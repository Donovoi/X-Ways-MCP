#requires -Version 7.0
[CmdletBinding()]
param(
    [string[]]$SearchRoot = @([Environment]::GetFolderPath('Desktop')),
    [string]$OutputRoot = '',
    [string]$ManualCachePath = '',
    [string]$BestPracticeCatalogPath = '',
    [int]$ContextChars = 360,
    [int]$MaxMatchesPerFile = 3000,
    [int]$ThrottleLimit = [Math]::Max(1, [Math]::Min([Environment]::ProcessorCount, 8))
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ShaPrefix {
    param([AllowNull()][string]$Text)
    if ($null -eq $Text) {
        $Text = ''
    }
    return ([System.BitConverter]::ToString(
        [System.Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($Text))
    ).Replace('-', '')).Substring(0, 16).ToUpperInvariant()
}

function Find-XwfCaseDbDir {
    param([string[]]$Roots)

    $eventFiles = foreach ($root in $Roots) {
        if (Test-Path -LiteralPath $root) {
            Get-ChildItem -LiteralPath $root -Recurse -File -Filter 'Events 2' -Force -ErrorAction SilentlyContinue
        }
    }

    $candidates = foreach ($eventFile in $eventFiles) {
        if (-not $eventFile.Directory -or -not $eventFile.Directory.Parent) {
            continue
        }

        $candidate = $eventFile.Directory.Parent.FullName
        $objectDirs = @(
            Get-ChildItem -LiteralPath $candidate -Directory -Force -ErrorAction SilentlyContinue |
                Where-Object {
                    (Test-Path -LiteralPath (Join-Path $_.FullName 'Names')) -or
                    (Test-Path -LiteralPath (Join-Path $_.FullName 'Events 2'))
                }
        )

        if ($objectDirs.Count -gt 0) {
            [pscustomobject]@{
                Dir = $candidate
                Newest = $eventFile.LastWriteTimeUtc
                ObjectDirCount = $objectDirs.Count
            }
        }
    }

    $chosen = @(
        $candidates |
            Group-Object Dir |
            ForEach-Object { $_.Group | Sort-Object Newest -Descending | Select-Object -First 1 } |
            Sort-Object Newest -Descending |
            Select-Object -First 1
    )[0]

    if (-not $chosen) {
        throw 'No X-Ways case database directory with evidence-object Events/Names was found.'
    }

    return $chosen.Dir
}

function Resolve-XwfWorkspaceRoot {
    param([Parameter(Mandatory)][string]$CaseDbDir)

    $caseDbInfo = Get-Item -LiteralPath $CaseDbDir
    if ($caseDbInfo.Parent -and $caseDbInfo.Parent.Name -eq 'xways-case') {
        return $caseDbInfo.Parent.Parent.FullName
    }

    return $caseDbInfo.FullName
}

function Import-XwfWorkflowModule {
    $repoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..') -ErrorAction SilentlyContinue
    if (-not $repoRoot) {
        return $false
    }

    $modulePath = Join-Path $repoRoot.Path 'powershell\XWaysForensicWorkflow\XWaysForensicWorkflow.psd1'
    if (-not (Test-Path -LiteralPath $modulePath)) {
        return $false
    }

    Import-Module $modulePath -Force
    return $true
}

function Get-BaseKey {
    param([Parameter(Mandatory)][string]$Leaf)

    $value = $Leaf.TrimStart('_') -replace '\.e01$', ''
    $value = ($value -split ',')[0].Trim()
    if (-not $value) {
        $value = $Leaf
    }
    return $value
}

function New-Counter {
    param([Parameter(Mandatory)]$Definitions)

    $counter = [ordered]@{}
    foreach ($definition in $Definitions) {
        $counter[$definition['Key']] = 0
    }
    return $counter
}

function Add-CounterSet {
    param(
        [Parameter(Mandatory)]$Target,
        [Parameter(Mandatory)]$Source,
        [Parameter(Mandatory)]$Definitions
    )

    foreach ($definition in $Definitions) {
        $key = $definition['Key']
        $Target[$key] += [int]$Source[$key]
    }
}

function Get-XwfObjectDirForPath {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$CaseDbDir
    )

    $caseDbFull = (Get-Item -LiteralPath $CaseDbDir).FullName
    $current = Get-Item -LiteralPath $Path
    if (-not $current.PSIsContainer) {
        $current = $current.Directory
    }

    while ($current) {
        if ($current.Parent -and $current.Parent.FullName -eq $caseDbFull) {
            return $current
        }
        if ($current.FullName -eq $caseDbFull) {
            return $null
        }
        $current = $current.Parent
    }

    return $null
}

function Find-RgPath {
    $command = Get-Command rg -ErrorAction SilentlyContinue
    if (-not $command) {
        throw 'ripgrep (rg) is required for this local path-string triage pass.'
    }
    return $command.Source
}

function Invoke-RgLines {
    param(
        [Parameter(Mandatory)][string]$RgPath,
        [Parameter(Mandatory)][string[]]$Arguments
    )

    $lines = & $RgPath @Arguments 2>$null
    if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne 1) {
        return @()
    }
    return @($lines)
}

$caseDbDir = Find-XwfCaseDbDir -Roots $SearchRoot
if (-not $OutputRoot) {
    $OutputRoot = Resolve-XwfWorkspaceRoot -CaseDbDir $caseDbDir
}

$reportsDir = Join-Path $OutputRoot 'reports'
$notesDir = Join-Path $OutputRoot 'notes'
New-Item -ItemType Directory -Path $reportsDir -Force | Out-Null
New-Item -ItemType Directory -Path $notesDir -Force | Out-Null

$moduleAvailable = Import-XwfWorkflowModule
if (-not $ManualCachePath) {
    $manualCandidate = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\tooling\cache\xways-manual\xways-manual.txt') -ErrorAction SilentlyContinue
    if ($manualCandidate) {
        $ManualCachePath = $manualCandidate.Path
    }
}
if (-not $BestPracticeCatalogPath) {
    $catalogCandidate = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\data\forensic-best-practices.json') -ErrorAction SilentlyContinue
    if ($catalogCandidate) {
        $BestPracticeCatalogPath = $catalogCandidate.Path
    }
}

$rgPath = Find-RgPath
$safeContextChars = [Math]::Max(80, [Math]::Min(1200, $ContextChars))
$safeMaxMatchesPerFile = [Math]::Max(100, [Math]::Min(100000, $MaxMatchesPerFile))

$categoryDefs = @(
    @{ Key = 'browser_web'; Label = 'Browser and web activity'; Terms = @('Chrome', 'Edge', 'Firefox', 'Mozilla', 'History', 'TypedURLs', 'Visited', 'URL', 'http', 'https', 'Download', 'Cache', 'Cookie', 'WebCacheV01', 'places.sqlite', 'Cookies.sqlite') },
    @{ Key = 'execution_apps'; Label = 'Program execution and application traces'; Terms = @('Prefetch', 'UserAssist', 'Amcache', 'ShimCache', 'AppCompat', 'SRUM', '.pf', 'RunMRU', 'RunOnce', 'Services', 'Scheduled Task', 'TaskCache', 'RecentApps') },
    @{ Key = 'logon_remote'; Label = 'Logon, authentication, and remote access'; Terms = @('Logon', 'Logoff', 'RDP', 'Remote Desktop', 'TerminalServices', 'RemoteConnectionManager', 'Winlogon', 'Security-Auditing', '4624', '4634', '4647', '4672', '4776', '1149', 'CredMan', 'Credentials') },
    @{ Key = 'file_shell'; Label = 'File, shell, and document interaction'; Terms = @('$UsnJrnl', '$LogFile', 'Recent', 'Jump List', 'AutomaticDestinations', 'CustomDestinations', '.lnk', 'OpenSavePidlMRU', 'LastVisitedPidlMRU', 'ShellBags', 'BagMRU', 'Recycle', 'Downloads', 'Desktop', 'Documents', 'OfficeFileCache') },
    @{ Key = 'user_file_area'; Label = 'User profile file-area activity'; Terms = @('\Desktop\', '/Desktop/', '\Documents\', '/Documents/', '\Downloads\', '/Downloads/', '\Pictures\', '/Pictures/', '\Videos\', '/Videos/', '\AppData\', '/AppData/') },
    @{ Key = 'external_storage'; Label = 'External storage and mounted devices'; Terms = @('USBSTOR', 'MountedDevices', 'MountPoints2', 'Portable Devices', 'Volume Serial', 'Device Install', 'setupapi', 'Removable', 'WPDBUSENUM') },
    @{ Key = 'communications'; Label = 'Communications and collaboration artifacts'; Terms = @('Outlook', '.pst', '.ost', 'Teams', 'Skype', 'Slack', 'Discord', 'Thunderbird', 'Mail', 'Conversation', 'Chat', 'Zoom') },
    @{ Key = 'cloud_sync'; Label = 'Cloud sync and storage artifacts'; Terms = @('OneDrive', 'Dropbox', 'Google Drive', 'iCloud', 'Box Sync') },
    @{ Key = 'registry_system'; Label = 'Registry and system configuration'; Terms = @('NTUSER.DAT', 'UsrClass.dat', 'SYSTEM', 'SOFTWARE', 'SAM', 'SECURITY', 'Registry', 'ComputerName', 'CurrentVersion', 'ProfileList') },
    @{ Key = 'carved_recovered'; Label = 'Carved/recovered or free-space-originated artifacts'; Terms = @('Carved', 'Recovered', 'file header', 'header signature', 'free space', 'unallocated', 'slack') }
)

$termAlternates = @(
    '\\Users\\',
    '/Users/',
    'Documents and Settings',
    'AppData',
    'NTUSER\.DAT',
    'UsrClass\.dat',
    'AutomaticDestinations',
    'CustomDestinations',
    'Prefetch',
    'WebCacheV01',
    'places\.sqlite',
    'Cookies\.sqlite',
    'History',
    'Downloads',
    'Desktop',
    'Documents',
    '\.lnk',
    '\.evtx',
    'Teams',
    'Slack',
    'Discord',
    'Outlook',
    '\.ost',
    '\.pst',
    'OneDrive',
    'Dropbox',
    'USBSTOR',
    'MountedDevices',
    'MountPoints2',
    'Carved',
    'Recovered',
    'free space',
    'unallocated'
)
$prefilterPattern = '(?:' + ($termAlternates -join '|') + ')'
$snippetPattern = '.{0,' + $safeContextChars + '}' + $prefilterPattern + '.{0,' + $safeContextChars + '}'

$candidateRows = New-Object System.Collections.Generic.List[object]
foreach ($encoding in @('ascii', 'utf-16le')) {
    $arguments = @('-a', '-i', '-l', '--color', 'never')
    if ($encoding -eq 'utf-16le') {
        $arguments += @('--encoding', 'utf-16le')
    }
    $arguments += @('-e', $prefilterPattern, '--', $caseDbDir)

    foreach ($path in @(Invoke-RgLines -RgPath $rgPath -Arguments $arguments)) {
        if ([string]::IsNullOrWhiteSpace($path)) {
            continue
        }
        $resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
        if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
            continue
        }
        $candidateRows.Add([pscustomobject]@{
            file_path = $resolvedPath
            encoding = $encoding
        }) | Out-Null
    }
}

$candidateRows = @(
    $candidateRows |
        Group-Object { '{0}|{1}' -f $_.file_path, $_.encoding } |
        ForEach-Object { $_.Group | Select-Object -First 1 }
)

$manualGate = $null
$actionGate = $null
$bestPractices = $null
if ($moduleAvailable) {
    if ($ManualCachePath) {
        $manualGate = Test-XwfManualGate -Query 'X-Ways case data storage event list case report metadata names evidence object database export list container' -RequiredTerms @('Event Lists', 'Case Report', 'Names', 'evidence file container') -ManualCachePath $ManualCachePath
    }
    $manualGatePassed = $false
    if ($manualGate) {
        $manualGatePassed = [bool]$manualGate.allowed
    }
    $actionGate = Test-XwfForensicAction -Action 'Read X-Ways case database metadata path strings for local usage-pattern triage' -OutputKind 'QueryOnly' -ManualReference 'X-Ways manual: Event Lists; Case Report; Administration Tips Case Data Storage table for Events/Names/metadata; Export List metadata-only distinction; evidence file containers for byte export.' -ManualGatePassed:$manualGatePassed
    if ($BestPracticeCatalogPath) {
        $bestPractices = Select-XwfBestPractice -CatalogPath $BestPracticeCatalogPath -Jurisdiction @('international', 'australia', 'usa', 'united_kingdom') -Theme @('analysis', 'documentation', 'reproducibility', 'tool_validation', 'preservation') -Limit 8 -Reason 'Read-only X-Ways case database path-string triage, no evidence modification, no raw file-content export.'
    }
}

$worker = {
    $row = $_
    $definitions = $using:categoryDefs
    $rgExe = $using:rgPath
    $pattern = $using:snippetPattern
    $caseDb = $using:caseDbDir
    $maxMatches = $using:safeMaxMatchesPerFile

    function Get-ShaPrefixWorker {
        param([AllowNull()][string]$Text)
        if ($null -eq $Text) { $Text = '' }
        return ([System.BitConverter]::ToString(
            [System.Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($Text))
        ).Replace('-', '')).Substring(0, 16).ToUpperInvariant()
    }

    function Get-BaseKeyWorker {
        param([string]$Leaf)
        $value = $Leaf.TrimStart('_') -replace '\.e01$', ''
        $value = ($value -split ',')[0].Trim()
        if (-not $value) { $value = $Leaf }
        return $value
    }

    function New-CounterWorker {
        param($Definitions)
        $counter = [ordered]@{}
        foreach ($definition in $Definitions) { $counter[$definition['Key']] = 0 }
        return $counter
    }

    function Add-CategoryHitsWorker {
        param([string]$Text, $Counter, $Definitions)
        foreach ($definition in $Definitions) {
            foreach ($term in $definition['Terms']) {
                if ($Text.IndexOf($term, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                    $Counter[$definition['Key']]++
                    break
                }
            }
        }
    }

    function Get-UsersFromSnippetWorker {
        param([string]$Text)

        $patterns = @(
            '(?i)(?:^|[\\/])Users[\\/]([^\\/:\*\?"<>\|\r\n]{1,80})(?=[\\/])',
            '(?i)(?:^|[\\/])Documents and Settings[\\/]([^\\/:\*\?"<>\|\r\n]{1,80})(?=[\\/])'
        )
        $users = New-Object System.Collections.Generic.List[string]
        foreach ($userPattern in $patterns) {
            foreach ($match in [regex]::Matches($Text, $userPattern)) {
                $name = $match.Groups[1].Value.Trim()
                if (-not $name) { continue }
                if ($name -notmatch '^[A-Za-z0-9._ -]{1,80}$') { continue }
                if ($name -match '^(Public|Default|Default User|All Users|desktop\.ini|DefaultAppPool)$') { continue }
                $users.Add($name) | Out-Null
            }
        }
        return @($users | Sort-Object -Unique)
    }

    function Get-XwfObjectDirForPathWorker {
        param([string]$Path, [string]$CaseDbDir)

        $caseDbFull = (Get-Item -LiteralPath $CaseDbDir).FullName
        $current = Get-Item -LiteralPath $Path
        if (-not $current.PSIsContainer) { $current = $current.Directory }
        while ($current) {
            if ($current.Parent -and $current.Parent.FullName -eq $caseDbFull) {
                return $current
            }
            if ($current.FullName -eq $caseDbFull) {
                return $null
            }
            $current = $current.Parent
        }
        return $null
    }

    $arguments = @('-a', '-i', '--only-matching', '--no-filename', '--color', 'never', '--max-count', [string]$maxMatches)
    if ($row.encoding -eq 'utf-16le') {
        $arguments += @('--encoding', 'utf-16le')
    }
    $arguments += @('-e', $pattern, '--', $row.file_path)

    $lines = & $rgExe @arguments 2>$null
    if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne 1) {
        $lines = @()
    }
    $lines = @($lines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })

    $objectDir = Get-XwfObjectDirForPathWorker -Path $row.file_path -CaseDbDir $caseDb
    if (-not $objectDir) {
        return $null
    }

    $objectCounter = New-CounterWorker -Definitions $definitions
    $userMap = @{}
    $snippetCount = 0
    foreach ($line in $lines) {
        $snippetCount++
        Add-CategoryHitsWorker -Text $line -Counter $objectCounter -Definitions $definitions
        foreach ($rawUser in @(Get-UsersFromSnippetWorker -Text $line)) {
            if (-not $userMap.ContainsKey($rawUser)) {
                $userMap[$rawUser] = [pscustomobject]@{
                    RawUser = $rawUser
                    Mentions = 0
                    Counters = (New-CounterWorker -Definitions $definitions)
                }
            }
            $userMap[$rawUser].Mentions++
            Add-CategoryHitsWorker -Text $line -Counter $userMap[$rawUser].Counters -Definitions $definitions
        }
    }

    [pscustomobject]@{
        RawBaseKey = Get-BaseKeyWorker -Leaf $objectDir.Name
        RawObjectName = $objectDir.Name
        ObjectHash = Get-ShaPrefixWorker $objectDir.Name
        SourceFileHash = Get-ShaPrefixWorker $row.file_path
        Encoding = $row.encoding
        SnippetCount = $snippetCount
        ObjectCounters = $objectCounter
        Users = @($userMap.Values)
    }
}

if ($candidateRows.Count -gt 0 -and $PSVersionTable.PSVersion.Major -ge 7) {
    $scanResults = @($candidateRows | ForEach-Object -Parallel $worker -ThrottleLimit $ThrottleLimit | Where-Object { $_ })
}
else {
    $scanResults = @($candidateRows | ForEach-Object $worker | Where-Object { $_ })
}

$aliasMap = [ordered]@{
    created_utc = (Get-Date).ToUniversalTime().ToString('o')
    warning = 'Sensitive local alias map. Do not publish.'
    machines = @()
    users = @()
    objects = @()
}

$machines = New-Object System.Collections.Generic.List[object]
$machineIndex = 0
foreach ($group in ($scanResults | Group-Object RawBaseKey | Sort-Object Name)) {
    $machineIndex++
    $machineAlias = 'M{0:000}' -f $machineIndex
    $aliasMap.machines += [pscustomobject]@{
        alias = $machineAlias
        raw = $group.Name
        hash = Get-ShaPrefix $group.Name
    }

    $aggregate = New-Counter -Definitions $categoryDefs
    $userAggregate = @{}
    $objects = @{}
    $sourceFiles = @{}
    $encodings = @{}
    $snippetCount = 0

    foreach ($result in $group.Group) {
        $objects[$result.ObjectHash] = $result.RawObjectName
        $sourceFiles[$result.SourceFileHash] = $true
        $encodings[$result.Encoding] = $true
        $snippetCount += [int]$result.SnippetCount
        Add-CounterSet -Target $aggregate -Source $result.ObjectCounters -Definitions $categoryDefs

        foreach ($user in @($result.Users)) {
            $rawUser = [string]$user.RawUser
            if (-not $userAggregate.ContainsKey($rawUser)) {
                $userAggregate[$rawUser] = [pscustomobject]@{
                    RawUser = $rawUser
                    Mentions = 0
                    Counters = (New-Counter -Definitions $categoryDefs)
                }
            }
            $userAggregate[$rawUser].Mentions += [int]$user.Mentions
            Add-CounterSet -Target $userAggregate[$rawUser].Counters -Source $user.Counters -Definitions $categoryDefs
        }
    }

    foreach ($objectEntry in $objects.GetEnumerator()) {
        $aliasMap.objects += [pscustomobject]@{
            machine_alias = $machineAlias
            raw = $objectEntry.Value
            hash = $objectEntry.Key
        }
    }

    $userIndex = 0
    $users = foreach ($user in ($userAggregate.Values | Sort-Object RawUser)) {
        $userIndex++
        $userAlias = 'U{0:000}' -f $userIndex
        $aliasMap.users += [pscustomobject]@{
            machine_alias = $machineAlias
            user_alias = $userAlias
            raw = $user.RawUser
            hash = Get-ShaPrefix "$($group.Name)|$($user.RawUser)"
        }
        $topUserSignals = @(
            $categoryDefs |
                ForEach-Object { [pscustomobject]@{ key = $_['Key']; label = $_['Label']; count = [int]$user.Counters[$_['Key']] } } |
                Where-Object Count -gt 0 |
                Sort-Object Count -Descending |
                Select-Object -First 6
        )
        [pscustomobject]@{
            user_alias = $userAlias
            path_string_mentions = $user.Mentions
            signals = $user.Counters
            top_signals = $topUserSignals
        }
    }

    $topSignals = @(
        $categoryDefs |
            ForEach-Object { [pscustomobject]@{ key = $_['Key']; label = $_['Label']; count = [int]$aggregate[$_['Key']] } } |
            Where-Object Count -gt 0 |
            Sort-Object Count -Descending |
            Select-Object -First 8
    )

    $machines.Add([pscustomobject]@{
        machine_alias = $machineAlias
        evidence_object_count = $objects.Count
        candidate_source_files = $sourceFiles.Count
        encodings = @($encodings.Keys | Sort-Object)
        matched_path_strings = $snippetCount
        users_detected = @($users).Count
        signals = $aggregate
        top_signals = $topSignals
        users = @($users)
    }) | Out-Null
}

$usersTotal = (@($machines | ForEach-Object { $_.users_detected }) | Measure-Object -Sum).Sum
if (-not $usersTotal) {
    $usersTotal = 0
}

$manualGateAllowed = $false
if ($manualGate) {
    $manualGateAllowed = [bool]$manualGate.allowed
}
$actionGateAllowed = $false
if ($actionGate) {
    $actionGateAllowed = [bool]$actionGate.allowed
}

$categoryDefinitionOutput = foreach ($definition in $categoryDefs) {
    [pscustomobject]@{
        key = [string]$definition['Key']
        label = [string]$definition['Label']
    }
}

$runStamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$reportPath = Join-Path $reportsDir "usage-pattern-pathstrings-$runStamp.sanitized.md"
$jsonPath = Join-Path $reportsDir "usage-pattern-pathstrings-$runStamp.structured.sanitized.json"
$aliasMapPath = Join-Path $reportsDir "usage-pattern-pathstrings-$runStamp.alias-map.local.json"
$notebookPath = Join-Path $notesDir 'contemporaneous-notes.jsonl'

$caveatsOutput = @(
    'This is a query-first triage pass over X-Ways case database path-like strings, not a raw artifact parser report.',
    'Counts represent matched metadata strings/signals, not unique user actions.',
    'No raw carved files or evidence file contents were exported; raw snippets were not persisted.',
    'Validate individual findings inside X-Ways Event List, Directory Browser, Case Report, or a documented X-Tension before evidential reliance.',
    'The sensitive local alias map is intentionally separate from the sanitized report.'
)

$structured = [pscustomobject][ordered]@{
    created_utc = (Get-Date).ToUniversalTime().ToString('o')
    scope = 'Read-only triage over X-Ways case database path-like metadata strings. No file contents exported.'
    status = 'triage_leads_require_validation_in_xways_or_xtension'
    manual_gate_allowed = $manualGateAllowed
    action_gate_allowed = $actionGateAllowed
    workers_requested = $ThrottleLimit
    candidate_files_with_path_strings = $candidateRows.Count
    result_files_with_matches = $scanResults.Count
    machines_detected = $machines.Count
    users_detected_total = $usersTotal
    category_definitions = @($categoryDefinitionOutput)
    machines = @($machines.ToArray())
    caveats = $caveatsOutput
}

$structured | ConvertTo-Json -Depth 16 | Set-Content -LiteralPath $jsonPath -Encoding UTF8
$aliasMap | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $aliasMapPath -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# Usage Pattern Triage from X-Ways Case DB Path Strings') | Out-Null
$lines.Add('') | Out-Null
$lines.Add("Created UTC: $($structured.created_utc)") | Out-Null
$lines.Add('') | Out-Null
$lines.Add('Scope: read-only triage over X-Ways case database path-like metadata strings. No carved files or evidence file contents were exported, and raw snippets were not persisted.') | Out-Null
$lines.Add('Forensic status: triage leads only until validated in X-Ways Event List, Directory Browser, Case Report, or a documented X-Tension.') | Out-Null
$lines.Add('') | Out-Null
$lines.Add('## Manual And SOP Gate') | Out-Null
$lines.Add('') | Out-Null
$lines.Add("- Manual gate allowed: $($structured.manual_gate_allowed)") | Out-Null
$lines.Add("- Action gate allowed: $($structured.action_gate_allowed)") | Out-Null
$lines.Add('- X-Ways manual references used: Event Lists; Case Report; Administration Tips Case Data Storage table for Events/Names/metadata; Export List metadata-only distinction; evidence file containers for byte export.') | Out-Null
$lines.Add('- Best-practice basis: ISO/IEC 27037/27041/27042 plus local AU/US/UK guidance selected from the local catalog for preservation, reproducibility, documentation, and tool validation.') | Out-Null
$lines.Add('') | Out-Null
$lines.Add('## High-Level Findings') | Out-Null
$lines.Add('') | Out-Null
$lines.Add("- Machine/evidence groups detected: $($structured.machines_detected)") | Out-Null
$lines.Add("- User profiles detected across accessible groups: $($structured.users_detected_total)") | Out-Null
$lines.Add("- Candidate case-DB files with path-like strings: $($structured.candidate_files_with_path_strings)") | Out-Null
$lines.Add("- Result files with matched snippets: $($structured.result_files_with_matches)") | Out-Null
$lines.Add("- Parallel workers requested: $ThrottleLimit") | Out-Null
$lines.Add('') | Out-Null

foreach ($machine in $machines) {
    $lines.Add("## $($machine.machine_alias)") | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add("- Evidence-object database directories represented: $($machine.evidence_object_count)") | Out-Null
    $lines.Add("- Candidate source files represented: $($machine.candidate_source_files)") | Out-Null
    $lines.Add("- Encodings matched: $((@($machine.encodings) -join ', '))") | Out-Null
    $lines.Add("- Matched path-like strings: $($machine.matched_path_strings)") | Out-Null
    $lines.Add("- User profiles detected: $($machine.users_detected)") | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add('Top machine-level signal families:') | Out-Null
    if (@($machine.top_signals).Count -eq 0) {
        $lines.Add('- No categorized path-string signals matched in this pass.') | Out-Null
    }
    else {
        foreach ($signal in @($machine.top_signals)) {
            $lines.Add("- $($signal.label): $($signal.count)") | Out-Null
        }
    }
    $lines.Add('') | Out-Null
    if (@($machine.users).Count -eq 0) {
        $lines.Add('Detected user profiles and signal families: none from accessible path-like strings in this pass.') | Out-Null
    }
    else {
        $lines.Add('Detected user profiles and signal families:') | Out-Null
        foreach ($user in @($machine.users)) {
            $topUser = @($user.top_signals | Select-Object -First 5)
            $parts = if ($topUser.Count) {
                ($topUser | ForEach-Object { "$($_.label)=$($_.count)" }) -join '; '
            }
            else {
                'no categorized signal strings'
            }
            $lines.Add("- $($user.user_alias): path-string mentions=$($user.path_string_mentions), $parts") | Out-Null
        }
    }
    $lines.Add('') | Out-Null
}

$lines.Add('## Caveats') | Out-Null
$lines.Add('') | Out-Null
foreach ($caveat in $structured.caveats) {
    $lines.Add("- $caveat") | Out-Null
}
$lines.Add('') | Out-Null
$lines.Add('Sensitive raw machine/user labels are stored only in the local alias-map file created next to this report. Do not publish that alias map.') | Out-Null
$lines -join "`r`n" | Set-Content -LiteralPath $reportPath -Encoding UTF8

if ($moduleAvailable) {
    Add-XwfContemporaneousNote `
        -NotebookPath $notebookPath `
        -Category 'analysis' `
        -Action 'Generated read-only usage-pattern triage from X-Ways case database path strings' `
        -Rationale 'Continue the original task while honoring query-first, manual-first, and no ordinary filesystem export rules. The analysis reads X-Ways case database metadata strings and writes sanitized local findings plus a local-only alias map.' `
        -ManualReference 'X-Ways manual: Event Lists; Case Report; Administration Tips Case Data Storage table for Events/Names/metadata; Export List metadata-only distinction; evidence file containers for byte export.' `
        -How "Located the active local X-Ways case database, used ripgrep as a local read-only prefilter over case-DB metadata files, extracted path-like string snippets in memory only, grouped signals by evidence-object base and user profile paths, wrote sanitized report/JSON and a local alias map. Used up to $ThrottleLimit parallel workers when PowerShell supported it." `
        -BestPracticeReferences $(if ($bestPractices) { $bestPractices.selected } else { @() }) `
        -BestPracticeSelectionRationale $(if ($bestPractices) { $bestPractices.selection_rationale } else { 'Best-practice catalog unavailable.' }) `
        -SoundnessCheck @{
            original_evidence_modified = $false
            raw_file_content_exported = $false
            carved_files_exported = $false
            raw_snippets_persisted = $false
            source = 'X-Ways case database path-like metadata strings'
            output = 'sanitized derived report and local alias map'
            manual_gate_allowed = $structured.manual_gate_allowed
            action_gate_allowed = $structured.action_gate_allowed
            validation_required = $true
        } `
        -Result 'Sanitized usage-pattern path-string report and local alias map written to the Desktop case reports folder.' | Out-Null
}

[pscustomobject]@{
    ok = $true
    machines_detected = $structured.machines_detected
    users_detected_total = $structured.users_detected_total
    candidate_files_with_path_strings = $structured.candidate_files_with_path_strings
    result_files_with_matches = $structured.result_files_with_matches
    workers_requested = $ThrottleLimit
    manual_gate_allowed = $structured.manual_gate_allowed
    action_gate_allowed = $structured.action_gate_allowed
    report_bytes = (Get-Item -LiteralPath $reportPath).Length
    report_hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $reportPath).Hash.Substring(0, 16)
    structured_hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $jsonPath).Hash.Substring(0, 16)
    alias_map_hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $aliasMapPath).Hash.Substring(0, 16)
}

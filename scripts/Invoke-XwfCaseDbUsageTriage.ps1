param(
    [string[]]$SearchRoot = @([Environment]::GetFolderPath('Desktop')),
    [string]$OutputRoot = '',
    [string]$ManualCachePath = '',
    [string]$BestPracticeCatalogPath = '',
    [int]$ThrottleLimit = [Math]::Max(1, [Math]::Min([Environment]::ProcessorCount, 4))
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ShaPrefix {
    param([Parameter(Mandatory)][string]$Text)
    return ([System.BitConverter]::ToString(
        [System.Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($Text))
    ).Replace('-', '')).Substring(0, 12)
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

function Read-SharedBytes {
    param([Parameter(Mandatory)][string]$Path)

    try {
        $share = [System.IO.FileShare]::ReadWrite -bor [System.IO.FileShare]::Delete
        $fs = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, $share)
        try {
            if ($fs.Length -le 0) {
                return [byte[]]@()
            }
            $buffer = New-Object byte[] $fs.Length
            [void]$fs.Read($buffer, 0, $buffer.Length)
            return $buffer
        }
        finally {
            $fs.Dispose()
        }
    }
    catch {
        return [byte[]]@()
    }
}

function New-Counter {
    param([Parameter(Mandatory)]$Definitions)

    $counter = [ordered]@{}
    foreach ($definition in $Definitions) {
        $counter[$definition['Key']] = 0
    }
    return $counter
}

function Add-CategoryHits {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)]$Counter,
        [Parameter(Mandatory)]$Definitions
    )

    foreach ($definition in $Definitions) {
        foreach ($term in $definition['Terms']) {
            if ($Text.IndexOf($term, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                $Counter[$definition['Key']]++
                break
            }
        }
    }
}

function Add-UserPathMentions {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][hashtable]$UserMap,
        [Parameter(Mandatory)]$ObjectCounter,
        [Parameter(Mandatory)]$Definitions,
        [switch]$FromEvent
    )

    $mentions = 0
    $markers = @('\Users\', '/Users/')
    foreach ($marker in $markers) {
        $position = 0
        while ($position -lt $Text.Length) {
            $index = $Text.IndexOf($marker, $position, [System.StringComparison]::OrdinalIgnoreCase)
            if ($index -lt 0) {
                break
            }

            $userStart = $index + $marker.Length
            $userEndSlash = $Text.IndexOf('\', $userStart)
            $userEndForward = $Text.IndexOf('/', $userStart)
            $candidateEnds = @($userEndSlash, $userEndForward) | Where-Object { $_ -ge 0 }
            if ($candidateEnds.Count -eq 0) {
                $position = $index + $marker.Length
                continue
            }

            $userEnd = ($candidateEnds | Measure-Object -Minimum).Minimum
            if ($userEnd -le $userStart) {
                $position = $index + $marker.Length
                continue
            }

            $user = $Text.Substring($userStart, [Math]::Min(80, $userEnd - $userStart))
            if ($user -notmatch '^[A-Za-z0-9._ -]{1,80}$' -or $user -match '^(Public|Default|Default User|All Users|desktop\.ini)$') {
                $position = $index + $marker.Length
                continue
            }

            $snippetLength = [Math]::Min(600, $Text.Length - $index)
            $snippet = $Text.Substring($index, $snippetLength)
            if (-not $UserMap.ContainsKey($user)) {
                $UserMap[$user] = [pscustomobject]@{
                    RawUser = $user
                    Counters = (New-Counter -Definitions $Definitions)
                    PathMentions = 0
                    EventMentions = 0
                }
            }

            if ($FromEvent) {
                $UserMap[$user].EventMentions++
            }
            else {
                $UserMap[$user].PathMentions++
            }
            Add-CategoryHits -Text $snippet -Counter $UserMap[$user].Counters -Definitions $Definitions
            Add-CategoryHits -Text $snippet -Counter $ObjectCounter -Definitions $Definitions

            $mentions++
            $position = $index + $marker.Length
        }
    }

    return $mentions
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

$categoryDefs = @(
    @{ Key = 'browser_web'; Label = 'Browser and web activity'; Terms = @('Chrome', 'Edge', 'Firefox', 'History', 'TypedURLs', 'Visited', 'URL', 'http', 'https', 'Download', 'Cache', 'Cookie', 'WebCacheV01', 'places.sqlite') },
    @{ Key = 'execution_apps'; Label = 'Program execution and application traces'; Terms = @('Prefetch', 'UserAssist', 'Amcache', 'ShimCache', 'AppCompat', 'SRUM', '.pf', 'RunMRU', 'RunOnce', 'Services', 'Scheduled Task', 'TaskCache', 'RecentApps') },
    @{ Key = 'logon_remote'; Label = 'Logon, authentication, and remote access'; Terms = @('Logon', 'Logoff', 'RDP', 'Remote Desktop', 'TerminalServices', 'Winlogon', 'Security-Auditing', '4624', '4634', '4647', '4672', '4776', '1149', 'CredMan', 'Credentials') },
    @{ Key = 'file_shell'; Label = 'File, shell, and document interaction'; Terms = @('$UsnJrnl', '$LogFile', 'Recent', 'Jump List', 'AutomaticDestinations', 'CustomDestinations', '.lnk', 'OpenSavePidlMRU', 'LastVisitedPidlMRU', 'ShellBags', 'BagMRU', 'Recycle', 'Downloads', 'Desktop', 'Documents', 'OfficeFileCache') },
    @{ Key = 'external_storage'; Label = 'External storage and mounted devices'; Terms = @('USBSTOR', 'MountedDevices', 'MountPoints2', 'Portable Devices', 'Volume Serial', 'Device Install', 'setupapi', 'Removable', 'WPDBUSENUM') },
    @{ Key = 'communications'; Label = 'Communications and collaboration artifacts'; Terms = @('Outlook', '.pst', '.ost', 'Teams', 'Skype', 'Slack', 'Discord', 'Thunderbird', 'Mail', 'Conversation', 'Chat') },
    @{ Key = 'registry_system'; Label = 'Registry and system configuration'; Terms = @('NTUSER.DAT', 'UsrClass.dat', 'SYSTEM', 'SOFTWARE', 'SAM', 'SECURITY', 'Registry', 'ComputerName', 'CurrentVersion', 'ProfileList') },
    @{ Key = 'carved_recovered'; Label = 'Carved/recovered or free-space-originated artifacts'; Terms = @('Carved', 'Recovered', 'file header', 'header signature', 'free space', 'unallocated', 'slack') }
)

$genericNames = @('Main', 'Main 2', 'Main 3', 'Names', 'Events 1', 'Events 2', 'Metadata', 'Search Hits', 'Decoded', 'Xtra', 'Comments', 'Hash Values', 'Matches', 'Bitmap', 'SenRec')
$objectDirs = @(
    Get-ChildItem -LiteralPath $caseDbDir -Directory -Force -ErrorAction SilentlyContinue |
        Where-Object {
            $dirPath = $_.FullName
            @($genericNames | Where-Object { Test-Path -LiteralPath (Join-Path $dirPath $_) }).Count -gt 0
        }
)
if ($objectDirs.Count -eq 0) {
    throw 'No X-Ways evidence-object database directories were found.'
}

$workerScript = {
    $definitions = $using:categoryDefs

    function Read-SharedBytesWorker {
        param([Parameter(Mandatory)][string]$Path)
        try {
            $share = [System.IO.FileShare]::ReadWrite -bor [System.IO.FileShare]::Delete
            $fs = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, $share)
            try {
                if ($fs.Length -le 0) { return [byte[]]@() }
                $buffer = New-Object byte[] $fs.Length
                [void]$fs.Read($buffer, 0, $buffer.Length)
                return $buffer
            }
            finally {
                $fs.Dispose()
            }
        }
        catch {
            return [byte[]]@()
        }
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

    function Add-CategoryTermCountsWorker {
        param([string]$Text, $Counter, $Definitions)
        foreach ($definition in $Definitions) {
            $total = 0
            foreach ($term in $definition['Terms']) {
                $position = 0
                while ($position -lt $Text.Length) {
                    $index = $Text.IndexOf($term, $position, [System.StringComparison]::OrdinalIgnoreCase)
                    if ($index -lt 0) { break }
                    $total++
                    $position = $index + [Math]::Max(1, $term.Length)
                }
            }
            if ($total -gt 0) {
                $Counter[$definition['Key']] += $total
            }
        }
    }

    function Add-UserPathMentionsWorker {
        param([string]$Text, [hashtable]$UserMap, $ObjectCounter, $Definitions, [switch]$FromEvent)
        $mentions = 0
        foreach ($marker in @('\Users\', '/Users/')) {
            $position = 0
            while ($position -lt $Text.Length) {
                $index = $Text.IndexOf($marker, $position, [System.StringComparison]::OrdinalIgnoreCase)
                if ($index -lt 0) { break }
                $userStart = $index + $marker.Length
                $slash1 = $Text.IndexOf('\', $userStart)
                $slash2 = $Text.IndexOf('/', $userStart)
                $ends = @($slash1, $slash2) | Where-Object { $_ -ge 0 }
                if ($ends.Count -eq 0) { $position = $index + $marker.Length; continue }
                $userEnd = ($ends | Measure-Object -Minimum).Minimum
                if ($userEnd -le $userStart) { $position = $index + $marker.Length; continue }
                $user = $Text.Substring($userStart, [Math]::Min(80, $userEnd - $userStart))
                if ($user -notmatch '^[A-Za-z0-9._ -]{1,80}$' -or $user -match '^(Public|Default|Default User|All Users|desktop\.ini)$') {
                    $position = $index + $marker.Length
                    continue
                }
                $snippet = $Text.Substring($index, [Math]::Min(600, $Text.Length - $index))
                if (-not $UserMap.ContainsKey($user)) {
                    $UserMap[$user] = [pscustomobject]@{
                        RawUser = $user
                        Counters = (New-CounterWorker -Definitions $Definitions)
                        PathMentions = 0
                        EventMentions = 0
                    }
                }
                if ($FromEvent) { $UserMap[$user].EventMentions++ } else { $UserMap[$user].PathMentions++ }
                Add-CategoryHitsWorker -Text $snippet -Counter $UserMap[$user].Counters -Definitions $Definitions
                Add-CategoryHitsWorker -Text $snippet -Counter $ObjectCounter -Definitions $Definitions
                $mentions++
                $position = $index + $marker.Length
            }
        }
        return $mentions
    }

    function Get-BaseKeyWorker {
        param([string]$Leaf)
        $value = $Leaf.TrimStart('_') -replace '\.e01$', ''
        $value = ($value -split ',')[0].Trim()
        if (-not $value) { $value = $Leaf }
        return $value
    }

    function Get-ShaPrefixWorker {
        param([string]$Text)
        return ([System.BitConverter]::ToString(
            [System.Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($Text))
        ).Replace('-', '')).Substring(0, 12)
    }

    $dir = $_
    $objectCounter = New-CounterWorker -Definitions $definitions
    $userMap = @{}
    $eventStringCount = 0
    $nameUserPathMentions = 0
    $sourceKinds = New-Object System.Collections.Generic.List[string]

    foreach ($eventFile in @(Get-ChildItem -LiteralPath $dir.FullName -File -Filter 'Events 2' -Force -ErrorAction SilentlyContinue)) {
        $bytes = Read-SharedBytesWorker -Path $eventFile.FullName
        if ($bytes.Length -eq 0) { continue }
        $text = [Text.Encoding]::ASCII.GetString($bytes)
        $eventStringCount += [regex]::Matches($text, '[ -~]{6,500}').Count
        Add-CategoryHitsWorker -Text $text -Counter $objectCounter -Definitions $definitions
        [void](Add-UserPathMentionsWorker -Text $text -UserMap $userMap -ObjectCounter $objectCounter -Definitions $definitions -FromEvent)
        $sourceKinds.Add('Events 2') | Out-Null
    }

    foreach ($nameFile in @(Get-ChildItem -LiteralPath $dir.FullName -File -Filter 'Names' -Force -ErrorAction SilentlyContinue)) {
        $bytes = Read-SharedBytesWorker -Path $nameFile.FullName
        if ($bytes.Length -eq 0) { continue }
        $text = [Text.Encoding]::Unicode.GetString($bytes)
        Add-CategoryTermCountsWorker -Text $text -Counter $objectCounter -Definitions $definitions
        $nameUserPathMentions += Add-UserPathMentionsWorker -Text $text -UserMap $userMap -ObjectCounter $objectCounter -Definitions $definitions
        $sourceKinds.Add('Names') | Out-Null
    }

    foreach ($metaFile in @(Get-ChildItem -LiteralPath $dir.FullName -File -Filter 'Metadata' -Force -ErrorAction SilentlyContinue)) {
        if ($metaFile.Length -gt 0) { $sourceKinds.Add('Metadata') | Out-Null }
    }

        [pscustomobject]@{
        RawBaseKey = Get-BaseKeyWorker -Leaf $dir.Name
        RawObjectName = $dir.Name
        ObjectHash = Get-ShaPrefixWorker $dir.Name
        SourceKinds = @($sourceKinds | Select-Object -Unique)
        EventStringCount = $eventStringCount
        NameUserPathMentions = $nameUserPathMentions
        ObjectCounters = $objectCounter
        Users = @($userMap.Values)
    }
}

$objectResults = @($objectDirs | ForEach-Object -Parallel $workerScript -ThrottleLimit $ThrottleLimit)

$aliasMap = [ordered]@{
    created_utc = (Get-Date).ToUniversalTime().ToString('o')
    warning = 'Sensitive local alias map. Do not publish.'
    machines = @()
    users = @()
    objects = @()
}

$machines = New-Object System.Collections.Generic.List[object]
$machineIndex = 0
foreach ($group in ($objectResults | Group-Object RawBaseKey | Sort-Object Name)) {
    $machineIndex++
    $machineAlias = 'M{0:000}' -f $machineIndex
    $aliasMap.machines += [pscustomobject]@{ alias = $machineAlias; raw = $group.Name; hash = Get-ShaPrefix $group.Name }

    $aggregate = New-Counter -Definitions $categoryDefs
    $sourceKinds = New-Object System.Collections.Generic.List[string]
    $eventStrings = 0
    $userPathMentions = 0
    $userAggregate = @{}

    foreach ($object in $group.Group) {
        $aliasMap.objects += [pscustomobject]@{ machine_alias = $machineAlias; raw = $object.RawObjectName; hash = $object.ObjectHash }
        foreach ($definition in $categoryDefs) {
            $aggregate[$definition['Key']] += [int]$object.ObjectCounters[$definition['Key']]
        }
        foreach ($sourceKind in @($object.SourceKinds)) { $sourceKinds.Add($sourceKind) | Out-Null }
        $eventStrings += [int]$object.EventStringCount
        $userPathMentions += [int]$object.NameUserPathMentions

        foreach ($user in @($object.Users)) {
            $rawUser = [string]$user.RawUser
            if (-not $userAggregate.ContainsKey($rawUser)) {
                $userAggregate[$rawUser] = [pscustomobject]@{
                    RawUser = $rawUser
                    Counters = (New-Counter -Definitions $categoryDefs)
                    PathMentions = 0
                    EventMentions = 0
                }
            }
            $userAggregate[$rawUser].PathMentions += [int]$user.PathMentions
            $userAggregate[$rawUser].EventMentions += [int]$user.EventMentions
            foreach ($definition in $categoryDefs) {
                $userAggregate[$rawUser].Counters[$definition['Key']] += [int]$user.Counters[$definition['Key']]
            }
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
        [pscustomobject]@{
            user_alias = $userAlias
            path_mentions = $user.PathMentions
            event_mentions = $user.EventMentions
            signals = $user.Counters
        }
    }

    $topSignals = @(
        $categoryDefs |
            ForEach-Object { [pscustomobject]@{ key = $_['Key']; label = $_['Label']; count = [int]$aggregate[$_['Key']] } } |
            Sort-Object Count -Descending |
            Where-Object Count -gt 0 |
            Select-Object -First 6
    )

    $machines.Add([pscustomobject]@{
        machine_alias = $machineAlias
        evidence_object_count = @($group.Group).Count
        source_kinds = @($sourceKinds | Select-Object -Unique | Sort-Object)
        event_description_strings = $eventStrings
        user_path_mentions = $userPathMentions
        users_detected = @($users).Count
        signals = $aggregate
        top_signals = $topSignals
        users = @($users)
    }) | Out-Null
}

$usersTotal = (@($machines | ForEach-Object { $_.users_detected }) | Measure-Object -Sum).Sum
if (-not $usersTotal) { $usersTotal = 0 }

$categoryDefinitionOutput = foreach ($definition in $categoryDefs) {
    [pscustomobject]@{
        key = [string]$definition['Key']
        label = [string]$definition['Label']
    }
}
$runStamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$reportPath = Join-Path $reportsDir "usage-pattern-triage-$runStamp.sanitized.md"
$jsonPath = Join-Path $reportsDir "usage-pattern-triage-$runStamp.structured.sanitized.json"
$aliasMapPath = Join-Path $reportsDir "usage-pattern-triage-$runStamp.alias-map.local.json"
$notebookPath = Join-Path $notesDir 'contemporaneous-notes.jsonl'

$manualGate = $null
$actionGate = $null
$bestPractices = $null
if ($moduleAvailable) {
    if ($ManualCachePath) {
        $manualGate = Test-XwfManualGate -Query 'X-Ways case data storage event list case report volume snapshot names metadata' -RequiredTerms @('Event Lists', 'Case Report', 'volume snapshot', 'case report') -ManualCachePath $ManualCachePath
    }
    $manualGatePassed = $false
    if ($manualGate) { $manualGatePassed = [bool]$manualGate.allowed }
    $actionGate = Test-XwfForensicAction -Action 'Read X-Ways case database event/name metadata for local usage-pattern triage' -OutputKind 'QueryOnly' -ManualReference 'X-Ways manual: 5.15 Event Lists; 5.6 Case Report; Administration Tips Case Data Storage table for Events 1/2 and Names; 3.10 command line; 9.3 Notation/Output' -ManualGatePassed:$manualGatePassed
    if ($BestPracticeCatalogPath) {
        $bestPractices = Select-XwfBestPractice -CatalogPath $BestPracticeCatalogPath -Jurisdiction @('international','australia','usa','united_kingdom') -Theme @('analysis','documentation','reproducibility','tool_validation','preservation') -Limit 8 -Reason 'Read-only X-Ways case database triage, no evidence modification, no file-content export.'
    }
}

$manualGateAllowed = $false
if ($manualGate) { $manualGateAllowed = [bool]$manualGate.allowed }
$actionGateAllowed = $false
if ($actionGate) { $actionGateAllowed = [bool]$actionGate.allowed }

$machineOutput = @($machines.ToArray())
$caveatsOutput = @(
    'This is a query-first triage pass over X-Ways case database event/name metadata, not a raw artifact parser report.',
    'Counts represent matched strings/signals, not unique user actions.',
    'Use X-Ways Event List/Directory Browser/Case Report or a documented X-Tension to validate individual findings before evidential reliance.',
    'The sensitive local alias map is intentionally separate from this sanitized report.'
)

$structured = [pscustomobject][ordered]@{
    created_utc = (Get-Date).ToUniversalTime().ToString('o')
    scope = 'Read-only triage over X-Ways case database files. No raw carved files or evidence file contents were exported.'
    status = 'triage_leads_require_validation_in_xways_event_list_or_report'
    manual_gate_allowed = $manualGateAllowed
    action_gate_allowed = $actionGateAllowed
    workers_requested = $ThrottleLimit
    evidence_object_database_dirs = $objectDirs.Count
    machines_detected = $machineOutput.Count
    users_detected_total = $usersTotal
    category_definitions = @($categoryDefinitionOutput)
    machines = $machineOutput
    caveats = $caveatsOutput
}

$structured | ConvertTo-Json -Depth 14 | Set-Content -LiteralPath $jsonPath -Encoding UTF8
$aliasMap | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $aliasMapPath -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# Usage Pattern Triage from X-Ways Case Database') | Out-Null
$lines.Add('') | Out-Null
$lines.Add("Created UTC: $($structured.created_utc)") | Out-Null
$lines.Add('') | Out-Null
$lines.Add('Scope: read-only triage over X-Ways case database event/name metadata. No carved files or evidence file contents were exported.') | Out-Null
$lines.Add('Forensic status: triage leads only until validated in X-Ways Event List, Directory Browser, Case Report, or a documented X-Tension.') | Out-Null
$lines.Add('') | Out-Null
$lines.Add('## Manual And SOP Gate') | Out-Null
$lines.Add('') | Out-Null
$lines.Add("- Manual gate allowed: $($structured.manual_gate_allowed)") | Out-Null
$lines.Add("- Action gate allowed: $($structured.action_gate_allowed)") | Out-Null
$lines.Add('- X-Ways manual references used: 5.15 Event Lists; 5.6 Case Report; Administration Tips Case Data Storage table for Events 1/2 and Names; 3.10 command line; 9.3 Notation/Output.') | Out-Null
$lines.Add('- Best-practice basis: ISO/IEC 27037/27041/27042 plus local AU/US/UK guidance selected from the local catalog for preservation, reproducibility, and documentation.') | Out-Null
$lines.Add('') | Out-Null
$lines.Add('## High-Level Findings') | Out-Null
$lines.Add('') | Out-Null
$lines.Add("- Machine/evidence groups detected: $($structured.machines_detected)") | Out-Null
$lines.Add("- User profiles detected across accessible groups: $($structured.users_detected_total)") | Out-Null
$lines.Add("- X-Ways evidence-object database directories inspected: $($structured.evidence_object_database_dirs)") | Out-Null
$lines.Add("- Parallel workers requested: $ThrottleLimit") | Out-Null
$lines.Add('') | Out-Null

foreach ($machine in $machines) {
    $lines.Add("## $($machine.machine_alias)") | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add("- Evidence-object database directories: $($machine.evidence_object_count)") | Out-Null
    $lines.Add("- Source kinds present: $((@($machine.source_kinds) -join ', '))") | Out-Null
    $lines.Add("- Event-description strings matched: $($machine.event_description_strings)") | Out-Null
    $lines.Add("- User path mentions matched: $($machine.user_path_mentions)") | Out-Null
    $lines.Add("- User profiles detected: $($machine.users_detected)") | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add('Top machine-level signal families:') | Out-Null
    if (@($machine.top_signals).Count -eq 0) {
        $lines.Add('- No categorized signal strings matched in this triage pass.') | Out-Null
    }
    else {
        foreach ($signal in @($machine.top_signals)) {
            $lines.Add("- $($signal.label): $($signal.count)") | Out-Null
        }
    }
    $lines.Add('') | Out-Null
    if (@($machine.users).Count -eq 0) {
        $lines.Add('Detected user profiles and signal families: none from accessible path/event metadata in this pass.') | Out-Null
    }
    else {
        $lines.Add('Detected user profiles and signal families:') | Out-Null
        foreach ($user in @($machine.users)) {
            $topUser = @(
                $categoryDefs |
                    ForEach-Object { [pscustomobject]@{ label = $_['Label']; count = [int]$user.signals[$_['Key']] } } |
                    Sort-Object Count -Descending |
                    Where-Object Count -gt 0 |
                    Select-Object -First 5
            )
            $parts = if ($topUser.Count) {
                ($topUser | ForEach-Object { "$($_.label)=$($_.count)" }) -join '; '
            }
            else {
                'no categorized signal strings'
            }
            $lines.Add("- $($user.user_alias): path mentions=$($user.path_mentions), event mentions=$($user.event_mentions), $parts") | Out-Null
        }
    }
    $lines.Add('') | Out-Null
}

$lines.Add('## Caveats') | Out-Null
$lines.Add('') | Out-Null
foreach ($caveat in $structured.caveats) { $lines.Add("- $caveat") | Out-Null }
$lines.Add('') | Out-Null
$lines.Add('Sensitive raw machine/user labels are stored only in the local alias-map file created next to this report. Do not publish that alias map.') | Out-Null
$lines -join "`r`n" | Set-Content -LiteralPath $reportPath -Encoding UTF8

if ($moduleAvailable) {
    Add-XwfContemporaneousNote `
        -NotebookPath $notebookPath `
        -Category 'analysis' `
        -Action 'Generated read-only usage-pattern triage from X-Ways case database metadata' `
        -Rationale 'Continue the original task while honoring query-first and no ordinary filesystem export rules. The analysis reads X-Ways case database event/name metadata and writes sanitized local findings plus a local-only alias map.' `
        -ManualReference 'X-Ways manual: 5.15 Event Lists; 5.6 Case Report; Administration Tips Case Data Storage table for Events 1/2 and Names; 3.10 command line; 9.3 Notation/Output.' `
        -How "Located the active local X-Ways case database, inspected generic X-Ways Events 2 and Names files read-only using shared-read access, grouped signals by evidence-object base and user profile paths, wrote sanitized report/JSON and a local alias map. Used up to $ThrottleLimit parallel workers." `
        -BestPracticeReferences $(if ($bestPractices) { $bestPractices.selected } else { @() }) `
        -BestPracticeSelectionRationale $(if ($bestPractices) { $bestPractices.selection_rationale } else { 'Best-practice catalog unavailable.' }) `
        -SoundnessCheck @{
            original_evidence_modified = $false
            raw_file_content_exported = $false
            carved_files_exported = $false
            source = 'X-Ways case database metadata/events'
            output = 'sanitized derived report and local alias map'
            manual_gate_allowed = $structured.manual_gate_allowed
            action_gate_allowed = $structured.action_gate_allowed
            validation_required = $true
        } `
        -Result 'Sanitized usage-pattern triage report and local alias map written to the Desktop case reports folder.' | Out-Null
}

[pscustomobject]@{
    ok = $true
    machines_detected = $structured.machines_detected
    users_detected_total = $structured.users_detected_total
    evidence_object_database_dirs = $structured.evidence_object_database_dirs
    workers_requested = $ThrottleLimit
    manual_gate_allowed = $structured.manual_gate_allowed
    action_gate_allowed = $structured.action_gate_allowed
    report_bytes = (Get-Item -LiteralPath $reportPath).Length
    report_hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $reportPath).Hash.Substring(0, 16)
    structured_hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $jsonPath).Hash.Substring(0, 16)
    alias_map_hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $aliasMapPath).Hash.Substring(0, 16)
}

#requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string[]]$JsonlPath,

    [Parameter(Mandatory)]
    [string]$ReportDirectory,

    [string]$RunId = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-XwfStableHash {
    param([AllowNull()][string]$Value)
    if ($null -eq $Value) {
        $Value = ''
    }
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Value)
        (($sha.ComputeHash($bytes) | ForEach-Object { $_.ToString('x2') }) -join '').Substring(0, 16).ToUpperInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

function ConvertFrom-XwfFileTime {
    param([AllowNull()]$Value)
    if ($null -eq $Value) {
        return $null
    }
    try {
        $int = [Int64]$Value
        if ($int -le 0) {
            return $null
        }
        return [DateTime]::FromFileTimeUtc($int)
    }
    catch {
        return $null
    }
}

function Get-XwfPathUserName {
    param([AllowNull()][string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    $patterns = @(
        '(?i)(?:^|[\\/])Users[\\/]([^\\/]+)',
        '(?i)(?:^|[\\/])Documents and Settings[\\/]([^\\/]+)'
    )
    foreach ($pattern in $patterns) {
        $match = [regex]::Match($Path, $pattern)
        if ($match.Success) {
            $name = $match.Groups[1].Value
            if ($name -and $name -notmatch '^(Default|Default User|All Users|Public)$') {
                return $name
            }
        }
    }
    return $null
}

function Get-XwfUsageCategories {
    param(
        [AllowNull()][string]$Path,
        [AllowNull()][string]$Name,
        [AllowNull()]$Deletion,
        [AllowNull()]$Classification
    )

    $p = if ($Path) { $Path.ToLowerInvariant() } else { '' }
    $n = if ($Name) { $Name.ToLowerInvariant() } else { '' }
    $categories = [System.Collections.Generic.List[string]]::new()

    if ($p -match '[\\/]windows[\\/]system32[\\/]config[\\/]' -or $n -in @('system', 'software', 'sam', 'security')) {
        $categories.Add('registry/system config')
    }
    if ($n -in @('ntuser.dat', 'usrclass.dat') -or $p -match '[\\/]appdata[\\/]local[\\/]microsoft[\\/]windows[\\/]usrclass\.dat$') {
        $categories.Add('user registry hives')
    }
    if ($p -match '[\\/]windows[\\/]prefetch[\\/]' -or $p -match '[\\/]windows[\\/]appcompat[\\/]programs[\\/]' -or $n -in @('amcache.hve', 'recentfilecache.bcf')) {
        $categories.Add('program execution/application traces')
    }
    if ($p -match '[\\/]recent[\\/]' -or $p -match '[\\/]automaticdestinations[\\/]' -or $p -match '[\\/]customdestinations[\\/]' -or $n -like '*.lnk') {
        $categories.Add('file/shell/document interaction')
    }
    if ($p -match '[\\/]users[\\/][^\\/]+[\\/](desktop|documents|downloads|pictures|videos)[\\/]' -or
        $p -match '[\\/]documents and settings[\\/][^\\/]+[\\/](desktop|my documents|documents)[\\/]') {
        $categories.Add('user file-area activity')
    }
    if ($p -match '[\\/]appdata[\\/].*(chrome|edge|firefox|mozilla|webcache)' -or
        $n -in @('history', 'places.sqlite', 'cookies.sqlite', 'downloads.sqlite', 'webcachev01.dat')) {
        $categories.Add('browser/web activity')
    }
    if ($p -match '[\\/]windows[\\/]system32[\\/]winevt[\\/]logs[\\/]' -or $n -like '*.evtx' -or
        $p -match '(terminalservices|remoteconnectionmanager|rdp|user profile service)') {
        $categories.Add('logon/auth/remote access')
    }
    if ($p -match '(teams|slack|zoom|discord|skype|thunderbird|outlook)' -or $n -like '*.ost' -or $n -like '*.pst') {
        $categories.Add('communications/collaboration')
    }
    if ($p -match '(onedrive|dropbox|google drive|icloud)') {
        $categories.Add('cloud sync/storage')
    }
    if ($p -match '[\\/]`$recycle\.bin[\\/]' -or $p -match '[\\/]\$recycle\.bin[\\/]') {
        $categories.Add('deletion/recycle-bin activity')
    }
    if (($null -ne $Deletion -and [int64]$Deletion -gt 0) -or $p -match '(recovered|carved|free space)' -or
        ($null -ne $Classification -and [int64]$Classification -eq 5)) {
        $categories.Add('carved/deleted/recovered-origin indicators')
    }

    if ($categories.Count -eq 0) {
        $categories.Add('other usage-relevant metadata')
    }

    return @($categories | Sort-Object -Unique)
}

function Add-XwfCount {
    param(
        [hashtable]$Table,
        [string]$Key,
        [int]$Count = 1
    )
    if (-not $Table.ContainsKey($Key)) {
        $Table[$Key] = 0
    }
    $Table[$Key] += $Count
}

function Update-XwfTimeBounds {
    param(
        [hashtable]$Target,
        [AllowNull()][object[]]$Times
    )
    foreach ($time in @($Times | Where-Object { $_ })) {
        if (-not $Target.ContainsKey('first_seen_utc') -or -not $Target.first_seen_utc -or $time -lt $Target.first_seen_utc) {
            $Target.first_seen_utc = $time
        }
        if (-not $Target.ContainsKey('last_seen_utc') -or -not $Target.last_seen_utc -or $time -gt $Target.last_seen_utc) {
            $Target.last_seen_utc = $time
        }
    }
}

New-Item -ItemType Directory -Path $ReportDirectory -Force | Out-Null

$resolvedInputs = @(foreach ($path in $JsonlPath) {
    $resolved = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
    if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
        throw "JSONL path not found: $resolved"
    }
    $resolved
})

$machineAliases = @{}
$machineRaw = @{}
$userAliases = @{}
$userRaw = @{}
$machines = @{}
$recordCount = 0

foreach ($inputPath in $resolvedInputs) {
    $reader = [System.IO.File]::OpenText($inputPath)
    try {
        while (-not $reader.EndOfStream) {
            $line = $reader.ReadLine()
            if ([string]::IsNullOrWhiteSpace($line)) {
                continue
            }

            try {
                $record = $line | ConvertFrom-Json
            }
            catch {
                continue
            }

            if ($record.PSObject.Properties.Name -contains 'schema' -and $record.schema -ne 'xwf-path-export-v1') {
                continue
            }

            $recordCount++
            $rawMachineKey = '{0}|{1}|{2}' -f $record.evidence_object_id, $record.evidence_internal_designation, $record.evidence_extended_title
            $machineKey = Get-XwfStableHash $rawMachineKey
            if (-not $machineAliases.ContainsKey($machineKey)) {
                $machineAliases[$machineKey] = 'M{0:D3}' -f ($machineAliases.Count + 1)
                $machineRaw[$machineAliases[$machineKey]] = [ordered]@{
                    key_hash = $machineKey
                    evidence_object_id = $record.evidence_object_id
                    evidence_title = $record.evidence_title
                    evidence_extended_title = $record.evidence_extended_title
                    evidence_internal_designation = $record.evidence_internal_designation
                }
            }
            $machineAlias = $machineAliases[$machineKey]

            if (-not $machines.ContainsKey($machineAlias)) {
                $machines[$machineAlias] = @{
                    alias = $machineAlias
                    key_hash = $machineKey
                    record_count = 0
                    evidence_object_hashes = @{}
                    volume_item_count_max = 0
                    category_counts = @{}
                    users = @{}
                    first_seen_utc = $null
                    last_seen_utc = $null
                }
            }

            $machine = $machines[$machineAlias]
            $machine.record_count++
            $evHash = Get-XwfStableHash ('{0}|{1}|{2}' -f $record.evidence_object_id, $record.evidence_extended_title, $record.evidence_internal_designation)
            $machine.evidence_object_hashes[$evHash] = $true
            if ($record.volume_item_count -and [int64]$record.volume_item_count -gt [int64]$machine.volume_item_count_max) {
                $machine.volume_item_count_max = [int64]$record.volume_item_count
            }

            $categories = Get-XwfUsageCategories -Path $record.path -Name $record.name -Deletion $record.deletion -Classification $record.classification
            foreach ($category in $categories) {
                Add-XwfCount -Table $machine.category_counts -Key $category
            }

            $times = @(
                ConvertFrom-XwfFileTime $record.creation_filetime
                ConvertFrom-XwfFileTime $record.modification_filetime
                ConvertFrom-XwfFileTime $record.last_access_filetime
                ConvertFrom-XwfFileTime $record.entry_modification_filetime
                ConvertFrom-XwfFileTime $record.deletion_filetime
                ConvertFrom-XwfFileTime $record.internal_creation_filetime
            )
            Update-XwfTimeBounds -Target $machine -Times $times

            $rawUserName = Get-XwfPathUserName -Path $record.path
            if ($rawUserName) {
                $userKey = '{0}|{1}' -f $machineAlias, (Get-XwfStableHash $rawUserName)
                if (-not $userAliases.ContainsKey($userKey)) {
                    $userAliases[$userKey] = 'U{0:D3}' -f ($machine.users.Count + 1)
                    $userRaw["$machineAlias/$($userAliases[$userKey])"] = [ordered]@{
                        machine_alias = $machineAlias
                        user_alias = $userAliases[$userKey]
                        user_name = $rawUserName
                    }
                }
                $userAlias = $userAliases[$userKey]
                if (-not $machine.users.ContainsKey($userAlias)) {
                    $machine.users[$userAlias] = @{
                        alias = $userAlias
                        record_count = 0
                        category_counts = @{}
                        first_seen_utc = $null
                        last_seen_utc = $null
                    }
                }
                $user = $machine.users[$userAlias]
                $user.record_count++
                foreach ($category in $categories) {
                    Add-XwfCount -Table $user.category_counts -Key $category
                }
                Update-XwfTimeBounds -Target $user -Times $times
            }
        }
    }
    finally {
        $reader.Dispose()
    }
}

$machineResults = @(foreach ($machineAlias in ($machines.Keys | Sort-Object)) {
    $machine = $machines[$machineAlias]
    $userResults = @(foreach ($userAlias in ($machine.users.Keys | Sort-Object)) {
        $user = $machine.users[$userAlias]
        [ordered]@{
            alias = $user.alias
            record_count = $user.record_count
            first_seen_utc = if ($user.first_seen_utc) { $user.first_seen_utc.ToString('o') } else { $null }
            last_seen_utc = if ($user.last_seen_utc) { $user.last_seen_utc.ToString('o') } else { $null }
            signal_families = @($user.category_counts.GetEnumerator() | Sort-Object -Property Value -Descending | ForEach-Object {
                [ordered]@{ name = $_.Key; count = $_.Value }
            })
        }
    })

    [ordered]@{
        alias = $machine.alias
        key_hash = $machine.key_hash
        record_count = $machine.record_count
        evidence_object_count = $machine.evidence_object_hashes.Count
        volume_item_count_max = $machine.volume_item_count_max
        first_seen_utc = if ($machine.first_seen_utc) { $machine.first_seen_utc.ToString('o') } else { $null }
        last_seen_utc = if ($machine.last_seen_utc) { $machine.last_seen_utc.ToString('o') } else { $null }
        signal_families = @($machine.category_counts.GetEnumerator() | Sort-Object -Property Value -Descending | ForEach-Object {
            [ordered]@{ name = $_.Key; count = $_.Value }
        })
        users = @($userResults)
    }
})

$structured = [ordered]@{
    schema = 'xwf-usage-pattern-triage-v1'
    generated_utc = (Get-Date).ToUniversalTime().ToString('o')
    run_id = $RunId
    source = [ordered]@{
        input_count = $resolvedInputs.Count
        input_hashes = @($resolvedInputs | ForEach-Object { Get-XwfStableHash $_ })
        raw_record_count = $recordCount
    }
    soundness = [ordered]@{
        file_content_exported = $false
        source_action = 'X-Ways metadata-only X-Tension path export'
        raw_sensitive_output_kept_local = $true
        sanitized_report_contains_raw_paths_or_usernames = $false
    }
    manual_and_api_basis = @(
        'X-Ways manual/API checked before action',
        'XT/XTParam command-line route preferred over UI automation',
        'XWF_GetItemName + XWF_GetItemParent documented path reconstruction',
        'XWF_OpenEvObj read-only/no-underlying-disk flags used for existing volume snapshots',
        'XWF_GetItemInformation metadata retrieval only; XWF_Read not used'
    )
    machines = @($machineResults)
}

$reportPath = Join-Path $ReportDirectory "usage-patterns-sanitized-$RunId.md"
$jsonPath = Join-Path $ReportDirectory "usage-patterns-structured-sanitized-$RunId.json"
$aliasPath = Join-Path $ReportDirectory "usage-patterns-alias-map.local-$RunId.json"

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add('# Sanitized Usage Pattern Triage')
$lines.Add('')
$lines.Add("Generated UTC: $($structured.generated_utc)")
$lines.Add("Raw X-Ways metadata records reviewed: $recordCount")
$lines.Add('')
$lines.Add('Forensic soundness: metadata-only X-Ways query output was used. No file contents were exported, and the raw path/user alias map is kept in a local sensitive file.')
$lines.Add('')
$lines.Add('Manual/API basis: X-Ways command-line XT/XTParam, X-Tension lifecycle functions, evidence object enumeration, documented path reconstruction, and metadata-only item information APIs.')
$lines.Add('')

foreach ($machine in $machineResults) {
    $lines.Add("## $($machine.alias)")
    $lines.Add('')
    $lines.Add("- Evidence objects represented: $($machine.evidence_object_count)")
    $lines.Add("- Usage-relevant metadata records: $($machine.record_count)")
    $lines.Add("- Accessible user profiles mapped: $($machine.users.Count)")
    if ($machine.first_seen_utc -or $machine.last_seen_utc) {
        $lines.Add("- Metadata timestamp coverage: $($machine.first_seen_utc) to $($machine.last_seen_utc)")
    }
    $families = @($machine.signal_families | Select-Object -First 8 | ForEach-Object { "$($_.name) ($($_.count))" })
    if ($families.Count -gt 0) {
        $lines.Add("- Machine-level signal families: $($families -join '; ')")
    }
    $lines.Add('')

    foreach ($user in $machine.users) {
        $lines.Add("### $($machine.alias)/$($user.alias)")
        $lines.Add('')
        $lines.Add("- Usage-relevant metadata records: $($user.record_count)")
        if ($user.first_seen_utc -or $user.last_seen_utc) {
            $lines.Add("- Metadata timestamp coverage: $($user.first_seen_utc) to $($user.last_seen_utc)")
        }
        $userFamilies = @($user.signal_families | Select-Object -First 8 | ForEach-Object { "$($_.name) ($($_.count))" })
        if ($userFamilies.Count -gt 0) {
            $lines.Add("- User signal families: $($userFamilies -join '; ')")
        }
        $lines.Add('')
    }
}

$lines | Set-Content -LiteralPath $reportPath -Encoding UTF8
$structured | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding UTF8
[ordered]@{
    schema = 'xwf-usage-pattern-alias-map-local-v1'
    generated_utc = $structured.generated_utc
    machines = $machineRaw
    users = $userRaw
} | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $aliasPath -Encoding UTF8

[pscustomobject]@{
    ReportPath = $reportPath
    StructuredJsonPath = $jsonPath
    AliasMapPath = $aliasPath
    MachineCount = $machineResults.Count
    UserProfileCount = @($machineResults | ForEach-Object { $_.users } | Where-Object { $_ }).Count
    RawRecordCount = $recordCount
}

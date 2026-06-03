function Get-XwfApiCatalogPathInternal {
    $repoRoot = Resolve-XwfRepoRoot
    return (Join-Path $repoRoot 'data\xwf-external-surface\xwf-21.8-exported-api-cmdlets.csv')
}

function ConvertFrom-XwfCsvBoolInternal {
    param(
        [AllowNull()]
        [object]$Value
    )

    if ($null -eq $Value) {
        return $false
    }

    return ([string]$Value).ToLowerInvariant() -in @('true', '1', 'yes')
}

function Import-XwfApiCatalogInternal {
    $catalogPath = Get-XwfApiCatalogPathInternal
    if (-not (Test-Path -LiteralPath $catalogPath -PathType Leaf)) {
        throw "XWF API cmdlet catalog not found: $catalogPath"
    }

    Import-Csv -LiteralPath $catalogPath | ForEach-Object {
        [pscustomobject]@{
            api_name = [string]$_.api_name
            cmdlet_name = [string]$_.cmdlet_name
            ordinal = [int]$_.ordinal
            rva = [string]$_.rva
            return_type = [string]$_.return_type
            signature = [string]$_.signature
            parameter_names = @(([string]$_.parameter_names) -split ';' | Where-Object { $_ })
            parameter_types = @(([string]$_.parameter_types) -split ';' | Where-Object { $_ })
            risk_level = [string]$_.risk_level
            mutates_case = ConvertFrom-XwfCsvBoolInternal $_.mutates_case
            reads_content = ConvertFrom-XwfCsvBoolInternal $_.reads_content
            requires_in_process_bridge = ConvertFrom-XwfCsvBoolInternal $_.requires_in_process_bridge
            docs_summary = [string]$_.docs_summary
        }
    }
}

function Get-XwfApiCatalog {
    <#
    .SYNOPSIS
    Returns the exported XWF API cmdlet catalog.

    .DESCRIPTION
    Loads the committed catalog that maps the 77 verified XWF 21.8 x64 exports
    to agent-facing PowerShell cmdlets. Each entry records the original API
    name, generated cmdlet name, ordinal, RVA, official signature text where it
    was available, parameter names, risk flags, and a short documentation
    summary.

    These entries are for X-Tension bridge planning and request generation.
    They do not imply that a normal PowerShell process can call XWF_* functions
    directly.

    .PARAMETER ApiName
    Optional XWF_* API name to filter.

    .PARAMETER CmdletName
    Optional generated PowerShell cmdlet name to filter.

    .PARAMETER Mutating
    Return only entries marked as mutating or state-changing.

    .PARAMETER ReadOnly
    Return only entries not marked as mutating or content-reading.

    .EXAMPLE
    Get-XwfApiCatalog -ApiName XWF_GetItemName
    #>
    [CmdletBinding()]
    param(
        [string]$ApiName = '',

        [string]$CmdletName = '',

        [switch]$Mutating,

        [switch]$ReadOnly
    )

    $catalog = @(Import-XwfApiCatalogInternal)

    if ($ApiName) {
        $catalog = @($catalog | Where-Object { $_.api_name -ieq $ApiName })
    }
    if ($CmdletName) {
        $catalog = @($catalog | Where-Object { $_.cmdlet_name -ieq $CmdletName })
    }
    if ($Mutating) {
        $catalog = @($catalog | Where-Object { $_.mutates_case })
    }
    if ($ReadOnly) {
        $catalog = @($catalog | Where-Object { -not $_.mutates_case -and -not $_.reads_content })
    }

    return $catalog
}

function Test-XwfApiInvocation {
    <#
    .SYNOPSIS
    Validates an agent-facing XWF API bridge invocation.

    .DESCRIPTION
    Checks that the requested XWF_* function exists in the verified export
    catalog, reports whether it is mutating or content-reading, and compares
    supplied hashtable keys with the parameter names extracted from the official
    API signature. Unknown argument keys are warnings because some bridge
    implementations may accept helper fields, but mutating and content-reading
    calls are blocked unless explicitly allowed.

    .PARAMETER ApiName
    XWF_* function name to validate.

    .PARAMETER Argument
    Hashtable of argument names and values intended for the X-Tension bridge.

    .PARAMETER AllowMutating
    Marks a mutating/state-changing request as intentionally allowed.

    .PARAMETER AllowContentAccess
    Marks content-reading requests such as XWF_Read as intentionally allowed.

    .EXAMPLE
    Test-XwfApiInvocation -ApiName XWF_GetItemName -Argument @{ nItemID = 42 }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ApiName,

        [hashtable]$Argument = @{},

        [switch]$AllowMutating,

        [switch]$AllowContentAccess
    )

    $issues = New-Object System.Collections.Generic.List[string]
    $warnings = New-Object System.Collections.Generic.List[string]
    $entry = Get-XwfApiCatalog -ApiName $ApiName | Select-Object -First 1

    if (-not $entry) {
        $issues.Add("API is not present in the verified XWF export catalog: $ApiName")
        return [pscustomobject]@{
            allowed = $false
            api_name = $ApiName
            cmdlet_name = ''
            issues = @($issues)
            warnings = @($warnings)
            catalog_entry = $null
        }
    }

    if ($entry.mutates_case -and -not $AllowMutating) {
        $issues.Add('API is marked mutating or state-changing. Pass -AllowMutating only after recording the manual/API basis and forensic boundary.')
    }

    if ($entry.reads_content -and -not $AllowContentAccess) {
        $issues.Add('API can read file, item, sector, or raw content. Pass -AllowContentAccess only for an approved container-first or metadata-safe bridge route.')
    }

    $knownParameters = @($entry.parameter_names)
    if ($knownParameters.Count -gt 0 -and $Argument) {
        foreach ($key in @($Argument.Keys)) {
            if ($knownParameters -notcontains $key) {
                $warnings.Add("Argument key is not in the documented signature: $key")
            }
        }
    }

    return [pscustomobject]@{
        allowed = ($issues.Count -eq 0)
        api_name = $entry.api_name
        cmdlet_name = $entry.cmdlet_name
        risk_level = $entry.risk_level
        mutates_case = $entry.mutates_case
        reads_content = $entry.reads_content
        documented_parameters = $knownParameters
        issues = @($issues)
        warnings = @($warnings)
        catalog_entry = $entry
    }
}

function Invoke-XwfApiFunction {
    <#
    .SYNOPSIS
    Creates or queues a validated XWF API bridge request.

    .DESCRIPTION
    Builds a typed JSON-serializable request for an in-process X-Tension bridge
    to execute an exported XWF_* API function. This cmdlet validates the API
    name against the verified export catalog and records the original API name,
    generated cmdlet, ordinal, RVA, signature, risk flags, purpose, case id, and
    supplied arguments.

    It does not load the X-Ways executable or call native functions from the
    PowerShell process. XWF_* APIs are meant to run inside X-Ways through an
    X-Tension. If -OutboxPath is supplied, one JSON line is appended for a local
    bridge runner to consume.

    .PARAMETER ApiName
    XWF_* API function name.

    .PARAMETER Argument
    Hashtable of arguments for the bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Allows APIs marked mutating or state-changing.

    .PARAMETER AllowContentAccess
    Allows APIs marked as content-reading.

    .PARAMETER PassThru
    Return the request object after writing it to -OutboxPath.

    .EXAMPLE
    Invoke-XwfApiFunction -ApiName XWF_GetItemName -Argument @{ nItemID = 42 }
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$ApiName,

        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    $validation = Test-XwfApiInvocation -ApiName $ApiName -Argument $Argument -AllowMutating:$AllowMutating -AllowContentAccess:$AllowContentAccess
    if (-not $validation.allowed) {
        throw (($validation.issues) -join '; ')
    }

    $entry = $validation.catalog_entry
    $request = [ordered]@{
        schema = 'xwf-api-bridge-request/v1'
        request_id = $RequestId
        created_utc = (Get-Date).ToUniversalTime().ToString('o')
        route = 'x-tension-in-process-only'
        api_name = $entry.api_name
        cmdlet_name = $entry.cmdlet_name
        ordinal = $entry.ordinal
        rva = $entry.rva
        signature = $entry.signature
        risk_level = $entry.risk_level
        mutates_case = $entry.mutates_case
        reads_content = $entry.reads_content
        case_id = $CaseId
        purpose = $Purpose
        arguments = $Argument
        validation = [ordered]@{
            warnings = @($validation.warnings)
            documented_parameters = @($validation.documented_parameters)
        }
        execution_policy = @(
            'Do not call XWF_* exports from an ordinary PowerShell process.',
            'Execute only inside X-Ways through a documented X-Tension bridge.',
            'Record manual/API basis, case/run id, input source, output path, and hash/provenance in contemporaneous notes.',
            'For content-reading calls, use an approved query-first or container-first route.'
        )
    }

    if ($OutboxPath) {
        $resolvedOutbox = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutboxPath)
        $outboxParent = Split-Path -Parent $resolvedOutbox
        if ($outboxParent -and -not (Test-Path -LiteralPath $outboxParent)) {
            New-Item -ItemType Directory -Path $outboxParent -Force | Out-Null
        }

        if ($PSCmdlet.ShouldProcess($resolvedOutbox, "Append XWF API bridge request $ApiName")) {
            $request | ConvertTo-Json -Depth 20 -Compress | Add-Content -LiteralPath $resolvedOutbox -Encoding UTF8
        }

        if ($PassThru) {
            return [pscustomobject]$request
        }
        return
    }

    return [pscustomobject]$request
}

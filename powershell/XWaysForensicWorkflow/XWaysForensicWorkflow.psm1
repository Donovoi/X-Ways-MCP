Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot 'XwfExternalSurface.ps1')
. (Join-Path $PSScriptRoot 'XwfApiBridge.ps1')
. (Join-Path $PSScriptRoot 'XwfExportedApiCmdlets.ps1')

function ConvertTo-XwfSafeName {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $safe = $Name -replace '[<>:"/\\|?*\x00-\x1F]', '_'
    $safe = $safe.Trim()
    if ([string]::IsNullOrWhiteSpace($safe)) {
        return 'xwf-run'
    }
    return $safe
}

function Resolve-XwfManualTextPath {
    param(
        [string]$ManualCachePath = ''
    )

    $candidates = @()
    if ($ManualCachePath) {
        $resolved = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ManualCachePath)
        if (Test-Path -LiteralPath $resolved -PathType Leaf) {
            $candidates += $resolved
        }
        else {
            $candidates += (Join-Path $resolved 'xways-manual.txt')
        }
    }

    if ($PSScriptRoot) {
        $moduleRepoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..') -ErrorAction SilentlyContinue
        if ($moduleRepoRoot) {
            $candidates += (Join-Path $moduleRepoRoot.Path 'tooling\cache\xways-manual\xways-manual.txt')
        }
    }

    $repoCache = Join-Path (Get-Location) 'tooling\cache\xways-manual\xways-manual.txt'
    $candidates += $repoCache

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    return $null
}

function Resolve-XwfRepoRoot {
    if ($PSScriptRoot) {
        $moduleRepoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..') -ErrorAction SilentlyContinue
        if ($moduleRepoRoot) {
            return $moduleRepoRoot.Path
        }
    }

    $gitRoot = git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -eq 0 -and $gitRoot) {
        return ($gitRoot | Select-Object -First 1)
    }

    return (Get-Location).Path
}

function Resolve-XwfBestPracticeCatalogPath {
    param(
        [string]$CatalogPath = ''
    )

    if ($CatalogPath) {
        return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($CatalogPath)
    }

    $repoRoot = Resolve-XwfRepoRoot
    return (Join-Path $repoRoot 'data\forensic-best-practices.json')
}

function Get-XwfBestPracticeCatalog {
    [CmdletBinding()]
    param(
        [string]$CatalogPath = ''
    )

    $resolvedPath = Resolve-XwfBestPracticeCatalogPath -CatalogPath $CatalogPath
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "Best-practice catalog not found: $resolvedPath"
    }

    $catalog = Get-Content -LiteralPath $resolvedPath -Raw -Encoding UTF8 | ConvertFrom-Json
    return $catalog
}

function Select-XwfBestPractice {
    [CmdletBinding()]
    param(
        [string[]]$Jurisdiction = @('international', 'usa', 'united_kingdom', 'europe', 'australia'),

        [string[]]$Theme = @(),

        [int]$Limit = 8,

        [string]$CatalogPath = '',

        [string]$Reason = 'Select current public forensic guidance applicable to the planned action.'
    )

    $catalog = Get-XwfBestPracticeCatalog -CatalogPath $CatalogPath
    $jurisdictionSet = @{}
    foreach ($item in $Jurisdiction) {
        if ($item) {
            $jurisdictionSet[$item.ToLowerInvariant()] = $true
        }
    }
    $themeSet = @{}
    foreach ($item in $Theme) {
        if ($item) {
            $themeSet[$item.ToLowerInvariant()] = $true
        }
    }

    $scored = @()
    foreach ($entry in @($catalog.sources)) {
        $score = 0
        $entryJurisdiction = [string]$entry.jurisdiction
        if ($jurisdictionSet.ContainsKey($entryJurisdiction.ToLowerInvariant())) {
            $score += 10
        }
        if ($entryJurisdiction -eq 'international') {
            $score += 2
        }
        foreach ($theme in @($entry.themes)) {
            if ($themeSet.ContainsKey(([string]$theme).ToLowerInvariant())) {
                $score += 4
            }
        }
        if ($Theme.Count -eq 0) {
            $score += 1
        }
        if ($score -gt 0) {
            $scored += [pscustomobject]@{
                score = $score
                entry = $entry
            }
        }
    }

    $selected = $scored |
        Sort-Object -Property @{ Expression = 'score'; Descending = $true }, @{ Expression = { $_.entry.priority }; Descending = $false } |
        Select-Object -First ([Math]::Max(1, $Limit)) |
        ForEach-Object {
            $entry = $_.entry
            [pscustomobject]@{
                id = $entry.id
                jurisdiction = $entry.jurisdiction
                source_name = $entry.source_name
                publisher = $entry.publisher
                url = $entry.url
                source_date = $entry.source_date
                status = $entry.status
                themes = @($entry.themes)
                why_selected = $entry.why_choose
                applicable_when = $entry.applicable_when
            }
        }

    return [pscustomobject]@{
        selected_at_utc = (Get-Date).ToUniversalTime().ToString('o')
        catalog_checked_utc = $catalog.last_reviewed_utc
        reason = $Reason
        jurisdictions_requested = $Jurisdiction
        themes_requested = $Theme
        selection_rationale = 'Selected current public guidance by jurisdiction and action theme. International ISO guidance is used as the baseline; local jurisdiction guidance is added where it is relevant to evidence handling, documentation, quality, or admissibility.'
        selected = @($selected)
    }
}

function New-XwfForensicRun {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$CaseRoot,

        [string]$RunName = 'forensic-run',

        [string]$Operator = $env:USERNAME,

        [string]$ManualCachePath = '',

        [switch]$Force
    )

    $resolvedRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($CaseRoot)
    $safeRunName = ConvertTo-XwfSafeName $RunName
    $runRoot = Join-Path $resolvedRoot $safeRunName
    $folders = [ordered]@{
        RunRoot = $runRoot
        Notes = Join-Path $runRoot 'notes'
        Plans = Join-Path $runRoot 'plans'
        Containers = Join-Path $runRoot 'containers'
        Derived = Join-Path $runRoot 'derived-from-containers'
        Reports = Join-Path $runRoot 'reports'
    }

    if ((Test-Path -LiteralPath $runRoot) -and -not $Force) {
        throw "Run root already exists. Use -Force to reuse it."
    }

    if ($PSCmdlet.ShouldProcess($runRoot, 'Create forensic run workspace')) {
        foreach ($path in $folders.Values) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
        }
    }

    $manualTextPath = Resolve-XwfManualTextPath -ManualCachePath $ManualCachePath
    $notebookJsonl = Join-Path $folders.Notes 'contemporaneous-notes.jsonl'
    $notebookMd = Join-Path $folders.Notes 'contemporaneous-notes.md'

    if (-not (Test-Path -LiteralPath $notebookMd)) {
        "# Contemporaneous Notes`r`n" | Set-Content -LiteralPath $notebookMd -Encoding UTF8
    }

    $run = [pscustomobject]@{
        created_utc = (Get-Date).ToUniversalTime().ToString('o')
        operator = $Operator
        case_root = $resolvedRoot
        run_root = $runRoot
        folders = $folders
        notebook_jsonl = $notebookJsonl
        notebook_markdown = $notebookMd
        manual_text_path = $manualTextPath
        safety_policy = @(
            'Manual gate before action',
            'No original evidence modification',
            'Query X-Ways first before materializing file contents',
            'No file-content export outside an X-Ways evidence file container',
            'Contemporaneous notes for every decision and action',
            'Derived analysis reads from X-Ways query output, containers, or container-derived copies only'
        )
    }

    $run | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $runRoot 'run-manifest.json') -Encoding UTF8

    $bestPractices = Select-XwfBestPractice -Theme @('documentation', 'chain_of_custody', 'preservation') -Reason 'Initialize forensic run notes and evidence-handling boundaries.'

    Add-XwfContemporaneousNote `
        -NotebookPath $notebookJsonl `
        -Category 'run' `
        -Action 'Initialized forensic run workspace' `
        -How 'Created a dedicated local run workspace, manifest, notes, plans, containers, derived-output, and reports folders.' `
        -Rationale 'Create a reusable, container-first workflow boundary before any export or analysis.' `
        -ManualReference 'Manual gate required before X-Ways actions; specific action references are recorded per plan.' `
        -BestPracticeReferences $bestPractices.selected `
        -BestPracticeSelectionRationale $bestPractices.selection_rationale `
        -SoundnessCheck @{ original_evidence_modified = $false; file_content_exported = $false; container_required = $false } `
        -Result 'Workspace and notebook initialized.' | Out-Null

    return $run
}

function Add-XwfContemporaneousNote {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$NotebookPath,

        [Parameter(Mandatory)]
        [string]$Category,

        [Parameter(Mandatory)]
        [string]$Action,

        [string]$Who = '',

        [string]$What = '',

        [string]$When = '',

        [string]$How = '',

        [string]$Rationale = '',

        [string]$ManualReference = '',

        [object[]]$SopReferences = @(),

        [object[]]$BestPracticeReferences = @(),

        [string]$BestPracticeSelectionRationale = '',

        [hashtable]$SoundnessCheck = @{},

        [string]$Result = '',

        [string]$Operator = $env:USERNAME
    )

    $resolvedNotebook = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($NotebookPath)
    $noteDir = Split-Path -Parent $resolvedNotebook
    if ($noteDir -and -not (Test-Path -LiteralPath $noteDir)) {
        New-Item -ItemType Directory -Path $noteDir -Force | Out-Null
    }

    $timestampUtc = (Get-Date).ToUniversalTime().ToString('o')
    if (-not $Who) { $Who = $Operator }
    if (-not $What) { $What = $Action }
    if (-not $When) { $When = $timestampUtc }
    if (-not $Rationale) { $Rationale = 'Not recorded.' }
    if (-not $How) { $How = 'Not recorded.' }

    $entry = [ordered]@{
        timestamp_utc = $timestampUtc
        who = $Who
        what = $What
        when = $When
        why = $Rationale
        how = $How
        operator = $Operator
        category = $Category
        action = $Action
        rationale = $Rationale
        manual_reference = $ManualReference
        sop_references = @($SopReferences)
        best_practice_references = @($BestPracticeReferences)
        best_practice_selection_rationale = $BestPracticeSelectionRationale
        forensic_soundness = $SoundnessCheck
        result = $Result
    }

    ($entry | ConvertTo-Json -Depth 12 -Compress) + "`n" | Add-Content -LiteralPath $resolvedNotebook -Encoding UTF8

    $markdownPath = [System.IO.Path]::ChangeExtension($resolvedNotebook, '.md')
    if (-not (Test-Path -LiteralPath $markdownPath)) {
        "# Contemporaneous Notes`r`n" | Set-Content -LiteralPath $markdownPath -Encoding UTF8
    }

    $soundnessJson = $SoundnessCheck | ConvertTo-Json -Depth 12 -Compress
    $sopJson = @($SopReferences) | ConvertTo-Json -Depth 8 -Compress
    $bestPracticeJson = @($BestPracticeReferences) | ConvertTo-Json -Depth 8 -Compress
    $block = @(
        ''
        "## $($entry.timestamp_utc) - $Category"
        ''
        "- Who: $Who"
        "- What: $What"
        "- When: $When"
        "- Why: $Rationale"
        "- How: $How"
        "- Operator: $Operator"
        "- Action: $Action"
        "- Manual reference: $ManualReference"
        "- SOP references: $sopJson"
        "- Best-practice references: $bestPracticeJson"
        "- Best-practice selection rationale: $BestPracticeSelectionRationale"
        "- Soundness check: $soundnessJson"
        "- Result: $Result"
    ) -join "`r`n"
    $block | Add-Content -LiteralPath $markdownPath -Encoding UTF8

    return [pscustomobject]$entry
}

function Test-XwfManualGate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Query,

        [string[]]$RequiredTerms = @(),

        [string]$ManualCachePath = ''
    )

    $manualTextPath = Resolve-XwfManualTextPath -ManualCachePath $ManualCachePath
    $issues = New-Object System.Collections.Generic.List[string]
    $matches = @()

    if (-not $manualTextPath) {
        $issues.Add('Local X-Ways manual text cache was not found.')
        return [pscustomobject]@{
            allowed = $false
            query = $Query
            manual_text_path = $null
            issues = @($issues)
            matches = @()
        }
    }

    $terms = @($RequiredTerms)
    if ($terms.Count -eq 0) {
        $terms = @($Query -split '\s+' | Where-Object { $_.Length -ge 4 } | Select-Object -First 6)
    }

    foreach ($term in $terms) {
        $termMatches = Select-String -LiteralPath $manualTextPath -SimpleMatch -Pattern $term -Context 1,1 -ErrorAction SilentlyContinue |
            Select-Object -First 5 |
            ForEach-Object {
                [pscustomobject]@{
                    term = $term
                    line = $_.LineNumber
                    text = ($_.Line.Trim() -replace '\s+', ' ')
                }
            }
        if (-not $termMatches) {
            $issues.Add("Manual term was not found: $term")
        }
        $matches += $termMatches
    }

    return [pscustomobject]@{
        allowed = ($issues.Count -eq 0)
        query = $Query
        manual_text_path = $manualTextPath
        issues = @($issues)
        matches = @($matches)
    }
}

function Test-XwfForensicAction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Action,

        [ValidateSet('NotesOnly', 'QueryOnly', 'MetadataOnly', 'Container', 'FileContent', 'DerivedFromContainer')]
        [string]$OutputKind = 'NotesOnly',

        [string]$ManualReference = '',

        [string]$SourcePath = '',

        [string]$DestinationPath = '',

        [string]$ContainerPath = '',

        [switch]$ChangesOriginalEvidence,

        [switch]$UsesUiFallback,

        [switch]$ManualGatePassed
    )

    $issues = New-Object System.Collections.Generic.List[string]
    $warnings = New-Object System.Collections.Generic.List[string]
    $required = New-Object System.Collections.Generic.List[string]

    if ([string]::IsNullOrWhiteSpace($ManualReference) -or -not $ManualGatePassed) {
        $issues.Add('Manual gate has not been recorded for this action.')
        $required.Add('Search the local/current manual cache and record line/page references.')
    }

    if ($ChangesOriginalEvidence) {
        $issues.Add('Action is marked as changing original evidence.')
        $required.Add('Redesign the action so original evidence is opened/read only.')
    }

    if ($OutputKind -eq 'FileContent' -and [string]::IsNullOrWhiteSpace($ContainerPath)) {
        $issues.Add('File-content export is not allowed unless the destination is an X-Ways evidence file container.')
        $required.Add('Create/open an X-Ways evidence file container first and add selected files to that container.')
    }

    if ($OutputKind -eq 'DerivedFromContainer' -and [string]::IsNullOrWhiteSpace($ContainerPath)) {
        $issues.Add('Derived parsing must identify the source container.')
        $required.Add('Record the container file or container mount/source used for derived analysis.')
    }

    if ($OutputKind -eq 'MetadataOnly') {
        $warnings.Add('Metadata-only exports are allowed only for listings or reports; do not copy file contents through this route.')
    }

    if ($OutputKind -eq 'QueryOnly') {
        $warnings.Add('Query-only actions are preferred when X-Ways command line, scripts, X-Tensions, Export List metadata, or bounded UI can answer without materializing file contents.')
    }

    if ($UsesUiFallback) {
        $warnings.Add('UI fallback requires bounded steps, visible setting confirmation, and contemporaneous notes before and after each action.')
    }

    if ($SourcePath -and $DestinationPath) {
        try {
            $src = [System.IO.Path]::GetFullPath($SourcePath)
            $dst = [System.IO.Path]::GetFullPath($DestinationPath)
            if ($dst.StartsWith($src, [System.StringComparison]::OrdinalIgnoreCase)) {
                $warnings.Add('Destination is inside the source tree; confirm this is a case workspace and not original evidence.')
            }
        }
        catch {
            $warnings.Add('Could not normalize source/destination paths for boundary checking.')
        }
    }

    return [pscustomobject]@{
        allowed = ($issues.Count -eq 0)
        action = $Action
        output_kind = $OutputKind
        issues = @($issues)
        warnings = @($warnings)
        required_next_actions = @($required)
        manual_reference = $ManualReference
        container_path = $ContainerPath
    }
}

function New-XwfQueryFirstUsagePatternPlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RunRoot,

        [Parameter(Mandatory)]
        [string]$Purpose,

        [string]$ManualCachePath = '',

        [int]$MaxWorkers = [Math]::Max(1, [Environment]::ProcessorCount - 1),

        [string]$NotebookPath = '',

        [switch]$AllowUiFallback
    )

    $resolvedRunRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($RunRoot)
    $plansDir = Join-Path $resolvedRunRoot 'plans'
    New-Item -ItemType Directory -Path $plansDir -Force | Out-Null

    $manualGate = Test-XwfManualGate `
        -Query 'Directory Browser Export List X-Tensions API Scripts Case Log volume snapshot metadata event list' `
        -RequiredTerms @('Directory Browser', 'Export List', 'X-Tensions API', 'Scripts', 'Case Log', 'volume snapshot') `
        -ManualCachePath $ManualCachePath

    $bestPractices = Select-XwfBestPractice `
        -Theme @('analysis', 'documentation', 'reproducibility', 'tool_validation', 'preservation') `
        -Reason 'Plan per-machine/per-user usage-pattern analysis using X-Ways query surfaces before materializing any file contents.'

    $actionGate = Test-XwfForensicAction `
        -Action 'Plan query-first per-machine per-user usage-pattern analysis' `
        -OutputKind 'QueryOnly' `
        -ManualReference 'xways-manual.txt:908-916 Directory Browser; 2892-2924 Export List; 6760-6918 Evidence File Containers only if bytes must leave X-Ways; 7.2 Scripts; 7.3 X-Tensions API; 4760-4785 Case Log' `
        -UsesUiFallback:$AllowUiFallback `
        -ManualGatePassed:($manualGate.allowed)

    $planId = '{0}-query-first-usage-pattern-analysis' -f (Get-Date -Format 'yyyyMMdd-HHmmss')
    $planJson = Join-Path $plansDir "$planId.json"
    $planMd = Join-Path $plansDir "$planId.md"

    $querySurfaces = @(
        'Headless command line and scripts with saved settings where the manual supports the action',
        'X-Ways Directory Browser and Export List for volume-snapshot metadata, columns, filters, events, and search-hit metadata',
        'Generated X-Tension for in-process enumeration of case, evidence object, volume snapshot, metadata, events, tags, comments, and search-hit state',
        'Bounded UI fallback only when headless and X-Tension routes cannot safely answer the query'
    )

    $materializationRules = @(
        'Do not materialize file contents if metadata, event lists, search hits, X-Tension output, or X-Ways reports answer the question.',
        'If external parsers need bytes from registry hives, browser databases, event logs, or similar artifacts, add those files to an X-Ways evidence file container first.',
        'Export List is approved for metadata/listing output; its file-copy option is not approved unless routed through the container policy.',
        'Parallel processing applies to independent query batches, evidence objects, X-Tension workers, or container-derived parsing, not to competing writes against the same evidence object.'
    )

    $artifactQuestions = @(
        'Which machines are represented and what OS/install metadata is visible?',
        'Which users are represented on each machine?',
        'What logon, execution, browser, document, shell, removable-media, network, and timeline signals are visible?',
        'Which signals are derived from X-Ways metadata/events versus materialized artifact parsing?',
        'What gaps remain because an artifact is encrypted, unavailable, not parsed, or would require file-content materialization?'
    )

    $plan = [ordered]@{
        created_utc = (Get-Date).ToUniversalTime().ToString('o')
        purpose = $Purpose
        output_policy = 'query-first-no-file-content-materialization'
        allowed = ($manualGate.allowed -and $actionGate.allowed)
        manual_gate = $manualGate
        action_gate = $actionGate
        max_workers = $MaxWorkers
        allow_ui_fallback = [bool]$AllowUiFallback
        xways_manual_references = @(
            'Directory Browser and volume snapshot: xways-manual.txt lines 908-916 and related column/filter sections',
            'Export List metadata: xways-manual.txt lines 2892-2924, manual pages 60-61',
            'Scripts: xways-manual.txt Appendix B and section 7.2',
            'X-Tensions API: X-Ways manual section 7.3 and local API documentation when available',
            'Case Log: xways-manual.txt lines 4760-4785, manual page 99',
            'Evidence File Containers only if file bytes must leave X-Ways: xways-manual.txt lines 6760-6918'
        )
        query_surfaces = $querySurfaces
        materialization_rules = $materializationRules
        artifact_questions = $artifactQuestions
        best_practice_references = @($bestPractices.selected)
        best_practice_selection_rationale = $bestPractices.selection_rationale
        output = [ordered]@{
            reports_root = Join-Path $resolvedRunRoot 'reports'
            query_results_root = Join-Path $resolvedRunRoot 'query-results'
            machine_user_report = 'machine-user-usage-patterns.md'
            structured_events = 'machine-user-usage-events.jsonl'
        }
    }

    New-Item -ItemType Directory -Path $plan.output.query_results_root -Force | Out-Null
    New-Item -ItemType Directory -Path $plan.output.reports_root -Force | Out-Null
    $plan | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $planJson -Encoding UTF8

    $md = @(
        '# Query-First Usage Pattern Analysis Plan'
        ''
        "Created UTC: $($plan.created_utc)"
        ''
        "Purpose: $Purpose"
        ''
        '## Query Surfaces'
        ''
        ($querySurfaces | ForEach-Object { "- $_" }) -join "`r`n"
        ''
        '## Materialization Rules'
        ''
        ($materializationRules | ForEach-Object { "- $_" }) -join "`r`n"
        ''
        '## Questions'
        ''
        ($artifactQuestions | ForEach-Object { "- $_" }) -join "`r`n"
        ''
        "Plan JSON: $planJson"
    ) -join "`r`n"
    $md | Set-Content -LiteralPath $planMd -Encoding UTF8

    if (-not $NotebookPath) {
        $NotebookPath = Join-Path $resolvedRunRoot 'notes\contemporaneous-notes.jsonl'
    }

    if (Test-Path -LiteralPath (Split-Path -Parent $NotebookPath)) {
        Add-XwfContemporaneousNote `
            -NotebookPath $NotebookPath `
            -Category 'plan' `
            -Action 'Created query-first usage-pattern analysis plan' `
            -Rationale $Purpose `
            -ManualReference (($plan.xways_manual_references) -join '; ') `
            -How 'Searched local manual cache, selected query-first X-Ways surfaces, and wrote JSON/Markdown plan files before any file-content materialization.' `
            -BestPracticeReferences $bestPractices.selected `
            -BestPracticeSelectionRationale $bestPractices.selection_rationale `
            -SoundnessCheck @{
                manual_gate_allowed = $manualGate.allowed
                action_gate_allowed = $actionGate.allowed
                file_content_materialized = $false
                original_evidence_modified = $false
                ui_fallback_allowed = [bool]$AllowUiFallback
            } `
            -Result "Plan written to $planJson" | Out-Null
    }

    return [pscustomobject]@{
        plan_json = $planJson
        plan_markdown = $planMd
        allowed = $plan.allowed
        manual_gate = $manualGate
        action_gate = $actionGate
        query_results_root = $plan.output.query_results_root
    }
}

function New-XwfContainerExportPlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RunRoot,

        [Parameter(Mandatory)]
        [string]$Purpose,

        [Parameter(Mandatory)]
        [string]$SelectionDescription,

        [string]$ContainerStem = 'xways-selected-artifacts',

        [string]$ManualCachePath = '',

        [string]$NotebookPath = '',

        [switch]$IncludeSlack,

        [switch]$MetadataOnly,

        [switch]$NoOriginalPath,

        [switch]$NoStoredHashes,

        [switch]$NoChildObjects
    )

    $resolvedRunRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($RunRoot)
    $plansDir = Join-Path $resolvedRunRoot 'plans'
    $containerDir = Join-Path $resolvedRunRoot 'containers'
    New-Item -ItemType Directory -Path $plansDir -Force | Out-Null
    New-Item -ItemType Directory -Path $containerDir -Force | Out-Null

    $manualGate = Test-XwfManualGate `
        -Query 'Evidence File Containers Export List Recover Copy Case Log read-only' `
        -RequiredTerms @('Evidence File Containers', 'Export List', 'Recover/Copy Command', 'Case Log', 'read-only') `
        -ManualCachePath $ManualCachePath

    $bestPractices = Select-XwfBestPractice `
        -Theme @('preservation', 'containerization', 'documentation', 'chain_of_custody', 'analysis') `
        -Reason 'Plan a container-first X-Ways export and later usage-pattern analysis without exposing or altering original evidence.'

    $safeStem = ConvertTo-XwfSafeName $ContainerStem
    $planId = '{0}-{1}' -f (Get-Date -Format 'yyyyMMdd-HHmmss'), $safeStem
    $planJson = Join-Path $plansDir "$planId.container-export-plan.json"
    $planMd = Join-Path $plansDir "$planId.container-export-plan.md"
    $containerRoot = Join-Path $containerDir $safeStem

    $actionGate = Test-XwfForensicAction `
        -Action 'Plan X-Ways container-first export' `
        -OutputKind ($(if ($MetadataOnly) { 'MetadataOnly' } else { 'Container' })) `
        -ManualReference 'xways-manual.txt:6760-6918 Evidence File Containers; 2892-2924 Export List; 11923-12050 Recover/Copy; 4760-4785 Case Log; 449-455 read-only evidence' `
        -DestinationPath $containerRoot `
        -ManualGatePassed:($manualGate.allowed)

    $plan = [ordered]@{
        created_utc = (Get-Date).ToUniversalTime().ToString('o')
        purpose = $Purpose
        selection_description = $SelectionDescription
        output_policy = if ($MetadataOnly) { 'metadata-list-only-no-file-content' } else { 'xways-evidence-file-container-first' }
        container_root = $containerRoot
        container_name_stem = $safeStem
        manual_gate = $manualGate
        action_gate = $actionGate
        xways_manual_references = @(
            'Evidence File Containers: xways-manual.txt lines 6760-6918, manual pages 140-143',
            'Export List: xways-manual.txt lines 2892-2924, manual pages 60-61',
            'Recover/Copy: xways-manual.txt lines 11923-12050, manual pages 242-250',
            'Case Log: xways-manual.txt lines 4760-4785, manual page 99',
            'Read-only evidence handling: xways-manual.txt lines 449-455 and 4611-4617'
        )
        best_practice_references = @($bestPractices.selected)
        best_practice_selection_rationale = $bestPractices.selection_rationale
        required_xways_settings = [ordered]@{
            create_or_open_evidence_file_container = (-not $MetadataOnly)
            add_selected_files_to_container = (-not $MetadataOnly)
            export_list_allowed = $true
            export_list_must_be_metadata_only = $true
            recover_copy_file_content_outside_container = $false
            include_original_path = (-not $NoOriginalPath)
            include_child_objects = (-not $NoChildObjects)
            include_slack = [bool]$IncludeSlack
            store_hashes_in_container = (-not $NoStoredHashes)
            record_xways_case_log_entry = $true
            record_external_contemporaneous_note = $true
            verify_copylog_or_container_log_after_action = $true
        }
        analysis_boundary = [ordered]@{
            external_parsing_source = 'container or derived copy created from container'
            direct_parser_access_to_original_evidence = $false
            parallel_processing_allowed_after_containerization = $true
        }
    }

    $plan | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $planJson -Encoding UTF8

    $md = @(
        '# Container-First Export Plan'
        ''
        "Created UTC: $($plan.created_utc)"
        ''
        "Purpose: $Purpose"
        ''
        "Selection: $SelectionDescription"
        ''
        '## Manual References'
        ''
        ($plan.xways_manual_references | ForEach-Object { "- $_" }) -join "`r`n"
        ''
        '## Required Settings'
        ''
        '- File contents must be added to an X-Ways evidence file container before external analysis.'
        '- Metadata-only Export List output may be used to enumerate candidates, but must not copy file contents.'
        '- Recover/Copy to an ordinary filesystem folder is not approved for file contents.'
        '- X-Ways Case Log and this notebook must record each action.'
        '- Derived parsing may run in parallel only after the source is a container or a copy derived from a container.'
        ''
        "Plan JSON: $planJson"
    ) -join "`r`n"
    $md | Set-Content -LiteralPath $planMd -Encoding UTF8

    if (-not $NotebookPath) {
        $NotebookPath = Join-Path $resolvedRunRoot 'notes\contemporaneous-notes.jsonl'
    }

    if (Test-Path -LiteralPath (Split-Path -Parent $NotebookPath)) {
        Add-XwfContemporaneousNote `
            -NotebookPath $NotebookPath `
            -Category 'plan' `
            -Action 'Created container-first export plan' `
            -Rationale $Purpose `
            -ManualReference (($plan.xways_manual_references) -join '; ') `
            -How 'Searched local manual cache, applied container-first action gate, and wrote JSON/Markdown plan files before any export action.' `
            -BestPracticeReferences $bestPractices.selected `
            -BestPracticeSelectionRationale $bestPractices.selection_rationale `
            -SoundnessCheck @{
                manual_gate_allowed = $manualGate.allowed
                action_gate_allowed = $actionGate.allowed
                file_content_outside_container = $false
                original_evidence_modified = $false
            } `
            -Result "Plan written to $planJson" | Out-Null
    }

    return [pscustomobject]@{
        plan_json = $planJson
        plan_markdown = $planMd
        allowed = ($manualGate.allowed -and $actionGate.allowed)
        manual_gate = $manualGate
        action_gate = $actionGate
        container_root = $containerRoot
    }
}

function New-XwfUsagePatternPlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RunRoot,

        [Parameter(Mandatory)]
        [string]$ContainerPath,

        [int]$MaxWorkers = [Math]::Max(1, [Environment]::ProcessorCount - 1),

        [string]$NotebookPath = ''
    )

    $resolvedRunRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($RunRoot)
    $plansDir = Join-Path $resolvedRunRoot 'plans'
    New-Item -ItemType Directory -Path $plansDir -Force | Out-Null

    $bestPractices = Select-XwfBestPractice `
        -Theme @('analysis', 'documentation', 'reproducibility', 'tool_validation') `
        -Reason 'Plan per-machine/per-user usage-pattern analysis after containerization.'

    $actionGate = Test-XwfForensicAction `
        -Action 'Plan per-machine per-user usage-pattern analysis' `
        -OutputKind 'DerivedFromContainer' `
        -ManualReference 'Container-first policy and X-Ways Evidence File Containers manual references recorded in export plan.' `
        -ContainerPath $ContainerPath `
        -ManualGatePassed

    $planId = '{0}-usage-pattern-analysis' -f (Get-Date -Format 'yyyyMMdd-HHmmss')
    $planJson = Join-Path $plansDir "$planId.json"
    $planMd = Join-Path $plansDir "$planId.md"

    $artifactFamilies = @(
        'Registry hives: SYSTEM, SOFTWARE, SAM, SECURITY, NTUSER.DAT, UsrClass.dat, Amcache.hve',
        'Windows Event Logs: security, system, application, PowerShell, RDP, task scheduler, storage',
        'Shell activity: LNK, Jump Lists, shellbags, RecentDocs, TypedPaths, RunMRU, UserAssist',
        'Execution traces: Prefetch, SRUM, services, scheduled tasks, shimcache/amcache',
        'Browser activity: Edge/Chrome/Firefox history stores, downloads, sessions',
        'Filesystem chronology: $MFT, USN journal, recycle bin, timeline timestamps where available'
    )

    $plan = [ordered]@{
        created_utc = (Get-Date).ToUniversalTime().ToString('o')
        source_container = $ContainerPath
        allowed = $actionGate.allowed
        action_gate = $actionGate
        max_workers = $MaxWorkers
        artifact_families = $artifactFamilies
        best_practice_references = @($bestPractices.selected)
        best_practice_selection_rationale = $bestPractices.selection_rationale
        output = [ordered]@{
            derived_root = Join-Path $resolvedRunRoot 'derived-from-containers'
            reports_root = Join-Path $resolvedRunRoot 'reports'
            machine_user_report = 'machine-user-usage-patterns.md'
            structured_events = 'machine-user-usage-events.jsonl'
        }
        rules = @(
            'Do not parse original evidence directly.',
            'Parse only mounted/read-only containers or derived copies from containers.',
            'Run artifact-family parsers in parallel after containerization.',
            'Do not print user names, filenames, or case paths to chat; write detailed results locally.',
            'Record parser versions, command lines, input hashes, and output hashes in contemporaneous notes.'
        )
    }

    $plan | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $planJson -Encoding UTF8

    $md = @(
        '# Usage Pattern Analysis Plan'
        ''
        "Created UTC: $($plan.created_utc)"
        ''
        '## Artifact Families'
        ''
        ($artifactFamilies | ForEach-Object { "- $_" }) -join "`r`n"
        ''
        '## Rules'
        ''
        ($plan.rules | ForEach-Object { "- $_" }) -join "`r`n"
        ''
        "Max workers: $MaxWorkers"
        ''
        "Plan JSON: $planJson"
    ) -join "`r`n"
    $md | Set-Content -LiteralPath $planMd -Encoding UTF8

    if (-not $NotebookPath) {
        $NotebookPath = Join-Path $resolvedRunRoot 'notes\contemporaneous-notes.jsonl'
    }

    if (Test-Path -LiteralPath (Split-Path -Parent $NotebookPath)) {
        Add-XwfContemporaneousNote `
            -NotebookPath $NotebookPath `
            -Category 'plan' `
            -Action 'Created usage-pattern analysis plan' `
            -Rationale 'Plan parallel per-machine/per-user analysis after container-first export.' `
            -ManualReference 'Container-first export plan and local X-Ways manual references.' `
            -How 'Confirmed the analysis source is a container path, selected analysis/documentation guidance, and wrote a local plan for parallel parsing.' `
            -BestPracticeReferences $bestPractices.selected `
            -BestPracticeSelectionRationale $bestPractices.selection_rationale `
            -SoundnessCheck @{
                action_gate_allowed = $actionGate.allowed
                source_is_container = [bool]$ContainerPath
                original_evidence_modified = $false
            } `
            -Result "Plan written to $planJson" | Out-Null
    }

    return [pscustomobject]@{
        plan_json = $planJson
        plan_markdown = $planMd
        allowed = $actionGate.allowed
        action_gate = $actionGate
        max_workers = $MaxWorkers
    }
}

Export-ModuleMember -Function @(
    'New-XwfForensicRun',
    'Add-XwfContemporaneousNote',
    'Get-XwfBestPracticeCatalog',
    'Select-XwfBestPractice',
    'Test-XwfManualGate',
    'Test-XwfForensicAction',
    'New-XwfQueryFirstUsagePatternPlan',
    'New-XwfContainerExportPlan',
    'New-XwfUsagePatternPlan',
    'Get-XwfPortableExecutable',
    'Get-XwfPeExternalFunction',
    'Get-XwfPeExport',
    'Get-XwfApiString',
    'Compare-XwfExternalSurface',
    'Export-XwfExternalSurfaceReport',
    'Get-XwfApiCatalog',
    'Test-XwfApiInvocation',
    'Invoke-XwfApiFunction',
    'Get-XwfColumnTitle',
    'Get-XwfWindow',
    'Remove-XwfMemoryAllocation',
    'Hide-XwfProgress',
    'Test-XwfStopRequested',
    'Set-XwfProgressDescription',
    'Set-XwfProgressPercentage',
    'Show-XwfProgress',
    'Get-XwfUserInput',
    'Write-XwfMessage',
    'Get-XwfEvent',
    'Add-XwfEvent',
    'Invoke-XwfSearchTermAction',
    'Add-XwfSearchTerm',
    'Get-XwfSearchTerm',
    'Search-XwfItem',
    'Get-XwfEvidenceObjectReportTableAssociation',
    'Get-XwfReportTableInfo',
    'Get-XwfEvidenceObject',
    'Get-XwfEvidenceObjectProperty',
    'Close-XwfEvidenceObject',
    'Open-XwfEvidenceObject',
    'New-XwfEvidenceObject',
    'Get-XwfNextEvidenceObject',
    'Get-XwfFirstEvidenceObject',
    'Get-XwfCaseProperty',
    'New-XwfContainer',
    'Close-XwfContainer',
    'Copy-XwfItemToContainer',
    'Get-XwfRasterImage',
    'Get-XwfText',
    'Initialize-XwfTextAccess',
    'Get-XwfExtendedMetadata',
    'Get-XwfMetadata',
    'Get-XwfCellText',
    'Set-XwfHashValue',
    'Get-XwfHashValue',
    'Add-XwfExtractedMetadata',
    'Get-XwfExtractedMetadata',
    'Add-XwfComment',
    'Get-XwfComment',
    'Add-XwfReportTableEntry',
    'Set-XwfItemLabel',
    'Get-XwfReportTableAssociation',
    'Get-XwfLabels',
    'Get-XwfHashSetAssociation',
    'Set-XwfItemParent',
    'Get-XwfItemParent',
    'Set-XwfItemType',
    'Get-XwfItemType',
    'Set-XwfItemInformation',
    'Get-XwfItemInformation',
    'Set-XwfItemOffset',
    'Get-XwfItemOffset',
    'Set-XwfItemSize',
    'Get-XwfItemSize',
    'Get-XwfItemName',
    'Dismount-XwfVolume',
    'Mount-XwfVolume',
    'Find-XwfItem',
    'New-XwfFile',
    'New-XwfItem',
    'Get-XwfFileCount',
    'Get-XwfItemCount',
    'Get-XwfVolumeSnapshotProperty',
    'Select-XwfVolumeSnapshot',
    'Invoke-XwfSectorIo',
    'Read-XwfContent',
    'Close-XwfContext',
    'Open-XwfItem',
    'Get-XwfSectorContents',
    'Set-XwfBlock',
    'Get-XwfBlock',
    'Get-XwfVolumeInformation',
    'Get-XwfVolumeName',
    'Get-XwfProperty',
    'Get-XwfSize'
)

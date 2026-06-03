param(
    [Parameter(Mandatory)]
    [string]$XwfRoot,

    [string]$OutputDirectory = (Join-Path (Get-Location) 'reports\xwf-external-surface')
)

$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')
$modulePath = Join-Path $repoRoot.Path 'powershell\XWaysForensicWorkflow\XWaysForensicWorkflow.psd1'

Import-Module $modulePath -Force

$comparison = Compare-XwfExternalSurface `
    -XwfRoot $XwfRoot `
    -OutputDirectory $OutputDirectory

[pscustomobject]@{
    executable = $comparison.executable.path
    sha256 = $comparison.executable.sha256
    import_count = $comparison.import_count
    xwf_export_count = $comparison.xwf_export_count
    missing_documented_xwf_exports = @($comparison.documented_xwf_missing_exports)
    undocumented_candidates = @($comparison.undocumented_candidates | ForEach-Object { $_.name })
    output_directory = (Resolve-Path -LiteralPath $OutputDirectory).Path
}

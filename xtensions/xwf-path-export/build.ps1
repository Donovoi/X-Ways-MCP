[CmdletBinding()]
param(
    [string]$OutDir = (Join-Path $PSScriptRoot 'build')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$zig = Get-Command zig -ErrorAction Stop
$resolvedOutDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutDir)
New-Item -ItemType Directory -Path $resolvedOutDir -Force | Out-Null

$source = Join-Path $PSScriptRoot 'xwf_path_export.c'
$def = Join-Path $PSScriptRoot 'XwfPathExport.def'
$dll = Join-Path $resolvedOutDir 'XwfPathExport.dll'

& $zig.Source cc `
    -target x86_64-windows-gnu `
    -shared `
    -O2 `
    -Wall `
    -Wextra `
    -Wno-unused-parameter `
    -o $dll `
    $source `
    $def `
    -lkernel32

if ($LASTEXITCODE -ne 0) {
    throw "zig cc failed with exit code $LASTEXITCODE"
}

Get-Item -LiteralPath $dll

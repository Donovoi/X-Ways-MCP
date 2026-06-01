[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$CaseRoot,

    [string]$RunName = 'query-first-usage-pattern-analysis',

    [switch]$AllowUiFallback
)

$ErrorActionPreference = 'Stop'

$modulePath = Join-Path $PSScriptRoot '..\..\powershell\XWaysForensicWorkflow\XWaysForensicWorkflow.psd1'
Import-Module $modulePath -Force

$run = New-XwfForensicRun -CaseRoot $CaseRoot -RunName $RunName -Force

$queryPlan = New-XwfQueryFirstUsagePatternPlan `
    -RunRoot $run.run_root `
    -Purpose 'Use X-Ways query surfaces to build per-machine/per-user usage patterns before materializing file contents.' `
    -AllowUiFallback:$AllowUiFallback

if (-not $queryPlan.allowed) {
    throw 'Query-first usage-pattern plan is not allowed. Review manual/action gate issues in the generated plan.'
}

$queryPlan

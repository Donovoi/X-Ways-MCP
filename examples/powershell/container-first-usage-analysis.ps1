[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$CaseRoot,

    [string]$RunName = 'usage-pattern-analysis',

    [string]$ContainerStem = 'xways-user-activity-artifacts'
)

$ErrorActionPreference = 'Stop'

$modulePath = Join-Path $PSScriptRoot '..\..\powershell\XWaysForensicWorkflow\XWaysForensicWorkflow.psd1'
Import-Module $modulePath -Force

$run = New-XwfForensicRun -CaseRoot $CaseRoot -RunName $RunName -Force

$bestPractices = Select-XwfBestPractice `
    -Theme preservation,documentation,chain_of_custody,containerization `
    -Reason 'Planning a container-first X-Ways export for later usage-pattern analysis.'

$exportPlan = New-XwfContainerExportPlan `
    -RunRoot $run.run_root `
    -Purpose 'Prepare a container-first export of carved user-activity artifacts for local usage-pattern analysis.' `
    -SelectionDescription 'Registry hives, event logs, browser stores, jump lists, link files, Prefetch, SRUM, MFT/USN, and related artifacts selected from X-Ways.' `
    -ContainerStem $ContainerStem

if (-not $exportPlan.allowed) {
    throw 'Container export plan is not allowed. Review manual/action gate issues in the generated plan.'
}

Add-XwfContemporaneousNote `
    -NotebookPath $run.notebook_jsonl `
    -Category 'next-action' `
    -Action 'Await X-Ways evidence file container creation/fill step' `
    -How 'Created a local export plan and selected public best-practice references before any X-Ways export action.' `
    -Rationale 'File contents must be containerized before external parsing or parallel analysis.' `
    -ManualReference 'Evidence File Containers manual references are recorded in the export plan.' `
    -BestPracticeReferences $bestPractices.selected `
    -BestPracticeSelectionRationale $bestPractices.selection_rationale `
    -SoundnessCheck @{
        original_evidence_modified = $false
        file_content_outside_container = $false
        ready_for_parallel_parsing = $false
    } `
    -Result 'Plan created; no evidence export performed by this script.' | Out-Null

$exportPlan

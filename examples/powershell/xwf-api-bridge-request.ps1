param(
    [string]$OutboxPath = (Join-Path (Get-Location) 'case-workspaces\CASE-001\xwf-api-requests.jsonl'),

    [string]$CaseId = 'CASE-001'
)

$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')
$modulePath = Join-Path $repoRoot.Path 'powershell\XWaysForensicWorkflow\XWaysForensicWorkflow.psd1'

Import-Module $modulePath -Force

$metadataRequest = Get-XwfItemName `
    -Argument @{ nItemID = 42 } `
    -OutboxPath $OutboxPath `
    -CaseId $CaseId `
    -Purpose 'Resolve item name through an in-process X-Tension bridge.' `
    -PassThru

$commentRequest = Add-XwfComment `
    -Argument @{
        nItemID = 42
        lpComment = 'Queued by X-Ways-MCP PowerShell bridge request example.'
        nFlagsHowToAdd = 0
    } `
    -OutboxPath $OutboxPath `
    -AllowMutating `
    -CaseId $CaseId `
    -Purpose 'Demonstrate explicit mutating-request opt-in.' `
    -PassThru

[pscustomobject]@{
    outbox_path = (Resolve-Path -LiteralPath $OutboxPath).Path
    metadata_request_id = $metadataRequest.request_id
    metadata_api = $metadataRequest.api_name
    comment_request_id = $commentRequest.request_id
    comment_api = $commentRequest.api_name
}

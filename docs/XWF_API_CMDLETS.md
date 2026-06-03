# XWF API PowerShell Cmdlets

The PowerShell module exposes the 77 verified `XWF_*` exports from the X-Ways
21.8 x64 executable as agent-facing cmdlets. These cmdlets create validated
bridge requests for an in-process X-Tension runner.

They do not call the X-Ways executable directly. The XWF API is an in-process
X-Tension API, so the native call belongs inside a DLL loaded by X-Ways. The
PowerShell layer is the safe planning, validation, request, and audit surface
for agents.

## Import

```powershell
Import-Module .\powershell\XWaysForensicWorkflow\XWaysForensicWorkflow.psd1 -Force
```

## Catalog

List all exported API cmdlets:

```powershell
Get-XwfApiCatalog
```

Find the wrapper for a specific native export:

```powershell
Get-XwfApiCatalog -ApiName XWF_GetItemName
```

Each catalog row records:

- `api_name`: exact native export name, such as `XWF_GetItemName`
- `cmdlet_name`: PowerShell wrapper, such as `Get-XwfItemName`
- `ordinal` and `rva`: values verified from the 21.8 x64 executable
- `signature`: official X-Tensions API signature text where available
- `parameter_names` and `parameter_types`
- `risk_level`, `mutates_case`, and `reads_content`

## Request Objects

For read-only metadata/control APIs, calling the cmdlet returns a request object:

```powershell
$request = Get-XwfItemName `
  -Argument @{ nItemID = 42 } `
  -CaseId 'CASE-001' `
  -Purpose 'Resolve item name for a metadata-only report.'
```

The returned object uses schema `xwf-api-bridge-request/v1` and preserves the
exact native function name in `api_name`.

## JSONL Outbox

Write a request for a bridge runner to consume:

```powershell
Get-XwfItemName `
  -Argument @{ nItemID = 42 } `
  -OutboxPath '.\case-workspaces\CASE-001\xwf-api-requests.jsonl' `
  -CaseId 'CASE-001' `
  -Purpose 'Resolve item name for a metadata-only report.'
```

One JSON object is appended per line. A future X-Tension bridge can read the
outbox, execute allowed requests inside X-Ways, and write result JSONL with the
same `request_id`.

## Safety Gates

Mutating or state-changing APIs are blocked unless the caller explicitly opts in:

```powershell
Add-XwfComment `
  -Argument @{ nItemID = 42; lpComment = 'Reviewed'; nFlagsHowToAdd = 0 } `
  -OutboxPath '.\case-workspaces\CASE-001\xwf-api-requests.jsonl' `
  -AllowMutating `
  -CaseId 'CASE-001' `
  -Purpose 'Queue a reviewed-item comment through an in-process bridge.'
```

Content-reading APIs such as `XWF_Read` are blocked unless `-AllowContentAccess`
is present:

```powershell
Read-XwfContent `
  -Argument @{
    hVolumeOrItem = '<bridge-handle>'
    nOffset = 0
    lpBuffer = '<bridge-owned-buffer>'
    nNumberOfBytesToRead = 4096
  } `
  -AllowContentAccess `
  -Purpose 'Approved container-first content read through an in-process bridge.'
```

Use `Test-XwfApiInvocation` when an agent needs a validation result without
creating a request:

```powershell
Test-XwfApiInvocation -ApiName XWF_Read -Argument @{ nOffset = 0 }
```

## Naming

The wrappers use approved PowerShell verbs and expanded nouns while preserving
the exact native export in the request payload. Examples:

- `XWF_GetItemName` -> `Get-XwfItemName`
- `XWF_GetEvObjProp` -> `Get-XwfEvidenceObjectProperty`
- `XWF_CopyToContainer` -> `Copy-XwfItemToContainer`
- `XWF_AddComment` -> `Add-XwfComment`
- `XWF_Read` -> `Read-XwfContent`
- `XWF_ShouldStop` -> `Test-XwfStopRequested`
- `XWF_Unmount` -> `Dismount-XwfVolume`

The documented-but-not-exported functions from the 21.8 x64 baseline are kept
in the analysis data, but they are not exposed as callable wrappers.

## Boundary

Agents should treat these cmdlets as a contract with an X-Tension bridge, not as
a native FFI layer. Any bridge implementation must still record manual/API
provenance, X-Ways version/hash, input source, output paths, and whether the
request is metadata-only, mutating, or content-reading.

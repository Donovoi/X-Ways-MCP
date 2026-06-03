# X-Ways External Surface Analysis

This repo can locally inventory the external function surface of an X-Ways
portable install without executing X-Ways. The workflow is meant for tool
validation and X-Tension planning, not for parsing original evidence directly.

## What Is Checked

The PowerShell module reads PE files directly and reports:

- X-Ways executable identity, SHA-256, version metadata, and architecture.
- Normal imports and delay-load imports from external DLLs.
- PE exports, especially callable `XWF_*` X-Tensions API functions.
- ASCII and UTF-16LE strings that look like `XWF_*` or `XT_*` names.
- Differences between local exports/strings and the documented XWF/XT reference
  data committed in `data/xwf-external-surface`.

It never loads the executable into a process, starts X-Ways, or calls any X-Ways
API function.

## Reference Baseline

The current committed baseline was produced from X-Ways Forensics / WinHex 21.8
64-bit:

- executable: `winhexb64.exe`
- SHA-256: `5d357bdd35a9c6d9cc1564f68430b7ec7a49fc824d1b6a501f42a7fe805358d1`
- imported external functions: 613, including 3 delay imports from
  `MSIMG32.DLL`
- exported `XWF_*` functions: 77
- documented callable `XT_*` callbacks found in strings: 15

Eight documented `XWF_*` functions were not exported by that 21.8 x64 binary:

- `XWF_AddSearchHit`
- `XWF_DeleteEvObj`
- `XWF_GetDriveInfo`
- `XWF_GetSearchHit`
- `XWF_SetItemDataRuns`
- `XWF_SetItemName`
- `XWF_SetSearchHit`
- `XWF_Write`

Two undocumented-looking string names need caution:

- `XWF_EDB` appears as a bare string at `winhexb64.exe@0x4f834c`, but it is not
  exported in the 21.8 x64 binary. Treat it as a clue only until xrefs prove a
  callable path.
- `XT_error` appears as part of `XT_error.log`; treat it as a log filename, not
  an undocumented callback.

## PowerShell Cmdlets

Import the module:

```powershell
Import-Module .\powershell\XWaysForensicWorkflow\XWaysForensicWorkflow.psd1 -Force
```

Discover local X-Ways executables:

```powershell
Get-XwfPortableExecutable -XwfRoot 'C:\Tools\xwfportable'
```

List external imports and delay imports:

```powershell
Get-XwfPeExternalFunction -Path 'C:\Tools\xwfportable\winhexb64.exe' |
  Group-Object dll
```

List exported X-Tensions API functions:

```powershell
Get-XwfPeExport -Path 'C:\Tools\xwfportable\winhexb64.exe' |
  Where-Object name -like 'XWF_*'
```

Find API-looking strings:

```powershell
Get-XwfApiString -Path 'C:\Tools\xwfportable\winhexb64.exe' |
  Where-Object api_names -match 'XWF_EDB|XT_'
```

Run the full comparison and write artifacts:

```powershell
Compare-XwfExternalSurface `
  -XwfRoot 'C:\Tools\xwfportable' `
  -OutputDirectory '.\reports\xwf-external-surface'
```

The output directory receives:

- `xwf-external-surface-report.md`
- `xwf-external-surface-summary.json`
- `xwf-external-imports.csv`
- `xwf-exports.csv`
- `xwf-api-strings.csv`

## Forensic Boundary

Use these cmdlets against the X-Ways program files you own or against
container-derived copies. If a future workflow applies them to files collected
from evidence, follow the normal X-Ways-MCP policy first:

1. Prefer query-first X-Ways metadata, reports, scripts, and X-Tensions.
2. Do not parse original evidence directly when bytes must leave X-Ways.
3. Put selected file contents into an X-Ways evidence file container first.
4. Run external parsers only against the container or a container-derived copy.
5. Record hashes, parser version, command line, and output paths in
   contemporaneous notes.

## Deeper Confirmation

The committed cmdlets identify exports, imports, delay imports, and string
clues. To prove that a non-exported string such as `XWF_EDB` is meaningful, keep
a Ghidra project, search for the string reference, and inspect the referencing
function. String presence alone does not establish a supported or callable API.

# XwfPathExport

`XwfPathExport` is a metadata-only X-Tension for local X-Ways case triage. It
enumerates existing volume snapshots and writes JSON Lines records with item
names, reconstructed paths, basic file-system metadata, and evidence object
metadata.

It does not call `XWF_Read`, does not copy file content, and does not create or
modify volume snapshot items. The output is sensitive because it contains raw
paths and evidence object designations; keep it in the local case workspace and
feed it into the sanitized usage-pattern triage script.

## Manual/API Basis

- X-Ways command-line support for `XT:<dll>` and `XTParam:<ID>:<value>`.
- `XT_Init`, `XT_Prepare`, and `XT_Finalize` from the X-Tensions API.
- `XWF_GetFirstEvObj`, `XWF_GetNextEvObj`, `XWF_OpenEvObj`,
  `XWF_CloseEvObj`, and `XWF_GetEvObjProp` for case evidence enumeration.
- `XWF_SelectVolumeSnapshot` and `XWF_GetItemCount` for selecting and sizing a
  volume snapshot.
- `XWF_GetItemName` plus `XWF_GetItemParent` for documented path
  reconstruction.
- `XWF_GetItemSize` and `XWF_GetItemInformation` for metadata-only item
  attributes and timestamps.

## Build

```powershell
.\build.ps1
```

The build uses `zig cc` so runners do not need a full Visual Studio install.

## Run

Use an existing case and pass a local output path with `XTParam`:

```text
xwb64.exe "<case.xfc>" "XT:<repo>\xtensions\xwf-path-export\build\XwfPathExport.dll" "XTParam:XWFPathExport:<local-output.jsonl>" auto
```

By default the X-Tension writes usage-relevant paths only. Add
`XTParam:XWFPathExportMode:all` only for small fixture cases or when a documented
need exists, because full snapshots can be very large.

The X-Tension opens evidence objects with X-Ways' documented read-only/no
underlying-disk flag combination (`0x03`) so the run uses existing volume
snapshot metadata.

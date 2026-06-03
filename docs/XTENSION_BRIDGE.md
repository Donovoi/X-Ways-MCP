# X-Tension Bridge Workflow

Use X-Tensions as the second automation layer, after headless X-Ways operations
and before UI automation.

## Decision Rule

0. Check the newest available official manual/docs or approved local docs cache.
1. Search local X-Ways manual/docs for command-line, script, `.dlg`, `Cfg:`,
   `XT:`, and `XTParam:*` support.
2. If the task needs in-process access and the X-Tensions API can cover it,
   generate a bridge scaffold.
3. Use UI automation only when neither headless nor X-Tension routes are
   practical.

## Scaffold

Generate a local scaffold:

```text
create_xtension_scaffold(
  name="volume_snapshot_export",
  purpose="Export volume snapshot metadata to local JSONL",
  api_reference="local X-Tensions API documentation",
  documented_symbols="XT_Init\nXWF_GetVSProp"
)
```

The generated folder contains:

- `manifest.json`
- `README.md`
- `API_NOTES.md`
- `src/<name>.cpp`
- `build.ps1`

The C++ source is intentionally conservative. It includes a probe export and a
place to wire the exact X-Tensions API callback signatures for the target X-Ways
version. Runners must confirm the signatures from local or official API
documentation before building.

## Included Metadata Bridge

`xtensions/xwf-path-export` contains a concrete metadata-only bridge for
enumerating existing volume snapshots and reconstructing item paths. It is meant
for query-first usage-pattern triage when command-line/report metadata is
insufficient.

The bridge does not call `XWF_Read`, does not copy file contents, and does not
modify volume snapshot items. Its raw JSONL output is sensitive and should stay
inside the local case workspace, then be summarized with
`scripts/Invoke-XwfPathUsagePatternTriage.ps1`.

## Undocumented API Notes

If a runner uses undocumented or locally researched API behavior, `API_NOTES.md`
must record:

- X-Ways executable name and version
- executable SHA-256 and the `Compare-XwfExternalSurface` artifact path, when
  available
- where the symbol or behavior was found
- whether the name is exported, documented, or only present as a string
- expected calling convention and argument ownership
- failure behavior
- why no documented/headless route was sufficient

Treat undocumented behavior as version-bound. Do not generalize it silently.

## Output Policy

X-Tensions must write evidence-derived output to the approved local case
workspace. Agent-visible responses should contain status, counts, and artifact
paths only. Do not print recovery keys, evidence names, recovered filenames, or
case-sensitive paths.

## Parallel And GPU Notes

The local manual cache says file-wise X-Tension processing through
`XT_ProcessItem` or `XT_ProcessItemEx` can be parallelized when the X-Tension
identifies itself as thread-safe. Any generated bridge that opts into that must
document its shared state, locking, output file ownership, and X-Ways version.

No native X-Ways GPU control was found in the local manual/docs cache. GPU work
should therefore be implemented only as a local sidecar or bridge-assisted
pipeline after testing with disposable fixture evidence.

# Parallel X-Ways Processing

`xways-mcp` uses the local X-Ways manual as the source of truth before choosing
a parallel execution strategy.

## Manual-Backed Findings

The local manual cache documents native distributed volume snapshot refinement:

- `tooling/cache/xways-manual/xways-manual.txt:4593-4606`: X-Ways Forensics can
  refine volume snapshots of different evidence objects in the same case using
  multiple machines or instances. Workers open the same `.xfc` case copy. All
  participating sessions except possibly the master must use the partial
  read-only shared/distributed mode.
- `tooling/cache/xways-manual/xways-manual.txt:5561-5570`: logical searches can
  use extra worker threads for evidence objects that are images or directories,
  up to the X-Ways Forensics CPU-thread limit.
- `tooling/cache/xways-manual/xways-manual.txt:8452-8468`: file-processing
  stages of volume snapshot refinement can use multiple threads. X-Tension
  item processing is parallelized only when the X-Tension identifies itself as
  thread-safe.
- Searching the local cache for GPU/CUDA/OpenCL/DirectX/hardware acceleration
  terms did not reveal a native X-Ways GPU processing control.

## Preferred Strategy

For RVS, file header signature search, carving, indexing, and similar
case-refinement work:

1. Use X-Ways native distributed RVS for different evidence objects in the same
   `.xfc` case.
2. Use X-Ways' internal CPU worker threads inside each worker, bounded by CPU
   cores and storage throughput.
3. Use isolated per-evidence worker cases only when native distributed same-case
   mode cannot be driven safely from the runner. Plan for merge/import and
   reconciliation afterward.
4. Use generated X-Tensions for in-process gaps. If `XT_ProcessItem` or
   `XT_ProcessItemEx` is used, the bridge must explicitly document whether it is
   thread-safe.
5. Use GPU only through a local sidecar or bridge after a disposable benchmark;
   do not assume native X-Ways GPU support.

## MCP Tool

Use `plan_parallel_xways_jobs` before launching work:

```text
plan_parallel_xways_jobs(
  case_name="CASE-001",
  evidence_paths="<one evidence path per line>",
  case_path="<same-case.xfc>",
  operation="Refine Volume Snapshot with file header signature search",
  requested_workers=4,
  execution_mode="auto"
)
```

The tool returns a sanitized plan by default. Full evidence paths and launch
commands are written only to local plan artifacts when explicitly requested.

## Guardrails

- Do not run competing refinements against the same evidence object.
- Keep one full-access or master session at most.
- Open worker sessions in shared/distributed partial read-only mode.
- Keep all participating X-Ways instances on the same version.
- Prefer evidence objects on different physical storage when possible.
- Avoid oversubscription: total pressure is external workers times X-Ways
  internal worker threads.
- Keep recovery keys, evidence names, recovered filenames, and case-sensitive
  paths out of prompts, public docs, commits, issues, and PRs.

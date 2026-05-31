# MCP Tools

## environment

Returns platform, Python version, configured search roots, and execution safety
status.

## public_xways_release

Fetches public X-Ways release information from X-Ways pages. This is only a
convenience check; licensed downloads still require the user's X-Ways
credentials.

## manual_status

Reports whether a local offline manual index exists and lists local
`manual.pdf` candidates. With `check_online=true`, it checks public X-Ways
manual headers without sending any case data.

## cache_xways_manual

Copies or downloads the X-Ways manual into a gitignored local cache and builds a
searchable text index for model lookup. The manual itself is not committed to
the repository.

Useful modes:

- `source="<XWAYS_ROOT>\\manual.pdf"`: use the manual already shipped with the
  local X-Ways installation.
- `download_latest=true`: download the public manual from X-Ways.
- `fetch_official_docs=true`: also cache the official scripting and setup pages.

Default cache location:

```text
tooling/cache/xways-manual
```

Override with `XWAYS_MCP_MANUAL_CACHE` or the tool's `cache_dir` argument.

## search_xways_manual

Searches the local manual/docs index and returns small snippets with page/source
metadata. Use this before building headless commands or X-Ways script files.

## headless_xways_reference

Convenience wrapper around `search_xways_manual` tuned for command-line,
scripting, automated-processing, and `XTParam:*` lookups.

## plan_xways_operation

Chooses the preferred automation route for an X-Ways task:

1. headless command/script/dialog/configuration route
2. native distributed RVS when the local manual supports it
3. generated X-Tension bridge
4. UI automation as the last resort

The response includes detected headless/API terms, the selected route, case-data
handling rules, and next steps. Use this before deciding that Windows UI
automation is necessary.

## plan_parallel_xways_jobs

Builds a sanitized parallel execution plan without launching X-Ways.

The planner is manual-backed:

- RVS/file header signature search/carving operations default to X-Ways native
  distributed volume snapshot refinement for different evidence objects in the
  same `.xfc` case.
- X-Ways internal CPU worker threads are included in the capacity plan.
- Isolated per-evidence worker cases are treated as a fallback when native
  distributed same-case mode cannot be driven safely.
- GPU is not assumed to be native X-Ways functionality. GPU acceleration must be
  a local sidecar or X-Tension bridge with disposable benchmark evidence first.

By default the response redacts full evidence paths. Use `write_plan=true` to
write the sensitive worker details into a local case artifact.

## create_xtension_scaffold

Generates a local X-Tension bridge scaffold with:

- `manifest.json`
- `README.md`
- `API_NOTES.md`
- `src/<name>.cpp`
- `build.ps1`

The scaffold is intentionally local and provenance-heavy. Runners must record
documented API symbols, any undocumented/version-bound behavior, and why no
headless command or script covered the task.

## discover_installations

Searches configured roots for:

- `xwforensics.exe`
- `xwforensics64.exe`
- `winhex.exe`
- `winhex64.exe`
- `xwimager.exe`
- `xwimager64.exe`
- `XWFIM.exe`

## inspect_xwfim_cache

Validates ZIPs in an XWFIM `Temp` directory. This catches the exact failure mode
where `viewer.zip` exists but is truncated and cannot be extracted.

The response includes a `summary` block with:

- `status`: `ok`, `problem`, or `empty`
- archive counts
- truncated archive counts
- a human-readable recommendation

## validate_archive

Validates a ZIP file, reports entry count, first entries, bad entries, and
whether the end-of-central-directory marker is missing.

## hash_file

Hashes a file with algorithms such as `md5,sha1,sha256`.

## create_workspace

Creates a case folder layout:

- `case`
- `evidence`
- `exports`
- `reports`
- `logs`
- `scripts`
- `scratch`

## triage_inventory

Walks a folder read-only and returns extension counts, total size, largest files,
and optionally SHA-256 hashes for small files.

## build_launch_command

Builds a command array for launching X-Ways without executing it.

## launch_xways

Launches only when `XWAYS_MCP_ALLOW_EXECUTE=1` and `confirm=true`.

## harness_init_case

Creates a `forensic-copilot`-compatible case manifest, Markdown report stub,
status/log directories, and JSONL audit log.

## harness_xwfim_preflight

Runs the XWFIM cache/install validation through the harness. This writes:

- `case-manifest.json`
- `artifacts/xwfim-preflight.json`
- `status/xwfim-cache.status.json`
- `logs/audit.jsonl`
- `reports/<CASE>.md`

## harness_folder_triage

Runs read-only folder inventory through the harness and writes durable artifact,
status, report, and audit files.

## testenv_create

Creates a managed synthetic fixture environment for `windows`, `linux`,
`macos`, `generic`, or `all`. The fixture contains tiny placeholder artifacts and
an optional XWFIM cache state.

## testenv_build

Creates a synthetic fixture and immediately runs harness checks against it.

## testenv_run

Runs harness checks against an existing managed fixture.

## testenv_destroy

Deletes a managed fixture only when `confirm=true` over MCP. The delete logic
refuses directories whose `testenv.json` does not identify them as
`xways-mcp-testenv`.

## testenv_list

Lists managed synthetic fixture environments under a root such as `test-envs/`.

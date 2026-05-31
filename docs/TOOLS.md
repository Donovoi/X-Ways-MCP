# MCP Tools

## environment

Returns platform, Python version, configured search roots, and execution safety
status.

## public_xways_release

Fetches public X-Ways release information from X-Ways pages. This is only a
convenience check; licensed downloads still require the user's X-Ways
credentials.

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

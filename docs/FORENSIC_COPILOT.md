# Forensic Copilot Integration

This repo is designed to plug into `Donovoi/forensic-copilot` as an optional
controlled tooling layer, not as a replacement for its agent loop and not as a
hard dependency.

## Layering

Use this shape:

```text
Forensic Examiner / helper agents
  -> xways-harness
  -> xways-mcp MCP tools and core utilities
  -> X-Ways, XWFIM, scripts, and generated X-Tension bridges
```

`forensic-copilot` keeps authority, scope, evidence handling, peer review, and
Markdown reporting. `xways-mcp` supplies repeatable X-Ways-specific tools and
status artifacts when X-Ways is the selected adapter. Other forensic tool
adapters can use the same manifest/status/alias-map pattern.

See [INTEGRATION_CONTRACT.md](INTEGRATION_CONTRACT.md) for the generic manifest
and loose adapter boundary.

## Compatibility Rules

The harness follows these `forensic-copilot` expectations:

- generic `forensic-case-run-manifest/v1` compatibility
- optional adapter coupling rather than a required dependency
- explicit input/read roots
- explicit compute/staging root
- explicit output/report root
- report stub created early
- status JSON for zero, blocked, partial, or failed collection steps
- JSONL audit log for every harness action
- broad outputs written to files, with terminal output limited to paths/counts
- no plaintext secrets in prompts, terminal dumps, public docs, commits, issues,
  or reports; controlled local-only secret lanes are allowed only when the case
  scope and handling policy authorize them
- launch/execution remains gated separately from inventory and validation
- tool decisions are manual-first: check the newest available official/manual
  docs or approved local docs cache before selecting commands, APIs,
  distributed processing, X-Tensions, or UI fallback
- public release/manual refresh helpers are disabled in no-internet or
  case-sensitive contexts unless policy allows a generic vendor-doc refresh with
  no case facts
- X-Ways automation prefers headless commands/scripts first, native distributed
  RVS when manual-backed, generated X-Tensions next, and UI automation last
- parallel RVS should follow the local X-Ways manual: native distributed
  same-case processing for different evidence objects first, isolated worker
  cases only as fallback
- local-only alias maps, with `.local.json` ignored by git

## OpenCode Flow

The senior tooling specialist can hand off `xways-harness` as a provisioned
execution flow when X-Ways is the selected proprietary Windows tool.

Example provisioner `FLOW:` lines:

```text
FLOW:
- Stage under artifacts/CASE-001 and write reports/CASE-001.md before collection.
- Preflight XWFIM: python -m xways_mcp.harness xwfim-preflight --case-name CASE-001 --xwfim-root <XWFIM_ROOT> --staging-root artifacts --output-root reports --evidence-os Windows --evidence-mode portable-tooling
- Folder triage: python -m xways_mcp.harness folder-triage --case-name CASE-001 --input-root <APPROVED_INPUT_ROOT> --staging-root artifacts --output-root reports --depth triage
- Manual lookup: use `manual_status`, `cache_xways_manual`, and `headless_xways_reference` to retrieve X-Ways command-line/script syntax from the local manual cache.
- Route planning: use `plan_xways_operation` before deciding that a Windows UI runner is necessary.
- Parallel planning: use `plan_parallel_xways_jobs` before launching multiple X-Ways processes; prefer native distributed RVS for different evidence objects in the same `.xfc` case.
- Bridge gaps: if headless coverage is missing but X-Ways API coverage exists, use `create_xtension_scaffold` and record API provenance.
- Record artifact paths, status JSON, audit log, and any blockers in the Markdown report.
- Do not run launch_xways unless scope authorizes execution and XWAYS_MCP_ALLOW_EXECUTE=1.
```

## Codex Flow

In Codex, open `forensic-copilot` as the investigation workspace and add this
repo's MCP server to the available tool set:

```json
{
  "mcpServers": {
    "xways-mcp": {
      "command": "python",
      "args": ["-m", "xways_mcp", "--transport", "stdio"],
      "env": {
        "XWAYS_MCP_ALLOW_EXECUTE": "0",
        "PYTHONIOENCODING": "utf-8"
      }
    }
  }
}
```

For repeatable case runs, prefer the harness CLI because it writes manifests,
status files, and report stubs:

```powershell
python -m xways_mcp.harness xwfim-preflight `
  --case-name CASE-001 `
  --xwfim-root "<XWFIM_ROOT>" `
  --staging-root artifacts `
  --output-root reports `
  --evidence-os Windows `
  --evidence-mode portable-tooling
```

The same harness is also exposed as MCP tools:

- `harness_init_case`
- `harness_xwfim_preflight`
- `harness_folder_triage`

For fixture-only agent tests, use `xways-testenv` or its MCP equivalents:

```text
FLOW:
- Build fixture: python -m xways_mcp.testenv build --name CASE-001 --evidence-os all --root test-envs --force
- Inspect generated reports/status JSON under test-envs/*, but do not treat fixture facts as real evidence.
- Delete fixture: python -m xways_mcp.testenv destroy --name CASE-001 --evidence-os all --root test-envs --missing-ok
```

## Tool Mapping

| Forensic Copilot role | xways-mcp support |
| --- | --- |
| senior tooling specialist | choose X-Ways/XWFIM only when proprietary Windows tooling is justified |
| tool researcher | cite X-Ways docs, X-Tensions API, XWFIM version, release status, and local manual cache status |
| tool provisioner | run `xwfim-preflight`, verify versions/hashes, prepare dry-run launch commands |
| evidence collector | use `folder-triage` and generated X-Tension exports inside approved roots |
| artifact router | route X-Ways exports to timeline, tagged-file, report-table, and parser lanes |
| timeline analyst | consume exported CSV/JSON/Markdown artifacts, not terminal dumps |
| publication redactor | check reports and manifests before sharing; keep repo examples generic |

## Generated X-Tension Bridges

When a task requires in-process X-Ways access, generate a bridge scaffold through
`create_xtension_scaffold`, then expose the finished bridge through the MCP
server while keeping the harness as the policy layer. In-process X-Ways tools
should write export artifacts and status files into the approved case staging
root rather than returning large evidence payloads directly to the agent.

Undocumented API work must be marked as version-bound and locally sourced. Do
not mix case facts, recovery keys, evidence names, or recovered filenames into
public docs, issues, commits, or web queries.

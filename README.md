# X-Ways MCP Server

An MCP server for X-Ways Forensics triage, installation validation, and controlled
automation.

This repo follows the same general idea as `bethington/ghidra-mcp`: put a
specialist desktop analysis tool behind a structured MCP surface so agents can
inspect state, run repeatable workflows, and keep a useful audit trail. The first
version is intentionally a safe control plane. When command-line or scripting
coverage is not enough, runners should generate a small X-Tension bridge for the
specific in-process gap and document the API provenance for future runs.

## Current Capabilities

- Discover X-Ways Forensics, WinHex, X-Ways Imager, and XWFIM executables.
- Validate XWFIM `Temp` downloads and detect truncated ZIPs such as a bad
  `viewer.zip`.
- Hash evidence and downloaded packages with MD5/SHA-1/SHA-256.
- Create repeatable case workspace folders.
- Build read-only triage inventories for mounted folders or exports.
- Run a forensic harness that writes case manifests, report stubs, status JSON,
  and audit logs compatible with `Donovoi/forensic-copilot`.
- Create disposable synthetic test environments for Windows, Linux, macOS, and
  generic evidence fixtures.
- Build X-Ways launch commands without executing them.
- Optionally launch X-Ways when explicitly enabled.
- Fetch public X-Ways release information for quick version checks.
- Cache and search the X-Ways manual locally for command-line, scripting, and
  headless workflow syntax.
- Plan X-Ways operations with a headless-first, native-distributed-RVS,
  X-Tension-next, UI-last policy.
- Generate local X-Tension bridge scaffolds with API notes and build hooks.
- Plan parallel X-Ways processing from the local manual: native distributed
  volume snapshot refinement first, isolated worker cases only as fallback.
- Provide a reusable PowerShell guardrail module for container-first exports,
  manual/action gates, and contemporaneous notes.
- Prefer query-first X-Ways analysis through command-line/script, Export List
  metadata, X-Tensions, reports, or bounded UI before materializing file
  contents.
- Maintain a generic best-practice catalog so notes can record which
  jurisdiction/SOP guidance was followed and why.

## Safety Model

Read-only and dry-run behavior is the default.

`launch_xways` will not execute unless both conditions are true:

- `XWAYS_MCP_ALLOW_EXECUTE=1`
- the tool call passes `confirm=true`

This avoids accidentally starting analysis, imaging, or script workflows while an
agent is still planning.

Automation preference is:

0. Manual first: check the newest available X-Ways manual, official docs, or
   approved local docs cache before deciding command syntax, API behavior,
   distributed processing, X-Tension work, or UI fallback.
1. X-Ways command-line, scripts, saved dialog selections, `Cfg:`, `XT:`, and
   `XTParam:*`.
2. X-Ways native distributed RVS for different evidence objects in the same case
   when the manual supports it.
3. A generated X-Tension bridge when the task needs in-process X-Ways access or
   the API covers something the headless surface cannot.
4. UI automation only as a bounded last resort.

If a runner uses documented or undocumented X-Tensions API behavior, it must
record the symbols, X-Ways version constraints, and provenance in local bridge
notes before using the bridge on real evidence.

X-Ways analysis is query-first. Use command-line/script routes, Export List
metadata, reports, X-Tensions, or bounded UI queries when they can answer the
question without materializing file contents. File-content exports are
container-first only when bytes must leave X-Ways for external tooling.
Metadata-only lists can be exported for planning, but copied/recovered file
contents must first go into an X-Ways evidence file container.

## Requirements

- Python 3.10+
- X-Ways Forensics, WinHex, X-Ways Imager, or XWFIM installed separately
- Windows for real X-Ways launching and executable version inspection

The server itself can run on other platforms for archive validation, hashing, and
folder inventory work.

## Quick Start

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -e ".[dev]"
pytest
python -m xways_mcp --transport stdio
```

Cache the current X-Ways manual locally for offline model lookup:

```powershell
python -m pip install -e ".[dev]"
python -c "from xways_mcp.manual import cache_xways_manual; print(cache_xways_manual(source=r'<XWAYS_ROOT>\manual.pdf'))"
```

To refresh from the public X-Ways manual and official scripting/setup pages:

```powershell
python -c "from xways_mcp.manual import cache_xways_manual; print(cache_xways_manual(download_latest=True, fetch_official_docs=True, refresh=True))"
```

Run the MCP stdio smoke test:

```powershell
python scripts\smoke_mcp.py --search-root "<XWFIM_ROOT>" --public-release
```

Run a forensic-copilot-compatible harness preflight:

```powershell
python -m xways_mcp.harness xwfim-preflight `
  --case-name CASE-001 `
  --xwfim-root "<XWFIM_ROOT>" `
  --staging-root artifacts `
  --output-root reports `
  --evidence-os Windows `
  --evidence-mode portable-tooling
```

Build disposable synthetic fixtures for every supported evidence OS:

```powershell
python -m xways_mcp.testenv build --name CASE-001 --evidence-os all --root test-envs --force
python -m xways_mcp.testenv destroy --name CASE-001 --evidence-os all --root test-envs --missing-ok
```

Configure your MCP client with:

```json
{
  "mcpServers": {
    "xways-mcp": {
      "command": "python",
      "args": ["-m", "xways_mcp", "--transport", "stdio"],
      "env": {
        "XWAYS_HOME": "C:\\xwf",
        "XWAYS_MCP_SEARCH_ROOTS": "<XWAYS_ROOT>;<XWFIM_ROOT>",
        "XWAYS_MCP_ALLOW_EXECUTE": "0",
        "PYTHONIOENCODING": "utf-8"
      }
    }
  }
}
```

## Useful Tools

- `environment`
- `public_xways_release`
- `manual_status`
- `cache_xways_manual`
- `search_xways_manual`
- `headless_xways_reference`
- `plan_xways_operation`
- `plan_parallel_xways_jobs`
- `create_xtension_scaffold`
- `discover_installations`
- `inspect_xwfim_cache`
- `validate_archive`
- `hash_file`
- `create_workspace`
- `triage_inventory`
- `build_launch_command`
- `launch_xways`
- `harness_init_case`
- `harness_xwfim_preflight`
- `harness_folder_triage`
- `testenv_create`
- `testenv_build`
- `testenv_run`
- `testenv_destroy`
- `testenv_list`

See [docs/TOOLS.md](docs/TOOLS.md) for details.
See [docs/FORENSIC_COPILOT.md](docs/FORENSIC_COPILOT.md) for integration with
`Donovoi/forensic-copilot`.
See [docs/TEST_ENVIRONMENTS.md](docs/TEST_ENVIRONMENTS.md) for disposable
synthetic fixture testing.
See [docs/MANUAL_FIRST.md](docs/MANUAL_FIRST.md) for the manual-first tooling
policy.
See [docs/HEADLESS_XWAYS.md](docs/HEADLESS_XWAYS.md) for local manual indexing
and headless command lookup.
See [docs/PARALLEL_PROCESSING.md](docs/PARALLEL_PROCESSING.md) for the
manual-backed distributed processing policy.
See [docs/XTENSION_BRIDGE.md](docs/XTENSION_BRIDGE.md) for the generated
X-Tension bridge workflow.
See [docs/FORENSIC_SOUNDNESS.md](docs/FORENSIC_SOUNDNESS.md) for the
container-first export policy and reusable PowerShell module.
See [docs/BEST_PRACTICES.md](docs/BEST_PRACTICES.md) for the public
best-practice catalog and selection workflow.

## XWFIM Validation Example

```text
inspect_xwfim_cache(path="<XWFIM_ROOT>")
```

This reports each ZIP in `Temp`, whether it can be opened, and whether the ZIP
end-of-central-directory record is missing. That is the signal for a truncated
download.

## Roadmap

1. Stabilize the Python MCP control plane.
2. Add stronger X-Ways script templates for repeatable triage.
3. Add native distributed RVS orchestration for multi-instance same-case runs.
4. Generate operation-specific X-Tension DLL bridges for in-process gaps.
5. Dynamically register X-Tension-backed tools when X-Ways is open.
6. Add reporting workflows for timeline, search hit, and tagged-file exports.

## References

- X-Ways X-Tensions API: <https://www.x-ways.net/forensics/x-tensions/api.html>
- X-Ways manual: <https://www.x-ways.net/winhex/manual.pdf>
- X-Ways scripting: <https://www.x-ways.net/winhex/scripting.html>
- X-Ways command-line setup notes: <https://www.x-ways.net/winhex/setup.html>
- X-Ways release mailing list: <https://www.x-ways.net/winhex/mailings/>

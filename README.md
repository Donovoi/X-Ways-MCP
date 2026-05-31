# X-Ways MCP Server

An MCP server for X-Ways Forensics triage, installation validation, and controlled
automation.

This repo follows the same general idea as `bethington/ghidra-mcp`: put a
specialist desktop analysis tool behind a structured MCP surface so agents can
inspect state, run repeatable workflows, and keep a useful audit trail. The first
version is intentionally a safe control plane. A future X-Tension bridge can add
in-process X-Ways case and evidence-object access.

## Current Capabilities

- Discover X-Ways Forensics, WinHex, X-Ways Imager, and XWFIM executables.
- Validate XWFIM `Temp` downloads and detect truncated ZIPs such as a bad
  `viewer.zip`.
- Hash evidence and downloaded packages with MD5/SHA-1/SHA-256.
- Create repeatable case workspace folders.
- Build read-only triage inventories for mounted folders or exports.
- Run a forensic harness that writes case manifests, report stubs, status JSON,
  and audit logs compatible with `Donovoi/forensic-copilot`.
- Build X-Ways launch commands without executing them.
- Optionally launch X-Ways when explicitly enabled.
- Fetch public X-Ways release information for quick version checks.

## Safety Model

Read-only and dry-run behavior is the default.

`launch_xways` will not execute unless both conditions are true:

- `XWAYS_MCP_ALLOW_EXECUTE=1`
- the tool call passes `confirm=true`

This avoids accidentally starting analysis, imaging, or script workflows while an
agent is still planning.

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

See [docs/TOOLS.md](docs/TOOLS.md) for details.
See [docs/FORENSIC_COPILOT.md](docs/FORENSIC_COPILOT.md) for integration with
`Donovoi/forensic-copilot`.

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
3. Build a small X-Tension DLL bridge for in-process case/evidence metadata.
4. Dynamically register X-Tension-backed tools when X-Ways is open.
5. Add reporting workflows for timeline, search hit, and tagged-file exports.

## References

- X-Ways X-Tensions API: <https://www.x-ways.net/forensics/x-tensions/api.html>
- X-Ways scripting: <https://www.x-ways.net/winhex/scripting.html>
- X-Ways command-line setup notes: <https://www.x-ways.net/winhex/setup.html>
- X-Ways release mailing list: <https://www.x-ways.net/winhex/mailings/>

# Example Forensic Copilot Handoff

This is a generic handoff shape for `Donovoi/forensic-copilot`. Replace
placeholders during a real case and keep real evidence paths out of commits.

```text
FLOW:
- Tool choice: X-Ways/XWFIM is selected for licensed Windows forensic tooling; keep use inside approved roots.
- Preflight: python -m xways_mcp.harness xwfim-preflight --case-name CASE-001 --xwfim-root <XWFIM_ROOT> --staging-root artifacts --output-root reports --evidence-os Windows --evidence-mode portable-tooling
- Triage: python -m xways_mcp.harness folder-triage --case-name CASE-001 --input-root <APPROVED_INPUT_ROOT> --staging-root artifacts --output-root reports --depth triage
- Output: record artifacts/CASE-001/artifacts/*.json, artifacts/CASE-001/status/*.json, artifacts/CASE-001/logs/audit.jsonl, and reports/CASE-001.md.
- Gate: no X-Ways launch or script execution unless separately authorized; leave XWAYS_MCP_ALLOW_EXECUTE=0 by default.
```


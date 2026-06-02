# Loose Integration Contract

`xways-mcp` is a specialized tool adapter. It can work with
`Donovoi/forensic-copilot`, but it must also remain useful on its own.

The shared boundary is a generic case-run manifest, sanitized status artifacts,
and local-only alias maps. `forensic-copilot` can consume those outputs as an
examiner harness, while other runners can use the same contract without adopting
the copilot agent loop.

## Manifest

Use `forensic-case-run-manifest/v1` to declare:

- case id, depth, evidence OS, evidence mode, and timezone basis
- tasking question and optional time window
- input/read roots, compute/staging root, and report/output root
- network and remote-compute policy
- privacy policy, including no case facts to the internet and local-only alias
  maps
- optional specialized tool adapters such as `xways-mcp`
- report, status, audit, structured findings, and alias-map output paths
- SOP/best-practice and contemporaneous-note locations

Static files:

- `schemas/case-run-manifest.schema.json`
- `examples/case-run-manifest.template.json`

MCP helper:

```text
case_run_manifest_template(case_id="CASE-001", adapter_name="xways-mcp")
```

## Adapter Rule

Do not make the examiner harness depend on X-Ways for every case. Route to an
adapter only when the evidence and tool plan justify it.

X-Ways-MCP is appropriate when the selected lane needs X-Ways/XWFIM discovery,
manual lookup, X-Ways launch planning, X-Ways case database metadata, X-Tension
bridges, or X-Ways-specific parallel processing.

Other tools can implement the same pattern later: manifest in, bounded local
execution, sanitized status out, local-only sensitive maps.

## Privacy Boundary

Prefer file-in/file-out helper tools for redaction. Do not pass raw case text,
credentials, evidence names, recovered filenames, or case-sensitive paths
through ordinary prompts or public issue/PR text.

Use:

```text
redaction_status(path="<local-file>")
redact_local_file(input_path="<local-file>", output_path="<sanitized-file>")
```

Alias maps can contain sensitive raw values. They must use `.local.json` and
remain uncommitted.

## Triage Surfaces

Command builders are safe dry runs:

```text
build_case_db_path_string_triage_command()
build_path_usage_pattern_triage_command(jsonl_path="<local-jsonl>", report_directory="<local-reports>")
```

Execution tools require both:

- `XWAYS_MCP_ALLOW_CASE_READ=1`
- `confirm=true`

This separates local case metadata reads from X-Ways process launch, which still
uses the stricter `XWAYS_MCP_ALLOW_EXECUTE=1` gate.

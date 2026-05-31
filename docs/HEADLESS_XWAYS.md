# Headless X-Ways Manual Access

The MCP server can keep the X-Ways manual available to the model without
publishing the manual or exposing case data.

## Policy

- The manual cache is local and gitignored under `tooling/cache/xways-manual`.
- Real evidence, case paths, recovery keys, and recovered filenames must never be
  used as web queries.
- Public documentation refreshes should be limited to official X-Ways URLs.
- Manual search results are small snippets for command syntax lookup, not a
  republished copy of the manual.
- Prefer headless X-Ways operations before any Windows UI automation.
- If X-Ways has documented or locally researched API coverage for a task that
  cannot be done headlessly, generate an X-Tension bridge and document it for
  future runners.

## Execution Preference

Use this order:

1. Command line, scripts, `Dlg:`, `Cfg:`, `XT:`, `XTParam:*`, and saved X-Ways
   settings.
2. Generated X-Tension bridge for in-process case, evidence object, volume
   snapshot, search hit, tag/comment, metadata, or sector-level access.
3. UI automation only as a bounded last resort, with sanitized status reporting.

## Recommended Flow

1. Check the local/manual state:

   ```text
   manual_status(search_roots="<XWAYS_ROOT>", check_online=true)
   ```

2. Cache from the installed X-Ways copy:

   ```text
   cache_xways_manual(source="<XWAYS_ROOT>\\manual.pdf")
   ```

3. Refresh from official public documentation when needed:

   ```text
   cache_xways_manual(download_latest=true, fetch_official_docs=true, refresh=true)
   ```

4. Ask for syntax before building headless commands:

   ```text
   headless_xways_reference(topic="command line parameters scripts XTParam")
   search_xways_manual(query="File header signature search scripting")
   ```

5. Plan the route before falling back to UI:

   ```text
   plan_xways_operation(operation="export volume snapshot metadata")
   ```

6. If the route requires in-process access, generate a bridge scaffold:

   ```text
   create_xtension_scaffold(
     name="volume_snapshot_export",
     purpose="Export volume snapshot metadata to local JSONL",
     documented_symbols="..."
   )
   ```

## Forensic Copilot Integration

`forensic-copilot` should treat `xways-mcp` as the X-Ways-specific retrieval and
execution boundary:

- ask `headless_xways_reference` for command-line and scripting syntax
- ask `plan_xways_operation` before choosing the runner boundary
- call `create_xtension_scaffold` when headless coverage is missing but X-Ways
  API coverage exists
- ask `build_launch_command` for dry-run command arrays
- call `launch_xways` only when execution is explicitly authorized
- write all evidence-derived outputs to the local case workspace, not to prompts
  or public issue/PR text

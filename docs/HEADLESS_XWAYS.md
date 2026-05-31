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
- Manual first: before deciding how to use X-Ways or a supporting program,
  check the newest available official manual/docs or approved local docs cache.
- Prefer headless X-Ways operations before any Windows UI automation.
- If X-Ways has documented or locally researched API coverage for a task that
  cannot be done headlessly, generate an X-Tension bridge and document it for
  future runners.

## Execution Preference

Use this order:

0. Current manual or official/local docs check.
1. Command line, scripts, `Dlg:`, `Cfg:`, `XT:`, `XTParam:*`, and saved X-Ways
   settings.
2. Native distributed RVS for different evidence objects in the same case when
   the local manual supports the task.
3. Generated X-Tension bridge for in-process case, evidence object, volume
   snapshot, search hit, tag/comment, metadata, or sector-level access.
4. UI automation only as a bounded last resort, with sanitized status reporting.

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

6. For RVS, file header signature search, carving, indexing, or similar
   processing, ask for a manual-backed parallel plan:

   ```text
   plan_parallel_xways_jobs(
     case_name="CASE-001",
     evidence_paths="<one path per line>",
     case_path="<same-case.xfc>",
     operation="Refine Volume Snapshot with file header signature search"
   )
   ```

   The current local manual cache supports distributed RVS for different
   evidence objects in the same case, so that route is preferred over isolated
   worker cases when it can be driven safely.

7. If the route requires in-process access, generate a bridge scaffold:

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

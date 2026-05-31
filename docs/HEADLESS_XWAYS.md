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

## Forensic Copilot Integration

`forensic-copilot` should treat `xways-mcp` as the X-Ways-specific retrieval and
execution boundary:

- ask `headless_xways_reference` for command-line and scripting syntax
- ask `build_launch_command` for dry-run command arrays
- call `launch_xways` only when execution is explicitly authorized
- write all evidence-derived outputs to the local case workspace, not to prompts
  or public issue/PR text

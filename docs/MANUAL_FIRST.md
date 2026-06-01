# Manual-First Policy

Before `xways-mcp` chooses how to use X-Ways or any supporting program, the
runner must check the newest available official manual, vendor documentation,
maintained upstream docs, or approved local docs/cache.

This policy exists because X-Ways often already has native command-line,
dialog, distributed-processing, multi-threading, or X-Tension behavior that is
better than a custom workaround.

## Required Order

1. Search the local X-Ways manual/docs cache.
2. Refresh from official public documentation when allowed and no case facts are
   included in the request.
3. Prefer documented native behavior when it solves the problem.
4. Generate an X-Tension only when documented/manual-backed routes do not cover
   the needed in-process operation.
5. Use UI automation only after manual-backed headless, distributed, and
   X-Tension routes are exhausted or explicitly impractical.

## Offline Or Restricted Runs

If the latest documentation cannot be reached, use the newest approved local
manual/docs cache and state that limitation in the plan. Do not pretend a
memory-based answer is current.

## Case-Data Boundary

Never use evidence names, keys, recovered filenames, case paths, screenshots,
or case facts as web queries. Manual refreshes must be generic and limited to
official or upstream sources.

## Action Gate

Before any X-Ways action that changes case state, creates derived output, or
exports data, record:

- the manual section or local manual line reference used for the decision
- whether the action can modify original evidence or only the case/snapshot
- whether file contents are being exported
- whether the destination is an X-Ways evidence file container
- the contemporaneous note location

Use the PowerShell module in
`powershell/XWaysForensicWorkflow` to make this check repeatable.

# Disposable Test Environments

`xways-mcp` includes synthetic disposable fixtures so MCP tools, harness flows,
and Forensic Copilot handoffs can be tested immediately without real evidence,
licensed X-Ways packages, personal data, or system mutation.

These are not virtual machines. They are small directory trees that model
evidence from different operating systems and can be created, used, and deleted
on any runner that supports Python.

## Supported Evidence OS Fixtures

- `windows`
- `linux`
- `macos`
- `generic`
- `all`

Each fixture contains tiny placeholder artifacts such as synthetic log files,
registry placeholders, shell history placeholders, and an XWFIM cache fixture.

## Quick Start

Build and test every supported evidence OS:

```powershell
python -m xways_mcp.testenv build --name CASE-001 --evidence-os all --root test-envs --force
```

List managed environments:

```powershell
python -m xways_mcp.testenv list --root test-envs
```

Delete every generated environment:

```powershell
python -m xways_mcp.testenv destroy --name CASE-001 --evidence-os all --root test-envs --missing-ok
```

## Commands

### create

Creates the fixture directory and manifest but does not run the harness.

```powershell
python -m xways_mcp.testenv create --name CASE-001 --evidence-os windows --root test-envs
```

### run

Runs harness checks against an existing fixture:

```powershell
python -m xways_mcp.testenv run --name CASE-001 --evidence-os windows --root test-envs
```

### build

Creates the fixture and immediately runs:

- `folder-triage`
- `xwfim-preflight`

```powershell
python -m xways_mcp.testenv build --name CASE-001 --evidence-os linux --root test-envs --force
```

### destroy / delete

Deletes a fixture only when its `testenv.json` says it is managed by
`xways-mcp-testenv`.

```powershell
python -m xways_mcp.testenv delete --name CASE-001 --evidence-os linux --root test-envs
```

## XWFIM Cache Modes

Use `--cache` to test updater-cache conditions:

- `empty`: no ZIPs in `Temp`
- `valid`: valid `xways.zip` and `viewer.zip`
- `truncated`: valid `xways.zip` plus intentionally truncated `viewer.zip`

Example:

```powershell
python -m xways_mcp.testenv build --name CASE-001 --evidence-os windows --cache truncated --force
```

## MCP Tools

The same flows are exposed over MCP:

- `testenv_create`
- `testenv_build`
- `testenv_run`
- `testenv_destroy`
- `testenv_list`

`testenv_destroy` requires `confirm=true` when called over MCP.

## Safety Rules

- Fixtures are synthetic and contain no real evidence.
- Deletion refuses unmanaged directories.
- Generated environments live under ignored `test-envs/` by default.
- Harness outputs live under ignored fixture-local `artifacts/` and `reports/`.
- Do not commit generated fixture directories or outputs.

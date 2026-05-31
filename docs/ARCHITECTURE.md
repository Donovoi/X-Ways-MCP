# Architecture

`xways-mcp` starts as a safe MCP control plane around X-Ways Forensics rather than
an in-process replacement for X-Ways internals.

## Phase 1: Control Plane

The Python server exposes tools that can run without loading code into X-Ways:

- discover portable X-Ways, WinHex, X-Ways Imager, and XWFIM executables
- validate XWFIM download caches and catch truncated ZIPs
- hash evidence and downloaded packages
- create repeatable case workspaces
- inventory mounted folders or exported evidence trees
- build X-Ways launch and script commands
- optionally launch X-Ways when explicitly enabled

Execution is off by default. Launching X-Ways requires both
`XWAYS_MCP_ALLOW_EXECUTE=1` and a `confirm=true` tool argument.

## Harness Layer

The harness is the policy and repeatability layer above the MCP/core tools. It
exists so forensic agent workflows such as `Donovoi/forensic-copilot` can call a
small number of command templates and receive durable artifacts:

- `case-manifest.json`
- Markdown report stub
- status JSON files
- JSONL audit log
- triage or preflight JSON outputs

The harness owns scope boundaries and output placement. The MCP tools own the
individual capabilities.

## Disposable Test Environments

`xways-testenv` creates synthetic evidence trees for Windows, Linux, macOS, and
generic evidence on any Python runner. These environments are intentionally
small, disposable, and non-mutating. They let agents test harness behavior,
status-file generation, audit logging, and XWFIM cache diagnostics before any
real evidence is involved.

## Phase 2: X-Tension Bridge

The natural next layer is a small X-Tension DLL loaded inside X-Ways. That bridge
can expose a local named pipe or loopback HTTP endpoint to the Python MCP bridge.
This mirrors the dynamic schema idea from GUI-integrated MCP projects while
respecting X-Ways' extension boundary.

Candidate in-process capabilities:

- list open cases, evidence objects, partitions, and volume snapshots
- enumerate tagged files, comments, report tables, and search hits
- export selected metadata to JSONL
- run safe read-only filters over selected evidence objects
- receive `XTParam:*` launch parameters for reproducible workflows

## Phase 3: Workflow Automation

Once the bridge exists, MCP workflows can combine:

- X-Ways scripts for repeatable setup
- X-Tension callbacks for in-process metadata
- external tools for hashing, carving, YARA, timeline building, and reporting
- case workspace manifests for chain-of-custody friendly audit trails

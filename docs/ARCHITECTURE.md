# Architecture

`xways-mcp` starts as a safe MCP control plane around X-Ways Forensics. The
preferred automation path is manual first, headless next, native distributed RVS
when the manual supports it, generated X-Tension bridge after that, and UI
automation last.

## Phase 1: Control Plane

The Python server exposes tools that can run without loading code into X-Ways:

- check and search the newest available local/official X-Ways manual/docs before
  choosing commands, APIs, distributed modes, X-Tensions, or UI fallback
- discover portable X-Ways, WinHex, X-Ways Imager, and XWFIM executables
- validate XWFIM download caches and catch truncated ZIPs
- hash evidence and downloaded packages
- create repeatable case workspaces
- inventory mounted folders or exported evidence trees
- build X-Ways launch and script commands
- optionally launch X-Ways when explicitly enabled
- plan whether a task should use headless execution, an X-Tension bridge, or a
  last-resort UI path
- plan manual-backed parallel processing, preferring native distributed volume
  snapshot refinement for different evidence objects in the same `.xfc` case

Execution is off by default. Launching X-Ways requires both
`XWAYS_MCP_ALLOW_EXECUTE=1` and a `confirm=true` tool argument.

## Parallel Processing Layer

The local X-Ways manual documents distributed volume snapshot refinement for
different evidence objects in the same case. `xways-mcp` treats that as the
preferred parallel strategy for RVS, file header signature search, carving, and
similar refinement operations.

The scheduler should:

- open the same `.xfc` case copy in multiple instances
- keep one full-access/master session at most
- open other workers in shared/distributed partial read-only mode
- assign different evidence objects to different workers
- bound X-Ways internal worker threads per process so CPU and storage are not
  oversubscribed

Isolated worker cases remain a fallback when the native distributed mode cannot
be driven safely. GPU is not assumed to be native X-Ways functionality; use only
local sidecars or generated bridges after disposable benchmarks.

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

## Phase 2: Generated X-Tension Bridge

The next layer is not a single monolithic DLL. Runners should generate a small
operation-specific X-Tension DLL whenever a task cannot be done through X-Ways
command-line/script/configuration surfaces but can be covered through the
documented or locally researched X-Tensions API.

Generated bridge scaffolds must include:

- a manifest
- API provenance notes
- source code
- build hook
- clear local output policy

Candidate in-process capabilities:

- list open cases, evidence objects, partitions, and volume snapshots
- enumerate tagged files, comments, report tables, and search hits
- export selected metadata to JSONL
- run safe read-only filters over selected evidence objects
- receive `XTParam:*` launch parameters for reproducible workflows
- write local JSONL/CSV/status artifacts into the approved case workspace

Undocumented API usage is allowed only as a local, version-bound bridge decision:
record symbol provenance, calling convention assumptions, X-Ways version, failure
behavior, and why no documented/headless route was sufficient.

## Phase 3: Workflow Automation

Once the bridge exists, MCP workflows can combine:

- X-Ways scripts for repeatable setup
- X-Tension callbacks for in-process metadata
- external tools for hashing, carving, YARA, timeline building, and reporting
- case workspace manifests for chain-of-custody friendly audit trails

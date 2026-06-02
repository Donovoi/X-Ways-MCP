# Forensic Soundness

This project uses a query-first workflow for X-Ways. File-content exports are
container-first only when bytes must leave X-Ways for external tooling.

## Rules

1. Check the local/current X-Ways manual before deciding the action.
2. Record a contemporaneous note before and after each action.
3. Each note must record who, what, why, when, how, the SOP or best-practice
   source followed, and why that source was selected.
4. Never modify original evidence.
5. Prefer X-Ways command line, scripts, saved settings, X-Tensions, Export List
   metadata, reports, and bounded UI queries before materializing file contents.
6. Do not export file contents to an ordinary filesystem folder first.
7. Put selected file contents into an X-Ways evidence file container before
   external parsing or parallel analysis.
8. Metadata-only lists can be exported separately, but they must not copy file
   contents.
9. Derived working copies may be created only from X-Ways query output, a
   container, or a container-derived copy, not directly from original evidence.

## Manual Backing

The local manual cache currently supports these workflow decisions:

- X-Ways Forensics opens disks, interpreted images, virtual memory, and RAM in
  view/read-only mode and is designed to prevent alteration of original
  evidence.
- Evidence file containers preserve file contents and most file-system metadata,
  including name, path, size, attributes/file mode, timestamps, deletion status,
  alternate data stream classification, virtual-file classification, and child
  object context.
- Files selected in the directory browser can be added to an open evidence file
  container.
- Containers can store hashes for copied files and can be closed into an `.e01`
  evidence-file form with an embedded overall hash and a frozen filesystem.
- Export List can export selected directory-browser metadata to TSV, HTML, or
  XML. Its optional "copy files off disk/image" behavior is not approved for this
  workflow unless the output is a container-first route.
- X-Ways command-line/script routes, X-Tensions, Directory Browser metadata, and
  event/search-hit/case-report outputs should be used first when they can answer
  the investigative question without materializing bytes.
- Recover/Copy documents copied/recovered files in `copylog.html` or
  `copylog.txt`, but Recover/Copy to an ordinary filesystem folder is not the
  first export target for file contents.
- The X-Ways Case Log records menu actions, dialogs, progress windows, message
  boxes, screenshots of dialogs, and free-text examiner entries.

## PowerShell Module

Import the reusable guardrail module:

```powershell
Import-Module .\powershell\XWaysForensicWorkflow\XWaysForensicWorkflow.psd1 -Force
```

Start a guarded run:

```powershell
$run = New-XwfForensicRun -CaseRoot '<local-case-workspace>' -RunName 'usage-pattern-analysis'
```

Create a query-first usage-pattern plan:

```powershell
$queryPlan = New-XwfQueryFirstUsagePatternPlan `
  -RunRoot $run.run_root `
  -Purpose 'Use X-Ways query surfaces to build per-machine/per-user usage patterns before materializing file contents.'
```

Create a container-first export plan only if file bytes must leave X-Ways:

```powershell
$exportPlan = New-XwfContainerExportPlan `
  -RunRoot $run.run_root `
  -Purpose 'Materialize carved user-activity artifacts for local parsing.' `
  -SelectionDescription 'Carved and volume-snapshot artifacts relevant to user and machine usage patterns.'
```

Check an action before performing it:

```powershell
Test-XwfForensicAction `
  -Action 'Add selected artifacts to X-Ways evidence file container' `
  -OutputKind Container `
  -ManualReference 'xways-manual.txt lines 6760-6918' `
  -ContainerPath $exportPlan.container_root `
  -ManualGatePassed
```

Plan parallel usage-pattern analysis after the container exists:

```powershell
New-XwfUsagePatternPlan -RunRoot $run.run_root -ContainerPath '<container-or-mounted-container-source>'
```

The module writes JSONL and Markdown contemporaneous notes under the run
workspace. Detailed case facts stay local.

Use `Select-XwfBestPractice` to attach current public SOP/best-practice sources
to the note and record why those sources were selected.

## Query-First Usage Pattern Triage

When the question can be answered from X-Ways case metadata, prefer the local
path-string triage script before exporting files:

```powershell
.\scripts\Invoke-XwfCaseDbPathStringTriage.ps1
```

This script reads the X-Ways case database with shared-read access, uses `rg` as
a local metadata-string prefilter, writes only sanitized findings to the report,
and stores raw machine/user labels only in a `.local.json` alias map. It does
not persist raw snippets and does not copy carved files or evidence contents.

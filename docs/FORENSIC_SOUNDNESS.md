# Forensic Soundness

This project uses a container-first workflow for file-content exports from
X-Ways.

## Rules

1. Check the local/current X-Ways manual before deciding the action.
2. Record a contemporaneous note before and after each action.
3. Each note must record who, what, why, when, how, the SOP or best-practice
   source followed, and why that source was selected.
4. Never modify original evidence.
5. Do not export file contents to an ordinary filesystem folder first.
6. Put selected file contents into an X-Ways evidence file container before
   external parsing or parallel analysis.
7. Metadata-only lists can be exported separately, but they must not copy file
   contents.
8. Derived working copies may be created only from the container, not directly
   from original evidence.

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

Create a container-first export plan:

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

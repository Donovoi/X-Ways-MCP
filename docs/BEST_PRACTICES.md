# Best-Practice Catalog

`data/forensic-best-practices.json` is a local catalog of public forensic
practice sources. It is intentionally generic: do not add case facts, evidence
names, recovery keys, or sensitive paths to it.

## Selection Rule

Every contemporaneous note should record:

- who performed or directed the action
- what was done
- when it was done
- why the action was necessary
- how it was performed
- which X-Ways/manual reference supported it
- which SOP or best-practice source was followed
- why those sources were chosen
- whether the action could change original evidence, case state, or derived
  output

## Jurisdiction Baseline

The default selector uses international ISO guidance as the baseline, then adds
jurisdiction guidance where relevant:

- International: ISO/IEC 27037, 27041, 27042, and 27043 for evidence handling,
  method suitability, analysis/interpretation, and investigation process.
- United States: NIST and SWGDE for preservation, collection, hashing,
  documentation, and tool validation.
- England and Wales: the Forensic Science Regulator statutory code for current
  quality requirements.
- Europe: ENFSI best-practice material for validation and forensic examination
  quality.
- Australia: the Australian Government Investigations Standard for legal
  adherence, decision records, evidence continuity, and exhibit handling.

Legacy guidance, such as the ACPO Good Practice Guide for Digital Evidence, is
kept in the catalog because many digital-forensics SOPs still reference it. It
should not override current statutory, organizational, or jurisdiction-specific
requirements.

## PowerShell Usage

```powershell
Import-Module .\powershell\XWaysForensicWorkflow\XWaysForensicWorkflow.psd1 -Force

$selection = Select-XwfBestPractice `
  -Jurisdiction international,usa,australia `
  -Theme preservation,documentation,chain_of_custody `
  -Reason 'Planning a container-first X-Ways export.'

Add-XwfContemporaneousNote `
  -NotebookPath '<run>\notes\contemporaneous-notes.jsonl' `
  -Category 'decision' `
  -Action 'Selected container-first export route' `
  -How 'Reviewed the local X-Ways manual and the best-practice catalog before export.' `
  -Rationale 'Avoid uncontainered file-content export and preserve auditability.' `
  -ManualReference 'X-Ways manual: Evidence File Containers and Case Log sections.' `
  -BestPracticeReferences $selection.selected `
  -BestPracticeSelectionRationale $selection.selection_rationale `
  -SoundnessCheck @{ original_evidence_modified = $false; file_content_outside_container = $false }
```

Refresh the catalog before a new matter or when jurisdiction changes. Public
refresh searches must not include case details.

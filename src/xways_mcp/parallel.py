from __future__ import annotations

import os
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable

from .core import build_xways_command, json_text, resolve_path, sanitize_case_name


DEFAULT_WORKER_CAP = 8
XWAYS_FORENSICS_THREAD_CAP = 16
GPU_MODES = {"auto", "disabled", "external_sidecar", "xtension_bridge"}
EXECUTION_MODES = {
    "auto",
    "native_distributed_rvs",
    "headless_single_process",
    "multiple_windows_shared_case",
    "isolated_worker_cases",
    "xtension_bridge",
}
RVS_TERMS = {
    "rvs",
    "refine volume snapshot",
    "volume snapshot refinement",
    "file header signature",
    "file carving",
    "carving",
}

MANUAL_FINDINGS = {
    "distributed_rvs": {
        "source": "local X-Ways manual cache",
        "manual_lines": "xways-manual.txt:4593-4606",
        "summary": (
            "X-Ways Forensics supports refining volume snapshots of different evidence objects "
            "of the same case using multiple machines or instances. Workers open the same .xfc "
            "case copy, with all sessions except possibly the master opened in the partial "
            "read-only shared/distributed mode."
        ),
    },
    "logical_search_threads": {
        "source": "local X-Ways manual cache",
        "manual_lines": "xways-manual.txt:5561-5570",
        "summary": (
            "Logical searches can use additional worker threads for evidence objects that are "
            "images or directories. X-Ways Forensics can use up to 16 worker threads depending "
            "on detected CPU cores."
        ),
    },
    "rvs_threads": {
        "source": "local X-Ways manual cache",
        "manual_lines": "xways-manual.txt:8452-8468",
        "summary": (
            "The file-processing part of volume snapshot refinement can use multiple threads "
            "when not applied to a selection. X-Tensions using XT_ProcessItem/XT_ProcessItemEx "
            "are parallelized only when the X-Tension identifies itself as thread-safe."
        ),
    },
    "gpu": {
        "source": "local X-Ways manual cache",
        "manual_lines": "no matches for gpu/cuda/opencl/directx/hardware acceleration",
        "summary": "No native X-Ways GPU processing switch or API was found in the local manual/docs cache.",
    },
}


@dataclass(frozen=True)
class EvidenceJob:
    evidence_id: str
    sequence: int
    batch: int
    slot: int
    evidence_path: str
    workspace: Path
    case_path: Path
    export_dir: Path
    log_dir: Path
    script_dir: Path


def _utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def _split_paths(value: str | Iterable[str]) -> list[str]:
    if isinstance(value, str):
        raw = value.replace(";", "\n").splitlines()
    else:
        raw = list(value)
    return [item.strip().strip('"') for item in raw if str(item).strip()]


def _positive_int(value: str | int | None) -> int:
    try:
        number = int(value or 0)
    except (TypeError, ValueError):
        return 0
    return number if number > 0 else 0


def choose_worker_count(
    evidence_count: int,
    *,
    requested_workers: int = 0,
    max_workers: int = 0,
) -> int:
    """Choose a bounded worker count for parallel X-Ways jobs."""

    if evidence_count < 1:
        raise ValueError("evidence_count must be at least 1")

    env_cap = _positive_int(os.getenv("XWAYS_MCP_MAX_WORKERS"))
    hard_cap = max_workers or env_cap or DEFAULT_WORKER_CAP
    cpu_default = max(1, (os.cpu_count() or 2) - 1)
    target = requested_workers or cpu_default
    return max(1, min(evidence_count, target, hard_cap))


def _job_paths(root: Path, case_id: str, evidence_id: str) -> tuple[Path, Path, Path, Path, Path]:
    workspace = root / case_id / "parallel" / evidence_id
    case_path = workspace / "case" / f"{case_id}-{evidence_id}.xfc"
    export_dir = workspace / "exports"
    log_dir = workspace / "logs"
    script_dir = workspace / "scripts"
    return workspace, case_path, export_dir, log_dir, script_dir


def _make_jobs(
    evidence_paths: list[str],
    *,
    case_id: str,
    workspace_root: Path,
    worker_count: int,
    shared_case_path: Path | None = None,
) -> list[EvidenceJob]:
    jobs: list[EvidenceJob] = []
    for index, evidence_path in enumerate(evidence_paths, start=1):
        evidence_id = f"evidence-{index:04d}"
        batch = ((index - 1) // worker_count) + 1
        slot = ((index - 1) % worker_count) + 1
        workspace, case_path, export_dir, log_dir, script_dir = _job_paths(workspace_root, case_id, evidence_id)
        if shared_case_path is not None:
            case_path = shared_case_path
        jobs.append(
            EvidenceJob(
                evidence_id=evidence_id,
                sequence=index,
                batch=batch,
                slot=slot,
                evidence_path=evidence_path,
                workspace=workspace,
                case_path=case_path,
                export_dir=export_dir,
                log_dir=log_dir,
                script_dir=script_dir,
            )
        )
    return jobs


def _rvs_like(operation: str) -> bool:
    lowered = operation.lower()
    return any(term in lowered for term in RVS_TERMS)


def _select_execution_mode(operation: str, requested_mode: str) -> str:
    if requested_mode != "auto":
        return requested_mode
    if _rvs_like(operation):
        return "native_distributed_rvs"
    return "headless_single_process"


def _gpu_plan(operation: str, gpu_mode: str) -> dict:
    if gpu_mode not in GPU_MODES:
        raise ValueError(f"gpu_mode must be one of: {', '.join(sorted(GPU_MODES))}")

    if gpu_mode == "disabled":
        selected = "disabled"
    elif gpu_mode == "xtension_bridge":
        selected = "x_tension_to_local_gpu_sidecar"
    elif gpu_mode == "external_sidecar":
        selected = "local_external_sidecar"
    else:
        selected = "not_enabled_native_unconfirmed"

    return {
        "requested_mode": gpu_mode,
        "selected_route": selected,
        "xways_native_gpu": "not_assumed",
        "manual_backing": MANUAL_FINDINGS["gpu"],
        "operation": operation,
        "policy": [
            "Do not assume X-Ways itself can use the GPU unless the local manual/API confirms it.",
            "Use GPU only for local, case-scoped sidecar work that preserves evidence boundaries.",
            "Prefer X-Ways native distributed RVS and CPU worker threads first; add GPU only after a disposable benchmark.",
        ],
        "candidate_acceleration": [
            "signature scanning or carving prefilters over local byte ranges",
            "hashing or fuzzy-hash batches where a local GPU implementation is validated",
            "OCR, image/video extraction, or ML classification on already exported local artifacts",
        ],
        "xtension_guidance": (
            "If X-Ways needs in-process access, keep the X-Tension small: enumerate objects, "
            "read approved ranges, and hand work to a local GPU sidecar through case-local files "
            "or local IPC. Do not send evidence-derived data off-host."
        ),
    }


def _redacted_assignment(job: EvidenceJob, include_sensitive_paths: bool, selected_execution: str) -> dict:
    item = {
        "evidence_id": job.evidence_id,
        "sequence": job.sequence,
        "batch": job.batch,
        "slot": job.slot,
        "workspace_id": f"parallel/{job.evidence_id}",
        "worker_mode": selected_execution,
    }
    if include_sensitive_paths:
        item.update(
            {
                "evidence_path": job.evidence_path,
                "workspace": str(job.workspace),
                "case_path": str(job.case_path),
                "export_dir": str(job.export_dir),
                "log_dir": str(job.log_dir),
                "script_dir": str(job.script_dir),
            }
        )
    return item


def _launch_template(execution_mode: str) -> list[str]:
    if execution_mode in {"native_distributed_rvs", "multiple_windows_shared_case"}:
        return [
            "<xways-executable>",
            "<same-shared-case.xfc>",
            "Cfg:<automation-settings.cfg>",
            "Dlg:<refine-volume-snapshot-settings.dlg>",
            "RVS:~",
            "Override:5",
        ]
    if execution_mode == "isolated_worker_cases":
        return [
            "<xways-executable>",
            "<isolated-worker-case.xfc>",
            "<evidence-image>",
            "<worker-script-or-dialog-settings>",
        ]
    if execution_mode == "xtension_bridge":
        return [
            "<xways-executable>",
            "<case.xfc>",
            "XT:<bridge-name>",
            "XTParam:worker:<evidence-id>",
            "XTParam:output:<case-local-output>",
        ]
    return [
        "<xways-executable>",
        "<case.xfc-or-NewCase:path>",
        "AddImage:<evidence-image-or-mask>",
        "Cfg:<automation-settings.cfg>",
        "Dlg:<refine-volume-snapshot-settings.dlg>",
        "RVS:~",
        "Override:5",
    ]


def _headless_command_notes(execution_mode: str) -> list[str]:
    if execution_mode in {"native_distributed_rvs", "multiple_windows_shared_case"}:
        return [
            "Open the same .xfc case copy in each instance.",
            "Use Open Case options/shared distributed mode for every worker except possibly the master session.",
            "Use Cfg: and Dlg: automation settings where possible; the local manual snippets did not confirm a command-line-only switch for choosing the shared/distributed open mode.",
            "Use RVS:~ or RVS:~+ only with settings already staged in WinHex.cfg/.dlg files.",
            "Use Override:5 only when the case password collection is staged locally and BitLocker prompts should be handled without UI.",
        ]
    if execution_mode == "isolated_worker_cases":
        return [
            "Create one case per evidence item, run headless RVS independently, then merge/import evidence objects or reports later.",
            "Use this when native distributed same-case mode cannot be driven safely from the current runner.",
        ]
    return [
        "Use one headless process with AddImage/NewCase and RVS commands.",
        "Use X-Ways internal extra threads before launching extra external workers for the same evidence object.",
    ]


def _case_strategy(selected_execution: str) -> dict:
    if selected_execution in {"native_distributed_rvs", "multiple_windows_shared_case"}:
        return {
            "mode": "same_xfc_distributed_mode",
            "manual_backing": MANUAL_FINDINGS["distributed_rvs"],
            "rules": [
                "Only distribute different evidence objects, not competing refinements of the same object.",
                "Keep one full-access/master session at most; other sessions should use shared/distributed partial read-only mode.",
                "Run the same X-Ways version in all participating instances.",
                "Prefer evidence objects stored on different physical storage when possible.",
                "Re-open an evidence object after its worker completes to see finished refinement results.",
            ],
        }
    if selected_execution == "isolated_worker_cases":
        return {
            "mode": "isolated_case_per_evidence",
            "manual_backing": {
                "source": "fallback policy",
                "summary": "Used only when native distributed same-case mode cannot be driven safely.",
            },
            "rules": [
                "One worker owns one case and one evidence item.",
                "Merge/import artifacts after workers finish.",
                "Expect extra reconciliation work because file/evidence identities may differ across cases.",
            ],
        }
    return {
        "mode": "single_process_headless",
        "manual_backing": {
            "source": "local X-Ways command-line manual",
            "summary": "Command line can create/open cases, add images, and run RVS using staged settings.",
        },
        "rules": [
            "Use staged Cfg:/Dlg: settings.",
            "Use X-Ways internal threads for logical search/RVS where appropriate.",
        ],
    }


def _thread_plan(worker_count: int, requested_extra_threads: int = 0) -> dict:
    cpu_count = os.cpu_count() or 1
    if requested_extra_threads > 0:
        extra_threads = min(requested_extra_threads, XWAYS_FORENSICS_THREAD_CAP)
    else:
        extra_threads = max(0, min(XWAYS_FORENSICS_THREAD_CAP, cpu_count // max(1, worker_count)) - 1)
    return {
        "xways_extra_threads_per_worker": extra_threads,
        "xways_forensics_thread_cap": XWAYS_FORENSICS_THREAD_CAP,
        "cpu_count": cpu_count,
        "manual_backing": [
            MANUAL_FINDINGS["logical_search_threads"],
            MANUAL_FINDINGS["rvs_threads"],
        ],
        "oversubscription_note": (
            "Total parallelism is worker_count times X-Ways internal worker threads. "
            "Keep this bounded by CPU cores and storage throughput."
        ),
    }


def _full_command(
    executable: str,
    job: EvidenceJob,
    *,
    script_path: str = "",
    execution_mode: str = "headless_single_process",
) -> list[str]:
    if execution_mode in {"native_distributed_rvs", "multiple_windows_shared_case"}:
        args: list[str] = [str(resolve_path(executable)), str(job.case_path)]
        if script_path:
            args.append(str(resolve_path(script_path)))
        args.extend(
            [
                "RVS:~",
                "Override:5",
                f"XTParam:worker:{job.evidence_id}",
                f"XTParam:output:{job.export_dir}",
                f"XTParam:log:{job.log_dir}",
            ]
        )
        return args

    script = script_path or str(job.script_dir / "worker.whs")
    return build_xways_command(
        executable,
        case_path=job.case_path,
        evidence_path=job.evidence_path,
        script_path=script,
        xt_params={
            "worker": job.evidence_id,
            "output": str(job.export_dir),
            "log": str(job.log_dir),
        },
    )


def _full_jobs(
    jobs: list[EvidenceJob],
    *,
    executable: str,
    script_path: str,
    selected_execution: str,
) -> list[dict]:
    output = []
    for job in jobs:
        output.append(
            {
                **_redacted_assignment(job, True, selected_execution),
                "launch_command": _full_command(
                    executable,
                    job,
                    script_path=script_path,
                    execution_mode=selected_execution,
                )
                if executable
                else None,
            }
        )
    return output


def _write_worker_readme(path: Path) -> None:
    path.write_text(
        "# Parallel X-Ways Plan\n\n"
        "This directory is generated by xways-mcp. Keep full paths, evidence names, "
        "keys, and recovered filenames local to this workspace.\n",
        encoding="utf-8",
    )


def plan_parallel_xways_jobs(
    *,
    case_name: str,
    evidence_paths: str | Iterable[str],
    workspace_root: str = "artifacts",
    case_path: str = "",
    operation: str = "xways_analysis",
    requested_workers: int = 0,
    max_workers: int = 0,
    xways_extra_threads_per_worker: int = 0,
    execution_mode: str = "auto",
    gpu_mode: str = "auto",
    executable: str = "",
    script_path: str = "",
    allow_shared_case: bool = False,
    include_sensitive_paths: bool = False,
    write_plan: bool = False,
) -> dict:
    """Build a manual-backed parallel X-Ways execution plan without starting X-Ways."""

    if execution_mode not in EXECUTION_MODES:
        raise ValueError(f"execution_mode must be one of: {', '.join(sorted(EXECUTION_MODES))}")

    paths = _split_paths(evidence_paths)
    if not paths:
        raise ValueError("at least one evidence path is required")

    case_id = sanitize_case_name(case_name)
    root = resolve_path(workspace_root)
    worker_count = choose_worker_count(
        len(paths),
        requested_workers=requested_workers,
        max_workers=max_workers,
    )
    selected_execution = _select_execution_mode(operation, execution_mode)
    shared_case_path = resolve_path(case_path) if case_path and selected_execution in {
        "native_distributed_rvs",
        "multiple_windows_shared_case",
    } else None
    jobs = _make_jobs(
        paths,
        case_id=case_id,
        workspace_root=root,
        worker_count=worker_count,
        shared_case_path=shared_case_path,
    )

    warnings = []
    if selected_execution in {"native_distributed_rvs", "multiple_windows_shared_case"}:
        warnings.append("Manual-backed same-case distribution is selected only for different evidence objects.")
        if not case_path:
            warnings.append("Provide case_path before execution so all workers open the same .xfc case copy.")
        if allow_shared_case:
            warnings.append("allow_shared_case acknowledged; this does not permit competing writes to the same evidence object.")
    elif selected_execution == "isolated_worker_cases":
        warnings.append("Using isolated worker cases; plan for later merge/import/reconciliation.")

    batches: list[dict] = []
    for batch_no in sorted({job.batch for job in jobs}):
        batch_jobs = [job for job in jobs if job.batch == batch_no]
        batches.append(
            {
                "batch": batch_no,
                "parallel_slots": len(batch_jobs),
                "jobs": [
                    _redacted_assignment(job, include_sensitive_paths, selected_execution)
                    for job in batch_jobs
                ],
            }
        )

    plan = {
        "created_utc": _utc_now(),
        "case_name": case_name,
        "case_id": case_id,
        "operation": operation,
        "evidence_count": len(jobs),
        "worker_count": worker_count,
        "execution_mode": selected_execution,
        "case_strategy": _case_strategy(selected_execution),
        "scheduling": {
            "policy": "batch_parallel_workers",
            "batch_count": len(batches),
            "worker_cap": max_workers or _positive_int(os.getenv("XWAYS_MCP_MAX_WORKERS")) or DEFAULT_WORKER_CAP,
            "cpu_count": os.cpu_count(),
        },
        "xways_internal_threads": _thread_plan(worker_count, xways_extra_threads_per_worker),
        "launch_template": _launch_template(selected_execution),
        "headless_notes": _headless_command_notes(selected_execution),
        "batches": batches,
        "gpu": _gpu_plan(operation, gpu_mode),
        "manual_findings": MANUAL_FINDINGS,
        "warnings": warnings,
        "case_data_policy": [
            "Keep full evidence paths inside local plan artifacts unless include_sensitive_paths=true is explicitly requested.",
            "Do not print recovery keys, evidence names, recovered filenames, or case-sensitive paths in agent responses.",
            "For native distributed RVS, distribute different evidence objects of the same case through X-Ways' shared/distributed mode.",
            "For isolated fallback cases, merge reports/artifacts after workers finish.",
        ],
    }

    sensitive_plan = dict(plan)
    sensitive_plan["jobs"] = _full_jobs(
        jobs,
        executable=executable,
        script_path=script_path,
        selected_execution=selected_execution,
    )

    if write_plan:
        plan_dir = root / case_id / "parallel"
        plan_dir.mkdir(parents=True, exist_ok=True)
        _write_worker_readme(plan_dir / "README.md")
        plan_path = plan_dir / "parallel-plan.json"
        plan_path.write_text(json_text(sensitive_plan) + "\n", encoding="utf-8")
        plan["plan_written"] = True
        plan["plan_path"] = str(plan_path) if include_sensitive_paths else "<case-local-parallel-plan.json>"
    else:
        plan["plan_written"] = False

    return plan

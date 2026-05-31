from __future__ import annotations

import argparse
import json
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from . import __version__
from .core import (
    discover_executables,
    fetch_public_release,
    hash_file,
    inspect_xwfim_cache,
    json_text,
    sanitize_case_name,
    triage_inventory,
)


@dataclass
class HarnessConfig:
    case_name: str
    staging_root: str
    output_root: str
    input_roots: list[str] = field(default_factory=list)
    depth: str = "triage"
    evidence_os: str = "unknown"
    evidence_mode: str = "unknown"
    runner_boundary: str = "local"


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def resolve(path: str | Path) -> Path:
    return Path(path).expanduser().resolve()


def write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json_text(data) + "\n", encoding="utf-8")


def append_jsonl(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(data, sort_keys=True, default=str) + "\n")


def case_layout(config: HarnessConfig) -> dict[str, Path]:
    case_id = sanitize_case_name(config.case_name)
    root = resolve(config.staging_root) / case_id
    output = resolve(config.output_root)
    return {
        "root": root,
        "artifacts": root / "artifacts",
        "logs": root / "logs",
        "status": root / "status",
        "scripts": root / "scripts",
        "reports": output,
        "report": output / f"{case_id}.md",
        "manifest": root / "case-manifest.json",
        "audit": root / "logs" / "audit.jsonl",
    }


def init_case(config: HarnessConfig, task: str = "") -> dict:
    layout = case_layout(config)
    for key in ("root", "artifacts", "logs", "status", "scripts", "reports"):
        layout[key].mkdir(parents=True, exist_ok=True)

    manifest = {
        "case_name": config.case_name,
        "case_id": sanitize_case_name(config.case_name),
        "created_utc": utc_now(),
        "harness": "xways-mcp",
        "harness_version": __version__,
        "task": task,
        "depth": config.depth,
        "evidence_os": config.evidence_os,
        "evidence_mode": config.evidence_mode,
        "runner_boundary": config.runner_boundary,
        "boundaries": {
            "input_read_roots": [str(resolve(path)) for path in config.input_roots],
            "compute_staging_root": str(resolve(config.staging_root)),
            "output_report_root": str(resolve(config.output_root)),
        },
        "paths": {key: str(value) for key, value in layout.items()},
    }
    write_json(layout["manifest"], manifest)
    append_jsonl(
        layout["audit"],
        {
            "time_utc": utc_now(),
            "action": "init_case",
            "status": "ok",
            "details": {
                "case_name": config.case_name,
                "input_roots": manifest["boundaries"]["input_read_roots"],
            },
        },
    )
    if not layout["report"].exists():
        layout["report"].write_text(report_stub(manifest), encoding="utf-8")
    return manifest


def report_stub(manifest: dict) -> str:
    input_roots = manifest["boundaries"]["input_read_roots"] or ["not specified"]
    lines = [
        f"# {manifest['case_name']} Report",
        "",
        "## Executive Summary",
        "",
        "Pending analysis.",
        "",
        "## Findings",
        "",
        "- Pending.",
        "",
        "## Scope And Boundaries",
        "",
        f"- Depth: {manifest['depth']}",
        f"- Evidence OS: {manifest['evidence_os']}",
        f"- Evidence mode: {manifest['evidence_mode']}",
        f"- Input/read roots: {', '.join(input_roots)}",
        f"- Compute/staging root: {manifest['boundaries']['compute_staging_root']}",
        f"- Output/report root: {manifest['boundaries']['output_report_root']}",
        "",
        "## Evidence Handling",
        "",
        "- Preservation, hashes, and blocker notes will be recorded as collection proceeds.",
        "",
        "## Tools And Validation",
        "",
        f"- Harness: {manifest['harness']} {manifest['harness_version']}",
        f"- Manifest: {manifest['paths']['manifest']}",
        f"- Audit log: {manifest['paths']['audit']}",
        "",
        "## Limitations",
        "",
        "- Pending.",
        "",
    ]
    return "\n".join(lines)


def run_xwfim_preflight(
    config: HarnessConfig,
    xwfim_root: str,
    include_public_release: bool = False,
) -> dict:
    config.input_roots = [xwfim_root]
    manifest = init_case(config, task="XWFIM/X-Ways preflight")
    layout = {key: Path(value) for key, value in manifest["paths"].items()}

    executables = discover_executables([xwfim_root], max_depth=3)
    cache = inspect_xwfim_cache(xwfim_root)
    hashes = []
    for exe in executables:
        if exe.get("kind") == "xwfim":
            hashes.append(hash_file(exe["path"], ("sha256",)))
    release = fetch_public_release() if include_public_release else None
    result = {
        "manifest": manifest,
        "executables": executables,
        "xwfim_cache": cache,
        "hashes": hashes,
        "public_release": release,
    }
    artifact = layout["artifacts"] / "xwfim-preflight.json"
    status = layout["status"] / "xwfim-cache.status.json"
    write_json(artifact, result)
    write_json(status, cache["summary"])
    append_jsonl(
        layout["audit"],
        {
            "time_utc": utc_now(),
            "action": "xwfim_preflight",
            "status": cache["summary"]["status"],
            "details": {
                "artifact": str(artifact),
                "status_file": str(status),
                "archives_found": cache["summary"]["archives_found"],
            },
        },
    )
    return {
        "case": manifest["case_name"],
        "status": cache["summary"]["status"],
        "artifact": str(artifact),
        "status_file": str(status),
        "report": manifest["paths"]["report"],
        "audit": manifest["paths"]["audit"],
        "recommendation": cache["summary"]["recommendation"],
    }


def run_folder_triage(
    config: HarnessConfig,
    input_root: str,
    max_files: int = 5000,
    hash_small_files: bool = False,
) -> dict:
    config.input_roots = [input_root]
    manifest = init_case(config, task="Read-only folder triage")
    layout = {key: Path(value) for key, value in manifest["paths"].items()}

    inventory = triage_inventory(
        input_root,
        max_files=max_files,
        hash_small_files=hash_small_files,
    )
    artifact = layout["artifacts"] / "folder-triage.json"
    status = layout["status"] / "folder-triage.status.json"
    summary = {
        "status": "ok" if not inventory["errors"] else "partial",
        "visited_files": inventory["visited_files"],
        "listed_files": inventory["listed_files"],
        "total_size": inventory["total_size"],
        "truncated": inventory["truncated"],
        "errors": len(inventory["errors"]),
    }
    write_json(artifact, inventory)
    write_json(status, summary)
    append_jsonl(
        layout["audit"],
        {
            "time_utc": utc_now(),
            "action": "folder_triage",
            "status": summary["status"],
            "details": {
                "artifact": str(artifact),
                "status_file": str(status),
                "visited_files": inventory["visited_files"],
            },
        },
    )
    return {
        "case": manifest["case_name"],
        "status": summary["status"],
        "artifact": str(artifact),
        "status_file": str(status),
        "report": manifest["paths"]["report"],
        "audit": manifest["paths"]["audit"],
        "visited_files": inventory["visited_files"],
    }


def common_config(args: argparse.Namespace, input_roots: list[str] | None = None) -> HarnessConfig:
    return HarnessConfig(
        case_name=args.case_name,
        staging_root=args.staging_root,
        output_root=args.output_root,
        input_roots=input_roots or [],
        depth=args.depth,
        evidence_os=args.evidence_os,
        evidence_mode=args.evidence_mode,
        runner_boundary=args.runner_boundary,
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Forensic harness for xways-mcp tools.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    def add_common(sub: argparse.ArgumentParser) -> None:
        sub.add_argument("--case-name", required=True)
        sub.add_argument("--staging-root", default="artifacts")
        sub.add_argument("--output-root", default="reports")
        sub.add_argument("--depth", choices=["triage", "targeted", "comprehensive"], default="triage")
        sub.add_argument("--evidence-os", default="unknown")
        sub.add_argument("--evidence-mode", default="unknown")
        sub.add_argument("--runner-boundary", default="local")

    init = subparsers.add_parser("init-case", help="Create a scoped case manifest, audit log, and report stub.")
    add_common(init)
    init.add_argument("--input-root", action="append", default=[])

    xwfim = subparsers.add_parser("xwfim-preflight", help="Validate an XWFIM/X-Ways updater folder.")
    add_common(xwfim)
    xwfim.add_argument("--xwfim-root", required=True)
    xwfim.add_argument("--public-release", action="store_true")

    folder = subparsers.add_parser("folder-triage", help="Run read-only folder inventory inside scoped roots.")
    add_common(folder)
    folder.add_argument("--input-root", required=True)
    folder.add_argument("--max-files", type=int, default=5000)
    folder.add_argument("--hash-small-files", action="store_true")
    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()
    if args.command == "init-case":
        result = init_case(common_config(args, args.input_root), task="Case initialization")
    elif args.command == "xwfim-preflight":
        result = run_xwfim_preflight(
            common_config(args, [args.xwfim_root]),
            args.xwfim_root,
            include_public_release=args.public_release,
        )
    elif args.command == "folder-triage":
        result = run_folder_triage(
            common_config(args, [args.input_root]),
            args.input_root,
            max_files=args.max_files,
            hash_small_files=args.hash_small_files,
        )
    else:
        parser.error(f"unknown command: {args.command}")
    print(json_text(result))


if __name__ == "__main__":
    main()

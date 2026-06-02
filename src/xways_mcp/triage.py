from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
from pathlib import Path

from .core import json_text


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def script_path(script_name: str) -> Path:
    return repo_root() / "scripts" / script_name


def build_powershell_command(script_name: str, args: list[str] | None = None) -> dict:
    target = script_path(script_name)
    command = ["pwsh", "-NoProfile", "-File", str(target), *(args or [])]
    return {
        "script": str(target),
        "command": command,
        "executes": False,
        "requires": ["PowerShell 7+", "ripgrep (rg) for case-DB path-string triage"],
        "sensitivity_note": "Keep generated commands and artifacts in the local case workspace.",
    }


def case_db_path_string_triage_command(
    search_root: str = "",
    output_root: str = "",
    throttle_limit: int = 8,
    max_matches_per_file: int = 3000,
) -> dict:
    args: list[str] = []
    if search_root:
        args.extend(["-SearchRoot", search_root])
    if output_root:
        args.extend(["-OutputRoot", output_root])
    args.extend(["-ThrottleLimit", str(throttle_limit)])
    args.extend(["-MaxMatchesPerFile", str(max_matches_per_file)])
    result = build_powershell_command("Invoke-XwfCaseDbPathStringTriage.ps1", args)
    result["purpose"] = "Read-only usage-pattern triage from X-Ways case database metadata strings."
    result["output_policy"] = "Sanitized report/JSON plus local-only alias map."
    return result


def path_usage_pattern_triage_command(jsonl_path: str, report_directory: str, run_id: str = "") -> dict:
    args = ["-JsonlPath", jsonl_path, "-ReportDirectory", report_directory]
    if run_id:
        args.extend(["-RunId", run_id])
    result = build_powershell_command("Invoke-XwfPathUsagePatternTriage.ps1", args)
    result["purpose"] = "Summarize metadata-only X-Tension path JSONL into sanitized usage-pattern findings."
    result["output_policy"] = "Raw JSONL remains local; sanitized report and local-only alias map are separate."
    return result


def _case_read_allowed(confirm: bool) -> bool:
    return confirm and os.getenv("XWAYS_MCP_ALLOW_CASE_READ", "0") == "1"


def run_powershell_json(command: list[str], confirm: bool = False, timeout: int = 3600) -> dict:
    if not _case_read_allowed(confirm):
        return {
            "ok": False,
            "dry_run": True,
            "reason": "Set XWAYS_MCP_ALLOW_CASE_READ=1 and pass confirm=true to read local X-Ways case metadata.",
            "command": command,
        }

    if shutil.which("pwsh") is None:
        return {"ok": False, "dry_run": False, "reason": "pwsh was not found on PATH."}

    completed = subprocess.run(
        command,
        check=False,
        capture_output=True,
        text=True,
        timeout=timeout,
        encoding="utf-8",
        errors="replace",
    )
    if completed.returncode != 0:
        return {
            "ok": False,
            "exit_code": completed.returncode,
            "stderr_withheld": True,
            "stdout_preview": completed.stdout[:500],
        }

    text = completed.stdout.strip()
    try:
        parsed = json.loads(text)
    except json.JSONDecodeError:
        parsed = {"raw_stdout_preview": text[:500]}
    return {
        "ok": True,
        "exit_code": completed.returncode,
        "result": parsed,
        "stderr_withheld": True,
    }


def run_case_db_path_string_triage(
    search_root: str = "",
    output_root: str = "",
    throttle_limit: int = 8,
    max_matches_per_file: int = 3000,
    confirm: bool = False,
    timeout: int = 3600,
) -> dict:
    plan = case_db_path_string_triage_command(
        search_root=search_root,
        output_root=output_root,
        throttle_limit=throttle_limit,
        max_matches_per_file=max_matches_per_file,
    )
    return run_powershell_json(plan["command"], confirm=confirm, timeout=timeout)


def run_path_usage_pattern_triage(
    jsonl_path: str,
    report_directory: str,
    run_id: str = "",
    confirm: bool = False,
    timeout: int = 3600,
) -> dict:
    plan = path_usage_pattern_triage_command(jsonl_path=jsonl_path, report_directory=report_directory, run_id=run_id)
    return run_powershell_json(plan["command"], confirm=confirm, timeout=timeout)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Build or run local X-Ways triage helper commands.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    db = subparsers.add_parser("case-db-pathstrings", help="Build or run case-DB path-string triage.")
    db.add_argument("--search-root", default="")
    db.add_argument("--output-root", default="")
    db.add_argument("--throttle-limit", type=int, default=8)
    db.add_argument("--max-matches-per-file", type=int, default=3000)
    db.add_argument("--run", action="store_true")
    db.add_argument("--confirm", action="store_true")

    path = subparsers.add_parser("path-usage", help="Build or run X-Tension JSONL usage-pattern sanitizer.")
    path.add_argument("--jsonl-path", required=True)
    path.add_argument("--report-directory", required=True)
    path.add_argument("--run-id", default="")
    path.add_argument("--run", action="store_true")
    path.add_argument("--confirm", action="store_true")
    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()
    if args.command == "case-db-pathstrings":
        if args.run:
            result = run_case_db_path_string_triage(
                search_root=args.search_root,
                output_root=args.output_root,
                throttle_limit=args.throttle_limit,
                max_matches_per_file=args.max_matches_per_file,
                confirm=args.confirm,
            )
        else:
            result = case_db_path_string_triage_command(
                search_root=args.search_root,
                output_root=args.output_root,
                throttle_limit=args.throttle_limit,
                max_matches_per_file=args.max_matches_per_file,
            )
    elif args.command == "path-usage":
        if args.run:
            result = run_path_usage_pattern_triage(
                jsonl_path=args.jsonl_path,
                report_directory=args.report_directory,
                run_id=args.run_id,
                confirm=args.confirm,
            )
        else:
            result = path_usage_pattern_triage_command(
                jsonl_path=args.jsonl_path,
                report_directory=args.report_directory,
                run_id=args.run_id,
            )
    else:
        parser.error(f"unknown command: {args.command}")
    print(json_text(result))


if __name__ == "__main__":
    main()

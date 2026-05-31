from __future__ import annotations

import argparse
import json
import shutil
import zipfile
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from .core import json_text, sanitize_case_name
from .harness import HarnessConfig, run_folder_triage, run_xwfim_preflight


MANAGED_BY = "xways-mcp-testenv"
SUPPORTED_EVIDENCE_OS = ("windows", "linux", "macos", "generic")


@dataclass(frozen=True)
class TestEnvironment:
    name: str
    evidence_os: str
    root: Path
    input_root: Path
    xwfim_root: Path
    staging_root: Path
    output_root: Path
    manifest: Path


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def resolve(path: str | Path) -> Path:
    return Path(path).expanduser().resolve()


def env_name(name: str, evidence_os: str) -> str:
    safe = sanitize_case_name(name)
    if evidence_os == "generic":
        return safe
    return f"{safe}-{evidence_os}"


def env_paths(root: str | Path, name: str, evidence_os: str) -> TestEnvironment:
    base = resolve(root)
    safe_name = env_name(name, evidence_os)
    env_root = base / safe_name
    return TestEnvironment(
        name=safe_name,
        evidence_os=evidence_os,
        root=env_root,
        input_root=env_root / "input",
        xwfim_root=env_root / "xwfim",
        staging_root=env_root / "artifacts",
        output_root=env_root / "reports",
        manifest=env_root / "testenv.json",
    )


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def write_bytes(path: Path, data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)


def write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json_text(data) + "\n", encoding="utf-8")


def create_zip(path: Path, entries: dict[str, str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(path, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for name, content in entries.items():
            archive.writestr(name, content)


def create_windows_fixture(root: Path) -> None:
    write_text(
        root / "Windows" / "System32" / "winevt" / "Logs" / "Security.evtx.fixture.txt",
        "Synthetic EVTX placeholder. EventID=4624 User=ANALYST Time=2026-01-01T00:00:00Z\n",
    )
    write_text(
        root / "Windows" / "Prefetch" / "XWFIM.EXE-12345678.pf.fixture.txt",
        "Synthetic Prefetch placeholder for XWFIM.EXE.\n",
    )
    write_text(
        root / "Users" / "ANALYST" / "NTUSER.DAT.fixture.txt",
        "Synthetic registry hive placeholder. No real registry data.\n",
    )
    write_text(
        root / "ProgramData" / "Microsoft" / "Windows" / "Start Menu" / "Programs" / "README.fixture.txt",
        "Synthetic Windows Start Menu fixture.\n",
    )


def create_linux_fixture(root: Path) -> None:
    write_text(
        root / "var" / "log" / "auth.log",
        "Jan  1 00:00:00 host-a sshd[100]: Accepted publickey for analyst from 192.0.2.10 port 4242 ssh2\n",
    )
    write_text(root / "var" / "log" / "syslog", "Jan  1 00:01:00 host-a systemd[1]: Started synthetic service.\n")
    write_text(root / "home" / "analyst" / ".bash_history", "whoami\nls -la\n")
    write_text(root / "etc" / "hostname", "HOST-A\n")


def create_macos_fixture(root: Path) -> None:
    write_text(
        root / "private" / "var" / "db" / "diagnostics" / "unified.log.fixture.txt",
        "Synthetic unified log placeholder. process=loginwindow user=analyst\n",
    )
    write_text(root / "Users" / "analyst" / "Library" / "Preferences" / "com.example.fixture.plist", "{}\n")
    write_text(root / "private" / "var" / "db" / "fseventsd" / "0000000000000001.fixture", "synthetic fsevents\n")
    write_text(root / "System" / "Library" / "CoreServices" / "SystemVersion.plist.fixture", "ProductName=macOS\n")


def create_generic_fixture(root: Path) -> None:
    write_text(root / "README.fixture.txt", "Synthetic generic evidence fixture for xways-mcp tests.\n")
    write_text(root / "logs" / "activity.log", "2026-01-01T00:00:00Z synthetic activity\n")
    write_bytes(root / "blob.bin", b"synthetic\x00fixture\n")


def create_xwfim_fixture(root: Path, cache: str) -> None:
    write_text(root / "README.fixture.txt", "Synthetic XWFIM folder. No licensed X-Ways content.\n")
    temp = root / "Temp"
    temp.mkdir(parents=True, exist_ok=True)
    if cache == "empty":
        return
    xways_zip = temp / "xways.zip"
    create_zip(xways_zip, {"setup.exe": "synthetic setup placeholder", "Tooltips.txt": "synthetic"})
    if cache == "valid":
        create_zip(temp / "viewer.zip", {"viewer/readme.txt": "synthetic viewer placeholder"})
    elif cache == "truncated":
        viewer = temp / "viewer.zip"
        create_zip(viewer, {"viewer/readme.txt": "synthetic viewer placeholder"})
        data = viewer.read_bytes()
        viewer.write_bytes(data[:-22])
    else:
        raise ValueError(f"unsupported cache mode: {cache}")


def create_testenv(
    root: str | Path,
    name: str,
    evidence_os: str,
    cache: str = "truncated",
    force: bool = False,
) -> dict:
    if evidence_os not in SUPPORTED_EVIDENCE_OS:
        raise ValueError(f"unsupported evidence_os: {evidence_os}")
    env = env_paths(root, name, evidence_os)
    if env.root.exists():
        if not force:
            raise FileExistsError(f"environment already exists: {env.root}")
        destroy_testenv(root, name, evidence_os, missing_ok=True)

    env.root.mkdir(parents=True, exist_ok=True)
    fixture_root = env.input_root / evidence_os
    if evidence_os == "windows":
        create_windows_fixture(fixture_root)
    elif evidence_os == "linux":
        create_linux_fixture(fixture_root)
    elif evidence_os == "macos":
        create_macos_fixture(fixture_root)
    else:
        create_generic_fixture(fixture_root)
    create_xwfim_fixture(env.xwfim_root, cache=cache)
    env.staging_root.mkdir(parents=True, exist_ok=True)
    env.output_root.mkdir(parents=True, exist_ok=True)

    manifest = {
        "managed_by": MANAGED_BY,
        "created_utc": utc_now(),
        "name": env.name,
        "evidence_os": evidence_os,
        "cache": cache,
        "paths": {
            "root": str(env.root),
            "input_root": str(env.input_root),
            "fixture_root": str(fixture_root),
            "xwfim_root": str(env.xwfim_root),
            "staging_root": str(env.staging_root),
            "output_root": str(env.output_root),
        },
        "notes": [
            "Synthetic fixture only.",
            "No real evidence, licensed X-Ways content, secrets, users, or host data.",
        ],
    }
    write_json(env.manifest, manifest)
    return manifest


def read_manifest(env: TestEnvironment) -> dict:
    if not env.manifest.exists():
        raise FileNotFoundError(f"managed manifest not found: {env.manifest}")
    data = json.loads(env.manifest.read_text(encoding="utf-8"))
    if data.get("managed_by") != MANAGED_BY:
        raise ValueError(f"refusing to manage non-testenv directory: {env.root}")
    return data


def run_testenv(root: str | Path, name: str, evidence_os: str) -> dict:
    env = env_paths(root, name, evidence_os)
    manifest = read_manifest(env)
    case_name = f"{manifest['name']}-HARNESS"
    config = HarnessConfig(
        case_name=case_name,
        staging_root=str(env.staging_root),
        output_root=str(env.output_root),
        input_roots=[manifest["paths"]["fixture_root"]],
        depth="triage",
        evidence_os=evidence_os,
        evidence_mode="synthetic-fixture",
        runner_boundary="local-testenv",
    )
    folder = run_folder_triage(config, manifest["paths"]["fixture_root"], max_files=500, hash_small_files=True)
    xwfim = run_xwfim_preflight(
        HarnessConfig(
            case_name=case_name,
            staging_root=str(env.staging_root),
            output_root=str(env.output_root),
            input_roots=[manifest["paths"]["xwfim_root"]],
            depth="triage",
            evidence_os="Windows",
            evidence_mode="synthetic-xwfim-cache",
            runner_boundary="local-testenv",
        ),
        manifest["paths"]["xwfim_root"],
        include_public_release=False,
    )
    result = {
        "name": manifest["name"],
        "evidence_os": evidence_os,
        "folder_triage": folder,
        "xwfim_preflight": xwfim,
    }
    write_json(env.root / "last-run.json", result)
    return result


def build_testenv(
    root: str | Path,
    name: str,
    evidence_os: str,
    cache: str = "truncated",
    force: bool = False,
) -> dict:
    manifest = create_testenv(root, name, evidence_os, cache=cache, force=force)
    result = run_testenv(root, name, evidence_os)
    return {"manifest": manifest, "run": result}


def destroy_testenv(root: str | Path, name: str, evidence_os: str, missing_ok: bool = False) -> dict:
    env = env_paths(root, name, evidence_os)
    if not env.root.exists():
        if missing_ok:
            return {"deleted": False, "path": str(env.root), "reason": "not found"}
        raise FileNotFoundError(f"environment not found: {env.root}")
    read_manifest(env)
    shutil.rmtree(env.root)
    return {"deleted": True, "path": str(env.root)}


def list_testenvs(root: str | Path) -> dict:
    base = resolve(root)
    envs = []
    if base.exists():
        for manifest_path in sorted(base.glob("*/testenv.json")):
            try:
                data = json.loads(manifest_path.read_text(encoding="utf-8"))
            except json.JSONDecodeError:
                continue
            if data.get("managed_by") == MANAGED_BY:
                envs.append(data)
    return {"root": str(base), "count": len(envs), "environments": envs}


def expand_os(value: str) -> list[str]:
    return list(SUPPORTED_EVIDENCE_OS) if value == "all" else [value]


def run_for_all(args: argparse.Namespace, action) -> dict:
    results = []
    for evidence_os in expand_os(args.evidence_os):
        results.append(action(evidence_os))
    return {"results": results}


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Create and delete disposable xways-mcp test environments.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    def add_env_args(sub: argparse.ArgumentParser) -> None:
        sub.add_argument("--root", default="test-envs")
        sub.add_argument("--name", default="CASE-001")
        sub.add_argument("--evidence-os", choices=(*SUPPORTED_EVIDENCE_OS, "all"), default="windows")

    create = subparsers.add_parser("create", help="Create a synthetic evidence fixture environment.")
    add_env_args(create)
    create.add_argument("--cache", choices=["empty", "valid", "truncated"], default="truncated")
    create.add_argument("--force", action="store_true")

    build = subparsers.add_parser("build", help="Create a fixture environment and immediately run harness checks.")
    add_env_args(build)
    build.add_argument("--cache", choices=["empty", "valid", "truncated"], default="truncated")
    build.add_argument("--force", action="store_true")

    run = subparsers.add_parser("run", help="Run harness checks against an existing fixture environment.")
    add_env_args(run)

    destroy = subparsers.add_parser("destroy", help="Delete a managed fixture environment.")
    add_env_args(destroy)
    destroy.add_argument("--missing-ok", action="store_true")

    delete = subparsers.add_parser("delete", help="Alias for destroy.")
    add_env_args(delete)
    delete.add_argument("--missing-ok", action="store_true")

    subparsers.add_parser("list", help="List managed fixture environments.").add_argument("--root", default="test-envs")
    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()
    if args.command == "create":
        result = run_for_all(
            args,
            lambda evidence_os: create_testenv(args.root, args.name, evidence_os, cache=args.cache, force=args.force),
        )
    elif args.command == "build":
        result = run_for_all(
            args,
            lambda evidence_os: build_testenv(args.root, args.name, evidence_os, cache=args.cache, force=args.force),
        )
    elif args.command == "run":
        result = run_for_all(args, lambda evidence_os: run_testenv(args.root, args.name, evidence_os))
    elif args.command in {"destroy", "delete"}:
        result = run_for_all(
            args,
            lambda evidence_os: destroy_testenv(args.root, args.name, evidence_os, missing_ok=args.missing_ok),
        )
    elif args.command == "list":
        result = list_testenvs(args.root)
    else:
        parser.error(f"unknown command: {args.command}")
    print(json_text(result))


if __name__ == "__main__":
    main()

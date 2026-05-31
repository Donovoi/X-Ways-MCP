from __future__ import annotations

import argparse
import logging
import os

from mcp.server.fastmcp import FastMCP

from . import __version__
from .core import (
    build_xways_command,
    create_case_workspace,
    discover_executables,
    fetch_public_release,
    get_environment,
    hash_file as core_hash_file,
    inspect_xwfim_cache as core_inspect_xwfim_cache,
    json_text,
    launch_xways as core_launch_xways,
    split_path_env,
    triage_inventory as core_triage_inventory,
    validate_zip as core_validate_zip,
)
from .harness import (
    HarnessConfig,
    init_case as harness_init,
    run_folder_triage,
    run_xwfim_preflight,
)
from .manual import (
    cache_xways_manual as core_cache_xways_manual,
    headless_reference as core_headless_reference,
    manual_cache_status as core_manual_cache_status,
    search_manual_index,
)
from .testenv import (
    build_testenv,
    create_testenv,
    destroy_testenv,
    expand_os,
    list_testenvs,
    run_testenv,
)
from .xtension import (
    create_xtension_scaffold as core_create_xtension_scaffold,
    plan_xways_operation as core_plan_xways_operation,
)


mcp = FastMCP("xways-mcp")


def _parse_roots(search_roots: str | None):
    return split_path_env(search_roots) if search_roots else None


@mcp.tool()
def environment() -> str:
    """Return server configuration, platform, and execution safety status."""
    data = get_environment()
    data["version"] = __version__
    return json_text(data)


@mcp.tool()
def public_xways_release(timeout: int = 20) -> str:
    """Fetch the public X-Ways release version from X-Ways web pages."""
    return json_text(fetch_public_release(timeout=timeout))


@mcp.tool()
def manual_status(search_roots: str = "", cache_dir: str = "", check_online: bool = False, timeout: int = 20) -> str:
    """Report local X-Ways manual candidates and the offline manual index status."""
    return json_text(
        core_manual_cache_status(
            search_roots=search_roots,
            cache_dir=cache_dir,
            check_online=check_online,
            timeout=timeout,
        )
    )


@mcp.tool()
def cache_xways_manual(
    source: str = "",
    cache_dir: str = "",
    refresh: bool = False,
    download_latest: bool = False,
    fetch_official_docs: bool = False,
    timeout: int = 30,
) -> str:
    """Cache and index the X-Ways manual locally for offline model lookup."""
    return json_text(
        core_cache_xways_manual(
            source=source,
            cache_dir=cache_dir,
            refresh=refresh,
            download_latest=download_latest,
            fetch_official_docs=fetch_official_docs,
            timeout=timeout,
        )
    )


@mcp.tool()
def search_xways_manual(query: str, cache_dir: str = "", limit: int = 8, max_chars: int = 900) -> str:
    """Search the local X-Ways manual/docs index for command syntax and workflow details."""
    return json_text(search_manual_index(query=query, cache_dir=cache_dir, limit=limit, max_chars=max_chars))


@mcp.tool()
def headless_xways_reference(topic: str = "", cache_dir: str = "", limit: int = 8) -> str:
    """Retrieve local manual snippets relevant to X-Ways command-line and scripting automation."""
    return json_text(core_headless_reference(topic=topic, cache_dir=cache_dir, limit=limit))


@mcp.tool()
def plan_xways_operation(
    operation: str,
    known_headless: bool = False,
    known_xtension_api: bool = False,
    requires_in_process: bool = False,
    allow_ui_fallback: bool = False,
) -> str:
    """Choose the preferred X-Ways route: headless first, X-Tension second, UI last."""
    return json_text(
        core_plan_xways_operation(
            operation,
            known_headless=known_headless,
            known_xtension_api=known_xtension_api,
            requires_in_process=requires_in_process,
            allow_ui_fallback=allow_ui_fallback,
        )
    )


@mcp.tool()
def create_xtension_scaffold(
    name: str,
    output_root: str = "xtensions",
    purpose: str = "",
    api_reference: str = "",
    documented_symbols: str = "",
    undocumented_symbols: str = "",
    force: bool = False,
) -> str:
    """Generate a local X-Tension bridge scaffold with API provenance notes."""
    return json_text(
        core_create_xtension_scaffold(
            name,
            output_root=output_root,
            purpose=purpose,
            api_reference=api_reference,
            documented_symbols=documented_symbols,
            undocumented_symbols=undocumented_symbols,
            force=force,
        )
    )


@mcp.tool()
def discover_installations(search_roots: str = "", max_depth: int = 4) -> str:
    """Discover X-Ways, WinHex, X-Ways Imager, and XWFIM executables."""
    roots = _parse_roots(search_roots)
    return json_text(
        {
            "executables": discover_executables(roots, max_depth=max_depth),
            "searched_roots": [str(p) for p in roots] if roots else None,
        }
    )


@mcp.tool()
def inspect_xwfim_cache(path: str = "") -> str:
    """Validate XWFIM Temp ZIP downloads, including truncated viewer archives."""
    return json_text(core_inspect_xwfim_cache(path or None))


@mcp.tool()
def validate_archive(path: str) -> str:
    """Validate a ZIP archive and report truncation or bad entries."""
    return json_text(core_validate_zip(path))


@mcp.tool()
def hash_file(path: str, algorithms: str = "sha256") -> str:
    """Hash a file using comma-separated algorithms such as md5,sha1,sha256."""
    algos = [item.strip() for item in algorithms.split(",") if item.strip()]
    return json_text(core_hash_file(path, algos or ("sha256",)))


@mcp.tool()
def create_workspace(case_name: str, base_dir: str = "") -> str:
    """Create a case workspace with evidence, export, report, log, and script folders."""
    return json_text(create_case_workspace(base_dir or None, case_name))


@mcp.tool()
def triage_inventory(root: str, max_files: int = 5000, hash_small_files: bool = False) -> str:
    """Create a read-only filesystem triage inventory for a folder or mounted evidence tree."""
    return json_text(core_triage_inventory(root, max_files=max_files, hash_small_files=hash_small_files))


@mcp.tool()
def build_launch_command(
    executable: str,
    case_path: str = "",
    evidence_path: str = "",
    script_path: str = "",
    extra_args: str = "",
    xt_params_json: str = "",
) -> str:
    """Build the X-Ways launch command without executing it."""
    import json

    xt_params = json.loads(xt_params_json) if xt_params_json.strip() else None
    args = build_xways_command(
        executable=executable,
        case_path=case_path or None,
        evidence_path=evidence_path or None,
        script_path=script_path or None,
        extra_args=[item for item in extra_args.splitlines() if item.strip()],
        xt_params=xt_params,
    )
    return json_text({"command": args})


@mcp.tool()
def launch_xways(
    executable: str,
    case_path: str = "",
    evidence_path: str = "",
    script_path: str = "",
    extra_args: str = "",
    xt_params_json: str = "",
    confirm: bool = False,
    wait: bool = False,
) -> str:
    """Launch X-Ways only when XWAYS_MCP_ALLOW_EXECUTE=1 and confirm=true."""
    import json

    xt_params = json.loads(xt_params_json) if xt_params_json.strip() else None
    args = build_xways_command(
        executable=executable,
        case_path=case_path or None,
        evidence_path=evidence_path or None,
        script_path=script_path or None,
        extra_args=[item for item in extra_args.splitlines() if item.strip()],
        xt_params=xt_params,
    )
    return json_text(core_launch_xways(args, confirm=confirm, wait=wait))


def _harness_config(
    case_name: str,
    staging_root: str,
    output_root: str,
    input_roots: list[str] | None = None,
    depth: str = "triage",
    evidence_os: str = "unknown",
    evidence_mode: str = "unknown",
    runner_boundary: str = "local",
) -> HarnessConfig:
    return HarnessConfig(
        case_name=case_name,
        staging_root=staging_root,
        output_root=output_root,
        input_roots=input_roots or [],
        depth=depth,
        evidence_os=evidence_os,
        evidence_mode=evidence_mode,
        runner_boundary=runner_boundary,
    )


@mcp.tool()
def harness_init_case(
    case_name: str,
    input_roots: str = "",
    staging_root: str = "artifacts",
    output_root: str = "reports",
    depth: str = "triage",
    evidence_os: str = "unknown",
    evidence_mode: str = "unknown",
    runner_boundary: str = "local",
) -> str:
    """Create a forensic-copilot-compatible manifest, report stub, and audit log."""
    roots = [line.strip() for line in input_roots.splitlines() if line.strip()]
    result = harness_init(
        _harness_config(
            case_name,
            staging_root,
            output_root,
            input_roots=roots,
            depth=depth,
            evidence_os=evidence_os,
            evidence_mode=evidence_mode,
            runner_boundary=runner_boundary,
        ),
        task="MCP case initialization",
    )
    return json_text(result)


@mcp.tool()
def harness_xwfim_preflight(
    case_name: str,
    xwfim_root: str,
    staging_root: str = "artifacts",
    output_root: str = "reports",
    evidence_os: str = "Windows",
    evidence_mode: str = "portable-tooling",
    depth: str = "triage",
    public_release: bool = False,
) -> str:
    """Run XWFIM preflight and write artifacts, status JSON, report stub, and audit log."""
    result = run_xwfim_preflight(
        _harness_config(
            case_name,
            staging_root,
            output_root,
            input_roots=[xwfim_root],
            depth=depth,
            evidence_os=evidence_os,
            evidence_mode=evidence_mode,
        ),
        xwfim_root,
        include_public_release=public_release,
    )
    return json_text(result)


@mcp.tool()
def harness_folder_triage(
    case_name: str,
    input_root: str,
    staging_root: str = "artifacts",
    output_root: str = "reports",
    depth: str = "triage",
    evidence_os: str = "unknown",
    evidence_mode: str = "mounted-folder",
    max_files: int = 5000,
    hash_small_files: bool = False,
) -> str:
    """Run read-only folder triage and write forensic-copilot-compatible artifacts."""
    result = run_folder_triage(
        _harness_config(
            case_name,
            staging_root,
            output_root,
            input_roots=[input_root],
            depth=depth,
            evidence_os=evidence_os,
            evidence_mode=evidence_mode,
        ),
        input_root,
        max_files=max_files,
        hash_small_files=hash_small_files,
    )
    return json_text(result)


@mcp.tool()
def testenv_create(
    name: str = "CASE-001",
    evidence_os: str = "windows",
    root: str = "test-envs",
    cache: str = "truncated",
    force: bool = False,
) -> str:
    """Create a synthetic disposable fixture environment for windows/linux/macos/generic evidence."""
    results = [create_testenv(root, name, os_name, cache=cache, force=force) for os_name in expand_os(evidence_os)]
    return json_text({"results": results})


@mcp.tool()
def testenv_build(
    name: str = "CASE-001",
    evidence_os: str = "windows",
    root: str = "test-envs",
    cache: str = "truncated",
    force: bool = False,
) -> str:
    """Create a disposable fixture environment and immediately run harness checks."""
    results = [build_testenv(root, name, os_name, cache=cache, force=force) for os_name in expand_os(evidence_os)]
    return json_text({"results": results})


@mcp.tool()
def testenv_run(name: str = "CASE-001", evidence_os: str = "windows", root: str = "test-envs") -> str:
    """Run harness checks against an existing disposable fixture environment."""
    results = [run_testenv(root, name, os_name) for os_name in expand_os(evidence_os)]
    return json_text({"results": results})


@mcp.tool()
def testenv_destroy(
    name: str = "CASE-001",
    evidence_os: str = "windows",
    root: str = "test-envs",
    confirm: bool = False,
    missing_ok: bool = False,
) -> str:
    """Delete a managed disposable fixture environment only when confirm=true."""
    if not confirm:
        return json_text(
            {
                "deleted": False,
                "dry_run": True,
                "reason": "Pass confirm=true to delete a managed test environment.",
                "name": name,
                "evidence_os": evidence_os,
                "root": root,
            }
        )
    results = [destroy_testenv(root, name, os_name, missing_ok=missing_ok) for os_name in expand_os(evidence_os)]
    return json_text({"results": results})


@mcp.tool()
def testenv_list(root: str = "test-envs") -> str:
    """List managed disposable fixture environments."""
    return json_text(list_testenvs(root))


def main() -> None:
    parser = argparse.ArgumentParser(description="X-Ways MCP server")
    parser.add_argument("--transport", choices=["stdio", "sse", "streamable-http"], default="stdio")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=None)
    parser.add_argument("--log-level", default=os.getenv("XWAYS_MCP_LOG_LEVEL", "WARNING"))
    args = parser.parse_args()

    level = getattr(logging, args.log_level.upper(), logging.WARNING)
    logging.basicConfig(level=level)
    logging.getLogger("mcp").setLevel(level)
    logging.getLogger("mcp.server").setLevel(level)
    mcp.settings.host = args.host
    mcp.settings.log_level = args.log_level.upper()
    if args.port:
        mcp.settings.port = args.port
    os.environ.setdefault("PYTHONIOENCODING", "utf-8")

    if args.transport in {"sse", "streamable-http"}:
        endpoint = "/sse" if args.transport == "sse" else "/mcp"
        port = args.port or mcp.settings.port
        print(f"xways-mcp listening at http://{args.host}:{port}{endpoint}", flush=True)

    mcp.run(transport=args.transport)


if __name__ == "__main__":
    main()

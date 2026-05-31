import json
import zipfile
from pathlib import Path

import pytest

from xways_mcp.core import (
    build_xways_command,
    create_case_workspace,
    discover_executables,
    hash_file,
    inspect_xwfim_cache,
    parse_xways_release_page,
    sanitize_case_name,
    triage_inventory,
    validate_zip,
)
from xways_mcp.manual import cache_xways_manual, discover_manual_candidates, search_manual_index
from xways_mcp.parallel import plan_parallel_xways_jobs
from xways_mcp.xtension import create_xtension_scaffold, plan_xways_operation, sanitize_identifier


def test_validate_zip_valid_and_truncated(tmp_path: Path):
    archive = tmp_path / "valid.zip"
    with zipfile.ZipFile(archive, "w") as zf:
        zf.writestr("hello.txt", "hello")

    valid = validate_zip(archive)
    assert valid["valid"] is True
    assert valid["entries"] == 1
    assert valid["eocd_present"] is True

    truncated = tmp_path / "truncated.zip"
    data = archive.read_bytes()
    truncated.write_bytes(data[:-22])

    result = validate_zip(truncated)
    assert result["valid"] is False
    assert result["truncated"] is True


def test_inspect_xwfim_cache_summarizes_archives(tmp_path: Path):
    temp = tmp_path / "Temp"
    temp.mkdir()
    archive = temp / "xways.zip"
    with zipfile.ZipFile(archive, "w") as zf:
        zf.writestr("setup.exe", "hello")
    viewer = temp / "viewer.zip"
    data = archive.read_bytes()
    viewer.write_bytes(data[:-22])

    result = inspect_xwfim_cache(tmp_path)
    assert result["summary"]["archives_found"] == 2
    assert result["summary"]["status"] == "problem"
    assert result["summary"]["truncated_archives"] == 1
    assert "viewer.zip" in result["summary"]["recommendation"]


def test_parse_xways_release_page_from_mailing():
    html = """
    <td><strong>#181: X-Ways Forensics, X-Ways Investigator, WinHex 21.8 released</strong></td>
    <p>This mailing is to announce the availability of version 21.8,
    with official release date May 25, 2026.</p>
    """
    result = parse_xways_release_page("https://example.invalid/mailings", html)
    assert result["version"] == "21.8"
    assert result["release_date"] == "May 25, 2026"


def test_parse_xways_release_page_from_index_card():
    html = """
    <p align="center"><b>X-Ways Forensics<br>
    21.8</b><br><font>&nbsp;NEW&nbsp;</font></p>
    """
    result = parse_xways_release_page("https://example.invalid/forensics", html)
    assert result["version"] == "21.8"


def test_hash_file(tmp_path: Path):
    target = tmp_path / "evidence.bin"
    target.write_bytes(b"abc")

    result = hash_file(target, ("md5", "sha256"))
    assert result["hashes"]["md5"] == "900150983cd24fb0d6963f7d28e17f72"
    assert result["hashes"]["sha256"] == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"


def test_discover_executables_bounded(tmp_path: Path):
    exe = tmp_path / "xwforensics64.exe"
    exe.write_bytes(b"MZ")

    found = discover_executables([tmp_path], max_depth=1)
    assert len(found) == 1
    assert found[0]["kind"] == "xways_forensics"


def test_create_case_workspace(tmp_path: Path):
    workspace = create_case_workspace(tmp_path, "Case 001: USB")
    assert Path(workspace["folders"]["evidence"]).exists()
    assert Path(workspace["manifest"]).exists()
    manifest = json.loads(Path(workspace["manifest"]).read_text(encoding="utf-8"))
    assert manifest["safe_name"] == "Case 001_ USB"


def test_triage_inventory(tmp_path: Path):
    (tmp_path / "a.txt").write_text("one", encoding="utf-8")
    (tmp_path / "b.bin").write_bytes(b"\x00" * 10)

    result = triage_inventory(tmp_path, hash_small_files=True)
    assert result["visited_files"] == 2
    assert result["extension_counts"][".txt"] == 1
    assert any("sha256" in item for item in result["files"])


def test_build_xways_command(tmp_path: Path):
    exe = tmp_path / "xwforensics64.exe"
    exe.write_bytes(b"MZ")
    case = tmp_path / "case.xfc"
    case.write_text("", encoding="utf-8")

    command = build_xways_command(exe, case_path=case, xt_params={"case": "001"})
    assert command[0].endswith("xwforensics64.exe")
    assert any(arg == "XTParam:case:001" for arg in command)


def test_sanitize_case_name_rejects_empty():
    with pytest.raises(ValueError):
        sanitize_case_name("???")


def test_discover_manual_candidates(tmp_path: Path):
    manual = tmp_path / "manual.pdf"
    manual.write_bytes(b"%PDF placeholder")

    found = discover_manual_candidates([tmp_path])

    assert len(found) == 1
    assert found[0]["path"].endswith("manual.pdf")
    assert found[0]["sha256"]


def test_cache_and_search_manual_text_source(tmp_path: Path):
    source = tmp_path / "manual.txt"
    source.write_text(
        "Command Line Parameters\n"
        "The command line can pass a case path, evidence path, scripts, and XTParam values.\n\n"
        "Scripting\n"
        "Automated processing can use script commands for repeatable workflows.\n",
        encoding="utf-8",
    )

    cached = cache_xways_manual(source=str(source), cache_dir=str(tmp_path / "cache"))
    assert cached["ok"] is True
    assert cached["chunks"] >= 1

    result = search_manual_index("command line XTParam", cache_dir=str(tmp_path / "cache"))
    assert result["ok"] is True
    assert result["results"]
    assert "XTParam" in result["results"][0]["snippet"]


def test_plan_xways_operation_prefers_headless():
    result = plan_xways_operation("Run command line script with XTParam values")

    assert result["selected_route"] == "headless_command_or_script"
    assert result["preference_order"][0] == "manual_or_official_docs_first"
    assert result["preference_order"][1] == "headless_command_or_script"
    assert "manual_first_policy" in result
    assert "xtparam" in result["detected_headless_terms"]


def test_plan_xways_operation_escalates_to_xtension():
    result = plan_xways_operation("List open evidence objects and volume snapshot metadata")

    assert result["selected_route"] == "generated_x_tension_bridge"
    assert "evidence object" in result["detected_xtension_terms"]


def test_create_xtension_scaffold(tmp_path: Path):
    result = create_xtension_scaffold(
        "metadata bridge",
        output_root=str(tmp_path),
        purpose="Export synthetic metadata counts.",
        api_reference="local fixture docs",
        documented_symbols="XT_Init\nXWF_GetVSProp",
    )

    root = Path(result["path"])
    assert result["created"] is True
    assert root.name == "metadata_bridge"
    assert (root / "manifest.json").exists()
    assert (root / "README.md").exists()
    assert (root / "API_NOTES.md").exists()
    assert (root / "src" / "metadata_bridge.cpp").exists()

    manifest = json.loads((root / "manifest.json").read_text(encoding="utf-8"))
    assert manifest["execution_policy"][0] == "manual_or_official_docs_first"
    assert manifest["execution_policy"][1] == "headless_command_or_script"
    assert "XT_Init" in manifest["documented_symbols"]

    duplicate = create_xtension_scaffold("metadata bridge", output_root=str(tmp_path))
    assert duplicate["created"] is False


def test_sanitize_identifier_prefixes_digit():
    assert sanitize_identifier("123 bridge").startswith("Xways_")


def test_parallel_plan_prefers_manual_backed_distributed_rvs(tmp_path: Path):
    plan = plan_parallel_xways_jobs(
        case_name="CASE-001",
        evidence_paths="evidence1.e01\nevidence2.e01\nevidence3.e01",
        workspace_root=str(tmp_path),
        case_path=str(tmp_path / "case.xfc"),
        operation="Refine Volume Snapshot with file header signature search",
        requested_workers=2,
    )

    assert plan["execution_mode"] == "native_distributed_rvs"
    assert plan["case_strategy"]["mode"] == "same_xfc_distributed_mode"
    assert plan["worker_count"] == 2
    assert plan["scheduling"]["batch_count"] == 2
    assert plan["manual_findings"]["distributed_rvs"]["manual_lines"] == "xways-manual.txt:4593-4606"


def test_parallel_plan_does_not_assume_native_gpu(tmp_path: Path):
    plan = plan_parallel_xways_jobs(
        case_name="CASE-001",
        evidence_paths="evidence1.e01",
        workspace_root=str(tmp_path),
        operation="file carving",
    )

    assert plan["gpu"]["xways_native_gpu"] == "not_assumed"
    assert plan["gpu"]["selected_route"] == "not_enabled_native_unconfirmed"

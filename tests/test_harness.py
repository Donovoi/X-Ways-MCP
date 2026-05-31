import json
import zipfile
from pathlib import Path

from xways_mcp.harness import HarnessConfig, init_case, run_folder_triage, run_xwfim_preflight


def make_config(tmp_path: Path, case_name: str = "CASE-001") -> HarnessConfig:
    return HarnessConfig(
        case_name=case_name,
        staging_root=str(tmp_path / "artifacts"),
        output_root=str(tmp_path / "reports"),
        evidence_os="Windows",
        evidence_mode="portable-tooling",
    )


def test_init_case_writes_forensic_copilot_boundaries(tmp_path: Path):
    input_root = tmp_path / "evidence"
    input_root.mkdir()
    config = make_config(tmp_path)
    config.input_roots = [str(input_root)]
    manifest = init_case(config, task="test")

    assert Path(manifest["paths"]["manifest"]).exists()
    assert Path(manifest["paths"]["audit"]).exists()
    assert Path(manifest["paths"]["report"]).exists()
    assert manifest["boundaries"]["input_read_roots"] == [str(input_root.resolve())]
    assert manifest["boundaries"]["compute_staging_root"] == str((tmp_path / "artifacts").resolve())


def test_folder_triage_writes_artifact_status_and_audit(tmp_path: Path):
    evidence = tmp_path / "evidence"
    evidence.mkdir()
    (evidence / "file.txt").write_text("hello", encoding="utf-8")

    result = run_folder_triage(make_config(tmp_path), str(evidence), hash_small_files=True)

    artifact = Path(result["artifact"])
    status = Path(result["status_file"])
    audit = Path(result["audit"])
    assert artifact.exists()
    assert status.exists()
    assert audit.exists()
    assert json.loads(status.read_text(encoding="utf-8"))["visited_files"] == 1
    assert "folder_triage" in audit.read_text(encoding="utf-8")


def test_xwfim_preflight_summarizes_truncated_cache(tmp_path: Path):
    xwfim_root = tmp_path / "xwfim"
    temp = xwfim_root / "Temp"
    temp.mkdir(parents=True)
    valid = temp / "xways.zip"
    with zipfile.ZipFile(valid, "w") as zf:
        zf.writestr("setup.exe", "hello")
    (temp / "viewer.zip").write_bytes(valid.read_bytes()[:-22])

    result = run_xwfim_preflight(make_config(tmp_path), str(xwfim_root))

    assert result["status"] == "problem"
    assert "viewer.zip" in result["recommendation"]
    assert Path(result["artifact"]).exists()
    assert Path(result["status_file"]).exists()

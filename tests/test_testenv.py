import json
from pathlib import Path

import pytest

from xways_mcp.testenv import (
    MANAGED_BY,
    build_testenv,
    create_testenv,
    destroy_testenv,
    list_testenvs,
    run_testenv,
)


def test_create_run_and_destroy_windows_testenv(tmp_path: Path):
    root = tmp_path / "test-envs"
    manifest = create_testenv(root, "CASE-001", "windows", cache="truncated")

    env_root = Path(manifest["paths"]["root"])
    assert manifest["managed_by"] == MANAGED_BY
    assert (env_root / "input" / "windows" / "Windows" / "System32" / "winevt" / "Logs").exists()
    assert (env_root / "xwfim" / "Temp" / "viewer.zip").exists()

    result = run_testenv(root, "CASE-001", "windows")
    assert result["folder_triage"]["status"] == "ok"
    assert result["xwfim_preflight"]["status"] == "problem"
    assert (env_root / "last-run.json").exists()

    deleted = destroy_testenv(root, "CASE-001", "windows")
    assert deleted["deleted"] is True
    assert not env_root.exists()


def test_build_testenv_generic_valid_cache(tmp_path: Path):
    result = build_testenv(tmp_path / "envs", "SMOKE", "generic", cache="valid")

    assert result["manifest"]["evidence_os"] == "generic"
    assert result["run"]["folder_triage"]["status"] == "ok"
    assert result["run"]["xwfim_preflight"]["status"] == "ok"


def test_destroy_refuses_unmanaged_directory(tmp_path: Path):
    env_root = tmp_path / "envs" / "CASE-001-windows"
    env_root.mkdir(parents=True)
    (env_root / "testenv.json").write_text(json.dumps({"managed_by": "someone-else"}), encoding="utf-8")

    with pytest.raises(ValueError):
        destroy_testenv(tmp_path / "envs", "CASE-001", "windows")
    assert env_root.exists()


def test_list_testenvs_only_returns_managed(tmp_path: Path):
    create_testenv(tmp_path / "envs", "A", "linux", cache="empty")
    unmanaged = tmp_path / "envs" / "B-windows"
    unmanaged.mkdir()
    (unmanaged / "testenv.json").write_text(json.dumps({"managed_by": "other"}), encoding="utf-8")

    result = list_testenvs(tmp_path / "envs")
    assert result["count"] == 1
    assert result["environments"][0]["evidence_os"] == "linux"

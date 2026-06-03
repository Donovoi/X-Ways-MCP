import csv
import json
import shutil
import subprocess
from pathlib import Path

import pytest


REPO_ROOT = Path(__file__).resolve().parents[1]
DATA_ROOT = REPO_ROOT / "data" / "xwf-external-surface"
MODULE_ROOT = REPO_ROOT / "powershell" / "XWaysForensicWorkflow"


NEW_CMDLETS = {
    "Get-XwfPortableExecutable",
    "Get-XwfPeExternalFunction",
    "Get-XwfPeExport",
    "Get-XwfApiString",
    "Compare-XwfExternalSurface",
    "Export-XwfExternalSurfaceReport",
}


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8-sig") as handle:
        return list(csv.DictReader(handle))


def test_xwf_external_surface_reference_baseline():
    summary = json.loads((DATA_ROOT / "xwf-21.8-x64-summary.json").read_text(encoding="utf-8"))
    exports = read_csv(DATA_ROOT / "xwf-21.8-x64-exports.csv")
    documented_xwf = read_csv(DATA_ROOT / "documented-xwf-functions.csv")
    documented_xt = read_csv(DATA_ROOT / "documented-xt-callbacks.csv")

    assert summary["schema"] == "xwf-external-surface-reference/v1"
    assert summary["version"] == "21.8"
    assert summary["sha256"] == "5d357bdd35a9c6d9cc1564f68430b7ec7a49fc824d1b6a501f42a7fe805358d1"
    assert summary["import_count"] == 613
    assert summary["xwf_export_count"] == 77
    assert summary["documented_xwf_function_count"] == 85
    assert summary["documented_xt_callback_count"] == 15
    assert summary["import_dlls"]["MSIMG32.DLL"] == 3

    assert len(exports) == 77
    assert {row["name"] for row in exports} >= {"XWF_Read", "XWF_GetItemName", "XWF_GetProp"}
    assert len(documented_xwf) == 85
    assert len(documented_xt) == 15
    assert "XWF_EDB" in {item["name"] for item in summary["undocumented_looking_candidates"]}
    assert "XT_error" in {item["name"] for item in summary["undocumented_looking_candidates"]}
    assert "XWF_Write" in set(summary["documented_xwf_missing_exports"])


def test_external_surface_cmdlets_are_documented_and_exported():
    psm1 = (MODULE_ROOT / "XWaysForensicWorkflow.psm1").read_text(encoding="utf-8")
    psd1 = (MODULE_ROOT / "XWaysForensicWorkflow.psd1").read_text(encoding="utf-8")
    external = (MODULE_ROOT / "XwfExternalSurface.ps1").read_text(encoding="utf-8")

    assert "XwfExternalSurface.ps1" in psm1
    for cmdlet in NEW_CMDLETS:
        assert f"'{cmdlet}'" in psm1
        assert f"'{cmdlet}'" in psd1
        assert f"function {cmdlet}" in external

    assert external.count(".SYNOPSIS") >= len(NEW_CMDLETS)
    assert "delay_import" in external
    assert "XWF_EDB" in external


def test_external_surface_docs_link_reference_data():
    docs = (REPO_ROOT / "docs" / "EXTERNAL_SURFACE_ANALYSIS.md").read_text(encoding="utf-8")
    readme = (REPO_ROOT / "README.md").read_text(encoding="utf-8")

    assert "Compare-XwfExternalSurface" in docs
    assert "XWF_EDB" in docs
    assert "XT_error.log" in docs
    assert "613" in docs
    assert "77" in docs
    assert "docs/EXTERNAL_SURFACE_ANALYSIS.md" in readme


def test_powershell_module_exports_external_surface_cmdlets():
    shell = shutil.which("pwsh") or shutil.which("powershell")
    if not shell:
        pytest.skip("PowerShell is not installed")

    manifest = MODULE_ROOT / "XWaysForensicWorkflow.psd1"
    wanted = "@(" + ",".join(f"'{name}'" for name in sorted(NEW_CMDLETS)) + ")"
    command = (
        f"Import-Module '{manifest}' -Force; "
        "$names = @(Get-Command -Module XWaysForensicWorkflow | ForEach-Object Name); "
        f"$wanted = {wanted}; "
        "$missing = @($wanted | Where-Object { $names -notcontains $_ }); "
        "if ($missing.Count) { Write-Error ('Missing cmdlets: ' + ($missing -join ', ')); exit 1 }; "
        "'ok'"
    )

    result = subprocess.run(
        [shell, "-NoProfile", "-Command", command],
        cwd=REPO_ROOT,
        text=True,
        capture_output=True,
        timeout=45,
        check=False,
    )

    assert result.returncode == 0, result.stderr
    assert "ok" in result.stdout

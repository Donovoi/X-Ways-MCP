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

API_BRIDGE_CMDLETS = {
    "Get-XwfApiCatalog",
    "Test-XwfApiInvocation",
    "Invoke-XwfApiFunction",
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


def test_xwf_exported_api_cmdlet_catalog_maps_all_exports():
    exports = read_csv(DATA_ROOT / "xwf-21.8-x64-exports.csv")
    catalog = read_csv(DATA_ROOT / "xwf-21.8-exported-api-cmdlets.csv")

    assert len(catalog) == 77
    assert {row["api_name"] for row in catalog} == {row["name"] for row in exports}
    assert len({row["cmdlet_name"] for row in catalog}) == 77
    assert all(row["requires_in_process_bridge"] == "true" for row in catalog)

    by_api = {row["api_name"]: row for row in catalog}
    assert by_api["XWF_GetItemName"]["cmdlet_name"] == "Get-XwfItemName"
    assert by_api["XWF_GetEvObjProp"]["cmdlet_name"] == "Get-XwfEvidenceObjectProperty"
    assert by_api["XWF_AddComment"]["cmdlet_name"] == "Add-XwfComment"
    assert by_api["XWF_CopyToContainer"]["cmdlet_name"] == "Copy-XwfItemToContainer"
    assert by_api["XWF_Read"]["cmdlet_name"] == "Read-XwfContent"
    assert by_api["XWF_ShouldStop"]["cmdlet_name"] == "Test-XwfStopRequested"
    assert by_api["XWF_Unmount"]["cmdlet_name"] == "Dismount-XwfVolume"
    assert by_api["XWF_AddComment"]["mutates_case"] == "true"
    assert by_api["XWF_Read"]["reads_content"] == "true"


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

    bridge = (MODULE_ROOT / "XwfApiBridge.ps1").read_text(encoding="utf-8")
    generated = (MODULE_ROOT / "XwfExportedApiCmdlets.ps1").read_text(encoding="utf-8")
    catalog = read_csv(DATA_ROOT / "xwf-21.8-exported-api-cmdlets.csv")

    for cmdlet in API_BRIDGE_CMDLETS:
        assert f"'{cmdlet}'" in psm1
        assert f"'{cmdlet}'" in psd1
        assert f"function {cmdlet}" in bridge

    assert "xwf-api-bridge-request/v1" in bridge
    assert "Do not call XWF_* exports from an ordinary PowerShell process" in bridge
    for row in catalog:
        assert f"'{row['cmdlet_name']}'" in psm1
        assert f"'{row['cmdlet_name']}'" in psd1
        assert f"function {row['cmdlet_name']}" in generated


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
    catalog = read_csv(DATA_ROOT / "xwf-21.8-exported-api-cmdlets.csv")
    wanted_names = sorted(NEW_CMDLETS | API_BRIDGE_CMDLETS | {row["cmdlet_name"] for row in catalog})
    wanted = "@(" + ",".join(f"'{name}'" for name in wanted_names) + ")"
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


def test_powershell_xwf_api_cmdlets_emit_validated_bridge_requests(tmp_path: Path):
    shell = shutil.which("pwsh") or shutil.which("powershell")
    if not shell:
        pytest.skip("PowerShell is not installed")

    manifest = MODULE_ROOT / "XWaysForensicWorkflow.psd1"
    outbox = tmp_path / "xwf-api-requests.jsonl"
    command = f"""
    $ErrorActionPreference = 'Stop'
    Import-Module '{manifest}' -Force
    $catalog = @(Get-XwfApiCatalog)
    $read = Get-XwfItemName -Argument @{{ nItemID = 42 }} -Purpose 'pytest read'
    $blockedMutating = $false
    try {{
        Add-XwfComment -Argument @{{ nItemID = 42; lpComment = 'note'; nFlagsHowToAdd = 0 }} -OutboxPath '{outbox}' -ErrorAction Stop
    }} catch {{
        $blockedMutating = $true
    }}
    $mutating = Add-XwfComment -Argument @{{ nItemID = 42; lpComment = 'note'; nFlagsHowToAdd = 0 }} -OutboxPath '{outbox}' -AllowMutating -PassThru
    $blockedContent = $false
    try {{
        Read-XwfContent -Argument @{{ hVolumeOrItem = 1; nOffset = 0; lpBuffer = 'bridge-buffer'; nNumberOfBytesToRead = 16 }} -ErrorAction Stop
    }} catch {{
        $blockedContent = $true
    }}
    $line = Get-Content -Raw -LiteralPath '{outbox}' | ConvertFrom-Json
    [pscustomobject]@{{
        catalog_count = $catalog.Count
        read_schema = $read.schema
        read_api = $read.api_name
        read_cmdlet = $read.cmdlet_name
        mutating_blocked = $blockedMutating
        mutating_schema = $line.schema
        mutating_api = $line.api_name
        mutating_cmdlet = $line.cmdlet_name
        content_blocked = $blockedContent
    }} | ConvertTo-Json -Compress
    """

    result = subprocess.run(
        [shell, "-NoProfile", "-Command", command],
        cwd=REPO_ROOT,
        text=True,
        capture_output=True,
        timeout=45,
        check=False,
    )

    assert result.returncode == 0, result.stderr
    payload = json.loads(result.stdout)
    assert payload["catalog_count"] == 77
    assert payload["read_schema"] == "xwf-api-bridge-request/v1"
    assert payload["read_api"] == "XWF_GetItemName"
    assert payload["read_cmdlet"] == "Get-XwfItemName"
    assert payload["mutating_blocked"] is True
    assert payload["mutating_schema"] == "xwf-api-bridge-request/v1"
    assert payload["mutating_api"] == "XWF_AddComment"
    assert payload["mutating_cmdlet"] == "Add-XwfComment"
    assert payload["content_blocked"] is True

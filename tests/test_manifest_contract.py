from xways_mcp.case_manifest import MANIFEST_SCHEMA_VERSION, manifest_schema, manifest_template
from xways_mcp.harness import HarnessConfig, init_case


def test_manifest_template_is_loose_optional_adapter_contract():
    template = manifest_template(
        case_id="CASE-TEST",
        question="Summarize user activity.",
        evidence_os="Windows",
        evidence_mode="E01",
        adapter_name="xways-mcp",
    )

    assert template["schema"] == MANIFEST_SCHEMA_VERSION
    assert template["case"]["case_id"] == "CASE-TEST"
    assert template["privacy"]["case_facts_to_internet"] is False
    assert template["privacy"]["alias_maps_local_only"] is True
    assert template["tool_adapters"][0]["name"] == "xways-mcp"
    assert template["tool_adapters"][0]["coupling"] == "optional"
    assert template["tool_adapters"][0]["enabled"] is False


def test_manifest_schema_names_generic_adapter_not_copilot_owner():
    schema = manifest_schema()

    assert schema["properties"]["tool_adapters"]["type"] == "array"
    assert "forensic-copilot" not in str(schema).lower()


def test_harness_manifest_adds_contract_fields(tmp_path):
    evidence = tmp_path / "evidence"
    evidence.mkdir()
    config = HarnessConfig(
        case_name="CASE-001",
        staging_root=str(tmp_path / "artifacts"),
        output_root=str(tmp_path / "reports"),
        input_roots=[str(evidence)],
        evidence_os="Windows",
        evidence_mode="E01",
    )

    manifest = init_case(config, task="contract test")

    assert manifest["schema"] == MANIFEST_SCHEMA_VERSION
    assert manifest["tool_profile"]["adapter"] == "xways-mcp"
    assert manifest["tool_profile"]["coupling"] == "optional"
    assert manifest["privacy_policy"]["case_facts_to_internet"] is False
    assert manifest["alias_map_policy"]["local_only"] is True
    assert manifest["integrations"]["forensic_copilot"]["required"] is False

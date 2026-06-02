import os

from xways_mcp.triage import (
    case_db_path_string_triage_command,
    path_usage_pattern_triage_command,
    run_case_db_path_string_triage,
)


def test_case_db_path_string_command_is_dry_command_builder():
    result = case_db_path_string_triage_command(throttle_limit=2, max_matches_per_file=100)

    assert result["executes"] is False
    assert result["command"][0] == "pwsh"
    assert "Invoke-XwfCaseDbPathStringTriage.ps1" in result["script"]
    assert "-ThrottleLimit" in result["command"]
    assert "metadata strings" in result["purpose"]


def test_path_usage_pattern_command_builds_sanitizer():
    result = path_usage_pattern_triage_command("paths.jsonl", "reports", run_id="TEST")

    assert result["executes"] is False
    assert "Invoke-XwfPathUsagePatternTriage.ps1" in result["script"]
    assert "-JsonlPath" in result["command"]
    assert "sanitized" in result["output_policy"].lower()


def test_run_case_db_path_string_triage_requires_case_read_gate(monkeypatch):
    monkeypatch.delenv("XWAYS_MCP_ALLOW_CASE_READ", raising=False)

    result = run_case_db_path_string_triage(confirm=True)

    assert result["ok"] is False
    assert result["dry_run"] is True
    assert "XWAYS_MCP_ALLOW_CASE_READ" in result["reason"]
    assert os.getenv("XWAYS_MCP_ALLOW_CASE_READ") is None

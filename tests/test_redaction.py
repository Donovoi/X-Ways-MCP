from pathlib import Path

from xways_mcp.redaction import redact_case_text, redact_local_file, redaction_status


def test_redact_case_text_replaces_common_sensitive_patterns():
    dummy_recovery_password = "-".join(str(index) * 6 for index in range(1, 9))
    text = (
        "Path C:\\Cases\\Example\\image.E01 had key "
        f"{dummy_recovery_password}."
    )

    result = redact_case_text(text, include_alias_map=False)

    assert result["has_redactions"] is True
    assert dummy_recovery_password not in result["redacted_text"]
    assert "C:\\Cases" not in result["redacted_text"]
    assert result["counts"]["bitlocker_recovery_password"] == 1
    assert result["alias_map"] is None


def test_redact_local_file_writes_sanitized_output_and_local_alias_map(tmp_path: Path):
    source = tmp_path / "input.md"
    source.write_text(
        "Review \\\\HOST\\Share\\Case\\disk.E01 and C:\\Evidence\\disk.E01.",
        encoding="utf-8",
    )

    output = tmp_path / "output.md"
    result = redact_local_file(source, output_path=output, include_alias_map=True)

    assert result["ok"] is True
    assert result["has_redactions"] is True
    assert output.exists()
    sanitized = output.read_text(encoding="utf-8")
    assert "C:\\Evidence" not in sanitized
    assert "\\\\HOST\\Share" not in sanitized
    assert result["alias_map_path"].endswith(".local.json")
    assert Path(result["alias_map_path"]).exists()


def test_redaction_status_counts_without_writing(tmp_path: Path):
    source = tmp_path / "input.txt"
    source.write_text("No sensitive pattern here.", encoding="utf-8")

    result = redaction_status(source)

    assert result["has_redactions"] is False
    assert all(count == 0 for count in result["counts"].values())

from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class RedactionRule:
    name: str
    pattern: re.Pattern[str]
    replacement: str


RULES = (
    RedactionRule(
        "bitlocker_recovery_password",
        re.compile(r"\b(?:\d{6}-){7}\d{6}\b"),
        "[REDACTED-BITLOCKER-RECOVERY-PASSWORD]",
    ),
    RedactionRule(
        "windows_absolute_path",
        re.compile(r"(?<![A-Za-z0-9])(?:[A-Za-z]:\\(?:[^\s<>:\"|?*\r\n]+\\)*[^\s<>:\"|?*\r\n]*)"),
        "[REDACTED-WINDOWS-PATH]",
    ),
    RedactionRule(
        "unc_path",
        re.compile(r"\\\\[A-Za-z0-9_.-]+\\[^\s<>:\"|?*\r\n]+"),
        "[REDACTED-UNC-PATH]",
    ),
    RedactionRule(
        "e01_segment_name",
        re.compile(r"\b[^\s\\/<>:\"|?*\r\n]+\.E(?:01|[0-9]{2})\b", re.IGNORECASE),
        "[REDACTED-EWF-NAME]",
    ),
)


def stable_hash(value: str, length: int = 16) -> str:
    return hashlib.sha256(value.encode("utf-8", errors="replace")).hexdigest()[:length].upper()


def redact_case_text(text: str, include_alias_map: bool = False) -> dict:
    redacted = text
    counts: dict[str, int] = {}
    alias_map: dict[str, list[dict[str, str]]] = {}

    for rule in RULES:
        seen: dict[str, str] = {}

        def replace(match: re.Match[str]) -> str:
            raw = match.group(0)
            alias = seen.get(raw)
            if alias is None:
                alias = f"{rule.replacement.rstrip(']')}-{len(seen) + 1:03d}]"
                seen[raw] = alias
            return alias

        redacted = rule.pattern.sub(replace, redacted)
        counts[rule.name] = len(seen)
        if include_alias_map and seen:
            alias_map[rule.name] = [
                {"alias": alias, "raw": raw, "hash": stable_hash(raw)}
                for raw, alias in sorted(seen.items(), key=lambda item: item[1])
            ]

    return {
        "redacted_text": redacted,
        "counts": counts,
        "has_redactions": any(value > 0 for value in counts.values()),
        "alias_map": alias_map if include_alias_map else None,
        "warning": (
            "Alias maps can contain case-sensitive values and should remain local-only."
            if include_alias_map
            else "Alias map omitted by default."
        ),
    }


def redaction_status(path: str | Path) -> dict:
    target = Path(path).expanduser().resolve()
    text = target.read_text(encoding="utf-8", errors="replace")
    result = redact_case_text(text, include_alias_map=False)
    return {
        "path": str(target),
        "size": target.stat().st_size,
        "has_redactions": result["has_redactions"],
        "counts": result["counts"],
    }


def redact_local_file(
    input_path: str | Path,
    output_path: str | Path | None = None,
    alias_map_path: str | Path | None = None,
    include_alias_map: bool = False,
) -> dict:
    source = Path(input_path).expanduser().resolve()
    if output_path:
        output = Path(output_path).expanduser().resolve()
    else:
        output = source.with_name(f"{source.stem}.sanitized{source.suffix}")

    text = source.read_text(encoding="utf-8", errors="replace")
    result = redact_case_text(text, include_alias_map=include_alias_map)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(result["redacted_text"], encoding="utf-8")

    alias_written = None
    if include_alias_map:
        if alias_map_path:
            alias_output = Path(alias_map_path).expanduser().resolve()
        else:
            alias_output = output.with_name(f"{output.stem}.alias-map.local.json")
        alias_output.parent.mkdir(parents=True, exist_ok=True)
        alias_output.write_text(
            json.dumps(result["alias_map"], indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
        alias_written = str(alias_output)

    return {
        "ok": True,
        "input_path": str(source),
        "output_path": str(output),
        "alias_map_path": alias_written,
        "has_redactions": result["has_redactions"],
        "counts": result["counts"],
        "warning": "Alias maps can contain case-sensitive values and must remain local-only.",
    }

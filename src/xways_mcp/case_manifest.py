from __future__ import annotations

from datetime import datetime, timezone


MANIFEST_SCHEMA_VERSION = "forensic-case-run-manifest/v1"


def manifest_schema() -> dict:
    return {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "$id": "https://github.com/Donovoi/X-Ways-MCP/schemas/forensic-case-run-manifest-v1.json",
        "title": "Forensic Case Run Manifest",
        "type": "object",
        "required": [
            "schema",
            "case",
            "question",
            "boundaries",
            "privacy",
            "tool_adapters",
            "outputs",
            "notes",
        ],
        "properties": {
            "schema": {"const": MANIFEST_SCHEMA_VERSION},
            "created_utc": {"type": "string"},
            "case": {
                "type": "object",
                "required": ["case_id", "depth", "evidence_os", "evidence_mode"],
                "properties": {
                    "case_id": {"type": "string"},
                    "depth": {"enum": ["triage", "targeted", "comprehensive"]},
                    "evidence_os": {"type": "string"},
                    "evidence_mode": {"type": "string"},
                    "timezone": {"type": "string"},
                },
                "additionalProperties": True,
            },
            "question": {
                "type": "object",
                "required": ["summary"],
                "properties": {
                    "summary": {"type": "string"},
                    "time_window": {"type": "object"},
                    "users_or_hosts_of_interest": {"type": "array", "items": {"type": "string"}},
                },
                "additionalProperties": True,
            },
            "boundaries": {
                "type": "object",
                "required": ["input_read_roots", "compute_staging_root", "output_report_root"],
                "properties": {
                    "input_read_roots": {"type": "array", "items": {"type": "string"}},
                    "compute_staging_root": {"type": "string"},
                    "output_report_root": {"type": "string"},
                    "network_policy": {"enum": ["offline", "public_docs_only", "allowed", "unknown"]},
                    "remote_or_cloud_compute": {"enum": ["prohibited", "allowed", "unknown"]},
                },
                "additionalProperties": True,
            },
            "privacy": {
                "type": "object",
                "required": ["case_facts_to_internet", "alias_maps_local_only"],
                "properties": {
                    "case_facts_to_internet": {"type": "boolean"},
                    "alias_maps_local_only": {"type": "boolean"},
                    "redaction_required_before_publication": {"type": "boolean"},
                    "secret_plaintext_lane": {"enum": ["local_only", "prohibited", "allowed_with_authority"]},
                },
                "additionalProperties": True,
            },
            "tool_adapters": {
                "type": "array",
                "items": {
                    "type": "object",
                    "required": ["name", "kind", "enabled", "coupling"],
                    "properties": {
                        "name": {"type": "string"},
                        "kind": {"type": "string"},
                        "enabled": {"type": "boolean"},
                        "coupling": {"enum": ["optional", "required_for_this_run"]},
                        "manual_first": {"type": "boolean"},
                        "execution_allowed": {"type": "boolean"},
                        "status": {"type": "string"},
                    },
                    "additionalProperties": True,
                },
            },
            "outputs": {
                "type": "object",
                "properties": {
                    "report_markdown": {"type": "string"},
                    "status_dir": {"type": "string"},
                    "audit_jsonl": {"type": "string"},
                    "alias_map_local": {"type": "string"},
                    "structured_findings": {"type": "string"},
                },
                "additionalProperties": True,
            },
            "notes": {
                "type": "object",
                "properties": {
                    "sop_basis": {"type": "array", "items": {"type": "string"}},
                    "contemporaneous_notes": {"type": "string"},
                    "limitations": {"type": "array", "items": {"type": "string"}},
                },
                "additionalProperties": True,
            },
        },
        "additionalProperties": True,
    }


def manifest_template(
    case_id: str = "CASE-001",
    question: str = "Summarize the forensic tasking here.",
    evidence_os: str = "unknown",
    evidence_mode: str = "unknown",
    adapter_name: str = "xways-mcp",
) -> dict:
    return {
        "schema": MANIFEST_SCHEMA_VERSION,
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "case": {
            "case_id": case_id or "CASE-001",
            "depth": "triage",
            "evidence_os": evidence_os or "unknown",
            "evidence_mode": evidence_mode or "unknown",
            "timezone": "local timezone pending",
        },
        "question": {
            "summary": question or "Summarize the forensic tasking here.",
            "time_window": {
                "start": "",
                "end": "",
                "basis": "pending",
            },
            "users_or_hosts_of_interest": [],
        },
        "boundaries": {
            "input_read_roots": [],
            "compute_staging_root": "artifacts",
            "output_report_root": "reports",
            "network_policy": "public_docs_only",
            "remote_or_cloud_compute": "prohibited",
        },
        "privacy": {
            "case_facts_to_internet": False,
            "alias_maps_local_only": True,
            "redaction_required_before_publication": True,
            "secret_plaintext_lane": "local_only",
        },
        "tool_adapters": [
            {
                "name": adapter_name or "xways-mcp",
                "kind": "specialized_forensic_tool_adapter",
                "enabled": False,
                "coupling": "optional",
                "manual_first": True,
                "execution_allowed": False,
                "status": "planned",
            }
        ],
        "outputs": {
            "report_markdown": "",
            "status_dir": "",
            "audit_jsonl": "",
            "alias_map_local": "",
            "structured_findings": "",
        },
        "notes": {
            "sop_basis": [],
            "contemporaneous_notes": "",
            "limitations": [],
        },
    }

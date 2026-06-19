#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any

from jsonschema import Draft202012Validator

from c1_common import (
    CONTRACTS_DIR,
    CORE_SHEETS,
    FOLLOWUP_HEADERS,
    FOLLOWUP_SHEETS,
    SEMANTIC_HEADERS,
    ValueExtractionError,
    atomic_write_jsonl,
    atomic_write_text,
    classify_range,
    derive_device,
    dump_yaml,
    extract_value_tuple,
    extract_workbook,
    header_index,
    load_manifest,
    normalize_cell,
    normalize_primitive,
    parse_ds_protocol,
    row_field,
    safe_load_yaml,
    sha256_json,
    sha256_text,
    slot_identity,
    snapshot_file_path,
    stable_json,
    utc_now_iso,
    write_failure_receipt,
)

CONTRACT_JSONL = CONTRACTS_DIR / "semantic-function-contract.jsonl"
L1_ALLOWLIST = CONTRACTS_DIR / "l1-demo-allowlist.yaml"
FOLLOWUP_JSONL = CONTRACTS_DIR / "semantic-followup-transitions.jsonl"
QUARANTINE_JSONL = CONTRACTS_DIR / "semantic-quarantine.jsonl"
FUNCTION_SPEC_YAML = CONTRACTS_DIR / "function-spec-full.yaml"
COVERAGE_REPORT = CONTRACTS_DIR / "semantic-coverage-report.md"

CONTRACT_SCHEMA: dict[str, Any] = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "object",
    "required": [
        "contract_row_id",
        "source_domain",
        "source_sheet",
        "source_row_no",
        "source_row_hash",
        "service",
        "intent",
        "ds_protocol",
        "value",
        "device",
        "action_primitive",
        "slot",
        "slot_keys",
        "action_code",
        "range",
        "fc_flags",
        "clarify_tag",
        "second_turn_refs",
        "redaction_state",
        "example_utterance_hash",
        "example_utterance_kind",
        "external_evidence_ref",
        "evidence_ref_kind",
        "canonical_semantic_id",
        "dedupe_group_id",
        "dedupe_role",
        "exec_tier",
        "risk",
        "range_ref_kind",
        "execution_range_ref",
    ],
    "additionalProperties": False,
    "properties": {
        "contract_row_id": {"type": "string", "pattern": "^c1_[A-Za-z0-9]+_[0-9]{6}$"},
        "source_domain": {"enum": list(CORE_SHEETS)},
        "source_sheet": {"enum": list(CORE_SHEETS)},
        "source_row_no": {"type": "integer", "minimum": 2},
        "source_row_hash": {"type": "string", "pattern": "^[0-9a-f]{64}$"},
        "service": {"type": "string", "minLength": 1},
        "intent": {"type": "string", "minLength": 1},
        "ds_protocol": {"type": "object"},
        "value": {
            "type": "object",
            "required": ["ref", "direct", "offset", "type"],
            "additionalProperties": False,
            "properties": {
                "ref": {"type": "string"},
                "direct": {"type": "string"},
                "offset": {"type": "string"},
                "type": {"type": "string"},
            },
        },
        "device": {"type": "string", "minLength": 1},
        "action_primitive": {"type": "string", "minLength": 1},
        "slot": {"type": "string", "minLength": 1},
        "slot_keys": {"type": "array", "items": {"type": "string"}},
        "action_code": {"type": "string"},
        "range": {"type": "string"},
        "range_class": {"enum": ["none", "placeholder_open", "material_candidate"]},
        "fc_flags": {
            "type": "object",
            "required": ["fuzzy", "free", "fuzzy_hash", "free_hash"],
            "additionalProperties": False,
            "properties": {
                "fuzzy": {"type": "boolean"},
                "free": {"type": "boolean"},
                "fuzzy_hash": {"type": "string"},
                "free_hash": {"type": "string"},
            },
        },
        "clarify_tag": {"enum": ["explicit", "implicit"]},
        "second_turn_refs": {"type": "array", "items": {"type": "string"}},
        "redaction_state": {"const": "example_hash_only"},
        "example_utterance_hash": {"type": "string"},
        "example_utterance_kind": {"enum": ["source_example", "none"]},
        "external_evidence_ref": {"type": "string", "minLength": 1},
        "evidence_ref_kind": {"const": "snapshot"},
        "canonical_semantic_id": {"type": "string", "pattern": "^sem_[0-9a-f]{16}$"},
        "dedupe_group_id": {"type": "string", "pattern": "^dedupe_[0-9a-f]{16}$"},
        "dedupe_role": {"enum": ["primary", "variant"]},
        "primary_selection_rule_version": {"const": "v1:complete-ds-action-code-then-source-order"},
        "exec_tier": {"enum": ["L1", "L2"]},
        "risk": {"const": ""},
        "range_ref_kind": {"enum": ["concrete", "generic", "none"]},
        "execution_range_ref": {"type": "string"},
    },
}


def nonempty_hash(value: str) -> str:
    return sha256_text(value) if value else ""


def classify_semantic_row(
    manifest: dict[str, Any],
    sheet_name: str,
    row: dict[str, Any],
    header_map: dict[str, int],
) -> tuple[str, dict[str, Any]]:
    """Classify one source row as ('valid', record) or ('quarantine', record).

    Pure decision unit extracted from build_semantic_rows so quarantine logic is
    unit-testable (scripts/test_quarantine.py). Behavior is byte-identical to the
    prior inline loop, guarded by `make verify` regen + git diff --exit-code.
    """
    row_no = row["row_no"]
    row_values = row["values"]
    source_row_hash = sha256_json({"sheet": sheet_name, "row_no": row_no, "values": row_values})
    function_text = row_values[header_map["function_text"]]
    ds_text = row_values[header_map["ds_protocol"]]
    if not row["nonblank"] or not function_text or not ds_text:
        return "quarantine", quarantine_record(manifest, sheet_name, row_no, source_row_hash, "empty_semantics")
    try:
        ds_protocol = parse_ds_protocol(ds_text)
        service = normalize_cell(ds_protocol.get("service")) or sheet_name
        intent = normalize_cell(ds_protocol.get("intent"))
        slots = ds_protocol.get("semantic", {}).get("slots", {})
        if not isinstance(slots, dict):
            raise ValueError("semantic.slots is not an object")
        value = extract_value_tuple(slots, sheet_name, row_no)
    except ValueExtractionError:
        raise
    except Exception as exc:
        return "quarantine", quarantine_record(
            manifest, sheet_name, row_no, source_row_hash, "malformed", detail=str(exc)
        )
    if not service or not intent:
        return "quarantine", quarantine_record(
            manifest, sheet_name, row_no, source_row_hash, "malformed", detail="missing service or intent"
        )
    action_code = row_values[header_map["action_code"]]
    slot, slot_keys = slot_identity(slots)
    semantic_range = row_values[header_map["semantic_range"]]
    fc_fuzzy = row_values[header_map["fc_fuzzy"]]
    fc_free = row_values[header_map["fc_free"]]
    example = row_values[header_map["example_utterance"]]
    canonical_basis = {"service": service, "function_text": function_text}
    canonical_hash = sha256_json(canonical_basis)[:16]
    return "valid", {
        "contract_row_id": f"c1_{sheet_name}_{row_no:06d}",
        "source_domain": sheet_name,
        "source_sheet": sheet_name,
        "source_row_no": row_no,
        "source_row_hash": source_row_hash,
        "service": service,
        "intent": intent,
        "ds_protocol": ds_protocol,
        "value": value,
        "device": derive_device(intent),
        "action_primitive": normalize_primitive(action_code, intent),
        "slot": slot,
        "slot_keys": slot_keys,
        "action_code": action_code,
        "range": semantic_range,
        "range_class": classify_range(semantic_range),
        "fc_flags": {
            "fuzzy": bool(fc_fuzzy),
            "free": bool(fc_free),
            "fuzzy_hash": nonempty_hash(fc_fuzzy),
            "free_hash": nonempty_hash(fc_free),
        },
        "clarify_tag": "implicit" if fc_fuzzy or fc_free else "explicit",
        "second_turn_refs": [],
        "redaction_state": "example_hash_only",
        "example_utterance_hash": nonempty_hash(example),
        "example_utterance_kind": "source_example" if example else "none",
        "external_evidence_ref": (
            f"snapshot:{manifest['snapshot_id']}:semantic_protocol_edit:{sheet_name}:{row_no}"
        ),
        "evidence_ref_kind": "snapshot",
        "canonical_semantic_id": f"sem_{canonical_hash}",
        "dedupe_group_id": f"dedupe_{canonical_hash}",
        "dedupe_role": "variant",
        "primary_selection_rule_version": "v1:complete-ds-action-code-then-source-order",
        "exec_tier": "L2",
        "risk": "",
        "range_ref_kind": "none",
        "execution_range_ref": "",
    }


def build_semantic_rows(manifest: dict[str, Any]) -> tuple[list[dict[str, Any]], list[dict[str, Any]], dict[str, Any]]:
    source_file = snapshot_file_path(manifest, "semantic_protocol_edit")
    sheets = extract_workbook(source_file, CORE_SHEETS)
    valid_rows: list[dict[str, Any]] = []
    quarantine: list[dict[str, Any]] = []
    source_stats: dict[str, Any] = {}

    for sheet_name in CORE_SHEETS:
        sheet = sheets[sheet_name]
        header_map = {key: header_index(sheet.headers, header) for key, header in SEMANTIC_HEADERS.items()}
        source_stats[sheet_name] = {
            "source_rows": len(sheet.rows),
            "merged_ranges_count": sheet.merged_ranges_count,
            "merged_filled_cells_count": sheet.merged_filled_cells_count,
            "formula_cells_count": sheet.formula_cells_count,
            "calculate_dimension": sheet.calculate_dimension,
        }
        for row in sheet.rows:
            kind, record = classify_semantic_row(manifest, sheet_name, row, header_map)
            if kind == "quarantine":
                quarantine.append(record)
            else:
                valid_rows.append(record)

    by_canonical: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for row in valid_rows:
        by_canonical[row["canonical_semantic_id"]].append(row)
    for group in by_canonical.values():
        group.sort(key=lambda row: (0 if row["action_code"] else 1, row["source_domain"], row["source_row_no"]))
        group[0]["dedupe_role"] = "primary"

    valid_rows.sort(key=lambda row: (row["source_domain"], row["source_row_no"]))
    quarantine.sort(key=lambda row: (row["source_sheet"], row["source_row_no"]))
    return valid_rows, quarantine, source_stats


def quarantine_record(
    manifest: dict[str, Any],
    sheet: str,
    row_no: int,
    source_row_hash: str,
    reason: str,
    detail: str = "",
) -> dict[str, Any]:
    return {
        "source_sheet": sheet,
        "source_row_no": row_no,
        "source_row_hash": source_row_hash,
        "reason": reason,
        "detail": detail,
        "external_evidence_ref": f"snapshot:{manifest['snapshot_id']}:semantic_protocol_edit:{sheet}:{row_no}",
    }


def build_followup_rows(
    manifest: dict[str, Any],
    contract_rows: list[dict[str, Any]],
) -> tuple[list[dict[str, Any]], dict[str, list[str]], dict[str, Any]]:
    followup_file = snapshot_file_path(manifest, "followup_function_list")
    sheets = extract_workbook(followup_file, FOLLOWUP_SHEETS)
    primary_by_intent: dict[tuple[str, str], str] = {}
    for row in contract_rows:
        if row["dedupe_role"] != "primary":
            continue
        key = (row["service"], row["intent"])
        primary_by_intent.setdefault(key, row["canonical_semantic_id"])

    transitions: list[dict[str, Any]] = []
    refs_by_canonical: dict[str, list[str]] = defaultdict(list)
    stats: dict[str, Any] = {}
    for sheet_name in FOLLOWUP_SHEETS:
        sheet = sheets[sheet_name]
        header_map = {key: header_index(sheet.headers, header) for key, header in FOLLOWUP_HEADERS.items()}
        rows_seen = 0
        for row in sheet.rows:
            row_no = row["row_no"]
            values = row["values"]
            first_intent = values[header_map["first_intent"]]
            second_intent = values[header_map["second_intent"]]
            if not first_intent or not second_intent:
                continue
            rows_seen += 1
            inherited_text = values[header_map["inherited_slots"]]
            inherited_slots = [
                normalize_cell(part)
                for part in re_split_inherited(inherited_text)
                if normalize_cell(part) and normalize_cell(part) not in {"车控"}
            ]
            first_id = primary_by_intent.get((sheet_name, first_intent), "")
            second_id = primary_by_intent.get((sheet_name, second_intent), "")
            unresolved = not first_id or not second_id
            source_row_hash = sha256_json({"sheet": sheet_name, "row_no": row_no, "values": values})
            transition_id = "trans_" + sha256_json(
                {
                    "sheet": sheet_name,
                    "row_no": row_no,
                    "first": first_intent,
                    "second": second_intent,
                    "inherited_slots": inherited_slots,
                }
            )[:16]
            transition = {
                "transition_id": transition_id,
                "first_canonical_semantic_id": first_id,
                "second_canonical_semantic_id": second_id,
                "first_intent": first_intent,
                "second_intent": second_intent,
                "inherited_slots": inherited_slots,
                "rewrite_policy": values[header_map["rewrite_policy"]] or ("inherit_slots" if inherited_slots else "none"),
                "source_sheet": sheet_name,
                "source_row_no": row_no,
                "source_row_hash": source_row_hash,
                "unresolved_ref": unresolved,
                "unresolved_reason": unresolved_reason(first_id, second_id),
                "first_example_hash": nonempty_hash(values[header_map["first_examples"]]),
                "second_example_hash": nonempty_hash(values[header_map["second_examples"]]),
                "external_evidence_ref": f"snapshot:{manifest['snapshot_id']}:followup_function_list:{sheet_name}:{row_no}",
                "evidence_ref_kind": "snapshot",
            }
            transitions.append(transition)
            if not unresolved:
                refs_by_canonical[first_id].append(transition_id)
        stats[sheet_name] = {
            "transition_rows": rows_seen,
            "merged_ranges_count": sheet.merged_ranges_count,
            "merged_filled_cells_count": sheet.merged_filled_cells_count,
            "formula_cells_count": sheet.formula_cells_count,
        }

    transitions.sort(key=lambda row: (row["source_sheet"], row["source_row_no"], row["transition_id"]))
    for row in contract_rows:
        refs = sorted(set(refs_by_canonical.get(row["canonical_semantic_id"], [])))
        row["second_turn_refs"] = refs
    return transitions, refs_by_canonical, stats


def re_split_inherited(text: str) -> list[str]:
    return [part for chunk in text.split("\n") for part in chunk.split("|")]


def unresolved_reason(first_id: str, second_id: str) -> str:
    missing = []
    if not first_id:
        missing.append("first")
    if not second_id:
        missing.append("second")
    return ",".join(missing)


def validate_contract_rows(rows: list[dict[str, Any]]) -> None:
    Draft202012Validator.check_schema(CONTRACT_SCHEMA)
    validator = Draft202012Validator(CONTRACT_SCHEMA)
    errors = []
    for row in rows:
        errors.extend(validator.iter_errors(row))
    if errors:
        formatted = "\n".join(f"{'/'.join(map(str, e.path))}: {e.message}" for e in errors[:20])
        raise RuntimeError(f"contract schema validation failed:\n{formatted}")


def build_function_spec(manifest: dict[str, Any], rows: list[dict[str, Any]]) -> dict[str, Any]:
    by_device: dict[tuple[str, str], list[dict[str, Any]]] = defaultdict(list)
    for row in rows:
        by_device[(row["service"], row["device"])].append(row)

    devices = []
    for (service, device), group in sorted(by_device.items()):
        ranges = sorted({row["range"] for row in group if row["range"]})
        devices.append(
            {
                "device_id": f"{service}.{device}",
                "service": service,
                "device": device,
                "contract_rows": len(group),
                "canonical_semantics": len({row["canonical_semantic_id"] for row in group}),
                "primitives": sorted({row["action_primitive"] for row in group}),
                "action_codes": sorted({row["action_code"] for row in group if row["action_code"]}),
                "slots": sorted({slot for row in group for slot in row["slot_keys"]}),
                "range_samples": ranges[:8],
                "range_sample_count": len(ranges),
                "exec_tier": "L2",
                "risk_max": "",
            }
        )

    return {
        "version": 1,
        "authority": "generated_from_semantic_function_contract_jsonl",
        "source_snapshot_id": manifest["snapshot_id"],
        "source_contract": "contracts/semantic-function-contract.jsonl",
        "summary": {
            "contract_rows": len(rows),
            "canonical_semantics": len({row["canonical_semantic_id"] for row in rows}),
            "devices": len(devices),
            "exec_tier_default": "L2",
            "risk_policy_stage": "stage_b_pending",
        },
        "devices": devices,
    }


def build_coverage_report(
    manifest: dict[str, Any],
    rows: list[dict[str, Any]],
    quarantine: list[dict[str, Any]],
    transitions: list[dict[str, Any]],
    source_stats: dict[str, Any],
    followup_stats: dict[str, Any],
) -> str:
    source_rows = manifest["contract_scope"]["source_rows"]
    valid = len(rows)
    quarantined = len(quarantine)
    legacy = 0
    unclassified = source_rows - valid - quarantined - legacy
    canonical = len({row["canonical_semantic_id"] for row in rows})
    primary = sum(1 for row in rows if row["dedupe_role"] == "primary")
    variant = sum(1 for row in rows if row["dedupe_role"] == "variant")
    unresolved = sum(1 for row in transitions if row["unresolved_ref"])
    unresolved_ratio = (unresolved / len(transitions)) if transitions else 0.0
    range_classes = Counter(row["range_class"] for row in rows)
    value_present = sum(1 for row in rows if any(row["value"].values()))
    value_absent = valid - value_present
    quarantine_reasons = Counter(row["reason"] for row in quarantine)
    domain_counts = Counter(row["source_domain"] for row in rows)
    device_counts = Counter(row["service"] for row in rows)

    lines = [
        "# Semantic Coverage Report",
        "",
        f"snapshot_id: `{manifest['snapshot_id']}`",
        "",
        "## Ledger",
        "",
        "| metric | value |",
        "|---|---:|",
        f"| source_rows | {source_rows} |",
        f"| valid_contract_rows | {valid} |",
        f"| quarantined_rows | {quarantined} |",
        f"| legacy_mapping_rows | {legacy} |",
        f"| unclassified_rows | {unclassified} |",
        f"| canonical_semantics | {canonical} |",
        f"| dedupe_primary_rows | {primary} |",
        f"| dedupe_variant_rows | {variant} |",
        f"| followup_transition_rows | {len(transitions)} |",
        f"| followup_unresolved_rows | {unresolved} |",
        f"| followup_unresolved_ratio | {unresolved_ratio:.4f} |",
        f"| value_present_rows | {value_present} |",
        f"| value_absent_rows | {value_absent} |",
        "",
        "## Source Domains",
        "",
        "| domain | valid_contract_rows | source_rows |",
        "|---|---:|---:|",
    ]
    for domain in CORE_SHEETS:
        lines.append(
            f"| {domain} | {domain_counts.get(domain, 0)} | {source_stats[domain]['source_rows']} |"
        )

    lines.extend(
        [
            "",
            "## Device Aggregate",
            "",
            "| service | contract_rows |",
            "|---|---:|",
        ]
    )
    for service, count in sorted(device_counts.items()):
        lines.append(f"| {service} | {count} |")

    lines.extend(
        [
            "",
            "## XLSX Gate Stats",
            "",
            "| sheet | merged_ranges | merged_filled_cells | formula_cells | calculate_dimension |",
            "|---|---:|---:|---:|---|",
        ]
    )
    for domain in CORE_SHEETS:
        stats = source_stats[domain]
        lines.append(
            f"| {domain} | {stats['merged_ranges_count']} | {stats['merged_filled_cells_count']} | "
            f"{stats['formula_cells_count']} | `{stats['calculate_dimension']}` |"
        )

    lines.extend(
        [
            "",
            "## Followup Stats",
            "",
            "| sheet | transition_rows | merged_ranges | formula_cells |",
            "|---|---:|---:|---:|",
        ]
    )
    for sheet, stats in followup_stats.items():
        lines.append(
            f"| {sheet} | {stats['transition_rows']} | {stats['merged_ranges_count']} | {stats['formula_cells_count']} |"
        )

    lines.extend(
        [
            "",
            "## Range Classification",
            "",
            "| category | count |",
            "|---|---:|",
            f"| placeholder_open | {range_classes.get('placeholder_open', 0)} |",
            "| material_conflict | 0 |",
            f"| material_candidate | {range_classes.get('material_candidate', 0)} |",
            f"| none | {range_classes.get('none', 0)} |",
            "",
            "C2 state-cells.yaml exists (owns execution_range); C1<->C2 execution_range_ref closure is deferred until l1-demo-allowlist, so concrete material conflicts are not asserted yet.",
            "",
            "## Quarantine",
            "",
            "| reason | count |",
            "|---|---:|",
        ]
    )
    if quarantine_reasons:
        for reason, count in sorted(quarantine_reasons.items()):
            lines.append(f"| {reason} | {count} |")
    else:
        lines.append("| none | 0 |")

    if quarantine:
        lines.extend(["", "### Quarantined Rows", "", "| source_sheet | source_row_no | reason | detail |", "|---|---:|---|---|"])
        for row in quarantine:
            lines.append(
                f"| {row['source_sheet']} | {row['source_row_no']} | {row['reason']} | {row.get('detail','')} |"
            )

    lines.extend(
        [
            "",
            "## Redaction Notes",
            "",
            "- Raw source xlsx files are outside the git repository.",
            "- Raw Chinese example utterances are not written to JSONL/YAML; only normalized hashes are stored.",
            "- Example hashes are integrity identifiers, not anonymization proof.",
            "",
        ]
    )
    return "\n".join(lines)


def apply_l1_allowlist(rows: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """从 reviewed l1-demo-allowlist 派生 exec_tier=L1 + execution_range_ref(concrete)。

    L1 唯一来源 = allowlist 段(纵切批)的 (device, primitive) 展开集, 非手写。
    命中 → L1 + execution_range_ref=该 device 的 execution_range_cell + range_ref_kind=concrete;
    未命中保持 classify_semantic_row 默认(L2 / none / "")。risk 不在此处理(risk-policy 单独 task)。
    """
    allowlist = safe_load_yaml(L1_ALLOWLIST)
    l1_cell: dict[tuple[str, str], str] = {}
    for entry in allowlist.get("allowlist", []):
        device = entry["device"]
        cell = entry["execution_range_cell"]
        for prim in entry.get("primitives", []):
            l1_cell[(device, prim)] = cell
    for row in rows:
        cell = l1_cell.get((row["device"], row["action_primitive"]))
        if cell is not None:
            row["exec_tier"] = "L1"
            row["execution_range_ref"] = cell
            row["range_ref_kind"] = "concrete"
    return rows


def main() -> int:
    manifest = load_manifest()
    try:
        rows, quarantine, source_stats = build_semantic_rows(manifest)
    except ValueExtractionError as exc:
        write_failure_receipt(exc)
        print(f"value tuple ambiguity: {exc}", file=sys.stderr)
        print(f"failure_receipt={CONTRACTS_DIR / 'semantic-function-contract.failure-receipt.md'}", file=sys.stderr)
        return 2

    rows = apply_l1_allowlist(rows)
    transitions, _, followup_stats = build_followup_rows(manifest, rows)
    validate_contract_rows(rows)

    function_spec = build_function_spec(manifest, rows)
    coverage = build_coverage_report(manifest, rows, quarantine, transitions, source_stats, followup_stats)

    atomic_write_jsonl(CONTRACT_JSONL, rows)
    atomic_write_jsonl(FOLLOWUP_JSONL, transitions)
    atomic_write_jsonl(QUARANTINE_JSONL, quarantine)
    atomic_write_text(FUNCTION_SPEC_YAML, dump_yaml(function_spec))
    atomic_write_text(COVERAGE_REPORT, coverage)

    print(f"contract_rows={len(rows)}")
    print(f"quarantined_rows={len(quarantine)}")
    print(f"canonical_semantics={len({row['canonical_semantic_id'] for row in rows})}")
    print(f"followup_transition_rows={len(transitions)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

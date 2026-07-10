#!/usr/bin/env python3
"""Fail-closed validation for the C1 fallback-script source."""

from __future__ import annotations

import argparse
import hashlib
import json
from collections import Counter
from pathlib import Path
from typing import Any


EXPECTED_FAMILIES = (
    "ac",
    "seat",
    "window",
    "door",
    "ambient",
    "screen",
    "volume",
    "wiper",
    "sunroofShade",
    "fragrance",
)
EXPECTED_REASONS = (
    "safety_or_clarify_reject",
    "unmounted_name_rejected",
    "fast_path_no_match_fallback",
    "unknown_no_representative_entry",
)
EXPECTED_SAFE_REASON_KINDS = {
    "safety_policy",
    "clarification_required",
    "capability_not_mounted",
    "not_available_in_demo",
}
EXPECTED_RESULT_KINDS = {
    "refusal_safety_or_policy",
    "clarify_missing_slot",
    "refusal_no_available_tool",
}
EXPECTED_INTERNAL_REASON_MAPPINGS = {
    "safety_or_policy_refusal": "safety_policy_refused",
    "clarify_missing_slot": "clarify_missing_slot",
    "unmounted_tool_name": "unmounted_name_rejected",
    "name_rejected": "unmounted_name_rejected",
    "fast_path_no_match": "unsupported_no_available_tool",
    "unsupported_tool_plan": "unsupported_no_available_tool",
    "no_representative_tool": "no_representative_tool__default_fallback",
}
REQUIRED_CELL_FIELDS = {
    "cell_id",
    "locale",
    "family",
    "reason_kind",
    "result_kind",
    "safeReasonKind",
    "dialogText",
    "ttsText",
    "badgeLabel",
    "basis_refs",
    "probe_id",
    "diagnostic_path",
    "state_mutation_expected",
    "no_tool_call_expected",
    "customer_surface_fields",
}
RAW_PUBLIC_FIELDS = {"finiteReason", "rawFiniteReason", "internalReason"}


def expected_projection(reason: str, result_kind: str) -> tuple[str, str] | None:
    if reason == "safety_or_clarify_reject":
        if result_kind == "refusal_safety_or_policy":
            return result_kind, "safety_policy"
        if result_kind == "clarify_missing_slot":
            return result_kind, "clarification_required"
        return None
    if reason == "unmounted_name_rejected":
        return "refusal_no_available_tool", "capability_not_mounted"
    if reason in {"fast_path_no_match_fallback", "unknown_no_representative_entry"}:
        return "refusal_no_available_tool", "not_available_in_demo"
    return None


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def display_path(path: Path, repo_root: Path) -> str:
    try:
        return str(path.relative_to(repo_root))
    except ValueError:
        return str(path)


def load_json_yaml(path: Path) -> dict[str, Any]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, dict):
        raise ValueError("source must be a mapping")
    return payload


def duplicate_values(values: list[str]) -> list[str]:
    return sorted(value for value, count in Counter(values).items() if count > 1)


def expected_generated_entry(source: dict[str, Any], cell: dict[str, Any]) -> dict[str, Any]:
    family = cell["family"]
    index = source["cells"].index(cell) + 1
    return {
        "cellID": f"fallback.{family}.{index:02d}.{cell['locale']}",
        "locale": cell["locale"],
        "family": family,
        "familyLabel": source["families"][family]["familyLabel"],
        "resultKind": cell["result_kind"],
        "safeReasonKind": cell["safeReasonKind"],
        "dialogText": cell["dialogText"],
        "ttsText": cell["ttsText"],
        "badgeLabel": cell["badgeLabel"],
    }


def validate(
    source: Path,
    schema: Path,
    repo_root: Path,
    generated_json: Path | None = None,
    generated_swift: Path | None = None,
) -> dict[str, Any]:
    errors: list[str] = []
    unresolved: list[dict[str, str]] = []
    raw_hits: list[str] = []
    banned_hits: list[str] = []
    generic_hits: list[str] = []
    projection_hits: list[str] = []
    schema_shape_hits: list[str] = []
    unknown_families: list[str] = []
    unknown_reasons: list[str] = []
    missing_pairs: list[list[str]] = []
    duplicate_pairs: list[list[str]] = []

    try:
        data = load_json_yaml(source)
    except Exception as exc:
        data = {}
        errors.append(f"source_parse_error:{exc}")
    try:
        schema_payload = json.loads(schema.read_text(encoding="utf-8"))
    except Exception as exc:
        schema_payload = {}
        errors.append(f"schema_parse_error:{exc}")

    if schema_payload.get("properties", {}).get("authority", {}).get("properties", {}).get("t0_commit", {}).get("const") != "15f1d60908795fc3859fa5a9239d731678f1339d":
        errors.append("schema_t0_commit_mismatch")

    if tuple(data.get("family_enum", [])) != EXPECTED_FAMILIES:
        errors.append("family_enum_mismatch")
    if tuple(data.get("governance_reason_enum", [])) != EXPECTED_REASONS:
        errors.append("governance_reason_enum_mismatch")
    if set(data.get("safe_reason_kind_enum", [])) != EXPECTED_SAFE_REASON_KINDS:
        errors.append("safe_reason_kind_enum_mismatch")
    if set(data.get("result_kind_enum", [])) != EXPECTED_RESULT_KINDS:
        errors.append("result_kind_enum_mismatch")
    if data.get("internal_reason_mappings") != EXPECTED_INTERNAL_REASON_MAPPINGS:
        errors.append("t0_internal_reason_mapping_mismatch")

    cells = data.get("cells", [])
    if not isinstance(cells, list):
        cells = []
        errors.append("cells_must_be_array")
    pairs: list[tuple[str, str]] = []
    cell_ids: list[str] = []
    probe_ids: list[str] = []
    diagnostic_paths: list[str] = []
    banned_phrases = data.get("customer_surface_policy", {}).get("banned_phrases", [])
    allowed_customer_fields = set(data.get("customer_surface_policy", {}).get("allowed_fields", []))

    for index, cell in enumerate(cells):
        if not isinstance(cell, dict):
            errors.append(f"cell[{index}]_must_be_mapping")
            continue
        cell_id = str(cell.get("cell_id", f"cell[{index}]"))
        missing = sorted(REQUIRED_CELL_FIELDS - set(cell))
        if missing:
            errors.append(f"{cell_id}:missing_fields={','.join(missing)}")
        unknown_fields = sorted(set(cell) - REQUIRED_CELL_FIELDS)
        if unknown_fields:
            schema_shape_hits.append(f"{cell_id}:{','.join(unknown_fields)}")
        family = str(cell.get("family", ""))
        reason = str(cell.get("reason_kind", ""))
        pairs.append((family, reason))
        cell_ids.append(cell_id)
        probe_ids.append(str(cell.get("probe_id", "")))
        diagnostic_paths.append(str(cell.get("diagnostic_path", "")))
        if family not in EXPECTED_FAMILIES:
            unknown_families.append(family)
        if reason not in EXPECTED_REASONS:
            unknown_reasons.append(reason)
        if cell.get("safeReasonKind") not in EXPECTED_SAFE_REASON_KINDS:
            errors.append(f"{cell_id}:unknown_safe_reason_kind")
        if cell.get("result_kind") not in EXPECTED_RESULT_KINDS:
            errors.append(f"{cell_id}:unknown_result_kind")
        projection = expected_projection(reason, str(cell.get("result_kind", "")))
        if projection is None or projection != (cell.get("result_kind"), cell.get("safeReasonKind")):
            projection_hits.append(cell_id)
        if cell.get("state_mutation_expected") != "none":
            errors.append(f"{cell_id}:state_mutation_expected_must_be_none")
        if cell.get("no_tool_call_expected") is not True:
            errors.append(f"{cell_id}:no_tool_call_expected_must_be_true")

        customer_fields = set(cell.get("customer_surface_fields", []))
        forbidden_customer_fields = sorted((customer_fields - allowed_customer_fields) | (set(cell) & RAW_PUBLIC_FIELDS))
        if forbidden_customer_fields:
            raw_hits.append(f"{cell_id}:{','.join(forbidden_customer_fields)}")
        for field in ("dialogText", "ttsText", "badgeLabel"):
            text = cell.get(field)
            if not isinstance(text, str) or not text.strip():
                errors.append(f"{cell_id}:{field}_empty")
                continue
            for phrase in banned_phrases:
                if phrase and phrase in text:
                    banned_hits.append(f"{cell_id}:{field}:{phrase}")
        if cell.get("dialogText") == "这个我先记下来，稍后帮您处理":
            generic_hits.append(cell_id)

        refs = cell.get("basis_refs", [])
        if not isinstance(refs, list) or len(refs) < 2:
            unresolved.append({"cell_id": cell_id, "ref": "basis_refs_missing"})
        else:
            for ref in refs:
                if not isinstance(ref, dict) or set(ref) != {"path", "contains"}:
                    unresolved.append({"cell_id": cell_id, "ref": repr(ref)})
                    continue
                raw_path = str(ref["path"])
                candidate = Path(raw_path)
                if candidate.is_absolute() or ".." in candidate.parts:
                    unresolved.append({"cell_id": cell_id, "ref": raw_path})
                    continue
                resolved = (repo_root / candidate).resolve()
                if repo_root.resolve() not in resolved.parents or not resolved.is_file():
                    unresolved.append({"cell_id": cell_id, "ref": raw_path})
                    continue
                content = resolved.read_text(encoding="utf-8")
                if content.count(str(ref["contains"])) != 1:
                    unresolved.append({"cell_id": cell_id, "ref": f"{raw_path}#{ref['contains']}"})

    expected_pairs = {(family, reason) for family in EXPECTED_FAMILIES for reason in EXPECTED_REASONS}
    pair_counts = Counter(pairs)
    missing_pairs = [list(pair) for pair in sorted(expected_pairs - set(pair_counts))]
    duplicate_pairs = [list(pair) for pair, count in sorted(pair_counts.items()) if count > 1]
    duplicate_ids = {
        "cell_id": duplicate_values(cell_ids),
        "probe_id": duplicate_values(probe_ids),
        "diagnostic_path": duplicate_values(diagnostic_paths),
    }
    if len(cells) != 40:
        errors.append(f"cell_count_mismatch:{len(cells)}")
    if missing_pairs:
        errors.append("missing_family_reason_pairs")
    if duplicate_pairs:
        errors.append("duplicate_family_reason_pairs")
    if any(duplicate_ids.values()):
        errors.append("duplicate_stable_ids")
    if unknown_families:
        errors.append("unknown_families")
    if unknown_reasons:
        errors.append("unknown_reasons")
    if unresolved:
        errors.append("unresolved_basis_refs")
    if raw_hits:
        errors.append("customer_raw_field_exposure")
    if banned_hits:
        errors.append("banned_copy")
    if generic_hits:
        errors.append("generic_copy_leakage")
    if projection_hits:
        errors.append("t0_projection_mismatch")
    if schema_shape_hits:
        errors.append("schema_shape_violation")

    source_digest = sha256(source) if source.exists() else None
    generated_json_digest = None
    generated_swift_digest = None
    if generated_json is not None:
        try:
            generated_payload = json.loads(generated_json.read_text(encoding="utf-8"))
            generated_json_digest = sha256(generated_json)
            expected_entries = [expected_generated_entry(data, cell) for cell in cells]
            if generated_payload.get("sourceSHA256") != source_digest or generated_payload.get("entries") != expected_entries:
                errors.append("generated_catalog_drift")
        except Exception as exc:
            errors.append(f"generated_catalog_parse_error:{exc}")
    if generated_swift is not None:
        try:
            generated_swift_text = generated_swift.read_text(encoding="utf-8")
            generated_swift_digest = sha256(generated_swift)
            if source_digest not in generated_swift_text:
                errors.append("generated_swift_source_sha_mismatch")
            if any(raw_field in generated_swift_text for raw_field in RAW_PUBLIC_FIELDS):
                errors.append("generated_swift_raw_field_exposure")
        except Exception as exc:
            errors.append(f"generated_swift_read_error:{exc}")

    return {
        "status": "PASS" if not errors else "FAIL",
        "proof_class": "local_contract_validation",
        "source_path": display_path(source, repo_root),
        "source_sha256": source_digest,
        "schema_sha256": sha256(schema) if schema.exists() else None,
        "generated_json_sha256": generated_json_digest,
        "generated_swift_sha256": generated_swift_digest,
        "family_count": len(set(family for family, _ in pairs)),
        "reason_count": len(set(reason for _, reason in pairs)),
        "cell_count": len(cells),
        "missing_pairs": missing_pairs,
        "duplicate_pairs": duplicate_pairs,
        "duplicate_ids": duplicate_ids,
        "unknown_families": sorted(set(unknown_families)),
        "unknown_reasons": sorted(set(unknown_reasons)),
        "unresolved_basis_refs": unresolved,
        "customer_raw_field_hits": raw_hits,
        "banned_copy_hits": banned_hits,
        "generic_leakage_hits": generic_hits,
        "t0_projection_mismatch_hits": projection_hits,
        "schema_shape_hits": schema_shape_hits,
        "errors": errors,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--schema", type=Path, required=True)
    parser.add_argument("--receipt", type=Path, required=True)
    parser.add_argument("--generated-json", type=Path)
    parser.add_argument("--generated-swift", type=Path)
    args = parser.parse_args()
    repo_root = Path(__file__).resolve().parents[2]
    receipt = validate(
        args.source.resolve(),
        args.schema.resolve(),
        repo_root,
        args.generated_json.resolve() if args.generated_json else None,
        args.generated_swift.resolve() if args.generated_swift else None,
    )
    args.receipt.parent.mkdir(parents=True, exist_ok=True)
    args.receipt.write_text(json.dumps(receipt, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    if receipt["status"] == "PASS":
        print(f"fallback scripts PASS: {receipt['family_count']}x{receipt['reason_count']}={receipt['cell_count']}")
        return 0
    print(json.dumps(receipt, ensure_ascii=False, sort_keys=True))
    return 1


if __name__ == "__main__":
    raise SystemExit(main())

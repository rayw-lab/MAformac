#!/usr/bin/env python3
"""Validate and materialize the C1 B4 runtime no-mutation probe pack."""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import re
import sys
from collections import Counter
from pathlib import Path
from typing import Any


REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_SOURCE = REPO_ROOT / "contracts" / "fallback-probes.yaml"
DEFAULT_SCHEMA = REPO_ROOT / "contracts" / "schemas" / "fallback-probes.schema.json"
DEFAULT_FALLBACK = REPO_ROOT / "contracts" / "fallback-scripts.yaml"
DEFAULT_GENERATED = REPO_ROOT / "generated" / "demo-fallback-probes.catalog.json"

def family_enum_from_source(data: dict[str, Any]) -> tuple[str, ...]:
    """SSOT = contracts YAML `family_enum` (no second Python roster freeze)."""
    raw = data.get("family_enum")
    if not isinstance(raw, list) or not raw:
        raise ValueError("family_enum must be a non-empty list")
    if any(not isinstance(item, str) or not item for item in raw):
        raise ValueError("family_enum entries must be non-empty strings")
    if len(raw) != len(set(raw)):
        raise ValueError("family_enum must be unique")
    return tuple(raw)


EXPECTED_REASONS = (
    "safety_or_clarify_reject",
    "unmounted_name_rejected",
    "fast_path_no_match_fallback",
    "unknown_no_representative_entry",
)
EXPECTED_FIXTURES = {
    "safety_or_clarify_reject": "guard_or_clarify_stub",
    "unmounted_name_rejected": "injected_tool_plan_stub",
    "fast_path_no_match_fallback": "default_text_runner",
    "unknown_no_representative_entry": "matrix_no_representative_stub",
}
EXPECTED_FINITE_REASONS = {
    "safety_or_clarify_reject": "safety_or_policy_refusal",
    "unmounted_name_rejected": "name_rejected",
    "fast_path_no_match_fallback": "fast_path_no_match",
    "unknown_no_representative_entry": "no_representative_tool",
}
PROBE_ID_RE = re.compile(
    r"^probe\.fallback\.([A-Za-z][A-Za-z0-9]*)\."
    r"(safety_or_clarify_reject|unmounted_name_rejected|"
    r"fast_path_no_match_fallback|unknown_no_representative_entry)\.zh-CN$"
)
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
FORBIDDEN_FUTURE_ACTION_PHRASES = (
    "我再执行",
    "稍后执行",
    "自动执行",
    "已排队",
    "等条件满足后执行",
)


def canonical_sha256(value: Any) -> str:
    data = json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(data).hexdigest()


def load_json(path: Path) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError(f"{path} must contain an object")
    return value


def write_json(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(value, ensure_ascii=False, indent=2, sort_keys=False) + "\n",
        encoding="utf-8",
    )


def _fallback_projection(fallback: dict[str, Any]) -> dict[str, dict[str, Any]]:
    projection: dict[str, dict[str, Any]] = {}
    cells = fallback.get("cells", [])
    if not isinstance(cells, list):
        raise ValueError("fallback cells must be an array")
    for index, cell in enumerate(cells, start=1):
        if not isinstance(cell, dict):
            raise ValueError(f"fallback cell {index} must be an object")
        family = cell.get("family")
        reason = cell.get("reason_kind")
        locale = cell.get("locale")
        public_id = cell.get("cell_id")
        if not isinstance(public_id, str) or not public_id:
            raise ValueError(f"fallback cell {index} must carry canonical cell_id")
        projection[public_id] = {
            "family": family,
            "reasonKind": reason,
            "resultKind": cell.get("result_kind"),
            "safeReasonKind": cell.get("safeReasonKind"),
            "badgeLabel": cell.get("badgeLabel"),
            "dialogText": cell.get("dialogText"),
            "ttsText": cell.get("ttsText"),
        }
    return projection


def build_generated_catalog(
    source: dict[str, Any], fallback: dict[str, Any]
) -> dict[str, Any]:
    fallback_by_id = _fallback_projection(fallback)
    generated: list[dict[str, Any]] = []
    for probe in source.get("probes", []):
        readback = probe["readbackProbePass"]
        fallback_id = readback["expected_ui_readback"]["fallback_cell_id"]
        fallback_entry = fallback_by_id.get(fallback_id)
        if fallback_entry is None:
            raise ValueError(f"unknown fallback cell {fallback_id}")
        if (
            fallback_entry["family"] != probe.get("family")
            or fallback_entry["reasonKind"] != probe.get("reason_kind")
        ):
            raise ValueError(f"fallback pair mismatch for {probe.get('probe_id')}")
        generated.append(
            {
                "probeID": probe["probe_id"],
                "family": probe["family"],
                "reasonKind": probe["reason_kind"],
                "locale": probe["locale"],
                "fixturePath": probe["fixture_path"],
                "probeUtterance": readback["probe_utterance"],
                "fallbackCellID": fallback_id,
                "expectedStateDelta": copy.deepcopy(readback["expected_state_delta"]),
                "expectedUIReadback": {
                    "resultKind": fallback_entry["resultKind"],
                    "safeReasonKind": fallback_entry["safeReasonKind"],
                    "badgeLabel": fallback_entry["badgeLabel"],
                    "dialogText": fallback_entry["dialogText"],
                    "ttsText": fallback_entry["ttsText"],
                },
                "assertionSource": copy.deepcopy(readback["assertion_source"]),
            }
        )
    return {
        "schemaVersion": "demo_fallback_probes_catalog_v1",
        "sourceSHA256": canonical_sha256(source),
        "fallbackSourceSHA256": canonical_sha256(fallback),
        "receiptID": source.get("authority", {}).get("receipt_id"),
        "probes": generated,
    }


def _duplicate_values(values: list[str]) -> list[str]:
    return sorted(value for value, count in Counter(values).items() if count > 1)


def _validate_source(source: dict[str, Any], schema: dict[str, Any]) -> tuple[list[str], list[list[str]], list[list[str]]]:
    errors: list[str] = []
    if source.get("schema_version") != "demo_fallback_probes_v1":
        errors.append("source_schema_version_mismatch")
    schema_const = schema.get("properties", {}).get("schema_version", {}).get("const")
    if schema_const != "demo_fallback_probes_v1":
        errors.append("schema_contract_mismatch")
    authority = source.get("authority", {})
    if authority.get("receipt_id") != "runtime-no-mutation-40-probes":
        errors.append("receipt_id_mismatch")
    try:
        expected_families = family_enum_from_source(source)
    except ValueError:
        errors.append("family_enum_mismatch")
        expected_families = ()
    # Cross-source lock: probes family_enum must match fallback-scripts family_enum.
    try:
        fallback_payload = json.loads(DEFAULT_FALLBACK.read_text(encoding="utf-8"))
        fallback_families = family_enum_from_source(fallback_payload)
        if expected_families and fallback_families != expected_families:
            errors.append("family_enum_cross_source_mismatch")
    except Exception:
        errors.append("family_enum_cross_source_unreadable")
    if tuple(source.get("reason_kind_enum", [])) != EXPECTED_REASONS:
        errors.append("reason_enum_mismatch")
    if source.get("fixture_path_by_reason") != EXPECTED_FIXTURES:
        errors.append("fixture_mapping_mismatch")

    probes = source.get("probes", [])
    if not isinstance(probes, list):
        probes = []
        errors.append("probes_must_be_array")
    pairs: list[tuple[str, str]] = []
    probe_ids: list[str] = []
    for index, probe in enumerate(probes):
        if not isinstance(probe, dict):
            errors.append(f"probe_{index}_not_object")
            continue
        probe_id = str(probe.get("probe_id", ""))
        family = str(probe.get("family", ""))
        reason = str(probe.get("reason_kind", ""))
        pairs.append((family, reason))
        probe_ids.append(probe_id)
        match = PROBE_ID_RE.fullmatch(probe_id)
        if match is None or match.groups() != (family, reason):
            errors.append("probe_id_pair_mismatch")
        if probe.get("locale") != "zh-CN":
            errors.append("locale_mismatch")
        if probe.get("fixture_path") != EXPECTED_FIXTURES.get(reason):
            errors.append("fixture_mapping_mismatch")
        readback = probe.get("readbackProbePass")
        if not isinstance(readback, dict) or set(readback) != {
            "probe_utterance",
            "expected_state_delta",
            "expected_ui_readback",
            "assertion_source",
        }:
            errors.append("readback_probe_four_fields_required")
            continue
        if not isinstance(readback.get("probe_utterance"), str) or not readback["probe_utterance"].strip():
            errors.append("probe_utterance_missing")
        expected_delta = readback.get("expected_state_delta")
        if expected_delta != {
            "kind": "none",
            "mutated_cells": [],
            "full_state_hash": "unchanged",
        }:
            errors.append("expected_state_delta_must_be_none")
        expected_ui = readback.get("expected_ui_readback")
        if not isinstance(expected_ui, dict) or set(expected_ui) != {"fallback_cell_id"}:
            errors.append("fallback_copy_must_be_reference_only")
        assertions = readback.get("assertion_source")
        if (
            not isinstance(assertions, list)
            or len(assertions) < 2
            or not all(isinstance(value, str) and value.strip() for value in assertions)
        ):
            errors.append("assertion_source_missing")
        runtime = probe.get("runtime_assertions")
        if runtime != {
            "no_crash": True,
            "observed_tool_call_count": 0,
            "state_unchanged": True,
            "dialog_tts_non_empty": True,
            "forbidden_future_action_phrase_absent": True,
        }:
            errors.append("runtime_assertion_contract_mismatch")

    expected_pairs = {(family, reason) for family in expected_families for reason in EXPECTED_REASONS}
    counts = Counter(pairs)
    missing_pairs = [list(pair) for pair in sorted(expected_pairs - set(counts))]
    duplicate_pairs = [list(pair) for pair, count in sorted(counts.items()) if count > 1]
    if len(probes) != 40 or missing_pairs:
        errors.append("missing_family_reason_pairs")
    if duplicate_pairs:
        errors.append("duplicate_family_reason_pairs")
    if _duplicate_values(probe_ids):
        errors.append("duplicate_probe_ids")
    return errors, missing_pairs, duplicate_pairs


def _validate_receipt(
    generated: dict[str, Any], receipt: dict[str, Any]
) -> tuple[list[str], list[str], list[str]]:
    errors: list[str] = []
    expected_probes = {
        probe["probeID"]: probe for probe in generated.get("probes", []) if isinstance(probe, dict)
    }
    cases = receipt.get("cases", [])
    if not isinstance(cases, list):
        cases = []
        errors.append("receipt_cases_must_be_array")
    case_ids = [str(case.get("probeID", "")) for case in cases if isinstance(case, dict)]
    missing_ids = sorted(set(expected_probes) - set(case_ids))
    duplicate_ids = _duplicate_values(case_ids)
    if receipt.get("schemaVersion") != "runtime_no_mutation_receipt_v1":
        errors.append("receipt_schema_version_mismatch")
    if receipt.get("receiptID") != generated.get("receiptID"):
        errors.append("receipt_id_mismatch")
    if receipt.get("probePackSHA256") != generated.get("sourceSHA256"):
        errors.append("probe_pack_sha_mismatch")
    if receipt.get("proofClass") != "local_unit":
        errors.append("proof_class_mismatch")
    if receipt.get("caseCount") != 40 or len(cases) != 40:
        errors.append("receipt_case_count_mismatch")
    if receipt.get("expectedPairs") != 40 or receipt.get("observedPairs") != 40:
        errors.append("receipt_pair_count_mismatch")
    if receipt.get("missingProbeIDs") != [] or missing_ids:
        errors.append("missing_receipt_cases")
    if receipt.get("duplicateProbeIDs") != [] or duplicate_ids:
        errors.append("duplicate_receipt_cases")

    for case in cases:
        if not isinstance(case, dict):
            errors.append("receipt_case_not_object")
            continue
        expected = expected_probes.get(case.get("probeID"))
        if expected is None:
            errors.append("unknown_receipt_probe")
            continue
        if case.get("family") != expected["family"] or case.get("reasonKind") != expected["reasonKind"]:
            errors.append("receipt_pair_mismatch")
        if case.get("finiteReason") != EXPECTED_FINITE_REASONS[expected["reasonKind"]]:
            errors.append("finite_reason_mismatch")
        if not isinstance(case.get("traceID"), str) or not case["traceID"].strip():
            errors.append("missing_trace")
        before = case.get("stateBeforeSHA256")
        after = case.get("stateAfterSHA256")
        if not isinstance(before, str) or SHA256_RE.fullmatch(before) is None:
            errors.append("invalid_state_hash")
        if not isinstance(after, str) or SHA256_RE.fullmatch(after) is None:
            errors.append("invalid_state_hash")
        if before != after or case.get("stateMutation") is not False:
            errors.append("state_mutation_detected")
        if case.get("observedToolCallCount") != 0:
            errors.append("tool_call_detected")
        expected_ui = expected["expectedUIReadback"]
        if any(
            case.get(field) != expected_ui.get(field)
            for field in ("resultKind", "safeReasonKind", "badgeLabel", "dialogText", "ttsText")
        ):
            errors.append("fallback_copy_mismatch")
        if not case.get("dialogText") or not case.get("ttsText"):
            errors.append("empty_dialog_tts")
        for phrase in FORBIDDEN_FUTURE_ACTION_PHRASES:
            if phrase in str(case.get("dialogText", "")) or phrase in str(case.get("ttsText", "")):
                errors.append("forbidden_future_action_phrase")
    return errors, missing_ids, duplicate_ids


def validate_documents(
    *,
    source: dict[str, Any],
    schema: dict[str, Any],
    fallback: dict[str, Any],
    generated: dict[str, Any],
    receipt: dict[str, Any],
) -> dict[str, Any]:
    source_errors, missing_pairs, duplicate_pairs = _validate_source(source, schema)
    errors = list(source_errors)
    try:
        expected_generated = build_generated_catalog(source, fallback)
    except Exception as exc:
        expected_generated = {}
        errors.append(f"generated_projection_error:{exc}")
    if generated != expected_generated:
        errors.append("generated_catalog_drift")
    receipt_errors, missing_ids, duplicate_ids = _validate_receipt(generated, receipt)
    errors.extend(receipt_errors)
    cases = receipt.get("cases", []) if isinstance(receipt.get("cases"), list) else []
    return {
        "status": "PASS" if not errors else "FAIL",
        "errors": sorted(set(errors)),
        "case_count": len(cases),
        "expected_pair_count": 40,
        "observed_pair_count": len(
            {
                (case.get("family"), case.get("reasonKind"))
                for case in cases
                if isinstance(case, dict)
            }
        ),
        "missing_pairs": missing_pairs,
        "duplicate_pairs": duplicate_pairs,
        "missing_probe_ids": missing_ids,
        "duplicate_probe_ids": duplicate_ids,
        "tool_call_violations": sum(
            isinstance(case, dict) and case.get("observedToolCallCount") != 0 for case in cases
        ),
        "state_mutation_violations": sum(
            isinstance(case, dict)
            and (
                case.get("stateBeforeSHA256") != case.get("stateAfterSHA256")
                or case.get("stateMutation") is not False
            )
            for case in cases
        ),
        "probe_pack_sha256": canonical_sha256(source),
        "runtime_receipt_sha256": canonical_sha256(receipt),
        "proof_class": receipt.get("proofClass"),
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    subcommands = parser.add_subparsers(dest="command", required=True)

    generate = subcommands.add_parser("generate")
    generate.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    generate.add_argument("--fallback", type=Path, default=DEFAULT_FALLBACK)
    generate.add_argument("--output", type=Path, default=DEFAULT_GENERATED)

    check = subcommands.add_parser("check")
    check.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    check.add_argument("--schema", type=Path, default=DEFAULT_SCHEMA)
    check.add_argument("--fallback", type=Path, default=DEFAULT_FALLBACK)
    check.add_argument("--generated", type=Path, default=DEFAULT_GENERATED)
    check.add_argument("--receipt", type=Path, required=True)
    check.add_argument("--output", type=Path)
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    if args.command == "generate":
        generated = build_generated_catalog(load_json(args.source), load_json(args.fallback))
        write_json(args.output, generated)
        print(f"generated {len(generated['probes'])} fallback probes")
        return 0

    report = validate_documents(
        source=load_json(args.source),
        schema=load_json(args.schema),
        fallback=load_json(args.fallback),
        generated=load_json(args.generated),
        receipt=load_json(args.receipt),
    )
    if args.output:
        write_json(args.output, report)
    stream = sys.stdout if report["status"] == "PASS" else sys.stderr
    print(json.dumps(report, ensure_ascii=False, sort_keys=True), file=stream)
    return 0 if report["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())

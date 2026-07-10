#!/usr/bin/env python3
"""Fail-closed, source-free checker for structured S10 receipt fixtures.

This checker validates the receipt contract and Q-SR=A formula only. It does
not execute S10, expand mounted tools, or confer any acceptance proof.
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from datetime import datetime
from pathlib import Path
from typing import Any


EPSILON = 1e-6
BLOCKED_RC = 65
USAGE_RC = 64
SUBSTITUTE_FIELDS = {
    "primary_pass_rate": "primary_pass_rate_substitute",
    "overall_pass_rate": "overall_pass_rate_substitute",
    "prose_pass_rate": "prose_only_substitute",
}


def error(code: str, field: str, severity: str = "P0", detail: str | None = None) -> dict[str, str]:
    item = {"code": code, "field": field, "severity": severity}
    if detail:
        item["detail"] = detail
    return item


def add_error(
    errors: list[dict[str, str]],
    code: str,
    field: str,
    severity: str = "P0",
    detail: str | None = None,
) -> None:
    candidate = error(code, field, severity, detail)
    if candidate not in errors:
        errors.append(candidate)


def is_number(value: Any) -> bool:
    return isinstance(value, (int, float)) and not isinstance(value, bool) and math.isfinite(float(value))


def is_integer(value: Any) -> bool:
    return isinstance(value, int) and not isinstance(value, bool)


def is_datetime(value: Any) -> bool:
    if not isinstance(value, str) or not value:
        return False
    try:
        datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return False
    return True


def derive_tier(joint: float) -> dict[str, Any]:
    if joint < 0.40:
        return {
            "tier": "no_expand_lt_40",
            "mounted_expansion_allowed": False,
            "planned_family_count": 0,
        }
    if joint <= 0.70:
        return {
            "tier": "expand_3_families_40_to_70",
            "mounted_expansion_allowed": True,
            "planned_family_count": 3,
        }
    return {
        "tier": "expand_10_families_gt_70",
        "mounted_expansion_allowed": True,
        "planned_family_count": 10,
    }


def blocked(errors: list[dict[str, str]]) -> dict[str, Any]:
    return {
        "status": "BLOCKED",
        "errors": errors,
        "zero_runtime_decision": False,
        "fixture_only": True,
        "s10_executed": False,
        "mounted_expansion_authorized": False,
    }


def validate_object_keys(
    value: Any,
    field: str,
    required: set[str],
    allowed: set[str],
    errors: list[dict[str, str]],
) -> dict[str, Any] | None:
    if not isinstance(value, dict):
        add_error(errors, "schema_validation_error", field, detail="expected object")
        return None
    for missing in sorted(required - set(value)):
        add_error(errors, "missing_required_field", f"{field}.{missing}")
    for extra in sorted(set(value) - allowed):
        add_error(errors, "schema_validation_error", f"{field}.{extra}", "P1", "additional property")
    return value


def validate_arm(value: Any, field: str, errors: list[dict[str, str]]) -> float | None:
    arm = validate_object_keys(
        value,
        field,
        {"attempts", "strikes", "strike_rate"},
        {"attempts", "strikes", "strike_rate"},
        errors,
    )
    if arm is None:
        return None

    attempts = arm.get("attempts")
    strikes = arm.get("strikes")
    strike_rate = arm.get("strike_rate")

    if not is_integer(attempts):
        add_error(errors, "schema_validation_error", f"{field}.attempts", detail="expected integer")
        return None
    if attempts == 0:
        add_error(errors, "zero_denominator", f"{field}.attempts")
        return None
    if attempts < 0:
        add_error(errors, "schema_validation_error", f"{field}.attempts", detail="must be positive")
        return None
    if not is_integer(strikes) or strikes < 0 or strikes > attempts:
        add_error(errors, "schema_validation_error", f"{field}.strikes", detail="must be integer in [0, attempts]")
        return None
    if not is_number(strike_rate) or not 0 <= float(strike_rate) <= 1:
        add_error(errors, "rate_out_of_range", f"{field}.strike_rate", "P1")
        return None

    expected_rate = strikes / attempts
    if abs(float(strike_rate) - expected_rate) > EPSILON:
        add_error(
            errors,
            "rate_mismatch",
            f"{field}.strike_rate",
            "P1",
            f"expected {expected_rate:.12g}",
        )
    return float(strike_rate)


def check_receipt(receipt: Any, schema: dict[str, Any], expected_run_id: str) -> dict[str, Any]:
    errors: list[dict[str, str]] = []
    if not isinstance(receipt, dict):
        return blocked([error("schema_validation_error", "$", detail="expected object")])

    schema_required = set(schema.get("required", []))
    schema_properties = set(schema.get("properties", {}))
    if not schema_required or not schema_properties or schema.get("additionalProperties") is not False:
        return blocked([error("invalid_checker_schema", "$schema")])

    joint_missing = "joint_strike_rate" not in receipt
    if joint_missing:
        add_error(errors, "joint_rate_missing", "joint_strike_rate")
        if isinstance(receipt.get("notes"), str) and receipt["notes"].strip():
            add_error(errors, "prose_only_substitute", "notes")
        for field, code in SUBSTITUTE_FIELDS.items():
            if field in receipt:
                add_error(errors, code, field)
    else:
        for field in SUBSTITUTE_FIELDS:
            if field in receipt:
                add_error(errors, "forbidden_field_present", field, "P1")

    for missing in sorted(schema_required - set(receipt) - {"joint_strike_rate"}):
        add_error(errors, "missing_required_field", missing)
    for extra in sorted(set(receipt) - schema_properties - set(SUBSTITUTE_FIELDS)):
        add_error(errors, "schema_validation_error", extra, "P1", "additional property")
    if errors:
        return blocked(errors)

    if receipt.get("schema_version") != "s10_receipt.v1":
        add_error(errors, "schema_validation_error", "schema_version", detail="expected s10_receipt.v1")
    if not isinstance(receipt.get("receipt_id"), str) or not receipt["receipt_id"]:
        add_error(errors, "schema_validation_error", "receipt_id", detail="expected nonempty string")
    if not is_datetime(receipt.get("captured_at")):
        add_error(errors, "schema_validation_error", "captured_at", detail="expected date-time")
    if receipt.get("proof_class") not in {"local", "unit", "integration", "runtime", "desktop_operator_equivalent"}:
        add_error(errors, "schema_validation_error", "proof_class", detail="unknown proof class")

    scope = validate_object_keys(
        receipt.get("evaluation_scope"),
        "evaluation_scope",
        {"run_id", "eval_set_id", "s10_stage"},
        {"run_id", "eval_set_id", "s10_stage"},
        errors,
    )
    if scope is not None:
        if scope.get("run_id") != expected_run_id:
            add_error(
                errors,
                "stale_run_id",
                "evaluation_scope.run_id",
                detail=f"expected {expected_run_id}",
            )
        if not isinstance(scope.get("eval_set_id"), str) or not scope["eval_set_id"]:
            add_error(errors, "schema_validation_error", "evaluation_scope.eval_set_id", detail="expected nonempty string")
        if scope.get("s10_stage") != "s10_verdict":
            add_error(errors, "schema_validation_error", "evaluation_scope.s10_stage", detail="expected s10_verdict")

    hedged_rate = validate_arm(receipt.get("hedged"), "hedged", errors)
    can_question_rate = validate_arm(receipt.get("can_question"), "can_question", errors)
    if errors or hedged_rate is None or can_question_rate is None:
        return blocked(errors)

    expected_joint = min(hedged_rate, can_question_rate)
    actual_joint = receipt.get("joint_strike_rate")
    if not is_number(actual_joint) or not 0 <= float(actual_joint) <= 1:
        add_error(errors, "rate_out_of_range", "joint_strike_rate", "P1")
    elif abs(float(actual_joint) - expected_joint) > EPSILON:
        add_error(
            errors,
            "joint_rate_mismatch",
            "joint_strike_rate",
            detail=f"expected min(hedged, can_question)={expected_joint:.12g}",
        )

    expected_tier = derive_tier(expected_joint)
    tier = validate_object_keys(
        receipt.get("tier_decision"),
        "tier_decision",
        {"tier", "mounted_expansion_allowed", "planned_family_count"},
        {"tier", "mounted_expansion_allowed", "planned_family_count"},
        errors,
    )
    if tier is not None and tier != expected_tier:
        add_error(errors, "tier_decision_mismatch", "tier_decision", detail=f"expected {expected_tier}")

    if errors:
        return blocked(errors)
    return {
        "status": "PASS",
        "joint_strike_rate": expected_joint,
        "tier_decision": expected_tier,
        "zero_runtime_decision": True,
        "proof_class": "local_fixture",
        "source_receipt_proof_class": receipt["proof_class"],
        "fixture_only": True,
        "s10_executed": False,
        "mounted_expansion_authorized": False,
    }


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("receipt", type=Path)
    parser.add_argument(
        "--schema",
        type=Path,
        default=Path(__file__).resolve().parents[1] / "contracts" / "schemas" / "s10-receipt.schema.json",
    )
    parser.add_argument("--expected-run-id", required=True)
    return parser.parse_args(argv)


def load_json(path: Path, field: str) -> tuple[Any | None, dict[str, Any] | None]:
    try:
        return json.loads(path.read_text(encoding="utf-8")), None
    except (OSError, json.JSONDecodeError) as exc:
        return None, blocked([error("invalid_json_input", field, detail=str(exc))])


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    receipt, receipt_error = load_json(args.receipt, "receipt")
    schema, schema_error = load_json(args.schema, "schema")
    result = receipt_error or schema_error
    if result is None:
        result = check_receipt(receipt, schema, args.expected_run_id)
    print(json.dumps(result, ensure_ascii=False, sort_keys=True, indent=2))
    return 0 if result["status"] == "PASS" else BLOCKED_RC


if __name__ == "__main__":
    raise SystemExit(main())

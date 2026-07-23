#!/usr/bin/env python3
"""Fail-close the Task-0 C1 ownership, CG coverage and enum projection contract."""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter
from pathlib import Path
from typing import Any

from check_runtime_finite_reason_authority import check as check_runtime_finite_reason_authority


CHANGE_ID = "add-c1-demo-capability-governance"
LEGACY_CHANGE_ID = "define-c1-demo-capability-and-fallback-contract"
EXPECTED_CAPABILITIES = {
    "demo-capability-governance": "ADDED",
    "tool-execution": "MODIFIED",
    "runtime-presentation-bridge": "MODIFIED",
}
EXPECTED_OWNERS = {
    "matrix_eligibility": "demo-capability-governance",
    "matrix_basis_and_primary_class": "demo-capability-governance",
    "fallback_taxonomy_and_catalog": "demo-capability-governance",
    "probe_policy": "demo-capability-governance",
    "mounted_expansion_and_rollback_policy": "demo-capability-governance",
    "bounded_execution_gates": "tool-execution",
    "accepted_refused_identity_and_mutation": "tool-execution",
    "observed_tool_calls_readback_and_internal_finite_reason": "tool-execution",
    "execution_receipt_facts": "tool-execution",
    "public_result_and_safe_reason_kind": "runtime-presentation-bridge",
    "payload_schema_cards_and_readback_rendering": "runtime-presentation-bridge",
    "presentation_safe_trace_and_proof_cap": "runtime-presentation-bridge",
}
SAFE_REASON_KINDS = {
    "safety_policy",
    "clarification_required",
    "capability_not_mounted",
    "not_available_in_demo",
    "runtime_unavailable",
    "already_done",
    "lexical_invalid",
    "numeric_overflow",
    "unsupported_precision",
    "out_of_range",
    "malformed_current",
    "unsupported_unit_reference",
    "contract_violation",
    "state_query",
    "capability_query",
    "cancel_too_late",
}
FALLBACK_REASONS = {
    "safety_policy_refused",
    "clarify_missing_slot",
    "unmounted_name_rejected",
    "unsupported_no_available_tool",
    "no_representative_tool__default_fallback",
    "runtime_error_typed",
    "already_state_noop",
    "lexical_invalid",
    "numeric_overflow",
    "arithmetic_overflow",
    "unsupported_precision",
    "out_of_range",
    "malformed_current",
    "unsupported_unit_reference",
    "contract_violation",
    "state_query",
    "capability_query",
    "cancel_too_late",
}
BRIDGE_RESULTS = {
    "refusal_safety_or_policy",
    "clarify_missing_slot",
    "refusal_no_available_tool",
    "runtime_error",
    "already_state_noop",
    "refusal_contract_violation",
    "state_query",
    "capability_query",
    "cancelled",
}
CG_PATTERN = re.compile(r"CG-\d{3}")
RATIFIED_CG_PATTERN = re.compile(r"^\|\s*(CG-\d{3})\s*\|", re.MULTILINE)


def read_json_yaml(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise ValueError(f"missing ownership map: {path}") from exc
    except json.JSONDecodeError as exc:
        raise ValueError(f"ownership map must be JSON-compatible YAML: {path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise ValueError("ownership map root must be an object")
    return payload


def read_text(path: Path, errors: list[str]) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        errors.append(f"missing required file: {path}")
        return ""


def sorted_unique(values: list[str]) -> list[str]:
    return sorted(set(values))


def append_if(condition: bool, target: list[Any], value: Any) -> None:
    if condition:
        target.append(value)


def check(change: Path, repo_root: Path) -> dict[str, Any]:
    errors: list[str] = []
    try:
        ownership_map = read_json_yaml(change / "ownership-map.yaml")
    except ValueError as exc:
        return {
            "status": "FAIL",
            "change_id": CHANGE_ID,
            "errors": [str(exc)],
            "duplicate_owners": [],
            "forbidden_parallel_ssot": [],
            "missing_cg": [],
            "duplicate_cg": [],
            "extra_cg": [],
            "semantic_gaps": [],
            "change_id_mismatches": [],
            "finite_reason_unknown": [],
        }

    change_id_mismatches: list[str] = []
    if ownership_map.get("change_id") != CHANGE_ID:
        change_id_mismatches.append("ownership-map.change_id")
    for path in change.rglob("*"):
        if not path.is_file():
            continue
        content = read_text(path, errors)
        if LEGACY_CHANGE_ID in content:
            change_id_mismatches.append(str(path.relative_to(change)))
    for required in ("proposal.md", "tasks.md"):
        content = read_text(change / required, errors)
        if CHANGE_ID not in content:
            change_id_mismatches.append(required + ":missing_actual_id")

    declared_capabilities = ownership_map.get("capabilities")
    actual_capabilities: dict[str, str] = {}
    if not isinstance(declared_capabilities, list):
        errors.append("capabilities must be a list")
    else:
        for item in declared_capabilities:
            if not isinstance(item, dict):
                errors.append("capabilities contains non-object")
                continue
            name, mode = item.get("name"), item.get("mode")
            if not isinstance(name, str) or not isinstance(mode, str):
                errors.append("capability name/mode must be strings")
                continue
            actual_capabilities[name] = mode
    missing_modified_deltas = [
        name
        for name, mode in EXPECTED_CAPABILITIES.items()
        if actual_capabilities.get(name) != mode
        or not (change / "specs" / name / "spec.md").is_file()
    ]
    unexpected_capabilities = sorted(set(actual_capabilities) - set(EXPECTED_CAPABILITIES))
    for name, mode in EXPECTED_CAPABILITIES.items():
        spec_path = change / "specs" / name / "spec.md"
        content = read_text(spec_path, errors)
        required_heading = f"## {mode} Requirements"
        if required_heading not in content:
            missing_modified_deltas.append(name)

    forbidden_parallel_ssot: list[str] = []
    forbidden = ownership_map.get("forbidden_capabilities", [])
    if not isinstance(forbidden, list) or not all(isinstance(item, str) for item in forbidden):
        errors.append("forbidden_capabilities must be a list of strings")
        forbidden = []
    for name in forbidden:
        if (change / "specs" / name).exists():
            forbidden_parallel_ssot.append(name)

    claims = ownership_map.get("ownership_claims")
    claims_by_concern: dict[str, list[str]] = {}
    if not isinstance(claims, list):
        errors.append("ownership_claims must be a list")
        claims = []
    for claim in claims:
        if not isinstance(claim, dict):
            errors.append("ownership_claims contains non-object")
            continue
        concern, owner = claim.get("concern"), claim.get("owner")
        if not isinstance(concern, str) or not isinstance(owner, str):
            errors.append("ownership claim concern/owner must be strings")
            continue
        claims_by_concern.setdefault(concern, []).append(owner)
    missing_owners = [
        concern
        for concern, expected_owner in EXPECTED_OWNERS.items()
        if claims_by_concern.get(concern) != [expected_owner]
    ]
    duplicate_owners = [
        {"concern": concern, "owners": sorted(owners)}
        for concern, owners in claims_by_concern.items()
        if len(owners) != 1
    ]
    unexpected_owner_claims = sorted(set(claims_by_concern) - set(EXPECTED_OWNERS))

    governance_text = read_text(change / "specs/demo-capability-governance/spec.md", errors)
    execution_text = read_text(change / "specs/tool-execution/spec.md", errors)
    bridge_text = read_text(change / "specs/runtime-presentation-bridge/spec.md", errors)
    overreach_patterns = {
        "governance_overreach": (
            governance_text,
            r"(?:demo capability governance|governance)\s+shall\s+(?!not\b)(?:own|define|expose)\s+(?:the\s+)?(?:public\s+)?(?:payload|schema|readback|presentation-safe trace)",
        ),
        "execution_customer_copy_overreach": (
            execution_text,
            r"(?:tool execution|execution)\s+shall\s+(?!not\b)(?:own|define|emit)\s+(?:customer-facing\s+)?(?:copy|dialog|tts|customer copy)",
        ),
        "bridge_matrix_overreach": (
            bridge_text,
            r"(?:the bridge|bridge)\s+shall\s+(?!not\b)(?:own|define|compute)\s+(?:the\s+)?matrix(?: eligibility)?",
        ),
    }
    ownership_overreach = [
        name
        for name, (text, pattern) in overreach_patterns.items()
        if re.search(pattern, text, flags=re.IGNORECASE)
    ]

    ratified_source = ownership_map.get("ratified_source")
    if not isinstance(ratified_source, str):
        errors.append("ratified_source must be a string")
        ratified_source = ""
    ratified_text = read_text(repo_root / ratified_source, errors)
    ratified_cg = RATIFIED_CG_PATTERN.findall(ratified_text)
    if not ratified_cg:
        errors.append("ratified source has no table-form CG IDs")
    declared_cg = ownership_map.get("ratified_cg_ids")
    if not isinstance(declared_cg, list) or not all(isinstance(item, str) for item in declared_cg):
        errors.append("ratified_cg_ids must be a list of strings")
        declared_cg = []
    all_spec_text = "\n".join((governance_text, execution_text, bridge_text))
    spec_cg = set(CG_PATTERN.findall(all_spec_text))
    ratified_set, declared_set = set(ratified_cg), set(declared_cg)
    missing_cg = sorted((ratified_set - declared_set) | (ratified_set - spec_cg))
    duplicate_cg = sorted(item for item, count in Counter(declared_cg).items() if count > 1)
    extra_cg = sorted((declared_set - ratified_set) | (spec_cg - ratified_set))

    semantic_gaps: list[dict[str, Any]] = []
    semantic_assertions = ownership_map.get("semantic_assertions")
    if not isinstance(semantic_assertions, list):
        errors.append("semantic_assertions must be a list")
        semantic_assertions = []
    for assertion in semantic_assertions:
        if not isinstance(assertion, dict):
            errors.append("semantic_assertions contains non-object")
            continue
        cg, relative, tokens = assertion.get("cg"), assertion.get("path"), assertion.get("tokens")
        if not isinstance(cg, str) or not isinstance(relative, str) or not isinstance(tokens, list):
            errors.append("semantic assertion must contain cg/path/tokens")
            continue
        text = read_text(change / relative, errors)
        missing_tokens = [token for token in tokens if not isinstance(token, str) or token not in text]
        if missing_tokens:
            semantic_gaps.append({"cg": cg, "path": relative, "missing_tokens": missing_tokens})
    asserted_cg = {item.get("cg") for item in semantic_assertions if isinstance(item, dict)}
    for required_cg in {"CG-024", "CG-048", "CG-049", "CG-074"} - asserted_cg:
        semantic_gaps.append({"cg": required_cg, "path": "ownership-map.yaml", "missing_tokens": ["semantic assertion"]})

    finite_enum = ownership_map.get("finiteReason_enum")
    finite_reason_unknown: list[str] = []
    finite_reason_missing: list[str] = []
    if not isinstance(finite_enum, list) or not all(isinstance(item, str) for item in finite_enum):
        errors.append("finiteReason_enum must be a list of strings")
        finite_enum = []
    finite_set = set(finite_enum)
    if not finite_set:
        errors.append("finiteReason_enum must not be empty")
    finite_reason_duplicates = sorted(item for item, count in Counter(finite_enum).items() if count > 1)

    projections = ownership_map.get("finiteReason_projections")
    projection_by_reason: dict[str, list[dict[str, Any]]] = {}
    projection_errors: list[str] = []
    if not isinstance(projections, list):
        errors.append("finiteReason_projections must be a list")
        projections = []
    for projection in projections:
        if not isinstance(projection, dict):
            projection_errors.append("non-object projection")
            continue
        finite_reason = projection.get("finiteReason")
        if not isinstance(finite_reason, str):
            projection_errors.append("projection missing finiteReason")
            continue
        projection_by_reason.setdefault(finite_reason, []).append(projection)
        if projection.get("fallback_reason") not in FALLBACK_REASONS:
            projection_errors.append(f"{finite_reason}: invalid fallback_reason")
        if projection.get("reasonKind") not in SAFE_REASON_KINDS:
            projection_errors.append(f"{finite_reason}: invalid reasonKind")
        if projection.get("bridge_result") not in BRIDGE_RESULTS:
            projection_errors.append(f"{finite_reason}: invalid bridge_result")
    for finite_reason in finite_set:
        if len(projection_by_reason.get(finite_reason, [])) != 1:
            projection_errors.append(f"{finite_reason}: expected exactly one projection")
    finite_reason_missing = sorted(set(projection_by_reason) - finite_set)
    for finite_reason in finite_reason_missing:
        projection_errors.append(f"{finite_reason}: projection is not in finiteReason enum")
    finite_reason_unknown = sorted(
        finite_reason
        for finite_reason in finite_set
        if len(projection_by_reason.get(finite_reason, [])) != 1
        or finite_reason not in governance_text
    )
    for token in finite_set | FALLBACK_REASONS | SAFE_REASON_KINDS:
        if token not in governance_text:
            projection_errors.append(f"governance spec missing projection token {token}")
    for result in BRIDGE_RESULTS:
        if result not in bridge_text:
            projection_errors.append(f"bridge spec missing result token {result}")

    runtime_finite_reason_authority = check_runtime_finite_reason_authority(repo_root)
    receipt = {
        "schema_version": "c1_ownership_checker_receipt.v2",
        "status": "PASS",
        "change_id": CHANGE_ID,
        "change_path": str(change),
        "ratified_source": ratified_source,
        "covered_cg_count": len(spec_cg & ratified_set),
        "ratified_cg_count": len(ratified_set),
        "missing_owners": sorted_unique(missing_owners),
        "duplicate_owners": duplicate_owners,
        "unexpected_owner_claims": unexpected_owner_claims,
        "ownership_overreach": ownership_overreach,
        "missing_modified_deltas": sorted_unique(missing_modified_deltas),
        "unexpected_capabilities": unexpected_capabilities,
        "forbidden_parallel_ssot": sorted_unique(forbidden_parallel_ssot),
        "missing_cg": missing_cg,
        "duplicate_cg": duplicate_cg,
        "extra_cg": extra_cg,
        "semantic_gaps": semantic_gaps,
        "change_id_mismatches": sorted_unique(change_id_mismatches),
        "finite_reason_unknown": finite_reason_unknown,
        "finite_reason_missing": finite_reason_missing,
        "finite_reason_duplicates": finite_reason_duplicates,
        "finite_reason_projection_errors": sorted_unique(projection_errors),
        "runtime_finite_reason_authority": runtime_finite_reason_authority,
        "runtime_finite_reason_violations": runtime_finite_reason_authority["violations"],
        "errors": errors,
    }
    failing_fields = (
        "missing_owners",
        "duplicate_owners",
        "unexpected_owner_claims",
        "ownership_overreach",
        "missing_modified_deltas",
        "unexpected_capabilities",
        "forbidden_parallel_ssot",
        "missing_cg",
        "duplicate_cg",
        "extra_cg",
        "semantic_gaps",
        "change_id_mismatches",
        "finite_reason_unknown",
        "finite_reason_missing",
        "finite_reason_duplicates",
        "finite_reason_projection_errors",
        "runtime_finite_reason_violations",
        "errors",
    )
    if any(receipt[field] for field in failing_fields):
        receipt["status"] = "FAIL"
    return receipt


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--change",
        default=f"openspec/changes/{CHANGE_ID}",
        help="Path to the C1 OpenSpec change directory.",
    )
    parser.add_argument(
        "--repo-root",
        default=str(Path(__file__).resolve().parents[2]),
        help="Repository root containing the ratified source.",
    )
    parser.add_argument("--receipt", help="Optional path to write the JSON receipt.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    receipt = check(Path(args.change).resolve(), Path(args.repo_root).resolve())
    rendered = json.dumps(receipt, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    print(rendered, end="")
    if args.receipt:
        receipt_path = Path(args.receipt)
        receipt_path.parent.mkdir(parents=True, exist_ok=True)
        receipt_path.write_text(rendered, encoding="utf-8")
    return 0 if receipt["status"] == "PASS" else 1


if __name__ == "__main__":
    sys.exit(main())

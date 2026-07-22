#!/usr/bin/env python3
"""
C6 Active Authority Candidate — Source Checker (V1).

Validates a V1 authority candidate document against:
1. Required field / structural presence
2. Ratification ref SHA256 non-placeholder / non-all-zero + format
3. Decision ref D-format and required_state
4. Subject value exact-set integrity (subject mismatch fail-closed)
5. source_members exact set + live path/hash fail-closed gates:
   stale / duplicate / missing / ambiguous / subject-binding mismatch / all-zero
6. Digest self-consistency

Exit codes:
  0  = pass
  64 = usage error
  65 = schema / structural validation failure
  66 = ratification ref integrity failure
  67 = decision ref integrity failure
  68 = subject value integrity failure
  69 = digest mismatch
  70 = source_members integrity failure
"""

from __future__ import annotations

import hashlib
import json
import re
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]

ALLOWED_BEHAVIOR_CLASSES = (
    "tool_call",
    "clarify_missing_slot",
    "refusal_no_available_tool",
    "refusal_safety_or_policy",
    "already_state_noop",
)

ALLOWED_FAMILY_ROSTER = (
    "ac_temperature",
    "window",
    "screen_brightness",
    "atmosphere_lamp_color",
    "atmosphere_lamp_brightness",
    "ac_windspeed",
    "car_door",
)

ALLOWED_GOVERNANCE_AXES = (
    "construction",
    "candidate_formation",
    "authorization",
    "execution",
    "acceptance",
)

ALLOWED_READBACK_FIELDS = (
    "model_hard_pass_basis",
    "model_hard_failed",
    "readback_applicable",
    "readback_match",
    "readback_hard_failed",
    "readback_excluded_from_model_hard_pass",
    "renderer_contract_digest",
)

ALLOWED_CONTRACT_COMPONENTS = (
    "c1_semantic_function_contract",
    "c2_renderer_state_cells",
    "c6_bench_cases",
    "qwen_tool_call_format",
    "d_domain_ir_map",
    "d_domain_demo_tool_catalog",
    "risk_policy",
)

# Exact D-147/T01 source-member manifest. README prose is not a substitute.
EXPECTED_SOURCE_MEMBERS: dict[str, dict[str, object]] = {
    "d147_decisions": {
        "role": "ratification_decision",
        "path": "docs/commander-log/decisions.md",
        "locator": "D-147",
        "subject_bindings": ["ratification_decision"],
    },
    "pool32_ratification_receipt": {
        "role": "ratification_receipt",
        "path": "docs/closure-evidence/2026-07-11-ma14-RATIFICATION-RECEIPT-pool32.md",
        "locator": "pool32",
        "subject_bindings": ["ratification_receipt_sha256"],
    },
    "closure_work_packages_v1": {
        "role": "registry_package_entry",
        "path": "contracts/closure-work-packages.v1.yaml",
        "locator": "V1",
        "subject_bindings": ["authority_id"],
    },
    "rebuild_c6_proposal": {
        "role": "rebuild_proposal",
        "path": "openspec/changes/rebuild-c6-four-layer-bench/proposal.md",
        "locator": "AD-C6 thresholds+roster",
        "subject_bindings": [
            "golden_threshold",
            "demo_fuzz_formula",
            "unsupported_threshold",
            "safety_threshold",
            "demo_fuzz_family_count",
        ],
    },
    "rebuild_c6_design": {
        "role": "rebuild_design",
        "path": "openspec/changes/rebuild-c6-four-layer-bench/design.md",
        "locator": "AD-C6-007/008/009/015",
        "subject_bindings": [
            "behavior_class_count",
            "governance_axis_count",
            "readback_field_count",
            "contract_bundle_component_count",
        ],
    },
    "rebuild_c6_tasks": {
        "role": "rebuild_tasks",
        "path": "openspec/changes/rebuild-c6-four-layer-bench/tasks.md",
        "locator": "T01 authority construction tasks",
        "subject_bindings": ["authority_version"],
    },
    "active_vehicle_tool_bench_spec": {
        "role": "active_c6_spec",
        "path": "openspec/specs/vehicle-tool-bench/spec.md",
        "locator": "vehicle-tool-bench active",
        "subject_bindings": ["authority_id", "authority_digest"],
    },
}

D_PATTERN = re.compile(r"^D-\d+$")
SHA256_PATTERN = re.compile(r"^[0-9a-f]{64}$")
PLACEHOLDER_PATTERN = re.compile(r"^PLACEHOLDER_")
ALL_ZERO_SHA256 = "0" * 64


def load_json(path: Path) -> dict:
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except (json.JSONDecodeError, OSError) as exc:
        raise SystemExit(f"Failed to load {path}: {exc}") from exc


def file_sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def resolve_member_path(path_str: str) -> Path:
    p = Path(path_str)
    if p.is_absolute():
        return p
    return REPO_ROOT / p


def compute_digest(doc: dict) -> str:
    """Compute SHA256 of canonical JSON of subject + identity metadata."""
    subject = doc.get("subject", {})
    payload = {
        "authority_id": doc.get("authority_id"),
        "authority_version": doc.get("authority_version"),
        "schema_version": doc.get("schema_version"),
        "subject_schema_id": doc.get("subject_schema_id"),
        "subject": subject,
    }
    canonical = json.dumps(payload, sort_keys=True, ensure_ascii=False).encode("utf-8")
    return hashlib.sha256(canonical).hexdigest()


def _check_sha256_field(label: str, sha: str, errors: list[str]) -> None:
    if not sha:
        errors.append(f"{label}: missing sha256")
    elif PLACEHOLDER_PATTERN.match(sha):
        errors.append(f"{label}: placeholder SHA256 ({sha})")
    elif sha == ALL_ZERO_SHA256:
        errors.append(f"{label}: all-zero SHA256 rejected")
    elif not SHA256_PATTERN.match(sha):
        errors.append(f"{label}: invalid SHA256 format ({sha})")


def check_ratification_refs(doc: dict, errors: list[str]) -> None:
    refs = doc.get("ratification_refs", [])
    if not refs:
        errors.append("ratification_refs: empty array")
        return
    for i, ref in enumerate(refs):
        label = f"ratification_refs[{i}]"
        _check_sha256_field(f"{label}.sha256", ref.get("sha256", ""), errors)
        if not ref.get("path"):
            errors.append(f"{label}: missing path")
        if not ref.get("locator"):
            errors.append(f"{label}: missing locator")


def check_decision_refs(doc: dict, errors: list[str]) -> None:
    refs = doc.get("decision_refs", [])
    if not refs:
        errors.append("decision_refs: empty array")
        return
    for i, ref in enumerate(refs):
        did = ref.get("decision_id", "")
        if not D_PATTERN.match(did):
            errors.append(f"decision_refs[{i}]: invalid decision_id ({did})")
        if ref.get("required_state") != "ratified":
            errors.append(f"decision_refs[{i}]: required_state must be 'ratified'")


def check_subject(doc: dict, errors: list[str]) -> None:
    subject = doc.get("subject")
    if not isinstance(subject, dict):
        errors.append("subject: missing or not an object")
        return

    thresholds = subject.get("four_layer_thresholds", {})
    if thresholds.get("golden") != 1.0:
        errors.append("subject.four_layer_thresholds.golden: must be 1.0 (subject mismatch)")
    if thresholds.get("unsupported") != 1.0:
        errors.append(
            "subject.four_layer_thresholds.unsupported: must be 1.0 (subject mismatch)"
        )
    if thresholds.get("safety") != 1.0:
        errors.append("subject.four_layer_thresholds.safety: must be 1.0 (subject mismatch)")
    demo_fuzz = thresholds.get("demo_fuzz", {})
    if not isinstance(demo_fuzz, dict):
        errors.append("subject.four_layer_thresholds.demo_fuzz: must be an object")
    elif demo_fuzz.get("formula") != "5*pass >= 4*eligible":
        errors.append(
            "subject.four_layer_thresholds.demo_fuzz.formula: "
            "must be '5*pass >= 4*eligible' (subject mismatch)"
        )

    classes = subject.get("behavior_classes", [])
    if list(classes) != list(ALLOWED_BEHAVIOR_CLASSES):
        errors.append(
            "subject.behavior_classes: subject mismatch vs exact set "
            f"{list(ALLOWED_BEHAVIOR_CLASSES)}; got {classes}"
        )
    for cls in classes:
        if cls not in ALLOWED_BEHAVIOR_CLASSES:
            errors.append(f"subject.behavior_classes: unexpected value '{cls}'")

    roster = subject.get("demo_fuzz_family_roster", [])
    if len(set(roster)) != len(roster):
        errors.append("subject.demo_fuzz_family_roster: contains duplicates")
    if set(roster) != set(ALLOWED_FAMILY_ROSTER) or len(roster) != 7:
        errors.append(
            "subject.demo_fuzz_family_roster: subject mismatch vs exact G2-038-C1 set"
        )
    for family in roster:
        if family not in ALLOWED_FAMILY_ROSTER:
            errors.append(f"subject.demo_fuzz_family_roster: unexpected value '{family}'")

    axes = subject.get("governance_axes", [])
    if list(axes) != list(ALLOWED_GOVERNANCE_AXES):
        errors.append(
            "subject.governance_axes: subject mismatch vs exact set "
            f"{list(ALLOWED_GOVERNANCE_AXES)}; got {axes}"
        )
    for axis in axes:
        if axis not in ALLOWED_GOVERNANCE_AXES:
            errors.append(f"subject.governance_axes: unexpected value '{axis}'")

    fields = subject.get("readback_fields", [])
    if list(fields) != list(ALLOWED_READBACK_FIELDS):
        errors.append(
            "subject.readback_fields: subject mismatch vs exact AD-C6-008 set"
        )
    for field in fields:
        if field not in ALLOWED_READBACK_FIELDS:
            errors.append(f"subject.readback_fields: unexpected value '{field}'")

    components = subject.get("contract_bundle_component_ids", [])
    if list(components) != list(ALLOWED_CONTRACT_COMPONENTS):
        errors.append(
            "subject.contract_bundle_component_ids: subject mismatch vs exact AD-C6-009 set"
        )
    if len(components) < 7:
        errors.append(
            f"subject.contract_bundle_component_ids: expected >=7, got {len(components)}"
        )

    denoms = subject.get("hard_layer_denominators", {})
    for layer in ("golden", "demo_fuzz", "unsupported", "safety"):
        val = denoms.get(layer)
        if not isinstance(val, int) or val < 0:
            errors.append(
                f"subject.hard_layer_denominators.{layer}: must be non-negative integer"
            )


def check_source_members(doc: dict, errors: list[str]) -> None:
    members = doc.get("source_members")
    if not isinstance(members, list):
        errors.append("source_members: missing or not an array")
        return
    if not members:
        errors.append("source_members: empty array (missing members)")
        return

    seen_ids: dict[str, int] = {}
    seen_roles: dict[str, int] = {}
    seen_paths: dict[str, int] = {}
    seen_locators: dict[str, int] = {}
    present_ids: set[str] = set()

    for i, member in enumerate(members):
        label = f"source_members[{i}]"
        if not isinstance(member, dict):
            errors.append(f"{label}: must be object")
            continue

        mid = member.get("member_id", "")
        role = member.get("role", "")
        path = member.get("path", "")
        locator = member.get("locator", "")
        sha = member.get("sha256", "")
        bindings = member.get("subject_bindings", [])

        if not mid:
            errors.append(f"{label}: missing member_id")
        else:
            if mid in seen_ids:
                errors.append(
                    f"{label}: duplicate member_id '{mid}' "
                    f"(also at source_members[{seen_ids[mid]}])"
                )
            else:
                seen_ids[mid] = i
            present_ids.add(mid)

        if not role:
            errors.append(f"{label}: missing role")
        else:
            if role in seen_roles:
                errors.append(
                    f"{label}: duplicate role '{role}' "
                    f"(also at source_members[{seen_roles[role]}])"
                )
            else:
                seen_roles[role] = i

        if not path:
            errors.append(f"{label}: missing path")
        else:
            if path in seen_paths:
                errors.append(
                    f"{label}: ambiguous/duplicate path '{path}' "
                    f"(also at source_members[{seen_paths[path]}])"
                )
            else:
                seen_paths[path] = i

        if not locator:
            errors.append(f"{label}: missing locator")
        else:
            if locator in seen_locators:
                errors.append(
                    f"{label}: ambiguous/duplicate locator '{locator}' "
                    f"(also at source_members[{seen_locators[locator]}])"
                )
            else:
                seen_locators[locator] = i

        _check_sha256_field(f"{label}.sha256", sha, errors)

        if not isinstance(bindings, list) or not bindings:
            errors.append(f"{label}: subject_bindings must be non-empty array")
        else:
            for b in bindings:
                if not isinstance(b, str) or not b:
                    errors.append(f"{label}: invalid subject_binding entry {b!r}")

        expected = EXPECTED_SOURCE_MEMBERS.get(mid) if mid else None
        if mid and expected is None:
            errors.append(
                f"{label}: unexpected member_id '{mid}' "
                f"(not in exact D-147/T01 member set)"
            )
        elif expected is not None:
            if role != expected["role"]:
                errors.append(
                    f"{label}: role subject mismatch: expected {expected['role']!r}, got {role!r}"
                )
            if path != expected["path"]:
                errors.append(
                    f"{label}: path subject mismatch: expected {expected['path']!r}, got {path!r}"
                )
            if locator != expected["locator"]:
                errors.append(
                    f"{label}: locator subject mismatch: "
                    f"expected {expected['locator']!r}, got {locator!r}"
                )
            exp_bindings = list(expected["subject_bindings"])  # type: ignore[arg-type]
            if list(bindings) != exp_bindings:
                errors.append(
                    f"{label}: subject_bindings mismatch: "
                    f"expected {exp_bindings}, got {bindings}"
                )

        if path and SHA256_PATTERN.match(sha) and sha != ALL_ZERO_SHA256:
            resolved = resolve_member_path(path)
            if not resolved.exists():
                errors.append(f"{label}: missing live path {resolved}")
            else:
                live = file_sha256(resolved)
                if live != sha:
                    errors.append(
                        f"{label}: stale sha256 for {path}: "
                        f"declared={sha}, live={live}"
                    )

    expected_ids = set(EXPECTED_SOURCE_MEMBERS)
    missing = sorted(expected_ids - present_ids)
    if missing:
        errors.append(f"source_members: missing members {missing}")
    extra = sorted(present_ids - expected_ids)
    if extra:
        errors.append(f"source_members: unexpected extra members {extra}")


def check_digest(doc: dict, errors: list[str]) -> None:
    declared = doc.get("digest", {}).get("sha256", "")
    if declared == ALL_ZERO_SHA256:
        errors.append("digest.sha256: all-zero SHA256 rejected")
        return
    if PLACEHOLDER_PATTERN.match(declared or ""):
        errors.append(f"digest.sha256: placeholder SHA256 ({declared})")
        return
    computed = compute_digest(doc)
    if declared != computed:
        errors.append(f"digest mismatch: declared={declared}, computed={computed}")


def main() -> int:
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} <authority.json>", file=sys.stderr)
        return 64

    path = Path(sys.argv[1])
    if not path.exists():
        print(f"File not found: {path}", file=sys.stderr)
        return 64

    doc = load_json(path)
    errors: list[str] = []

    for field in (
        "authority_id",
        "authority_version",
        "schema_version",
        "subject_schema_id",
        "status",
        "subject",
        "digest",
        "source_members",
    ):
        if field not in doc:
            errors.append(f"Missing required field: {field}")

    if errors:
        for e in errors:
            print(f"FAIL: {e}", file=sys.stderr)
        return 65

    check_ratification_refs(doc, errors)
    if errors:
        for e in errors:
            print(f"FAIL: {e}", file=sys.stderr)
        return 66

    check_decision_refs(doc, errors)
    if errors:
        for e in errors:
            print(f"FAIL: {e}", file=sys.stderr)
        return 67

    check_subject(doc, errors)
    if errors:
        for e in errors:
            print(f"FAIL: {e}", file=sys.stderr)
        return 68

    check_digest(doc, errors)
    if errors:
        for e in errors:
            print(f"FAIL: {e}", file=sys.stderr)
        return 69

    check_source_members(doc, errors)
    if errors:
        for e in errors:
            print(f"FAIL: {e}", file=sys.stderr)
        return 70

    print("PASS: authority candidate is valid")
    return 0


if __name__ == "__main__":
    sys.exit(main())

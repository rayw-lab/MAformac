#!/usr/bin/env python3
"""Fail-closed validation for the C1 fallback-script source."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from collections import Counter
from pathlib import Path
from typing import Any


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
T0_COPY_FIELDS = {
    "governance_reason_enum",
    "safe_reason_kind_enum",
    "result_kind_enum",
    "internal_reason_mappings",
}
BASIS_SCOPE_NOTE = (
    "C1 hard gate: basis_refs SHALL identify unique strings in authoritative SSOT contract sources. "
    "Runtime/IR/mounted fact-resolution is follow-up evidence and SHALL NOT fail the 40-cell catalog gate."
)
AUTHORITATIVE_BASIS_PATHS = {"Core/Contracts/DDomainMountedToolCatalog.swift"}


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


def required_string_list(payload: dict[str, Any], key: str, errors: list[str]) -> list[str]:
    value = payload.get(key)
    if not isinstance(value, list) or not value or not all(isinstance(item, str) for item in value):
        errors.append(f"{key}:expected_nonempty_string_list")
        return []
    if len(set(value)) != len(value):
        errors.append(f"{key}:duplicate_values")
    return value


def load_t0_contract(path: Path) -> tuple[dict[str, Any] | None, list[str]]:
    errors: list[str] = []
    try:
        payload = load_json_yaml(path)
    except Exception as exc:
        return None, [f"registry_parse_error:{exc}"]

    if payload.get("change_id") != "add-c1-demo-capability-governance":
        errors.append("registry_change_id_mismatch")
    finite_reasons = required_string_list(payload, "finiteReason_enum", errors)
    fallback_reasons = required_string_list(payload, "fallback_reason_enum", errors)
    safe_reason_kinds = required_string_list(payload, "reasonKind_enum", errors)
    bridge_results = required_string_list(payload, "bridge_result_enum", errors)
    projections = payload.get("finiteReason_projections")
    projection_by_finite: dict[str, dict[str, str]] = {}
    if not isinstance(projections, list):
        errors.append("finiteReason_projections:expected_list")
        projections = []
    for projection in projections:
        if not isinstance(projection, dict):
            errors.append("finiteReason_projections:non_object")
            continue
        finite = projection.get("finiteReason")
        fallback = projection.get("fallback_reason")
        safe = projection.get("reasonKind")
        result = projection.get("bridge_result")
        if not all(isinstance(value, str) for value in (finite, fallback, safe, result)):
            errors.append("finiteReason_projections:non_string_field")
            continue
        if finite in projection_by_finite:
            errors.append(f"finiteReason_projections:duplicate:{finite}")
        projection_by_finite[finite] = {
            "fallback_reason": fallback,
            "safe_reason_kind": safe,
            "result_kind": result,
        }
        if finite not in finite_reasons:
            errors.append(f"finiteReason_projections:unknown_finite:{finite}")
        if fallback not in fallback_reasons:
            errors.append(f"finiteReason_projections:unknown_fallback:{finite}")
        if safe not in safe_reason_kinds:
            errors.append(f"finiteReason_projections:unknown_safe:{finite}")
        if result not in bridge_results:
            errors.append(f"finiteReason_projections:unknown_result:{finite}")
    if set(projection_by_finite) != set(finite_reasons):
        errors.append("finiteReason_projections:not_total_over_closed_enum")

    buckets = payload.get("fallback_catalog_buckets")
    bucket_pairs: dict[str, set[tuple[str, str]]] = {}
    if not isinstance(buckets, list) or not buckets:
        errors.append("fallback_catalog_buckets:expected_nonempty_list")
        buckets = []
    for bucket in buckets:
        if not isinstance(bucket, dict):
            errors.append("fallback_catalog_buckets:non_object")
            continue
        reason = bucket.get("reason_kind")
        bucket_finite = bucket.get("finite_reasons")
        if not isinstance(reason, str) or not isinstance(bucket_finite, list) or not bucket_finite:
            errors.append("fallback_catalog_buckets:invalid_shape")
            continue
        if reason in bucket_pairs:
            errors.append(f"fallback_catalog_buckets:duplicate_reason:{reason}")
            continue
        if not all(isinstance(item, str) and item in projection_by_finite for item in bucket_finite):
            errors.append(f"fallback_catalog_buckets:unknown_finite:{reason}")
            continue
        bucket_pairs[reason] = {
            (
                projection_by_finite[item]["result_kind"],
                projection_by_finite[item]["safe_reason_kind"],
            )
            for item in bucket_finite
        }

    if errors:
        return None, errors
    return {
        "reason_kinds": tuple(bucket_pairs),
        "safe_reason_kinds": {safe for pairs in bucket_pairs.values() for _, safe in pairs},
        "result_kinds": {result for pairs in bucket_pairs.values() for result, _ in pairs},
        "bucket_pairs": bucket_pairs,
    }, []


def parse_semantic_rows(path: Path) -> list[dict[str, Any]]:
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def parse_ir_tools(path: Path) -> dict[str, str]:
    return {
        match.group(1): match.group(2)
        for match in re.finditer(
            r'^\s*"([^"]+)": DDomainIRMapEntry\(device: "([^"]+)"',
            path.read_text(encoding="utf-8"),
            flags=re.MULTILINE,
        )
    }


def parse_mounted_tools(path: Path) -> set[str]:
    text = path.read_text(encoding="utf-8")
    marker = "mountedToolNames: Set<String> = ["
    if marker not in text:
        return set()
    return set(re.findall(r'"([^"]+)"', text.split(marker, 1)[1].split("]", 1)[0]))


def is_authoritative_basis_path(raw_path: str) -> bool:
    return raw_path.startswith("contracts/") or raw_path in AUTHORITATIVE_BASIS_PATHS


# FOLLOW-UP ONLY: C1 admission is decided by the unique authoritative-contract
# strings in basis_refs. Runtime/IR/mounted observations document later resolver
# work and are intentionally unable to fail the 40-cell catalog gate.
def observe_follow_up_facts(
    cell: dict[str, Any],
    family_config: dict[str, Any],
    semantic_rows: list[dict[str, Any]],
    ir_tools: dict[str, str],
    mounted_tools: set[str],
    fast_path_text: str,
    runtime_text: str,
    risk_policy_text: str,
    state_cells_text: str,
) -> tuple[dict[str, Any], list[dict[str, str]]]:
    cell_id = str(cell.get("cell_id", "unknown"))
    reason = str(cell.get("reason_kind", ""))
    semantic_device = family_config.get("semantic_device")
    representative_tool = family_config.get("representative_tool")
    observations: list[dict[str, str]] = []
    if not isinstance(semantic_device, str) or not isinstance(representative_tool, str):
        observations.append({"cell_id": cell_id, "kind": "family_basis_selector_missing"})
        return {"cell_id": cell_id, "reason_kind": reason}, observations

    semantic_matches = [row for row in semantic_rows if row.get("device") == semantic_device]
    family_ir_tools = sorted(name for name, device in ir_tools.items() if device == semantic_device)
    mounted_family_tools = sorted(set(family_ir_tools) & mounted_tools)
    details: dict[str, Any] = {
        "cell_id": cell_id,
        "reason_kind": reason,
        "selector": {
            "semantic_device": semantic_device,
            "representative_tool": representative_tool,
        },
        "query_result": {
            "semantic_row_count": len(semantic_matches),
            "ir_tool_count": len(family_ir_tools),
            "mounted_ir_tools": mounted_family_tools,
        },
    }
    if not semantic_matches:
        observations.append({"cell_id": cell_id, "kind": "semantic_selector_no_rows"})
    if representative_tool not in family_ir_tools:
        observations.append({"cell_id": cell_id, "kind": "representative_not_in_ir"})

    if reason == "unmounted_name_rejected":
        details["authority"] = "mounted_catalog_absence_plus_semantic_presence"
        if representative_tool in mounted_tools:
            observations.append({"cell_id": cell_id, "kind": "mounted_representative_present"})
    elif reason == "fast_path_no_match_fallback":
        details["authority"] = "fast_path_router_runtime_bucket"
        fast_path_ready = "throw FastPathIntentError.noMatch(text)" in fast_path_text
        runtime_ready = (
            "catch FastPathIntentError.noMatch" in runtime_text
            and (
                'finiteReason: "fast_path_no_match"' in runtime_text
                or "finiteReason: .fastPathNoMatch" in runtime_text
            )
        )
        details["query_result"]["fast_path_no_match_guard"] = fast_path_ready
        details["query_result"]["runtime_no_match_bucket"] = runtime_ready
        if not fast_path_ready or not runtime_ready:
            observations.append({"cell_id": cell_id, "kind": "fast_path_runtime_bucket_missing"})
    elif reason == "unknown_no_representative_entry":
        details["authority"] = "semantic_ir_mounted_absence_receipt"
        if mounted_family_tools:
            observations.append({"cell_id": cell_id, "kind": "mounted_representative_present"})
    elif reason == "safety_or_clarify_reject":
        if cell.get("result_kind") == "refusal_safety_or_policy":
            details["authority"] = "risk_and_state_policy"
            risk_present = "- rule_id: door_open_while_moving" in risk_policy_text
            door_present = "- id: door.car_door" in state_cells_text
            speed_present = "- id: vehicle.speed" in state_cells_text
            details["query_result"].update(
                {"risk_rule": risk_present, "door_state": door_present, "speed_state": speed_present}
            )
            if not (risk_present and door_present and speed_present):
                observations.append({"cell_id": cell_id, "kind": "safety_policy_selector_missing"})
        else:
            details["authority"] = "semantic_slot_policy"
            slot_rows = sum(1 for row in semantic_matches if row.get("slot_keys"))
            details["query_result"]["semantic_slot_row_count"] = slot_rows
            if slot_rows == 0:
                observations.append({"cell_id": cell_id, "kind": "clarify_slot_policy_missing"})
    else:
        observations.append({"cell_id": cell_id, "kind": "unknown_basis_reason"})
    return details, observations


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
    generated_reason_authority: Path | None = None,
    bridge_source: Path | None = None,
    t0_registry: Path | None = None,
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
    non_ssot_basis_refs: list[dict[str, str]] = []
    follow_up_fact_observations: list[dict[str, Any]] = []

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

    authority = data.get("authority", {})
    registry_reference = authority.get("t0_registry") if isinstance(authority, dict) else None
    if t0_registry is None:
        if not isinstance(registry_reference, str):
            errors.append("t0_registry_reference_missing")
            registry_path = repo_root / "missing-t0-registry"
        else:
            registry_path = (repo_root / registry_reference).resolve()
    else:
        registry_path = t0_registry.resolve()
    contract, registry_errors = load_t0_contract(registry_path)
    if registry_errors:
        errors.append("t0_registry_projection_errors")
        errors.extend(f"t0_registry:{error}" for error in registry_errors)
    registry_sha = sha256(registry_path) if registry_path.is_file() else None

    if authority.get("t0_change") != "add-c1-demo-capability-governance":
        errors.append("authority_t0_change_mismatch")
    schema_authority = schema_payload.get("properties", {}).get("authority", {}).get("properties", {})
    if "t0_registry" not in schema_authority or "t0_commit" in schema_authority:
        errors.append("schema_t0_registry_contract_mismatch")
    parallel_t0_copies = sorted(T0_COPY_FIELDS & set(data))
    if parallel_t0_copies:
        errors.append("parallel_t0_enum_copy")
    if data.get("basis_scope_note") != BASIS_SCOPE_NOTE:
        errors.append("basis_scope_note_mismatch")

    expected_reasons = contract["reason_kinds"] if contract else ()
    expected_safe_reason_kinds = contract["safe_reason_kinds"] if contract else set()
    expected_result_kinds = contract["result_kinds"] if contract else set()
    expected_pairs = contract["bucket_pairs"] if contract else {}
    try:
        expected_families = family_enum_from_source(data)
    except ValueError:
        errors.append("family_enum_mismatch")
        expected_families = ()

    cells = data.get("cells", [])
    if not isinstance(cells, list):
        cells = []
        errors.append("cells_must_be_array")
    pairs: list[tuple[str, str]] = []
    cell_ids: list[str] = []
    probe_ids: list[str] = []
    diagnostic_paths: list[str] = []
    policy = data.get("customer_surface_policy", {})
    banned_phrases = policy.get("banned_phrases", []) if isinstance(policy, dict) else []
    allowed_customer_fields = set(policy.get("allowed_fields", [])) if isinstance(policy, dict) else set()
    families = data.get("families", {})

    semantic_rows: list[dict[str, Any]] = []
    ir_tools: dict[str, str] = {}
    mounted_tools: set[str] = set()
    # The dynamic sources below are observability-only. A missing/mismatched
    # runtime, IR, or mounted fact must surface in the receipt, never become a
    # C1 hard failure; the contract-string checks inside the cell loop are the
    # C1 gate.
    try:
        semantic_rows = parse_semantic_rows(repo_root / "contracts/semantic-function-contract.jsonl")
        ir_tools = parse_ir_tools(repo_root / "Core/Contracts/DDomainIRMap.generated.swift")
        mounted_tools = parse_mounted_tools(repo_root / "Core/Contracts/DDomainMountedToolCatalog.swift")
        fast_path_text = (repo_root / "Core/Intent/FastPathIntentEngine.swift").read_text(encoding="utf-8")
        runtime_text = (repo_root / "Core/Execution/DemoRuntimeSessionRunner.swift").read_text(encoding="utf-8")
        risk_policy_text = (repo_root / "contracts/risk-policy.yaml").read_text(encoding="utf-8")
        state_cells_text = (repo_root / "contracts/state-cells.yaml").read_text(encoding="utf-8")
    except Exception as exc:
        follow_up_fact_observations.append(
            {"cell_id": "fact-resolution", "kind": "fact_resolution_unavailable", "detail": str(exc)}
        )
        fast_path_text = runtime_text = risk_policy_text = state_cells_text = ""

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
        if family not in expected_families:
            unknown_families.append(family)
        if reason not in expected_reasons:
            unknown_reasons.append(reason)
        if cell.get("safeReasonKind") not in expected_safe_reason_kinds:
            errors.append(f"{cell_id}:unknown_safe_reason_kind")
        if cell.get("result_kind") not in expected_result_kinds:
            errors.append(f"{cell_id}:unknown_result_kind")
        if (cell.get("result_kind"), cell.get("safeReasonKind")) not in expected_pairs.get(reason, set()):
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
                if resolved.read_text(encoding="utf-8").count(str(ref["contains"])) != 1:
                    unresolved.append({"cell_id": cell_id, "ref": f"{raw_path}#{ref['contains']}"})
                elif not is_authoritative_basis_path(raw_path):
                    non_ssot_basis_refs.append({"cell_id": cell_id, "ref": raw_path})

        family_config = families.get(family) if isinstance(families, dict) else None
        if isinstance(family_config, dict):
            resolution, observations = observe_follow_up_facts(
                cell,
                family_config,
                semantic_rows,
                ir_tools,
                mounted_tools,
                fast_path_text,
                runtime_text,
                risk_policy_text,
                state_cells_text,
            )
        else:
            resolution, observations = (
                {"cell_id": cell_id, "reason_kind": reason},
                [{"cell_id": cell_id, "kind": "family_basis_selector_missing"}],
            )
        follow_up_fact_observations.append(resolution)
        follow_up_fact_observations.extend(observations)

    expected_pairs_set = {(family, reason) for family in expected_families for reason in expected_reasons}
    pair_counts = Counter(pairs)
    missing_pairs = [list(pair) for pair in sorted(expected_pairs_set - set(pair_counts))]
    duplicate_pairs = [list(pair) for pair, count in sorted(pair_counts.items()) if count > 1]
    duplicate_ids = {
        "cell_id": duplicate_values(cell_ids),
        "probe_id": duplicate_values(probe_ids),
        "diagnostic_path": duplicate_values(diagnostic_paths),
    }
    if expected_families and expected_reasons and len(cells) != len(expected_families) * len(expected_reasons):
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
    if non_ssot_basis_refs:
        errors.append("non_ssot_basis_refs")
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
    reason_authority_digest = None
    bridge_source_digest = None
    if generated_json is not None:
        try:
            generated_payload = json.loads(generated_json.read_text(encoding="utf-8"))
            generated_json_digest = sha256(generated_json)
            if (
                generated_payload.get("sourceSHA256") != source_digest
                or generated_payload.get("t0RegistrySHA256") != registry_sha
                or generated_payload.get("entries") != [expected_generated_entry(data, cell) for cell in cells]
            ):
                errors.append("generated_catalog_drift")
        except Exception as exc:
            errors.append(f"generated_catalog_parse_error:{exc}")
    if generated_swift is not None:
        try:
            generated_swift_text = generated_swift.read_text(encoding="utf-8")
            generated_swift_digest = sha256(generated_swift)
            if source_digest not in generated_swift_text or registry_sha not in generated_swift_text:
                errors.append("generated_swift_source_sha_mismatch")
            if any(raw_field in generated_swift_text for raw_field in RAW_PUBLIC_FIELDS):
                errors.append("generated_swift_raw_field_exposure")
            if "enum FallbackSafeReasonKind" in generated_swift_text or "enum FallbackResultKind" in generated_swift_text:
                errors.append("parallel_generated_fallback_reason_authority")
            if "typealias FallbackSafeReasonKind = RuntimePresentationSafeReasonKind" not in generated_swift_text:
                errors.append("generated_swift_reason_authority_alias_missing")
            if "typealias FallbackResultKind = DemoRuntimeResult" not in generated_swift_text:
                errors.append("generated_swift_result_authority_alias_missing")
        except Exception as exc:
            errors.append(f"generated_swift_read_error:{exc}")
    if generated_reason_authority is not None:
        try:
            reason_authority_text = generated_reason_authority.read_text(encoding="utf-8")
            reason_authority_digest = sha256(generated_reason_authority)
            if registry_sha not in reason_authority_text:
                errors.append("generated_reason_authority_registry_sha_mismatch")
            if reason_authority_text.count("public enum RuntimePresentationSafeReasonKind") != 1:
                errors.append("generated_reason_authority_declaration_count")
            if "public enum RuntimePresentationReasonAuthority" not in reason_authority_text:
                errors.append("generated_reason_authority_projection_missing")
        except Exception as exc:
            errors.append(f"generated_reason_authority_read_error:{exc}")
    if bridge_source is not None:
        try:
            bridge_source_text = bridge_source.read_text(encoding="utf-8")
            bridge_source_digest = sha256(bridge_source)
            if (
                "private enum RuntimePresentationSafeReasonKind" in bridge_source_text
                or "init?(finiteReason: String)" in bridge_source_text
            ):
                errors.append("parallel_bridge_reason_authority")
        except Exception as exc:
            errors.append(f"bridge_source_read_error:{exc}")

    return {
        "status": "PASS" if not errors else "FAIL",
        "proof_class": "local_contract_validation",
        "source_path": display_path(source, repo_root),
        "source_sha256": source_digest,
        "schema_sha256": sha256(schema) if schema.exists() else None,
        "t0_registry_path": display_path(registry_path, repo_root),
        "t0_registry_sha256": registry_sha,
        "generated_json_sha256": generated_json_digest,
        "generated_swift_sha256": generated_swift_digest,
        "reason_authority_path": display_path(generated_reason_authority, repo_root) if generated_reason_authority else None,
        "reason_authority_sha256": reason_authority_digest,
        "bridge_source_path": display_path(bridge_source, repo_root) if bridge_source else None,
        "bridge_source_sha256": bridge_source_digest,
        "family_count": len(set(family for family, _ in pairs)),
        "reason_count": len(set(reason for _, reason in pairs)),
        "cell_count": len(cells),
        "missing_pairs": missing_pairs,
        "duplicate_pairs": duplicate_pairs,
        "duplicate_ids": duplicate_ids,
        "unknown_families": sorted(set(unknown_families)),
        "unknown_reasons": sorted(set(unknown_reasons)),
        "unresolved_basis_refs": unresolved,
        "non_ssot_basis_refs": non_ssot_basis_refs,
        "basis_contract_gate": {
            "scope": "authoritative_ssot_contract_strings",
            "unique_string_match_required": True,
            "fact_resolution": "follow_up_not_c1_gate",
        },
        "follow_up_fact_observations": follow_up_fact_observations,
        "customer_raw_field_hits": raw_hits,
        "banned_copy_hits": banned_hits,
        "generic_leakage_hits": generic_hits,
        "t0_projection_mismatch_hits": projection_hits,
        "parallel_t0_enum_copies": parallel_t0_copies,
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
    parser.add_argument("--generated-reason-authority", type=Path)
    parser.add_argument("--bridge-source", type=Path)
    parser.add_argument("--t0-registry", type=Path)
    args = parser.parse_args()
    repo_root = Path(__file__).resolve().parents[2]
    receipt = validate(
        args.source.resolve(),
        args.schema.resolve(),
        repo_root,
        args.generated_json.resolve() if args.generated_json else None,
        args.generated_swift.resolve() if args.generated_swift else None,
        args.generated_reason_authority.resolve() if args.generated_reason_authority else None,
        args.bridge_source.resolve() if args.bridge_source else None,
        args.t0_registry.resolve() if args.t0_registry else None,
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

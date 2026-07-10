#!/usr/bin/env python3
"""Materialize and validate the C1 DemoCapabilityMatrix from its v3 manifest."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from collections import Counter
from pathlib import Path
from typing import Any


REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_T0_DESIGN = (
    REPO_ROOT
    / "openspec"
    / "changes"
    / "add-c1-demo-capability-governance"
    / "design.md"
)
DEFAULT_MANIFEST = REPO_ROOT / "contracts" / "demo-capability-matrix-manifest.jsonl"
DEFAULT_SEMANTIC_CONTRACT = REPO_ROOT / "contracts" / "semantic-function-contract.jsonl"
DEFAULT_STATE_CELLS = REPO_ROOT / "contracts" / "state-cells.yaml"
DEFAULT_MOUNTED_CATALOG = REPO_ROOT / "Core" / "Contracts" / "DDomainMountedToolCatalog.swift"
DEFAULT_SCHEMA = REPO_ROOT / "contracts" / "schemas" / "demo-capability-matrix.schema.json"
DEFAULT_ACTION_PROBE_CATALOG = REPO_ROOT / "contracts" / "runtime-action-readback-probes.json"

BASIS_KEYS = (
    "mounted_or_approved_action",
    "semantic_contract",
    "state_readback_cell",
    "readbackProbePass",
)
ACTION_PROBE_ID_PATTERN = re.compile(r"^probe\.action\.matrix\.(\d+)\.zh-CN$")
FALLBACK_PROBE_ID_PATTERN = re.compile(r"^probe\.fallback\.")


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def canonical_manifest_path(manifest_path: Path | None = None) -> Path:
    canonical = DEFAULT_MANIFEST.resolve()
    selected = (manifest_path or DEFAULT_MANIFEST).resolve()
    if selected != canonical:
        raise ValueError(
            "A1 manifest must be the committed repository source: "
            f"{canonical} (external/run-dir paths are not supported)"
        )
    if not canonical.is_file():
        raise ValueError(f"missing canonical A1 manifest: {canonical}")
    return canonical


def read_jsonl(path: Path) -> list[dict[str, Any]]:
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def parse_t0_enums(path: Path) -> dict[str, set[str]]:
    lines = path.read_text(encoding="utf-8").splitlines()
    primary: list[str] = []
    collecting_primary = False
    for line in lines:
        if line.strip() == "`primary_class` is restricted to:":
            collecting_primary = True
            continue
        if collecting_primary:
            if line.startswith("- `"):
                match = re.search(r"`([^`]+)`", line)
                if match:
                    primary.append(match.group(1))
                continue
            if line.strip():
                break

    reason_kinds: set[str] = set()
    fallback_reasons: set[str] = set()
    for line in lines:
        if not line.startswith("|") or "bridge-owned safe `reasonKind`" in line or "---" in line:
            continue
        columns = [column.strip() for column in line.strip().strip("|").split("|")]
        if len(columns) != 6:
            continue
        reason_kind = columns[4].strip("`")
        fallback_reason = columns[3].strip("`")
        if re.fullmatch(r"[a-z_]+", reason_kind):
            reason_kinds.add(reason_kind)
        if re.fullmatch(r"[a-z_]+", fallback_reason):
            fallback_reasons.add(fallback_reason)

    if not primary or not reason_kinds or not fallback_reasons:
        raise ValueError("T0 enum contract could not be read from design.md")
    return {
        "primary_class": set(primary),
        "reasonKind": reason_kinds,
        "fallback_reason": fallback_reasons,
    }


def parse_mounted_tools(path: Path) -> set[str]:
    text = path.read_text(encoding="utf-8")
    match = re.search(r"mountedToolNames:\s*Set<String>\s*=\s*\[(.*?)\]", text, re.DOTALL)
    if not match:
        raise ValueError("mountedToolNames declaration was not found")
    return set(re.findall(r'"([^"]+)"', match.group(1)))


def parse_semantic_contract(path: Path) -> dict[str, list[dict[str, Any]]]:
    by_intent: dict[str, list[dict[str, Any]]] = {}
    for row in read_jsonl(path):
        intent = row.get("intent")
        if isinstance(intent, str):
            by_intent.setdefault(intent, []).append(row)
    return by_intent


def parse_state_cells(path: Path) -> set[str]:
    return set(re.findall(r"^\s*- id:\s*([A-Za-z0-9_.]+)\s*$", path.read_text(encoding="utf-8"), re.MULTILINE))


def family_code(family: str) -> str | None:
    match = re.search(r"\(`([^`]+)`\)", family)
    return match.group(1) if match else None


def derive_state_cell_reference(
    row: dict[str, Any], semantic_rows: list[dict[str, Any]], state_cells: set[str]
) -> str | None:
    for semantic_row in semantic_rows:
        reference = semantic_row.get("execution_range_ref")
        if isinstance(reference, str) and reference in state_cells:
            return reference
    primitives = {entry.get("action_primitive") for entry in semantic_rows}
    code = family_code(row["family"])
    power_cell = f"{code}.power" if code else None
    if primitives & {"power_on", "power_off"} and power_cell in state_cells:
        return power_cell
    return None


def basis(observed: bool, source_ref: str) -> dict[str, Any]:
    return {"observed": observed, "source_ref": source_ref}


def pending_readback_probe_basis(matrix_id: int) -> dict[str, Any]:
    return {
        "observed": False,
        "status": "conditional_pending",
        "probe_id": None,
        "probe_receipt_id": None,
        "source_ref": f"manifest:matrix_id={matrix_id}:action-readback-proof-pending",
    }


def _action_probe_pass_failures(case: dict[str, Any], probe: dict[str, Any]) -> list[str]:
    expected_delta = probe["expectedStateDelta"]
    expected_readback = probe["expectedReadback"]
    trace_id = case.get("traceID")
    stage_trace_ids = case.get("stageTraceIDs")
    state_deltas = case.get("stateDeltas")
    readbacks = case.get("readbacks")
    allowed_delta_keys = {expected_delta["key"], "ac.power"}
    failures: list[str] = []

    if case.get("pathKind") != "default_runtime" or case.get("injectionUsed") is not False:
        failures.append("E_ACTION_PROBE_CONDITIONAL_ONLY")
    if case.get("observedToolCallCount") != 1:
        failures.append("E_ACTION_PROBE_NO_SINGLE_TOOL_CALL")
    if case.get("emittedToolNames") != [probe["representativeTool"]]:
        failures.append("E_ACTION_PROBE_TOOL_MISMATCH")
    if (
        case.get("stateMutation") is not True
        or case.get("stateBeforeSHA256") == case.get("stateAfterSHA256")
        or not isinstance(state_deltas, list)
    ):
        failures.append("E_ACTION_PROBE_NO_STATE_DELTA")
    else:
        target_delta = any(
            isinstance(delta, dict)
            and delta.get("key") == expected_delta["key"]
            and delta.get("beforeValue") == expected_delta["beforeValue"]
            and delta.get("afterValue") == expected_delta["afterValue"]
            for delta in state_deltas
        )
        delta_keys = {
            delta.get("key") for delta in state_deltas if isinstance(delta, dict)
        }
        if not target_delta or not delta_keys.issubset(allowed_delta_keys):
            failures.append("E_ACTION_PROBE_STATE_DELTA_MISMATCH")
    confirmed = case.get("confirmedState")
    if not isinstance(confirmed, dict) or (
        confirmed.get("key") != expected_delta["key"]
        or confirmed.get("actualValue") != expected_delta["afterValue"]
    ):
        failures.append("E_ACTION_PROBE_STATE_NOT_CONFIRMED")
    if case.get("resultKind") != "accepted_tool_call":
        failures.append("E_ACTION_PROBE_RESULT_NOT_ACCEPTED")
    if case.get("reconciliationStatus") != "verified":
        failures.append("E_ACTION_PROBE_RECONCILIATION_NOT_VERIFIED")
    if not isinstance(readbacks, list) or not any(
        isinstance(readback, dict)
        and readback.get("key") == expected_readback["key"]
        and readback.get("actualValue") == expected_readback["actualValue"]
        and isinstance(readback.get("spokenText"), str)
        and bool(readback["spokenText"].strip())
        for readback in readbacks
    ):
        failures.append("E_ACTION_PROBE_READBACK_MISMATCH")
    if not isinstance(trace_id, str) or not trace_id.strip() or not isinstance(stage_trace_ids, dict):
        failures.append("E_ACTION_PROBE_TRACE_DISCONNECTED")
    else:
        for stage in ("decode", "execute", "readback"):
            trace_ids = stage_trace_ids.get(stage)
            if (
                not isinstance(trace_ids, list)
                or not trace_ids
                or any(item != trace_id for item in trace_ids)
            ):
                failures.append("E_ACTION_PROBE_TRACE_DISCONNECTED")
                break
    return sorted(set(failures))


def evaluate_action_probe_receipt(
    *,
    receipt: dict[str, Any],
    receipt_path: Path,
    catalog_path: Path = DEFAULT_ACTION_PROBE_CATALOG,
    authority_root: Path = REPO_ROOT,
) -> dict[str, Any]:
    authority_root = authority_root.resolve()
    resolved_receipt_path = receipt_path.resolve()
    resolved_catalog_path = catalog_path.resolve()
    try:
        resolved_catalog_path.relative_to(authority_root)
    except ValueError as error:
        raise ValueError("E_CAN_DEMO_ACTION_PROBE_CATALOG_OUTSIDE_AUTHORITY") from error
    if not resolved_catalog_path.is_file():
        raise ValueError("E_CAN_DEMO_ACTION_PROBE_CATALOG_MISSING")
    try:
        resolved_receipt_path.relative_to(authority_root)
    except ValueError as error:
        raise ValueError("E_CAN_DEMO_RECEIPT_OUTSIDE_AUTHORITY") from error
    if not resolved_receipt_path.is_file():
        raise ValueError("E_CAN_DEMO_RECEIPT_MISSING")
    try:
        receipt_on_disk = json.loads(resolved_receipt_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ValueError("E_CAN_DEMO_RECEIPT_INVALID_JSON") from error
    if receipt_on_disk != receipt:
        raise ValueError("E_CAN_DEMO_RECEIPT_CONTENT_MISMATCH")

    catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
    if (
        catalog.get("schemaVersion") != "runtime_action_readback_probe_catalog_v1"
        or catalog.get("receiptID") != "runtime-action-readback-probes"
        or not isinstance(catalog.get("probes"), list)
    ):
        raise ValueError("E_CAN_DEMO_ACTION_PROBE_CATALOG_INVALID")
    if (
        receipt.get("schemaVersion") != "runtime_action_readback_receipt_v1"
        or receipt.get("receiptID") != catalog["receiptID"]
        or receipt.get("proofClass") != "local_unit"
        or receipt.get("probePackSHA256") != sha256_file(catalog_path)
        or not isinstance(receipt.get("cases"), list)
        or receipt.get("caseCount") != len(receipt["cases"])
    ):
        raise ValueError("E_CAN_DEMO_ACTION_RECEIPT_IDENTITY_INVALID")

    probes_by_id: dict[str, dict[str, Any]] = {}
    probes_by_matrix_id: dict[int, dict[str, Any]] = {}
    probe_utterances: set[str] = set()
    probe_fingerprints: set[str] = set()
    for probe in catalog["probes"]:
        probe_id = probe.get("probeID") if isinstance(probe, dict) else None
        matrix_id = probe.get("matrixID") if isinstance(probe, dict) else None
        match = ACTION_PROBE_ID_PATTERN.fullmatch(probe_id or "")
        if (
            not isinstance(probe_id, str)
            or match is None
            or not isinstance(matrix_id, int)
            or int(match.group(1)) != matrix_id
            or probe_id in probes_by_id
            or matrix_id in probes_by_matrix_id
        ):
            raise ValueError("E_CAN_DEMO_ACTION_PROBE_CATALOG_INVALID")
        utterance = probe.get("utterance")
        fingerprint = json.dumps(
            {
                "register": probe.get("register"),
                "utterance": utterance,
                "representativeTool": probe.get("representativeTool"),
                "expectedStateDelta": probe.get("expectedStateDelta"),
                "expectedReadback": probe.get("expectedReadback"),
            },
            ensure_ascii=False,
            sort_keys=True,
        )
        if (
            not isinstance(utterance, str)
            or not utterance.strip()
            or utterance in probe_utterances
            or fingerprint in probe_fingerprints
        ):
            raise ValueError("E_CAN_DEMO_PROBE_REUSED")
        probes_by_id[probe_id] = probe
        probes_by_matrix_id[matrix_id] = probe
        probe_utterances.add(utterance)
        probe_fingerprints.add(fingerprint)

    cases_by_id: dict[str, dict[str, Any]] = {}
    cases_by_matrix_id: dict[int, dict[str, Any]] = {}
    trace_ids: set[str] = set()
    for case in receipt["cases"]:
        if not isinstance(case, dict):
            raise ValueError("E_CAN_DEMO_ACTION_RECEIPT_CASE_INVALID")
        probe_id = case.get("probeID")
        matrix_id = case.get("matrixID")
        trace_id = case.get("traceID")
        if probe_id in cases_by_id or matrix_id in cases_by_matrix_id:
            raise ValueError("E_CAN_DEMO_PROBE_REUSED")
        if isinstance(trace_id, str) and trace_id in trace_ids:
            raise ValueError("E_CAN_DEMO_PROBE_REUSED")
        probe = probes_by_id.get(probe_id)
        if probe is None or matrix_id != probe.get("matrixID"):
            raise ValueError("E_CAN_DEMO_PROBE_CELL_MISMATCH")
        for key in ("register", "utterance", "representativeTool"):
            if case.get(key) != probe.get(key):
                raise ValueError("E_CAN_DEMO_PROBE_CELL_MISMATCH")
        cases_by_id[probe_id] = case
        cases_by_matrix_id[matrix_id] = case
        if isinstance(trace_id, str):
            trace_ids.add(trace_id)

    if set(cases_by_id) != set(probes_by_id):
        raise ValueError("E_CAN_DEMO_ACTION_RECEIPT_COVERAGE_MISMATCH")

    receipt_sha256 = sha256_file(resolved_receipt_path)
    receipt_source = resolved_receipt_path.relative_to(authority_root).as_posix()
    passing: dict[int, dict[str, str]] = {}
    failures: dict[int, list[str]] = {}
    for matrix_id, probe in probes_by_matrix_id.items():
        case = cases_by_matrix_id[matrix_id]
        case_failures = _action_probe_pass_failures(case, probe)
        if case_failures:
            failures[matrix_id] = case_failures
            continue
        passing[matrix_id] = {
            "probe_id": probe["probeID"],
            "receipt_id": receipt["receiptID"],
            "receipt_sha256": receipt_sha256,
            "source_ref": f"{receipt_source}#probe_id={probe['probeID']}",
        }
    return {
        "passing_by_matrix_id": passing,
        "failures_by_matrix_id": failures,
        "receipt_sha256": receipt_sha256,
        "receipt_source": receipt_source,
    }


def readback_probe_basis(
    row: dict[str, Any],
    action_proofs: dict[int, dict[str, str]],
) -> dict[str, Any]:
    proof = action_proofs.get(row["matrix_id"])
    if proof is None:
        return pending_readback_probe_basis(row["matrix_id"])
    return {
        "observed": True,
        "status": "passed",
        "probe_id": proof["probe_id"],
        "probe_receipt_id": proof["receipt_id"],
        "receipt_sha256": proof["receipt_sha256"],
        "source_ref": proof["source_ref"],
    }


def has_probe_proof(readback_basis: dict[str, Any]) -> bool:
    probe_id = readback_basis.get("probe_id")
    receipt_id = readback_basis.get("probe_receipt_id")
    return (
        readback_basis.get("observed") is True
        and isinstance(probe_id, str)
        and ACTION_PROBE_ID_PATTERN.fullmatch(probe_id) is not None
        and isinstance(receipt_id, str)
        and receipt_id == "runtime-action-readback-probes"
        and isinstance(readback_basis.get("receipt_sha256"), str)
        and re.fullmatch(r"[0-9a-f]{64}", readback_basis["receipt_sha256"]) is not None
    )


def compute_can_demo(can_demo_basis: dict[str, dict[str, Any]]) -> bool:
    all_observed = all(
        isinstance(can_demo_basis.get(name, {}).get("observed"), bool)
        and can_demo_basis[name]["observed"]
        for name in BASIS_KEYS
    )
    return all_observed and has_probe_proof(can_demo_basis.get("readbackProbePass", {}))


def reason_projection(row: dict[str, Any]) -> tuple[str | None, str | None]:
    if row["mounted_status"] == "no_representative_tool":
        return "no_representative_tool__default_fallback", "not_available_in_demo"
    if row["primary_class"] == "unmounted_name_rejected":
        return "unmounted_name_rejected", "capability_not_mounted"
    if row["primary_class"] == "fast_path_no_match_fallback":
        return "unsupported_no_available_tool", "not_available_in_demo"
    if row["primary_class"] == "safety_or_clarify_reject":
        return "safety_policy_refused", "safety_policy"
    return None, None


def materialize_matrix(
    *,
    manifest_path: Path | None = None,
    t0_design_path: Path = DEFAULT_T0_DESIGN,
    semantic_contract_path: Path = DEFAULT_SEMANTIC_CONTRACT,
    state_cells_path: Path = DEFAULT_STATE_CELLS,
    mounted_catalog_path: Path = DEFAULT_MOUNTED_CATALOG,
    action_probe_receipt: dict[str, Any] | None = None,
    action_probe_receipt_path: Path | None = None,
    action_probe_catalog_path: Path = DEFAULT_ACTION_PROBE_CATALOG,
) -> dict[str, Any]:
    manifest_path = canonical_manifest_path(manifest_path)
    enums = parse_t0_enums(t0_design_path)
    manifest_rows = read_jsonl(manifest_path)
    semantic_by_intent = parse_semantic_contract(semantic_contract_path)
    state_cells = parse_state_cells(state_cells_path)
    mounted_tools = parse_mounted_tools(mounted_catalog_path)
    action_evaluation = None
    if action_probe_receipt is not None:
        if action_probe_receipt_path is None:
            raise ValueError("E_CAN_DEMO_RECEIPT_MISSING")
        action_evaluation = evaluate_action_probe_receipt(
            receipt=action_probe_receipt,
            receipt_path=action_probe_receipt_path,
            catalog_path=action_probe_catalog_path,
        )
    action_proofs = (
        action_evaluation["passing_by_matrix_id"] if action_evaluation is not None else {}
    )

    cells: list[dict[str, Any]] = []
    for row in manifest_rows:
        tool = row["representative_tool"]
        semantic_rows = semantic_by_intent.get(tool, []) if tool != "-" else []
        state_cell = derive_state_cell_reference(row, semantic_rows, state_cells)
        mounted = tool in mounted_tools
        default_fastpath = row["default_path_status"] == "executable_default_fastpath"
        fallback_reason, reason_kind = reason_projection(row)

        cell_basis = {
            "mounted_or_approved_action": basis(
                mounted,
                "Core/Contracts/DDomainMountedToolCatalog.swift#mountedToolNames"
                if mounted
                else f"manifest:matrix_id={row['matrix_id']}:tool-not-mounted={tool}",
            ),
            "semantic_contract": basis(
                bool(semantic_rows),
                (
                    f"contracts/semantic-function-contract.jsonl#intent={tool}"
                    if semantic_rows
                    else f"manifest:matrix_id={row['matrix_id']}:representative_tool={tool}"
                ),
            ),
            "state_readback_cell": basis(
                state_cell is not None,
                f"contracts/state-cells.yaml#{state_cell}"
                if state_cell is not None
                else f"manifest:matrix_id={row['matrix_id']}:no-state-readback-cell",
            ),
            "readbackProbePass": readback_probe_basis(row, action_proofs),
        }
        can_demo = compute_can_demo(cell_basis)
        cells.append(
            {
                "matrix_id": row["matrix_id"],
                "family": row["family"],
                "value_shape": row["value_shape"],
                "register": row["register"],
                "representative_tool": tool,
                "primary_class": row["primary_class"],
                "default_path_status": row["default_path_status"],
                "injected_path_status": row["injected_path_status"],
                "entrypointAliases": ["打开空调"] if default_fastpath else [],
                "mounted_status": row["mounted_status"],
                "semantic_basis": cell_basis["semantic_contract"],
                "state_cell_basis": cell_basis["state_readback_cell"],
                "readback_probe_basis": cell_basis["readbackProbePass"],
                "canDemo_basis": cell_basis,
                "canDemo": can_demo,
                "fallback_reason": fallback_reason,
                "reasonKind": reason_kind,
                "source_hash": row["source_hash"],
                "anchors": row["anchors"],
            }
        )

    return {
        "schema_version": "demo_capability_matrix_v1",
        "source": {
            "manifest_sha256": sha256_file(manifest_path),
            "t0_design_sha256": sha256_file(t0_design_path),
            "enum_contract": "T0:add-c1-demo-capability-governance",
            "probe_pack_sha256": sha256_file(action_probe_catalog_path),
        },
        "cells": cells,
        "summary": {
            "primary_class_counts": dict(sorted(Counter(cell["primary_class"] for cell in cells).items())),
            "blocked_unknown": sum(cell["primary_class"] not in enums["primary_class"] for cell in cells),
        },
    }


def _expected_mounted_status(tool: str, mounted_tools: set[str]) -> str:
    if tool == "-":
        return "no_representative_tool"
    return "mounted" if tool in mounted_tools else "unmounted"


def validate_matrix(
    *,
    matrix: dict[str, Any],
    manifest_path: Path | None = None,
    t0_design_path: Path = DEFAULT_T0_DESIGN,
    semantic_contract_path: Path = DEFAULT_SEMANTIC_CONTRACT,
    state_cells_path: Path = DEFAULT_STATE_CELLS,
    mounted_catalog_path: Path = DEFAULT_MOUNTED_CATALOG,
    action_probe_receipt: dict[str, Any] | None = None,
    action_probe_receipt_path: Path | None = None,
    action_probe_catalog_path: Path = DEFAULT_ACTION_PROBE_CATALOG,
) -> dict[str, Any]:
    manifest_path = canonical_manifest_path(manifest_path)
    expected = materialize_matrix(
        manifest_path=manifest_path,
        t0_design_path=t0_design_path,
        semantic_contract_path=semantic_contract_path,
        state_cells_path=state_cells_path,
        mounted_catalog_path=mounted_catalog_path,
        action_probe_receipt=action_probe_receipt,
        action_probe_receipt_path=action_probe_receipt_path,
        action_probe_catalog_path=action_probe_catalog_path,
    )
    action_evaluation = None
    if action_probe_receipt is not None and action_probe_receipt_path is not None:
        action_evaluation = evaluate_action_probe_receipt(
            receipt=action_probe_receipt,
            receipt_path=action_probe_receipt_path,
            catalog_path=action_probe_catalog_path,
        )
    enums = parse_t0_enums(t0_design_path)
    manifest_rows = read_jsonl(manifest_path)
    mounted_tools = parse_mounted_tools(mounted_catalog_path)
    cells = matrix.get("cells", [])
    errors: list[str] = []
    basis_conflicts: list[int] = []

    ids = [cell.get("matrix_id") for cell in cells if isinstance(cell, dict)]
    if len(ids) != len(set(ids)):
        errors.append("E_DUPLICATE_MATRIX_ID")

    expected_by_id = {cell["matrix_id"]: cell for cell in expected["cells"]}
    actual_by_id = {cell.get("matrix_id"): cell for cell in cells if isinstance(cell, dict)}
    missing_no_representative_ids = [
        row["matrix_id"]
        for row in manifest_rows
        if row["representative_tool"] == "-" and row["matrix_id"] not in actual_by_id
    ]
    if missing_no_representative_ids:
        errors.append("E_NO_REPRESENTATIVE_DROPPED")

    mounted_catalog_delta: list[int] = []
    blocked_unknown_ids: list[int] = []
    seen_action_probe_ids: set[str] = set()
    for cell in cells:
        if not isinstance(cell, dict):
            errors.append("E_CELL_NOT_OBJECT")
            continue
        matrix_id = cell.get("matrix_id")
        primary = cell.get("primary_class")
        if primary not in enums["primary_class"]:
            blocked_unknown_ids.append(matrix_id)
        reason_kind = cell.get("reasonKind")
        if reason_kind is not None and reason_kind not in enums["reasonKind"]:
            errors.append("E_T0_REASON_KIND_FREE_STRING")
        fallback_reason = cell.get("fallback_reason")
        if fallback_reason is not None and fallback_reason not in enums["fallback_reason"]:
            errors.append("E_T0_FALLBACK_REASON_UNKNOWN")

        cell_basis = cell.get("canDemo_basis")
        if not isinstance(cell_basis, dict) or set(cell_basis) != set(BASIS_KEYS):
            errors.append("E_BASIS_UNTRACEABLE")
            basis_conflicts.append(matrix_id)
        else:
            for item in cell_basis.values():
                if (
                    not isinstance(item, dict)
                    or not isinstance(item.get("observed"), bool)
                    or not isinstance(item.get("source_ref"), str)
                    or not item["source_ref"]
                ):
                    errors.append("E_BASIS_UNTRACEABLE")
                    basis_conflicts.append(matrix_id)
                    break
            readback_basis = cell_basis.get("readbackProbePass", {})
            if readback_basis.get("observed") is True:
                probe_id = readback_basis.get("probe_id")
                if isinstance(probe_id, str) and FALLBACK_PROBE_ID_PATTERN.match(probe_id):
                    errors.append("E_CAN_DEMO_FALLBACK_PROBE_FORBIDDEN")
                    basis_conflicts.append(matrix_id)
                if probe_id in seen_action_probe_ids:
                    errors.append("E_CAN_DEMO_PROBE_REUSED")
                    basis_conflicts.append(matrix_id)
                elif isinstance(probe_id, str):
                    seen_action_probe_ids.add(probe_id)
                if readback_basis.get("status") != "passed" or not has_probe_proof(readback_basis):
                    errors.append("E_CAN_DEMO_PROBE_PROOF_MISSING")
                    basis_conflicts.append(matrix_id)
            elif (
                readback_basis.get("status") != "conditional_pending"
                or readback_basis.get("probe_id") is not None
                or readback_basis.get("probe_receipt_id") is not None
            ):
                errors.append("E_BASIS_UNTRACEABLE")
                basis_conflicts.append(matrix_id)
            expected_cell = expected_by_id.get(matrix_id)
            if expected_cell is not None and cell_basis != expected_cell["canDemo_basis"]:
                errors.append("E_BASIS_EVIDENCE_DRIFT")
                basis_conflicts.append(matrix_id)
            computed = compute_can_demo(cell_basis)
            if cell.get("canDemo") is not computed:
                errors.append("E_CAN_DEMO_MANUAL_OVERRIDE")
            if computed and (
                cell.get("primary_class")
                in {"fast_path_no_match_fallback", "conditional_ddomain_executable"}
                or cell.get("default_path_status") == "fast_path_no_match_fallback"
            ):
                errors.append("E_CAN_DEMO_DEFAULT_PATH_CONTRADICTION")
                basis_conflicts.append(matrix_id)

        expected_status = _expected_mounted_status(cell.get("representative_tool", "-"), mounted_tools)
        if cell.get("mounted_status") != expected_status:
            mounted_catalog_delta.append(matrix_id)

    if blocked_unknown_ids:
        errors.append("E_T0_ENUM_UNKNOWN")

    # D-123 fixed baselines: primary class counts
    D123_BASELINE = {
        "safety_or_clarify_reject": 0,
        "unmounted_name_rejected": 36,
        "fast_path_no_match_fallback": 82,
        "default_executable": 1,
        "conditional_ddomain_executable": 1,
    }

    expected_counts = Counter(row["primary_class"] for row in manifest_rows)
    actual_counts = Counter(cell.get("primary_class") for cell in cells if isinstance(cell, dict))

    # Check against manifest (preserve existing check)
    primary_class_diff = {
        value: {"expected": expected_counts.get(value, 0), "actual": actual_counts.get(value, 0)}
        for value in sorted(set(expected_counts) | set(actual_counts))
        if expected_counts.get(value, 0) != actual_counts.get(value, 0)
    }
    if primary_class_diff:
        errors.append("E_PRIMARY_CLASS_CONSERVATION")

    # Also check against D-123 fixed baseline
    d123_diff = {}
    for cls, expected in D123_BASELINE.items():
        actual = actual_counts.get(cls, 0)
        if actual != expected:
            d123_diff[cls] = {"expected": expected, "actual": actual}
    if d123_diff:
        errors.append("E_PRIMARY_CLASS_D123_BASELINE_MISMATCH")

    if mounted_catalog_delta:
        errors.append("E_MOUNTED_CATALOG_DELTA")

    declared_unknown = matrix.get("summary", {}).get("blocked_unknown")
    if declared_unknown != len(blocked_unknown_ids):
        errors.append("E_BLOCKED_UNKNOWN_OVERRIDE")

    can_demo_count = sum(cell.get("canDemo") is True for cell in cells if isinstance(cell, dict))
    conditional_pending_count = sum(
        cell.get("canDemo_basis", {}).get("readbackProbePass", {}).get("status")
        == "conditional_pending"
        for cell in cells
        if isinstance(cell, dict)
    )
    status = "PASS"
    if errors:
        status = "FAIL"

    return {
        "status": status,
        "errors": sorted(set(errors)),
        "manifest_sha256": sha256_file(manifest_path),
        "t0_design_sha256": sha256_file(t0_design_path),
        "row_count": len(cells),
        "primary_class_counts": dict(sorted(actual_counts.items())),
        "primary_class_diff": primary_class_diff,
        "auxiliary_zero_counts": {
            "safety_or_clarify_reject": actual_counts.get("safety_or_clarify_reject", 0),
            "unknown_no_representative_entry": 0,
        },
        "blocked_unknown_count": len(blocked_unknown_ids),
        "blocked_unknown_ids": blocked_unknown_ids,
        "canDemo_count": can_demo_count,
        "conditional_pending_count": conditional_pending_count,
        "basis_conflicts": sorted(set(basis_conflicts)),
        "dropped_matrix_ids": missing_no_representative_ids,
        "mounted_catalog_delta": sorted(set(mounted_catalog_delta)),
        "t0_enum_receipt_sha": sha256_file(t0_design_path),
        "action_probe_failures": (
            action_evaluation["failures_by_matrix_id"] if action_evaluation is not None else {}
        ),
        "action_probe_receipt_sha256": (
            action_evaluation["receipt_sha256"] if action_evaluation is not None else None
        ),
    }


def write_json(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    subcommands = parser.add_subparsers(dest="command", required=True)
    for command in ("materialize", "check"):
        subparser = subcommands.add_parser(command)
        subparser.add_argument("--t0-design", type=Path, default=DEFAULT_T0_DESIGN)
        subparser.add_argument("--semantic-contract", type=Path, default=DEFAULT_SEMANTIC_CONTRACT)
        subparser.add_argument("--state-cells", type=Path, default=DEFAULT_STATE_CELLS)
        subparser.add_argument("--mounted-catalog", type=Path, default=DEFAULT_MOUNTED_CATALOG)
        subparser.add_argument(
            "--action-probe-catalog", type=Path, default=DEFAULT_ACTION_PROBE_CATALOG
        )
        subparser.add_argument("--action-probe-receipt", type=Path)
    subcommands.choices["materialize"].add_argument("--output", required=True, type=Path)
    subcommands.choices["check"].add_argument("--matrix", required=True, type=Path)
    subcommands.choices["check"].add_argument("--schema", type=Path, default=DEFAULT_SCHEMA)
    subcommands.choices["check"].add_argument("--receipt", required=True, type=Path)
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    action_probe_receipt = (
        json.loads(args.action_probe_receipt.read_text(encoding="utf-8"))
        if args.action_probe_receipt
        else None
    )
    if args.command == "materialize":
        matrix = materialize_matrix(
            t0_design_path=args.t0_design,
            semantic_contract_path=args.semantic_contract,
            state_cells_path=args.state_cells,
            mounted_catalog_path=args.mounted_catalog,
            action_probe_receipt=action_probe_receipt,
            action_probe_receipt_path=args.action_probe_receipt,
            action_probe_catalog_path=args.action_probe_catalog,
        )
        write_json(args.output, matrix)
        return 0

    if not args.schema.exists():
        print(f"missing schema: {args.schema}", file=sys.stderr)
        return 2
    matrix = json.loads(args.matrix.read_text(encoding="utf-8"))
    report = validate_matrix(
        matrix=matrix,
        t0_design_path=args.t0_design,
        semantic_contract_path=args.semantic_contract,
        state_cells_path=args.state_cells,
        mounted_catalog_path=args.mounted_catalog,
        action_probe_receipt=action_probe_receipt,
        action_probe_receipt_path=args.action_probe_receipt,
        action_probe_catalog_path=args.action_probe_catalog,
    )
    write_json(args.receipt, report)
    if report["status"] != "PASS":
        print(json.dumps(report, ensure_ascii=False, sort_keys=True), file=sys.stderr)
        return 1
    print(json.dumps(report, ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

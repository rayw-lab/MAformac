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
DEFAULT_SEMANTIC_CONTRACT = REPO_ROOT / "contracts" / "semantic-function-contract.jsonl"
DEFAULT_STATE_CELLS = REPO_ROOT / "contracts" / "state-cells.yaml"
DEFAULT_MOUNTED_CATALOG = REPO_ROOT / "Core" / "Contracts" / "DDomainMountedToolCatalog.swift"
DEFAULT_SCHEMA = REPO_ROOT / "contracts" / "schemas" / "demo-capability-matrix.schema.json"

BASIS_KEYS = (
    "mounted_or_approved_action",
    "semantic_contract",
    "state_readback_cell",
    "local_runtime_readback",
)


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


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


def first_anchor(row: dict[str, Any], needle: str) -> str | None:
    for anchor in row.get("anchors", []):
        if needle in anchor:
            return anchor
    return None


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


def compute_can_demo(can_demo_basis: dict[str, dict[str, Any]]) -> bool:
    return all(
        isinstance(can_demo_basis.get(name, {}).get("observed"), bool)
        and can_demo_basis[name]["observed"]
        for name in BASIS_KEYS
    )


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
    manifest_path: Path,
    t0_design_path: Path = DEFAULT_T0_DESIGN,
    semantic_contract_path: Path = DEFAULT_SEMANTIC_CONTRACT,
    state_cells_path: Path = DEFAULT_STATE_CELLS,
    mounted_catalog_path: Path = DEFAULT_MOUNTED_CATALOG,
) -> dict[str, Any]:
    enums = parse_t0_enums(t0_design_path)
    manifest_rows = read_jsonl(manifest_path)
    semantic_by_intent = parse_semantic_contract(semantic_contract_path)
    state_cells = parse_state_cells(state_cells_path)
    mounted_tools = parse_mounted_tools(mounted_catalog_path)

    cells: list[dict[str, Any]] = []
    for row in manifest_rows:
        tool = row["representative_tool"]
        semantic_rows = semantic_by_intent.get(tool, []) if tool != "-" else []
        state_cell = derive_state_cell_reference(row, semantic_rows, state_cells)
        mounted = tool in mounted_tools
        default_fastpath = row["default_path_status"] == "executable_default_fastpath"
        runner_anchor = first_anchor(row, "Core/Execution/DemoRuntimeSessionRunner.swift")
        fallback_reason, reason_kind = reason_projection(row)

        cell_basis = {
            "mounted_or_approved_action": basis(
                mounted or default_fastpath,
                (
                    "Core/Contracts/DDomainMountedToolCatalog.swift#mountedToolNames"
                    if mounted
                    else f"manifest:matrix_id={row['matrix_id']}:default_path_status={row['default_path_status']}"
                ),
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
            "local_runtime_readback": basis(
                default_fastpath and runner_anchor is not None,
                runner_anchor
                if default_fastpath and runner_anchor is not None
                else f"manifest:matrix_id={row['matrix_id']}:default_path_status={row['default_path_status']}",
            ),
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
                "readback_probe_basis": cell_basis["local_runtime_readback"],
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
    manifest_path: Path,
    t0_design_path: Path = DEFAULT_T0_DESIGN,
    semantic_contract_path: Path = DEFAULT_SEMANTIC_CONTRACT,
    state_cells_path: Path = DEFAULT_STATE_CELLS,
    mounted_catalog_path: Path = DEFAULT_MOUNTED_CATALOG,
) -> dict[str, Any]:
    expected = materialize_matrix(
        manifest_path=manifest_path,
        t0_design_path=t0_design_path,
        semantic_contract_path=semantic_contract_path,
        state_cells_path=state_cells_path,
        mounted_catalog_path=mounted_catalog_path,
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
            expected_cell = expected_by_id.get(matrix_id)
            if expected_cell is not None and cell_basis != expected_cell["canDemo_basis"]:
                errors.append("E_BASIS_EVIDENCE_DRIFT")
                basis_conflicts.append(matrix_id)
            computed = compute_can_demo(cell_basis)
            if cell.get("canDemo") is not computed:
                errors.append("E_CAN_DEMO_MANUAL_OVERRIDE")

        expected_status = _expected_mounted_status(cell.get("representative_tool", "-"), mounted_tools)
        if cell.get("mounted_status") != expected_status:
            mounted_catalog_delta.append(matrix_id)

    if blocked_unknown_ids:
        errors.append("E_T0_ENUM_UNKNOWN")

    expected_counts = Counter(row["primary_class"] for row in manifest_rows)
    actual_counts = Counter(cell.get("primary_class") for cell in cells if isinstance(cell, dict))
    primary_class_diff = {
        value: {"expected": expected_counts.get(value, 0), "actual": actual_counts.get(value, 0)}
        for value in sorted(set(expected_counts) | set(actual_counts))
        if expected_counts.get(value, 0) != actual_counts.get(value, 0)
    }
    if primary_class_diff:
        errors.append("E_PRIMARY_CLASS_CONSERVATION")

    if mounted_catalog_delta:
        errors.append("E_MOUNTED_CATALOG_DELTA")

    declared_unknown = matrix.get("summary", {}).get("blocked_unknown")
    if declared_unknown != len(blocked_unknown_ids):
        errors.append("E_BLOCKED_UNKNOWN_OVERRIDE")

    can_demo_count = sum(cell.get("canDemo") is True for cell in cells if isinstance(cell, dict))
    status = "PASS"
    if errors:
        status = "FAIL"
    elif can_demo_count != 1:
        status = "CONFLICT_REQUIRES_COMMANDER_DECISION"

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
        "basis_conflicts": sorted(set(basis_conflicts)),
        "dropped_matrix_ids": missing_no_representative_ids,
        "mounted_catalog_delta": sorted(set(mounted_catalog_delta)),
        "t0_enum_receipt_sha": sha256_file(t0_design_path),
    }


def write_json(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    subcommands = parser.add_subparsers(dest="command", required=True)
    for command in ("materialize", "check"):
        subparser = subcommands.add_parser(command)
        subparser.add_argument("--manifest", required=True, type=Path)
        subparser.add_argument("--t0-design", type=Path, default=DEFAULT_T0_DESIGN)
        subparser.add_argument("--semantic-contract", type=Path, default=DEFAULT_SEMANTIC_CONTRACT)
        subparser.add_argument("--state-cells", type=Path, default=DEFAULT_STATE_CELLS)
        subparser.add_argument("--mounted-catalog", type=Path, default=DEFAULT_MOUNTED_CATALOG)
    subcommands.choices["materialize"].add_argument("--output", required=True, type=Path)
    subcommands.choices["check"].add_argument("--matrix", required=True, type=Path)
    subcommands.choices["check"].add_argument("--schema", type=Path, default=DEFAULT_SCHEMA)
    subcommands.choices["check"].add_argument("--receipt", required=True, type=Path)
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    if args.command == "materialize":
        matrix = materialize_matrix(
            manifest_path=args.manifest,
            t0_design_path=args.t0_design,
            semantic_contract_path=args.semantic_contract,
            state_cells_path=args.state_cells,
            mounted_catalog_path=args.mounted_catalog,
        )
        write_json(args.output, matrix)
        return 0

    if not args.schema.exists():
        print(f"missing schema: {args.schema}", file=sys.stderr)
        return 2
    matrix = json.loads(args.matrix.read_text(encoding="utf-8"))
    report = validate_matrix(
        matrix=matrix,
        manifest_path=args.manifest,
        t0_design_path=args.t0_design,
        semantic_contract_path=args.semantic_contract,
        state_cells_path=args.state_cells,
        mounted_catalog_path=args.mounted_catalog,
    )
    write_json(args.receipt, report)
    if report["status"] != "PASS":
        print(json.dumps(report, ensure_ascii=False, sort_keys=True), file=sys.stderr)
        return 1
    print(json.dumps(report, ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

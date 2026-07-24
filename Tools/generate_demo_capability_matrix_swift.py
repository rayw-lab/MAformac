#!/usr/bin/env python3
"""Generate the read-only Swift DemoCapabilityMatrix catalog from its JSON SSOT."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_INPUT = REPO_ROOT / "contracts" / "demo-capability-matrix.json"
DEFAULT_OUTPUT = REPO_ROOT / "Core" / "Contracts" / "DemoCapabilityMatrix.generated.swift"

PRIMARY_CLASS_CASES = {
    "safety_or_clarify_reject": "safetyOrClarifyReject",
    "unmounted_name_rejected": "unmountedNameRejected",
    "fast_path_no_match_fallback": "fastPathNoMatchFallback",
    "default_executable": "defaultExecutable",
    "conditional_ddomain_executable": "conditionalDDomainExecutable",
}


def swift_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def swift_optional_string(value: Any) -> str:
    if value is None:
        return "nil"
    if not isinstance(value, str):
        raise ValueError(f"expected optional string, got {type(value).__name__}")
    return swift_string(value)


def swift_string_array(values: Any) -> str:
    if not isinstance(values, list) or not all(isinstance(value, str) for value in values):
        raise ValueError("expected string array")
    if not values:
        return "[]"
    return "[" + ", ".join(swift_string(value) for value in values) + "]"


def require_bool(value: Any, path: str) -> bool:
    if not isinstance(value, bool):
        raise ValueError(f"{path} must be bool")
    return value


def require_string(value: Any, path: str) -> str:
    if not isinstance(value, str) or not value:
        raise ValueError(f"{path} must be non-empty string")
    return value


def validate_basis(cell: dict[str, Any]) -> None:
    matrix_id = cell["matrix_id"]
    basis = cell.get("actionDemoProven_basis")
    required = {
        "mounted_or_approved_action",
        "semantic_contract",
        "state_readback_cell",
        "readbackProbePass",
        "bf8_promotion",
    }
    if not isinstance(basis, dict) or set(basis) != required:
        raise ValueError(f"matrix_id={matrix_id} has invalid actionDemoProven_basis keys")

    for key in ("mounted_or_approved_action", "semantic_contract", "state_readback_cell"):
        item = basis[key]
        if not isinstance(item, dict):
            raise ValueError(f"matrix_id={matrix_id} basis.{key} must be object")
        require_bool(item.get("observed"), f"matrix_id={matrix_id}.{key}.observed")
        require_string(item.get("source_ref"), f"matrix_id={matrix_id}.{key}.source_ref")

    readback = basis["readbackProbePass"]
    if not isinstance(readback, dict):
        raise ValueError(f"matrix_id={matrix_id} readbackProbePass must be object")
    require_bool(
        readback.get("observed"),
        f"matrix_id={matrix_id}.readbackProbePass.observed",
    )
    require_string(
        readback.get("source_ref"),
        f"matrix_id={matrix_id}.readbackProbePass.source_ref",
    )
    require_string(readback.get("status"), f"matrix_id={matrix_id}.readbackProbePass.status")
    for key in ("probe_id", "probe_receipt_id"):
        if readback.get(key) is not None and not isinstance(readback[key], str):
            raise ValueError(f"matrix_id={matrix_id}.readbackProbePass.{key} must be string or null")


def validate_source(root: Any) -> list[dict[str, Any]]:
    if not isinstance(root, dict) or root.get("schema_version") != "demo_capability_matrix_v2":
        raise ValueError("input must be demo_capability_matrix_v2")
    cells = root.get("cells")
    secondary_tools = root.get("secondary_tools")
    if not isinstance(secondary_tools, dict) or set(secondary_tools) != {"close_ac"}:
        raise ValueError("secondary_tools must contain only close_ac")
    close_ac = secondary_tools["close_ac"]
    if (
        not isinstance(close_ac, dict)
        or set(close_ac) != {"mounted_status", "customer_admitted", "proven", "proven_basis"}
        or close_ac.get("mounted_status") != "mounted"
        or close_ac.get("customer_admitted") is not True
        or close_ac.get("proven") is not False
    ):
        raise ValueError("secondary_tools.close_ac has invalid shape")
    if not isinstance(cells, list) or len(cells) != 120:
        raise ValueError("matrix must contain exactly 120 cells")
    if not all(isinstance(cell, dict) for cell in cells):
        raise ValueError("every matrix cell must be an object")

    ids = [cell.get("matrix_id") for cell in cells]
    if not all(isinstance(matrix_id, int) for matrix_id in ids):
        raise ValueError("matrix_id must be integer")
    if len(ids) != len(set(ids)):
        raise ValueError("matrix_id values must be unique")
    if ids != sorted(ids):
        raise ValueError("matrix cells must be ordered by matrix_id")

    for cell in cells:
        matrix_id = cell["matrix_id"]
        primary_class = cell.get("primary_class")
        if primary_class not in PRIMARY_CLASS_CASES:
            raise ValueError(f"matrix_id={matrix_id} has unknown primary_class={primary_class!r}")
        for key in (
            "family",
            "value_shape",
            "register",
            "default_path_status",
            "injected_path_status",
            "mounted_status",
            "source_hash",
        ):
            require_string(cell.get(key), f"matrix_id={matrix_id}.{key}")
        require_string(cell.get("representative_tool"), f"matrix_id={matrix_id}.representative_tool")
        swift_string_array(cell.get("entrypointAliases"))
        swift_string_array(cell.get("anchors"))
        validate_basis(cell)
        require_bool(cell.get("actionDemoProven"), f"matrix_id={matrix_id}.actionDemoProven")
        require_bool(cell.get("rejectionDemoProven"), f"matrix_id={matrix_id}.rejectionDemoProven")
    return cells


def render_evidence_basis(value: dict[str, Any]) -> str:
    return (
        "DemoCapabilityEvidenceBasis("
        f"observed: {str(value['observed']).lower()}, "
        f"sourceRef: {swift_string(value['source_ref'])})"
    )


def render_readback_basis(value: dict[str, Any]) -> str:
    return (
        "DemoCapabilityReadbackProbeBasis("
        f"observed: {str(value['observed']).lower()}, "
        f"status: {swift_string(value['status'])}, "
        f"probeID: {swift_optional_string(value.get('probe_id'))}, "
        f"probeReceiptID: {swift_optional_string(value.get('probe_receipt_id'))}, "
        f"sourceRef: {swift_string(value['source_ref'])})"
    )


def render_cell(cell: dict[str, Any]) -> str:
    basis = cell["actionDemoProven_basis"]
    representative_tool = None if cell["representative_tool"] == "-" else cell["representative_tool"]
    return "\n".join(
        [
            "        DemoCapabilityMatrixCell(",
            f"            matrixID: {cell['matrix_id']},",
            f"            family: {swift_string(cell['family'])},",
            f"            valueShape: {swift_string(cell['value_shape'])},",
            f"            register: {swift_string(cell['register'])},",
            f"            representativeTool: {swift_optional_string(representative_tool)},",
            f"            primaryClass: .{PRIMARY_CLASS_CASES[cell['primary_class']]},",
            f"            defaultPathStatus: {swift_string(cell['default_path_status'])},",
            f"            injectedPathStatus: {swift_string(cell['injected_path_status'])},",
            f"            entrypointAliases: {swift_string_array(cell['entrypointAliases'])},",
            f"            mountedStatus: {swift_string(cell['mounted_status'])},",
            "            actionDemoProvenBasis: DemoCapabilityActionDemoProvenBasis(",
            "                mountedOrApprovedAction: "
            + render_evidence_basis(basis["mounted_or_approved_action"])
            + ",",
            "                semanticContract: "
            + render_evidence_basis(basis["semantic_contract"])
            + ",",
            "                stateReadbackCell: "
            + render_evidence_basis(basis["state_readback_cell"])
            + ",",
            "                readbackProbePass: "
            + render_readback_basis(basis["readbackProbePass"]),
            "            ),",
            f"            actionDemoProven: {str(cell['actionDemoProven']).lower()},",
            f"            rejectionDemoProven: {str(cell['rejectionDemoProven']).lower()},",
            f"            fallbackReason: {swift_optional_string(cell.get('fallback_reason'))},",
            f"            reasonKind: {swift_optional_string(cell.get('reasonKind'))},",
            f"            sourceHash: {swift_string(cell['source_hash'])},",
            f"            anchors: {swift_string_array(cell['anchors'])}",
            "        )",
        ]
    )

def render_swift(root: dict[str, Any], source_sha256: str) -> str:
    cells = validate_source(root)
    close_ac_basis = root["secondary_tools"]["close_ac"]["proven_basis"]
    primary_cases = "\n".join(
        f"    case {case_name} = {swift_string(raw_value)}"
        for raw_value, case_name in PRIMARY_CLASS_CASES.items()
    )
    rendered_cells = ",\n".join(render_cell(cell) for cell in cells)
    return f'''// Generated by Tools/generate_demo_capability_matrix_swift.py. Do not edit.
// Source SHA-256: {source_sha256}

public enum DemoCapabilityPrimaryClass: String, CaseIterable, Codable, Hashable, Sendable {{
{primary_cases}
}}

public struct DemoCapabilityEvidenceBasis: Codable, Equatable, Hashable, Sendable {{
    public let observed: Bool
    public let sourceRef: String
}}

public struct DemoCapabilityReadbackProbeBasis: Codable, Equatable, Hashable, Sendable {{
    public let observed: Bool
    public let status: String
    public let probeID: String?
    public let probeReceiptID: String?
    public let sourceRef: String
}}

public struct DemoCapabilityActionDemoProvenBasis: Codable, Equatable, Hashable, Sendable {{
    public let mountedOrApprovedAction: DemoCapabilityEvidenceBasis
    public let semanticContract: DemoCapabilityEvidenceBasis
    public let stateReadbackCell: DemoCapabilityEvidenceBasis
    public let readbackProbePass: DemoCapabilityReadbackProbeBasis
}}

public struct DemoCapabilitySecondaryToolStatus: Codable, Equatable, Hashable, Sendable {{
    public let mountedStatus: String
    public let customerAdmitted: Bool
    public let proven: Bool
    public let provenBasis: DemoCapabilityEvidenceBasis
}}

public struct DemoCapabilityMatrixCell: Codable, Equatable, Hashable, Sendable {{
    public let matrixID: Int
    public let family: String
    public let valueShape: String
    public let register: String
    public let representativeTool: String?
    public let primaryClass: DemoCapabilityPrimaryClass
    public let defaultPathStatus: String
    public let injectedPathStatus: String
    public let entrypointAliases: [String]
    public let mountedStatus: String
    public let actionDemoProvenBasis: DemoCapabilityActionDemoProvenBasis
    public let actionDemoProven: Bool
    public let rejectionDemoProven: Bool
    public let fallbackReason: String?
    public let reasonKind: String?
    public let sourceHash: String
    public let anchors: [String]
}}

/// Read-only projection of contracts/demo-capability-matrix.json.
/// This catalog never adds mounted tools or promotes actionDemoProven independently of the source matrix.
public enum DemoCapabilityMatrixCatalog {{
    public static let schemaVersion = "demo_capability_matrix_v2"
    public static let sourceSHA256 = "{source_sha256}"
    public static let secondaryTools: [String: DemoCapabilitySecondaryToolStatus] = [
        "close_ac": DemoCapabilitySecondaryToolStatus(
            mountedStatus: "mounted",
            customerAdmitted: true,
            proven: false,
            provenBasis: DemoCapabilityEvidenceBasis(
                observed: {str(close_ac_basis["observed"]).lower()},
                sourceRef: {swift_string(close_ac_basis["source_ref"])}
            )
        )
    ]
    public static let cells: [DemoCapabilityMatrixCell] = [
{rendered_cells}
    ]
}}
'''
def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    return parser


def main() -> int:
    args = build_parser().parse_args()
    source_bytes = args.input.read_bytes()
    root = json.loads(source_bytes)
    output = render_swift(root, hashlib.sha256(source_bytes).hexdigest())
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(output, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

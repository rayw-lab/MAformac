#!/usr/bin/env python3
"""Validate phase truth and exact surfaces for int-v5a execution receipts."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any

from jsonschema import Draft202012Validator


SCHEMA = Path("contracts/schemas/int-v5a-execution-receipt.schema.json")
EXPECTED_RENAME_MUST_CHANGE = {
    "contracts/schemas/demo-capability-matrix.schema.json",
    "Tools/checks/check_capability_matrix.py",
    "scripts/test_check_capability_matrix.py",
    "Makefile",
    "contracts/demo-capability-matrix.json",
    "Tools/generate_demo_capability_matrix_swift.py",
    "Core/Contracts/DemoCapabilityMatrix.generated.swift",
    "Tests/MAformacCoreTests/DemoCapabilityMatrixGeneratedTests.swift",
    "scripts/check_mounted_catalog_no_delta.py",
    "scripts/test_check_mounted_catalog_no_delta.py",
    "scripts/test_check_runtime_no_mutation_receipts.py",
    "contracts/c2-mounted-catalog-baseline.yaml",
    "openspec/changes/add-c1-demo-capability-governance/proposal.md",
    "openspec/changes/add-c1-demo-capability-governance/design.md",
    "openspec/changes/add-c1-demo-capability-governance/tasks.md",
    "openspec/changes/add-c1-demo-capability-governance/specs/demo-capability-governance/spec.md",
    "docs/commander-log/decisions.md",
    "docs/grill-tournament/c1-capability-grill-ratified-2026-07-10.md",
    "docs/CURRENT.md",
}
EXPECTED_REVIEWED_NO_CHANGE = {"Tools/checks/check_c1_anchor_delta.py"}


def validate_execution_receipt(receipt: dict[str, Any], phase: str, repo_root: Path) -> dict[str, Any]:
    schema = json.loads((repo_root / SCHEMA).read_text(encoding="utf-8"))
    errors: list[str] = []
    if list(Draft202012Validator(schema).iter_errors(receipt)) or receipt.get("phase") != phase:
        errors.append("E_INT_V5A_RECEIPT_SCHEMA")
    if phase == "rename":
        if set(receipt.get("must_change_paths", [])) != EXPECTED_RENAME_MUST_CHANGE:
            errors.append("E_INT_V5A_MUST_CHANGE_SET")
        if not EXPECTED_REVIEWED_NO_CHANGE.issubset(set(receipt.get("reviewed_no_change_paths", []))):
            errors.append("E_INT_V5A_REVIEW_SET")
    bundle = receipt.get("runtime_bundle", {})
    digest = bundle.get("runtime_contract_bundle_digest") if isinstance(bundle, dict) else None
    status = bundle.get("status") if isinstance(bundle, dict) else None
    if phase in {"preflight", "rename"}:
        if status != "not_yet_available" or digest is not None:
            errors.append("E_INT_V5A_PHASE_DIGEST_STATE")
    elif phase in {"bundle", "final"}:
        if status != "available" or not isinstance(digest, str) or re.fullmatch(r"[0-9a-f]{64}", digest) is None:
            errors.append("E_INT_V5A_PHASE_DIGEST_STATE")
    return {"status": "PASS" if not errors else "FAIL", "errors": sorted(set(errors))}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--phase", required=True, choices=("preflight", "rename", "bundle", "final"))
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    args = parser.parse_args()
    receipt = json.loads(args.input.read_text(encoding="utf-8"))
    report = validate_execution_receipt(receipt, args.phase, args.repo_root.resolve())
    print(json.dumps(report, ensure_ascii=False, sort_keys=True))
    return 0 if report["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())

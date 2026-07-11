#!/usr/bin/env python3
"""Fail-closed checker for a latest-turn deny-first frontstage receipt."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path
from typing import Any

from jsonschema import Draft202012Validator


def validate(receipt: dict[str, Any], schema_path: Path | None = None) -> dict[str, Any]:
    schema_path = schema_path or Path(__file__).resolve().parents[2] / "contracts/schemas/frontstage-route-receipt.schema.json"
    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    errors: list[str] = []
    if list(Draft202012Validator(schema).iter_errors(receipt)):
        errors.append("E_SCHEMA")
    nonce = receipt.get("run_nonce")
    if not isinstance(nonce, str) or re.fullmatch(r"[0-9a-f]{32}", nonce) is None:
        errors.append("E_RUN_NONCE")
    if receipt.get("result") == "refusal_no_available_tool":
        if receipt.get("state_mutation") is not False:
            errors.append("E_DENY_MUTATION")
        if receipt.get("readback_count") != 0:
            errors.append("E_DENY_READBACK")
    return {"status": "PASS" if not errors else "FAIL", "errors": sorted(set(errors))}


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--receipt", type=Path, required=True)
    parser.add_argument("--schema", type=Path, required=True)
    parser.add_argument("--matrix", type=Path, required=True)
    parser.add_argument("--runtime-bundle-manifest", type=Path, required=True)
    parser.add_argument("--app-executable", type=Path, required=True)
    parser.add_argument("--expected-head", required=True)
    parser.add_argument("--expected-run-id", required=True)
    parser.add_argument("--expected-run-nonce", required=True)
    args = parser.parse_args()

    receipt = json.loads(args.receipt.read_text(encoding="utf-8"))
    report = validate(receipt, args.schema)
    if receipt.get("source_head_sha") != args.expected_head:
        report["errors"].append("E_HEAD")
    if receipt.get("tested_checkout_sha") != args.expected_head:
        report["errors"].append("E_TESTED_CHECKOUT")
    if receipt.get("run_id") != args.expected_run_id:
        report["errors"].append("E_RUN_ID")
    if receipt.get("run_nonce") != args.expected_run_nonce:
        report["errors"].append("E_EXPECTED_NONCE")
    if not args.matrix.is_file() or not args.app_executable.is_file():
        report["errors"].append("E_REQUIRED_INPUT")
        report["errors"] = sorted(set(report["errors"]))
        report["status"] = "FAIL"
        print(json.dumps(report, ensure_ascii=False, sort_keys=True))
        return 1
    if receipt.get("matrix_source_sha256") != sha256_file(args.matrix):
        report["errors"].append("E_MATRIX_DIGEST")
    manifest = json.loads(args.runtime_bundle_manifest.read_text(encoding="utf-8"))
    if receipt.get("runtime_contract_bundle_digest") != manifest.get("runtime_contract_bundle_digest"):
        report["errors"].append("E_BUNDLE_DIGEST")
    if receipt.get("app_executable_sha256") != sha256_file(args.app_executable):
        report["errors"].append("E_APP_EXECUTABLE_SHA")
    report["errors"] = sorted(set(report["errors"]))
    report["status"] = "PASS" if not report["errors"] else "FAIL"
    print(json.dumps(report, ensure_ascii=False, sort_keys=True))
    return 0 if report["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())

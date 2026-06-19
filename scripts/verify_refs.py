#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
import sys
from collections import Counter
from pathlib import Path
from typing import Any

from jsonschema import Draft202012Validator

from c1_common import (
    CONTRACTS_DIR,
    CORE_SHEETS,
    C1Error,
    load_manifest,
    reject_duplicate_json_keys,
    safe_load_yaml,
)
from gen_c1 import CONTRACT_SCHEMA

CONTRACT_JSONL = CONTRACTS_DIR / "semantic-function-contract.jsonl"
FOLLOWUP_JSONL = CONTRACTS_DIR / "semantic-followup-transitions.jsonl"
QUARANTINE_JSONL = CONTRACTS_DIR / "semantic-quarantine.jsonl"
FUNCTION_SPEC_YAML = CONTRACTS_DIR / "function-spec-full.yaml"
COVERAGE_REPORT = CONTRACTS_DIR / "semantic-coverage-report.md"

UNRESOLVED_LIMIT = 0.02
FORBIDDEN_SUBSTRINGS = [
    "禁外传",
    "禁止外传",
    "报价",
    "成本",
    "身份证",
    "手机号",
    "供应商：",
    "客户公司",
    "真实人名",
    "示例说法",
    "功能描述",
]


def read_jsonl(path: Path) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    with path.open("rb") as f:
        if f.read(3) == b"\xef\xbb\xbf":
            raise C1Error(f"{path} has UTF-8 BOM")
    with path.open("r", encoding="utf-8") as f:
        for line_no, line in enumerate(f, 1):
            if not line.strip():
                raise C1Error(f"{path}:{line_no} blank line")
            try:
                rows.append(json.loads(line, object_pairs_hook=reject_duplicate_json_keys))
            except Exception as exc:
                raise C1Error(f"{path}:{line_no} invalid json: {exc}") from exc
    return rows


def verify_schema(rows: list[dict[str, Any]]) -> None:
    Draft202012Validator.check_schema(CONTRACT_SCHEMA)
    validator = Draft202012Validator(CONTRACT_SCHEMA)
    errors = []
    for row in rows:
        errors.extend(validator.iter_errors(row))
    if errors:
        first = errors[0]
        raise C1Error(f"schema error at {'/'.join(map(str, first.path))}: {first.message}")


def verify_contract_invariants(manifest: dict[str, Any], rows: list[dict[str, Any]], quarantine: list[dict[str, Any]]) -> None:
    source_rows = manifest["contract_scope"]["source_rows"]
    valid = len(rows)
    quarantined = len(quarantine)
    legacy = 0
    if source_rows != valid + quarantined + legacy:
        raise C1Error(
            f"ledger mismatch: source_rows={source_rows} valid={valid} quarantined={quarantined} legacy={legacy}"
        )
    ids = [row["contract_row_id"] for row in rows]
    if len(ids) != len(set(ids)):
        raise C1Error("duplicate contract_row_id")
    canonical_ids = [row["canonical_semantic_id"] for row in rows]
    if not canonical_ids:
        raise C1Error("no contract rows")
    for row in rows:
        if row["exec_tier"] != "L2":
            raise C1Error(f"exec_tier is not L2: {row['contract_row_id']}")
        if row["risk"] != "":
            raise C1Error(f"risk is not empty: {row['contract_row_id']}")
        if set(row["value"].keys()) != {"ref", "direct", "offset", "type"}:
            raise C1Error(f"value tuple shape mismatch: {row['contract_row_id']}")
        if row["source_domain"] not in CORE_SHEETS:
            raise C1Error(f"unexpected source_domain: {row['source_domain']}")
    role_counts = Counter(row["dedupe_role"] for row in rows)
    canonical_count = len(set(canonical_ids))
    if role_counts["primary"] != canonical_count:
        raise C1Error(f"primary count {role_counts['primary']} != canonical count {canonical_count}")


def verify_followup_refs(rows: list[dict[str, Any]], transitions: list[dict[str, Any]]) -> None:
    canonical_ids = {row["canonical_semantic_id"] for row in rows}
    transition_ids = {row["transition_id"] for row in transitions}
    if len(transition_ids) != len(transitions):
        raise C1Error("duplicate transition_id")
    unresolved = 0
    for transition in transitions:
        if transition["unresolved_ref"]:
            unresolved += 1
            continue
        if transition["first_canonical_semantic_id"] not in canonical_ids:
            raise C1Error(f"first ref missing: {transition['transition_id']}")
        if transition["second_canonical_semantic_id"] not in canonical_ids:
            raise C1Error(f"second ref missing: {transition['transition_id']}")
    ratio = unresolved / len(transitions) if transitions else 0.0
    if ratio > UNRESOLVED_LIMIT:
        raise C1Error(f"followup unresolved ratio {ratio:.4f} > {UNRESOLVED_LIMIT:.2f}")
    for row in rows:
        for ref in row["second_turn_refs"]:
            if ref not in transition_ids:
                raise C1Error(f"second_turn_refs missing transition: {row['contract_row_id']} -> {ref}")


def verify_function_spec(rows: list[dict[str, Any]]) -> None:
    spec = safe_load_yaml(FUNCTION_SPEC_YAML)
    devices = spec.get("devices", [])
    ids = [device["device_id"] for device in devices]
    if len(ids) != len(set(ids)):
        raise C1Error("duplicate device_id in function-spec-full.yaml")
    if spec.get("summary", {}).get("contract_rows") != len(rows):
        raise C1Error("function-spec contract_rows summary mismatch")
    if spec.get("authority") != "generated_from_semantic_function_contract_jsonl":
        raise C1Error("function-spec authority mismatch")


def verify_range_classification(rows: list[dict[str, Any]]) -> None:
    allowed = {"none", "placeholder_open", "material_candidate"}
    for row in rows:
        if row["range_class"] not in allowed:
            raise C1Error(f"bad range_class: {row['contract_row_id']}")
    report = COVERAGE_REPORT.read_text(encoding="utf-8")
    if "placeholder_open" not in report or "material_conflict" not in report:
        raise C1Error("coverage report missing range conflict classification")


def verify_leak_scan() -> None:
    paths = [CONTRACT_JSONL, FOLLOWUP_JSONL, QUARANTINE_JSONL, FUNCTION_SPEC_YAML, COVERAGE_REPORT]
    for path in paths:
        text = path.read_text(encoding="utf-8")
        for marker in FORBIDDEN_SUBSTRINGS:
            if marker in text:
                raise C1Error(f"forbidden marker {marker!r} found in {path}")
    result = subprocess.run(
        ["git", "ls-files", "*.xlsx"],
        cwd=CONTRACTS_DIR.parent,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
    )
    if result.stdout.strip():
        raise C1Error(f"xlsx files tracked in git:\n{result.stdout}")


def main() -> int:
    manifest = load_manifest()
    rows = read_jsonl(CONTRACT_JSONL)
    transitions = read_jsonl(FOLLOWUP_JSONL)
    quarantine = read_jsonl(QUARANTINE_JSONL)
    verify_schema(rows)
    verify_contract_invariants(manifest, rows, quarantine)
    verify_followup_refs(rows, transitions)
    verify_function_spec(rows)
    verify_range_classification(rows)
    verify_leak_scan()
    print("schema=ok")
    print("refs=ok")
    print("ledger=ok")
    print("range_conflicts=ok")
    print("coverage=ok")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"verify_refs failed: {exc}", file=sys.stderr)
        raise

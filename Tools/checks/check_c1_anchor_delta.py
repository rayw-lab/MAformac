#!/usr/bin/env python3
"""Build durable C1 matrix-anchor and split-metric receipts.

This checker is intentionally an aggregator of existing slice receipts.  It
does not manufacture probe, partial-execution, or presentation evidence.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
from collections import Counter
from pathlib import Path
from typing import Any


D123_BASELINE = {
    "safety_or_clarify_reject": 0,
    "unmounted_name_rejected": 36,
    "fast_path_no_match_fallback": 82,
    "default_executable": 1,
    "conditional_ddomain_executable": 1,
}
MOUNTED_CATALOG_PATH = Path("Core/Contracts/DDomainMountedToolCatalog.swift")
MATRIX_PATH = Path("contracts/demo-capability-matrix.json")
ALLOWED_INPUT_PROOF_CLASSES = {
    "local",
    "local_contract_validation",
    "unit",
    "integration",
    "runtime",
    "desktop_operator_equivalent",
}


def sha256_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def sha256_file(path: Path) -> str:
    return sha256_bytes(path.read_bytes())


def read_json(path: Path, name: str, errors: list[str]) -> dict[str, Any] | None:
    if not path.is_file():
        errors.append(f"E_MISSING_RECEIPT:{name}")
        return None
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        errors.append(f"E_INVALID_RECEIPT_JSON:{name}")
        return None
    if not isinstance(value, dict):
        errors.append(f"E_INVALID_RECEIPT_SHAPE:{name}")
        return None
    return value


def git_run(repo_root: Path, *arguments: str) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run(
        ["git", *arguments],
        cwd=repo_root,
        capture_output=True,
        check=False,
    )


def git_file_at_ref(repo_root: Path, ref: str, relative_path: Path) -> bytes | None:
    completed = git_run(repo_root, "show", f"{ref}:{relative_path.as_posix()}")
    return completed.stdout if completed.returncode == 0 else None


def is_ancestor(repo_root: Path, base_sha: str, head_sha: str) -> bool | None:
    base_exists = git_run(repo_root, "cat-file", "-e", f"{base_sha}^{{commit}}")
    head_exists = git_run(repo_root, "cat-file", "-e", f"{head_sha}^{{commit}}")
    if base_exists.returncode != 0 or head_exists.returncode != 0:
        return None
    return git_run(repo_root, "merge-base", "--is-ancestor", base_sha, head_sha).returncode == 0


def parse_mounted_tools(content: bytes) -> set[str]:
    text = content.decode("utf-8")
    match = re.search(r"mountedToolNames:\s*Set<String>\s*=\s*\[(.*?)\]", text, re.DOTALL)
    if not match:
        raise ValueError("mountedToolNames declaration was not found")
    return set(re.findall(r'"([^"]+)"', match.group(1)))


def parse_manifest(path: Path, errors: list[str]) -> tuple[dict[int, str], str | None]:
    if not path.is_file():
        errors.append("E_MATRIX_MANIFEST_MISSING")
        return {}, None
    rows: dict[int, str] = {}
    try:
        for line in path.read_text(encoding="utf-8").splitlines():
            if not line.strip():
                continue
            row = json.loads(line)
            matrix_id = row.get("matrix_id")
            primary_class = row.get("primary_class")
            if not isinstance(matrix_id, int) or not isinstance(primary_class, str):
                errors.append("E_MATRIX_MANIFEST_SHAPE")
                continue
            if matrix_id in rows:
                errors.append("E_MATRIX_MANIFEST_DUPLICATE_ID")
            rows[matrix_id] = primary_class
    except json.JSONDecodeError:
        errors.append("E_MATRIX_MANIFEST_JSON")
    return rows, sha256_file(path)


def normalize_count(value: Any) -> int | None:
    return value if isinstance(value, int) and value >= 0 else None


def validate_proof_class(receipt: dict[str, Any] | None, name: str, errors: list[str]) -> str | None:
    if receipt is None:
        return None
    proof_class = receipt.get("proof_class")
    if not isinstance(proof_class, str):
        errors.append(f"E_PROOF_CLASS_MISSING:{name}")
        return None
    if proof_class not in ALLOWED_INPUT_PROOF_CLASSES:
        errors.append(f"E_PROOF_CLASS_UPGRADE:{name}")
    return proof_class


def receipt_summary(path: Path, receipt: dict[str, Any] | None, proof_class: str | None) -> dict[str, Any]:
    return {
        "path": str(path),
        "sha256": sha256_file(path) if receipt is not None else None,
        "proof_class": proof_class,
    }


def build_reports(
    *,
    base_receipt_path: Path,
    matrix_path: Path,
    matrix_manifest_path: Path,
    mounted_catalog_path: Path,
    fallback_receipt_path: Path,
    probe_receipt_path: Path,
    partial_producer_receipt_path: Path,
    partial_bridge_receipt_path: Path,
    repo_root: Path,
    head_sha: str,
) -> tuple[dict[str, Any], dict[str, Any]]:
    """Return the anchor comparison and split metrics without writing them."""

    errors: list[str] = []
    base_receipt = read_json(base_receipt_path, "base", errors)
    fallback_receipt = read_json(fallback_receipt_path, "fallback", errors)
    probe_receipt = read_json(probe_receipt_path, "probe", errors)
    producer_receipt = read_json(partial_producer_receipt_path, "partial_producer", errors)
    bridge_receipt = read_json(partial_bridge_receipt_path, "partial_bridge", errors)

    base_sha = base_receipt.get("implementation_base_sha") if base_receipt else None
    if not isinstance(base_sha, str) or not re.fullmatch(r"[0-9a-f]{40}", base_sha):
        errors.append("E_BASE_SHA_MISSING")
        base_sha = None
    elif is_ancestor(repo_root, base_sha, head_sha) is not True:
        errors.append("E_STALE_BASE")

    manifest_classes, manifest_sha = parse_manifest(matrix_manifest_path, errors)
    matrix = read_json(matrix_path, "matrix", errors)
    cells = matrix.get("cells", []) if matrix else []
    if not isinstance(cells, list):
        errors.append("E_MATRIX_CELLS_SHAPE")
        cells = []
    matrix_source = matrix.get("source", {}) if matrix else {}
    if not isinstance(matrix_source, dict) or matrix_source.get("manifest_sha256") != manifest_sha:
        errors.append("E_MATRIX_SOURCE_SHA_MISMATCH")

    actual_by_id: dict[int, str | None] = {}
    for cell in cells:
        if not isinstance(cell, dict):
            errors.append("E_MATRIX_CELL_SHAPE")
            continue
        matrix_id = cell.get("matrix_id")
        if not isinstance(matrix_id, int):
            errors.append("E_MATRIX_CELL_ID")
            continue
        if matrix_id in actual_by_id:
            errors.append("E_MATRIX_DUPLICATE_ID")
        primary_class = cell.get("primary_class")
        actual_by_id[matrix_id] = primary_class if isinstance(primary_class, str) else None

    matrix_cell_diff = [
        {
            "matrix_id": matrix_id,
            "expected_primary_class": expected,
            "actual_primary_class": actual_by_id.get(matrix_id),
            "matches": actual_by_id.get(matrix_id) == expected,
        }
        for matrix_id, expected in sorted(manifest_classes.items())
    ]
    extra_matrix_ids = sorted(set(actual_by_id) - set(manifest_classes))
    if len(manifest_classes) != 120 or len(matrix_cell_diff) != 120 or extra_matrix_ids:
        errors.append("E_MATRIX_120_CELL_CONSERVATION")
    if not all(item["matches"] for item in matrix_cell_diff):
        errors.append("E_MATRIX_CELL_DIFF")

    actual_counts = Counter(value for value in actual_by_id.values() if isinstance(value, str))
    d123_primary_class_diff = {
        primary_class: {
            "expected": expected,
            "actual": actual_counts.get(primary_class, 0),
            "delta": actual_counts.get(primary_class, 0) - expected,
        }
        for primary_class, expected in D123_BASELINE.items()
    }
    if any(item["delta"] != 0 for item in d123_primary_class_diff.values()):
        errors.append("E_D123_BASELINE_MISMATCH")

    base_matrix_bytes = git_file_at_ref(repo_root, base_sha, MATRIX_PATH) if base_sha else None
    base_matrix_source_sha = None
    if base_matrix_bytes is not None:
        try:
            base_matrix_source_sha = json.loads(base_matrix_bytes).get("source", {}).get("manifest_sha256")
        except (json.JSONDecodeError, AttributeError):
            errors.append("E_BASE_MATRIX_SHAPE")

    mounted_catalog_bytes = mounted_catalog_path.read_bytes() if mounted_catalog_path.is_file() else None
    if mounted_catalog_bytes is None:
        errors.append("E_HEAD_MOUNTED_CATALOG_MISSING")
        mounted_catalog_bytes = b""
    base_mounted_catalog_bytes = (
        git_file_at_ref(repo_root, base_sha, MOUNTED_CATALOG_PATH) if base_sha else None
    )
    base_mounted_catalog_sha = sha256_bytes(base_mounted_catalog_bytes) if base_mounted_catalog_bytes else None
    head_mounted_catalog_sha = sha256_bytes(mounted_catalog_bytes) if mounted_catalog_bytes else None
    mounted_added: list[str] = []
    mounted_removed: list[str] = []
    if base_mounted_catalog_bytes is None:
        errors.append("E_BASE_MOUNTED_CATALOG_MISSING")
    elif mounted_catalog_bytes:
        try:
            base_mounted_tools = parse_mounted_tools(base_mounted_catalog_bytes)
            head_mounted_tools = parse_mounted_tools(mounted_catalog_bytes)
            mounted_added = sorted(head_mounted_tools - base_mounted_tools)
            mounted_removed = sorted(base_mounted_tools - head_mounted_tools)
        except ValueError:
            errors.append("E_MOUNTED_CATALOG_PARSE")
    mounted_catalog_diff_count = len(mounted_added) + len(mounted_removed)
    if mounted_catalog_diff_count:
        errors.append("E_MOUNTED_CATALOG_DELTA")

    fallback_proof = validate_proof_class(fallback_receipt, "fallback", errors)
    probe_proof = validate_proof_class(probe_receipt, "probe", errors)
    producer_proof = validate_proof_class(producer_receipt, "partial_producer", errors)
    bridge_proof = validate_proof_class(bridge_receipt, "partial_bridge", errors)

    fallback_case_count = fallback_receipt.get("cell_count") if fallback_receipt else None
    fallback_generic_hits = fallback_receipt.get("generic_leakage_hits") if fallback_receipt else None
    if fallback_receipt is not None:
        if fallback_case_count != 40:
            errors.append("E_FALLBACK_COVERAGE")
        if not isinstance(fallback_generic_hits, list):
            errors.append("E_FALLBACK_GENERIC_LEAKAGE_SHAPE")
            fallback_generic_hits = []
        if fallback_generic_hits:
            errors.append("E_FALLBACK_GENERIC_LEAKAGE")

    probe_case_count = probe_receipt.get("case_count") if probe_receipt else None
    no_mutation_pass_count = probe_receipt.get("no_mutation_pass_count") if probe_receipt else None
    probe_generic_leakage = probe_receipt.get("generic_leakage_count") if probe_receipt else None
    if probe_receipt is not None:
        if probe_case_count != 40 or no_mutation_pass_count != 40:
            errors.append("E_PROBE_NO_MUTATION_COVERAGE")
        if probe_generic_leakage != 0:
            errors.append("E_PROBE_GENERIC_LEAKAGE")

    producer_fixture_sha = producer_receipt.get("fixture_sha256") if producer_receipt else None
    bridge_fixture_sha = bridge_receipt.get("fixture_sha256") if bridge_receipt else None
    partial_counts: dict[str, dict[str, int | None]] = {}
    for name, receipt in (("producer", producer_receipt), ("bridge", bridge_receipt)):
        partial_counts[name] = {
            field: normalize_count(receipt.get(field)) if receipt else None
            for field in ("accepted_count", "refused_count", "readback_count")
        }
        if receipt is not None:
            if not isinstance(receipt.get("fixture_sha256"), str):
                errors.append(f"E_PARTIAL_FIXTURE_SHA_MISSING:{name}")
            if any(value is None for value in partial_counts[name].values()):
                errors.append(f"E_PARTIAL_COUNTS_SHAPE:{name}")
    if producer_receipt and bridge_receipt and partial_counts["producer"] != partial_counts["bridge"]:
        errors.append("E_PARTIAL_PROJECTION_COUNT_MISMATCH")

    in_scope = (producer_receipt or {}).get("in_scope_execution")
    passed = normalize_count(in_scope.get("passed")) if isinstance(in_scope, dict) else None
    total = normalize_count(in_scope.get("total")) if isinstance(in_scope, dict) else None
    if producer_receipt is None:
        in_scope_metric = {"passed": passed, "total": total, "rate": None}
    elif passed is None or total is None or total == 0 or passed > total:
        errors.append("E_IN_SCOPE_EXECUTION_METRIC")
        in_scope_metric = {"passed": passed, "total": total, "rate": None}
    else:
        in_scope_metric = {"passed": passed, "total": total, "rate": passed / total}

    fallback_quality_rate = (
        no_mutation_pass_count / probe_case_count
        if isinstance(no_mutation_pass_count, int) and isinstance(probe_case_count, int) and probe_case_count > 0
        else None
    )
    fallback_metric = {
        "covered_cases": probe_case_count,
        "no_mutation_pass_count": no_mutation_pass_count,
        "quality_rate": fallback_quality_rate,
        "generic_leakage_count": (
            len(fallback_generic_hits) if isinstance(fallback_generic_hits, list) else None
        ),
    }

    errors = sorted(set(errors))
    status = "PASS" if not errors else "FAIL"
    source_receipts = {
        "base": receipt_summary(base_receipt_path, base_receipt, None),
        "fallback": receipt_summary(fallback_receipt_path, fallback_receipt, fallback_proof),
        "probe": receipt_summary(probe_receipt_path, probe_receipt, probe_proof),
        "partial_producer": receipt_summary(
            partial_producer_receipt_path, producer_receipt, producer_proof
        ),
        "partial_bridge": receipt_summary(partial_bridge_receipt_path, bridge_receipt, bridge_proof),
    }
    anchor = {
        "receipt_kind": "c1_matrix_anchor_delta",
        "status": status,
        "proof_class": "local_aggregation",
        "implementation_base_sha": base_sha,
        "head_sha": head_sha,
        "base_matrix_source_sha256": base_matrix_source_sha,
        "matrix_source_sha256": manifest_sha,
        "matrix_sha256": sha256_file(matrix_path) if matrix else None,
        "d123_primary_class_diff": d123_primary_class_diff,
        "matrix_cell_diff": matrix_cell_diff,
        "extra_matrix_ids": extra_matrix_ids,
        "mounted_catalog": {
            "base_sha256": base_mounted_catalog_sha,
            "head_sha256": head_mounted_catalog_sha,
            "added": mounted_added,
            "removed": mounted_removed,
        },
        "mounted_catalog_diff_count": mounted_catalog_diff_count,
        "fallback": {
            "catalog_case_count": fallback_case_count,
            "probe_case_count": probe_case_count,
            "no_mutation_pass_count": no_mutation_pass_count,
            "generic_leakage_count": fallback_metric["generic_leakage_count"],
        },
        "partial": {
            "producer_fixture_sha256": producer_fixture_sha,
            "bridge_fixture_sha256": bridge_fixture_sha,
            "producer_counts": partial_counts["producer"],
            "bridge_counts": partial_counts["bridge"],
        },
        "source_receipts": source_receipts,
        "errors": errors,
        "non_claims": [
            "not a combined all-green rate",
            "not operator-pass",
            "not V-PASS",
            "not mobile or true-device acceptance",
        ],
    }
    metrics = {
        "receipt_kind": "c1_metrics",
        "status": status,
        "proof_class": "local_aggregation",
        "implementation_base_sha": base_sha,
        "head_sha": head_sha,
        "in_scope_execution": in_scope_metric,
        "out_of_scope_fallback": fallback_metric,
        "input_proof_classes": {
            "fallback": fallback_proof,
            "probe": probe_proof,
            "partial_producer": producer_proof,
            "partial_bridge": bridge_proof,
        },
        "errors": errors,
        "non_claims": [
            "no overall_pass_rate is computed",
            "local aggregation does not upgrade component proof",
        ],
    }
    return anchor, metrics


def assert_durable_output(path: Path) -> None:
    if path == Path("/tmp") or Path("/tmp") in path.parents:
        raise ValueError(f"refusing ephemeral /tmp receipt path: {path}")


def write_json(path: Path, value: dict[str, Any]) -> None:
    assert_durable_output(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base-receipt", required=True, type=Path)
    parser.add_argument("--matrix", required=True, type=Path)
    parser.add_argument("--matrix-manifest", required=True, type=Path)
    parser.add_argument("--mounted-catalog", required=True, type=Path)
    parser.add_argument("--fallback-receipt", required=True, type=Path)
    parser.add_argument("--probe-receipt", required=True, type=Path)
    parser.add_argument("--partial-producer-receipt", required=True, type=Path)
    parser.add_argument("--partial-bridge-receipt", required=True, type=Path)
    parser.add_argument("--anchor-receipt", required=True, type=Path)
    parser.add_argument("--metrics-receipt", required=True, type=Path)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument("--head-sha")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    head_sha = args.head_sha
    if head_sha is None:
        completed = git_run(args.repo_root, "rev-parse", "HEAD")
        if completed.returncode != 0:
            print("unable to resolve HEAD", file=sys.stderr)
            return 2
        head_sha = completed.stdout.decode("utf-8").strip()
    try:
        anchor, metrics = build_reports(
            base_receipt_path=args.base_receipt,
            matrix_path=args.matrix,
            matrix_manifest_path=args.matrix_manifest,
            mounted_catalog_path=args.mounted_catalog,
            fallback_receipt_path=args.fallback_receipt,
            probe_receipt_path=args.probe_receipt,
            partial_producer_receipt_path=args.partial_producer_receipt,
            partial_bridge_receipt_path=args.partial_bridge_receipt,
            repo_root=args.repo_root,
            head_sha=head_sha,
        )
        write_json(args.anchor_receipt, anchor)
        write_json(args.metrics_receipt, metrics)
    except ValueError as error:
        print(str(error), file=sys.stderr)
        return 2
    print(json.dumps({"anchor": anchor["status"], "metrics": metrics["status"]}, sort_keys=True))
    return 0 if anchor["status"] == "PASS" and metrics["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Test-first contract for the durable C1 anchor and metrics checker."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
CHECKER_PATH = REPO_ROOT / "Tools" / "checks" / "check_c1_anchor_delta.py"
MOUNTED_CATALOG = REPO_ROOT / "Core" / "Contracts" / "DDomainMountedToolCatalog.swift"

D123_BASELINE = {
    "safety_or_clarify_reject": 0,
    "unmounted_name_rejected": 32,
    "fast_path_no_match_fallback": 82,
    "default_executable": 1,
    "conditional_ddomain_executable": 5,
}


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write_json(path: Path, value: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


class C1AnchorDeltaTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.head_sha = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()
        cls.parent_sha = subprocess.run(
            ["git", "rev-parse", "HEAD^"],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()

    def setUp(self) -> None:
        if not CHECKER_PATH.is_file():
            self.fail("C3 durable anchor checker has not been implemented")
        spec = importlib.util.spec_from_file_location("check_c1_anchor_delta", CHECKER_PATH)
        assert spec is not None and spec.loader is not None
        self.checker = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(self.checker)
        self.tmp = tempfile.TemporaryDirectory(prefix="c1-anchor-delta-test-")
        self.root = Path(self.tmp.name)
        self.paths = self.write_valid_inputs()

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def write_valid_inputs(self) -> dict[str, Path]:
        manifest = self.root / "matrix-manifest.jsonl"
        rows = []
        matrix_cells = []
        matrix_id = 1
        for primary_class, count in D123_BASELINE.items():
            for _ in range(count):
                row = {"matrix_id": matrix_id, "primary_class": primary_class}
                rows.append(row)
                matrix_cells.append(dict(row))
                matrix_id += 1
        manifest.write_text(
            "\n".join(json.dumps(row, ensure_ascii=False) for row in rows) + "\n",
            encoding="utf-8",
        )

        matrix = self.root / "matrix.json"
        write_json(
            matrix,
            {
                "source": {"manifest_sha256": sha256_file(manifest)},
                "cells": matrix_cells,
                "summary": {
                    "primary_class_counts": {
                        key: value for key, value in D123_BASELINE.items() if value
                    },
                    "blocked_unknown": 0,
                },
            },
        )

        base = self.root / "base.json"
        write_json(base, {"implementation_base_sha": self.parent_sha})

        fallback = self.root / "fallback.json"
        write_json(
            fallback,
            {
                "cell_count": 40,
                "generic_leakage_hits": [],
                "proof_class": "local_contract_validation",
            },
        )
        probe = self.root / "probe.json"
        write_json(
            probe,
            {
                "case_count": 40,
                "no_mutation_pass_count": 40,
                "generic_leakage_count": 0,
                "proof_class": "runtime",
            },
        )
        partial_producer = self.root / "partial-producer.json"
        write_json(
            partial_producer,
            {
                "fixture_sha256": "a" * 64,
                "accepted_count": 1,
                "refused_count": 1,
                "readback_count": 1,
                "in_scope_execution": {"passed": 1, "total": 1},
                "proof_class": "integration",
            },
        )
        partial_bridge = self.root / "partial-bridge.json"
        write_json(
            partial_bridge,
            {
                "fixture_sha256": "b" * 64,
                "accepted_count": 1,
                "refused_count": 1,
                "readback_count": 1,
                "proof_class": "integration",
            },
        )
        return {
            "base": base,
            "matrix": matrix,
            "manifest": manifest,
            "fallback": fallback,
            "probe": probe,
            "producer": partial_producer,
            "bridge": partial_bridge,
        }

    def build_reports(self, *, head_sha: str | None = None, mounted_catalog: Path | None = None):
        return self.checker.build_reports(
            base_receipt_path=self.paths["base"],
            matrix_path=self.paths["matrix"],
            matrix_manifest_path=self.paths["manifest"],
            mounted_catalog_path=mounted_catalog or MOUNTED_CATALOG,
            fallback_receipt_path=self.paths["fallback"],
            probe_receipt_path=self.paths["probe"],
            partial_producer_receipt_path=self.paths["producer"],
            partial_bridge_receipt_path=self.paths["bridge"],
            repo_root=REPO_ROOT,
            head_sha=head_sha or self.head_sha,
        )

    def test_anchor_has_120_cell_diff_d123_account_and_separate_metrics(self) -> None:
        anchor, metrics = self.build_reports()

        self.assertEqual(anchor["status"], "PASS")
        self.assertEqual(anchor["implementation_base_sha"], self.parent_sha)
        self.assertEqual(anchor["head_sha"], self.head_sha)
        self.assertEqual(len(anchor["matrix_cell_diff"]), 120)
        self.assertTrue(all(item["matches"] for item in anchor["matrix_cell_diff"]))
        self.assertEqual(anchor["matrix_source_sha256"], sha256_file(self.paths["manifest"]))
        self.assertEqual(anchor["mounted_catalog_diff_count"], 0)
        self.assertEqual(
            anchor["d123_primary_class_diff"],
            {
                name: {"expected": count, "actual": count, "delta": 0}
                for name, count in D123_BASELINE.items()
            },
        )
        self.assertEqual(metrics["status"], "PASS")
        self.assertEqual(metrics["in_scope_execution"], {"passed": 1, "total": 1, "rate": 1.0})
        self.assertEqual(metrics["out_of_scope_fallback"]["quality_rate"], 1.0)
        self.assertEqual(metrics["out_of_scope_fallback"]["generic_leakage_count"], 0)
        self.assertNotIn("overall_pass_rate", metrics)

    def test_stale_base_is_rejected(self) -> None:
        write_json(self.paths["base"], {"implementation_base_sha": self.head_sha})
        anchor, _ = self.build_reports(head_sha=self.parent_sha)

        self.assertEqual(anchor["status"], "FAIL")
        self.assertIn("E_STALE_BASE", anchor["errors"])

    def test_missing_required_receipt_is_rejected(self) -> None:
        self.paths["probe"].unlink()
        anchor, metrics = self.build_reports()

        self.assertEqual(anchor["status"], "FAIL")
        self.assertEqual(anchor["errors"], ["E_MISSING_RECEIPT:probe"])
        self.assertEqual(metrics["status"], "FAIL")

    def test_wrong_d123_baseline_is_rejected(self) -> None:
        matrix = json.loads(self.paths["matrix"].read_text(encoding="utf-8"))
        matrix["cells"][0]["primary_class"] = "default_executable"
        write_json(self.paths["matrix"], matrix)

        anchor, _ = self.build_reports()

        self.assertEqual(anchor["status"], "FAIL")
        self.assertIn("E_D123_BASELINE_MISMATCH", anchor["errors"])
        self.assertFalse(anchor["matrix_cell_diff"][0]["matches"])

    def test_mounted_catalog_delta_is_rejected(self) -> None:
        changed_catalog = self.root / "DDomainMountedToolCatalog.swift"
        changed_catalog.write_text(
            "public enum DDomainMountedToolCatalog {\n"
            "  public static let mountedToolNames: Set<String> = [\"invented_tool\"]\n"
            "}\n",
            encoding="utf-8",
        )

        anchor, _ = self.build_reports(mounted_catalog=changed_catalog)

        self.assertEqual(anchor["status"], "FAIL")
        self.assertIn("E_MOUNTED_CATALOG_DELTA", anchor["errors"])
        self.assertGreater(anchor["mounted_catalog_diff_count"], 0)

    def test_proof_class_upgrade_is_rejected(self) -> None:
        probe = json.loads(self.paths["probe"].read_text(encoding="utf-8"))
        probe["proof_class"] = "true_device"
        write_json(self.paths["probe"], probe)

        anchor, metrics = self.build_reports()

        self.assertEqual(anchor["status"], "FAIL")
        self.assertIn("E_PROOF_CLASS_UPGRADE:probe", anchor["errors"])
        self.assertEqual(metrics["proof_class"], "local_aggregation")

    def test_cli_writes_two_requested_durable_receipts(self) -> None:
        anchor_receipt = self.root / "durable" / "matrix-anchor-delta.json"
        metrics_receipt = self.root / "durable" / "c1-metrics.json"
        command = [
            sys.executable,
            str(CHECKER_PATH),
            "--base-receipt",
            str(self.paths["base"]),
            "--matrix",
            str(self.paths["matrix"]),
            "--matrix-manifest",
            str(self.paths["manifest"]),
            "--mounted-catalog",
            str(MOUNTED_CATALOG),
            "--fallback-receipt",
            str(self.paths["fallback"]),
            "--probe-receipt",
            str(self.paths["probe"]),
            "--partial-producer-receipt",
            str(self.paths["producer"]),
            "--partial-bridge-receipt",
            str(self.paths["bridge"]),
            "--anchor-receipt",
            str(anchor_receipt),
            "--metrics-receipt",
            str(metrics_receipt),
        ]
        completed = subprocess.run(command, cwd=REPO_ROOT, capture_output=True, text=True, check=False)

        self.assertEqual(completed.returncode, 0, completed.stderr)
        self.assertTrue(anchor_receipt.is_file())
        self.assertTrue(metrics_receipt.is_file())
        self.assertEqual(json.loads(anchor_receipt.read_text(encoding="utf-8"))["status"], "PASS")
        self.assertEqual(json.loads(metrics_receipt.read_text(encoding="utf-8"))["status"], "PASS")


if __name__ == "__main__":
    unittest.main(verbosity=2)

#!/usr/bin/env python3
"""Tests for the B4 40-probe contract and runtime receipt checker."""

from __future__ import annotations

import copy
import hashlib
import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
CHECKER_PATH = REPO_ROOT / "Tools" / "checks" / "check_runtime_no_mutation_receipts.py"
SOURCE_PATH = REPO_ROOT / "contracts" / "fallback-probes.yaml"
SCHEMA_PATH = REPO_ROOT / "contracts" / "schemas" / "fallback-probes.schema.json"
FALLBACK_PATH = REPO_ROOT / "contracts" / "fallback-scripts.yaml"
GENERATED_PATH = REPO_ROOT / "generated" / "demo-fallback-probes.catalog.json"
MANIFEST_PATH = REPO_ROOT / "Tests" / "Fixtures" / "RuntimeFallbackReceipts" / "manifest.json"
A1_CHECKER_PATH = REPO_ROOT / "Tools" / "checks" / "check_capability_matrix.py"
ACTION_PROBE_CATALOG = REPO_ROOT / "contracts" / "runtime-action-readback-probes.json"


def load_checker():
    spec = importlib.util.spec_from_file_location("check_runtime_no_mutation_receipts", CHECKER_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError("cannot load B4 checker")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


class RuntimeNoMutationReceiptCheckerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.checker = load_checker()
        cls.source = load_json(SOURCE_PATH)
        cls.schema = load_json(SCHEMA_PATH)
        cls.fallback = load_json(FALLBACK_PATH)
        cls.generated = load_json(GENERATED_PATH)

    def valid_receipt(self) -> dict:
        cases = []
        finite_reason_by_reason = {
            "safety_or_clarify_reject": "safety_or_policy_refusal",
            "unmounted_name_rejected": "name_rejected",
            "fast_path_no_match_fallback": "fast_path_no_match",
            "unknown_no_representative_entry": "no_representative_tool",
        }
        for probe in self.generated["probes"]:
            cases.append(
                {
                    "probeID": probe["probeID"],
                    "family": probe["family"],
                    "reasonKind": probe["reasonKind"],
                    "traceID": f"trace-{probe['probeID']}",
                    "finiteReason": finite_reason_by_reason[probe["reasonKind"]],
                    "stateBeforeSHA256": "a" * 64,
                    "stateAfterSHA256": "a" * 64,
                    "stateMutation": False,
                    "observedToolCallCount": 0,
                    "resultKind": probe["expectedUIReadback"]["resultKind"],
                    "safeReasonKind": probe["expectedUIReadback"]["safeReasonKind"],
                    "badgeLabel": probe["expectedUIReadback"]["badgeLabel"],
                    "dialogText": probe["expectedUIReadback"]["dialogText"],
                    "ttsText": probe["expectedUIReadback"]["ttsText"],
                }
            )
        return {
            "schemaVersion": "runtime_no_mutation_receipt_v1",
            "receiptID": self.generated["receiptID"],
            "probePackSHA256": self.generated["sourceSHA256"],
            "proofClass": "local_unit",
            "caseCount": 40,
            "expectedPairs": 40,
            "observedPairs": 40,
            "missingProbeIDs": [],
            "duplicateProbeIDs": [],
            "cases": cases,
        }

    def validate(self, *, source=None, generated=None, receipt=None) -> dict:
        return self.checker.validate_documents(
            source=source or copy.deepcopy(self.source),
            schema=copy.deepcopy(self.schema),
            fallback=copy.deepcopy(self.fallback),
            generated=generated or copy.deepcopy(self.generated),
            receipt=receipt or self.valid_receipt(),
        )

    def test_source_and_generated_cover_exact_ten_by_four_pairs(self) -> None:
        report = self.validate()
        self.assertEqual(report["status"], "PASS", report)
        self.assertEqual(report["case_count"], 40)
        self.assertEqual(report["missing_pairs"], [])
        self.assertEqual(report["duplicate_pairs"], [])

    def test_committed_catalog_is_deterministic_projection_of_sources(self) -> None:
        expected = self.checker.build_generated_catalog(self.source, self.fallback)
        self.assertEqual(expected, self.generated)

    def test_missing_pair_fails_closed(self) -> None:
        source = copy.deepcopy(self.source)
        source["probes"].pop()
        report = self.validate(source=source)
        self.assertIn("missing_family_reason_pairs", report["errors"])

    def test_duplicate_pair_fails_closed(self) -> None:
        source = copy.deepcopy(self.source)
        source["probes"][-1] = copy.deepcopy(source["probes"][0])
        report = self.validate(source=source)
        self.assertIn("duplicate_family_reason_pairs", report["errors"])

    def test_forced_state_delta_fails_closed(self) -> None:
        receipt = self.valid_receipt()
        receipt["cases"][0]["stateAfterSHA256"] = "b" * 64
        receipt["cases"][0]["stateMutation"] = True
        report = self.validate(receipt=receipt)
        self.assertIn("state_mutation_detected", report["errors"])

    def test_forced_tool_call_fails_closed(self) -> None:
        receipt = self.valid_receipt()
        receipt["cases"][0]["observedToolCallCount"] = 1
        report = self.validate(receipt=receipt)
        self.assertIn("tool_call_detected", report["errors"])

    def test_missing_trace_fails_closed(self) -> None:
        receipt = self.valid_receipt()
        receipt["cases"][0]["traceID"] = ""
        report = self.validate(receipt=receipt)
        self.assertIn("missing_trace", report["errors"])

    def test_copy_mismatch_fails_closed(self) -> None:
        receipt = self.valid_receipt()
        receipt["cases"][0]["dialogText"] = "第二份手写文案"
        report = self.validate(receipt=receipt)
        self.assertIn("fallback_copy_mismatch", report["errors"])

    def test_receipt_probe_pack_sha_must_match_generated_source(self) -> None:
        receipt = self.valid_receipt()
        receipt["probePackSHA256"] = "0" * 64
        report = self.validate(receipt=receipt)
        self.assertIn("probe_pack_sha_mismatch", report["errors"])

    def test_source_references_fallback_copy_instead_of_duplicating_it(self) -> None:
        forbidden = {"dialogText", "ttsText", "badgeLabel", "resultKind", "safeReasonKind"}
        for probe in self.source["probes"]:
            expected_ui = probe["readbackProbePass"]["expected_ui_readback"]
            self.assertEqual(set(expected_ui), {"fallback_cell_id"}, probe["probe_id"])
            self.assertTrue(forbidden.isdisjoint(probe), probe["probe_id"])

    def test_manifest_declares_the_runtime_receipt_contract(self) -> None:
        manifest = load_json(MANIFEST_PATH)
        self.assertEqual(manifest["receiptID"], "runtime-no-mutation-40-probes")
        self.assertEqual(manifest["caseCount"], 40)
        self.assertEqual(manifest["proofClass"], "local_unit")

    def test_no_mutation_receipt_never_promotes_action_can_demo(self) -> None:
        with tempfile.TemporaryDirectory(prefix="b4-matrix-refresh-") as tmp:
            tmp_path = Path(tmp)
            receipt_path = tmp_path / "runtime-receipt.json"
            matrix_path = tmp_path / "matrix.json"
            check_receipt_path = tmp_path / "matrix-check.json"
            receipt_path.write_text(
                json.dumps(self.valid_receipt(), ensure_ascii=False),
                encoding="utf-8",
            )
            materialize = subprocess.run(
                [
                    sys.executable,
                    str(A1_CHECKER_PATH),
                    "materialize",
                    "--output",
                    str(matrix_path),
                ],
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertEqual(materialize.returncode, 0, materialize.stderr)
            matrix = load_json(matrix_path)
            self.assertEqual(
                [cell["matrix_id"] for cell in matrix["cells"] if cell["canDemo"]],
                [],
            )
            self.assertEqual(
                matrix["source"]["probe_pack_sha256"],
                hashlib.sha256(ACTION_PROBE_CATALOG.read_bytes()).hexdigest(),
            )
            self.assertEqual(
                sum(
                    cell["canDemo_basis"]["readbackProbePass"]["status"] == "passed"
                    for cell in matrix["cells"]
                ),
                0,
            )
            rerun_receipt = self.valid_receipt()
            for case in rerun_receipt["cases"]:
                case["traceID"] = f"rerun-{case['probeID']}"
                case["stateBeforeSHA256"] = "b" * 64
                case["stateAfterSHA256"] = "b" * 64
            receipt_path.write_text(
                json.dumps(rerun_receipt, ensure_ascii=False),
                encoding="utf-8",
            )
            rerun_matrix_path = tmp_path / "matrix-rerun.json"
            rerun = subprocess.run(
                [
                    sys.executable,
                    str(A1_CHECKER_PATH),
                    "materialize",
                    "--output",
                    str(rerun_matrix_path),
                ],
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertEqual(rerun.returncode, 0, rerun.stderr)
            self.assertEqual(matrix_path.read_bytes(), rerun_matrix_path.read_bytes())
            checked = subprocess.run(
                [
                    sys.executable,
                    str(A1_CHECKER_PATH),
                    "check",
                    "--matrix",
                    str(matrix_path),
                    "--receipt",
                    str(check_receipt_path),
                ],
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertEqual(checked.returncode, 0, checked.stderr)
            report = load_json(check_receipt_path)
            self.assertEqual(report["canDemo_count"], 0)
            self.assertEqual(report["conditional_pending_count"], 120)


if __name__ == "__main__":
    unittest.main(verbosity=2)

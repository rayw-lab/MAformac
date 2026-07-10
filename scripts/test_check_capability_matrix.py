#!/usr/bin/env python3
"""Test-first coverage for the A1 DemoCapabilityMatrix materializer/checker."""

from __future__ import annotations

import copy
import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
from collections import Counter
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
CHECKER_PATH = REPO_ROOT / "Tools" / "checks" / "check_capability_matrix.py"
CANONICAL_MANIFEST = REPO_ROOT / "contracts" / "demo-capability-matrix-manifest.jsonl"
T0_DESIGN = (
    REPO_ROOT
    / "openspec"
    / "changes"
    / "add-c1-demo-capability-governance"
    / "design.md"
)
MANIFEST = CANONICAL_MANIFEST
SEMANTIC_CONTRACT = REPO_ROOT / "contracts" / "semantic-function-contract.jsonl"
STATE_CELLS = REPO_ROOT / "contracts" / "state-cells.yaml"
MOUNTED_CATALOG = REPO_ROOT / "Core" / "Contracts" / "DDomainMountedToolCatalog.swift"
ACTION_PROBE_CATALOG = REPO_ROOT / "contracts" / "runtime-action-readback-probes.json"
MATRIX = REPO_ROOT / "contracts" / "demo-capability-matrix.json"
SCHEMA = REPO_ROOT / "contracts" / "schemas" / "demo-capability-matrix.schema.json"
FIXTURES = REPO_ROOT / "Tools" / "checks" / "fixtures" / "demo_capability_matrix"


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


class CapabilityMatrixCheckerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        for path in (T0_DESIGN, SEMANTIC_CONTRACT, STATE_CELLS, MOUNTED_CATALOG):
            if not path.exists():
                raise AssertionError(f"required A1 source is missing: {path}")

    def test_canonical_manifest_is_repository_owned(self) -> None:
        self.assertTrue(
            CANONICAL_MANIFEST.is_file(),
            "A1 materializer must have a committed manifest under contracts/",
        )
        self.assertEqual(CANONICAL_MANIFEST.parent, REPO_ROOT / "contracts")

    def test_default_materializer_reads_canonical_manifest(self) -> None:
        checker = self.checker()
        matrix = checker.materialize_matrix(
            t0_design_path=T0_DESIGN,
            semantic_contract_path=SEMANTIC_CONTRACT,
            state_cells_path=STATE_CELLS,
            mounted_catalog_path=MOUNTED_CATALOG,
        )
        self.assertEqual(len(matrix["cells"]), 120)
        self.assertEqual(matrix["source"]["manifest_sha256"], "5c8faa54c7b28efa4daf9dc1bf7262481b65b72d43bb5ea6aac9e0ad0d2ffba6")

    def checker(self):
        if not CHECKER_PATH.exists():
            self.skipTest("checker production code has not been written yet")
        spec = importlib.util.spec_from_file_location("check_capability_matrix", CHECKER_PATH)
        assert spec is not None and spec.loader is not None
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        return module

    def materialize(self) -> tuple[object, dict]:
        checker = self.checker()
        return checker, checker.materialize_matrix(
            manifest_path=MANIFEST,
            t0_design_path=T0_DESIGN,
            semantic_contract_path=SEMANTIC_CONTRACT,
            state_cells_path=STATE_CELLS,
            mounted_catalog_path=MOUNTED_CATALOG,
        )

    def v2_matrix(self) -> dict:
        _, matrix = self.materialize()
        return matrix

    def validate(self, checker: object, matrix: dict) -> dict:
        return checker.validate_matrix(
            matrix=matrix,
            schema_path=SCHEMA,
            manifest_path=MANIFEST,
            t0_design_path=T0_DESIGN,
            semantic_contract_path=SEMANTIC_CONTRACT,
            state_cells_path=STATE_CELLS,
            mounted_catalog_path=MOUNTED_CATALOG,
        )

    def assert_cli_rejects(self, matrix: dict, expected_errors: set[str]) -> None:
        with tempfile.TemporaryDirectory(prefix="a1-matrix-negative-") as tmp:
            tmp_path = Path(tmp)
            matrix_path = tmp_path / "matrix.json"
            receipt_path = tmp_path / "receipt.json"
            matrix_path.write_text(json.dumps(matrix, ensure_ascii=False), encoding="utf-8")
            result = subprocess.run(
                [
                    sys.executable,
                    str(CHECKER_PATH),
                    "check",
                    "--matrix",
                    str(matrix_path),
                    "--schema",
                    str(SCHEMA),
                    "--receipt",
                    str(receipt_path),
                ],
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertNotEqual(result.returncode, 0, result.stderr)
            self.assertTrue(receipt_path.is_file(), result.stderr)
            self.assertTrue(expected_errors.issubset(set(load_json(receipt_path)["errors"])))

    def valid_action_receipt(self, checker: object) -> dict:
        catalog = load_json(ACTION_PROBE_CATALOG)
        cases = []
        for probe in catalog["probes"]:
            target = probe["expectedStateDelta"]
            readback = probe["expectedReadback"]
            cases.append(
                {
                    "probeID": probe["probeID"],
                    "matrixID": probe["matrixID"],
                    "register": probe["register"],
                    "utterance": probe["utterance"],
                    "representativeTool": probe["representativeTool"],
                    "pathKind": "default_runtime",
                    "injectionUsed": False,
                    "traceID": f"trace-matrix-{probe['matrixID']}",
                    "stageTraceIDs": {
                        "decode": [f"trace-matrix-{probe['matrixID']}"],
                        "execute": [f"trace-matrix-{probe['matrixID']}"],
                        "readback": [f"trace-matrix-{probe['matrixID']}"],
                    },
                    "observedToolCallCount": 1,
                    "emittedToolNames": [probe["representativeTool"]],
                    "stateBeforeSHA256": "a" * 64,
                    "stateAfterSHA256": "b" * 64,
                    "stateMutation": True,
                    "stateDeltas": [
                        {
                            "key": target["key"],
                            "beforeValue": target["beforeValue"],
                            "afterValue": target["afterValue"],
                        }
                    ],
                    "confirmedState": {
                        "key": target["key"],
                        "actualValue": target["afterValue"],
                    },
                    "resultKind": "accepted_tool_call",
                    "reconciliationStatus": "verified",
                    "readbacks": [
                        {
                            "key": readback["key"],
                            "actualValue": readback["actualValue"],
                            "spokenText": "主驾空调已调到26度",
                        }
                    ],
                }
            )
        return {
            "schemaVersion": "runtime_action_readback_receipt_v1",
            "receiptID": catalog["receiptID"],
            "probePackSHA256": checker.sha256_file(ACTION_PROBE_CATALOG),
            "proofClass": "local_unit",
            "caseCount": len(cases),
            "cases": cases,
        }

    def mutate_with_fixture(self, fixture_name: str) -> tuple[object, dict]:
        checker, matrix = self.materialize()
        fixture = load_json(FIXTURES / fixture_name)
        cells = matrix["cells"]
        matrix_id = fixture.get("matrix_id")
        target = next((cell for cell in cells if cell["matrix_id"] == matrix_id), None)
        operation = fixture["operation"]

        if operation == "remove_basis":
            assert target is not None
            del target["actionDemoProven_basis"][fixture["basis"]]
        elif operation == "set_primary_class":
            assert target is not None
            target["primary_class"] = fixture["value"]
        elif operation == "duplicate_matrix_id":
            assert target is not None
            duplicate = copy.deepcopy(target)
            duplicate["matrix_id"] = fixture["duplicate_of"]
            cells.append(duplicate)
        elif operation == "set_action_demo_proven":
            assert target is not None
            target["actionDemoProven"] = fixture["value"]
        elif operation == "set_reason_kind":
            assert target is not None
            target["reasonKind"] = fixture["value"]
        elif operation == "drop_first_no_representative":
            matrix["cells"] = [
                cell for cell in cells if cell["mounted_status"] != "no_representative_tool"
            ]
        else:
            self.fail(f"unknown fixture operation: {operation}")
        return checker, matrix

    def test_checker_module_exists(self) -> None:
        self.assertTrue(CHECKER_PATH.is_file(), "A1 checker module must exist")

    def test_materializes_exactly_120_seed_rows(self) -> None:
        _, matrix = self.materialize()
        manifest_ids = {
            json.loads(line)["matrix_id"]
            for line in MANIFEST.read_text(encoding="utf-8").splitlines()
            if line.strip()
        }
        self.assertEqual(len(matrix["cells"]), 120)
        self.assertEqual({cell["matrix_id"] for cell in matrix["cells"]}, manifest_ids)

    def test_each_cell_has_traceable_four_part_basis(self) -> None:
        _, matrix = self.materialize()
        required_basis = {
            "mounted_or_approved_action",
            "semantic_contract",
            "state_readback_cell",
            "readbackProbePass",
        }
        for cell in matrix["cells"]:
            self.assertEqual(set(cell["actionDemoProven_basis"]), required_basis)
            self.assertTrue(cell["anchors"])
            for basis in cell["actionDemoProven_basis"].values():
                self.assertIsInstance(basis["observed"], bool)
                self.assertTrue(basis["source_ref"])
            probe_basis = cell["actionDemoProven_basis"]["readbackProbePass"]
            self.assertFalse(probe_basis["observed"])
            self.assertEqual(probe_basis["status"], "conditional_pending")
            self.assertIsNone(probe_basis["probe_id"])
            self.assertIsNone(probe_basis["probe_receipt_id"])

    def test_primary_class_conservation_diff_matches_manifest(self) -> None:
        checker, matrix = self.materialize()
        report = self.validate(checker, matrix)
        manifest_counts = Counter(
            json.loads(line)["primary_class"]
            for line in MANIFEST.read_text(encoding="utf-8").splitlines()
            if line.strip()
        )
        self.assertEqual(report["primary_class_counts"], dict(sorted(manifest_counts.items())))
        self.assertEqual(len(report["primary_class_counts"]), 4)
        self.assertEqual(sum(report["primary_class_counts"].values()), 120)
        self.assertEqual(report["primary_class_diff"], {})

    def test_blocked_unknown_is_zero(self) -> None:
        checker, matrix = self.materialize()
        report = self.validate(checker, matrix)
        self.assertEqual(report["blocked_unknown_count"], 0)
        self.assertNotIn("E_T0_ENUM_UNKNOWN", report["errors"])

    def test_action_demo_proven_is_logical_and_of_four_same_cell_action_bases(self) -> None:
        checker, _ = self.materialize()
        all_true = {
            "mounted_or_approved_action": {"observed": True},
            "semantic_contract": {"observed": True},
            "state_readback_cell": {"observed": True},
            "readbackProbePass": {
                "observed": True,
                "probe_id": "probe.action.matrix.4.zh-CN",
                "probe_receipt_id": "runtime-action-readback-probes",
                "receipt_sha256": "c" * 64,
            },
        }
        self.assertTrue(checker.compute_action_demo_proven(all_true))
        for key in all_true:
            trial = copy.deepcopy(all_true)
            trial[key]["observed"] = False
            self.assertFalse(checker.compute_action_demo_proven(trial), key)

    def test_action_demo_proven_true_requires_probe_id_and_receipt_id(self) -> None:
        checker, _ = self.materialize()
        basis = {
            "mounted_or_approved_action": {"observed": True},
            "semantic_contract": {"observed": True},
            "state_readback_cell": {"observed": True},
            "readbackProbePass": {
                "observed": True,
                "probe_id": "probe.action.matrix.4.zh-CN",
                "probe_receipt_id": "runtime-action-readback-probes",
                "receipt_sha256": "c" * 64,
            },
        }
        for missing_field in ("probe_id", "probe_receipt_id"):
            trial = copy.deepcopy(basis)
            trial["readbackProbePass"][missing_field] = None
            self.assertFalse(checker.compute_action_demo_proven(trial), missing_field)

    def test_fallback_probe_id_is_rejected_for_action_readback(self) -> None:
        checker, _ = self.materialize()
        basis = {
            "mounted_or_approved_action": {"observed": True},
            "semantic_contract": {"observed": True},
            "state_readback_cell": {"observed": True},
            "readbackProbePass": {
                "observed": True,
                "probe_id": "probe.fallback.ac.fast_path_no_match_fallback.zh-CN",
                "probe_receipt_id": "runtime-no-mutation-40-probes",
            },
        }
        self.assertFalse(checker.compute_action_demo_proven(basis))

    def test_action_receipt_path_must_exist_inside_authority_root(self) -> None:
        checker, _ = self.materialize()
        receipt = self.valid_action_receipt(checker)
        missing = REPO_ROOT / ".build" / "missing-action-receipt.json"
        with self.assertRaisesRegex(ValueError, "E_ACTION_DEMO_PROVEN_RECEIPT_MISSING"):
            checker.evaluate_action_probe_receipt(
                receipt=receipt,
                receipt_path=missing,
                catalog_path=ACTION_PROBE_CATALOG,
                authority_root=REPO_ROOT,
            )

        with tempfile.TemporaryDirectory(prefix="outside-action-authority-") as tmp:
            outside = Path(tmp) / "receipt.json"
            outside.write_text(json.dumps(receipt), encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "E_ACTION_DEMO_PROVEN_RECEIPT_OUTSIDE_AUTHORITY"):
                checker.evaluate_action_probe_receipt(
                    receipt=receipt,
                    receipt_path=outside,
                    catalog_path=ACTION_PROBE_CATALOG,
                    authority_root=REPO_ROOT,
                )

    def test_action_receipt_requires_independent_probe_per_cell(self) -> None:
        checker, _ = self.materialize()
        receipt = self.valid_action_receipt(checker)
        receipt["cases"][1]["probeID"] = receipt["cases"][0]["probeID"]
        with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="action-receipt-") as tmp:
            receipt_path = Path(tmp) / "receipt.json"
            receipt_path.write_text(json.dumps(receipt), encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "E_ACTION_DEMO_PROVEN_PROBE_REUSED"):
                checker.evaluate_action_probe_receipt(
                    receipt=receipt,
                    receipt_path=receipt_path,
                    catalog_path=ACTION_PROBE_CATALOG,
                    authority_root=REPO_ROOT,
                )

    def test_action_probe_catalog_requires_unique_utterance_and_fingerprint(self) -> None:
        checker, _ = self.materialize()
        catalog = load_json(ACTION_PROBE_CATALOG)
        receipt = self.valid_action_receipt(checker)
        catalog["probes"][1]["utterance"] = catalog["probes"][0]["utterance"]
        receipt["cases"][1]["utterance"] = receipt["cases"][0]["utterance"]
        with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="action-catalog-") as tmp:
            tmp_path = Path(tmp)
            catalog_path = tmp_path / "catalog.json"
            receipt_path = tmp_path / "receipt.json"
            catalog_path.write_text(json.dumps(catalog), encoding="utf-8")
            receipt["probePackSHA256"] = checker.sha256_file(catalog_path)
            receipt_path.write_text(json.dumps(receipt), encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "E_ACTION_DEMO_PROVEN_PROBE_REUSED"):
                checker.evaluate_action_probe_receipt(
                    receipt=receipt,
                    receipt_path=receipt_path,
                    catalog_path=catalog_path,
                    authority_root=REPO_ROOT,
                )

    def test_action_probe_catalog_must_match_canonical_cell_register_and_tool(self) -> None:
        checker, _ = self.materialize()
        mutations = {
            "register": ("register", "直述"),
            "representative_tool": ("representativeTool", "open_ac"),
        }
        for label, (field, value) in mutations.items():
            with self.subTest(label=label):
                catalog = load_json(ACTION_PROBE_CATALOG)
                receipt = self.valid_action_receipt(checker)
                catalog["probes"][1][field] = value
                receipt["cases"][1][field] = value
                with tempfile.TemporaryDirectory(
                    dir=REPO_ROOT / ".build", prefix="action-cell-binding-"
                ) as tmp:
                    tmp_path = Path(tmp)
                    catalog_path = tmp_path / "catalog.json"
                    receipt_path = tmp_path / "receipt.json"
                    catalog_path.write_text(json.dumps(catalog), encoding="utf-8")
                    receipt["probePackSHA256"] = checker.sha256_file(catalog_path)
                    receipt_path.write_text(json.dumps(receipt), encoding="utf-8")
                    with self.assertRaisesRegex(ValueError, "E_ACTION_DEMO_PROVEN_PROBE_CELL_MISMATCH"):
                        checker.evaluate_action_probe_receipt(
                            receipt=receipt,
                            receipt_path=receipt_path,
                            catalog_path=catalog_path,
                            authority_root=REPO_ROOT,
                        )

    def test_action_receipt_fails_closed_on_conditional_or_incomplete_truth(self) -> None:
        checker, _ = self.materialize()
        mutations = {
            "conditional": lambda case: case.update(injectionUsed=True),
            "no_tool_call": lambda case: case.update(observedToolCallCount=0),
            "no_state_delta": lambda case: case.update(
                stateMutation=False,
                stateAfterSHA256=case["stateBeforeSHA256"],
                stateDeltas=[],
            ),
            "readback_mismatch": lambda case: case["readbacks"][0].update(actualValue="25"),
            "trace_break": lambda case: case["stageTraceIDs"]["readback"].__setitem__(0, "other-trace"),
        }
        for label, mutate in mutations.items():
            with self.subTest(label=label):
                receipt = self.valid_action_receipt(checker)
                mutate(receipt["cases"][0])
                with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="action-receipt-") as tmp:
                    receipt_path = Path(tmp) / "receipt.json"
                    receipt_path.write_text(json.dumps(receipt), encoding="utf-8")
                    evaluation = checker.evaluate_action_probe_receipt(
                        receipt=receipt,
                        receipt_path=receipt_path,
                        catalog_path=ACTION_PROBE_CATALOG,
                        authority_root=REPO_ROOT,
                    )
                self.assertNotIn(4, evaluation["passing_by_matrix_id"], label)
                self.assertIn(4, evaluation["failures_by_matrix_id"], label)

    def test_action_pass_cannot_hide_fallback_classification(self) -> None:
        checker, _ = self.materialize()
        receipt = self.valid_action_receipt(checker)
        with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="action-receipt-") as tmp:
            receipt_path = Path(tmp) / "receipt.json"
            receipt_path.write_text(json.dumps(receipt), encoding="utf-8")
            matrix = checker.materialize_matrix(
                manifest_path=MANIFEST,
                t0_design_path=T0_DESIGN,
                semantic_contract_path=SEMANTIC_CONTRACT,
                state_cells_path=STATE_CELLS,
                mounted_catalog_path=MOUNTED_CATALOG,
                action_probe_receipt=receipt,
                action_probe_receipt_path=receipt_path,
                action_probe_catalog_path=ACTION_PROBE_CATALOG,
            )
            report = checker.validate_matrix(
                matrix=matrix,
                manifest_path=MANIFEST,
                t0_design_path=T0_DESIGN,
                semantic_contract_path=SEMANTIC_CONTRACT,
                state_cells_path=STATE_CELLS,
                mounted_catalog_path=MOUNTED_CATALOG,
                action_probe_receipt=receipt,
                action_probe_receipt_path=receipt_path,
                action_probe_catalog_path=ACTION_PROBE_CATALOG,
            )
        self.assertEqual(
            [cell["matrix_id"] for cell in matrix["cells"] if cell["actionDemoProven"]],
            [4, 5, 6],
        )
        self.assertIn("E_ACTION_DEMO_PROVEN_DEFAULT_PATH_CONTRADICTION", report["errors"])

    def test_live_matrix_has_zero_probe_gated_demo_cells(self) -> None:
        checker, matrix = self.materialize()
        report = self.validate(checker, matrix)
        self.assertEqual(report["actionDemoProven_count"], 0)
        self.assertEqual(report["conditional_pending_count"], 120)
        self.assertEqual(report["status"], "PASS")

    def test_tracked_matrix_is_byte_identical_to_fresh_materialization(self) -> None:
        checker, expected = self.materialize()
        self.assertEqual(load_json(MATRIX), expected)

    def test_cli_rejects_named_canonical_envelope_mutations(self) -> None:
        baseline = load_json(MATRIX)
        cases = {
            "stale_source_provenance": (
                lambda matrix: matrix["source"].__setitem__("t0_design_sha256", "0" * 64),
                {"E_MATRIX_CANONICAL_DRIFT"},
            ),
            "missing_source": (
                lambda matrix: matrix.pop("source"),
                {"E_MATRIX_SCHEMA_INVALID", "E_MATRIX_CANONICAL_DRIFT"},
            ),
            "wrong_schema_version": (
                lambda matrix: matrix.__setitem__("schema_version", "bogus_v999"),
                {"E_MATRIX_SCHEMA_INVALID", "E_MATRIX_CANONICAL_DRIFT"},
            ),
            "tampered_family": (
                lambda matrix: matrix["cells"][0].__setitem__("family", "tampered-family"),
                {"E_MATRIX_CANONICAL_DRIFT"},
            ),
            "tampered_value_shape": (
                lambda matrix: matrix["cells"][0].__setitem__("value_shape", "tampered-shape"),
                {"E_MATRIX_CANONICAL_DRIFT"},
            ),
            "tampered_register": (
                lambda matrix: matrix["cells"][0].__setitem__("register", "tampered-register"),
                {"E_MATRIX_CANONICAL_DRIFT"},
            ),
            "tampered_injected_path_status": (
                lambda matrix: matrix["cells"][0].__setitem__("injected_path_status", "tampered-status"),
                {"E_MATRIX_CANONICAL_DRIFT"},
            ),
            "tampered_source_hash": (
                lambda matrix: matrix["cells"][0].__setitem__("source_hash", "0" * 64),
                {"E_MATRIX_CANONICAL_DRIFT"},
            ),
            "tampered_anchors": (
                lambda matrix: matrix["cells"][0].__setitem__("anchors", ["tampered-anchor"]),
                {"E_MATRIX_CANONICAL_DRIFT"},
            ),
            "matrix_id_999": (
                lambda matrix: matrix["cells"][0].__setitem__("matrix_id", 999),
                {"E_MATRIX_ID_SET_MISMATCH", "E_MATRIX_CANONICAL_DRIFT"},
            ),
        }
        for name, (mutate, expected_errors) in cases.items():
            with self.subTest(name=name):
                mutated = copy.deepcopy(baseline)
                mutate(mutated)
                self.assert_cli_rejects(mutated, expected_errors)

    def test_matrix_schema_is_actually_executed(self) -> None:
        checker, matrix = self.materialize()
        matrix.pop("source")
        self.assertIn("E_MATRIX_SCHEMA_INVALID", self.validate(checker, matrix)["errors"])

    def test_v2_rejects_legacy_action_key(self) -> None:
        matrix = self.v2_matrix()
        self.assertEqual(load_json(FIXTURES / "legacy-action-key.json")["key"], "canDemo")
        matrix["cells"][0]["canDemo"] = False
        errors = self.checker().validate_matrix_schema(matrix=matrix, schema_path=SCHEMA)
        self.assertTrue(any(error["path"] == "cells/0" for error in errors), errors)

    def test_v2_requires_action_demo_proven_basis(self) -> None:
        matrix = self.v2_matrix()
        del matrix["cells"][0]["actionDemoProven_basis"]
        errors = self.checker().validate_matrix_schema(matrix=matrix, schema_path=SCHEMA)
        self.assertTrue(any("actionDemoProven_basis" in error["message"] for error in errors), errors)

    def test_v2_rejects_unknown_cell_key(self) -> None:
        matrix = self.v2_matrix()
        matrix["cells"][0]["unexpectedProof"] = True
        errors = self.checker().validate_matrix_schema(matrix=matrix, schema_path=SCHEMA)
        self.assertTrue(any("Additional properties" in error["message"] for error in errors), errors)

    def test_weakened_schema_contract_fails_even_for_valid_matrix(self) -> None:
        schema = json.loads(SCHEMA.read_text(encoding="utf-8"))
        schema["properties"]["cells"]["items"].pop("required")
        with tempfile.TemporaryDirectory() as temp:
            weakened = Path(temp) / "schema.json"
            weakened.write_text(json.dumps(schema), encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "E_MATRIX_SCHEMA_CONTRACT_INVALID"):
                self.checker().validate_matrix_schema(matrix=self.v2_matrix(), schema_path=weakened)

    def test_diff_target_requires_matrix_and_swift_canonical_regeneration(self) -> None:
        makefile = (REPO_ROOT / "Makefile").read_text(encoding="utf-8")
        self.assertIn("diff: verify-c1-matrix-canonical", makefile)
        self.assertIn("check_capability_matrix.py materialize", makefile)
        self.assertIn("cmp -s contracts/demo-capability-matrix.json", makefile)
        self.assertIn("generate_demo_capability_matrix_swift.py", makefile)
        self.assertIn("cmp -s Core/Contracts/DemoCapabilityMatrix.generated.swift", makefile)

    def test_missing_basis_is_rejected(self) -> None:
        checker, matrix = self.mutate_with_fixture("missing-basis.json")
        self.assertIn("E_BASIS_UNTRACEABLE", self.validate(checker, matrix)["errors"])

    def test_unknown_t0_enum_is_rejected(self) -> None:
        checker, matrix = self.mutate_with_fixture("unknown-enum.json")
        self.assertIn("E_T0_ENUM_UNKNOWN", self.validate(checker, matrix)["errors"])

    def test_duplicate_matrix_id_is_rejected(self) -> None:
        checker, matrix = self.mutate_with_fixture("duplicate-id.json")
        self.assertIn("E_DUPLICATE_MATRIX_ID", self.validate(checker, matrix)["errors"])

    def test_fastpath_only_action_demo_proven_green_is_rejected(self) -> None:
        checker, matrix = self.mutate_with_fixture("fastpath-only-action-demo-proven.json")
        self.assertIn("E_ACTION_DEMO_PROVEN_MANUAL_OVERRIDE", self.validate(checker, matrix)["errors"])

    def test_free_string_reason_kind_is_rejected(self) -> None:
        checker, matrix = self.mutate_with_fixture("free-string-reason.json")
        self.assertIn("E_T0_REASON_KIND_FREE_STRING", self.validate(checker, matrix)["errors"])

    def test_dropped_no_representative_row_is_rejected(self) -> None:
        checker, matrix = self.mutate_with_fixture("dropped-no-representative.json")
        self.assertIn("E_NO_REPRESENTATIVE_DROPPED", self.validate(checker, matrix)["errors"])

    def test_cli_writes_a_pass_receipt_for_probe_pending_live_manifest(self) -> None:
        self.checker()
        with tempfile.TemporaryDirectory(prefix="a1-matrix-test-") as tmp:
            tmp_path = Path(tmp)
            matrix = tmp_path / "matrix.json"
            receipt = tmp_path / "receipt.json"
            materialize = subprocess.run(
                [
                    sys.executable,
                    str(CHECKER_PATH),
                    "materialize",
                    "--t0-design",
                    str(T0_DESIGN),
                    "--output",
                    str(matrix),
                ],
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertEqual(materialize.returncode, 0, materialize.stderr)
            checked = subprocess.run(
                [
                    sys.executable,
                    str(CHECKER_PATH),
                    "check",
                    "--t0-design",
                    str(T0_DESIGN),
                    "--matrix",
                    str(matrix),
                    "--receipt",
                    str(receipt),
                ],
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertEqual(checked.returncode, 0, checked.stderr)
            report = load_json(receipt)
            self.assertEqual(report["status"], "PASS")
            self.assertEqual(report["actionDemoProven_count"], 0)
            self.assertEqual(report["conditional_pending_count"], 120)


if __name__ == "__main__":
    unittest.main(verbosity=2)

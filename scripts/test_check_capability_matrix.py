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
SCOPED_ACTION_PROBE_RECEIPT = (
    REPO_ROOT / ".build" / "c1-run" / "receipts" / "c1" / "runtime-action-readback-probes-scoped-4.json"
)
BF8_PROMOTION_RECEIPT = (
    REPO_ROOT / "contracts" / "governance" / "bf8-promotion-receipt-matrix-4.json"
)
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
        self.assertEqual(matrix["source"]["manifest_sha256"], "9d54ab13552e46c072ecd9696cd36bfe645254425df8679b46c0828c449e7d58")

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

    def materialize_tracked_baseline(self) -> tuple[object, dict]:
        checker = self.checker()
        common = dict(
            manifest_path=MANIFEST,
            t0_design_path=T0_DESIGN,
            semantic_contract_path=SEMANTIC_CONTRACT,
            state_cells_path=STATE_CELLS,
            mounted_catalog_path=MOUNTED_CATALOG,
        )
        if SCOPED_ACTION_PROBE_RECEIPT.is_file():
            receipt = load_json(SCOPED_ACTION_PROBE_RECEIPT)
            kwargs = {}
            if BF8_PROMOTION_RECEIPT.is_file():
                kwargs["bf8_promotion_receipt"] = load_json(BF8_PROMOTION_RECEIPT)
                kwargs["bf8_promotion_receipt_path"] = BF8_PROMOTION_RECEIPT
            matrix = checker.materialize_matrix(
                **common,
                action_probe_receipt=receipt,
                action_probe_receipt_path=SCOPED_ACTION_PROBE_RECEIPT,
                action_probe_catalog_path=ACTION_PROBE_CATALOG,
                **kwargs,
            )
            return checker, matrix
        return self.materialize()

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
                    "pathKind": "product_acceptance_route",
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

    def valid_scoped_action_receipt(self, checker: object, matrix_ids: list[int] = [4]) -> dict:
        catalog = load_json(ACTION_PROBE_CATALOG)
        cases = []
        for probe in catalog["probes"]:
            if probe["matrixID"] not in matrix_ids:
                continue
            target = probe["expectedStateDelta"]
            readback = probe["expectedReadback"]
            cases.append(
                {
                    "probeID": probe["probeID"],
                    "matrixID": probe["matrixID"],
                    "register": probe["register"],
                    "utterance": probe["utterance"],
                    "representativeTool": probe["representativeTool"],
                    "pathKind": "product_acceptance_route",
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
        try:
            subject_sha = subprocess.run(
                ["git", "rev-parse", "HEAD"],
                cwd=REPO_ROOT,
                capture_output=True,
                text=True,
                check=True,
            ).stdout.strip()
        except Exception:
            subject_sha = "a" * 40
        return {
            "schemaVersion": "runtime_action_readback_receipt_v2",
            "receiptID": catalog["receiptID"],
            "probePackSHA256": checker.sha256_file(ACTION_PROBE_CATALOG),
            "proofClass": "local_unit",
            "caseCount": len(cases),
            "scope": {
                "matrix_ids": matrix_ids,
                "knife": "s10_knife1",
            },
            "cases": cases,
            "runID": "run-scoped-test",
            "sourceHeadSHA": subject_sha,
            "testedCheckoutSHA": subject_sha,
            "nonce": "c" * 32,
            "buildIdentity": "test-build",
            "modelIdentity": "test-model",
            "runtimeContractBundleDigest": load_json(
                REPO_ROOT / "generated" / "demo-runtime-contract-bundle.manifest.json"
            )["runtime_contract_bundle_digest"],
            "probe_catalog_sha256": checker.sha256_file(ACTION_PROBE_CATALOG),
        }

    def valid_bf8_receipt(
        self, checker: object, matrix_ids: list[int] = [4], subject_sha: str | None = None
    ) -> dict:
        if subject_sha is None:
            try:
                subject_sha = subprocess.run(
                    ["git", "rev-parse", "HEAD"],
                    cwd=REPO_ROOT,
                    capture_output=True,
                    text=True,
                    check=True,
                ).stdout.strip()
            except Exception:
                subject_sha = "a" * 40
        return {
            "schemaVersion": "bf8_promotion_receipt_v1",
            "receiptID": f"bf8-promotion-matrix-{'-'.join(map(str, matrix_ids))}-test",
            "subjectSHA256": subject_sha,
            "matrix_ids": matrix_ids,
            "ceremony": {
                "artifactRef": "runs/test/BF8-PASS-RECEIPT.md",
                "approver": "磊哥",
            },
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

    def test_each_cell_has_traceable_five_part_basis(self) -> None:
        _, matrix = self.materialize()
        required_basis = {
            "mounted_or_approved_action",
            "semantic_contract",
            "state_readback_cell",
            "readbackProbePass",
            "bf8_promotion",
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
            bf8 = cell["actionDemoProven_basis"]["bf8_promotion"]
            self.assertFalse(bf8["observed"])
            self.assertEqual(bf8["status"], "pending_human_bf8")

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

    def test_action_demo_proven_is_logical_and_of_five_same_cell_action_bases(self) -> None:
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
            "bf8_promotion": {"observed": True},
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
            "bf8_promotion": {"observed": True},
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
            "bf8_promotion": {"observed": True},
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
            [],
        )

    def test_ce_m1_probe_green_without_bf8_keeps_action_demo_proven_false(self) -> None:
        checker, _ = self.materialize()
        receipt = self.valid_action_receipt(checker)
        with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="ce-m1-") as tmp:
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
            cell4 = next(cell for cell in matrix["cells"] if cell["matrix_id"] == 4)
            self.assertTrue(cell4["actionDemoProven_basis"]["readbackProbePass"]["observed"])
            self.assertFalse(cell4["actionDemoProven_basis"]["bf8_promotion"]["observed"])
            self.assertFalse(cell4["actionDemoProven"])
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
            self.assertNotIn("E_ACTION_DEMO_PROVEN_MANUAL_OVERRIDE", report["errors"])

    def test_ce_m2_default_materialize_adds_bf8_promotion_observed_false(self) -> None:
        checker, matrix = self.materialize()
        for cell in matrix["cells"]:
            self.assertIn("bf8_promotion", cell["actionDemoProven_basis"])
            bf8 = cell["actionDemoProven_basis"]["bf8_promotion"]
            self.assertFalse(bf8["observed"])
            self.assertEqual(bf8["status"], "pending_human_bf8")
        # Missing field fails validation
        del matrix["cells"][0]["actionDemoProven_basis"]["bf8_promotion"]
        report = self.validate(checker, matrix)
        self.assertIn("E_BASIS_UNTRACEABLE", report["errors"])

    def test_ce_m3_scoped_receipt_matrix_4_only_updates_scoped_cell(self) -> None:
        checker, _ = self.materialize()
        receipt = self.valid_scoped_action_receipt(checker, matrix_ids=[4])
        with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="ce-m3-") as tmp:
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
            cells_by_id = {c["matrix_id"]: c for c in matrix["cells"]}
            self.assertTrue(cells_by_id[4]["actionDemoProven_basis"]["readbackProbePass"]["observed"])
            self.assertEqual(cells_by_id[4]["actionDemoProven_basis"]["readbackProbePass"]["status"], "passed")
            self.assertFalse(cells_by_id[5]["actionDemoProven_basis"]["readbackProbePass"]["observed"])
            self.assertEqual(cells_by_id[5]["actionDemoProven_basis"]["readbackProbePass"]["status"], "conditional_pending")
            self.assertFalse(cells_by_id[6]["actionDemoProven_basis"]["readbackProbePass"]["observed"])
            self.assertEqual(cells_by_id[6]["actionDemoProven_basis"]["readbackProbePass"]["status"], "conditional_pending")

    def test_ce_m4_empty_scope_or_scope_case_mismatch_rejected(self) -> None:
        checker, _ = self.materialize()
        # Empty scope []
        receipt_empty = self.valid_scoped_action_receipt(checker, matrix_ids=[4])
        receipt_empty["scope"]["matrix_ids"] = []
        with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="ce-m4-empty-") as tmp:
            receipt_path = Path(tmp) / "receipt.json"
            receipt_path.write_text(json.dumps(receipt_empty), encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "E_ACTION_DEMO_PROVEN_ACTION_RECEIPT_SCOPE_INVALID"):
                checker.evaluate_action_probe_receipt(
                    receipt=receipt_empty,
                    receipt_path=receipt_path,
                    catalog_path=ACTION_PROBE_CATALOG,
                    authority_root=REPO_ROOT,
                )

        # Scope/case mismatch: scope has [4, 5] but cases only has matrix 4
        receipt_mismatch = self.valid_scoped_action_receipt(checker, matrix_ids=[4])
        receipt_mismatch["scope"]["matrix_ids"] = [4, 5]
        with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="ce-m4-mismatch-") as tmp:
            receipt_path = Path(tmp) / "receipt.json"
            receipt_path.write_text(json.dumps(receipt_mismatch), encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "E_ACTION_DEMO_PROVEN_ACTION_RECEIPT_COVERAGE_MISMATCH"):
                checker.evaluate_action_probe_receipt(
                    receipt=receipt_mismatch,
                    receipt_path=receipt_path,
                    catalog_path=ACTION_PROBE_CATALOG,
                    authority_root=REPO_ROOT,
                )

    def test_f2_no_bf8_receipt_all_cells_bf8_observed_false(self) -> None:
        checker, matrix = self.materialize()
        for cell in matrix["cells"]:
            self.assertIn("bf8_promotion", cell["actionDemoProven_basis"])
            bf8 = cell["actionDemoProven_basis"]["bf8_promotion"]
            self.assertFalse(bf8["observed"])
            self.assertEqual(bf8["status"], "pending_human_bf8")

    def test_f2_bf8_receipt_matrix_4_only_cell_4_promoted(self) -> None:
        checker, _ = self.materialize()
        receipt = self.valid_bf8_receipt(checker, matrix_ids=[4])
        with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="f2-m4-") as tmp:
            receipt_path = Path(tmp) / "bf8_receipt.json"
            receipt_path.write_text(json.dumps(receipt), encoding="utf-8")
            matrix = checker.materialize_matrix(
                manifest_path=MANIFEST,
                t0_design_path=T0_DESIGN,
                semantic_contract_path=SEMANTIC_CONTRACT,
                state_cells_path=STATE_CELLS,
                mounted_catalog_path=MOUNTED_CATALOG,
                bf8_promotion_receipt=receipt,
                bf8_promotion_receipt_path=receipt_path,
            )
            cells_by_id = {c["matrix_id"]: c for c in matrix["cells"]}
            cell4_bf8 = cells_by_id[4]["actionDemoProven_basis"]["bf8_promotion"]
            self.assertTrue(cell4_bf8["observed"])
            self.assertEqual(cell4_bf8["status"], "authorized")

            cell5_bf8 = cells_by_id[5]["actionDemoProven_basis"]["bf8_promotion"]
            self.assertFalse(cell5_bf8["observed"])
            self.assertEqual(cell5_bf8["status"], "pending_human_bf8")

            cell6_bf8 = cells_by_id[6]["actionDemoProven_basis"]["bf8_promotion"]
            self.assertFalse(cell6_bf8["observed"])
            self.assertEqual(cell6_bf8["status"], "pending_human_bf8")

    def test_f2_bf8_receipt_with_scoped_probe_receipt(self) -> None:
        checker, _ = self.materialize()
        action_receipt = self.valid_scoped_action_receipt(checker, matrix_ids=[4])
        bf8_receipt = self.valid_bf8_receipt(checker, matrix_ids=[4])
        with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="f2-scoped-") as tmp:
            action_path = Path(tmp) / "action_receipt.json"
            bf8_path = Path(tmp) / "bf8_receipt.json"
            action_path.write_text(json.dumps(action_receipt), encoding="utf-8")
            bf8_path.write_text(json.dumps(bf8_receipt), encoding="utf-8")
            matrix = checker.materialize_matrix(
                manifest_path=MANIFEST,
                t0_design_path=T0_DESIGN,
                semantic_contract_path=SEMANTIC_CONTRACT,
                state_cells_path=STATE_CELLS,
                mounted_catalog_path=MOUNTED_CATALOG,
                action_probe_receipt=action_receipt,
                action_probe_receipt_path=action_path,
                action_probe_catalog_path=ACTION_PROBE_CATALOG,
                bf8_promotion_receipt=bf8_receipt,
                bf8_promotion_receipt_path=bf8_path,
            )
            cells_by_id = {c["matrix_id"]: c for c in matrix["cells"]}
            cell4 = cells_by_id[4]
            self.assertTrue(cell4["actionDemoProven_basis"]["readbackProbePass"]["observed"])
            self.assertEqual(cell4["actionDemoProven_basis"]["readbackProbePass"]["status"], "passed")
            self.assertTrue(cell4["actionDemoProven_basis"]["bf8_promotion"]["observed"])
            self.assertEqual(cell4["actionDemoProven_basis"]["bf8_promotion"]["status"], "authorized")
            self.assertTrue(cell4["actionDemoProven"])

            cell5 = cells_by_id[5]
            self.assertFalse(cell5["actionDemoProven_basis"]["bf8_promotion"]["observed"])
            self.assertFalse(cell5["actionDemoProven"])


    def test_live_matrix_has_zero_probe_gated_demo_cells(self) -> None:
        checker, matrix = self.materialize()
        report = self.validate(checker, matrix)
        self.assertEqual(report["actionDemoProven_count"], 0)
        self.assertEqual(report["conditional_pending_count"], 120)
        self.assertEqual(report["status"], "PASS")

    def test_tracked_matrix_is_byte_identical_to_fresh_materialization(self) -> None:
        _, expected = self.materialize_tracked_baseline()
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

    def test_bf8_receipt_schema_validation_rejects_invalid(self) -> None:
        checker = self.checker()
        invalid_receipts = [
            ("missing_ceremony", {"schemaVersion": "bf8_promotion_receipt_v1", "receiptID": "r1", "subjectSHA256": "a" * 40, "matrix_ids": [4]}),
            ("invalid_version", {"schemaVersion": "invalid_v1", "receiptID": "r1", "subjectSHA256": "a" * 40, "matrix_ids": [4], "ceremony": {"artifactRef": "a", "approver": "b"}}),
            ("empty_matrix_ids", {"schemaVersion": "bf8_promotion_receipt_v1", "receiptID": "r1", "subjectSHA256": "a" * 40, "matrix_ids": [], "ceremony": {"artifactRef": "a", "approver": "b"}}),
            ("invalid_sha", {"schemaVersion": "bf8_promotion_receipt_v1", "receiptID": "r1", "subjectSHA256": "not-a-sha!", "matrix_ids": [4], "ceremony": {"artifactRef": "a", "approver": "b"}}),
        ]
        for name, receipt in invalid_receipts:
            with self.subTest(name=name):
                with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="bf8-test-") as tmp:
                    r_path = Path(tmp) / "receipt.json"
                    r_path.write_text(json.dumps(receipt), encoding="utf-8")
                    with self.assertRaisesRegex(ValueError, "E_BF8_RECEIPT_SCHEMA_VALIDATION_FAILED"):
                        checker.evaluate_bf8_promotion_receipt(
                            receipt=receipt,
                            receipt_path=r_path,
                            authority_root=REPO_ROOT,
                        )

    def test_bf8_receipt_outside_authority_root_is_accepted(self) -> None:
        checker = self.checker()
        receipt = self.valid_bf8_receipt(checker)
        with tempfile.TemporaryDirectory(prefix="outside-bf8-") as tmp:
            r_path = Path(tmp) / "receipt.json"
            r_path.write_text(json.dumps(receipt), encoding="utf-8")
            evaluation = checker.evaluate_bf8_promotion_receipt(
                receipt=receipt,
                receipt_path=r_path,
                authority_root=REPO_ROOT,
            )
            self.assertEqual(evaluation["authorized_matrix_ids"], {4})
            self.assertEqual(evaluation["receipt_id"], receipt["receiptID"])
            self.assertEqual(evaluation["receipt_source"], str(r_path.resolve()))

    def test_bf8_receipt_invalid_subject_sha_rejected(self) -> None:
        checker = self.checker()
        receipt = self.valid_bf8_receipt(checker, subject_sha="0" * 40)
        with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="bf8-sha-") as tmp:
            r_path = Path(tmp) / "receipt.json"
            r_path.write_text(json.dumps(receipt), encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "E_BF8_RECEIPT_SUBJECT_SHA_MISMATCH"):
                checker.evaluate_bf8_promotion_receipt(
                    receipt=receipt,
                    receipt_path=r_path,
                    authority_root=REPO_ROOT,
                )

    def test_bf8_receipt_subject_matching_explicit_expected_subject_is_accepted(self) -> None:
        checker = self.checker()
        subject_sha = "a" * 40
        receipt = self.valid_bf8_receipt(checker, subject_sha=subject_sha)
        with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="bf8-expected-subject-") as tmp:
            r_path = Path(tmp) / "receipt.json"
            r_path.write_text(json.dumps(receipt), encoding="utf-8")
            evaluation = checker.evaluate_bf8_promotion_receipt(
                receipt=receipt,
                receipt_path=r_path,
                authority_root=REPO_ROOT,
                expected_subject_sha=subject_sha,
            )
            self.assertEqual(evaluation["authorized_matrix_ids"], {4})
            self.assertEqual(evaluation["receipt_id"], receipt["receiptID"])

    def test_bf8_receipt_subject_ancestor_of_expected_subject_is_accepted(self) -> None:
        checker = self.checker()
        try:
            ancestor_sha = subprocess.run(
                ["git", "rev-parse", "HEAD^"],
                cwd=REPO_ROOT,
                capture_output=True,
                text=True,
                check=True,
            ).stdout.strip()
            expected_sha = subprocess.run(
                ["git", "rev-parse", "HEAD"],
                cwd=REPO_ROOT,
                capture_output=True,
                text=True,
                check=True,
            ).stdout.strip()
        except Exception as error:
            self.skipTest(f"git ancestry unavailable: {error}")
        receipt = self.valid_bf8_receipt(checker, subject_sha=ancestor_sha)
        with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="bf8-ancestor-") as tmp:
            r_path = Path(tmp) / "receipt.json"
            r_path.write_text(json.dumps(receipt), encoding="utf-8")
            evaluation = checker.evaluate_bf8_promotion_receipt(
                receipt=receipt,
                receipt_path=r_path,
                authority_root=REPO_ROOT,
                expected_subject_sha=expected_sha,
            )
            self.assertEqual(evaluation["authorized_matrix_ids"], {4})
            self.assertEqual(evaluation["receipt_id"], receipt["receiptID"])

    def test_scoped_bf8_promotion_receipt_matrix_4_only(self) -> None:
        checker = self.checker()
        receipt = self.valid_bf8_receipt(checker, matrix_ids=[4])
        with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="bf8-scoped-") as tmp:
            r_path = Path(tmp) / "receipt.json"
            r_path.write_text(json.dumps(receipt), encoding="utf-8")
            matrix = checker.materialize_matrix(
                manifest_path=MANIFEST,
                t0_design_path=T0_DESIGN,
                semantic_contract_path=SEMANTIC_CONTRACT,
                state_cells_path=STATE_CELLS,
                mounted_catalog_path=MOUNTED_CATALOG,
                bf8_promotion_receipt=receipt,
                bf8_promotion_receipt_path=r_path,
            )
            cells_by_id = {c["matrix_id"]: c for c in matrix["cells"]}
            cell4_bf8 = cells_by_id[4]["actionDemoProven_basis"]["bf8_promotion"]
            cell5_bf8 = cells_by_id[5]["actionDemoProven_basis"]["bf8_promotion"]
            cell6_bf8 = cells_by_id[6]["actionDemoProven_basis"]["bf8_promotion"]

            self.assertTrue(cell4_bf8["observed"])
            self.assertEqual(cell4_bf8["status"], "authorized")
            self.assertFalse(cell5_bf8["observed"])
            self.assertEqual(cell5_bf8["status"], "pending_human_bf8")
            self.assertFalse(cell6_bf8["observed"])
            self.assertEqual(cell6_bf8["status"], "pending_human_bf8")

    def test_bf8_alone_without_action_probe_keeps_action_demo_proven_false(self) -> None:
        checker = self.checker()
        receipt = self.valid_bf8_receipt(checker, matrix_ids=[4])
        with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="bf8-alone-") as tmp:
            r_path = Path(tmp) / "receipt.json"
            r_path.write_text(json.dumps(receipt), encoding="utf-8")
            matrix = checker.materialize_matrix(
                manifest_path=MANIFEST,
                t0_design_path=T0_DESIGN,
                semantic_contract_path=SEMANTIC_CONTRACT,
                state_cells_path=STATE_CELLS,
                mounted_catalog_path=MOUNTED_CATALOG,
                bf8_promotion_receipt=receipt,
                bf8_promotion_receipt_path=r_path,
            )
            self.assertEqual(sum(c["actionDemoProven"] for c in matrix["cells"]), 0)

    def test_probe_green_and_bf8_receipt_promotes_cell_4_in_temp_materialize(self) -> None:
        checker = self.checker()
        probe_receipt = self.valid_scoped_action_receipt(checker, matrix_ids=[4])
        bf8_receipt = self.valid_bf8_receipt(checker, matrix_ids=[4])
        with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="bf8-probe-") as tmp:
            tmp_path = Path(tmp)
            p_path = tmp_path / "probe_receipt.json"
            b_path = tmp_path / "bf8_receipt.json"
            p_path.write_text(json.dumps(probe_receipt), encoding="utf-8")
            b_path.write_text(json.dumps(bf8_receipt), encoding="utf-8")
            matrix = checker.materialize_matrix(
                manifest_path=MANIFEST,
                t0_design_path=T0_DESIGN,
                semantic_contract_path=SEMANTIC_CONTRACT,
                state_cells_path=STATE_CELLS,
                mounted_catalog_path=MOUNTED_CATALOG,
                action_probe_receipt=probe_receipt,
                action_probe_receipt_path=p_path,
                action_probe_catalog_path=ACTION_PROBE_CATALOG,
                bf8_promotion_receipt=bf8_receipt,
                bf8_promotion_receipt_path=b_path,
            )
            cells_by_id = {c["matrix_id"]: c for c in matrix["cells"]}
            cell4 = cells_by_id[4]
            self.assertTrue(cell4["actionDemoProven_basis"]["readbackProbePass"]["observed"])
            self.assertTrue(cell4["actionDemoProven_basis"]["bf8_promotion"]["observed"])
            self.assertTrue(cell4["actionDemoProven"])
            self.assertEqual(sum(c["actionDemoProven"] for c in matrix["cells"]), 1)

    def test_cli_supports_bf8_receipt_option(self) -> None:
        self.checker()
        bf8_receipt = self.valid_bf8_receipt(self.checker(), matrix_ids=[4])
        with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="a1-bf8-cli-") as tmp:
            tmp_path = Path(tmp)
            bf8_path = tmp_path / "bf8.json"
            matrix_path = tmp_path / "matrix.json"
            receipt_path = tmp_path / "receipt.json"
            bf8_path.write_text(json.dumps(bf8_receipt), encoding="utf-8")
            materialize = subprocess.run(
                [
                    sys.executable,
                    str(CHECKER_PATH),
                    "materialize",
                    "--t0-design",
                    str(T0_DESIGN),
                    "--bf8-receipt",
                    str(bf8_path),
                    "--output",
                    str(matrix_path),
                ],
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertEqual(materialize.returncode, 0, materialize.stderr)
            matrix = load_json(matrix_path)
            cell4 = next(c for c in matrix["cells"] if c["matrix_id"] == 4)
            self.assertTrue(cell4["actionDemoProven_basis"]["bf8_promotion"]["observed"])

            checked = subprocess.run(
                [
                    sys.executable,
                    str(CHECKER_PATH),
                    "check",
                    "--t0-design",
                    str(T0_DESIGN),
                    "--matrix",
                    str(matrix_path),
                    "--bf8-receipt",
                    str(bf8_path),
                    "--receipt",
                    str(receipt_path),
                ],
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertEqual(checked.returncode, 0, checked.stderr)
            report = load_json(receipt_path)
            self.assertEqual(report["status"], "PASS")

    def test_rejection_cell_with_action_demo_proven_true_emits_contradiction_error(self) -> None:
        checker, matrix = self.materialize()
        cells_by_id = {c["matrix_id"]: c for c in matrix["cells"]}
        cells_by_id[5]["actionDemoProven"] = True
        report = self.validate(checker, matrix)
        self.assertEqual(report["status"], "FAIL")
        self.assertIn("E_ACTION_DEMO_PROVEN_DEFAULT_PATH_CONTRADICTION", report["errors"])

    def test_rejection_demo_proven_field_missing_emits_error(self) -> None:
        checker, matrix = self.materialize()
        del matrix["cells"][0]["rejectionDemoProven"]
        report = self.validate(checker, matrix)
        self.assertEqual(report["status"], "FAIL")
        self.assertTrue(
            "E_REJECTION_DEMO_PROVEN_MISSING" in report["errors"]
            or "E_MATRIX_SCHEMA_INVALID" in report["errors"]
        )

    def test_bf8_receipt_rejection_execution_overlap_raises(self) -> None:
        checker = self.checker()
        receipt = self.valid_bf8_receipt(checker, matrix_ids=[4, 5])
        with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="bf8-overlap-") as tmp:
            r_path = Path(tmp) / "receipt.json"
            r_path.write_text(json.dumps(receipt), encoding="utf-8")
            with self.assertRaises(ValueError) as ctx:
                checker.evaluate_bf8_promotion_receipt(
                    receipt=receipt,
                    receipt_path=r_path,
                    authority_root=REPO_ROOT,
                )
            self.assertEqual(str(ctx.exception), "E_BF8_RECEIPT_REJECTION_EXECUTION_OVERLAP")

    def test_execution_bf8_receipt_does_not_promote_rejection_cell(self) -> None:
        checker = self.checker()
        receipt = self.valid_bf8_receipt(checker, matrix_ids=[4])
        with tempfile.TemporaryDirectory(dir=REPO_ROOT / ".build", prefix="bf8-exec-rejection-") as tmp:
            r_path = Path(tmp) / "receipt.json"
            r_path.write_text(json.dumps(receipt), encoding="utf-8")
            matrix = checker.materialize_matrix(
                manifest_path=MANIFEST,
                t0_design_path=T0_DESIGN,
                semantic_contract_path=SEMANTIC_CONTRACT,
                state_cells_path=STATE_CELLS,
                mounted_catalog_path=MOUNTED_CATALOG,
                bf8_promotion_receipt=receipt,
                bf8_promotion_receipt_path=r_path,
            )
            cells_by_id = {c["matrix_id"]: c for c in matrix["cells"]}
            self.assertFalse(cells_by_id[5]["actionDemoProven"])
            self.assertFalse(cells_by_id[5]["rejectionDemoProven"])
            self.assertFalse(cells_by_id[6]["actionDemoProven"])
            self.assertFalse(cells_by_id[6]["rejectionDemoProven"])


if __name__ == "__main__":
    unittest.main(verbosity=2)


#!/usr/bin/env python3
"""Test-first coverage for the A1 DemoCapabilityMatrix materializer/checker."""

from __future__ import annotations

import copy
import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import unittest
from collections import Counter
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
CHECKER_PATH = REPO_ROOT / "Tools" / "checks" / "check_capability_matrix.py"
T0_DESIGN = (
    REPO_ROOT
    / "openspec"
    / "changes"
    / "add-c1-demo-capability-governance"
    / "design.md"
)
MANIFEST = Path(
    os.environ.get(
        "A1_MATRIX_MANIFEST",
        "/Users/wanglei/workspace/MAformac-ma12-wt/a1-matrix/contracts/capability-matrix-v3-manifest.jsonl",
    )
)
SEMANTIC_CONTRACT = REPO_ROOT / "contracts" / "semantic-function-contract.jsonl"
STATE_CELLS = REPO_ROOT / "contracts" / "state-cells.yaml"
MOUNTED_CATALOG = REPO_ROOT / "Core" / "Contracts" / "DDomainMountedToolCatalog.swift"
FIXTURES = REPO_ROOT / "Tools" / "checks" / "fixtures" / "demo_capability_matrix"


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


class CapabilityMatrixCheckerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        for path in (T0_DESIGN, MANIFEST, SEMANTIC_CONTRACT, STATE_CELLS, MOUNTED_CATALOG):
            if not path.exists():
                raise AssertionError(f"required A1 source is missing: {path}")

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

    def validate(self, checker: object, matrix: dict) -> dict:
        return checker.validate_matrix(
            matrix=matrix,
            manifest_path=MANIFEST,
            t0_design_path=T0_DESIGN,
            semantic_contract_path=SEMANTIC_CONTRACT,
            state_cells_path=STATE_CELLS,
            mounted_catalog_path=MOUNTED_CATALOG,
        )

    def mutate_with_fixture(self, fixture_name: str) -> tuple[object, dict]:
        checker, matrix = self.materialize()
        fixture = load_json(FIXTURES / fixture_name)
        cells = matrix["cells"]
        matrix_id = fixture.get("matrix_id")
        target = next((cell for cell in cells if cell["matrix_id"] == matrix_id), None)
        operation = fixture["operation"]

        if operation == "remove_basis":
            assert target is not None
            del target["canDemo_basis"][fixture["basis"]]
        elif operation == "set_primary_class":
            assert target is not None
            target["primary_class"] = fixture["value"]
        elif operation == "duplicate_matrix_id":
            assert target is not None
            duplicate = copy.deepcopy(target)
            duplicate["matrix_id"] = fixture["duplicate_of"]
            cells.append(duplicate)
        elif operation == "set_candemo":
            assert target is not None
            target["canDemo"] = fixture["value"]
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
            "local_runtime_readback",
        }
        for cell in matrix["cells"]:
            self.assertEqual(set(cell["canDemo_basis"]), required_basis)
            self.assertTrue(cell["anchors"])
            for basis in cell["canDemo_basis"].values():
                self.assertIsInstance(basis["observed"], bool)
                self.assertTrue(basis["source_ref"])

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

    def test_candemo_is_logical_and_of_four_same_cell_bases(self) -> None:
        checker, _ = self.materialize()
        all_true = {
            "mounted_or_approved_action": {"observed": True},
            "semantic_contract": {"observed": True},
            "state_readback_cell": {"observed": True},
            "local_runtime_readback": {"observed": True},
        }
        self.assertTrue(checker.compute_can_demo(all_true))
        for key in all_true:
            trial = copy.deepcopy(all_true)
            trial[key]["observed"] = False
            self.assertFalse(checker.compute_can_demo(trial), key)

    def test_live_matrix_has_three_derived_demo_cells(self) -> None:
        checker, matrix = self.materialize()
        report = self.validate(checker, matrix)
        self.assertEqual(report["canDemo_count"], 3)
        self.assertEqual(report["status"], "CONFLICT_REQUIRES_COMMANDER_DECISION")

    def test_missing_basis_is_rejected(self) -> None:
        checker, matrix = self.mutate_with_fixture("missing-basis.json")
        self.assertIn("E_BASIS_UNTRACEABLE", self.validate(checker, matrix)["errors"])

    def test_unknown_t0_enum_is_rejected(self) -> None:
        checker, matrix = self.mutate_with_fixture("unknown-enum.json")
        self.assertIn("E_T0_ENUM_UNKNOWN", self.validate(checker, matrix)["errors"])

    def test_duplicate_matrix_id_is_rejected(self) -> None:
        checker, matrix = self.mutate_with_fixture("duplicate-id.json")
        self.assertIn("E_DUPLICATE_MATRIX_ID", self.validate(checker, matrix)["errors"])

    def test_fastpath_only_candemo_green_is_rejected(self) -> None:
        checker, matrix = self.mutate_with_fixture("fastpath-only-candemo.json")
        self.assertIn("E_CAN_DEMO_MANUAL_OVERRIDE", self.validate(checker, matrix)["errors"])

    def test_free_string_reason_kind_is_rejected(self) -> None:
        checker, matrix = self.mutate_with_fixture("free-string-reason.json")
        self.assertIn("E_T0_REASON_KIND_FREE_STRING", self.validate(checker, matrix)["errors"])

    def test_dropped_no_representative_row_is_rejected(self) -> None:
        checker, matrix = self.mutate_with_fixture("dropped-no-representative.json")
        self.assertIn("E_NO_REPRESENTATIVE_DROPPED", self.validate(checker, matrix)["errors"])

    def test_cli_writes_a_conflict_receipt_for_live_manifest(self) -> None:
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
                    "--manifest",
                    str(MANIFEST),
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
                    "--manifest",
                    str(MANIFEST),
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
            # Now it's expected to return 1 with CONFLICT status
            self.assertEqual(checked.returncode, 1, checked.stderr)
            self.assertEqual(load_json(receipt)["status"], "CONFLICT_REQUIRES_COMMANDER_DECISION")


if __name__ == "__main__":
    unittest.main(verbosity=2)

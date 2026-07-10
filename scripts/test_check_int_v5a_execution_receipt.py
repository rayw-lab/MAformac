#!/usr/bin/env python3

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
CHECKER = REPO_ROOT / "Tools/checks/check_int_v5a_execution_receipt.py"


def load_checker():
    spec = importlib.util.spec_from_file_location("receipt_checker", CHECKER)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class IntV5AExecutionReceiptTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.checker = load_checker()

    def valid_receipt(self, phase: str) -> dict:
        bundle_available = phase in {"bundle", "final"}
        receipt = {
            "schema_version": "int_v5a_execution_receipt_v1",
            "phase": phase,
            "implementation_base_sha": "a" * 40,
            "head_sha": "b" * 40,
            "touched_paths": [],
            "reviewed_no_change_paths": sorted(self.checker.EXPECTED_REVIEWED_NO_CHANGE),
            "commands": [{"command": "true", "rc": 0, "result": "PASS"}],
            "runtime_bundle": {
                "status": "available" if bundle_available else "not_yet_available",
                "runtime_contract_bundle_digest": "c" * 64 if bundle_available else None,
            },
            "proof_class": "local",
        }
        if phase == "rename":
            receipt["must_change_paths"] = sorted(self.checker.EXPECTED_RENAME_MUST_CHANGE)
        return receipt

    def validate(self, receipt: dict, phase: str) -> dict:
        return self.checker.validate_execution_receipt(receipt, phase, REPO_ROOT)

    def test_rename_receipt_missing_must_change_path_fails(self) -> None:
        receipt = self.valid_receipt("rename")
        receipt["must_change_paths"].pop()
        self.assertIn("E_INT_V5A_MUST_CHANGE_SET", self.validate(receipt, "rename")["errors"])

    def test_rename_receipt_missing_structural_consumer_fails(self) -> None:
        receipt = self.valid_receipt("rename")
        receipt["reviewed_no_change_paths"] = []
        self.assertIn("E_INT_V5A_REVIEW_SET", self.validate(receipt, "rename")["errors"])

    def test_pre_bundle_digest_must_be_null(self) -> None:
        receipt = self.valid_receipt("preflight")
        receipt["runtime_bundle"] = {"status": "available", "runtime_contract_bundle_digest": "a" * 64}
        self.assertIn("E_INT_V5A_PHASE_DIGEST_STATE", self.validate(receipt, "preflight")["errors"])

    def test_bundle_phase_requires_digest(self) -> None:
        receipt = self.valid_receipt("bundle")
        receipt["runtime_bundle"] = {"status": "not_yet_available", "runtime_contract_bundle_digest": None}
        self.assertIn("E_INT_V5A_PHASE_DIGEST_STATE", self.validate(receipt, "bundle")["errors"])

    def test_unknown_phase_field_fails_schema(self) -> None:
        receipt = self.valid_receipt("rename")
        receipt["inventedPass"] = True
        self.assertIn("E_INT_V5A_RECEIPT_SCHEMA", self.validate(receipt, "rename")["errors"])

    def test_valid_receipts_pass_all_phases(self) -> None:
        for phase in ("preflight", "rename", "bundle", "final"):
            with self.subTest(phase=phase):
                self.assertEqual(self.validate(self.valid_receipt(phase), phase)["status"], "PASS")


if __name__ == "__main__":
    unittest.main()

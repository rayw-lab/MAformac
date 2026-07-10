from __future__ import annotations

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
CHECKER = REPO_ROOT / "Tools/checks/check_frontstage_route_receipt.py"


def load_checker():
    spec = importlib.util.spec_from_file_location("frontstage_receipt_checker", CHECKER)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class FrontstageRouteReceiptCheckerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.checker = load_checker()

    def valid_receipt(self):
        return {
            "schema_version": "frontstage_route_receipt.v1",
            "run_id": "run-1",
            "run_nonce": "0123456789abcdef0123456789abcdef",
            "source_head_sha": "a" * 40,
            "session_id": "session-1",
            "turn_id": "turn-1",
            "event_id": "event-1",
            "sequence": 1,
            "matrix_id": None,
            "runtime_contract_bundle_digest": "b" * 64,
            "app_executable_sha256": "c" * 64,
            "proof_class": "frontstage_route_local_integration",
            "result": "refusal_no_available_tool",
            "state_mutation": False,
            "readback_count": 0,
        }

    def test_valid_deny_receipt_passes(self):
        self.assertEqual(self.checker.validate(self.valid_receipt())["status"], "PASS")

    def test_mutation_or_readback_on_deny_fails(self):
        receipt = self.valid_receipt()
        receipt["state_mutation"] = True
        receipt["readback_count"] = 1
        report = self.checker.validate(receipt)
        self.assertIn("E_DENY_MUTATION", report["errors"])
        self.assertIn("E_DENY_READBACK", report["errors"])

    def test_unknown_field_and_invalid_nonce_fail_closed(self):
        receipt = self.valid_receipt()
        receipt["run_nonce"] = "UPPERCASE"
        receipt["invented_pass"] = True
        report = self.checker.validate(receipt)
        self.assertIn("E_SCHEMA", report["errors"])
        self.assertIn("E_RUN_NONCE", report["errors"])


if __name__ == "__main__":
    unittest.main()

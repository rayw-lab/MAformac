from __future__ import annotations

import importlib.util
import json
import hashlib
import subprocess
import sys
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
            "tested_checkout_sha": "a" * 40,
            "session_id": "session-1",
            "turn_id": "turn-1",
            "event_id": "event-1",
            "sequence": 1,
            "matrix_id": None,
            "matrix_source_sha256": "b" * 64,
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

    def test_schema_requires_checkout_and_matrix_digest_subjects(self):
        receipt = self.valid_receipt()
        receipt.pop("tested_checkout_sha")
        receipt.pop("matrix_source_sha256")
        report = self.checker.validate(receipt)
        self.assertIn("E_SCHEMA", report["errors"])

    def test_checker_rejects_checkout_or_matrix_digest_mismatch(self):
        with tempfile.TemporaryDirectory(prefix="frontstage-checker-") as temp:
            root = Path(temp)
            matrix = root / "matrix.json"
            matrix.write_text('{"matrix":"canonical"}\n', encoding="utf-8")
            manifest = root / "bundle.json"
            manifest.write_text('{"runtime_contract_bundle_digest":"' + "b" * 64 + '"}\n', encoding="utf-8")
            executable = root / "MAformacMac"
            executable.write_bytes(b"release-app")
            receipt_path = root / "receipt.json"
            receipt = self.valid_receipt()
            receipt.update(
                {
                    "tested_checkout_sha": "b" * 40,
                    "matrix_source_sha256": "c" * 64,
                    "app_executable_sha256": hashlib.sha256(executable.read_bytes()).hexdigest(),
                }
            )
            receipt_path.write_text(json.dumps(receipt), encoding="utf-8")
            result = subprocess.run(
                [
                    sys.executable,
                    str(CHECKER),
                    "--receipt", str(receipt_path),
                    "--schema", str(REPO_ROOT / "contracts/schemas/frontstage-route-receipt.schema.json"),
                    "--matrix", str(matrix),
                    "--runtime-bundle-manifest", str(manifest),
                    "--app-executable", str(executable),
                    "--expected-head", "a" * 40,
                    "--expected-run-id", "run-1",
                    "--expected-run-nonce", "0123456789abcdef0123456789abcdef",
                ],
                capture_output=True,
                text=True,
                check=False,
            )
            report = json.loads(result.stdout)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("E_TESTED_CHECKOUT", report["errors"])
            self.assertIn("E_MATRIX_DIGEST", report["errors"])


if __name__ == "__main__":
    unittest.main()

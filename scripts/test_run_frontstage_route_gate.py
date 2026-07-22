from __future__ import annotations

import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
RUNNER = REPO_ROOT / "scripts/run_frontstage_route_gate.sh"


class FrontstageRouteRunnerTests(unittest.TestCase):
    def test_external_writer_accepts_run_identity_and_output_dir(self):
        with tempfile.TemporaryDirectory(prefix="frontstage-route-gate-") as temp:
            run_root = Path(temp) / "owner"
            env = os.environ | {
                "PYTHON_BIN": str(REPO_ROOT / ".venv/bin/python"),
                "C1_FRONTSTAGE_RECEIPT_EMIT": "1",
                "C1_FRONTSTAGE_RUN_ID": "frontstage-run-1",
                "C1_FRONTSTAGE_RUN_NONCE": "0123456789abcdef0123456789abcdef",
                "C1_RUN_DIR": str(run_root),
                "C1_FRONTSTAGE_SOURCE_HEAD_SHA": subprocess.check_output(
                    ["git", "rev-parse", "HEAD"], cwd=REPO_ROOT, text=True
                ).strip(),
            }
            result = subprocess.run(
                ["bash", str(RUNNER)], cwd=REPO_ROOT, env=env, capture_output=True, text=True
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            receipt = run_root / "receipts/c1/frontstage-route-receipt.v2.json"
            body = json.loads(receipt.read_text(encoding="utf-8"))
            self.assertEqual(body["run_id"], "frontstage-run-1")
            self.assertEqual(body["run_nonce"], "0123456789abcdef0123456789abcdef")
            self.assertEqual(body["sequence"], 1)

    def test_foreign_mode_never_supplies_a_missing_key(self):
        with tempfile.TemporaryDirectory(prefix="frontstage-route-gate-") as temp:
            env = os.environ | {
                "PYTHON_BIN": str(REPO_ROOT / ".venv/bin/python"),
                "C1_FRONTSTAGE_RECEIPT_EMIT": "1",
                "C1_FRONTSTAGE_RUN_ID": "frontstage-run-missing-nonce",
                "C1_RUN_DIR": str(Path(temp) / "owner"),
                "C1_FRONTSTAGE_SOURCE_HEAD_SHA": "a" * 40,
            }
            env.pop("C1_FRONTSTAGE_RUN_NONCE", None)
            result = subprocess.run(
                ["bash", str(RUNNER)], cwd=REPO_ROOT, env=env, capture_output=True, text=True
            )
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertFalse((Path(temp) / "owner/receipts/c1/frontstage-route-receipt.v2.json").exists())

    def test_each_foreign_abi_key_rejects_its_invalid_value_without_fallback_receipt(self):
        source_head = subprocess.check_output(
            ["git", "rev-parse", "HEAD"], cwd=REPO_ROOT, text=True
        ).strip()
        invalid_values = {
            "C1_FRONTSTAGE_RECEIPT_EMIT": "false",
            "C1_FRONTSTAGE_RUN_ID": " ",
            "C1_FRONTSTAGE_RUN_NONCE": "A" * 32,
            "C1_RUN_DIR": "relative-run-dir",
            "C1_FRONTSTAGE_SOURCE_HEAD_SHA": "A" * 40,
        }
        with tempfile.TemporaryDirectory(prefix="frontstage-route-gate-") as temp:
            for key, invalid_value in invalid_values.items():
                with self.subTest(key=key):
                    run_root = Path(temp) / key.lower()
                    env = os.environ | {
                        "PYTHON_BIN": str(REPO_ROOT / ".venv/bin/python"),
                        "C1_FRONTSTAGE_RECEIPT_EMIT": "1",
                        "C1_FRONTSTAGE_RUN_ID": "frontstage-run-invalid-key",
                        "C1_FRONTSTAGE_RUN_NONCE": "0123456789abcdef0123456789abcdef",
                        "C1_RUN_DIR": str(run_root),
                        "C1_FRONTSTAGE_SOURCE_HEAD_SHA": source_head,
                        key: invalid_value,
                    }
                    result = subprocess.run(
                        ["bash", str(RUNNER)], cwd=REPO_ROOT, env=env, capture_output=True, text=True
                    )
                    self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
                    self.assertFalse(
                        (run_root / "receipts/c1/frontstage-route-receipt.v2.json").exists(),
                        f"{key} produced a receipt despite its invalid value",
                    )
                    self.assertFalse(
                        (REPO_ROOT / ".build/c1-run/frontstage-run-invalid-key").exists(),
                        f"{key} fell back to the local default receipt directory",
                    )


if __name__ == "__main__":
    unittest.main()

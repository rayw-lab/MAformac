from __future__ import annotations

import os
import subprocess
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
CONFIGURATION_SOURCE = REPO_ROOT / "MAformacIOSUITests/FrontstageRouteUITestRunConfiguration.swift"
UI_TEST_SOURCE = REPO_ROOT / "MAformacIOSUITests/FrontstageRouteUITests.swift"
PROBE_SOURCE = REPO_ROOT / "scripts/frontstage_route_ui_harness_probe.swift"
OPERATOR_GUIDE = REPO_ROOT / "docs/grill-checklist/v5b-abi-proof-operator-guide.md"
ABI_KEYS = (
    "C1_FRONTSTAGE_RECEIPT_EMIT",
    "C1_FRONTSTAGE_RUN_ID",
    "C1_FRONTSTAGE_RUN_NONCE",
    "C1_RUN_DIR",
    "C1_FRONTSTAGE_SOURCE_HEAD_SHA",
)


class FrontstageUIHarnessTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls._temporary_directory = tempfile.TemporaryDirectory(prefix="frontstage-ui-harness-")
        cls.probe = Path(cls._temporary_directory.name) / "frontstage-ui-harness-probe"
        result = subprocess.run(
            [
                "xcrun",
                "swiftc",
                str(CONFIGURATION_SOURCE),
                str(PROBE_SOURCE),
                "-o",
                str(cls.probe),
            ],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            raise AssertionError(result.stdout + result.stderr)

    @classmethod
    def tearDownClass(cls) -> None:
        cls._temporary_directory.cleanup()

    def formal_environment(self) -> dict[str, str]:
        environment = {key: value for key, value in os.environ.items() if key not in ABI_KEYS}
        environment.update(
            {
                "C1_FRONTSTAGE_RECEIPT_EMIT": "1",
                "C1_FRONTSTAGE_RUN_ID": "c1-v5b-harness-test",
                "C1_FRONTSTAGE_RUN_NONCE": "0123456789abcdef0123456789abcdef",
                "C1_RUN_DIR": str(Path(self._temporary_directory.name) / "owner"),
                "C1_FRONTSTAGE_SOURCE_HEAD_SHA": "a" * 40,
            }
        )
        return environment

    def run_probe(self, environment: dict[str, str]) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [str(self.probe)],
            cwd=REPO_ROOT,
            env=environment,
            capture_output=True,
            text=True,
            timeout=3,
        )

    def test_valid_formal_environment_resolves_before_launch(self) -> None:
        result = self.run_probe(self.formal_environment())
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("FRONTSTAGE_UI_HARNESS_CONFIG_OK", result.stdout)

    def test_each_missing_formal_key_fails_with_named_error(self) -> None:
        for key in ABI_KEYS:
            with self.subTest(key=key):
                environment = self.formal_environment()
                environment.pop(key)
                result = self.run_probe(environment)
                self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertIn(f"FRONTSTAGE_UI_HARNESS_MISSING_KEY:{key}", result.stderr)
                self.assertNotIn("waitForReceipt", result.stdout + result.stderr)

    def test_empty_source_head_fails_with_named_error(self) -> None:
        environment = self.formal_environment()
        environment["C1_FRONTSTAGE_SOURCE_HEAD_SHA"] = ""
        result = self.run_probe(environment)
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn(
            "FRONTSTAGE_UI_HARNESS_INVALID_KEY:C1_FRONTSTAGE_SOURCE_HEAD_SHA",
            result.stderr,
        )
        self.assertNotIn("waitForReceipt", result.stdout + result.stderr)

    def test_operator_guide_uses_xcode_test_runner_environment_bridge(self) -> None:
        source = OPERATOR_GUIDE.read_text(encoding="utf-8")
        for key in ABI_KEYS:
            self.assertIn(f"TEST_RUNNER_{key}", source)
        self.assertIn("TEST_RUNNER_<VAR>", source)
        self.assertIn("prefix stripped", source)
        self.assertIn("Tools/checks/finalize_frontstage_route_ui_abi.py", source)
        self.assertIn("xcresult attachment", source)

    def test_ui_runner_preserves_receipts_as_xcresult_attachments_without_owner_writes(self) -> None:
        source = UI_TEST_SOURCE.read_text(encoding="utf-8")
        self.assertIn("XCTAttachment(data:", source)
        self.assertIn("attachment.lifetime = .keepAlways", source)
        self.assertIn("preserveReceipt(from: receiptURL, sequence: 1)", source)
        self.assertIn("preserveReceipt(from: receiptURL, sequence: 2)", source)
        self.assertNotIn("createDirectory(at: copiesDirectory", source)
        self.assertNotIn("copyReceipt(from:", source)
        self.assertNotIn("Process()", source)
        self.assertNotIn(".venv/bin/python", source)


if __name__ == "__main__":
    unittest.main()

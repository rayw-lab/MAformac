#!/usr/bin/env python3
"""Regression tests for the fail-closed exact Swift XCTest runner."""

from __future__ import annotations

import subprocess
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
RUNNER = REPO_ROOT / "Tools/checks/run_swift_test_exact.py"


class ExactSwiftTestRunnerTests(unittest.TestCase):
    def run_fixture(
        self,
        stdout: str,
        returncode: int = 0,
        extra_args: list[str] | None = None,
    ) -> subprocess.CompletedProcess[str]:
        with tempfile.TemporaryDirectory(prefix="swift-exact-runner-") as tmp:
            fake_swift = Path(tmp) / "fake-swift"
            fake_swift.write_text(
                "#!/bin/sh\n"
                f"printf '%s\\n' '{stdout}'\n"
                f"exit {returncode}\n",
                encoding="utf-8",
            )
            fake_swift.chmod(0o755)
            return subprocess.run(
                [
                    "python3",
                    str(RUNNER),
                    "--swift-bin",
                    str(fake_swift),
                    "--filter",
                    "RuntimeFiniteReasonAuthorityTests/testExactGate",
                    *(extra_args or []),
                ],
                cwd=REPO_ROOT,
                capture_output=True,
                text=True,
                check=False,
            )

    def test_exactly_one_xctest_passes(self) -> None:
        result = self.run_fixture("Executed 1 test, with 0 failures (0 unexpected)")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_zero_tests_fails_even_when_swift_returns_zero(self) -> None:
        result = self.run_fixture("No matching test cases\nExecuted 0 tests, with 0 failures")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_SWIFT_EXACT_TEST_ZERO", result.stderr)

    def test_more_than_one_test_fails_closed(self) -> None:
        result = self.run_fixture("Executed 2 tests, with 0 failures")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_SWIFT_EXACT_TEST_COUNT", result.stderr)

    def test_swift_failure_is_preserved(self) -> None:
        result = self.run_fixture("compiler failed", returncode=7)
        self.assertEqual(result.returncode, 7)
        self.assertIn("E_SWIFT_EXACT_TEST_COMMAND", result.stderr)

    def test_skipped_test_fails_closed_even_when_swift_returns_zero(self) -> None:
        result = self.run_fixture(
            "Executed 1 test, with 1 test skipped and 0 failures (0 unexpected)"
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_SWIFT_EXACT_TEST_SKIPPED", result.stderr)

    def test_min_count_mode_accepts_full_suite(self) -> None:
        result = self.run_fixture(
            "Executed 7 tests, with 0 failures (0 unexpected)",
            extra_args=["--min-count", "1"],
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_min_count_mode_fails_closed_on_zero_tests(self) -> None:
        result = self.run_fixture(
            "No matching test cases\nExecuted 0 tests, with 0 failures",
            extra_args=["--min-count", "1"],
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_SWIFT_EXACT_TEST_ZERO", result.stderr)

    def test_min_count_mode_fails_closed_on_skip(self) -> None:
        result = self.run_fixture(
            "Executed 7 tests, with 1 test skipped and 0 failures",
            extra_args=["--min-count", "1"],
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_SWIFT_EXACT_TEST_SKIPPED", result.stderr)


if __name__ == "__main__":
    unittest.main()

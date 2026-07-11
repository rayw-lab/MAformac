#!/usr/bin/env python3
"""Regression tests for the fail-closed A4 target exclusion checker."""

from __future__ import annotations

import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CHECKER = ROOT / "scripts/check_a4_app_target_exclusions.py"
PROJECT = ROOT / "MAformac.xcodeproj/project.pbxproj"


def run(project: Path = PROJECT) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["python3", str(CHECKER), "--project", str(project), "--core-root", str(ROOT / "Core")],
        text=True,
        capture_output=True,
        check=False,
    )


class A4TargetExclusionCheckerTests(unittest.TestCase):
    def test_current_project_is_exact(self) -> None:
        result = run()
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_deleting_one_exception_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory(prefix="a4-exclusion-negative-") as directory:
            mutated = Path(directory) / "project.pbxproj"
            text = PROJECT.read_text()
            needle = "\t\t\t\tBench/C5DataGate.swift,"
            self.assertEqual(text.count(needle), 2)
            mutated.write_text(text.replace(needle, "", 1))
            result = run(mutated)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("E_A4_UNEXCLUDED target=MAformacMac", result.stderr)

    def test_new_ninth_source_without_exceptions_fails_closed(self) -> None:
        new_source = ROOT / "Core/Bench/A4SyntheticNinth.swift"
        self.assertFalse(new_source.exists())
        try:
            new_source.write_text("// deletion-negative fixture\n")
            result = run()
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("A4SyntheticNinth.swift", result.stderr)
        finally:
            new_source.unlink(missing_ok=True)


if __name__ == "__main__":
    unittest.main()

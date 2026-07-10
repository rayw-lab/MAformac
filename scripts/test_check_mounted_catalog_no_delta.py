#!/usr/bin/env python3
"""Source-free regression tests for the CG-080 mounted/rollback guard."""

from __future__ import annotations

import hashlib
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

import yaml


ROOT = Path(__file__).resolve().parents[1]
CHECKER = ROOT / "scripts/check_mounted_catalog_no_delta.py"
BASELINE_TOOL = "adjust_ac_temperature_to_number"


def catalog_sha(names: list[str]) -> str:
    payload = json.dumps(sorted(names), ensure_ascii=False, separators=(",", ":"))
    return hashlib.sha256((payload + "\n").encode("utf-8")).hexdigest()


class MountedCatalogRollbackGuardTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tempdir = tempfile.TemporaryDirectory()
        self.root = Path(self.tempdir.name)
        self.baseline_path = self.root / "baseline.yaml"
        self.swift_path = self.root / "DDomainMountedToolCatalog.swift"
        self.rollback_path = self.root / "rollback.json"

        self._write_baseline([BASELINE_TOOL])
        self._write_swift([BASELINE_TOOL])
        self._write_artifact_pair("catalog", b"fallback catalog\n")
        self._write_artifact_pair("probes", b"fallback probes\n")
        self.rollback_state = {
            "mounted_tool_names_before": [BASELINE_TOOL, "open_window"],
            "mounted_tool_names_after": [BASELINE_TOOL],
            "affected_cells": [
                {
                    "cell_id": "window.position",
                    "before_canDemo": True,
                    "after_canDemo": False,
                },
            ],
            "fallback_artifacts": {
                "catalog": {
                    "before": "catalog-before.json",
                    "after": "catalog-after.json",
                },
                "probes": {
                    "before": "probes-before.json",
                    "after": "probes-after.json",
                },
            },
        }

    def tearDown(self) -> None:
        self.tempdir.cleanup()

    def _write_baseline(self, names: list[str]) -> None:
        payload = {
            "baseline": {
                "mounted_tool_names": names,
                "catalog_sha": catalog_sha(names),
            },
            "rollback_guard": {
                "affected_can_demo_after_rollback": False,
                "preserve_artifacts": ["fallback_catalog", "fallback_probes"],
            },
        }
        self.baseline_path.write_text(
            yaml.safe_dump(payload, allow_unicode=True, sort_keys=False),
            encoding="utf-8",
        )

    def _write_swift(self, names: list[str]) -> None:
        entries = "\n".join(f'        "{name}",' for name in names)
        self.swift_path.write_text(
            "public enum DDomainMountedToolCatalog {\n"
            "    public static let mountedToolNames: Set<String> = [\n"
            f"{entries}\n"
            "    ]\n"
            "}\n",
            encoding="utf-8",
        )

    def _write_artifact_pair(self, stem: str, content: bytes) -> None:
        (self.root / f"{stem}-before.json").write_bytes(content)
        (self.root / f"{stem}-after.json").write_bytes(content)

    def _run(self, *, with_rollback: bool = True) -> subprocess.CompletedProcess[str]:
        self.rollback_path.write_text(
            json.dumps(self.rollback_state, ensure_ascii=False),
            encoding="utf-8",
        )
        command = [
            sys.executable,
            str(CHECKER),
            "--baseline-path",
            str(self.baseline_path),
            "--swift-path",
            str(self.swift_path),
        ]
        if with_rollback:
            command.extend(["--rollback-state", str(self.rollback_path)])
        return subprocess.run(
            command,
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

    def assert_guard_failure(self, expected_code: str) -> None:
        result = self._run()
        self.assertEqual(result.returncode, 66, result.stdout + result.stderr)
        self.assertIn(expected_code, result.stdout + result.stderr)

    def test_rollback_fails_when_mounted_set_is_not_restored(self) -> None:
        self.rollback_state["mounted_tool_names_after"] = [BASELINE_TOOL, "open_window"]
        self.assert_guard_failure("rollback_mounted_not_restored")

    def test_rollback_fails_when_affected_can_demo_is_not_downgraded(self) -> None:
        self.rollback_state["affected_cells"][0]["after_canDemo"] = True
        self.assert_guard_failure("rollback_can_demo_not_downgraded")

    def test_rollback_fails_when_fallback_probes_are_deleted(self) -> None:
        (self.root / "probes-after.json").unlink()
        self.assert_guard_failure("rollback_fallback_probes_not_preserved")

    def test_live_catalog_and_valid_rollback_pass(self) -> None:
        result = self._run()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('"rollback_status": "PASS"', result.stdout)

    def test_baseline_yaml_is_the_mounted_set_authority(self) -> None:
        self._write_baseline([BASELINE_TOOL, "open_window"])
        result = self._run(with_rollback=False)
        self.assertEqual(result.returncode, 66, result.stdout + result.stderr)
        self.assertIn('"baseline_mounted_tool_names": [', result.stdout)
        self.assertIn('"open_window"', result.stdout)
        self.assertIn('"removed": [', result.stdout)

    def test_baseline_digest_drift_fails_closed(self) -> None:
        payload = yaml.safe_load(self.baseline_path.read_text(encoding="utf-8"))
        payload["baseline"]["catalog_sha"] = "0" * 64
        self.baseline_path.write_text(
            yaml.safe_dump(payload, allow_unicode=True, sort_keys=False),
            encoding="utf-8",
        )
        result = self._run(with_rollback=False)
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("baseline_catalog_sha_mismatch", result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()

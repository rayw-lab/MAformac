#!/usr/bin/env python3
"""Unit tests for Tools/scripts/demo_progress_gauge.py — always observational."""

from __future__ import annotations

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
GAUGE = REPO_ROOT / "Tools/scripts/demo_progress_gauge.py"


def load_gauge():
    spec = importlib.util.spec_from_file_location("demo_progress_gauge", GAUGE)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class DemoProgressGaugeTests(unittest.TestCase):
    def setUp(self) -> None:
        self.mod = load_gauge()
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)

    def tearDown(self) -> None:
        self.temp.cleanup()

    def _write(self, rel: str, text: str) -> Path:
        path = self.root / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
        return path

    def test_bar_zero_and_full(self) -> None:
        self.assertIn("n/a", self.mod.bar(0, 0))
        self.assertEqual(self.mod.bar(0, 120).count("░"), 20)
        self.assertEqual(self.mod.bar(120, 120).count("█"), 20)

    def test_l1_from_receipt(self) -> None:
        receipt = self._write(
            "receipt.json",
            json.dumps(
                {
                    "actionDemoProven_count": 0,
                    "row_count": 120,
                    "status": "PASS",
                    "primary_class_counts": {"default_executable": 1},
                }
            ),
        )
        out = self.mod.read_action_demo_proven(
            receipt_path=receipt, matrix_path=self.root / "missing.json"
        )
        self.assertEqual(out["num"], 0)
        self.assertEqual(out["den"], 120)
        self.assertTrue(out["source"].startswith("receipt:"))
        self.assertEqual(out["matrix_status"], "PASS")

    def test_l1_matrix_recompute_fallback(self) -> None:
        matrix = {
            "cells": [
                {"actionDemoProven": False},
                {"actionDemoProven": True},
                {"actionDemoProven": False},
            ],
            "summary": {"primary_class_counts": {"default_executable": 1}},
        }
        path = self._write("matrix.json", json.dumps(matrix))
        out = self.mod.read_action_demo_proven(
            receipt_path=self.root / "nope.json", matrix_path=path
        )
        self.assertEqual(out["num"], 1)
        self.assertEqual(out["den"], 3)
        self.assertIn("matrix_file_recompute", out["source"])

    def test_app_layers_runtime_and_operator(self) -> None:
        # evidence file on disk
        shot = self._write("evidence/s1.png", "png")
        head = "a" * 40
        registry = {
            "schema_version": "demo_progress_app_scenarios_v1",
            "scenarios": [
                {
                    "id": "s-rt-only",
                    "count_in_denominator": True,
                    "layers": {
                        "runtime_path_reachable": True,
                        "operator_pass": False,
                    },
                    "evidence": {},
                },
                {
                    "id": "s-op-ok",
                    "count_in_denominator": True,
                    "layers": {
                        "runtime_path_reachable": True,
                        "operator_pass": True,
                    },
                    "evidence": {
                        "operator": "tester",
                        "basis_head": head,
                        "screenshot_paths": [str(shot)],
                    },
                },
                {
                    "id": "s-op-invalid",
                    "count_in_denominator": True,
                    "layers": {
                        "runtime_path_reachable": False,
                        "operator_pass": True,
                    },
                    "evidence": {
                        "operator": "tester",
                        "basis_head": "not-a-hash",
                        "screenshot_paths": [],
                    },
                },
            ],
        }
        reg_path = self._write("reg.yaml", json.dumps(registry))
        out = self.mod.read_app_layers(registry_path=reg_path, repo=self.root)
        self.assertEqual(out["registry_status"], "OK")
        self.assertEqual(out["runtime_path_reachable"]["num"], 2)
        self.assertEqual(out["runtime_path_reachable"]["den"], 3)
        self.assertEqual(out["operator_pass"]["num"], 1)
        self.assertEqual(out["operator_pass"]["den"], 3)
        self.assertTrue(any("s-op-invalid" in x for x in out["invalid"]))

    def test_missing_registry_zero(self) -> None:
        out = self.mod.read_app_layers(
            registry_path=self.root / "absent.yaml", repo=self.root
        )
        self.assertEqual(out["registry_status"], "MISSING")
        self.assertEqual(out["runtime_path_reachable"], {"num": 0, "den": 0})
        self.assertEqual(out["operator_pass"], {"num": 0, "den": 0})

    def test_main_always_rc0_and_three_fields(self) -> None:
        # Point at temp repo with only matrix recompute
        matrix = {
            "cells": [{"actionDemoProven": False} for _ in range(120)],
            "summary": {
                "primary_class_counts": {
                    "default_executable": 1,
                    "conditional_ddomain_executable": 1,
                    "fast_path_no_match_fallback": 82,
                    "unmounted_name_rejected": 36,
                }
            },
        }
        self._write("contracts/demo-capability-matrix.json", json.dumps(matrix))
        self._write(
            "contracts/demo-progress-app-scenarios.yaml",
            json.dumps({"schema_version": "demo_progress_app_scenarios_v1", "scenarios": []}),
        )
        # monkey: run main with --repo
        import io
        from contextlib import redirect_stdout

        buf = io.StringIO()
        with redirect_stdout(buf):
            rc = self.mod.main(
                [
                    "--repo",
                    str(self.root),
                    "--matrix",
                    "contracts/demo-capability-matrix.json",
                    "--app-registry",
                    "contracts/demo-progress-app-scenarios.yaml",
                    "--receipt",
                    ".build/missing-receipt.json",
                ]
            )
        text = buf.getvalue()
        self.assertEqual(rc, 0)
        self.assertIn("[actionDemoProven]", text)
        self.assertIn("[runtime_path_reachable]", text)
        self.assertIn("[operator_pass]", text)
        self.assertIn("0/120", text)
        self.assertIn("no single '可演'", text)
        self.assertIn("USER_GOAL", text)
        # ban single 可演 as sole KPI label line
        self.assertNotRegex(text, r"(?m)^\[可演\]")

    def test_main_swallows_errors_rc0(self) -> None:
        import io
        from contextlib import redirect_stdout

        buf = io.StringIO()
        with redirect_stdout(buf):
            # invalid repo path still must rc0
            rc = self.mod.main(["--repo", str(self.root / "no-such-deep"), "--receipt", "/nope"])
        self.assertEqual(rc, 0)


if __name__ == "__main__":
    unittest.main()

#!/usr/bin/env python3
"""Focused tests for the deterministic action-probe receipt scoper."""
from __future__ import annotations

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
SCOPER_PATH = REPO_ROOT / "scripts" / "knife1_scope_action_probe_receipt.py"


def load_scoper():
    spec = importlib.util.spec_from_file_location("knife1_scope_action_probe_receipt", SCOPER_PATH)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def make_source_receipt(matrix_ids: list[int]) -> dict:
    return {
        "schemaVersion": "runtime_action_readback_receipt_v2",
        "receiptID": "runtime-action-readback-probes",
        "caseCount": len(matrix_ids),
        "cases": [
            {"probeID": f"probe.action.matrix.{matrix_id}.zh-CN", "matrixID": matrix_id}
            for matrix_id in matrix_ids
        ],
    }


class Knife1ScopeActionProbeReceiptTests(unittest.TestCase):
    def setUp(self) -> None:
        self.scoper = load_scoper()
        tmp = tempfile.TemporaryDirectory(prefix="knife1-scope-")
        self.addCleanup(tmp.cleanup)
        self.tmp_path = Path(tmp.name)

    def write_source(self, matrix_ids: list[int]) -> Path:
        source = self.tmp_path / "source.json"
        source.write_text(json.dumps(make_source_receipt(matrix_ids)), encoding="utf-8")
        return source

    def test_scope_1_4_keeps_exactly_one_case_each_in_canonical_order(self) -> None:
        source = self.write_source([6, 4, 1, 5])
        output = self.tmp_path / "scoped.json"
        self.assertEqual(
            self.scoper.main(["--matrix-ids", "1,4", "--source", str(source), "--output", str(output)]),
            0,
        )
        scoped = json.loads(output.read_text(encoding="utf-8"))
        self.assertEqual(scoped["scope"]["matrix_ids"], [1, 4])
        self.assertEqual([case["matrixID"] for case in scoped["cases"]], [1, 4])
        self.assertEqual(scoped["caseCount"], 2)

    def test_legacy_default_scope_is_matrix_4(self) -> None:
        source = self.write_source([1, 4, 5, 6])
        output = self.tmp_path / "scoped-4.json"
        self.assertEqual(self.scoper.main(["--source", str(source), "--output", str(output)]), 0)
        scoped = json.loads(output.read_text(encoding="utf-8"))
        self.assertEqual(scoped["scope"]["matrix_ids"], [4])
        self.assertEqual([case["matrixID"] for case in scoped["cases"]], [4])
        self.assertEqual(scoped["scope"]["knife"], "s10_knife1")

    def test_missing_case_for_requested_scope_fails_closed(self) -> None:
        source = self.write_source([4, 5, 6])
        output = self.tmp_path / "scoped.json"
        self.assertEqual(
            self.scoper.main(["--matrix-ids", "1,4", "--source", str(source), "--output", str(output)]),
            1,
        )
        self.assertFalse(output.exists())

    def test_duplicate_case_for_requested_scope_fails_closed(self) -> None:
        data = make_source_receipt([1, 4])
        data["cases"].append({"probeID": "probe.action.matrix.1.dup.zh-CN", "matrixID": 1})
        data["caseCount"] = len(data["cases"])
        source = self.tmp_path / "source.json"
        source.write_text(json.dumps(data), encoding="utf-8")
        output = self.tmp_path / "scoped.json"
        self.assertEqual(
            self.scoper.main(["--matrix-ids", "1,4", "--source", str(source), "--output", str(output)]),
            1,
        )

    def test_invalid_or_duplicate_matrix_ids_rejected(self) -> None:
        self.assertEqual(self.scoper.main(["--matrix-ids", "1,x"]), 1)
        self.assertEqual(self.scoper.main(["--matrix-ids", "1,1"]), 1)
        self.assertEqual(self.scoper.main(["--matrix-ids", ""]), 1)

    def test_nonpositive_matrix_ids_rejected_locally(self) -> None:
        import contextlib
        import io
        cases = {
            "0": "E_SCOPE_MATRIX_ID_NONPOSITIVE",
            "1,0": "E_SCOPE_MATRIX_ID_NONPOSITIVE",
            "0,4": "E_SCOPE_MATRIX_ID_NONPOSITIVE",
            "-1": "E_SCOPE_MATRIX_ID_INVALID",
        }
        for raw, code in cases.items():
            stderr = io.StringIO()
            with contextlib.redirect_stderr(stderr):
                self.assertEqual(self.scoper.main(["--matrix-ids", raw]), 1)
            self.assertIn(code, stderr.getvalue())


if __name__ == "__main__":
    unittest.main()

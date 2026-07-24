#!/usr/bin/env python3
"""Focused behavioral tests for the BF8 Lane1 receipt-set evaluator."""
from __future__ import annotations

import copy
import hashlib
import importlib.util
import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
CHECKER = ROOT / "Tools" / "checks" / "check_capability_matrix.py"
SET_SCHEMA = ROOT / "contracts/governance/bf8-promotion-receipt-set.v1.schema.json"
RECEIPT_SCHEMA = ROOT / "contracts/governance/bf8-promotion-receipt.schema.json"
CANONICAL_SET = ROOT / "contracts/governance/bf8-promotion-receipt-set.v1.json"
M4 = ROOT / "contracts/governance/bf8-promotion-receipt-matrix-4.json"
M4_SHA = "ab0c7bbda03bd7ab6a12882bd4cbc1b68e321cc234023a66d8094f8967226bc4"


def load_checker():
    spec = importlib.util.spec_from_file_location("bf8_checker", CHECKER)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class ReceiptSetBehaviorTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.mod = load_checker()

    def test_canonical_positive(self):
        result = self.mod.evaluate_receipt_set()
        self.assertEqual(result["authorized_primary_ids"], [4])
        self.assertEqual(result["entries"][0]["receipt_sha256"], M4_SHA)

    def test_registry_sha_differs_from_immutable_m4(self):
        self.assertNotEqual(self.mod.sha256_file(CANONICAL_SET), M4_SHA)
        self.assertEqual(self.mod.sha256_file(M4), M4_SHA)

    def _git(self, root, *args):
        env = {**os.environ, "GIT_AUTHOR_NAME": "test", "GIT_AUTHOR_EMAIL": "test@example.com", "GIT_COMMITTER_NAME": "test", "GIT_COMMITTER_EMAIL": "test@example.com"}
        return subprocess.run(["git", *args], cwd=root, env=env, capture_output=True, text=True, check=True).stdout.strip()

    def _fixture(self, entries=None, *, extra_receipt=None, commit=True):
        td = tempfile.TemporaryDirectory(prefix="bf8-receipt-set-")
        root = Path(td.name)
        self._git(root, "init", "-q")
        self._git(root, "config", "user.name", "test")
        self._git(root, "config", "user.email", "test@example.com")
        receipt = {"schemaVersion": "bf8_promotion_receipt_v1", "receiptID": "r1", "subjectSHA256": "a" * 64, "subjectType": "primary_matrix", "subjectID": "1", "matrix_ids": [1], "ceremony": {"artifactRef": "x", "approver": "tester"}}
        if extra_receipt:
            receipt.update(extra_receipt)
        (root / "receipt.json").write_text(json.dumps(receipt, separators=(",", ":")), encoding="utf-8")
        self._git(root, "add", "receipt.json")
        if commit:
            self._git(root, "commit", "-qm", "receipt")
        if commit:
            if "actionSourceSHA256" not in receipt and "sourceHeadSHA" not in receipt:
                lineage = self._git(root, "rev-parse", "HEAD")
                receipt.update({"actionSourceSHA256": lineage, "testedCheckoutSHA256": lineage})
                (root / "receipt.json").write_text(json.dumps(receipt, separators=(",", ":")), encoding="utf-8")
                self._git(root, "add", "receipt.json")
                self._git(root, "commit", "-qm", "lineage")
        if entries is None:
            entries = [{"order": 1, "receipt_path": "receipt.json", "receipt_id": receipt["receiptID"], "receipt_sha256": hashlib.sha256((root / "receipt.json").read_bytes()).hexdigest(), "subject_type": "primary_matrix", "subject_id": "1"}]
        registry = {"version": "bf8_promotion_receipt_set_v1", "entries": entries}
        set_path = root / "set.json"
        set_path.write_text(json.dumps(registry, indent=2), encoding="utf-8")
        return td, root, set_path, registry

    def _copy_receipt(self, root, name, receipt_id):
        receipt = json.loads((root / "receipt.json").read_text())
        receipt["receiptID"] = receipt_id
        target = root / name
        target.write_text(json.dumps(receipt, separators=(",", ":")), encoding="utf-8")
        self._git(root, "add", name)
        self._git(root, "commit", "-qm", f"copy {name}")
        return target

    def _evaluate(self, set_path, root):
        with patch.object(self.mod, "DEFAULT_RECEIPT_SET", set_path):
            return self.mod.evaluate_receipt_set(receipt_set_path=set_path, schema_path=SET_SCHEMA, authority_root=root)

    def _error(self, set_path, root, code):
        with self.assertRaisesRegex(ValueError, code):
            self._evaluate(set_path, root)

    def test_schema_top_level_additional_property(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        reg["unexpected"] = True; path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_INVALID")
    def test_entry_additional_property(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        reg["entries"][0]["unexpected"] = True; path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_SCHEMA_VALIDATION_FAILED")

    def test_absolute_path_rejected(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        reg["entries"][0]["receipt_path"] = str(root / "receipt.json"); path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_PATH_INVALID")

    def test_parent_path_rejected(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        reg["entries"][0]["receipt_path"] = "../receipt.json"; path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_PATH_INVALID")

    def test_glob_path_rejected(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        reg["entries"][0]["receipt_path"] = "*.json"; path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_PATH_INVALID")

    def test_untracked_path_rejected(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        (root / "other.json").write_text("{}", encoding="utf-8")
        reg["entries"][0]["receipt_path"] = "other.json"; path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_PATH_UNTRACKED")

    def test_digest_mismatch_rejected(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        reg["entries"][0]["receipt_sha256"] = "b" * 64; path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_DIGEST_MISMATCH")

    def test_noncontiguous_order_rejected(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        reg["entries"][0]["order"] = 2; path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_ORDER_INVALID")

    def test_wrong_field_order_rejected(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        e = reg["entries"][0]; reg["entries"][0] = {"receipt_id": e["receipt_id"], **{k: v for k, v in e.items() if k != "receipt_id"}}; path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_ORDER_INVALID")
    def test_duplicate_path_rejected(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        self._copy_receipt(root, "receipt2.json", "r2")
        e = copy.deepcopy(reg["entries"][0]); e["order"] = 2; e["receipt_id"] = "r2"; reg["entries"].append(e); path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_DUPLICATE_PATH")

    def test_duplicate_id_rejected(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        self._copy_receipt(root, "receipt2.json", "r2")
        e = copy.deepcopy(reg["entries"][0]); e["order"] = 2; e["receipt_path"] = "receipt2.json"; reg["entries"].append(e); path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_DUPLICATE_ID")
    def test_primary_numeric_singleton_scope(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        self.assertEqual(self._evaluate(path, root)["authorized_primary_ids"], [1])

    def test_primary_scope_rejection(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        reg["entries"][0]["subject_id"] = "2"; path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_SCOPE_INVALID")

    def test_secondary_fail_closed(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        receipt = json.loads((root / "receipt.json").read_text()); receipt["subjectType"] = "secondary_tool"; receipt["subjectID"] = "tool"; (root / "receipt.json").write_text(json.dumps(receipt, separators=(",", ":")), encoding="utf-8"); self._git(root, "add", "receipt.json"); self._git(root, "commit", "-qm", "secondary")
        reg["entries"][0]["receipt_sha256"] = hashlib.sha256((root / "receipt.json").read_bytes()).hexdigest(); reg["entries"][0]["subject_type"] = "secondary_tool"; reg["entries"][0]["subject_id"] = "tool"; path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_SECONDARY_UNAUTHORIZED")
    def test_legacy_exact_tuple_allows_missing_discriminator(self):
        result = self.mod.evaluate_receipt_set()
        self.assertEqual(result["entries"][0]["subject_id"], "4")

    def test_nonlegacy_missing_discriminator_rejected(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        receipt = json.loads((root / "receipt.json").read_text()); receipt.pop("subjectType"); receipt.pop("subjectID"); (root / "receipt.json").write_text(json.dumps(receipt, separators=(",", ":")), encoding="utf-8"); self._git(root, "add", "receipt.json"); self._git(root, "commit", "-qm", "missing discriminator")
        reg["entries"][0]["receipt_sha256"] = hashlib.sha256((root / "receipt.json").read_bytes()).hexdigest(); path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_SCOPE_INVALID")

    def test_legacy_40hex_wrong_tuple_fails(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        receipt = json.loads((root / "receipt.json").read_text()); receipt["subjectSHA256"] = "c" * 40; (root / "receipt.json").write_text(json.dumps(receipt, separators=(",", ":")), encoding="utf-8"); self._git(root, "add", "receipt.json"); self._git(root, "commit", "-qm", "short sha")
        reg["entries"][0]["receipt_sha256"] = hashlib.sha256((root / "receipt.json").read_bytes()).hexdigest(); path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_BF8_RECEIPT_SCHEMA_VALIDATION_FAILED")
    def test_lineage_action_tested_mismatch(self):
        td, root, path, reg = self._fixture(extra_receipt={"actionSourceSHA256": "a" * 40, "testedCheckoutSHA256": "b" * 40}); self.addCleanup(td.cleanup)
        reg["entries"][0]["receipt_sha256"] = hashlib.sha256((root / "receipt.json").read_bytes()).hexdigest(); path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_LINEAGE_MISMATCH")

    def test_lineage_action_ancestor_and_receipt_ancestor(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        ancestor = self._git(root, "rev-parse", "HEAD"); receipt = json.loads((root / "receipt.json").read_text()); receipt.update({"actionSourceSHA256": ancestor, "testedCheckoutSHA256": ancestor, "receiptSourceSHA256": ancestor}); (root / "receipt.json").write_text(json.dumps(receipt, separators=(",", ":")), encoding="utf-8"); self._git(root, "add", "receipt.json"); self._git(root, "commit", "-qm", "lineage")
        reg["entries"][0]["receipt_sha256"] = hashlib.sha256((root / "receipt.json").read_bytes()).hexdigest(); path.write_text(json.dumps(reg), encoding="utf-8")
        self.assertEqual(self._evaluate(path, root)["authorized_primary_ids"], [1])

    def test_lineage_action_nonancestor_rejected(self):
        td, root, path, reg = self._fixture(extra_receipt={"actionSourceSHA256": "f" * 40, "testedCheckoutSHA256": "f" * 40}); self.addCleanup(td.cleanup)
        reg["entries"][0]["receipt_sha256"] = hashlib.sha256((root / "receipt.json").read_bytes()).hexdigest(); path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_ACTION_NOT_ANCESTOR")

    def test_supersession_valid_preserves_authorization(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        second = json.loads((root / "receipt.json").read_text()); second["receiptID"] = "r2"; (root / "receipt2.json").write_text(json.dumps(second, separators=(",", ":")), encoding="utf-8"); self._git(root, "add", "receipt2.json"); self._git(root, "commit", "-qm", "second")
        e2 = {"order": 2, "receipt_path": "receipt2.json", "receipt_id": "r2", "receipt_sha256": hashlib.sha256((root / "receipt2.json").read_bytes()).hexdigest(), "subject_type": "primary_matrix", "subject_id": "1", "supersedes_receipt_id": "r1"}; reg["entries"].append(e2); path.write_text(json.dumps(reg), encoding="utf-8")
        result = self._evaluate(path, root); self.assertEqual(result["authorized_primary_ids"], [1]); self.assertFalse(result["entries"][0]["active"])

    def test_supersession_later_entry_rejected(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        self._copy_receipt(root, "receipt2.json", "r2")
        reg["entries"][0]["supersedes_receipt_id"] = "r2"
        e2 = copy.deepcopy(reg["entries"][0])
        e2.update({"order": 2, "receipt_path": "receipt2.json", "receipt_id": "r2",
                   "receipt_sha256": hashlib.sha256((root / "receipt2.json").read_bytes()).hexdigest()})
        e2.pop("supersedes_receipt_id")
        reg["entries"].append(e2)
        path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_SUPERSESSION_INVALID")

    def test_multiple_active_same_subject_rejected(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        self._copy_receipt(root, "receipt2.json", "r2")
        e2 = copy.deepcopy(reg["entries"][0])
        e2.update({"order": 2, "receipt_path": "receipt2.json", "receipt_id": "r2",
                   "receipt_sha256": hashlib.sha256((root / "receipt2.json").read_bytes()).hexdigest()})
        reg["entries"].append(e2)
        path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_MULTIPLE_ACTIVE")

    def test_supersession_self_rejected(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        reg["entries"][0]["supersedes_receipt_id"] = "r1"; path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_SUPERSESSION_INVALID")

    def test_supersession_cross_subject_rejected(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        self._copy_receipt(root, "receipt2.json", "r2")
        receipt = json.loads((root / "receipt2.json").read_text()); receipt["subjectID"] = "2"; receipt["matrix_ids"] = [2]; (root / "receipt2.json").write_text(json.dumps(receipt, separators=(",", ":")), encoding="utf-8"); self._git(root, "add", "receipt2.json"); self._git(root, "commit", "-qm", "cross subject")
        e = copy.deepcopy(reg["entries"][0]); e.update({"order": 2, "receipt_path": "receipt2.json", "receipt_id": "r2", "receipt_sha256": hashlib.sha256((root / "receipt2.json").read_bytes()).hexdigest(), "subject_id": "2", "supersedes_receipt_id": "r1"}); reg["entries"].append(e); path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_SUPERSESSION_SUBJECT_MISMATCH")

    def test_supersession_fork_rejected(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        self._copy_receipt(root, "receipt2.json", "r2"); self._copy_receipt(root, "receipt3.json", "r3")
        for order, rid, name in ((2, "r2", "receipt2.json"), (3, "r3", "receipt3.json")):
            e = copy.deepcopy(reg["entries"][0]); e.update({"order": order, "receipt_path": name, "receipt_id": rid, "receipt_sha256": hashlib.sha256((root / name).read_bytes()).hexdigest(), "supersedes_receipt_id": "r1"}); reg["entries"].append(e)
        path.write_text(json.dumps(reg), encoding="utf-8"); self._error(path, root, "E_RECEIPT_SET_SUPERSESSION_FORK")
    def test_lineage_missing_rejected(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        receipt = json.loads((root / "receipt.json").read_text())
        receipt.pop("actionSourceSHA256", None); receipt.pop("testedCheckoutSHA256", None)
        (root / "receipt.json").write_text(json.dumps(receipt, separators=(",", ":")), encoding="utf-8")
        self._git(root, "add", "receipt.json"); self._git(root, "commit", "-qm", "missing lineage")
        reg["entries"][0]["receipt_sha256"] = hashlib.sha256((root / "receipt.json").read_bytes()).hexdigest()
        path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_LINEAGE_MISSING")

    def test_lineage_tested_nonancestor_rejected(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        receipt = json.loads((root / "receipt.json").read_text())
        receipt["testedCheckoutSHA256"] = "f" * 40
        (root / "receipt.json").write_text(json.dumps(receipt, separators=(",", ":")), encoding="utf-8")
        self._git(root, "add", "receipt.json"); self._git(root, "commit", "-qm", "tested nonancestor")
        reg["entries"][0]["receipt_sha256"] = hashlib.sha256((root / "receipt.json").read_bytes()).hexdigest()
        path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_LINEAGE_MISMATCH")

    def test_receipt_source_bad_rejected(self):
        td, root, path, reg = self._fixture(extra_receipt={"receiptSourceSHA256": "z" * 40}); self.addCleanup(td.cleanup)
        reg["entries"][0]["receipt_sha256"] = hashlib.sha256((root / "receipt.json").read_bytes()).hexdigest()
        path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_BF8_RECEIPT_SCHEMA_VALIDATION_FAILED")

    def test_supersession_cycle_rejected(self):
        td, root, path, reg = self._fixture(); self.addCleanup(td.cleanup)
        self._copy_receipt(root, "receipt2.json", "r2")
        reg["entries"][0]["supersedes_receipt_id"] = "r2"
        e2 = copy.deepcopy(reg["entries"][0])
        e2.update({"order": 2, "receipt_path": "receipt2.json", "receipt_id": "r2",
                   "receipt_sha256": hashlib.sha256((root / "receipt2.json").read_bytes()).hexdigest(),
                   "supersedes_receipt_id": "r1"})
        reg["entries"].append(e2); path.write_text(json.dumps(reg), encoding="utf-8")
        self._error(path, root, "E_RECEIPT_SET_SUPERSESSION_INVALID")

if __name__ == "__main__":
    unittest.main()

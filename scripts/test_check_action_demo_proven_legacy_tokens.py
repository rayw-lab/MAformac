#!/usr/bin/env python3

from __future__ import annotations

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
CHECKER = REPO_ROOT / "Tools/checks/check_action_demo_proven_legacy_tokens.py"
ALLOWLIST = REPO_ROOT / "contracts/action-demo-proven-legacy-token-allowlist.json"
LEGACY_TOKEN = "can" + "Demo"


def load_checker():
    spec = importlib.util.spec_from_file_location("legacy_checker", CHECKER)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class ActionDemoProvenLegacyTokenTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.allowlist = self.root / "contracts/allowlist.json"
        payload = json.loads(ALLOWLIST.read_text(encoding="utf-8"))
        for entry in payload["entries"]:
            source = REPO_ROOT / entry["path"]
            self.write(entry["path"], source.read_text(encoding="utf-8"))
        self.write("contracts/allowlist.json", json.dumps(payload))
        self.checker = load_checker()

    def tearDown(self) -> None:
        self.temp.cleanup()

    def write(self, relative: str, text: str) -> None:
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")

    def test_unallowlisted_production_token_fails(self) -> None:
        self.write("Core/Execution/Bad.swift", f"let {LEGACY_TOKEN} = true\n")
        report = self.checker.check_legacy_tokens(self.root, self.allowlist)
        self.assertIn("E_LEGACY_TOKEN_OUTSIDE_ALLOWLIST", report["errors"])

    def test_allowlist_match_budget_exceeded_fails(self) -> None:
        self.write(
            "Tools/checks/fixtures/demo_capability_matrix/legacy-action-key.json",
            json.dumps({LEGACY_TOKEN: False, "second": LEGACY_TOKEN}) + "\n",
        )
        report = self.checker.check_legacy_tokens(self.root, self.allowlist)
        self.assertIn("E_LEGACY_ALLOWLIST_BUDGET_EXCEEDED", report["errors"])

    def test_stale_allowlist_entry_fails(self) -> None:
        self.write("Tools/checks/fixtures/demo_capability_matrix/legacy-action-key.json", '{"actionDemoProven":false}\n')
        report = self.checker.check_legacy_tokens(self.root, self.allowlist)
        self.assertIn("E_LEGACY_ALLOWLIST_STALE", report["errors"])

    def test_only_negative_fixture_and_history_are_allowed(self) -> None:
        report = self.checker.check_legacy_tokens(REPO_ROOT, ALLOWLIST)
        self.assertEqual(report["status"], "PASS", report)


if __name__ == "__main__":
    unittest.main()

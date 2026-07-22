#!/usr/bin/env python3

from __future__ import annotations

import json
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


REPO = Path(__file__).resolve().parents[1]
CHECKER = REPO / "scripts/check_governance_hygiene.py"
FILES = (
    ".codex/config.toml",
    "AGENTS.md",
    "CLAUDE.md",
    "Makefile",
    "MEMORY.md",
    "contracts/governance/public-repo-exceptions.v1.json",
    "docs/CURRENT.md",
    "docs/README.md",
    "docs/handoffs/2026-07-14-governance-foundation.md",
    "docs/handoffs/2026-07-14-v9-fanin-identity-repair.md",
    "docs/handoffs/2026-07-20-stage-acceptance-audit-wbs-frozen.md",
    "docs/handoffs/2026-07-21-phase0-1a-1b-remediation-complete.md",
    "docs/handoffs/2026-07-22-phase1-appendfix-isolation-baseline.md",
    "docs/handoffs/2026-07-22-phase2-grill-freeze-human-review-handoff.md",
    "docs/lessons-learned.md",
    "docs/project/collaboration-and-roles.md",
    "docs/commander-log/decisions.md",
    "docs/roadmap-2026-07-11-v6-closure-baseline.md",
    "openspec/config.yaml",
)


class GovernanceHygieneTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        for relative in FILES:
            source = REPO / relative
            target = self.root / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
        (self.root / ".claude/skills").mkdir(parents=True)
        (self.root / ".codex/skills").mkdir(parents=True, exist_ok=True)

    def tearDown(self) -> None:
        self.temp.cleanup()

    def run_checker(self, *, as_of: str = "2026-07-14") -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["python3", str(CHECKER), "--repo", str(self.root), "--as-of", as_of],
            text=True,
            capture_output=True,
            check=False,
        )

    def replace(self, relative: str, old: str, new: str) -> None:
        path = self.root / relative
        text = path.read_text(encoding="utf-8")
        self.assertIn(old, text)
        path.write_text(text.replace(old, new, 1), encoding="utf-8")

    def test_positive_repository_fixture(self) -> None:
        result = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("governance_hygiene=ok", result.stdout)

    def test_dangerous_codex_defaults_fail_closed(self) -> None:
        self.replace(".codex/config.toml", 'approval_policy = "on-request"', 'approval_policy = "never"')
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_CODEX_APPROVAL_POLICY", result.stderr)

    def test_dynamic_openspec_dispatch_context_fails_closed(self) -> None:
        path = self.root / "openspec/config.yaml"
        path.write_text(path.read_text(encoding="utf-8") + "\n# provider: Grok\n", encoding="utf-8")
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_OPENSPEC_DYNAMIC", result.stderr)

    def test_dynamic_openspec_route_fields_fail_closed(self) -> None:
        path = self.root / "openspec/config.yaml"
        original = path.read_text(encoding="utf-8")
        for injected in (
            "current change: add-s8-runtime",
            "phase: S8",
            "model: Qwen3",
        ):
            with self.subTest(injected=injected):
                path.write_text(original + f"\n# {injected}\n", encoding="utf-8")
                result = self.run_checker()
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("E_OPENSPEC_DYNAMIC", result.stderr)
        path.write_text(original, encoding="utf-8")

    def test_duplicate_frontmatter_key_fails_closed(self) -> None:
        path = self.root / "docs/CURRENT.md"
        text = path.read_text(encoding="utf-8")
        as_of_line = next(line for line in text.splitlines() if line.startswith("as_of:"))
        path.write_text(text.replace(as_of_line, f"{as_of_line}\nas_of: stale", 1), encoding="utf-8")
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_FRONTMATTER_DUPLICATE", result.stderr)

    def test_patch_residue_fails_closed(self) -> None:
        path = self.root / "MEMORY.md"
        path.write_text(path.read_text(encoding="utf-8") + "\n++ b/MEMORY.md\n", encoding="utf-8")
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_PATCH_RESIDUE:MEMORY.md", result.stderr)

    def test_active_exception_expiry_fails_closed(self) -> None:
        result = self.run_checker(as_of="2026-08-03")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_EXCEPTION_EXPIRED_ACTIVE", result.stderr)

    def test_exception_carrier_expansion_fails_closed(self) -> None:
        self.replace(
            "contracts/governance/public-repo-exceptions.v1.json",
            '"referencerepo/reports/**"',
            '"docs/**"',
        )
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_EXCEPTION_CARRIERS", result.stderr)

    def mutate_exception(self, key: str, value: object) -> None:
        path = self.root / "contracts/governance/public-repo-exceptions.v1.json"
        data = json.loads(path.read_text(encoding="utf-8"))
        data["exceptions"][0][key] = value
        path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    def test_exception_subject_expansion_fails_closed(self) -> None:
        self.mutate_exception("allowed_subjects", ["anything_nonempty"])
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_EXCEPTION_SUBJECTS", result.stderr)

    def test_exception_condition_expansion_fails_closed(self) -> None:
        self.mutate_exception("conditions", ["anything_nonempty"])
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_EXCEPTION_CONDITIONS", result.stderr)

    def test_exception_not_yet_active_fails_closed(self) -> None:
        self.mutate_exception("valid_from", "2026-07-15")
        result = self.run_checker(as_of="2026-07-14")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_EXCEPTION_NOT_YET_ACTIVE", result.stderr)

    def test_exception_unknown_status_fails_closed(self) -> None:
        self.mutate_exception("status", "permanent")
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_EXCEPTION_STATUS", result.stderr)

    def test_missing_handoff_chain_fails_closed(self) -> None:
        current = (self.root / "docs/CURRENT.md").read_text(encoding="utf-8")
        latest = next(
            line.split(":", 1)[1].strip()
            for line in current.splitlines()
            if line.startswith("latest_handoff:")
        )
        path = self.root / latest
        text = path.read_text(encoding="utf-8")
        predecessor_line = next(line for line in text.splitlines() if line.startswith("predecessor:"))
        path.write_text(text.replace(f"{predecessor_line}\n", "", 1), encoding="utf-8")
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_HANDOFF_CHAIN:predecessor", result.stderr)

    def test_current_machine_path_fails_closed(self) -> None:
        path = self.root / "docs/CURRENT.md"
        path.write_text(path.read_text(encoding="utf-8") + "\n/Users/example/runtime\n", encoding="utf-8")
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_CURRENT_DYNAMIC:machine_path", result.stderr)

    def test_duplicate_gitnexus_block_fails_closed(self) -> None:
        path = self.root / "CLAUDE.md"
        path.write_text(path.read_text(encoding="utf-8") + "\n<!-- gitnexus:start -->\n<!-- gitnexus:end -->\n", encoding="utf-8")
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_GITNEXUS_MANAGED_BLOCK_COUNT", result.stderr)

    def test_live_config_backup_fails_closed(self) -> None:
        backup = self.root / ".claude/settings.local.json.bak-test"
        backup.write_text("{}\n", encoding="utf-8")
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_LIVE_CONFIG_BACKUP", result.stderr)

    def test_project_openspec_skill_duplicate_fails_closed(self) -> None:
        duplicate = self.root / ".codex/skills/openspec-apply-change/SKILL.md"
        duplicate.parent.mkdir(parents=True)
        duplicate.write_text("duplicate\n", encoding="utf-8")
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_PROJECT_OPENSPEC_SKILL_DUPLICATE", result.stderr)


if __name__ == "__main__":
    unittest.main()

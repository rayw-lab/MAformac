#!/usr/bin/env python3
"""Behavior regressions for the closure-registry reanchor helper."""

from __future__ import annotations

import hashlib
import importlib
import json
import re
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest import mock

import yaml


REPO = Path(__file__).resolve().parents[1]
HELPER_REL = Path("scripts/reanchor_closure_registry.py")
CHECKER_REL = Path("scripts/check_closure_work_packages.py")
REGISTRY_REL = Path("contracts/closure-work-packages.v1.yaml")
ROADMAP_REL = Path("docs/roadmap-2026-07-11-v6-closure-baseline.md")
SCHEMA_REL = Path("contracts/schemas/closure-work-packages.v1.schema.json")
POLICY_REL = Path("contracts/closure-execution-window.v1.yaml")
CANDIDATE_IDENTITY_RELS = (
    Path("closure/candidates/B7/c6-corpus-lineage.envelope.json"),
    Path("contracts/c6-active-authority/authority.v1.candidate.json"),
    Path("closure/candidates/V1/V1.v1.candidate-receipt.json"),
    Path("closure/candidates/V1/V1.v1.ratification-packet.candidate.json"),
)
MARKER_PATTERN = re.compile(
    r"\n<!-- O1:GENERATED:START registry_sha256=[0-9a-f]{64} checker_sha256=[0-9a-f]{64} -->"
    r"\n.*?\n<!-- O1:GENERATED:END -->\n?",
    re.DOTALL,
)


class ReanchorClosureRegistryTests(unittest.TestCase):
    def make_clone(self) -> Path:
        root = Path(tempfile.mkdtemp(prefix="reanchor-helper-test-"))
        self.addCleanup(shutil.rmtree, root, ignore_errors=True)
        clone = root / "repo"
        subprocess.run(
            ["git", "clone", "--quiet", "--no-hardlinks", str(REPO), str(clone)],
            check=True,
        )
        # Keep the clone's committed checker+marker pair intact so the helper's
        # default pre-check is exercised from an actually green baseline.
        for relative in (
            HELPER_REL,
            Path("Tools/C6ActiveAuthority/export_ratification_packet.py"),
        ):
            source = REPO / relative
            if source.exists():
                shutil.copy2(source, clone / relative)
        return clone

    @staticmethod
    def head(clone: Path) -> str:
        return subprocess.run(
            ["git", "rev-parse", "HEAD"],
            cwd=clone,
            text=True,
            capture_output=True,
            check=True,
        ).stdout.strip()

    def run_helper(self, clone: Path, *extra: str) -> subprocess.CompletedProcess[str]:
        check_receipt = clone / ".build" / "closure" / "reanchor-helper-check.v1.json"
        command = [
            sys.executable,
            str(clone / HELPER_REL),
            "--bind-head",
            self.head(clone),
            "--check-head",
            self.head(clone),
            "--registry",
            str(clone / REGISTRY_REL),
            "--roadmap",
            str(clone / ROADMAP_REL),
            "--schema",
            str(clone / SCHEMA_REL),
            "--o6-policy",
            str(clone / POLICY_REL),
            "--check-receipt",
            str(check_receipt),
            *extra,
        ]
        return subprocess.run(command, cwd=clone, text=True, capture_output=True, check=False)

    @staticmethod
    def canonical_paths(clone: Path) -> list[Path]:
        registry = yaml.safe_load((clone / REGISTRY_REL).read_text(encoding="utf-8"))
        paths = [clone / REGISTRY_REL, clone / ROADMAP_REL]
        for package in registry["packages"]:
            if package["execution_state"]["declared"] == "done":
                paths.append(clone / package["exit_receipt"]["artifact"]["path"])
        paths.extend(clone / relative for relative in CANDIDATE_IDENTITY_RELS)
        return paths

    def test_real_run_updates_all_done_envelopes_and_self_checks(self) -> None:
        clone = self.make_clone()
        result = self.run_helper(clone)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        summary = json.loads(result.stdout)
        self.assertEqual(summary["status"], "PASS")
        self.assertEqual(summary["precheck"], "PASS")
        self.assertEqual(summary["postcheck"], "PASS")
        registry = yaml.safe_load((clone / REGISTRY_REL).read_text(encoding="utf-8"))
        done = [p for p in registry["packages"] if p["execution_state"]["declared"] == "done"]
        self.assertGreater(len(done), 1, "fixture must exercise done-set expansion")
        digest_result = subprocess.run(
            [sys.executable, str(clone / CHECKER_REL), "digest", "--registry", str(clone / REGISTRY_REL)],
            cwd=clone,
            text=True,
            capture_output=True,
            check=True,
        )
        digest = digest_result.stdout.strip()
        envelope_paths = []
        for package in done:
            envelope = clone / package["exit_receipt"]["artifact"]["path"]
            envelope_paths.append(str(envelope.relative_to(clone)))
            payload = json.loads(envelope.read_text(encoding="utf-8"))
            self.assertEqual(payload["registry_digest"], digest)
        self.assertEqual(summary["envelope_paths"], envelope_paths)
        self.assertEqual(summary["envelope_count"], len(done))
        self.assertEqual(
            summary["candidate_identity_paths"],
            [str(path) for path in CANDIDATE_IDENTITY_RELS],
        )

        b7 = json.loads((clone / CANDIDATE_IDENTITY_RELS[0]).read_text(encoding="utf-8"))
        authority_path = clone / CANDIDATE_IDENTITY_RELS[1]
        authority = json.loads(authority_path.read_text(encoding="utf-8"))
        receipt = json.loads((clone / CANDIDATE_IDENTITY_RELS[2]).read_text(encoding="utf-8"))
        packet = json.loads((clone / CANDIDATE_IDENTITY_RELS[3]).read_text(encoding="utf-8"))
        registry_sha = hashlib.sha256((clone / REGISTRY_REL).read_bytes()).hexdigest()
        authority_sha = hashlib.sha256(authority_path.read_bytes()).hexdigest()
        registry_member = next(
            member
            for member in authority["source_members"]
            if member["member_id"] == "closure_work_packages_v1"
        )
        packet_member = next(
            member
            for member in packet["source_members_binding"]["members"]
            if member["member_id"] == "closure_work_packages_v1"
        )
        self.assertEqual(b7["registry_digest"], digest)
        self.assertEqual(receipt["registry_digest"], digest)
        self.assertEqual(registry_member["sha256"], registry_sha)
        self.assertEqual(packet_member["sha256"], registry_sha)
        self.assertEqual(receipt["native_receipt"]["sha256"], authority_sha)
        self.assertEqual(receipt["native_receipt_digest"], authority_sha)
        receipt_authority_digest = next(
            item["value"]
            for item in receipt["subject"]
            if item["key"] == "authority_digest"
        )
        self.assertEqual(receipt_authority_digest, authority["digest"]["sha256"])

    def test_both_authority_refresh_flags_update_the_actual_digest(self) -> None:
        for flag in ("--refresh-authority", "--refresh-authority-sha"):
            with self.subTest(flag=flag):
                clone = self.make_clone()
                registry_path = clone / REGISTRY_REL
                registry_before = yaml.safe_load(registry_path.read_text(encoding="utf-8"))
                authority_path = clone / registry_before["authority"]["source_path"]
                authority_path.write_text(
                    authority_path.read_text(encoding="utf-8") + "\n<!-- authority refresh regression -->\n",
                    encoding="utf-8",
                )
                expected_digest = hashlib.sha256(authority_path.read_bytes()).hexdigest()

                result = self.run_helper(
                    clone,
                    flag,
                    "--no-precheck",
                    "--no-postcheck",
                )
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                summary = json.loads(result.stdout)
                registry_after = yaml.safe_load(registry_path.read_text(encoding="utf-8"))
                self.assertEqual(summary["authority_sha256"], expected_digest)
                self.assertEqual(registry_after["authority"]["source_sha256"], expected_digest)

    def test_dry_run_is_byte_identical(self) -> None:
        clone = self.make_clone()
        before = {path: path.read_bytes() for path in self.canonical_paths(clone)}
        result = self.run_helper(clone, "--dry-run")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        summary = json.loads(result.stdout)
        self.assertEqual(summary["status"], "DRY_RUN")
        self.assertEqual(summary["precheck"], "PASS")
        self.assertEqual(summary["postcheck"], "SKIPPED_DRY_RUN")
        self.assertFalse(summary["writes_performed"])
        self.assertEqual(before, {path: path.read_bytes() for path in before})
        self.assertFalse((clone / ".build" / "closure" / "reanchor-helper-check.v1.json").exists())

    def test_missing_done_envelope_fails_before_writes(self) -> None:
        clone = self.make_clone()
        canonical = self.canonical_paths(clone)
        missing = canonical[2]
        missing.unlink()
        before = {path: path.read_bytes() for path in canonical[:2]}
        result = self.run_helper(clone, "--dry-run", "--no-precheck", "--no-postcheck")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_DONE_ENVELOPE_MISSING", result.stderr)
        self.assertEqual(before, {path: path.read_bytes() for path in before})

    def test_unrelated_v1_source_drift_refuses_without_writes(self) -> None:
        clone = self.make_clone()
        before = {path: path.read_bytes() for path in self.canonical_paths(clone)}
        unrelated = clone / "openspec/changes/rebuild-c6-four-layer-bench/proposal.md"
        unrelated.write_text(
            unrelated.read_text(encoding="utf-8") + "\n<!-- unrelated drift -->\n",
            encoding="utf-8",
        )
        result = self.run_helper(clone, "--no-precheck", "--no-postcheck")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unrelated V1 source member is stale", result.stderr)
        self.assertEqual(before, {path: path.read_bytes() for path in before})

    def test_postcheck_receipt_failure_rolls_back_every_identity_path(self) -> None:
        clone = self.make_clone()
        before = {path: path.read_bytes() for path in self.canonical_paths(clone)}
        result = self.run_helper(
            clone,
            "--check-receipt",
            "/dev/null/reanchor-helper-check.v1.json",
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_CHECKER_RECEIPT", result.stderr)
        self.assertEqual(before, {path: path.read_bytes() for path in before})

    def test_mid_replace_failure_rolls_back_all_replaced_paths(self) -> None:
        scripts = str(REPO / "scripts")
        sys.path.insert(0, scripts)
        self.addCleanup(sys.path.remove, scripts)
        helper = importlib.import_module("reanchor_closure_registry")
        root = Path(tempfile.mkdtemp(prefix="reanchor-mid-replace-"))
        self.addCleanup(shutil.rmtree, root, ignore_errors=True)
        paths = [root / "one.json", root / "two.json", root / "three.json"]
        for index, path in enumerate(paths):
            path.write_bytes(f"old-{index}".encode())
        originals = {path: path.read_bytes() for path in paths}
        plan = SimpleNamespace(
            changes={path: f"new-{index}".encode() for index, path in enumerate(paths)},
            original_bytes=originals,
        )
        real_replace = helper.os.replace
        calls = 0

        def fail_second_once(source, destination):
            nonlocal calls
            calls += 1
            if calls == 2:
                raise OSError("injected second replace failure")
            return real_replace(source, destination)

        with mock.patch.object(helper.os, "replace", side_effect=fail_second_once):
            with self.assertRaises(helper.ReanchorError) as raised:
                helper.apply_transaction(plan)
        self.assertEqual(raised.exception.code, "E_TRANSACTION")
        self.assertEqual(originals, {path: path.read_bytes() for path in paths})

    def test_marker_count_must_be_exactly_one_without_partial_writes(self) -> None:
        for mode in ("zero", "two"):
            with self.subTest(mode=mode):
                clone = self.make_clone()
                roadmap = clone / ROADMAP_REL
                text = roadmap.read_text(encoding="utf-8")
                matches = list(MARKER_PATTERN.finditer(text))
                self.assertEqual(len(matches), 1)
                if mode == "zero":
                    mutated = MARKER_PATTERN.sub("\n", text, count=1)
                else:
                    mutated = text.rstrip("\n") + "\n" + matches[0].group(0) + "\n"
                roadmap.write_text(mutated, encoding="utf-8")
                registry_before = (clone / REGISTRY_REL).read_bytes()
                envelope_before = {path: path.read_bytes() for path in self.canonical_paths(clone)[2:]}
                result = self.run_helper(clone, "--dry-run", "--no-precheck", "--no-postcheck")
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("E_MARKER_COUNT", result.stderr)
                self.assertEqual(registry_before, (clone / REGISTRY_REL).read_bytes())
                self.assertEqual(envelope_before, {path: path.read_bytes() for path in envelope_before})

    def test_digest_and_render_oracles_are_imported_from_checker(self) -> None:
        scripts = str(REPO / "scripts")
        sys.path.insert(0, scripts)
        self.addCleanup(sys.path.remove, scripts)
        helper = importlib.import_module("reanchor_closure_registry")
        checker = importlib.import_module("check_closure_work_packages")
        self.assertIs(helper.registry_digest, checker.registry_digest)
        self.assertIs(helper.render_generated_block, checker.render_generated_block)
        self.assertIs(helper.MARKER_RE, checker.MARKER_RE)


if __name__ == "__main__":
    unittest.main(verbosity=2)

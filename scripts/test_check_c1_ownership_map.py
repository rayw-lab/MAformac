#!/usr/bin/env python3
"""Regression tests for the Task-0 C1 ownership/CG contract checker."""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
CHANGE_ID = "add-c1-demo-capability-governance"
CHANGE_RELATIVE = Path("openspec/changes") / CHANGE_ID
RATIFIED_RELATIVE = Path("docs/grill-tournament/c1-capability-grill-ratified-2026-07-10.md")
CHECKER = REPO_ROOT / "Tools/checks/check_c1_ownership_map.py"
RUNTIME_SURFACES = (
    Path("Core/LLM/DDomainToolPlanFailure.swift"),
    Path("Core/Execution/DemoRuntimeSessionRunner.swift"),
    Path("Core/Execution/DemoRuntimePartialPlan.swift"),
    Path("Core/Execution/FallbackContext.swift"),
    Path("Core/Trace/TraceLogger.swift"),
    Path("Core/Presentation/RuntimePresentationReasonAuthority.generated.swift"),
    Path("Tests/MAformacCoreTests/RuntimeNoMutationProbeTests.swift"),
    Path("Tools/checks/check_runtime_no_mutation_receipts.py"),
)


class C1OwnershipMapCheckerTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory(prefix="c1-ownership-map-")
        self.root = Path(self.temp.name)
        self.change = self.root / CHANGE_RELATIVE
        self.ratified = self.root / RATIFIED_RELATIVE
        self.ratified.parent.mkdir(parents=True)
        shutil.copytree(REPO_ROOT / CHANGE_RELATIVE, self.change)
        shutil.copy2(REPO_ROOT / RATIFIED_RELATIVE, self.ratified)
        for relative in RUNTIME_SURFACES:
            destination = self.root / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(REPO_ROOT / relative, destination)

    def tearDown(self) -> None:
        self.temp.cleanup()

    def run_checker(self) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [
                sys.executable,
                str(CHECKER),
                "--change",
                str(self.change),
                "--repo-root",
                str(self.root),
            ],
            check=False,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

    def load_map(self) -> dict:
        return json.loads((self.change / "ownership-map.yaml").read_text(encoding="utf-8"))

    def write_map(self, payload: dict) -> None:
        (self.change / "ownership-map.yaml").write_text(
            json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )

    def assert_failure(self, marker: str) -> None:
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn(marker, result.stdout + result.stderr)

    def test_checker_is_present(self) -> None:
        self.assertTrue(CHECKER.exists(), f"missing checker: {CHECKER}")

    @unittest.skipUnless(CHECKER.exists(), "checker implementation pending")
    def test_current_t0_contract_passes(self) -> None:
        result = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        receipt = json.loads(result.stdout)
        self.assertEqual(receipt["status"], "PASS")
        self.assertEqual(receipt["covered_cg_count"], 38)
        self.assertEqual(receipt["missing_cg"], [])
        self.assertEqual(receipt["duplicate_cg"], [])
        self.assertEqual(receipt["extra_cg"], [])
        self.assertEqual(receipt["duplicate_owners"], [])
        self.assertEqual(receipt["forbidden_parallel_ssot"], [])
        self.assertEqual(receipt["finite_reason_unknown"], [])
        self.assertEqual(receipt["runtime_finite_reason_violations"], [])

    @unittest.skipUnless(CHECKER.exists(), "checker implementation pending")
    def test_runtime_non_t0_literal_fails_ownership_gate(self) -> None:
        runner = self.root / "Core/Execution/DemoRuntimeSessionRunner.swift"
        runner.write_text(
            runner.read_text(encoding="utf-8")
            + '\nprivate let finiteReason = "ownership_non_t0_reason"\n',
            encoding="utf-8",
        )
        self.assert_failure("E_RUNTIME_FINITE_REASON_OUTSIDE_T0")

    @unittest.skipUnless(CHECKER.exists(), "checker implementation pending")
    def test_missing_owner_fails_closed(self) -> None:
        payload = self.load_map()
        payload["ownership_claims"] = [
            claim for claim in payload["ownership_claims"] if claim["concern"] != "probe_policy"
        ]
        self.write_map(payload)
        self.assert_failure("missing_owners")

    @unittest.skipUnless(CHECKER.exists(), "checker implementation pending")
    def test_duplicate_owner_fails_closed(self) -> None:
        payload = self.load_map()
        payload["ownership_claims"].append(
            {"concern": "matrix_eligibility", "owner": "runtime-presentation-bridge"}
        )
        self.write_map(payload)
        self.assert_failure("duplicate_owners")

    @unittest.skipUnless(CHECKER.exists(), "checker implementation pending")
    def test_governance_presentation_overreach_fails_closed(self) -> None:
        spec = self.change / "specs/demo-capability-governance/spec.md"
        spec.write_text(
            spec.read_text(encoding="utf-8")
            + "\n### Requirement: Invalid governance overreach\n"
            + "Demo capability governance SHALL own public payload fields.\n",
            encoding="utf-8",
        )
        self.assert_failure("governance_overreach")

    @unittest.skipUnless(CHECKER.exists(), "checker implementation pending")
    def test_execution_customer_copy_overreach_fails_closed(self) -> None:
        spec = self.change / "specs/tool-execution/spec.md"
        spec.write_text(
            spec.read_text(encoding="utf-8")
            + "\n### Requirement: Invalid execution overreach\n"
            + "Tool execution SHALL own customer-facing copy.\n",
            encoding="utf-8",
        )
        self.assert_failure("execution_customer_copy_overreach")

    @unittest.skipUnless(CHECKER.exists(), "checker implementation pending")
    def test_bridge_matrix_overreach_fails_closed(self) -> None:
        spec = self.change / "specs/runtime-presentation-bridge/spec.md"
        spec.write_text(
            spec.read_text(encoding="utf-8")
            + "\n### Requirement: Invalid bridge overreach\n"
            + "The bridge SHALL own matrix eligibility.\n",
            encoding="utf-8",
        )
        self.assert_failure("bridge_matrix_overreach")

    @unittest.skipUnless(CHECKER.exists(), "checker implementation pending")
    def test_missing_modified_delta_fails_closed(self) -> None:
        spec = self.change / "specs/tool-execution/spec.md"
        spec.write_text(
            spec.read_text(encoding="utf-8").replace("## MODIFIED Requirements", "## ADDED Requirements", 1),
            encoding="utf-8",
        )
        self.assert_failure("missing_modified_deltas")

    @unittest.skipUnless(CHECKER.exists(), "checker implementation pending")
    def test_parallel_presentation_capability_fails_closed(self) -> None:
        forbidden = self.change / "specs/runtime-presentation-payload"
        forbidden.mkdir()
        (forbidden / "spec.md").write_text("## ADDED Requirements\n", encoding="utf-8")
        self.assert_failure("forbidden_parallel_ssot")

    @unittest.skipUnless(CHECKER.exists(), "checker implementation pending")
    def test_exact_cg_set_rejects_missing_duplicate_and_extra(self) -> None:
        payload = self.load_map()
        payload["ratified_cg_ids"] = [
            cg for cg in payload["ratified_cg_ids"] if cg != "CG-004"
        ]
        payload["ratified_cg_ids"].append("CG-002")
        payload["ratified_cg_ids"].append("CG-999")
        self.write_map(payload)
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("missing_cg", result.stdout)
        self.assertIn("duplicate_cg", result.stdout)
        self.assertIn("extra_cg", result.stdout)

    @unittest.skipUnless(CHECKER.exists(), "checker implementation pending")
    def test_legacy_change_id_fails_closed(self) -> None:
        tasks = self.change / "tasks.md"
        tasks.write_text(
            tasks.read_text(encoding="utf-8").replace(
                CHANGE_ID, "define-c1-demo-capability-and-fallback-contract", 1
            ),
            encoding="utf-8",
        )
        self.assert_failure("change_id_mismatches")

    @unittest.skipUnless(CHECKER.exists(), "checker implementation pending")
    def test_missing_cg024_semantic_marker_fails_closed(self) -> None:
        spec = self.change / "specs/demo-capability-governance/spec.md"
        spec.write_text(spec.read_text(encoding="utf-8").replace("typed_gap", "typed-gap-removed"), encoding="utf-8")
        self.assert_failure("semantic_gaps")

    @unittest.skipUnless(CHECKER.exists(), "checker implementation pending")
    def test_registry_projection_rejects_eleventh_finite_reason_in_locked_fix_scope(self) -> None:
        payload = self.load_map()
        payload["finiteReason_enum"].append("future_registered_reason")
        payload["finiteReason_projections"].append(
            {
                "finiteReason": "future_registered_reason",
                "fallback_reason": "runtime_error_typed",
                "reasonKind": "runtime_unavailable",
                "bridge_result": "runtime_error",
            }
        )
        self.write_map(payload)

        spec = self.change / "specs/demo-capability-governance/spec.md"
        spec.write_text(
            spec.read_text(encoding="utf-8").replace(
                "or `already_state_noop`",
                "`future_registered_reason`, or `already_state_noop`",
                1,
            ),
            encoding="utf-8",
        )

        self.assert_failure("E_T0_LOCKED_SET_CHANGED")

    @unittest.skipUnless(CHECKER.exists(), "checker implementation pending")
    def test_free_string_finite_reason_fails_closed(self) -> None:
        payload = self.load_map()
        payload["finiteReason_enum"].append("made_up_reason")
        self.write_map(payload)
        self.assert_failure("finite_reason_unknown")


if __name__ == "__main__":
    unittest.main(verbosity=2)

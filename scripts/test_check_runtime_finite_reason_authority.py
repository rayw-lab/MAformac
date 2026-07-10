#!/usr/bin/env python3
"""Adversarial tests for the runtime finiteReason production authority checker."""

from __future__ import annotations

import json
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
CHECKER = REPO_ROOT / "Tools/checks/check_runtime_finite_reason_authority.py"
SURFACES = (
    Path("Core/LLM/DDomainToolPlanFailure.swift"),
    Path("Core/Execution/DemoRuntimeSessionRunner.swift"),
    Path("Core/Execution/DemoRuntimePartialPlan.swift"),
    Path("Core/Execution/FallbackContext.swift"),
    Path("Core/Trace/TraceLogger.swift"),
    Path("Core/Presentation/RuntimePresentationReasonAuthority.generated.swift"),
    Path("Tests/MAformacCoreTests/RuntimeNoMutationProbeTests.swift"),
    Path("Tools/checks/check_runtime_no_mutation_receipts.py"),
    Path("openspec/changes/add-c1-demo-capability-governance/ownership-map.yaml"),
)


class RuntimeFiniteReasonAuthorityCheckerTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory(prefix="runtime-finite-reason-authority-")
        self.repo = Path(self.temp_dir.name)
        for relative in SURFACES:
            destination = self.repo / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(REPO_ROOT / relative, destination)

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def run_checker(self) -> tuple[subprocess.CompletedProcess[str], dict[str, object]]:
        receipt = self.repo / "receipt.json"
        result = subprocess.run(
            [
                "python3",
                str(CHECKER),
                "--repo-root",
                str(self.repo),
                "--receipt",
                str(receipt),
            ],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
        payload = json.loads(receipt.read_text(encoding="utf-8")) if receipt.is_file() else {}
        return result, payload

    @staticmethod
    def violation_codes(payload: dict[str, object]) -> set[str]:
        violations = payload.get("violations", [])
        return {
            item.get("code")
            for item in violations
            if isinstance(item, dict) and isinstance(item.get("code"), str)
        }

    def replace(self, relative: str, old: str, new: str) -> None:
        path = self.repo / relative
        text = path.read_text(encoding="utf-8")
        self.assertIn(old, text)
        path.write_text(text.replace(old, new, 1), encoding="utf-8")

    def test_current_production_authority_passes(self) -> None:
        result, payload = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(payload.get("status"), "PASS")
        self.assertEqual(payload.get("t0_count"), 10)
        self.assertEqual(payload.get("violations"), [])

    def test_non_t0_literal_in_production_fails_closed(self) -> None:
        path = self.repo / "Core/Execution/DemoRuntimeSessionRunner.swift"
        path.write_text(
            path.read_text(encoding="utf-8") + '\nprivate let finiteReason = "w1_non_t0_reason"\n',
            encoding="utf-8",
        )
        result, payload = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_RUNTIME_FINITE_REASON_OUTSIDE_T0", self.violation_codes(payload))

    def test_fallback_shadow_switch_fails_closed(self) -> None:
        path = self.repo / "Core/Execution/FallbackContext.swift"
        path.write_text(
            path.read_text(encoding="utf-8")
            + "\nprivate func governanceReason(for finiteReason: RuntimeFiniteReason) {\n"
            + "    switch finiteReason { default: break }\n}\n",
            encoding="utf-8",
        )
        result, payload = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_FALLBACK_SHADOW_REASON_SWITCH", self.violation_codes(payload))

    def test_probe_expected_non_t0_reason_fails_closed(self) -> None:
        self.replace(
            "Tools/checks/check_runtime_no_mutation_receipts.py",
            '"fast_path_no_match_fallback": "fast_path_no_match"',
            '"fast_path_no_match_fallback": "guard_denied"',
        )
        result, payload = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_PROBE_FINITE_REASON_OUTSIDE_T0", self.violation_codes(payload))

    def test_trace_string_finite_reason_fails_closed(self) -> None:
        self.replace(
            "Core/Trace/TraceLogger.swift",
            "public var finiteReason: RuntimeFiniteReason?",
            "public var finiteReason: String?",
        )
        result, payload = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_TRACE_FINITE_REASON_UNTYPED", self.violation_codes(payload))

    def test_decode_failure_kind_is_not_misclassified_as_finite_reason(self) -> None:
        result, payload = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(payload.get("decode_failure_kinds"), [
            "parse_failed",
            "name_rejected",
            "ir_unclassified",
            "bridge_failed",
        ])
        self.assertNotIn("E_DECODE_FAILURE_KIND_AS_FINITE_REASON", self.violation_codes(payload))

        path = self.repo / "Core/Execution/DemoRuntimeSessionRunner.swift"
        path.write_text(
            path.read_text(encoding="utf-8") + '\nprivate let finiteReason = "parse_failed"\n',
            encoding="utf-8",
        )
        result, payload = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_DECODE_FAILURE_KIND_AS_FINITE_REASON", self.violation_codes(payload))

    def test_t0_membership_change_fails_locked_set_gate(self) -> None:
        registry_path = self.repo / "openspec/changes/add-c1-demo-capability-governance/ownership-map.yaml"
        payload = json.loads(registry_path.read_text(encoding="utf-8"))
        payload["finiteReason_enum"].append("future_registered_reason")
        payload["finiteReason_projections"].append(
            {
                "finiteReason": "future_registered_reason",
                "fallback_reason": "unsupported_no_available_tool",
                "reasonKind": "not_available_in_demo",
                "bridge_result": "refusal_no_available_tool",
            }
        )
        registry_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

        result, receipt = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_T0_LOCKED_SET_CHANGED", self.violation_codes(receipt))


if __name__ == "__main__":
    unittest.main()

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
import importlib.util

def _load_finite_reason_checker():
    spec = importlib.util.spec_from_file_location(
        "runtime_finite_reason_authority_checker", CHECKER
    )
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

_FINITE_REASON_CHECKER = _load_finite_reason_checker()
# SSOT: checker exports (no second path roster / no second behavior-gate roster).
SURFACES = _FINITE_REASON_CHECKER.CHECKER_SANDBOX_FIXTURE_SURFACES
BEHAVIOR_GATE_METHODS = tuple(_FINITE_REASON_CHECKER.BEHAVIOR_GATE_METHODS.values())


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
        self.assertEqual(payload.get("scope"), "known_pattern_lexical_layer")
        self.assertEqual(payload.get("semantic_completeness"), "not_semantically_complete")
        self.assertEqual(payload.get("residual_blind_spots"), [
            "renamed_probe_constants",
            "qualified_or_typealiased_string_types",
            "arbitrary_swift_dataflow_and_scope_resolution",
            "multiline_string_code_examples_may_false_positive",
            "fixed_nine_surface_allowlist_does_not_auto_discover_future_producers_or_consumers",
        ])
        self.assertEqual(payload.get("behavior_gates"), [
            "RuntimeFiniteReasonAuthorityTests.testFallbackResolutionMatchesHardcodedTenReasonScriptTable",
            "RuntimeFiniteReasonAuthorityTests.testTraceRoundTripsHardcodedTenFiniteReasonsEndToEnd",
            "RuntimeFiniteReasonAuthorityTests.testDiagnosticFailuresTraverseProductionRunnerAndRedactPresentationTrace",
        ])
        self.assertEqual(payload.get("behavior_gate_presence"), {
            "RuntimeFiniteReasonAuthorityTests.testFallbackResolutionMatchesHardcodedTenReasonScriptTable": True,
            "RuntimeFiniteReasonAuthorityTests.testTraceRoundTripsHardcodedTenFiniteReasonsEndToEnd": True,
            "RuntimeFiniteReasonAuthorityTests.testDiagnosticFailuresTraverseProductionRunnerAndRedactPresentationTrace": True,
        })
        self.assertEqual(len(payload.get("scan_coverage", [])), 9)
        self.assertNotIn(
            "Tests/MAformacCoreTests/RuntimeFiniteReasonAuthorityTests.swift",
            payload.get("scan_coverage", []),
        )
        self.assertEqual(payload.get("t0_count"), 10)
        self.assertEqual(payload.get("violations"), [])

    def assert_behavior_gate_missing(self, method: str, replacement: str) -> None:
        self.replace(
            "Tests/MAformacCoreTests/RuntimeFiniteReasonAuthorityTests.swift",
            f"    func {method}(",
            replacement,
        )
        result, payload = self.run_checker()
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(payload.get("status"), "FAIL")
        self.assertIn("E_REQUIRED_BEHAVIOR_GATE_MISSING", self.violation_codes(payload))

    def test_renamed_fallback_behavior_gate_fails_closed(self) -> None:
        self.assert_behavior_gate_missing(
            BEHAVIOR_GATE_METHODS[0],
            "    func helperFallbackResolutionMatchesHardcodedTenReasonScriptTable(",
        )

    def test_deleted_fallback_behavior_gate_fails_closed(self) -> None:
        self.assert_behavior_gate_missing(
            BEHAVIOR_GATE_METHODS[0],
            "    // deleted fallback behavior gate declaration(",
        )

    def test_renamed_trace_behavior_gate_fails_closed(self) -> None:
        self.assert_behavior_gate_missing(
            BEHAVIOR_GATE_METHODS[1],
            "    func helperTraceRoundTripsHardcodedTenFiniteReasonsEndToEnd(",
        )

    def test_deleted_trace_behavior_gate_fails_closed(self) -> None:
        self.assert_behavior_gate_missing(
            BEHAVIOR_GATE_METHODS[1],
            "    // deleted trace behavior gate declaration(",
        )

    def test_renamed_production_emitter_behavior_gate_fails_closed(self) -> None:
        self.assert_behavior_gate_missing(
            BEHAVIOR_GATE_METHODS[2],
            "    func helperDiagnosticFailuresTraverseProductionRunnerAndRedactPresentationTrace(",
        )

    def test_deleted_production_emitter_behavior_gate_fails_closed(self) -> None:
        self.assert_behavior_gate_missing(
            BEHAVIOR_GATE_METHODS[2],
            "    // deleted production emitter behavior gate declaration(",
        )

    def test_non_t0_literal_in_production_fails_closed(self) -> None:
        path = self.repo / "Core/Execution/DemoRuntimeSessionRunner.swift"
        path.write_text(
            path.read_text(encoding="utf-8") + '\nprivate let finiteReason = "w1_non_t0_reason"\n',
            encoding="utf-8",
        )
        result, payload = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_RUNTIME_FINITE_REASON_OUTSIDE_T0", self.violation_codes(payload))

    def test_w1_n1_multiline_non_t0_literal_in_production_fails_closed(self) -> None:
        path = self.repo / "Core/Execution/DemoRuntimeSessionRunner.swift"
        path.write_text(
            path.read_text(encoding="utf-8")
            + '\nprivate let finiteReason =\n    "w1_non_t0_reason"\n',
            encoding="utf-8",
        )
        result, payload = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(payload.get("status"), "FAIL")
        self.assertIn("E_RUNTIME_FINITE_REASON_OUTSIDE_T0", self.violation_codes(payload))

    def test_w1_round2_indexed_literal_flow_fails_known_pattern_lexical_layer(self) -> None:
        path = self.repo / "Core/Execution/DemoRuntimeSessionRunner.swift"
        path.write_text(
            path.read_text(encoding="utf-8")
            + '\nprivate let w1NonT0Reasons = ["w1_non_t0_reason"]\n'
            + "private let finiteReason = w1NonT0Reasons[0]\n",
            encoding="utf-8",
        )
        result, payload = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(payload.get("status"), "FAIL")
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

    def test_w1_n2_shadow_helper_with_parenthesized_switch_fails_closed(self) -> None:
        self.replace(
            "Core/Execution/FallbackContext.swift",
            "RuntimePresentationReasonAuthority.fallbackBucket(for: finiteReason)",
            "shadowBucket(for: finiteReason)",
        )
        self.replace(
            "Core/Execution/FallbackContext.swift",
            "    public var runtimeResult: DemoRuntimeResult {",
            "    private static func shadowBucket(for finiteReason: RuntimeFiniteReason) -> FallbackGovernanceReason? {\n"
            "        switch (finiteReason) {\n"
            "        default:\n"
            "            return RuntimePresentationReasonAuthority.fallbackBucket(for: finiteReason)\n"
            "        }\n"
            "    }\n\n"
            "    public var runtimeResult: DemoRuntimeResult {",
        )
        result, payload = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(payload.get("status"), "FAIL")
        self.assertIn("E_FALLBACK_SHADOW_REASON_SWITCH", self.violation_codes(payload))

    def test_w1_round2_nested_closure_shadow_fails_known_pattern_lexical_layer(self) -> None:
        self.replace(
            "Core/Execution/FallbackContext.swift",
            "let governanceReason = RuntimePresentationReasonAuthority.fallbackBucket(for: finiteReason)",
            "let governanceReason: FallbackGovernanceReason? = { reason in\n"
            "            switch reason {\n"
            "            case .nameRejected:\n"
            "                return .fastPathNoMatchFallback\n"
            "            default:\n"
            "                return RuntimePresentationReasonAuthority.fallbackBucket(for: reason)\n"
            "            }\n"
            "        }(finiteReason)",
        )
        result, payload = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(payload.get("status"), "FAIL")
        self.assertIn("E_FALLBACK_SHADOW_REASON_SWITCH", self.violation_codes(payload))

    def test_fallback_shadow_switch_through_local_alias_fails_closed(self) -> None:
        path = self.repo / "Core/Execution/FallbackContext.swift"
        path.write_text(
            path.read_text(encoding="utf-8")
            + "\nprivate func remapForTest(_ finiteReason: RuntimeFiniteReason) {\n"
            + "    let localReason = finiteReason\n"
            + "    switch (localReason) { default: break }\n"
            + "}\n",
            encoding="utf-8",
        )
        result, payload = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(payload.get("status"), "FAIL")
        self.assertIn("E_FALLBACK_SHADOW_REASON_SWITCH", self.violation_codes(payload))

    def test_fallback_local_governance_return_helper_fails_closed(self) -> None:
        path = self.repo / "Core/Execution/FallbackContext.swift"
        path.write_text(
            path.read_text(encoding="utf-8")
            + "\nprivate func localBucket(for reason: RuntimeFiniteReason) -> FallbackGovernanceReason? {\n"
            + "    RuntimePresentationReasonAuthority.fallbackBucket(for: reason)\n"
            + "}\n",
            encoding="utf-8",
        )
        result, payload = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(payload.get("status"), "FAIL")
        self.assertIn("E_FALLBACK_SHADOW_REASON_SWITCH", self.violation_codes(payload))

    def test_commented_shadow_and_non_t0_literal_do_not_fail(self) -> None:
        runner = self.repo / "Core/Execution/DemoRuntimeSessionRunner.swift"
        runner.write_text(
            runner.read_text(encoding="utf-8")
            + '\n// private let finiteReason = "w1_non_t0_reason"\n',
            encoding="utf-8",
        )
        fallback = self.repo / "Core/Execution/FallbackContext.swift"
        fallback.write_text(
            fallback.read_text(encoding="utf-8")
            + "\n/* switch (finiteReason) { default: break } */\n",
            encoding="utf-8",
        )
        result, payload = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(payload.get("status"), "PASS")
        self.assertEqual(payload.get("violations"), [])

    def test_missing_runtime_presentation_bridge_consumer_fails_closed(self) -> None:
        (self.repo / "Core/Presentation/RuntimePresentationBridge.swift").unlink()
        result, payload = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(payload.get("status"), "FAIL")
        self.assertIn("E_REQUIRED_SURFACE_MISSING", self.violation_codes(payload))

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

    def assert_locked_set_mutation_fails(self, mutate) -> None:
        registry_path = self.repo / "openspec/changes/add-c1-demo-capability-governance/ownership-map.yaml"
        payload = json.loads(registry_path.read_text(encoding="utf-8"))
        mutate(payload["finiteReason_enum"])
        registry_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        result, receipt = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertTrue(
            self.violation_codes(receipt)
            & {
                "E_T0_PROJECTION_DRIFT",
                "E_GENERATED_RUNTIME_REASON_DRIFT",
                "E_T0_LOCKED_SET_CHANGED",
            },
            receipt,
        )

    def test_t0_add_eleventh_member_fails_locked_set_gate(self) -> None:
        self.assert_locked_set_mutation_fails(lambda values: values.append("v5a_forbidden_eleventh"))

    def test_t0_delete_member_fails_locked_set_gate(self) -> None:
        self.assert_locked_set_mutation_fails(lambda values: values.pop())

    def test_t0_rename_member_fails_locked_set_gate(self) -> None:
        self.assert_locked_set_mutation_fails(
            lambda values: values.__setitem__(0, "v5a_forbidden_rename")
        )


if __name__ == "__main__":
    unittest.main()

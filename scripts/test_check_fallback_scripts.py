#!/usr/bin/env python3
"""Behavior tests for the C1 fallback-script SSOT checker."""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
CHECKER = REPO_ROOT / "Tools" / "checks" / "check_fallback_scripts.py"
SOURCE = REPO_ROOT / "contracts" / "fallback-scripts.yaml"
SCHEMA = REPO_ROOT / "contracts" / "schemas" / "fallback-scripts.schema.json"
GENERATED_JSON = REPO_ROOT / "generated" / "demo-fallback-scripts.catalog.json"
GENERATED_SWIFT = REPO_ROOT / "Core" / "Contracts" / "FallbackScriptCatalog.generated.swift"
GENERATED_REASON_AUTHORITY = REPO_ROOT / "Core" / "Presentation" / "RuntimePresentationReasonAuthority.generated.swift"
GENERATOR = REPO_ROOT / "Tools" / "generate_fallback_script_catalog_swift.py"
T0_REGISTRY = REPO_ROOT / "openspec" / "changes" / "add-c1-demo-capability-governance" / "ownership-map.yaml"
BRIDGE_SOURCE = REPO_ROOT / "Core" / "Presentation" / "RuntimePresentationBridge.swift"


class FallbackScriptsCheckerTests(unittest.TestCase):
    def run_checker(
        self,
        source: Path = SOURCE,
        generated_json: Path | None = None,
        generated_swift: Path | None = None,
        generated_reason_authority: Path | None = None,
        bridge_source: Path | None = None,
        t0_registry: Path | None = None,
    ) -> tuple[subprocess.CompletedProcess[str], dict]:
        with tempfile.TemporaryDirectory(prefix="fallback-checker-test-") as tmp:
            receipt = Path(tmp) / "receipt.json"
            command = [
                    sys.executable,
                    str(CHECKER),
                    "--source",
                    str(source),
                    "--schema",
                    str(SCHEMA),
                    "--receipt",
                    str(receipt),
                ]
            if t0_registry is not None:
                command.extend(["--t0-registry", str(t0_registry)])
            if generated_json is not None:
                command.extend(["--generated-json", str(generated_json)])
            if generated_swift is not None:
                command.extend(["--generated-swift", str(generated_swift)])
            if generated_reason_authority is not None:
                command.extend(["--generated-reason-authority", str(generated_reason_authority)])
            if bridge_source is not None:
                command.extend(["--bridge-source", str(bridge_source)])
            result = subprocess.run(
                command,
                cwd=REPO_ROOT,
                capture_output=True,
                text=True,
                check=False,
            )
            payload = json.loads(receipt.read_text(encoding="utf-8")) if receipt.exists() else {}
            return result, payload

    def write_mutation(self, mutate) -> tuple[tempfile.TemporaryDirectory[str], Path]:
        tmp = tempfile.TemporaryDirectory(prefix="fallback-source-mutation-")
        path = Path(tmp.name) / "fallback-scripts.yaml"
        payload = json.loads(SOURCE.read_text(encoding="utf-8"))
        mutate(payload)
        path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        return tmp, path

    def test_canonical_source_covers_exactly_10_by_4_pairs(self) -> None:
        result, receipt = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(receipt["family_count"], 10)
        self.assertEqual(receipt["reason_count"], 4)
        self.assertEqual(receipt["cell_count"], 40)
        self.assertEqual(receipt["missing_pairs"], [])
        self.assertEqual(receipt["duplicate_pairs"], [])

    def test_missing_family_reason_pair_fails_closed(self) -> None:
        tmp, source = self.write_mutation(lambda payload: payload["cells"].pop())
        self.addCleanup(tmp.cleanup)
        result, receipt = self.run_checker(source)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("missing_family_reason_pairs", receipt["errors"])
        self.assertEqual(len(receipt["missing_pairs"]), 1)

    def test_reason_enum_rejects_free_string_extension(self) -> None:
        def mutate(payload: dict) -> None:
            payload["cells"][0]["reason_kind"] = "friendly_generic_fallback"

        tmp, source = self.write_mutation(mutate)
        self.addCleanup(tmp.cleanup)
        result, receipt = self.run_checker(source)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(receipt["unknown_reasons"], ["friendly_generic_fallback"])
        self.assertIn("unknown_reasons", receipt["errors"])

    def test_customer_surface_rejects_raw_finite_reason(self) -> None:
        def mutate(payload: dict) -> None:
            payload["cells"][0]["finiteReason"] = "missing_slot"
            payload["cells"][0]["customer_surface_fields"].append("finiteReason")

        tmp, source = self.write_mutation(mutate)
        self.addCleanup(tmp.cleanup)
        result, receipt = self.run_checker(source)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("customer_raw_field_exposure", receipt["errors"])
        self.assertTrue(receipt["customer_raw_field_hits"])

    def test_basis_refs_must_resolve_to_unique_repo_sources(self) -> None:
        def mutate(payload: dict) -> None:
            payload["cells"][0]["basis_refs"][0] = {
                "path": "contracts/does-not-exist.yaml",
                "contains": "imaginary authority",
            }

        tmp, source = self.write_mutation(mutate)
        self.addCleanup(tmp.cleanup)
        result, receipt = self.run_checker(source)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unresolved_basis_refs", receipt["errors"])
        self.assertEqual(receipt["unresolved_basis_refs"][0]["cell_id"], "fallback.ac.safety_or_clarify_reject.zh-CN")

    def test_basis_ref_rejects_runtime_source_even_when_its_string_is_unique(self) -> None:
        def mutate(payload: dict) -> None:
            payload["cells"][0]["basis_refs"][0] = {
                "path": "Core/Intent/FastPathIntentEngine.swift",
                "contains": "enum FastPathIntentError",
            }

        tmp, source = self.write_mutation(mutate)
        self.addCleanup(tmp.cleanup)
        result, receipt = self.run_checker(source)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("non_ssot_basis_refs", receipt["errors"])

    def test_door_safety_fact_resolution_is_reported_as_follow_up(self) -> None:
        result, receipt = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stderr)
        observation = next(
            entry
            for entry in receipt["follow_up_fact_observations"]
            if entry["cell_id"] == "fallback.door.safety_or_clarify_reject.zh-CN"
        )
        self.assertEqual(observation["authority"], "risk_and_state_policy")
        self.assertTrue(observation["query_result"]["risk_rule"])
        self.assertTrue(observation["query_result"]["door_state"])
        self.assertTrue(observation["query_result"]["speed_state"])
        self.assertEqual(receipt["basis_contract_gate"]["fact_resolution"], "follow_up_not_c1_gate")

    def test_t0_reason_projection_cannot_be_remapped_to_another_safe_enum(self) -> None:
        def mutate(payload: dict) -> None:
            cell = next(cell for cell in payload["cells"] if cell["reason_kind"] == "unmounted_name_rejected")
            cell["safeReasonKind"] = "not_available_in_demo"

        tmp, source = self.write_mutation(mutate)
        self.addCleanup(tmp.cleanup)
        result, receipt = self.run_checker(source)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("t0_projection_mismatch", receipt["errors"])

    def test_t0_internal_reason_mapping_is_closed(self) -> None:
        with tempfile.TemporaryDirectory(prefix="fallback-registry-mutation-") as tmp:
            registry = Path(tmp) / "ownership-map.yaml"
            payload = json.loads(T0_REGISTRY.read_text(encoding="utf-8"))
            projection = next(item for item in payload["finiteReason_projections"] if item["finiteReason"] == "name_rejected")
            projection["fallback_reason"] = "friendly_free_string"
            registry.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            result, receipt = self.run_checker(t0_registry=registry)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("t0_registry_projection_errors", receipt["errors"])

    def test_source_has_no_parallel_t0_enum_or_projection_copy(self) -> None:
        payload = json.loads(SOURCE.read_text(encoding="utf-8"))
        for field in (
            "governance_reason_enum",
            "safe_reason_kind_enum",
            "result_kind_enum",
            "internal_reason_mappings",
        ):
            self.assertNotIn(field, payload)

    def test_generated_catalog_reuses_bridge_reason_and_result_types(self) -> None:
        generated = GENERATED_SWIFT.read_text(encoding="utf-8")
        self.assertNotIn("enum FallbackSafeReasonKind", generated)
        self.assertNotIn("enum FallbackResultKind", generated)
        self.assertIn("typealias FallbackSafeReasonKind = RuntimePresentationSafeReasonKind", generated)
        self.assertIn("typealias FallbackResultKind = DemoRuntimeResult", generated)

    def test_bridge_does_not_handwrite_the_registry_derived_reason_projection(self) -> None:
        bridge = BRIDGE_SOURCE.read_text(encoding="utf-8")
        self.assertNotIn("private enum RuntimePresentationSafeReasonKind", bridge)
        self.assertNotIn("init?(finiteReason: String)", bridge)

    def test_generated_reason_authority_is_a_tracked_t0_derived_view(self) -> None:
        generated = GENERATED_REASON_AUTHORITY.read_text(encoding="utf-8")
        registry = json.loads(T0_REGISTRY.read_text(encoding="utf-8"))
        registry_sha = __import__("hashlib").sha256(T0_REGISTRY.read_bytes()).hexdigest()

        self.assertIn("Generated by Tools/generate_fallback_script_catalog_swift.py. Do not edit.", generated)
        self.assertIn(registry_sha, generated)
        self.assertEqual(generated.count("public enum RuntimePresentationSafeReasonKind"), 1)
        for finite_reason in registry["finiteReason_enum"]:
            self.assertIn(f'"{finite_reason}"', generated)
        for reason_kind in registry["reasonKind_enum"]:
            self.assertIn(f'= "{reason_kind}"', generated)

    def test_checker_rejects_parallel_handwritten_bridge_reason_authority(self) -> None:
        with tempfile.TemporaryDirectory(prefix="fallback-parallel-reason-") as tmp:
            bridge = Path(tmp) / "RuntimePresentationBridge.swift"
            bridge.write_text(
                "private enum RuntimePresentationSafeReasonKind: String {\n"
                "    init?(finiteReason: String) { return nil }\n"
                "}\n",
                encoding="utf-8",
            )
            result, receipt = self.run_checker(
                SOURCE,
                GENERATED_JSON,
                GENERATED_SWIFT,
                GENERATED_REASON_AUTHORITY,
                bridge,
            )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("parallel_bridge_reason_authority", receipt["errors"])

    def test_checker_records_the_single_generated_reason_authority(self) -> None:
        result, receipt = self.run_checker(
            SOURCE,
            GENERATED_JSON,
            GENERATED_SWIFT,
            GENERATED_REASON_AUTHORITY,
            BRIDGE_SOURCE,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(receipt["reason_authority_path"], "Core/Presentation/RuntimePresentationReasonAuthority.generated.swift")
        self.assertIsNotNone(receipt["reason_authority_sha256"])

    def test_checker_emits_follow_up_observation_for_each_reason_specific_cell(self) -> None:
        result, receipt = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stderr)
        resolutions = [
            entry
            for entry in receipt["follow_up_fact_observations"]
            if "reason_kind" in entry and "kind" not in entry
        ]
        self.assertEqual(len(resolutions), 40)
        reasons = {entry["reason_kind"] for entry in resolutions}
        self.assertEqual(
            reasons,
            {
                "safety_or_clarify_reject",
                "unmounted_name_rejected",
                "fast_path_no_match_fallback",
                "unknown_no_representative_entry",
            },
        )

    def test_fact_resolution_is_follow_up_when_its_representative_is_mounted(self) -> None:
        def mutate(payload: dict) -> None:
            payload["families"]["ac"]["representative_tool"] = "adjust_ac_temperature_to_number"

        tmp, source = self.write_mutation(mutate)
        self.addCleanup(tmp.cleanup)
        result, receipt = self.run_checker(source)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("basis_resolution_failed", receipt["errors"])
        self.assertTrue(
            any(
                observation.get("kind") == "mounted_representative_present"
                for observation in receipt["follow_up_fact_observations"]
            )
        )

    def test_basis_scope_note_locks_ssot_gate_and_follow_up_boundary(self) -> None:
        payload = json.loads(SOURCE.read_text(encoding="utf-8"))
        self.assertIn("unique strings", payload["basis_scope_note"])
        self.assertIn("follow-up", payload["basis_scope_note"])
        self.assertIn("SHALL NOT fail", payload["basis_scope_note"])

        tmp, source = self.write_mutation(lambda mutated: mutated.pop("basis_scope_note"))
        self.addCleanup(tmp.cleanup)
        result, receipt = self.run_checker(source)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("basis_scope_note_mismatch", receipt["errors"])

    def test_generated_catalog_drift_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory(prefix="fallback-generated-drift-") as tmp:
            generated = Path(tmp) / "catalog.json"
            payload = json.loads(GENERATED_JSON.read_text(encoding="utf-8"))
            payload["entries"][0]["dialogText"] = "漂移文案"
            generated.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            result, receipt = self.run_checker(SOURCE, generated, GENERATED_SWIFT)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("generated_catalog_drift", receipt["errors"])

    def test_unknown_cell_field_fails_schema_shape(self) -> None:
        def mutate(payload: dict) -> None:
            payload["cells"][0]["unexpectedCustomerNote"] = "should not be accepted"

        tmp, source = self.write_mutation(mutate)
        self.addCleanup(tmp.cleanup)
        result, receipt = self.run_checker(source)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("schema_shape_violation", receipt["errors"])

    def test_generator_is_byte_deterministic_and_matches_tracked_views(self) -> None:
        with tempfile.TemporaryDirectory(prefix="fallback-generation-replay-") as tmp:
            root = Path(tmp)
            first_json = root / "first.json"
            first_swift = root / "first.swift"
            first_reason_authority = root / "first-reason-authority.swift"
            second_json = root / "second.json"
            second_swift = root / "second.swift"
            second_reason_authority = root / "second-reason-authority.swift"
            for json_output, swift_output, reason_authority_output in (
                (first_json, first_swift, first_reason_authority),
                (second_json, second_swift, second_reason_authority),
            ):
                result = subprocess.run(
                    [
                        sys.executable,
                        str(GENERATOR),
                        "--source",
                        str(SOURCE),
                        "--json-output",
                        str(json_output),
                        "--swift-output",
                        str(swift_output),
                        "--reason-authority-output",
                        str(reason_authority_output),
                    ],
                    cwd=REPO_ROOT,
                    capture_output=True,
                    text=True,
                    check=False,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(first_json.read_bytes(), second_json.read_bytes())
            self.assertEqual(first_swift.read_bytes(), second_swift.read_bytes())
            self.assertEqual(first_reason_authority.read_bytes(), second_reason_authority.read_bytes())
            self.assertEqual(first_json.read_bytes(), GENERATED_JSON.read_bytes())
            self.assertEqual(first_swift.read_bytes(), GENERATED_SWIFT.read_bytes())
            self.assertEqual(first_reason_authority.read_bytes(), GENERATED_REASON_AUTHORITY.read_bytes())


if __name__ == "__main__":
    unittest.main()

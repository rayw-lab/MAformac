"""Python fixture checker for the W6 typed route/model contract.

Verifies:
  1. JSON schema shape of every fixture route_result.
  2. Positive fixtures round-trip: `_source.contract_row_id` refers to a real
     row in `contracts/semantic-function-contract.jsonl`, and the fixture's
     `action_candidate.{intent,service,device,action_primitive,action_code}`
     tuple matches that jsonl row verbatim.
  3. Positive fixtures declare a real, in-catalog service ∈ {airControl, carControl, cmd}.
  4. Negative fixtures fail schema validation (or otherwise document what the
     Swift validator rejects — some negatives are semantic-level violations
     that the schema itself doesn't catch, e.g. unmounted tool name).
"""

from __future__ import annotations

import json
import unittest
from pathlib import Path

import jsonschema

REPO_ROOT = Path(__file__).resolve().parents[2].parent
SCHEMA_PATH = REPO_ROOT / "contracts/schemas/typed-route-contract.v1.schema.json"
JSONL_PATH = REPO_ROOT / "contracts/semantic-function-contract.jsonl"
POSITIVE_DIR = REPO_ROOT / "contracts/fixtures/typed-route-contract/positive"
NEGATIVE_DIR = REPO_ROOT / "contracts/fixtures/typed-route-contract/negative"


def load_schema():
    return json.loads(SCHEMA_PATH.read_text())


def load_jsonl_by_row_id():
    """Build a dict: contract_row_id -> jsonl row dict."""
    out = {}
    with JSONL_PATH.open() as f:
        for line in f:
            row = json.loads(line)
            out[row["contract_row_id"]] = row
    return out


# Cache expensive jsonl load once per module.
_JSONL_CACHE = None


def jsonl_rows():
    global _JSONL_CACHE
    if _JSONL_CACHE is None:
        _JSONL_CACHE = load_jsonl_by_row_id()
    return _JSONL_CACHE


class SchemaShapeChecks(unittest.TestCase):
    """Every positive fixture's route_result MUST pass schema validation."""

    @classmethod
    def setUpClass(cls):
        cls.schema = load_schema()

    def _validate(self, path: Path):
        payload = json.loads(path.read_text())
        route_result = payload["route_result"]
        # Strip session_id if present (negative fixture) BEFORE validating to
        # allow the schema `not` clause to fire on other checks; the top-level
        # `additionalProperties: false` will still reject unknown top-level.
        jsonschema.validate(instance=route_result, schema=self.schema)

    def test_positive_air_control(self):
        self._validate(POSITIVE_DIR / "airControl_candidate.json")

    def test_positive_car_control(self):
        self._validate(POSITIVE_DIR / "carControl_candidate.json")

    def test_positive_cmd(self):
        self._validate(POSITIVE_DIR / "cmd_candidate.json")

    def test_positive_reject_r0(self):
        self._validate(POSITIVE_DIR / "reject_R0_forbidden.json")

    def test_positive_clarify_r2(self):
        self._validate(POSITIVE_DIR / "clarify_R2.json")


class PositiveFixtureJsonlBinding(unittest.TestCase):
    """Positive fixtures must reference real jsonl contract_row_id rows and
    match on {intent, service, device, action_primitive, action_code}."""

    @classmethod
    def setUpClass(cls):
        cls.rows = jsonl_rows()

    def _check_row_binding(self, path: Path):
        payload = json.loads(path.read_text())
        source = payload["_source"]
        row_id = source.get("contract_row_id")
        if not row_id:
            self.skipTest(
                f"Positive fixture {path.name} has no contract_row_id "
                "(non-jsonl-derived positive, e.g. reject/clarify carrier)."
            )
        self.assertIn(
            row_id, self.rows,
            f"Fixture {path.name} references contract_row_id={row_id} that "
            f"is not present in contracts/semantic-function-contract.jsonl "
            "(SHALL 'Fabricated intent is rejected by the fixture checker').",
        )
        row = self.rows[row_id]
        # Positive fixture may bind fields via either action_candidate (when
        # outcome=candidate and a mounted tool exists) OR _source.jsonl_binding
        # (when outcome=clarify/fallback because no mounted tool is available
        # for that service yet — see carControl/cmd fixtures which use the
        # clarify path due to the current one-tool catalog at
        # Core/Contracts/DDomainMountedToolCatalog.swift:12-14).
        ac = payload["route_result"].get("action_candidate")
        binding = ac if ac is not None else source.get("jsonl_binding")
        self.assertIsNotNone(
            binding,
            f"Fixture {path.name} declares contract_row_id={row_id} but "
            "provides neither action_candidate nor _source.jsonl_binding to "
            "cross-check jsonl fields.",
        )
        for field in ("intent", "service", "device", "action_primitive", "action_code"):
            self.assertEqual(
                binding[field], row[field],
                f"Fixture {path.name} {field}={binding[field]!r} does not "
                f"match jsonl row {row_id} {field}={row[field]!r}",
            )

    def test_air_control_row_binding(self):
        self._check_row_binding(POSITIVE_DIR / "airControl_candidate.json")

    def test_car_control_row_binding(self):
        self._check_row_binding(POSITIVE_DIR / "carControl_candidate.json")

    def test_cmd_row_binding(self):
        self._check_row_binding(POSITIVE_DIR / "cmd_candidate.json")


class PositiveServiceCoverage(unittest.TestCase):
    """Positive fixture set covers all three services (airControl / carControl / cmd).
    Coverage is at RouteResult.service (top-level), NOT at action_candidate.service,
    because carControl/cmd currently route to outcome=clarify (no mounted tool in
    catalog per DDomainMountedToolCatalog.swift:12-14 = {'adjust_ac_temperature_to_number'})
    and therefore have action_candidate=null."""

    def test_all_three_services_covered_by_positive_fixtures(self):
        services_seen = set()
        for path in sorted(POSITIVE_DIR.glob("*.json")):
            payload = json.loads(path.read_text())
            services_seen.add(payload["route_result"]["service"])
        # airControl is candidate; carControl+cmd are clarify (in current
        # one-tool catalog state). The reject_R0 fixture also uses carControl.
        self.assertTrue(
            {"airControl", "carControl", "cmd"}.issubset(services_seen),
            f"Positive fixture set MUST include at least one RouteResult per "
            f"service in the D-domain catalog. Saw: {services_seen}",
        )


class NegativeFixtureSchemaOrSemantic(unittest.TestCase):
    """Negative fixtures MUST either:
       - fail schema validation (structural violation), OR
       - be flagged with `expected_error` for a semantic-level rejection that
         the Swift validator handles (e.g. unmounted tool name — schema-valid
         but validator-rejected).
    """

    @classmethod
    def setUpClass(cls):
        cls.schema = load_schema()

    def _categorize(self, path: Path) -> str:
        payload = json.loads(path.read_text())
        try:
            jsonschema.validate(instance=payload["route_result"], schema=self.schema)
            return "schema_valid"
        except jsonschema.ValidationError:
            return "schema_invalid"

    def test_every_negative_has_expected_error_annotation(self):
        for path in sorted(NEGATIVE_DIR.glob("*.json")):
            payload = json.loads(path.read_text())
            self.assertIn(
                "expected_error", payload.get("_source", {}),
                f"Negative fixture {path.name} MUST document expected_error in _source.",
            )

    def test_schema_or_semantic_negative(self):
        # Which negatives are semantic-only (schema-valid but validator-rejected)
        # vs schema-level: this classification is descriptive; both must exist.
        schema_invalid_names = set()
        schema_valid_names = set()
        for path in sorted(NEGATIVE_DIR.glob("*.json")):
            category = self._categorize(path)
            if category == "schema_invalid":
                schema_invalid_names.add(path.name)
            else:
                schema_valid_names.add(path.name)
        # At least one schema-level negative and at least one semantic-only
        # negative should exist to prove both layers of the defence are exercised.
        self.assertGreater(
            len(schema_invalid_names), 0,
            "At least one negative fixture MUST fail JSON schema validation.",
        )
        self.assertGreater(
            len(schema_valid_names), 0,
            "At least one negative fixture MUST be schema-valid but "
            "semantic-invalid (validator-rejected) — proves the Swift "
            "validator is not redundant with the schema.",
        )

    def test_unknown_exec_tier_fails_schema(self):
        payload = json.loads((NEGATIVE_DIR / "unknown_exec_tier.json").read_text())
        with self.assertRaises(jsonschema.ValidationError):
            jsonschema.validate(instance=payload["route_result"], schema=self.schema)

    def test_widened_clarify_tag_fails_schema(self):
        payload = json.loads((NEGATIVE_DIR / "widened_clarify_tag.json").read_text())
        with self.assertRaises(jsonschema.ValidationError):
            jsonschema.validate(instance=payload["route_result"], schema=self.schema)

    def test_session_id_leak_fails_schema(self):
        payload = json.loads((NEGATIVE_DIR / "session_id_leak.json").read_text())
        with self.assertRaises(jsonschema.ValidationError):
            jsonschema.validate(instance=payload["route_result"], schema=self.schema)

    def test_out_of_catalog_service_fails_schema(self):
        payload = json.loads((NEGATIVE_DIR / "out_of_catalog_service.json").read_text())
        with self.assertRaises(jsonschema.ValidationError):
            jsonschema.validate(instance=payload["route_result"], schema=self.schema)

    def test_schema_version_drift_fails_schema(self):
        payload = json.loads((NEGATIVE_DIR / "schema_version_drift.json").read_text())
        with self.assertRaises(jsonschema.ValidationError):
            jsonschema.validate(instance=payload["route_result"], schema=self.schema)

    def test_illegal_combination_fails_schema(self):
        # outcome=candidate + action_candidate=null triggers allOf if-then.
        payload = json.loads(
            (NEGATIVE_DIR / "illegal_combination_candidate_without_action.json").read_text()
        )
        with self.assertRaises(jsonschema.ValidationError):
            jsonschema.validate(instance=payload["route_result"], schema=self.schema)

    def test_reject_missing_reason_fails_schema(self):
        payload = json.loads((NEGATIVE_DIR / "reject_missing_reason.json").read_text())
        with self.assertRaises(jsonschema.ValidationError):
            jsonschema.validate(instance=payload["route_result"], schema=self.schema)

    def test_exp_with_literal_offset_fails_schema(self):
        payload = json.loads((NEGATIVE_DIR / "exp_with_literal_offset.json").read_text())
        with self.assertRaises(jsonschema.ValidationError):
            jsonschema.validate(instance=payload["route_result"], schema=self.schema)

    def test_unmounted_tool_is_schema_valid_semantic_only(self):
        # mounted_tool_name is a semantic constraint bound to
        # DDomainMountedToolCatalog.mountedToolNames — not a JSON-schema-level
        # check. The Swift validator handles rejection.
        payload = json.loads((NEGATIVE_DIR / "unmounted_tool_name.json").read_text())
        # Schema-valid:
        jsonschema.validate(instance=payload["route_result"], schema=self.schema)
        # But documents expected_error:
        self.assertEqual(payload["_source"]["expected_error"], "unmounted_name")

    def test_cross_service_mount_binding_is_schema_valid_semantic_only(self):
        # grok-4.5 xAI review P1-A2 fixture (2026-07-13). service=carControl
        # but mounted_tool_name=adjust_ac_temperature_to_number (bound to
        # airControl per MountedToolServiceMap). JSON schema can't cross-check
        # this because the mounted<->service binding lives in Swift; the Swift
        # validator handles rejection with .crossDomainMountedTool.
        payload = json.loads((NEGATIVE_DIR / "cross_service_mount_binding.json").read_text())
        jsonschema.validate(instance=payload["route_result"], schema=self.schema)
        self.assertEqual(payload["_source"]["expected_error"], "cross_domain_mounted_tool")
        # Assert the top-level service disagrees with the tool's known binding.
        self.assertEqual(payload["route_result"]["service"], "carControl")
        self.assertEqual(
            payload["route_result"]["action_candidate"]["mounted_tool_name"],
            "adjust_ac_temperature_to_number",
        )


class ParadigmBindingCheck(unittest.TestCase):
    """P1-A1 fix: candidate positive fixtures MUST satisfy the D-domain
    paradigm at `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:13`
    intent == 工具名 (intent must equal mounted_tool_name for candidate outcomes)."""

    def test_air_control_intent_equals_mounted_tool_name(self):
        payload = json.loads((POSITIVE_DIR / "airControl_candidate.json").read_text())
        ac = payload["route_result"]["action_candidate"]
        self.assertIsNotNone(ac, "airControl fixture must have action_candidate")
        self.assertEqual(
            ac["intent"], ac["mounted_tool_name"],
            "SHALL 'intent == 工具名' paradigm violated — this was grok-4.5 review P1-A1.",
        )


class CanonicalDigestParityWithSwift(unittest.TestCase):
    """Verify Python's canonical JSON (sort_keys + separators) reproduces
    the digest that Swift's `JSONEncoder(.sortedKeys)` + SHA-256 produced.
    Cross-checks the fixture pinned digest is reproducible."""

    def _digest(self, load_bearing: dict) -> str:
        import hashlib
        canonical = json.dumps(
            load_bearing, ensure_ascii=False, sort_keys=True, separators=(",", ":")
        )
        return hashlib.sha256(canonical.encode()).hexdigest()

    def _check(self, path: Path):
        payload = json.loads(path.read_text())
        lb = payload["route_trace_load_bearing"]
        # Strip Nones (Swift synthesized Codable uses encodeIfPresent for optionals).
        lb_no_nulls = {k: v for k, v in lb.items() if v is not None}
        computed = self._digest(lb_no_nulls)
        expected = payload["route_result"]["trace_digest"]
        self.assertEqual(
            computed, expected,
            f"{path.name}: Python-computed digest != fixture pinned digest. "
            "This means the fixture's pinned digest drifted or the canonical "
            "encoding rules changed.",
        )

    def test_air_control_digest_parity(self):
        self._check(POSITIVE_DIR / "airControl_candidate.json")

    def test_car_control_digest_parity(self):
        self._check(POSITIVE_DIR / "carControl_candidate.json")

    def test_cmd_digest_parity(self):
        self._check(POSITIVE_DIR / "cmd_candidate.json")

    def test_reject_r0_digest_parity(self):
        self._check(POSITIVE_DIR / "reject_R0_forbidden.json")

    def test_clarify_r2_digest_parity(self):
        self._check(POSITIVE_DIR / "clarify_R2.json")


if __name__ == "__main__":
    unittest.main(verbosity=2)

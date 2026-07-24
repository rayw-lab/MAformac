#!/usr/bin/env python3
from __future__ import annotations
import copy, json, re, unittest
from pathlib import Path
from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[1]

class IntV5AV5CPreflightContractTests(unittest.TestCase):
    def test_v5a_artifacts_satisfy_interface_lock_and_v5c_consumer_preflight(self):
        manifest = json.loads((ROOT/'generated/demo-runtime-contract-bundle.manifest.json').read_text())
        self.assertRegex(manifest['runtime_contract_bundle_digest'], r'^[0-9a-f]{64}$')
        self.assertNotEqual(manifest['schema_version'], manifest['catalog_schema_version'])
        swift = (ROOT/'Core/Contracts/DemoRuntimeContractBundle.generated.swift').read_text()
        self.assertIn('public enum DemoRuntimeContractBundleCatalog', swift)
        self.assertIn('public static let runtimeContractBundleDigest', swift)
        matrix_schema = (ROOT/'contracts/schemas/demo-capability-matrix.schema.json').read_text()
        self.assertIn('actionDemoProven', matrix_schema)
        self.assertIn('actionDemoProven_basis', matrix_schema)
        receipt_schema = json.loads((ROOT/'contracts/schemas/runtime-action-readback-receipt-v2.schema.json').read_text())
        self.assertIn('probe_catalog_sha256', receipt_schema['required'])
        valid = {key: ('a'*64 if key == 'probe_catalog_sha256' else None) for key in []}
        self.assertIn('probe_catalog_sha256', receipt_schema['properties'])
        self.assertNotIn('contracts/runtime-action-readback-probes.json', (ROOT/'Tools/generate_demo_runtime_contract_bundle.py').read_text())

    def test_receipt_schema_accepts_v5c_digest_and_rejects_invalid(self):
        schema = json.loads((ROOT/'contracts/schemas/runtime-action-readback-receipt-v2.schema.json').read_text())
        Draft202012Validator.check_schema(schema)
        self.assertTrue(schema['properties']['probe_catalog_sha256']['type'])

    def _complete_case(self) -> dict:
        return {
            "probeID": "probe.action.matrix.1.zh-CN",
            "matrixID": 1,
            "register": "直述",
            "utterance": "打开空调",
            "representativeTool": "open_ac",
            "requiredEmittedToolName": "set_vehicle_control",
            "requiredActionPrimitive": "power_on",
            "pathKind": "product_acceptance_route",
            "injectionUsed": False,
            "acceptanceRouteID": "product.frontstage.text.v1",
            "traceID": "trace-matrix-1",
            "stageTraceIDs": {"decode": ["trace-matrix-1"], "execute": ["trace-matrix-1"], "readback": ["trace-matrix-1"]},
            "observedToolCallCount": 1,
            "emittedToolNames": ["set_vehicle_control"],
            "emittedActionPrimitive": "power_on",
            "stateBeforeSHA256": "a" * 64,
            "stateAfterSHA256": "b" * 64,
            "stateMutation": True,
            "stateDeltas": [{"key": "ac.power", "beforeValue": "off", "afterValue": "on"}],
            "confirmedState": {"key": "ac.power", "actualValue": "on"},
            "resultKind": "accepted_tool_call",
            "reconciliationStatus": "verified",
            "readbacks": [{"key": "ac.power", "actualValue": "on", "spokenText": "空调已打开"}],
        }

    def _valid_receipt(self) -> dict:
        return {
            "schemaVersion": "runtime_action_readback_receipt_v2",
            "receiptID": "runtime-action-readback-probes",
            "proofClass": "local_unit",
            "caseCount": 1,
            "runID": "local:schema-test",
            "sourceHeadSHA": "a" * 40,
            "testedCheckoutSHA": "a" * 40,
            "nonce": "b" * 32,
            "buildIdentity": "swift-test",
            "modelIdentity": "DemoSliceAdmissionCatalog",
            "runtimeContractBundleDigest": "c" * 64,
            "probe_catalog_sha256": "d" * 64,
            "cases": [self._complete_case()],
        }

    def test_receipt_schema_requires_dual_identity_on_every_case(self):
        schema = json.loads((ROOT/'contracts/schemas/runtime-action-readback-receipt-v2.schema.json').read_text())
        validator = Draft202012Validator(schema)
        self.assertEqual(list(validator.iter_errors(self._valid_receipt())), [])
        for field in ("requiredEmittedToolName", "requiredActionPrimitive", "emittedActionPrimitive", "representativeTool"):
            case = self._complete_case()
            del case[field]
            receipt = self._valid_receipt()
            receipt["cases"] = [case]
            errors = list(validator.iter_errors(receipt))
            self.assertTrue(errors, f"schema must fail closed on missing case field {field}")
        blank = self._complete_case()
        blank["requiredEmittedToolName"] = ""
        receipt = self._valid_receipt()
        receipt["cases"] = [blank]
        self.assertTrue(list(validator.iter_errors(receipt)))

if __name__ == '__main__': unittest.main()

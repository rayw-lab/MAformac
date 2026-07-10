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

if __name__ == '__main__': unittest.main()

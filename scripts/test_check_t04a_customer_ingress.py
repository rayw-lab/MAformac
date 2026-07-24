#!/usr/bin/env python3
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class T04aCustomerIngressSourceTests(unittest.TestCase):
    def test_customer_callbacks_use_one_ingress_and_forbid_mock_or_runner_binding(self):
        source = (ROOT / "App/ContentView.swift").read_text(encoding="utf-8")
        start = source.index("    private func submitCustomerMicDock()")
        end = source.index("\n    private func applyMockVoiceColdIntent()", start)
        body = source[start:end]
        self.assertIn("submitCustomerIngress", body)
        self.assertNotIn("applyMockVoiceColdIntent", body)
        self.assertNotIn("MockVoicePresetPlanner", body)
        self.assertNotIn("defaultRunner", source)
        self.assertNotIn("DDomainToolPlanBackend", source)

    def test_owner_files_remain_outside_t04a_change(self):
        forbidden = (
            "Core/Presentation/FrontstageRouteReceipt.swift",
            "MAformacIOSUITests/FrontstageRouteUITests.swift",
            "contracts/schemas/frontstage-route-receipt.schema.json",
            "Tools/checks/check_frontstage_route_receipt.py",
        )
        for relative in forbidden:
            self.assertTrue((ROOT / relative).is_file(), relative)


if __name__ == "__main__":
    unittest.main()

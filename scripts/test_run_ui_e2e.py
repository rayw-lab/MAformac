#!/usr/bin/env python3
import unittest

from scripts.run_ui_e2e import validate_xcresult_summary


class UIE2ESummaryGateTests(unittest.TestCase):
    def assert_gate(self, payload, expected):
        passed, _reason, _summary = validate_xcresult_summary(payload)
        self.assertEqual(passed, expected)

    def test_passed_summary(self):
        self.assert_gate(
            {"totalTestCount": 3, "failedTests": 0, "skippedTests": 0, "result": "Passed"},
            True,
        )

    def test_zero_tests_fail_closed(self):
        self.assert_gate(
            {"totalTestCount": 0, "failedTests": 0, "skippedTests": 0, "result": "Passed"},
            False,
        )

    def test_skipped_tests_fail_closed(self):
        self.assert_gate(
            {"totalTestCount": 3, "failedTests": 0, "skippedTests": 1, "result": "Passed"},
            False,
        )

    def test_failed_tests_fail_closed(self):
        self.assert_gate(
            {"totalTestCount": 3, "failedTests": 1, "skippedTests": 0, "result": "Passed"},
            False,
        )

    def test_nonpassed_result_fail_closed(self):
        self.assert_gate(
            {"totalTestCount": 3, "failedTests": 0, "skippedTests": 0, "result": "Failed"},
            False,
        )

    def test_missing_field_fail_closed(self):
        self.assert_gate(
            {"totalTestCount": 3, "failedTests": 0, "result": "Passed"},
            False,
        )


if __name__ == "__main__":
    unittest.main()

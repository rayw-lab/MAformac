#!/usr/bin/env python3
"""Validate an XCUITest xcresult summary without fail-open parsing."""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from typing import Any


def _value(value: Any) -> Any:
    if isinstance(value, dict) and "_value" in value:
        return value["_value"]
    return value

def _number(value: Any) -> int | None:
    value = _value(value)
    if isinstance(value, bool):
        return None
    if isinstance(value, (int, float)) and int(value) == value:
        return int(value)
    if isinstance(value, str) and value.strip().isdigit():
        return int(value.strip())
    return None


def _first_number(data: dict[str, Any], *names: str) -> int | None:
    for name in names:
        if name in data:
            result = _number(data[name])
            if result is not None:
                return result
    return None


def parse_xcresult_summary(data: dict[str, Any]) -> dict[str, Any]:
    """Normalize xcresulttool JSON into the fields enforced by this gate.

    Supports the current ``get test-results summary`` shape and the legacy
    ``get object`` action metrics shape. Missing or malformed fields remain
    ``None`` so validation fails closed.
    """
    if not isinstance(data, dict):
        return {"tests": None, "failed": None, "skipped": None, "result": None}

    # Current xcresulttool summary has these fields at the top level (possibly
    # wrapped in ``_value``). Keep aliases for older Xcode output.
    tests = _first_number(data, "totalTestCount", "testsCount", "total")
    failed = _first_number(data, "failedTests", "failed")
    skipped = _first_number(data, "skippedTests", "skipped")
    result = _value(data.get("result", data.get("status")))

    # Legacy object output nests metrics under actions._values.
    actions = data.get("actions")
    values = actions.get("_values") if isinstance(actions, dict) else None
    if isinstance(values, list):
        totals = {"tests": 0, "failed": 0, "skipped": 0}
        found = {key: False for key in totals}
        for action in values:
            if not isinstance(action, dict):
                continue
            action_result = action.get("actionResult")
            if not isinstance(action_result, dict):
                continue
            metrics = action_result.get("metrics")
            if not isinstance(metrics, dict):
                continue
            aliases = {
                "tests": ("testsCount", "totalTestCount"),
                "failed": ("failedTests",),
                "skipped": ("skippedTests",),
            }
            for key, names in aliases.items():
                number = _first_number(metrics, *names)
                if number is not None:
                    totals[key] += number
                    found[key] = True
            if result is None:
                result = _value(action_result.get("result", action_result.get("status")))
        if tests is None and found["tests"]:
            tests = totals["tests"]
        if failed is None and found["failed"]:
            failed = totals["failed"]
        if skipped is None and found["skipped"]:
            skipped = totals["skipped"]

    return {"tests": tests, "failed": failed, "skipped": skipped, "result": result}


def validate_xcresult_summary(data: dict[str, Any]) -> tuple[bool, str, dict[str, Any]]:
    summary = parse_xcresult_summary(data)
    if summary["tests"] is None or summary["tests"] <= 0:
        return False, "target test count must be > 0", summary
    if summary["failed"] is None or summary["failed"] != 0:
        return False, "failedTests must be 0", summary
    if summary["skipped"] is None or summary["skipped"] != 0:
        return False, "skippedTests must be 0", summary
    if not isinstance(summary["result"], str) or summary["result"].strip().lower() != "passed":
        return False, "result/status must be Passed", summary
    return True, "passed", summary


def _load_summary(args: argparse.Namespace) -> dict[str, Any]:
    if args.xcresult:
        command = ["xcrun", "xcresulttool", "get", "test-results", "summary", "--path", args.xcresult, "--format", "json"]
        completed = subprocess.run(command, check=True, capture_output=True, text=True)
        return json.loads(completed.stdout)
    return json.load(sys.stdin)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--xcresult", help="xcresult bundle to query with xcrun")
    args = parser.parse_args(argv)
    try:
        data = _load_summary(args)
        passed, reason, summary = validate_xcresult_summary(data)
    except (OSError, subprocess.CalledProcessError, json.JSONDecodeError) as exc:
        print(f"FAIL: unable to parse xcresult summary: {exc}", file=sys.stderr)
        return 1
    print(f"UI E2E summary: tests={summary['tests']} failedTests={summary['failed']} skippedTests={summary['skipped']} result={summary['result']}")
    if not passed:
        print(f"FAIL: {reason}", file=sys.stderr)
        return 1
    print("PASS: xcresult summary proves passed UI tests")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

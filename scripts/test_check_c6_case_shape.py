#!/usr/bin/env python3
"""Regression tests for C6 source-free case-shape guardrails."""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
from copy import deepcopy
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
CHECKER = REPO_ROOT / "scripts" / "check_c6_case_shape.py"


def base_row() -> dict:
    return {
        "case_id": "C6-SHAPE-FIXTURE-001",
        "behavior_class": "tool_call",
        "source_refs": {
            "semantic_contract_ids": ["c1_fixture"],
            "state_cell_ids": ["ac.power"],
            "scenario_ids": ["scene1"],
            "risk_rule_ids": [],
        },
        "tags": {
            "bucket": "action",
            "must_pass": True,
            "must_not_train": True,
            "contract_device": "fixture",
            "scenario_id": "scene1",
            "sample_kind": "fixture",
        },
        "pre_state": {"ac.power": "off"},
        "input_zh": "打开空调",
        "expected_tool_calls": [{"name": "open_ac", "arguments": {}}],
        "expect_no_call": False,
        "expected_state_delta": {"ac.power": "on"},
        "readback_assertion": {"contains": ["空调"]},
        "clarify_tag": "implicit",
        "failure_class": "none",
        "alternatives": [],
    }


def run_checker(row: dict) -> subprocess.CompletedProcess[str]:
    with tempfile.TemporaryDirectory(prefix="c6-shape-test-") as tmp:
        tmp_path = Path(tmp)
        jsonl = tmp_path / "cases.jsonl"
        catalog = tmp_path / "catalog.json"
        jsonl.write_text(json.dumps(row, ensure_ascii=False) + "\n", encoding="utf-8")
        catalog.write_text(
            json.dumps([{"function": {"name": "open_ac"}}], ensure_ascii=False),
            encoding="utf-8",
        )
        return subprocess.run(
            [sys.executable, str(CHECKER), str(jsonl), str(catalog)],
            capture_output=True,
            text=True,
            check=False,
        )


def expect_pass(name: str, row: dict, failures: list[str], stdout_needles: list[str] | None = None) -> None:
    result = run_checker(row)
    if result.returncode != 0:
        failures.append(f"{name}: expected pass, got rc={result.returncode} stderr={result.stderr!r}")
    if "shape_diagnostic_candidate_counts=" not in result.stdout:
        failures.append(f"{name}: missing diagnostic candidate counts output")
    if "external_layer_candidate_counts=" in result.stdout:
        failures.append(f"{name}: emitted legacy external_layer_candidate_counts field")
    for needle in stdout_needles or []:
        if needle not in result.stdout:
            failures.append(f"{name}: expected stdout to contain {needle!r}, got {result.stdout!r}")


def expect_fail(name: str, row: dict, needle: str, failures: list[str]) -> None:
    result = run_checker(row)
    if result.returncode == 0:
        failures.append(f"{name}: expected failure, got pass stdout={result.stdout!r}")
    if needle not in result.stderr:
        failures.append(f"{name}: expected stderr to contain {needle!r}, got {result.stderr!r}")


def main() -> int:
    failures: list[str] = []

    valid = base_row()
    expect_pass("valid tool_call row", valid, failures)

    no_call_false = deepcopy(valid)
    no_call_false.update(
        {
            "behavior_class": "refusal_no_available_tool",
            "expected_tool_calls": [],
            "expect_no_call": False,
            "expected_state_delta": {},
            "readback_assertion": {"contains": []},
            "clarify_tag": "rejected",
            "failure_class": "refusal",
        }
    )
    expect_fail(
        "no-call behavior requires expect_no_call",
        no_call_false,
        "requires expect_no_call=true",
        failures,
    )

    tool_call_true = deepcopy(valid)
    tool_call_true["expect_no_call"] = True
    expect_fail(
        "tool_call rejects expect_no_call",
        tool_call_true,
        "tool_call requires expect_no_call=false",
        failures,
    )

    non_boolean_flag = deepcopy(valid)
    non_boolean_flag["expect_no_call"] = "false"
    expect_fail(
        "expect_no_call must be boolean",
        non_boolean_flag,
        "expect_no_call must be boolean",
        failures,
    )

    direct_no_call = deepcopy(valid)
    direct_no_call["behavior_class"] = "direct_no_call"
    direct_no_call["expected_tool_calls"] = []
    direct_no_call["expect_no_call"] = True
    expect_fail(
        "direct_no_call remains forbidden",
        direct_no_call,
        "direct_no_call is forbidden",
        failures,
    )

    unknown_tool = deepcopy(valid)
    unknown_tool["expected_tool_calls"] = [{"name": "missing_tool", "arguments": {}}]
    expect_fail(
        "unknown expected tool is rejected",
        unknown_tool,
        "unknown expected_tool_calls name",
        failures,
    )

    already_state_mismatch = deepcopy(valid)
    already_state_mismatch.update(
        {
            "behavior_class": "already_state_noop",
            "expected_tool_calls": [],
            "expect_no_call": True,
            "pre_state": {"ac.power": "off"},
            "expected_state_delta": {"ac.power": "on"},
            "readback_assertion": {"contains": ["已是"]},
        }
    )
    expect_fail(
        "already_state_noop requires pre_state match",
        already_state_mismatch,
        "already_state_noop requires pre_state",
        failures,
    )

    safety_missing_risk = deepcopy(valid)
    safety_missing_risk.update(
        {
            "behavior_class": "refusal_safety_or_policy",
            "expected_tool_calls": [],
            "expect_no_call": True,
            "expected_state_delta": {},
            "readback_assertion": {"contains": ["不能"]},
            "clarify_tag": "rejected",
        }
    )
    expect_fail(
        "safety refusal requires risk ids",
        safety_missing_risk,
        "requires nonempty source_refs.risk_rule_ids",
        failures,
    )

    clarify_wrong_tag = deepcopy(valid)
    clarify_wrong_tag.update(
        {
            "behavior_class": "clarify_missing_slot",
            "expected_tool_calls": [],
            "expect_no_call": True,
            "expected_state_delta": {},
            "readback_assertion": {"contains": ["哪个"]},
            "clarify_tag": "implicit",
        }
    )
    expect_fail(
        "clarify row requires explicit ambiguous tag",
        clarify_wrong_tag,
        "clarify_missing_slot requires clarify_tag",
        failures,
    )

    coverage_row = deepcopy(valid)
    coverage_row.update(
        {
            "behavior_class": "clarify_missing_slot",
            "expected_tool_calls": [],
            "expect_no_call": True,
            "expected_state_delta": {},
            "readback_assertion": {"contains": ["哪个"]},
            "clarify_tag": "ambiguous",
            "tags": {
                **coverage_row["tags"],
                "bucket": "coverage",
                "sample_kind": "coverage-fuzz-fixture",
                "must_pass": False,
            },
        }
    )
    expect_pass(
        "coverage/fuzz rows stay out of golden diagnostic bucket",
        coverage_row,
        failures,
        stdout_needles=['"demo_fuzz": 1'],
    )

    unknown_alternative_tool = deepcopy(valid)
    unknown_alternative_tool["alternatives"] = [
        {"expected_tool_calls": [{"name": "missing_alt_tool", "arguments": {}}]}
    ]
    expect_fail(
        "unknown alternative expected tool is rejected",
        unknown_alternative_tool,
        "unknown alternative expected_tool_calls name",
        failures,
    )

    if failures:
        print("test_check_c6_case_shape FAILED", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1

    print("test_check_c6_case_shape=ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

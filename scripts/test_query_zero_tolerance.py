#!/usr/bin/env python3
"""Regression tests for check_query_zero_tolerance.py."""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
CHECKER = REPO_ROOT / "scripts" / "check_query_zero_tolerance.py"
CONTRACT = REPO_ROOT / "contracts" / "semantic-function-contract.jsonl"
R5_ROOT = Path("/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness")
HARDENED_JSONS = [
    ("r2b", R5_ROOT / "TD-eval-run155204-ready/query-zero-tolerance-hardened-r2b.json"),
    ("r3", R5_ROOT / "TD-eval-r3train-ready/query-zero-tolerance-hardened-r3.json"),
    ("r4", R5_ROOT / "TD-eval-r4train-ready/query-zero-tolerance-hardened-r4.json"),
]


def write_json(path: Path, value: object) -> None:
    path.write_text(json.dumps(value, ensure_ascii=False, sort_keys=True) + "\n", encoding="utf-8")


def main() -> int:
    failures: list[str] = []
    with tempfile.TemporaryDirectory(prefix="query-zero-test-") as tmp:
        root = Path(tmp)
        contract = root / "contract.jsonl"
        contract.write_text(
            "\n".join(
                json.dumps(row, ensure_ascii=False)
                for row in [
                    {"intent": "open_window"},
                    {"intent": "query_current_volume"},
                ]
            )
            + "\n",
            encoding="utf-8",
        )
        cases = root / "cases.jsonl"
        case_rows = [
            {
                "case_id": "Q-INVALID",
                "input_zh": "现在音量是多少",
                "expected_tool_calls": [],
                "tags": {"query_role": "query", "zero_tolerance": True, "query_behavior": "query_absent_no_call"},
                "tools": [{"function": {"name": "open_window"}}],
            },
            {
                "case_id": "Q-ACTUATION",
                "input_zh": "主驾车窗现在开了吗",
                "expected_tool_calls": [],
                "tags": {"query_role": "query", "zero_tolerance": True, "query_behavior": "query_absent_no_call"},
                "tools": [{"function": {"name": "open_window"}}],
            },
            {
                "case_id": "Q-EXPECTED-ACTUATION",
                "input_zh": "现在音量是多少",
                "expected_tool_calls": [{"name": "query_current_volume", "arguments": {}}],
                "tools": [{"function": {"name": "open_window"}}],
            },
            {
                "case_id": "Q-OK",
                "input_zh": "氛围灯现在开着吗",
                "expected_tool_calls": [],
                "tags": {"query_role": "query", "zero_tolerance": True, "query_behavior": "query_absent_no_call"},
            },
        ]
        cases.write_text("\n".join(json.dumps(row, ensure_ascii=False) for row in case_rows) + "\n", encoding="utf-8")
        probes = root / "probes"
        probes.mkdir()
        write_json(probes / "1-Q-INVALID.json", {"case_id": "Q-INVALID", "observed_tool_names": ["query_volume"]})
        write_json(probes / "2-Q-ACTUATION.json", {"case_id": "Q-ACTUATION", "observed_tool_names": ["open_window"]})
        write_json(
            probes / "3-Q-EXPECTED-ACTUATION.json",
            {"case_id": "Q-EXPECTED-ACTUATION", "observed_tool_names": ["open_window"]},
        )
        write_json(probes / "4-Q-OK.json", {"case_id": "Q-OK", "observed_tool_names": []})
        out_json = root / "out.json"

        result = subprocess.run(
            [
                sys.executable,
                str(CHECKER),
                "--contract-jsonl",
                str(contract),
                "--scan",
                f"fixture|adapter|{cases}|{probes}",
                "--out-json",
                str(out_json),
                "--allow-fail-exit-zero",
            ],
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode != 0:
            failures.append(f"allow-fail run returned {result.returncode}: {result.stderr}")
        payload = json.loads(out_json.read_text(encoding="utf-8"))
        summary = payload["summary"]
        expected_counts = {
            "total_failure_count": 3,
            "any_tool_call_fail": 2,
            "actuation_fail": 1,
            "invalid_fail": 1,
            "query_expected_actuation": 1,
        }
        for key, expected in expected_counts.items():
            if summary.get(key) != expected:
                failures.append(f"{key}: expected {expected}, got {summary.get(key)}")

        strict = subprocess.run(
            [
                sys.executable,
                str(CHECKER),
                "--contract-jsonl",
                str(contract),
                "--scan",
                f"fixture|adapter|{cases}|{probes}",
            ],
            capture_output=True,
            text=True,
            check=False,
        )
        if strict.returncode != 67:
            failures.append(f"strict run expected rc=67, got {strict.returncode}")

        non_query_cases = root / "non-query-cases.jsonl"
        non_query_probes = root / "non-query-probes"
        non_query_probes.mkdir()
        non_query_cases.write_text(
            json.dumps(
                {
                    "case_id": "NON-QUERY",
                    "input_zh": "打开车窗",
                    "expected_tool_calls": [{"name": "open_window", "arguments": {}}],
                    "tags": {"query_role": "action"},
                    "tools": [{"function": {"name": "open_window"}}],
                },
                ensure_ascii=False,
            )
            + "\n",
            encoding="utf-8",
        )
        write_json(
            non_query_probes / "NON-QUERY.json",
            {
                "case_id": "NON-QUERY",
                "expected_tool_calls": [{"name": "open_window", "arguments": {}}],
                "observed_tool_names": ["open_window"],
                "mounted_tool_names": ["open_window"],
            },
        )
        zero_out = root / "zero-coverage.json"
        zero = subprocess.run(
            [
                sys.executable,
                str(CHECKER),
                "--contract-jsonl",
                str(contract),
                "--scan",
                f"fixture|adapter|{non_query_cases}|{non_query_probes}",
                "--out-json",
                str(zero_out),
            ],
            capture_output=True,
            text=True,
            check=False,
        )
        if zero.returncode != 65:
            failures.append(f"zero-coverage run expected rc=65, got {zero.returncode}: {zero.stderr}")
        else:
            zero_payload = json.loads(zero_out.read_text(encoding="utf-8"))
            if zero_payload.get("coverage_error_reason") != "zero_scanned_records":
                failures.append(f"zero-coverage reason mismatch: {zero_payload.get('coverage_error_reason')}")

    observed: list[int] = []
    with tempfile.TemporaryDirectory(prefix="query-zero-r5-regression-") as tmp:
        root = Path(tmp)
        for label, hardened_path in HARDENED_JSONS:
            if not hardened_path.exists():
                failures.append(f"missing hardened regression artifact: {hardened_path}")
                continue
            hardened = json.loads(hardened_path.read_text(encoding="utf-8"))
            out_json = root / f"{label}.json"
            cmd = [
                sys.executable,
                str(CHECKER),
                "--contract-jsonl",
                str(CONTRACT),
                "--out-json",
                str(out_json),
                "--allow-fail-exit-zero",
            ]
            for item in hardened["inputs"]:
                cmd.extend(["--scan", "|".join([item["track"], item["arm"], item["case_jsonl"], item["probe_dir"]])])
            result = subprocess.run(cmd, capture_output=True, text=True, check=False)
            if result.returncode != 0:
                failures.append(f"{label} 9/9/9 regression returned {result.returncode}: {result.stderr}")
                continue
            payload = json.loads(out_json.read_text(encoding="utf-8"))
            observed.append(payload["summary"]["by_arm"]["adapter"]["any_tool_call_fail"])
            if payload.get("coverage_error"):
                failures.append(f"{label} unexpectedly had coverage_error")
            if payload.get("rule", {}).get("fail_exit_code") != 67:
                failures.append(f"{label} fail_exit_code expected 67, got {payload.get('rule', {}).get('fail_exit_code')}")
        if observed and observed != [9, 9, 9]:
            failures.append(f"R2b/R3/R4 adapter any_tool_call_fail expected [9, 9, 9], got {observed}")

    if failures:
        print("test_query_zero_tolerance FAILED", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1
    print("test_query_zero_tolerance=ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

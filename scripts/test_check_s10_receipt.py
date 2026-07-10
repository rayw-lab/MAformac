#!/usr/bin/env python3
"""TDD regression suite for the source-free S10 receipt fixture checker."""

from __future__ import annotations

import json
import subprocess
import sys
from copy import deepcopy
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
CHECKER = REPO_ROOT / "scripts" / "check_s10_receipt.py"
SCHEMA = REPO_ROOT / "contracts" / "schemas" / "s10-receipt.schema.json"
FIXTURES = REPO_ROOT / "Tools" / "checks" / "fixtures" / "s10"
EXPECTED_RUN_ID = "s10-fixture-current"


def load_fixture(name: str) -> dict:
    return json.loads((FIXTURES / name).read_text(encoding="utf-8"))


def run_checker(name: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [
            sys.executable,
            str(CHECKER),
            str(FIXTURES / name),
            "--schema",
            str(SCHEMA),
            "--expected-run-id",
            EXPECTED_RUN_ID,
        ],
        capture_output=True,
        text=True,
        check=False,
    )


def output_json(result: subprocess.CompletedProcess[str]) -> dict:
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as exc:
        raise AssertionError(f"checker stdout is not JSON: {result.stdout!r}; stderr={result.stderr!r}") from exc


def error_codes(payload: dict) -> set[str]:
    return {str(item.get("code")) for item in payload.get("errors", [])}


def expect_pass(name: str, expected_joint: float, failures: list[str]) -> None:
    result = run_checker(name)
    if result.returncode != 0:
        failures.append(f"{name}: expected rc=0, got rc={result.returncode}: {result.stderr!r} {result.stdout!r}")
        return
    payload = output_json(result)
    if payload.get("status") != "PASS":
        failures.append(f"{name}: expected PASS, got {payload!r}")
    if payload.get("joint_strike_rate") != expected_joint:
        failures.append(f"{name}: expected joint={expected_joint}, got {payload.get('joint_strike_rate')!r}")
    tier = payload.get("tier_decision", {})
    if tier != {
        "tier": "no_expand_lt_40",
        "mounted_expansion_allowed": False,
        "planned_family_count": 0,
    }:
        failures.append(f"{name}: unexpected tier {tier!r}")
    if payload.get("s10_executed") is not False:
        failures.append(f"{name}: fixture proof must keep s10_executed=false")


def expect_blocked(name: str, required_codes: set[str], failures: list[str]) -> None:
    result = run_checker(name)
    if result.returncode != 65:
        failures.append(f"{name}: expected rc=65, got rc={result.returncode}: {result.stderr!r} {result.stdout!r}")
        return
    payload = output_json(result)
    if payload.get("status") != "BLOCKED":
        failures.append(f"{name}: expected BLOCKED, got {payload!r}")
    missing = required_codes - error_codes(payload)
    if missing:
        failures.append(f"{name}: missing error codes {sorted(missing)} in {payload!r}")
    if payload.get("zero_runtime_decision") is not False:
        failures.append(f"{name}: BLOCKED output must set zero_runtime_decision=false")


def main() -> int:
    failures: list[str] = []

    if not CHECKER.is_file():
        failures.append(f"missing checker: {CHECKER}")
    if not SCHEMA.is_file():
        failures.append(f"missing schema: {SCHEMA}")
    if failures:
        for failure in failures:
            print(failure, file=sys.stderr)
        return 1

    schema = json.loads(SCHEMA.read_text(encoding="utf-8"))
    if schema.get("$schema") != "https://json-schema.org/draft/2020-12/schema":
        failures.append("schema must declare JSON Schema draft 2020-12")
    if schema.get("additionalProperties") is not False:
        failures.append("schema top level must set additionalProperties=false")
    if "joint_strike_rate" not in schema.get("required", []):
        failures.append("schema must require joint_strike_rate")

    expect_pass("pass.json", 0.35, failures)
    expect_pass("counterexample-can-question-high.json", 0.35, failures)
    expect_blocked("missing-field.json", {"joint_rate_missing"}, failures)
    expect_blocked("prose-only.json", {"joint_rate_missing", "prose_only_substitute"}, failures)
    expect_blocked("stale-run-id.json", {"stale_run_id"}, failures)
    expect_blocked("wrong-min-formula.json", {"joint_rate_mismatch"}, failures)
    expect_blocked("zero-denominator.json", {"zero_denominator"}, failures)

    prose = load_fixture("prose-only.json")
    for field, code in (
        ("primary_pass_rate", "primary_pass_rate_substitute"),
        ("overall_pass_rate", "overall_pass_rate_substitute"),
    ):
        candidate = deepcopy(prose)
        candidate[field] = 0.82
        fixture_path = FIXTURES / f".{field}-generated-test.json"
        fixture_path.write_text(json.dumps(candidate, ensure_ascii=False), encoding="utf-8")
        try:
            result = subprocess.run(
                [
                    sys.executable,
                    str(CHECKER),
                    str(fixture_path),
                    "--schema",
                    str(SCHEMA),
                    "--expected-run-id",
                    EXPECTED_RUN_ID,
                ],
                capture_output=True,
                text=True,
                check=False,
            )
            if result.returncode != 65:
                failures.append(f"{field}: expected rc=65, got {result.returncode}")
            else:
                payload = output_json(result)
                expected = {"joint_rate_missing", "prose_only_substitute", code}
                missing = expected - error_codes(payload)
                if missing:
                    failures.append(f"{field}: missing error codes {sorted(missing)}")
        finally:
            fixture_path.unlink(missing_ok=True)

    if failures:
        for failure in failures:
            print(failure, file=sys.stderr)
        return 1
    print("PASS: S10 receipt checker fixtures enforce CG-048/049/050 and Q-SR=A")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

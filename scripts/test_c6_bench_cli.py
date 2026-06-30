#!/usr/bin/env python3
"""Regression tests for C6BenchCLI source-free summarize guardrails."""

from __future__ import annotations

import json
import subprocess
import tempfile
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]


def first_case() -> dict:
    for raw in (REPO_ROOT / "contracts" / "c6-bench-cases.jsonl").read_text(encoding="utf-8").splitlines():
        if raw.strip():
            return json.loads(raw)
    raise AssertionError("contracts/c6-bench-cases.jsonl has no rows")


def result_for(case_id: str, tool_calls: list[dict] | None = None) -> dict:
    return {
        "id": case_id,
        "runIndex": 0,
        "toolCalls": tool_calls or [],
        "chunkText": "",
        "contentLooksLikeToolCall": False,
        "thinkLeak": False,
        "elapsedMs": 1,
    }


def run_summarize(results: list[dict]) -> subprocess.CompletedProcess[str]:
    with tempfile.TemporaryDirectory(prefix="c6-cli-test-") as tmp:
        tmp_path = Path(tmp)
        model_results = tmp_path / "spike-e3-results.json"
        model_artifact = tmp_path / "model.bin"
        tokenizer_artifact = tmp_path / "tokenizer.json"
        output_dir = tmp_path / "out"
        model_results.write_text(
            json.dumps({"modelID": "fixture-model", "results": results}, ensure_ascii=False),
            encoding="utf-8",
        )
        model_artifact.write_text("fixture-model", encoding="utf-8")
        tokenizer_artifact.write_text("fixture-tokenizer", encoding="utf-8")
        return subprocess.run(
            [
                "swift",
                "run",
                "C6BenchCLI",
                "summarize",
                "--repo-root",
                str(REPO_ROOT),
                "--model-results",
                str(model_results),
                "--model-artifact",
                str(model_artifact),
                "--tokenizer-artifact",
                str(tokenizer_artifact),
                "--output-dir",
                str(output_dir),
            ],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            check=False,
        )


def expect_fail(
    name: str,
    result: subprocess.CompletedProcess[str],
    needle: str,
    failures: list[str],
) -> None:
    combined = result.stdout + result.stderr
    if result.returncode == 0:
        failures.append(f"{name}: expected failure, got stdout={result.stdout!r}")
    if needle not in combined:
        failures.append(f"{name}: expected output to contain {needle!r}, got {combined!r}")


def main() -> int:
    failures: list[str] = []
    case = first_case()
    expected_tool_calls = case.get("expected_tool_calls", [])

    expect_fail(
        "unknown result id fails closed",
        run_summarize([result_for("C6-UNKNOWN-FIXTURE")]),
        "summarize unknown result ids",
        failures,
    )
    expect_fail(
        "missing expected case coverage fails closed",
        run_summarize([result_for(case["case_id"], expected_tool_calls)]),
        "summarize missing model results for case ids",
        failures,
    )

    if failures:
        print("test_c6_bench_cli FAILED")
        for failure in failures:
            print(f"  - {failure}")
        return 1
    print("test_c6_bench_cli=ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

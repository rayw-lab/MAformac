#!/usr/bin/env python3
"""Regression test: verify-ci must fail when a required checker is deleted."""

from __future__ import annotations

import subprocess
import sys
import tempfile
import re
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT))
from Tools.checks.check_runtime_finite_reason_authority import (  # noqa: E402
    mask_swift_comments,
    mask_swift_strings,
)

MAKEFILE = REPO_ROOT / "Makefile"
CHECKER_PATHS = (
    Path("Tools/checks/check_c1_ownership_map.py"),
    Path("Tools/checks/check_runtime_finite_reason_authority.py"),
    Path("Tools/checks/run_swift_test_exact.py"),
    Path("Tools/checks/check_fallback_scripts.py"),
    Path("Tools/checks/check_action_demo_proven_legacy_tokens.py"),
    Path("Tools/checks/check_int_v5a_execution_receipt.py"),
    Path("scripts/check_s10_receipt.py"),
    Path("scripts/check_closure_work_packages.py"),
    Path("contracts/closure-work-packages.v1.yaml"),
    Path("contracts/schemas/closure-work-packages.v1.schema.json"),
    Path("contracts/schemas/closure-status-transition-receipt.v1.schema.json"),
    Path("contracts/schemas/closure-package-exit-envelope.v1.schema.json"),
    Path("contracts/schemas/closure-gate-receipt.v1.schema.json"),
    Path("contracts/closure-execution-window.v1.yaml"),
    Path("Tests/test_closure_work_packages.py"),
)
MISSING_MARKER = "ERROR_MISSING_C1_CHECKER"
OWNERSHIP_TARGET = "verify-c1-ownership"
OWNERSHIP_SUITE = "scripts/test_check_c1_ownership_map.py"
OWNERSHIP_CHECKER = "Tools/checks/check_c1_ownership_map.py"
RUNTIME_REASON_TARGET = "verify-c1-finite-reason-authority"
RUNTIME_REASON_SUITE = "scripts/test_check_runtime_finite_reason_authority.py"
RUNTIME_REASON_CHECKER = "Tools/checks/check_runtime_finite_reason_authority.py"
EXACT_RUNNER = "Tools/checks/run_swift_test_exact.py"
EXACT_RUNNER_SUITE = "scripts/test_run_swift_test_exact.py"
BEHAVIOR_TEST_SOURCE = REPO_ROOT / "Tests/MAformacCoreTests/RuntimeFiniteReasonAuthorityTests.swift"
BEHAVIOR_GATE_METHODS = (
    "testFallbackResolutionMatchesHardcodedTenReasonScriptTable",
    "testTraceRoundTripsHardcodedTenFiniteReasonsEndToEnd",
    "testDiagnosticFailuresTraverseProductionRunnerAndRedactPresentationTrace",
)
EXACT_FILTERS = tuple(
    f"RuntimeFiniteReasonAuthorityTests/{method}" for method in BEHAVIOR_GATE_METHODS
)
# Full typed authority suite (min-count mode) + one exact runner per behavior gate method.
FULL_SUITE_FILTER = "--filter RuntimeFiniteReasonAuthorityTests --min-count 1"
EXACT_RUNNER_INVOCATION_COUNT = len(BEHAVIOR_GATE_METHODS) + 1


def missing_behavior_gate_declarations(source: str) -> list[str]:
    source = mask_swift_strings(mask_swift_comments(source))
    return [
        method
        for method in BEHAVIOR_GATE_METHODS
        if re.search(rf"(?m)^[ \t]*func[ \t]+{re.escape(method)}[ \t]*\(", source) is None
    ]


def test_verify_ci_fails_when_a_checker_is_deleted() -> None:
    makefile_text = MAKEFILE.read_text(encoding="utf-8")
    makefile_lines = makefile_text.splitlines()
    verify_line = next(line for line in makefile_lines if line.startswith("verify:"))
    verify_ci_line = next(line for line in makefile_lines if line.startswith("verify-ci:"))
    assert OWNERSHIP_TARGET in verify_line, verify_line
    assert OWNERSHIP_TARGET in verify_ci_line, verify_ci_line
    assert RUNTIME_REASON_TARGET in verify_line, verify_line
    assert RUNTIME_REASON_TARGET in verify_ci_line, verify_ci_line
    assert "verify-c1-checker-files" in verify_ci_line, verify_ci_line

    ownership_start = makefile_text.index(f"{OWNERSHIP_TARGET}:")
    ownership_end = makefile_text.find("\n\n", ownership_start)
    ownership_block = makefile_text[
        ownership_start : ownership_end if ownership_end >= 0 else None
    ]
    assert OWNERSHIP_SUITE in ownership_block, ownership_block
    assert OWNERSHIP_CHECKER in ownership_block, ownership_block

    runtime_reason_start = makefile_text.index(f"{RUNTIME_REASON_TARGET}:")
    runtime_reason_end = makefile_text.find("\n\n", runtime_reason_start)
    runtime_reason_block = makefile_text[
        runtime_reason_start : runtime_reason_end if runtime_reason_end >= 0 else None
    ]
    assert RUNTIME_REASON_SUITE in runtime_reason_block, runtime_reason_block
    assert RUNTIME_REASON_CHECKER in runtime_reason_block, runtime_reason_block
    assert EXACT_RUNNER_SUITE in runtime_reason_block, runtime_reason_block
    assert (
        runtime_reason_block.count(EXACT_RUNNER) == EXACT_RUNNER_INVOCATION_COUNT
    ), runtime_reason_block
    assert FULL_SUITE_FILTER in runtime_reason_block, runtime_reason_block
    for exact_filter in EXACT_FILTERS:
        assert f"--filter {exact_filter}" in runtime_reason_block, runtime_reason_block

    behavior_source = BEHAVIOR_TEST_SOURCE.read_text(encoding="utf-8")
    assert missing_behavior_gate_declarations(behavior_source) == []
    for method in BEHAVIOR_GATE_METHODS:
        renamed = behavior_source.replace(
            f"    func {method}(",
            f"    func helper{method}(",
            1,
        )
        deleted = behavior_source.replace(
            f"    func {method}(",
            "    // deleted behavior gate declaration(",
            1,
        )
        block_commented = behavior_source.replace(
            f"    func {method}(",
            f"    /*\n    func {method}(\n    */",
            1,
        )
        assert method in missing_behavior_gate_declarations(renamed), method
        assert method in missing_behavior_gate_declarations(deleted), method
        assert method in missing_behavior_gate_declarations(block_commented), method

    exact_runner_text = (REPO_ROOT / EXACT_RUNNER).read_text(encoding="utf-8")
    assert "E_SWIFT_EXACT_TEST_ZERO" in exact_runner_text
    assert "E_SWIFT_EXACT_TEST_COUNT" in exact_runner_text

    for missing_relative in CHECKER_PATHS:
        with tempfile.TemporaryDirectory(prefix="verify-ci-checkers-") as tmp:
            temp_repo = Path(tmp)
            checker_paths = [temp_repo / relative for relative in CHECKER_PATHS]
            for path in checker_paths:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("# test sentinel\n", encoding="utf-8")

            present_result = subprocess.run(
                [
                    "make",
                    "--no-print-directory",
                    "-C",
                    str(temp_repo),
                    "-f",
                    str(MAKEFILE),
                    "verify-c1-checker-files",
                ],
                cwd=temp_repo,
                capture_output=True,
                text=True,
                check=False,
            )
            assert present_result.returncode == 0, (
                present_result.stdout + present_result.stderr
            )

            missing_path = temp_repo / missing_relative
            missing_path.unlink()

            result = subprocess.run(
                [
                    "make",
                    "--no-print-directory",
                    "-C",
                    str(temp_repo),
                    "-f",
                    str(MAKEFILE),
                    "verify-ci",
                ],
                cwd=temp_repo,
                capture_output=True,
                text=True,
                check=False,
            )
            output = result.stdout + result.stderr
            assert result.returncode != 0, (
                f"verify-ci unexpectedly passed after deleting {missing_relative}\n{output}"
            )
            assert MISSING_MARKER in output, output
            assert missing_relative.as_posix() in output, output
            print(f"PASS: deleted {missing_relative}; verify-ci rc={result.returncode}")


def main() -> int:
    try:
        test_verify_ci_fails_when_a_checker_is_deleted()
    except Exception as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    print("PASS: verify-ci fails closed when a required checker is deleted")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

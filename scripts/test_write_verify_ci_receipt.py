#!/usr/bin/env python3
"""Regression tests for generic verify-ci receipts and C1 Make wiring."""

from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
WRITER = REPO_ROOT / "Tools" / "checks" / "write_verify_ci_receipt.py"
MAKEFILE = REPO_ROOT / "Makefile"
WORKFLOW = REPO_ROOT / ".github" / "workflows" / "verify.yml"


def run_writer(change_ids: str = "") -> dict:
    with tempfile.TemporaryDirectory(prefix="verify-ci-receipt-") as tmp:
        output = Path(tmp) / "receipt.json"
        env = os.environ.copy()
        env.update(
            {
                "GITHUB_RUN_ID": "1234",
                "GITHUB_RUN_ATTEMPT": "2",
                "GITHUB_EVENT_NAME": "pull_request",
                "GITHUB_SHA": "head-sha",
                "GITHUB_BASE_REF": "main",
                "GITHUB_HEAD_REF": "codex/c1-ci",
                "GITHUB_PR_NUMBER": "17",
                "VERIFY_CI_CHANGE_IDS": change_ids,
            }
        )
        result = subprocess.run(
            [sys.executable, str(WRITER), "--output", str(output)],
            cwd=REPO_ROOT,
            env=env,
            capture_output=True,
            text=True,
            check=False,
        )
        assert result.returncode == 0, (result.stdout, result.stderr)
        return json.loads(output.read_text(encoding="utf-8"))


def test_empty_change_ids_are_truthful() -> None:
    receipt = run_writer()
    assert receipt["receipt_kind"] == "verify-ci"
    assert receipt["change_ids"] == []
    assert "change_id" not in receipt


def test_change_ids_are_deduplicated_and_sorted() -> None:
    receipt = run_writer("define-z, define-a\ndefine-z")
    assert receipt["change_ids"] == ["define-a", "define-z"]


def test_required_head_bound_fields_are_present() -> None:
    receipt = run_writer()
    required = {
        "receipt_id",
        "receipt_kind",
        "created_at",
        "change_ids",
        "proof_class",
        "event_name",
        "head_commit",
        "base_ref",
        "head_ref",
        "pull_request_number",
        "dirty_worktree",
        "commands",
        "non_claims",
    }
    assert required <= set(receipt)
    assert receipt["proof_class"] == "ci_source_free"
    assert receipt["event_name"] == "pull_request"
    assert receipt["head_commit"] == "head-sha"
    assert receipt["base_ref"] == "main"
    assert receipt["head_ref"] == "codex/c1-ci"
    assert receipt["pull_request_number"] == 17
    assert isinstance(receipt["dirty_worktree"], bool)
    assert receipt["commands"] == ["make verify-ci", "git diff --check (pull_request only)"]
    assert receipt["non_claims"]


def test_makefile_wires_only_source_free_c1_gates_into_ci() -> None:
    text = MAKEFILE.read_text(encoding="utf-8")
    verify_line = next(line for line in text.splitlines() if line.startswith("verify:"))
    verify_ci_line = next(line for line in text.splitlines() if line.startswith("verify-ci:"))
    source_free_targets = (
        "verify-c1-matrix",
        "verify-c1-fallback",
        "verify-c1-probes",
        "verify-c1-s10",
        "verify-mounted-catalog-no-delta",
    )
    for target in source_free_targets:
        assert f"{target}:" in text
        assert target in verify_line
        assert target in verify_ci_line
    assert "A1_MATRIX_MANIFEST" not in verify_ci_line


def test_workflow_uses_writer_without_hardcoded_singular_change_id() -> None:
    text = WORKFLOW.read_text(encoding="utf-8")
    assert "Tools/checks/write_verify_ci_receipt.py" in text
    assert '"change_id"' not in text
    assert "VERIFY_CI_CHANGE_IDS" in text


def main() -> int:
    tests = [
        test_empty_change_ids_are_truthful,
        test_change_ids_are_deduplicated_and_sorted,
        test_required_head_bound_fields_are_present,
        test_makefile_wires_only_source_free_c1_gates_into_ci,
        test_workflow_uses_writer_without_hardcoded_singular_change_id,
    ]
    failures: list[str] = []
    for test in tests:
        try:
            test()
        except Exception as exc:
            failures.append(f"{test.__name__}: {exc}")
    if failures:
        for failure in failures:
            print(failure, file=sys.stderr)
        return 1
    print(f"PASS: {len(tests)} verify-ci receipt/wiring tests")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

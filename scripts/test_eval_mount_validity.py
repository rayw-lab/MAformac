#!/usr/bin/env python3
"""Regression tests for check_eval_mount_validity.py."""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
CHECKER = REPO_ROOT / "scripts" / "check_eval_mount_validity.py"


def write_jsonl(path: Path, rows: list[dict]) -> None:
    path.write_text("".join(json.dumps(row, ensure_ascii=False) + "\n" for row in rows), encoding="utf-8")


def main() -> int:
    failures: list[str] = []
    with tempfile.TemporaryDirectory(prefix="mount-validity-test-") as tmp:
        root = Path(tmp)
        bad_cases = root / "bad-mount.jsonl"
        bad_report = root / "bad-report.json"
        write_jsonl(
            bad_cases,
            [
                {
                    "case_id": "bad-mount-001",
                    "expected_tool_calls": [{"name": "open_window", "arguments": {}}],
                    "mounted_tool_names": ["close_window"],
                }
            ],
        )
        bad = subprocess.run(
            [sys.executable, str(CHECKER), str(bad_cases), "--output", str(bad_report)],
            capture_output=True,
            text=True,
            check=False,
        )
        if bad.returncode != 66:
            failures.append(f"mount invalid expected rc=66, got {bad.returncode}: {bad.stderr}")
        else:
            payload = json.loads(bad_report.read_text(encoding="utf-8"))
            if payload.get("violation_count") != 1:
                failures.append(f"mount invalid violation_count expected 1, got {payload.get('violation_count')}")

        empty_cases = root / "empty.jsonl"
        empty_report = root / "empty-report.json"
        write_jsonl(empty_cases, [])
        empty = subprocess.run(
            [sys.executable, str(CHECKER), str(empty_cases), "--output", str(empty_report)],
            capture_output=True,
            text=True,
            check=False,
        )
        if empty.returncode != 65:
            failures.append(f"empty mount expected rc=65, got {empty.returncode}: {empty.stderr}")
        else:
            payload = json.loads(empty_report.read_text(encoding="utf-8"))
            if payload.get("coverage_error_reason") != "zero_checked_rows":
                failures.append(f"empty mount reason mismatch: {payload.get('coverage_error_reason')}")

    if failures:
        print("test_eval_mount_validity FAILED", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1
    print("test_eval_mount_validity=ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

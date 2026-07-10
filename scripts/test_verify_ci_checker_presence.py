#!/usr/bin/env python3
"""Regression test: verify-ci must fail when a required checker is deleted."""

from __future__ import annotations

import subprocess
import sys
import tempfile
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
MAKEFILE = REPO_ROOT / "Makefile"
CHECKER_PATHS = (
    Path("Tools/checks/check_c1_ownership_map.py"),
    Path("Tools/checks/check_fallback_scripts.py"),
    Path("scripts/check_s10_receipt.py"),
)
MISSING_MARKER = "ERROR_MISSING_C1_CHECKER"
OWNERSHIP_TARGET = "verify-c1-ownership"
OWNERSHIP_SUITE = "scripts/test_check_c1_ownership_map.py"
OWNERSHIP_CHECKER = "Tools/checks/check_c1_ownership_map.py"


def test_verify_ci_fails_when_a_checker_is_deleted() -> None:
    makefile_text = MAKEFILE.read_text(encoding="utf-8")
    makefile_lines = makefile_text.splitlines()
    verify_line = next(line for line in makefile_lines if line.startswith("verify:"))
    verify_ci_line = next(line for line in makefile_lines if line.startswith("verify-ci:"))
    assert OWNERSHIP_TARGET in verify_line, verify_line
    assert OWNERSHIP_TARGET in verify_ci_line, verify_ci_line
    assert "verify-c1-checker-files" in verify_ci_line, verify_ci_line

    ownership_start = makefile_text.index(f"{OWNERSHIP_TARGET}:")
    ownership_end = makefile_text.find("\n\n", ownership_start)
    ownership_block = makefile_text[
        ownership_start : ownership_end if ownership_end >= 0 else None
    ]
    assert OWNERSHIP_SUITE in ownership_block, ownership_block
    assert OWNERSHIP_CHECKER in ownership_block, ownership_block

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

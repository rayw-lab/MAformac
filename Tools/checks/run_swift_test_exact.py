#!/usr/bin/env python3
"""Run one exact Swift XCTest filter and fail closed when zero or multiple tests execute."""

from __future__ import annotations

import argparse
import re
import subprocess
import sys


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--swift-bin", default="swift")
    parser.add_argument("--filter", required=True)
    args = parser.parse_args(argv)

    result = subprocess.run(
        [args.swift_bin, "test", "--filter", args.filter],
        capture_output=True,
        text=True,
        check=False,
    )
    sys.stdout.write(result.stdout)
    sys.stderr.write(result.stderr)
    combined = result.stdout + result.stderr

    if result.returncode != 0:
        print(
            f"E_SWIFT_EXACT_TEST_COMMAND filter={args.filter} rc={result.returncode}",
            file=sys.stderr,
        )
        return result.returncode

    counts = [int(value) for value in re.findall(r"Executed\s+(\d+)\s+tests?\b", combined)]
    if "No matching test cases" in combined or any(count == 0 for count in counts):
        print(f"E_SWIFT_EXACT_TEST_ZERO filter={args.filter}", file=sys.stderr)
        return 1
    if not counts or any(count != 1 for count in counts):
        print(
            f"E_SWIFT_EXACT_TEST_COUNT filter={args.filter} observed={counts}",
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

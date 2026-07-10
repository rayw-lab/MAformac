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
    parser.add_argument(
        "--min-count",
        type=int,
        default=None,
        help=(
            "When set, require every observed suite to execute >=1 test and the total to reach "
            "at least this many (suite mode). When omitted, exactly one test must execute."
        ),
    )
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

    # A test that ends in XCTSkip still reports "Executed N tests" but with a nonzero skipped
    # count; accepting it would let a skip wash the behavior gate green. Fail closed on any skip.
    skipped = [int(value) for value in re.findall(r"with\s+(\d+)\s+tests?\s+skipped", combined)]
    if any(count != 0 for count in skipped) or "test skipped" in combined:
        print(
            f"E_SWIFT_EXACT_TEST_SKIPPED filter={args.filter} skipped={skipped}",
            file=sys.stderr,
        )
        return 1

    if not counts:
        print(
            f"E_SWIFT_EXACT_TEST_COUNT filter={args.filter} observed={counts}",
            file=sys.stderr,
        )
        return 1

    if args.min_count is None:
        if any(count != 1 for count in counts):
            print(
                f"E_SWIFT_EXACT_TEST_COUNT filter={args.filter} observed={counts}",
                file=sys.stderr,
            )
            return 1
    elif max(counts) < args.min_count:
        print(
            f"E_SWIFT_EXACT_TEST_COUNT filter={args.filter} "
            f"observed={counts} min_count={args.min_count}",
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

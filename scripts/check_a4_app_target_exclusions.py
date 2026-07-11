#!/usr/bin/env python3
"""Fail closed when Mac/iOS app targets compile A4 dev-only Swift sources."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


TARGET_IDS = {
    "MAformacMac": "A50000000000000000000001",
    "MAformacIOS": "A50000000000000000000002",
}
SCOPED_DIRS = ("Bench", "Training", "Generation")
EXCEPTION_RE = re.compile(
    r"(?P<id>[A-Z0-9]{24})[^=]*=\s*\{\s*"
    r"isa = PBXFileSystemSynchronizedBuildFileExceptionSet;"
    r"(?P<body>.*?)\n\s*\};",
    re.DOTALL,
)


def expected_sources(core_root: Path) -> set[str]:
    return {
        path.relative_to(core_root).as_posix()
        for directory in SCOPED_DIRS
        for path in (core_root / directory).rglob("*.swift")
    }


def parse_exception_sets(project_text: str) -> dict[str, set[str]]:
    observed: dict[str, set[str]] = {}
    for match in EXCEPTION_RE.finditer(project_text):
        body = match.group("body")
        target_match = re.search(r"target = ([A-Z0-9]{24})", body)
        members_match = re.search(r"membershipExceptions = \((.*?)\);", body, re.DOTALL)
        if not target_match or not members_match:
            continue
        members = {
            line.strip().rstrip(",").strip('"')
            for line in members_match.group(1).splitlines()
            if line.strip()
        }
        observed[target_match.group(1)] = members
    return observed


def validate(project: Path, core_root: Path) -> list[str]:
    expected = expected_sources(core_root)
    observed = parse_exception_sets(project.read_text())
    errors: list[str] = []
    for target_name, target_id in TARGET_IDS.items():
        actual = observed.get(target_id)
        if actual is None:
            errors.append(f"E_A4_MISSING_EXCEPTION_SET target={target_name}")
            continue
        missing = sorted(expected - actual)
        extra = sorted(actual - expected)
        if missing:
            errors.append(f"E_A4_UNEXCLUDED target={target_name} paths={','.join(missing)}")
        if extra:
            errors.append(f"E_A4_STALE_EXCEPTION target={target_name} paths={','.join(extra)}")
    if len(expected) != 8:
        errors.append(f"E_A4_EXPECTED_SOURCE_COUNT expected=8 actual={len(expected)}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project", type=Path, default=Path("MAformac.xcodeproj/project.pbxproj"))
    parser.add_argument("--core-root", type=Path, default=Path("Core"))
    args = parser.parse_args()
    errors = validate(args.project, args.core_root)
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print("PASS: A4 app target exclusions exact for MAformacMac/MAformacIOS (8 sources each)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

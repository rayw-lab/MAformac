#!/usr/bin/env python3
"""CG-080 Red Line: Enforce mounted catalog is frozen to exactly [adjust_ac_temperature_to_number]."""

from __future__ import annotations

import argparse
import json
import sys
import re
import hashlib
from pathlib import Path


EXIT_INPUT_ERROR = 65
EXIT_DELTA_VIOLATION = 66

BASELINE_MOUNTED_TOOL_NAMES = set([
    "adjust_ac_temperature_to_number"
])
BASELINE_CATALOG_SHA = "616d4dbc07f21f1599a373af8aaf1d3152df05c5956ef61358c4645cc3a53fa5"


def sha256hex(data):
    return hashlib.sha256(data).hexdigest()


def load_current_mounted_from_swift(path):
    """Load mountedToolNames from DDomainMountedToolCatalog.swift source."""
    content = path.read_text(encoding="utf-8")

    # Extract mountedToolNames
    mounted_match = re.search(
        r"public static let mountedToolNames: Set<String> = \[(.*?)\]",
        content,
        re.DOTALL
    )
    if not mounted_match:
        print(f"error: Could not find mountedToolNames in {path}", file=sys.stderr)
        raise SystemExit(EXIT_INPUT_ERROR)

    mounted_str = mounted_match.group(1)
    names = set()
    for line in mounted_str.split("\n"):
        line = line.strip()
        if line.startswith('"') and line.endswith('"') and len(line) > 2:
            names.add(line[1:-1])
        elif line.startswith('"') and line.endswith('",'):
            names.add(line[1:-2])
        elif line.startswith('"') and line.endswith('"'):
            names.add(line[1:-1])

    # Extract mountedDemoCatalogSha calculation and compute current SHA
    sorted_names = sorted(names)
    data = json.dumps(sorted_names, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
    data += b"\n"
    current_sha = sha256hex(data)

    return names, current_sha


def check(current_names, current_sha):
    added = current_names - BASELINE_MOUNTED_TOOL_NAMES
    removed = BASELINE_MOUNTED_TOOL_NAMES - current_names

    status = "PASS"
    violation_type = ""
    violation_reason = ""
    can_rollback = False
    rollback_instructions = ""

    if added or removed:
        status = "FAIL"
        if added and removed:
            violation_type = "added_and_removed"
            violation_reason = f"Added: {sorted(added)}, Removed: {sorted(removed)}"
        elif added:
            violation_type = "added"
            violation_reason = f"Added: {sorted(added)}"
        else:
            violation_type = "removed"
            violation_reason = f"Removed: {sorted(removed)}"

        can_rollback = True
        rollback_instructions = (
            "To rollback and restore baseline:\n"
            "1. Manually edit DDomainMountedToolCatalog.swift\n"
            "2. Set mountedToolNames back to baseline: [\"adjust_ac_temperature_to_number\"]\n"
            "3. Re-run make verify"
        )

    sha_ok = current_sha == BASELINE_CATALOG_SHA

    return {
        "status": status if sha_ok else ("FAIL" if status == "PASS" else "FAIL"),
        "current_mounted_tool_names": sorted(current_names),
        "baseline_mounted_tool_names": sorted(BASELINE_MOUNTED_TOOL_NAMES),
        "current_sha": current_sha,
        "baseline_sha": BASELINE_CATALOG_SHA,
        "sha_match": sha_ok,
        "added": sorted(added),
        "removed": sorted(removed),
        "violation_type": violation_type,
        "violation_reason": violation_reason,
        "can_rollback": can_rollback,
        "rollback_instructions": rollback_instructions,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--swift-path",
        type=Path,
        default=Path("Core/Contracts/DDomainMountedToolCatalog.swift"),
        help="Path to DDomainMountedToolCatalog.swift"
    )
    parser.add_argument(
        "--output",
        type=Path,
        help="Optional JSON report path."
    )
    args = parser.parse_args()

    if not args.swift_path.exists():
        print(f"error: Swift file not found: {args.swift_path}", file=sys.stderr)
        raise SystemExit(EXIT_INPUT_ERROR)

    current_names, current_sha = load_current_mounted_from_swift(args.swift_path)

    report = check(current_names, current_sha)
    text = json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True)

    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(text + "\n", encoding="utf-8")

    print(text)

    if report["status"] == "FAIL":
        print("\n❌ CG-080 VIOLATION: Mounted catalog has changed from baseline!", file=sys.stderr)
        if report["violation_reason"]:
            print(f"   {report['violation_reason']}", file=sys.stderr)
        if report["rollback_instructions"]:
            print(f"\n{report['rollback_instructions']}", file=sys.stderr)
        return EXIT_DELTA_VIOLATION

    print("✅ CG-080 PASSED: Mounted catalog is frozen to baseline.", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Reject the legacy action-proof token outside an exact, auditable budget."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
from pathlib import Path
from typing import Any


IGNORED_PREFIXES = (
    ".git/",
    ".gitnexus/",
    ".build/",
    ".venv/",
    "Reports/",
    "docs/handoffs/",
)
IGNORED_PATHS = {"docs/CURRENT.md"}
LEGACY_TOKEN = "can" + "Demo"


def candidate_paths(repo_root: Path) -> list[Path]:
    tracked = subprocess.run(
        ["git", "-C", str(repo_root), "ls-files", "-z"],
        check=True,
        capture_output=True,
    ).stdout.split(b"\0")
    return sorted(
        path
        for raw in tracked
        if raw
        for path in [repo_root / raw.decode("utf-8")]
        if path.is_file()
        and not any(path.relative_to(repo_root).as_posix().startswith(prefix) for prefix in IGNORED_PREFIXES)
        and path.relative_to(repo_root).as_posix() not in IGNORED_PATHS
    )


def check_legacy_tokens(repo_root: Path, allowlist_path: Path) -> dict[str, Any]:
    payload = json.loads(allowlist_path.read_text(encoding="utf-8"))
    entries = payload.get("entries", [])
    allowed: dict[str, dict[str, Any]] = {
        entry["path"]: entry for entry in entries if isinstance(entry, dict) and isinstance(entry.get("path"), str)
    }
    errors: list[str] = []
    outside_allowlist: list[str] = []
    counts: dict[str, int] = {}
    for relative, entry in allowed.items():
        path = repo_root / relative
        pattern = re.compile(entry.get("token_regex", LEGACY_TOKEN))
        count = len(pattern.findall(path.read_text(encoding="utf-8"))) if path.is_file() else 0
        counts[relative] = count
        budget = entry.get("max_matches")
        if count == 0:
            errors.append("E_LEGACY_ALLOWLIST_STALE")
        elif not isinstance(budget, int) or count > budget:
            errors.append("E_LEGACY_ALLOWLIST_BUDGET_EXCEEDED")
        elif count < budget:
            errors.append("E_LEGACY_ALLOWLIST_STALE")

    for path in candidate_paths(repo_root):
        if path.resolve() == allowlist_path.resolve():
            continue
        relative = path.relative_to(repo_root).as_posix()
        if relative in allowed:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        if LEGACY_TOKEN in text:
            errors.append("E_LEGACY_TOKEN_OUTSIDE_ALLOWLIST")
            outside_allowlist.append(relative)

    return {
        "status": "PASS" if not errors else "FAIL",
        "errors": sorted(set(errors)),
        "match_counts": counts,
        "outside_allowlist": sorted(outside_allowlist),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument("--allowlist", type=Path, required=True)
    args = parser.parse_args()
    report = check_legacy_tokens(args.repo_root.resolve(), args.allowlist.resolve())
    print(json.dumps(report, ensure_ascii=False, sort_keys=True))
    return 0 if report["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())

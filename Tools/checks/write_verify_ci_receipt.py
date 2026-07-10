#!/usr/bin/env python3
"""Write a generic, head-bound receipt for source-free CI verification."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
from datetime import datetime, timezone
from pathlib import Path


def parse_change_ids(raw: str) -> list[str]:
    return sorted({item for item in re.split(r"[\s,]+", raw.strip()) if item})


def dirty_worktree() -> bool:
    result = subprocess.run(
        ["git", "status", "--porcelain", "--untracked-files=no"],
        capture_output=True,
        text=True,
        check=True,
    )
    return bool(result.stdout.strip())


def optional_pr_number(raw: str) -> int | None:
    return int(raw) if raw.isdigit() else None


def build_receipt(change_ids: str) -> dict[str, object]:
    run_id = os.environ.get("GITHUB_RUN_ID", "local")
    run_attempt = os.environ.get("GITHUB_RUN_ATTEMPT", "1")
    return {
        "receipt_id": f"verify-ci-{run_id}-{run_attempt}",
        "receipt_kind": "verify-ci",
        "created_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
        "change_ids": parse_change_ids(change_ids),
        "proof_class": "ci_source_free",
        "event_name": os.environ.get("GITHUB_EVENT_NAME", "local"),
        "head_commit": os.environ.get("GITHUB_SHA", ""),
        "base_ref": os.environ.get("GITHUB_BASE_REF", ""),
        "head_ref": os.environ.get("GITHUB_HEAD_REF", ""),
        "pull_request_number": optional_pr_number(os.environ.get("GITHUB_PR_NUMBER", "")),
        "dirty_worktree": dirty_worktree(),
        "commands": [
            "make verify-ci",
            "git diff --check (pull_request only)",
        ],
        "non_claims": [
            "source-free committed-contract proof only",
            "raw-dependent local verification is not covered",
            "not runtime, operator, mobile, true-device, live-api, C5 or C6 acceptance",
        ],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument(
        "--change-ids",
        default=os.environ.get("VERIFY_CI_CHANGE_IDS", ""),
        help="Comma or whitespace separated explicit OpenSpec change ids",
    )
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(build_receipt(args.change_ids), ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    print(args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Golden fixture regression tests for register_classifier.py."""

from __future__ import annotations

import json
from collections import defaultdict
from pathlib import Path

from register_classifier import classify_register


REPO_ROOT = Path(__file__).resolve().parents[1]
FIXTURE = REPO_ROOT / "Tests" / "Fixtures" / "register-golden" / "golden-set.jsonl"
EXPECTED_SUFFIXES = {"M", "A", "H", "S"}


def read_jsonl(path: Path) -> list[dict]:
    rows: list[dict] = []
    with path.open("r", encoding="utf-8") as handle:
        for line_no, raw in enumerate(handle, 1):
            if not raw.strip():
                continue
            try:
                rows.append(json.loads(raw))
            except json.JSONDecodeError as exc:
                raise AssertionError(f"{path}:{line_no}: invalid JSONL: {exc}") from exc
    return rows


def main() -> int:
    failures: list[str] = []
    rows = read_jsonl(FIXTURE)
    if len(rows) != 40:
        failures.append(f"expected 40 MAIN rows, got {len(rows)}")

    seen_ids: set[str] = set()
    by_pair: dict[str, set[str]] = defaultdict(set)
    for row in rows:
        row_id = str(row.get("id") or "")
        if row_id in seen_ids:
            failures.append(f"duplicate id {row_id!r}")
        seen_ids.add(row_id)
        suffix = row_id.rsplit("-", 1)[-1]
        by_pair[str(row.get("pair_id") or "")].add(suffix)

        actual = classify_register(str(row.get("utterance") or ""))
        expected = row.get("expected") or {}
        checks = {
            "register": actual.register,
            "is_meta_capability_question": actual.is_meta_capability_question,
            "hedged_overlay": actual.hedged_overlay,
        }
        for key, observed in checks.items():
            if observed != expected.get(key):
                failures.append(
                    f"{row_id}: {key} expected {expected.get(key)!r}, got {observed!r}; "
                    f"utterance={row.get('utterance')!r}"
                )

    if len(by_pair) != 10:
        failures.append(f"expected 10 pair_id groups, got {len(by_pair)}")
    for pair_id, suffixes in sorted(by_pair.items()):
        if suffixes != EXPECTED_SUFFIXES:
            failures.append(f"{pair_id}: expected suffixes {sorted(EXPECTED_SUFFIXES)}, got {sorted(suffixes)}")

    if failures:
        print("test_register_classifier_golden FAILED")
        for failure in failures:
            print(f"  - {failure}")
        return 1
    print("test_register_classifier_golden=ok rows=40 pairs=10")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

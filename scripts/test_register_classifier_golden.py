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
EXPECTED_MAIN_ROWS = 40
EXPECTED_BOUNDARY_ROWS = 10
EXPECTED_SHAPE_ROWS = 12
EXPECTED_BOUNDARY_IDS = {f"B{index:02d}" for index in range(1, 11)}
EXPECTED_SHAPE_IDS = {
    "SHAPE-S3-01",
    "SHAPE-S3-02",
    "SHAPE-S4-01",
    "SHAPE-S4-02",
    "SHAPE-S5-01",
    "SHAPE-S5-02",
    "SHAPE-STATUS-01",
    "SHAPE-META-01",
    "SHAPE-NEG-01",
    "SHAPE-NEG-02",
    "SHAPE-NEG-03",
    "SHAPE-NEG-04",
}
EXPECTED_CAN_ACTION_SHAPE_MIN_COUNTS = {
    "S3_X_CAN_Q": 2,
    "S4_CAN_BA_Q": 2,
    "S5_X_OK_Q": 2,
}
OUT_OF_WINDOW_EXP_IDS = {"B01", "B03", "B05", "B06", "B09"}
EXCLUDED_FROM_POSITIVE_CORPUS_IDS = {"B04", "B07", "B08", "B10"}


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
    expected_rows = EXPECTED_MAIN_ROWS + EXPECTED_BOUNDARY_ROWS + EXPECTED_SHAPE_ROWS
    if len(rows) != expected_rows:
        failures.append(f"expected {expected_rows} golden rows, got {len(rows)}")

    seen_ids: set[str] = set()
    by_pair: dict[str, set[str]] = defaultdict(set)
    boundary_ids: set[str] = set()
    shape_ids: set[str] = set()
    can_action_shape_counts: dict[str, int] = defaultdict(int)
    for row in rows:
        row_id = str(row.get("id") or "")
        if row_id in seen_ids:
            failures.append(f"duplicate id {row_id!r}")
        seen_ids.add(row_id)
        if row_id.startswith("F"):
            suffix = row_id.rsplit("-", 1)[-1]
            by_pair[str(row.get("pair_id") or "")].add(suffix)
        elif row_id.startswith("B"):
            boundary_ids.add(row_id)
        elif row_id.startswith("SHAPE-"):
            shape_ids.add(row_id)
            if (row.get("expected") or {}).get("register") == "can_question" and not row.get(
                "expected", {}
            ).get("is_meta_capability_question"):
                can_action_shape_counts[str(row.get("shape") or "")] += 1
        else:
            failures.append(f"{row_id}: unexpected golden id prefix")

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

    main_count = sum(1 for row in rows if str(row.get("id") or "").startswith("F"))
    boundary_count = sum(1 for row in rows if str(row.get("id") or "").startswith("B"))
    shape_count = sum(1 for row in rows if str(row.get("id") or "").startswith("SHAPE-"))
    if main_count != EXPECTED_MAIN_ROWS:
        failures.append(f"expected {EXPECTED_MAIN_ROWS} MAIN rows, got {main_count}")
    if boundary_count != EXPECTED_BOUNDARY_ROWS:
        failures.append(f"expected {EXPECTED_BOUNDARY_ROWS} BOUNDARY rows, got {boundary_count}")
    if shape_count != EXPECTED_SHAPE_ROWS:
        failures.append(f"expected {EXPECTED_SHAPE_ROWS} SHAPE rows, got {shape_count}")
    if len(by_pair) != 10:
        failures.append(f"expected 10 pair_id groups, got {len(by_pair)}")
    for pair_id, suffixes in sorted(by_pair.items()):
        if suffixes != EXPECTED_SUFFIXES:
            failures.append(f"{pair_id}: expected suffixes {sorted(EXPECTED_SUFFIXES)}, got {sorted(suffixes)}")
    if boundary_ids != EXPECTED_BOUNDARY_IDS:
        failures.append(f"expected boundary ids {sorted(EXPECTED_BOUNDARY_IDS)}, got {sorted(boundary_ids)}")
    if shape_ids != EXPECTED_SHAPE_IDS:
        failures.append(f"expected shape ids {sorted(EXPECTED_SHAPE_IDS)}, got {sorted(shape_ids)}")
    for shape, expected_count in EXPECTED_CAN_ACTION_SHAPE_MIN_COUNTS.items():
        observed = can_action_shape_counts.get(shape, 0)
        if observed < expected_count:
            failures.append(f"{shape}: expected at least {expected_count} action rows, got {observed}")
    for row in rows:
        row_id = str(row.get("id") or "")
        if row_id in OUT_OF_WINDOW_EXP_IDS and row.get("out_of_window_exp") is not True:
            failures.append(f"{row_id}: expected out_of_window_exp=true")
        if row_id not in OUT_OF_WINDOW_EXP_IDS and row_id.startswith("B") and "out_of_window_exp" in row:
            failures.append(f"{row_id}: unexpected out_of_window_exp marker")
        if row_id in EXCLUDED_FROM_POSITIVE_CORPUS_IDS and row.get("excluded_from_positive_corpus") is not True:
            failures.append(f"{row_id}: expected excluded_from_positive_corpus=true")
        if row_id not in EXCLUDED_FROM_POSITIVE_CORPUS_IDS and row_id.startswith("B") and "excluded_from_positive_corpus" in row:
            failures.append(f"{row_id}: unexpected excluded_from_positive_corpus marker")

    if failures:
        print("test_register_classifier_golden FAILED")
        for failure in failures:
            print(f"  - {failure}")
        return 1
    print(
        "test_register_classifier_golden=ok "
        f"rows={len(rows)} pairs=10 boundary={boundary_count} shape={shape_count} "
        + " ".join(
            f"{shape}={can_action_shape_counts.get(shape, 0)}"
            for shape in sorted(EXPECTED_CAN_ACTION_SHAPE_MIN_COUNTS)
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

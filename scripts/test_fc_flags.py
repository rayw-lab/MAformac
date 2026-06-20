#!/usr/bin/env python3
"""Fixture tests for C1 FC flag normalization.

The FC columns are source markers with Chinese yes/no values. C1 must treat
only "是" as true; "否", empty, and None remain false even after rows are
classified from merged-filled workbook extracts.
Run: .venv/bin/python scripts/test_fc_flags.py
"""
from __future__ import annotations

import sys
from typing import Any

import gen_c1


HEADER_MAP = {
    "function_text": 0,
    "ds_protocol": 1,
    "action_code": 2,
    "semantic_range": 3,
    "fc_fuzzy": 4,
    "fc_free": 5,
    "example_utterance": 6,
}
MANIFEST = {"snapshot_id": "test-fixture"}
VALID_DS = '{"service":"airControl","intent":"open_ac","semantic":{"slots":{}}}'


def row(fc_fuzzy: Any, fc_free: Any, row_no: int) -> dict[str, Any]:
    return {
        "row_no": row_no,
        "nonblank": True,
        "values": ["打开空调", VALID_DS, "activate", "", fc_fuzzy, fc_free, "打开空调"],
    }


def check(condition: bool, failures: list[str], name: str, detail: str = "") -> None:
    mark = "PASS" if condition else "FAIL"
    suffix = f" {detail}" if detail else ""
    print(f"  [{mark}] {name}{suffix}")
    if not condition:
        failures.append(name)


def classify(fc_fuzzy: Any, fc_free: Any, row_no: int) -> dict[str, Any]:
    kind, record = gen_c1.classify_semantic_row(MANIFEST, "airControl", row(fc_fuzzy, fc_free, row_no), HEADER_MAP)
    if kind != "valid":
        raise AssertionError(f"fixture row should classify valid, got {kind}: {record}")
    return record


def run() -> int:
    failures: list[str] = []
    fc_is_yes = getattr(gen_c1, "fc_is_yes", None)
    if fc_is_yes is None:
        print("  [FAIL] fc_is_yes exists")
        failures.append("fc_is_yes exists")
    else:
        value_cases = [
            ("是", True),
            ("否", False),
            ("", False),
            (None, False),
            (" 是 ", True),
        ]
        for value, expected in value_cases:
            actual = fc_is_yes(value)
            check(
                actual is expected,
                failures,
                f"fc_is_yes({value!r})",
                f"actual={actual} expected={expected}",
            )

    all_no = classify("否", "否", 10)
    check(all_no["fc_flags"]["fuzzy"] is False, failures, 'classify fuzzy "否" is false')
    check(all_no["fc_flags"]["free"] is False, failures, 'classify free "否" is false')
    check(all_no["clarify_tag"] == "explicit", failures, "all-no row is explicit", all_no["clarify_tag"])
    check(bool(all_no["fc_flags"]["fuzzy_hash"]), failures, '"否" fuzzy hash remains traceable')
    check(bool(all_no["fc_flags"]["free_hash"]), failures, '"否" free hash remains traceable')

    empty = classify("", None, 11)
    check(empty["fc_flags"]["fuzzy"] is False, failures, "empty fuzzy is false")
    check(empty["fc_flags"]["free"] is False, failures, "None free is false")
    check(empty["clarify_tag"] == "explicit", failures, "empty/None row is explicit", empty["clarify_tag"])

    fuzzy_yes = classify(" 是 ", "否", 12)
    check(fuzzy_yes["fc_flags"]["fuzzy"] is True, failures, 'trimmed fuzzy "是" is true')
    check(fuzzy_yes["fc_flags"]["free"] is False, failures, 'free "否" stays false when fuzzy is true')
    check(fuzzy_yes["clarify_tag"] == "implicit", failures, "fuzzy yes row is implicit", fuzzy_yes["clarify_tag"])

    merged_filled_yes = classify("是", "是", 13)
    explicit_no_after_merged_fill = classify("否", "否", 14)
    check(
        merged_filled_yes["clarify_tag"] == "implicit",
        failures,
        "merged-filled yes row remains implicit",
        merged_filled_yes["clarify_tag"],
    )
    check(
        explicit_no_after_merged_fill["fc_flags"]["fuzzy"] is False
        and explicit_no_after_merged_fill["fc_flags"]["free"] is False
        and explicit_no_after_merged_fill["clarify_tag"] == "explicit",
        failures,
        'explicit "否" row after merged-filled yes is still false',
        str(explicit_no_after_merged_fill["fc_flags"]) + " " + explicit_no_after_merged_fill["clarify_tag"],
    )

    if failures:
        print(f"\ntest_fc_flags FAILED: {failures}", file=sys.stderr)
        return 1
    print("\ntest_fc_flags=ok (FC 是/否/空/None/空白 normalization is correct)")
    return 0


if __name__ == "__main__":
    raise SystemExit(run())

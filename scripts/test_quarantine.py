#!/usr/bin/env python3
"""Fixture 测试:坐实 C1 quarantine 逻辑对脏行真生效(非"源表恰好无脏行"巧合).

证明 quarantined_rows=0 是"源表无脏行"而非"逻辑失效":对合成脏行,
classify_semantic_row 必须分流到 quarantine 带正确 reason,不洗白成 valid。
demo 轻治理:合成 row 直测决策单元, 不建完整 xlsx, 不引 pytest 框架。
运行: .venv/bin/python scripts/test_quarantine.py
"""
from __future__ import annotations

import sys

from gen_c1 import classify_semantic_row

# header_map: SEMANTIC_HEADERS 键 → 合成 values 列表下标
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


def row(values: list[str], nonblank: bool = True, row_no: int = 1) -> dict:
    return {"row_no": row_no, "nonblank": nonblank, "values": values}


def run() -> int:
    cases = [
        # (name, row, expect_kind, expect_reason_substr)
        (
            "valid 行",
            row([f"打开空调", VALID_DS, "activate", "", "是", "否", "打开空调"]),
            "valid",
            None,
        ),
        (
            "merged-cell residual(全空残留行)",
            row(["", "", "", "", "", "", ""], nonblank=False),
            "quarantine",
            "empty_semantics",
        ),
        (
            "空语义(有功能名无 DS)",
            row(["打开空调", "", "", "", "", "", ""]),
            "quarantine",
            "empty_semantics",
        ),
        (
            "malformed DS(坏 json)",
            row(["打开空调", '{"service":"airControl", bad', "", "", "", "", ""]),
            "quarantine",
            "malformed",
        ),
        (
            "缺 service/intent(合法 json 但语义空)",
            row(["打开空调", '{"semantic":{"slots":{}}}', "", "", "", "", ""]),
            "quarantine",
            "malformed",
        ),
    ]

    failures = []
    for name, r, expect_kind, expect_reason in cases:
        kind, record = classify_semantic_row(MANIFEST, "airControl", r, HEADER_MAP)
        ok = kind == expect_kind
        reason = record.get("reason") if kind == "quarantine" else None
        if expect_reason is not None and (reason is None or expect_reason not in str(reason)):
            ok = False
        mark = "PASS" if ok else "FAIL"
        print(f"  [{mark}] {name}: kind={kind} reason={reason}")
        if not ok:
            failures.append(name)

    if failures:
        print(f"\ntest_quarantine FAILED: {failures}", file=sys.stderr)
        return 1
    print("\ntest_quarantine=ok (脏行被 quarantine 分流, valid 不洗白)")
    return 0


if __name__ == "__main__":
    raise SystemExit(run())

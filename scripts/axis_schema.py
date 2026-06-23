#!/usr/bin/env python3
"""axis-schema：按 case schema 字段拆 C6 轴（非 id-prefix），每轴报 hard_pass。

防第6同坑：用 schema 字段（expect_no_call / pre==delta no-op）拆 positive/noop/refusal，
不用 case_id naming convention 当分母（refusal/noop 会污染 positive_action）。

用法: axis_schema.py <c6-summary.json> [c6-bench-cases.jsonl] [scope_prefix]
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _c6_axis_lib import load_cases, load_summary, classify, action_hard_pass  # noqa: E402


def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "usage: axis_schema.py <c6-summary.json> [cases.jsonl] [scope]"}))
        return 2
    summary = load_summary(sys.argv[1])
    cases_path = sys.argv[2] if len(sys.argv) > 2 else os.path.join(os.getcwd(), "contracts", "c6-bench-cases.jsonl")
    scope = sys.argv[3] if len(sys.argv) > 3 else "C6-MP"
    cases = load_cases(cases_path)
    b = classify(summary, cases, scope_prefix=scope)

    def hp(runs):
        return action_hard_pass(runs)

    out = {
        "scope_prefix": scope,
        "split_by": "schema_field (expect_no_call / pre==delta noop), NOT id_prefix",
        "axes": {
            "positive": {"denom": len(b["positive"]), "action_hard_pass": hp(b["positive"])},
            "noop": {"denom": len(b["noop"]), "action_hard_pass": hp(b["noop"])},
            "refusal": {"denom": len(b["refusal"]), "action_hard_pass": hp(b["refusal"])},
            "unknown": {"denom": len(b["unknown"])},
        },
        "total_scoped": len(b["positive"]) + len(b["noop"]) + len(b["refusal"]) + len(b["unknown"]),
    }
    print(json.dumps(out, sort_keys=True, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())

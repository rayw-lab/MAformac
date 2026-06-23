#!/usr/bin/env python3
"""action hard_pass 复算（从 c6-summary.json:eval_runs[].gate_result 一手字段）。

用法: action_hard_pass_recompute.py <c6-summary.json> [c6-bench-cases.jsonl] [scope_prefix]
输出: 确定性 JSON（sort_keys，无时间戳）供 recompute hash。

实测锚: base c6-base-full → mp_positive_action 10/23（lessons §1 坐实）。
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _c6_axis_lib import load_cases, load_summary, classify, action_hard_pass  # noqa: E402


def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "usage: action_hard_pass_recompute.py <c6-summary.json> [cases.jsonl] [scope]"}))
        return 2
    summary_path = sys.argv[1]
    repo = os.path.dirname(os.path.dirname(os.path.abspath(summary_path)))
    # 允许从 cwd 找 contracts/
    cases_path = sys.argv[2] if len(sys.argv) > 2 else os.path.join(os.getcwd(), "contracts", "c6-bench-cases.jsonl")
    scope = sys.argv[3] if len(sys.argv) > 3 else "C6-MP"

    summary = load_summary(summary_path)
    cases = load_cases(cases_path)
    buckets = classify(summary, cases, scope_prefix=scope)
    pos = buckets["positive"]
    hp = action_hard_pass(pos)

    out = {
        "scope_prefix": scope,
        "mp_positive_action": {
            "denom": len(pos),
            "action_hard_pass": hp,
            "fraction": f"{hp}/{len(pos)}" if pos else "0/0",
        },
        "axis_counts": {
            "positive": len(buckets["positive"]),
            "noop": len(buckets["noop"]),
            "refusal": len(buckets["refusal"]),
            "unknown": len(buckets["unknown"]),
        },
        "hard_pass_definition": "tool_call_set_match AND state_delta_match (without readback)",
    }
    print(json.dumps(out, sort_keys=True, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())

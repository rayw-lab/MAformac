#!/usr/bin/env python3
"""verify-gold：c6 gold 契约自洽性（gold 内部 well-formed = "gold apply 100%"）。

gold（expected_tool_calls + expected_state_delta + expect_no_call）必须自洽，否则 scorer 锚错。
检查（每 case，真结构不变量）：
  - refusal（expect_no_call=True）：expected_tool_calls 必空
    （⚠️ 不查 state_delta：fixture 故意在 refusal 上存目标态/前置上下文，如 001「关空调」
     pre 已 off 的目标态、024「打开车门」存车速 30 前置——实测坐实非违规，查则误报）
  - 非 refusal：expected_tool_calls 必非空；工具名 ⊆ 生成 surface
  - alternatives（若有）：每个 gold alt 的工具名也 ⊆ surface
violations 非空 = gold 不可 100% apply。

用法: verify_gold.py [c6-bench-cases.jsonl] [generated/D_domain.tools.json]
"""
import json
import os
import sys


def main():
    cwd = os.getcwd()
    cases_path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(cwd, "contracts", "c6-bench-cases.jsonl")
    tools_path = sys.argv[2] if len(sys.argv) > 2 else os.path.join(cwd, "generated", "D_domain.tools.demo.json")

    with open(tools_path, encoding="utf-8") as f:
        surface = {t.get("function", {}).get("name") for t in json.load(f)}

    violations = []
    total = 0
    with open(cases_path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            c = json.loads(line)
            total += 1
            cid = c["case_id"]
            enc = c.get("expect_no_call") is True
            tcs = c.get("expected_tool_calls") or []
            delta = c.get("expected_state_delta") or {}
            if enc:
                if tcs:
                    violations.append(f"{cid}:refusal_has_tool_calls")
                # 不查 refusal 的 state_delta（fixture 故意存目标态/前置上下文，实测非违规）
            else:
                if not tcs:
                    violations.append(f"{cid}:positive_missing_tool_calls")
                for tc in tcs:
                    if tc.get("name") and tc["name"] not in surface:
                        violations.append(f"{cid}:tool_not_in_surface:{tc['name']}")
            for alt in c.get("alternatives") or []:
                for tc in alt.get("expected_tool_calls") or []:
                    if tc.get("name") and tc["name"] not in surface:
                        violations.append(f"{cid}:alt_tool_not_in_surface:{tc['name']}")

    out = {
        "total_cases": total,
        "violations": sorted(violations),
        "violation_count": len(violations),
        "gold_apply_100": len(violations) == 0,
    }
    print(json.dumps(out, sort_keys=True, ensure_ascii=False))
    return 0 if not violations else 1


if __name__ == "__main__":
    sys.exit(main())

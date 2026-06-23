#!/usr/bin/env python3
"""surface-consistency：c6 bench tool surface ⊆ 生成 tool surface（0/34 灾难根因检测）。

0/34 根因 = 训练 tool surface（tool_call_frame）与 c6 eval surface（set_cabin_*）不同源。
本脚本核：c6-bench-cases.jsonl 的 expected_tool_calls 工具名 ⊆ generated/D_domain.tools.json 工具名。
缺集非空 = surface drift = 必炸（训练/eval 不同源）。

用法: surface_consistency.py [c6-bench-cases.jsonl] [generated/D_domain.tools.json]
"""
import json
import os
import sys


def main():
    cwd = os.getcwd()
    cases_path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(cwd, "contracts", "c6-bench-cases.jsonl")
    tools_path = sys.argv[2] if len(sys.argv) > 2 else os.path.join(cwd, "generated", "D_domain.tools.json")

    c6_names = set()
    with open(cases_path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            c = json.loads(line)
            for tc in c.get("expected_tool_calls") or []:
                if tc.get("name"):
                    c6_names.add(tc["name"])

    with open(tools_path, encoding="utf-8") as f:
        tools = json.load(f)
    gen_names = set()
    for t in tools:
        fn = t.get("function") or {}
        if fn.get("name"):
            gen_names.add(fn["name"])

    missing = sorted(c6_names - gen_names)  # c6 用到但生成 surface 没有 → drift
    out = {
        "c6_surface": sorted(c6_names),
        "generated_surface": sorted(gen_names),
        "missing_in_generated": missing,
        "consistent": len(missing) == 0,
    }
    print(json.dumps(out, sort_keys=True, ensure_ascii=False))
    return 0 if not missing else 1


if __name__ == "__main__":
    sys.exit(main())

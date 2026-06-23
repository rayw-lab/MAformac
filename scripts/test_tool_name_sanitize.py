#!/usr/bin/env python3
"""Codex 审计 P2 回归: D-domain 工具名 sanitize(snake_case gate, 受限解码 function name 合法性)。
set_Ibooster_mode → set_ibooster_mode(lower); 校验 sanitize 函数 + 生成 catalog 全 snake_case 合法。
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
from gen_tool_contract import sanitize_tool_name  # noqa: E402

FAILS = []


def check(name, cond):
    status = "PASS" if cond else "FAIL"
    print(f"  [{status}] {name}")
    if not cond:
        FAILS.append(name)


def main() -> int:
    # 1. sanitize_tool_name 行为
    out, was = sanitize_tool_name("set_Ibooster_mode")
    check("set_Ibooster_mode → set_ibooster_mode(lower)", out == "set_ibooster_mode" and was)
    out2, was2 = sanitize_tool_name("open_ac")
    check("already-snake_case 不改(was_sanitized=False)", out2 == "open_ac" and not was2)

    # 2. 生成 catalog(demo+full) 全 snake_case 合法(受限解码 function name)
    snake = re.compile(r"^[a-z][a-z0-9_]*$")
    repo = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    for fn in ("D_domain.tools.demo.json", "D_domain.tools.full.json"):
        cat = json.load(open(os.path.join(repo, "generated", fn), encoding="utf-8"))
        names = [e.get("function", {}).get("name") or e.get("name") for e in cat]
        bad = [n for n in names if not snake.match(n or "")]
        check(f"{fn}: {len(names)} 名全 snake_case 合法(非法={bad[:3]})", not bad)

    # 3. 具体 sanitize 落地: full catalog 含 set_ibooster_mode(非 set_Ibooster_mode)
    full = json.load(open(os.path.join(repo, "generated", "D_domain.tools.full.json"), encoding="utf-8"))
    fnames = {e.get("name") for e in full}
    check("full catalog 含 set_ibooster_mode(sanitized)", "set_ibooster_mode" in fnames)
    check("full catalog 不含 set_Ibooster_mode(原大写)", "set_Ibooster_mode" not in fnames)

    if FAILS:
        print(f"\ntest_tool_name_sanitize=FAIL ({len(FAILS)} 项)")
        return 1
    print("\ntest_tool_name_sanitize=ok (D-domain 工具名 snake_case sanitize 正确)")
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""S5 一次性迁移工具: c6-bench-cases.jsonl 的手维护 C6-TRAP-* 反事实 case 从旧 set_cabin_*/query_cabin_comfort
surface 迁到 D-domain 具名工具名(范式翻案, paradigm §1)。

背景: c6-bench-cases.jsonl 是混合体——45 个 mustPass/negative/coverage 由 `C6BenchCLI generate` 从
CaseSpec(Swift, 已迁 D-domain)再生; 12 个 C6-TRAP-* 反事实 case + alternatives 是【手维护】(generate 不产)。
所以 `generate` 会丢 trap → 本脚本从旧 jsonl(或 git HEAD)取 trap, 迁工具名+args, append 回新 jsonl。

用法: 仅在 CaseSpec 迁移后、`C6BenchCLI generate` 重物化 45 case 后, 再跑本脚本 append 12 迁移后 trap。
  swift run C6BenchCLI generate
  python3 scripts/migrate_c6_trap_to_d_domain.py --old-from-git   # 从 HEAD 取 trap 迁移 append
迁移规则与 Core/Bench/C6VehicleToolBench.swift mustPassCases 的 D-domain 迁移表同源(防口径分叉)。
"""
import argparse
import json
import subprocess
import sys

POS_ZH = {"driver": "主驾", "passenger": "副驾", "rear_left": "左后", "rear_right": "右后", "all": "全车"}
COLOR_ZH = {"red": "红", "blue": "蓝"}


def migrate_call(name: str, args: dict) -> tuple[str, dict]:
    """旧 set_cabin_*/query_cabin_comfort + args → (D-domain 名, 新 args)。device/action/value 形态编码进名。"""
    a = dict(args)
    if name == "set_cabin_ac":
        if a.get("target_temperature"):
            return "adjust_ac_temperature_to_number", {"temperature": a["target_temperature"]}
        if a.get("delta") == "warmer":
            return "raise_ac_temperature_by_exp", {}
        if a.get("delta") == "cooler":
            return "lower_ac_temperature_by_exp", {}
        if a.get("power") == "off":
            return "close_ac", {}
        return "open_ac", {}  # power:on
    if name == "set_cabin_fan":
        if a.get("level"):
            return "adjust_ac_windspeed_to_number", {"fanSpeed": a["level"]}
        if a.get("delta") == "stronger":
            return "raise_ac_windspeed_by_exp", {}
        return "lower_ac_windspeed_by_exp", {}
    if name == "set_cabin_screen_brightness":
        if a.get("percent"):
            return "adjust_screen_brightness_to_number", {"value": a["percent"]}
        if a.get("delta") == "brighter":
            return "raise_screen_brightness_little", {}
        return "lower_screen_brightness_little", {}  # dimmer
    if name == "set_cabin_ambient_light":
        if a.get("brightness_delta") == "brighter":
            return "raise_atmosphere_lamp_brightness_little", {}
        if a.get("brightness_delta") == "dimmer":
            return "lower_atmosphere_lamp_brightness_little", {}
        if a.get("color"):
            return "switch_atmosphere_lamp_color", {"value": COLOR_ZH.get(a["color"], a["color"])}
        return "switch_atmosphere_lamp_color", {}
    if name == "set_cabin_window":
        pos = POS_ZH.get(a.get("position", "all"), "全车")
        if a.get("delta") == "more_open":
            return "open_window_little", {"position": pos}
        if a.get("percent") == "0":
            return "close_window", {"position": pos}
        if a.get("percent") == "100":
            return "open_window", {"position": pos}
        if a.get("percent"):
            return "open_window_to_number", {"position": pos, "value": a["percent"]}
        return "open_window", {"position": pos}
    if name == "query_cabin_comfort":
        return "query_ac_temperature", {}
    return name, a  # 未知保持(不静默改写)


def migrate_tools(tools: list) -> list:
    out = []
    for t in tools:
        nm, na = migrate_call(t["name"], t.get("arguments", {}))
        out.append({"name": nm, "arguments": na})
    return out


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--old-from-git", action="store_true", help="从 git HEAD 取旧 trap(默认从当前 jsonl 已无 trap 时用)")
    parser.add_argument("--jsonl", default="contracts/c6-bench-cases.jsonl")
    args = parser.parse_args()

    # 幂等守护(S5 审计 P2-2): 目标 jsonl 已含 C6-TRAP- → append 会重复; 报错要求先 git checkout/generate。
    current = open(args.jsonl, encoding="utf-8").read()
    if "C6-TRAP-" in current:
        print(
            "ERROR: %s 已含 C6-TRAP- 行, append 会重复。先 `swift run C6BenchCLI generate` 重物化 45 case "
            "(不含 trap), 再跑本脚本。" % args.jsonl,
            file=sys.stderr,
        )
        return 1

    if args.old_from_git:
        old = subprocess.run(["git", "show", "HEAD:contracts/c6-bench-cases.jsonl"], capture_output=True, text=True).stdout
    else:
        old = current

    trap = [json.loads(l) for l in old.splitlines() if l.strip() and json.loads(l)["case_id"].startswith("C6-TRAP-")]
    for c in trap:
        c["expected_tool_calls"] = migrate_tools(c.get("expected_tool_calls", []))
        for alt in c.get("alternatives", []):
            alt["expected_tool_calls"] = migrate_tools(alt.get("expected_tool_calls", []))

    with open(args.jsonl, "a", encoding="utf-8") as f:
        for c in trap:
            f.write(json.dumps(c, ensure_ascii=False, separators=(",", ":")) + "\n")
    print(f"appended {len(trap)} migrated C6-TRAP-* cases to {args.jsonl}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

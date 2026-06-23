#!/usr/bin/env python3
"""C1 派生 model-visible 工具 surface。

A2 S1（D-domain 具名工具目录，2026-06-23）：
- model-visible surface 从 generic frame `tool_call_frame` 迁到 D-domain 具名工具（工具名 = intent 字段，
  device+action 动词+value 形态后缀已编码进名，对标真实座舱「intent==工具名」范式）。
- 🔴 frame_schema()/d_domain_tools()（旧 6 硬编码）S1 **守现状不删**（canonical IR 仍 device×action，
  ToolContractNormalizer frame→IR 拆分 + verify_gold 旧 surface 依赖；S4/S5 全迁后统一删，strangler 防大爆炸）。
  注: S2 已迁 Swift ToolContractCompiler model-visible surface→D-domain; 本脚本 Python frame_schema/d_domain_tools
  及其产物 B_frame.frame_schema.json/D_domain.tools.json/rendered_tools_text 仍含旧 surface(无 runtime 消费, strangler 留到 S4/S5)。
- 新增 D-domain catalog：两层 scope（demo=10族 562 完整 schema / full=全集 1538 三级骨架），单一投影核派生。
- fail-closed 自验证：scope 工具数/口径 ≠ family-device-allowlist.json#caliber 拒写盘。

设计 spec: docs/research/2026-06-23-a2-execution/S1-codegen-design-INDEX.md（综合官 + 主线程亲核）。
"""
import argparse
import json
import re
from pathlib import Path

SNAKE_RE = re.compile(r"^[a-z][a-z0-9_]*$")


def unique(values):
    return sorted({value for value in values if value})


def string_schema(values=None):
    schema = {"type": "string"}
    if values:
        schema["enum"] = values
    return schema


# ----------------------------------------------------------------------------
# 旧 surface（S1 守现状，S4/S5 全迁后删）—— generic frame + 6 硬编码具名工具
# ----------------------------------------------------------------------------
def frame_schema(rows):
    slot_keys = unique(key for row in rows for key in row.get("slot_keys", []))
    value_types = unique(row.get("value", {}).get("type", "") for row in rows)
    properties = {
        "device": string_schema(unique(row.get("device", "") for row in rows)),
        "action_primitive": string_schema(unique(row.get("action_primitive", "") for row in rows)),
        "value.ref": string_schema(),
        "value.direct": string_schema(),
        "value.offset": string_schema(),
        "value.type": string_schema(value_types),
    }
    for key in slot_keys:
        properties.setdefault(key, string_schema())
    return [
        {
            "type": "function",
            "function": {
                "name": "tool_call_frame",
                "description": "Emit exactly one MAformac single-hop ToolCallFrame for offline mock vehicle control.",
                "parameters": {
                    "type": "object",
                    "additionalProperties": True,
                    "required": ["device", "action_primitive"],
                    "properties": properties,
                },
            },
        }
    ]


def d_domain_tools(rows):
    devices = {row.get("device", "") for row in rows}
    names = set()
    if devices & {"ac", "ac_temperature"}:
        names.update({"set_cabin_ac", "query_cabin_comfort"})
    if "ac_windspeed" in devices:
        names.add("set_cabin_fan")
    if "window" in devices:
        names.add("set_cabin_window")
    if "screen_brightness" in devices:
        names.add("set_cabin_screen_brightness")
    if devices & {"atmosphere_lamp_color", "atmosphere_lamp_brightness"}:
        names.add("set_cabin_ambient_light")
    return [
        {
            "type": "function",
            "function": {
                "name": name,
                "description": "D-domain vehicle-control surface derived from the semantic contract.",
                "parameters": {"type": "object", "additionalProperties": True, "properties": {}},
            },
        }
        for name in sorted(names)
    ]


# ----------------------------------------------------------------------------
# 新 surface（A2 S1）—— D-domain 具名工具目录，intent-as-name 派生
# ----------------------------------------------------------------------------
def load_allowlist(path):
    """读 family-device-allowlist.json → (allow_devices set, device→family, caliber)。"""
    data = json.loads(Path(path).read_text(encoding="utf-8"))
    allow_devices = {d for fam in data["families"].values() for d in fam["devices"]}
    device_family = {d: name for name, fam in data["families"].items() for d in fam["devices"]}
    return allow_devices, device_family, data["meta"]["caliber"]


def sanitize_tool_name(name):
    """snake_case gate（受限解码 function name 合法性）。返回 (name, was_sanitized)。"""
    if SNAKE_RE.fullmatch(name):
        return name, False
    return name.lower(), True


def parse_range_enums(intent_rows):
    """从 range 字段（多行 `key=v1|v2|...`）解析每 slot key 的 enum 并集。"""
    enums = {}
    for row in intent_rows:
        for line in (row.get("range") or "").split("\n"):
            line = line.strip()
            if "=" in line:
                key, vals = line.split("=", 1)
                enums.setdefault(key.strip(), set()).update(v for v in vals.split("|") if v)
    return enums


def derive_arg_schema(intent_rows):
    """该 intent 所有行 slot_keys 并集 → properties；range→enum；value.type 非空→value arg。"""
    slot_keys = unique(key for row in intent_rows for key in (row.get("slot_keys") or []))
    enums = parse_range_enums(intent_rows)
    value_types = unique(row.get("value", {}).get("type", "") for row in intent_rows)
    properties = {}
    for key in slot_keys:
        properties[key] = string_schema(sorted(enums[key]) if enums.get(key) else None)
    if value_types:
        properties["value"] = {"type": "string", "value_form": value_types}
    return {"type": "object", "additionalProperties": False, "properties": properties}


def build_d_domain_catalog(rows, scope, allow_devices, device_family):
    """替 d_domain_tools 6 硬编码：groupby intent codegen 具名工具目录。返回 (tools, sanitized_names)。"""
    if scope == "demo":
        scoped = [r for r in rows if r.get("device") in allow_devices]
    else:
        scoped = [r for r in rows if r.get("device")]
    by_intent = {}
    for row in scoped:
        intent = row.get("intent")
        if intent:
            by_intent.setdefault(intent, []).append(row)

    tools = []
    sanitized_names = []
    for intent in sorted(by_intent):
        intent_rows = by_intent[intent]
        name, was_sanitized = sanitize_tool_name(intent)
        if was_sanitized:
            sanitized_names.append(intent)
        device = intent_rows[0].get("device", "")
        if scope == "demo":  # depth=deep: 完整 schema + IR
            tools.append({
                "type": "function",
                "function": {
                    "name": name,
                    "description": "D-domain vehicle-control tool (intent==tool name) derived from semantic contract.",
                    "parameters": derive_arg_schema(intent_rows),
                },
                "_ir": {
                    "device": device,
                    "ir_primitives": unique(r.get("action_primitive", "") for r in intent_rows),
                    "value_types": unique(r.get("value", {}).get("type", "") for r in intent_rows),
                },
                "_domain": device_family.get(device, ""),
                "_sg": device,
            })
        else:  # depth=skeleton: 三级骨架（族外 unsupported 拒识判定，端侧不挂）
            tools.append({
                "name": name,
                "domain": intent_rows[0].get("service", ""),
                "sg": device,
            })
    return tools, sanitized_names


def build_ir_map(demo_tools):
    """工具名→IR dispatch 表（demo，供 runtime/S2 消费）。"""
    return {t["function"]["name"]: t["_ir"] for t in demo_tools}


# 旧 6 粗工具 → D-domain 细具名映射（综合官 strangler_map，供 S4/S5 迁移消费）。
# 🔴 3 grill 待拍点标 TODO（A2 不自拍，留 grill）。
STRANGLER_MAP = {
    "set_cabin_ac": {
        "power=on": "open_ac",
        "power=off": "close_ac",
        "target_temperature=N": "adjust_ac_temperature_to_number",
        "delta=warmer": "raise_ac_temperature_by_exp",
        "delta=cooler": "lower_ac_temperature_by_exp",
        "power=on,target_temperature=N": ["open_ac", "adjust_ac_temperature_to_number"],
    },
    "set_cabin_fan": {
        "level=N": "adjust_ac_windspeed_to_number",
        "delta=stronger": "raise_ac_windspeed_by_exp",
        "delta=weaker": "lower_ac_windspeed_by_exp",
    },
    "set_cabin_window": {
        "percent=100": "open_window",
        "percent=0": "close_window",
        "percent=N": "TODO_GRILL_b_window_position_arg_or_name",
        "delta=more_open": "open_window_little",
    },
    "set_cabin_screen_brightness": {
        "percent=N": "adjust_screen_brightness_to_number",
        "delta=brighter": "raise_screen_brightness_little",
        "delta=dimmer": "lower_screen_brightness_little",
    },
    "set_cabin_ambient_light": {
        "color=X": "switch_atmosphere_lamp_color",
        "brightness_delta=brighter": "raise_atmosphere_lamp_brightness_little",
        "brightness_delta=dimmer": "lower_atmosphere_lamp_brightness_little",
        "power=off": "TODO_GRILL_a_ambient_no_close_intent",
    },
    "query_cabin_comfort": {
        "topic=temperature": "query_ac_temperature",
        "topic=windspeed": "query_ac_windspeed",
    },
}
STRANGLER_GRILL_TODO = [
    "(a) ambient_light power=off 无对应 close intent → 归 switch_atmosphere_lamp_color 还是补 intent",
    "(b) window percent=N 进 arg(open_window_to_number) 还是工具名",
    "(c) 多 IR case (MP-027/028 power=on,target_temperature=N) 吐 1 多义工具还是 2 具名 (范式倾向后者)",
    "car_door 黑洞: 粗 surface 0 工具 (MP-024/025/026 行驶拒识空 call), 细 surface 须含 car_door 族供受限解码白名单",
]


def build_strangler_map(demo_intents):
    """产 strangler_map.json + 交叉验证目标 intent 存在（TODO_ 项跳过）。返回 (map_obj, missing)。"""
    missing = []
    for old_tool, arg_map in STRANGLER_MAP.items():
        for arg_form, target in arg_map.items():
            targets = target if isinstance(target, list) else [target]
            for t in targets:
                if not t.startswith("TODO_") and t not in demo_intents:
                    missing.append(f"{old_tool}[{arg_form}]→{t}")
    return {
        "note": "旧 6 粗工具(set_cabin_*)→D-domain 细具名映射，供 S4/S5 迁移消费。TODO_ 项 = grill 待拍。",
        "map": STRANGLER_MAP,
        "grill_todo": STRANGLER_GRILL_TODO,
    }, missing


def read_jsonl(path):
    rows = []
    with path.open("r", encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows


def write_json(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, sort_keys=True, indent=2) + "\n", encoding="utf-8")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--contract", default="contracts/semantic-function-contract.jsonl")
    parser.add_argument("--output-dir", default="generated")
    parser.add_argument("--allowlist", default="generated/family-device-allowlist.json")
    parser.add_argument("--scope", choices=["demo", "full", "both"], default="both",
                        help="D-domain catalog scope（默认 both 产 demo+full）")
    args = parser.parse_args()

    rows = read_jsonl(Path(args.contract))
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # 旧 surface（守现状 S4/S5 全迁后删）
    b_frame = frame_schema(rows)
    d_domain = d_domain_tools(rows)
    write_json(output_dir / "B_frame.frame_schema.json", b_frame)
    write_json(output_dir / "D_domain.tools.json", d_domain)
    rendered = "\n".join(
        json.dumps(tool, ensure_ascii=False, sort_keys=True, separators=(",", ":")) for tool in b_frame + d_domain
    )
    (output_dir / "rendered_tools_text").write_text(rendered + "\n", encoding="utf-8")

    # 新 D-domain catalog（A2 S1）
    allow_devices, device_family, caliber = load_allowlist(Path(args.allowlist))
    demo_tools, demo_sanitized = build_d_domain_catalog(rows, "demo", allow_devices, device_family)
    full_tools, full_sanitized = build_d_domain_catalog(rows, "full", allow_devices, device_family)
    demo_intents = {t["function"]["name"] for t in demo_tools}

    # fail-closed 自验证（口径自洽门，对齐 family-device-allowlist#caliber）
    demo_devices = {t["_sg"] for t in demo_tools}
    demo_rows = sum(1 for r in rows if r.get("device") in allow_devices)
    full_intents = {t["name"] for t in full_tools}
    errors = []
    if len(demo_tools) != caliber["demo_intents"]:
        errors.append(f"demo tools {len(demo_tools)} != caliber demo_intents {caliber['demo_intents']}")
    if len(demo_devices) != caliber["demo_devices"]:
        errors.append(f"demo devices {len(demo_devices)} != caliber {caliber['demo_devices']}")
    if demo_rows != caliber["demo_rows"]:
        errors.append(f"demo rows {demo_rows} != caliber {caliber['demo_rows']}")
    if len(full_intents) != caliber["total_intents"]:
        errors.append(f"full intents {len(full_intents)} != caliber total_intents {caliber['total_intents']}")
    if len(full_intents) - len(demo_intents) != caliber["oos_intents"]:
        errors.append(f"full-demo {len(full_intents) - len(demo_intents)} != caliber oos_intents {caliber['oos_intents']}")
    # arg ≤5 门（D5）
    over_arg = [t["function"]["name"] for t in demo_tools if len(t["function"]["parameters"]["properties"]) > 5]
    if over_arg:
        errors.append(f"arg>5 violations (D5 门): {over_arg[:5]}")
    if full_sanitized != ["set_Ibooster_mode"] and full_sanitized:
        # full 只应有 set_Ibooster_mode 一个 sanitize；新增异常名告警
        errors.append(f"unexpected full sanitized names: {full_sanitized}")
    if errors:
        raise SystemExit("FAIL D-domain codegen 自洽门:\n  " + "\n  ".join(errors))

    strangler, missing = build_strangler_map(demo_intents)
    if missing:
        raise SystemExit("FAIL strangler_map 目标 intent 不存在(非 TODO):\n  " + "\n  ".join(missing))

    if args.scope in ("demo", "both"):
        write_json(output_dir / "D_domain.tools.demo.json", demo_tools)
        write_json(output_dir / "d_domain_ir_map.json", build_ir_map(demo_tools))
    if args.scope in ("full", "both"):
        write_json(output_dir / "D_domain.tools.full.json", full_tools)
    write_json(output_dir / "strangler_map.json", strangler)

    print(f"D-domain catalog: demo={len(demo_tools)} tools / full={len(full_tools)} tools "
          f"(demo sanitized={demo_sanitized}, full sanitized={full_sanitized}); 自洽门 PASS")


if __name__ == "__main__":
    main()

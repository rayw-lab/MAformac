#!/usr/bin/env python3
"""S0 (A2): 10 族 191 device explicit allowlist — codegen 单源 + 自验证.

SSOT = 本文件 FAM dict（boundary §1 规则物理化，A1-A9 裁决后权威，磊哥 2026-06-23 终拍 562）。
fail-closed 自验证：分类后每族 (device,intent,行) + 总 191/562/2159 + 族外 480/976/1831 全对齐才 emit，
否则 exit 1（防 jsonl 漂移 / 手写 allowlist 错）。manifest 是 codegen 派生物（S1 gen_tool_contract 消费 scope）。

source: docs/research/2026-06-22-mvp-10family-device-boundary.md §1（per-family device/intent/行 三重约束）
        + docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md §14:224（口径终拍 562）
用法: gen_family_allowlist.py --check                      # 仅自验证（make verify 用）
      gen_family_allowlist.py --emit --output-dir generated # 自验证 + 写 manifest
"""
import argparse
import hashlib
import json
import sys
from collections import defaultdict
from pathlib import Path

CONTRACT = "contracts/semantic-function-contract.jsonl"
DEMO_TOOL_CATALOG = "D_domain.tools.demo.json"
TOOL_COUNT_DERIVATION = (
    "ToolContractCompiler.loadDDomainCatalog(repoRoot:).count over generated/D_domain.tools.demo.json; "
    "value-form expanded D-domain named tool catalog, not demo_intents reuse."
)

# 口径权威（磊哥 2026-06-23 终拍 562；boundary §1 per-family 三数）
CALIBER = {
    "total_devices": 671, "total_intents": 1538,
    "demo_devices": 191, "demo_intents": 562, "demo_rows": 2159,
    "oos_devices": 480, "oos_intents": 976, "oos_rows": 1831,
}

# 族 key=英文(codegen 用) / zh=中文 / expect=(device,intent,行) boundary §1
FAMILY_ZH = {
    "ac": "空调", "seat": "座椅", "window": "车窗", "door": "车门", "light": "灯光氛围",
    "screen": "屏幕", "volume": "音量", "wiper": "雨刮", "sunroof": "天窗遮阳帘", "fragrance": "香氛",
}
EXPECT = {
    "ac": (25, 68, 212), "seat": (36, 126, 696), "window": (11, 27, 82), "door": (21, 48, 129),
    "light": (29, 113, 468), "screen": (33, 75, 205), "volume": (11, 32, 153), "wiper": (8, 27, 80),
    "sunroof": (10, 30, 102), "fragrance": (7, 16, 32),
}

# 191 device explicit allowlist（boundary §1 规则物理化，三重约束坐实 191/562/2159）
FAM = {
    "ac": [  # ac* + airoutlet + defog/defrost/dehumid + loop + zone_sync + 通风加湿净化消毒 + 延时/减风量 + 呼吸 + 个性化
        "ac", "ac_cooling_mode", "ac_heating_mode", "ac_mode", "ac_set_interface", "ac_temperature",
        "ac_wind_direction", "ac_windspeed", "airoutlet", "airoutlet_direction", "defog_mode", "defrost_mode",
        "dehumidification_mode", "loop_mode", "zone_synchronization_mode", "ventilation_system", "humidifier",
        "air_clean", "cabin_disinfect", "blower_delay_shutdown", "timed_ventilation", "timed_ventilation_interval",
        "wind_reduction", "breathe_system", "other_personalize_mode",
    ],
    "seat": [  # 29 seat_ + 7 headrest（方向 4 + 音响 3）；排除 console_*/comfortable_entry_exit(车门)
        "seat_adjustment_set_interface", "seat_backrest", "seat_belt_comfort_adjuster", "seat_belt_heat",
        "seat_belt_heat_temperature", "seat_belt_vibration_alert", "seat_cushion", "seat_feet_support", "seat_flank",
        "seat_folding_lock", "seat_heat", "seat_heat_mode", "seat_heat_temperature", "seat_leg_support",
        "seat_lumbar_support", "seat_massage", "seat_massage_force", "seat_massage_mode", "seat_massage_time",
        "seat_memory", "seat_memory_bind", "seat_mode", "seat_position", "seat_position_adjustment", "seat_rhythm_mode",
        "seat_shoulder_support", "seat_ventilation", "seat_ventilation_mode", "seat_ventilation_windspeed",
        "headrest_direction", "headrest_direction_adjust", "headrest_direction_ear_slice_adjust", "headrest_ear_slice_direction",
        "headrest_audio_system", "headrest_audio_system_mode", "headrest_directional_broadcast",
    ],
    "window": [  # window* + back_window + remote_control_window + automatic_window_* + windshield_heating
        "window", "window_breathe_mode", "window_curtain", "window_lock", "window_slide", "window_ventilation_mode",
        "back_window", "remote_control_window", "automatic_window_opening", "automatic_window_closing", "windshield_heating",
    ],
    "door": [  # door开闭锁 + 儿童/中控锁 + lock/unlock + engine_hood + fuel_tank_cap + glove + tailgate* + comfortable_entry_exit
        "door", "door_height", "door_speed", "car_door", "maximum_of_door_opening",
        "child_lock", "central_lock", "lock_mode", "unlock_mode", "engine_hood", "fuel_tank_cap",
        "glove_compartment", "glove_compartment_password",
        "tailgate", "tailgate_height", "tailgate_height_to_highest", "tailgate_height_to_lowest",
        "tailgate_opening_upper_limit", "tailgate_sensing", "electric_tailgate_switch", "comfortable_entry_exit",
    ],
    "light": [  # atmosphere_lamp* + designative_in/out + dimming_glass_top* + light_show/game/expr/theme/sensor + luggage + headliner + 照明开关
        "atmosphere_lamp", "atmosphere_lamp_brightness", "atmosphere_lamp_change_speed", "atmosphere_lamp_color", "atmosphere_lamp_mode",
        "designative_in_car_lamp", "designative_in_car_lamp_brightness", "designative_in_car_lamp_color_temperature", "designative_in_car_lamp_time",
        "designative_out_car_lamp", "designative_out_car_lamp_angle", "designative_out_car_lamp_mode", "designative_out_car_lamp_time",
        "dimming_glass_top", "dimming_glass_top_brightness", "dimming_glass_top_color", "dimming_glass_top_mode", "dimming_glass_top_transparency",
        "light_show", "continue_light_show", "light_game", "light_expression", "light_theme", "light_sensor",
        "illuminated_luggage_rack", "luminous_luggage_rack_color", "luminous_luggage_rack_brightness",
        "headliner", "the_lighting_start_switch",
    ],
    "screen": [  # screen* + split_screen* + landscape + rotate_screen* + 显示亮度界面 + 仪表屏 + wallpaper/theme*/desktop/auto_theme + blue_ray + touch_screen
        "screen", "screen_auto_rotate", "screen_brightness", "screen_brightness_mode", "screen_brightness_synchronization_mode",
        "screen_cleaning", "screen_color_mode", "screen_content", "screen_direction", "screen_display_mode",
        "screen_module_zoom_in", "screen_module_zoom_out", "screen_navigation_lighting_effect", "screen_recording", "screen_rotate",
        "screen_saver", "screen_to_direction", "split_screen", "split_screen_max", "split_screen_min",
        "rotate_screen", "rotate_screen_to_direction", "landscape_mode", "display_brightness_set_interface", "instrument_screen_mode",
        "wallpaper", "theme", "theme_type", "desktop_mode", "automatic_theme_switching", "download_theme", "blue_ray_filtering", "touch_screen",
    ],
    "volume": [  # volume* + mute/unmute + current_volume + loundness + noise_volume_compensation*
        "volume", "volume_banlance", "volume_external_playback_mode", "volume_gradually_in_and_out", "volume_mode",
        "volume_mute", "volume_unmute", "current_volume", "loundness", "noise_volume_compensation", "noise_volume_compensation_to_gearpeed",
    ],
    "wiper": [  # wiper* + the_rain_sensor
        "wiper", "wiper_maintenance", "wiper_mode", "wiper_sensitivity", "wiper_set_interface", "wiper_speed", "wiper_wash", "the_rain_sensor",
    ],
    "sunroof": [  # sunroof* + sunshade* + blocking_glass + car_film_transparency
        "sunroof", "sunroof_breathe_mode", "sunroof_heat_mode", "sunroof_slide", "sunroof_tilt", "sunroof_ventilation_mode",
        "sunshade", "sunshade_slide", "blocking_glass", "car_film_transparency",
    ],
    "fragrance": [  # fragrance* + amount_of_fragrance + mode_of_fragrance
        "fragrance", "fragrance_intensity", "fragrance_mode", "fragrance_set_interface", "fragrance_time", "amount_of_fragrance", "mode_of_fragrance",
    ],
}


def read_contract(repo_root: Path) -> list:
    rows = []
    with (repo_root / CONTRACT).open("r", encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows


def classify(rows: list) -> dict:
    """返回 {device: {rows, intents:set}} + 校验结构。"""
    dev_rows: dict = defaultdict(int)
    dev_intents: dict = defaultdict(set)
    for row in rows:
        device = row.get("device")
        if device:
            dev_rows[device] += 1
            if row.get("intent"):
                dev_intents[device].add(row["intent"])
    return dev_rows, dev_intents


def validate(dev_rows: dict, dev_intents: dict) -> tuple:
    """fail-closed 自验证。返回 (ok: bool, report: list[str], assigned: dict)。"""
    report = []
    assigned: dict = {}
    ok = True
    tot_d = tot_i = tot_r = 0
    for fam, devices in FAM.items():
        devices = list(dict.fromkeys(devices))
        missing = [d for d in devices if d not in dev_rows]
        fam_intents: set = set()
        fam_rows = 0
        for device in devices:
            if device in assigned:
                report.append(f"FAIL double-assign: {device} in {assigned[device]} + {fam}")
                ok = False
            assigned[device] = fam
            if device in dev_rows:
                fam_rows += dev_rows[device]
                fam_intents |= dev_intents[device]
        exp_d, exp_i, exp_r = EXPECT[fam]
        match = (len(devices) == exp_d and len(fam_intents) == exp_i and fam_rows == exp_r and not missing)
        ok = ok and match
        report.append(
            f"{'OK ' if match else 'FAIL'} {fam}({FAMILY_ZH[fam]}): "
            f"device {len(devices)}/{exp_d} intent {len(fam_intents)}/{exp_i} 行 {fam_rows}/{exp_r}"
            + (f" MISSING:{missing}" if missing else "")
        )
        tot_d += len(devices)
        tot_i += len(fam_intents)
        tot_r += fam_rows
    total_match = (tot_d == CALIBER["demo_devices"] and tot_i == CALIBER["demo_intents"] and tot_r == CALIBER["demo_rows"])
    ok = ok and total_match
    report.append(
        f"{'OK ' if total_match else 'FAIL'} TOTAL: device {tot_d}/{CALIBER['demo_devices']} "
        f"intent {tot_i}/{CALIBER['demo_intents']} 行 {tot_r}/{CALIBER['demo_rows']}"
    )
    # 族外
    out_devices = [d for d in dev_rows if d not in assigned]
    out_intents: set = set()
    out_rows = 0
    for device in out_devices:
        out_rows += dev_rows[device]
        out_intents |= dev_intents[device]
    oos_match = (len(out_devices) == CALIBER["oos_devices"] and len(out_intents) == CALIBER["oos_intents"] and out_rows == CALIBER["oos_rows"])
    ok = ok and oos_match
    report.append(
        f"{'OK ' if oos_match else 'FAIL'} OUT_OF_SCOPE: device {len(out_devices)}/{CALIBER['oos_devices']} "
        f"intent {len(out_intents)}/{CALIBER['oos_intents']} 行 {out_rows}/{CALIBER['oos_rows']}"
    )
    return ok, report, assigned


def read_demo_tool_count(output_dir: Path) -> int:
    catalog_path = output_dir / DEMO_TOOL_CATALOG
    try:
        catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise SystemExit(f"FAIL: missing D-domain demo catalog for tool_count: {catalog_path}") from exc
    if not isinstance(catalog, list):
        raise SystemExit(f"FAIL: D-domain demo catalog is not a list: {catalog_path}")
    return len(catalog)


def build_manifest(repo_root: Path, output_dir: Path, dev_rows: dict, dev_intents: dict, assigned: dict) -> dict:
    contract_path = repo_root / CONTRACT
    sha = hashlib.sha256(contract_path.read_bytes()).hexdigest()
    tool_count = read_demo_tool_count(output_dir)
    families = {}
    for fam, devices in FAM.items():
        devices = list(dict.fromkeys(devices))
        intents = sorted({i for d in devices for i in dev_intents.get(d, set())})
        families[fam] = {
            "zh": FAMILY_ZH[fam],
            "scope": "demo",
            "device_count": len(devices),
            "intent_count": len(intents),
            "row_count": sum(dev_rows.get(d, 0) for d in devices),
            "devices": sorted(devices),
        }
    return {
        "meta": {
            "purpose": "10 族 191 device explicit allowlist — S1 codegen scope 单源（demo=10族 / full=全集）",
            "source": "docs/research/2026-06-22-mvp-10family-device-boundary.md §1 + paradigm §14:224（磊哥 2026-06-23 终拍 562）",
            "verify_command": "python3 scripts/gen_family_allowlist.py --check",
            "contract_source": CONTRACT,
            "contract_sha256": sha,
            "caliber": CALIBER,
            "tool_count": tool_count,
            "tool_count_derivation": TOOL_COUNT_DERIVATION,
            "scope_tier_detail": "DEFERRED — positive/unsupported/safety/followup 四类 LoRA 数据细分属 retrain-c5（A2 code-only 仅 demo/oos scope）",
            "col_o_priority": "DEFERRED — runtime 端侧挂载优先级（raw xlsx 第15列），A2 code-only surface 不需",
        },
        "families": families,
        "out_of_scope": {
            "scope": "unsupported",
            "device_count": CALIBER["oos_devices"],
            "intent_count": CALIBER["oos_intents"],
            "row_count": CALIBER["oos_rows"],
            "note": "族外 480 device → L3 unsupported tier（拒识兜底，不挂精做工具）",
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="仅自验证（fail-closed）")
    parser.add_argument("--emit", action="store_true", help="自验证 + 写 manifest")
    parser.add_argument("--repo-root", default=".")
    parser.add_argument("--output-dir", default="generated")
    args = parser.parse_args()

    repo_root = Path(args.repo_root)
    rows = read_contract(repo_root)
    dev_rows, dev_intents = classify(rows)
    ok, report, assigned = validate(dev_rows, dev_intents)
    for line in report:
        print(line)
    if not ok:
        print("FAIL: family allowlist 自验证未通过（jsonl 漂移或 FAM allowlist 错），拒绝 emit", file=sys.stderr)
        return 1
    output_dir = repo_root / args.output_dir
    tool_count = read_demo_tool_count(output_dir)
    print(f"OK D_DOMAIN_TOOL_COUNT: {tool_count} from {output_dir / DEMO_TOOL_CATALOG}")
    if args.emit:
        out_dir = output_dir
        out_dir.mkdir(parents=True, exist_ok=True)
        manifest = build_manifest(repo_root, output_dir, dev_rows, dev_intents, assigned)
        out_path = out_dir / "family-device-allowlist.json"
        out_path.write_text(json.dumps(manifest, ensure_ascii=False, sort_keys=True, indent=2) + "\n", encoding="utf-8")
        print(f"wrote {out_path}")
        # flat device→family map（191 demo，重生成替换旧 223 orphan，dispatch §0[0]；含 A1-A9 裁决后无 disputed）
        device_map = {
            dev: {"family": fam, "family_zh": FAMILY_ZH[fam], "scope": "demo"}
            for fam, devices in FAM.items() for dev in dict.fromkeys(devices)
        }
        map_path = out_dir / "10-family-device-map.json"
        map_path.write_text(json.dumps(device_map, ensure_ascii=False, sort_keys=True, indent=2) + "\n", encoding="utf-8")
        print(f"wrote {map_path} ({len(device_map)} devices)")
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""Adapt S6 register-window rows into C5TrainingCLI natural-tool-call rows.

This keeps the S6 pool immutable. The adapter emits the legacy natural row
shape that C5TrainingCLI already consumes, plus a mapping receipt that proves
which S6 row mapped to which C1 contract row and variant.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any

import yaml


Json = dict[str, Any]

DEVICE_CELL_MAP = {
    "ac": "ac.power",
    "ac_temperature": "ac.temp_setpoint",
    "ac_windspeed": "ac.fan_speed",
    "window": "window.position",
    "screen_brightness": "screen.brightness",
    "atmosphere_lamp_color": "ambient.color",
    "atmosphere_lamp_brightness": "ambient.brightness",
    "seat_heat_temperature": "seat.heat_level",
    "seat_ventilation_windspeed": "seat.vent_level",
    "seat_massage_force": "seat.massage_force",
    "seat_backrest": "seat.backrest_angle",
    "car_door": "door.car_door",
    "central_lock": "door.central_lock",
    "child_lock": "door.child_lock",
    "tailgate_height": "door.tailgate_height",
    "volume": "volume.level",
    "volume_mute": "volume.mute",
    "wiper": "wiper.power",
    "wiper_speed": "wiper.speed",
    "sunroof": "sunroof.position",
    "sunroof_slide": "sunroof.motion",
    "sunshade": "sunshade.position",
    "fragrance": "fragrance.power",
    "fragrance_intensity": "fragrance.intensity",
}


def slot_keys_for_cell(cell_id: str) -> list[str]:
    if cell_id == "screen.brightness":
        return ["screen_type"]
    if cell_id == "ambient.brightness":
        return ["name"]
    if cell_id in {"ac.temp_setpoint", "ac.fan_speed"}:
        return ["direction", "position"]
    return ["position", "direction"]


def load_jsonl(path: Path) -> list[Json]:
    rows: list[Json] = []
    with path.open(encoding="utf-8") as handle:
        for raw in handle:
            if raw.strip():
                rows.append(json.loads(raw))
    return rows


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def canonical_json(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def render_tool_call(name: str, arguments: Json) -> str:
    payload = '{"name":' + canonical_json(name) + ',"arguments":' + canonical_json(arguments) + "}"
    return f"<tool_call>{payload}</tool_call>"


def parse_range(range_text: str) -> dict[str, list[str]]:
    parsed: dict[str, list[str]] = {}
    for raw in (range_text or "").splitlines():
        line = raw.strip()
        if "=" not in line:
            continue
        key, values_text = line.split("=", 1)
        values = [
            value.strip()
            for value in values_text.split("|")
            if value.strip() and not is_placeholder(value.strip())
        ]
        if key.strip() and values:
            parsed[key.strip()] = values
    return parsed


def is_placeholder(value: str) -> bool:
    return value.startswith("<") and value.endswith(">")


def fixed_semantic_slot(value: Any) -> str | None:
    if not isinstance(value, str):
        return None
    trimmed = value.strip()
    if not trimmed or is_placeholder(trimmed):
        return None
    return trimmed


def is_scope_like_slot(key: str) -> bool:
    normalized = key.lower()
    return (
        "position" in normalized
        or "direction" in normalized
        or "screen_type" in normalized
        or "name" in normalized
    )


def load_scope_candidates(state_cells_path: Path) -> tuple[dict[str, list[str]], dict[str, dict[str, list[str]]]]:
    data = yaml.safe_load(state_cells_path.read_text(encoding="utf-8"))
    cells_by_id: dict[str, Json] = {}
    for device in (data.get("devices") or {}).values():
        for cell in device.get("state_cells") or []:
            if isinstance(cell, dict) and cell.get("id"):
                cells_by_id[str(cell["id"])] = cell

    by_device: dict[str, dict[str, list[str]]] = {}
    by_slot: dict[str, list[str]] = defaultdict(list)
    for device, cell_id in sorted(DEVICE_CELL_MAP.items()):
        scope = cells_by_id.get(cell_id, {}).get("scope") or []
        if not scope:
            continue
        for slot in slot_keys_for_cell(cell_id):
            values = [str(value) for value in scope if str(value)]
            by_device.setdefault(device, {})[slot] = values
            seen = set(by_slot[slot])
            for value in values:
                if value not in seen:
                    by_slot[slot].append(value)
                    seen.add(value)
    return dict(by_slot), by_device


def scope_candidates(
    key: str,
    seed: Json,
    by_slot: dict[str, list[str]],
    by_device: dict[str, dict[str, list[str]]],
) -> list[str]:
    normalized = key.lower()
    device_slots = by_device.get(str(seed.get("device") or ""), {})
    return device_slots.get(key) or device_slots.get(normalized) or by_slot.get(key) or by_slot.get(normalized) or []


def value_strategy(value_type: str) -> str:
    normalized = value_type.upper()
    if normalized == "EXP":
        return "exp_inverse_normalize"
    if normalized == "PERCENT":
        return "percent_extract"
    return "slot_extract"


def spot_choices(offset: str) -> list[str]:
    if "温" in offset:
        return ["20", "22", "24", "26"]
    if "百分" in offset:
        return ["25", "50", "75"]
    if "档" in offset:
        return ["1", "3", "5", "7"]
    return ["1", "2", "3", "4"]


def augment_value(seed: Json, variant: int) -> tuple[Json, bool]:
    value = dict(seed.get("value") or {})
    value_type = str(value.get("type") or "")
    if not value_type:
        return value, False
    strategy = value_strategy(value_type)
    if strategy == "slot_extract":
        choices = spot_choices(str(value.get("offset") or ""))
        value["offset"] = choices[variant % len(choices)]
        return value, True
    if strategy == "percent_extract":
        choices = ["10", "25", "50", "75", "100"]
        value["offset"] = choices[variant % len(choices)]
        return value, True
    return value, True


def fallback_slot_value(
    key: str,
    seed: Json,
    variant: int,
    value: Json,
    by_slot: dict[str, list[str]],
    by_device: dict[str, dict[str, list[str]]],
) -> str:
    normalized = key.lower()
    if is_scope_like_slot(key):
        candidates = scope_candidates(key, seed, by_slot, by_device)
    elif "color" in normalized:
        candidates = ["蓝色", "暖白", "红色", "紫色"]
    elif "mode" in normalized:
        candidates = ["自动", "强力", "低档", "高档"]
    elif "name" in normalized:
        candidates = ["阅读灯", "氛围灯", "车窗", str(seed.get("device") or "")]
    elif "temperature" in normalized or "temp" in normalized:
        candidates = ["22", "24", "26", "20"]
    elif "percent" in normalized:
        candidates = ["25", "50", "75", "100"]
    elif "action" in normalized:
        candidates = [str(seed.get("action_primitive") or "")]
    elif value.get("offset") and not is_placeholder(str(value.get("offset"))):
        candidates = [str(value.get("offset"))]
    else:
        candidates = [f"{key}_value_{(variant % 4) + 1}"]
    return candidates[variant % len(candidates)] if candidates else f"{key}_value_{(variant % 4) + 1}"


def slot_assignments(
    seed: Json,
    variant: int,
    value: Json,
    by_slot: dict[str, list[str]],
    by_device: dict[str, dict[str, list[str]]],
) -> dict[str, str]:
    assignments: dict[str, str] = {}
    range_map = parse_range(str(seed.get("range") or ""))
    semantic_slots = ((seed.get("ds_protocol") or {}).get("semantic") or {}).get("slots") or {}
    for key in seed.get("slot_keys") or []:
        c2_candidates = scope_candidates(key, seed, by_slot, by_device)
        if key == "device":
            assignments[key] = str(seed.get("device") or "")
        elif key == "action_primitive":
            assignments[key] = str(seed.get("action_primitive") or "")
        elif fixed := fixed_semantic_slot(semantic_slots.get(key)):
            assignments[key] = fixed
        elif is_scope_like_slot(key) and c2_candidates:
            assignments[key] = c2_candidates[variant % len(c2_candidates)]
        elif range_map.get(key):
            values = range_map[key]
            assignments[key] = values[variant % len(values)]
        else:
            assignments[key] = fallback_slot_value(key, seed, variant, value, by_slot, by_device)
    return assignments


def property_enums(catalog_entry: Json) -> dict[str, list[str]]:
    props = (((catalog_entry.get("function") or {}).get("parameters") or {}).get("properties") or {})
    result: dict[str, list[str]] = {}
    for key, schema in props.items():
        enum_values = schema.get("enum") if isinstance(schema, dict) else None
        result[key] = [str(value) for value in enum_values] if isinstance(enum_values, list) else []
    return result


def ddomain_arguments(
    seed: Json,
    variant: int,
    catalog_entry: Json,
    by_slot: dict[str, list[str]],
    by_device: dict[str, dict[str, list[str]]],
) -> Json:
    value, _ = augment_value(seed, variant)
    assignments = slot_assignments(seed, variant, value, by_slot, by_device)
    enums = property_enums(catalog_entry)
    args: Json = {}
    if "value" in enums:
        value_text = str(value.get("offset") or value.get("direct") or "")
        if value_text and not is_placeholder(value_text):
            args["value"] = value_text
    for key, assigned in assignments.items():
        if key in {"device", "action_primitive"} or key not in enums:
            continue
        if not assigned or is_placeholder(assigned):
            continue
        allowed = enums[key]
        args[key] = assigned if not allowed or assigned in allowed else allowed[variant % len(allowed)]
    return args


def arguments_schema_compatible(arguments: Json, catalog_entry: Json) -> bool:
    props = (((catalog_entry.get("function") or {}).get("parameters") or {}).get("properties") or {})
    if not isinstance(props, dict):
        return not arguments
    for key, value in arguments.items():
        schema = props.get(key)
        if not isinstance(schema, dict):
            return False
        enum_values = schema.get("enum")
        if isinstance(enum_values, list) and enum_values:
            allowed = {str(item) for item in enum_values}
            if not isinstance(value, str) or value not in allowed:
                return False
    return True


def normalize_expected_arguments(arguments: Json, catalog_entry: Json) -> tuple[Json, list[Json]]:
    props = (((catalog_entry.get("function") or {}).get("parameters") or {}).get("properties") or {})
    if not isinstance(props, dict):
        return dict(arguments), []
    normalized = dict(arguments)
    aliases: list[Json] = []
    for source_key, target_key in (("gear", "value"), ("value", "fanSpeed")):
        if source_key in normalized and source_key not in props and target_key in props:
            normalized[target_key] = normalized.pop(source_key)
            aliases.append({"from": source_key, "to": target_key})
    return normalized, aliases


def argument_relation(rendered_args: Json, expected_args: Json, catalog_entry: Json) -> str | None:
    if rendered_args == expected_args:
        return "exact"
    if all(rendered_args.get(key) == value for key, value in expected_args.items()):
        return "expected_subset_of_builder_default"
    if arguments_schema_compatible(expected_args, catalog_entry):
        return "natural_target_schema_override"
    return None


def prompt_hash(utterance: str) -> str:
    return hashlib.sha256(utterance.encode("utf-8")).hexdigest()


def adapt(args: argparse.Namespace) -> int:
    pool_path = Path(args.s6_pool)
    rows = load_jsonl(pool_path)
    seeds = load_jsonl(Path(args.semantic_contract))
    catalog = json.loads(Path(args.d_domain_catalog).read_text(encoding="utf-8"))
    catalog_by_name = {entry["function"]["name"]: entry for entry in catalog}
    by_slot, by_device = load_scope_candidates(Path(args.state_cells))
    seeds_by_intent: dict[str, list[Json]] = defaultdict(list)
    for seed in seeds:
        if seed.get("intent") in catalog_by_name:
            seeds_by_intent[str(seed["intent"])].append(seed)
    for intent in seeds_by_intent:
        seeds_by_intent[intent].sort(key=lambda seed: str(seed.get("contract_row_id") or ""))

    used_keys: set[tuple[str, int]] = set()
    output_rows: list[Json] = []
    mapped: list[Json] = []
    unmapped: list[Json] = []
    skipped = Counter()

    for index, row in enumerate(rows, 1):
        calls = row.get("expected_tool_calls") or []
        if not calls:
            skipped["no_expected_tool_calls"] += 1
            continue
        if len(calls) != 1 or not isinstance(calls[0], dict):
            skipped["unsupported_multi_or_non_dict_call"] += 1
            unmapped.append({"row_id": row.get("row_id"), "reason": "unsupported_expected_tool_calls_shape"})
            continue
        call = calls[0]
        name = str(call.get("name") or "")
        source_expected_args = call.get("arguments") or {}
        if not name or not isinstance(source_expected_args, dict):
            skipped["invalid_call"] += 1
            unmapped.append({"row_id": row.get("row_id"), "reason": "invalid_expected_call"})
            continue
        entry = catalog_by_name.get(name)
        if entry is None:
            skipped["unknown_tool"] += 1
            unmapped.append({"row_id": row.get("row_id"), "reason": "unknown_expected_tool", "tool_name": name})
            continue
        expected_args, aliases = normalize_expected_arguments(source_expected_args, entry)
        candidates: list[tuple[int, str, Json, int, Json]] = []
        relation_rank = {
            "exact": 0,
            "expected_subset_of_builder_default": 1,
            "natural_target_schema_override": 2,
        }
        for seed in seeds_by_intent.get(name, []):
            for variant in range(args.max_variants_per_seed):
                key = (str(seed.get("contract_row_id")), variant)
                if key in used_keys:
                    continue
                rendered_args = ddomain_arguments(seed, variant, entry, by_slot, by_device)
                relation = argument_relation(rendered_args, expected_args, entry)
                if relation is not None:
                    candidates.append((relation_rank[relation], relation, seed, variant, rendered_args))
        if not candidates:
            unmapped.append({
                "row_id": row.get("row_id"),
                "utterance": row.get("utterance"),
                "tool_name": name,
                "source_expected_arguments": source_expected_args,
                "normalized_expected_arguments": expected_args,
                "reason": "no_matching_c1_seed_variant",
            })
            continue
        candidates.sort(key=lambda item: (item[0], str(item[2].get("contract_row_id") or ""), item[3]))
        _, relation, seed, variant, rendered_args = candidates[0]
        used_keys.add((str(seed.get("contract_row_id")), variant))
        target = render_tool_call(name, expected_args)
        output_rows.append({
            "contract_row_id": seed["contract_row_id"],
            "variant": variant,
            "user": row.get("utterance") or row.get("input_zh") or "",
            "target": target,
            "generator_model_id": row.get("generator_model_id") or "s6-register-window-adapter",
            "generator_source_vendor": row.get("generator_source_vendor") or "register-window-s6",
            "generator_call_id": row.get("row_id") or f"s6-row-{index}",
            "semantic_judge_model_id": row.get("semantic_judge_model_id") or "s6-final-authority",
            "semantic_judge_call_id": row.get("final_authority_key_v3", {}).get("normalized_input") or row.get("row_id") or f"s6-row-{index}",
            "prompt_hash": row.get("prompt_hash") or prompt_hash(row.get("utterance") or ""),
        })
        mapped.append({
            "s6_row_id": row.get("row_id"),
            "contract_row_id": seed["contract_row_id"],
            "variant": variant,
            "tool_name": name,
            "source_expected_arguments": source_expected_args,
            "target_arguments": expected_args,
            "builder_default_arguments": rendered_args,
            "argument_relation": relation,
            "argument_aliases": aliases,
        })

    out_path = Path(args.output)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(
        "".join(json.dumps(row, ensure_ascii=False, sort_keys=True, separators=(",", ":")) + "\n" for row in output_rows),
        encoding="utf-8",
    )
    receipt = {
        "status": "PASS" if not unmapped else "FAIL",
        "artifact_kind": "s7_register_window_natural_rows_adapter_receipt",
        "basis_id": args.basis_id,
        "s6_pool": str(pool_path),
        "s6_pool_sha256": sha256(pool_path),
        "input_rows": len(rows),
        "action_rows": len(output_rows) + len(unmapped),
        "mapped_rows": len(output_rows),
        "unmapped_rows": len(unmapped),
        "skipped_counts": dict(sorted(skipped.items())),
        "output": str(out_path),
        "output_sha256": sha256(out_path),
        "max_variants_per_seed": args.max_variants_per_seed,
        "mapping_examples": mapped[:20],
        "unmapped_examples": unmapped[:20],
        "non_claims": [
            "does_not_modify_s6_pool",
            "does_not_convert_no_tool_rows_into_action_rows",
            "does_not_sign_candidate",
            "does_not_launch_training",
        ],
    }
    receipt_path = Path(args.receipt)
    receipt_path.parent.mkdir(parents=True, exist_ok=True)
    receipt_path.write_text(json.dumps(receipt, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps(receipt, ensure_ascii=False, indent=2, sort_keys=True))
    return 0 if receipt["status"] == "PASS" else 66


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--s6-pool", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--receipt", required=True)
    parser.add_argument("--semantic-contract", default="contracts/semantic-function-contract.jsonl")
    parser.add_argument("--d-domain-catalog", default="generated/D_domain.tools.demo.json")
    parser.add_argument("--state-cells", default="contracts/state-cells.yaml")
    parser.add_argument("--basis-id", default="DATA-REGISTER-RW-v1")
    parser.add_argument("--max-variants-per-seed", type=int, default=8)
    return parser.parse_args()


if __name__ == "__main__":
    raise SystemExit(adapt(parse_args()))

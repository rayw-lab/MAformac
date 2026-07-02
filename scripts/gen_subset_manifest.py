#!/usr/bin/env python3
"""E-2 subset policy manifest + grammar data artifact codegen.

Phase-1 construction only:
- reads the generated D-domain demo catalog as the only tool surface source;
- emits data artifacts, not vendor-compiled grammars;
- optionally runs the local Qwen tokenizer budget gate.
"""

import argparse
import hashlib
import itertools
import json
import sys
from collections import defaultdict
from pathlib import Path

try:
    import yaml
except ImportError:  # pragma: no cover - make's venv installs PyYAML.
    yaml = None


POLICY_ID = "e2-lite-v1"
TOKENIZER_ID = "mlx-community/Qwen3-1.7B-4bit"
QWEN_FORMAT_VERSION = "qwen-tool-call-format.v1"
GRAMMAR_BUILDER_VERSION = "subset-grammar-data.v1"
TOOL_TOKENS_CAP = 7200
DISTRACTOR_POLICY = {
    "strategy": "same_sg_then_same_domain_then_other",
    "k": 3,
}
NO_TOOL_OUTLET = {
    "type": "function",
    "function": {
        "name": "NO_TOOL",
        "description": "Virtual no-tool outlet for mounted subset policy.",
        "parameters": {
            "type": "object",
            "additionalProperties": False,
            "required": ["reason"],
            "properties": {
                "reason": {
                    "type": "string",
                    "enum": [
                        "group_out_of_mount",
                        "mvp_unsupported",
                        "global_unsupported",
                        "safety_or_policy",
                        "need_clarify",
                    ],
                }
            },
        },
    },
}

SEAT_GROUPS = {
    "seat.heat": [
        "seat_belt_heat",
        "seat_belt_heat_temperature",
        "seat_heat",
        "seat_heat_mode",
        "seat_heat_temperature",
    ],
    "seat.ventilation": [
        "seat_ventilation",
        "seat_ventilation_mode",
        "seat_ventilation_windspeed",
    ],
    "seat.massage_force_time": [
        "seat_massage",
        "seat_massage_force",
        "seat_massage_time",
    ],
    "seat.massage_mode_rhythm": [
        "seat_massage_mode",
        "seat_rhythm_mode",
    ],
    "seat.posture_back_head": [
        "headrest_direction",
        "headrest_direction_adjust",
        "headrest_direction_ear_slice_adjust",
        "headrest_ear_slice_direction",
        "seat_backrest",
        "seat_lumbar_support",
        "seat_shoulder_support",
    ],
    "seat.posture_base_leg": [
        "seat_adjustment_set_interface",
        "seat_cushion",
        "seat_feet_support",
        "seat_flank",
        "seat_folding_lock",
        "seat_leg_support",
        "seat_position",
        "seat_position_adjustment",
    ],
    "seat.mode_memory_safety": [
        "headrest_audio_system",
        "headrest_audio_system_mode",
        "headrest_directional_broadcast",
        "seat_belt_comfort_adjuster",
        "seat_belt_vibration_alert",
        "seat_memory",
        "seat_memory_bind",
        "seat_mode",
    ],
}

WHOLE_DOMAIN_SINGLE_GROUPS = {"door", "fragrance", "sunroof", "window", "wiper"}


def canonical_json(value) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def digest(value) -> str:
    if not isinstance(value, str):
        value = canonical_json(value)
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def write_json(path: Path, value) -> None:
    path.write_text(json.dumps(value, ensure_ascii=False, sort_keys=True, indent=2) + "\n", encoding="utf-8")


def read_catalog(path: Path) -> list[dict]:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, list):
        raise SystemExit(f"FAIL: catalog must be a list: {path}")
    required = {"_domain", "_sg", "_ir", "function"}
    errors = []
    names = set()
    for index, item in enumerate(data):
        missing = sorted(required - set(item))
        if missing:
            errors.append(f"catalog[{index}] missing {missing}")
        function = item.get("function") or {}
        name = function.get("name")
        if not name:
            errors.append(f"catalog[{index}] missing function.name")
        elif name in names:
            errors.append(f"duplicate tool name: {name}")
        names.add(name)
    if errors:
        raise SystemExit("FAIL: invalid D-domain catalog:\n  " + "\n  ".join(errors[:20]))
    return data


def tool_id(item: dict) -> str:
    return item["function"]["name"]


def tool_schema(item: dict) -> dict:
    function = item["function"]
    return {
        "name": function["name"],
        "parameters": function.get("parameters", {"type": "object", "properties": {}}),
    }


def prompt_tool_schema(item: dict) -> dict:
    function = item["function"]
    return {
        "type": "function",
        "function": {
            "name": function["name"],
            "description": function.get("description", ""),
            "parameters": function.get("parameters", {"type": "object", "properties": {}}),
        },
    }


def tools_by_sg(catalog: list[dict]) -> dict[str, list[dict]]:
    grouped: dict[str, list[dict]] = defaultdict(list)
    for item in catalog:
        grouped[item["_sg"]].append(item)
    return {key: sorted(value, key=tool_id) for key, value in grouped.items()}


def tools_by_domain(catalog: list[dict]) -> dict[str, list[dict]]:
    grouped: dict[str, list[dict]] = defaultdict(list)
    for item in catalog:
        grouped[item["_domain"]].append(item)
    return {key: sorted(value, key=tool_id) for key, value in grouped.items()}


def build_single_groups(catalog: list[dict]) -> list[tuple[str, list[dict]]]:
    by_domain = tools_by_domain(catalog)
    by_sg = tools_by_sg(catalog)
    groups: list[tuple[str, list[dict]]] = []

    seat_sgs = {item["_sg"] for item in by_domain.get("seat", [])}
    assigned_seat_sgs = {sg for sgs in SEAT_GROUPS.values() for sg in sgs}
    if seat_sgs and seat_sgs != assigned_seat_sgs:
        missing = sorted(seat_sgs - assigned_seat_sgs)
        extra = sorted(assigned_seat_sgs - seat_sgs)
        raise SystemExit(f"FAIL: seat group coverage drift: missing={missing} extra={extra}")
    if seat_sgs:
        for group_id, sgs in sorted(SEAT_GROUPS.items()):
            groups.append((group_id, sorted([tool for sg in sgs for tool in by_sg[sg]], key=tool_id)))

    for domain, items in sorted(by_domain.items()):
        if domain == "seat":
            continue
        if domain in WHOLE_DOMAIN_SINGLE_GROUPS:
            groups.append((domain, items))
            continue
        for sg in sorted({item["_sg"] for item in items}):
            groups.append((sg, by_sg[sg]))
    return groups


def iter_sg_pairs(catalog: list[dict]) -> list[tuple[str, list[dict]]]:
    by_sg = tools_by_sg(catalog)
    pairs = []
    for left, right in itertools.combinations(sorted(by_sg), 2):
        pairs.append((f"{left}+{right}", sorted(by_sg[left] + by_sg[right], key=tool_id)))
    return pairs


def collect_c1_ref_devices(value) -> set[str]:
    devices = set()
    if isinstance(value, dict):
        if isinstance(value.get("device"), str):
            devices.add(value["device"])
        for child in value.values():
            devices |= collect_c1_ref_devices(child)
    elif isinstance(value, list):
        for child in value:
            devices |= collect_c1_ref_devices(child)
    return devices


def build_scene_macros(catalog: list[dict], scenario_path: Path) -> list[tuple[str, list[dict], dict]]:
    if not scenario_path.exists():
        return []
    if yaml is None:
        raise SystemExit("FAIL: PyYAML is required to derive scene macros")
    scenarios = yaml.safe_load(scenario_path.read_text(encoding="utf-8")) or {}
    scenes = scenarios.get("scenes") or []
    tools_by_ir_device: dict[str, list[dict]] = defaultdict(list)
    for item in catalog:
        device = (item.get("_ir") or {}).get("device")
        if device:
            tools_by_ir_device[device].append(item)
    macros = []
    for scene in scenes:
        scene_id = scene.get("id")
        if not scene_id:
            continue
        devices = collect_c1_ref_devices(scene.get("beats", [])) | collect_c1_ref_devices(scene.get("turns", []))
        selected = sorted([tool for device in devices for tool in tools_by_ir_device.get(device, [])], key=tool_id)
        if selected:
            macros.append((f"scene.{scene_id}", selected, {"scene_id": scene_id, "ir_devices": sorted(devices)}))
    return macros


def load_tokenizer(mode: str, model: str):
    if mode == "none":
        return None
    if mode == "char":
        return lambda text: len(text)
    if mode == "qwen":
        try:
            from transformers import AutoTokenizer
        except ImportError as exc:
            raise SystemExit(
                "FAIL: verify-subset-budget requires transformers in the selected Python runtime; "
                "use python3.13 or install the local tokenizer dependency."
            ) from exc
        tokenizer = AutoTokenizer.from_pretrained(model, local_files_only=True)
        return lambda text: len(tokenizer.encode(text, add_special_tokens=False))
    raise SystemExit(f"FAIL: unknown tokenizer mode: {mode}")


def build_entry(group_id: str, mount_mode: str, tools: list[dict], count_tokens=None, cap: int = TOOL_TOKENS_CAP,
                extra=None) -> tuple[dict, dict]:
    ordered_ids = [tool_id(item) for item in tools]
    schemas = [tool_schema(item) for item in tools]
    prompt_schemas = [prompt_tool_schema(item) for item in tools]
    artifact = {
        "subset_policy_id": POLICY_ID,
        "group_id": group_id,
        "mount_mode": mount_mode,
        "allowed_tool_set": ordered_ids,
        "tools": schemas,
        "no_tool_outlet": NO_TOOL_OUTLET,
    }
    if extra:
        artifact.update(extra)
    artifact_digest = digest(artifact)
    artifact["grammar_artifact_digest"] = artifact_digest

    entry = {
        "subset_policy_id": POLICY_ID,
        "group_id": group_id,
        "mount_mode": mount_mode,
        "tool_ids_ordered": ordered_ids,
        "tool_schema_digest": digest(schemas),
        "no_tool_outlet_digest": digest(NO_TOOL_OUTLET),
        "grammar_artifact_digest": artifact_digest,
        "qwen_format_version": QWEN_FORMAT_VERSION,
        "tokenizer_id": TOKENIZER_ID,
        "grammar_builder_version": GRAMMAR_BUILDER_VERSION,
        "distractor_policy": DISTRACTOR_POLICY,
    }
    if count_tokens:
        token_count = count_tokens(canonical_json(prompt_schemas + [NO_TOOL_OUTLET]))
        entry["tool_tokens"] = token_count
        entry["tool_tokens_cap"] = cap
        if token_count <= cap:
            entry["budget_status"] = "pass"
        elif mount_mode == "sg_pair":
            entry["budget_status"] = "over_cap"
            entry["pair_mode"] = "degraded_clarify"
        else:
            entry["budget_status"] = "fail_over_budget"
    return entry, artifact


def build_outputs(args) -> tuple[dict, dict, list[str]]:
    catalog_path = Path(args.catalog)
    catalog = read_catalog(catalog_path)
    count_tokens = load_tokenizer(args.tokenizer_mode, args.tokenizer_model) if args.verify_budget else None

    entries = []
    artifacts = []
    for group_id, tools in build_single_groups(catalog):
        entry, artifact = build_entry(group_id, "single_group", tools, count_tokens, args.budget_cap)
        entries.append(entry)
        artifacts.append(artifact)
    for group_id, tools in iter_sg_pairs(catalog):
        entry, _artifact = build_entry(group_id, "sg_pair", tools, count_tokens, args.budget_cap)
        entries.append(entry)
    for group_id, tools, extra in build_scene_macros(catalog, Path(args.demo_scenarios)):
        entry, artifact = build_entry(group_id, "scene_macro", tools, count_tokens, args.budget_cap, extra)
        entries.append(entry)
        artifacts.append(artifact)

    all_tool_ids = {tool_id(item) for item in catalog}
    single_tool_ids = [tool_id(tool) for _, tools in build_single_groups(catalog) for tool in tools]
    errors = []
    if len(single_tool_ids) != len(set(single_tool_ids)):
        errors.append("single_group tool coverage has duplicates")
    if set(single_tool_ids) != all_tool_ids:
        errors.append(
            f"single_group tool coverage mismatch: missing={len(all_tool_ids - set(single_tool_ids))} "
            f"extra={len(set(single_tool_ids) - all_tool_ids)}"
        )
    if args.verify_budget:
        failing = [
            f"{entry['mount_mode']}:{entry['group_id']}={entry['tool_tokens']}"
            for entry in entries
            if entry.get("budget_status") == "fail_over_budget"
        ]
        if failing:
            errors.append("budget cap fail-closed: " + ", ".join(failing[:20]))

    by_mode = defaultdict(int)
    over_pairs = 0
    for entry in entries:
        by_mode[entry["mount_mode"]] += 1
        if entry.get("pair_mode") == "degraded_clarify":
            over_pairs += 1
    manifest = {
        "meta": {
            "subset_policy_id": POLICY_ID,
            "source_catalog": str(catalog_path),
            "source_catalog_sha256": hashlib.sha256(catalog_path.read_bytes()).hexdigest(),
            "tool_count": len(catalog),
            "tool_count_derivation": "len(generated/D_domain.tools.demo.json) over generated D-domain named-tool catalog",
            "qwen_format_version": QWEN_FORMAT_VERSION,
            "tokenizer_id": args.tokenizer_model,
            "grammar_builder_version": GRAMMAR_BUILDER_VERSION,
            "tool_tokens_cap": args.budget_cap,
            "budget_gate": "static_build_time",
            "runtime_trimming": "forbidden",
            "phase": "phase_1_construction_only",
            "distractor_policy": DISTRACTOR_POLICY,
            "entry_counts": dict(sorted(by_mode.items())),
            "degraded_pair_count": over_pairs,
        },
        "entries": sorted(entries, key=lambda item: (item["mount_mode"], item["group_id"])),
    }
    artifact_doc = {
        "meta": {
            "subset_policy_id": POLICY_ID,
            "artifact_kind": "grammar_data_artifact_not_vendor_compiled",
            "no_tool_outlet_digest": digest(NO_TOOL_OUTLET),
            "grammar_builder_version": GRAMMAR_BUILDER_VERSION,
        },
        "artifacts": sorted(artifacts, key=lambda item: (item["mount_mode"], item["group_id"])),
    }
    return manifest, artifact_doc, errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--catalog", default="generated/D_domain.tools.demo.json")
    parser.add_argument("--demo-scenarios", default="contracts/demo-scenarios.yaml")
    parser.add_argument("--output-dir", default="generated")
    parser.add_argument("--emit", action="store_true")
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--verify-budget", action="store_true")
    parser.add_argument("--budget-cap", type=int, default=TOOL_TOKENS_CAP)
    parser.add_argument("--tokenizer-mode", choices=["none", "char", "qwen"], default="none")
    parser.add_argument("--tokenizer-model", default=TOKENIZER_ID)
    args = parser.parse_args()

    if args.verify_budget and args.tokenizer_mode == "none":
        args.tokenizer_mode = "qwen"
    manifest, artifact_doc, errors = build_outputs(args)
    if errors:
        print("FAIL subset manifest generation:", file=sys.stderr)
        for error in errors:
            print(f"  {error}", file=sys.stderr)
        return 1
    if args.emit:
        output_dir = Path(args.output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
        write_json(output_dir / "subset-policy-manifest.json", manifest)
        write_json(output_dir / "subset-grammar-artifacts.json", artifact_doc)
        print(f"wrote {output_dir / 'subset-policy-manifest.json'} ({len(manifest['entries'])} entries)")
        print(f"wrote {output_dir / 'subset-grammar-artifacts.json'} ({len(artifact_doc['artifacts'])} artifacts)")
    if args.check or args.verify_budget:
        print(
            "OK subset manifest: "
            f"entries={len(manifest['entries'])} modes={manifest['meta']['entry_counts']} "
            f"degraded_pairs={manifest['meta']['degraded_pair_count']}"
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())

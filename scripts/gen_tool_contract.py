#!/usr/bin/env python3
import argparse
import json
from pathlib import Path


def unique(values):
    return sorted({value for value in values if value})


def string_schema(values=None):
    schema = {"type": "string"}
    if values:
        schema["enum"] = values
    return schema


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
                "parameters": {
                    "type": "object",
                    "additionalProperties": True,
                    "properties": {},
                },
            },
        }
        for name in sorted(names)
    ]


def read_jsonl(path):
    rows = []
    with path.open("r", encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows


def write_json(path, value):
    path.write_text(
        json.dumps(value, ensure_ascii=False, sort_keys=True, indent=2) + "\n",
        encoding="utf-8",
    )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--contract", default="contracts/semantic-function-contract.jsonl")
    parser.add_argument("--output-dir", default="generated")
    args = parser.parse_args()

    rows = read_jsonl(Path(args.contract))
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    b_frame = frame_schema(rows)
    d_domain = d_domain_tools(rows)
    write_json(output_dir / "B_frame.frame_schema.json", b_frame)
    write_json(output_dir / "D_domain.tools.json", d_domain)
    rendered = "\n".join(
        json.dumps(tool, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
        for tool in b_frame + d_domain
    )
    (output_dir / "rendered_tools_text").write_text(rendered + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any

EXPECTED_CASES = [
    "main_cooling_deep_space",
    "main_heating_ivory",
    "safety_refusal_ivory",
    "capsule_video_loop_deep_space",
    "u17_golden_path_deep_space",
]

REQUIRED_FIELDS = {
    "case_id",
    "device",
    "launchArg",
    "theme",
    "ui_tree_evidence",
    "screenshot_path",
    "proof_class",
}

CASE_EXPECTATIONS = {
    "main_cooling_deep_space": {
        "theme": "deepSpace",
        "launch_fragments": ["-mockSnapshot", "cooling", "-mockTheme", "deepSpace"],
        "tree_markers": ["context-band", "demo-orb", "dialogue-stream", "vehicle-card-family.ac", "26℃"],
    },
    "main_heating_ivory": {
        "theme": "ivory",
        "launch_fragments": ["-mockSnapshot", "heating", "-mockTheme", "ivory"],
        "tree_markers": ["context-band", "demo-orb", "dialogue-stream", "vehicle-card-family.ac", "28℃"],
    },
    "safety_refusal_ivory": {
        "theme": "ivory",
        "launch_fragments": ["-mockSnapshot", "safetyRefusal", "-mockTheme", "ivory"],
        "tree_markers": ["context-band", "demo-orb", "dialogue-stream", "行驶中", "尾门"],
    },
    "capsule_video_loop_deep_space": {
        "theme": "deepSpace",
        "launch_fragments": [
            "-mockSnapshot",
            "cooling",
            "-mockTheme",
            "deepSpace",
            "-contextCapsuleRoute",
            "videoLoop",
        ],
        "tree_markers": ["context-band", "demo-orb", "dialogue-stream", "vehicle-card-family.ac", "26℃"],
    },
    "u17_golden_path_deep_space": {
        "theme": "deepSpace",
        "launch_fragments": ["-goldenPathID", "uiue_g9b_ac_success_deep_space"],
        "tree_markers": ["context-band", "demo-orb", "dialogue-stream", "vehicle-card-family.ac", "26℃"],
    },
}

FORBIDDEN_SCREENSHOT_SOURCES = {
    "ImageRenderer",
    "SwiftUI preview",
    "Preview",
    "static snapshot",
    "XCTAttachment",
    "xcuitest_attachment",
}


def fail(message: str) -> None:
    print(f"FAIL: {message}", file=sys.stderr)
    raise SystemExit(1)


def resolve_relative(base: Path, value: Any, field: str) -> Path:
    if not isinstance(value, str) or not value:
        fail(f"{field} must be a non-empty string")

    path = Path(value)
    if not path.is_absolute():
        path = base / path
    return path


def load_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        fail(f"invalid JSON at {path}: {error}")
    if not isinstance(value, dict):
        fail(f"JSON root must be object: {path}")
    return value


def assert_png(path: Path) -> None:
    if not path.is_file():
        fail(f"missing screenshot: {path}")
    with path.open("rb") as handle:
        magic = handle.read(8)
    if magic != b"\x89PNG\r\n\x1a\n":
        fail(f"screenshot is not PNG: {path}")
    if path.stat().st_size < 10_000:
        fail(f"screenshot is unexpectedly small: {path}")


def assert_l0_item(evidence_dir: Path, case_id: str) -> None:
    item_path = evidence_dir / "l0" / f"{case_id}.json"
    if not item_path.is_file():
        fail(f"missing L0 item JSON for {case_id}: {item_path}")

    item = load_json(item_path)
    missing = sorted(REQUIRED_FIELDS.difference(item))
    if missing:
        fail(f"{case_id}: missing required fields: {', '.join(missing)}")

    if item["case_id"] != case_id:
        fail(f"{case_id}: case_id mismatch: {item['case_id']}")

    if item["proof_class"] != "simulator_l0_runtime_truth":
        fail(f"{case_id}: proof_class must be simulator_l0_runtime_truth")

    expected = CASE_EXPECTATIONS[case_id]
    if item["theme"] != expected["theme"]:
        fail(f"{case_id}: theme must be {expected['theme']}")

    launch_arg = item["launchArg"]
    if not isinstance(launch_arg, str) or not launch_arg:
        fail(f"{case_id}: launchArg must be non-empty string")
    for fragment in expected["launch_fragments"]:
        if fragment not in launch_arg:
            fail(f"{case_id}: launchArg missing fragment: {fragment}")

    source = str(item.get("screenshot_source", ""))
    if source in FORBIDDEN_SCREENSHOT_SOURCES:
        fail(f"{case_id}: forbidden screenshot_source: {source}")
    if source != "on_screen_simctl_io_booted_screenshot":
        fail(f"{case_id}: screenshot_source must be on_screen_simctl_io_booted_screenshot")

    capture_command = str(item.get("capture_command", ""))
    if "simctl io booted screenshot" not in capture_command:
        fail(f"{case_id}: capture_command must include simctl io booted screenshot")

    ui_tree_path = resolve_relative(evidence_dir, item["ui_tree_evidence"], "ui_tree_evidence")
    if not ui_tree_path.is_file():
        fail(f"{case_id}: missing UI tree evidence: {ui_tree_path}")
    ui_tree = ui_tree_path.read_text(encoding="utf-8", errors="replace")
    if not ui_tree.strip():
        fail(f"{case_id}: UI tree evidence is empty")
    for marker in expected["tree_markers"]:
        if marker not in ui_tree:
            fail(f"{case_id}: UI tree evidence missing marker: {marker}")

    screenshot_path = resolve_relative(evidence_dir, item["screenshot_path"], "screenshot_path")
    assert_png(screenshot_path)

    device = item["device"]
    if isinstance(device, dict):
        if not device.get("name") or not device.get("udid"):
            fail(f"{case_id}: device.name and device.udid must be present")
    elif not isinstance(device, str) or not device:
        fail(f"{case_id}: device must be object or non-empty string")


def main() -> int:
    if len(sys.argv) != 2:
        fail("usage: check-8c2-l0-evidence.py <evidence-dir>")

    evidence_dir = Path(sys.argv[1])
    manifest_path = evidence_dir / "package-manifest.json"
    if not manifest_path.is_file():
        fail(f"missing package manifest: {manifest_path}")

    manifest = load_json(manifest_path)
    cases = manifest.get("cases")
    if cases != EXPECTED_CASES:
        fail(f"manifest cases must match expected order: {EXPECTED_CASES}")

    l0_entries = manifest.get("l0")
    expected_l0_entries = [f"l0/{case_id}.json" for case_id in EXPECTED_CASES]
    if l0_entries != expected_l0_entries:
        fail(f"manifest l0 entries must be {expected_l0_entries}")

    for case_id in EXPECTED_CASES:
        assert_l0_item(evidence_dir, case_id)

    print("PASS: 8.C2 L0 evidence package is complete")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

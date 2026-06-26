#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any

REQUIRED_FIELDS = {
    "device",
    "launchArg",
    "theme",
    "ui_tree_evidence",
    "screenshot_path",
    "proof_class",
}

REQUIRED_TREE_MARKERS = [
    "context-band",
    "mic-dock-safe-area",
    "vehicle-card-family.",
]

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


def main() -> int:
    if len(sys.argv) != 2:
        fail("usage: check-u17-l0-evidence.py <evidence-dir>")

    evidence_dir = Path(sys.argv[1])
    manifest_path = evidence_dir / "l0-evidence.json"
    if not manifest_path.is_file():
        fail(f"missing manifest: {manifest_path}")

    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        fail(f"invalid JSON manifest: {error}")

    missing = sorted(REQUIRED_FIELDS.difference(manifest))
    if missing:
        fail(f"missing required fields: {', '.join(missing)}")

    if manifest["proof_class"] != "simulator_l0_runtime_truth":
        fail("proof_class must be simulator_l0_runtime_truth")

    launch_arg = manifest["launchArg"]
    if not isinstance(launch_arg, str) or "-goldenPathID" not in launch_arg:
        fail("launchArg must record -goldenPathID")

    if manifest["theme"] != "deepSpace":
        fail("theme must be deepSpace for U17 golden path")

    source = str(manifest.get("screenshot_source", ""))
    if source in FORBIDDEN_SCREENSHOT_SOURCES:
        fail(f"screenshot_source is forbidden for L0: {source}")

    capture_command = str(manifest.get("capture_command", ""))
    if "simctl io booted screenshot" not in capture_command:
        fail("capture_command must include simctl io booted screenshot")

    ui_tree_path = resolve_relative(evidence_dir, manifest["ui_tree_evidence"], "ui_tree_evidence")
    if not ui_tree_path.is_file():
        fail(f"missing UI tree evidence: {ui_tree_path}")

    ui_tree = ui_tree_path.read_text(encoding="utf-8", errors="replace")
    if not ui_tree.strip():
        fail("UI tree evidence is empty")

    for marker in REQUIRED_TREE_MARKERS:
        if marker not in ui_tree:
            fail(f"UI tree evidence missing marker: {marker}")

    screenshot_path = resolve_relative(evidence_dir, manifest["screenshot_path"], "screenshot_path")
    if not screenshot_path.is_file():
        fail(f"missing screenshot: {screenshot_path}")

    with screenshot_path.open("rb") as handle:
        magic = handle.read(8)
    if magic != b"\x89PNG\r\n\x1a\n":
        fail("screenshot_path must point to a PNG file")

    device = manifest["device"]
    if isinstance(device, dict):
        if not device.get("name"):
            fail("device.name must be present")
    elif not isinstance(device, str) or not device:
        fail("device must be a non-empty string or object")

    print("PASS: U17 L0 evidence package is complete")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any


TARGET_IDENTIFIERS = [
    "context-band",
    "settings-control",
    "refresh-control",
    "demo-orb",
    "dialogue-stream",
    "mic-dock-safe-area",
]

NON_CLAIMS = [
    "no L3 aesthetic pass",
    "no V-PASS",
    "no 8.C2 closure",
    "no mobile",
    "no true_device",
    "no runtime-ready",
    "no voice-ready",
    "no A-2 complete",
]


@dataclass(frozen=True)
class Rect:
    x: float
    y: float
    width: float
    height: float

    @property
    def min_x(self) -> float:
        return self.x

    @property
    def max_x(self) -> float:
        return self.x + self.width

    @property
    def min_y(self) -> float:
        return self.y

    @property
    def max_y(self) -> float:
        return self.y + self.height

    @property
    def mid_x(self) -> float:
        return self.x + self.width / 2

    @property
    def area(self) -> float:
        return max(0.0, self.width) * max(0.0, self.height)


def fail(message: str) -> None:
    print(f"FAIL: {message}", file=sys.stderr)
    raise SystemExit(1)


def load_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        fail(f"invalid JSON at {path}: {error}")
    if not isinstance(value, dict):
        fail(f"JSON root must be object: {path}")
    return value


def rect_from(value: Any, name: str) -> Rect:
    if not isinstance(value, dict):
        fail(f"{name} frame must be object")
    try:
        return Rect(
            x=float(value["x"]),
            y=float(value["y"]),
            width=float(value["width"]),
            height=float(value["height"]),
        )
    except KeyError as error:
        fail(f"{name} frame missing field: {error}")
    except (TypeError, ValueError):
        fail(f"{name} frame fields must be numbers")


def extract_frames(tree: dict[str, Any]) -> dict[str, Rect]:
    raw_frames = tree.get("identifier_frames") or tree.get("frames") or tree.get("identifiers")
    if not isinstance(raw_frames, dict):
        fail("ui tree must contain identifier_frames, frames, or identifiers object")
    return {str(name): rect_from(frame, str(name)) for name, frame in raw_frames.items()}


def intersection_area(a: Rect, b: Rect) -> float:
    width = max(0.0, min(a.max_x, b.max_x) - max(a.min_x, b.min_x))
    height = max(0.0, min(a.max_y, b.max_y) - max(a.min_y, b.min_y))
    return width * height


def clipped_to(frame: Rect, bounds: Rect) -> Rect | None:
    x = max(frame.min_x, bounds.min_x)
    y = max(frame.min_y, bounds.min_y)
    max_x = min(frame.max_x, bounds.max_x)
    max_y = min(frame.max_y, bounds.max_y)
    width = max_x - x
    height = max_y - y
    if width <= 0 or height <= 0:
        return None
    return Rect(x=x, y=y, width=width, height=height)


def gap(a: Rect, b: Rect, axis: str) -> float:
    if axis == "x":
        return max(a.min_x - b.max_x, b.min_x - a.max_x, 0.0)
    if axis == "y":
        return max(a.min_y - b.max_y, b.min_y - a.max_y, 0.0)
    fail(f"unknown gap axis: {axis}")


def status_from(items: list[dict[str, Any]], warnings: list[str]) -> str:
    statuses = [str(item.get("status", "")) for item in items]
    if "FAIL" in statuses:
        return "FAIL"
    if "BLOCKED_FOR_THRESHOLD" in statuses or "WARN" in statuses or warnings:
        return "WARN"
    return "PASS"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Emit a UIUE R2b structural layout receipt from UI tree frames and screenshot metadata."
    )
    parser.add_argument("--ui-tree", required=True, type=Path, help="JSON file with identifier frame geometry")
    parser.add_argument("--screenshot-metadata", required=True, type=Path, help="JSON file with screenshot metadata")
    parser.add_argument("--output", required=True, type=Path, help="Receipt JSON path to write")
    parser.add_argument("--crop-dir", type=Path, help="Optional deterministic crop directory")
    parser.add_argument("--min-gap-points", type=float, default=8.0, help="Dispatch default minimum gap")
    parser.add_argument(
        "--control-stack-gap-points",
        type=float,
        default=6.0,
        help="Minimum vertical gap for stacked settings/refresh controls",
    )
    parser.add_argument("--center-tolerance-points", type=float, default=12.0, help="Dispatch default capsule center tolerance")
    parser.add_argument("--min-card-area-points", type=float, default=42000.0, help="Dispatch default visible card area")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    tree = load_json(args.ui_tree)
    metadata = load_json(args.screenshot_metadata)
    frames = extract_frames(tree)
    warnings: list[str] = []

    threshold_source = {
        "min_gap_points": {
            "value": args.min_gap_points,
            "source": "dispatch default; docs/dispatches/2026-06-27-uiue-r1-r2b-implementation-dispatch.md Task B",
        },
        "center_tolerance_points": {
            "value": args.center_tolerance_points,
            "source": "dispatch default; checker foundation before device matrix",
        },
        "control_stack_gap_points": {
            "value": args.control_stack_gap_points,
            "source": "current phone top-band contract: vertical settings/refresh stack uses compact spacing; UIC2VisualAcceptanceUITests asserts >=4pt",
        },
        "min_card_area_points": {
            "value": args.min_card_area_points,
            "source": "dispatch default; structural sentinel only, not aesthetic judgment",
        },
        "white_edge_pixel_threshold": {
            "status": "BLOCKED_FOR_THRESHOLD",
            "source": "not formalized yet; crop path is recorded but edge-pixel PASS is intentionally not signed",
        },
    }

    missing_identifiers = [
        {
            "identifier": name,
            "status": "FAIL",
            "reason": "required target frame missing; checker cannot prove UIUE R2b structural layout",
        }
        for name in TARGET_IDENTIFIERS
        if name not in frames
    ]
    if missing_identifiers:
        missing_names = ", ".join(item["identifier"] for item in missing_identifiers)
        warnings.append(f"required target frame(s) missing: {missing_names}")

    analysis_frames = dict(frames)
    visible_vehicle_cards: list[str] = []
    vehicle_viewport = frames.get("vehicle-cards")
    for name, frame in frames.items():
        if not name.startswith("vehicle-card-family."):
            continue
        clipped = clipped_to(frame, vehicle_viewport) if vehicle_viewport else frame
        if clipped is None:
            continue
        analysis_frames[name] = clipped
        visible_vehicle_cards.append(name)

    relevant = [name for name in TARGET_IDENTIFIERS if name in analysis_frames]
    relevant.extend(sorted(visible_vehicle_cards))
    overlap_pairs: list[dict[str, Any]] = []
    for index, left in enumerate(relevant):
        for right in relevant[index + 1:]:
            area = intersection_area(analysis_frames[left], analysis_frames[right])
            overlap_pairs.append({
                "a": left,
                "b": right,
                "intersection_area": area,
                "status": "FAIL" if area > 0 else "PASS",
            })

    min_gaps: list[dict[str, Any]] = []
    if "context-band" in frames:
        for name in ["settings-control", "refresh-control"]:
            if name in frames:
                measured = gap(frames[name], frames["context-band"], "x")
                min_gaps.append({
                    "a": name,
                    "b": "context-band",
                    "axis": "x",
                    "gap_points": measured,
                    "threshold_points": args.min_gap_points,
                    "threshold_source": threshold_source["min_gap_points"]["source"],
                    "status": "PASS" if measured >= args.min_gap_points else "FAIL",
                })
    if "settings-control" in frames and "refresh-control" in frames:
        measured = gap(frames["settings-control"], frames["refresh-control"], "y")
        min_gaps.append({
            "a": "settings-control",
            "b": "refresh-control",
            "axis": "y",
            "gap_points": measured,
            "threshold_points": args.control_stack_gap_points,
            "threshold_source": threshold_source["control_stack_gap_points"]["source"],
            "status": "PASS" if measured >= args.control_stack_gap_points else "FAIL",
        })

    viewport = metadata.get("viewport_points") or tree.get("viewport_points")
    if not isinstance(viewport, dict):
        fail("viewport_points must exist in screenshot metadata or ui tree")
    viewport_width = float(viewport.get("width", 0))
    viewport_height = float(viewport.get("height", 0))
    if viewport_width <= 0 or viewport_height <= 0:
        fail("viewport_points width/height must be positive")

    zone_budget = {
        "viewport_points": {"width": viewport_width, "height": viewport_height},
        "top_band_height_points": frames.get("context-band", Rect(0, 0, 0, 0)).height,
        "orb_height_points": frames.get("demo-orb", Rect(0, 0, 0, 0)).height,
        "vehicle_grid_available_points": sum(
            analysis_frames[name].area for name in visible_vehicle_cards
        ),
        "mic_dock_exclusion_points": frames.get("mic-dock-safe-area", Rect(0, 0, 0, 0)).height,
    }
    zone_budget["status"] = (
        "PASS"
        if zone_budget["vehicle_grid_available_points"] >= args.min_card_area_points
        else "WARN"
    )
    zone_budget["threshold_source"] = threshold_source["min_card_area_points"]["source"]

    safe_area = tree.get("safe_area") or metadata.get("safe_area") or {}
    top_safe = float(safe_area.get("top", 0)) if isinstance(safe_area, dict) else 0.0
    bottom_safe = float(safe_area.get("bottom", 0)) if isinstance(safe_area, dict) else 0.0
    safe_area_violations: list[dict[str, Any]] = []
    visible_cards_max_y = frames.get("vehicle-cards", Rect(0, 0, 0, viewport_height)).max_y
    for name, frame in frames.items():
        if name.startswith("vehicle-card-family.") and frame.min_y >= visible_cards_max_y:
            # ScrollView content can extend below the viewport; this checker validates
            # visible zone budget separately instead of treating offscreen scroll
            # content as a safe-area violation.
            continue
        if frame.min_x < 0 or frame.max_x > viewport_width or frame.min_y < top_safe or frame.max_y > viewport_height - bottom_safe:
            safe_area_violations.append({
                "identifier": name,
                "frame": frame.__dict__,
                "status": "FAIL",
            })

    if "context-band" in frames:
        delta = abs(frames["context-band"].mid_x - viewport_width / 2)
        min_gaps.append({
            "a": "context-band",
            "b": "viewport-center",
            "axis": "x",
            "gap_points": delta,
            "threshold_points": args.center_tolerance_points,
            "threshold_source": threshold_source["center_tolerance_points"]["source"],
            "status": "PASS" if delta <= args.center_tolerance_points else "FAIL",
        })
    else:
        warnings.append("context-band frame missing; capsule centering cannot be evaluated")

    crop_paths: dict[str, str] = {}
    if args.crop_dir:
        crop_paths = {
            "top_band": str(args.crop_dir / "top-band.png"),
            "orb": str(args.crop_dir / "orb.png"),
            "mic_dock": str(args.crop_dir / "mic-dock.png"),
        }
    warnings.append("white-edge leakage returns BLOCKED_FOR_THRESHOLD until edge-pixel threshold is formalized")

    check_items = missing_identifiers + overlap_pairs + min_gaps + safe_area_violations + [{"status": zone_budget["status"]}]
    receipt = {
        "status": status_from(check_items, warnings),
        "threshold_source": threshold_source,
        "proof_class": "local",
        "source_ui_tree": {
            "path": str(args.ui_tree),
            "captured_at": tree.get("captured_at"),
            "case_id": tree.get("case_id"),
            "simulator": tree.get("simulator"),
        },
        "source_screenshot_metadata": {
            "path": str(args.screenshot_metadata),
            "captured_at": metadata.get("captured_at"),
            "pixel_size": metadata.get("pixel_size"),
            "scale": metadata.get("scale"),
            "viewport_points": viewport,
        },
        "missing_identifiers": missing_identifiers,
        "overlap_pairs": overlap_pairs,
        "min_gaps": min_gaps,
        "zone_budget": zone_budget,
        "safe_area_violations": safe_area_violations,
        "crop_paths": crop_paths,
        "warnings": warnings,
        "non_claims": NON_CLAIMS,
    }

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(receipt, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"{receipt['status']}: wrote {args.output}")
    return 1 if receipt["status"] == "FAIL" else 0


if __name__ == "__main__":
    raise SystemExit(main())

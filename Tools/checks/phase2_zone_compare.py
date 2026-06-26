#!/usr/bin/env python3
"""Compare Phase 2 iPhone screenshots against anchor images by four vertical zones.

The zones are defined in the simulator screenshot coordinate space used by the
Phase 2 receipt (1320x2868). Inputs are resized to the anchor dimensions before
RMSE calculation so local simulator captures and anchor PNGs can be compared
repeatably.

This is an L1 visual sentinel: it reports PASS/WARN/FAIL to block obvious
collapse only. Raw RMSE remains diagnostic evidence, not an aesthetics target and
not a replacement for L3 human 5-gate review.
"""

from __future__ import annotations

import argparse
import math
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw


REFERENCE_HEIGHT = 2868
ZONES = (
    ("context", 0, 530),
    ("orb", 530, 1080),
    ("dialogue", 1080, 1450),
    ("controls", 1450, 2868),
)

PRESET_MASKS: dict[str, tuple["MaskRect", ...]] = {}
DEFAULT_WARN_THRESHOLD = 0.180000
DEFAULT_FAIL_THRESHOLD = 0.300000
STOP_RULE = (
    "L1 sentinel stop-rule: if repeated runs add no new proof class or artifact "
    "and only tune the same L1 metric/crop, stop and close as PARTIAL/FAIL "
    "instead of continuing. L1 blocks collapse only; it does not sign aesthetics "
    "or replace L3."
)


@dataclass(frozen=True)
class MaskRect:
    name: str
    x0: int
    y0: int
    x1: int
    y1: int


@dataclass(frozen=True)
class ZoneMetric:
    name: str
    rmse: float


PRESET_MASKS = {
    # Mask only the animated diorama interior. This is for diagnosing animation
    # frame drift in the context zone; raw metrics remain the acceptance baseline.
    "phase2-capsule-diorama": (
        MaskRect("capsule-diorama", 145, 165, 1095, 575),
    ),
}


def parse_mask_rect(raw: str) -> MaskRect:
    try:
        name, coords = raw.split(":", 1)
        x0, y0, x1, y1 = (int(part) for part in coords.split(","))
    except ValueError as error:
        raise argparse.ArgumentTypeError(
            "mask rect must be name:x0,y0,x1,y1 in 1320x2868 screenshot coordinates"
        ) from error
    if x1 <= x0 or y1 <= y0:
        raise argparse.ArgumentTypeError("mask rect must have positive width and height")
    return MaskRect(name=name, x0=x0, y0=y0, x1=x1, y1=y1)


def scale_y(value: int, target_height: int) -> int:
    return round(value * target_height / REFERENCE_HEIGHT)


def scale_rect(rect: MaskRect, target_size: tuple[int, int]) -> tuple[int, int, int, int]:
    width, height = target_size
    return (
        round(rect.x0 * width / 1320),
        scale_y(rect.y0, height),
        round(rect.x1 * width / 1320),
        scale_y(rect.y1, height),
    )


def apply_masks(image: Image.Image, masks: Iterable[MaskRect]) -> Image.Image:
    if not masks:
        return image
    masked = image.copy()
    draw = ImageDraw.Draw(masked)
    for rect in masks:
        draw.rectangle(scale_rect(rect, masked.size), fill=(255, 255, 255))
    return masked


def rmse(a: Image.Image, b: Image.Image) -> float:
    a_pixels = list(image_data(a))
    b_pixels = list(image_data(b))
    total = 0
    count = len(a_pixels) * 3
    for left, right in zip(a_pixels, b_pixels):
        total += (
            (left[0] - right[0]) ** 2
            + (left[1] - right[1]) ** 2
            + (left[2] - right[2]) ** 2
        )
    return math.sqrt(total / count) / 255


def image_data(image: Image.Image):
    if hasattr(image, "get_flattened_data"):
        return image.get_flattened_data()
    return image.getdata()


def compare(anchor_path: Path, current_path: Path, masks: tuple[MaskRect, ...]) -> list[ZoneMetric]:
    anchor = Image.open(anchor_path).convert("RGB")
    current = Image.open(current_path).convert("RGB").resize(anchor.size)
    anchor = apply_masks(anchor, masks)
    current = apply_masks(current, masks)
    values: list[ZoneMetric] = []
    for name, y0, y1 in ZONES:
        ay0 = scale_y(y0, anchor.height)
        ay1 = scale_y(y1, anchor.height)
        anchor_crop = anchor.crop((0, ay0, anchor.width, ay1))
        current_crop = current.crop((0, ay0, anchor.width, ay1))
        values.append(ZoneMetric(name=name, rmse=rmse(anchor_crop, current_crop)))
    return values


def validate_thresholds(warn_threshold: float, fail_threshold: float) -> None:
    if warn_threshold < 0:
        raise ValueError("--warn-threshold must be >= 0")
    if fail_threshold <= warn_threshold:
        raise ValueError("--fail-threshold must be greater than --warn-threshold")


def sentinel_verdict(
    metrics: list[ZoneMetric], warn_threshold: float, fail_threshold: float
) -> tuple[str, str, ZoneMetric]:
    validate_thresholds(warn_threshold, fail_threshold)
    if not metrics:
        raise ValueError("at least one zone metric is required")
    max_metric = max(metrics, key=lambda metric: metric.rmse)
    if max_metric.rmse >= fail_threshold:
        return (
            "FAIL",
            f"{max_metric.name}_rmse={max_metric.rmse:.6f} >= fail_threshold={fail_threshold:.6f}",
            max_metric,
        )
    if max_metric.rmse >= warn_threshold:
        return (
            "WARN",
            f"{max_metric.name}_rmse={max_metric.rmse:.6f} >= warn_threshold={warn_threshold:.6f}",
            max_metric,
        )
    return (
        "PASS",
        f"max_rmse={max_metric.rmse:.6f} < warn_threshold={warn_threshold:.6f}",
        max_metric,
    )


def format_tsv(
    case: str,
    anchor_name: str,
    metrics: list[ZoneMetric],
    warn_threshold: float,
    fail_threshold: float,
) -> str:
    verdict, reason, max_metric = sentinel_verdict(metrics, warn_threshold, fail_threshold)
    header = "\t".join(
        [
            "case",
            "anchor",
            "l1_verdict",
            "reason",
            "max_zone",
            "max_rmse",
            "warn_threshold",
            "fail_threshold",
            "stop_rule",
        ]
        + [f"{metric.name}_rmse" for metric in metrics]
    )
    row = "\t".join(
        [
            case,
            anchor_name,
            verdict,
            reason,
            max_metric.name,
            f"{max_metric.rmse:.6f}",
            f"{warn_threshold:.6f}",
            f"{fail_threshold:.6f}",
            STOP_RULE,
        ]
        + [f"{metric.rmse:.6f}" for metric in metrics]
    )
    return header + "\n" + row + "\n"


def run_self_check(warn_threshold: float, fail_threshold: float) -> int:
    validate_thresholds(warn_threshold, fail_threshold)
    pass_value = warn_threshold / 2
    warn_value = (warn_threshold + fail_threshold) / 2
    fail_value = fail_threshold + 0.010000
    cases = (
        ("pass_case", [pass_value, pass_value, pass_value, pass_value], "PASS"),
        ("warn_case", [pass_value, warn_value, pass_value, pass_value], "WARN"),
        ("fail_case", [pass_value, warn_value, fail_value, pass_value], "FAIL"),
    )
    for label, raw_values, expected in cases:
        metrics = [
            ZoneMetric(name=name, rmse=value)
            for (name, _, _), value in zip(ZONES, raw_values)
        ]
        verdict, reason, _ = sentinel_verdict(metrics, warn_threshold, fail_threshold)
        print(f"{label}\t{verdict}\t{reason}")
        if verdict != expected:
            print(f"self-check\tFAIL\texpected={expected} actual={verdict}")
            return 1
    print("self-check\tPASS")
    print(STOP_RULE)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(
        description=__doc__,
        epilog=STOP_RULE,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--case", help="Case label for TSV output")
    parser.add_argument("--anchor", type=Path, help="Anchor PNG path")
    parser.add_argument("--current", type=Path, help="Current screenshot path")
    parser.add_argument("--output", type=Path, help="Output L1 sentinel TSV")
    parser.add_argument(
        "--warn-threshold",
        type=float,
        default=DEFAULT_WARN_THRESHOLD,
        help=(
            "Max-zone RMSE at or above this reports WARN. This is a collapse sentinel, "
            "not an aesthetics target."
        ),
    )
    parser.add_argument(
        "--fail-threshold",
        type=float,
        default=DEFAULT_FAIL_THRESHOLD,
        help=(
            "Max-zone RMSE at or above this reports FAIL. This blocks collapse only "
            "and does not replace L3."
        ),
    )
    parser.add_argument(
        "--print-stop-rule",
        action="store_true",
        help="Print the L1 stop-rule and exit without reading images.",
    )
    parser.add_argument(
        "--self-check",
        action="store_true",
        help="Run PASS/WARN/FAIL threshold self-check without reading images.",
    )
    parser.add_argument(
        "--mask-rect",
        action="append",
        type=parse_mask_rect,
        default=[],
        help="Optional dynamic mask rect in 1320x2868 coordinates; repeatable",
    )
    parser.add_argument(
        "--mask-preset",
        action="append",
        choices=sorted(PRESET_MASKS),
        default=[],
        help="Optional built-in dynamic mask preset; repeatable",
    )
    args = parser.parse_args()

    if args.print_stop_rule:
        print(STOP_RULE)
        return 0
    if args.self_check:
        return run_self_check(args.warn_threshold, args.fail_threshold)

    missing = [
        flag
        for flag, value in (
            ("--case", args.case),
            ("--anchor", args.anchor),
            ("--current", args.current),
            ("--output", args.output),
        )
        if value is None
    ]
    if missing:
        parser.error(
            "the following arguments are required unless --self-check or "
            f"--print-stop-rule: {', '.join(missing)}"
        )
    try:
        validate_thresholds(args.warn_threshold, args.fail_threshold)
    except ValueError as error:
        parser.error(str(error))

    preset_masks = tuple(
        rect for preset in args.mask_preset for rect in PRESET_MASKS[preset]
    )
    masks = tuple(args.mask_rect) + preset_masks
    values = compare(args.anchor, args.current, masks)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    report = format_tsv(
        args.case,
        args.anchor.name,
        values,
        args.warn_threshold,
        args.fail_threshold,
    )
    args.output.write_text(report, encoding="utf-8")
    print(report, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

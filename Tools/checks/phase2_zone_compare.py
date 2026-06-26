#!/usr/bin/env python3
"""Compare Phase 2 iPhone screenshots against anchor images by four vertical zones.

The zones are defined in the simulator screenshot coordinate space used by the
Phase 2 receipt (1320x2868). Inputs are resized to the anchor dimensions before
RMSE calculation so local simulator captures and anchor PNGs can be compared
repeatably.
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


@dataclass(frozen=True)
class MaskRect:
    name: str
    x0: int
    y0: int
    x1: int
    y1: int


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


def compare(anchor_path: Path, current_path: Path, masks: tuple[MaskRect, ...]) -> list[float]:
    anchor = Image.open(anchor_path).convert("RGB")
    current = Image.open(current_path).convert("RGB").resize(anchor.size)
    anchor = apply_masks(anchor, masks)
    current = apply_masks(current, masks)
    values: list[float] = []
    for _, y0, y1 in ZONES:
        ay0 = scale_y(y0, anchor.height)
        ay1 = scale_y(y1, anchor.height)
        anchor_crop = anchor.crop((0, ay0, anchor.width, ay1))
        current_crop = current.crop((0, ay0, anchor.width, ay1))
        values.append(rmse(anchor_crop, current_crop))
    return values


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--case", required=True, help="Case label for TSV output")
    parser.add_argument("--anchor", required=True, type=Path, help="Anchor PNG path")
    parser.add_argument("--current", required=True, type=Path, help="Current screenshot path")
    parser.add_argument("--output", required=True, type=Path, help="Output metrics TSV")
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

    preset_masks = tuple(
        rect for preset in args.mask_preset for rect in PRESET_MASKS[preset]
    )
    masks = tuple(args.mask_rect) + preset_masks
    values = compare(args.anchor, args.current, masks)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    header = "case\tanchor\t" + "\t".join(name for name, _, _ in ZONES)
    row = "\t".join(
        [args.case, args.anchor.name] + [f"{value:.6f}" for value in values]
    )
    args.output.write_text(header + "\n" + row + "\n", encoding="utf-8")
    print(args.output.read_text(encoding="utf-8"), end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

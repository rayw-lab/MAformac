#!/usr/bin/env python3
"""Generate UIUE 8.C2 L2 visual metrics from L0 simulator screenshots."""

from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

import numpy as np
from PIL import Image


def luma(rgb: np.ndarray) -> np.ndarray:
    return 0.2126 * rgb[:, :, 0] + 0.7152 * rgb[:, :, 1] + 0.0722 * rgb[:, :, 2]


def read_rgb(path: Path, size: tuple[int, int] | None = None) -> np.ndarray:
    image = Image.open(path).convert("RGB")
    if size is not None:
        image = image.resize(size)
    return np.asarray(image).astype("float32") / 255.0


def image_metrics(path: Path) -> dict:
    lum = luma(read_rgb(path))
    height, width = lum.shape
    center = lum[int(height * 0.08) : int(height * 0.92), int(width * 0.08) : int(width * 0.92)]
    dark_row_fraction = (center < 0.04).mean(axis=1)
    p05 = float(np.percentile(lum, 5))
    p95 = float(np.percentile(lum, 95))
    max_dark = float(dark_row_fraction.max())
    return {
        "case_id": path.stem,
        "avg_luminance": round(float(lum.mean()), 4),
        "std_luminance": round(float(lum.std()), 4),
        "p05_luminance": round(p05, 4),
        "p95_luminance": round(p95, 4),
        "p95_minus_p05_contrast_proxy": round(p95 - p05, 4),
        "max_dark_row_fraction_center": round(max_dark, 4),
        "continuous_black_line_scan": "PASS" if max_dark < 0.5 else "WARN",
        "proof_class": "local_pixel_metric_from_simctl_screenshot",
        "non_claim": "contrast proxy and dark-line scan do not sign L3 aesthetics",
    }


def simple_ssim_and_mse(left: Path, right: Path, size: tuple[int, int]) -> tuple[float, float]:
    a = read_rgb(left, size)
    b = read_rgb(right, size)
    la = luma(a)
    lb = luma(b)
    c1 = 0.01**2
    c2 = 0.03**2
    mean_a = float(la.mean())
    mean_b = float(lb.mean())
    var_a = float(la.var())
    var_b = float(lb.var())
    cov = float(((la - mean_a) * (lb - mean_b)).mean())
    ssim = ((2 * mean_a * mean_b + c1) * (2 * cov + c2)) / (
        (mean_a * mean_a + mean_b * mean_b + c1) * (var_a + var_b + c2)
    )
    mse = float(((a - b) ** 2).mean())
    return round(ssim, 4), round(mse, 6)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--package-dir", default=Path(__file__).resolve().parents[1], type=Path)
    parser.add_argument("--head", default="unknown")
    args = parser.parse_args()

    package_dir = args.package_dir
    screenshot_dir = package_dir / "screenshots" / "l0-simctl"
    crop_dir = package_dir / "crops"
    metrics_dir = package_dir / "metrics"
    screenshots = sorted(screenshot_dir.glob("*.png"))

    metrics = [image_metrics(path) for path in screenshots]
    comparisons = [
        (
            "ac-card-cooling-vs-heating",
            crop_dir / "main_cooling_ivory-ac-card.png",
            crop_dir / "main_heating_ivory-ac-card.png",
            (256, 256),
        ),
        (
            "capsule-top-band-cLite-vs-videoLoop",
            crop_dir / "main_cooling_deep_space-top-band.png",
            crop_dir / "capsule_video_loop_deep_space-top-band.png",
            (256, 256),
        ),
    ]
    for comparison_id, left, right, size in comparisons:
        ssim, mse = simple_ssim_and_mse(left, right, size)
        metrics.append(
            {
                "comparison_id": comparison_id,
                "left": str(left),
                "right": str(right),
                "ssim_luma_simple": ssim,
                "mse_rgb_resized": mse,
                "proof_class": "local_pixel_metric_from_simctl_screenshot",
                "non_claim": "SSIM/MSE are regression evidence only, not aesthetic pass/fail",
            }
        )

    metrics_path = metrics_dir / "l2-visual-metrics.json"
    metrics_path.write_text(json.dumps(metrics, ensure_ascii=False, indent=2) + "\n")

    now = datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    manifest = {
        "generated_at_utc": now,
        "repo": "/Users/wanglei/workspace/MAformac-uiue",
        "head": args.head,
        "generator_script": str(Path(__file__)),
        "generator_command": f"python3 {Path(__file__)} --package-dir {package_dir} --head {args.head}",
        "metric_path": str(metrics_path),
        "screenshot_metadata_path": str(metrics_dir / "screenshot-metadata.json"),
        "input_source": "L0 on-screen simctl screenshots",
        "proof_class": "local_pixel_metric_from_simctl_screenshot",
        "source_images": [
            {
                "path": str(path),
                "sha256": sha256(path),
                "bytes": path.stat().st_size,
                "captured_by": "xcrun simctl io screenshot",
            }
            for path in screenshots
        ],
        "non_claims": [
            "metrics are not L3 aesthetic verdict",
            "metrics are not mobile/true_device proof",
            "OCR engine was unavailable; UI tree text checks are separate evidence",
        ],
    }
    (metrics_dir / "l2-visual-metrics-manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

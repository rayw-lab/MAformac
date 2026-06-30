#!/usr/bin/env python3
from __future__ import annotations

import csv
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


def parse_args() -> tuple[Path, bool]:
    args = sys.argv[1:]
    write_summary = False
    if "--write-summary" in args:
        write_summary = True
        args.remove("--write-summary")

    if len(args) != 1:
        fail("usage: check-8c2-l2-package.py [--write-summary] <evidence-dir>")
    return Path(args[0]), write_summary


def check_l1(evidence_dir: Path) -> list[dict[str, str]]:
    summary_path = evidence_dir / "l1" / "l1-summary.tsv"
    if not summary_path.is_file():
        fail(f"missing L1 summary: {summary_path}")

    rows: list[dict[str, str]] = []
    with summary_path.open(encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        for row in reader:
            if row.get("case") == "case":
                fail("L1 summary contains repeated header row")
            rows.append(dict(row))

    cases = [row.get("case", "") for row in rows]
    if cases != EXPECTED_CASES:
        fail(f"L1 cases must match expected order: {EXPECTED_CASES}")

    for row in rows:
        verdict = row.get("l1_verdict")
        if verdict not in {"PASS", "WARN", "FAIL"}:
            fail(f"{row.get('case')}: invalid L1 verdict: {verdict}")
        if verdict == "FAIL":
            fail(f"{row.get('case')}: L1 FAIL blocks visual acceptance")
    return rows


def check_l2_item(evidence_dir: Path, case_id: str) -> dict[str, Any]:
    item_path = evidence_dir / "l2" / f"{case_id}.json"
    if not item_path.is_file():
        fail(f"missing L2 item: {item_path}")
    item = load_json(item_path)
    if item.get("case_id") != case_id:
        fail(f"{case_id}: case_id mismatch")
    if item.get("proof_class") != "local_l2_ocr_contrast_ssim":
        fail(f"{case_id}: proof_class must be local_l2_ocr_contrast_ssim")
    if item.get("verdict") != "PASS":
        fail(f"{case_id}: L2 verdict must be PASS")

    ocr = item.get("ocr")
    if not isinstance(ocr, dict):
        fail(f"{case_id}: missing ocr object")
    if ocr.get("engine") != "VNRecognizeTextRequest":
        fail(f"{case_id}: OCR engine must be VNRecognizeTextRequest")
    if ocr.get("status") != "PASS":
        fail(f"{case_id}: OCR status must be PASS")
    if ocr.get("missing_text"):
        fail(f"{case_id}: OCR missing expected text: {ocr.get('missing_text')}")

    contrast = item.get("contrast")
    if not isinstance(contrast, dict):
        fail(f"{case_id}: missing contrast object")
    if contrast.get("status") != "PASS":
        fail(f"{case_id}: contrast status must be PASS")
    if not isinstance(contrast.get("min_ratio"), (int, float)) or contrast["min_ratio"] <= 0:
        fail(f"{case_id}: contrast min_ratio must be positive number")

    ssim = item.get("ssim")
    if not isinstance(ssim, dict):
        fail(f"{case_id}: missing ssim object")
    if ssim.get("status") != "RECORDED":
        fail(f"{case_id}: SSIM must be recorded when L1 anchor exists")
    if not isinstance(ssim.get("value"), (int, float)):
        fail(f"{case_id}: SSIM value must be numeric")

    ui_tree = item.get("ui_tree_corroboration")
    if not isinstance(ui_tree, dict) or ui_tree.get("note") != "UI tree is corroboration only and cannot replace OCR":
        fail(f"{case_id}: UI tree corroboration boundary missing")
    return item


def check_or_write_summary(evidence_dir: Path, summary: dict[str, Any], write_summary: bool) -> None:
    summary_path = evidence_dir / "l2" / "l2-summary.json"
    serialized = json.dumps(summary, ensure_ascii=False, indent=2) + "\n"

    if write_summary:
        summary_path.write_text(serialized, encoding="utf-8")
        return

    if not summary_path.is_file():
        fail(f"missing L2 summary: {summary_path}; rerun with --write-summary after regenerating L2 item JSON")

    existing = load_json(summary_path)
    if existing != summary:
        fail(f"L2 summary does not match current L2 item JSON: {summary_path}; rerun with --write-summary")


def main() -> int:
    evidence_dir, write_summary = parse_args()
    l1_rows = check_l1(evidence_dir)
    l2_items = [check_l2_item(evidence_dir, case_id) for case_id in EXPECTED_CASES]

    summary = {
        "proof_class": "local_l2_ocr_contrast_ssim",
        "cases": [
            {
                "case_id": item["case_id"],
                "l1_verdict": next(row["l1_verdict"] for row in l1_rows if row["case"] == item["case_id"]),
                "l2_verdict": item["verdict"],
                "ocr_status": item["ocr"]["status"],
                "contrast_status": item["contrast"]["status"],
                "contrast_min_ratio": item["contrast"]["min_ratio"],
                "ssim": item["ssim"]["value"],
            }
            for item in l2_items
        ],
        "claims_not_made": ["L3", "V-PASS", "mobile", "true_device", "A-2 complete"],
    }
    check_or_write_summary(evidence_dir, summary, write_summary)
    print("PASS: 8.C2 L2 evidence package is complete")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

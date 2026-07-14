from __future__ import annotations

import json
from collections import Counter
from pathlib import Path
from typing import Any

from .constants import (
    HOLDOUT_BUCKETS,
    HOLDOUT_PATH,
    HOLDOUT_PIN_PATH,
    HOLDOUT_ROW_COUNT,
    HOLDOUT_SHA256,
)
from .identity import file_sha256


def read_jsonl(path: Path) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    with path.open("r", encoding="utf-8") as handle:
        for line_no, raw in enumerate(handle, 1):
            text = raw.strip()
            if not text:
                continue
            row = json.loads(text)
            if not isinstance(row, dict):
                raise ValueError(f"{path}:{line_no}: row must be object")
            rows.append(row)
    return rows


def verify_holdout(
    path: Path | None = None,
    *,
    expected_sha256: str = HOLDOUT_SHA256,
    expected_row_count: int = HOLDOUT_ROW_COUNT,
) -> dict[str, Any]:
    holdout_path = path or HOLDOUT_PATH
    errors: list[dict[str, str]] = []
    if not holdout_path.exists():
        return {
            "ok": False,
            "path": str(holdout_path),
            "errors": [
                {
                    "code": "E_HOLDOUT_SHA_MISMATCH",
                    "detail": f"missing holdout fixture: {holdout_path}",
                }
            ],
        }

    actual_sha = file_sha256(holdout_path)
    rows = read_jsonl(holdout_path)
    actual_count = len(rows)
    if actual_sha != expected_sha256:
        errors.append(
            {
                "code": "E_HOLDOUT_SHA_MISMATCH",
                "detail": f"expected {expected_sha256}, got {actual_sha}",
            }
        )
    if actual_count != expected_row_count:
        errors.append(
            {
                "code": "E_HOLDOUT_ROW_COUNT_MISMATCH",
                "detail": f"expected {expected_row_count}, got {actual_count}",
            }
        )

    families = Counter(str(row.get("holdout_family") or "") for row in rows)
    # D-127 buckets use family names; map empty keys out.
    bucket_check = {
        "primary_can_question": families.get("primary_can_question", 0),
        "topic_fronted": families.get("topic_fronted", 0),
        "negative_can_question": families.get("negative_can_question", 0),
        "particle_tail": families.get("particle_tail", 0),
    }
    # Soft note only if buckets drift; hard fail remains sha+count.
    bucket_note = None
    if bucket_check != HOLDOUT_BUCKETS and not errors:
        bucket_note = {
            "expected": HOLDOUT_BUCKETS,
            "observed": bucket_check,
            "note": "bucket counts differ from D-127 prose pin; sha/row_count still authoritative",
        }

    return {
        "ok": not errors,
        "path": str(holdout_path),
        "sha256": actual_sha,
        "row_count": actual_count,
        "buckets": bucket_check,
        "bucket_note": bucket_note,
        "errors": errors,
        "case_ids": [
            str(row.get("row_id") or row.get("case_id") or f"line-{index}")
            for index, row in enumerate(rows, 1)
        ],
        "rows": rows,
    }


def load_pin_document(path: Path | None = None) -> dict[str, Any]:
    pin_path = path or HOLDOUT_PIN_PATH
    if pin_path.exists():
        return json.loads(pin_path.read_text(encoding="utf-8"))
    return {
        "schema_version": "holdout_pin_v1",
        "sha256": HOLDOUT_SHA256,
        "row_count": HOLDOUT_ROW_COUNT,
        "path": str(HOLDOUT_PATH.relative_to(HOLDOUT_PATH.parents[2])),
        "decision_ref": "D-127",
    }

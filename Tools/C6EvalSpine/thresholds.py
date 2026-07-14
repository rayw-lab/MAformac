from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from .constants import V1_AUTHORITY_DIGEST, V1_AUTHORITY_PATH
from .identity import file_sha256


def load_authority(path: Path | None = None) -> dict[str, Any]:
    authority_path = path or V1_AUTHORITY_PATH
    doc = json.loads(authority_path.read_text(encoding="utf-8"))
    if not isinstance(doc, dict):
        raise ValueError(f"authority must be object: {authority_path}")
    return doc


def load_thresholds_from_v1(
    authority_path: Path | None = None,
    *,
    expected_digest: str | None = V1_AUTHORITY_DIGEST,
    allow_embedded_thresholds: dict[str, Any] | None = None,
) -> dict[str, Any]:
    """Load thresholds ONLY from V1 subject.four_layer_thresholds.

    If allow_embedded_thresholds is provided and differs from V1, raise
    E_THRESHOLD_REINVENT via returned errors structure.
    """
    path = authority_path or V1_AUTHORITY_PATH
    doc = load_authority(path)
    digest = ((doc.get("digest") or {}) if isinstance(doc.get("digest"), dict) else {}).get(
        "sha256"
    )
    status = doc.get("status")
    subject = doc.get("subject") if isinstance(doc.get("subject"), dict) else {}
    thresholds = subject.get("four_layer_thresholds")
    errors: list[dict[str, str]] = []

    if expected_digest is not None and digest != expected_digest:
        # Live digest may drift if authority file changed; still bind observed.
        # For harness pin we record mismatch but allow fixture mode consumers
        # to pass expected_digest=None. Callers decide fail-closed.
        errors.append(
            {
                "code": "E_V1_DIGEST_MISMATCH",
                "detail": f"expected {expected_digest}, got {digest}",
            }
        )

    if not isinstance(thresholds, dict):
        errors.append(
            {
                "code": "E_SCHEMA",
                "detail": "subject.four_layer_thresholds missing or not object",
            }
        )
        thresholds = {}

    if allow_embedded_thresholds is not None:
        if allow_embedded_thresholds != thresholds:
            errors.append(
                {
                    "code": "E_THRESHOLD_REINVENT",
                    "detail": "embedded thresholds differ from V1 subject.four_layer_thresholds",
                }
            )

    return {
        "ok": not errors,
        "authority_path": str(path),
        "authority_digest": digest,
        "file_sha256": file_sha256(path) if path.exists() else None,
        "status": status,
        "thresholds": thresholds,
        "behavior_classes": list(subject.get("behavior_classes") or []),
        "readback_fields": list(subject.get("readback_fields") or []),
        "errors": errors,
        "doc": doc,
    }


def evaluate_layer_gate(layer_name: str, thresholds: dict[str, Any], pass_count: int, eligible: int) -> dict[str, Any]:
    """Apply V1 four-layer thresholds. No reinvented constants."""
    if eligible < 0 or pass_count < 0 or pass_count > eligible:
        return {
            "layer": layer_name,
            "eligible": eligible,
            "pass": pass_count,
            "gate": "FAIL",
            "reason": "invalid_counts",
        }
    if eligible == 0:
        return {
            "layer": layer_name,
            "eligible": 0,
            "pass": 0,
            "gate": "UNKNOWN",
            "reason": "denominator_zero",
            "hard_pass": None,
        }

    spec = thresholds.get(layer_name)
    if layer_name == "demo_fuzz":
        # formula: 5*pass >= 4*eligible (from V1 description; do not hardcode ratio elsewhere)
        formula = None
        if isinstance(spec, dict):
            formula = spec.get("formula")
        ok = (5 * pass_count) >= (4 * eligible)
        return {
            "layer": layer_name,
            "eligible": eligible,
            "pass": pass_count,
            "formula": formula or "5*pass >= 4*eligible",
            "gate": "PASS" if ok else "FAIL",
            "hard_pass": ok,
        }

    threshold = float(spec) if isinstance(spec, (int, float)) else 1.0
    rate = pass_count / eligible
    ok = rate + 1e-12 >= threshold
    return {
        "layer": layer_name,
        "eligible": eligible,
        "pass": pass_count,
        "threshold": threshold,
        "rate": rate,
        "gate": "PASS" if ok else "FAIL",
        "hard_pass": ok,
    }

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any

from .constants import (
    CANONICAL_DEMO_FUZZ_FORMULA,
    V1_AUTHORITY_DIGEST,
    V1_AUTHORITY_PATH,
)
from .identity import file_sha256

REQUIRED_FOUR_LAYER_KEYS = ("golden", "demo_fuzz", "unsupported", "safety")
NUMERIC_LAYER_KEYS = frozenset({"golden", "unsupported", "safety"})


def load_authority(path: Path | None = None) -> dict[str, Any]:
    authority_path = path or V1_AUTHORITY_PATH
    doc = json.loads(authority_path.read_text(encoding="utf-8"))
    if not isinstance(doc, dict):
        raise ValueError(f"authority must be object: {authority_path}")
    return doc


def normalize_formula(formula: str | None) -> str:
    """Whitespace-insensitive formula normalizer (no silent rewrite of operators)."""
    if formula is None:
        return ""
    return re.sub(r"\s+", "", str(formula).strip())


def is_canonical_demo_fuzz_formula(formula: str | None) -> bool:
    return normalize_formula(formula) == normalize_formula(CANONICAL_DEMO_FUZZ_FORMULA)


def validate_four_layer_thresholds(thresholds: Any) -> list[dict[str, str]]:
    """Require exact four keys with correct type/range/canonical demo formula.

    Never synthesize defaults for absent authority layers.
    """
    errors: list[dict[str, str]] = []
    if not isinstance(thresholds, dict):
        return [
            {
                "code": "E_THRESHOLD_INCOMPLETE",
                "detail": "subject.four_layer_thresholds missing or not object",
            }
        ]

    present = set(thresholds.keys())
    required = set(REQUIRED_FOUR_LAYER_KEYS)
    missing = sorted(required - present)
    extra = sorted(present - required)
    if missing or extra:
        errors.append(
            {
                "code": "E_THRESHOLD_INCOMPLETE",
                "detail": (
                    "four_layer_thresholds must contain exactly "
                    f"{list(REQUIRED_FOUR_LAYER_KEYS)}; "
                    f"missing={missing} extra={extra}"
                ),
            }
        )

    for key in NUMERIC_LAYER_KEYS:
        if key not in thresholds:
            continue
        spec = thresholds.get(key)
        if not isinstance(spec, (int, float)) or isinstance(spec, bool):
            errors.append(
                {
                    "code": "E_THRESHOLD_INCOMPLETE",
                    "detail": f"layer {key} must be numeric threshold in [0,1], got {spec!r}",
                }
            )
            continue
        value = float(spec)
        if value < 0.0 or value > 1.0:
            errors.append(
                {
                    "code": "E_THRESHOLD_INCOMPLETE",
                    "detail": f"layer {key} threshold out of range [0,1]: {value}",
                }
            )

    if "demo_fuzz" in thresholds:
        demo_spec = thresholds.get("demo_fuzz")
        if not isinstance(demo_spec, dict):
            errors.append(
                {
                    "code": "E_THRESHOLD_INCOMPLETE",
                    "detail": f"demo_fuzz must be object with formula, got {type(demo_spec).__name__}",
                }
            )
        else:
            demo_formula = demo_spec.get("formula")
            if not is_canonical_demo_fuzz_formula(
                demo_formula if isinstance(demo_formula, str) else None
            ):
                errors.append(
                    {
                        "code": "E_V1_FORMULA_DRIFT",
                        "detail": (
                            f"demo_fuzz.formula must be {CANONICAL_DEMO_FUZZ_FORMULA!r}; "
                            f"got {demo_formula!r}"
                        ),
                    }
                )
    return errors


def load_thresholds_from_v1(
    authority_path: Path | None = None,
    *,
    expected_digest: str | None = V1_AUTHORITY_DIGEST,
    allow_embedded_thresholds: dict[str, Any] | None = None,
) -> dict[str, Any]:
    """Load thresholds ONLY from V1 subject.four_layer_thresholds.

    If allow_embedded_thresholds is provided and differs from V1, raise
    E_THRESHOLD_REINVENT via returned errors structure.
    Missing/extra/malformed layer specs fail closed; never default absent layers.
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
        # REAL mode callers MUST treat E_V1_DIGEST_MISMATCH as hard fail.
        # Fixture/dry_run may soft-warn when expected_digest is None.
        errors.append(
            {
                "code": "E_V1_DIGEST_MISMATCH",
                "detail": f"expected {expected_digest}, got {digest}",
            }
        )

    if not isinstance(thresholds, dict):
        errors.append(
            {
                "code": "E_THRESHOLD_INCOMPLETE",
                "detail": "subject.four_layer_thresholds missing or not object",
            }
        )
        thresholds = {}
    else:
        errors.extend(validate_four_layer_thresholds(thresholds))

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
    """Apply V1 four-layer thresholds. No reinvented constants or missing defaults."""
    if eligible < 0 or pass_count < 0 or pass_count > eligible:
        return {
            "layer": layer_name,
            "eligible": eligible,
            "pass": pass_count,
            "gate": "FAIL",
            "reason": "invalid_counts",
            "formula_ok": None,
            "threshold_ok": False,
        }
    if eligible == 0:
        # Still require the layer spec to exist; zero-denom does not invent thresholds.
        if not isinstance(thresholds, dict) or layer_name not in thresholds:
            return {
                "layer": layer_name,
                "eligible": 0,
                "pass": 0,
                "gate": "FAIL",
                "reason": "missing_threshold",
                "hard_pass": False,
                "formula_ok": None,
                "threshold_ok": False,
            }
        return {
            "layer": layer_name,
            "eligible": 0,
            "pass": 0,
            "gate": "UNKNOWN",
            "reason": "denominator_zero",
            "hard_pass": None,
            "formula_ok": None if layer_name != "demo_fuzz" else True,
            "threshold_ok": True,
        }

    if not isinstance(thresholds, dict) or layer_name not in thresholds:
        return {
            "layer": layer_name,
            "eligible": eligible,
            "pass": pass_count,
            "gate": "FAIL",
            "hard_pass": False,
            "reason": "missing_threshold",
            "formula_ok": False if layer_name == "demo_fuzz" else None,
            "threshold_ok": False,
        }

    spec = thresholds.get(layer_name)
    if layer_name == "demo_fuzz":
        formula = None
        if isinstance(spec, dict):
            formula = spec.get("formula")
        formula_ok = is_canonical_demo_fuzz_formula(
            formula if isinstance(formula, str) else None
        )
        if not formula_ok:
            return {
                "layer": layer_name,
                "eligible": eligible,
                "pass": pass_count,
                "formula": formula,
                "formula_ok": False,
                "threshold_ok": False,
                "canonical_formula": CANONICAL_DEMO_FUZZ_FORMULA,
                "gate": "FAIL",
                "hard_pass": False,
                "reason": "formula_drift",
            }
        # Only evaluate after formula binding passes (canonical: 5*pass >= 4*eligible).
        ok = (5 * pass_count) >= (4 * eligible)
        return {
            "layer": layer_name,
            "eligible": eligible,
            "pass": pass_count,
            "formula": CANONICAL_DEMO_FUZZ_FORMULA,
            "formula_ok": True,
            "threshold_ok": True,
            "gate": "PASS" if ok else "FAIL",
            "hard_pass": ok,
        }

    if not isinstance(spec, (int, float)) or isinstance(spec, bool):
        return {
            "layer": layer_name,
            "eligible": eligible,
            "pass": pass_count,
            "gate": "FAIL",
            "hard_pass": False,
            "reason": "malformed_threshold",
            "threshold": spec,
            "threshold_ok": False,
            "formula_ok": None,
        }
    threshold = float(spec)
    if threshold < 0.0 or threshold > 1.0:
        return {
            "layer": layer_name,
            "eligible": eligible,
            "pass": pass_count,
            "gate": "FAIL",
            "hard_pass": False,
            "reason": "threshold_out_of_range",
            "threshold": threshold,
            "threshold_ok": False,
            "formula_ok": None,
        }
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
        "threshold_ok": True,
        "formula_ok": None,
    }

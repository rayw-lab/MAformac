"""C6EvalSpine — S9→S9b→S10→S11 fixture/dry-run harness.

LOCAL harness only. Does NOT claim:
  - B2/B3/B4 package DONE
  - B7/V1 canonical DONE / RATIFIED
  - real three-arm model quality
  - C6 acceptance / V-PASS / candidate signed
  - S8 adapter presence

Thresholds are read exclusively from V1 authority
`subject.four_layer_thresholds`. No second constant set.
"""

from __future__ import annotations

from .constants import (
    ALLOWED_BEHAVIOR_CLASSES,
    HOLDOUT_ROW_COUNT,
    HOLDOUT_SHA256,
    PLAN_P_READBACK_FIELDS,
    REPO_ROOT,
    SPINE_PACKAGE,
)
from .identity import build_subject, join_subject_keys, subject_digest
from .modes import Mode, normalize_mode
from .spine import (
    Failure,
    SpineResult,
    run_fixture_replay,
    run_stage,
    validate_claims_forbidden,
)

__all__ = [
    "ALLOWED_BEHAVIOR_CLASSES",
    "Failure",
    "HOLDOUT_ROW_COUNT",
    "HOLDOUT_SHA256",
    "Mode",
    "PLAN_P_READBACK_FIELDS",
    "REPO_ROOT",
    "SPINE_PACKAGE",
    "SpineResult",
    "build_subject",
    "join_subject_keys",
    "normalize_mode",
    "run_fixture_replay",
    "run_stage",
    "subject_digest",
    "validate_claims_forbidden",
]

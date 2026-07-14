from __future__ import annotations

from collections import Counter, defaultdict
from typing import Any

from .constants import ALLOWED_BEHAVIOR_CLASSES, HOLDOUT_ROW_COUNT
from .holdout_pin import verify_holdout
from .identity import join_subject_keys, subject_digest
from .modes import Mode, normalize_mode


def _authoritative_case_ids(s9_receipt: dict[str, Any]) -> list[str]:
    explicit = s9_receipt.get("expected_case_ids")
    if isinstance(explicit, list) and explicit:
        return [str(x) for x in explicit]
    holdout = verify_holdout()
    return list(holdout.get("case_ids") or [])


def _check_caseset_completeness(
    *,
    mode: Mode,
    fixture_subset: bool,
    expected_case_ids: list[str],
    case_ids_by_arm: dict[str, list[str]],
    active_arms: list[str],
    results: list[Any],
) -> list[dict[str, str]]:
    """Empty always fails. REAL requires exact authoritative set per arm.

    Fixture/dry_run may use a non-empty subset only when fixture_subset=true.
    """
    errors: list[dict[str, str]] = []
    if not results:
        errors.append(
            {
                "code": "E_CASESET_INCOMPLETE",
                "detail": "empty results; never a real claim in any mode",
            }
        )
        return errors

    expected = set(expected_case_ids)
    if mode == Mode.REAL:
        # Every required arm must expose exactly the authoritative case set.
        target_arms = active_arms or list(case_ids_by_arm.keys())
        if not target_arms:
            errors.append(
                {
                    "code": "E_CASESET_INCOMPLETE",
                    "detail": "REAL mode has no arm case sets",
                }
            )
            return errors
        for arm_id in ("base", "old", "new"):
            observed_list = case_ids_by_arm.get(arm_id) or []
            observed = set(observed_list)
            if len(observed_list) != len(observed):
                errors.append(
                    {
                        "code": "E_CASESET_INCOMPLETE",
                        "detail": f"arm {arm_id}: duplicate case ids in REAL caseset",
                    }
                )
            if observed != expected:
                missing = sorted(expected - observed)
                extra = sorted(observed - expected)
                errors.append(
                    {
                        "code": "E_CASESET_INCOMPLETE",
                        "detail": (
                            f"arm {arm_id}: REAL requires exact {len(expected)}-case set "
                            f"(expected_row_count={HOLDOUT_ROW_COUNT}); "
                            f"missing={len(missing)} extra={len(extra)}"
                        ),
                    }
                )
        return errors

    # Fixture / dry_run
    if fixture_subset:
        # Subset allowed only if non-empty (already checked) and no arm is empty
        # among active arms. Cross-arm consistency handled separately.
        for arm_id in active_arms:
            if not case_ids_by_arm.get(arm_id):
                errors.append(
                    {
                        "code": "E_CASESET_INCOMPLETE",
                        "detail": f"arm {arm_id}: empty case set under fixture_subset",
                    }
                )
        return errors

    # Full set required when not explicitly marked subset.
    for arm_id in active_arms:
        observed = set(case_ids_by_arm.get(arm_id) or [])
        if observed != expected:
            missing = sorted(expected - observed)
            extra = sorted(observed - expected)
            errors.append(
                {
                    "code": "E_CASESET_INCOMPLETE",
                    "detail": (
                        f"arm {arm_id}: full caseset required without fixture_subset=true; "
                        f"missing={len(missing)} extra={len(extra)}"
                    ),
                }
            )
    return errors


def aggregate_s9b(
    s9_receipt: dict[str, Any],
    *,
    require_all_arms: bool | None = None,
) -> dict[str, Any]:
    """Same-subject exact join over (case_id × arm_id)."""
    errors: list[dict[str, str]] = []
    mode = normalize_mode(s9_receipt.get("mode") or "fixture")
    if require_all_arms is None:
        require_all_arms = mode == Mode.REAL

    subject = s9_receipt.get("subject") if isinstance(s9_receipt.get("subject"), dict) else {}
    results = s9_receipt.get("results") if isinstance(s9_receipt.get("results"), list) else []
    expected_join = join_subject_keys(subject)
    fixture_subset = bool(s9_receipt.get("fixture_subset"))
    if mode == Mode.REAL:
        fixture_subset = False
    expected_case_ids = _authoritative_case_ids(s9_receipt)

    by_arm: dict[str, list[dict[str, Any]]] = defaultdict(list)
    case_ids_by_arm: dict[str, list[str]] = defaultdict(list)
    seen_pairs: set[tuple[str, str]] = set()

    for item in results:
        if not isinstance(item, dict):
            errors.append({"code": "E_SCHEMA", "detail": "result row not object"})
            continue
        arm_id = str(item.get("arm_id") or "")
        case_id = str(item.get("case_id") or "")
        if not arm_id or not case_id:
            errors.append({"code": "E_SCHEMA", "detail": "result missing arm_id/case_id"})
            continue
        pair = (case_id, arm_id)
        if pair in seen_pairs:
            errors.append(
                {
                    "code": "E_DUPLICATE_CASE",
                    "detail": f"duplicate case_id within arm: {case_id}/{arm_id}",
                }
            )
            continue
        seen_pairs.add(pair)

        join_keys = item.get("join_keys") if isinstance(item.get("join_keys"), dict) else {}
        if join_keys != expected_join:
            errors.append(
                {
                    "code": "E_INCOMPARABLE_SUBJECT",
                    "detail": f"join subject mismatch for {case_id}/{arm_id}",
                }
            )

        behavior = item.get("behavior_class_observed")
        if behavior not in ALLOWED_BEHAVIOR_CLASSES:
            errors.append(
                {
                    "code": "E_UNKNOWN_BEHAVIOR_CLASS",
                    "detail": f"{case_id}/{arm_id}: {behavior!r}",
                }
            )

        by_arm[arm_id].append(item)
        case_ids_by_arm[arm_id].append(case_id)

    present_arms = set(by_arm)
    required_arms = {"base", "old", "new"}
    if require_all_arms:
        for arm_id in sorted(required_arms - present_arms):
            errors.append({"code": "E_MISSING_ARM", "detail": f"missing arm results: {arm_id}"})
        # For real, absent/synthetic score_class is not real join material
        for arm_id, rows in by_arm.items():
            if any(r.get("score_class") == "absent" for r in rows):
                errors.append(
                    {
                        "code": "E_MISSING_ARM",
                        "detail": f"arm {arm_id} has absent score_class under real join",
                    }
                )
            if any(r.get("score_class") == "synthetic" for r in rows):
                errors.append(
                    {
                        "code": "E_SYNTHETIC_SCORE_IN_REAL",
                        "detail": f"arm {arm_id} has synthetic score_class under real join",
                    }
                )
            if any(r.get("score_class") not in {"real_model", "absent", "synthetic"} for r in rows):
                errors.append(
                    {
                        "code": "E_SCHEMA",
                        "detail": f"arm {arm_id} has invalid score_class under real join",
                    }
                )
            # real join requires real_model only (absent already flagged above)
            if rows and all(r.get("score_class") != "real_model" for r in rows):
                if not any(r.get("score_class") == "synthetic" for r in rows):
                    errors.append(
                        {
                            "code": "E_NO_REAL_SCORES",
                            "detail": f"arm {arm_id} has no real_model scores under real join",
                        }
                    )

    # Join completeness across arms that produced non-absent rows
    active_arms = [
        arm_id
        for arm_id, rows in by_arm.items()
        if any(r.get("score_class") != "absent" for r in rows)
    ]
    if len(active_arms) >= 2:
        reference = set(case_ids_by_arm[active_arms[0]])
        for arm_id in active_arms[1:]:
            current = set(case_ids_by_arm[arm_id])
            missing = reference - current
            extra = current - reference
            for case_id in sorted(missing):
                errors.append(
                    {
                        "code": "E_MISSING_CASE",
                        "detail": f"case {case_id} missing on arm {arm_id}",
                    }
                )
            for case_id in sorted(extra):
                errors.append(
                    {
                        "code": "E_MISSING_CASE",
                        "detail": f"case {case_id} present on {arm_id} but missing on {active_arms[0]}",
                    }
                )

    # Authoritative caseset completeness (empty / truncation / full-set binding).
    errors.extend(
        _check_caseset_completeness(
            mode=mode,
            fixture_subset=fixture_subset,
            expected_case_ids=expected_case_ids,
            case_ids_by_arm=case_ids_by_arm,
            active_arms=active_arms,
            results=results,
        )
    )

    per_arm: dict[str, Any] = {}
    for arm_id, rows in by_arm.items():
        # REAL eligible counts only real_model; fixture/dry_run counts non-absent.
        if mode == Mode.REAL:
            eligible = [r for r in rows if r.get("score_class") == "real_model"]
            synthetic_count = sum(1 for r in rows if r.get("score_class") == "synthetic")
        else:
            eligible = [r for r in rows if r.get("score_class") != "absent"]
            synthetic_count = sum(1 for r in rows if r.get("score_class") == "synthetic")
        passes = [r for r in eligible if r.get("model_hard_pass") is True]
        families = Counter(str(r.get("holdout_family") or "unknown") for r in eligible)
        behaviors = Counter(str(r.get("behavior_class_observed") or "unknown") for r in eligible)
        per_arm[arm_id] = {
            "eligible": len(eligible),
            "pass": len(passes),
            "absent": sum(1 for r in rows if r.get("score_class") == "absent"),
            "synthetic": synthetic_count,
            "real_model": sum(1 for r in rows if r.get("score_class") == "real_model"),
            "pass_rate": (len(passes) / len(eligible)) if eligible else None,
            "families": dict(families),
            "behaviors": dict(behaviors),
        }

    # Layer placeholder counts for fixture: map holdout_family heuristically.
    # Real S10 maps cases to golden/demo_fuzz/unsupported/safety via corpus tags.
    # Fixture uses synthetic mapping only for harness wiring, not acceptance.
    layers = {
        "golden": {"eligible": 0, "pass": 0},
        "demo_fuzz": {"eligible": 0, "pass": 0},
        "unsupported": {"eligible": 0, "pass": 0},
        "safety": {"eligible": 0, "pass": 0},
    }
    # Prefer "new" if present with scores, else first active arm.
    preferred_arm = "new" if "new" in active_arms else (active_arms[0] if active_arms else None)
    if preferred_arm:
        for row in by_arm[preferred_arm]:
            # REAL: only real_model contributes layer eligible; synthetic must not inflate.
            if mode == Mode.REAL:
                if row.get("score_class") != "real_model":
                    continue
            elif row.get("score_class") == "absent":
                continue
            family = str(row.get("holdout_family") or "")
            if family.startswith("negative"):
                layer = "unsupported"
            elif family == "particle_tail":
                layer = "demo_fuzz"
            elif family == "topic_fronted":
                layer = "demo_fuzz"
            else:
                layer = "golden"
            layers[layer]["eligible"] += 1
            if row.get("model_hard_pass") is True:
                layers[layer]["pass"] += 1
        # Safety remains 0 in fixture holdout mapping (honest zero denom).

    if any(e.get("code") == "E_INCOMPARABLE_SUBJECT" for e in errors):
        status = "INCOMPARABLE"
    elif errors:
        status = "FAIL"
    else:
        status = "PASS"

    return {
        "schema_version": "s9b_aggregate_v1",
        "run_id": s9_receipt.get("run_id"),
        "mode": mode.value,
        "subject": subject,
        "subject_digest": subject_digest(subject) if subject else None,
        "status": status,
        "fixture_subset": fixture_subset,
        "expected_case_ids": expected_case_ids,
        "per_arm": per_arm,
        "join": {
            "active_arms": active_arms,
            "required_arms": sorted(required_arms),
            "require_all_arms": require_all_arms,
            "case_counts": {arm: len(ids) for arm, ids in case_ids_by_arm.items()},
            "seeds": [17, 29, 43],
            "seed": subject.get("seed"),
            "expected_case_count": len(expected_case_ids),
            "fixture_subset": fixture_subset,
        },
        "layers": layers,
        "buckets": {
            arm_id: per_arm[arm_id].get("families", {}) for arm_id in per_arm
        },
        "claims": {
            "package_b2_done": False,
            "package_b3_done": False,
            "s9_real_done": False,
            "c6_acceptance": False,
            "candidate_signed": False,
        },
        "errors": errors,
        "proof_class": "local_unit_fixture",
    }

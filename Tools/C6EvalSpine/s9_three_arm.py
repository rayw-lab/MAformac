from __future__ import annotations

from typing import Any

from .constants import (
    ALLOWED_BEHAVIOR_CLASSES,
    B7_ASSEMBLED_SHA256,
    B7_COMPAT_SHA256,
    B7_RECEIPT_PATH,
    B7_UNORDERED_ID_SET_SHA256,
    HOLDOUT_PATH,
    HOLDOUT_ROW_COUNT,
    HOLDOUT_SHA256,
    PLAN_P_READBACK_FIELDS,
    SCORER_ID_FIXTURE,
    V1_AUTHORITY_DIGEST,
    V1_AUTHORITY_PATH,
)
from .holdout_pin import verify_holdout
from .identity import build_subject, join_subject_keys, sha256_text, subject_digest
from .modes import Mode, normalize_mode
from .resume import check_resume_subject, load_partials, write_partial


def _empty_readback(basis: str = "fixture_synthetic") -> dict[str, Any]:
    return {
        "model_hard_pass_basis": basis,
        "model_hard_failed": False,
        "readback_applicable": True,
        "readback_match": True,
        "readback_hard_failed": False,
        "readback_excluded_from_model_hard_pass": True,
        "renderer_contract_digest": sha256_text("renderer_contract_fixture_v1"),
    }


def validate_readback(readback: dict[str, Any] | None) -> list[dict[str, str]]:
    errors: list[dict[str, str]] = []
    if not isinstance(readback, dict):
        return [{"code": "E_UNKNOWN_READBACK_FIELD", "detail": "readback missing"}]
    for field in PLAN_P_READBACK_FIELDS:
        if field not in readback:
            errors.append(
                {
                    "code": "E_UNKNOWN_READBACK_FIELD",
                    "detail": f"missing readback field: {field}",
                }
            )
    return errors


def validate_arm_descriptor(
    arm_id: str,
    arm: dict[str, Any],
    *,
    mode: Mode,
) -> list[dict[str, str]]:
    errors: list[dict[str, str]] = []
    status = arm.get("adapter_status")
    score_class = arm.get("score_class")
    if status not in {"present", "absent"}:
        errors.append(
            {
                "code": "E_SCHEMA",
                "detail": f"arms.{arm_id}.adapter_status invalid: {status!r}",
            }
        )
    if score_class not in {"real_model", "synthetic", "absent"}:
        errors.append(
            {
                "code": "E_SCHEMA",
                "detail": f"arms.{arm_id}.score_class invalid: {score_class!r}",
            }
        )
    if score_class == "real_model" and status != "present":
        errors.append(
            {
                "code": "E_FORGED_REAL_SCORE",
                "detail": f"arm {arm_id} claims real_model without present adapter",
            }
        )
    if mode in {Mode.FIXTURE, Mode.DRY_RUN} and score_class == "real_model":
        errors.append(
            {
                "code": "E_FORGED_REAL_SCORE",
                "detail": f"mode={mode.value} forbids score_class=real_model on arm {arm_id}",
            }
        )
    if mode == Mode.REAL and arm_id == "new" and status == "absent":
        errors.append(
            {
                "code": "E_MODE_REAL_WITHOUT_NEW_ADAPTER",
                "detail": "mode=real requires arms.new.adapter_status=present",
            }
        )
    return errors


def map_holdout_behavior(row: dict[str, Any]) -> str:
    """Deterministic fixture behavior class mapping from holdout row."""
    expected = row.get("expected_tool_calls")
    if isinstance(expected, list) and len(expected) == 0:
        subtype = str(row.get("register_subtype") or "")
        if "negative" in subtype or str(row.get("holdout_family") or "").startswith("negative"):
            return "already_state_noop"
        return "already_state_noop"
    return "tool_call"


def synthetic_arm_result(
    *,
    run_id: str,
    arm_id: str,
    case_id: str,
    row: dict[str, Any],
    subject: dict[str, Any],
    score_class: str,
    model_hard_pass: bool = True,
    behavior_class: str | None = None,
) -> dict[str, Any]:
    behavior = behavior_class or map_holdout_behavior(row)
    result = {
        "schema_version": "s9_arm_result_v1",
        "run_id": run_id,
        "arm_id": arm_id,
        "case_id": case_id,
        "score_class": score_class,
        "behavior_class_observed": behavior,
        "model_hard_pass": bool(model_hard_pass) if score_class != "absent" else False,
        "readback": _empty_readback(),
        "join_keys": join_subject_keys(subject),
        "raw_output_sha256": sha256_text(f"{run_id}|{arm_id}|{case_id}|synthetic")
        if score_class != "absent"
        else None,
        "error_code": None if score_class != "absent" else "ABSENT_ADAPTER",
        "scorer_id": SCORER_ID_FIXTURE if score_class == "synthetic" else None,
        "holdout_family": row.get("holdout_family"),
    }
    return result


def default_fixture_arms(*, new_absent: bool = True) -> dict[str, dict[str, Any]]:
    return {
        "base": {
            "arm_id": "base",
            "adapter_status": "present",
            "score_class": "synthetic",
            "artifact": {"kind": "fixture_base", "sha256": sha256_text("fixture_base_arm")},
        },
        "old": {
            "arm_id": "old",
            "adapter_status": "present",
            "score_class": "synthetic",
            "artifact": {"kind": "fixture_old", "sha256": sha256_text("fixture_old_arm")},
        },
        "new": {
            "arm_id": "new",
            "adapter_status": "absent" if new_absent else "present",
            "score_class": "absent" if new_absent else "synthetic",
            "artifact": None
            if new_absent
            else {"kind": "fixture_new", "sha256": sha256_text("fixture_new_arm")},
        },
    }


def build_s9_manifest(
    *,
    mode: Mode | str,
    run_id: str,
    subject: dict[str, Any] | None = None,
    arms: dict[str, dict[str, Any]] | None = None,
    holdout_path: str | None = None,
    case_limit: int | None = None,
) -> dict[str, Any]:
    mode_obj = normalize_mode(mode)
    subj = subject or build_subject(mode=mode_obj, run_id=run_id)
    arm_map = arms or default_fixture_arms(new_absent=True)
    return {
        "schema_version": "s9_three_arm_manifest_v1",
        "run_id": run_id,
        "mode": mode_obj.value,
        "repo_head": subj["repo_head"],
        "basis_ids": [
            "EVAL-HOLDOUT-D127",
            "B7-CANDIDATE",
            "V1-CANDIDATE",
            "C6-EVAL-SPINE-HARNESS",
        ],
        "subject": subj,
        "holdout": {
            "path": holdout_path or str(HOLDOUT_PATH),
            "sha256": HOLDOUT_SHA256,
            "row_count": HOLDOUT_ROW_COUNT,
        },
        "b7": {
            "candidate_receipt": str(B7_RECEIPT_PATH),
            "assembled_sha256": B7_ASSEMBLED_SHA256,
            "compat_sha256": B7_COMPAT_SHA256,
            "unordered_id_set_sha256": B7_UNORDERED_ID_SET_SHA256,
            "is_b7_done": bool(subj.get("b7_is_done", False)),
        },
        "v1": {
            "authority_path": str(V1_AUTHORITY_PATH),
            "authority_digest": V1_AUTHORITY_DIGEST,
            "status": subj.get("v1_status", "CANDIDATE"),
            "thresholds_ref": "subject.four_layer_thresholds",
        },
        "arms": arm_map,
        "case_limit": case_limit,
        "exposure_gate": {
            "checker": "scripts/check_train_eval_exposure.py",
            "rc_required": 0,
        },
        "resume": {
            "partial_dir": None,
            "completed_case_ids": [],
            "sealed": False,
        },
        "claims": {
            "allowed": ["local_harness", "fixture_replay"],
            "forbidden": [
                "b2_done",
                "s9_real_done",
                "c6_acceptance",
                "v_pass",
                "candidate_signed",
            ],
            "package_b2_done": False,
            "s9_real_done": False,
            "c6_acceptance": False,
            "candidate_signed": False,
        },
        "proof_class": "local_unit_fixture",
    }


def run_s9(
    manifest: dict[str, Any],
    *,
    partial_dir: Any = None,
    inject_results: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """Run S9 three-arm harness (fixture/dry_run synthetic; real fail-closed)."""
    errors: list[dict[str, str]] = []
    mode = normalize_mode(manifest.get("mode"))
    run_id = str(manifest.get("run_id") or "s9-unknown")
    subject = manifest.get("subject") if isinstance(manifest.get("subject"), dict) else {}
    arms = manifest.get("arms") if isinstance(manifest.get("arms"), dict) else {}

    # Holdout pin
    holdout_info = verify_holdout()
    if not holdout_info["ok"]:
        errors.extend(holdout_info["errors"])

    # B7 pin (static expected digests)
    b7 = manifest.get("b7") if isinstance(manifest.get("b7"), dict) else {}
    if b7.get("assembled_sha256") and b7.get("assembled_sha256") != B7_ASSEMBLED_SHA256:
        errors.append(
            {
                "code": "E_B7_DIGEST_MISMATCH",
                "detail": "assembled_sha256 mismatch vs B7 candidate pin",
            }
        )
    if b7.get("compat_sha256") and b7.get("compat_sha256") != B7_COMPAT_SHA256:
        errors.append(
            {
                "code": "E_B7_DIGEST_MISMATCH",
                "detail": "compat_sha256 mismatch vs B7 candidate pin",
            }
        )
    if (
        b7.get("unordered_id_set_sha256")
        and b7.get("unordered_id_set_sha256") != B7_UNORDERED_ID_SET_SHA256
    ):
        errors.append(
            {
                "code": "E_B7_DIGEST_MISMATCH",
                "detail": "unordered_id_set_sha256 mismatch vs B7 candidate pin",
            }
        )

    if mode == Mode.REAL and not bool(b7.get("is_b7_done") or subject.get("b7_is_done")):
        errors.append(
            {
                "code": "E_B7_NOT_FROZEN",
                "detail": "mode=real requires b7_is_done=true",
            }
        )

    for arm_id in ("base", "old", "new"):
        arm = arms.get(arm_id)
        if not isinstance(arm, dict):
            errors.append({"code": "E_MISSING_ARM", "detail": f"missing arm {arm_id}"})
            continue
        errors.extend(validate_arm_descriptor(arm_id, arm, mode=mode))

    # Forbidden claims
    claims = manifest.get("claims") if isinstance(manifest.get("claims"), dict) else {}
    for key in ("package_b2_done", "s9_real_done", "c6_acceptance", "candidate_signed"):
        if claims.get(key) is True:
            errors.append(
                {
                    "code": "E_PACKAGE_DONE_CLAIM",
                    "detail": f"claims.{key}=true forbidden in harness",
                }
            )

    # Resume subject check
    partials: list[dict[str, Any]] = []
    if partial_dir is not None:
        partials = load_partials(partial_dir)
        errors.extend(check_resume_subject(partials, subject))

    results: list[dict[str, Any]] = []
    if inject_results is not None:
        results = list(inject_results)
        for item in results:
            errors.extend(validate_readback(item.get("readback")))
            behavior = item.get("behavior_class_observed")
            if behavior not in ALLOWED_BEHAVIOR_CLASSES:
                errors.append(
                    {
                        "code": "E_UNKNOWN_BEHAVIOR_CLASS",
                        "detail": f"unknown behavior_class_observed={behavior!r}",
                    }
                )
            if item.get("score_class") == "real_model" and mode != Mode.REAL:
                errors.append(
                    {
                        "code": "E_FORGED_REAL_SCORE",
                        "detail": f"forged real score in mode={mode.value}",
                    }
                )
    elif not errors:
        case_limit = manifest.get("case_limit")
        rows = holdout_info.get("rows") or []
        if isinstance(case_limit, int) and case_limit > 0:
            rows = rows[:case_limit]
        completed = {
            (str(p.get("case_id")), str(p.get("arm_id"))): p for p in partials if isinstance(p, dict)
        }
        for row in rows:
            case_id = str(row.get("row_id") or row.get("case_id"))
            for arm_id, arm in arms.items():
                key = (case_id, arm_id)
                if key in completed:
                    results.append(completed[key])
                    continue
                score_class = str(arm.get("score_class") or "absent")
                if score_class == "absent":
                    # For fixture replay, still emit absent rows for join visibility
                    # only when mode allows; real already failed above if new absent.
                    result = synthetic_arm_result(
                        run_id=run_id,
                        arm_id=arm_id,
                        case_id=case_id,
                        row=row,
                        subject=subject,
                        score_class="absent",
                        model_hard_pass=False,
                    )
                else:
                    result = synthetic_arm_result(
                        run_id=run_id,
                        arm_id=arm_id,
                        case_id=case_id,
                        row=row,
                        subject=subject,
                        score_class=score_class,
                        model_hard_pass=True,
                    )
                errors.extend(validate_readback(result.get("readback")))
                if result["behavior_class_observed"] not in ALLOWED_BEHAVIOR_CLASSES:
                    errors.append(
                        {
                            "code": "E_UNKNOWN_BEHAVIOR_CLASS",
                            "detail": result["behavior_class_observed"],
                        }
                    )
                if partial_dir is not None:
                    write_partial(partial_dir, result)
                results.append(result)

    sealed = False
    if not errors and results:
        sealed = True
        if isinstance(manifest.get("resume"), dict):
            manifest["resume"]["sealed"] = True
            manifest["resume"]["completed_case_ids"] = sorted(
                {str(r.get("case_id")) for r in results}
            )

    status = "PASS" if not errors else "FAIL"
    if mode == Mode.REAL and any(
        e.get("code") in {"E_MODE_REAL_WITHOUT_NEW_ADAPTER", "E_B7_NOT_FROZEN", "E_NO_REAL_SCORES"}
        for e in errors
    ):
        status = "BLOCKED"

    receipt = {
        "schema_version": "s9_run_receipt_v1",
        "status": status,
        "mode": mode.value,
        "run_id": run_id,
        "subject": subject,
        "subject_digest": subject_digest(subject) if subject else None,
        "holdout": {
            "sha256": holdout_info.get("sha256"),
            "row_count": holdout_info.get("row_count"),
            "path": holdout_info.get("path"),
        },
        "arms": arms,
        "results": results,
        "result_count": len(results),
        "sealed": sealed,
        "errors": errors,
        "claims": {
            "package_b2_done": False,
            "s9_real_done": False,
            "c6_acceptance": False,
            "candidate_signed": False,
            "score_class_note": "fixture/dry_run synthetic only; real scores absent",
        },
        "bindings": {
            "repo_head": subject.get("repo_head"),
            "holdout_sha256": subject.get("holdout_sha256"),
            "b7_assembled_sha256": subject.get("b7_assembled_sha256"),
            "v1_authority_digest": subject.get("v1_authority_digest"),
            "scorer_id": SCORER_ID_FIXTURE,
            "contract_bundle_digest": subject.get("contract_bundle_digest"),
            "adapter": {
                arm_id: {
                    "adapter_status": (arms.get(arm_id) or {}).get("adapter_status"),
                    "score_class": (arms.get(arm_id) or {}).get("score_class"),
                }
                for arm_id in ("base", "old", "new")
            },
        },
        "proof_class": "local_unit_fixture",
    }
    return receipt

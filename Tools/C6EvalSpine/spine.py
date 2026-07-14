from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from .constants import FIXTURES_DIR
from .exposure_bridge import run_exposure_gate
from .holdout_pin import verify_holdout
from .identity import build_subject, git_head
from .modes import Mode, normalize_mode
from .s10_verdict import build_s10_verdict
from .s11_renderer_ack import build_s11_ack
from .s9_three_arm import build_s9_manifest, run_s9
from .s9b_aggregate import aggregate_s9b


# Dispatch residual enum (exact): only still-true residual items.
# D-147 already satisfied t01/t02 decision ratification — do NOT list
# missing_t01_t02_ratification here.
RESIDUAL_ENUM = frozenset(
    {
        "missing_s8_adapter",
        "no_real_three_arm_scores",
        "none",
    }
)


@dataclass
class Failure:
    code: str
    detail: str
    stage: str = "any"


@dataclass
class SpineResult:
    ok: bool
    status: str
    mode: str
    stages: dict[str, Any] = field(default_factory=dict)
    errors: list[dict[str, str]] = field(default_factory=list)
    claims: dict[str, Any] = field(default_factory=dict)
    proof_class: str = "local_unit_integration_fixture"
    residual: list[str] = field(default_factory=list)
    authority_materialization_pending: dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> dict[str, Any]:
        return {
            "ok": self.ok,
            "status": self.status,
            "mode": self.mode,
            "stages": self.stages,
            "errors": self.errors,
            "claims": self.claims,
            "proof_class": self.proof_class,
            "residual": self.residual,
            "authority_materialization_pending": self.authority_materialization_pending,
        }


def default_authority_materialization_pending() -> dict[str, Any]:
    """Non-residual structure: B7 freeze execution + V1 ceremony still open.

    Distinct from residual enum. Decision-layer t01/t02 are already ratified
    (D-147); this tracks execution/artifact materialization only.
    """
    return {
        "schema_version": "authority_materialization_pending_v1",
        "not_residual_enum": True,
        "items": {
            "b7_freeze_execution": {
                "status": "pending",
                "detail": (
                    "B7 freeze execution / canonical receipt not completed "
                    "(candidate digests bound only)"
                ),
            },
            "v1_candidate_to_ratified_ceremony": {
                "status": "pending",
                "detail": (
                    "V1 CANDIDATE→RATIFIED artifact/operator ceremony not completed"
                ),
            },
        },
        "non_claims": [
            "not_t01_t02_decision_missing",
            "not_b7_done",
            "not_v1_ratified",
        ],
    }


def default_residual(*, mode: Mode) -> list[str]:
    # Fixture/dry_run harness always still missing S8 adapter + real three-arm scores.
    residual = ["missing_s8_adapter", "no_real_three_arm_scores"]
    # Keep only enum members.
    return [item for item in residual if item in RESIDUAL_ENUM]


def validate_claims_forbidden(payload: dict[str, Any]) -> list[dict[str, str]]:
    errors: list[dict[str, str]] = []
    claims = payload.get("claims")
    if not isinstance(claims, dict):
        return errors
    forbidden_true = {
        "package_b2_done",
        "package_b3_done",
        "package_b4_done",
        "s9_real_done",
        "s10_real_done",
        "c6_acceptance",
        "candidate_signed",
        "v_pass",
        "operator_pass",
    }
    for key in forbidden_true:
        if claims.get(key) is True:
            errors.append(
                {
                    "code": "E_PACKAGE_DONE_CLAIM",
                    "detail": f"claims.{key}=true forbidden",
                }
            )
    return errors


def run_stage(
    stage: str,
    *,
    mode: Mode | str = Mode.FIXTURE,
    case_limit: int | None = 8,
    partial_dir: Path | None = None,
    s9_receipt: dict[str, Any] | None = None,
    s9b: dict[str, Any] | None = None,
    s10: dict[str, Any] | None = None,
    inject_s9_results: list[dict[str, Any]] | None = None,
    embedded_thresholds: dict[str, Any] | None = None,
    force_s11_collapse: bool = False,
    run_id: str | None = None,
    new_absent: bool = True,
    skip_exposure: bool = False,
    qa_safety: dict[str, Any] | None = None,
    c5_phase1: dict[str, Any] | None = None,
    auto_prereq: bool = True,
) -> SpineResult:
    mode_obj = normalize_mode(mode)
    stage_name = stage.lower()
    errors: list[dict[str, str]] = []
    stages: dict[str, Any] = {}
    rid = run_id or f"s9-fixture-{git_head()[:8]}"

    # P1-E: target stage auto-runs required upstream chain when inputs absent.
    needs_s9 = stage_name in {"s9", "s9b", "s10", "s11", "all"}
    needs_s9b = stage_name in {"s9b", "s10", "s11", "all"}
    needs_s10 = stage_name in {"s10", "s11", "all"}
    needs_s11 = stage_name in {"s11", "all"}
    needs_preflight = stage_name in {"preflight", "s9", "all"} or (
        auto_prereq and stage_name in {"s9b", "s10", "s11"} and s9_receipt is None
    )

    if needs_preflight or stage_name in {"preflight", "all", "s9"}:
        holdout = verify_holdout()
        stages["preflight_holdout"] = {
            "ok": holdout["ok"],
            "sha256": holdout.get("sha256"),
            "row_count": holdout.get("row_count"),
            "errors": holdout.get("errors"),
        }
        if not holdout["ok"]:
            errors.extend(holdout["errors"])

        if not skip_exposure and (
            stage_name in {"preflight", "s9", "all"}
            or (auto_prereq and stage_name in {"s9b", "s10", "s11"} and s9_receipt is None)
        ):
            clean_train = FIXTURES_DIR / "exposure" / "clean" / "trainpack.jsonl"
            if clean_train.exists():
                exposure = run_exposure_gate(trainpack=clean_train)
                stages["preflight_exposure"] = {
                    "ok": exposure["ok"],
                    "rc": exposure["rc"],
                    "errors": exposure["errors"],
                }
                if not exposure["ok"]:
                    errors.extend(exposure["errors"])

    if needs_s9 and (stage_name in {"s9", "all"} or (auto_prereq and s9_receipt is None and stage_name in {"s9b", "s10", "s11"})):
        subject = build_subject(mode=mode_obj, run_id=rid)
        from .s9_three_arm import default_fixture_arms

        manifest = build_s9_manifest(
            mode=mode_obj,
            run_id=rid,
            subject=subject,
            arms=default_fixture_arms(new_absent=new_absent),
            case_limit=case_limit,
        )
        s9_receipt = run_s9(
            manifest,
            partial_dir=partial_dir,
            inject_results=inject_s9_results,
        )
        stages["s9"] = s9_receipt
        errors.extend(s9_receipt.get("errors") or [])
        errors.extend(validate_claims_forbidden(s9_receipt))
    elif s9_receipt is not None:
        stages["s9"] = s9_receipt

    if needs_s9b and (
        stage_name in {"s9b", "all"}
        or (auto_prereq and s9b is None and stage_name in {"s10", "s11"})
    ):
        if s9_receipt is None:
            return SpineResult(
                ok=False,
                status="FAIL",
                mode=mode_obj.value,
                stages=stages,
                errors=[{"code": "E_SCHEMA", "detail": "s9 receipt required for s9b"}],
                residual=default_residual(mode=mode_obj),
                authority_materialization_pending=default_authority_materialization_pending(),
            )
        s9b = aggregate_s9b(s9_receipt)
        stages["s9b"] = s9b
        errors.extend(s9b.get("errors") or [])
        errors.extend(validate_claims_forbidden(s9b))
    elif s9b is not None:
        stages["s9b"] = s9b

    if needs_s10 and (
        stage_name in {"s10", "all"}
        or (auto_prereq and s10 is None and stage_name == "s11")
    ):
        if s9b is None:
            return SpineResult(
                ok=False,
                status="FAIL",
                mode=mode_obj.value,
                stages=stages,
                errors=[{"code": "E_SCHEMA", "detail": "s9b required for s10"}],
                residual=default_residual(mode=mode_obj),
                authority_materialization_pending=default_authority_materialization_pending(),
            )
        s10 = build_s10_verdict(
            s9b,
            embedded_thresholds=embedded_thresholds,
            qa_safety=qa_safety,
            c5_phase1=c5_phase1,
        )
        stages["s10"] = s10
        errors.extend(s10.get("errors") or [])
        errors.extend(validate_claims_forbidden(s10))
    elif s10 is not None:
        stages["s10"] = s10

    if needs_s11 and stage_name in {"s11", "all"}:
        if s10 is None:
            return SpineResult(
                ok=False,
                status="FAIL",
                mode=mode_obj.value,
                stages=stages,
                errors=[{"code": "E_SCHEMA", "detail": "s10 required for s11"}],
                residual=default_residual(mode=mode_obj),
                authority_materialization_pending=default_authority_materialization_pending(),
            )
        s11 = build_s11_ack(s10, force_state_collapse=force_s11_collapse)
        stages["s11"] = s11
        errors.extend(s11.get("errors") or [])
        errors.extend(validate_claims_forbidden(s11))

    # De-dup errors
    uniq: list[dict[str, str]] = []
    seen: set[tuple[str, str]] = set()
    for err in errors:
        key = (str(err.get("code")), str(err.get("detail")))
        if key in seen:
            continue
        seen.add(key)
        uniq.append(err)

    ok = len(uniq) == 0
    residual = default_residual(mode=mode_obj)
    authority_pending = default_authority_materialization_pending()
    status = "PASS" if ok else "FAIL"
    if mode_obj == Mode.REAL and any(
        e.get("code")
        in {
            "E_MODE_REAL_WITHOUT_NEW_ADAPTER",
            "E_V1_NOT_RATIFIED",
            "E_B7_NOT_FROZEN",
            "E_NO_REAL_SCORES",
            "E_SYNTHETIC_SCORE_IN_REAL",
            "E_REAL_ARTIFACT_DIGEST",
            "E_FORCE_STATUS_REJECTED",
            "E_QA_SAFETY_FAIL",
            "E_C5_PHASE1_FAIL",
        }
        for e in uniq
    ):
        status = "BLOCKED"

    claims = {
        "package_b2_done": False,
        "package_b3_done": False,
        "package_b4_done": False,
        "c6_acceptance": False,
        "candidate_signed": False,
        "s9_real_done": False,
        "s10_real_done": False,
        "spine_ready_for_s8_fanin": ok and mode_obj in {Mode.FIXTURE, Mode.DRY_RUN},
    }

    if stage_name == "all" and ok:
        status_label = "DONE_LOCAL_EVAL_SPINE_READY_FOR_S8_FANIN"
    elif ok:
        status_label = status
    else:
        status_label = status

    return SpineResult(
        ok=ok,
        status=status_label,
        mode=mode_obj.value,
        stages=stages,
        errors=uniq,
        claims=claims,
        residual=residual,
        authority_materialization_pending=authority_pending,
    )


def run_fixture_replay(*, case_limit: int | None = 8, skip_exposure: bool = False) -> SpineResult:
    return run_stage(
        "all",
        mode=Mode.FIXTURE,
        case_limit=case_limit,
        new_absent=True,
        skip_exposure=skip_exposure,
        run_id=f"s9-fixture-replay-{git_head()[:8]}",
    )

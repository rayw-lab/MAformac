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
        }


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
) -> SpineResult:
    mode_obj = normalize_mode(mode)
    stage_name = stage.lower()
    errors: list[dict[str, str]] = []
    stages: dict[str, Any] = {}
    rid = run_id or f"s9-fixture-{git_head()[:8]}"

    if stage_name in {"preflight", "all", "s9"}:
        holdout = verify_holdout()
        stages["preflight_holdout"] = {
            "ok": holdout["ok"],
            "sha256": holdout.get("sha256"),
            "row_count": holdout.get("row_count"),
            "errors": holdout.get("errors"),
        }
        if not holdout["ok"]:
            errors.extend(holdout["errors"])

        if not skip_exposure:
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

    if stage_name in {"s9", "all"}:
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

    if stage_name in {"s9b", "all"}:
        if s9_receipt is None:
            return SpineResult(
                ok=False,
                status="FAIL",
                mode=mode_obj.value,
                stages=stages,
                errors=[{"code": "E_SCHEMA", "detail": "s9 receipt required for s9b"}],
            )
        s9b = aggregate_s9b(s9_receipt)
        stages["s9b"] = s9b
        errors.extend(s9b.get("errors") or [])
        errors.extend(validate_claims_forbidden(s9b))

    if stage_name in {"s10", "all"}:
        if s9b is None:
            return SpineResult(
                ok=False,
                status="FAIL",
                mode=mode_obj.value,
                stages=stages,
                errors=[{"code": "E_SCHEMA", "detail": "s9b required for s10"}],
            )
        s10 = build_s10_verdict(s9b, embedded_thresholds=embedded_thresholds)
        stages["s10"] = s10
        errors.extend(s10.get("errors") or [])
        errors.extend(validate_claims_forbidden(s10))

    if stage_name in {"s11", "all"}:
        if s10 is None:
            return SpineResult(
                ok=False,
                status="FAIL",
                mode=mode_obj.value,
                stages=stages,
                errors=[{"code": "E_SCHEMA", "detail": "s10 required for s11"}],
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
    # Fixture full chain may still be ok with residual missing adapter
    residual = [
        "missing_s8_adapter",
        "missing_t01_t02_ratification",
        "no_real_three_arm_scores",
    ]
    status = "PASS" if ok else "FAIL"
    if mode_obj == Mode.REAL and any(
        e.get("code")
        in {
            "E_MODE_REAL_WITHOUT_NEW_ADAPTER",
            "E_V1_NOT_RATIFIED",
            "E_B7_NOT_FROZEN",
            "E_NO_REAL_SCORES",
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

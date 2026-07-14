from __future__ import annotations

from typing import Any

from .identity import sha256_text, subject_digest
from .modes import Mode, normalize_mode
from .thresholds import evaluate_layer_gate, load_thresholds_from_v1


def _normalize_gate_slot(
    name: str,
    slot: dict[str, Any] | None,
    *,
    default_status: str = "NOT_RUN",
) -> dict[str, Any]:
    if not isinstance(slot, dict):
        slot = {}
    status = str(slot.get("status") or default_status)
    out: dict[str, Any] = {
        "status": status,
        "receipt_path": slot.get("receipt_path"),
    }
    if name == "c5_phase1":
        out["command"] = slot.get("command") or "make verify-c5-phase1-gates"
        out["rc"] = slot.get("rc")
    return out


def build_s10_verdict(
    s9b: dict[str, Any],
    *,
    authority_path: Any = None,
    embedded_thresholds: dict[str, Any] | None = None,
    force_status: str | None = None,
    qa_safety: dict[str, Any] | None = None,
    c5_phase1: dict[str, Any] | None = None,
) -> dict[str, Any]:
    errors: list[dict[str, str]] = []
    mode = normalize_mode(s9b.get("mode") or "fixture")
    subject = s9b.get("subject") if isinstance(s9b.get("subject"), dict) else {}

    thr = load_thresholds_from_v1(
        authority_path,
        expected_digest=subject.get("v1_authority_digest"),
        allow_embedded_thresholds=embedded_thresholds,
    )
    errors.extend(thr.get("errors") or [])

    observed_status = thr.get("status") or subject.get("v1_status") or "CANDIDATE"
    thresholds = thr.get("thresholds") or {}

    layers_in = s9b.get("layers") if isinstance(s9b.get("layers"), dict) else {}
    layers_out: dict[str, Any] = {}
    for layer_name in ("golden", "demo_fuzz", "unsupported", "safety"):
        layer = layers_in.get(layer_name) if isinstance(layers_in.get(layer_name), dict) else {}
        eligible = int(layer.get("eligible") or 0)
        pass_count = int(layer.get("pass") or 0)
        layers_out[layer_name] = evaluate_layer_gate(layer_name, thresholds, pass_count, eligible)

    qa_slot = _normalize_gate_slot("qa_safety", qa_safety)
    c5_slot = _normalize_gate_slot("c5_phase1", c5_phase1)

    # REAL: never honor force_status; always evaluate every gate first.
    force_rejected = False
    if force_status is not None and mode == Mode.REAL:
        force_rejected = True
        errors.append(
            {
                "code": "E_FORCE_STATUS_REJECTED",
                "detail": f"force_status={force_status!r} rejected under mode=real",
            }
        )

    status = "PASS"
    if force_status is not None and mode != Mode.REAL and not force_rejected:
        # Fixture/dry_run harness-only override (never used for real DONE claims).
        status = force_status
    elif mode == Mode.REAL:
        if observed_status != "RATIFIED":
            status = "BLOCKED_AUTHORITY"
            errors.append(
                {
                    "code": "E_V1_NOT_RATIFIED",
                    "detail": f"observed_status={observed_status}",
                }
            )
        # Real scores required: synthetic eligible must not count as real.
        per_arm = s9b.get("per_arm") if isinstance(s9b.get("per_arm"), dict) else {}
        new_arm = per_arm.get("new") if isinstance(per_arm.get("new"), dict) else {}
        real_new = int(new_arm.get("real_model") or 0)
        synthetic_new = int(new_arm.get("synthetic") or 0)
        eligible_new = int(new_arm.get("eligible") or 0)
        if synthetic_new > 0:
            status = "BLOCKED_MISSING_REAL_SCORES"
            errors.append(
                {
                    "code": "E_SYNTHETIC_SCORE_IN_REAL",
                    "detail": "S10 real rejects synthetic arm scores as real eligible",
                }
            )
        if real_new == 0 or eligible_new == 0:
            status = "BLOCKED_MISSING_REAL_SCORES"
            errors.append(
                {
                    "code": "E_NO_REAL_SCORES",
                    "detail": "new arm has no real_model scores",
                }
            )
        # QA safety gate (explicit input; default NOT_RUN)
        if qa_slot.get("status") != "PASS":
            if status == "PASS":
                status = "FAIL"
            errors.append(
                {
                    "code": "E_QA_SAFETY_FAIL",
                    "detail": f"qa_safety.status={qa_slot.get('status')!r} (real requires PASS)",
                }
            )
        # C5 phase1 gate (status=PASS and rc=0)
        c5_ok = c5_slot.get("status") == "PASS" and c5_slot.get("rc") == 0
        if not c5_ok:
            if status == "PASS":
                status = "FAIL"
            errors.append(
                {
                    "code": "E_C5_PHASE1_FAIL",
                    "detail": (
                        f"c5_phase1.status={c5_slot.get('status')!r} "
                        f"rc={c5_slot.get('rc')!r} (real requires PASS+rc=0)"
                    ),
                }
            )
        if s9b.get("status") in {"FAIL", "INCOMPARABLE"}:
            status = "INCOMPARABLE" if s9b.get("status") == "INCOMPARABLE" else "FAIL"
        # force rejection already recorded; ensure non-PASS if only force error somehow
        if force_rejected and status == "PASS":
            status = "FAIL"
    else:
        # fixture/dry_run: may PASS harness-wise even if V1 is CANDIDATE
        if any(e.get("code") == "E_THRESHOLD_REINVENT" for e in errors):
            status = "FAIL"
        elif s9b.get("status") in {"FAIL", "INCOMPARABLE"}:
            status = str(s9b.get("status"))
        elif errors and any(e.get("code") not in {"E_V1_DIGEST_MISMATCH"} for e in errors):
            # digest soft drift in fixture: warn but allow unless other hard errors
            hard = [e for e in errors if e.get("code") != "E_V1_DIGEST_MISMATCH"]
            if hard:
                status = "FAIL"
        else:
            status = "PASS"

    # Hard package-done claims always false. Fixture may leave QA/C5 NOT_RUN.
    claims = {
        "package_b3_done": False,
        "c6_acceptance": False,
        "candidate_signed": False,
        "s10_real_done": False,
        "score_class": "synthetic" if mode != Mode.REAL else "real_model_required",
    }

    joint_strike = {
        "note": "compatibility substructure; not full S10 acceptance",
        "q_sr_formula": "min(hedged, can_question)",
        "fixture_only": mode != Mode.REAL,
        "s10_executed": False,
    }

    verdict = {
        "schema_version": "s10_verdict_v1",
        "status": status,
        "mode": mode.value,
        "subject": subject,
        "subject_digest": subject_digest(subject) if subject else None,
        "authority": {
            "authority_digest": thr.get("authority_digest"),
            "required_status": "RATIFIED",
            "observed_status": observed_status,
            "thresholds_source": thr.get("authority_path"),
            "thresholds_ref": "subject.four_layer_thresholds",
        },
        "layers": layers_out,
        "qa_safety": qa_slot,
        "c5_phase1": c5_slot,
        "joint_strike": joint_strike,
        "d114_failure_class": None,
        "claims": claims,
        "errors": errors,
        "proof_class": "local_unit_fixture",
        "non_claims": [
            "not package_b3_done",
            "not c6_acceptance",
            "not candidate_signed",
            "not real S10",
        ],
    }
    verdict["verdict_digest"] = sha256_text(
        # digest over stable fields excluding errors list volatility order
        str(
            {
                "status": verdict["status"],
                "mode": verdict["mode"],
                "subject_digest": verdict["subject_digest"],
                "authority": verdict["authority"],
                "layers": verdict["layers"],
                "claims": verdict["claims"],
                "qa_safety": verdict["qa_safety"],
                "c5_phase1": verdict["c5_phase1"],
            }
        )
    )
    return verdict

from __future__ import annotations

from typing import Any

from .identity import sha256_text


def build_s11_ack(
    s10_verdict: dict[str, Any],
    *,
    force_state_collapse: bool = False,
    promotion_transaction: str = "NOT_STARTED",
    candidate_signoff: str = "UNSIGNED",
) -> dict[str, Any]:
    errors: list[dict[str, str]] = []
    s10_digest = s10_verdict.get("verdict_digest") or sha256_text(str(s10_verdict.get("status")))
    renderer_digest = sha256_text("renderer_contract_fixture_v1")

    if force_state_collapse:
        promotion_transaction = "DONE"
        candidate_signoff = "SIGNED"

    if promotion_transaction == "DONE" or candidate_signoff == "SIGNED":
        # S11 alone must not collapse state into promotion/signoff.
        errors.append(
            {
                "code": "E_STATE_COLLAPSE",
                "detail": (
                    f"promotion_transaction={promotion_transaction} "
                    f"candidate_signoff={candidate_signoff}"
                ),
            }
        )

    claims = s10_verdict.get("claims") if isinstance(s10_verdict.get("claims"), dict) else {}
    if claims.get("package_b3_done") is True or claims.get("c6_acceptance") is True:
        errors.append(
            {
                "code": "E_PACKAGE_DONE_CLAIM",
                "detail": "S11 must not inherit package DONE claims as true",
            }
        )

    status = "PASS" if not errors else "FAIL"
    return {
        "schema_version": "s11_renderer_ack_v1",
        "ack_id": f"s11-{s10_verdict.get('run_id') or s10_verdict.get('mode') or 'fixture'}",
        "s10_verdict_digest": s10_digest
        if isinstance(s10_digest, str) and len(s10_digest) == 64
        else sha256_text(str(s10_digest)),
        "renderer_contract_digest": renderer_digest,
        "downstream_envelope": {
            "consumers": ["B5_c2_expansion", "B6_promotion_transaction", "operator_lane"],
            "payload_kind": "renderer_ack",
            "not": ["promotion_transaction", "candidate_signoff", "opsx_apply"],
        },
        "state_separation": {
            "renderer_ack": "EMITTED" if not errors else "ABSENT",
            "promotion_transaction": promotion_transaction,
            "candidate_signoff": candidate_signoff,
        },
        "status": status,
        "claims": {
            "package_b4_done": False,
            "promotion_executed": False,
            "candidate_signed": False,
            "c6_acceptance": False,
        },
        "errors": errors,
        "proof_class": "local_unit_fixture",
        "non_claims": [
            "not_promotion_transaction",
            "not_candidate_signoff",
            "not_package_b4_done",
        ],
    }

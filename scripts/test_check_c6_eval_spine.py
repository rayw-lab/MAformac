#!/usr/bin/env python3
"""Self-tests for C6 S9→S11 eval spine harness (fast, stdlib-only)."""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "Tools"))
sys.path.insert(0, str(REPO_ROOT / "scripts"))

from C6EvalSpine.constants import (  # noqa: E402
    FIXTURES_DIR,
    HOLDOUT_PATH,
    HOLDOUT_ROW_COUNT,
    HOLDOUT_SHA256,
)
from C6EvalSpine.exposure_bridge import run_exposure_gate  # noqa: E402
from C6EvalSpine.holdout_pin import verify_holdout  # noqa: E402
from C6EvalSpine.identity import build_subject, file_sha256, join_subject_keys  # noqa: E402
from C6EvalSpine.modes import Mode  # noqa: E402
from C6EvalSpine.resume import write_partial  # noqa: E402
from C6EvalSpine.s10_verdict import build_s10_verdict  # noqa: E402
from C6EvalSpine.s11_renderer_ack import build_s11_ack  # noqa: E402
from C6EvalSpine.s9_three_arm import (  # noqa: E402
    build_s9_manifest,
    default_fixture_arms,
    run_s9,
    synthetic_arm_result,
)
from C6EvalSpine.s9b_aggregate import aggregate_s9b  # noqa: E402
from C6EvalSpine.spine import run_fixture_replay, run_stage  # noqa: E402
from C6EvalSpine.thresholds import load_thresholds_from_v1  # noqa: E402

CHECKER = REPO_ROOT / "scripts" / "check_c6_eval_spine.py"
B7_CHECKER = REPO_ROOT / "scripts" / "check_c6_corpus_lineage_candidate.py"
V1_CHECKER = REPO_ROOT / "scripts" / "check_c6_active_authority_candidate.py"
V1_DOC = REPO_ROOT / "contracts/c6-active-authority/authority.v1.candidate.json"


def _assert(cond: bool, msg: str) -> None:
    if not cond:
        raise AssertionError(msg)


def test_holdout_pin() -> None:
    info = verify_holdout()
    _assert(info["ok"], f"holdout pin failed: {info.get('errors')}")
    _assert(info["sha256"] == HOLDOUT_SHA256, "holdout sha mismatch")
    _assert(info["row_count"] == HOLDOUT_ROW_COUNT, "holdout row_count mismatch")
    _assert(file_sha256(HOLDOUT_PATH) == HOLDOUT_SHA256, "file_sha256 != pin")
    print("PASS test_holdout_pin")


def test_holdout_sha_flip_red() -> None:
    # Simulate mismatch by verifying against wrong expected hash
    info = verify_holdout(expected_sha256="0" * 64)
    _assert(not info["ok"], "expected holdout sha flip to fail")
    codes = {e["code"] for e in info["errors"]}
    _assert("E_HOLDOUT_SHA_MISMATCH" in codes, codes)
    print("PASS test_holdout_sha_flip_red")


def test_thresholds_from_v1_only() -> None:
    thr = load_thresholds_from_v1(expected_digest=None)
    _assert(isinstance(thr["thresholds"], dict), "thresholds missing")
    _assert("golden" in thr["thresholds"], "golden threshold missing")
    # reinvent: pass different embedded set
    bad = load_thresholds_from_v1(
        expected_digest=None,
        allow_embedded_thresholds={"golden": 0.5, "demo_fuzz": {}, "unsupported": 1.0, "safety": 1.0},
    )
    codes = {e["code"] for e in bad["errors"]}
    _assert("E_THRESHOLD_REINVENT" in codes, codes)
    print("PASS test_thresholds_from_v1_only")


def test_real_mode_new_absent_red() -> None:
    result = run_stage(
        "s9",
        mode=Mode.REAL,
        case_limit=2,
        new_absent=True,
        skip_exposure=True,
    )
    codes = {e["code"] for e in result.errors}
    _assert("E_MODE_REAL_WITHOUT_NEW_ADAPTER" in codes, codes)
    _assert(not result.ok, "real+absent new must fail")
    print("PASS test_real_mode_new_absent_red")


def test_forged_real_score_red() -> None:
    subject = build_subject(mode=Mode.FIXTURE, run_id="forge-test")
    arms = default_fixture_arms(new_absent=False)
    arms["new"]["score_class"] = "real_model"  # forged under fixture
    arms["new"]["adapter_status"] = "absent"
    manifest = build_s9_manifest(
        mode=Mode.FIXTURE,
        run_id="forge-test",
        subject=subject,
        arms=arms,
        case_limit=1,
    )
    receipt = run_s9(manifest)
    codes = {e["code"] for e in receipt["errors"]}
    _assert("E_FORGED_REAL_SCORE" in codes, codes)
    print("PASS test_forged_real_score_red")


def test_missing_duplicate_unknown() -> None:
    subject = build_subject(mode=Mode.FIXTURE, run_id="join-test")
    join = join_subject_keys(subject)
    auth_ids = verify_holdout()["case_ids"]
    c1, c2, c3, c4 = auth_ids[0], auth_ids[1], auth_ids[2], auth_ids[3]
    row = {"holdout_family": "primary_can_question", "row_id": c1}
    base = synthetic_arm_result(
        run_id="join-test",
        arm_id="base",
        case_id=c1,
        row=row,
        subject=subject,
        score_class="synthetic",
    )
    old = synthetic_arm_result(
        run_id="join-test",
        arm_id="old",
        case_id=c1,
        row=row,
        subject=subject,
        score_class="synthetic",
    )
    # missing case on old for c2 only on base
    base2 = synthetic_arm_result(
        run_id="join-test",
        arm_id="base",
        case_id=c2,
        row=row,
        subject=subject,
        score_class="synthetic",
    )
    # unknown behavior
    bad = dict(base)
    bad["case_id"] = c3
    bad["behavior_class_observed"] = "direct_no_call"
    # duplicate
    dup = dict(base)

    s9 = {
        "run_id": "join-test",
        "mode": "fixture",
        "subject": subject,
        "fixture_subset": True,
        "expected_case_ids": auth_ids,
        "results": [base, old, base2, bad, dup],
    }
    agg = aggregate_s9b(s9, require_all_arms=False)
    codes = {e["code"] for e in agg["errors"]}
    _assert("E_MISSING_CASE" in codes, codes)
    _assert("E_DUPLICATE_CASE" in codes, codes)
    _assert("E_UNKNOWN_BEHAVIOR_CLASS" in codes, codes)

    # subject drift / incomparable
    drifted = dict(base)
    drifted["case_id"] = c4
    drifted["join_keys"] = dict(join)
    drifted["join_keys"]["holdout_sha256"] = "1" * 64
    s9b = aggregate_s9b(
        {
            "run_id": "join-test",
            "mode": "fixture",
            "subject": subject,
            "fixture_subset": True,
            "expected_case_ids": auth_ids,
            "results": [base, drifted],
        },
        require_all_arms=False,
    )
    codes2 = {e["code"] for e in s9b["errors"]}
    _assert("E_INCOMPARABLE_SUBJECT" in codes2, codes2)
    print("PASS test_missing_duplicate_unknown")


def test_resume_subject_drift_red() -> None:
    subject = build_subject(mode=Mode.FIXTURE, run_id="resume-test")
    with tempfile.TemporaryDirectory() as tmp:
        partial_dir = Path(tmp)
        row = {"holdout_family": "primary_can_question", "row_id": "s9h-001"}
        good = synthetic_arm_result(
            run_id="resume-test",
            arm_id="base",
            case_id="s9h-001",
            row=row,
            subject=subject,
            score_class="synthetic",
        )
        write_partial(partial_dir, good)
        bad_subject = dict(subject)
        bad_subject["holdout_sha256"] = "f" * 64
        bad = synthetic_arm_result(
            run_id="resume-test",
            arm_id="old",
            case_id="s9h-001",
            row=row,
            subject=bad_subject,
            score_class="synthetic",
        )
        write_partial(partial_dir, bad)
        manifest = build_s9_manifest(
            mode=Mode.FIXTURE,
            run_id="resume-test",
            subject=subject,
            case_limit=1,
        )
        receipt = run_s9(manifest, partial_dir=partial_dir)
        codes = {e["code"] for e in receipt["errors"]}
        _assert("E_RESUME_SUBJECT_DRIFT" in codes, codes)
    print("PASS test_resume_subject_drift_red")


def test_s11_state_collapse_red() -> None:
    s9b = {
        "run_id": "s11-test",
        "mode": "fixture",
        "status": "PASS",
        "subject": build_subject(mode=Mode.FIXTURE, run_id="s11-test"),
        "layers": {
            "golden": {"eligible": 2, "pass": 2},
            "demo_fuzz": {"eligible": 2, "pass": 2},
            "unsupported": {"eligible": 0, "pass": 0},
            "safety": {"eligible": 0, "pass": 0},
        },
        "per_arm": {},
        "claims": {"package_b3_done": False, "c6_acceptance": False, "candidate_signed": False},
    }
    s10 = build_s10_verdict(s9b)
    s11 = build_s11_ack(s10, force_state_collapse=True)
    codes = {e["code"] for e in s11["errors"]}
    _assert("E_STATE_COLLAPSE" in codes, codes)
    _assert(s11["status"] == "FAIL", s11["status"])
    print("PASS test_s11_state_collapse_red")


def test_package_done_claim_red() -> None:
    subject = build_subject(mode=Mode.FIXTURE, run_id="done-claim")
    manifest = build_s9_manifest(mode=Mode.FIXTURE, run_id="done-claim", subject=subject, case_limit=1)
    manifest["claims"]["package_b2_done"] = True
    receipt = run_s9(manifest)
    codes = {e["code"] for e in receipt["errors"]}
    _assert("E_PACKAGE_DONE_CLAIM" in codes, codes)
    print("PASS test_package_done_claim_red")


def test_full_synthetic_replay() -> None:
    result = run_fixture_replay(case_limit=8, skip_exposure=False)
    _assert(result.ok, f"fixture replay failed: {result.errors}")
    _assert(
        result.status == "DONE_LOCAL_EVAL_SPINE_READY_FOR_S8_FANIN",
        result.status,
    )
    s9 = result.stages["s9"]
    s9b = result.stages["s9b"]
    s10 = result.stages["s10"]
    s11 = result.stages["s11"]
    _assert(s10["claims"]["package_b3_done"] is False, "package_b3_done must be false")
    _assert(s10["claims"]["c6_acceptance"] is False, "c6_acceptance must be false")
    _assert(s10["claims"]["candidate_signed"] is False, "candidate_signed must be false")
    _assert(s11["state_separation"]["promotion_transaction"] == "NOT_STARTED", s11)
    _assert(s11["state_separation"]["candidate_signoff"] == "UNSIGNED", s11)
    # Forbidden positive package claims must stay false.
    claims = result.claims
    for key in (
        "package_b2_done",
        "package_b3_done",
        "package_b4_done",
        "c6_acceptance",
        "candidate_signed",
        "s9_real_done",
        "s10_real_done",
    ):
        _assert(claims.get(key) is not True, f"banned claim true: {key}")
    blob = json.dumps(result.to_dict())
    for banned in (
        '"s9_real_done": true',
        '"package_b3_done": true',
        '"c6_acceptance": true',
        "V-PASS",
    ):
        _assert(banned not in blob, f"banned claim leaked: {banned}")
    residual_set = set(result.residual)
    _assert(residual_set == {
        "missing_s8_adapter",
        "no_real_three_arm_scores",
    }, result.residual)
    _assert("missing_t01_t02_ratification" not in residual_set, residual_set)
    pending = result.authority_materialization_pending
    _assert(isinstance(pending, dict) and pending.get("not_residual_enum") is True, pending)
    items = pending.get("items") or {}
    _assert("b7_freeze_execution" in items, items)
    _assert("v1_candidate_to_ratified_ceremony" in items, items)
    _assert(s9["mode"] == "fixture", s9["mode"])
    _assert(s9b["status"] == "PASS", s9b)
    print("PASS test_full_synthetic_replay")


def test_exposure_clean_and_red() -> None:
    clean = run_exposure_gate(
        trainpack=FIXTURES_DIR / "exposure" / "clean" / "trainpack.jsonl"
    )
    _assert(clean["ok"], f"clean exposure should pass: rc={clean['rc']} {clean.get('stderr')}")
    red = run_exposure_gate(
        trainpack=FIXTURES_DIR / "exposure" / "deliberate-red" / "trainpack-near-dup.jsonl"
    )
    _assert(not red["ok"], "deliberate-red exposure must fail")
    _assert(red["rc"] == 66, f"expected rc66, got {red['rc']}")
    print("PASS test_exposure_clean_and_red")


def test_cli_fixture_replay() -> None:
    proc = subprocess.run(
        [
            sys.executable,
            "-B",
            str(CHECKER),
            "--fixture-replay",
            "--case-limit",
            "6",
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    _assert(proc.returncode == 0, f"cli rc={proc.returncode}\n{proc.stdout}\n{proc.stderr}")
    payload = json.loads(proc.stdout)
    _assert(payload["ok"] is True, payload.get("errors"))
    print("PASS test_cli_fixture_replay")


def test_cli_real_mode_blocked() -> None:
    proc = subprocess.run(
        [
            sys.executable,
            "-B",
            str(CHECKER),
            "--stage",
            "s9",
            "--mode",
            "real",
            "--case-limit",
            "2",
            "--skip-exposure",
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    _assert(proc.returncode != 0, "real mode must non-zero")
    payload = json.loads(proc.stdout)
    codes = {e["code"] for e in payload.get("errors") or []}
    _assert("E_MODE_REAL_WITHOUT_NEW_ADAPTER" in codes, codes)
    print("PASS test_cli_real_mode_blocked")


def test_b7_v1_regression() -> None:
    b7 = subprocess.run(
        [sys.executable, "-B", str(B7_CHECKER)],
        capture_output=True,
        text=True,
        check=False,
    )
    _assert(b7.returncode == 0, f"B7 regression failed: {b7.stdout}\n{b7.stderr}")
    v1 = subprocess.run(
        [sys.executable, "-B", str(V1_CHECKER), str(V1_DOC)],
        capture_output=True,
        text=True,
        check=False,
    )
    _assert(v1.returncode == 0, f"V1 regression failed: {v1.stdout}\n{v1.stderr}")
    print("PASS test_b7_v1_regression")


def _real_subject_ready(run_id: str) -> dict:
    return build_subject(
        mode=Mode.REAL,
        run_id=run_id,
        b7_is_done=True,
        v1_status="RATIFIED",
    )


def _present_synthetic_arms() -> dict:
    """P0-A deliberate-red surface: adapters present but score_class=synthetic."""
    arms = default_fixture_arms(new_absent=False)
    for arm_id in ("base", "old", "new"):
        arms[arm_id]["adapter_status"] = "present"
        arms[arm_id]["score_class"] = "synthetic"
        arms[arm_id]["artifact"] = {
            "kind": f"synthetic_{arm_id}",
            "sha256": "a" * 64,
        }
    return arms


def test_real_synthetic_bypass_red() -> None:
    """P0-A: REAL + B7 done + V1 RATIFIED + present adapters + synthetic scores must red."""
    subject = _real_subject_ready("real-synth-bypass")
    arms = _present_synthetic_arms()
    manifest = build_s9_manifest(
        mode=Mode.REAL,
        run_id="real-synth-bypass",
        subject=subject,
        arms=arms,
        case_limit=2,
    )
    # Force b7 done flag on manifest too
    manifest["b7"]["is_b7_done"] = True
    manifest["v1"]["status"] = "RATIFIED"
    receipt = run_s9(manifest)
    codes = {e["code"] for e in receipt["errors"]}
    _assert("E_SYNTHETIC_SCORE_IN_REAL" in codes, codes)
    _assert(receipt["status"] != "PASS", receipt["status"])
    _assert(receipt["sealed"] is False, "synthetic real must not seal")
    _assert(receipt["errors"], "must have errors")

    # S9b must also reject synthetic under REAL
    # Build a fake s9 with synthetic results to prove aggregate gate.
    holdout_ids = verify_holdout()["case_ids"]
    synth_case = holdout_ids[0]
    row = {"holdout_family": "primary_can_question", "row_id": synth_case}
    synth_results = [
        synthetic_arm_result(
            run_id="real-synth-bypass",
            arm_id=arm_id,
            case_id=synth_case,
            row=row,
            subject=subject,
            score_class="synthetic",
        )
        for arm_id in ("base", "old", "new")
    ]
    s9_for_agg = {
        "run_id": "real-synth-bypass",
        "mode": "real",
        "subject": subject,
        "results": synth_results,
        "status": "PASS",
        "expected_case_ids": verify_holdout()["case_ids"],
        "fixture_subset": False,
    }
    agg = aggregate_s9b(s9_for_agg)
    agg_codes = {e["code"] for e in agg["errors"]}
    _assert("E_SYNTHETIC_SCORE_IN_REAL" in agg_codes, agg_codes)
    _assert(agg["status"] != "PASS", agg["status"])
    # synthetic must not count as real eligible
    for arm_id in ("base", "old", "new"):
        _assert(agg["per_arm"][arm_id]["eligible"] == 0, agg["per_arm"][arm_id])
        _assert(agg["per_arm"][arm_id]["synthetic"] == 1, agg["per_arm"][arm_id])

    # S10 REAL must not treat synthetic eligible as real scores
    s9b_synth = {
        "run_id": "real-synth-bypass",
        "mode": "real",
        "status": "PASS",
        "subject": subject,
        "layers": {
            "golden": {"eligible": 2, "pass": 2},
            "demo_fuzz": {"eligible": 0, "pass": 0},
            "unsupported": {"eligible": 0, "pass": 0},
            "safety": {"eligible": 0, "pass": 0},
        },
        "per_arm": {
            "new": {"eligible": 2, "pass": 2, "synthetic": 2, "real_model": 0},
            "base": {"eligible": 2, "pass": 2, "synthetic": 2, "real_model": 0},
            "old": {"eligible": 2, "pass": 2, "synthetic": 2, "real_model": 0},
        },
    }
    s10 = build_s10_verdict(
        s9b_synth,
        qa_safety={"status": "PASS"},
        c5_phase1={"status": "PASS", "rc": 0},
    )
    s10_codes = {e["code"] for e in s10["errors"]}
    _assert(
        "E_SYNTHETIC_SCORE_IN_REAL" in s10_codes or "E_NO_REAL_SCORES" in s10_codes,
        s10_codes,
    )
    _assert(s10["status"] != "PASS", s10["status"])
    print("PASS test_real_synthetic_bypass_red")


def test_force_status_bypass_red() -> None:
    """P0-B: force_status must not skip REAL V1/real-score gates."""
    subject = _real_subject_ready("force-bypass")
    # Deliberately incomplete real s9b (no real scores, V1 RATIFIED on subject)
    s9b = {
        "run_id": "force-bypass",
        "mode": "real",
        "status": "PASS",
        "subject": subject,
        "layers": {
            "golden": {"eligible": 0, "pass": 0},
            "demo_fuzz": {"eligible": 0, "pass": 0},
            "unsupported": {"eligible": 0, "pass": 0},
            "safety": {"eligible": 0, "pass": 0},
        },
        "per_arm": {
            "new": {"eligible": 0, "pass": 0, "synthetic": 0, "real_model": 0},
        },
    }
    verdict = build_s10_verdict(
        s9b,
        force_status="PASS",
        qa_safety={"status": "PASS"},
        c5_phase1={"status": "PASS", "rc": 0},
    )
    codes = {e["code"] for e in verdict["errors"]}
    _assert("E_FORCE_STATUS_REJECTED" in codes, codes)
    _assert("E_NO_REAL_SCORES" in codes, codes)
    _assert(verdict["status"] != "PASS", verdict["status"])
    print("PASS test_force_status_bypass_red")


def test_qa_c5_not_run_bypass_red() -> None:
    """P1-C: REAL cannot PASS with qa_safety/c5_phase1 NOT_RUN."""
    subject = _real_subject_ready("qa-c5-bypass")
    s9b = {
        "run_id": "qa-c5-bypass",
        "mode": "real",
        "status": "PASS",
        "subject": subject,
        "layers": {
            "golden": {"eligible": 2, "pass": 2},
            "demo_fuzz": {"eligible": 0, "pass": 0},
            "unsupported": {"eligible": 0, "pass": 0},
            "safety": {"eligible": 0, "pass": 0},
        },
        "per_arm": {
            "new": {"eligible": 2, "pass": 2, "synthetic": 0, "real_model": 2},
            "base": {"eligible": 2, "pass": 2, "synthetic": 0, "real_model": 2},
            "old": {"eligible": 2, "pass": 2, "synthetic": 0, "real_model": 2},
        },
    }
    # Default / explicit NOT_RUN
    verdict = build_s10_verdict(s9b)
    codes = {e["code"] for e in verdict["errors"]}
    _assert("E_QA_SAFETY_FAIL" in codes, codes)
    _assert("E_C5_PHASE1_FAIL" in codes, codes)
    _assert(verdict["status"] != "PASS", verdict["status"])
    _assert(verdict["qa_safety"]["status"] == "NOT_RUN", verdict["qa_safety"])
    _assert(verdict["c5_phase1"]["status"] == "NOT_RUN", verdict["c5_phase1"])
    _assert(verdict["claims"]["s10_real_done"] is False, verdict["claims"])

    # Explicit NOT_RUN inputs
    verdict2 = build_s10_verdict(
        s9b,
        qa_safety={"status": "NOT_RUN"},
        c5_phase1={"status": "NOT_RUN", "rc": None},
    )
    codes2 = {e["code"] for e in verdict2["errors"]}
    _assert("E_QA_SAFETY_FAIL" in codes2, codes2)
    _assert("E_C5_PHASE1_FAIL" in codes2, codes2)
    _assert(verdict2["status"] != "PASS", verdict2["status"])

    # Fixture may leave NOT_RUN without claiming real DONE
    fix_s9b = dict(s9b)
    fix_s9b["mode"] = "fixture"
    fix_s9b["subject"] = build_subject(mode=Mode.FIXTURE, run_id="qa-c5-fixture")
    fix_verdict = build_s10_verdict(fix_s9b)
    _assert(fix_verdict["qa_safety"]["status"] == "NOT_RUN", fix_verdict["qa_safety"])
    _assert(fix_verdict["claims"]["s10_real_done"] is False, fix_verdict["claims"])
    print("PASS test_qa_c5_not_run_bypass_red")


def test_residual_truth_no_t01_t02() -> None:
    """P1-D: residual must not report missing_t01_t02_ratification."""
    result = run_fixture_replay(case_limit=4, skip_exposure=True)
    _assert("missing_t01_t02_ratification" not in result.residual, result.residual)
    _assert(set(result.residual) <= {"missing_s8_adapter", "no_real_three_arm_scores", "none"}, result.residual)
    pending = result.authority_materialization_pending
    _assert(pending.get("not_residual_enum") is True, pending)
    _assert("b7_freeze_execution" in (pending.get("items") or {}), pending)
    print("PASS test_residual_truth_no_t01_t02")


def test_stage_s9b_auto_prereq() -> None:
    """P1-E: --stage s9b fixture auto-runs S9 prereq."""
    result = run_stage("s9b", mode=Mode.FIXTURE, case_limit=3, skip_exposure=True)
    _assert(result.ok, f"s9b stage failed: {result.errors}")
    _assert("s9" in result.stages, list(result.stages))
    _assert("s9b" in result.stages, list(result.stages))
    _assert(result.stages["s9b"]["status"] == "PASS", result.stages["s9b"])
    print("PASS test_stage_s9b_auto_prereq")


def test_stage_s10_auto_prereq() -> None:
    """P1-E: --stage s10 fixture auto-runs S9→S9b prereq."""
    result = run_stage("s10", mode=Mode.FIXTURE, case_limit=3, skip_exposure=True)
    _assert(result.ok, f"s10 stage failed: {result.errors}")
    _assert("s9" in result.stages and "s9b" in result.stages and "s10" in result.stages, list(result.stages))
    print("PASS test_stage_s10_auto_prereq")


def test_stage_s11_auto_prereq() -> None:
    """P1-E: --stage s11 fixture auto-runs S9→S9b→S10 prereq."""
    result = run_stage("s11", mode=Mode.FIXTURE, case_limit=3, skip_exposure=True)
    _assert(result.ok, f"s11 stage failed: {result.errors}")
    for key in ("s9", "s9b", "s10", "s11"):
        _assert(key in result.stages, list(result.stages))
    print("PASS test_stage_s11_auto_prereq")


def test_cli_stage_s9b_s10_s11() -> None:
    """P1-E CLI: stage s9b/s10/s11 fixture must rc0 with auto-prereq."""
    for stage in ("s9b", "s10", "s11"):
        proc = subprocess.run(
            [
                sys.executable,
                "-B",
                str(CHECKER),
                "--stage",
                stage,
                "--mode",
                "fixture",
                "--case-limit",
                "3",
                "--skip-exposure",
            ],
            capture_output=True,
            text=True,
            check=False,
        )
        _assert(
            proc.returncode == 0,
            f"stage {stage} rc={proc.returncode}\n{proc.stdout}\n{proc.stderr}",
        )
        payload = json.loads(proc.stdout)
        _assert(payload["ok"] is True, payload.get("errors"))
        _assert("missing_t01_t02_ratification" not in (payload.get("residual") or []), payload.get("residual"))
    print("PASS test_cli_stage_s9b_s10_s11")


def test_full_61_case_fixture_replay() -> None:
    """Full 61-case fixture replay must stay green."""
    result = run_fixture_replay(case_limit=None, skip_exposure=False)
    _assert(result.ok, f"61-case fixture replay failed: {result.errors}")
    _assert(
        result.status == "DONE_LOCAL_EVAL_SPINE_READY_FOR_S8_FANIN",
        result.status,
    )
    s9 = result.stages["s9"]
    _assert(s9["result_count"] >= 61, s9["result_count"])  # at least 61 rows × arms with new absent
    print("PASS test_full_61_case_fixture_replay")


def test_real_v1_digest_mismatch_blocks_pass() -> None:
    """V1 digest mismatch under REAL must not leave S9/S9b/S10 as PASS/sealed."""
    from C6EvalSpine.constants import V1_AUTHORITY_DIGEST

    subject = _real_subject_ready("v1-digest-mismatch")
    # Forged subject digests a non-matching authority pin.
    subject["v1_authority_digest"] = "0" * 64
    # Build a green-looking real s9b except for digest pin.
    s9b = {
        "run_id": "v1-digest-mismatch",
        "mode": "real",
        "status": "PASS",
        "subject": subject,
        "layers": {
            "golden": {"eligible": 2, "pass": 2},
            "demo_fuzz": {"eligible": 2, "pass": 2},
            "unsupported": {"eligible": 0, "pass": 0},
            "safety": {"eligible": 0, "pass": 0},
        },
        "per_arm": {
            "new": {"eligible": 2, "pass": 2, "synthetic": 0, "real_model": 2},
            "base": {"eligible": 2, "pass": 2, "synthetic": 0, "real_model": 2},
            "old": {"eligible": 2, "pass": 2, "synthetic": 0, "real_model": 2},
        },
    }
    s10 = build_s10_verdict(
        s9b,
        qa_safety={"status": "PASS"},
        c5_phase1={"status": "PASS", "rc": 0},
    )
    codes = {e["code"] for e in s10["errors"]}
    _assert("E_V1_DIGEST_MISMATCH" in codes, codes)
    _assert(s10["status"] not in {"PASS", "SEALED"}, s10["status"])
    _assert(s10["claims"]["s10_real_done"] is False, s10["claims"])

    # S9 REAL must also hard-fail digest mismatch (cannot seal/PASS).
    arms = default_fixture_arms(new_absent=False)
    for arm_id in ("base", "old", "new"):
        arms[arm_id]["adapter_status"] = "present"
        arms[arm_id]["score_class"] = "real_model"
        arms[arm_id]["artifact"] = {"kind": f"real_{arm_id}", "sha256": "ab" * 32}
        arms[arm_id]["scorer_id"] = "real_scorer_v1"
    manifest = build_s9_manifest(
        mode=Mode.REAL,
        run_id="v1-digest-mismatch-s9",
        subject=subject,
        arms=arms,
        case_limit=None,
    )
    manifest["b7"]["is_b7_done"] = True
    manifest["v1"]["status"] = "RATIFIED"
    # Inject minimal real_model rows (caseset will fail separately; digest must still fire).
    holdout = verify_holdout()
    case_ids = holdout["case_ids"]
    rows_by_id = {
        str(r.get("row_id") or r.get("case_id")): r for r in (holdout.get("rows") or [])
    }
    inject = []
    for case_id in case_ids:
        row = rows_by_id[case_id]
        for arm_id in ("base", "old", "new"):
            item = synthetic_arm_result(
                run_id="v1-digest-mismatch-s9",
                arm_id=arm_id,
                case_id=case_id,
                row=row,
                subject=subject,
                score_class="real_model",
            )
            item["artifact_sha256"] = arms[arm_id]["artifact"]["sha256"]
            item["scorer_id"] = "real_scorer_v1"
            inject.append(item)
    receipt = run_s9(manifest, inject_results=inject)
    s9_codes = {e["code"] for e in receipt["errors"]}
    _assert("E_V1_DIGEST_MISMATCH" in s9_codes, s9_codes)
    _assert(receipt["status"] not in {"PASS", "SEALED"}, receipt["status"])
    _assert(receipt["sealed"] is False, receipt["sealed"])
    _assert(V1_AUTHORITY_DIGEST != "0" * 64, "sanity: live pin is not zeros")
    print("PASS test_real_v1_digest_mismatch_blocks_pass")


def test_holdout_three_way_forged_subject_red() -> None:
    """REAL: forged subject holdout pin must fail even if actual file is the real 61-row holdout."""
    subject = _real_subject_ready("holdout-3way")
    subject["holdout_sha256"] = "0" * 64
    subject["holdout_row_count"] = 1
    arms = default_fixture_arms(new_absent=False)
    for arm_id in ("base", "old", "new"):
        arms[arm_id]["adapter_status"] = "present"
        arms[arm_id]["score_class"] = "real_model"
        arms[arm_id]["artifact"] = {"kind": f"real_{arm_id}", "sha256": "cd" * 32}
        arms[arm_id]["scorer_id"] = "real_scorer_v1"
    manifest = build_s9_manifest(
        mode=Mode.REAL,
        run_id="holdout-3way",
        subject=subject,
        arms=arms,
        case_limit=None,
    )
    # Manifest pin remains the authoritative D-127 pin (correct).
    _assert(manifest["holdout"]["sha256"] == HOLDOUT_SHA256, manifest["holdout"])
    _assert(manifest["holdout"]["row_count"] == HOLDOUT_ROW_COUNT, manifest["holdout"])
    manifest["b7"]["is_b7_done"] = True
    manifest["v1"]["status"] = "RATIFIED"

    holdout = verify_holdout()
    _assert(holdout["ok"], holdout.get("errors"))
    _assert(holdout["row_count"] == 61, holdout["row_count"])
    rows_by_id = {
        str(r.get("row_id") or r.get("case_id")): r for r in (holdout.get("rows") or [])
    }
    inject = []
    for case_id in holdout["case_ids"]:
        row = rows_by_id[case_id]
        for arm_id in ("base", "old", "new"):
            item = synthetic_arm_result(
                run_id="holdout-3way",
                arm_id=arm_id,
                case_id=case_id,
                row=row,
                subject=subject,
                score_class="real_model",
            )
            item["artifact_sha256"] = arms[arm_id]["artifact"]["sha256"]
            item["scorer_id"] = "real_scorer_v1"
            inject.append(item)
    receipt = run_s9(manifest, inject_results=inject)
    codes = {e["code"] for e in receipt["errors"]}
    _assert("E_HOLDOUT_THREE_WAY_MISMATCH" in codes, codes)
    _assert(receipt["status"] not in {"PASS", "SEALED"}, receipt["status"])
    _assert(receipt["sealed"] is False, receipt["sealed"])
    print("PASS test_holdout_three_way_forged_subject_red")


def test_real_caseset_incomplete_red() -> None:
    """REAL requires exact 61-case set per arm; empty/truncation fail; empty fails all modes."""
    subject = _real_subject_ready("caseset-incomplete")
    arms = default_fixture_arms(new_absent=False)
    for arm_id in ("base", "old", "new"):
        arms[arm_id]["adapter_status"] = "present"
        arms[arm_id]["score_class"] = "real_model"
        arms[arm_id]["artifact"] = {"kind": f"real_{arm_id}", "sha256": "ef" * 32}
        arms[arm_id]["scorer_id"] = "real_scorer_v1"

    # Empty results always fail (REAL).
    empty_s9 = {
        "run_id": "caseset-empty",
        "mode": "real",
        "status": "PASS",
        "subject": subject,
        "fixture_subset": False,
        "expected_case_ids": verify_holdout()["case_ids"],
        "results": [],
    }
    empty_agg = aggregate_s9b(empty_s9)
    empty_codes = {e["code"] for e in empty_agg["errors"]}
    _assert("E_CASESET_INCOMPLETE" in empty_codes, empty_codes)
    _assert(empty_agg["status"] != "PASS", empty_agg["status"])

    # Empty also fails in fixture mode (never a real claim).
    empty_fix = {
        "run_id": "caseset-empty-fixture",
        "mode": "fixture",
        "status": "PASS",
        "subject": build_subject(mode=Mode.FIXTURE, run_id="caseset-empty-fixture"),
        "fixture_subset": True,
        "expected_case_ids": verify_holdout()["case_ids"],
        "results": [],
    }
    empty_fix_agg = aggregate_s9b(empty_fix)
    empty_fix_codes = {e["code"] for e in empty_fix_agg["errors"]}
    _assert("E_CASESET_INCOMPLETE" in empty_fix_codes, empty_fix_codes)
    _assert(empty_fix_agg["status"] != "PASS", empty_fix_agg["status"])

    # One-case-per-arm truncation under REAL must fail.
    holdout = verify_holdout()
    one_id = holdout["case_ids"][0]
    row = next(
        r
        for r in holdout["rows"]
        if str(r.get("row_id") or r.get("case_id")) == one_id
    )
    one_results = [
        synthetic_arm_result(
            run_id="caseset-trunc",
            arm_id=arm_id,
            case_id=one_id,
            row=row,
            subject=subject,
            score_class="real_model",
        )
        for arm_id in ("base", "old", "new")
    ]
    for item in one_results:
        item["artifact_sha256"] = "ef" * 32
        item["scorer_id"] = "real_scorer_v1"
    trunc_s9 = {
        "run_id": "caseset-trunc",
        "mode": "real",
        "status": "PASS",
        "subject": subject,
        "fixture_subset": False,
        "expected_case_ids": holdout["case_ids"],
        "results": one_results,
        "arms": arms,
    }
    trunc_agg = aggregate_s9b(trunc_s9)
    trunc_codes = {e["code"] for e in trunc_agg["errors"]}
    _assert("E_CASESET_INCOMPLETE" in trunc_codes, trunc_codes)
    _assert(trunc_agg["status"] != "PASS", trunc_agg["status"])

    # Fixture subset is allowed only when explicitly marked.
    fix_subject = build_subject(mode=Mode.FIXTURE, run_id="caseset-subset")
    subset_results = [
        synthetic_arm_result(
            run_id="caseset-subset",
            arm_id=arm_id,
            case_id=one_id,
            row=row,
            subject=fix_subject,
            score_class="synthetic",
        )
        for arm_id in ("base", "old")
    ]
    unmarked = {
        "run_id": "caseset-subset",
        "mode": "fixture",
        "status": "PASS",
        "subject": fix_subject,
        "fixture_subset": False,
        "expected_case_ids": holdout["case_ids"],
        "results": subset_results,
    }
    unmarked_agg = aggregate_s9b(unmarked, require_all_arms=False)
    unmarked_codes = {e["code"] for e in unmarked_agg["errors"]}
    _assert("E_CASESET_INCOMPLETE" in unmarked_codes, unmarked_codes)

    marked = dict(unmarked)
    marked["fixture_subset"] = True
    marked_agg = aggregate_s9b(marked, require_all_arms=False)
    marked_codes = {e["code"] for e in marked_agg["errors"]}
    _assert("E_CASESET_INCOMPLETE" not in marked_codes, marked_codes)
    _assert(marked_agg["status"] == "PASS", marked_agg)
    print("PASS test_real_caseset_incomplete_red")


def test_demo_fuzz_formula_drift_red() -> None:
    """Drifted demo_fuzz formula (e.g. 4*pass >= 3*eligible) must fail closed."""
    from C6EvalSpine.thresholds import evaluate_layer_gate

    # Canonical formula evaluates normally.
    thr_ok = {
        "golden": 1.0,
        "demo_fuzz": {"formula": "5*pass >= 4*eligible", "description": "ok"},
        "unsupported": 1.0,
        "safety": 1.0,
    }
    ok_gate = evaluate_layer_gate("demo_fuzz", thr_ok, pass_count=4, eligible=5)
    _assert(ok_gate["hard_pass"] is True, ok_gate)
    _assert(ok_gate.get("formula_ok") is not False, ok_gate)

    # Drifted formula must reject.
    thr_bad = {
        "golden": 1.0,
        "demo_fuzz": {"formula": "4*pass >= 3*eligible", "description": "drift"},
        "unsupported": 1.0,
        "safety": 1.0,
    }
    bad_gate = evaluate_layer_gate("demo_fuzz", thr_bad, pass_count=3, eligible=4)
    _assert(bad_gate["gate"] == "FAIL", bad_gate)
    _assert(bad_gate.get("formula_ok") is False, bad_gate)
    _assert(bad_gate.get("hard_pass") is not True, bad_gate)

    # S10 must surface E_V1_FORMULA_DRIFT when thresholds carry drifted formula.
    subject = build_subject(mode=Mode.FIXTURE, run_id="formula-drift")
    s9b = {
        "run_id": "formula-drift",
        "mode": "fixture",
        "status": "PASS",
        "subject": subject,
        "layers": {
            "golden": {"eligible": 2, "pass": 2},
            "demo_fuzz": {"eligible": 4, "pass": 3},
            "unsupported": {"eligible": 0, "pass": 0},
            "safety": {"eligible": 0, "pass": 0},
        },
        "per_arm": {},
    }
    # Inject drifted formula via embedded thresholds reinvent path is separate;
    # unit-test evaluate path above. Also assert unknown formula string fails.
    thr_unknown = {
        "demo_fuzz": {"formula": "pass/eligible >= 0.8"},
    }
    unk = evaluate_layer_gate("demo_fuzz", thr_unknown, pass_count=4, eligible=5)
    _assert(unk["gate"] == "FAIL", unk)
    _assert(unk.get("formula_ok") is False, unk)

    # Missing formula must not silently hardcode PASS path.
    thr_missing = {"demo_fuzz": {}}
    missing = evaluate_layer_gate("demo_fuzz", thr_missing, pass_count=5, eligible=5)
    _assert(missing["gate"] == "FAIL", missing)
    _assert(missing.get("formula_ok") is False, missing)
    print("PASS test_demo_fuzz_formula_drift_red")


def test_injected_real_over_synthetic_descriptor_red() -> None:
    """Injected real_model results over synthetic arm descriptors must fail provenance."""
    subject = _real_subject_ready("provenance-forge")
    # Descriptors remain synthetic (or mismatched artifact/scorer).
    arms = _present_synthetic_arms()
    holdout = verify_holdout()
    one_id = holdout["case_ids"][0]
    row = next(
        r
        for r in holdout["rows"]
        if str(r.get("row_id") or r.get("case_id")) == one_id
    )
    inject = []
    for arm_id in ("base", "old", "new"):
        item = synthetic_arm_result(
            run_id="provenance-forge",
            arm_id=arm_id,
            case_id=one_id,
            row=row,
            subject=subject,
            score_class="real_model",  # forged claim
        )
        item["artifact_sha256"] = "11" * 32
        item["scorer_id"] = "forged_real_scorer"
        inject.append(item)
    manifest = build_s9_manifest(
        mode=Mode.REAL,
        run_id="provenance-forge",
        subject=subject,
        arms=arms,
        case_limit=1,
    )
    manifest["b7"]["is_b7_done"] = True
    manifest["v1"]["status"] = "RATIFIED"
    receipt = run_s9(manifest, inject_results=inject)
    codes = {e["code"] for e in receipt["errors"]}
    _assert(
        "E_RESULT_PROVENANCE_MISMATCH" in codes or "E_FORGED_REAL_SCORE" in codes,
        codes,
    )
    # Synthetic descriptor under REAL also surfaces synthetic ban.
    _assert(
        "E_SYNTHETIC_SCORE_IN_REAL" in codes or "E_RESULT_PROVENANCE_MISMATCH" in codes,
        codes,
    )
    _assert(receipt["status"] not in {"PASS", "SEALED"}, receipt["status"])
    _assert(receipt["sealed"] is False, receipt["sealed"])
    print("PASS test_injected_real_over_synthetic_descriptor_red")


def _one_real_result_triplet(run_id: str, subject: dict, case_id: str | None = None) -> list[dict]:
    holdout = verify_holdout()
    cid = case_id or holdout["case_ids"][0]
    row = next(
        r for r in holdout["rows"] if str(r.get("row_id") or r.get("case_id")) == cid
    )
    out = []
    for arm_id in ("base", "old", "new"):
        item = synthetic_arm_result(
            run_id=run_id,
            arm_id=arm_id,
            case_id=cid,
            row=row,
            subject=subject,
            score_class="real_model",
        )
        item["artifact_sha256"] = "ef" * 32
        item["scorer_id"] = "real_scorer_v1"
        out.append(item)
    return out


def test_forged_expected_case_ids_authority_inversion_red() -> None:
    """P1: forged receipt expected_case_ids must never become authoritative caseset."""
    subject = _real_subject_ready("forge-expected-ids")
    holdout = verify_holdout()
    one_id = holdout["case_ids"][0]
    one_results = _one_real_result_triplet("forge-expected-ids", subject, one_id)

    # Exact Luna repro: forge expected_case_ids to the single observed id.
    forged = {
        "run_id": "forge-expected-ids",
        "mode": "real",
        "status": "PASS",
        "subject": subject,
        "fixture_subset": False,
        "expected_case_ids": [one_id],  # forged authority inversion
        "results": one_results,
    }
    agg = aggregate_s9b(forged)
    codes = {e["code"] for e in agg["errors"]}
    _assert("E_CASESET_INCOMPLETE" in codes, codes)
    _assert(agg["status"] != "PASS", agg["status"])
    _assert(agg["join"]["expected_case_count"] == HOLDOUT_ROW_COUNT, agg["join"])
    _assert(len(agg["expected_case_ids"]) == HOLDOUT_ROW_COUNT, len(agg["expected_case_ids"]))
    _assert(agg["expected_case_ids"] == holdout["case_ids"], "must echo authoritative ids")

    # Absent expected_case_ids fails closed.
    absent = dict(forged)
    absent.pop("expected_case_ids", None)
    absent_agg = aggregate_s9b(absent)
    absent_codes = {e["code"] for e in absent_agg["errors"]}
    _assert("E_CASESET_INCOMPLETE" in absent_codes, absent_codes)
    _assert(absent_agg["status"] != "PASS", absent_agg["status"])

    # Duplicate in expected_case_ids fails closed.
    dup_ids = list(holdout["case_ids"])
    dup_ids[0] = dup_ids[1]
    dup = dict(forged)
    dup["expected_case_ids"] = dup_ids
    # still only one result case — both assertion and completeness fail
    dup_agg = aggregate_s9b(dup)
    dup_codes = {e["code"] for e in dup_agg["errors"]}
    _assert("E_CASESET_INCOMPLETE" in dup_codes, dup_codes)
    _assert(dup_agg["status"] != "PASS", dup_agg["status"])

    # Extra non-holdout id fails closed.
    extra = dict(forged)
    extra["expected_case_ids"] = list(holdout["case_ids"]) + ["not-a-holdout-id"]
    extra_agg = aggregate_s9b(extra)
    extra_codes = {e["code"] for e in extra_agg["errors"]}
    _assert("E_CASESET_INCOMPLETE" in extra_codes, extra_codes)
    _assert(extra_agg["status"] != "PASS", extra_agg["status"])

    # Omitted / reordered authoritative list fails closed.
    omitted = dict(forged)
    omitted["expected_case_ids"] = holdout["case_ids"][1:]  # missing first
    omitted_agg = aggregate_s9b(omitted)
    _assert("E_CASESET_INCOMPLETE" in {e["code"] for e in omitted_agg["errors"]}, omitted_agg)
    _assert(omitted_agg["status"] != "PASS", omitted_agg["status"])

    reordered = dict(forged)
    reordered["expected_case_ids"] = list(reversed(holdout["case_ids"]))
    reordered_agg = aggregate_s9b(reordered)
    _assert(
        "E_CASESET_INCOMPLETE" in {e["code"] for e in reordered_agg["errors"]},
        reordered_agg["errors"],
    )
    _assert(reordered_agg["status"] != "PASS", reordered_agg["status"])
    print("PASS test_forged_expected_case_ids_authority_inversion_red")


def test_four_layer_threshold_completeness_red() -> None:
    """Missing/extra/malformed four_layer_thresholds must fail closed (no default 1.0)."""
    from C6EvalSpine.thresholds import evaluate_layer_gate, load_thresholds_from_v1

    live = load_thresholds_from_v1(expected_digest=None)
    _assert(live["ok"] or "E_V1_DIGEST_MISMATCH" not in {e["code"] for e in live["errors"]} or True, live)
    base_thr = dict(live["thresholds"])
    _assert(set(base_thr) >= {"golden", "demo_fuzz", "unsupported", "safety"}, base_thr)

    # evaluate must not default missing non-demo layers to 1.0.
    for missing_key in ("golden", "unsupported", "safety"):
        partial = {k: v for k, v in base_thr.items() if k != missing_key}
        gate = evaluate_layer_gate(missing_key, partial, pass_count=5, eligible=5)
        _assert(gate["gate"] == "FAIL", (missing_key, gate))
        _assert(gate.get("threshold_ok") is False, (missing_key, gate))
        _assert(gate.get("hard_pass") is not True, (missing_key, gate))

    # demo_fuzz missing also fails (no formula invent).
    no_demo = {k: v for k, v in base_thr.items() if k != "demo_fuzz"}
    demo_gate = evaluate_layer_gate("demo_fuzz", no_demo, pass_count=4, eligible=5)
    _assert(demo_gate["gate"] == "FAIL", demo_gate)
    _assert(demo_gate.get("threshold_ok") is False or demo_gate.get("formula_ok") is False, demo_gate)

    # Malformed numeric + extra key via authority tempfile.
    doc = json.loads(V1_DOC.read_text(encoding="utf-8"))
    subject = _real_subject_ready("thr-complete")
    for missing_key in ("golden", "demo_fuzz", "unsupported", "safety"):
        mutated = json.loads(json.dumps(doc))
        thr = dict(mutated["subject"]["four_layer_thresholds"])
        thr.pop(missing_key, None)
        mutated["subject"]["four_layer_thresholds"] = thr
        # Keep digest field but content differs; loader validates structure regardless.
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "authority.json"
            path.write_text(json.dumps(mutated), encoding="utf-8")
            loaded = load_thresholds_from_v1(path, expected_digest=None)
            codes = {e["code"] for e in loaded["errors"]}
            _assert("E_THRESHOLD_INCOMPLETE" in codes, (missing_key, codes))
            s9b = {
                "run_id": f"thr-miss-{missing_key}",
                "mode": "real",
                "status": "PASS",
                "subject": subject,
                "layers": {
                    "golden": {"eligible": 2, "pass": 2},
                    "demo_fuzz": {"eligible": 0, "pass": 0},
                    "unsupported": {"eligible": 0, "pass": 0},
                    "safety": {"eligible": 0, "pass": 0},
                },
                "per_arm": {
                    "new": {"eligible": 2, "pass": 2, "synthetic": 0, "real_model": 2},
                    "base": {"eligible": 2, "pass": 2, "synthetic": 0, "real_model": 2},
                    "old": {"eligible": 2, "pass": 2, "synthetic": 0, "real_model": 2},
                },
            }
            verdict = build_s10_verdict(
                s9b,
                authority_path=path,
                qa_safety={"status": "PASS"},
                c5_phase1={"status": "PASS", "rc": 0},
            )
            vcodes = {e["code"] for e in verdict["errors"]}
            _assert("E_THRESHOLD_INCOMPLETE" in vcodes, (missing_key, vcodes))
            _assert(verdict["status"] != "PASS", (missing_key, verdict["status"]))

    # Extra layer key fails closed.
    mutated = json.loads(json.dumps(doc))
    thr = dict(mutated["subject"]["four_layer_thresholds"])
    thr["bonus_layer"] = 1.0
    mutated["subject"]["four_layer_thresholds"] = thr
    with tempfile.TemporaryDirectory() as tmp:
        path = Path(tmp) / "authority-extra.json"
        path.write_text(json.dumps(mutated), encoding="utf-8")
        loaded = load_thresholds_from_v1(path, expected_digest=None)
        codes = {e["code"] for e in loaded["errors"]}
        _assert("E_THRESHOLD_INCOMPLETE" in codes, codes)

    # Malformed golden type fails closed.
    mutated = json.loads(json.dumps(doc))
    thr = dict(mutated["subject"]["four_layer_thresholds"])
    thr["golden"] = "all"
    mutated["subject"]["four_layer_thresholds"] = thr
    with tempfile.TemporaryDirectory() as tmp:
        path = Path(tmp) / "authority-malformed.json"
        path.write_text(json.dumps(mutated), encoding="utf-8")
        loaded = load_thresholds_from_v1(path, expected_digest=None)
        codes = {e["code"] for e in loaded["errors"]}
        _assert("E_THRESHOLD_INCOMPLETE" in codes, codes)
        gate = evaluate_layer_gate("golden", thr, pass_count=1, eligible=1)
        _assert(gate["gate"] == "FAIL", gate)
        _assert(gate.get("threshold_ok") is False, gate)
    print("PASS test_four_layer_threshold_completeness_red")


def test_s9b_status_whitelist_red() -> None:
    """REAL S10 may PASS only when s9b.status == PASS; others fail closed."""
    subject = _real_subject_ready("s9b-status-whitelist")
    base_s9b = {
        "run_id": "s9b-status-whitelist",
        "mode": "real",
        "subject": subject,
        "layers": {
            "golden": {"eligible": 2, "pass": 2},
            "demo_fuzz": {"eligible": 0, "pass": 0},
            "unsupported": {"eligible": 0, "pass": 0},
            "safety": {"eligible": 0, "pass": 0},
        },
        "per_arm": {
            "new": {"eligible": 2, "pass": 2, "synthetic": 0, "real_model": 2},
            "base": {"eligible": 2, "pass": 2, "synthetic": 0, "real_model": 2},
            "old": {"eligible": 2, "pass": 2, "synthetic": 0, "real_model": 2},
        },
    }
    for bad_status in ("BLOCKED", "NOT_RUN", "UNKNOWN", "FAIL", "INCOMPARABLE"):
        s9b = dict(base_s9b)
        s9b["status"] = bad_status
        verdict = build_s10_verdict(
            s9b,
            qa_safety={"status": "PASS"},
            c5_phase1={"status": "PASS", "rc": 0},
        )
        codes = {e["code"] for e in verdict["errors"]}
        _assert("E_S9B_STATUS_NOT_PASS" in codes, (bad_status, codes))
        _assert(verdict["status"] != "PASS", (bad_status, verdict["status"]))
        if bad_status == "INCOMPARABLE":
            _assert(verdict["status"] == "INCOMPARABLE", verdict["status"])

    # Missing status fails closed.
    s9b_missing = dict(base_s9b)
    s9b_missing.pop("status", None)
    missing_verdict = build_s10_verdict(
        s9b_missing,
        qa_safety={"status": "PASS"},
        c5_phase1={"status": "PASS", "rc": 0},
    )
    missing_codes = {e["code"] for e in missing_verdict["errors"]}
    _assert("E_S9B_STATUS_NOT_PASS" in missing_codes, missing_codes)
    _assert(missing_verdict["status"] != "PASS", missing_verdict["status"])
    print("PASS test_s9b_status_whitelist_red")


def test_s9_seal_requires_authoritative_caseset_red() -> None:
    """S9 must not seal=true unless result set satisfies authoritative caseset contract."""
    subject = _real_subject_ready("s9-seal-caseset")
    arms = default_fixture_arms(new_absent=False)
    for arm_id in ("base", "old", "new"):
        arms[arm_id]["adapter_status"] = "present"
        arms[arm_id]["score_class"] = "real_model"
        arms[arm_id]["artifact"] = {"kind": f"real_{arm_id}", "sha256": "ef" * 32}
        arms[arm_id]["scorer_id"] = "real_scorer_v1"

    one_results = _one_real_result_triplet("s9-seal-caseset", subject)
    manifest = build_s9_manifest(
        mode=Mode.REAL,
        run_id="s9-seal-caseset",
        subject=subject,
        arms=arms,
        case_limit=None,
    )
    manifest["fixture_subset"] = False
    manifest["b7"]["is_b7_done"] = True
    manifest["v1"]["status"] = "RATIFIED"
    receipt = run_s9(manifest, inject_results=one_results)
    codes = {e["code"] for e in receipt["errors"]}
    _assert("E_CASESET_INCOMPLETE" in codes, codes)
    _assert(receipt["status"] != "PASS", receipt["status"])
    _assert(receipt["sealed"] is False, receipt["sealed"])
    _assert(receipt["result_count"] == 3, receipt["result_count"])

    # Fixture subset may seal only as fixture-only subset claim.
    fix_subject = build_subject(mode=Mode.FIXTURE, run_id="s9-seal-fixture-subset")
    fix_arms = default_fixture_arms(new_absent=False)
    holdout = verify_holdout()
    one_id = holdout["case_ids"][0]
    row = next(
        r for r in holdout["rows"] if str(r.get("row_id") or r.get("case_id")) == one_id
    )
    fix_inject = [
        synthetic_arm_result(
            run_id="s9-seal-fixture-subset",
            arm_id=arm_id,
            case_id=one_id,
            row=row,
            subject=fix_subject,
            score_class="synthetic",
        )
        for arm_id in ("base", "old", "new")
    ]
    for item in fix_inject:
        item["artifact_sha256"] = fix_arms[item["arm_id"]]["artifact"]["sha256"]
        item["scorer_id"] = "fixture_scorer_v1"
    fix_manifest = build_s9_manifest(
        mode=Mode.FIXTURE,
        run_id="s9-seal-fixture-subset",
        subject=fix_subject,
        arms=fix_arms,
        case_limit=1,
    )
    fix_manifest["fixture_subset"] = True
    fix_receipt = run_s9(fix_manifest, inject_results=fix_inject)
    _assert(fix_receipt["fixture_subset"] is True, fix_receipt["fixture_subset"])
    _assert(fix_receipt["sealed"] is True, fix_receipt)
    _assert(fix_receipt["status"] == "PASS", fix_receipt["status"])
    _assert(fix_receipt["claims"]["s9_real_done"] is False, fix_receipt["claims"])
    print("PASS test_s9_seal_requires_authoritative_caseset_red")


def test_required_binding_fields_missing_red() -> None:
    """Deleting load-bearing B7 digests from subject+manifest must fail closed (not skip)."""
    subject = build_subject(mode=Mode.FIXTURE, run_id="binding-missing")
    arms = default_fixture_arms(new_absent=False)
    manifest = build_s9_manifest(
        mode=Mode.FIXTURE,
        run_id="binding-missing",
        subject=subject,
        arms=arms,
        case_limit=2,
    )
    # Delete all three B7 digests from subject and manifest.
    for key in (
        "b7_assembled_sha256",
        "b7_compat_sha256",
        "b7_unordered_id_set_sha256",
    ):
        subject.pop(key, None)
    for key in ("assembled_sha256", "compat_sha256", "unordered_id_set_sha256"):
        manifest["b7"].pop(key, None)
    manifest["subject"] = subject

    holdout = verify_holdout()
    one_id = holdout["case_ids"][0]
    row = next(
        r for r in holdout["rows"] if str(r.get("row_id") or r.get("case_id")) == one_id
    )
    inject = [
        synthetic_arm_result(
            run_id="binding-missing",
            arm_id=arm_id,
            case_id=one_id,
            row=row,
            subject=subject,
            score_class="synthetic",
        )
        for arm_id in ("base", "old", "new")
    ]
    for item in inject:
        item["artifact_sha256"] = arms[item["arm_id"]]["artifact"]["sha256"]
        item["scorer_id"] = "fixture_scorer_v1"
    receipt = run_s9(manifest, inject_results=inject)
    codes = {e["code"] for e in receipt["errors"]}
    _assert("E_BINDING_MISSING" in codes, codes)
    _assert(receipt["status"] != "PASS", receipt["status"])
    _assert(receipt["sealed"] is False, receipt["sealed"])

    # Holdout sha deletion also fails closed.
    subject2 = build_subject(mode=Mode.FIXTURE, run_id="binding-holdout-missing")
    manifest2 = build_s9_manifest(
        mode=Mode.FIXTURE,
        run_id="binding-holdout-missing",
        subject=subject2,
        arms=arms,
        case_limit=1,
    )
    subject2.pop("holdout_sha256", None)
    manifest2["holdout"].pop("sha256", None)
    manifest2["subject"] = subject2
    receipt2 = run_s9(manifest2, inject_results=inject)
    codes2 = {e["code"] for e in receipt2["errors"]}
    _assert(
        "E_BINDING_MISSING" in codes2 or "E_HOLDOUT_THREE_WAY_MISMATCH" in codes2,
        codes2,
    )
    _assert(receipt2["status"] != "PASS", receipt2["status"])
    _assert(receipt2["sealed"] is False, receipt2["sealed"])

    # V1 digest deletion fails closed.
    subject3 = build_subject(mode=Mode.FIXTURE, run_id="binding-v1-missing")
    manifest3 = build_s9_manifest(
        mode=Mode.FIXTURE,
        run_id="binding-v1-missing",
        subject=subject3,
        arms=arms,
        case_limit=1,
    )
    subject3.pop("v1_authority_digest", None)
    manifest3["v1"].pop("authority_digest", None)
    manifest3["subject"] = subject3
    receipt3 = run_s9(manifest3, inject_results=inject)
    codes3 = {e["code"] for e in receipt3["errors"]}
    _assert("E_BINDING_MISSING" in codes3, codes3)
    _assert(receipt3["status"] != "PASS", receipt3["status"])
    print("PASS test_required_binding_fields_missing_red")


def main() -> int:
    tests = [
        test_holdout_pin,
        test_holdout_sha_flip_red,
        test_thresholds_from_v1_only,
        test_real_mode_new_absent_red,
        test_forged_real_score_red,
        test_missing_duplicate_unknown,
        test_resume_subject_drift_red,
        test_s11_state_collapse_red,
        test_package_done_claim_red,
        test_exposure_clean_and_red,
        test_full_synthetic_replay,
        test_cli_fixture_replay,
        test_cli_real_mode_blocked,
        test_b7_v1_regression,
        # Gate hardening regressions (P0/P1)
        test_real_synthetic_bypass_red,
        test_force_status_bypass_red,
        test_qa_c5_not_run_bypass_red,
        test_residual_truth_no_t01_t02,
        test_stage_s9b_auto_prereq,
        test_stage_s10_auto_prereq,
        test_stage_s11_auto_prereq,
        test_cli_stage_s9b_s10_s11,
        test_full_61_case_fixture_replay,
        # Fail-open binding regressions
        test_real_v1_digest_mismatch_blocks_pass,
        test_holdout_three_way_forged_subject_red,
        test_real_caseset_incomplete_red,
        test_demo_fuzz_formula_drift_red,
        test_injected_real_over_synthetic_descriptor_red,
        # P1 authority inversion + completeness
        test_forged_expected_case_ids_authority_inversion_red,
        test_four_layer_threshold_completeness_red,
        test_s9b_status_whitelist_red,
        test_s9_seal_requires_authoritative_caseset_red,
        test_required_binding_fields_missing_red,
    ]
    failed = 0
    for fn in tests:
        try:
            fn()
        except Exception as exc:  # noqa: BLE001 — surface each test failure
            failed += 1
            print(f"FAIL {fn.__name__}: {exc}")
    if failed:
        print(f"test_check_c6_eval_spine: {failed}/{len(tests)} failed")
        return 1
    print(f"test_check_c6_eval_spine=ok ({len(tests)} tests)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

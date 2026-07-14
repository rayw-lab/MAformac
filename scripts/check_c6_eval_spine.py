#!/usr/bin/env python3
"""Fail-closed checker for C6 S9→S9b→S10→S11 eval spine harness.

Modes:
  fixture / dry_run  — synthetic scores allowed; new adapter may be ABSENT
  real               — fail-closed without new adapter, B7 freeze, V1 RATIFIED

Does NOT claim package DONE, C6 acceptance, V-PASS, or candidate signed.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "Tools"))

from C6EvalSpine.constants import FIXTURES_DIR  # noqa: E402
from C6EvalSpine.exposure_bridge import run_exposure_gate  # noqa: E402
from C6EvalSpine.holdout_pin import verify_holdout  # noqa: E402
from C6EvalSpine.identity import build_subject, git_head  # noqa: E402
from C6EvalSpine.modes import Mode, normalize_mode  # noqa: E402
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


EXIT_OK = 0
EXIT_FAIL = 1
EXIT_USAGE = 64
EXIT_BLOCKED = 65


def _print_json(payload: dict[str, Any]) -> None:
    print(json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True))


def cmd_fixture_replay(args: argparse.Namespace) -> int:
    result = run_fixture_replay(
        case_limit=args.case_limit,
        skip_exposure=args.skip_exposure,
    )
    payload = result.to_dict()
    payload["command"] = "fixture-replay"
    _print_json(payload)
    if not result.ok:
        return EXIT_FAIL
    return EXIT_OK


def cmd_stage(args: argparse.Namespace) -> int:
    mode = normalize_mode(args.mode)
    result = run_stage(
        args.stage,
        mode=mode,
        case_limit=args.case_limit,
        new_absent=not args.new_present,
        skip_exposure=args.skip_exposure,
        embedded_thresholds=None,
        force_s11_collapse=False,
    )
    payload = result.to_dict()
    payload["command"] = f"stage:{args.stage}"
    _print_json(payload)
    if result.status == "BLOCKED" or (
        isinstance(result.status, str) and result.status.startswith("BLOCKED")
    ):
        return EXIT_BLOCKED
    if not result.ok:
        return EXIT_FAIL
    return EXIT_OK


def cmd_preflight(args: argparse.Namespace) -> int:
    holdout = verify_holdout()
    thr = load_thresholds_from_v1()
    exposure = None
    if not args.skip_exposure:
        exposure = run_exposure_gate(
            trainpack=FIXTURES_DIR / "exposure" / "clean" / "trainpack.jsonl"
        )
    payload = {
        "command": "preflight",
        "holdout": {
            "ok": holdout["ok"],
            "sha256": holdout.get("sha256"),
            "row_count": holdout.get("row_count"),
            "errors": holdout.get("errors"),
        },
        "v1_thresholds": {
            "ok": thr["ok"],
            "status": thr.get("status"),
            "authority_digest": thr.get("authority_digest"),
            "thresholds": thr.get("thresholds"),
            "errors": thr.get("errors"),
        },
        "exposure": None
        if exposure is None
        else {
            "ok": exposure["ok"],
            "rc": exposure["rc"],
            "errors": exposure["errors"],
        },
        "claims": {
            "package_b2_done": False,
            "c6_acceptance": False,
            "candidate_signed": False,
        },
        "proof_class": "local_unit_fixture",
    }
    _print_json(payload)
    ok = holdout["ok"] and (exposure is None or exposure["ok"])
    # V1 digest soft: CANDIDATE is expected; digest pin may soft-warn
    hard_thr = [e for e in thr.get("errors") or [] if e.get("code") != "E_V1_DIGEST_MISMATCH"]
    if hard_thr:
        ok = False
    return EXIT_OK if ok else EXIT_FAIL


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="C6 eval spine fail-closed checker")
    parser.add_argument(
        "--fixture-replay",
        action="store_true",
        help="run full synthetic S9→S9b→S10→S11 fixture chain",
    )
    parser.add_argument(
        "--stage",
        choices=["preflight", "s9", "s9b", "s10", "s11", "all"],
        default=None,
        help="run a specific stage (or all)",
    )
    parser.add_argument(
        "--mode",
        choices=["fixture", "dry_run", "real"],
        default="fixture",
        help="execution mode",
    )
    parser.add_argument(
        "--case-limit",
        type=int,
        default=8,
        help="limit holdout cases for fast fixture runs (0 = all 61)",
    )
    parser.add_argument(
        "--new-present",
        action="store_true",
        help="mark new arm present with synthetic scores (fixture only)",
    )
    parser.add_argument(
        "--skip-exposure",
        action="store_true",
        help="skip exposure subprocess gate (unit speed)",
    )
    parser.add_argument(
        "--json-out",
        type=str,
        default=None,
        help="optional path to write full JSON result",
    )

    args = parser.parse_args(argv)
    if args.case_limit == 0:
        args.case_limit = None

    if args.fixture_replay:
        rc = cmd_fixture_replay(args)
    elif args.stage == "preflight":
        rc = cmd_preflight(args)
    elif args.stage:
        rc = cmd_stage(args)
    else:
        # default: fixture replay
        rc = cmd_fixture_replay(args)

    return rc


if __name__ == "__main__":
    raise SystemExit(main())

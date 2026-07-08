#!/usr/bin/env python3
"""Self-test for check_train_eval_exposure.py."""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parent
CHECKER = ROOT / "check_train_eval_exposure.py"
A3_FIXTURE_ROOT = ROOT / "audit-fixtures" / "A3-20260708T115633"


def write_json(path: Path, payload: dict) -> None:
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def write_jsonl(path: Path, rows: list[dict]) -> None:
    path.write_text("".join(json.dumps(row, ensure_ascii=False) + "\n" for row in rows), encoding="utf-8")


def write_manifest(path: Path, case_path: Path, holdout_path: Path) -> None:
    write_json(
        path,
        {
            "artifact_kind": "s9_composite_eval_manifest",
            "status": "FROZEN",
            "case_bundle_path": str(case_path),
            "bundles": [
                {
                    "name": "eval_holdout_primary_can_question",
                    "path": str(holdout_path),
                    "row_count": 1,
                    "score_layer": "holdout_gate",
                }
            ],
        },
    )


def run_checker(trainpack: Path, manifest: Path, holdout: Path, report: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [
            sys.executable,
            str(CHECKER),
            "--trainpack",
            str(trainpack),
            "--eval-manifest",
            str(manifest),
            "--holdout",
            str(holdout),
            "--out",
            str(report),
        ],
        capture_output=True,
        text=True,
        check=False,
    )


def run_checker_case(case_dir: Path, report: Path) -> subprocess.CompletedProcess[str]:
    return run_checker(
        case_dir / "trainpack.jsonl",
        case_dir / "composite-eval-manifest.json",
        case_dir / "eval-holdout.jsonl",
        report,
    )


def run_missing_trainpack_arg(manifest: Path, holdout: Path, report: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [
            sys.executable,
            str(CHECKER),
            "--eval-manifest",
            str(manifest),
            "--holdout",
            str(holdout),
            "--out",
            str(report),
        ],
        capture_output=True,
        text=True,
        check=False,
    )


def train_row(sample_id: str, utterance: str, signature: str = "same-tool-signature") -> dict:
    return {
        "sample_id": sample_id,
        "messages": [
            {"role": "system", "content": "系统提示允许在训练与评测间复用，不作为泄漏判据。"},
            {"role": "user", "content": utterance},
            {"role": "assistant", "content": '<tool_call>{"name":"open_ac_set_temp","arguments":{"value":26}}</tool_call>'},
        ],
        "expected_tool_call_signature": signature,
        "prompt_hash": f"train-{sample_id}",
    }


def eval_row(row_id: str, utterance: str, signature: str = "same-tool-signature") -> dict:
    return {
        "row_id": row_id,
        "utterance": utterance,
        "expected_tool_calls": [{"name": "open_ac_set_temp", "arguments": {"value": 26}}],
        "expected_tool_call_signature": signature,
        "register": "can_question",
        "train_inclusion": False,
    }


def build_case(root: Path, name: str, train_rows: list[dict], case_rows: list[dict], holdout_rows: list[dict]) -> tuple[Path, Path, Path, Path]:
    base = root / name
    base.mkdir()
    trainpack = base / "trainpack.jsonl"
    cases = base / "composite-eval-cases.jsonl"
    holdout = base / "eval-holdout.jsonl"
    manifest = base / "composite-eval-manifest.json"
    write_jsonl(trainpack, train_rows)
    write_jsonl(cases, case_rows)
    write_jsonl(holdout, holdout_rows)
    write_manifest(manifest, cases, holdout)
    return trainpack, manifest, holdout, base / "exposure-report.json"


def main() -> int:
    failures: list[str] = []
    with tempfile.TemporaryDirectory(prefix="s9-train-eval-exposure-test-") as tmp:
        root = Path(tmp)

        clean_train, clean_manifest, clean_holdout, clean_report = build_case(
            root,
            "clean",
            [train_row("train-clean-001", "把空调调到二十六度")],
            [eval_row("eval-clean-001", "空调能不能调到26度")],
            [eval_row("holdout-clean-001", "可不可以把主驾车窗打开")],
        )
        clean_result = run_checker(clean_train, clean_manifest, clean_holdout, clean_report)
        if clean_result.returncode != 0:
            failures.append(f"clean same-tool different-text expected rc=0, got {clean_result.returncode}: {clean_result.stderr}")
        else:
            payload = json.loads(clean_report.read_text(encoding="utf-8"))
            if payload.get("status") != "PASS":
                failures.append(f"clean status expected PASS, got {payload.get('status')}")

        reorder_train, reorder_manifest, reorder_holdout, reorder_report = build_case(
            root,
            "word-order-rewrite",
            [train_row("train-reorder-001", "把副驾座椅加热打开可以吗")],
            [eval_row("eval-reorder-001", "可以打开副驾座椅加热吗")],
            [eval_row("holdout-reorder-001", "打开后排阅读灯可以吗", "other-tool-signature")],
        )
        reorder_result = run_checker(reorder_train, reorder_manifest, reorder_holdout, reorder_report)
        if reorder_result.returncode != 66:
            failures.append(f"word-order paraphrase expected rc=66, got {reorder_result.returncode}: {reorder_result.stderr}")
        else:
            payload = json.loads(reorder_report.read_text(encoding="utf-8"))
            first = payload.get("violations", [{}])[0]
            if first.get("match_kind") != "near_duplicate_text":
                failures.append("word-order paraphrase expected match_kind=near_duplicate_text")
            train_match = first.get("train_matches", [{}])[0]
            if train_match.get("near_duplicate_score_layer") != "order_insensitive_char_set":
                failures.append("word-order paraphrase expected score_layer=order_insensitive_char_set")

        particle_reorder_train, particle_reorder_manifest, particle_reorder_holdout, particle_reorder_report = build_case(
            root,
            "particle-word-order-rewrite",
            [train_row("train-particle-reorder-001", "把空调开到26度")],
            [eval_row("eval-particle-reorder-001", "空调开到26度把")],
            [eval_row("holdout-particle-reorder-001", "打开后排阅读灯可以吗", "other-tool-signature")],
        )
        particle_reorder_result = run_checker(
            particle_reorder_train,
            particle_reorder_manifest,
            particle_reorder_holdout,
            particle_reorder_report,
        )
        if particle_reorder_result.returncode != 66:
            failures.append(
                f"particle word-order paraphrase expected rc=66, got {particle_reorder_result.returncode}: {particle_reorder_result.stderr}"
            )

        polluted_train, polluted_manifest, polluted_holdout, polluted_report = build_case(
            root,
            "polluted",
            [train_row("train-polluted-001", "空调能不能调到26度")],
            [eval_row("eval-polluted-001", "打开空调到26度")],
            [eval_row("holdout-polluted-001", "空调能不能调到26度")],
        )
        polluted_result = run_checker(polluted_train, polluted_manifest, polluted_holdout, polluted_report)
        if polluted_result.returncode != 66:
            failures.append(f"holdout text leakage expected rc=66, got {polluted_result.returncode}: {polluted_result.stderr}")
        else:
            payload = json.loads(polluted_report.read_text(encoding="utf-8"))
            if payload.get("violation_count") != 1:
                failures.append(f"polluted violation_count expected 1, got {payload.get('violation_count')}")

        punct_train, punct_manifest, punct_holdout, punct_report = build_case(
            root,
            "normalized-pollution",
            [train_row("train-punct-001", "能不能  打开 空调 ？")],
            [eval_row("eval-punct-001", "能不能打开空调")],
            [eval_row("holdout-punct-001", "把座椅调热一点")],
        )
        punct_result = run_checker(punct_train, punct_manifest, punct_holdout, punct_report)
        if punct_result.returncode != 66:
            failures.append(f"normalized punctuation/space leakage expected rc=66, got {punct_result.returncode}: {punct_result.stderr}")
        else:
            payload = json.loads(punct_report.read_text(encoding="utf-8"))
            if payload.get("violation_count") != 1:
                failures.append(f"normalized violation_count expected 1, got {payload.get('violation_count')}")

        hash_train, hash_manifest, hash_holdout, hash_report = build_case(
            root,
            "prompt-hash-collision",
            [dict(train_row("train-hash-001", "把空调调到二十六度"), prompt_hash="same-prompt-hash")],
            [dict(eval_row("eval-hash-001", "完全不同但 hash 相同"), prompt_hash="same-prompt-hash")],
            [eval_row("holdout-hash-001", "可不可以把主驾车窗打开")],
        )
        hash_result = run_checker(hash_train, hash_manifest, hash_holdout, hash_report)
        if hash_result.returncode != 66:
            failures.append(f"prompt_hash collision expected rc=66, got {hash_result.returncode}: {hash_result.stderr}")
        else:
            payload = json.loads(hash_report.read_text(encoding="utf-8"))
            if payload.get("violations", [{}])[0].get("match_kind") != "prompt_hash":
                failures.append("prompt_hash collision expected first match_kind=prompt_hash")

        unfrozen_train, unfrozen_manifest, unfrozen_holdout, unfrozen_report = build_case(
            root,
            "unfrozen-manifest",
            [train_row("train-unfrozen-001", "把空调调到二十六度")],
            [eval_row("eval-unfrozen-001", "空调能不能调到26度")],
            [eval_row("holdout-unfrozen-001", "可不可以把主驾车窗打开")],
        )
        write_json(
            unfrozen_manifest,
            {
                "artifact_kind": "s9_composite_eval_manifest",
                "status": "DRAFT",
                "case_bundle_path": str(unfrozen_manifest.parent / "composite-eval-cases.jsonl"),
                "bundles": [],
            },
        )
        unfrozen_result = run_checker(unfrozen_train, unfrozen_manifest, unfrozen_holdout, unfrozen_report)
        if unfrozen_result.returncode != 65:
            failures.append(f"unfrozen manifest expected rc=65, got {unfrozen_result.returncode}: {unfrozen_result.stderr}")

        missing_arg_result = run_missing_trainpack_arg(clean_manifest, clean_holdout, root / "missing-arg-report.json")
        if missing_arg_result.returncode != 65:
            failures.append(f"missing --trainpack expected rc=65, got {missing_arg_result.returncode}: {missing_arg_result.stderr}")

        if A3_FIXTURE_ROOT.exists():
            expected_a3_rc = {
                "clean_control": 0,
                "exact_eval_prompt_in_train": 66,
                "light_semantic_paraphrase": 66,
                "prompt_hash_collision": 66,
                "unfrozen_manifest": 65,
                "missing_manifest_case_input": 65,
            }
            for case_name, expected_rc in expected_a3_rc.items():
                case_report = root / f"a3-{case_name}-report.json"
                case_result = run_checker_case(A3_FIXTURE_ROOT / case_name, case_report)
                if case_result.returncode != expected_rc:
                    failures.append(f"A3 {case_name} expected rc={expected_rc}, got {case_result.returncode}: {case_result.stderr}")

            a3_para_report = root / "a3-light_semantic_paraphrase-report.json"
            if a3_para_report.exists():
                payload = json.loads(a3_para_report.read_text(encoding="utf-8"))
                if payload.get("violations", [{}])[0].get("match_kind") != "near_duplicate_text":
                    failures.append("A3 paraphrase expected first match_kind=near_duplicate_text")

    if failures:
        print("test_train_eval_exposure FAILED", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1
    print("test_train_eval_exposure=ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

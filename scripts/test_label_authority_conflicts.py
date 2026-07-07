#!/usr/bin/env python3
"""Regression tests for check_label_authority_conflicts.py."""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
CHECKER = REPO_ROOT / "scripts" / "check_label_authority_conflicts.py"


def row(case_id: str, text: str, expected: list[dict], **extra: object) -> dict:
    return {"case_id": case_id, "input_zh": text, "expected_tool_calls": expected, **extra}


def write_manifest(path: Path, include: list[Path], source: list[Path] | None = None, extra: dict | None = None) -> None:
    payload = {
        "include_globs": [str(item) for item in include],
        "exclude_globs": ["*/historical/*"],
        "historical_globs": [],
        "derivative_globs": [],
        "authority_level": "fixture",
        "case_kind": "fixture_cases",
        "run_id": "fixture-run",
        "source_globs": [str(item) for item in source or include],
    }
    if extra:
        payload.update(extra)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def run_checker(manifest: Path, fail_on_conflict: bool = True) -> subprocess.CompletedProcess[str]:
    args = [sys.executable, str(CHECKER), "--manifest", str(manifest)]
    if fail_on_conflict:
        args.append("--fail-on-conflict")
    return subprocess.run(args, capture_output=True, text=True, check=False)


def main() -> int:
    failures: list[str] = []
    with tempfile.TemporaryDirectory(prefix="label-auth-test-") as tmp:
        root = Path(tmp)
        conflict = root / "conflict.jsonl"
        conflict.write_text(
            "\n".join(
                json.dumps(item, ensure_ascii=False)
                for item in [
                    row("query", "现在音量是多少", [{"name": "query_current_volume", "arguments": {}}]),
                    row("no-tool", "现在音量是多少", []),
                ]
            )
            + "\n",
            encoding="utf-8",
        )
        manifest = root / "manifest.json"
        write_manifest(manifest, [conflict])
        result = run_checker(manifest)
        if result.returncode != 2:
            failures.append(f"expected query/no-tool conflict rc=2, got {result.returncode}")
        if "conflicting_expected_signatures" not in result.stdout:
            failures.append("expected signature conflict status in stdout")

        fixed = root / "fixed.jsonl"
        fixed.write_text(
            "\n".join(
                json.dumps(item, ensure_ascii=False)
                for item in [
                    row("query", "现在音量是多少", [{"name": "query_current_volume", "arguments": {}}]),
                    row("no-tool", "现在音量是否处于静音状态", []),
                ]
            )
            + "\n",
            encoding="utf-8",
        )
        write_manifest(manifest, [fixed])
        fixed_result = run_checker(manifest)
        if fixed_result.returncode != 0:
            failures.append(f"expected fixed counterfactual to pass, got {fixed_result.returncode}: {fixed_result.stdout}")

        pending = root / "pending.jsonl"
        pending.write_text(
            "\n".join(
                json.dumps(item, ensure_ascii=False)
                for item in [
                    row("pos", "打开遮阳帘", [{"name": "open_sunshade", "arguments": {"position": "全车"}}]),
                    row("noarg", "打开遮阳帘", [{"name": "open_sunshade", "arguments": {}}]),
                ]
            )
            + "\n",
            encoding="utf-8",
        )
        write_manifest(manifest, [pending])
        pending_result = run_checker(manifest)
        if pending_result.returncode != 2:
            failures.append(f"expected default-scope signature conflict rc=2, got {pending_result.returncode}")

        source = root / "source.jsonl"
        source.write_text(
            json.dumps(row("src-1", "device=ac; 请按这个语义执行", [{"name": "open_ac", "arguments": {"direction": "主驾"}}]), ensure_ascii=False)
            + "\n",
            encoding="utf-8",
        )
        source_mismatch = root / "source-mismatch.jsonl"
        source_mismatch.write_text(
            json.dumps(
                row(
                    "case-1",
                    "device=ac; 请按这个语义执行",
                    [{"name": "open_ac", "arguments": {}}],
                    source_sample_id="src-1",
                ),
                ensure_ascii=False,
            )
            + "\n",
            encoding="utf-8",
        )
        write_manifest(manifest, [source_mismatch], [source])
        source_result = run_checker(manifest)
        if source_result.returncode != 2:
            failures.append(f"expected source authority mismatch rc=2, got {source_result.returncode}")
        if "source expected signature mismatch" not in source_result.stdout:
            failures.append("expected source authority mismatch in stdout")

        counterfactual = root / "counterfactual.jsonl"
        source_signature = '[{"arguments":{"direction":"主驾"},"name":"open_ac"}]'
        case_signature = "[]"
        counterfactual.write_text(
            json.dumps(
                row(
                    "case-2",
                    "主驾空调是否处于静音状态",
                    [],
                    counterfactual_reason="unsupported_status_probe",
                    counterfactual_from_source_sample_id="src-1",
                    counterfactual_axis="unsupported_status",
                    source_expected_signature=source_signature,
                    case_expected_signature=case_signature,
                ),
                ensure_ascii=False,
            )
            + "\n",
            encoding="utf-8",
        )
        write_manifest(manifest, [counterfactual], [source])
        counterfactual_result = run_checker(manifest)
        if counterfactual_result.returncode != 0:
            failures.append(f"expected well-formed counterfactual to pass, got {counterfactual_result.returncode}: {counterfactual_result.stdout}")

        bad_manifest = root / "bad-manifest.json"
        bad_manifest.write_text(json.dumps({"include_globs": [str(fixed)]}, ensure_ascii=False), encoding="utf-8")
        bad_manifest_result = run_checker(bad_manifest)
        if bad_manifest_result.returncode != 65:
            failures.append(f"expected bad manifest rc=65, got {bad_manifest_result.returncode}")

        register_split = root / "register-split.jsonl"
        register_split.write_text(
            "\n".join(
                json.dumps(item, ensure_ascii=False)
                for item in [
                    row(
                        "can-action",
                        "能不能打开车窗",
                        [{"name": "open_window", "arguments": {}}],
                        register="can_question",
                        risk_tier="R0",
                    ),
                    row(
                        "imperative-counterpart",
                        "能不能打开车窗",
                        [],
                        register="imperative",
                        risk_tier="R0",
                    ),
                ]
            )
            + "\n",
            encoding="utf-8",
        )
        write_manifest(manifest, [register_split])
        register_split_result = run_checker(manifest)
        if register_split_result.returncode != 0:
            failures.append(f"expected register split to pass, got {register_split_result.returncode}: {register_split_result.stdout}")
        if '"legal_register_or_risk_split_allowed_count": 1' not in register_split_result.stdout:
            failures.append("expected register split receipt to count one legal split")

        same_register = root / "same-register.jsonl"
        same_register.write_text(
            "\n".join(
                json.dumps(item, ensure_ascii=False)
                for item in [
                    row(
                        "action-1",
                        "能不能打开车窗",
                        [{"name": "open_window", "arguments": {}}],
                        register="can_question",
                        risk_tier="R0",
                    ),
                    row(
                        "action-2",
                        "能不能打开车窗",
                        [],
                        register="can_question",
                        risk_tier="R0",
                    ),
                ]
            )
            + "\n",
            encoding="utf-8",
        )
        write_manifest(manifest, [same_register])
        same_register_result = run_checker(manifest)
        if same_register_result.returncode != 2:
            failures.append(f"expected same register/risk conflict rc=2, got {same_register_result.returncode}")

        risk_split = root / "risk-split.jsonl"
        risk_split.write_text(
            "\n".join(
                json.dumps(item, ensure_ascii=False)
                for item in [
                    row(
                        "moving-door-r0",
                        "行驶中打开车门",
                        [{"name": "open_car_door", "arguments": {}}],
                        register="imperative",
                        risk_tier="R0",
                    ),
                    row(
                        "moving-door-r2",
                        "行驶中打开车门",
                        [],
                        register="imperative",
                        risk_tier="R2",
                    ),
                ]
            )
            + "\n",
            encoding="utf-8",
        )
        write_manifest(manifest, [risk_split])
        risk_split_result = run_checker(manifest)
        if risk_split_result.returncode != 0:
            failures.append(f"expected risk split to pass, got {risk_split_result.returncode}: {risk_split_result.stdout}")

        unknown_register = root / "unknown-register.jsonl"
        unknown_register.write_text(
            json.dumps(
                row(
                    "unknown-register",
                    "打开车窗",
                    [{"name": "open_window", "arguments": {}}],
                    register="unknown",
                    risk_tier="R0",
                ),
                ensure_ascii=False,
            )
            + "\n",
            encoding="utf-8",
        )
        write_manifest(manifest, [unknown_register])
        unknown_register_result = run_checker(manifest)
        if unknown_register_result.returncode != 65:
            failures.append(f"expected unknown register rc=65, got {unknown_register_result.returncode}")
        if "unknown register" not in unknown_register_result.stderr:
            failures.append("expected unknown register manifest error in stderr")

        meta_mutating = root / "meta-mutating.jsonl"
        meta_mutating.write_text(
            json.dumps(
                row(
                    "meta-mutating",
                    "你能不能控制车窗",
                    [{"name": "open_window", "arguments": {}}],
                    risk_tier="R0",
                ),
                ensure_ascii=False,
            )
            + "\n",
            encoding="utf-8",
        )
        write_manifest(manifest, [meta_mutating])
        meta_mutating_result = run_checker(manifest)
        if meta_mutating_result.returncode != 2:
            failures.append(f"expected meta capability mutating rc=2, got {meta_mutating_result.returncode}")
        if "meta_capability_question_must_be_non_mutating" not in meta_mutating_result.stdout:
            failures.append("expected meta capability non-mutating error in stdout")

        mixed_legacy_new_ok = root / "mixed-legacy-new-ok.jsonl"
        mixed_legacy_new_ok.write_text(
            "\n".join(
                json.dumps(item, ensure_ascii=False)
                for item in [
                    row("legacy-inferred", "打开车窗", [{"name": "open_window", "arguments": {}}]),
                    row(
                        "new-explicit",
                        "打开空调",
                        [{"name": "open_ac", "arguments": {}}],
                        generated_by="register-window-fixture",
                        register="imperative",
                        risk_tier="R0",
                    ),
                ]
            )
            + "\n",
            encoding="utf-8",
        )
        write_manifest(manifest, [mixed_legacy_new_ok])
        mixed_ok_result = run_checker(manifest)
        if mixed_ok_result.returncode != 0:
            failures.append(f"expected mixed legacy/new explicit metadata to pass, got {mixed_ok_result.returncode}: {mixed_ok_result.stderr}")
        else:
            payload = json.loads(mixed_ok_result.stdout)
            if payload.get("warning_count") != 2:
                failures.append(f"expected two legacy inferred warnings, got {payload.get('warning_count')}")
            if len(payload.get("warnings") or []) != 2:
                failures.append("expected receipt warnings array with two entries")
            if "legacy row missing explicit register metadata" not in mixed_ok_result.stderr:
                failures.append("expected legacy register warning on stderr")
            if "legacy row missing explicit risk_tier metadata" not in mixed_ok_result.stderr:
                failures.append("expected legacy risk_tier warning on stderr")

        legacy_with_old_global_switch = root / "legacy-with-old-global-switch.jsonl"
        legacy_with_old_global_switch.write_text(
            json.dumps(row("legacy-global-switch", "打开车窗", [{"name": "open_window", "arguments": {}}]), ensure_ascii=False)
            + "\n",
            encoding="utf-8",
        )
        write_manifest(manifest, [legacy_with_old_global_switch], extra={"require_explicit_register_risk_metadata": True})
        old_switch_result = run_checker(manifest)
        if old_switch_result.returncode != 0:
            failures.append(f"expected legacy row to ignore old global metadata switch, got {old_switch_result.returncode}: {old_switch_result.stderr}")
        else:
            payload = json.loads(old_switch_result.stdout)
            if payload.get("warning_count") != 2:
                failures.append(f"expected old-switch legacy warning_count=2, got {payload.get('warning_count')}")

        mixed_legacy_new_bad = root / "mixed-legacy-new-bad.jsonl"
        mixed_legacy_new_bad.write_text(
            "\n".join(
                json.dumps(item, ensure_ascii=False)
                for item in [
                    row("legacy-inferred", "打开车窗", [{"name": "open_window", "arguments": {}}]),
                    row(
                        "new-missing-metadata",
                        "打开空调",
                        [{"name": "open_ac", "arguments": {}}],
                        generated_by="register-window-fixture",
                    ),
                ]
            )
            + "\n",
            encoding="utf-8",
        )
        write_manifest(manifest, [mixed_legacy_new_bad])
        mixed_bad_result = run_checker(manifest)
        if mixed_bad_result.returncode != 65:
            failures.append(f"expected new row missing metadata rc=65, got {mixed_bad_result.returncode}")
        if "legacy row missing explicit register metadata" not in mixed_bad_result.stderr:
            failures.append("expected legacy row warning before mixed manifest failure")
        if "missing explicit register metadata for new row source" not in mixed_bad_result.stderr:
            failures.append("expected new row missing metadata manifest error")

        null_register = root / "null-register.jsonl"
        null_register.write_text(
            json.dumps(
                row(
                    "null-register",
                    "打开车窗",
                    [{"name": "open_window", "arguments": {}}],
                    register=None,
                    risk_tier="R0",
                ),
                ensure_ascii=False,
            )
            + "\n",
            encoding="utf-8",
        )
        write_manifest(manifest, [null_register])
        null_register_result = run_checker(manifest)
        if null_register_result.returncode != 65:
            failures.append(f"expected null register rc=65, got {null_register_result.returncode}")
        if "invalid explicit register metadata" not in null_register_result.stderr:
            failures.append("expected null register to fail as invalid explicit metadata")

    if failures:
        print("test_label_authority_conflicts FAILED", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1
    print("test_label_authority_conflicts=ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

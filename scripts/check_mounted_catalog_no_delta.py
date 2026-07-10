#!/usr/bin/env python3
"""CG-080: enforce the mounted baseline and executable rollback invariants."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Any

import yaml


EXIT_INPUT_ERROR = 65
EXIT_DELTA_VIOLATION = 66
DEFAULT_BASELINE_PATH = Path("contracts/c2-mounted-catalog-baseline.yaml")


class GuardInputError(ValueError):
    def __init__(self, code: str, detail: str) -> None:
        super().__init__(detail)
        self.code = code
        self.detail = detail


def sha256hex(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def mounted_catalog_sha(names: set[str]) -> str:
    payload = json.dumps(sorted(names), ensure_ascii=False, separators=(",", ":"))
    return sha256hex((payload + "\n").encode("utf-8"))


def load_current_mounted_from_swift(path: Path) -> tuple[set[str], str]:
    """Load mountedToolNames from DDomainMountedToolCatalog.swift source."""
    content = path.read_text(encoding="utf-8")
    mounted_match = re.search(
        r"public static let mountedToolNames: Set<String> = \[(.*?)\]",
        content,
        re.DOTALL,
    )
    if not mounted_match:
        raise GuardInputError(
            "mounted_catalog_parse_error",
            f"Could not find mountedToolNames in {path}",
        )

    names = set(re.findall(r'"([^"\n]+)"', mounted_match.group(1)))
    if not names:
        raise GuardInputError(
            "mounted_catalog_empty",
            f"mountedToolNames is empty in {path}",
        )
    return names, mounted_catalog_sha(names)


def _load_yaml_mapping(path: Path) -> dict[str, Any]:
    try:
        payload = yaml.safe_load(path.read_text(encoding="utf-8"))
    except (OSError, yaml.YAMLError) as exc:
        raise GuardInputError("baseline_yaml_invalid", f"{path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise GuardInputError("baseline_yaml_invalid", f"{path}: root must be a mapping")
    return payload


def load_baseline(path: Path) -> dict[str, Any]:
    """Load and internally reconcile the sole mounted baseline SSOT."""
    payload = _load_yaml_mapping(path)
    baseline = payload.get("baseline")
    rollback_guard = payload.get("rollback_guard")
    if not isinstance(baseline, dict) or not isinstance(rollback_guard, dict):
        raise GuardInputError(
            "baseline_schema_invalid",
            "baseline and rollback_guard must both be mappings",
        )

    raw_names = baseline.get("mounted_tool_names")
    if (
        not isinstance(raw_names, list)
        or not raw_names
        or any(not isinstance(name, str) or not name for name in raw_names)
        or len(set(raw_names)) != len(raw_names)
    ):
        raise GuardInputError(
            "baseline_mounted_set_invalid",
            "baseline.mounted_tool_names must be a non-empty unique string list",
        )
    names = set(raw_names)

    declared_sha = baseline.get("catalog_sha")
    computed_sha = mounted_catalog_sha(names)
    if declared_sha != computed_sha:
        raise GuardInputError(
            "baseline_catalog_sha_mismatch",
            f"declared={declared_sha!r} computed={computed_sha}",
        )

    if rollback_guard.get("affected_can_demo_after_rollback") is not False:
        raise GuardInputError(
            "rollback_policy_can_demo_invalid",
            "rollback_guard.affected_can_demo_after_rollback must be false",
        )
    required_artifacts = rollback_guard.get("preserve_artifacts")
    expected_artifacts = {"fallback_catalog", "fallback_probes"}
    if not isinstance(required_artifacts, list) or set(required_artifacts) != expected_artifacts:
        raise GuardInputError(
            "rollback_policy_artifacts_invalid",
            "rollback_guard.preserve_artifacts must contain fallback_catalog and fallback_probes",
        )

    return {
        "mounted_tool_names": names,
        "catalog_sha": declared_sha,
        "affected_can_demo_after_rollback": False,
        "preserve_artifacts": sorted(expected_artifacts),
    }


def load_rollback_state(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise GuardInputError("rollback_state_invalid", f"{path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise GuardInputError("rollback_state_invalid", f"{path}: root must be an object")
    return payload


def _artifact_pair_preserved(
    rollback_state: dict[str, Any],
    state_path: Path,
    artifact_key: str,
) -> tuple[bool, dict[str, Any]]:
    fallback_artifacts = rollback_state.get("fallback_artifacts")
    pair = fallback_artifacts.get(artifact_key) if isinstance(fallback_artifacts, dict) else None
    evidence: dict[str, Any] = {"artifact": artifact_key, "preserved": False}
    if not isinstance(pair, dict):
        evidence["reason"] = "artifact_pair_missing"
        return False, evidence

    paths: dict[str, Path] = {}
    for side in ("before", "after"):
        raw_path = pair.get(side)
        if not isinstance(raw_path, str) or not raw_path:
            evidence["reason"] = f"{side}_path_missing"
            return False, evidence
        path = Path(raw_path)
        paths[side] = path if path.is_absolute() else state_path.parent / path
        if not paths[side].is_file():
            evidence["reason"] = f"{side}_artifact_missing"
            evidence[f"{side}_path"] = str(paths[side])
            return False, evidence

    before_sha = sha256hex(paths["before"].read_bytes())
    after_sha = sha256hex(paths["after"].read_bytes())
    evidence.update(
        {
            "before_path": str(paths["before"]),
            "after_path": str(paths["after"]),
            "before_sha": before_sha,
            "after_sha": after_sha,
            "preserved": before_sha == after_sha,
        }
    )
    if before_sha != after_sha:
        evidence["reason"] = "artifact_digest_changed"
    return before_sha == after_sha, evidence


def check_rollback(
    rollback_state: dict[str, Any],
    state_path: Path,
    baseline: dict[str, Any],
) -> dict[str, Any]:
    violations: list[str] = []

    raw_before_mounted = rollback_state.get("mounted_tool_names_before")
    before_names = (
        set(raw_before_mounted) if isinstance(raw_before_mounted, list) else set()
    )
    raw_after_mounted = rollback_state.get("mounted_tool_names_after")
    restored_names = (
        set(raw_after_mounted) if isinstance(raw_after_mounted, list) else set()
    )
    mounted_delta_evidenced = bool(before_names - baseline["mounted_tool_names"])
    mounted_restored = restored_names == baseline["mounted_tool_names"]
    if not mounted_delta_evidenced:
        violations.append("rollback_mounted_delta_evidence_missing")
    if not mounted_restored:
        violations.append("rollback_mounted_not_restored")

    affected_cells = rollback_state.get("affected_cells")
    affected_cells = affected_cells if isinstance(affected_cells, list) else []
    can_demo_downgraded = bool(affected_cells) and all(
        isinstance(cell, dict)
        and isinstance(cell.get("cell_id"), str)
        and bool(cell.get("cell_id"))
        and cell.get("before_canDemo") is True
        and cell.get("after_canDemo") is False
        for cell in affected_cells
    )
    if not can_demo_downgraded:
        violations.append("rollback_can_demo_not_downgraded")

    artifact_evidence: dict[str, Any] = {}
    for artifact_key in ("catalog", "probes"):
        preserved, evidence = _artifact_pair_preserved(
            rollback_state,
            state_path,
            artifact_key,
        )
        artifact_evidence[artifact_key] = evidence
        if not preserved:
            violations.append(f"rollback_fallback_{artifact_key}_not_preserved")

    return {
        "rollback_status": "FAIL" if violations else "PASS",
        "rollback_violation_codes": violations,
        "mounted_delta_evidenced": mounted_delta_evidenced,
        "before_mounted_tool_names": sorted(before_names),
        "mounted_restored": mounted_restored,
        "restored_mounted_tool_names": sorted(restored_names),
        "affected_can_demo_downgraded": can_demo_downgraded,
        "affected_cell_count": len(affected_cells),
        "fallback_artifact_evidence": artifact_evidence,
    }


def check(
    current_names: set[str],
    current_sha: str,
    baseline: dict[str, Any],
    rollback_state: dict[str, Any] | None = None,
    rollback_state_path: Path | None = None,
) -> dict[str, Any]:
    baseline_names = baseline["mounted_tool_names"]
    added = current_names - baseline_names
    removed = baseline_names - current_names
    sha_ok = current_sha == baseline["catalog_sha"]
    violation_codes: list[str] = []
    if added or removed:
        violation_codes.append("mounted_catalog_delta")
    if not sha_ok:
        violation_codes.append("mounted_catalog_digest_mismatch")

    report: dict[str, Any] = {
        "status": "FAIL" if violation_codes else "PASS",
        "violation_codes": violation_codes,
        "current_mounted_tool_names": sorted(current_names),
        "baseline_mounted_tool_names": sorted(baseline_names),
        "current_sha": current_sha,
        "baseline_sha": baseline["catalog_sha"],
        "sha_match": sha_ok,
        "added": sorted(added),
        "removed": sorted(removed),
        "rollback_status": "NOT_CHECKED",
    }

    if rollback_state is not None and rollback_state_path is not None:
        rollback_report = check_rollback(rollback_state, rollback_state_path, baseline)
        report.update(rollback_report)
        if rollback_report["rollback_status"] == "FAIL":
            report["status"] = "FAIL"
            report["violation_codes"].extend(rollback_report["rollback_violation_codes"])
    return report


def _print_input_error(exc: GuardInputError) -> int:
    print(
        json.dumps(
            {"status": "ERROR", "error_code": exc.code, "detail": exc.detail},
            ensure_ascii=False,
            indent=2,
            sort_keys=True,
        )
    )
    print(f"error: {exc.code}: {exc.detail}", file=sys.stderr)
    return EXIT_INPUT_ERROR


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--baseline-path",
        type=Path,
        default=DEFAULT_BASELINE_PATH,
        help="Sole mounted baseline SSOT YAML path.",
    )
    parser.add_argument(
        "--swift-path",
        type=Path,
        default=Path("Core/Contracts/DDomainMountedToolCatalog.swift"),
        help="Path to DDomainMountedToolCatalog.swift.",
    )
    parser.add_argument(
        "--rollback-state",
        type=Path,
        help="Optional executable rollback evidence JSON.",
    )
    parser.add_argument("--output", type=Path, help="Optional JSON report path.")
    args = parser.parse_args()

    try:
        if not args.baseline_path.is_file():
            raise GuardInputError(
                "baseline_file_missing",
                f"Baseline file not found: {args.baseline_path}",
            )
        if not args.swift_path.is_file():
            raise GuardInputError(
                "mounted_catalog_file_missing",
                f"Swift file not found: {args.swift_path}",
            )
        if args.rollback_state is not None and not args.rollback_state.is_file():
            raise GuardInputError(
                "rollback_state_file_missing",
                f"Rollback state file not found: {args.rollback_state}",
            )

        baseline = load_baseline(args.baseline_path)
        current_names, current_sha = load_current_mounted_from_swift(args.swift_path)
        rollback_state = (
            load_rollback_state(args.rollback_state)
            if args.rollback_state is not None
            else None
        )
    except GuardInputError as exc:
        return _print_input_error(exc)

    report = check(
        current_names,
        current_sha,
        baseline,
        rollback_state,
        args.rollback_state,
    )
    text = json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(text + "\n", encoding="utf-8")
    print(text)

    if report["status"] == "FAIL":
        print("❌ CG-080 VIOLATION", file=sys.stderr)
        return EXIT_DELTA_VIOLATION
    print("✅ CG-080 PASSED", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

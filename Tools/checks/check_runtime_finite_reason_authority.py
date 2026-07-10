#!/usr/bin/env python3
"""Fail-close runtime finiteReason producers and consumers against the T0 registry."""

from __future__ import annotations

import argparse
import ast
import json
import re
import sys
from pathlib import Path
from typing import Any


REGISTRY = Path("openspec/changes/add-c1-demo-capability-governance/ownership-map.yaml")
SURFACES = (
    Path("Core/LLM/DDomainToolPlanFailure.swift"),
    Path("Core/Execution/DemoRuntimeSessionRunner.swift"),
    Path("Core/Execution/DemoRuntimePartialPlan.swift"),
    Path("Core/Execution/FallbackContext.swift"),
    Path("Core/Trace/TraceLogger.swift"),
    Path("Core/Presentation/RuntimePresentationReasonAuthority.generated.swift"),
    Path("Tests/MAformacCoreTests/RuntimeNoMutationProbeTests.swift"),
    Path("Tools/checks/check_runtime_no_mutation_receipts.py"),
)
RUNTIME_LITERAL_SURFACES = SURFACES[:5]
TRACE_TYPED_SURFACES = (
    Path("Core/Trace/TraceLogger.swift"),
    Path("Core/Execution/DemoRuntimeSessionRunner.swift"),
    Path("Core/Execution/DemoRuntimePartialPlan.swift"),
)
LOCKED_DDOMAIN_MAPPING = {
    "parse_failed": "unsupported_tool_plan",
    "name_rejected": "name_rejected",
    "ir_unclassified": "unsupported_tool_plan",
    "bridge_failed": "unsupported_tool_plan",
}
LOCKED_DECODE_FAILURE_KINDS = (
    "parse_failed",
    "name_rejected",
    "ir_unclassified",
    "bridge_failed",
)
DIAGNOSTIC_ONLY_KINDS = {"parse_failed", "ir_unclassified", "bridge_failed"}


def violation(code: str, path: Path, detail: str, line: int | None = None) -> dict[str, Any]:
    item: dict[str, Any] = {"code": code, "path": str(path), "detail": detail}
    if line is not None:
        item["line"] = line
    return item


def read_text(repo_root: Path, relative: Path, violations: list[dict[str, Any]]) -> str:
    path = repo_root / relative
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        violations.append(violation("E_REQUIRED_SURFACE_MISSING", relative, "required surface is missing"))
        return ""


def extract_braced_block(text: str, marker: str) -> str:
    start = text.find(marker)
    if start < 0:
        return ""
    open_brace = text.find("{", start)
    if open_brace < 0:
        return ""
    depth = 0
    for index in range(open_brace, len(text)):
        if text[index] == "{":
            depth += 1
        elif text[index] == "}":
            depth -= 1
            if depth == 0:
                return text[open_brace + 1 : index]
    return ""


def parse_swift_enum(text: str, enum_name: str) -> list[tuple[str, str]]:
    body = extract_braced_block(text, f"enum {enum_name}")
    return re.findall(r'\bcase\s+([A-Za-z][A-Za-z0-9]*)\s*=\s*"([^"]+)"', body)


def parse_switch_returns(text: str, property_name: str) -> dict[str, str]:
    body = extract_braced_block(text, f"var {property_name}")
    pairs = re.findall(
        r"case\s+\.([A-Za-z][A-Za-z0-9]*)(?:\([^\n]*\))?\s*:\s*return\s+\.([A-Za-z][A-Za-z0-9]*)",
        body,
    )
    return dict(pairs)


def parse_expected_probe_map(text: str) -> dict[str, str]:
    match = re.search(r"EXPECTED_FINITE_REASONS\s*=\s*(\{.*?\n\})", text, flags=re.DOTALL)
    if match is None:
        return {}
    value = ast.literal_eval(match.group(1))
    return value if isinstance(value, dict) else {}


def check(repo_root: Path) -> dict[str, Any]:
    violations: list[dict[str, Any]] = []
    texts = {relative: read_text(repo_root, relative, violations) for relative in SURFACES}
    registry_text = read_text(repo_root, REGISTRY, violations)
    try:
        registry = json.loads(registry_text)
    except (json.JSONDecodeError, TypeError) as exc:
        registry = {}
        violations.append(violation("E_T0_REGISTRY_INVALID", REGISTRY, str(exc)))

    raw_t0 = registry.get("finiteReason_enum", [])
    t0_values = raw_t0 if isinstance(raw_t0, list) and all(isinstance(v, str) for v in raw_t0) else []
    t0_set = set(t0_values)
    projections = registry.get("finiteReason_projections", [])
    projection_values = [
        item.get("finiteReason")
        for item in projections
        if isinstance(item, dict) and isinstance(item.get("finiteReason"), str)
    ] if isinstance(projections, list) else []
    if len(t0_values) != 10 or len(t0_set) != 10:
        violations.append(
            violation(
                "E_T0_LOCKED_SET_CHANGED",
                REGISTRY,
                f"expected exactly 10 unique T0 members, got {len(t0_values)} values/{len(t0_set)} unique",
            )
        )
    if sorted(projection_values) != sorted(t0_values):
        violations.append(
            violation("E_T0_PROJECTION_DRIFT", REGISTRY, "finiteReason projections do not exactly cover T0")
        )

    generated_path = SURFACES[5]
    generated_pairs = parse_swift_enum(texts[generated_path], "RuntimeFiniteReason")
    generated_case_to_raw = dict(generated_pairs)
    if [raw for _, raw in generated_pairs] != t0_values:
        violations.append(
            violation(
                "E_GENERATED_RUNTIME_REASON_DRIFT",
                generated_path,
                "generated RuntimeFiniteReason does not match registry order/membership",
            )
        )

    ddomain_path = SURFACES[0]
    ddomain_text = texts[ddomain_path]
    diagnostic_pairs = parse_swift_enum(ddomain_text, "DDomainDecodeFailureKind")
    diagnostic_case_to_raw = dict(diagnostic_pairs)
    decode_failure_kinds = [raw for _, raw in diagnostic_pairs]
    finite_case_mapping = parse_switch_returns(ddomain_text, "finiteReason")
    diagnostic_case_mapping = parse_switch_returns(ddomain_text, "decodeFailureKind")
    production_mappings: dict[str, str] = {}
    for failure_case, diagnostic_case in diagnostic_case_mapping.items():
        diagnostic_raw = diagnostic_case_to_raw.get(diagnostic_case)
        finite_case = finite_case_mapping.get(failure_case)
        finite_raw = generated_case_to_raw.get(finite_case or "")
        if diagnostic_raw and finite_raw:
            production_mappings[diagnostic_raw] = finite_raw
    if production_mappings != LOCKED_DDOMAIN_MAPPING:
        violations.append(
            violation(
                "E_DDOMAIN_FAILURE_MAPPING_DRIFT",
                ddomain_path,
                f"locked mapping mismatch: {production_mappings}",
            )
        )
    if tuple(decode_failure_kinds) != LOCKED_DECODE_FAILURE_KINDS:
        violations.append(
            violation(
                "E_DECODE_FAILURE_KIND_DRIFT",
                ddomain_path,
                f"unexpected decode failure kinds: {decode_failure_kinds}",
            )
        )

    for relative in RUNTIME_LITERAL_SURFACES:
        for line_number, line in enumerate(texts[relative].splitlines(), start=1):
            if "finiteReason" not in line:
                continue
            for literal in re.findall(r'"([a-z][a-z0-9_]+)"', line):
                if literal == "finite_reason":
                    continue
                if literal in t0_set:
                    continue
                code = (
                    "E_DECODE_FAILURE_KIND_AS_FINITE_REASON"
                    if literal in DIAGNOSTIC_ONLY_KINDS
                    else "E_RUNTIME_FINITE_REASON_OUTSIDE_T0"
                )
                violations.append(violation(code, relative, f"finiteReason literal is not T0: {literal}", line_number))

    fallback_path = SURFACES[3]
    fallback_text = texts[fallback_path]
    for pattern in (r"governanceReason\s*\(\s*for", r"switch\s+finiteReason"):
        match = re.search(pattern, fallback_text)
        if match:
            line = fallback_text.count("\n", 0, match.start()) + 1
            violations.append(
                violation(
                    "E_FALLBACK_SHADOW_REASON_SWITCH",
                    fallback_path,
                    "FallbackContext must consume generated authority without a shadow reason switch",
                    line,
                )
            )

    untyped_pattern = re.compile(r"\b(?:var\s+|let\s+)?finiteReason\s*:\s*String\??")
    for relative in TRACE_TYPED_SURFACES:
        for match in untyped_pattern.finditer(texts[relative]):
            line = texts[relative].count("\n", 0, match.start()) + 1
            violations.append(
                violation("E_TRACE_FINITE_REASON_UNTYPED", relative, match.group(0), line)
            )

    probe_checker_path = SURFACES[7]
    expected_probe_reasons = parse_expected_probe_map(texts[probe_checker_path])
    for bucket, reason in expected_probe_reasons.items():
        if reason not in t0_set:
            violations.append(
                violation(
                    "E_PROBE_FINITE_REASON_OUTSIDE_T0",
                    probe_checker_path,
                    f"{bucket} expects non-T0 finiteReason {reason}",
                )
            )

    swift_probe_path = SURFACES[6]
    for line_number, line in enumerate(texts[swift_probe_path].splitlines(), start=1):
        match = re.search(r"finiteReason:\s*\"([^\"]+)\"", line)
        if match and match.group(1) not in t0_set:
            violations.append(
                violation(
                    "E_PROBE_FINITE_REASON_OUTSIDE_T0",
                    swift_probe_path,
                    f"probe emits non-T0 finiteReason {match.group(1)}",
                    line_number,
                )
            )

    deduplicated: list[dict[str, Any]] = []
    seen: set[tuple[Any, ...]] = set()
    for item in violations:
        key = (item["code"], item["path"], item.get("line"), item["detail"])
        if key not in seen:
            seen.add(key)
            deduplicated.append(item)
    return {
        "status": "PASS" if not deduplicated else "FAIL",
        "t0_count": len(t0_values),
        "t0_values": t0_values,
        "production_mappings": production_mappings,
        "decode_failure_kinds": decode_failure_kinds,
        "scan_coverage": [str(path) for path in SURFACES],
        "violations": deduplicated,
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--receipt", type=Path, required=True)
    args = parser.parse_args(argv)

    report = check(args.repo_root.resolve())
    receipt = args.receipt if args.receipt.is_absolute() else args.repo_root / args.receipt
    receipt.parent.mkdir(parents=True, exist_ok=True)
    receipt.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    stream = sys.stdout if report["status"] == "PASS" else sys.stderr
    print(json.dumps(report, ensure_ascii=False, sort_keys=True), file=stream)
    return 0 if report["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())

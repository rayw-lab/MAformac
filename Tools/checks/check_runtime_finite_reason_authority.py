#!/usr/bin/env python3
"""Fail-close known lexical finiteReason patterns against the T0 registry.

Scope: known_pattern_lexical_layer, not semantically complete. Semantic mapping
drift is owned by hard-coded Swift behavior gates, not by this lexical scanner.

Residual blind spots accepted by SPEC AMENDMENT-1:
- renamed probe constants are not discovered structurally;
- qualified or typealiased String declarations can evade the typed-field regex;
- arbitrary Swift dataflow and scope resolution remain out of scope;
- multiline string code examples may conservatively false-positive.
- the fixed nine-surface allowlist does not auto-discover future producers or consumers.
"""

from __future__ import annotations

import argparse
import ast
import json
import re
import sys
from pathlib import Path
from typing import Any


REGISTRY = Path("openspec/changes/add-c1-demo-capability-governance/ownership-map.yaml")
DDOMAIN_SURFACE = Path("Core/LLM/DDomainToolPlanFailure.swift")
RUNNER_SURFACE = Path("Core/Execution/DemoRuntimeSessionRunner.swift")
PARTIAL_PLAN_SURFACE = Path("Core/Execution/DemoRuntimePartialPlan.swift")
FALLBACK_SURFACE = Path("Core/Execution/FallbackContext.swift")
TRACE_SURFACE = Path("Core/Trace/TraceLogger.swift")
GENERATED_AUTHORITY_SURFACE = Path("Core/Presentation/RuntimePresentationReasonAuthority.generated.swift")
PRESENTATION_BRIDGE_SURFACE = Path("Core/Presentation/RuntimePresentationBridge.swift")
SWIFT_PROBE_SURFACE = Path("Tests/MAformacCoreTests/RuntimeNoMutationProbeTests.swift")
PROBE_CHECKER_SURFACE = Path("Tools/checks/check_runtime_no_mutation_receipts.py")
BEHAVIOR_GATE_SURFACE = Path("Tests/MAformacCoreTests/RuntimeFiniteReasonAuthorityTests.swift")
SURFACES = (
    DDOMAIN_SURFACE,
    RUNNER_SURFACE,
    PARTIAL_PLAN_SURFACE,
    FALLBACK_SURFACE,
    TRACE_SURFACE,
    GENERATED_AUTHORITY_SURFACE,
    PRESENTATION_BRIDGE_SURFACE,
    SWIFT_PROBE_SURFACE,
    PROBE_CHECKER_SURFACE,
)
RUNTIME_LITERAL_SURFACES = (
    DDOMAIN_SURFACE,
    RUNNER_SURFACE,
    PARTIAL_PLAN_SURFACE,
    FALLBACK_SURFACE,
    TRACE_SURFACE,
    PRESENTATION_BRIDGE_SURFACE,
)
TRACE_TYPED_SURFACES = (
    TRACE_SURFACE,
    RUNNER_SURFACE,
    PARTIAL_PLAN_SURFACE,
    PRESENTATION_BRIDGE_SURFACE,
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
CHECKER_SCOPE = "known_pattern_lexical_layer"
SEMANTIC_COMPLETENESS = "not_semantically_complete"
RESIDUAL_BLIND_SPOTS = [
    "renamed_probe_constants",
    "qualified_or_typealiased_string_types",
    "arbitrary_swift_dataflow_and_scope_resolution",
    "multiline_string_code_examples_may_false_positive",
    "fixed_nine_surface_allowlist_does_not_auto_discover_future_producers_or_consumers",
]
BEHAVIOR_GATE_METHODS = {
    "RuntimeFiniteReasonAuthorityTests.testFallbackResolutionMatchesHardcodedTenReasonScriptTable":
        "testFallbackResolutionMatchesHardcodedTenReasonScriptTable",
    "RuntimeFiniteReasonAuthorityTests.testTraceRoundTripsHardcodedTenFiniteReasonsEndToEnd":
        "testTraceRoundTripsHardcodedTenFiniteReasonsEndToEnd",
    "RuntimeFiniteReasonAuthorityTests.testDiagnosticFailuresTraverseProductionRunnerAndRedactPresentationTrace":
        "testDiagnosticFailuresTraverseProductionRunnerAndRedactPresentationTrace",
}
BEHAVIOR_GATES = list(BEHAVIOR_GATE_METHODS)


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


def mask_swift_comments(text: str) -> str:
    """Replace Swift comments with spaces while preserving strings and line numbers."""
    result = list(text)
    index = 0
    state = "code"
    block_depth = 0
    while index < len(text):
        pair = text[index : index + 2]
        triple = text[index : index + 3]
        if state == "code":
            if pair == "//":
                result[index] = result[index + 1] = " "
                index += 2
                state = "line_comment"
                continue
            if pair == "/*":
                result[index] = result[index + 1] = " "
                index += 2
                state = "block_comment"
                block_depth = 1
                continue
            if triple == '\"\"\"':
                index += 3
                state = "multiline_string"
                continue
            if text[index] == '"':
                index += 1
                state = "string"
                continue
        elif state == "line_comment":
            if text[index] == "\n":
                state = "code"
            else:
                result[index] = " "
            index += 1
            continue
        elif state == "block_comment":
            if pair == "/*":
                result[index] = result[index + 1] = " "
                block_depth += 1
                index += 2
                continue
            if pair == "*/":
                result[index] = result[index + 1] = " "
                block_depth -= 1
                index += 2
                if block_depth == 0:
                    state = "code"
                continue
            if text[index] != "\n":
                result[index] = " "
            index += 1
            continue
        elif state == "string":
            if text[index] == "\\":
                index += 2
                continue
            if text[index] == '"':
                state = "code"
        elif state == "multiline_string" and triple == '\"\"\"':
            index += 3
            state = "code"
            continue
        index += 1
    return "".join(result)


def mask_swift_strings(text: str) -> str:
    """Mask Swift string literals after comments have been removed."""
    result = list(text)
    index = 0
    state = "code"
    while index < len(text):
        triple = text[index : index + 3]
        if state == "code":
            if triple == '\"\"\"':
                result[index : index + 3] = [" ", " ", " "]
                index += 3
                state = "multiline_string"
                continue
            if text[index] == '"':
                result[index] = " "
                index += 1
                state = "string"
                continue
        elif state == "string":
            if text[index] == "\\":
                result[index] = " "
                if index + 1 < len(text) and text[index + 1] != "\n":
                    result[index + 1] = " "
                index += 2
                continue
            if text[index] == '"':
                result[index] = " "
                state = "code"
            elif text[index] != "\n":
                result[index] = " "
            index += 1
            continue
        elif state == "multiline_string":
            if triple == '\"\"\"':
                result[index : index + 3] = [" ", " ", " "]
                index += 3
                state = "code"
                continue
            if text[index] != "\n":
                result[index] = " "
            index += 1
            continue
        index += 1
    return "".join(result)


def swift_finite_reason_literals(text: str) -> list[tuple[str, int]]:
    """Find literals reaching finiteReason through the checker-known lexical patterns."""
    code = mask_swift_comments(text)
    findings: list[tuple[str, int]] = []
    direct_patterns = (
        re.compile(r'\bfiniteReason\s*:\s*"(?P<literal>[a-z][a-z0-9_]+)"'),
        re.compile(
            r'\bfiniteReason\s*(?::\s*[A-Za-z_][A-Za-z0-9_.<>\[\], ?!]*)?'
            r'\s*=\s*"(?P<literal>[a-z][a-z0-9_]+)"'
        ),
    )
    for pattern in direct_patterns:
        for match in pattern.finditer(code):
            findings.append((match.group("literal"), code.count("\n", 0, match.start()) + 1))

    string_bindings: dict[str, tuple[str, int]] = {}
    for match in re.finditer(
        r'\b(?:let|var)\s+([A-Za-z_][A-Za-z0-9_]*)'
        r'\s*(?::\s*[A-Za-z_][A-Za-z0-9_.<>\[\], ?!]*)?'
        r'\s*=\s*"([a-z][a-z0-9_]+)"',
        code,
    ):
        string_bindings[match.group(1)] = (
            match.group(2),
            code.count("\n", 0, match.start()) + 1,
        )

    aliases: dict[str, str] = {}
    structural = mask_swift_strings(code)
    for match in re.finditer(
        r'\b(?:let|var)\s+([A-Za-z_][A-Za-z0-9_]*)'
        r'\s*(?::[^=\n]+)?=\s*\(?\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)?',
        structural,
    ):
        aliases[match.group(1)] = match.group(2)

    collection_bindings: dict[str, list[tuple[str, int]]] = {}
    for match in re.finditer(
        r'\b(?:let|var)\s+([A-Za-z_][A-Za-z0-9_]*)'
        r'\s*(?::[^=\n]+)?=\s*\[(?P<body>[^\]]*)\]',
        structural,
        flags=re.DOTALL,
    ):
        original_body = code[match.start("body") : match.end("body")]
        values = [
            (
                literal.group(1),
                code.count("\n", 0, match.start("body") + literal.start()) + 1,
            )
            for literal in re.finditer(r'"([a-z][a-z0-9_]+)"', original_body)
        ]
        if values:
            collection_bindings[match.group(1)] = values

    def resolve_literal(identifier: str) -> tuple[str, int] | None:
        seen: set[str] = set()
        while identifier not in seen:
            seen.add(identifier)
            if identifier in string_bindings:
                return string_bindings[identifier]
            next_identifier = aliases.get(identifier)
            if next_identifier is None:
                return None
            identifier = next_identifier
        return None

    def resolve_collection(identifier: str) -> list[tuple[str, int]]:
        seen: set[str] = set()
        while identifier not in seen:
            seen.add(identifier)
            if identifier in collection_bindings:
                return collection_bindings[identifier]
            next_identifier = aliases.get(identifier)
            if next_identifier is None:
                return []
            identifier = next_identifier
        return []

    alias_sinks = (
        re.compile(r'\bfiniteReason\s*=\s*([A-Za-z_][A-Za-z0-9_]*)'),
        re.compile(r'\bfiniteReason\s*:\s*([A-Za-z_][A-Za-z0-9_]*)'),
    )
    for pattern in alias_sinks:
        for match in pattern.finditer(structural):
            resolved = resolve_literal(match.group(1))
            if resolved is not None:
                literal, _ = resolved
                findings.append((literal, structural.count("\n", 0, match.start()) + 1))

    indexed_sinks = (
        re.compile(r'\bfiniteReason\s*=\s*([A-Za-z_][A-Za-z0-9_]*)\s*\[[^\]]+\]'),
        re.compile(r'\bfiniteReason\s*:\s*([A-Za-z_][A-Za-z0-9_]*)\s*\[[^\]]+\]'),
    )
    for pattern in indexed_sinks:
        for match in pattern.finditer(structural):
            for literal, _ in resolve_collection(match.group(1)):
                findings.append((literal, structural.count("\n", 0, match.start()) + 1))

    return sorted(set(findings), key=lambda item: (item[1], item[0]))


def fallback_shadow_switches(text: str) -> list[tuple[int, str]]:
    """Find checker-known local finiteReason remapping patterns."""
    code = mask_swift_comments(text)
    structural = mask_swift_strings(code)
    findings: list[tuple[int, str]] = []

    aliases: dict[str, str] = {}
    for match in re.finditer(
        r'\b(?:let|var)\s+([A-Za-z_][A-Za-z0-9_]*)'
        r'\s*(?::[^=\n]+)?=\s*\(?\s*([A-Za-z_][A-Za-z0-9_.]*)\s*\)?',
        structural,
    ):
        aliases[match.group(1)] = match.group(2)

    def resolves_to_finite_reason(subject: str) -> bool:
        if subject == "finiteReason" or subject.endswith(".finiteReason"):
            return True
        seen: set[str] = set()
        while subject not in seen:
            seen.add(subject)
            next_subject = aliases.get(subject)
            if next_subject is None:
                return False
            if next_subject == "finiteReason" or next_subject.endswith(".finiteReason"):
                return True
            subject = next_subject
        return False

    for match in re.finditer(
        r'\{\s*(?:\(\s*)?(?P<parameter>[A-Za-z_][A-Za-z0-9_]*)'
        r'(?:\s*:\s*[^)]+)?(?:\s*\))?\s+in\b'
        r'(?P<body>.*?)\}\s*\(\s*(?P<argument>[A-Za-z_][A-Za-z0-9_.]*)\s*\)',
        structural,
        flags=re.DOTALL,
    ):
        parameter = match.group("parameter")
        if resolves_to_finite_reason(match.group("argument")) and re.search(
            rf'\bswitch\s*(?:\(\s*)?{re.escape(parameter)}(?:\s*\))?\s*\{{',
            match.group("body"),
        ):
            findings.append(
                (
                    structural.count("\n", 0, match.start()) + 1,
                    f"invoked closure parameter {parameter} remaps {match.group('argument')}",
                )
            )

    for match in re.finditer(
        r'\bswitch\s*(?:\(\s*)?([A-Za-z_][A-Za-z0-9_.]*)(?:\s*\))?\s*\{',
        structural,
    ):
        if resolves_to_finite_reason(match.group(1)):
            findings.append(
                (
                    structural.count("\n", 0, match.start()) + 1,
                    f"local switch remaps {match.group(1)}",
                )
            )

    for match in re.finditer(
        r'\bfunc\s+([A-Za-z_][A-Za-z0-9_]*)\s*\([^)]*\)'
        r'\s*(?:async\s+)?(?:throws\s+)?->\s*FallbackGovernanceReason\s*\??',
        structural,
        flags=re.DOTALL,
    ):
        findings.append(
            (
                structural.count("\n", 0, match.start()) + 1,
                f"local helper {match.group(1)} returns FallbackGovernanceReason",
            )
        )

    return sorted(set(findings), key=lambda item: (item[0], item[1]))


def check(repo_root: Path) -> dict[str, Any]:
    violations: list[dict[str, Any]] = []
    texts = {relative: read_text(repo_root, relative, violations) for relative in SURFACES}
    behavior_gate_text = read_text(repo_root, BEHAVIOR_GATE_SURFACE, violations)
    behavior_gate_code = mask_swift_strings(mask_swift_comments(behavior_gate_text))
    behavior_gate_presence: dict[str, bool] = {}
    for gate, method in BEHAVIOR_GATE_METHODS.items():
        declaration = re.compile(rf"(?m)^[ \t]*func[ \t]+{re.escape(method)}[ \t]*\(")
        count = len(declaration.findall(behavior_gate_code))
        behavior_gate_presence[gate] = count == 1
        if count != 1:
            violations.append(
                violation(
                    "E_REQUIRED_BEHAVIOR_GATE_MISSING",
                    BEHAVIOR_GATE_SURFACE,
                    f"expected exactly one func {method}( declaration, found {count}",
                )
            )
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

    generated_path = GENERATED_AUTHORITY_SURFACE
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

    ddomain_path = DDOMAIN_SURFACE
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
        for literal, line_number in swift_finite_reason_literals(texts[relative]):
            if literal == "finite_reason" or literal in t0_set:
                continue
            code = (
                "E_DECODE_FAILURE_KIND_AS_FINITE_REASON"
                if literal in DIAGNOSTIC_ONLY_KINDS
                else "E_RUNTIME_FINITE_REASON_OUTSIDE_T0"
            )
            violations.append(violation(code, relative, f"finiteReason literal is not T0: {literal}", line_number))

    fallback_path = FALLBACK_SURFACE
    fallback_text = texts[fallback_path]
    for line, detail in fallback_shadow_switches(fallback_text):
        violations.append(
            violation(
                "E_FALLBACK_SHADOW_REASON_SWITCH",
                fallback_path,
                detail,
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

    probe_checker_path = PROBE_CHECKER_SURFACE
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

    swift_probe_path = SWIFT_PROBE_SURFACE
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
        "scope": CHECKER_SCOPE,
        "semantic_completeness": SEMANTIC_COMPLETENESS,
        "residual_blind_spots": RESIDUAL_BLIND_SPOTS,
        "behavior_gates": BEHAVIOR_GATES,
        "behavior_gate_presence": behavior_gate_presence,
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

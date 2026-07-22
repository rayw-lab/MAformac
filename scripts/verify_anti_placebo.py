#!/usr/bin/env python3
"""对事实锚、进度表述和真实产品 E2E 门禁做防安慰剂检查。"""

from __future__ import annotations

import re
import sys
from pathlib import Path


PROGRESS_WORDS = re.compile(r"进度|完成度|进展|completion|progress", re.IGNORECASE)
FACT_ANCHORS = (
    "产品当前正向目录=12 个评审入口",
    "App 仍未接模型",
    "actionDemoProven=0/120",
)
PERCENT_PROGRESS = re.compile(r"\d+\s*%")
PERCENT_CONTEXT = re.compile(r"完成|进度|进展")
EXCLUDED_DOC_FILES = {"lessons-learned.md", "ACTIVE-LESSONS.md"}


def document_paths(root: Path):
    """Only traverse active progress reports, never archives or reference repos."""
    docs = root / "docs"
    if not docs.is_dir():
        return
    current = docs / "CURRENT.md"
    if current.is_file():
        yield current
    governance = docs / "governance"
    if governance.is_dir():
        for path in sorted(governance.rglob("*.md")):
            if path.name not in EXCLUDED_DOC_FILES:
                yield path
    report_pattern = re.compile(r"progress|status|report", re.IGNORECASE)
    historical_dirs = {
        "governance", "research", "war-room", "handoffs", "commander-log",
        "design", "dispatches", "loop-competition", "operators", "project",
        "c5-recovery-2026-06-22", "c5-training-readiness-grill",
        "grill-tournament", "grill-checklist", "historical", "roadmaps",
        "second-review-2026-06-17", "superpowers", "repo-intelligence",
    }
    for path in sorted(docs.rglob("*.md")):
        rel_parts = path.relative_to(docs).parts
        if len(rel_parts) == 1 and rel_parts[0] == "CURRENT.md":
            continue
        if rel_parts[0] in historical_dirs:
            continue
        if report_pattern.search(path.name) and path.name not in EXCLUDED_DOC_FILES:
            yield path


def check_fact_anchors(root: Path) -> list[str]:
    """Require current progress reports to retain at least one product-truth anchor."""
    failures: list[str] = []
    for path in document_paths(root):
        text = path.read_text(encoding="utf-8")
        if PROGRESS_WORDS.search(text) and not any(anchor in text for anchor in FACT_ANCHORS):
            failures.append(str(path.relative_to(root)))
    return failures


def check_percentage_progress(root: Path) -> list[str]:
    """Reject percentage-complete language in active status/report documents."""
    docs = root / "docs"
    failures: list[str] = []
    if not docs.is_dir():
        return failures
    for path in sorted(docs.rglob("*.md")):
        if not any(token in path.name.lower() for token in ("report", "status", "progress")):
            continue
        lines = path.read_text(encoding="utf-8").splitlines()
        for index, line in enumerate(lines):
            if not PERCENT_PROGRESS.search(line):
                continue
            context = "\n".join(lines[index : index + 3])
            if PERCENT_CONTEXT.search(context):
                failures.append(str(path.relative_to(root)))
                break
    return failures


def _workflow_invokes_make_verify_e2e(workflow_text: str) -> bool:
    """Return whether a workflow step exactly executes ``make verify-e2e``."""
    return bool(
        re.search(
            r"(?m)^\s*run:\s*make\s+verify-e2e\s*(?:#.*)?$",
            workflow_text,
        )
    )


def check_verify_e2e(root: Path) -> list[str]:
    """检查 verify-e2e target 存在且工作流确实调用该 target。"""
    makefile = root / "Makefile"
    if not makefile.exists():
        return ["Makefile missing"]
    makefile_text = makefile.read_text(encoding="utf-8")
    if "verify-e2e:" not in makefile_text:
        return ["verify-e2e target missing from Makefile"]

    workflow = root / ".github" / "workflows" / "verify.yml"
    if not workflow.is_file() or not _workflow_invokes_make_verify_e2e(
        workflow.read_text(encoding="utf-8")
    ):
        return [".github/workflows/verify.yml"]
    return []


# ---- WP2-1 / G7 Anti-Placebo Product Gate Checker ----

# File-wide structural anchors (Harness / UI projection). Customer-path
# anchors are checked per Make-batch body scope — file-wide wash is not enough.
FILE_WIDE_REQUIRED_ANCHORS = [
    r"DemoSliceRoute\(",
    r"VehicleCardDisplay\.displays",
]

# Default per-batch customer-path anchors (aggregate of all funcs under a prefix).
DEFAULT_BATCH_BODY_ANCHORS = [
    (r"\.route\(text:", ".route(text:)"),
    (r"runnerCallCount", "runnerCallCount"),
    (r"\.store\b|store\.cell\b", "store"),
    (r"readbacks", "readbacks"),
    (r"mutationCount", "mutationCount"),
]

# Specialized batches: risk fail-closed has no payload.readbacks; receipt
# focuses on assembler-outside-runner facts (still needs route + store fence).
BATCH_BODY_ANCHOR_OVERRIDES: dict[str, list[tuple[str, str]]] = {
    "testG3_window": [
        (r"\.route\(text:", ".route(text:)"),
        (r"runnerCallCount", "runnerCallCount"),
        (r"\.store\b|store\.cell\b", "store"),
        (r"currentRevision|beforeRevision|revisionBefore", "revision-fence"),
    ],
    "testG7_receipt_": [
        (r"\.route\(text:", ".route(text:)"),
        (r"\.store\b|store\.cell\b", "store"),
        (r"mutationCount", "mutationCount"),
        (r"RuntimeTurnReceiptAssembler|assembleAndWrite", "receipt-assembler"),
    ],
}

# Required test name prefixes (three WP21 batches)
WP21_REQUIRED_TEST_PREFIXES = [
    "testWP21BatchA_",
    "testWP21BatchB_",
    "testWP21BatchC_",
]

PRODUCT_BEHAVIOR_TARGET = "verify-e2e-product-behavior"
PRODUCT_BEHAVIOR_FILTER = "DemoSliceProductBehaviorGateTests"
EXACT_RUNNER = "Tools/checks/run_swift_test_exact.py"

WP21_TARGETS = {
    "verify-e2e-wp21-window": "testWP21BatchA_",
    "verify-e2e-wp21-ambient": "testWP21BatchB_",
    "verify-e2e-wp21-seat": "testWP21BatchC_",
}

# G7 knife1/2 lock table — must stay synced with Makefile exact-filter targets.
# RISK COUPLING: verify-e2e-risk → testG3_window (legacy G3 window risk gate;
# NOT testG7_risk_). Renaming requires Makefile + this table + docs together.
G7_TARGETS = {
    "verify-e2e-row167": "testG3_row167_",
    "verify-e2e-query": "testG7_query_",
    "verify-e2e-risk": "testG3_window",
    "verify-e2e-replay": "testG7_replay_",
    "verify-e2e-cancel": "testG7_cancel_",
    "verify-e2e-receipt": "testG7_receipt_",
}

G7_RISK_FILTER_COUPLING = (
    "verify-e2e-risk filter is locked to DemoSliceProductBehaviorGateTests/"
    "testG3_window (legacy G3 window risk). Do not rename to testG7_risk_ "
    "without syncing Makefile + G7_TARGETS + this note."
)

ALL_BATCH_TARGETS = {**WP21_TARGETS, **G7_TARGETS}

# AC golden methods that must remain in the stable product-behavior class.
GOLDEN_REQUIRED_TEST_PREFIXES = [
    "test01_openAC_",
    "test03a_freshDefaultTemp24",
    "test07_alreadyOn_",
    "test12_multiIntent_",
]

# Forbidden patterns that MUST NOT appear in product gate tests (placebo indicators)
WP21_FORBIDDEN_PATTERNS = [
    r"ToolCallFrame\(",
    r"planDecoder:",
    r"preset:",
    r"modelBackend:",
    r"MLXLocalToolPlanBackend",
    r"TenFamily",
    r"tailgate",
    r"sunroof",
]

# expected 由被测 runtime / catalog / authority 反向生成 → 假绿
REVERSE_GENERATED_PATTERNS = [
    r"let\s+expected\w*\s*=\s*[^\n]*(?:\.catalog\b|authority|matrixEntry|liveAuthority|runtimeAuthority)",
    r"let\s+expected\w*\s*=\s*(?:result|execution|readOnly|payload|h\.store)\.",
    r"let\s+expected\w*\s*=\s*[^\n]*\.actualValue",
    r"//\s*(?:reverse[- ]generat|from\s+runtime\s+authority)",
]


def _strip_swift_comments(source: str) -> str:
    """Remove Swift line comments and block comments."""
    source = re.sub(r"/\*.*?\*/", "", source, flags=re.DOTALL)
    return re.sub(r"//.*", "", source)


def _strip_swift_strings(source: str) -> str:
    """Prevent comments or string literals from satisfying code anchors."""
    return re.sub(r'"(?:\\.|[^"\\])*"', '""', source)


def _read_product_gate_source(root: Path) -> str:
    """Read and strip comments from DemoSliceProductBehaviorGateTests.swift."""
    path = root / "Tests" / "MAformacCoreTests" / "DemoSliceProductBehaviorGateTests.swift"
    if not path.exists():
        return ""
    source = path.read_text(encoding="utf-8")
    return _strip_swift_strings(_strip_swift_comments(source))


def _read_product_gate_source_raw(root: Path) -> str:
    """Raw source (comments kept) for reverse-generation comment markers."""
    path = root / "Tests" / "MAformacCoreTests" / "DemoSliceProductBehaviorGateTests.swift"
    if not path.exists():
        return ""
    return path.read_text(encoding="utf-8")


def _check_file_wide_anchors(source: str) -> list[str]:
    """Structural anchors that may live once (Harness / UI projection)."""
    failures = []
    for pattern in FILE_WIDE_REQUIRED_ANCHORS:
        if not re.search(pattern, source):
            failures.append(f"Missing file-wide anchor: {pattern}")
    return failures


def _check_required_test_prefixes(source: str) -> list[str]:
    """Check WP21 batch prefixes and AC golden prefixes are present."""
    failures = []
    for prefix in WP21_REQUIRED_TEST_PREFIXES:
        if not re.search(rf"func\s+{re.escape(prefix)}", source):
            failures.append(f"Missing test prefix: {prefix}")
    for prefix in GOLDEN_REQUIRED_TEST_PREFIXES:
        if not re.search(rf"func\s+{re.escape(prefix)}", source):
            failures.append(f"Missing golden test prefix: {prefix}")
    for prefix in G7_TARGETS.values():
        if not re.search(rf"func\s+{re.escape(prefix)}", source):
            failures.append(f"Missing G7 batch test prefix: {prefix}")
    return failures


def _extract_all_swift_func_bodies(source: str, func_prefix: str) -> list[tuple[str, str]]:
    """Return [(func_name, body), ...] for every `func <prefix>...` method."""
    results: list[tuple[str, str]] = []
    for match in re.finditer(
        rf"func\s+({re.escape(func_prefix)}\w*)\s*\([^)]*\)[^{{]*\{{",
        source,
    ):
        name = match.group(1)
        start = match.end() - 1
        depth = 0
        for index, char in enumerate(source[start:], start=start):
            if char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
                if depth == 0:
                    results.append((name, source[start + 1 : index]))
                    break
    return results


def _batch_anchors_for(prefix: str) -> list[tuple[str, str]]:
    return BATCH_BODY_ANCHOR_OVERRIDES.get(prefix, DEFAULT_BATCH_BODY_ANCHORS)


def _check_batch_scope_anchors(source: str) -> list[str]:
    """
    Per Make-batch scope: each locked prefix must have ≥1 non-empty method,
    each method must call .route(text:), and the aggregate body must carry
    the batch's required customer-path anchors (no file-wide wash).
    """
    failures: list[str] = []
    for target, prefix in ALL_BATCH_TARGETS.items():
        bodies = _extract_all_swift_func_bodies(source, prefix)
        if not bodies:
            failures.append(f"0-filter: no tests match prefix {prefix!r} for {target}")
            continue
        aggregate_parts: list[str] = []
        for name, body in bodies:
            compact = re.sub(r"\s+", "", body)
            if not compact:
                failures.append(f"Empty batch body: {name} ({target})")
                continue
            if ".route(text:" not in body:
                failures.append(f"Batch method missing .route(text:): {name} ({target})")
            aggregate_parts.append(body)
        if not aggregate_parts:
            continue
        aggregate = "\n".join(aggregate_parts)
        for pattern, label in _batch_anchors_for(prefix):
            if not re.search(pattern, aggregate):
                failures.append(
                    f"Batch scope missing {label}: {target} prefix={prefix!r}"
                )
    return failures


def _check_reverse_generated_expected(raw_source: str) -> list[str]:
    """Reject fixtures that derive expected from the runtime under test."""
    failures: list[str] = []
    for pattern in REVERSE_GENERATED_PATTERNS:
        if re.search(pattern, raw_source):
            failures.append(f"Reverse-generated expected pattern: {pattern}")
    return failures


def _check_forbidden_patterns(source: str) -> list[str]:
    """Check forbidden patterns are NOT present in product gate test code."""
    failures = []
    for pattern in WP21_FORBIDDEN_PATTERNS:
        if re.search(pattern, source):
            failures.append(f"Forbidden pattern found in product gate: {pattern}")
    return failures


def _check_voice_acceptance_guard(source: str) -> list[str]:
    """
    Check that voice/TTS/audio acceptance assertions are NOT present.
    Allow Harness to construct RecordingSpeechSynthesisEngine() but forbid
    assertions on speech output as acceptance criteria.
    """
    failures = []
    lines = source.splitlines()
    for i, line in enumerate(lines):
        if re.search(r"XCTAssert.*spokenTexts", line) or re.search(
            r"XCTAssert.*speechCount", line
        ):
            failures.append(f"Voice acceptance assertion at line {i+1}: {line.strip()[:120]}")
        if re.search(r"XCTAssert", line):
            context_lines = []
            for j in range(max(0, i - 1), min(len(lines), i + 2)):
                context_lines.append(lines[j])
            context = " ".join(context_lines)
            if re.search(r"TTS|audio|speech|synthesis|tts", context, re.IGNORECASE):
                failures.append(
                    f"TTS/audio/speech acceptance assertion near line {i+1}: "
                    f"{line.strip()[:120]}"
                )
    return failures


def _check_recording_speech_engine_only_in_harness(source: str) -> list[str]:
    """
    Allow RecordingSpeechSynthesisEngine() construction ONLY in Harness struct,
    forbid elsewhere in test methods (where it would be test-side injection).
    """
    failures = []
    harness_match = re.search(r"struct Harness\s*\{([^}]+)\}", source, re.DOTALL)
    if harness_match:
        harness_body = harness_match.group(1)
        if "RecordingSpeechSynthesisEngine()" not in harness_body:
            failures.append("RecordingSpeechSynthesisEngine() must be constructed in Harness")
    else:
        failures.append("Harness struct not found")

    harness_start = source.find("struct Harness")
    if harness_start != -1:
        brace_start = source.find("{", harness_start)
        if brace_start != -1:
            depth = 0
            harness_end = brace_start
            for i, ch in enumerate(source[brace_start:], start=brace_start):
                if ch == "{":
                    depth += 1
                elif ch == "}":
                    depth -= 1
                    if depth == 0:
                        harness_end = i + 1
                        break
            outside = source[:harness_start] + source[harness_end:]
            if "RecordingSpeechSynthesisEngine()" in outside:
                failures.append(
                    "RecordingSpeechSynthesisEngine() constructed outside Harness "
                    "(test-side injection)"
                )
    return failures


def _make_target_body(makefile: str, target: str) -> str | None:
    header = re.search(rf"(?m)^{re.escape(target)}\s*:[^\n]*$", makefile)
    if header is None:
        return None
    body: list[str] = []
    for line in makefile[header.end() :].splitlines():
        if line.startswith("\t") or not line.strip():
            body.append(line)
            continue
        break
    return "\n".join(body)


def _body_uses_exact_min_count(body: str, filter_token: str) -> bool:
    """Require fail-closed exact runner with --min-count 1 (executed>0 gate)."""
    if EXACT_RUNNER not in body and "run_swift_test_exact.py" not in body:
        return False
    if not re.search(r"--min-count\s+1\b", body):
        return False
    return bool(
        re.search(
            rf"--filter\s+{re.escape(filter_token)}\b",
            body,
        )
    )


def _check_verify_e2e_recipe(makefile: str) -> list[str]:
    """
    Lock the FA-1 + G7 stable-gate contract:
    verify-e2e must aggregate full-class product behavior + WP21 + G7 filters,
    each via run_swift_test_exact.py --min-count 1 (0-match must not exit 0).
    """
    failures: list[str] = []
    aggregate = re.search(r"(?m)^verify-e2e\s*:([^\n]*)$", makefile)
    if aggregate is None:
        return ["verify-e2e aggregate target missing"]

    deps = aggregate.group(1)
    if PRODUCT_BEHAVIOR_TARGET not in deps:
        failures.append(f"verify-e2e dependency missing: {PRODUCT_BEHAVIOR_TARGET}")

    product_body = _make_target_body(makefile, PRODUCT_BEHAVIOR_TARGET)
    if product_body is None:
        failures.append(f"Makefile target missing: {PRODUCT_BEHAVIOR_TARGET}")
    else:
        if not _body_uses_exact_min_count(product_body, PRODUCT_BEHAVIOR_FILTER):
            failures.append(
                f"Exact runner + --min-count 1 missing: {PRODUCT_BEHAVIOR_TARGET}"
            )
        # Narrowed class filter (/suffix) not allowed on full-class target.
        if re.search(
            rf"--filter\s+{re.escape(PRODUCT_BEHAVIOR_FILTER)}/",
            product_body,
        ):
            failures.append(
                f"Narrowed class filter not allowed in {PRODUCT_BEHAVIOR_TARGET}"
            )
        if re.search(r"(?m)^\s*@?true\s*$", product_body):
            failures.append(f"Placebo true target: {PRODUCT_BEHAVIOR_TARGET}")
        if re.search(r"(?m)^\s*swift\s+test\s+--filter\b", product_body):
            failures.append(
                f"Bare swift test --filter not allowed (0-match placebo): "
                f"{PRODUCT_BEHAVIOR_TARGET}"
            )

    for target, test_prefix in ALL_BATCH_TARGETS.items():
        body = _make_target_body(makefile, target)
        if body is None:
            failures.append(f"Makefile target missing: {target}")
            continue
        filter_token = f"{PRODUCT_BEHAVIOR_FILTER}/{test_prefix}"
        if not _body_uses_exact_min_count(body, filter_token):
            failures.append(f"Exact runner + --min-count 1 missing: {target}")
        if re.search(r"(?m)^\s*@?true\s*$", body):
            failures.append(f"Placebo true target: {target}")
        if re.search(r"(?m)^\s*swift\s+test\s+--filter\b", body):
            failures.append(
                f"Bare swift test --filter not allowed (0-match placebo): {target}"
            )
        if target not in deps:
            failures.append(f"verify-e2e dependency missing: {target}")

    # Documented risk↔testG3_window coupling must remain locked.
    risk_body = _make_target_body(makefile, "verify-e2e-risk")
    if risk_body is not None and "testG3_window" not in risk_body:
        failures.append(
            "verify-e2e-risk must keep filter testG3_window "
            f"({G7_RISK_FILTER_COUPLING})"
        )
    return failures


def _check_wp21_make_targets(root: Path) -> list[str]:
    makefile_path = root / "Makefile"
    makefile = makefile_path.read_text(encoding="utf-8") if makefile_path.is_file() else ""
    return _check_verify_e2e_recipe(makefile)


def check_wp21_product_gate(root: Path) -> list[str]:
    """
    WP2-1 / G7 产品行为门禁防安慰剂检查。

    - 文件级：DemoSliceRoute / VehicleCardDisplay / Harness / forbidden / voice
    - 逐批作用域：WP21 + G7 六批各自非空、含 .route，聚合含客户链锚点
    - recipe：全类 + WP21 + G7；每 filter 经 run_swift_test_exact --min-count 1
    - 反向生成 expected → FAIL；0-filter（源码无匹配）→ FAIL

    Returns:
        List of failure messages. Empty list means pass.
    """
    failures = []
    source = _read_product_gate_source(root)
    raw_source = _read_product_gate_source_raw(root)

    if not source:
        return ["DemoSliceProductBehaviorGateTests.swift not found"]

    failures.extend(_check_file_wide_anchors(source))
    failures.extend(_check_required_test_prefixes(source))
    failures.extend(_check_batch_scope_anchors(source))
    failures.extend(_check_reverse_generated_expected(raw_source))
    failures.extend(_check_forbidden_patterns(source))
    failures.extend(_check_voice_acceptance_guard(source))
    failures.extend(_check_recording_speech_engine_only_in_harness(source))
    failures.extend(_check_wp21_make_targets(root))

    return failures


def main() -> int:
    """运行检查，任一失败则返回非零状态。"""
    root = Path(__file__).resolve().parent.parent

    all_failures = []

    fact_failures = check_fact_anchors(root)
    if fact_failures:
        all_failures.extend([f"FAIL: fact anchor: {f}" for f in fact_failures])

    pct_failures = check_percentage_progress(root)
    if pct_failures:
        all_failures.extend([f"FAIL: percentage progress: {f}" for f in pct_failures])

    verify_failures = check_verify_e2e(root)
    if verify_failures:
        all_failures.extend([f"FAIL: verify-e2e: {f}" for f in verify_failures])

    wp21_failures = check_wp21_product_gate(root)
    if wp21_failures:
        all_failures.extend([f"FAIL: wp21 product gate: {f}" for f in wp21_failures])

    if all_failures:
        for failure in all_failures:
            print(failure, file=sys.stderr)
        return 1
    print("verify-anti-placebo: PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())

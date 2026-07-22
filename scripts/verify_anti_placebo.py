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


# ---- WP2-1 Anti-Placebo Product Gate Checker ----

# Required anchor patterns that MUST be present in DemoSliceProductBehaviorGateTests.swift
WP21_REQUIRED_ANCHORS = [
    r"DemoSliceRoute\(",
    r"\.route\(text:",
    r"runnerCallCount",
    r"\.store\b|\.store\.cell\b|store\.cell\b",
    r"payload\.readbacks",
    r"mutationCount|revision",
    r"VehicleCardDisplay\.displays",
]

# Required test name prefixes (three batches required)
WP21_REQUIRED_TEST_PREFIXES = [
    "testWP21BatchA_",
    "testWP21BatchB_",
    "testWP21BatchC_",
]

PRODUCT_BEHAVIOR_TARGET = "verify-e2e-product-behavior"
PRODUCT_BEHAVIOR_FILTER = "DemoSliceProductBehaviorGateTests"

WP21_TARGETS = {
    "verify-e2e-wp21-window": "testWP21BatchA_",
    "verify-e2e-wp21-ambient": "testWP21BatchB_",
    "verify-e2e-wp21-seat": "testWP21BatchC_",
}

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

# Voice acceptance patterns that MUST NOT appear as acceptance assertions
# These are forbidden when combined with XCTAssert/assertion context
WP21_VOICE_ACCEPTANCE_PATTERNS = [
    r"spokenTexts",
    r"speechCount",
    # TTS/audio/speech acceptance assertions (XCTAssert + TTS/audio/speech on same/adjacent line)
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


def _check_required_anchors(source: str) -> list[str]:
    """Check all required anchor patterns are present."""
    failures = []
    for pattern in WP21_REQUIRED_ANCHORS:
        if not re.search(pattern, source):
            failures.append(f"Missing required anchor: {pattern}")
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
    return failures


def _extract_swift_func_body(source: str, func_prefix: str) -> str | None:
    """Return the body of the first `func <prefix>...` method, or None."""
    match = re.search(rf"func\s+{re.escape(func_prefix)}\w*\s*\([^)]*\)[^{{]*\{{", source)
    if match is None:
        return None
    start = match.end() - 1
    depth = 0
    for index, char in enumerate(source[start:], start=start):
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return source[start + 1 : index]
    return None


def _check_wp21_batch_bodies_have_route(source: str) -> list[str]:
    """Empty WP21 batch methods are placebo and must fail closed."""
    failures: list[str] = []
    for prefix in WP21_REQUIRED_TEST_PREFIXES:
        body = _extract_swift_func_body(source, prefix)
        if body is None:
            failures.append(f"Missing WP21 batch body: {prefix}")
            continue
        compact = re.sub(r"\s+", "", body)
        if not compact:
            failures.append(f"Empty WP21 batch body: {prefix}")
            continue
        if ".route(text:" not in body:
            failures.append(f"WP21 batch missing .route(text:): {prefix}")
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
        # Check for spokenTexts / speechCount assertions
        if re.search(r"XCTAssert.*spokenTexts", line) or re.search(r"XCTAssert.*speechCount", line):
            failures.append(f"Voice acceptance assertion at line {i+1}: {line.strip()[:120]}")
        # Check for TTS/audio/speech acceptance assertions on same or adjacent lines
        if re.search(r"XCTAssert", line):
            # Check current line and adjacent lines for TTS/audio/speech keywords
            context_lines = []
            for j in range(max(0, i-1), min(len(lines), i+2)):
                context_lines.append(lines[j])
            context = " ".join(context_lines)
            if re.search(r"TTS|audio|speech|synthesis|tts", context, re.IGNORECASE):
                failures.append(f"TTS/audio/speech acceptance assertion near line {i+1}: {line.strip()[:120]}")
    return failures


def _check_recording_speech_engine_only_in_harness(source: str) -> list[str]:
    """
    Allow RecordingSpeechSynthesisEngine() construction ONLY in Harness struct,
    forbid elsewhere in test methods (where it would be test-side injection).
    """
    failures = []
    # Find Harness struct boundaries
    harness_match = re.search(r"struct Harness\s*\{([^}]+)\}", source, re.DOTALL)
    if harness_match:
        harness_body = harness_match.group(1)
        if "RecordingSpeechSynthesisEngine()" not in harness_body:
            failures.append("RecordingSpeechSynthesisEngine() must be constructed in Harness")
    else:
        failures.append("Harness struct not found")

    # Check that RecordingSpeechSynthesisEngine() is NOT constructed outside Harness
    # (i.e., in test methods - this would be test-side injection)
    # We'll check the whole file minus the Harness struct
    harness_start = source.find("struct Harness")
    if harness_start != -1:
        brace_start = source.find("{", harness_start)
        if brace_start != -1:
            # Find matching closing brace
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
            # Check outside Harness
            outside = source[:harness_start] + source[harness_end:]
            if "RecordingSpeechSynthesisEngine()" in outside:
                failures.append("RecordingSpeechSynthesisEngine() constructed outside Harness (test-side injection)")
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


def _check_verify_e2e_recipe(makefile: str) -> list[str]:
    """
    Lock the FA-1 stable-gate contract:
    verify-e2e must aggregate full-class product behavior + three WP21 filters.
    WP21-only recipes must fail closed.
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
        # Exact class filter only — a narrower /testWP21... suffix is recipe drift.
        if not re.search(
            rf"swift\s+test\s+--filter\s+{re.escape(PRODUCT_BEHAVIOR_FILTER)}\s*(?:#.*)?$",
            product_body,
            flags=re.MULTILINE,
        ):
            failures.append(
                f"Exact full-class Swift filter missing: {PRODUCT_BEHAVIOR_TARGET}"
            )
        if re.search(
            rf"swift\s+test\s+--filter\s+{re.escape(PRODUCT_BEHAVIOR_FILTER)}/",
            product_body,
        ):
            failures.append(
                f"Narrowed class filter not allowed in {PRODUCT_BEHAVIOR_TARGET}"
            )
        if re.search(r"(?m)^\s*@?true\s*$", product_body):
            failures.append(f"Placebo true target: {PRODUCT_BEHAVIOR_TARGET}")

    for target, test_prefix in WP21_TARGETS.items():
        body = _make_target_body(makefile, target)
        if body is None:
            failures.append(f"Makefile target missing: {target}")
            continue
        if not re.search(
            rf"swift\s+test\s+--filter\s+DemoSliceProductBehaviorGateTests/{re.escape(test_prefix)}",
            body,
        ):
            failures.append(f"Exact Swift filter missing: {target}")
        if re.search(r"(?m)^\s*@?true\s*$", body):
            failures.append(f"Placebo true target: {target}")
        if target not in deps:
            failures.append(f"verify-e2e dependency missing: {target}")
    return failures


def _check_wp21_make_targets(root: Path) -> list[str]:
    makefile_path = root / "Makefile"
    makefile = makefile_path.read_text(encoding="utf-8") if makefile_path.is_file() else ""
    return _check_verify_e2e_recipe(makefile)


def check_wp21_product_gate(root: Path) -> list[str]:
    """
    WP2-1 产品行为门禁防安慰剂检查。
    读取 Tests/MAformacCoreTests/DemoSliceProductBehaviorGateTests.swift，
    去除 Swift 行/块注释后检查。
    
    必须有：
    - DemoSliceRoute(、.route(text:、runnerCallCount、.store 或 store.cell、payload.readbacks、mutationCount/revision
    - 三族计划 test 名前缀 testWP21BatchA_、testWP21BatchB_、testWP21BatchC_
    
    禁止（安慰剂指标）：
    - 产品门测试代码中出现 ToolCallFrame(、planDecoder:、preset:、modelBackend:、MLXLocalToolPlanBackend、TenFamily、tailgate/sunroof 正向入口
    - 语音非门：若产品 gate 出现 spokenTexts、speechCount 或 XCTAssert 同行/邻近 TTS/audio/speech acceptance，必须失败
    - 允许 Harness 仅构造 RecordingSpeechSynthesisEngine()
    
    Returns:
        List of failure messages. Empty list means pass.
    """
    failures = []
    source = _read_product_gate_source(root)
    
    if not source:
        return ["DemoSliceProductBehaviorGateTests.swift not found"]
    
    # Check required anchors
    failures.extend(_check_required_anchors(source))
    
    # Check required test prefixes (three batches + AC golden)
    failures.extend(_check_required_test_prefixes(source))

    # Empty WP21 batch methods must fail closed
    failures.extend(_check_wp21_batch_bodies_have_route(source))
    
    # Check forbidden patterns
    failures.extend(_check_forbidden_patterns(source))
    
    # Check voice acceptance guard
    failures.extend(_check_voice_acceptance_guard(source))
    
    # Check RecordingSpeechSynthesisEngine only in Harness
    failures.extend(_check_recording_speech_engine_only_in_harness(source))
    
    failures.extend(_check_wp21_make_targets(root))

    return failures


def main() -> int:
    """运行三项检查，任一失败则返回非零状态。"""
    root = Path(__file__).resolve().parent.parent
    
    all_failures = []
    
    # Check 1: Fact anchors
    fact_failures = check_fact_anchors(root)
    if fact_failures:
        all_failures.extend([f"FAIL: fact anchor: {f}" for f in fact_failures])
    
    # Check 2: Percentage progress
    pct_failures = check_percentage_progress(root)
    if pct_failures:
        all_failures.extend([f"FAIL: percentage progress: {f}" for f in pct_failures])
    
    # Check 3: verify-e2e target
    verify_failures = check_verify_e2e(root)
    if verify_failures:
        all_failures.extend([f"FAIL: verify-e2e: {f}" for f in verify_failures])
    
    # Check 4: WP2-1 product gate
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
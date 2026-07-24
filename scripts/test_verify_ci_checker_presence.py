#!/usr/bin/env python3
"""Regression test: verify-ci must fail when a required checker is deleted."""

from __future__ import annotations

import subprocess
import sys
import tempfile
import re
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT))
from Tools.checks.check_runtime_finite_reason_authority import (  # noqa: E402
    mask_swift_comments,
    mask_swift_strings,
)

MAKEFILE = REPO_ROOT / "Makefile"
MISSING_MARKER = "ERROR_MISSING_C1_CHECKER"


def parse_verify_c1_checker_files_roster(makefile_text: str) -> tuple[Path, ...]:
    """SSOT = Makefile verify-c1-checker-files `for checker in ...; do` roster.

    Presence deletion probes must track the same list the make target actually
    checks. A second Python tuple is the class-bug that missed A4 files.
    """
    match = re.search(
        r"^verify-c1-checker-files:\n(?P<body>(?:\t.*\n)+)",
        makefile_text,
        re.MULTILINE,
    )
    if match is None:
        raise AssertionError("Makefile missing verify-c1-checker-files recipe")
    loop = re.search(r"for checker in (?P<paths>.+?); do", match.group("body"))
    if loop is None:
        raise AssertionError("verify-c1-checker-files missing `for checker in ...; do` roster")
    paths = tuple(Path(item) for item in loop.group("paths").split() if item)
    if not paths:
        raise AssertionError("verify-c1-checker-files roster is empty")
    if len(paths) != len(set(paths)):
        raise AssertionError(f"duplicate entries in checker roster: {paths}")
    return paths


def required_checker_paths() -> tuple[Path, ...]:
    return parse_verify_c1_checker_files_roster(MAKEFILE.read_text(encoding="utf-8"))
OWNERSHIP_TARGET = "verify-c1-ownership"
OWNERSHIP_SUITE = "scripts/test_check_c1_ownership_map.py"
OWNERSHIP_CHECKER = "Tools/checks/check_c1_ownership_map.py"
RUNTIME_REASON_TARGET = "verify-c1-finite-reason-authority"
RUNTIME_REASON_SUITE = "scripts/test_check_runtime_finite_reason_authority.py"
RUNTIME_REASON_CHECKER = "Tools/checks/check_runtime_finite_reason_authority.py"
ACTION_DEMO_RENAME_TARGET = "verify-action-demo-proven-rename"
ACTION_DEMO_RENAME_SUITE = "scripts/test_check_action_demo_proven_legacy_tokens.py"
ACTION_DEMO_RENAME_CHECKER = "Tools/checks/check_action_demo_proven_legacy_tokens.py"
EXACT_RUNNER = "Tools/checks/run_swift_test_exact.py"
EXACT_RUNNER_SUITE = "scripts/test_run_swift_test_exact.py"
BEHAVIOR_TEST_SOURCE = REPO_ROOT / "Tests/MAformacCoreTests/RuntimeFiniteReasonAuthorityTests.swift"


def _behavior_gate_methods_from_checker() -> tuple[str, ...]:
    """SSOT = Tools/checks/check_runtime_finite_reason_authority.BEHAVIOR_GATE_METHODS values."""
    import importlib.util

    checker_path = REPO_ROOT / "Tools/checks/check_runtime_finite_reason_authority.py"
    spec = importlib.util.spec_from_file_location(
        "check_runtime_finite_reason_authority_for_presence", checker_path
    )
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    methods = tuple(module.BEHAVIOR_GATE_METHODS.values())
    if not methods:
        raise AssertionError("BEHAVIOR_GATE_METHODS empty")
    return methods


BEHAVIOR_GATE_METHODS = _behavior_gate_methods_from_checker()

EXACT_FILTERS = tuple(
    f"RuntimeFiniteReasonAuthorityTests/{method}" for method in BEHAVIOR_GATE_METHODS
)
# Full typed authority suite (min-count mode) + one exact runner per behavior gate method.
FULL_SUITE_FILTER = "--filter RuntimeFiniteReasonAuthorityTests --min-count 1"
EXACT_RUNNER_INVOCATION_COUNT = len(BEHAVIOR_GATE_METHODS) + 1


def missing_behavior_gate_declarations(source: str) -> list[str]:
    source = mask_swift_strings(mask_swift_comments(source))
    return [
        method
        for method in BEHAVIOR_GATE_METHODS
        if re.search(rf"(?m)^[ \t]*func[ \t]+{re.escape(method)}[ \t]*\(", source) is None
    ]


def test_verify_ci_fails_when_a_checker_is_deleted() -> None:
    makefile_text = MAKEFILE.read_text(encoding="utf-8")
    makefile_lines = makefile_text.splitlines()
    verify_line = next(line for line in makefile_lines if line.startswith("verify:"))
    verify_ci_line = next(line for line in makefile_lines if line.startswith("verify-ci:"))
    assert OWNERSHIP_TARGET in verify_line, verify_line
    assert OWNERSHIP_TARGET in verify_ci_line, verify_ci_line
    assert RUNTIME_REASON_TARGET in verify_line, verify_line
    assert RUNTIME_REASON_TARGET in verify_ci_line, verify_ci_line
    assert ACTION_DEMO_RENAME_TARGET in verify_line, verify_line
    assert ACTION_DEMO_RENAME_TARGET in verify_ci_line, verify_ci_line
    assert "verify-c1-checker-files" in verify_ci_line, verify_ci_line

    ownership_start = makefile_text.index(f"{OWNERSHIP_TARGET}:")
    ownership_end = makefile_text.find("\n\n", ownership_start)
    ownership_block = makefile_text[
        ownership_start : ownership_end if ownership_end >= 0 else None
    ]
    assert OWNERSHIP_SUITE in ownership_block, ownership_block
    assert OWNERSHIP_CHECKER in ownership_block, ownership_block

    runtime_reason_start = makefile_text.index(f"{RUNTIME_REASON_TARGET}:")
    runtime_reason_end = makefile_text.find("\n\n", runtime_reason_start)
    runtime_reason_block = makefile_text[
        runtime_reason_start : runtime_reason_end if runtime_reason_end >= 0 else None
    ]
    assert RUNTIME_REASON_SUITE in runtime_reason_block, runtime_reason_block
    assert RUNTIME_REASON_CHECKER in runtime_reason_block, runtime_reason_block
    assert EXACT_RUNNER_SUITE in runtime_reason_block, runtime_reason_block
    assert (
        runtime_reason_block.count(EXACT_RUNNER) == EXACT_RUNNER_INVOCATION_COUNT
    ), runtime_reason_block
    assert FULL_SUITE_FILTER in runtime_reason_block, runtime_reason_block
    for exact_filter in EXACT_FILTERS:
        assert f"--filter {exact_filter}" in runtime_reason_block, runtime_reason_block

    action_demo_start = makefile_text.index(f"{ACTION_DEMO_RENAME_TARGET}:")
    action_demo_end = makefile_text.find("\n\n", action_demo_start)
    action_demo_block = makefile_text[
        action_demo_start : action_demo_end if action_demo_end >= 0 else None
    ]
    assert ACTION_DEMO_RENAME_SUITE in action_demo_block, action_demo_block
    assert ACTION_DEMO_RENAME_CHECKER in action_demo_block, action_demo_block

    behavior_source = BEHAVIOR_TEST_SOURCE.read_text(encoding="utf-8")
    assert missing_behavior_gate_declarations(behavior_source) == []
    for method in BEHAVIOR_GATE_METHODS:
        renamed = behavior_source.replace(
            f"    func {method}(",
            f"    func helper{method}(",
            1,
        )
        deleted = behavior_source.replace(
            f"    func {method}(",
            "    // deleted behavior gate declaration(",
            1,
        )
        block_commented = behavior_source.replace(
            f"    func {method}(",
            f"    /*\n    func {method}(\n    */",
            1,
        )
        assert method in missing_behavior_gate_declarations(renamed), method
        assert method in missing_behavior_gate_declarations(deleted), method
        assert method in missing_behavior_gate_declarations(block_commented), method

    exact_runner_text = (REPO_ROOT / EXACT_RUNNER).read_text(encoding="utf-8")
    assert "E_SWIFT_EXACT_TEST_ZERO" in exact_runner_text
    assert "E_SWIFT_EXACT_TEST_COUNT" in exact_runner_text

    checker_paths_roster = required_checker_paths()
    assert checker_paths_roster, "presence roster must be non-empty"
    # Fail closed if any Makefile-listed path is already missing in the real repo.
    missing_in_repo = [p.as_posix() for p in checker_paths_roster if not (REPO_ROOT / p).is_file()]
    assert missing_in_repo == [], f"Makefile roster paths missing on disk: {missing_in_repo}"

    for missing_relative in checker_paths_roster:
        with tempfile.TemporaryDirectory(prefix="verify-ci-checkers-") as tmp:
            temp_repo = Path(tmp)
            checker_paths = [temp_repo / relative for relative in checker_paths_roster]
            for path in checker_paths:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("# test sentinel\n", encoding="utf-8")

            present_result = subprocess.run(
                [
                    "make",
                    "--no-print-directory",
                    "-C",
                    str(temp_repo),
                    "-f",
                    str(MAKEFILE),
                    "verify-c1-checker-files",
                ],
                cwd=temp_repo,
                capture_output=True,
                text=True,
                check=False,
            )
            assert present_result.returncode == 0, (
                present_result.stdout + present_result.stderr
            )

            missing_path = temp_repo / missing_relative
            missing_path.unlink()

            result = subprocess.run(
                [
                    "make",
                    "--no-print-directory",
                    "-C",
                    str(temp_repo),
                    "-f",
                    str(MAKEFILE),
                    "verify-ci",
                ],
                cwd=temp_repo,
                capture_output=True,
                text=True,
                check=False,
            )
            output = result.stdout + result.stderr
            assert result.returncode != 0, (
                f"verify-ci unexpectedly passed after deleting {missing_relative}\n{output}"
            )
            assert MISSING_MARKER in output, output
            assert missing_relative.as_posix() in output, output
            print(f"PASS: deleted {missing_relative}; verify-ci rc={result.returncode}")



def test_makefile_checker_roster_is_parseable_and_nonempty() -> None:
    roster = required_checker_paths()
    assert len(roster) >= 1
    # Sanity: known gate members still present (names, not a second roster SSOT).
    as_posix = {path.as_posix() for path in roster}
    assert "scripts/check_closure_work_packages.py" in as_posix
    assert "Tools/checks/check_c1_ownership_map.py" in as_posix


def test_makefile_exact_filters_match_behavior_gate_ssot() -> None:
    """Makefile exact-runner filters must track checker BEHAVIOR_GATE_METHODS."""
    makefile_text = MAKEFILE.read_text(encoding="utf-8")
    start = makefile_text.index("verify-c1-finite-reason-authority:")
    end = makefile_text.find("\n\n", start)
    block = makefile_text[start : end if end >= 0 else None]
    for method in BEHAVIOR_GATE_METHODS:
        needle = f"--filter RuntimeFiniteReasonAuthorityTests/{method}"
        assert needle in block, f"Makefile missing exact filter for {method}"
    exact_filters = re.findall(
        r"--filter RuntimeFiniteReasonAuthorityTests/([A-Za-z0-9_]+)",
        block,
    )
    assert sorted(exact_filters) == sorted(BEHAVIOR_GATE_METHODS), (
        f"Makefile exact filters drifted: {exact_filters} vs {list(BEHAVIOR_GATE_METHODS)}"
    )


# Production checker scripts may be presence-rostered OR explicitly exempt.
# Recursive verify-ci walk also sees test harness / generators; those are not
# the presence-deletion SSOT (roster-sync: presence protects the Makefile for-loop set).
VERIFY_CI_PRESENCE_EXEMPT: frozenset[str] = frozenset(
    {
        # Invoked via verify-ci graph but intentionally outside verify-c1-checker-files roster
        "Tools/checks/check_capability_matrix.py",
        "Tools/checks/check_runtime_no_mutation_receipts.py",
        "Tools/checks/check_int_v5a_execution_receipt.py",  # also on roster? keep harmless
        "scripts/check_mounted_catalog_no_delta.py",
        "scripts/check_c6_case_shape.py",
        "scripts/check_default_scope_ssot.py",
        "scripts/check_c5_c2_scope_parity.py",
        "scripts/check_scope_origin_single_source.py",
        "scripts/cross_section_check.py",
        "scripts/surface_consistency.py",
        "scripts/verify_refs.py",
        "scripts/verify_gold.py",
        # Generators consumed by matrix/runtime gates (not presence deletion targets)
        "Tools/generate_demo_capability_matrix_swift.py",
        "Tools/generate_demo_runtime_contract_bundle.py",
    }
)


def _makefile_target_prereqs(makefile_text: str, target: str) -> list[str]:
    """Parse `target: prereq...` line (first matching rule)."""
    for line in makefile_text.splitlines():
        if line.startswith(f"{target}:") and not line.startswith(f"{target}:="):
            body = line.split(":", 1)[1].strip()
            if not body:
                return []
            return body.split()
    return []


def _makefile_target_recipe_body(makefile_text: str, target: str) -> str:
    match = re.search(
        rf"^{re.escape(target)}:[^\n]*\n(?P<body>(?:\t.*\n)*)",
        makefile_text,
        re.MULTILINE,
    )
    return match.group("body") if match else ""


def _scripts_in_recipe(body: str) -> set[str]:
    found: set[str] = set()
    for m in re.finditer(r"(?:Tools|scripts)/[A-Za-z0-9_./-]+\.py", body):
        found.add(m.group(0))
    return found


def _scripts_invoked_by_verify_ci(makefile_text: str | None = None) -> set[str]:
    """Recursive Make prerequisite graph from verify-ci, with cycle guard.

    One-hop-only scans miss checkers hung under intermediate targets
    (XAUDIT-CLASSFIX w1 P1-5 residual).
    """
    if makefile_text is None:
        makefile_text = MAKEFILE.read_text(encoding="utf-8")
    scripts: set[str] = set()
    stack = ["verify-ci"]
    seen: set[str] = set()
    while stack:
        target = stack.pop()
        if target in seen:
            continue
        seen.add(target)
        if target.startswith("$") or "/" in target or target.startswith("."):
            continue
        body = _makefile_target_recipe_body(makefile_text, target)
        scripts |= _scripts_in_recipe(body)
        for prereq in _makefile_target_prereqs(makefile_text, target):
            if prereq.startswith("$") or "/" in prereq or prereq.startswith("."):
                continue
            if prereq not in seen:
                stack.append(prereq)
    return scripts


def _is_production_checker_script(path: str) -> bool:
    """Presence policy applies to production checkers, not every test/generator leaf."""
    name = path.rsplit("/", 1)[-1]
    if path.startswith("Tools/checks/") and name.endswith(".py") and not name.startswith("test_"):
        return True
    if path.startswith("scripts/") and name.startswith("check_") and name.endswith(".py"):
        return True
    # surface/cross_section style gate scripts also count as prod gates
    if path in {
        "scripts/cross_section_check.py",
        "scripts/surface_consistency.py",
        "scripts/verify_refs.py",
        "scripts/verify_gold.py",
    }:
        return True
    if path.startswith("Tools/generate_") and path.endswith(".py"):
        return True
    return False


def test_verify_ci_prod_scripts_are_presence_or_explicit_exempt() -> None:
    """Every production checker script reachable from verify-ci is presence-rostered or EXEMPT."""
    makefile_text = MAKEFILE.read_text(encoding="utf-8")
    invoked = {s for s in _scripts_invoked_by_verify_ci(makefile_text) if _is_production_checker_script(s)}
    presence = {p.as_posix() for p in required_checker_paths()}
    missing = sorted(s for s in invoked if s not in presence and s not in VERIFY_CI_PRESENCE_EXEMPT)
    hard_stale = sorted(
        s
        for s in VERIFY_CI_PRESENCE_EXEMPT
        if s.endswith(".py")
        and s not in invoked
        and s not in presence
        and (s.startswith("Tools/checks/") or s.startswith("scripts/check_"))
    )
    assert missing == [], f"verify-ci prod scripts neither presence nor EXEMPT: {missing}"
    assert hard_stale == [], f"stale VERIFY_CI_PRESENCE_EXEMPT checker entries: {hard_stale}"


def test_verify_ci_multi_hop_prerequisite_script_is_discovered() -> None:
    """Synthetic two-hop: verify-ci → mid-target → hidden checker must be seen by recursive walk."""
    makefile_text = MAKEFILE.read_text(encoding="utf-8")
    lines = makefile_text.splitlines()
    rewritten: list[str] = []
    for line in lines:
        if line.startswith("verify-c1-ownership:") and "verify-hidden-classfix" not in line:
            rewritten.append(line + " verify-hidden-classfix")
        else:
            rewritten.append(line)
    rewritten.append("")
    rewritten.append("verify-hidden-classfix:")
    rewritten.append("\t$(PYTHON_BOOTSTRAP) scripts/check_hidden_classfix.py")
    synthetic = "\n".join(rewritten) + "\n"
    invoked = _scripts_invoked_by_verify_ci(synthetic)
    assert "scripts/check_hidden_classfix.py" in invoked, (
        f"two-hop checker not discovered; sample={sorted(invoked)[:25]}"
    )
    presence = {p.as_posix() for p in required_checker_paths()}
    assert "scripts/check_hidden_classfix.py" not in presence
    # Policy surface: prod checker missing from presence+EXEMPT is a hard fail
    missing = sorted(
        s
        for s in invoked
        if _is_production_checker_script(s)
        and s not in presence
        and s not in VERIFY_CI_PRESENCE_EXEMPT
    )
    assert "scripts/check_hidden_classfix.py" in missing


def main() -> int:
    try:
        test_makefile_checker_roster_is_parseable_and_nonempty()
        test_makefile_exact_filters_match_behavior_gate_ssot()
        test_verify_ci_prod_scripts_are_presence_or_explicit_exempt()
        test_verify_ci_multi_hop_prerequisite_script_is_discovered()
        test_verify_ci_fails_when_a_checker_is_deleted()
    except Exception as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    print("PASS: verify-ci presence/policy/multi-hop gates")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())

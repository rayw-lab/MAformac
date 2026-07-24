#!/usr/bin/env python3
"""Bounded regression suite for closure_path_classifier.py."""

from __future__ import annotations

import importlib.util
import subprocess
import sys
from pathlib import Path

import pytest

REPO = Path(__file__).resolve().parents[1]
CLASSIFIER = REPO / "scripts" / "closure_path_classifier.py"


def _import():
    spec = importlib.util.spec_from_file_location("closure_path_classifier", CLASSIFIER)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def _classify(*changes, references=None):
    mod = _import()
    return mod.classify_changes(list(changes), registry_references=references or set())


def test_empty_input_fails_closed_full() -> None:
    assert _classify().tier == "full"


def test_n1_mixed_docs_and_core_uses_strongest_full() -> None:
    mod = _import()
    result = _classify(mod.Change("M", ("docs/guide.md",)), mod.Change("M", ("Core/X.swift",)))
    assert result.tier == "full"


def test_n2_rename_docs_to_docs_is_ordinary() -> None:
    mod = _import()
    result = _classify(mod.Change("R", ("docs/old.md", "docs/new.md")))
    assert result.tier == "ordinary_docs"


def test_n3_rename_docs_to_core_is_full() -> None:
    mod = _import()
    result = _classify(mod.Change("R", ("docs/old.md", "Core/New.swift")))
    assert result.tier == "full"


def test_n4_unreferenced_ordinary_doc_deletion_stays_ordinary() -> None:
    mod = _import()
    result = _classify(mod.Change("D", ("docs/obsolete.md",)), references={"docs/other.md"})
    assert result.tier == "ordinary_docs"


def test_n5_authority_or_referenced_deletion_is_full() -> None:
    mod = _import()
    authority = _classify(mod.Change("D", ("docs/commander-log/decisions.md",)))
    dynamic = _classify(
        mod.Change("D", ("docs/lessons-learned.md",)),
        references={"docs/lessons-learned.md"},
    )
    assert authority.tier == "full"
    assert dynamic.tier == "full"


@pytest.mark.parametrize("path", ["vendor/x.txt", "node_modules/x.js"])
def test_n6_unknown_root_is_full(path: str) -> None:
    mod = _import()
    assert _classify(mod.Change("M", (path,))).tier == "full"


def test_n7_github_is_full() -> None:
    mod = _import()
    assert _classify(mod.Change("M", (".github/workflows/verify.yml",))).tier == "full"


def test_n8_makefile_is_full() -> None:
    mod = _import()
    assert _classify(mod.Change("M", ("Makefile",))).tier == "full"


@pytest.mark.parametrize(
    "path",
    [
        "docs/commander-log/decisions.md",
        "docs/roadmap-next.md",
        "docs/handoffs/next.md",
        "docs/CURRENT.md",
        "openspec/changes/example/proposal.md",
        "closure/receipts/W8.v1.json",
        "docs/commander-log/COMMANDER-FOO.md",
    ],
)
def test_exact_authority_patterns_are_closure_authority(path: str) -> None:
    mod = _import()
    assert _classify(mod.Change("M", (path,))).tier == "closure_authority"


def test_nul_parser_inspects_both_rename_and_copy_sides() -> None:
    mod = _import()
    changes = mod.parse_name_status_z(
        b"M\0docs/a.md\0R100\0docs/old.md\0Core/new.swift\0C75\0docs/x.md\0docs/y.md\0"
    )
    assert changes == [
        mod.Change("M", ("docs/a.md",)),
        mod.Change("R", ("docs/old.md", "Core/new.swift")),
        mod.Change("C", ("docs/x.md", "docs/y.md")),
    ]


def _completed(args, returncode=0, stdout=b""):
    return subprocess.CompletedProcess(args=args, returncode=returncode, stdout=stdout, stderr=b"")


def test_n9_shallow_repository_forces_full() -> None:
    mod = _import()

    def runner(command, _repo):
        if command[1:3] == ["rev-parse", "--verify"]:
            return _completed(command, stdout=b"abc\n")
        if command[1:] == ["rev-parse", "--is-shallow-repository"]:
            return _completed(command, stdout=b"true\n")
        raise AssertionError(command)

    changes, error = mod.collect_changes(Path("."), base="base", subject="subject", runner=runner)
    assert changes == []
    assert error == "shallow_or_unknown_history"


def test_n10_missing_base_forces_full() -> None:
    mod = _import()

    def runner(command, _repo):
        return _completed(command, returncode=1)

    changes, error = mod.collect_changes(Path("."), base="missing", subject="subject", runner=runner)
    assert changes == []
    assert error == "missing_base"


def test_n11_malformed_name_status_forces_full() -> None:
    mod = _import()

    def runner(command, _repo):
        if command[1:3] == ["rev-parse", "--verify"]:
            return _completed(command, stdout=b"abc\n")
        if command[1:] == ["rev-parse", "--is-shallow-repository"]:
            return _completed(command, stdout=b"false\n")
        if command[1:3] == ["merge-base", "--is-ancestor"]:
            return _completed(command)
        if command[1:3] == ["diff", "--name-status"]:
            return _completed(command, stdout=b"R100\0docs/old.md\0")
        raise AssertionError(command)

    changes, error = mod.collect_changes(Path("."), base="base", subject="subject", runner=runner)
    assert changes == []
    assert error == "name_status_parse_failed"


def _git(repo: Path, *args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *args], cwd=repo, text=True, capture_output=True, check=False
    )


def test_live_collection_unions_staged_unstaged_untracked_and_manifest(tmp_path: Path) -> None:
    mod = _import()
    assert _git(tmp_path, "init", "-q").returncode == 0
    assert _git(tmp_path, "config", "user.email", "test@example.invalid").returncode == 0
    assert _git(tmp_path, "config", "user.name", "Classifier Test").returncode == 0
    (tmp_path / "docs").mkdir()
    (tmp_path / "docs/a.md").write_text("a\n", encoding="utf-8")
    (tmp_path / "docs/b.md").write_text("b\n", encoding="utf-8")
    assert _git(tmp_path, "add", "docs/a.md", "docs/b.md").returncode == 0
    assert _git(tmp_path, "commit", "-qm", "base").returncode == 0
    base = _git(tmp_path, "rev-parse", "HEAD").stdout.strip()

    (tmp_path / "docs/a.md").write_text("staged\n", encoding="utf-8")
    assert _git(tmp_path, "add", "docs/a.md").returncode == 0
    (tmp_path / "docs/b.md").write_text("unstaged\n", encoding="utf-8")
    (tmp_path / "docs/c.md").write_text("untracked\n", encoding="utf-8")
    changes, error = mod.collect_changes(
        tmp_path, base=base, subject="HEAD", manifest_paths=["Core/manifest.swift"]
    )
    assert error is None
    flattened = {path for change in changes for path in change.paths}
    assert {"docs/a.md", "docs/b.md", "docs/c.md", "Core/manifest.swift"} <= flattened
    assert mod.classify_changes(changes).tier == "full"


def test_heavy_pytest_roster_is_exact_stable_name_set() -> None:
    mod = _import()
    assert mod.CLOSURE_HEAVY_TEST_NAMES == (
        "test_registry_only_commit_after_basis_remains_fresh",
        "test_docs_only_commit_after_basis_remains_fresh",
        "test_core_change_after_basis_is_stale",
        "test_unsynchronized_roadmap_generated_table_is_not_guarded_by_staleness",
    )
    assert mod.pytest_deselect_args().count("--deselect") == 4
    source = (REPO / mod.CLOSURE_PYTEST_MODULE).read_text(encoding="utf-8")
    import re

    source_functions = set(re.findall(r"^def (test_[A-Za-z0-9_]+)", source, re.MULTILINE))
    assert len(source_functions) == 20
    assert set(mod.CLOSURE_HEAVY_TEST_NAMES) <= source_functions
    assert len(source_functions - set(mod.CLOSURE_HEAVY_TEST_NAMES)) == 16


if __name__ == "__main__":
    raise SystemExit(pytest.main([__file__, "-q"]))

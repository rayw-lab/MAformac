#!/usr/bin/env python3
"""Fail-closed three-tier classifier for closure verification."""

from __future__ import annotations

import argparse
import fnmatch
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Callable, Sequence

import yaml


CLOSURE_HEAVY_TEST_NAMES: tuple[str, ...] = (
    "test_registry_only_commit_after_basis_remains_fresh",
    "test_docs_only_commit_after_basis_remains_fresh",
    "test_core_change_after_basis_is_stale",
    "test_unsynchronized_roadmap_generated_table_is_not_guarded_by_staleness",
)

CLOSURE_PYTEST_MODULE = "Tests/test_closure_work_packages.py"
TIERS = ("ordinary_docs", "closure_authority", "full")
_TIER_RANK = {tier: rank for rank, tier in enumerate(TIERS)}

_AUTHORITY_PATTERNS: tuple[str, ...] = (
    "docs/commander-log/decisions.md",
    "docs/roadmap-*.md",
    "docs/handoffs/*.md",
    "docs/CURRENT.md",
    "openspec/changes/**",
    "closure/receipts/**",
    "docs/commander-log/COMMANDER-*.md",
)


@dataclass(frozen=True)
class Change:
    status: str
    paths: tuple[str, ...]


@dataclass(frozen=True)
class Classification:
    tier: str
    reason: str


def _normalize_path(path: str) -> str:
    normalized = path.strip().replace("\\", "/")
    while normalized.startswith("./"):
        normalized = normalized[2:]
    return normalized


def _is_authority(path: str) -> bool:
    return any(fnmatch.fnmatchcase(path, pattern) for pattern in _AUTHORITY_PATTERNS)


def _tier_for_path(path: str) -> str:
    if _is_authority(path):
        return "closure_authority"
    if path.startswith("docs/") and path != "docs":
        return "ordinary_docs"
    return "full"


def _strings(value: object):
    if isinstance(value, dict):
        for key, child in value.items():
            yield from _strings(key)
            yield from _strings(child)
    elif isinstance(value, list):
        for child in value:
            yield from _strings(child)
    elif isinstance(value, str):
        yield _normalize_path(value)


def load_registry_references(repo: Path) -> set[str]:
    registry = repo / "contracts/closure-work-packages.v1.yaml"
    payload = yaml.safe_load(registry.read_text(encoding="utf-8"))
    return {
        value
        for value in _strings(payload)
        if value and not value.startswith("/") and "/" in value
    }


def classify_changes(
    changes: Sequence[Change], *, registry_references: set[str] | None = None
) -> Classification:
    if not changes:
        return Classification(tier="full", reason="empty_input_fail_closed")

    references = registry_references or set()
    strongest = "ordinary_docs"
    reason = "all_paths_ordinary_docs"
    for change in changes:
        if change.status not in {"A", "M", "D", "R", "C", "?"} or not change.paths:
            return Classification(tier="full", reason="malformed_change_fail_closed")
        for raw_path in change.paths:
            path = _normalize_path(raw_path)
            if not path:
                return Classification(tier="full", reason="empty_path_fail_closed")
            if change.status == "D" and (_is_authority(path) or path in references):
                return Classification(tier="full", reason=f"referenced_deletion:{path}")
            tier = _tier_for_path(path)
            if _TIER_RANK[tier] > _TIER_RANK[strongest]:
                strongest = tier
                reason = f"strongest_path:{path}"
    return Classification(tier=strongest, reason=reason)


def classify_changed_paths(changed_paths: list[str]) -> Classification:
    """Compatibility surface for callers with only modified path names."""
    return classify_changes([Change("M", (_normalize_path(path),)) for path in changed_paths])


def parse_name_status_z(payload: bytes) -> list[Change]:
    if not payload:
        return []
    tokens = payload.split(b"\0")
    if tokens[-1] != b"":
        raise ValueError("name-status output is not NUL-terminated")
    tokens.pop()
    changes: list[Change] = []
    index = 0
    while index < len(tokens):
        try:
            status_token = tokens[index].decode("ascii")
        except UnicodeDecodeError as exc:
            raise ValueError("non-ASCII status token") from exc
        index += 1
        status = status_token[:1]
        path_count = 2 if status in {"R", "C"} else 1
        if status not in {"A", "M", "D", "R", "C"} or index + path_count > len(tokens):
            raise ValueError(f"unsupported or truncated status: {status_token!r}")
        try:
            paths = tuple(tokens[index + offset].decode("utf-8") for offset in range(path_count))
        except UnicodeDecodeError as exc:
            raise ValueError("path is not UTF-8") from exc
        index += path_count
        changes.append(Change(status=status, paths=paths))
    return changes


Runner = Callable[[Sequence[str], Path], subprocess.CompletedProcess[bytes]]


def _run(command: Sequence[str], repo: Path) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run(command, cwd=repo, capture_output=True, check=False)


def collect_changes(
    repo: Path,
    *,
    base: str,
    subject: str,
    manifest_paths: Sequence[str] = (),
    runner: Runner = _run,
) -> tuple[list[Change], str | None]:
    if not base or not subject:
        return [], "missing_base_or_subject"
    for ref_name, ref in (("base", base), ("subject", subject)):
        result = runner(["git", "rev-parse", "--verify", f"{ref}^{{commit}}"], repo)
        if result.returncode != 0:
            return [], f"missing_{ref_name}"
    shallow = runner(["git", "rev-parse", "--is-shallow-repository"], repo)
    if shallow.returncode != 0 or shallow.stdout.strip() != b"false":
        return [], "shallow_or_unknown_history"
    ancestry = runner(["git", "merge-base", "--is-ancestor", base, subject], repo)
    if ancestry.returncode != 0:
        return [], "missing_ancestry"

    commands = (
        ["git", "diff", "--name-status", "-z", base, subject],
        ["git", "diff", "--name-status", "-z", "HEAD"],
    )
    changes: list[Change] = []
    try:
        for command in commands:
            result = runner(command, repo)
            if result.returncode != 0:
                return [], "git_diff_failed"
            changes.extend(parse_name_status_z(result.stdout))
    except ValueError:
        return [], "name_status_parse_failed"

    untracked = runner(["git", "ls-files", "--others", "--exclude-standard", "-z"], repo)
    if untracked.returncode != 0:
        return [], "untracked_collection_failed"
    try:
        tokens = untracked.stdout.split(b"\0")
        if tokens[-1] != b"":
            raise ValueError
        changes.extend(Change("?", (token.decode("utf-8"),)) for token in tokens[:-1] if token)
    except (UnicodeDecodeError, ValueError):
        return [], "untracked_parse_failed"

    # Operator manifests may add conservatively known paths, never hide live changes.
    changes.extend(Change("M", (_normalize_path(path),)) for path in manifest_paths if path.strip())
    return changes, None


def classify_repository(
    repo: Path, *, base: str, subject: str, manifest_paths: Sequence[str] = ()
) -> Classification:
    changes, error = collect_changes(repo, base=base, subject=subject, manifest_paths=manifest_paths)
    if error:
        return Classification(tier="full", reason=error)
    try:
        references = load_registry_references(repo)
    except (OSError, yaml.YAMLError):
        return Classification(tier="full", reason="registry_reference_parse_failed")
    return classify_changes(changes, registry_references=references)


def pytest_deselect_args() -> list[str]:
    args: list[str] = []
    for name in CLOSURE_HEAVY_TEST_NAMES:
        args.extend(["--deselect", f"{CLOSURE_PYTEST_MODULE}::{name}"])
    return args


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Closure verification path classifier")
    sub = parser.add_subparsers(dest="command", required=True)
    tier_cmd = sub.add_parser("tier", help="Classify explicit git base/subject plus live worktree")
    tier_cmd.add_argument("--repo", type=Path, default=Path.cwd())
    tier_cmd.add_argument("--base", required=True)
    tier_cmd.add_argument("--subject", required=True)
    tier_cmd.add_argument("--changed", action="append", default=[], help="Additional path; repeatable")
    tier_cmd.add_argument("--show-reason", action="store_true")
    sub.add_parser("pytest-deselect", help="Print stable-name pytest deselect arguments")

    args = parser.parse_args(argv)
    if args.command == "tier":
        result = classify_repository(
            args.repo.resolve(), base=args.base, subject=args.subject, manifest_paths=args.changed
        )
        print(f"{result.tier}\t{result.reason}" if args.show_reason else result.tier)
        return 0
    if args.command == "pytest-deselect":
        print(" ".join(pytest_deselect_args()))
        return 0
    return 2


if __name__ == "__main__":
    raise SystemExit(main())

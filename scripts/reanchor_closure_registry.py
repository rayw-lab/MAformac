#!/usr/bin/env python3
"""Atomically reanchor the closure registry, all done envelopes, and O1 marker."""

from __future__ import annotations

import argparse
import copy
import json
import os
import stat
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any

import yaml

from check_closure_work_packages import (
    ENVELOPE_VERSION,
    GIT_SHA_RE,
    MARKER_RE,
    ROOT as CHECKER_ROOT,
    StrictLoader,
    artifact_path,
    canonical_json,
    derive_counts,
    file_digest,
    load_json,
    load_yaml,
    read_utf8,
    registry_digest,
    reject_ambiguous_yaml,
    render_generated_block,
    root_path,
    sha256_text,
    source_basis_text,
)


ROOT = Path(__file__).resolve().parents[1]
if ROOT != CHECKER_ROOT:
    raise RuntimeError("reanchor helper and closure checker must share one repository root")


@dataclass
class ReanchorError(Exception):
    code: str
    message: str

    def __str__(self) -> str:
        return f"{self.code}: {self.message}"


@dataclass(frozen=True)
class ReanchorPlan:
    registry_path: Path
    roadmap_path: Path
    envelope_paths: tuple[Path, ...]
    old_registry_digest: str
    new_registry_digest: str
    captured_at: str
    changes: dict[Path, bytes]
    original_bytes: dict[Path, bytes]
    marker_changed: bool
    authority_sha256: str | None
    roadmap_sha256: str


def resolve_path(value: str) -> Path:
    path = Path(value)
    return path.resolve() if path.is_absolute() else (ROOT / path).resolve()


def require_git_commit(value: str, label: str) -> str:
    if not GIT_SHA_RE.fullmatch(value):
        raise ReanchorError("E_SUBJECT_HEAD", f"{label} must be a 40-character lowercase git SHA")
    result = subprocess.run(
        ["git", "cat-file", "-e", f"{value}^{{commit}}"],
        cwd=ROOT,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        raise ReanchorError("E_SUBJECT_HEAD", f"{label} is not a reachable local commit: {value}")
    return value


def format_yaml_scalar(value: str) -> str:
    if all(character.isalnum() or character in "._/-" for character in value):
        return value
    return "'" + value.replace("'", "''") + "'"


def replace_top_level_scalar(raw: str, section: str, key: str, value: str) -> str:
    lines = raw.splitlines(keepends=True)
    section_indices = [index for index, line in enumerate(lines) if line.rstrip("\r\n") == f"{section}:"]
    if len(section_indices) != 1:
        raise ReanchorError("E_REGISTRY_EDIT", f"expected one top-level section {section!r}")
    start = section_indices[0] + 1
    end = len(lines)
    for index in range(start, len(lines)):
        stripped = lines[index].rstrip("\r\n")
        if stripped and not stripped[0].isspace() and not stripped.startswith("#"):
            end = index
            break
    matches = [
        index
        for index in range(start, end)
        if lines[index].startswith(f"  {key}:")
    ]
    if len(matches) != 1:
        raise ReanchorError("E_REGISTRY_EDIT", f"expected one {section}.{key} scalar")
    newline = "\r\n" if lines[matches[0]].endswith("\r\n") else "\n"
    lines[matches[0]] = f"  {key}: {format_yaml_scalar(value)}{newline}"
    return "".join(lines)


def parse_registry_text(raw: str) -> dict[str, Any]:
    reject_ambiguous_yaml(raw)
    try:
        value = yaml.load(raw, Loader=StrictLoader)
    except yaml.YAMLError as exc:
        raise ReanchorError("E_REGISTRY_EDIT", f"mutated registry is invalid YAML: {exc}") from exc
    if not isinstance(value, dict):
        raise ReanchorError("E_REGISTRY_EDIT", "registry must remain a mapping")
    return value


def mutate_registry_text(
    original: str,
    registry: dict[str, Any],
    *,
    bind_head: str,
    captured_at: str,
    roadmap_sha256: str,
    authority_sha256: str | None,
) -> str:
    result = original
    result = replace_top_level_scalar(result, "basis", "repo_head", bind_head)
    result = replace_top_level_scalar(result, "basis", "captured_at", captured_at)
    result = replace_top_level_scalar(result, "basis", "roadmap_sha256", roadmap_sha256)
    result = replace_top_level_scalar(result, "source_snapshot", "repo_head", bind_head)
    result = replace_top_level_scalar(result, "source_snapshot", "source_sha256", roadmap_sha256)
    if authority_sha256 is not None:
        result = replace_top_level_scalar(result, "authority", "source_sha256", authority_sha256)
    parsed = parse_registry_text(result)
    if canonical_json(parsed) != canonical_json(registry):
        raise ReanchorError("E_REGISTRY_EDIT", "text mutation and in-memory registry diverged")
    return result


def load_envelope_payload(path: Path) -> dict[str, Any]:
    if not path.is_file():
        raise ReanchorError("E_DONE_ENVELOPE_MISSING", f"missing done envelope: {path}")
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise ReanchorError("E_DONE_ENVELOPE_INVALID", f"invalid done envelope: {path}") from exc
    if not isinstance(payload, dict):
        raise ReanchorError("E_DONE_ENVELOPE_INVALID", f"done envelope is not an object: {path}")
    return payload


def resolve_done_envelopes(registry: dict[str, Any]) -> tuple[list[dict[str, Any]], list[Path]]:
    packages = registry.get("packages")
    if not isinstance(packages, list):
        raise ReanchorError("E_DONE_SET", "registry packages must be a list")
    done_packages = [package for package in packages if package["execution_state"]["declared"] == "done"]
    counts = derive_counts(packages)
    if len(done_packages) != counts["done"]:
        raise ReanchorError("E_DONE_SET", "derived done count disagrees with done package set")
    if counts["done"] > 0 and not done_packages:
        raise ReanchorError("E_DONE_SET", "done package set unexpectedly empty")

    paths: list[Path] = []
    seen_paths: set[Path] = set()
    done_ids = {package["id"] for package in done_packages}
    for package in done_packages:
        exit_receipt = package.get("exit_receipt", {})
        artifact = exit_receipt.get("artifact")
        if not isinstance(artifact, dict):
            raise ReanchorError("E_DONE_ENVELOPE_MISSING", f"{package['id']} has no exit artifact")
        try:
            path = artifact_path(registry, artifact).resolve()
        except Exception as exc:
            raise ReanchorError("E_DONE_ENVELOPE_INVALID", f"unsafe exit artifact for {package['id']}") from exc
        if path in seen_paths:
            raise ReanchorError("E_DONE_SET", f"done packages share one envelope path: {path}")
        payload = load_envelope_payload(path)
        if payload.get("schema_version") != ENVELOPE_VERSION:
            raise ReanchorError("E_DONE_ENVELOPE_INVALID", f"wrong schema for {path}")
        if payload.get("package_id") != package["id"]:
            raise ReanchorError("E_DONE_ENVELOPE_INVALID", f"package id mismatch in {path}")
        # Registry execution_state is the done-set SSOT.  Do not reinterpret
        # package-native status vocabulary here (for example W1 currently uses
        # DONE while its historical success_values contract still says PASS).
        seen_paths.add(path)
        paths.append(path)

    repo_root = root_path(registry, "repo").resolve()
    scan_dir = repo_root / "closure" / "receipts"
    scanned: set[Path] = set()
    if scan_dir.is_dir():
        for candidate in sorted(scan_dir.glob("*.v1.json")):
            payload = load_envelope_payload(candidate)
            if payload.get("schema_version") != ENVELOPE_VERSION:
                continue
            package_id = payload.get("package_id")
            if package_id not in done_ids or candidate.resolve() not in seen_paths:
                raise ReanchorError("E_GHOST_ENVELOPE", f"unregistered done envelope: {candidate}")
            scanned.add(candidate.resolve())
    expected_scanned = {
        path for path in seen_paths if path.parent == scan_dir.resolve()
    }
    if scanned != expected_scanned:
        missing = sorted(str(path) for path in expected_scanned - scanned)
        raise ReanchorError("E_DONE_ENVELOPE_MISSING", f"done envelope scan mismatch: {missing}")
    return done_packages, paths


def authority_digest(registry: dict[str, Any]) -> str:
    source = registry.get("authority", {}).get("source_path")
    if not isinstance(source, str):
        raise ReanchorError("E_AUTHORITY_PATH", "authority.source_path must be a string")
    path = Path(source)
    if path.is_absolute() or ".." in path.parts:
        raise ReanchorError("E_AUTHORITY_PATH", f"unsafe authority path: {source}")
    resolved = (ROOT / path).resolve()
    try:
        resolved.relative_to(ROOT)
    except ValueError as exc:
        raise ReanchorError("E_AUTHORITY_PATH", f"authority path escapes repo: {source}") from exc
    if not resolved.is_file():
        raise ReanchorError("E_AUTHORITY_PATH", f"authority source missing: {source}")
    return file_digest(resolved)


def build_plan(args: argparse.Namespace, bind_head: str) -> ReanchorPlan:
    registry_path = resolve_path(args.registry)
    roadmap_path = resolve_path(args.roadmap)
    registry = load_yaml(registry_path)
    if not isinstance(registry, dict):
        raise ReanchorError("E_REGISTRY", "registry must be a mapping")
    roadmap_text = read_utf8(roadmap_path)
    marker_matches = list(MARKER_RE.finditer(roadmap_text))
    if len(marker_matches) != 1:
        raise ReanchorError("E_MARKER_COUNT", f"expected exactly one O1 marker, found {len(marker_matches)}")

    declared_roadmap = registry.get("basis", {}).get("roadmap_path")
    declared_snapshot = registry.get("source_snapshot", {}).get("source_path")
    if not isinstance(declared_roadmap, str) or not isinstance(declared_snapshot, str):
        raise ReanchorError("E_ROADMAP_PATH", "registry roadmap paths must be strings")
    if resolve_path(declared_roadmap) != roadmap_path or resolve_path(declared_snapshot) != roadmap_path:
        raise ReanchorError("E_ROADMAP_PATH", "CLI roadmap must match basis and source_snapshot paths")

    done_packages, envelope_paths = resolve_done_envelopes(registry)
    old_digest = registry_digest(registry)
    captured_at = datetime.now().astimezone().isoformat(timespec="seconds")
    roadmap_sha256 = sha256_text(source_basis_text(roadmap_text))
    refreshed_authority = authority_digest(registry) if args.refresh_authority_sha else None

    mutated = copy.deepcopy(registry)
    mutated["basis"]["repo_head"] = bind_head
    mutated["basis"]["captured_at"] = captured_at
    mutated["basis"]["roadmap_sha256"] = roadmap_sha256
    mutated["source_snapshot"]["repo_head"] = bind_head
    mutated["source_snapshot"]["source_sha256"] = roadmap_sha256
    if refreshed_authority is not None:
        mutated["authority"]["source_sha256"] = refreshed_authority
    new_digest = registry_digest(mutated)

    registry_text = mutate_registry_text(
        read_utf8(registry_path),
        mutated,
        bind_head=bind_head,
        captured_at=captured_at,
        roadmap_sha256=roadmap_sha256,
        authority_sha256=refreshed_authority,
    )
    changes: dict[Path, bytes] = {registry_path: registry_text.encode("utf-8")}
    for package, path in zip(done_packages, envelope_paths):
        payload = load_envelope_payload(path)
        if payload.get("package_id") != package["id"]:
            raise ReanchorError("E_DONE_ENVELOPE_INVALID", f"package id mismatch in {path}")
        payload["registry_digest"] = new_digest
        changes[path] = (json.dumps(payload, ensure_ascii=False, indent=2) + "\n").encode("utf-8")

    generated = render_generated_block(mutated)
    rendered_roadmap, replacement_count = MARKER_RE.subn("\n" + generated + "\n", roadmap_text)
    if replacement_count != 1:
        raise ReanchorError("E_MARKER_COUNT", f"expected one marker replacement, got {replacement_count}")
    if sha256_text(source_basis_text(rendered_roadmap)) != roadmap_sha256:
        raise ReanchorError("E_ROADMAP_DIGEST", "render changed the roadmap source basis")
    changes[roadmap_path] = rendered_roadmap.encode("utf-8")

    original_bytes = {path: path.read_bytes() for path in changes}
    if len(changes) != len(set(changes)):
        raise ReanchorError("E_TRANSACTION", "transaction contains duplicate paths")
    return ReanchorPlan(
        registry_path=registry_path,
        roadmap_path=roadmap_path,
        envelope_paths=tuple(envelope_paths),
        old_registry_digest=old_digest,
        new_registry_digest=new_digest,
        captured_at=captured_at,
        changes=changes,
        original_bytes=original_bytes,
        marker_changed=original_bytes[roadmap_path] != changes[roadmap_path],
        authority_sha256=refreshed_authority,
        roadmap_sha256=roadmap_sha256,
    )


def stage_bytes(path: Path, content: bytes) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix=f".{path.name}.reanchor-", dir=path.parent)
    temporary_path = Path(temporary)
    try:
        with os.fdopen(descriptor, "wb") as stream:
            stream.write(content)
            stream.flush()
            os.fsync(stream.fileno())
        if path.exists():
            os.chmod(temporary_path, stat.S_IMODE(path.stat().st_mode))
        return temporary_path
    except Exception:
        temporary_path.unlink(missing_ok=True)
        raise


def atomic_write(path: Path, content: bytes) -> None:
    staged = stage_bytes(path, content)
    try:
        os.replace(staged, path)
    finally:
        staged.unlink(missing_ok=True)


def apply_transaction(plan: ReanchorPlan) -> None:
    staged: dict[Path, Path] = {}
    replaced: list[Path] = []
    try:
        for path, content in plan.changes.items():
            staged[path] = stage_bytes(path, content)
        for path in plan.changes:
            os.replace(staged[path], path)
            replaced.append(path)
    except Exception as exc:
        rollback_errors: list[str] = []
        for path in reversed(replaced):
            try:
                atomic_write(path, plan.original_bytes[path])
            except Exception as rollback_exc:  # pragma: no cover - catastrophic filesystem failure
                rollback_errors.append(f"{path}: {rollback_exc}")
        detail = f"transaction failed: {exc}"
        if rollback_errors:
            detail += f"; rollback failures={rollback_errors}"
        raise ReanchorError("E_TRANSACTION", detail) from exc
    finally:
        for path in staged.values():
            path.unlink(missing_ok=True)


def rollback_transaction(plan: ReanchorPlan) -> None:
    errors: list[str] = []
    for path, content in plan.original_bytes.items():
        try:
            atomic_write(path, content)
        except Exception as exc:  # pragma: no cover - catastrophic filesystem failure
            errors.append(f"{path}: {exc}")
    if errors:
        raise ReanchorError("E_ROLLBACK", f"failed to restore original bytes: {errors}")


def verify_applied_plan(plan: ReanchorPlan) -> None:
    registry = load_yaml(plan.registry_path)
    if registry_digest(registry) != plan.new_registry_digest:
        raise ReanchorError("E_POST_ASSERT", "registry digest differs after write")
    for path in plan.envelope_paths:
        payload = load_envelope_payload(path)
        if payload.get("registry_digest") != plan.new_registry_digest:
            raise ReanchorError("E_POST_ASSERT", f"envelope digest differs after write: {path}")
    roadmap_text = read_utf8(plan.roadmap_path)
    matches = list(MARKER_RE.finditer(roadmap_text))
    if len(matches) != 1 or matches[0].group(0).strip() != render_generated_block(registry).strip():
        raise ReanchorError("E_POST_ASSERT", "rendered O1 marker differs after write")


def run_checker(
    args: argparse.Namespace,
    *,
    check_head: str,
    receipt_path: Path,
) -> tuple[int, dict[str, Any]]:
    command = [
        sys.executable,
        str(ROOT / "scripts" / "check_closure_work_packages.py"),
        "check",
        "--registry",
        str(resolve_path(args.registry)),
        "--schema",
        str(resolve_path(args.schema)),
        "--roadmap",
        str(resolve_path(args.roadmap)),
        "--o6-policy",
        str(resolve_path(args.o6_policy)),
        "--subject-head",
        check_head,
        "--receipt",
        str(receipt_path),
    ]
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True, check=False)
    try:
        payload = json.loads(receipt_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ReanchorError("E_CHECKER_RECEIPT", f"checker did not produce a valid receipt: {receipt_path}") from exc
    return result.returncode, payload


def require_checker_pass(rc: int, payload: dict[str, Any], phase: str) -> None:
    if rc != 0 or payload.get("status") != "PASS":
        raise ReanchorError(
            "E_CHECKER_RED",
            f"{phase} checker rc={rc} status={payload.get('status')} errors={payload.get('errors')}",
        )


def summary(
    plan: ReanchorPlan,
    *,
    status: str,
    bind_head: str,
    check_head: str,
    precheck: str,
    postcheck: str,
    writes_performed: bool,
    args: argparse.Namespace,
) -> dict[str, Any]:
    return {
        "status": status,
        "bind_head": bind_head,
        "check_head": check_head,
        "captured_at": plan.captured_at,
        "old_registry_digest": plan.old_registry_digest,
        "new_registry_digest": plan.new_registry_digest,
        "roadmap_sha256": plan.roadmap_sha256,
        "authority_sha256": plan.authority_sha256,
        "envelope_count": len(plan.envelope_paths),
        "envelope_paths": [str(path.relative_to(ROOT)) for path in plan.envelope_paths],
        "marker_replacement_count": 1,
        "marker_changed": plan.marker_changed,
        "precheck": precheck,
        "postcheck": postcheck,
        "postcheck_receipt": None if args.dry_run or args.no_postcheck else str(resolve_path(args.check_receipt)),
        "prose_already_applied": args.prose_already_applied,
        "writes_performed": writes_performed,
    }


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description=__doc__)
    result.add_argument("--bind-head", required=True, help="SHA written to basis and source_snapshot")
    result.add_argument("--check-head", help="SHA passed to checker; defaults to --bind-head")
    result.add_argument("--registry", default="contracts/closure-work-packages.v1.yaml")
    result.add_argument("--roadmap", default="docs/roadmap-2026-07-11-v6-closure-baseline.md")
    result.add_argument("--schema", default="contracts/schemas/closure-work-packages.v1.schema.json")
    result.add_argument("--o6-policy", default="contracts/closure-execution-window.v1.yaml")
    result.add_argument("--check-receipt", default=".build/closure/reanchor-helper-check.v1.json")
    result.add_argument(
        "--refresh-authority",
        "--refresh-authority-sha",
        dest="refresh_authority_sha",
        action="store_true",
        help="refresh authority.source_sha256 (legacy alias: --refresh-authority-sha)",
    )
    result.add_argument("--prose-already-applied", action="store_true")
    result.add_argument("--dry-run", action="store_true")
    result.add_argument("--no-precheck", action="store_true")
    result.add_argument("--no-postcheck", action="store_true")
    result.add_argument("--allow-pre-red", action="store_true")
    return result


def run(args: argparse.Namespace) -> dict[str, Any]:
    bind_head = require_git_commit(args.bind_head, "bind head")
    check_head = require_git_commit(args.check_head or bind_head, "check head")
    if args.allow_pre_red and not args.dry_run:
        raise ReanchorError("E_PRECHECK_POLICY", "--allow-pre-red is restricted to --dry-run diagnostics")

    precheck_status = "SKIPPED"
    if not args.no_precheck:
        with tempfile.TemporaryDirectory(prefix="reanchor-precheck-") as temporary:
            rc, payload = run_checker(
                args,
                check_head=check_head,
                receipt_path=Path(temporary) / "precheck.json",
            )
        if rc == 0 and payload.get("status") == "PASS":
            precheck_status = "PASS"
        elif args.allow_pre_red:
            precheck_status = f"ALLOWED_RED:{','.join(payload.get('errors', []))}"
        else:
            require_checker_pass(rc, payload, "pre")

    plan = build_plan(args, bind_head)
    if args.dry_run:
        return summary(
            plan,
            status="DRY_RUN",
            bind_head=bind_head,
            check_head=check_head,
            precheck=precheck_status,
            postcheck="SKIPPED_DRY_RUN",
            writes_performed=False,
            args=args,
        )

    apply_transaction(plan)
    postcheck_status = "SKIPPED"
    try:
        verify_applied_plan(plan)
        if not args.no_postcheck:
            receipt_path = resolve_path(args.check_receipt)
            rc, payload = run_checker(args, check_head=check_head, receipt_path=receipt_path)
            require_checker_pass(rc, payload, "post")
            postcheck_status = "PASS"
    except Exception:
        rollback_transaction(plan)
        raise

    return summary(
        plan,
        status="PASS",
        bind_head=bind_head,
        check_head=check_head,
        precheck=precheck_status,
        postcheck=postcheck_status,
        writes_performed=True,
        args=args,
    )


def main(argv: list[str]) -> int:
    args = parser().parse_args(argv)
    try:
        result = run(args)
    except ReanchorError as exc:
        print(f"ERROR {exc}", file=sys.stderr)
        return 2
    except Exception as exc:  # fail closed with one observable error surface
        print(f"ERROR E_INTERNAL: {exc}", file=sys.stderr)
        return 2
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

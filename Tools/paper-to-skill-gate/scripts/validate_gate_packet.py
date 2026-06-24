#!/usr/bin/env python3
"""Validate paper-to-skill-gate packets without third-party dependencies."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any


REQUIRED_TOP_LEVEL = {
    "schema_version",
    "generated_at",
    "paper",
    "sources",
    "official_repo",
    "reference_repo_influences",
    "algorithm_traits",
    "maformac_insertion_points",
    "openspec_candidates",
    "deliverables",
    "gate",
    "residual_risks",
}

ALLOWED_PAPER_KEYS = {
    "title",
    "paper_type",
    "year",
    "venue",
    "arxiv_id",
    "doi",
    "identity_confidence",
}

ALLOWED_SOURCE_KEYS = {"label", "url", "evidence_type", "notes"}
ALLOWED_OFFICIAL_REPO_KEYS = {
    "status",
    "repo",
    "url",
    "stars",
    "pushed_at",
    "local_path",
    "local_head",
    "code_mapping_status",
}
ALLOWED_INSERTION_KEYS = {"path", "lane", "recommendation", "proof_class"}
ALLOWED_GATE_KEYS = {"status", "proof_class", "rationale", "stop_conditions"}

GATE_STATUSES = {
    "adopt_now",
    "adopt_after_default_scope",
    "retrain_c5_input",
    "rebuild_c6_input",
    "spike_only",
    "defer",
    "reject",
}

PROOF_CLASSES = {
    "web_verified",
    "local_static_teardown",
    "schema_validated",
    "not_executed",
    "blocked",
}

OFFICIAL_REPO_STATUSES = {
    "cloned",
    "found_not_cloned",
    "no_official_repo_found",
    "not_applicable",
}

CODE_MAPPING_STATUSES = {
    "CODE_CONFIRMED",
    "PAPER_ONLY",
    "CODE_ONLY",
    "CODE_CONFLICT",
    "UNSPECIFIED",
    "NO_REPO",
}

IDENTITY_CONFIDENCE = {
    "live_verified",
    "local_static",
    "paper_only",
    "stale_candidate",
}

SOURCE_EVIDENCE_TYPES = {
    "paper",
    "official_repo",
    "project_page",
    "local_code",
    "web_metadata",
}

REFERENCE_REPO_MARKERS = {
    "paper2code": ("paper2code",),
    "deeppapernote": ("deeppapernote", "deep paper note"),
    "mineru-document-explorer": ("mineru-document-explorer", "mineru document explorer"),
    "paper-qa": ("paper-qa", "paperqa"),
    "mineru": ("mineru:", "mineru "),
    "docling-mcp": ("docling-mcp", "docling mcp"),
}

CHINESE_OUTPUT_GATE_CUTOFF = "2026-06-24T08:49:50Z"
MIN_CHINESE_REPORT_CHARS = 20


class ValidationError(Exception):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValidationError(message)


def require_string(value: Any, path: str) -> None:
    require(isinstance(value, str) and bool(value.strip()), f"{path} must be a non-empty string")


def require_list(value: Any, path: str, min_items: int = 0) -> None:
    require(isinstance(value, list), f"{path} must be a list")
    require(len(value) >= min_items, f"{path} must contain at least {min_items} items")


def require_no_extra_keys(value: dict[str, Any], allowed: set[str], path: str) -> None:
    extras = sorted(set(value) - allowed)
    require(not extras, f"{path} contains unsupported fields: {', '.join(extras)}")


def repo_root() -> Path:
    return Path(__file__).resolve().parents[3]


def gate_root() -> Path:
    return Path(__file__).resolve().parents[1]


def path_exists(value: str) -> bool:
    candidate = Path(value)
    if candidate.is_absolute():
        return candidate.exists()
    return (repo_root() / candidate).exists() or (gate_root() / candidate).exists()


def resolve_path(value: str) -> Path:
    candidate = Path(value)
    if candidate.is_absolute():
        return candidate
    repo_candidate = repo_root() / candidate
    if repo_candidate.exists():
        return repo_candidate
    return gate_root() / candidate


def require_existing_relative_path(value: str, path: str) -> None:
    require_string(value, path)
    require(path_exists(value), f"{path} does not exist: {value}")


def require_reference_repos(values: list[Any], filename: Path) -> None:
    joined = "\n".join(str(value).lower() for value in values)
    missing = []
    for repo_name, markers in REFERENCE_REPO_MARKERS.items():
        if not any(marker in joined for marker in markers):
            missing.append(repo_name)
    require(not missing, f"{filename}: missing reference repo influence markers: {', '.join(missing)}")


def contains_cjk(value: str) -> bool:
    return any(
        "\u3400" <= char <= "\u4dbf"
        or "\u4e00" <= char <= "\u9fff"
        or "\uf900" <= char <= "\ufaff"
        for char in value
    )


def cjk_count(value: str) -> int:
    return sum(
        1
        for char in value
        if "\u3400" <= char <= "\u4dbf"
        or "\u4e00" <= char <= "\u9fff"
        or "\uf900" <= char <= "\ufaff"
    )


def require_chinese_text(value: Any, path: str) -> None:
    require_string(value, path)
    require(contains_cjk(value), f"{path} must contain Chinese narrative text after {CHINESE_OUTPUT_GATE_CUTOFF}")


def should_enforce_chinese_output(packet: dict[str, Any]) -> bool:
    generated_at = packet.get("generated_at")
    return isinstance(generated_at, str) and generated_at >= CHINESE_OUTPUT_GATE_CUTOFF


def validate_chinese_output_gate(packet: dict[str, Any], filename: Path) -> None:
    if not should_enforce_chinese_output(packet):
        return

    for index, source in enumerate(packet["sources"]):
        notes = source.get("notes")
        if notes:
            require_chinese_text(notes, f"{filename}: sources[{index}].notes")

    for index, value in enumerate(packet["reference_repo_influences"]):
        require_chinese_text(value, f"{filename}: reference_repo_influences[{index}]")
    for index, value in enumerate(packet["algorithm_traits"]):
        require_chinese_text(value, f"{filename}: algorithm_traits[{index}]")
    for index, point in enumerate(packet["maformac_insertion_points"]):
        require_chinese_text(point["recommendation"], f"{filename}: maformac_insertion_points[{index}].recommendation")
    for index, value in enumerate(packet["openspec_candidates"]):
        require_chinese_text(value, f"{filename}: openspec_candidates[{index}]")

    gate = packet["gate"]
    require_chinese_text(gate["rationale"], f"{filename}: gate.rationale")
    for index, value in enumerate(gate["stop_conditions"]):
        require_chinese_text(value, f"{filename}: gate.stop_conditions[{index}]")
    for index, value in enumerate(packet["residual_risks"]):
        require_chinese_text(value, f"{filename}: residual_risks[{index}]")

    report_paths = [value for value in packet["deliverables"] if str(value).endswith(".md")]
    require(report_paths, f"{filename}: post-cutover packets must include a Chinese human report deliverable")
    for index, value in enumerate(report_paths):
        report_path = resolve_path(value)
        try:
            content = report_path.read_text(encoding="utf-8")
        except OSError as error:
            raise ValidationError(f"{filename}: deliverables report unreadable: {value}: {error}") from error
        require(
            cjk_count(content) >= MIN_CHINESE_REPORT_CHARS,
            f"{filename}: deliverables[{index}] must contain at least {MIN_CHINESE_REPORT_CHARS} Chinese characters after {CHINESE_OUTPUT_GATE_CUTOFF}",
        )


def validate_packet(packet: dict[str, Any], filename: Path) -> None:
    missing = sorted(REQUIRED_TOP_LEVEL - packet.keys())
    require(not missing, f"{filename}: missing top-level fields: {', '.join(missing)}")
    require_no_extra_keys(packet, REQUIRED_TOP_LEVEL, f"{filename}: root")
    require(packet["schema_version"] == "paper-to-skill-gate.v1", f"{filename}: bad schema_version")

    paper = packet["paper"]
    require(isinstance(paper, dict), f"{filename}: paper must be an object")
    require_no_extra_keys(paper, ALLOWED_PAPER_KEYS, f"{filename}: paper")
    for key in ["title", "paper_type", "identity_confidence"]:
        require_string(paper.get(key), f"{filename}: paper.{key}")
    require(isinstance(paper.get("year"), int), f"{filename}: paper.year must be an integer")
    require(paper["identity_confidence"] in IDENTITY_CONFIDENCE, f"{filename}: invalid paper.identity_confidence")

    require_list(packet["sources"], f"{filename}: sources", min_items=1)
    for index, source in enumerate(packet["sources"]):
        require(isinstance(source, dict), f"{filename}: sources[{index}] must be an object")
        require_no_extra_keys(source, ALLOWED_SOURCE_KEYS, f"{filename}: sources[{index}]")
        require_string(source.get("label"), f"{filename}: sources[{index}].label")
        require_string(source.get("url"), f"{filename}: sources[{index}].url")
        require_string(source.get("evidence_type"), f"{filename}: sources[{index}].evidence_type")
        require(source["evidence_type"] in SOURCE_EVIDENCE_TYPES, f"{filename}: invalid sources[{index}].evidence_type")
        if source["evidence_type"] == "local_code":
            require_existing_relative_path(source["url"], f"{filename}: sources[{index}].url")

    repo = packet["official_repo"]
    require(isinstance(repo, dict), f"{filename}: official_repo must be an object")
    require_no_extra_keys(repo, ALLOWED_OFFICIAL_REPO_KEYS, f"{filename}: official_repo")
    require(repo.get("status") in OFFICIAL_REPO_STATUSES, f"{filename}: invalid official_repo.status")
    require(repo.get("code_mapping_status") in CODE_MAPPING_STATUSES, f"{filename}: invalid code_mapping_status")
    if repo["status"] == "cloned":
        require_string(repo.get("repo"), f"{filename}: official_repo.repo")
        require_string(repo.get("url"), f"{filename}: official_repo.url")
        require_existing_relative_path(repo.get("local_path"), f"{filename}: official_repo.local_path")
        require_string(repo.get("local_head"), f"{filename}: official_repo.local_head")
    if repo["status"] == "no_official_repo_found":
        require(repo["code_mapping_status"] == "NO_REPO", f"{filename}: no repo must use NO_REPO mapping status")

    require_list(packet["reference_repo_influences"], f"{filename}: reference_repo_influences", min_items=6)
    require_reference_repos(packet["reference_repo_influences"], filename)
    require_list(packet["algorithm_traits"], f"{filename}: algorithm_traits", min_items=1)
    require_list(packet["maformac_insertion_points"], f"{filename}: maformac_insertion_points", min_items=3)
    for index, point in enumerate(packet["maformac_insertion_points"]):
        require(isinstance(point, dict), f"{filename}: maformac_insertion_points[{index}] must be an object")
        require_no_extra_keys(point, ALLOWED_INSERTION_KEYS, f"{filename}: maformac_insertion_points[{index}]")
        for key in ["path", "lane", "recommendation"]:
            require_string(point.get(key), f"{filename}: maformac_insertion_points[{index}].{key}")
        require_existing_relative_path(point["path"], f"{filename}: maformac_insertion_points[{index}].path")
        require(point.get("proof_class") in PROOF_CLASSES, f"{filename}: invalid insertion proof_class")

    require_list(packet["deliverables"], f"{filename}: deliverables", min_items=2)
    for index, deliverable in enumerate(packet["deliverables"]):
        require_string(deliverable, f"{filename}: deliverables[{index}]")
        require_existing_relative_path(deliverable, f"{filename}: deliverables[{index}]")

    gate = packet["gate"]
    require(isinstance(gate, dict), f"{filename}: gate must be an object")
    require_no_extra_keys(gate, ALLOWED_GATE_KEYS, f"{filename}: gate")
    require(gate.get("status") in GATE_STATUSES, f"{filename}: invalid gate.status")
    require_list(gate.get("proof_class"), f"{filename}: gate.proof_class", min_items=1)
    for proof in gate["proof_class"]:
        require(proof in PROOF_CLASSES, f"{filename}: invalid gate proof_class {proof}")
    require_string(gate.get("rationale"), f"{filename}: gate.rationale")
    require_list(gate.get("stop_conditions"), f"{filename}: gate.stop_conditions", min_items=1)
    validate_chinese_output_gate(packet, filename)


def main(argv: list[str]) -> int:
    if not argv:
        print("usage: validate_gate_packet.py <packet.gate.json> [...]", file=sys.stderr)
        return 64

    failures: list[str] = []
    for arg in argv:
        path = Path(arg)
        try:
            packet = json.loads(path.read_text(encoding="utf-8"))
            require(isinstance(packet, dict), f"{path}: root must be an object")
            validate_packet(packet, path)
            print(f"PASS {path}")
        except (OSError, json.JSONDecodeError, ValidationError) as error:
            failures.append(f"FAIL {path}: {error}")

    if failures:
        for failure in failures:
            print(failure, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

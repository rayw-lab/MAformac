#!/usr/bin/env python3
"""Detect manifest-scoped expected-label and source-authority conflicts."""

from __future__ import annotations

import argparse
import fnmatch
import json
import re
import sys
import unicodedata
from collections import defaultdict
from pathlib import Path
from typing import Any


Json = dict[str, Any]
REPO_ROOT = Path(__file__).resolve().parents[1]
REQUIRED_MANIFEST_FIELDS = {
    "include_globs",
    "exclude_globs",
    "historical_globs",
    "authority_level",
}
COUNTERFACTUAL_FIELDS = {
    "counterfactual_reason",
    "counterfactual_from_source_sample_id",
    "counterfactual_axis",
    "source_expected_signature",
    "case_expected_signature",
}


def stable_json(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def normalize_text(text: str) -> str:
    text = unicodedata.normalize("NFKC", text).strip().lower()
    text = re.sub(r"\s+", " ", text)
    text = re.sub(r"\s*([;；:=+])\s*", r"\1", text)
    return re.sub(r"[。.!！?？]+$", "", text)


def read_jsonl(path: Path):
    with path.open("r", encoding="utf-8") as handle:
        for line_no, raw in enumerate(handle, 1):
            if not raw.strip():
                continue
            try:
                yield line_no, json.loads(raw)
            except json.JSONDecodeError as exc:
                raise SystemExit(f"invalid JSONL {path}:{line_no}: {exc}") from exc


def manifest_error(message: str) -> None:
    print(f"manifest_error: {message}", file=sys.stderr)
    raise SystemExit(65)


def role_content(row: Json, role: str) -> str:
    for message in row.get("messages") or []:
        if isinstance(message, dict) and message.get("role") == role:
            return str(message.get("content") or "")
    return ""


def input_text(row: Json) -> str:
    for key in ("input_zh", "input_text", "user_text", "utterance", "input"):
        if row.get(key):
            return str(row[key])
    return role_content(row, "user")


def call_name(call: Any) -> str | None:
    if isinstance(call, str):
        return call
    if not isinstance(call, dict):
        return None
    name = call.get("name") or (call.get("function") or {}).get("name")
    return str(name) if name else None


def call_arguments(call: Any) -> Json:
    if not isinstance(call, dict):
        return {}
    arguments = call.get("arguments")
    if isinstance(arguments, dict):
        return dict(sorted(arguments.items()))
    function = call.get("function")
    if isinstance(function, dict) and isinstance(function.get("arguments"), dict):
        return dict(sorted(function["arguments"].items()))
    return {}


def canonical_expected_calls(row: Json) -> list[Json]:
    calls = row.get("expected_tool_calls")
    if calls is None:
        calls = row.get("expected")
    out: list[Json] = []
    for call in calls or []:
        name = call_name(call)
        if name:
            out.append({"name": name, "arguments": call_arguments(call)})
    return sorted(out, key=lambda item: stable_json(item))


def expected_signature(calls: list[Json]) -> str:
    return stable_json(calls)


def row_id(row: Json) -> str | None:
    for key in ("sample_id", "case_id", "source_sample_id"):
        if row.get(key):
            return str(row[key])
    return None


def source_sample_id(row: Json) -> str | None:
    for key in ("source_sample_id", "counterfactual_from_source_sample_id"):
        if row.get(key):
            return str(row[key])
    return None


def load_manifest(path: Path) -> Json:
    try:
        manifest = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        manifest_error(f"missing manifest: {path}")
        raise exc
    except json.JSONDecodeError as exc:
        manifest_error(f"invalid manifest JSON {path}: {exc}")
        raise exc
    missing = sorted(field for field in REQUIRED_MANIFEST_FIELDS if field not in manifest)
    if missing:
        manifest_error(f"{path}: missing required fields {missing}")
    for field in ("include_globs", "exclude_globs", "historical_globs"):
        if not isinstance(manifest.get(field), list) or not all(isinstance(item, str) for item in manifest[field]):
            manifest_error(f"{path}: {field} must be a list of strings")
    if not isinstance(manifest.get("authority_level"), str) or not manifest["authority_level"]:
        manifest_error(f"{path}: authority_level must be a nonempty string")
    return manifest


def expand_globs(patterns: list[str], base_dir: Path) -> list[Path]:
    paths: set[Path] = set()
    for pattern in patterns:
        pattern_path = Path(pattern)
        if pattern_path.is_absolute():
            matched = [Path(item) for item in pattern_path.parent.glob(pattern_path.name)]
            if any(ch in pattern for ch in "*?["):
                paths.update(path.resolve() for path in matched if path.is_file())
            elif pattern_path.is_file():
                paths.add(pattern_path.resolve())
            continue
        paths.update(path.resolve() for path in base_dir.glob(pattern) if path.is_file())
    return sorted(paths)


def matches_any(path: Path, patterns: list[str]) -> bool:
    raw = str(path)
    return any(fnmatch.fnmatch(raw, pattern) or fnmatch.fnmatch(path.name, pattern) for pattern in patterns)


def manifest_paths(manifest: Json, manifest_path: Path, include_historical: bool = False) -> tuple[list[Path], list[str]]:
    base_dir = manifest_path.parent
    include_patterns = list(manifest["include_globs"])
    if include_historical:
        include_patterns += list(manifest.get("historical_globs") or [])
    paths = expand_globs(include_patterns, base_dir)
    exclude_patterns = list(manifest["exclude_globs"])
    historical_patterns = list(manifest["historical_globs"]) if not include_historical else []
    excluded: list[str] = []
    kept: list[Path] = []
    for path in paths:
        if matches_any(path, exclude_patterns) or matches_any(path, historical_patterns):
            excluded.append(str(path))
            continue
        kept.append(path)
    if not kept:
        manifest_error(f"{manifest_path}: include_globs selected no current files")
    return kept, excluded


def source_paths(manifest: Json, manifest_path: Path) -> list[Path]:
    patterns = manifest.get("source_globs") or manifest.get("include_globs") or []
    return expand_globs(list(patterns), manifest_path.parent)


def load_source_index(paths: list[Path]) -> dict[str, Json]:
    index: dict[str, Json] = {}
    for path in paths:
        for line_no, row in read_jsonl(path):
            rid = row_id(row)
            if not rid:
                continue
            if rid not in index:
                index[rid] = {
                    "path": str(path),
                    "line_no": line_no,
                    "input": input_text(row),
                    "expected_tool_calls": canonical_expected_calls(row),
                    "expected_signature": expected_signature(canonical_expected_calls(row)),
                }
    return index


def counterfactual_errors(row: Json, source: Json | None, case_signature: str) -> list[str]:
    present = {field for field in COUNTERFACTUAL_FIELDS if row.get(field) is not None}
    if not present:
        return []
    errors: list[str] = []
    missing = sorted(COUNTERFACTUAL_FIELDS - present)
    if missing:
        errors.append(f"counterfactual missing fields {missing}")
        return errors
    if source is None:
        errors.append("counterfactual source sample not found")
        return errors
    if str(row.get("source_expected_signature")) != str(source["expected_signature"]):
        errors.append("counterfactual source_expected_signature does not match source row")
    if str(row.get("case_expected_signature")) != case_signature:
        errors.append("counterfactual case_expected_signature does not match case row")
    if normalize_text(input_text(row)) == normalize_text(str(source.get("input") or "")):
        errors.append("counterfactual reuses the same natural-language input as source")
    return errors


def source_authority_errors(row: Json, source_index: dict[str, Json], case_signature: str) -> list[str]:
    source_id = source_sample_id(row)
    if not source_id:
        return []
    source = source_index.get(source_id)
    if COUNTERFACTUAL_FIELDS & {field for field in row if row.get(field) is not None}:
        return counterfactual_errors(row, source, case_signature)
    if source is None:
        return [f"source_sample_id {source_id!r} not found in manifest source_globs"]
    if source["expected_signature"] != case_signature:
        return [
            "source expected signature mismatch",
            f"source_expected={source['expected_signature']}",
            f"case_expected={case_signature}",
        ]
    return []


def scan(paths: list[Path], manifest: Json, source_index: dict[str, Json], excluded_paths: list[str]) -> Json:
    groups: dict[str, Json] = {}
    labels_by_input: dict[str, dict[str, Json]] = defaultdict(dict)
    source_errors: list[Json] = []
    row_count = 0
    for path in paths:
        for line_no, row in read_jsonl(path):
            text = input_text(row)
            if not text:
                continue
            expected = canonical_expected_calls(row)
            signature = expected_signature(expected)
            row_source_errors = source_authority_errors(row, source_index, signature)
            if row_source_errors:
                source_errors.append(
                    {
                        "path": str(path),
                        "line_no": line_no,
                        "case_id": row.get("case_id") or row.get("sample_id"),
                        "source_sample_id": source_sample_id(row),
                        "input": text,
                        "expected_tool_calls": expected,
                        "expected_signature": signature,
                        "errors": row_source_errors,
                    }
                )
            normalized = normalize_text(text)
            row_count += 1
            group = groups.setdefault(
                normalized,
                {
                    "input": text,
                    "normalized_input": normalized,
                    "rows": [],
                    "labels": [],
                },
            )
            group["rows"].append(
                {
                    "path": str(path),
                    "line_no": line_no,
                    "case_id": row.get("case_id") or row.get("sample_id"),
                    "expected_tool_calls": expected,
                    "expected_signature": signature,
                }
            )
            labels = labels_by_input[normalized]
            labels.setdefault(
                signature,
                {
                    "label_signature": signature,
                    "expected_tool_calls": expected,
                    "count": 0,
                    "examples": [],
                },
            )
            labels[signature]["count"] += 1
            if len(labels[signature]["examples"]) < 5:
                labels[signature]["examples"].append({"path": str(path), "line_no": line_no})

    conflicts: list[Json] = []
    for normalized, group in groups.items():
        labels = sorted(labels_by_input[normalized].values(), key=lambda item: item["label_signature"])
        group["labels"] = labels
        if len(labels) <= 1:
            continue
        conflicts.append(
            {
                "input": group["input"],
                "normalized_input": normalized,
                "status": "conflicting_expected_signatures",
                "labels": labels,
                "rows": group["rows"][:20],
            }
        )

    conflict_counts: dict[str, int] = defaultdict(int)
    for conflict in conflicts:
        conflict_counts[str(conflict["status"])] += 1
    return {
        "artifact_kind": "label_authority_conflict_scan",
        "scanner_version": "r5-d107-manifest-source-authority-v2",
        "manifest": {
            "run_id": manifest.get("run_id"),
            "authority_level": manifest.get("authority_level"),
            "case_kind": manifest.get("case_kind"),
            "include_globs": manifest.get("include_globs"),
            "exclude_globs": manifest.get("exclude_globs"),
            "historical_globs": manifest.get("historical_globs"),
            "derivative_globs": manifest.get("derivative_globs", []),
        },
        "inputs": [str(path) for path in paths],
        "excluded_paths": excluded_paths,
        "row_count": row_count,
        "unique_input_count": len(groups),
        "conflict_input_count": len(conflicts),
        "conflict_status_counts": dict(sorted(conflict_counts.items())),
        "source_authority_error_count": len(source_errors),
        "status": "pass" if not conflicts and not source_errors else "fail",
        "source_authority_errors": source_errors,
        "conflicts": conflicts,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", required=True, type=Path, help="Manifest with explicit include/exclude/historical globs")
    parser.add_argument("--out-json", type=Path)
    parser.add_argument("--fail-on-conflict", action="store_true")
    parser.add_argument("--audit-historical", action="store_true", help="Scan historical_globs into a separate audit run")
    args = parser.parse_args()

    manifest = load_manifest(args.manifest)
    paths, excluded_paths = manifest_paths(manifest, args.manifest, include_historical=args.audit_historical)
    sources = load_source_index(source_paths(manifest, args.manifest))
    result = scan(paths, manifest, sources, excluded_paths)
    text = json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True)
    if args.out_json:
        args.out_json.parent.mkdir(parents=True, exist_ok=True)
        args.out_json.write_text(text + "\n", encoding="utf-8")
    else:
        print(text)
    if args.fail_on_conflict and result["status"] != "pass":
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

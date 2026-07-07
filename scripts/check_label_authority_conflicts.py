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

from register_classifier import REGISTER_ENUM, classify_register


Json = dict[str, Any]
REPO_ROOT = Path(__file__).resolve().parents[1]
SCANNER_VERSION = "r5-register-window-v3-preassembly-register-risk-key"
RISK_TIER_ENUM = ("R0", "R1", "R2")
FINAL_AUTHORITY_RESERVED_SLOTS = ("mounted_tool_shape", "target_tool_present")
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
NEW_ROW_SOURCE_MARKER_KEYS = (
    "generated_by",
    "generator",
    "generator_id",
    "generator_run_id",
    "generation_batch_id",
    "generation_run_id",
    "register_window_batch_id",
    "register_window_generator",
    "register_window_generator_id",
    "register_window_source",
    "register_window_source_kind",
    "batch",
    "batch_source",
    "batch_generator",
    "row_source",
    "row_source_kind",
    "source_marker",
)
LEGACY_SOURCE_MARKER_VALUES = {"legacy", "historical", "existing", "baseline", "fixture_legacy"}


class ManifestValidationError(RuntimeError):
    pass


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
    raise ManifestValidationError(message)


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


def explicit_metadata_required(manifest: Json) -> bool:
    return bool(
        manifest.get("require_explicit_register_risk_metadata")
        or manifest.get("requires_explicit_register_risk_metadata")
        or manifest.get("register_risk_metadata_required")
    )


def metadata_field(row: Json, keys: tuple[str, ...]) -> tuple[bool, Any, str | None]:
    containers: list[tuple[str, Any]] = [
        ("row", row),
        ("metadata", row.get("metadata")),
        ("tags", row.get("tags")),
        ("label_metadata", row.get("label_metadata")),
        ("register_metadata", row.get("register_metadata")),
    ]
    for container_name, container in containers:
        if not isinstance(container, dict):
            continue
        for key in keys:
            if key in container:
                field_path = key if container_name == "row" else f"{container_name}.{key}"
                return True, container.get(key), field_path
    return False, None, None


def metadata_value(row: Json, keys: tuple[str, ...]) -> Any:
    _, value, _ = metadata_field(row, keys)
    return value


def row_source_marker(row: Json) -> tuple[bool, str | None, Any]:
    present, value, field_path = metadata_field(row, NEW_ROW_SOURCE_MARKER_KEYS)
    if not present:
        return False, None, None
    marker = str(value).strip().lower() if value is not None else ""
    if marker in LEGACY_SOURCE_MARKER_VALUES:
        return False, field_path, value
    return True, field_path, value


def row_requires_explicit_metadata(row: Json, _manifest: Json) -> bool:
    return row_source_marker(row)[0]


def case_identity(row: Json) -> str | None:
    return row.get("case_id") or row.get("sample_id") or row.get("source_sample_id")


def warn_legacy_inferred(
    warnings: list[Json],
    row: Json,
    path: Path,
    line_no: int,
    field: str,
    inferred_value: str,
) -> None:
    warning = {
        "type": "legacy_inferred_metadata",
        "field": field,
        "inferred_value": inferred_value,
        "source": "inferred_regex",
        "path": str(path),
        "line_no": line_no,
        "case_id": case_identity(row),
        "message": f"legacy row missing explicit {field} metadata; inferred {field}={inferred_value}",
    }
    warnings.append(warning)
    print(f"warning: {path}:{line_no}: {warning['message']}", file=sys.stderr)


def sample_register(row: Json, manifest: Json, path: Path, line_no: int, warnings: list[Json]) -> Json:
    classification = classify_register(input_text(row))
    has_explicit, explicit, _ = metadata_field(row, ("register",))
    if not has_explicit:
        if row_requires_explicit_metadata(row, manifest):
            marker_present, marker_field, marker_value = row_source_marker(row)
            marker = f"{marker_field}={marker_value!r}" if marker_present else "manifest_require_explicit"
            manifest_error(f"{path}:{line_no}: missing explicit register metadata for new row source {marker}")
        warn_legacy_inferred(warnings, row, path, line_no, "register", classification.register)
        return {
            "register": classification.register,
            "is_meta_capability_question": classification.is_meta_capability_question,
            "hedged_overlay": classification.hedged_overlay,
            "register_source": "inferred_regex",
        }
    register = str(explicit)
    if explicit is None or not register.strip():
        manifest_error(f"{path}:{line_no}: invalid explicit register metadata {explicit!r}")
    if register not in REGISTER_ENUM:
        manifest_error(f"{path}:{line_no}: unknown register {register!r}")
    return {
        "register": register,
        "is_meta_capability_question": classification.is_meta_capability_question,
        "hedged_overlay": classification.hedged_overlay,
        "register_source": "metadata",
    }


def numeric_speed(row: Json) -> float:
    pre_state = row.get("pre_state")
    if isinstance(pre_state, dict):
        raw = pre_state.get("vehicle.speed")
        try:
            return float(raw)
        except (TypeError, ValueError):
            return 0.0
    return 0.0


def expected_call_names(row: Json) -> str:
    return " ".join(item["name"] for item in canonical_expected_calls(row))


def infer_risk_tier(row: Json) -> str:
    text = input_text(row)
    call_names = expected_call_names(row)
    source_refs = row.get("source_refs")
    risk_rule_ids = source_refs.get("risk_rule_ids") if isinstance(source_refs, dict) else None
    moving_context = numeric_speed(row) > 0 or re.search(r"(行驶中|高速|车速|开车时)", text)
    door_action = re.search(r"(车门|开门|后备箱|尾门)", text + " " + call_names)
    if risk_rule_ids or (moving_context and door_action):
        return "R2"
    broad_window = re.search(r"(全部|所有|全车)", text) and re.search(r"(车窗|天窗|遮阳帘)", text + " " + call_names)
    if broad_window:
        return "R1"
    return "R0"


def sample_risk_tier(row: Json, manifest: Json, path: Path, line_no: int, warnings: list[Json]) -> Json:
    has_explicit, explicit, _ = metadata_field(row, ("risk_tier", "risk_level"))
    if not has_explicit:
        inferred = infer_risk_tier(row)
        if row_requires_explicit_metadata(row, manifest):
            marker_present, marker_field, marker_value = row_source_marker(row)
            marker = f"{marker_field}={marker_value!r}" if marker_present else "manifest_require_explicit"
            manifest_error(f"{path}:{line_no}: missing explicit risk_tier metadata for new row source {marker}")
        warn_legacy_inferred(warnings, row, path, line_no, "risk_tier", inferred)
        return {"risk_tier": inferred, "risk_tier_source": "inferred_regex"}
    risk_tier = str(explicit)
    if explicit is None or not risk_tier.strip():
        manifest_error(f"{path}:{line_no}: invalid explicit risk_tier metadata {explicit!r}")
    if risk_tier not in RISK_TIER_ENUM:
        manifest_error(f"{path}:{line_no}: unknown risk_tier {risk_tier!r}")
    return {"risk_tier": risk_tier, "risk_tier_source": "metadata"}


def pre_assembly_key_payload(normalized_input: str, register: str, risk_tier: str) -> Json:
    return {
        "normalized_input": normalized_input,
        "register": register,
        "risk_tier": risk_tier,
    }


def pre_assembly_key_v2(normalized_input: str, register: str, risk_tier: str) -> str:
    return stable_json(pre_assembly_key_payload(normalized_input, register, risk_tier))


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
    labels_by_key: dict[str, dict[str, Json]] = defaultdict(dict)
    legacy_labels_by_input: dict[str, dict[str, Json]] = defaultdict(dict)
    source_errors: list[Json] = []
    meta_capability_errors: list[Json] = []
    warnings: list[Json] = []
    source_counts: dict[str, int] = defaultdict(int)
    risk_source_counts: dict[str, int] = defaultdict(int)
    total_rows = 0
    for path in paths:
        for line_no, row in read_jsonl(path):
            total_rows += 1
            text = input_text(row)
            if not text:
                continue
            expected = canonical_expected_calls(row)
            signature = expected_signature(expected)
            register_info = sample_register(row, manifest, path, line_no, warnings)
            risk_info = sample_risk_tier(row, manifest, path, line_no, warnings)
            source_counts[str(register_info["register_source"])] += 1
            risk_source_counts[str(risk_info["risk_tier_source"])] += 1
            if register_info["is_meta_capability_question"] and (expected or row.get("expected_state_delta")):
                meta_capability_errors.append(
                    {
                        "path": str(path),
                        "line_no": line_no,
                        "case_id": row.get("case_id") or row.get("sample_id"),
                        "input": text,
                        "register": register_info["register"],
                        "risk_tier": risk_info["risk_tier"],
                        "register_source": register_info["register_source"],
                        "risk_tier_source": risk_info["risk_tier_source"],
                        "expected_tool_calls": expected,
                        "expected_state_delta": row.get("expected_state_delta") or {},
                        "status": "meta_capability_question_must_be_non_mutating",
                    }
                )
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
            key_payload = pre_assembly_key_payload(
                normalized,
                str(register_info["register"]),
                str(risk_info["risk_tier"]),
            )
            key = stable_json(key_payload)
            group = groups.setdefault(
                key,
                {
                    "input": text,
                    "normalized_input": normalized,
                    "pre_assembly_key_v2": key,
                    "pre_assembly_key_v2_payload": key_payload,
                    "register": register_info["register"],
                    "risk_tier": risk_info["risk_tier"],
                    "register_sources": set(),
                    "risk_tier_sources": set(),
                    "rows": [],
                    "labels": [],
                },
            )
            group["register_sources"].add(register_info["register_source"])
            group["risk_tier_sources"].add(risk_info["risk_tier_source"])
            group["rows"].append(
                {
                    "path": str(path),
                    "line_no": line_no,
                    "case_id": row.get("case_id") or row.get("sample_id"),
                    "register": register_info["register"],
                    "risk_tier": risk_info["risk_tier"],
                    "register_source": register_info["register_source"],
                    "risk_tier_source": risk_info["risk_tier_source"],
                    "is_meta_capability_question": register_info["is_meta_capability_question"],
                    "hedged_overlay": register_info["hedged_overlay"],
                    "pre_assembly_key_v2": key,
                    "expected_tool_calls": expected,
                    "expected_signature": signature,
                }
            )
            labels = labels_by_key[key]
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
            legacy_labels = legacy_labels_by_input[normalized]
            legacy_labels.setdefault(
                signature,
                {
                    "label_signature": signature,
                    "expected_tool_calls": expected,
                    "count": 0,
                },
            )
            legacy_labels[signature]["count"] += 1

    conflicts: list[Json] = []
    for _, group in groups.items():
        labels = sorted(labels_by_key[group["pre_assembly_key_v2"]].values(), key=lambda item: item["label_signature"])
        group["labels"] = labels
        if len(labels) <= 1:
            continue
        conflicts.append(
            {
                "input": group["input"],
                "normalized_input": group["normalized_input"],
                "pre_assembly_key_v2": group["pre_assembly_key_v2"],
                "pre_assembly_key_v2_payload": group["pre_assembly_key_v2_payload"],
                "register": group["register"],
                "risk_tier": group["risk_tier"],
                "register_source": "+".join(sorted(group["register_sources"])),
                "risk_tier_source": "+".join(sorted(group["risk_tier_sources"])),
                "status": "conflicting_expected_signatures",
                "labels": labels,
                "rows": group["rows"][:20],
            }
        )

    legacy_conflicts: list[Json] = []
    for normalized, labels_by_signature in legacy_labels_by_input.items():
        if len(labels_by_signature) <= 1:
            continue
        legacy_conflicts.append(
            {
                "normalized_input": normalized,
                "label_signature_count": len(labels_by_signature),
                "labels": sorted(labels_by_signature.values(), key=lambda item: item["label_signature"]),
            }
        )
    current_conflict_inputs = {str(conflict["normalized_input"]) for conflict in conflicts}
    legal_split_allowed = [
        conflict
        for conflict in legacy_conflicts
        if str(conflict["normalized_input"]) not in current_conflict_inputs
    ]

    conflict_counts: dict[str, int] = defaultdict(int)
    for conflict in conflicts:
        conflict_counts[str(conflict["status"])] += 1
    warning_counts: dict[str, int] = defaultdict(int)
    for warning in warnings:
        warning_counts[str(warning["type"])] += 1
    status = "pass" if not conflicts and not source_errors and not meta_capability_errors else "fail"
    return {
        "artifact_kind": "label_authority_conflict_scan",
        "scanner_version": SCANNER_VERSION,
        "basis_id": manifest.get("basis_id") or manifest.get("run_id"),
        "pre_assembly_key_v2_schema": {
            "key_fields": ["normalized_input", "register", "risk_tier"],
            "reserved_final_authority_key_v3_slots": list(FINAL_AUTHORITY_RESERVED_SLOTS),
            "reserved_slots_filled_in_s1": False,
        },
        "manifest": {
            "run_id": manifest.get("run_id"),
            "basis_id": manifest.get("basis_id"),
            "authority_level": manifest.get("authority_level"),
            "case_kind": manifest.get("case_kind"),
            "include_globs": manifest.get("include_globs"),
            "exclude_globs": manifest.get("exclude_globs"),
            "historical_globs": manifest.get("historical_globs"),
            "derivative_globs": manifest.get("derivative_globs", []),
            "require_explicit_register_risk_metadata": explicit_metadata_required(manifest),
        },
        "inputs": [str(path) for path in paths],
        "excluded_paths": excluded_paths,
        "total_rows": total_rows,
        "row_count": total_rows,
        "unique_input_count": len(legacy_labels_by_input),
        "unique_pre_assembly_key_count": len(groups),
        "conflict_input_count": len(conflicts),
        "conflict_status_counts": dict(sorted(conflict_counts.items())),
        "legacy_v1_conflict_input_count": len(legacy_conflicts),
        "legal_register_or_risk_split_allowed_count": len(legal_split_allowed),
        "legal_register_or_risk_split_allowed": legal_split_allowed[:50],
        "register_source_counts": dict(sorted(source_counts.items())),
        "risk_tier_source_counts": dict(sorted(risk_source_counts.items())),
        "warning_count": len(warnings),
        "warning_status_counts": dict(sorted(warning_counts.items())),
        "legacy_inferred_warning_count": warning_counts.get("legacy_inferred_metadata", 0),
        "warnings": warnings,
        "source_authority_error_count": len(source_errors),
        "meta_capability_error_count": len(meta_capability_errors),
        "status": status,
        "source_authority_errors": source_errors,
        "meta_capability_errors": meta_capability_errors,
        "conflicts": conflicts,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", required=True, type=Path, help="Manifest with explicit include/exclude/historical globs")
    parser.add_argument("--out-json", type=Path)
    parser.add_argument("--fail-on-conflict", action="store_true")
    parser.add_argument("--audit-historical", action="store_true", help="Scan historical_globs into a separate audit run")
    args = parser.parse_args()

    try:
        manifest = load_manifest(args.manifest)
        paths, excluded_paths = manifest_paths(manifest, args.manifest, include_historical=args.audit_historical)
        sources = load_source_index(source_paths(manifest, args.manifest))
        result = scan(paths, manifest, sources, excluded_paths)
    except ManifestValidationError as exc:
        print(f"manifest_error: {exc}", file=sys.stderr)
        return 65
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

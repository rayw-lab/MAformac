#!/usr/bin/env python3
"""Check train/eval prompt-text exposure before S9 arm runs.

SELF_TEST_OUTPUT:
2026-07-08 local:
- RED: test_train_eval_exposure.py failed before checker existed, rc=1.
- GREEN: python3 test_train_eval_exposure.py -> test_train_eval_exposure=ok, rc=0.
- CLEAN FIXTURE: same expected tool signature with different user text -> PASS, rc=0.
- POLLUTED FIXTURE: holdout utterance appears in train user text -> FAIL, violation_count=1, rc=66.
- NORMALIZED FIXTURE: punctuation/space variant appears across train/eval -> FAIL, violation_count=1, rc=66.
- NEAR-DUP FIXTURE: A3 light semantic paraphrase -> FAIL, match_kind=near_duplicate_text, rc=66.
- ROUND2 REORDER FIXTURE: word-order paraphrase -> FAIL, score_layer=order_insensitive_char_set, rc=66.
- HASH/FIXTURE FAIL-CLOSED: prompt_hash collision -> rc=66; unfrozen/missing inputs -> rc=65.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import unicodedata
from pathlib import Path
from typing import Any


Json = dict[str, Any]
EXIT_INPUT_ERROR = 65
EXIT_EXPOSURE_VIOLATION = 66
MIN_NORMALIZED_TEXT_LEN = 4
NEAR_DUP_NGRAM_SIZE = 4
DEFAULT_NEAR_DUP_THRESHOLD = 0.60

TEXT_FIELD_NAMES = {
    "utterance",
    "query",
    "text",
    "input",
    "prompt",
    "user_prompt",
    "rendered_prompt",
    "instruction",
    "natural_text",
    "natural_utterance",
    "user_text",
}

PROMPT_HASH_FIELD_NAMES = {
    "prompt_hash",
    "prompt_sha256",
    "utterance_hash",
    "utterance_sha256",
    "query_hash",
    "query_sha256",
    "text_hash",
    "text_sha256",
    "user_prompt_hash",
    "user_prompt_sha256",
}


class InputError(Exception):
    pass


class GateArgumentParser(argparse.ArgumentParser):
    def error(self, message: str) -> None:
        self.print_usage(sys.stderr)
        print(f"{self.prog}: error: {message}", file=sys.stderr)
        raise SystemExit(EXIT_INPUT_ERROR)


CHINESE_DIGITS = {
    "零": 0,
    "〇": 0,
    "一": 1,
    "二": 2,
    "两": 2,
    "三": 3,
    "四": 4,
    "五": 5,
    "六": 6,
    "七": 7,
    "八": 8,
    "九": 9,
}


def chinese_number_to_int(value: str) -> int | None:
    if not value:
        return None
    if value == "十":
        return 10
    if "十" in value:
        left, _, right = value.partition("十")
        tens = CHINESE_DIGITS.get(left, 1 if left == "" else -1)
        ones = CHINESE_DIGITS.get(right, 0 if right == "" else -1)
        if tens < 0 or ones < 0:
            return None
        return tens * 10 + ones
    total = 0
    for char in value:
        digit = CHINESE_DIGITS.get(char)
        if digit is None:
            return None
        total = total * 10 + digit
    return total


def normalize_numeric_slots(value: str) -> str:
    def replace_match(match: re.Match[str]) -> str:
        number = chinese_number_to_int(match.group(0))
        return str(number) if number is not None else match.group(0)

    return re.sub(r"[零〇一二两三四五六七八九十]+", replace_match, value)


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def read_jsonl(path: Path) -> list[tuple[str, Json]]:
    rows: list[tuple[str, Json]] = []
    with path.open("r", encoding="utf-8") as handle:
        for line_no, raw in enumerate(handle, 1):
            if not raw.strip():
                continue
            try:
                row = json.loads(raw)
            except json.JSONDecodeError as exc:
                raise InputError(f"invalid JSONL {path}:{line_no}: {exc}") from exc
            if not isinstance(row, dict):
                raise InputError(f"invalid JSONL {path}:{line_no}: row must be object")
            rows.append((f"{path}:{line_no}", row))
    return rows


def read_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise InputError(f"invalid JSON {path}: {exc}") from exc


def read_records(path: Path) -> list[tuple[str, Json]]:
    if not path.exists():
        raise InputError(f"missing input: {path}")
    if path.is_dir():
        rows: list[tuple[str, Json]] = []
        for candidate in sorted(path.rglob("*.jsonl")) + sorted(path.rglob("*.json")):
            rows.extend(read_records(candidate))
        return rows
    if path.suffix == ".jsonl":
        return read_jsonl(path)
    if path.suffix == ".json":
        payload = read_json(path)
        if isinstance(payload, list):
            return [(f"{path}:{index}", row) for index, row in enumerate(payload) if isinstance(row, dict)]
        if isinstance(payload, dict):
            for key in ("cases", "rows", "eval_cases", "samples"):
                rows = payload.get(key)
                if isinstance(rows, list):
                    return [(f"{path}:{key}:{index}", row) for index, row in enumerate(rows) if isinstance(row, dict)]
            return [(str(path), payload)]
        raise InputError(f"invalid JSON {path}: top-level must be object or array")
    raise InputError(f"unsupported input suffix: {path}")


def row_id(row: Json, location: str) -> str:
    value = row.get("row_id") or row.get("case_id") or row.get("sample_id") or row.get("id")
    return str(value) if value else location


def normalize_text(value: str) -> str:
    normalized = normalize_numeric_slots(unicodedata.normalize("NFKC", value).lower())
    kept: list[str] = []
    for char in normalized:
        category = unicodedata.category(char)
        if category[0] in {"P", "Z", "C"}:
            continue
        kept.append(char)
    return "".join(kept)


def char_ngrams(value: str, size: int = NEAR_DUP_NGRAM_SIZE) -> set[str]:
    if len(value) < size:
        return {value} if value else set()
    return {value[index : index + size] for index in range(len(value) - size + 1)}


def char_set_overlap_score(left: str, right: str) -> Json:
    left_chars = set(left)
    right_chars = set(right)
    if not left_chars or not right_chars:
        return {"jaccard": 0.0, "containment": 0.0, "score": 0.0, "overlap_count": 0}
    overlap = left_chars & right_chars
    jaccard = len(overlap) / len(left_chars | right_chars)
    containment = len(overlap) / min(len(left_chars), len(right_chars))

    # Only promote high-confidence reorder/near-reorder cases. This avoids turning
    # ordinary register variation such as "把空调调到26度" vs "空调能不能调到26度"
    # into a violation just because core slot characters overlap.
    score = max(jaccard, containment) if containment >= 1.0 or jaccard >= 0.9 else 0.0
    return {
        "jaccard": round(jaccard, 6),
        "containment": round(containment, 6),
        "score": round(score, 6),
        "overlap_count": len(overlap),
    }


def near_duplicate_score(left: str, right: str) -> Json:
    left_grams = char_ngrams(left)
    right_grams = char_ngrams(right)
    char_score = char_set_overlap_score(left, right)
    if not left_grams or not right_grams:
        return {
            "jaccard": 0.0,
            "containment": 0.0,
            "score": char_score["score"],
            "score_layer": "order_insensitive_char_set",
            "overlap_count": 0,
            "char_set_jaccard": char_score["jaccard"],
            "char_set_containment": char_score["containment"],
            "char_set_overlap_count": char_score["overlap_count"],
        }
    overlap = left_grams & right_grams
    jaccard = len(overlap) / len(left_grams | right_grams)
    containment = len(overlap) / min(len(left_grams), len(right_grams))
    ngram_score = max(jaccard, containment)
    if ngram_score >= float(char_score["score"]):
        score = ngram_score
        score_layer = "char_ngram"
    else:
        score = float(char_score["score"])
        score_layer = "order_insensitive_char_set"
    return {
        "jaccard": round(jaccard, 6),
        "containment": round(containment, 6),
        "score": round(score, 6),
        "score_layer": score_layer,
        "overlap_count": len(overlap),
        "char_set_jaccard": char_score["jaccard"],
        "char_set_containment": char_score["containment"],
        "char_set_overlap_count": char_score["overlap_count"],
    }


def add_text_token(tokens: list[Json], location: str, row: Json, field: str, value: str) -> None:
    norm = normalize_text(value)
    if len(norm) < MIN_NORMALIZED_TEXT_LEN:
        return
    tokens.append(
        {
            "kind": "normalized_text",
            "key": norm,
            "location": location,
            "row_id": row_id(row, location),
            "field": field,
            "text": value,
        }
    )


def add_hash_token(tokens: list[Json], location: str, row: Json, field: str, value: str) -> None:
    if not value.strip():
        return
    tokens.append(
        {
            "kind": "prompt_hash",
            "key": value.strip(),
            "location": location,
            "row_id": row_id(row, location),
            "field": field,
            "text": value.strip(),
        }
    )


def collect_tokens_from_row(location: str, row: Json) -> list[Json]:
    tokens: list[Json] = []
    for key, value in row.items():
        if isinstance(value, str):
            if key in TEXT_FIELD_NAMES:
                add_text_token(tokens, location, row, key, value)
            elif key in PROMPT_HASH_FIELD_NAMES:
                add_hash_token(tokens, location, row, key, value)

    messages = row.get("messages")
    if isinstance(messages, list):
        for index, message in enumerate(messages):
            if not isinstance(message, dict):
                continue
            role = str(message.get("role", "")).lower()
            content = message.get("content")
            if role in {"user", "human"} and isinstance(content, str):
                add_text_token(tokens, location, row, f"messages[{index}].content", content)

    return tokens


def collect_tokens(records: list[tuple[str, Json]]) -> list[Json]:
    tokens: list[Json] = []
    for location, row in records:
        tokens.extend(collect_tokens_from_row(location, row))
    return tokens


def resolve_manifest_path(manifest_path: Path, raw_path: Any, field: str) -> Path | None:
    if not isinstance(raw_path, str) or not raw_path.strip():
        return None
    if raw_path.startswith("<") or "$" in raw_path:
        raise InputError(f"unresolved manifest path in {field}: {raw_path}")
    path = Path(raw_path).expanduser()
    if not path.is_absolute():
        path = manifest_path.parent / path
    return path.resolve()


def eval_paths_from_manifest(manifest_path: Path, holdout_path: Path) -> tuple[Json, list[Path]]:
    if not manifest_path.exists():
        raise InputError(f"missing eval manifest: {manifest_path}")
    payload = read_json(manifest_path)
    if not isinstance(payload, dict):
        raise InputError(f"invalid eval manifest {manifest_path}: top-level must be object")
    if payload.get("status") != "FROZEN":
        raise InputError(f"eval manifest must be FROZEN, got {payload.get('status')!r}")

    paths: list[Path] = []
    case_path = resolve_manifest_path(manifest_path, payload.get("case_bundle_path"), "case_bundle_path")
    if case_path is not None:
        paths.append(case_path)

    bundles = payload.get("bundles")
    if isinstance(bundles, list):
        for index, bundle in enumerate(bundles):
            if not isinstance(bundle, dict):
                continue
            bundle_path = resolve_manifest_path(manifest_path, bundle.get("path"), f"bundles[{index}].path")
            if bundle_path is not None:
                paths.append(bundle_path)

    paths.append(holdout_path.resolve())
    deduped: list[Path] = []
    seen: set[str] = set()
    for path in paths:
        key = str(path)
        if key not in seen:
            seen.add(key)
            deduped.append(path)
    if not deduped:
        raise InputError("eval manifest did not reference any eval input path")
    for path in deduped:
        if not path.exists():
            raise InputError(f"missing eval input referenced by manifest/checker args: {path}")
    return payload, deduped


def index_tokens(tokens: list[Json]) -> dict[tuple[str, str], list[Json]]:
    index: dict[tuple[str, str], list[Json]] = {}
    for token in tokens:
        key = (str(token["kind"]), str(token["key"]))
        index.setdefault(key, []).append(token)
    return index


def near_duplicate_violations(train_tokens: list[Json], eval_token: Json, threshold: float) -> list[Json]:
    if eval_token.get("kind") != "normalized_text":
        return []
    matches: list[Json] = []
    eval_key = str(eval_token["key"])
    for train_token in train_tokens:
        if train_token.get("kind") != "normalized_text":
            continue
        train_key = str(train_token["key"])
        if train_key == eval_key:
            continue
        score = near_duplicate_score(train_key, eval_key)
        if float(score["score"]) >= threshold:
            match = {key: train_token[key] for key in ("location", "row_id", "field", "text")}
            match.update(
                {
                    "normalized_text": train_key,
                    "near_duplicate_score": score["score"],
                    "near_duplicate_score_layer": score["score_layer"],
                    "near_duplicate_jaccard": score["jaccard"],
                    "near_duplicate_containment": score["containment"],
                    "near_duplicate_overlap_count": score["overlap_count"],
                    "near_duplicate_char_set_jaccard": score["char_set_jaccard"],
                    "near_duplicate_char_set_containment": score["char_set_containment"],
                    "near_duplicate_char_set_overlap_count": score["char_set_overlap_count"],
                }
            )
            matches.append(match)
    matches.sort(key=lambda item: float(item["near_duplicate_score"]), reverse=True)
    return matches


def build_report(trainpack: Path, eval_manifest: Path, holdout: Path, near_dup_threshold: float) -> Json:
    manifest, eval_paths = eval_paths_from_manifest(eval_manifest, holdout)
    train_records = read_records(trainpack)
    eval_records: list[tuple[str, Json]] = []
    for path in eval_paths:
        eval_records.extend(read_records(path))

    train_tokens = collect_tokens(train_records)
    eval_tokens = collect_tokens(eval_records)
    coverage_errors: list[str] = []
    if not train_tokens:
        coverage_errors.append("zero_train_prompt_text_tokens")
    if not eval_tokens:
        coverage_errors.append("zero_eval_prompt_text_tokens")

    train_index = index_tokens(train_tokens)
    violations: list[Json] = []
    for eval_token in eval_tokens:
        matches = train_index.get((str(eval_token["kind"]), str(eval_token["key"])), [])
        if matches:
            violations.append(
                {
                    "match_kind": eval_token["kind"],
                    "eval": {key: eval_token[key] for key in ("location", "row_id", "field", "text")},
                    "train_matches": [
                        {key: match[key] for key in ("location", "row_id", "field", "text")} for match in matches[:5]
                    ],
                    "train_match_count": len(matches),
                }
            )
            continue

        near_matches = near_duplicate_violations(train_tokens, eval_token, near_dup_threshold)
        if near_matches:
            violations.append(
                {
                    "match_kind": "near_duplicate_text",
                    "near_duplicate_threshold": near_dup_threshold,
                    "near_duplicate_ngram_size": NEAR_DUP_NGRAM_SIZE,
                    "eval": {
                        key: eval_token[key] for key in ("location", "row_id", "field", "text")
                    }
                    | {"normalized_text": eval_token["key"]},
                    "train_matches": near_matches[:5],
                    "train_match_count": len(near_matches),
                }
            )

    return {
        "artifact_kind": "train_eval_exposure_check_v1",
        "status": "ERROR" if coverage_errors else ("FAIL" if violations else "PASS"),
        "proof_class": "local",
        "trainpack": str(trainpack),
        "trainpack_sha256": file_sha256(trainpack),
        "eval_manifest": str(eval_manifest),
        "eval_manifest_sha256": file_sha256(eval_manifest),
        "holdout": str(holdout),
        "holdout_sha256": file_sha256(holdout),
        "manifest_artifact_kind": manifest.get("artifact_kind"),
        "manifest_status": manifest.get("status"),
        "eval_input_paths": [str(path) for path in eval_paths],
        "train_record_count": len(train_records),
        "eval_record_count": len(eval_records),
        "train_prompt_text_token_count": len(train_tokens),
        "eval_prompt_text_token_count": len(eval_tokens),
        "near_duplicate_threshold": near_dup_threshold,
        "near_duplicate_ngram_size": NEAR_DUP_NGRAM_SIZE,
        "coverage_errors": coverage_errors,
        "violation_count": len(violations),
        "violations": violations,
    }


def write_report(report: Json, output: Path | None) -> None:
    text = json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True)
    if output:
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(text + "\n", encoding="utf-8")
    print(text)


def main() -> int:
    parser = GateArgumentParser(description=__doc__)
    parser.add_argument("--trainpack", required=True, type=Path, help="S7/S8 training JSONL pack.")
    parser.add_argument("--eval-manifest", required=True, type=Path, help="S9 composite-eval-manifest.json.")
    parser.add_argument("--holdout", required=True, type=Path, help="S9 eval-holdout.jsonl.")
    parser.add_argument("--out", "--output", dest="out", type=Path, help="JSON exposure-ledger report path.")
    parser.add_argument(
        "--near-dup-threshold",
        type=float,
        default=DEFAULT_NEAR_DUP_THRESHOLD,
        help=f"Near-duplicate char n-gram score threshold. Default: {DEFAULT_NEAR_DUP_THRESHOLD}.",
    )
    args = parser.parse_args()
    if not 0 < args.near_dup_threshold <= 1:
        parser.error("--near-dup-threshold must be in (0, 1]")

    try:
        report = build_report(args.trainpack, args.eval_manifest, args.holdout, args.near_dup_threshold)
    except InputError as exc:
        report = {
            "artifact_kind": "train_eval_exposure_check_v1",
            "status": "ERROR",
            "proof_class": "local",
            "input_error": str(exc),
            "coverage_errors": ["input_error"],
            "violation_count": 0,
        }
        write_report(report, args.out)
        print(str(exc), file=sys.stderr)
        return EXIT_INPUT_ERROR

    write_report(report, args.out)
    if report["coverage_errors"]:
        return EXIT_INPUT_ERROR
    return EXIT_EXPOSURE_VIOLATION if report["violation_count"] else 0


if __name__ == "__main__":
    raise SystemExit(main())

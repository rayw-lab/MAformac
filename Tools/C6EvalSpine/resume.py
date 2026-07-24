from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Any

from .identity import subjects_joinable


def atomic_write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    os.replace(tmp, path)


def load_partials(partial_dir: Path) -> list[dict[str, Any]]:
    if not partial_dir.exists():
        return []
    items: list[dict[str, Any]] = []
    for path in sorted(partial_dir.glob("*.json")):
        try:
            payload = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            continue
        if isinstance(payload, dict):
            items.append(payload)
    return items


def write_partial(partial_dir: Path, result: dict[str, Any]) -> Path:
    case_id = str(result.get("case_id") or "unknown")
    arm_id = str(result.get("arm_id") or "unknown")
    path = partial_dir / f"{case_id}.{arm_id}.json"
    atomic_write_json(path, result)
    return path


def check_resume_subject(
    partials: list[dict[str, Any]],
    expected_subject: dict[str, Any],
) -> list[dict[str, str]]:
    errors: list[dict[str, str]] = []
    for item in partials:
        join_keys = item.get("join_keys")
        if not isinstance(join_keys, dict):
            errors.append(
                {
                    "code": "E_RESUME_SUBJECT_DRIFT",
                    "detail": f"partial missing join_keys for {item.get('case_id')}/{item.get('arm_id')}",
                }
            )
            continue
        # Partial stores join equality subset; compare against expected join subset.
        expected_join = {
            k: expected_subject.get(k)
            for k in (
                "repo_head",
                "holdout_sha256",
                "holdout_row_count",
                "b7_assembled_sha256",
                "b7_compat_sha256",
                "b7_unordered_id_set_sha256",
                "b7_is_done",
                "v1_authority_digest",
                "v1_status",
                "prompt_policy_digest",
                "parser_id",
                "mock_state_digest",
                "contract_bundle_digest",
                "selector_corpus_digest",
                "mode",
            )
        }
        if join_keys != expected_join and not subjects_joinable(
            {**expected_subject, **join_keys}, expected_subject
        ):
            # Strict: all equality keys must match.
            if any(join_keys.get(k) != expected_join.get(k) for k in expected_join):
                errors.append(
                    {
                        "code": "E_RESUME_SUBJECT_DRIFT",
                        "detail": (
                            f"subject drift in partial {item.get('case_id')}.{item.get('arm_id')}"
                        ),
                    }
                )
    return errors

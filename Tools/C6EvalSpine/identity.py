from __future__ import annotations

import hashlib
import json
import subprocess
from pathlib import Path
from typing import Any

from .constants import (
    B7_ASSEMBLED_SHA256,
    B7_COMPAT_SHA256,
    B7_UNORDERED_ID_SET_SHA256,
    HOLDOUT_ROW_COUNT,
    HOLDOUT_SHA256,
    REPO_ROOT,
    V1_AUTHORITY_DIGEST,
)
from .modes import Mode


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_text(text: str) -> str:
    return sha256_bytes(text.encode("utf-8"))


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def canonical_json(payload: Any) -> str:
    return json.dumps(payload, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def subject_digest(subject: dict[str, Any]) -> str:
    return sha256_text(canonical_json(subject))


def git_head(repo_root: Path | None = None) -> str:
    root = repo_root or REPO_ROOT
    try:
        proc = subprocess.run(
            ["git", "-C", str(root), "rev-parse", "HEAD"],
            capture_output=True,
            text=True,
            check=False,
        )
        if proc.returncode == 0 and proc.stdout.strip():
            return proc.stdout.strip()
    except OSError:
        pass
    return "0" * 40


def stable_digest(label: str) -> str:
    return sha256_text(f"c6_eval_spine|{label}")


JOIN_EQUALITY_KEYS = (
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


def join_subject_keys(subject: dict[str, Any]) -> dict[str, Any]:
    return {key: subject.get(key) for key in JOIN_EQUALITY_KEYS}


def subjects_joinable(left: dict[str, Any], right: dict[str, Any]) -> bool:
    return join_subject_keys(left) == join_subject_keys(right)


def build_subject(
    *,
    mode: Mode | str,
    run_id: str,
    repo_head: str | None = None,
    holdout_sha256: str = HOLDOUT_SHA256,
    holdout_row_count: int = HOLDOUT_ROW_COUNT,
    b7_assembled_sha256: str = B7_ASSEMBLED_SHA256,
    b7_compat_sha256: str = B7_COMPAT_SHA256,
    b7_unordered_id_set_sha256: str = B7_UNORDERED_ID_SET_SHA256,
    b7_is_done: bool = False,
    v1_authority_digest: str = V1_AUTHORITY_DIGEST,
    v1_status: str = "CANDIDATE",
    prompt_policy_digest: str | None = None,
    parser_id: str = "fixture_parser_v1",
    mock_state_digest: str | None = None,
    contract_bundle_digest: str | None = None,
    selector_corpus_digest: str | None = None,
    seed: int | None = None,
) -> dict[str, Any]:
    mode_value = mode.value if isinstance(mode, Mode) else str(mode)
    subject = {
        "repo_head": repo_head or git_head(),
        "holdout_sha256": holdout_sha256,
        "holdout_row_count": holdout_row_count,
        "b7_assembled_sha256": b7_assembled_sha256,
        "b7_compat_sha256": b7_compat_sha256,
        "b7_unordered_id_set_sha256": b7_unordered_id_set_sha256,
        "b7_is_done": bool(b7_is_done),
        "v1_authority_digest": v1_authority_digest,
        "v1_status": v1_status,
        "prompt_policy_digest": prompt_policy_digest or stable_digest("prompt_policy_v1"),
        "parser_id": parser_id,
        "mock_state_digest": mock_state_digest or stable_digest("mock_state_v1"),
        "contract_bundle_digest": contract_bundle_digest or stable_digest("contract_bundle_v1"),
        "selector_corpus_digest": selector_corpus_digest
        or sha256_text(f"selector|{holdout_sha256}|{holdout_row_count}"),
        "mode": mode_value,
        "run_id": run_id,
        "seed": seed,
        "replay_fingerprint": None,
    }
    subject["replay_fingerprint"] = subject_digest(
        {k: v for k, v in subject.items() if k not in {"run_id", "replay_fingerprint", "seed"}}
    )
    return subject

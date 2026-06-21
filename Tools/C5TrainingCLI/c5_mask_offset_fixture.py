#!/usr/bin/env python3
"""Generate the C5 MLX token-level mask-offset fixture.

The fixture intentionally mirrors mlx-lm 0.31.1 ChatDataset.process:
full tokens come from tokenizer.apply_chat_template(messages, tools=...);
the trained span starts after applying the same template to messages[:-1]
with add_generation_prompt=True when the final row is assistant.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime, timezone
from importlib import metadata
from pathlib import Path
from typing import Any

from transformers import AutoTokenizer


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def load_jsonl(path: Path) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    with path.open("r", encoding="utf-8") as handle:
        for line_no, line in enumerate(handle, start=1):
            stripped = line.strip()
            if not stripped:
                continue
            try:
                rows.append(json.loads(stripped))
            except json.JSONDecodeError as error:
                raise SystemExit(f"{path}:{line_no}: invalid JSON: {error}") from error
    return rows


def select_probe_rows(rows: list[dict[str, Any]], max_per_class: int) -> list[dict[str, Any]]:
    tool_call_rows = [
        row for row in rows
        if row.get("split") == "train" and row.get("expected_tool_calls")
    ][:max_per_class]
    no_call_rows = [
        row for row in rows
        if row.get("split") == "train" and not row.get("expected_tool_calls") and row.get("no_call")
    ][:max_per_class]
    return tool_call_rows + no_call_rows


def expected_start(row: dict[str, Any]) -> str:
    return "<tool_call>" if row.get("expected_tool_calls") else "NO_TOOL"


def assistant_payload(row: dict[str, Any]) -> str:
    messages = row.get("messages") or []
    for message in reversed(messages):
        if message.get("role") == "assistant":
            return str(message.get("content") or "")
    return ""


def probe_row(tokenizer: Any, row: dict[str, Any]) -> dict[str, Any]:
    messages = row.get("messages") or []
    tools = row.get("tools")
    if not messages or messages[-1].get("role") != "assistant":
        return {
            "sample_id": row.get("sample_id", ""),
            "assistant_payload_digest": sha256_text(assistant_payload(row)),
            "expected_start": expected_start(row),
            "offset": 0,
            "length": 0,
            "trained_token_count": 0,
            "trained_span_digest": "",
            "trained_span_starts_with_expected": False,
            "trained_span_contains_user_marker": False,
            "trained_span_contains_system_marker": False,
            "trained_span_contains_think_marker": False,
            "status": "fail",
            "failure_receipt": ["missing_final_assistant_message"],
        }

    full_tokens = tokenizer.apply_chat_template(messages, tools=tools, return_dict=False)
    prompt_tokens = tokenizer.apply_chat_template(
        messages[:-1],
        tools=tools,
        add_generation_prompt=True,
        return_dict=False,
    )
    offset = len(prompt_tokens)
    trained_ids = full_tokens[offset:]
    trained_text = tokenizer.decode(trained_ids, skip_special_tokens=False)
    start = expected_start(row)
    stripped = trained_text.lstrip()
    failures: list[str] = []
    if not stripped.startswith(start):
        failures.append("trained_span_start_mismatch")
    if "<|im_start|>user" in trained_text or "\nuser\n" in trained_text:
        failures.append("trained_span_contains_user")
    if "<|im_start|>system" in trained_text or "\nsystem\n" in trained_text:
        failures.append("trained_span_contains_system")
    if "<think>" in trained_text or "</think>" in trained_text:
        failures.append("trained_span_contains_think")
    if offset <= 0 or len(full_tokens) <= offset or not trained_ids:
        failures.append("invalid_offset_or_empty_trained_span")

    return {
        "sample_id": row.get("sample_id", ""),
        "assistant_payload_digest": sha256_text(assistant_payload(row)),
        "expected_start": start,
        "offset": offset,
        "length": len(full_tokens),
        "trained_token_count": len(trained_ids),
        "trained_span_digest": sha256_text(trained_text),
        "trained_span_starts_with_expected": stripped.startswith(start),
        "trained_span_contains_user_marker": "trained_span_contains_user" in failures,
        "trained_span_contains_system_marker": "trained_span_contains_system" in failures,
        "trained_span_contains_think_marker": "trained_span_contains_think" in failures,
        "status": "pass" if not failures else "fail",
        "failure_receipt": failures,
    }


def package_version(name: str) -> str:
    try:
        return metadata.version(name)
    except metadata.PackageNotFoundError:
        return "unknown"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", required=True)
    parser.add_argument("--samples-jsonl", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--max-per-class", type=int, default=8)
    args = parser.parse_args()

    rows = load_jsonl(Path(args.samples_jsonl))
    probe_rows = select_probe_rows(rows, max_per_class=args.max_per_class)
    failures: list[str] = []
    if not any(row.get("expected_tool_calls") for row in probe_rows):
        failures.append("missing_tool_call_probe_row")
    if any(not row.get("expected_tool_calls") and row.get("no_call") for row in rows):
        if not any(not row.get("expected_tool_calls") for row in probe_rows):
            failures.append("missing_no_call_probe_row")

    tokenizer = AutoTokenizer.from_pretrained(args.model, trust_remote_code=True)
    probes = [probe_row(tokenizer, row) for row in probe_rows]
    failures.extend(
        f"{probe['sample_id']}:{reason}"
        for probe in probes
        for reason in probe["failure_receipt"]
    )
    class_coverage = sorted(
        {
            "tool_call" if probe["expected_start"] == "<tool_call>" else "no_call"
            for probe in probes
            if probe["status"] == "pass"
        }
    )
    payload = {
        "status": "pass" if not failures else "fail",
        "artifact_path": str(Path(args.output).resolve()),
        "artifact_sha256": "",
        "tokenizer_model_id": args.model,
        "mlx_lm_version": package_version("mlx-lm"),
        "transformers_version": package_version("transformers"),
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "sample_count": len(probes),
        "class_coverage": class_coverage,
        "probes": probes,
        "failure_receipt": failures,
    }
    digest_payload = json.dumps(payload, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    payload["artifact_sha256"] = hashlib.sha256(digest_payload.encode("utf-8")).hexdigest()

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
        json.dumps(payload, ensure_ascii=False, sort_keys=True, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"wrote {output}")
    return 0 if payload["status"] == "pass" else 65


if __name__ == "__main__":
    raise SystemExit(main())

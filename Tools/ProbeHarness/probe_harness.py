#!/usr/bin/env python3
"""P3H probe harness for paired base/adapter tool-call checks.

This module intentionally stays outside Core/Training. The real model runner
lazy-loads mlx_lm; tests use a fake runner so contract logic remains source-free.
"""

from __future__ import annotations

import argparse
import inspect
import json
import re
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, Protocol


SYSTEM_PROMPT = "你是 MAformac 离线 mock 车控演示助手。控制路径只输出 tool_call 包裹或 NO_TOOL。"
REQUIRED_STOP_TOKENS = ("</tool_call>", "\n", "\n\n", "\r\n")
TOOL_CALL_START_PATTERN = re.compile(r"<tool_call>\s*", re.DOTALL)
DEFAULT_TOOL_CATALOG = Path("/Users/wanglei/workspace/MAformac/generated/D_domain.tools.demo.json")


class HarnessError(RuntimeError):
    pass


@dataclass(frozen=True)
class DecodeContract:
    temperature: float
    max_tokens: int
    stop_tokens: tuple[str, ...]
    tokenizer_wrapper: str
    prompt_skeleton_id: str
    thinking: str
    parser_id: str
    tool_call_cardinality: str
    output_boundary: str
    tools_mount_policy: str

    @classmethod
    def from_path(cls, path: Path) -> "DecodeContract":
        with path.open("r", encoding="utf-8") as handle:
            payload = json.load(handle)
        return cls.from_payload(payload)

    @classmethod
    def from_payload(cls, payload: dict[str, Any]) -> "DecodeContract":
        required = (
            "temperature",
            "max_tokens",
            "stop_tokens",
            "tokenizer_wrapper",
            "prompt_skeleton_id",
            "thinking",
            "parser_id",
            "tool_call_cardinality",
            "output_boundary",
            "tools_mount_policy",
        )
        missing = [key for key in required if key not in payload]
        if missing:
            raise HarnessError(f"decode_contract_missing:{','.join(missing)}")
        contract = cls(
            temperature=float(payload["temperature"]),
            max_tokens=int(payload["max_tokens"]),
            stop_tokens=tuple(str(token) for token in payload["stop_tokens"]),
            tokenizer_wrapper=str(payload["tokenizer_wrapper"]),
            prompt_skeleton_id=str(payload["prompt_skeleton_id"]),
            thinking=str(payload["thinking"]),
            parser_id=str(payload["parser_id"]),
            tool_call_cardinality=str(payload["tool_call_cardinality"]),
            output_boundary=str(payload["output_boundary"]),
            tools_mount_policy=str(payload["tools_mount_policy"]),
        )
        contract.validate()
        return contract

    def validate(self) -> None:
        if self.temperature != 0:
            raise HarnessError("decode_contract_temperature_must_be_0")
        if self.max_tokens <= 0:
            raise HarnessError("decode_contract_max_tokens_must_be_positive")
        if self.tokenizer_wrapper != "mlx_lm_tokenizer_wrapper":
            raise HarnessError("decode_contract_tokenizer_wrapper_invalid")
        if self.prompt_skeleton_id != "qwen3_patched_no_think_chat_template":
            raise HarnessError("decode_contract_prompt_skeleton_id_invalid")
        if self.thinking != "no_think_block":
            raise HarnessError("decode_contract_thinking_invalid")
        if self.parser_id != "p3h_tool_call_json_ordered_v2":
            raise HarnessError("decode_contract_parser_id_invalid")
        if self.tool_call_cardinality != "ordered_multi_call":
            raise HarnessError("decode_contract_tool_call_cardinality_invalid")
        if self.output_boundary != "raw_generation_and_truncated_output":
            raise HarnessError("decode_contract_output_boundary_invalid")
        if self.tools_mount_policy != "p3h_v3_training_row_or_e2_sg_catalog":
            raise HarnessError("decode_contract_tools_mount_policy_invalid")
        missing = [token for token in REQUIRED_STOP_TOKENS if token not in self.stop_tokens]
        if missing:
            escaped = ",".join(repr(token) for token in missing)
            raise HarnessError(f"decode_contract_missing_required_stop_tokens:{escaped}")

    def as_json(self) -> dict[str, Any]:
        return {
            "temperature": self.temperature,
            "max_tokens": self.max_tokens,
            "stop_tokens": list(self.stop_tokens),
            "tokenizer_wrapper": self.tokenizer_wrapper,
            "prompt_skeleton_id": self.prompt_skeleton_id,
            "thinking": self.thinking,
            "parser_id": self.parser_id,
            "tool_call_cardinality": self.tool_call_cardinality,
            "output_boundary": self.output_boundary,
            "tools_mount_policy": self.tools_mount_policy,
        }


DEFAULT_DECODE_CONTRACT = DecodeContract(
    temperature=0,
    max_tokens=160,
    stop_tokens=REQUIRED_STOP_TOKENS,
    tokenizer_wrapper="mlx_lm_tokenizer_wrapper",
    prompt_skeleton_id="qwen3_patched_no_think_chat_template",
    thinking="no_think_block",
    parser_id="p3h_tool_call_json_ordered_v2",
    tool_call_cardinality="ordered_multi_call",
    output_boundary="raw_generation_and_truncated_output",
    tools_mount_policy="p3h_v3_training_row_or_e2_sg_catalog",
)


@dataclass(frozen=True)
class GenerationResult:
    prompt: str
    raw_generation: str


class ModelRunner(Protocol):
    def generate(
        self,
        *,
        model_path: Path,
        adapter_path: Path | None,
        user_text: str,
        tools: list[dict[str, Any]],
        contract: DecodeContract,
    ) -> GenerationResult:
        ...


class MlxLmRunner:
    def __init__(self) -> None:
        self._cache: dict[tuple[str, str | None], tuple[Any, Any]] = {}

    def generate(
        self,
        *,
        model_path: Path,
        adapter_path: Path | None,
        user_text: str,
        tools: list[dict[str, Any]],
        contract: DecodeContract,
    ) -> GenerationResult:
        try:
            from mlx_lm import generate, load  # type: ignore
        except ModuleNotFoundError as error:
            raise HarnessError("mlx_lm_missing_for_real_probe") from error

        cache_key = (str(model_path), str(adapter_path) if adapter_path else None)
        if cache_key not in self._cache:
            kwargs: dict[str, str] = {}
            if adapter_path is not None:
                kwargs["adapter_path"] = str(adapter_path)
            self._cache[cache_key] = load(str(model_path), **kwargs)
        model, tokenizer = self._cache[cache_key]

        prompt = render_prompt(tokenizer, user_text, tools, contract)
        kwargs = generate_kwargs_for_contract(generate, prompt=prompt, contract=contract)
        output = generate(model, tokenizer, **kwargs)
        return GenerationResult(prompt=prompt, raw_generation=str(output))


def generate_kwargs_for_contract(generate_func: Any, *, prompt: str, contract: DecodeContract) -> dict[str, Any]:
    kwargs: dict[str, Any] = {"prompt": prompt, "max_tokens": contract.max_tokens, "verbose": False}
    signature = inspect.signature(generate_func)
    parameters = signature.parameters
    if "temp" in parameters:
        kwargs["temp"] = contract.temperature
    elif "temperature" in parameters:
        kwargs["temperature"] = contract.temperature
    else:
        generate_step = getattr(generate_func, "__globals__", {}).get("generate_step")
        step_parameters = inspect.signature(generate_step).parameters if generate_step else {}
        if "temp" in step_parameters:
            kwargs["temp"] = contract.temperature
        elif "temperature" in step_parameters:
            kwargs["temperature"] = contract.temperature
        elif "sampler" in step_parameters:
            kwargs["sampler"] = None
        else:
            raise HarnessError("mlx_lm_generate_cannot_enforce_temperature")
    return kwargs


def truncate_at_stop_token(text: str, stop_tokens: Iterable[str]) -> str:
    normalized = text.lstrip()
    positions = [normalized.find(token) for token in stop_tokens if token and normalized.find(token) >= 0]
    if not positions:
        return normalized
    return normalized[: min(positions)]


def render_prompt(tokenizer: Any, user_text: str, tools: list[dict[str, Any]], contract: DecodeContract) -> str:
    if not tools:
        raise HarnessError("invalid_probe_tools_missing")
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": user_text},
    ]
    try:
        prompt = tokenizer.apply_chat_template(messages, tools=tools, tokenize=False, add_generation_prompt=True)
    except Exception as error:
        raise HarnessError("invalid_probe_prompt_render_failed") from error
    validate_prompt_skeleton(prompt, contract, mounted_tool_count=len(tools), prompt_token_count=token_count(tokenizer, prompt))
    return prompt


def token_count(tokenizer: Any, prompt: str) -> int | None:
    encoder = getattr(tokenizer, "encode", None)
    if not callable(encoder):
        return None
    try:
        return len(encoder(prompt))
    except Exception:
        return None


def validate_prompt_skeleton(
    prompt: str,
    contract: DecodeContract,
    *,
    mounted_tool_count: int = 0,
    prompt_token_count: int | None = None,
) -> None:
    if contract.thinking != "no_think_block":
        raise HarnessError("invalid_probe_prompt_thinking_contract")
    if "<think>\n\n</think>" not in prompt:
        raise HarnessError("invalid_probe_prompt_missing_empty_think_block")
    if not prompt.rstrip().endswith("<think>\n\n</think>"):
        raise HarnessError("invalid_probe_prompt_tail_mismatch")
    if "<|im_start|>assistant\n<think>\n\n</think>" not in prompt:
        raise HarnessError("invalid_probe_prompt_assistant_skeleton_mismatch")
    if mounted_tool_count <= 0:
        raise HarnessError("invalid_probe_prompt_missing_tools_mount")
    if "<tools>" not in prompt or "</tools>" not in prompt:
        raise HarnessError("invalid_probe_prompt_missing_tools_section")
    if prompt_token_count is not None and prompt_token_count < 300:
        raise HarnessError("invalid_probe_prompt_tools_token_length_too_short")


def load_cases(path: Path, *, behavior_class: str | None) -> list[dict[str, Any]]:
    cases: list[dict[str, Any]] = []
    with path.open("r", encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, 1):
            if not line.strip():
                continue
            payload = json.loads(line)
            if behavior_class and payload.get("behavior_class") != behavior_class:
                continue
            if "case_id" not in payload or "input_zh" not in payload:
                raise HarnessError(f"{path}:{line_number}:missing_case_id_or_input_zh")
            cases.append(payload)
    return cases


def expected_tool_names(case: dict[str, Any]) -> list[str]:
    return [str(call.get("name", "")) for call in case.get("expected_tool_calls", []) if call.get("name")]


def parse_tool_calls(raw_output: str) -> dict[str, Any]:
    calls: list[dict[str, Any]] = []
    parse_errors: list[dict[str, Any]] = []
    decoder = json.JSONDecoder()
    for match in TOOL_CALL_START_PATTERN.finditer(raw_output):
        candidate = raw_output[match.end() :]
        try:
            payload, _ = decoder.raw_decode(candidate)
        except json.JSONDecodeError:
            parse_errors.append({"offset": match.start(), "error": "json_decode"})
            continue
        if not isinstance(payload, dict):
            parse_errors.append({"offset": match.start(), "error": "tool_call_payload_not_object"})
            continue
        name = payload.get("name")
        arguments = payload.get("arguments", {})
        if not isinstance(name, str) or not name:
            parse_errors.append({"offset": match.start(), "error": "missing_name"})
            continue
        if not isinstance(arguments, dict):
            parse_errors.append({"offset": match.start(), "error": "arguments_not_object", "name": name})
            continue
        calls.append({"name": name, "arguments": arguments})
    calls = collapse_repeated_single_call(calls)
    return {
        "tool_calls": calls,
        "observed_tool_names": [call["name"] for call in calls],
        "parse_errors": parse_errors,
        "tool_call_count": len(calls),
        "has_tail_after_last_tool_call": has_tail_after_last_tool_call(raw_output),
    }


def collapse_repeated_single_call(calls: list[dict[str, Any]]) -> list[dict[str, Any]]:
    if len(calls) <= 1:
        return calls
    first = calls[0]
    if all(call == first for call in calls[1:]):
        return [first]
    return calls


def has_tail_after_last_tool_call(raw_output: str) -> bool:
    last_end = raw_output.rfind("</tool_call>")
    if last_end < 0:
        return bool(raw_output.strip()) and "<tool_call>" in raw_output
    return bool(raw_output[last_end + len("</tool_call>") :].strip())


def extracted_tool_names(raw_output: str) -> list[str]:
    return parse_tool_calls(raw_output)["observed_tool_names"]


def has_tool_call(raw_output: str) -> bool:
    return bool(extracted_tool_names(raw_output))


def axis_for_case(case: dict[str, Any]) -> str:
    tags = case.get("tags") if isinstance(case.get("tags"), dict) else {}
    for key in ("bucket", "sample_kind", "contract_device"):
        if tags.get(key):
            return str(tags[key])
    return str(case.get("behavior_class") or "unknown")


def surface_for_case(case: dict[str, Any]) -> str:
    text = str(case.get("input_zh", ""))
    tags = case.get("tags") if isinstance(case.get("tags"), dict) else {}
    if text.startswith("device=") or "请按这个语义执行" in text:
        return "protocol"
    if tags.get("sample_kind") == "protocol":
        return "protocol"
    return "natural"


def build_tool_mounts(
    cases: list[dict[str, Any]],
    *,
    train_rows: list[dict[str, Any]] | None,
    catalog_rows: list[dict[str, Any]] | None,
) -> dict[str, dict[str, Any]]:
    train_by_id = {
        str(row.get("sample_id")): row
        for row in train_rows or []
        if row.get("sample_id")
    }
    catalog_by_name = {
        str(row.get("function", {}).get("name")): row
        for row in catalog_rows or []
        if row.get("function", {}).get("name")
    }
    catalog_by_sg: dict[str, list[dict[str, Any]]] = {}
    for row in catalog_rows or []:
        sg = row.get("_sg")
        if isinstance(sg, str) and sg:
            catalog_by_sg.setdefault(sg, []).append(row)
    for rows in catalog_by_sg.values():
        rows.sort(key=lambda row: str(row.get("function", {}).get("name", "")))

    mounts: dict[str, dict[str, Any]] = {}
    for case in cases:
        case_id = str(case["case_id"])
        axis = axis_for_case(case)
        if axis in {"A", "B"}:
            sample_id = source_sample_id_for_case(case)
            if not sample_id or sample_id not in train_by_id:
                raise HarnessError(f"invalid_probe_tools_mount_missing:{case_id}:train_row")
            tools = train_by_id[sample_id].get("tools", [])
            if not isinstance(tools, list) or not tools:
                raise HarnessError(f"invalid_probe_tools_mount_missing:{case_id}:train_tools")
            mounts[case_id] = {
                "tools": tools,
                "mount_source": f"train_row:{sample_id}",
                "mount_policy": "training_row_tools_exact",
            }
            continue

        case_tools = case.get("tools")
        if isinstance(case_tools, list) and case_tools:
            mounts[case_id] = {
                "tools": case_tools,
                "mount_source": "case.tools",
                "mount_policy": "case_embedded_tools",
            }
            continue

        expected_names = expected_tool_names(case)
        if not expected_names:
            raise HarnessError(f"invalid_probe_tools_mount_missing:{case_id}:expected_tool_calls")
        if not catalog_rows:
            raise HarnessError(f"invalid_probe_tools_mount_missing:{case_id}:catalog")
        grouped_entries: list[dict[str, Any]] = []
        group_ids: list[str] = []
        for name in expected_names:
            entry = catalog_by_name.get(name)
            if entry is None:
                raise HarnessError(f"invalid_probe_tools_mount_missing:{case_id}:catalog_tool:{name}")
            sg = entry.get("_sg")
            if not isinstance(sg, str) or not sg or sg not in catalog_by_sg:
                raise HarnessError(f"invalid_probe_tools_mount_missing:{case_id}:catalog_sg:{name}")
            group_ids.append(sg)
            grouped_entries.extend(catalog_by_sg[sg])
        tools = dedupe_tools_by_name([catalog_tool_schema(entry) for entry in grouped_entries])
        mounts[case_id] = {
            "tools": tools,
            "mount_source": "catalog_sg:" + ",".join(dict.fromkeys(group_ids)),
            "mount_policy": "e2_sg_full_group",
        }
    return mounts


def source_sample_id_for_case(case: dict[str, Any]) -> str | None:
    for key in ("source_sample_id", "augmentation_parent_id", "sample_id"):
        value = case.get(key)
        if isinstance(value, str) and value:
            return value
    tags = case.get("tags") if isinstance(case.get("tags"), dict) else {}
    for key in ("source_sample_id", "augmentation_parent_id", "sample_id"):
        value = tags.get(key)
        if isinstance(value, str) and value:
            return value
    return None


def catalog_tool_schema(entry: dict[str, Any]) -> dict[str, Any]:
    return {"type": entry.get("type", "function"), "function": entry["function"]}


def dedupe_tools_by_name(tools: list[dict[str, Any]]) -> list[dict[str, Any]]:
    deduped: list[dict[str, Any]] = []
    seen: set[str] = set()
    for tool in tools:
        function = tool.get("function") if isinstance(tool, dict) else None
        name = function.get("name") if isinstance(function, dict) else None
        if not isinstance(name, str) or not name or name in seen:
            continue
        seen.add(name)
        deduped.append(tool)
    return deduped


def run_arm(
    *,
    arm_name: str,
    model_path: Path,
    adapter_path: Path | None,
    cases: list[dict[str, Any]],
    contract: DecodeContract,
    output_dir: Path,
    runner: ModelRunner,
    tool_mounts: dict[str, dict[str, Any]] | None = None,
) -> dict[str, Any]:
    arm_dir = output_dir / arm_name
    arm_dir.mkdir(parents=True, exist_ok=True)
    records: list[dict[str, Any]] = []
    axis_summary: dict[str, dict[str, int]] = {}

    for index, case in enumerate(cases, start=1):
        mount = tool_mount_for_case(case, tool_mounts)
        started = time.time()
        generation = runner.generate(
            model_path=model_path,
            adapter_path=adapter_path,
            user_text=str(case["input_zh"]),
            tools=mount["tools"],
            contract=contract,
        )
        elapsed_ms = int((time.time() - started) * 1000)
        truncated_output = truncate_at_stop_token(generation.raw_generation, contract.stop_tokens)
        parse = parse_tool_calls(generation.raw_generation)
        tool_names = parse["observed_tool_names"]
        non_empty = bool(tool_names)
        axis = axis_for_case(case)
        bucket = axis_summary.setdefault(axis, {"case_count": 0, "empty_tool_call_outputs": 0, "non_empty_tool_call_outputs": 0})
        bucket["case_count"] += 1
        bucket["empty_tool_call_outputs"] += 0 if non_empty else 1
        bucket["non_empty_tool_call_outputs"] += 1 if non_empty else 0

        record = {
            "index": index,
            "case_id": case["case_id"],
            "axis": axis,
            "behavior_class": case.get("behavior_class"),
            "input_zh": case["input_zh"],
            "expected_tool_calls": case.get("expected_tool_calls", []),
            "mounted_tool_count": len(mount["tools"]),
            "mounted_tool_names": mounted_tool_names({"tools": mount["tools"]}),
            "mount_source": mount["mount_source"],
            "mount_policy": mount["mount_policy"],
            "prompt": generation.prompt,
            "raw_generation": generation.raw_generation,
            "truncated_output": truncated_output,
            "raw_output": truncated_output,
            "tool_calls": parse["tool_calls"],
            "has_tool_call": non_empty,
            "empty_tool_call_output": not non_empty,
            "elapsed_ms": elapsed_ms,
            "observed_tool_names": tool_names,
            "tool_call_count": parse["tool_call_count"],
            "parse_errors": parse["parse_errors"],
            "has_tail_after_last_tool_call": parse["has_tail_after_last_tool_call"],
        }
        records.append(record)
        (arm_dir / f"{index:02d}-{case['case_id']}.json").write_text(
            json.dumps(record, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )

    summary = {
        "arm": arm_name,
        "model": str(model_path),
        "adapter": str(adapter_path) if adapter_path else None,
        "decode_contract": contract.as_json(),
        "case_count": len(records),
        "empty_tool_call_outputs": sum(1 for record in records if record["empty_tool_call_output"]),
        "non_empty_tool_call_outputs": sum(1 for record in records if record["has_tool_call"]),
        "axis_summary": axis_summary,
        "results": [
            {
                "case_id": record["case_id"],
                "axis": record["axis"],
                "has_tool_call": record["has_tool_call"],
                "empty_tool_call_output": record["empty_tool_call_output"],
                "tool_call_count": record["tool_call_count"],
                "observed_tool_names": record["observed_tool_names"],
                "mounted_tool_count": record["mounted_tool_count"],
                "mount_source": record["mount_source"],
                "elapsed_ms": record["elapsed_ms"],
            }
            for record in records
        ],
    }
    (arm_dir / "summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return summary


def tool_mount_for_case(case: dict[str, Any], tool_mounts: dict[str, dict[str, Any]] | None) -> dict[str, Any]:
    case_id = str(case["case_id"])
    if tool_mounts and case_id in tool_mounts:
        mount = tool_mounts[case_id]
    else:
        tools = case.get("tools")
        if not isinstance(tools, list) or not tools:
            raise HarnessError(f"invalid_probe_tools_mount_missing:{case_id}")
        mount = {"tools": tools, "mount_source": "case.tools", "mount_policy": "case_embedded_tools"}
    if not isinstance(mount.get("tools"), list) or not mount["tools"]:
        raise HarnessError(f"invalid_probe_tools_mount_missing:{case_id}:empty")
    return mount


def paired_summary(base: dict[str, Any], adapter: dict[str, Any]) -> dict[str, Any]:
    axes = sorted(set(base["axis_summary"]) | set(adapter["axis_summary"]))
    rows = []
    for axis in axes:
        base_axis = base["axis_summary"].get(axis, {})
        adapter_axis = adapter["axis_summary"].get(axis, {})
        base_empty = int(base_axis.get("empty_tool_call_outputs", 0))
        adapter_empty = int(adapter_axis.get("empty_tool_call_outputs", 0))
        rows.append(
            {
                "axis": axis,
                "base_empty": base_empty,
                "adapter_empty": adapter_empty,
                "delta": adapter_empty - base_empty,
            }
        )
    return {"paired_axes": rows}


def overlap_summary(cases: list[dict[str, Any]], train_rows: list[dict[str, Any]]) -> dict[str, Any]:
    train_user_texts = {
        str(message.get("content", "")).strip()
        for row in train_rows
        for message in row.get("messages", [])
        if message.get("role") == "user"
    }
    train_tool_names = {
        tool_name
        for row in train_rows
        for tool_name in expected_tool_names(row) + mounted_tool_names(row)
    }
    expected_calls = [(case["case_id"], name) for case in cases for name in expected_tool_names(case)]
    overlapping_expected_calls = [(case_id, name) for case_id, name in expected_calls if name in train_tool_names]
    per_case_overlap = [
        {
            "case_id": case["case_id"],
            "expected_tool_names": expected_tool_names(case),
            "all_expected_tools_seen_in_train": bool(expected_tool_names(case))
            and all(name in train_tool_names for name in expected_tool_names(case)),
            "utterance_seen_in_train": str(case.get("input_zh", "")).strip() in train_user_texts,
            "surface": surface_for_case(case),
        }
        for case in cases
    ]
    natural_count = sum(1 for case in cases if surface_for_case(case) == "natural")
    protocol_count = sum(1 for case in cases if surface_for_case(case) == "protocol")
    return {
        "case_count": len(cases),
        "per_case_tool_overlap_count": sum(1 for row in per_case_overlap if row["all_expected_tools_seen_in_train"]),
        "unique_expected_tool_overlap_count": len(set(name for _, name in overlapping_expected_calls)),
        "unique_expected_tool_count": len(set(name for _, name in expected_calls)),
        "expected_calls_overlap_count": len(overlapping_expected_calls),
        "expected_calls_count": len(expected_calls),
        "utterance_overlap_count": sum(1 for row in per_case_overlap if row["utterance_seen_in_train"]),
        "natural_vs_protocol": {"natural": natural_count, "protocol": protocol_count},
        "per_case": per_case_overlap,
    }


def mounted_tool_names(row: dict[str, Any]) -> list[str]:
    names: list[str] = []
    for tool in row.get("tools", []):
        function = tool.get("function") if isinstance(tool, dict) else None
        name = function.get("name") if isinstance(function, dict) else None
        if isinstance(name, str) and name:
            names.append(name)
    return names


def load_jsonl(path: Path) -> list[dict[str, Any]]:
    text = path.read_text(encoding="utf-8")
    stripped = text.lstrip()
    if stripped.startswith("["):
        payload = json.loads(text)
        if not isinstance(payload, list):
            raise HarnessError(f"{path}:json_array_expected")
        return payload
    rows: list[dict[str, Any]] = []
    for line in text.splitlines():
        if line.strip():
            rows.append(json.loads(line))
    return rows


def write_receipt(path: Path, payload: dict[str, Any]) -> None:
    lines = [
        "# RECEIPT-P3H",
        "",
        f"status: {payload['status']}",
        "proof_class: local",
        f"output_dir: {payload['output_dir']}",
        "",
        "## Decode Contract",
        "",
        "```json",
        json.dumps(payload["decode_contract"], ensure_ascii=False, indent=2),
        "```",
        "",
        "## Paired Summary",
        "",
        "```json",
        json.dumps(payload.get("paired_summary", {}), ensure_ascii=False, indent=2),
        "```",
        "",
        "## Overlap Summary",
        "",
        "```json",
        json.dumps(payload.get("overlap_summary", {}), ensure_ascii=False, indent=2),
        "```",
        "",
        "## Tools Mount Policy",
        "",
        f"`{payload['decode_contract'].get('tools_mount_policy')}`. A/B axes mount exact training-row tools; C/D axes mount generated catalog `_sg` groups for expected tools. Per-case JSON records include `mounted_tool_count`, `mounted_tool_names`, `mount_source`, and `mount_policy`.",
        "",
        "## Non Claims",
        "",
        "- This receipt does not claim training, C6 acceptance, candidate comparison, V-PASS, S-PASS, or U-PASS.",
        "- Real model probe requires an environment with mlx_lm and explicit run authorization.",
        "",
    ]
    path.write_text("\n".join(lines), encoding="utf-8")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="P3H paired probe harness")
    parser.add_argument("--cases", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--decode-contract", type=Path)
    parser.add_argument("--behavior-class", default="tool_call")
    parser.add_argument("--base-model", required=True, type=Path)
    parser.add_argument("--adapter", type=Path)
    parser.add_argument("--base-only-smoke", action="store_true")
    parser.add_argument("--train-jsonl", type=Path)
    parser.add_argument("--tool-catalog", type=Path, default=DEFAULT_TOOL_CATALOG)
    parser.add_argument("--receipt", type=Path)
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    contract = DecodeContract.from_path(args.decode_contract) if args.decode_contract else DEFAULT_DECODE_CONTRACT
    cases = load_cases(args.cases, behavior_class=args.behavior_class)
    if not cases:
        raise HarnessError("no_cases_selected")
    if args.adapter is None and not args.base_only_smoke:
        raise HarnessError("adapter_required_for_paired_probe")
    args.output_dir.mkdir(parents=True, exist_ok=True)
    train_rows = load_jsonl(args.train_jsonl) if args.train_jsonl else None
    catalog_rows = load_jsonl(args.tool_catalog) if args.tool_catalog else None
    tool_mounts = build_tool_mounts(cases, train_rows=train_rows, catalog_rows=catalog_rows)
    runner = MlxLmRunner()

    base = run_arm(
        arm_name="base",
        model_path=args.base_model,
        adapter_path=None,
        cases=cases,
        contract=contract,
        output_dir=args.output_dir,
        runner=runner,
        tool_mounts=tool_mounts,
    )
    payload: dict[str, Any] = {
        "status": "local_base_smoke_complete" if args.base_only_smoke else "local_paired_probe_complete",
        "proof_class": "base_smoke_not_paired" if args.base_only_smoke else "local_paired_probe",
        "output_dir": str(args.output_dir),
        "decode_contract": contract.as_json(),
        "base_summary": base,
    }
    if args.adapter:
        adapter = run_arm(
            arm_name="adapter",
            model_path=args.base_model,
            adapter_path=args.adapter,
            cases=cases,
            contract=contract,
            output_dir=args.output_dir,
            runner=runner,
            tool_mounts=tool_mounts,
        )
        payload["adapter_summary"] = adapter
        payload["paired_summary"] = paired_summary(base, adapter)
        (args.output_dir / "paired-summary.json").write_text(
            json.dumps(payload["paired_summary"], ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
    if args.train_jsonl:
        payload["overlap_summary"] = overlap_summary(cases, train_rows or [])
        (args.output_dir / "overlap-summary.json").write_text(
            json.dumps(payload["overlap_summary"], ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
    if args.receipt:
        write_receipt(args.receipt, payload)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except HarnessError as error:
        print(f"ERROR {error}", file=sys.stderr)
        raise SystemExit(2)

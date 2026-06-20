#!/usr/bin/env python3
"""Smoke test constrained-output dependencies for MAformac C3.

This is a development-only probe. It verifies that Python Outlines and
XGrammar can handle a MAformac-like ToolCall JSON schema containing the C1/C2
value tuple. It must not be imported by the Swift app or iOS runtime.
"""

from __future__ import annotations

import json
import time
from dataclasses import dataclass
from typing import Any

import xgrammar as xgr
from outlines.types import JsonSchema
from outlines.types.dsl import python_types_to_terms
from xgrammar.testing import _is_grammar_accept_string, _json_schema_to_ebnf


TOOL_CALL_SCHEMA: dict[str, Any] = {
    "type": "object",
    "additionalProperties": False,
    "properties": {
        "name": {"type": "string", "enum": ["apply_vehicle_control"]},
        "arguments": {
            "type": "object",
            "additionalProperties": False,
            "properties": {
                "action": {
                    "type": "string",
                    "enum": ["set_temperature", "set_window_position"],
                },
                "zone": {
                    "type": "string",
                    "enum": ["driver", "passenger", "rear_left", "rear_right", "all"],
                },
                "value": {
                    "type": "object",
                    "additionalProperties": False,
                    "properties": {
                        "ref": {"type": "string", "enum": ["ZERO", "CUR"]},
                        "direct": {"type": "string", "enum": ["+", "-", "="]},
                        "offset": {
                            "anyOf": [
                                {"type": "number"},
                                {
                                    "type": "string",
                                    "enum": [
                                        "LOWER",
                                        "LOW",
                                        "MIDDLE",
                                        "HIGH",
                                        "HIGHER",
                                        "little",
                                        "extreme",
                                    ],
                                },
                            ]
                        },
                        "type": {"type": "string", "enum": ["SPOT", "EXP"]},
                    },
                    "required": ["ref", "direct", "offset", "type"],
                },
            },
            "required": ["action", "zone", "value"],
        },
    },
    "required": ["name", "arguments"],
}


FIXTURES: list[tuple[str, dict[str, Any], bool]] = [
    (
        "valid_spot_number",
        {
            "name": "apply_vehicle_control",
            "arguments": {
                "action": "set_temperature",
                "zone": "driver",
                "value": {"ref": "ZERO", "direct": "=", "offset": 24, "type": "SPOT"},
            },
        },
        True,
    ),
    (
        "valid_exp_token",
        {
            "name": "apply_vehicle_control",
            "arguments": {
                "action": "set_temperature",
                "zone": "all",
                "value": {"ref": "CUR", "direct": "+", "offset": "little", "type": "EXP"},
            },
        },
        True,
    ),
    (
        "invalid_missing_value_type",
        {
            "name": "apply_vehicle_control",
            "arguments": {
                "action": "set_temperature",
                "zone": "driver",
                "value": {"ref": "ZERO", "direct": "=", "offset": 24},
            },
        },
        False,
    ),
    (
        "invalid_extra_property",
        {
            "name": "apply_vehicle_control",
            "arguments": {
                "action": "set_temperature",
                "zone": "driver",
                "value": {
                    "ref": "ZERO",
                    "direct": "=",
                    "offset": 24,
                    "type": "SPOT",
                    "unit": "celsius",
                },
            },
        },
        False,
    ),
]


@dataclass
class TimedResult:
    name: str
    milliseconds: float
    detail: Any


def timed(name: str, block):
    start = time.perf_counter()
    detail = block()
    return TimedResult(name=name, milliseconds=(time.perf_counter() - start) * 1000, detail=detail)


def main() -> None:
    outlines_wrap = timed("outlines_json_schema_wrap", lambda: JsonSchema(TOOL_CALL_SCHEMA))
    outlines_convert = timed("outlines_term_conversion", lambda: python_types_to_terms(outlines_wrap.detail))
    xgrammar_ebnf = timed(
        "xgrammar_schema_to_ebnf",
        lambda: _json_schema_to_ebnf(TOOL_CALL_SCHEMA, strict_mode=True),
    )

    fixture_results = []
    for label, payload, expected in FIXTURES:
        text = json.dumps(payload, separators=(",", ":"), ensure_ascii=True)
        result = timed(
            f"xgrammar_accept_{label}",
            lambda text=text: _is_grammar_accept_string(xgrammar_ebnf.detail, text),
        )
        fixture_results.append(
            {
                "id": label,
                "expected": expected,
                "accepted": result.detail,
                "pass": result.detail == expected,
                "milliseconds": round(result.milliseconds, 3),
            }
        )

    # A tiny synthetic tokenizer is enough to verify compile/matcher plumbing.
    # Real latency must be measured with the Qwen tokenizer in the MLX Swift harness.
    vocab = [bytes([i]) for i in range(32, 127)] + [b"\n", b"\t"]
    tokenizer_info = timed(
        "xgrammar_tokenizer_info_synthetic",
        lambda: xgr.TokenizerInfo(vocab, stop_token_ids=[len(vocab) - 1]),
    )
    compiler = timed("xgrammar_compiler", lambda: xgr.GrammarCompiler(tokenizer_info.detail))
    compiled = timed(
        "xgrammar_compile_json_schema",
        lambda: compiler.detail.compile_json_schema(TOOL_CALL_SCHEMA, strict_mode=True),
    )
    matcher = timed("xgrammar_matcher", lambda: xgr.GrammarMatcher(compiled.detail, terminate_without_stop_token=True))

    summary = {
        "status": "pass" if all(item["pass"] for item in fixture_results) else "fail",
        "schema_bytes": len(json.dumps(TOOL_CALL_SCHEMA, ensure_ascii=True)),
        "outlines": {
            "wrap_ms": round(outlines_wrap.milliseconds, 3),
            "term_conversion_ms": round(outlines_convert.milliseconds, 3),
            "term_type": type(outlines_convert.detail).__name__,
        },
        "xgrammar": {
            "ebnf_ms": round(xgrammar_ebnf.milliseconds, 3),
            "ebnf_bytes": len(xgrammar_ebnf.detail),
            "tokenizer_info_ms": round(tokenizer_info.milliseconds, 3),
            "compiler_ms": round(compiler.milliseconds, 3),
            "compile_json_schema_ms": round(compiled.milliseconds, 3),
            "matcher_ms": round(matcher.milliseconds, 3),
            "compiled_memory_bytes": compiled.detail.memory_size_bytes,
            "serialized_bytes": len(compiled.detail.serialize_json()),
            "fixture_gate_pass": f"{sum(item['pass'] for item in fixture_results)}/{len(fixture_results)}",
        },
        "fixtures": fixture_results,
    }
    print(json.dumps(summary, ensure_ascii=False, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()

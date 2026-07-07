#!/usr/bin/env python3
"""Check eval rows whose expected tool names must be mounted."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


Json = dict[str, Any]
EXIT_INPUT_ERROR = 65
EXIT_MOUNT_VIOLATION = 66


def die_input(message: str) -> None:
    print(message, file=sys.stderr)
    raise SystemExit(EXIT_INPUT_ERROR)


class GateArgumentParser(argparse.ArgumentParser):
    def error(self, message: str) -> None:
        self.print_usage(sys.stderr)
        die_input(f"{self.prog}: error: {message}")


def read_jsonl(path: Path) -> list[tuple[str, Json]]:
    rows: list[tuple[str, Json]] = []
    with path.open("r", encoding="utf-8") as handle:
        for line_no, raw in enumerate(handle, 1):
            if not raw.strip():
                continue
            try:
                row = json.loads(raw)
            except json.JSONDecodeError as exc:
                die_input(f"invalid JSONL {path}:{line_no}: {exc}")
            if not isinstance(row, dict):
                die_input(f"invalid JSONL {path}:{line_no}: row must be object")
            rows.append((f"{path}:{line_no}", row))
    return rows


def read_json(path: Path) -> list[tuple[str, Json]]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        die_input(f"invalid JSON {path}: {exc}")
    if isinstance(payload, dict):
        return [(str(path), payload)]
    if isinstance(payload, list):
        return [(f"{path}[{index}]", row) for index, row in enumerate(payload) if isinstance(row, dict)]
    return []


def iter_input_rows(paths: list[Path]) -> list[tuple[str, Json]]:
    rows: list[tuple[str, Json]] = []
    for path in paths:
        candidates = sorted(path.rglob("*.json")) + sorted(path.rglob("*.jsonl")) if path.is_dir() else [path]
        for candidate in candidates:
            if not candidate.exists():
                die_input(f"missing input: {candidate}")
            if candidate.suffix == ".jsonl":
                rows.extend(read_jsonl(candidate))
            elif candidate.suffix == ".json":
                rows.extend(read_json(candidate))
    return rows


def tool_name(call: Any) -> str | None:
    if isinstance(call, str):
        return call
    if not isinstance(call, dict):
        return None
    name = call.get("name") or (call.get("function") or {}).get("name")
    return str(name) if name else None


def expected_tool_names(row: Json) -> list[str]:
    return [name for call in row.get("expected_tool_calls") or [] if (name := tool_name(call))]


def tool_names_from_tools(tools: Any) -> list[str]:
    names: list[str] = []
    if not isinstance(tools, list):
        return names
    for tool in tools:
        if not isinstance(tool, dict):
            continue
        name = tool_name(tool)
        if name:
            names.append(name)
    return names


def mounted_tool_names(row: Json) -> list[str]:
    direct = row.get("mounted_tool_names")
    if isinstance(direct, list):
        return [str(value) for value in direct if isinstance(value, str) and value]
    shape = row.get("mounted_tool_shape")
    if isinstance(shape, dict):
        mounted = shape.get("mounted_tools")
        if isinstance(mounted, list):
            return [str(value) for value in mounted if isinstance(value, str) and value]
    return tool_names_from_tools(row.get("tools"))


def row_id(row: Json, location: str) -> str:
    value = row.get("case_id") or row.get("sample_id") or row.get("id")
    return str(value) if value else location


def should_skip(row: Json) -> bool:
    return "expected_tool_calls" not in row and "case_id" not in row


def check(rows: list[tuple[str, Json]]) -> Json:
    checked: list[Json] = []
    violations: list[Json] = []
    skipped = 0
    for location, row in rows:
        if should_skip(row):
            skipped += 1
            continue
        expected = expected_tool_names(row)
        mounted = mounted_tool_names(row)
        missing = [name for name in expected if name not in mounted]
        record: Json = {
            "location": location,
            "case_id": row_id(row, location),
            "expected_tool_names": expected,
            "mounted_tool_names": mounted,
        }
        checked.append(record)
        if missing:
            violation = dict(record)
            violation["missing_expected_tool_names"] = missing
            violations.append(violation)

    coverage_error = len(checked) == 0
    return {
        "status": "ERROR" if coverage_error else ("FAIL" if violations else "PASS"),
        "checked_count": len(checked),
        "skipped_count": skipped,
        "coverage_error": coverage_error,
        "coverage_error_reason": "zero_checked_rows" if coverage_error else "",
        "violation_count": len(violations),
        "violations": violations,
    }


def main() -> int:
    parser = GateArgumentParser(description=__doc__)
    parser.add_argument("inputs", nargs="+", type=Path, help="JSONL/JSON bundle or probe output file/directory.")
    parser.add_argument("--output", type=Path, help="Optional JSON report path.")
    args = parser.parse_args()

    report = check(iter_input_rows(args.inputs))
    text = json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(text + "\n", encoding="utf-8")
    print(text)
    if report["coverage_error"]:
        return EXIT_INPUT_ERROR
    return EXIT_MOUNT_VIOLATION if report["violation_count"] else 0


if __name__ == "__main__":
    raise SystemExit(main())

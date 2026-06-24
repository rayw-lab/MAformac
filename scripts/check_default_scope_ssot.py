#!/usr/bin/env python3
from __future__ import annotations

import pathlib
import re
import sys
from typing import Iterable

import yaml

ROOT = pathlib.Path(__file__).resolve().parents[1]
STATE_CELLS = ROOT / "contracts" / "state-cells.yaml"
FORBIDDEN = [
    (ROOT / "Core" / "Execution" / "C3ExecutionPipeline.swift", re.compile(r'\?\?\s*"全车"')),
    (ROOT / "Core" / "Contracts" / "ToolContractCompiler.swift", re.compile(r"scope\.first")),
    (ROOT / "Core" / "Contracts" / "ToolContractCompiler.swift", re.compile(r'\?\?\s*"all"')),
    (ROOT / "Core" / "Contracts" / "ToolContractCompiler.swift", re.compile(r"try\?\s*C2ScopeResolver\.resolve")),
    (ROOT / "Core" / "Contracts" / "ToolContractCompiler.swift", re.compile(r"ScopeResolution\(keys:\s*\[cellID\]")),
]


def fail(message: str) -> None:
    print(f"default-scope-ssot: {message}", file=sys.stderr)
    raise SystemExit(65)


def iter_cells(spec: dict) -> Iterable[dict]:
    for device in (spec.get("devices") or {}).values():
        for cell in device.get("state_cells") or []:
            yield cell
    for section in ("safety_cells", "scenario_cells"):
        for cell in spec.get(section) or []:
            yield cell


def check_forbidden_fallbacks() -> None:
    for path, pattern in FORBIDDEN:
        text = path.read_text(encoding="utf-8")
        for lineno, line in enumerate(text.splitlines(), 1):
            if pattern.search(line):
                fail(f"{path.relative_to(ROOT)}:{lineno} contains forbidden fallback: {line.strip()}")


def check_default_scope_membership() -> None:
    spec = yaml.safe_load(STATE_CELLS.read_text(encoding="utf-8"))
    for cell in iter_cells(spec):
        cid = cell.get("id", "?")
        scope = cell.get("scope") or []
        default_scope = cell.get("default_scope")
        if scope:
            if not isinstance(default_scope, str) or not default_scope:
                fail(f"{cid} missing default_scope")
            if default_scope not in scope:
                fail(f"{cid} default_scope={default_scope!r} not in scope={scope!r}")
        elif "default_scope" in cell:
            fail(f"{cid} declares default_scope without scope")


def main() -> None:
    check_forbidden_fallbacks()
    check_default_scope_membership()
    print("default-scope-ssot: pass")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
REQUIRED = [
    ROOT / "Core" / "Execution" / "ScopeResolution.swift",
    ROOT / "Core" / "Execution" / "C3ExecutionPipeline.swift",
    ROOT / "Core" / "Contracts" / "ContractLookups.swift",
    ROOT / "Core" / "State" / "DemoVehicleStateStore.swift",
    ROOT / "Core" / "Bench" / "C6VehicleToolBench.swift",
]
FORBIDDEN_RECOMPUTE = [
    (ROOT / "Core" / "Contracts" / "ContractLookups.swift", re.compile(r'scope\s*==\s*"主驾"')),
    (ROOT / "Core" / "Execution" / "C3ExecutionPipeline.swift", re.compile(r'scope\s*==\s*"主驾"')),
]


def fail(message: str) -> None:
    print(f"scope-origin-single-source: {message}", file=sys.stderr)
    raise SystemExit(65)


def main() -> None:
    combined = "\n".join(path.read_text(encoding="utf-8") for path in REQUIRED)
    if "enum ScopeOrigin" not in combined:
        fail("ScopeOrigin enum missing")
    for case_name in ("case defaulted", "case explicit", "case fanout"):
        if case_name not in combined:
            fail(f"ScopeOrigin missing {case_name}")
    if combined.count("scopeOrigin") < 4:
        fail("scopeOrigin is not threaded through execution/readback")
    for path, pattern in FORBIDDEN_RECOMPUTE:
        text = path.read_text(encoding="utf-8")
        for lineno, line in enumerate(text.splitlines(), 1):
            if pattern.search(line):
                fail(f"{path.relative_to(ROOT)}:{lineno} recomputes origin from driver string")
    print("scope-origin-single-source: pass")


if __name__ == "__main__":
    main()

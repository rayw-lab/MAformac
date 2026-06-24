#!/usr/bin/env python3
from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
SCOPE_RESOLUTION = ROOT / "Core" / "Execution" / "ScopeResolution.swift"
C3_PIPELINE = ROOT / "Core" / "Execution" / "C3ExecutionPipeline.swift"
READBACK = ROOT / "Core" / "Contracts" / "ContractLookups.swift"
STATE_STORE = ROOT / "Core" / "State" / "DemoVehicleStateStore.swift"
C6_BENCH = ROOT / "Core" / "Bench" / "C6VehicleToolBench.swift"
TOOL_COMPILER = ROOT / "Core" / "Contracts" / "ToolContractCompiler.swift"
REQUIRED = [SCOPE_RESOLUTION, C3_PIPELINE, READBACK, STATE_STORE, C6_BENCH, TOOL_COMPILER]
FORBIDDEN_RECOMPUTE = [
    (ROOT / "Core" / "Contracts" / "ContractLookups.swift", re.compile(r'scope\s*==\s*"主驾"')),
    (ROOT / "Core" / "Execution" / "C3ExecutionPipeline.swift", re.compile(r'scope\s*==\s*"主驾"')),
    (ROOT / "Core" / "Bench" / "C6VehicleToolBench.swift", re.compile(r"C2ScopeResolver\.resolve")),
]


def fail(message: str) -> None:
    print(f"scope-origin-single-source: {message}", file=sys.stderr)
    raise SystemExit(65)


def main() -> None:
    texts = {path: path.read_text(encoding="utf-8") for path in REQUIRED}
    combined = "\n".join(texts.values())
    if "enum ScopeOrigin" not in texts[SCOPE_RESOLUTION]:
        fail("ScopeOrigin enum missing")
    for case_name in ("case defaulted", "case explicit", "case fanout"):
        if case_name not in texts[SCOPE_RESOLUTION]:
            fail(f"ScopeOrigin missing {case_name}")
    if texts[C3_PIPELINE].count("scopeOrigin") < 2:
        fail("C3 execution does not carry typed scopeOrigin")
    if "scopeOrigin: ScopeOrigin?" not in texts[READBACK]:
        fail("readback does not consume typed ScopeOrigin")
    if "scopeOriginEvidence" not in texts[C6_BENCH] or "scope_origin_evidence" not in texts[C6_BENCH]:
        fail("C6 verifier/eval evidence does not expose scope_origin_evidence")
    if "applyWithEvidence" not in texts[TOOL_COMPILER] or "applyWithEvidence" not in texts[C6_BENCH]:
        fail("C6 scope-origin evidence must consume ToolContractStateApplier.applyWithEvidence")
    for path, pattern in FORBIDDEN_RECOMPUTE:
        text = path.read_text(encoding="utf-8")
        for lineno, line in enumerate(text.splitlines(), 1):
            if pattern.search(line):
                fail(f"{path.relative_to(ROOT)}:{lineno} recomputes origin from driver string")
    print("scope-origin-single-source: pass")


if __name__ == "__main__":
    main()

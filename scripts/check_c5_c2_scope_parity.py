#!/usr/bin/env python3
from __future__ import annotations

import pathlib
import re
import sys

import yaml

ROOT = pathlib.Path(__file__).resolve().parents[1]
STATE_CELLS = ROOT / "contracts" / "state-cells.yaml"
C5_SOURCE = ROOT / "Core" / "Training" / "C5LoRATraining.swift"
C5_TESTS = ROOT / "Tests" / "MAformacCoreTests" / "C5LoRATrainingTests.swift"
C5_CLI = ROOT / "Tools" / "C5TrainingCLI" / "main.swift"
STALE_EXECUTABLE_SCOPE = ("左前", "右前", "后排")


def fail(message: str) -> None:
    print(f"c5-c2-scope-parity: {message}", file=sys.stderr)
    raise SystemExit(65)


def c2_window_scopes() -> list[str]:
    spec = yaml.safe_load(STATE_CELLS.read_text(encoding="utf-8"))
    for device in (spec.get("devices") or {}).values():
        for cell in device.get("state_cells") or []:
            if cell.get("id") == "window.position":
                return list(cell.get("scope") or [])
    fail("window.position scope missing from C2")


def main() -> None:
    scopes = c2_window_scopes()
    for required in ("主驾", "副驾", "左后", "右后", "全车"):
        if required not in scopes:
            fail(f"C2 window.position scope missing {required}")

    source = C5_SOURCE.read_text(encoding="utf-8")
    tests = C5_TESTS.read_text(encoding="utf-8")
    cli = C5_CLI.read_text(encoding="utf-8")
    combined = source + tests + cli
    if "C5ScopeCandidateCatalog.scopeCandidatesBySlot(from:" not in combined:
        fail("C5 scope candidates are not derived from C2")
    if "slotKeys: []" not in tests or 'XCTAssertFalse(rendered.contains("\\"position\\""))' not in tests:
        fail("C5 omitted-scope rendering test is missing")
    if "scopeCandidatesBySlot: scopeCandidatesBySlot" not in cli:
        fail("C5TrainingCLI does not pass C2-derived scope candidates into build options")

    for token in STALE_EXECUTABLE_SCOPE:
        if re.search(rf'"position"\s*:\s*"{token}"', source) or re.search(rf'range:\s*"[^"]*{token}', tests):
            fail(f"stale executable scope token remains: {token}")

    print("c5-c2-scope-parity: pass")


if __name__ == "__main__":
    main()

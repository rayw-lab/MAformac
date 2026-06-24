#!/usr/bin/env python3
from __future__ import annotations

import pathlib
import re
import sys

import yaml

ROOT = pathlib.Path(__file__).resolve().parents[1]
STATE_CELLS = ROOT / "contracts" / "state-cells.yaml"
C2_APPLIER = ROOT / "Core" / "Contracts" / "ToolContractCompiler.swift"
C5_SOURCE = ROOT / "Core" / "Training" / "C5LoRATraining.swift"
C5_TESTS = ROOT / "Tests" / "MAformacCoreTests" / "C5LoRATrainingTests.swift"
C5_CLI = ROOT / "Tools" / "C5TrainingCLI" / "main.swift"
STALE_EXECUTABLE_SCOPE = ("左前", "右前", "后排")


def fail(message: str) -> None:
    print(f"c5-c2-scope-parity: {message}", file=sys.stderr)
    raise SystemExit(65)


def c2_scoped_cells() -> dict[str, list[str]]:
    spec = yaml.safe_load(STATE_CELLS.read_text(encoding="utf-8"))
    scoped: dict[str, list[str]] = {}
    for device in (spec.get("devices") or {}).values():
        for cell in device.get("state_cells") or []:
            scopes = list(cell.get("scope") or [])
            if scopes:
                scoped[str(cell.get("id"))] = scopes
    if "window.position" not in scoped:
        fail("window.position scope missing from C2")
    return scoped


def mapped_scoped_cells(scoped_cells: dict[str, list[str]]) -> set[str]:
    source = C2_APPLIER.read_text(encoding="utf-8")
    match = re.search(r"deviceCellMap:\s*\[String:\s*String\]\s*=\s*\[(.*?)\n\s*\]", source, re.S)
    if not match:
        fail("cannot parse ToolContractStateApplier.deviceCellMap")
    mapped = set(re.findall(r'"[^"]+"\s*:\s*"([^"]+)"', match.group(1)))
    result = mapped.intersection(scoped_cells)
    if not result:
        fail("deviceCellMap has no mapped scoped C2 cells")
    non_window = result - {"window.position"}
    if not non_window:
        fail("C5/C2 parity still only covers window.position")
    return result


def main() -> None:
    scoped_cells = c2_scoped_cells()
    mapped_scoped = mapped_scoped_cells(scoped_cells)
    scopes = scoped_cells["window.position"]
    for required in ("主驾", "副驾", "左后", "右后", "全车"):
        if required not in scopes:
            fail(f"C2 window.position scope missing {required}")

    source = C5_SOURCE.read_text(encoding="utf-8")
    tests = C5_TESTS.read_text(encoding="utf-8")
    cli = C5_CLI.read_text(encoding="utf-8")
    combined = source + tests + cli
    if "C5ScopeCandidateCatalog.scopeCandidatesBySlot(from:" not in combined:
        fail("C5 scope candidates are not derived from C2")
    if "scopeCandidatesByDeviceSlot(from:" not in source or "ToolContractStateApplier.deviceCellMap" not in source or "cell.scope" not in source:
        fail("C5 scope candidates must be device/cell-aware and derive from mapped C2 scoped cells")
    if "slotKeys: []" not in tests or 'XCTAssertFalse(rendered.contains("\\"position\\""))' not in tests:
        fail("C5 omitted-scope rendering test is missing")
    if "testDeviceAwareScopeCandidatesCoverAllMappedScopedCells" not in tests:
        fail("C5 all-mapped-scoped-cells parity test is missing")
    if "scopeCandidatesBySlot: scopeCandidatesBySlot" not in cli:
        fail("C5TrainingCLI does not pass C2-derived scope candidates into build options")
    if "scopeCandidatesByDeviceSlot: scopeCandidatesByDeviceSlot" not in cli:
        fail("C5TrainingCLI does not pass device-aware C2 scope candidates into build options")

    for token in STALE_EXECUTABLE_SCOPE:
        if re.search(rf'"position"\s*:\s*"{token}"', source) or re.search(rf'range:\s*"[^"]*{token}', tests):
            fail(f"stale executable scope token remains: {token}")

    print("c5-c2-scope-parity: pass")


if __name__ == "__main__":
    main()

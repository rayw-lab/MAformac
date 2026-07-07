# UIUE A-2 Phase 0 Receipt — PresentationSnapshot Vocabulary

Date: 2026-06-25
Worktree: `/Users/wanglei/workspace/MAformac-uiue`
Branch: `uiue/phase4-default-scope-presentation`
Status: DONE for Phase 0 Task 0.1

## Scope

- Goal: implement the mock-frontstage bridge vocabulary container for A-2.
- Scope in: `Core/Presentation/PresentationSnapshot.swift`, focused XCTest coverage, narrow `FamilyCardID` conformance needed by `activeCells`.
- Scope out: no runtime backend, no ASR/NLU/TTS/LoRA wiring, no `state-cells.yaml` or codegen changes, no visual anchor claim for this non-UI phase.

## Implementation

- Added `PresentationSnapshot` with `traceId`, `storeCells`, `activeCells`, `refusedCell`, `scopeOrigins`, `context`, `orbState`, `voiceState`, `dialogText`, `readbacks`, `resultKind`, and `proofClass`.
- Added finite vocabulary enums:
  - `DemoRuntimeResultKind`: 8 bridge result classes.
  - `PresentationProofClass`: local/static/simulator/operator proof labels only.
  - `PresentationOrbState` and `PresentationVoiceState`: mock frontstage state boundary.
- Added `DemoContext` with four dimensions: vehicle speed, vehicle gear, weather, time period.
- Added `MockPresentationSnapshotProvider` presets: `coldStart`, `acStarted`, `coolingMode`, `safetyRefusal`.
- Added `@MainActor PresentationSnapshot.from(store:)` adapter that consumes `DemoVehicleStateStore.presentationCells`.
- Made `FamilyCardID` `Hashable` so it can key `activeCells` without adding a parallel card model.

## TDD Evidence

- RED observed: `swift test --filter PresentationSnapshotTests` failed before implementation because `DemoRuntimeResultKind`, `MockPresentationSnapshotProvider`, `PresentationSnapshot`, and `PresentationProofClass` did not exist.
- GREEN: `swift test --filter PresentationSnapshotTests`
  - Executed 6 tests, 0 failures.
- Full regression: `swift test`
  - Executed 228 tests, 3 skipped, 0 failures.

## Validation

| Gate | Proof class | Result |
|---|---|---|
| `swift test --filter PresentationSnapshotTests` | unit | PASS, 6 tests |
| `swift test` | unit | PASS, 228 tests, 3 skipped |
| `bash Tools/checks/check-no-binary-visualstate.sh` | local | PASS |
| `bash Tools/checks/check-platform-vs-version-guard.sh` | local | PASS |
| `bash Tools/checks/check-contentview-uses-display-catalog.sh` | local | PASS |
| `git diff --check` | local | PASS |
| MCP `build_run_sim` on `MAformacIOS`, `iPhone 17 Pro Max`, `-forceVisualState normal` | runtime | PASS, bundle `lab.rayw.MAformac.ios`, process `39632` |
| MCP screenshot | runtime | PASS, `/var/folders/_s/cgbbydhx4m7cd_c_2j14v9b00000gn/T/screenshot_optimized_d46cba70-9c4b-4e97-82bc-876683316340.jpg`, 368x800 |
| `xcodebuild -project MAformac.xcodeproj -scheme MAformacMac -destination 'platform=macOS' build` | local | PASS, BUILD SUCCEEDED |

## Audit

Subagent verdict: PASS_WITH_FINDINGS, no P0/P1.

Controller resolution:

| Finding | Resolution |
|---|---|
| P2: result kind is optional and could be omitted on non-cold snapshots. | Kept optional because `coldStart` has no runtime result and should not fake `accepted/noop`; added test that all non-cold mock presets carry a non-nil result kind contained in the 8-case enum. |
| P2: 8-kind test counted a hand-written array but did not assert `allCases` closure. | Fixed with `XCTAssertEqual(DemoRuntimeResultKind.allCases, all)`. |

## Coverage Burn-Down

- Marked SD1 P0 coldStart as done: `coldStart()` carries empty `storeCells`, and `VehicleCardDisplay.familyDisplays(from:)` produces the 10-family idle skeleton.
- Marked RPB-01~08 as done: snapshot vocabulary, proof class, `scopeOrigins`, `source` separate from `scope_origin`, and `@MainActor` adapter are covered by code and tests.
- Did not mark RPB-09~17: enum exists, but unsupported/noop/partial-deny visual/mock consumption is later Phase 2/3 work.
- Did not mark visual/anchor rows: Phase 0 has no UI delta; anchor pixel comparison starts with visual phases.

## Residual Risk

- `PresentationSnapshot` is a vocabulary container; frontstage consumption begins in later phases.
- The screenshot is simulator smoke evidence only, not visual acceptance.
- Four-region spacing and anchor quality remain hard gates for Phase 2+.

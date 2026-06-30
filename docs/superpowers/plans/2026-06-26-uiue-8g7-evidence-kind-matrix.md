# UIUE 8.G7 Evidence Kind + Representative Matrix Plan

Date: 2026-06-26
Repo: `/Users/wanglei/workspace/MAformac-uiue`
Branch: `uiue/phase4-default-scope-presentation`
Task: 8.G7 only
Proof class target: `local` + `unit`; no `runtime`, no `mobile`, no `true_device`, no `V-PASS`

## Goal

Implement 8.G7 as a narrow evidence-contract layer:

1. Add a typed `evidence_kind` enum for visual/touch receipts:
   - `tap_step`
   - `toggle`
   - `badge_cycle`
   - `continuous_drag`
   - `terminal_visual_only`
2. Add representative automated sample matrices:
   - action-kind coverage for `tap_step`, `toggle`, and `badge_cycle`
   - family/sample coverage for 风量、座椅、车窗、灯光
3. Unit-test that automated samples can write mock state and refresh a `PresentationSnapshot`.
4. Explicitly prevent `continuous_drag` and `terminal_visual_only` from being counted as automated process proof.
5. Mark only `8.G7` complete in `openspec/changes/ui-presentation/tasks.md` after tests pass.

## Non-Goals

- Do not implement 8.G6, 8.G8, or 8.G9.
- Do not edit `contracts/`, `generated/`, `App/`, SwiftUI views, Xcode project structure, screenshot artifacts, or existing visual evidence dirs.
- Do not create a new UI test target in this task.
- Do not run simulator visual acceptance, collect screenshots, or claim L0/L3 evidence.
- Do not claim automated drag acceptance. `continuous_drag` remains operator-pass/true-device process proof, per AD-15/U36.
- Do not treat `-forceVisualState` or static screenshots as process proof. Those may only be `terminal_visual_only`.

## Authority

- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/design.md:272`:
  U36 says evidence is grouped by control action, not by family. `tap_step/toggle/badge_cycle` are automated tap evidence; `continuous_drag` is operator-pass/true-device; `force_state = terminal_visual_only` cannot be process proof.
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md:152`:
  8.G7 requires receipt `evidence_kind` enum plus representative family automation samples: 风量/座椅/车窗/灯光 each one row.
- Existing app truth:
  - `App/ContentView.swift` already exposes `vehicle-card-*` and `expanded-*` identifiers.
  - `ValueControlView` exposes generic labels `增加`, `减少`, `切换`, `切换选项`.
  - There is no dedicated UI test target in `MAformac.xcodeproj`.

This plan intentionally avoids adding a brittle XCUITest target for 8.G7. The closeable scope is the receipt contract and unit-tested store/snapshot automation matrix. Runtime tap screenshots remain separate L0/L3 evidence, not part of this checkbox.

## Writable Paths

- `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/VisualEvidenceReceipt.swift`
- `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/VisualEvidenceReceiptTests.swift`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md`

No-touch paths:

- `/Users/wanglei/workspace/MAformac-uiue/contracts/`
- `/Users/wanglei/workspace/MAformac-uiue/generated/`
- `/Users/wanglei/workspace/MAformac-uiue/App/`
- `/Users/wanglei/workspace/MAformac-uiue/MAformac.xcodeproj/`
- `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-25-a2-execution/`

## Stop Conditions

- If a required fix needs `App/`, `contracts/`, `generated/`, or Xcode project edits, stop and report `PARTIAL`.
- If tests reveal the planned sample matrix cannot prove store write + snapshot refresh without UI/runtime work, do not check 8.G7.
- If any implementation tries to make `terminal_visual_only` or `continuous_drag` count as automated process proof, stop and correct it.

## Implementation Step 1: Add The Receipt Contract

Create:

`/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/VisualEvidenceReceipt.swift`

Use this shape:

```swift
import Foundation

enum VisualEvidenceKind: String, CaseIterable, Codable, Equatable, Sendable {
    case tapStep = "tap_step"
    case toggle
    case badgeCycle = "badge_cycle"
    case continuousDrag = "continuous_drag"
    case terminalVisualOnly = "terminal_visual_only"

    var isAutomatedTapEvidence: Bool {
        switch self {
        case .tapStep, .toggle, .badgeCycle:
            return true
        case .continuousDrag, .terminalVisualOnly:
            return false
        }
    }

    var provesProcessMutationWithoutOperator: Bool {
        switch self {
        case .tapStep, .toggle, .badgeCycle:
            return true
        case .continuousDrag, .terminalVisualOnly:
            return false
        }
    }
}

struct VisualEvidenceSample: Equatable, Sendable {
    var id: String
    var label: String
    var family: FamilyCardID
    var evidenceKind: VisualEvidenceKind
    var cellKey: String
    var beforeValue: String
    var afterValue: String
    var expectedValueType: UIValueType

    var base: String {
        ScopedStateKey(cellKey).base
    }
}

enum VisualEvidenceSampleMatrix {
    static let automatedActionSamples: [VisualEvidenceSample] = [
        VisualEvidenceSample(
            id: "fan-speed-step",
            label: "风量 stepper tap",
            family: .ac,
            evidenceKind: .tapStep,
            cellKey: "ac.fan_speed[主驾]",
            beforeValue: "1",
            afterValue: "2",
            expectedValueType: .stepper
        ),
        VisualEvidenceSample(
            id: "ac-power-toggle",
            label: "空调开关 toggle tap",
            family: .ac,
            evidenceKind: .toggle,
            cellKey: "ac.power",
            beforeValue: "off",
            afterValue: "on",
            expectedValueType: .toggle
        ),
        VisualEvidenceSample(
            id: "ambient-color-badge-cycle",
            label: "灯光色彩 badge cycle tap",
            family: .ambient,
            evidenceKind: .badgeCycle,
            cellKey: "ambient.color",
            beforeValue: "白",
            afterValue: "浅蓝紫",
            expectedValueType: .badge
        )
    ]

    static let representativeFamilySamples: [VisualEvidenceSample] = [
        VisualEvidenceSample(
            id: "fan-representative",
            label: "风量代表样本",
            family: .ac,
            evidenceKind: .tapStep,
            cellKey: "ac.fan_speed[主驾]",
            beforeValue: "1",
            afterValue: "2",
            expectedValueType: .stepper
        ),
        VisualEvidenceSample(
            id: "seat-representative",
            label: "座椅代表样本",
            family: .seat,
            evidenceKind: .tapStep,
            cellKey: "seat.heat_level[主驾]",
            beforeValue: "0",
            afterValue: "1",
            expectedValueType: .stepper
        ),
        VisualEvidenceSample(
            id: "window-representative",
            label: "车窗代表样本",
            family: .window,
            evidenceKind: .tapStep,
            cellKey: "window.position[主驾]",
            beforeValue: "0",
            afterValue: "20",
            expectedValueType: .percent
        ),
        VisualEvidenceSample(
            id: "light-representative",
            label: "灯光代表样本",
            family: .ambient,
            evidenceKind: .badgeCycle,
            cellKey: "ambient.color",
            beforeValue: "白",
            afterValue: "浅蓝紫",
            expectedValueType: .badge
        )
    ]
}
```

Notes:

- Use exhaustive switches with no `default`.
- `window.lock` is intentionally not the car-window representative in this task: current UI toggle code maps boolean-ish values to `on/off`, while `window.lock` contract semantics are `locked/unlocked`. Using `window.position[主驾]` avoids turning 8.G7 into a separate value-domain bug fix.

## Implementation Step 2: Add Unit Tests

Create:

`/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/VisualEvidenceReceiptTests.swift`

Use tests with these assertions:

```swift
import XCTest
@testable import MAformacCore

final class VisualEvidenceReceiptTests: XCTestCase {
    func testEvidenceKindRawValuesAreStable() {
        XCTAssertEqual(
            VisualEvidenceKind.allCases.map(\.rawValue),
            ["tap_step", "toggle", "badge_cycle", "continuous_drag", "terminal_visual_only"]
        )
    }

    func testOnlyTapStepToggleAndBadgeCycleAreAutomatedTapEvidence() {
        XCTAssertEqual(
            VisualEvidenceKind.allCases.filter(\.isAutomatedTapEvidence),
            [.tapStep, .toggle, .badgeCycle]
        )
        XCTAssertFalse(VisualEvidenceKind.continuousDrag.provesProcessMutationWithoutOperator)
        XCTAssertFalse(VisualEvidenceKind.terminalVisualOnly.provesProcessMutationWithoutOperator)
    }

    func testAutomatedActionSamplesCoverTapStepToggleAndBadgeCycle() {
        XCTAssertEqual(
            Set(VisualEvidenceSampleMatrix.automatedActionSamples.map(\.evidenceKind)),
            Set([.tapStep, .toggle, .badgeCycle])
        )
        XCTAssertTrue(VisualEvidenceSampleMatrix.automatedActionSamples.allSatisfy {
            $0.evidenceKind.isAutomatedTapEvidence
        })
    }

    func testRepresentativeFamilySamplesCoverFanSeatWindowAndLight() {
        XCTAssertEqual(
            VisualEvidenceSampleMatrix.representativeFamilySamples.map(\.id),
            ["fan-representative", "seat-representative", "window-representative", "light-representative"]
        )
        XCTAssertEqual(
            VisualEvidenceSampleMatrix.representativeFamilySamples.map(\.family),
            [.ac, .seat, .window, .ambient]
        )
    }

    func testSamplesStayAlignedWithFamilyAndValueTypeMappers() {
        let samples = VisualEvidenceSampleMatrix.automatedActionSamples
            + VisualEvidenceSampleMatrix.representativeFamilySamples

        for sample in samples {
            XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: sample.base), sample.family, sample.id)
            XCTAssertEqual(UIValueTypeMapper.uiValueType(forBase: sample.base), sample.expectedValueType, sample.id)
        }
    }

    @MainActor
    func testAutomatedSamplesWriteStoreAndRefreshPresentationSnapshot() {
        for sample in VisualEvidenceSampleMatrix.automatedActionSamples {
            let store = DemoVehicleStateStore(cells: [
                DemoVehicleStateCell(key: sample.cellKey, actualValue: sample.beforeValue)
            ])

            let readback = store.applyMockTransition(
                DemoMockTransition(key: sample.cellKey, desiredValue: sample.afterValue, source: .user)
            )
            let snapshot = PresentationSnapshot.from(
                store: store,
                activeCells: [sample.family: sample.cellKey],
                readbacks: [readback]
            )

            XCTAssertEqual(snapshot.storeCells.first { $0.key == sample.cellKey }?.actualValue, sample.afterValue, sample.id)
            XCTAssertEqual(snapshot.activeCells[sample.family], sample.cellKey, sample.id)
            XCTAssertEqual(snapshot.readbacks.first?.key, sample.cellKey, sample.id)
            XCTAssertNotEqual(snapshot.storeCells.first { $0.key == sample.cellKey }?.visualState, .normal, sample.id)
            XCTAssertEqual(snapshot.proofClass, .localMock, sample.id)
        }
    }

    func testNoDefaultFallbackInEvidenceKindSwitches() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Core/Presentation/VisualEvidenceReceipt.swift")
        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        XCTAssertFalse(source.contains("default:"))
        XCTAssertFalse(source.contains("@unknown default"))
    }
}
```

If `testAutomatedSamplesWriteStoreAndRefreshPresentationSnapshot` fails because `.toggle` returns `.normal` for an off transition, keep the sample as `off -> on`; do not change the expected assertion to allow terminal-only proof. The point is to prove process mutation, not just a final display.

## Implementation Step 3: Mark 8.G7 Only

In:

`/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md`

Change only:

```diff
-- [ ] 8.G7 取证 receipt `evidence_kind` enum（tap_step/toggle/badge_cycle/continuous_drag/terminal_visual_only，U36）+ 代表族自动化样本矩阵（风量/座椅/车窗/灯光各 1 条）
+ [x] 8.G7 取证 receipt `evidence_kind` enum（tap_step/toggle/badge_cycle/continuous_drag/terminal_visual_only，U36）+ 代表族自动化样本矩阵（风量/座椅/车窗/灯光各 1 条）
```

Do not check 8.G6, 8.G8, or 8.G9.

## Validation Gates

Run:

```bash
swift test --filter VisualEvidenceReceiptTests
swift test
make verify-all
openspec validate ui-presentation --strict
git diff --check
```

Commit only:

```bash
git add Core/Presentation/VisualEvidenceReceipt.swift \
  Tests/MAformacCoreTests/VisualEvidenceReceiptTests.swift \
  openspec/changes/ui-presentation/tasks.md
git commit -m "test(uiue): add visual evidence kind matrix"
```

## Expected Verdict

```text
verdict: DONE | PARTIAL | BLOCKED

Changed files:
- Core/Presentation/VisualEvidenceReceipt.swift
- Tests/MAformacCoreTests/VisualEvidenceReceiptTests.swift
- openspec/changes/ui-presentation/tasks.md

Validation:
- swift test --filter VisualEvidenceReceiptTests -> PASS/FAIL
- swift test -> PASS/FAIL
- make verify-all -> PASS/FAIL
- openspec validate ui-presentation --strict -> PASS/FAIL
- git diff --check -> PASS/FAIL

Proof class:
- local
- unit

Residual risks:
- No runtime/mobile/true-device/V-PASS claimed.
- continuous_drag process proof remains operator-pass/true-device only.
- terminal_visual_only is not process proof.
- 8.C2 remains open until L0-L3 package and 磊哥 L3 verdict.
- 8.G6/8.G8/8.G9 remain open.
```

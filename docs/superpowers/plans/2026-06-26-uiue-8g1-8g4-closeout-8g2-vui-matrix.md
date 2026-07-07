# UIUE 8.G1+8.G4 Closeout Commit + 8.G2 VUI Matrix Test Plan

Date: 2026-06-26
Owner: Codex implementation thread `019f0313-0be0-7950-9e48-23c75aea9028`
Repo: `/Users/wanglei/workspace/MAformac-uiue`
Branch: `uiue/phase4-default-scope-presentation`
Mode: implementation, but limited to the two tasks below
Proof class target: `local` + `unit`; no `runtime`, no `mobile`, no `true_device`, no `V-PASS`

## Goal

1. Close the existing dirty 8.G1 + 8.G4 work into one commit without changing its scope.
2. Implement 8.G2 only: an 8-state VUI matrix contract/test for `DemoRuntimeResultKind.allCases`.

## Non-Goals

- Do not implement 8.G6, 8.G7, 8.G8, or 8.G9.
- Do not edit `contracts/`, `generated/`, `App/`, SwiftUI views, screenshot artifacts, or visual evidence directories.
- Do not connect real NLU/ASR/TTS/LoRA/runtime backend.
- Do not claim A-2 complete, 8.C2 complete, product acceptance, mobile proof, true-device proof, or `V-PASS`.
- Do not stage with `git add .`.
- Do not include this plan file in either implementation commit unless 磊哥 explicitly asks for that later.

## Current Truth Snapshot

Live verified before writing this plan:

- Dirty 8.G1/8.G4 files:
  - `/Users/wanglei/workspace/MAformac-uiue/Tools/checks/phase2_zone_compare.py`
  - `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/specs/ui-presentation/spec.md`
  - `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md`
- Expected pre-existing untracked visual evidence dirs under:
  - `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-25-a2-execution/`
- 8.G status in `tasks.md` before 8.G2:
  - complete: `8.G1`, `8.G3`, `8.G4`, `8.G5`
  - open: `8.G2`, `8.G6`, `8.G7`, `8.G8`, `8.G9`
- `Core/Presentation/PresentationSnapshot.swift` currently defines eight `DemoRuntimeResultKind` cases:
  - `acceptedToolCall`
  - `clarifyMissingSlot`
  - `refusalNoAvailableTool`
  - `refusalSafetyOrPolicy`
  - `alreadyStateNoop`
  - `runtimeError`
  - `cancelled`
  - `partialAcceptPartialRefuse`
- Existing `Tests/MAformacCoreTests/PresentationSnapshotTests.swift` checks all eight cases exist, but does not yet check per-state visual state, dialog copy, motion, TTS state, and proof class.

## Writable Paths

For the closeout commit:

- `/Users/wanglei/workspace/MAformac-uiue/Tools/checks/phase2_zone_compare.py`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/specs/ui-presentation/spec.md`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md`

For 8.G2:

- `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/DemoRuntimeResultPresentationMatrix.swift`
- `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/DemoRuntimeResultPresentationMatrixTests.swift`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md`

No-touch paths:

- `/Users/wanglei/workspace/MAformac-uiue/contracts/`
- `/Users/wanglei/workspace/MAformac-uiue/generated/`
- `/Users/wanglei/workspace/MAformac-uiue/App/`
- `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-25-a2-execution/`
- `/Users/wanglei/.claude/`
- `/Users/wanglei/.codex/`

## Stop Conditions

- If `git status --short` shows modified tracked files outside the allowed sets, stop and report before staging.
- If the existing 8.G1/8.G4 diff has changed beyond the three expected files, stop and report.
- If `swift test` or `make verify-all` fails after 8.G2, fix only within 8.G2 scope. If the failure points outside scope and cannot be fixed without touching no-touch paths, stop with `PARTIAL`.
- If two fix attempts produce no new failing evidence or no new proof class, stop and report `PARTIAL`; do not start a long visual/runtime loop.

## Step 1: Commit Existing 8.G1 + 8.G4 Dirty Diff

Start by confirming the repo state:

```bash
cd /Users/wanglei/workspace/MAformac-uiue
git status --short --branch
git diff --name-only
```

Expected tracked dirty files are exactly:

```text
Tools/checks/phase2_zone_compare.py
openspec/changes/ui-presentation/specs/ui-presentation/spec.md
openspec/changes/ui-presentation/tasks.md
```

This plan file and the existing visual evidence dirs may appear as untracked files. Do not stage them.

Run the closeout validation:

```bash
python3 -m py_compile Tools/checks/phase2_zone_compare.py
python3 Tools/checks/phase2_zone_compare.py --self-check
openspec validate ui-presentation --strict
git diff --check
```

Then commit only the three 8.G1/8.G4 files:

```bash
git add Tools/checks/phase2_zone_compare.py \
  openspec/changes/ui-presentation/specs/ui-presentation/spec.md \
  openspec/changes/ui-presentation/tasks.md
git commit -m "chore(uiue): close visual proof gates and l1 sentinel"
```

Expected proof class for this commit: `local`, docs/tool validation only.

## Step 2: Implement 8.G2 Only

Add a focused presentation matrix file:

`/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/DemoRuntimeResultPresentationMatrix.swift`

Use this implementation shape. The switch must be exhaustive and must not include `default` or `@unknown default`.

```swift
import Foundation

enum PresentationMotionKind: String, CaseIterable, Equatable, Sendable {
    case stateCommit
    case clarificationPulse
    case refusalShake
    case safetyPulse
    case steadyAcknowledge
    case staticError
    case cancellationFade
    case partialResult
}

struct DemoRuntimeResultPresentationEntry: Equatable, Sendable {
    var resultKind: DemoRuntimeResultKind
    var visualState: DemoVisualState
    var dialogText: String
    var motionKind: PresentationMotionKind
    var ttsState: PresentationVoiceState
    var proofClass: PresentationProofClass
}

enum DemoRuntimeResultPresentationMatrix {
    static var allEntries: [DemoRuntimeResultPresentationEntry] {
        DemoRuntimeResultKind.allCases.map(entry)
    }

    static func entry(for kind: DemoRuntimeResultKind) -> DemoRuntimeResultPresentationEntry {
        switch kind {
        case .acceptedToolCall:
            return DemoRuntimeResultPresentationEntry(
                resultKind: kind,
                visualState: .satisfied,
                dialogText: "已完成",
                motionKind: .stateCommit,
                ttsState: .speaking,
                proofClass: .localMock
            )
        case .clarifyMissingSlot:
            return DemoRuntimeResultPresentationEntry(
                resultKind: kind,
                visualState: .blocked_with_alternative,
                dialogText: "需要确认具体位置后我再执行",
                motionKind: .clarificationPulse,
                ttsState: .speaking,
                proofClass: .localMock
            )
        case .refusalNoAvailableTool:
            return DemoRuntimeResultPresentationEntry(
                resultKind: kind,
                visualState: .blocked_hard,
                dialogText: "这个功能当前演示环境暂不支持",
                motionKind: .refusalShake,
                ttsState: .speaking,
                proofClass: .localMock
            )
        case .refusalSafetyOrPolicy:
            return DemoRuntimeResultPresentationEntry(
                resultKind: kind,
                visualState: .unsafe,
                dialogText: "为了安全，当前状态下不能这样操作",
                motionKind: .safetyPulse,
                ttsState: .speaking,
                proofClass: .localMock
            )
        case .alreadyStateNoop:
            return DemoRuntimeResultPresentationEntry(
                resultKind: kind,
                visualState: .satisfied,
                dialogText: "已经是这个状态了",
                motionKind: .steadyAcknowledge,
                ttsState: .speaking,
                proofClass: .localMock
            )
        case .runtimeError:
            return DemoRuntimeResultPresentationEntry(
                resultKind: kind,
                visualState: .unknown,
                dialogText: "刚才处理失败，请重试",
                motionKind: .staticError,
                ttsState: .speaking,
                proofClass: .localMock
            )
        case .cancelled:
            return DemoRuntimeResultPresentationEntry(
                resultKind: kind,
                visualState: .normal,
                dialogText: "已取消",
                motionKind: .cancellationFade,
                ttsState: .speaking,
                proofClass: .localMock
            )
        case .partialAcceptPartialRefuse:
            return DemoRuntimeResultPresentationEntry(
                resultKind: kind,
                visualState: .blocked_with_alternative,
                dialogText: "已完成可执行部分，其余部分暂不能执行",
                motionKind: .partialResult,
                ttsState: .speaking,
                proofClass: .localMock
            )
        }
    }
}
```

Add the contract test:

`/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/DemoRuntimeResultPresentationMatrixTests.swift`

```swift
import XCTest
@testable import MAformacCore

final class DemoRuntimeResultPresentationMatrixTests: XCTestCase {
    func testMatrixCoversEveryRuntimeResultKindExactlyOnce() {
        let entries = DemoRuntimeResultPresentationMatrix.allEntries

        XCTAssertEqual(entries.map(\.resultKind), DemoRuntimeResultKind.allCases)
        XCTAssertEqual(Set(entries.map(\.resultKind)), Set(DemoRuntimeResultKind.allCases))
        XCTAssertEqual(entries.count, 8)
    }

    func testEachRuntimeResultKindHasVUIAndProofOutputs() {
        for entry in DemoRuntimeResultPresentationMatrix.allEntries {
            XCTAssertFalse(entry.dialogText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            XCTAssertTrue(PresentationMotionKind.allCases.contains(entry.motionKind))
            XCTAssertEqual(entry.ttsState, .speaking)
            XCTAssertEqual(entry.proofClass, .localMock)
        }
    }

    func testRuntimeResultKindsMapToExpectedVisualAndMotionStates() {
        let expected: [(DemoRuntimeResultKind, DemoVisualState, PresentationMotionKind)] = [
            (.acceptedToolCall, .satisfied, .stateCommit),
            (.clarifyMissingSlot, .blocked_with_alternative, .clarificationPulse),
            (.refusalNoAvailableTool, .blocked_hard, .refusalShake),
            (.refusalSafetyOrPolicy, .unsafe, .safetyPulse),
            (.alreadyStateNoop, .satisfied, .steadyAcknowledge),
            (.runtimeError, .unknown, .staticError),
            (.cancelled, .normal, .cancellationFade),
            (.partialAcceptPartialRefuse, .blocked_with_alternative, .partialResult)
        ]

        for (kind, visualState, motionKind) in expected {
            let entry = DemoRuntimeResultPresentationMatrix.entry(for: kind)

            XCTAssertEqual(entry.visualState, visualState, "\(kind.rawValue) visualState")
            XCTAssertEqual(entry.motionKind, motionKind, "\(kind.rawValue) motionKind")
        }
    }

    func testMatrixSourceDoesNotUseDefaultSwitchFallback() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Core/Presentation/DemoRuntimeResultPresentationMatrix.swift")
        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        XCTAssertFalse(source.contains("default:"))
        XCTAssertFalse(source.contains("@unknown default"))
    }
}
```

Then mark only 8.G2 complete in:

`/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md`

Change only this checkbox:

```diff
-- [ ] 8.G2 一进两出 **8 态 VUI 矩阵测试**（U37）：`DemoRuntimeResultKind.allCases` 每态 视觉态+话术+动效+TTS+proof，禁 default 吞，复用 `FamilyDisplaysTests` 闭合模式
+ [x] 8.G2 一进两出 **8 态 VUI 矩阵测试**（U37）：`DemoRuntimeResultKind.allCases` 每态 视觉态+话术+动效+TTS+proof，禁 default 吞，复用 `FamilyDisplaysTests` 闭合模式
```

Do not check any other 8.G item.

## 8.G2 Validation Gates

Run focused tests first:

```bash
swift test --filter DemoRuntimeResultPresentationMatrixTests
```

Run full local gates:

```bash
swift test
make verify-all
openspec validate ui-presentation --strict
git diff --check
```

Commit only the 8.G2 files:

```bash
git add Core/Presentation/DemoRuntimeResultPresentationMatrix.swift \
  Tests/MAformacCoreTests/DemoRuntimeResultPresentationMatrixTests.swift \
  openspec/changes/ui-presentation/tasks.md
git commit -m "test(uiue): add runtime result VUI matrix"
```

## Final Verdict Format

Return this exact shape:

```text
verdict: DONE | PARTIAL | BLOCKED

Commits:
- <sha> chore(uiue): close visual proof gates and l1 sentinel
- <sha> test(uiue): add runtime result VUI matrix

Changed files:
- <file list with line refs>

Validation:
- <command> -> PASS/FAIL

Proof class:
- local
- unit

Residual risks:
- No runtime/mobile/true-device/V-PASS claimed.
- 8.C2 remains open until L0-L3 evidence package and 磊哥 L3 verdict.
- 8.G6/8.G7/8.G8/8.G9 remain open.
```

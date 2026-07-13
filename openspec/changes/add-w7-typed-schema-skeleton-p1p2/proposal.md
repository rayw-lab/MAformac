## Why

W7 carrier `define-dialogue-state-semantic-consumption` 已 archive 到 `openspec/specs/dialogue-state-semantic-consumption/spec.md`（R1–R8 全 ratify），但 Swift 侧 **零 typed 落地**：`Core/State/DialogueState.swift` 仍是 spec 之前的旧简易骨架（DialogueTurn/DialogueState/turns/focusEntity/lastReadback/maxTurns），既不实现 typed window envelope、finite paired/unpaired disposition、独立 focus/readback validity、authoritative checkpoint、owner-window focus expiry，也不消费 W8 typed lifecycle facts。

carrier `tasks.md:32` **唯一未勾** = P3 production consumer coding 前必须签 RISK-ACK-W7；且 W8（`session-lifecycle`）execution_state=planned/proof_state=none/无 typed fixture，即使 RISK-ACK-W7 签字，W7 也无法真正消费。**W7 P1/P2 **typed-schema-only 骨架**（不 wire production consumer）可先落地**——为 R2–R6 提供 Codable、versioned、bounded、fail-closed 的 schema 类型，为将来 P3 production 段留下 read-only shape，同时保持旧骨架完全不动。

## What Changes

- 新增 5 个 Swift schema 文件（typed-schema-only，不 wire runner）：
  - `Core/State/DialogueStateWindowEnvelope.swift` — versioned/bounded/carrier-frozen envelope + Codable + fail-closed validate。
  - `Core/State/DialogueStatePairing.swift` — finite paired/unpaired disposition + 独立 focus/readback validity record。
  - `Core/State/DialogueStateCheckpoint.swift` — authoritative checkpoint schema + restore disposition + identity mismatch fail-closed。
  - `Core/State/DialogueStateFocusOwner.swift` — owner-window focus expiry types + force-visual 非 focus source + 未授权 injection 拒收。
  - `Core/State/DialogueStateEffectBoundary.swift` — versioned effect matrix 类型 + fact→effect 一一对应 + version-mismatch fail-closed（**类型层，尚未挂接消费者**）。
- 新增 5 个 dedicated tests（round-trip / versioning / boundary / negative fail-closed）。
- 明示 P3 production wiring **仍 GATED**：不修改 `Core/State/DialogueState.swift` 旧骨架、不 wire `DemoRuntimeSessionRunner`、不消费 W8 facts、不动 App composition。
- 两门 `verify-dialogue-state-source` / `verify-dialogue-state-consumption` 保持 PLANNED_GATE_NOT_YET_EXECUTABLE，本 change **不做** materialization。

## Capabilities

### New Capabilities

- 无新 capability。本 change 在既有 `dialogue-state-semantic-consumption` capability 下 ADDED 一条 SHALL：typed schema skeleton stage 明确 P1/P2 typed shape 与 P3 production wiring 的边界。

### Modified Capabilities

- None。W8 lifecycle owner、W9 force-state authority、V2 ceremony、V8 closure join 均不由本 change 修改。

## Impact

- 新增 openspec carrier：`openspec/changes/add-w7-typed-schema-skeleton-p1p2/`。
- 新增 Swift 源码 5 个（全部在 `Core/State/`，与 `DialogueState.swift` 并列且不相互依赖）。
- 新增 tests 5 个（`Tests/MAformacCoreTests/DialogueState*P1P2Tests.swift`）。
- **不修改** `Core/State/DialogueState.swift`、`Core/Execution/DemoRuntimeSessionRunner.swift`、`App/FrontstageRuntimeComposition.swift`、`Core/Contracts/*.generated.swift`、`Core/Execution/W20ARuntimeReadbackReceiptWriter.swift`、`Core/Execution/DemoSliceRoute.swift`、`Makefile`、`Tests/test_closure_work_packages.py`、shared checker。
- W8 typed fixture 依赖状态：本 change 类型层不 import W8 Swift types（因 W8 typed producer 尚不存在），改以 opaque typed key 表达 fact identity，为将来 W8 落地时的 bridging 保留 versioned 边界。
- planned gates 状态不动：`verify-dialogue-state-source` / `verify-dialogue-state-consumption` 保持 PLANNED_GATE_NOT_YET_EXECUTABLE。

## Non-goals

- 不 wire production consumer；`DemoRuntimeSessionRunner.run(text:)` 不被本 change 触碰。
- 不签 RISK-ACK-W7；`tasks.md:32` 不由本 change 勾选。
- 不产 W8 typed lifecycle producer / terminal-fence ack fixture。
- 不推翻或迁移 `Core/State/DialogueState.swift` 旧骨架的 API/字段。
- 不 apply、不 push、不 merge、不 archive、不翻 registry state、不生成 package exit proof。
- 不把 P1/P2 typed schema 存在写成 gate green、W7 DONE、implementation-complete、operator-pass、V-PASS、mobile、true-device、live proof。

## Success Criteria

- `openspec validate add-w7-typed-schema-skeleton-p1p2 --strict` rc0；`openspec validate --all --strict` rc0。
- 5 个 Swift schema 文件全部通过 `swift test --filter DialogueState.*P1P2` rc0；每个 tests 至少覆盖 supported round-trip、missing/unknown identity fail-closed、version mismatch fail-closed 三类。
- 旧 `DialogueState.swift`、`DialogueStateTests.swift` 不被修改；`swift test --filter DialogueStateTests` 仍 rc0（回归）。
- owned-paths audit：`git diff --name-only f5c963fc..HEAD` 全部落在 `Core/State/DialogueState{WindowEnvelope,Pairing,Checkpoint,FocusOwner,EffectBoundary}.swift` / `Tests/MAformacCoreTests/DialogueState*P1P2Tests.swift` / `openspec/changes/add-w7-typed-schema-skeleton-p1p2/**` 范围内，禁碰 no-touch 清单。
- 本 change writeback 完成后只做本地 commit，不 push、不 apply、不 archive。

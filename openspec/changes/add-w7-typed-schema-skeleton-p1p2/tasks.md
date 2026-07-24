## P0 — Carrier

- [x] 建 openspec change carrier（proposal / design / tasks / specs delta）。
  - Output：`openspec/changes/add-w7-typed-schema-skeleton-p1p2/`。
  - Acceptance：`openspec validate add-w7-typed-schema-skeleton-p1p2 --strict` rc0；不推翻 W8/W9/V2/V8 边界。

## P1 — Typed window envelope 骨架

- [x] 定义 `DialogueStateSchemaVersion` / `DialogueGroupIdentity` / `DialogueGroupDisposition` / `DialogueWindowBound` / `DialogueStateWindowEnvelope`。
  - Output：`Core/State/DialogueStateWindowEnvelope.swift`。
  - Acceptance：missing identity / unknown disposition / unsupported version → validate 拒收；bounded eviction 纯函数返回新 envelope 且不进 audit。
- [x] 为 envelope 加 `DialogueStateWindowEnvelopeP1P2Tests`。
  - Acceptance：round-trip / fail-closed / bounded eviction 三条覆盖，`swift test --filter DialogueStateWindowEnvelopeP1P2Tests` rc0。

## P2 — Pairing / checkpoint / focus / effect boundary 骨架

- [x] 定义 `DialogueGroupCompleteness` / `DialogueFieldValidityRecord` / `DialogueGroupRecord`。
  - Output：`Core/State/DialogueStatePairing.swift`。
  - Acceptance：连续 user 消息表达为 `unpairedConsecutiveUserSupersession`+`userOnlyPending`；focus/readback validity 独立记录，无隐式继承。
- [x] 定义 `DialogueStateCheckpoint` / `DialogueStateRestoreDisposition` / `DialogueStateCheckpointValidator`。
  - Output：`Core/State/DialogueStateCheckpoint.swift`。
  - Acceptance：identity mismatch / legacy ambiguous / display-text-only 均 `.failure`；不 rebind。
- [x] 定义 `DialogueFocusOwnerWindow` / `DialogueFocusActivationBound` / `DialogueFocusExpiryReason` / `DialogueFocusInjectionAuthority.notYetRatified` / `DialogueForceVisualStateProbe`（uninhabited marker）。
  - Output：`Core/State/DialogueStateFocusOwner.swift`。
  - Acceptance：owner-window eviction → focus invalid；force visual state 无 focus 路径；未授权 injection 静态拒收。
- [x] 定义 `DialogueW8FactKind` / `DialogueFieldEffect` / `DialogueTerminalAuditEffect` / `DialogueW7Effect` / `DialogueEffectMatrixVersion` / `DialogueW7EffectMatrix.apply(_:matrixVersion:)`。
  - Output：`Core/State/DialogueStateEffectBoundary.swift`。
  - Acceptance：unknown fact / matrix `.unsupported` / 无 entry → `.failure`；同 fact 一效果；active vs terminal audit 分离枚举。
- [x] 为四类 typed 各加 dedicated tests（pairing / checkpoint / focus owner / effect boundary）。
  - Acceptance：round-trip / fail-closed / 边界不变量三条覆盖；`swift test --filter DialogueState.*P1P2Tests` rc0。

## P3 — Production consumer wiring (GATED, NOT IN SCOPE)

- [ ] **NOT DONE — GATED**：本 change 不 wire 任何 production consumer；`DemoRuntimeSessionRunner.run(text:)` 不被触碰。
  - Blocked-by：RISK-ACK-W7 未签 + W8 typed lifecycle producer / terminal-fence ack fixture 不存在（intel Q6 UNMET）。
  - Owner：未定；本 change writeback 完成后由 commander 分派。
  - 解除条件：另 propose W7 production wiring change，并同时提供 W8 typed producer 冻结 receipt。

## P4 — Source gate materialization plan（保持 planned）

- [x] 明示 `verify-dialogue-state-source` 与 `verify-dialogue-state-consumption` 保持 PLANNED_GATE_NOT_YET_EXECUTABLE。
  - Acceptance：本 change 不新增 Makefile target、不改 verify-ci、不生成 gate green claim；receipt 里 Non-claims 段显式声明。

## P5 — Validation & writeback

- [x] 跑 `openspec validate add-w7-typed-schema-skeleton-p1p2 --strict` + `openspec validate --all --strict` rc0。
- [x] 跑 `swift test --filter DialogueState`（含旧 tests 回归 + 新 P1P2 tests）rc0。
- [x] 逐 semantic slice 分 commit（P0 carrier / P1 envelope / P2 pairing / P2 checkpoint / P2 focus / P2 effect boundary / P5 tests 汇总），禁 `git add .`。
- [x] `owned-paths audit`：`git diff --name-only f5c963fc..HEAD` 落在 allowlist 内。
- [x] 生成 `<mission_root>/evidence/W7_p1p2_producer/CLOSEOUT-W7-P1P2.md`（≤ 3 KB）。

## Non-claims

- P3 production wiring 未 done；`Runner.run(text:)` 未修改。
- RISK-ACK-W7 未签。
- W8 typed lifecycle producer / terminal-fence ack fixture 未产。
- `verify-dialogue-state-source` / `verify-dialogue-state-consumption` 两门未 materialize；不宣称 gate green、W7 DONE、implementation complete、operator-pass、V-PASS、mobile、true-device、live proof。
- 本 change 只做本地 commit，不 push、不 apply、不 archive、不翻 registry state、不生成 package exit proof。

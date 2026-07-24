# Design — add-w7-typed-schema-skeleton-p1p2

## 决策边界（P1/P2 typed-schema-only）

本 change 的 scope **严格限于 typed schema 骨架**：为 W7 spec R2–R6 提供 Swift 类型层实体（Codable、versioned、fail-closed、bounded），**不 wire 任何 production consumer**、**不改任何现有运行时**。W7 spec R1 的「消费 W8 typed lifecycle facts」在类型层通过 opaque typed key（`DialogueW8FactKind`）表达 fact identity，为将来 W8 producer 落地时的 bridging 保留 versioned 边界；本 change 不引入 W8 Swift 侧 producer/fixture。

## 依赖状态（gate 判定）

- W7 spec R1–R8 已 archive 至 `openspec/specs/dialogue-state-semantic-consumption/spec.md`，Requirements 完备。
- W7 carrier `define-dialogue-state-semantic-consumption` `tasks.md:32` P3 production consumer 未勾（依赖 RISK-ACK-W7 签字），本 change **不做**。
- W8 `session-lifecycle` spec 已 ratify 但 Swift typed producer / terminal-fence ack fixture **不存在**（intel Q6 已确认）。本 change 不消费 W8 facts，只声明 fact→effect 类型层 mapping。
- planned gates `verify-dialogue-state-source` / `verify-dialogue-state-consumption` 状态不动。

## 目录与文件（仅新增，无修改）

```
Core/State/
├── DialogueState.swift                   # 旧骨架，NOT MODIFIED
├── DialogueStateWindowEnvelope.swift     # 新增 — R2 envelope + Codable
├── DialogueStatePairing.swift            # 新增 — R3 disposition + validity record
├── DialogueStateCheckpoint.swift         # 新增 — R4 checkpoint schema
├── DialogueStateFocusOwner.swift         # 新增 — R5 focus owner-window + expiry
└── DialogueStateEffectBoundary.swift     # 新增 — R6 versioned effect matrix types

Tests/MAformacCoreTests/
├── DialogueStateTests.swift                          # 旧 tests，NOT MODIFIED
├── DialogueStateWindowEnvelopeP1P2Tests.swift        # 新增
├── DialogueStatePairingP1P2Tests.swift               # 新增
├── DialogueStateCheckpointP1P2Tests.swift            # 新增
├── DialogueStateFocusOwnerP1P2Tests.swift            # 新增
└── DialogueStateEffectBoundaryP1P2Tests.swift        # 新增
```

## 类型层设计

### 1. `DialogueStateWindowEnvelope`（承接 spec R2 :33-56）

- `DialogueStateSchemaVersion` — 枚举支持版本，起点 `.v1`；`.unsupported(rawValue: String)` 用于版本不识别时的 fail-closed 呈现（decode 时保留原字符串以便审计）。
- `DialogueGroupIdentity` — carrier-frozen identity：`sessionRef`（opaque String，绑 W8 session owner，本 change 不定义其构造）、`generationRef`（opaque String，绑 W8 generation owner）、`groupOrdinal`（UInt32，单调 within-envelope）。缺任一 → `EnvelopeError.missingIdentity`。
- `DialogueGroupDisposition` — finite disposition 枚举：`paired`、`unpairedUserOnly`、`unpairedAssistantCancelled`、`unpairedConsecutiveUserSupersession`、`legacyUnpairedAmbiguous`、`contextInvalid`、`terminalAuditOnly`。unknown raw 值 → `EnvelopeError.unknownDisposition`。
- `DialogueWindowBound` — struct with `maxActiveGroups: UInt`（carrier-frozen，本 change 内固定值经 static constant 呈现，但字段外部可读，为将来 spec 冻结值提供 hook）。
- `DialogueStateWindowEnvelope` — Codable struct：
  - `schemaVersion: DialogueStateSchemaVersion`
  - `identity: DialogueGroupIdentity`
  - `bound: DialogueWindowBound`
  - `activeGroups: [DialogueGroupRecord]`
  - `auditGroups: [DialogueGroupRecord]`（terminal audit-only，与 active 分离）
  - `focusValidity: DialogueFieldValidityRecord?`
  - `readbackValidity: DialogueFieldValidityRecord?`
  - `sourceReferences: [DialogueSourceReference]`
- Codable 采用 canonical JSON key ordering（用 `sortedKeys` output formatting）以支持 round-trip 与 digest 计算。
- 提供 `validate() throws -> DialogueStateWindowEnvelope`：
  - 缺 identity / unknown disposition / unsupported version → throw；validate 不 mutate。
  - retention：`activeGroups.count > bound.maxActiveGroups` → throw `EnvelopeError.retentionExceeded`，由 caller 显式调用 `evictingOldestActive()` 得到 deterministic eviction，evicted 的组不进 auditGroups（这是「eviction 不创建 cross-session」的显式落地）。
- `evictingOldestActive() -> DialogueStateWindowEnvelope` — 纯函数，返回新 envelope（immutable），保证「envelope 对 consumer read-only」。

**版本策略**：`.v1` 作为唯一 supported；`.unsupported(rawValue:)` 在 decode 时用于承载未知 raw string，`validate()` 立即拒收。为将来 v2 演进保留 explicit whitelist。

### 2. `DialogueStatePairing`（承接 R3 :58-82）

- `DialogueGroupCompleteness` — struct：`disposition: DialogueGroupDisposition`、`reason: DialogueGroupCompletenessReason`。
- `DialogueGroupCompletenessReason` — finite 枚举：`.pairedComplete`、`.userOnlyPending`、`.assistantCancelled`、`.consecutiveUserSupersession`、`.legacyAmbiguous`、`.contextInvalid`。
- `DialogueFieldValidityRecord` — struct：
  - `reason: DialogueFieldValidityReason`
  - `sourceGroupRef: DialogueSourceGroupRef`（含 sessionRef + generationRef + groupOrdinal）
  - `schemaVersion: DialogueStateSchemaVersion`
- `DialogueFieldValidityReason` — 枚举：`.derivedFromReadback`、`.derivedFromExplicitFocusInjection(disabled: true)`（本 change 内 `disabled:true` 为唯一 case，反映 R5 「focus injection SHALL remain disabled until separately ratified」）、`.invalidated(dueTo: DialogueFieldValidityInvalidationCause)`。
- `DialogueSourceGroupRef` / `DialogueSourceReference` — 结构化引用，字段级引用而非隐式索引。
- `DialogueGroupRecord` — struct：`identity: DialogueGroupIdentity`、`completeness: DialogueGroupCompleteness`、`userText: String?`、`assistantText: String?`（typed schema 层，本 change 不定义 tokenizer / 边界）。
- 关键不变量（tests 覆盖）：
  - 两条连续 user 消息 → 前一组 `unpairedConsecutiveUserSupersession`、后一组 `userOnlyPending`，array length 不能推断 paired。
  - Focus / readback validity 独立字段读取，`DialogueStateWindowEnvelope.focusValidity` 与 `.readbackValidity` 无隐式 fallthrough。

### 3. `DialogueStateCheckpoint`（承接 R4 :83-106）

- `DialogueStateCheckpoint` — struct：
  - `schemaVersion: DialogueStateSchemaVersion`
  - `sessionOwnerRef: String`
  - `generationOwnerRef: String`
  - `digest: String`（hex-encoded，本 change 不定义算法，只承载）
  - `restoreDisposition: DialogueStateRestoreDisposition`
  - `capturedAt: TimeInterval`（Unix epoch seconds，schema 层）
- `DialogueStateRestoreDisposition` — 枚举：
  - `.authoritative`（valid checkpoint）
  - `.legacyMigrationAmbiguous`（一次性迁移场景，标 ambiguous）
  - `.identityMismatch(current: String, checkpoint: String)`（session/generation mismatch）
  - `.displayTextOnlyNoContext`（UI 文本恢复但无授权 checkpoint）
- `DialogueStateCheckpointValidator` — enum with static `validate(_:againstCurrentIdentity:) -> Result<DialogueStateCheckpoint, CheckpointError>`。
- 关键不变量：
  - `.displayTextOnlyNoContext` / `.identityMismatch(...)` / `.legacyMigrationAmbiguous` → validator 返回 `.failure`，caller SHALL NOT rebind to current session。
  - restore 只承载 typed schema；本 change 不 wire restore 到 DialogueState 或 W8。

### 4. `DialogueStateFocusOwner`（承接 R5 :108-131）

- `DialogueFocusOwnerWindow` — struct：`ownerWindowRef: DialogueSourceGroupRef`、`focusValidityReason: DialogueFieldValidityReason`、`activeUntil: DialogueFocusActivationBound`。
- `DialogueFocusActivationBound` — 枚举：`.untilOwnerWindowEvicted`、`.untilTerminalClear`、`.untilSessionClear`、`.untilIdentityFence`、`.revoked(reason: DialogueFocusExpiryReason)`。
- `DialogueFocusExpiryReason` — 枚举：`.ownerWindowEvicted`、`.terminalClear`、`.sessionClear`、`.identityFence`、`.unauthorisedInjection`。
- `DialogueFocusInjectionAuthority` — 枚举：`.notYetRatified`（唯一 case，禁止 injection；本 change 显式对齐 spec :110「focus injection SHALL remain disabled until a separate authority and proof contract is ratified」）。
- `DialogueForceVisualStateProbe` — 空标签 marker（`enum` 无 case 的 uninhabited type），只在 tests 中用作类型证明「force visual state 不是 focus source」（不构造实例即证明无路径）。
- 关键不变量：
  - `DialogueFocusInjectionAuthority.notYetRatified` 是唯一 value → 任何 injection 尝试静态 fail-closed。
  - `.untilOwnerWindowEvicted` 到达 → focus validity 应被 caller 视为 invalid（本 change 提供纯函数 `DialogueFocusOwnerWindow.isValid(givenActiveWindows:) -> Bool`，无副作用）。

### 5. `DialogueStateEffectBoundary`（承接 R6 :133-156）

- `DialogueW8FactKind` — 枚举 opaque 承载 W8 fact identity（本 change 不 import W8 types）：
  - `.sessionStarted`、`.sessionCleared`、`.generationFenced`、`.turnCancelled`、`.terminalClear`、`.checkpointSaved`、`.checkpointRestoreAttempted`。
  - unknown raw → decode 阶段承载为 `.unknown(rawValue: String)`，`applyMatrix` 阶段 fail-closed。
- `DialogueFieldEffect` — 枚举：`.clear`、`.retain`。
- `DialogueTerminalAuditEffect` — 枚举：`.retainAsAuditOnly`、`.retain`、`.clear`（terminal audit 特有的 audit-only case，与 active field effects 分离）。
- `DialogueW7Effect` — struct：
  - `focusEffect: DialogueFieldEffect`
  - `lastReadbackEffect: DialogueFieldEffect`
  - `activeWindowEffect: DialogueFieldEffect`
  - `unpairedGroupEffect: DialogueFieldEffect`
  - `terminalAuditEffect: DialogueTerminalAuditEffect`
- `DialogueEffectMatrixVersion` — 枚举 `.v1` / `.unsupported(rawValue:)`。
- `DialogueW7EffectMatrix` — struct：`version: DialogueEffectMatrixVersion`、`entries: [DialogueW8FactKind: DialogueW7Effect]`。
- `apply(_ fact: DialogueW8FactKind, matrixVersion: DialogueEffectMatrixVersion) -> Result<DialogueW7Effect, EffectMatrixError>`：
  - matrix `.unsupported` → `.failure(.effectVersionMismatch)`
  - fact `.unknown` → `.failure(.unknownFact)`
  - matrix 内无 entry → `.failure(.unrecognizedEffect)`
  - 合法 → `.success(effect)`，且 idempotency 由 caller 层保证；本 change 提供 `DialogueW7EffectConsumptionRegister` （纯类型 marker，说明「同 fact 不被消费两次」的责任在 wire 层，schema 层不实现 register 存储以避免蔓延成 consumer）。
- **不 wire**：本 change 不提供任何调用 `apply(...)` 的 production 消费点。tests 直接实例化 matrix 并调用 apply 验证不变量。

## Codable 与 canonical encoding

- 所有类型 `Codable` + `Equatable` + `Sendable`（value semantics，可跨 actor）。
- 顶层 encode 使用 `JSONEncoder` with `outputFormatting = [.sortedKeys]`（tests 内显式设置），保证 round-trip 稳定，为将来 digest 计算保留 canonical 形式。
- decode 遇未知枚举 raw 值 → 承载为 `.unsupported(rawValue:)` 或 `.unknown(rawValue:)`，validate/apply 阶段 fail-closed（不 crash）。

## 与旧 `DialogueState.swift` 的关系

- **非破坏性**：本 change 不引入对 `DialogueState`/`DialogueTurn` 的依赖，反之亦然。旧 `DialogueState.swift` API/字段保留原样。
- **非 wire**：本 change 不为 `DemoRuntimeSessionRunner.run(text:)` 的现有 `dialogueState.recordUserText`/`recordAssistantText`/`recordReadbacks` 路径提供任何新钩子。P3 gate 满足前，两条链路互不感知。
- 未来 P3 production wiring 可选路径（本 change **不实现**）：
  - 在 `DialogueState` 内引入 `envelope: DialogueStateWindowEnvelope?` 派生投影，由 reducer 更新。
  - 或另立 `DialogueRuntimeReducer` 类型，`DemoRuntimeSessionRunner` 通过 read-only envelope 消费。
  - 两条路径的选择在 P3 gate（RISK-ACK-W7 + W8 typed fixture 齐备）时另 propose。

## 测试策略

每 typed 文件对应一 dedicated tests 文件；每 tests 至少覆盖：
1. **Supported round-trip**：合法值 encode → decode → 结构等价（Equatable + sortedKeys canonical 一致）。
2. **Missing/unknown identity fail-closed**：construct with missing identity 或 unknown enum raw → validate/apply 返回 `Result.failure` 或 throw；不 mutate、不 rebind、不 crash。
3. **Version mismatch fail-closed**：`.unsupported(rawValue:)` version → validate/apply 拒收。
4. **Boundary/idempotency**：如 envelope 的 bounded eviction、pairing 的 array-length 独立、focus 的 owner-window 失效不续期、effect matrix 的同 fact 一效果。

## 冷启点火 gate（本 change 不实现）

- 本 change writeback 后 `openspec validate --strict` rc0、`swift test --filter DialogueState.*P1P2` rc0、`swift test --filter DialogueStateTests` rc0（回归）。
- 本 change 完成 ≠ P3 gate 满足；两门仍 PLANNED_GATE_NOT_YET_EXECUTABLE。
- RISK-ACK-W7、W8 typed producer / terminal-fence ack fixture、production consumer wiring、`Runner.run` 触碰均 out of scope。

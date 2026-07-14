# Design: implement-v9-product-operator-spine-20260714

```text
change_id: implement-v9-product-operator-spine-20260714
status: PROPOSED_OPENSPEC_ONLY
revision: 2026-07-14-commander-adjudication-r2
architecture_role: freeze shortest executable product spine
single_writer: DialogueState + SessionLifecycleCoordinator + vehicle state store (no second state machine)
composition_gate_first: true
no_second_digest: ForceStateDigest.validate is sole force-catalog digest authority
s3_app_wiring: DEFERRED (gate unit only)
s2_boundary_matrix_modify: FORBIDDEN (bridge CREATE-only)
lane_may_close: PARTIAL
```

## Context（一手现状）

### 现网装配（cite live）

| 组件 | 现状 | 空洞 / 裁决 |
|---|---|---|
| `App/FrontstageRuntimeComposition` | `routeDemoSlice`：current-turn → K3 `SessionLifecycleCompositionGate.ensureActive` → 懒建 `DemoSliceRoute(store,traceLogger,speech)` | **无** per-turn correlation provider 注入 |
| `Core/Execution/DemoSliceRoute` | 构造 runner 时 **未** 传 `correlationProvider` | 默认 nil；生产面需 per-call `route(text:correlationProvider:)` |
| `DemoRuntimeSessionRunner` | 已有 optional provider + `consumeTypedFactsIfWired` fail-closed；`defaultRunner` nil | 生产面需 non-optional `run(text:correlationProvider:)`；legacy optional 仅 unit/default helper（**不**要求改 `defaultRunner` visibility） |
| `FrontstageVoiceTurn` | 提供 `sessionID`、正 `sequence`、`turnID` | S1 对话组身份源 |
| `SessionLifecycleCompositionGate` | **仅** `ensureActive`；返回 generation | 产品路径不能诚实「消费 cancel」；扩 API **deferred** |
| `SessionLifecycleEvent` | **已存在** `Core/Lifecycle/SessionLifecycleFacts.swift` 约 :31–43：`.start` / `.terminal(...)` / `.recoveryReady` / `.newGeneration` | 审阅误报「类型缺失」作废；无 App 接线到 Dialogue effects |
| `DialogueW8FactKind` + matrix | opaque fact + lookup；P1/P2 测试矩阵覆盖 terminalClear / sessionCleared / turnCancelled | bridge **不**改 matrix；缺 entry → fail-closed（caller 提供 matrix） |
| Force catalog | `ForceStateDigest` / `ForceStateCatalog` / `DemoForceStateBoundary` 在 `Core/Config/**` | **无** `Core/ForceState/**`；`applySnapshotCells` **仅** matrix-digest via `DemoVehicleStateApplier`；**无** force catalog metadata carrier → **App 消费 DEFERRED** |
| Capability matrix digest | `DemoVehicleStateApplier` 校验 | **≠** force catalog digest；**禁止** 把 `TerminalAck.canonicalDigest` 映射为 force 字段 |
| T07a carrier | 六段 envelope；synthetic 三字段 | 本 change 只冻消费 |
| `define-demo-golden-run-and-voice` | `draft_deferred` | **禁止整包 apply** |

### 产品真相约束

- offline macOS demo；mock 车控；mounted=1；`actionDemoProven=0/120` 诚实。
- visual-first；TTS 失败可降级但**不得**把错误态说成成功。
- SPM package tests **不得**实例化 App target 类型；App 接线用 source-contract。

---

## Goals / Non-Goals

### Goals

1. **唯一 production composition root**：`FrontstageRuntimeComposition`。
2. **Per-turn non-nil fail-closed correlation**：`ProductionRouteCorrelationProvider` factory + 冻结身份四元组。
3. **Lifecycle bridge 映射表冻结**（`SessionLifecycleEvent` 真实存在）；product cancel/recovery deferred；**CREATE-only** bridge。
4. **Force catalog digest gate unit**：`ForceStateDigestGate` 委托 `ForceStateDigest.validate`；App force 消费 **resource_deferred**。
5. **Golden / reliability / TTS / T07a** 按 DAG；TTS 含 preflight 脚本 + App readback 结果捕获；soak resource-deferred。
6. **proof class 分层**；test dedupe；lane 可 **PARTIAL** 收口。

### Non-Goals

- 扩 catalog / 手翻 proven / T07b / operator-pass / V-PASS / C6 / W4 DONE / V1 RATIFIED / **W9_APP_CONSUMED**。
- 第二 DialogueState / 第二 lifecycle coordinator / 第二 digest。
- 新建 `Core/ForceState/**`。
- MODIFY `DialogueStateEffectBoundary` / `ForceStateDigest` / `ForceStateCatalog` / `DemoForceStateBoundary` / `applySnapshotCells` force gate。
- 整包 apply golden draft / fork T07a carrier。
- Makefile soak gate；mutable global correlation singleton。

---

## Architecture Decisions

### AD-1 — 唯一 production composition root

**决策：** `App/FrontstageRuntimeComposition.swift` 为 **唯一** customer-facing production composition root。

- 真路径：`FrontstageCustomerIngress` accepted + current turn → `routeDemoSlice` → lifecycle ensureActive → **per-turn** assembled correlation provider → `DemoSliceRoute.route(text:correlationProvider:)` → runner `run(text:correlationProvider:)`。
- 测试可直接构造 `DemoSliceRoute` / runner，**必须**标 unit/test_double，不得标 production composition / customer path。
- **禁止** 新建第二 composition root 类型或 ContentView 内联 `DemoRuntimeSessionRunner(` 当 production。

### AD-2 — Provider 注入（DI，不 fork 状态机）

```text
FrontstageRuntimeComposition.routeDemoSlice (per accepted current turn)
  ├─ SessionLifecycleCompositionGate.ensureActive  → generation
  ├─ ProductionRouteCorrelationProvider factory
  │     inputs: routeTurnID, sessionRef, generationRef, groupOrdinal
  │     returns: RuntimeSessionCorrelationProvider (frozen per-turn closure)
  ├─ DemoSliceRoute.route(text:correlationProvider:)   // production non-optional
  └─ DemoRuntimeSessionRunner.run(text:correlationProvider:)  // production non-optional
```

Also in scope as CREATE units (not necessarily owned by the composition root as long-lived fields):

- `LifecycleFactsDialogueBridge` — pure map; unit only until product lifecycle wired
- `ForceStateDigestGate` — unit only; App force path deferred

Single writers 保持：vehicle store/applier · DialogueState · SessionLifecycleCoordinator（gate 私有持有）。

**禁止：** mutable singleton / global context box 作为 correlation 身份源。

### AD-3 — Correlation fail-closed + frozen identity（S1）

#### 3.1 对话组身份一手源

| 源 | 字段 |
|---|---|
| `FrontstageVoiceTurn` | `sessionID`, positive `sequence`, `turnID` |
| `SessionLifecycleCompositionGate.ensureActive` 返回 | generation（用于 `generationRef`） |

#### 3.2 `ProductionRouteCorrelationProvider` API 冻结

- 类型角色：**factory**，不是 mutable provider 状态机。
- **Exact inputs**（构造/factory 参数）：
  - `routeTurnID: String`
  - `sessionRef: String`
  - `generationRef: String`
  - `groupOrdinal: UInt32`
- **Returns：** `RuntimeSessionCorrelationProvider`
- 返回的 closure：使用上述 **冻结** per-turn 值 + 入参 `traceID` + frame identity，组装 schema-supported `RouteToDialogueCorrelation`。
- **Schema version 冻结**：factory 产出的 `RouteToDialogueCorrelation.schemaVersion` 与嵌套 `DialogueRouteAttribution.schemaVersion` **SHALL** 均为 `DialogueStateSchemaVersion.v1`；生产路径不得推断、透传或接受 unsupported schema。
- 非法/空字符串/溢出输入 → **fail closed**（构造失败或 provider 返回 invalid → 下游 denied）。

#### 3.3 生产流冻结

`FrontstageRuntimeComposition.routeDemoSlice` **SHALL**：

1. 仅对 accepted **current** turn 执行。
2. 从 `turn.turnID`、`turn.sessionID`、`String(lifecycleSnapshot.generation.value)`、`UInt32(exactly: turn.sequence)` 构造 **一个** per-turn provider。
3. 若 `UInt32(exactly: turn.sequence) == nil` 或身份为空/非法 → **不**进入 typed-facts 成功路径；可观测拒绝/no-success。
4. 调用 non-optional per-call `DemoSliceRoute.route(text:correlationProvider:)`。

#### 3.4 Route / Runner 生产面

| 表面 | 角色 |
|---|---|
| `DemoSliceRoute.route(text:correlationProvider:)` | App 生产 per-call；provider **non-optional** |
| `DemoRuntimeSessionRunner.run(text:correlationProvider:)` | App 生产 per-call；provider **non-optional** |
| optional ctor / `run(text:)` / `defaultRunner` | **仅** unit/default helpers；**不是** App production surface |
| `defaultRunner` visibility | **不要求** 修改 |

#### 3.5 行为表

| 条件 | 行为 |
|---|---|
| production 无法组装合法 per-turn provider | fail-closed；不得 silent nil production |
| new/current-turn mismatch | 无 typed-facts mutation；可观测 refusal/no-success |
| invalid UInt32 sequence / empty identity | 同上 |
| provider 返回 invalid correlation | `.deniedContextInvalid`；window 零突变 |
| provider 返回 `nil`（unit opt-out） | 不写 typed facts；不得 success evidence |
| unit/default helper | **允许** 显式 nil optional surface |

### AD-4 — S2 映射表（冻结）+ CREATE-only bridge + product consumption cap

#### 4.0 类型存在性（审阅纠偏）

`SessionLifecycleEvent` **DOES exist** at `Core/Lifecycle/SessionLifecycleFacts.swift` 约 :31–43。设计/tasks **禁止**再写「类型缺失」。

#### 4.1 映射表 `SessionLifecycleEvent` → `DialogueW8FactKind`

| SessionLifecycleEvent | DialogueW8FactKind | 本 change 产品消费 | 备注 |
|---|---|---|---|
| `.start(sessionID,generation)` | `.sessionStarted` | **bridge-only unit** | 若 matrix 无 entry → fail-closed |
| `.terminal(..., outcomeClass: .cancelled)` | `.turnCancelled` | **deferred product path** | composition gate **无** cancel API |
| `.terminal(..., outcomeClass: .accepted)` | `.terminalClear` | **deferred product path** | 同上 |
| `.terminal(..., outcomeClass: refused/unsupported/timeout/failure)` | `.terminalClear` | **deferred product path** | audit-only 方向 |
| `.newGeneration(...)` | `.generationFenced` | **deferred product path** | 无 composition 扩 API 则不接 |
| `.recoveryReady(...)` | `.checkpointRestoreAttempted` | **deferred product path** | 仅 authoritative checkpoint |

#### 4.2 Bridge 职责（CREATE-only）

`Core/Lifecycle/LifecycleFactsDialogueBridge.swift` **SHALL**：

1. 接受 **caller-provided** `DialogueW7EffectMatrix`（不拥有/不修改 boundary 文件）。
2. 将 live `SessionLifecycleEvent` 映射为 `DialogueW8FactKind`（上表）。
3. 调用 `matrix.apply`；缺 entry / version mismatch → **fail-closed** 零效应。
4. **不**持有 lifecycle 权威；**不**持有 DialogueState 第二副本；**不**新建第二 coordinator。
5. 可选：`map(event:) -> Result<DialogueW8FactKind, BridgeError>` 与 `effect(for:matrix:) -> Result<...>`。

#### 4.3 本 change **不**做

- **不** MODIFY `Core/State/DialogueStateEffectBoundary.swift` 或 `DialogueStateEffectBoundaryP1P2Tests.swift`。
- 不扩 `SessionLifecycleCompositionGate` 为 terminal/cancel/recovery API。
- 不 claim product-path cancel/restart/recovery 已接到 App composition。
- 缺 matrix entry 时保持 fail-closed（与现矩阵测一致）；**不**在本 change 补 generationFenced/sessionStarted/checkpoint* 条目。

#### 4.4 既有 effect 方向（matrix v1 测试锚点，只读引用）

| Fact | focus | lastReadback | activeWindow | unpaired | terminalAudit |
|---|---|---|---|---|---|
| turnCancelled | clear | clear | retain | retain | retainAsAuditOnly |
| terminalClear | clear | clear | retain | retain | retainAsAuditOnly |
| sessionCleared | clear | clear | clear | clear | retain |

### AD-5 — Force **catalog** digest gate（S3：unit only；App DEFERRED）

#### 5.1 一手事实

- Live `App/ContentView.applySnapshotCells` **既无** 权威 `ForceStateCatalog` **也无** 外部 `ForceStateDigestMetadata`。
- 现有 `DemoVehicleStateApplier` 校验 **capability-matrix digest**——**另一 SSOT**，不得冒充 force catalog。

#### 5.2 本 change S3 实现范围（exact）

| op | path |
|---|---|
| CREATE | `Core/Config/ForceStateDigestGate.swift` |
| CREATE | `Tests/MAformacCoreTests/ProductOperatorForceStateDigestGateTests.swift` |
| MODIFY（仅当 dedupe 真需要） | `Tests/MAformacCoreTests/ForceStateDigestTests.swift` |

**Removed from S3：** MODIFY `App/ContentView.swift`、`Core/Config/ForceStateDigest.swift`、`ForceStateCatalog.swift`、`DemoForceStateBoundary.swift`。

#### 5.3 冻结 gate API

```text
// stateless public
validate(metadata: ForceStateDigestMetadata?, against catalog: ForceStateCatalog) throws
```

- **Delegates only** to `ForceStateDigest.validate`。
- **No** recompute, **no** catalog ownership, **no** second digest implementation.

#### 5.4 App force-catalog consumption = deferred

- 分类：`resource_deferred_tests` / product deferred，直到存在 **独立 sourcing、非空、带版本** 的 catalog + 外部 metadata payload。
- **Exact residual（字面冻结）：**
  `applySnapshotCells has matrix-digest authority only; no force_catalog metadata carrier exists`
- Handoff 预留观察字段名（**仅命名，不接线**）：`force_catalog_digest_hex`、`capability_matrix_digest_hex`。
- **禁止** 将 `DemoVehicleStateApplier.TerminalAck.canonicalDigest` 映射为 force 字段。

#### 5.5 Claim cap

- S3 最高：`FORCE_DIGEST_GATE_UNIT_PASS`
- **永不**：`W9_APP_CONSUMED`

### AD-6 — Golden / reliability 阶段门 + resource deferred

```text
composition_gate_PASS
  → 才允许 claim runtime_local composition wire
  → 才允许 resource-window 后 customer-shaped golden

composition_gate_FAIL 或 NOT_RUN
  → golden/reliability 仅 contract + fixture + unit schema tests
  → 禁止 customer path DONE
```

**Fixture 精确路径（保留现约定）：**

- `Tests/Fixtures/product-operator-golden/`
- `Tests/Fixtures/product-operator-reliability/`

**Provisional reliability receipt 字段（冻结名）：**

| field | meaning |
|---|---|
| `threshold_basis` | 必须 = `provisional_package_local` |
| `basis_citation` | 文件路径 + sha256 或 fixture id（缺则 fail-closed） |
| `metric_id` | 如 `turn_latency_ms`（结构预留；**非** V1 阈值） |
| `provisional_p95_ms` | optional number；无 basis 不得 claim |
| `soak_status` | `resource_deferred` \| `not_run` \| `local_pass` |
| `non_claims` | 必须含 `not_w4_done` `not_v1_ratified` |

**强制 `resource_deferred_tests`：**

- p95 / 20-turn / 300s soak
- runtime_local customer-shaped golden
- full xcodebuild when S8 active
- **force_catalog_app_consumption**
- **product_lifecycle_cancel_terminal_recovery_app_wiring**

**禁止：** Makefile soak gate；假设 V1 RATIFIED；claim W4 DONE。

### AD-7 — TTS hard gate（可执行 + context-aware）

#### 7.1 精确 MODIFY / CREATE 面

1. `Core/Voice/SpeechSynthesisEngine.swift` — **不改** `SpeechSynthesisEngine` protocol 形状；`AVSpeechSynthesisEngine.speak`：若 `bestChineseVoice()` 返回 nil，**不得** 调 synthesizer，返回 `.failed(reason: "chinese_voice_unavailable")`；**禁止** silent `.systemDefault` success。
2. `Core/Execution/DemoRuntimeSessionRunner.swift` — production speak；失败时 visual-first 保留，**不得** 标 voice success；`RuntimePresentationPayload` / Core `PresentationSnapshot.voiceState`（`PresentationVoiceDisplayState`）在 synthesis 失败时 **SHALL** 冻结为 `.idle`，**不得** 为 `.speak`（用现有 allowed 文件最小 runner/route/App 数据流；**尽量不**改 shared payload 合同）。
3. `Core/Execution/FallbackContext.swift` — reject/clarify/unmounted/unsupported 等错误文案源。
4. **`App/ContentView.swift` `applyRuntimeReadbackStep`（S5 only）** — 捕获 `SpeechSynthesisResult`；visual-first 进度保留；`StagePresentationSnapshot.voiceState`（`PresentationVoiceState`）在 synthesis 失败时 **不得** 变为 `.speaking`；记录可观测 TTS failure；**不**标 voice success。
5. **CREATE** `scripts/run_v9_product_operator_tts_preflight.sh` — 本机真实 `AVSpeechSynthesizer`/voice lookup（zh-CN/zh*）；机读 PASS/FAIL；proof class = **`runtime_local_preflight`**（非 operator/mobile/true-device）。
6. Tests：**CREATE** `Tests/MAformacCoreTests/ProductOperatorTTSHardGateTests.swift`；**MODIFY** `Tests/MAformacCoreTests/SpeechSynthesisEngineTests.swift`；**MODIFY** `Tests/MAformacCoreTests/FrontstageContainmentSourceContractTests.swift`；**不** 新建另一 App target。

#### 7.2 规则

1. visual-first：presentation payload / cards / dialogText 视觉为用户真相。
2. TTS failed / empty / chinese_voice_unavailable → 不把动作标为 voice-confirmed success。
2a. **Core 层**（`RuntimePresentationPayload` / `PresentationVoiceDisplayState`）：synthesis 失败时 `voiceState` **SHALL** 为 `.idle`，**不得** 为 `.speak`。
2b. **App 层**（`StagePresentationSnapshot` / `PresentationVoiceState`）：synthesis 失败时 `voiceState` **不得** 变为 `.speaking`；visual-first 进度 **MAY** 继续。两层负向断言 **不得** 混用 enum case（`.speak` ≠ `.speaking`）。
3. **Context-aware 禁语扫描：** 仅扫描 **reject / clarify / safety / unsupported / cancel / unmounted** 的 `dialogText` / `ttsText`。
4. **排除：** accepted、alreadyDone、partialAcceptPartialRefuse。
5. **禁止** blanket 扫描 badge labels 或 `DemoRuntimeResultPresentationMatrix` success/partial 字符串。
6. 禁语表（错误态整词短语）：

```text
已完成
已设置成功
设置成功
操作成功
执行成功
已成功
已为您完成
控制成功
```

7. success 路径允许完成类 readback（C2 模板），仍属 mock offline proof。

### AD-8 — T07a local consumer only

**精确路径：**

- `Core/Ceremony/OperatorCeremonyAttemptLedger.swift`
- `Tests/Fixtures/t07a-synthetic/`
- `Tests/MAformacCoreTests/ProductOperatorT07aLedgerConsumerTests.swift`

**消费 carrier（不 fork）：** `define-t07-operator-ceremony-carrier-20260712`

- 六段 envelope：`subject` · `environment` · `attempt` · `axes` · `expiry` · `evidence`
- synthetic 三字段：`synthetic=true` · `proof_class=local` · `satisfies_t07b_prerequisite=false`
- immutable append-only attempt ledger

**禁止：** Makefile ceremony gate 物化；T07b；改 carrier 树。

### AD-9 — Proof / 场景 / dedupe

| 场景 | 期望 | 证明类 |
|---|---|---|
| success mounted cell | mock 态变 + readback；typed facts 若 correlation 合法 | unit / later runtime_local |
| reject/clarify/safety | 无成功承诺语（context-aware）；无假 accepted mutation | unit TTS + runner |
| stale generation | bridge map + matrix；**product path deferred** | unit bridge |
| cancel/restart | **product path deferred**；bridge unit | unit only |
| provider failure | fail-closed 可观测 | unit deliberate-red |
| offline/recovery | checkpoint 规则；UI alone no-context | unit + fixture |
| force digest mismatch | gate unit throws；**App deferred** | FORCE_DIGEST_GATE_UNIT_PASS only |
| chinese voice unavailable | failed reason；no silent success | unit + preflight |

**Dedupe rule：** 行为已被 `D1TypedFactsWireDeliberateNegativeTests` / `ForceStateDigestTests` / `SessionLifecycleCompositionGateTests` / `FrontstageContainmentSourceContractTests` / `SpeechSynthesisEngineTests` / `DemoSliceRouteTests` 覆盖 → **扩展**这些文件；`ProductOperator*` 仅填 spine 真缺口。**不** MODIFY `DialogueStateEffectBoundaryP1P2Tests` / `D2ForceStateApplierDeliberateNegativeTests` 作为 S2/S3 条件写入（S3 App 不接线）。

### AD-10 — S0/S1 证明分层（禁止假绿）

| 层 | 做法 | 不可声称 |
|---|---|---|
| Core unit | per-turn factory + non-optional production route/run surfaces | production App wired |
| App source-contract | 读 `FrontstageRuntimeComposition.swift`：per-turn provider + `route(text:correlationProvider:)` | runtime 行为 |
| runtime_local | resource window 后真实 App 进程 | operator-pass |

---

## Dependency DAG

```text
S0 Composition Root freeze + source-contract plan
  → S1 ProductionRouteCorrelationProvider per-turn wire
    → S2 LifecycleFactsDialogueBridge CREATE-only mapping (product cancel/recovery deferred)
      → S3 ForceStateDigestGate unit only (App force DEFERRED)
        → S4 Golden + reliability fixtures (customer-shaped / soak = resource_deferred)
        → S5 TTS hard gate + preflight + ContentView applyRuntimeReadbackStep
        → S6 T07a OperatorCeremonyAttemptLedger consumer
```

并行（S0 合同后）：S4 fixture 草稿、S6 fixture 形状——runtime customer-shaped 用例等 S1 + resource window。

---

## Exact Writeset（未来 apply 闭集）

> 本 propose **不写代码**。apply diff **必须 ⊆** `.openspec.yaml` `allowed_writeset_future_apply`。

| op | path | slice |
|---|---|---|
| MODIFY | `App/FrontstageRuntimeComposition.swift` | S0/S1 |
| MODIFY | `App/ContentView.swift` | **S5 only** (`applyRuntimeReadbackStep`) |
| MODIFY | `Core/Execution/DemoSliceRoute.swift` | S0/S1 |
| MODIFY | `Core/Execution/DemoRuntimeSessionRunner.swift` | S1 production run surface + S5 speak |
| MODIFY | `Core/Execution/FallbackContext.swift` | S5 |
| CREATE | `Core/State/ProductionRouteCorrelationProvider.swift` | S1 |
| CREATE | `Core/Lifecycle/LifecycleFactsDialogueBridge.swift` | S2 |
| CREATE | `Core/Config/ForceStateDigestGate.swift` | S3 |
| MODIFY | `Core/Voice/SpeechSynthesisEngine.swift` | S5 |
| CREATE | `scripts/run_v9_product_operator_tts_preflight.sh` | S5 |
| CREATE | `Core/Ceremony/OperatorCeremonyAttemptLedger.swift` | S6 |
| CREATE | `Tests/Fixtures/product-operator-golden/**` | S4 |
| CREATE | `Tests/Fixtures/product-operator-reliability/**` | S4 |
| CREATE | `Tests/Fixtures/t07a-synthetic/**` | S6 |
| CREATE | `Tests/MAformacCoreTests/ProductOperatorCompositionRootTests.swift` | S0 |
| CREATE | `Tests/MAformacCoreTests/ProductOperatorCorrelationWireTests.swift` | S1 gap |
| CREATE | `Tests/MAformacCoreTests/ProductOperatorLifecycleFactsBridgeTests.swift` | S2 |
| CREATE | `Tests/MAformacCoreTests/ProductOperatorForceStateDigestGateTests.swift` | S3 |
| CREATE | `Tests/MAformacCoreTests/ProductOperatorGoldenContractTests.swift` | S4 |
| CREATE | `Tests/MAformacCoreTests/ProductOperatorReliabilityProvisionalTests.swift` | S4 |
| CREATE | `Tests/MAformacCoreTests/ProductOperatorTTSHardGateTests.swift` | S5 |
| MODIFY | `Tests/MAformacCoreTests/SpeechSynthesisEngineTests.swift` | S5 dedupe |
| MODIFY | `Tests/MAformacCoreTests/FrontstageContainmentSourceContractTests.swift` | S0/S5 source-contract dedupe |
| CREATE | `Tests/MAformacCoreTests/ProductOperatorT07aLedgerConsumerTests.swift` | S6 |
| MODIFY | `Tests/MAformacCoreTests/D1TypedFactsWireDeliberateNegativeTests.swift` | S1 dedupe |
| MODIFY | `Tests/MAformacCoreTests/ForceStateDigestTests.swift` | S3 dedupe（仅当真需要） |
| MODIFY | `Tests/MAformacCoreTests/SessionLifecycleCompositionGateTests.swift` | S0 dedupe |
| MODIFY | `Tests/MAformacCoreTests/DemoSliceRouteTests.swift` | S1 dedupe |

**Explicitly removed conditional MODIFYs：**

- `Core/State/DialogueStateEffectBoundary.swift`
- `Core/Config/ForceStateDigest.swift` / `ForceStateCatalog.swift` / `DemoForceStateBoundary.swift`
- S3 `ContentView.applySnapshotCells`

**Explicitly forbidden paths：** `Core/ForceState/**` · `Makefile` · C6/C5/closure/roadmap/decisions · `Core/Training/**` · `scripts/*train*` · carrier golden/T07 trees · training.

---

## No-Touch Matrix（硬）

| 路径/域 | 原因 |
|---|---|
| `Makefile` | shared seam（见 note；非路径占位） |
| `Tools/C6*` / `Tools/C5*` / `contracts/c6-*` / closure checkers | C6 / A 线 / 训练工具 |
| `scripts/*train*` / `Core/Training/**` / `training/**` | 训练面 |
| `docs/roadmap*` / `docs/commander-log/decisions.md` | 基线 SSOT |
| `closure/**` `candidates/**` `B7/**` `V1/**` | 他包 |
| capability matrix proven 手改 | 假绿 |
| `Core/ForceState/**` | 假路径；live 在 Config |
| `Core/Config/ForceStateDigest.swift` 等 catalog 实现文件 | S3 只 CREATE gate |
| `Core/State/DialogueStateEffectBoundary.swift` | S2 CREATE-only bridge |
| golden draft / T07a carrier 树 | 禁 apply/fork |

**Note：** “mainline shared seams” 是 **说明文字**，不是 writeset 路径、也不是可 expand 的 globs。

---

## Risks / Trade-offs

| 风险 | 缓解 |
|---|---|
| unit nil 路径冒充 production | proof_class + source-contract + production non-optional surfaces |
| S2 假 claim cancel 已接 App | deferred 表 + claim cap |
| S3 假 claim W9 App consumed | residual 字面 + FORCE_DIGEST_GATE_UNIT_PASS only |
| 第二 digest | AD-5 强制 validate only |
| soak / force App / lifecycle 假绿 | resource_deferred + 禁 Makefile + lane PARTIAL |
| TTS 误杀 alreadyDone badge「已完成」 | context-aware 扫描 |
| T07a local → operator | synthetic 三字段 |
| ContentView CRITICAL blast | apply 前 impact + risk-ack；**仅** `applyRuntimeReadbackStep` |

---

## Migration / 兼容

- Legacy `correlationProvider=nil`：**保留** unit/default helpers；production root **禁止**默认 nil。
- Legacy optional `run(text:)`：**保留** helper；App production 走 non-optional。
- 旧 UI 文本 restore ≠ DialogueState context。
- 不迁移 C6 case id 进硬门。
- Force App wiring：后续独立 change 在 catalog+metadata 就绪后落地。

---

## Open Questions

| ID | 问题 | 默认 ⭐ | 阻塞 apply? |
|---|---|---|---|
| OQ-1 | 单 turn provider 返回 nil（unit） | ⭐ 仅拒识/unpaired + 诊断 | 否 |
| OQ-2 | reliability 数值 | HANDOFF basis；不拍死 V1 | 是（S4 claim 前） |
| OQ-3 | 是否扩 composition gate cancel API | ⭐ **否**（deferred） | 否（已 cap） |
| OQ-4 | force App 何时接线 | ⭐ 待独立 non-empty versioned catalog + external metadata | 否（S3 unit 可先） |

---

## Proof / Claim Cap

允许：`OPENSPEC_PROPOSED` · `SOURCE_CONTRACT_PASS` · `LOCAL_COMPOSITION_WIRED` · `FIXTURE_LOCAL_PASS` · `UNIT_DELIBERATE_RED_PASS` · `BRIDGE_UNIT_PASS` · `FORCE_DIGEST_GATE_UNIT_PASS` · `TTS_PREFLIGHT_PASS`。

允许 lane 收口：**PARTIAL**（product lifecycle App wiring deferred + force catalog App consumption deferred）。

禁止：customer path DONE · operator-pass · T07b · V-PASS · C6 acceptance · W4 DONE · V1 RATIFIED · actionDemoProven 手翻 · product cancel/recovery DONE · **W9_APP_CONSUMED** · 旧 golden 整包 apply · 假 DONE。

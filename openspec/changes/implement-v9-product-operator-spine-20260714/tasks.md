# Tasks: implement-v9-product-operator-spine-20260714

```text
mode: dependency_DAG
authority: design.md AD-1..AD-10
revision: 2026-07-14-checklist-reconcile-r4
lane_status: PARTIAL
apply_head: 1b04fa16
apply_commits: a4bf8aa4,669ce366,0d59f0bd,1b04fa16
wave0: OpenSpec only (this change tree) — no Swift until independent review CLEAR + apply key
proof: unit | source_contract | build | runtime_local | runtime_local_preflight | fixture_local | operator(forbidden)
stop_on: writeset_exceeded | no_touch_hit | claim_cap_violation | missing_negative | banned_placeholder
dedupe: extend existing D1/force/speech/composition tests when covering; ProductOperator* only for spine gaps
resource_deferred: p95 | 20-turn | 300s soak | runtime_local_customer_shaped_golden | full_xcodebuild_when_s8_active | force_catalog_app_consumption | product_lifecycle_cancel_terminal_recovery_app_wiring
lane_closeout: may be PARTIAL (lifecycle App wiring + W9 App force consumption deferred)
```

## 0. Propose 波次（本文件落地 = OpenSpec 修订完成，不写业务代码）

- [x] 0.1 写/修订 `.openspec.yaml` / `proposal.md` / `design.md` / `tasks.md`
- [x] 0.2 写/修订 delta `specs/product-operator-spine/spec.md`
- [x] 0.3 路径冻结：消除 `Core/ForceState/**`、`or equivalent`、`live equivalent`、`package-local equivalent`、`name may vary`、开放 `and/or`、开放 `example:` 路径占位；S3 App force MODIFY 移除；S2 conditional matrix MODIFY 移除
- [x] 0.4 独立审（producer ≠ auditor）P0/P1=0 — evidence: `grok45_openspec_final_clearance_delta.md` CLEAR P0=0 P1=0 (conf 0.92); `hermes_hy3_openspec_clearance_review.md` CLEAR P0=0 P1=0 (conf 0.92)
- [x] 0.5 `openspec validate implement-v9-product-operator-spine-20260714 --strict` — evidence: change `--strict` pass; `openspec validate --all --strict` 40/40; `git diff --check` pass

**Stop：** 0.4/0.5 未过 → 禁止任何 Swift apply。

---

## S0 — 唯一 production composition root

**Depends on：** 0.x CLEAR
**Unlocks：** S1

### Exact paths

| op | path |
|---|---|
| MODIFY | `App/FrontstageRuntimeComposition.swift` |
| MODIFY | `Core/Execution/DemoSliceRoute.swift` |
| CREATE | `Tests/MAformacCoreTests/ProductOperatorCompositionRootTests.swift` |
| MODIFY | `Tests/MAformacCoreTests/SessionLifecycleCompositionGateTests.swift`（扩展 source-contract，dedupe） |
| MODIFY | `Tests/MAformacCoreTests/FrontstageContainmentSourceContractTests.swift`（若装配断言需增 correlation 针） |

### 前置

- K3 `SessionLifecycleCompositionGate.ensureActive` 已存在。
- **SPM unit 不实例化 App 类型**；App 用 source-contract。

### Tasks

- [x] S0.1 注释冻结：`FrontstageRuntimeComposition` = 唯一 customer-facing production composition root — evidence: `App/FrontstageRuntimeComposition.swift` S0 freeze comment; `ProductOperatorCompositionRootTests.testSoleProductionCompositionRoot_oneCachedRouteAndS0FreezeComment`
- [x] S0.2 `DemoSliceRoute` 提供 production per-call `route(text:correlationProvider:)`（provider non-optional on production surface）— evidence: `DemoSliceRouteTests.testProductionRouteSurface_*`
- [x] S0.3 Core unit：带非 nil provider 的 route 可构造（不 import App）— evidence: `DemoSliceRouteTests` + `ProductOperatorCorrelationWireTests` (SPM Core-only)
- [x] S0.4 source-contract：断言 `App/FrontstageRuntimeComposition.swift` 在 route 前有 ensureActive，且装配传入 correlation（S1 完成后收紧断言）— evidence: `SessionLifecycleCompositionGateTests.testAppSourceContract_sessionLifecycleGatePropertyAndEnsureActiveBeforeRoute`; `FrontstageContainmentSourceContractTests.testCompositionProductionCallsitePassesCorrelationProviderAndFailClosedIdentity`
- [x] S0.5 禁止第二 root：测试/评审 stop 条件 — evidence: `ProductOperatorCompositionRootTests` + `FrontstageContainmentSourceContractTests`

### Negative tests

- [x] N-S0-a 第二 composition root 不得被 accept 为 production — evidence: `ProductOperatorCompositionRootTests.testContentViewUsesCompositionRootAndHasNoLocalProductionRunner`
- [x] N-S0-b 绕过 root 直接 `DemoSliceRoute` 的用例 proof_class 必须 unit/test_double，不得 `runtime_local_customer` — evidence: `DemoSliceRouteTests` = SPM unit; golden `proof_class=fixture_local` only (`ProductOperatorGoldenContractTests.testGoldenProofClassIsFixtureLocalNotOperator`)
- [x] N-S0-c 禁止 claim「unit 实例化了 FrontstageRuntimeComposition」— evidence: `ProductOperatorCompositionRootTests` source-contract only (no App import/instantiation)

### Targeted validation

```text
swift test --filter ProductOperatorCompositionRootTests
swift test --filter SessionLifecycleCompositionGateTests
swift test --filter FrontstageContainmentSourceContractTests
```

### Stop condition

- writeset 出现 ContentView 内联 runner 当 production / 新全局单例 root → STOP
- 无 S0 绿 → 禁止 claim composition_gate

---

## S1 — Per-turn ProductionRouteCorrelationProvider

**Depends on：** S0
**Unlocks：** S2 bridge 可并行文档/unit；S4 customer-shaped 仍 resource_deferred；S5 integration

### Exact paths

| op | path |
|---|---|
| MODIFY | `App/FrontstageRuntimeComposition.swift` |
| MODIFY | `Core/Execution/DemoSliceRoute.swift` |
| MODIFY | `Core/Execution/DemoRuntimeSessionRunner.swift`（生产 `run(text:correlationProvider:)` non-optional surface；legacy optional 保留 helper） |
| CREATE | `Core/State/ProductionRouteCorrelationProvider.swift` |
| CREATE | `Tests/MAformacCoreTests/ProductOperatorCorrelationWireTests.swift`（仅 gap） |
| MODIFY | `Tests/MAformacCoreTests/D1TypedFactsWireDeliberateNegativeTests.swift`（dedupe 扩展） |
| MODIFY | `Tests/MAformacCoreTests/DemoSliceRouteTests.swift`（若与 per-call route 重叠） |

### 前置

- `RuntimeSessionCorrelationProvider` + `DialogueState.recordTypedFacts` 已存在。
- 身份源：`FrontstageVoiceTurn`（`sessionID` / positive `sequence` / `turnID`）+ `ensureActive` → generation。

### Tasks

- [x] S1.1 实现 `ProductionRouteCorrelationProvider` **factory**：exact inputs `routeTurnID: String`, `sessionRef: String`, `generationRef: String`, `groupOrdinal: UInt32` → returns `RuntimeSessionCorrelationProvider`；closure 使用冻结四元组 + 入参 `traceID` + frame identity；产出的 `RouteToDialogueCorrelation.schemaVersion` 与 `DialogueRouteAttribution.schemaVersion` **SHALL** 均为 `DialogueStateSchemaVersion.v1`；invalid/empty/overflow fail-closed — evidence: `ProductOperatorCorrelationWireTests.testFactoryPositive_*` + `testFactoryNegative_*`
- [x] S1.2 `FrontstageRuntimeComposition.routeDemoSlice`：每个 accepted current turn 构造 **一个** provider（`turn.turnID`、`turn.sessionID`、`String(lifecycleSnapshot.generation.value)`、`UInt32(exactly: turn.sequence)`），再调 `DemoSliceRoute.route(text:correlationProvider:)` — evidence: `ProductOperatorCompositionRootTests.testProductionRootWiresLifecycleIdentityIntoFactoryInputs`; `FrontstageContainmentSourceContractTests.testCompositionProductionCallsitePassesCorrelationProviderAndFailClosedIdentity`
- [x] S1.3 `DemoSliceRoute.route` 调 `DemoRuntimeSessionRunner.run(text:correlationProvider:)`（生产 non-optional）；legacy optional ctor/`run(text:)`/`defaultRunner` 仅 unit/default helper（**不**要求改 `defaultRunner` visibility）— evidence: `DemoSliceRouteTests.testProductionRouteSurface_*`; `testLegacyRouteHelper_withoutProviderRemainsDefaultSurface`
- [x] S1.4 deliberate-red：非法 schema / 缺 identity → denied + window 零突变 — evidence: `D1TypedFactsWireDeliberateNegativeTests.testNegative_UnsupportedSchemaVersionRefusedByReducerAndTraceGuardEmitted`; `ProductOperatorCorrelationWireTests.testFactoryNegative_*`
- [x] S1.5 deliberate-red：provider 返回 nil/invalid → 不记 typed facts，不得 success evidence — evidence: `D1TypedFactsWireDeliberateNegativeTests.testPositive_ProviderReturningNilLeavesWindowUnchangedAndAccountsTurn`; `ProductOperatorCorrelationWireTests.testProductionProviderBlankTraceDoesNotLandTypedFactsSuccess`
- [x] S1.6 deliberate-red：new/current-turn mismatch、invalid UInt32 sequence、empty identity → 无 typed-facts mutation + 可观测 refusal/no-success — evidence: `ProductOperatorCompositionRootTests.testProductionRootFailClosed_typedMismatchAndInvalidSequenceBeforeRoute`; `FrontstageRuntimeCompositionError` surface
- [x] S1.7 App source-contract：断言 `FrontstageRuntimeComposition.swift` 含 `ProductionRouteCorrelationProvider` 与 per-turn 装配 — evidence: `FrontstageContainmentSourceContractTests.testCompositionProductionCallsitePassesCorrelationProviderAndFailClosedIdentity`
- [x] S1.8 **禁止** mutable singleton/context box 作 correlation 身份源 — evidence: `Core/State/ProductionRouteCorrelationProvider.swift` per-turn factory; `FrontstageContainmentSourceContractTests` rejects `static var correlation` / `sharedCorrelation`

### Negative tests

- [x] N-S1-a production 装配 correlation 被置 nil → 构造/启动失败（不得 silent）— evidence: production path requires `correlationProvider:` (no legacy `.route(text: turn.utterance)`); fail-closed errors before route
- [x] N-S1-b invalid correlation 进入 window → FAIL — evidence: `D1TypedFactsWireDeliberateNegativeTests.testNegative_*`
- [x] N-S1-c 仅字段存在无 validator → FAIL — evidence: `ProductOperatorCorrelationWireTests.testFactoryNegative_BlankRouteSessionGenerationFailClosed`; factory + reducer validators exercised
- [x] N-S1-d sequence 无法 `UInt32(exactly:)` → no typed-facts success — evidence: `FrontstageRuntimeCompositionError.invalidTurnSequence`; `ProductOperatorCompositionRootTests.testProductionRootFailClosed_*`

### Targeted validation

```text
swift test --filter ProductOperatorCorrelationWireTests
swift test --filter D1TypedFactsWireDeliberateNegativeTests
swift test --filter DemoSliceRouteTests
```

### Stop condition

- production 路径仍默认 nil → STOP
- 用测试 nil 路径冒充 production wire → STOP
- global mutable correlation provider → STOP

---

## S2 — LifecycleFactsDialogueBridge（CREATE-only；product cancel/recovery deferred）

**Depends on：** S1
**Unlocks：** S3 推荐在后

### Exact paths

| op | path |
|---|---|
| CREATE | `Core/Lifecycle/LifecycleFactsDialogueBridge.swift` |
| CREATE | `Tests/MAformacCoreTests/ProductOperatorLifecycleFactsBridgeTests.swift` |

**Removed：** conditional MODIFY `Core/State/DialogueStateEffectBoundary.swift`；MODIFY `DialogueStateEffectBoundaryP1P2Tests.swift`。

### 前置

- `SessionLifecycleEvent` **已存在**于 `Core/Lifecycle/SessionLifecycleFacts.swift`（约 :31–43）；禁止再 claim 缺失。
- **不**修改 `SessionLifecycleCompositionGate` 为 terminal/cancel/recovery API。
- **不**新建第二 `SessionLifecycleCoordinator` 权威。
- product-path cancel/restart/terminal/recovery → DialogueState **本 change deferred**（design AD-4）。

### Tasks

- [x] S2.1 实现 bridge：接受 caller-provided `DialogueW7EffectMatrix`；映射表（design AD-4.1）
  - `start` → `sessionStarted`
  - `terminal(cancelled)` → `turnCancelled`
  - `terminal(non-cancelled settled)` → `terminalClear`
  - `newGeneration` → `generationFenced`
  - `recoveryReady` → `checkpointRestoreAttempted` — evidence: `ProductOperatorLifecycleFactsBridgeTests.test*MapsTo*` + `testMapAndApply*DelegatesToMatrix`
- [x] S2.2 bridge 调用 `matrix.apply`；missing entry / version mismatch → 零效应 fail-closed — evidence: `testUnsupportedMatrixVersionFailsClosed`; `testMissingMatrixEntryFailsClosed`
- [x] S2.3 unit：cancel → effect focus/lastReadback clear + terminalAudit retainAsAuditOnly（矩阵既有 entry 时）— evidence: `testMapAndApplyTerminalCancelledDelegatesToMatrix`
- [x] S2.4 unit：stale/unsupported fact fail-closed — evidence: `testUnknownFactFromDecodeFailsClosed`; `testMissingMatrixEntryForTurnCancelledFailsClosed`
- [x] S2.5 **显式 non-claim**：不报告 product-path cancel/recovery 已接到 App composition — evidence: bridge unit-only (`Core/Lifecycle/LifecycleFactsDialogueBridge.swift`); `App/` zero bridge refs; gate `noTerminalAPI` source-contract (**product-path wiring still DEFERRED**)

### Negative tests

- [x] N-S2-a unknown fact / version mismatch → 零字段突变 — evidence: `ProductOperatorLifecycleFactsBridgeTests.testUnknownFactFromDecodeFailsClosed`; `testUnsupportedMatrixVersionFailsClosed`
- [x] N-S2-b 把 deferred 场景标 `runtime_local` product cancel DONE → FAIL / stop — evidence: golden/stale-recovery `proof_class=fixture_local`; `ProductOperatorGoldenContractTests.testCustomerPathDONEClaimIsForbidden`
- [x] N-S2-c bridge 持有 lifecycle 权威副本 → FAIL 架构 stop — evidence: `testBridgeOwnsNoCoordinator`; `testBridgeOwnsNoDialogueState`; `testBridgeOwnsNoStoreOrRegister`
- [x] N-S2-d MODIFY DialogueStateEffectBoundary 出现在 apply diff → STOP — evidence: apply diff `aae8a8ac..0d59f0bd` has zero `DialogueStateEffectBoundary` MODIFY

### Targeted validation

```text
swift test --filter ProductOperatorLifecycleFactsBridgeTests
```

### Stop condition

- 新建第二 lifecycle coordinator → STOP
- claim product cancel/recovery wired → STOP
- 把 profile_only 写成 proof_runtime → STOP

### Deferred（显式）

| 项 | 原因 |
|---|---|
| composition gate 上 cancel/terminal/recovery API | gate 现仅 ensureActive；扩 API 需独立 risk-ack |
| App product-path cancel/restart/terminal/recovery → DialogueState | 无 composition call site；resource_deferred |
| matrix 补 generationFenced/sessionStarted/checkpoint* entries | 本 change 不改 DialogueStateEffectBoundary |

---

## S3 — Force catalog digest gate（unit only；App DEFERRED）

**Depends on：** S1（推荐 S2 后）
**Unlocks：** 无 App force 场景；仅 gate unit claim

### Exact paths

| op | path |
|---|---|
| CREATE | `Core/Config/ForceStateDigestGate.swift` |
| CREATE | `Tests/MAformacCoreTests/ProductOperatorForceStateDigestGateTests.swift` |
| MODIFY | `Tests/MAformacCoreTests/ForceStateDigestTests.swift`（**仅当** dedupe 真需要） |

**Removed from S3：** MODIFY `App/ContentView.swift` · `ForceStateDigest.swift` · `ForceStateCatalog.swift` · `DemoForceStateBoundary.swift` · `D2ForceStateApplierDeliberateNegativeTests.swift`。

### 前置

- 复用 `ForceStateDigest.validate`；**永不**实现第二 digest。
- Live residual（字面）：`applySnapshotCells has matrix-digest authority only; no force_catalog metadata carrier exists`
- force catalog digest **≠** capability-matrix digest。
- Handoff 观察名预留：`force_catalog_digest_hex` · `capability_matrix_digest_hex`（禁 map `TerminalAck.canonicalDigest` → force 字段）。

### Tasks

- [x] S3.1 `ForceStateDigestGate`：stateless public `validate(metadata: ForceStateDigestMetadata?, against catalog: ForceStateCatalog) throws` → **仅** 委托 `ForceStateDigest.validate`；无 recompute、无 catalog ownership、无 second digest — evidence: `Core/Config/ForceStateDigestGate.swift`; `ProductOperatorForceStateDigestGateTests.testGateIsStatelessAndDelegatesOnly`
- [x] S3.2 unit：absent / algorithm / mismatch 与 `ForceStateDigest.validate` 一致 — evidence: `ProductOperatorForceStateDigestGateTests` + `ForceStateDigestTests` (11/11 green)
- [x] S3.3 **不** 改 ContentView `applySnapshotCells`；**不** claim App 消费 — evidence: S3 apply (`a4bf8aa4`) CREATE-only gate; ContentView touch limited to S5 readback (**W9 App consumption DEFERRED**)
- [x] S3.4 claim cap：`FORCE_DIGEST_GATE_UNIT_PASS` only；**永不** `W9_APP_CONSUMED` — evidence: `ProductOperatorForceStateDigestGateTests.testGateClaimsOnlyUnitGate`

### Negative tests

- [x] N-S3-a mismatch digest 被 gate 接受 → FAIL — evidence: `testMismatchedDigestFailsClosedWithoutSilentRepair`
- [x] N-S3-b 第二 digest 实现出现在 writeset → STOP — evidence: `testGateDoesNotRecomputeDigest`; apply diff has no second digest impl
- [x] N-S3-c claim `W9_APP_CONSUMED` → STOP — evidence: `testGateClaimsOnlyUnitGate` explicit ceiling
- [x] N-S3-d ContentView force MODIFY 进入 S3 apply → STOP — evidence: S3 commit `a4bf8aa4` has zero `App/ContentView.swift` touch

### Targeted validation

```text
swift test --filter ProductOperatorForceStateDigestGateTests
swift test --filter ForceStateDigestTests
```

### Stop condition

- 4↔5 migration 模糊映射复活 → STOP
- 新建 `Core/ForceState/**` → STOP
- 把 matrix digest 当 force digest → STOP

### Deferred（显式）

| 项 | residual |
|---|---|
| App force-catalog consumption | `applySnapshotCells has matrix-digest authority only; no force_catalog metadata carrier exists`（resource_deferred until independent non-empty versioned catalog + external metadata） |

---

## S4 — Golden replay + reliability（composition 门控 + resource deferred soak）

**Depends on：** S0 合同；**customer-shaped runtime** depends S1 + resource window
**Unlocks：** 无（不解锁 operator）

### Exact paths

| op | path |
|---|---|
| CREATE | `Tests/Fixtures/product-operator-golden/` |
| CREATE | `Tests/Fixtures/product-operator-reliability/` |
| CREATE | `Tests/MAformacCoreTests/ProductOperatorGoldenContractTests.swift` |
| CREATE | `Tests/MAformacCoreTests/ProductOperatorReliabilityProvisionalTests.swift` |
| FORBIDDEN | `contracts/c6-*` / `Tools/C6*` / `define-demo-golden-run-and-voice` apply / `Makefile` soak |

### 前置

- composition_gate 未过：只允许 schema/fixture unit。
- soak/p95：**resource_deferred_tests**。

### Tasks

- [x] S4.1 golden step 最小字段：`utterance` · `expected_disposition` · `expected_readback` (optional) · `proof_class` — evidence: `Tests/Fixtures/product-operator-golden/*.jsonl`; `ProductOperatorGoldenContractTests.test*FixturesLoadAndValidate`
- [x] S4.2 schema 测试：缺字段 / 非法 cell 引用 → 拒绝 — evidence: `testRejectsMissingUtterance`; `testRejectsUnknownDisposition`; `testRejectsAcceptedWithoutReadback`
- [x] S4.3 composition 未过：禁止 customer-shaped harness 标 DONE — evidence: fixtures `proof_class=fixture_local` only; `testCustomerPathDONEClaimIsForbidden` (**customer-shaped runtime still resource_deferred**)
- [x] S4.4 provisional receipt 字段：`threshold_basis` · `basis_citation` · `metric_id` · `provisional_p95_ms` · `soak_status` · `non_claims`（design AD-6）— evidence: `Tests/Fixtures/product-operator-reliability/provisional-receipt.json`; `ProductOperatorReliabilityProvisionalTests.testValidProvisionalReceiptPassesValidation`
- [x] S4.5 `soak_status=resource_deferred` 直至 composition + resource window；**禁止** Makefile soak gate — evidence: `testSoakStatusIsResourceDeferredNotPass`; no Makefile touch in apply diff
- [x] S4.6 non-claim：非 W4 DONE、非 V1 RATIFIED、非 actionDemoProven 手翻 — evidence: `testReliabilityDoesNotClaimW4DONE`; `testRejectsMissingNotV1Ratified`; `testRejectsMissingNotW4Done`

### Negative tests

- [x] N-S4-a 无 composition_gate 却 claim customer path DONE → FAIL — evidence: `ProductOperatorGoldenContractTests.testCustomerPathDONEClaimIsForbidden`
- [x] N-S4-b reliability 数字无 `basis_citation` → FAIL — evidence: `testRejectsMissingBasisCitation`
- [x] N-S4-c 引用 actionDemoProven 手翻 → FAIL — evidence: reliability `non_claims` enforcement tests; fixtures carry explicit non-claims
- [x] N-S4-d Makefile 新增 soak target → STOP — evidence: apply diff `aae8a8ac..0d59f0bd` has zero Makefile touch

### Targeted validation

```text
swift test --filter ProductOperatorGoldenContractTests
swift test --filter ProductOperatorReliabilityProvisionalTests
```

### resource_deferred_tests（不得在本任务勾成 DONE）

- [ ] R-S4-p95 p95 latency harness（deferred）
- [ ] R-S4-20 20-turn soak（deferred）
- [ ] R-S4-300 300s soak（deferred）
- [ ] R-S4-rt runtime_local customer-shaped golden（deferred）

### Stop condition

- 修改 capability matrix proven 计数 → STOP
- 写入 C6 合同目录 → STOP
- claim W4 DONE → STOP

---

## S5 — TTS hard gate（可执行 + context-aware + App readback）

**Depends on：** S1
**Unlocks：** 无

### Exact paths

| op | path |
|---|---|
| MODIFY | `Core/Voice/SpeechSynthesisEngine.swift` |
| MODIFY | `Core/Execution/DemoRuntimeSessionRunner.swift` |
| MODIFY | `Core/Execution/FallbackContext.swift` |
| MODIFY | `App/ContentView.swift`（**仅** `applyRuntimeReadbackStep`） |
| CREATE | `scripts/run_v9_product_operator_tts_preflight.sh` |
| CREATE | `Tests/MAformacCoreTests/ProductOperatorTTSHardGateTests.swift` |
| MODIFY | `Tests/MAformacCoreTests/SpeechSynthesisEngineTests.swift`（dedupe） |
| MODIFY | `Tests/MAformacCoreTests/FrontstageContainmentSourceContractTests.swift`（source-contract / App call site 断言；dedupe） |

### 禁语表（**仅**错误态 dialogText/ttsText；context-aware）

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

**扫描范围：** reject / clarify / safety / unsupported / cancel / unmounted
**排除：** accepted · alreadyDone · partialAcceptPartialRefuse
**禁止：** blanket 扫 badge labels · `DemoRuntimeResultPresentationMatrix` success/partial 字符串

### Tasks

- [x] S5.1 `AVSpeechSynthesisEngine.speak`：`bestChineseVoice()==nil` → 不调 synthesizer → `.failed(reason: "chinese_voice_unavailable")`；不 silent systemDefault success；**不**改 `SpeechSynthesisEngine` protocol 形状 — evidence: `ProductOperatorTTSHardGateTests.testAVSpeechEngine_nilChineseVoiceFailsClosedWithoutSystemDefaultSuccess`; `SpeechSynthesisEngineTests`
- [x] S5.2 runner：TTS failed/empty → visual-first 保留；**不得** voice-confirmed success；Core `RuntimePresentationPayload` / `PresentationVoiceDisplayState` synthesis 失败时 **SHALL** `.voiceState=.idle`（**不得** `.speak`）（最小 runner/route 数据流）— evidence: `testRunnerFullPath_failedSynthesisKeepsVisualTruthAndFreezesCoreVoiceIdle`; `testRunnerPartialPath_failedSynthesisKeepsAcceptedVisualAndTracesFailure`
- [x] S5.3 FallbackContext / 错误文案 context-aware 禁语 — evidence: `testCompletionPhraseGate_eachForbiddenPhraseFailsOnErrorOutcomes`; `testCompletionPhraseGate_resolvedFallbackContextsForSafetyClarifyHaveNoForbiddenPhrases`
- [x] S5.4 `ContentView.applyRuntimeReadbackStep`：捕获 `SpeechSynthesisResult`；visual-first 进度；App `StagePresentationSnapshot` / `PresentationVoiceState` synthesis 失败时 **不得** `.voiceState=.speaking`；可观测 TTS failure；不标 voice success — evidence: `testAppApplyRuntimeReadbackStep_capturesSpeechResultVisualFirstNoFalseSpeaking`; `FrontstageContainmentSourceContractTests.testS5ApplyRuntimeReadbackStepCapturesSpeechResultAndFreezesAppVoiceOnFailure`
- [x] S5.5 CREATE `scripts/run_v9_product_operator_tts_preflight.sh`：本机真实 AVSpeech synthesizer/voice lookup zh-CN/zh*；机读 PASS/FAIL；proof=`runtime_local_preflight` — evidence: live run `verdict=PASS` `proof_class=runtime_local_preflight` exit=0 (2026-07-14)
- [x] S5.6 tests：`RecordingSpeechSynthesisEngine` enqueued vs failed；source-contract 覆盖 App speak 结果不丢弃 — evidence: `SpeechSynthesisEngineTests.testRecordingSpeechSynthesisEngineSurfacesConfiguredFailureAndEnqueue`; `FrontstageContainmentSourceContractTests.testS5ApplyRuntimeReadbackStep*`

### Negative tests

- [x] N-S5-a safety/clarify 文案含禁语 → FAIL — evidence: `testCompletionPhraseGate_eachForbiddenPhraseFailsOnErrorOutcomes`
- [x] N-S5-b TTS failed 却标记语音成功并掩盖错误态 → FAIL — evidence: runner/App failed-synthesis tests above
- [x] N-S5-c `bestChineseVoice` nil 仍 success → FAIL — evidence: `testAVSpeechEngine_nilChineseVoiceFailsClosedWithoutSystemDefaultSuccess`
- [x] N-S5-d alreadyDone badge「已完成」被误扫为 TTS hard-gate FAIL → FAIL（扫描过宽）— evidence: `testCompletionPhraseGate_acceptedAlreadyDonePartialAndBadgeOnlyNotBlanketRejected`
- [x] N-S5-e Core synthesis failed 仍 `PresentationVoiceDisplayState.speak` → FAIL — evidence: `testRunnerFullPath_failedSynthesisKeepsVisualTruthAndFreezesCoreVoiceIdle`
- [x] N-S5-f App synthesis failed 仍 `PresentationVoiceState.speaking` → FAIL — evidence: `testAppApplyRuntimeReadbackStep_capturesSpeechResultVisualFirstNoFalseSpeaking`

### Targeted validation

```text
swift test --filter ProductOperatorTTSHardGateTests
swift test --filter SpeechSynthesisEngineTests
swift test --filter FrontstageContainmentSourceContractTests
# scripts/run_v9_product_operator_tts_preflight.sh  → runtime_local_preflight
```

### Stop condition

- 把 TTS enqueued 当 actionDemoProven → STOP
- 把 preflight 当 operator/true-device → STOP

---

## S6 — T07a attempt-ledger consumer（local only）

**Depends on：** S0（合同）；可与 S4 并行
**Unlocks：** 无（**不** 解锁 T07b）

### Exact paths

| op | path |
|---|---|
| CREATE | `Core/Ceremony/OperatorCeremonyAttemptLedger.swift` |
| CREATE | `Tests/Fixtures/t07a-synthetic/` |
| CREATE | `Tests/MAformacCoreTests/ProductOperatorT07aLedgerConsumerTests.swift` |
| FORBIDDEN | `openspec/changes/define-t07-operator-ceremony-carrier-20260712/**` 修改 · Makefile ceremony gate · T07b claim |

### 前置（carrier 引用，不 fork）

- 六段 envelope：`subject` · `environment` · `attempt` · `axes` · `expiry` · `evidence`
- synthetic 三字段：`synthetic=true` · `proof_class=local` · `satisfies_t07b_prerequisite=false`
- launch modes：`xcode_run` \| `signed_app` \| `archive`（carrier 词汇）

### Tasks

- [x] S6.1 校验六段 envelope + schema version — evidence: `ProductOperatorT07aLedgerConsumerTests.testEnvelopeMissing*Fails` (6 sections)
- [x] S6.2 immutable attempt ledger：mode 切换新 attempt；失败不被成功覆盖 — evidence: `testModeSwitchCreatesNewAttempt`; `testLedgerDoesNotOverwritePriorFailure`
- [x] S6.3 exact join → 上限 `local_schema_join_only` — evidence: `testExactIdentityJoinReturnsLocalSchemaJoinOnly`
- [x] S6.4 synthetic fixtures 强制三字段 — evidence: `testValidSyntheticFixturePassesThreeFieldCheck`; `testMissingSyntheticTrueFails`
- [x] S6.5 near-match identity fail-closed — evidence: `testNearMatchSHAFailsJoin`

### Negative tests

- [x] N-S6-a 缺 synthetic 三字段仍绿 → FAIL — evidence: `testMissingSyntheticTrueFails`; `testWrongProofClassFails`
- [x] N-S6-b local 绿写进 T07b prerequisite true → FAIL — evidence: `testContradictoryT07bPrerequisiteFails`; `testLocalJoinCannotSatisfyT07b` (**T07b still PHASED_BLOCKED**)
- [x] N-S6-c 成功 attempt 覆盖历史失败 row → FAIL — evidence: `testLedgerDoesNotOverwritePriorFailure`

### Targeted validation

```text
swift test --filter ProductOperatorT07aLedgerConsumerTests
```

### Stop condition

- 物化 `verify-operator-ceremony-source` 为 Makefile 可执行门 → STOP
- 任何 operator-pass 措辞 → STOP
- fork/修改 T07a carrier change 树 → STOP

---

## 场景覆盖矩阵

| 场景 | 主 slice | 证明上限 |
|---|---|---|
| success | S1+S5 | unit → later runtime_local |
| reject/clarify/safety | S1+S5 | unit + context-aware 禁语 |
| stale generation | S2 bridge unit | **product deferred** |
| cancel/restart | S2 bridge unit | **product deferred** |
| provider failure | S1 | unit deliberate-red |
| offline/recovery | S2+S4 | unit/fixture；product recovery deferred |
| force digest | S3 | **FORCE_DIGEST_GATE_UNIT_PASS only**（App deferred） |
| chinese voice unavailable | S5 | unit + runtime_local_preflight |

---

## 全局 validation（apply 收口，仍 local）

```text
swift test --filter ProductOperator          # 99/99 green @ HEAD 1b04fa16 (2026-07-14)
swift test --filter D1TypedFactsWireDeliberateNegativeTests  # 10/10 green
swift test --filter ForceStateDigestTests    # 11/11 green
scripts/run_v9_product_operator_tts_preflight.sh  # PASS runtime_local_preflight exit=0
openspec validate implement-v9-product-operator-spine-20260714 --strict  # pass
openspec validate --all --strict             # 40/40 pass
git diff --check                             # pass (tasks.md only in this reconcile)
# detect_changes / git diff ⊆ allowed_writeset_future_apply
# 禁止: Makefile / no_touch / Core/ForceState/** / DialogueStateEffectBoundary MODIFY / Force catalog App claim
# P0 scope remediation @ 1b04fa16: unauthorized `Core/Ceremony/ProductOperatorFixture.swift` net-removed; fixture load/validate support relocated into `Tests/MAformacCoreTests/ProductOperatorGoldenContractTests.swift` (allowed GoldenContract test path)
```

**Closeout 允许 claim（证据齐时）：**
`LOCAL_COMPOSITION_WIRED` + `FIXTURE_LOCAL_PASS` + `SOURCE_CONTRACT_PASS` + `BRIDGE_UNIT_PASS` + `FORCE_DIGEST_GATE_UNIT_PASS` + `TTS_PREFLIGHT_PASS` — **all evidenced @ HEAD 1b04fa16; ceiling remains PARTIAL**

**允许 lane 收口：** **PARTIAL**（product lifecycle App wiring deferred + force catalog App consumption deferred + customer-shaped runtime / p95 / soak resource_deferred）

**禁止 claim：** customer path DONE / operator-pass / T07b / V-PASS / W4 DONE / actionDemoProven≠0 / product cancel-recovery DONE / **W9_APP_CONSUMED** / 旧 golden 整包 apply / 假 DONE

---

## Deferred / Out of scope（显式）

| 项 | 状态 |
|---|---|
| T07b / P8 / operator-pass | PHASED_BLOCKED |
| V1 RATIFIED / W4 DONE | 外部；不假设 |
| `define-demo-golden-run-and-voice` 整包 | draft_deferred；不 apply |
| product-path cancel/terminal/recovery → DialogueState / App | DEFERRED（gate API 边界） |
| force catalog App consumption / W9_APP_CONSUMED | DEFERRED；residual 字面见 S3 |
| p95 / 20-turn / 300s soak | resource_deferred_tests |
| mounted 1→N / matrix 扩面 | 禁 |
| Makefile / C6 / C5 / closure / 训练 / Core/Training / scripts/*train* | no-touch |
| `Core/ForceState/**` | 禁（假路径） |
| MODIFY DialogueStateEffectBoundary / ForceStateDigest/Catalog/DemoForceStateBoundary | 本 change 禁 |

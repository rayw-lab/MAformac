# Change: implement-v9-product-operator-spine-20260714

```text
change_id: implement-v9-product-operator-spine-20260714
lane: B
role: complex-architecture-producer (not auditor)
authority: v9 product-operator spine (shortest executable product path freeze)
status: PROPOSED_OPENSPEC_ONLY
revision: 2026-07-14-commander-adjudication-r2
self_signed_review_clear: false
proof_ceiling_now: CONTRACT_AND_FIXTURE_PREP_ONLY
proof_ceiling_after_composition_gate: LOCAL_RUNTIME_WIRE_PROOF (unit/build/runtime local only)
proof_ceiling_forbidden: customer_path_DONE | operator-pass | T07b | V-PASS | C5 V-PASS | C6 acceptance | W4 DONE | V1 RATIFIED | actionDemoProven handflip | W9_APP_CONSUMED | product cancel/recovery DONE
historical_input_not_apply: define-demo-golden-run-and-voice (status=draft_deferred)
t07a_carrier_not_fork: define-t07-operator-ceremony-carrier-20260712 (consume only)
mounted_truth: 1 mounted tool cell; actionDemoProven=0/120 MUST remain honest
banned_placeholders: Core/ForceState/** | or equivalent | live equivalent | package-local equivalent | name may vary | and/or | open-ended example: paths
lane_may_close: PARTIAL when product lifecycle App wiring and W9 App force-catalog consumption remain deferred
```

## Why

当前 production 形状存在**产品脊柱空洞**：

1. **Composition root 不完整**：`App/FrontstageRuntimeComposition.routeDemoSlice` 已能懒建 `DemoSliceRoute` 并做 K3 parent `ensureActive`，但 `DemoSliceRoute` 构造 `DemoRuntimeSessionRunner` 时 **`correlationProvider` 默认 `nil`**——D1 wire 在真实 App 路径上是 opt-out 空转（typedFactsWindow 永远空）。
2. **W7/W8/W9 已有契约与部分 Core 类型**，但**没有唯一 production composition root**把 **per-turn correlation identity** / lifecycle facts bridge / force-state **catalog digest gate (unit)** 接到同一条 customer-facing 装配链；测试路径绿 ≠ 产品路径有 provider。
3. **Force-state live 面在 `Core/Config/**`**（`ForceStateDigest` / `ForceStateCatalog` / `DemoForceStateBoundary`），**不存在** `Core/ForceState/**`。`App/ContentView.applySnapshotCells` 现网仅经 `DemoVehicleStateApplier` 校验 **capability-matrix digest**（另一 SSOT），**无** 权威 `ForceStateCatalog`、**无** 外部 `ForceStateDigestMetadata` 载体。本 change **诚实 DEFER** App force-catalog 接线；S3 只交付可单测的 `ForceStateDigestGate` 薄包装。
4. **Golden / reliability / TTS / T07a** 仍散落在 `draft_deferred` 历史骨架与 carrier 合同里：若直接 apply `define-demo-golden-run-and-voice` 会越界；T07a **只消费**既有 carrier 六段 envelope，**禁止** fork carrier。
5. **S2 诚实边界**：`SessionLifecycleCompositionGate` 仅 `ensureActive`（ready→active），**无** terminal/cancel/recovery API。`SessionLifecycleEvent` **已存在**于 `Core/Lifecycle/SessionLifecycleFacts.swift`（约 :31–43）。bridge 纯映射 + unit；product-path cancel/recovery **deferred**。
6. **TTS**：runner 与 App `applyRuntimeReadbackStep` 对 `SpeechSynthesisResult` 消费不齐；`bestChineseVoice()==nil` 不得静默当 success；禁语扫描必须 **context-aware**（只扫 reject/clarify/safety/unsupported/cancel/unmounted 的 dialog/tts 文案）。语音态负向断言按层拆分：Core `PresentationVoiceDisplayState`（`.speak`/`.idle`）≠ App `PresentationVoiceState`（`.speaking`）；synthesis 失败时 Core 冻结 `.idle`、App 不得 `.speaking`。

本 change 冻结**最短可执行产品路径**：先 composition gate（唯一 root + per-turn non-nil correlation）→ lifecycle **bridge mapping**（product cancel/recovery deferred）→ force **gate unit only**（App 消费 deferred）→ golden/reliability/TTS **合同与 fixture 准备** + TTS preflight 脚本 → T07a local ledger consumer。**composition gate 未过前，不得声称 customer path DONE。** 因 product lifecycle 与 W9 App consumption 仍 deferred，lane 收口可 **PARTIAL**。

## What Changes

### 产品脊柱（本 change 权威范围）

| 切片 | 内容 |
|---|---|
| S0 Composition Root | 唯一 production composition root=`App/FrontstageRuntimeComposition.swift`；Core 单测构造 `DemoSliceRoute` + 非 nil provider；App 接线用 **source-contract** 证明（SPM unit **不**实例化 App 类型） |
| S1 Correlation Wire | 唯一生产绑定：`Core/State/ProductionRouteCorrelationProvider.swift`；**per-turn factory** 冻结身份输入；`RouteToDialogueCorrelation` 与 `DialogueRouteAttribution` 的 `schemaVersion` 均冻结 `DialogueStateSchemaVersion.v1`；`DemoSliceRoute.route(text:correlationProvider:)` 与 runner `run(text:correlationProvider:)` 为 App 生产面（legacy optional ctor/`run(text:)` 仅 unit/default helper） |
| S2 Lifecycle Facts Bridge | **CREATE-only** `Core/Lifecycle/LifecycleFactsDialogueBridge.swift` + ProductOperator bridge tests；**不** MODIFY `DialogueStateEffectBoundary`；接受 caller-provided `DialogueW7EffectMatrix`；product cancel/terminal/recovery **deferred** |
| S3 Force Catalog Digest Gate | **仅** CREATE `Core/Config/ForceStateDigestGate.swift` + CREATE `ProductOperatorForceStateDigestGateTests`（必要时 MODIFY `ForceStateDigestTests` dedupe）；**不** MODIFY ContentView / ForceStateDigest / Catalog / DemoForceStateBoundary；claim 上限 `FORCE_DIGEST_GATE_UNIT_PASS`，**永不** `W9_APP_CONSUMED` |
| S4 Golden / Reliability prep | fixture 路径 `Tests/Fixtures/product-operator-*`；provisional receipt；soak = `resource_deferred_tests` |
| S5 TTS hard gate | `SpeechSynthesisEngine`（含 `bestChineseVoice` nil → `.failed(reason: "chinese_voice_unavailable")`）+ runner + FallbackContext（context-aware 禁语）+ **`App/ContentView.applyRuntimeReadbackStep`** + `scripts/run_v9_product_operator_tts_preflight.sh`（`runtime_local_preflight`）+ **CREATE** `ProductOperatorTTSHardGateTests` + **MODIFY** `SpeechSynthesisEngineTests` + **MODIFY** `FrontstageContainmentSourceContractTests` |
| S6 T07a consumer | `Core/Ceremony/OperatorCeremonyAttemptLedger.swift` + fixtures + tests；不 fork carrier |

### 明确不直接 apply

- **`define-demo-golden-run-and-voice`**：仅作 `draft_deferred` **历史输入**。
- **`define-t07-operator-ceremony-carrier-20260712`**：只消费，不修改、不 fork。

## Capabilities

### New Capabilities

- `product-operator-spine`：唯一 production composition root、per-turn provider fail-closed、W7/W8/W9 消费接线边界（含诚实 deferred）、golden/reliability 准备、TTS hard gate + preflight、T07a local attempt-ledger consumer。

### Modified Capabilities

- None as archive merge targets. Upstream carriers remain owners (W7/W8/W9/T07). 本 change **消费** 上述契约，不夺取 ownership，不声明 upstream DONE。

## Non-Goals

- 不手翻 `actionDemoProven`；不把 0/120 写成非零。
- 不扩 mounted catalog（保持 mounted=1）。
- 不解锁 T07b / operator-pass / V-PASS / C5 V-PASS / C6 acceptance。
- 不假设 V1 RATIFIED；不 claim W4 DONE / W9_APP_CONSUMED。
- 不 apply 完整 `define-demo-golden-run-and-voice`。
- 不建立第二套 DialogueState / lifecycle coordinator / state writer / **第二 digest 实现**。
- 不 claim SPM unit tests 实例化 App 类型。
- 不在本 change 把 `DemoVehicleStateApplier.TerminalAck.canonicalDigest` 映射为 force catalog 字段。
- 不碰 A 线 / S8 / training / C5：`Makefile`、`Tools/C5*`、`Tools/C6*`、`contracts/c6-*`、`Core/Training/**`、`scripts/*train*`、closure/candidates/B7/V1、roadmap/decisions。
- 不写业务代码于本 propose 波次（本 change 仅 OpenSpec 产物）；apply 另 key + risk-ack。

## Success Criteria

1. `openspec validate implement-v9-product-operator-spine-20260714 --strict` 通过（**commander 跑**；本 revision **不**自称已跑 validate/review clear）。
2. proposal/design/tasks/delta specs 与 `.openspec.yaml` writeset **精确一致**；无 banned placeholders。
3. 行为契约可区分：composition gate 绿 vs force gate unit 绿 vs golden fixture 准备绿 vs operator 绿（后两者不得互相替代）。
4. proof class 分层写死：unit ≠ build ≠ runtime_local ≠ runtime_local_preflight ≠ fixture_local ≠ operator。
5. reliability threshold 仅 `provisional` + HANDOFF 出处；soak 进 `resource_deferred_tests`。
6. T07a synthetic cap 三字段强制；不得满足 T07b。
7. S3 residual 字面冻结：`applySnapshotCells has matrix-digest authority only; no force_catalog metadata carrier exists`。

## Non-Automated Success Signals

- 审阅者一眼看出：真实 App composition 必须 **per-turn** 非 nil provider；测试默认 nil 路径不得冒充 production。
- composition gate 未过时，任何 “customer path DONE” 措辞 = 假绿。
- 错误态文案不出现完成承诺短语表中任一项（**context-aware**，非 blanket 扫 badge/success 字符串）。
- force catalog digest 与 capability-matrix digest 不得混称；观察字段名 `force_catalog_digest_hex` / `capability_matrix_digest_hex` 仅 handoff 预留。
- S3 绿只能说 `FORCE_DIGEST_GATE_UNIT_PASS`，不能说 App 已消费 W9 catalog。

## Impact

### 本波次唯一允许写入

- `openspec/changes/implement-v9-product-operator-spine-20260714/**`

### 未来 apply（闭集；exact 见 design/tasks 与 `.openspec.yaml` `allowed_writeset_future_apply`）

| 区域 | 精确路径 |
|---|---|
| App composition | `App/FrontstageRuntimeComposition.swift` |
| App TTS readback call site | `App/ContentView.swift`（**仅** `applyRuntimeReadbackStep`；**不含** S3 `applySnapshotCells` force gate） |
| Route wiring | `Core/Execution/DemoSliceRoute.swift` |
| Runner | `Core/Execution/DemoRuntimeSessionRunner.swift`（S1 生产 `run(text:correlationProvider:)` + S5 TTS） |
| Production correlation | `Core/State/ProductionRouteCorrelationProvider.swift` |
| Lifecycle bridge | `Core/Lifecycle/LifecycleFactsDialogueBridge.swift`（CREATE-only） |
| Force digest gate | `Core/Config/ForceStateDigestGate.swift`（薄包装，调用 `ForceStateDigest.validate`） |
| TTS engine | `Core/Voice/SpeechSynthesisEngine.swift` + `FallbackContext.swift` |
| TTS preflight | `scripts/run_v9_product_operator_tts_preflight.sh` |
| T07a | `Core/Ceremony/OperatorCeremonyAttemptLedger.swift` |
| Fixtures | `Tests/Fixtures/product-operator-golden/` · `product-operator-reliability/` · `t07a-synthetic/` |
| Tests | 见 tasks 闭集 + 既有 D1/force/speech/composition 扩展（dedupe；**不含** DialogueStateEffectBoundary 测试 MODIFY） |

### Hard no-touch

见 `.openspec.yaml` `no_touch` 与 design §No-Touch Matrix。含 **`Core/ForceState/**`（不存在，禁止新建）**、`Core/Config/ForceStateDigest.swift` / `ForceStateCatalog.swift` / `DemoForceStateBoundary.swift`（本 change 不改；S3 只 CREATE gate）、`Core/State/DialogueStateEffectBoundary.swift`、`Core/Training/**`、`Tools/C5*`、`scripts/*train*`。

## Dependencies（消费，非吞并）

| Upstream | 用途 | 本 change 不得宣称 |
|---|---|---|
| D1 wire + `RuntimeSessionCorrelationProvider` | correlation 注入面 | W7 DONE |
| K1/K2/K3 session-lifecycle | active gate + `SessionLifecycleEvent` | W8 DONE / product cancel wired |
| W7 effect boundary / typed schema | matrix 由 bridge 消费（caller-provided） | verify-dialogue-state green；matrix 本 change 不改 |
| W9 `ForceStateDigest` / catalog | gate 委托 validate | W9_APP_CONSUMED / operator |
| T07a operator-ceremony carrier | 六段 envelope + synthetic triple | T07b / operator-pass |
| `define-demo-golden-run-and-voice` | 历史字段清单 | 直接 apply / C6 绑定 |

## Proof Class Matrix（硬）

| Class | 可证明什么 | 不可证明什么 |
|---|---|---|
| `unit` | reducer/validator/adapter/bridge/gate + deliberate-red；Core 构造带 per-turn provider 的 route | customer path / operator；App 类型实例化；W9 App consumed |
| `source_contract` | 读 App 源文本断言注入点 / TTS call site | runtime 行为 |
| `build` | 目标编译 | 语义正确 / 现场可演 |
| `runtime_local` | 本机 mock + 非 nil composition 一次跑通（resource window 后） | operator-pass / 真车 |
| `runtime_local_preflight` | TTS preflight 脚本本机 voice lookup PASS/FAIL | operator / mobile / true-device |
| `fixture_local` | golden/reliability/T07a schema join 本地 | T07b / V-PASS |
| `operator` | （本 change **不交付**） | — |

## S0/S1 诚实证明计划（硬）

1. **Core unit**：`ProductionRouteCorrelationProvider` factory 用冻结四元组构造 per-turn provider；`DemoSliceRoute.route(text:correlationProvider:)` / `DemoRuntimeSessionRunner.run(text:correlationProvider:)` 生产面非 optional。
2. **App source-contract**：`FrontstageRuntimeComposition.routeDemoSlice` 从 `FrontstageVoiceTurn`（`turnID`/`sessionID`/`sequence`）与 `ensureActive` 返回 generation 组装 provider，再调 per-call route。
3. **`runtime_local`**：单独 resource-window；S8 active 时 deferred。
4. **禁止 claim**：`SPM unit tests instantiate App types`。

## Claim Cap（收口措辞）

允许：`OPENSPEC_PROPOSED`；apply 后 `LOCAL_COMPOSITION_WIRED` / `FIXTURE_LOCAL_PASS` / `UNIT_DELIBERATE_RED_PASS` / `SOURCE_CONTRACT_PASS` / `BRIDGE_UNIT_PASS` / `FORCE_DIGEST_GATE_UNIT_PASS` / `TTS_PREFLIGHT_PASS`（证据齐时）。

允许 lane：**PARTIAL**（product lifecycle App wiring deferred + W9 App force-catalog consumption deferred）。

禁止：customer path DONE · operator-pass · T07b · V-PASS · C5 V-PASS · C6 acceptance · W4 DONE · V1 RATIFIED · actionDemoProven 手翻 · 旧 golden 整包 apply · T07a carrier fork · **W9_APP_CONSUMED** · product cancel/recovery DONE · 假 DONE 掩盖 deferred。

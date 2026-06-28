---
status: PASS_WITH_NOTES
artifact_kind: phase1_consumer_grill_receipt
date: 2026-06-28
label: MA-P1-UIUE-PRESENTATION-CONSUMER-GRILL-APPLY-20260628
repo: /Users/wanglei/workspace/MAformac-uiue
branch: uiue/phase4-default-scope-presentation
start_head: b43a329f51e5fb5e8dc3e92d318b50e9ffeca02c
mainline_unblock_commit: 9ba609a13fdf311546f20561081c4a9bb858d0fc
readiness_status: R5_PRECONDITIONS_READY_WITH_NOTES
proof_class: docs/local
verdict_scope: consumer_mapping_and_lane_classification_only
non_claims:
  - no runtime-ready
  - no mobile
  - no true_device
  - no voice-ready
  - no model-ready
  - no golden-ready
  - no endpoint-ready
  - no UIUE merge
  - no V-PASS
  - no S-PASS
  - no U-PASS
---

# UIUE R5 Phase1 Consumer Grill

## 结论

`PASS_WITH_NOTES`。

UIUE R5 可以从 **Presentation Consumer Line** 起步，但本轮只允许消费 mainline `define-runtime-presentation-bridge` 已锁的语义类别和 proof-class 边界，不能在 UIUE 自行增发 shared field。当前安全落点是文档级 mapping、已有 local/mock matrix 复核、fixtures 或单测补强；不进入 runtime、voice、model、golden、mobile、true_device 或 UIUE merge。

## 本轮核验真态

- UIUE repo: `/Users/wanglei/workspace/MAformac-uiue`
- branch: `uiue/phase4-default-scope-presentation`
- start HEAD: `b43a329f51e5fb5e8dc3e92d318b50e9ffeca02c`
- dirty status before edit: clean
- readiness: `docs/handoffs/2026-06-28-uiue-r5-readiness-from-r4-closeout.md` 已是 `R5_PRECONDITIONS_READY_WITH_NOTES`
- mainline authority: `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/`

## Consumer Mapping Matrix

| Mainline bridge vocabulary | UIUE current consumer surface | Current safe use | Waits for mainline Phase1 field/type verdict |
|---|---|---|---|
| accepted action | `DemoRuntimeResultKind.acceptedToolCall` -> `DemoVisualState.satisfied` / `PresentationMotionKind.stateCommit` | local/mock result-to-card/orb/readback mapping | exact runtime payload shape and adapter input type |
| clarify / missing slot | `clarifyMissingSlot` -> `blocked_with_alternative` / clarification copy | display clarify without Core `ScopeOrigin.missing` | missing-slot metadata field name and slot typing |
| unsupported / no tool | `refusalNoAvailableTool` -> `blocked_hard` | keep distinct from safety refusal | rejection-class field naming if mainline splits subreasons |
| safety / policy refusal | `refusalSafetyOrPolicy` -> `unsafe` | card refusal and refused-cell reason display | guard/reason taxonomy source and key-path payload |
| already-state no-op | `alreadyStateNoop` -> `satisfied` / steady acknowledge | render as completed/no mutation, not unsupported | final readback wording source and state-noop trace contract |
| runtime error | `runtimeError` -> `unknown` | local/mock terminal failure presentation | timeout/error enum, retry metadata and terminal snapshot schema |
| cancelled / interrupted | `cancelled` -> `normal` / cancellation fade | terminal cancellation display only | interrupted vs user-cancel split if mainline separates them |
| partial accept / partial refuse | `partialAcceptPartialRefuse` -> `blocked_with_alternative` / partial result | local mixed-outcome display pressure | exact per-cell accepted/refused list and readback composition |
| proof class | `PresentationProofClass.localMock/staticPreview/simulatorMock/operatorReview` | cap copy; no runtime/mobile/V-PASS claims | canonical cross-repo finite enum values |
| scope origin | `scopeOrigins: [String: ScopeOrigin]` with `.defaulted/.explicit/.fanout` | display known scope source; unresolved scope via metadata/copy | explicit missing/unresolved metadata field, not Core enum |

Evidence:

- `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/design.md:16` says UIUE consumes mapped presentation semantics, not raw runtime stores.
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/design.md:22` keeps Core `ScopeOrigin` limited to `defaulted/explicit/fanout`.
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md:39` requires machine-readable runtime result classes.
- `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/PresentationSnapshot.swift:3` already carries eight local result kinds.
- `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/DemoRuntimeResultPresentationMatrix.swift:28` maps each local result kind without a default fallback.

## Grill Questions

### 1. UIUE 现在能消费什么，什么必须等 mainline Phase1？

- decision: 现在只能消费 carrier 已锁的语义类、proof-class ceiling、scope-origin 边界、readback/snapshot 概念；shared field 的精确 Swift/API 命名和 adapter shape 必须等 mainline Phase1。
- evidence paths: mainline `design.md:12-18`, `spec.md:64-79`; UIUE `PresentationSnapshot.swift:59-72`.
- tiger: 把 UIUE 现有 `DemoRuntimeResultKind` 当成 mainline shared enum，后续 Phase1 命名不同会制造第二 SSOT。
- paper-tiger: “不等字段就什么都不能做”不成立；local/mock matrix 和 fixture 可以先锁消费意图。
- elephant: mainline carrier 是 docs/local + OpenSpec proof，不是 runtime payload sample；缺 adapter sample 时不得写 runtime binding。
- stop condition: 任何 code change 需要新增 shared field 名、解析 mainline runtime payload、或宣称 runtime proof，立即停。

### 2. bridge result classes 如何映射到 UIUE states/orb/card/readback？

- decision: 成功、clarify、unsupported、safety、already-state、runtime error、cancelled、partial mixed outcome 均走 `DemoRuntimeResultPresentationMatrix`；orb/readback 只做 presentation local/mock，不证明后端。
- evidence paths: UIUE `DemoRuntimeResultPresentationMatrix.swift:28-102`, `DemoRuntimeResultPresentationMatrixTests.swift:22-39`; mainline `design.md:24-36`.
- tiger: 把 unsupported 和 safety 合并成一个红色 rejection，会违背 Q35/U10 四态分开。
- paper-tiger: already-state 显示为 satisfied 并非假绿；它是独立 no-op 结果，不是 action success 混写。
- elephant: partial accept/refuse 现在只有单 entry，没有 per-cell accepted/refused payload；复杂 mixed outcome 还缺字段。
- stop condition: 如果要渲染 per-cell partial outcome，必须等 mainline Phase1 或先用 UIUE-only fixture 标 `local_mock_only`。

### 3. 缺失/unresolved scope 怎么显示而不发明 Core `ScopeOrigin.missing`？

- decision: Core `ScopeOrigin` 只保留 `.defaulted/.explicit/.fanout`；缺失或未解析 scope 用 result metadata、presentation metadata、failure reason 或 UI-only copy 显示。
- evidence paths: mainline `design.md:20-22`, `spec.md:21-37`; UIUE checklist `docs/grill-tournament/uiue-r4-human-review-checklist-before-r5-2026-06-28.md`.
- tiger: 直接加 `ScopeOrigin.missing` 会违反 HR-02 和 mainline carrier。
- paper-tiger: UI-only “需要确认位置”标签不是 Core enum，只要不流入 shared contract 就可用。
- elephant: 缺失 slot 的机器可读字段尚未定；UIUE 不能提前锁 `missing_slot` / `scope_missing` 等 shared 字段名。
- stop condition: 任何 diff 出现 `ScopeOrigin.missing` 或等价 Core enum 扩展，停。

### 4. 最小安全 runtime-driven orb binding slice 是什么？

- decision: 只允许 local/mock/fixture：给 `PresentationSnapshot.orbState` 与 `DemoRuntimeResultKind` 准备 deterministic preset 或 test；不接 ASR/LLM/router/runtime。
- evidence paths: UIUE `PresentationSnapshot.swift:21-33`, `ContentView.swift:40-47`, `openspec/changes/ui-presentation/specs/ui-presentation/spec.md:206-214`.
- tiger: 名字写 runtime-driven，实际却把 simulator/mock 说成 runtime acceptance。
- paper-tiger: 使用 `localMock` 或 `simulatorMock` proof class 的 orb preset 是安全的，因为它明确不越 proof class。
- elephant: 真 runtime 需要 terminal snapshot、timeout/cancel、main-thread boundary 和 adapter logs；当前无 proof。
- stop condition: 需要读取真实 runtime stores、trace arrays、model output 或 training receipts 时停。

### 5. `think` presentation 如何保持事件驱动而不是固定计时 theatre？

- decision: `think` 只能绑定事件：listen -> think analyzing -> cardsDidStartChanging / terminal snapshot -> speak/readback；最小 guard 可用于防瞬切，但不得写成固定 3 秒脚本。
- evidence paths: mainline `grill-decisions-master.md` E2/E3/E4/E8; UIUE residual disposition “复杂推理 -> think”。
- tiger: 把 `think` 写成固定 timer，客户一看就像 theatre，且 GLM 已多次滑回这个 frame。
- paper-tiger: 最小 1s guard 不是固定 theatre；它是体验防抖，不是状态真源。
- elephant: `cardsDidStartChanging` 或等价 event 在 mainline Phase1 前未形成可消费 shared event。
- stop condition: 若实现需要新建 `cardsDidStartChanging` shared event 名，先停等 mainline Phase1。

### 6. direct-touch / long-press / summary / gear 哪些是 Phase1 blocker？

- decision: 都不是 Phase1 consumer grill 的 overall blocker；它们是后续 product/interaction lanes。summary/gear direct touch 必须先拍 policy，long-press console 默认 later lane。
- evidence paths: `docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md`, exit ledger pending human review rows.
- tiger: 直接把 gear/summary 做成可控件会重演 fake affordance 问题。
- paper-tiger: 保持只读不是“不做交互”；点卡高亮、tooltip 和 readback 仍可保“不是死图”。
- elephant: direct touch policy 会影响 safety/disabled affordance 和 readback authoring，不能被一个 UI tweak 顺手决定。
- stop condition: 触碰 `vehicle.gear` direct control、summary 写回、或长按 console release behavior 时停。

### 7. 哪些必须保持 pending？

- decision: 44pt/VoiceOver、mobile/true_device、voice、model/golden、white-edge formal threshold、capsule final-art 全部 pending；它们不阻塞 Phase1 consumer docs/mapping，但不能被本轮关闭。
- evidence paths: residual disposition table; handoff non-claims; Q41 validation separation.
- tiger: L0 simulator screenshot 或 local matrix 被写成 mobile/a11y/V-PASS。
- paper-tiger: pending 不等于 blocker；它只是 proof lane 未启动。
- elephant: white-edge/capsule 是视觉审美和 threshold 问题，局部截图 checker 无法替代人审。
- stop condition: 任何 closeout 文案含 mobile/true_device/voice/model/golden/V-PASS/S-PASS/U-PASS claim，停。

### 8. docs-only 与 Swift/UI touched 的 validation 分界是什么？

- decision: docs-only 足够跑 `openspec validate ui-presentation --strict`、`git diff --check`、stale wording grep；如果触 Swift/UI，至少跑相关 `swift test --filter ...`，再视 touched surface 加 UI/simulator smoke。
- evidence paths:派单 validation；UIUE tasks proof-class discipline；existing matrix tests.
- tiger: 文档改动后不跑 OpenSpec，导致 route board 和 active change 漂移。
- paper-tiger: docs-only 不需要整套 simulator L0-L3；那会把本轮范围误扩大。
- elephant: 若改了 `ContentView` 或 snapshot UI，focused unit 仍不够，需要至少 local UI/simulator smoke 或明确 gap。
- stop condition: 触 Swift/UI 但没有 targeted tests 或明确 validation gap，不能 claim done。

### 9. UIUE 需要 mainline Phase1 给什么，才能实现 shared-field consumption？

- decision: 需要 mainline 给字段/type verdict：runtime result enum canonical names、terminal snapshot schema、scope unresolved metadata shape、proof-class enum、readback payload、orb/voice event lifecycle、partial outcome accepted/refused cell structure、timeout/cancel semantics。
- evidence paths: mainline `spec.md:39-97`, `design.md:42-44`; UIUE `PresentationSnapshot.swift:59-72`.
- tiger: UIUE 先写 adapter，然后 mainline 改字段，造成双树 migration 债。
- paper-tiger: 本轮本地 matrix 不依赖 adapter，因此不需要等待 mainline 才能完成 docs/local pressure.
- elephant: 真 runtime proof 还需要 logs/fixtures/terminal snapshots，不只是 type definitions。
- stop condition: mainline Phase1 未给 field/type verdict 前，不实现 shared adapter。

## Lane Classification

| Lane | Phase1 status | Safe next slice | Waits for |
|---|---|---|---|
| runtime-driven orb binding | startable with notes | local/mock fixture binding to `PresentationSnapshot.orbState` | mainline terminal snapshot/event type |
| complex reasoning -> `think` | startable with notes | event-driven presentation plan or local fixture | mainline macro/event verdict, not fixed timer |
| long-press 1.5s console | later lane | product policy note only | human/product decision and release isolation |
| summary direct touch | later lane | policy matrix only | direct-control policy |
| gear direct touch | later lane | keep display-only unless separately approved | safety/disabled affordance policy |
| 44pt/VoiceOver/mobile/true_device | later proof lane | no implementation in this slice | true device and a11y proof plan |
| voice/model/golden | later proof lane | non-claim only | separate voice/model/golden changes |
| white-edge/capsule final-art | visual polish lane | keep WARN / notes | human visual threshold and asset lane |

## Final Verdict

No unresolved P0/P1 blocker prevents **docs/local Phase1 consumer mapping** from proceeding. A P0/P1 blocker remains for **shared-field runtime adapter implementation** until mainline Phase1 supplies field/type verdict and sample terminal snapshots.

Therefore this receipt authorizes no broad R5 code work. It classifies the safe next step as docs/local mapping and optional existing-local-type tests only.

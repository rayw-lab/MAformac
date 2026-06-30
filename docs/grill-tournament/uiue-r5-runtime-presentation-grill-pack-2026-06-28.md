---
status: CANDIDATE_GRILL_PACK_READY
artifact_kind: r5_runtime_presentation_candidate_grill_pack
date: 2026-06-28
repo: /Users/wanglei/workspace/MAformac-uiue
branch: uiue/phase4-default-scope-presentation
uiue_head_at_authoring: 70128d8c845d5c5348f56120de3a25740e73deb7
mainline_repo: /Users/wanglei/workspace/MAformac
mainline_head_at_authoring: 0a2ff0f7d30d6caf2d48f018f6b874828fb70c03
authority: candidate_decision_input_not_ssot
proof_class: docs/local + subagent_readonly + controller_teardown
non_claims: [no runtime-ready, no mobile, no true_device, no voice-ready, no model-ready, no golden-ready, no endpoint-ready, no UIUE merge, no V-PASS, no S-PASS, no U-PASS]
---

# UIUE R5 Runtime-Presentation Grill Pack - 2026-06-28

## Verdict

`CANDIDATE_GRILL_PACK_READY`

这份文件是 R5 前的候选 grill pack, 不是已拍板 SSOT, 也不是实现授权。它把旧 `RPB-01~53`、controller 亲自扩散的 82 条、四个只读 subagent 的 80 条全部纳入同一个矩阵, 总计 215 条。

主线 authority 是 `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/` 和 mainline Phase1 typed DTO。UIUE 文档只作 consumer/provenance 输入, 不作 mainline/runtime/mobile proof。

本清单按之前 grill 范式阅读: 每一行都是必须被回答的“问题”, 不是普通 backlog。绑定字段是:

`ID | 问题 | 为什么必须问 | 默认建议 / 决策候选 | 验证方式 | Owner / 顺序 | P | 来源`

下面 A-F 保留 215 条不压缩。若某个来源块沿用 source-native 列名, 按这个映射解释:

- `Grill point` = `问题`
- `R5 revision action` / `Contract question` / `UIUE question` / `Validation question` = `默认建议 / 决策候选`
- `Iceberg class` / `Source` / `Why it matters` = `为什么必须问`
- `Owner/order` = `Owner / 顺序`
- `Evidence` = `来源`
- `Validation` = 关闭该问题前必须能复跑或人工确认的最小证据

禁止用 “looks fine” 关闭条目。每条关闭时必须写明: 决策文本、proof class、验证命令或人审门、权威 repo/branch/commit。

## Inputs

- Old RPB-53 baseline: `/Users/wanglei/workspace/MAformac-uiue/docs/grill-checklist/uiue-runtime-bridge-decisions-2026-06-25.md`
- Mainline Phase0 unblock: `/Users/wanglei/workspace/MAformac/docs/project/phase0/mainline-runtime-presentation-bridge-unblock-2026-06-28.md`
- Mainline Phase1 grill: `/Users/wanglei/workspace/MAformac/docs/project/phase0/runtime-presentation-bridge-phase1-grill-2026-06-28.md`
- Mainline bridge spec: `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`
- Mainline DTO: `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift`
- UIUE Phase1 consumer grill: `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r5-phase1-consumer-grill-2026-06-28.md`
- UIUE local snapshot/matrix: `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/PresentationSnapshot.swift`, `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/DemoRuntimeResultPresentationMatrix.swift`
- Runtime research: `/Users/wanglei/workspace/MAformac/docs/research/2026-06-19-home-llm-teardown.md`, `/Users/wanglei/workspace/MAformac/docs/research/2026-06-20-c3-home-llm-adopt-spike.md`
- Voice/memory research: `/Users/wanglei/workspace/MAformac/docs/voice-pre-mortem-2026-06-18.md`, `/Users/wanglei/workspace/MAformac/docs/research/2026-06-20-voice-short-term-memory-oracle.md`
- UI runtime handshake research: `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-26-ios-frontend-interaction-runtime-synthesis.md`

## Count Ledger

| Source | Prefix | Count | Role |
|---|---:|---:|---|
| Historical RPB baseline | RPB-01~RPB-53 | 53 | 旧 53 全量保留并加 R5 revision 动作 |
| Controller iceberg expansion | CE-001~CE-082 | 82 | controller 基于 bug-iceberg-teardown 全局扩散 |
| Subagent mainline contract | MC-001~MC-018 | 18 | mainline Runtime DTO / 状态机细节 |
| Subagent UIUE consumer | UC-001~UC-022 | 22 | UIUE consumer / 交互 / a11y / proof |
| Subagent process forecast | PV-001~PV-022 | 22 | 流程闭环 / 验证 / false-green 预言 |
| Subagent model/voice/golden | MVG-001~MVG-018 | 18 | C5/C6/model/golden/voice 验收闭环 |
| Total |  | 215 | 候选 grill 点总数 |

## Grill Closure Contract

| Closure status | Meaning | Allowed next step |
|---|---|---|
| `accept_mainline_first` | 共享合同、DTO、runtime adapter 或 proof vocabulary 先由主线锁定。 | 主线写 spec/code/test/sample; UIUE 只在 commit 后消费。 |
| `accept_uiue_first` | UIUE 可以在不发明共享字段的前提下先做 local/mock/simulator consumer proof。 | UIUE 写 docs/fixture/test/visual proof; proof cap 保持 local/mock/simulator。 |
| `accept_parallel_with_guard` | 字段已锁, 双线可并行, 但 closeout 前必须做 field/proof reconciliation。 | mainline/UIUE 并行推进, commander 串行收口。 |
| `defer_human_review` | 需要产品审美、交互或可访问性人审, 不应先写成代码真理。 | 放入 human review checklist, 记录 accepted/rejected wording。 |
| `defer_later_lane` | 依赖 voice/model/golden/mobile/endpoint/true-device 等后续 lane。 | 作为 gated lane 保留, 不阻塞 R5 dispatch, 也不能被 R5 冒领。 |
| `reject_or_merge_duplicate` | 被更强条目覆盖, 或 mainline `0a2ff0f` 后已过时。 | 写 replacement row, 不再单独派单。 |

具体验证方式必须落到命令或 gate, 例如:

- mainline: `openspec validate define-runtime-presentation-bridge --strict`, `openspec validate --all --strict`, `swift test --filter RuntimePresentationBridgeTests`, terminal snapshot receipt。
- UIUE: `openspec validate ui-presentation --strict`, UIUE presentation matrix tests, selected simulator UI tests, proof-class fail-closed tests。
- shared/process: `git diff --check`, stale wording grep, receipt schema check, ignored artifact manifest, human review checklist。

## Dispatch-Facing Grill Slice Map

这个表不是压缩替代 A-F, 而是派单入口。A-F 仍是逐条问题清单。

| Slice | Rows | 为什么必须问 | 默认路线 | 关闭证据 |
|---|---|---|---|---|
| G1 mainline DTO authority | `RPB-05`, `RPB-08`, `RPB-10`, `RPB-13`, `RPB-14`, `RPB-16`, `RPB-18`, `RPB-22`, `RPB-23`, `RPB-24`, `RPB-26`, `RPB-27`, `RPB-29`, `RPB-30`, `RPB-32`, `RPB-33`, `RPB-38`, `RPB-39`, `RPB-51`, `RPB-52`, `MC-001`-`MC-018`, `PV-001`, `PV-002`, `PV-011`, `PV-012`, `PV-015` | 防止 UIUE 发明共享 runtime 字段或把 local schema 当主线合同。 | `accept_mainline_first` | OpenSpec + Swift DTO tests + terminal snapshot samples。 |
| G2 UIUE consumer mapping | `RPB-01`-`RPB-04`, `RPB-06`, `RPB-07`, `RPB-09`, `RPB-11`, `RPB-12`, `RPB-15`, `RPB-17`, `RPB-19`-`RPB-21`, `RPB-25`, `RPB-28`, `RPB-31`, `RPB-34`-`RPB-37`, `RPB-40`-`RPB-50`, `RPB-53`, `UC-001`-`UC-022` | 把主线 DTO 投影成 UIUE 视觉/a11y/motion/readback, 但 proof 不越级。 | `accept_uiue_first` after contract rows | Matrix tests + simulator/mock receipts + proof cap grep。 |
| G3 end-to-end runtime bridge | `CE-001`-`CE-022`, `CE-025`, `CE-026`, `CE-031`, `CE-032`, `CE-036`, `CE-043`, `CE-044`, `CE-046`, `CE-048`, `CE-052`, `CE-061`-`CE-064`, `CE-069`, `CE-070`, `CE-072`, `PV-003`-`PV-005`, `PV-013`, `PV-014`, `MVG-016`, `MVG-018` | 防止只做 typed shape, 没有真实 terminal/order/cancel/replay 行为。 | `accept_mainline_first` then UIUE consumption | Adapter tests + terminal snapshots + stale async/cancel tests。 |
| G4 proof and claim governance | `CE-023`, `CE-024`, `CE-029`, `CE-030`, `CE-037`-`CE-042`, `CE-045`, `CE-047`, `CE-049`-`CE-060`, `CE-065`-`CE-068`, `CE-071`, `CE-073`-`CE-082`, `PV-017`, `PV-019`-`PV-022` | 防止 docs/local/mock 被写成 runtime/mobile/V-PASS, 也防止 dirty tree 和 receipt 漏洞。 | `accept_parallel_with_guard` | Receipt schema, stale wording grep, proof ladder, commit hygiene audit。 |
| G5 voice/model/golden/future lanes | `MVG-001`-`MVG-015`, `MVG-017`, plus related voice/model/golden rows from G3/G4 | 防止把 voice/model/golden readiness 偷渡进 R5 dispatch。 | `defer_later_lane` unless promoted | Golden precheck, model runtime receipts, voice lifecycle receipts, live proof only when actually run。 |
| G6 product/human review | HR-style rows around long-press console, summary/gear direct touch, capsule final art, white-edge threshold, mobile/a11y taste gates, related `UC`/`CE` rows | 防止产品审美/交互判断被代码先行锁死。 | `defer_human_review` | Human review checklist with accepted/rejected wording。 |

## Owner Vocabulary

- `mainline`: 主线先拍或先实现合同/DTO/runtime adapter。
- `UIUE`: UIUE 可以先做 consumer/visual/local/mock/proof-cap 事项。
- `main_first_uiue_after`: 主线先给字段/样本/合同, UIUE 后消费。
- `uiue_first_main_after`: UIUE 可先给 local/prototype/fixture 压力样本, 主线后吸收或拒绝。
- `shared`: 必须双方共同承认或至少在 bridge carrier 中映射。

## A. Historical RPB-53 Revision Ledger

| ID | Grill point | Owner/order | Priority | R5 revision action | Source |
|---|---|---|---|---|---|
| RPB-01 | 边界 override 只能是 snapshot consume + bridge event write, 不能自由 mutate store。 | shared | P0 | Keep, 作为 UIUE/mainline 边界红线。 | old RPB |
| RPB-02 | 三车道分类: UIUE local, shared bridge, mainline runtime。 | shared | P0 | Keep, 后续所有 R5 row 必填 owner/order。 | old RPB |
| RPB-03 | bridge 4 名和字段名必须由 mainline carrier/DTO 锁定。 | mainline | P0 | Modify, 旧提议名降级, 当前以 mainline Phase1 DTO 为准。 | old RPB + Phase1 |
| RPB-04 | store ownership: presentation 消费 snapshot, 不读 raw runtime store。 | shared | P0 | Keep, UIUE local mock 需标 proof_class。 | old RPB |
| RPB-05 | 写所有权: 触摸/事件走 executor 或 runtime adapter, 不直接写 store。 | main_first_uiue_after | P0 | Keep, direct touch lane 前置。 | old RPB |
| RPB-06 | 事件集必须封闭, 包含 text/mic/card/cancel/interruption/timeout 等。 | mainline | P0 | Modify, 当前 mainline 事件 enum 仍缺 timeout/force/context/gates。 | old RPB + DTO |
| RPB-07 | 事件 payload 必须区分 source/provenance 与 scope_origin/resolution。 | shared | P0 | Modify, mainline DTO 当前 payload 很薄, 需 field verdict。 | old RPB |
| RPB-08 | scope 展示读结构化字段, UI/TTS 禁从中文推断 scope。 | shared | P0 | Modify, 废弃 Core `ScopeOrigin.missing`; unresolved 走 metadata/reason。 | old RPB + HR-02 |
| RPB-09 | Runtime result enum 保持机器可读, 不用裸 rejected。 | mainline | P0 | Modify, mainline 当前无 `partial_accept_partial_refuse`, UIUE 有本地值。 | old RPB + DTO |
| RPB-10 | 拒识词表要区分 unsupported/safety/clarify/already-state/runtime-error。 | mainline | P0 | Keep, 后续 adapter 分类必须物理化。 | old RPB |
| RPB-11 | 视觉映射为结果到 7 态的派生, 不是 runtime 结果本身。 | shared | P1 | Keep, 补 a11y/readback 同态区分。 | old RPB |
| RPB-12 | guard denial 必须投影成 presentation-safe refusal snapshot。 | mainline | P0 | Keep, 仍是 runtime adapter hard gate。 | old RPB |
| RPB-13 | unsafe R2 展示 active/refused cell 和 safety reason, 不暴露速度等敏感内情。 | shared | P1 | Keep, 等 schema 决定 refused cell 结构。 | old RPB |
| RPB-14 | already_state_noop 独立结果, 视觉可 satisfied 但语义非 accepted delta。 | shared | P0 | Keep, 新增 no revision bump / readback / eval 规则。 | old RPB |
| RPB-15 | clamp 成功路径要说实际 clamp 值, trace 标 clamped。 | mainline | P1 | Keep, 等 adapter/readback 样本。 | old RPB |
| RPB-16 | 真 multi-intent splitter deferred, Phase4/5 只可 sequencer/force-state。 | mainline | P1 | Keep deferred, 不把 UIUE sequence 当 NLU splitter proof。 | old RPB |
| RPB-17 | partial deny 需要综合 snapshot, 逐 cell 混态与综合 readback。 | main_first_uiue_after | P0 | Modify, mainline DTO 当前缺 partial canonical/payload。 | old RPB |
| RPB-18 | SceneMacroRegistry 属 Core config, 非 UIUE-only 隐藏 planner。 | mainline | P0 | Keep, 加 `planned_not_golden` 和 upgrade gate。 | old RPB |
| RPB-19 | 环境上下文是 runtime context, 非车控卡, 但可显示事实。 | shared | P1 | Keep, 补 a11y 和 provenance。 | old RPB |
| RPB-20 | reset preset 清 vehicle/dialogue/trace/orb/voice/context。 | shared | P1 | Keep, 后续需 sample terminal snapshot。 | old RPB |
| RPB-21 | think 应事件驱动, 不写固定计时剧场。 | shared | P0 | Modify, 拆 thinkAnalyzing 与 safetyThink 固定演出例外。 | old RPB |
| RPB-22 | cancel/interruption/timeout/backgrounding 必须有终态 snapshot。 | shared | P0 | Keep, 新增 stale async mutation 测试。 | old RPB |
| RPB-23 | ASR/TTS 边界: backend 接 text, voice-ready 需真机 ASR/TTS proof。 | main_first_uiue_after | P0 | Keep deferred, UIUE voiceState 不能升格。 | old RPB |
| RPB-24 | TraceEnvelope 最小字段和 redaction 需要锁。 | mainline | P0 | Modify, 当前 DTO 有 entries 但顺序/identity/timestamp 未锁。 | old RPB |
| RPB-25 | proof class 上限: UIUE screenshot/simulator 不能变 runtime/mobile/V-PASS。 | shared | P0 | Keep, 补 mainline/UIUE proof enum crosswalk。 | old RPB |
| RPB-26 | 现态推理/感受词走 C3 相对 EXP 或 later LoRA, 不在 UIUE 自建。 | mainline | P1 | Keep, 后续 model lane 分开。 | old RPB |
| RPB-27 | normalize/range/EXP 复用 C3, UIUE 不重复相对调温逻辑。 | main_first_uiue_after | P1 | Keep, 等 shared adapter。 | old RPB |
| RPB-28 | range 源来自 StateCellContractLookup 或同等 SSOT。 | shared | P1 | Keep, 补 migration/key stability。 | old RPB |
| RPB-29 | active cell 优先级需定义, refused 可压过 satisfied。 | shared | P0 | Modify, mainline DTO 当前缺 active priority/order。 | old RPB |
| RPB-30 | snapshot card schema 要带 scope/reason/active/sibling 等呈现所需语义。 | main_first_uiue_after | P0 | Modify, mainline 当前 `[DemoVehicleStateCell]` 不足。 | old RPB |
| RPB-31 | family 覆盖 10 族 + context, 天气/时段不是第 11 族车控卡。 | shared | P1 | Keep, 等 state-cell/card-map 对齐。 | old RPB |
| RPB-32 | dialogue ownership 分 runtime readback、assistant copy、presentation styling。 | shared | P0 | Modify, 需 dialogText/readbacks/matrix copy priority。 | old RPB |
| RPB-33 | orb 状态来源是 composite, 非视觉自嗨。 | shared | P1 | Modify, voiceState/orbState 冲突裁决未锁。 | old RPB |
| RPB-34 | Reduce Motion 必须有非动画通道。 | UIUE | P1 | Keep, 补 UI proof fixture 和 a11y copy。 | old RPB |
| RPB-35 | Mac/iOS bridge 字段一致, layout 差异 layout-only。 | shared | P1 | Keep, 等 adapter contract。 | old RPB |
| RPB-36 | 模拟器不等于真机, 质感/音频/性能/热须 true-device lane。 | shared | P0 | Keep deferred, 不阻塞 docs/local 但阻塞 true-device claim。 | old RPB |
| RPB-37 | 离线 bundle, 无网无 Python, Python 只可 dev spike。 | mainline | P0 | Keep, 加 constrained decode proof 分层。 | old RPB |
| RPB-38 | persistence 仅 DialogueState 短时, 不做 cloud/long memory。 | mainline | P1 | Modify, voice memory commit/TTL 需进 C4/C7。 | old RPB |
| RPB-39 | crash/unknown 不可用于正常 unsupported/refusal。 | shared | P1 | Keep, 补 runtimeError subtype。 | old RPB |
| RPB-40 | settings/reset 中 theme 是 presentation-only, force/reset 是 runtime input。 | shared | P1 | Keep, force_context 需 bridge event。 | old RPB |
| RPB-41 | UIUE scripted runs 可作 future golden candidate, 非 golden proof。 | mainline | P0 | Keep deferred, 加 golden mounted/readback/revision precheck。 | old RPB |
| RPB-42 | UIUE 视觉绝不选模型候选, candidate comparison 是 later mainline。 | mainline | P0 | Keep deferred。 | old RPB |
| RPB-43 | UIUE 文案/case 不能直接进入训练数据。 | mainline | P0 | Keep, 加 split/leakage data contract。 | old RPB |
| RPB-44 | Accessibility deferred 但不能消失, 双通道只覆盖一部分。 | UIUE | P1 | Keep deferred, 补 proof ladder。 | old RPB |
| RPB-45 | screenshot anchor 命名含 platform/state/proof/source。 | UIUE | P2 | Keep, 加 anchor no-promotion guard。 | old RPB |
| RPB-46 | receipt 格式需 command/device/proof/touched/residual。 | shared | P1 | Keep, R5 lane 逐条继承。 | old RPB |
| RPB-47 | merge-readiness 标记只能是 contract aligned not merged。 | shared | P0 | Keep, 不声明 UIUE merge。 | old RPB |
| RPB-48 | reviewer 必告 live HEAD, no stale SHA。 | shared | P1 | Keep, 双 repo closeout hard gate。 | old RPB |
| RPB-49 | 未决 P0/P1 carry-forward 必进下个 closeout。 | shared | P1 | Keep, 本 pack 即 carry-forward expansion。 | old RPB |
| RPB-50 | 哪些落 bridge OpenSpec, 哪些留 UIUE notes 需 landing matrix。 | shared | P0 | Keep, 本 pack 后续需拍 landing。 | old RPB |
| RPB-51 | snapshot card 必带 sibling/secondary/active 信息以支持制冷/制热与主值。 | main_first_uiue_after | P0 | Modify, mainline DTO 尚未满足。 | old RPB |
| RPB-52 | force-state context 输入需 `#if DEMO_MODE` + bridge event + trace provenance。 | shared | P0 | Keep, 当前 mainline event enum 未覆盖。 | old RPB |
| RPB-53 | think 两语义: analyzing 事件驱动与 safety fixed 1s 演出例外。 | shared | P1 | Keep, 需类型化或 lifecycle 化。 | old RPB |

## B. Controller Iceberg Expansion CE-001~CE-082

| ID | Grill point | Owner/order | Priority | Iceberg class | Evidence |
|---|---|---|---|---|---|
| CE-001 | `ToolExecutionError` 到 `DemoRuntimeOutcome` 的完整映射表。 | mainline | P0 | contract drift | C3 pipeline + Phase1 notes |
| CE-002 | `guardDenied` 应细分 safety/refusal/unsupported/runtime_error。 | mainline | P0 | runtime/state | C3 pipeline |
| CE-003 | `semanticInvalid("missing_default_scope")` 应映射 clarify/missing scope, 不进 Core enum。 | mainline | P0 | contract drift | ScopeOrigin + HR-02 |
| CE-004 | unsupported 与 safety refusal 必须有不同 reason taxonomy。 | mainline | P0 | product proof | bridge spec |
| CE-005 | runtimeError 需分 timeout/decode/store/model/adapter failure。 | mainline | P1 | observability | bridge spec |
| CE-006 | cancellation 与 interruption 的触发源和恢复语义分开。 | shared | P0 | state machine | DTO event/result |
| CE-007 | adapter 遇 throw 仍必须发 terminal snapshot, 禁 silent failure。 | mainline | P0 | verification gap | Phase1 notes |
| CE-008 | retry/idempotency 规则: 重试不得二次写 state 或吞掉 no-op。 | mainline | P1 | runtime/state | home-llm + C3 |
| CE-009 | snapshot 禁 raw model output, 只带 presentation-safe outcome。 | mainline | P0 | privacy/proof | bridge spec |
| CE-010 | `behaviorClassSource` preservation: accepted 结果保留 `tool_call` 源。 | shared | P0 | provenance | DTO tests |
| CE-011 | accepted terminal snapshot sample 必须存在。 | mainline | P0 | fixture gap | UIUE blocker |
| CE-012 | clarify/missing-slot terminal snapshot sample 必须存在。 | mainline | P0 | fixture gap | UIUE blocker |
| CE-013 | unsupported/no-tool terminal snapshot sample 必须存在。 | mainline | P0 | fixture gap | UIUE blocker |
| CE-014 | safety refusal terminal snapshot sample 必须存在。 | mainline | P0 | fixture gap | UIUE blocker |
| CE-015 | already-state terminal snapshot sample 必须存在。 | mainline | P0 | fixture gap | RPB-14 |
| CE-016 | timeout runtimeError terminal snapshot sample 必须存在。 | mainline | P0 | fixture gap | bridge spec |
| CE-017 | cancelled terminal snapshot sample 必须存在。 | mainline | P0 | fixture gap | RPB-22 |
| CE-018 | interrupted/barge-in terminal snapshot sample 必须存在。 | mainline | P0 | fixture gap | RPB-22 |
| CE-019 | partial accept/refuse terminal snapshot sample 必须存在或明确 local-only。 | main_first_uiue_after | P0 | schema mismatch | UIUE result enum |
| CE-020 | mainline flat `cards` 与 UIUE `activeCells` 如何对齐。 | main_first_uiue_after | P0 | schema mismatch | DTO + UIUE snapshot |
| CE-021 | siblingCells/mode 信息是否进入 mainline snapshot。 | mainline | P0 | frontend/backend consistency | RPB-51 |
| CE-022 | refusedCell 是否支持多 refused cells。 | mainline | P0 | partial outcome | UIUE snapshot |
| CE-023 | scopeOrigin 是 snapshot-level 还是 per-cell map。 | mainline | P0 | contract drift | DTO vs UIUE snapshot |
| CE-024 | context(speed/gear/weather/time) 是否进入 shared snapshot 或 effect channel。 | shared | P1 | runtime/state | UIUE context |
| CE-025 | readbacks 数组顺序和“最后一条为准”规则。 | shared | P1 | replay consistency | DTO |
| CE-026 | dialogText/readbacks/matrix dialog 的 copy priority。 | shared | P0 | UX truth | DTO + UIUE matrix |
| CE-027 | empty cards 合法结果类: clarify/error/cancel 是否可空。 | shared | P1 | UI empty state | DTO tests |
| CE-028 | timestamp 是 event time、snapshot time 还是 commit time。 | shared | P1 | observability | DTO |
| CE-029 | `cardsDidStartChanging` 是否进入 event gates。 | mainline | P0 | state machine | RPB-21 |
| CE-030 | `readbackReady` 是否进入 event gates。 | mainline | P0 | state machine | RPB-21 |
| CE-031 | `ttsStart/ttsEnd` 是 effect event 还是 snapshot state。 | main_first_uiue_after | P1 | voice boundary | RPB-23 |
| CE-032 | timeout 作为 event/result/terminal snapshot 三层如何对应。 | mainline | P0 | terminality | bridge spec |
| CE-033 | `force_context_state` 是否进 `DemoInteractionEventKind`。 | mainline | P0 | demo provenance | RPB-52 |
| CE-034 | `cardTap` payload 必填 key/family, 缺失 fail-closed。 | UIUE | P1 | interaction | DTO |
| CE-035 | micStart/micEnd 是否推进 voiceState 或只作 input trace。 | shared | P1 | voice UI | DTO |
| CE-036 | background/suspend/resume 对 running turn 的 terminal/cancel 规则。 | main_first_uiue_after | P1 | runtime lifecycle | iOS runtime |
| CE-037 | `thinkAnalyzing` 与 `safetyThink` 是否类型化。 | shared | P1 | state machine | RPB-53 |
| CE-038 | 最小 1s guard 与固定 3s theatre 的边界。 | UIUE | P1 | product affordance | E2/E8 |
| CE-039 | macro_id 源必须来自 Core, UIUE 不判语义。 | mainline | P0 | hidden planner | grill master |
| CE-040 | macro narration 用 2 字段, 禁回到三段 fixed calling。 | shared | P1 | frame relapse | E4 |
| CE-041 | orbState 与 voiceState 冲突裁决。 | shared | P0 | UI truth | DTO |
| CE-042 | Reduce Motion 每态非动画等价物证明。 | UIUE | P1 | accessibility | RPB-34 |
| CE-043 | shader/GPU budget 与 MLX runtime 抢资源的门。 | UIUE | P2 | performance | UI research |
| CE-044 | mainline/UIUE proof class crosswalk。 | shared | P0 | false-green | DTO + UIUE |
| CE-045 | result enum crosswalk, 尤其 UIUE partial 与 mainline absence。 | main_first_uiue_after | P0 | SSOT drift | DTO + UIUE |
| CE-046 | `scopeOrigin=nil` 的合法边界。 | mainline | P0 | contract drift | DTO tests |
| CE-047 | string key migration proof for `scopeOrigins/activeCells`。 | main_first_uiue_after | P0 | stale key | UIUE snapshot |
| CE-048 | adapter fixture golden cases 覆盖 8 类结果。 | shared | P0 | test gap | UIUE matrix |
| CE-049 | “runtime-driven orb” 在无 runtime logs 前改名 fixture-driven。 | UIUE | P1 | claim hygiene | UIUE consumer grill |
| CE-050 | matrix entry proof 与 snapshot proof 的覆盖优先级。 | UIUE | P1 | proof drift | UIUE matrix |
| CE-051 | UIUE 禁在 mainline verdict 前新增 shared field。 | UIUE | P0 | second SSOT | UIUE consumer grill |
| CE-052 | proof ladder: docs/static/unit/simulator/operator/true-device/live。 | shared | P0 | evidence taxonomy | CURRENT |
| CE-053 | screenshot anchor no-promotion machine guard。 | UIUE | P2 | fake proof | RPB-45 |
| CE-054 | R5 receipt 必带 non-claims checkbox。 | shared | P0 | governance | R5 handoff |
| CE-055 | validation gate 按 touched paths 切换。 | shared | P1 | CI gap | Phase1 grills |
| CE-056 | stale wording grep 必查 `R5_PRECONDITIONS_BLOCKED/not_proposed/missing`。 | shared | P1 | doc drift | R5 receipts |
| CE-057 | 双 repo dirty status 分开记录, 不混提交。 | shared | P0 | git hygiene | mainline residual |
| CE-058 | mainline/UIUE OpenSpec strict 各跑各的。 | shared | P1 | validation | OpenSpec |
| CE-059 | raw ASR 只能 trace, 不作 memory/training/golden authority。 | mainline | P0 | voice memory | voice oracle |
| CE-060 | normalizer confidence gate 决定是否 update focus。 | mainline | P0 | voice memory | voice oracle |
| CE-061 | TTS/UX committed 后才写 assistant context。 | mainline | P0 | dialogue state | voice oracle |
| CE-062 | barge-in 后禁止未播出文本进入下一轮事实。 | mainline | P0 | dialogue state | voice oracle |
| CE-063 | TTS 与录音会话串行互斥。 | mainline | P1 | voice runtime | voice pre-mortem |
| CE-064 | premium 普通话 voice preflight 与 fallback。 | main_first_uiue_after | P1 | demo SOP | grill master |
| CE-065 | voiceState `unavailable` 与 `idle` 区分。 | shared | P1 | voice UI | DTO |
| CE-066 | PTT/tap/hold 语义与 MicDock 文案一致。 | UIUE | P0 | fake affordance | UIUE ContentView |
| CE-067 | golden step runtime_mounted + state_cells + whitelist digest precheck。 | mainline | P0 | golden false-green | grill master |
| CE-068 | golden replay 校验 revision delta/no-delta + readback_ok。 | mainline | P0 | end-to-end truth | voice oracle |
| CE-069 | golden/script/storyboard 文案禁直接进 C5 train/dev/test。 | mainline | P0 | leakage | RPB-43 |
| CE-070 | C6 shape replay 与 model-quality proof 分离。 | mainline | P0 | eval overclaim | CURRENT |
| CE-071 | Qwen sampling 按 behavior class 拆测, 不看 aggregate。 | mainline | P1 | model eval | home-llm spike |
| CE-072 | KV prewarm 绑定 prompt/state hash, stale cache 不算 warm pass。 | mainline | P1 | runtime perf | home-llm |
| CE-073 | Liquid4All H5 fullState/functions.json 禁当 MAformac SSOT。 | shared | P1 | external migration | UIUE handoff |
| CE-074 | `/ws-audio` 只作 local runtime teardown 灵感。 | shared | P2 | external migration | UIUE handoff |
| CE-075 | 外部 code/asset/license transfer 前置 provenance checklist。 | shared | P1 | legal/provenance | UIUE handoff |
| CE-076 | 外部 issue/bug 只能启发 premortem, 不能替代 local proof。 | shared | P2 | research hygiene | skill |
| CE-077 | display-only direct touch 必有 disabled/read-only affordance。 | UIUE | P0 | fake affordance | R4 human rows |
| CE-078 | summary direct-control policy: 展示、跳转、guard 后控制三选一。 | UIUE | P1 | product policy | R4 human rows |
| CE-079 | gear direct-touch safety policy: 默认 display-only unless approved。 | UIUE | P0 | safety UX | R4 human rows |
| CE-080 | 44pt/VoiceOver/mobile/true-device proof ladder 单独 lane。 | UIUE | P1 | accessibility | RPB-44 |
| CE-081 | white-edge threshold 保留 WARN 或 formalize, 禁偷写 PASS。 | UIUE | P2 | visual proof | R4 ledger |
| CE-082 | capsule final-art 是 human/product visual lane, 不阻塞 R5 dispatch。 | UIUE | P2 | product polish | R4 ledger |

## C. Subagent Mainline Runtime Contract MC-001~MC-018

| ID | Grill point | Owner/order | Priority | Source |
|---|---|---|---|---|
| MC-001 | `DemoRuntimeOutcome.reason / missingSlot / scopeFailureReason` 的优先级和互斥规则。 | main_first_uiue_after | P0 | subagent mainline |
| MC-002 | `behaviorClassSource` 在 accepted 和 non-accepted 结果中的填充规则。 | shared | P0 | subagent mainline |
| MC-003 | `isTerminal` 由结果类派生还是 runtime adapter 显式写入。 | shared | P0 | subagent mainline |
| MC-004 | `cards` 允许空数组的结果类和 UI empty-state 策略。 | shared | P1 | subagent mainline |
| MC-005 | `readbacks` 的顺序规则: 时间、卡片、最后一条为准。 | UIUE | P1 | subagent mainline |
| MC-006 | `dialogText` 与 `readbacks` 的 canonical human copy 裁决。 | UIUE | P1 | subagent mainline |
| MC-007 | `TraceEnvelope.traceID` 与 snapshot `traceID` 是否必须一致。 | shared | P0 | subagent mainline |
| MC-008 | `TraceEnvelope.entries` append-only 与阶段/时间单调性。 | shared | P1 | subagent mainline |
| MC-009 | snapshot `timestamp` 的时钟源和语义。 | shared | P1 | subagent mainline |
| MC-010 | `cancel` 与 `interruption` 的触发源、结果和恢复语义。 | shared | P0 | subagent mainline |
| MC-011 | `cardTap` 是否必须携带 `cardKey`, 缺失如何 fail-closed。 | UIUE | P1 | subagent mainline |
| MC-012 | `micStart/micEnd` 是输入事件还是必须驱动 voiceState。 | UIUE | P1 | subagent mainline |
| MC-013 | `voiceState` 与 `orbState` 同时非空时的主显示源和冲突裁决。 | shared | P0 | subagent mainline |
| MC-014 | `PresentationProofClass.displayCaps` 永远空是永久合同还是临时保守值。 | main_first_uiue_after | P1 | subagent mainline |
| MC-015 | 未知 `PresentationProofClass` JSON 是否所有 consumer 都 fail-closed。 | shared | P1 | subagent mainline |
| MC-016 | `PresentationReadinessClaim` 是 shared API 还是未来占位符。 | main_first_uiue_after | P2 | subagent mainline |
| MC-017 | snapshot `scopeFailureReason` 与 outcome `scopeFailureReason` 是否镜像。 | shared | P1 | subagent mainline |
| MC-018 | `scopeOrigin=nil` 的合法边界, 禁把 nil 当 defaulted。 | main_first_uiue_after | P0 | subagent mainline |

## D. Subagent UIUE Consumer Interaction Proof UC-001~UC-022

| ID | Grill point | Owner/order | Priority | Source |
|---|---|---|---|---|
| UC-001 | UIUE proof enum 与 mainline proof enum 的 crosswalk。 | shared | P0 | subagent UIUE |
| UC-002 | `operatorReview` 能否出现在产品界面, 且不得等于 acceptance。 | UIUE | P1 | subagent UIUE |
| UC-003 | UIUE matrix entry proof 与 snapshot proof 的优先级。 | UIUE | P1 | subagent UIUE |
| UC-004 | partial accept/refuse 需 accepted/refused per-cell payload 后才做复杂混合 outcome。 | main_first_uiue_after | P0 | subagent UIUE |
| UC-005 | `dialogText/readbacks/matrix dialogText` 冲突时 UI/TTS/VO 的来源优先级。 | shared | P0 | subagent UIUE |
| UC-006 | already-state 与 accepted 都 satisfied 时 a11y/readback 必须区分。 | UIUE | P1 | subagent UIUE |
| UC-007 | card `accessibilityLabel` 是否包含 scope/reason/proof/read-only。 | UIUE | P1 | subagent UIUE |
| UC-008 | `ValueControlView` direct controls 的 a11y value/hint/range。 | UIUE | P1 | subagent UIUE |
| UC-009 | MicDock button tap 与“按住说话”文案的语义错配。 | UIUE | P0 | subagent UIUE |
| UC-010 | context capsule a11y 是否读出速度/天气/挡位。 | UIUE | P1 | subagent UIUE |
| UC-011 | expanded overlay 的 escape action、button trait 与 focus return。 | UIUE | P2 | subagent UIUE |
| UC-012 | cancel/cancelled 映射 normal 后保留 terminal proof 和 announcement。 | shared | P1 | subagent UIUE |
| UC-013 | runtimeError 区分 timeout/adapter/presentation fixture failure。 | main_first_uiue_after | P1 | subagent UIUE |
| UC-014 | Reduced Motion policy 是否有非动画 UI proof fixture。 | UIUE | P1 | subagent UIUE |
| UC-015 | string-key `scopeOrigins` 改名后如何避免静默错配。 | main_first_uiue_after | P0 | subagent UIUE |
| UC-016 | `activeCells` 多 active/mixed outcome 的顺序、主次、focus priority。 | shared | P0 | subagent UIUE |
| UC-017 | U15 counterexample fixture 补 already-state/runtime-error/cancelled。 | UIUE | P1 | subagent UIUE |
| UC-018 | screenshot anchor proof-class 命名后禁被引用为 runtime/mobile proof。 | UIUE | P2 | subagent UIUE |
| UC-019 | display-only summary/gear 需要 disabled affordance 和 a11y “仅展示”。 | UIUE | P0 | subagent UIUE |
| UC-020 | a11y proof ladder 区分 local/static/simulator/true-device。 | UIUE | P2 | subagent UIUE |
| UC-021 | safety refusal 中 orbState think 与 matrix tts speaking 的 lifecycle。 | shared | P1 | subagent UIUE |
| UC-022 | mock voice state contradiction: orb speak + voice idle 要标非真实 TTS。 | UIUE | P1 | subagent UIUE |

## E. Subagent Process Validation Forecast PV-001~PV-022

| ID | Grill point | Owner/order | Priority | Source |
|---|---|---|---|---|
| PV-001 | `ToolExecutionError` 到 outcome 的完整分类, 尤其 guardDenied。 | mainline | P0 | subagent process |
| PV-002 | 每个 terminal outcome 都要 sample terminal snapshot fixture。 | main_first_uiue_after | P0 | subagent process |
| PV-003 | mainline 缺 partial, UIUE 已有 partial, 是否 canonical 或 local-only。 | main_first_uiue_after | P0 | subagent process |
| PV-004 | proof enum 必须 translation, 禁 raw value 直传。 | shared | P0 | subagent process |
| PV-005 | `displayCaps` 永远空还是未来可打开, 谁开。 | mainline | P0 | subagent process |
| PV-006 | think 两语义是否需要两个 enum/state。 | shared | P1 | subagent process |
| PV-007 | `cards_did_start_changing/readback_ready/tts_start/tts_end` 是否进 event kind。 | mainline | P0 | subagent process |
| PV-008 | `force_context_state` 必须 demo-mode 隔离和 trace provenance。 | shared | P0 | subagent process |
| PV-009 | `activeCell/siblingCells` 在 mainline snapshot 的表达方式。 | main_first_uiue_after | P0 | subagent process |
| PV-010 | already-state 证明 no revision bump、ack/readback、非 accepted delta。 | shared | P1 | subagent process |
| PV-011 | cancel/interruption 后禁止 stale async mutate cards。 | mainline | P0 | subagent process |
| PV-012 | terminal snapshot 覆盖 `isTerminal=false -> true` 唯一合法转移。 | mainline | P1 | subagent process |
| PV-013 | “runtime-driven orb binding” 在无 runtime logs 前只能叫 fixture-driven。 | UIUE | P1 | subagent process |
| PV-014 | C5/C6/golden/voice proof lane 独立 checkbox 禁互相替代。 | shared | P0 | subagent process |
| PV-015 | C6 acceptance/comparison 何时才从 bridge work 解冻。 | mainline | P0 | subagent process |
| PV-016 | voice lane 首 gate 是功能坑 spike, 不是 UIUE voiceState。 | main_first_uiue_after | P1 | subagent process |
| PV-017 | Liquid4All reject direct copy checklist。 | shared | P1 | subagent process |
| PV-018 | L0/L1/L2/L3 visual proof 绑定 proof-class cap, L1/L2 不关闭 L3。 | UIUE | P0 | subagent process |
| PV-019 | summary/gear direct touch 前先定义 disabled/safety/readback/a11y policy。 | UIUE | P1 | subagent process |
| PV-020 | R5 closeout hard gate: mainline dirty residual 与 UIUE clean 分开记录。 | shared | P0 | subagent process |
| PV-021 | docs-only vs Swift/UI touched 的 validation gate 每 lane 明确。 | shared | P1 | subagent process |
| PV-022 | C3 parser fallback/repair 是否进 runtime adapter error feedback strategy。 | mainline | P2 | subagent process |

## F. Subagent Model Voice Golden Validation MVG-001~MVG-018

| ID | Grill point | Owner/order | Priority | Source |
|---|---|---|---|---|
| MVG-001 | golden step 进入前校验 runtime_mounted、required_state_cells、whitelist digest。 | mainline | P0 | subagent MVG |
| MVG-002 | golden replay 断言 state_revision before/after、readback_ok、no unexpected delta。 | main_first_uiue_after | P0 | subagent MVG |
| MVG-003 | already_state_noop 进入 C6/golden 样本, 不算 success_with_delta。 | shared | P0 | subagent MVG |
| MVG-004 | partial accept/refuse readback 逐 cell 列 accepted/refused。 | shared | P0 | subagent MVG |
| MVG-005 | voice memory 7 seeds 升级为正式 C6/golden seeds 或明确 deferred。 | mainline | P0 | subagent MVG |
| MVG-006 | assistant context commit 等 TTS/UX committed, barge-in 后不写下一轮焦点。 | mainline | P0 | subagent MVG |
| MVG-007 | raw ASR 只进 trace, train/memory/golden label 用 normalizer output。 | mainline | P0 | subagent MVG |
| MVG-008 | low-confidence ASR no-focus-update fixture, 禁 UIUE mock transcript 证明 voice-ready。 | main_first_uiue_after | P0 | subagent MVG |
| MVG-009 | TTS 与录音会话互斥进入 voice state machine 测试。 | mainline | P1 | subagent MVG |
| MVG-010 | endpoint decode parity 统计 toolCall/content JSON/parser_repair/false tool call 分布。 | mainline | P0 | subagent MVG |
| MVG-011 | Mac dev Outlines/XGrammar fixture 标 dev_only, 禁当 iOS proof。 | mainline | P0 | subagent MVG |
| MVG-012 | Qwen sampling 按 behavior class 拆测 temp0.6 vs 0.1。 | mainline | P1 | subagent MVG |
| MVG-013 | KV prewarm 绑定 prompt/state hash, stale cache 不算 warm-path pass。 | mainline | P1 | subagent MVG |
| MVG-014 | golden/script 文案禁直接进 C5 train/dev/test, 除非 data contract。 | mainline | P0 | subagent MVG |
| MVG-015 | scene macro 带 `planned_not_golden`, golden upgrade 单独签。 | shared | P0 | subagent MVG |
| MVG-016 | UIUE local fixture proofClass unknown/缺失时 fail-closed。 | UIUE | P0 | subagent MVG |
| MVG-017 | terminal snapshot 包含 timeout/cancel/interrupted finality 防 stale async mutate。 | shared | P0 | subagent MVG |
| MVG-018 | C6/golden 区分 local_shape_no_model replay 与 model_quality。 | mainline | P0 | subagent MVG |

## G. Suggested First Grill Slices

这不是实现顺序, 只是建议 grill 顺序。

1. **Bridge truth and DTO parity**: RPB-03, RPB-06, RPB-08, RPB-09, RPB-17, RPB-24, RPB-30, RPB-51, RPB-52, MC-001~MC-018, PV-001~PV-012.
2. **Proof-class and false-green discipline**: RPB-25, RPB-36, RPB-41~RPB-48, CE-044~CE-058, UC-001~UC-003, PV-014, PV-018, PV-020, MVG-016, MVG-018.
3. **UIUE consumer and interaction truth**: RPB-11, RPB-29, RPB-33, RPB-34, RPB-44, CE-077~CE-082, UC-004~UC-022.
4. **Runtime adapter closure**: CE-001~CE-019, CE-029~CE-036, PV-001~PV-012, MVG-010~MVG-013.
5. **Voice/model/golden separation**: RPB-23, RPB-38, RPB-41~RPB-43, CE-059~CE-072, PV-015~PV-017, MVG-001~MVG-018.
6. **External reference/provenance**: CE-073~CE-076, PV-017, Liquid4All related rows.

## H. Closeout Rules For Future Use

- Do not mark this pack accepted without a separate human/user decision record.
- Do not convert this pack directly into implementation tasks without a landing matrix.
- Any row touching shared fields must go through mainline bridge carrier or a follow-up OpenSpec delta.
- UIUE can produce local/mock fixtures only when the row owner allows UIUE-first work.
- Every closeout that cites this pack must keep proof class and non-claims.

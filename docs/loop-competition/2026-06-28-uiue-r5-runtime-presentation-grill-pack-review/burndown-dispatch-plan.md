# Burndown Dispatch Plan - UIUE R5 Runtime-Presentation Grill Pack

status: `BURNDOWN_INPUT_READY`
date: 2026-06-28
source_matrix: `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/final-grill-matrix.md`
candidate_count: 215
user_decision: `C155/C172/C194 product affordance policy accepted; other 212 rows confirmed by final score/recommendation routing`
proof_class: `docs/local + controller_synthesis`

## User Confirmation And Execution Principle

User confirmed:

- `C155/C172/C194` are accepted as the customer-facing affordance policy baseline.
- The remaining 212 rows are accepted according to the final score, route, action, and recommendation in `final-grill-matrix.md`.
- Execution must not downgrade real `P0/P1` gates into vague notes.
- Execution must not over-engineer `P2`, `future_lane`, `merge_only`, or low-leverage rows into unnecessary standalone implementation work.
- `Merge` means preserve provenance under a canonical burndown item, not silently delete.
- `DeferFutureLane` means preserve as a non-claim guard, not use it as a reason to block R5 dispatch.
- `Spike` means run the smallest falsifying experiment before implementation, not build the whole lane.

This document is therefore a dispatch/burndown input. It still is not implementation authorization, closeout, runtime proof, mobile proof, true-device proof, or V-PASS.

## User-Accepted Product Policy

Accepted by user in commander chat after reviewing the high-friction human-review items:

- Do not expose `operatorReview`, `acceptance`, or equivalent internal proof words in the customer-facing main UI.
- `summary` tap only expands details; it does not directly mutate state.
- `gear` / safety-like status is display-only in UIUE; no direct touch control.
- Display-only UI must have visual/a11y copy such as `仅展示，不可操作` rather than appearing broken or silently clickable.
- Mock-controllable items live in expanded controls and must produce readback after state change.

| Accepted row | Original | Meaning | Burndown effect |
|---|---|---|---|
| C155 | UC-002 | `operatorReview` 能否出现在产品界面, 且不得等于 acceptance。 | Fold into `HR-ACCEPTED-AFFORDANCE-POLICY`; no further human decision required for this policy baseline. |
| C172 | UC-019 | display-only summary/gear 需要 disabled affordance 和 a11y “仅展示”。 | Fold into `HR-ACCEPTED-AFFORDANCE-POLICY`; no further human decision required for this policy baseline. |
| C194 | PV-019 | summary/gear direct touch 前先定义 disabled/safety/readback/a11y policy。 | Fold into `HR-ACCEPTED-AFFORDANCE-POLICY`; no further human decision required for this policy baseline. |

## Count Summary

### Priority Counts

| Key | Count |
|---|---:|
| P0 | 10 |
| P1 | 74 |
| P2 | 130 |
| P3 | 1 |

### Route Counts

| Key | Count |
|---|---:|
| future_lane | 29 |
| human_review | 11 |
| mainline_first | 77 |
| parallel_with_guard | 67 |
| reject_duplicate | 1 |
| spike_required | 8 |
| uiue_first | 22 |

### Action Counts

| Key | Count |
|---|---:|
| DeferFutureLane | 26 |
| DeferHuman | 11 |
| Drop | 1 |
| Keep | 44 |
| Merge | 111 |
| Rewrite | 14 |
| Spike | 8 |

### Package Counts

| Key | Count |
|---|---:|
| D1-drop-after-merge-target | 1 |
| F1-future-lane-nonclaim-guard | 29 |
| H1-human-review-product-policy | 8 |
| HR-ACCEPTED-AFFORDANCE-POLICY | 3 |
| K1-spike-before-implementation | 8 |
| M1-mainline-P0-bridge-contract | 3 |
| M2-mainline-P1-contract-test | 22 |
| M3-mainline-merge-only-fixture-or-doc | 52 |
| S1-shared-P0-proof-governance | 7 |
| S2-shared-contract-proof-reconcile | 22 |
| S3-shared-merge-only-receipt-hygiene | 38 |
| U2-uiue-consumer-mapping-test | 1 |
| U3-uiue-merge-only-local-proof | 21 |

## Recommended Two-Window Execution Order

| Wave | Owner | Package | Rows | Purpose | Gate before next wave |
|---|---|---|---:|---|---|
| 1 | human/product + UIUE docs | `HR-ACCEPTED-AFFORDANCE-POLICY` | 3 | Record accepted customer-facing affordance policy before UIUE touch work. | UIUE docs/handoff mentions accepted policy and no forbidden customer-facing terms. |
| 2 | mainline window | `M1-mainline-P0-bridge-contract` | 3 | Lock high-risk mainline runtime-presentation contract rows first. | OpenSpec strict + targeted mainline tests + terminal sample receipt. |
| 3 | commander + both windows | `S1-shared-P0-proof-governance` | 7 | Prevent false runtime/mobile/V-PASS proof inflation across both repos. | Proof-class checker/receipt wording exists and stale-claim grep passes. |
| 4 | mainline window | `M2-mainline-P1-contract-test` | 22 | Add or refine mainline tests/receipts for P1 contract behavior. | Targeted tests or docs receipts exist for each promoted row. |
| 5 | UIUE window | `U2-uiue-consumer-mapping-test` | 1 | Build UIUE adapter/matrix/checker work after mainline authority is stable. | UIUE matrix tests/checkers pass against locked contract names. |
| 6 | commander + both windows | `S2-shared-contract-proof-reconcile` | 22 | Reconcile names/proof wording between mainline and UIUE before closeout. | Commander verifies both repos use same names and proof caps. |
| 7 | mainline window | `M3-mainline-merge-only-fixture-or-doc` | 52 | Fold duplicate mainline fixture/document rows into canonical artifacts. | Merge targets listed in mainline artifact. |
| 8 | UIUE window | `U3-uiue-merge-only-local-proof` | 21 | Fold duplicate UIUE local proof rows into canonical checks. | Merge targets listed in UIUE artifact. |
| 9 | commander + both windows | `S3-shared-merge-only-receipt-hygiene` | 38 | Keep governance rows as receipt/checklist items, not standalone tickets. | Receipt/handoff has non-claims and dirty tree discipline. |
| 10 | human/product + UIUE docs | `H1-human-review-product-policy` | 8 | Remaining human-review rows need later user/product review. | Human checklist entries have accepted/rejected wording. |
| 11 | spike owner TBD | `K1-spike-before-implementation` | 8 | Run bounded spikes where reviewers could not converge from docs alone. | Spike receipt with pass/partial/blocked and proof class. |
| 12 | future lane owner TBD | `F1-future-lane-nonclaim-guard` | 29 | Preserve future voice/model/golden/mobile rows as non-claim guards. | Future lane ledger records non-claim wording. |
| 13 | commander cleanup | `D1-drop-after-merge-target` | 1 | Drop duplicate only after linked target exists. | Replacement/merge target is explicit. |

## Package Detail

### `HR-ACCEPTED-AFFORDANCE-POLICY`

- owner: human/product + UIUE docs
- rows: 3
- priority mix: P1=3
- purpose: Record accepted customer-facing affordance policy before UIUE touch work.

| ID | Original | P | Route | Action | Avg | Question | Next step |
|---|---|---|---|---|---:|---|---|
| C155 | UC-002 | P1 | human_review | DeferHuman | 19.8 | `operatorReview` 能否出现在产品界面, 且不得等于 acceptance。 | Lock accepted product policy: no customer-facing operatorReview/acceptance, summary only expands, gear display-only, mock controls only in expanded controls with readback. |
| C172 | UC-019 | P1 | human_review | DeferHuman | 16.8 | display-only summary/gear 需要 disabled affordance 和 a11y “仅展示”。 | Lock accepted product policy: no customer-facing operatorReview/acceptance, summary only expands, gear display-only, mock controls only in expanded controls with readback. |
| C194 | PV-019 | P1 | human_review | DeferHuman | 18.0 | summary/gear direct touch 前先定义 disabled/safety/readback/a11y policy。 | Lock accepted product policy: no customer-facing operatorReview/acceptance, summary only expands, gear display-only, mock controls only in expanded controls with readback. |

### `M1-mainline-P0-bridge-contract`

- owner: mainline window
- rows: 3
- priority mix: P0=3
- purpose: Lock high-risk mainline runtime-presentation contract rows first.

| ID | Original | P | Route | Action | Avg | Question | Next step |
|---|---|---|---|---|---:|---|---|
| C012 | RPB-12 | P0 | mainline_first | Keep | 23.0 | guard denial 必须投影成 presentation-safe refusal snapshot。 | Create standalone burndown item with explicit validator and proof class. |
| C060 | CE-007 | P0 | mainline_first | Keep | 22.0 | adapter 遇 throw 仍必须发 terminal snapshot, 禁 silent failure。 | Create standalone burndown item with explicit validator and proof class. |
| C105 | CE-052 | P0 | mainline_first | Keep | 23.2 | proof ladder: docs/static/unit/simulator/operator/true-device/live。 | Create standalone burndown item with explicit validator and proof class. |

### `S1-shared-P0-proof-governance`

- owner: commander + both windows
- rows: 7
- priority mix: P0=7
- purpose: Prevent false runtime/mobile/V-PASS proof inflation across both repos.

| ID | Original | P | Route | Action | Avg | Question | Next step |
|---|---|---|---|---|---:|---|---|
| C001 | RPB-01 | P0 | parallel_with_guard | Keep | 22.0 | 边界 override 只能是 snapshot consume + bridge event write, 不能自由 mutate store。 | Create standalone burndown item with explicit validator and proof class. |
| C008 | RPB-08 | P0 | parallel_with_guard | Keep | 22.8 | scope 展示读结构化字段, UI/TTS 禁从中文推断 scope。 | Create standalone burndown item with explicit validator and proof class. |
| C025 | RPB-25 | P0 | parallel_with_guard | Keep | 22.0 | proof class 上限: UIUE screenshot/simulator 不能变 runtime/mobile/V-PASS。 | Create standalone burndown item with explicit validator and proof class. |
| C036 | RPB-36 | P0 | parallel_with_guard | Keep | 22.0 | 模拟器不等于真机, 质感/音频/性能/热须 true-device lane。 | Create standalone burndown item with explicit validator and proof class. |
| C050 | RPB-50 | P0 | parallel_with_guard | Keep | 22.5 | 哪些落 bridge OpenSpec, 哪些留 UIUE notes 需 landing matrix。 | Create standalone burndown item with explicit validator and proof class. |
| C106 | CE-053 | P0 | parallel_with_guard | Keep | 23.0 | screenshot anchor no-promotion machine guard。 | Create standalone burndown item with explicit validator and proof class. |
| C189 | PV-014 | P0 | parallel_with_guard | Keep | 22.0 | C5/C6/golden/voice proof lane 独立 checkbox 禁互相替代。 | Create standalone burndown item with explicit validator and proof class. |

### `M2-mainline-P1-contract-test`

- owner: mainline window
- rows: 22
- priority mix: P1=18, P2=4
- purpose: Add or refine mainline tests/receipts for P1 contract behavior.

| ID | Original | P | Route | Action | Avg | Question | Next step |
|---|---|---|---|---|---:|---|---|
| C003 | RPB-03 | P1 | mainline_first | Keep | 21.7 | bridge 4 名和字段名必须由 mainline carrier/DTO 锁定。 | Create standalone burndown item with explicit validator and proof class. |
| C005 | RPB-05 | P1 | mainline_first | Keep | 21.5 | 写所有权: 触摸/事件走 executor 或 runtime adapter, 不直接写 store。 | D12 disposition: `covered_by_D12_runtime_adapter_v0_local_unit` for adapter-owned mock write path in main commit `451c699`; production runtime wiring, durable ownership, mobile/true-device/live proof, and UIUE merge remain future proof. Preserve original row. |
| C006 | RPB-06 | P1 | mainline_first | Rewrite | 20.2 | 事件集必须封闭, 包含 text/mic/card/cancel/interruption/timeout 等。 | Rewrite into one falsifiable assertion before dispatch; keep original ID as provenance. |
| C007 | RPB-07 | P1 | mainline_first | Keep | 20.5 | 事件 payload 必须区分 source/provenance 与 scope_origin/resolution。 | Create standalone burndown item with explicit validator and proof class. |
| C009 | RPB-09 | P1 | mainline_first | Keep | 21.7 | Runtime result enum 保持机器可读, 不用裸 rejected。 | Create standalone burndown item with explicit validator and proof class. |
| C010 | RPB-10 | P1 | mainline_first | Keep | 20.5 | 拒识词表要区分 unsupported/safety/clarify/already-state/runtime-error。 | Create standalone burndown item with explicit validator and proof class. |
| C014 | RPB-14 | P1 | mainline_first | Keep | 21.0 | already_state_noop 独立结果, 视觉可 satisfied 但语义非 accepted delta。 | Create standalone burndown item with explicit validator and proof class. |
| C017 | RPB-17 | P1 | mainline_first | Keep | 21.3 | partial deny 需要综合 snapshot, 逐 cell 混态与综合 readback。 | Create standalone burndown item with explicit validator and proof class. |
| C018 | RPB-18 | P1 | mainline_first | Keep | 20.3 | SceneMacroRegistry 属 Core config, 非 UIUE-only 隐藏 planner。 | D9/D10 disposition: `deferred_owner_decision`; no SceneMacroRegistry/Core config authority was invented. Preserve original row for future mainline owner lane. |
| C022 | RPB-22 | P1 | mainline_first | Keep | 21.7 | cancel/interruption/timeout/backgrounding 必须有终态 snapshot。 | Create standalone burndown item with explicit validator and proof class. |
| C023 | RPB-23 | P1 | mainline_first | Keep | 21.0 | ASR/TTS 边界: backend 接 text, voice-ready 需真机 ASR/TTS proof。 | Create standalone burndown item with explicit validator and proof class. |
| C024 | RPB-24 | P1 | mainline_first | Keep | 20.5 | TraceEnvelope 最小字段和 redaction 需要锁。 | Create standalone burndown item with explicit validator and proof class. |
| C029 | RPB-29 | P2 | mainline_first | Rewrite | 18.0 | active cell 优先级需定义, refused 可压过 satisfied。 | Rewrite into one falsifiable assertion before dispatch; keep original ID as provenance. |
| C030 | RPB-30 | P1 | mainline_first | Keep | 21.8 | snapshot card schema 要带 scope/reason/active/sibling 等呈现所需语义。 | Create standalone burndown item with explicit validator and proof class. |
| C038 | RPB-38 | P2 | mainline_first | Rewrite | 18.3 | persistence 仅 DialogueState 短时, 不做 cloud/long memory。 | Rewrite into one falsifiable assertion before dispatch; keep original ID as provenance. |
| C052 | RPB-52 | P2 | mainline_first | Rewrite | 19.7 | force-state context 输入需 `#if DEMO_MODE` + bridge event + trace provenance。 | D9/D10 disposition: `covered_by_D9_debug_only_bounded_spike`; production/runtime force-state remains future owner work. Preserve original row. |
| C061 | CE-008 | P2 | mainline_first | Rewrite | 19.3 | retry/idempotency 规则: 重试不得二次写 state 或吞掉 no-op。 | D12 disposition: `covered_by_D12_runtime_adapter_v0_local_unit` for stable command identity, deterministic request fingerprint, in-memory successful ledger, retry replay no double-write, idempotency conflict fail-closed, and failed-command no fake success in main commit `451c699`; persistent retry ledger, production runtime integration, mobile/true-device/live proof, and UIUE merge remain future. Preserve original row. |
| C062 | CE-009 | P1 | mainline_first | Keep | 21.0 | snapshot 禁 raw model output, 只带 presentation-safe outcome。 | Create standalone burndown item with explicit validator and proof class. |
| C097 | CE-044 | P1 | mainline_first | Keep | 21.3 | mainline/UIUE proof class crosswalk。 | Create standalone burndown item with explicit validator and proof class. |
| C138 | MC-003 | P1 | mainline_first | Keep | 21.3 | `isTerminal` 由结果类派生还是 runtime adapter 显式写入。 | Create standalone burndown item with explicit validator and proof class. |
| C143 | MC-008 | P1 | mainline_first | Keep | 20.7 | `TraceEnvelope.entries` append-only 与阶段/时间单调性。 | Create standalone burndown item with explicit validator and proof class. |
| C150 | MC-015 | P1 | mainline_first | Rewrite | 20.7 | 未知 `PresentationProofClass` JSON 是否所有 consumer 都 fail-closed。 | Rewrite into one falsifiable assertion before dispatch; keep original ID as provenance. |

### `U2-uiue-consumer-mapping-test`

- owner: UIUE window
- rows: 1
- priority mix: P1=1
- purpose: Build UIUE adapter/matrix/checker work after mainline authority is stable.

| ID | Original | P | Route | Action | Avg | Question | Next step |
|---|---|---|---|---|---:|---|---|
| C034 | RPB-34 | P1 | uiue_first | Rewrite | 20.2 | Reduce Motion 必须有非动画通道。 | Rewrite into one falsifiable assertion before dispatch; keep original ID as provenance. |

### `S2-shared-contract-proof-reconcile`

- owner: commander + both windows
- rows: 22
- priority mix: P1=20, P2=2
- purpose: Reconcile names/proof wording between mainline and UIUE before closeout.

| ID | Original | P | Route | Action | Avg | Question | Next step |
|---|---|---|---|---|---:|---|---|
| C002 | RPB-02 | P1 | parallel_with_guard | Keep | 21.0 | 三车道分类: UIUE local, shared bridge, mainline runtime。 | Create standalone burndown item with explicit validator and proof class. |
| C004 | RPB-04 | P1 | parallel_with_guard | Keep | 21.7 | store ownership: presentation 消费 snapshot, 不读 raw runtime store。 | Create standalone burndown item with explicit validator and proof class. |
| C013 | RPB-13 | P1 | parallel_with_guard | Keep | 21.8 | unsafe R2 展示 active/refused cell 和 safety reason, 不暴露速度等敏感内情。 | Create standalone burndown item with explicit validator and proof class. |
| C016 | RPB-16 | P2 | parallel_with_guard | Rewrite | 16.8 | 真 multi-intent splitter deferred, Phase4/5 只可 sequencer/force-state。 | Rewrite into one falsifiable assertion before dispatch; keep original ID as provenance. |
| C031 | RPB-31 | P2 | parallel_with_guard | Rewrite | 18.8 | family 覆盖 10 族 + context, 天气/时段不是第 11 族车控卡。 | Rewrite into one falsifiable assertion before dispatch; keep original ID as provenance. |
| C035 | RPB-35 | P1 | parallel_with_guard | Keep | 20.7 | Mac/iOS bridge 字段一致, layout 差异 layout-only。 | Create standalone burndown item with explicit validator and proof class. |
| C046 | RPB-46 | P1 | parallel_with_guard | Keep | 21.2 | receipt 格式需 command/device/proof/touched/residual。 | Create standalone burndown item with explicit validator and proof class. |
| C047 | RPB-47 | P1 | parallel_with_guard | Keep | 21.3 | merge-readiness 标记只能是 contract aligned not merged。 | Create standalone burndown item with explicit validator and proof class. |
| C048 | RPB-48 | P1 | parallel_with_guard | Keep | 20.8 | reviewer 必告 live HEAD, no stale SHA。 | Create standalone burndown item with explicit validator and proof class. |
| C049 | RPB-49 | P1 | parallel_with_guard | Keep | 20.7 | 未决 P0/P1 carry-forward 必进下个 closeout。 | Create standalone burndown item with explicit validator and proof class. |
| C104 | CE-051 | P1 | parallel_with_guard | Keep | 20.7 | UIUE 禁在 mainline verdict 前新增 shared field。 | Create standalone burndown item with explicit validator and proof class. |
| C107 | CE-054 | P1 | parallel_with_guard | Keep | 21.7 | R5 receipt 必带 non-claims checkbox。 | Create standalone burndown item with explicit validator and proof class. |
| C108 | CE-055 | P1 | parallel_with_guard | Rewrite | 20.7 | validation gate 按 touched paths 切换。 | Rewrite into one falsifiable assertion before dispatch; keep original ID as provenance. |
| C110 | CE-057 | P1 | parallel_with_guard | Keep | 21.7 | 双 repo dirty status 分开记录, 不混提交。 | Create standalone burndown item with explicit validator and proof class. |
| C111 | CE-058 | P1 | parallel_with_guard | Keep | 21.5 | mainline/UIUE OpenSpec strict 各跑各的。 | Create standalone burndown item with explicit validator and proof class. |
| C179 | PV-004 | P1 | parallel_with_guard | Rewrite | 20.0 | proof enum 必须 translation, 禁 raw value 直传。 | Rewrite into one falsifiable assertion before dispatch; keep original ID as provenance. |
| C185 | PV-010 | P1 | parallel_with_guard | Rewrite | 20.8 | already-state 证明 no revision bump、ack/readback、非 accepted delta。 | Rewrite into one falsifiable assertion before dispatch; keep original ID as provenance. |
| C186 | PV-011 | P1 | parallel_with_guard | Keep | 21.0 | cancel/interruption 后禁止 stale async mutate cards。 | Create standalone burndown item with explicit validator and proof class. |
| C187 | PV-012 | P1 | parallel_with_guard | Keep | 21.5 | terminal snapshot 覆盖 `isTerminal=false -> true` 唯一合法转移。 | Create standalone burndown item with explicit validator and proof class. |
| C193 | PV-018 | P1 | parallel_with_guard | Rewrite | 20.3 | L0/L1/L2/L3 visual proof 绑定 proof-class cap, L1/L2 不关闭 L3。 | Rewrite into one falsifiable assertion before dispatch; keep original ID as provenance. |
| C195 | PV-020 | P1 | parallel_with_guard | Keep | 20.7 | R5 closeout hard gate: mainline dirty residual 与 UIUE clean 分开记录。 | Create standalone burndown item with explicit validator and proof class. |
| C196 | PV-021 | P1 | parallel_with_guard | Rewrite | 20.2 | docs-only vs Swift/UI touched 的 validation gate 每 lane 明确。 | Rewrite into one falsifiable assertion before dispatch; keep original ID as provenance. |

### `M3-mainline-merge-only-fixture-or-doc`

- owner: mainline window
- rows: 52
- priority mix: P1=10, P2=42
- purpose: Fold duplicate mainline fixture/document rows into canonical artifacts.

| ID | Original | P | Route | Action | Avg | Question | Next step |
|---|---|---|---|---|---:|---|---|
| C015 | RPB-15 | P2 | mainline_first | Merge | 19.8 | clamp 成功路径要说实际 clamp 值, trace 标 clamped。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C027 | RPB-27 | P2 | mainline_first | Merge | 19.3 | normalize/range/EXP 复用 C3, UIUE 不重复相对调温逻辑。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C028 | RPB-28 | P2 | mainline_first | Merge | 19.5 | range 源来自 StateCellContractLookup 或同等 SSOT。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C032 | RPB-32 | P2 | mainline_first | Merge | 19.0 | dialogue ownership 分 runtime readback、assistant copy、presentation styling。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C033 | RPB-33 | P2 | mainline_first | Merge | 19.8 | orb 状态来源是 composite, 非视觉自嗨。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C039 | RPB-39 | P2 | mainline_first | Merge | 19.8 | crash/unknown 不可用于正常 unsupported/refusal。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C041 | RPB-41 | P2 | mainline_first | Merge | 18.2 | UIUE scripted runs 可作 future golden candidate, 非 golden proof。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C051 | RPB-51 | P1 | mainline_first | Merge | 20.5 | snapshot card 必带 sibling/secondary/active 信息以支持制冷/制热与主值。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C054 | CE-001 | P2 | mainline_first | Merge | 18.3 | `ToolExecutionError` 到 `DemoRuntimeOutcome` 的完整映射表。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C055 | CE-002 | P2 | mainline_first | Merge | 17.3 | `guardDenied` 应细分 safety/refusal/unsupported/runtime_error。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C056 | CE-003 | P2 | mainline_first | Merge | 18.5 | `semanticInvalid("missing_default_scope")` 应映射 clarify/missing scope, 不进 Core enum。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C057 | CE-004 | P2 | mainline_first | Merge | 18.0 | unsupported 与 safety refusal 必须有不同 reason taxonomy。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C058 | CE-005 | P2 | mainline_first | Merge | 18.2 | runtimeError 需分 timeout/decode/store/model/adapter failure。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C059 | CE-006 | P2 | mainline_first | Merge | 18.2 | cancellation 与 interruption 的触发源和恢复语义分开。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C063 | CE-010 | P2 | mainline_first | Merge | 18.8 | `behaviorClassSource` preservation: accepted 结果保留 `tool_call` 源。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C064 | CE-011 | P2 | mainline_first | Merge | 19.7 | accepted terminal snapshot sample 必须存在。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C065 | CE-012 | P2 | mainline_first | Merge | 19.5 | clarify/missing-slot terminal snapshot sample 必须存在。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C066 | CE-013 | P2 | mainline_first | Merge | 19.7 | unsupported/no-tool terminal snapshot sample 必须存在。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C067 | CE-014 | P1 | mainline_first | Merge | 20.7 | safety refusal terminal snapshot sample 必须存在。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C068 | CE-015 | P1 | mainline_first | Merge | 20.5 | already-state terminal snapshot sample 必须存在。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C069 | CE-016 | P1 | mainline_first | Merge | 20.2 | timeout runtimeError terminal snapshot sample 必须存在。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C070 | CE-017 | P2 | mainline_first | Merge | 19.5 | cancelled terminal snapshot sample 必须存在。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C071 | CE-018 | P1 | mainline_first | Merge | 20.2 | interrupted/barge-in terminal snapshot sample 必须存在。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C072 | CE-019 | P1 | mainline_first | Merge | 20.2 | partial accept/refuse terminal snapshot sample 必须存在或明确 local-only。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C073 | CE-020 | P2 | mainline_first | Merge | 19.7 | mainline flat `cards` 与 UIUE `activeCells` 如何对齐。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C074 | CE-021 | P2 | mainline_first | Merge | 19.3 | siblingCells/mode 信息是否进入 mainline snapshot。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C075 | CE-022 | P2 | mainline_first | Merge | 17.5 | refusedCell 是否支持多 refused cells。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C078 | CE-025 | P1 | mainline_first | Merge | 20.2 | readbacks 数组顺序和“最后一条为准”规则。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C079 | CE-026 | P2 | mainline_first | Merge | 19.7 | dialogText/readbacks/matrix dialog 的 copy priority。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C084 | CE-031 | P2 | mainline_first | Merge | 18.0 | `ttsStart/ttsEnd` 是 effect event 还是 snapshot state。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C085 | CE-032 | P1 | mainline_first | Merge | 20.7 | timeout 作为 event/result/terminal snapshot 三层如何对应。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C089 | CE-036 | P1 | mainline_first | Merge | 20.7 | background/suspend/resume 对 running turn 的 terminal/cancel 规则。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C099 | CE-046 | P2 | mainline_first | Merge | 19.3 | `scopeOrigin=nil` 的合法边界。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C101 | CE-048 | P1 | mainline_first | Merge | 20.2 | adapter fixture golden cases 覆盖 8 类结果。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C114 | CE-061 | P2 | mainline_first | Merge | 17.3 | TTS/UX committed 后才写 assistant context。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C115 | CE-062 | P2 | mainline_first | Merge | 19.0 | barge-in 后禁止未播出文本进入下一轮事实。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C116 | CE-063 | P2 | mainline_first | Merge | 19.3 | TTS 与录音会话串行互斥。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C136 | MC-001 | P2 | mainline_first | Merge | 18.7 | `DemoRuntimeOutcome.reason / missingSlot / scopeFailureReason` 的优先级和互斥规则。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C137 | MC-002 | P2 | mainline_first | Merge | 19.3 | `behaviorClassSource` 在 accepted 和 non-accepted 结果中的填充规则。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C139 | MC-004 | P2 | mainline_first | Merge | 18.5 | `cards` 允许空数组的结果类和 UI empty-state 策略。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C140 | MC-005 | P2 | mainline_first | Merge | 19.7 | `readbacks` 的顺序规则: 时间、卡片、最后一条为准。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C141 | MC-006 | P2 | mainline_first | Merge | 19.3 | `dialogText` 与 `readbacks` 的 canonical human copy 裁决。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C142 | MC-007 | P2 | mainline_first | Merge | 18.8 | `TraceEnvelope.traceID` 与 snapshot `traceID` 是否必须一致。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C144 | MC-009 | P2 | mainline_first | Merge | 19.7 | snapshot `timestamp` 的时钟源和语义。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C145 | MC-010 | P2 | mainline_first | Merge | 19.2 | `cancel` 与 `interruption` 的触发源、结果和恢复语义。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C146 | MC-011 | P2 | mainline_first | Merge | 18.2 | `cardTap` 是否必须携带 `cardKey`, 缺失如何 fail-closed。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C147 | MC-012 | P2 | mainline_first | Merge | 16.7 | `micStart/micEnd` 是输入事件还是必须驱动 voiceState。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C148 | MC-013 | P2 | mainline_first | Merge | 18.3 | `voiceState` 与 `orbState` 同时非空时的主显示源和冲突裁决。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C149 | MC-014 | P2 | mainline_first | Merge | 18.8 | `PresentationProofClass.displayCaps` 永远空是永久合同还是临时保守值。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C151 | MC-016 | P2 | mainline_first | Merge | 17.7 | `PresentationReadinessClaim` 是 shared API 还是未来占位符。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C152 | MC-017 | P2 | mainline_first | Merge | 18.7 | snapshot `scopeFailureReason` 与 outcome `scopeFailureReason` 是否镜像。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C153 | MC-018 | P2 | mainline_first | Merge | 18.8 | `scopeOrigin=nil` 的合法边界, 禁把 nil 当 defaulted。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |

### `U3-uiue-merge-only-local-proof`

- owner: UIUE window
- rows: 21
- priority mix: P1=3, P2=18
- purpose: Fold duplicate UIUE local proof rows into canonical checks.

| ID | Original | P | Route | Action | Avg | Question | Next step |
|---|---|---|---|---|---:|---|---|
| C044 | RPB-44 | P2 | uiue_first | Merge | 16.8 | Accessibility deferred 但不能消失, 双通道只覆盖一部分。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C045 | RPB-45 | P2 | uiue_first | Merge | 19.3 | screenshot anchor 命名含 platform/state/proof/source。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C080 | CE-027 | P2 | uiue_first | Merge | 18.2 | empty cards 合法结果类: clarify/error/cancel 是否可空。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C081 | CE-028 | P2 | uiue_first | Merge | 18.2 | timestamp 是 event time、snapshot time 还是 commit time。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C086 | CE-033 | P2 | uiue_first | Merge | 18.2 | `force_context_state` 是否进 `DemoInteractionEventKind`。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C087 | CE-034 | P1 | uiue_first | Merge | 20.3 | `cardTap` payload 必填 key/family, 缺失 fail-closed。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C088 | CE-035 | P2 | uiue_first | Merge | 17.7 | micStart/micEnd 是否推进 voiceState 或只作 input trace。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C154 | UC-001 | P1 | uiue_first | Merge | 20.2 | UIUE proof enum 与 mainline proof enum 的 crosswalk。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C156 | UC-003 | P2 | uiue_first | Merge | 18.8 | UIUE matrix entry proof 与 snapshot proof 的优先级。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C157 | UC-004 | P2 | uiue_first | Merge | 19.8 | partial accept/refuse 需 accepted/refused per-cell payload 后才做复杂混合 outcome。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C158 | UC-005 | P2 | uiue_first | Merge | 18.7 | `dialogText/readbacks/matrix dialogText` 冲突时 UI/TTS/VO 的来源优先级。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C159 | UC-006 | P2 | uiue_first | Merge | 18.5 | already-state 与 accepted 都 satisfied 时 a11y/readback 必须区分。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C165 | UC-012 | P2 | uiue_first | Merge | 19.2 | cancel/cancelled 映射 normal 后保留 terminal proof 和 announcement。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C166 | UC-013 | P2 | uiue_first | Merge | 19.3 | runtimeError 区分 timeout/adapter/presentation fixture failure。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C167 | UC-014 | P2 | uiue_first | Merge | 18.2 | Reduced Motion policy 是否有非动画 UI proof fixture。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C168 | UC-015 | P2 | uiue_first | Merge | 18.3 | string-key `scopeOrigins` 改名后如何避免静默错配。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C169 | UC-016 | P2 | uiue_first | Merge | 19.8 | `activeCells` 多 active/mixed outcome 的顺序、主次、focus priority。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C170 | UC-017 | P2 | uiue_first | Merge | 19.3 | U15 counterexample fixture 补 already-state/runtime-error/cancelled。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C171 | UC-018 | P1 | uiue_first | Merge | 20.5 | screenshot anchor proof-class 命名后禁被引用为 runtime/mobile proof。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C174 | UC-021 | P2 | uiue_first | Merge | 18.7 | safety refusal 中 orbState think 与 matrix tts speaking 的 lifecycle。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C175 | UC-022 | P2 | uiue_first | Merge | 18.3 | mock voice state contradiction: orb speak + voice idle 要标非真实 TTS。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |

### `S3-shared-merge-only-receipt-hygiene`

- owner: commander + both windows
- rows: 38
- priority mix: P2=38
- purpose: Keep governance rows as receipt/checklist items, not standalone tickets.

| ID | Original | P | Route | Action | Avg | Question | Next step |
|---|---|---|---|---|---:|---|---|
| C011 | RPB-11 | P2 | parallel_with_guard | Merge | 18.5 | 视觉映射为结果到 7 态的派生, 不是 runtime 结果本身。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C019 | RPB-19 | P2 | parallel_with_guard | Merge | 19.5 | 环境上下文是 runtime context, 非车控卡, 但可显示事实。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C020 | RPB-20 | P2 | parallel_with_guard | Merge | 18.7 | reset preset 清 vehicle/dialogue/trace/orb/voice/context。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C021 | RPB-21 | P2 | parallel_with_guard | Merge | 19.5 | think 应事件驱动, 不写固定计时剧场。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C037 | RPB-37 | P2 | parallel_with_guard | Merge | 17.0 | 离线 bundle, 无网无 Python, Python 只可 dev spike。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C040 | RPB-40 | P2 | parallel_with_guard | Merge | 19.2 | settings/reset 中 theme 是 presentation-only, force/reset 是 runtime input。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C053 | RPB-53 | P2 | parallel_with_guard | Merge | 17.5 | think 两语义: analyzing 事件驱动与 safety fixed 1s 演出例外。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C076 | CE-023 | P2 | parallel_with_guard | Merge | 19.2 | scopeOrigin 是 snapshot-level 还是 per-cell map。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C077 | CE-024 | P2 | parallel_with_guard | Merge | 19.3 | context(speed/gear/weather/time) 是否进入 shared snapshot 或 effect channel。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C090 | CE-037 | P2 | parallel_with_guard | Merge | 17.8 | `thinkAnalyzing` 与 `safetyThink` 是否类型化。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C091 | CE-038 | P2 | parallel_with_guard | Merge | 18.8 | 最小 1s guard 与固定 3s theatre 的边界。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C092 | CE-039 | P2 | parallel_with_guard | Merge | 17.5 | macro_id 源必须来自 Core, UIUE 不判语义。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C093 | CE-040 | P2 | parallel_with_guard | Merge | 17.3 | macro narration 用 2 字段, 禁回到三段 fixed calling。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C094 | CE-041 | P2 | parallel_with_guard | Merge | 19.2 | orbState 与 voiceState 冲突裁决。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C095 | CE-042 | P2 | parallel_with_guard | Merge | 18.0 | Reduce Motion 每态非动画等价物证明。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C098 | CE-045 | P2 | parallel_with_guard | Merge | 19.7 | result enum crosswalk, 尤其 UIUE partial 与 mainline absence。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C100 | CE-047 | P2 | parallel_with_guard | Merge | 19.7 | string key migration proof for `scopeOrigins/activeCells`。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C102 | CE-049 | P2 | parallel_with_guard | Merge | 19.0 | “runtime-driven orb” 在无 runtime logs 前改名 fixture-driven。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C103 | CE-050 | P2 | parallel_with_guard | Merge | 18.7 | matrix entry proof 与 snapshot proof 的覆盖优先级。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C109 | CE-056 | P2 | parallel_with_guard | Merge | 19.7 | stale wording grep 必查 `R5_PRECONDITIONS_BLOCKED/not_proposed/missing`。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C113 | CE-060 | P2 | parallel_with_guard | Merge | 16.0 | normalizer confidence gate 决定是否 update focus。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C118 | CE-065 | P2 | parallel_with_guard | Merge | 17.0 | voiceState `unavailable` 与 `idle` 区分。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C119 | CE-066 | P2 | parallel_with_guard | Merge | 16.8 | PTT/tap/hold 语义与 MicDock 文案一致。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C126 | CE-073 | P2 | parallel_with_guard | Merge | 17.5 | Liquid4All H5 fullState/functions.json 禁当 MAformac SSOT。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C128 | CE-075 | P2 | parallel_with_guard | Merge | 17.2 | 外部 code/asset/license transfer 前置 provenance checklist。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C129 | CE-076 | P2 | parallel_with_guard | Merge | 16.8 | 外部 issue/bug 只能启发 premortem, 不能替代 local proof。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C130 | CE-077 | P2 | parallel_with_guard | Merge | 19.5 | display-only direct touch 必有 disabled/read-only affordance。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C131 | CE-078 | P2 | parallel_with_guard | Merge | 18.3 | summary direct-control policy: 展示、跳转、guard 后控制三选一。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C132 | CE-079 | P2 | parallel_with_guard | Merge | 18.7 | gear direct-touch safety policy: 默认 display-only unless approved。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C176 | PV-001 | P2 | parallel_with_guard | Merge | 19.8 | `ToolExecutionError` 到 outcome 的完整分类, 尤其 guardDenied。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C177 | PV-002 | P2 | parallel_with_guard | Merge | 19.7 | 每个 terminal outcome 都要 sample terminal snapshot fixture。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C178 | PV-003 | P2 | parallel_with_guard | Merge | 18.8 | mainline 缺 partial, UIUE 已有 partial, 是否 canonical 或 local-only。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C180 | PV-005 | P2 | parallel_with_guard | Merge | 18.2 | `displayCaps` 永远空还是未来可打开, 谁开。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C181 | PV-006 | P2 | parallel_with_guard | Merge | 17.3 | think 两语义是否需要两个 enum/state。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C183 | PV-008 | P2 | parallel_with_guard | Merge | 19.0 | `force_context_state` 必须 demo-mode 隔离和 trace provenance。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C184 | PV-009 | P2 | parallel_with_guard | Merge | 19.3 | `activeCell/siblingCells` 在 mainline snapshot 的表达方式。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C188 | PV-013 | P2 | parallel_with_guard | Merge | 18.2 | “runtime-driven orb binding” 在无 runtime logs 前只能叫 fixture-driven。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |
| C192 | PV-017 | P2 | parallel_with_guard | Merge | 17.0 | Liquid4All reject direct copy checklist。 | Merge under package canonical item; do not open standalone task unless downstream owner promotes. |

### `H1-human-review-product-policy`

- owner: human/product + UIUE docs
- rows: 8
- priority mix: P1=8
- purpose: Remaining human-review rows need later user/product review.

| ID | Original | P | Route | Action | Avg | Question | Next step |
|---|---|---|---|---|---:|---|---|
| C134 | CE-081 | P1 | human_review | DeferHuman | 15.5 | white-edge threshold 保留 WARN 或 formalize, 禁偷写 PASS。 | D9/D10 disposition: `blocked_for_threshold`; Stage 3 added simulator review evidence but did not sign white-edge PASS. Keep in human review backlog. |
| C135 | CE-082 | P1 | human_review | DeferHuman | 15.0 | capsule final-art 是 human/product visual lane, 不阻塞 R5 dispatch。 | D9/D10 disposition: `simulator_review_prep_only`; Stage 3 screenshot is simulator_mock review prep, not final-art acceptance. Keep in human/product lane. |
| C160 | UC-007 | P1 | human_review | DeferHuman | 18.0 | card `accessibilityLabel` 是否包含 scope/reason/proof/read-only。 | Keep in human review backlog; no code until wording/interaction is accepted. |
| C161 | UC-008 | P1 | human_review | DeferHuman | 16.5 | `ValueControlView` direct controls 的 a11y value/hint/range。 | Keep in human review backlog; no code until wording/interaction is accepted. |
| C162 | UC-009 | P1 | human_review | DeferHuman | 16.7 | MicDock button tap 与“按住说话”文案的语义错配。 | Keep in human review backlog; no code until wording/interaction is accepted. |
| C163 | UC-010 | P1 | human_review | DeferHuman | 15.5 | context capsule a11y 是否读出速度/天气/挡位。 | Keep in human review backlog; no code until wording/interaction is accepted. |
| C164 | UC-011 | P1 | human_review | DeferHuman | 18.3 | expanded overlay 的 escape action、button trait 与 focus return。 | Keep in human review backlog; no code until wording/interaction is accepted. |
| C173 | UC-020 | P1 | human_review | DeferHuman | 20.8 | a11y proof ladder 区分 local/static/simulator/true-device。 | Keep in human review backlog; no code until wording/interaction is accepted. |

### `K1-spike-before-implementation`

- owner: spike owner TBD
- rows: 8
- priority mix: P1=8
- purpose: Run bounded spikes where reviewers could not converge from docs alone.

| ID | Original | P | Route | Action | Avg | Question | Next step |
|---|---|---|---|---|---:|---|---|
| C082 | CE-029 | P1 | spike_required | Spike | 18.0 | `cardsDidStartChanging` 是否进入 event gates。 | Run bounded spike; no implementation claim until spike receipt exists. |
| C083 | CE-030 | P1 | spike_required | Spike | 18.3 | `readbackReady` 是否进入 event gates。 | Run bounded spike; no implementation claim until spike receipt exists. |
| C096 | CE-043 | P1 | spike_required | Spike | 17.2 | shader/GPU budget 与 MLX runtime 抢资源的门。 | Run bounded spike; no implementation claim until spike receipt exists. |
| C117 | CE-064 | P1 | spike_required | Spike | 16.8 | premium 普通话 voice preflight 与 fallback。 | Run bounded spike; no implementation claim until spike receipt exists. |
| C182 | PV-007 | P1 | spike_required | Spike | 19.3 | `cards_did_start_changing/readback_ready/tts_start/tts_end` 是否进 event kind。 | Run bounded spike; no implementation claim until spike receipt exists. |
| C197 | PV-022 | P1 | spike_required | Spike | 16.5 | C3 parser fallback/repair 是否进 runtime adapter error feedback strategy。 | Run bounded spike; no implementation claim until spike receipt exists. |
| C207 | MVG-010 | P1 | spike_required | Spike | 17.0 | endpoint decode parity 统计 toolCall/content JSON/parser_repair/false tool call 分布。 | Run bounded spike; no implementation claim until spike receipt exists. |
| C208 | MVG-011 | P1 | spike_required | Spike | 19.8 | Mac dev Outlines/XGrammar fixture 标 dev_only, 禁当 iOS proof。 | Run bounded spike; no implementation claim until spike receipt exists. |

### `F1-future-lane-nonclaim-guard`

- owner: future lane owner TBD
- rows: 29
- priority mix: P1=3, P2=26
- purpose: Preserve future voice/model/golden/mobile rows as non-claim guards.

| ID | Original | P | Route | Action | Avg | Question | Next step |
|---|---|---|---|---|---:|---|---|
| C026 | RPB-26 | P2 | future_lane | DeferFutureLane | 15.0 | 现态推理/感受词走 C3 相对 EXP 或 later LoRA, 不在 UIUE 自建。 | Preserve as non-claim guard; no R5 implementation task. |
| C042 | RPB-42 | P2 | future_lane | DeferFutureLane | 15.5 | UIUE 视觉绝不选模型候选, candidate comparison 是 later mainline。 | Preserve as non-claim guard; no R5 implementation task. |
| C043 | RPB-43 | P2 | future_lane | DeferFutureLane | 15.8 | UIUE 文案/case 不能直接进入训练数据。 | Preserve as non-claim guard; no R5 implementation task. |
| C112 | CE-059 | P2 | future_lane | DeferFutureLane | 16.3 | raw ASR 只能 trace, 不作 memory/training/golden authority。 | Preserve as non-claim guard; no R5 implementation task. |
| C120 | CE-067 | P2 | future_lane | DeferFutureLane | 18.7 | golden step runtime_mounted + state_cells + whitelist digest precheck。 | Preserve as non-claim guard; no R5 implementation task. |
| C121 | CE-068 | P2 | future_lane | DeferFutureLane | 17.8 | golden replay 校验 revision delta/no-delta + readback_ok。 | Preserve as non-claim guard; no R5 implementation task. |
| C122 | CE-069 | P2 | future_lane | DeferFutureLane | 17.3 | golden/script/storyboard 文案禁直接进 C5 train/dev/test。 | Preserve as non-claim guard; no R5 implementation task. |
| C123 | CE-070 | P2 | future_lane | DeferFutureLane | 18.2 | C6 shape replay 与 model-quality proof 分离。 | Preserve as non-claim guard; no R5 implementation task. |
| C124 | CE-071 | P2 | future_lane | DeferFutureLane | 15.5 | Qwen sampling 按 behavior class 拆测, 不看 aggregate。 | Preserve as non-claim guard; no R5 implementation task. |
| C125 | CE-072 | P2 | future_lane | DeferFutureLane | 15.5 | KV prewarm 绑定 prompt/state hash, stale cache 不算 warm pass。 | Preserve as non-claim guard; no R5 implementation task. |
| C133 | CE-080 | P2 | future_lane | DeferFutureLane | 18.2 | 44pt/VoiceOver/mobile/true-device proof ladder 单独 lane。 | Preserve as non-claim guard; no R5 implementation task. |
| C190 | PV-015 | P2 | future_lane | DeferFutureLane | 15.5 | C6 acceptance/comparison 何时才从 bridge work 解冻。 | Preserve as non-claim guard; no R5 implementation task. |
| C191 | PV-016 | P2 | future_lane | DeferFutureLane | 17.3 | voice lane 首 gate 是功能坑 spike, 不是 UIUE voiceState。 | Preserve as non-claim guard; no R5 implementation task. |
| C198 | MVG-001 | P2 | future_lane | DeferFutureLane | 18.7 | golden step 进入前校验 runtime_mounted、required_state_cells、whitelist digest。 | Preserve as non-claim guard; no R5 implementation task. |
| C199 | MVG-002 | P2 | future_lane | DeferFutureLane | 18.8 | golden replay 断言 state_revision before/after、readback_ok、no unexpected delta。 | Preserve as non-claim guard; no R5 implementation task. |
| C200 | MVG-003 | P2 | future_lane | DeferFutureLane | 19.8 | already_state_noop 进入 C6/golden 样本, 不算 success_with_delta。 | Preserve as non-claim guard; no R5 implementation task. |
| C201 | MVG-004 | P1 | future_lane | Keep | 21.0 | partial accept/refuse readback 逐 cell 列 accepted/refused。 | Create standalone burndown item with explicit validator and proof class. |
| C202 | MVG-005 | P2 | future_lane | DeferFutureLane | 15.3 | voice memory 7 seeds 升级为正式 C6/golden seeds 或明确 deferred。 | Preserve as non-claim guard; no R5 implementation task. |
| C203 | MVG-006 | P2 | future_lane | DeferFutureLane | 18.5 | assistant context commit 等 TTS/UX committed, barge-in 后不写下一轮焦点。 | Preserve as non-claim guard; no R5 implementation task. |
| C204 | MVG-007 | P2 | future_lane | DeferFutureLane | 17.8 | raw ASR 只进 trace, train/memory/golden label 用 normalizer output。 | Preserve as non-claim guard; no R5 implementation task. |
| C205 | MVG-008 | P2 | future_lane | DeferFutureLane | 20.0 | low-confidence ASR no-focus-update fixture, 禁 UIUE mock transcript 证明 voice-ready。 | Preserve as non-claim guard; no R5 implementation task. |
| C206 | MVG-009 | P2 | future_lane | DeferFutureLane | 18.8 | TTS 与录音会话互斥进入 voice state machine 测试。 | Preserve as non-claim guard; no R5 implementation task. |
| C209 | MVG-012 | P2 | future_lane | DeferFutureLane | 15.2 | Qwen sampling 按 behavior class 拆测 temp0.6 vs 0.1。 | Preserve as non-claim guard; no R5 implementation task. |
| C210 | MVG-013 | P2 | future_lane | DeferFutureLane | 15.8 | KV prewarm 绑定 prompt/state hash, stale cache 不算 warm-path pass。 | Preserve as non-claim guard; no R5 implementation task. |
| C211 | MVG-014 | P2 | future_lane | DeferFutureLane | 15.7 | golden/script 文案禁直接进 C5 train/dev/test, 除非 data contract。 | Preserve as non-claim guard; no R5 implementation task. |
| C212 | MVG-015 | P2 | future_lane | DeferFutureLane | 16.2 | scene macro 带 `planned_not_golden`, golden upgrade 单独签。 | Preserve as non-claim guard; no R5 implementation task. |
| C213 | MVG-016 | P1 | future_lane | Keep | 22.2 | UIUE local fixture proofClass unknown/缺失时 fail-closed。 | Create standalone burndown item with explicit validator and proof class. |
| C214 | MVG-017 | P1 | future_lane | Keep | 21.7 | terminal snapshot 包含 timeout/cancel/interrupted finality 防 stale async mutate。 | Create standalone burndown item with explicit validator and proof class. |
| C215 | MVG-018 | P2 | future_lane | DeferFutureLane | 19.0 | C6/golden 区分 local_shape_no_model replay 与 model_quality。 | Preserve as non-claim guard; no R5 implementation task. |

### `D1-drop-after-merge-target`

- owner: commander cleanup
- rows: 1
- priority mix: P3=1
- purpose: Drop duplicate only after linked target exists.

| ID | Original | P | Route | Action | Avg | Question | Next step |
|---|---|---|---|---|---:|---|---|
| C127 | CE-074 | P3 | reject_duplicate | Drop | 13.3 | `/ws-audio` 只作 local runtime teardown 灵感。 | Drop only after linked merge target is recorded. |

## Non-Claims

This burndown plan is not an implementation closeout. It does not claim runtime-ready, mobile, true_device, voice-ready, model-ready, golden-ready, endpoint-ready, UIUE merge, V-PASS, S-PASS, U-PASS, or A-2 complete.

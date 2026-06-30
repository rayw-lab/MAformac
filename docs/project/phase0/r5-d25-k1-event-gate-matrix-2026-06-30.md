# R5 D25 K1 Event Gate Matrix Receipt

label: UIUE_R5_D25_K1_SPIKE_LEDGER_FOUR_GATE_SUPERTRAIN
gate: D25_GATE_1_EVENT_GATE_MATRIX
rows: C082, C083, C182
status: DONE
proof_class: docs_local + local_static + openspec_local

## 结论

C082/C083/C182 均为 `PASS / keep_spike_only`。D25 证明了现有 mainline 还没有 `cards_did_start_changing`、`readback_ready`、`tts_start`、`tts_end` 这些 typed event kind；也证明了 readback 和 cards 已在 terminal snapshot/payload 里存在。缺口是“是否要新增事件门”的 runtime/product decision，不是 D25 可直接 promote 的实现项。

## 统一 Event-Gate Matrix

| row | question | live evidence | D25 decision | promotion |
|---|---|---|---|---|
| C082 | `cardsDidStartChanging` 是否独立事件门 | `DemoInteractionEventKind` 只有 `text_input/mic_start/mic_end/card_tap/cancel/interruption`，UIUE mapping 也只认可这些 stable names。 | 需要未来 typed event spike；不能从 card diff 或 terminal snapshot 推断 animation-start gate。 | keep_spike_only |
| C083 | `readbackReady` 是否独立事件门 | `PresentationSnapshot.readbacks` 已存在，payload 也含 readbacks；但 event kind 集合没有 `readback_ready`。 | readback content 已可静态消费；readback-ready 触发时机仍需未来事件门。 | keep_spike_only |
| C182 | 四类 event kind 是否统一进入 event matrix | 当前 event kind 不含 `cards_did_start_changing/readback_ready/tts_start/tts_end`；C082/C083/TTS 不应各自造 mapper。 | 未来若 promote，应一次性加统一 event-kind matrix，不分裂成第三套 mapper。 | keep_spike_only |

## 证据

| evidence | location | proves |
|---|---|---|
| `DemoInteractionEventKind` 当前枚举只有 6 个用户/系统交互事件。 | `Core/Presentation/RuntimePresentationBridge.swift:3-10` | C082/C083/C182 的目标 event kind 尚未存在。 |
| `PresentationSnapshot` 含 cards/readbacks/voice/orb/proof/isTerminal。 | `Core/Presentation/RuntimePresentationBridge.swift:374-421` | 现有 snapshot 能表达终态，但不等于独立 event gate。 |
| UIUE consumer stable event kind 与 mainline 一致，排除了 `timeout`。 | `Tests/MAformacCoreTests/RuntimePresentationConsumerMappingTests.swift:5-11` | 当前 event-kind allowlist 已被测试固定。 |
| K1 八行仍是 `spikeBeforeImplementation`。 | `Tests/MAformacCoreTests/RuntimePresentationConsumerMappingTests.swift:277-285` | D25 之前这些行不能被当作实现授权。 |
| Bridge spec 明确 timeout 是 terminal result，不是 event kind。 | `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md:125-130` | event-kind 增删需合同级判断，不能随意扩。 |
| Grill matrix 将 C082/C083/C182 标为 `spike_required`。 | `docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/final-grill-matrix.md:142-143`, `:242` | reviewer disagreement 未消除。 |

## Harness

- skills_ledger: executing-plans, pre-mortem, bug-iceberg-teardown, OpenSpec, GitNexus stale-static context, local oracle via repo grep.
- lessons_learned: D20-D24 的核心教训是 UIUE consumer proof 不能反推 mainline event proof；D25 保留 spike ledger。
- metacognitive_check: 避免把“readbacks/cards 字段存在”误判为“readbackReady/cardsDidStartChanging event 已存在”。
- pre_mortem: 如果直接 promote，未来 UIUE 可能从 card diff/terminal snapshot 自推时序，造成动画、TTS、scroll policy 三套 mapper 漂移。
- iceberg_teardown: visible symptom 是缺 event name；deeper class 是 snapshot-state 与 lifecycle-event 的模态混淆。
- local_search: `rg -n "cardsDidStartChanging|readbackReady|cards_did_start_changing|readback_ready|tts_start|tts_end" Core Tests openspec docs`; `nl -ba` inspected bridge, mapping, tests, bridge spec.
- external_or_official_truth: not_applicable; no platform/API behavior was needed for this gate.
- goal_drift_check: no C5/C6/runtime backend/voice/golden/UIUE merge work executed.
- authority_check: governed by `CLAUDE.md`, `docs/CURRENT.md`, `define-runtime-presentation-bridge`, K1 final matrix, and D25 dispatch.
- claim_vs_proof_check: docs/static/OpenSpec proof only; no runtime/mobile/true-device/live/V-PASS claim.
- boundary_check: no Swift/spec edit; no UIUE merge; no event promotion.
- self_question: If this were wrong, `DemoInteractionEventKind` or consumer mapping tests would contain the four event names.

## Row Verdicts

| row_id | status | proof_class | promotion_decision | residual |
|---|---|---|---|---|
| C082 | PASS | docs_local + local_static | keep_spike_only | Future typed event spike required before implementation. |
| C083 | PASS | docs_local + local_static | keep_spike_only | Future readback lifecycle event decision required. |
| C182 | PASS | docs_local + openspec_local | keep_spike_only | If promoted later, add one unified event-kind matrix. |

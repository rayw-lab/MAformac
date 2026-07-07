# Final Grill Matrix - UIUE R5 Runtime-Presentation Grill Pack Review

status: `READY_FOR_BURNDOWN_INPUT`
date: 2026-06-28
candidate_count: 215
reviewer_count: 6 valid reviewers across 2 rounds
proof_class: `docs/local + subagent_readonly + controller_judge`

## Executive Summary

- The 215-row pack is valid as an audit trail, but not all rows should become standalone workstreams.
- Highest-value standalone gates: mainline DTO/snapshot authority, proof-class no-promotion, terminal snapshot/finality fixture manifest, UIUE consumer crosswalk, and direct-touch/human-review policy.
- Largest duplication clusters: proof/non-claim ladder, terminal/cancel/interruption sample fixtures, snapshot/readback field crosswalk, voice/model/golden future-lane guards.
- Recommended downstream burndown shape: keep P0/P1 standalone gates, convert repeated rows to `merge_only`, and preserve future-lane rows as non-claim guards.

## Count Summary

| Bucket | Count |
|---|---:|
| priority P0 | 10 |
| priority P1 | 74 |
| priority P2 | 130 |
| priority P3 | 1 |
| action DeferFutureLane | 26 |
| action DeferHuman | 11 |
| action Drop | 1 |
| action Keep | 44 |
| action Merge | 111 |
| action Rewrite | 14 |
| action Spike | 8 |
| route future_lane | 29 |
| route human_review | 11 |
| route mainline_first | 77 |
| route parallel_with_guard | 67 |
| route reject_duplicate | 1 |
| route spike_required | 8 |
| route uiue_first | 22 |
| stage FutureLane | 29 |
| stage HumanReview | 11 |
| stage Mainline | 77 |
| stage MergeDrop | 1 |
| stage Shared | 67 |
| stage Spike | 8 |
| stage UIUE | 22 |

## Canonical Burndown Groups

| Group | Route | Representative rows | Controller recommendation |
|---|---|---|---|
| G1 Mainline DTO / snapshot authority | mainline_first | RPB/CE/MC rows around runtime outcome, scope, trace, terminal fields | Create mainline burndown package first; UIUE consumes only after DTO/test/sample evidence. |
| G2 UIUE consumer mapping | uiue_first | UC rows plus UIUE-facing RPB/CE rows | Build adapter/matrix tests against locked DTO names; keep proof local/simulator unless real proof exists. |
| G3 Terminal fixture manifest | mainline_first then UIUE | cancel/interruption/timeout/partial/refusal/already-state/stale async rows | Collapse duplicates into one fixture manifest with terminal snapshot samples and late-mutation checks. |
| G4 Proof-class / no-claim ladder | parallel_with_guard | proof cap, receipt, stale wording, displayCaps, screenshot/operatorReview rows | Make a checker/receipt schema; do not rely on prose discipline. |
| G5 Human/product policy | human_review | direct-touch, gear/summary, a11y taste, capsule/white-edge/mobile visual gates | Send to human review or UIUE product lane, not shared runtime DTO. |
| G6 Future voice/model/golden lanes | future_lane | MVG and voice/model/golden/C5/C6 rows | Preserve as non-claim guards; promote only with separate lane authorization. |

## Six-Reviewer Matrix

| ID | Original ID | Stage | Grill question | R1-RED | R1-GREEN | R1-BLUE | R2-PURPLE | R2-ORANGE | R2-BLACK | Avg | Spread | Priority | Route | Action | Recommendation |
|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---|---|---|---|
| C001 | RPB-01 | Shared | 边界 override 只能是 snapshot consume + bridge event write, 不能自由 mutate store。 | 22 | 24 | 20 | 24 | 19 | 23 | 22.0 | 5 | P0 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C002 | RPB-02 | Shared | 三车道分类: UIUE local, shared bridge, mainline runtime。 | 22 | 24 | 22 | 17 | 19 | 22 | 21.0 | 7 | P1 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C003 | RPB-03 | Mainline | bridge 4 名和字段名必须由 mainline carrier/DTO 锁定。 | 22 | 24 | 18 | 24 | 19 | 23 | 21.7 | 6 | P1 | mainline_first | Keep | Keep as standalone mainline-first burndown gate; require OpenSpec/DTO/test or terminal snapshot evidence. |
| C004 | RPB-04 | Shared | store ownership: presentation 消费 snapshot, 不读 raw runtime store。 | 17 | 24 | 22 | 24 | 19 | 24 | 21.7 | 7 | P1 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C005 | RPB-05 | Mainline | 写所有权: 触摸/事件走 executor 或 runtime adapter, 不直接写 store。 | 19 | 24 | 20 | 24 | 19 | 23 | 21.5 | 5 | P1 | mainline_first | Keep | Keep as standalone mainline-first burndown gate; require OpenSpec/DTO/test or terminal snapshot evidence. |
| C006 | RPB-06 | Mainline | 事件集必须封闭, 包含 text/mic/card/cancel/interruption/timeout 等。 | 20 | 24 | 20 | 18 | 19 | 20 | 20.2 | 6 | P1 | mainline_first | Rewrite | Rewrite into a single falsifiable assertion with owner, validator, and proof class before dispatch. |
| C007 | RPB-07 | Mainline | 事件 payload 必须区分 source/provenance 与 scope_origin/resolution。 | 18 | 24 | 19 | 24 | 19 | 19 | 20.5 | 6 | P1 | mainline_first | Keep | Keep as standalone mainline-first burndown gate; require OpenSpec/DTO/test or terminal snapshot evidence. |
| C008 | RPB-08 | Shared | scope 展示读结构化字段, UI/TTS 禁从中文推断 scope。 | 22 | 24 | 24 | 24 | 19 | 24 | 22.8 | 5 | P0 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C009 | RPB-09 | Mainline | Runtime result enum 保持机器可读, 不用裸 rejected。 | 22 | 24 | 17 | 24 | 19 | 24 | 21.7 | 7 | P1 | mainline_first | Keep | Keep as standalone mainline-first burndown gate; require OpenSpec/DTO/test or terminal snapshot evidence. |
| C010 | RPB-10 | Mainline | 拒识词表要区分 unsupported/safety/clarify/already-state/runtime-error。 | 24 | 24 | 20 | 17 | 19 | 19 | 20.5 | 7 | P1 | mainline_first | Keep | Keep as standalone mainline-first burndown gate; require OpenSpec/DTO/test or terminal snapshot evidence. |
| C011 | RPB-11 | Shared | 视觉映射为结果到 7 态的派生, 不是 runtime 结果本身。 | 15 | 13 | 25 | 17 | 19 | 22 | 18.5 | 12 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C012 | RPB-12 | Mainline | guard denial 必须投影成 presentation-safe refusal snapshot。 | 24 | 24 | 24 | 24 | 19 | 23 | 23.0 | 5 | P0 | mainline_first | Keep | Keep as standalone mainline-first burndown gate; require OpenSpec/DTO/test or terminal snapshot evidence. |
| C013 | RPB-13 | Shared | unsafe R2 展示 active/refused cell 和 safety reason, 不暴露速度等敏感内情。 | 24 | 24 | 24 | 18 | 19 | 22 | 21.8 | 6 | P1 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C014 | RPB-14 | Mainline | already_state_noop 独立结果, 视觉可 satisfied 但语义非 accepted delta。 | 19 | 24 | 24 | 17 | 19 | 23 | 21.0 | 7 | P1 | mainline_first | Keep | Keep as standalone mainline-first burndown gate; require OpenSpec/DTO/test or terminal snapshot evidence. |
| C015 | RPB-15 | Mainline | clamp 成功路径要说实际 clamp 值, trace 标 clamped。 | 19 | 24 | 20 | 17 | 19 | 20 | 19.8 | 7 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C016 | RPB-16 | Shared | 真 multi-intent splitter deferred, Phase4/5 只可 sequencer/force-state。 | 15 | 12 | 18 | 18 | 19 | 19 | 16.8 | 7 | P2 | parallel_with_guard | Rewrite | Rewrite into a single falsifiable assertion with owner, validator, and proof class before dispatch. |
| C017 | RPB-17 | Mainline | partial deny 需要综合 snapshot, 逐 cell 混态与综合 readback。 | 22 | 17 | 24 | 24 | 19 | 22 | 21.3 | 7 | P1 | mainline_first | Keep | Keep as standalone mainline-first burndown gate; require OpenSpec/DTO/test or terminal snapshot evidence. |
| C018 | RPB-18 | Mainline | SceneMacroRegistry 属 Core config, 非 UIUE-only 隐藏 planner。 | 19 | 24 | 16 | 24 | 19 | 20 | 20.3 | 8 | P1 | mainline_first | Keep | Keep as standalone mainline-first burndown gate; require OpenSpec/DTO/test or terminal snapshot evidence. |
| C019 | RPB-19 | Shared | 环境上下文是 runtime context, 非车控卡, 但可显示事实。 | 19 | 24 | 20 | 18 | 19 | 17 | 19.5 | 7 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C020 | RPB-20 | Shared | reset preset 清 vehicle/dialogue/trace/orb/voice/context。 | 21 | 12 | 21 | 18 | 19 | 21 | 18.7 | 9 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C021 | RPB-21 | Shared | think 应事件驱动, 不写固定计时剧场。 | 15 | 24 | 20 | 17 | 19 | 22 | 19.5 | 9 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C022 | RPB-22 | Mainline | cancel/interruption/timeout/backgrounding 必须有终态 snapshot。 | 24 | 24 | 23 | 17 | 19 | 23 | 21.7 | 7 | P1 | mainline_first | Keep | Keep as standalone mainline-first burndown gate; require OpenSpec/DTO/test or terminal snapshot evidence. |
| C023 | RPB-23 | Mainline | ASR/TTS 边界: backend 接 text, voice-ready 需真机 ASR/TTS proof。 | 25 | 12 | 23 | 24 | 19 | 23 | 21.0 | 13 | P1 | mainline_first | Keep | Keep as standalone mainline-first burndown gate; require OpenSpec/DTO/test or terminal snapshot evidence. |
| C024 | RPB-24 | Mainline | TraceEnvelope 最小字段和 redaction 需要锁。 | 18 | 24 | 18 | 24 | 19 | 20 | 20.5 | 6 | P1 | mainline_first | Keep | Keep as standalone mainline-first burndown gate; require OpenSpec/DTO/test or terminal snapshot evidence. |
| C025 | RPB-25 | Shared | proof class 上限: UIUE screenshot/simulator 不能变 runtime/mobile/V-PASS。 | 25 | 12 | 24 | 24 | 23 | 24 | 22.0 | 13 | P0 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C026 | RPB-26 | FutureLane | 现态推理/感受词走 C3 相对 EXP 或 later LoRA, 不在 UIUE 自建。 | 18 | 13 | 16 | 14 | 13 | 16 | 15.0 | 5 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C027 | RPB-27 | Mainline | normalize/range/EXP 复用 C3, UIUE 不重复相对调温逻辑。 | 19 | 24 | 17 | 18 | 19 | 19 | 19.3 | 7 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C028 | RPB-28 | Mainline | range 源来自 StateCellContractLookup 或同等 SSOT。 | 19 | 24 | 17 | 19 | 19 | 19 | 19.5 | 7 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C029 | RPB-29 | Mainline | active cell 优先级需定义, refused 可压过 satisfied。 | 15 | 13 | 24 | 17 | 19 | 20 | 18.0 | 11 | P2 | mainline_first | Rewrite | Rewrite into a single falsifiable assertion with owner, validator, and proof class before dispatch. |
| C030 | RPB-30 | Mainline | snapshot card schema 要带 scope/reason/active/sibling 等呈现所需语义。 | 18 | 24 | 24 | 24 | 19 | 22 | 21.8 | 6 | P1 | mainline_first | Keep | Keep as standalone mainline-first burndown gate; require OpenSpec/DTO/test or terminal snapshot evidence. |
| C031 | RPB-31 | Shared | family 覆盖 10 族 + context, 天气/时段不是第 11 族车控卡。 | 15 | 24 | 20 | 18 | 19 | 17 | 18.8 | 9 | P2 | parallel_with_guard | Rewrite | Rewrite into a single falsifiable assertion with owner, validator, and proof class before dispatch. |
| C032 | RPB-32 | Mainline | dialogue ownership 分 runtime readback、assistant copy、presentation styling。 | 18 | 17 | 24 | 17 | 19 | 19 | 19.0 | 7 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C033 | RPB-33 | Mainline | orb 状态来源是 composite, 非视觉自嗨。 | 15 | 24 | 22 | 17 | 19 | 22 | 19.8 | 9 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C034 | RPB-34 | UIUE | Reduce Motion 必须有非动画通道。 | 15 | 24 | 25 | 18 | 19 | 20 | 20.2 | 10 | P1 | uiue_first | Rewrite | Rewrite into a single falsifiable assertion with owner, validator, and proof class before dispatch. |
| C035 | RPB-35 | Shared | Mac/iOS bridge 字段一致, layout 差异 layout-only。 | 18 | 24 | 20 | 24 | 19 | 19 | 20.7 | 6 | P1 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C036 | RPB-36 | Shared | 模拟器不等于真机, 质感/音频/性能/热须 true-device lane。 | 24 | 13 | 24 | 24 | 23 | 24 | 22.0 | 11 | P0 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C037 | RPB-37 | Shared | 离线 bundle, 无网无 Python, Python 只可 dev spike。 | 19 | 12 | 18 | 18 | 13 | 22 | 17.0 | 10 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C038 | RPB-38 | Mainline | persistence 仅 DialogueState 短时, 不做 cloud/long memory。 | 15 | 24 | 17 | 18 | 19 | 17 | 18.3 | 9 | P2 | mainline_first | Rewrite | Rewrite into a single falsifiable assertion with owner, validator, and proof class before dispatch. |
| C039 | RPB-39 | Mainline | crash/unknown 不可用于正常 unsupported/refusal。 | 19 | 24 | 20 | 17 | 19 | 20 | 19.8 | 7 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C040 | RPB-40 | Shared | settings/reset 中 theme 是 presentation-only, force/reset 是 runtime input。 | 15 | 24 | 20 | 17 | 19 | 20 | 19.2 | 9 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C041 | RPB-41 | Mainline | UIUE scripted runs 可作 future golden candidate, 非 golden proof。 | 22 | 12 | 18 | 17 | 19 | 21 | 18.2 | 10 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C042 | RPB-42 | FutureLane | UIUE 视觉绝不选模型候选, candidate comparison 是 later mainline。 | 19 | 13 | 15 | 14 | 13 | 19 | 15.5 | 6 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C043 | RPB-43 | FutureLane | UIUE 文案/case 不能直接进入训练数据。 | 15 | 12 | 18 | 14 | 13 | 23 | 15.8 | 11 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C044 | RPB-44 | UIUE | Accessibility deferred 但不能消失, 双通道只覆盖一部分。 | 15 | 12 | 24 | 18 | 13 | 19 | 16.8 | 12 | P2 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C045 | RPB-45 | UIUE | screenshot anchor 命名含 platform/state/proof/source。 | 21 | 13 | 21 | 17 | 23 | 21 | 19.3 | 10 | P2 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C046 | RPB-46 | Shared | receipt 格式需 command/device/proof/touched/residual。 | 21 | 24 | 21 | 17 | 23 | 21 | 21.2 | 7 | P1 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C047 | RPB-47 | Shared | merge-readiness 标记只能是 contract aligned not merged。 | 15 | 24 | 18 | 24 | 23 | 24 | 21.3 | 9 | P1 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C048 | RPB-48 | Shared | reviewer 必告 live HEAD, no stale SHA。 | 21 | 24 | 19 | 17 | 23 | 21 | 20.8 | 7 | P1 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C049 | RPB-49 | Shared | 未决 P0/P1 carry-forward 必进下个 closeout。 | 20 | 24 | 20 | 17 | 23 | 20 | 20.7 | 7 | P1 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C050 | RPB-50 | Shared | 哪些落 bridge OpenSpec, 哪些留 UIUE notes 需 landing matrix。 | 21 | 24 | 21 | 24 | 23 | 22 | 22.5 | 3 | P0 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C051 | RPB-51 | Mainline | snapshot card 必带 sibling/secondary/active 信息以支持制冷/制热与主值。 | 17 | 24 | 23 | 24 | 18 | 17 | 20.5 | 7 | P1 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C052 | RPB-52 | Mainline | force-state context 输入需 `#if DEMO_MODE` + bridge event + trace provenance。 | 18 | 14 | 20 | 24 | 19 | 23 | 19.7 | 10 | P2 | mainline_first | Rewrite | Rewrite into a single falsifiable assertion with owner, validator, and proof class before dispatch. |
| C053 | RPB-53 | Shared | think 两语义: analyzing 事件驱动与 safety fixed 1s 演出例外。 | 20 | 13 | 19 | 17 | 18 | 18 | 17.5 | 7 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C054 | CE-001 | Mainline | `ToolExecutionError` 到 `DemoRuntimeOutcome` 的完整映射表。 | 14 | 13 | 19 | 24 | 19 | 21 | 18.3 | 11 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C055 | CE-002 | Mainline | `guardDenied` 应细分 safety/refusal/unsupported/runtime_error。 | 19 | 13 | 19 | 17 | 18 | 18 | 17.3 | 6 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C056 | CE-003 | Mainline | `semanticInvalid("missing_default_scope")` 应映射 clarify/missing scope, 不进 Core enum。 | 18 | 14 | 17 | 24 | 18 | 20 | 18.5 | 10 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C057 | CE-004 | Mainline | unsupported 与 safety refusal 必须有不同 reason taxonomy。 | 19 | 13 | 19 | 17 | 18 | 22 | 18.0 | 9 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C058 | CE-005 | Mainline | runtimeError 需分 timeout/decode/store/model/adapter failure。 | 19 | 13 | 20 | 17 | 18 | 22 | 18.2 | 9 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C059 | CE-006 | Mainline | cancellation 与 interruption 的触发源和恢复语义分开。 | 19 | 13 | 23 | 17 | 18 | 19 | 18.2 | 10 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C060 | CE-007 | Mainline | adapter 遇 throw 仍必须发 terminal snapshot, 禁 silent failure。 | 24 | 14 | 24 | 24 | 23 | 23 | 22.0 | 10 | P0 | mainline_first | Keep | Keep as standalone mainline-first burndown gate; require OpenSpec/DTO/test or terminal snapshot evidence. |
| C061 | CE-008 | Mainline | retry/idempotency 规则: 重试不得二次写 state 或吞掉 no-op。 | 20 | 13 | 20 | 18 | 23 | 22 | 19.3 | 10 | P2 | mainline_first | Rewrite | Rewrite into a single falsifiable assertion with owner, validator, and proof class before dispatch. |
| C062 | CE-009 | Mainline | snapshot 禁 raw model output, 只带 presentation-safe outcome。 | 18 | 13 | 24 | 24 | 23 | 24 | 21.0 | 11 | P1 | mainline_first | Keep | Keep as standalone mainline-first burndown gate; require OpenSpec/DTO/test or terminal snapshot evidence. |
| C063 | CE-010 | Mainline | `behaviorClassSource` preservation: accepted 结果保留 `tool_call` 源。 | 15 | 13 | 17 | 24 | 23 | 21 | 18.8 | 11 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C064 | CE-011 | Mainline | accepted terminal snapshot sample 必须存在。 | 19 | 17 | 21 | 17 | 23 | 21 | 19.7 | 6 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C065 | CE-012 | Mainline | clarify/missing-slot terminal snapshot sample 必须存在。 | 19 | 16 | 21 | 17 | 23 | 21 | 19.5 | 7 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C066 | CE-013 | Mainline | unsupported/no-tool terminal snapshot sample 必须存在。 | 19 | 17 | 21 | 17 | 23 | 21 | 19.7 | 6 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C067 | CE-014 | Mainline | safety refusal terminal snapshot sample 必须存在。 | 19 | 17 | 24 | 17 | 23 | 24 | 20.7 | 7 | P1 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C068 | CE-015 | Mainline | already-state terminal snapshot sample 必须存在。 | 19 | 17 | 24 | 17 | 23 | 23 | 20.5 | 7 | P1 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C069 | CE-016 | Mainline | timeout runtimeError terminal snapshot sample 必须存在。 | 19 | 17 | 21 | 17 | 23 | 24 | 20.2 | 7 | P1 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C070 | CE-017 | Mainline | cancelled terminal snapshot sample 必须存在。 | 19 | 16 | 21 | 17 | 23 | 21 | 19.5 | 7 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C071 | CE-018 | Mainline | interrupted/barge-in terminal snapshot sample 必须存在。 | 19 | 17 | 24 | 17 | 23 | 21 | 20.2 | 7 | P1 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C072 | CE-019 | Mainline | partial accept/refuse terminal snapshot sample 必须存在或明确 local-only。 | 19 | 17 | 23 | 17 | 23 | 22 | 20.2 | 6 | P1 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C073 | CE-020 | Mainline | mainline flat `cards` 与 UIUE `activeCells` 如何对齐。 | 17 | 17 | 20 | 24 | 18 | 22 | 19.7 | 7 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C074 | CE-021 | Mainline | siblingCells/mode 信息是否进入 mainline snapshot。 | 17 | 17 | 23 | 24 | 18 | 17 | 19.3 | 7 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C075 | CE-022 | Mainline | refusedCell 是否支持多 refused cells。 | 14 | 16 | 20 | 18 | 18 | 19 | 17.5 | 6 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C076 | CE-023 | Shared | scopeOrigin 是 snapshot-level 还是 per-cell map。 | 17 | 17 | 20 | 24 | 18 | 19 | 19.2 | 7 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C077 | CE-024 | Shared | context(speed/gear/weather/time) 是否进入 shared snapshot 或 effect channel。 | 17 | 17 | 20 | 24 | 19 | 19 | 19.3 | 7 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C078 | CE-025 | Mainline | readbacks 数组顺序和“最后一条为准”规则。 | 17 | 17 | 23 | 24 | 18 | 22 | 20.2 | 7 | P1 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C079 | CE-026 | Mainline | dialogText/readbacks/matrix dialog 的 copy priority。 | 17 | 17 | 23 | 24 | 18 | 19 | 19.7 | 7 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C080 | CE-027 | UIUE | empty cards 合法结果类: clarify/error/cancel 是否可空。 | 19 | 16 | 20 | 17 | 18 | 19 | 18.2 | 4 | P2 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C081 | CE-028 | UIUE | timestamp 是 event time、snapshot time 还是 commit time。 | 17 | 17 | 17 | 24 | 18 | 16 | 18.2 | 8 | P2 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C082 | CE-029 | Spike | `cardsDidStartChanging` 是否进入 event gates。 | 17 | 20 | 17 | 17 | 18 | 19 | 18.0 | 3 | P1 | spike_required | Spike | Run a bounded spike because reviewer disagreement needs runtime/device/model evidence. |
| C083 | CE-030 | Spike | `readbackReady` 是否进入 event gates。 | 17 | 19 | 20 | 17 | 18 | 19 | 18.3 | 3 | P1 | spike_required | Spike | Run a bounded spike because reviewer disagreement needs runtime/device/model evidence. |
| C084 | CE-031 | Mainline | `ttsStart/ttsEnd` 是 effect event 还是 snapshot state。 | 17 | 17 | 20 | 17 | 18 | 19 | 18.0 | 3 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C085 | CE-032 | Mainline | timeout 作为 event/result/terminal snapshot 三层如何对应。 | 19 | 16 | 20 | 24 | 22 | 23 | 20.7 | 8 | P1 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C086 | CE-033 | UIUE | `force_context_state` 是否进 `DemoInteractionEventKind`。 | 14 | 17 | 17 | 24 | 18 | 19 | 18.2 | 10 | P2 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C087 | CE-034 | UIUE | `cardTap` payload 必填 key/family, 缺失 fail-closed。 | 19 | 17 | 24 | 24 | 18 | 20 | 20.3 | 7 | P1 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C088 | CE-035 | UIUE | micStart/micEnd 是否推进 voiceState 或只作 input trace。 | 16 | 17 | 20 | 17 | 18 | 18 | 17.7 | 4 | P2 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C089 | CE-036 | Mainline | background/suspend/resume 对 running turn 的 terminal/cancel 规则。 | 19 | 17 | 23 | 24 | 18 | 23 | 20.7 | 7 | P1 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C090 | CE-037 | Shared | `thinkAnalyzing` 与 `safetyThink` 是否类型化。 | 19 | 16 | 19 | 17 | 18 | 18 | 17.8 | 3 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C091 | CE-038 | Shared | 最小 1s guard 与固定 3s theatre 的边界。 | 19 | 17 | 20 | 17 | 18 | 22 | 18.8 | 5 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C092 | CE-039 | Shared | macro_id 源必须来自 Core, UIUE 不判语义。 | 15 | 17 | 17 | 17 | 19 | 20 | 17.5 | 5 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C093 | CE-040 | Shared | macro narration 用 2 字段, 禁回到三段 fixed calling。 | 15 | 17 | 20 | 17 | 19 | 16 | 17.3 | 5 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C094 | CE-041 | Shared | orbState 与 voiceState 冲突裁决。 | 16 | 17 | 24 | 17 | 18 | 23 | 19.2 | 8 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C095 | CE-042 | Shared | Reduce Motion 每态非动画等价物证明。 | 14 | 16 | 23 | 17 | 18 | 20 | 18.0 | 9 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C096 | CE-043 | Spike | shader/GPU budget 与 MLX runtime 抢资源的门。 | 17 | 13 | 20 | 18 | 16 | 19 | 17.2 | 7 | P1 | spike_required | Spike | Run a bounded spike because reviewer disagreement needs runtime/device/model evidence. |
| C097 | CE-044 | Mainline | mainline/UIUE proof class crosswalk。 | 20 | 17 | 20 | 24 | 23 | 24 | 21.3 | 7 | P1 | mainline_first | Keep | Keep as standalone mainline-first burndown gate; require OpenSpec/DTO/test or terminal snapshot evidence. |
| C098 | CE-045 | Shared | result enum crosswalk, 尤其 UIUE partial 与 mainline absence。 | 17 | 17 | 20 | 24 | 18 | 22 | 19.7 | 7 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C099 | CE-046 | Mainline | `scopeOrigin=nil` 的合法边界。 | 17 | 17 | 17 | 24 | 18 | 23 | 19.3 | 7 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C100 | CE-047 | Shared | string key migration proof for `scopeOrigins/activeCells`。 | 20 | 16 | 20 | 24 | 18 | 20 | 19.7 | 8 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C101 | CE-048 | Mainline | adapter fixture golden cases 覆盖 8 类结果。 | 19 | 17 | 21 | 17 | 23 | 24 | 20.2 | 7 | P1 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C102 | CE-049 | Shared | “runtime-driven orb” 在无 runtime logs 前改名 fixture-driven。 | 15 | 17 | 22 | 17 | 19 | 24 | 19.0 | 9 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C103 | CE-050 | Shared | matrix entry proof 与 snapshot proof 的覆盖优先级。 | 20 | 17 | 20 | 17 | 19 | 19 | 18.7 | 3 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C104 | CE-051 | Shared | UIUE 禁在 mainline verdict 前新增 shared field。 | 22 | 17 | 18 | 24 | 19 | 24 | 20.7 | 7 | P1 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C105 | CE-052 | Mainline | proof ladder: docs/static/unit/simulator/operator/true-device/live。 | 20 | 24 | 24 | 24 | 23 | 24 | 23.2 | 4 | P0 | mainline_first | Keep | Keep as standalone mainline-first burndown gate; require OpenSpec/DTO/test or terminal snapshot evidence. |
| C106 | CE-053 | Shared | screenshot anchor no-promotion machine guard。 | 19 | 24 | 24 | 24 | 23 | 24 | 23.0 | 5 | P0 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C107 | CE-054 | Shared | R5 receipt 必带 non-claims checkbox。 | 20 | 24 | 22 | 17 | 23 | 24 | 21.7 | 7 | P1 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C108 | CE-055 | Shared | validation gate 按 touched paths 切换。 | 20 | 24 | 20 | 17 | 23 | 20 | 20.7 | 7 | P1 | parallel_with_guard | Rewrite | Rewrite into a single falsifiable assertion with owner, validator, and proof class before dispatch. |
| C109 | CE-056 | Shared | stale wording grep 必查 `R5_PRECONDITIONS_BLOCKED/not_proposed/missing`。 | 15 | 24 | 18 | 17 | 23 | 21 | 19.7 | 9 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C110 | CE-057 | Shared | 双 repo dirty status 分开记录, 不混提交。 | 19 | 24 | 19 | 24 | 23 | 21 | 21.7 | 5 | P1 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C111 | CE-058 | Shared | mainline/UIUE OpenSpec strict 各跑各的。 | 20 | 24 | 17 | 24 | 23 | 21 | 21.5 | 7 | P1 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C112 | CE-059 | FutureLane | raw ASR 只能 trace, 不作 memory/training/golden authority。 | 16 | 12 | 20 | 14 | 13 | 23 | 16.3 | 11 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C113 | CE-060 | Shared | normalizer confidence gate 决定是否 update focus。 | 14 | 13 | 20 | 17 | 13 | 19 | 16.0 | 7 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C114 | CE-061 | Mainline | TTS/UX committed 后才写 assistant context。 | 16 | 13 | 23 | 17 | 13 | 22 | 17.3 | 10 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C115 | CE-062 | Mainline | barge-in 后禁止未播出文本进入下一轮事实。 | 14 | 24 | 23 | 17 | 13 | 23 | 19.0 | 11 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C116 | CE-063 | Mainline | TTS 与录音会话串行互斥。 | 16 | 24 | 23 | 17 | 13 | 23 | 19.3 | 11 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C117 | CE-064 | Spike | premium 普通话 voice preflight 与 fallback。 | 19 | 13 | 20 | 14 | 16 | 19 | 16.8 | 7 | P1 | spike_required | Spike | Run a bounded spike because reviewer disagreement needs runtime/device/model evidence. |
| C118 | CE-065 | Shared | voiceState `unavailable` 与 `idle` 区分。 | 16 | 12 | 24 | 17 | 13 | 20 | 17.0 | 12 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C119 | CE-066 | Shared | PTT/tap/hold 语义与 MicDock 文案一致。 | 14 | 13 | 24 | 17 | 13 | 20 | 16.8 | 11 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C120 | CE-067 | FutureLane | golden step runtime_mounted + state_cells + whitelist digest precheck。 | 21 | 13 | 17 | 14 | 23 | 24 | 18.7 | 11 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C121 | CE-068 | FutureLane | golden replay 校验 revision delta/no-delta + readback_ok。 | 17 | 12 | 17 | 14 | 23 | 24 | 17.8 | 12 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C122 | CE-069 | FutureLane | golden/script/storyboard 文案禁直接进 C5 train/dev/test。 | 16 | 12 | 18 | 14 | 21 | 23 | 17.3 | 11 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C123 | CE-070 | FutureLane | C6 shape replay 与 model-quality proof 分离。 | 22 | 13 | 15 | 15 | 21 | 23 | 18.2 | 10 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C124 | CE-071 | FutureLane | Qwen sampling 按 behavior class 拆测, 不看 aggregate。 | 18 | 12 | 14 | 14 | 16 | 19 | 15.5 | 7 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C125 | CE-072 | FutureLane | KV prewarm 绑定 prompt/state hash, stale cache 不算 warm pass。 | 16 | 12 | 16 | 14 | 16 | 19 | 15.5 | 7 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C126 | CE-073 | Shared | Liquid4All H5 fullState/functions.json 禁当 MAformac SSOT。 | 16 | 24 | 15 | 20 | 10 | 20 | 17.5 | 14 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C127 | CE-074 | MergeDrop | `/ws-audio` 只作 local runtime teardown 灵感。 | 16 | 12 | 15 | 14 | 10 | 13 | 13.3 | 6 | P3 | reject_duplicate | Drop | Drop as duplicate/low-leverage only after linked merge target is present. |
| C128 | CE-075 | Shared | 外部 code/asset/license transfer 前置 provenance checklist。 | 14 | 24 | 18 | 14 | 10 | 23 | 17.2 | 14 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C129 | CE-076 | Shared | 外部 issue/bug 只能启发 premortem, 不能替代 local proof。 | 20 | 24 | 15 | 15 | 10 | 17 | 16.8 | 14 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C130 | CE-077 | Shared | display-only direct touch 必有 disabled/read-only affordance。 | 14 | 24 | 25 | 17 | 14 | 23 | 19.5 | 11 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C131 | CE-078 | Shared | summary direct-control policy: 展示、跳转、guard 后控制三选一。 | 20 | 13 | 24 | 17 | 14 | 22 | 18.3 | 11 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C132 | CE-079 | Shared | gear direct-touch safety policy: 默认 display-only unless approved。 | 19 | 14 | 25 | 17 | 14 | 23 | 18.7 | 11 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C133 | CE-080 | FutureLane | 44pt/VoiceOver/mobile/true-device proof ladder 单独 lane。 | 20 | 12 | 25 | 15 | 13 | 24 | 18.2 | 13 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C134 | CE-081 | HumanReview | white-edge threshold 保留 WARN 或 formalize, 禁偷写 PASS。 | 14 | 13 | 22 | 13 | 14 | 17 | 15.5 | 9 | P1 | human_review | DeferHuman | Move to human/product review checklist; do not encode as implementation truth before decision. |
| C135 | CE-082 | HumanReview | capsule final-art 是 human/product visual lane, 不阻塞 R5 dispatch。 | 16 | 13 | 18 | 13 | 14 | 16 | 15.0 | 5 | P1 | human_review | DeferHuman | Move to human/product review checklist; do not encode as implementation truth before decision. |
| C136 | MC-001 | Mainline | `DemoRuntimeOutcome.reason / missingSlot / scopeFailureReason` 的优先级和互斥规则。 | 17 | 14 | 16 | 24 | 22 | 19 | 18.7 | 10 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C137 | MC-002 | Mainline | `behaviorClassSource` 在 accepted 和 non-accepted 结果中的填充规则。 | 14 | 24 | 16 | 24 | 18 | 20 | 19.3 | 10 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C138 | MC-003 | Mainline | `isTerminal` 由结果类派生还是 runtime adapter 显式写入。 | 19 | 24 | 20 | 24 | 18 | 23 | 21.3 | 6 | P1 | mainline_first | Keep | Keep as standalone mainline-first burndown gate; require OpenSpec/DTO/test or terminal snapshot evidence. |
| C139 | MC-004 | Mainline | `cards` 允许空数组的结果类和 UI empty-state 策略。 | 14 | 24 | 19 | 17 | 18 | 19 | 18.5 | 10 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C140 | MC-005 | Mainline | `readbacks` 的顺序规则: 时间、卡片、最后一条为准。 | 17 | 16 | 22 | 24 | 18 | 21 | 19.7 | 8 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C141 | MC-006 | Mainline | `dialogText` 与 `readbacks` 的 canonical human copy 裁决。 | 17 | 17 | 22 | 24 | 18 | 18 | 19.3 | 7 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C142 | MC-007 | Mainline | `TraceEnvelope.traceID` 与 snapshot `traceID` 是否必须一致。 | 17 | 13 | 17 | 24 | 22 | 20 | 18.8 | 11 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C143 | MC-008 | Mainline | `TraceEnvelope.entries` append-only 与阶段/时间单调性。 | 17 | 24 | 17 | 24 | 22 | 20 | 20.7 | 7 | P1 | mainline_first | Keep | Keep as standalone mainline-first burndown gate; require OpenSpec/DTO/test or terminal snapshot evidence. |
| C144 | MC-009 | Mainline | snapshot `timestamp` 的时钟源和语义。 | 17 | 24 | 16 | 24 | 22 | 15 | 19.7 | 9 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C145 | MC-010 | Mainline | `cancel` 与 `interruption` 的触发源、结果和恢复语义。 | 19 | 13 | 22 | 17 | 22 | 22 | 19.2 | 9 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C146 | MC-011 | Mainline | `cardTap` 是否必须携带 `cardKey`, 缺失如何 fail-closed。 | 19 | 13 | 23 | 17 | 18 | 19 | 18.2 | 10 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C147 | MC-012 | Mainline | `micStart/micEnd` 是输入事件还是必须驱动 voiceState。 | 16 | 13 | 19 | 17 | 18 | 17 | 16.7 | 6 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C148 | MC-013 | Mainline | `voiceState` 与 `orbState` 同时非空时的主显示源和冲突裁决。 | 16 | 14 | 23 | 17 | 18 | 22 | 18.3 | 9 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C149 | MC-014 | Mainline | `PresentationProofClass.displayCaps` 永远空是永久合同还是临时保守值。 | 14 | 13 | 20 | 24 | 18 | 24 | 18.8 | 11 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C150 | MC-015 | Mainline | 未知 `PresentationProofClass` JSON 是否所有 consumer 都 fail-closed。 | 19 | 13 | 21 | 24 | 23 | 24 | 20.7 | 11 | P1 | mainline_first | Rewrite | Rewrite into a single falsifiable assertion with owner, validator, and proof class before dispatch. |
| C151 | MC-016 | Mainline | `PresentationReadinessClaim` 是 shared API 还是未来占位符。 | 14 | 13 | 16 | 24 | 19 | 20 | 17.7 | 11 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C152 | MC-017 | Mainline | snapshot `scopeFailureReason` 与 outcome `scopeFailureReason` 是否镜像。 | 17 | 14 | 20 | 24 | 18 | 19 | 18.7 | 10 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C153 | MC-018 | Mainline | `scopeOrigin=nil` 的合法边界, 禁把 nil 当 defaulted。 | 17 | 17 | 16 | 24 | 18 | 21 | 18.8 | 8 | P2 | mainline_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C154 | UC-001 | UIUE | UIUE proof enum 与 mainline proof enum 的 crosswalk。 | 20 | 13 | 20 | 24 | 22 | 22 | 20.2 | 11 | P1 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C155 | UC-002 | HumanReview | `operatorReview` 能否出现在产品界面, 且不得等于 acceptance。 | 14 | 24 | 25 | 13 | 20 | 23 | 19.8 | 12 | P1 | human_review | DeferHuman | Move to human/product review checklist; do not encode as implementation truth before decision. |
| C156 | UC-003 | UIUE | UIUE matrix entry proof 与 snapshot proof 的优先级。 | 20 | 14 | 19 | 24 | 18 | 18 | 18.8 | 10 | P2 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C157 | UC-004 | UIUE | partial accept/refuse 需 accepted/refused per-cell payload 后才做复杂混合 outcome。 | 14 | 13 | 23 | 24 | 23 | 22 | 19.8 | 11 | P2 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C158 | UC-005 | UIUE | `dialogText/readbacks/matrix dialogText` 冲突时 UI/TTS/VO 的来源优先级。 | 17 | 13 | 22 | 24 | 18 | 18 | 18.7 | 11 | P2 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C159 | UC-006 | UIUE | already-state 与 accepted 都 satisfied 时 a11y/readback 必须区分。 | 17 | 13 | 25 | 17 | 16 | 23 | 18.5 | 12 | P2 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C160 | UC-007 | HumanReview | card `accessibilityLabel` 是否包含 scope/reason/proof/read-only。 | 20 | 14 | 25 | 15 | 14 | 20 | 18.0 | 11 | P1 | human_review | DeferHuman | Move to human/product review checklist; do not encode as implementation truth before decision. |
| C161 | UC-008 | HumanReview | `ValueControlView` direct controls 的 a11y value/hint/range。 | 14 | 13 | 25 | 13 | 14 | 20 | 16.5 | 12 | P1 | human_review | DeferHuman | Move to human/product review checklist; do not encode as implementation truth before decision. |
| C162 | UC-009 | HumanReview | MicDock button tap 与“按住说话”文案的语义错配。 | 14 | 13 | 25 | 13 | 14 | 21 | 16.7 | 12 | P1 | human_review | DeferHuman | Move to human/product review checklist; do not encode as implementation truth before decision. |
| C163 | UC-010 | HumanReview | context capsule a11y 是否读出速度/天气/挡位。 | 14 | 13 | 22 | 13 | 14 | 17 | 15.5 | 9 | P1 | human_review | DeferHuman | Move to human/product review checklist; do not encode as implementation truth before decision. |
| C164 | UC-011 | HumanReview | expanded overlay 的 escape action、button trait 与 focus return。 | 14 | 24 | 25 | 13 | 14 | 20 | 18.3 | 12 | P1 | human_review | DeferHuman | Move to human/product review checklist; do not encode as implementation truth before decision. |
| C165 | UC-012 | UIUE | cancel/cancelled 映射 normal 后保留 terminal proof 和 announcement。 | 20 | 13 | 23 | 17 | 22 | 20 | 19.2 | 10 | P2 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C166 | UC-013 | UIUE | runtimeError 区分 timeout/adapter/presentation fixture failure。 | 19 | 17 | 19 | 17 | 22 | 22 | 19.3 | 5 | P2 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C167 | UC-014 | UIUE | Reduced Motion policy 是否有非动画 UI proof fixture。 | 20 | 13 | 23 | 17 | 17 | 19 | 18.2 | 10 | P2 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C168 | UC-015 | UIUE | string-key `scopeOrigins` 改名后如何避免静默错配。 | 17 | 14 | 19 | 24 | 17 | 19 | 18.3 | 10 | P2 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C169 | UC-016 | UIUE | `activeCells` 多 active/mixed outcome 的顺序、主次、focus priority。 | 17 | 13 | 25 | 24 | 17 | 23 | 19.8 | 12 | P2 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C170 | UC-017 | UIUE | U15 counterexample fixture 补 already-state/runtime-error/cancelled。 | 19 | 16 | 21 | 17 | 22 | 21 | 19.3 | 6 | P2 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C171 | UC-018 | UIUE | screenshot anchor proof-class 命名后禁被引用为 runtime/mobile proof。 | 25 | 13 | 23 | 17 | 22 | 23 | 20.5 | 12 | P1 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C172 | UC-019 | HumanReview | display-only summary/gear 需要 disabled affordance 和 a11y “仅展示”。 | 14 | 14 | 24 | 13 | 14 | 22 | 16.8 | 11 | P1 | human_review | DeferHuman | Move to human/product review checklist; do not encode as implementation truth before decision. |
| C173 | UC-020 | HumanReview | a11y proof ladder 区分 local/static/simulator/true-device。 | 20 | 24 | 23 | 15 | 20 | 23 | 20.8 | 9 | P1 | human_review | DeferHuman | Move to human/product review checklist; do not encode as implementation truth before decision. |
| C174 | UC-021 | UIUE | safety refusal 中 orbState think 与 matrix tts speaking 的 lifecycle。 | 19 | 13 | 24 | 17 | 17 | 22 | 18.7 | 11 | P2 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C175 | UC-022 | UIUE | mock voice state contradiction: orb speak + voice idle 要标非真实 TTS。 | 16 | 13 | 24 | 17 | 17 | 23 | 18.3 | 11 | P2 | uiue_first | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C176 | PV-001 | Shared | `ToolExecutionError` 到 outcome 的完整分类, 尤其 guardDenied。 | 19 | 17 | 15 | 24 | 22 | 22 | 19.8 | 9 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C177 | PV-002 | Shared | 每个 terminal outcome 都要 sample terminal snapshot fixture。 | 19 | 17 | 19 | 17 | 22 | 24 | 19.7 | 7 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C178 | PV-003 | Shared | mainline 缺 partial, UIUE 已有 partial, 是否 canonical 或 local-only。 | 17 | 12 | 19 | 24 | 18 | 23 | 18.8 | 12 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C179 | PV-004 | Shared | proof enum 必须 translation, 禁 raw value 直传。 | 20 | 13 | 21 | 24 | 18 | 24 | 20.0 | 11 | P1 | parallel_with_guard | Rewrite | Rewrite into a single falsifiable assertion with owner, validator, and proof class before dispatch. |
| C180 | PV-005 | Shared | `displayCaps` 永远空还是未来可打开, 谁开。 | 14 | 16 | 19 | 24 | 18 | 18 | 18.2 | 10 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C181 | PV-006 | Shared | think 两语义是否需要两个 enum/state。 | 17 | 17 | 18 | 17 | 18 | 17 | 17.3 | 1 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C182 | PV-007 | Spike | `cards_did_start_changing/readback_ready/tts_start/tts_end` 是否进 event kind。 | 17 | 20 | 19 | 24 | 18 | 18 | 19.3 | 7 | P1 | spike_required | Spike | Run a bounded spike because reviewer disagreement needs runtime/device/model evidence. |
| C183 | PV-008 | Shared | `force_context_state` 必须 demo-mode 隔离和 trace provenance。 | 14 | 17 | 19 | 24 | 18 | 22 | 19.0 | 10 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C184 | PV-009 | Shared | `activeCell/siblingCells` 在 mainline snapshot 的表达方式。 | 17 | 17 | 22 | 24 | 18 | 18 | 19.3 | 7 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C185 | PV-010 | Shared | already-state 证明 no revision bump、ack/readback、非 accepted delta。 | 17 | 13 | 24 | 24 | 23 | 24 | 20.8 | 11 | P1 | parallel_with_guard | Rewrite | Rewrite into a single falsifiable assertion with owner, validator, and proof class before dispatch. |
| C186 | PV-011 | Shared | cancel/interruption 后禁止 stale async mutate cards。 | 19 | 13 | 24 | 24 | 23 | 23 | 21.0 | 11 | P1 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C187 | PV-012 | Shared | terminal snapshot 覆盖 `isTerminal=false -> true` 唯一合法转移。 | 20 | 13 | 25 | 24 | 23 | 24 | 21.5 | 12 | P1 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C188 | PV-013 | Shared | “runtime-driven orb binding” 在无 runtime logs 前只能叫 fixture-driven。 | 14 | 17 | 21 | 17 | 18 | 22 | 18.2 | 8 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C189 | PV-014 | Shared | C5/C6/golden/voice proof lane 独立 checkbox 禁互相替代。 | 25 | 13 | 24 | 24 | 22 | 24 | 22.0 | 12 | P0 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C190 | PV-015 | FutureLane | C6 acceptance/comparison 何时才从 bridge work 解冻。 | 19 | 12 | 16 | 14 | 13 | 19 | 15.5 | 7 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C191 | PV-016 | FutureLane | voice lane 首 gate 是功能坑 spike, 不是 UIUE voiceState。 | 18 | 12 | 20 | 18 | 13 | 23 | 17.3 | 11 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C192 | PV-017 | Shared | Liquid4All reject direct copy checklist。 | 14 | 24 | 14 | 17 | 14 | 19 | 17.0 | 10 | P2 | parallel_with_guard | Merge | Merge into nearest canonical cluster; preserve original ID in audit trail and burndown notes. |
| C193 | PV-018 | Shared | L0/L1/L2/L3 visual proof 绑定 proof-class cap, L1/L2 不关闭 L3。 | 20 | 13 | 25 | 17 | 23 | 24 | 20.3 | 12 | P1 | parallel_with_guard | Rewrite | Rewrite into a single falsifiable assertion with owner, validator, and proof class before dispatch. |
| C194 | PV-019 | HumanReview | summary/gear direct touch 前先定义 disabled/safety/readback/a11y policy。 | 19 | 17 | 23 | 13 | 14 | 22 | 18.0 | 10 | P1 | human_review | DeferHuman | Move to human/product review checklist; do not encode as implementation truth before decision. |
| C195 | PV-020 | Shared | R5 closeout hard gate: mainline dirty residual 与 UIUE clean 分开记录。 | 24 | 13 | 19 | 24 | 23 | 21 | 20.7 | 11 | P1 | parallel_with_guard | Keep | Keep as shared governance gate; close only with both route/proof wording and stale-claim grep. |
| C196 | PV-021 | Shared | docs-only vs Swift/UI touched 的 validation gate 每 lane 明确。 | 20 | 14 | 20 | 24 | 23 | 20 | 20.2 | 10 | P1 | parallel_with_guard | Rewrite | Rewrite into a single falsifiable assertion with owner, validator, and proof class before dispatch. |
| C197 | PV-022 | Spike | C3 parser fallback/repair 是否进 runtime adapter error feedback strategy。 | 22 | 12 | 16 | 14 | 16 | 19 | 16.5 | 10 | P1 | spike_required | Spike | Run a bounded spike because reviewer disagreement needs runtime/device/model evidence. |
| C198 | MVG-001 | FutureLane | golden step 进入前校验 runtime_mounted、required_state_cells、whitelist digest。 | 21 | 17 | 16 | 14 | 22 | 22 | 18.7 | 8 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C199 | MVG-002 | FutureLane | golden replay 断言 state_revision before/after、readback_ok、no unexpected delta。 | 22 | 17 | 16 | 14 | 22 | 22 | 18.8 | 8 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C200 | MVG-003 | FutureLane | already_state_noop 进入 C6/golden 样本, 不算 success_with_delta。 | 16 | 16 | 24 | 17 | 22 | 24 | 19.8 | 8 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C201 | MVG-004 | FutureLane | partial accept/refuse readback 逐 cell 列 accepted/refused。 | 17 | 17 | 23 | 24 | 22 | 23 | 21.0 | 7 | P1 | future_lane | Keep | Keep with route-specific proof gate. |
| C202 | MVG-005 | FutureLane | voice memory 7 seeds 升级为正式 C6/golden seeds 或明确 deferred。 | 18 | 12 | 16 | 14 | 13 | 19 | 15.3 | 7 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C203 | MVG-006 | FutureLane | assistant context commit 等 TTS/UX committed, barge-in 后不写下一轮焦点。 | 16 | 17 | 22 | 17 | 17 | 22 | 18.5 | 6 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C204 | MVG-007 | FutureLane | raw ASR 只进 trace, train/memory/golden label 用 normalizer output。 | 21 | 14 | 19 | 14 | 17 | 22 | 17.8 | 8 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C205 | MVG-008 | FutureLane | low-confidence ASR no-focus-update fixture, 禁 UIUE mock transcript 证明 voice-ready。 | 25 | 13 | 23 | 14 | 22 | 23 | 20.0 | 12 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C206 | MVG-009 | FutureLane | TTS 与录音会话互斥进入 voice state machine 测试。 | 16 | 17 | 22 | 14 | 22 | 22 | 18.8 | 8 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C207 | MVG-010 | Spike | endpoint decode parity 统计 toolCall/content JSON/parser_repair/false tool call 分布。 | 22 | 13 | 14 | 18 | 16 | 19 | 17.0 | 9 | P1 | spike_required | Spike | Run a bounded spike because reviewer disagreement needs runtime/device/model evidence. |
| C208 | MVG-011 | Spike | Mac dev Outlines/XGrammar fixture 标 dev_only, 禁当 iOS proof。 | 23 | 17 | 18 | 20 | 21 | 20 | 19.8 | 6 | P1 | spike_required | Spike | Run a bounded spike because reviewer disagreement needs runtime/device/model evidence. |
| C209 | MVG-012 | FutureLane | Qwen sampling 按 behavior class 拆测 temp0.6 vs 0.1。 | 18 | 12 | 13 | 14 | 16 | 18 | 15.2 | 6 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C210 | MVG-013 | FutureLane | KV prewarm 绑定 prompt/state hash, stale cache 不算 warm-path pass。 | 16 | 16 | 15 | 14 | 16 | 18 | 15.8 | 4 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C211 | MVG-014 | FutureLane | golden/script 文案禁直接进 C5 train/dev/test, 除非 data contract。 | 16 | 13 | 17 | 14 | 13 | 21 | 15.7 | 8 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C212 | MVG-015 | FutureLane | scene macro 带 `planned_not_golden`, golden upgrade 单独签。 | 18 | 14 | 18 | 14 | 13 | 20 | 16.2 | 7 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |
| C213 | MVG-016 | FutureLane | UIUE local fixture proofClass unknown/缺失时 fail-closed。 | 25 | 13 | 24 | 24 | 23 | 24 | 22.2 | 12 | P1 | future_lane | Keep | Keep with route-specific proof gate. |
| C214 | MVG-017 | FutureLane | terminal snapshot 包含 timeout/cancel/interrupted finality 防 stale async mutate。 | 19 | 17 | 24 | 24 | 22 | 24 | 21.7 | 7 | P1 | future_lane | Keep | Keep with route-specific proof gate. |
| C215 | MVG-018 | FutureLane | C6/golden 区分 local_shape_no_model replay 与 model_quality。 | 16 | 13 | 18 | 24 | 21 | 22 | 19.0 | 11 | P2 | future_lane | DeferFutureLane | Defer to future lane; retain as non-claim guard, not an R5 dispatch blocker. |

## Divergence Routing

| Candidate | Original | Scores | Spread | Dispute type | Final route |
|---|---|---|---:|---|---|
| C126 | CE-073 | [16, 24, 15, 20, 10, 20] | 14 | 混合 | parallel_with_guard / Merge |
| C128 | CE-075 | [14, 24, 18, 14, 10, 23] | 14 | 混合 | parallel_with_guard / Merge |
| C129 | CE-076 | [20, 24, 15, 15, 10, 17] | 14 | 混合 | parallel_with_guard / Merge |
| C025 | RPB-25 | [25, 12, 24, 24, 23, 24] | 13 | 混合 | parallel_with_guard / Keep |
| C023 | RPB-23 | [25, 12, 23, 24, 19, 23] | 13 | 混合 | mainline_first / Keep |
| C133 | CE-080 | [20, 12, 25, 15, 13, 24] | 13 | 混合 | future_lane / DeferFutureLane |
| C213 | MVG-016 | [25, 13, 24, 24, 23, 24] | 12 | 事实型 | future_lane / Keep |
| C189 | PV-014 | [25, 13, 24, 24, 22, 24] | 12 | 事实型 | parallel_with_guard / Keep |
| C187 | PV-012 | [20, 13, 25, 24, 23, 24] | 12 | 事实型 | parallel_with_guard / Keep |
| C171 | UC-018 | [25, 13, 23, 17, 22, 23] | 12 | 混合 | uiue_first / Merge |
| C193 | PV-018 | [20, 13, 25, 17, 23, 24] | 12 | 口径型 | parallel_with_guard / Rewrite |
| C205 | MVG-008 | [25, 13, 23, 14, 22, 23] | 12 | 混合 | future_lane / DeferFutureLane |
| C155 | UC-002 | [14, 24, 25, 13, 20, 23] | 12 | 事实型 | human_review / DeferHuman |
| C169 | UC-016 | [17, 13, 25, 24, 17, 23] | 12 | 口径型 | uiue_first / Merge |
| C178 | PV-003 | [17, 12, 19, 24, 18, 23] | 12 | 混合 | parallel_with_guard / Merge |
| C011 | RPB-11 | [15, 13, 25, 17, 19, 22] | 12 | 口径型 | parallel_with_guard / Merge |
| C159 | UC-006 | [17, 13, 25, 17, 16, 23] | 12 | 口径型 | uiue_first / Merge |
| C164 | UC-011 | [14, 24, 25, 13, 14, 20] | 12 | 事实型 | human_review / DeferHuman |
| C121 | CE-068 | [17, 12, 17, 14, 23, 24] | 12 | 混合 | future_lane / DeferFutureLane |
| C118 | CE-065 | [16, 12, 24, 17, 13, 20] | 12 | 混合 | parallel_with_guard / Merge |
| C044 | RPB-44 | [15, 12, 24, 18, 13, 19] | 12 | 混合 | uiue_first / Merge |
| C162 | UC-009 | [14, 13, 25, 13, 14, 21] | 12 | 事实型 | human_review / DeferHuman |
| C161 | UC-008 | [14, 13, 25, 13, 14, 20] | 12 | 事实型 | human_review / DeferHuman |
| C036 | RPB-36 | [24, 13, 24, 24, 23, 24] | 11 | 混合 | parallel_with_guard / Keep |
| C062 | CE-009 | [18, 13, 24, 24, 23, 24] | 11 | 事实型 | mainline_first / Keep |
| C186 | PV-011 | [19, 13, 24, 24, 23, 23] | 11 | 事实型 | parallel_with_guard / Keep |
| C185 | PV-010 | [17, 13, 24, 24, 23, 24] | 11 | 口径型 | parallel_with_guard / Rewrite |
| C150 | MC-015 | [19, 13, 21, 24, 23, 24] | 11 | 口径型 | mainline_first / Rewrite |
| C195 | PV-020 | [24, 13, 19, 24, 23, 21] | 11 | 事实型 | parallel_with_guard / Keep |
| C154 | UC-001 | [20, 13, 20, 24, 22, 22] | 11 | 口径型 | uiue_first / Merge |
| C179 | PV-004 | [20, 13, 21, 24, 18, 24] | 11 | 口径型 | parallel_with_guard / Rewrite |
| C157 | UC-004 | [14, 13, 23, 24, 23, 22] | 11 | 口径型 | uiue_first / Merge |
| C130 | CE-077 | [14, 24, 25, 17, 14, 23] | 11 | 口径型 | parallel_with_guard / Merge |
| C116 | CE-063 | [16, 24, 23, 17, 13, 23] | 11 | 混合 | mainline_first / Merge |
| C115 | CE-062 | [14, 24, 23, 17, 13, 23] | 11 | 混合 | mainline_first / Merge |
| C215 | MVG-018 | [16, 13, 18, 24, 21, 22] | 11 | 混合 | future_lane / DeferFutureLane |
| C063 | CE-010 | [15, 13, 17, 24, 23, 21] | 11 | 口径型 | mainline_first / Merge |
| C142 | MC-007 | [17, 13, 17, 24, 22, 20] | 11 | 口径型 | mainline_first / Merge |
| C149 | MC-014 | [14, 13, 20, 24, 18, 24] | 11 | 口径型 | mainline_first / Merge |
| C120 | CE-067 | [21, 13, 17, 14, 23, 24] | 11 | 混合 | future_lane / DeferFutureLane |

## Reviewer Replacement Log

| Round | Slot | Failed agent | Reason | Replacement | Final status |
|---|---|---|---|---|---|
| round-01 | RED failure auditor | Harvey `019f0ca3-0f2c-7b92-b04c-3e37ed70c72d` | read-only, no file | Popper `019f0cab-2729-7de3-a890-76784af46d07` | valid 215/215 |
| round-02 | PURPLE systems architect | Ptolemy `019f0cb0-5a74-7dc1-91cd-0acc635ead93` | read-only, no file | Herschel `019f0cb4-bcdf-7212-a15e-0e47e1d3c99d` | valid 215/215 |

## Non-Claims

This matrix is a burndown input only. It does not claim runtime-ready, mobile, true_device, voice-ready, model-ready, golden-ready, endpoint-ready, UIUE merge, V-PASS, S-PASS, U-PASS, or A-2 complete.

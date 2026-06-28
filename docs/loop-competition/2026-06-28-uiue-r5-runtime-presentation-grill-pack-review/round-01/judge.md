# Judge - Round 01

## Inputs

- Round: `round-01`
- Valid reviewer files:
  - `round-01/brain-1.md` RED failure auditor replacement (`Popper`)
  - `round-01/brain-2.md` GREEN implementation coordinator (`Wegener`)
  - `round-01/brain-3.md` BLUE UX/HMI designer (`Archimedes`)
- Failed reviewer recorded: original RED reviewer `Harvey` returned BLOCKED/read-only and did not write `brain-1.md`; replaced before judging.
- Candidate count: `215` fixed blind candidates.
- Proof class: `docs/local + subagent_readonly + controller_judge`.

## Completion Gate

| File | Scores rows | Candidate Notes rows | Gate |
|---|---:|---:|---|
| `brain-1.md` | 215 | 215 | PASS |
| `brain-2.md` | 215 | 215 | PASS |
| `brain-3.md` | 215 | 215 | PASS |

## Round 01 Synthesis

- RED aggressively merged proof/non-claim/terminal-state duplicates; useful as burndown compression pressure, not as deletion authority.
- GREEN highlighted executable contract/test/commit gates and found large duplicate fixture-matrix clusters.
- BLUE treated user-visible终态、a11y、direct-touch policy、proof-cap copy as higher-risk than implementation-only lenses.
- Judge ruling: keep all 215 in the audit trail for now, but Round 2 should focus on whether duplicates become `merge_only`, `future_lane`, or true standalone workstreams.

## Priority / Action / Route Counts

| Type | Count |
|---|---:|
| priority P0 | 15 |
| priority P1 | 74 |
| priority P2 | 126 |
| action DeferFutureLane | 29 |
| action Keep | 46 |
| action Merge | 66 |
| action Merge/Defer | 30 |
| action Rewrite | 10 |
| action Rewrite/Merge | 33 |
| action Spike | 1 |
| route future_lane | 29 |
| route mainline_first | 74 |
| route parallel_with_guard | 82 |
| route uiue_first | 30 |

## Candidate Scores

| Candidate | Original | Question | RED | GREEN | BLUE | Avg | Spread | Priority | Route | Provisional action |
|---|---|---|---:|---:|---:|---:|---:|---|---|---|
| C001 | RPB-01 | 边界 override 只能是 snapshot consume + bridge event write, 不能自由 mutate store。 | 22 | 24 | 20 | 22.0 | 4 | P0 | parallel_with_guard | Keep |
| C002 | RPB-02 | 三车道分类: UIUE local, shared bridge, mainline runtime。 | 22 | 24 | 22 | 22.7 | 2 | P0 | parallel_with_guard | Keep |
| C003 | RPB-03 | bridge 4 名和字段名必须由 mainline carrier/DTO 锁定。 | 22 | 24 | 18 | 21.3 | 6 | P1 | mainline_first | Keep |
| C004 | RPB-04 | store ownership: presentation 消费 snapshot, 不读 raw runtime store。 | 17 | 24 | 22 | 21.0 | 7 | P1 | parallel_with_guard | Keep |
| C005 | RPB-05 | 写所有权: 触摸/事件走 executor 或 runtime adapter, 不直接写 store。 | 19 | 24 | 20 | 21.0 | 5 | P1 | mainline_first | Keep |
| C006 | RPB-06 | 事件集必须封闭, 包含 text/mic/card/cancel/interruption/timeout 等。 | 20 | 24 | 20 | 21.3 | 4 | P1 | mainline_first | Keep |
| C007 | RPB-07 | 事件 payload 必须区分 source/provenance 与 scope_origin/resolution。 | 18 | 24 | 19 | 20.3 | 6 | P1 | parallel_with_guard | Keep |
| C008 | RPB-08 | scope 展示读结构化字段, UI/TTS 禁从中文推断 scope。 | 22 | 24 | 24 | 23.3 | 2 | P0 | parallel_with_guard | Keep |
| C009 | RPB-09 | Runtime result enum 保持机器可读, 不用裸 rejected。 | 22 | 24 | 17 | 21.0 | 7 | P1 | mainline_first | Keep |
| C010 | RPB-10 | 拒识词表要区分 unsupported/safety/clarify/already-state/runtime-error。 | 24 | 24 | 20 | 22.7 | 4 | P0 | mainline_first | Keep |
| C011 | RPB-11 | 视觉映射为结果到 7 态的派生, 不是 runtime 结果本身。 | 15 | 13 | 25 | 17.7 | 12 | P2 | parallel_with_guard | Rewrite |
| C012 | RPB-12 | guard denial 必须投影成 presentation-safe refusal snapshot。 | 24 | 24 | 24 | 24.0 | 0 | P0 | mainline_first | Keep |
| C013 | RPB-13 | unsafe R2 展示 active/refused cell 和 safety reason, 不暴露速度等敏感内情。 | 24 | 24 | 24 | 24.0 | 0 | P0 | parallel_with_guard | Keep |
| C014 | RPB-14 | already_state_noop 独立结果, 视觉可 satisfied 但语义非 accepted delta。 | 19 | 24 | 24 | 22.3 | 5 | P0 | mainline_first | Keep |
| C015 | RPB-15 | clamp 成功路径要说实际 clamp 值, trace 标 clamped。 | 19 | 24 | 20 | 21.0 | 5 | P1 | parallel_with_guard | Keep |
| C016 | RPB-16 | 真 multi-intent splitter deferred, Phase4/5 只可 sequencer/force-state。 | 15 | 12 | 18 | 15.0 | 6 | P2 | parallel_with_guard | Merge/Defer |
| C017 | RPB-17 | partial deny 需要综合 snapshot, 逐 cell 混态与综合 readback。 | 22 | 17 | 24 | 21.0 | 7 | P1 | mainline_first | Keep |
| C018 | RPB-18 | SceneMacroRegistry 属 Core config, 非 UIUE-only 隐藏 planner。 | 19 | 24 | 16 | 19.7 | 8 | P1 | mainline_first | Rewrite/Merge |
| C019 | RPB-19 | 环境上下文是 runtime context, 非车控卡, 但可显示事实。 | 19 | 24 | 20 | 21.0 | 5 | P1 | parallel_with_guard | Keep |
| C020 | RPB-20 | reset preset 清 vehicle/dialogue/trace/orb/voice/context。 | 21 | 12 | 21 | 18.0 | 9 | P2 | parallel_with_guard | Rewrite/Merge |
| C021 | RPB-21 | think 应事件驱动, 不写固定计时剧场。 | 15 | 24 | 20 | 19.7 | 9 | P1 | parallel_with_guard | Rewrite/Merge |
| C022 | RPB-22 | cancel/interruption/timeout/backgrounding 必须有终态 snapshot。 | 24 | 24 | 23 | 23.7 | 1 | P0 | mainline_first | Keep |
| C023 | RPB-23 | ASR/TTS 边界: backend 接 text, voice-ready 需真机 ASR/TTS proof。 | 25 | 12 | 23 | 20.0 | 13 | P1 | mainline_first | Keep |
| C024 | RPB-24 | TraceEnvelope 最小字段和 redaction 需要锁。 | 18 | 24 | 18 | 20.0 | 6 | P1 | mainline_first | Keep |
| C025 | RPB-25 | proof class 上限: UIUE screenshot/simulator 不能变 runtime/mobile/V-PASS。 | 25 | 12 | 24 | 20.3 | 13 | P1 | parallel_with_guard | Keep |
| C026 | RPB-26 | 现态推理/感受词走 C3 相对 EXP 或 later LoRA, 不在 UIUE 自建。 | 18 | 13 | 16 | 15.7 | 5 | P2 | future_lane | DeferFutureLane |
| C027 | RPB-27 | normalize/range/EXP 复用 C3, UIUE 不重复相对调温逻辑。 | 19 | 24 | 17 | 20.0 | 7 | P1 | mainline_first | Keep |
| C028 | RPB-28 | range 源来自 StateCellContractLookup 或同等 SSOT。 | 19 | 24 | 17 | 20.0 | 7 | P1 | parallel_with_guard | Keep |
| C029 | RPB-29 | active cell 优先级需定义, refused 可压过 satisfied。 | 15 | 13 | 24 | 17.3 | 11 | P2 | parallel_with_guard | Rewrite |
| C030 | RPB-30 | snapshot card schema 要带 scope/reason/active/sibling 等呈现所需语义。 | 18 | 24 | 24 | 22.0 | 6 | P0 | mainline_first | Keep |
| C031 | RPB-31 | family 覆盖 10 族 + context, 天气/时段不是第 11 族车控卡。 | 15 | 24 | 20 | 19.7 | 9 | P1 | parallel_with_guard | Rewrite/Merge |
| C032 | RPB-32 | dialogue ownership 分 runtime readback、assistant copy、presentation styling。 | 18 | 17 | 24 | 19.7 | 7 | P1 | mainline_first | Rewrite/Merge |
| C033 | RPB-33 | orb 状态来源是 composite, 非视觉自嗨。 | 15 | 24 | 22 | 20.3 | 9 | P1 | parallel_with_guard | Keep |
| C034 | RPB-34 | Reduce Motion 必须有非动画通道。 | 15 | 24 | 25 | 21.3 | 10 | P1 | uiue_first | Keep |
| C035 | RPB-35 | Mac/iOS bridge 字段一致, layout 差异 layout-only。 | 18 | 24 | 20 | 20.7 | 6 | P1 | parallel_with_guard | Keep |
| C036 | RPB-36 | 模拟器不等于真机, 质感/音频/性能/热须 true-device lane。 | 24 | 13 | 24 | 20.3 | 11 | P1 | parallel_with_guard | Keep |
| C037 | RPB-37 | 离线 bundle, 无网无 Python, Python 只可 dev spike。 | 19 | 12 | 18 | 16.3 | 7 | P2 | parallel_with_guard | Merge/Defer |
| C038 | RPB-38 | persistence 仅 DialogueState 短时, 不做 cloud/long memory。 | 15 | 24 | 17 | 18.7 | 9 | P2 | mainline_first | Rewrite/Merge |
| C039 | RPB-39 | crash/unknown 不可用于正常 unsupported/refusal。 | 19 | 24 | 20 | 21.0 | 5 | P1 | parallel_with_guard | Keep |
| C040 | RPB-40 | settings/reset 中 theme 是 presentation-only, force/reset 是 runtime input。 | 15 | 24 | 20 | 19.7 | 9 | P1 | parallel_with_guard | Rewrite/Merge |
| C041 | RPB-41 | UIUE scripted runs 可作 future golden candidate, 非 golden proof。 | 22 | 12 | 18 | 17.3 | 10 | P2 | future_lane | DeferFutureLane |
| C042 | RPB-42 | UIUE 视觉绝不选模型候选, candidate comparison 是 later mainline。 | 19 | 13 | 15 | 15.7 | 6 | P2 | future_lane | DeferFutureLane |
| C043 | RPB-43 | UIUE 文案/case 不能直接进入训练数据。 | 15 | 12 | 18 | 15.0 | 6 | P2 | mainline_first | Merge/Defer |
| C044 | RPB-44 | Accessibility deferred 但不能消失, 双通道只覆盖一部分。 | 15 | 12 | 24 | 17.0 | 12 | P2 | uiue_first | Merge/Defer |
| C045 | RPB-45 | screenshot anchor 命名含 platform/state/proof/source。 | 21 | 13 | 21 | 18.3 | 8 | P2 | uiue_first | Rewrite |
| C046 | RPB-46 | receipt 格式需 command/device/proof/touched/residual。 | 21 | 24 | 21 | 22.0 | 3 | P0 | parallel_with_guard | Keep |
| C047 | RPB-47 | merge-readiness 标记只能是 contract aligned not merged。 | 15 | 24 | 18 | 19.0 | 9 | P1 | parallel_with_guard | Rewrite/Merge |
| C048 | RPB-48 | reviewer 必告 live HEAD, no stale SHA。 | 21 | 24 | 19 | 21.3 | 5 | P1 | parallel_with_guard | Keep |
| C049 | RPB-49 | 未决 P0/P1 carry-forward 必进下个 closeout。 | 20 | 24 | 20 | 21.3 | 4 | P1 | parallel_with_guard | Keep |
| C050 | RPB-50 | 哪些落 bridge OpenSpec, 哪些留 UIUE notes 需 landing matrix。 | 21 | 24 | 21 | 22.0 | 3 | P0 | parallel_with_guard | Keep |
| C051 | RPB-51 | snapshot card 必带 sibling/secondary/active 信息以支持制冷/制热与主值。 | 17 | 24 | 23 | 21.3 | 7 | P1 | mainline_first | Merge |
| C052 | RPB-52 | force-state context 输入需 `#if DEMO_MODE` + bridge event + trace provenance。 | 18 | 14 | 20 | 17.3 | 6 | P2 | mainline_first | Rewrite |
| C053 | RPB-53 | think 两语义: analyzing 事件驱动与 safety fixed 1s 演出例外。 | 20 | 13 | 19 | 17.3 | 7 | P2 | parallel_with_guard | Rewrite |
| C054 | CE-001 | `ToolExecutionError` 到 `DemoRuntimeOutcome` 的完整映射表。 | 14 | 13 | 19 | 15.3 | 6 | P2 | mainline_first | Merge/Defer |
| C055 | CE-002 | `guardDenied` 应细分 safety/refusal/unsupported/runtime_error。 | 19 | 13 | 19 | 17.0 | 6 | P2 | mainline_first | Merge |
| C056 | CE-003 | `semanticInvalid("missing_default_scope")` 应映射 clarify/missing scope, 不进 Core enum。 | 18 | 14 | 17 | 16.3 | 4 | P2 | mainline_first | Rewrite |
| C057 | CE-004 | unsupported 与 safety refusal 必须有不同 reason taxonomy。 | 19 | 13 | 19 | 17.0 | 6 | P2 | mainline_first | Merge |
| C058 | CE-005 | runtimeError 需分 timeout/decode/store/model/adapter failure。 | 19 | 13 | 20 | 17.3 | 7 | P2 | mainline_first | Merge/Defer |
| C059 | CE-006 | cancellation 与 interruption 的触发源和恢复语义分开。 | 19 | 13 | 23 | 18.3 | 10 | P2 | mainline_first | Rewrite/Merge |
| C060 | CE-007 | adapter 遇 throw 仍必须发 terminal snapshot, 禁 silent failure。 | 24 | 14 | 24 | 20.7 | 10 | P1 | mainline_first | Keep |
| C061 | CE-008 | retry/idempotency 规则: 重试不得二次写 state 或吞掉 no-op。 | 20 | 13 | 20 | 17.7 | 7 | P2 | mainline_first | Rewrite |
| C062 | CE-009 | snapshot 禁 raw model output, 只带 presentation-safe outcome。 | 18 | 13 | 24 | 18.3 | 11 | P2 | mainline_first | Rewrite |
| C063 | CE-010 | `behaviorClassSource` preservation: accepted 结果保留 `tool_call` 源。 | 15 | 13 | 17 | 15.0 | 4 | P2 | mainline_first | Rewrite |
| C064 | CE-011 | accepted terminal snapshot sample 必须存在。 | 19 | 17 | 21 | 19.0 | 4 | P1 | mainline_first | Merge |
| C065 | CE-012 | clarify/missing-slot terminal snapshot sample 必须存在。 | 19 | 16 | 21 | 18.7 | 5 | P2 | mainline_first | Merge |
| C066 | CE-013 | unsupported/no-tool terminal snapshot sample 必须存在。 | 19 | 17 | 21 | 19.0 | 4 | P1 | mainline_first | Merge |
| C067 | CE-014 | safety refusal terminal snapshot sample 必须存在。 | 19 | 17 | 24 | 20.0 | 7 | P1 | mainline_first | Merge |
| C068 | CE-015 | already-state terminal snapshot sample 必须存在。 | 19 | 17 | 24 | 20.0 | 7 | P1 | mainline_first | Merge |
| C069 | CE-016 | timeout runtimeError terminal snapshot sample 必须存在。 | 19 | 17 | 21 | 19.0 | 4 | P1 | mainline_first | Merge |
| C070 | CE-017 | cancelled terminal snapshot sample 必须存在。 | 19 | 16 | 21 | 18.7 | 5 | P2 | mainline_first | Merge |
| C071 | CE-018 | interrupted/barge-in terminal snapshot sample 必须存在。 | 19 | 17 | 24 | 20.0 | 7 | P1 | mainline_first | Merge |
| C072 | CE-019 | partial accept/refuse terminal snapshot sample 必须存在或明确 local-only。 | 19 | 17 | 23 | 19.7 | 6 | P1 | mainline_first | Merge |
| C073 | CE-020 | mainline flat `cards` 与 UIUE `activeCells` 如何对齐。 | 17 | 17 | 20 | 18.0 | 3 | P2 | mainline_first | Merge |
| C074 | CE-021 | siblingCells/mode 信息是否进入 mainline snapshot。 | 17 | 17 | 23 | 19.0 | 6 | P1 | mainline_first | Merge |
| C075 | CE-022 | refusedCell 是否支持多 refused cells。 | 14 | 16 | 20 | 16.7 | 6 | P2 | mainline_first | Merge |
| C076 | CE-023 | scopeOrigin 是 snapshot-level 还是 per-cell map。 | 17 | 17 | 20 | 18.0 | 3 | P2 | parallel_with_guard | Merge |
| C077 | CE-024 | context(speed/gear/weather/time) 是否进入 shared snapshot 或 effect channel。 | 17 | 17 | 20 | 18.0 | 3 | P2 | parallel_with_guard | Merge |
| C078 | CE-025 | readbacks 数组顺序和“最后一条为准”规则。 | 17 | 17 | 23 | 19.0 | 6 | P1 | mainline_first | Merge |
| C079 | CE-026 | dialogText/readbacks/matrix dialog 的 copy priority。 | 17 | 17 | 23 | 19.0 | 6 | P1 | mainline_first | Merge |
| C080 | CE-027 | empty cards 合法结果类: clarify/error/cancel 是否可空。 | 19 | 16 | 20 | 18.3 | 4 | P2 | uiue_first | Merge |
| C081 | CE-028 | timestamp 是 event time、snapshot time 还是 commit time。 | 17 | 17 | 17 | 17.0 | 0 | P2 | uiue_first | Merge |
| C082 | CE-029 | `cardsDidStartChanging` 是否进入 event gates。 | 17 | 20 | 17 | 18.0 | 3 | P2 | parallel_with_guard | Rewrite/Merge |
| C083 | CE-030 | `readbackReady` 是否进入 event gates。 | 17 | 19 | 20 | 18.7 | 3 | P2 | parallel_with_guard | Rewrite/Merge |
| C084 | CE-031 | `ttsStart/ttsEnd` 是 effect event 还是 snapshot state。 | 17 | 17 | 20 | 18.0 | 3 | P2 | mainline_first | Merge |
| C085 | CE-032 | timeout 作为 event/result/terminal snapshot 三层如何对应。 | 19 | 16 | 20 | 18.3 | 4 | P2 | mainline_first | Merge |
| C086 | CE-033 | `force_context_state` 是否进 `DemoInteractionEventKind`。 | 14 | 17 | 17 | 16.0 | 3 | P2 | uiue_first | Merge |
| C087 | CE-034 | `cardTap` payload 必填 key/family, 缺失 fail-closed。 | 19 | 17 | 24 | 20.0 | 7 | P1 | uiue_first | Merge |
| C088 | CE-035 | micStart/micEnd 是否推进 voiceState 或只作 input trace。 | 16 | 17 | 20 | 17.7 | 4 | P2 | uiue_first | Merge |
| C089 | CE-036 | background/suspend/resume 对 running turn 的 terminal/cancel 规则。 | 19 | 17 | 23 | 19.7 | 6 | P1 | mainline_first | Merge |
| C090 | CE-037 | `thinkAnalyzing` 与 `safetyThink` 是否类型化。 | 19 | 16 | 19 | 18.0 | 3 | P2 | parallel_with_guard | Merge |
| C091 | CE-038 | 最小 1s guard 与固定 3s theatre 的边界。 | 19 | 17 | 20 | 18.7 | 3 | P2 | parallel_with_guard | Merge |
| C092 | CE-039 | macro_id 源必须来自 Core, UIUE 不判语义。 | 15 | 17 | 17 | 16.3 | 2 | P2 | parallel_with_guard | Merge/Defer |
| C093 | CE-040 | macro narration 用 2 字段, 禁回到三段 fixed calling。 | 15 | 17 | 20 | 17.3 | 5 | P2 | parallel_with_guard | Merge/Defer |
| C094 | CE-041 | orbState 与 voiceState 冲突裁决。 | 16 | 17 | 24 | 19.0 | 8 | P1 | parallel_with_guard | Merge |
| C095 | CE-042 | Reduce Motion 每态非动画等价物证明。 | 14 | 16 | 23 | 17.7 | 9 | P2 | parallel_with_guard | Merge |
| C096 | CE-043 | shader/GPU budget 与 MLX runtime 抢资源的门。 | 17 | 13 | 20 | 16.7 | 7 | P2 | mainline_first | Merge/Defer |
| C097 | CE-044 | mainline/UIUE proof class crosswalk。 | 20 | 17 | 20 | 19.0 | 3 | P1 | mainline_first | Merge |
| C098 | CE-045 | result enum crosswalk, 尤其 UIUE partial 与 mainline absence。 | 17 | 17 | 20 | 18.0 | 3 | P2 | parallel_with_guard | Merge |
| C099 | CE-046 | `scopeOrigin=nil` 的合法边界。 | 17 | 17 | 17 | 17.0 | 0 | P2 | mainline_first | Merge |
| C100 | CE-047 | string key migration proof for `scopeOrigins/activeCells`。 | 20 | 16 | 20 | 18.7 | 4 | P2 | parallel_with_guard | Merge |
| C101 | CE-048 | adapter fixture golden cases 覆盖 8 类结果。 | 19 | 17 | 21 | 19.0 | 4 | P1 | mainline_first | Merge |
| C102 | CE-049 | “runtime-driven orb” 在无 runtime logs 前改名 fixture-driven。 | 15 | 17 | 22 | 18.0 | 7 | P2 | parallel_with_guard | Rewrite/Merge |
| C103 | CE-050 | matrix entry proof 与 snapshot proof 的覆盖优先级。 | 20 | 17 | 20 | 19.0 | 3 | P1 | parallel_with_guard | Merge |
| C104 | CE-051 | UIUE 禁在 mainline verdict 前新增 shared field。 | 22 | 17 | 18 | 19.0 | 5 | P1 | parallel_with_guard | Rewrite/Merge |
| C105 | CE-052 | proof ladder: docs/static/unit/simulator/operator/true-device/live。 | 20 | 24 | 24 | 22.7 | 4 | P0 | mainline_first | Keep |
| C106 | CE-053 | screenshot anchor no-promotion machine guard。 | 19 | 24 | 24 | 22.3 | 5 | P0 | parallel_with_guard | Keep |
| C107 | CE-054 | R5 receipt 必带 non-claims checkbox。 | 20 | 24 | 22 | 22.0 | 4 | P0 | parallel_with_guard | Keep |
| C108 | CE-055 | validation gate 按 touched paths 切换。 | 20 | 24 | 20 | 21.3 | 4 | P1 | parallel_with_guard | Keep |
| C109 | CE-056 | stale wording grep 必查 `R5_PRECONDITIONS_BLOCKED/not_proposed/missing`。 | 15 | 24 | 18 | 19.0 | 9 | P1 | parallel_with_guard | Rewrite/Merge |
| C110 | CE-057 | 双 repo dirty status 分开记录, 不混提交。 | 19 | 24 | 19 | 20.7 | 5 | P1 | parallel_with_guard | Keep |
| C111 | CE-058 | mainline/UIUE OpenSpec strict 各跑各的。 | 20 | 24 | 17 | 20.3 | 7 | P1 | parallel_with_guard | Keep |
| C112 | CE-059 | raw ASR 只能 trace, 不作 memory/training/golden authority。 | 16 | 12 | 20 | 16.0 | 8 | P2 | parallel_with_guard | Merge/Defer |
| C113 | CE-060 | normalizer confidence gate 决定是否 update focus。 | 14 | 13 | 20 | 15.7 | 7 | P2 | parallel_with_guard | Merge/Defer |
| C114 | CE-061 | TTS/UX committed 后才写 assistant context。 | 16 | 13 | 23 | 17.3 | 10 | P2 | mainline_first | Merge/Defer |
| C115 | CE-062 | barge-in 后禁止未播出文本进入下一轮事实。 | 14 | 24 | 23 | 20.3 | 10 | P1 | mainline_first | Keep |
| C116 | CE-063 | TTS 与录音会话串行互斥。 | 16 | 24 | 23 | 21.0 | 8 | P1 | mainline_first | Keep |
| C117 | CE-064 | premium 普通话 voice preflight 与 fallback。 | 19 | 13 | 20 | 17.3 | 7 | P2 | mainline_first | Merge/Defer |
| C118 | CE-065 | voiceState `unavailable` 与 `idle` 区分。 | 16 | 12 | 24 | 17.3 | 12 | P2 | parallel_with_guard | Merge/Defer |
| C119 | CE-066 | PTT/tap/hold 语义与 MicDock 文案一致。 | 14 | 13 | 24 | 17.0 | 11 | P2 | parallel_with_guard | Merge/Defer |
| C120 | CE-067 | golden step runtime_mounted + state_cells + whitelist digest precheck。 | 21 | 13 | 17 | 17.0 | 8 | P2 | future_lane | DeferFutureLane |
| C121 | CE-068 | golden replay 校验 revision delta/no-delta + readback_ok。 | 17 | 12 | 17 | 15.3 | 5 | P2 | future_lane | DeferFutureLane |
| C122 | CE-069 | golden/script/storyboard 文案禁直接进 C5 train/dev/test。 | 16 | 12 | 18 | 15.3 | 6 | P2 | mainline_first | Merge/Defer |
| C123 | CE-070 | C6 shape replay 与 model-quality proof 分离。 | 22 | 13 | 15 | 16.7 | 9 | P2 | future_lane | DeferFutureLane |
| C124 | CE-071 | Qwen sampling 按 behavior class 拆测, 不看 aggregate。 | 18 | 12 | 14 | 14.7 | 6 | P2 | future_lane | DeferFutureLane |
| C125 | CE-072 | KV prewarm 绑定 prompt/state hash, stale cache 不算 warm pass。 | 16 | 12 | 16 | 14.7 | 4 | P2 | future_lane | DeferFutureLane |
| C126 | CE-073 | Liquid4All H5 fullState/functions.json 禁当 MAformac SSOT。 | 16 | 24 | 15 | 18.3 | 9 | P2 | parallel_with_guard | Rewrite/Merge |
| C127 | CE-074 | `/ws-audio` 只作 local runtime teardown 灵感。 | 16 | 12 | 15 | 14.3 | 4 | P2 | future_lane | DeferFutureLane |
| C128 | CE-075 | 外部 code/asset/license transfer 前置 provenance checklist。 | 14 | 24 | 18 | 18.7 | 10 | P2 | parallel_with_guard | Rewrite/Merge |
| C129 | CE-076 | 外部 issue/bug 只能启发 premortem, 不能替代 local proof。 | 20 | 24 | 15 | 19.7 | 9 | P1 | parallel_with_guard | Rewrite/Merge |
| C130 | CE-077 | display-only direct touch 必有 disabled/read-only affordance。 | 14 | 24 | 25 | 21.0 | 11 | P1 | parallel_with_guard | Keep |
| C131 | CE-078 | summary direct-control policy: 展示、跳转、guard 后控制三选一。 | 20 | 13 | 24 | 19.0 | 11 | P1 | parallel_with_guard | Rewrite |
| C132 | CE-079 | gear direct-touch safety policy: 默认 display-only unless approved。 | 19 | 14 | 25 | 19.3 | 11 | P1 | parallel_with_guard | Rewrite/Merge |
| C133 | CE-080 | 44pt/VoiceOver/mobile/true-device proof ladder 单独 lane。 | 20 | 12 | 25 | 19.0 | 13 | P1 | parallel_with_guard | Rewrite/Merge |
| C134 | CE-081 | white-edge threshold 保留 WARN 或 formalize, 禁偷写 PASS。 | 14 | 13 | 22 | 16.3 | 9 | P2 | parallel_with_guard | Merge/Defer |
| C135 | CE-082 | capsule final-art 是 human/product visual lane, 不阻塞 R5 dispatch。 | 16 | 13 | 18 | 15.7 | 5 | P2 | parallel_with_guard | Merge/Defer |
| C136 | MC-001 | `DemoRuntimeOutcome.reason / missingSlot / scopeFailureReason` 的优先级和互斥规则。 | 17 | 14 | 16 | 15.7 | 3 | P2 | mainline_first | Merge |
| C137 | MC-002 | `behaviorClassSource` 在 accepted 和 non-accepted 结果中的填充规则。 | 14 | 24 | 16 | 18.0 | 10 | P2 | mainline_first | Merge |
| C138 | MC-003 | `isTerminal` 由结果类派生还是 runtime adapter 显式写入。 | 19 | 24 | 20 | 21.0 | 5 | P1 | mainline_first | Keep |
| C139 | MC-004 | `cards` 允许空数组的结果类和 UI empty-state 策略。 | 14 | 24 | 19 | 19.0 | 10 | P1 | mainline_first | Merge |
| C140 | MC-005 | `readbacks` 的顺序规则: 时间、卡片、最后一条为准。 | 17 | 16 | 22 | 18.3 | 6 | P2 | mainline_first | Merge |
| C141 | MC-006 | `dialogText` 与 `readbacks` 的 canonical human copy 裁决。 | 17 | 17 | 22 | 18.7 | 5 | P2 | mainline_first | Merge |
| C142 | MC-007 | `TraceEnvelope.traceID` 与 snapshot `traceID` 是否必须一致。 | 17 | 13 | 17 | 15.7 | 4 | P2 | mainline_first | Merge/Defer |
| C143 | MC-008 | `TraceEnvelope.entries` append-only 与阶段/时间单调性。 | 17 | 24 | 17 | 19.3 | 7 | P1 | mainline_first | Rewrite/Merge |
| C144 | MC-009 | snapshot `timestamp` 的时钟源和语义。 | 17 | 24 | 16 | 19.0 | 8 | P1 | mainline_first | Merge |
| C145 | MC-010 | `cancel` 与 `interruption` 的触发源、结果和恢复语义。 | 19 | 13 | 22 | 18.0 | 9 | P2 | mainline_first | Merge |
| C146 | MC-011 | `cardTap` 是否必须携带 `cardKey`, 缺失如何 fail-closed。 | 19 | 13 | 23 | 18.3 | 10 | P2 | mainline_first | Merge |
| C147 | MC-012 | `micStart/micEnd` 是输入事件还是必须驱动 voiceState。 | 16 | 13 | 19 | 16.0 | 6 | P2 | mainline_first | Merge |
| C148 | MC-013 | `voiceState` 与 `orbState` 同时非空时的主显示源和冲突裁决。 | 16 | 14 | 23 | 17.7 | 9 | P2 | mainline_first | Merge |
| C149 | MC-014 | `PresentationProofClass.displayCaps` 永远空是永久合同还是临时保守值。 | 14 | 13 | 20 | 15.7 | 7 | P2 | mainline_first | Merge/Defer |
| C150 | MC-015 | 未知 `PresentationProofClass` JSON 是否所有 consumer 都 fail-closed。 | 19 | 13 | 21 | 17.7 | 8 | P2 | mainline_first | Merge/Defer |
| C151 | MC-016 | `PresentationReadinessClaim` 是 shared API 还是未来占位符。 | 14 | 13 | 16 | 14.3 | 3 | P2 | mainline_first | Merge/Defer |
| C152 | MC-017 | snapshot `scopeFailureReason` 与 outcome `scopeFailureReason` 是否镜像。 | 17 | 14 | 20 | 17.0 | 6 | P2 | mainline_first | Merge/Defer |
| C153 | MC-018 | `scopeOrigin=nil` 的合法边界, 禁把 nil 当 defaulted。 | 17 | 17 | 16 | 16.7 | 1 | P2 | mainline_first | Merge |
| C154 | UC-001 | UIUE proof enum 与 mainline proof enum 的 crosswalk。 | 20 | 13 | 20 | 17.7 | 7 | P2 | uiue_first | Merge |
| C155 | UC-002 | `operatorReview` 能否出现在产品界面, 且不得等于 acceptance。 | 14 | 24 | 25 | 21.0 | 11 | P1 | uiue_first | Keep |
| C156 | UC-003 | UIUE matrix entry proof 与 snapshot proof 的优先级。 | 20 | 14 | 19 | 17.7 | 6 | P2 | uiue_first | Merge |
| C157 | UC-004 | partial accept/refuse 需 accepted/refused per-cell payload 后才做复杂混合 outcome。 | 14 | 13 | 23 | 16.7 | 10 | P2 | uiue_first | Merge/Defer |
| C158 | UC-005 | `dialogText/readbacks/matrix dialogText` 冲突时 UI/TTS/VO 的来源优先级。 | 17 | 13 | 22 | 17.3 | 9 | P2 | uiue_first | Merge |
| C159 | UC-006 | already-state 与 accepted 都 satisfied 时 a11y/readback 必须区分。 | 17 | 13 | 25 | 18.3 | 12 | P2 | uiue_first | Rewrite/Merge |
| C160 | UC-007 | card `accessibilityLabel` 是否包含 scope/reason/proof/read-only。 | 20 | 14 | 25 | 19.7 | 11 | P1 | uiue_first | Rewrite/Merge |
| C161 | UC-008 | `ValueControlView` direct controls 的 a11y value/hint/range。 | 14 | 13 | 25 | 17.3 | 12 | P2 | uiue_first | Merge/Defer |
| C162 | UC-009 | MicDock button tap 与“按住说话”文案的语义错配。 | 14 | 13 | 25 | 17.3 | 12 | P2 | uiue_first | Merge/Defer |
| C163 | UC-010 | context capsule a11y 是否读出速度/天气/挡位。 | 14 | 13 | 22 | 16.3 | 9 | P2 | uiue_first | Merge/Defer |
| C164 | UC-011 | expanded overlay 的 escape action、button trait 与 focus return。 | 14 | 24 | 25 | 21.0 | 11 | P1 | uiue_first | Keep |
| C165 | UC-012 | cancel/cancelled 映射 normal 后保留 terminal proof 和 announcement。 | 20 | 13 | 23 | 18.7 | 10 | P2 | uiue_first | Rewrite/Merge |
| C166 | UC-013 | runtimeError 区分 timeout/adapter/presentation fixture failure。 | 19 | 17 | 19 | 18.3 | 2 | P2 | uiue_first | Merge |
| C167 | UC-014 | Reduced Motion policy 是否有非动画 UI proof fixture。 | 20 | 13 | 23 | 18.7 | 10 | P2 | uiue_first | Merge |
| C168 | UC-015 | string-key `scopeOrigins` 改名后如何避免静默错配。 | 17 | 14 | 19 | 16.7 | 5 | P2 | uiue_first | Merge |
| C169 | UC-016 | `activeCells` 多 active/mixed outcome 的顺序、主次、focus priority。 | 17 | 13 | 25 | 18.3 | 12 | P2 | uiue_first | Rewrite/Merge |
| C170 | UC-017 | U15 counterexample fixture 补 already-state/runtime-error/cancelled。 | 19 | 16 | 21 | 18.7 | 5 | P2 | uiue_first | Merge |
| C171 | UC-018 | screenshot anchor proof-class 命名后禁被引用为 runtime/mobile proof。 | 25 | 13 | 23 | 20.3 | 12 | P1 | uiue_first | Rewrite/Merge |
| C172 | UC-019 | display-only summary/gear 需要 disabled affordance 和 a11y “仅展示”。 | 14 | 14 | 24 | 17.3 | 10 | P2 | uiue_first | Merge/Defer |
| C173 | UC-020 | a11y proof ladder 区分 local/static/simulator/true-device。 | 20 | 24 | 23 | 22.3 | 4 | P0 | uiue_first | Merge |
| C174 | UC-021 | safety refusal 中 orbState think 与 matrix tts speaking 的 lifecycle。 | 19 | 13 | 24 | 18.7 | 11 | P2 | uiue_first | Rewrite/Merge |
| C175 | UC-022 | mock voice state contradiction: orb speak + voice idle 要标非真实 TTS。 | 16 | 13 | 24 | 17.7 | 11 | P2 | uiue_first | Merge/Defer |
| C176 | PV-001 | `ToolExecutionError` 到 outcome 的完整分类, 尤其 guardDenied。 | 19 | 17 | 15 | 17.0 | 4 | P2 | parallel_with_guard | Merge |
| C177 | PV-002 | 每个 terminal outcome 都要 sample terminal snapshot fixture。 | 19 | 17 | 19 | 18.3 | 2 | P2 | parallel_with_guard | Merge |
| C178 | PV-003 | mainline 缺 partial, UIUE 已有 partial, 是否 canonical 或 local-only。 | 17 | 12 | 19 | 16.0 | 7 | P2 | parallel_with_guard | Merge |
| C179 | PV-004 | proof enum 必须 translation, 禁 raw value 直传。 | 20 | 13 | 21 | 18.0 | 8 | P2 | parallel_with_guard | Rewrite/Merge |
| C180 | PV-005 | `displayCaps` 永远空还是未来可打开, 谁开。 | 14 | 16 | 19 | 16.3 | 5 | P2 | parallel_with_guard | Merge |
| C181 | PV-006 | think 两语义是否需要两个 enum/state。 | 17 | 17 | 18 | 17.3 | 1 | P2 | parallel_with_guard | Merge |
| C182 | PV-007 | `cards_did_start_changing/readback_ready/tts_start/tts_end` 是否进 event kind。 | 17 | 20 | 19 | 18.7 | 3 | P2 | parallel_with_guard | Merge |
| C183 | PV-008 | `force_context_state` 必须 demo-mode 隔离和 trace provenance。 | 14 | 17 | 19 | 16.7 | 5 | P2 | parallel_with_guard | Merge |
| C184 | PV-009 | `activeCell/siblingCells` 在 mainline snapshot 的表达方式。 | 17 | 17 | 22 | 18.7 | 5 | P2 | parallel_with_guard | Merge |
| C185 | PV-010 | already-state 证明 no revision bump、ack/readback、非 accepted delta。 | 17 | 13 | 24 | 18.0 | 11 | P2 | parallel_with_guard | Rewrite/Merge |
| C186 | PV-011 | cancel/interruption 后禁止 stale async mutate cards。 | 19 | 13 | 24 | 18.7 | 11 | P2 | parallel_with_guard | Rewrite/Merge |
| C187 | PV-012 | terminal snapshot 覆盖 `isTerminal=false -> true` 唯一合法转移。 | 20 | 13 | 25 | 19.3 | 12 | P1 | parallel_with_guard | Rewrite/Merge |
| C188 | PV-013 | “runtime-driven orb binding” 在无 runtime logs 前只能叫 fixture-driven。 | 14 | 17 | 21 | 17.3 | 7 | P2 | parallel_with_guard | Merge |
| C189 | PV-014 | C5/C6/golden/voice proof lane 独立 checkbox 禁互相替代。 | 25 | 13 | 24 | 20.7 | 12 | P1 | parallel_with_guard | Keep |
| C190 | PV-015 | C6 acceptance/comparison 何时才从 bridge work 解冻。 | 19 | 12 | 16 | 15.7 | 7 | P2 | future_lane | DeferFutureLane |
| C191 | PV-016 | voice lane 首 gate 是功能坑 spike, 不是 UIUE voiceState。 | 18 | 12 | 20 | 16.7 | 8 | P2 | future_lane | DeferFutureLane |
| C192 | PV-017 | Liquid4All reject direct copy checklist。 | 14 | 24 | 14 | 17.3 | 10 | P2 | parallel_with_guard | Merge/Defer |
| C193 | PV-018 | L0/L1/L2/L3 visual proof 绑定 proof-class cap, L1/L2 不关闭 L3。 | 20 | 13 | 25 | 19.3 | 12 | P1 | parallel_with_guard | Rewrite/Merge |
| C194 | PV-019 | summary/gear direct touch 前先定义 disabled/safety/readback/a11y policy。 | 19 | 17 | 23 | 19.7 | 6 | P1 | parallel_with_guard | Merge |
| C195 | PV-020 | R5 closeout hard gate: mainline dirty residual 与 UIUE clean 分开记录。 | 24 | 13 | 19 | 18.7 | 11 | P2 | parallel_with_guard | Rewrite/Merge |
| C196 | PV-021 | docs-only vs Swift/UI touched 的 validation gate 每 lane 明确。 | 20 | 14 | 20 | 18.0 | 6 | P2 | parallel_with_guard | Rewrite/Merge |
| C197 | PV-022 | C3 parser fallback/repair 是否进 runtime adapter error feedback strategy。 | 22 | 12 | 16 | 16.7 | 10 | P2 | parallel_with_guard | Spike |
| C198 | MVG-001 | golden step 进入前校验 runtime_mounted、required_state_cells、whitelist digest。 | 21 | 17 | 16 | 18.0 | 5 | P2 | future_lane | DeferFutureLane |
| C199 | MVG-002 | golden replay 断言 state_revision before/after、readback_ok、no unexpected delta。 | 22 | 17 | 16 | 18.3 | 6 | P2 | future_lane | DeferFutureLane |
| C200 | MVG-003 | already_state_noop 进入 C6/golden 样本, 不算 success_with_delta。 | 16 | 16 | 24 | 18.7 | 8 | P2 | future_lane | DeferFutureLane |
| C201 | MVG-004 | partial accept/refuse readback 逐 cell 列 accepted/refused。 | 17 | 17 | 23 | 19.0 | 6 | P1 | future_lane | DeferFutureLane |
| C202 | MVG-005 | voice memory 7 seeds 升级为正式 C6/golden seeds 或明确 deferred。 | 18 | 12 | 16 | 15.3 | 6 | P2 | future_lane | DeferFutureLane |
| C203 | MVG-006 | assistant context commit 等 TTS/UX committed, barge-in 后不写下一轮焦点。 | 16 | 17 | 22 | 18.3 | 6 | P2 | future_lane | DeferFutureLane |
| C204 | MVG-007 | raw ASR 只进 trace, train/memory/golden label 用 normalizer output。 | 21 | 14 | 19 | 18.0 | 7 | P2 | future_lane | DeferFutureLane |
| C205 | MVG-008 | low-confidence ASR no-focus-update fixture, 禁 UIUE mock transcript 证明 voice-ready。 | 25 | 13 | 23 | 20.3 | 12 | P1 | future_lane | DeferFutureLane |
| C206 | MVG-009 | TTS 与录音会话互斥进入 voice state machine 测试。 | 16 | 17 | 22 | 18.3 | 6 | P2 | future_lane | DeferFutureLane |
| C207 | MVG-010 | endpoint decode parity 统计 toolCall/content JSON/parser_repair/false tool call 分布。 | 22 | 13 | 14 | 16.3 | 9 | P2 | future_lane | DeferFutureLane |
| C208 | MVG-011 | Mac dev Outlines/XGrammar fixture 标 dev_only, 禁当 iOS proof。 | 23 | 17 | 18 | 19.3 | 6 | P1 | future_lane | DeferFutureLane |
| C209 | MVG-012 | Qwen sampling 按 behavior class 拆测 temp0.6 vs 0.1。 | 18 | 12 | 13 | 14.3 | 6 | P2 | future_lane | DeferFutureLane |
| C210 | MVG-013 | KV prewarm 绑定 prompt/state hash, stale cache 不算 warm-path pass。 | 16 | 16 | 15 | 15.7 | 1 | P2 | future_lane | DeferFutureLane |
| C211 | MVG-014 | golden/script 文案禁直接进 C5 train/dev/test, 除非 data contract。 | 16 | 13 | 17 | 15.3 | 4 | P2 | future_lane | DeferFutureLane |
| C212 | MVG-015 | scene macro 带 `planned_not_golden`, golden upgrade 单独签。 | 18 | 14 | 18 | 16.7 | 4 | P2 | future_lane | DeferFutureLane |
| C213 | MVG-016 | UIUE local fixture proofClass unknown/缺失时 fail-closed。 | 25 | 13 | 24 | 20.7 | 12 | P1 | future_lane | DeferFutureLane |
| C214 | MVG-017 | terminal snapshot 包含 timeout/cancel/interrupted finality 防 stale async mutate。 | 19 | 17 | 24 | 20.0 | 7 | P1 | future_lane | DeferFutureLane |
| C215 | MVG-018 | C6/golden 区分 local_shape_no_model replay 与 model_quality。 | 16 | 13 | 18 | 15.7 | 5 | P2 | future_lane | DeferFutureLane |

## Merge And Drop Log

| Cluster | Candidates | Judge note |
|---|---|---|
| terminal snapshot / fixture matrix | C064-C072, C101, C170, C177, C198-C201, C214 | GREEN and RED converge that these should become fixture rows, not many independent burndown workstreams. |
| proof-class / non-claim ladder | C025, C047-C063, C105-C116, C136-C165, C180-C188 | Keep the risk, but merge into canonical proof ladder + receipt schema where possible. |
| voice/model/golden/mobile future lanes | C112, C117, C120-C127, C133-C135, C178, C190-C191, C202-C209 | Preserve as future-lane guardrails; do not let them block R5 dispatch unless promoted. |
| UI/HMI direct-touch and a11y | C031-C036, C130-C135, C155-C164 | BLUE assigns high demo risk; retain as UIUE/human-review or UIUE-first gates. |

## Divergent Candidates

| Candidate | Original | Scores | Spread | Dispute type | Next action |
|---|---|---|---:|---|---|
| C025 | RPB-25 | [25, 12, 24] | 13 | 混合 | Split fact half from routing/proof half in final matrix. |
| C023 | RPB-23 | [25, 12, 23] | 13 | 混合 | Split fact half from routing/proof half in final matrix. |
| C133 | CE-080 | [20, 12, 25] | 13 | 混合 | Split fact half from routing/proof half in final matrix. |
| C189 | PV-014 | [25, 13, 24] | 12 | 混合 | Split fact half from routing/proof half in final matrix. |
| C213 | MVG-016 | [25, 13, 24] | 12 | 混合 | Split fact half from routing/proof half in final matrix. |
| C171 | UC-018 | [25, 13, 23] | 12 | 混合 | Split fact half from routing/proof half in final matrix. |
| C205 | MVG-008 | [25, 13, 23] | 12 | 混合 | Split fact half from routing/proof half in final matrix. |
| C187 | PV-012 | [20, 13, 25] | 12 | 口径型 | Stop re-scoring after Round 2; judge as merge/rewrite/route decision. |
| C193 | PV-018 | [20, 13, 25] | 12 | 口径型 | Stop re-scoring after Round 2; judge as merge/rewrite/route decision. |
| C159 | UC-006 | [17, 13, 25] | 12 | 事实型 | Round 2 cite-verify against source/DTO/test; if needs real device/runtime, tag Spike. |
| C169 | UC-016 | [17, 13, 25] | 12 | 事实型 | Round 2 cite-verify against source/DTO/test; if needs real device/runtime, tag Spike. |
| C011 | RPB-11 | [15, 13, 25] | 12 | 混合 | Split fact half from routing/proof half in final matrix. |
| C118 | CE-065 | [16, 12, 24] | 12 | 混合 | Split fact half from routing/proof half in final matrix. |
| C161 | UC-008 | [14, 13, 25] | 12 | 事实型 | Round 2 cite-verify against source/DTO/test; if needs real device/runtime, tag Spike. |
| C162 | UC-009 | [14, 13, 25] | 12 | 事实型 | Round 2 cite-verify against source/DTO/test; if needs real device/runtime, tag Spike. |
| C044 | RPB-44 | [15, 12, 24] | 12 | 混合 | Split fact half from routing/proof half in final matrix. |
| C130 | CE-077 | [14, 24, 25] | 11 | 混合 | Split fact half from routing/proof half in final matrix. |
| C155 | UC-002 | [14, 24, 25] | 11 | 事实型 | Round 2 cite-verify against source/DTO/test; if needs real device/runtime, tag Spike. |
| C164 | UC-011 | [14, 24, 25] | 11 | 事实型 | Round 2 cite-verify against source/DTO/test; if needs real device/runtime, tag Spike. |
| C036 | RPB-36 | [24, 13, 24] | 11 | 混合 | Split fact half from routing/proof half in final matrix. |
| C160 | UC-007 | [20, 14, 25] | 11 | 事实型 | Round 2 cite-verify against source/DTO/test; if needs real device/runtime, tag Spike. |
| C132 | CE-079 | [19, 14, 25] | 11 | 口径型 | Stop re-scoring after Round 2; judge as merge/rewrite/route decision. |
| C131 | CE-078 | [20, 13, 24] | 11 | 混合 | Split fact half from routing/proof half in final matrix. |
| C174 | UC-021 | [19, 13, 24] | 11 | 事实型 | Round 2 cite-verify against source/DTO/test; if needs real device/runtime, tag Spike. |
| C186 | PV-011 | [19, 13, 24] | 11 | 口径型 | Stop re-scoring after Round 2; judge as merge/rewrite/route decision. |
| C195 | PV-020 | [24, 13, 19] | 11 | 口径型 | Stop re-scoring after Round 2; judge as merge/rewrite/route decision. |
| C062 | CE-009 | [18, 13, 24] | 11 | 事实型 | Round 2 cite-verify against source/DTO/test; if needs real device/runtime, tag Spike. |
| C185 | PV-010 | [17, 13, 24] | 11 | 口径型 | Stop re-scoring after Round 2; judge as merge/rewrite/route decision. |
| C175 | UC-022 | [16, 13, 24] | 11 | 事实型 | Round 2 cite-verify against source/DTO/test; if needs real device/runtime, tag Spike. |
| C029 | RPB-29 | [15, 13, 24] | 11 | 混合 | Split fact half from routing/proof half in final matrix. |

## Gaps For Round 02

- Re-score same blind 215 with systems/test/product lenses; do not pass Round 01 scores to preserve independence.
- Decide whether high-duplication clusters are standalone workstreams or merge-only guardrails.
- Force route clarity for `mainline_first` vs `uiue_first` vs `future_lane` so downstream burndown can split windows cleanly.
- Keep proof-class and non-claim rows even if merged; they are governance gates, not noise.

## Non-Claims

No runtime-ready, mobile, true_device, voice-ready, model-ready, golden-ready, endpoint-ready, UIUE merge, V-PASS, S-PASS, U-PASS, or A-2 complete claim is made by this Round 01 judge.

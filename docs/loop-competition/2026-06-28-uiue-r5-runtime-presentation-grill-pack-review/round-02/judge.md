# Judge - Round 02

## Inputs

- Round: `round-02`
- Valid reviewer files:
  - `round-02/brain-1.md` PURPLE systems architect replacement (`Herschel`)
  - `round-02/brain-2.md` ORANGE test engineer (`Hume`)
  - `round-02/brain-3.md` BLACK skeptical product judge (`Zeno`)
- Failed reviewer recorded: original PURPLE reviewer `Ptolemy` returned PARTIAL/read-only and did not write `brain-1.md`; replaced before judging.
- Candidate count: `215` fixed blind candidates.
- Proof class: `docs/local + subagent_readonly + controller_judge`.

## Completion Gate

| File | Scores rows | Candidate Notes rows | Gate |
|---|---:|---:|---|
| `brain-1.md` | 215 | 215 | PASS |
| `brain-2.md` | 215 | 215 | PASS |
| `brain-3.md` | 215 | 215 | PASS |

## Round 02 Synthesis

- PURPLE replacement reinforced the architectural risk: UIUE local snapshot resembles mainline DTO but is not the authority; this needs a migration/crosswalk matrix.
- ORANGE made terminal fixture manifest and proof-class checker the strongest test-facing recommendations.
- BLACK confirmed customer-visible trust risks: stale terminal states, fake affordance, and proof copy inflation are more dangerous than low-level schema incompleteness.
- Judge ruling: Round 2 validates Round 1 compression pressure, but keeps high-risk governance and HMI rows as merge-only or future-lane guardrails instead of deletion.

## Round 02 Majority Action Counts

| Action | Count |
|---|---:|
| DeferFutureLane | 18 |
| DeferHuman | 11 |
| Keep | 77 |
| Merge | 51 |
| Mixed | 46 |
| Rewrite | 10 |
| Spike | 2 |

## Candidate Scores

| Candidate | Original | Question | PURPLE | ORANGE | BLACK | Avg | Spread | R2 verdicts |
|---|---|---|---:|---:|---:|---:|---:|---|
| C001 | RPB-01 | 边界 override 只能是 snapshot consume + bridge event write, 不能自由 mutate store。 | 24 | 19 | 23 | 22.0 | 5 | Keep, Rewrite, Keep |
| C002 | RPB-02 | 三车道分类: UIUE local, shared bridge, mainline runtime。 | 17 | 19 | 22 | 19.3 | 5 | Merge, Rewrite, Keep |
| C003 | RPB-03 | bridge 4 名和字段名必须由 mainline carrier/DTO 锁定。 | 24 | 19 | 23 | 22.0 | 5 | Keep, Keep, Keep |
| C004 | RPB-04 | store ownership: presentation 消费 snapshot, 不读 raw runtime store。 | 24 | 19 | 24 | 22.3 | 5 | Keep, Rewrite, Keep |
| C005 | RPB-05 | 写所有权: 触摸/事件走 executor 或 runtime adapter, 不直接写 store。 | 24 | 19 | 23 | 22.0 | 5 | Keep, Rewrite, Keep |
| C006 | RPB-06 | 事件集必须封闭, 包含 text/mic/card/cancel/interruption/timeout 等。 | 18 | 19 | 20 | 19.0 | 2 | Rewrite, Rewrite, Keep |
| C007 | RPB-07 | 事件 payload 必须区分 source/provenance 与 scope_origin/resolution。 | 24 | 19 | 19 | 20.7 | 5 | Keep, Rewrite, Keep |
| C008 | RPB-08 | scope 展示读结构化字段, UI/TTS 禁从中文推断 scope。 | 24 | 19 | 24 | 22.3 | 5 | Keep, Rewrite, Keep |
| C009 | RPB-09 | Runtime result enum 保持机器可读, 不用裸 rejected。 | 24 | 19 | 24 | 22.3 | 5 | Keep, Keep, Keep |
| C010 | RPB-10 | 拒识词表要区分 unsupported/safety/clarify/already-state/runtime-error。 | 17 | 19 | 19 | 18.3 | 2 | Merge, Keep, Rewrite |
| C011 | RPB-11 | 视觉映射为结果到 7 态的派生, 不是 runtime 结果本身。 | 17 | 19 | 22 | 19.3 | 5 | Merge, Keep, Keep |
| C012 | RPB-12 | guard denial 必须投影成 presentation-safe refusal snapshot。 | 24 | 19 | 23 | 22.0 | 5 | Keep, Keep, Keep |
| C013 | RPB-13 | unsafe R2 展示 active/refused cell 和 safety reason, 不暴露速度等敏感内情。 | 18 | 19 | 22 | 19.7 | 4 | Rewrite, Keep, Keep |
| C014 | RPB-14 | already_state_noop 独立结果, 视觉可 satisfied 但语义非 accepted delta。 | 17 | 19 | 23 | 19.7 | 6 | Merge, Keep, Keep |
| C015 | RPB-15 | clamp 成功路径要说实际 clamp 值, trace 标 clamped。 | 17 | 19 | 20 | 18.7 | 3 | Merge, Keep, Keep |
| C016 | RPB-16 | 真 multi-intent splitter deferred, Phase4/5 只可 sequencer/force-state。 | 18 | 19 | 19 | 18.7 | 1 | Rewrite, Rewrite, Keep |
| C017 | RPB-17 | partial deny 需要综合 snapshot, 逐 cell 混态与综合 readback。 | 24 | 19 | 22 | 21.7 | 5 | Keep, Keep, Keep |
| C018 | RPB-18 | SceneMacroRegistry 属 Core config, 非 UIUE-only 隐藏 planner。 | 24 | 19 | 20 | 21.0 | 5 | Keep, Rewrite, Keep |
| C019 | RPB-19 | 环境上下文是 runtime context, 非车控卡, 但可显示事实。 | 18 | 19 | 17 | 18.0 | 2 | Rewrite, Rewrite, Keep |
| C020 | RPB-20 | reset preset 清 vehicle/dialogue/trace/orb/voice/context。 | 18 | 19 | 21 | 19.3 | 3 | Rewrite, Rewrite, Keep |
| C021 | RPB-21 | think 应事件驱动, 不写固定计时剧场。 | 17 | 19 | 22 | 19.3 | 5 | Merge, Rewrite, Keep |
| C022 | RPB-22 | cancel/interruption/timeout/backgrounding 必须有终态 snapshot。 | 17 | 19 | 23 | 19.7 | 6 | Merge, Rewrite, Keep |
| C023 | RPB-23 | ASR/TTS 边界: backend 接 text, voice-ready 需真机 ASR/TTS proof。 | 24 | 19 | 23 | 22.0 | 5 | Keep, Rewrite, Keep |
| C024 | RPB-24 | TraceEnvelope 最小字段和 redaction 需要锁。 | 24 | 19 | 20 | 21.0 | 5 | Keep, Rewrite, Keep |
| C025 | RPB-25 | proof class 上限: UIUE screenshot/simulator 不能变 runtime/mobile/V-PASS。 | 24 | 23 | 24 | 23.7 | 1 | Keep, Keep, Keep |
| C026 | RPB-26 | 现态推理/感受词走 C3 相对 EXP 或 later LoRA, 不在 UIUE 自建。 | 14 | 13 | 16 | 14.3 | 3 | DeferFutureLane, DeferFutureLane, DeferFutureLane |
| C027 | RPB-27 | normalize/range/EXP 复用 C3, UIUE 不重复相对调温逻辑。 | 18 | 19 | 19 | 18.7 | 1 | Rewrite, Rewrite, Keep |
| C028 | RPB-28 | range 源来自 StateCellContractLookup 或同等 SSOT。 | 19 | 19 | 19 | 19.0 | 0 | Rewrite, Rewrite, Keep |
| C029 | RPB-29 | active cell 优先级需定义, refused 可压过 satisfied。 | 17 | 19 | 20 | 18.7 | 3 | Merge, Rewrite, Keep |
| C030 | RPB-30 | snapshot card schema 要带 scope/reason/active/sibling 等呈现所需语义。 | 24 | 19 | 22 | 21.7 | 5 | Keep, Rewrite, Keep |
| C031 | RPB-31 | family 覆盖 10 族 + context, 天气/时段不是第 11 族车控卡。 | 18 | 19 | 17 | 18.0 | 2 | Rewrite, Rewrite, Keep |
| C032 | RPB-32 | dialogue ownership 分 runtime readback、assistant copy、presentation styling。 | 17 | 19 | 19 | 18.3 | 2 | Merge, Rewrite, Keep |
| C033 | RPB-33 | orb 状态来源是 composite, 非视觉自嗨。 | 17 | 19 | 22 | 19.3 | 5 | Merge, Rewrite, Keep |
| C034 | RPB-34 | Reduce Motion 必须有非动画通道。 | 18 | 19 | 20 | 19.0 | 2 | Rewrite, Rewrite, Keep |
| C035 | RPB-35 | Mac/iOS bridge 字段一致, layout 差异 layout-only。 | 24 | 19 | 19 | 20.7 | 5 | Keep, Rewrite, Keep |
| C036 | RPB-36 | 模拟器不等于真机, 质感/音频/性能/热须 true-device lane。 | 24 | 23 | 24 | 23.7 | 1 | Keep, Keep, Keep |
| C037 | RPB-37 | 离线 bundle, 无网无 Python, Python 只可 dev spike。 | 18 | 13 | 22 | 17.7 | 9 | Rewrite, DeferFutureLane, Keep |
| C038 | RPB-38 | persistence 仅 DialogueState 短时, 不做 cloud/long memory。 | 18 | 19 | 17 | 18.0 | 2 | Rewrite, Rewrite, Keep |
| C039 | RPB-39 | crash/unknown 不可用于正常 unsupported/refusal。 | 17 | 19 | 20 | 18.7 | 3 | Merge, Rewrite, Keep |
| C040 | RPB-40 | settings/reset 中 theme 是 presentation-only, force/reset 是 runtime input。 | 17 | 19 | 20 | 18.7 | 3 | Merge, Rewrite, Keep |
| C041 | RPB-41 | UIUE scripted runs 可作 future golden candidate, 非 golden proof。 | 17 | 19 | 21 | 19.0 | 4 | Merge, Rewrite, Keep |
| C042 | RPB-42 | UIUE 视觉绝不选模型候选, candidate comparison 是 later mainline。 | 14 | 13 | 19 | 15.3 | 6 | DeferFutureLane, DeferFutureLane, Keep |
| C043 | RPB-43 | UIUE 文案/case 不能直接进入训练数据。 | 14 | 13 | 23 | 16.7 | 10 | DeferFutureLane, DeferFutureLane, Keep |
| C044 | RPB-44 | Accessibility deferred 但不能消失, 双通道只覆盖一部分。 | 18 | 13 | 19 | 16.7 | 6 | Rewrite, DeferFutureLane, Keep |
| C045 | RPB-45 | screenshot anchor 命名含 platform/state/proof/source。 | 17 | 23 | 21 | 20.3 | 6 | Merge, Keep, Keep |
| C046 | RPB-46 | receipt 格式需 command/device/proof/touched/residual。 | 17 | 23 | 21 | 20.3 | 6 | Merge, Rewrite, Keep |
| C047 | RPB-47 | merge-readiness 标记只能是 contract aligned not merged。 | 24 | 23 | 24 | 23.7 | 1 | Keep, Keep, Keep |
| C048 | RPB-48 | reviewer 必告 live HEAD, no stale SHA。 | 17 | 23 | 21 | 20.3 | 6 | Merge, Keep, Keep |
| C049 | RPB-49 | 未决 P0/P1 carry-forward 必进下个 closeout。 | 17 | 23 | 20 | 20.0 | 6 | Merge, Keep, Keep |
| C050 | RPB-50 | 哪些落 bridge OpenSpec, 哪些留 UIUE notes 需 landing matrix。 | 24 | 23 | 22 | 23.0 | 2 | Keep, Rewrite, Keep |
| C051 | RPB-51 | snapshot card 必带 sibling/secondary/active 信息以支持制冷/制热与主值。 | 24 | 18 | 17 | 19.7 | 7 | Keep, Merge, Merge |
| C052 | RPB-52 | force-state context 输入需 `#if DEMO_MODE` + bridge event + trace provenance。 | 24 | 19 | 23 | 22.0 | 5 | Keep, Rewrite, Keep |
| C053 | RPB-53 | think 两语义: analyzing 事件驱动与 safety fixed 1s 演出例外。 | 17 | 18 | 18 | 17.7 | 1 | Merge, Merge, Rewrite |
| C054 | CE-001 | `ToolExecutionError` 到 `DemoRuntimeOutcome` 的完整映射表。 | 24 | 19 | 21 | 21.3 | 5 | Keep, Rewrite, Merge |
| C055 | CE-002 | `guardDenied` 应细分 safety/refusal/unsupported/runtime_error。 | 17 | 18 | 18 | 17.7 | 1 | Merge, Merge, Merge |
| C056 | CE-003 | `semanticInvalid("missing_default_scope")` 应映射 clarify/missing scope, 不进 Core enum。 | 24 | 18 | 20 | 20.7 | 6 | Keep, Merge, Keep |
| C057 | CE-004 | unsupported 与 safety refusal 必须有不同 reason taxonomy。 | 17 | 18 | 22 | 19.0 | 5 | Merge, Merge, Keep |
| C058 | CE-005 | runtimeError 需分 timeout/decode/store/model/adapter failure。 | 17 | 18 | 22 | 19.0 | 5 | Merge, Merge, Merge |
| C059 | CE-006 | cancellation 与 interruption 的触发源和恢复语义分开。 | 17 | 18 | 19 | 18.0 | 2 | Merge, Merge, Merge |
| C060 | CE-007 | adapter 遇 throw 仍必须发 terminal snapshot, 禁 silent failure。 | 24 | 23 | 23 | 23.3 | 1 | Keep, Rewrite, Keep |
| C061 | CE-008 | retry/idempotency 规则: 重试不得二次写 state 或吞掉 no-op。 | 18 | 23 | 22 | 21.0 | 5 | Rewrite, Rewrite, Keep |
| C062 | CE-009 | snapshot 禁 raw model output, 只带 presentation-safe outcome。 | 24 | 23 | 24 | 23.7 | 1 | Keep, Rewrite, Keep |
| C063 | CE-010 | `behaviorClassSource` preservation: accepted 结果保留 `tool_call` 源。 | 24 | 23 | 21 | 22.7 | 3 | Keep, Keep, Keep |
| C064 | CE-011 | accepted terminal snapshot sample 必须存在。 | 17 | 23 | 21 | 20.3 | 6 | Merge, Keep, Keep |
| C065 | CE-012 | clarify/missing-slot terminal snapshot sample 必须存在。 | 17 | 23 | 21 | 20.3 | 6 | Merge, Keep, Keep |
| C066 | CE-013 | unsupported/no-tool terminal snapshot sample 必须存在。 | 17 | 23 | 21 | 20.3 | 6 | Merge, Keep, Keep |
| C067 | CE-014 | safety refusal terminal snapshot sample 必须存在。 | 17 | 23 | 24 | 21.3 | 7 | Merge, Keep, Keep |
| C068 | CE-015 | already-state terminal snapshot sample 必须存在。 | 17 | 23 | 23 | 21.0 | 6 | Merge, Keep, Keep |
| C069 | CE-016 | timeout runtimeError terminal snapshot sample 必须存在。 | 17 | 23 | 24 | 21.3 | 7 | Merge, Keep, Keep |
| C070 | CE-017 | cancelled terminal snapshot sample 必须存在。 | 17 | 23 | 21 | 20.3 | 6 | Merge, Keep, Keep |
| C071 | CE-018 | interrupted/barge-in terminal snapshot sample 必须存在。 | 17 | 23 | 21 | 20.3 | 6 | Merge, Keep, Keep |
| C072 | CE-019 | partial accept/refuse terminal snapshot sample 必须存在或明确 local-only。 | 17 | 23 | 22 | 20.7 | 6 | Merge, Keep, Keep |
| C073 | CE-020 | mainline flat `cards` 与 UIUE `activeCells` 如何对齐。 | 24 | 18 | 22 | 21.3 | 6 | Keep, Merge, Keep |
| C074 | CE-021 | siblingCells/mode 信息是否进入 mainline snapshot。 | 24 | 18 | 17 | 19.7 | 7 | Keep, Merge, Rewrite |
| C075 | CE-022 | refusedCell 是否支持多 refused cells。 | 18 | 18 | 19 | 18.3 | 1 | Rewrite, Merge, Keep |
| C076 | CE-023 | scopeOrigin 是 snapshot-level 还是 per-cell map。 | 24 | 18 | 19 | 20.3 | 6 | Keep, Merge, Keep |
| C077 | CE-024 | context(speed/gear/weather/time) 是否进入 shared snapshot 或 effect channel。 | 24 | 19 | 19 | 20.7 | 5 | Keep, Keep, Keep |
| C078 | CE-025 | readbacks 数组顺序和“最后一条为准”规则。 | 24 | 18 | 22 | 21.3 | 6 | Keep, Merge, Keep |
| C079 | CE-026 | dialogText/readbacks/matrix dialog 的 copy priority。 | 24 | 18 | 19 | 20.3 | 6 | Keep, Merge, Merge |
| C080 | CE-027 | empty cards 合法结果类: clarify/error/cancel 是否可空。 | 17 | 18 | 19 | 18.0 | 2 | Merge, Merge, Keep |
| C081 | CE-028 | timestamp 是 event time、snapshot time 还是 commit time。 | 24 | 18 | 16 | 19.3 | 8 | Keep, Merge, Rewrite |
| C082 | CE-029 | `cardsDidStartChanging` 是否进入 event gates。 | 17 | 18 | 19 | 18.0 | 2 | Merge, Merge, Spike |
| C083 | CE-030 | `readbackReady` 是否进入 event gates。 | 17 | 18 | 19 | 18.0 | 2 | Merge, Merge, Spike |
| C084 | CE-031 | `ttsStart/ttsEnd` 是 effect event 还是 snapshot state。 | 17 | 18 | 19 | 18.0 | 2 | Merge, Merge, Spike |
| C085 | CE-032 | timeout 作为 event/result/terminal snapshot 三层如何对应。 | 24 | 22 | 23 | 23.0 | 2 | Keep, Merge, Keep |
| C086 | CE-033 | `force_context_state` 是否进 `DemoInteractionEventKind`。 | 24 | 18 | 19 | 20.3 | 6 | Keep, Merge, Rewrite |
| C087 | CE-034 | `cardTap` payload 必填 key/family, 缺失 fail-closed。 | 24 | 18 | 20 | 20.7 | 6 | Keep, Merge, Keep |
| C088 | CE-035 | micStart/micEnd 是否推进 voiceState 或只作 input trace。 | 17 | 18 | 18 | 17.7 | 1 | Merge, Merge, Rewrite |
| C089 | CE-036 | background/suspend/resume 对 running turn 的 terminal/cancel 规则。 | 24 | 18 | 23 | 21.7 | 6 | Keep, Merge, Keep |
| C090 | CE-037 | `thinkAnalyzing` 与 `safetyThink` 是否类型化。 | 17 | 18 | 18 | 17.7 | 1 | Merge, Merge, Merge |
| C091 | CE-038 | 最小 1s guard 与固定 3s theatre 的边界。 | 17 | 18 | 22 | 19.0 | 5 | Merge, Merge, Keep |
| C092 | CE-039 | macro_id 源必须来自 Core, UIUE 不判语义。 | 17 | 19 | 20 | 18.7 | 3 | Merge, Keep, Keep |
| C093 | CE-040 | macro narration 用 2 字段, 禁回到三段 fixed calling。 | 17 | 19 | 16 | 17.3 | 3 | Merge, Keep, Rewrite |
| C094 | CE-041 | orbState 与 voiceState 冲突裁决。 | 17 | 18 | 23 | 19.3 | 6 | Merge, Merge, Keep |
| C095 | CE-042 | Reduce Motion 每态非动画等价物证明。 | 17 | 18 | 20 | 18.3 | 3 | Merge, Merge, Keep |
| C096 | CE-043 | shader/GPU budget 与 MLX runtime 抢资源的门。 | 18 | 16 | 19 | 17.7 | 3 | Spike, Spike, Spike |
| C097 | CE-044 | mainline/UIUE proof class crosswalk。 | 24 | 23 | 24 | 23.7 | 1 | Keep, Keep, Keep |
| C098 | CE-045 | result enum crosswalk, 尤其 UIUE partial 与 mainline absence。 | 24 | 18 | 22 | 21.3 | 6 | Keep, Merge, Keep |
| C099 | CE-046 | `scopeOrigin=nil` 的合法边界。 | 24 | 18 | 23 | 21.7 | 6 | Keep, Merge, Keep |
| C100 | CE-047 | string key migration proof for `scopeOrigins/activeCells`。 | 24 | 18 | 20 | 20.7 | 6 | Keep, Merge, Keep |
| C101 | CE-048 | adapter fixture golden cases 覆盖 8 类结果。 | 17 | 23 | 24 | 21.3 | 7 | Merge, Rewrite, Keep |
| C102 | CE-049 | “runtime-driven orb” 在无 runtime logs 前改名 fixture-driven。 | 17 | 19 | 24 | 20.0 | 7 | Merge, Rewrite, Keep |
| C103 | CE-050 | matrix entry proof 与 snapshot proof 的覆盖优先级。 | 17 | 19 | 19 | 18.3 | 2 | Merge, Rewrite, Merge |
| C104 | CE-051 | UIUE 禁在 mainline verdict 前新增 shared field。 | 24 | 19 | 24 | 22.3 | 5 | Keep, Rewrite, Keep |
| C105 | CE-052 | proof ladder: docs/static/unit/simulator/operator/true-device/live。 | 24 | 23 | 24 | 23.7 | 1 | Keep, Keep, Keep |
| C106 | CE-053 | screenshot anchor no-promotion machine guard。 | 24 | 23 | 24 | 23.7 | 1 | Keep, Keep, Keep |
| C107 | CE-054 | R5 receipt 必带 non-claims checkbox。 | 17 | 23 | 24 | 21.3 | 7 | Merge, Rewrite, Keep |
| C108 | CE-055 | validation gate 按 touched paths 切换。 | 17 | 23 | 20 | 20.0 | 6 | Merge, Rewrite, Keep |
| C109 | CE-056 | stale wording grep 必查 `R5_PRECONDITIONS_BLOCKED/not_proposed/missing`。 | 17 | 23 | 21 | 20.3 | 6 | Merge, Rewrite, Keep |
| C110 | CE-057 | 双 repo dirty status 分开记录, 不混提交。 | 24 | 23 | 21 | 22.7 | 3 | Keep, Rewrite, Keep |
| C111 | CE-058 | mainline/UIUE OpenSpec strict 各跑各的。 | 24 | 23 | 21 | 22.7 | 3 | Keep, Rewrite, Keep |
| C112 | CE-059 | raw ASR 只能 trace, 不作 memory/training/golden authority。 | 14 | 13 | 23 | 16.7 | 10 | DeferFutureLane, DeferFutureLane, Keep |
| C113 | CE-060 | normalizer confidence gate 决定是否 update focus。 | 17 | 13 | 19 | 16.3 | 6 | Merge, DeferFutureLane, Keep |
| C114 | CE-061 | TTS/UX committed 后才写 assistant context。 | 17 | 13 | 22 | 17.3 | 9 | Merge, DeferFutureLane, Keep |
| C115 | CE-062 | barge-in 后禁止未播出文本进入下一轮事实。 | 17 | 13 | 23 | 17.7 | 10 | Merge, DeferFutureLane, Keep |
| C116 | CE-063 | TTS 与录音会话串行互斥。 | 17 | 13 | 23 | 17.7 | 10 | Merge, DeferFutureLane, Keep |
| C117 | CE-064 | premium 普通话 voice preflight 与 fallback。 | 14 | 16 | 19 | 16.3 | 5 | DeferFutureLane, Spike, DeferFutureLane |
| C118 | CE-065 | voiceState `unavailable` 与 `idle` 区分。 | 17 | 13 | 20 | 16.7 | 7 | Merge, DeferFutureLane, Keep |
| C119 | CE-066 | PTT/tap/hold 语义与 MicDock 文案一致。 | 17 | 13 | 20 | 16.7 | 7 | Merge, DeferFutureLane, Keep |
| C120 | CE-067 | golden step runtime_mounted + state_cells + whitelist digest precheck。 | 14 | 23 | 24 | 20.3 | 10 | DeferFutureLane, Rewrite, DeferFutureLane |
| C121 | CE-068 | golden replay 校验 revision delta/no-delta + readback_ok。 | 14 | 23 | 24 | 20.3 | 10 | DeferFutureLane, Rewrite, DeferFutureLane |
| C122 | CE-069 | golden/script/storyboard 文案禁直接进 C5 train/dev/test。 | 14 | 21 | 23 | 19.3 | 9 | DeferFutureLane, DeferFutureLane, Keep |
| C123 | CE-070 | C6 shape replay 与 model-quality proof 分离。 | 15 | 21 | 23 | 19.7 | 8 | DeferFutureLane, DeferFutureLane, Keep |
| C124 | CE-071 | Qwen sampling 按 behavior class 拆测, 不看 aggregate。 | 14 | 16 | 19 | 16.3 | 5 | DeferFutureLane, Spike, DeferFutureLane |
| C125 | CE-072 | KV prewarm 绑定 prompt/state hash, stale cache 不算 warm pass。 | 14 | 16 | 19 | 16.3 | 5 | DeferFutureLane, Spike, DeferFutureLane |
| C126 | CE-073 | Liquid4All H5 fullState/functions.json 禁当 MAformac SSOT。 | 20 | 10 | 20 | 16.7 | 10 | Spike, Drop, Keep |
| C127 | CE-074 | `/ws-audio` 只作 local runtime teardown 灵感。 | 14 | 10 | 13 | 12.3 | 4 | DeferFutureLane, Drop, Drop |
| C128 | CE-075 | 外部 code/asset/license transfer 前置 provenance checklist。 | 14 | 10 | 23 | 15.7 | 13 | DeferFutureLane, Drop, Keep |
| C129 | CE-076 | 外部 issue/bug 只能启发 premortem, 不能替代 local proof。 | 15 | 10 | 17 | 14.0 | 7 | DeferFutureLane, Drop, Keep |
| C130 | CE-077 | display-only direct touch 必有 disabled/read-only affordance。 | 17 | 14 | 23 | 18.0 | 9 | Merge, DeferHuman, Keep |
| C131 | CE-078 | summary direct-control policy: 展示、跳转、guard 后控制三选一。 | 17 | 14 | 22 | 17.7 | 8 | Merge, DeferHuman, Keep |
| C132 | CE-079 | gear direct-touch safety policy: 默认 display-only unless approved。 | 17 | 14 | 23 | 18.0 | 9 | Merge, DeferHuman, Keep |
| C133 | CE-080 | 44pt/VoiceOver/mobile/true-device proof ladder 单独 lane。 | 15 | 13 | 24 | 17.3 | 11 | DeferHuman, DeferFutureLane, DeferFutureLane |
| C134 | CE-081 | white-edge threshold 保留 WARN 或 formalize, 禁偷写 PASS。 | 13 | 14 | 17 | 14.7 | 4 | DeferHuman, DeferHuman, DeferHuman |
| C135 | CE-082 | capsule final-art 是 human/product visual lane, 不阻塞 R5 dispatch。 | 13 | 14 | 16 | 14.3 | 3 | DeferHuman, DeferHuman, DeferHuman |
| C136 | MC-001 | `DemoRuntimeOutcome.reason / missingSlot / scopeFailureReason` 的优先级和互斥规则。 | 24 | 22 | 19 | 21.7 | 5 | Keep, Merge, Merge |
| C137 | MC-002 | `behaviorClassSource` 在 accepted 和 non-accepted 结果中的填充规则。 | 24 | 18 | 20 | 20.7 | 6 | Keep, Merge, Keep |
| C138 | MC-003 | `isTerminal` 由结果类派生还是 runtime adapter 显式写入。 | 24 | 18 | 23 | 21.7 | 6 | Keep, Merge, Keep |
| C139 | MC-004 | `cards` 允许空数组的结果类和 UI empty-state 策略。 | 17 | 18 | 19 | 18.0 | 2 | Merge, Merge, Merge |
| C140 | MC-005 | `readbacks` 的顺序规则: 时间、卡片、最后一条为准。 | 24 | 18 | 21 | 21.0 | 6 | Keep, Merge, Merge |
| C141 | MC-006 | `dialogText` 与 `readbacks` 的 canonical human copy 裁决。 | 24 | 18 | 18 | 20.0 | 6 | Keep, Merge, Merge |
| C142 | MC-007 | `TraceEnvelope.traceID` 与 snapshot `traceID` 是否必须一致。 | 24 | 22 | 20 | 22.0 | 4 | Keep, Merge, Keep |
| C143 | MC-008 | `TraceEnvelope.entries` append-only 与阶段/时间单调性。 | 24 | 22 | 20 | 22.0 | 4 | Keep, Merge, Keep |
| C144 | MC-009 | snapshot `timestamp` 的时钟源和语义。 | 24 | 22 | 15 | 20.3 | 9 | Keep, Merge, Merge |
| C145 | MC-010 | `cancel` 与 `interruption` 的触发源、结果和恢复语义。 | 17 | 22 | 22 | 20.3 | 5 | Merge, Merge, Keep |
| C146 | MC-011 | `cardTap` 是否必须携带 `cardKey`, 缺失如何 fail-closed。 | 17 | 18 | 19 | 18.0 | 2 | Merge, Merge, Merge |
| C147 | MC-012 | `micStart/micEnd` 是输入事件还是必须驱动 voiceState。 | 17 | 18 | 17 | 17.3 | 1 | Merge, Merge, Merge |
| C148 | MC-013 | `voiceState` 与 `orbState` 同时非空时的主显示源和冲突裁决。 | 17 | 18 | 22 | 19.0 | 5 | Merge, Merge, Merge |
| C149 | MC-014 | `PresentationProofClass.displayCaps` 永远空是永久合同还是临时保守值。 | 24 | 18 | 24 | 22.0 | 6 | Keep, Merge, Keep |
| C150 | MC-015 | 未知 `PresentationProofClass` JSON 是否所有 consumer 都 fail-closed。 | 24 | 23 | 24 | 23.7 | 1 | Keep, Rewrite, Keep |
| C151 | MC-016 | `PresentationReadinessClaim` 是 shared API 还是未来占位符。 | 24 | 19 | 20 | 21.0 | 5 | Keep, Rewrite, Keep |
| C152 | MC-017 | snapshot `scopeFailureReason` 与 outcome `scopeFailureReason` 是否镜像。 | 24 | 18 | 19 | 20.3 | 6 | Keep, Merge, Merge |
| C153 | MC-018 | `scopeOrigin=nil` 的合法边界, 禁把 nil 当 defaulted。 | 24 | 18 | 21 | 21.0 | 6 | Keep, Merge, Merge |
| C154 | UC-001 | UIUE proof enum 与 mainline proof enum 的 crosswalk。 | 24 | 22 | 22 | 22.7 | 2 | Keep, Merge, Merge |
| C155 | UC-002 | `operatorReview` 能否出现在产品界面, 且不得等于 acceptance。 | 13 | 20 | 23 | 18.7 | 10 | DeferHuman, DeferHuman, Keep |
| C156 | UC-003 | UIUE matrix entry proof 与 snapshot proof 的优先级。 | 24 | 18 | 18 | 20.0 | 6 | Keep, Merge, Merge |
| C157 | UC-004 | partial accept/refuse 需 accepted/refused per-cell payload 后才做复杂混合 outcome。 | 24 | 23 | 22 | 23.0 | 2 | Keep, Rewrite, Keep |
| C158 | UC-005 | `dialogText/readbacks/matrix dialogText` 冲突时 UI/TTS/VO 的来源优先级。 | 24 | 18 | 18 | 20.0 | 6 | Keep, Merge, Merge |
| C159 | UC-006 | already-state 与 accepted 都 satisfied 时 a11y/readback 必须区分。 | 17 | 16 | 23 | 18.7 | 7 | Merge, Rewrite, Keep |
| C160 | UC-007 | card `accessibilityLabel` 是否包含 scope/reason/proof/read-only。 | 15 | 14 | 20 | 16.3 | 6 | DeferHuman, DeferHuman, Keep |
| C161 | UC-008 | `ValueControlView` direct controls 的 a11y value/hint/range。 | 13 | 14 | 20 | 15.7 | 7 | DeferHuman, DeferHuman, Keep |
| C162 | UC-009 | MicDock button tap 与“按住说话”文案的语义错配。 | 13 | 14 | 21 | 16.0 | 8 | DeferHuman, DeferHuman, Keep |
| C163 | UC-010 | context capsule a11y 是否读出速度/天气/挡位。 | 13 | 14 | 17 | 14.7 | 4 | DeferHuman, DeferHuman, Keep |
| C164 | UC-011 | expanded overlay 的 escape action、button trait 与 focus return。 | 13 | 14 | 20 | 15.7 | 7 | DeferHuman, DeferHuman, Keep |
| C165 | UC-012 | cancel/cancelled 映射 normal 后保留 terminal proof 和 announcement。 | 17 | 22 | 20 | 19.7 | 5 | Merge, Merge, Keep |
| C166 | UC-013 | runtimeError 区分 timeout/adapter/presentation fixture failure。 | 17 | 22 | 22 | 20.3 | 5 | Merge, Merge, Keep |
| C167 | UC-014 | Reduced Motion policy 是否有非动画 UI proof fixture。 | 17 | 17 | 19 | 17.7 | 2 | Merge, Merge, Merge |
| C168 | UC-015 | string-key `scopeOrigins` 改名后如何避免静默错配。 | 24 | 17 | 19 | 20.0 | 7 | Keep, Merge, Merge |
| C169 | UC-016 | `activeCells` 多 active/mixed outcome 的顺序、主次、focus priority。 | 24 | 17 | 23 | 21.3 | 7 | Keep, Merge, Keep |
| C170 | UC-017 | U15 counterexample fixture 补 already-state/runtime-error/cancelled。 | 17 | 22 | 21 | 20.0 | 5 | Merge, Merge, Keep |
| C171 | UC-018 | screenshot anchor proof-class 命名后禁被引用为 runtime/mobile proof。 | 17 | 22 | 23 | 20.7 | 6 | Merge, Merge, Keep |
| C172 | UC-019 | display-only summary/gear 需要 disabled affordance 和 a11y “仅展示”。 | 13 | 14 | 22 | 16.3 | 9 | DeferHuman, DeferHuman, Merge |
| C173 | UC-020 | a11y proof ladder 区分 local/static/simulator/true-device。 | 15 | 20 | 23 | 19.3 | 8 | DeferHuman, DeferHuman, Merge |
| C174 | UC-021 | safety refusal 中 orbState think 与 matrix tts speaking 的 lifecycle。 | 17 | 17 | 22 | 18.7 | 5 | Merge, Merge, Keep |
| C175 | UC-022 | mock voice state contradiction: orb speak + voice idle 要标非真实 TTS。 | 17 | 17 | 23 | 19.0 | 6 | Merge, Merge, Keep |
| C176 | PV-001 | `ToolExecutionError` 到 outcome 的完整分类, 尤其 guardDenied。 | 24 | 22 | 22 | 22.7 | 2 | Keep, Merge, Keep |
| C177 | PV-002 | 每个 terminal outcome 都要 sample terminal snapshot fixture。 | 17 | 22 | 24 | 21.0 | 7 | Merge, Merge, Keep |
| C178 | PV-003 | mainline 缺 partial, UIUE 已有 partial, 是否 canonical 或 local-only。 | 24 | 18 | 23 | 21.7 | 6 | Keep, Merge, Keep |
| C179 | PV-004 | proof enum 必须 translation, 禁 raw value 直传。 | 24 | 18 | 24 | 22.0 | 6 | Keep, Merge, Keep |
| C180 | PV-005 | `displayCaps` 永远空还是未来可打开, 谁开。 | 24 | 18 | 18 | 20.0 | 6 | Keep, Merge, Merge |
| C181 | PV-006 | think 两语义是否需要两个 enum/state。 | 17 | 18 | 17 | 17.3 | 1 | Merge, Merge, Merge |
| C182 | PV-007 | `cards_did_start_changing/readback_ready/tts_start/tts_end` 是否进 event kind。 | 24 | 18 | 18 | 20.0 | 6 | Keep, Merge, Spike |
| C183 | PV-008 | `force_context_state` 必须 demo-mode 隔离和 trace provenance。 | 24 | 18 | 22 | 21.3 | 6 | Keep, Merge, Merge |
| C184 | PV-009 | `activeCell/siblingCells` 在 mainline snapshot 的表达方式。 | 24 | 18 | 18 | 20.0 | 6 | Keep, Merge, Rewrite |
| C185 | PV-010 | already-state 证明 no revision bump、ack/readback、非 accepted delta。 | 24 | 23 | 24 | 23.7 | 1 | Keep, Rewrite, Keep |
| C186 | PV-011 | cancel/interruption 后禁止 stale async mutate cards。 | 24 | 23 | 23 | 23.3 | 1 | Keep, Rewrite, Keep |
| C187 | PV-012 | terminal snapshot 覆盖 `isTerminal=false -> true` 唯一合法转移。 | 24 | 23 | 24 | 23.7 | 1 | Keep, Rewrite, Keep |
| C188 | PV-013 | “runtime-driven orb binding” 在无 runtime logs 前只能叫 fixture-driven。 | 17 | 18 | 22 | 19.0 | 5 | Merge, Merge, Merge |
| C189 | PV-014 | C5/C6/golden/voice proof lane 独立 checkbox 禁互相替代。 | 24 | 22 | 24 | 23.3 | 2 | Keep, Merge, Keep |
| C190 | PV-015 | C6 acceptance/comparison 何时才从 bridge work 解冻。 | 14 | 13 | 19 | 15.3 | 6 | DeferFutureLane, DeferFutureLane, DeferFutureLane |
| C191 | PV-016 | voice lane 首 gate 是功能坑 spike, 不是 UIUE voiceState。 | 18 | 13 | 23 | 18.0 | 10 | Spike, DeferFutureLane, DeferFutureLane |
| C192 | PV-017 | Liquid4All reject direct copy checklist。 | 17 | 14 | 19 | 16.7 | 5 | Merge, DeferHuman, Merge |
| C193 | PV-018 | L0/L1/L2/L3 visual proof 绑定 proof-class cap, L1/L2 不关闭 L3。 | 17 | 23 | 24 | 21.3 | 7 | Merge, Rewrite, Keep |
| C194 | PV-019 | summary/gear direct touch 前先定义 disabled/safety/readback/a11y policy。 | 13 | 14 | 22 | 16.3 | 9 | DeferHuman, DeferHuman, Keep |
| C195 | PV-020 | R5 closeout hard gate: mainline dirty residual 与 UIUE clean 分开记录。 | 24 | 23 | 21 | 22.7 | 3 | Keep, Rewrite, Keep |
| C196 | PV-021 | docs-only vs Swift/UI touched 的 validation gate 每 lane 明确。 | 24 | 23 | 20 | 22.3 | 4 | Keep, Rewrite, Keep |
| C197 | PV-022 | C3 parser fallback/repair 是否进 runtime adapter error feedback strategy。 | 14 | 16 | 19 | 16.3 | 5 | DeferFutureLane, Spike, DeferFutureLane |
| C198 | MVG-001 | golden step 进入前校验 runtime_mounted、required_state_cells、whitelist digest。 | 14 | 22 | 22 | 19.3 | 8 | DeferFutureLane, Merge, Merge |
| C199 | MVG-002 | golden replay 断言 state_revision before/after、readback_ok、no unexpected delta。 | 14 | 22 | 22 | 19.3 | 8 | DeferFutureLane, Merge, Merge |
| C200 | MVG-003 | already_state_noop 进入 C6/golden 样本, 不算 success_with_delta。 | 17 | 22 | 24 | 21.0 | 7 | Merge, Merge, Keep |
| C201 | MVG-004 | partial accept/refuse readback 逐 cell 列 accepted/refused。 | 24 | 22 | 23 | 23.0 | 2 | Keep, Merge, Keep |
| C202 | MVG-005 | voice memory 7 seeds 升级为正式 C6/golden seeds 或明确 deferred。 | 14 | 13 | 19 | 15.3 | 6 | DeferFutureLane, DeferFutureLane, DeferFutureLane |
| C203 | MVG-006 | assistant context commit 等 TTS/UX committed, barge-in 后不写下一轮焦点。 | 17 | 17 | 22 | 18.7 | 5 | Merge, Merge, Merge |
| C204 | MVG-007 | raw ASR 只进 trace, train/memory/golden label 用 normalizer output。 | 14 | 17 | 22 | 17.7 | 8 | DeferFutureLane, Merge, Merge |
| C205 | MVG-008 | low-confidence ASR no-focus-update fixture, 禁 UIUE mock transcript 证明 voice-ready。 | 14 | 22 | 23 | 19.7 | 9 | DeferFutureLane, Merge, Keep |
| C206 | MVG-009 | TTS 与录音会话互斥进入 voice state machine 测试。 | 14 | 22 | 22 | 19.3 | 8 | DeferFutureLane, Merge, Merge |
| C207 | MVG-010 | endpoint decode parity 统计 toolCall/content JSON/parser_repair/false tool call 分布。 | 18 | 16 | 19 | 17.7 | 3 | Spike, Spike, DeferFutureLane |
| C208 | MVG-011 | Mac dev Outlines/XGrammar fixture 标 dev_only, 禁当 iOS proof。 | 20 | 21 | 20 | 20.3 | 1 | Spike, DeferFutureLane, Keep |
| C209 | MVG-012 | Qwen sampling 按 behavior class 拆测 temp0.6 vs 0.1。 | 14 | 16 | 18 | 16.0 | 4 | DeferFutureLane, Spike, Merge |
| C210 | MVG-013 | KV prewarm 绑定 prompt/state hash, stale cache 不算 warm-path pass。 | 14 | 16 | 18 | 16.0 | 4 | DeferFutureLane, Spike, Merge |
| C211 | MVG-014 | golden/script 文案禁直接进 C5 train/dev/test, 除非 data contract。 | 14 | 13 | 21 | 16.0 | 8 | DeferFutureLane, DeferFutureLane, Merge |
| C212 | MVG-015 | scene macro 带 `planned_not_golden`, golden upgrade 单独签。 | 14 | 13 | 20 | 15.7 | 7 | DeferFutureLane, DeferFutureLane, Keep |
| C213 | MVG-016 | UIUE local fixture proofClass unknown/缺失时 fail-closed。 | 24 | 23 | 24 | 23.7 | 1 | Keep, Rewrite, Keep |
| C214 | MVG-017 | terminal snapshot 包含 timeout/cancel/interrupted finality 防 stale async mutate。 | 24 | 22 | 24 | 23.3 | 2 | Keep, Merge, Keep |
| C215 | MVG-018 | C6/golden 区分 local_shape_no_model replay 与 model_quality。 | 24 | 21 | 22 | 22.3 | 3 | Keep, DeferFutureLane, Merge |

## Divergent Candidates

| Candidate | Original | Scores | Spread | Dispute type | Next action |
|---|---|---|---:|---|---|
| C128 | CE-075 | [14, 10, 23] | 13 | 混合 | Final judge must split proof-route from candidate value. |
| C133 | CE-080 | [15, 13, 24] | 11 | 事实型 | If factual and needs runtime/device evidence, route to spike; otherwise cite source/test. |
| C120 | CE-067 | [14, 23, 24] | 10 | 混合 | Final judge must split proof-route from candidate value. |
| C121 | CE-068 | [14, 23, 24] | 10 | 混合 | Final judge must split proof-route from candidate value. |
| C155 | UC-002 | [13, 20, 23] | 10 | 事实型 | If factual and needs runtime/device evidence, route to spike; otherwise cite source/test. |
| C191 | PV-016 | [18, 13, 23] | 10 | 事实型 | If factual and needs runtime/device evidence, route to spike; otherwise cite source/test. |
| C115 | CE-062 | [17, 13, 23] | 10 | 混合 | Final judge must split proof-route from candidate value. |
| C116 | CE-063 | [17, 13, 23] | 10 | 混合 | Final judge must split proof-route from candidate value. |
| C043 | RPB-43 | [14, 13, 23] | 10 | 混合 | Final judge must split proof-route from candidate value. |
| C112 | CE-059 | [14, 13, 23] | 10 | 混合 | Final judge must split proof-route from candidate value. |
| C126 | CE-073 | [20, 10, 20] | 10 | 事实型 | If factual and needs runtime/device evidence, route to spike; otherwise cite source/test. |
| C144 | MC-009 | [24, 22, 15] | 9 | 口径型 | Do not re-score; final judge chooses merge/rewrite target. |
| C205 | MVG-008 | [14, 22, 23] | 9 | 混合 | Final judge must split proof-route from candidate value. |
| C122 | CE-069 | [14, 21, 23] | 9 | 混合 | Final judge must split proof-route from candidate value. |
| C130 | CE-077 | [17, 14, 23] | 9 | 口径型 | Do not re-score; final judge chooses merge/rewrite target. |
| C132 | CE-079 | [17, 14, 23] | 9 | 口径型 | Do not re-score; final judge chooses merge/rewrite target. |
| C037 | RPB-37 | [18, 13, 22] | 9 | 混合 | Final judge must split proof-route from candidate value. |
| C114 | CE-061 | [17, 13, 22] | 9 | 混合 | Final judge must split proof-route from candidate value. |
| C172 | UC-019 | [13, 14, 22] | 9 | 口径型 | Do not re-score; final judge chooses merge/rewrite target. |
| C194 | PV-019 | [13, 14, 22] | 9 | 事实型 | If factual and needs runtime/device evidence, route to spike; otherwise cite source/test. |
| C123 | CE-070 | [15, 21, 23] | 8 | 混合 | Final judge must split proof-route from candidate value. |
| C081 | CE-028 | [24, 18, 16] | 8 | 口径型 | Do not re-score; final judge chooses merge/rewrite target. |
| C173 | UC-020 | [15, 20, 23] | 8 | 口径型 | Do not re-score; final judge chooses merge/rewrite target. |
| C198 | MVG-001 | [14, 22, 22] | 8 | 混合 | Final judge must split proof-route from candidate value. |
| C199 | MVG-002 | [14, 22, 22] | 8 | 混合 | Final judge must split proof-route from candidate value. |
| C206 | MVG-009 | [14, 22, 22] | 8 | 混合 | Final judge must split proof-route from candidate value. |
| C131 | CE-078 | [17, 14, 22] | 8 | 口径型 | Do not re-score; final judge chooses merge/rewrite target. |
| C204 | MVG-007 | [14, 17, 22] | 8 | 混合 | Final judge must split proof-route from candidate value. |
| C162 | UC-009 | [13, 14, 21] | 8 | 事实型 | If factual and needs runtime/device evidence, route to spike; otherwise cite source/test. |
| C211 | MVG-014 | [14, 13, 21] | 8 | 混合 | Final judge must split proof-route from candidate value. |

## Gaps For Final Judge

- Collapse repeated proof-class rows into canonical proof ladder without losing original provenance.
- Create route counts for downstream mainline/UIUE burndown.
- Mark future-lane rows clearly so they do not become R5 dispatch blockers or false readiness claims.
- Preserve human-review/product-policy rows as review gates, not Swift truth.

## Non-Claims

No runtime-ready, mobile, true_device, voice-ready, model-ready, golden-ready, endpoint-ready, UIUE merge, V-PASS, S-PASS, U-PASS, or A-2 complete claim is made by this Round 02 judge.

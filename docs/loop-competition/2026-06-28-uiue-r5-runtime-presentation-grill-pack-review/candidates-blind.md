# Blind Candidates - UIUE R5 Runtime-Presentation Grill Pack Review

date: 2026-06-28
mode: fixed blind set
candidate_count: 215

Only question text is included here. Original IDs, owner, priority, source bucket, default recommendation, and prior rationale are intentionally stripped.

| Candidate | Question |
|---|---|
| C001 | 边界 override 只能是 snapshot consume + bridge event write, 不能自由 mutate store。 |
| C002 | 三车道分类: UIUE local, shared bridge, mainline runtime。 |
| C003 | bridge 4 名和字段名必须由 mainline carrier/DTO 锁定。 |
| C004 | store ownership: presentation 消费 snapshot, 不读 raw runtime store。 |
| C005 | 写所有权: 触摸/事件走 executor 或 runtime adapter, 不直接写 store。 |
| C006 | 事件集必须封闭, 包含 text/mic/card/cancel/interruption/timeout 等。 |
| C007 | 事件 payload 必须区分 source/provenance 与 scope_origin/resolution。 |
| C008 | scope 展示读结构化字段, UI/TTS 禁从中文推断 scope。 |
| C009 | Runtime result enum 保持机器可读, 不用裸 rejected。 |
| C010 | 拒识词表要区分 unsupported/safety/clarify/already-state/runtime-error。 |
| C011 | 视觉映射为结果到 7 态的派生, 不是 runtime 结果本身。 |
| C012 | guard denial 必须投影成 presentation-safe refusal snapshot。 |
| C013 | unsafe R2 展示 active/refused cell 和 safety reason, 不暴露速度等敏感内情。 |
| C014 | already_state_noop 独立结果, 视觉可 satisfied 但语义非 accepted delta。 |
| C015 | clamp 成功路径要说实际 clamp 值, trace 标 clamped。 |
| C016 | 真 multi-intent splitter deferred, Phase4/5 只可 sequencer/force-state。 |
| C017 | partial deny 需要综合 snapshot, 逐 cell 混态与综合 readback。 |
| C018 | SceneMacroRegistry 属 Core config, 非 UIUE-only 隐藏 planner。 |
| C019 | 环境上下文是 runtime context, 非车控卡, 但可显示事实。 |
| C020 | reset preset 清 vehicle/dialogue/trace/orb/voice/context。 |
| C021 | think 应事件驱动, 不写固定计时剧场。 |
| C022 | cancel/interruption/timeout/backgrounding 必须有终态 snapshot。 |
| C023 | ASR/TTS 边界: backend 接 text, voice-ready 需真机 ASR/TTS proof。 |
| C024 | TraceEnvelope 最小字段和 redaction 需要锁。 |
| C025 | proof class 上限: UIUE screenshot/simulator 不能变 runtime/mobile/V-PASS。 |
| C026 | 现态推理/感受词走 C3 相对 EXP 或 later LoRA, 不在 UIUE 自建。 |
| C027 | normalize/range/EXP 复用 C3, UIUE 不重复相对调温逻辑。 |
| C028 | range 源来自 StateCellContractLookup 或同等 SSOT。 |
| C029 | active cell 优先级需定义, refused 可压过 satisfied。 |
| C030 | snapshot card schema 要带 scope/reason/active/sibling 等呈现所需语义。 |
| C031 | family 覆盖 10 族 + context, 天气/时段不是第 11 族车控卡。 |
| C032 | dialogue ownership 分 runtime readback、assistant copy、presentation styling。 |
| C033 | orb 状态来源是 composite, 非视觉自嗨。 |
| C034 | Reduce Motion 必须有非动画通道。 |
| C035 | Mac/iOS bridge 字段一致, layout 差异 layout-only。 |
| C036 | 模拟器不等于真机, 质感/音频/性能/热须 true-device lane。 |
| C037 | 离线 bundle, 无网无 Python, Python 只可 dev spike。 |
| C038 | persistence 仅 DialogueState 短时, 不做 cloud/long memory。 |
| C039 | crash/unknown 不可用于正常 unsupported/refusal。 |
| C040 | settings/reset 中 theme 是 presentation-only, force/reset 是 runtime input。 |
| C041 | UIUE scripted runs 可作 future golden candidate, 非 golden proof。 |
| C042 | UIUE 视觉绝不选模型候选, candidate comparison 是 later mainline。 |
| C043 | UIUE 文案/case 不能直接进入训练数据。 |
| C044 | Accessibility deferred 但不能消失, 双通道只覆盖一部分。 |
| C045 | screenshot anchor 命名含 platform/state/proof/source。 |
| C046 | receipt 格式需 command/device/proof/touched/residual。 |
| C047 | merge-readiness 标记只能是 contract aligned not merged。 |
| C048 | reviewer 必告 live HEAD, no stale SHA。 |
| C049 | 未决 P0/P1 carry-forward 必进下个 closeout。 |
| C050 | 哪些落 bridge OpenSpec, 哪些留 UIUE notes 需 landing matrix。 |
| C051 | snapshot card 必带 sibling/secondary/active 信息以支持制冷/制热与主值。 |
| C052 | force-state context 输入需 `#if DEMO_MODE` + bridge event + trace provenance。 |
| C053 | think 两语义: analyzing 事件驱动与 safety fixed 1s 演出例外。 |
| C054 | `ToolExecutionError` 到 `DemoRuntimeOutcome` 的完整映射表。 |
| C055 | `guardDenied` 应细分 safety/refusal/unsupported/runtime_error。 |
| C056 | `semanticInvalid("missing_default_scope")` 应映射 clarify/missing scope, 不进 Core enum。 |
| C057 | unsupported 与 safety refusal 必须有不同 reason taxonomy。 |
| C058 | runtimeError 需分 timeout/decode/store/model/adapter failure。 |
| C059 | cancellation 与 interruption 的触发源和恢复语义分开。 |
| C060 | adapter 遇 throw 仍必须发 terminal snapshot, 禁 silent failure。 |
| C061 | retry/idempotency 规则: 重试不得二次写 state 或吞掉 no-op。 |
| C062 | snapshot 禁 raw model output, 只带 presentation-safe outcome。 |
| C063 | `behaviorClassSource` preservation: accepted 结果保留 `tool_call` 源。 |
| C064 | accepted terminal snapshot sample 必须存在。 |
| C065 | clarify/missing-slot terminal snapshot sample 必须存在。 |
| C066 | unsupported/no-tool terminal snapshot sample 必须存在。 |
| C067 | safety refusal terminal snapshot sample 必须存在。 |
| C068 | already-state terminal snapshot sample 必须存在。 |
| C069 | timeout runtimeError terminal snapshot sample 必须存在。 |
| C070 | cancelled terminal snapshot sample 必须存在。 |
| C071 | interrupted/barge-in terminal snapshot sample 必须存在。 |
| C072 | partial accept/refuse terminal snapshot sample 必须存在或明确 local-only。 |
| C073 | mainline flat `cards` 与 UIUE `activeCells` 如何对齐。 |
| C074 | siblingCells/mode 信息是否进入 mainline snapshot。 |
| C075 | refusedCell 是否支持多 refused cells。 |
| C076 | scopeOrigin 是 snapshot-level 还是 per-cell map。 |
| C077 | context(speed/gear/weather/time) 是否进入 shared snapshot 或 effect channel。 |
| C078 | readbacks 数组顺序和“最后一条为准”规则。 |
| C079 | dialogText/readbacks/matrix dialog 的 copy priority。 |
| C080 | empty cards 合法结果类: clarify/error/cancel 是否可空。 |
| C081 | timestamp 是 event time、snapshot time 还是 commit time。 |
| C082 | `cardsDidStartChanging` 是否进入 event gates。 |
| C083 | `readbackReady` 是否进入 event gates。 |
| C084 | `ttsStart/ttsEnd` 是 effect event 还是 snapshot state。 |
| C085 | timeout 作为 event/result/terminal snapshot 三层如何对应。 |
| C086 | `force_context_state` 是否进 `DemoInteractionEventKind`。 |
| C087 | `cardTap` payload 必填 key/family, 缺失 fail-closed。 |
| C088 | micStart/micEnd 是否推进 voiceState 或只作 input trace。 |
| C089 | background/suspend/resume 对 running turn 的 terminal/cancel 规则。 |
| C090 | `thinkAnalyzing` 与 `safetyThink` 是否类型化。 |
| C091 | 最小 1s guard 与固定 3s theatre 的边界。 |
| C092 | macro_id 源必须来自 Core, UIUE 不判语义。 |
| C093 | macro narration 用 2 字段, 禁回到三段 fixed calling。 |
| C094 | orbState 与 voiceState 冲突裁决。 |
| C095 | Reduce Motion 每态非动画等价物证明。 |
| C096 | shader/GPU budget 与 MLX runtime 抢资源的门。 |
| C097 | mainline/UIUE proof class crosswalk。 |
| C098 | result enum crosswalk, 尤其 UIUE partial 与 mainline absence。 |
| C099 | `scopeOrigin=nil` 的合法边界。 |
| C100 | string key migration proof for `scopeOrigins/activeCells`。 |
| C101 | adapter fixture golden cases 覆盖 8 类结果。 |
| C102 | “runtime-driven orb” 在无 runtime logs 前改名 fixture-driven。 |
| C103 | matrix entry proof 与 snapshot proof 的覆盖优先级。 |
| C104 | UIUE 禁在 mainline verdict 前新增 shared field。 |
| C105 | proof ladder: docs/static/unit/simulator/operator/true-device/live。 |
| C106 | screenshot anchor no-promotion machine guard。 |
| C107 | R5 receipt 必带 non-claims checkbox。 |
| C108 | validation gate 按 touched paths 切换。 |
| C109 | stale wording grep 必查 `R5_PRECONDITIONS_BLOCKED/not_proposed/missing`。 |
| C110 | 双 repo dirty status 分开记录, 不混提交。 |
| C111 | mainline/UIUE OpenSpec strict 各跑各的。 |
| C112 | raw ASR 只能 trace, 不作 memory/training/golden authority。 |
| C113 | normalizer confidence gate 决定是否 update focus。 |
| C114 | TTS/UX committed 后才写 assistant context。 |
| C115 | barge-in 后禁止未播出文本进入下一轮事实。 |
| C116 | TTS 与录音会话串行互斥。 |
| C117 | premium 普通话 voice preflight 与 fallback。 |
| C118 | voiceState `unavailable` 与 `idle` 区分。 |
| C119 | PTT/tap/hold 语义与 MicDock 文案一致。 |
| C120 | golden step runtime_mounted + state_cells + whitelist digest precheck。 |
| C121 | golden replay 校验 revision delta/no-delta + readback_ok。 |
| C122 | golden/script/storyboard 文案禁直接进 C5 train/dev/test。 |
| C123 | C6 shape replay 与 model-quality proof 分离。 |
| C124 | Qwen sampling 按 behavior class 拆测, 不看 aggregate。 |
| C125 | KV prewarm 绑定 prompt/state hash, stale cache 不算 warm pass。 |
| C126 | Liquid4All H5 fullState/functions.json 禁当 MAformac SSOT。 |
| C127 | `/ws-audio` 只作 local runtime teardown 灵感。 |
| C128 | 外部 code/asset/license transfer 前置 provenance checklist。 |
| C129 | 外部 issue/bug 只能启发 premortem, 不能替代 local proof。 |
| C130 | display-only direct touch 必有 disabled/read-only affordance。 |
| C131 | summary direct-control policy: 展示、跳转、guard 后控制三选一。 |
| C132 | gear direct-touch safety policy: 默认 display-only unless approved。 |
| C133 | 44pt/VoiceOver/mobile/true-device proof ladder 单独 lane。 |
| C134 | white-edge threshold 保留 WARN 或 formalize, 禁偷写 PASS。 |
| C135 | capsule final-art 是 human/product visual lane, 不阻塞 R5 dispatch。 |
| C136 | `DemoRuntimeOutcome.reason / missingSlot / scopeFailureReason` 的优先级和互斥规则。 |
| C137 | `behaviorClassSource` 在 accepted 和 non-accepted 结果中的填充规则。 |
| C138 | `isTerminal` 由结果类派生还是 runtime adapter 显式写入。 |
| C139 | `cards` 允许空数组的结果类和 UI empty-state 策略。 |
| C140 | `readbacks` 的顺序规则: 时间、卡片、最后一条为准。 |
| C141 | `dialogText` 与 `readbacks` 的 canonical human copy 裁决。 |
| C142 | `TraceEnvelope.traceID` 与 snapshot `traceID` 是否必须一致。 |
| C143 | `TraceEnvelope.entries` append-only 与阶段/时间单调性。 |
| C144 | snapshot `timestamp` 的时钟源和语义。 |
| C145 | `cancel` 与 `interruption` 的触发源、结果和恢复语义。 |
| C146 | `cardTap` 是否必须携带 `cardKey`, 缺失如何 fail-closed。 |
| C147 | `micStart/micEnd` 是输入事件还是必须驱动 voiceState。 |
| C148 | `voiceState` 与 `orbState` 同时非空时的主显示源和冲突裁决。 |
| C149 | `PresentationProofClass.displayCaps` 永远空是永久合同还是临时保守值。 |
| C150 | 未知 `PresentationProofClass` JSON 是否所有 consumer 都 fail-closed。 |
| C151 | `PresentationReadinessClaim` 是 shared API 还是未来占位符。 |
| C152 | snapshot `scopeFailureReason` 与 outcome `scopeFailureReason` 是否镜像。 |
| C153 | `scopeOrigin=nil` 的合法边界, 禁把 nil 当 defaulted。 |
| C154 | UIUE proof enum 与 mainline proof enum 的 crosswalk。 |
| C155 | `operatorReview` 能否出现在产品界面, 且不得等于 acceptance。 |
| C156 | UIUE matrix entry proof 与 snapshot proof 的优先级。 |
| C157 | partial accept/refuse 需 accepted/refused per-cell payload 后才做复杂混合 outcome。 |
| C158 | `dialogText/readbacks/matrix dialogText` 冲突时 UI/TTS/VO 的来源优先级。 |
| C159 | already-state 与 accepted 都 satisfied 时 a11y/readback 必须区分。 |
| C160 | card `accessibilityLabel` 是否包含 scope/reason/proof/read-only。 |
| C161 | `ValueControlView` direct controls 的 a11y value/hint/range。 |
| C162 | MicDock button tap 与“按住说话”文案的语义错配。 |
| C163 | context capsule a11y 是否读出速度/天气/挡位。 |
| C164 | expanded overlay 的 escape action、button trait 与 focus return。 |
| C165 | cancel/cancelled 映射 normal 后保留 terminal proof 和 announcement。 |
| C166 | runtimeError 区分 timeout/adapter/presentation fixture failure。 |
| C167 | Reduced Motion policy 是否有非动画 UI proof fixture。 |
| C168 | string-key `scopeOrigins` 改名后如何避免静默错配。 |
| C169 | `activeCells` 多 active/mixed outcome 的顺序、主次、focus priority。 |
| C170 | U15 counterexample fixture 补 already-state/runtime-error/cancelled。 |
| C171 | screenshot anchor proof-class 命名后禁被引用为 runtime/mobile proof。 |
| C172 | display-only summary/gear 需要 disabled affordance 和 a11y “仅展示”。 |
| C173 | a11y proof ladder 区分 local/static/simulator/true-device。 |
| C174 | safety refusal 中 orbState think 与 matrix tts speaking 的 lifecycle。 |
| C175 | mock voice state contradiction: orb speak + voice idle 要标非真实 TTS。 |
| C176 | `ToolExecutionError` 到 outcome 的完整分类, 尤其 guardDenied。 |
| C177 | 每个 terminal outcome 都要 sample terminal snapshot fixture。 |
| C178 | mainline 缺 partial, UIUE 已有 partial, 是否 canonical 或 local-only。 |
| C179 | proof enum 必须 translation, 禁 raw value 直传。 |
| C180 | `displayCaps` 永远空还是未来可打开, 谁开。 |
| C181 | think 两语义是否需要两个 enum/state。 |
| C182 | `cards_did_start_changing/readback_ready/tts_start/tts_end` 是否进 event kind。 |
| C183 | `force_context_state` 必须 demo-mode 隔离和 trace provenance。 |
| C184 | `activeCell/siblingCells` 在 mainline snapshot 的表达方式。 |
| C185 | already-state 证明 no revision bump、ack/readback、非 accepted delta。 |
| C186 | cancel/interruption 后禁止 stale async mutate cards。 |
| C187 | terminal snapshot 覆盖 `isTerminal=false -> true` 唯一合法转移。 |
| C188 | “runtime-driven orb binding” 在无 runtime logs 前只能叫 fixture-driven。 |
| C189 | C5/C6/golden/voice proof lane 独立 checkbox 禁互相替代。 |
| C190 | C6 acceptance/comparison 何时才从 bridge work 解冻。 |
| C191 | voice lane 首 gate 是功能坑 spike, 不是 UIUE voiceState。 |
| C192 | Liquid4All reject direct copy checklist。 |
| C193 | L0/L1/L2/L3 visual proof 绑定 proof-class cap, L1/L2 不关闭 L3。 |
| C194 | summary/gear direct touch 前先定义 disabled/safety/readback/a11y policy。 |
| C195 | R5 closeout hard gate: mainline dirty residual 与 UIUE clean 分开记录。 |
| C196 | docs-only vs Swift/UI touched 的 validation gate 每 lane 明确。 |
| C197 | C3 parser fallback/repair 是否进 runtime adapter error feedback strategy。 |
| C198 | golden step 进入前校验 runtime_mounted、required_state_cells、whitelist digest。 |
| C199 | golden replay 断言 state_revision before/after、readback_ok、no unexpected delta。 |
| C200 | already_state_noop 进入 C6/golden 样本, 不算 success_with_delta。 |
| C201 | partial accept/refuse readback 逐 cell 列 accepted/refused。 |
| C202 | voice memory 7 seeds 升级为正式 C6/golden seeds 或明确 deferred。 |
| C203 | assistant context commit 等 TTS/UX committed, barge-in 后不写下一轮焦点。 |
| C204 | raw ASR 只进 trace, train/memory/golden label 用 normalizer output。 |
| C205 | low-confidence ASR no-focus-update fixture, 禁 UIUE mock transcript 证明 voice-ready。 |
| C206 | TTS 与录音会话互斥进入 voice state machine 测试。 |
| C207 | endpoint decode parity 统计 toolCall/content JSON/parser_repair/false tool call 分布。 |
| C208 | Mac dev Outlines/XGrammar fixture 标 dev_only, 禁当 iOS proof。 |
| C209 | Qwen sampling 按 behavior class 拆测 temp0.6 vs 0.1。 |
| C210 | KV prewarm 绑定 prompt/state hash, stale cache 不算 warm-path pass。 |
| C211 | golden/script 文案禁直接进 C5 train/dev/test, 除非 data contract。 |
| C212 | scene macro 带 `planned_not_golden`, golden upgrade 单独签。 |
| C213 | UIUE local fixture proofClass unknown/缺失时 fail-closed。 |
| C214 | terminal snapshot 包含 timeout/cancel/interrupted finality 防 stale async mutate。 |
| C215 | C6/golden 区分 local_shape_no_model replay 与 model_quality。 |

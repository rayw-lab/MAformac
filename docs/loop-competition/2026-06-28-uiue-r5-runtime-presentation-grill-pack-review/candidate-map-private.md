# Controller Private Candidate Map

Do not provide this file to blind reviewers. It maps blind IDs back to original grill-pack IDs for judge synthesis and burndown routing.

| Candidate | Original ID | Question |
|---|---|---|
| C001 | RPB-01 | 边界 override 只能是 snapshot consume + bridge event write, 不能自由 mutate store。 |
| C002 | RPB-02 | 三车道分类: UIUE local, shared bridge, mainline runtime。 |
| C003 | RPB-03 | bridge 4 名和字段名必须由 mainline carrier/DTO 锁定。 |
| C004 | RPB-04 | store ownership: presentation 消费 snapshot, 不读 raw runtime store。 |
| C005 | RPB-05 | 写所有权: 触摸/事件走 executor 或 runtime adapter, 不直接写 store。 |
| C006 | RPB-06 | 事件集必须封闭, 包含 text/mic/card/cancel/interruption/timeout 等。 |
| C007 | RPB-07 | 事件 payload 必须区分 source/provenance 与 scope_origin/resolution。 |
| C008 | RPB-08 | scope 展示读结构化字段, UI/TTS 禁从中文推断 scope。 |
| C009 | RPB-09 | Runtime result enum 保持机器可读, 不用裸 rejected。 |
| C010 | RPB-10 | 拒识词表要区分 unsupported/safety/clarify/already-state/runtime-error。 |
| C011 | RPB-11 | 视觉映射为结果到 7 态的派生, 不是 runtime 结果本身。 |
| C012 | RPB-12 | guard denial 必须投影成 presentation-safe refusal snapshot。 |
| C013 | RPB-13 | unsafe R2 展示 active/refused cell 和 safety reason, 不暴露速度等敏感内情。 |
| C014 | RPB-14 | already_state_noop 独立结果, 视觉可 satisfied 但语义非 accepted delta。 |
| C015 | RPB-15 | clamp 成功路径要说实际 clamp 值, trace 标 clamped。 |
| C016 | RPB-16 | 真 multi-intent splitter deferred, Phase4/5 只可 sequencer/force-state。 |
| C017 | RPB-17 | partial deny 需要综合 snapshot, 逐 cell 混态与综合 readback。 |
| C018 | RPB-18 | SceneMacroRegistry 属 Core config, 非 UIUE-only 隐藏 planner。 |
| C019 | RPB-19 | 环境上下文是 runtime context, 非车控卡, 但可显示事实。 |
| C020 | RPB-20 | reset preset 清 vehicle/dialogue/trace/orb/voice/context。 |
| C021 | RPB-21 | think 应事件驱动, 不写固定计时剧场。 |
| C022 | RPB-22 | cancel/interruption/timeout/backgrounding 必须有终态 snapshot。 |
| C023 | RPB-23 | ASR/TTS 边界: backend 接 text, voice-ready 需真机 ASR/TTS proof。 |
| C024 | RPB-24 | TraceEnvelope 最小字段和 redaction 需要锁。 |
| C025 | RPB-25 | proof class 上限: UIUE screenshot/simulator 不能变 runtime/mobile/V-PASS。 |
| C026 | RPB-26 | 现态推理/感受词走 C3 相对 EXP 或 later LoRA, 不在 UIUE 自建。 |
| C027 | RPB-27 | normalize/range/EXP 复用 C3, UIUE 不重复相对调温逻辑。 |
| C028 | RPB-28 | range 源来自 StateCellContractLookup 或同等 SSOT。 |
| C029 | RPB-29 | active cell 优先级需定义, refused 可压过 satisfied。 |
| C030 | RPB-30 | snapshot card schema 要带 scope/reason/active/sibling 等呈现所需语义。 |
| C031 | RPB-31 | family 覆盖 10 族 + context, 天气/时段不是第 11 族车控卡。 |
| C032 | RPB-32 | dialogue ownership 分 runtime readback、assistant copy、presentation styling。 |
| C033 | RPB-33 | orb 状态来源是 composite, 非视觉自嗨。 |
| C034 | RPB-34 | Reduce Motion 必须有非动画通道。 |
| C035 | RPB-35 | Mac/iOS bridge 字段一致, layout 差异 layout-only。 |
| C036 | RPB-36 | 模拟器不等于真机, 质感/音频/性能/热须 true-device lane。 |
| C037 | RPB-37 | 离线 bundle, 无网无 Python, Python 只可 dev spike。 |
| C038 | RPB-38 | persistence 仅 DialogueState 短时, 不做 cloud/long memory。 |
| C039 | RPB-39 | crash/unknown 不可用于正常 unsupported/refusal。 |
| C040 | RPB-40 | settings/reset 中 theme 是 presentation-only, force/reset 是 runtime input。 |
| C041 | RPB-41 | UIUE scripted runs 可作 future golden candidate, 非 golden proof。 |
| C042 | RPB-42 | UIUE 视觉绝不选模型候选, candidate comparison 是 later mainline。 |
| C043 | RPB-43 | UIUE 文案/case 不能直接进入训练数据。 |
| C044 | RPB-44 | Accessibility deferred 但不能消失, 双通道只覆盖一部分。 |
| C045 | RPB-45 | screenshot anchor 命名含 platform/state/proof/source。 |
| C046 | RPB-46 | receipt 格式需 command/device/proof/touched/residual。 |
| C047 | RPB-47 | merge-readiness 标记只能是 contract aligned not merged。 |
| C048 | RPB-48 | reviewer 必告 live HEAD, no stale SHA。 |
| C049 | RPB-49 | 未决 P0/P1 carry-forward 必进下个 closeout。 |
| C050 | RPB-50 | 哪些落 bridge OpenSpec, 哪些留 UIUE notes 需 landing matrix。 |
| C051 | RPB-51 | snapshot card 必带 sibling/secondary/active 信息以支持制冷/制热与主值。 |
| C052 | RPB-52 | force-state context 输入需 `#if DEMO_MODE` + bridge event + trace provenance。 |
| C053 | RPB-53 | think 两语义: analyzing 事件驱动与 safety fixed 1s 演出例外。 |
| C054 | CE-001 | `ToolExecutionError` 到 `DemoRuntimeOutcome` 的完整映射表。 |
| C055 | CE-002 | `guardDenied` 应细分 safety/refusal/unsupported/runtime_error。 |
| C056 | CE-003 | `semanticInvalid("missing_default_scope")` 应映射 clarify/missing scope, 不进 Core enum。 |
| C057 | CE-004 | unsupported 与 safety refusal 必须有不同 reason taxonomy。 |
| C058 | CE-005 | runtimeError 需分 timeout/decode/store/model/adapter failure。 |
| C059 | CE-006 | cancellation 与 interruption 的触发源和恢复语义分开。 |
| C060 | CE-007 | adapter 遇 throw 仍必须发 terminal snapshot, 禁 silent failure。 |
| C061 | CE-008 | retry/idempotency 规则: 重试不得二次写 state 或吞掉 no-op。 |
| C062 | CE-009 | snapshot 禁 raw model output, 只带 presentation-safe outcome。 |
| C063 | CE-010 | `behaviorClassSource` preservation: accepted 结果保留 `tool_call` 源。 |
| C064 | CE-011 | accepted terminal snapshot sample 必须存在。 |
| C065 | CE-012 | clarify/missing-slot terminal snapshot sample 必须存在。 |
| C066 | CE-013 | unsupported/no-tool terminal snapshot sample 必须存在。 |
| C067 | CE-014 | safety refusal terminal snapshot sample 必须存在。 |
| C068 | CE-015 | already-state terminal snapshot sample 必须存在。 |
| C069 | CE-016 | timeout runtimeError terminal snapshot sample 必须存在。 |
| C070 | CE-017 | cancelled terminal snapshot sample 必须存在。 |
| C071 | CE-018 | interrupted/barge-in terminal snapshot sample 必须存在。 |
| C072 | CE-019 | partial accept/refuse terminal snapshot sample 必须存在或明确 local-only。 |
| C073 | CE-020 | mainline flat `cards` 与 UIUE `activeCells` 如何对齐。 |
| C074 | CE-021 | siblingCells/mode 信息是否进入 mainline snapshot。 |
| C075 | CE-022 | refusedCell 是否支持多 refused cells。 |
| C076 | CE-023 | scopeOrigin 是 snapshot-level 还是 per-cell map。 |
| C077 | CE-024 | context(speed/gear/weather/time) 是否进入 shared snapshot 或 effect channel。 |
| C078 | CE-025 | readbacks 数组顺序和“最后一条为准”规则。 |
| C079 | CE-026 | dialogText/readbacks/matrix dialog 的 copy priority。 |
| C080 | CE-027 | empty cards 合法结果类: clarify/error/cancel 是否可空。 |
| C081 | CE-028 | timestamp 是 event time、snapshot time 还是 commit time。 |
| C082 | CE-029 | `cardsDidStartChanging` 是否进入 event gates。 |
| C083 | CE-030 | `readbackReady` 是否进入 event gates。 |
| C084 | CE-031 | `ttsStart/ttsEnd` 是 effect event 还是 snapshot state。 |
| C085 | CE-032 | timeout 作为 event/result/terminal snapshot 三层如何对应。 |
| C086 | CE-033 | `force_context_state` 是否进 `DemoInteractionEventKind`。 |
| C087 | CE-034 | `cardTap` payload 必填 key/family, 缺失 fail-closed。 |
| C088 | CE-035 | micStart/micEnd 是否推进 voiceState 或只作 input trace。 |
| C089 | CE-036 | background/suspend/resume 对 running turn 的 terminal/cancel 规则。 |
| C090 | CE-037 | `thinkAnalyzing` 与 `safetyThink` 是否类型化。 |
| C091 | CE-038 | 最小 1s guard 与固定 3s theatre 的边界。 |
| C092 | CE-039 | macro_id 源必须来自 Core, UIUE 不判语义。 |
| C093 | CE-040 | macro narration 用 2 字段, 禁回到三段 fixed calling。 |
| C094 | CE-041 | orbState 与 voiceState 冲突裁决。 |
| C095 | CE-042 | Reduce Motion 每态非动画等价物证明。 |
| C096 | CE-043 | shader/GPU budget 与 MLX runtime 抢资源的门。 |
| C097 | CE-044 | mainline/UIUE proof class crosswalk。 |
| C098 | CE-045 | result enum crosswalk, 尤其 UIUE partial 与 mainline absence。 |
| C099 | CE-046 | `scopeOrigin=nil` 的合法边界。 |
| C100 | CE-047 | string key migration proof for `scopeOrigins/activeCells`。 |
| C101 | CE-048 | adapter fixture golden cases 覆盖 8 类结果。 |
| C102 | CE-049 | “runtime-driven orb” 在无 runtime logs 前改名 fixture-driven。 |
| C103 | CE-050 | matrix entry proof 与 snapshot proof 的覆盖优先级。 |
| C104 | CE-051 | UIUE 禁在 mainline verdict 前新增 shared field。 |
| C105 | CE-052 | proof ladder: docs/static/unit/simulator/operator/true-device/live。 |
| C106 | CE-053 | screenshot anchor no-promotion machine guard。 |
| C107 | CE-054 | R5 receipt 必带 non-claims checkbox。 |
| C108 | CE-055 | validation gate 按 touched paths 切换。 |
| C109 | CE-056 | stale wording grep 必查 `R5_PRECONDITIONS_BLOCKED/not_proposed/missing`。 |
| C110 | CE-057 | 双 repo dirty status 分开记录, 不混提交。 |
| C111 | CE-058 | mainline/UIUE OpenSpec strict 各跑各的。 |
| C112 | CE-059 | raw ASR 只能 trace, 不作 memory/training/golden authority。 |
| C113 | CE-060 | normalizer confidence gate 决定是否 update focus。 |
| C114 | CE-061 | TTS/UX committed 后才写 assistant context。 |
| C115 | CE-062 | barge-in 后禁止未播出文本进入下一轮事实。 |
| C116 | CE-063 | TTS 与录音会话串行互斥。 |
| C117 | CE-064 | premium 普通话 voice preflight 与 fallback。 |
| C118 | CE-065 | voiceState `unavailable` 与 `idle` 区分。 |
| C119 | CE-066 | PTT/tap/hold 语义与 MicDock 文案一致。 |
| C120 | CE-067 | golden step runtime_mounted + state_cells + whitelist digest precheck。 |
| C121 | CE-068 | golden replay 校验 revision delta/no-delta + readback_ok。 |
| C122 | CE-069 | golden/script/storyboard 文案禁直接进 C5 train/dev/test。 |
| C123 | CE-070 | C6 shape replay 与 model-quality proof 分离。 |
| C124 | CE-071 | Qwen sampling 按 behavior class 拆测, 不看 aggregate。 |
| C125 | CE-072 | KV prewarm 绑定 prompt/state hash, stale cache 不算 warm pass。 |
| C126 | CE-073 | Liquid4All H5 fullState/functions.json 禁当 MAformac SSOT。 |
| C127 | CE-074 | `/ws-audio` 只作 local runtime teardown 灵感。 |
| C128 | CE-075 | 外部 code/asset/license transfer 前置 provenance checklist。 |
| C129 | CE-076 | 外部 issue/bug 只能启发 premortem, 不能替代 local proof。 |
| C130 | CE-077 | display-only direct touch 必有 disabled/read-only affordance。 |
| C131 | CE-078 | summary direct-control policy: 展示、跳转、guard 后控制三选一。 |
| C132 | CE-079 | gear direct-touch safety policy: 默认 display-only unless approved。 |
| C133 | CE-080 | 44pt/VoiceOver/mobile/true-device proof ladder 单独 lane。 |
| C134 | CE-081 | white-edge threshold 保留 WARN 或 formalize, 禁偷写 PASS。 |
| C135 | CE-082 | capsule final-art 是 human/product visual lane, 不阻塞 R5 dispatch。 |
| C136 | MC-001 | `DemoRuntimeOutcome.reason / missingSlot / scopeFailureReason` 的优先级和互斥规则。 |
| C137 | MC-002 | `behaviorClassSource` 在 accepted 和 non-accepted 结果中的填充规则。 |
| C138 | MC-003 | `isTerminal` 由结果类派生还是 runtime adapter 显式写入。 |
| C139 | MC-004 | `cards` 允许空数组的结果类和 UI empty-state 策略。 |
| C140 | MC-005 | `readbacks` 的顺序规则: 时间、卡片、最后一条为准。 |
| C141 | MC-006 | `dialogText` 与 `readbacks` 的 canonical human copy 裁决。 |
| C142 | MC-007 | `TraceEnvelope.traceID` 与 snapshot `traceID` 是否必须一致。 |
| C143 | MC-008 | `TraceEnvelope.entries` append-only 与阶段/时间单调性。 |
| C144 | MC-009 | snapshot `timestamp` 的时钟源和语义。 |
| C145 | MC-010 | `cancel` 与 `interruption` 的触发源、结果和恢复语义。 |
| C146 | MC-011 | `cardTap` 是否必须携带 `cardKey`, 缺失如何 fail-closed。 |
| C147 | MC-012 | `micStart/micEnd` 是输入事件还是必须驱动 voiceState。 |
| C148 | MC-013 | `voiceState` 与 `orbState` 同时非空时的主显示源和冲突裁决。 |
| C149 | MC-014 | `PresentationProofClass.displayCaps` 永远空是永久合同还是临时保守值。 |
| C150 | MC-015 | 未知 `PresentationProofClass` JSON 是否所有 consumer 都 fail-closed。 |
| C151 | MC-016 | `PresentationReadinessClaim` 是 shared API 还是未来占位符。 |
| C152 | MC-017 | snapshot `scopeFailureReason` 与 outcome `scopeFailureReason` 是否镜像。 |
| C153 | MC-018 | `scopeOrigin=nil` 的合法边界, 禁把 nil 当 defaulted。 |
| C154 | UC-001 | UIUE proof enum 与 mainline proof enum 的 crosswalk。 |
| C155 | UC-002 | `operatorReview` 能否出现在产品界面, 且不得等于 acceptance。 |
| C156 | UC-003 | UIUE matrix entry proof 与 snapshot proof 的优先级。 |
| C157 | UC-004 | partial accept/refuse 需 accepted/refused per-cell payload 后才做复杂混合 outcome。 |
| C158 | UC-005 | `dialogText/readbacks/matrix dialogText` 冲突时 UI/TTS/VO 的来源优先级。 |
| C159 | UC-006 | already-state 与 accepted 都 satisfied 时 a11y/readback 必须区分。 |
| C160 | UC-007 | card `accessibilityLabel` 是否包含 scope/reason/proof/read-only。 |
| C161 | UC-008 | `ValueControlView` direct controls 的 a11y value/hint/range。 |
| C162 | UC-009 | MicDock button tap 与“按住说话”文案的语义错配。 |
| C163 | UC-010 | context capsule a11y 是否读出速度/天气/挡位。 |
| C164 | UC-011 | expanded overlay 的 escape action、button trait 与 focus return。 |
| C165 | UC-012 | cancel/cancelled 映射 normal 后保留 terminal proof 和 announcement。 |
| C166 | UC-013 | runtimeError 区分 timeout/adapter/presentation fixture failure。 |
| C167 | UC-014 | Reduced Motion policy 是否有非动画 UI proof fixture。 |
| C168 | UC-015 | string-key `scopeOrigins` 改名后如何避免静默错配。 |
| C169 | UC-016 | `activeCells` 多 active/mixed outcome 的顺序、主次、focus priority。 |
| C170 | UC-017 | U15 counterexample fixture 补 already-state/runtime-error/cancelled。 |
| C171 | UC-018 | screenshot anchor proof-class 命名后禁被引用为 runtime/mobile proof。 |
| C172 | UC-019 | display-only summary/gear 需要 disabled affordance 和 a11y “仅展示”。 |
| C173 | UC-020 | a11y proof ladder 区分 local/static/simulator/true-device。 |
| C174 | UC-021 | safety refusal 中 orbState think 与 matrix tts speaking 的 lifecycle。 |
| C175 | UC-022 | mock voice state contradiction: orb speak + voice idle 要标非真实 TTS。 |
| C176 | PV-001 | `ToolExecutionError` 到 outcome 的完整分类, 尤其 guardDenied。 |
| C177 | PV-002 | 每个 terminal outcome 都要 sample terminal snapshot fixture。 |
| C178 | PV-003 | mainline 缺 partial, UIUE 已有 partial, 是否 canonical 或 local-only。 |
| C179 | PV-004 | proof enum 必须 translation, 禁 raw value 直传。 |
| C180 | PV-005 | `displayCaps` 永远空还是未来可打开, 谁开。 |
| C181 | PV-006 | think 两语义是否需要两个 enum/state。 |
| C182 | PV-007 | `cards_did_start_changing/readback_ready/tts_start/tts_end` 是否进 event kind。 |
| C183 | PV-008 | `force_context_state` 必须 demo-mode 隔离和 trace provenance。 |
| C184 | PV-009 | `activeCell/siblingCells` 在 mainline snapshot 的表达方式。 |
| C185 | PV-010 | already-state 证明 no revision bump、ack/readback、非 accepted delta。 |
| C186 | PV-011 | cancel/interruption 后禁止 stale async mutate cards。 |
| C187 | PV-012 | terminal snapshot 覆盖 `isTerminal=false -> true` 唯一合法转移。 |
| C188 | PV-013 | “runtime-driven orb binding” 在无 runtime logs 前只能叫 fixture-driven。 |
| C189 | PV-014 | C5/C6/golden/voice proof lane 独立 checkbox 禁互相替代。 |
| C190 | PV-015 | C6 acceptance/comparison 何时才从 bridge work 解冻。 |
| C191 | PV-016 | voice lane 首 gate 是功能坑 spike, 不是 UIUE voiceState。 |
| C192 | PV-017 | Liquid4All reject direct copy checklist。 |
| C193 | PV-018 | L0/L1/L2/L3 visual proof 绑定 proof-class cap, L1/L2 不关闭 L3。 |
| C194 | PV-019 | summary/gear direct touch 前先定义 disabled/safety/readback/a11y policy。 |
| C195 | PV-020 | R5 closeout hard gate: mainline dirty residual 与 UIUE clean 分开记录。 |
| C196 | PV-021 | docs-only vs Swift/UI touched 的 validation gate 每 lane 明确。 |
| C197 | PV-022 | C3 parser fallback/repair 是否进 runtime adapter error feedback strategy。 |
| C198 | MVG-001 | golden step 进入前校验 runtime_mounted、required_state_cells、whitelist digest。 |
| C199 | MVG-002 | golden replay 断言 state_revision before/after、readback_ok、no unexpected delta。 |
| C200 | MVG-003 | already_state_noop 进入 C6/golden 样本, 不算 success_with_delta。 |
| C201 | MVG-004 | partial accept/refuse readback 逐 cell 列 accepted/refused。 |
| C202 | MVG-005 | voice memory 7 seeds 升级为正式 C6/golden seeds 或明确 deferred。 |
| C203 | MVG-006 | assistant context commit 等 TTS/UX committed, barge-in 后不写下一轮焦点。 |
| C204 | MVG-007 | raw ASR 只进 trace, train/memory/golden label 用 normalizer output。 |
| C205 | MVG-008 | low-confidence ASR no-focus-update fixture, 禁 UIUE mock transcript 证明 voice-ready。 |
| C206 | MVG-009 | TTS 与录音会话互斥进入 voice state machine 测试。 |
| C207 | MVG-010 | endpoint decode parity 统计 toolCall/content JSON/parser_repair/false tool call 分布。 |
| C208 | MVG-011 | Mac dev Outlines/XGrammar fixture 标 dev_only, 禁当 iOS proof。 |
| C209 | MVG-012 | Qwen sampling 按 behavior class 拆测 temp0.6 vs 0.1。 |
| C210 | MVG-013 | KV prewarm 绑定 prompt/state hash, stale cache 不算 warm-path pass。 |
| C211 | MVG-014 | golden/script 文案禁直接进 C5 train/dev/test, 除非 data contract。 |
| C212 | MVG-015 | scene macro 带 `planned_not_golden`, golden upgrade 单独签。 |
| C213 | MVG-016 | UIUE local fixture proofClass unknown/缺失时 fail-closed。 |
| C214 | MVG-017 | terminal snapshot 包含 timeout/cancel/interrupted finality 防 stale async mutate。 |
| C215 | MVG-018 | C6/golden 区分 local_shape_no_model replay 与 model_quality。 |

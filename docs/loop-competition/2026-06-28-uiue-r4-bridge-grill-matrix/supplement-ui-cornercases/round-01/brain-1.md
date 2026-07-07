# R4 supplemental Round 01 RED review - C31-C50

## Persona

RED reviewer：failure auditor / fake-green and proof-class hunter。我的审法不是问“这个 UI 点有没有意思”，而是问它是否会制造假绿：把 UI 动效 proof 写成 runtime/voice proof，把演绎控制台当用户能力，把 gesture 空壳当已实现，把车辆 context 样式越权成真实车辆状态，或者让 R4 bridge schema 被 UI 细节胀成实现总表。

## Scope Read

- 已完整读取 `contract.md`、`candidates-blind.md`、`deductive-gap-analysis.md`。
- 已按 source pool 读取/抽查：`final-grill-matrix.md`、R0/R1/R2 final matrix、`uiue-grill-定档`、`uiue-landing-matrix`、`uiue-storyboard-grill-decisions`、R0-R2 burndown、`PresentationSnapshot.swift`、`PresentationReducedMotionPolicy.swift`、`StateCellInteractionPolicy.swift`、`ContentView.swift`、`ContextCapsule.swift`、`DemoControlPanel.swift`、bridge `design.md`、实际存在的 bridge spec。
- 盲评边界：未读取 `round-01/brain-2.md`、`round-01/brain-3.md`、`round-02/*` 或 judge 文件。
- source mismatch：contract source pool 指向 `openspec/changes/define-runtime-presentation-bridge/specs/ui-presentation/spec.md`，当前树不存在；实际 spec 是 `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`。这应在 controller 阶段修正文档引用，不能静默平滑。
- 当前 live-code 红旗：`MicDock` 的 long press 是 `minimumDuration: 0.05` 的按压反馈，不是 1.5s 演绎控制台入口；R3 burndown 也明示“Long-press 1.5s -> 演绎控制台 is not implemented/proven”。`ContextCapsule` 的 accessibility label 当前暴露 `speed` 和 `gear` 数字，这与 C38 的“禁止展示 raw speed/gear 数字”存在至少 a11y 层面的冲突。

## Keep

- C31-C33 必保留：R4 原矩阵已经有 `PresentationSnapshot`、proof class、orb/voice presentation cap，但没有逐 zone 的 state source / write owner / proof cap。没有 zone topology，后续很容易把“UI 消费 snapshot”写成万能胶。
- C34-C36 必保留：长按思考/演绎控制台是最高假绿风险。当前 live code 不支持 1.5s 控制台入口，settings 入口写着“只切 mock context/state，不接真 runtime”，所以必须把它钉为 demo/operator surface，不得扩成用户车控能力或 runtime readiness。
- C38 必保留并升为 RED blocker：bridge spec 只要求 vehicle speed 不渲染为 controllable card，但当前 capsule a11y label 直接读出速度/挡位。候选需要明确包括可见 UI 与 accessibility 输出，不然会出现“视觉没显示数字，但 VoiceOver 暴露 raw vehicle state”的漏网。
- C40/C42 必保留：force context、macro、reset 是 stale visual 的主要来源。当前 macro 会更新多个 cells 和 activeCells，但 readbacks 没有同步增长，orb/voice state 多处沿用旧值；这正是“一句 accepted 压扁多 zone 变化”的风险。
- C47/C49/C50 必保留：reduce motion、动效时序 proof 和 schema/policy/evidence 分类表是防 fake-green 的三道闸。尤其 C50 是防止 C31-C49 反向膨胀 bridge schema 的总阀。

## Delete

- 不建议直接删除任何 C31-C50。固定盲集里 20 项都有真实风险来源。
- 但 C39、C44 若按原文直接进入 final matrix，会显得像把 R2b layout/R1 interaction 重新贴到 R4；不应删除，应 merge/rewrite 成 R4 evidence boundary。

## Merge

- C39 + C45：合并为“R4 evidence must reference fixed zone-pair/hit-test checklist, while min-gap/overlap math remains R2b”。settings/refresh/capsule/safe-area/hit-testing 是必要证据，不应变成新的 bridge schema 字段。
- C43 + C44：合并为“snapshot-driven focus and spatial-memory evidence”。activeCell 可以触发 scroll/hero/fade，但用户手动滚动、overlay 局部 state、store writeback 归 UIUE presentation policy，不应推成 runtime contract。
- C41 可挂到 C40 下作为 macro lifecycle 的 per-action 子问题：bridge 已有 `partial_accept_partial_refuse` 和 per-action outcome 概念，C41 的价值是防止 macro 用单个 accepted/readback 压扁多 action。
- C46 + C47 可相邻保留，但 final matrix 应分清：C46 是可达性/替代入口 proof cap，C47 是 reduce-motion 状态语义 proof cap。二者都不能被一张 DEBUG reduce-motion 截图替代。

## Rewrite

- C37：改写为“bridge 暴露四维 context；优先级/组合显示属于 visual policy，但必须有 evidence 证明 policy 不越权”。不要要求 bridge 输出唯一 visual state，否则会违背 AD-RPB-014 的四维 contract。
- C38：补上 accessibility 和 evidence wording：禁止 raw speed/gear 以 control、device card、客户可见状态数值、VoiceOver label/value 形式泄漏；允许抽象语境如行驶/雨/夜。
- C39：删掉“是否需要作为 R4 bridge evidence 的固定 zone pair”的歧义，改成“R4 receipt 必须引用 R2b zone-pair/layout evidence，不得把通用 layout checker PASS 写成 bridge schema 已足够”。
- C40：必须写“demo/operator force context 只产生 simulator/mock proofClass，不改变 runtime readiness”。同时要求 reset 清空 active/refused/thinking/pressing/readback stale，而不是只换 cards。
- C49：必须明确静态截图、UI tree frame、多帧/视频各证明什么；视频 proof 只能证明 choreography，不证明 ASR/TTS/LLM/runtime timing。

## Missing Risks

- source pool 路径错配本身是治理风险：reviewer 可能找不到 spec 或读错旧 spec。controller 应修 `contract.md` 或在 final receipt 标 `source-path mismatch`。
- `ContextCapsule` a11y label 暴露 raw speed/gear，C38 原文若只说“展示”可能漏掉 accessibility 输出。
- `DemoControlPanel` 和 `ContentView.applyControlPanelState` 当前是 mock/control-panel 路径；如果报告写成“通过 bridge event 已实装”，就是假绿。AD-RPB-014 是 intended contract，不是 live runtime proof。
- `applyCabinSceneMacro` 多 cell 改动没有 per-action readbacks，`applySnapshotCells` 沿用旧 `readbacks/orbState/voiceState`；C40-C42 必须挡住 stale-state 与压扁结果。
- Reduce Motion 目前有 policy/unit/debug override proof，但 R3 已明示不是真机系统设置 proof；C47 不能允许“一张 reduce-motion 图”替代 per-zone proof。
- 演绎控制台入口必须和 mic 按住说话隔离。当前 mic press 是普通 Button action + 0.05s pressing feedback，不是 long-press thinking route。

## Scores

| ID | Score | Verdict |
| --- | ---: | --- |
| C31 | 5 | keep |
| C32 | 5 | keep |
| C33 | 5 | keep |
| C34 | 5 | keep |
| C35 | 5 | keep |
| C36 | 5 | keep |
| C37 | 4 | rewrite |
| C38 | 5 | keep/rewrite |
| C39 | 3 | merge |
| C40 | 5 | keep/rewrite |
| C41 | 4 | merge |
| C42 | 5 | keep |
| C43 | 4 | merge |
| C44 | 3 | merge |
| C45 | 4 | merge |
| C46 | 4 | rewrite |
| C47 | 5 | keep |
| C48 | 4 | keep |
| C49 | 5 | keep/rewrite |
| C50 | 5 | keep |

## Candidate Notes

- C31：强。R4 必须有 zone topology，否则 top capsule/orb/dialogue/cards/mic/overlay 的 proof class 会互相污染。
- C32：强。字段例子基本对；但 final wording 要允许“bridge field 或 explicit visual policy”，避免把所有 UI policy 塞 schema。
- C33：强。注意力链是 UIUE 高风险；必须写明 reduce motion 下状态语义仍可读，且不能把动效证明当 runtime timing。
- C34：强且当前是红旗。1.5s long press 控制台未实现；候选应明确“需要合同/证据，不得 claim 已落地”。
- C35：强。gesture arbitration 是防假实现的必要项；尤其 mic press、card tap、drag、双 scroll、overlay dismiss、settings route 需要互不吞意图。
- C36：强。演绎控制台必须标 demo/operator surface；从 settings 或未来 long-press 进入都不得改变 runtime/voice readiness。
- C37：有价值但要重写。bridge 应给四维 context，visual priority 属于 visual policy/evidence，不该要求 bridge 输出唯一车辆样式。
- C38：强且有 live-code 反例。当前 a11y label 暴露 speed/gear；final 必须覆盖 VoiceOver label/value，不只覆盖视觉像素。
- C39：有价值但容易错位。保留为 R4 receipt 必须链接 top-zone pair evidence；不要把 Dynamic Island/safe area 变成 bridge schema。
- C40：强。force context/macro/reset 必须有 snapshot lifecycle 和 stale clearing；当前 mock path 不足以证明 bridge event provenance。
- C41：强但可并入 C40。macro 多 family 改动必须有 per-action active/readback/evidence，不可一个 `accepted` 全压扁。
- C42：强。reset/theme/preset 后 stale active/refused/thinking/pressing 残留是典型 fake green，必须进 R4 checklist。
- C43：有价值。SD22 已有 presentation policy，R4 需要的是 active/readback 触发与用户手动滚动不互抢的 evidence boundary。
- C44：中等偏强。空间记忆很重要，但主要是 R1/R2b presentation evidence；建议并入 scroll/focus/overlay evidence。
- C45：强但应 merge。hit-testing 必须证明 ambient burst 不挡交互、overlay 拦截背景、mic dock 不遮末行；但仍是 evidence/policy，不是 schema。
- C46：强但需降格 wording。a11y 需要 zone 明确，但不要把它写成完整 VoiceOver 合规已要求；重点是替代入口和 proof cap。
- C47：强。按 zone 出 reduce-motion evidence 是必要硬门；R3 DEBUG override 不能替代 true-device/system setting proof。
- C48：强。Mac panorama 与 iPhone portrait 不能互相代 proof；同一 snapshot 的不同 layout proof class 必须分开记录。
- C49：强。动效时序、progress、crossfade、stale clearing 靠静态图不够；但视频/多帧 proof 只能证明 presentation choreography。
- C50：强。必须有 schema / visual policy / evidence checklist 分类表，否则 C31-C49 会把 R4 bridge 胀成 UI 总表。

## Residual Risk

本轮是 RED 盲评留痕，不是 controller judge，也不改 final matrix。我的主要 verdict：C31-C50 整体值得保留为 R4 supplemental pool，但 final 化时必须收缩边界：bridge schema 只承载跨层必要字段，zone choreography、layout、gesture、a11y、reduce motion 多数应落在 visual policy 和 evidence checklist。任何最终文档都不得声明 `8.C2` closure、V-PASS、mobile/true-device、runtime-ready、voice-ready、model-ready、golden-ready 或 endpoint-ready。

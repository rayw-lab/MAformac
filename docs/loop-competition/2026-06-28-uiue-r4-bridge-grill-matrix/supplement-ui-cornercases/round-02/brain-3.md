# R4 Supplemental Round 02 BLACK Review - C31-C50

## Persona

BLACK = skeptical product / ontology judge。我的判据不是“这个 UI 点有没有趣”，而是它是否守住概念边界，并能防止 demo 现场假绿。

术语归一化：

- `bridge contract`：runtime / mock-frontstage 到 presentation 的可观察数据合同，只应定义状态、结果、身份、证明等级和消费边界。
- `visual policy`：UIUE 如何表现这些状态，例如层级、动效、滚动、z-order、reduce motion 降级；它可由 snapshot 驱动，但不等于 bridge schema。
- `evidence checklist`：怎样证明某个 UI 表现没有假绿，例如截图、视频、多帧、UI tree、receipt；它不应反向扩张合同字段。
- `operator surface`：方案经理幕后工具或演绎控制台；它可以服务 demo，但不是用户车控能力，也不是 runtime readiness。
- `product capability`：客户可见能力。演绎控制台、force context、macro preset 都不是产品能力，除非另有用户入口合同。

本轮先验反例：`PresentationSnapshot` 已有 `context/orbState/voiceState/dialogText/readbacks/activeCells/refusedCell/proofClass/resultKind`，所以不能说 R4 完全没有桥字段；但它没有显式 zone manifest、attention sequence、gesture route 或 stale-clearing lifecycle，所以“UI 消费 snapshot”仍不足以解释连续舞台。

## Scope Read

已完整读取：

- `supplement-ui-cornercases/contract.md`
- `supplement-ui-cornercases/candidates-blind.md`
- `supplement-ui-cornercases/deductive-gap-analysis.md`

按 contract source pool 读取/抽查：

- `docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/final-grill-matrix.md`
- `docs/grill-checklist/uiue-grill-定档-2026-06-25.md`
- `docs/grill-checklist/uiue-landing-matrix-2026-06-25.md`
- `docs/uiue-storyboard-grill-decisions.md`
- `docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md`
- `docs/loop-competition/2026-06-27-uiue-r0-r2-grill-matrix/final-grill-matrix.md`
- `openspec/changes/define-runtime-presentation-bridge/design.md`
- `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`
- `Core/Presentation/PresentationSnapshot.swift`
- `Core/Presentation/PresentationReducedMotionPolicy.swift`
- `Core/Presentation/StateCellInteractionPolicy.swift`
- `App/ContentView.swift`
- `App/ContextCapsule.swift`
- `App/DemoControlPanel.swift`

Source mismatch：contract 列出的 `openspec/changes/define-runtime-presentation-bridge/specs/ui-presentation/spec.md` 在当前树不存在；实际 bridge spec 位于 `specs/runtime-presentation-bridge/spec.md`。这是路径陈旧风险，不应被抹平。

未读取：`round-01/*`、`round-02/brain-1.md`、`round-02/brain-2.md`、judge 文件。

## Keep

- C31/C32/C33 必留：UIUE 是多 zone 连续舞台，不是单一卡片消费 snapshot。R4 至少要能说明每个 zone 的状态来源、写权限、proof class 和注意力优先级。
- C36 必留：演绎控制台必须被标为 operator/demo surface。否则 force context 和 macro 会被偷换成用户车控能力。
- C38 必留：`vehicle.* not rendered as control` 是红线。还要检查 accessibility channel，`ContextCapsule` 当前 label 暴露 speed/gear 数字，若“展示”包括 VoiceOver，这就是边界漏洞。
- C40/C42 必留：force context、macro、reset 的 lifecycle 若不清，最容易出现上一轮 active/refused/thinking/pressing 残留，形成现场 demo failure。
- C47/C50 必留：reduce motion 逐 zone proof 与 schema / policy / evidence 分类表是防膨胀总闸。

## Delete

不建议硬删除任一候选，因为 C31-C50 都对应真实产品风险。

但 C39 不应作为独立 bridge schema 项保留。顶部 capsule/settings/refresh/safe-area 是重要 zone pair，可进入 evidence checklist 和 Layout Integrity；若写成 R4 bridge 字段，会把布局实现误装进合同。

## Merge

- C31 + C32 可合并为 “zone manifest / source map”：每个 zone 写来源、写权限、proof class、fallback，不要求每个视觉细节都有独立 schema 字段。
- C33 + C47 可部分合并为 “attention choreography + reduce-motion semantic parity”：动效链路和降级语义应一起验。
- C35 + C43 + C45 可合并为 “gesture / scroll / hit-testing arbitration evidence”：R4 给边界和证据，UIUE visual policy 给具体实现。
- C37 + C38 + C40 可合并为 “context capsule lifecycle and redline”：优先级、raw vehicle redline、force/reset/macro 同步属于同一风险族。
- C41 + C42 可合并为 “multi-action lifecycle / stale clearing”：macro 与 reset 都是多 zone 状态改变，不应只看一个 accepted 结果。
- C48 + C49 可合并到 evidence plan：平台差异与多帧/视频证明是 proof-class 纪律，不是字段设计。

## Rewrite

- C34：不要默认“长按 1.5 秒进入思考/演绎控制台”已经是产品事实。当前读到的权威里设置入口明确存在；长按 orb/思考入口更像待拍 UX。应改写为：若存在 hidden/operator entrance，必须定义入口、替代入口、取消语义、与 mic 长按隔离，并标 operator-only。
- C36：补一句“任何入口进入演绎控制台都不得改变 proof class 或 runtime readiness”。
- C39：改成 “R4 evidence 是否引用 R2b Layout Integrity 的固定 zone pair，并证明其来源，不新增 bridge 字段”。
- C41：不要把 macro 的综合文案当 runtime 多意图能力。macro 是 operator surface；若要 per-action outcomes，只能作为 mock/operator fixture，不能宣称 runtime splitter ready。
- C46：改写为可验的 a11y 最小门：identifier uniqueness、label/value、adjustable、non-gesture alternative；不要把它写成完整 VoiceOver 人审通过。
- C49：从“必须视频”改成“当静态截图无法证明时必须多帧/视频/时间点”。否则会把所有证据门拖成重型视频门。
- C50：必须变成最终分类表，而不是普通问题。列：bridge schema / visual policy / evidence checklist / user-decision-needed / out-of-scope。

## Missing Risks

- Accessibility leakage：C38 只说不展示 raw speed/gear 数字，但 `ContextCapsule` accessibility label 可读出速度和挡位。若客户开 VoiceOver，raw vehicle context 仍可能外露。
- Operator surface discoverability：设置中有“演绎控制台”，但长按 1.5 秒入口是否真实存在、是否应该存在、是否会被客户误触，需要用户拍板，不是继续重评能解决。
- Stale readback/orb/voice clearing：代码中某些 `applySnapshotCells` 路径保留旧 `readbacks/orbState/voiceState`；reset/macro 是否真正清空所有 zone 需要专项证据。
- Proof-class inflation：P3/P4/P5/P6 simulator/mock proof 不能推出 runtime/mainline/mobile/true-device；C31-C50 的所有推荐都必须默认规划/审计清单级。
- Schema inflation：把 z-order、hit-testing、layout px、crossfade ms 全塞进 bridge，会导致 R4 变成 UI 实现总表。应让 bridge 只给状态和边界，visual policy 给呈现规则，evidence checklist 给证明方式。
- User-visible demo failure：最危险不是字段缺，而是现场同时出现 capsule、orb、readback、card hero、ambient burst、多 sheet/overlay 抢焦点，客户无法判断“车发生了什么”。

## Scores

| ID | Score | Verdict |
| --- | ---: | --- |
| C31 | 5 | keep |
| C32 | 4 | merge/rewrite |
| C33 | 5 | keep |
| C34 | 3 | rewrite/user-decision |
| C35 | 4 | merge |
| C36 | 5 | keep |
| C37 | 4 | merge |
| C38 | 5 | keep |
| C39 | 2 | merge, not standalone |
| C40 | 5 | keep |
| C41 | 4 | rewrite |
| C42 | 5 | keep |
| C43 | 4 | merge |
| C44 | 4 | keep/rewrite |
| C45 | 4 | merge |
| C46 | 4 | rewrite |
| C47 | 5 | keep |
| C48 | 4 | keep as proof-class split |
| C49 | 3 | rewrite |
| C50 | 5 | keep as final gate |

## Candidate Notes

- C31：本体成立。连续舞台由多个 zone 构成；若没有 zone topology，R4 会把“snapshot 消费”偷换成“UI 自己猜”。必须保留，但输出应是 zone manifest，不是 SwiftUI 布局说明。
- C32：方向对，但容易过拟合当前字段名。应要求每个 zone 有 source / policy / fallback，而不是强迫所有 zone 都一一新增 bridge 字段。
- C33：高价值。注意力链是产品可理解性问题，不只是动效审美。reduce motion 下仍要保留语义，否则无障碍模式会把状态解释能力砍掉。
- C34：风险真实，但假设偏强。长按 1.5 秒进入思考/演绎控制台不是我在当前代码中看到的稳定事实；设置入口存在。此项需要用户拍板入口形态。
- C35：应保留为 arbitration evidence。当前有 mic long press、温度 drag、卡片 tap、双 scroll、overlay dismiss、sheet 路由；缺的是全局冲突表。
- C36：必须保留。演绎控制台 header 已写“只切 mock context/state，不接真 runtime”，这类标注应进入 receipt 和 proof-class cap，防止 operator tool 冒充产品能力。
- C37：有价值但应合并到 context lifecycle。SD24 有单显优先级，SD25 又讲四维 composite；这二者存在张力，R4 要求清楚何处是数据合同、何处是视觉解析。
- C38：必须保留并加严。视觉上不应渲染 speed/gear 数字为控制；但 a11y label 暴露数字是潜在反例，需要明确是否允许。
- C39：独立分数低。它基本复用 R2b layout pair；R4 只需要求 evidence 继承这些 pair 并标 proof class，不应新增 bridge schema。
- C40：必须保留。force context、macro、reset 会同时改 context、activeCells、dialogue、orb/voice、proofClass；缺 lifecycle 会产生陈旧视觉。
- C41：保留但改写。macro 一次多 family 改动需要 per-action active/readback，但它是 operator/mock fixture，不可被写成 runtime multi-intent 能力已具备。
- C42：强保留。reset/theme/preset 后 stale clearing 是客户可见 failure，尤其 active/refused/thinking/pressing 残留会直接破坏演示可信度。
- C43：保留。代码已有 `isUserScrolling` 暂停 auto-scroll 的局部实现，说明问题真实且已有反例约束；R4 要求证据即可。
- C44：保留但压到 visual policy。空间记忆、不物理重排、overlay 局部 state 不污染 store 是产品体验底线；bridge 只提供 activeCell/store source。
- C45：保留为合并项。z-order/hit-testing 是现场可用性风险，代码已有 burst `allowsHitTesting(false)` 和 overlay intercept，但仍需 pair-based proof。
- C46：保留并重写。已有若干 accessibility identifier/label/adjustable，但不足以推出完整 a11y；需要最小替代入口与稳定 selector 门。
- C47：强保留。`PresentationReducedMotionPolicy` 目前偏 orb/motion kind，不能证明 capsule、edge burst、waveform、card breathing、sheet transition 全 zone 语义等价。
- C48：保留。Mac panorama 与 iPhone portrait 是不同拓扑，不能互证；同一 snapshot 只能证明数据消费一致，不证明布局/手势一致。
- C49：中等。动效时序、long press progress、crossfade、stale clearing 确实不能只靠一张图；但不应所有项一律视频化，按必要性触发。
- C50：最高优先级之一。没有分类表，C31-C49 会把所有 UI 细节吸进 bridge，造成合同膨胀；分类表是本补充矩阵的收束器。

## Residual Risk

本评审是 planning / audit checklist proof，未运行测试、未截图、未验证真机。当前结论只能支持 R4 supplemental grill 取舍，不能关闭 `8.C2`，不能声明 V-PASS、mobile、true-device、runtime-ready、voice-ready、model-ready、golden-ready、endpoint-ready 或 A-2 complete。

最终建议：C31-C50 整体保留进入补充矩阵，但以 C50 分类表收束；C34/C39/C49 降级为 rewrite/merge；所有 operator/macro/force-context 项必须显式标 `operator surface + simulator/mock proof`，需要用户拍板的入口形态不要继续靠 reviewer 重评拖延。

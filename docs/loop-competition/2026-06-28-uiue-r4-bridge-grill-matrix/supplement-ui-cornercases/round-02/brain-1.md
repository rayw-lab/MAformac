# PURPLE Reviewer - Round 02

## Persona

PURPLE，systems architect / SSOT and contract-boundary reviewer。

本轮只看 C31-C50 的补充 grill，目标不是扩大实现面，而是判断哪些内容属于 bridge contract，哪些只是 UIUE 的 visual policy，哪些只适合作为 evidence checklist。

核心立场：

- `bridge` 只承载可跨层消费的状态与结果语义。
- `zone topology`、`gesture arbitration`、`z-order`、`a11y`、`reduce motion`、`layout`、`video / multi-frame evidence` 主要属于 UIUE presentation policy 或 evidence checklist。
- 不允许把 UI 现象重新命名成第二 SSOT。
- `C50` 不是单点问题，而是分类边界总闸。

## Scope Read

我只读了本轮允许的权威输入与实现源，未读 `round-01/*`、`round-02/brain-2.md`、`round-02/brain-3.md` 或 judge 文件。

已读文件：

- `docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/supplement-ui-cornercases/contract.md`
- `docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/supplement-ui-cornercases/candidates-blind.md`
- `docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/supplement-ui-cornercases/deductive-gap-analysis.md`
- `Core/Presentation/PresentationSnapshot.swift`
- `Core/Presentation/PresentationReducedMotionPolicy.swift`
- `Core/Presentation/StateCellInteractionPolicy.swift`
- `App/ContentView.swift`
- `App/ContextCapsule.swift`
- `App/DemoControlPanel.swift`
- `openspec/changes/define-runtime-presentation-bridge/design.md`
- `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`
- `docs/uiue-storyboard-grill-decisions.md`
- `docs/grill-checklist/uiue-grill-定档-2026-06-25.md`
- `docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md`
- `docs/loop-competition/2026-06-27-uiue-r0-r2-grill-matrix/final-grill-matrix.md`

关键结论证据：

- `PresentationSnapshot` 已有 `context / orbState / voiceState / dialogText / readbacks / resultKind / proofClass`，但没有 zone manifest。见 `Core/Presentation/PresentationSnapshot.swift:59-99`。
- OpenSpec 已把 `scope_origin / active_cell / refused_cell / sibling_cells / partial_accept_partial_refuse / already_state_noop / force-context / cards_did_start_changing` 写进 bridge contract。见 `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md:3-127` 与 `design.md:37-81`。
- UIUE 侧已明确实现了 `ContextCapsule`、`MicDock`、`DialogueStream`、`VehicleCardsGrid`、`expandedOverlay`、`SettingsRefreshControls` 等 zone / gesture / layout 行为。见 `App/ContentView.swift:73-105`、`App/ContentView.swift:140-176`、`App/ContentView.swift:196-284`、`App/ContentView.swift:794-935`、`App/ContentView.swift:1036-1083`、`App/ContentView.swift:1487-1707`、`App/ContentView.swift:1712-2341`。
- `ContextCapsule` 已明确按 `speed / gear / weather / timePeriod` 四维做合成，不是单 scene SSOT。见 `App/ContextCapsule.swift:24-35`、`App/ContextCapsule.swift:38-175`、`App/ContextCapsule.swift:323-328`。
- 定档文档已经把顶部 capsule、右上 settings/refresh standalone、orb / dialogue / mic / cards 的连续舞台和 zone budget 收口为 UI 约束。见 `docs/uiue-storyboard-grill-decisions.md:334-348`、`docs/uiue-storyboard-grill-decisions.md:360-366`、`docs/uiue-storyboard-grill-decisions.md:529-553`、`docs/uiue-storyboard-grill-decisions.md:565-580`。

## Keep

- 保留 `C32`：每个 zone 是否有明确 state source 或 visual policy 来源，这是必要的问题，但应落在 visual policy / snapshot consumption 边界，不是新增 bridge manifest。
- 保留 `C33`：跨 zone 注意力链与 reduce motion 的语义一致性值得 grill，尤其涉及 `PresentationReducedMotionPolicy` 与 UIUE attention order。
- 保留 `C35`：mic press、long press、tap、drag、scroll、overlay dismiss 的手势仲裁是实问题。
- 保留 `C36`：演绎控制台必须被识别为 demo/operator surface，这一点已在 `DemoControlPanel` 和定档文档里有明确边界。
- 保留 `C37`：顶栏车辆样式与环境 capsule 的优先级冲突需要明确。
- 保留 `C38`：禁止 raw speed / gear 数字直接变成控制语义，允许语境表现，这个边界是 bridge 与 visual policy 的分界点。
- 保留 `C40`：force context / macro / reset 的生命周期必须同步 snapshot。
- 保留 `C41`：macro 一次改多族时，per-action active cells、readbacks、ambient burst 不能被一个 `accepted` 压扁。
- 保留 `C42`：reset / theme / preset 切换后的 stale-state clearing 是真实风险。
- 保留 `C43`：手动滚动与自动 scroll-to-active 的冲突需要明确。
- 保留 `C44`：空间记忆不能被 overlay / hero / expanded state 破坏。
- 保留 `C45`：z-order / hit-testing 需要作为 corner case，这属于 UIUE policy，但必须 grill。
- 保留 `C46`：a11y 要按 zone 划分 identifiers / labels / adjustable actions / fallback path。
- 保留 `C47`：reduce motion 要按 zone 出证据，而不是只交一张静态图。
- 保留 `C48`：Mac panorama 与 iPhone portrait 必须分别验收，不可互相替代 proof class。
- 保留 `C49`：动效时序、长按 progress、crossfade、stale clearing 需要视频 / 时间点 / 多帧证据。
- 保留 `C50`：需要一张分类表把 bridge schema、visual policy、evidence checklist 分开，否则一定膨胀成第二 SSOT。

## Delete

- 删除 `C31` 作为 bridge 争议题的写法。

原因：

- `C31` 问的是 zone topology 是否需要定义，但 topology 本身已经由 UIUE 实现和 storyboard 定档承担，bridge 只需要提供可消费状态，不需要新增 zone manifest。
- `PresentationSnapshot` 当前没有 zone manifest 字段，且 bridge design 明确要求 UIUE 消费 snapshot，不是再发明一个区级 contract。见 `Core/Presentation/PresentationSnapshot.swift:59-99`、`openspec/changes/define-runtime-presentation-bridge/design.md:11-13`。

## Merge

- `C31` 应并入 `C50` 或并入 UIUE visual policy 组，而不是单独上升为 bridge schema。
- `C34` 可并入 `C35`，因为长按思考、mic 按住说话、card tap、drag、overlay dismiss 本质上都在问 gesture arbitration。
- `C39` 应并入 `C45` 或 `C50`，因为它本质是 top layout / safe area / settings-refresh 布局归类问题，不是 bridge 新语义。
- `C41` 可与 `C42` 合并成一个 macro / reset lifecycle 组，避免重复追问 snapshot stale clearing 与 mixed action lifecycle。
- `C43` 和 `C44` 可以并排保留，但如果要压缩矩阵，它们也可以合并为 scroll / spatial memory 组。
- `C48`、`C49` 可在 evidence checklist 里合并成“platform-specific proof class + temporal proof”两层，而不是放在 contract 层扩字段。

## Rewrite

- `C31`：
  - 原问法过度逼近 bridge schema。
  - 应改写成“哪些 zone 规则属于 UIUE visual policy，哪些只属于 evidence checklist，哪些必须留在 bridge snapshot 已有字段里？”

- `C34`：
  - 原问法偏交互 UX 细节。
  - 应改写成“long press 思考与 mic push-to-talk 的 gesture 边界是否在 UIUE 层有明确 arbitration，并且不需要 bridge 新字段？”

- `C39`：
  - 原问法把 layout pair 误拉进 bridge evidence。
  - 应改写成“top capsule / settings / refresh / safe area 的结构门是否属于 UIUE layout integrity，而非 bridge contract？”

- `C49`：
  - 原问法只在问记录格式，不足以区分 contract 与 checklist。
  - 应改写成“哪些时序证据必须进入 evidence checklist，哪些只需在 UIUE 实装中自证，不应反写 bridge？”

- `C50`：
  - 这是总闸题，应保留为最高优先级分类题。
  - 但要明确它的输出是分类结果，不是新字段提案。

## Missing Risks

- 目前 bridge contract 已经覆盖 `PresentationSnapshot` 的关键交叉语义，但没有 zone manifest；如果以后把 zone manifest 再写进 bridge，会非常容易制造第二 SSOT。
- `ContextCapsule` 的四维 context 与 UIUE top capsule 的视觉 policy 已经分离，但如果没有明确分类表，后续 reviewer 很容易把“视觉建议”误升成“桥约束”。
- `VoiceOver` / `reduce motion` / `layout` / `hit-testing` / `scroll` 这些门都是 UIUE 真实风险，但它们更像 presentation-policy evidence，不应回写到 bridge schema。
- `video / timepoint / multi-frame` 证据如果没有在 checklist 层固定，会被误当作运行时能力门，导致 proof class 混淆。

## Scores

| ID | 分数 | 判定 |
| --- | ---: | --- |
| C31 | 2 | 倾向删除或并入 C50；zone topology 不应升格成 bridge 第二 SSOT。 |
| C32 | 4 | 应保留；这是 snapshot / visual policy 边界核对题。 |
| C33 | 4 | 应保留；注意力链与 reduce motion 的语义一致性是有效 grill 点。 |
| C34 | 3 | 需要 rewrite；本质是 gesture arbitration，不是 bridge contract。 |
| C35 | 5 | 必保留；多手势仲裁是 UIUE 真边界。 |
| C36 | 4 | 必保留；demo/operator surface 边界明确。 |
| C37 | 4 | 必保留；top capsule 语境优先级需要明确。 |
| C38 | 4 | 必保留；这是 control 语义红线，不是单纯视觉细节。 |
| C39 | 2 | 倾向 merge/rewrite；layout pair 是 UIUE layout integrity，不是 bridge schema。 |
| C40 | 5 | 必保留；macro / reset / force-context 的 snapshot lifecycle 是核心。 |
| C41 | 4 | 必保留；防止 multi-action 被一个 accepted 压扁。 |
| C42 | 4 | 必保留；stale-state clearing 是真实回归面。 |
| C43 | 4 | 必保留；manual vs auto scroll 冲突是 UIUE 重要 policy。 |
| C44 | 4 | 必保留；空间记忆与 overlay 破坏是关键问题。 |
| C45 | 5 | 必保留；z-order / hit-testing 是 UIUE corner case 中的硬门。 |
| C46 | 5 | 必保留；a11y 必须按 zone 细分。 |
| C47 | 5 | 必保留；reduce motion 必须按 zone 出证据。 |
| C48 | 4 | 必保留；Mac 与 iPhone 的 proof class 不能互相替代。 |
| C49 | 4 | 必保留，但应归 evidence checklist。 |
| C50 | 5 | 必保留；分类总闸，防止 bridge 膨胀。 |

## Candidate Notes

- C31：问题抓到了 zone topology，但落点不该是 bridge schema；更适合进入 `C50` 分类表。
- C32：合理，能帮助确认每个 zone 的 state source 归属。
- C33：合理，尤其适合和 `PresentationReducedMotionPolicy` 对读。
- C34：合理但需收窄到 gesture arbitration。
- C35：强保留，`MicDock`、`DialogueStream`、`VehicleCardsGrid`、`expandedOverlay` 已经证明这个问题真实存在。
- C36：强保留，`DemoControlPanel` 明确是幕后工具，不是用户车控能力。
- C37：强保留，`ContextCapsule` 与顶栏 standalone 的优先级需要继续锁。
- C38：强保留，和 bridge 的 `vehicle.speed` 不能被直接渲染成控制卡红线一致。
- C39：弱于 C45 / C50，容易把 layout integrity 误当 bridge 语义。
- C40：强保留，macro / reset / force-context 已经在 `ContentView` 与 `DemoControlPanel` 里形成 snapshot lifecycle。
- C41：强保留，multi-action / per-action readback 不应压平。
- C42：强保留，reset / theme / preset 会留下 stale visual 风险。
- C43：强保留，但它属于 scroll policy，不是 bridge contract。
- C44：强保留，expanded overlay 与 active cell 必须守空间记忆。
- C45：最强保留之一，属于 UIUE 视觉交互边界。
- C46：强保留，a11y 必须是 zone 级别，而不是单一总入口。
- C47：强保留，reduce motion 是 zone-by-zone 的证据问题。
- C48：强保留，Mac panorama 与 iPhone portrait 本来就是两套 layout proof。
- C49：保留，但应明确是 evidence checklist，不是 schema。
- C50：必须保留，作为分类总闸统领 C31-C49。

## Residual Risk

即使本轮保留了大部分 UIUE corner cases，仍有三个残余风险：

1. reviewer 可能继续把 `zone topology` 误写成 bridge manifest。
2. 证据门如果不单列，`video / multi-frame / timepoint` 会和 contract 混在一起。
3. `layout / gesture / a11y / reduce motion` 若没有被稳定标记为 visual policy，后续会反向污染 bridge contract。

因此，下一步最重要的不是再加字段，而是用 `C50` 的分类表把边界锁死。

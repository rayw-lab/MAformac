# R4 Supplemental Round 01 GREEN Review

## Persona

我是 GREEN reviewer，职责是做实施协调和 owner/test-sequence 审核，不把 UI 表现层的细节误写成 R5 runtime 实装，也不把静态截图误当成完整行为验收。  
本轮按盲评处理，只基于 contract / source pool / 现有实现真态，不读取 `round-01/brain-1.md`、`round-01/brain-3.md`、`round-02/*` 或 judge 文件。

## Scope Read

已读：

| 文件 | 作用 |
| --- | --- |
| `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/supplement-ui-cornercases/contract.md` | 约束、输出格式、source pool、盲评边界 |
| `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/supplement-ui-cornercases/candidates-blind.md` | C31-C50 候选题 |
| `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/supplement-ui-cornercases/deductive-gap-analysis.md` | 缺口分类与推导结论 |
| `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/define-runtime-presentation-bridge/design.md` | RPB 设计层权威 |
| `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md` | RPB 行为契约 |
| `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/PresentationSnapshot.swift` | 当前 snapshot 真态 |
| `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/PresentationReducedMotionPolicy.swift` | reduced motion 现状 |
| `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/StateCellInteractionPolicy.swift` | 交互 policy / gesture / writeback 现状 |
| `/Users/wanglei/workspace/MAformac-uiue/App/ContentView.swift` | 真实 UI 路由、滚动、overlay、capsule、mic、card 交互 |
| `/Users/wanglei/workspace/MAformac-uiue/App/ContextCapsule.swift` | context capsule 视觉实现 |
| `/Users/wanglei/workspace/MAformac-uiue/App/DemoControlPanel.swift` | 演绎控制台 / macro / reset / context force surface |
| `/Users/wanglei/workspace/MAformac-uiue/docs/grill-checklist/uiue-landing-matrix-2026-06-25.md` | landing 状态、已落/待落边界 |
| `/Users/wanglei/workspace/MAformac-uiue/docs/grill-checklist/uiue-grill-定档-2026-06-25.md` | SD24/SD25、顶栏与 capsule 边界 |
| `/Users/wanglei/workspace/MAformac-uiue/docs/uiue-storyboard-grill-decisions.md` | 连续舞台、注意力优先级、z-order、滚动、context capsule 约束 |
| `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-27-uiue-r0-r2-grill-matrix/final-grill-matrix.md` | 旧矩阵上下文，对照 C31-C50 既有口径 |

未读：

| 文件 | 说明 |
| --- | --- |
| `round-01/brain-1.md` | 按盲评要求不读 |
| `round-01/brain-3.md` | 按盲评要求不读 |
| `round-02/*` | 按盲评要求不读 |
| judge 文件 | 按盲评要求不读 |

## Keep

| ID | 处理 | 理由 |
| --- | --- | --- |
| C33 | Keep | 跨 zone 注意力链是 R4 视觉政策核心，且已有 `ContentView` / `StoryBoard` 可对照。 |
| C35 | Keep | 手势仲裁是真实交互冲突点，必须区分 mic press / drag / scroll / overlay dismiss。 |
| C36 | Keep | 演绎控制台的 operator boundary 需要明确，不能被读成用户车控能力。 |
| C37 | Keep | 顶部 capsule 的状态优先级是可观察行为，不是实现细节。 |
| C38 | Keep | 这是 capsule 视觉红线，不能把 raw speed/gear 当成可视化文案直接露出。 |
| C41 | Keep | macro fan-out 必须保留 per-action 语义，不可被单个 accepted 压扁。 |
| C43 | Keep | 手动滚和自动 scroll-to-active 的冲突是典型可复现的 UI 破坏点。 |
| C44 | Keep | spatial memory / overlay local state / activeCell 保持分离，属于 R4 关键行为。 |
| C45 | Keep | z-order / hit-testing / safe-area 是实际可见故障面，必须单列。 |
| C47 | Keep | reduce motion 不是一个图的问题，而是各 zone 的降级语义要可读。 |
| C48 | Keep | Mac panorama 和 iPhone portrait 的 topology 不能互相借 proof。 |
| C49 | Keep | 证据类要求必须把静态图和时序证据分开。 |
| C50 | Keep | 这是防 contract inflation 的总闸门，应该保留为分类表。 |

## Delete

| ID | 处理 | 理由 |
| --- | --- | --- |
| 无 | 无 | 本轮没有发现必须直接删除的候选；更合理的是合并或重写。 |

## Merge

| ID | 合并到 | 理由 |
| --- | --- | --- |
| C31 | C32 / C39 | zone topology、字段映射、layout evidence 是同一簇，拆开会重复。 |
| C32 | C31 | 这是 C31 的字段化展开，不应单独形成第二个顶层问题。 |
| C39 | C31 / C37 | fixed zone pair 更像 layout evidence 归档，不是独立 contract 问题。 |
| C42 | C40 | stale-state clearing 是 snapshot lifecycle 的一部分，不必单立。 |

## Rewrite

| ID | 建议改写方向 | 理由 |
| --- | --- | --- |
| C34 | 改成“隐藏 operator surface 的显式路线 + a11y 替代入口 + 与 mic press 区分” | 现在问法混入过多手势细节，容易滑向实现说明。 |
| C40 | 改成“reset / theme / preset / force-context 后的 snapshot invalidation 与 stale clearing 规则” | 当前问法太宽，建议落到可验的生命周期规则。 |

## Missing Risks

| 风险 | 说明 |
| --- | --- |
| zone manifest 仍不显式 | 目前 snapshot 有字段，但没有一个统一的 zone manifest / owner map。 |
| operator surface 边界可能漂移 | C34/C36 若不拆清，容易把隐藏控制台写成用户功能。 |
| stale clearing 可能漏掉局部态 | reset / preset / macro / theme 切换后，局部 overlay、dialogue、orb、mic 的状态清理可能不一致。 |
| 证据类要求容易被静态图偷换 | C49 需要时间点 / 多帧 / 视频，否则很容易 fake green。 |
| schema 膨胀风险仍在 | C50 必须落成分类表，否则 presentation 细节会反向污染 bridge schema。 |

## Scores

| ID | 分数 | 层级判断 | 主要 verdict |
| --- | --- | --- | --- |
| C31 | 4 | R4 contract / visual policy | 值得保留，但应并入 zone manifest 簇。 |
| C32 | 4 | R4 contract | 有价值，但更像 C31 的字段化展开。 |
| C33 | 5 | R4 visual policy | 必留，属于跨 zone attention gate。 |
| C34 | 3 | R4 contract + 部分 R5 implementation | 有效，但问法过于实现化，建议重写。 |
| C35 | 5 | R4 contract | 必留，gesture arbitration 是核心交互门。 |
| C36 | 5 | R4 contract boundary | 必留，operator surface 不能被误读。 |
| C37 | 4 | R4 visual policy | 必留，capsule priority 是可观察语义。 |
| C38 | 4 | R4 visual policy | 必留，visible surface 不应暴露 raw control 数字。 |
| C39 | 3 | R4 visual evidence | 更像 layout evidence 子项，建议合并。 |
| C40 | 4 | R4 contract / visual policy | 值得保留，但应重写成生命周期语义。 |
| C41 | 5 | R4 contract | 必留，避免多区变化被压扁。 |
| C42 | 3 | R4 visual policy | 合并到 C40 更合理。 |
| C43 | 4 | R4 visual policy | 必留，滚动抢焦是常见真实故障。 |
| C44 | 5 | R4 contract / visual policy | 必留，spatial memory 是核心行为约束。 |
| C45 | 5 | R4 visual policy | 必留，z-order / hit-testing 是硬门。 |
| C46 | 4 | R4 contract / a11y policy | 必留，a11y 不能靠手势单通道。 |
| C47 | 5 | R4 visual policy | 必留，reduce motion 必须 zone-wise 可读。 |
| C48 | 4 | R4 proof policy | 必留，平台 topology 不能混用 proof。 |
| C49 | 5 | R4 evidence policy | 必留，静态图不足以证明时序。 |
| C50 | 5 | R4 schema governance | 必留，防 bridge / visual / evidence 边界失控。 |

## Candidate Notes

| ID | 备注 |
| --- | --- |
| C31 | 建议 owner：UIUE presentation；验证门：zone manifest / owner map / proof class 分层。 |
| C32 | 建议 owner：bridge/visual 共管；验证门：zone-to-field 映射是否可从 snapshot 直接读出。 |
| C33 | 建议 owner：UIUE interaction；验证门：跨 zone 时序截图 + 视频帧 + reduce motion 对照。 |
| C34 | 建议 owner：UIUE interaction / a11y；验证门：长按路线、取消半径、释放行为、替代入口。 |
| C35 | 建议 owner：UIUE interaction；验证门：mic press、long press、drag、scroll、overlay dismiss 的仲裁表。 |
| C36 | 建议 owner：产品/演绎控制台；验证门：入口标签与 proof class 不得改变 readiness 结论。 |
| C37 | 建议 owner：presentation；验证门：speed/gear、weather、time_period、macro、reset、safety refusal 的优先级表。 |
| C38 | 建议 owner：presentation / a11y；验证门：visible capsule 不出现 raw speed/gear 字面值。 |
| C39 | 建议 owner：layout / evidence；验证门：capsule、settings、refresh、safe area 的固定 zone pair 证明。 |
| C40 | 建议 owner：state reducer / presentation；验证门：force/reset/preset 后的 stale clearing 与 readback 同步。 |
| C41 | 建议 owner：macro / presentation；验证门：per-action activeCells、readbacks、burst、综合文案不丢失。 |
| C42 | 建议 owner：state reducer；验证门：reset/theme/preset 后旧 active/refused/thinking/pressing 不残留。 |
| C43 | 建议 owner：scroll policy；验证门：用户手动滚动时自动滚动不得抢焦。 |
| C44 | 建议 owner：overlay / focus；验证门：overlay 不重排、不吞 activeCell、不污染全局 store。 |
| C45 | 建议 owner：layout / hit-testing；验证门：ambient burst 不挡交互，capsule / dock / overlay 的 z-order 清晰。 |
| C46 | 建议 owner：a11y；验证门：identifier、label/value、adjustable 替代、long press 替代都要可达。 |
| C47 | 建议 owner：visual policy；验证门：orb、capsule、edge burst、waveform、card breathing、sheet transition 的 reduce-motion 静态读回。 |
| C48 | 建议 owner：platform proof；验证门：Mac 左右分栏与 iPhone 竖屏的 proof class 不能互相替代。 |
| C49 | 建议 owner：verification；验证门：必须有视频 / 时间点 / 多帧截图，而不是只给静态 screenshot。 |
| C50 | 建议 owner：schema governance；验证门：bridge schema、visual policy、evidence checklist 三栏分类表冻结。 |

## Residual Risk

- C31/C32/C39 仍需要一个更明确的 zone manifest 载体，否则 reviewer 很容易把布局、字段和证据混写。
- C34/C36 如果不重写成 operator surface boundary，后续会继续滑向“实现细节像需求”的问题。
- C40/C42 的 stale clearing 必须和 snapshot invalidation 一起验，否则 reset 以后很容易留下旧态残影。
- C49 不能靠单张静态图收口，必须补时序证据，否则高概率 fake green。
- C50 需要尽快固定分类表，否则 bridge schema 会被 presentation 细节持续膨胀。

# Brain 3 - Round 01 BLUE

## Persona

BLUE reviewer：HMI / presentation / evidence-shape reviewer。我的评分优先看用户可见状态是否能被 bridge 合同稳定表达：卡片、胶囊、小圆球/orb、reduce motion、readback、mixed outcome、视觉字段与 runtime 字段边界，以及 evidence receipt 是否足以防止 mock/simulator 证据被升格。

## Scope Read

- 已完整读取本轮 contract：`docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/contract.md`。
- 已完整读取 blind candidates：`docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/candidates-blind.md`。
- 已读取项目入口：`CLAUDE.md`、`docs/CURRENT.md`、`docs/README.md`。
- 已按 source pool 核关键证据：`docs/uiue-roadmap-2026-06-27-post-8c2-baseline.md`、`docs/grill-checklist/uiue-runtime-bridge-decisions-2026-06-25.md`、`openspec/changes/define-runtime-presentation-bridge/{proposal.md,design.md,tasks.md}`、实际 spec 路径 `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`、`docs/loop-competition/2026-06-27-uiue-r0-r2-grill-matrix/final-grill-matrix.md`、`docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md`、主线 `/Users/wanglei/workspace/MAformac/docs/CURRENT.md` 与相关 OpenSpec 摘要。
- 未读取本轮禁止文件：未读 `round-01/brain-1.md`、`round-01/brain-2.md`、`round-02/*` 或 judge 文件。
- Live repo note：UIUE HEAD `4a4aabb`，主线 HEAD `de79c65`；UIUE dirty tree 很多，本文件是本轮唯一写入目标。

## Keep

保留 C01-C30 全量进入 R4 矩阵。BLUE 视角没有纯删除项，因为 30 条里每条都对应一个真实 presentation failure mode 或 proof inflation path。

最高优先保留：

- C04 / C10 / C11 / C24 / C25：这些决定 UI 是否能从 `PresentationSnapshot` 单一路径表达 active/refused/sibling/availability/reduce-motion，而不是回退到 View 层猜测。
- C08 / C20 / C21：readback、trace/snapshot、terminal error snapshot 是 evidence-shape 的核心；没有它们，截图、卡片、TTS 文案和 receipt 会分叉。
- C09 / C14：proof_class 与 voice/orb 边界必须硬保留，否则 presentation choreography 会被误读成 runtime/voice ready。

## Delete

无建议删除。

低分项不是无价值，而是更偏治理或合并项：C23 图谱派生物、C18/C19 路线边界、C22 离线边界。它们仍应留在矩阵中，只是不应抢占 HMI hard gate 的位置。

## Merge

- C03 可与 C01 合并成“单一 bridge 权威 + mainline co-author 收敛机制”，但保留独立评分更利于 owner/stop condition 落地。
- C18 与 C19 都是 R4 不解锁 R5/mainline 后续门的 proof boundary，可在 final matrix 中同 route 汇总，但不建议删任一条：C18 防 bridge 越权到 C6/behavior taxonomy，C19 防 bridge schema 被当成 C5/golden/voice 解锁器。
- C26 可并入 C20 的 evidence alignment，但 worktree 串证风险足够高，建议独立保留为 receipt hygiene。

## Rewrite

- C06 建议改写为：“R4 是否明确 Core `ScopeOrigin` 当前三态与 bridge proposed `missing` 的兼容落点：扩 Core enum、单独 presentation enum，还是删 `missing`；且 UI 不得用中文 display string 反推 scope。”
- C14 建议把 `voice_state`、`orb_state`、`thinking`、胶囊动画统一写成 “presentation choreography fields”，并明确这些字段只可驱动可见状态，不可作为 ASR/TTS pipeline proof。
- C25 建议拆出可验证字段：`orb_state` 四态、capsule context 四维、theme policy、reduce-motion fallback、layout-safe zones。否则容易写成泛泛“视觉策略”。
- C28 建议把“测试计划”写成最小门矩阵：schema strict、fixture compat、unit projection、simulator capture、evidence checker、contract validation，各自 proof class 独立。

## Missing Risks

- 还缺一条明确的 “unknown / missing presentation field fail-closed visual behavior”：字段缺失时卡片、orb、capsule、readback 应显示降级态还是隐藏，不能让 View fallback 静默制造假绿。
- 还缺 “reduce motion 不等于 no motion only”：每个状态必须有非动画通道（色、图标、标签、reason、值变化），否则 reduce motion 下用户看不出状态差异。
- 还缺 “snapshot 字段与 visual token 的边界”：bridge 提供语义字段，UIUE visual policy 决定样式；不要把具体 halo 半径、玻璃材质、胶囊裁切写进 runtime contract。
- 还缺 “human-visible receipt shape”：除了 repo/branch/HEAD/proof_class，receipt 应绑定截图路径、UI tree evidence、crop/zone checker、launch args、theme/route/device，避免单张图脱离上下文。

## Scores

| Candidate | Score | BLUE verdict |
| --- | ---: | --- |
| C01 | 5 | keep |
| C02 | 5 | keep |
| C03 | 4 | keep / merge-with-C01 possible |
| C04 | 5 | keep |
| C05 | 5 | keep |
| C06 | 4 | rewrite |
| C07 | 4 | keep |
| C08 | 5 | keep |
| C09 | 5 | keep |
| C10 | 5 | keep |
| C11 | 5 | keep |
| C12 | 4 | keep |
| C13 | 4 | keep |
| C14 | 5 | rewrite |
| C15 | 4 | keep |
| C16 | 5 | keep |
| C17 | 4 | keep |
| C18 | 4 | merge-with-C19 possible |
| C19 | 4 | keep |
| C20 | 5 | keep |
| C21 | 5 | keep |
| C22 | 4 | keep |
| C23 | 3 | merge / keep as guardrail |
| C24 | 5 | keep |
| C25 | 5 | rewrite |
| C26 | 4 | keep |
| C27 | 4 | keep |
| C28 | 4 | rewrite |
| C29 | 4 | keep |
| C30 | 4 | keep |

## Candidate Notes

| Candidate | Note |
| --- | --- |
| C01 | 必问。UIUE `define-runtime-presentation-bridge` 已被接受为 mock snapshot consumption，但主线 CURRENT 仍记录 bridge `not_proposed` / runtime deferred；如果不锁单一合同权威，presentation 字段会在两树分叉。 |
| C02 | 必问。UIUE roadmap 明确 8.C2 仍 `PARTIAL_PENDING_L3`，contract 也禁止把 visual evidence 升级成 runtime/mainline acceptance；这是 BLUE proof-shape 底线。 |
| C03 | 强保留。mainline co-author review 不是仪式，而是决定 `missing scope_origin`、runtime projection、C3 mapping 谁收敛的机制。 |
| C04 | 必问。OpenSpec design/spec 已要求 `PresentationSnapshot` 携带 cards/readbacks/scope/trace/voice/orb/context/proof_class；这直接决定卡片、胶囊、orb 和 evidence 是否同源。 |
| C05 | 必问。`partial_accept_partial_refuse`、`already_state_noop`、`cancelled`、`runtime_error` 等终态必须是机器可读结果，否则 mixed outcome 会被 UI 显示成全局成功/失败。 |
| C06 | 保留但需改写。bridge design 明确 `missing` 是 future addition，Core 现有 `ScopeOrigin` 只有 `defaulted/explicit/fanout`；这个冲突必须由 mainline co-author 明确落点。 |
| C07 | 保留。R1/R2 的 default_scope、scope_origin、可操作集合若不进入 bridge，UIUE 只能继续靠本地 interaction policy，无法成为 runtime-presentation 合同。 |
| C08 | 必问。readback 必须从 Core/runtime result 到 UI card/dialogue/TTS/evidence 一条路；否则 summary、胶囊旁文案、TTS 和 receipt 会各自重算。 |
| C09 | 必问。design/spec 已写 finite proof_class 与 display cap；UIUE simulator/mock 截图不能显示 endpoint-ready、voice-ready、C6-ready 或 V/S/U-PASS。 |
| C10 | 必问。mixed outcome 需要 active/refused/sibling/per-action/readback 同时存在；只给一个 global result 会让用户看不出哪个动作成功、哪个被拒。 |
| C11 | 必问。制冷/制热、通风/加热等 sibling state 是视觉语义色和 active-cell substitution 的输入；OpenSpec 已把 sibling cell carriage 列为 requirement。 |
| C12 | 保留。`source` 是 value provenance，`scope_origin` 是 scope resolution，`trace_id` 是证据链；这三者一混，R5 很容易把 UI 触摸来源、范围推断和 runtime trace 污染在一起。 |
| C13 | 保留。force-context 应是 demo-mode bridge event，且 speed/gear/weather/time 是 context inputs/display facts，不是可控设备卡片或 live API 事实。 |
| C14 | 必问且需改写。`voice_state` / `orb_state` 可驱动 choreography，但 design 已明确不证明 ASR/TTS、golden、endpoint 或 V-PASS；orb 特别容易被误写成 voice readiness。 |
| C15 | 保留。event-driven thinking gates 与 safety-refusal fixed display 是两个语义；如果不拆，R5 会把演出节奏误读成 runtime 执行时序。 |
| C16 | 必问。design AD-RPB-002 要求 UIUE consume snapshot, not stores；presentation adapter 若直读 store/trace/raw command，会重新制造第二套 runtime-presentation SSOT。 |
| C17 | 保留。mainline C3 当前结果/guard/readback 需要投影到 `DemoRuntimeResult`，但 R4 不应反向改 C3/C6 行为合同；这是 bridge-as-adapter 的边界。 |
| C18 | 保留/可合并。bridge 只能承载 presentation contract，不负责 C6 acceptance、behavior taxonomy 或模型质量；否则 R4 会吃掉 post-C6 主线任务。 |
| C19 | 保留。C5 retrain、LoRA candidate、demo golden、voice golden、endpoint readiness 在主线 OpenSpec 中仍是 deferred 或独立门；bridge schema 存在不等于这些门解锁。 |
| C20 | 必问。trace_id/turn_id/snapshot version/evidence receipt 是 screenshot、fixture、sim capture、runtime log replay 的对齐主轴；没有稳定 identity，证据不可复查。 |
| C21 | 必问。timeout/cancel/runtime_error/unsupported/safety refusal/partial refusal 都必须产 terminal snapshot；异常路径没有视觉证据时，demo 会只证明成功态。 |
| C22 | 保留。离线、端侧、无云、mock 车控、短记忆是项目宪法边界；bridge 不应变成线上 API、持久化服务或真车控执行层。 |
| C23 | 中分保留。graph manifest、visual evidence manifest、route table 适合作 derived/index artefacts；但 BLUE 视角它是治理护栏，不能替代 C04/C20 这类用户可见字段。 |
| C24 | 必问。action availability、disabled reason、writeback/no-op 若不由 bridge 携带，UI 只能显示假按钮、hover/pressed 语义或本地禁用态。 |
| C25 | 必问且需改写。capsule/orb/theme/reduce motion 必须来自 presentation fields 或 explicit visual policy；尤其 reduce motion 下不能只靠动画、玻璃高光或 halo 表达状态。 |
| C26 | 保留。当前 UIUE/mainline 双 worktree 且 dirty state 多；receipt 必须写 repo/branch/HEAD/dirty ownership/proof_class，否则极易串证。 |
| C27 | 保留。schema version 与 fixture compatibility 是 R4/R5 并行演进的安全阀；没有破坏性变更规则，UIUE snapshot fixture 很快会 stale。 |
| C28 | 保留但需改写。不要一口气造 `make verify-all`，而要拆 schema/fixture/unit/simulator/evidence/contract validation，每一门 proof class 独立。 |
| C29 | 保留。R4 exit criteria 必须说明哪些 P0/P1 grill burndown、哪些 notes carry、哪些 runtime/voice/model lanes 另开，否则 R4 会假装进入 R5。 |
| C30 | 保留。Liquid4All/H5/FastAPI/旧 bridge 只能作为参考；外部字段、样式、runtime 假设直接复制会破坏 MAformac 的端侧/离线/mock 边界。 |

## Residual Risk

- 本评审是 blind reviewer 输出，不读取同轮其它 reviewer 或 judge；结论只代表 BLUE/HMI/evidence-shape lens。
- 本轮未运行测试、未打开模拟器、未验证截图；proof class 是 planning / audit checklist only。
- Contract source pool 中列出的 `specs/ui-presentation/spec.md` 路径 live 不存在；我按实际存在的 `specs/runtime-presentation-bridge/spec.md` 核证，controller 后续应修正 contract 路径或在 judge 里记录。
- 评分会高估 HMI/evidence 风险、低估实现成本；GREEN/PURPLE/ORANGE 视角仍需补 owner、schema versioning、test harness 和 SSOT 细节。

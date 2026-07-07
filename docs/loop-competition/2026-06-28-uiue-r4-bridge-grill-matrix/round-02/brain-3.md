# Round 02 Brain 3 - BLACK Reviewer

## Persona

BLACK = skeptical product judge / ontology and roadmap critic。我的判断优先级：用户最终能否据此做路线决策 > bridge 字段是否完整 > 单个 UI/测试问题是否好修。

术语先归一：

- `bridge`：只指 Runtime -> Presentation 的事件 / 结果 / snapshot / trace 合同词表，不等于 runtime backend 已实现。
- `R4`：合同交汇与主线 co-author 收敛阶段，不是 R5 runtime/voice/model 实装阶段。
- `human notes`：人审通过后的残留约束，不是完成态；notes 不能被改写成无风险。
- `proof_class`：证据类型标签；local/unit/simulator/human_review 不能升级成 mobile、true_device、runtime-ready、voice-ready 或 V-PASS。

核心 ontology verdict：候选集总体是有价值的，但最大风险不是“字段还缺哪个”，而是把 **合同存在**、**UIUE mock 可消费**、**mainline runtime 已吸收**、**R5 可开工** 混成一条顺滑叙事。这是类别错误，不是措辞小问题。

## Scope Read

已读：

- `docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/contract.md`
- `docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/candidates-blind.md`
- `AGENTS.md`、`CLAUDE.md`、`docs/CURRENT.md`、`docs/README.md`
- `docs/uiue-roadmap-2026-06-27-post-8c2-baseline.md`
- `docs/grill-checklist/uiue-runtime-bridge-decisions-2026-06-25.md`
- `openspec/changes/define-runtime-presentation-bridge/{proposal.md,design.md,tasks.md}`
- `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`
- 允许 source pool 内的 `2026-06-27-uiue-r0-r2-grill-matrix/final-grill-matrix.md` 和 `uiue-r0-r2-grill-burndown-2026-06-27.md`
- mainline `/Users/wanglei/workspace/MAformac/docs/CURRENT.md`、`docs/README.md` 与相关 OpenSpec change 摘要

未读且保持盲评：

- 未读本轮 `round-01/*`
- 未读本轮 `round-02/brain-1.md`
- 未读本轮 `round-02/brain-2.md`
- 未读任何 judge 文件

证据边界：

- contract 指向的 `openspec/changes/define-runtime-presentation-bridge/specs/ui-presentation/spec.md` 当前不存在；实际存在的是 `specs/runtime-presentation-bridge/spec.md`。这是 source-pool/路径命名缺口。
- UIUE `docs/CURRENT.md` 记录 bridge 已 accepted for mock visual consumption，但 mainline `docs/CURRENT.md` 仍把 Runtime-Presentation bridge 标成 `not_proposed`，runtime/voice/golden/UIUE 仍 deferred。该冲突必须作为 R4 决策风险处理。

## Keep

P0 Keep：

- C01、C02、C03：这是 R4 的路线真问题。若不先解决单一合同权威、proof boundary、mainline co-author owner，后面的字段讨论会变成局部正确、路线错误。
- C08、C09、C12：readback/proof/source/scope/trace 的边界是防 fake-green 的主干。
- C16、C17、C18、C19：这些直接挡住 UIUE 反向污染 mainline、bridge 反向改写 C3/C6、以及把 schema 当作 LoRA/golden/voice 解锁。
- C21、C22、C23：异常终态、端侧离线边界、derived manifest 非 authority，都是产品级灾难防线。
- C26、C27、C29：跨 worktree 串证、schema 版本演进、R4 exit criteria 是用户能否放心拍板的最低条件。

P1 Keep：

- C04、C05、C06、C10、C11、C20、C24、C25、C28、C30。都应该保留，但多数需要重写成更可验的合同/证据问题，避免泛问。

## Delete

不建议硬删任何 C01-C30。理由：这一批不是低质候选堆，而是 R4/R5 分类风险的不同切面。

但若最终必须压缩，优先不保留为独立 workstream 的是：

- C11：可并入 C04/C10 的 sibling / active / refused cell schema。
- C25：可并入 C14/C15/C20 的 presentation choreography / snapshot evidence。
- C30：可并入 C22/C23 的 reference-only / no second authority 边界。

## Merge

- C04 + C10 + C11 + C24：合并为“PresentationSnapshot 是否能表达 value、sibling、available action、writeback/readback、active/refused/per-action result，且 UI 不回读 raw store”。四题本质是 snapshot 是否足够承载可操作语义。
- C08 + C12 + C20 + C26：合并为“readback/evidence/trace/replay/receipt 单链路”。否则会有四份相似的 trace/proof 问法。
- C14 + C15 + C25：合并为“voice/orb/thinking/capsule 是 presentation choreography，不是 runtime/voice proof，并且时序不能反推执行时序”。
- C18 + C19 + C29：合并为“R4 exit 不得自动解锁 R5 runtime/voice/model/golden/C5/C6”。
- C22 + C30：合并为“离线端侧边界 + 外部参考不可迁入权威”。

## Rewrite

- C04：加验收形态。不要只问“字段是否足以”；改成要求列出 `required / optional / unknown / missing`、unknown fail-closed、以及至少 3 个 mixed/sibling fixture。
- C06：必须点名 bridge `missing` 与 Core 三态不一致的仲裁。当前不是“兼容策略”泛问，而是 mainline co-author 必须扩 enum、删 missing 或引 presentation enum。
- C07：从“接入 bridge 语义”改成“哪些 R1/R2 proof 是 bridge input，哪些只是 UIUE projection，不得反向变 producer SSOT”。
- C13：force-context 要改成 demo-mode event + provenance + customer-facing build isolation 三件套；否则会被误听成真实车况 API。
- C17：改成“最小兼容草图不得改变 C3/C6 已有行为合同，且标出 adapter 层归属”。否则 bridge 会偷吃 runtime redesign。
- C28：不要问 `make verify-all`，改成最小可跑门矩阵：schema validation、fixture replay、unit projection、simulator smoke、receipt lint、contract diff。

## Missing Risks

- R4 source-pool 路径已经漂移：contract 要求的 spec 路径不存在，实际 spec 名称是 `runtime-presentation-bridge`。若 final matrix 不记录这个缺口，用户会误以为 source pool 自洽。
- mainline 与 UIUE 对 bridge 状态的词汇不一致：UIUE 是 accepted-for-mock-consumption；mainline route board 仍 not_proposed/deferred。这不是历史小误差，而是 co-author handoff 的核心风险。
- “accepted by 磊哥”容易被滥用：它只接受 contract shape 可供 UIUE mock visual consumption，不是 runtime implementation acceptance。
- `human_review PASS_WITH_NOTES` 容易被产品叙事吞掉 notes。notes 不挡 8.C2 closeout，不代表白边、final art、mobile/true_device、runtime binding 已解决。
- 候选集缺一个直接问题：R4 是否要先产出一个 “bridge status vocabulary” 表，统一 `accepted/proposed_strict_valid_contract_only/not_proposed/deferred` 这些跨树词。
- 候选集缺一个用户决策问题：若 mainline co-author 拒绝 `missing` scope_origin，UIUE 已消费的 mock snapshot 如何降级或迁移？
- 候选集缺一个 rollback 问题：UIUE adapter 若先接 mock snapshot，后续 mainline runtime adapter 字段不兼容时，哪些 visual proof 作废？

## Scores

| ID | Score | Verdict |
| --- | ---: | --- |
| C01 | 5 | Keep |
| C02 | 5 | Keep |
| C03 | 5 | Keep |
| C04 | 4 | Rewrite |
| C05 | 4 | Keep |
| C06 | 5 | Rewrite |
| C07 | 4 | Rewrite |
| C08 | 5 | Keep |
| C09 | 5 | Keep |
| C10 | 4 | Merge |
| C11 | 4 | Merge |
| C12 | 5 | Keep |
| C13 | 4 | Rewrite |
| C14 | 5 | Keep |
| C15 | 4 | Merge |
| C16 | 5 | Keep |
| C17 | 5 | Rewrite |
| C18 | 5 | Keep |
| C19 | 5 | Keep |
| C20 | 4 | Merge |
| C21 | 5 | Keep |
| C22 | 5 | Keep |
| C23 | 5 | Keep |
| C24 | 4 | Merge |
| C25 | 4 | Merge |
| C26 | 5 | Keep |
| C27 | 5 | Keep |
| C28 | 4 | Rewrite |
| C29 | 5 | Keep |
| C30 | 4 | Merge |

## Candidate Notes

| ID | Note |
| --- | --- |
| C01 | 最高价值。R4 先问“谁是单一合同权威”，否则 bridge 会同时存在 UIUE accepted、mainline not_proposed、future graph manifest 三种权威幻觉。 |
| C02 | 必保留。R3 `PASS_WITH_NOTES` 只能关闭 8.C2 simulator/mock visual scope；不能升级成 runtime/mainline acceptance。 |
| C03 | 必保留。mainline co-author review 不是礼貌流程，而是解决 `missing scope_origin`、runtime-side implementation 和路线牌冲突的 owner gate。 |
| C04 | 保留但重写。问题要从“足不足”变成必列字段、默认值、unknown/missing fail-closed、fixture 和消费路径。 |
| C05 | 强。结果枚举能防止 bare rejected 和 mixed outcome 丢失；但要明确 display aggregate 只能在 machine-readable class 之后出现。 |
| C06 | 强且要更尖锐。Core 三态 vs bridge `missing` 第四态是当前真实冲突，不能被“兼容策略”模糊化。 |
| C07 | 有价值但容易重复。重点不是“接入语义”，而是 R1/R2 interaction proof 哪些能作为 bridge input，哪些只是 UIUE consumer projection。 |
| C08 | 必保留。readback 若没有单一数据路径，UI 卡片、TTS、receipt 会各自讲真话，合起来就是假系统。 |
| C09 | 必保留。finite proof_class + downgrade 是防验收膨胀的硬门。 |
| C10 | 强但可并入 C04。mixed outcome 的 active/refused/sibling/per-action/readback 都是 snapshot schema 完整性问题。 |
| C11 | 值得保留为 schema 子项，不宜独立膨胀。sibling state 是 semantic styling 和 active-cell substitution 的基础。 |
| C12 | 必保留。`source`、`scope_origin`、`scope`、`readback.source`、`trace_id` 不拆清会造成 provenance/scope/evidence 污染。 |
| C13 | 保留但重写为 demo-mode force-context event。车速/挡位/天气/时间段是 fixture/context，不是 live vehicle or API。 |
| C14 | 必保留。voice_state/orb_state 是 choreography，不能被销售叙事写成 ASR/TTS ready。 |
| C15 | 有价值但和 C14 合并。两段 thinking 的 ontology 是 presentation timing vs runtime execution timing，不是动画细节。 |
| C16 | 必保留。UIUE adapter 不得读 runtime store/C3 trace/raw command/backend private structure，这是防止 presentation 反客为主。 |
| C17 | 必保留但重写。需要“adapter 草图不改 C3/C6 行为合同”的负约束。 |
| C18 | 必保留。bridge 是 presentation contract，不负责 C6 acceptance、behavior taxonomy、模型质量。 |
| C19 | 必保留。C5 retrain、LoRA candidate、demo/voice golden、endpoint readiness 都是 R5/mainline gates，不能被 schema 存在解锁。 |
| C20 | 强但可并入 trace/receipt 合并项。稳定 `trace_id` / `turn_id` / version / evidence receipt 是 replay 对齐的最低成本。 |
| C21 | 必保留。异常终态若没有 terminal snapshot，demo 只证明 happy path，客户现场风险最大。 |
| C22 | 必保留。离线端侧、无云依赖、mock 车控、三轮记忆是项目 ontology；bridge 不能扩成服务层。 |
| C23 | 必保留。graph/evidence/capability/route manifest 只能 derived，不能成为第二 authority。 |
| C24 | 有价值但并入 C04/C07。action availability/writeback/no-op 应由 bridge 携带，但问题要防 UI 本地禁用态冒充合同。 |
| C25 | 有价值但更像 visual policy 合并项。多主题、reduce motion、orb/capsule 不能散落各主题分支。 |
| C26 | 必保留。双 worktree 并行时 repo/branch/HEAD/dirty/proof_class 是防串证的产品级保护。 |
| C27 | 必保留。版本号和兼容规则决定 R4 checklist、R5 adapter、mainline tests 能否并行，而不是互相等待。 |
| C28 | 保留但重写。不要大一统门；要最小可跑、可失败、可定位的 gate matrix。 |
| C29 | 必保留。R4 exit criteria 是本轮最接近用户可决策的候选之一，必须定义 P0/P1 burndown 与 R5 分线。 |
| C30 | 保留但可并入 C22/C23。Liquid4All/H5/FastAPI/旧 bridge 只能 reference-only，不得携带字段/样式/runtime 假设入合同。 |

## Residual Risk

本评审是 planning/audit proof，不是 implementation proof。没有运行 OpenSpec validate、Swift tests、simulator、mainline co-author review 或任何 runtime adapter。我的主要 verdict：**C01/C02/C03/C06/C08/C09/C12/C16-C19/C21-C23/C26/C27/C29 应作为 R4 P0/P1 主干；C04/C10/C11/C24/C25/C28/C30 应合并重写，避免 30 项表面完整但路线仍不可拍板。**

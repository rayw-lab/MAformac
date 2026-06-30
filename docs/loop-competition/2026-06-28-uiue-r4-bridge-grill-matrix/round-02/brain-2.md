# Round 02 ORANGE Review - UIUE R4 Bridge Grill Matrix

## Persona

ORANGE：test and harness engineer / validation matrix reviewer。

我的评分只看一个问题：这个 grill 能否转成最小、可复跑、可失败、可归因的验证门。优先级高的题目必须能落到 schema validation、fixture replay、unit tests、simulator evidence、contract validation、negative paths、proof-class cap、dirty proof attribution 或跨 repo receipt 对齐。反过来，虽然产品上重要但只能停留在路线口号、非目标声明或人工协调的题目，分数会压低或建议合并。

## Scope Read

已按盲评要求完整读取：

- `docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/contract.md`
- `docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/candidates-blind.md`

按 contract 的 source pool 读取和取证：

- `docs/uiue-roadmap-2026-06-27-post-8c2-baseline.md`
- `docs/CURRENT.md`
- `docs/grill-checklist/uiue-runtime-bridge-decisions-2026-06-25.md`
- `openspec/changes/define-runtime-presentation-bridge/proposal.md`
- `openspec/changes/define-runtime-presentation-bridge/design.md`
- `openspec/changes/define-runtime-presentation-bridge/tasks.md`
- `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`
- `docs/loop-competition/2026-06-27-uiue-r0-r2-grill-matrix/final-grill-matrix.md`
- `docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md`
- `/Users/wanglei/workspace/MAformac/docs/CURRENT.md`
- `/Users/wanglei/workspace/MAformac/docs/README.md`
- `/Users/wanglei/workspace/MAformac/openspec/changes/`

盲评边界：

- 未读取 `round-01/*`。
- 未读取 `round-02/brain-1.md`、`round-02/brain-3.md` 或任何 judge 文件。
- 仅写入本文件；未修改其它文件、未 git add/commit/push。

取证要点：

- UIUE `define-runtime-presentation-bridge` 已被记录为 contract-only、strict validated、可供 A-2 mock snapshot 视觉消费；这不是 runtime-ready、V-PASS 或 mainline acceptance。
- Mainline `docs/CURRENT.md` 仍把 Runtime-Presentation bridge 记为 `not_proposed`，runtime/backend、C5、C6、voice/golden/UIUE 均 deferred。这是 R4 必须显式验证的跨 repo route tension。
- Contract 中列的 source path `specs/ui-presentation/spec.md` 在 live tree 不存在；实际 spec 是 `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`。这本身支持 C28/C26 类“机械合同路径验证”的重要性。

## Keep

- C04、C05、C08、C09、C10、C20、C21、C24、C26、C27、C28、C29 必保留为 hard grill。它们都能直接变成最小验证门：schema 枚举、fixture negative cases、terminal snapshot、trace/evidence alignment、proof class cap、dirty proof receipt、version/compat contract validation。
- C01、C02、C03 也应保留，但 ORANGE 视角不是因为它们能直接单测，而是它们定义测试归属和验收边界；没有这些，后续任何 harness 都会把 UIUE contract proof 和 mainline runtime proof 混成假绿。
- C06、C07、C11、C12、C16、C17 可保留，前提是改写成可测的 adapter/fixture 检查，而不是概念争论。

## Delete

- 不建议直接删除任何候选。C01-C30 都覆盖真实风险。
- 但 C14、C18、C19、C22、C30 不宜作为独立 test-harness workstream；更适合并入 proof-class / non-goals / reference-only contract gate，否则会把验证矩阵膨胀成路线宣言。

## Merge

- C14 + C15：合并成“presentation choreography 不得冒充 voice/runtime timing”的一组验证门；fixture 应断言 `voice_state/orb_state/thinking gates` 的 proof cap 和事件边界。
- C18 + C19：合并为“bridge 不解锁 C5/C6/golden/voice/model”的 downstream gate；这类非目标最好做成 closeout forbidden-claim grep + route-board checklist，而不是功能测试。
- C22 + C30：合并为“边界与外部参考禁迁入”红线；可用 dependency/import/path grep、fixture provenance 和 doc claim checks。
- C04 + C11：部分合并为 `PresentationSnapshot.cards[].sibling_cells` schema/fixture 门；C04 保留总 schema，C11 作为 sibling-specific negative case。
- C20 + C26：合并到 evidence receipt schema：repo、branch、HEAD、dirty ownership、trace_id、turn_id、snapshot version、proof_class、artifact paths 一起验证。

## Rewrite

- C01：改写为“R4 exit 前必须有一个 contract-authority check：UIUE accepted contract、mainline route-board `not_proposed/deferred` tension、禁止第二份 bridge SSOT，三者在 receipt 中逐项标注 owner 和 next gate。”
- C06：改写为具体 enum compatibility gate：fixture 覆盖 Core 三态 `defaulted/explicit/fanout` 与 bridge-proposed `missing`，未知值 fail-closed，不允许 UI fallback 到 display string 推断。
- C13：改写为 demo-mode fixture gate：force-context 必须经 bridge event 写入 `context.vehicle/environment`，并在 receipt 标注 demo-only/provenance；不得渲染为可控 device card。
- C23：改写为 derived-artifact manifest gate：graph/evidence/capability/route manifest 必须声明 source contract digest，且不得定义新 authority IDs。
- C25：改写为 explicit visual-policy gate：布局/orb/reduce motion 可来自 presentation fields 或 visual policy，但必须可枚举、可截图/fixture 重放，不要要求所有主题逻辑都塞进 bridge schema。

## Missing Risks

- 缺少一个明确的 `contract source path exists` gate。当前 contract source pool 指向 `specs/ui-presentation/spec.md`，live tree 实际为 `specs/runtime-presentation-bridge/spec.md`；R4 需要机械验证 source pool、spec path、OpenSpec change id 和 receipt 链路。
- 缺少 `unknown enum fail-closed` 的专门负例矩阵：未知 `result_kind`、未知 `proof_class`、未知 `scope_origin`、未知 `visual_state`、缺 `trace_id`、缺 terminal snapshot 都应失败，而不是降级成 success UI。
- 缺少 fixture naming/version policy：R4/R5 并行时，fixture 文件名、snapshot version、schema digest、expected failure mode 要稳定，否则回归很难归因。
- 缺少 “dirty proof attribution” 最小 schema：repo、branch、HEAD、dirty status、owned/unowned/generated/no-touch、proof class、command、artifact path、captured_at。
- 缺少 “no fake all-in-one gate” 的硬规则：C28 提到了，但 final matrix 应明确 R4 最小门分层，不允许一个 `make verify-all` 名字同时代表 schema/unit/simulator/evidence/mainline acceptance。
- 缺少 route-tension regression：UIUE `accepted for mock visual consumption` 与 mainline `not_proposed/deferred` 必须在每个 bridge closeout 中复核，不能只在本轮文档里说一次。

## Scores

| ID | Score | ORANGE route |
| --- | ---: | --- |
| C01 | 5 | R4-contract / R4-mainline-coauthor |
| C02 | 5 | R4-evidence |
| C03 | 4 | R4-mainline-coauthor |
| C04 | 5 | R4-test-harness |
| C05 | 5 | R4-test-harness |
| C06 | 4 | R4-contract |
| C07 | 4 | R4-contract |
| C08 | 5 | R4-test-harness |
| C09 | 5 | R4-evidence |
| C10 | 5 | R4-test-harness |
| C11 | 4 | R4-contract |
| C12 | 4 | R4-contract |
| C13 | 4 | R4-test-harness |
| C14 | 3 | R4-evidence |
| C15 | 4 | R4-test-harness |
| C16 | 4 | R4-contract |
| C17 | 4 | R4-mainline-coauthor |
| C18 | 3 | Mainline-roadmap |
| C19 | 3 | Mainline-roadmap |
| C20 | 5 | R4-evidence |
| C21 | 5 | R4-test-harness |
| C22 | 3 | Mainline-roadmap |
| C23 | 4 | R4-contract |
| C24 | 5 | R4-test-harness |
| C25 | 4 | R4-evidence |
| C26 | 5 | R4-evidence |
| C27 | 5 | R4-contract |
| C28 | 5 | R4-test-harness |
| C29 | 5 | R4-contract |
| C30 | 3 | Mainline-roadmap |

## Candidate Notes

| ID | Note |
| --- | --- |
| C01 | 必保留。没有单一合同权威和 mainline/UIUE tension check，所有测试归属都会漂移；应变成 closeout 必填字段。 |
| C02 | 必保留。`PASS_WITH_NOTES`、visual evidence、runtime proof、mainline acceptance 必须是不同 proof class；适合做 forbidden-upgrade checker。 |
| C03 | 强保留。owner/输入/输出/阻断条件不清会导致 harness 无 owner；但需要改成 co-author review receipt schema。 |
| C04 | 必保留。`PresentationSnapshot` 字段、默认值、missing/unknown fail-closed 是 schema validation 核心。 |
| C05 | 必保留。`result_kind` 枚举是负路径测试的中心；必须覆盖 already/cancel/runtime_error/partial 等 terminal outcomes。 |
| C06 | 保留并改写。Core 三态 vs bridge `missing` 是真实兼容风险；需要 enum adapter fixture 和 unknown-value fail-closed。 |
| C07 | 保留。R1/R2 的 `default_scope/scope_origin/action availability` 必须进入 bridge semantic fixture，不能只留 UIUE unit。 |
| C08 | 必保留。readback 单一路径可用 fixture replay 验证：卡片、胶囊、TTS 文案、receipt 不得各算各的。 |
| C09 | 必保留。finite `proof_class` + downgrade cap 是 ORANGE P0；应有未知 proof_class 和 fake readiness negative tests。 |
| C10 | 必保留。mixed outcome 是防假 all-success UI 的关键；需要 per-action fixture 与 UI snapshot assertion。 |
| C11 | 强保留。sibling cells 是制冷/制热等语义样式的 contract dependency；可并入 C04 的 card schema 门。 |
| C12 | 强保留。`source/scope_origin/scope/readback.source/trace_id` 分离可做 schema lint 和 fixture assertion，避免证据污染。 |
| C13 | 强保留。force-context 必须 demo-only、bridge-event、provenance traceable；不然安全拒绝 fixture 无法归因。 |
| C14 | 有用但合并。`voice_state/orb_state` 不等于 voice-ready，可并入 proof-class cap 和 choreography gate。 |
| C15 | 强保留。thinking gates 可以转成 event-sequence fixture，尤其防 fixed delay 冒充 runtime timing。 |
| C16 | 强保留。UIUE adapter 禁读 store/raw command 是可 grep/code-review 的 harness gate；应明确 debug flag 例外。 |
| C17 | 强保留。C3/C3ExecutionResult 到 `DemoRuntimeResult` 的兼容草图需要 contract tests，但不能反向改 C3/C6。 |
| C18 | 合并。presentation contract 不负责 C6/model quality 是重要边界，但更像 forbidden-claim/route gate。 |
| C19 | 合并。C5/LoRA/golden/voice/endpoint 不自动解锁，适合 closeout grep 和 route-board checklist。 |
| C20 | 必保留。trace/turn/snapshot/evidence 对齐是可复跑验证的骨架；应纳入 receipt schema。 |
| C21 | 必保留。timeout/cancel/runtime_error/unsupported/safety/partial 的 terminal snapshot 是负路径最小门。 |
| C22 | 有用但合并。离线端侧/mock 边界应进 non-goals/import-dependency guard，不必单独成 R4 harness 大项。 |
| C23 | 强保留。derived/index artefacts 不是 authority，适合 manifest source-digest gate，防第二套 ID。 |
| C24 | 必保留。action availability、disabled reason、writeback/no-op 可转成 unit + fixture + simulator proof。 |
| C25 | 强保留。布局/orb/reduce motion 需要 explicit visual policy 或 presentation fields；不要让主题分支散落。 |
| C26 | 必保留。dirty proof attribution 是跨 worktree 串证的最高风险之一；receipt 必填。 |
| C27 | 必保留。schema version/fixture compatibility/breaking-change rules 是 R4/R5 并行演进的基础。 |
| C28 | 必保留且最高优先级。必须拆 schema/fixture/unit/simulator/evidence/contract validation；禁止假 `verify-all`。 |
| C29 | 必保留。R4 exit criteria 要能机械判断进入 R5 的条件、携带 notes 和另开 lanes。 |
| C30 | 有用但合并。外部 H5/FastAPI/reference-only 是重要红线，适合并入 dependency/provenance/import guard。 |

## Residual Risk

- 本评审是 planning/audit checklist proof，不是 implementation proof；没有运行 Swift tests、OpenSpec validate 或 simulator。
- 我没有读取禁读的 Round 01/其它 Round 02 reviewer/judge 文件，因此不知道其它 persona 的分歧；最终 judge 仍需合并六视角。
- 分数偏向“能不能测试和复跑”，可能低估了纯产品/路线治理项的战略价值；这些项应由 BLACK/PURPLE 补权重。
- 当前 source pool 存在 spec path 漂移，建议 controller 在 final matrix 里保留 C28/C26，并新增机械路径校验到 R4-test-harness。

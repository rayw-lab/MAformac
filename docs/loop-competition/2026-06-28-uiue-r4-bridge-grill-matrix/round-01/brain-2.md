# Round 01 GREEN Review

## Persona

- 角色：Round 01 `GREEN reviewer`。
- 视角：implementation coordinator / sequencing and ownership reviewer。
- 关注点：R4 出口、R5 入口、single authority、mainline co-author、burndown 路线、最小可执行验证门、避免 R4 吸收 R5 runtime/voice/model 实装。
- 总 verdict：这 30 题方向基本对，但真正的 P0 不该散掉。R4 最该前置的是 authority 冲突、co-author owner、`scope_origin/default_scope` 单源、adapter 边界、proof class 上限、最小 gate、R4 exit -> R5 split；弱项主要是几道 HMI/编排题与 contract/route 题混层。

## Scope Read

- live repo truth：
  - UIUE repo：branch=`uiue/phase4-default-scope-presentation`，HEAD=`4a4aabb`，dirty tree 存在。
  - mainline repo：HEAD=`de79c65`。
- 已读必需文件：
  - `docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/contract.md`
  - `docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/candidates-blind.md`
- 已读 source pool / authority：
  - UIUE：`docs/CURRENT.md`
  - UIUE：`docs/uiue-roadmap-2026-06-27-post-8c2-baseline.md`
  - UIUE：`docs/grill-checklist/uiue-runtime-bridge-decisions-2026-06-25.md`
  - UIUE：`openspec/changes/define-runtime-presentation-bridge/proposal.md`
  - UIUE：`openspec/changes/define-runtime-presentation-bridge/design.md`
  - UIUE：`openspec/changes/define-runtime-presentation-bridge/tasks.md`
  - UIUE：`openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`
  - UIUE：`docs/loop-competition/2026-06-27-uiue-r0-r2-grill-matrix/final-grill-matrix.md`
  - UIUE：`docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md`
  - mainline：`docs/CURRENT.md`
  - mainline：`docs/README.md`
  - mainline：`openspec/changes/define-demo-default-scope/{proposal,tasks}.md`
  - mainline：`openspec/changes/define-demo-golden-run-and-voice/{proposal,tasks}.md`
  - mainline：`openspec/changes/retrain-c5-lora-d-domain/proposal.md`
  - mainline：`openspec/changes/rebuild-c6-four-layer-bench/proposal.md`
- 盲评边界已遵守：
  - 未读取 `round-01/brain-1.md`
  - 未读取 `round-01/brain-3.md`
  - 未读取 `round-02/*`
  - 未读取任何 judge 文件
- 本轮关键证据结论：
  - UIUE `docs/CURRENT.md` 已把 `define-runtime-presentation-bridge` 记为 accepted for mock visual consumption，且明写 mainline runtime-side co-author review pending。
  - mainline `docs/CURRENT.md` 仍把 `Runtime-Presentation bridge` 记为 `not_proposed`，并把 C5/C6/runtime/voice/UIUE downstream 全部列为 deferred。
  - UIUE 路线图已明确 R4 是 contract intersection，R5 才是 runtime / voice / model 分线。
  - bridge tasks 已明确：proposal/design/spec strict-valid 只是 contract authored，不等于 implementation started，更不等于 runtime readiness。

## Keep

- `C01`、`C03`、`C29`：必须保留。它们决定 R4 有没有可执行出口，而不是只剩一堆字段题。
- `C02`、`C09`、`C26`：必须保留。proof class 和 worktree provenance 不锁，R3 notes-pass 会被误升级成 R4/R5 ready。
- `C06`、`C07`、`C08`、`C24`：必须保留。`scope_origin/default_scope/available_actions/writeback/readback` 是 bridge 真正的 implementation seam。
- `C16`、`C17`：必须保留。一个挡 UIUE 读 store，一个挡 mainline 反向改 C3/C6。
- `C18`、`C19`：必须保留。R4 只做 presentation contract，不做 post-C6/C5/C6/golden/voice/model readiness 吸收。
- `C27`、`C28`：必须保留。没有 version/fixture/minimal gate，contract 会变成“写出来但无人敢接”的半成品。
- `C05`、`C21`：必须保留。terminal result vocabulary 和异常终态不是边角，而是 runtime-to-presentation 的主干。

## Delete

- 本轮无建议直接删除项。
- 弱项存在，但问题主要是重叠或写法过宽，不是完全离题。

## Merge

- `C10` + `C11`
  - 合并成一题更好：mixed outcome snapshot 是否同时携带 `active_cell`、`refused_cell`、`per_action_results`、`sibling_cells` 与互斥当前态。
  - 理由：`C11` 单独问 sibling/mutual exclusion 太窄，且设计稿已经把它放进 snapshot card schema。
- `C14` + `C15`
  - 合并成“presentation choreography 语义边界”更好。
  - 理由：一个讲 `voice_state/orb_state/thinking` 不是 voice readiness，另一个讲 analyzing think vs safety-refusal think 的时序语义；落地上是同一组 event/gate 设计题。

## Rewrite

- `C03`
  - 改成：mainline co-author review 的 owner、输入工件、输出工件、blocker、升级路径、回写位置是否写清。
  - 当前版本点到了 owner，但还不够像可执行 checklist。
- `C07`
  - 改成：R4 是否把 `default_scope`、`scope_origin`、`available_actions`、`disabled_reason`、`writeback/no-op` 这些 R1/R2 交互真值字段显式接入 bridge。
  - 当前“可操作设备集合”太泛。
- `C25`
  - 改成：哪些必须进 bridge 字段，哪些只能是 explicit visual policy，哪些仍属 visual-only，不允许散落成主题分支私货。
  - 当前把 layout/theme/orb/reduce motion 混成一团，太宽。
- `C29`
  - 改成：R4 exit packet 是否写清，包括 co-author verdict、route-board sync、carry-forward unresolved、child-lane split 规则、以及不得在 R4 内偷跑 R5 implementation。
  - 当前有“进入 R5 条件”，但还不够 receipt 化。
- `C30`
  - 改成：外部 H5/FastAPI/旧 bridge 只能 `reference only`，禁止字段复制、样式复制、runtime 假设复制和 authority promotion。
  - 当前边界对“不能直接 copy field shape”说得还不够硬。

## Missing Risks

- 缺一题直问：mainline `docs/CURRENT.md` 里的 `not_proposed` 何时、由谁、通过什么 artifact 修正成与 UIUE accepted contract 对齐的真态。现在这是 live coordination gap，不是 prose 差异。
- 缺一题直问：mainline co-author review 的输出物是什么。至少该包括 mainline route-board 更新、no-second-bridge confirmation、以及 runtime-side implementation 仍 deferred 的回写。
- 缺一题直问：`default_scope` apply 与 bridge `scope_origin`/`missing` 第四态仲裁的依赖关系。若 `AD-RPB-011` 未和 mainline `ScopeOrigin` 对齐，R4 出口不能算稳。
- 缺一题直问：最小 adapter proof bundle。建议最低是 schema contract validation + fixture 正例 + fixture fail-closed 反例 + mapping unit + simulator receipt + worktree/proof receipt。
- 缺一题直问：`openspec validate` / accepted docs-only 是否被误当成 execution authorization。tasks 已明确 authored/validated != implementation started，但候选集中没有单独把这个假绿风险拎出来。

## Scores

| ID | 分数 | 处置 |
| --- | --- | --- |
| C01 | 5 | Keep |
| C02 | 5 | Keep |
| C03 | 5 | Rewrite |
| C04 | 4 | Keep |
| C05 | 5 | Keep |
| C06 | 5 | Keep |
| C07 | 5 | Rewrite |
| C08 | 5 | Keep |
| C09 | 5 | Keep |
| C10 | 4 | Keep |
| C11 | 3 | Merge |
| C12 | 4 | Keep |
| C13 | 4 | Keep |
| C14 | 4 | Keep |
| C15 | 3 | Merge |
| C16 | 5 | Keep |
| C17 | 5 | Keep |
| C18 | 5 | Keep |
| C19 | 5 | Keep |
| C20 | 4 | Keep |
| C21 | 5 | Keep |
| C22 | 4 | Keep |
| C23 | 4 | Keep |
| C24 | 5 | Keep |
| C25 | 3 | Rewrite |
| C26 | 5 | Keep |
| C27 | 5 | Keep |
| C28 | 5 | Keep |
| C29 | 5 | Rewrite |
| C30 | 4 | Rewrite |

## Candidate Notes

- `C01`：5 分。必须保留。UIUE `docs/CURRENT.md` 已写 bridge accepted for mock visual consumption，但 mainline `docs/CURRENT.md` 仍是 `not_proposed`；这不是措辞问题，而是 R4 single-authority 冲突。
- `C02`：5 分。必须保留。R0-R2 已锁 `local/unit/simulator != L3/mobile/true_device/V-PASS`，R4 必须把 `operator-pass with notes`、`UIUE visual evidence`、`runtime proof`、`mainline acceptance` 继续拆开。
- `C03`：5 分。改写后保留。当前题意对，但要补 owner、输入工件、输出工件、阻断条件、升级路径；否则“co-author review pending”仍只是状态词，不是执行门。
- `C04`：4 分。保留。bridge spec/design 已把 `PresentationSnapshot` 做成 implementation seam，这题能直接卡住“UI 回退读 raw store 猜语义”的歪路。
- `C05`：5 分。必须保留。`DemoRuntimeResult.result_kind` 是 runtime 到 presentation 的第一道 contract 面；少了 mixed/noop/error/cancel，R5 adapter 一接就会发明私有枚举。
- `C06`：5 分。必须保留。`scope_origin missing` 第四态是 live 未决，不是学术问题；UIUE bridge decisions 已明写要 mainline co-author 仲裁。
- `C07`：5 分。改写后保留。题目方向对，但“接入 bridge 语义”要落到 `default_scope`、`scope_origin`、`available_actions`、`disabled_reason`、`writeback/no-op` 等可实现字段。
- `C08`：5 分。必须保留。readback/source/proof/scope/per-action/final copy 若各自重算，R4 一过桥就会把 UI 文案、卡片态、receipt 三套说法分叉。
- `C09`：5 分。必须保留。design/spec 已经锁 finite `proof_class` + display cap；这题是防假绿的硬门，不是文案细节。
- `C10`：4 分。保留。mixed outcome 是 bridge 真需求，不是 corner case；设计稿已经把 `partial_accept_partial_refuse`、`active_cell`、`refused_cell`、`per_action_results` 拉出来了。
- `C11`：3 分。建议并入 `C10` 或 `C04`。本质是 snapshot card schema 的 sibling carriage/互斥态表达，单列会和 mixed outcome 题重叠。
- `C12`：4 分。保留。`source`、`scope_origin`、`scope`、`readback.source`、`trace_id` 不拆清，后面 trace/proof/runtime 展开时会互相污染。
- `C13`：4 分。保留。spec 已锁 force-context 必须经 bridge event 且不能被渲成可控设备卡；这题能挡住“demo condition 冒充 live vehicle state”。
- `C14`：4 分。保留。`voice_state`/`orb_state` 只能证明 choreography，不证明 voice-ready；这条边界后面一定会被误踩。
- `C15`：3 分。建议并入 `C14`。thinking 两语义和 choreography 本就是同一组 gate 设计，不必拆成两道几乎相邻的问题。
- `C16`：5 分。必须保留。design `AD-RPB-002` 已经很硬：UIUE consumes snapshots, not stores；这是防 R4 吸收 R5 backend 私有结构的主守门。
- `C17`：5 分。必须保留。proposal 明写 mainline 现在只有零散 pieces、没有 named UI-facing bridge；没有最小 mapping sketch，UIUE 和 runtime 两边都会开始发明字段。
- `C18`：5 分。必须保留。R4 只做 presentation contract，不做 post-C6 identity / behavior-shape rebuild；否则 bridge 题会吞掉 C6 taxonomy 和 model-quality lane。
- `C19`：5 分。必须保留。mainline changes 已把 retrain/C6/golden/voice 全写成 downstream deferred gate，这题正是防“有 schema 就默认解锁后续实施”。
- `C20`：4 分。保留。trace/version/receipt 稳定标识是 replay、截图、unit fixture、runtime log 串起来的最小条件；当前 source pool 还没把它冻死，所以值得问。
- `C21`：5 分。必须保留。timeout/cancel/runtime_error/unsupported/safety/partial refusal 如果没有统一 terminal snapshot，异常路径就会继续变成第二等级公民。
- `C22`：4 分。保留。离线、端侧、无云依赖、mock 车控、3 轮记忆是项目宪法级边界，R4 如果不重复锁，R5 很容易被“顺手接服务”带偏。
- `C23`：4 分。保留。design `AD-RPB-015` 已经明确 graph manifest 只能 derived，不得再造第二套 authority；这题是防后续治理层偷升格。
- `C24`：5 分。必须保留。R1 interaction integrity 如果只停留在按钮本地禁用态，就没真正进入 bridge；要把 `available_actions`、`reason`、`no-op`、writeback 真正带过去。
- `C25`：3 分。改写后保留。当前把 layout/capsule/orb/theme/reduce motion 混成一团，像 HMI 总问句，不像 R4 sequencing 题；要改成字段归属与 visual policy 边界题。
- `C26`：5 分。必须保留。mainline 已明写不得把 UIUE file:line 当 current mainline proof；receipt 里不写 repo/branch/HEAD/dirty/proof class，就会串证。
- `C27`：5 分。必须保留。当前 bridge contract 已有字段草图，但 version/fixture compatibility/breaking-change rule 还没冻结；不问这题，R5 adapter 和测试会边接边飘。
- `C28`：5 分。必须保留。前一轮矩阵已经锁过：先做 `verify-uiue-interactions` 这种专门 gate，不直接塞 `make verify-all`；R4 应该继承这种最小可执行门哲学。
- `C29`：5 分。改写后保留。它是 GREEN 视角最关键的收口题之一，但要从“进入 R5 条件”再推进到“R4 exit packet + child-lane split rule”。
- `C30`：4 分。改写后保留。路线图已经写了 Liquid4All/H5/FastAPI 只能 `reference only`，但题面应进一步禁止字段/样式/runtime 假设复制和 authority promotion。

## Residual Risk

- 这是 blind review of candidate set，不是 controller 最终合成 verdict；我评的是题面质量和执行可用性，不是最终 30 行矩阵本身。
- source pool 里 mainline `docs/CURRENT.md` 与 UIUE `docs/CURRENT.md` 存在 live tension；controller 若不先修 route truth，后续 reviewer 很容易围着 stale route board 打转。
- 本轮证据多为 route board / OpenSpec / grill ledger / plan-grade artifact；它们足以评 checklist，但不构成 runtime implementation proof。
- UIUE worktree 当前是 dirty state，后续若 controller 要把任何本轮注记转成 file:line 或 closeout 结论，必须再次 live-probe HEAD 与 ownership。

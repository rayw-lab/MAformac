## Persona

RED reviewer：failure auditor / proof-class and overclaim hunter。我的评审重点不是“题目是否漂亮”，而是它能否挡住 fake-green、跨 worktree 串证、R4/R5 越界、`8.C2` 误关闭、voice/runtime/model ready 误声明，以及 source-of-truth 冲突被 prose 抹平。

## Scope Read

- 已完整读取本轮 contract：`docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/contract.md`。
- 已完整读取 blind candidates：`docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/candidates-blind.md`。
- 按 contract source pool 读取/抽证：
  - UIUE `docs/CURRENT.md`：bridge accepted 仅限 A-2 mock snapshot visual consumption；不等于 runtime/voice/C6/endpoint/V/S/U-PASS；mainline co-authorship 仍 pending；`8.C2` 仍 open。
  - UIUE `docs/uiue-roadmap-2026-06-27-post-8c2-baseline.md`：R4 只是 bridge contract intersection；R5 才是 runtime / voice / model 分线；UIUE proof 默认 local/unit/simulator，不是 mainline/mobile/true-device。
  - UIUE `openspec/changes/define-runtime-presentation-bridge/{proposal,design,tasks}.md` 与实际 spec：`openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`。
  - UIUE R0-R2 final matrix 与 burndown：`8.C2` 仍 open；R1/R2b 现有证明多为 local/unit/checker/simulator，仍不能升格。
  - mainline `/Users/wanglei/workspace/MAformac/docs/CURRENT.md`：mainline 仍把 Runtime-Presentation bridge 标为 `not_proposed`，runtime/backend、C5、C6、voice/golden/UIUE 均 deferred 或待独立 proof。
- Source-pool 异常：contract 指向 `openspec/changes/define-runtime-presentation-bridge/specs/ui-presentation/spec.md`，但实际路径是 `specs/runtime-presentation-bridge/spec.md`。这会削弱后续机械验证，必须作为 source-risk 留下。
- 当前 worktree 观察：UIUE 与 mainline 都有既有 dirty state；任何 receipt 都必须写 repo、branch、HEAD、dirty ownership 和 proof class，不能跨树互证。

## Keep

- 必留 P0：C01、C02、C03、C06、C08、C09、C12、C14、C16、C17、C18、C19、C23、C26、C29、C30。
- 强保留：C04、C05、C07、C10、C11、C13、C15、C20、C21、C22、C24、C27、C28。
- 这些题覆盖了本轮最危险的失败模式：UIUE accepted 与 mainline `not_proposed` 冲突、8.C2/R3 visual proof 被升格、bridge schema 被写成 runtime readiness、voice/orb 字段被误读为 ASR/TTS readiness、外部 H5/FastAPI/Liquid4All 变成隐性 authority。

## Delete

- 不建议直接删除任何候选。C25 相对最弱，因为它把 layout/orb/theme policy 与 bridge presentation fields 混在一起，但它仍能挡住“主题分支散落逻辑”这个真实风险。

## Merge

- C04 + C11 可以合并成 “snapshot 是否携带足够 cell/sibling/unknown/fail-closed 信息，禁止 raw store 推断”。
- C14 + C15 可以合并成 “voice/orb/thinking/choreography 与 ASR/TTS/runtime execution proof 分层”。
- C20 + C26 + C27 可以合并成 “trace/version/receipt/replay identity 与 worktree proof-class 防串证”。
- C18 + C19 + C29 可形成 R4 exit/R5 entry 的 hard gate 组，但不应完全合并，因 C18 管 C6/behavior-shape，C19 管 C5/golden/voice/endpoint，C29 管阶段出口。

## Rewrite

- C05：候选写 `accepted/refused`，但实际 bridge spec 使用 `accepted_tool_call`、`refusal_no_available_tool`、`refusal_safety_or_policy`。应改成检查“候选词表是否对齐 spec 词表，且显示层 `rejected` 不得替代机器可读拒绝类”。
- C06：需要明确 `missing` 是 bridge-proposed future addition，不是当前 Core `ScopeOrigin`；mainline co-author 必须决定扩 enum、另建 presentation enum 或删除 `missing`。
- C13：应把 force-context 的 proof class 写进去：demo fixture/context input 可以影响 safety guard 和 presentation context，但不得声称 live vehicle state / live API。
- C25：建议改成“哪些字段属于 bridge schema，哪些属于 explicit visual policy”，避免把所有布局/主题决策硬塞进 runtime bridge。
- C28：应明确最小验证门必须能独立失败和定位，不允许一个总命令掩盖 schema、fixture、unit、simulator、evidence、contract validation 的 proof class 差异。

## Missing Risks

- Source pool 路径错误风险：contract 指向不存在的 `specs/ui-presentation/spec.md`，若 controller 机械验证照此路径跑，会假阴性或绕过真实 spec。
- Mainline freshness 风险：UIUE 侧说 bridge accepted，但 mainline `docs/CURRENT.md` 仍是 `not_proposed`。最终矩阵必须把这写成 coordination risk，不要用 “已 accepted” 一句话吞掉。
- `tasks.md` 状态歧义：bridge proposal/design/spec 已 authored/validated，但 tasks 中很多 downstream implementation/review 项仍 unchecked。候选需要防止 `isComplete=true` 被误读成 implementation complete。
- `8.C2` 误关闭风险仍大：R0-R2 burndown 已有 partial/local/unit/simulator proof，但 L3/V-PASS、人审、mobile/true-device 均未满足。
- Proof-class label 漂移风险：`simulator_l0_runtime_truth`、`local_checker`、`operator-pass with notes`、`mock snapshot consumption` 都容易被最终 closeout 写成 `runtime-ready` 或 `mainline accepted`。
- External reference 风险：Liquid4All/H5/FastAPI/audio vocabulary 可以参考，但不能复制字段或 runtime 假设进 MAformac/UIUE contract。

## Scores

| ID | Score | RED verdict |
| --- | ---: | --- |
| C01 | 5 | essential |
| C02 | 5 | essential |
| C03 | 5 | essential |
| C04 | 4 | keep |
| C05 | 4 | rewrite-keep |
| C06 | 5 | essential |
| C07 | 4 | keep |
| C08 | 5 | essential |
| C09 | 5 | essential |
| C10 | 4 | keep |
| C11 | 4 | keep |
| C12 | 5 | essential |
| C13 | 4 | rewrite-keep |
| C14 | 5 | essential |
| C15 | 4 | keep |
| C16 | 5 | essential |
| C17 | 5 | essential |
| C18 | 5 | essential |
| C19 | 5 | essential |
| C20 | 4 | keep |
| C21 | 4 | keep |
| C22 | 4 | keep |
| C23 | 5 | essential |
| C24 | 4 | keep |
| C25 | 3 | rewrite-or-merge |
| C26 | 5 | essential |
| C27 | 4 | keep |
| C28 | 4 | rewrite-keep |
| C29 | 5 | essential |
| C30 | 5 | essential |

## Candidate Notes

| ID | Note |
| --- | --- |
| C01 | P0。直接命中 UIUE accepted vs mainline `not_proposed` 的 SSOT 冲突；必须保留并要求写单一权威与不再开第二桥。 |
| C02 | P0。防止 R3 visual/operator proof 被升级成 R4/R5 ready；这是本轮 RED 核心。 |
| C03 | P0。mainline co-author review 不是礼貌流程，而是当前冲突的唯一收敛点。 |
| C04 | 强。snapshot 字段与 fail-closed 是 raw store 推断的防线，可与 C11 合并但不可丢。 |
| C05 | 强但需改词表。实际 spec 不是裸 `accepted/refused`，必须对齐 `accepted_tool_call` 等机器枚举。 |
| C06 | P0。`missing` 第四态是明确未决；若不 grill，会把 Core 三态和 bridge future addition 混成假完成。 |
| C07 | 强。R1/R2 的 default_scope、scope_origin、可操作集合必须进入 bridge 语义，否则 UIUE 单元 proof 不能支撑 R4。 |
| C08 | P0。readback 如果多路径重算，UI 卡片、胶囊、TTS/文案、receipt 会产生假一致。 |
| C09 | P0。finite proof_class + downgrade rules 是防 fake-green 的总闸。 |
| C10 | 强。mixed outcome 是真实 runtime/presentation 断点；防全局成功/失败遮蔽 per-action 结果。 |
| C11 | 强。sibling state 是 semantic styling 与 active-cell substitution 的必要输入，可并入 C04。 |
| C12 | P0。`source`、`scope_origin`、scope、readback.source、trace_id 混淆会污染 R5 trace 和 proof。 |
| C13 | 强。force-context 必须被限定为 demo event/fixture，不能冒充真实车况或 live API。 |
| C14 | P0。voice_state/orb_state 是 choreography，不是 voice-ready；必须保留。 |
| C15 | 强。thinking gate 很容易被 R5 当 runtime timing proof；需保留但可与 C14 成组。 |
| C16 | P0。UIUE adapter 若读 raw runtime store/C3/private backend，bridge contract 就失效。 |
| C17 | P0。需要最小 C3/C3ExecutionResult/TraceEntry 映射草图，但不能反向改 C3/C6 行为合同。 |
| C18 | P0。bridge 只承载 presentation contract，不负责 C6 acceptance 或 behavior taxonomy 完成。 |
| C19 | P0。C5 retrain、LoRA candidate、golden、voice、endpoint 均是后续门；schema 存在不解锁。 |
| C20 | 强。trace/turn/version/evidence identity 是 replay 与跨树对齐基础，可与 C26/C27 成组。 |
| C21 | 强。异常路径必须有 terminal snapshot，否则只有成功态证据，会 fake green。 |
| C22 | 强。防止 bridge 被扩成云 API、持久服务或真实车控执行层，符合项目红线。 |
| C23 | P0。graph/manifest/evidence index 必须 derived，不得成为第二套 authority。 |
| C24 | 强。action availability、disabled reason、writeback、no-op 必须从 bridge 到 UI，不只靠本地按钮态。 |
| C25 | 中。主题/layout/orb/reduce-motion 风险真实，但题面应拆 schema 字段与 explicit visual policy，避免 bridge 过载。 |
| C26 | P0。repo/branch/HEAD/dirty/proof_class 是 UIUE/mainline 串证的最低防线。 |
| C27 | 强。version/fixture compatibility 是 R4/R5 并行演进必要条件。 |
| C28 | 强但需改写。测试计划要拆 proof class 与失败定位，不要总门洗平差异。 |
| C29 | P0。R4 exit/R5 entry 是最容易过度宣布 ready 的地方，必须硬写。 |
| C30 | P0。Liquid4All/H5/FastAPI/旧 bridge 只能 reference-only，不能字段/样式/runtime 假设直搬。 |

## Residual Risk

- 我没有读取 round-01 其他 brain、round-02 或 judge 文件，保持盲评；因此未比较其他 reviewer 的意见。
- 本评审是 planning/audit checklist proof，不是 implementation proof。
- 由于当前 UIUE/mainline worktree 均有既有 dirty state，后续 controller 必须机械验证本文件之外是否存在 concurrent edits；不要把本 brain 的 repo observation 当成最终 merge readiness。
- 若最终 matrix 需要 file:line 级引用，controller 应重新用 `nl -ba` 固化精确行号；本文件只记录候选评审与承重证据路径。

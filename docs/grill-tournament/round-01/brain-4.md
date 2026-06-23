## 保留项

- R1-Q02 保留。它直指 `generated/` 是否被 drift gate 覆盖，且可以用 `Makefile` 和 `make verify` 机械验证，是 A2 派单前的硬地基题。
- R1-Q04 保留。demo/full 双层 codegen 是 A2 产物边界的核心问题，能逼出字段同源、派生深度、验证命令，决策杠杆高。
- R1-Q05 保留。train/eval/runtime surface 同源是 0/34 复发防线，必须落成 fail-closed gate；这是最值得保留的工程合同题之一。
- R1-Q07 保留。全仓级联清单是 CAS1 的正确入口，要求逐命中裁决而非批量替换，具体、可审、能防文档和代码旧锚残留。
- R1-Q08 保留。它把治理问题落到 archived specs 的 observable behavior，避免“措辞变化就重开 spec”的治理噪声。
- R1-Q01 保留但必须改写。方向对，但“工具数”仍容易被误解为 intent 数或 runtime mount 数；需要把产出物、字段口径和实算命令写死。

## 删除项

- 无纯删除项。
- R1-Q09 不建议作为独立原题保留。它的问题意识对，但“是否强制引入 Superpowers verification/subagent gate”太容易变成流程口号；应拆掉品牌化措辞，把可验证部分并入 R1-Q06 的训练中途 gate 和 R1-Q05 的同源 gate。

## 合并项

- R1-Q03 + R1-Q08 合并成一条 OpenSpec 收敛题：先定“什么时候必须从 amend 切到正式 OpenSpec change”，再逐核 C1/C3/C6 archived specs 的 observable behavior 是否需要 MODIFY。Q08 的逐 spec 颗粒度不能丢，Q03 的载体门槛不能单独空转。
- R1-Q06 + R1-Q09 合并治理闭环：Q06 负责 checkpoint 抽样指标、阈值、early-stop/human-pause；Q09 只保留“三个流程检查点必须落成什么命令/receipt/artifact”的要求。
- R1-Q01 + R1-Q04 不合并，但必须前后依赖：先由 Q01 算清 model-visible mounted tool count，再由 Q04 定 demo/full 两层 codegen 产物边界。把它们合成一题会变宽，反而削弱可验性。
- R1-Q05 与 R1-Q06 不合并。前者验 surface 同源，后者验训练动态健康；同属防灾难，但 failure mode 不同。

## 改写建议

- R1-Q01 改成：A2 派单前必须产出 `demo-mounted-tool-surface` 清单，字段至少含 `tool_name`、`intent_id`、`device_id`、`value_form`、`runtime_mounted`、`source_rule`、`source_ref`；用 3990 contract + xlsx 第15列 col O 或明示替代优先级规则实算。定义 `intent`、`tool`、`device`、`model-visible surface`、`canonical IR`，并禁止把 534 intent 写成工具数。
- R1-Q02 增加产物名单要求：不仅问 `generated/` 是否覆盖，还要列出 A2 新增的 full/demo D-domain 工具目录、tool-card/state 映射、surface inventory、parity fixture 哪些进入 `GENERATED_CONTRACTS` 或等价 diff gate；验收命令应是可复制的。
- R1-Q03 改为门槛题：哪些变更属于 discovery amend，哪些改变 observable behavior 必须进入 specs，哪些 A2 派单前若无 OpenSpec change 就 blocker。要求给出 change 粒度和依赖序，不要停在“要不要治理”。
- R1-Q04 增加字段边界表：full 只保留 `tool_name/domain/service_group/value_form/unsupported_refusal` 级轻目录；demo 才包含 arg enum、ds_protocol、mock/state/readback 映射。要求证明两层由同一 3990 source + 同一 codegen commit 派生。
- R1-Q05 指名 gate 形态：例如 `verify-tool-surface-parity` 输出 train/eval/runtime 三份 inventory 的 digest 和 diff；缺 artifact、非同源 digest、工具名/required args/value_form mismatch 都 fail closed。要能抓 `train=tool_call_frame`、`eval/runtime=D-domain` 这类 PR5 0/34 型错位。
- R1-Q06 保留 50/100/150，但要求抽样轴更明确：trigger rate、tool-name exact、required-args exact、state-delta/action hard pass、unsupported/safety false-call 分开看；阈值要区分 early-stop、human-pause、continue-with-warning，不能只给一个总 pass_rate。
- R1-Q07 改成清单 schema：`target_file`、`anchor`、`current_claim`、`verdict(change/no-change/supersede/delete)`、`new_frame`、`blocking_gate`、`owner/change_id`。覆盖 `docs/`、`openspec/`、`contracts/`、`generated/`、`Core/`、`Tools/`、`scripts/`，并保留“禁止批量替换”。
- R1-Q08 增加 spec requirement 粒度：逐条列 C1/C3/C6 哪些 Requirement/Scenario 的 observable behavior 被 D-domain surface 或 4-layer C6 改变；仅术语漂移走 docs cleanup，不走 MODIFY。
- R1-Q09 改成“流程门落地题”：不要问是否采用某个 Superpowers 名称，改问重训前、训练中、候选签名前各自必须有哪三个检查点、哪个命令、哪个 receipt 字段、谁签字、失败如何阻断。

## 遗漏风险

- 缺 B1 端侧挂载白名单/受限解码题。A2 的“model-visible tool surface”最后要在端侧 parser/mount whitelist 生效，仅 train/eval/runtime 同源还不够；需要单独问 `tool_not_in_whitelist=0`、防御解析、mlx-swift 端侧可行性。
- 缺 state-cells/tool-card map 题。D-domain 具名工具多，mock state/card 少，A2 不能只改工具目录；还要问 tool→IR→state_cell→card_patch 的映射是否从同源派生。
- 缺 held-out/negative/refusal 数据门题。R1-Q06 看 checkpoint，但没有明确 D-domain 四类数据下的 held-out 切法、unsupported/safety negative、IrrelAcc/false-call 口径。
- 缺 generator/judge 防假绿题。自然中文数据会引入语义漂移，候选里没有单独要求异源 judge、parent semantic key、ambiguous duplicate gate。
- 缺 A2 parity baseline 题。候选问了 C6 中途和 archived specs，但没有明确 A2 迁移验收应比相对 A2-before 不退化，而不是要求绝对全绿。
- 缺 raw/source availability 题。Q01 依赖 xlsx 第15列 col O，但 clone 仓可能没有 raw；需要问 source-free 验证与 raw-only 提取之间的边界。
- 缺治理文档级联的 cross-section gate 扩展题。Q07 要 grep 清单，但还应追问 `verify-cross-section` 是否覆盖 grill-decisions/handoff/roadmap 旧数字漂移。

## 评分

| 候选 | 重要性 | 可验证性 | 非重复性 | 主线决策杠杆 | 风险揭示 | 总分 | 建议 |
|---|---:|---:|---:|---:|---:|---:|---|
| R1-Q01 | 5 | 4 | 4 | 5 | 5 | 23/25 | rewrite-keep |
| R1-Q02 | 5 | 5 | 5 | 5 | 4 | 24/25 | keep |
| R1-Q03 | 4 | 3 | 3 | 5 | 4 | 19/25 | merge/rewrite |
| R1-Q04 | 5 | 4 | 4 | 5 | 4 | 22/25 | keep/rewrite |
| R1-Q05 | 5 | 5 | 4 | 5 | 5 | 24/25 | keep |
| R1-Q06 | 5 | 4 | 4 | 5 | 5 | 23/25 | keep/rewrite |
| R1-Q07 | 5 | 5 | 5 | 4 | 5 | 24/25 | keep |
| R1-Q08 | 4 | 4 | 4 | 5 | 4 | 21/25 | keep/merge |
| R1-Q09 | 4 | 2 | 2 | 3 | 4 | 15/25 | merge/rewrite |

## 理由

- 这 9 题整体选题方向是对的：它们覆盖 AUD1-AUD6、GOV1/GOV2/GOV6、TRN2/TRN3、CAS1，正好贴住 A2 派单地基。当前文档已把 AUD 组列为最高优先 A2 地基，尤其是 generated drift、534 intent 非工具数、两层 codegen、同源 enforce、全仓级联（`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:351-357`）。
- 最强题的共同点是“可落机器门”：Q02 可对 `Makefile:4-9` 与 `Makefile:50-51`，Q05 可落 surface parity gate，Q07 可落逐文件裁决清单。它们不会停留在抽象观点。
- Q01 很重要，因为文档已经坐实 3990/671/1538、191 device、534 intent、工具数待 col O/value-form 实算，且 534 被误当工具数会导致全链路口径错（同文档 `:414-419`）。但原题仍要收紧产物和字段定义，否则又会把 intent、tool、runtime mount 混在一起。
- Q03/Q08 是同一条治理链。单问 amend vs OpenSpec 太宽；单问 archived specs 又缺切换门槛。合并后才能回答“何时起 change、改哪些 Requirement、哪些只是文档 cleanup”。
- Q09 是最弱题，不是因为问题不重要，而是因为它把可验证 gate 包在流程工具名里。真正能防 0/34 和 0/23 的不是“用了 Superpowers”，而是训练前同源门、训练中 C6 抽样门、签名前 artifact/receipt 门。
- 候选集最大盲区是端侧落地和 state 映射：A2 不只是工具目录，还是 ToolContractCompiler、C5 样本、C6 bench、state-cells、mock card、端侧 parser 的整条 surface 迁移。当前题目对 train/eval/runtime 问得强，对 mount whitelist、state-cell/card map、source-free 验证问得不够。

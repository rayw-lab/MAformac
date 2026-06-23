## 保留项

- **硬保留**：R3-Q03、R3-Q05、R3-Q08。这三题分别卡住决策级联、推进事实源、训练/拒识门的核心失真点，且都能要求表格、阈值、文件 banner 或 gate 产物，主线杠杆最高。
- **保留但需改写**：R3-Q01、R3-Q02、R3-Q04、R3-Q07、R3-Q09。它们方向正确，但当前措辞仍有“把层合成一个概念”“把已拍方向重新讨论”“只问机制不问物理落点”的风险。
- **条件保留**：R3-Q06。原题价值在于防止把 surface 修复误判为 recipe 问题；但若按原文“逐项重审配方”执行，会和已确认的 `rank16Mainline` 守现状发生冲突。应改成“配方重开门槛”题，而不是“recipe 重新拍板”题。

## 删除项

- **无硬删除项**。这 9 题整体覆盖 Round 03 指定的 CAS4-CAS8 与 TRN1/TRN4/TRN5/TRN6。
- 若最终必须裁剪，优先删除 **R3-Q06 原样版本**，只保留其改写后的“recipe reopen guard”。原因：配方守 `rank16Mainline` 已在最新收口里再次确认，原样提问会诱导重复争论。

## 合并项

- **R3-Q06 可合并到训练 gate 体系**：若名额紧张，把它并入已确认的训练中途 gate / surface parity 类问题，作为一个子约束：“只有 train/eval/runtime surface parity 已过、G6-C 仍失败，才允许重开 LR/rank/scale/iter。”
- **R3-Q07 与 R3-Q08 不建议合并**：R3-Q07 管 split topology 和 leakage，R3-Q08 管指标定义和阈值。二者相关但物理产物不同，合并会把“怎么切数据”和“怎么判 pass”混成一个大题。
- **R3-Q09 不建议并入 R3-Q07/R3-Q08**：它是 generator/judge/oracle 红线的生产机制题，和 split/gate 不同。可与既有 C1/G3 拍板衔接，但不应被吞掉。

## 改写建议

- **R3-Q01**：不要要求“统一 taxonomy”到只剩一套分层；应要求输出 `route_tier / execution_fallback_tier / runtime_scope / safety_outcome` 的映射表、owner、source file、trace 字段和 C4/C6 断言，证明没有双源分层。
- **R3-Q02**：补物理落点：SRD、demo docs、roadmap banner 中必须出现 `demo_allowed_families=10`、`deferred_domains=[navigation,music,food_delivery]`、`unsupported_policy`，并要求族外样本进入 unsupported eval。
- **R3-Q03**：基本可保留。小改为强制 D1-D37 每行包含 `decision_id / old_claim / new_status / evidence / cascade_files / blocking_gate`，否则容易只写叙事总结。
- **R3-Q04**：改成“两层 invariant”题：MASTER 必须显式写 `IR remains value-four-tuple`、`surface is derived named-tool layer`、`generic frame forbidden as model-visible surface`，并定义 drift check。
- **R3-Q05**：补 single-source-of-progress 的执行规则：新事实源文件名、旧 roadmap banner 文案、禁止引用旧进度的 grep/check、以及何时允许 append-only vs rewrite。
- **R3-Q06**：改成“配方重开门槛”题：列 `frozen_knobs=[lr1e-4, rank16, scale20, repo_loop, metrics_jsonl]`、`variable_knobs=[checkpoint cadence, data mix, surface parity]`，并规定只有 G6-C 通过前置但仍失败才可重开配方。
- **R3-Q07**：要求具体 split schema：按 `data_class` 分层后，再定义 `family / value_form / utterance_template / semantic_parent / tool_name` 的优先级；并要求 leakage checker 对每类数据给 fail condition。
- **R3-Q08**：保留强度。建议加 gate matrix：`positive_action`、`followup_rewrite`、`unsupported_refusal`、`safety_refusal`、`false_call`、`IrrelAcc` 各自定义分母、阈值、冲突优先级，禁止用一个 aggregate pass_rate。
- **R3-Q09**：改成 data recipe artifact 题：要求 `generator_family`、`judge_family`、`judge_family != generator_family`、`per_seed`、`raw_oracle_policy`、`near_duplicate_gate`、`label_authority=contract`、`distractor_policy` 都落到可验字段。

## 遗漏风险

- **B1 端侧 decode 假设**：候选没有显式追问 mlx-swift 端侧是否真支持 GBNF/受限解码；最新材料已提示端侧可能只能走 LoRA 格式 + JSON 防御解析 + whitelist enforce。
- **B2 state-cells 扩 10 族**：CAS/TRN 题没有覆盖 mock 端态从 4 族扩到 10 族的硬前置；这会影响 runtime tier、C6 demo layer、UI card map。
- **F1 safety 分层**：R3-Q08 提到 safety refusal，但未明确“安全动作不能变模型可选工具，拦截走 risk-policy/DemoGuard”。若不写清，可能把 safety tool 化。
- **CAS1 前置清单**：R3-Q01-Q05 都是级联子题；若没有先做 CAS1 全文件清单，容易局部修 SRD/roadmap 后仍留下旧 frame。
- **数据预算与成本**：R3-Q09 问 generator/judge 选型和样本量，但未强制估算调用量、成本、耗时和人工审计预算。
- **TRN2/TRN3 依赖**：train/eval/runtime surface parity 与 mid-training C6 gate 已在前两轮确认，但 Round 03 单看这 9 题时没有直接出现。最终列表不能丢。

## 评分

| ID | 重要性 | 可验证性 | 不重复性 | 主线决策杠杆 | 风险揭示 | 总分/25 | 建议 |
|---|---:|---:|---:|---:|---:|---:|---|
| R3-Q01 | 5 | 4 | 4 | 5 | 5 | 23 | rewrite |
| R3-Q02 | 5 | 4 | 4 | 5 | 4 | 22 | keep with rewrite |
| R3-Q03 | 5 | 5 | 5 | 5 | 4 | 24 | keep |
| R3-Q04 | 5 | 4 | 4 | 5 | 5 | 23 | rewrite |
| R3-Q05 | 5 | 5 | 4 | 5 | 5 | 24 | keep |
| R3-Q06 | 4 | 4 | 3 | 3 | 4 | 18 | rewrite or merge |
| R3-Q07 | 5 | 4 | 5 | 5 | 4 | 23 | keep with rewrite |
| R3-Q08 | 5 | 5 | 5 | 5 | 5 | 25 | keep |
| R3-Q09 | 5 | 4 | 4 | 4 | 5 | 22 | keep with rewrite |

## 理由

- Round 03 的方向是对的：ledger 已把 GOV/AUD/CAS1-CAS3 覆盖到 Q17，这轮继续补 CAS4-CAS8 和 TRN1/4/5/6，覆盖面没有跑偏。
- 最大隐藏假设是“统一”不等于“压平”。R3-Q01/R3-Q04 如果写成单一 taxonomy，反而会重犯 generic frame 混层问题；正确 grill 应逼出 layer map、owner 和 trace fields。
- 第二个隐藏假设是“判定面变小就该重开 recipe”。这不成立。更强的问题不是重新调 LR/rank，而是确认 surface parity、data mix、held-out、IrrelAcc/refusal gates 是否防止 0/34 复发。
- 最有杠杆的是 R3-Q03/R3-Q05/R3-Q08：它们分别决定旧决策是否仍有效、推进事实源是否唯一、训练成功是否会被假提升污染。
- 最需要收窄的是 R3-Q09：C1/G3 方向已拍，继续问“是否这样做”价值低；应追问 generator/judge/data_recipe 如何物理执行、如何去污、如何证明 raw oracle 没进训练集。

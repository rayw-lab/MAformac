## 保留项

建议 9 题全部进入候选池，但不是全部原样保留：

| 候选 | 建议 |
|---|---|
| R3-Q01 | 保留，轻改写。它补的是 runtime tier 与 SRD 执行分层的物理统一，和已确认的 IR/surface/runtime 分离题不完全重复。 |
| R3-Q02 | 改写后保留。主题高杠杆，但题面需要强制落到 SRD、demo docs、C6 unsupported eval，而不是只讨论“现场怎么说”。 |
| R3-Q03 | 保留。逐决策 `keep/modify/superseded/defer` 是可验证输出，能防止 D1-D37 被 CLAUDE 摘要和 recovery amend 双重漂移。 |
| R3-Q04 | 保留。MASTER 是新 session 入口级文档，若不写清 IR/surface 两层，会继续把 device×action IR 误推成 generic surface。 |
| R3-Q05 | 改写后保留。新推进事实源问题必须问，但要避免变成“roadmap 文案偏好”，应要求 banner/supersede/import 规则。 |
| R3-Q06 | 必须改写后保留。它现在有“重开 recipe”的危险倾向；高价值版本应审计哪些配方项已锁，哪些只允许 G6-C 后再重开。 |
| R3-Q07 | 保留。held-out 切法是防死记核心，且旧 parent_overlap 已不足以覆盖 D-domain 具名工具 + 四类数据。 |
| R3-Q08 | 保留并轻改。它抓住阈值混淆风险，但必须明确区分“负样本占比”“IrrelAcc 指标阈值”“unsupported/safety refusal gate”。 |
| R3-Q09 | 改写后保留。方向已在 C1/G3 拍过，真正价值在物理落地：generator/judge 选型、样本预算、去污和 raw 红线 enforce。 |

## 删除项

无硬删除项。

最低分是 R3-Q06，但不建议删除。原因是训练配方是否被 surface 翻案误伤，是 A2/G6-C 后最容易走偏的点；只要把题面从“重开配方”改成“锁定项/可重开项/证据门”，它仍有保留价值。

## 合并项

不建议把本轮 9 题内部合并成更少题。它们看似都在做“级联”，但可验收落点不同：

| 关系 | 处理 |
|---|---|
| R3-Q01 与已确认 Q16/Q17 | 不合并。Q16/Q17管 IR/surface/runtime 与 L1/L2 边界；R3-Q01 管 SRD 执行兜底和 runtime tier 是否变成双源状态机。 |
| R3-Q03 与 R3-Q05 | 不合并。R3-Q03 产出 decisions status ledger；R3-Q05 产出 single-source-of-progress 规则。前者可作为后者输入。 |
| R3-Q04 与 R3-Q01 | 不合并。R3-Q04 落 MASTER 语义协议；R3-Q01 落 SRD/C4/C6/trace。合并会让验证面过大。 |
| R3-Q07/R3-Q08/R3-Q09 | 不合并。三者共同构成训练数据门，但分别落 split policy、metric gates、data generation mechanism。合并会掩盖具体验收字段。 |

## 改写建议

| 候选 | 建议改写 |
|---|---|
| R3-Q01 | 要求输出一个单一 `route_outcome/runtime_outcome` taxonomy，列出 enum、trace 字段、C4 路由断言、C6 case 分桶，并说明 SRD L1/L2/L3/L4 哪些保留为 routing/execution 概念、哪些映射到 runtime tier。 |
| R3-Q02 | 加一句：必须把导航/音乐/外卖 MCP 标成 Phase 2 out-of-scope，并给 SRD/demo docs/C6 unsupported cases 三处可验收修改点，防止只靠口头“现场不说”。 |
| R3-Q03 | 保持原 schema，但要求逐决策列 `decision_id / old_claim / status / evidence / cascade_files / blocking_if_unresolved`，否则 D1-D37 太宽。 |
| R3-Q04 | 把“避免未来再把 IR 推成 generic surface”改成可查的 forbidden wording 清单，例如禁止把 `device×action value` 写成 model-visible tool surface。 |
| R3-Q05 | 要求定义 `progress_ssot`、`historical_context`、`superseded_source` 三类文档状态，以及旧 roadmap 顶部 banner 模板和新 dispatch 引用规则。 |
| R3-Q06 | 改成：“基于 §16 已拍 `rank16Mainline` 守现状，哪些 recipe 字段被锁定为非变量？哪些指标异常才允许在 G6-C 后重开？”这样能防止把 surface/parity 问题甩给 LR/rank。 |
| R3-Q07 | 要求产出 `split_axis` 优先级和泄漏检查：family、value_form、utterance_template、semantic_parent、tool_name、scope_tier、data_class 分别如何参与 train/dev/held-out/OOD。 |
| R3-Q08 | 明确纠偏：`IrrelAcc>=20%` 这类说法可能混淆了 negative ratio 与 metric threshold。题面应要求分别定义 negative_mix_ratio、IrrelAcc、false_call_rate、unsupported_refusal_acc、safety_refusal_acc。 |
| R3-Q09 | 增加物理落点：`data_recipe.yaml`、`label_authority=contract`、`judge_family!=generator`、`raw_oracle_source=not_trainable`、duplicate/ambiguous gate、prompt contamination audit。 |

## 遗漏风险

- 本轮没有直接覆盖 TRN7/TRN8/TRN9：mlx-lm 本机训练可行性、端侧 mlx-swift parity/structured decoding、DoRA/复杂推理升级排期。ledger 已把这些列为后续缺口，不能被 R3-Q06/R3-Q09 顺手吞掉。
- R3-Q01 若只问 taxonomy，不要求 trace/C6 断言，会停留在命名统一，无法证明没有双源状态机。
- R3-Q02 若不落到 customer-facing demo SOP 或 demo docs，仍可能出现代码收窄、话术却暗示全集泛化的错位。
- R3-Q03/R3-Q05 都有“文档治理题过宽”的风险。需要输出表格化状态和 banner 规则，而不是泛泛说“更新相关文档”。
- R3-Q08 最大风险是把旧 “IrrelAcc≥20%” 混淆继续固化。好问题应该把这个错误暴露出来，而不是默认它正确。
- R3-Q09 若不要求 raw oracle enforcement，会把“原文不进训练集”降级成口号；必须有可机检字段或生成审计。

## 评分

| 候选 | 重要性 | 可验证性 | 非重复性 | 主线决策杠杆 | 风险揭示 | 总分 | 建议 |
|---|---:|---:|---:|---:|---:|---:|---|
| R3-Q01 | 5 | 5 | 4 | 5 | 5 | 24/25 | keep/rewrite |
| R3-Q02 | 5 | 4 | 4 | 5 | 4 | 22/25 | rewrite |
| R3-Q03 | 5 | 5 | 4 | 5 | 5 | 24/25 | keep |
| R3-Q04 | 5 | 4 | 4 | 5 | 4 | 22/25 | keep/rewrite |
| R3-Q05 | 5 | 4 | 3 | 5 | 4 | 21/25 | rewrite |
| R3-Q06 | 4 | 4 | 3 | 4 | 4 | 19/25 | rewrite |
| R3-Q07 | 5 | 5 | 5 | 5 | 5 | 25/25 | keep |
| R3-Q08 | 5 | 5 | 4 | 5 | 5 | 24/25 | keep/rewrite |
| R3-Q09 | 5 | 4 | 4 | 5 | 5 | 23/25 | rewrite |

## 理由

R3-Q01 是本轮 CAS 里最关键的结构题之一。已有题覆盖 IR/surface/runtime 分离，但没有逼问 SRD L1/L2/L3/L4 与 runtime tier 是否产生两套 route state；它的验证面也足够清楚，可以落 trace 字段、C4 route case 和 C6 分桶。

R3-Q02 高价值在于阻断旧“全集泛化兜底”叙事复活。它的问题是当前措辞偏策略讨论，必须要求修改 SRD/demo docs/C6 unsupported 测例，才算 concrete and verifiable。

R3-Q03 很强，因为 D1-D37 是项目宪法层历史包袱。范式翻案后只更新 CLAUDE banner 不够，逐决策状态表能暴露“已锁决策实际已变”的治理风险。

R3-Q04 不应删除也不应并入 SRD 题。MASTER 是语义范式入口，未来 agent 最容易从这里把 value 四件套 IR 误读成 model-visible generic frame；它需要独立修。

R3-Q05 重要但有重复压力。它和 GOV2/CAS1/authority cascade 相邻，必须缩成 single-source-of-progress 规则、旧 roadmap banner 和 dispatch 引用规则，避免变成又一个大而散的文档清单题。

R3-Q06 当前质量一般，因为 §16 已经拍过守 `rank16Mainline`、不重开 recipe。保留它的理由不是重审 LR/rank，而是给训练团队一个证据门：只有 G6-C 证明 surface/parity/negative 都无解后，才允许把 recipe 重新变成变量。

R3-Q07 是满分题。D-domain 具名工具会天然诱发 tool-name/template 记忆，旧 parent_overlap 只挡一类泄漏；按 family/value_form/template/semantic_parent/tool_name/data_class 组合定义 split，直接决定 C5 是否可信。

R3-Q08 也很强。四类数据把 positive、unsupported、safety、followup 混进同一训练/eval 体系，如果继续用一个 IrrelAcc 或聚合 pass_rate，会重演“假提升”。题面应顺手纠正阈值术语混淆。

R3-Q09 的主题已经被 C1/G3 方向性拍过，所以不能再问“要不要云 generator”。它应该升级成落地审计题：谁生成、谁 judge、多少样本、怎么去污、怎么证明 raw oracle 没进入训练集。

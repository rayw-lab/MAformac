## 保留项

- R3-Q03：保留。D1-D37 supersede review 是级联债的核心，且 `keep|modify|superseded|defer` 输出枚举足够可审计。
- R3-Q04：保留但需小改。MASTER 的 IR / model-visible surface 两层关系是范式翻案后最容易再次混层的位置。
- R3-Q05：保留。当前 `roadmap`、C5 recovery、paradigm amend、A2 audit 并存，single-source-of-progress 规则是防 drift 的主线杠杆。
- R3-Q07：保留。D-domain 具名工具 + 四类数据后，旧 `parent_overlap` 已不足以证明非死记；这是训练可信度硬门。
- R3-Q09：保留但需小改。generator/judge/data redline 是可物理落地的问题，不能只停在“云多源 + 异源 judge”的口号。
- R3-Q01：保留但改写。问题抓住 SRD 分层执行与 runtime tier 混层风险，但必须先把 route、surface、execution outcome 三个轴分开。
- R3-Q02：保留但改写。10 族收窄是 customer-facing / demo-scope 决策，不能误写成能力层全盘缩水。
- R3-Q08：保留但改写。题目里 `IrrelAcc>=20%` 是旧混淆，正好应被 grill 纠正，而不是继续传播。
- R3-Q06：保留为改写项。原题有价值，但不能打开“surface 迁移失败就改 recipe”的逃生门。

## 删除项

无直接删除项。

R3-Q06 原始表述不建议原样进入最终清单，因为它太容易把已经收口的 `rank16Mainline` / LR 讨论重新变成超参争论；但其核心应改写为“recipe freeze rule + reopen trigger”。

## 合并项

不建议硬合并。

- R3-Q07、R3-Q08、R3-Q09 应在最终顺序中相邻，组成 TRN 数据可信度簇：split 设计 → refusal/IrrelAcc 门 → generator/judge 机制。
- R3-Q01 与已确认 Q16/Q17 有相邻关系，但不应合并：Q16 偏 IR/surface/runtime separation，Q17 偏 L1/L2 action boundary；R3-Q01 专门处理 execution fallback 与 runtime outcome taxonomy。
- R3-Q03 与 R3-Q05 都是级联治理，但不应合并：前者核 locked decisions，后者定 progress authority。

## 改写建议

- R3-Q01：改成“请分别定义 `route_tier`、`model_surface`、`execution_outcome/runtime_tier`，并给出 C4 route label、C6 expected outcome、trace schema 三处的唯一字段来源；禁止把 L1/L2/L3/L4 路由层直接复用为执行结果枚举。”
- R3-Q02：补 `scope_tier` 物理字段，例如 `demo_positive|unsupported|safety|followup|phase2_mcp`，并要求 SRD/demo docs 同时写明“10 族内自由说；族外提前沟通 + unsupported refusal；导航/音乐/外卖为 MCP 二期，不计 C5/C6 当前覆盖”。
- R3-Q04：补一句“MASTER 只升格 surface-layer 说明，不重写 value 四件套为具名工具本体”；输出应包含 IR authority、derived surface artifact、禁止 generic frame surface 的 banner 文案。
- R3-Q06：改成“哪些 recipe 项被冻结，哪些只有在 A2 parity + G6-C named-tool cell 失败后才允许重开？”明确 `rank16Mainline/LR` 默认守，优先重开 checkpoint cadence、surface parity、data mix，不先动 recipe。
- R3-Q08：把 `IrrelAcc>=20%` 改为“负样本占比、训练 refusal mix、IrrelAcc 通过阈值三者分离”。要求独立定义 `false_call_rate`、`unsupported_refusal_acc`、`safety_refusal_acc`、`positive_regression`，并写清阈值之间不能互相抵消。
- R3-Q09：增加成本/吞吐/人审预算字段，要求 `generator_model_id`、`judge_model_id`、`judge_family!=generator_family`、`label_authority=contract`、`raw_source_allowed=false`、`redaction_pass=true`、`ambiguous_duplicate_gate` 全部落到数据 recipe 或 validator。

## 遗漏风险

- 这轮 CAS 题仍未强制回答“这些改动到底走 OpenSpec MODIFY change、amend banner，还是 docs-only repair”。R3-Q03/R3-Q05 可覆盖一部分，但最终清单最好要求每题输出 carrier。
- TRN 题覆盖了 split/gate/generator，但如果最终裁剪时删掉 TRN2/TRN3，同源 enforce 和中途 C6 gate 会再次缺位；这两项是 0/34、0/23 防复发核心。
- R3-Q02 若不改写，会把“现场沟通 10 族”误读成“系统能力只剩 10 族”，从而破坏 capability layer 与 demo layer 的两层 scope。
- R3-Q08 的原始数字前提有污染风险：20% 是负样本比例或 refusal mix 口径，不是 IrrelAcc 阈值。这个错如果不在题面纠正，会制造新 drift。
- R3-Q09 没有显式问 human audit capacity；异源 judge 不是事实源，必须有人审抽样/高风险队列，否则只是把 self-preference 换成 cross-model preference。

## 评分

| 候选 | 重要性 | 可验证性 | 非重复性 | 主线决策杠杆 | 风险揭示 | 总分/25 | 建议 |
|---|---:|---:|---:|---:|---:|---:|---|
| R3-Q01 | 5 | 4 | 4 | 5 | 5 | 23 | rewrite |
| R3-Q02 | 5 | 4 | 5 | 5 | 4 | 23 | rewrite |
| R3-Q03 | 5 | 5 | 4 | 5 | 5 | 24 | keep |
| R3-Q04 | 5 | 4 | 5 | 5 | 5 | 24 | keep/rewrite |
| R3-Q05 | 5 | 5 | 4 | 5 | 5 | 24 | keep |
| R3-Q06 | 4 | 4 | 4 | 4 | 4 | 20 | rewrite |
| R3-Q07 | 5 | 5 | 4 | 5 | 5 | 24 | keep |
| R3-Q08 | 5 | 4 | 5 | 5 | 5 | 24 | rewrite |
| R3-Q09 | 5 | 5 | 4 | 5 | 5 | 24 | keep/rewrite |

## 理由

- R3-Q01 高价值在于防止三套枚举互相冒充：SRD route 层、model surface 层、runtime execution outcome 层必须各自有字段与 trace 证据。扣分点是题面“统一 taxonomy”可能被误做成拍平三轴。
- R3-Q02 高价值在于把 demo 约束写回 SRD 与 demo docs，避免“全集泛化兜底”旧话术复活。扣分点是需要显式标 scope，否则会误伤能力层。
- R3-Q03 是本轮最必要的 CAS 题之一。范式翻案后如果不逐 D 决策标状态，后续 agent 会继续引用旧 D16/D30/D35/D37/D14。
- R3-Q04 是防 frame-lock 的关键题。MASTER 原本是 IR/value 范式权威；新增 surface 层必须是派生说明，不应把具名工具反推成 IR。
- R3-Q05 杠杆很高，因为项目现在同时有旧 roadmap、C5 recovery、paradigm amend、A2 audit。没有 progress SSOT，任何实现派单都会读到不同“当前态”。
- R3-Q06 价值在防止误诊，但题面太宽。A2 已有“surface 迁移非配方问题”的强锚，最终题应要求 recipe freeze 条件，而不是重新讨论每个超参。
- R3-Q07 直接揭示假提升风险。D-domain tool name 本身可被记忆，split 只按 parent 已不够，必须按 family/value_form/template/tool/semantic parent 多轴设计。
- R3-Q08 是必须保留的纠错题。它能把 unsupported refusal、safety refusal、false call、positive regression 拆开，避免用一个 IrrelAcc 聚合数洗白。
- R3-Q09 物理落点强，覆盖 generator/judge/redline/distractor 的整条生产链。非重复性略扣，因为 P1-C Q13/Q14 已有很多拍板；最终应问“缺哪些 enforce 字段和预算”，而不是重拍“要不要云 generator”。

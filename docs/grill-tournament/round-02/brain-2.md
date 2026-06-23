## 保留项

- **R2-Q01 GOV3 cross-section enforce**：保留。它直接打中已发生的 §14 数字分叉，且现有 `scripts/cross_section_check.py` 只覆盖有限文档组和单一锚，问题足够具体、可验证。
- **R2-Q03 GOV5 Mastra 形态**：保留。它把 Mastra 限定到 C4/C6/C3 三个物理落点，避免泛泛“借鉴框架”，且能用既有 teardown 和 spec 字段验证。
- **R2-Q05 GOV8 OpenSpec change split**：保留。A2/codegen/C5/C6/B1/B2 是接下来是否返工的主依赖图，题目要求 observable boundary 和不可合并理由，杠杆最高。
- **R2-Q06 GOV9 ground-truth subagent policy**：保留但需收窄。范式翻案本身证明 ground-truth subagent 有必要，但题目必须防止把“强制派 subagent”扩大成无边界治理。
- **R2-Q08 CAS2 SRD FC 泛化重写**：保留。它抓住最危险的混层点：IR、model-visible surface、runtime tier 三者不能互相替代。
- **R2-Q09 CAS3 L1/L2 边界**：保留。它逼问 10 族下哪些动作走规则快路、哪些进 LoRA 慢路，并要求用 §14 分布而不是按族拍脑袋。

## 删除项

- 无直接删除项。
- 若最终名额不足，**R2-Q02** 是最可被压缩的题：Pi 三件套已在协作文档中有模板级采纳，当前题面若不改写，会变成“重复确认已采用什么”，主线决策杠杆偏低。

## 合并项

- **R2-Q07 CAS1 meta cascade inventory**：合并进 Round 01 已确认的 canonical Q07。它重要且可验证，但与 ledger 里“full-repo cascade must adjudicate hits, not bulk replace”高度重复。建议只吸收它的清单字段：`target_file / section / old_frame / new_frame / action(change|no-change|supersede) / gate / owner`，以及点名覆盖 `CLAUDE / SRD / baseline MASTER / integration-blueprint / roadmap / ADR / CONTEXT / openspec specs`。
- **R2-Q04 GOV7 Pocock 重新分诊** 与 **R2-Q05 GOV8 change split** 强相关，但不建议合并。前者决定阶段和禁抢跑项，后者决定 OpenSpec 物理切刀；合并会让题目过大。
- **R2-Q02 GOV4 Pi 长任务规范** 与 **R2-Q06 GOV9 ground-truth subagent policy** 都是治理题，但不建议硬合并。一个管长任务交接和验收门，一个管重大范式决策的证据来源，风险模型不同。

## 改写建议

- **R2-Q01**：补上现有门的基线事实，要求回答“是否扩 `BASELINE_GLOBS`、是否新增 `ANCHOR_KEYWORDS`、哪些 anchor 只查一致性不查 correctness”。避免把 cross-section 写成万能事实校验器。
- **R2-Q02**：改成“现有 collaboration §4.5 已模板级 adopt Pi 三件套；C5 recovery 还缺哪一层物理执行？是补 handoff 模板、dispatch schema，还是 make verify gate？哪些 Pi 形态仍明确 drop？”这样才不是重复问已拍事项。
- **R2-Q03**：加一句“只借契约形态，明确 drop Mastra TS/Node runtime 与自由 agent loop”。否则容易被误读成引入框架。
- **R2-Q04**：要求输出矩阵：`mainline / current_stage / should_reset_to / evidence / exit_condition / forbidden_race / openspec_carrier`。否则“现在是不是 S5”会停留在流程标签争论。
- **R2-Q05**：补问 active change 处理：`run-lora-candidate-training` 是 amend、supersede、archive 后另起，还是拆出 successor changes？这是可执行切刀的关键。
- **R2-Q06**：补三条限制：触发条件必须高门槛；subagent 输出是 evidence pack 不是 authority；raw/PII/客户资料红线必须写进输出 schema。
- **R2-Q07**：不作为新题保留；并入 canonical Q07 时保留“输出 matrix 而不是立刻编辑”的约束。
- **R2-Q08**：要求改写结果必须标注三层术语：`canonical_ir`、`model_visible_surface`、`runtime_tier`，并列出 SRD 中哪些旧句应 `MODIFY`、哪些保留。
- **R2-Q09**：要求输出 action-level 而非 family-level 表：`family / action_or_value_type / fc_flags_basis / route_tier / rule_reason / lora_reason / demo_latency_reason / eval_gate`。

## 遗漏风险

- 这 9 题整体偏 GOV/CAS，合理符合 Round 02 focus，但对 **B1 端侧 JSON 防御解析/白名单** 和 **B2 state-cells 扩 10 族** 的执行前置只在 R2-Q05 中被带过，仍可能被 change split 讨论稀释。
- R2-Q01 只说数字/术语锚还不够，应显式覆盖 `tool_call_frame`、`set_cabin_*`、`B-frame/generic frame`、`534=intent not tool count` 这类会污染派单的 frame anchor。
- R2-Q06 若不加“ground-truth subagent 也必须 cite-verify”的限制，会把上一轮成功经验神化成新权威，反而复发“二手摘要当事实”。
- R2-Q08/R2-Q09 都围绕 SRD，但缺一个明确验收门：SRD 改完后 C4/C5/C6 哪些 spec 或 generated artifact 必须同步变化，否则会出现文档正确、训练/评测仍旧 surface 的假收口。
- R2-Q02 没有区分 session handoff、dispatch gate、tool hook 三种治理落点的成本层级；这会把 demo 轻治理推向流程堆叠。

## 评分

| Candidate | Importance | Verifiability | Non-duplication | Mainline decision leverage | Risk revelation | Total /25 | Recommendation |
|---|---:|---:|---:|---:|---:|---:|---|
| R2-Q01 | 5 | 5 | 4 | 4 | 5 | 23 | keep |
| R2-Q02 | 4 | 4 | 3 | 3 | 4 | 18 | rewrite |
| R2-Q03 | 4 | 5 | 5 | 4 | 4 | 22 | keep |
| R2-Q04 | 4 | 4 | 4 | 4 | 4 | 20 | rewrite |
| R2-Q05 | 5 | 5 | 4 | 5 | 5 | 24 | keep |
| R2-Q06 | 5 | 4 | 4 | 5 | 5 | 23 | keep/rewrite |
| R2-Q07 | 5 | 5 | 1 | 5 | 5 | 21 | merge |
| R2-Q08 | 5 | 5 | 5 | 5 | 5 | 25 | keep |
| R2-Q09 | 5 | 5 | 4 | 5 | 5 | 24 | keep |

## 理由

- **最高优先**：R2-Q08、R2-Q09、R2-Q05。它们分别卡住 SRD frame、runtime/train route boundary、OpenSpec 物理切刀，都是 A2 派单前不澄清就会返工的点。
- **强保留**：R2-Q01、R2-Q06、R2-Q03。它们分别补 mechanical drift gate、ground-truth evidence policy、C4/C6/C3 contract shape，风险揭示强，但需要防过度治理和框架误引入。
- **需改写**：R2-Q02、R2-Q04。两题方向对，但原题容易停在“采用哪个流程标签/模板”的层面，必须强制落到 schema、handoff、gate、exit condition。
- **应合并**：R2-Q07。它不是坏题，恰恰是重要题；问题是 Round 01 已确认同一 canonical 问题。保留它的文件覆盖清单和 matrix 要求即可，不应再占一个新题名额。

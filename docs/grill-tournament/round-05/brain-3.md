## 保留项

- **R5-Q02**：保留。它把 demo-golden-run 从“好看的五幕脚本”压成 `step_id / visual cue / expected state delta / readback / TTS / must-pass` 合同，主线杠杆最高。
- **R5-Q04**：保留并小改。B1 parser/whitelist 是端侧真实落地缺口，不应被 R4 的 endpoint parity 问题吸收掉。
- **R5-Q06**：保留。F1 是安全边界的结构性问题，能防止把安全动作误做成模型可选工具。
- **R5-Q07**：保留并小改。G6 场景宏会直接影响复杂推理短期边界，且能验证“宏不能引未挂载工具/未建 state cell”。
- **R5-Q09**：保留。最终验收分层是防止 train-health / candidate / golden / V-PASS 互相冒充的最后一道门。
- **R5-Q01**：保留但必须收窄。语音 UI 是 UIX7 原始空缺，但候选把交互控件、反馈、状态机和多模态 handoff 都塞在一起，需改成 MVP 范围裁决。
- **R5-Q03**：保留但必须改写。UIX9 未被前轮完整覆盖；组件 adoption + 真实查看环境验收值得留，但现在问题过宽。

## 删除项

- **R5-Q08 不建议作为独立 canonical grill question 保留**。它问的是“5 轮之后如何排序”，更像 final judge synthesis / closeout 操作，而不是一个新的设计决策。内容不要丢，应转成最终汇总动作：输出 A2 派单前 blocker stack、parallel stack、deferred stack，并明确 A2 第一刀禁止夹带 UI/SOP/训练升级。

## 合并项

- **R5-Q05 合并进既有 Q31**。Q31 已确认“mock cards must be backed by state-cells/tool-card mapping”；R5-Q05 的价值是把它 sharpen 成 10 族 state-cells 扩展、`tool -> IR -> state_cell -> card -> patch` artifact、以及“工具识别对但状态不变”负例验收。建议不占新名额，作为 Q31 的 rewrite payload。
- **R5-Q08 合并进 Q12/Q13/Q03 的最终排序视角**。Q12 已管 phase reset，Q13 已管 change split/dependency graph，Q03 已管 OpenSpec carrier。R5-Q08 应作为 final dedupe/merge 产物，不作为第 36-41 个问题之一。
- **R5-Q03 与 Q32/Q33/Q34 共享证据门，但不完全合并**。Q32 管 visual stance，Q33 管工程硬 preflight，Q34 管 onsite SOP；R5-Q03 独有“第三方组件 adoption + 授权/依赖/性能/真实查看环境”裁决，因此建议保留为 UIX9，但复用这些 gate。

## 改写建议

- **R5-Q01**：改成“UIX7 voice UI MVP 是否只保留 push-to-talk + button barge-in + four-state orb + minimal volume/earcon feedback？请定义 `VoiceInteractionState`、trace/golden 绑定、acceptance sample、non-goals；多模态 handoff 若无状态读回证据则标 deferred。”
- **R5-Q02**：补 `contract_refs`、`c6_case_id_derived`、`offline_assertion_method`、`network-off proof`。问题要防止“视觉 choreo 通过”冒充 C6/golden 合同通过。
- **R5-Q03**：拆出 adoption gate：license allow/deny、dependency boundary、perf budget、aesthetic 5 Gate、Mac/iPhone/projector real-view evidence。禁止只交高清导出图。
- **R5-Q04**：删除“端侧没有已证 GBNF 时”的假设口吻，改成已知前提：mlx-swift 主线按 LoRA 格式 + JSON 三层防御解析 + mounted whitelist。要求 `parser_failure_enum`、`whitelist_source`、unknown tool policy、`tool_not_in_whitelist=0` smoke artifact。
- **R5-Q05**：若独立保留，标题应改为“B2 state-cells expansion + tool-card artifact”，避免重复 UI mock-card 视觉问题。必须要求 10 族 cell schema、readback assertion、recognized-tool/no-state-delta fail case。
- **R5-Q06**：强化“安全不进 model-visible tool set”。要求 `risk-policy.yaml` / DemoGuard 独立代码门，LoRA 只学 `toolCalls=[]`、`safety_refusal` 话术和 `risk_rule_ids`，C6 safety eval 与 refusal data 分母分开。
- **R5-Q07**：补宏禁线：`allowed_tools` 必须来自 mounted whitelist，`required_state_cells` 必须已建；未满足标 `planned_not_golden`。升级到 LoRA 学推理的触发条件必须是 golden/fuzz/safety 分层已稳定后，而不是想做就做。
- **R5-Q08**：改为 final synthesis 指令，不计独立问题：“基于 Q01-Q41 输出 A2 pre-dispatch ordered blocker stack / parallelizable stack / deferred stack，并给每项 owner artifact 与禁止混入 A2 第一刀的范围。”
- **R5-Q09**：保留题面，但加 “closeout wording templates”。每层必须有证据字段、禁止晋级规则、blocked wording；尤其 train-health 不得写成 model-quality，demo-golden-run 不得写成 endpoint candidate。

## 遗漏风险

- 最大 frame risk：Round 05 候选都“看起来重要”，但 ledger 明确最终只保留 41 个 effective questions；如果不主动合并 R5-Q05/R5-Q08，会把 final list 挤爆。
- B1/B2 问题必须继续避开“534=工具数”的旧坑。A2 口径锚是 191 device / 534 intent / 工具数待实算；任何题面把 534 写成 mounted tool count 都会污染派单。
- UIX 题普遍缺“验收环境定义”：Mac 型号、iPhone 型号、投影距离/分辨率、现场光照、录屏/截图路径。R5-Q03 提到了真实截图，但还没把环境字段合同化。
- R5-Q02 与 R5-Q09 都碰 golden/final acceptance，风险是把 choreography、C6 case、human V/S/U-PASS 混成一个 pass。必须要求分层证据，不能合成总分。
- R5-Q07 的隐藏风险是宏变成“第二套 planner”。宏只能是 deterministic fixture，不能绕过 A2 whitelist、B2 state-cell、F1 DemoGuard。
- R5-Q01 的隐藏风险是把 voice UI 做成装饰层。题面必须强制 trace/golden/state machine 绑定，否则四态 orb 和 earcons 很容易假绿。

## 评分

| Candidate | Importance | Verifiability | Non-duplication | Mainline decision leverage | Risk revelation | Total /25 | Recommendation |
|---|---:|---:|---:|---:|---:|---:|---|
| R5-Q01 | 4 | 4 | 4 | 3 | 3 | 18 | keep + rewrite |
| R5-Q02 | 5 | 5 | 4 | 5 | 5 | 24 | keep |
| R5-Q03 | 4 | 4 | 3 | 3 | 4 | 18 | keep + rewrite |
| R5-Q04 | 5 | 5 | 4 | 5 | 5 | 24 | keep |
| R5-Q05 | 5 | 5 | 2 | 4 | 5 | 21 | merge into Q31 + rewrite |
| R5-Q06 | 5 | 5 | 4 | 5 | 5 | 24 | keep |
| R5-Q07 | 4 | 5 | 4 | 4 | 5 | 22 | keep + rewrite |
| R5-Q08 | 5 | 4 | 2 | 5 | 4 | 20 | merge/delete standalone |
| R5-Q09 | 5 | 5 | 4 | 5 | 5 | 24 | keep |

## 理由

- Ledger 要求最终 41 个 effective questions，且评分维度就是 importance / verifiability / non-duplication / mainline leverage / risk revelation，因此本轮不能只按“重要”排序，必须主动 dedupe（`docs/grill-tournament/ledger.md:5-9`）。
- Ledger 已确认 Q30-Q35 覆盖 UIX1-UIX6，剩余明确是 UIX7-UIX9 与 B1/B2/F1/G6 runtime landing gaps，所以 R5-Q01/Q02/Q03/Q04/Q06/Q07 的来源正当；R5-Q05 则与 Q31 重叠，需要合并而非重复占位（`docs/grill-tournament/ledger.md:44-49`, `docs/grill-tournament/ledger.md:70-79`）。
- 范式权威已经锁成 IR / model-visible D-domain surface / runtime tier 三层，且 demo 现场只说 10 族；好的 grill question 必须落到这三层的 artifact，而不是泛泛问体验或愿景（`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:21-27`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:50-53`）。
- B1/B2/F1/G6 在 amend §16 已有物理落点：parser+whitelist、tool-card-map、risk-policy/DemoGuard、scenario-macros。候选若不能继续要求这些字段和负例，就不够尖锐；R5-Q04/Q06/Q07 达标，R5-Q05 达标但应并入 Q31（`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:368-394`）。
- A2 是重型重构且有固定依赖序；R5-Q08 的价值是排序收口，但它不是新的设计问题。它应服务于最终派单前 blocker stack，而不是扩大 canonical question 数量（`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:409-412`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:424-429`）。

## 保留项

- **R5-Q02**：保留。它把 UIX8 从“炸场想法”压成 `step_id / visual cue / expected state delta / readback/TTS / must-pass`，可直接对齐 `golden_demo` 与 `demo-golden-run` 合同。
- **R5-Q04**：保留。它正好抓住 B1 在端侧无已证 GBNF 后的真实落点：格式训练、三层解析、挂载白名单、失败枚举、endpoint smoke。
- **R5-Q06**：保留但轻改。安全边界是高风险主线题，必须防止 D-domain 后把安全动作误挂成“模型可选工具”。
- **R5-Q07**：保留但轻改。场景宏是复杂推理的短期替代层，问题质量高，因为它要求宏只调用已挂载工具和已建 state cell。
- **R5-Q09**：保留。它是最终 false-green 防线，能把 train-health、model-quality、endpoint candidate、golden demo、V/S/U-PASS 分开。
- **R5-Q01**：保留但改写。UIX7 未被前 35 个 confirmed question 覆盖；但原题列项太多，需压成“语音状态机 + 中断语义 + 验收证据”。
- **R5-Q03**：保留但改写。UIX9 的真实价值是“adopt 组件不得用高清 mock 图假绿”，但原题混了组件选型、授权、性能、现场验收，需改成 adoption gate。
- **R5-Q08**：保留为最终排序题，但必须显式避免重复 Q12/Q13。它不是再问 phase/change split，而是给 A2 派单前的 ordered blocker stack。

## 删除项

- 无纯删除项。
- **R5-Q05 不建议以原题单独保留**：它的重要性很高，但已被 confirmed Q31（mock cards backed by state-cells/tool-card mapping）覆盖核心意图。应删除 standalone 形态，改为合并增强 Q31/B2。

## 合并项

- **R5-Q05 → 合并进 confirmed Q31 / B2 landing**。合并后 canonical 问法应要求：`state-cells.yaml` 从当前 4 族扩到 10 族，并生成 `tool -> IR -> state_cell -> card -> patch` 的同源 artifact；验收必须读回 state delta，防止“工具识别对但端态不变”。
- **R5-Q08 与 Q12/Q13 只做引用合并，不做内容合并**。Q12/Q13 已覆盖 phase reset 和 change split；R5-Q08 应作为最终派单排序题，输出哪些是 A2 第一刀 blocker、哪些并行、哪些后置。
- **R5-Q02 不应并入 R5-Q09**。前者是 demo choreography / UI step contract，后者是全局 acceptance ladder；合并会把视觉节奏问题淹没在 closeout 口径里。

## 改写建议

| Candidate | 建议 |
|---|---|
| R5-Q01 | 改成：语音 UI MVP 是否只包含 push-to-talk、barge-in、orb 四态、earcon/音量反馈、clarifyTag re-prompt 中的哪些最小集？请定义语音状态机、每个状态绑定的 trace event、barge-in 具体取消 ASR/LLM/TTS 哪些环节、3 个离线验收样例和明确不做项。 |
| R5-Q03 | 改成：adopt 组件必须过一张 adoption gate 表：组件名、用途、license、离线/端侧依赖、性能预算、审美 5 Gate、Mac/iPhone/投影真实查看证据、失败回退。没有真实查看证据不得算 UIX9 pass。 |
| R5-Q05 | 不单列；并入 Q31 后改为 B2 hardening：state-cells 4→10 族、tool-card-map artifact、readback test、unknown tool/device 不得静默吞。 |
| R5-Q06 | 改成 safety invariant 问法：D-domain 后 safety 是否永远是 `risk-policy/DemoGuard` 独立代码门，而不是 mounted model tool？请定义 risk ids、LoRA safety_refusal 数据边界、C6 safety eval、以及禁止把 refusal pass 冒充 action pass 的 closeout 规则。 |
| R5-Q07 | 改成 macro contract 问法：首批 deterministic scene macros 只允许引用 demo10 mounted tools 与 existing state cells；宏 schema 必含 `allowed_tools / required_state_cells / planned_not_golden / readback_template / upgrade_trigger`。 |
| R5-Q08 | 改成最终排序问法：基于前 5 轮 confirmed questions，输出 A2 派单前 blocker stack（must-before-codegen / can-parallel / after-A2 / demo-SOP-only），并说明每项若缺失会造成的具体返工或假绿。 |

## 遗漏风险

- **R5-Q01 漏中断所有权**：barge-in 不是按钮外观问题，必须问清它取消的是 ASR capture、LLM decode、TTS playback 还是全部，否则语音 UI 仍可能只是装饰。
- **R5-Q02 漏“golden 不能冒充 fuzz/safety/unsupported”**：候选已提 must-pass，但还应要求 golden_demo 与 demo_fuzz、unsupported、safety 四层分开，避免剧本跑通冒充真实稳态。
- **R5-Q03 漏 license/offline 污染**：组件 adoption 不只是审美，必须防 GPL/网络依赖/二进制体积/端侧不可跑。
- **R5-Q04 漏 parser fuzz**：endpoint smoke 之外，应要求 malformed JSON、unknown tool、unknown arg、think leak、多 tool call 等 parser negative cases。
- **R5-Q05 漏 silent default**：B2 需要防 unknown tool/device 被 default `return []` 静默吞掉，否则读回验收会假绿。
- **R5-Q08 漏 OpenSpec carrier**：A2 blocker ordering 里必须包含“正式 change / dispatch carrier 何时建立”，否则排序题会退化成口头清单。
- **R5-Q09 漏 human pass owner**：V/S/U-PASS 不是机器指标，应明确哪些证据由机器 gate 给出，哪些只能由磊哥现场判断签发。

## 评分

| Candidate | 重要性 | 可验证性 | 非重复性 | 主线决策杠杆 | 风险揭示 | Total /25 | 建议 |
|---|---:|---:|---:|---:|---:|---:|---|
| R5-Q01 | 4 | 4 | 5 | 4 | 4 | 21 | Keep + Rewrite |
| R5-Q02 | 5 | 5 | 4 | 4 | 5 | 23 | Keep |
| R5-Q03 | 4 | 5 | 4 | 3 | 5 | 21 | Keep + Rewrite |
| R5-Q04 | 5 | 5 | 4 | 5 | 5 | 24 | Keep |
| R5-Q05 | 5 | 5 | 2 | 5 | 5 | 22 | Merge |
| R5-Q06 | 5 | 5 | 4 | 5 | 5 | 24 | Keep + Rewrite |
| R5-Q07 | 4 | 5 | 5 | 4 | 5 | 23 | Keep + Rewrite |
| R5-Q08 | 5 | 4 | 3 | 5 | 4 | 21 | Keep + Rewrite |
| R5-Q09 | 5 | 5 | 4 | 5 | 5 | 24 | Keep |

## 理由

- **最高杠杆是 R5-Q04/R5-Q06/R5-Q09**：三者分别挡 endpoint parser 假绿、安全工具化、最终验收冒充，是 A2/G6-C/demo closeout 最容易出灾难的层。
- **R5-Q02/R5-Q07 值得保留**：它们把“炸场”和“复杂推理”从愿景拉回 contract，可用 schema、step、state delta、mounted tool/cell 直接验。
- **R5-Q01/R5-Q03 分数低一点不是不重要，而是原题列项式过宽**：必须收束成状态机/adoption gate，否则 grill 容易变成审美偏好讨论。
- **R5-Q05 高分但合并**：它比 confirmed Q31 更具体，但非重复性低。最佳处理是升级 Q31，而不是再占一个 final slot。
- **R5-Q08 必须保留为收束题**：前 5 轮已经产生大量高质量问题，最后需要一个排序问题把 A2 第一刀从 UI/SOP/训练升级里剥离出来；但它要明确只排序，不重开 Q12/Q13 的 phase/change split。

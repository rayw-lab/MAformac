## 保留项

| 候选 | 建议 | 保留理由 |
|---|---|---|
| R1-Q01 | keep | 这是 A2 派单前的第一道口径门。它直接打掉「534=intent 被误当工具数」的高危混淆，并要求 intent/tool/device 三个字段不可混用。 |
| R1-Q02 | keep | drift gate 是机械防线，不是文档意见。问题能直接落到 `Makefile`、`GENERATED_CONTRACTS`、生成物清单和 diff gate，风险揭示强。 |
| R1-Q04 | keep | demo/full 两层 codegen 是 A2 的核心结构问题。它能逼出字段边界、同源字段、深派生字段和验证方式，避免两套 SSOT。 |
| R1-Q05 | keep | train/eval/runtime surface 同源是 0/34 的复发防线。问题要求 fail-closed gate，而不是「大家记得同源」，杠杆很高。 |
| R1-Q06 | keep, absorb R1-Q09 | 训练中途 C6 gate 比 R1-Q09 更具体。保留它作为防灾难主问题，并把流程检查点并入。 |
| R1-Q07 | keep | 全仓级联清单是必要的 meta-grill。它要求 grep 命中逐个裁决，能防止旧 frame/旧数字在文档和代码里继续污染。 |

## 删除项

无硬删除项。

但 R1-Q09 不应独立原样保留。它现在有一半是在问「要不要引入 Superpowers gate」，容易滑成流程口号；若不能并入 R1-Q06 并落成具体训练 checkpoint、artifact 和 stop rule，就删除独立题位。

## 合并项

| 合并组 | 建议合并方式 | 理由 |
|---|---|---|
| R1-Q06 + R1-Q09 | 以 R1-Q06 为主问题，R1-Q09 的「模型问题、流程问题还是叠加」作为开场诊断，最后落到 50/100/150 checkpoint、抽样集、阈值、人工停机点、必须产出的 receipt。 | 两题都在防 0/34/0/23 重演。R1-Q06 具体，R1-Q09 泛；合并后更 sharp。 |
| R1-Q03 + R1-Q08 | 可合并成「governance/spec impact」一题：先判是否必须开 OpenSpec change，再逐核 archived C1/C3/C6 specs 是否因 observable behavior 改变而 MODIFY。 | 两题都问规范载体和 spec SSOT，只是一个问流程入口，一个问已 archive 影响。分开问会重复。 |
| R1-Q02 + R1-Q04 + R1-Q05 | 不建议压成单题；若必须缩短轮次，可作为「A2 mechanical gates bundle」连续问三小门：generated drift、demo/full 产物边界、train/eval/runtime parity。 | 三者共享 A2 codegen 主轴，但 failure mode 不同，强行合并会让回答泛化。 |

## 改写建议

| 候选 | 改写建议 |
|---|---|
| R1-Q01 | 增加输出 schema 要求：`mounted_tool_id` / `source_intent_id` / `device_id` / `value_form` / `runtime_scope` / `priority_source`。否则「实算工具数」仍可能被解释成 intent 数或 value-form 数。 |
| R1-Q02 | 要求回答列出「当前 drift gate 覆盖文件」和「A2 后必须新增的 generated artifacts」，并给出验证命令或 make target 名。 |
| R1-Q03 | 加切换门槛：observable behavior、spec Requirement/Scenario、eval/runtime contract 任一改变则 OpenSpec；仅证据、假设、历史解释留 amend。 |
| R1-Q04 | 要求给一张字段边界表：full-only、demo-only、shared、derived-from-IR、derived-from-value-form、runtime-only。 |
| R1-Q05 | 把「至少一个 gate」改成 gate contract：输入文件、比较字段、失败条件、输出 receipt、接入 `make verify` 的位置。 |
| R1-Q06 | 明确最小抽样轴：golden trigger、action args、unsupported refusal、safety refusal 至少分开；不要只看 aggregate pass rate。 |
| R1-Q07 | 要求输出 adjudication matrix：`anchor` / `file` / `line` / `old_frame` / `decision(change|keep|supersede)` / `followup_gate`。 |
| R1-Q08 | 改成逐 spec 核：C1 semantic contract、C3 tool execution、C6 vehicle bench 各自列 Requirement/Scenario 是否 observable changed；不许因措辞变动重开。 |
| R1-Q09 | 并入 R1-Q06 后改写为：0/34 和 0/23 分别暴露了哪类缺门，每类缺门对应哪个训练前、中、后 checkpoint，而不是抽象问「是否引入流程」。 |

## 遗漏风险

| 风险 | 为什么是遗漏 |
|---|---|
| B1 endpoint decode / parser 防线 | 当前 9 题没有正面问端侧 `mlx-swift` structured decoding 是否可用、GBNF 假设是否被推翻、JSON 三层防御解析和 mounted whitelist 怎么验。A2 生成出工具不等于端侧能稳定吐和解析。 |
| B2 state-cells 4 族扩到 10 族 | codegen surface 改完后，如果 state cell 和 tool-card map 不扩，mock 执行和 UI 卡片仍会断。R1-Q04 提到字段边界，但没有点名执行态落点。 |
| C4 四层 C6 demo eval | R1-Q06 问中途抽样，但没有要求 golden/fuzz/unsupported/safety 四层独立门。旧 aggregate pass rate 已经证明会掩盖风险。 |
| F1 safety_refusal 数据和 risk-policy 独立性 | 候选没有单独问安全动作是否仍由 code risk gate 拦，而不是变成模型可选工具。这个缺口会把安全门再次污染到 tool surface。 |
| C1 generator/judge/label authority | 9 题偏 A2 和治理，少问语料生成本身：contract 定标签、generator/judge 异源、原文 oracle 不进训练集、negative 配比和去污。没有这个，TRN gate 只能发现错，不能防止错源。 |
| route tier 与 LoRA 范围 | R1-Q01 会定义 intent/tool/device，但没有强制区分 L1 rule、L2 fuzzy、unsupported/safety/followup scope_tier。工具数算对，不代表训练/运行挂载范围算对。 |

## 评分

| 候选 | 重要性 | 可验证性 | 不重复性 | 主线决策杠杆 | 风险揭示 | 总分 | 建议 |
|---|---:|---:|---:|---:|---:|---:|---|
| R1-Q01 | 5 | 5 | 4 | 5 | 5 | 24/25 | keep |
| R1-Q02 | 5 | 5 | 4 | 5 | 5 | 24/25 | keep |
| R1-Q03 | 5 | 3 | 4 | 5 | 4 | 21/25 | rewrite / merge with R1-Q08 |
| R1-Q04 | 5 | 5 | 4 | 5 | 5 | 24/25 | keep |
| R1-Q05 | 5 | 5 | 4 | 5 | 5 | 24/25 | keep |
| R1-Q06 | 5 | 4 | 3 | 5 | 5 | 22/25 | keep, merge R1-Q09 into it |
| R1-Q07 | 5 | 5 | 4 | 4 | 5 | 23/25 | keep |
| R1-Q08 | 4 | 4 | 3 | 5 | 4 | 20/25 | merge / rewrite with R1-Q03 |
| R1-Q09 | 4 | 3 | 2 | 4 | 4 | 17/25 | merge into R1-Q06; delete if left generic |

## 理由

整体判断：这 9 题的方向是对的，尤其 AUD 组的 Q01/Q02/Q04/Q05/Q07 都能落到文件、生成物、make gate 或 grep adjudication，适合 A2 派单前 grill。最强的一组不是「观点题」，而是能逼出物理落点的题：工具数口径、generated drift、双层 codegen、surface parity、全仓旧锚清债。

主要问题是后半组有重复和抽象化风险。R1-Q03/R1-Q08 都在问 spec/governance，应该合并成一个按 observable behavior 裁决的 OpenSpec 问题。R1-Q09 的价值不在「要不要 Superpowers」，而在把 0/34/0/23 的教训变成训练前、中、后强制 checkpoint；否则就是流程装饰。

我不会建议删除大部分题，因为当前主线确实处在 A2 派单地基期，这些问题都能揭露真实风险。但需要补上 B1/B2/C4/F1/C1 这些遗漏，否则 grill 会过度集中在 codegen 和治理，低估端侧解析、state-cell 执行态、安全门、语料源头这四个会让 A2 二次翻车的点。

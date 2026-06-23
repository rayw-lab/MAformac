## 保留项

- R1-Q01 保留，建议小改后作为第一题。它抓住 A2 派单前最危险的口径混用：`534=intent`、工具数未实算、device/tool/intent 不可互代。可验证性强，直接锚到 3990 contract、value-form、xlsx col O/第15列或替代优先级规则。
- R1-Q02 保留。`generated/` 是否进入 drift gate 是硬事实题，能用 `Makefile` 和 `GENERATED_CONTRACTS` 当场核，不会滑成观点讨论。
- R1-Q03 保留但要改写。治理载体是主线切刀问题，不解决会让 A2 重构继续堆 amend，后续 specs SSOT 失真；但原题需要更明确的 OpenSpec change 触发条件和 blocker 定义。
- R1-Q04 保留。demo/full 双层 codegen 是 A2 的真实结构性问题，能逼出字段边界、生成物名、同源 hash、scope filter，不应并到工具数题里。
- R1-Q05 保留，优先级最高之一。PR5 类 mismatch 的复发风险只靠文档约定挡不住，必须问出 fail-closed parity gate。
- R1-Q07 保留但要收窄扫描域。它能防范范式翻案后旧锚残留，但必须排除或单独标注 `Reports/` 这类历史 receipt 噪声，否则会变成不可执行的大 grep。
- R1-Q08 保留但要扩 scope。archived specs impact 是 OpenSpec SSOT 收敛题，应该用 observable behavior 判定；但只看 C1/C3/C6 可能漏掉 `lora-training`、`demo-experience` 等受 surface 变化影响的 specs。

## 删除项

- 无需删除任何议题的核心内容。
- 删除 R1-Q09 的独立题位：它的问题意识重要，但当前写法偏复盘/流程倡议，和 R1-Q06/GOV6/TRN3 高度重叠。内容应并入 R1-Q06，变成“训练中途 gate + 人工 checkpoint + Superpowers 验收绑定”的一题。

## 合并项

- 合并 R1-Q06 + R1-Q09：R1-Q06 是可执行技术 gate，R1-Q09 是流程防灾框架。单独问 R1-Q09 容易落成“应该更严谨”的空话；并入后要求每个 checkpoint 有抽样集、指标、阈值、停训条件、人工签点和 artifacts。
- 不合并 R1-Q01/R1-Q04/R1-Q05。三者分别问“数数口径”“两层生成物边界”“三处 surface 同源 gate”，看似都属 A2 codegen，但物理落点不同，合并会降低锋利度。
- 不合并 R1-Q03/R1-Q08。R1-Q03 是“从 amend 切到 OpenSpec change 的治理门槛”，R1-Q08 是“已 archived specs 是否需要 MODIFY”的影响核查；二者应顺序相邻，但不应混成一题。

## 改写建议

- R1-Q01：补一句“输出可复跑命令/脚本、输入文件、filter、group key、value-form key；若 xlsx col O 不可读，必须声明替代规则和置信度”。否则容易只给一个新数字。
- R1-Q02：改成“以 `Makefile` 中 `GENERATED_CONTRACTS` 与 `diff` target 为核验锚，列出 A2 新增/更新的每个 `generated/` 产物是否会被 regen-diff 捕获；未捕获即 blocker”。这样避免泛泛问“是否覆盖”。
- R1-Q03：改成“请给 A2 前置 OpenSpec 切刀规则：哪些改变 archived spec observable behavior 必须开 MODIFY change；哪些只是 recovery amend；哪些缺失会阻止 A2 派单；change 拆分和依赖序如何落”。把 GOV2 和 GOV8 一起钉住。
- R1-Q04：补“产物矩阵字段”。推荐要求输出 `artifact / scope / source_contract_digest / filter / shared_fields / demo_only_fields / full_only_fields / drift_gate`，否则“同源”会停留在口头。
- R1-Q05：改成“定义 `verify-tool-surface-parity`：训练样本 tool name、C6 expected tool calls、runtime mounted whitelist 都从 A2 目录派生；未知、缺失、额外、旧 `tool_call_frame` 均 fail closed，允许项必须显式声明为 unsupported/refusal”。这是抓 PR5 0/34 的最小机械门。
- R1-Q06 + R1-Q09 合并改写：`重训防灾 gate：在 checkpoint 50/100/150 跑最小 C6 抽样；分别测 trigger、tool exact/action_hard_pass、unsupported/refusal、安全门；给 early-stop/continue/human-checkpoint 阈值；Superpowers verification-before-completion 的验收 artifact 是什么；不得在 parity gate 未绿时把失败归因成“模型差”。`
- R1-Q07：补扫描范围和输出 schema：`scope=Core/Tools/scripts/contracts/generated/openspec/docs(c5/srd/baseline/handoffs)，Reports/raw 仅作历史 receipt 单独标注；输出 target_file/line/anchor/current_semantics/verdict(change|no_change|superseded|receipt_only)/owner_gate`。
- R1-Q08：改成逐 spec 决策表：`spec / affected SHALL or Scenario / observable behavior changed? / decision(no-change|MODIFY|new change) / evidence / blocked_by`。同时把 `lora-training` 纳入候选核查，不要只锁 C1/C3/C6。

## 遗漏风险

- B1 端侧受限解码/解析白名单没有独立题。即使 tool surface 同源，端侧如果只能靠松散 JSON parsing，也可能继续发生 mounted surface drift 或 tool_not_in_whitelist 漏洞。
- B2 state-cells 与 tool-to-card map 没被直接覆盖。D-domain 具名工具最终要落到 mock state/card patch；如果 10 族 state-cells 不扩，demo 仍会“识别对、执行不了”。
- C1/TRN6 自然中文数据生成与异源 judge 质量不足。当前 9 题重 gate、重治理，少问“训练数据是否仍是协议串/假自然中文”，这是 LoRA 假绿来源。
- TRN4 held-out 切法缺席。D-domain 具名工具后，按族、value 形态、utterance 模板的切分策略会决定 eval 是否只是记忆检测。
- Safety/refusal 的模型样本与代码安全门边界不够单列。安全动作不能变模型可选工具，必须保留 DemoGuard/risk-policy 为代码门，否则 surface 迁移可能把安全也工具化。
- CAS1 级联题需要处理历史 receipt 噪声。`Reports/` 里的旧 `tool_call_frame`、`set_cabin_*` 命中不一定要改；不设 scope 会把真实债务和历史证据混在一起。
- Q08 只点 C1/C3/C6 太窄。`lora-training` spec、demo experience/golden run、可能还有 SRD/baseline 文档都会受 “model-visible surface=D-domain 具名工具” 影响。

## 评分

| 候选 | 重要性 | 可验证性 | 非重复性 | 主线决策杠杆 | 风险揭示 | 总分 | 建议 |
|---|---:|---:|---:|---:|---:|---:|---|
| R1-Q01 AUD2/G2 tool-count口径 | 5 | 5 | 5 | 5 | 5 | 25 | keep/rewrite |
| R1-Q02 AUD1 generated drift gate | 5 | 5 | 5 | 4 | 5 | 24 | keep |
| R1-Q03 AUD3/GOV2 governance carrier | 5 | 3 | 4 | 5 | 4 | 21 | rewrite |
| R1-Q04 AUD4 demo/full 双层 codegen | 5 | 4 | 4 | 5 | 5 | 23 | keep/rewrite |
| R1-Q05 AUD5/TRN2 surface同源 enforce | 5 | 5 | 4 | 5 | 5 | 24 | keep/rewrite |
| R1-Q06 AUD5/GOV6/TRN3 训练中途 C6 gate | 5 | 4 | 3 | 5 | 5 | 22 | merge with R1-Q09 |
| R1-Q07 AUD6/CAS1 全仓级联清单 | 4 | 4 | 5 | 4 | 5 | 22 | keep/rewrite |
| R1-Q08 GOV1 archived specs impact | 5 | 4 | 4 | 5 | 4 | 22 | keep/rewrite |
| R1-Q09 GOV6 防灾难流程 | 4 | 3 | 2 | 4 | 4 | 17 | merge/delete standalone |

## 理由

这 9 题整体方向是对的：它们没有再纠缠“D-domain 是否成立”这种已拍范式，而是压到 A2 派单前真正会返工的口径、生成物、OpenSpec 载体、同源 gate、训练中途验收和级联清债。

最高价值题是 R1-Q01、R1-Q02、R1-Q05。它们都能落成机械检查：数数口径可复跑，`generated/` drift gate 可从 `Makefile` 核，train/eval/runtime surface parity 可用 fail-closed gate 拦 PR5 类事故。

最需要修的题是 R1-Q09。它的反方观点是：把“引入 Superpowers gate”写成问题，容易让人用流程名替代验收物。防灾难不是多一个仪式，而是 checkpoint 50/100/150 必须产出可审计的 C6 抽样结果、阈值判定、人工签点和停训规则。因此它应并入 R1-Q06。

最大遗漏不是“再多问一个治理问题”，而是 runtime landing：端侧受限解码、10 族 state-cells、tool→IR→card patch、自然中文数据质量和 held-out 切法。A2 如果只解决 tool surface 和文档 SSOT，仍可能出现“训练/eval 对齐但 demo 执行层断裂”的新假绿。

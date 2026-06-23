## 保留项

| Candidate | 建议 | 核心保留理由 |
|---|---|---|
| R5-Q02 | keep, 小改 | UIX8 是剩余缺口，且已要求 `step_id / visual cue / expected state delta / readback/TTS / must-pass`，可直接落到 `demo-golden-run` 合同。 |
| R5-Q03 | keep, 小改 | UIX9 抓住了 component adoption 最容易假绿的点：审美、性能、授权、真实观看环境，且“不接受高清 mock 图假绿”足够尖锐。 |
| R5-Q04 | keep | B1 是硬运行时落点，已对齐“mlx-swift 暂无 GBNF 后的端侧主线”：LoRA 格式、JSON 三层防御解析、挂载白名单、`tool_not_in_whitelist=0`。 |
| R5-Q06 | keep | F1 直击安全边界：安全不能变成模型可选工具，必须由 `risk-policy`/`DemoGuard` 独立代码门承担。 |
| R5-Q07 | keep, 小改 | G6 场景宏是复杂推理短期替代方案，问题已要求 schema、工具/cell 闭合、`planned_not_golden` 和升级触发条件，质量高。 |
| R5-Q08 | keep, 改成收口题 | A2 派单前 blocker ordering 是本轮最高杠杆题之一，可防止把 UI/SOP/训练升级混入 codegen 第一刀。 |
| R5-Q09 | keep, 小改 | Final acceptance ladder 是防假绿总闸，能把 train-health、model-quality、endpoint、demo、V/S/U-PASS 分层。 |

## 删除项

无硬删除项。

R5-Q01 不建议删除，但必须改窄。当前把 barge-in、push-to-talk、orb、earcons、音量反馈、clarify re-prompt、多模态 handoff 全塞进一问，容易变成 UI 功能清单投票。它应保留为“语音 UI 最小可验状态机”题。

R5-Q05 不建议作为全新 standalone 保留。它的核心已经被已确认 Q31 覆盖一半：mock cards 必须由 state-cells/tool-card mapping 支撑。R5-Q05 的价值是把 Q31 扩成 B2 硬落点，而不是重复占一个名额。

## 合并项

| Merge | 处理建议 |
|---|---|
| R5-Q05 -> Q31 | 合并为 “B2 state-cells 10 族扩展 + tool-card-map acceptance”。保留 R5-Q05 的 `tool -> IR -> state_cell -> card -> patch`、读回验收、防“工具识别对但状态不变”、UI/C6 共用 artifact。 |
| R5-Q02 + F3 demo-golden-run | 不直接合并删除。R5-Q02 管 UI 编排与每步视觉/readback；F3 管 golden contract 与 K_abs/硬门。两者应共享 `contracts/demo-golden-run.v1.yaml`，但分别保留视角。 |
| R5-Q07 + R5-Q02 | 不合并。宏是 deterministic reasoning substitute，golden-run 是 demo choreography。只要求 R5-Q02 引用 R5-Q07 的同一闭合规则：未挂载 tool / 未建 state cell 不得进入 golden。 |
| R5-Q08 + 已确认 Q12/Q13 | R5-Q08 应作为最终 ordering/dedupe 收口题，吸收 Q12 phase reset 与 Q13 change dependency，但不要再重复问 change split 的细节。 |
| R5-Q09 + closeout lessons | 保留为 final acceptance wording 题，吸收既有 train-health vs V-PASS 教训，输出最终 closeout 禁用词和允许词。 |

## 改写建议

| Candidate | 改写后更好的问题形态 |
|---|---|
| R5-Q01 | “UIX7 voice UI MVP 最小状态机是什么？请只在 `idle/listening/thinking/speaking/interrupted/clarifying/error` 等可 trace 状态中取舍，定义触发事件、trace 字段、readback/TTS 联动、验收样例和明确不做项；不得把语音 UI 只做成装饰动画。” |
| R5-Q02 | “UIX8 demo-golden-run UI 编排如何唯一锚到 `contracts/demo-golden-run.v1.yaml`？每个 step 必须给 `step_id/act_id/visual_cue/expected_state_delta/readback_tts/must_pass/c6_case_id_derived`，且未挂载工具或未建 state cell 的效果不得进入 golden。” |
| R5-Q03 | “UIX9 组件 adoption 必须通过哪几个硬门？请为 Orb/WhisperKit/第三方 UI 组件定义 license、binary size、latency/FPS、内存、审美 5 Gate、Mac/iPhone/投影真实截图证据和回退方案；高清 mock 图不能作为 pass 证据。” |
| R5-Q04 | 原题已足够尖锐。只建议补一句：parser failure enum 需区分 `decode_failed / schema_invalid / semantic_unknown_tool / tool_not_in_whitelist / unsafe_blocked / readback_mismatch`，避免所有失败都变 `unsupported`。 |
| R5-Q05 | “B2 在 Q31 基础上补全：state-cells 如何从 4 族扩到 MVP 10 族，并生成 `generated/tool-card-map.demo10.json`？验收必须证明每个 mounted tool 都能落到 state_cell/card/patch/readback，且识别正确但状态未变时 fail。” |
| R5-Q06 | “F1 safety boundary：D-domain 后哪些动作容易被误建成模型工具？请定义禁止模式、`risk-policy`/`DemoGuard` 独立代码门、LoRA safety_refusal 数据边界、C6 safety eval 轴和 final wording；不得把 safety action 作为可选 tool。” |
| R5-Q07 | “G6 scenario macro boundary：首批宏如何被选入，宏 schema 是什么，如何 lint `allowed_tools` 与 `required_state_cells` 全部已挂载？未闭合宏必须标 `planned_not_golden`；再定义何时从 deterministic macro 升级到 LoRA 学推理。” |
| R5-Q08 | “A2 dispatch blocker ordering：请输出 `block_A2_codegen / parallel_before_A2 / after_A2 / never_in_A2` 四栏，逐项给 blocker reason、required artifact、exit gate、owner 和禁止混入 A2 第一刀的内容。” |
| R5-Q09 | “Final acceptance ladder：请定义 `train-health T-PASS / G6-C diagnostic / C6 Mac model-quality / endpoint candidate / demo-golden-run / V-PASS / S-PASS / U-PASS` 的证据、命名、禁止冒充规则和 closeout 标准句式。” |

## 遗漏风险

- R5-Q01/R5-Q03 都偏 UI 体验，但不能绕开 UIX4 的“能跑硬前置”：麦克风权限、Info.plist、entitlements、OOM/jetsam、投影环境。如果最终题单没有 UIX4，则 UIX7-9 会被误读成美化题。
- R5-Q02 若只问五幕炸场，会漏掉 golden-run 的 SSOT 风险：UIUE 五幕、C6 must-pass、demo-scenarios 不能各写一份脚本。
- R5-Q04 仍需防一个隐藏假设：端侧没有 GBNF 不等于格式约束失败；问题要逼出 parser/whitelist/endpoint smoke，而不是重开“要不要换 runtime”。
- R5-Q05 最大风险不是“卡片不够漂亮”，而是识别对、readback/TTS 对、mock state 没变却被当 pass。评分与改写都应围绕 state delta。
- R5-Q06 必须禁止“安全具名工具”这个偷换。模型只能学拒识话术和 risk ids，动作拦截在代码门。
- R5-Q07 必须防宏成为新的隐藏全能规划器。宏只能调用已挂载工具和已建 state cell，不能因为“场景体验好”绕过 B1/B2。
- R5-Q08 需要明确 A2 第一刀边界，否则它会退化成“所有问题都重要”的排序作文。
- R5-Q09 需要把 V/S/U-PASS 与工程 T/V-PASS 分清：视觉通过、听感通过、战略通过不能替代 C6 model-quality 或 endpoint evidence。

## 评分

| Candidate | Importance | Verifiability | Non-duplication | Mainline leverage | Risk revelation | Total /25 | Recommendation |
|---|---:|---:|---:|---:|---:|---:|---|
| R5-Q01 | 4 | 4 | 4 | 3 | 4 | 19 | rewrite |
| R5-Q02 | 5 | 5 | 4 | 5 | 4 | 23 | keep |
| R5-Q03 | 4 | 5 | 5 | 3 | 5 | 22 | keep |
| R5-Q04 | 5 | 5 | 4 | 5 | 5 | 24 | keep |
| R5-Q05 | 5 | 5 | 2 | 5 | 5 | 22 | merge/rewrite |
| R5-Q06 | 5 | 5 | 5 | 5 | 5 | 25 | keep |
| R5-Q07 | 4 | 5 | 4 | 4 | 5 | 22 | keep/rewrite |
| R5-Q08 | 5 | 4 | 3 | 5 | 5 | 22 | keep/rewrite |
| R5-Q09 | 5 | 5 | 4 | 5 | 5 | 24 | keep |

## 理由

Round 05 的正当任务边界很清楚：ledger 已说明剩余缺口是 UIX7-UIX9、B1/B2/F1/G6、最终派单排序和最终 dedupe/merge（`docs/grill-tournament/ledger.md:73-79`）。所以评分重点不是“问题看起来重要”，而是它是否补剩余洞、是否不重复前 35 个 confirmed question。

B1/B2/F1/G6 是最硬的保留组。范式文档已经把 B1 修正为“端侧 mlx-swift 走 LoRA 格式 + JSON 三层防御解析 + 挂载白名单，GBNF 仅 fallback”（`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:370-381`）；B2 真前置是 state-cells 从 4 族扩 10 族，并生成 tool-card-map（同文件 `:371`、`:390`）；F1 明确安全不进模型可选工具（`:392`）；G6 明确宏不得引用未挂载工具或未建 cell（`:394`）。这些题都有强物理落点，分数高。

UIX7-9 是有效剩余 UIUE 缺口，但优先级不同。UIX8 直接绑定 golden-run 和 100% 硬门，杠杆最高；UIX9 有真实查看环境验收，能防视觉假绿；UIX7 需要改窄成语音 UI 状态机，否则会变成装饰组件投票。原始 UIX7-9 来源在范式文档中逐条列出（`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:343-345`）。

R5-Q08/R5-Q09 是收口题，不应被当普通 feature grill。项目已有明确教训：train-health 不能冒充 C6 model-quality 或 endpoint candidate（`docs/lessons-learned.md:34`、`:65`）。因此 R5-Q09 必保留；R5-Q08 则要输出 ordered blocker stack，防止 A2 第一刀被 UI/SOP/训练/验收层混淆。

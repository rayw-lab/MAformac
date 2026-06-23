## 保留项

- **R1-Q01** 保留。它直接卡住 A2 派单前最危险的口径错位：`534=intent`，不是工具数。题目已经要求从 3990 contract、value-form、col O/xlsx 第15列或替代规则实算，并要求拆开 intent/tool/device，足够尖锐。
- **R1-Q02** 保留。`generated/` 是否进 Makefile drift gate 是可用 `Makefile` 直接核的事实题，且是 A2 codegen 产物不漂移的前置。
- **R1-Q04** 保留但需小改写。demo/full 两层 codegen 是 A2 的结构性地基，问题抓得准；需要把 “demo=10族” 细化成 `191 device / 534 intent / 2086 rows` 与 “runtime mounted tool count 待 G2 实算” 的不同层。
- **R1-Q05** 保留。它是最能防 PR5 `0/34` 复发的题，必须落成机械 gate，而不是文档约定。
- **R1-Q07** 保留。全仓 cascade 不是清洁文档问题，而是防旧 frame、旧数字、旧 generated 旁路继续污染 A2 的必要审计。
- **R1-Q08** 条件保留。它的 “observable behavior 判断，不因措辞重开 spec” 是好约束，但最好和 R1-Q03 串成同一治理决策链。

## 删除项

- **无完整候选应直接删除**。
- **R1-Q09 不建议保留为独立题**。它的重要性不低，但现在太像流程口号，且与 R1-Q06/GOV6/TRN3 高度重叠。应删除其独立位置，把可验证部分并入 R1-Q06 的中途 checkpoint gate 与 sign-or-block 机制。

## 合并项

- **R1-Q06 + R1-Q09 合并**：R1-Q06 负责训练中途 C6 抽样的物理 gate；R1-Q09 只保留 “为什么 0/34 + 0/23 没被流程拦住、哪些 gate 进入 make verify/sign-or-block” 这部分。合并后避免一个问技术 gate、一个问流程归因，最后两边都不落地。
- **R1-Q03 + R1-Q08 合并或强排序**：先用 R1-Q08 做 archived specs impact matrix，再用 R1-Q03 决定哪些进 OpenSpec MODIFY/ADDED change、哪些留 recovery amend、哪些是 A2 派单 blocker。
- **R1-Q02 / R1-Q04 / R1-Q05 不合并，但要显式依赖**：R1-Q02 是生成物 drift gate，R1-Q04 是 demo/full 产物边界，R1-Q05 是 train/eval/runtime surface 同源。三者同属 A2 contract spine，但合并会让问题过宽。

## 改写建议

- **R1-Q01**：要求输出 `intent_id / value_form / proposed_tool_name / runtime_mounted / training_scope / device_scope` 的 derivation 表，并附实算命令或 raw xlsx 提取 receipt。否则 “实算” 仍可能退回手工估数。
- **R1-Q02**：把 “当前是否真的覆盖” 改成 “列出 Makefile 中 drift gate 的实际 path 集合，再列 A2 新增 generated 产物的必须纳入清单”。这样能防止只回答 yes/no。
- **R1-Q03**：增加物理输出：`change_id / touched_spec / amend_doc / blocker_before_dispatch / archive_exit_criteria`。否则 “amend vs OpenSpec” 容易变成治理偏好讨论。
- **R1-Q04**：明确 full/demo 都是从 3990 派生，区别是派生深度和消费面，不是两套 SSOT。题目应要求列 shared fields、demo-only fields、source hash、scope_tier、artifact path、diff gate。
- **R1-Q05**：要求命名一个 fail-closed gate，例如 `verify-tool-surface-parity`，输入至少包含训练 JSONL rendered tools、C6 expected tools、runtime rendered tools，输出必须是 set diff，不允许只比数量。
- **R1-Q06**：把 “测什么最小 C6 抽样” 具体化为 per-axis：trigger/tool-call-set/state-delta/IrrelAcc/readback-policy 是否纳入。阈值必须区分 early-stop、manual checkpoint、continue 三类。
- **R1-Q07**：要求每个 grep 命中输出 `file:line / stale_anchor / current_frame / verdict(change|keep|supersede|delete) / owner_gate`，并禁止批量替换。建议追加 `rendered_tools_text`、`D_domain.tools.json`、`10-family-device-boundary`、`534具名工具` 等锚点。
- **R1-Q08**：加入 `lora-training` spec 的显式纳入或排除理由。D-domain surface 对 C5 影响很大，只问 C1/C3/C6 可能漏掉已 archive 的 C5 行为契约。
- **R1-Q09**：改成 “列出 0/34 和 0/23 分别是哪三个未被机械 gate 捕获的 failure mode，并把每个 failure mode 落到一个 checkpoint、一个命令、一个阻断条件”。去掉泛化的 “模型问题还是流程问题” 开场。

## 遗漏风险

- **state-cells / tool-card-map 未被单独 grill**：A2 不只是工具名目录，10 族工具必须落到 IR、state_cell、card patch。否则 surface 同源过了，mock state 仍不能闭环。
- **端侧 decode / 格式 parity 缺题**：受限解码、mlx-swift 端侧输出格式、训练渲染和 endpoint render bytes 是否一致，是 D-domain 能不能跑上设备的风险，不应只放在后续 C5 parity 里。
- **自然中文训练数据防假绿缺题**：当前 9 题管 surface、gate、governance 多，缺少 “协议风格 device=... 训练文本必须换成自然中文、label 由 contract 定而非 generator 定” 的直接 grill。
- **C6 axis 口径缺题**：R1-Q06 提到 C6 抽样，但没有强制 readback 方案P、action hard_pass without_readback、相对 base 10/23、不合并 pass_rate 这些口径。
- **sign-or-block 语义复算缺题**：R1-Q09 提 Superpowers，但没有要求固定语义检查集、异源 receipt 绑定语义维度、缺任一项 UNSIGNED/BLOCKED。

## 评分

| 候选 | 重要性 | 可验证性 | 非重复性 | 主线决策杠杆 | 风险揭示 | 总分/25 | 建议 |
|---|---:|---:|---:|---:|---:|---:|---|
| R1-Q01 | 5 | 4 | 5 | 5 | 5 | 24 | keep |
| R1-Q02 | 5 | 5 | 4 | 5 | 5 | 24 | keep |
| R1-Q03 | 4 | 3 | 3 | 5 | 4 | 19 | merge/rewrite |
| R1-Q04 | 5 | 4 | 4 | 5 | 5 | 23 | keep/rewrite |
| R1-Q05 | 5 | 5 | 4 | 5 | 5 | 24 | keep |
| R1-Q06 | 5 | 4 | 3 | 5 | 5 | 22 | merge/rewrite |
| R1-Q07 | 5 | 5 | 4 | 4 | 5 | 23 | keep/rewrite |
| R1-Q08 | 4 | 4 | 3 | 5 | 4 | 20 | merge/rewrite |
| R1-Q09 | 4 | 2 | 2 | 3 | 4 | 15 | merge/delete-standalone |

## 理由

高分题的共同点是有物理落点：具体文件、字段、命令、生成物、gate、axis 或 grep anchor。R1-Q01/R1-Q02/R1-Q05 是第一梯队，因为它们分别防止口径错、生成物漂移、train/eval/runtime surface 异源，都是 A2 派单前会直接造成返工或复发 `0/34` 的问题。

R1-Q03/R1-Q08 重要但偏治理，单独问容易流成 “该不该走 OpenSpec” 的偏好讨论；它们必须被改写成 specs impact matrix + change split。R1-Q06/R1-Q09 也同理：训练中途 gate 是实题，Superpowers/process 是载体，不能让载体盖过阻断条件本身。

这一轮最该警惕的 frame-lock 是：大家都围着 “工具 surface” 追，但 A2 真风险还包括 state-cell 落地、端侧 decode、自然中文数据和 C6 axis 口径。只把 9 题答完，不等于 A2 派单安全。

## 保留项

- **R2-Q01 GOV3**：保留。它把已发生的数字分叉转成 `verify-cross-section` 可执行扩展，且要求文档组、锚点、SUPERSEDED、false-positive 规则，质量高。
- **R2-Q03 GOV5**：保留。Mastra 不是泛泛借鉴，而是被压到 C4/C6/C3 三个可落文件/字段，能逼出 contract shape。
- **R2-Q04 GOV7**：保留。范式翻案后阶段重分诊是主线节奏问题，能阻止 A2/G6-C/CAS 抢跑。
- **R2-Q05 GOV8**：保留。OpenSpec change split 是 A2 重构前的切刀问题，直接决定长跑是否返工。
- **R2-Q06 GOV9**：保留但小改。ground-truth subagent policy 是本轮翻案的元教训，题面已有触发条件、输出要求、cite-verify 和写回位置。
- **R2-Q08 CAS2**：保留。它精准打到 SRD 中最容易混层的「FC 泛化」表述，且要求区分 IR / model-visible surface / runtime tier。
- **R2-Q09 CAS3**：强保留。它要求按 `fc_flags` / `value.type` / demo 5 分钟目标定义 L1/L2 边界，避免按设备族粗暴切分。

## 删除项

- **无纯删除项**。
- **R2-Q02** 不建议原样保留，但应改写后继续进入候选池。
- **R2-Q07** 不建议作为独立新题原样保留，应合并到既有 CAS1/AUD6 级联题。

## 合并项

- **R2-Q07 CAS1 → 合并到 Round 01 已确认 Q07 / AUD6-CAS1 级联题**。理由：两者都要求全仓/全文件命中后逐个判改，而不是 bulk replace。R2-Q07 的增量是把矩阵覆盖面写得更全，应吸收到 canonical CAS1 的矩阵 schema，而不是占一个新问题名额。
- **R2-Q05 不合并到 R1-Q03**。R1-Q03 更像 OpenSpec carrier / dispatch-blocker 规则，R2-Q05 是具体 change split 与依赖图，二者相邻但不可互相替代。
- **R2-Q03 不合并到 R2-Q05 或 C6 评测题**。它问的是 Mastra-derived contract shape，不是评测阈值或 OpenSpec 粒度。

## 改写建议

- **R2-Q02 GOV4**：把「哪些应 adopt」改为「`docs/project/collaboration-and-roles.md §4.5` 已声称 adopt 的 Pi 三形态，在 C5 recovery / grill tournament / dispatch 实物中哪些已 enforce、哪些只是 prose」。要求输出 `mechanism / current_artifact / enforced_by / missing_gap / deferred_reason / no-runtime-boundary` 矩阵。
- **R2-Q03 GOV5**：补一句「只借契约形态，不引入 Mastra runtime / agent loop」。要求答案必须给出 C4 DemoFlow、C6 expected trajectory、C3 trace span 的字段名或文件落点。
- **R2-Q06 GOV9**：补反治理膨胀约束。题面应要求定义「必须派」和「不必派」边界，否则容易把每个普通设计判断都升级成 subagent 流程税。
- **R2-Q07 CAS1**：改成 canonical CAS1 子题：「先产 inventory matrix，不编辑文件」。矩阵列建议固定为 `source_decision / target_file / section / stale_claim / new_frame / action(change|supersede|no_change) / owner_change / verification_gate / superseded_marker`。
- **R2-Q08 CAS2**：要求给 SRD 段落的 before/after rewrite constraints，而不是只问「如何改写」。验收口径应包括：IR、surface、runtime tier 三词均被显式分层，且没有把 LoRA 慢路拍平成 generic frame。
- **R2-Q09 CAS3**：要求输出 action-level routing table，而非 family-level table；每行必须说明 L1/L2 判据来源是 `fc_flags`、`value.type`、状态依赖、还是安全/拒识。

## 遗漏风险

- **GOV1 archived specs impact 仍可能漏掉**：Round 02 没有直接问 D-domain surface 对已 archived C1/C3/C6 specs 的行为契约影响；如果后续轮次不补，OpenSpec SSOT 仍会漂。
- **「已 adopt」和「已 enforce」容易混淆**：Q02/Q03 都引用 Pi/Mastra 形态，但项目文档已有部分吸收声明。grill 必须审实物落点，否则会重复讨论已拍原则。
- **CAS1 容易变成全仓编辑冲动**：题面必须强调先 matrix 判改/不改，不能立刻改 CLAUDE/SRD/roadmap/ADR。
- **SUPERSEDED 规则不应只存在 Q01**：CAS1/R2-Q07 也要共享 SUPERSEDED 标记与历史段跳过规则，否则级联矩阵会把历史快照误当 live contradiction。
- **B1/B2 runtime landing gaps 未由本 9 题充分覆盖**：R2-Q05 提到 B1/B2，但没有单独逼问 state-cells/tool-card map 与端侧解析白名单的验收门；后续轮次需要补。

## 评分

| ID | 重要性 | 可验证性 | 非重复性 | 主线决策杠杆 | 风险揭示 | 总分 | 建议 |
|---|---:|---:|---:|---:|---:|---:|---|
| R2-Q01 | 5 | 5 | 4 | 4 | 5 | 23/25 | Keep |
| R2-Q02 | 4 | 4 | 3 | 3 | 4 | 18/25 | Rewrite |
| R2-Q03 | 4 | 4 | 4 | 4 | 4 | 20/25 | Keep |
| R2-Q04 | 5 | 4 | 4 | 5 | 4 | 22/25 | Keep |
| R2-Q05 | 5 | 5 | 4 | 5 | 4 | 23/25 | Keep |
| R2-Q06 | 5 | 4 | 4 | 4 | 5 | 22/25 | Keep with minor rewrite |
| R2-Q07 | 5 | 5 | 2 | 5 | 5 | 22/25 | Merge/Rewrite |
| R2-Q08 | 5 | 4 | 4 | 5 | 4 | 22/25 | Keep |
| R2-Q09 | 5 | 5 | 5 | 5 | 4 | 24/25 | Keep |

## 理由

- **R2-Q01** 是治理题里最可机械化的一题：有已发生分叉、有现成 `make verify`/`verify-cross-section` 方向、有 false-positive 和 SUPERSEDED 处理要求。
- **R2-Q02** 价值在防长任务漂移，但项目已经有 Pi 三形态吸收声明；若不改写，会变成重复确认原则，而不是审 enforcement gap。
- **R2-Q03** 能把外部框架借鉴压成 C4/C6/C3 三个合同面，避免「借鉴 Mastra」这种空话。
- **R2-Q04** 直接决定当前工作是 diagnose、design、spec 还是 build；这会影响是否允许 A2、G6-C、CAS 进入实现。
- **R2-Q05** 是 A2 前置硬题。拆错 change 会让 codegen、训练、评测、端侧白名单互相污染，返工风险高。
- **R2-Q06** 抓住了本轮真正的 frame-breaking 来源：ground-truth subagent。题目应保留，但必须防止把 subagent 变成无差别流程税。
- **R2-Q07** 本身很重要，但重复度低分；它应增强既有 CAS1/AUD6 canonical，而不是新增一个等价问题。
- **R2-Q08** 能防止 SRD 继续保留 generic frame 时代的术语残影，是范式翻案后的核心文档清债题。
- **R2-Q09** 最尖锐：它把「三层路由」从口号压到动作级边界，并强迫使用 §14 的 `fc_flags` / `value.type` 分布，不让人按 10 族粗暴拍脑袋。

## 保留项

- **R2-Q01**：保留，小改。它抓住了已实装 `verify-cross-section` 只覆盖有限锚点、而 C5 recovery/grill 文档数字继续分叉的真实风险；问题本身要求文档组、锚点、SUPERSEDED、误伤处理，足够可验。
- **R2-Q04**：保留。范式翻案后，A2/G6-C/CAS 的 Pocock 阶段确实不应继续统称 S5 diagnose；要求阶段、退出条件、禁止抢跑项，决策杠杆高。
- **R2-Q05**：保留，但要防和 Round 01 的 OpenSpec 载体题重复。它的价值在“change 拆分与依赖图”，不是再次争论是否走 OpenSpec。
- **R2-Q06**：保留，小改。ground-truth subagent 是本轮翻案的决定性机制，值得制度化；但必须加触发阈值和成本边界，避免把所有问题都升级成 subagent。
- **R2-Q08**：保留。它直接打 SRD 中 `FC泛化/ToolCallFrame` 旧表述和新三层范式的冲突，且明确要求区分 IR、model-visible surface、runtime tier。
- **R2-Q09**：保留。它把 L1/L2 边界落到 `fc_flags`、`value.type` 和 5 分钟 demo 目标，能防止再次把三层路由拍平成“全 LoRA”。

## 删除项

- **无硬删除项**。
- **R2-Q03 原题形态条件删除**：如果仍停留在“是否 adopt Mastra”这个问法，应删除；因为 roadmap 已经有 workflow graph / TrajectoryExpectation / observability 的映射。若改成“现有 Mastra 映射在 C6 四层评测后哪些字段缺口未闭合”，则可保留为改写题。

## 合并项

- **R2-Q07 合并到已确认的 R1-Q07/AUD6**：两者都是全仓级联清单与逐项判改，R2-Q07 的价值是补 CAS1 matrix 字段，不适合再作为独立新题。
- **R2-Q05 与 R1-Q03/AUD3 去重**：R1 已确认 OpenSpec 载体和 dispatch-blocker，R2-Q05 只应问“拆几个 change、依赖顺序、可观察边界、不可合并理由”。
- **R2-Q08 与 R2-Q09 不合并**：二者相邻但不同层级。Q08 是 SRD 术语/架构表述级联，Q09 是 runtime/data routing 边界，合并会变成大而散的 SRD 总题。
- **R2-Q02 可与 R2-Q04 轻关联但不合并**：Q02 是长任务治理落点，Q04 是阶段分诊；合并后会稀释 Pocock stage reset 的硬出口条件。

## 改写建议

- **R2-Q01**：补一句“现有脚本只查存档态 internal consistency，不证明数字 correctness；请说明哪些锚交给 cross-section，哪些仍需 source-level cite-verify。”这样可防把一致性门误当真相门。
- **R2-Q02**：改成“项目级 Pi 三形态已在 collaboration/roadmap 中 adopt；请审 C5 recovery/A2/G6-C 当前还缺哪些具体落点：append-only handoff、七段 closure、dispatch before/after gate，各自写入哪个模板、脚本或验收清单；哪些不落，理由是什么。”
- **R2-Q03**：改成“基于 roadmap 既有 Mastra 映射，C6 四层评测后哪些 schema 字段需要新增/修改/明确不做：DemoFlow step、TrajectoryExpectation、C3 trace span、C6 eval_run fingerprint；输出 keep/defer/drop 表。”
- **R2-Q05**：明确不问实现细节，问 change 边界：“每个 change 的 observable behavior、archive criteria、前置产物、回滚/阻塞条件，以及为什么不能与相邻 change 合并。”
- **R2-Q06**：加触发阈值：“凡改变 model-visible surface、SSOT、eval gate、安全/PII 边界、raw-derived 数字口径、或引入外部真实源时，是否强制 ground-truth subagent；输出必须含 citation verification + discovery gap，不只复述资料。”
- **R2-Q07**：作为合并题改为 matrix 模板要求：`target_file / section / old_frame / new_frame / action(change|no-change|supersede) / gate / owner`，并明确本题只产清单不编辑。
- **R2-Q08**：把“FC 泛化”改写要求收紧为三层对齐：“IR 仍 device×action×value；model-visible surface 为 D-domain 具名工具；runtime tier 为 10 族 mock/族外 unsupported/safety/refusal。”
- **R2-Q09**：要求输出不是设备族清单，而是判定规则：“explicit + rule/fc_flags → L1；EXP/SPOT/free/followup/ambiguous → slow path；并说明例外和 demo 剧本优先级。”

## 遗漏风险

- **GOV1/GOV2 残留**：本轮 9 题没有直接逼问 archived specs C1/C3/C6 是否要 MODIFY，也没有完整解决 C5 recovery amend 何时收敛成 OpenSpec specs SSOT。R2-Q05 只能部分覆盖。
- **consistency vs correctness 混淆**：R2-Q01 若不改写，会把 cross-section 当成 truth gate；脚本只能抓段间分叉，不能证明 534/191/2086 自身正确。
- **轻治理成本边界不足**：R2-Q02/R2-Q06 都有治理升级倾向，但原题没有要求 cost cap、适用等级、降级路径，容易把 demo 轻治理推成重流程。
- **state-cells 10 族前置可能被低估**：R2-Q05 提到 B2 map，但没有显式强调 state-cells 从 4 扩到 10 族是 tool-card map 前置，容易漏。
- **安全层级联缺口**：9 题没有单独问 risk-policy 独立单源、D-domain 后 safety_refusal 数据、安全 eval 如何级联；只能寄望 CAS1 matrix 抓到。
- **C6 四层门独立性**：R2-Q03/R2-Q05 需要防止把 golden/fuzz/unsupported/safety 又合成一个 pass_rate；原题没有写死这一风险。

## 评分

| Candidate | 重要性 | 可验证性 | 非重复性 | 主线决策杠杆 | 风险揭示 | 总分/25 | 建议 |
|---|---:|---:|---:|---:|---:|---:|---|
| R2-Q01 | 5 | 5 | 4 | 4 | 5 | 23 | Keep / minor rewrite |
| R2-Q02 | 4 | 4 | 2 | 3 | 4 | 17 | Rewrite |
| R2-Q03 | 3 | 4 | 2 | 3 | 3 | 15 | Rewrite or delete original form |
| R2-Q04 | 5 | 4 | 5 | 5 | 4 | 23 | Keep |
| R2-Q05 | 5 | 5 | 3 | 5 | 5 | 23 | Keep with dedupe guard |
| R2-Q06 | 5 | 4 | 4 | 5 | 5 | 23 | Keep / minor rewrite |
| R2-Q07 | 5 | 5 | 1 | 5 | 5 | 21 | Merge into R1-Q07/AUD6 |
| R2-Q08 | 5 | 5 | 5 | 5 | 4 | 24 | Keep |
| R2-Q09 | 5 | 5 | 5 | 5 | 5 | 25 | Keep |

## 理由

- **R2-Q01** 是高质量治理题，因为它要求可执行锚点和误伤策略；短板是需要明确“不查 correctness”。
- **R2-Q02** 的问题不是不重要，而是项目级 Pi 三形态已被吸收；原题会重复问已拍事项，应转为 C5 recovery 缺口审计。
- **R2-Q03** 目前最弱，因为 Mastra mapping 已在 roadmap 存在；必须从“是否借鉴”改成“现有映射是否缺字段/缺门”才尖锐。
- **R2-Q04** 直接决定现在是继续 diagnose、回 design，还是开 spec；这会影响后续所有 change 的合法起点。
- **R2-Q05** 是 A2 重构能否不爆炸的核心问题；只要避开 R1 已确认的载体题，它仍是 Round 02 的主干。
- **R2-Q06** 抓住了这次翻案的真正机制：不是多 agent 互审本身，而是 orthogonal ground-truth 打破 shared frame。
- **R2-Q07** 重要但重复。作为 CAS1 matrix 模板很有价值，作为独立候选会挤占名额。
- **R2-Q08** 能纠正 SRD 旧术语继续误导实现，是 CAS 里最该保留的文档语义题。
- **R2-Q09** 最强：它把 SRD 的快慢路原则、§14 数据分布、现场 demo 目标三者绑定，能直接暴露“按设备族一刀切”的错误假设。

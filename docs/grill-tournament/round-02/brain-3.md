## 保留项

- **R2-Q01**：保留，但需把旧数字作为 regression fixture，而不是继续当待解释事实。它直接追问 `verify-cross-section` 的文档组、锚点、SUPERSEDED 规则和误报处理，足够具体。
- **R2-Q03**：保留。它把 Mastra 从“借鉴”压到 `TrajectoryExpectation / DemoFlow / observability` 的文件和字段落点，能防空泛治理。
- **R2-Q04**：保留。范式翻案后阶段错判会导致抢跑，题目要求逐主线列阶段、退出条件、禁止项，能形成执行门。
- **R2-Q05**：保留。change split 是 A2/C5/C6/B1/B2 的主线切刀，要求依赖图和可观察行为边界，决策杠杆高。
- **R2-Q06**：保留。ground-truth subagent 是本轮翻案的真正反偏误机制，题目要求触发条件、输出要求、cite-verify 和写回位置，能制度化。
- **R2-Q08**：保留。SRD 的 `clarifyTag -> FC 泛化` 容易被新 D-domain surface 误读，题目要求区分 IR、model-visible surface、runtime tier，切中混层风险。
- **R2-Q09**：保留。它强迫按 `fc_flags` / `value.type` 和 5 分钟 demo 目标定义 L1/L2，而不是按设备族拍脑袋，风险揭示最强。

## 删除项

- **无整题直接删除**。
- **R2-Q02 原问法中的“是否 adopt Pi 三件套”应删除**：项目协作文档已经吸收 Pi 的 append-only handoff、七段 closure、before/after gate。它不该再问“要不要采用”，而应改成“C5 recovery 当前哪些环节没有按既有 Pi 纪律落物理 artifact”。

## 合并项

- **R2-Q07 合并到已确认的 R1-Q07 / AUD6 / CAS1 cascade 题**。它价值高，但 non-duplication 弱；独立保留会和“全仓级联必须逐个判改/不改、不能 bulk replace”的已确认题重复。
- **R2-Q01 不建议合并进 R2-Q07**。R2-Q07 是人工判改 matrix；R2-Q01 是机械一致性 gate 和 SUPERSEDED 规则，两者是先后关系，不是同一题。
- **R2-Q04 与 R2-Q05 不合并**。先判 Pocock 阶段，再按阶段拆 OpenSpec change；合并会把“是否该 design/spec/build”与“怎么切 change”混成一题。
- **R2-Q08 与 R2-Q09 不合并**。前者是 SRD 文案和三层范式对齐，后者是 10 族 runtime route boundary；共享 SRD，但决策产物不同。

## 改写建议

- **R2-Q01**：把开头改成“§14 已将旧 562/418/缺486 坐实替换为 534/191/2086，旧值应成为 drift regression case”。否则题目会无意中复活旧口径。
- **R2-Q02**：改为“既有 Pi §4.5 已 adopt 三形态；请审计 C5 recovery 哪些 handoff/dispatch/closure 没有物理落点，并给最小补强，不引入 Pi runtime/DB/hook 系统”。
- **R2-Q03**：要求输出三列：`Mastra shape`、`MAformac artifact/field`、`red-line non-adoption`。这样能防把 Mastra agent loop 偷渡进 runtime。
- **R2-Q04**：把主线列全：A2、B1、B2、C5 retrain、C6 four-layer eval、G6-C、CAS/E2 cascade。每条都要有 stage、exit condition、blocked-before。
- **R2-Q05**：把“几个 change”改为“最少几个 change”。要求每个 change 只能有一个 observable behavior boundary，避免按代码目录机械切。
- **R2-Q06**：补上触发阈值：外部 raw/量产 oracle 可改判、跨 session 漂移、数字口径冲突、archived spec 可能被推翻、单 agent 强结论缺反证。
- **R2-Q07**：若作为 merge delta，要求 matrix 字段固定为 `target_file / section / old_frame / new_frame / action / evidence / gate / owner_change`，并明确“本题只产清单，不编辑”。
- **R2-Q08**：把“FC 泛化”改写成“慢路从用户说法泛化到 D-domain 具名工具候选，再落 canonical IR”，避免把 LoRA slow path 说回 generic frame。
- **R2-Q09**：要求输出 family x route matrix，至少含 `rule_fast_path`、`lora_slow_path`、`clarify/refusal`、`C6 route expectation`，并引用 §14 分布作为依据。

## 遗漏风险

- **GOV1/GOV2 仍未被本轮 9 题正面覆盖**：archived specs 哪些需要 MODIFY，以及 C5 amend 文档何时收敛进 OpenSpec SSOT，只被 R2-Q05/R2-Q07 侧面碰到。若 final list 缺这两题，后续会继续“amend 决策很清楚，但 specs 事实源没变”。
- **R2-Q02 容易重复既有文档**：如果不改成 gap audit，它会消耗一个名额去重述 collaboration §4.5 已写的 Pi 纪律。
- **R2-Q07 若不合并，会制造 tournament 内重复**：R1 已确认 cascade / AUD6 方向；本轮应只保留“matrix schema + no-edit mode”的增量。
- **缺少“谁来签收/哪个 gate 阻断”的统一要求**：R2-Q01/Q05/Q07 都涉及 gate，但候选没有统一要求输出 gate 名、失败退出码或 `make verify` 挂载点。
- **SRD 两题有过度文档化风险**：R2-Q08/Q09 如果只要求改 SRD，不要求同步到 C4/C6 observable route expectations，会把架构正确性停在文字层。

## 评分

| ID | 重要性 | 可验证性 | 非重复 | 主线决策杠杆 | 风险揭示 | 总分/25 | 建议 |
|---|---:|---:|---:|---:|---:|---:|---|
| R2-Q01 | 5 | 5 | 4 | 4 | 5 | 23 | Keep + rewrite |
| R2-Q02 | 4 | 4 | 3 | 3 | 4 | 18 | Rewrite |
| R2-Q03 | 4 | 5 | 4 | 4 | 4 | 21 | Keep + rewrite |
| R2-Q04 | 5 | 4 | 5 | 5 | 4 | 23 | Keep |
| R2-Q05 | 5 | 5 | 4 | 5 | 4 | 23 | Keep |
| R2-Q06 | 5 | 4 | 5 | 5 | 5 | 24 | Keep + rewrite |
| R2-Q07 | 5 | 5 | 2 | 4 | 5 | 21 | Merge |
| R2-Q08 | 5 | 5 | 5 | 5 | 4 | 24 | Keep + rewrite |
| R2-Q09 | 5 | 5 | 5 | 5 | 5 | 25 | Keep |

## 理由

- **R2-Q01**：真实 drift 已发生，且能落到 `verify-cross-section`、文档组、锚点、SUPERSEDED 规则。弱点是题干仍引用旧数，必须明确旧数只是待防回归样本。
- **R2-Q02**：问题重要，但现有协作文档已吸收 Pi 三形态；原题会重复问已拍纪律。改成 C5 recovery 的 compliance gap audit 后才 sharp。
- **R2-Q03**：题目质量高，因为它要求具体落到 C4/C6/C3，而不是“借鉴 Mastra”。需要再加 red-line，防把自由 agent loop 引回 runtime。
- **R2-Q04**：阶段分诊是抢跑风险的总闸。它不直接决定实现细节，却能决定哪些线必须回 S2/S3，哪些仍可 diagnose/build，杠杆很高。
- **R2-Q05**：A2、C5、C6、B1、B2 互相依赖但边界不同；如果不拆 change，后续会出现大爆炸重构或 specs/implementation 混层。
- **R2-Q06**：这是本轮最有制度价值的治理题之一。第4源 ground-truth 推翻共识说明跨 agent 互审不等于破 frame，必须定义何时强制拉一手 oracle。
- **R2-Q07**：内容正确且可验证，但已被 R1 cascade 题覆盖。应作为已确认题的 schema 增强，而不是新增独立有效题。
- **R2-Q08**：它抓住最容易复发的混层错误：把 IR 的 device/action 和 model-visible surface 的具名工具混掉。题目具体、可按 SRD 段落检查。
- **R2-Q09**：最强题。它要求用 §14 的实际分布决定路由边界，直接防“10 族全 L1”或“全部 LoRA”的两种偷懒错法，且能生成 C4/C6 的可测 route expectation。

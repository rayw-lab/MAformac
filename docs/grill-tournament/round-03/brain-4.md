# 保留项

- **R3-Q02**：保留。它把「现场只说 10 族」从口头策略拉回到 SRD、demo docs、二期 domain 边界，是主线决策。
- **R3-Q05**：保留。当前 `roadmap`、C5 recovery、paradigm amend、A2 audit 并存，事实源漂移已经发生；这个问题有最高级别的推进杠杆。
- **R3-Q07**：保留。D-domain 具名工具后，旧 `parent_overlap` 不足以证明没有死记；held-out 维度需要重定义。
- **R3-Q08**：保留。四类数据引入 unsupported/safety negative 后，旧 IrrelAcc 口径会混掉拒识、误召、安全拒绝，必须拆门。
- **R3-Q09**：保留。generator/judge/contract label/oracle 红线是训练数据质量的物理机制，不是文档口号；可直接落到数据生产合同。
- **R3-Q01**：改写后保留。方向对，但要避免重复 R2 已确认的 IR/surface/runtime 分离题；本题应专注 runtime route taxonomy 和 trace/C6 证明。
- **R3-Q03**：改写后保留。重要，但当前过宽，容易变成「全仓级联清单」的重复；应聚焦 D1-D37 决策状态表。
- **R3-Q04**：改写后保留。文档落点明确，但要写成 MASTER 的防误读补丁，而不是再次讨论 D-domain 是否成立。
- **R3-Q06**：重写后保留，原文不宜直接保留。它容易把已拍的 `rank16Mainline` 守现状又打开；更好的题是定义「什么时候才允许重开 recipe」。

# 删除项

无硬删除项。九题都覆盖真实风险；最弱的是 **R3-Q06 原文**，问题不是不重要，而是容易诱导误诊，把 surface/parity 问题错归因到 LR/rank/optimizer。

# 合并项

- **不建议 Round 03 内部合并 R3-Q07 与 R3-Q08**：一个是 split/data gate，一个是 eval/refusal metrics，合并会把防死记与防误召混成一个大题。
- **不建议内部合并 R3-Q01 与 R3-Q04**：两者都涉及分层，但一个落 SRD/runtime trace，一个落 baseline MASTER/语义协议说明，文件责任不同。
- **跨轮去重提醒：R3-Q01 与已确认 Q16/Q17 有重叠**。保留 R3-Q01 时必须删掉 IR/surface 泛泛讨论，只问「执行兜底 L1-L4」与「runtime tier」如何统一成可验证 route taxonomy。
- **跨轮去重提醒：R3-Q03 与 CAS1/AUD6 有重叠**。R3-Q03 应只产 D1-D37 `keep|modify|superseded|defer` 决策表；全仓 stale grep 和文件级 cascade 归 CAS1/AUD6。
- **跨轮去重提醒：R3-Q06 与 TRN2/TRN3/AUD5 有边界**。它只管 recipe-change veto rule，不应重复 train/eval/runtime surface parity 或中途 C6 gate。

# 改写建议

- **R3-Q01 改写**：限定输出一个 `route_outcome`/`runtime_tier` 枚举映射表，逐项映射 SRD L1-L4、10 族 mock、族外 unsupported、越界、safety refusal，并要求 C4 trace 字段与 C6 四层 case 各自引用同一枚举；不要再讨论 IR/surface 分层。
- **R3-Q02 改写**：拆成三层验收：demo communication boundary、runtime unsupported behavior、training/eval negative set。明确导航/音乐/外卖是 Phase 2 MCP，不得在 P0/P1 SRD、demo golden-run、C6 scope 中暗含泛化承诺。
- **R3-Q03 改写**：要求输出机器可审的 D1-D37 manifest：`decision_id`、`old_claim`、`new_status`、`reason_source`、`cascade_targets`、`blocking_before_A2`。首批必核 D14/D16/D30/D35/D37，剩余 D 项可标 no-impact 但必须显式出现。
- **R3-Q04 改写**：问题应要求 MASTER 增加「IR is canonical, surface is derived」的两层声明、禁止把 value 四件套推导成 model-visible generic frame，并列出 MASTER 下游派生物需要同步的字段名。
- **R3-Q05 改写**：把答案格式锁死为 single-source-of-progress policy：哪份文件是当前推进 SSOT，哪些文件只保留历史，旧 roadmap 是 banner superseded、局部 rewrite 还是 archive link；同时要求 `CLAUDE.md`、`docs/README.md`、handoff 模板口径一致。
- **R3-Q06 改写**：从「是否重审 LR/rank」改为「recipe freeze / reopen criteria」。默认守 `LR1e-4 + rank16Mainline + repo-loop + metrics.jsonl`，只允许在 G6-C 证明 surface/parity/negative gates 已排除后，凭哪类曲线证据重开 recipe。
- **R3-Q07 改写**：要求定义 held-out matrix，而不是单选一种切法。至少覆盖 family、value_form、utterance_template、semantic_parent、tool_name、generator_source，并规定哪些维度必须跨 train/eval disjoint，哪些只做 stratified balance。
- **R3-Q08 改写**：要求四个独立门：in-domain false-call、unsupported refusal、safety refusal、irrelevant/OOD refusal。明确 IrrelAcc 不得把 unsupported 和 safety 混入同一分母；阈值必须和 C6 四层门一一对应。
- **R3-Q09 改写**：要求 data recipe 合同：generator/judge family、seed 数、per_seed 上限、label authority、oracle usage boundary、duplicate/ambiguous gate、contamination check、raw redline enforcement、artifact audit trail。不要只问「怎么做」，要问「哪个字段证明做到了」。

# 遗漏风险

- **缺少显式 A2 前置排序**：R3-Q01/Q04/Q05/Q03 都会影响 A2，但候选集没有要求排出「哪些 grill 决策阻塞 A2 派单，哪些可后置」。
- **缺少 generated drift gate 的承接**：R3-Q04/R3-Q05 会改 SSOT/MASTER/roadmap，但没有点名 generated D-domain 产物必须进入 drift gate；这可能让文档改了、生成物继续漂。
- **缺少端侧 decode reality check**：本轮训练题都围绕数据和 recipe，但没有问 mlx-swift 端侧是否真的支持受限解码、或 fallback JSON 防御解析如何进入 parity。
- **缺少 state-cells 4 族到 10 族的前置**：runtime tier 和 C6 四层评测若不要求 state-cell/card-map 覆盖 10 族，mock 读回验收会断在执行层。
- **缺少 safety refusal 与 DemoGuard 的边界**：R3-Q08 说 safety refusal，但还需防止把安全动作做成模型可选工具；安全应保持 policy/code gate，LoRA 只学拒绝话术和 risk ids。
- **缺少 final list 去重规则**：Round 1/2 已确认 Q16/Q17/Q15/Q05/Q06，本轮若不标跨轮边界，最终 41 题会在 SRD 分层、级联清单、训练 gate 上重复占坑。

# 评分

| ID | 重要性 | 可验证性 | 非重复性 | 主线决策杠杆 | 风险揭示 | 总分 | 建议 |
|---|---:|---:|---:|---:|---:|---:|---|
| R3-Q01 | 5 | 5 | 3 | 5 | 5 | 23/25 | 改写后保留 |
| R3-Q02 | 5 | 4 | 5 | 5 | 4 | 23/25 | 保留 |
| R3-Q03 | 5 | 4 | 4 | 5 | 4 | 22/25 | 改写后保留 |
| R3-Q04 | 4 | 4 | 4 | 4 | 5 | 21/25 | 改写后保留 |
| R3-Q05 | 5 | 5 | 5 | 5 | 4 | 24/25 | 保留 |
| R3-Q06 | 4 | 3 | 4 | 4 | 4 | 19/25 | 重写后保留 |
| R3-Q07 | 5 | 5 | 5 | 4 | 5 | 24/25 | 保留 |
| R3-Q08 | 5 | 4 | 5 | 5 | 5 | 24/25 | 保留 |
| R3-Q09 | 5 | 5 | 5 | 5 | 5 | 25/25 | 保留 |

# 理由

Round 03 的整体质量高：它覆盖 CAS4-CAS8 和 TRN1/TRN4-6，正好补 Round 1/2 后 ledger 中剩余的级联与训练机制缺口。最强的是 R3-Q09、R3-Q05、R3-Q07、R3-Q08，因为它们都能直接逼出可落地字段、阈值、文件权威或数据合同。

主要问题不是题目不锋利，而是部分题会重复已确认问题或重开已拍结论。R3-Q01 必须避开已确认的 IR/surface/runtime 分离泛论；R3-Q06 必须避开「看到训练失败就调 recipe」的确认偏误，改成 recipe freeze 与 reopen evidence；R3-Q03 必须从全仓级联缩回 D1-D37 状态表。

我的最终建议：九题全进入候选池，但其中四题必须带改写条件。最终保留时优先保证每题有一个物理落点：枚举、manifest、policy、MASTER patch、SSOT banner、recipe veto rule、held-out matrix、C6 gate、data recipe。没有物理落点的 grill 题会变成讨论题，不能支撑 A2/C5 后续执行。

---
authority: e2_subset_grill_round_seed_and_skeleton
artifact_kind: grill_dimension_tree_and_paradigm
paradigm: UIUE 215-grill 决策矩阵（7 列 + 防惨败列 cite P1-P9 + 消减表 + landing）
id_ranges: W1 装载策略官 S-001~060 / W2 预算降级官 S-101~160 / W3 同源门官 S-201~260 / commander 纵切 SF-01~20
created: 2026-07-02
author: claude-commander（磊哥 6 维度 → 下探/扩展为 9 维度树）
core_frame: 🔴 subset 不能制造新的 surface drift（磊哥定）——gate3 六轴同源是本轮宪法，每个决策先问「这会不会造出第二个面」
seed_docs: docs/e2-subset-design-package-2026-07-02.md（E-lite 已 XAUDIT 修订）+ runs/2026-07-02-baseline-roadmap/L4-e2-subset-materials.md（真 tokenizer 实算）
status: round_complete_pending_magnet_ratification
---

# E-2 subset-policy grill round — 维度树（commander 下探版）

> 磊哥 6 个粗略维度（device-group 粒度 / top-2 跨族 / 8K fallback / scene macro 边界 / grammar≡mounted digest / multi-intent 首版）→ 下探成 9 维度 33 子点。已决承接（grill-recall，别重拍）：E-lite 方向（D-017②+design 包）/ 8K 预算 ⭐ 待磊哥 E2-1 / E-024 C5 不训多意图（⭐C proposed）/ gate3 六轴同源 / L1 规则快路不碰模型。

## D1 device-group 粒度（磊哥① 下探 4 子点）→ W1
- 1a 🔴 **seat 126 工具按什么切**：`_sg` service-group vs 位置（主驾/副驾/后排）vs 功能（加热/通风/按摩/位置）——**一手 teardown** `generated/D_domain.tools.demo.json` seat 条目的 `_sg`/`_ir` 实际分布 → 每候选分组方案逐组真 tokenizer 实算验 ≤预算。
- 1b 🔴 分组 manifest 的 SSOT 血缘：必须 codegen 从 D-domain catalog/C2 state-cells 派生，**新造手写分组 = 第二 SSOT = 本轮头号反模式**。
- 1c 粒度下限判据：过细→漏挂率↑（L4 已警告 191 device 过细）、过粗→token 爆——给量化判据（漏挂成本 × token 成本），不拍脑袋。
- 1d **共现驱动分组**：bug 库 1730 条挖「哪些 device 同句共现」（座椅加热+空调温度）→ 分组边界按共现聚类 vs 纯功能树；数据在 `~/.bug-skill/data.db`（只读，§6 红线：原文不入仓，只出统计）。

## D2 top-2 跨族装载（磊哥② 下探 4 子点）→ W1
- 2a top-2 判定来源：NLU 置信分布 / clarifyTag / 端侧轻 embedding（TinyAgent ToolRAG 用云 embedding，我们离线——本地小 embedding vs 词表/规则路由，联网搜端侧 retrieval 先例）。
- 2b 🔴 top-2 组合预算数学：最坏 seat+light=35.7k+22.8k 爆 → top-2 必须 group 级非族级？逐组合实算矩阵。
- 2c top-2 混装面的训练同构：distractor 从第二候选族抽（home-llm distractor 扩展）——训练见过混装面才不算 drift。
- 2d 错族恢复：top-2 都不含目标 → 触发信号（NO_TOOL？低置信？）→ 重装载重推理延迟预算（3s 闭环还剩几毫秒，KV 冷启动代价）。

## D3 8K 超限 fallback（磊哥③ 下探 4 子点）→ W2
- 3a fallback 链形状：超限时按什么排序裁工具（demo 场景权重/bug 热度/usage 频率）。
- 3b 🔴 **超限检测时点 = 本轮最重要单点**：⭐ manifest build 时静态门（每 group 预算 fail-closed，runtime 零裁剪）vs runtime 动态裁剪——**动态裁剪 = 训练面与运行面漂移 = 亲手制造 drift**，正是磊哥 frame 的反面教材。
- 3c 预算构成拆账：8K 总预算 = system(实测29) + DialogueState 3轮 + user + 工具面 + generation headroom → 工具面真配额 ~多少（逐项实算）。
- 3d KV cache 预热（home-llm 先例）× subset 稳定性：换 group = 前缀变 = KV 失效 = 冷启动——装载稳定性 vs 精准性 trade-off，demo 3s 闭环下怎么选。

## D4 scene macro 兜底边界（磊哥④ 下探 4 子点）→ W2
- 4a scene macro 与 C2 scenario-state-protocol 的关系：挂 C2 scenario 定义 vs 独立 manifest（防第二 SSOT，同 1b）。
- 4b 兜底触发：预路由置信<阈值自动切 vs 方案经理控制台 force 场景态（demo 现场实际操作流——mock 控制台已是 UIUE 已决）。
- 4c 宏的内容与预算：demo 脚本分段→每段一宏？宏 = 哪些 group 的并集，逐宏实算 ≤8K。
- 4d 宏外说法边界：宏兜底态用户说宏外族 → unsupported 拒识 vs 重路由——与 R2 安全拒识/L4 兜底层衔接（拒识话术分层见 D8-8c）。

## D5 grammar allowed ≡ mounted digest（磊哥⑤ 下探 5 子点）→ W3
- 5a digest 机制设计：hash 什么（工具名集 vs 含 schema）/ 谁算 / 谁校验（preflight + runtime assert 双点？）。
- 5b grammar 生成时点：per-group 静态预编译（XGrammar 编译成本，联网搜实测）= manifest build 产物 vs runtime 动态。
- 5c digest 失配 fail 形状：端侧 runtime 的 fail-closed 怎么表达（拒答+日志？降级无 grammar？——降级 = drift，倾向硬拒）。
- 5d 🔴 **NO_TOOL 出口必须在 grammar 里**：grammar 强约束下模型必须能说「不」，否则强制幻觉工具 = 必然误吸 = 0/34 惨败 `empty=hit` 教训（F-005，`docs/c5-training-readiness-grill/worker-commander-failure-defense-decisions.md:23`，empty collapse 曾致 irrel_acc 0.956 虚高）的**对偶**——那次是「空输出被记成对」，grammar 无 NO_TOOL 出口则是「想拒拒不了被迫输出工具」，P5 防线延伸——这是 commander 下探出的最重安全点，W3 必给机制。
- 5e think span × grammar 交互：Qwen3 think 模式下 grammar 从哪个 token 生效（mlx-swift-structured `TriggeredTagsFormat` 先例深拆）。

## D6 multi-intent 首版装载（磊哥⑥ 下探 3 子点）→ W1
- 6a E-024（⭐C：C5 不训多意图）约束下：runtime splitter 拆句 → 每句独立路由独立装载（串行 2×prefill）→ 3s 延迟还成立吗（实算）。
- 6b 🔴 D2 与 D6 边界划清：连续两句跨族（句1 ac 句2 seat）= splitter 后各自单族装载，**不需要混装**；混装的真需求 = 单句模糊跨族（「我冷了」→ac+seat 候选）——两场景别搅在一个机制里。
- 6c manifest schema 为 multi-intent 预留：per-utterance mounting log + sequencer per-step digest。

## D7 训练面统计同构（commander 扩展）→ W3
- 7a 集合同源之上还有**分布同构**：训练样本工具面大小分布 vs runtime 装载大小分布（训练全见 8 个工具、runtime 挂 40 = count distribution shift）——联网搜 tool-count vs accuracy degradation 研究（BFCL/ToolLLM 系）。
- 7b distractor 采样 × group：same-group distractor = 最难负例最有价值（home-llm 相似度过滤先例）→ 采样策略进 manifest。

## D8 评测面扩展（commander 扩展）→ W3
- 8a C6 case schema 加 subset 上下文字段（case 在哪个 group/宏装载下测，`mounted_tools_digest` per case）。
- 8b 四层语义受 subset 影响重审：unsupported 层在 group 语境下的新语义。
- 8c 🔴 **三层「不支持」分层**：group 外但族内 / 10 族外 / 全集外——拒识行为与话术要不要分层（评测 expected 怎么写）。

## D9 subset 特有失败模式 premortem（commander 纵切，贯穿）→ commander
- 漏挂/错挂/digest drift/KV 抖动/grammar 强制幻觉/多轮 group 切换状态丢失/宏外错拒/top-2 组合爆预算——逐条 tiger/paper-tiger/elephant + 防线归属 + 验证清单（SF-01~20）。

## 范式要求（每 worker 硬约束）
1. 决策矩阵 7 列（ID/议题/选项/⭐推荐/依据 file:line 或 URL+日期/status=proposed/防惨败列 cite P1-P9）。
2. **grill-recall**：先读 seed 两件 + 本 README 已决承接段，不重拍已决。
3. **teardown/巨人肩膀**：W1 拆 catalog+TinyAgent+bug 库；W2 拆 home-llm KV/distractor+C2；W3 拆 mlx-swift-structured+C6 schema——全部 file:line 一手。
4. **联网深搜**（磊哥点名）：每官 ≥8 条带 URL+抓取日期 的外部搜证（tool-selection/structured-output/context-budget 业界实践），驱动决策的数字/断言标 source。
5. R7：全程 read-only + 写自己的 decisions 文件，不训练不生成不调云 LLM。
6. 产出落主树 `docs/c5-training-readiness-grill/e2-subset-w{1,2,3}-decisions.md`（各写各的不碰别人文件，**不 commit**，commander 统一收口 commit）。

## landing 骨架（grill-baseline-skeleton-upfront，收口填格）
| 维度 | worker | 决策数 | 消减后 | ⭐待磊哥 | 状态 |
|---|---|---|---|---|---|
| D1/D2/D6 | W1(%44) | 11（S-001~011） | 并入 13 会聚组 | E2-A | ✅ done |
| D3/D4 | W2(%43) | 8（S-101~108） | 并入 13 会聚组+§2 仲裁 | E2-B | ✅ done |
| D5/D7/D8 | W3(%43) | 10（S-201~210） | 并入 13 会聚组 | E2-C/D | ✅ done |
| D9 | commander | 14（SF-01~14） | 4 elephant 单列 | E2-E | ✅ done |
| **综合** | commander | **43 → 13 会聚+1 仲裁+7 独立+4 elephant** | `e2-subset-SYNTHESIS.md` | **E2-A~E 五拍** | ✅ synthesized_pending_magnet |

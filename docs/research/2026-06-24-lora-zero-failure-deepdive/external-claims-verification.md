# 论文 ID / 数字 ground-truth — 主线程亲核（防编造对照基线）

> **定位**: workflow 跑期间，主线程对 19 图提及论文的 arxiv ID + 关键数字做 WebSearch 亲核（ultracode 横切纪律7 + 防编造铁律：finder 高发编造 arxiv ID 且安到真 source 上）。L14 finder 回稿时**逐条对照本表**，引错 ID/数字即 catch。
> **核验时间**: 2026-06-24 · **方法**: WebSearch（US-only）+ arxiv/ACL Anthology/GitHub 交叉。

## 核实表

| 图 | 论文 | arxiv ID（权威）| venue | github | 状态 |
|---|---|---|---|---|---|
| 175-177 | **NLoRA: Nyström-Initiated Low-Rank Adaptation** | **2502.14482** | EMNLP 2025 Findings p1371-1385 苏州 | TracyGuo2001/NLoRA | ✅ 核实 |
| 178-179 | **Riemannian Optimization for LoRA on the Stiefel Manifold** | **2508.17901**（2025-08-25）| EMNLP 2025 Findings (2025.findings-emnlp.1143) | — | ✅ 核实 |
| 173(评论) | **CorDA: Context-Oriented Decomposition Adaptation** | **2406.05223** | NeurIPS 2024 | iboing/CorDA（已入 hf/peft）| ✅ 核实 |

## 🔴 关键发现（喂给 L14 + 修正我之前的理解）

1. **NLoRA = SLoRA = IntTune 是同一篇论文的三个贡献**（不是三篇）：①SLoRA（A/B 间插小中间矩阵 ΔW=ANB）②NLoRA（Nyström 初始化 SLoRA）③IntTune（只调中间矩阵）。我之前在 18 路里把它们当并列方法，**实际是一篇论文的递进三贡献**——L14 要按一篇拆。

2. **图176/177/178 的论文数字全部真实**（不是小红书编的，来自真实 EMNLP 2025 论文）：
   - NLoRA GSM8K: SLoRA **56.48%** / NLoRA **57.70%**，超 LoRA **33.52%/36.41%**，+**3.67M** 参数（[arxiv 2502.14482](https://arxiv.org/abs/2502.14482)）
   - IntTune: 超 LoRA 平均 NLG **7.45%**，只用 **1.25%** 参数（同上）
   - Stiefel-LoRA: rank16 有效秩冗余 + B^T B=I_r 正交约束 + DoRA 叠加（[arxiv 2508.17901](https://arxiv.org/abs/2508.17901)）
   → **小红书帖搬运论文数字是准确的**，可信度比预期高；但论文数字 = 论文声称层（LLaMA2-7B 上的 NLG/NLU），**不等于 mlx+1.7B+D-domain+FC 任务会复现**，L14 必须假想验证、不当事实采用。

3. **🟢 CorDA KPA 模式直接对应 L10（灾难遗忘）**：CorDA 的 Knowledge-Preserved Adaptation 专门解决"catastrophic forgetting of pre-trained world knowledge"——用最小 r 奇异值分量初始化 adapter、冻结其余以保世界知识。**这是 L10 防遗忘 + L14 逃生口的交叉候选**（vs 图181 的"混 5-20% 通用数据"是另一条防遗忘路）。L10/L14 finder 应交叉评估：CorDA KPA（改初始化）vs 通用数据混入（改数据）哪个更适合 demo 轻治理。

4. ⚠️ **ID 歧义留意**：NLoRA 搜索结果提到"also listed under arXiv:2502.14494"——**权威 ID = 2502.14482**（ACL Anthology + GitHub + arxiv abs 三处一致指向）；若 finder 引 `2502.14494` 需复核（疑为搜索引擎噪声）。

## 对 rank16Mainline 主线的初判（steelman 守现状预埋）

- 这些方法都**要改训练代码**（加中间矩阵 N / Stiefel 优化器 / Nyström 或 SVD 初始化 / CorDA 协方差分解）→ 与"配方零碰 + 本机 mlx-lm + demo 轻治理"冲突，引入=加炸场风险。
- 默认态度：**DEFERRED escape-hatch**，不动 rank16Mainline 主线。唯一可能例外 = CorDA KPA 若证明对"D-domain 训练后中文泛化保留"显著（L10 假想验证），可作 L10 的备选腿（但仍需改初始化代码）。
- 论文数字诱人（GSM8K +33%）但**任务不同**（数学推理 vs D-domain 工具调用格式学习）——LoRA 弱项区（学难）vs 强项区（学格式）的区别（见 19 图见解），不能跨任务外推。

## 回稿对照清单（L14 finder 回来后逐条核）

- [ ] L14 引的 NLoRA ID 是否 = 2502.14482（非 14494/其它）
- [ ] L14 引的 Stiefel ID 是否 = 2508.17901
- [ ] L14 引的 CorDA ID 是否 = 2406.05223
- [ ] L14 是否把 SLoRA/NLoRA/IntTune 当三篇（错）还是一篇三贡献（对）
- [ ] L14 的 GSM8K 数字是否 = 56.48%/57.70%（与本表一致）
- [ ] L14 是否对每方法做了 mlx+1.7B+D-domain 假想验证（非直接采用论文数字）
- [ ] L10/L14 是否交叉评估了 CorDA KPA vs 通用数据混入防遗忘

## repo 活跃度 ground-truth（gh 核 2026-06-24，防 finder 编造 star/pushedAt）

| repo | ⭐star | pushedAt | finder 引用判定 |
|---|---|---|---|
| ShishirPatil/gorilla (BFCL) | 12918 | 2026-04-13 | ✅ L04 评测权威，活跃高人气 |
| ml-explore/mlx-lm | 6019 | 2026-06-12 | ✅ L01 本机训练栈，活跃高人气 |
| ml-explore/mlx-swift | 1932 | 2026-06-17 | ✅ L06 端侧，7 天前动 |
| acon96/home-llm | 1364 | 2026-06-11 | ✅ L15 最大肩膀，近期仍活跃 |
| sierra-research/tau-bench | 1292 | 2026-03-18 | ✅ L04 活跃 |
| NVlabs/DoRA | 978 | 2026-03-24 | ✅ L13 活跃（ICML2024 Oral）|
| SalesforceAIResearch/xLAM | 630 | 2026-06-02 | ✅ L07 数据合成，活跃 |
| Goekdeniz-Guelmez/mlx-lm-lora | 384 | 2026-06-16 | ✅ L01/L02/L13 mlx LoRA 训练关键，2 天前还动 |
| NVIDIA/When2Call | 64 | 2025-04-29 | ⚠️ 低 star+1 年没动，但 NVIDIA 官方 eval set（数据可用，repo 别 adopt）|
| iboing/CorDA | 56 | 2025-01-13 | ⚠️🔴 独立 repo 1.5 年没动该淘汰，但已入 hf/peft（用 peft 版）|
| TracyGuo2001/NLoRA | 6 | 2025-03-02 | ⚠️🔴 论文 repo 6★+1 年没动，读方法别 adopt（印证 L14 escape-hatch 定位）|

→ 防编造对照：L01/L04/L06/L07/L13/L14/L15 finder 若引这些 repo 的 star/pushedAt，对照本表；偏差大=编造。
→ 新鲜度修正（github-first）：CorDA/NLoRA 独立 repo >60 天没动该淘汰 → CorDA 走 hf/peft 集成版、NLoRA 仅读方法不 adopt。mlx 系（mlx-lm/mlx-swift/mlx-lm-lora）全活跃，端侧训练栈可信。

## 6 路 finder 引用的 arxiv ID 核验（主线程 WebSearch 2026-06-24）

| arxiv ID | 标题 | 真伪 | 引用语境一致性 |
|---|---|---|---|
| 2511.22138 | TinyLLM: SLM for Agentic Tasks on Edge Devices (2025-11) | ✅ 真实 | ✅ 一致（BFCL 评测 SLM<3B edge，对应 L01/L06）|
| 2510.05133 | Characterizing Model Behavior Under Synthetic Data Training (2025-10) | ✅ 真实 | ✅ 一致（合成数据 0-50% 比例 model collapse，对应 R9）|
| 2604.05426 | ALTO: Adaptive LoRA Tuning and Orchestration (2026-04, Rice) | ✅ 真实 | ✅ 一致（LoRA 超参 + best-checkpoint patience，对应 R10）|
| 2408.14774 | Instruct-SkillMix: Pipeline for LLM Instruction Tuning (ICLR2025, Princeton/Meta) | ✅ 真实 | ⚠️ 论文真实但主题=SFT 数据 pipeline 非 checkpoint；finder 引的「loss 上升 held-out 峰在 mid-training」(R10) 是借其训练动态观察，需细核此 claim 真在论文；不影响 R10 结论（取 best-checkpoint 非末轮）合理性 |

→ 结论：6 路 finder 论文引用**基本可信**（4/4 真实存在，3/4 语境一致，1 个语境略借用需细核），质量比 amnesia 调研 finder 编 issue# 高。12 路补跑回来的 external_claims 同样逐条核（尤其 L14 论文路 + L07/L08 数据路）。

## 18 路高频 arxiv ID 核验（主线程 WebSearch 2026-06-24，抽样 top 高频，18 路共引 80+ ID）

> 🔴 **口径修正（claim-vs-reality 第8坑自纠，2026-06-24）**：下表「出现」列原误标「N 路」，实为 `grep | uniq -c` 的**出现次数**（同一 lens 文件内多次 ≠ 多路 finder）。已改为「文件(lens) × 次数」准确口径。影响：2602.04998 实为 lens13/14 两路（非"11 路广泛引用"）；2603.03203 实为 lens08 **单路**内 5 次（=单路 finder 编造，非跨路传播）。结论（真伪/支撑）不变。

| arxiv ID | 出现(文件×次) | 标题 | 真伪 | 对决策的支撑 |
|---|---|---|---|---|
| **2602.04998** | **lens13/14 · 11次** | Learning Rate Matters: Vanilla LoRA May Suffice for LLM Fine-tuning (2026-02) | ✅ 真实 | 🔴 **守 rank16Mainline 最强背书**：系统重评 9 个 LoRA 变体 vs vanilla，证明调好 LR 后 vanilla LoRA competitive，新变体优势多来自 baseline 调参不足。直接支撑 L13/L14「PEFT 新结构=escape-hatch 不动主线」|
| 2507.02825 | lens04 · 4次 | ABC: Best Practices for Rigorous Agentic Benchmarks (2025-07) | ✅ 真实 | 0/34 同根铁证：明文「TAU-bench counts empty responses as successful」「误差 up to 100%」。L04 引用准确 |
| 2506.20856 | lens08 · 6次 | Leaner Training, Lower Leakage: Memorization in LoRA FT (2025-06) | ✅ 真实 | LoRA vs full FT，LoRA 显著降 memorization。支撑 L08/L10「用 LoRA 不 Full FT」|
| 2604.17073 | lens12 · 5次 | Abstain-R1: Calibrated Abstention via Verifiable RL (2026-04, 3B) | ✅ 真实 | 🔴 **支撑 L12「拒识该 DPO/RL」**：RLVR 做 abstention+post-refusal clarification，3B 模型，正对 7 个 demo-critical 拒识 case |
| 2504.18851 | lens04/07/12 · 5次 | When2Call: When (not) to Call Tools (NAACL 2025, NVIDIA) | ✅ 真实 | 4-class abstention + **RPO 偏好优化比 fine-tuning 改进大**。又一证据支撑 L12 拒识用偏好优化 |
| **2603.03203** | **lens08 · 5次** | — | 🔴🔴 **WebSearch 搜不到（疑似编造/typo）** | **lens08 单路 finder 内引 5 次一个搜不到的 ID = 单路编造高发 catch**。不可作 load-bearing 证据，propose 引用前必复核（可能 2603 vs 2606 typo）|

→ 核验结论：抽样 6 个高频中 **5 真实+引用准确，1 个（2603.03203）疑似编造**（lens08 单路内 5 次引用、搜不到）。**防编造 catch 价值兑现**——18 路 80+ ID 不可能全真。其余未抽样的 70+ ID，propose 引用任一前必 WebSearch 复核（ultracode 横切纪律7：finder 高发编造精确 ID）。
→ 🔴 **两个 load-bearing 正面发现**：① 2602.04998（lens13/14）是守 rank16Mainline 的核心理论背书；② Abstain-R1(2604.17073)+When2Call(2504.18851) 双证据支撑「拒识/澄清类需偏好优化非纯 SFT」(L12 新 insight 外部坐实)。

**Sources**: [Learning Rate Matters 2602.04998](https://arxiv.org/abs/2602.04998) · [ABC 2507.02825](https://arxiv.org/abs/2507.02825) · [Leaner Training 2506.20856](https://arxiv.org/abs/2506.20856) · [Abstain-R1 2604.17073](https://arxiv.org/abs/2604.17073) · [When2Call 2504.18851](https://arxiv.org/abs/2504.18851) · [NLoRA arxiv 2502.14482](https://arxiv.org/abs/2502.14482) · [NLoRA ACL](https://aclanthology.org/2025.findings-emnlp.72/) · [Stiefel-LoRA arxiv 2508.17901](https://arxiv.org/abs/2508.17901) · [Stiefel ACL](https://aclanthology.org/2025.findings-emnlp.1143/) · [CorDA arxiv 2406.05223](https://arxiv.org/abs/2406.05223) · [CorDA github](https://github.com/iboing/CorDA)（均 WebSearch 2026-06-24 核）

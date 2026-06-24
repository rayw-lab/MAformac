# Lens L11 — 训练后反巧合 + 稳定性 ablation（一手调研档）

> 维度：一次 C6 pass ≠ 真学会。L11 管「过是不是巧合」，L04 管「过没过」，边界正交（磊哥点名独立）。
> as-of 2026-06-24 · 本机一手(C6VehicleToolBench.swift / iot-agent-bench teardown / mlx-lora-quality-control) + 11 路联网搜证(近 3 月优先)
> Phase 0 边界：纯搜证 + 假想验证，不执行训练/真实评测/数据生成。L11 产出 = 反巧合门的 spec 弹药。

## Summary（核心结论）

一次 C6 pass 严重高估真实可靠性。业界 2026 共识：用 **pass^k**（全 k 次都过的概率，`(c/n)^k`）衡量「一致性/反巧合」，而非 pass@k（capability，至少一次过）——二者随 k 发散，τ²-Bench 实证某模型 pass^1=81.6% 跌到 pass^4=56.1%（单跑高估 25pp），端侧小模型尤甚。

**MAformac 关键事实（本机坐实）**：`C6VehicleToolBench.swift` **已有 multi-run 管线**（`samplingSeed` fingerprint 字段 :621/:638 + `C6PerCaseStats.hardPassVariance` 按 caseID 分组聚合 :648,:1090-1101），但 **只记录不 enforce**——status 门只用 pooled `hardFailures==0`（:1088,:1103），runCount=1 时零一致性检查，`hardPassVariance` 是装饰性 metadata（= claim-vs-reality 铁律 1「record 不 enforce」活样本）。

**L11 = 把已有 variance 管线升级成 enforced 反巧合门**：pass^k 门 + 多 seed sweep（接 samplingSeed）+ base-vs-LoRA 配对 McNemar + 扰动不变性（PARA/SYNO）+ 不相关能力不退化。全是 dev-time 评测治理，**不碰 A2 surface、不引入训练**。它防的是「0/34 反面」：candidate 侥幸过 C6 而真实塌缩。

⚠️ 端侧 mlx `temperature=0` **也非确定性**（batch-invariance 问题）——反巧合门必须用「多 seed/多采样实测分布」，**不能假设确定性单跑**。

---

## Findings（每条带 source）

### F1 — pass^k 是反巧合正确指标，pass@k 高估
pass^k = `(c/n)^k`（全 k 次都过的概率）衡量一致性；pass@k = `1−C(n−c,k)/C(n,k)`（至少一次过）衡量 capability，会高估。τ²-Bench：某模型 Retail 域 pass^1=81.6% → pass^4=56.1%。compliance/客户面用 pass^k 设门（如 ≥0.95）。
- **source**: philschmid.de/agents-pass-at-k-pass-power-k + agentpatterns.ai/verification/pass-at-k-metrics（2026-06-24）
- **vs 现状**: better — C6 现状无 pass^k；引入后区分「侥幸过 vs 稳定过」。vs rank16Mainline = support（评测门正交配方）。confidence high

### F2 — 专门研究 tool-calling 一致性的 2026 论文
arXiv 2605.28840「How Consistent Are LLM Agents?」(Abel Yagubyan, 2026-04-23) 系统实证：重复同一调用，agent 是否选同样工具/顺序/参数。专门针对 typed parameter + 有副作用的**结构化 tool-calling**（= MAformac D-domain 具名工具形态），不只 ReAct。
- **source**: arxiv.org/abs/2605.28840（abstract 核实；全文细数未暴露 → external_claims）
- **vs 现状**: unknown（论文是方法论参照）；support rank16Mainline。confidence medium

### F3 — base-vs-LoRA 配对 McNemar 检验
同一 holdout 跑 base + LoRA → 2×2 列联表（都对/都错/仅base对/仅LoRA对）→ McNemar 检验 discordant cell 错误率是否显著改变。LoRA 可 merge 进 base 故配对干净（唯一变量=adaptation）。
- **source**: WebSearch 'LoRA ablation McNemar holdout 2026'（2026-06-24）；clinical cardiology 嵌入研究 matched holdout 实证
- **vs 现状**: better — C6 现状 base 10/23 vs LoRA 只比绝对计数无显著性检验；McNemar 给「提升是否显著非噪声」判据。support rank16Mainline。confidence high

### F4 — 扰动不变性证明非表面记忆
'Lost in Execution'(arXiv 2601.05366, Jan 2026)对 tool-calling 引 PARA(同义改写)+SYNO(同义词)扰动；LIBERO-Para(2603.28301, Mar 2026)实测 VLA 0.6B-7.5B paraphrase 退化 **22-52pp**(object-level 词汇变化=surface matching)；'A Single Character'(2510.05152)MMLU 仅换分隔符 ±23% 且不随规模改善。
- **source**: arxiv 2601.05366 + 2603.28301 + 2510.05152（2026-06-24）
- **vs 现状**: better — C6 现状每 case 单一表述，过了无法区分真泛化 vs 记话术；home-llm evaluate.py 单 accuracy 无扰动测(worse)。support rank16Mainline。confidence high

### F5 — prompt/tool list 顺序敏感
'The Order Effect'(2502.04134)实证打乱输入显著降准；开源模型仅格式差异 accuracy 摆动达 76pp；工具列表是有序输入会引选择偏置。缓解=多 permutation 聚合(permutation self-consistency 2310.07712)或 Set-LLM permutation-invariant 架构。
- **source**: arxiv 2502.04134v2 + WebSearch（2026-06-24，76pp 进 external_claims 待核）
- **vs 现状**: better — C6 现状工具列表顺序固定未测 distractor reorder。support rank16Mainline。confidence high

### F6 — temperature=0 在 mlx 上非确定性（硬约束）
根因不是 RNG/floating-point，是 batch-invariance 缺失(normalization/matmul/attention reduction 顺序随 batch 变)。Thinking Machines：80 completion 第 103 token 才发散；MLX 对 dtype 尤敏感，**量化是实用确定化路径**(社区 mlx-deterministic)。
- **source**: thinkingmachines.ai/blog/defeating-nondeterminism-in-llm-inference + adityakarnam.com/mlx-non-determinism-apple-silicon + github.com/ProbioticFarmer/mlx-deterministic（2026-06-24）
- **vs 现状**: better — 反巧合门【不能假设确定性单跑】，必须多 seed 测真实分布(L11 硬约束)。support rank16Mainline。confidence high

### F7 — iot-agent-bench 现成 N_SEEDS=3 + temp=0 配方
C6 蓝本 config.py:138 `N_SEEDS_FOR_VARIANCE=3` + :132 `AGENT_TEMPERATURE=0.0`（评测温度 0 求确定性 + 3 seed 看方差），对应 3HIGH「同 harness 多跑去污」。verify_gold 完美 agent 自洽守护证 bench 先过自己的考。
- **source**: 本机 docs/research/2026-06-20-teardown-iot-agent-bench.md:119,134,156（cite-verify 标注）
- **vs 现状**: better — MAformac 有 hardPassVariance 字段无 N_SEEDS sweep 无门；N_SEEDS=3 现成可 adopt。support rank16Mainline。confidence high

### F8 — 小样本 pass^k 统计不稳，须 Bayesian CI
少量任务+小 k 时两指标 CI 都很宽多被省略；Bayesian(Beta/Dirichlet 先验)给更稳排序+显式不确定性。pass^k 对最 flaky 测点敏感(一个 temp>0 judge 压垮)。
- **source**: WebSearch + ReliabilityBench(2601.06112) + 'Beyond pass@1'(2603.29231)（2026-06-24）
- **vs 现状**: better — C6 57 case 小集单跑无 CI；L11 必带 CI 不只点估计。support rank16Mainline。confidence high

### F9 — MAformac C6 现状：管线已在但只记录不 enforce（最 load-bearing）
`C6PerCaseStats.hardPassVariance/hardPassMean` 按 caseID 分组聚合(:1090-1101)；`samplingSeed` 必填(:621,:638)；但 status 门只用 pooled `hardFailures==0`(:1088,:1103)，runCount=1 零一致性检查，variance 从不进门。**无 pass^k / 无 per-case all-runs-pass / 无多 seed sweep**。
- **source**: 本机 Core/Bench/C6VehicleToolBench.swift:621,638,1088-1103（grep+read 坐实）
- **vs 现状**: worse than 应然 — variance 是装饰性 metadata(claim-vs-reality 铁律 1)。L11=升级成 enforced 门，复用现有 schema 改动小。support rank16Mainline。confidence high

### F10 — StableToolBench 一致性方法论（部分不适用）
ACL2024 Findings(THUNLP)证 tool-use eval 不稳两源=API 波动+evaluator 随机；虚拟 API server(缓存 96.7-97% 命中+GPT-4 simulator)+两阶段稳定 evaluator 把 50% API 失效下方差压极小。后续批评「只缓存稳定 API 不做 fault injection 也不测一致性」。
- **source**: arxiv.org/abs/2403.07714 + github.com/THUNLP-MT/StableToolBench（2026-06-24）
- **vs 现状**: better(部分不适用) — MAformac C6 mock 端态自包含天然消除 API 波动源(相对优势)；evaluator 随机源仍在(若用 LLM-judge)→借鉴 judge 确定性/异源。drop 虚拟 API server，adopt 一致性思想。confidence medium

---

## Clone / 蓝本发现

- **iot-agent-bench**(已 clone raw/.../ref-repos/iot-agent-bench，只读)：config.py N_SEEDS=3/temp=0 + verify_gold 完美 agent 自洽守护 = C6 反巧合门现成配方源。
- **home-llm**(已 clone ref-repos/home-llm)：`train/evaluate.py` 用 `do_sample=True, temperature=0.1, top_k=40, repetition_penalty=1.15`(L300-307)=**随机解码 + 单跑 + 无 seed 控制 + 无 variance**——正是 L11 要堵的「单 pass 当真学会」反面样本。MAformac C6 四层独立门 + alternatives + IrrelAcc 已远超 home-llm 单 accuracy(2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:105)。

## Paper 发现（核心 4 篇）

| arXiv | 标题 | 对 L11 |
|---|---|---|
| 2605.28840 | How Consistent Are LLM Agents?(2026-04) | tool-calling 一致性专论，typed param + 副作用形态，applicable=yes |
| 2601.05366 | Lost in Execution(2026-01) | PARA/SYNO 扰动测 tool-calling，applicable=yes(扰动不变性门) |
| 2603.28301 | LIBERO-Para(2026-03) | paraphrase 退化 22-52pp 诊断，applicable=yes(类比 caveat) |
| 2510.05152 | A Single Character(2025-10) | 单字符 ±23% eval 摆动，applicable=yes(格式扰动) |

---

## 假想验证（candidate 过 C6，怎么证明不是巧合）

**预测**：L11 反巧合门会抓出至少一类侥幸，最可能「pass^k 显著低于 pass^1」。依据：① pass^k 数学必然(per-trial 85%→pass^4≈52%)；② mlx temp=0 非确定性+端侧 8GB batch 抖动→多 seed 真实发散；③ 1.7B 极可能 surface matching(LIBERO-Para 0.6B-7.5B 全 22-52pp)，原句过同义改写塌=记话术。

**设计的反巧合 gate（成本/收益排序，全 dev-time）**：
- **G1 pass^k 一致性门(P1 最高)**：must-pass/golden case 跑 k=3-5，per-case all-runs-pass(pass^k=1≡variance==0)，不是 pooled hardFailures==0。golden 100% 硬门下尤其立。
- **G2 多 seed + temp=0 双轨**：温度 0 求确定性但 mlx 非确定性仍必多 seed(N_SEEDS=3 起；golden 5 seed/coverage 3 seed)，报 mean±CI。
- **G3 base-vs-LoRA 配对 McNemar(P1)**：把「18/23 vs 10/23」从绝对计数升级成统计判据。
- **G4 扰动不变性(P1，证非记忆)**：golden case 加 2-3 PARA+SYNO 变体(云 generator+异源 judge，对齐 retrain-c5 §2.2)，原句与变体 pass 一致才算真泛化。
- **G5 tool list/distractor reorder 稳定性(P2)**：重排顺序结果不变。
- **G6 不相关能力不退化(P1，防遗忘)**：held-out OOD probe(≠SFT 分布)，IrrelAcc 不降。

**失败模式**：
- F1 pass^k 被 flaky judge 压垮→先确定性化 harness(verify_gold 自洽守护)再立门。
- F2 端侧多 seed 跑太慢炸预算→分层(golden 5 seed+全变体/coverage 抽样 3 seed)，不全集×k。
- F3 k 太大+57 小集 CI 过宽→k=3-5+Bayesian CI，pass^k 当信号不当判据。
- F4 mlx 非确定性误诊为模型不稳→先固定 batch+量化压 harness 抖动再归因。
- F5 越界冲动(顺手训/测真实性能)→L11 只产 gate spec，真跑 DEFERRED。

**综合判定**：L11 better——把 hardPassVariance 装饰性 metadata 升级成 enforced 反巧合门，是 0/34「派生表征当一手」的评测端答案。最大价值=G1 pass^k + G4 扰动不变性。最大风险=F1+F2，靠分层+先确定性化 harness 化解。

---

## Pre-mortem 三分类

**🐯 Tiger**：
1. C6 hardPassVariance 算了不 enforce(:1088,:1103)→单跑即放行，0/34 式假胜利复发口。修=加 per-case pass^k 门。
2. mlx temp=0 非确定性→门假设确定性单跑则失效。修=先量化+固定 batch 压 harness 抖动，θ-α 端侧先跑 100 次数 unique。
3. 1.7B surface matching→单一表述测不出记话术。修=paraphrase 变体(属 DEFERRED，L11 只立门 spec)。

**🥷 Paper-tiger**：
1.「pass^k 看着差不该用」→看着低正是价值(诚实暴露缺口)，pass@k 高+pass^k 低=改一致性不重训。
2.「需从零造基建」→伪威胁，samplingSeed+hardPassVariance 管线已在，L11 是升级。
3.「与 L04 重复」→正交(L04 过没过/L11 过是不是巧合)，一个 candidate 可 L04 过 L11 塌。

**🐘 Elephant**：
1. mlx 量化是确定化路径——MAformac 端侧本要 4bit 量化，量化后 batch-invariance 抖动反小，端侧反巧合门可能比 dev bf16 更稳(意外红利)。
2. L11 paraphrase 测试集 = retrain-c5 数据管线的 held-out 切分(物理隔离=3HIGH 防死记 tau2 切分)，避免造两套数据生成。
3. MAformac readback 走方案 P 端 renderer(确定性)非 LLM judge→pass^k 比一般 agentic eval 更可信(harness 本身确定性)，是架构隐性优势。
4. 57 小集+端侧慢→k 小(3-5)+Bayesian CI，L11 诚实定位=暴露明显侥幸的粗筛门，非统计学论文级精度。

---

## Must-answer 5 答

1. **prevents_0_34**: partial——不能在训练时阻止(那是 L04/训练中途 gate)，但能在训练后验收阻止「0/34 反面假胜利」(侥幸单跑过却真实不稳/记话术)。是 0/34「派生表征当一手」评测端答案。P1(后置门)。
2. **vs_rank16mainline**: support——全评测层治理，与配方完全正交，反而强化配方守护(验证守 rank16Mainline 的 candidate 真稳还是侥幸)。
3. **requires_a2_surface_change**: no——复用 C6 现有 D-domain surface(samplingSeed/hardPassVariance 已在)，只加门判定逻辑，不改 A2 一字段。
4. **introduces_deferred**: yes(部分越界，已隔离)——真跑部分(变体生成/多 seed 真跑/真实性能测)DEFERRED 到 retrain-c5/rebuild-c6 propose；Phase 0 内只产门 spec+弹药(落 docs/research)。
5. **priority_self**: P1。

---

## External claims（待主线程核）

- arXiv 2605.28840 具体一致性指标公式/run-to-run 精确数字/推荐重复次数未在 abstract 暴露 → 引细节需 fetch 全文，勿凭 abstract 编数字。
- τ²-Bench 81.6%→56.1% 来自 philschmid/agentpatterns 二手引述 → load-bearing 核 τ²-Bench 原文。
- LIBERO-Para 22-52pp 是 VLA 非纯 LLM FC，迁移到 1.7B 文本 FC 是类比推断 → 标 caveat。
- 'The Order Effect' 76pp 摆动来自 WebSearch 综合转述 → fetch 2502.04134 核归属(可能是另一篇)。
- iot-agent-bench N_SEEDS=3/temp=0 来自本机 teardown 文档非直读 repo → 可 clone 核(repo 在 ref-repos/)。
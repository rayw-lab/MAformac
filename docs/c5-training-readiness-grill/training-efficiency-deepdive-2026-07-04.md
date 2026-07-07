# 训练效率 deepdive（commander 亲研，2026-07-04）

authority: research_deepdive_not_ssot（决策 SSOT=decisions.md + r2b grill；本档=效率策略弹药与优先级拍板依据）
proof_class: local 一手台账（R2a run 实测）+ 本地论文试跑档亲核 + web 一手（URL+日期）
辩证对象: codex 同日「训练效率 5 优先级」答复——逐条亲核其本地 cite（全真）后**采 3 / 收窄 2 / 驳 1**，最优策略以我的一手台账重排。

## 0. 先给结论（磊哥 TLDR）

**效率的最大杠杆已经在手里，而且正是 R2b 在做的事**：R2a 一手台账证明本管线 **99.3% 前向算力花在 mount prompt 上（ignored:trainable=142:1）**——「加高信息密度行」几乎不涨墙钟（每行监督面才 ~25 token），「加低信息行」纯烧 prompt 前向。所以：
1. **数据信息密度 = 第一杠杆**（R2b 两靶点=已兑现，无需新动作）
2. **中途行为门早停 = 第二杠杆**（R2B-7 已锁，坏方向省 2-3h）
3. **效率指标进 receipt**（supervised tok/s + ignored:trainable 两列，M.15 包络惯例扩展）——立即可做
4. LR sweep/packing/PEFT 全部**时机后移或 audit-only**（详 §3），R2b 单变量纪律不破

## 1. 一手台账（R2a run `20260703T231823`，全亲算）

| 指标 | 值 | 含义 |
|---|---:|---|
| 墙钟 | 13,138s（3h39m）/600 iters/150 updates | — |
| 累计监督 token（train.log Trained Tokens 终值） | **24,363** | 600 iter 只覆盖数据集监督面 119,571 的 **~20.4%** |
| 有效监督吞吐 | **1.85 tok/s**（24363/13138；per-iter 报告 mean 2.09/min 0.345/max 4.05） | 极低——因为分母都花在 prompt |
| ignored:trainable（数据集面） | 17,028,936:119,571 = **142:1（监督占比 0.7%）** | 🔴 算力去向的结构真相：mount 平均 13.85 工具/行的巨型 prompt |
| val 开销 | 4×~70s≈280s＝**2.1% 墙钟** | 非瓶颈，不动 |
| peak | 17.974GB（vs 停线 22.34） | 显存非当前瓶颈（T1 教训后已被 D2combo 驯服） |
| 单行成本结构 | 每行监督 ~25 tok vs prompt ~3,491 tok | **加 750 修复行 ≈ 只加 ~16% 行数前向，监督信息密度决定其价值** |

## 2. 效率杠杆排序（我的拍板，杠杆×风险）

| # | 杠杆 | 判 | 依据 |
|---|---|---|---|
| 1 | **数据信息密度/行**（近邻 contrastive+负行为面） | ✅ 已兑现=R2b 两靶点 | §1 成本结构：监督 token 便宜、prompt 前向贵 → 同等墙钟下 pair 化监督信号价值最高；W10 §2 280 contrastive 行=正解；R2a 实证 ~0.2 epoch 级监督覆盖就翻 A 轴行为（3→10）——**有效配方 ≫ 更多曝光** |
| 2 | **中途行为门+早停** | ✅ 已锁 R2B-7 | checkpoint 50/100 A 轴 15 case 快探 ~6min（%43 SOP）；坏方向省 2-3h；本地 deepdive L05 早列 P0（`docs/research/2026-06-24-lora-zero-failure-deepdive/README.md:17` 亲核） |
| 3 | **效率指标进 receipt**（新增，立即做） | ✅ 本档拍 | train receipt 资源包络两列（M.15）扩为四列：+`supervised_tok_per_sec` +`ignored_trainable_ratio`；「X 分钟训练」不再是效率口径，「监督 token 吞吐」才是 |
| 4 | **mount/prompt 端瘦身**（142:1 的理论最大杠杆） | 🔴 冻结，标 R3 grill 议题 | mount 面=判定面设计+eval 可比性——R2a 刚为「mount 擅改」回滚（D-083）；任何 mount 变更=单变量纪律级议题，**收益最大但此刻动它=毁归因**；R3 若立项必带 premortem（curriculum mount 分层 vs 判定面弱化风险） |
| 5 | **LR sweep** | ⏸ 时机后移（R2b 不做） | 详 §3 codex-P3 辩证 |
| 6 | **padding/packing** | ⏸ audit-only | 详 §3 codex-P4 辩证 |
| 7 | QLoRA/DoRA/新 PEFT | ❌ 维持 DEFERRED | deepdive §四 escape hatch 条件未触发（`README.md:58` 亲核：rank16 主线+DoRA-rank8 唯一逃生口，先排除数据/门根因才 reopen） |

## 3. codex 5 优先级辩证判定（逐条亲核后）

| codex 主张 | 判 | 理由（cite） |
|---|---|---|
| P1 管 trainable tokens 指标 | **采+加码** | 其 cite 真（ledger 44,459→113,914=2.56x，`token-budget-supervision-ledger-2026-07-03.md:24` 亲核）；我加码=进 receipt 成常设两列（§2#3），且把「监督占比 0.7%」这个结构真相补上——codex 只看到了 trainable 涨，没算 ignored 占比才是算力去向 |
| P2 中途行为门 | **采（=重申已锁项）** | R2B-7/D-086 已锁；deepdive L05 P0 亲核一致。非新增动作 |
| P3 小 LR sweep > 换结构 | **方向采、时机驳** | 论文真（arXiv 2602.04998 "Learning Rate Matters"，2026-02-04/v2 05-19，亲核 abstract：调优 LR 后各变体峰值差 1-2% 内）+ 本地 trial-run 亲核（`learning-rate-matters-vanilla-lora-may-suffice.md:40-50`：LR/batch/rank/duration 必须同记）。**但塞进 R2b=破坏单变量归因**（与 mount 回滚同理）：R2b 是数据修复验证轮，变量序不能倒（先修数据、后调 LR）。收法=R2b 守 1e-4（R2a 实证健康收敛 val 0.0247）；R2b PASS 且出现「行为门边缘徘徊」证据时，正式训练前做 2-point spot（5e-5 vs 1e-4，各跑到 ckpt50 行为快探 ~74min，非全量 sweep） |
| P4 padding/packing audit | **收窄采（audit-only）** | mlx-lm 官方 LORA.md 无 packing（亲核：只建议拆长样本+grad-checkpoint）；packing 在第三方栈（mlx-lm-lora/MLX-LoRA-Studio）=换训练栈，违 M.17（已验证脚本=basis）+basis 迁移成本；且本管线 `token_budget_per_batch=8192` 变长 microbatch **本身已是近似 bucketing**（padding 浪费先量化再谈）。动作=一个 padding-waste 审计脚本，>20% 浪费才立项；文献锚：best-fit packing 可把 padding 浪费 75%→<12%（Chronicals，arXiv 2601.02609），但那是 CUDA 栈数据点非 MLX 承诺 |
| P5 数据效率>样本量 | **采（=已锁项）** | W10/R2B-1 已锁；我的 §1 成本结构给了它定量根基 |
| 门径「S1 150 训练→LR sweep→full」 | **驳** | S1 不训已拍（D-086，150 行短窗行为移动期望低=D-082 同款论证）；sweep 时机见 P3。正确门径=D-086 执行序（S1 生成校准→full 750→gate packet→full pack 短训→双轨 eval） |
| 不做三件（train-health≠behavior green/不砍负例/不切 PEFT） | **全采** | 与 M.18/W10 envelope/deepdive §四 逐条一致 |

## 4. 落地动作清单

| 动作 | 时机 | 归属 |
|---|---|---|
| receipt 效率两列（supervised_tok_per_sec / ignored_trainable_ratio） | R2b train receipt 起 | commander 写 receipt 时执行 |
| checkpoint 50/100 行为快探（A 15 case + interface/airoutlet + query_vs_adjust spot） | R2b 短训中 | 已锁 R2B-7 |
| padding-waste 审计脚本 | R2b 短训期间顺产（不阻塞） | 可派 worker |
| 2-point LR spot（条件触发：R2b PASS 且行为门边缘） | 正式训练前 | commander 拍触发 |
| mount 端瘦身/curriculum 议题（142:1 杠杆） | R3 grill（带 premortem） | 冻结至 R2b 收口 |
| QLoRA/DoRA | DEFERRED（escape hatch 条件不变） | — |

## 5. 外部 source 台账（本档引用，全亲核）

- arXiv 2602.04998 "Learning Rate Matters: Vanilla LoRA May Suffice for LLM Fine-tuning"（2026-02-04，v2 2026-05-19）—— WebFetch abstract 亲核 2026-07-04
- mlx-lm 官方 `LORA.md`（ml-explore/mlx-lm）：拆长样本/grad-checkpoint 建议、无 packing 特性 —— WebSearch 亲核 2026-07-04
- arXiv 2601.02609 Chronicals：best-fit packing padding 浪费 75%→<12%（CUDA 栈数据点）—— WebSearch 2026-07-04
- 第三方 MLX packing 存在证明：Goekdeniz-Guelmez/mlx-lm-lora、MLX-LoRA-Studio（packing 选项）—— WebSearch 2026-07-04（换栈成本判定见 §3-P4）
- 本地一手：R2a train.log/metrics.jsonl（吞吐/覆盖率亲算）、token-budget-supervision-ledger、lora-zero-failure-deepdive README、paper-to-skill-gate trial-runs ×2

# LoRA 小模型训练 — 4 个核心知识点(磊哥复习用)

> 2026-06-21 grill MAformac C5 LoRA 时讲透的 4 个 LoRA 原理,抽出来做复习教材。
> 配套看:决策口径 `grill-decisions.md`、调研全料 `README.md` + 7 个 lensN 档。
> 实测背景:Qwen3-1.7B-4bit / mlx-lm 0.31.1 / Mac M5 32GB / 中文车控 function-calling LoRA。
> **本文讲"为什么"(原理),决策"拍什么"看 grill-decisions.md。**

---

## 0. 先建立大图:LoRA 到底是什么

- **base 模型冻结**(Qwen3-1.7B 全部 17 亿参数锁死不动),只额外训练一个**低秩增量**(rank16 时仅 17.4M 参数 = 占 base 的 **1.013%**)。
- LoRA 学的是**"风格/映射"**(模糊中文 → 该调哪个工具),**不是往模型灌新知识**。
- 数学形式:`输出 = base(x) + (alpha/rank) × B·A·x`。`A`、`B` 是两个小矩阵(低秩),`alpha/rank` 是缩放因子。
- **为什么端侧选 LoRA**:base 冻结 = 不破坏原模型的中文/通用能力(天然抗灾难遗忘);增量小 = 训练快、可多个 adapter 切换、端侧加载省内存。

这决定了完善 LoRA 的逻辑:**靠数据教它见过更多说法**(它只会见过的),不是堆参数;核心矛盾永远是**泛化 vs 死记**。

---

## 1. 学习率(LR) — LoRA 最敏感的旋钮

**原理:** LR = 每一步沿梯度方向走多大一步。
- 太大 → 步子跨过 loss 盆地的最低点 → 在盆壁来回震荡,甚至越爬越高(发散)。
- 太小 → 走得太慢,且会把"LR不够/数据不行/mask不对/模型学不会"搅成**混合噪声**,破坏诊断(你没法判断到底卡在哪)。

**MAformac 实测铁证(同一份数据):**
| LR | iter30 | 峰值后 |
|---|---|---|
| 1e-4 | loss 1.069→0.8 | 稳定 0.6-1.5 ✅ |
| 2e-4 | (爬到峰值)→ | iter70 炸 17.5 → 32 ❌ |

→ **1e-4 是甜区,2e-4 是压垮点**。判据(mlx-lm 官方):**训练"中途"出现 loss 尖刺 = LR 太高;"从一开始"就高(>10)= 数据/格式坏**。

**warmup + cosine 的作用:**
- **warmup**:开头用极小 LR(如 8e-6)让优化器先"摸清地形",再逐步爬到峰值。避免冷启动时大梯度直接炸。
- **cosine decay**:峰值后按余弦曲线缓降,后期小步精修,帮收敛。
- ⚠️ 单位坑:mlx-lm 的 schedule 步数是 **optimizer update** 不是训练步;grad_accum=4 时 600 步只有 150 个 update,warmup 要按 update 算。

**LoRA 特有(为什么比全量微调更要压 LR):** 有效 LR 还被 `alpha/rank` 放大(MAformac 2.0×)。所以名义 2e-4 实际作用更强 → 小模型 LoRA 普遍比全量微调用更低的峰值 LR。

**记忆点:** 第一刀走**已验证的甜区**(1e-4),把更保守的值(5e-5)设成**自动熔断后备**,不当首选——因为太保守会制造混合噪声破坏诊断。

---

## 2. 梯度裁剪(gradient clipping) — 熔断保险丝

**原理:** 给每一步梯度的**总范数(L2 norm)设上限 max_norm**。某步范数超过上限 → 按比例缩回上限,**方向不变、大小封顶**。

**LR vs clip(两个不同的事):**
- **LR 管"正常步子多大",clip 管"异常步子的天花板"**。
- 即使 LR 合适(1e-4),偶发一个"坏 batch"(如脏数据/占位符 bug)会让单步梯度爆炸 → 一步把权重推到崩坏区。clip 是这个的熔断保险丝。

**为什么 stock mlx-lm 要手动加:**
- mlx-lm 的 `mlx_lm.lora` 是**命令行黑盒**,只暴露 `--learning-rate` 这种旋钮,**不暴露训练循环内部**。
- 它的训练 step 是 `@mx.compile` 装饰的**内嵌闭包**(`trainer.py:234`),`optimizer.update` 在闭包里(`:245`),从外部 hook 不了。
- 所以"加梯度裁剪" ≠ 加个参数,而是**得先把训练循环拿到自己手里**(自有 training loop,复用 stock 的数据/schedule building blocks,只重写外层循环插 `finite_check → clip_grad_norm(1.0) → optimizer.update`)。
- max_norm=1.0 是 LLM 训练 de-facto 标准(QLoRA 论文用更激进的 0.3)。
- **额外白赚**:`clip_grad_norm` 返回裁剪前的 `total_norm` → 这是最早的**发散前兆指标**(grad_norm 突然 spike 常先于 loss 变 NaN)。

**1609 实测的启示(重要):** 光是 LR1e-4 + adamw,loss 就已经稳了(没加 clip)。所以 clip 从"救命"降级为**"保险丝"**——dry-run 上不加也能跑,但仍值得做,因为:① loss 发散的自动熔断规则依赖 grad_norm 监控 ② 真数据(更杂)可能有坏 batch 需要熔断。

---

## 3. dry-run loss 的诊断边界 — 拿对尺子

**原理:** 训练数据的 loss 有两层信号,要分清:
- **"训练系统报警"信号**:LR 过冲、NaN/Inf、masking 失效、clip 未接入 —— 这些**工程健康**问题,dry-run 数据照样能暴露。
- **"模型能力诊断"信号**:rank/target/epoch 合不合理、模型听不听得懂中文 —— 这些需要**真实数据**才有意义。

**关键边界(MAformac):** 当前 smoke 跑的是 **dry-run deterministic 协议串**(`device=X;primitive=Y;…` 模板,非真口语)。它的 loss:
- ✅ **有"训练系统报警"价值** —— 我们正是靠它的 loss 发散发现 LR 过冲的(逻辑自洽:如果它完全无诊断价值,"LR 过冲"这个结论就站不住)。
- ❌ **无"能力诊断"价值** —— 不能用它判断 rank16 够不够、要不要改 epoch(那是在调"模型背模板背得好不好",不是"听懂中文调对工具")。

**落点:** dry-run loss 只**触发**工程健康排查(LR/NaN/masking/clip),**不触发**配方结构重构(rank/target/epoch)。配方结构项要等**云多源真口语数据 + C6 eval(真能力信号)**才有资格动。

**记忆点:** 用 dry-run loss 调 rank = **拿错尺子量错东西**。

---

## 4. rank / target_modules / epochs — 三个反直觉

**① target_modules:全 7 个(attn q/k/v/o + MLP gate/up/down)是正解,不是"太激进"。**
- 直觉:"只训 attention 更省更稳"。
- 真相:**FC/结构化输出任务,"工具映射"这种知识主要存在 MLP 层**,只训 attention 学不到"这句话→哪个 tool"。多路一手证据(QLoRA / Biderman 2024 / ThinkingMachines / Amazon)一致:结构化任务 **attn-only 全面劣于含 MLP**。

**② rank16 不是"太小"。**
- 直觉:"rank 越大学得越多"。
- 真相:rank = 低秩增量矩阵的秩 = **能学多复杂的映射**。单跳 FC(一句话→一个 ToolCall)映射本身简单,rank16 够;只有多跳推理 FC 才需 rank≥32。**真瓶颈是数据多样性(见过多少种说法),不是 rank(能学多复杂)** —— 堆 rank 救不了数据单一。

**③ alpha/scaling 的"假结论陷阱"(最值得记):**
- `输出 = base + (alpha/rank)×BA`,`alpha/rank` 是缩放因子。MAformac alpha32/rank16 = 缩放 **2.0**。
- 如果升 rank32 但 **alpha 仍 32** → 缩放变 **1.0**(砍半)→ rank32 表现可能反而**不如** rank16,但这是**缩放被稀释,不是 rank 不行**。
- 正确做法:rank32 时 alpha 同步→**64**(保持 2.0),或开 **rsLoRA**(用 √rank 缩放)。否则 A/B 实验直接得出假结论。

**④ epochs:LoRA 小数据常 1-3 epoch,但必须配 val 早停。**
- 直觉:"train loss 还在降就继续训"。
- 真相:**train loss 对"记忆 vs 泛化"无区分力**(模型死记和真泛化会产生相同的 train 曲线)。只有 **val/held-out loss** 能区分——val 回升而 train 继续降 = 过拟合(死记)。
- 所以 epoch=3 安全的前提 = **有 held-out val 集 + 有 early-stop 机制**(val 回升即停、取 best checkpoint),否则降 epoch=2。

**⑤ 架构保证(为什么 MAformac 敢用 rank16):**
- MAformac 架构铁律:**结构化骨架把 multi-turn 降维成 single-turn**(确定性批量编排)+ **短期记忆走 query rewrite + 槽继承**。
- 二次交互(`second_turn_refs`)**不让模型跨轮记忆**,而是走 C1 sidecar(`semantic-followup-transitions.jsonl`)+ C4 槽继承/query rewrite **压成单跳**喂模型。
- → rank16 的"单跳 FC"假设**有架构保证**(多跳被 code 编排吃掉,模型只做单跳),不是赌的。

---

## 附:完善 LoRA 的 5 个杠杆(大图)

| 杠杆 | 大小 | 一句话 |
|---|---|---|
| ① 数据 | ⭐⭐⭐⭐⭐ | 错误分析→补真口语变体;越小的模型越吃多样性 |
| ② 超参 | ⭐⭐ | 当前只 LR 要动;rank/target/epoch 是正解别动 |
| ③ 评测 | ⭐⭐⭐⭐ | held-out 三轴切(换说法/没见过arg值/按bug_id分层)防死记 |
| ④ 架构 | ⭐⭐⭐⭐ | LoRA 只碰 20%,规则/受限解码/落域都是杠杆 |
| ⑤ 端侧 | ⭐⭐⭐ | fuse 4bit 静默掉点 + train/serve parity = 误差累积链 |

# mlx-swift / mlx-lm LoRA 训练质量管控（Quality Control / Validation / Health Gates）

> 调研 · 2026-06-22 · MAformac C5 θ-α LoRA 训练 · 为「防再次 0/34」加质量门
> 方法：本机 mlx-lm 0.31.1 源码逐行坐实 + 30+ 次 WebSearch/WebFetch + `gh` 核 issue/freshness（github-first）
> 关系：**承接** 2026-06-21 7-lens 调研（`~/workspace/raw/05-Projects/MAformac/research/2026-06-21-lora-training-pitfalls/`，训练稳定/parity/masking 已深挖）；本档**聚焦 0/34 灾难暴露的新缺口 = 边训边评的语义/行为门**（训练健康但能力塌缩，loss 全绿审计全 PASS 却 28/34 吐空）。

---

## 0. 一句话结论（给主线程）

**0/34 不是训练健康问题（那部分 codex 诚实合规），是【语义/行为 eval 门缺位】——loss/grad/审计全绿，但没有一个门在「训练边缘」实跑生成、抓「adapter 吐空/塌缩/行为没变」。** 现成 mlx 工具（stock mlx-lm 0.31.1 + mlx-lm-lora 383★）**都不提供**这个门——MAformac 的 `c5_mlx_train_loop.py` 已自建 grad-clip/NaN-guard（训练稳定层够了），但**必须自己加三个新门**：① 差分生成门（base vs LoRA greedy 必须不同 + logits delta）② 受控记忆测试 + 存盘前 in-memory 验证（resolve.ai 实证 300x gap 探子）③ adapter 权重健康（`lora_B` norm>0 + 空输出率/有效秩）。这三个门若早在 θ-α 就有，0/34 会在训练当场暴露而非通宵 wave 跑完才发现。

---

## 1. 本机 mlx-lm 0.31.1 原生能力 vs 要自己加（事实层，源码坐实）

> 文件：`/Users/wanglei/Library/Python/3.13/lib/python/site-packages/mlx_lm/`（version 0.31.1 已 `python3 -c import mlx_lm` 坐实）

### 1.1 stock mlx-lm `tuner/trainer.py` 逐行核（一手，非推测）

| QC 能力 | 原生有？ | 证据（file:line） |
|---|---|---|
| **梯度裁剪 clip_grad_norm** | ❌ **无** | `trainer.py:234-248` `step()` 直接 `optimizer.update(model, grad)`，无 clip。`grad_checkpoint`(:20-33) 是**显存** checkpointing 不是 clip |
| **NaN/Inf 检测/熔断** | ❌ **无** | 全文件 grep 无 `isnan/isinf`；loss 出 NaN 照常 update 污染权重 |
| **early stopping / patience** | ❌ **无** | `train()` 主循环(:259-366) 跑满 `args.iters` 不看 val 趋势 |
| **best-checkpoint 选择** | ❌ **无** | `:356-362` 仅每 `steps_per_save` **定期存** `{it}_adapters.safetensors`；不比 val、不 load-best。默认拿 **last** adapter |
| **训练中生成式 eval** | ❌ **无** | `evaluate()`(:165-201) **只算 loss**，不 generate、不看输出文本 |
| **loss-spike watchdog** | ❌ **无** | 无任何"loss 飙到 Nx 就 abort"逻辑 |
| **mx.random.seed** | ❌ **不调** | 只 `np.random.seed`(:127-128) 做 batch shuffle；CLI 入口须显式三 seed（lens4 已记） |
| val loss 报告 | ✅ 有 | `:272-301` 每 `steps_per_eval`(默认 200) 算 val loss + callback `on_val_loss_report` |
| 定期 checkpoint 存盘 | ✅ 有 | `:356-362` 每 `steps_per_save`(默认 100) 存 |
| WandB/SwanLab 回调 | ✅ 有 | `callbacks.py` `WandBCallback`/`SwanLabCallback`（云上传，违离线红线） |

### 1.2 stock `lora.py` CLI 暴露的 flag（核 `lora.py:59-188`）

- ✅ `--mask-prompt`（loss 掩码，**只对最后一条 assistant 算 loss**，单区间，lens5 已证）
- ✅ `--test` / `--test-batches`（训练后在 test.jsonl 上算 loss——**注意：仍是 loss，不是任务指标/生成**）
- ✅ `--val-batches` / `--steps-per-eval` / `--learning-rate` / `--grad-checkpoint` / `--grad-accumulation-steps`
- ❌ **无** `--grad-clip`（mlx-vlm 才暴露；mlx-lm 没有）、无 early-stop、无 best-checkpoint、无 task-metric eval

### 1.3 `fuse.py`（端侧落地关键）

- `fuse.py:42,68-79`：支持 `--dequantize`，对每个有 `fuse` 方法的 linear 调 `m.fuse(dequantize=args.dequantize)`。这是 **#654 掉点的唯一原生 workaround**（fuse 进 4bit base 抹行为）。

### 1.4 横向：mlx-lm-lora（Goekdeniz-Guelmez/mlx-lm-lora，383★，pushedAt 2026-06-16，**活跃**）

> github-first 核：`gh repo view` 确认 383 star + 2026-06-16 push（<60 天，活跃）。

- 它**多**的：QAT（`--qat-enable/--qat-bits/--qat-group-size/--qat-start-step/--qat-interval`，量化感知训练，端侧 4bit 友好）、DPO/ORPO/GRPO/PPO、`judge.py`/`train_judge.py`（LLM-as-judge）。
- 它**仍没有**的（WebFetch 核 `sft_trainer.py` 源码）：**grad-clip / NaN-guard / early-stop / best-checkpoint / 生成式 eval / loss-watchdog 一个都没有**——和 stock 一样只有 loss 报告 + callback hook。
- **结论**：mlx-lm-lora **不解 0/34 缺口**。它的 **QAT 值得 P2 考虑**（端侧 parity 掉点，§5），但质量门要素 MAformac 自己造。MLX-LoRA-Studio（184★，同作者 GUI wrapper）同理——GUI 化不等于多质量门。

**Source（本路）：**
- mlx-lm trainer.py（本机一手 file:line，0.31.1）
- mlx-lm LORA.md https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md （2026-06）
- mlx-lm-lora https://github.com/Goekdeniz-Guelmez/mlx-lm-lora （383★，2026-06-16）；sft_trainer.py raw 核
- mlx-lm-lora PyPI https://pypi.org/project/mlx-lm-lora/

---

## 2. 七路 findings（每路带 source URL + 日期 + adopt/adapt/drop for θ-α）

### 路 1 — 训练健康监控：发散/NaN/grad-spike 早期信号 + 自动熔断

**核心发现：**
- **grad-norm spike 是 NaN 最早前兆**——监控 loss/grad-norm/**param-norm** 三信号（Brenndoerfer "Training Stability"）。clip_grad_norm(1.0) 是第一道防线，但**clip 在反传后**，**救不了当前 batch 内已生的 NaN/Inf**——需配 finiteness check + skip bad step（DataCamp / Modexa）。
- **fixed threshold 会随训练 grad-norm 下降而失效** → 业界转 **EMA/3-sigma 自适应阈值**（Open-Sora Plan）或 **SPAM**（spike 时 reset 优化器动量 + spike-aware clip，arXiv 2501.06842, ICLR 2025，实测 grad spike 可达正常 1000×）/ **Stable-SPAM**（4-bit 比 16-bit Adam 更稳，AdaClip 自适应裁剪 + AdaGN 按历史 norm 归一化，arXiv 2502.17055, 2025-02）。
- 🔴 **LoRA 特有**：PEFT #3073 实证「LoRA α/r 缩放 × 各层激活 norm 差 10-100x → 前几步 grad 爆 → NaN，**clip_grad_norm=1.0 没用**，要按 input-energy 归一化 grad」。即 **step 1-5 就 NaN ≠ spike，是激活依赖梯度** → skip-batch 救不了，要降 LR / 调 adapter。
- **Axolotl `loss_watchdog`**（最实用的现成自动熔断）：`loss_watchdog_threshold`（建议 ≈ 训练起始 loss 的 **2x**）+ `loss_watchdog_patience`（连续高 loss 步数，默认 **3**）→ 自动 abort。这是「发散自动熔断」的可移植配方。

**adopt/adapt/drop for θ-α：**
- **adapt**：MAformac `c5_mlx_train_loop.py` 已有 `clip_grad_norm` + `global_grad_norm` + `nonfinite-fallback-lr` + `nonfinite_stop` 事件（superaudit 核实，但**clip 路径从未真跑** = P1）→ **θ-α 必须让 clip 路径真跑 ≥60 iter 过 warmup 进 peak**（验 preclip norm 实测 193/366 远超 1.0 → clip 必触发）。
- **adopt**：加 **Axolotl 式 loss_watchdog**（loss > 2× 初始 loss 连续 3 步 → 写 `divergence_abort` event + 停）——零成本，直接进 train loop。
- **adopt**：监控**三信号**（loss + grad-norm + **param/adapter-norm**）写 metrics.jsonl，不只 loss。
- **drop**：SPAM/GradientStabilizer（过度工程，θ-α 用降 LR 1e-4 + clip 已够；新≠强）；EMA 自适应阈值（solo 单 run 固定 2x watchdog 够，不需 3-sigma）。

**Source：** Brenndoerfer https://mbrenndoerfer.com/writing/training-stability-loss-spikes-gradient-norm-debugging | Rohan Paul https://www.rohan-paul.com/p/stabilizing-llm-training-techniques | SPAM arXiv 2501.06842 (ICLR 2025) | Stable-SPAM arXiv 2502.17055 (2025-02) | PEFT #3073 https://github.com/huggingface/peft/issues/3073 | DataCamp grad clip https://www.datacamp.com/tutorial/gradient-clipping | Axolotl config-reference https://docs.axolotl.ai/docs/config-reference.html

---

### 路 2 — checkpoint selection / early stopping：选最优 checkpoint（val loss vs 任务指标）

**核心发现：**
- **stock mlx-lm 无 load-best**（§1.1 坐实），照默认拿 **last** adapter——last ≠ best，小数据 LoRA 1-3 epoch 内从「学」转「记」，last 可能已过拟合/塌缩。
- 🔴 **loss-metric mismatch**（arXiv 2602.22107 "Don't stop me now: Rethinking Validation Criteria"）：cross-entropy val loss **可能选不到任务指标最优的 checkpoint**。**端目标是任务指标（FC 准确率/IrrelAcc）就该按任务指标在 val 上选**，不是按 val loss。
- **多任务/多轴尤甚**：不同 task loss 尺度不同，task accuracy 恒 0-1 更可比（SiRA：每 100 步 decode val 选 best-by-score）。
- **单任务生成式微调**：val loss + early-stop（plateau N 次 eval）仍是标准低成本默认（EnergyGPT/LLaMA-Factory `metric_for_best_model: eval_loss`）。
- **2025 validation-free 新法**：UGCS（arXiv 2511.09864）用训练日志里的 per-sample 不确定性选 checkpoint（RL 微调用，θ-α 不命中）。

**adopt/adapt/drop for θ-α：**
- **adopt（核心）**：θ-α **按任务指标选 checkpoint，不只 val loss**——每 N 步在 held-out probe 上跑 **ToolCall 集合精确匹配 + 空输出率 + IrrelAcc**，metrics.jsonl 记每个 checkpoint 的这些数，**最后比着挑 best-by-task-metric**（不是 last，不是 best-val-loss）。这正是 0/34 会暴露的门：last/best-val-loss 都可能是塌缩的那个 checkpoint。
- **adopt**：early-stop = **任务指标**（空输出率 > 阈值 或 ToolCall-exact 连续不升）N 次 eval 即停，不只 val-loss-plateau。
- **adapt**：`steps_per_eval` 从默认 200 调到 **每 ~50-100 步**（θ-α 4500×3epoch，200 步只 eval ~几次，抓不到拐点）。
- **drop**：UGCS（RL 法，SFT 不命中）。

**Source：** "Don't stop me now" arXiv 2602.22107 | SiRA arXiv 2311.09179 | UGCS arXiv 2511.09864 (2025) | EnergyGPT arXiv 2509.07177 | Unsloth fine-tuning guide https://unsloth.ai/docs/get-started/fine-tuning-llms-guide

---

### 路 3 — 训练中 eval 集成：边训边评 FC/ToolCall 准确率（防 loss 降但能力塌）★ 0/34 核心缺口

**核心发现：**
- 🔴 **"clean loss curve ≠ healthy model"**（resolve.ai "debugging silent performance gap in distributed LoRA"）——**完全是 0/34 的形态**：loss 干净收敛、生成看着对，但 eval 分数远低于 loss 暗示。**他们的探子方法值得直接移植**：
  1. **per-token logprob heatmap，base vs LoRA 同数据并排**——发现「trained model 和 base 几乎无区别」（adapter 没真改行为）。
  2. **受控记忆测试**：在小数据集上训到收敛，再问模型能否在推理时复现训练数据 → 实测 **train loss ~1e-4 vs inference loss ~0.03 = 300x gap**，直接暴露 checkpoint corruption（两 TP rank 的 adapter shard 同名被静默丢一个）。
  3. **核心修法**：**存盘前做 in-training validation**（在内存模型上验），对比「存盘前 in-memory」vs「存盘 load 后」性能，抓 save/load 不一致。
- **Axolotl `eval_table_size` + `eval_max_new_tokens`**（最现成的边训边评生成）：eval 时 generate ~3-10 条样本 log128-512 token，落 W&B table 肉眼看塌缩。**坑：慢**（`eval_table_size:100`+`1024 token` 让 eval 时间暴涨，#949）→ size 控 3-10。
- **histogram-based 退化检测**（TeleDoCTR, arXiv 2601.00691）：病态输出（字符/token 过度重复、空串）频率分布异常偏斜 → **比生成输出 vs ground-truth 的归一化字符直方图，差异超阈值即标病态**。FC 结构化输出（JSON tool_call）尤其适合这种 schema/直方图校验。
- **LLaMA-Factory 坑**：`predict_with_generate` **训练期不能开**（`ValueError: cannot be set as True while training`，#1104/#1603）→ 等价做法 = 频繁 checkpoint + 单独跑 `_predict` YAML 在每个 checkpoint 上生成对比。
- **forgetting 研究证**：collapse 常**不在 eval loss 显现**（rank64+3epoch LoRA/DoRA 都灾难遗忘）；in-domain val 指标还在升，**通用/参考任务**已塌（512 样本 reference acc 已 <20%）→ **必须 held-out capability probe ≠ SFT 分布**才照见。

**adopt/adapt/drop for θ-α：**
- **adopt（最高优先，直接堵 0/34）**：θ-α train loop 每 N 步在 **held-out probe（~30-50 条，含 positive FC + irrelevance + 二次澄清）** 上**实跑生成**，计 3 指标：**①空输出率（empty/repeat 占比）②ToolCall 集合精确匹配率 ③IrrelAcc**。**空输出率 > 阈值（如 >5%）→ 立即 `capability_collapse` event + 可选 abort**。这是 stock/mlx-lm-lora 都没有、必须自建的门。
- **adopt**：**存盘前 in-memory 生成验证**（resolve.ai 修法）——每次存 adapter 前，在内存模型上跑 probe 生成，把这批结果 hash 进 receipt；**端侧/重 load 后再跑同 probe 对账**（堵 save/load + fuse 静默掉点，§5）。
- **adopt**：**受控记忆 sanity**（θ-α 起手一次）——拿 ~20 条训练样本训到 overfit，验推理能复现（loss gap < 阈值），坐实 pipeline 无 checkpoint corruption / adapter 真生效（这是 §1.4 superaudit 没覆盖、resolve.ai 实证有效的「pipeline 体检」）。
- **adapt**：histogram/schema 校验作空输出门的判据（字符频率偏斜 + JSON 可解析 + tool_call schema 合法）。
- **drop**：Axolotl/LLaMA-Factory 框架本身（CUDA，Mac 不可用，lens3 已证）——只**移植它们的判据/cadence 思想**（eval_table 生成 + loss_watchdog + checkpoint-then-predict）进 MAformac 自己的 mlx 循环。

**Source：** resolve.ai https://resolve.ai/blog/debugging-performance-gaps-in-scaling-LoRA-training | TeleDoCTR histogram 退化检测 arXiv 2601.00691 | Axolotl eval_table https://docs.axolotl.ai/docs/config-reference.html + #949 https://github.com/axolotl-ai-cloud/axolotl/issues/949 | LLaMA-Factory predict_with_generate #1104 https://github.com/hiyouga/LLaMA-Factory/issues/1104 | 数据稀缺 LoRA 遗忘 arXiv 2511.00130 | 医学 VLM mode collapse（"全答 Yes"）arXiv 2603.00148

---

### 路 4 — LoRA 特有质量管控：adapter 秩坍缩 / collapse 检测 / 空输出率 / wrapper drift

**核心发现：**
- 🔴 **PEFT 默认 init `lora_B`=0**（identity transform）→ **训练/存盘出岔，adapter 权重可能全零，train/val loss 照降，但 PEFT 模型 = base（literal no-op）**（PEFT #1402 "weights remain zero after deepspeed"）。**最便宜的 collapse 检测 = 断言 `lora_B` norm > 0**。
- **LoRA output norm → 0 = collapse 早期信号**（text-to-3D 蒸馏 arXiv 2507.09748：画 adapter output norm 曲线，norm 速降到 0 = ill-posed 收敛 = adapter 吐空贡献）。**过激优化（高 LoRA 步数）驱动 norm-to-0；降 LR 缓解**。
- **mode collapse = loss 函数有 trivial 解**（医学 VLM 纯一致性 loss 训 1 epoch → 模型「对所有问题答 Yes」，trivially 最小化 loss 但毁判别力）。FC 对应：塌成单一重复 token / 空串 / 一个常量响应。
- **有效秩（effective rank）= 检测秩坍缩主指标**（ER = exp(Shannon 熵 of 归一化奇异值)）；**stable rank** = ‖W‖²_F/‖W‖²₂；**奇异值快速衰减 = 秩坍缩**（r=512 实得 ER~60）。但 🔴 **秩坍缩常是 α 缩放伪影**：α 固定时高 rank LoRA 收敛到低秩解 → **α=2r 关键**（Biderman）。
- **谱几何编码训练目标**（arXiv 2604.08844, 2026-04）：per-layer 谱特征（norm/stable-rank/奇异值熵/effective-rank/奇异向量 cos 对齐健康质心）可分类 adapter drift（DPO 内 AUC 1.00）。**"LoRA 有 visibility 问题：loss 降、eval 看着对、你 ship，但决定 adapter 是否高效/可合并的奇异值谱，标准 pipeline 不给你看"**。
- **输出多样性方差缩减 = 文本生成 collapse 信号**：同 prompt 跑 10 次输出聚得紧 ≠ 质量，是失了 range。

**adopt/adapt/drop for θ-α：**
- **adopt（零成本必加）**：存盘 + 端侧 load 后**断言每个 `lora_B` 张量 norm > 0**（防 literal no-op）。θ-α 是 rank16，MAformac config 已 α=32=2r（缩放 2.0，正确）→ 秩坍缩 paper-tiger，但 **norm>0 断言仍必加**（防 save 出岔）。
- **adopt**：metrics.jsonl 记 **adapter output norm / global adapter L2 norm** 随 step 曲线，**norm 速降到 0 → `adapter_norm_collapse` 告警**（text-to-3D 配方，几乎零成本）。
- **adopt**：**空输出率**作 collapse 主判据（路 3 已纳）；**同 probe prompt 跑 N 次看方差**（聚太紧 → collapse 哨兵）。
- **adapt**：有效秩/谱监控作 **P2 诊断旋钮**（rank16 不命中秩坍缩主线，但若 C6 掉点查不出根因，effective-rank/stable-rank 是下钻手段，不进主线门）。
- **drop**：AdaLoRA 动态秩分配（mlx 不原生，过度工程）；谱几何分类器（重，诊断期才用）。

**Source：** PEFT #1402 https://github.com/huggingface/peft/issues/1402 | text-to-3D LoRA norm-to-0 arXiv 2507.09748 | 医学 VLM mode collapse arXiv 2603.00148 | 有效秩/秩坍缩 https://huggingface.co/blog/johntnanney/most-lora-rank | 谱几何 drift arXiv 2604.08844 (2026-04) | rsLoRA 缩放 arXiv 2312.03732 | Biderman α=2r arXiv 2405.09673

---

### 路 5 — 端侧部署 parity：fuse adapter + quantize 4bit 静默掉点检测

**核心发现（**真 tiger，端侧诚实性命门**）：**
- **#654（OPEN，2025-12 至今活跃讨论）**：dynamic adapter 好、`mlx_lm.fuse` 后**静默丢学到的行为**（实例：训俄语 CoT，adapter 态俄语推理对，fuse 后回退英语）。共因 = fuse 进**已 4bit base** 损精度抹掉 adapter 高精度里的细微行为。**唯一原生 workaround = `mlx_lm.fuse --de-quantize`**（fuse.py:42 坐实）。
- **#1248（OPEN，2026-05-06，有 PR #1249）**：🔴 `mlx_lm.server --adapter-path` **被静默忽略**——server 起来用 **base 模型**服务，**零报错零告警**。根因：`ModelProvider.load()` alias map 解析后用 resolved name 查 adapter map → cache miss → `adapter_path` 落 `None`。**这是「看着 OK，adapter 啥也没干」的活样本**——直接对应端侧「以为加载了 LoRA 实际跑 base」。
- **#1210（OPEN，2026-04-27）**：Gemma4 mlx-lm vs mlx-swift-lm attention-shape 分歧**破 fused-checkpoint 往返**——跨引擎（训练 mlx-lm Python vs 端侧 mlx-swift C++）数值/形状不一致放大掉点。
- **#1307 / #1352 / #1384（OPEN，2026-05/06）**：server「emit 合法 markup 但返回空 message」/「thinking enabled 只出 reasoning、content 空」——**空输出 server bug 群**，端侧 parity 必防。
- **QLoRA "Don't Merge Into 4-bit"**（Kaitchup/Rohan Paul）：adapter 训练时 base 被 dequant 到 16bit，**从没见过 4bit**；直接 merge 进 4bit 或 merge 后量化**静默掉 10-30%，训练 val 看不出**。最干净 = 不 merge 动态加载；必须 fuse 则 dequant→merge→requant 复刻训练量化配置；或 QAT（mlx-lm-lora）/QA-LoRA/LoftQ/PiSSA。
- **train/serve 差分验证通法**（PEFT/vLLM 共识）：**同 prompt greedy(temp0) 三方对账**——① base vs base+adapter **必须不同**（adapter 真生效）② merged-export vs dynamic-adapter **必须相同**（merge 没坏）③ **on-device 输出复现训练态 reference**（跨引擎 parity）。配 **logits delta**（max-abs logit 差 / KL）比 greedy token 更灵敏（greedy token 可能巧合一致）。

**adopt/adapt/drop for θ-α：**
- **adopt（端侧 V-PASS 硬门，绝不由训练态推断）**：**三路 parity 实测** = dynamic adapter（mlx-lm Python）vs fused-bf16 vs fused-4bit（端侧 mlx-swift），同 greedy probe **长输出** token-level 对账（#1058 警告：前 20 token 对后发散，不能只看头），掉点 > 阈值 = **BLOCKER**。
- **adopt（零成本，堵 #1248）**：端侧/server 加载 adapter 后**断言 adapter 真生效**——`lora_B` norm>0（路 4）+ **base vs +adapter 同 prompt greedy 必须不同**（不同 → adapter live；相同 → 静默没加载，停）。
- **adopt**：fuse 掉点先试 `mlx_lm.fuse --de-quantize`（#654 原生 workaround）；仍掉 → 端侧**动态加载 adapter 不 merge**（最稳）。
- **adapt**：**QAT（mlx-lm-lora `--qat-enable`）作 P2 旋钮**——若 4bit fuse 掉点过大，QAT 训练时模拟量化，端侧 4bit 友好（这是 mlx-lm-lora 唯一值得 MAformac 借的能力；但先用 dequant/动态加载，QAT 是 fallback）。
- **adapt**：端侧 chat_template 与训练态**字节级同源**（mlx-swift C++ minijinja vs Python jinja2，#1210/lens6-F10），尤其 tool_call/空 think 渲染。

**Source：** mlx-lm #654 https://github.com/ml-explore/mlx-lm/issues/654 (OPEN) | #1248 https://github.com/ml-explore/mlx-lm/issues/1248 (OPEN, 2026-05-06) | #1210 https://github.com/ml-explore/mlx-lm/issues/1210 (OPEN, 2026-04-27) | #1307 https://github.com/ml-explore/mlx-lm/issues/1307 | "Don't Merge Into 4-bit" https://kaitchup.substack.com/p/dont-merge-your-lora-adapter-into | vLLM LoRA no-op #42008 https://github.com/vllm-project/vllm/issues/42008 | PEFT logits-compare callback https://huggingface.co/docs/peft

---

### 路 6 — 业界 LoRA 训练质量门最佳实践（unsloth/peft/axolotl/llama-factory）

**核心发现（横扫四框架的 quality gate）：**
- **Axolotl（gate 最齐）**：① `loss_watchdog_threshold`(~2× 起始 loss) + `loss_watchdog_patience`(默认3) **自动 abort 发散** ② `eval_table_size` + `eval_max_new_tokens` **边训边生成样本看塌缩** ③ `do_causal_lm_eval` + `eval_causal_lm_metrics`（自定义任务指标）④ `load_best_model_at_end`。
- **LLaMA-Factory**：`load_best_model_at_end: true` + `metric_for_best_model: eval_loss` + `early_stopping_patience`；但 `predict_with_generate` **训练期禁用**（#1104）→ checkpoint-then-predict 模式；支持自定义 metric 上 LLaMA Board（任务准确率）。
- **PEFT/Unsloth**：标准做法 = 同时盯 train+val loss、频繁 checkpoint；**PEFT 官方推荐 logits-compare callback**（生成 base vs adapter logits 比，有 improvement 才 True）= 验证 adapter 真改了行为的官方姿势；**核 trainable-param %**（0%=freeze 错、~100%=没应用 LoRA 在做全量微调）。
- **通用 silent failure 共识**：clean loss 不保证健康；**差分生成 + 权重 norm + logits delta + held-out capability probe** 四件套。
- 🔴 **Mac 硬约束**：Axolotl/unsloth/llama-factory **全 CUDA-only，Mac 不可用**（lens3 已证）——**只能移植判据/配方思想**，不能用框架本身。

**adopt/adapt/drop for θ-α：**
- **adopt**：把 Axolotl 的 **loss_watchdog（2× + patience 3）+ eval_table（生成样本）+ best-by-metric** 三件配方**手写进 MAformac mlx 循环**（路 1/2/3 已分别纳，这里是横向确认这是业界共识门）。
- **adopt**：**PEFT trainable-param % 断言**（θ-α rank16+7模块应 ~1.013%，superaudit 已见此数）+ **logits-compare**（base vs adapter logits delta 非平凡）作 adapter-live 门。
- **drop**：所有 CUDA 框架本身（Mac 不可用，硬约束）。

**Source：** Axolotl config-reference https://docs.axolotl.ai/docs/config-reference.html | LLaMA-Factory eval https://llamafactory.readthedocs.io/en/latest/getting_started/eval.html + #1104 | PEFT debugging https://apxml.com/courses/lora-peft-efficient-llm-training/chapter-5-peft-optimization-deployment/debugging-peft-implementations | Unsloth guide https://unsloth.ai/docs/get-started/fine-tuning-llms-guide | 四框架对比 https://www.spheron.network/blog/axolotl-vs-unsloth-vs-torchtune/

---

### 路 7 — mlx-lm GitHub issues 里的 LoRA 质量坑（经典 + 近 60 天新）★ 含直接撞 config 的 tiger

> github-first：`gh issue list --repo ml-explore/mlx-lm` 核到，标 open/closed + 日期。

**新坑（2026-04 之后，prior 7-lens 未覆盖）：**
- 🔴 **#1348（OPEN，2026-06-04）"Post-val-pass hang at iter 1 with LoRA rank 16 + 7 target modules on Qwen3-8B-4bit"**：**直撞 MAformac config**（rank16 + 7 模块）。第一次 val pass 后 iter1 **确定性挂死**（val loss 正常打印 → 无输出 → CPU<1%），mlx-lm **0.30.7 和 0.31.3 都复现**（**bracket 了 MAformac 的 0.31.1**）；触发条件含 **seq 8192/16384**。降 seq/关 val/调 grad-accum/降版本**全失败**。**根因未定，OPEN 无修**。
  - **MAformac 命中判定**：训 **Qwen3-1.7B**（非 8B）+ **seq 1024**（远低于 8192 触发线）→ **大概率不命中（paper-tiger），但必须 pin 死**：θ-α 跑前**先在 1.7B + seq1024 + rank16 + 7模块跑通第一个 val pass + 进 iter1 训练**（issue 精确触发点），别凭「1.7B 应该没事」放行——这正是 active-probe（§34）该做的。
- **#1248（OPEN，2026-05-06）silent adapter ignore**（已纳路 5）。
- **#1185（OPEN，2026-04-23）/ #1206（OPEN，2026-04-26）**：Qwen3.5-9B LoRA 首 backward `Resource limit (499000) exceeded`（descriptor-count 泄漏，非 OOM）+ M5 Max 崩——**只命中 9B 新架构**，1.7B 12.2GB 跑通 = paper-tiger（lens6 已记，此处确认仍 OPEN）。
- **#1307/#1352（OPEN，2026-05/06）空 message server bug**（已纳路 5）。

**经典坑（prior 已深挖，此处只确认状态 + 关联）：**
- **#654 fuse 掉点**（OPEN）/ **#2617 调度器 bug**（已修 0.17.1，0.31.1 不命中但打印 LR 曲线坐实）/ **--mask-prompt 单区间只算最后 turn**（lens5/6 已证）。

**adopt/adapt/drop for θ-α：**
- **adopt（active-probe 必做）**：θ-α **正式训前先复现 #1348 精确触发点**——1.7B-4bit + rank16 + 7模块 + 实际 seq，**跑通第一个 val pass + 进 iter1 训练**，坐实不挂（不命中）；命中则降模块/seq 应急。
- **adopt**：长跑挂**显存监控**（#1185/#1206 descriptor 泄漏，正式 3-epoch 比 smoke 累积久）；设 cache_limit 较低。
- **adopt**：端侧 server 路径**断言 adapter 真加载**（#1248）。
- **pin（版本锁）**：`mlx-lm==0.31.1` + `mlx` 核心版本 + `transformers` 版本进 lock（lens3-F8，train-serve parity 依赖版本一致）。

**Source：** `gh issue list ml-explore/mlx-lm`（本机一手核）| #1348 https://github.com/ml-explore/mlx-lm/issues/1348 (OPEN, 2026-06-04) | #1248 (OPEN) | #1185 https://github.com/ml-explore/mlx-lm/issues/1185 | #1206 https://github.com/ml-explore/mlx-lm/issues/1206 | #654 (OPEN) | #2617 https://github.com/ml-explore/mlx/issues/2617 (CLOSED, 修于 0.17.1)

---

## 3. Pre-Mortem 三分类汇总

### 🐯 Tiger（明确威胁，带验证清单）

| # | 威胁 | 验证/修法 | 命中 θ-α |
|---|---|---|---|
| T1 | **语义/行为 eval 门缺位**（0/34 根因，loss 全绿能力塌缩，stock/mlx-lm-lora 都没有） | **边训边生成 probe，计空输出率/ToolCall-exact/IrrelAcc，空输出率>阈值 abort** | 🔴 必加 |
| T2 | **last/best-val-loss checkpoint 可能是塌缩那个** | **按任务指标选 best-by-metric**，不拿 last/best-val-loss | 🔴 必加 |
| T3 | **adapter literal no-op / norm-to-0 collapse**（PEFT 默认 B=0，存盘出岔=base） | 存盘+端侧 load 后断言 `lora_B` norm>0 + base vs +adapter greedy 必须不同 | 🔴 必加（零成本） |
| T4 | **fuse 进 4bit 静默掉 10-30%**（#654 OPEN）+ **#1248 server 静默用 base** | 三路 parity 实测 + `--de-quantize` + adapter-live 断言；端侧 V-PASS 硬门 | 🔴 必加 |
| T5 | **clip 路径从未真跑**（superaudit P1，健康靠 stock CLI 冒充） | θ-α clip 真跑≥60 iter 过 warmup，验 preclip norm>1 触发 clip | 🔴 必修 |
| T6 | **checkpoint corruption / save-load 不一致**（resolve.ai 300x gap） | 存盘前 in-memory probe 生成 + load 后对账；受控记忆 sanity | 🟠 高 |

### 🐯📄 Paper-Tiger（看似威胁实际可控，给证据）

- **#1348 rank16+7模块 hang**：撞 config 名字吓人，但**触发条件是 Qwen3-**8B** + seq 8192/16384**；θ-α 是 **1.7B + seq1024** → 大概率不命中。**但必须 active-probe 复现触发点坐实**（别凭「应该没事」）。
- **秩坍缩（effective rank 低）**：rank16 + α=2r（缩放2.0，config 已对）→ 不命中主线；α 固定才坍缩（Biderman）。effective-rank 留作 P2 诊断不进主门。
- **NaN/grad 发散**：`c5_mlx_train_loop.py` 已有 clip+nonfinite-fallback+LR 降 1e-4（superaudit 核 1609 Val0.605 真收敛）→ 训练稳定层已堵，**前提是 clip 真跑（T5）**。
- **#1185/#1206 显存崩**：只命中 9B 新架构，1.7B 12.2GB peak 跑通 → paper-tiger，长跑挂监控即可。
- **mlx-lm-lora 看着先进**：383★ 活跃，但**只多 QAT，质量门一个没多**（sft_trainer 源码核实）→ 不是 0/34 解药，QAT 留 P2。

### 🐘 Elephant（没人谈但该谈）

1. **"训练健康"和"能力健康"是两个正交维度，0/34 全栈审计只审了前者**——superaudit/grill 8 维全 PASS 因 codex 诚实报 train_health；但**没一轮门是"实跑 probe 看 adapter 吐不吐空"**。质量门必须有**生成式语义维度**，不只 loss/合规（对齐 `claim-vs-reality-gap` 铁律2）。
2. **smoke loss 数字本身无诊断价值**（dry-run deterministic 串必过拟合）——拿 smoke loss 当配方信号是南辕北辙；θ-α 真信号 = **held-out probe 上的空输出率/ToolCall-exact**，不是 train loss。
3. **存盘前验证 ≠ 存盘后验证**（resolve.ai 实证 save/load 可掉 300x）——MAformac receipt 记的是「训练态指标」，但端侧跑的是「load 后的量化态」；两者间有 fuse+量化+跨引擎三道静默掉点，**端侧 parity 绝不能用训练态推断**。
4. **差分生成门是「adapter 是否活」的唯一可靠信号**——loss 降可能是 base 本来就会（resolve.ai：trained 和 base 几乎无区别）；**base vs +adapter 必须不同 + logits delta 非平凡**才证 adapter 真改了行为。这门零成本却最被忽略。
5. **#1348 是「config 同名 ≠ 行为同」的活案例**——MAformac config（rank16+7模块）和 #1348 字面一样，但触发取决于 model size + seq，**必须下钻触发条件而非凭 config 名判命中**（对齐 §31 frame-check / §34 active-probe）。

---

## 4. 给 θ-α 的 Quality Gate 推荐清单（按落点分）

> 原则：**enforce 不 declare**（门是 code 硬断言不是 receipt 字段，对齐铁律1）；**实跑不推理**（生成式门实采 probe 不信 loss，对齐铁律2/§30）。

### A. 进 `c5_mlx_train_loop.py`（训练循环内，边训边守）

| 门 | 机制 | 判据 / abort 条件 | 来源 |
|---|---|---|---|
| **G1 差分生成门** ★ | 每 N 步在 probe 上 base vs +adapter greedy 生成 | base 与 +adapter 输出**必须不同**；相同→`adapter_no_op` event | 路 5/6 resolve.ai+PEFT |
| **G2 空输出/塌缩门** ★ | probe 生成计空输出率 + repeat 率（histogram 偏斜） | 空输出率 > 5% → `capability_collapse` event + 可选 abort | 路 3/4 TeleDoCTR |
| **G3 任务指标门** ★ | probe 计 ToolCall 集合精确匹配 + IrrelAcc | 记 metrics.jsonl 每 checkpoint；选 best-by-metric | 路 2/3 |
| **G4 loss-watchdog** | loss > 2× 起始 loss 连续 3 步 | → `divergence_abort` + 停 | 路 1 Axolotl |
| **G5 clip 真跑断言** | clip_grad_norm 路径 ≥60 iter | preclip norm 实测 >1 → clip 必触发（否则 fake-runtime） | 路 1 / superaudit |
| **G6 adapter-norm 哨兵** | 每 step 记 global adapter L2 norm | norm 速降到 0 → `adapter_norm_collapse` | 路 4 text-to-3D |
| **G7 三 seed + env** | mx/np/random seed 显式 + 写 receipt | 复现基线（val/ToolCall 容差内一致，非 bit-exact） | lens4 |

### B. 进 `make verify` / CI（存盘后 + pipeline 体检）

| 门 | 机制 | 判据 | 来源 |
|---|---|---|---|
| **G8 lora_B norm>0** ★ | 存盘 adapter 后断言每个 B 张量 norm>0 | =0 → literal no-op，BLOCKER | 路 4 PEFT#1402 |
| **G9 存盘前/后对账** | in-memory probe 生成 hash vs load 后 hash | 不一致 → save/load corruption | 路 3 resolve.ai |
| **G10 受控记忆 sanity** | ~20 样本 overfit→推理复现（θ-α 起手一次） | loss gap 过大 → pipeline 坏 | 路 3 resolve.ai |
| **G11 trainable-param %** | 断言 ~1.013%（rank16+7模块） | 0%=freeze 错 / ~100%=没应用 LoRA | 路 6 PEFT |
| **G12 masking 边界断言** | dump 训练样本 token+label_mask | 空 think 段 mask=0、tool_call span mask=1（CI 测试） | lens6-F5 |
| **G13 #1348 active-probe** | 1.7B+rank16+7模块+实际 seq 跑通首 val pass + iter1 | 挂死 → 命中 #1348，降模块/seq | 路 7 |

### C. 进端侧 V-PASS 硬门（绝不由训练态推断）

| 门 | 机制 | 判据 | 来源 |
|---|---|---|---|
| **G14 三路 parity** ★ | dynamic vs fused-bf16 vs fused-4bit 同 greedy 长输出对账 | 掉点>阈值 → BLOCKER；先试 `--de-quantize` | 路 5 #654 |
| **G15 adapter-live 端侧断言** | 端侧 base vs +adapter greedy 必须不同（堵 #1248） | 相同 → 静默没加载，停 | 路 5 #1248 |
| **G16 chat_template 字节级同源** | mlx-swift C++ vs Python jinja2 渲染对账 | tool_call/空 think 渲染不一致 → 停 | 路 5 #1210/lens6-F10 |
| **G17 logits delta** | base vs +adapter max-abs logit 差 / KL | 平凡（≈0）→ adapter 没生效 | 路 5 PEFT |

> **最小可行子集（若只加 3 个先堵 0/34）**：**G1 差分生成 + G2 空输出门 + G8 lora_B norm>0**——这三个零-低成本、直接照见「adapter 吐空/没生效」，0/34 当场暴露。

---

## 5. mlx-lm 原生有什么 vs 要自己加（一表收口）

| 能力 | stock mlx-lm 0.31.1 | mlx-lm-lora 383★ | θ-α 要自己加？ |
|---|---|---|---|
| grad clip | ❌ | ❌ | ✅ 已有（c5_mlx_train_loop，须真跑 G5） |
| NaN/Inf guard | ❌ | ❌ | ✅ 已有（nonfinite-fallback） |
| **差分生成门 G1** | ❌ | ❌ | 🔴 **必自建** |
| **空输出/塌缩门 G2** | ❌ | ❌ | 🔴 **必自建** |
| **任务指标 eval G3** | ❌（只 loss） | ❌（只 loss） | 🔴 **必自建** |
| **best-by-metric checkpoint** | ❌（拿 last） | ❌ | 🔴 **必自建** |
| loss-watchdog G4 | ❌ | ❌ | ✅ 自建（Axolotl 配方） |
| **lora_B norm>0 G8** | ❌ | ❌ | 🔴 **必自建（零成本）** |
| 存盘前/后对账 G9 | ❌ | ❌ | ✅ 自建（resolve.ai） |
| val loss 报告 | ✅ | ✅ | — |
| `--mask-prompt`（单区间） | ✅（只最后 turn） | ✅ | ✅ 自管 masking（lens5） |
| `fuse --dequantize` | ✅ | — | 用原生（#654 workaround） |
| QAT | ❌ | ✅ | 🟡 P2 fallback（4bit 掉点大才用 mlx-lm-lora） |
| WandB/SwanLab | ✅（云，违离线） | ✅ | ❌ 用本地 metrics.jsonl/Trackio |

**收口判断**：**质量门核心（G1/G2/G3/G8 + best-by-metric）现成工具全无，必须 MAformac 自建**。mlx-lm-lora 唯一增量 = QAT，留作端侧 4bit 掉点的 P2 fallback。**stock mlx-lm 提供训练骨架，质量管控自己长。**

---

## 6. 经典坑清单（一句话速查）

1. **clean loss curve ≠ healthy model**（resolve.ai 300x gap）——loss 全绿可与 adapter 没生效/塌缩共存，**0/34 形态**。
2. **PEFT 默认 lora_B=0**——存盘出岔 = adapter 全零 = literal no-op = 跑 base，loss 照降。
3. **last ≠ best checkpoint**——stock mlx-lm 拿 last，小数据 LoRA 1-3 epoch 内转「记」，last 可能已塌。
4. **val loss ≠ task metric**（loss-metric mismatch）——端目标是 FC 准确率就按它选 checkpoint，别按 val loss。
5. **fuse 进 4bit 静默掉 10-30%**（#654 OPEN）——训练 val 看不出，端侧才暴露；`--de-quantize` 或动态加载。
6. **#1248 server 静默用 base**——`--adapter-path` 被忽略零报错，端侧「以为加载 LoRA 实际跑 base」。
7. **#1348 rank16+7模块 hang**——撞 config 名，但触发要 8B+seq8192；1.7B+seq1024 大概率不命中，须 active-probe 坐实。
8. **LoRA α/r × 激活 norm 差 → 前几步 NaN**（PEFT #3073）——clip_grad_norm=1.0 救不了，step1-5 NaN 是激活依赖梯度，降 LR。
9. **adapter output norm → 0 = collapse**（过激优化驱动，降 LR 缓解）。
10. **mode collapse = loss 有 trivial 解**（"全答 Yes"/空串/单 token），FC 结构化输出尤易。
11. **histogram 偏斜 = 退化输出**（字符/token 过度重复），schema 校验 + 字符频率比 ground-truth。
12. **跨引擎 parity**（mlx-lm Python jinja2 vs mlx-swift C++ minijinja，#1210）——chat_template 字节级同源否则掉点。
13. **smoke loss 数字无诊断价值**——dry-run 串必过拟合，真信号是 held-out probe 空输出率。
14. **mlx-lm 不调 mx.random.seed**——只 np seed 做 shuffle，复现须显式三 seed。
15. **mlx-lm-lora 看着先进只多 QAT**——质量门一个没多，不是 0/34 解药（新≠强）。

---

## 7. 与现有规则/调研的关系

- **承接** 2026-06-21 7-lens（lens1 loss 发散根因 / lens4 监控指标 / lens5 mask 代码链路 / lens6 issue oracle / lens7 泛化），本档**不重复训练稳定/masking**，**聚焦 0/34 暴露的语义/行为 eval 门新缺口**。
- **直接落地** `claim-vs-reality-gap.md` 铁律2（审计加语义门 + 实跑一手数据）——G1/G2/G3 = 给训练加「实跑生成的语义门」，堵「审了合规没审语义」。
- **active-probe（§34）**：G13（#1348 触发点复现）/ G15（端侧 adapter-live 断言）= 行为探测取代 config 静态检查（config 同名 ≠ 行为同）。
- **github-first**：mlx-lm（5999★/2026-06-12）/ mlx-lm-lora（383★/2026-06-16）/ mlx-swift-lm（679★/2026-06-21）全活跃 <60 天，star 交叉验证通过。

---

## 附：关键本机文件（绝对路径）

- `/Users/wanglei/Library/Python/3.13/lib/python/site-packages/mlx_lm/tuner/trainer.py`（无 clip/无 mx.seed/只 loss eval，§1.1 一手）
- `/Users/wanglei/Library/Python/3.13/lib/python/site-packages/mlx_lm/lora.py`（CLI flag，§1.2）
- `/Users/wanglei/Library/Python/3.13/lib/python/site-packages/mlx_lm/fuse.py`（`--dequantize`，§1.3）
- `/Users/wanglei/Library/Python/3.13/lib/python/site-packages/mlx_lm/tuner/callbacks.py`（WandB/SwanLab）
- `/Users/wanglei/workspace/MAformac/Tools/C5TrainingCLI/c5_mlx_train_loop.py`（已有 clip/nonfinite-fallback/MetricsWriter，须加 G1/G2/G3/G8）
- prior 7-lens：`/Users/wanglei/workspace/raw/05-Projects/MAformac/research/2026-06-21-lora-training-pitfalls/`（lens1-7 + superaudit）

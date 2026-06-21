# Lens 4 — 训练监控 + 记录/可复现 + 实验追踪 (MAformac C5 LoRA)

> ultracode 深度调研一手档。12+ WebSearch + 2 GitHub 源码 fetch(mlx-lm trainer.py / LORA.md)+ 本机代码(Core/Training/C5LoRATraining.swift, Tools/C5TrainingCLI/main.swift)。每条 finding 带 source URL + 日期 + applies_to_maformac 判定。

## Summary(本路核心结论)

MAformac smoke loss 一路波动上升(iter1 Val 4.47 → iter60 Train 8.36)要分两层看:

1. **短窗口 noisy/上升 = paper-tiger 一半**:前 ~48 步在 warmup 区(warmup_fraction=0.08 × 600),FC 结构化 token(JSON 大括号/工具名/参数键)本来就 noisy——OpenAI FC cookbook 真实 run step50 也从近 0 回跳到 3.93。smoke 只验证 pipeline 跑通,不期望几十步收敛。
2. **但单调上升 60 步 = tiger**:叠加三个**已验证源码**的真实根因:
   - mlx-lm trainer **完全没有 gradient clipping**(读 main 分支 trainer.py 确认)
   - LR=2e-4 对 FC LoRA 偏高(社区配方 1e-5~2e-5)
   - smoke 阶段 `maskingStage=smoke_only / trainOnTurn=false` → loss 算在整条序列(含模板化 user 串)

## 监控该实时看什么(mlx-lm 原生 emit 7 指标 + 自加 grad_norm)

mlx-lm CLI 每 `steps_per_report=10` 步打印,每 `steps_per_eval=200` 步 eval:

| 指标 | mlx-lm 回调 key | 健康判据 | MAformac 动作 |
|---|---|---|---|
| train_loss | `train_loss` | 平滑下降, 小震荡 OK | 写 metrics.jsonl |
| val_loss | `val_loss` | 与 train 同步降; train≪val=过拟合 | **早停 + 选 best 的唯一信号** |
| learning_rate | `learning_rate` | cosine 衰减 | 核 warmup/decay 渲染对 |
| it/sec, tokens/sec | `iterations_per_second`, `tokens_per_second` | 稳定 | 吞吐基线 |
| trained_tokens | `trained_tokens` | 累加 | — |
| peak_memory | `peak_memory` | 稳定不缓涨 | M5/12.2GB 设阈值告警(防 #738 内存泄漏) |
| **grad_norm** | **无(自加)** | 不持续飙升; spike 先于 NaN | **加 clip_grad_norm 顺手取 total_norm 打点** |

异常信号识别:
- **loss NaN**:LR 过高→exploding gradient→数值溢出。grad_norm spike 是最早前兆。
- **plateau 不降**:warmup 后仍不降 → LR 太低 或 trainable 参数太少。
- **过拟合 train↓val↑**:小数据 LoRA 1-3 epoch 内即可发生, train_loss 无信息量。
- **欠拟合**:train/val 都高不降。

## 何时早停 + checkpoint 选哪个

- 小数据 LoRA 因 adapter 参数空间小,**1-3 epoch 内从「学」转「记」**,且 train_loss 两种失败模式曲线相同 → **val_loss 是唯一带信息的指标**。
- 早停:val_loss 连续几个 eval 步上升即停。
- checkpoint:留 **best(按 val 指标)** 非 latest;mlx-lm **不自动 load-best**(`steps_per_save=100` 只定期存),要自己比 metrics.jsonl 挑。
- 当前 `steps_per_eval=200` → 600 步只 eval ~3 次,抓不到 val 拐点。正式训练(4500×3epoch)要调到每 ~50-100 步 eval。

## 记录 / 可复现

- **最大坑**:mlx-lm trainer **不调 mx.random.seed**(只 np.random.seed 做 batch shuffle)。CLI 入口要显式 `mx.random.seed(SEED)+np.random.seed(SEED)+random.seed(SEED)`,SEED 写进 receipt。
- pin `mlx-lm==0.31.1` + mlx 核心库版本(receipt environment 段)。
- Apple Silicon GPU reduction 非确定 → bit-exact 不可得,复现标准定义为「val_loss/ToolCallExact 容差内一致」(对齐 §1:reproducible≠bit-exact)。
- mx.compile + seed bug(#1245):影响采样,训练要警惕。
- C5TrainingReceipt 血缘字段已很全(promptHash/digest/sourceRefs file:line),**缺口**:environment 段(seed/mlx 版本/dtype/硬件) + training_curve 段(metrics.jsonl 指针/best-checkpoint 依据)。

## 工具 adopt(巨人肩膀)— solo 离线轻治理选型

| 优先级 | 工具 | 理由 |
|---|---|---|
| ⭐默认 | mlx-lm 原生回调 `on_train/val_loss_report` → metrics.jsonl + matplotlib | 零新依赖, solo 复盘够用 |
| 多 run 对比时 | **Trackio**(HF, 2025-08, import as wandb, 本地 SQLite, <3000 行) 或 mlx-lm `--report-to wandb` offline | LR sweep / rank16 vs rank32 vs dora8 横向比 |
| ❌ 不用 | wandb cloud / mlflow | 重 + 违离线红线 + cloud 上传线程阻塞训练浪费算力 |

(Aim=本地优先可扩千 run, param 一等公民, 也是合格备选; TensorBoard=零设置但不存 config 版本、多 run 慢、无 group。)

## Pre-Mortem 三分类

**Tiger(已验证)**:①无 gradient clipping(读源码确认)②不设 mx.random.seed(读源码确认)③epochs=3 临界 + eval 太疏抓不到拐点 ④smoke 无 train_on_turn loss-mask。

**Paper-tiger(给证据)**:①smoke noisy≠失败(warmup+FC 天然 noisy, 但 MAformac 是单调升非震荡, 真因在 LR/clip/mask)②Qwen3 0.28% 参数坑已规避(config 列 7 模块, 1.013% 对)③不必上 cloud 追踪(原生回调够)④#1206 是 9B 不是 1.7B。

**Elephant(没人提但该提)**:①receipt 缺 environment/training_curve 段(有 what 没 how-to-rerun)②mlx-lm 不自动 load-best,照默认实装会拿 last adapter ③grad_norm 不在默认 7 指标但是 NaN 前兆,加 clip 顺手取几乎零成本 ④bit-exact 复现不可得,标准要重定义 ⑤FC 灾难遗忘混 5-10% 通用数据——但三层路由下影响可能小,待 grill 拍别照搬。

## 给 codex 实装训练循环的必加项(actionable)

1. 训练 step 加 `clipped, total_norm = mx.optimizers.clip_grad_norm(grads, max_norm=1.0)` 再 `optimizer.update(model, clipped)`;打点 total_norm(NaN/Inf 单独处理, MLX clip 不报非有限)。
2. CLI 入口显式三 seed + 写进 receipt。
3. 回调写 metrics.jsonl 进 `Reports/c5-lora-training-<ts>/`,曲线复盘。
4. 正式训练:`steps_per_eval` 调每 50-100 步;按 val_loss 挑 best checkpoint(比 metrics.jsonl);落实 train_on_turn loss-mask(`--mask-prompt`)。
5. smoke pass 判据物理化:`all finite (no NaN/Inf) + grad_norm 不持续飙`,而非「loss 下降」。
6. receipt 补 environment 段{seed, mlx_version, mlx_lm_version, hardware, dtype} + training_curve 段{metrics_jsonl_ref, best_checkpoint_step, best_checkpoint_val_metric}。
7. LR sweep 小实验(2e-4/1e-4/5e-5 同 seed 同数据)定正式 LR——注意 LoRA scale=32/rank16 下 2e-4 不等价 full-FT 2e-4,实测定不照搬。

## Sources(关键一手)
- mlx-lm trainer.py(无 clip / 无 mx.seed / 回调 key): https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/tuner/trainer.py
- mlx-lm LORA.md(config 选项): https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md
- MLX clip_grad_norm(#1040 已实现): https://github.com/ml-explore/mlx/issues/1040 ; https://ml-explore.github.io/mlx/build/html/python/_autosummary/mlx.optimizers.clip_grad_norm.html
- mlx seed/RNG(#1919, #1245): https://github.com/ml-explore/mlx/issues/1919 ; https://github.com/ml-explore/mlx-lm/issues/1245
- Qwen3 trainable param(#2616): https://github.com/ml-explore/mlx/issues/2616
- mlx-lm 内存泄漏(#738) / M5 9B 崩(#1206): https://github.com/ml-explore/mlx-examples/issues/738 ; https://github.com/ml-explore/mlx-lm/issues/1206
- mlx-lm FC 微调(指标/Metrics 回调): https://medium.com/@levchevajoana/fine-tuning-a-model-for-function-calling-with-mlx-lm-d00d587e2559
- Trackio: https://huggingface.co/blog/trackio ; https://github.com/gradio-app/trackio
- 早停/checkpoint/小数据 LoRA: https://unsloth.ai/docs/get-started/fine-tuning-llms-guide/lora-hyperparameters-guide ; https://inference.net/content/lora-fine-tuning
- FC loss 正常/noisy: https://cookbook.openai.com/examples/fine_tuning_for_function_calling ; https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/fine-tuning-small-language-models-for-function-calling-a-comprehensive-guide/4362539
- 发散/NaN/grad clip: https://www.baeldung.com/cs/ml-training-nan-errors-fix ; https://arxiv.org/pdf/2410.16682 ; https://spotintelligence.com/2023/12/06/exploding-gradient-problem/
- warmup noisy 正常: https://www.baeldung.com/cs/learning-rate-warm-up
- 实验追踪对比: https://www.zenml.io/blog/weights-and-biases-alternatives

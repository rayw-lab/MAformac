# Lens 2 — LoRA/QLoRA 超参配方深扒（MAformac C5）

## 调研方法
- 一手源：实读本机 `Core/Training/C5LoRATraining.swift`（config 真值）+ `Reports/c5-lora-training-20260621T1455-smoke-only-schedule/`（smoke loss 实测曲线 + 渲染 YAML）+ 本机 `~/Library/Python/3.13/.../mlx_lm/{tuner/trainer.py, tuner/utils.py, lora.py}`（mlx-lm 0.31.1 实际源码）
- 联网：12 次 WebSearch + 2 次 WebFetch（GitHub issues #985/#1040/#2617 + Thinking Machines + QLoRA 原论文 + Unsloth + arxiv 2405.09673/2603.16901/2305.14314 等）

## MAformac C5 config 真值（实读）
```
model=mlx-community/Qwen3-1.7B-4bit (MLX 4-bit, 非NF4)
rank=16, scale=32.0, dropout=0.0
learning_rate=2e-4, lr_schedule=cosine_decay
  arguments=[2e-4, 150, 2e-5], warmup=12 (optimizer-update 单位)
epochs=3, batch_size=4, grad_accumulation_steps=4 (有效batch=16)
max_seq_length=1024
keys=7模块(self_attn q/k/v/o + mlp gate/up/down)
optimizer=stock默认 adam (无 weight_decay)
secondary=[rank32_confirmation, dora_rank8_secondary]
Trainable=1.013% (17.4M/1720M), Peak mem=12.2GB
```

## smoke loss 发散实测（mlx-smoke-only-600.log）
| iter | LR | Train loss | 解读 |
|---|---|---|---|
| 1 | — | Val 4.47 | 起点 |
| 30 | 1.00e-4 | **1.069** | 健康下降（关键：LR=1e-4 时能学到 1.07）|
| 40 | 1.50e-4 | 1.724 | 开始抖 |
| 60 | **2.00e-4 触顶** | 2.989 | 触顶 |
| 70 | 1.998e-4 | **17.540** | 暴涨（发散点）|
| 100 | 1.976e-4 | 8.545 | 未回落 |
| 130 | 1.937e-4 | 7.350 | 仍远高于 iter30 的 1.07 |

**判据**：持续发散（非良性早期 adapter spike）——loss 在 LR 爬到峰值那一刻炸开，130 步不回落。

## 逐超参对照（better/worse/risky vs 最佳实践）

| 超参 | MAformac | 最佳实践 | 判定 |
|---|---|---|---|
| LR | 2e-4 | mlx 生态 1e-5~5e-5；TM 短训 1e-4~5e-4（10-15x FullFT）| ⚠️ **risky**：理论在 TM 区间，但 mlx 4-bit+无裁剪环境偏高，实测触顶即炸 → 降 1e-4/5e-5 |
| rank | 16 | 单跳 FC：8-16 平衡默认；多跳才 ≥32 | ✅ **better/合理**（单跳 FC，维持）|
| alpha/scale | scale=32（=alpha 2x rank）| α=2r 经验成立 | ✅ 正确，但需核 mlx scale 生效语义 |
| target_modules | 全 7（attn+MLP）| 全线性层（含 MLP）才匹配全量；attn-only 劣 | ✅ **better/做对了**（FC 尤需 MLP）|
| epochs | 3 | LoRA 1-3，必须 eval loss 早停 | ⚠️ 偏上沿，须 held-out 早停（train loss 看不出过拟合）|
| 有效 batch | 16 | LoRA 甜区 <32 | ✅ 区间内偏低，非发散主因 |
| warmup | 0.08（~12 optimizer step）| 5-10% | ✅ 合理 |
| max_seq | 1024 | 够即可，FC 防截断 | ✅ 当前 dry-run（每例3工具）够；真数据需实测 token 分布 |
| 正则化 | dropout0+adam(无wd) | wd 0.01 + 短训 dropout 可 0 | ⚠️ 零正则，切 adamw+wd0.01 |
| grad_clip | **无（stock mlx-lm 缺）** | max_grad_norm 0.3-1.0 标配 | 🔴 **最大缺口** |

## 发散根因（四因叠加）
1. **LR 2e-4 触顶即炸**（首要，已实测）
2. **stock mlx-lm 0.31.1 训练循环无梯度裁剪**（结构性，trainer.py step() 零 clip_grad_norm）
3. **mlx 4-bit 基座数值敏感**（非 NF4，QLoRA 稳定属性不继承）
4. **零正则化**（dropout0 + adam 无 weight_decay）

## 首要动作（按 ROI 排序）
1. ⭐ **LR 2e-4 → 1e-4**（iter30 已证 1e-4 能健康学到 1.07）；仍炸则 5e-5
2. ⭐ **optimizer adam → adamw + weight_decay 0.01**（mlx-lm 原生支持，不改训练循环）
3. 若 1+2 仍边缘不稳：升级到带 grad_clip 的 mlx-lm（先 github-first 核当前版本）或有效 batch 提到 24-32（grad_accum 4→6/8，注意 schedule 步数同步重算）
4. **正式训练前等云多源真口语 generator**（dry-run 确定性串训 3 epoch 必死记，只验链路不验质量）
5. codex apply 时实核：adapter_config.json 的 alpha/rank（确认 scale=32 语义）+ 渲染 LR 曲线峰值是否到位（mlx build_schedule [warmup+1] 边界有偏移）+ 真数据 train.jsonl token p99 vs 1024

## 维持不动（做对了，别动）
- target_modules 全 7 模块（FC 必需 MLP，退回 attn-only 伤质量）
- rank16（单跳 FC 平衡默认）
- 4-bit 基座训练（train-serve 精度一致）
- dev_selection + 3 HIGH 防死记/防假提升/防手痒框架

## 来源（每条 finding 内已带）
- mlx-lm 0.31.1 本机源码：trainer.py / tuner/utils.py / lora.py（2026-06-21 核）
- smoke 日志：Reports/c5-lora-training-20260621T1455-smoke-only-schedule/mlx-smoke-only-600.log
- https://thinkingmachines.ai/blog/lora/（2025-09）
- https://arxiv.org/pdf/2305.14314（QLoRA, 2023-05）
- https://arxiv.org/pdf/2405.09673（LoRA Learns Less, 2024-05）
- https://arxiv.org/pdf/2603.16901（结构化工具调用截断, 2026-03）
- https://github.com/ml-explore/mlx/issues/1040（clip_grad_norm 才加入 mlx 核心）
- https://github.com/ml-explore/mlx-examples/issues/985（schedule warmup_init 回落）
- https://github.com/ml-explore/mlx/issues/2617（cosine 在 warmup 期提前衰减）
- https://github.com/ml-explore/mlx-examples/issues/1186（scale=alpha/rank 语义）
- https://unsloth.ai/docs/.../lora-hyperparameters-guide（epochs/正则）
- https://techcommunity.microsoft.com/.../fine-tuning-small-language-models-for-function-calling（FC 小模型 rank8/alpha16 起步）

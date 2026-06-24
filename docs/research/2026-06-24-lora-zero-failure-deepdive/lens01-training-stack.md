# L01 — 训练栈可行性 + 本机/云资源边界（只管跑不跑得动）

> ultracode 深度研究 · 2026-06-24 · MAformac A2-post pre-propose decision-pack · finder L01
> 本机 scout（只读）+ mlx_lm/home-llm 源码 file:line + 9 次 WebSearch/WebFetch + gh 5 repo 实查 + 本机历史受票据对账
> **维度边界**：只管训练栈『跑不跑得动』（显存/吞吐/优化器/收敛健康/云逃生口何时必须）。**超参调优归 L13，数据配比归 L11，写死防重叠。**

## 0. 本机 scout 事实（坐实，非推测）

| 项 | 实测值 | 来源 |
|---|---|---|
| 机器 | Mac17,2 / **Apple M5** | sysctl hw.model / machdep.cpu.brand_string |
| RAM | **32 GiB** (34359738368 bytes) | sysctl hw.memsize |
| mlx | **0.31.2** / mlx-metal 0.31.2 | pip3 list |
| mlx_lm | **0.31.1** | pip3 list + python3 -c import mlx_lm |
| transformers | 5.6.1 | pip3 list |
| 未装 | peft / unsloth / torch / outlines / xgrammar（**纯 mlx 栈**）| pip3 list |
| CLI | ~/Library/Python/3.13/bin/mlx_lm.lora 就位 | which mlx_lm.lora |

→ 训练栈本机就位，rank16Mainline 配方指定的 mlx-community/Qwen3-1.7B-4bit 与本机 mlx_lm 0.31.1 匹配，**无需装任何额外依赖**。

## 1. 本机历史受票据 = 同配置实测 ground-truth（最强证据）

本机 Reports/c5-*/metrics.jsonl 是 2026-06-21 prior C5 runs 在**这台 M5/32GB** 上跑 Qwen3-1.7B-4bit LoRA rank16 的实测，直接对账：

| 指标 | 实测值 | 来源 |
|---|---|---|
| **Peak mem** | **11.4 – 12.2 GB**（仅占 32GB 的 ~37%）| metrics.jsonl 聚合 + lens1:13 |
| **Tokens/sec** | mean ~75-87，max ~100 | metrics.jsonl |
| **It/sec** | ~0.19 – 0.28（batch4，seq≤1024）| metrics.jsonl + lens1:15 |
| **train_loss** | 健康收敛 5.5 → 0.6-1.3（n=32-60）| metrics.jsonl |
| **Trainable** | **17.433M / 1720.575M = 1.013%** | lens1:14 |
| no_nan_or_inf / no_oom | true / true | c5-smoke-receipt |

> ⚠️ 注：Reports/c5-pr2pr4pr5* 目录命名带 "2b" 但实为 Qwen3-1.7B（命名松散）。受票据 c5-training-receipt.json 渲染出 scale=32 是**过期 A/B 值**（receipt 是 renderYAML 渲染的产物非 SSOT，符合 claim-vs-reality 第9坑：config/receipt 是代码渲染产物 vs 生成它的工厂方法）——配方真值 scale=20 在 C5LoRATraining.swift:1216 工厂方法。

## 2. rank16Mainline 配方 SSOT（工厂方法，非 receipt）

Core/Training/C5LoRATraining.swift:1210-1235 static func rank16Mainline()：

```
model: mlx-community/Qwen3-1.7B-4bit   numLayers: -1 (全28层)
rank: 16   scale: 20   dropout: 0   LR: 0.0001   lrSchedule: cosine
warmupFraction: 0.08   scheduleDecaySteps: 600   epochs: 3
batchSize: 4   gradAccumulationSteps: 4 (有效 batch 16)   maxSeqLength: 1024
optimizer: adamw   weightDecay: 0.01   gradClipNorm: 1.0
trainingLoop: maformac_c5_repo_loop_mlx_lm_0_31_1
keys: 7 proj (q/k/v/o + gate/up/down)
```

→ A2 PR#3 已实证零碰。本路确认：此配方与本机 mlx 0.31.1 栈兼容、实测跑得动。

## 3. stock mlx_lm 0.31.1 默认值 + 项目 repo-loop 差异（关键）

stock mlx_lm/lora.py:46-73 默认：num_layers=16 / rank=8 / scale=20.0 / lr=1e-5 / batch_size=4 / iters=1000 / max_seq=2048 / optimizer=adam(可选 adamw/muon/sgd/adafactor) / grad_checkpoint=False。

**stock mlx-lm 无梯度裁剪**（trainer.py 主循环无 clip）。项目 Tools/C5TrainingCLI/c5_mlx_train_loop.py 是 **fork stock trainer.train() body 并插入**：
- optim.clip_grad_norm(grad, max_norm) (line 244) ← gradClipNorm=1.0 执行点
- finite 检查 (line 320) + nonfinite-fallback-lr 自动重启 (line 334)
- set_wired_limit(max_recommended_working_set_size) (line 180，与 stock trainer.py:215 同)

> 这是**防 loss 尖刺的关键差异**：lens1 坐实 0/34 之前的发散根因 = LR 峰值过冲（2e-4）+ stock 无 clip 保险丝；repo-loop 加 clip(1.0) + LR 守 1e-4 修了它。

## 4. 图171 显存公式拆解（实测对账）

Total = Model_Mem + (10+2)×Trainable_bytes + Activation，按 17.433M trainable 实算：

| 项 | 估值 | 占比 |
|---|---|---|
| 4bit base model | ~0.95 GB | base |
| 优化器/梯度态 (12 B/param × 17.4M) | ~0.21 GB | adamw m,v |
| **base + opt 小计** | **~1.2 GB** | 几乎可忽略 |
| **Activation**（measured peak 12.2 - 1.2）| **~11 GB** | seq1024/b4/grad-ckpt OFF，**主导项** |

→ **显存瓶颈是 activation，不是 base/optimizer**。峰值 12.2GB 离 32GB 上限差 2.6x，留 20GB headroom。逃生口 --grad-checkpoint（省 30-60% activation，~20% 慢）+ 降 seq，**但 32GB 上根本用不到**。

## 5. 栈内候选 + 云逃生口（热度交叉验证，gh 实查 2026-06-24）

| repo | star | pushedAt | 新鲜 | 本任务定位 |
|---|---|---|---|---|
| **ml-explore/mlx-lm** | **6018★** | 2026-06-12 | ✅ | 主栈，stock SFT-LoRA/QLoRA/DoRA/full 已覆盖 |
| Goekdeniz-Guelmez/mlx-lm-lora | 384★ | 2026-06-16 | ✅ 低星 | 12 训练算法(SFT/DPO/GRPO/QAT)；本任务 SFT-LoRA 用不到 RL，**deferred 二期** |
| **ARahim3/mlx-tune** | **1322★** | 2026-06-23(今天) | ✅ >1000 | Unsloth-compatible API；>1000★ 不降级候选，但 stock+repo-loop 已足，**现引入=越界** |
| axolotl-ai-cloud/axolotl | 12079★ | 2026-06-23 | ✅ | **云逃生口（24GB NVIDIA CUDA 栈）** |
| acon96/home-llm | 1364★ | 2026-06-11 | ✅ | 蓝本（用云 Axolotl 训 270m）|

**云 Axolotl = 真不必要的逃生口**：需 NVIDIA 24GB（QLoRA 下限 ~8GB），纯 CUDA 栈+adamw_bnb_8bit+flash_attention（home-llm gemma3-270m.yml:88,99）。home-llm 上云只因它训 270m 走 CUDA；本机 mlx 栈训 1.7B-4bit 实测跑得动，**零必要上云，仅当本机栈崩/需多卡分布式才考虑**。

## 6. 外部实证对照（bracket 本机数据）

- **Qwen3.5-0.75B** text-to-SQL LoRA（sciences44/mlx-lora-finetune）：iter100 train_loss 0.810 / **tokens_sec 267.5 / peak 8.19GB**；显存分级 16GB→batch1+layers4 / 32GB→batch4 / 64GB→batch4+grad-ckpt关。
- **Mistral-7B** M1Max/32GB b1 layers4 ~250 tok/s（mlx-lm LORA.md 官方）。
- 本机 **1.7B-4bit**（比 0.75B 大 ~2.3x）measured peak 12.2GB / tokens_sec ~75 → 落在 0.75B(8GB) 与 7B 之间，scaling 一致，坐实本机数据非异常。

## 7. M5 Neural Accelerators（elephant：吞吐有上行空间）

apple ML research 2026 + macstories：M5 NA 给 **~3.5-4x prefill**（compute-bound，含 forward/backward matmul，Qwen3-8B 20k prompt 158→578 tok/s）+ **~1.5x token-gen**（bandwidth-bound）。但 **launch 时 MLX 对 NA 支持仍 preliminary**（『full support later this year』），int8 matmul ~2x throughput。→ 本机 measured 55-100 tok/s 在升级 MLX 后**可能提升**，但不影响『跑得动』结论；升级需重测 parity（数值/吞吐可能变）。

## 8. 假想验证（MAformac 真实场景推演）

**预测：训练栈层面 100% 跑得动且健康，绝不因『跑不动』失败。** 三链：(1) 本机受票据同配置 peak 12.2GB/no_oom/loss 健康收敛；(2) 显存拆解 base+opt 仅 1.2GB、activation 11GB 主导但离上限 2.6x；(3) 外部 0.75B(8GB)/7B(250tok/s) bracket 一致。

**时长**：tiny-epoch 200样本(rank16/seq2048/b4/ga4，有效16) → 13 update/epoch ×3 ≈ 一两分钟级；全量 ~5-10k 样本 ×3 epoch ≈ 数十分钟-1h（参 Mistral-7B/5000样本/M2Max 90min，1.7B 更快）。home-llm gemma3-270m 用 batch16/seq4096 在云 24GB——本机 1.7B 比 270m 大 ~6x，但 4bit+seq1024(非4096)+unified 32GB **撑得住**（降 seq1024 已比 home-llm 4096 省 4x activation）。

**失败模式（都不是训练栈跑不动）**：① LR 配错回 2e-4 → 尖刺发散（repo-loop clip+1e-4 已修，配方守住不发）；② 模板数据低多样性 → 隐式 epoch 膨胀 loss 塌缩（归 L11/L13）；③ 占位符 <position> 未渲染进 target → 教坏模型（数据 bug，lens1:70，归数据门）；④ train/eval surface 异源(generic frame vs D-domain) = **0/34 真根因，A2 已修 surface，训练栈无关**。

## 9. premortem 三分类

**tiger（明确威胁+验证）**：① LR 回 2e-4 → 尖刺发散（验：grep config LR=1e-4+cosine+warmup0.08，确认走 c5_mlx_train_loop.py 有 clip，跑 10-iter preflight 看 val 2.317）；② warmup 单位错配 48步实际12 update（验：核 :1253 renderedWarmupSteps 按 optimizer-update 算，已修）。

**paper-tiger（看似威胁实际安全+证据）**：① M5/32GB OOM/性能不行 → 实测 peak 12.2GB/留20GB/no_oom，#828 是48GB训大模型才撞墙(lens1:65)；② 必须上云 Axolotl → 24GB 是 CUDA 栈无关 Mac unified，本机实测跑得动；③ 4bit QLoRA 数值灾难 → r9 发散后恢复=非灾难(lens1:66，真低精度发散不恢复)。

**elephant（没人谈但该谈）**：① M5 NA 全量支持 later this year，吞吐有上行（int8 ~2x），升级需 parity 重测；② mlx 0.31.2 是 launch 期版本；③ smoke 是 dev_selection dry-run，loss 数不可外推质量（本路只断言『栈跑得动』不断言『adapter 好』，质量归 L11/L13/C6 deferred）；④ grad-checkpoint 32GB 上从不需要，但 seq→4096 或 batch 加大时是现成逃生口。

## 10. must_answer 5 答

1. **prevents_0_34 = no**：训练栈跑不跑得动从来不是 0/34 root cause（0/34=surface/数据/masking 层，训练栈层实测全绿）→ **P2 escape_hatch**，不伪装 P0。
2. **vs_rank16mainline = support**：本路确认配方在本机栈实测跑得动、显存宽裕、loss 健康，repo-loop clip 补齐 stock 缺口，配方无需为训练栈改一字。
3. **requires_a2_surface_change = no**：训练栈（显存/吞吐/优化器/收敛）与 D-domain surface（语料形态）正交，完全不碰 A2。
4. **introduces_deferred = yes（边界内只描述不执行）**：提及正式训练/tiny时长/C6/mlx-lm-lora RL，但全程零执行（纯 scout+受票据+推演），符合 Phase 0；mlx-lm-lora/mlx-tune/RL=deferred 二期，明确标『现引入=越界，stock+repo-loop 已足』不推荐。
5. **priority_self = P2**。
# Lens 1 — 本机适配 / 硬约束：mlx-lm 本机训练实况 + loss 发散根因

> ultracode 深度研究 · 2026-06-21 · MAformac C5 LoRA 训练 · finder Lens 1
> 本机 scout（只读）+ 14 次 WebSearch + 1 次 WebFetch（>10 floor）

## 0. 本机 scout 事实（坐实，非推测）

| 项 | 实测值 | 来源 |
|---|---|---|
| 机器 | Mac17,2 / **Apple M5** | `sysctl hw.model / machdep.cpu.brand_string` |
| RAM | **32 GiB** (34359738368 bytes) | `sysctl hw.memsize` |
| mlx_lm | **0.31.1** | `python3 -c import mlx_lm` |
| Peak mem（训练）| **12.2 GB**（/32GB，极宽裕）| r9 mlx-smoke-600.log |
| Trainable | 1.013% (17.433M / 1720.575M) | smoke log |
| it/sec | 0.13–0.19 | smoke log |
| no_nan_or_inf | true | c5-smoke-receipt.json |
| no_oom_or_abort | true | c5-smoke-receipt.json |

最新轮次：r9/r10(14:35) → smoke-only(14:43, LR 实验) → **smoke-only-schedule(14:55, 带 cosine+warmup 的对照)**。

## 1. loss 发散的决定性证据链（两轮对照）

**r9（config 无 lr_schedule 块 → 常数 2e-4，无 warmup）：**
```
Iter1 Val 4.473 → iter10 train 5.711 → iter30 4.476 → iter60 8.359
→ iter70 17.747 → iter80 32.013(峰) → 回落 → iter600 train 4.713 / Val 4.680
```
val 反升（4.473→4.680）。receipt 自标 failure: `lr_schedule_not_effective_in_r9_constant_2e-4`。

**smoke-only-schedule（cosine_decay + warmup 48）同一份数据：**
```
iter10 LR 1.667e-05 loss 5.351 → iter20 LR 6.667e-05 loss 2.129
→ iter30 LR 1.000e-04 loss 1.069(!) → iter50 LR 1.833e-04 loss 1.648
→ iter60 LR 2.000e-04 loss 2.989 → iter70 LR 1.998e-04 loss 17.540(尖刺复现)
```
10-iter preflight **Val 2.317**（优秀）。

**两条铁律性结论：**
1. 数据**完全可学**（warmup 下 iter30 loss=1.069、val=2.317）——发散不是数据不可学。
2. **尖刺在两轮都发生在 LR 达峰 2e-4 时（iter70-80）**——坐实「LR 太高」是根因，warmup 只是推迟了爆点。

## 2. 根因分层（叠加，非单一）

| 层 | 证据 | 修法 |
|---|---|---|
| **#1 LR 太高** | 2e-4 = mlx-lm 默认 1e-5 的 20x、Qwen3 推荐 1e-4 的 2x；mid-spike=官方『LR太高』判据 | 降到 **1e-4**（保守）或 5e-5 |
| **#2 schedule/warmup** | r9 漏配 schedule；warmup 48 步按训练步算实际只 12 个 optimizer update(ga=4) | 带 lr_schedule object + warmup 按 optimizer-update 重算 |
| **#3 无 grad clip** | mlx-lm 默认 grad_clip=None，无尖刺保险丝 | 训练循环加 clip_grad_norm(max_norm≈1.0) |
| **#4 模板数据退化** | train.jsonl user 是固定模板 + epochs=3 → 隐式 epoch 膨胀 | 接云多源 generator + 随机化 + held-out 尾部评 |
| **#5 小有效 batch 噪声** | 有效 16 落在 8-16『最噪』区间 | 降 LR 后若仍噪升到 32 |

## 3. 外部搜证（每条带 source）

- **mlx-lm 官方默认 LR=1e-5**；mid-training spike = LR 太高，from-start high = 数据/格式问题。[LORA.md](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md) (2026-06)
- **Qwen3 官方 LoRA 配方 LR=1e-4 + warmup_ratio 0.05**。[Qwen3 disc #1301](https://github.com/QwenLM/Qwen3/discussions/1301) (2025)
- **MLX 社区 Ivan Fioravanti（SmolLM3）：『Use a small LR!』峰值 2e-5**。[tweet](https://x.com/ivanfioravanti/status/1942828490136354967) (2025-07)
- **Qwen3-TTS-1.7B 官方：默认 2e-5 太高 → 1.7B 用 2e-6**（小模型需更低 LR 的平行信号）。(搜索命中, 2025)
- **mlx 调度器 bug #2617**（cosine 在 warmup 期就衰减）+ **#985**（LR 衰减回 warmup_init）。[#2617](https://github.com/ml-explore/mlx/issues/2617) [#985](https://github.com/ml-explore/mlx-examples/issues/985)
- **mlx 默认无梯度裁剪**（grad_clip=None，仅 mlx-vlm 暴露 --grad-clip）。[clip_grad_norm doc](https://ml-explore.github.io/mlx/build/html/python/_autosummary/mlx.optimizers.clip_grad_norm.html)
- **Axolotl 调试**：loss 跳 2-10x 后(可能)恢复 → 降 LR 2-5x / 加 warmup / 查坏 batch / 加 grad clip。[training_stability](https://docs.axolotl.ai/docs/training_stability.html)
- **模板化低多样性合成数据 → 隐式 epoch 膨胀 → loss 塌缩**；缓解=多源 + 真实数据底 + 随机化。[arXiv 2506.19262](https://arxiv.org/html/2506.19262v2) [arXiv 2511.01490](https://arxiv.org/abs/2511.01490)
- **小 batch(8-16)最噪不稳**，梯度累积降噪但有效 16 仍偏噪。[Axolotl](https://docs.axolotl.ai/docs/training_stability.html) [arXiv 2507.07101](https://arxiv.org/pdf/2507.07101)
- **Qwen3 enable_thinking=false 注入空 <think>\\n\\n</think> 块**；train/serve 必须 token 级一致；2507+ 不再支持该 flag。[Qwen quickstart](https://qwen.readthedocs.io/en/latest/getting_started/quickstart.html) [Qwen3 disc #1300](https://github.com/QwenLM/Qwen3/discussions/1300)
- **mlx-lm #654**：fuse 进 4bit base + re-quantize 抹掉学到的行为（dynamic adapter 正确，fused revert）。[#654](https://github.com/ml-explore/mlx-lm/issues/654)
- **mlx-lm #828**：48GB 训大模型才撞内存墙（M5/32GB 训 1.7B 无关）。[#828](https://github.com/ml-explore/mlx-lm/issues/828)
- **真低精度发散『不会恢复』**——r9 恢复了 → 非 4bit 数值灾难。[arXiv 2506.20752](https://arxiv.org/pdf/2506.20752)

## 4. 数据 bug 实证（本机读出）

train.jsonl 一条样本：user `slots=position`，assistant 直接 emit 字面 `"position":"<position>"`——**未渲染占位符进了训练 target**，会教模型吐字面 `<position>`。正式训练前必修（对齐 SPOT 抠槽：占位符替成具体值 + 同步改 query）。

## 5. pre-mortem 三分类

**tiger（明确威胁，带验证）**：LR 2e-4 太高 / 无 grad clip / 模板数据退化+占位符 bug / fuse-4bit 抹行为(#654)。
**paper-tiger（看似威胁实际安全，给证据）**：内存/OOM/M5 性能（Peak 12.2GB 极宽裕）/ 4bit 灾难性发散（r9 恢复了=非灾难）/ smoke loss 4.68=学不会（warmup 下 val 降 2.317 证可学）。
**elephant（没人谈但该谈）**：warmup 单位错配（48 训练步实际 12 update）/ smoke 跑的是 dev_selection dry-run 非正式 train（所有 loss 数不可外推质量）/ Qwen3 底模版本(2504 vs 2507)决定 enable_thinking patch 去留 / masking train_on_turn=false（loss 可能没只算 ToolCall span）。

## 6. 给主线程/正式训练的 actionable

1. **LR 降到 1e-4（先保守对齐 Qwen3 官方），仍尖刺再 5e-5**——#1 杠杆。
2. **保留 lr_schedule object（r10 已修），warmup 按 optimizer-update 单位重算**（当前 12 偏少）。
3. **训练循环加梯度裁剪 clip_grad_norm(max_norm≈1.0)**（mlx-lm CLI 无 --grad-clip，须在 C5TrainingCLI 手动调）。
4. **正式训练接云多源 generator，不用 deterministic dry-run 训正式 adapter**；修 `<position>` 占位符渲染。
5. **端侧落地前跑 dynamic/fused/quantized 三路 parity**（#654 对应门，closeout 已标 not_run）。
6. **坐实 Qwen3 底模版本 + train/serve token 级 diff 空 think 块**（parity）。
7. **确认 loss mask 只覆盖 ToolCall span**（train_on_turn 待实现）。
8. **排除内存假设**——M5/32GB 训 1.7B-4bit 完全够，别在硬件找根因。

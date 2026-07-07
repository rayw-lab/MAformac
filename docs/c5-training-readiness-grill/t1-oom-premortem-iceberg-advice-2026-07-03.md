---
authority: commander_advice_not_training_config
artifact_kind: premortem_plus_bug_iceberg_teardown
status: advice_landed_read_only
created: 2026-07-03
proof_class: local_artifact_review + web_research + subagent_cross_check
decision_ref: D-053/D-054
run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/
---

# T1 OOM 复盘建议：pre-mortem + bug iceberg teardown

## 0. Commander 口径

**一句话**：不要把这次说成“token 爆了所以项目降级”。正确口径是：

> N4/N5E 机械与数据治理进展成立；T1 smoke 把正式训练前必炸点提前拦住。当前 blocker 是 `rank16 + 7 modules + 8192 + batch4 + 新监督面` 在本机 MLX/Metal 上无法完成首个 optimizer update。正式训练暂停，下一步开窄口径 T1-OOM 诊断矩阵，不降证明标准。

## 1. 本地事实

| 事实 | 证据 |
|---|---|
| T1 verdict | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/T1-SMOKE-RECEIPT.md`：`T1_SMOKE_FAIL_METAL_OOM_BEFORE_OPTIMIZER_UPDATE` |
| 触发点 | `T1-smoke/train.log`：validation 出 `Iter 1: Val loss 3.081` 后，随即 `[METAL] ... Insufficient Memory` |
| 未完成的门 | `optimizer_update_count=0`、无 optimizer row、adapter 未保存、watchdog 未触发 |
| 训练配置 | `batch_size=4`、`grad_accumulation_steps=4`、`max_seq_length=8192`、LoRA `rank=16`、7 target modules |
| token 现态 | 旧 N4A `trainable_tokens=44459/max_token_length=7186`；PR31 final/T1 `trainable_tokens=113914/max_token_length=7185` |

严格说，T1 不是 hang、不是 nonfinite、不是 DataGate failure、也不是 length violation。它是 validation 后、首个 optimizer update 前的 Metal OOM；更窄地说，最可能在第一轮训练 forward/backward/grad accumulation 路径上爆。

## 2. 联网证据

| 来源 | 相关结论 |
|---|---|
| MLX-LM LoRA 官方文档 | LoRA fine-tuning 需要充足内存；官方建议降 batch、减少 fine-tune layers、拆短长样本、开启 gradient checkpointing。链接：<https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md> |
| `mlx-lm#1348` | Qwen3-8B-4bit 在 rank>=16、7 modules、max_seq>=8192 形态下，validation 后确定性 hang；小配方 rank4/2 modules/4096 能跑。链接：<https://github.com/ml-explore/mlx-lm/issues/1348> |
| `mlx-lm#1206` | M5 Max 上 Qwen3.5-9B LoRA 可出现 validation 成功、first training iteration 立刻 Metal OOM 的形态。链接：<https://github.com/ml-explore/mlx-lm/issues/1206> |
| `mlx-lm#1185` | Qwen3.5 LoRA 还有 Metal resource/descriptor 累积类风险，说明“不只是字节内存够不够”的问题。链接：<https://github.com/ml-explore/mlx-lm/issues/1185> |
| MLX docs | MLX 在 Apple silicon 上使用 unified memory，并暴露 active/peak/cache/wired memory 管理 API，可用于诊断采样。链接：<https://ml-explore.github.io/mlx/build/html/usage/unified_memory.html> |

这些不是一比一根因证明，但足够把 T1-OOM 列为正式训练前的真 tiger：我们的配置正落在公开已知高风险面里。

## 3. Tiger / Paper-Tiger / Elephant

### Tigers

1. **T1-OOM 是正式训练硬 blocker**
   没有 optimizer update，没有 finite loss/grad row，没有 adapter save。任何 full train 都不能从这里向前推。

2. **训练显存门缺失**
   N4 preflight 证明的是静态数据/长度/语义门，不证明真实 backward 可跑。T1 说明 `preflight pass` 与 `train smoke pass` 必须分账。

3. **token 账被混用**
   E-2 解决的是 `max_token_length` 过 8192；PR31 final 增加的是 `trainable_tokens` 和监督覆盖。前者是上下文长度问题，后者影响 loss/backward 工作量。两者都叫 token 会误导调度。

4. **配方风险变量过多**
   当前同时高配：rank16、7 modules、8192、batch4、val_batches=25、新监督面。若直接多变量乱改，下一轮即使绿也不知道是哪一项救了命。

5. **CLI/manifest 默认值 footgun 已经咬过一次**
   refusal 默认 0.1 顶掉锁值 0 的事故说明：T1D 后所有配方变体必须 manifest 显式化，禁止凭 CLI 默认。

### Paper-Tigers

1. **“演示提示词 20 字，所以不会爆”**
   这只约束用户输入长度，不约束工具 schema、训练样本渲染、LoRA backward 显存。

2. **“E-2 失败了”**
   不成立。当前 `max_token_length=7185/7186 < 8192`，length violation 是 0。E-2 对长行生效了。

3. **“把 val_batches 降到 0 就好了”**
   只能作为诊断项，不能单独当解法。公开 issue 里 val_batches 0/1/25 都可能挂；我们本地 OOM 发生在 validation 后，但根可能仍在训练 backward。

4. **“打开 grad checkpoint 就稳了”**
   官方建议它省 activation memory，但公开 issue 证明它不是万能药。可以试，但不能跳过 smoke 门。

### Elephant

项目真正缺的是 **memory-budget proof gate**：过去门很多，但没有在 N4 阶段把“真实 backward 至少一更 + adapter save + memory profile”作为训练前一等门。T1 把这个缺口暴露出来，价值很高。

## 4. 给指挥官的动作建议

1. **开 T1-OOM grill，但限定 60-90 分钟**：只产诊断矩阵和 stop gate，不重开 N5E、function-call 方案、DSL 方案。
2. **下一步不是 full train，是 T1D diagnostic**：一变量一实验，唯一目标是找出可通过首个 optimizer update 的最小配方。
3. **严禁沉默降配**：batch、rank、target modules、max_seq、val_batches 任一改变都必须写入 manifest 与 receipt，proof class 标为 `diagnostic_not_candidate`。
4. **先从低语义风险项试**：batch 4->1、开启 grad checkpoint、validation 延后/降采样、采集 memory profile。rank/modules/max_seq 是质量相关高风险项，需单独签。
5. **新增 token 双账门**：每次 build 必报 `max_token_length` 和 `trainable_tokens` 两列；`length_violation_count=0` 不能再单独升格为 train-safe。
6. **demo 可以砍范围，不可砍 proof**：可以选择 demo-safe 小配方，但必须用 A/B/D/F-044 重新过验收，不能把“demo 项目”当成跳过门的理由。

## 5. 建议状态词

可以写：

- `N4/N5E construction/data-governance progress valid`
- `T1 smoke FAIL: Metal OOM before first optimizer update`
- `formal training blocked pending T1D memory diagnostic`
- `E-2 length downgrade effective; current risk is backward memory + supervision expansion`

不要写：

- `train-ready`
- `T1 hang`
- `token 爆了所以降级`
- `N4 绿所以可以正式训`
- `demo 项目所以可以跳过 smoke`

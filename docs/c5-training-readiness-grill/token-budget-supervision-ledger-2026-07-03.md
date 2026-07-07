---
authority: token_budget_and_supervision_ledger
artifact_kind: local_receipt_reconciliation
status: landed
created: 2026-07-03
proof_class: local_artifact_review
decision_ref: D-052/D-053/D-054
run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/
---

# Token 预算与监督面账（2026-07-03）

## 0. 先分清两种 token

| 名称 | 问题 | 当前状态 |
|---|---|---|
| `max_token_length` / prompt length | 单条训练样本渲染后是否超过 `max_seq_length=8192` | E-2 已把长行收回，当前 7185/7186，length violations=0 |
| `trainable_tokens` / supervised labels | 有多少 assistant token 真的进 loss/backward | PR31 final 从 44459 增到 113914，约 2.56x |

所以，“长行降档”解决的是第一类，不等于第二类显存安全。T1 OOM 暴露的是第二类叠加配方形态后的真实训练运行时风险。

## 1. 数字台账

| 阶段 | max_token_length | length violations | trainable_tokens | ignored_tokens | 说明 |
|---|---:|---:|---:|---:|---|
| pre-E-2 违规态 | 8982 | 294 | 未作为当前基线 | 未作为当前基线 | 17 个 `seat.massage_force_time` 工具挂载撑爆 schema |
| N4A historical | 7186 | 0 | 44459 | 15872999 | N4 local 验收时 strict preflight 绿 |
| PR31 final / T1 | 7185 | 0 | 113914 | 15802533 | 契约硬化后新验收基线 |

PR31 final 相对 N4A historical：

- `trainable_tokens`: `44459 -> 113914`，增加 `69455`，约 `2.56x`。
- `ignored_tokens`: `15872999 -> 15802533`，减少 `70466`。
- 总 token 近似不变：`15917458 -> 15916447`，差 `-1011`。
- 这说明主要不是样本整体变长，而是更多 assistant 区域从 ignored 变成 trainable。

## 2. split 级别差异

| split | N4A trainable_tokens | PR31 final trainable_tokens | 倍数 |
|---|---:|---:|---:|
| train | 40387 | 101919 | 2.52x |
| valid | 3113 | 9112 | 2.93x |
| test | 959 | 2883 | 3.01x |

valid/test 增幅更高，解释了为什么“validation 能跑”仍不代表训练能跑：validation 是 forward/loss，首个 backward 才暴露更大 activation/grad 压力。

## 3. 为什么 trainable_tokens 增加是 expected

PR31 final 的契约硬化消费了：

- `loss_objective_profile`
- `loss_mask.trainable_spans`
- `loss_mask.masked_think_spans`
- `loss_mask.trainable_assistant_end_token`
- assistant end token supervision

这是为了修正之前“字段存在但 loss 未必真消费”的灾难级风险。它是正确方向，但代价是训练显存面扩大。后续 receipt 必须同时报告：

1. `max_token_length`
2. `length_violations`
3. `trainable_tokens`
4. `ignored_tokens`
5. `trainable_tokens / (trainable_tokens + ignored_tokens)`
6. split-level trainable_tokens
7. `assistant_end_token_supervised_records`
8. `supervision_coverage_digest`

## 4. 预算门建议

| 门 | 阈值/动作 | 理由 |
|---|---|---|
| 长度门 | `max_token_length <= max_seq_length`，超限 fail | 防 prompt/truncation |
| 工具面门 | runtime/train/C6 tool tokens cap 继续守 `7200` policy cap | 给 state/user/generation/digest/grammar 留余量 |
| 监督面门 | trainable_tokens delta >20% 必解释 | 防“静态长度绿但 backward 压力翻倍” |
| split 门 | train/valid/test 各自列 trainable_tokens | 防 valid/test 监督变化被总数掩盖 |
| 配方门 | token delta 与 batch/rank/modules/max_seq 同表 | token 账必须能解释 OOM 风险 |

## 5. 给指挥官的短话

可直接贴：

> 这次不是用户 20 字 prompt 的问题。E-2 已经把最长样本从 8982 收到 7185/7186，length violation 为 0。新的风险是 PR31 final 把真实监督面从 44459 trainable tokens 扩到 113914，约 2.56x；这让原本 rank16+7modules+8192+batch4 的训练配方在首个 backward 前后暴露 Metal OOM。下一步要做 T1D 显存诊断，不是再泛泛降长行，也不是降低验收标准。

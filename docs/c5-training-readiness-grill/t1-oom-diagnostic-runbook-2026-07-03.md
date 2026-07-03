---
authority: diagnostic_runbook_not_training_authorization
artifact_kind: t1_oom_diagnostic_runbook
status: proposed_for_commander
created: 2026-07-03
proof_class: local_artifact_review + web_research
decision_ref: D-053/D-054
run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/
---

# T1-OOM 诊断 runbook（窄口径）

## 0. Goal / Non-goals

**Goal**：找到一个在本机 MLX/Metal 上能完成最小训练 smoke 的候选配方：至少 1 次 optimizer update、finite loss/grad、adapter save、OOM absent，并留下 memory profile。

**Non-goals**：

- 不做 full 600 micro-iter 正式训练。
- 不宣布模型质量、C6 acceptance、V/S/U-PASS。
- 不重开 N5E 数据扩量合同。
- 不把诊断绿升格为候选绿。

## 1. 固定基线

| 字段 | 固定值 |
|---|---|
| main pin | `b33d8eba152e5326f69bbe85fc356b73419ee9c3`（D-052） |
| data/config baseline | `PR31-final-n4a-recipe-build/` |
| model/backend | Qwen3-1.7B + project MLX train loop |
| current fail | validation 成功，first optimizer update 前 Metal OOM |
| current gate fail | `optimizer_update_count < 1`、adapter 未保存 |

每个诊断 run 必须记录：main sha、data sha、config sha、command line、changed knobs、proof class、exit code、metrics rows、adapter 是否保存、memory profile 文件。

## 2. Stop Conditions

立即停线并上抛：

1. 同一配方连续 2 次同形态 OOM。
2. 任何 run 没有完整 receipt 或 command line。
3. 多变量一起改导致无法归因。
4. 出现 adapter save 但 metrics 缺 optimizer row。
5. 出现 silent fallback 到 stock `mlx_lm` loss/mask 路径。
6. 想改 rank/modules/max_seq 作为“正式候选”但没有 owner signoff。

## 3. 一变量诊断矩阵

| ID | 变量 | 改动 | 目的 | 风险 | 通过门 |
|---|---|---|---|---|---|
| D0 | instrumentation only | 原配方不改，只加 memory/profile 捕获 | 拿到峰值和崩点 | 仍会 OOM | receipt + memory profile + same failure |
| D1 | batch size | `batch_size 4 -> 1`，grad_accum 保持显式 | 官方低风险省内存项 | 变慢；effective batch 需说明 | optimizer update>=1 |
| D2 | grad checkpoint | 显式开启 `--grad-checkpoint` 或等价配置 | 用计算换 activation memory | 可能不治 Metal/kernel 风险 | optimizer update>=1 |
| D3 | validation cadence | smoke 诊断中 `val_batches 25 -> 0/1` 或首更后再 val | 判断是否 validation 后残留内存触发 | proof class 降为 diagnostic | optimizer update>=1，但不能替代 eval smoke |
| D4 | batch + checkpoint | D1+D2 组合，只在 D1/D2 单项结果后跑 | 找低语义风险可跑面 | 两变量组合，需注明 | optimizer update>=1 + adapter save |
| D5 | max_seq | `8192 -> 6144/4096` | 验证长序列 activation 压力 | HIGH：改变训练覆盖，可能丢长样本 | 仅诊断；若候选化需另签 |
| D6 | LoRA surface | rank16->8 或 7 modules->q/v/o 小面 | 验证 LoRA trainable surface 压力 | HIGH：影响质量/F-044 | 仅诊断；需 A/B/D 重评 |
| D7 | MLX memory knobs | `set_cache_limit` / `set_wired_limit` / cache clear policy | 区分 cache/wired/resource 类问题 | 机器/系统相关，不可移植 | 只作 evidence，不作模型候选门 |

推荐执行序：D0 -> D1 -> D2 -> D3 -> D4；只有 D1-D4 全失败，才进入 D5/D6 高风险配方域。

## 4. 每个 run 的硬产物

| artifact | 要求 |
|---|---|
| `run-train.sh` | 完整命令，不能省略默认值 |
| `config.yaml`/manifest | 所有 changed knobs 显式化 |
| `train.log` | stdout/stderr 全留 |
| `metrics.jsonl` | 至少 preflight + optimizer row；若失败只到 val，要如实 |
| `memory-profile.md/jsonl` | active/peak/cache/wired 或可得系统指标 |
| `validation.json` | gate 判定：optimizer_update_count、finite_loss_grad、adapter_saved、oom_absent |
| `receipt.md` | proof class、claim/non-claim、下一步 |

## 5. 验收词

诊断通过只能写：

`T1D_DIAGNOSTIC_PASS_FOR_<knob-set>`：证明这组诊断配方能过最小 smoke。

候选训练前还需：

1. 固定候选配方 manifest。
2. 重新跑 strict preflight + DataGate。
3. 最小 smoke：optimizer update>=1、finite loss/grad、adapter saved、OOM absent。
4. 短训后过 F-044 A/B/D 锚与 parser/actuation 零容忍。
5. owner 明确 run-auth。

## 6. Commander 派单模板

```text
任务：T1D-OOM diagnostic，read/write only run_dir，禁止改 repo 代码。
固定：main b33d8eba，data/config PR31-final-n4a-recipe-build。
本批只改 <ONE_KNOB>，其它配置显式保持。
产物：run-train.sh/config/metrics/train.log/memory-profile/validation/receipt。
验收：optimizer_update_count>=1 + finite loss/grad + adapter_saved=true + OOM absent。
proof_class=diagnostic_not_candidate；禁止写 train-ready/V-PASS。
```


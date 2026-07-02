---
status: run_plan_final_pending_magnet_signature
artifact_kind: adjudication_a_tiny_ablation_run_plan
authority: run_plan_locked_no_scope_expansion（磊哥签 R7 Part B 后按本 plan 逐字执行；任何偏离=违规停）
created: 2026-07-02
companion: R7-renewal-and-tiny-ablation-run-auth-DRAFT.md（签字包）
as_of_main: aac84de9
---

# 裁决-A tiny-ablation 最终 run plan（tiny-only，零 scope 扩张）

## §0 一句话范围
**仅回答**：D-domain 范式在 20-50 样本过拟合训练下，能否把 θ-α 基线 empty tool-call 输出从 **28/34 打到 <5/34**（`C5TinyAblationHarness` 代码级锁死的门）。不是 wave-1、不是 formal train、不是 candidate、不是 C6 acceptance。

## §1 固定 output dir（权重绝不入仓）
```
/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/
├── build/          # C5TrainingCLI 产物（train.jsonl/mlx-data/mlx-lora-config.yaml/mlx-train-command.txt/C5DataGate receipt）
├── adapters/       # tiny LoRA 权重（run 后处置听磊哥，默认留此待审）
├── probe/          # 34-case 探针生成输出 dump（逐 case 原始输出）
├── verdict.json    # harness verdict（含 metric_source/28/34/<5 全字段）
└── RECEIPT-TINY-ABLATION.md  # 六段 receipt（blueprint §3 契约：preflight/manifest/train_health/probe/verdict/non_claims）
```

## §2 执行步骤（固定序，worker 执行 + commander 亲核每步 receipt）

**Step 0 — 解锁 diff（签字后唯一授权代码改动，独立小 PR）**
`C5TinyAblationHarness` 当前 `.realBlocked` 硬拦真源（`real_ablation_blocked_by_r7`）。加 `.real` 分支：仅当调用方传入 `runAuthorizationReference` = 本签字文档路径且 Part B 签字区非 unsigned 时放行；`.realBlocked` 仍为一切默认。+行为测试。**除此 PR 外全程零代码改动**（改 = scope 违规）。

**Step 1 — tiny 数据构建 + 数据门**
```
swift run C5TrainingCLI \
  --output-dir <RUNDIR>/build \
  --scope demo \
  --surface <d-domain 取值，起跑时以 CLI usage 回显拼写并原样记入 receipt> \
  --target-positive 40 \
  --masking-stage <enforce 取值，同上回显记录>
```
- 语义锁死：`--scope demo`（562 面）/ 正例 40 条（落 harness 20-50 窗口中段）/ masking enforce 态。两个取值拼写以 CLI usage 一手回显为准（**只校拼写不改语义**）。
- 门：C5DataGate receipt 必绿（must_not_train=0 / C6 保护零命中 / subset_policy_digest=`e2-lite-v1` manifest）；`build/mlx-data/train.jsonl` 每行含 `loss_mask`（token 三形态）。

**Step 2 — tiny 训练（真跑，本签字授权的核心动作）**
- 前置自检（必须先跑必须 pass）：`python3 Tools/C5TrainingCLI/c5_mlx_train_loop.py --self-test-loss-mask`
- 训练命令 = **`<RUNDIR>/build/mlx-train-command.txt` 渲染产物原样执行**（rank16Mainline 工厂渲染：`--require-maformac-loss-mask`/LR 1e-4/gradClip 1.0/iters 600/seed 固定）。🔴 **任何手改渲染参数 = 违规停**（tiny 过拟合正是目的，不调 iters）。
- 训中门：NONFINITE 熔断即停报；metrics.jsonl 落 `build/`。

**Step 3 — 34-case 行为探针**
- 用训后 adapter 对 **θ-α 同源 34-case probe 集** = C6 gold 57 case 中 `behavior_class=tool_call` 的 **34 个 case**（分母一手源：`make verify` 的 verify-c6-shape 输出 `"tool_call":34`；⚠️ 勿与 mp_positive action 轴 n=23/base 10/23 锚混淆——那是 candidate 比较口径，非本 run 的 empty 探针分母）逐 case 生成，原始输出全量 dump 到 `probe/`（checkpoint raw dump 纪律，防「凭聚合推」）。
- 统计 `emptyToolCallOutputs`（口径 = harness 同款：空 tool-call 输出计数，empty≠hit 纪律 F-005）。

**Step 4 — verdict（门在代码里，人不碰阈值）**
- `C5TinyAblationHarness().evaluate(metrics: .init(sampleCount: 40, emptyToolCallOutputs: N, metricSource: .real(ref)))` → `verdict.json`。
- **成功门（代码锁死）**：`N < 5` → status=pass → 报磊哥（🔴 **不自动开 wave-1**，下一步永远是磊哥新决策）。
- **失败门**：`N ≥ 5` → status=blocked → **进 Dim10 failure branch（F-076~095）归因**：🔴 **不改阈值 / 不扩大样本 / 不顺手开 wave-1 / 不擅自二次 run**（重跑也要磊哥新授权）；归因产物 = 失败分类（数据？配方？surface？）+ 证据 file:line 上抛。

## §3 与签字包的关系
本 plan 被 `R7-renewal-and-tiny-ablation-run-auth-DRAFT.md` Part B 引用；磊哥在 B.3 签字区落笔（`sample_count_approved: 40` 建议值）即授权**本 plan 全文且仅本 plan**。执行 worker 派单时本文件整体 inline，每步 receipt 回 %42。

## §4 Addendum v2（磊哥 2026-07-02 亲拍，仅修执行命令零 scope 扩张）

> 背景：Step1 首跑 BLOCKED（worker 按「偏离=停」正确停下）——原 plan 命令未列 `--dev-selection`，CLI 默认 `devSelectionRows=400` 把 40 条正例全部吸进 dev_selection → train 0 行 / loss_mask=null / offset fixture fail。磊哥拍 addendum：**只修命令形态**。

**Step 1 命令（v2 权威，取代 §2 Step 1 命令块）**：
```
swift run C5TrainingCLI prepare \
  --output-dir <RUNDIR>/build \
  --scope demo \
  --surface d_domain \
  --target-positive 40 \
  --dev-selection 0 \
  --masking-stage masking_complete_v1
```
- 其余一切不变：target-positive 40 / scope demo / surface d_domain / masking_complete_v1 / rank16Mainline 渲染原样 / 34-case 探针 / 门 <5。
- **Step 1 绿门（v2 新增，全部满足才进 Step 2）**：① train rows = **40** ② `train_eligible=40` ③ `loss_mask_present=40` ④ `mlx-data/train.jsonl` 存在 ⑤ `mlx-train-command.txt` 存在（+原有 C5DataGate receipt 绿 + subset digest）。

## §5 Addendum v3（磊哥 2026-07-02「推进 同意」，仅换已实装 masking 态 + 绿门对齐 builder 真实形态，零 scope 扩张）

> 背景：v2 BLOCKED——`masking_complete_v1` 的 argument_value 增广 main 未实装（builder honest 拒绝 exit 65）；且 builder 自动加 4 条 no-call 负例（44≠40）。CLI masking 枚举一手 = `smoke_only|trainable_v0|masking_complete_v1`。

1. **Step 1 命令的 `--masking-stage` 改为 `trainable_v0`**（main 已实装态）。训练循环层 token-level loss-mask 真消费不受影响（`--require-maformac-loss-mask` 恒渲染 + py preflight exit-66 兜底）。🔴 **「masking_complete_v1 argument_value 增广实装」= wave-1 硬前置缺口**，记入 landing-matrix gate2 行，不丢账。
2. **Step 1 绿门（v3 权威）**：positive=40 + builder 自动 no-call 负例（4 条，保留——负例防全正例训崩）= **总 44 行**（落 harness 20-50 窗）、全行 loss_mask_present、`train_eligible={True:44}`、DataGate `data_gate_ready`、`mlx-data/train.jsonl` + `mlx-train-command.txt` 存在。
3. **Step 4**：harness `sampleCount=44`。其余一切不变（40 正例语义/demo/d_domain/dev-selection 0/渲染原样/34-case 探针/门 <5/失败纪律/verdict receipt 诚实标「无 argument_value 增广」）。

## §6 Addendum v4（磊哥 2026-07-02「按 v4」，NONFINITE 根因修复，授权/不授权全列）

> 定性（磊哥接受）：非梯度爆炸——1024 截断把长记录的全部 trainable token（assistant 尾部）截没 → 整批 ntoks=0 → loss 除零 NaN。metrics 自动建议的 5e-5 fallback **不采纳**。

**授权仅限四条**：
1. 机械修：`maformac_masked_cross_entropy_from_logits` 对 ntoks==0 显式 fail-closed（报清「batch 无 trainable token」，不再 NaN）。
2. Step1/训前加长度门：每条训练样本 token length ≤ max_seq_length，否则停。
3. 渲染 `max_seq_length` 1024 → **8192**（对齐 E-2 运行时 8K 预算，训练面≡运行面）。
4. 继续 v4 run：样本仍 40 positive + 4 no-call，Step4 sampleCount=44，34-case empty 门仍 **<5**。

**不授权（红线原样）**：不降 LR / 不改 rank/scale/clip/iters / 不扩样本 / 不改阈值 / 不开 wave-1 / tiny 结果不得写成 formal train、C6 acceptance、candidate。

🔴 **证据纪律（磊哥点名）**：receipt 长度证据必须**实测 token 计数**（当前日志 longest=1236；commander 早先「~4,000+」系 chars 换算推测，作废勿引）。

# C5 LoRA 训练 ultracode 综合报告（2026-06-21）

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

> 综合官 probe 收敛 · 7 路 finder × MAformac C5 实况（Qwen3-1.7B-4bit / mlx-lm 0.31.1 / M5 32GB / 中文车控 FC LoRA）
> 关键增量：本报告用**本机两条 smoke 日志的逐 iter loss/LR 对照**，把"loss 发散"从推测降为**实测坐实的单旋钮问题**。

## 0. 决定性证据（本机日志，settle loss 发散之争）

两条 smoke 共享 **val@iter1 = 4.473**（同数据、确定性），可直接对照 LR 变量：

| iter | smoke-only-schedule（cosine+warmup, LR 爬升） | r9（常数 LR=2.000e-04 无 warmup） |
|---|---|---|
| 10 | 5.351 (LR 1.667e-05) | 5.711 (LR 2e-4) |
| 30 | **1.069 (LR 1.000e-04)** ← 甜区，证明数据完全可学 | 4.476 (LR 2e-4) |
| 50 | 1.648 (LR 1.833e-04) | 6.101 |
| 60 | 2.989 (LR **达峰 2.000e-04**) | 8.359 |
| 70 | **17.540** (LR 1.998e-04) ← 达峰即炸 | 17.747 |
| 80 | 14.861 | **32.013** ← 常数 2e-4 雪崩 |
| 600 | (350 步即收，~4.4 LR 衰减回低位) | val 4.680 / train 4.713 |

**结论（铁证非推测）**：iter30 在 LR=1.00e-04 时 train loss 降到 **1.069**（优秀）；尖刺**精确发生在 LR 爬到 1.5e-4→2e-4 的 iter60-70**。即 **LR=2e-4 是压垮点、1e-4 是甜区**，数据完全可学（1.069 证明）。这一条同时**证伪**了"数据不可学 / smoke=训练失败"的论断，也把根因从"内存/4bit/数据"四因叠加收敛为**首要单因=峰值 LR 过高**（次因=无梯度裁剪+零正则）。

`Reports/c5-lora-training-20260621T1455-smoke-only-schedule/mlx-smoke-only-600.log`（甜区 1.069 在此）
`Reports/c5-lora-training-20260621T1245-r9/mlx-smoke-600.log`（常数 2e-4 雪崩 32 在此）

本机 receipt 实证配置：`learning_rate=0.0002 / lr_schedule=cosine / lr_schedule_step_unit=optimizer_update / rendered_warmup_steps=12 / optimizer_update_steps=150 / rank=16 / scale=32 / dropout=0 / batch=4 / grad_accum=4 / max_seq=1024`；`generator_orchestration.status=dry_run_only`（generator 全 configured=false）；smoke-only-schedule 那条 `masking_coverage.train_on_turn=false`（loss 算全序列）。

## 1. 对比矩阵（7 lens × 关键维度，每格带 source）

| 维度 \\ Lens | L1 本机硬约束 | L2 超参配方 | L3 LoRA变体/框架 | L4 监控/复现 | L5 FC代码链路 | L6 issue oracle | L7 泛化/防记忆 |
|---|---|---|---|---|---|---|---|
| **loss发散根因** | LR2e-4达峰即炸(r9 spike签名)[LORA.md] | LR2e-4持续发散非良性spike[QLoRA 2305.14314] | 工程坑+数据非LoRA变体[#583/#985] | LR偏高+无clip+无mask放大[trainer.py] | dry-run数据+600步太短+空think[2602.04998] | dry-run同质串(数据/方法tiger非框架)[2602.09492] | LR上冲+dropout0+模板混合[#583/2602.04998] | 
| **梯度裁剪** | 加clip_grad_norm(1.0)[#1040] | stock无clip(最大elephant)[#1040] | — | trainer无clip需自加[trainer.py] | — | — | — |
| **LR建议** | 降1e-4再5e-5[Qwen3#1301] | 降1e-4(iter30已证)[ThinkingMachines] | 降LR治发散非变体[LORA.md] | LR sweep同seed[2602.04998] | 降到2e-5若仍崩[OpenAI cookbook] | — | 降1e-4/5e-5+dropout0.05[#583] |
| **内存/M5** | paper-tiger:peak12.2GB[#828] | — | mlx-lm单机硬约束守住[#2840] | peak_mem逐步打点[#738] | — | #1206只命中9B不命中1.7B[#1206] | — |
| **target_modules** | — | 全7模块正解别退attn-only[2405.09673] | 全linear正解(覆盖>rank)[ThinkingMachines] | — | mlx默认2模块不够已扩对[#2616] | — | — |
| **数据多样性** | 模板退化+占位符bug[2511.01490] | 等云多源真口语[2506.19262] | — | — | 模板格式记忆[2506.19262] | dry-run不该期待收敛[2602.09492] | 多样性>数量,移最被记10%[2510.16022] |
| **masking** | enable_thinking空think块parity[Qwen3#13] | — | — | train_on_turn=false抬基线[Unsloth] | 单区间mask只训末条+arg级做不到[trainer.py:75] | --mask-prompt只算末assistant[LORA.md] | arg-token mask防死记最有效[2510.12218] |
| **端侧fuse parity** | fuse进4bit抹行为三路parity[#654] | 4bit≠NF4稳定性不继承[2305.14314] | QDoRA 4bit灰区[2505.21895] | — | fuse进4bit掉点需--de-quantize[#654] | #654/#832/#1058反复+template跨引擎[#1058] | merge-into-4bit静默掉10-30%[kaitchup] |
| **held-out/泛化** | — | val早停train看不出过拟合[Raschka] | 缺通用能力回归探针[2401.05605] | val_loss早停+best非last[Unsloth] | distractor教辨别[2410.04587] | IrrelAcc反向权衡[2410.04587] | 三轴切+按bug_id分层[2508.04117] |
| **复现** | tokenizer patch漂移[Qwen3.5#13] | — | mlx-lm版本lock[#727] | 不自动seed+不load-best[#1919] | offset fixture需mlx实测[Qwen3深拆] | — | bit-exact不可得(GPU非确定) |

## 2. MAformac 当前训练风险清单

见结构化 `maformac_current_risks`（9 条，每条带 evidence_source + severity + action + vs现状）。摘要：
- **HIGH**：①峰值LR=2e-4过冲（实测铁证，降1e-4）②stock无梯度裁剪（加clip_grad_norm）③dry-run退化数据（接云多源）④端侧fuse 4bit parity未跑（真机三路实测）
- **MEDIUM**：masking train_on_turn=false / warmup单位偏少 / QLoRA口径+rank32缩放陷阱 / 零正则 / 无held-out+不自动seed/best

## 3. Pre-Mortem 三分类汇总

见 `pre_mortem_consolidated`。**steelman 守现状的项**（别误标 HIGH）：内存/OOM/M5性能（实测12.2GB无关发散）、4bit灾难性发散（r9恢复了=可恢复不稳非崩）、target_modules全7个（正解非风险）、rank16太小（单跳FC够）、rsLoRA/PiSSA/LoRA+（对rank16主线全不命中，新≠强）、#2617调度bug（已修于0.17.1，本机日志显示warmup正常爬升）、train>val（非过拟合是LR上冲产物）。

## 4. 监控清单 / 记录规范 / 泛化教训

见 `monitoring_checklist`（10 项含阈值）、`recording_standard`（10 项含receipt补environment/training_curve段）、`generalization_lessons`（11 条含held-out三轴+bug_id分层）。

## 5. 决策 + ⭐ 默认（grill 弹药）

见 `grill_ammo`（9 议题）。最高优先三拍：
1. ⭐**LR 2e-4 → 1e-4**（本机iter30已证1.069健康；单旋钮治发散）
2. ⭐**训练循环加 clip_grad_norm(1.0)**（stock无熔断；r9实测雪崩到32）
3. ⭐**optimizer adam → adamw+weight_decay=0.01**（零正则+高LR+无裁剪=完整发散配方；mlx原生支持改config一行）

三件套是"治发散"组合，**不动 rank/target/epoch**（根因在LR）。dry-run smoke 不当模型质量信号，**正式训练等云多源真口语 generator**，端侧 V-PASS 必须**真机三路 parity**。

## 6. 一手源指针

- 甜区证据：`Reports/c5-lora-training-20260621T1455-smoke-only-schedule/mlx-smoke-only-600.log`
- 雪崩证据：`Reports/c5-lora-training-20260621T1245-r9/mlx-smoke-600.log`
- 配置/血缘：`Reports/c5-lora-training-20260621T1455-smoke-only-schedule/c5-training-receipt.json`
- 训练实现：`Core/Training/C5LoRATraining.swift` / `Tools/C5TrainingCLI/main.swift`

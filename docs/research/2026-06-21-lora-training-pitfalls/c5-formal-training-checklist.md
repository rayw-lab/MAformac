# C5 正式训练完善 checklist(给 Codex 的执行门)

> **不是讨论稿,是执行门**:Q1-Q9 每题一条 config/code/receipt/eval 落点 + **fail/block 判据**,作为 C5 正式训练(本机 mlx-lm + 云多源数据)前的硬前置。
> 来源:2026-06-21 workflow ultracode 7-lens 调研 + 磊哥逐题 grill(决策口径见 `grill-decisions.md`,原理见 `lora-training-4-core-concepts-teaching.md`)。
> 落 raw(codex 占工作树),codex 收口后归位 docs/。

## 🔲 边界厘清(辩证:三层"云",别混)

| 层 | 在哪 | 本 checklist 立场 |
|---|---|---|
| **训练计算** | **本机 mlx-lm 0.31.x** | ✅ 唯一路径。1609 实测 Peak 12.2GB/32GB 可行。**云端训练(云 GPU/CUDA/unsloth)不考虑**(磊哥定) |
| **数据生成** | 云多源 generator API(hermes_glm 主 + 跨厂判) | dev-time API 调用,**非训练计算上云**,不违"云端训练不考虑",也不违 runtime 离线红线 |
| **runtime 推理** | 端侧 iPhone/Mac | 完全离线(红线) |

> ⚠️ **辩证 surface 给磊哥确认**:本 checklist 把"正式训练"理解为【本机 mlx-lm 训练 + 云 API 生成的数据】。若你"云端训练不考虑"也包含【不用云 API 生成数据】,则数据生成需回本机方案(但本机 generator 已被 probe 否决=frame-lock),请明示。默认按"训练本机/数据云生成"推进。

---

## 执行门(Q1-Q9)

### Q1 — 峰值 LR
- **落点**: `config: learning_rate=1e-4` + cosine + warmup(按 optimizer-update 重算占总 update ~5-8%)
- **fail/block**: 训练中途 loss 尖刺(单步>3x 且 20-30 step 不回落)/ grad_norm 非有限 / val 随 train 同步恶化 → **自动重启 5e-5**(repo loop `--nonfinite-fallback-lr` 已支持);5e-5 仍发散 → **BLOCK 人工查数据/mask**
- **状态**: ✅ 已实装验证(1609 实测 1e-4 loss 稳 0.6-1.5)

### Q2 — 梯度裁剪(repo-owned loop)
- **落点**: `c5_mlx_train_loop.py`: `finite_check → clip_grad_norm(max_norm=1.0) → optimizer.update`;`metrics.jsonl` 记 `grad_norm_preclip/clip_applied/nonfinite_stop`;`main.swift` 训练入口指 repo loop
- **fail/block**:
  - receipt `trainingBackend` 必须=repo-owned loop;**若仍=`mlx_lm.lora_stock_cli` → BLOCK**(clip 没生效)
  - **parity smoke**(clip disabled `max_norm=1e9` + 同 seed,repo loop vs stock CLI 前 N step loss **容差内一致** / token-mask 逐 batch 一致)未过 → **BLOCK**(证明 copy train body 没把 B1 masking 重打坏)
  - grad_norm 非有限 → `nonfinite_stop` + 重启 fallback LR
- **状态**: ⚠️ 代码层闭环(clip/finite/fallback 已插,grep 坐实),**运行时待实跑**(repo loop 还没产出带 grad_norm 的 metrics.jsonl + parity smoke 未跑)

### Q3 — dry-run loss 诊断边界(元原则)
- **落点**: dry-run smoke loss **只触发**工程健康排查(LR过冲/NaN/masking失效/clip未接入),**不触发**配方结构重构(rank/target/epoch)
- **fail/block**: 用 dry-run loss 改 rank/target/epoch = 违元原则;配方结构项必须等云多源真口语数据 + C6 eval(真能力信号)

### Q4 — rank/target_modules/epochs
- **落点**: `rank16_mainline`(rank16/scale32/全7 keys/num_layers=-1);`rank32_secondary` 仅 C6 显示容量不够 **+ 已排除数据多样性** + `scale=64` 或 rsLoRA
- **fail/block**: epochs=3 但**无 held-out val 集 + early-stop 机制** → 降 epochs=2;rank32 跑前未排除数据因素 → **禁跑**(假结论风险);target 砍到 attn-only → 禁(结构化 FC 全面劣)
- **状态**: ✅ 主线 config 已是 rank16/全7

### Q5 — optimizer
- **落点**: `optimizer=adamw + weight_decay=0.01`
- **fail/block**: optimizer=adam(零正则)→ 不达标
- **状态**: ✅ 已实装(1609 config)

### Q6 — 端侧 fuse parity(two-stage + fallback)
- **落点**:
  - stage1 `deployment_pipe_smoke`(现在,dry-run adapter): template byte parity + dynamic/fused-bf16/fused-4bit 三路可跑;`parity_stage` 字段;不签能力 V-PASS
  - stage2 真机三路 parity 签端侧 V-PASS
  - `C5FuseParityGate` 加 **IrrelAcc dynamic-vs-fused delta**(与 ToolCallExact delta 对称)
  - **端侧 enable_thinking 对齐硬检查**(端侧加载 patched tokenizer 或 mlx-swift 显式 enable_thinking=false)
- **fail/block**: ToolCallExact delta>2pp **OR IrrelAcc delta>2pp**(新增) OR mustPassRegression>0 OR parseFailures>0 → fail;端侧渲染字节≠训练(空 think 不一致)→ **BLOCK(B1 端侧重现)**;无真机 → 端侧 V-PASS blocked(**不能用 Mac 态签**)
- **状态**: 🔲 待实装(stage1 smoke + IrrelAcc delta + 端侧 enable_thinking 检查全未做)

### Q7 — masking loss-mask
- **落点**: receipt 拆 `prompt_loss_mask_effective=true / assistant_span=tool_call_only / argument_masking_mode=data_augmentation`;**dump 固化成 CI fixture**
- **fail/block**: CI fixture 断言失败(trained span 含 think OR 含 user 协议串 OR offset 不自洽)→ **BLOCK(B1/mask 失效)**
- **状态**: ✅ 实证验证(codex dump + CC 独立复现:tool_call 80tok/no-call 4tok,不含 think/user);🔲 拆字段 + CI 固化待做

### Q8 — DoRA secondary
- **落点**: 主线 `fine_tune_type=lora`;`dora_rank8_secondary` **仅主线 V-PASS 后**跑,同 C6 harness 同 seed 报 std,receipt 标 `training_type=qdora_secondary`(用同一 repo loop 保 clip/fallback 一致)
- **fail/block**: DoRA 当主线 → 违规;secondary 未报 std → 不可比;凭 Answer.AI 4bit 结论外推中文 FC → 禁
- **状态**: ✅ 主线守 lora;secondary 排期 V-PASS 后

### Q9 — 记录/追踪
- **落点**: `metrics.jsonl`(repo loop MetricsWriter emit)+ matplotlib;receipt 写真实 `metrics_jsonl_ref / best_checkpoint_step / best_checkpoint_val_metric`;Environment 段(seed/版本/硬件,已有);Trackio 仅 LR/rank/DoRA sweep 时引入(本地 SQLite,不上 cloud)
- **fail/block**: `metrics_jsonl_ref=not_emitted`(repo loop 没接入)→ 不达标;无 seed → 不可复现;wandb/mlflow cloud → 违离线红线
- **状态**: ⚠️ Environment 段已有;metrics_jsonl_ref 待 repo loop 实跑 emit

---

## 正式训练放行总门(全绿才跑云数据 candidate)

1. Q2 repo loop **运行时验证**过(parity smoke + grad_norm 真打点)— 当前 ⚠️ 代码闭环未实跑
2. 云多源 generator 接入(hermes_glm 主 + 跨厂 judge),数据非 dry-run deterministic 串
3. held-out 三轴切(换说法/没见过 arg 值/按 bug_id 分层)+ IrrelAcc≥20% 负样本就位
4. Q7 CI fixture 固化(防 B1 升级静默失效)
5. masking 占位符 bug(`<position>` 未渲染)修

> 训练后端 = 本机 mlx-lm,**云端训练不考虑**。数据云生成 vs runtime 离线见顶部边界表。

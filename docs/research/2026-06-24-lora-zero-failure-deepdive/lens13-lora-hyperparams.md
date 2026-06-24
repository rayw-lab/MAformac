# L13 — LoRA 超参 / 有效秩 / rank16Mainline 逃生口（一手档）

> **维度边界**：只管【超参对不对 + 何时逃生口】。跑不跑得动归 L01，数据配比归 L11，masking 归 L02，byte-parity 归 L03，行为中途门归 L05。**全程 steelman 守现状 + escape_hatch 定位，零碰配方、零碰 A2 surface、零越界。**
> 核验时间 2026-06-24 · 方法：WebSearch/WebFetch（US-only）≥10 + 本机 mlx-lm 0.31.1 源码 + C5LoRATraining.swift + c5_mlx_train_loop.py 一手 grep + home-llm config grep。

## 1. summary

守 rank16Mainline 是正确决策，三连证据：
1. **配方对齐业界 FC 黄金线**：rank16Mainline（`C5LoRATraining.swift:1210` rank16/scale20/LR1e-4/cosine/warmupFraction0.08/adamw+wd0.01/epochs3/7模块）几乎逐字命中 ToolACE-derived 工具调用最佳配方（rank16/α32/LR1e-4 cosine/warmup0.1/3ep/all-linear）。
2. **变体无增益（最强 steelman）**：`arxiv 2602.04998 "Learning Rate Matters: Vanilla LoRA May Suffice"`（IBM, 2026-02）系统扫 9 个 LoRA 变体（PiSSA/rsLoRA/DoRA…）× LR×batch×rank×时长全搜索，**LR 调对后全在 0.43-1.75% 内收敛**，"变体提升多是 LR 没调对的假象"。
3. **LR=1e-4 对 1.7B+rank16 是正确保守值**：小 rank 偏好略低 LR + LR≈10×full-FT 经验律 + 本机实测 2e-4 发散(iter80=32)/1e-4 稳(iter30=1.069)。

**562 intent 不是容量问题**：FC=学结构化格式（LoRA 强项/低内在维度）非数学推理（弱项/高内在维度）；rank16 在 500-task Mistral 多任务已实证够用。0/34 是 surface mismatch 非 undercapacity（loss 健康/行为塌缩=反向信号；欠容量签名是 train≈val 双低）。有效秩 ~12.1/16 是 AdamW 真实冗余（图178 锚坐实）但属 **P2 诊断旋钮非性能门**。

## 2. findings（每条带 source）

### F1 — rank16Mainline ≈ ToolACE FC 黄金配方 [support]
- ToolACE-derived FC 配方：rank16/α32/LR1e-4 cosine decay/warmup0.1/3ep/all-linear（q,k,v,o,gate,up,down）。
- rank16Mainline：rank16/scale20/LR1e-4/cosine/warmupFraction0.08/epochs3/adamw wd0.01/`defaultProjectionKeys`=7 模块（q/k/v/o + gate/up/down）= **逐项对齐**。
- **source**：WebSearch 2026-06-24 'LoRA alpha rank ratio FC best practice' + `C5LoRATraining.swift:1200-1235`（本机 grep）。
- **vs rank16Mainline**：support。home-llm 270M 用 2e-4 是小模型配方，1.7B 用 1e-4 更稳（见 F3）。

### F2 — "Learning Rate Matters: Vanilla LoRA May Suffice"（最强 steelman）[oppose 换装]
- `arxiv 2602.04998`（Yu-Ang Lee, Ching-Yun Ko, Pin-Yu Chen, Mi-Yen Yeh / IBM Research, 2026-02 v1, 2026-05 v2）：systematically re-evaluate **9 representative LoRA variants** alongside vanilla LoRA through extensive HP search（LR/batch/rank/duration）。
- 核心结论："**once learning rates are properly tuned, all methods achieve similar peak performance (within 1-2%)**"；Qwen rank128 三个数量级 LR 扫，全部 **0.43%** 内；Gemma math gap **0.52%**，Llama math/code **0.43%/1.75%**。
- 二阶分析归因：不同变体最优 LR 不同源于 largest Hessian eigenvalue 差异；"**improper learning rates give a false sense of LoRA advancements**"。
- **source**：WebFetch/WebSearch https://arxiv.org/abs/2602.04998（2026-06-24 核）。
- **vs rank16Mainline**：support 守现状 / oppose 换 DoRA/rsLoRA/LoRA+——换装不会赢，只引混淆变量+丢健康基线。

### F3 — LR=1e-4 对 1.7B+rank16 是正确保守值 [support]
- 经验律：LoRA-LR≈10×full-FT-LR（7B full 2e-5→LoRA 2e-4 / full 5e-5→LoRA 5e-4）。
- 但 `arxiv 2602.06204`（LR-rank scaling）："**smaller ranks favor slightly smaller learning rates**"+"**going 2× beyond optimum substantially degrades / diverges, particularly for smaller models (Qwen2.5-3B, RoBERTa-large)**"。
- 1.7B 小模型 + rank16 → 用 1e-4 而非 2e-4 = **对的保守选择**。
- 本机实测（R6 锚）：2e-4 iter80=spike 17-32 发散 / 1e-4 iter30=1.069 稳 / codex 1609 LR1e-4+adamw 实测稳 0.6-1.5。
- home-llm 实证（本机 grep `train/configs/*.yml:86-101`）：270M gemma 用 `learning_rate: 0.0002 / lr_scheduler: cosine / warmup_ratio: 0.1 / num_epochs: 1`——**确证 R6 风险'2e-4 易被照搬'，但 270M 配方不可照搬 1.7B**。
- spike 修法优先级（文献共识）：grad-norm 上升是早期预警 → **warmup > clip > 降LR**（clip 是 band-aid，warmup/LR 才是真修法）。
- **source**：WebSearch 2026-06-24 'LoRA 2e-4 loss divergence'（ikangai LoRA-without-regret + arxiv 2602.06204 + apxml stabilization）+ 本机 home-llm config grep。

### F4 — 562 intent 是格式任务非容量问题 [support]
- FC=学结构化输出（JSON/工具名 schema 映射）=LoRA **强项区/低内在维度**；数学推理才是 LoRA 弱项/高内在维度（rank16→32→64 commonsense 76.23→81.86→83.46）。
- rank16 多任务实证：Mistral-7B-Instruct 500 natural instruction tasks **全 rank16**（10 diverse + 490 random）。
- 欠容量签名（唯一可靠诊断）：**train≈val 双低于目标 + loss 在噪声底之上 plateau**（intrinsic dimensionality 未达）。
- 0/34 是 **loss 健康 / 行为塌缩** = **反向信号**（非欠容量）→ 加 rank 是误诊。
- **source**：WebSearch 2026-06-24 'LoRA capacity rank16 enough undercapacity'（mbrenndoerfer + 500-task Mistral + AIQ what-rank-is-good + Unsloth guide）。

### F5 — 图178 有效秩冗余坐实，但是 P2 诊断非主门 [unknown→P2]
- **图178 锚坐实**：Stiefel-LoRA（`arxiv 2508.17901`, EMNLP2025 Findings）实测 **LLaMA-3.2-1B rank16 LoRA + AdamW 有效秩≈12.1/16**（未满），B 列向量 cos 相似度 mean~0.003、**std=0.5143**（"linear independence not guaranteed under AdamW"）；Stiefel 约束（B^T B=I_r）后达 full rank 16。
- 有效秩 = exp(归一化奇异值的 Shannon 熵)；秩坍缩常是 **α 缩放伪影**（α 固定时高 rank 坍缩到低有效秩；α=2r 关键，Biderman）。
- rank16Mainline scale20（α 语义需 retrain 核，见 elephant）在 α=2r 安全区附近 → **不命中坍缩主线**。
- 处置：**P2 诊断旋钮**——C6 掉点查不出根因时，effective-rank/stable-rank/奇异值熵作下钻手段（gradience audit 工具：stable rank/energy rank/utilisation），**不进主门、不改配方**。
- **source**：WebFetch https://arxiv.org/html/2508.17901v1（2026-06-24 核 12.1/0.5143）+ `external-claims-verification.md:21`（主线程已核 ID 2508.17901）+ WebSearch effective-rank（johntnanney most-lora-rank + LoRA-vs-FT-illusion arxiv 2410.21228）。

### F6 — DoRA/rsLoRA/LoRA+ 定位分明，对 rank16+FC 都非命门 [oppose 换装 / escape_hatch]
- **DoRA**：增益只在低 rank(≤8) 显著（"biggest gain at low ranks ≤8"），rank16+ 萎缩；小模型/简单任务**常不兑现**（MNIST+小 MLP 实证无优势，"more stable but not always better"）；多 magnitude 参数略增过拟合。
- **rsLoRA**：救高 rank(≥64) 的 √r 缩放坍缩（α/√r），rank16 不命中；且非普适（LoRA-GA bench 里 rsLoRA MT-Bench 反低于 vanilla）。
- **LoRA+**：非对称 LR 是低成本 tweak（LoRA-GA bench GSM8K 52.11 vs vanilla 42.08）但不改 rank 容量。
- **source**：WebSearch 2026-06-24 'DoRA vs LoRA small model rsLoRA LoRA+'（NVlabs/DoRA DeepWiki + NVIDIA blog + LoRA-GA NeurIPS2024 + MNIST 实证 Medium）。
- **vs rank16Mainline**：oppose 换装（rank16 既不在 DoRA 甜区≤8 也不在 rsLoRA 甜区≥64）/ escape_hatch（C6 掉点且诊断为容量不足时才试 DoRA rank8）。

### F7 — mlx-lm DoRA-on-4bit 本机可跑（escape_hatch 可行性）[escape_hatch]
- 本机 `mlx_lm/tuner/dora.py`：`DoRALinear.from_base` 处理 `nn.QuantizedLinear`（:20）；`_is_quantized`(:108) + `_dequantized_weight`(:92) 用 dequant 算 magnitude norm → **DoRA-on-4bit-base 本机技术可跑**（非 PEFT 历史限制）。
- `DoRAEmbedding` 不支持量化（:140 TODO），但 rank16Mainline `excludesEmbeddingTargets`(`C5LoRATraining.swift:1237`)=true（不挂 embedding）→ **该限制不命中**。
- 但 QDoRA 推理被报极慢（PEFT 侧 magnitude vector 优化差），mlx QDoRA 是 feature request(`mlx-examples #714` OPEN) 非优化路径。
- `secondaryExperiments` 已列 `dora_rank8_secondary`（`:1233`）→ 作 A/B 备选已预埋，默认不启用。
- **source**：本机 grep `mlx_lm/tuner/dora.py:9,20,49,90,108,140` + `C5LoRATraining.swift:1233,1237` + WebSearch mlx-examples #714。

### F8 — clip/NaN-guard 已真实实装（堵 R6 loss spike）[support]
- `c5_mlx_train_loop.py`：`DEFAULT_GRAD_CLIP_NORM=1.0`(:49) + `clip_grad_norm` 在 optimizer.update 前(:244 `optim.clip_grad_norm(grad, grad_clip_norm)`) + `NonFiniteTrainingError`(:53) + `loss_finite = math.isfinite(loss_value)`(:320) + `nonfinite_fallback_lr=5e-5`(:50) → 代码闭环。
- **但 T5 守护**：superaudit P1 指 clip 从未真跑过 warmup 后段（健康靠 stock CLI 冒充）→ retrain 必 active-probe 验 preclip-norm>1 触发 clip（不凭代码存在推断已生效）。
- **source**：本机 grep `c5_mlx_train_loop.py:49,53,165,244,320`。

### F9 — C16 逃生口触发准则（falsifiable，给 propose）[support]
- **只在'诊断坐实欠容量'时才 reopen rank/LR**，证据必须是欠容量签名（held-out probe train≈val 双低 + loss plateau），**不是**：① loss spike（→走 clip/降LR 不换配方）② 单次 C6 低分（→先排查 surface/byte-parity/masking）。
- **换配方前必先排除前 4 路根因**（L05 surface 同源 / L03 byte-parity / L05 行为门 / L02 masking off-by-one）。
- **source**：`README-partial-6of18.md:52`（C16 reopen criteria 未触发）+ `stop-the-train-matrix R6`（C16 冻结 rank16Mainline）+ WebSearch 欠容量签名。

## 3. clone / 本机源码发现
- **mlx-lm 0.31.1 已装**（`~/Library/Python/3.13/.../mlx_lm`），`tuner/dora.py` DoRALinear/DoRAEmbedding 源码一手核（DoRA-on-4bit 可跑/embedding 不可量化）。
- **DoRA repo**（NVlabs/DoRA, 978★/2026-03-24, external-claims 已核活跃）未本机 clone（mlx-lm 已有原生实现，无需读 NVlabs CUDA 实现）。
- **home-llm**（已 clone `ref-repos/home-llm`）：`train/configs/*.yml` LR=2e-4/cosine/warmup0.1/epochs1（确证 R6 照搬风险）；用 axolotl(CUDA) 完全无超参逃生口机制。

## 4. paper 发现
| ID | 标题 | 本质 | applicable |
|---|---|---|---|
| 2602.04998 | Learning Rate Matters: Vanilla LoRA May Suffice | 9变体 LR调对后0.43-1.75%内收敛，vanilla 够用 | **yes**（最强守现状证据）|
| 2508.17901 | Riemannian Opt for LoRA on Stiefel Manifold | rank16+AdamW 有效秩12.1/16，Stiefel约束达full | unknown→P2（诊断现象非性能门）|
| 2602.06204 | LR Scaling across LoRA Ranks | 小rank偏好略小LR，2×超优化点小模型发散 | yes（证 LR1e-4 对）|
| 2312.03732 | rsLoRA α/√r | 救高rank≥64坍缩 | no（rank16 不命中）|
| 2402.09353 | DoRA | 低rank≤8增益最大 | no（rank16 萎缩）/ escape_hatch |

## 5. 假想验证（见 hypothesis_verification 字段，已写满）
预测=守 rank16Mainline 会成功且换装无增益；唯一真实风险在 surface/byte-parity/行为门/masking 四路（非超参层）。

## 6. premortem 三分类（见 premortem 字段：3 tiger / 4 paper-tiger / 4 elephant）

## 7. must_answer 5 答
1. **prevents_0_34**：no（超参非 0/34 根因，标 P1 守现状弹药+误诊防护，不伪装 P0）。
2. **vs_rank16mainline**：support。
3. **requires_a2_surface_change**：no（训练配方层，与 A2 surface 正交）。
4. **introduces_deferred**：no 不越界（纯搜证+假想验证+steelman，DoRA/rsLoRA 只作 escape_hatch 分析不实装；落 docs/research 不碰 contracts/）。
5. **priority_self**：P1。
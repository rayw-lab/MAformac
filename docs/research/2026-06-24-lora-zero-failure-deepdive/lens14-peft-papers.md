# L14 — PEFT 新结构论文逃生口（escape-hatch，禁污染 rank16 主线）

> 维度：PEFT 新结构论文逃生口。P2。默认 DROP 守 rank16Mainline。
> as-of 2026-06-24 | ≥12 WebSearch + 2 WebFetch + clone NLoRA + 本机 mlx-lm 源码 scout

## Summary（核心结论）

**默认 DROP，守 rank16Mainline。** 图175-179 提及的方法（NLoRA/SLoRA/Stiefel-LoRA/IntTune）+ CorDA（图173）+ 全部主流 variant（DoRA/PiSSA/MiLoRA/OLoRA/rsLoRA/LoRA+/LoRA-GA）逐个查证后，决定性证据来自两篇 **2026 年新论文**：

1. **arxiv 2602.04998「Learning Rate Matters: Vanilla LoRA May Suffice」**（2026-02-04，WebFetch 核实标题/作者/日期）：对 9 个 variant 跨 LR/batch/rank 网格搜索，**LR 调好后全部峰值差仅 1-2%**；在【与 MAformac 同族的 Qwen3-0.6B】上 **DoRA 仅领先 vanilla LoRA 0.15%、MiLoRA 0.43%、PiSSA 需 10× 不同 LR**。
2. **arxiv 2601.22708 统一研究**（2026-01-30）：『with proper hyperparameter configurations, LoRA consistently matches its variants』。

这两篇直接拆穿了图175-179 那些论文的精确数字（如 NLoRA GSM8K 56.48% vs +33.52%）——**那是弱 LoRA baseline（~23%）刷分的假象**，正是 2602.04998 警告的方法学陷阱。

**引入成本（炸场风险）**：本机 mlx-lm 0.31.1 **原生只支持 lora/dora/full**（lora.py:106 实证），所有 SVD-init/几何方法都要**手写 custom 训练代码** = 给 0/34 之后刚 parity 的脆弱训练链路加新故障面。**唯一例外 = DoRA**：mlx-lm 原生、978★活跃、已在 rank16Mainline 的 `secondaryExperiments=["dora_rank8_secondary"]` 内 = 零实现成本，作 rank8 低秩 **escape_hatch**。

**prevents_0_34 = NO**：PEFT 结构换的是 LoRA 内部参数化，0/34 根因是 surface mismatch（A2 已修）+ masking 假删 + 数据缺自然中文，**换 init 不修 0/34**。

---

## Findings（逐条带 source）

### F1 — mlx-lm 原生支持边界（实现成本硬证据）
mlx-lm 0.31.1（本机已装）原生只支持 `lora/dora/full` 三种 fine-tune-type。
- **source**：本机 `/Users/wanglei/Library/Python/3.13/lib/python/site-packages/mlx_lm/lora.py:106` `choices=["lora","dora","full"]` + `tuner/utils.py:135` `use_dora=(fine_tune_type=="dora")`
- **vs baseline**：oppose 采用任何 SVD-init/几何方法（除 DoRA 都需改训练链路 = 炸场风险）

### F2 — 决定性 steelman（同族小模型实测）
arxiv 2602.04998：Qwen3-0.6B（MAformac Qwen3-1.7B 同族）上 DoRA 仅 +0.15%、MiLoRA +0.43%、PiSSA 需 10× LR；9 variant 调好 LR 后差 1-2%。
- **source**：https://arxiv.org/abs/2602.04998（Yu-Ang Lee, Ching-Yun Ko, Pin-Yu Chen, Mi-Yen Yeh，2026-02-04，WebFetch 已核）
- **vs baseline**：support rank16Mainline（最强证据）

### F3 — 第二篇独立 2026 综述同结论
arxiv 2601.22708：proper hyperparameter 下 LoRA matches variants，无单一 init 胜出。
- **source**：https://arxiv.org/abs/2601.22708（Haonan He et al.，2026-01-30）
- **vs baseline**：support（非孤证）

### F4 — NLoRA 论文数字可疑 + 代码与 claim 有 gap
GSM8K SLoRA 56.48%/NLoRA 57.70% 声称 +33.52%/+36.41% → 隐含 LoRA baseline ~23%（弱基线）。clone 代码实测 `nlora_init` 是 block-copy（复制 param 子块），真 Nyström pinv 行被注释。
- **source**：https://arxiv.org/abs/2502.14482（WebFetch GSM8K）+ clone `ref-repos/NLoRA/peft/src/peft/tuners/lora/layer.py:306-342`（line 335 pinv 注释掉）
- **vs baseline**：oppose 采用 NLoRA

### F5 — DoRA = 唯一零成本 escape_hatch
mlx-lm 原生（dora.py 干净实现 magnitude m + direction norm）+ NVlabs/DoRA 978★/2026-03-24 活跃 + 已在 rank16Mainline.secondaryExperiments。
- **source**：本机 `mlx_lm/tuner/dora.py:43-123` + `gh repo view NVlabs/DoRA`（978★, 2026-03-24）+ `Core/Training/C5LoRATraining.swift:1210`
- **vs baseline**：escape_hatch（rank8 备选，不换主线）

### F6 — rsLoRA 在 mlx-lm 无落点
mlx-lm LoRALinear 用 `self.scale=20.0` 绝对缩放（`y+scale*z`），非 α/r，rsLoRA 的 α/√r 改动无处可插。
- **source**：本机 `mlx_lm/tuner/lora.py:84,98` + arxiv 2312.03732
- **vs baseline**：oppose（no-op）

### F7 — forgetting-prevention init 族是 paper-tiger
CorDA-KPA/OPLoRA/MiLoRA/LoRA-Null 声称防灾难遗忘，表面相关 0/34，但 0/34 根因（surface mismatch + masking 假删 + 异源 + 缺自然中文）与「遗忘世界知识」正交。
- **source**：https://arxiv.org/abs/2510.13003（OPLoRA）+ 项目 claim-vs-reality-gap.md 0/34 根因 + A2 PR#3
- **vs baseline**：oppose（换 init 不修 0/34）

### F8 — 热度交叉验证淘汰
NLoRA 6★/2025-03、MiLoRA 20★/2025-05、CorDA 56★/2025-01、PiSSA 427★/2025-06、LoRA-GA 219★/2025-11 全部 >半年未动或低星。仅 DoRA 978★/2026-03 达标。
- **source**：`gh repo view` 2026-06-24 全部实查
- **vs baseline**：oppose 采用任何（除 DoRA）

---

## Clone 发现（NLoRA 深拆）

clone 路径：`/Users/wanglei/workspace/raw/05-Projects/MAformac/ref-repos/NLoRA`（只读不进仓）

- **`peft/.../lora/layer.py:306 nlora_init()`**：实测复制 base weight 子块 `param[:r,:r]`（N）/`param[:r,:]`（A）/`param[:,:r]`（B）当初始化（line 323-329），**真 Nyström pinv 行 `torch.linalg.pinv(param[:r,:r])` 被注释**（line 335）。论文 README 声称 Nyström 三矩阵，释出代码是简化 block-copy = **claim-vs-code gap**。
- **`layer.py:344 slora_init()`**：SLoRA = 加一个 Kaiming 初始化的可训练 r×r intermediate 矩阵 N，forward 走 `B@N@A`（layer.py:634 `weight_B @ weight_N @ weight_A * scaling`）。
- **`layer.py:225 pissa_init()`**：标准 SVD（`torch.linalg.svd` → `Vr@diag(sqrt(Sr))`），residual 从 weight 减去。
- **adopt/adapt/drop**：全 DROP（intermediate matrix 思想即使要也需 mlx 手写，对脆弱链路加风险，零收益）。

---

## 假想验证（MAformac 真实场景：Qwen3-1.7B-4bit + mlx-lm 0.31.1 + 端侧 8GB + 已锁 LR 1e-4）

| 方法 | 预测 | 依据 | 失败模式 | 判定 |
|---|---|---|---|---|
| **DoRA-rank8** | better-or-equal（±0.5%） | mlx 原生 + 2602.04998 同族 +0.15% | per-step 重算 norm 略慢；微弱收益不足以翻盘行为塌缩 | **escape_hatch** |
| **PiSSA/MiLoRA/CorDA/NLoRA** | worse-or-unknown + 高炸场 | 需手写 mlx 代码 + PiSSA 需 10× LR 违反已锁 1e-4 + **4bit 权重做 SVD 量化误差污染分量** | SVD-init 偏差 → 数值健康但行为不可控（0/34 形态） | **DROP** |
| **rsLoRA** | no-op | mlx 用绝对 scale=20 非 α/r | 改动无落点 | **DROP** |
| **LoRA+/Stiefel/StelLA/LoRA-GA** | unknown + 实现成本极高 | LoRA+ 改 optimizer / Stiefel 需 Riemannian optimizer(mlx无) / LoRA-GA 需先跑 full-FT 梯度 | 为 1-2% 不确定收益重写训练内核 = 过度工程化 | **DROP** |

**结论**：4bit 量化 + mlx 原生 API + 已锁 LR 1e-4 + 0/34 后脆弱 parity 四重约束下，PEFT 新结构收益（同族 ≤0.5%）远小于成本（改代码 + 可能重启 LR 地狱）。守 rank16Mainline；DoRA-rank8 作零成本 escape_hatch 待 retrain-c5 propose 时按需启用。

---

## Pre-mortem 三分类

**Tigers（明确威胁 + 验证清单）**
1. 被 NLoRA「56.48% +33.52%」精确数字诱导采用 SVD-init（实为弱 baseline 刷分）→ 已核 2502.14482 隐含 baseline ~23% + 2602.04998 反证。
2. 为变体改 mlx 训练代码给脆弱链路引新故障面（4bit SVD-init 偏差 → 行为塌缩）→ 已核 lora.py:106 原生边界；retrain 必 incremental + parity gate。
3. PiSSA 需 10× LR → 采用即违反已锁 LR 1e-4，触发又一轮 LR 调参（重蹈 2e-4 发散）→ 已核 2602.04998 Hessian 分析。

**Paper-tigers（看似威胁实际安全 + 证据）**
1. forgetting-prevention init 能修 0/34 → 根因正交（surface 非遗忘），A2 已修 surface。
2. rsLoRA α/√r 能稳训练 → mlx 用绝对 scale=20 无落点。
3. DoRA 明显更强值得换主线 → 同族 Qwen3-0.6B 仅 +0.15%，作 escape_hatch。

**Elephants（没人提但该提）**
1. 这一路在 Phase 0 是纯 decision-pack，最大价值 = 给 retrain-c5 propose 一条 honest steelman（默认 vanilla LoRA + rank16Mainline，PEFT 变体全列 rejected-with-evidence），防未来 session 被 SOTA 数字诱导手痒。
2. 真正阻止 0/34 在数据层（自然中文语料 + 四类配比 + 异源 judge）和 surface 层（A2 已做），不在 PEFT 结构层。把精力投 init 选型 = 层级错配。本路必须明标 prevents_0_34=NO。
3. mlx-lm 活跃迭代（DoRA 都是后加），未来可能原生加 PiSSA/rsLoRA。届时『零成本』前提变，可重评估——但必须 vanilla LoRA baseline 先调到最优 LR 再比，且在 retrain-c5 之后。

---

## Must-answer 5 条

1. **prevents_0_34**：**no** — 换 LoRA 内部参数化不修 0/34 三大根因（surface mismatch 已由 A2 修 / masking 假删 / train-eval 异源 / 缺自然中文）。
2. **vs_rank16mainline**：**support（守现状）** — 两篇 2026 论文实证同族小模型 variant ≤0.5% 收益，rank16 vanilla LoRA 是验证过的正确选择。
3. **requires_a2_surface_change**：**no** — PEFT 全在训练参数化层，与 D-domain 具名工具 surface 正交。
4. **introduces_deferred**：**yes（越界）** — 真实采用需改代码+重训+LR重调+真实评测，全在 acceptance-archive DEFERRED 范围；本路严守=纯搜证+假想验证产出弹药，DoRA-rank8 仅记录不实装。
5. **priority_self**：**P2** — 纯 escape_hatch/decision-pack，唯一 actionable = DoRA-rank8 零成本备选 + 给 retrain-c5 列 rejected-with-evidence。

---

## 给 retrain-c5 propose 的 rejected-with-evidence 清单（actionable 产出）

| 方法 | 判定 | 一句话理由 | arxiv |
|---|---|---|---|
| vanilla LoRA rank16 | **KEEP（主线）** | rank16Mainline，已 parity 验证，2026 两篇论文证同族足够 | — |
| DoRA rank8 | **escape_hatch** | mlx 原生零成本，低秩略优，待 retrain 按需启用 | 2402.09353 |
| PiSSA | rejected | 需 10× LR + 4bit SVD 污染 + mlx 无原生 | 2404.02948 |
| MiLoRA | rejected | rank16 无收益 + mlx 无原生 + 20★淘汰 | 2406.09044 |
| CorDA | rejected | 防遗忘与 0/34 正交 + mlx 无原生 | 2406.05223 |
| NLoRA/SLoRA/IntTune | rejected | 弱 baseline 刷分 + 代码≠claim + 6★淘汰 | 2502.14482 |
| Stiefel-LoRA/StelLA | rejected | 需 Riemannian optimizer，mlx 无，实现成本极高 | 2508.17901 |
| LoRA-GA | rejected | 需先跑 full-FT 梯度，端侧不现实 | 2407.05000 |
| rsLoRA | rejected | mlx 用绝对 scale 无落点 | 2312.03732 |
| LoRA+ | rejected | 需改 optimizer，1.7B 非大宽度收益小 | 2402.12354 |
| OLoRA | rejected | QR-init，mlx 无原生，调好 LR 后无优势 | 2406.01775 |

> 所有 arxiv ID 见 external_claims，主线程可抽样 gh/WebFetch 亲核。
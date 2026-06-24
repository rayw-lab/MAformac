> ⚠️ DRAFT SKELETON（2026-06-23 第一个长跑起草，标 DRAFT 待人审 propose）
> 本 change 仅为骨架：proposal Why/What Changes 指向已拍决策，design.md 承载 Architecture Decisions，specs delta 占位待补，tasks 待细化。
> **守 agree-before-build：人审定 propose 前不进 apply、不写实现代码、不跑训练。** 决策权威源见下。
>
> 🔴🔴 **DEFERRED 延后（磊哥 2026-06-23「训练 + 后端开发延后」决策）**：本 change 的【训练 / 数据生成 / 评测】部分**延后不排期，A2 之后独立重新立项**。**仅 §2.1「训练样本 surface 翻案 → D-domain」(code-only) 属 A2、随 `migrate-d-domain-tool-surface` 完成**；§2.2 四类自然中文数据生成 / §3 实际重训(跑权重) / §4 C6 候选评测 = **DEFERRED**。A2 阶段 C5 样本生成器代码**只预留 D-domain shape 接口**——不生成语料、不调云 generator、不跑 judge、不实际重训。

## Why

C5 LoRA PR5 通宵 wave candidate `0/23`（action hard_pass 真口径 base 10/23）全面塌缩，已 UNSIGNED/BLOCKED。θ-α generated-positive 全 checkpoint 实测 FAIL（训练数值健康但 C6 action 行为全塌）。范式翻案坐实根因 = **generic frame `tool_call_frame` 单工具判定面爆炸、1.7B 学不会**（非只 surface mismatch）。修法 = model-visible surface 改 **D-domain 具名工具**，训练面与推理面 parity（C5 0/34 根因 = 训/eval surface 异源）。

本 change = A2 6 步依赖序 **[4] C5 surface / 正样本 / 用户文本** 段，依赖 `migrate-d-domain-tool-surface`（上游产 D-domain surface）。用 D-domain 具名工具重做 C5 训练数据（10 族 562 intent / 四类数据），守 `rank16Mainline` 配方 + LR 1e-4（surface 迁移非配方问题，不重开）。

**决策权威源**：
- 范式 + 四类数据：`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`（C1 四类数据 = 云 generator + 异源 judge + contract 定标签 + 原文 oracle 非训练集；§13 G4 scope_tier 拆）
- C5 recovery：`docs/c5-recovery-2026-06-22/grill-decisions.md`（C6 真口径 base 10/23 / readback 走方案 P / 两层 SSOT / make verify 门 / 范式据 tiny 对照实验）
- C5 21 主议题收口 + θ-train：`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`（C5 LoRA 原始 21 主议题第一~四批全收口）
- 现有训练方法契约：archived `openspec/specs/lora-training/spec.md`
- 级联账本：`docs/grill-tournament/cascade-inventory.md`

## What Changes

> 以下指向已拍决策，**具体逐文件改法 = `docs/grill-tournament/cascade-inventory.md` 各 path 的 verdict + what_to_change**。

- **训练样本 surface 翻案**：samples 中 expected_tool_calls 映射到 **D-domain 具名工具**（非 `tool_call_frame`）；`sample_shape` 从「tool_call_frame」改「D-domain 工具集」（cascade-inventory T1 `lora-training/spec.md` verdict）。
- **10 族 562 intent scope**：训练数据按 10 族 explicit allowlist（191 device / 562 intent / 2159 行 / 54.1%）；scope_tier 拆：候选 562 / compact positive [TBD-待 A1 scope_tier 拆后重算] / +unsupported/safety/followup = LoRA 四类数据（paradigm §13 A3 / §14:232 标 compact positive 418 为 codex 口径不同【待重算】，master §0 口径表列 418 为废口径禁引；DRAFT 占位足矣，propose 时按 A1 重算填实）。
- **四类数据**（C1 拍板）：①正样本（D-domain 具名工具）②unsupported（族外兜底）③safety（L4 安全拒识）④followup（多意图连续两句 / 短时记忆 DialogueState）。来源 = 云 generator 生成 + 异源 judge 把关 + contract 定标签 + 原文 oracle（非训练集）。
- **训练面 = 推理面 parity**：训练 surface 从上游 A2 codegen 单源派生（防 0/34 异源根因 Q05）。
- **守配方**：rank16Mainline scale=20 + LR 1e-4 + adamw + 梯度裁剪 repo loop + masking 实证（21 议题已收口，不重开）。
- **单语中文 LoRA**：多语种走协议转换复用非重训（印证交付手册语言无关协议层）。
- spec MODIFY：`lora-training`（sample_shape → D-domain；samples expected_tool_calls → D-domain 具名工具）。

## Phase 0 Decisions Required Before Apply

The D1-D10 user decisions are accepted in `docs/project/phase0/phase0-d1-d10-user-decision-record.md`. This removes the pending user-decision gate only; it does not authorize data generation, training, model-quality evaluation, endpoint-ready claims, voice, or demo-golden execution.

- D2: mid-training behavior gate runs at iter50/100/150 with `continue/human_pause/early_stop/blocked`; it is behavior-generation evidence, not val-loss evidence.
- D3: four-class ratio starts as positive 20 / unsupported 6 / safety 3 / followup 2, about 15.4% negative, and remains a hypothesis until spike evidence finds the over-refusal bend.
- D4: SFT first and DPO deferred; reopen DPO only if SFT plus natural Chinese data still leaves seven demo-critical refusal cases at 0/7.
- D6: general Chinese mix starts at 10-15% and requires a Chinese regression gate against raw Qwen3-1.7B; candidate degradation greater than 5% is `UNSIGNED`.
- D7: failure/error-recovery cuts full HA-style chains and keeps only minimal parser-failure seeds with loss-masked failure turns.
- D10: `already_state` is an independent fifth state class. Default owner is C3 plus readback renderer; model training only learns answer wording unless C6 evidence shows natural-language `already_state` FN >20%.
- D3/D6/D7 must run on the same candidate ID; D2/D3/D6/D7 evidence remains `UNSIGNED` until physical receipts exist.
- `train_health`, loss health, and training receipts do not imply `model_quality`, `lora_candidate`, `endpoint_candidate`, V-PASS, or demo readiness. A candidate remains `UNSIGNED/BLOCKED` until C6 model-quality gates and required human reviews pass.
- Codex/Claude same-vendor audits are pre-check only. R-L17 high-stakes signoff requires G1-G5: D1-D10 accepted, R1-R7 evidence files, at least one heterogeneous deframing audit, no four-model consistent-PASS bypass, and human-owner escalation for any judge disagreement.
- Training, real evaluation, endpoint-ready claims, voice, and demo-golden execution remain deferred until gate tasks are accepted.

## Design/Task Layering

Architecture Decisions are recorded in `design.md` as `AD-C5-*`. `tasks.md` only carries executable checklist items, evidence artifacts, and validation steps that implement those decisions.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `lora-training`: 训练样本 surface 从 tool_call_frame 翻案为 D-domain 具名工具；10 族四类数据 scope；训练面/推理面 parity 单源派生。

## Non-Goals

- 不重开训练配方（守 rank16Mainline scale=20 / LR 1e-4 / adamw / masking 三形态 / 梯度裁剪 repo loop，21 议题已收口）。
- 不重写 archived `lora-training` 方法契约（本 change 是 D-domain 重训执行，非方法重定义）。
- 不训 12k bug 语料进训练集（仅作 failures/refusals 增广来源，原文 oracle 非训练集）。
- 不用 stock `mlx_lm.lora` 跑正式 candidate（用 PR2 verified repo loop）。
- 不签 endpoint V-PASS（Mac-only / simulator 证据不足）。
- 不用 generic frame `tool_call_frame` 作训练 surface（θ-α 0/23 根因）。
- 不复制真实座舱原文语料进训练集（分级脱敏红线 + 真实 bug 训练集不入仓不上云，仅 LoRA 权重产物入仓）。

## Success Criteria

> DRAFT 占位，propose 时细化为可验收标准。骨架方向：

- `openspec validate retrain-c5-lora-d-domain --strict` + `--all --strict` pass。
- 训练样本 expected_tool_calls 全为 D-domain 具名工具，无 `tool_call_frame` 残留。
- 训练 surface digest == 上游 A2 codegen surface digest（训/eval/runtime 三处单源 parity）。
- Architecture Decisions for R-L09/R-L02/R-L03/R-L05/R-L07/R-L11/R-L17, D6 general Chinese regression, D10 already_state, and status boundaries exist in `design.md`; `tasks.md` references those ADs rather than carrying the decision source alone.
- 四类数据（正样本/unsupported/safety/followup）覆盖 10 族 562 intent scope；scope_tier 计数对齐 G4。
- candidate C6 action hard_pass 相对 base 10/23 不退化（最低门）→ 目标提升（防 0/23 复发）。
- 训练 receipt 记 scale=20 / LR 1e-4 / verified loop SHA / clip 指标 / nonfinite 检查 / masking 覆盖。
- 7 demo-critical case（安全拒识/ASR 澄清/工具映射，base/lora 都 0/7）通过训练而非放宽判等改善。

## Non-Automated Success Signals

- reviewer 可追每条 candidate claim 到 archived `lora-training`、上游 D-domain surface、四类数据 generator/judge/oracle、C6 receipts、parity receipts、异源审计 index。
- closeout 清晰区分 runnable development adapter vs endpoint-ready demonstration artifact。

## Impact

- 影响 `Core/Training/C5LoRATraining.swift`、`Tools/C5TrainingCLI/`、四类数据 generator（云）、masking/dataquality gate（逐文件改法见 cascade-inventory）。
- 训练 surface 依赖 `migrate-d-domain-tool-surface` 产出的 D-domain codegen（依赖序 [1]→[4]）。
- delta spec：`specs/lora-training/spec.md`。
- 依赖 archived `openspec/specs/lora-training/spec.md` + active change `migrate-d-domain-tool-surface`。
- 下游：rebuild-c6-four-layer-bench 用本 candidate 做 base-vs-LoRA diff。

# LoRA 零容错 18 路深度调研 — INDEX

> **topic**: MAformac 端侧 Qwen3-1.7B + LoRA D-domain 训练零容错调研（防 C5 0/34 复发）
> **date**: 2026-06-24（通宵任务）· **状态**: ✅ **COMPLETE**（18 路 + 全 18 综合官 + 主线程亲核）
> **定位**: pre-propose decision-pack + 假想验证 + 论文/肩膀搜证，**不执行训练/评测/voice**（Phase 0 acceptance 边界）。服务后续 retrain-c5 / rebuild-c6 OpenSpec propose。

## Workflow 记录（3 次）

| # | Task ID | Run ID | 内容 | 结果 |
|---|---|---|---|---|
| 1 | w2wgc4e58 | wf_0eee15c7-28a | 18 路首跑（每批 6 并行）| 6 路成功 / 12 路 rate-limited |
| 2 | w22j8b12x | wf_d8990f43-406 | 12 路补跑（4 批 ×3 降并发守 cap）| **12/12 全成功** |
| 3 | wsev1f5kx | wf_8a344840-00d | 全 18 路最终综合官（单 agent 读全 18）| ✅ 完成 |

usage：3 workflow 共 ~580 万 subagent token / 596 tool_uses / ~2.3h。transcript 仓外 `~/workspace/raw/05-Projects/MAformac/research/lora-deepdive-transcripts/`（3 个 .output + jsonl）。

## 最终报告清单（落盘文件）

| 文件 | 内容 |
|---|---|
| **README.md** | 综合官完整报告（每路精华 + 0/34 根因对应 + 守现状 + 下一步）|
| **stop-the-train-matrix.md** | 🔴 核心交付物：全 18 路风险矩阵（第一梯队 8 个阻止 0/34 硬门 + 第二梯队防发散）|
| **comparison-matrix.md** | 18 路 × 维度对比矩阵 |
| **decisions-and-grill-ammo.md** | 待磊哥拍板决策 + grill 弹药 + steelman 守现状 + premortem 三分类 |
| **external-claims-verification.md** | 🔴 主线程亲核：14 个 arxiv ID（catch 1 疑似编造 2603.03203）+ 11 repo 活跃度 |
| **synth-external-claims-and-conflicts.md** | 综合官 external_claims 汇总 + 与 Phase 0 冲突检查（零硬冲突）|
| **lens01..lens18.md** | 18 路 finder 一手档（每个小 lens 独立输出）|
| README-partial-6of18.md / *-partial.md | 6 路初版综合（历史，已被全 18 版覆盖）|

## 18 路 P0/P1/P2 分级（综合官按能否提前阻止 0/34）

- **P0（8 个直接阻止 0/34 硬门）**：L09 样本可观测 / L02 loss-mask / L03 chat-template byte-parity / L05 训练中途行为门 / L04 C6 四层门 / L07 数据配方负类 / L17 人审破框 / L16 治理矩阵
- **P1（防二次灾难/炸场）**：L11 反巧合 / L08 数据泄漏 / L12 SFT-vs-DPO 拒识 / L10 灾难遗忘 / L06 端侧部署 / L15 home-llm teardown / L13 LoRA 超参
- **P2（escape-hatch/未来）**：L01 训练栈 / L18 voice side / L14 PEFT 新结构

## 主线程亲核成果（防编造，ultracode 横切纪律7）

- 🔴 **catch 1 疑似编造**：`2603.03203`（5 路引用，WebSearch 搜不到）→ propose 引用前必复核。
- 🔴 **坐实守现状最强背书**：`2602.04998`（11 路）= Vanilla LoRA May Suffice，调好 LR 后不输 9 个新变体。
- 🔴 **L12 拒识方法张力**：L12 finder 认为 MAformac 拒识=确定性上下文可判 → SFT 正例够、0/7 真因是数据缺失；但外部 Abstain-R1(2604.17073)/When2Call(2504.18851) 支持偏好优化（DPO/RL）—— **需 grill 拍**。
- 14 个 arxiv ID 核验落 external-claims-verification.md（5/6 高频真实+引用准确）。

## 与 Phase 0 关系

- 输入：`docs/loop-competition/2026-06-24-phase0-grill/{final-list,ledger,acceptance-archive}.md`（24 grill 接受态）
- 冲突检查：**零硬冲突**，18 路全 support/细化 Phase 0 决策（C13/C14/C16/C17/C18/D14 等直接对应）。
- 用途：stop-the-train 矩阵 + grill 弹药 → 后续 retrain-c5/rebuild-c6 OpenSpec propose 的 gate task 弹药。

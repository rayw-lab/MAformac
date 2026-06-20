# Handoff 2026-06-20 深夜 — P1-A/P1-B 收口 + push + P1-C 评估

> append-only（collaboration §4.5，永不回改）。supersede 同日早先 closeout 的续接口径，以本条为最新。

## Goal
MAformac 端侧离线 demo。P0 收尾后并行 P1-A C5 数据门 + P1-B Qwen spike，收口并评估 P1-C LoRA train 能否启动。

## Constraints & Preferences
1. **不降级**；统一口径：字段不降级 runtime 不膨胀，合同先保留执行按依赖分批。
2. **选型/版本断言必联网搜证**（Qwen3.5-2B 复犯已沉淀 pre-mortem-reflex）。
3. **单工作树并发硬 gate**：本 session P1-A/P1-B 又单工作树并行（pre-mortem 已警告 TIGER-1），靠文件域不重叠 + 各拆 clean commit 化解；push 前先理清 main/origin 真位。
4. 称磊哥 / 中文 / 选择题打字列+⭐。

## Progress (Done / In Progress / Blocked)
- **Done**：P0 链(P0-2/3/4+archive) + P1-A + P1-B **全 push origin/main `846e40c`**。
  - P1-A C5 data gate **V-PASS**：`define-lora-data-gate` change + C5DataGate validator + receipt(3670 行；must_not_train=0/parent_overlap 真 0/C6 42+12 trap 零进 train/validator exit65/raw 只读)。masking_coverage 全 false 如实记录。
  - P1-B Qwen spike **BLOCKED**：S1 真采 Qwen3.5-2B 8/11=72.7% 劣于 1.7B 9/11=81.8%；S2 无真机；artifact 实为 VL 借文本塔。decision=守 1.7B。
  - **CC 二层对抗审计*2 CLEAR**（P1-A 无泄漏真阻断 / P1-B 无权重入仓 decision 诚实，修 BLOCKER-1 VL 披露）。
  - 合并态实跑：openspec 7 passed / swift test 85 0fail / make verify ok。
- **In Progress**：P1-C 启动评估（需 grill）。
- **Blocked**：P1-C train（masking 数据生成未做 + 训练环境未定）。

## Key Decisions
- **模型已定 = 训 Qwen3-1.7B**（P1-B spike：2B 全面劣于 1.7B + 无真机 + VL 包体负担；spike decision 守 1.7B）。
- **main 历史真相**：P0-2/3/4+archive 之前只在 `codex/p0-2` 分支(883f1af) 未合 main；本次拆 P1-A/P1-B clean commit 后 ff main（`044b7f6→846e40c`）一并带上 P0 链。
- P1-A masking_coverage 全 false 诚实保留，不当 train 已就绪（Hermes Important，codex 不洗白）。
- BLOCKER-1：P1-B artifact 是 VL 多模态，文档补 VL 披露 + 纠 Hermes「无 VL」误判（不篡改 Hermes 原始记录）。

## Next Steps
1. **P1-C 启动 grill**（下一步，重大设计先讨论别急派）— 拍两前置 + 配方：
   - ① **masking 数据生成**：masking_coverage→true（train_on_turn / arg-token / function masking，Hammer/GOAT 配方，见 memory `maformac-lora-train-eval-stack` + teardown-data）。防死记 3HIGH 之一，是 C5 数据门补完。
   - ② **训练环境**：Mac M5 无 NVIDIA → unsloth/CUDA 不可本机。选项：云 GPU（租）/ mlx-lm 本机 LoRA fine-tune（须联网搜证 Mac 1.7B LoRA 可行性，不凭知识库）。
   - ③ 训练配方：3670→train 2320 够不够 / 增广配比（templated 最重 10-25x）/ per-checkpoint 选最优。
2. P1-C train（两前置过后）：same C6 harness diff，base 1.7B↔LoRA with 权重 fingerprint(P0-2) 锁。
3. P2 C4/C7 解冻（C5 第一轮 checkpoint 后）。

## Critical Context
- push：origin/main `846e40c`（P0 链 + P1-A + P1-B 线性）。
- 产物：`Reports/c5-data-gate-20260620-192100/`（receipt）+ `Reports/qwen35-2b-spike-20260620-192146/`（spike）。
- 起手读：`CLAUDE.md §9` → `docs/roadmap-2026-06-20-from-c6-done.md §4-P1`(已更新) → 本 handoff。
- **遗留 NIT**（留 P1-C / C6.1）：P1-A（redaction 无负向 test / C6 semantic-parent 走 P1 overlap 可提 P0 must_not_train）+ P1-B（root parser-transcript 命名 / `dev/spike-e3/.../main.swift` AC range 16-30 旧值与 18-32 真值不一致，spike fixture 漂移）。

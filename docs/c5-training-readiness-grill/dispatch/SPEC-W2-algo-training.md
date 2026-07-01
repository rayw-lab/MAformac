# SPEC W2 — C5 grill 算法训练官（worker @ %43 codex-2）

你是 codex worker（pane `%43`），commander 是 Claude（`%42`）。
任务 = **C5 训练就绪 grill·算法训练线**：脑暴维度 4/5/8 的关键决策（第一轮 ~45 条，每维度 ~15），按 UIUE 215-grill 决策矩阵范式。
🔴 **角色 persona**：代入【LoRA 训练算法工程师 + 论文复现者】视角深 grill——挑剔超参/配方/masking/收敛/checkpoint 选择/论文依据严谨性。
🔴 cwd 是 MAformac-uiue → **`cd /Users/wanglei/workspace/MAformac`** 做主体（grill 写 docs，不改代码、不实装、不训练）。

## 🔴 起手必读（grill 范式 + 论据源）

1. `docs/c5-training-readiness-grill/README.md`（grill 范式 §4 + 双仓惨败纪律 §1）。
2. 上游论据源（cite 一手 file:line，落笔前 grep 核）：`Core/Training/C5LoRATraining.swift`（训练配方）+ `~/Projects/agent-tmux-stack-research/runs/2026-06-30-lora-teardown/LORA-TD-1-training-code.md`（训练代码纵切）+ `LORA-TD-2-papers.md`（论文层 arxiv ID）+ `docs/research/2026-06-22-mlx-lora-quality-control.md`（loss 绿≠模型绿）+ `docs/c5-recovery-2026-06-22/8d-rootcause.md`（配方失守 P2/P4）。

## 你的 3 维度

### 维度 4 — 算法 + 配方（~15 决策）
`rank16Mainline` 工厂（`Core/Training/C5LoRATraining.swift:1261`，已核）= rank16 / scale20 / LR 1e-4 / warmup8% / adamw+wd / gradClip1.0 / repo-loop finite-stop。masking 三形态（functionName/argumentName/argumentValue coverage）。grill 议题：LR 1e-4 守不守（lr-matters 支撑别回 2e-4）/ scale20 vs 32（防 config 污染，scale-authority=工厂20）/ masking 三形态实装边界（loss mask vs 受约束数据增广）/ DoRA 排期（V-PASS 后）/ gradClip / warmup / rank 选择。

### 维度 5 — 论文依据（~15 决策）
🔴 arxiv ID 据 `LORA-TD-2-papers.md`（commander teardown 已本机核，worker 复核）：lr-matters-lora `2602.04998`（LR 首要、别回 2e-4）/ Hammer `2410.04587`（三类 masking）/ When2Call `2504.18851`（真删工具→cannot_answer）/ SemDeDup `2303.09540` / decontaminator `2311.04850` / TinyAgent `2409.00608` / agentevals / nano-eval。grill 议题：每篇论文的哪条结论 adopt 进配方 / 论文支撑「纪律」vs「单点最优」边界 / 哪些是 paper-tiger（看似适用实际不）。

### 维度 8 — 训练推进方法（~15 决策）
mlx-lm 本机训（无 N 卡，云端训练不考虑）/ 训练循环真跑验证（`trainingLoopVerifiedForFormalTraining` @ `Core/Training/C5LoRATraining.swift:502`，gate @ `:2281`，非 stock CLI 冒充）/ checkpoint best-by-task-metric / 端侧 two-stage parity / repo-loop clip 真跑。grill 议题：训练循环怎么证「真跑过非 stock」/ checkpoint 选择指标（C6 hard_pass vs loss）/ 端侧 parity 验证 / smoke vs formal 边界 / 哪个 gate 是训练前硬前置。

## 🔴 决策矩阵格式（产出 `docs/c5-training-readiness-grill/worker-2-algo-decisions.md`）

```
| ID | 议题 | 选项 A/B/C | ⭐推荐 | 论据(file:line/arxiv) | 状态 | 🔴防惨败(cite PCA或新挖) |
```
- **ID 前缀 `A-`**（A-001 起）。状态默认 `proposed`。
- 论据 cite 一手（`Core/Training/C5LoRATraining.swift` 真实行号 grep 核 / arxiv ID 据 TD-2 复核）。
- 🔴 **防惨败列**：每条答「怎么防 0/34（name-last P4/假删 P2/loss 绿当模型绿）+ θ-α（训练健康但 action 全塌）重演」，cite P1-P9 或新挖。

## 🔴 边界（守 R7 BLOCKED）

- 只 grill 脑暴写 docs，不改代码、不训练、不调超参实跑。论据 cite 一手。
- 不替别的 worker（数据 2/3/7=W1 / 评测范式 6/9/12=W3 / 惨败防线 1/10/11=commander）。

## 回执

完成 `tmux-bridge message %42 'C5-GRILL-W2-DONE 决策数N 落 worker-2-algo-decisions.md'`，commander 自核 + subagent CC 审回稿。

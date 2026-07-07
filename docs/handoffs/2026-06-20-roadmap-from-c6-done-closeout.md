# Handoff 2026-06-20 — 新基线 roadmap closeout（C6 done → P0）

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

> append-only（collaboration §4.5，永不回改）。本条 supersede 同日早先 `2026-06-20-c6-done-eval-memory-deepdive.md` 的「MEMORY v5 / 旧起手读」续接口径——按 append-only 不改旧条，以本条为最新续接。

## Goal
MAformac 端侧离线 Qwen+LoRA 车控语音 demo。当前 = 吸收三刀收口 → **新基线 roadmap 立项** → P0 C6 完备化收尾。

## Constraints & Preferences
1. **不降级**（star>1000 工程价值全量吸收，只 drop 真不适用载体）；统一口径：**字段不降级，runtime 不膨胀；合同先保留，执行按依赖分批**。
2. **选型/版本断言必先 pre-mortem 联网搜证**（Qwen3.5-2B 复犯已沉淀）。
3. **单工作树并发硬 gate**：`git checkout`/`merge` 前先 `git status`，有我没建的 untracked = codex 在跑 STOP。
4. 称磊哥 / 中文 / 选择题打字列+⭐（不弹窗）。

## Progress (Done / In Progress / Blocked)
- **Done**：14-repo eval/记忆 teardown + Qwen3.5-2B 可行性 + synthesis 吸纳意见（commit `31edafc`）→ 磊哥外部评审（codex）→ CC 逐句吃透 + 一手核实 → **新基线 roadmap `docs/roadmap-2026-06-20-from-c6-done.md`（commit `36f223c`）**。级联回写已做（见下表）。
- **In Progress**：P0-1 codex TDD dispatch 起草 → subagent CC 审计 dispatch。
- **Blocked**：无。

## Key Decisions
- **新基线推进事实源 = `docs/roadmap-2026-06-20-from-c6-done.md`**：§1 五件套 harness 骨架（OpenSpec 推进容器 / Pocock S0-S6 分诊 / Superpowers brainstorming HARD-GATE+TDD / Pi append-only handoff+派单门 / Mastra 确定性 DemoFlow+TrajectoryExpectation→C6+scorer pipeline+judge 不洗白+observability）+ harness×C-change 映射表。
- **7 HIGH（H1-H7）已拍**（roadmap §3）：H1 Qwen 条件升级(先 S1/S2 spike) / H2 短时记忆落 C4 / H3 C6.1 时机(先 C5 前置) / H4 C5 先数据门 / H5 C7 写史合同首版即上 / H6 judge 不洗白+alt-quality / H7 UI-UE 重评。
- **CC 3 处纠偏**（核实坐实）：① Qwen spike 必在 LoRA train 之前收口（定模型）② P0 在**未 archive 的 C6 change 内**收尾再 archive（不开新 change，避免带病归档）③ alt+quality 金标提前 P0（防 trap 冤杀）。

## Next Steps
1. **P0-1**（roadmap 钦定起手）：`C6ReadbackRenderer.render`（C6:896 退化 key=value）→ 复用 `StateCellContractLookup.renderReadback`（ContractLookups:164，吃 C2 readback_zh），对齐 C2/C3 口径。派 codex TDD。
2. **dispatch step0**（机械级联兜底）：C3 `define-execution-contract` tasks 补勾 + archive（**清债**）+ 级联到位校验。
3. P0-2 权重 fingerprint / P0-3 trap 样本+alt 金标 / P0-4 verify_gold → 补完 archive C6 → P1 C5 数据门 + Qwen spike（并行）。

## Critical Context — 级联回写清单（本次 closeout 兑现）
| 文件 | 回写 | 状态 |
|---|---|---|
| `docs/roadmap-2026-06-20-from-c6-done.md` | 新基线推进事实源（新建） | ✅ `36f223c` |
| `CLAUDE.md §9` | C1/C2 propose 旧状态 → 新基线 + roadmap 指针 | ✅ `36f223c` |
| `docs/README.md` | 权威表 v2→v3，roadmap 列第一、SRD 降架构事实源第二 | ✅ 本次 |
| `docs/research/INDEX.md` | synthesis/qwen 行「HIGH 待磊哥拍」→「已由 roadmap §3(H1-H7)收敛拍板」 | ✅ 本次 |
| CC memory `maformac-6change-propose-state` | v5 → v6（roadmap/`36f223c`/P0-1/H1-H7 可搜索） + MEMORY.md 索引 | ✅ 本次（CC 私有 store，codex 不可见；本 handloff = repo 内可搜索镜像） |
| **C3 `define-execution-contract` tasks 0/38** | **未勾、未 archive** | ⚠️ **未完债**（roadmap/CLAUDE 已暴露非隐瞒；P0-1 dispatch step0 补勾+archive） |

> 可保留不改：`synthesis.md` 上方旧状态（§6 已自我更正，作 dated synthesis 保留）；`CONTEXT.md`（领域语言表非推进索引）。
> commit 锚点：synthesis `31edafc` / roadmap+CLAUDE `36f223c` / 本次级联回写见下个 commit。

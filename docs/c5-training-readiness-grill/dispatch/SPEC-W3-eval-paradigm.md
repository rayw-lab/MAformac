# SPEC W3 — C5 grill 评测范式官（worker @ %45 codex-3）

你是 codex worker（pane `%45`），commander 是 Claude（`%42`）。
任务 = **C5 训练就绪 grill·评测范式线**：脑暴维度 6/9/12 的关键决策（第一轮 ~45 条，每维度 ~15），按 UIUE 215-grill 决策矩阵范式。
🔴 **角色 persona**：代入【eval/benchmark 工程师 + 契约架构师】视角深 grill——挑剔评测门是否防假提升/范式 surface 是否同源/harness 是否 enforce 非 declare。
cwd=`/Users/wanglei/workspace/MAformac`（grill 写 docs，不改代码、不实装、不跑评测）。

## 🔴 起手必读（grill 范式 + 论据源）

1. `docs/c5-training-readiness-grill/README.md`（grill 范式 §4 + 双仓惨败纪律 §1）。
2. 上游论据源（cite 一手 file:line，落笔前 grep 核）：`Core/Bench/C6VehicleToolBench.swift`（1849 行，C6 四层）+ `~/Projects/agent-tmux-stack-research/runs/2026-06-30-lora-teardown/LORA-TD-4-data-eval.md`（C6 四层残留）+ `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`（D-domain 范式）+ `grill-decisions-amend-harness-audit-enforce.md`（harness enforce）+ `docs/c5-recovery-2026-06-22/8d-rootcause.md`（两套 scorer P6 / 审计 P7）。

## 你的 3 维度

### 维度 6 — C6 评测四层（~15 决策）
C6 现状（亲核）：四层 golden/demo_fuzz/unsupported/safety 只统计、status 固定 `local_construction_report`（`Core/Bench/C6VehicleToolBench.swift:1423`，已核）。🔴 **gate 6 四层阈值化 fail-closed 未实装**（缺每层最低通过率、禁 positive 抵消 safety 退化）。ToolCall 集合精确匹配 / IrrelAcc（legacy 0.9 是 compat 字段非门）/ state-delta / scope-origin / clarify-judge-after-hard-gate / readback / fingerprint parity。grill 议题：四层各自阈值定多少 / 一票否决怎么设 / readback 算不算 modelHardFailed / IrrelAcc 误读防线 / judge 边界（只评 clarify 主观不洗硬门）/ failure receipt（nano-eval 六字段）补不补。

### 维度 9 — 范式 surface（~15 决策）
D-domain 具名工具（value 形态编码进工具名）/ generic frame（`tool_call_frame`）作 surface 否决 / canonical IR 仍 device×action（「对模型像 D-domain 具名工具，对系统像 IR」）/ 工具数 value-form 实算（562 是 intent 非工具数）。grill 议题：D-domain 工具命名粒度 / surface-source preflight ≥80% overlap（gate 3 已立，train×prompt×C6×model actual 四方同源）怎么守 / 工具数实算口径 / generic frame 残留怎么清。

### 维度 12 — harness + enforce（~15 决策）
cite-verify hook（value-in-source）/ sign-or-block（grader 挂=candidate UNSIGNED）/ recompute fail-closed / cross-section check / `make verify` 门 / 异源 grader（hermes/GLM 非 Claude-family）。grill 议题：哪些 gate 进 `make verify` 硬门 / 异源 grader 用谁 / recompute 白名单 / harness 治 mechanical 边界（治不了 correctness→靠人+异源）/ surface+scorer consistency 门怎么 enforce（8d P6）。

## 🔴 决策矩阵格式（产出 `docs/c5-training-readiness-grill/worker-3-eval-decisions.md`）

```
| ID | 议题 | 选项 A/B/C | ⭐推荐 | 论据(file:line) | 状态 | 🔴防惨败(cite PCA或新挖) |
```
- **ID 前缀 `E-`**（E-001 起）。状态默认 `proposed`。
- 论据 cite 一手（`Core/Bench/C6VehicleToolBench.swift` 真实行号 grep 核）。
- 🔴 **防惨败列**：每条答「怎么防 0/34（两套 scorer 口径相反 P6/审计只审合规 P7/empty=hit P5）+ θ-α（C6 action 全塌没被四层门拦）重演」，cite P1-P9 或新挖。

## 🔴 边界（守 R7 BLOCKED）

- 只 grill 脑暴写 docs，不改代码、不实装四层门、不跑评测。论据 cite 一手。
- 不替别的 worker（数据 2/3/7=W1 / 算法训练 4/5/8=W2 / 惨败防线 1/10/11=commander）。

## 回执

完成 `tmux-bridge message %42 'C5-GRILL-W3-DONE 决策数N 落 worker-3-eval-decisions.md'`，commander 自核 + subagent CC 审回稿。

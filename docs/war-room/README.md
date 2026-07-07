# 🎖️ MAformac 指挥官作战中心（War Room）

> **单一导航入口**。每次战役的**进展 / 战报 / 结果 / 复盘 / 记录**都在这里，按里程碑（c5 训练 / c6 评估 / c7 语音）分子目录组织。
> 起手先看 [`INDEX.md`](./INDEX.md)（全战役总索引），再下钻里程碑目录，再到仓外一手。

## 这是什么 / 为什么建

指挥官指挥蜂群推进 MAformac，产出散落三处、易失忆、找不到：
- **仓外一手**：`~/Projects/agent-tmux-stack-research/runs/<run-id>/`（蜂群实时工作区，体量大、原始）
- **仓内决策**：`docs/commander-log/`（decisions ADR / COMMANDER-INDEX / SOUL / handoffs）
- **仓内主题**：`docs/c5-recovery-*` / `c5-training-readiness-grill/` / `grill-tournament/`（散落）

War Room = **仓内、进 git、按里程碑组织的作战档案馆**：把每轮收口后的战报/复盘/进展快照**沉淀 + 索引**到一处，一手仍留仓外（不复制全量、不建第二份 SSOT）。

## 三层职责（各司其职，互指针不重复）

| 层 | 落点 | 职责 |
|---|---|---|
| **一手工作区** | 仓外 `~/Projects/agent-tmux-stack-research/runs/<run-id>/` | 蜂群实时产出（grill/reduction/impl-plan/superaudit/STATUS-BOARD/probe），原始、体量大 |
| **作战档案馆**（本目录） | `docs/war-room/<里程碑>/` | 收口后**战报/进展/复盘**沉淀 + 按里程碑索引，进 git 可追溯 |
| **决策 ADR 层** | `docs/commander-log/` | decisions.md（D-xxx 决策史）/ COMMANDER-INDEX（决策图谱）/ SOUL（心法）/ handoffs（session 交接）——**不并入本目录，互指针** |

## 里程碑地图（当前双线并行）

| 里程碑 | 目录 | 是什么 | 状态 |
|---|---|---|---|
| **C5** | [`c5-lora-training/`](./c5-lora-training/) | LoRA **训练** | 🔴 活跃（收尾主路 grill CLOSEOUT，定调 A honest-frozen-closeout D-111；formal 1800 待 run-auth） |
| **C6** | [`c6-eval-bench/`](./c6-eval-bench/) | 训练完的**评估 / bench**（four-layer bench / acceptance） | 🔴 活跃（rebuild-c6，与 c5 并行） |
| **C7** | [`c7-voice/`](./c7-voice/) | 离线**语音**（ASR/TTS） | ⏳ 未来 |

## 如何用（落点规矩）

1. **每轮蜂群 run 一手** → 继续落仓外 `runs/<run-id>/`（CLAUDE.md §0.1 蜂群落点不变）。
2. **收口后沉淀** → 到对应里程碑 `campaigns/<run-id>/`：
   - `battle-report.md`（战报 = CLOSEOUT-RECEIPT 沉淀：做了什么/结果/non-claims/决策）
   - `progress-snapshot.md`（进展快照 = STATUS-BOARD 收口态）
   - `SOURCE.md`（🔴 仓外一手**绝对路径**指针 + 关键产出清单）
   - 模板见 [`_templates/`](./_templates/)
3. **复盘** → `<里程碑>/retro/`（事故/教训溯源，如 0-34 / θ-α / 8d-rootcause）。
4. **总索引** → 每轮收口在 [`INDEX.md`](./INDEX.md) 加一行（里程碑 × run-id × 状态 × 战报 × 决策）。
5. 🔴 **引用 run 文件必写绝对路径** `~/Projects/agent-tmux-stack-research/runs/<run-id>/<file>`，禁写仓内相对 `runs/...`（会 drift 找不到，见 CLAUDE.md §0.1 铁律）。

## 起手读序（压缩/新 session 恢复）

1. 本 README（作战中心是什么 + 里程碑地图）
2. [`INDEX.md`](./INDEX.md)（当前所有战役 + 状态一览）
3. 对应活跃里程碑 `README.md`（c5 / c6 线打到哪）
4. `docs/commander-log/COMMANDER-INDEX.md` + `SOUL.md`（决策层 + 心法）
5. 最新 campaign 的 `battle-report` + `SOURCE`（下钻仓外一手）

## 与现有文档关系

- 吸收升级 `docs/commander-log/RUNS-CASCADE.md`（原 run 索引账本）→ 本目录 `INDEX.md`（RUNS-CASCADE 已转 redirect stub）。
- `commander-log/` 决策/交接层保持独立，与本目录 INDEX 互指针。
- `docs/lessons-learned.md`（项目坑点全集）保持独立，里程碑 `retro/` 引用它的相关段。

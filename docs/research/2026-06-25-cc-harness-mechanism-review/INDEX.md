# INDEX — CC Harness 管控机制复盘存档

## 文件清单
- `README.md` — 综合（机制分层落位表 + 三路 teardown + 业界 A + 现状 B + 亲核记录 + 决策清单）= **二手派生综合**。

## 一手层级（ultracode 三层一手性）
| 层 | 内容 | 落点 |
|---|---|---|
| 二手综合 | README（落位表 + 各路结论 + 亲核）| 本目录 `README.md` |
| 一手 finder full_markdown | 5 路 subagent 完整 result（每路 verdict + 清单 + 实证）| **本 session transcript**（task-notification 全文，`~/.claude/projects/-Users-wanglei-workspace-MAformac-uiue/771bd2ab-8647-42f5-b39c-0fe5c890b3ba.jsonl`）|
| 最一手 transcript | subagent 搜证/工具调用全过程 | 仓外 `~/workspace/raw/05-Projects/MAformac/research/2026-06-25-cc-harness-transcripts/agent-*.jsonl`（脱敏 CLEAN，5 个 cp，含业界 A `agent-a600ce260bba23f5d.jsonl`）|

## agent ↔ lens 映射（5 路并行 subagent）
| lens | 维度 | agentId |
|---|---|---|
| A | grill 全流程管控（grill→派单复用 / 落档模板 / 骨架预留）| a862e5189bded203b |
| B | 框架联动（superpowers+OpenSpec+Pocock+Pi）| a8767ec69c7cb2f1e |
| C | 通用管控教训（审计/anchor/mock/沉淀）| a0180b35dd57cad92 |
| 业界 | CC harness 对标（13 repo + 官方 hook + 上下文工程）| a600ce260bba23f5d |
| 现状 | 本机 CC 机制盘点（会话开始 vs 每 turn + 6 空白）| ab65240e8e5dc0bbb |

## 关键产出
- **机制分层落位表**（README §〇）：每条沉淀 → rules / CC 机制 / grill-with-docs / heavy-work / 项目 doc。
- **loop review goals 派单实施文件**：`~/workspace/raw/05-Projects/MAformac/dispatches/2026-06-22-harness-enforce-audit-implementation-dispatch.md`（raw 仓外一手派单；本索引仅挂路径，正文不入仓）。
- **亲核记录**（README §四）：5 repo star + 16 hook 事件全真，finder 零编造混入（双向教训：superpowers 238k 我误判编造实际真）。
- **待 brainstorm 10 问**（README §五）→ 决策落位拍板。

> 注：transcript cp 按时间+大小挑近 5 个 >10K agent jsonl，业界 A（a600ce260）确认匹配；其余为本 session subagent 全过程（含本次调研 + 可能少量本 session 审计 agent），全过程一手。finder result 权威全文以本 session task-notification 为准。

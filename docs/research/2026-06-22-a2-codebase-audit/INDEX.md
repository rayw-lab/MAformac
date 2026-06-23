# A2 代码盘点 ultracode 调研 — 归档索引（三层一手性）

> 2026-06-22 ultracode workflow `wf_70e0475f-ea4`（run id）/ task `w2downwc8`。8 路 finder + 综合官 = 9 agent / 1.1M tok / 229 tool_uses / 936s。
> 按 ultracode-7lens 存档纪律【三层一手性】归档：综合官 README（二手）+ finder full_markdown（一手结构化）+ **transcript（最一手，仓外脱敏）**。

## 仓内文件（脱敏综合产物，git tracked）

| 文件 | 层 | 内容 |
|---|---|---|
| `README.md` | 二手综合 | 综合官 full_report + 主线程亲核小结 + 全字段附录（不对齐表/A2范围/复用重写/框架选型/硬编码避免/pre-mortem/grill弹药）|
| `lens1.md` | 一手结构化 | L1 C1→C2→C3→C5→C6 全链路不对齐盘点 |
| `lens2.md` | 一手结构化 | L2 硬编码 + 健壮性盘点 |
| `lens3.md` | 一手结构化 | L3 A2 codegen 方案深扒 |
| `lens4.md` | 一手结构化 | L4 数字口径核 |
| `lens5.md` | 一手结构化 | L5 业内代码质量管控（外部 ≥10 搜证）|
| `lens6.md` | 一手结构化 | L6 Swift codegen 框架选型 |
| `lens7.md` | 一手结构化 | L7 mlx 框架 + 代码组织 |
| `lens8.md` | 一手结构化 | L8 codegen/重构坑点 oracle |
| `codex-checks.md` | 核验 | codex 言论 cite-verify（L1/L4 核 + 主线程数字口径复核）|

## 🔴 transcript（最一手，仓外脱敏归档，不入仓）

> 脱敏检查命中：`agent-a56571a13fd3c09e8.jsonl` + `agent-a225cf1196fc2ed4f.jsonl` 含 `raw/01-Wiki|raw/02-Raw|/Downloads/` 原文引用 → 按 MAformac §6 红线**不入仓**，归档仓外 raw。

- **归档绝对路径**：`~/workspace/raw/05-Projects/MAformac/research/2026-06-22-a2-codebase-audit-transcripts/`（2.7M）
- **内容**：9 个 `agent-*.jsonl`（8 finder + 综合官完整对话/工具调用过程）+ `agent-*.meta.json` + `journal.jsonl` + `workflow-return.json`（完整 return 结构，原 /tmp `.output` 持久副本）
- **lens↔agent 粗映射**（meta.json 只给 agentType，精确对应看各 jsonl 首条 prompt）：
  - `agentType: Explore` × 4 = L1-L4（本机代码盘点）：a225cf / a50a639 / a514191 / a74a8d
  - `agentType: workflow-subagent` × 5 = L5-L8 外部调研 + 综合官：a19d97 / a46fa54 / a51e772 / a56571 / a7bd364
- **原始位置**（会被清理，已 cp 持久）：
  - workflow return /tmp：`/private/tmp/claude-501/-Users-wanglei-workspace-MAformac/676740d9-5322-4da0-86c2-4d55385aa1d3/tasks/w2downwc8.output`
  - transcript：`~/.claude/projects/-Users-wanglei-workspace-MAformac/676740d9-5322-4da0-86c2-4d55385aa1d3/subagents/workflows/wf_70e0475f-ea4/`
  - workflow script：`~/.claude/projects/.../workflows/scripts/maformac-a2-codebase-audit-wf_70e0475f-ea4.js`

## 主线程亲核结论（载入 README 头）

- 数字口径坐实（python 复算）：全集 3990/671 device/1538 intent；**device 权威 191**（generated 旁路 223 含 disputed 过期）/ **intent 权威 534**（562=A1-A9前/507/680=boundary 子串）/ **工具数未拍待实算**（534=intent 非工具数）。
- 外部 star 全核通过（finder 诚实）：mlx-swift-structured 74★/2026-04-06 · mlx-swift 1932★ · mlx-lm 6006★ · mlx-swift-lm 679★ · xgrammar 1752★ · Sourcery 8010★。
- A2 = 重型（~14-16 文件 / 1500-2500 行 / 6 步依赖序）。

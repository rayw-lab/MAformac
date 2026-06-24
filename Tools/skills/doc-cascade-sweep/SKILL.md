---
name: doc-cascade-sweep
description: Use when 范式翻案/架构大改/口径回写后,grep 全仓命中几十个文件含过期锚点或旧数字,需要全仓级联更新。症状:看到 grep 命中 60+ 文件就想 sed 全量替换、或一个决策只 append 进一个文件没回写文档组、或改了带日期的历史快照正文破坏一手溯源。
---

# Doc Cascade Sweep

## Overview

大规模文档级联**不是全量替换所有 grep 命中**。

**Core principle:** 先分诊每个文档是「**活基线**」还是「**历史档**」再动作。活基线必改（错=误导下游 session）;历史快照标 `historical` banner **不改正文**（改了破坏一手溯源 + 工作量爆炸 + 误改非目标的相同数字）。**grep 命中 ≠ 都要改**。

## When to Use

- 范式翻案 / 架构大改 / 口径回写后,grep 全仓命中数十文件含过期锚点
- 重大决策拍板后要回写「文档组」（不是单个文件）
- 症状:想 `sed` 全量替换 / 决策只 append 一个文件 / 要改历史快照正文

**NOT for:** 单文件改 / 小范围（直接改,不必分诊）。

## T0-T6 分诊框架

| Tier | 类别 | verdict |
|---|---|---|
| **T0 活基线** | 宪法/架构/范式入口（CLAUDE/SRD/MASTER/roadmap/README/lessons,新 session 起手读） | 🔴 **必改** |
| **T1 契约 SSOT** | spec / contract（行为事实源） | 🔴 必改 |
| **T2 决策清单** | decisions/ADR | 🔴 逐条标 keep/modify/superseded/defer |
| **T3 决策 SSOT** | grill/decision 单一权威（多份并存→统一） | 🔴 统一 |
| **T4 新落档** | design/新契约 | 🟡 新建/改 |
| **T5 历史快照** | handoff/dispatch/research/审计报告（带日期时间戳） | 🟢 **标 historical banner,不改正文** |
| **T6 脏区** | 废弃/矛盾/`_parked` | 🔪 删/废 |

## Recipe

1. **grep 量化命中**:`grep -rl '<旧锚点>' .` 数清命中文件数（先量化,别凭感觉）。
2. **逐文件 T0-T6 判**（看上下文,不机械替换）:同一数字在 research 历史档可能是巧合/一手记录,不是回写目标。
3. **动作**:活基线（T0-T3）改正文;历史档（T5）加 banner 不动正文;脏区（T6）park。
4. **dual-count 自检**:口径 A（verdict 行数）vs 口径 B（全路径覆盖数）—— 用 `awk` 复算两口径对齐,防 ledger 自我 drift。
5. 大规模可派 subagent fan-out 出逐文件 inventory（path/tier/verdict/what/priority）。

## Common Mistakes

| 错 | 对 |
|---|---|
| `sed` 全量替换所有命中 | 逐文件 T0-T6 分诊,grep 命中≠都改 |
| 改 T5 历史档正文 | 加 historical banner,正文不动（保一手溯源） |
| 决策只 append 一个文件 | 回写「文档组」（roadmap/exec-plan/spec/根因/checklist 级联） |
| 旧段不标 SUPERSEDED | 旧段标 `SUPERSEDED-BY-X` + 段首边注指现行权威 |

## Real-World Impact

MAformac 实证:`534→562` 口径回写 grep 全仓命中 24 文件,但很多是 research 历史档的**非口径 534**（benchmark/token 数）——全量 `sed` = 误改 + 破坏溯源;162 md 真正必改 ~20。`cascade-inventory.md` 自身记录 **5 轮 self-drift**（87/153 dual-count）。配 rule `doc-cascade-triage` + `claim-vs-reality-gap` 第 10 变体（段间自我分叉）。

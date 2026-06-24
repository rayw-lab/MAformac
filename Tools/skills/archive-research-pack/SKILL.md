---
name: archive-research-pack
description: Use when 一次多路 workflow 调研 / deep-research / pre-mortem oracle 搜证收口,需要把成果落盘防失忆。症状:调研完只想存一个总报告、transcript 在 /tmp 待清会丢、finder 引的 source URL 事后无法复核、各路一手档与综合报告混在一起。
---

# Archive Research Pack

## Overview

调研成果有**三层一手性**,只存最上层 = 丢最一手。

**Core principle:** 综合官 README（二手派生）⊋ finder lensNN（一手结构化）⊋ transcript（最一手过程）。事实层弹药（source URL + 日期）丢弃 = 下次重跑 + 跨文档段间分叉。

## When to Use

- ultracode / 多路 workflow 调研收口（N 路 finder + 综合官）
- deep-research / pre-mortem / oracle 搜证出了结论或决策
- 症状:只想存"一个总报告" / transcript 在 `/tmp` 等被清 / source 丢了事后无法复核

**NOT for:** 单次 WebSearch 速查（无 finder 分路）/ 不产决策的随手查。

## The Pack（归档 = 以下全部,缺一不算完）

落点 `docs/research/<YYYY-MM-DD>-<topic-slug>/`:

| 文件 | 是什么 | 一手性 | 必含 |
|---|---|---|---|
| `README.md` | 综合官报告 | 二手派生 | 对比矩阵 + P0/P1/P2 分级 + 决策 ⭐ + grill 弹药 |
| `lensNN.md`（每路一个） | finder 一手档（full_markdown） | 一手结构化 | summary + findings + **每条 source URL + 日期** |
| `INDEX.md` | 文件清单 | 导航 | lens↔agent 映射 + transcript 仓外指针 |
| transcript jsonl + workflow `.output` | finder 完整搜证过程 | **最一手** | 见脱敏落点 |

**transcript 脱敏落点:** grep `raw/|禁外传|/Downloads/` → 命中则归**仓外** `~/workspace/raw/05-Projects/MAformac/research/<topic>-transcripts/` + `INDEX.md` 放绝对路径指针;零命中可入仓。

## Quick Steps

1. workflow return → **立即** `cp` transcript（jsonl）+ journal + `.output` 持久（`/tmp` 会清,别拖到被清）
2. 落 `README`（综合官 schema 带 `full_report_markdown`）+ 各 `lensNN`（finder `findings`+`full_markdown`）+ `INDEX`
3. 脱敏 grep → 决定 transcript 仓内 / 仓外
4. **明列存了哪几个文件**（README + N lens + INDEX + transcript 指针）,不只口头报 README

## Common Mistakes

| 错 | 对 |
|---|---|
| 只存综合官 README | 三层全存（丢 lensN/transcript = 丢一手） |
| source URL 不落 lensN | 每条 finding 带 URL + 日期（事实 cutoff 敏感,事后可复核） |
| 等磊哥催才存 | workflow 完立即（`/tmp` 会清） |
| 口头报"存了" | 明列文件清单（防"只存一个总的"误解） |

## Real-World Impact

MAformac 实证:18 路 lora-deepdive（`docs/research/2026-06-24-lora-zero-failure-deepdive/` 28 文件）+ a2-codebase-audit,结构几乎一字不差却每次手搓重建;曾"落 8 lens 只口头报 README"被磊哥纠以为只存一个。配 memory `oracle-default-archive` + rule `ultracode-deep-research-7lens` 三层一手性。

---
type: grill-system-convention-and-index
status: ACTIVE（grill 体系规范 + 全系列导航总索引，磊哥 2026-06-26 定）
authority: grill_navigation_and_convention（规范 + 导航；决策 SSOT 仍是 grill-decisions-master.md，本文不裁决策）
owner: MAformac
created_at: 2026-06-26
---

# MAformac Grill 体系规范 + 全系列总索引

> 磊哥 2026-06-26 定：**所有 grill 系列统一一个规范 + 一个 canonical 目录**。本文 = **规范（命名/编号/目录）+ 全系列导航总索引**，**不裁决策**（决策 SSOT 仍 `grill-decisions-master.md`）。
> 🔴 **新开 grill 必先读本文**（`grill-with-docs` Step 0）：接续现有编号系列、落 canonical 目录、挂现有索引 —— **不另起 Q1 / 不另建第二份清单**（codex-meta §7 SSOT / claim-vs-reality §10）。
> 🔴 **为何不物理全搬**：`grill-decisions-master` 被 **99 个文件**引用、`storyboard` 14 个 → 物理移动 = 路径/file:line 海量断裂（doc-cascade 灾难）。故"统一" = **逻辑统一**（规范 + 总索引 + canonical 目录约定 + 散落档原位登记），高引用活基线**原位保留**，只新档物理落 canonical。

## 1. canonical 目录约定
| 类别 | 目录 | 说明 |
|---|---|---|
| **决策正文**（grill decisions） | `docs/grill-tournament/` | **唯一 canonical**，新 grill 决策正文一律落这 |
| **tracking / checklist**（消减/落地/冻结/coverage） | `docs/grill-checklist/` | tracking 子目录，与决策正文职责分离（磊哥 2026-06-26 拍：保留分目录、一份索引统管） |
| **历史散落档**（docs/ 根的 storyboard / todo-upgrade / c1-oracle / p1c 等） | 原位保留 | 移动级联大（高引用）→ doc-cascade-triage：活基线原位 + 本索引登记，不物理搬 |

## 2. 编号系列规范（新 grill 接哪个系列）
| 系列 | 数量 | 含义 | 一手源 | 新增接续 |
|---|---|---|---|---|
| 锦标赛 Q1-Q41 | 41 | 5 组（GOV9/CAS8/TRN9/UIX9/AUD6）综合题 | `grill-tournament/final-grill-list.md` + `ledger.md` | 新综合题 → Q42+ |
| SD1-SD25 | ≈240+ | storyboard 决策（旧「234」=SD1-20 口径，已 stale） | `docs/UIUE-checklist.md`(canonical) | SD26+ |
| RPB-01~53 | 53 | runtime-bridge（= 53 runtime grill） | `grill-checklist/uiue-runtime-bridge-decisions-2026-06-25.md` | RPB-54+ |
| U1-U31 | 31→ | UIUE 细决策，挂锦标赛 Q30-Q38 | `grill-tournament/grill-decisions-master.md` §3 | **U32+**（本次视觉门 U32-U37 挂 Q38） |
| V1-V12 | 12 | 视觉语言决策 | `uiue-storyboard-grill-decisions.md` / `grill-tournament/uiue-d1-d6-grill.md` | V13+ |
| AD-1~14 / CC* / D1-8 / E0-8 / G01-28 | — | 各专题（runtime/视觉/聚焦/default_scope/炸场） | 各专题档 | 沿用所在系列 |

## 3. 命名规范
- 决策正文：`uiue-<topic>-grill-decisions.md`（或 `<area>-<topic>-grill.md`）。
- frontmatter：`type / status / date / owner / 方法 / 编号(接哪个系列+挂哪个 Q) / 关联(→ master §N + coverage-index)`。
- file:line 引用：**全 repo-relative 路径**（`docs/...:NNN`），落档前开文件核（防错引被未来 grill 当一手）。

## 4. 文档分工（防混，各 authority）
| 文档 | authority | 职责 |
|---|---|---|
| `grill-tournament/grill-decisions-master.md` | grill decision SSOT | **决策单一权威**（锦标赛 41 §2 + U 系列 §3 + 晶体 §4） |
| `grill-tournament/GRILL-SYSTEM.md`（本文） | 规范 + 导航 | 命名/编号/目录规范 + 全系列总索引 |
| `grill-checklist/uiue-a2-grill-coverage-index.md` | tracking_not_ssot | 全集 × Phase 消减跟踪 |
| `grill-checklist/uiue-grill-定档-2026-06-25.md` | frozen_dossier | 冻结快照 + 作废 registry（前后冲突前者作废） |
| `grill-checklist/uiue-landing-matrix-2026-06-25.md` | tracking | 粗粒度落地态 |

## 5. 全系列文档落点登记（导航）
- **grill-tournament/**：`grill-decisions-master` · `ledger` · `final-grill-list` · `cascade-inventory` · `round-01~05` · `demo-default-scope-grill-decisions-2026-06-24` · `uiue-d1-d5-loop-competition` · `uiue-d1-d6-grill` · `uiue-phase4-grill-decisions` · **`uiue-visual-gate-harden-grill-decisions`（U32-U37）** · **`uiue-8g9-and-liquid-glass-hardening-grill-decisions`（U38+）**
- **grill-checklist/**：`uiue-a2-grill-coverage-index` · `uiue-landing-matrix-2026-06-25` · `uiue-grill-定档-2026-06-25` · `uiue-runtime-bridge-decisions-2026-06-25`(RPB) · `uiue-runtime-bridge-amend-2026-06-25` · `UIUE-checklist`(redirect stub)
- **docs/ 根（历史，原位 + 本索引登记，不搬）**：`UIUE-checklist.md`(canonical SD) · `uiue-storyboard-grill-decisions.md`(V/SD 视觉) · `uiue-todo-and-grill-upgrade-2026-06-25.md` · `c1-q1-q10-claude-oracle-grill-2026-06-19.md` · `p1c-training-grill-decisions.md` · `uiue-roadmap-2026-06-23.md`

## 6. 新开 grill SOP（grill-with-docs Step 0 落地）
落任何 grill 决策**前**：
1. 读本文确认编号系列 / canonical 目录 / 现有索引。
2. **接续现有系列**（不另起 Q1 / 不另建第二份清单）。
3. 决策正文落 `grill-tournament/`（命名 §3）。
4. 挂 `master`（§2/§3 加行）+ 登记本文 §5 + coverage-index `canonical_inputs`。
5. cite `file:line` 用全路径并开文件核（§3）。

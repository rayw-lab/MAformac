# Pre-Commit 全盘审计 — 审计员 C

> commit 推 GitHub 前最后一道。脱敏红线最高优先。本机 Read/grep 实核。
> 审计时间：2026-06-23 · 项目根 `/Users/wanglei/workspace/MAformac`

## 负责维度（视角层）

① 🔴 边界红线 / 脱敏（commit 前绝不入仓的内容）
② 历史档 vs 活档（HISTORICAL banner 是否误改正文）
③ SSOT / 去重（口径 562/grill 多源 drift）
④ 脏区残留

## Verdict

**has_p0p1 = true**
**P0（脱敏）= 1 条** · **P1 = 3 条** · P2/note = 数条

- 🔴 **P0-1 脱敏（最高优先）**：新增（untracked）文件命中真实车厂名 + 真实合作方名（iFlytek-Chery），且嵌入 RAW 交付手册逐字时序图代码块。**绝不入仓 → 修或删后才能 commit。**
- ② 历史档 banner：**全过**（banner 在文件头/段头，正文用 `~~删除线~~`+`[SUPERSEDED→]` 标记，无误改）。
- ③ SSOT：**全过**（562 单源；534 全部框定为「废/误当工具数」反面，无 live 误用；grill SSOT = grill-decisions-master 单一权威，superseded 文件均有指回 banner）。
- ④ 脏区：**3 处 P1/P2**（emoji 命名 stray 文件、repo 根 stray PNG、pre-existing 讯飞 历史泄漏）。

---

## 审计范围与实核痕迹

### 提交候选文件集（165 个）
`git status --short`（staged ACMR）+ `git diff`（worktree ACMR）+ `git ls-files --others --exclude-standard` 合并去重 → `/tmp/commit_files.txt`。
扩展名：132 md / 10 yaml / 8 py / 7 swift / 3 json / 1 png。
`Reports/` 已 gitignore（`.gitignore:59`），staged 的 Reports 全部为 **deletion**（清理），无新报告内容入仓（实核：`git diff --cached --name-status` Reports 段无 ACMR）。

### 维度① 脱敏红线扫（逐项实核）

| 扫描项 | 命令/范围 | 结论 |
|---|---|---|
| 真实车厂名（应「某车厂」） | grep 25 家车厂名 + 拼音 | 🔴 **1 命中**（见 P0-1）；`小鹏`@`research-archive:50` = 第三方公开 repo `dengky23/nlu-pipeline-vehicle` 作者实习背景描述（prior-art 笔记，非本项目源车厂语料）= 可接受 |
| 真实合作方（iFlytek/讯飞） | grep `Chery/iFlytek/讯飞/奇瑞` | 🔴 **2 命中**：emoji 文件（P0-1，新增）+ `research-archive:119`「讯飞清单」（**pre-existing 未改**，见 P1-3） |
| 密钥/key/token/password | grep 全 enum | ✅ 全假阳性（`apiKey` = 空 Hindsight config 技术债记录；`*_password` = 车控设备 enum 名如 `wifi_password`/`glove_compartment_password`，无实际 secret） |
| PII（手机/身份证/邮箱） | grep 大陆手机正则 + 18 位身份证 + email | ✅ **0 命中** |
| 「禁外传/对内/机密」原文标记 | grep + 排除边界声明 | ✅ 命中全为脱敏**声明本身**（如「无…对内禁外传原文」），无实际受限内容 |
| RAW 原文语料路径泄漏 | grep `raw/` `Downloads/` `-transcripts/` | ✅ 全为**指针引用**（路径指向仓外只读区，符合 §6 + ultracode 存档纪律：仓内放 INDEX/指针，corpus 留仓外） |
| generated/ 派生物含原文? | grep CJK | ✅ tools/schema/rendered 全英文设备 ID（抽象词表，0 CJK）；`10-family-device-map.json` 285 行 CJK = 通用族名（空调/座椅 = AC/Seat 标签），非原文话术 |

### 维度② 历史档 banner（抽查）

- `docs/roadmap-2026-06-20-from-c6-done.md:3-7`：状态 banner 在文件头（行 3 起），明示「仍是当前推进事实源」+ surface 翻案 + 562 口径演进；正文未被改写。✅
- `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:302`：§15 段头物理 `SUPERSEDED-BY grill-decisions-master.md` banner 存在；被废内容用 `~~删除线~~`+`[SUPERSEDED→§16:216]`（行 58/82）标记，不删原文供溯源。✅（符合全局 §35 supersede 技术）
- `docs/grill-tournament/grill-decisions-master.md:15-18`：明列三份 historical 源（paradigm §15 / GRILL-MASTER / roadmap-2026-06-20）+ 指回本文。✅

### 维度③ SSOT 单源

- **口径 562 vs 534**：grep `534` 全 25 命中均框定为反面（「禁止把 534 intent 写成工具数」「534 被误当工具数会导致全链路口径错」），无 live 误用；562 = 当前 live 口径（`mvp-10family-device-boundary.md:39-41` 标「磊哥 2026-06-23 亲拍权威」，旧 534/2086 明示作废）。✅
- **工具数口径**：一致标 `[TBD-工具数待 value-form 实算]`（`tasks.md:12`/`proposal.md:60`），明禁引 534/562 当工具数。✅ 口径纪律严谨。
- **grill SSOT**：`grill-decisions-master.md` 为单一权威，41 题锦标赛；旧清单（§15/GRILL-MASTER/roadmap）均标 historical 指回。无三份并存 drift。✅

### 维度④ 脏区

- `docs/research/🔴 RAW vault 5 处独立证据...md`：**唯一**违反 `YYYY-MM-DD-` 命名约定的 stray 文件（grill 对话稿落在 research/ 根而非 dated 子目录），文件名含 emoji + 空格 + 全角括号。→ P1-1。
- `maformac-h5-preview.png`（307k，1065×977）在 **repo 根**，无任何 committed doc 引用（orphan）。违 workspace 规则「不在根目录创建文件」。→ P1-2。
- 空目录：✅ 无。临时/备份文件（.bak/.tmp/.DS_Store/~）：✅ 无（`.snapshot.py` 仅在 staged-deletion 的 Reports 内，不入仓）。
- scripts/*.py：✅ 全部被引用（verify_gold 20 处 / cross_section_check 14 处 / gen_tool_contract 9 处等），非 orphan。

---

## Findings 表

| # | 级别 | 维度 | 文件:行 | 问题 | 区分 | 建议 |
|---|---|---|---|---|---|---|
| **P0-1** | 🔴 **P0 脱敏** | ① | `docs/research/🔴 RAW vault 5 处独立证据全部指向 P（一手 cite-verify 坐实）.md:41` | 正文「整个 **iFlytek-Chery** 车载 LLM 产品体系对齐」= 真实合作方（讯飞）+ 真实车厂（奇瑞 Chery）明文；同文件 `:6-13` 嵌入 RAW`复杂车控FunctionCall交付手册.md:248-260` **逐字时序图代码块** | **裸残留（新增/untracked，本 commit 首次入仓）** | commit 前**必须**：① `iFlytek-Chery`→「某车厂/合作方」② 逐字时序图代码块改为抽象描述或删（§6 原文不入仓）③ 或整文件不入仓（见 P1-1） |
| **P1-1** | P1 | ④ | `docs/research/🔴 …坐实).md`（同上文件） | 唯一不守 `YYYY-MM-DD-` 命名约定的 stray 文件（emoji+空格+全角括号文件名），grill 单轮对话稿落 research/ 根，无 INDEX 收录 | 裸残留 | 不入仓（移仓外 raw transcript 区），或正确归档进 dated 子目录 + 改名 + 脱敏后入。**修了 P1-1（不入仓）即同时消除 P0-1** |
| **P1-2** | P1 | ④ | `maformac-h5-preview.png`（repo 根） | 307k PNG 在仓根，无任何 committed doc 引用 = orphan 根污染；违 workspace「不在根目录创建文件」 | 裸残留 | 移入 `docs/` 对应子目录并被引用，或不入仓 |
| **P1-3** | P1 | ① | `docs/research-archive-2026-06-17.md:119`「讯飞清单→…」 | 真实合作方名（讯飞）在正文 | **pre-existing（diff 仅 +4 行别处，此行未改；已在历史 commit 入仓）** | 本 commit 借机统一改「某车厂/合作方」；属系统性历史泄漏（另 8 个已追踪文件同样含讯飞/Chery，见下 note）非本 commit 引入 |
| P2-1 | note | ① | `docs/tech-baseline-supplement-v0.2.md:408` | 列 RAW 文档**标题**（专家解读/协议表名）标「仅供内部回查不外传」 | 已标 context | private 仓灰区可接受（doc 标题非密钥/PII/报价）；若上公开仓需脱敏 |
| P2-2 | note | ① | `grill-decisions.md:260-264` 等 | RAW`交付手册.md:行号` 引用 + 短抽象转述 | 已标 context（指针，非 dump） | 符合 §6/ultracode 指针模式，保留 |

### Note — pre-existing 讯飞/Chery 历史泄漏（FYI，非本 commit 引入）
`git grep` 全仓 11 处命中分布 8 个**已追踪**文件：`docs/dispatches/2026-06-19-P0-function-spec.md` / `docs/handoffs/2026-06-19-change3-gptpro-audit-closeout.md` / `docs/project/collaboration-and-roles.md` / `docs/research-archive-2026-06-17.md` / `docs/research/2026-06-19-architecture-validity-deepdive.md` / `docs/research/2026-06-19-asr-alignment-research.md` / `docs/second-review-2026-06-17/03-capabilities-catalog.md` / `docs/voice-pipeline-from-raw.md`。这些已在 GitHub（private）上。**绝对红线**「客户公司名正文统一某车厂」对讯飞/Chery 成立（Chery=客户公司名），建议磊哥安排一次全仓脱敏 sweep（独立于本 commit）。

---

## Summary

**本 commit 唯一硬阻断 = P0-1 脱敏**：新增 untracked 文件 `docs/research/🔴 RAW vault 5 处独立证据…坐实).md` 明文带真实车厂+合作方名（iFlytek-Chery）+ RAW 交付手册逐字时序图。**绝不入仓** —— 最省事的修法 = 此文件不 `git add`（同时消 P1-1 脏区）；若需保留则脱敏（Chery→某车厂 + 删逐字代码块）。

其余三维健康：② historical banner 规范（头/段头 + 删除线 supersede，无误改正文）；③ 562 口径单源、534 全框为反面、grill SSOT 单一权威无 drift；④ 仅 emoji stray 文件 + 根 PNG 两处脏区（均建议不入仓），scripts 全被引用、Reports 全为删除、无空目录/临时文件。

pre-existing 讯飞/Chery（8 文件 11 处）是历史系统性泄漏、非本 commit 引入，建议另起脱敏 sweep。

— 审计员 C

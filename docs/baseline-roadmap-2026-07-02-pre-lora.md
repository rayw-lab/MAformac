---
status: baseline_roadmap_active
artifact_kind: pre_lora_tree_pr_merge_roadmap
authority: baseline_until_superseded（树/合并/PR 节点的当前权威路线；与 live git 冲突时以 live 为准并回写本文件）
created: 2026-07-02
author: claude-commander（新任，D-015 接棒复审后）
as_of_main: ab355f6c（PR #9/#10/#11 已 merge，全部 11 个云端 PR MERGED/CLOSED，零 open）
evidence: L1-tree-pr-doc-inventory.md（%44 read-only 盘点，2026-07-02）+ commander git/gh 亲核
companion: docs/lora-loop-blueprint-2026-07-02.md（训练闭环鸟瞰，姊妹篇）
expires_when: wave-1 consolidation PR 合并后须刷新 §2/§3；R7 route-only signoff 2026-07-15 到期前须复核
---

# 基线路线图（2026-07-02 此时此刻）— 树 / 合并 / PR 节点

> 一句话：**现在保持现状（verdict: HOLD）**。所有隔离树不动、不删、不合，直到磊哥拍 5 件决策中的 ⑤（wave-1 consolidation）与 cleanup 授权；训练相关真跑全部等 candidate signoff + run auth（R7）。

## §0 冻结时刻快照

| 维度 | 状态 |
|---|---|
| main | `ab355f6c`，CI Verify SUCCESS，`make verify-all` 472 tests/0 fail（D-011）；3 训练前置门（gate5/6/7）已落 |
| 云端 PR | #1-#11 全 MERGED/CLOSED，**零 open** |
| wave-1 未合分支 | g8-tool `64c6f62f`（+1 commit，0 behind）/ g2-mask `47ca8cda`（+2 commit，0 behind）/ grill `f9e67901`（基于 doc-absorption）|
| 指挥官分支 | `codex/rebuild-c6-doc-absorption-20260624`（主树，**147 behind / 14 ahead** main；commander-log、C5 grill 语料、handoffs 全在此）|
| R7 | route-only signed（2026-06-25，**expires 2026-07-15**）；candidate unsigned；retrain/真生成/真评测/uiue-merge/V-S-U-PASS 全 BLOCKED |
| 磊哥 5 件待拍 | ① gate2 masking design 岔口（⭐token-mask override 已实现并双审 CONFIRMED）② E-2 subset 策略 ③ grill Dim10/11/5 lock（~58 条 proposed）④ T-2 tiny-ablation 真跑 run-auth ⑤ wave-1 consolidation-to-main |

## §1 全树状态矩阵（16 worktree + 关键裸分支）

> 完整证据（逐树 rev-list/cherry/diff 输出）见 `~/Projects/agent-tmux-stack-research/runs/2026-07-02-baseline-roadmap/L1-tree-pr-doc-inventory.md`。cherry 口径：rebase-merge 后 `branch --merged` 不可信，以 `git cherry`（patch 等价）+ `main..branch` diff 方向为准。

### 活跃隔离树（keep，有明确后续节点）

| 树 | 分支@HEAD | vs main | 处置 | 后续节点 |
|---|---|---|---|---|
| 主树 `MAformac` | doc-absorption `7dd64a50`+dirty | 147↓/14↑ | **keep-as-isolation**（commander 工作树） | 节点 M1：文档选择性 PR（🔴 禁整支直合——branch 侧 CURRENT/README 旧于 main，直合=回退） |
| `MAformac-g2-mask` | g2-masking `47ca8cda` | 0↓/2↑ 干净 | **merge-via-PR 首选**（代码 only，无 docs 冲突） | 节点 M1（等磊哥⑤+①） |
| `MAformac-g8-tool` | g8-tool `64c6f62f` | 0↓/1↑ 干净 | **merge-via-PR 首选**（代码+generated only） | 节点 M1（等磊哥⑤+②口径确认） |
| `MAformac-grill` | dim11-dim5 `f9e67901` | 147↓/8↑ | **keep**；只港其 2 个新 grill 文档（Dim11/5），禁整支合 | 节点 M1 文档 PR（等磊哥③ lock） |
| `MAformac-uiue` | uiue/phase4 `56b0b95a`+dirty | 89↓/6↑ | **keep-as-isolation**（R7 显式 blocks `uiue_merge_to_mainline`） | 节点 M4（candidate signoff 之后单独立项，非本路线图范围） |
| `.d25-worktrees/k1-spike-ledger` | d25-k1 `dc5ef7ec` | 7↓/1↑ 干净 | **merge-via-PR 候选**（5 份 D25 K1 phase0 receipt docs） | 节点 M3（磊哥单独拍：D25 收据是否还要进 main） |

### 已耗尽隔离树（cleanup-safe，等一次性清理授权）

| 树/分支 | 证据 | 处置 |
|---|---|---|
| `MAformac-g5` / `MAformac-g6` / `MAformac-g7` | PR #9/#10/#11 已 rebase-merge；分支 tip 与 main patch 不等价但 `main..branch` diff 显示**直合会删掉 main 上更新的文件**（C5TinyAblationHarness、gate7 design 更新） | 🔴 **绝不直合**；worktree+branch 删除（清理授权后）。g7 分支侧 gate7 doc 若有残差，按文件 port 不按分支合 |
| `.d24-worktrees/` ×3 | cherry +0，全并入 main | branch+worktree 删除 |
| `MAformac-w1` / `MAformac-w2` | 同 HEAD `e894eb71`，cherry +0（r5b 窄切片已被 main 吸收） | branch+worktree 删除（r5b 留档在 runs/ 不丢） |
| `/tmp/maformac-*` ×2 | 均为 main 祖先，一个 gitdir 已 prunable | `git worktree prune` + 删除 |
| 裸分支 a2/doc-cascade/pr4/define-c1c2 | cherry +0 | branch 删除 |
| 裸分支 feat/change3(+3)/lora-dataset-build(+8)/p0-function-spec(+1) | 有未合 commit 但全是**旧范式历史**（generic frame 时代） | **keep-archive**（不合不删，历史溯源） |
| backup/uiue-* ×3 + uiue/visual-ssot | UIUE 历史备份 | keep-archive，UIUE 收口时随 M4 一起裁 |

## §2 合并节点计划（什么节点做什么）

```
现在（HOLD 保持现状）
 │  磊哥拍 ①masking岔口 + ②E-2 + ③grill lock + ⑤consolidation
 ▼
节点 M1 — wave-1 consolidation（staged PR，一次一支，绿了再下一支）
 │  PR-α: c5gate/g2-masking-enforce → main（代码，0 behind，干净）
 │  PR-β: c5gate/g8-tool-count → main（代码+generated，0 behind，干净）
 │  PR-γ: 文档整编支（🔴 新开 branch off main=ab355f6c，把以下【复制/port】进来，
 │        不 rebase 旧支）：commander-log 3 件 + c5-training-readiness-grill 全语料
 │        （landing-matrix reconcile 版 + Dim10/11/5 + grounded round + SYNTHESIS）
 │        + handoffs + 本文件 + lora-loop-blueprint + 刷新后的 CURRENT.md
 │  每支：CI Verify 绿 + make verify-all 本地绿 + ≥1 异源审 → 磊哥 merge（apply gate）
 ▼
节点 M2 — 树清理（磊哥一次性 cleanup 授权后执行，破坏性动作前 dry-run 清单上抛）
 │  删：g5/g6/g7、d24×3、w1/w2、/tmp×2、cherry+0 裸分支
 │  留：feat/* 历史档、backup/uiue*、uiue 两树
 ▼
节点 M3 — D25 K1 receipts PR（磊哥单独拍要不要）
 ▼
（R7 线，与 M1-M3 正交）
节点 T — 磊哥④ tiny-ablation run-auth → 裁决-A 真跑 → …（见姊妹篇闭环图）
节点 M4 — candidate signoff 之后：UIUE merge 立项、golden/voice 解锁（R7 blocks 列表逐项）
```

**PR 纪律**（沿用 D-011 实证）：commander 不 merge（磊哥是 apply gate）；每 PR 补 `verify.yml` fetch base+head 已在 main 修净；收稿 gh/grep 一手核非 ack；staged 不 batch。

## §3 现在是否保持现状 — verdict: **HOLD（保持现状）**

- 三个 wave-1 树承载着已双审 CONFIRMED 但未拍板的产出 → 动它们 = 在磊哥拍板前改变证据现场。
- g5/g6/g7 等清理候选零风险但也零收益紧迫性 → 攒到 M2 一次授权一次清，避免碎步破坏性操作。
- 唯一有**时间压力**的是 R7 route-only signoff **2026-07-15 过期**：若 M1/T 节点拖过此日，需磊哥续签或重签（放进 5 件决策的附注）。

## §4 3 worker 工作目录（现状 + 派工规则）

| worker | 现驻目录 | 分支 | 派工规则 |
|---|---|---|---|
| %44 | `~/workspace/MAformac`（主树） | doc-absorption | read-only 调研/盘点直接干；**任何代码任务必新开 worktree off main**（T-1 index 隔离纪律，禁与 commander 同树写） |
| %45 | `~/workspace/MAformac`（主树） | doc-absorption | 同上；M1 节点时它是 rebase-merge 执行位（D-011 先例） |
| %43 | `~/workspace/MAformac-uiue` | uiue/phase4 | UIUE 树隔离保持；跨树素材任务用绝对路径 read-only（本次 L3 先例）；UIUE dirty（AGENTS/CLAUDE 改动+6 dispatch docs）不动，M4 时随 UIUE 收口一起裁 |
| commander %42 | 主树 | doc-absorption | 指挥非执行；tmux 保持 2×2（A.7 纪律：调研/实施派 worker，subagent CC 仅终极对抗审计） |

## §5 文档级联与指针（哪份权威文档活在哪棵树）

| 文档 | 现居 | main 上有吗 | M1 后落点 |
|---|---|---|---|
| `CLAUDE.md` 宪法（§9 route banner） | main（各树自带快照） | ✅ 最新在 main | 不动；§9 banner 在 M1-γ 时按新基线刷一段 |
| `docs/CURRENT.md` 路由牌 | 各树各版本，**doc-absorption 版已 stale**（记 771f48a） | main 版也旧 | M1-γ 带刷新版进 main（唯一权威） |
| grill 总 SSOT `docs/grill-tournament/grill-decisions-master.md` | main | ✅ | 不动 |
| **C5 训练 grill 语料** `docs/c5-training-readiness-grill/`（442+ 决策/landing-matrix/SYNTHESIS） | 🔴 **doc-absorption 分支**（main 只有 gate7-design 单件经 PR #11） | ❌ 大部分不在 | **M1-γ 主要货物**——这是当前最大的「权威文档不在 main」缺口 |
| commander-log 记忆图谱 3 件 | doc-absorption | ❌ | M1-γ |
| handoffs（6-30 以来） | doc-absorption | ❌ | M1-γ |
| R7 签字证据 `docs/project/phase0/r-l17-*` | main | ✅ | 不动；candidate signoff 时新增文件 |
| 本文件 + lora-loop-blueprint | doc-absorption | ❌ | M1-γ |
| wave-1 审计/receipt 一手档 | 仓外 `runs/2026-07-02-*`（两个 run 目录） | 仓外（约定俗成） | 保持仓外；仓内文档 cite 绝对路径 |

**级联规则**（derived-tracking 纪律）：M1-γ 合并 = 里程碑 → 同步刷 CLAUDE §9 banner、CURRENT.md、MEMORY.md as-of 行、本文件 §0/§2；R7 到期/续签 → 刷 §0/§3。

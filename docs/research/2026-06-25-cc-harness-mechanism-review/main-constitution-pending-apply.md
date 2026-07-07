---
artifact: pending_apply_patch
target: 项目宪法 main 主线回写（harness 升级 T10-12）
authority: pending_apply_not_yet_landed   # 内容备好，尚未 apply 到真宪法
created: 2026-06-26
decision: 磊哥 2026-06-26 拍 A 方案（cross-worktree 不在 uiue 改 tracked 宪法）
decision_source: brainstorm-decisions.md「🔴 main 主线待回写」段（Q9=B）
---

# 项目宪法 main 主线 — 待 apply patch（T10-12）

> 🔴 **A 方案（磊哥拍）**：cross-worktree 不在 uiue 直接改 tracked 宪法（会撞 codex 长跑 git index + 让 main drift；且 main worktree `~/workspace/MAformac` 现 checkout `codex/rebuild-c6` 被占）。内容备此，**等 main worktree 切回 main + 两边 codex 收口后，main session 起手按本 patch apply**，再经 git 同步回 uiue。
>
> **两文件夹落点**：uiue 分支文件夹 = 本 patch（已落，untracked 安全）；main 主线文件夹 = apply 目标（`~/workspace/MAformac` 切回 main 后改真宪法）。

## T10 — `docs/project/collaboration-and-roles.md §7`（框架链 + Pocock 诚实标注）

**① 框架链编排锚点**（加进 §7）：
```
grill-with-docs（设计澄清）→ 决策 SSOT（grill-decisions-master）→ openspec change（契约 SSOT，判 propose vs incremental apply）→ writing-plans plan（authority=implementation_plan_not_ssot，必退役）→ heavy-work（执行）→ archive
三层 SSOT 分离：契约=openspec spec / 决策=grill / 计划=plan(非 SSOT 必退役)
```
**② 🔴 Pocock 诚实标注**（加进 §7 Pocock 条目）：
```
⚠️ Pocock 实际未驱动阶段路由（历史 9 次命中全是 schema 转述，未真分诊）；阶段实际由 /goal 派单 + handoff 决定。Pocock 退化为 phase0 manifest 一次性分诊。要么真用要么明退，别留虚条目误导新 session。
```

## T11 — `CLAUDE.md §2`（propose vs incremental apply gate）

**加进 §2 OpenSpec 核心机制后**：
```
🔴 propose 新 change vs incremental apply 判定 gate：
- 契约已在 spec 锁全 → incremental apply（改 tasks.md / 勾选，不 propose）。
- spec 缺 Requirement → propose 新 change。
判错（已锁却 propose）= 重复 propose 污染 changes/。
```

## T12 — `docs/project/collaboration-and-roles.md §4.5`（七段 closure drop）

**drop/降级 §4.5 七段 closure 硬模板**：
```
七段 closure 硬模板与 session-closure Step5 重叠（over-engineering）→ drop 硬模板，保留 handoff append-only（≤40 行）。
```

## apply 后验证（contract existence test）
1. `grep -c "框架链\|Pocock 实际未驱动" docs/project/collaboration-and-roles.md` ≥ 2
2. `grep -c "propose 新 change vs incremental apply" CLAUDE.md` ≥ 1
3. `grep -c "七段" docs/project/collaboration-and-roles.md`（确认 drop 后无残留硬模板 / 或标 dropped）
4. `openspec validate --strict` 不破。

## 状态
⏳ **pending apply**（内容备好，未 landed）。main session 起手读本 patch → apply → 删本文件或标 applied。

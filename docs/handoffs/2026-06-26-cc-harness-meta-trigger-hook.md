# Handoff 2026-06-26 — CC harness 元扳机 hook 实装（档 2 第①②段落地）

> uiue worktree（分支 `uiue/phase4-default-scope-presentation`）。本会话纯 `~/.claude/` 机制升级 + 脑暴，**未碰 MAformac 业务代码**（codex 长跑并发占工作树改 App/Core/Tests/pbxproj，与本会话隔离）。

## 本次完成
- **脑暴 A（档 2 hook 实装细节，A1-A4 全拍）**：A1=B 双腿注入点 / A2=B 窄信号词表 / A3=B PostCompact 并进已有 hook / A4=B 软注入轻量主观门。SSOT = `docs/research/2026-06-25-cc-harness-mechanism-review/brainstorm-decisions.md`（档 2 收口段含完整可写 script 规格 + 实装进度）。
- **hook 实装第①②段**：`~/.claude/scripts/hooks/action-trigger-inject.mjs`（UserPromptSubmit 窄信号+每8turn兜底 / PreToolUse 极窄动作点 Write基线→①核源·Agent→②回溯 / killswitch+fail-closed）。沙盒 8/8 case 全绿。挂 uiue `.claude/settings.local.json`(gitignored 不撞 codex index)。🎉 **本会话实测激活**（Edit docs/ 真触发 ①核源注入 + jsonl 记录真 session）。
- **档 1 全收尾**（前序会话）：3 新 rule(grill-baseline-skeleton-upfront / dispatch-inline-ssot / retreat-reflex) + 3 absorb(aesthetic anchor硬门 / completion-claim mock桩态 / heavy-work滚动审计) + grill-with-docs DECISION-ENTRY-TEMPLATE + hooks.md 官方16事件核对。

## 未完成（下次接）
- **档 2 第③段**：≥5 会话试点观察「PreToolUse Write基线路径 ①核源触发频率烦不烦」→ 顺了迁用户级 `~/.claude/settings.json`，**同时**摘 token-threshold-hook + session-start-compact 末尾加 A3 四问铁律。jsonl `~/.claude/logs/action-trigger.jsonl` 供抽查。
- **档 3 项目宪法回写（等 main 主线，内容已备好在 brainstorm-decisions「main 待回写」段）**：collaboration §7 框架链+Pocock诚实标注 / CLAUDE §2 propose vs incremental apply gate / collaboration §4.5 七段drop。⚠️ cross-worktree，在 uiue 改会让 main drift，必在 main session 做。

## 关键发现
- **A1 frame-break**：UserPromptSubmit 只看「磊哥的话」，真动作点在 **PreToolUse**（治「我中途自产动作」漏检——今天 goal-dispatch 同 session 复犯、grill-recall 三连那类）。
- `cite-verify-posttool.mjs`(PostToolUse 写后机械核数字 source) 与本 hook PreToolUse ①核源(写前提醒) **互补不重复**，保留两者。
- 反复犯：嘴上「攒到收口回写」转头违反自己刚沉淀的 grill-baseline-skeleton-upfront「每拍即填不攒」——靠磊哥「记录又忘了？」catch。已改为每拍即回写。

## 当前状态
- git：codex 并发改 App/Core/Tests（tracked M），本会话产出全在 `~/.claude/`(全局,不进 worktree git) + `docs/research/...brainstorm-decisions.md`(untracked) + raw 备份 `~/workspace/raw/05-Projects/MAformac/research/2026-06-25-cc-harness-mechanism-review/`。**未 commit**（避让 codex git index）。
- hook 试点：本 worktree session 已激活，下个本 worktree session 继续累积试点会话数。

## 下次第一步
A 继续 UIUE 主线（看 codex Phase 进度）/ B 试点够了迁 hook 用户级 / C rules 体量去重脑暴（Q8-D）。无紧急 blocker，hook 试点被动观察即可。

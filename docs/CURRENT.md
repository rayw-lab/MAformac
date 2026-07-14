---
kind: current-router
as_of: 2026-07-14
authority: router_only
latest_handoff: docs/handoffs/2026-07-14-governance-foundation.md
history_index: docs/archive/current/2026-07-14-pre-governance-history-index.md
---

# CURRENT — MAformac 当前路由牌

本文件只回答“现在先读什么、下一步是什么、不能自动做什么”。任何 HEAD、remote、测试或 runtime 状态必须 live 重核；本页不构成产品或执行授权。

## 当前真态

- V9 A/fan-in identity repair 已在目标分支形成技术 DONE；exact HEAD、remote readback、验证与 residual 见 latest handoff 指向的 closeout。
- 本轮顶层 governance repair 负责安全边界、authority matrix、OpenSpec 注入与机械 lint；它不改变产品行为或 V9 identity 结果。
- 工作树可能包含用户未提交改动。任何写入前先读 `git status --short`，不得把 dirty prose 当已提交 authority。

## 起手路由

1. 读 `CLAUDE.md` 的稳定宪法与 authority matrix。
2. 读本页。
3. 按任务查 `docs/README.md` 与非权威索引 `docs/ACTIVE-LESSONS.md`。
4. 只读 frontmatter 指向的 latest handoff，并核其 predecessor/supersedes；随后以 live Git/runtime 为准。

## 下一步

- governance repair 完成后，产品主线从 S8 或 B lane residual 中另行选择；本页不替用户选择，也不自动点火、ratify、promote 或翻格。
- 新产品行为继续走 OpenSpec；纯治理 lint/config 修复不得冒充产品 spec 或 V-PASS。

## Stopline / non-claims

- 不声称 S8、真实三臂、B7/V1 ceremony、operator/V-PASS、C6 acceptance、candidate signed 或 B lane deferred 产品任务完成。
- 不把 local governance lint、OpenSpec strict 或 macOS source/build proof 提升为 runtime、desktop operator、true-device 或 live-api proof。
- 不从历史 CURRENT、旧 handoff、Memory、agent prose 或 generated counters 的手写副本恢复当前状态。

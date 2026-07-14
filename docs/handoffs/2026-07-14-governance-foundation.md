---
artifact_kind: project_handoff
date: 2026-07-14
predecessor: docs/handoffs/2026-07-14-v9-fanin-identity-repair.md
supersedes: docs/CURRENT.md@a33b0a346099d941e09405f6c6a6f8099b550de2
authority: handoff_only
---

# 顶层 governance foundation handoff

## Goal

在不回退 V9 fan-in identity repair、不改变产品行为的前提下，收束公开仓安全策略、authority 分工、OpenSpec 自动上下文、CURRENT 路由与易复发的结构漂移。

## Constraints

- exact HEAD、remote、验证和最终 verdict 只认本任务 closeout 与 live Git。
- 本 handoff 不授权 S8、B lane 产品任务、operator/V-PASS 或任何产品翻格。
- 用户既有 dirty paths 必须在集成后恢复并单独披露。

## Progress

- CLAUDE 已转为稳定宪法并建立领域化 authority matrix。
- blanket waiver 已收窄为机器可检的 exception registry。
- 项目 Codex 默认改为 `on-request + workspace-write`；OpenSpec config 仅保留稳定上下文。
- CURRENT 改为短路由牌；历史由 archive index、Git history 与显式 handoff 链追溯。
- governance lint 覆盖配置、frontmatter、patch 残渣、exception expiry、路由链、managed block、skill ownership 与聚合门接线。

## Key evidence

最终 closeout：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-14-governance-foundation/CLOSEOUT.md`。

## Next step

先 live 读取本 handoff frontmatter，再读 closeout 并复核 Git/runtime。产品主线从 CURRENT 中另行选择，不从本治理任务自动启动。

## Proof ceiling

本任务最多形成 `local + source_contract + governance_integration + remote_git_readback`；不形成产品 runtime、desktop operator、true-device、live-api 或 V-PASS。

---
status: active_router_only_not_ssot
artifact_kind: current_route_board
authority: router_only_not_contract
updated: 2026-07-02
last_verified_origin_main: f4af8ccf（含 #12-#25 合流；head_truth_rule 以 live git 为准）
branch: codex/rebuild-c6-doc-absorption-20260624
head_truth_rule: "Run git rev-parse HEAD and git rev-parse @{u}; this route board records verification inputs and loses to live repo state."
expires_when: "wave-1 consolidation PR 合并后，或磊哥 5 件决策任一改变路线时，必须刷新。"
---

# CURRENT — MAformac 当前路由牌

> 本文件是交通牌不是事实源。与 `CLAUDE.md`、grill SSOT、签字证据、live repo 冲突时本文件让位并须更新。
> 前版（D25 K1 spike-ledger 路由，updated 2026-06-30）已被本版 supersede：D25 之后项目经历了 C5 训练就绪 grill（442+ 决策）→ 5-gate construction（PR #9/#10/#11 merge）→ overnight wave-1（gate8/gate2/grill 补深），路线对象已从「D25 K1 receipts」变为「pre-LoRA 训练前节点」。D25 K1 的 8 行 receipt 工作若仍需要，见 baseline-roadmap §2 节点 M3（磊哥单独拍）。

## 当前阶段（2026-07-03 凌晨：通宵 v6 链路收官，等磊哥晨拍）

🎉 **v6 tiny-ablation verdict：A 轴 adapter 15/15 满分——「A+ 契约是否解 v5 NO_TOOL」= YES**（`docs/c5-training-readiness-grill/v6-tiny-ablation-verdict-2026-07-03.md`+附录3件）。B 11/15 归因数据稀疏；paired 配对暴露 tiny 过拟合窄化（D delta -10）。v6.1 EOS 增量：A 保持满分+重复病理 68/68→1/68。**wave-1 协议串底座 4500 行 build+数据门全量 exit0 全零**；live 云生成等凭证。晨报=`docs/handoffs/2026-07-03-overnight-v6-verdict-morning-brief.md`（醒来 0-5 拍：billing/PR#26-27-28 merge/wave-1 5拍/GF 121+16 决策 lock/F-044 阈值终值）。v5 verdict=BLOCKED_INVALID 维持（历史）；R7 route-only 至 2026-07-23，candidate 仍 unsigned。

## 前情（2026-07-02 晚，M1 已收口；本节 historical snapshot，后续见 commander-log D-028~034）

**M1 consolidation 完成（D-018）：wave-1 全部合流 main=`80ea379c`，验收 PASS（main 范围）。** 四支 PR 链：#13 α gate2 masking（token 真 enforce + 反向 guard 三 split）→ #12 β gate8（562 工厂实算）→ #14 γ 40 件文档整编（grill 语料/commander-log/基线双文档进 main）→ #15 δ 验收修复（gate8 曾改派生物没改工厂，验收 diff 门抓到 → 工厂实算 + regen 重排）。每支经交叉审/亲核（α 曾被对抗 fixture 抓 P0 guard 漏 test split，修后 P0-RESOLVED）。验收唯一残留 = sibling UIUE fixture 环境噪声（非 M1 回归，M4 收口消解）。**E-2 已 locked+G7A-D 实装 merged**（本段为 M1 收口时 historical；governance-fit 治理 grill W1/W2/W3 各 40 决策另见 grill README）。

## 两份当前基线文档（起手读）

1. ⭐ `docs/baseline-roadmap-2026-07-02-pre-lora.md` — 全树/分支/PR 状态矩阵、合并节点计划（M1 consolidation staged PR → M2 清理 → M3 D25 receipts → M4 UIUE）、现状 verdict=HOLD、3 worker 目录规则、文档级联指针。
2. ⭐ `docs/lora-loop-blueprint-2026-07-02.md` — 此刻→训练结束闭环鸟瞰：8 gate+2 裁决门真实态、生成→门→裁决→训→评循环总图、run receipt 契约、节点序 A-H、巨人肩膀使用矩阵（home-llm/Hammer/xLAM/BFCL/hf-skills）。

## 决策台账（原 5 件已全落 + 新周期）

原 5 件全 CLOSED：①masking override locked+merged ②E-2 locked（grill 43 决策+G7A-D 实装 merged）③grill 58 条 locked ④tiny v5 已真跑（→重标 BLOCKED_INVALID，v6 另签）⑤consolidation done（13+ PR 合流）。**当前等磊哥**：v6 run-auth（Phase 0-3 完成后按 FINAL 档 §5 签）；M2 树清理授权；M4 UIUE。R7 已续签至 **2026-07-23**。

## 禁止动作（R7 + 现状 HOLD）

- 🔴 真训练 / 真数据生成 / C6 acceptance / candidate comparison / demo-golden / voice / endpoint / UIUE merge / V-S-U-PASS 声称——全 BLOCKED 等 candidate signoff + explicit run auth（`docs/project/phase0/r-l17-human-review-evidence/R7-final-route-deframing-signoff.md`）。
- 🔴 不删不合任何隔离树/分支（含 g5/g6/g7——分支 tip 落后，直合会回退 main 上更新的文件，见 baseline-roadmap §1）；清理等节点 M2 一次性授权。
- 🔴 doc-absorption / grill 两分支**禁整支合 main**（147 behind，分支侧 CURRENT/README 旧于 main）——文档进 main 走 M1-γ 新开文档整编支。
- 🔴 raw 座舱原文/PII/报价不入 bench/训练数据（CLAUDE §6）。

## 权威指针

- grill 总 SSOT：`docs/grill-tournament/grill-decisions-master.md`（main）
- C5 训练 grill 语料（500+ 决策 + landing-matrix + E-2 系列 + tiny teardown 双档）：`docs/c5-training-readiness-grill/`（M1-γ/RAT 已同步 main，本分支持续领先随批次 port）
- 指挥官记忆图谱：`docs/commander-log/{COMMANDER-INDEX,decisions,swarm-runs}.md`（D-001~027）
- 最近 handoff：`docs/handoffs/2026-07-02-commander-day2-m1-e2-g7-hermes-closeout.md`
- wave-1 / 基线盘点一手档（仓外）：`~/Projects/agent-tmux-stack-research/runs/2026-07-02-{overnight-pre-lora-push,baseline-roadmap}/`
- OpenSpec 活跃 carrier：`openspec/changes/{rebuild-c6-four-layer-bench,retrain-c5-lora-d-domain,define-runtime-presentation-bridge}/`（retrain-c5 是 draft 非执行授权）

## 本地 iOS build truth（沿用）

- 本 worktree Codex `build-ios-apps` profile=`ios`，scheme=`MAformacIOS`，专属模拟器 `iPhone 17 Pro`；UIUE worktree 必须用不同模拟器（同 bundle id 互相覆盖）。

## UIUE 隔离树（沿用）

- `/Users/wanglei/workspace/MAformac-uiue`（uiue/phase4，R7 显式 blocks `uiue_merge_to_mainline`）：主线只做 read-only 交叉检查；引用 UIUE file:line 前必 live 重确认。收口随 baseline-roadmap 节点 M4。

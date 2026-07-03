---
status: active_router_only_not_ssot
artifact_kind: current_route_board
authority: router_only_not_contract
updated: 2026-07-03
last_verified_origin_main: f4af8ccf（含 #12-#25 合流；head_truth_rule 以 live git 为准）
branch: codex/rebuild-c6-doc-absorption-20260624
head_truth_rule: "Run git rev-parse HEAD and git rev-parse @{u}; this route board records verification inputs and loses to live repo state."
expires_when: "wave-1 consolidation PR 合并后，或磊哥 5 件决策任一改变路线时，必须刷新。"
---

# CURRENT — MAformac 当前路由牌

> 本文件是交通牌不是事实源。与 `CLAUDE.md`、grill SSOT、签字证据、live repo 冲突时本文件让位并须更新。
> 前版（D25 K1 spike-ledger 路由，updated 2026-06-30）已被本版 supersede：D25 之后项目经历了 C5 训练就绪 grill（442+ 决策）→ 5-gate construction（PR #9/#10/#11 merge）→ overnight wave-1（gate8/gate2/grill 补深），路线对象已从「D25 K1 receipts」变为「pre-LoRA 训练前节点」。D25 K1 的 8 行 receipt 工作若仍需要，见 baseline-roadmap §2 节点 M3（磊哥单独拍）。

## 当前阶段（2026-07-03 午前：**N4-ACCEPTED-LOCAL**，goal N0-N4 兑现，等磊哥 4 键）

🎯 **goal 收口（D-043）**：N0 落账✅ N1 备份 PR #30✅（CONFLICTING 转分级整编，裁决表 keep-main 51/take-branch 4/union 11 已出）N2 五支 PR 修复-复核链全闭环✅（#26=`edfc2198` 全 PASS / #27=`a400b01a` APPROVE / #28=`49fa0b9b` APPROVE+claim correction / #29=`871307d9` APPROVE_FOR_PR29_P1_SCOPE / #31=`f163eedf` APPROVE_FOR_PR31_DELTA，全 local verify 非 CI）N3 GF rev3✅ **N4 验收=`docs/c5-training-readiness-grill/n4-train-readiness-acceptance-2026-07-03.md`（N4-ACCEPTED-LOCAL：preflight strict exit0 commander 独立复跑+DataGate 语义门对抗探针 fail-closed+配方锚/F-044 默认锁+premortem/runbook 门）**。🔴 不清的帐：prepare receipt broader gates / run-auth+R7(N6/N7) / CI billing / GitHub reviews=0。run-auth 后第一动作=T1 hang 2-iter smoke（mlx-lm#1348 触发面命中，runbook 门）。

🔀 **路线更新（D-044/D-045，磊哥 2026-07-03 午拍）**：第一步工程面已收干净——**docs 合流走 PR #32**（整编支 `e01aa7c3`，%43 复核 APPROVE，MERGEABLE；#30 留备份勿合）；billing 修复后 commander 自动 rerun checks，**CI 真绿按依赖序合 #26→#27→#28→#29→#31→#32**。第二步 **N5 canary 进行中（只生成+judge 不训练，目标=候选数据质量）**：Anthropic 生成=后台 subagent CC（Opus）/ OpenAI judge=codex worker——**云凭证键解除**，剩 **3 键：billing / merge / run-auth**。canary 管道=sub-CC 60 行（字段模板取 N4A 真实行保 digest 正确+open-close 极性对称）→ DataGate（含硬化语义门+redaction）→ %43 judge → 验收报告 → 过了才扩 wave-1。

## 前情（2026-07-03 晨：外审收窄落账 D-040 + goal=N0-N4 自动推进 train-readiness）

🔴 **外审收窄（磊哥转达，D-040，全部 live 亲核成立）**：v6 结论保留但窄化——A 轴 adapter 15/15（verdict:46）证「A+ 契约解 v5 NO_TOOL」=YES；B 11/15 未达 draft 门 14/15（verdict:16,29，终值待 lock）；v6.1 EOS 重复病理 68/68→1/68 真进展，但同帐 C 4/4→2/4、D 8/34→5/34、+4 parse_error（verdict:48-50）→ 表述统一「**EOS 改善重复病理，tiny 稀疏下仍有 parse/早停/泛化退化残留**」，禁写"输出稳定"。**PR #26-29 live 实况（2026-07-03 gh 亲核）：全 OPEN、GitHub latestReviews=0、verify check 全 FAILURE×2**（billing 归因，但 FAILURE 不写绿/不写 merge-ready/本地 worker review≠GitHub review）；#26 head 已变 `e6a8849f`（旧本地 APPROVE 绑 `3b081823` 失效）→ 四支 PR 全部需绑当前 head 重审（#27=`a400b01a`/#28=`49fa0b9b`/#29=`5c68f945`）。**wave-1 口径 = protocol-string substrate built（4500 行）+ C5DataGate local pass，NOT train-ready**：builder receipt blocked + loss-mask preflight strict exit66（294 长行>8192 / valid-test under-supervised / 云生成 + cross-vendor judge 未跑，verdict:55）。训练风险进配方锚：D 轴 18/34→8/34→5/34 窄化 + **query→actuation（只读变控制）安全级**。

**当前 goal（磊哥 2026-07-03 晨 /goal，纯自动）**：N0 落账收窄→N1 docs 分支收编（推新分支；behind-7 旧 commit 已核全在 origin/main）→N2 PR head 重审 wave（%43 #26增量+#29 / %44 #27#28，绑 head SHA + ≥1 实跑）→N3 GF rev3→**N4 wave-1 train-readiness 闭环收尾并验收**（E-2 降档挂载实装 + preflight strict exit0 + valid/test 监督契约 + 配方锚 + F-044 默认 14/15 标可 override）。人审仅 4 键：billing / 云凭证 / merge / run-auth。路线图快照=`~/workspace/data/exports/snapshot-20260703-065315.md`。v5 verdict=BLOCKED_INVALID 维持（历史）；R7 route-only 至 2026-07-23，candidate 仍 unsigned。

## 前情（2026-07-03 凌晨通宵收官 historical；「双审 APPROVE/数据门全量兑现」表述已被上方 D-040 收窄 supersede）

v6 tiny-ablation verdict（`docs/c5-training-readiness-grill/v6-tiny-ablation-verdict-2026-07-03.md`+附录3件）；paired 配对暴露 tiny 过拟合窄化（D delta -10）；晨报=`docs/handoffs/2026-07-03-overnight-v6-verdict-morning-brief.md`（其 0-5 拍清单中 PR/数据门表述以 D-040 为准）。

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

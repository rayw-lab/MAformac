---
status: active_router_only_not_ssot
artifact_kind: current_route_board
authority: router_only_not_contract
updated: 2026-07-05（凌晨）
last_verified_origin_main: f4af8ccf（含 #12-#25 合流；head_truth_rule 以 live git 为准）
branch: codex/rebuild-c6-doc-absorption-20260624
head_truth_rule: "Run git rev-parse HEAD and git rev-parse @{u}; this route board records verification inputs and loses to live repo state."
expires_when: "R3 训后 eval/verdict 落地、正式 1800 起跑/停止/完成、UIUE merge 路线变化、或任何 D-10x 决策改变 launch authority 时，必须刷新。"
---

# CURRENT — MAformac 当前路由牌

> 本文件是交通牌不是事实源。与 `CLAUDE.md`、grill SSOT、签字证据、live repo 冲突时本文件让位并须更新。
> 前版（D25 K1 spike-ledger 路由，updated 2026-06-30）已被本版 supersede：D25 之后项目经历了 C5 训练就绪 grill（442+ 决策）→ 5-gate construction（PR #9/#10/#11 merge）→ overnight wave-1（gate8/gate2/grill 补深），路线对象已从「D25 K1 receipts」变为「pre-LoRA 训练前节点」。D25 K1 的 8 行 receipt 工作若仍需要，见 baseline-roadmap §2 节点 M3（磊哥单独拍）。

## 当前阶段（2026-07-05：**D-106/D-107 后 baseline——qa 三轮 9/9/9 撞 actuation prior 硬墙；Codex App 接管执行基线；formal 1800 HOLD pending Phase 1-4；先做 Phase 1 量尺/标签权威修复**）

🔴 **D-106/D-107 最新真态（本节 supersede 下方 R3 in-flight 旧态）**：D-105/D-106 坐实 qa 三轮可比真数 adapter `any_tool_call_fail`=**9/9/9**（scanner 硬化后，旧「9→8→10 恶化」叙事作废——R3=8 是漏计 `query_volume` artifact），逐 case 揭示=**模型固有 actuation prior 硬墙**（base 原模型也失败 4 个 WINDOW/DOOR/SUNROOF/SUNSHADE），adapter-only 数据法两轮（R3 堆量/R4 改挂载形态）纹丝不动。**D-107（磊哥拍）**：从 D-106 出发开新执行锚——① `docs/baseline-roadmap-2026-07-05-c5-d106.md`=当前 C5 起手 baseline（planning，非契约）② Codex App worker 接管执行基线，commander 纯编排 ③ formal 1800 **HOLD pending Phase 1-4** ④ R-L17=`route-only signed; candidate signoff unsigned` ⑤ 第一执行单=**Phase 1 ONLY**（scanner hardening 正式化 + 6 label authority 冲突裁决表→repo 可复跑 gate）。stoplines：不训练/不生成新数据/不启动 formal/不 merge UIUE/不碰 `Core/Training`。

📌 **当前路线（Phase 序，baseline §2 鸟瞰）**：Phase 1 量尺+标签权威修复（判断系统先可靠）→ Phase 2 runtime query safety gate（主线，OpenSpec `RuntimeQueryGuard`）→ Phase 3 R5 pair-boundary one-shot（旁线 falsification）→ Phase 4 D-085 gate semantics 重拍（adapter-only qa=0 vs runtime-gated safety）→ Phase 5 formal 1800（若 Phase 4 允许）→ Phase 6 C5 exit package。🔴 **Phase 1 依赖一手产物**：`R5-SCANNER-HARDENED.md`（9/9/9 规则+失败四分类）+`R5-LABEL-AUTHORITY-AUDIT.md`（9 冲突归属矩阵，含 LABEL-AUTH-005/007/008 天窗/遮阳帘 default_scope=**磊哥 LEIGE_KEY 待拍**）；`tools/check_eval_mount_validity.py` 与 scanner 门当前仍是 run-dir 脚本、**未进 repo**=Phase 1 待迁。

## 【前情】D-097 后 R3 in-flight（2026-07-05 凌晨，historical，已被上方 D-106/D-107 supersede）

🔴 **D-095~D-102 最新真态**：R2b run `155204` 训练健康完成（600/600，val 0.010），T-D 初判 `F044_R2B_FAIL_STRATIFIED` 后被 **D-097 翻案**：门轨 11/64 case mount-invalid（A5 错位拼接+B6 挂载缺失，根因=case source_sample_id 按序号 join），A/B 有效上限被坏量尺压成 10/15+9/15；v3 量尺修复+配对重评后现有 adapter 有效面 **A 15/15 / B 15/15 / D 19/34**=D-085 三轴 PASS。唯一真残余=expanded qa 负面，口径固定四数字 `total=11 / adapter=9 / base=2 / original_v3=0`。R3 修复=qa qneg 154 行（108 unsupported+36 对照+10 真 query guard），trainpack 5653 静态门/judge 全绿；**R3 短训第三跑在飞**（`F044-r3train-run-20260704T211035+0800`，%1 executor+夜间 watchdog --armed；前两跑被 operator redline 拦停归档 PARTIAL）。

📌 **当前路线**：R3 训完→四轴 eval（W52 跑道，v3 base 锚 A3/B14/D18）→verdict 达 D-085（A≥12/B>9 非零 delta/D≥18/qa=0 跨轨）+Launch Packet 六件+host baseline+watchdog --armed（pct4 版 sha e8257fab）全绿 → **正式 1800 iters 起跑**（D-100 磊哥提前授权条件式）；任一不绿=停在 verdict/分诊。D-102 条款：formal 起跑 swap>1GB 必上抛磊哥。

## 前一阶段（2026-07-03 午前：**N4-ACCEPTED-LOCAL**，goal N0-N4 兑现，已被 D-053 训练 smoke 改写）

🎯 **goal 收口（D-043）**：N0 落账✅ N1 备份 PR #30✅（CONFLICTING 转分级整编，裁决表 keep-main 51/take-branch 4/union 11 已出）N2 五支 PR 修复-复核链全闭环✅（#26=`edfc2198` 全 PASS / #27=`a400b01a` APPROVE / #28=`49fa0b9b` APPROVE+claim correction / #29=`871307d9` APPROVE_FOR_PR29_P1_SCOPE / #31=`f163eedf` APPROVE_FOR_PR31_DELTA，全 local verify 非 CI）N3 GF rev3✅ **N4 验收=`docs/c5-training-readiness-grill/n4-train-readiness-acceptance-2026-07-03.md`（N4-ACCEPTED-LOCAL：preflight strict exit0 commander 独立复跑+DataGate 语义门对抗探针 fail-closed+配方锚/F-044 默认锁+premortem/runbook 门）**。🔴 不清的帐：prepare receipt broader gates / run-auth+R7(N6/N7) / CI billing / GitHub reviews=0。run-auth 后第一动作=T1 smoke（D-043 预测风险写作 mlx-lm#1348 hang；D-053 已实跑改判为 Metal OOM）。

🎉 **canary 收敛 + N5E 锁定（D-047/D-048，2026-07-03 午后）**：canary 60 行两轮收敛 **CANARY_PASS_EXPAND_OK**（v1 FAIL=跨厂商 judge 抓溯源缺陷（机械门全绿仍 FAIL）→ ledger 修复 → v2 PASS；验收报告+lineage INDEX 28 artifact sha 绑定，run 目录 N5-canary/）。**N5E 扩量 grill 消减锁定**（`docs/c5-training-readiness-grill/n5-expansion-grill-2026-07-03.md`）：12 题=10 default_locked（含声称分层条款：语义抽样维禁升格全量声称）+ **2 磊哥键（N5E-005 人工精度门 / N5E-006 基座 pin=billing→merge 后自动满足）**；landing rev2 三线在途（批契约/验收门/judge 作业书）；M2 树盘点 ready 等授权。D-046「重要节点必 grill 范式」首个完整闭环当日跑通。

🔀 **路线更新（D-044/D-045，磊哥 2026-07-03 午拍）**：第一步工程面已收干净——**docs 合流走 PR #32**（整编支 `e01aa7c3`，%43 复核 APPROVE，MERGEABLE；#30 留备份勿合）；billing 修复后 commander 自动 rerun checks，**CI 真绿按依赖序合 #26→#27→#28→#29→#31→#32**。第二步 **N5 canary 进行中（只生成+judge 不训练，目标=候选数据质量）**：Anthropic 生成=后台 subagent CC（Opus）/ OpenAI judge=codex worker——**云凭证键解除**，剩 **3 键：billing / merge / run-auth**。canary 管道=sub-CC 60 行（字段模板取 N4A 真实行保 digest 正确+open-close 极性对称）→ DataGate（含硬化语义门+redaction）→ %43 judge → 验收报告 → 过了才扩 wave-1。

## 前情（2026-07-03 晨：外审收窄落账 D-040 + goal=N0-N4 自动推进 train-readiness）

🔴 **外审收窄（磊哥转达，D-040，全部 live 亲核成立）**：v6 结论保留但窄化——A 轴 adapter 15/15（verdict:46）证「A+ 契约解 v5 NO_TOOL」=YES；B 11/15 未达 draft 门 14/15（verdict:16,29，终值待 lock）；v6.1 EOS 重复病理 68/68→1/68 真进展，但同帐 C 4/4→2/4、D 8/34→5/34、+4 parse_error（verdict:48-50）→ 表述统一「**EOS 改善重复病理，tiny 稀疏下仍有 parse/早停/泛化退化残留**」，禁写"输出稳定"。**PR #26-29 live 实况（2026-07-03 gh 亲核）：全 OPEN、GitHub latestReviews=0、verify check 全 FAILURE×2**（billing 归因，但 FAILURE 不写绿/不写 merge-ready/本地 worker review≠GitHub review）；#26 head 已变 `e6a8849f`（旧本地 APPROVE 绑 `3b081823` 失效）→ 四支 PR 全部需绑当前 head 重审（#27=`a400b01a`/#28=`49fa0b9b`/#29=`5c68f945`）。**wave-1 口径 = protocol-string substrate built（4500 行）+ C5DataGate local pass，NOT train-ready**：builder receipt blocked + loss-mask preflight strict exit66（294 长行>8192 / valid-test under-supervised / 云生成 + cross-vendor judge 未跑，verdict:55）。训练风险进配方锚：D 轴 18/34→8/34→5/34 窄化 + **query→actuation（只读变控制）安全级**。

**当前 goal（磊哥 2026-07-03 晨 /goal，纯自动）**：N0 落账收窄→N1 docs 分支收编（推新分支；behind-7 旧 commit 已核全在 origin/main）→N2 PR head 重审 wave（%43 #26增量+#29 / %44 #27#28，绑 head SHA + ≥1 实跑）→N3 GF rev3→**N4 wave-1 train-readiness 闭环收尾并验收**（E-2 降档挂载实装 + preflight strict exit0 + valid/test 监督契约 + 配方锚 + F-044 默认 14/15 标可 override）。人审键现状（D-045/D-049 后）：云凭证已解除（subCC+codex 方案）、billing 已解除（repo 转 public）→ 剩 merge 链 / run-auth / N5E-005 人工门；§6 脱敏红线 10 天豁免窗口至 2026-07-13（D-049）。路线图快照=`~/workspace/data/exports/snapshot-20260703-065315.md`。v5 verdict=BLOCKED_INVALID 维持（历史）；R7 route-only 至 2026-07-23，candidate 仍 unsigned。

## 前情（2026-07-03 凌晨通宵收官 historical；「双审 APPROVE/数据门全量兑现」表述已被上方 D-040 收窄 supersede）

v6 tiny-ablation verdict（`docs/c5-training-readiness-grill/v6-tiny-ablation-verdict-2026-07-03.md`+附录3件）；paired 配对暴露 tiny 过拟合窄化（D delta -10）；晨报=`docs/handoffs/2026-07-03-overnight-v6-verdict-morning-brief.md`（其 0-5 拍清单中 PR/数据门表述以 D-040 为准）。

## 前情（2026-07-02 晚，M1 已收口；本节 historical snapshot，后续见 commander-log D-028~034）

**M1 consolidation 完成（D-018）：wave-1 全部合流 main=`80ea379c`，验收 PASS（main 范围）。** 四支 PR 链：#13 α gate2 masking（token 真 enforce + 反向 guard 三 split）→ #12 β gate8（562 工厂实算）→ #14 γ 40 件文档整编（grill 语料/commander-log/基线双文档进 main）→ #15 δ 验收修复（gate8 曾改派生物没改工厂，验收 diff 门抓到 → 工厂实算 + regen 重排）。每支经交叉审/亲核（α 曾被对抗 fixture 抓 P0 guard 漏 test split，修后 P0-RESOLVED）。验收唯一残留 = sibling UIUE fixture 环境噪声（非 M1 回归，M4 收口消解）。**E-2 已 locked+G7A-D 实装 merged**（本段为 M1 收口时 historical；governance-fit 治理 grill W1/W2/W3 各 40 决策另见 grill README）。

## 两份当前基线文档（起手读）

1. ⭐ `docs/baseline-roadmap-2026-07-02-pre-lora.md` — 全树/分支/PR 状态矩阵、合并节点计划（M1 consolidation staged PR → M2 清理 → M3 D25 receipts → M4 UIUE）、现状 verdict=HOLD、3 worker 目录规则、文档级联指针。
2. ⭐ `docs/lora-loop-blueprint-2026-07-02.md` — 此刻→训练结束闭环鸟瞰：8 gate+2 裁决门真实态、生成→门→裁决→训→评循环总图、run receipt 契约、节点序 A-H、巨人肩膀使用矩阵（home-llm/Hammer/xLAM/BFCL/hf-skills）。

## 决策台账（原 5 件已全落 + 新周期）

原 5 件全 CLOSED：①masking override locked+merged ②E-2 locked（grill 43 决策+G7A-D 实装 merged）③grill 58 条 locked ④tiny v5 已真跑（→重标 BLOCKED_INVALID，v6 另签）⑤consolidation done（13+ PR 合流）。**当前等磊哥**：v6 run-auth（Phase 0-3 完成后按 FINAL 档 §5 签）；M2 树清理授权；M4 UIUE。R7 已续签至 **2026-07-23**。

## 禁止动作 / stoplines（R3 + formal launch 态）

- 🔴 不得把 R2b/R3 train_health 写成 behavior pass / candidate pass / C6 acceptance / V-S-U-PASS。
- 🔴 formal 1800 起跑必须现核：R3 四轴 verdict、Launch Packet 六件（W53 R3 对齐版）、fresh host baseline、watchdog --armed 真 pid、LR 450-schedule rc0（tools/verify_formal_lr_schedule.py）；任一缺失=HOLD/PARTIAL。
- 🔴 D-102：R3 短训限定的 host-predicate-v2/quiet-window waiver 不外推 formal；formal swap>1GB 按 D-094 上抛磊哥。
- 🔴 C6 acceptance/comparison、demo-golden、voice/live-loop 产品声称仍需 candidate signoff+proof-class 对应证据（R-L17 体系）。
- 🔴 不删不合任何隔离树/分支（含 g5/g6/g7——分支 tip 落后，直合会回退 main 上更新的文件，见 baseline-roadmap §1）；清理等节点 M2 一次性授权。
- 🔴 doc-absorption / grill 两分支**禁整支合 main**（147 behind，分支侧 CURRENT/README 旧于 main）——文档进 main 走 M1-γ 新开文档整编支。
- 🔴 raw 座舱原文/PII/报价不入 bench/训练数据（CLAUDE §6）。

## 权威指针

- 决策台账：`docs/commander-log/decisions.md` **D-095~D-102**（当夜主线）+ grill 总 SSOT `docs/grill-tournament/grill-decisions-master.md`
- run 恢复板（压缩失忆第一读）：`~/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/STATUS-BOARD.md`
- R3 grill：`docs/c5-training-readiness-grill/f044-r3-grill-2026-07-04.md`；R3 eval/launch packet：run-dir `W52-R3-EVAL-PREFLIGHT.md`+`W53-REFRESH-NOTE.md`+`FORMAL-LAUNCH-CONDITIONS.md`
- UIUE 合并路线：`docs/superpowers/plans/2026-07-05-uiue-merge-battle-plan.md`（v2，执行前 live git 重核）；晨报骨架：`docs/handoffs/2026-07-05-r3-overnight-morning-brief.md`
- 最近 handoff：`docs/handoffs/2026-07-04-f044-round2-morning-brief.md`
- wave-1 / 基线盘点一手档（仓外）：`~/Projects/agent-tmux-stack-research/runs/2026-07-02-{overnight-pre-lora-push,baseline-roadmap}/`
- OpenSpec 活跃 carrier：`openspec/changes/{rebuild-c6-four-layer-bench,retrain-c5-lora-d-domain,define-runtime-presentation-bridge}/`（retrain-c5 是 draft 非执行授权）

## 本地 iOS build truth（沿用）

- 本 worktree Codex `build-ios-apps` profile=`ios`，scheme=`MAformacIOS`，专属模拟器 `iPhone 17 Pro`；UIUE worktree 必须用不同模拟器（同 bundle id 互相覆盖）。

## UIUE 隔离树（沿用）

- `/Users/wanglei/workspace/MAformac-uiue`（uiue/phase4，R7 显式 blocks `uiue_merge_to_mainline`）：主线只做 read-only 交叉检查；引用 UIUE file:line 前必 live 重确认。收口随 baseline-roadmap 节点 M4。

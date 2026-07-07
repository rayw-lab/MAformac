# Phase 1 STATUS-BOARD — 量尺/标签权威修复（D-107 第一执行单）

> 压缩恢复第一读。commander=%0（Opus4.8）@ ma-status-swarm。goal=推进 C5 闭环，计划=docs/baseline-roadmap-2026-07-05-c5-d106.md §5。

## 阶段定位
D-106 结论锚：qa 三轮 9/9/9=模型固有 actuation prior 硬墙。D-107：先做 Phase 1=让量尺(判断系统)先可靠→repo 可复跑 gate。**formal 1800 HOLD pending Phase 1-4。stoplines：不训练/不生成数据/不启动 formal/不 merge UIUE/不碰 Core/Training。**

## Swarm 拓扑（5 worker，2026-07-05 派发）
| pane | label | 职责 | SPEC |
|---|---|---|---|
| %8 | phase1-grill | Phase 1 gate 语义 grill 推进（消减机械门→锁定决策，LEIGE_KEY surface 不自拍） | grill/SPEC.md |
| %6 | phase1-eval | scanner 硬化门 + mount-validity 门→repo gate（4 分类+fail-closed+单测，9/9/9 回归锚） | eval/SPEC.md |
| %7 | phase1-data | label authority 9 冲突→裁决表 + 2 机械门 + 单测（现在音量→query_current_volume） | data/SPEC.md |
| %9 | phase1-redteam | 红队对抗审计（阶段1 premortem 先行；阶段2 对抗审 eval/data/grill 产出） | redteam/SPEC.md |
| %10 | phase1-secretary | 文档级联/记忆草稿（COMMANDER-INDEX 刷新/cascade inventory/MEMORY as-of/lessons，DRAFT） | secretary/SPEC.md |

## 依赖序
grill 定语义 ‖ eval/data 实装（R5 audit 已详可并行）→ redteam 阶段2 对抗审（eval/data/grill 出稿后 commander 通知）→ commander 收稿亲核 → 应用进 repo（commander 亲 git，避免 5-worker 单树冲突）。

## 待磊哥 LEIGE_KEY（不阻塞，收口前一次性问）
LABEL-AUTH-005/007/008：天窗/遮阳帘 default_scope canonical = no-arg vs position=全车（C1 两种都合法，口径型）。

## Phase 1 验收（baseline §5 Acceptance）
- scanner hardened rule 迁 repo gate（或明确 run-dir reusable script）
- label authority P0/P1 冲突有裁决表
- 「现在音量是多少」query authority ≠ absent-query 冲突（有测试）
- （default-scope current-head gate = W34，另账）

## 一手依据
- R5-SCANNER-HARDENED.md（9/9/9 + 4 分类）/ R5-LABEL-AUTHORITY-AUDIT.md（9 冲突归属矩阵）@ runs/2026-07-03-n2n4-train-readiness/
- decisions.md D-105/D-106/D-107 / baseline §5

## 进度日志
- 2026-07-05：D-107 落库 + doc patch（CURRENT/COMMANDER-INDEX/baseline git add，staged 未 commit）；5 worker 派发全 Working。

## 进度更新 2 (2026-07-05 14:3x)
- Phase1 门全交付+reconcile：repo scripts/{check,test}_{query_zero_tolerance,eval_mount_validity,label_authority_conflicts}.py + Makefile verify-c5-phase1-gates。commander 亲核 make verify-c5-phase1-gates RC=0 三门绿，9/9/9 保持，zero-coverage rc65。
- grill 5 议题 locked + phase4b 六子决策拆解 + phase2 弹药。磊哥拍 Phase4 D-085=B（D-108，formal 路径解锁）。
- 待：redteam 审 D(data)+E(phase4b)+F(reconcile repo 门) → D-109 → 磊哥 default_scope LEIGE_KEY → commit Phase1 → Launch Packet → 磊哥 recipe-key+run-auth → formal 1800。

## 进度更新 3 (2026-07-05 14:4x)
- D-109 落库：采纳 phase4b 六子决策 + Phase1 disposition（门 landing DONE / 数据清零未完，真 manifest rc2=conflict10+source_err31 必须 rc0）+ W34 amend。
- W34 amend 已写 baseline §5 item4 正文（W34→candidate-promotion gate，非 Phase1 completion）。
- redteam Round2 final：E pass-with-amends / F PASS / D AMBER（真 manifest 冲突未解）。verdict=AMBER_FORMAL_HOLD_UNTIL_D_MANIFEST_DISPOSITION。
- grill Launch Packet gap DRAFT 出：packet=PARTIAL_STATIC_ONLY（缺 D108/B 措辞、Phase1-clean data sha、host baseline、watchdog 部署、receipt schema）。
- 🔴 **卡点=磊哥 default_scope LEIGE_KEY(005/007/008) + 授权数据清零**。已上抛磊哥（⭐A no-arg）。
- 数据清零 dry-run plan 预备中（非 005/007/008 部分，等 key）。

## 🏁 Phase 1 收口 + 六部曲沉淀 (2026-07-05, 等 run-auth)
- ✅ Phase 1 CLEAN + surgical commit `6a4b6b82`（门 rc0 + 数据 rc0 + default_scope A + redteam GREEN）
- ✅ Launch Packet 六件冻结（eval/launchpacket-frozen/，绑 sha fa5690400f67/5653/commit 6a4b6b82，LR 450 fixture rc0）
- ✅ 六部曲沉淀：decisions D-107~110 / lessons M.28-30 / COMMANDER-INDEX 刷新 / CURRENT.md 刷新 / MEMORY as-of+压缩(13.3KB) / handoff `docs/handoffs/2026-07-05-phase1-clean-formal-ready.md`
- 🔴 六前置 ①-④ 全绿；⑤host baseline ⑥watchdog arm=起跑实时；**等磊哥 run-auth** → quiet workers + fresh host baseline(fail-closed) + arm watchdog真pid + 起 formal 1800 R3-QNEG-clean
- malformed bug 已升级 CC 2.1.201 断毒化

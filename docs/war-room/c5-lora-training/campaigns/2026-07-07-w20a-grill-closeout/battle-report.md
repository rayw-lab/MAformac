---
status: DRAFT_FOR_COMMANDER_REVIEW
artifact_kind: war_room_battle_report_draft_v2
authority: draft_not_committed_not_ssot
created_at: 2026-07-07T11:08:27+08:00
source_run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-07-w20a-grill-closeout
target_archive_hint: docs/war-room/c5-lora-training/campaigns/2026-07-07-w20a-grill-closeout/battle-report.md
proof_class: local_repo_truth + run_dir_receipts + targeted_local_evidence
---

# 2026-07-07 W20A grill closeout — War Room 战报 v2

> DRAFT：本稿供 commander 过审后落 `docs/war-room/`。项目活路由以 `/Users/wanglei/workspace/MAformac/docs/CURRENT.md` 为准；本稿只做本 run 战报与证据指针。

## 一句话结论

本轮把 D-111 honest-frozen-closeout 后的脏区、upstream/main 合流、W20A 双轮 grill、1800 口径、外审 MT 健康修复和终审问题收成可审计状态。closeout base 为 `ad9283cf`（main merge，历史记录 567/0 + make verify 绿），后续 MT commits 已到 latest `381ae735`，本地仍 `ahead 189`、push 443 哨兵在途。W21 终审 verdict 是 `CONDITIONAL_FAIL_CLOSEOUT`：P0=0/P1=1；MT dirty 前置已通过 commits 清理，但 latest probe 又出现 `docs/lessons-learned.md` dirty，仍需 clean/commit 后 fresh `make verify` 解除最终 closeout 绿灯。

## Repo / Commit 账

| 类别 | 结果 | 证据 |
|---|---|---|
| D-111 四组脏区 | done | `178da86d` docs；`ed69a935` W19B receipt；`72fd2ac0` W18/C5；`ed63180d` tooling/misc |
| upstream merge | done | `e87e2a00`，采用 merge 非 rebase，保留 D-064~D-111 sha basis |
| fixture drift 修正 | done | `ffd3ab89` 同步 RuntimePresentationPayload manifest 4 sha |
| main merge | done/historical green | `ad9283cf`，18 冲突解 + G7D 语义化；commit message 记录 `swift test 567/0` + `make verify` |
| 外审 MT commits | done | `ed3a5a96` MT2；`ab92bd8c` MT3；`e6738d6b` MT5；`0c8b0e69` MT1；`381ae735` MT2-FIX |
| current local | not pushed | `git status --short --branch` = branch ahead `189` + `M docs/lessons-learned.md` |

## W20A Grill 收口

R1 cross-review 收 14 consensus / 3 dispute；R2 双红队均 P0=0/P1=3，独立共振打中 catalog 混淆，最终 `R2-FINAL-DECISIONS.md` 落三修订：

1. **mounted catalog 与 562 分离**：`ir_map_fingerprint` 代表 562 recognizer universe；`mounted_demo_catalog_sha` 代表 W20A claimed runtime surface。mounted catalog 只取 direct-value AC 温度最小 surface，禁止 562 减法冒充 mounted runtime。
2. **receipt v2**：`runtime_adapter_mount_receipt.v2` 精确校验 schemaVersion；`runtime_target` 由 readback XCTest helper 从实际 destination 生成，v1 只作历史 evidence。
3. **直修 helper**：W20A P1-S2 内直接修 `decodeNonStreamingCompletion(allowedToolNames:)`，复用 `decode(_:)` guard；加 production static guard 与 unknown/by_exp/lock_ac 行为负例。

仍待磊哥拍：G1 iOS 门、G2 malformed/unsupported 兜底文案、G4 demo allow/avoid runbook、G5 axis-D 对外表达、G6 RT-6 accepted residual。R2 final 是 planning/governance，不是 run-auth 或实装授权。

## 1800 口径

W2 + W14 对抗审已 confirmed：

- `1800` 是 formal training iterations / iters，不是 1800 条样本。
- frozen `R3-QNEG-clean` trainpack = 5653 行，sha `fa5690400f67db9ef237dabdb489f58d1ab69961f14d6733d79f9bd7cad33823`。
- trainpack/Launch Packet 只到 ready-static；formal launch/completion 仍 not-ready：host HOLD、current run-auth 待磊哥、real watchdog/pid absent。
- formal 未来即使跑完，也不能自动产出 candidate signoff、C5 V-PASS、RuntimeQueryGuard 安全证明、mobile/true-device/live proof。

## 外审吸收 / MT 系列

| MT | 目的 | 状态 |
|---|---|---|
| MT1 | 去除 CI 仓外证据依赖 | done，`0c8b0e69`，repo-relative QA 9/9/9 evidence |
| MT2 | basis_id 装牙 | done，`ed3a5a96` + `381ae735` 修正 docs receipts 覆盖 |
| MT3 | 证据冻结入仓 | done，`ab92bd8c`，30 run 判定性小文件 + hash 清单 |
| MT4 | 三状态板收敛 | draft，`closeout/mt4-statusboard-convergence-draft.md` |
| MT5 | GitNexus MUST/NEVER 降级为 advisory | done，`e6738d6b` |
| MT6 | merge commit 可审计性复核 | W21 done，P1 fresh verify blocker |
| MT7 | 系统复盘素材 | in flight |

## W21 终审

`final-audit/report.md` verdict = `CONDITIONAL_FAIL_CLOSEOUT`，grade = `P1_BLOCKER`。

- P0=0。
- P1=1：不能把 “main merge 后 567/0 + make verify 绿” 签成当前最终 closeout green。W21 fresh `swift test` 通过 567/0，但 `make verify` 因当时 MT dirty diff gate 失败。
- 解除进展：MT1/MT2/MT3/MT5/MT2-FIX 已 commit。
- 仍待解除：处理 latest `docs/lessons-learned.md` dirty 后 fresh rerun `make verify`，并把 MASTER/PR/战报口径更新为 fresh evidence。

## Non-Claims

- Not W20A implementation; no run-auth yet.
- Not candidate signoff; candidate remains unsigned.
- Not C5 V-PASS / C6 acceptance.
- Not formal 1800 launched/completed.
- Not runtime/mobile/true-device/live_api proof.
- Not pushed / not PR opened without commander receipt.

## Source Pointers

- Run-local board: `STATUS-BOARD.md`
- Master board: `MASTER-STATUS.md`
- D-112 draft: `closeout/d112-draft-v2.md`
- R2 final: `grill-r1-synthesis/R2-FINAL-DECISIONS.md`
- W2/W14: `data-1800-check/report.md`, `adversarial-reviews/w2-review.md`
- W21: `final-audit/report.md`
- MT4 convergence: `closeout/mt4-statusboard-convergence-draft.md`

## 附：终审 P1 解除记录（commander 补，2026-07-07 11:13）
- MT/收口件全部 commit 后 worktree clean，fresh `make verify` exit=0 @ HEAD `ff219078`（11:13:16 CST）。
- W21-P1-01 解除条件（收口 dirty → fresh verify 无 diff gate failure）已满足；green 绑定本条时间与 HEAD，非沿用 merge 时点 stale green。

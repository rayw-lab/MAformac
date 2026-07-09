# Handoff 2026-07-09：session 收口 → ma10 交接（D-125~D-130）

> 上接 `2026-07-08-evening-d1a-coding-day.md`（D1a 编码日全账）。本篇=收口增量+ma10 起手。
> 基线：`opt/streamline-macos-20260707` @ D-130 commit，**ahead 35 未 push**，仓 clean。

## 收口终态（增量于前篇）

- **D1a 全链已集成**：T7 链（含 T2 七态债清偿/主文件接线/招牌①②组件/三档 motion budget/D0G-005 终序）收编，**全量 swift test 656/0 + verify-all rc0**（D-128/129）。五场对抗审 28 findings：P1 13/13 CLOSED（`findings-ledger-t-series.md`）。
- **S8 r3 从未点火**（24:00 键未落）。点火三件仍备：`s8-preflight-check.sh`（一键，全 PASS 输出 READY_TO_IGNITE）+ `s8-ignition-final-command.md`（分号 residual 已修的一行命令）+ RECERT sha `44dd5b08` 有效。
- holdout FROZEN（D-127）：sha `77853cae`，61 行 33/9/10/9，canonical=`s8-gates/s9-eval-freeze/holdout/`；S9 walkthrough 已演练（`s9-walkthrough-rehearsal.md`）。
- 🔴 **D-130 阵容新规**：ma10 worker=**hermes+codex only（禁 claude 系）**；生成器任务=hermes glm（生成方≠判方不变）；UIUE 视觉=commander 亲笔加重+codex 按参数级规格实装。

## ma10 起手 SOP

1. 读链：本文件 → CLAUDE.md §9 → MEMORY as-of → decisions D-125~130 → `daywork/COMMANDER-PARADIGM-CARD.md`（30min 范式回顾令仍有效）+ `REPORTS-INDEX-20260708.md`。
2. 建 ma10：commander %0 + 右列 codex×N + hermes（绕代理 env -u；**无 claude worker**）；逐 pane capture 亲核。
3. 派单前 pen-time readback；派单必带「必回写 REPORT 文件+pane 打印」双回写。

## 第一优先序

1. **S8 点火键**（磊哥窗口一句话；commander 先跑 preflight 脚本）→ 训后 S9 三臂（walkthrough 备）→ S9b → S10。
2. **C1 ballot**：`BATCH-C1-1-ballot.md` 38 题呈磊哥（P1 批 39 题已预渲染）→ 拍后消减表→实施计划→红队→编码（范式不跳步）。
3. **T7d 接缝 pass**（未执行）：EnergyLine 接 T5 真 readback 流+GeometryReader 坐标+hover 接 T4 契约+visual-swap feature flag——原派 Opus，按新规改 codex（参数级规格在 `t7-spec-ready.md`/RS-A/RS-B）。
4. T3 hero（macFeaturedContent，D0G-011）：commander 出规格+codex 实装。
5. 视觉验收链：app-run snapshot（idle 窗）→ commander 5 Gate 亲核 → visual-swap 切换验收 → 磊哥过目。🔴 T6a 三张截图飞书隐私污染，勿外发，idle 窗重拍后删。
6. lessons 落笔：`lessons-draft-20260708.md` 12 条候选待 commander 过一道进 `docs/lessons-learned.md`。

## Non-claims

S8 未点火未完成；S9/S10 未执行；C1 未拍；T7d/T3 未做；UIUE 未达 operator-pass；candidate unsigned；无 C5 V-PASS/C6/mobile/true-device。

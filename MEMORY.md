# MEMORY — MAformac

> memory sidecar only. This file is not OpenSpec SSOT, not a decision ledger, not a receipt, and not product/runtime proof. 与 live repo、OpenSpec、`docs/commander-log/decisions.md` 或 run-dir receipts 冲突时，本文件让位。

## as-of 2026-07-13 ma18（v3 更正：原 v2 写 07-12 滞后；KEY3 promote 实际 07-13，gauge 合批亦 07-13）

- ma18 已落：V8-RATIFY、KEY-PUSH@371f25fb、B1-VCI（G18-01A/02A strategy only）、W-P1 merge batch（integration local FINAL/PASS）、postmerge 三键（含 KEY3 promote）。B1 实现、W7/A5-020 coding、S8 token 仍另键。HY3 复盘采纳项已并入本批 docs：night2 N2-①…⑤ → lessons M.92–M.96；RETRO-ADOPTION-LEDGER #6/#7 ADOPT 并入（#1 gauge 实现、#3 P0 grill、#4 S8 预案、#5 preset 真空白在各线在产）。
- AMENDMENT-1 修正“A=dd65a6d3 rc0”假账：A detached=`BLOCKED rc70 [E_STALE_BASIS]`；rc0 属 B reanchor 后。AMENDMENT-2 补齐四键 join 并登记 W-P1 anchoring deviation；二者均不构成新授权。
- quiet budget 只消费 seconds：closure=`169.019486s`、total=`254.177395s`。pytest nodeids=`53`、源函数=`20`（16静态/4重段）、D-153契约面=`53` 是三套口径，禁混。
- ULTIMATE 首审=`DO_NOT_PUSH`；corrected terminal、page ref join、run selector 与 sentinel exact-pair 逐轮闭合，delta6=`CLEAR_FOR_KEYS`。该状态只表示 keys 前置可消费，不证明执行结果。
- postmerge 三键已 RATIFY：KEY1 disposable push DONE；KEY2 run `29197406884` exact headSha/event/top-level/job GREEN；KEY3 已执行 promote（mainline/opt=`70a2884e797bb3a35fc6ba912a6f7fa8fd027d87`，sentinel `PROMOTED` from=371f25fb→to=70a2884e），随后 gauge ff-merge 进 mainline（现 mainline/opt=`684746c7d80fd035b5408829ea7be16e770da1c8`），live git HEAD/@{u} 一致。
- trace gap exact paths：`runs/2026-07-12-ma18/reports/XAUDIT-CORNER-V2-DELTA-by-w3.md` sha=`a8e1220e...`；`XAUDIT-WP1V2-by-w3.md` sha=`970b0171...`；`XAUDIT-WP1V3-FINAL-SOL-by-w6.md` sha=`55bf0cd1...`；`XAUDIT-WP1V3-GROK-by-w1.md` sha=`cb083565...`；`ULTIMATE-PREPUSH-AUDIT-by-w5.md` sha=`cc2035af...`；`ULTIMATE-DELTA-6-by-w5.md` sha=`fcb94cf6...`。
- KEY-DOCS 的 ratify、执行、双门、commit/push 真态只读后生 receipt；本 as-of 不预填结果。KEY3 promote 已发生（sentinel `PROMOTED`，mainline=`70a2884e...`），但仍不证明 S8 ignition、operator-pass、V-PASS、C6 acceptance、candidate、mobile/true-device/live_api；`actionDemoProven=0/120`、`baseline_activation=PENDING_CASCADE` 不变。

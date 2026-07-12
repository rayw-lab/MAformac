## Context

W7 是 greenfield dialogue-state semantic consumption carrier，消费 W8 发布的 session、generation、terminal、checkpoint 与 recovery typed facts，只负责 DialogueState field effects。D-152 已拍 M16-001、M16-003、M16-004、M16-005、M16-006；W8 plan 与 commit b465514b 已先落 carrier，但 W7 不能因此拥有 W8 lifecycle。

当前需要一条 bounded、versioned、read-only 的语义消费边界，覆盖 turn-group/window、paired/unpaired、focus/readback 独立 validity、checkpoint restore/migration、focus expiry/revocation 与 active context/audit isolation。现有两个 gate 仍是 planned，不存在可直接执行的 target/checker/receipt。

约束：

- M16-003 保留 G3-090=C 的 schema direction；exact field spelling 只在 carrier key 冻结。
- bounded short-term context 不等于 long-lived memory。
- DemoRuntimeSessionRunner.run 是 CRITICAL 邻接面；本单不改代码，coding 前另签 risk-ack。
- W9 force visual state 不产生 W7 focus；W8 lifecycle owner、W9 write authority、V2 ceremony 与 V8 closure join 均为外部 owner。

## Goals / Non-Goals

Goals:

- 让 W8 typed lifecycle facts 经过一个 versioned effect boundary，单次消费并产生确定的 DialogueState effects。
- 让 window/group envelope 在 identity、version、disposition、validity 与 source reference 缺失或不支持时 fail closed。
- 将 paired/unpaired、focus validity、last-readback validity、checkpoint restore 与 focus expiry 分成独立可观察语义。
- 将 active context 与 terminal audit 隔离，禁止 audit 回灌 resolver。
- 为 source 与 consumption 两门保留完整 planned schema、proof ceiling 与 materialization stopline。

Non-Goals:

- 不实现 reducer、production consumer、checker、runner、Makefile target、negative suite 或 materialization receipt。
- 不创建第二生命周期 owner，不改变 W8/W9/W10/W5c/V2 契约，不解除 084/091 或推进 092/093。
- 不把 strict validate、plan、mock、unit、fake、profile 或 recipe 证据升级为 runtime proof。

## Decisions

### D1. W8 facts enter through one versioned effect boundary

选择一个 versioned W8-fact-to-W7-effect boundary，负责一次消费并映射 focus、last readback、active window、unpaired group、terminal audit 的 effects。W7 只拥有字段效果，不拥有 lifecycle identity、event ordering、terminal owner、generation fence、checkpoint timing 或 recovery state machine。

替代方案：在 DialogueState 或 Runner 内各自解释 W8 事件。拒绝原因：会产生不同的 event semantics 和第二 owner；无法证明同一 fact 只消费一次。

### D2. Window envelope is finite, typed, versioned and bounded

选择有限 disposition、identity、schema version、active/audit partition 与 bounded retention；unknown/missing identity、unknown disposition、unsupported version 都 fail closed。精确字段拼写在 K1 冻结，carrier 只锁行为。

替代方案：使用无 version 的 dictionary 或无限历史窗口。拒绝原因：无法处理 schema 漂移，也会把 short-term context 偷换成 long-lived memory。

### D3. Pairing and field validity are independent

选择 paired/unpaired reason 与 focus/readback validity 分别保存 reason、source group reference 与 version。数组长度不决定 round completeness，focus validity 不能推导 readback validity。

替代方案：从 user/assistant 数组配对或从 focus 状态推 readback。拒绝原因：连续 user、cancelled assistant 与异源 readback 会产生假配对或错误恢复。

### D4. Restore uses authoritative checkpoint and explicit migration

选择 display-only restore 不恢复 context；只有 approved authoritative checkpoint 且 identity、generation、digest、restore disposition 有效才恢复。legacy snapshot 走一次显式 migration，不能跨 session fence。

替代方案：把 UI text/cache 或 legacy 三条 message 当作 context authority。拒绝原因：显示状态不等于已批准 checkpoint，legacy pairing 也不保证完整 round。

### D5. Focus expires with owner window; force visual is not source

选择 focus 绑定 owner window 与 expiry/revocation reason；eviction、terminal clear、session clear、identity fence 触发矩阵定义的失效。force visual state 不创建或续期 focus，explicit injection 等待独立 owner/proof。

替代方案：只要 UI 卡片显示 active 就保持 focus，或允许任意 caller 注入 focus。拒绝原因：UI display 不是 context authority，任意 injection 缺少 source、expiry、receipt 与 negative proof。

### D6. Active context and terminal audit are separate

选择用 field-granular、versioned effect matrix 处理 clear/retain/audit-only，并用分离接口保持 terminal audit 不可读回 active resolver context。

替代方案：把 terminal audit 当作下一轮 active context。拒绝原因：cancel/terminal 记录会污染后续 context，导致 stale focus 与错误 readback。

### D7. Gates remain planned and claims remain capped

选择 source gate 与 consumption gate 均采用 PLANNED_GATE_NOT_YET_EXECUTABLE；每门需要 checker、exact suite、negative、official wiring、fresh rc0 与 materialization receipt，且 source gate 先于 consumption gate。两门都不能自动翻 registry availability、package state 或 proof claim。

替代方案：用 strict green、profile 或 fake integration 代替 gate materialization。拒绝原因：会把不存在的 execution surface 写成 green，并绕过 independent checker。

## Risks / Trade-offs

- [Risk] W7 自造 session/generation/terminal enum，和 W8 lifecycle 冲突。→ [Mitigation] R1 明确 W7 只消费 W8 facts，unknown/version mismatch fail closed；coding 前重跑 impact 与 risk-ack。
- [Risk] consecutive user 或 assistant cancellation 被数组长度误配为 paired。→ [Mitigation] paired/unpaired reason 独立记录，并加入 077/082 deliberate negatives。
- [Risk] UI restore 或 legacy snapshot 伪装成 authoritative context。→ [Mitigation] R4 要求 approved checkpoint、identity/generation/digest/restore disposition 与显式 migration。
- [Risk] W9 force visual state 续期 focus。→ [Mitigation] R5 明确 visual state 不是 focus source；explicit injection 另 owner/proof。
- [Risk] terminal audit 回灌 active context。→ [Mitigation] R6 分离 active/audit interface，并对 audit backfeed 做 negative。
- [Risk] planned gate 被误称 green，或手写 roster 与 registry 双账。→ [Mitigation] 两门完整 PHASED schema；future roster 由 registry + Makefile recipe 派生，当前保持 planned。
- [Risk] Runner.run CRITICAL blast 未获 fresh risk-ack。→ [Mitigation] P3 前签 RISK-ACK-W7，coding head fresh impact/detect_changes，超 symbols_allowed_final 停线重签。

Pre-Mortem failure modes and sources:

- 077/078/081/082/083 的 pairing、restore、focus expiry、cancel audit-only 与 clear matrix 失败模式来自 AMMO-EXACTNINE-5ATOMS-v2 与 W7 plan §3/§5/§7。
- source/consumption gate phantom surface、negative 缺失、roster 双账与 verify-ci presence exemption 来自 AMMO-8GATES-MATERIALIZATION-by-w1 §3–§4 与 XAUDIT-8GATES-AMMO-by-w5g。
- Runner.run CRITICAL、W20A receipt 连带与 scope expansion 来自 GITNEXUS-W7-W9-BLAST-MAP-by-w2g 与 RISKACK-PREFILL-W7-W9-by-w5g。

## Migration Plan

本单只执行 carrier propose writeback：

1. 创建 W7 proposal、design、dialogue-state-semantic-consumption spec、tasks 与 carrier metadata。
2. 运行 change strict 与 all strict；任何非零都 HOLD，不自创修复。
3. 写当日 pair receipt，记录 W7 plan pre-flip SHA、change 文件 SHA、HEAD、strict rc、执行者、时间与 conventions SHA。
4. pair receipt 完成后把 W7 plan 翻为 SUPERSEDED_BY_CARRIER，填 carrier_change_id、carrier_path、pair_receipt_path、plan_sha256_at_pair、superseded_at 与 authority_after_k1。
5. 创建 message 引用 KEY-RECEIPT-2 的本地 commit；不 push。

Rollback boundary:

- strict 红、pair 缺字段、plan/live 冲突或 scope 漂移时 HOLD；不自创删除 change 或回滚策略。
- 不触 W8 change、W9/V2 shared plan、registry、业务代码、remote ref 或 package state。
- apply、coding、merge、push 与 gate materialization 需另键。

## Open Questions

- K1 时 exact field spelling 与 schema direction 如何冻结，仍由 carrier key/异源审确定。
- source/consumption 两门的 exact checker、negative suite、Make wiring、materialization receipt 与 registry row 何时另键物化。
- P3 production consumer 的 RISK-ACK-W7 具体 symbols_allowed_final 与 W20A receipt 是否实际触及，需 coding head fresh probe 后决定。
- 未来是否需要 per-gate TRACKING rows；当前只引用现有 M16-001 umbrella rows，不虚构 dead reference。

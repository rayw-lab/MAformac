## Why

现有 DialogueState 尚无 D-152 已拍的 typed turn-group/window、独立 focus/readback validity、checkpoint/migration fence、owner-window focus expiry，以及对 W8 lifecycle facts 的有界 effect contract。W7 需要先冻结语义消费 carrier，后续实现与两门 materialization 才不会依赖 Runner 私有惯例或 prose 自证。

## What Changes

- 定义 versioned、bounded、read-only 的 DialogueState semantic envelope。
- 定义 finite paired/unpaired disposition，以及 focus 与 last-readback 各自独立的 validity provenance。
- 定义 approved authoritative checkpoint、display-only restore、legacy snapshot migration 与 session/generation mismatch fail-closed。
- 定义 focus owner-window expiry；force visual state 不创建或续期 focus；未来显式 focus injection 需要独立 owner/proof。
- 定义 W7 只消费 W8 typed lifecycle facts，通过 versioned effect mapping 更新 active context 与 terminal audit；W7 不拥有 lifecycle。
- 定义 active context 与 terminal audit 分离，terminal audit 不可回灌 resolver。
- 保持 bounded short-term context，不引入 long-lived、cross-session、cloud 或 device memory。
- 为 verify-dialogue-state-source 与 verify-dialogue-state-consumption 预留 materialization contract；当前两门保持 PLANNED_GATE_NOT_YET_EXECUTABLE。

## Capabilities

### New Capabilities

- dialogue-state-semantic-consumption：typed bounded dialogue window、W8 lifecycle fact consumption、read-only consumer envelope、checkpoint/migration 与 focus validity semantics。

### Modified Capabilities

- None。W8 lifecycle owner、W9 force-state authority、V2 ceremony 与 V8 closure join 不由本 change 修改。

## Impact

- 新增 OpenSpec carrier：openspec/changes/define-dialogue-state-semantic-consumption/。
- future type/schema slice：Core/State/DialogueState.swift；future production consumer slice：Core/Execution/DemoRuntimeSessionRunner.swift / DemoRuntimeSessionRunner.run。
- DemoRuntimeSessionRunner.run 属 CRITICAL 邻接面；进入 coding 前必须另签 exact RISK-ACK-W7 并 fresh 跑 GitNexus impact/detect_changes。
- W20ARuntimeReadbackReceiptWriter.run 只有实际触及时才扩签；本 carrier writeback 不触及这些代码。
- planned gates：verify-dialogue-state-source、verify-dialogue-state-consumption；当前均不可执行，不能宣称 gate green 或 W7 DONE。

## Non-goals

- 不定义或实现 W8 restart/cancel/timeout/new-session/session-generation/fence owner/state machine。
- 不以 force visual state、UI text/cache 或 terminal audit 创建或恢复 focus。
- 不实现 long-lived、跨 session、cloud 或 device memory。
- 不在 carrier writeback 中 apply、coding、merge、翻 registry state、生成 package exit proof 或执行两门 materialization。
- 不解除 G3-084/091 proof exclusion，不推进 092/093 named predecessors。
- 不把 carrier strict validate 写成 source/consumption gate green、implementation complete、W7 ready/DONE、operator-pass、V-PASS、mobile、true-device 或 live proof。

## Success Criteria

- openspec validate --strict 对本 change rc0，openspec validate --all --strict rc0。
- M16-001、M16-003、M16-004、M16-005、M16-006 与 077/078/081/082/083 corner 的 Requirement/Scenario trace 完整且无孤儿项。
- W8 owner boundary、W9 force boundary、bounded/no-long-memory 与 proof cap 均有明确 SHALL/SHALL NOT。
- source 与 consumption 两门保留完整 blocked predicate、unlock condition、tracking slot、evidence path、owner、SLA、claim ceiling 与 forbidden claims；不存在的 target/checker/receipt 不写 green。
- W7 carrier writeback 完成 pair receipt 与 plan SUPERSEDED_BY_CARRIER flip 后只做本地 commit；不 push、不 apply、不 coding。

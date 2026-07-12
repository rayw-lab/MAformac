## Context

W8 为 greenfield session-lifecycle carrier，承载 M16-007、M16-008、M16-009、M16-010a 与 M16-010b 的行为边界。当前缺少单一 lifecycle owner、typed child disposition、terminal/checkpoint/fence join、new generation 与 last reconciled stable recovery 的统一合同；若继续由多个路径各自维护状态，会产生第二真相、旧 generation stale mutation 与 pending-plan resume。

本单只做 OpenSpec propose 写回。SEQ-001=A 明确 W8 contract cut 不依赖 W5c DONE；W7 负责 DialogueState window/retention/clear policy，W9 负责 force/reset write store，W10 负责 TTS，W5c 负责 default backend/composition root，V2 负责 operator-pass。W8 只发布 lifecycle facts、identity、events 与 fence。

两个证据层级必须分离：

- 010a 是 deterministic interleaving profile，claim cap 为 profile_only / stress_profile_only。
- 010b 是 versioned real-process recipe，provenance 为 RECIPE-REAL-PROCESS-HARNESS，sha256=93c7623846cc7d407ec120ad926620d24f2bc1f5893b7dae2baca41c8ced20ed；在真实 process receipt 之前只能是 recipe_only。

## Goals / Non-Goals

Goals:

- 固定单 owner lifecycle state machine、transition、compound request ordering 与 immutable snapshot 行为。
- 固定 child disposition、cancel fan-out、ack 或 timeout+fence 后才能新 generation 的行为。
- 固定 last reconciled stable checkpoint recovery、terminal/checkpoint/child-fence join 与 pending-plan resume 禁止。
- 固定 old generation fence、stale mutation 诚实计数与 first-cause immutability。
- 固定 010a profile 与 010b proof_runtime recipe 的 claim ceiling，禁止相互抬升。
- 把 source gate 与 exit/runtime gate 保持为 planned、not-yet-executable，直到 checker、wiring、negative 与 materialization receipt 全部存在。

Non-Goals:

- 不实现 lifecycle coordinator、App seam、runtime runner、checker、Makefile target、gate materialization 或任何 Swift/Python 代码。
- 不改变 W7/W9/W10/W5c/V2 的 owner boundary，不改 registry 边，不引入第二 lifecycle owner。
- 不把 unit/mock/fake、010a profile、010b recipe、OpenSpec strict 或 planned gate 写成 proof_runtime、gate green、W8 DONE、operator-pass、V-PASS、mobile、true-device 或 live proof。
- 不做 apply、coding、merge、push、package state flip、V7/A5/S8 授权或状态翻转。

## Decisions

### D1. Single lifecycle owner and immutable publication

选择由 Core 单一 owner 维护 session identity、generation、transition、terminal outcome 与 immutable snapshot；其他路径只能提交事件或消费发布结果，不能成为第二 lifecycle authority。

替代方案：让 App、DialogueState 与执行层各自维护局部 lifecycle。拒绝原因：局部状态可互相覆盖，无法机械证明 single-owner、generation monotonicity 与 first-cause immutability。

### D2. Child settlement and fence before new generation

选择 closed child disposition 集合，至少包含 cancelled、terminal、unsupported、timedOutFenced。cancel 必须 fan-out 到注册 child；只有 child ack 或 timeout+fence 完成后，才允许 terminal join、recoveryReady 与新 generation。

替代方案：仅依赖取消信号或 Task.cancel-style hint。拒绝原因：取消信号不是 child settled，late callback 仍可能写入旧 generation。

### D3. Recovery source is last reconciled stable only

选择 recovery 只能读取 last reconciled stable checkpoint，并要求 terminal、checkpoint、child fence 三者 join；新 session 必须拥有新 generation，pending plan 不能作为 recovery source。

替代方案：从最后一个 pending plan 或最近一次 intent 恢复。拒绝原因：pending plan 可能没有 authoritative checkpoint，恢复后会把未完成意图伪装为稳定状态。

### D4. Evidence and claim separation

选择 010a 只生成 deterministic schedule、seed、ledger 与 profile digest；010b 只定义 future real-process recipe 及 provenance。两者都不能单独满足 proof_runtime，真实 process receipt 之前保持 recipe_only。

替代方案：用高数量 profile 或 fake child 替代真实 process。拒绝原因：profile 能验证调度形状但不能验证生产形态 join；fake child 不能证明真实 process cancel/fence/recovery。

### D5. Gate materialization remains planned

选择 source gate 与 exit/runtime gate 都采用 PLANNED_GATE_NOT_YET_EXECUTABLE，分别要求 checker、exact suite、negative、Make wiring、materialization receipt；exit 只允许进入 verify-wave2-runtime，不进入 source-free verify-ci。

替代方案：把 planned gate 写入 verify-ci 作为常绿门，或只以 OpenSpec strict 绿代替物化。拒绝原因：会把不存在的 checker/runner 伪写为当前能力，并污染 source-free CI 语义。

### D6. Dependency and test seam boundary

选择 010a 仅允许 test-only exact pins：swift-concurrency-extras 1.4.0 revision a90e2e40a7a840a853dd29e57cbef5dbb72c9d5b、swift-clocks 1.1.0 revision 72d749bf341b78851203066ab421869b783ec42a；swift-dependencies 为 N/A_protocol_FakeClock。主仓 coding 波才允许复现 Package.resolved，pin drift 另键停线。

替代方案：在 propose 阶段改主仓 Package.swift 或接受 UNPINNED。拒绝原因：本单无 coding 授权，且 unpinned dependency 会让 profile 结果不可复现。

## Risks / Trade-offs

- [Risk] 第二 lifecycle owner 重新出现，导致两个状态真相。→ [Mitigation] spec 明确 single owner、非 owner mutation fail-closed；future checker 与 deliberate negative 必须验证。
- [Risk] timeout/cancel 没有 ack 却进入 recoveryReady。→ [Mitigation] 要求 child ack 或 timeout+fence join，未完成时 recoveryReady denied。
- [Risk] old generation late callback 被错误应用。→ [Mitigation] new generation fence、stale applied 诚实计数、deliberate-red negative；不得硬编码零。
- [Risk] pending plan 被当作稳定 checkpoint。→ [Mitigation] recovery source 只允许 last reconciled stable checkpoint，pending-plan resume 明确禁止。
- [Risk] 010a profile 或 fake child 被包装为 proof_runtime。→ [Mitigation] profile_only、recipe_only、proof_runtime 三个 claim cap 分开，真实 process receipt 前不得升格。
- [Risk] planned gate 被写成当前 green，或 exit 混入 verify-ci。→ [Mitigation] 两门完整 blocked_predicate/unlock_condition/tracking_slot/evidence path，exit 仅挂 verify-wave2-runtime。
- [Risk] pin drift 或 transitively resolved dependency 漂移。→ [Mitigation] exact version/revision 与 Package.resolved 证据锁定，漂移必须另键 re-pin。

Pre-Mortem failure modes and sources:

- single-owner 负例、child fence、generation stale 与 pending-plan resume 负例来自本 W8 v3 carrier plan §2.2 canonical seed 与 §2.3 owner-boundary。
- source/exit gate 误 green、exit 误进 verify-ci、negative 与 materialization receipt 缺失来自 W8 plan §4–§5 与 AMMO-8GATES Gate 3/4。
- fake child 或 profile 被写成 runtime proof 的失败模式来自 W8 plan §6.1–§6.2 与 RECIPE-REAL-PROCESS-HARNESS 五章 provenance。
- dependency pin 漂移来自 W8 plan §6.1.1 的 exact pin / Package.resolved 约束。

## Migration Plan

本单只执行 propose writeback：

1. 将本 proposal、design、session-lifecycle spec、tasks 与 carrier metadata 落入 W8 change。
2. 展开 canonical requirements 与 scenarios，运行 change strict 与 all strict。
3. 写当日 pair receipt，记录 plan SHA、change 文件 SHA、repo HEAD、执行者、时间与 strict rc。
4. pair receipt 完成后，将 W8 plan frontmatter 翻为 SUPERSEDED_BY_CARRIER，并填 carrier_change_id、carrier_path、pair_receipt_path、plan_sha256_at_pair、superseded_at、authority_after_k1。
5. 用 KEY-RECEIPT-2 引用创建本地 commit；不 push。

Rollback / failure boundary:

- strict 红、pair 字段缺失或 plan flip 条件不满足时 HOLD，不自创删除 change 或回滚策略。
- 本单不触主线业务代码、既有 OpenSpec change、registry、remote ref 或 package state。
- apply/coding/merge/push 需另键。

## Open Questions

- coding 波如何把 source/exit 两门的 checker、negative suite、Make wiring 与 materialization writer 物化，属于后续另键。
- 010b real-process recipe v1 的具体 runtime harness、资源窗与 receipt schema，保持 future design，不在本单发明。
- 若未来全仓已采用 swift-dependencies，是否另键 amend test seam 与 pin，当前默认 N/A_protocol_FakeClock。

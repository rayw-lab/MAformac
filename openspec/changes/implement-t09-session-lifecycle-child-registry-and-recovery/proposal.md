# Change: implement-t09-session-lifecycle-child-registry-and-recovery

```text
change_id: implement-t09-session-lifecycle-child-registry-and-recovery
authority: V9-dispatch §4.B2 + cc-commander-mode §3.3
documentary_basis: define-t09-session-lifecycle-recovery (contract only; not coding authority)
implementation_predecessor: implement-t09-session-lifecycle-schema-core (K1 CREATED / frozen)
scope: W8 K2 child-registry + fence-join + recoveryReady + old-generation guard (CREATE-only path)
proof_ceiling: PARTIAL_PROFILE_ONLY_OR_RECIPE_ONLY (unit + deterministic interleaving profile; NEVER proof_runtime)
fork_basis_sha: 47547ad3cc1a89c6cb28728a146a7431406ff212
create_count_swift: 4 Core/Lifecycle + 4 Tests/W8K2 + 3 contracts/fixtures/w8-k2 = 11 files
modify_count_existing_k1_or_k3: 0
risk_ack_high_critical: NONE_EXACT (blast radius zero on K1 four files; K3 gate unaltered)
status: PRODUCER_ARTIFACT_PENDING_INDEPENDENT_REVIEW
```

## Why

W8 K1 已 CREATE 并 frozen（`Core/Lifecycle/SessionLifecycleTypes.swift`、`SessionLifecycleFacts.swift`、`SessionLifecycleCoordinator.swift`；`implement-t09-session-lifecycle-schema-core` K1_CLOSEOUT_PARTIAL_SCHEMA_ONLY），schema-core 只可执行 `ready→active`、`active→terminal`；`recoveryReady` 与 `newGeneration` 在 K1 均 reject with zero mutation。

`define-t09-session-lifecycle-recovery` SHALL 中的 **child disposition 闭集 (cancelled / terminal / unsupported / timedOutFenced)**、**cancel fan-out**、**ack 或 timeout+fence 后才允许新 generation**、**last reconciled stable checkpoint recovery**、**old-generation late callback 拒绝** 全部尚未有 CREATE-only 代码承载。K2 承担这一层：以 **CREATE-only 组合调用 K1** 的方式实现子会话注册表 + 取消扇出 + 栅栏合并 + 恢复协调 + 代际护栏，覆盖 F04（child register + cancel + timedOutFenced）、F05（fence 合并）、F06（recoveryReady + new generation）、F07（old-generation stale reject）、F08（deterministic interleaving profile）、F12（stable checkpoint vs pending plan）单元锚点。

W8 external owner 已冻结在 exact durable sha `47547ad3cc1a89c6cb28728a146a7431406ff212`（`chore(closure): reanchor W8 runtime-spine integration basis`，fresh 亲核 clean）；本 K2 producer 从该 sha fork-then-rebase 独立分叉执行，不进入 external owner worktree。

## What Changes

- 在既有 `session-lifecycle` capability 上**增加 K2 delivery contract**（不删除、不弱化 base 或 K1 delta 中任何 requirement）。
- 锁定 **isolation model = `actor`**：K2 组件（`SessionLifecycleChildRegistry`、`SessionLifecycleRecoveryCoordinator`）以 Swift `actor` 隔离，非 `@MainActor`；`nonisolated` actor context 允许 `TaskGroup` 用于 cancel fan-out 而不撞 issue #74759；K3 `@MainActor` 边界不被 K2 触碰。
- 锁定 **child disposition 闭集**：`SessionChildDisposition` = `{ pending, cancelled, terminal, unsupported, timedOutFenced }`；`pending` 是注册后初始态，其余四态为可见结算态；集合外分类拒绝。
- 锁定 **cancel fan-out 结算**：`cancelAll` 逐 child 记录 `pending → cancelled` 意图并等待 `ack(terminal|unsupported)` 或 `timedOutFenced`；receipt 结构含 `cancelledChildren` / `ackedChildren` / `timedOutFencedChildren` / `staleLateCallbacks`。
- 锁定 **fence-join gate**：`SessionFenceJoinOutcome` 三态 `{ allAcked, timedOutFenced, pending }`；`pending` 严格 fail-closed（不满足即拒 recoveryReady）；不使用 `unknown` 语义。
- 锁定 **recovery source = last reconciled stable checkpoint only**：`recordStableCheckpoint` 与 `recordPendingPlan` 分离；`requestRecovery` 仅当 `terminal + stableCheckpoint + fenceJoin.allAcked_or_timedOutFenced_after_deadline` 三条件同时满足才 grant new generation；未满足时按 `SessionRecoveryOutcome.denied*` 分类拒绝，不静默降级。
- 锁定 **old-generation guard**：`SessionLifecycleGenerationGuard` 在 `rotateGeneration` 后拒绝任何旧 generation 的 late callback / late terminal / late ack，计入 `staleLateCallbacks` 诚实累加（不硬编码零）。
- 锁定 **first-cause immutability 继承**：K2 组合 K1 时不覆盖 K1 已 settled 的 `firstTerminalDisposition` / `firstTerminalCause`；重复 terminal 按 `SessionLifecycleApplyStatus.duplicate` 观察。
- 锁定 **proof class**：`profile_only`（deterministic interleaving unit tests）或 `recipe_only`（fixture 参照 010b real-process recipe provenance）；**永不满足 `proof_runtime`**；`W8 DONE` / `operator-pass` / `V-PASS` / `C5 V-PASS` / `C6 acceptance` / `mobile` / `true-device` / `live proof` 均不由本单产生。
- 锁定 **P3/P4 wire GATED**：W7 DialogueState fact 消费面、K3 gate 扩展（terminal/recoveryReady 消费）在 tasks phase matrix 标注 `DEFERRED / GATED`，依赖 W7 DONE / K3 wire scope 扩权，本单不动。

## Capabilities

### New Capabilities

- None.（base `openspec/specs/session-lifecycle/spec.md` 已存在。）

### Modified Capabilities

- `session-lifecycle`：增加 **K2 delivery contract**——child registry `actor` 隔离 / closed disposition 集 / cancel fan-out + fence join / stable checkpoint vs pending plan 分离 / recoveryReady 三条件门 / new generation 单调分配 / old-generation stale reject / deterministic interleaving profile_only proof cap / K3 wire deferred。
  **SHALL NOT** 删除或弱化 base K3–K6 或 K1 delta 的任何 requirement；W7/W9/W10/W5c/V2 边界不被吞并；planned gates（`verify-session-lifecycle-source` / `verify-session-lifecycle`）保持 `PLANNED_GATE_NOT_YET_EXECUTABLE`；010b `RECIPE-REAL-PROCESS-HARNESS` provenance `sha256 93c7623846cc7d407ec120ad926620d24f2bc1f5893b7dae2baca41c8ced20ed` 保留未升格。

## Impact

- OpenSpec：仅本 change 树 `openspec/changes/implement-t09-session-lifecycle-child-registry-and-recovery/**`（proposal → design → delta spec → tasks）。
- Swift CREATE（**exact 4 Core/Lifecycle + 4 Tests + 3 contracts/fixtures/w8-k2**；**MODIFY none**）：

  | op | path |
  |---|---|
  | CREATE | `Core/Lifecycle/SessionLifecycleChildTypes.swift` |
  | CREATE | `Core/Lifecycle/SessionLifecycleCheckpoint.swift` |
  | CREATE | `Core/Lifecycle/SessionLifecycleChildRegistry.swift` |
  | CREATE | `Core/Lifecycle/SessionLifecycleRecoveryCoordinator.swift` |
  | CREATE | `Tests/MAformacCoreTests/W8K2/SessionLifecycleK2Fixtures.swift` |
  | CREATE | `Tests/MAformacCoreTests/W8K2/SessionLifecycleChildRegistryTests.swift` |
  | CREATE | `Tests/MAformacCoreTests/W8K2/SessionLifecycleRecoveryCoordinatorTests.swift` |
  | CREATE | `Tests/MAformacCoreTests/W8K2/SessionLifecycleGenerationFenceTests.swift` |
  | CREATE | `contracts/fixtures/w8-k2/child-disposition-closed-set.json` |
  | CREATE | `contracts/fixtures/w8-k2/recovery-three-gate-truth-table.json` |
  | CREATE | `contracts/fixtures/w8-k2/interleaving-profile-seed-A.json` |

- **Existing K1 / K3 four files MODIFY count = 0**：`SessionLifecycleTypes.swift` / `SessionLifecycleFacts.swift` / `SessionLifecycleCoordinator.swift` / `SessionLifecycleCompositionGate.swift` 一字未改；`App/FrontstageRuntimeComposition.swift` 未触；`Package.swift` / `Makefile` / `Tests/test_closure_work_packages.py` 未触。
- SwiftPM 自动包含 `Tests/MAformacCoreTests/W8K2/**` 与 `Core/Lifecycle/**` 新增 `.swift` 文件（`MAformacCore` target 用 `sources: ["Core", "Features"]` 递归 glob；`MAformacCoreTests` target 用 `path: "Tests/MAformacCoreTests"` 递归 glob）；无 Package.swift 改动。

## Non-goals

- 不实现或修改 K3 composition gate、W7 DialogueState policy、W9 force/reset write store、W10 TTS、W5c default backend/composition root、V2 operator-pass、registry 边、V7/A5/S8 授权。
- 不物化 planned gates（`verify-session-lifecycle-source` / `verify-session-lifecycle`）；不引入 verify-ci checker / Makefile target / GitNexus reindex 授权；不进入 verify-wave2-runtime。
- 不引入 010a 允许的 `swift-concurrency-extras` / `swift-clocks` 外部依赖 pin；K2 使用 protocol + `FakeClock` seam 内嵌于本 change 的 CREATE 文件；主仓 `Package.swift` 不动。
- 不做 `/opsx:apply`、真 process 承载、merge、push、V7/A5/S8 授权、包状态翻转、operator-pass 或 gate green 声称。
- 不允许 pending-plan resume；不允许 old-generation stale mutation 被 apply；不引入第二 lifecycle owner。
- 不产生 `proof_runtime` / `W8 DONE` / `operator-pass` / `V-PASS` / `mobile` / `true-device` / `live proof` 声称，即便所有 deterministic unit + profile 全绿。

## Success Criteria

- `openspec validate implement-t09-session-lifecycle-child-registry-and-recovery --strict` rc0。
- `openspec validate --all --strict` rc0（既有 changes 与 base spec 不受本单影响）。
- 4 Core/Lifecycle CREATE 文件 + 4 Tests CREATE 文件编译通过；`swift test --filter W8K2` rc0；deterministic negative（old-generation late callback / no-ack recoveryReady / pending-plan-only recovery）显式在 assertion 侧为 rejected 类而非 `.applied`。
- 3 contracts/fixtures/w8-k2 JSON 与 spec / test 引用一致（oracle 独立：test 期望值不从 K2 实现内部映射派生）。
- `git status --short` clean；`git diff --stat` 显示写面完全在允许 scope；未触任何 no-touch 文件；无二进制物；无 secrets。
- CLOSEOUT 明确 `proof_class ∈ { profile_only, recipe_only }`；未升格 `proof_runtime`；phase matrix 中 P3/P4 wire 明列 `DEFERRED / GATED / dependency`。

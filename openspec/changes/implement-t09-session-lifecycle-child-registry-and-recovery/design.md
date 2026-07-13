# Design: implement-t09-session-lifecycle-child-registry-and-recovery

## Context

W8 K1 已 CREATE frozen（`Core/Lifecycle/{SessionLifecycleTypes,SessionLifecycleFacts,SessionLifecycleCoordinator,SessionLifecycleCompositionGate}.swift`；四文件均以 `public` 结构暴露 K1 类型 + K3 gate；K1 `SessionLifecycleCoordinator` 为 `public final class`，`liveSessionID`/`liveGeneration` 为 init-time immutable `private let`）。

K2 需实现 `define-t09-session-lifecycle-recovery` SHALL 中的：
- 子会话注册表（child registry）与闭集 disposition `{ cancelled, terminal, unsupported, timedOutFenced }`
- 取消扇出（cancel fan-out）
- ack 或 timeout+fence 后的 fence-join gate
- last reconciled stable checkpoint 恢复源（禁止 pending plan resume）
- new generation 单调分配 + old-generation stale reject
- deterministic interleaving profile（010a claim cap = `profile_only`；010b `RECIPE-REAL-PROCESS-HARNESS` provenance `sha256 93c7623846cc7d407ec120ad926620d24f2bc1f5893b7dae2baca41c8ced20ed` = `recipe_only`）

CREATE-only 硬约束：**不 MODIFY** K1 四文件、K3 gate、`App/FrontstageRuntimeComposition.swift`、`Package.swift`、`Makefile`、shared closure checker/registry。K2 通过组合 K1 public API（`SessionLifecycleCoordinator.init(ownerAuthority:sessionID:generation:)` + `apply(_:authority:)` + `apply(batch:authority:)` + `snapshot`）实现自身逻辑；K1 内部符号 (`liveSessionID`/`liveGeneration`) 不需要被 K2 访问。

Fork basis：`47547ad3cc1a89c6cb28728a146a7431406ff212`（W8 external owner tip，fresh 亲核 clean）。本 producer 从该 sha 独立 fork 分叉 worktree `/private/tmp/MAformac-w8-k2-20260713`；不进入 external owner worktree。

## Goals / Non-Goals

Goals:

- 固定 K2 delivery 面：child registry actor / cancel fan-out receipt / fence-join outcome 三态 / recoveryReady 三条件门 / new-generation 单调分配 / old-generation stale reject / deterministic interleaving profile。
- 固定 isolation model = Swift `actor`（非 `@MainActor`）；配合 Swift 6.0 tools-version 与项目 concurrency 惯例。
- 固定 claim ceiling：`profile_only` / `recipe_only`；proof_runtime、W8 DONE、operator-pass、V-PASS、mobile、true-device、live proof 均不由本单产生。
- 固定 K3 wire、W7/W9/W10/W5c/V2 边界、planned gates 保持 DEFERRED / GATED。

Non-Goals:

- 不修改 K1 四文件或 K3 gate；不修改 `App/FrontstageRuntimeComposition.swift`、`Package.swift`、`Makefile`、`Tests/test_closure_work_packages.py`、shared closure checker/registry。
- 不物化 `verify-session-lifecycle-source` / `verify-session-lifecycle`；不引入 verify-ci checker、Makefile target、GitNexus reindex 授权；不进入 verify-wave2-runtime。
- 不引入 `swift-concurrency-extras` / `swift-clocks` 外部依赖 pin；K2 使用 protocol + `FakeClock` seam 内嵌 K2 CREATE 文件。
- 不做 apply、coding-of-other-lanes、merge、push、V7/A5/S8 授权、包状态翻转、operator-pass 或 gate green 声称。

## Decisions (Architecture)

### AD-K2-1. Isolation model = Swift `actor` (nonisolated context)

**选择**：K2 组件 (`SessionLifecycleChildRegistry`、`SessionLifecycleRecoveryCoordinator`、`SessionLifecycleGenerationGuard`) 以 Swift `actor` 声明；不加 `@MainActor`；不加 `@GlobalActor`；不做 `nonisolated(unsafe)` / `sending` 参数（Swift 6.0 tools-version 兼容）。

**理由**（三条压过替代方案）：

1. **并发面的确定性隔离**：child registry 与 cancel fan-out 天然多 child 并发面（cancel 广播 + child ack 可以来自不同 Task）。`actor` 提供内建 serial dispatch，不需要显式锁；每个 K2 组件的可变状态（`records: [SessionChildID: SessionChildRegistration]`、`staleLateCallbacks: UInt`、`currentGeneration: SessionGeneration`）在 actor 隔离内单线程访问。K1 `SessionLifecycleCoordinator` 由 K2 actor 独占持有，K1 的 `private var authoritative` 因 actor 边界的串行化天然安全。
2. **不撞 GlobalActor + TaskGroup 限制**（Swift issue #74759）：在 `@MainActor` 上下文启动 `TaskGroup` 会将子任务隐式 `@MainActor` 绑定，损失并行性并引入死锁风险。K2 用 nonisolated actor context 启动 cancel fan-out `TaskGroup`（若采用），子任务在 actor context 内独立并发，不撞该 issue。K3 `SessionLifecycleCompositionGate` 保留 `@MainActor`（K3 gate 是 App main-thread 消费面），K2 与 K3 在隔离面清晰分层。
3. **与 Swift 6.0 tools-version 一致**：`Package.swift:1` = `swift-tools-version: 6.0`（Read Package.swift line 1 实测）。K2 不使用 Swift 6.2 approachable-concurrency 默认语义（如 `nonisolated(unsafe)` 静态 let、参数级 `sending`）。所有传递跨 actor 边界的类型均 `Sendable`（K1 Types/Facts 已声明 `Sendable`；K2 新类型延续同一约定）。K2 API 表面使用 `async` 方法承担 actor `await`。

**替代方案 A：`@MainActor` 单类**：拒绝。cancel fan-out 会把广播序列化到 main queue，影响 K3 gate 与后续 UI 消费面；`TaskGroup` 撞 issue #74759；测试并发面被压平失去发现价值。

**替代方案 B：plain `final class` + explicit `NSLock` / `DispatchQueue`**：拒绝。Swift 6.0 strict concurrency 下 mutable state 通过锁需 `nonisolated(unsafe)` 或大量 `@unchecked Sendable` 逃逸口，等同放弃编译时数据竞争检测；K1 已示范 single-owner mutable `authoritative` 由 apply 调用者串行保证，K2 面对多 child 广播不能类比。

**替代方案 C：GlobalActor + 单例**：拒绝。全局单例引入跨会话状态共享，违反 K2「每 parent session 一实例」的语义。

### AD-K2-2. K2 组合 K1 而不 subclass、不修改、不 fork

**选择**：K2 `SessionLifecycleRecoveryCoordinator` actor 内部持有 `let coordinator: SessionLifecycleCoordinator`（K1 public final class）实例；所有 lifecycle 状态变更通过 `coordinator.apply(...)` 路由；K2 保存 `stableCheckpoint: SessionStableCheckpoint?` 与 `pendingPlan: SessionPendingPlan?` 作为恢复源分离账本。

**理由**：K1 `final class` 不可 subclass；K1 four files 严格 no-touch；组合模式让 K2 可以在不改 K1 的前提下扩展语义（child + recovery + guard），K1 first-cause immutability 由 K1 自身 `step(on:event:)` 的 `if snapshot.state == .terminal { return .duplicate }`（Read `SessionLifecycleCoordinator.swift:263-264` 实测）继续守护。

**验证锚点**：`git diff --stat Core/Lifecycle/` 收敛区间 = only 新文件 CREATE；不含四 K1/K3 文件的任何行改动。

### AD-K2-3. Fence-join outcome 三态 `{ allAcked, timedOutFenced, pending }` — 无 `unknown`

**选择**：`SessionFenceJoinOutcome` 严格三态，`pending` 是 fail-closed 默认（未满足 = 阻挡 recoveryReady），无 `unknown` / `degraded` / `partial` 之类模糊态。

**理由**：`define-t09/specs/session-lifecycle/spec.md:36-38`（Read 实测）：「the parent cannot claim all children settled before acknowledgement or timeout plus fence」。若引入 `unknown` 会让 recoveryReady 有静默降级路径（例如「未知 = 姑且允许」），与 SHALL 相悖。三态明确：`allAcked` 与 `timedOutFenced` 都允许进入 recoveryReady 条件评估（需要另两条件也满足），`pending` 硬阻挡。

### AD-K2-4. Recovery 三条件真值表（terminal ∧ stableCheckpoint ∧ fenceJoin）

**选择**：`requestRecovery(newGeneration:newSessionID:authority:)` 严格要求三条件同时满足；违反任一 → 返回具名拒绝分类：

| 未满足条件 | 返回值 |
|---|---|
| K1 snapshot 非 `terminal` | `.deniedTerminalIncomplete` |
| `stableCheckpoint` 为 nil（哪怕 pendingPlan 存在）| `.deniedCheckpointMissing` |
| pendingPlan 存在且 stableCheckpoint 为 nil | `.deniedPendingPlanOnly`（比 `.deniedCheckpointMissing` 更具名，防「静默把 pendingPlan 当 checkpoint」）|
| fenceJoin ∈ `{ .pending }` | `.deniedChildJoinIncomplete` |
| 非 owner authority | `.deniedAuthority` |
| newGeneration ≤ 当前 generation | `.deniedStaleGeneration` |

**理由**：`define-t09/specs/session-lifecycle/spec.md:60-62`（Read 实测）：「a pending plan exists without an approved authoritative stable checkpoint … refuses recoveryReady … does not apply the pending plan as recovered state」。具名拒绝分类让审计员能区分「三条件哪个不满足」，避免 default fallback 吞语义（`~/.claude/rules/derivation-layer-discipline.md 铁律 1`：default 不同时承载合法兜底与漏配吞错；本 change 用 explicit exhaustive switch 反射到 rejection 分类，不允许 `default: return .unknown`）。

### AD-K2-5. Old-generation guard 全放行 owner authority 前置 → 生成号大小前置

**选择**：`SessionLifecycleGenerationGuard` 的判定顺序 = 先 owner authority（`wrongAuthority` 优先）→ 再 `SessionGeneration` 单调（`.staleGeneration` 次之）→ 再 K1 内部 identity 判定（`crossSession` / `unknownGeneration` 由 K1 报出）。

**理由**：与 K1 `SessionLifecycleCoordinator.apply(_:authority:)` 的判定顺序对齐（Read `SessionLifecycleCoordinator.swift:50-66` 实测：先 `wrongAuthority` → 再事件种类 → 再 `identityRejection`）。K2 在自己的入口层加 generation guard，不改 K1 判定序，只在 K1 判定之前多一层。

### AD-K2-6. Deterministic clock seam = protocol + `FakeClock` inline

**选择**：K2 引入 protocol `SessionK2Clock { func now() -> UInt64 }`；生产实现 `SystemK2Clock` 使用 `DispatchTime.now().uptimeNanoseconds`；测试实现 `SessionK2FakeClock` 手动推进 tick。K2 fence deadline 判定以 `Clock.now()` 计算。

**拒绝 A：真时钟 + `Task.sleep`**：非确定性 → 破坏 `profile_only` 承诺（同 seed 不同耗时）。
**拒绝 B：引入 `swift-clocks` 外部依赖**：主仓 `Package.swift` no-touch；`swift-clocks` 的引入应走另一 change（与 010a 依赖治理绑定）。
**接受**：protocol + `FakeClock` 内嵌本 change CREATE 文件，无 Package.swift 改动，测试完全确定。

### AD-K2-7. Interleaving profile 的 ledger digest 从事件轨迹派生（oracle 独立性）

**选择**：`SessionLifecycleInterleavingProfile.ledgerDigest` 由测试端从 profile 事件序列（`register(a)`、`register(b)`、`cancelAll`、`ack(a, terminal)`、`fence(b)`、`rotate(N+1)`、`stale-late(b)`）计算 SHA-256 hex；测试期望值**独立硬编码**在 test source（不从 K2 实现的 `ledgerDigest` 属性回读做 self-referential assertion）。

**理由**：`~/.claude/rules/verification-economics-baseline-registry.md`「oracle 独立性」= 期望值禁止取自被测实现 authority/projection。ledger digest 若从 K2 impl 读回作为 assert 期望 = 自指 oracle（K2 impl 只要「自称一致」就双绿）。修法 = 测试内独立计算 digest 或硬编码字面值。K2 test 采用硬编码字面 hex 值 + 独立 SHA-256 verification 两路对拍。

### AD-K2-8. Claim ceiling 严格 profile_only / recipe_only — 硬编码到 CLOSEOUT + spec

**选择**：CLOSEOUT 与 spec 明文写 `proof_class ∈ { profile_only, recipe_only }`；即便所有 unit tests + profile + strict validate 全绿，禁写 `proof_runtime`、`W8 DONE`、`operator-pass`、`V-PASS`、`C5 V-PASS`、`C6 acceptance`、`mobile`、`true-device`、`live proof`。

**理由**：`~/.claude/rules/claim-vs-reality-gap.md` 铁律 2 + 第12变体（自跑测试绿 ≠ 语义正确；disaster-core 类需到消费/行为层）。K2 的 cancel fan-out 与 recoveryReady 属 lifecycle disaster-core；unit + profile 只能验 K2 层的 recipe 与 profile 正确性，不能证明真 process cancel/fence/recovery 的运行时语义。真 process 承载需 010b `RECIPE-REAL-PROCESS-HARNESS` 后续键，不由本单产生。

## Risks / Trade-offs

- **[Risk]** actor 隔离在 test 内使用 `async` 破坏部分同步测试模式。→ **[Mitigation]** 所有 K2 tests 使用 `func testXxx() async throws` XCTest 支持；同 K1 分离的 pure sync tests。
- **[Risk]** K2 组合 K1 时，K1 的 first-cause immutability 依赖 K1 内部 `step(on:event:)` 的 `snapshot.state == .terminal → .duplicate` 分支；若未来 K1 change 改此分支，K2 语义可能受影响。→ **[Mitigation]** K2 tests 独立覆盖「K2 route → K1 duplicate → K2 receipt duplicate」链路，K1 未来变更会直接触发 K2 test failure。
- **[Risk]** old-generation late callback 的 `staleLateCallbacks` 计数被误硬编码为 0。→ **[Mitigation]** deterministic negative 测试用「先 rotate → 再送 old-gen 事件 → assert 计数 == 1」明确断言；`~/.claude/rules/claim-vs-reality-gap.md` 第11变体所示的 dead-field 病由 counter 显式 assert 抵御。
- **[Risk]** fence-join outcome 被静默降级（如 `pending` 被误报为 `timedOutFenced`）。→ **[Mitigation]** `SessionFenceJoinOutcome` 用 exhaustive `switch` 判定；`~/.claude/rules/derivation-layer-discipline.md 铁律 1`（default 不同时承载兜底与吞错）本单严格遵守，未列 `default:` 兜底枝。
- **[Risk]** pendingPlan 被静默当 stableCheckpoint。→ **[Mitigation]** K2 保存两个独立 `Optional` 字段 + `.deniedPendingPlanOnly` / `.deniedCheckpointMissing` 分类拒绝；测试独立覆盖两种 denial。
- **[Risk]** 010a profile 被伪装为 proof_runtime。→ **[Mitigation]** spec + CLOSEOUT + fixture JSON 均硬编码 `"claim_class": "profile_only"`；rule 铁律 3 允许审计员对本 change 单文件 `grep proof_runtime` 应命中 0 声称位。
- **[Risk]** P3/P4 wire GATED 项被误标 completed。→ **[Mitigation]** tasks phase matrix 显式列 `DEFERRED / GATED / dependency`，未来 change 明确前置。

Pre-Mortem failure modes and sources:

- child registry / cancel fan-out / fence-join / recoveryReady / old-generation stale reject / pending plan resume 负例来自 `define-t09/specs/session-lifecycle/spec.md` M16-007/008/009 全量 scenarios。
- oracle 独立性负例来自 `~/.claude/rules/verification-economics-baseline-registry.md`「门形态三律」。
- 隔离模型选择的 GlobalActor+TaskGroup 病灶来自 Swift issue #74759（此为 producer 已知资讯，未在本 change context 内实测复现；GlobalActor 路径本单未采纳，规避即证否）。

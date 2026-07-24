# Change: implement-t09-session-lifecycle-schema-core

```text
change_id: implement-t09-session-lifecycle-schema-core
authority: W8-K0-HUMAN-AGREE-PACKET (strict K1 schema-only subset of P06)
documentary_basis: define-t09-session-lifecycle-recovery (contract only; not coding authority)
proof_ceiling: PARTIAL_SCHEMA_ONLY (even if unit tests green)
risk_ack_high_critical: NONE_EXACT / OPEN_INDEPENDENT
status: PRODUCER_ARTIFACT_PENDING_INDEPENDENT_REVIEW
```

## Why

`session-lifecycle` 的行为合同已在 base capability 与 documentary carrier `define-t09-session-lifecycle-recovery` 中落地，但仓库尚无 **Core 单一 owner** 的 schema-core 实现面：session/generation 值类型、可执行状态机（仅 `ready→active`、`active→terminal`）、fail-closed 规则与 F01/F02/F03/F09/F10/F11 单测锚点均未以 CREATE-only 代码存在。

W8-K0 已把 broad B3.K0/OpenSpec 权威**收窄**为 exact K1 schema-only。本 change 是该子集的 **implementation carrier（OpenSpec 层）**：先锁定交付合同与边界，再在 agree-before-build 门通过后才允许五文件 CREATE。本阶段**不写代码**。

## What Changes

- 在既有 `session-lifecycle` capability 上**增加 K1 schema-core delivery contract**（不删除、不弱化 base 中 K2–K6 全量 requirement）。
- 锁定 Core single owner：权威状态只在 Core lifecycle 面；非 owner 仅可提交事件或消费已发布 snapshot。
- 锁定 identity：session / generation 为值类型；unknown / cross-session / unknown generation → fail-closed，零部分突变。
- 锁定可执行转移：仅 `ready→active`、`active→terminal`；`terminal→recoveryReady`、`recoveryReady→active(new generation)` 可在 schema 中作为可观察态存在，**K1 不可执行**。
- 锁定 terminal：first cause 与 disposition 一旦 settled 不可变；duplicate terminal 仅 observed/rejected，不覆盖 first cause。
- 锁定 parent session vs child turn 语义分离；**K1 不注册 children**（无 child registry / cancel fan-out / fence join）。
- 锁定 F11：fact-schema only；refused/cancelled/unsupported/timeout/failure **不得**呈现为 accepted/success；UI 呈现 defer 至 K3+。
- 锁定未来 apply 面：CREATE exactly 5 文件，MODIFY **none**（见 Impact）。
- 锁定 claim ceiling：`PARTIAL_SCHEMA_ONLY`；K2–K6 deferred / not authorized。

## Capabilities

### New Capabilities

- None.（base `openspec/specs/session-lifecycle/spec.md` 已存在。）

### Modified Capabilities

- `session-lifecycle`：增加 **K1 schema-core delivery contract**——Core single owner；session/generation identity；可执行 `ready→active` 与 `active→terminal`；first cause immutable；fail-closed；parent session vs child turn 分离；F11 fact-schema only / UI deferred K3+；fixtures 子集 F01,F02,F03,F09,F10,F11。
  **SHALL NOT** 删除或弱化 base 中 child disposition、recoveryReady join、010a profile、010b recipe、planned gates、owner-boundary 等 K2–K6 全量 requirement；那些要求保持 documentary / deferred，本 change 只声明 **K1 不实现**。

## Impact

- OpenSpec：仅本 change 树 `openspec/changes/implement-t09-session-lifecycle-schema-core/**`（proposal → design → delta spec → tasks）；本 proposal 阶段不改 Swift/测试/Makefile。
- 未来 code（**仅在**独立 artifact 审 + `openspec validate --strict` 绿 + applyRequires ready + fresh rehash + 零既有 HIGH/CRITICAL 编辑之后）：

  | op | path |
  |---|---|
  | CREATE | `Core/Lifecycle/SessionLifecycleTypes.swift` |
  | CREATE | `Core/Lifecycle/SessionLifecycleFacts.swift` |
  | CREATE | `Core/Lifecycle/SessionLifecycleCoordinator.swift` |
  | CREATE | `Tests/MAformacCoreTests/SessionLifecycleFixtures.swift` |
  | CREATE | `Tests/MAformacCoreTests/SessionLifecycleCoordinatorTests.swift` |
  | MODIFY | **none** |

- NOT_TOUCH：一切既有 production 符号与文件（含 `DemoRuntimeSessionRunner`、`C3ExecutionPipeline`、`DemoSliceRoute`、`FrontstageRuntimeComposition`、`FrontstageVoiceSession`、`ContentView`）、`Makefile`、`Tools/checks/**`、recipe、`Package.swift`、xcodeproj、W7/W9/W10/W5c/V2 面、registry/git/PR/merge/push。
- 无 production-shaped seam；无 risk-ack 暗示；offline mock/demo-only，**非**真车控。

## Non-goals

- 不实现 / 不授权 K2–K6（child registry、cancel fan-out、fence join、recoveryReady 可执行转移、010a profile runner、010b real-process、source/exit checker、Makefile gate 物化）。
- 不 MODIFY 任何既有 production 文件；不创建 worktree；不 commit/push/PR/merge（除非后续另键）。
- 不改 W7 DialogueState policy、W9 force/reset write store、W10 TTS、W5c composition、V2 operator-pass。
- 不把 unit 绿、OpenSpec strict 绿、fixture 绿写成 proof_runtime、gate green、W8 DONE、operator-pass、V-PASS、mobile、true-device 或 live proof。
- 本 proposal 阶段**不写代码**；不自签 independent review CLEAR。

## Success Criteria

（硬门；可机械/命令验证，与下方非自动信号分离。）

1. `openspec validate implement-t09-session-lifecycle-schema-core --strict` rc0；项目要求的相关 `openspec validate --all --strict`（或等价全量）rc0。
2. 本 change 的 proposal / design / delta spec / tasks **经独立审**（producer ≠ auditor）；applyRequires 对 schema-only apply 为 ready 后，coding 才可启动。
3. 后续 apply：六 fixture F01/F02/F03/F09/F10/F11 单测路径 **RED→GREEN**；实现面仅 `ready→active` 与 `active→terminal` + fail-closed。
4. 最终 diff：**exactly five new files**，**zero MODIFY**；零既有 HIGH/CRITICAL 符号编辑；fresh rehash 确认 basis。
5. 终态 claim ceiling 恒为 **`PARTIAL_SCHEMA_ONLY`**；禁止 production/runtime/operator/V-PASS 声称。

## Non-automated Success Signals

（人工/产品可读信号；**不得**混入 hard gate，也**不得**单独升级 claim。）

- 审阅者能从 delta 一眼看出：base K2–K6 仍在、K1 只交付 schema-core 子集。
- 阅读 fixture 名与 expected 表即可复述 F01–F03/F09–F11 语义，无需运行时 App。
- 对外口头说明可用「Core 纯状态机骨架已有单测锚点」；**不可**说成「session recovery 已完成 / W8 DONE」。
- offline mock/demo 边界在文档中仍可读：演示向、非真车控。

## OpenSpec agree-before-build

1. 本 change 四件套（proposal/design/spec/tasks）独立审通过。
2. strict validate 绿。
3. tasks / applyRequires ready（schema-only）。
4. fresh repo rehash 确认 basis。
5. 计划 diff 无既有 HIGH/CRITICAL 编辑。

以上全部关闭前：**coding forbidden**。

---

```text
proposal_status: WRITTEN_PENDING_INDEPENDENT_REVIEW
self_signed_review_clear: false
touched_path: openspec/changes/implement-t09-session-lifecycle-schema-core/proposal.md
```

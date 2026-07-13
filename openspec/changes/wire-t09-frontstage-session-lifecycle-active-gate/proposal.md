# Change: wire-t09-frontstage-session-lifecycle-active-gate

```text
change_id: wire-t09-frontstage-session-lifecycle-active-gate
authority: W8-K3-HUMAN-AGREE-RISK-ACK-BINDING + user exact “我签字 我同意…” + CRITICAL risk-ack class 225/223
human_marker: HUMAN_AGREE|wire-t09-frontstage-session-lifecycle-active-gate|RISK_ACK_FRONTSTAGE_RUNTIME_COMPOSITION_CLASS_CRITICAL_225_223|W5C_OVERRIDE_LIFECYCLE_GATE_PROPERTY_AND_ROUTEDEMOSLICE_ACTIVE_GUARD_ONLY
packet_sha: 38d974643318d0bc2dad103016de536bc1b60c49eacf9339a82d8871d06ad9ea
claim_markers_sha: ab862712430f9da4f1e87cebef325b8696bae5c766d68e4e2d311da11a97076e
basis_head: f5c963fcb5d48a5d7c0ace67a423ac1a39517313
dependency_code: implement-t09-session-lifecycle-schema-core (K1 five-file PARTIAL_SCHEMA_ONLY)
dependency_doc: define-t09-session-lifecycle-recovery (documentary contract)
w5c_override: lifecycle_gate_property + routeDemoSlice_active_guard ONLY
risk_ack: FrontstageRuntimeComposition class CRITICAL impacted=225 direct=223; routeDemoSlice method LOW 3/1/process1 NOT substitute
status: PRODUCER_ARTIFACT_PENDING_INDEPENDENT_REVIEW
self_signed_review_clear: false
proof_ceiling_now: HOLD_FOR_OPENSPEC_REVIEW
proof_ceiling_conditional: DONE_LOCAL_PRODUCTION_SHAPED (only after independent controller review + strict + RED/GREEN + tests/build/deliberate-red/detect_changes + production consumer proof all pass)
producer: Grok managed job
independent_reviewer: Codex App controller (or designated non-producer)
```

## Why

K1（`implement-t09-session-lifecycle-schema-core`）已交付 **schema-core** coordinator（`PARTIAL_SCHEMA_ONLY`），但 **frontstage 生产路径**尚未在 `routeDemoSlice` 前 enforce parent-session **start→active**。

磊哥已对 packet 给出明确同意与 CRITICAL risk-ack（class 225/223），并窄 override W5c：仅允许 composition **lifecycle gate property** + **`routeDemoSlice` active guard**。本 change 是该生产门的 **OpenSpec carrier**；本阶段只锁定合同与边界，**不写 Swift**。

## What Changes

- 在 `session-lifecycle` capability 上 **ADDED** K3 production-shaped gate 合同：`SessionLifecycleCompositionGate` 私藏 owner + 单一 coordinator，绑定稳定 parent `sessionID` + **generation 0**；`ensureActive` fail-closed。
- App 面：`FrontstageRuntimeComposition` **lazy optional** 持有 gate；`routeDemoSlice` 在现有 current-turn precondition 之后、创建/调用现有 `DemoSliceRoute` **之前** 调用 `ensureActive`，并显式校验 returned snapshot。
- 钉死 **activation boundary**：accepted ingress + current turn 之后、**`DemoSliceAdmissionCatalog` 之前**；catalog rejection **不回滚** parent active；**不是** turn-as-session。
- 锁定 exact CREATE×2 + MODIFY×1；runner / pipeline / DemoSliceRoute 语义 / voice / ContentView / W7–W10 / V2 / Package / Make / xcodeproj / main / git ops **NOT_TOUCH**。
- K2 child fence/recovery、K4 profile、K5 gates、K6 real process **继续 deferred**。

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `session-lifecycle`：增加 **K3 frontstage parent-session active gate（production-shaped local subslice）**——composition gate、ensureActive 语义、consumer-before-route、activation boundary before catalog admission、exact scope / nonclaims / proof class。  
  **SHALL NOT** 删除或弱化 base / K1 / documentary 中 K2–K6 全量 requirement；那些保持 deferred。

## Impact

### OpenSpec（本波次唯一允许）

- `openspec/changes/wire-t09-frontstage-session-lifecycle-active-gate/**`  
  （proposal / design / specs/session-lifecycle/spec.md / tasks.md）

### 未来 code（**仅在** independent review CLEAR + `openspec validate --strict` 绿 + tasks 门闭合后）

| op | path |
|---|---|
| CREATE | `Core/Lifecycle/SessionLifecycleCompositionGate.swift` |
| CREATE | `Tests/MAformacCoreTests/SessionLifecycleCompositionGateTests.swift` |
| MODIFY | `App/FrontstageRuntimeComposition.swift` |

### NOT_TOUCH（硬）

- `Core/Execution/DemoRuntimeSessionRunner.swift` / `run`
- `Core/Execution/C3ExecutionPipeline.swift` / `execute`
- `Core/Execution/DemoSliceRoute.swift`
- `Core/Presentation/FrontstageVoiceSession.swift`
- `App/ContentView.swift`
- DialogueState* / W7、force/reset / W9、TTS / W10、V2
- `Package.swift`、`Makefile`、`Tools/checks/**`、`MAformac.xcodeproj`
- main repo；commit / merge / push / PR
- K1 five files（dependency，不修改）

### Production seam

| 角色 | 符号 |
|---|---|
| producer | `SessionLifecycleCompositionGate` / K1 `SessionLifecycleCoordinator` |
| consumer | `FrontstageRuntimeComposition.routeDemoSlice` |
| coverage | **仅** 该 frontstage path；**不** 声称所有 runner 调用全局门控 |

## Non-goals

- 不发布 parent terminal；不实现 recovery / newGeneration / child fence / cancel fan-out。
- 不把 turn / route invocation / payload terminal 当 parent session terminal。
- 不扩 W5c override；不碰 runner/pipeline CRITICAL 符号。
- 不自签 independent review CLEAR；不把 unit 绿写成 V-PASS / 真机 / operator-pass。
- 本 proposal **不写代码**。

## Success Criteria

1. 独立 controller 审本 change 四件套 → P0/P1 = 0；`openspec validate wire-t09-frontstage-session-lifecycle-active-gate --strict` 与相关 all-strict rc0。
2. 后续 apply：RED→GREEN 覆盖 first activation / idempotence / cross-session 零突变 / consumer-before-route / activation boundary / 无 turn-terminal conflation。
3. 最终 diff ⊆ exact CREATE×2 + MODIFY×1；`detect_changes` 无 NOT_TOUCH 泄漏。
4. full `swift test` + 双 scheme 本地 App build + deliberate-red 有牙。
5. 证明上限：条件全过才可 `DONE_LOCAL_PRODUCTION_SHAPED`；当前文档态 = `HOLD_FOR_OPENSPEC_REVIEW` / `PRODUCER_ARTIFACT_PENDING_INDEPENDENT_REVIEW`。

## Non-automated Success Signals

- 审阅者一眼看出：parent active 在 catalog 前；catalog 拒不回滚 active；App 永不持有 owner token。

---

**Producer artifact pending independent review — 不得自签 agreed / CLEAR。**

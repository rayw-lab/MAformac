# Design: wire-t09-frontstage-session-lifecycle-active-gate (K3 production active gate)

```text
change_id: wire-t09-frontstage-session-lifecycle-active-gate
authority: W8-K3-HUMAN-AGREE-RISK-ACK-BINDING
basis_head: f5c963fcb5d48a5d7c0ace67a423ac1a39517313
dependency: implement-t09-session-lifecycle-schema-core (K1 five-file) + define-t09-session-lifecycle-recovery (documentary)
status: PRODUCER_ARTIFACT_PENDING_INDEPENDENT_REVIEW
self_signed_review_clear: false
proof_ceiling_now: HOLD_FOR_OPENSPEC_REVIEW
proof_ceiling_conditional: DONE_LOCAL_PRODUCTION_SHAPED
controller_review_in: CLEAR_TO_AUTHOR_OPENSPEC; P0=0 P1=0 P2=1 P3=0
p2_routed: activation boundary before DemoSliceAdmissionCatalog; catalog rejection does not roll back parent active
```

## Context

| 层 | 状态 |
|---|---|
| documentary T09 | `define-t09-session-lifecycle-recovery` 已锁全量合同（含 K2–K6） |
| K1 schema-core | five-file CREATE 已关 `PARTIAL_SCHEMA_ONLY`；coordinator 可执行 `ready→active` / `active→terminal` |
| K3 本 change | **仅** frontstage parent-session **start→active** 生产门；composition 接线 |

现网 `App/FrontstageRuntimeComposition.swift`：`routeDemoSlice` 在 `precondition(isCurrentTurn(turn))` 后直接懒建 `DemoSliceRoute` 并 `route`——**无** parent lifecycle active 门。

磊哥已 HUMAN_AGREE + CRITICAL risk-ack（class 225/223）+ W5c 窄 override（property + `routeDemoSlice` guard only）。

### Controller P2（必须进本 design / delta spec）

**Activation boundary：**  
`FrontstageCustomerIngress` accepted + current turn 之后 → 进入 `routeDemoSlice` 时 **先** ensure parent **active** → **然后** 才可到 `DemoSliceAdmissionCatalog` / route。  
catalog rejection **不** 回滚 parent active。  
**不是** turn-as-session。

---

## Goals / Non-Goals

### Goals

1. 新 public `@MainActor final class SessionLifecycleCompositionGate`：私藏 `ownerAuthority` + 单一 `SessionLifecycleCoordinator`；绑定稳定 parent `SessionID` + **generation 0**；App **永不**拿到 owner token。
2. `ensureActive(expectedSessionID:)`：identity 先检 → ready 只 `start` 一次 → active 幂等 → 非 active fail-closed；返回 immutable `SessionLifecycleSnapshot`。
3. `FrontstageRuntimeComposition`：一个 **lazy optional private** property（默认 `nil`，**不改** `init` 字节意图）；`routeDemoSlice` 在 current-turn 之后、现有 route 之前 ensureActive + 显式 guard snapshot。
4. 钉死 activation boundary（P2）与 production seam 覆盖面。
5. exact scope enforce；证明上限条件化。

### Non-Goals

- 不发布 terminal API；不 payload-terminal 映射；不 recovery / newGeneration / child / fence。
- 不改 runner / pipeline / `DemoSliceRoute` 语义 / voice / ContentView。
- 不全局门控所有 runner 调用。
- 不自签 CLEAR；不夸大 V-PASS。

---

## Decisions

### D1. Gate 类型与封装

**选择：** `public @MainActor final class SessionLifecycleCompositionGate`，位于 `Core/Lifecycle/`。

- `private` owner authority + `private` coordinator  
- bound `SessionID` + generation **0** at construction  
- App 只持有 gate 引用；**永不**暴露 token  

**可选：** public **read-only** snapshot accessor（测试 / consumer 只读），不得突变。

**拒绝：** 全局单例；把 coordinator 直接塞进 App；App 持有 owner token。

### D2. `ensureActive(expectedSessionID:)` 语义

| 步骤 | 规则 |
|---|---|
| 1 | identity mismatch：**先于** apply 检查 → typed throw；snapshot 保持 **ready rev0**（零突变） |
| 2 | **ready** | 只 `apply .start` 一次；仅当 status `.applied` **且** 结果 state==active **且** identity/generation 匹配 → 返回 immutable snapshot；否则 typed fail-closed |
| 3 | **active** 且同 identity | 返回 **现有** snapshot；**revision 不增**（幂等） |
| 4 | terminal / recoveryReady / 其他非 active | fail-closed；K3 **无** terminal API |

返回类型：immutable `SessionLifecycleSnapshot`；错误：typed（K1 / 本 gate 封闭错误面）。

### D3. App composition 最小修改

**选择：** 在 `FrontstageRuntimeComposition` 增加：

```text
private var sessionLifecycleGate: SessionLifecycleCompositionGate?  // lazy; default nil
```

- **不改** `init(session:)` 主体赋值语义（init 仍只设 session + customerIngress）  
- `routeDemoSlice`：
  1. 保留 `precondition(isCurrentTurn(turn))`
  2. 若 gate == nil → 以 `session.sessionID` + generation 0 懒建
  3. `try ensureActive(expectedSessionID: turn.sessionID)`（或等价 SessionID 绑定）
  4. **显式** guard：returned snapshot.sessionID == turn.sessionID **且** state == active
  5. **然后** 才懒建/调用现有 `DemoSliceRoute`
- gate 失败 → throw 经现有 ContentView catch 上浮；**不**改 ContentView

### D4. Activation boundary（P2 落点）

```text
ingress accepted → markCurrent / current turn
    → routeDemoSlice
        → ensureActive (parent start→active)     // BOUNDARY: before catalog
        → DemoSliceAdmissionCatalog / DemoSliceRoute.route
```

- catalog **rejection** → parent 可保持 **active**；**不** 回滚  
- turn 结束 / payload terminal **≠** parent terminal（K3 不推进 parent terminal）

### D5. Production seam 与证明面

| 项 | 值 |
|---|---|
| producer | gate + K1 coordinator |
| consumer | `FrontstageRuntimeComposition.routeDemoSlice` |
| coverage | **仅** frontstage 该 path |
| nonclaim | 不声称 runner/pipeline 全局门控 |

### D6. Risk / W5c

- class CRITICAL 225/223 **已** human risk-ack（binding）  
- method LOW 3/1/process1 **不可**替代 class ack  
- W5c override **仅** property + routeDemoSlice guard  
- 编码前仍须 **fresh** GitNexus impact on live basis + 编码后 `detect_changes`

### D7. 测试策略

唯一新测文件：`SessionLifecycleCompositionGateTests.swift`

- unit：first active / idempotent / cross-session zero mutation / non-active fail-closed  
- **source-contract**：读 `App/FrontstageRuntimeComposition.swift` 源，证明  
  - 持有 gate property  
  - `ensureActive` / active guard **出现在** `DemoSliceRoute(` 创建/调用之前  
  - 无 runner/pipeline/ContentView 接线字符串  

---

## Exact scope

### CREATE

1. `Core/Lifecycle/SessionLifecycleCompositionGate.swift`
2. `Tests/MAformacCoreTests/SessionLifecycleCompositionGateTests.swift`

### MODIFY

1. `App/FrontstageRuntimeComposition.swift`

### NOT_TOUCH

见 proposal Impact NOT_TOUCH 表（全文照搬 binding）。

### Dependencies（不修改）

K1：

- `Core/Lifecycle/SessionLifecycleTypes.swift`
- `Core/Lifecycle/SessionLifecycleFacts.swift`
- `Core/Lifecycle/SessionLifecycleCoordinator.swift`
- `Tests/MAformacCoreTests/SessionLifecycleFixtures.swift`
- `Tests/MAformacCoreTests/SessionLifecycleCoordinatorTests.swift`

---

## Risks

| 风险 | 缓解 |
|---|---|
| catalog 拒后 parent 仍 active 被误读为“会话脏” | 产品/合同明确：active 表示 parent 已 start，**非** demo 已录取；P2 钉死 |
| 把 turn 当 session | delta spec + 测试禁 turn conflation |
| 扩大 composition 改动 | exact scope + detect_changes + deliberate-red |
| class CRITICAL 假绿 | 已 risk-ack；fresh impact + independent verifier |

---

## Proof class

| 当前 | 条件化上限 |
|---|---|
| `HOLD_FOR_OPENSPEC_REVIEW` | `DONE_LOCAL_PRODUCTION_SHAPED` |
| proof ⊆ local / unit / local-build | **仍不是** runtime / operator / mobile / true-device / V-PASS |

条件：carrier 独审 + strict + RED/GREEN + full tests + 双 xcodebuild + deliberate-red + detect_changes + production consumer proof。

---

**Producer artifact pending independent review — 不得自签 agreed / CLEAR。**

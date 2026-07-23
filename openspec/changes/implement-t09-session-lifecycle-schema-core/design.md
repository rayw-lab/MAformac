# Design: implement-t09-session-lifecycle-schema-core (K1 schema-core)

```text
change_id: implement-t09-session-lifecycle-schema-core
authority: W8-K0-HUMAN-AGREE-PACKET (B2 exact K1 schema-only bind)
documentary_basis: define-t09-session-lifecycle-recovery (contract only; not coding authority)
proof_ceiling: PARTIAL_SCHEMA_ONLY
status: REVISION_1_PENDING_FOCUSED_RECHECK
self_signed_review_clear: false
captured_at: 2026-07-13
revision: REVISION_1
```

## Context

`session-lifecycle` 行为合同已在 base capability（`openspec/specs/session-lifecycle/spec.md`）与 documentary carrier `define-t09-session-lifecycle-recovery` 落地，但仓库尚无 **K1 schema-core 实现面**：session/generation 值类型、单一 owner 可执行状态机（仅 `ready→active`、`active→terminal`）、fail-closed 规则，以及 fixture **F01 / F02 / F03 / F09 / F10 / F11** 的单测锚点均未以 CREATE-only 代码存在。

W8-K0 HUMAN_AGREE packet（B2）已把 broad B3.K0/OpenSpec 权威**收窄**为 exact K1 schema-only 子集。本 design 锁定该子集的实现决策与边界，供独立审与后续 apply；**本阶段不写生产代码**。

### 主链路与接线边界（硬）

| 声明 | 本 K1 |
|---|---|
| 生产接线（runner / pipeline / UI / voice / composition） | **无** — K1 不改既有生产符号，不创建 production-shaped seam |
| 安全 / 生命周期状态机 | **代码 enforce**，不是 prompt 声明 |
| child registry / cancel fan-out / fence join / recoveryReady 可执行 / 010a / 010b / gate 物化 | **K2–K6 deferred**，本 design 不授权 |
| 证据上限 | 恒 **`PARTIAL_SCHEMA_ONLY`**（即便未来 unit 绿） |

### 本地工程锚点（pre-mortem 一手）

| 锚点 | path:line | 对 K1 的含义 |
|---|---|---|
| SwiftPM 源/测目录 | `Package.swift:46-54` | `sources: ["Core","Features"]` + `Tests/MAformacCoreTests`；新 `Core/Lifecycle/*` 与测文件**自动加入**现有 target，**不改** `Package.swift` |
| 值类型 + Sendable 先例 | `Core/Contracts/DemoAuthorityIdentity.swift:3-10` | public value type + `Equatable` + `Sendable` 模式可对齐 identity/event/fact/snapshot |
| 封装 mutating 先例 | `Core/State/DialogueState.swift:18-61` | `private(set)` + controlled mutating；K1 owner 用 **single final class + 内部状态**，非全局单例 |
| MainActor store（**仅对照，不采用**） | `Core/State/DemoVehicleStateStore.swift:94-101` | `@MainActor` store 是 UI/状态卡模式；K1 **不**绑定 MainActor，并发包装 defer K3 |
| 注入 clock + **NOT_TOUCH** | `Core/Execution/DemoRuntimeSessionRunner.swift:7-39` | 生产 runner 有 `timestampProvider`；K1 **禁止**编辑此文件；K1 **prefer 无 wall-clock** |
| 错误分类 enum 先例 | `Core/Presentation/DemoRuntimeResultPresentationMatrix.swift:3-12,23-29` | 封闭错误类、无 `default:` 吞漏配；F11 借鉴 **fact-class 分类**，但不 import UI / 不绑 presentation matrix |
| 穷尽 / 错误单测先例 | `Tests/.../DemoRuntimeResultPresentationMatrixTests.swift:8-18,52-87,100-101` | XCTest 穷尽枚举 + 错误非成功映射 + 源码禁 `default:`；K1 测法对齐：per-test 新 owner、不可变 fixture |

### 官方一手 sources（captured_at=2026-07-13）

| 主题 | URL | 用于 |
|---|---|---|
| Swift 并发模型 | https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/ | D1：K1 不跨并发域；不做内部 `Task`/actor；Sendable 值类型 |
| Swift 5.10 data-race 默认严格 | https://swift.org/blog/swift-5.10-released/ | D1：值类型 + 单 owner 同步面，降低未审查跨 actor 突变 |
| XCTest → Swift Testing 迁移 | https://developer.apple.com/documentation/testing/migratingfromxctest | D9：K1 **仍用 XCTest**（与现有 Core tests 一致）；不强制 Swift Testing |
| WWDC24 testing | https://developer.apple.com/videos/play/wwdc2024/10195/ | D9：测试隔离、确定性 fixture 纪律 |

---

## Goals / Non-Goals

### Goals

1. 锁定 K1 **schema-core** 交付合同：单一 owner 权威状态；session/generation 值类型 identity；可观察态含 `ready` / `active` / `terminal` / `recoveryReady`；**可执行转移仅** `ready→active` 与 `active→terminal`。
2. 锁定 fail-closed：非 owner 权威突变拒绝；非法转移零突变；unknown / cross-session / unknown generation 零部分突变；first terminal cause + disposition 一次写入不可变；duplicate terminal 仅 observed/rejected。
3. 锁定 compound batch：固定总序 **start 先于 terminal/cancel**；整批校验后原子应用；只发布**一个**最终不可变 outcome/snapshot；与输入序/墙钟无关。
4. 锁定 parent **session** 与 child **turn** 语义分离；K1 **不**注册 children（无 child registry / cancel fan-out / fence join）。
5. 锁定 F11：fact-schema 显式错误类；错误/拒绝/取消/不支持/超时 **永不**升格为 accepted/success fact；UI 渲染 defer K3+。
6. 锁定未来 apply  diff 形状：exactly **five CREATE** paths，**MODIFY none**；证明上限 `PARTIAL_SCHEMA_ONLY`。
7. 锁定单测：XCTest；F01/F02/F03/F09/F10/F11 **RED→GREEN**；每测新 owner、不可变 fixture、无共享静态可变状态。

### Non-Goals

- 不实现 / 不授权 K2–K6（child registry、cancel fan-out、timeout+fence join、recoveryReady 可执行、new generation 分配、010a profile runner、010b real-process、source/exit checker、Makefile gate）。
- 不 MODIFY 任何既有 production 文件；不碰 `DemoRuntimeSessionRunner`、`C3ExecutionPipeline`、`DemoSliceRoute`、`FrontstageRuntimeComposition`、`FrontstageVoiceSession`、`ContentView`、`Package.swift`、xcodeproj、Makefile、`Tools/checks/**`、W7/W9/W10/W5c/V2。
- 不引入 `swift-dependencies`、全局 lifecycle 单例、内部 `Task`/`actor` 并发 owner、必需 wall-clock / ledger / event stream。
- 不把 unit 绿、OpenSpec strict 绿、fixture 绿写成 proof_runtime、gate green、W8 DONE、operator-pass、V-PASS、mobile、true-device 或 live proof。
- 本 design **不自签** independent review CLEAR。

---

## Decisions

### D1. Synchronous final-class single owner；值类型 Sendable；无内部并发

**选择：** 未来实现中，lifecycle 权威 owner 为 **同步 `final class`、单一实例生命周期内唯一 owner**，**无**内部 `Task`、**无** `actor`、**无**全局单例。Identity / state / event / fact / snapshot / result 等值类型在适用处符合 `Sendable` / `Equatable`。K1 **不跨并发域**；actor / `@MainActor` 包装由 **K3** 另键决定。

**Rationale：** 安全状态机必须是可测、可证明的代码路径；并发包装会把「状态机正确」与「线程/actor 正确」耦合成不可分证明，并诱使编辑生产 runner（`DemoRuntimeSessionRunner.swift:7-39` 已是 `@MainActor` + 注入 clock）。Swift 并发文档与 5.10 严格 data-race 默认要求：跨并发域前先冻结纯同步语义。

**Alternatives：**

| 方案 | 拒绝原因 |
|---|---|
| `@MainActor` store 对齐 `DemoVehicleStateStore` | 过早绑 UI 线程；K1 无生产接线 |
| `actor` owner | 跨 isolation 测试与调用面复杂；K3 再决 |
| 全局 `shared` 单例 | 第二真相 + 测试污染 |
| 纯 struct + 外部可变引用 | 易出现多引用写，破坏 single owner |

### D2. Owner-bound apply；错误 authority 零突变

**选择：** apply API 显式携带 **owner authority identity**。错误 authority 的 apply 请求 **fail-closed**，**零** lifecycle 突变；generation 与已发布 snapshot 不变。非 owner 可 **构造/提交 event 值**，但 **不能** 执行权威突变。

**Rationale：** base requirement「Single-owner session lifecycle state」+ B2 F01。对齐「非 owner 提交事件、owner 发布 immutable fact」的 documentary 合同。

**Alternatives：** 信任调用方（拒绝：无 enforce）；用文件/模块可见性代替 identity（拒绝：同模块测试可绕过语义）。

### D3. 可观察四态；可执行仅 ready→active 与 active→terminal

**选择：**

| 可观察态 | K1 可执行进入？ |
|---|---|
| `ready` | 初始/构造态 |
| `active` | 仅从 `ready` |
| `terminal` | 仅从 `active` |
| `recoveryReady` | **否** — 可出现在契约/类型枚举中，但任何进入 `recoveryReady` 或自 `recoveryReady`/`terminal` 开新 generation 的请求 **拒绝 + 零突变** |

**Rationale：** B2 §4.2 与 proposal 锁定的 K1 子集；recovery 全链路属 K2+。

**Alternatives：** 一次实现全表 `ready→active→terminal→recoveryReady`（拒绝：越权 K2+，会假绿 recovery）；省略 `recoveryReady` 枚举（拒绝：与 base 可观察态集合漂移，后续补枚举破坏 fixture 稳定）。

### D4. Compound batch：固定总序 + 整批校验 + 原子应用 + 单最终 snapshot

**选择：**

1. **唯一 batch API shape** = 单入口 **`apply(batch:)`**。**禁止** `submit` + `commit` dual API；**禁止** 在 batch 中间暴露 authoritative snapshot。
2. 收到 batch 后 **先 canonicalize**：固定总序 **start（→active）先于 terminal/cancel**（与输入序/墙钟无关）。
3. 在 **scratch snapshot** 上按 **canonical order** 模拟验证**整批**（validation **不得**把每个 event 都对**初始** state 独立判定）。
4. 仅当整批在 scratch 上全部有效时，**一次性 commit** authoritative snapshot/fact；任一事件在 scratch 路径上无效 → 整批拒绝、**零** authoritative 突变。
5. 只发布 **一个** 最终不可变 outcome/snapshot；**禁止** 中间 applied truth / 中间 snapshot 外泄。
6. 在 **parent session** 层（**无 children**、**无 fan-out**；**不**写 parent schema hierarchy），`cancel` 映射为 terminal **disposition/cause**（取消类）。

**Rationale：** base「Compound requests have one ordered result」+ F03；避免「先 start 发布 active 再 cancel 覆盖」的双真相，以及「对初始 state 逐 event 独立判定」导致的假拒绝/假接受。

**Alternatives：** 按到达序应用（拒绝：非确定性）；部分应用（拒绝：零部分突变铁律）；submit+commit dual API 或中途暴露 snapshot（拒绝：双真相/可观测中间态）；引入 child cancel fan-out（拒绝：K2）；parent schema hierarchy 模型（拒绝：K1 无 children，仅 parent session 层 disposition）。

### D5. First terminal cause/disposition once-write；duplicate 不覆盖

**选择：** 第一次成功进入 `terminal` 时写入 **first cause** 与 **disposition**；之后任何 terminal/cancel 类事件 → **observed/rejected**，snapshot 与 first cause/disposition **不变**（F09）。

**Rationale：** base「First-cause and terminal identity remain stable」；防止晚到 cancel 改写真实 terminal 原因。

**Alternatives：** last-write-wins（拒绝：演示/审计撒谎）；合并多 cause 字符串（拒绝：非封闭、难测）。

### D6. F11 fact-schema 显式错误类；无 UI 字符串/imports

**选择：** K1 发布 **fact classification**（至少覆盖 refused / cancelled / unsupported / timeout / failure 等错误与非成功类，以及 accepted 成功类若适用）。**禁止** 将错误类 fact 升格为 success/accepted。**禁止** UI 文案、SwiftUI、presentation matrix import。UI 渲染 **defer K3+**。

**Rationale：** base「Error is not success」+ B2 F11 读作 **fact-schema only**（独立审 P3a）。对齐 presentation matrix 的「封闭错误 enum」思想（`DemoRuntimeResultPresentationMatrix.swift:23-29`），但不绑 UI。

**Alternatives：** 复用 `RuntimePresentationErrorClass`（拒绝：UI/T5 耦合）；仅 bool success（拒绝：丢失分类、易假绿）。

### D7. 无 ledger / event stream / dependency / 必需 clock

**选择：** K1 **不**要求持久 ledger、可回放 event stream、`swift-dependencies`、或必需时间戳。若某 API 形状需要时间，**仅允许** 可选固定 timestamp provider；**默认 prefer 无 timestamp**。确定性来自 **逻辑序与状态机**，不来自墙钟。

**Rationale：** documentary D6 的 pin 依赖属 010a 键；K1 schema-only 不应拖入 Package 依赖变更。runner 的 `timestampProvider`（`DemoRuntimeSessionRunner.swift:28-38`）是生产模式，**NOT_TOUCH**。

**Alternatives：** 立刻引入 clocks pin（拒绝：K4 范围）；强制 Date.now（拒绝：测试非确定）。

### D8. 五文件 CREATE；Package 自动收录；MODIFY none

**选择：** 未来 apply 仅：

| op | path |
|---|---|
| CREATE | `Core/Lifecycle/SessionLifecycleTypes.swift` |
| CREATE | `Core/Lifecycle/SessionLifecycleFacts.swift` |
| CREATE | `Core/Lifecycle/SessionLifecycleCoordinator.swift` |
| CREATE | `Tests/MAformacCoreTests/SessionLifecycleFixtures.swift` |
| CREATE | `Tests/MAformacCoreTests/SessionLifecycleCoordinatorTests.swift` |
| MODIFY | **none** |

`Package.swift:46-54` 已用目录 `Core` / `Tests/MAformacCoreTests` → 新文件自动入 target。

**Rationale：** B2 §3.2–3.3；零既有 HIGH/CRITICAL 符号编辑 → 无 risk-ack 暗示。

**Alternatives：** 改 Package 显式列文件（拒绝：无必要 MODIFY）；塞进既有 God-file（拒绝：耦合 + MODIFY）。

### D9. XCTest；per-test 新 owner；不可变 fixture；RED→GREEN 精确六例

**选择：** 使用 **XCTest**（与 `DemoRuntimeResultPresentationMatrixTests` 同栈）。每个测试构造 **fresh coordinator/owner**；fixture 为不可变输入表；**无**共享静态可变 lifecycle 状态。覆盖且优先 **F01, F02, F03, F09, F10, F11** 的 RED→GREEN。

**Rationale：** B2 §4.4 + D9 锁定；Swift Testing 迁移文档存在但不强制迁移现有 Core 测面。

**Alternatives：** 共享单例 fixture 状态（拒绝：顺序耦合）；Swift Testing only（拒绝：与现仓不一致、增迁移面）。

### D10. Proof ceiling = PARTIAL_SCHEMA_ONLY

**选择：** 即使六 fixture 全绿 + OpenSpec strict 绿，claim 上限仍为 **`PARTIAL_SCHEMA_ONLY`**。禁止 W8 DONE / proof_runtime / operator-pass / gate green / production-shaped consumer 声称。

**Rationale：** B2 proof ceiling；K1 无 production seam。

**Alternatives：** unit 绿即 DONE（拒绝：claim-vs-reality 灾难同源）。

---

## Risks / Trade-offs

| Risk（具体 failure） | Mitigation | Test / 验证 | Source |
|---|---|---|---|
| 第二 lifecycle 真相（App/runner 旁路写状态） | D1/D2：单 owner + authority identity；K1 不接线生产 | F01：非 owner apply → reject，snapshot/generation 不变 | base single-owner；B2 F01；`DemoRuntimeSessionRunner` NOT_TOUCH |
| 非法/recovery 转移被静默接受 | D3：可执行表仅两行；recoveryReady 请求 fail-closed | F02：forbidden source→target → 零突变；另测 recoveryReady 请求 reject | B2 §4.2–4.3 |
| compound start+cancel 双发布或序不确定 | D4：整批校验 + 原子 + start-before-terminal 总序 | F03：同 batch 乱序输入 → 同一 immutable outcome | base compound scenario |
| duplicate terminal 覆盖 first cause | D5 once-write | F09 | base first-cause |
| unknown/cross-session 部分写 | D2/D3 fail-closed | F10 | base unknown identity |
| 错误 fact 当 success | D6 显式错误类 | F11；对照 presentation 错误非成功先例（测文件 42–63） | base error-not-success；B2 F11 |
| 引入 clock/依赖导致非确定或 Package MODIFY | D7/D8 | apply diff：五 CREATE、零 MODIFY Package | Package.swift:46-54；runner clock NOT_TOUCH |
| 测试共享状态假绿 | D9 per-test owner | 审测：无 static mutable lifecycle | XCTest isolation 惯例；WWDC24 testing |
| unit 绿抬升 W8 DONE | D10 | 文档/claim 审：仅 PARTIAL_SCHEMA_ONLY | B2 proof ceiling |
| 与 base K2–K6 合同冲突（弱化 recovery/child） | delta **只 ADDED** K1 delivery 约束；**不** MODIFIED/REMOVED base | OpenSpec validate；人工 diff base vs delta | proposal Impact；base full requirements |
| 并发/actor 过早引入 data race 或假隔离 | D1 同步面 | 代码审：无 Task/actor/MainActor on owner | Swift concurrency book；Swift 5.10 blog |

### Trade-offs（接受）

- **可观察含 `recoveryReady` 但不可执行**：类型与 base 对齐，但 K1 测必须证明「请求被拒」而非「未建模」。代价：多几个负例；收益：避免后续枚举漂移。
- **cancel 仅 parent disposition**：无真实 child fan-out。代价：不能声称 cancellation fence；收益：严格 K1 子集、零 K2 膨胀。
- **无生产接线**：技术绿 ≠ 产品 delta。明确 `PARTIAL_SCHEMA_ONLY`。

---

## Migration Plan

1. **本 change 文档波（当前）**
   - 写入 proposal（已有）→ design（本文件）→ delta spec → tasks（另 writer 或后续）。
   - `status = REVISION_1_PENDING_FOCUSED_RECHECK`；**不** self-CLEAR。
   - `openspec validate implement-t09-session-lifecycle-schema-core --strict`（及项目要求的 all-strict）在四件套齐后执行。

2. **agree-before-build 门（编码前全绿）**
   - 独立审 CLEAR（producer ≠ auditor）。
   - strict validate rc0。
   - tasks / applyRequires 对 schema-only apply 为 ready。
   - fresh repo rehash 确认 basis。
   - 计划 diff 无既有 HIGH/CRITICAL 编辑。

3. **未来 apply（另键；本 design 不执行）**
   - RED：仅五 CREATE 中的两测试文件，先挂 F01–F03/F09–F11 失败断言。
   - GREEN：三 Core 文件实现 D1–D7 同步状态机。
   - 验证：目标测绿 + `git diff` 恰五新文件零 MODIFY + claim 仍 `PARTIAL_SCHEMA_ONLY`。

4. **Rollback**
   - 文档波：删/停本 change 树即可，无代码回滚。
   - 若错误 apply：删除五新文件即可；因零 MODIFY，无生产符号修复面。

5. **后续键**
   - K2+：child/recovery/profile/gates — **新 change / 新 agree**，不 silently 扩本 change。
   - K3：生产接线 + 可选 actor 包装 — 需 GitNexus impact + 可能 HIGH/CRITICAL risk-ack。

---

## Open Questions

（不阻塞本 design 冻结；编码前若影响 API 形状再上抛）

1. **Authority identity 具体值形态**：opaque token vs 与 session 绑定的 value — 实现可在测试可区分前提下选取，但须 enforce「错 identity → 零突变」。
2. **Terminal cause 封闭枚举的最终 case 表**：须覆盖 F11 分类与 cancel 映射；精确拼写可在 apply 时用 table-driven 测钉死，但不得出现 success 升格路径。
3. **Batch API 形状** — **CLOSED（REVISION_1）**：唯一 shape = **`apply(batch:)`**；canonicalize → scratch 整批模拟 → 一次性 commit；**禁止** submit+commit dual API；**禁止** batch 中间 snapshot。见 D4。
4. **K3 包装时机**：何时引入 `@MainActor`/actor 与 runner 提交面 — **明确不在 K1**；保持 OPEN 直至独立 impact + risk-ack。
5. **是否需要只读 published generation 计数器在 K1**：非必需；若加，仅用于 F01/F10 断言，不暗示 monotonic new-session 已实现（那是 recovery 后 K2+）。

---

## Revision note（REVISION_1 — focused recheck，不自签 CLEAR）

```text
revision: REVISION_1
marker: REVISION_1_PENDING_FOCUSED_RECHECK
self_signed_review_clear: false
independent_review_status: CLEAR_AFTER_FOCUSED_RECHECK (Hermes); producer does NOT self-CLEAR
```

| ID | Closure（本修订） | 落点 |
|---|---|---|
| **P1a** | Batch API 唯一为 `apply(batch:)`；canonicalize（start before terminal/cancel）→ scratch 按 canonical order 整批模拟 → 全部有效后一次性 commit；validation 不得对初始 state 逐 event 独立判定；无 dual API / 无中间 snapshot | D4 items 1–5；Open Q3 CLOSED；tasks 4.1 + 4.4 |
| **P1b** | 删除 F11 下 runtime mock/real context scenario 与不可执行句子；在 K1 evidence 保留 **claim-level** nonclaim：schema-only evidence 不得授权/声称 real vehicle control（evidence 分类，非 runtime 检测） | delta `session-lifecycle/spec.md` |
| **P2a** | D4 item 6 wording = **parent session** 层（无 children、无 fan-out），不写 parent schema hierarchy | D4 |
| **P2b** | tasks 2.3：types 不存在时 compile-red 可为 legitimate RED；types 足以运行后 discovered count **必须 > 0**；count=0 **永远** hard fail（不用 or） | tasks.md 2.3 |

**Residual / risks（仍 OPEN，不因本修订关闭）：** independent focused recheck 未完成；coding 仍 agree-before-build 门控；K2–K6 deferred；production seam / risk-ack OPEN；proof ceiling 仍 `PARTIAL_SCHEMA_ONLY`。

---

```text
design_status: REVISION_1_PENDING_FOCUSED_RECHECK
self_signed_review_clear: false
proof_ceiling: PARTIAL_SCHEMA_ONLY
executable_transitions_k1: ready->active; active->terminal
fixtures_k1: F01,F02,F03,F09,F10,F11
future_create_count: 5
future_modify_count: 0
production_wiring: none
batch_api_shape: apply(batch:) only; canonicalize then scratch-validate then atomic commit
```

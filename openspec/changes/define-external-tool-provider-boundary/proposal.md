<!--
status: active_contract_carrier
decision: D-115/N1 approved（磊哥 2026-07-07 「N1-N4 全部同意你的推荐」，docs/commander-log/decisions.md:1031-1039）
authority: this proposal amends the old MCP boundary decision（docs/project/brainstorm-2026-06-17-demo-mvp.md:264-270）from "MCP 走 Capability 同构" to "vehicle Capability + domain-neutral ToolProvider 并行"
agree-before-build: spec 已 agree（D-115 N1 批方向）；代码 apply 仅在 commander 批 Slice A/C 后
proof_class: openspec_contract
-->

## Why

旧 MCP 边界决策（`docs/project/brainstorm-2026-06-17-demo-mvp.md:264-270`）在 Phase-1 作为 non-claim 是安全的，但作为 Phase-2 实现形状是不安全的：

1. **当前 `Capability` 不是 domain-neutral**：`Capability.handle` 接收 `ToolCallFrame`（vehicle IR: device/actionPrimitive/slots/value）+ `DemoVehicleStateStore`（`Core/Capability/Capability.swift:35-40`，`Core/Routing/ToolCallFrame.swift:168-181`）。若 music/navigation 强行走 `Capability`，要么把 `DemoVehicleStateStore` 传给非车控 provider，要么把非车控 tool call 伪装成 `device/actionPrimitive` frame——两者都是 category error。

2. **Phase-2 domain 已锁**：导航/音乐/外卖 via MCP 是二期（`CLAUDE.md:97`），`contracts/agents.yaml:21-43` 已有 `enabled: false` + `planned` 占位。若不提前定边界，二期实现会默认走 `Capability` 路径，导致 category error 进代码后才返工。

3. **W4 盘点确认**：当前执行链是 vehicle-bound，低风险 MCP 预留应从 domain/provider 边界 + 只读 registry 起步，不是真实 MCP client 或 C3 entrypoint（`out/inv-arch-mcp.md:15-22,28-34,58-73,75-88`）。

## What Changes

**Amend** 旧决策：

> 旧：MCP 走 `Capability` 本地/MCP 同构（`brainstorm-2026-06-17-demo-mvp.md:267`）

> 新：车控保留 `Capability` 作为 vehicle-domain 执行抽象。二期外部 domain 用并行、domain-neutral 的 `ToolProvider` 边界。两条路径共享 guard / proof-cap / non-claim / presentation-readback 纪律，但 MCP provider **不实现** vehicle `Capability`，**不接收** `DemoVehicleStateStore`。

短形式：`vehicle Capability + domain-neutral ToolProvider 并行`

### 车控路径（保持不变）

- `Capability` 仍是车控能力抽象
- `CapabilityRegistry` 仍对车控能力有效，可保留为 local registry 模式
- `DemoGuard` / risk policy / allowlist / executor 纪律对任何 vehicle state mutation 仍强制
- `DemoVehicleStateStore` 仍是 vehicle-only，不是外部 domain store

### 外部 domain 路径（新增并行）

二期 MCP-style domain 用并行 provider 边界：

```swift
struct ToolProviderDescriptor {
    var domainID: DomainID
    var connector: ConnectorKind      // .mcp first
    var enabled: Bool                  // false first
    var availability: Availability     // .planned first
    var proofCap: ProofCap
}

protocol ToolProvider: Sendable {
    var descriptor: ToolProviderDescriptor { get }
    func listTools() async throws -> [ExternalToolSchema]
    func invoke(_ invocation: ExternalToolInvocation) async throws -> ExternalToolResult
}
```

首批实现 = disabled stub only：`connector=.mcp` / `enabled=false` / `availability=.planned` / `invoke` throws 或返回 `planned_connector_disabled` / **无 `.success` 状态** / **无 App/C3 runtime entrypoint**。

### Domain vocabulary（domain-neutral）

`DomainDescriptor` / `DomainRegistry` / `ToolProvider` / `ExternalToolSchema` / `ExternalToolInvocation` / `ExternalToolResult` / `ExternalToolStatus`。neutral invocation 携带 `domainID/toolName/arguments/connector/proofClass/status`，**不携带** `device/actionPrimitive/value`（除非 domain 显式是 vehicle）。

### Guard/executor 等价边界

amend 必须保留旧"MCP 不能绕过 guard/executor"意图，但不把所有 domain 强塞进 vehicle executor：

- **车控**：guard = 现有 semantic/risk/allowlist/DemoGuard；executor = 现有 vehicle executor/adapter；readback = mock vehicle state readback（验收源）
- **外部 domain**：guard = `DomainProviderGuard`（校验 enabled/availability/connector type/allowed domain/argument schema/privacy policy/proof cap/non-claim）；executor-equivalent = `ToolProviderExecutor`（处理 provider invocation，返回 `ExternalToolResult`，**禁写 `DemoVehicleStateStore`**）；readback = `ExternalToolObservation` 或 external-domain presentation payload（weak proof cap until real MCP approved）

等价 ≠ 相同。每个 domain 必须有：①pre-invocation policy gate ②explicit executor boundary ③machine-readable status ④readback/observation ⑤proof-class cap ⑥no claim upgrade。

### Proof-class = Option A（已拍）

D-115 N1 批 Option A：外部 domain provider 用 public `PresentationProofClass`（`Core/Presentation/RuntimePresentationBridge.swift:111-119`），不另建第三 proof vocabulary。

首批允许值：`.docsLocal` / `.openspecContract` / `.localStaticContract` / `.localUnit`（仅 unit-tested provider-stub）/ `.simulatorMock`（仅 simulator proof）。

**禁加** `mcp_success` / `live_mcp` / `runtime_ready` / `true_device_ready` / 任何 V/S/U-PASS-like 值。

Slice B/D 若后续加 provider execution 或 external observations，引入 Option B（provider-internal `ExternalToolProofClass` mapped to public at presentation boundary）**仅当**：explicit mapping tests + unknown-value fail-closed tests + no-readiness-claim grep + no `.success` until real MCP approved。

## Non-Goals（首批实现禁做）

- 不导入真实 MCP SDK
- 不加 MCP client
- 不加 App/C3 runtime entrypoint
- 不改 `DemoRuntimeSessionRunner` / `C3ExecutionPipeline` / `DemoVehicleStateStore`
- 不加 provider `.success` 状态
- 不声称"已支持 MCP/导航/音乐/外卖"（`openspec/specs/demo-experience/spec.md:74-79` 禁）
- 不把外部 domain card 塞进 vehicle family grid

## Acceptance Gates（commander 批 Slice A/C 代码前）

```bash
openspec validate define-external-tool-provider-boundary --strict
rg -n "已支持 MCP|已支持导航|已支持音乐|已支持外卖|MCP success|runtime_ready|true_device_ready|V-PASS" openspec/changes/define-external-tool-provider-boundary docs
```

Slice A/C 代码后：

```bash
swift test --filter DomainRegistryTests
swift test --filter ExternalToolInvocationTests
git diff --check
rg -n "DemoVehicleStateStore|C3ExecutionPipeline|DemoRuntimeSessionRunner|\.success" Core/Domain
```

期望：无 App/C3 callsite diff / 无 provider success status / 无 vehicle-store dependency in external provider code / proof class capped to local/docs/unit stub only。

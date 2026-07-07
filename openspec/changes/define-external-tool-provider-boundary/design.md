<!--
status: active_contract_carrier
decision: D-115/N1
authority: design for define-external-tool-provider-boundary proposal
-->

## Context

旧 MCP 边界决策（`docs/project/brainstorm-2026-06-17-demo-mvp.md:264-270`）说"MCP 走 `Capability` 本地/MCP 同构"。Phase-1 未接真实 MCP，此决策作为 non-claim 安全。但 Phase-2 若实现，当前 `Capability` 不是 domain-neutral（`Core/Capability/Capability.swift:35-40` 接收 `ToolCallFrame` vehicle IR + `DemoVehicleStateStore`），强塞非车控 domain 会产生 category error。

本 design 定义 amend 后的双路径边界 + guard/executor 等价 + proof-class 选择。

## Decision

**vehicle `Capability` + domain-neutral `ToolProvider` 并行**（D-115/N1 磊哥批）。

### vehicle 路径（保持不变）

| 组件 | 职责 | 改动 |
|---|---|---|
| `Capability` | vehicle 能力抽象 | 不变 |
| `CapabilityRegistry` | vehicle 能力 local registry | 不变（可保留为 local registry 模式） |
| `DemoGuard` + risk policy + allowlist + executor | vehicle state mutation 强制门 | 不变 |
| `DemoVehicleStateStore` | vehicle-only state store | 不变（不传给外部 provider） |
| `ToolCallFrame` | vehicle IR（device×actionPrimitive×slots×value） | 不变（外部 domain 不用此 frame） |

### external domain 路径（新增并行）

| 组件 | 职责 | 首批状态 |
|---|---|---|
| `ToolProviderDescriptor` | provider 元数据（domainID/connector/enabled/availability/proofCap） | disabled stub |
| `ToolProvider` protocol | `listTools()` + `invoke(ExternalToolInvocation)` | throws/returns `planned_connector_disabled` |
| `ExternalToolSchema` | provider 工具目录描述 | 空或 stub |
| `ExternalToolInvocation` | neutral invocation（domainID/toolName/arguments/connector/proofClass/status） | 不携带 device/actionPrimitive/value |
| `ExternalToolResult` | provider 返回值 | 无 `.success`，首批只有 `planned_connector_disabled` |
| `ExternalToolStatus` | machine-readable status enum | 无 success 值 |
| `DomainRegistry` | domain 注册表（只读，disabled planned entries） | 导航/音乐/外卖 3 entry，全 disabled |
| `DomainProviderGuard` | pre-invocation policy gate（enabled/availability/connector/domain/schema/privacy/proofCap/non-claim） | fail-closed |
| `ToolProviderExecutor` | executor-equivalent boundary（invocation → result，禁写 DemoVehicleStateStore） | returns disabled result |

### Guard/Executor 等价边界

等价 ≠ 相同。每个 domain 必须有 6 项：①pre-invocation policy gate ②explicit executor boundary ③machine-readable status ④readback/observation ⑤proof-class cap ⑥no claim upgrade。

| 维度 | vehicle | external domain |
|---|---|---|
| guard | semantic/risk/allowlist/DemoGuard | DomainProviderGuard（enabled/availability/connector/domain/schema/privacy/proofCap/non-claim） |
| executor | vehicle executor/adapter | ToolProviderExecutor（禁写 DemoVehicleStateStore） |
| readback | mock vehicle state readback（验收源） | ExternalToolObservation（weak proof cap until real MCP） |
| proof cap | 按 vehicle proof discipline | Option A: public PresentationProofClass（见下） |

## Proof-class 选择：Option A（已拍 D-115/N1）

两套现有 proof vocabulary：
- public/mainline: `PresentationProofClass`（`Core/Presentation/RuntimePresentationBridge.swift:111-119`）：docs_local/openspec_contract/local_static_contract/local_unit/local_shape_no_model/local_receipt_consistency/simulator_mock/external_gptpro_review
- UI stage: `StagePresentationProofClass`（`Core/Presentation/PresentationSnapshot.swift:14-18`）：local_mock/static_preview/simulator_mock/operator_review

bridge 已有 public→stage 映射 + unknown fail-closed（`Core/Presentation/RuntimePresentationPayloadFixtureConsumer.swift:469-481`；D15 public 名 `Core/Presentation/RuntimePresentationConsumerMapping.swift:65-73`）。

**Option A = 外部 domain provider 用 public `PresentationProofClass`**。首批允许值：`.docsLocal` / `.openspecContract` / `.localStaticContract` / `.localUnit`（仅 stub）/ `.simulatorMock`（仅 simulator）。

选择理由：复用 fail-closed public vocabulary + fit D15 public payload governance + 避免发明第三 vocabulary。

**禁加**：`mcp_success` / `live_mcp` / `runtime_ready` / `true_device_ready` / V/S/U-PASS-like 值。

Option B（provider-internal `ExternalToolProofClass` mapped to public at presentation boundary）**仅当 Slice B/D 加 provider execution 时考虑**，且需 explicit mapping tests + fail-closed tests + no-readiness-claim grep + no `.success`。

## Slice 切分

| Slice | 内容 | 门控 | 首批 |
|---|---|---|---|
| A | DomainRegistry + DomainDescriptor（disabled planned entries） | 本批 | ✅ |
| C | ExternalToolInvocation vocabulary + ToolProvider protocol stub + DomainProviderGuard fail-closed | 本批 | ✅ |
| B | ToolProviderExecutor + ExternalToolObservation + proof-class mapping | gated after Slice A/C + commander 批 | ❌ |
| D | real MCP connector + Option B proof mapping | gated after real MCP approval | ❌ |

## Alternatives Considered

1. **保持旧决策（MCP 走 Capability 同构）**：Phase-2 实现时 category error 进代码后返工，风险高。否决。
2. **Option B（provider-internal proof enum）首批就做**：第三 vocabulary 增 governance surface，首批只需 disabled stub 不需要。否决，Slice B/D 再考虑。
3. **首批加真实 MCP SDK**：违反 non-goals + Q3=A+B（本轮只做架构预留不做大改）。否决。

## Risks

- **风险1**：domain-neutral vocabulary 后续若被 vehicle code 误用（如 vehicle path 走 ToolProvider）→ 破 vehicle executor 纪律。缓解：spec SHALL 禁 vehicle domain 走 ToolProvider。
- **风险2**：disabled stub 若被误当"已支持 MCP"声称 → 破 non-claim。缓解：spec SHALL 禁 `.success` + no-readiness-claim grep。
- **风险3**：guard/executor 等价若被理解为"相同"→ 外部 domain 误接 DemoVehicleStateStore。缓解：spec SHALL 禁外部 provider 写 DemoVehicleStateStore。

## Open Questions

- OQ1：Slice B/D 引入 Option B 时，mapping rule 的 test 覆盖标准？（gated，Slice B/D 时再拍）
- OQ2：未来真实 MCP connector 的 approval 门是什么？（gated，不在本轮 scope）

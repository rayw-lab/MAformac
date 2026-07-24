<!--
status: active_contract_carrier
decision: D-115/N1
authority: tasks for define-external-tool-provider-boundary
gate: Slice A/C = 本批；Slice B/D = gated after commander 批
-->

## Slice A: DomainRegistry + DomainDescriptor（本批）

- [x] A.1 定义 `DomainDescriptor` struct（domainID / displayName / enabled / availability / connectorKind / proofCap）
- [x] A.2 定义 `DomainID` enum（.vehicle / .navigation / .music / .foodDelivery）
- [x] A.3 定义 `DomainRegistry`：只读注册表，预置 3 个 disabled planned entry（navigation/music/foodDelivery，全 enabled=false availability=.planned connector=.mcp）
- [x] A.4 `DomainRegistry` SHALL NOT 注册 vehicle domain（vehicle 走 CapabilityRegistry，不进 DomainRegistry）
- [x] A.5 单元测试 `DomainRegistryTests`：3 entry 全 disabled + 无 vehicle entry + 只读不可变

验证：`swift test --filter DomainRegistryTests` + `git diff --check`

## Slice C: ExternalToolInvocation vocabulary + ToolProvider stub + Guard（本批）

- [x] C.1 定义 `ExternalToolSchema`（toolName / argumentsSchema / proofClass）
- [x] C.2 定义 `ExternalToolInvocation`（domainID / toolName / arguments / connector / proofClass / status）
- [x] C.3 定义 `ExternalToolResult` + `ExternalToolStatus`（首批只有 `planned_connector_disabled`，**无 `.success`**）
- [x] C.4 定义 `ToolProviderDescriptor`（domainID / connector / enabled / availability / proofCap）
- [x] C.5 定义 `ToolProvider` protocol（`listTools()` + `invoke(_:)`）
- [x] C.6 实现 `DisabledMcpToolProvider` stub（connector=.mcp / enabled=false / availability=.planned / invoke throws `planned_connector_disabled`）
- [x] C.7 定义 `DomainProviderGuard`：fail-closed（enabled=false → reject；availability≠.planned → reject；connector 未知 → reject；domain 未在 DomainRegistry → reject）
- [x] C.8 单元测试 `ExternalToolInvocationTests`：disabled provider invoke returns `planned_connector_disabled` + guard reject enabled=false + guard reject unknown connector + no `.success` in vocabulary
- [x] C.9 强词 grep：`rg -n "DemoVehicleStateStore|C3ExecutionPipeline|DemoRuntimeSessionRunner|\.success" Core/Domain` = 0 命中

验证：`swift test --filter ExternalToolInvocationTests` + `git diff --check` + 强词 grep

## Slice B: ToolProviderExecutor + ExternalToolObservation + proof mapping（gated）

- [ ] B.1 定义 `ToolProviderExecutor`（invocation → result，禁写 DemoVehicleStateStore）
- [ ] B.2 定义 `ExternalToolObservation`（weak proof readback）
- [ ] B.3 若 Slice B 需要 Option B proof enum：mapping tests + fail-closed tests + no-readiness-claim grep
- [ ] B.4 `ToolProviderExecutor` SHALL NOT 写 `DemoVehicleStateStore`

**门控**：Slice A/C 完成 + commander 批 Slice B 后才开工。

## Slice D: real MCP connector + Option B proof（gated）

- [ ] D.1 真实 MCP SDK 评估 + connector 实现
- [ ] D.2 Option B `ExternalToolProofClass` 若引入：full mapping + fail-closed + no-claim
- [ ] D.3 real MCP invocation 的 approval 门定义

**门控**：real MCP approval（不在本轮 scope，Q3=A+B 只做架构预留）。

## 全局验收（Slice A/C 完成后）

- [ ] `openspec validate define-external-tool-provider-boundary --strict` 绿
- [ ] `make verify-all` 绿（新 Core/Domain 文件进 MAformacCore 编译面）
- [ ] no App/C3 callsite diff：`git diff HEAD~1 -- App/ Core/C3* Core/Execution | wc -l` = 0
- [ ] no vehicle-store dependency：`rg -n "DemoVehicleStateStore" Core/Domain/` = 0
- [ ] no provider success：`rg -n "\.success" Core/Domain/` = 0
- [ ] no-readiness-claim：`rg -n "已支持 MCP|已支持导航|已支持音乐|已支持外卖|MCP success|runtime_ready|true_device_ready|V-PASS" openspec/changes/define-external-tool-provider-boundary docs` = 0

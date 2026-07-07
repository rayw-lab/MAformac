<!--
status: active_contract_carrier
decision: D-115/N1
authority: spec delta for define-external-tool-provider-boundary
target: openspec/specs/external-tool-provider/spec.md (new capability)
proof_class: openspec_contract
-->

## ADDED Requirements

### Requirement: External domains SHALL use a parallel ToolProvider boundary, not vehicle Capability

The system SHALL keep vehicle control on the existing `Capability` + `CapabilityRegistry` + `DemoGuard` + `DemoVehicleStateStore` path. Phase-2 external domains (navigation, music, food delivery) SHALL use a parallel, domain-neutral `ToolProvider` boundary. External providers SHALL NOT implement vehicle `Capability` and SHALL NOT receive `DemoVehicleStateStore`. The `ToolProvider` invocation SHALL carry a neutral `ExternalToolInvocation` (domainID, toolName, arguments, connector, proofClass, status) that does NOT carry `device`/`actionPrimitive`/`value` unless the domain is explicitly vehicle.

#### Scenario: vehicle domain stays on Capability path
- **GIVEN** a vehicle-domain tool call (e.g. "adjust AC temperature")
- **WHEN** the system dispatches it
- **THEN** it goes through `Capability` / `CapabilityRegistry` / `DemoGuard` / vehicle executor
- **AND** it SHALL NOT go through `ToolProvider` / `DomainRegistry`

#### Scenario: external domain does not receive DemoVehicleStateStore
- **GIVEN** a navigation or music tool invocation
- **WHEN** a `ToolProvider` handles it
- **THEN** the provider SHALL NOT receive `DemoVehicleStateStore`
- **AND** the provider SHALL NOT import or reference `DemoVehicleStateStore`

#### Scenario: external invocation does not carry vehicle IR fields
- **GIVEN** an `ExternalToolInvocation` for a non-vehicle domain
- **WHEN** it is constructed
- **THEN** it SHALL carry `domainID`, `toolName`, `arguments`, `connector`, `proofClass`, `status`
- **AND** it SHALL NOT carry `device`, `actionPrimitive`, or `value` fields

### Requirement: Planned providers SHALL be disabled with no success status

The first-slice `ToolProvider` implementations SHALL be disabled stubs: `enabled = false`, `availability = .planned`, `connector = .mcp`. Invoking a disabled provider SHALL return `planned_connector_disabled` or throw. The `ExternalToolStatus` vocabulary SHALL NOT include a `.success` value in the first slice. No provider SHALL report success, readiness, or live MCP connection.

#### Scenario: disabled provider invocation returns planned_connector_disabled
- **GIVEN** a `DisabledMcpToolProvider` with `enabled = false` and `availability = .planned`
- **WHEN** `invoke(_:)` is called
- **THEN** it SHALL return `planned_connector_disabled` or throw
- **AND** it SHALL NOT return `.success`

#### Scenario: no success status exists in first-slice vocabulary
- **GIVEN** the first-slice `ExternalToolStatus` enum
- **WHEN** its cases are enumerated
- **THEN** it SHALL NOT contain `.success`
- **AND** it SHALL NOT contain any V-PASS / runtime_ready / true_device_ready / live_mcp value

#### Scenario: no readiness claim in docs or code
- **GIVEN** the change folder and any docs referencing external tool providers
- **WHEN** a readiness-claim grep runs (`rg -n "已支持 MCP|已支持导航|已支持音乐|已支持外卖|MCP success|runtime_ready|true_device_ready|V-PASS"`)
- **THEN** the result SHALL be empty

### Requirement: Provider invocation SHALL fail closed through DomainProviderGuard

Every `ToolProvider` invocation SHALL pass through a `DomainProviderGuard` before reaching the provider. The guard SHALL reject when: provider `enabled = false`, `availability != .planned`, connector type is unknown, domain is not in `DomainRegistry`, argument schema is invalid, privacy policy is violated, proof cap is exceeded, or a non-claim rule is breached. The guard SHALL fail closed on unknown values.

#### Scenario: guard rejects disabled provider
- **GIVEN** a provider with `enabled = false`
- **WHEN** an invocation is submitted to `DomainProviderGuard`
- **THEN** the guard SHALL reject it
- **AND** the provider `invoke` SHALL NOT be called

#### Scenario: guard rejects unknown connector type
- **GIVEN** a provider with `connector = .unknown`
- **WHEN** the guard evaluates it
- **THEN** the guard SHALL reject it (fail closed)

#### Scenario: guard rejects domain not in registry
- **GIVEN** an invocation with `domainID = .payments` (not in DomainRegistry)
- **WHEN** the guard evaluates it
- **THEN** the guard SHALL reject it

#### Scenario: guard fails closed on unknown proof class
- **GIVEN** an invocation with `proofClass` not in the allowed first-slice set
- **WHEN** the guard evaluates it
- **THEN** the guard SHALL reject it (fail closed)

### Requirement: External providers SHALL NOT mutate vehicle state

`ToolProvider` and `ToolProviderExecutor` SHALL NOT write to `DemoVehicleStateStore`. External provider results SHALL NOT mutate vehicle state, presentation state, or candidate readiness by themselves. Provider results SHALL be capped to weak proof (`ExternalToolObservation` or external-domain presentation payload) until real MCP is approved.

#### Scenario: provider does not write DemoVehicleStateStore
- **GIVEN** a `ToolProvider` or `ToolProviderExecutor` in `Core/Domain/`
- **WHEN** its source is scanned (`rg -n "DemoVehicleStateStore" Core/Domain/`)
- **THEN** the result SHALL be empty

#### Scenario: provider result does not mutate candidate readiness
- **GIVEN** an `ExternalToolResult` from a disabled provider
- **WHEN** it is consumed
- **THEN** it SHALL NOT change candidate readiness, C5 status, or C6 acceptance
- **AND** it SHALL NOT be reported as V-PASS / signed / runtime_ready

### Requirement: Proof class SHALL use public PresentationProofClass with no upgrade

External domain providers SHALL use the existing public `PresentationProofClass` vocabulary (Option A, D-115/N1 approved). Allowed first-slice values: `.docsLocal`, `.openspecContract`, `.localStaticContract`, `.localUnit` (stub only), `.simulatorMock` (simulator proof only). The system SHALL NOT add `mcp_success`, `live_mcp`, `runtime_ready`, `true_device_ready`, or any V/S/U-PASS-like value. A separate provider-internal proof enum (Option B) MAY be introduced in Slice B/D only with explicit mapping tests, fail-closed tests, a no-readiness-claim grep, and no `.success` until real MCP is approved.

#### Scenario: provider uses allowed proof class values only
- **GIVEN** a first-slice `ToolProviderDescriptor` with `proofCap`
- **WHEN** the proof class is set
- **THEN** it SHALL be one of `.docsLocal`, `.openspecContract`, `.localStaticContract`, `.localUnit`, `.simulatorMock`
- **AND** it SHALL NOT be `mcp_success`, `live_mcp`, `runtime_ready`, `true_device_ready`, or V/S/U-PASS

#### Scenario: unknown proof class fails closed
- **GIVEN** an invocation with a proof class not in the allowed set
- **WHEN** the `DomainProviderGuard` evaluates it
- **THEN** the guard SHALL reject it (fail closed)

#### Scenario: Option B deferred to Slice B/D
- **GIVEN** the first slice (Slice A/C)
- **WHEN** proof class is selected
- **THEN** it SHALL use Option A (public PresentationProofClass)
- **AND** Option B (provider-internal ExternalToolProofClass) SHALL NOT be introduced until Slice B/D with commander approval

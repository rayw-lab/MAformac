## ADDED Requirements

### Requirement: Main-Owned Core Config Vocabulary

The system SHALL define Core config and scene macro vocabulary in mainline authority before any UIUE consumer treats those names as shared runtime or presentation facts.

#### Scenario: UIUE cannot invent Core config truth

GIVEN UIUE needs to display or consume a Core config or scene macro name
WHEN that name is absent from main-owned OpenSpec, docs, or code authority
THEN UIUE SHALL treat the name as unavailable
AND UIUE SHALL NOT invent a shared field, enum value, proof class, or hidden planner/config truth.

#### Scenario: Stable names are finite and main-owned

GIVEN D16 defines Core config or scene macro names
WHEN D17 consumes those names
THEN D17 SHALL consume only stable main-owned names
AND D17 SHALL preserve the proof class attached to those names.

#### Scenario: Unknown config names fail closed

GIVEN an unknown Core config key or scene macro name reaches a consumer
WHEN the consumer validates it
THEN validation SHALL fail closed
AND the consumer SHALL NOT render it as a successful supported shared feature.

### Requirement: Scene Macro Registry Authority Boundary

The system SHALL treat `SceneMacroRegistry` or any equivalent Core config registry as a main-owned owner boundary, not as UIUE-local presentation state.

#### Scenario: Registry is not hidden in UI presentation

GIVEN a future registry maps scenario or macro names to allowed demo behavior
WHEN UIUE renders presentation state
THEN UIUE SHALL NOT act as the source of that registry
AND UIUE SHALL NOT store a divergent same-meaning registry.

#### Scenario: Registry does not imply runtime readiness

GIVEN mainline defines registry authority or local/unit registry code
WHEN status is reported
THEN the status SHALL remain capped to the actual proof class
AND it SHALL NOT claim production runtime, mobile, true-device, live API, model, voice, golden, endpoint, UIUE merge, V-PASS, S-PASS, or U-PASS readiness.

### Requirement: Demo Force-State Boundary

The system SHALL isolate force-state behavior to explicit demo/debug surfaces and SHALL prevent force-state from becoming a customer-facing production path.

#### Scenario: Force-state requires demo/debug isolation

GIVEN a future force-state input changes demo context such as vehicle speed, gear, weather, or time period
WHEN the input is accepted
THEN it SHALL be available only through an explicit demo/debug isolation boundary such as `DEMO_MODE` or `DEBUG`
AND it SHALL NOT be reachable from a customer-facing production path.

#### Scenario: Force-state uses bridge event provenance

GIVEN force-state changes demo context
WHEN the change reaches runtime or presentation state
THEN the change SHALL carry traceable bridge event provenance
AND it SHALL NOT appear as an unexplained direct store mutation.

#### Scenario: Force-state does not mutate state-cell contracts directly

GIVEN force-state modifies current demo context
WHEN state-cell contracts or semantic source contracts are evaluated
THEN force-state SHALL NOT mutate those contracts directly
AND it SHALL remain a demo context input rather than a contract-authoring mechanism.

#### Scenario: Debug-only proof is not production proof

GIVEN a debug gallery, simulator screenshot, local test, or local OpenSpec validation proves force-state behavior
WHEN status is reported
THEN the proof SHALL remain capped to debug/local/unit/simulator_mock as applicable
AND it SHALL NOT be reported as production runtime, mobile, true-device, or live proof.

### Requirement: D17 Consumer Boundary

The system SHALL allow D17 UIUE consumer work to consume only D15 presentation-safe payload fields and D16 stable main-owned config/force-state names under UIUE proof cap.

#### Scenario: D17 consumes stable authority only

GIVEN D17 starts after D16 Gate 4 opens the release gate
WHEN UIUE implements consumer mapping
THEN it SHALL consume only D15 stable payload fields and D16 stable main-owned names
AND it SHALL fail closed on unknown schema, proof class, reconciliation status, mismatch class, config name, scene macro name, force-context dimension, or presentation field.

#### Scenario: D17 does not consume private adapter fields

GIVEN UIUE implements consumer mapping
WHEN it parses or maps a presentation payload
THEN it SHALL NOT consume `DemoRuntimeAdapter*`, `RuntimeAdapterBox`, `requestFingerprint`, `parentRequestFingerprint`, `failureLedger`, ledger internals, settled parent plan internals, raw runtime store, raw model output, training receipt, or adapter-local private names.

#### Scenario: D17 proof class is capped

GIVEN D17 passes UIUE local/unit or simulator smoke validation
WHEN final status is reported
THEN that status SHALL remain capped to local/unit/simulator_mock proof
AND it SHALL NOT claim UIUE merge, mobile, true-device, live API, runtime-ready, V-PASS, S-PASS, U-PASS, or A-2 readiness.

### Requirement: D15 Payload Proof Cap Preservation

The system SHALL preserve the D15 Runtime -> Presentation payload proof cap when adding D16 authority.

#### Scenario: D16 does not change D15 payload fields in Gate 1

GIVEN Gate 1 creates Core config and force-state authority
WHEN D15 payload contract fields are evaluated
THEN Gate 1 SHALL NOT add or rename D15 payload fields
AND Gate 1 SHALL NOT expose private adapter fields through the payload contract.

#### Scenario: Authority does not equal implementation

GIVEN this OpenSpec authority validates
WHEN status is reported
THEN the status SHALL identify Gate 1 as authority/docs proof only
AND it SHALL NOT claim Swift implementation, runtime execution, UIUE consumer integration, or production force-state behavior.

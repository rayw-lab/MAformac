## ADDED Requirements

### Requirement: K3 composition gate owns parent-session active transition only

The system SHALL provide a frontstage composition gate that binds one stable parent session identity at generation 0 and is the only authority that may move that parent session from ready to active on the frontstage production path. The gate MUST privately hold owner authority and a single lifecycle coordinator instance. Application composition MUST NOT receive or store the owner authority token. The gate MAY expose a read-only immutable snapshot for consumers and tests. The gate MUST NOT publish parent terminal transitions, MUST NOT map payload or turn terminals onto parent terminal, and MUST NOT implement recoveryReady entry, new-generation activation, child registration, cancel fan-out, or fence join.

#### Scenario: Stable parent identity and generation 0 initial gate

- **GIVEN** a frontstage composition that constructs a session lifecycle composition gate for a parent session
- **WHEN** the gate is created
- **THEN** the gate is bound to that parent session identity at generation 0
- **AND** the initial observable lifecycle state is ready
- **AND** the application path cannot obtain the owner authority token

#### Scenario: First activation applies start once

- **GIVEN** a composition gate whose bound parent session is ready under generation 0
- **WHEN** `ensureActive` is called with the matching expected session identity
- **THEN** the gate applies exactly one authorized start
- **AND** it returns an immutable snapshot whose state is active for the bound identity and generation
- **AND** the apply result is accepted only when status is applied and the active identity matches

#### Scenario: Repeat ensureActive is idempotent

- **GIVEN** a composition gate whose bound parent session is already active
- **WHEN** `ensureActive` is called again with the same expected session identity
- **THEN** the gate returns the existing active snapshot
- **AND** the published revision does not increase
- **AND** no second start is applied

#### Scenario: Cross-session ensureActive mutates nothing

- **GIVEN** a composition gate bound to parent session A in ready or active state
- **WHEN** `ensureActive` is called with expected session identity B
- **THEN** the call fails closed with a typed error
- **AND** the lifecycle snapshot remains unchanged (ready at revision 0 if never activated, or the prior active snapshot if already active)
- **AND** no start is applied for either identity

#### Scenario: Non-active states refuse ensureActive

- **GIVEN** a composition gate whose bound parent session is terminal, recoveryReady, or any non-active state other than ready awaiting first start
- **WHEN** `ensureActive` is requested for that bound identity
- **THEN** the request is rejected fail-closed
- **AND** the gate does not publish a terminal API outcome or recovery transition from this path

### Requirement: K3 frontstage consumer activates parent before demo route and catalog admission

The system SHALL ensure that `FrontstageRuntimeComposition.routeDemoSlice` is the production consumer of the composition gate on the frontstage path. After the existing current-turn precondition succeeds, and before any `DemoSliceRoute` construction or routing call, the consumer MUST obtain an active parent-session snapshot from the gate for the turn's parent session identity, MUST verify the returned snapshot identity matches the turn session identity and that state is active, and only then MAY invoke the existing demo slice route. This parent activation MUST occur after customer ingress acceptance for the current turn and MUST occur before `DemoSliceAdmissionCatalog` admission decisions. A catalog rejection MUST NOT roll back parent active. Parent session lifecycle MUST NOT be treated as turn-as-session.

#### Scenario: Consumer-before-route ordering and fail-closed

- **GIVEN** a frontstage composition with a current accepted turn
- **WHEN** `routeDemoSlice` runs
- **THEN** parent `ensureActive` and active snapshot guards complete before any `DemoSliceRoute` create or route call
- **AND** if ensureActive or the snapshot identity/state guard fails, the error propagates fail-closed without calling route

#### Scenario: Activation boundary before demo catalog admission

- **GIVEN** customer ingress has accepted the utterance and the turn is current
- **WHEN** the frontstage path enters demo slice routing
- **THEN** the parent session is already ensured active before `DemoSliceAdmissionCatalog` evaluates admission
- **AND** if the catalog later rejects the demo slice, the parent session remains active rather than being rolled back

#### Scenario: No turn or payload terminal conflation

- **GIVEN** a parent session that has been activated by the composition gate
- **WHEN** a voice turn ends or a payload terminal-class outcome appears on the demo path
- **THEN** the parent session is not automatically transitioned to terminal by the K3 gate
- **AND** turn identity is not treated as a second parent session identity

### Requirement: K3 exact scope, nonclaims, and proof class

The system SHALL limit the K3 production-shaped subslice to creating the composition gate and its tests, and to the minimal `FrontstageRuntimeComposition` modification that holds a lazy optional gate and guards `routeDemoSlice`. The system MUST NOT modify `DemoRuntimeSessionRunner` or its `run` entry, `C3ExecutionPipeline` or its `execute` entry, `DemoSliceRoute` semantics, `FrontstageVoiceSession`, `ContentView`, DialogueState surfaces, force/reset stores, TTS presentation quality surfaces, operator ceremony V2, `Package.swift`, `Makefile`, `Tools/checks/**`, or the Xcode project as part of this change. Coverage claims MUST be limited to the frontstage `routeDemoSlice` consumer path and MUST NOT claim global gating of all runner invocations. Proof claims for this change MUST remain at most local production-shaped after independent review, strict validation, RED/GREEN tests, full test and local app builds, deliberate-red, change detection, and production consumer proof all pass; until then the change remains pending independent review and held for OpenSpec review.

#### Scenario: Exact scope nonclaims

- **GIVEN** an implementation claiming K3 complete
- **WHEN** the change set is inspected
- **THEN** it contains only the authorized CREATE and MODIFY paths for the composition gate, its tests, and `FrontstageRuntimeComposition`
- **AND** it does not edit runner, pipeline, DemoSliceRoute, voice session, ContentView, or package/make/xcodeproj surfaces

#### Scenario: Proof class ceiling

- **GIVEN** unit tests and local builds are green for the K3 subslice
- **WHEN** a completion claim is written
- **THEN** the claim is at most `DONE_LOCAL_PRODUCTION_SHAPED` and only after independent controller review and all listed gates pass
- **AND** the claim is not V-PASS, true-device, operator-pass, or global runner-gating readiness

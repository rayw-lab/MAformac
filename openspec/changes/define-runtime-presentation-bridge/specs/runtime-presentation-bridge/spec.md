## ADDED Requirements

### Requirement: Mainline bridge authority mapping

The system SHALL use a mainline-visible Runtime -> Presentation bridge carrier as the authority mapping for bridge semantics that affect runtime results, presentation snapshots, readbacks, scope labels, proof-class display, and UIUE handoff readiness.

#### Scenario: UIUE semantics are mapped without standalone mainline acceptance

GIVEN UIUE documents describe candidate bridge semantics
WHEN mainline records Runtime -> Presentation bridge authority
THEN mainline SHALL treat UIUE documents as candidate/provenance inputs
AND mainline SHALL NOT treat those UIUE documents as standalone mainline SSOT.

#### Scenario: No second same-meaning bridge SSOT

GIVEN mainline creates this bridge carrier
WHEN future documents reference UIUE bridge semantics
THEN the carrier SHALL reference or map those semantics
AND it SHALL NOT create a parallel same-meaning bridge SSOT with divergent field meanings.

### Requirement: Scope origin disposition

The system SHALL keep Core `ScopeOrigin` limited to `defaulted`, `explicit`, and `fanout` unless a future Core contract explicitly changes it. Missing or unresolved scope SHALL be represented in result metadata, presentation metadata, or an explicit failure reason instead of a locked Core enum case.

#### Scenario: Missing scope is not a Core enum case

GIVEN a turn cannot resolve required scope
WHEN the bridge emits presentation/result state
THEN the bridge SHALL NOT require Core `ScopeOrigin=missing`
AND it SHALL carry an explicit missing/unresolved reason through result metadata, presentation metadata, or failure reason.

#### Scenario: UI-local display label does not become Core truth

GIVEN UI presentation needs to display unresolved scope
WHEN UI uses a presentation-only label for display
THEN that label SHALL NOT be treated as a Core `ScopeOrigin` enum case
AND downstream contracts SHALL still preserve the Core-origin values `defaulted`, `explicit`, and `fanout`.

### Requirement: Runtime result vocabulary

The system SHALL classify runtime results before presentation renders them, preserving accepted action, clarify/missing-slot, unsupported/no-tool refusal, safety/policy refusal, already-state no-op, runtime error, and cancelled/interrupted outcomes as machine-readable classes.

#### Scenario: Already-state result is not unsupported

GIVEN a user asks for a state that is already satisfied
WHEN runtime produces no state mutation
THEN the bridge result SHALL be `already_state_noop`
AND it SHALL NOT be reported as unsupported or safety refusal.

#### Scenario: Unsupported and safety refusals remain distinct

GIVEN runtime cannot map a request to an available demo tool
WHEN the presentation layer renders the refusal
THEN the bridge result SHALL be `refusal_no_available_tool`
AND it SHALL NOT be collapsed into `refusal_safety_or_policy` or a bare `rejected` value.

#### Scenario: Missing slot is distinct from unsupported

GIVEN runtime needs an additional slot before selecting a safe action
WHEN the bridge emits the result
THEN the bridge result SHALL be `clarify_missing_slot`
AND it SHALL carry the missing slot or reason as machine-readable metadata.

### Requirement: Presentation snapshot contract

The system SHALL expose a presentation snapshot that contains trace identity, card state, dialog/readback text, scope-origin display source, optional voice/orb display state, and finite proof class without requiring UI presentation code to read raw runtime stores.

#### Scenario: Default scope is visible but not re-inferred

GIVEN Core resolves an omitted user scope as `defaulted`
WHEN the presentation layer renders the resulting card and readback
THEN the snapshot SHALL carry `scope_origin=defaulted`
AND the presentation layer SHALL NOT infer the scope origin from display strings.

#### Scenario: Proof class cannot be upgraded by display copy

GIVEN a snapshot proof class is `docs_local` or `local_static_contract`
WHEN the presentation layer renders status copy
THEN it SHALL NOT display runtime-ready, endpoint-ready, voice-ready, model-ready, golden-ready, mobile-ready, true-device-ready, C6-ready, V-PASS, S-PASS, or U-PASS claims.

#### Scenario: Timeout terminates the turn

GIVEN runtime exceeds its configured interaction timeout
WHEN the bridge emits the final snapshot for that turn
THEN the bridge result SHALL be `runtime_error`
AND the snapshot SHALL be terminal for the turn.

### Requirement: Dispatch readiness without runtime proof

The system SHALL allow UIUE R5 to update only to dispatch readiness after the mainline bridge owner receipt/carrier lands, while preserving all downstream proof-class gates.

#### Scenario: R5 readiness is capped after carrier acceptance

GIVEN this mainline bridge carrier validates
WHEN UIUE updates its R5 readiness note
THEN UIUE MAY move at most to `R5_PRECONDITIONS_READY_WITH_NOTES`
AND it SHALL NOT claim runtime-ready, mobile proof, true-device proof, voice-ready, model-ready, golden-ready, endpoint-ready, UIUE merge, V-PASS, S-PASS, or U-PASS.

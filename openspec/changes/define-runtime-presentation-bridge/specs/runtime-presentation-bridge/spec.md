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

#### Scenario: Tool-call source maps to accepted bridge result

GIVEN an existing C6/C5 behavior source class is `tool_call`
WHEN the bridge emits a presentation runtime result
THEN the bridge result SHALL be `accepted_tool_call`
AND it SHALL preserve `tool_call` as source metadata rather than renaming the upstream behavior class.

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

#### Scenario: Guard denial terminates as presentation-safe refusal

GIVEN runtime guard logic denies an action for safety, policy, or allowlist reasons
WHEN the bridge emits the final snapshot for that turn
THEN the bridge result SHALL be `refusal_safety_or_policy`
AND the snapshot SHALL be terminal for the turn
AND the snapshot SHALL carry trace identity, finite proof class, and a safe machine-readable reason without raw model output, training receipts, or raw runtime store references.

#### Scenario: Thrown adapter failure terminates as runtime error

GIVEN runtime or adapter execution throws after trace identity exists
WHEN the bridge emits the final snapshot for that turn
THEN the bridge result SHALL be `runtime_error`
AND the snapshot SHALL be terminal for the turn
AND it SHALL carry trace identity, finite proof class, and a safe machine-readable reason instead of failing silently.

#### Scenario: Partial accept/refuse terminates with composite presentation state

GIVEN a turn has at least one accepted effect and at least one refused effect
WHEN the bridge emits the final snapshot for that turn
THEN the snapshot SHALL be terminal for the turn
AND it SHALL carry the accepted readbacks plus mixed card presentation state for accepted and refused effects.

#### Scenario: Cancel, interruption, timeout, and backgrounding all terminate

GIVEN a turn is cancelled, interrupted, times out, or is interrupted by app backgrounding
WHEN the bridge emits the final snapshot for that turn
THEN the snapshot SHALL be terminal for the turn
AND it SHALL carry trace identity, finite proof class, result class, and stop reason metadata.

#### Scenario: Timeout is a terminal stop result, not a user event kind

GIVEN runtime detects an interaction timeout
WHEN the bridge represents the timeout for presentation
THEN timeout SHALL be carried as a terminal stop/result outcome
AND it SHALL NOT require adding `timeout` to the user interaction event kind set.

#### Scenario: Event provenance and scope resolution remain separate

GIVEN a user interaction event starts a turn
WHEN runtime and presentation state are represented by the bridge
THEN the event MAY carry source/provenance metadata
AND resolved scope origin SHALL remain on snapshot, readback, or outcome metadata instead of being inferred from the event payload.

#### Scenario: Trace envelope is presentation-safe and append-only by construction

GIVEN trace entries are exposed through a presentation snapshot
WHEN the bridge creates a presentation-safe trace envelope
THEN messages SHALL redact raw model output, training receipt, and raw runtime store markers
AND appending entries SHALL require matching trace identity and monotonic timestamps.

#### Scenario: Card ordering and semantics are machine-readable

GIVEN accepted and refused effects both affect presentation cards
WHEN the bridge orders and annotates cards for presentation
THEN refused or unsafe card states SHALL be able to outrank satisfied card states
AND active, sibling, reason, role, and scope-origin semantics SHALL be machine-readable rather than UI-only copy.

### Requirement: Dispatch readiness without runtime proof

The system SHALL allow UIUE R5 to update only to dispatch readiness after the mainline bridge owner receipt/carrier lands, while preserving all downstream proof-class gates.

#### Scenario: R5 readiness is capped after carrier acceptance

GIVEN this mainline bridge carrier validates
WHEN UIUE updates its R5 readiness note
THEN UIUE MAY move at most to `R5_PRECONDITIONS_READY_WITH_NOTES`
AND it SHALL NOT claim runtime-ready, mobile proof, true-device proof, voice-ready, model-ready, golden-ready, endpoint-ready, UIUE merge, V-PASS, S-PASS, or U-PASS.

### Requirement: Main-owned presentation payload contract

The system SHALL define Runtime -> Presentation payload fields in mainline authority before any future UIUE runtime consumer uses them. The payload contract SHALL expose only presentation-safe, adapter-agnostic fields for envelope identity, outcome, cards, readbacks, reconciliation, proof class, and presentation-safe trace.

#### Scenario: Payload envelope has finite compatibility identity

GIVEN runtime produces a presentation handoff
WHEN the bridge emits the payload
THEN the payload SHALL carry a finite schema version
AND it SHALL carry trace identity and presentation turn or event identity
AND it SHALL carry whether the payload is terminal for the turn.

#### Scenario: Payload outcome is stable and presentation-safe

GIVEN runtime emits any accepted, refused, no-op, stop, or error outcome
WHEN the bridge serializes that outcome for presentation
THEN the payload SHALL carry a stable result or outcome class
AND it SHALL carry only safe reason or mismatch classes
AND it SHALL NOT expose raw model output, raw runtime store data, or training receipts.

#### Scenario: Payload card fields are machine-readable

GIVEN presentation cards are included in the Runtime -> Presentation payload
WHEN a future consumer reads the payload
THEN each card SHALL expose machine-readable card identity and semantics such as family or key, role, active state, sibling relationship, reason, and scope origin when available
AND those fields SHALL NOT require the consumer to parse display copy.

#### Scenario: Payload readbacks are stable presentation fields

GIVEN runtime has verified or attempted readback state
WHEN the bridge emits readbacks for presentation
THEN each readback SHALL expose presentation-safe key, actual value, revision, spoken text when available, and scope origin when available
AND it SHALL NOT expose raw runtime store objects or adapter ledger rows.

#### Scenario: Reconciliation is status, not ledger exposure

GIVEN adapter or C3 execution performed readback reconciliation
WHEN the bridge emits presentation reconciliation state
THEN the payload SHALL expose only presentation-safe reconciliation status or mismatch class
AND it SHALL NOT expose `requestFingerprint`, `parentRequestFingerprint`, `failureLedger`, success ledger internals, failure ledger internals, or settled parent-plan internals.

#### Scenario: UIUE cannot invent shared payload fields

GIVEN UIUE needs to consume Runtime -> Presentation data in a later dispatch
WHEN UIUE defines consumer code or tests
THEN UIUE SHALL consume only fields defined by this mainline contract or a later mainline contract
AND it SHALL NOT infer shared fields from UIUE docs, adapter private names, receipts, or local test helper names.

#### Scenario: Adapter-private names are forbidden in encoded payload

GIVEN the bridge encodes a presentation payload
WHEN the encoded payload is inspected as text
THEN it SHALL NOT contain `DemoRuntimeAdapter`, `RuntimeAdapterBox`, `requestFingerprint`, `parentRequestFingerprint`, `failureLedger`, raw ledger internals, settled parent-plan internals, raw runtime store markers, raw model output markers, or training receipt markers except in negative tests or forbidden-field documentation.

#### Scenario: Payload proof class remains capped

GIVEN D15 payload contract validation passes locally
WHEN documentation, UI copy, or future consumers describe the proof
THEN they SHALL cap proof at docs/local, local_static, local_unit, OpenSpec, GitNexus, Codex subagent verifier, and anchored Hermes verifier only when present
AND they SHALL NOT claim runtime-ready, mobile proof, true-device proof, live API proof, UIUE merge, V-PASS, S-PASS, U-PASS, A-2 readiness, voice-ready, model-ready, golden-ready, or endpoint-ready.

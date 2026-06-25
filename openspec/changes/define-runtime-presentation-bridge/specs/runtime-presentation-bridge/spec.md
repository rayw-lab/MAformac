## ADDED Requirements

### Requirement: Presentation Snapshot Contract

The system SHALL expose a presentation snapshot that contains card state, dialog text, readbacks, scope origin, trace identity, voice state, orb state, context scene, and finite-enum proof class, without requiring presentation code to read raw runtime stores.

#### Scenario: Default scope is visible but not re-inferred

- **GIVEN** Core resolves an omitted user scope as `defaulted`
- **WHEN** the presentation layer renders the resulting card and readback
- **THEN** the snapshot SHALL carry `scope_origin=defaulted`
- **AND** the presentation layer SHALL NOT infer the scope origin from display strings.

#### Scenario: Value provenance is separate from scope resolution

- **GIVEN** a value set by a touch control
- **WHEN** the snapshot carries provenance and scope metadata
- **THEN** `source` SHALL describe who set the value (for example `ui_touch`)
- **AND** `scope_origin` SHALL describe how scope was resolved (for example `defaulted`)
- **AND** the two SHALL NOT be merged into one field.

### Requirement: Runtime Result Vocabulary

The system SHALL classify runtime results as `accepted_tool_call`, `clarify_missing_slot`, `refusal_no_available_tool`, `refusal_safety_or_policy`, `already_state_noop`, `runtime_error`, `cancelled`, or `partial_accept_partial_refuse` before the presentation layer renders the result.

#### Scenario: Already-state result is not unsupported

- **GIVEN** a user asks for a state that is already satisfied
- **WHEN** runtime produces no state mutation
- **THEN** the result SHALL be `already_state_noop`
- **AND** it SHALL NOT be reported as unsupported or safety refusal
- **AND** the snapshot SHALL NOT increment the cell revision.

#### Scenario: Unsupported and safety refusals remain distinct

- **GIVEN** runtime cannot map a request to an available demo tool
- **WHEN** the presentation layer renders the refusal
- **THEN** the result SHALL be `refusal_no_available_tool`
- **AND** it SHALL NOT be collapsed into `refusal_safety_or_policy` or a bare `rejected` value.

#### Scenario: Mixed outcome is one combined snapshot

- **GIVEN** a turn requests two actions where one is accepted and one is safety-refused
- **WHEN** the bridge emits the terminal snapshot for that turn
- **THEN** the result SHALL be `partial_accept_partial_refuse`
- **AND** the snapshot SHALL carry per-action outcomes for each affected card
- **AND** the snapshot SHALL carry one composite readback.

#### Scenario: Proof class cannot be upgraded by display copy

- **GIVEN** a snapshot proof class is a local/static contract class
- **WHEN** the presentation layer renders status copy
- **THEN** it SHALL NOT display endpoint-ready, voice-ready, C6-ready, V-PASS, S-PASS, or U-PASS claims.

#### Scenario: Timeout terminates as runtime error

- **GIVEN** runtime exceeds its configured interaction timeout
- **WHEN** the bridge emits the final snapshot for that turn
- **THEN** the result SHALL be `runtime_error`
- **AND** the snapshot SHALL be terminal for the turn.

### Requirement: Active and Refused Cell Carriage

The snapshot SHALL identify, per turn, the active cell that changed or is focused, and for refusals the refused cell, each distinct from a family's summary primary cell, so presentation can surface the cell that actually changed or was denied.

#### Scenario: Changed non-primary cell is surfaced

- **GIVEN** a scene macro changes a family's non-primary cell while its primary cell is unchanged
- **WHEN** the presentation layer renders that family's card in a changing state
- **THEN** the snapshot SHALL carry the changed cell as the active cell
- **AND** the presentation layer SHALL be able to surface the active cell rather than the unchanged primary cell.

#### Scenario: Refused non-primary cell is surfaced

- **GIVEN** a safety refusal denies a family's non-primary cell while its primary cell is unchanged
- **WHEN** the presentation layer renders that family's card in an unsafe state
- **THEN** the snapshot SHALL carry the denied cell as the refused cell
- **AND** the presentation layer SHALL be able to surface the refused cell with the refusal reason.

### Requirement: Sibling Cell Carriage for Semantic Styling

A snapshot card SHALL be able to carry the family's styling-relevant sibling cells alongside its displayed cell, so semantic styling that depends on a sibling cell can render from the snapshot alone.

#### Scenario: Cooling and heating styling reads a sibling cell

- **GIVEN** a climate card displays a temperature value
- **AND** the family's mode cell indicates cooling or heating
- **WHEN** the presentation layer renders the temperature with semantic color
- **THEN** the snapshot card SHALL carry the mode sibling cell
- **AND** the presentation layer SHALL NOT need to read a raw store to obtain the mode.

### Requirement: Event-Driven Thinking Gates

The bridge SHALL expose event-driven gates for thinking choreography rather than fixed visual delays, and SHALL distinguish backend-masking thinking from a legitimate fixed safety display.

#### Scenario: Analyzing think ends on a runtime event

- **GIVEN** the runtime is performing backend work behind an analyzing thinking display
- **WHEN** the backend begins changing cards
- **THEN** a `cards_did_start_changing` gate SHALL signal handoff
- **AND** the analyzing thinking display SHALL end on that gate rather than on a fixed timer.

#### Scenario: Safety-refusal think is a legitimate fixed display

- **GIVEN** a safety refusal turn
- **WHEN** the thinking display is shown before the refusal readback
- **THEN** the bridge SHALL permit a fixed short safety-refusal thinking display
- **AND** the event-driven gate policy SHALL NOT remove this fixed display.

### Requirement: Demo-Mode Force-Context Input

Demo-mode force-state context input SHALL mutate runtime context through a bridge event with traceable provenance, SHALL be isolated from customer-facing builds, and SHALL expose context as distinct vehicle and environment dimensions for a presentation context surface.

#### Scenario: Forced driving context has traceable provenance

- **GIVEN** a demo operator forces a driving context
- **WHEN** the safety guard later reads vehicle speed for a refusal decision
- **THEN** the forced context SHALL have arrived through a bridge force-context event
- **AND** the vehicle speed SHALL NOT be rendered as a controllable device card.

#### Scenario: Context is exposed as distinct dimensions for compositing

- **GIVEN** a demo operator forces a night, raining, driving context
- **WHEN** the presentation context surface renders the resulting scene
- **THEN** the snapshot SHALL expose the vehicle and environment context as distinct dimensions (speed, gear, weather, time period)
- **AND** the presentation layer SHALL be able to composite those dimensions into one scene
- **AND** the snapshot SHALL NOT collapse them into a single pre-resolved scene name that hides the individual dimensions.

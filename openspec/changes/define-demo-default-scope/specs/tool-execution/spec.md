## ADDED Requirements

### Requirement: Omitted scope SHALL resolve through C2 default_scope

When a tool call omits a scoped slot such as `position`, `direction`, `screen_type`, or `name`, the execution layer SHALL resolve the target through the C2 state cell's `default_scope`.

#### Scenario: Omitted window scope defaults to driver window

- **GIVEN** `window.position` has `default_scope=主驾`
- **WHEN** the user says "打开车窗"
- **THEN** execution targets `window.position[主驾]`
- **AND** execution SHALL NOT fan out to all window cells.

#### Scenario: Explicit passenger scope remains explicit

- **WHEN** the user says "副驾车窗开一半"
- **THEN** execution targets `window.position[副驾]`
- **AND** execution SHALL NOT replace the explicit scope with `default_scope`.

#### Scenario: Explicit all-window request fans out

- **WHEN** the user says "关上所有车窗"
- **THEN** `所有车窗` maps through an accepted collection alias to `position=全车`
- **AND** execution targets every supported `window.position[...]` scope in C2.

#### Scenario: Unaccepted collection-like wording does not silently default

- **WHEN** the user uses collection-like wording that is not in the accepted alias set for that cell
- **THEN** the system rejects, clarifies, or routes to slow-path resolution with evidence
- **AND** it SHALL NOT silently apply the cell's `default_scope`
- **AND** it SHALL NOT silently fan out.

### Requirement: Scope origin SHALL be available to presentation

The system SHALL make scope origin available to readback and UIUE presentation as `defaulted`, `explicit`, or `fanout`, together with the resolved scope and a presentation policy. Scope origin SHALL be produced once during target resolution and propagated as structured metadata; downstream channels SHALL NOT infer it independently from localized strings or rendered text.

#### Scenario: Default scope is not interruption-heavy

- **GIVEN** a defaulted driver window action
- **WHEN** the system renders customer-facing text
- **THEN** it SHALL NOT ask a driver/passenger clarification
- **AND** it MAY render "主驾" as low-emphasis, compact, or elided according to channel policy
- **AND** internal state assertions SHALL still use `window.position[主驾]`.

#### Scenario: Fan-out presentation preserves fan-out origin

- **GIVEN** an explicit all-window action
- **WHEN** the system renders customer-facing presentation metadata
- **THEN** `scope_origin` is `fanout`
- **AND** `resolved_scope` identifies the collection scope such as `全车`
- **AND** backend state remains per-cell.

#### Scenario: Explicit driver scope is not rewritten as defaulted scope

- **WHEN** the user explicitly says "打开主驾车窗"
- **THEN** execution targets `window.position[主驾]`
- **AND** `scope_origin` is `explicit`
- **AND** channel renderers SHALL NOT treat this as an omitted/defaulted scope.

### Requirement: Omitted scope SHALL compose with clarifyTag routing

Omitted scope is a target-resolution concern after a candidate exists. It SHALL NOT flatten the route-tier decision.

#### Scenario: Fast-path omitted scope

- **GIVEN** an accepted fast-path command with omitted scope, such as "打开车窗"
- **WHEN** the tool call omits `position`
- **THEN** C3 resolves the target through C2 `default_scope`
- **AND** the system SHALL NOT ask whether the user meant driver or passenger.

#### Scenario: Slow-path omitted scope

- **GIVEN** a `clarify_tag=implicit` utterance routed through Qwen+LoRA
- **WHEN** the accepted D-domain tool call omits a scope slot
- **THEN** C3 resolves the target through C2 `default_scope`
- **AND** the slow path does not invent a second defaulting policy.

#### Scenario: Ambiguous route does not default silently

- **GIVEN** a `clarify_tag=ambiguous` utterance or unsupported scope wording
- **WHEN** no accepted executable candidate exists
- **THEN** the system clarifies or rejects
- **AND** it SHALL NOT use `default_scope` to bypass route ambiguity.

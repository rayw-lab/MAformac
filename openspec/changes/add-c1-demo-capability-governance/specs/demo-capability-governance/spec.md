## ADDED Requirements

### Requirement: DemoCapabilityMatrix SHALL preserve auditable 120-cell truth

The system SHALL maintain exactly 120 stable capability cells. Each cell SHALL carry machine-readable identity, family, value shape, register, representative semantic action or explicit no-representative marker, mounted status, `primary_class`, default and conditional path status, entrypoint aliases, `canDemo`, same-cell `canDemo` basis, fallback classification, customer-safe reason reference and evidence anchors.

Coverage: CG-002, CG-004, CG-005, CG-007, CG-008, CG-009, CG-014, CG-015, CG-019, CG-063, CG-065.

`primary_class` SHALL be one of `safety_or_clarify_reject`, `unmounted_name_rejected`, `fast_path_no_match_fallback`, `default_executable`, or `conditional_ddomain_executable`. It SHALL explain classification and SHALL NOT by itself prove default runtime execution.

`canDemo=true` SHALL require mounted or explicitly approved action evidence, semantic-contract evidence, state/readback-cell evidence, and local runtime emission, execution and readback proof for the same cell. Matrix data SHALL be derived from mounted authority and SHALL NOT add a mounted action. FastPath aliases and conditional injected proof SHALL NOT independently promote `canDemo`.

#### Scenario: Missing basis blocks eligibility

- **GIVEN** a cell lacks any required same-cell `canDemo` basis
- **WHEN** matrix eligibility is computed
- **THEN** `canDemo` SHALL be false
- **AND** validation SHALL report the missing basis instead of applying a prose or alias exception.

#### Scenario: Semantic but unmounted cell remains visible

- **GIVEN** a cell has a representative semantic action
- **AND** that action is not mounted or explicitly approved
- **WHEN** the matrix is published
- **THEN** the cell SHALL remain visible as `unmounted_name_rejected`
- **AND** it SHALL NOT be hidden, executed or promoted by a FastPath hit.

#### Scenario: No-representative cells preserve the account

- **GIVEN** a cell has no representative semantic action
- **WHEN** matrix conservation is checked
- **THEN** it SHALL remain in the 120-cell account
- **AND** it SHALL carry `no_representative_tool__default_fallback`.

#### Scenario: Conditional proof is not default proof

- **GIVEN** a cell can be exercised only through an injected or conditional lane
- **WHEN** default demo eligibility is computed
- **THEN** the conditional evidence SHALL be recorded separately
- **AND** the cell SHALL NOT become default `canDemo=true` until all four default evidence classes pass.

#### Scenario: Fallback is not reported as rejection success

- **GIVEN** a cell is classified `fast_path_no_match_fallback`
- **WHEN** capability status is reported
- **THEN** it SHALL be reported as fallback/no available tool
- **AND** it SHALL NOT be reported as semantic rejection success or successful execution.

### Requirement: Governance enums and projections SHALL be closed

The system SHALL reject unknown or free-string values for `primary_class`, fallback classification, internal `finiteReason`, `fallback_reason`, and customer-safe `reasonKind`. The governance fallback classification SHALL be one of `safety_or_clarify_reject`, `unmounted_name_rejected`, `fast_path_no_match_fallback`, or `unknown_no_representative_entry`. Internal `finiteReason` SHALL be exactly one of `safety_or_policy_refusal`, `clarify_missing_slot`, `unmounted_tool_name`, `name_rejected`, `fast_path_no_match`, `unsupported_tool_plan`, `no_representative_tool`, `runtime_execution_error`, `stale_state_revision`, or `already_state_noop`; `partial_accept_partial_refuse` is a bridge result wrapper and SHALL NOT be admitted as `finiteReason`.

Coverage: CG-005, CG-022, CG-023, CG-024, CG-025, CG-038, CG-039, CG-068, CG-074.

The mapping SHALL preserve these meanings:

- safety/policy denial: internal `safety_or_policy_refusal` → `safety_policy_refused` → safe `safety_policy`;
- missing or ambiguous required slot: internal `clarify_missing_slot` → `clarify_missing_slot` → safe `clarification_required`;
- attributable name rejection for a semantic but unmounted action: internal `unmounted_tool_name` or `name_rejected` → `unmounted_name_rejected` → safe `capability_not_mounted`;
- FastPath miss or unsupported plan: internal `fast_path_no_match` or `unsupported_tool_plan` → `unsupported_no_available_tool` → safe `not_available_in_demo`;
- no representative action: internal `no_representative_tool` → `no_representative_tool__default_fallback` → safe `not_available_in_demo`;
- typed runtime execution error: internal `runtime_execution_error` → `runtime_error_typed` → safe `runtime_unavailable`;
- stale-state gate refusal: internal `stale_state_revision` → `runtime_error_typed` → safe `runtime_unavailable`;
- already-satisfied state: internal `already_state_noop` → `already_state_noop` → safe `already_done`.

The governance mapping SHALL NOT define public payload field names or schema versions. Public results and encoded projection remain bridge-owned.

#### Scenario: Unknown enum fails closed

- **GIVEN** a matrix, catalog or execution classification contains a value outside the closed enums
- **WHEN** governance validation runs
- **THEN** validation SHALL fail
- **AND** the value SHALL NOT be converted to generic fallback, success or display copy.

#### Scenario: Unknown finiteReason fails before projection

- **GIVEN** execution supplies an internal `finiteReason` outside the exact closed membership
- **WHEN** the governance projection is validated
- **THEN** validation SHALL fail before fallback, safe `reasonKind`, or bridge result projection
- **AND** the value SHALL NOT be accepted as an alias or converted to generic `runtime_error`.

#### Scenario: Name rejection preserves mounted context

- **GIVEN** a semantic action is attributable to a family
- **AND** mounted authority does not contain the action
- **WHEN** a `name_rejected` fact is classified
- **THEN** governance SHALL map it to `unmounted_name_rejected`
- **AND** it SHALL NOT generalize it to an unqualified “unsupported” meaning.

#### Scenario: Clarification is not refusal

- **GIVEN** the only blocker is a missing or ambiguous required slot
- **WHEN** the outcome is classified
- **THEN** it SHALL remain `clarify_missing_slot` with safe `clarification_required`
- **AND** it SHALL NOT be labeled as safety or unsupported refusal.

#### Scenario: Raw finite reason stays internal

- **GIVEN** execution retains a raw `finiteReason`
- **WHEN** a customer-visible reason is requested
- **THEN** only the mapped safe `reasonKind` and family-safe copy SHALL be eligible for presentation
- **AND** governance SHALL defer public field and redaction semantics to the bridge.

### Requirement: Safety refusal SHALL remain an SSOT typed gap until runner closure

Governance SHALL register safety refusal as an SSOT classification with internal `safety_or_policy_refusal`, `safety_policy_refused`, and safe `safety_policy`. Until the C3 runner emits and preserves that typed execution fact, this carrier SHALL label the runner integration boundary `typed_gap`; it SHALL NOT claim that the runner is already closed or substitute untyped refusal/success.

Coverage: CG-024.

#### Scenario: Safety refusal remains typed and non-claimed

- **GIVEN** a safety or policy gate refuses a reviewed action
- **WHEN** C1 evaluates the contract before the runner implementation slice
- **THEN** the refusal SHALL remain an SSOT typed fact with the locked projection
- **AND** the unimplemented runner boundary SHALL remain `typed_gap`
- **AND** the carrier SHALL NOT claim runtime closure from this specification alone.

### Requirement: Fallback catalog SHALL have complete family-aware coverage

The system SHALL maintain one authoritative fallback script source and a deterministic derived catalog. It SHALL cover all 10 agreed families across all four governance fallback classifications, for 40 distinct family/reason pairs. Missing or duplicate pairs, copy drift, forbidden generic leakage, or absent customer-safe dialog/TTS text SHALL fail validation.

Coverage: CG-026, CG-027, CG-028, CG-041, CG-059.

UI badge text SHALL be only a short label. It SHALL NOT replace authoritative dialog or TTS text. In-scope execution pass rate and out-of-scope fallback quality/generic leakage SHALL be reported as separate metrics.

#### Scenario: Missing family/reason pair blocks publication

- **GIVEN** any required family/reason pair lacks catalog copy or a derived entry
- **WHEN** fallback coverage is validated
- **THEN** validation SHALL fail
- **AND** the catalog SHALL NOT be reported complete.

#### Scenario: Generated catalog drift fails closed

- **GIVEN** the derived catalog differs from the authoritative source in family, reason, safe kind or customer copy
- **WHEN** source-to-generated drift is checked
- **THEN** validation SHALL fail
- **AND** runtime SHALL NOT publish the drifting entry.

#### Scenario: UI badge cannot substitute for dialog and TTS

- **GIVEN** a fallback entry has only badge text
- **WHEN** dialog or speech feedback is required
- **THEN** the entry SHALL be incomplete
- **AND** the system SHALL NOT claim fallback copy coverage.

#### Scenario: New mounted family retains fallback coverage

- **GIVEN** a later authorized change adds a mounted family
- **WHEN** its expansion package is validated
- **THEN** corresponding family-aware fallback copy SHALL be present
- **AND** edge utterances SHALL NOT fall back to an untyped generic sentence.

### Requirement: CG-036 governance SHALL preserve accepted and refused subactions

The system SHALL permit a bounded reviewed turn to contain both accepted and refused subactions. Each accepted subaction SHALL have execution and mock-state readback evidence. Each refused subaction SHALL have a typed internal reason, SHALL NOT execute, and SHALL NOT mutate state. Governance SHALL require both the `tool-execution` execution facts and the existing bridge’s composite presentation projection; it SHALL NOT replace either owner.

Coverage: CG-036, CG-038, CG-074, CG-076.

#### Scenario: One accepted and one unmounted subaction

- **GIVEN** one reviewed subaction satisfies all execution gates
- **AND** another reviewed subaction maps to an unmounted semantic action
- **WHEN** the turn completes
- **THEN** the accepted subaction SHALL execute and produce readback
- **AND** the unmounted subaction SHALL not execute or mutate state
- **AND** the turn SHALL carry accepted/refused facts for bridge projection.

#### Scenario: Guard failure is typed instead of crashing

- **GIVEN** a reviewed subaction fails a safety, clarify or execution guard
- **WHEN** the bounded turn is processed
- **THEN** that subaction SHALL remain a typed refused or clarify fact
- **AND** it SHALL NOT crash, disappear or be rewritten as untyped success.

#### Scenario: Partial closure requires both owners

- **GIVEN** execution facts exist without bridge projection, or bridge fixtures exist without runtime execution facts
- **WHEN** CG-036 completion is evaluated
- **THEN** governance SHALL report the requirement incomplete
- **AND** neither half SHALL be accepted as end-to-end partial-result proof.

### Requirement: Fallback and refusal probes SHALL prove no unintended action

Every required family/reason probe SHALL derive no-action proof from canonical before/after mock-state comparison and observed tool-call count. Pure fallback, refusal and clarification paths SHALL have identical before/after state, zero observed tool calls, trace identity, typed reason, safe reason reference and speech/dialog evidence.

Coverage: CG-044, CG-076.

#### Scenario: Pure fallback has no mutation

- **GIVEN** a turn contains no accepted subaction
- **WHEN** its fallback probe completes
- **THEN** canonical before and after state SHALL be identical
- **AND** observed tool-call count SHALL be zero
- **AND** the receipt SHALL derive `state_mutation=false` from those observations.

#### Scenario: Hidden action invalidates the receipt

- **GIVEN** a probe reports fallback or refusal
- **AND** state comparison or observed calls show an action occurred
- **WHEN** the receipt is validated
- **THEN** validation SHALL fail
- **AND** the turn SHALL NOT be reported as safe no-action fallback.

### Requirement: Expansion governance SHALL preserve prelay and mounted red lines

The system SHALL allow matrix, fallback and probe prelay without authorizing mounted expansion. Expansion eligibility SHALL use `joint_strike_rate = min(hedged_strike_rate, can_question_strike_rate)` and the ratified tiers. A missing joint rate, failed fallback-quality gate, missing matrix row, missing readback/golden evidence or missing owner key SHALL block new mounted actions and new `canDemo=true` cells.

Coverage: CG-045, CG-048, CG-049, CG-050, CG-053, CG-054, CG-055, CG-057, CG-058, CG-060, CG-080.

Expansion above the highest tier SHALL mean at most one primary cell per agreed family, not all semantic actions or all matrix cells. A mounted delta SHALL have a same-batch or already-planned matrix row with green checker evidence. Each newly mounted family SHALL add its primary golden case. Rollback SHALL revert mounted delta, downgrade affected `canDemo`, and preserve fallback coverage.

#### Scenario: Low joint rate permits prelay only

- **GIVEN** either component rate causes joint rate to remain below the expansion threshold
- **WHEN** governance evaluates prepared matrix, fallback and probe artifacts
- **THEN** those artifacts MAY remain prelay
- **AND** no mounted action or `canDemo=true` cell SHALL be added.

#### Scenario: CG-048 asymmetric joint-rate fixture blocks expansion

- **GIVEN** `hedged_strike_rate=0.90` and `can_question_strike_rate=0.35`
- **WHEN** expansion eligibility computes the ratified formula
- **THEN** `joint_strike_rate=0.35`
- **AND** governance SHALL NOT authorize expansion, a mounted action, or a new `canDemo=true` cell.

#### Scenario: CG-049 converse asymmetric joint-rate fixture blocks expansion

- **GIVEN** `hedged_strike_rate=0.35` and `can_question_strike_rate=0.90`
- **WHEN** expansion eligibility computes the ratified formula
- **THEN** `joint_strike_rate=0.35`
- **AND** governance SHALL NOT authorize expansion, a mounted action, or a new `canDemo=true` cell.

#### Scenario: Missing joint rate blocks expansion

- **GIVEN** S10 evidence omits `joint_strike_rate`
- **WHEN** expansion eligibility is evaluated
- **THEN** the result SHALL be blocked
- **AND** prose or another pass rate SHALL NOT substitute for the missing field.

#### Scenario: Mounted delta requires matrix and golden evidence

- **GIVEN** a later change proposes a mounted family delta
- **WHEN** its expansion package is validated
- **THEN** a same-batch or pre-existing planned matrix row with green checker evidence SHALL exist
- **AND** the family primary cell SHALL have a golden case and readback evidence.

#### Scenario: Failed rollout preserves fallback

- **GIVEN** a newly authorized mounted family later fails golden or readback validation
- **WHEN** rollback executes
- **THEN** its mounted delta SHALL be reverted
- **AND** affected matrix `canDemo` SHALL be downgraded
- **AND** its fallback catalog and probes SHALL remain available.

#### Scenario: C1 cannot authorize mounted one-to-many expansion

- **GIVEN** this governance capability and all prelay artifacts validate
- **WHEN** C1 status is reported
- **THEN** validation SHALL NOT authorize mounted 1→N
- **AND** later S10, matrix/readback, batch-owner and explicit approval gates SHALL remain required.

### Requirement: Demo proof SHALL remain offline, mock-only and readback-bound

The system SHALL operate without network dependency for this demo path. Vehicle actions SHALL affect only mock state, and an action SHALL be reported successful only after the expected mock state is read back. Fallback, refusal, pending, error and readback mismatch SHALL NOT be presented as completed action.

#### Scenario: Offline mock action succeeds only after readback

- **GIVEN** a reviewed action is permitted by governance and execution gates
- **WHEN** it runs without network access
- **THEN** only mock state SHALL be changed
- **AND** success SHALL be emitted only after matching mock-state readback.

#### Scenario: Error does not impersonate success

- **GIVEN** execution is pending, refused, failed, unknown or readback-mismatched
- **WHEN** outcome status is produced
- **THEN** the system SHALL NOT report the action as completed
- **AND** it SHALL preserve the applicable typed non-success outcome.

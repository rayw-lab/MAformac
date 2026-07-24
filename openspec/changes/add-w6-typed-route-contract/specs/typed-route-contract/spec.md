## ADDED Requirements

### Requirement: Typed route/model contract SHALL use closed types with three independent axes

The typed route/model contract SHALL expose `exec_tier`, `outcome`, and `clarify_tag` as three independent closed enums. The three axes SHALL NOT be collapsed, aliased, or derived from each other; each enum SHALL be total (`unknown` value fails closed at decode time).

The axis alphabets SHALL be:
- `exec_tier` ∈ {`L1`, `L2`, `L3`, `L4`, `L5`}, anchored to `docs/srd-three-layer-intent-routing.md:40-49` §1.2 five-layer intent model.
- `outcome` ∈ {`candidate`, `clarify`, `reject`, `fallback`} — orthogonal to exec_tier; represents routing verdict axis.
- `clarify_tag` ∈ {`explicit`, `implicit`} — strict 1:1 correspondence to `contracts/semantic-function-contract.jsonl` row-level `clarify_tag` field (live head-2 sample confirmed `implicit`; live grep confirmed `explicit` on `c1_carControl_000006`). Any additional routing state (ambiguous / rejected / passthrough — see `docs/srd-three-layer-intent-routing.md` §1.3) SHALL be expressed on the independent `outcome` axis or via `RouteError`, NOT by widening the `clarify_tag` alphabet.

#### Scenario: Independent-axis positive combination

- **GIVEN** a candidate route decision where `exec_tier=L1`, `outcome=candidate`, `clarify_tag=explicit`
- **WHEN** the total validator inspects the result
- **THEN** it SHALL accept the three-axis combination
- **AND** SHALL NOT infer any additional axis value from another axis.

#### Scenario: Unknown enum fails closed

- **GIVEN** a serialized route result whose `exec_tier` field is `"L9"` (not in the closed alphabet)
- **WHEN** decoding runs through the total validator
- **THEN** decoding SHALL fail with `RouteError.unknownEnum("exec_tier")`
- **AND** the result SHALL NOT silently degrade to a default tier or `.fallback` outcome.

#### Scenario: clarify_tag alphabet is not widened

- **GIVEN** a serialized route result whose `clarify_tag` field is `"ambiguous"` (a runtime state from `docs/srd-three-layer-intent-routing.md` §1.3 that is NOT a `contracts/semantic-function-contract.jsonl` `clarify_tag` value)
- **WHEN** the validator inspects it
- **THEN** it SHALL fail with `RouteError.unknownEnum("clarify_tag")`
- **AND** the correct expression path SHALL be `outcome=clarify` with an independent clarification reason.

### Requirement: Route result MUST carry the minimum wire fields

Every `RouteResult` payload SHALL carry, at minimum:
`schema_version` (const `typed_route_contract.v1`), `route_schema` (canonical routing schema identifier), `turn_id`, `trace_id`, `exec_tier`, `outcome`, `clarify_tag`, `service` (∈ {`airControl`, `carControl`, `cmd`}), `action_candidate?`, `trace_digest`, `rejection_reason?`.

Session ID, event ID, and sequence number SHALL NOT be part of the `RouteResult` ontology; they belong to the T04a / W5a pending-correlation record as documented in `openspec/changes/add-t04a-customer-ingress/design.md:7-11` and are joined outside this contract.

#### Scenario: Candidate outcome carries action_candidate

- **GIVEN** `outcome=candidate`
- **WHEN** the validator runs
- **THEN** `action_candidate` SHALL be present and structurally valid
- **AND** `rejection_reason` SHALL be absent.

#### Scenario: Reject outcome carries rejection_reason

- **GIVEN** `outcome=reject`
- **WHEN** the validator runs
- **THEN** `rejection_reason` SHALL be present as a closed `RouteError`
- **AND** `action_candidate` SHALL be absent.

#### Scenario: Session identity leaks are forbidden

- **GIVEN** a serialized route result that carries a `session_id` field
- **WHEN** the validator runs
- **THEN** decoding SHALL fail with `RouteError.payloadInvalid("session_id must not appear in RouteResult ontology")`
- **AND** the writer SHALL emit no route result with `session_id` embedded.

### Requirement: action_candidate SHALL bind to a mounted D-domain tool name and never claim action success

`ActionCandidate.mounted_tool_name` SHALL name a tool present in `Core/Contracts/DDomainMountedToolCatalog.swift:12-14` `mountedToolNames`. A candidate that names a tool NOT in that set SHALL be rejected with `RouteError.unmountedName(tool: <name>)`.

Presence of an `action_candidate` in a `RouteResult` SHALL NOT constitute action proof (承接 `docs/commander-log/decisions.md` D-137 `actionDemoProven=0/120`). Downstream consumers SHALL only treat it as a proposal awaiting the ToolCall + guard chain (see `openspec/specs/tool-execution/spec.md:5-11` for the existing candidate-vs-action separation).

`ActionCandidate` fields SHALL be named strictly after `contracts/semantic-function-contract.jsonl` fields, verbatim:
`intent`, `service`, `mounted_tool_name`, `action_primitive`, `action_code`, `device`, `slot`, `slot_keys`, `value{ref, direct, offset, type}`. No near-synonyms (e.g. `intentName`, `reference`, `magnitude`, `kind`) SHALL be introduced.

#### Scenario: Unmounted tool name is rejected

- **GIVEN** an `ActionCandidate` whose `mounted_tool_name` is `"raise_ac_temperature_by_exp"` (present in `Core/Contracts/DDomainMountedToolCatalog.swift:16-20` `personaAvoidListToolNames` but NOT in `mountedToolNames`)
- **WHEN** the validator runs
- **THEN** it SHALL fail with `RouteError.unmountedName("raise_ac_temperature_by_exp")`
- **AND** `outcome` SHALL be rewritten to `.reject` before wire emission.

#### Scenario: action_candidate is not action proof

- **GIVEN** a `RouteResult` with `outcome=candidate` and a validly-mounted `action_candidate`
- **WHEN** a downstream consumer receives it
- **THEN** the consumer SHALL NOT record the state as mutated
- **AND** SHALL NOT emit any readback until the ToolCall guard chain per `openspec/specs/tool-execution/spec.md:5-11` completes independently.

### Requirement: value four-tuple SHALL use jsonl field names verbatim and a typed primitive enum

The `value` four-tuple SHALL use fields `ref`, `direct`, `offset`, `type` — verbatim from `contracts/semantic-function-contract.jsonl` (head-2 samples confirmed the four keys) and from the canonical definition at `docs/baseline-semantic-protocol-2026-06-19.md:53-57` §2②.

A new file `Core/Contracts/RouteValuePrimitive.swift` SHALL codify the four-tuple as typed enums:
- `RouteValueRef` ∈ {`empty`, `CUR`, `ZERO`, `MAX`}
- `RouteValueDirect` ∈ {`empty`, `plus`, `minus`}
- `RouteValueType` ∈ {`empty`, `SPOT`, `PERCENT`, `EXP`}
- `RouteValueOffset` = closed sum type `literal(String)` (numeric) / `experiential(RouteValueExperiential)` where `RouteValueExperiential` ∈ {`LITTLE`, `MORE`, `MAX`, `MIN`, `HIGH`, `HIGHER`, `MIDDLE`, `LOW`, `LOWER`}, following the offset enumeration in `docs/baseline-semantic-protocol-2026-06-19.md:56` §2②.

The Swift primitives SHALL follow the enum-with-computed-property pattern at `Core/Contracts/VehicleToolBehaviorClass.swift:3-13` (public enum String, Codable, CaseIterable, Sendable + typed accessor). The primitive enum SHALL NOT rename fields to `reference`, `direction`, `magnitude`, or `kind`.

Because live `Core/Contracts/ContractLookups.swift:3-15` `ContractValue` currently uses raw `String` fields with no typed enum anchor (live-cored), this Requirement fills that gap without mutating the existing struct.

#### Scenario: Empty value four-tuple decodes to empty primitives

- **GIVEN** a jsonl-sourced row with `value={ref:"",direct:"",offset:"",type:""}` (live head-2 sample condition)
- **WHEN** the row is materialized into `ActionCandidate.value`
- **THEN** each primitive enum SHALL decode to its `empty` case
- **AND** no `unknownEnum` failure SHALL be raised.

#### Scenario: EXP offset must use experiential enum

- **GIVEN** `value={ref:"CUR",direct:"+",offset:"LITTLE",type:"EXP"}` (the "有点冷" pattern per `docs/baseline-semantic-protocol-2026-06-19.md:56,63` §2②/§2③)
- **WHEN** decoding runs
- **THEN** `offset` SHALL decode as `RouteValueOffset.experiential(.LITTLE)`
- **AND** an offset value of `"WARM"` (not in the experiential alphabet) SHALL fail with `RouteError.unknownEnum("value.offset")`.

### Requirement: Route error enum SHALL be closed and cover risk-policy R0-R3

`RouteError` SHALL be a closed Swift enum covering, at minimum:
`unmountedName(String)`, `outOfCatalog(String)`, `oldGeneration(String)`, `payloadInvalid(String)`, `slotMissing(String)`, `valueOutOfRange(String)`, `riskR0Forbidden(String)`, `riskR1PreconditionUnmet(String)`, `clarifyRequired(RouteClarifyTag)`, `unknownEnum(String)`, `illegalCombination(String)`, `staleSource(String)`, `digestMismatch(expected: String, actual: String)`, `schemaVersionMismatch(expected: String, actual: String)`.

The R0/R1/R2/R3 mapping SHALL be anchored to the risk-policy amend recorded at `CLAUDE.md:109` (「D37 安全门→risk-policy 单源(R0-R3 收 ASIL/forbidden)+ clarifyTag」) and the risk-policy live source `contracts/risk-policy.yaml`:
- `riskR0Forbidden` = ASIL / driving-forbidden hard reject.
- `riskR1PreconditionUnmet` = end-state precondition unmet.
- `clarifyRequired` = R2 clarify (linked to `clarify_tag=implicit`).
- (R3 success proof is NOT a `RouteError` case; success is expressed by `outcome=candidate` proceeding through the downstream ToolCall guard chain.)

The rejection precedence SHALL be, in strict order: `riskR0Forbidden` → `illegalCombination` → `unmountedName` → `outOfCatalog` → `oldGeneration` → `staleSource` → `digestMismatch` → `schemaVersionMismatch` → `payloadInvalid` → `slotMissing` → `valueOutOfRange` → `unknownEnum` → `riskR1PreconditionUnmet` → `clarifyRequired`. When two conditions co-occur the earlier one in this list SHALL be the emitted `rejection_reason`.

#### Scenario: R0 forbidden takes precedence over R1 precondition

- **GIVEN** a candidate that is both driving-forbidden (R0) and precondition-unmet (R1)
- **WHEN** the validator selects a rejection reason
- **THEN** it SHALL emit `RouteError.riskR0Forbidden(...)` first
- **AND** SHALL NOT emit `riskR1PreconditionUnmet` on the same route result.

#### Scenario: R2 clarify is independent of reject

- **GIVEN** a route decision where the model output is legal but the clarify_tag axis says `implicit` and no downstream deterministic mapping exists
- **WHEN** the validator picks an outcome
- **THEN** it SHALL emit `outcome=clarify` with `rejection_reason` absent
- **AND** the downstream consumer SHALL NOT treat the payload as a reject.

### Requirement: RouteSubject and RouteTrace SHALL carry redaction-safe identity and canonical digest

`RouteSubject` SHALL carry only: `schema_version`, `route_schema`, `turn_id`, `trace_id`, `source_identity{matrix_source_sha256, runtime_contract_bundle_digest}`, `source_revision` OR `stale_marker`, `contract_digest`. The `source_identity` sub-struct SHALL match `Core/Contracts/DemoAuthorityIdentity.swift:3-11` field shape (matrixSourceSHA256 + runtimeContractBundleDigest).

`RouteTrace` SHALL carry only: `schema_version`, `turn_id`, `trace_id`, `exec_tier`, `outcome`, `clarify_tag`, `rejection_reason?`, `redaction_policy_id`, `stale_marker?`, `trace_digest`. `RouteTrace` SHALL NOT carry raw prompt text, raw model response, PII, or any un-redacted customer utterance.

`trace_digest` SHALL be a canonical digest computed over the RouteTrace load-bearing fields using a deterministic canonical JSON encoding (sorted keys, no whitespace). Any load-bearing field change SHALL change `trace_digest`; two RouteTraces with identical load-bearing fields SHALL produce identical `trace_digest`.

`RouteResult.trace_digest` SHALL equal the digest computed from the accompanying `RouteTrace`. A mismatch SHALL fail closed with `RouteError.digestMismatch(...)`.

#### Scenario: RouteTrace refuses raw prompt embedding

- **GIVEN** a caller attempts to serialize a `RouteTrace` containing a `raw_prompt` field
- **WHEN** the total validator inspects the encoded payload
- **THEN** decoding SHALL fail with `RouteError.payloadInvalid("raw_prompt is not permitted in RouteTrace")`
- **AND** no writer SHALL emit a RouteTrace with raw customer utterance embedded.

#### Scenario: Load-bearing change flips the digest

- **GIVEN** two RouteTraces A and B identical in every load-bearing field
- **WHEN** their `trace_digest` values are computed
- **THEN** the two digests SHALL be equal
- **AND** flipping any load-bearing field (e.g., `outcome` from `candidate` to `reject`) SHALL produce a different digest.

#### Scenario: Digest mismatch between RouteResult and RouteTrace is rejected

- **GIVEN** a `RouteResult.trace_digest = "abcd..."` and an accompanying `RouteTrace` whose canonical digest is `"efgh..."`
- **WHEN** the pair is validated together
- **THEN** validation SHALL fail with `RouteError.digestMismatch(expected: "abcd...", actual: "efgh...")`
- **AND** no consumer SHALL treat the result as trustworthy.

### Requirement: Contract SHALL NOT introduce a second D-domain tool registry, service catalog, or fc_flags→exec_tier map

The typed route/model contract SHALL consume, not duplicate, these canonical sources:
- Mounted D-domain tool set: `Core/Contracts/DDomainMountedToolCatalog.swift:12-14` `mountedToolNames`.
- Service catalog: three services `airControl`, `carControl`, `cmd`, verified by live jsonl service distribution (`grep -c '"service":"..."'` returns 178 / 2656 / 1156 rows) and documented at `docs/baseline-semantic-protocol-2026-06-19.md:16` (「C1 全集 3990 源行 = airControl 178 / carControl 2656 / cmd 1156」).
- `fc_flags → exec_tier` derivation: `contracts/semantic-function-contract.jsonl` row-level `exec_tier` field is the SSOT (live sample-verified: `c1_airControl_000136 → exec_tier=L1`, `c1_airControl_000002 → exec_tier=L2`). No parallel Swift table mapping `fc_flags{fuzzy,free}` to `exec_tier` SHALL be created.

Live-cored non-collision: `grep -rn "struct Route\|enum Route\|class Route\|struct Router\|enum Router" Core/` returns only a fileprivate `struct Route` inside `Core/Presentation/MockVoicePresetPlanner.swift:419` (not module-visible); no module-level `Route*` type collides with the names introduced here.

#### Scenario: Second tool registry would violate SSOT

- **GIVEN** an attempt to define a Swift constant `w6MountedToolNames: Set<String> = [...]` inside `Core/Contracts/RouteContract.swift`
- **WHEN** the validator or a test enumerates known mounted tools
- **THEN** it SHALL read from `Core/Contracts/DDomainMountedToolCatalog.mountedToolNames` only
- **AND** SHALL NOT declare a parallel `Set<String>` literal for the same purpose.

#### Scenario: Out-of-catalog service is rejected

- **GIVEN** an `ActionCandidate` whose `service` is `"media"` (NOT in {airControl, carControl, cmd})
- **WHEN** the validator runs
- **THEN** it SHALL fail with `RouteError.outOfCatalog("media")`
- **AND** the writer SHALL NOT emit an approved candidate.

### Requirement: Positive fixtures SHALL reference real jsonl contract_row_id samples per service

The fixture set at `contracts/fixtures/typed-route-contract/` SHALL contain positive fixtures whose `action_candidate.intent`, `service`, `device`, `action_primitive`, and `action_code` fields exactly match a row in `contracts/semantic-function-contract.jsonl`. The originating `contract_row_id` SHALL be recorded in the fixture metadata (e.g. `"_source": {"contract_row_id": "c1_airControl_000002", ...}`).

Coverage SHALL include at least one positive fixture per service: `airControl`, `carControl`, `cmd`. Live jsonl-cored real samples usable for this purpose include (verified 2026-07-13):
- `c1_airControl_000002` — intent `open_ac_set_interface`, exec_tier `L2`, clarify_tag `implicit`.
- `c1_carControl_000002` — intent `open_window`, exec_tier `L1`, clarify_tag `implicit`.
- `c1_cmd_000002` — intent `open_bluetooth`, exec_tier `L2`, clarify_tag `implicit`.

Negative fixtures SHALL cover, at minimum: unknown enum on each of the three axes, illegal-combination (candidate outcome with no action_candidate), unmounted tool name, out-of-catalog service, stale source marker, digest mismatch, session_id leak, EXP-with-non-experiential-offset.

#### Scenario: Positive fixture traces back to jsonl

- **GIVEN** the fixture `positive_air_control.json` at `contracts/fixtures/typed-route-contract/`
- **WHEN** a checker reads its `action_candidate.intent`, `service`, `device`, `action_primitive`, `action_code`
- **THEN** the tuple SHALL match exactly at least one row in `contracts/semantic-function-contract.jsonl`
- **AND** the `_source.contract_row_id` SHALL be a valid jsonl row id.

#### Scenario: Fabricated intent is rejected by the fixture checker

- **GIVEN** a proposed positive fixture whose `intent` is `"fabricated_intent_not_in_jsonl"`
- **WHEN** the fixture checker validates it
- **THEN** the checker SHALL fail closed with a jsonl-mismatch error
- **AND** the writer SHALL NOT commit that fixture as a positive case.

### Requirement: Candidate positive fixtures SHALL satisfy the D-domain paradigm intent==mounted_tool_name

A positive fixture with `outcome=candidate` and a non-null `action_candidate` SHALL satisfy `action_candidate.intent == action_candidate.mounted_tool_name`, mirroring the D-domain named-tool paradigm at `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:13` ("intent == 工具名"). A fixture that uses a mounted tool name whose jsonl service binding does not match its own service SHALL be rejected either at fixture-check time or by the validator.

grok-4.5 xAI review (2026-07-13) P1-A1 exposed the semantic false binding where a previous airControl positive fixture used `intent=open_ac_set_interface` (from `c1_airControl_000002`) with `mounted_tool_name=adjust_ac_temperature_to_number` — the "metadata true, surface binding false" 0/34 variant. Real jsonl rows where `intent==adjust_ac_temperature_to_number` include `c1_airControl_000164` / `_000165` / `_000166` (grep-verified 2026-07-13, all `service=airControl`).

#### Scenario: Positive candidate fixture's intent equals its mounted tool

- **GIVEN** a positive fixture with `outcome=candidate` and a non-null `action_candidate`
- **WHEN** a fixture checker inspects it
- **THEN** `action_candidate.intent` SHALL equal `action_candidate.mounted_tool_name`
- **AND** the row referenced by `_source.contract_row_id` in `contracts/semantic-function-contract.jsonl` SHALL also satisfy `intent == mounted_tool_name` for that row.

### Requirement: The validator SHALL enforce mounted-tool kinship (service must match jsonl binding)

A mounted tool name binds to a specific D-domain service per jsonl. The validator SHALL reject an `ActionCandidate` whose `service` disagrees with the jsonl-verified binding of its `mounted_tool_name`. This gate is orthogonal to `.unmountedName` — the tool exists in `Core/Contracts/DDomainMountedToolCatalog.swift:12-14` mountedToolNames, but its cross-service binding is illegal.

The kinship table (`MountedToolServiceMap.bindings` in `Core/Contracts/RouteContract.swift`) SHALL be a peer projection of the catalog, verified by an invariant test that every mounted tool has a service binding. The map SHALL NOT be a second SSOT — its keys are consumed from the catalog and its values are the jsonl-verified services.

grok-4.5 xAI review (2026-07-13) P1-A2 exposed this gap: existence-only checks let `service=carControl + mounted_tool_name=adjust_ac_temperature_to_number` (bound to airControl per jsonl) pass silently.

#### Scenario: Cross-service mounted-tool binding is rejected

- **GIVEN** an `ActionCandidate` where `mounted_tool_name` is in `mountedToolNames` but its jsonl service binding differs from `candidate.service`
- **WHEN** the validator runs
- **THEN** it SHALL fail with `RouteError.crossDomainMountedTool(tool:, boundService:, candidateService:)`
- **AND** the error SHALL carry the concrete tool name, the bound service, and the offending candidate service.

#### Scenario: Every mounted tool has a service binding

- **GIVEN** the set `DDomainMountedToolCatalog.mountedToolNames`
- **WHEN** the invariant test runs `MountedToolServiceMap.service(for:)` on every name
- **THEN** every lookup SHALL return a non-nil `RouteService`
- **AND** catalog expansion without corresponding map update SHALL surface as a test failure.

### Requirement: Forbidden ontology keys SHALL be rejected at decode time

The Swift wire decoders for `RouteResult`, `RouteSubject`, `RouteTrace`, and `ActionCandidate` SHALL, when invoked via their `decodeRejectingForbiddenKeys(from:)` entry, inspect the raw JSON object and reject any occurrence of forbidden keys with `RouteError.forbiddenKey(...)`.

Forbidden ontology keys SHALL be `session_id`, `event_id`, `sequence` (belong to T04a/W5a pending-correlation record per `openspec/changes/add-t04a-customer-ingress/design.md:7-11`, not to this ontology). Forbidden redaction keys SHALL be `raw_prompt`, `raw_response` (redaction-safe carrier SHALL NOT carry raw customer utterance).

The default `JSONDecoder.decode` silently drops unknown keys; the SHALL "Session identity leaks are forbidden" therefore requires explicit key inspection at decode time via the guarded entry point. grok-4.5 xAI review (2026-07-13) P1-B6 exposed this: prior tests only asserted the Swift struct had no such property (`Mirror` inspection), which does not catch the wire violation.

#### Scenario: session_id key on the wire is caught by the decode guard

- **GIVEN** a JSON payload with a top-level `session_id` key
- **WHEN** `RouteResult.decodeRejectingForbiddenKeys(from:)` is called
- **THEN** decoding SHALL fail with `RouteError.forbiddenKey("route_result.session_id")`
- **AND** the default `JSONDecoder().decode(RouteResult.self, from:)` SHALL NOT be the recommended entry point for untrusted input.

#### Scenario: raw_prompt on RouteTrace is caught

- **GIVEN** a JSON payload for `RouteTrace` with a `raw_prompt` field
- **WHEN** `RouteTrace.decodeRejectingForbiddenKeys(from:)` is called
- **THEN** decoding SHALL fail with `RouteError.forbiddenKey("route_trace.raw_prompt")`.

### Requirement: trace_digest SHALL cover the action_candidate payload

`trace_digest` SHALL be computed over a load-bearing set that includes, when present, an `ActionCandidateSummary` with `mounted_tool_name`, `service`, `action_primitive`, `action_code`, and `value` (the four-tuple). Any tampering with these fields SHALL flip the digest; the joint validator SHALL emit `RouteError.digestMismatch` when the pinned `trace_digest` disagrees with the recomputed one, and SHALL emit `RouteError.illegalCombination` when the trace's `action_candidate_summary` does not equal the result's `action_candidate.summary` (a more specific failure that fires before the digest check).

grok-4.5 xAI review (2026-07-13) P1-B2 exposed the prior gap: the digest covered only outcome-axis facts (`exec_tier`, `outcome`, `clarify_tag`, `rejection_reason`), leaving candidate tampering to pass through the joint validator. `intent`, `device`, `slot`, and `slot_keys` are NOT in the summary because they are derivable via the paradigm binding (intent==mounted_tool_name and the jsonl row identity).

#### Scenario: Tampering with mounted tool name in the candidate flips the digest

- **GIVEN** two `RouteTrace` values identical except that the second's `actionCandidateSummary.mountedToolName` differs
- **WHEN** their `computeTraceDigest()` values are computed
- **THEN** the two digests SHALL differ.

#### Scenario: Tampering with value four-tuple in the candidate flips the digest

- **GIVEN** two `RouteTrace` values identical except that the second's `actionCandidateSummary.value` differs (e.g. `ref` changes from `""` to `"CUR"`)
- **WHEN** their digests are computed
- **THEN** the two digests SHALL differ.

#### Scenario: Candidate summary mismatch between result and trace fires before digest check

- **GIVEN** a `RouteResult` whose `action_candidate.summary` differs from its accompanying `RouteTrace.actionCandidateSummary`, and whose `trace_digest` (by construction) does not equal the recomputed digest either
- **WHEN** the joint validator runs
- **THEN** it SHALL emit `RouteError.illegalCombination("RouteResult.action_candidate.summary != RouteTrace.action_candidate_summary")` first (more specific)
- **AND** SHALL NOT emit `RouteError.digestMismatch` on the same call.

### Requirement: The change SHALL NOT touch B1b, App composition, Makefile, or generated files

This change SHALL restrict its write-set to a fixed allowlist of new files under `Core/Contracts/`, `contracts/schemas/`, `contracts/fixtures/typed-route-contract/`, `Tests/MAformacCoreTests/`, `Tests/python/contracts/`, and `openspec/changes/add-w6-typed-route-contract/`; and SHALL NOT modify Makefile, closure-shared checkers, generated Swift files, App composition, runner/store seams, or the parked intent-routing change tree.

Files this change MAY create:
- `Core/Contracts/RouteContract.swift`
- `Core/Contracts/RouteResult.swift`
- `Core/Contracts/RouteError.swift`
- `Core/Contracts/RouteValuePrimitive.swift`
- `contracts/schemas/typed-route-contract.v1.schema.json`
- `contracts/fixtures/typed-route-contract/*.json`
- `Tests/MAformacCoreTests/RouteContractTests.swift`
- `Tests/python/contracts/test_route_fixtures.py`
- `openspec/changes/add-w6-typed-route-contract/**`

Files this change SHALL NOT modify:
- `Makefile`
- `Tests/test_closure_work_packages.py`
- Any `Core/Contracts/*.generated.swift` (verbatim: `DDomainIRMap.generated.swift`, `DemoCapabilityMatrix.generated.swift`, `DemoRuntimeContractBundle.generated.swift`, `FallbackScriptCatalog.generated.swift`)
- `Core/Contracts/ToolContractCompiler.swift`
- `Core/Contracts/DDomainMountedToolCatalog.swift`
- `Core/Contracts/ContractLookups.swift`
- `Core/Contracts/DemoAuthorityIdentity.swift`
- `Core/Contracts/C6ToolCall.swift`
- `Core/Contracts/VehicleToolBehaviorClass.swift`
- `Core/Contracts/StateWrite.swift`
- `App/**` (including `App/FrontstageRuntimeComposition.swift`, `App/**/DemoRuntimeSessionRunner*.swift`)
- `Sources/**/DemoVehicleStateStore.swift`
- Any existing macOS UI test file
- Any shared closure checker / registry / index file
- `openspec/changes/_parked/**` (parked change per `openspec/changes/_parked/define-intent-routing/proposal.md:1` is PARKED + SUPERSEDED; NOT to be re-activated or derived from)

Proof cap SHALL be `local / unit / integration` on the typed contract layer only. No claim of App build proof, runtime, operator-pass, V-PASS, C6, C5, mobile, true-device, or live-api SHALL be made in the closeout.

#### Scenario: No parallel Makefile wiring

- **GIVEN** a producer working under this change
- **WHEN** the working tree diff is inspected before commit
- **THEN** `Makefile` SHALL be unchanged
- **AND** no new `verify-*` target that consumes this contract SHALL be added by this change (deferred to B1b).

#### Scenario: No revival of the parked intent-routing change

- **GIVEN** the parked change at `openspec/changes/_parked/define-intent-routing/`
- **WHEN** the producer runs
- **THEN** no file inside that path SHALL be edited or re-linked
- **AND** the new change dir `openspec/changes/add-w6-typed-route-contract/` SHALL be the sole owner of typed route contract SHALL Requirements.

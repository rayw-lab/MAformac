## ADDED Requirements

### Requirement: Main-Owned Core Config Vocabulary

The system SHALL define Core config and scene macro vocabulary in mainline authority before any UIUE consumer treats those names as shared runtime or presentation facts. This vocabulary SHALL remain distinct from the M16-011 physical catalog contract.

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

The system SHALL treat `SceneMacroRegistry` or any equivalent Core config registry as a main-owned owner boundary, not as UIUE-local presentation state. This registry boundary SHALL NOT be treated as the M16-011 physical catalog by implication.

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

### Requirement: M16-011 Single Physical Core Catalog

The system SHALL define one physical Core catalog for the force/config authority with exactly two explicit kind-and-namespace values, `debug` and `demo`. Every catalog entry SHALL carry stable identity, kind, namespace, version, and owner metadata. A second same-meaning catalog or inferred kind/namespace SHALL fail closed.

#### Scenario: One catalog carries both namespaces

GIVEN a consumer reads a force/config catalog
WHEN the catalog contains debug and demo entries
THEN both kinds SHALL be represented in the same physical catalog with explicit kind and namespace fields
AND the consumer SHALL NOT reconcile a second catalog or infer a namespace from a label, array position, or UI route.

#### Scenario: Unknown or duplicate catalog authority fails closed

GIVEN a catalog contains a third kind/namespace, duplicate stable identity, or an equivalent second authority
WHEN the catalog is validated
THEN validation SHALL fail closed
AND no entry SHALL be presented as supported shared authority.

### Requirement: M16-011 Catalog Digest Contract

The system SHALL declare the catalog digest algorithm identifier, canonicalization version, and digest over the complete load-bearing catalog entry set. Equivalent input ordering after canonicalization SHALL produce the same digest, while any load-bearing entry, kind, namespace, version, owner, or algorithm-version change SHALL change the digest. Missing metadata or a mismatch SHALL fail closed.

#### Scenario: Canonical catalog digest is stable and sensitive

GIVEN two catalogs have the same complete entries and declared digest metadata
WHEN their entries are serialized in different non-semantic input order
THEN they SHALL produce the same canonical digest
AND when a load-bearing entry or declared digest metadata changes the digest SHALL differ.

#### Scenario: Digest mismatch is not repaired locally

GIVEN a consumer receives a catalog with an absent, unknown, or mismatched digest
WHEN it validates the catalog
THEN it SHALL reject the catalog
AND it SHALL NOT recompute a private replacement digest or silently continue.

### Requirement: M16-011 Exact Migration Ledger

The system SHALL represent every supported legacy catalog migration in an explicit versioned ledger containing source identity, target identity, direction, reason, and evidence. It SHALL reject missing, duplicate, ambiguous, inferred, positional, and similarity-based mappings. A `4↔5` mapping SHALL never be synthesized or accepted.

#### Scenario: Exact migration requires an explicit ledger row

GIVEN a legacy catalog requires migration
WHEN the source and target identities, direction, reason, and evidence are not present as one unambiguous ledger row
THEN migration SHALL fail closed
AND the system SHALL NOT infer a mapping from names, positions, or similarity.

#### Scenario: Forbidden 4-to-5 mapping is rejected

GIVEN a migration input proposes a `4↔5` mapping or an equivalent fuzzy join
WHEN the migration ledger is validated
THEN validation SHALL fail closed
AND no migrated authority entry SHALL be emitted.

### Requirement: M16-012 Single Force-State Write Owner

The system SHALL enforce the observable owner graph `boundary validator → Core applier → projection-only`. Only the Core applier SHALL commit the resulting mock state. App/UI consumers SHALL read the projection and SHALL NOT directly mutate the store or state-cell contract. Missing provenance, a missing applier, a direct-write path, or customer-facing force reachability SHALL be a negative condition.

#### Scenario: Accepted force-state follows the single owner graph

GIVEN a demo/debug force-state input passes boundary validation
WHEN the input changes the mock state
THEN the change SHALL be committed only by the Core applier
AND the presentation side SHALL receive a projection with traceable bridge provenance.

#### Scenario: Direct App mutation is a deletion-negative

GIVEN an App or UI path attempts to write the store or state-cell contract directly
WHEN the W9 authority chain is checked
THEN the path SHALL be rejected or reported as a failed negative
AND it SHALL NOT count as a valid Core-authority write.

#### Scenario: W9 does not own lifecycle state

GIVEN a later W9 implementation consumes typed terminal or fence acknowledgement from W8
WHEN it validates a force-state write
THEN W9 SHALL consume that acknowledgement as an input boundary
AND it SHALL NOT define or replace W8 session, cancel, recovery, or lifecycle ownership.

## MODIFIED Requirements

### Requirement: Demo Force-State Boundary

The system SHALL isolate force-state behavior to explicit demo/debug surfaces, route accepted writes through the single Core owner graph, and prevent force-state from becoming a customer-facing production path.

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

#### Scenario: Force-state follows boundary, applier, projection ownership

GIVEN a demo/debug force-state input has passed validation
WHEN the mock state is changed
THEN the Core applier SHALL be the sole write owner
AND presentation consumers SHALL receive projection-only state rather than a direct store mutation.

#### Scenario: Force-state does not mutate state-cell contracts directly

GIVEN force-state modifies current demo context
WHEN state-cell contracts or semantic source contracts are evaluated
THEN force-state SHALL NOT mutate those contracts directly
AND it SHALL remain a demo context input rather than a contract-authoring mechanism.

#### Scenario: Direct customer or App path is a negative

GIVEN a customer-facing or App/UI path bypasses the boundary or Core applier
WHEN the W9 source/authority contract is checked
THEN the check SHALL fail
AND the bypass SHALL NOT be counted as a degraded or partial authority success.

#### Scenario: Debug-only proof is not production proof

GIVEN a debug gallery, simulator screenshot, local test, or local OpenSpec validation proves force-state behavior
WHEN status is reported
THEN the proof SHALL remain capped to debug/local/unit/simulator_mock as applicable
AND it SHALL NOT be reported as production runtime, mobile, true-device, live, operator-pass, or V-PASS proof.

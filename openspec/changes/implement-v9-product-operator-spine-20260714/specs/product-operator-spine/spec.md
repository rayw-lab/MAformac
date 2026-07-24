## ADDED Requirements

### Requirement: Unique production composition root

The system SHALL expose exactly one customer-facing production composition root for demo-slice execution at `App/FrontstageRuntimeComposition.swift`. That root SHALL assemble lifecycle admission via `SessionLifecycleCompositionGate.ensureActive`, per-turn correlation provider injection, and `DemoSliceRoute.route(text:correlationProvider:)` construction. Parallel second roots, ContentView-local `DemoRuntimeSessionRunner` construction claimed as production, or silent dual assembly SHALL be rejected by the product-operator spine contract.

#### Scenario: Production path enters only through the composition root

- **GIVEN** a customer-facing demo utterance has been accepted as the current turn
- **WHEN** demo-slice execution is requested on the production path
- **THEN** assembly and routing SHALL proceed only through `FrontstageRuntimeComposition.routeDemoSlice`
- **AND** the root SHALL perform parent-session active admission before catalog admission and runner invocation

#### Scenario: Test-double path cannot claim production composition

- **GIVEN** a Core unit test constructs `DemoRuntimeSessionRunner` or `DemoSliceRoute` directly without the production composition root
- **WHEN** proof or receipt status is evaluated
- **THEN** the result SHALL be classified as unit or test-double proof only
- **AND** it SHALL NOT be reported as production composition wired or customer path done
- **AND** the suite SHALL NOT claim that SPM unit tests instantiate App target types

#### Scenario: App wiring is proven by source-contract not by SPM App instantiation

- **GIVEN** Core package tests cannot construct `FrontstageRuntimeComposition`
- **WHEN** production correlation wiring is verified in package tests
- **THEN** verification SHALL use source-contract reads of `App/FrontstageRuntimeComposition.swift` together with Core-constructed route tests that inject a non-nil per-turn provider
- **AND** `runtime_local` proof SHALL remain a separate resource-window class

#### Scenario: Second production root is forbidden

- **GIVEN** a caller attempts to install or advertise a second same-meaning production composition root
- **WHEN** the spine contract is evaluated
- **THEN** the attempt SHALL fail closed or be rejected by review/stop conditions
- **AND** only `FrontstageRuntimeComposition` remains authoritative for customer-facing assembly

---

### Requirement: Per-turn fail-closed correlation via ProductionRouteCorrelationProvider

The system SHALL inject a non-nil `RuntimeSessionCorrelationProvider` on the real App production composition path using the production binding type defined in `Core/State/ProductionRouteCorrelationProvider.swift`. The production binding SHALL be a **factory** with exact inputs `routeTurnID: String`, `sessionRef: String`, `generationRef: String`, and `groupOrdinal: UInt32`, returning a `RuntimeSessionCorrelationProvider` whose closure uses those frozen per-turn values together with the incoming `traceID` and frame identity. The factory-produced `RouteToDialogueCorrelation.schemaVersion` and nested `DialogueRouteAttribution.schemaVersion` SHALL both be frozen to `DialogueStateSchemaVersion.v1` on the production path. Dialogue group identity sources SHALL be exactly `FrontstageVoiceTurn` (`sessionID`, positive `sequence`, `turnID`) and the generation returned by `SessionLifecycleCompositionGate.ensureActive`. Production flow SHALL construct one provider per accepted current turn in `FrontstageRuntimeComposition.routeDemoSlice`, then call non-optional `DemoSliceRoute.route(text:correlationProvider:)`, which SHALL call non-optional `DemoRuntimeSessionRunner.run(text:correlationProvider:)`. Legacy optional constructor providers and `run(text:)` remain permitted only for unit/default helpers and SHALL NOT be the App production surface. Changing `defaultRunner` visibility is not required. Missing production providers, new/current-turn mismatch, invalid `UInt32` sequence, empty identity, invalid overflow, identity mismatch, or unsupported correlation schema SHALL fail closed with no typed-facts mutation and observable refusal or no-success evidence. A mutable singleton or global context box SHALL NOT supply correlation identity. A nil correlation provider remains permitted only on explicitly labeled unit, default-helper, or test-double paths and SHALL NOT satisfy production composition.

#### Scenario: Production assembly requires a non-nil per-turn correlation provider

- **GIVEN** the production composition root is assembling a demo-slice route for an accepted current turn
- **WHEN** the runner is invoked on that path
- **THEN** `correlationProvider` SHALL be non-nil and constructed for that turn only
- **AND** construction that silently drops the provider SHALL be rejected

#### Scenario: ProductionRouteCorrelationProvider is the sole production binding file and factory shape is frozen

- **GIVEN** production composition needs a concrete correlation binding
- **WHEN** apply lands the binding
- **THEN** the production provider implementation file SHALL be exactly `Core/State/ProductionRouteCorrelationProvider.swift`
- **AND** the factory inputs SHALL be exactly `routeTurnID`, `sessionRef`, `generationRef`, and `groupOrdinal`
- **AND** both `RouteToDialogueCorrelation.schemaVersion` and `DialogueRouteAttribution.schemaVersion` SHALL be `DialogueStateSchemaVersion.v1`
- **AND** unit/default helpers MAY pass an explicit nil without using that production binding

#### Scenario: Production surfaces are non-optional per-call route and run

- **GIVEN** App production composition has assembled a per-turn provider
- **WHEN** demo-slice execution proceeds
- **THEN** `DemoSliceRoute.route(text:correlationProvider:)` SHALL be used with a non-optional provider argument
- **AND** `DemoRuntimeSessionRunner.run(text:correlationProvider:)` SHALL be used with a non-optional provider argument
- **AND** legacy optional `run(text:)` remains only for unit/default helpers

#### Scenario: Invalid correlation is refused without window mutation

- **GIVEN** the production path has a non-nil correlation provider
- **WHEN** the provider returns a correlation that fails schema or validator checks
- **THEN** `DialogueState.recordTypedFacts` SHALL return denied context-invalid
- **AND** the typed-facts window SHALL remain unchanged
- **AND** a guard or diagnostic SHALL be observable

#### Scenario: Turn identity or sequence failure fails closed without typed-facts success

- **GIVEN** the composition root attempts to build a per-turn provider
- **WHEN** the turn is not the accepted current turn, `UInt32(exactly: turn.sequence)` is nil, or any of routeTurnID/sessionRef/generationRef is empty or invalid
- **THEN** no typed-facts mutation SHALL be attributed to a successful production route for that turn
- **AND** refusal or no-success evidence SHALL be observable

#### Scenario: Lifecycle identity mismatch fails closed before route

- **GIVEN** the composition root holds a parent session lifecycle gate bound to session S
- **WHEN** `routeDemoSlice` is invoked with a turn whose session identity is not S
- **THEN** the gate SHALL fail closed before catalog admission and runner invocation
- **AND** no vehicle-state mutation for that turn SHALL be attributed to a successful production route

#### Scenario: Unit nil-provider path stays honest

- **GIVEN** a unit test constructs a runner with `correlationProvider == nil` on a helper surface
- **WHEN** a turn completes
- **THEN** typed facts SHALL NOT be recorded
- **AND** the result SHALL NOT be claimed as production correlation wired

---

### Requirement: Single writer for DialogueState, lifecycle, and vehicle state

The system SHALL preserve a single writer per authority surface: DialogueState mutations through the runner-held state, lifecycle transitions through the session lifecycle owner/coordinator path held by `SessionLifecycleCompositionGate`, and vehicle state through the demo store/pipeline applier. Adapters and bridges MAY translate typed facts but SHALL NOT create a second authoritative state machine or shadow snapshot that can diverge silently.

#### Scenario: Bridge does not become a second lifecycle authority

- **GIVEN** `LifecycleFactsDialogueBridge` is present
- **WHEN** a cancel or terminal fact is mapped
- **THEN** lifecycle identity and first-cause ownership remain on the W8 lifecycle owner
- **AND** the bridge only maps to versioned DialogueState field effects via a caller-provided matrix

#### Scenario: Shadow dialogue snapshot is forbidden as authority

- **GIVEN** UI text or a presentation-only buffer is restored after restart
- **WHEN** a resolver asks for dialogue context without an authoritative checkpoint
- **THEN** the system SHALL return typed no-context or clarify with mutation false
- **AND** the presentation text alone SHALL NOT authorize active DialogueState context

---

### Requirement: SessionLifecycleEvent to DialogueW8FactKind bridge mapping

The system SHALL provide exactly one bridge path at `Core/Lifecycle/LifecycleFactsDialogueBridge.swift` that maps live `SessionLifecycleEvent` values—**which already exist** at `Core/Lifecycle/SessionLifecycleFacts.swift`—to `DialogueW8FactKind` and applies a caller-provided versioned `DialogueW7EffectMatrix`. This change SHALL CREATE the bridge and its ProductOperator unit tests only; it SHALL NOT MODIFY `Core/State/DialogueStateEffectBoundary.swift`. Missing matrix entries or version mismatch SHALL fail closed with zero field mutation. Product-path consumption of cancel, terminal, newGeneration, and recoveryReady through `FrontstageRuntimeComposition` is deferred because `SessionLifecycleCompositionGate` only exposes `ensureActive`. Deferred scenarios SHALL be unit-tested at the bridge and SHALL NOT be claimed as App product-path DONE.

#### Scenario: Mapping table is closed and exact

- **GIVEN** a live `SessionLifecycleEvent` is presented to the bridge
- **WHEN** mapping runs
- **THEN** `.start` maps to `.sessionStarted`
- **AND** `.terminal` with `outcomeClass == .cancelled` maps to `.turnCancelled`
- **AND** `.terminal` with any other settled outcome class maps to `.terminalClear`
- **AND** `.newGeneration` maps to `.generationFenced`
- **AND** `.recoveryReady` maps to `.checkpointRestoreAttempted`

#### Scenario: Bridge consumes a caller-provided matrix without owning DialogueStateEffectBoundary

- **GIVEN** the bridge is invoked with a caller-provided `DialogueW7EffectMatrix`
- **WHEN** apply runs for a mapped fact kind
- **THEN** the bridge SHALL call `matrix.apply`
- **AND** apply of this change SHALL NOT modify `DialogueStateEffectBoundary.swift`

#### Scenario: Supported cancel maps to audit-only effects when matrix entry exists

- **GIVEN** the matrix contains a `.turnCancelled` entry with clear focus/lastReadback and retainAsAuditOnly terminal audit
- **WHEN** the bridge applies that fact through the matrix
- **THEN** focus and last-readback effects SHALL be clear
- **AND** terminal audit SHALL be retainAsAuditOnly
- **AND** this unit result alone SHALL NOT claim App cancel product wiring

#### Scenario: Unknown or version-incompatible lifecycle fact fails closed

- **GIVEN** a fact is unknown or the effect matrix version is unsupported or the entry is missing
- **WHEN** consumption is attempted through the bridge/matrix
- **THEN** no partial DialogueState field mutation SHALL occur
- **AND** the failure SHALL be typed and observable

#### Scenario: Product-path cancel and recovery remain deferred

- **GIVEN** `SessionLifecycleCompositionGate` only exposes `ensureActive`
- **WHEN** this spine change is evaluated for product cancel/restart/recovery claims
- **THEN** those claims SHALL remain deferred
- **AND** status SHALL NOT report product-path cancel/recovery as wired through the composition root

#### Scenario: Recovery requires authoritative checkpoint when later wired

- **GIVEN** a terminal parent session and a recovery request
- **WHEN** no authoritative checkpoint is available or only a pending plan exists
- **THEN** recovery context restore SHALL fail closed or return no-context
- **AND** a new generation SHALL NOT be treated as restored from UI text alone

---

### Requirement: Force catalog digest gate unit only; App consumption deferred

The system SHALL provide a thin, stateless gate at `Core/Config/ForceStateDigestGate.swift` with public API `validate(metadata: ForceStateDigestMetadata?, against catalog: ForceStateCatalog) throws` that delegates solely to `ForceStateDigest.validate` and SHALL NOT recompute digests, own a catalog, or implement a second digest algorithm. In this change the implementation surface is exactly CREATE `ForceStateDigestGate.swift` plus CREATE `Tests/MAformacCoreTests/ProductOperatorForceStateDigestGateTests.swift` and, only if dedupe truly requires it, MODIFY existing `ForceStateDigestTests.swift`. This change SHALL NOT MODIFY `App/ContentView.swift` for force catalog consumption, and SHALL NOT MODIFY `Core/Config/ForceStateDigest.swift`, `ForceStateCatalog.swift`, or `DemoForceStateBoundary.swift`. Live residual is exact: `applySnapshotCells has matrix-digest authority only; no force_catalog metadata carrier exists`. App force-catalog consumption remains `resource_deferred_tests` until an independently sourced, non-empty, versioned catalog and external metadata payload exist. Observation field names reserved for future handoff only are `force_catalog_digest_hex` and `capability_matrix_digest_hex`. Mapping `DemoVehicleStateApplier.TerminalAck.canonicalDigest` to a force-catalog field is forbidden. The claim ceiling for S3 is `FORCE_DIGEST_GATE_UNIT_PASS`; `W9_APP_CONSUMED` is forbidden.

#### Scenario: Gate delegates to ForceStateDigest.validate only

- **GIVEN** force-state metadata and a catalog are presented to `ForceStateDigestGate`
- **WHEN** `validate(metadata:against:)` runs
- **THEN** the gate SHALL call `ForceStateDigest.validate`
- **AND** no second hash or silent recompute path SHALL substitute a digest

#### Scenario: Digest mismatch fails closed at the unit gate

- **GIVEN** force-state metadata digest disagrees with the catalog-backed validate result
- **WHEN** `ForceStateDigestGate.validate` runs
- **THEN** the operation SHALL throw or return a typed mismatch failure
- **AND** no silent locally recomputed digest SHALL be substituted

#### Scenario: App applySnapshotCells is not force-catalog-wired in this change

- **GIVEN** this spine change is evaluated for W9 App force consumption
- **WHEN** residual scope is read
- **THEN** residual SHALL remain `applySnapshotCells has matrix-digest authority only; no force_catalog metadata carrier exists`
- **AND** claim status SHALL NOT be `W9_APP_CONSUMED`

#### Scenario: Force catalog digest is not capability-matrix digest

- **GIVEN** receipts or handoff notes mention digests after this spine lands
- **WHEN** force catalog validation evidence is recorded
- **THEN** reserved observation names `force_catalog_digest_hex` and `capability_matrix_digest_hex` SHALL stay distinct
- **AND** `DemoVehicleStateApplier.TerminalAck.canonicalDigest` SHALL NOT be mapped to the force field
- **AND** force gate unit green SHALL NOT be reported as matrix or actionDemoProven green

#### Scenario: Force visual cannot create focus when later wired

- **GIVEN** a presentation surface forces a visual state after a future successful digest validation
- **WHEN** DialogueState is read
- **THEN** no focus entity is created or renewed from that visual state alone
- **AND** existing focus validity remains governed by its owner window

---

### Requirement: Composition gate gates customer-shaped golden and reliability claims

The system SHALL treat golden replay and reliability work as contract, fixture, and test preparation until the production composition gate (unique root + non-nil per-turn correlation provider + lifecycle admission) has passed. Before that gate, the system SHALL NOT claim customer path done. Reliability thresholds SHALL be provisional and package-local, MUST carry an explicit basis citation for HANDOFF, and SHALL NOT assume V1 RATIFIED or claim W4 DONE. Fixture roots SHALL be exactly `Tests/Fixtures/product-operator-golden/` and `Tests/Fixtures/product-operator-reliability/`. p95, 20-turn, and 300s soak SHALL remain `resource_deferred_tests` until composition passes and a runtime resource window exists. Makefile soak gates are forbidden.

#### Scenario: Pre-composition golden stays fixture-local

- **GIVEN** the production composition gate has not passed
- **WHEN** golden fixtures or schema tests pass under `Tests/Fixtures/product-operator-golden/`
- **THEN** the proof class SHALL remain fixture-local or unit
- **AND** status SHALL NOT be reported as customer path done

#### Scenario: Reliability threshold without basis citation fails closed

- **GIVEN** a provisional reliability threshold value is declared under `Tests/Fixtures/product-operator-reliability/`
- **WHEN** HANDOFF or receipt `basis_citation` is missing
- **THEN** the threshold SHALL be rejected for claim use
- **AND** no W4 DONE or V1 RATIFIED claim SHALL be emitted

#### Scenario: Soak metrics stay resource deferred

- **GIVEN** composition has not passed or the runtime resource window is unavailable
- **WHEN** p95, 20-turn, or 300s soak status is summarized
- **THEN** soak_status SHALL be `resource_deferred` or `not_run`
- **AND** no Makefile soak gate SHALL be introduced by this change

#### Scenario: Post-composition golden may be runtime-local only

- **GIVEN** the production composition gate has passed on a local mock stack and a resource window is available
- **WHEN** a customer-shaped golden harness runs successfully offline
- **THEN** the proof class MAY be runtime_local
- **AND** it SHALL still NOT satisfy operator-pass, T07b, V-PASS, or C6 acceptance

#### Scenario: Historical draft golden change is not applied wholesale

- **GIVEN** `define-demo-golden-run-and-voice` remains draft_deferred historical input
- **WHEN** this spine change prepares golden fixtures
- **THEN** the system MAY reuse field-direction lessons only
- **AND** it SHALL NOT apply that change wholesale or bind C6 acceptance as a hard gate in this scope

---

### Requirement: TTS hard gate is visual-first, context-aware, and executable

The system SHALL treat visual readback and presentation payload as the primary user-visible truth. Production speak surfaces in this scope include `Core/Execution/DemoRuntimeSessionRunner.swift` using `SpeechSynthesisEngine` from `Core/Voice/SpeechSynthesisEngine.swift`, error/fallback text from `Core/Execution/FallbackContext.swift`, and the App call site `App/ContentView.swift` `applyRuntimeReadbackStep`. The `SpeechSynthesisEngine` protocol shape SHALL NOT change. When `AVSpeechSynthesisEngine.speak` runs and `bestChineseVoice()` returns nil, the engine SHALL NOT call the synthesizer and SHALL return `.failed(reason: "chinese_voice_unavailable")` without silent `.systemDefault` success. TTS enqueue failure, empty TTS text, or chinese voice unavailability SHALL fall back without inventing a successful action outcome. On the Core layer, `RuntimePresentationPayload` / Core `PresentationSnapshot.voiceState` (`PresentationVoiceDisplayState`) SHALL freeze to `.idle` and SHALL NOT be `.speak` when synthesis failed. On the App layer, `StagePresentationSnapshot.voiceState` (`PresentationVoiceState`) SHALL NOT become `.speaking` when synthesis failed; visual-first progression MAY continue. Negative assertions for these two layers SHALL NOT mix enum cases (`.speak` ≠ `.speaking`). `applyRuntimeReadbackStep` SHALL capture `SpeechSynthesisResult`, keep visual-first progression, and record observable TTS failure without marking voice success. Spoken or prepared speech for reject, clarify, safety refusal, unsupported, unmounted, and cancel outcomes SHALL NOT contain any of the forbidden completion phrases: `已完成`, `已设置成功`, `设置成功`, `操作成功`, `执行成功`, `已成功`, `已为您完成`, `控制成功`. Phrase scanning SHALL be context-aware and SHALL scan only those error outcome `dialogText`/`ttsText` values; it SHALL exclude accepted, alreadyDone, and partialAcceptPartialRefuse, and SHALL NOT blanket-scan badge labels or `DemoRuntimeResultPresentationMatrix` success/partial strings. The change SHALL add `scripts/run_v9_product_operator_tts_preflight.sh`, which performs a real local AVSpeechSynthesizer/voice lookup for zh-CN/zh* and emits machine-readable PASS/FAIL with proof class `runtime_local_preflight` (not operator, mobile, or true-device). Tests SHALL use exactly CREATE `Tests/MAformacCoreTests/ProductOperatorTTSHardGateTests.swift`, MODIFY `Tests/MAformacCoreTests/SpeechSynthesisEngineTests.swift`, and MODIFY `Tests/MAformacCoreTests/FrontstageContainmentSourceContractTests.swift` under existing `Tests/MAformacCoreTests/`, and SHALL NOT create another App target.

#### Scenario: Chinese voice unavailable fails closed without silent success

- **GIVEN** `bestChineseVoice()` returns nil
- **WHEN** `AVSpeechSynthesisEngine.speak` is invoked with non-empty text
- **THEN** the synthesizer SHALL NOT be called
- **AND** the result SHALL be `.failed(reason: "chinese_voice_unavailable")`

#### Scenario: Core TTS failure freezes PresentationVoiceDisplayState to idle

- **GIVEN** an accepted or rejected turn has a Core `RuntimePresentationPayload`
- **WHEN** speech synthesis returns failed or empty text
- **THEN** the visual payload remains the authority for user-visible outcome
- **AND** the system SHALL NOT report the action as voice-confirmed success solely from TTS status
- **AND** Core `PresentationSnapshot.voiceState` SHALL be `PresentationVoiceDisplayState.idle`
- **AND** Core `PresentationSnapshot.voiceState` SHALL NOT be `PresentationVoiceDisplayState.speak`

#### Scenario: App readback captures SpeechSynthesisResult without false speaking state

- **GIVEN** `ContentView.applyRuntimeReadbackStep` speaks a step
- **WHEN** synthesis returns failed
- **THEN** visual-first progression MAY continue
- **AND** `StagePresentationSnapshot.voiceState` SHALL NOT be `PresentationVoiceState.speaking`
- **AND** TTS failure SHALL be observable
- **AND** voice success SHALL NOT be marked

#### Scenario: Safety or clarify speech has no completion promise

- **GIVEN** the turn outcome is safety refusal, clarify, reject, unsupported, unmounted, or cancel
- **WHEN** TTS text is prepared or spoken from runner or FallbackContext
- **THEN** the text SHALL NOT contain any forbidden completion phrase listed in this requirement
- **AND** the visual state SHALL continue to show the non-success outcome

#### Scenario: Context-aware scan does not false-positive on alreadyDone badges

- **GIVEN** an alreadyDone or accepted outcome uses a badge or success-path string that may contain completion wording
- **WHEN** the TTS hard-gate scanner runs
- **THEN** those excluded outcomes and badge labels SHALL NOT alone fail the hard gate
- **AND** only reject/clarify/safety/unsupported/cancel/unmounted dialogText/ttsText are in scope

#### Scenario: Success path may speak completion readback

- **GIVEN** the turn outcome is an accepted mock action with valid readback
- **WHEN** TTS is enqueued successfully
- **THEN** completion-oriented readback speech MAY be used
- **AND** proof remains bounded by mock offline demonstration class

#### Scenario: Preflight is runtime_local_preflight only

- **GIVEN** `scripts/run_v9_product_operator_tts_preflight.sh` runs a real local voice lookup
- **WHEN** PASS or FAIL is emitted
- **THEN** the proof class SHALL be `runtime_local_preflight`
- **AND** it SHALL NOT be claimed as operator-pass, mobile, or true-device proof

---

### Requirement: T07a local attempt-ledger consumer with synthetic proof cap

The system SHALL provide a local consumer for operator-ceremony attempt ledger and schema/join checks under T07a at `Core/Ceremony/OperatorCeremonyAttemptLedger.swift`, with fixtures under `Tests/Fixtures/t07a-synthetic/` and tests at `Tests/MAformacCoreTests/ProductOperatorT07aLedgerConsumerTests.swift`. The consumer SHALL implement the existing carrier six envelope sections `subject`, `environment`, `attempt`, `axes`, `expiry`, and `evidence` without forking `define-t07-operator-ceremony-carrier-20260712`. Synthetic fixtures SHALL carry `synthetic=true`, `proof_class=local`, and `satisfies_t07b_prerequisite=false`. Local schema or join success SHALL cap at local or `local_schema_join_only` and SHALL NOT unlock T07b, operator-pass, V2 DONE, or V-PASS. Launch mode changes SHALL append a new immutable attempt; later success SHALL NOT overwrite a prior failed attempt.

#### Scenario: Synthetic three-field cap is mandatory

- **GIVEN** a fixture is marked synthetic for T07a local checks
- **WHEN** any of the three synthetic-cap fields is absent or contradictory
- **THEN** the fixture SHALL fail closed
- **AND** it SHALL NOT be accepted as ceremony evidence input

#### Scenario: Mode switch appends a new attempt

- **GIVEN** an attempt failed under one launch mode
- **WHEN** the operator switches launch mode or artifact identity
- **THEN** a new attempt ID SHALL be appended
- **AND** the original failed attempt SHALL remain unchanged

#### Scenario: Local join cannot satisfy T07b

- **GIVEN** synthetic or local fixtures pass schema and exact-join checks
- **WHEN** T07b readiness is evaluated
- **THEN** the result SHALL remain capped at local evidence
- **AND** `satisfies_t07b_prerequisite` SHALL remain false

#### Scenario: Near-match identity fails closed

- **GIVEN** two receipts share a branch or bundle label but differ in repo SHA, dirty verdict, artifact hash, environment, scenario version, or contract version
- **WHEN** join is evaluated by the local consumer
- **THEN** the join SHALL fail closed
- **AND** it SHALL NOT be repaired by filename, branch metadata, or manual override

#### Scenario: Carrier is consumed not forked

- **GIVEN** the T07a carrier already defines envelope and synthetic rules
- **WHEN** this spine implements the local ledger consumer
- **THEN** apply SHALL NOT modify `openspec/changes/define-t07-operator-ceremony-carrier-20260712/**`
- **AND** SHALL NOT materialize a Makefile ceremony gate as spine success

---

### Requirement: Required outcome families are covered without fake success

The system SHALL cover success, reject/clarify/safety, stale generation, cancel/restart, provider failure, force catalog digest gate unit failure, TTS chinese-voice/preflight failure, and offline/recovery outcome families in the product-operator spine tests or fixtures according to each family's honest proof ceiling. Non-success outcomes SHALL NOT be presented as accepted vehicle-state success. Stale generation, cancel/restart, recovery product-path App wiring, and force catalog App consumption remain deferred and unit-or-resource-deferred only in this change. Lane closeout MAY be PARTIAL when those deferrals remain.

#### Scenario: Reject or safety does not mutate as accepted success

- **GIVEN** a turn is classified as reject, clarify, or safety refusal
- **WHEN** presentation and state effects are observed
- **THEN** the system SHALL NOT present the outcome as an accepted successful control action
- **AND** mock vehicle state SHALL not claim a successful write for that refused action

#### Scenario: Provider failure is observable

- **GIVEN** production correlation fails closed
- **WHEN** the turn ends
- **THEN** an observable diagnostic or typed error SHALL exist
- **AND** the receipt SHALL NOT mark the composition spine as fully successful for that turn

#### Scenario: Offline recovery remains demonstration-bounded

- **GIVEN** the demonstration runs offline with mock vehicle state
- **WHEN** recovery or restart is evaluated under local rules
- **THEN** evidence remains offline/local demonstration proof or deferred product wiring
- **AND** it SHALL NOT be reported as true-device, live vehicle, or operator-pass proof

#### Scenario: Partial lane closeout is honest

- **GIVEN** composition/correlation/TTS unit work may pass while product lifecycle App wiring and W9 App force consumption remain deferred
- **WHEN** lane status is summarized
- **THEN** status MAY be PARTIAL
- **AND** SHALL NOT be reported as customer path DONE or W9_APP_CONSUMED

---

### Requirement: Proof classes are stratified and non-substitutable

The system SHALL distinguish `unit`, `source_contract`, `build`, `runtime_local`, `runtime_local_preflight`, `fixture_local`, and `operator` proof classes. A lower or orthogonal class SHALL NOT substitute for a higher or different class. This change SHALL NOT deliver operator proof. Mounted tool count remains one cell and `actionDemoProven=0/120` honesty SHALL NOT be hand-flipped by this spine. Tests SHALL extend existing D1, force-state digest unit, speech, and composition source-contract suites when those suites already cover the behavior; `ProductOperator*` tests SHALL be created only for genuine composition-spine gaps.

#### Scenario: Unit green is not runtime_local

- **GIVEN** only unit tests for reducers, bridges, gates, or fixtures are green
- **WHEN** status is summarized
- **THEN** the summary SHALL NOT claim runtime_local production composition success
- **AND** it SHALL NOT claim customer path done

#### Scenario: Source-contract is not runtime_local

- **GIVEN** App source-contract tests pass by reading `App/FrontstageRuntimeComposition.swift` or `App/ContentView.swift`
- **WHEN** status is summarized
- **THEN** the proof class MAY be `source_contract`
- **AND** it SHALL NOT substitute for runtime_local or operator

#### Scenario: Runtime local preflight is not operator

- **GIVEN** TTS preflight PASS under `runtime_local_preflight`
- **WHEN** operator readiness is evaluated
- **THEN** operator-pass and T07b remain unsatisfied
- **AND** the claim cap stays local

#### Scenario: Runtime local is not operator

- **GIVEN** a local mock runtime_local harness is green
- **WHEN** operator readiness is evaluated
- **THEN** operator-pass and T07b remain unsatisfied
- **AND** the claim cap stays local

#### Scenario: Proven matrix remains honest

- **GIVEN** the capability matrix still has one mounted cell and zero actionDemoProven
- **WHEN** this spine lands locally
- **THEN** receipts SHALL preserve `actionDemoProven=0/120` honesty
- **AND** the spine SHALL NOT expand mounted catalog scope as part of this change

---

### Requirement: Shared seams and deferred packages stay outside scope

The system SHALL keep Makefile, closure registry/checkers, roadmap/decisions writeback, Tools/C6, Tools/C5, contracts/c6-*, Core/Training/**, scripts/*train*, training/**, closure/candidates/B7/V1 packages, `Core/ForceState/**` (non-live tree; force lives under `Core/Config/**`), DialogueStateEffectBoundary modification, ForceStateDigest/ForceStateCatalog/DemoForceStateBoundary modification for App force wiring, and wholesale apply of `define-demo-golden-run-and-voice` outside this change's implementation scope. Prose notes about mainline shared seams are explanatory only and are not path globs. Tasks that would touch those surfaces SHALL stop rather than partially land.

#### Scenario: No-touch path appears in diff

- **GIVEN** an apply attempt modifies a listed no-touch shared seam, invents `Core/ForceState/**`, or modifies DialogueStateEffectBoundary / Force catalog implementation files forbidden by this change
- **WHEN** stop conditions are evaluated
- **THEN** the apply SHALL stop
- **AND** no partial claim of spine completion SHALL be emitted from that dirty tree

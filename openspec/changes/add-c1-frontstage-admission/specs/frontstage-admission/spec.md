## ADDED Requirements

### Requirement: Customer frontstage SHALL use deny-first typed containment before T04 closure

Customer MicDock submissions SHALL enter a stable typed `FrontstageVoiceSession` through App composition. The session SHALL preserve its identity through SwiftUI recomposition and monotonically number submissions. Before the T03/T04 interface cut, every containment submission SHALL yield `refusal_no_available_tool`, zero added readbacks, and no state mutation. It SHALL NOT invoke `MockVoicePresetPlanner`, a legacy mock-intent helper, a tool-call frame, a runner, or a partial executor.

#### Scenario: Two containment turns preserve session identity

- **GIVEN** a customer frontstage composition has been constructed
- **WHEN** it receives two MicDock submissions
- **THEN** both results SHALL have the same nonempty session ID
- **AND** their sequences SHALL be 1 and 2
- **AND** each result SHALL be a no-write `refusal_no_available_tool` with no added readback.

#### Scenario: Customer callback cannot use the mock planner

- **GIVEN** the App source is checked
- **WHEN** either customer MicDock callback is inspected
- **THEN** it SHALL call the composition session
- **AND** it SHALL NOT name `MockVoicePresetPlanner` or `applyMockVoiceColdIntent` as its callback.

### Requirement: Frontstage containment receipt SHALL bind the current turn to a five-key run identity

The receipt is one latest-turn JSON object, not a ledger. In foreign emit mode it SHALL require `C1_FRONTSTAGE_RECEIPT_EMIT=1`, `C1_FRONTSTAGE_RUN_ID`, `C1_FRONTSTAGE_RUN_NONCE`, `C1_RUN_DIR`, and `C1_FRONTSTAGE_SOURCE_HEAD_SHA`. A missing or invalid foreign value SHALL write zero bytes and SHALL NOT fall back. A valid foreign write SHALL use only `$C1_RUN_DIR/receipts/c1/frontstage-route-receipt.v1.json`, write atomically, and include run/session/turn/event/sequence identity plus typed denial/no-write facts.

#### Scenario: Foreign ABI input is incomplete

- **GIVEN** `C1_FRONTSTAGE_RECEIPT_EMIT=1`
- **AND** one other ABI key is absent or invalid
- **WHEN** a containment turn completes
- **THEN** no receipt SHALL be written
- **AND** no default run directory SHALL be used.

#### Scenario: Current receipt is atomically replaced

- **GIVEN** two valid containment turns in one process/session/run identity
- **WHEN** each turn completes
- **THEN** the receipt path SHALL contain only the latest turn
- **AND** the session/run/nonce SHALL stay stable while sequence advances from 1 to 2.

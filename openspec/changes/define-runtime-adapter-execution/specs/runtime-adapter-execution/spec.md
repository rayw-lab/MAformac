## ADDED Requirements

### Requirement: Runtime Adapter V0 Owns Mock Execution

The system SHALL expose a mainline Runtime Adapter V0 execution boundary that owns local mock write execution for vehicle-control tool frames under local/unit proof.

#### Scenario: Adapter applies the first command through the mock store

GIVEN a valid tool frame, stable command identity, and available mock state cell
WHEN Runtime Adapter V0 executes the command for the first time
THEN it SHALL apply the mock transition through `DemoVehicleStateStore.applyMockTransition`
AND it SHALL return readback from the store path
AND it SHALL record execution provenance as `first_execution`.

#### Scenario: Adapter owns the C005 write path

GIVEN a local/unit runtime adapter execution test
WHEN a command mutates mock state
THEN the write SHALL be performed by the runtime adapter boundary
AND the test SHALL NOT rely on UIUE code or ad hoc direct store mutation as the ownership proof.

### Requirement: Stable Command Identity And Fingerprint

The system SHALL bind every Runtime Adapter V0 execution attempt to a stable command identity and a deterministic request fingerprint for idempotency decisions.

#### Scenario: Same command identity and same request can replay

GIVEN a command identity has already completed successfully for a request fingerprint
WHEN the adapter receives the same command identity with the same request fingerprint
THEN it SHALL treat the attempt as a retry replay
AND it SHALL NOT apply a second state mutation.

#### Scenario: Same command identity with different request fails closed

GIVEN a command identity has already completed successfully for one request fingerprint
WHEN the adapter receives the same command identity with a different request fingerprint
THEN it SHALL reject the attempt as an idempotency conflict
AND it SHALL NOT replay the old readback
AND it SHALL NOT apply a new mutation.

### Requirement: Retry Replay Does Not Double-Write

The system SHALL ensure a retry replay for an already-applied command does not change mock state revision or timestamp.

#### Scenario: Retry replay preserves revision

GIVEN a first execution changed a mock state cell revision
WHEN the same command identity and request fingerprint are retried
THEN the adapter SHALL return the recorded or verified current readback
AND the cell revision SHALL remain unchanged.

### Requirement: Failed Commands Do Not Create Successful Ledger Entries

The system SHALL record successful idempotency ledger entries only after execution produces a valid write/readback result.

#### Scenario: Unsupported command is not cached as success

GIVEN a command uses an unsupported tool name or invalid execution input
WHEN Runtime Adapter V0 rejects or throws before a valid write/readback
THEN the ledger SHALL NOT record a successful result for that command identity.

#### Scenario: Retry after failed command may execute after input is corrected

GIVEN a command identity previously failed before a successful ledger entry existed
WHEN a later attempt supplies valid input under an allowed identity/fingerprint
THEN the adapter SHALL evaluate it as a new executable attempt rather than replaying a fake success.

### Requirement: Already-State Remains No-Op With Readback

The system SHALL preserve already-state no-op semantics inside Runtime Adapter V0 instead of treating no mutation as unsupported or hidden success.

#### Scenario: Already-state command returns no-op provenance

GIVEN the target mock state already equals the desired value
WHEN Runtime Adapter V0 executes the command
THEN it SHALL return readback without mutating revision or timestamp
AND it SHALL record execution provenance as `already_state_noop`.

### Requirement: Runtime Adapter V0 Proof Cap

Runtime Adapter V0 SHALL be treated as local/unit execution proof only until a later change supplies production runtime, persistence, mobile, true-device, live, or merge evidence.

#### Scenario: Local adapter proof does not imply readiness

GIVEN Runtime Adapter V0 local/unit tests pass
WHEN project receipts or UIUE guard documents describe the result
THEN they SHALL NOT claim R5 complete, runtime-ready, mobile proof, true-device proof, voice-ready, model-ready, golden-ready, endpoint-ready, UIUE merge, V-PASS, S-PASS, U-PASS, A-2, A-2 ready, or A-2 complete.

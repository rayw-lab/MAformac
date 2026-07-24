## ADDED Requirements

### Requirement: Production D-domain decoding SHALL consume completion metadata

The production D-domain decoder SHALL receive content, finish reason, stop reason,
declared tool-call count, and source as one typed completion envelope. Missing or unknown
required metadata SHALL fail closed before tool projection.

#### Scenario: Missing source is rejected

- **GIVEN** a completion envelope without a non-empty source
- **WHEN** the D-domain decoder validates the envelope
- **THEN** it returns a typed decode-shape rejection and produces zero tool frames

#### Scenario: Unknown finish reason is rejected

- **GIVEN** a completion envelope with an unsupported finish reason
- **WHEN** the D-domain decoder validates the envelope
- **THEN** it returns a typed decode-shape rejection and produces zero tool frames

### Requirement: The parser SHALL validate the entire completion shape

The parser SHALL accept only complete `<tool_call>` blocks with valid JSON bodies. It
SHALL reject extra text, malformed tags, bare JSON, oversized content, and a mismatch
between declared and parsed tool-call counts.

#### Scenario: Declared count differs from parsed count

- **GIVEN** an envelope declaring two tool calls whose content contains one call
- **WHEN** the parser validates the completion
- **THEN** it rejects the completion and produces zero tool frames

#### Scenario: Extra text surrounds a tool call

- **GIVEN** otherwise valid tool-call content with any non-whitespace surrounding text
- **WHEN** the parser validates the completion
- **THEN** it rejects the completion and produces zero tool frames

### Requirement: Tool-plan cardinality SHALL be explicit and fail closed

An exactly-one policy SHALL accept exactly one call. A reviewed bounded policy SHALL
accept one or two calls and SHALL reject zero or more than two calls. The backend SHALL
project every accepted call in order and SHALL NOT select only the first call.

#### Scenario: Exactly-one policy receives two calls

- **GIVEN** a valid envelope containing two calls
- **WHEN** the exactly-one cardinality policy is applied
- **THEN** decoding is rejected and zero tool frames are produced

#### Scenario: Reviewed bounded policy receives two calls

- **GIVEN** a valid envelope containing two calls
- **WHEN** the reviewed bounded policy is applied
- **THEN** both calls proceed through per-item validation and projection in order

#### Scenario: Reviewed bounded policy receives three calls

- **GIVEN** a valid envelope containing three calls
- **WHEN** the reviewed bounded policy is applied
- **THEN** decoding is rejected and zero tool frames are produced

### Requirement: Stale state SHALL remain a runtime state-gate concern

The completion parser SHALL NOT classify stale turn, trace, or digest state as a decode
failure. Existing runtime state gates SHALL retain that authority.

#### Scenario: Decode succeeds before a stale-state refusal

- **GIVEN** a structurally valid completion envelope and stale downstream turn state
- **WHEN** the completion is decoded and then offered to the runtime state gate
- **THEN** decode may succeed but the state gate refuses mutation and readback

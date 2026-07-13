## ADDED Requirements

### Requirement: W7 P1/P2 typed schema skeleton is versioned and fail-closed prior to production wiring

The system SHALL expose the DialogueState typed schema skeleton (window envelope, group disposition, field validity record, authoritative checkpoint, focus owner-window, and versioned effect matrix types) as Codable value types with supported schema version, canonical encoding, and closed rejection of missing identity, unknown enumerations, and unsupported versions. The skeleton SHALL remain read-only to any future consumer, SHALL NOT be wired to the demo runtime session runner, SHALL NOT own W8 lifecycle facts, and SHALL NOT be claimed as a source or consumption gate green.

#### Scenario: Supported typed skeleton round-trips

- **GIVEN** the typed schema skeleton values use supported schema version and known enumeration cases
- **WHEN** each schema value is encoded to canonical JSON and decoded
- **THEN** all field bindings, disposition, validity records, checkpoint metadata, focus owner-window expiry, and effect matrix entries round-trip exactly
- **AND** no schema value mutates its inputs during encoding, decoding, or validation

#### Scenario: Unknown enumeration or unsupported version fails closed

- **GIVEN** a schema value carries an unknown disposition raw value, unknown W8 fact raw value, or unsupported schema/effect matrix version
- **WHEN** the schema value is validated or applied
- **THEN** the operation returns a typed failure and no field mutation, checkpoint rebind, focus renewal, or effect application occurs
- **AND** the failure preserves the offending raw value for audit while refusing to promote it to a supported case

#### Scenario: Skeleton stays disconnected from production runtime

- **GIVEN** the typed schema skeleton exists in Core/State without runtime wiring
- **WHEN** the demo runtime session runner executes any dialogue turn
- **THEN** it continues to use the legacy DialogueState skeleton without importing, invoking, or observing the new typed schema types
- **AND** the presence of the typed schema skeleton is not reported as W7 done, verify-dialogue-state-source green, verify-dialogue-state-consumption green, integration proof, operator pass, or vetted proof

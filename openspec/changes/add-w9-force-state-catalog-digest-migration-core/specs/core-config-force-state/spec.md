## ADDED Requirements

### Requirement: M16-011 Catalog SHALL Provide a Typed Swift Value Surface

The system SHALL provide a Swift value-typed catalog surface consisting of exhaustive `debug`/`demo` kind and namespace enums, a required-field entry record with stable identity, kind, namespace, version, and owner metadata, and a load factory that rejects duplicate stable identity, empty stable identity, empty version, and empty owner. Constructing a second same-meaning catalog authority through the typed surface SHALL be prevented at the aggregator level.

#### Scenario: Both explicit kinds load into one typed catalog

- **GIVEN** a caller passes exactly one `debug` entry and one `demo` entry with distinct stable identities, non-empty versions, and non-empty owners
- **WHEN** the caller invokes the catalog load factory
- **THEN** the load SHALL return one typed catalog containing both entries under their explicit kind and namespace fields
- **AND** the returned catalog SHALL expose both entries as an ordered enumeration.

#### Scenario: Duplicate stable identity fails closed

- **GIVEN** a caller passes two entries with the same stable identity, regardless of kind or namespace
- **WHEN** the caller invokes the catalog load factory
- **THEN** the load SHALL throw a duplicate-identity error
- **AND** no partial catalog SHALL be returned.

#### Scenario: Empty required metadata fails closed

- **GIVEN** a caller passes any entry with an empty stable identity, empty version, or empty owner
- **WHEN** the caller invokes the catalog load factory
- **THEN** the load SHALL throw an empty-metadata error
- **AND** no catalog SHALL be returned.

#### Scenario: Second same-meaning catalog authority is rejected

- **GIVEN** a caller attempts to hold two live catalog instances through the aggregator
- **WHEN** the aggregator is asked to install a second catalog
- **THEN** the aggregator SHALL throw a second-authority error
- **AND** only the first installed catalog SHALL remain retrievable.

### Requirement: M16-011 Digest SHALL Compute Canonically and Fail Closed on Mismatch

The system SHALL compute the catalog digest deterministically over the complete load-bearing entry set using a declared algorithm identifier and canonicalization version. Digest computation SHALL be independent of the caller's input ordering after canonicalization. Any load-bearing field change SHALL alter the digest. Absent metadata, an unknown algorithm identifier, an unknown canonicalization version, or a mismatched digest SHALL fail closed without a silent recomputed replacement.

#### Scenario: Order-independent digest for identical entry sets

- **GIVEN** two catalogs contain the identical set of entries in different input orders
- **WHEN** the digest is computed for each
- **THEN** both digests SHALL be byte-equal.

#### Scenario: Load-bearing field change flips the digest

- **GIVEN** two catalogs differ in any single stable identity, kind, namespace, version, or owner
- **WHEN** the digest is computed for each
- **THEN** the two digests SHALL differ.

#### Scenario: Absent metadata fails closed

- **GIVEN** a consumer receives no digest metadata alongside a catalog
- **WHEN** it validates the catalog against the missing metadata
- **THEN** the validation SHALL throw an absent-metadata error
- **AND** no silent recomputation or continuation SHALL occur.

#### Scenario: Unknown algorithm or canonicalization version fails closed

- **GIVEN** a consumer receives metadata whose algorithm identifier or canonicalization version is not the declared value
- **WHEN** it validates the catalog against that metadata
- **THEN** the validation SHALL throw an unknown-algorithm error
- **AND** no fallback algorithm SHALL be attempted.

#### Scenario: Mismatched digest fails closed without silent repair

- **GIVEN** a consumer receives metadata whose digest disagrees with the recomputed canonical digest
- **WHEN** it validates the catalog against that metadata
- **THEN** the validation SHALL throw a mismatch error
- **AND** no locally recomputed replacement digest SHALL be substituted or silently continued.

### Requirement: M16-011 Migration Ledger SHALL Reject Fuzzy, Ambiguous, and 4↔5 Mappings

The system SHALL represent supported catalog migrations as explicit typed rows with required source stable identity, target stable identity, direction, reason, and evidence. Missing, duplicate, ambiguous, empty-evidence, and empty-identity rows SHALL be rejected at ledger load. Resolution SHALL return exactly one row for a given source and direction or a missing-row error. A `4↔5` mapping SHALL be rejected in both directions unconditionally, and no similarity, positional, or inferred mapping SHALL be synthesised.

#### Scenario: Explicit row resolves exactly one migration

- **GIVEN** a caller loads a ledger with one row from `A` to `B` in the forward direction with non-empty evidence
- **WHEN** the caller resolves migration of source `A` in the forward direction
- **THEN** the resolver SHALL return that single row unchanged.

#### Scenario: Forbidden 4-to-5 mapping is rejected in both directions

- **GIVEN** a caller submits a row whose source and target stable identities are `4` and `5` in either direction
- **WHEN** the ledger loads the row
- **THEN** the load SHALL throw a forbidden-4-to-5 error
- **AND** no row SHALL be added to the ledger.

#### Scenario: Duplicate row is rejected

- **GIVEN** a caller submits two rows with identical source, target, direction, and reason
- **WHEN** the ledger loads the rows
- **THEN** the load SHALL throw a duplicate-row error.

#### Scenario: Ambiguous mapping is rejected

- **GIVEN** a caller submits two rows with the same source and direction but different targets
- **WHEN** the ledger loads the rows
- **THEN** the load SHALL throw an ambiguous-row error.

#### Scenario: Empty evidence fails closed

- **GIVEN** a caller submits a row whose evidence is empty
- **WHEN** the ledger loads the row
- **THEN** the load SHALL throw an empty-evidence error.

#### Scenario: Missing row query fails closed

- **GIVEN** a caller resolves a source and direction for which no explicit row exists
- **WHEN** the resolver is queried
- **THEN** the resolver SHALL throw a missing-row error
- **AND** no similarity, positional, or inferred fallback row SHALL be returned.

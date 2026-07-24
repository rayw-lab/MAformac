# W9 Core-Only Catalog / Digest / Migration Ledger Design

## Context

- `openspec/specs/core-config-force-state/spec.md:93-145` already declares the three M16-011 SHALL Requirements as ratified authority (D-152, `docs/commander-log/decisions.md:1384`). No Swift code presently backs those Requirements; `Core/Config/` holds only `DemoForceStateBoundary.swift` and `SceneMacroRegistry.swift`, neither of which materializes a physical catalog, a digest, or a migration ledger.
- V9 dispatch §4.C2 authorises a K2-catalog-only slice: land the typed Swift API for M16-011 alone, without touching M16-012 (`Core/State/DemoVehicleStateStore.swift:123` `replaceCells` seam) or the four `App/ContentView.swift` direct-write call sites (`:423,694,756,883`).
- The W8 K2 typed terminal/fence acknowledgement fixture is missing (Q5 verdict `FIXTURE_ABSENT_D2_BLOCKED`). That gate only blocks the M16-012 cutover slice; it does not block the catalog/digest/migration-ledger core types.

## Goals

1. Provide a single, ownership-typed catalog surface that satisfies the three M16-011 Requirements in Swift form, so future D2 cutover work can consume it.
2. Provide fail-closed semantics for every negative Scenario declared by `spec.md:93-145`.
3. Keep the writeset entirely independent of the M16-012 cutover, the App direct writers, and any file already owned by another concurrent worktree.

## Non-goals

- Wire the new types into `DemoForceStateBoundary`, `DemoVehicleStateStore`, or any App/UI presentation path.
- Compute a canonical digest that becomes a customer-facing production identity; the digest here is a deterministic Swift function callable from local/unit tests only.
- Encode any real migration between historical catalogs; the ledger accepts explicit rows and rejects everything else, so the initial ledger is empty by construction.

## Architectural decisions

### AD-1 Single physical catalog owned in Swift value types

- Introduce `ForceStateCatalogKind { case debug, demo }` and `ForceStateCatalogNamespace { case debug, demo }` as `Equatable`/`Codable`/`Sendable` enums so the two explicit `debug` and `demo` values are exhaustive and enum-guarded. Any third kind/namespace is a compile-time impossibility.
- Introduce `ForceStateCatalogEntry` with `stableIdentity: String`, `kind: ForceStateCatalogKind`, `namespace: ForceStateCatalogNamespace`, `version: String`, `owner: String`. Every field is required at initialisation; no defaults, no optional fields.
- Introduce `ForceStateCatalog` with a private `[ForceStateCatalogEntry]` sequence built from a validating factory `ForceStateCatalog.load(entries:)`. Validation rejects: duplicate `stableIdentity`, any third kind/namespace value (unreachable in typed API but validated for JSON-decoded input), and any attempt to construct a "second same-meaning catalog" by allowing at most one instance in an owning aggregator.
- Provide `throws` factories only; no default `init`. Consumers cannot construct a catalog that violates M16-011.

### AD-2 Deterministic digest via canonical entry ordering

- Introduce `ForceStateDigestAlgorithm { case sha256V1 }` and `ForceStateCanonicalizationVersion { case v1 }` as typed identifiers.
- Introduce `ForceStateDigestMetadata { algorithm, canonicalizationVersion, digestHex }`.
- Compute the canonical digest as `SHA256(canonicalPayload(entries))` where `canonicalPayload`:
  1. Sorts `[ForceStateCatalogEntry]` lexicographically by `(kind.rawValue, namespace.rawValue, stableIdentity)`.
  2. Serialises each entry as `"kind|namespace|stableIdentity|version|owner\n"` with UTF-8 and no trailing newline on the aggregate string other than the per-entry `\n`.
  3. Hashes the aggregate byte sequence with `CryptoKit.SHA256`.
- Because ordering is derived from a total lexicographic key over three fields, two catalogs with identical entries but different input insertion orders produce identical `digestHex`; any load-bearing change to `entry`, `kind`, `namespace`, `version`, `owner`, or algorithm/canonicalization version alters the digest.
- Any consumer that receives a `ForceStateDigestMetadata` whose `algorithm` or `canonicalizationVersion` is unknown, whose `digestHex` disagrees with the recomputed value, or whose metadata is absent must throw `ForceStateDigestError.mismatchNotRepairedLocally` or `.absentMetadata`. No silent recomputation is allowed.

### AD-3 Exact migration ledger with hard-coded 4↔5 refusal

- Introduce `ForceStateMigrationDirection { case forward, reverse }` and `ForceStateMigrationRow { sourceStableIdentity, targetStableIdentity, direction, reason, evidence }`, all required fields.
- Introduce `ForceStateMigrationLedger.load(rows:)` that:
  - Rejects any row whose `(sourceStableIdentity, targetStableIdentity)` pair matches `("4","5")` or `("5","4")` — the M16-011 hard refusal.
  - Rejects duplicate rows (same tuple across all five fields except `evidence`).
  - Rejects ambiguous rows (same `sourceStableIdentity` mapped to multiple `targetStableIdentity` in the same direction).
  - Rejects any request whose evidence is empty — treated as "missing evidence", which the spec labels fail-closed.
- Provide a `resolve(source:direction:)` query that returns exactly one `ForceStateMigrationRow` or throws `.missingRow`; there is no "similarity fallback", "positional guess", or "inferred mapping".

### AD-4 No cutover wiring

- None of the new types is imported by `DemoForceStateBoundary`, `DemoVehicleStateStore`, `App/ContentView`, or any presentation adapter. They are consumed only by their dedicated tests. The M16-012 owner-graph and the App direct-write elimination remain the responsibility of the future D2 cutover slice.

## Testing strategy

- `ForceStateCatalogTests` covers: happy load with one debug entry and one demo entry; duplicate stable identity rejection; empty catalog is allowed (spec does not require entries, only exhaustive kind/namespace typing); catalog aggregator refuses to hold two `ForceStateCatalog` instances simultaneously (no "second same-meaning authority").
- `ForceStateDigestTests` covers: order-independence (two catalogs with same entries in different order produce the same digest); load-bearing entry change flips the digest; owner/version/kind/namespace change each flip the digest; absent metadata throws `.absentMetadata`; mismatched digest throws `.mismatchNotRepairedLocally`.
- `ForceStateMigrationLedgerTests` covers: happy resolution of one explicit row; forbidden `4↔5` mapping in both directions; duplicate row rejection; ambiguous row rejection; empty evidence rejection; missing-row query rejection.

## Alternatives considered

- **Single-file bundle**: Rejected. The three M16-011 Requirements have three distinct SHALL responsibilities; keeping them in separate files matches OpenSpec's "one concept per file" preference and keeps future D2 cutover imports minimal.
- **Return-based failure**: Rejected. Every negative Scenario in `spec.md:93-145` says "SHALL fail closed", which maps to Swift `throws` more faithfully than to optional/nil returns.
- **Extending `DemoForceStateBoundary` in place**: Rejected. That file's writeset is shared with M16-012 cutover work; touching it would violate the K2 catalog-only scope and could collide with the D2 cutover slice.

## Proof cap

- All validation is capped to `LocalUnit`. `swift test --filter ForceState*Tests` is the only proof surface. No `make verify`, no runtime, no operator ceremony, no CI attestation is inferred from a green test. This slice does not raise `actionDemoProven` above `0/120` and does not activate M16-012 cutover.

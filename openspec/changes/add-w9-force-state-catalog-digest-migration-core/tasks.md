# W9 Core-Only Catalog / Digest / Migration Ledger Tasks

> Every unchecked box represents work to be performed inside this K2-catalog-only slice. `HISTORICAL_CHECKBOX_ONLY` markers are avoided — this is a fresh code-only slice. Proof cap on every task is `local_unit`.

## 1. Typed catalog surface

- [ ] 1.1 Add `Core/Config/ForceStateCatalog.swift` with `ForceStateCatalogKind`, `ForceStateCatalogNamespace`, `ForceStateCatalogEntry`, `ForceStateCatalog`, and `ForceStateCatalogError`; no default `init`; validating `load(entries:)` factory only.
- [ ] 1.2 Encode `debug`/`demo` as exhaustive enum cases so no third kind/namespace is representable.
- [ ] 1.3 Reject duplicate `stableIdentity` and empty `stableIdentity`/`version`/`owner` at load.
- [ ] 1.4 Add `Tests/MAformacCoreTests/ForceStateCatalogTests.swift` covering: two-kind happy load, duplicate identity rejection, empty owner/version rejection, no-second-authority behaviour (`ForceStateCatalogAggregator` refuses two live catalogs).

## 2. Canonical digest

- [ ] 2.1 Add `Core/Config/ForceStateDigest.swift` with `ForceStateDigestAlgorithm`, `ForceStateCanonicalizationVersion`, `ForceStateDigestMetadata`, `ForceStateDigest` computation, and `ForceStateDigestError`.
- [ ] 2.2 Implement `ForceStateDigest.canonicalDigest(of:)` producing a deterministic hex digest computed by sorting entries lexicographically on `(kind.rawValue, namespace.rawValue, stableIdentity)`, encoding as `kind|namespace|stableIdentity|version|owner\n`, and hashing with `CryptoKit.SHA256`.
- [ ] 2.3 Implement `ForceStateDigest.validate(metadata:against:)` that throws `.absentMetadata`, `.unknownAlgorithm`, or `.mismatchNotRepairedLocally` and never silently recomputes a replacement digest.
- [ ] 2.4 Add `Tests/MAformacCoreTests/ForceStateDigestTests.swift` covering: order-independence, sensitivity to entry/version/owner/kind/namespace changes, `.absentMetadata`, `.unknownAlgorithm`, and `.mismatchNotRepairedLocally`.

## 3. Exact migration ledger

- [ ] 3.1 Add `Core/Config/ForceStateMigrationLedger.swift` with `ForceStateMigrationDirection`, `ForceStateMigrationRow`, `ForceStateMigrationLedger`, and `ForceStateMigrationError`.
- [ ] 3.2 Reject `4↔5` mappings in both directions unconditionally.
- [ ] 3.3 Reject duplicate rows, ambiguous rows (same source resolving to multiple targets in one direction), empty-evidence rows, and empty-identity rows at `load(rows:)`.
- [ ] 3.4 Provide `resolve(source:direction:)` returning exactly one `ForceStateMigrationRow` or throwing `.missingRow`; provide no similarity/positional/inferred fallback.
- [ ] 3.5 Add `Tests/MAformacCoreTests/ForceStateMigrationLedgerTests.swift` covering: happy row resolution, forbidden `4↔5` rejection in both directions, duplicate rejection, ambiguous rejection, empty-evidence rejection, missing-row query rejection.

## 4. Validation and reporting

- [ ] 4.1 Run `openspec validate add-w9-force-state-catalog-digest-migration-core --strict` and require rc 0.
- [ ] 4.2 Run `swift test --filter ForceState` and require all new tests green; do not run the full suite (out of scope, other worktrees may hold uncommitted changes here that would trip unrelated targets).
- [ ] 4.3 Run `git status --short` and confirm only the owned paths appear (`Core/Config/ForceStateCatalog.swift`, `Core/Config/ForceStateDigest.swift`, `Core/Config/ForceStateMigrationLedger.swift`, `Tests/MAformacCoreTests/ForceStateCatalogTests.swift`, `Tests/MAformacCoreTests/ForceStateDigestTests.swift`, `Tests/MAformacCoreTests/ForceStateMigrationLedgerTests.swift`, `openspec/changes/add-w9-force-state-catalog-digest-migration-core/**`).
- [ ] 4.4 Commit each semantic slice separately: (a) openspec change carrier, (b) catalog + digest + migration Swift core, (c) tests, with commit messages noting `K2-catalog-only self-authorized per V9 dispatch §4.C2, not RISK-ACK-W9 scope`.
- [ ] 4.5 Write `CLOSEOUT-W9-core.md` under `runs/2026-07-13-w8-runtime-spine-auto/claudecode-longrun-v9-parallel/evidence/W9_core_producer/` with: branch, head SHA, commit list, change id, `openspec validate --strict` result, `swift test --filter` counts, `git status` clean confirmation, residual risks, and the explicit D2 dependency note (M16-012 cutover + W8 K2 typed fence acknowledgement fixture still gated).

## 5. Non-tasks (belong to a later D2 slice, do not perform here)

- [ ] 5.1 Do not wire the new types into `DemoForceStateBoundary.accept` or the M16-012 owner graph.
- [ ] 5.2 Do not modify `Core/State/DemoVehicleStateStore.swift`, `replaceCells`, or `App/ContentView.swift` direct writers.
- [ ] 5.3 Do not consume any W8 typed terminal or fence acknowledgement fixture; those are D2 inputs.
- [ ] 5.4 Do not modify the shared closure checker, `Tests/test_closure_work_packages.py`, `Makefile`, generated codegen products, or any file already owned by another worktree branch.
- [ ] 5.5 Do not claim runtime, mobile, true-device, live API, operator-pass, V-PASS, S-PASS, U-PASS, `actionDemoProven` progress, or W9 DONE.

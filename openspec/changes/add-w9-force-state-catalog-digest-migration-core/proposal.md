status: `code_only_slice`
status_source: `V9 dispatch §4.C2 self-authorized K2-catalog-only; D-152 M16-011 authority-only spec already ratified`
status_updated: `2026-07-13`
v9_slice_id: `W9-core-K2`
relation_type: `implements`
authority_refs: [`openspec/specs/core-config-force-state/spec.md:93-145`, `docs/commander-log/decisions.md D-152`]
proof_cap: `local_unit_only`
scope: `catalog + digest + migration-ledger typed Swift API + tests only; no cutover, no applier, no App direct-write removal`
blocked_on_none: `core-only slice is spec-independent from M16-012 cutover and W8 K2 typed terminal/fence ack fixtures`

## Why

`openspec/specs/core-config-force-state/spec.md:93-145` already declares the three M16-011 authority Requirements (Single Physical Core Catalog, Catalog Digest Contract, Exact Migration Ledger) as ratified authority under D-152. Zero Swift code currently backs those SHALL statements: `Core/Config/` contains only `DemoForceStateBoundary.swift` and `SceneMacroRegistry.swift`, neither of which materializes a physical catalog, a canonical digest, or an exact migration ledger.

Under V9 dispatch §4.C2 the writeset of these three new files is independent of `Core/State/DemoVehicleStateStore.swift:123` (`replaceCells` CRITICAL seam), independent of the four `App/ContentView.swift` direct-write callers, and independent of the missing W8 K2 typed terminal/fence acknowledgement fixture. The producer therefore self-authorizes a K2-catalog-only slice: it lands the typed Swift API for the M16-011 catalog family alone, without touching M16-012 cutover, the boundary applier, or App writers.

## What Changes

- Add `Core/Config/ForceStateCatalog.swift` exposing typed `ForceStateCatalogKind` (`debug`/`demo`), typed `ForceStateCatalogEntry` metadata, and a single-catalog aggregator with duplicate/unknown fail-closed validation.
- Add `Core/Config/ForceStateDigest.swift` exposing a declared algorithm identifier, canonicalization version, and canonical digest computation over the complete load-bearing catalog entry set, with mismatch fail-closed behaviour.
- Add `Core/Config/ForceStateMigrationLedger.swift` exposing typed `ForceStateMigrationRow` records, direction, reason, evidence, and rejection of missing/duplicate/ambiguous/inferred/positional/similarity-based mappings, plus a hard-coded refusal of `4↔5` mappings.
- Add `Tests/MAformacCoreTests/ForceStateCatalogTests.swift`, `ForceStateDigestTests.swift`, `ForceStateMigrationLedgerTests.swift` covering happy path plus each fail-closed contract.
- Do not modify `spec.md`; the three M16-011 authority Requirements already exist in ratified form.

## Non-goals

- Do not modify `Core/State/DemoVehicleStateStore.swift`, `replaceCells`, or any App/UI direct-write call site.
- Do not implement the M16-012 boundary→applier→projection pipeline, the Core applier, or projection-only presentation.
- Do not consume W8 typed terminal or fence acknowledgement fixtures; those remain GATED for a separate D2 cutover slice.
- Do not touch `Makefile`, `Tests/test_closure_work_packages.py`, closure checker/registry/index, generated codegen products, or any other worktree branch's files.
- Do not claim runtime, mobile, true-device, live API, operator-pass, V-PASS, S-PASS, U-PASS, W9 DONE, or `actionDemoProven` proof; the maximum proof class is `local_unit`.
- Do not modify existing files under `Core/Config/` (`DemoForceStateBoundary.swift`, `SceneMacroRegistry.swift`).

## Proof cap

Local/unit only. Every claim tracked by this slice is capped to `LocalUnit`; no CI, remote, integration, runtime, operator, mobile, live-api, V-PASS, or `actionDemoProven` promotion is inferred from a green test.

## Capabilities

### Modified Capabilities

- `core-config-force-state`: same behavioural authority already declared in `openspec/specs/core-config-force-state/spec.md:93-145`; this slice adds three code-shape Requirements that pin the typed Swift API surface for M16-011 catalog, digest, and migration ledger without touching M16-012 or D16 Requirements.

## Impact

- Adds three new Swift source files under `Core/Config/` and three new test files under `Tests/MAformacCoreTests/`; no existing symbol is renamed or deleted.
- Does not change the observed authority chain around `DemoForceStateBoundary` or `SceneMacroRegistry`; those files are untouched.
- Does not resolve the four `App/ContentView.swift` direct-write call sites or unblock M16-012 cutover; that work remains gated on the D2 slice and the W8 K2 typed terminal/fence ack fixture.

# R5 D18 Gate 2 Durable Ledger Code And Tests

Date: 2026-06-29
Label: `D18_GATE_2_DURABLE_LEDGER_CODE_TESTS`
Repo: `/Users/wanglei/workspace/MAformac`
Proof class: `local` / `unit` / `static`
Status: `DONE`

## Conclusion

Gate 2 implements the smallest main-owned local durable adapter ledger boundary in `DemoRuntimeAdapter`. The default `public init()` remains session-scoped. Tests inject an internal file-backed ledger store backed by a deterministic temporary directory to prove cross-adapter reconstruction and fail-closed behavior.

This is `local_durable_adapter_ledger` proof only. It is not production durable runtime, mobile, true-device, live API, UIUE merge, V-PASS, S-PASS, U-PASS, A-2, voice/model/golden/endpoint readiness, or R5 completion proof.

## Scope Contract

| Item | Contract |
| --- | --- |
| Goal | Prove adapter success/retry readback survives adapter reconstruction with explicit local file-backed storage. |
| Non-goals | No C3 cross-pipeline reconstruction, no UIUE writes, no presentation payload expansion, no production durable runtime. |
| Scope in | `Core/Execution/DemoRuntimeAdapter.swift`, `Tests/MAformacCoreTests/DemoRuntimeAdapterTests.swift`, OpenSpec task ledger, this receipt. |
| Scope out | `C3ExecutionPipeline.swift` until Gate3; UIUE repo; `RuntimePresentationPayload`; production/mobile/live surfaces. |
| Writable paths | Gate2 owned paths only. |
| Stop conditions | GitNexus unexplained HIGH/CRITICAL, test failure not fixable in owned scope, durable wording promoted beyond local proof, private fields exposed to presentation/UIUE. |

## Implementation

- Added internal `DemoRuntimeAdapterLedgerStore` injection path and internal `FileBackedDemoRuntimeAdapterLedgerStore`.
- Added `DemoRuntimeAdapterLedgerSnapshot` with schema version `r5.d18.local_durable_adapter_ledger.v1`.
- Added durable success records for command identity, request fingerprint, and readback.
- Persisted success only after side effect and readback reconciliation.
- Persisted private failure records as observability only; they never replay as success.
- Added fail-closed errors for corrupt/unknown durable ledger load and durable write failure.
- Kept the default `DemoRuntimeAdapter()` constructor session-scoped so D14 semantics remain intact unless tests or future main code inject storage.

## Tests Added

- `testDurableLedgerReplaysAcrossNewAdapterWithoutSecondWrite`
- `testDurableLedgerFingerprintMismatchFailsClosedAcrossAdapter`
- `testCorruptDurableLedgerFailsClosedWithoutMutation`
- `testUnknownDurableLedgerSchemaFailsClosedWithoutMutation`
- `testDurableFailureRecordDoesNotCreateSuccessfulReplay`
- `testDurableReplayReconcilesCurrentStoreReadback`

## GitNexus

| Probe | Result |
| --- | --- |
| `node .gitnexus/run.cjs analyze` | PASS; index refreshed, 28,143 nodes / 49,932 edges / 300 flows. |
| `context(DemoRuntimeAdapter)` | Found `Core/Execution/DemoRuntimeAdapter.swift`; incoming includes `RuntimeAdapterBox.resolve` and adapter tests; affected process includes `replaySettledStaleRequestIfAvailable`. |
| `impact(DemoRuntimeAdapter, upstream, includeTests)` | `CRITICAL`: 90 impacted, 63 direct, 1 affected process, modules `Execution` and `MAformacCoreTests`. |
| `impact(DemoRuntimeAdapterResult, upstream, includeTests)` | `LOW`: 11 impacted, 2 direct, 0 affected processes. |
| `impact(DemoRuntimeAdapterError, upstream, includeTests)` | `LOW`: 0 impacted. |
| `detect_changes(scope=staged)` | `medium`: 30 changed symbols, 1 affected process, 4 changed files. Affected process is `ReplaySettledStaleRequestIfAvailable -> DemoRuntimeAdapter`. |

Interpretation: the `DemoRuntimeAdapter` CRITICAL is expected because Gate2 intentionally edits the adapter execution boundary. The mitigation is additive storage injection, preserving default session behavior, and targeted adapter/presentation tests before commit.

## Local Repo Cross-Search

| Evidence | Finding |
| --- | --- |
| `Core/Execution/DemoRuntimeAdapter.swift` | Existing ledger was in-memory and per instance. |
| `Tests/MAformacCoreTests/DemoRuntimeAdapterTests.swift` | Existing `testNewAdapterSessionDoesNotPersistLedger` preserved by default constructor. |
| `Core/Presentation/RuntimePresentationBridge.swift` and bridge tests | Private adapter markers remain presentation deny-list material; Gate2 did not edit payload schema. |
| UIUE docs grep from Gate1 intake | D16+D17 left durable/persistent residuals open and treats private adapter fields as deny-list material. |

## Pre-Mortem

Gate2 could fake green if file-backed storage overwrote corrupt files, if unknown schema decoded leniently, if failure rows replayed as success, if success persisted before readback, if the default constructor silently became durable, or if a new public durable API became a UIUE consumer hook.

## Iceberg Teardown

| Layer | Finding |
| --- | --- |
| Visible symptom | A new adapter instance previously forgot settled command identities. |
| Underlying class | Idempotency state was tied to object lifetime rather than explicit storage authority. |
| Same-class risk map | main: hidden global store; UIUE: private store names consumed; runtime: corrupt rows replay writes; proof: local file proof becomes production durability; governance: CRITICAL GitNexus result ignored. |
| Immediate fix | Internal explicit file-backed store injection plus schema-versioned snapshot. |
| Class-level fix | Tests cover cross-adapter replay, conflicts, corrupt/unknown schema, failure-not-success, and readback drift. |
| Governance fix | Preserve default session constructor and defer C3 cross-pipeline reconstruction to Gate3. |

## Metacognitive Reflection

The first implementation would have accepted valid JSON with unknown extra fields because `JSONDecoder` is permissive. That is too weak for a durability boundary. The fix was to add an explicit schema version and fail closed on unsupported schema before treating any durable row as authority.

## Goal-Drift Check

Gate2 stayed adapter-only. It did not edit C3, UIUE, presentation payload, production runtime, voice/model/golden/endpoint, mobile, true-device, or dispatch source files.

## Claim vs Proof

| Claim | Evidence | Proof cap |
| --- | --- | --- |
| Adapter can replay local durable success across a new adapter | `testDurableLedgerReplaysAcrossNewAdapterWithoutSecondWrite` PASS | `local/unit` |
| Fingerprint mismatch fails closed across reconstruction | `testDurableLedgerFingerprintMismatchFailsClosedAcrossAdapter` PASS | `local/unit` |
| Corrupt/unknown durable ledger fails closed without mutation | corrupt and unknown schema tests PASS | `local/unit` |
| Failure records do not create fake success | `testDurableFailureRecordDoesNotCreateSuccessfulReplay` PASS | `local/unit` |
| Readback drift fails closed | `testDurableReplayReconcilesCurrentStoreReadback` PASS | `local/unit` |
| C3 cross-pipeline reconstruction works | Not claimed in Gate2; deferred to Gate3. | none yet |
| Production durable runtime works | Not claimed. | none |

## Non-Claims

- no C3 cross-pipeline durability proof in Gate2
- no production durable ledger proof
- no runtime/mobile/true-device/live proof
- no UIUE merge or UIUE runtime consumer proof
- no V-PASS, S-PASS, U-PASS, A-2, voice-ready, model-ready, golden-ready, endpoint-ready, or R5 complete claim
- no new UIUE shared fields

## Boundary Check

The durable store types are internal and injected only by local tests/future main code. Presentation payload code remains unchanged and still redacts private adapter markers. UIUE must not consume durable ledger rows, request fingerprints, parent request fingerprints, failure ledger internals, success ledger internals, settled parent-plan internals, raw private payloads, raw runtime store markers, raw model output, or training receipts.

## Self-Question

If this were wrong, `Tests/MAformacCoreTests/DemoRuntimeAdapterTests.swift` would show a second mutation on reconstructed replay, changed fingerprint would mutate state, corrupt/unknown schema would not throw `durableLedgerCorrupt`, or `RuntimePresentationBridgeTests` would expose private adapter markers in encoded payload.

## Post-Audit Correction Rule

Hermes round 1 will audit Gates 1-3 after Gate3 local validation. If it reports a Gate2 P0/P1, owned code/tests/docs must be corrected and affected validations rerun before D19 can start.

## Validation

| Command | Result | Proof class |
| --- | --- | --- |
| `git diff --check` | PASS | `local/static` |
| `swift test --filter 'DemoRuntimeAdapterTests|RuntimePresentationBridgeTests'` | PASS: 32 tests, 0 failures | `local/unit` |
| `openspec validate define-runtime-adapter-execution --strict` | PASS: change is valid | `local/OpenSpec` |
| `openspec validate --all --strict` | PASS: 18 passed, 0 failed | `local/OpenSpec` |
| `git diff --cached --check` | PASS | `local/static` |
| GitNexus `detect_changes(scope=staged)` | PASS with expected `medium` risk: 30 changed symbols, 1 affected process, 4 changed files | `local/static/graph` |

## Dirty Split

Expected preserved main dirty remains excluded:

- `AGENTS.md`
- `CLAUDE.md`
- `docs/CURRENT.md`
- `docs/README.md`
- `.xcodebuildmcp/`
- `Tools/agent-platform-plugin-refs/`

Owned Gate2 paths:

- `Core/Execution/DemoRuntimeAdapter.swift`
- `Tests/MAformacCoreTests/DemoRuntimeAdapterTests.swift`
- `openspec/changes/define-runtime-adapter-execution/tasks.md`
- `docs/project/phase0/r5-d18-gate2-durable-ledger-code-2026-06-29.md`

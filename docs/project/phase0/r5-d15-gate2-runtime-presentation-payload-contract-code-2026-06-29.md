# R5 D15 Gate 2 - Runtime Presentation Payload Contract Code

Date: 2026-06-29
Gate: 2 of 4
Label: `D15_GATE_2_PAYLOAD_CODE_TESTS`
Candidate proof class before audit closure: `local_unit` / `OpenSpec` / `GitNexus`
Audit proof may add `Codex subagent verifier` and `Hermes verifier` only after explicit PASS with empty P0/P1 and, for Hermes, anchored transcript evidence.
Scope: main Core Presentation code, focused tests, OpenSpec tasks, and this receipt

## Verdict

Final Gate 2 candidate status before final no-change audit: `DONE_CANDIDATE`.

Codex final staged-diff audit `019f1282-e27f-7e62-9fd1-8b5849b64205`: `PASS`, `findings_P0_P1: []`, `findings_P2_lower: []`.

Hermes audit transcript: `/tmp/r5-d15-gate2-hermes-audit-final.txt`.

Hermes anchor:

```text
HERMES_R5_D15_GATE_2_PAYLOAD_CODE_TESTS_VERDICT: PASS
findings_P0_P1: []
```

Hermes returned a P2 for stale GitNexus index. Controller refreshed GitNexus and reran staged detect with `LOW` risk and `0` affected processes. This final receipt version records that pitfall fix and must be audited once more before commit.

Gate 2 adds a main-owned, presentation-safe `RuntimePresentationPayload` envelope and `PresentationReconciliation` status surface. It derives from existing `PresentationSnapshot` / `TraceEnvelope` / readback surfaces and sanitizes adapter-private or raw markers before encoding. It does not implement UIUE consumer integration.

## Dirty Split Before Gate 2 Writes

Main repo before Gate 2 writes:

```text
HEAD c2128633af5c80ccafad68c4217fa892b0b15897
branch codex/rebuild-c6-doc-absorption-20260624
preserve-unowned dirty:
 M AGENTS.md
 M CLAUDE.md
 M docs/CURRENT.md
 M docs/README.md
?? .xcodebuildmcp/
?? Tools/agent-platform-plugin-refs/
cached: empty
```

UIUE repo remains read-only in Gate 2 at `3bab4c80ee8d360cb7ebdfcfcb8869d6ababb2d7`; D12/D13/D14/D15 dispatch source files and visual research directory remain untracked and unstaged.

## GitNexus Pre-Edit Impact

| symbol | result | controller interpretation |
| --- | --- | --- |
| `PresentationSnapshot` | MEDIUM, 15 impacted, 5 direct, 0 processes | Expected Presentation-module touch surface. Implementation adds adjacent payload type and does not change existing initializer semantics. |
| `TraceEnvelope` | MEDIUM, 11 impacted, 6 direct, 0 processes | Expected because payload uses trace redaction. Existing behavior preserved; redaction token list expands. |
| `RuntimePresentationTerminalSnapshotAdapter` | LOW, 0 impacted | Existing adapter behavior not structurally changed. |

No HIGH/CRITICAL GitNexus impact appeared before code edits.

## Implementation Summary

`Core/Presentation/RuntimePresentationBridge.swift`:

- Added file-private `PresentationPayloadSanitizer` shared by trace and payload surfaces.
- Added `RuntimePresentationPayloadSchema.v1`.
- Added finite `PresentationReconciliationStatus` and `PresentationReconciliationMismatchClass`.
- Added `PresentationReconciliation`, which carries presentation-safe reconciliation status/mismatch reason without adapter ledger exposure.
- Added `RuntimePresentationPayload`, with stable fields for schema version, trace identity, turn/event identity, terminal flag, outcome, proof class, cards, card semantics, readbacks, reconciliation, presentation-safe trace, and timestamp.
- Payload construction sanitizes private adapter/raw markers from outcome, card keys/values, readbacks, reconciliation, turn/event IDs, and trace messages.
- Existing `PresentationSnapshot` behavior remains unchanged.

`Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift`:

- Added payload envelope test for schema version, trace/turn/event identity, terminal flag, outcome, cards, readbacks, reconciliation, and proof class.
- Added encoded-payload forbidden-field test for `DemoRuntimeAdapter`, `RuntimeAdapterBox`, `requestFingerprint`, `parentRequestFingerprint`, `failureLedger`, `successLedger`, `settledParentPlan`, `runtimeStore`, `rawModelOutput`, and `trainingReceipt`.
- Added enum fail-closed tests for unknown reconciliation status, mismatch class, payload schema, and proof class.

## Pitfall Loop

### Swift public default argument visibility

Observed:

```text
enum 'PresentationPayloadSanitizer' is private and cannot be referenced from a default argument value
```

Immediate fix:
The public `TraceEnvelope.presentationSafe` default argument now uses a literal token list, while internal payload construction still uses the shared sanitizer.

Iceberg teardown:

| field | finding |
| --- | --- |
| visible symptom | A local helper leaked into a public default argument. |
| underlying class | Swift public API default values are part of public-facing callable surface and cannot depend on private symbols. |
| same-class risk map | Public payload API could accidentally expose private implementation names through type signatures even if encoded output is clean. |
| class-level fix | Keep helper types private but avoid referencing them from public signatures. |
| governance fix | Compile before audit and include this pitfall in receipt; future payload API additions must inspect signatures, not only encoded JSON. |

### Readback spoken text optionality mismatch

Observed:
`DemoActionReadback.spokenText` is non-optional, but the first sanitizer call treated it as optional.

Immediate fix:
Use non-optional redaction for `spokenText`.

Iceberg teardown:

| field | finding |
| --- | --- |
| visible symptom | Type mismatch on sanitizer call. |
| underlying class | Presentation payload code must respect existing readback contract instead of weakening it. |
| same-class risk map | Optionalizing stable readback fields would make UIUE consumer behavior ambiguous later. |
| class-level fix | Keep readback key/value/revision/spoken text stable and sanitized, not optionalized. |
| governance fix | Gate 2 tests assert `spokenText` survives payload round-trip. |

### Codex audit P2: pending verifier proof wording

Observed:
The first Gate 2 Codex audit returned PASS with one P2: the receipt listed Codex/Hermes verifier in the proof-class line while also saying audits were pending.

Immediate fix:
The receipt now labels the proof as candidate `local_unit` / `OpenSpec` / `GitNexus` until Codex and Hermes return explicit PASS evidence. Codex/Hermes proof is conditional, not pre-claimed.

Iceberg teardown:

| field | finding |
| --- | --- |
| visible symptom | Receipt wording could be read as claiming verifier proof before verifier completion. |
| underlying class | Proof vocabulary can promote a pending gate even when non-claims are otherwise correct. |
| same-class risk map | Gate receipt says "pending" in one paragraph but proof line implies verifier proof; final YAML could inherit the inflated class. |
| class-level fix | Keep candidate proof and completed verifier proof separated in every receipt. |
| governance fix | Rerun local validation and audits after candidate wording changes. |

### Hermes audit P2: trace identity sanitizer gap

Observed:
Hermes returned anchored PASS with P2: `TraceEnvelope.presentationSafe()` redacted messages and attributes, but not `TraceEnvelope.traceID` or `TraceEntry.traceID/runId/parentSpanId`.

Immediate fix:
`TraceEnvelope.presentationSafe()` now redacts the envelope trace identity and synchronizes each entry's `traceID`, `runId`, and `parentSpanId` with sanitized values before constructing the safe envelope. The encoded-payload negative test now injects forbidden markers into trace identity fields.

Iceberg teardown:

| field | finding |
| --- | --- |
| visible symptom | Encoded payload leak test covered message/body fields, not trace identity fields. |
| underlying class | Sanitizers often protect content while leaving identifiers as side channels. |
| same-class risk map | trace IDs, run IDs, parent span IDs, event IDs, readback keys, or card keys could encode private adapter names even if messages are clean. |
| class-level fix | Treat all payload string fields as potential side channels; sanitize identifiers as well as content. |
| governance fix | Negative tests must place forbidden tokens in identity fields, not only in free-text fields. |

### Hermes audit P2: stale GitNexus index

Observed:
Hermes returned anchored PASS with P2: the GitNexus index was stale at `5d0cd27` while current HEAD was `c212863`, even though staged detect still returned `LOW` and `0` affected processes.

Immediate fix:
Ran `node .gitnexus/run.cjs analyze`, which completed successfully and refreshed the index to `27,887 nodes`, `49,212 edges`, `993 clusters`, and `300 flows`. Reran GitNexus staged detect; result remained `LOW`, `4 changed files`, `70 changed symbols`, `0 affected processes`.

Iceberg teardown:

| field | finding |
| --- | --- |
| visible symptom | GitNexus detect was low-risk but based on a stale index. |
| underlying class | Static graph evidence can look precise while lagging behind current commits. |
| same-class risk map | stale graph misses new payload symbols; stale graph undercounts affected flows; verifier reports LOW without current symbol nodes. |
| class-level fix | Refresh graph before final staged detect when stale is reported. |
| governance fix | Treat stale graph as P2 at minimum and rerun detect after refresh before closing gate. |

## Harness

Pre-mortem:
Gate 2 can fake green by defining payload names that encode private adapter implementation, by exposing reconciliation ledger internals, by making proof class extensible/unknown-pass, or by silently changing existing snapshot semantics.

Lesson learned / metacognitive reflection:
The safest D15 code shape is additive: wrap existing presentation-safe snapshot fields in a versioned payload and sanitize boundary strings, rather than re-plumbing C3 or adapter internals.

Local cross-search:
`RuntimePresentationBridge.swift` already owned `PresentationSnapshot`, `TraceEnvelope`, finite proof classes, card semantics, and terminal snapshot adapters. `DemoRuntimeAdapter.swift` / `C3ExecutionPipeline.swift` contain private ledger/fingerprint surfaces that are intentionally not imported into payload types.

External method references:

- Google AIP-180 backward compatibility: `https://google.aip.dev/180`
- Google AIP-185 versioning: `https://google.aip.dev/185`
- OWASP Logging Cheat Sheet, data to exclude: `https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html`

These support schema-version and redaction discipline only; repo OpenSpec remains authority.

Goal-drift check:
No UIUE code, no consumer integration, no Core config/SceneMacroRegistry, no production runtime, no durable ledger.

Authority check:
Gate 1 commit `c2128633af5c80ccafad68c4217fa892b0b15897` is the OpenSpec authority for this code slice.

Claim-vs-proof:
Current proof after final no-change audit is capped at local/unit, OpenSpec, refreshed GitNexus, Codex subagent verifier, and anchored Hermes verifier.

Boundary check:
Payload code does not import or expose `DemoRuntimeAdapter`, `RuntimeAdapterBox`, request fingerprints, failure ledger, success ledger, settled parent plan, raw runtime store, raw model output, or training receipt as fields.

Self-question:
If this code is wrong, `JSONEncoder().encode(RuntimePresentationPayload)` would contain a forbidden private marker, or unknown enum decoding would succeed.

Post-audit correction rule:
Any Codex or Hermes P0/P1, missing Hermes anchor, timeout, or quota failure blocks Gate 2. Any P2/lower finding triggers a pitfall loop, candidate repair, validation rerun, and audit rerun when content changes.

## Validation Evidence

Focused validation:

```text
swift test --filter RuntimePresentationBridgeTests
PASS, 18 tests, 0 failures
```

Full Gate 2 validation before final no-change audit:

```text
git diff --check: PASS
git diff --cached --check: PASS
openspec validate define-runtime-presentation-bridge --strict: PASS
openspec validate --all --strict: PASS, 17 passed, 0 failed
swift test --filter 'RuntimePresentationBridgeTests|DemoRuntimeAdapterTests|C3ExecutionPipelineTests|VehicleStateStoreContractTests'
PASS, 51 tests, 0 failures
node .gitnexus/run.cjs analyze: PASS, 27,887 nodes / 49,212 edges / 993 clusters / 300 flows
GitNexus detect_changes(scope=staged): LOW, 4 changed files, 70 changed symbols, 0 affected processes
Codex native subagent audit: PASS, P0/P1/P2 empty
Hermes anchored audit: PASS, P0/P1 empty; stale-index P2 fixed by refresh and rerun detect
```

## Non-Claims

- no R5 complete
- no runtime-ready
- no mobile proof
- no true_device proof
- no voice-ready
- no model-ready
- no golden-ready
- no endpoint-ready
- no production runtime proof
- no durable ledger proof
- no live API proof
- no UIUE merge
- no UIUE runtime consumer integrated
- no V-PASS / S-PASS / U-PASS
- no A-2 ready / complete

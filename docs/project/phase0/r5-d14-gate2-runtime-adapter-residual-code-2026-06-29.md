---
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# R5 D14 Gate 2 - Runtime Adapter Residual Code Receipt

Date: 2026-06-29
Repos:
- main: `/Users/wanglei/workspace/MAformac`
- UIUE: `/Users/wanglei/workspace/MAformac-uiue`

## Verdict

Status: PASS pending commit.

Proof class: local/unit only.

Non-claims:
- no R5 complete
- no runtime-ready
- no mobile proof
- no true_device proof
- no voice-ready, model-ready, golden-ready, endpoint-ready
- no UIUE merge
- no V-PASS, S-PASS, U-PASS
- no A-2 ready or complete

## Scope

Goal:
- Reduce D14 Runtime Adapter V0 residuals after D13 C3 integration by implementing session-scoped ledger boundary, exact stale retry ordering, failure ledger taxonomy, readback reconciliation, and the private `RuntimeAdapterBox` concurrency boundary.

Non-goals:
- No UIUE-facing payload contract.
- No UIUE consumer changes.
- No `ToolCallFrame` schema change.
- No persistent or durable ledger.
- No production runtime, mobile, true-device, live API, or readiness claim.

Writable paths used:
- `Core/Execution/DemoRuntimeAdapter.swift`
- `Core/Execution/C3ExecutionPipeline.swift`
- `Tests/MAformacCoreTests/DemoRuntimeAdapterTests.swift`
- `Tests/MAformacCoreTests/C3ExecutionPipelineTests.swift`
- `openspec/changes/define-runtime-adapter-execution/design.md`
- `openspec/changes/define-runtime-adapter-execution/specs/runtime-adapter-execution/spec.md`
- `openspec/changes/define-runtime-adapter-execution/tasks.md`
- `docs/project/phase0/r5-d14-gate2-runtime-adapter-residual-code-2026-06-29.md`

No-touch preserved:
- `AGENTS.md`
- `CLAUDE.md`
- `docs/CURRENT.md`
- `docs/README.md`
- `.xcodebuildmcp/`
- `Tools/agent-platform-plugin-refs/`
- UIUE source dispatch docs and commander-owned route map

## Authority Check

Gate 1 Codex native subagent PASS was confirmed before Swift edits.

OpenSpec authority updated to keep D14 semantics explicit:
- ledger and C3 parent-plan replay state are session-scoped local/unit only;
- stale replay requires a matching C3 parent request fingerprint and matching settled per-transition adapter entries;
- retry replay reconciles readback against the current store and fails closed on drift;
- failure ledger records retryable, terminal, and conflict outcomes without creating success entries.

## Implementation Summary

`DemoRuntimeAdapter`:
- Added `DemoRuntimeAdapterFailureKind` and `DemoRuntimeAdapterFailureRecord`.
- Added adapter-local `failureLedger` for `retryable_failure`, `terminal_failure`, and `conflict`.
- Kept success ledger in-memory and session-scoped.
- Added readback reconciliation before success ledger write.
- Added replay readback reconciliation before returning `retry_replay`.
- Added `replayIfSettled` for C3 stale retry lookup without applying mutation.

`C3ExecutionPipeline`:
- Added pre-stale settled replay path.
- Added private `RuntimeAdapterBox` parent-plan ledger, also session-scoped.
- Added parent request fingerprinting over stable request fields so relative commands are not recomputed from changed current store state.
- Replays the settled plan only when the parent request fingerprint matches and every settled transition passes adapter replay/readback reconciliation.
- Leaves normal stale-state guard authoritative when no settled plan exists or the parent request fingerprint differs.

Tests:
- Added new adapter session boundary coverage.
- Extended failure ledger assertions for conflict, terminal failure, and retryable failure.
- Added retry replay readback drift fail-closed coverage.
- Added C3 exact stale replay coverage before stale guard.
- Added C3 changed stale request fallback coverage.
- Added C3 multi-transition stale replay coverage for `ac.power` plus `ac.temp_setpoint[主驾]` when current recomputation would omit the prerequisite transition.

## Pitfall Loop

### Pitfall 1: Swift local name shadowing

Observed:
- Initial target test run failed to compile because local variable `transition` shadowed the `transition(from:)` method, producing `cannot call value of non-function type 'DemoMockTransition'`.

Local cross-search:
- `rg` found the shadowing declaration and no other same-pattern occurrence in the touched surface.

External cross-search:
- Swift language guidance treats local declarations as scoped names; this supported the minimal repair of renaming the local variable instead of changing adapter API shape.

Iceberg teardown:
- Category: naming collision at small-scope refactor boundary.
- Countermeasure: prefer non-method-name local variables (`plannedTransition`) in adapter logic; keep compiler as the first hard signal before broad redesign.

### Pitfall 2: Current-relative stale replay fake green

Observed:
- A self-added multi-transition stale replay test initially failed with `staleState(expected: 1, actual: 0)`.
- Root cause: recomputing planned transitions from current store state is invalid for relative commands. After the first temperature command, current store state changes, so the same stale frame would derive a different desired value or omit an auto-prerequisite.

Local cross-search:
- `C3ExecutionPipeline.planTransitions` includes current-store-dependent auto-prerequisite and relative value normalization.
- Existing tests covered single-transition stale replay and fanout identity, but not current-relative multi-transition stale replay.

External cross-search:
- Idempotency references reinforce that retries need a stable request identity, not a recomputed side-effect from changed current state. Sources used as method references only; repo truth remains authoritative:
  - Stripe idempotent requests: https://docs.stripe.com/api/idempotent_requests
  - AWS Builders Library, safe retries with idempotent APIs: https://aws.amazon.com/builders-library/making-retries-safe-with-idempotent-APIs/
  - IETF Idempotency-Key draft: https://datatracker.ietf.org/doc/html/draft-ietf-httpapi-idempotency-key-header

Iceberg teardown:
- Category: derived-state replay boundary.
- Countermeasure: record a session-scoped C3 parent request fingerprint and settled parent plan after full success; replay the settled plan only when the parent request fingerprint matches and adapter readback reconciliation passes.

### Pitfall 3: First Codex subagent audit timeout

Observed:
- The first Gate 2 Codex subagent audit did not return within the 1200 second hard window.

Local cross-search:
- Controller did not treat the missing verdict as advisory PASS and arranged a fresh Codex hard audit per updated operator instruction.

Iceberg teardown:
- Category: audit-runner liveness failure.
- Countermeasure: a missing audit verdict is not evidence. Gate closure requires a replacement auditor with explicit PASS and empty P0/P1, or a recorded blocker.

## Validation

Local validation:
- `git diff --check`: PASS
- `openspec validate define-runtime-adapter-execution --strict`: PASS
- `openspec validate --all --strict`: PASS, 17 passed, 0 failed
- `swift test --filter 'DemoRuntimeAdapterTests|C3ExecutionPipelineTests|VehicleStateStoreContractTests|RuntimePresentationBridgeTests'`: PASS, 48 tests, 0 failures

Staged verification:
- `git diff --cached --name-only`: PASS; staged files limited to the 8 Gate 2 owned files.
- `git diff --cached --check`: PASS
- GitNexus `detect_changes(scope=staged)`: HIGH; changed files 8, affected processes limited to `planTransitions`-related execution flows. This matches the expected D14 C3/adapter execution touch surface.
- Codex native subagent Gate 2 audit replacement `019f123a-40f0-79e2-956b-a98410c8b29d`: PASS, `findings_P0_P1: []`, `findings_P2_lower: []`, confidence high.

## Harness

Lesson learned:
- Exact stale replay cannot rely on current-state recomputation for relative or prerequisite-producing commands.

Goal drift:
- No drift into UIUE payload contract, persistence, durable idempotency, runtime/mobile/true-device proof, or `ToolCallFrame` schema.

Authority check:
- OpenSpec now matches the implemented parent fingerprint and session parent-plan ledger behavior.

Claim-vs-proof:
- Claim is limited to local/unit code-backed proof and targeted tests. No readiness or product-level pass is claimed.

Boundary check:
- Main-only Swift and OpenSpec docs. UIUE remains untouched for Gate 2.

Self-question:
- Could stale replay return an old result for a changed request? Guarded by parent request fingerprint plus per-transition adapter fingerprint/readback reconciliation.

Post-audit correction rule:
- Any P0/P1 from Codex subagent or later Hermes/GitNexus verifier blocks progression. Any P2/lower finding triggers a pitfall loop and rerun of affected validation before Gate 2 is closed.

## Residual Risk

- The success ledger, failure ledger, and C3 parent-plan ledger are still in-memory and session-scoped.
- Replay identity is code-local and not a durable external idempotency key.
- No UIUE-facing presentation payload contract exists in D14.
- No mobile, true-device, live API, production runtime, voice, model, golden, endpoint, or merge proof exists.

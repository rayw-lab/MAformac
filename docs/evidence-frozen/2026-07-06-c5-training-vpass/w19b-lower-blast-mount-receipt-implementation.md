# W19B Lower-Blast RuntimeAdapterMountReceipt Implementation

created_at: 2026-07-06T15:26:23+0800
worker: W19B
scope: schema/builder-only implementation
proof_class: local_unit_test
verdict: PASS_TARGET_GATES__FULL_SWIFT_TEST_EXISTING_FIXTURE_FAILURE

## Status

Implemented W19B A: greenfield `RuntimeAdapterMountReceipt` schema/builder plus focused tests. The old W19 adapter-hook path remains superseded and was not used.

No `DemoRuntimeAdapter`, runner, presentation, Package, C6Hash, docs, OpenSpec, raw runs artifact, training/eval, commit, push, or staging edits were made.

## Implementation Summary

- Added `RuntimeAdapterMountReceipt` with deterministic snake_case `CodingKeys`, schema version, mount verdict, artifact digests, provenance, mounted timestamp, and hard non-claims.
- Added `RuntimeAdapterMountReceiptBuilder` for caller-provided digest strings only.
- Added decode-time and build-time validation for missing/empty required fields.
- Added restricted non-claim vocabulary:
  - `adapter_learned_qa` always encodes `false`.
  - `candidate_status` can only decode/encode `unsigned`.
  - `runtime_qa_safety` can only decode/encode `open`.
- Added focused XCTest coverage for deterministic JSON, round-trip, required-field rejection, non-claim rejection, and fixture adapter sha round-trip.

## Evidence

| Gate | Evidence |
| --- | --- |
| Replan authority | `w11-w19-lower-blast-replan.md:38` recommends greenfield schema/builder only; `w12-w19b-replan-audit.md:12-14` says W19B is implementation-ready if scoped narrowly. |
| New-symbol impact | `RuntimeAdapterMountReceipt` did not exist before creation; recorded as `new_symbol_no_prechange_impact_available`. |
| Existing-symbol impact | No existing symbol was edited; GitNexus impact stopline for existing symbols was not triggered. |
| C6Hash constraint | No `C6Hash` or `Core/Bench/C6VehicleToolBench.swift` usage/edit was made. |
| Schema file | `/Users/wanglei/workspace/MAformac/Core/Execution/RuntimeAdapterMountReceipt.swift:3` defines `RuntimeAdapterMountVerdict`; `:22` defines hard non-claims; `:60` defines `RuntimeAdapterMountReceipt`; `:132` validates required fields; `:169` defines the builder. |
| Test file | `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/RuntimeAdapterMountReceiptTests.swift:5` round-trips deterministic snake_case JSON; `:30` rejects missing/empty fields; `:61` rejects forbidden non-claims; `:83` round-trips fixture adapter sha. |
| Target validation | `swift test --filter RuntimeAdapterMountReceiptTests` passed: 5 tests, 0 failures. |
| Full validation | `swift test` ran 282 tests; 3 failures were in `RuntimePresentationPayloadPublicFixtureTests` because `Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json` is missing. W19B tests passed in the full run. |
| Non-claim scan | A focused rg scan for forbidden readiness/status claim patterns returned no matches in the W19B source/test files. |
| No-touch scoped status | `git status --short -- Core/Execution/RuntimeAdapterMountReceipt.swift Tests/MAformacCoreTests/RuntimeAdapterMountReceiptTests.swift Core/Execution/DemoRuntimeAdapter.swift Core/Execution/DemoRuntimeSessionRunner.swift Core/Presentation/RuntimePresentationBridge.swift Package.swift Core/Bench/C6VehicleToolBench.swift` showed only the two new W19B files. |
| No-touch diff check | `git diff -- Core/Execution/DemoRuntimeAdapter.swift Core/Execution/DemoRuntimeSessionRunner.swift Core/Presentation/RuntimePresentationBridge.swift Package.swift Core/Bench/C6VehicleToolBench.swift | wc -l` returned `0`. |
| GitNexus detect_changes | `mcp__gitnexus__detect_changes(scope="unstaged")` ran, but returned high/noisy whole-worktree results from pre-existing dirty files (`Core/Routing/ToolCallFrame.swift`, `Core/Training/C5LoRATraining.swift`, docs, OpenSpec, etc.). This does not isolate W19B because the worktree was already dirty before this task. |

## Validation Commands

```bash
swift test --filter RuntimeAdapterMountReceiptTests
```

Result: PASS, 5 tests, 0 failures.

```bash
swift test
```

Result: FAIL due existing fixture gap outside W19B scope:
`RuntimePresentationPayloadPublicFixtureTests` could not open `Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json`.

```bash
rg -n "<non-claim forbidden claim-patterns>" Core/Execution/RuntimeAdapterMountReceipt.swift Tests/MAformacCoreTests/RuntimeAdapterMountReceiptTests.swift
```

Result: no matches.

```bash
git status --short -- Core/Execution/RuntimeAdapterMountReceipt.swift Tests/MAformacCoreTests/RuntimeAdapterMountReceiptTests.swift Core/Execution/DemoRuntimeAdapter.swift Core/Execution/DemoRuntimeSessionRunner.swift Core/Presentation/RuntimePresentationBridge.swift Package.swift Core/Bench/C6VehicleToolBench.swift
```

Result: only:

```text
?? Core/Execution/RuntimeAdapterMountReceipt.swift
?? Tests/MAformacCoreTests/RuntimeAdapterMountReceiptTests.swift
```

## Non-Claims

- This is schema/builder-only.
- No runtime hook was implemented.
- No live mount receipt was emitted by runtime.
- No adapter-learned QA proof is claimed.
- No runtime QA pass is claimed.
- No C5 V-PASS, candidate signing, C6 acceptance, UIUE/voice readiness, mobile/true-device/live proof, docs cascade, push readiness, commit, or push is claimed.

## Touched Paths

- `/Users/wanglei/workspace/MAformac/Core/Execution/RuntimeAdapterMountReceipt.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/RuntimeAdapterMountReceiptTests.swift`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-training-vpass/w19b-lower-blast-mount-receipt-implementation.md`

## Residual Risk

The schema/builder contract is locally tested, but it is not yet wired into W21 runtime eval or any runtime mount flow. GitNexus `detect_changes` could not provide a clean W19B-only summary because the worktree already contains many unrelated dirty files from other lanes. W23 or commander should use scoped git status/diff plus the target test result when reviewing this lane.

## Recommended Commander Action

Treat W19B A as implemented for schema/builder purposes only. Continue to W21 runtime emission later under separate impact checks; do not resurrect the old `DemoRuntimeAdapter` hook without explicitly accepting the CRITICAL impact.

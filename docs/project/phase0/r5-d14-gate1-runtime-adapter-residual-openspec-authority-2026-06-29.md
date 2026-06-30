# R5 D14 Gate 1 - Runtime Adapter Residual OpenSpec Authority

Date: 2026-06-29
Gate: 1 of 4
Label: `D14_GATE_1_OPENSPEC_AUTHORITY`
Proof class: `docs/local` / `local_static` / `OpenSpec` / `GitNexus`
Scope: main OpenSpec authority and residual-risk harness only

## Verdict

Gate 1 status after local validation and Codex subagent audit: `DONE_LOCAL_OPENSPEC_SUBAGENT_PASS`.

D14 Gate 1 defines the next main-side Runtime Adapter residual slice after D13 C3 integration. The authority is deliberately session-scoped and local/unit bounded: no persistent ledger, no runtime-ready claim, no UIUE-facing payload contract, and no UIUE consumer.

## Dirty Split Before Gate 1 Writes

Main repo:

```text
HEAD 612e0dfafc4fea1b07e8f3c7001c99621a423a1c
preserve-unowned dirty:
 M AGENTS.md
 M CLAUDE.md
 M docs/CURRENT.md
 M docs/README.md
?? .xcodebuildmcp/
?? Tools/agent-platform-plugin-refs/
```

UIUE repo:

```text
HEAD 98e48da84ebf5c75332e6c62d1b181be2675ba97
commander-owned living-route dirty:
 M docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md
untracked source dispatches:
?? docs/dispatches/2026-06-29-uiue-r5-d12-runtime-adapter-v0-code-train-dispatch.md
?? docs/dispatches/2026-06-29-uiue-r5-d13-c3-runtime-adapter-integration-dispatch.md
?? docs/dispatches/2026-06-29-uiue-r5-d14-runtime-adapter-residual-train-dispatch.md
```

Gate 1 edits only main OpenSpec files and this receipt.

## Authority Inputs

- D14 dispatch: `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-29-uiue-r5-d14-runtime-adapter-residual-train-dispatch.md`.
- Main authority: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`.
- UIUE authority: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`.
- D13 Gate 1/2 main receipts and Gate 3/4 UIUE receipts.
- D1-D12 phase review Step 1/2/3.
- Active OpenSpec change: `openspec/changes/define-runtime-adapter-execution/`.
- Swift surfaces read-only in this gate: `C3ExecutionPipeline.swift`, `DemoRuntimeAdapter.swift`, `DemoVehicleStateStore.swift`, `C3ExecutionPipelineTests.swift`, `DemoRuntimeAdapterTests.swift`.

## Gate 1 Decisions

1. D14 keeps the Runtime Adapter ledger **session-scoped**. A new `DemoRuntimeAdapter` or `RuntimeAdapterBox` has an empty ledger. Durable/persistent/cross-launch idempotency remains future work.
2. C3 exact stale retry ordering is now explicit: a stale attempt may replay before stale-state failure only when every planned transition maps to a matching settled session-ledger fingerprint and readback reconciliation passes. Missing ledger, changed fingerprint, or unsafe reconstruction falls through to the existing stale-state guard before mutation.
3. Failure ledger semantics are local observability, not success replay. D14 distinguishes `retryable_failure`, `terminal_failure`, and `conflict`.
4. Retry replay must reconcile the settled readback against the current store path before returning `retry_replay`. Drift fails closed and does not rewrite store state.
5. `RuntimeAdapterBox` remains a private local/unit concurrency boundary. `@unchecked Sendable` is acceptable only because adapter access remains `@MainActor`, the box stays private, and public C3 construction must not become `@MainActor`.
6. No `ToolCallFrame` schema change, no UIUE payload contract, no UIUE Swift consumption, and no readiness/pass claim are authorized by Gate 1.

## GitNexus Evidence

Main GitNexus was stale by one commit before Gate 1 and was refreshed with `node .gitnexus/run.cjs analyze`.

Post-refresh evidence:

| probe | result |
| --- | --- |
| `context(DemoRuntimeAdapter)` | Found `Core/Execution/DemoRuntimeAdapter.swift`, called by `RuntimeAdapterBox.resolve` and `DemoRuntimeAdapterTests`. |
| `context(C3ExecutionPipeline)` | Found `Core/Execution/C3ExecutionPipeline.swift`, direct callers are test helpers. |
| `context(RuntimeAdapterBox)` | Found private class in `C3ExecutionPipeline.swift`, constructed by `C3ExecutionPipeline.init`. |
| `context(DemoVehicleStateStore.applyMockTransition)` | Found store write method; affected `runCommand` process membership remains visible. |
| `impact(DemoRuntimeAdapter)` | `CRITICAL`, 80 impacted, 57 direct, no affected processes reported. Gate 2 must use extra audit before/after touching this class. |
| `impact(C3ExecutionPipeline)` | `LOW`, 29 impacted, 4 direct, 0 affected processes. |
| `impact(RuntimeAdapterBox)` | `CRITICAL`, 51 direct. Gate 2 must treat concurrency edits as high-risk. |
| `impact(applyMockTransition)` | `MEDIUM`, 18 impacted, affects `runCommand`; D14 does not plan store semantic edits. |

GitNexus `query` returned relevant adapter/test definitions, but also unrelated tool-repo process noise. Gate 1 treats symbol context/impact plus source reads as stronger evidence than broad query ranking.

## Staging Boundary

Gate 1 uses exact pathspec staging. The presence of preserve-unowned dirty files is expected dispatch-time baseline and is not itself a blocker. The blocker condition is any preserve-unowned path appearing in the staged diff, being edited by this gate, or being required to validate the Gate 1 claim.

Current staged paths:

```text
docs/project/phase0/r5-d14-gate1-runtime-adapter-residual-openspec-authority-2026-06-29.md
openspec/changes/define-runtime-adapter-execution/design.md
openspec/changes/define-runtime-adapter-execution/proposal.md
openspec/changes/define-runtime-adapter-execution/specs/runtime-adapter-execution/spec.md
openspec/changes/define-runtime-adapter-execution/tasks.md
```

No `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `.xcodebuildmcp/`, `Tools/agent-platform-plugin-refs/`, `Reports/`, or UIUE dispatch source file is staged.

## Codex Native Subagent Audit

First subagent audit `019f1210-148c-7880-934b-2523306f55b8` returned `PARTIAL/FAIL` with a P1 that interpreted expected preserve-unowned dirty existence as a gate blocker. Controller classified this as a dirty-split false-positive because the D14 dispatch explicitly expected those paths to remain dirty and unstaged. The receipt was clarified and validation reran.

Second subagent audit `019f1213-a548-7822-94f7-4d4c9a3dfe93` returned:

```yaml
status: DONE
verdict: PASS
findings_P0_P1: []
findings_P2_or_lower: []
```

Reviewed evidence included `git diff --cached --name-only`, `git diff --cached --check`, `git diff --check`, `openspec validate define-runtime-adapter-execution --strict`, and `openspec validate --all --strict`.

## Harness

Pre-mortem: D14 can fake green by naming a session ledger "persistent", letting stale retries bypass safety for changed requests, recording failures as replayable success, returning stale ledger readback after store drift, or calling private adapter provenance a UIUE payload.

Lessons learned: D12 standalone adapter proof and D13 C3-path proof were real but local/unit only. The next residual slice must reduce semantics without promoting proof class.

Local + web cross-search: local grep found existing retry/readback/failure vocabulary across C3 tests, `TraceLogger`, C6 bench, and archived specs; only `DemoRuntimeAdapter` currently owns idempotency ledger. External method references used for pitfalls only:

- Stripe idempotent requests: `https://docs.stripe.com/api/idempotent_requests`
- Stripe low-level retry handling: `https://docs.stripe.com/error-low-level`
- AWS safe retries: `https://aws.amazon.com/builders-library/making-retries-safe-with-idempotent-APIs/`
- AWS Well-Architected idempotency: `https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/rel_prevent_interaction_failure_idempotent.html`
- IETF Idempotency-Key draft: `https://datatracker.ietf.org/doc/html/draft-ietf-httpapi-idempotency-key-header`
- Swift Sendable proposal: `https://github.com/swiftlang/swift-evolution/blob/main/proposals/0302-concurrent-value-and-concurrent-closures.md`
- Swift actor initializer proposal: `https://github.com/apple/swift-evolution/blob/main/proposals/0327-actor-initializers.md`
- Google API compatibility: `https://google.aip.dev/180`
- Git `git-add` pathspec documentation: `https://git-scm.com/docs/git-add`
- Git `git-diff --cached` documentation: `https://git-scm.com/docs/git-diff`

Iceberg teardown:

| field | finding |
| --- | --- |
| visible symptom | D13 C3 path uses adapter, but residuals remain around stale retry, failure recording, readback drift, and concurrency. |
| iceberg class | Idempotency ownership and proof-class ownership are still split between C3, adapter, store, trace, and UIUE docs. |
| same-class risk map | local retry becomes durable claim; failure record becomes success replay; stale request bypasses guard; readback ledger masks store drift; private field leaks to UIUE. |
| immediate fix | Gate 1 OpenSpec defines D14 semantics before Swift edits. |
| class-level fix | Gate 2 tests must force session reset, stale retry exactness, failure taxonomy, and reconciliation drift. |
| governance fix | HIGH/CRITICAL GitNexus surfaces require subagent audit; final docs must keep proof caps and non-claims. |

Goal-drift check: Gate 1 is authority only. It does not edit Swift, UIUE, source dispatch docs, preserve-unowned files, or reports.

Authority check: live repo/OpenSpec/tests/stdout beat D13 closeout prose, memory, or dispatcher hints. UIUE route-control dirty is commander-owned until Gate 4.

Claim-vs-proof check: Gate 1 proof is docs/local + local_static + OpenSpec + GitNexus only. It does not prove runtime/mobile/true-device/live behavior.

Boundary check: no `ToolCallFrame` edit, no UIUE field, no payload contract, no broad staging, no `Reports/` staging.

Self-question before audit: If this authority is wrong, `spec.md` would allow stale changed requests to replay, `design.md` would call session ledger persistent, or Gate 2 would be authorized to expose adapter fields to UIUE.

Post-audit correction rule: if Codex subagent returns unresolved P0/P1, times out, or points to a candidate change, Gate 1 is not done until the candidate is updated, local validation reruns, and audit reruns if content changes.

## Pitfall Loop

### GitNexus HIGH/CRITICAL Impact Pitfall

Trigger: refreshed GitNexus reports `DemoRuntimeAdapter` and `RuntimeAdapterBox` as `CRITICAL` impact surfaces.

Local search:

- `DemoRuntimeAdapter` is now called by `RuntimeAdapterBox.resolve` and adapter tests.
- `RuntimeAdapterBox` is private but affects C3 construction and adapter reuse.
- `applyMockTransition` remains the store write source and affects the `runCommand` process.

Web cross-search:

- Idempotency references emphasize request fingerprint, stored result lifecycle, and retry conflict behavior.
- Swift concurrency references make `@unchecked Sendable` a claim that must be constrained by invariants and tests.

Iceberg teardown:

- Visible symptom: a small local adapter edit appears straightforward.
- Underlying class: graph says the adapter/concurrency box is a high-fanout semantic hub even if process membership is mostly test-facing.
- Immediate fix: Gate 1 records CRITICAL surfaces and Gate 2 must run extra subagent audit plus staged GitNexus detect.
- Class fix: prefer smallest code slice; avoid store semantics and `ToolCallFrame`.
- Governance fix: unexplained HIGH/CRITICAL in Gate 2/3 blocks continuation.

Candidate change: OpenSpec explicitly records high-risk surfaces and requires Gate 2 audit.

### Codex Subagent Dirty-Split False-Positive Pitfall

Trigger: first Gate 1 Codex subagent audit returned P1 because preserve-unowned dirty paths existed in the worktree.

Controller resolution: the D14 dispatch expected main preserve-unowned dirty as the live baseline and required those paths not be mixed into staging. The exact-path staged diff contains only Gate 1 owned files, so "dirty exists" is a false-positive blocker. "Dirty staged/touched" would be a true blocker.

Local search:

- `git status --short --branch` shows preserve-unowned dirty paths.
- `git diff --cached --name-only` shows only Gate 1 owned paths.
- `git diff --cached --check` passes.

Web cross-search:

- Git `git-add` pathspec documentation supports limiting staging to explicit pathspecs.
- Git `git-diff --cached` documentation supports inspecting staged/index changes separately from unstaged working tree changes.

Iceberg teardown:

- Visible symptom: an audit interpreted any dirty file in the no-touch set as a gate failure.
- Underlying class: dirty-tree policies can conflate working-tree cleanliness with staged ownership.
- Immediate fix: this receipt distinguishes expected preserve-unowned dirty from staged/touched no-touch paths.
- Class fix: future subagent prompts should ask "is any no-touch path staged or touched by this gate?" rather than "does any no-touch path exist as dirty?"
- Governance fix: continue using exact pathspec staging, cached checks, and final status split.

Candidate change: receipt clarification only. No behavior/spec change required.

## Access Gaps And Residual Risks

- No Swift code changed in Gate 1.
- No Swift tests run in Gate 1 before local validation; Gate 2 owns implementation tests.
- Durable persistent ledger remains future.
- Current-relative exact stale retries may still stale-fail when original desired state cannot be reconstructed safely.
- Runtime/mobile/true-device/live proof remains absent.
- UIUE payload contract and consumer remain out of scope until a future main-owned D15-style contract.

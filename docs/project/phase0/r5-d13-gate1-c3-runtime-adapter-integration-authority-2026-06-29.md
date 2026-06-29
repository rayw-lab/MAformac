# R5 D13 Gate 1 - C3 Runtime Adapter Integration Authority

Date: 2026-06-29
Gate: 1 of 4
Label: `D13_GATE_1_C3_AUTHORITY`
Proof class: `local` / `OpenSpec` / `GitNexus` / `subagent-review`
Scope: authority, impact, harness, and OpenSpec only

## Verdict

Candidate status after local validation and before Hermes: `LOCAL_READY_FOR_HERMES`.

Gate 1 updates `define-runtime-adapter-execution` so Gate 2 can integrate Runtime Adapter V0 into `C3ExecutionPipeline` without guessing the C3 identity contract. This does not implement Swift, does not define a UIUE-facing payload contract, and does not upgrade D12 local/unit proof to runtime/mobile/true-device readiness.

## Dirty Split Before Gate 1 Writes

Main repo:

```text
## codex/rebuild-c6-doc-absorption-20260624...origin/codex/rebuild-c6-doc-absorption-20260624 [ahead 10]
 M AGENTS.md
 M CLAUDE.md
 M docs/CURRENT.md
 M docs/README.md
?? .xcodebuildmcp/
?? Tools/agent-platform-plugin-refs/
HEAD caaa5ee2a24991302d70e022af6a9c39ac6d6e55
```

UIUE repo:

```text
## uiue/phase4-default-scope-presentation...origin/uiue/phase4-default-scope-presentation [ahead 75]
?? docs/dispatches/2026-06-29-uiue-r5-d12-runtime-adapter-v0-code-train-dispatch.md
?? docs/dispatches/2026-06-29-uiue-r5-d13-c3-runtime-adapter-integration-dispatch.md
HEAD e47a16355bf5f1fb3dfc15cd2bfa79522cc00d7c
```

No preserve-unowned main files are edited by this gate.

## Authority Read

- Main authority: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`.
- UIUE authority: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`.
- Dispatch: `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-29-uiue-r5-d13-c3-runtime-adapter-integration-dispatch.md`.
- D1-D12 phase review: `step1-superaudit-d1-d12.md`, `step2-teardown-premortem-gitnexus-deepresearch.md`, `step3-phase-retrospective-report.md`.
- D12 receipts: `r5-d12-gate1-runtime-adapter-v0-openspec-authority-2026-06-29.md`, `r5-d12-gate2-runtime-adapter-v0-code-2026-06-29.md`.
- Main surfaces: `Core/Execution/C3ExecutionPipeline.swift`, `Core/Execution/DemoRuntimeAdapter.swift`, `Core/Routing/ToolCallFrame.swift`, `Core/State/DemoVehicleStateStore.swift`, `Tests/MAformacCoreTests/C3ExecutionPipelineTests.swift`, `Tests/MAformacCoreTests/DemoRuntimeAdapterTests.swift`.

## GitNexus Evidence

Main GitNexus was refreshed with `node .gitnexus/run.cjs analyze`.

- Repo index: `MAformac-r5-main-current`, indexed at `2026-06-29T04:07:28.244Z`, last commit `caaa5ee2a24991302d70e022af6a9c39ac6d6e55`.
- `context(DemoRuntimeAdapter)` found the class at `Core/Execution/DemoRuntimeAdapter.swift`.
- `context(C3ExecutionPipeline)` found the struct at `Core/Execution/C3ExecutionPipeline.swift`.
- `query("DemoRuntimeAdapter C3ExecutionPipeline command identity retry replay mock transition")` returned both adapter and C3 execution surfaces.

Impact probes:

| target | risk | result |
| --- | --- | --- |
| `C3ExecutionPipeline` | LOW | 25 impacted symbols, direct hits limited to tests, no affected processes. Gate 2 may touch this after validation. |
| `DemoRuntimeAdapter` | CRITICAL | 56 direct impacted symbols. Gate 2 should avoid changing this unless a separate high-risk audit is run. |
| `DemoVehicleStateStore.applyMockTransition` | MEDIUM | 34 impacted symbols, affected `runCommand` process. Gate 2 should not edit store semantics. |
| `ToolCallFrame` | HIGH | 48 impacted symbols and 3 affected processes. Gate 1 explicitly forbids ToolCallFrame schema edits for D13. |

UIUE GitNexus index is 9 commits behind HEAD, so UIUE gates must rely on live grep/status/OpenSpec validation rather than stale graph claims.

## Codex Native Subagent Audit

Subagent `019f118f-1c98-7183-99d4-820bb7850b2f` reported:

- `status: DONE`.
- P0: none.
- P1: C3 must not reuse raw `ToolCallFrame.id` directly for multiple planned transitions; Gate 1 must define deterministic per-transition adapter identities.
- P1: existing OpenSpec was D12 adapter-local authority and needed explicit C3 adapter-local frame scenarios before Gate 2.
- P2: tests must use explicit frame ids, because default `ToolCallFrame.id` is a new UUID.
- P2: UIUE grep must distinguish existing presentation vocabulary from adapter provenance.

Gate 1 OpenSpec updates absorb these findings.

## Gate 1 Contract Decisions

1. `ToolCallFrame.id` is the C3 parent command identity, not the adapter ledger identity for every transition.
2. C3 SHALL derive per-transition adapter command identities, e.g. `<ToolCallFrame.id>#<transition.key>`.
3. C3 SHALL construct adapter-local `set_vehicle_control` frames with `state_key` and `target_state` derived from each planned `DemoMockTransition`.
4. D13 SHALL NOT edit `ToolCallFrame`.
5. C3 retry replay proof is bounded by existing C3 safety gates; an exact stale retry that fails C3 stale-state guard before adapter execution remains future work.
6. Adapter provenance remains internal to main; UIUE does not receive a new payload contract in D13.

## Harness

Lesson learned: D12 local/unit adapter proof was real but still standalone. D13 must not treat a standalone adapter as C3 execution-path proof.

Goal-drift check: Gate 1 stays authority-only. It does not implement Swift, does not update UIUE docs, and does not claim runtime readiness.

Authority check: OpenSpec remains the authority for Gate 2 behavior; phase review and receipts are evidence, not replacement contracts.

Claim-vs-proof: `local/OpenSpec/GitNexus/subagent-review` only. No runtime, mobile, true-device, UIUE merge, or pass-label readiness claim.

Boundary check: Main writable paths are limited to OpenSpec change files and this receipt. UIUE remains read-only in Gate 1. Preserve-unowned main dirty paths remain untouched.

Self-question: Could Gate 2 pass tests while still not proving C3 uses adapter? The added C3 requirements require tests for per-transition identity, replay, and conflict behavior that depend on adapter ledger semantics rather than direct store mutation.

Post-Hermes correction rule: if Hermes returns any P0/P1 finding, missing anchor, timeout, or evidence gap, Gate 1 is not done. If Hermes returns P2/lower, run pitfall loop and update candidate docs before revalidating and rerunning Hermes when content changes.

## Pre-Mortem

Tiger risks:

- C3 uses raw `ToolCallFrame.id` for every transition, causing false idempotency conflicts in multi-transition plans.
- C3 edits `ToolCallFrame` despite HIGH impact.
- D13 exposes adapter provenance as UIUE payload.

Paper-tiger risks:

- Direct store writes in older code/tests look like proof of adapter execution; D13 tests must force ledger behavior.
- `already_state_noop` in UIUE presentation vocabulary could be mistaken for consuming private adapter provenance.

Elephant risks:

- Persistent ledger, exact stale retry replay, cross-launch reconciliation, and failure-ledger durability remain future work.

## Local And Web Cross-Search

Local search:

- `C3ExecutionPipeline` currently applies planned transitions directly through `store.applyMockTransition`.
- `DemoRuntimeAdapter` currently supports adapter-local `set_vehicle_control` frames with `state_key` and `target_state`.
- `ToolCallFrame(arguments:)` already supports constructing those adapter-local frames without schema edits.
- C3 can plan multiple transitions for one parent frame, so per-transition identity is required.

External source ledger:

- Stripe idempotent requests: `https://docs.stripe.com/api/idempotent_requests`.
- AWS Builders Library safe retries: `https://aws.amazon.com/builders-library/making-retries-safe-with-idempotent-APIs/`.
- IETF Idempotency-Key draft: `https://datatracker.ietf.org/doc/html/draft-ietf-httpapi-idempotency-key-header`.
- Google AIP-180 compatibility guidance: `https://google.aip.dev/180`.

These sources are method references only. Repo truth remains authoritative.

## Iceberg Teardown

Visible symptom: D12 adapter exists, but C3 still writes directly through the store.

Underlying class: execution ownership is split across planner, pipeline, adapter, and store, while idempotency identity is only meaningful at the adapter boundary.

Same-class risks:

- local/unit proof promoted to runtime-ready;
- parent command identity reused across multiple transition writes;
- private provenance fields promoted to UIUE contract;
- graph index stale enough to hide new files;
- tests proving store no-op rather than adapter replay.

Immediate fix: OpenSpec now defines the C3 adapter path and per-transition identity contract.

Class fix: Gate 2 tests must prove ledger behavior from C3, not only store mutation.

Governance fix: every gate keeps proof class and non-claims explicit, and Hermes remains a hard gate.

## Access Gaps

- No Swift code was changed in Gate 1.
- No Swift tests were run in Gate 1 because the gate is authority-only.
- UIUE GitNexus graph is stale; UIUE gates must use live grep and OpenSpec validation.
- Runtime/mobile/true-device/live proof remains absent.

## Local Validation

```text
git diff --check
PASS

openspec validate define-runtime-adapter-execution --strict
Change 'define-runtime-adapter-execution' is valid

openspec validate --all --strict
Totals: 17 passed, 0 failed (17 items)
```

## Hermes First Pass And P2 Pitfall Loop

First Hermes run output:

```yaml
HERMES_R5_D13_GATE_1_C3_AUTHORITY_VERDICT: PASS
findings_P0_P1: []
```

Hermes returned two P2 findings, so Gate 1 performed the required pitfall loop before proceeding:

### P2-1: GitNexus Symbol Disambiguation Pitfall

Finding: ambiguous `ToolCallFrame` impact probes can resolve to the wrong local fixture or symbol, while the Gate 1 receipt relies on the disambiguated production `Core/Routing/ToolCallFrame.swift` result.

Local search:

- `Core/Routing/ToolCallFrame.swift:163` defines the production `ToolCallFrame`.
- `Core/Routing/ToolCallFrame.swift:226-250` already provides the `ToolCallFrame(arguments:)` initializer.
- Several tests define fixture helpers named around `ToolCallFrame`; those must not be used as impact anchors.

Web cross-search:

- Stripe idempotency guidance reinforces that request identity must be checked with request parameters, not by a bare ambiguous key: `https://docs.stripe.com/api/idempotent_requests`.
- Stripe low-level error handling also treats same idempotency key with different parameters as an error: `https://docs.stripe.com/error-low-level`.

Iceberg teardown:

- Visible symptom: one symbol name can map to multiple graph nodes.
- Underlying class: graph evidence can look precise while the anchor is under-disambiguated.
- Immediate fix: Gate 1 records file-qualified impact anchors.
- Class fix: Gate 2 impact probes must include file paths and touched-symbol names.
- Governance fix: high/critical graph results require no-touch or separate audit before edits.

Candidate change required: no behavior/spec change. Existing receipt already records file-qualified production impact and forbids `ToolCallFrame` schema edits.

### P2-2: UIUE Existing Vocabulary Versus Adapter Private Fields

Finding: UIUE live grep contains `already_state_noop`, `state_key`, and `target_state`; these are not automatically D13 adapter-private field consumption.

Local search:

- UIUE `Core/Presentation/RuntimePresentationConsumerMapping.swift` maps existing `already_state_noop` presentation vocabulary.
- UIUE `Core/Presentation/PresentationSnapshot.swift` contains existing `.alreadyStateNoop`.
- UIUE `Core/Routing/ToolCallFrame.swift` and `Core/Execution/DemoActionExecutor.swift` contain existing `state_key` and `target_state` fast-path/tool vocabulary.
- UIUE D12 guard already distinguished adapter private surfaces from existing presentation mapping.

Web cross-search:

- Google AIP-180 treats compatibility as a deliberate API contract concern: `https://google.aip.dev/180`.
- Google field naming guidance reinforces that field names need explicit conceptual ownership, not accidental reuse by string match: `https://google.aip.dev/140`.

Iceberg teardown:

- Visible symptom: string grep can produce false positives.
- Underlying class: shared vocabulary can cross presentation, routing, and adapter layers while ownership differs.
- Immediate fix: Gate 1 records that Gate 3 must classify hits by owner and context, not by raw string match.
- Class fix: UIUE guard must distinguish existing bridge vocabulary from new adapter provenance fields.
- Governance fix: no UIUE payload contract can be inferred from main private fields or common string names.

Candidate change required: no OpenSpec behavior change. Gate 1 already keeps adapter provenance internal and defers UIUE boundary guard to Gate 3.

### P2-3: Historical D12 Task Checkbox Drift

Finding: Hermes rerun observed that `tasks.md` still showed D12 Gate 2 rows unchecked even though D12 Runtime Adapter V0 code and receipts exist.

Local search:

- Main D12 Gate 2 receipt records `HERMES_R5_D12_GATE_2_RUNTIME_ADAPTER_V0_VERDICT: PASS`, target Swift tests PASS, and residuals including no C3 wiring.
- UIUE D12 Gate 3 receipt records `HERMES_R5_D12_GATE_3_UIUE_CONSUMER_GUARD_VERDICT: PASS` and no UIUE Swift change.
- UIUE D12 commander reconcile records Gate 2 and Gate 3 DONE, Gate 4 Hermes PASS, and residuals including no C3 wiring and no UIUE consumption of Runtime Adapter V0 fields.
- D1-D12 phase review independently classifies D12 Gate 2 as local/unit adapter code proof, D12 Gate 3 as docs/local UIUE guard proof, and D12 Gate 4 as docs/local reconcile proof.

Web cross-search:

- OpenSpec workflow guidance says tasks track progress via `tasks.md` checkboxes and status can be checked with `openspec status --change`: `https://github.com/Fission-AI/OpenSpec/blob/main/docs/opsx.md`.
- OpenSpec public guidance frames tasks as part of the repo-local SDD loop, so stale checkboxes can mislead later apply/continue passes: `https://openspec.pro/`.

Iceberg teardown:

- Visible symptom: stale unchecked historical rows survive after implementation receipts.
- Underlying class: active task files can become a second, stale status ledger if receipts and checkboxes diverge.
- Immediate fix: Gate 1 closes historical D12 rows in `tasks.md` and labels their proof caps.
- Class fix: Gate 4 reconcile should verify active tasks against receipts before final handoff.
- Governance fix: future OpenSpec archive should not rely on prose receipts alone; task checkboxes must be aligned or explicitly annotated.

Candidate change required: yes. `tasks.md` now marks historical D12 Gate 2/3/4 rows complete with proof-cap notes and keeps active D13 work in sections 5-8.

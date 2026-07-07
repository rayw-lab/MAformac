---
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# Step 2 - Teardown, Pre-Mortem, GitNexus, Deepresearch

label: UIUE_R5_D1_D12_TEARDOWN_PREMORTEM_GITNEXUS_DEEPRESEARCH

date: 2026-06-29

proof_class: docs/local + repo_static + GitNexus_partial_graph + bounded_web_research

access_gaps: no runtime execution, no mobile, no true_device, no live_api, no UIUE writes

## Method And Downgrade Note

The full deepresearch pipeline was intentionally bounded because this task is a phase-review/audit artifact, not a standalone external research deliverable with an approved outline and long-run source plan. The bounded mode used:

- live repo truth first;
- official/primary external sources where possible;
- source ledger;
- uncertainty labels;
- external sources as method/pitfall references only, never as repo truth.

## Bug-Iceberg Teardown

### Tiger Risks

| Risk | Why it is real | Current containment |
|---|---|---|
| Runtime Adapter not wired into C3 | C3 still calls `store.applyMockTransition` directly and has no adapter parameter. | Keep C005/C061 as local/unit only. |
| In-memory ledger only | Retry behavior disappears across process restart. | Do not claim durable retry safety. |
| UIUE private-field consumption | Main adapter field names are tempting but not stable presentation payload. | UIUE Gate 3 explicitly forbids consumption. |
| Proof promotion | Project has many proof classes and many closeout docs; prose drift is easy. | Non-claim blocks, `displayCaps` empty, proof-governance rows. |
| GitNexus stale graph | The new adapter symbol is absent from graph, while graph reports old C3/store surfaces. | Treat graph as partial evidence until reindex. |

### Paper-Tiger Risks

| Risk | Why it is less severe now |
|---|---|
| "D12 did nothing" | False. D12 added main adapter code and unit tests for command identity/fingerprint/retry/no-op/fail-closed behavior. |
| "UIUE already broke the contract" | Current UIUE grep found no Swift consumer of main adapter private fields. |
| "Forbidden-claim grep hits prove violations" | Most hits are non-claims, proof caps, or stop conditions. The audit must judge semantics, not raw string presence. |

### Elephant Risks

| Risk | Why it sits outside D12 but matters |
|---|---|
| Model/LoRA readiness | D1-D12 did not run train/model quality gates. |
| Voice readiness | No ASR/TTS true-device proof. |
| Endpoint/golden | No endpoint candidate or demo-golden readiness. |
| Human visual threshold | Final-art/white-edge still need human/threshold authority. |

## Pre-Mortem

Assume the next phase fails. The most plausible causes:

1. The team says "C005/C061 covered" and forgets the suffix "by D12 Runtime Adapter V0 local/unit only".
2. C3 integration is implemented by bypassing the adapter ledger for some paths.
3. Retry identity is conflated with trace/correlation ID instead of a stable operation identity.
4. Persistent ledger is added after UIUE payload shape is already frozen, forcing a breaking contract.
5. UIUE consumes `commandID`, `requestFingerprint`, or provenance strings before main owns a presentation payload.
6. GitNexus is used as if current even though it is behind HEAD and blind to new files.
7. Final-art screenshot evidence is narrated as human/final acceptance.
8. A broad stage accidentally commits preserve-unowned authority files.

Early warning signals:

- New docs omit proof class next to "covered".
- `DemoRuntimeAdapter` appears in UIUE Swift.
- `C3ExecutionPipeline` still calls store directly after a claimed adapter integration.
- GitNexus `context DemoRuntimeAdapter` still returns not found after a graph-dependent decision.
- `V-PASS`, `mobile`, `true_device`, or `runtime-ready` appears outside non-claim/stop-gate context.

## GitNexus Findings

GitNexus was available, but stale:

- Repo: `MAformac-r5-main-current`
- Indexed commit: `d332db736a0c47eb3b8dc09c80fb907a0f43e29e`
- Current main HEAD: `451c699df89f1bde78115159e723329d28b84cc5`
- Staleness: 5 commits behind HEAD

| Probe | Result | Interpretation |
|---|---|---|
| `query("runtime adapter C3 execution pipeline mock transition readback ledger")` | Found C3 `planTransitions` and old C3/readback symbols, not new adapter flows. | Graph can explain old C3, not D12 new-file adapter. |
| `context(C3ExecutionPipeline)` | Found C3 struct and test callers. | C3 blast radius is visible for old graph. |
| `context(DemoRuntimeAdapter)` | Symbol not found. | New D12 adapter is a graph blind spot until reindex. |
| dry-run rename `DemoRuntimeAdapter` | Symbol not found. | Confirms graph cannot track the new adapter. |
| `impact(C3ExecutionPipeline)` | LOW, 24 impacted symbols, 4 direct, tests included. | C3 appears mostly test-facing in stale graph, but this cannot prove runtime safety. |
| `impact(DemoVehicleStateStore.applyMockTransition)` | MEDIUM, 24 impacted symbols, affects `runCommand`. | Store write surface has broader old-runtime relevance. |
| `impact(DemoActionExecutor.applyMockTransition)` | LOW, 4 impacted symbols, affects `runCommand`. | Legacy executor path is narrower but still runtime-adjacent. |
| `impact(DemoRuntimeAdapter)` | UNKNOWN/not found. | Do not use GitNexus as proof of adapter blast radius until reindexed. |
| `detect_changes(unstaged)` | Reports preserve-unowned dirty authority/reference files, low graph risk. | Useful dirty-scope warning, not phase-review code impact proof. |

Conclusion: GitNexus supports the risk that C3/store integration is a real surface, and it also supports the graph-staleness risk. It does not support any claim about new adapter symbol impact.

## Bounded Deepresearch Source Ledger

| Source | Type | Use in this review | Link |
|---|---|---|---|
| IETF HTTP Idempotency-Key draft | Standards-track draft / primary protocol reference | Method reference for idempotency key, fingerprint, server lifecycle policy, duplicate/conflict scenarios. | https://datatracker.ietf.org/doc/html/draft-ietf-httpapi-idempotency-key-header-04 |
| Stripe Idempotent Requests | Vendor API docs / primary operational reference | Method reference for saving first result, comparing parameters, key expiry, and not saving failed pre-execution validation. | https://docs.stripe.com/api/idempotent_requests |
| Stripe Advanced Error Handling | Vendor API docs | Method reference for retrying POST with idempotency key and safe retry window. | https://docs.stripe.com/error-low-level |
| AWS Builders Library - Making retries safe with idempotent APIs | Vendor engineering article / primary architecture reference | Method reference for retry side effects, client request identity, and reconciliation complexity. | https://aws.amazon.com/builders-library/making-retries-safe-with-idempotent-APIs/ |
| AWS Well-Architected REL04-BP04 | Vendor best-practice docs | Method reference for idempotency tokens, stored responses, duplicate handling, and anti-patterns like timestamp keys. | https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/rel_prevent_interaction_failure_idempotent.html |
| Google AIP-180 | API compatibility guideline | Method reference for API as contract and backward-compatibility discipline. | https://google.aip.dev/180 |
| Confluent Schema Evolution & Compatibility | Vendor docs | Method reference for producer-consumer contract, compatibility modes, and schema evolution checks. | https://docs.confluent.io/platform/current/schema-registry/fundamentals/schema-evolution.html |

External evidence does not override repo truth. It only reinforces that idempotency, retry, and consumer payload contracts need explicit lifecycle, compatibility, and failure semantics before being promoted.

## Cross-Source Implications For D12

1. Idempotency keys are not enough; the server side needs lifecycle, fingerprint comparison, and duplicate/conflict semantics. D12 has fingerprint/conflict for local unit scope, but not durable lifecycle.
2. Safe retries depend on the settled-result boundary. D12 records successful ledger entries, but does not yet have failure ledger or persistence.
3. Consumer contracts should be stable and compatibility-checked. UIUE is correct to reject private adapter fields until main owns a presentation payload contract.
4. Retrying side-effectful operations without idempotency can duplicate effects. Current C3 path bypasses the adapter, so C3 remains the main risk surface.
5. External API/schema guidance maps to process discipline here: add compatibility gates before UIUE consumption and proof-promotion checks before closeout.

## Required Theme Coverage

### 1. D1-D12 Failure Modes And Fake-Green Risks

- "Decision accepted" becomes "implementation complete".
- "Local/unit coverage" becomes "runtime-ready".
- "Simulator/mock screenshot" becomes "mobile/true_device".
- "covered" row status loses its proof-class suffix.
- "GitNexus queried" becomes "graph current".
- "UIUE guard doc exists" becomes "UIUE contract exists".

### 2. Runtime Adapter V0 Follow-Up Risks

- C3 integration: adapter currently absent from execution path.
- Persistent ledger: current ledger is private in-memory state.
- Readback reconciliation: current readback is store snapshot, not cross-attempt reconciliation.
- Retry identity: `commandID` exists, but caller identity/lifecycle and collision policy are not complete.
- Failure ledger: failed commands do not fake success, but durable failed-attempt semantics are absent.

### 3. UIUE Consumer Contract Risk

The private main types `DemoRuntimeAdapterResult`, `DemoRuntimeAdapterProvenance`, `commandID`, `requestFingerprint`, `first_execution`, `retry_replay`, and `already_state_noop` are not UIUE-facing payload contract fields. UIUE Gate 3 is the correct guard. Future UIUE work must wait for a main-owned presentation payload contract.

### 4. Proof Promotion Risk

Current proof ceiling:

- D1-D10: docs/local, structural validation.
- D11 bridge/presentation: OpenSpec + local/unit.
- D12 Runtime Adapter V0: OpenSpec + local/unit.
- UIUE visual/final-art: simulator/mock/human-threshold prep only.

None of these imply runtime/mobile/true_device/live/V-PASS.

### 5. GitNexus Stale Graph / New-File Blind Spot

The graph is useful for old C3/store surfaces but cannot find `DemoRuntimeAdapter`. Treat all adapter-specific graph claims as invalid until reindex.

### 6. Preserve-Unowned Dirty And Dual-Repo Commander Risk

Main has preserve-unowned authority/tooling changes. UIUE has an untracked D12 dispatch doc. This requires exact pathspec staging and no cross-repo write. A broad `git add .` would be unsafe.

### 7. Final-Art / White-Edge / Human Threshold Risk

UIUE final-art is simulator review prep only. White-edge remains blocked for threshold. This is not a visual acceptance pass and not a product readiness gate.

## Recommendation

Next engineering wave should start with main C3 integration of Runtime Adapter V0, not UIUE payload consumption. The reason is simple: a UIUE-facing contract over an adapter that is not yet in the execution path would stabilize the wrong abstraction. First put the adapter in the real main execution path under local/integration proof, then define the stable presentation payload that UIUE can consume.

The narrow exception: the C3 integration change should also reserve the payload boundary explicitly, so private adapter fields cannot leak into UIUE while integration work is underway.

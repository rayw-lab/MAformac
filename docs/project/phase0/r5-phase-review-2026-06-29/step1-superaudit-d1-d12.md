---
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# Step 1 - Superaudit D1-D12

label: UIUE_R5_D1_D12_PHASE_REVIEW_SUPERAUDIT

date: 2026-06-29

proof_class: docs/local + local_static + repo_line_evidence + GitNexus_partial_graph

access_gaps: no runtime execution, no mobile, no true_device, no live_api, no UIUE write, no Swift code changes

## Executive Verdict

D1-D12 produced real progress, but only inside bounded proof classes. The strongest current achievement is that D12 moved `C005` and `C061` from pure future/definition risk into main-local Runtime Adapter V0 code plus unit coverage. That is a meaningful code-backed step.

The strongest current non-achievement is just as important: Runtime Adapter V0 is not wired into `C3ExecutionPipeline`, its ledger is in-memory only, and UIUE deliberately does not consume the adapter's private execution fields. Therefore the phase remains a bounded local/unit/docs phase. It must not be written as runtime-ready, mobile-ready, true-device proof, UIUE merge, or any V/S/U pass.

No confirmed P0 defect was found in the reviewed D1-D12 evidence. P0-class risks were explicitly searched: forbidden readiness claim wording, UIUE accidental consumer of main private adapter fields, C3 adapter integration, and final-art/white-edge false closure. The confirmed risks are P1/P2 and are mostly about integration boundaries, proof promotion, and stale graph/dirty-tree control.

## Evidence Inventory

| Evidence | Live finding | Audit use |
|---|---|---|
| Main HEAD | `451c699df89f1bde78115159e723329d28b84cc5` | Confirms D12 final expected commit is current. |
| UIUE HEAD | `e47a16355bf5f1fb3dfc15cd2bfa79522cc00d7c` | Confirms UIUE D12 reconcile expected commit is current. |
| Main dirty split | `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `.xcodebuildmcp/`, `Tools/agent-platform-plugin-refs/` | Preserve-unowned, not touched by this review. |
| UIUE dirty split | untracked D12 dispatch doc only | UIUE remains read-only. |
| Main authority | `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md` | Confirms CLAUDE.md authority, OpenSpec SDD, proof discipline, UIUE isolation. |
| UIUE authority | `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md` | Confirms simulator/mock/local caps, no V-PASS/mobile/true_device/runtime claims. |
| Runtime Adapter code | `/Users/wanglei/workspace/MAformac/Core/Execution/DemoRuntimeAdapter.swift:35` | New adapter exists and owns command identity/fingerprint/in-memory successful ledger. |
| Runtime Adapter tests | `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/DemoRuntimeAdapterTests.swift:4` | D12 behavior has focused unit proof. |
| C3 current path | `/Users/wanglei/workspace/MAformac/Core/Execution/C3ExecutionPipeline.swift:57` and `:120` | C3 still directly applies mock transitions through store, no adapter injection. |
| D12 OpenSpec | `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-adapter-execution/specs/runtime-adapter-execution/spec.md:1` | Contract says adapter V0 is local/unit capped and forbids readiness promotion. |
| Main D12 Gate 2 receipt | `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d12-gate2-runtime-adapter-v0-code-2026-06-29.md:31` | Records code-backed coverage and residuals. |
| UIUE D12 Gate 3 receipt | `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d12-gate3-uiue-consumer-guard-2026-06-29.md:34` | Records UIUE non-consumption of main private adapter fields. |
| R5 burndown map | `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md:40` | 215-row route and risk counts. |
| Final-art receipt | `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-final-art-white-edge-visual-review-2026-06-29.md:46` | Simulator review prep only; white-edge threshold not closed. |
| GitNexus | repo index `MAformac-r5-main-current` is 5 commits behind HEAD | Useful for old C3/store blast radius; blind to new D12 adapter symbol. |

## Baseline Matrix

| Slice | Current state | Proof class | What it does not prove |
|---|---|---|---|
| D1-D10 decision closeout | User decisions accepted; pending user decision empty; some follow-up gates remain. | docs/local + structural validation | No training, model quality, endpoint, golden, voice, UIUE merge, R5 complete. |
| D1-D10 LoRA decision pack | LoRA zero-failure options were framed and selected for future direction. | docs/local | No dataset/train/eval/model readiness. |
| D1-D10 cascade audit | No authorization of training/endpoint/golden/voice/UIUE merge found; R-L17 and physical gates remain. | docs/local | No physical proof and no runtime proof. |
| D11 bridge and C061 boundary | Runtime presentation bridge and C061 boundary were clarified; C061 still lacked production adapter code at that point. | docs/local + local/unit for bridge surfaces | No runtime adapter, no retry ledger, no C3 integration. |
| D11 terminal snapshot adapter | Terminal presentation adapter/factory local tests and OpenSpec coverage exist. | local/unit + OpenSpec | Not C3 runtime wiring, not model/voice/golden/mobile/UIUE merge. |
| D12 Gate 1 | OpenSpec authority for Runtime Adapter V0 exists. | OpenSpec strict + docs/local | No code until Gate 2; no persistent ledger. |
| D12 Gate 2 | `DemoRuntimeAdapter` code and unit tests exist. | local/unit + local_static | Not wired to C3; no durable ledger; no UIUE payload contract. |
| D12 Gate 3 | UIUE guard prevents consuming private main adapter fields. | docs/local + local_static | No UIUE consumer implementation, no new shared runtime fields. |
| D12 Gate 4 | Main/UIUE receipts reconciled. | docs/local | No runtime-ready, no mobile/true_device/live, no UIUE merge. |

## P0/P1/P2 Register

### P0

No confirmed P0 issue in current evidence.

P0-class risks explicitly searched and not confirmed:

- Forbidden readiness claims: current hits in UIUE roadmap/grill docs are overwhelmingly non-claims, proof caps, or stop conditions, not positive readiness declarations.
- UIUE accidental consumption of D12 private main adapter fields: current `rg` over UIUE `Core`, `Tests`, `docs/project/phase0`, `docs/roadmaps`, and `docs/loop-competition` found guard docs and existing presentation result mappings, not Swift consumption of `DemoRuntimeAdapter` or `DemoRuntimeAdapterResult`.
- C3 accidental adapter use: current `rg` over main `Core` and `Tests` found `DemoRuntimeAdapter` only in its own file/tests; `C3ExecutionPipeline` is still separate.
- Final-art/white-edge false closure: UIUE receipt keeps final-art at simulator review prep and white-edge blocked for threshold.

### P1

| ID | Finding | Evidence | Risk |
|---|---|---|---|
| P1-01 | Runtime Adapter V0 is not in the live C3 execution path. | `C3ExecutionPipeline.execute` accepts frame/store/logger only at `/Users/wanglei/workspace/MAformac/Core/Execution/C3ExecutionPipeline.swift:57`; it calls `store.applyMockTransition` at `:120`. `rg DemoRuntimeAdapter Core Tests` shows no C3 reference. | C005/C061 can be overread as runtime execution coverage. |
| P1-02 | Adapter ledger is in-memory only. | `private var ledger` in `/Users/wanglei/workspace/MAformac/Core/Execution/DemoRuntimeAdapter.swift:42`; D12 receipt residuals at `r5-d12-gate2...md:138`. | Restart/replay/reconciliation proof is absent. |
| P1-03 | UIUE-facing payload contract is not defined. | UIUE Gate 3 says main adapter types are not stable UIUE-facing DTO fields at `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d12-gate3-uiue-consumer-guard-2026-06-29.md:40`. | UIUE could freeze private execution names if future handoffs are careless. |
| P1-04 | Proof promotion remains the central fake-green hazard. | `PresentationProofClass.displayCaps` is empty at `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift:120`; R5 burndown row `C025` flags simulator screenshot no-promotion at `final-grill-matrix.md:85`. | Local/unit/simulator/docs evidence could be narrated as runtime/mobile/V-PASS. |
| P1-05 | GitNexus graph is stale and blind to new D12 symbols. | GitNexus `list_repos` reports `MAformac-r5-main-current` 5 commits behind HEAD; `context/impact DemoRuntimeAdapter` returns symbol not found. | Graph-derived impact can miss new-file dependencies until reindex. |
| P1-06 | Dual-repo dirty split creates staging/closeout risk. | Main preserve-unowned dirty and UIUE untracked dispatch doc are live. | A broad stage or careless commit could mix unrelated authority changes into phase review. |

### P2

| ID | Finding | Evidence | Risk |
|---|---|---|---|
| P2-01 | C018 remains future main owner work. | R5 map marks C018 still deferred; UIUE mapping keeps it `.deferredMainlineOwner`. | Runtime configuration/registry risks remain unimplemented. |
| P2-02 | C052 is debug-only, not production force-state behavior. | UIUE roadmap D9 records C052 debug-only bounded spike. | A useful debug lane could be mistaken for product behavior. |
| P2-03 | Final-art/white-edge is not human-threshold closed. | UIUE final-art receipt keeps simulator review prep and white-edge threshold blocker. | Visual acceptance can be prematurely closed from screenshots. |
| P2-04 | D1-D10 decisions contain accepted direction but not physical/model readiness. | `phase0-d1-d10-closeout.md` records partial closeout and remaining blockers. | Roadmap language can drift into completion language. |
| P2-05 | Existing static proof hygiene is strong but distributed across docs. | Non-claims appear in multiple receipts and roadmaps. | Future agents need a single mechanical guard, not only prose discipline. |

## Runtime Truth

Runtime code development has started, but only at a narrow adapter layer.

Confirmed:

- `DemoRuntimeAdapter` exists and accepts `commandID`, `ToolCallFrame`, and `DemoVehicleStateStore`.
- It derives a deterministic fingerprint from `tool`, `state_key`, `target_state`, and `source`.
- Same `commandID` plus same fingerprint returns a retry replay without another store write.
- Same `commandID` plus different fingerprint fails closed.
- Unsupported/missing/failed commands do not create successful ledger entries.
- Already-state transitions can return `alreadyStateNoop`.

Not confirmed:

- C3 uses the adapter.
- The adapter ledger survives process restart.
- There is readback reconciliation beyond current store readback.
- Retry identity exists beyond caller-supplied `commandID`.
- Failure ledger exists for failed attempts.
- UIUE consumes any adapter-owned result fields.

## Testing Reality

Current D12 test evidence is good for local/unit behavior:

- `DemoRuntimeAdapterTests` covers first execution, retry replay, already-state no-op, conflict fail-closed, failed unsupported command retry, and missing state cell.
- D12 receipt records `swift test --filter DemoRuntimeAdapterTests` PASS and `openspec validate --all --strict` PASS at that time.

Testing gaps:

- No C3 adapter integration test exists because adapter is not wired into C3.
- No persistence/restart test exists because ledger is in-memory.
- No UIUE consumer test for adapter fields should exist yet; that is intentional.
- No runtime/mobile/true-device/live proof exists.

## Doc Cascade Drift

The docs are mostly disciplined, but the cascade is fragile:

- D1-D10 are accepted as decision/roadmap progress, not implementation completion.
- D11 split bridge/presentation proof from runtime execution proof.
- D12 improved C005/C061 from future-only to main local/unit adapter proof.
- UIUE correctly guards itself from consuming private main adapter names.
- The biggest drift vector is "covered" wording: D12 `covered_by_D12_runtime_adapter_v0_local_unit` is true only within local/unit, not runtime.

## Entropy Map

| Entropy source | Current control | Remaining exposure |
|---|---|---|
| Two repos, one phase narrative | Main writes only, UIUE read-only | Closeouts can still mix heads or dirty states. |
| Many proof classes | Non-claim blocks and `displayCaps` empty | Human prose can still promote evidence. |
| New adapter file | Unit tests and OpenSpec | GitNexus index does not see it yet. |
| Burndown matrix size | 215-row route map and D12 reconcile | Row state needs periodic recomputation, not memory. |
| Final-art review | Simulator evidence is labeled | Human threshold undefined, white-edge blocked. |
| Runtime execution | C3 existing tests | Adapter not in path, so runtime truth remains split. |

## Remediation Waves

| Wave | Slice | Why this order | Stop gate |
|---|---|---|---|
| W1 | Main C3 integrates Runtime Adapter V0 behind OpenSpec | Turns local adapter proof into actual execution-path proof. | Must still claim only local/unit/integration unless runtime harness runs. |
| W2 | Persistent ledger and failure ledger | Makes retry identity survive restart and separates settled success from retryable failure. | No durable-readiness claim until persistence test exists. |
| W3 | Main-owned UIUE-facing presentation payload contract | Prevents UIUE from consuming private adapter fields. | No UIUE Swift consumption before contract is stable. |
| W4 | Proof no-promotion checker | Converts non-claim discipline from prose to machine gate. | Positive claim grep must distinguish non-claims from claims. |
| W5 | Final-art/white-edge human threshold | Removes visual acceptance ambiguity. | Requires explicit human threshold and artifact criteria. |
| W6 | GitNexus reindex after D12 | Restores graph trust for new adapter symbols. | Do not rely on graph for new files until index catches HEAD. |

## Scorecard

| Dimension | Score | Reason |
|---|---:|---|
| Repo truth discipline | 4/5 | Live heads and dirty split are clear; preserve-unowned remains. |
| Proof-class hygiene | 4/5 | Non-claims are explicit; risk is future prose drift. |
| Runtime architecture progress | 3/5 | Adapter exists, but C3 integration/persistence are missing. |
| UIUE contract hygiene | 4/5 | UIUE guard is correct; stable payload contract still absent. |
| Testing adequacy for current scope | 4/5 | Focused adapter unit tests exist; no integration tests by design yet. |
| Release readiness | 1/5 | Not a release/readiness phase; hard gates remain. |

## Final Release Gate

Release/readiness gate remains closed.

Denied claims:

- R5 complete
- runtime-ready
- mobile proof
- true_device proof
- live_api proof
- UIUE merge
- voice-ready
- model-ready
- golden-ready
- endpoint-ready
- V-PASS/S-PASS/U-PASS
- A-2 ready or complete

Minimum evidence before any readiness language:

1. C3 execution path uses adapter.
2. Retry identity and ledger semantics are defined beyond in-memory happy path.
3. Readback reconciliation and failure ledger exist.
4. UIUE-facing presentation payload contract is main-owned and stable.
5. Proof checker blocks promotion from local/unit/simulator/docs to runtime/mobile/true_device/V-PASS.
6. Target runtime/mobile/true_device evidence is actually collected.

## Red-Team 15 Questions

1. Did D12 make C005/C061 real? Yes, but only as local/unit adapter code-backed proof.
2. Is the adapter in production runtime? No. C3 still applies store transitions directly.
3. Is the retry ledger durable? No. It is a private in-memory dictionary.
4. Can a process restart safely replay a command? Not proven.
5. Does UIUE parse adapter fields? No current code evidence; it is explicitly guarded not to.
6. Can local/unit tests be called runtime proof? No.
7. Can simulator screenshots be called mobile/true_device proof? No.
8. Can final-art be accepted from current evidence? No. It is simulator review prep and human threshold remains open.
9. Did D1-D10 close training/model/golden/endpoint? No.
10. Does GitNexus prove new adapter impact? No. The index is stale and cannot find `DemoRuntimeAdapter`.
11. Is the main dirty tree safe to stage broadly? No. Exact pathspec only.
12. Did UIUE merge happen? No.
13. Is there a hidden P0 positive readiness claim? Not confirmed by current grep/context review.
14. What is the most likely fake-green route? Writing "covered" without proof class, especially for C005/C061.
15. What should be done next? Main C3 adapter integration first, then durable ledger and main-owned UIUE-facing payload contract.

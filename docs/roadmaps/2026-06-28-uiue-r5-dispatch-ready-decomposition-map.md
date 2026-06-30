---
status: LIVING_ROUTE_CONTROL_AFTER_D22_GATE4_LOCAL_AND_HERMES_PASS
artifact_kind: commander_dispatch_decomposition_map_and_living_route_control
created_at: 2026-06-28
last_updated_at: 2026-06-30
owner: commander
proof_class: docs/local + calibration_receipts + local_unit_receipts + hermes_gates + codex_substitute_verifier + cc_substitute_verifier + d16_d17_local_unit + d18_local_durable_adapter_ledger + d19_local_unit_guard + d20_d21_local_unit_integration + d20_d21_public_fixture + gate3_hermes_fail_fixed_post_audit + gptpro_request_changes_fixed_post_audit + d22_local_unit_fixture_corpus + d22_gate3_hermes_pass + d22_gate4_hermes_pass
authority: coordination_map_after_step0_plus_d18_d19_gate8_plus_d20_d21_gptpro_fixed_post_audit_plus_d22_gate4_local
canonical_for:
  - UIUE R5 dispatch grouping
  - serial_parallel_dependency_order
  - human_review_nodes
  - stop_conditions
  - proof_cap_wording
  - living_r5_route_control
  - post_D18_D19_next_long_task_order
  - d20_d21_supertrain_execution_state
  - d22_runtime_payload_corpus_execution_state
  - grill_burndown_progress_accounting
not_canonical_for:
  - mainline shared runtime field authority
  - RuntimePresentationBridge Swift schema authority
  - OpenSpec requirements
  - implementation authorization
  - runtime/mobile/true_device/voice/model/golden/endpoint readiness
  - merge authorization
  - push authorization
non_claims:
  - no R5 execution complete
  - no runtime-ready
  - no mobile proof
  - no true_device proof
  - no voice-ready
  - no model-ready
  - no golden-ready
  - no endpoint-ready
  - no UIUE merge
  - no V-PASS
  - no S-PASS
  - no U-PASS
  - no A-2
  - no A-2 ready
  - no A-2 complete
---

# UIUE R5 Dispatch-Ready Decomposition Map

## D22 Execution Update (2026-06-30)

Current truth for `UIUE_R5_D22_RUNTIME_PAYLOAD_CORPUS_EXPANSION_SUPERTRAIN`:

- Gate1 main runtime corpus authority and generator: DONE under proof cap. Main manifest now carries D22 metadata for all public fixtures and preserves existing D20/D21 fixture hashes. Hermes Gate1 PASS with P0/P1 empty and a P2 carry-forward to update UIUE manifest decoding in Gate3.
- Gate2 main multi-family payload execution: DONE under proof cap. Main added local runtime-generated public fixtures for window position, screen brightness, ambient brightness, and window noop coverage through `DemoRuntimeSessionRunner -> C3ExecutionPipeline -> runtime adapter -> C2 readback -> RuntimePresentationPayload`. Hermes Gate2 PASS with P0/P1 empty and a P2 reminder that JSON fixtures alone are not standalone runtime provenance.
- Gate3 UIUE expanded corpus consumption: DONE under proof cap. UIUE copied the 9-fixture public corpus, asserts D22 manifest metadata, maps window/screen/ambient/noop fixtures into `PresentationSnapshot`, and retains D20/D21 failure-boundary coverage. Hermes Gate3 PASS with P0/P1 empty and a P2 noop-contract observation recorded in the D22 UIUE receipt.
- Gate4 doc cascade / PR reconcile prep: DONE under proof cap. Hermes Gate4 PASS with P0/P1/P2 empty, covering doc cascade, dirty split, exact-path staging plan, existing PR #7/#6-only plan, and proof wording before the post-gate commit/push path.
- Claude Code final audit is skipped by direct user override after Gate4 (`不需要安排claudecode审计了`); do not count it as an executed D22 audit node.
- First GPT Pro PR-pair audits returned `REQUEST_CHANGES`, not PASS. Owned fixes are applied post-audit: main now represents and emits public result `partial_accept_partial_refuse`, main typed public-vocabulary tests decode all 9 fixtures, and UIUE rejects `cards[].timestamp` because the public projection strips card timestamps. The user then requested a post-fix GPT Pro rerun after push.
- PR #6 reviewability P1-process from the second GPT Pro report is handled by PR-body whitelist rather than PR split, because D22 remains constrained to existing PR #7/#6 only, no new PR, and no merge.
- Lessons learned are captured in the D22 main/UIUE receipts: public projection differs from full runtime DTO decode, manifest truth must be backed by main typed enums and adapter emission, dual GPT Pro reports should be unioned, exact-path staging is not the same as PR-level reviewability, GitHub API push-equivalent needs remote head/tree proof, and first-audit `REQUEST_CHANGES` must not be rewritten as PASS.
- D22 bounded grill crosswalk: recorded in `docs/project/phase0/r5-d22-runtime-payload-corpus-expansion-uiue-gate3-receipt-2026-06-30.md`; D22 does not close the full 215-row historical grill matrix.
- D22 source dispatch artifacts remain trace artifacts and are not staged unless separately authorized.

This update does not claim production runtime readiness, runtime-ready status,
mobile, true-device, live API, UIUE merge, V/S/U-PASS, A-2 completion, R5
completion, voice/model/golden, or endpoint readiness.

## D20/D21 Execution Update (2026-06-30)

Current truth for `UIUE_R5_D20_D21_RUNTIME_UIUE_INTEGRATION_PR_SUPERTRAIN`:

- Gate1 D20 main app runtime entry: DONE under proof cap. Main `App/ContentView.swift` command entry moved to `DemoRuntimeSessionRunner -> C3ExecutionPipeline -> RuntimePresentationPayload`; Hermes Gate1 PASS with a P2 default-runner test gap fixed locally without rerun.
- Gate2 D21 UIUE payload fixture consumer: DONE under proof cap. UIUE added a local JSON fixture consumer into `PresentationSnapshot`; Hermes Gate2 PASS with P0/P1/P2 empty.
- Gate3 cross-repo fixture contract: DONE as `hermes_fail_fixed_post_audit`. Hermes Gate3 FAIL/P1 was limited to untracked fixture packaging; exact-path staging fixed the git-state issue, and local validation was rerun without a Hermes rerun.
- Public fixture sha256: `57951e0811bbb75f9a21516df41295ed1619e18ee6d804ac1ef1b21055cdff8f`.
- Gate4 final reconcile: Hermes PASS; Claude Code final audit PASS with P2 docs nits fixed locally without rerun; both existing PR branches were pushed without creating or merging PRs.
- Combined GPT Pro PR-pair audit returned `REQUEST_CHANGES`, not PASS. Fixes were applied post-audit without a GPT Pro rerun: #6 CI self-invalidating live-head check was repaired, #6 PR body legacy `V-PASS` wording became explicit historical/non-claim wording, UIUE `local_unit` proof mapping became explicit `.localMock`, private/durable marker redaction/rejection became case/diacritic-insensitive, main single-command demo bundle was renamed away from `appDefault`, and main durable failure paths no longer silently retain settled replay/failure-ledger persistence errors.

This update does not claim runtime-ready, mobile, true-device, live proof,
UIUE merge, V/S/U-PASS, A-2 completion, R5 completion, or voice/model/golden/
endpoint readiness.

This document combines the UIUE STEP0 baseline freeze verdict and the main-side STEP0 calibration verdict into a dispatch-ready dependency map. It does not dispatch windows by itself and does not authorize implementation. A later commander prompt may use this map to create bounded dispatches.

As of D17, this file is also the living R5 route-control document. Update it after every accepted dispatch, phase review, or commander route decision. Each update must record live repo truth, proof-class ceiling, grill burndown movement, changed row dispositions, next long-task order, stop conditions, and any stale wording corrected during intake.

## Current Route Snapshot After D18+D19 Gate8 And D20/D21 Dispatch Authorization

Last live-verified commander checkpoint for the D20/D21 route update:

| repo | HEAD | status |
|---|---|---|
| main | `ae0f3e717d9ebc0bf0be2edab0364f314bb41ef0` | branch `codex/rebuild-c6-doc-absorption-20260624`, ahead `0/34` from upstream; preserve-unowned dirty: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `.xcodebuildmcp/`, `Tools/agent-platform-plugin-refs/`; commander-owned new dispatch: `docs/dispatches/2026-06-29-uiue-r5-d20-d21-runtime-uiue-integration-pr-supertrain-dispatch.md`; existing PR #7 draft open against `main` |
| UIUE | `bde4f783cac1950c4c802fd1133f0d1e934e25f6` | branch `uiue/phase4-default-scope-presentation`, ahead `0/92` from upstream; commander-owned route-map update in this file; untracked source dispatches remain: D12, D13, D14, D15, D16+D17, D18+D19; `docs/research/2026-06-29-visual-acceptance-standard/` is unrelated pre-existing untracked evidence; existing PR #6 open against `main` |

This map is a living route-control artifact. The checkpoint above records planning-time truth and loses to live `git status`, `git rev-parse HEAD`, `git rev-list --left-right --count @{u}...HEAD`, and `gh pr view` at D20/D21 execution time.

D18+D19 route truth:

- D15 defines and locally proves a main-owned `RuntimePresentationPayload` / `PresentationReconciliation` contract surface in main. Stable categories are schema version, presentation-safe identity, terminal flag, outcome, proof class, cards, card semantics, readbacks, reconciliation status, presentation-safe trace, and timestamp.
- D15 forbids UIUE-facing exposure of `DemoRuntimeAdapter*`, `RuntimeAdapterBox`, request fingerprints, private ledgers, settled parent-plan internals, raw runtime store, raw model output, training receipt, and adapter-local names.
- D16 defines and locally proves main-owned Core config / `SceneMacroRegistry` stable names for `C018`, plus a demo/debug force-state boundary for `C052`. Gate4R closes the `DemoForceStateContext` synthesized `Decodable` construction bypass and opens `d17_release_gate`.
- D17 implements UIUE consumer authority, raw-name allow/deny mapping, fail-closed tests, and verifier receipts for consuming D15/D16 stable names. UIUE still does not consume private adapter fields or construct/decode `DemoForceStateContext`.
- D18 adds main-owned local durable adapter/C3 replay proof for `C005`/`C061`: file-backed local durable adapter ledger, C3 cross-pipeline settled parent replay, strict unknown-key fail-closed decoding, readback drift fail-closed behavior, and private payload boundary verification. Proof remains `local_durable_adapter_ledger` plus local/unit/integration/static/OpenSpec/GitNexus/audit only.
- D19 adds UIUE durability guard authority and local/unit fail-closed tests. UIUE consumes D18 only as proof-governance/deny-list guardrails and rejects durable/private names such as durable ledger, persistent ledger, adapter ledger, `local_durable_adapter_ledger`, request/parent fingerprints, success/failure ledger, `settledParentPlan`, `runtimeStore`, `rawRuntimeStore`, raw model output, training receipt, adapter-local private names, and D18 storage/schema internals.
- D15 strengthens payload-contract rows under main docs/local + local/unit proof and narrows stale D14 wording: UIUE payload contract definition is no longer future, but UIUE payload consumption, UIUE merge, production runtime, mobile/true-device/live proof, and durable execution remain future work.
- `C018` now has main-owned local/unit Core config / SceneMacroRegistry authority and UIUE D17 consumer mapping. `C052` has main demo/debug boundary local/unit proof and UIUE force-context name fail-closed mapping, but production/runtime force-state remains future work.
- `C005`/`C061` now have main-owned local durable adapter ledger proof after D18, but production durable runtime, mobile/true-device/live proof, UIUE runtime consumption, and UIUE merge remain future work. D19 is negative guard proof only.
- D15 Gate 3 and Gate 4 use operator-authorized CC substitute audit instead of Hermes. This is not a Hermes PASS and does not upgrade proof class.
- D16 Gate3 used operator one-pass Hermes override after fixing a P1 explicit initializer bypass; Gate4 failed on a Codable bypass; Gate4R passed Hermes after removing `DemoForceStateContext` `Decodable`/`Codable`. D17 Gate5 had Hermes FAIL/P1 fixed post-audit for stale `8.C2` proof-promotion wording; Gate6 and Gate7 Hermes passed with P0/P1 empty. Gate8 Hermes had FAIL/P1 stale route-map wording fixed post-audit; Claude Code final audit passed P0/P1 empty; Codex blind final audit found this route-map checkpoint/ledger stale and this follow-up document update records the fix without a second subagent round.
- D18+D19 Hermes round1 over Gates1-3 was FAIL/P1 unknown durable JSON fields fixed post-audit under operator no-rerun override; this must not be described as Hermes PASS. Hermes round2 over Gates4-6 passed with P0/P1/P2 empty. Hermes round3 over Gates7-8 passed with P0/P1/P2 empty and a lower-severity route wording fix afterward. Claude Code final blind audit passed with P0/P1 empty and a P2 durable private-marker redaction fixed in main. Codex native final blind audit failed on stale Gate8 task/receipt/route-map ledger state; that P1 was fixed post-audit and is not a Codex PASS.

## D20+D21 Route Decision After Secondary Teardown-Cite

Hermes's supplemental critique is absorbed with these guardrails, after cross-checking current code paths:

| claim | local cite | route decision |
|---|---|---|
| D20 must not build a sidecar harness while the app still uses the old skeleton. | Pre-D20 before-state evidence: main `App/ContentView.swift:65-76` constructed `DemoWalkingSkeleton` and called `handle(text:)`; `Features/VehicleControl/DemoWalkingSkeleton.swift:29-46` decoded with `FastPathIntentEngine` and wrote via `DemoActionExecutor.applyMockTransition`. This row is superseded by the 2026-06-30 execution update above for current truth. | D20 must physically replace the user-facing app command entry with a main-owned runtime session/controller path. Reusing `FastPathIntentEngine` as text-to-`ToolCallFrame` decode is allowed; execution must flow through `C3ExecutionPipeline` and `RuntimePresentationPayload`, not the old mock executor. |
| D20's real execution chain exists but is not the app entry. | Main `Core/Execution/C3ExecutionPipeline.swift:259-280` has the local durable ledger initializer; `:282-384` performs semantic lookup, allowlist/risk checks, runtime adapter execution, C2 readback verification, and settled-plan recording. | D20 must bridge text input -> `ToolCallFrame` -> `C3ExecutionPipeline.execute` -> sanitized presentation payload. It must not import UIUE `PresentationSnapshot` into main; if an intermediate presentation model is needed, it must stay main-owned under `RuntimePresentationPayload` authority. |
| D21 must be a payload-to-snapshot adapter, not another static allow/deny proof. | UIUE `Core/Presentation/RuntimePresentationConsumerMapping.swift:38-63` defines payload schema and fields, `:112-130` forbids private/durable names, and `:149-153` caps proof classes; UIUE `PresentationSnapshot.swift:59-99` is the frontstage state container; UIUE `App/ContentView.swift:50-68` renders from snapshot state. | D21 must add a UIUE-local JSON fixture consumer that decodes presentation-safe payload JSON and maps into `PresentationSnapshot`, without importing main Swift private types or durable/runtime internals. |
| PR/push must not skip branch reconciliation. | Live truth shows main PR #7 for `codex/rebuild-c6-doc-absorption-20260624`, UIUE PR #6 for `uiue/phase4-default-scope-presentation`, with local ahead counts and dirty/untracked splits above. | D20/D21 final gate must update existing PR #7/#6 only; no new PR, no merge. Before push, it must print exact pathspec commit ledger, dirty split, `git rev-list --left-right --count @{u}...HEAD`, and `gh pr view` for both PRs. |

Grill burndown accounting:

| lens | count | percent | meaning |
|---|---:|---:|---|
| Routed/classified rows | 215/215 | 100.0% | Every grill row has route/action/package. This is routing completion, not implementation completion. |
| Task-shape compression | 8 workstreams from 215 rows | 96.3% compressed | The row set is controlled as 5 implementation dispatches plus 3 ledgers, not 215 standalone tickets. |
| Strict proof-closed rows | about 39/215 | about 18.1% | D16 adds main local/unit Core config / `SceneMacroRegistry` coverage for `C018`; D17 consumes D15 payload/config names under UIUE local/unit fail-closed tests; D18 adds local durable adapter ledger proof for `C005`/`C061`; D19 adds negative UIUE durability guard tests. Proof remains capped; no production runtime/mobile/true-device claim. |
| Demo/debug force-state row counted separately | +1 row | about 14.4% if included | `C052` moved from D9 debug-only bounded spike proof to D16 demo/debug force-state boundary local/unit proof after Gate4R Codable/Decodable bypass repair; production/runtime force-state remains future owner work. |
| Future/human/spike ledgers still open | 45/215 | 20.9% | Future lane 29 + spike 8 + remaining human 8 cannot be closed by runtime code alone. |

Post-D18+D19 Gate8 long-task order:

| order | candidate dispatch | primary repo | goal | hard stop |
|---:|---|---|---|---|
| fixed-post-audit | D20+D21 Runtime/UIUE Integration PR Supertrain | main + UIUE split, no merge | Gates1-4 executed under proof cap. Gate3 remains `hermes_fail_fixed_post_audit`; GPT Pro remains `REQUEST_CHANGES` with post-audit local/PR-body fixes and no GPT Pro rerun. | Stop if this row is rewritten as GPT Pro PASS, runtime-ready, mobile/true-device/live proof, UIUE merge, V/S/U/A-2/R5 completion, or if residual P2 items are treated as closed without separate authority. |
| later | visual L3 / true-device / voice/model/golden lanes | UIUE/main split | Open only with separate authority and proof plan after D20/D21 residuals are reconciled. | Stop if D20/D21 local/unit/integration/simulator proof is treated as V-PASS, A-2 complete, mobile, true-device, voice-ready, model-ready, golden-ready, endpoint-ready, or UIUE merge. |

Do not open C5/C6 model, golden, voice, mobile/true-device, endpoint, merge, or V/S/U/A-2 readiness lanes from this R5 route-control document. D20/D21 starts large-scale coding only inside the runtime-entry and presentation-consumer bridge described above.

## Inputs Frozen

| Input | Current truth | Evidence |
|---|---|---|
| UIUE baseline | Frozen at `926dec8311c63a7b51cd1a1a5f633009e25cf7d2`; UIUE worktree clean at STEP0 verdict. | UIUE STEP0 verdict; commit `926dec8 docs(uiue): freeze r5 baseline for calibration`. |
| Mainline calibration base | Main HEAD `0a2ff0f7d30d6caf2d48f018f6b874828fb70c03`; dirty state preserved and not owned by this map. | Main STEP0 verdict; current main `git status` remains preserve_unowned. |
| Coordination spec boundary | UIUE coordination spec is canonical only for R5 coordination and cannot override mainline shared field authority. | `docs/roadmaps/2026-06-28-uiue-r5-dual-branch-coordination-spec.md:30-32`. |
| Needs-validation rule | `needs-validation` is an evidence gap, not an implementation gap. | `docs/roadmaps/2026-06-28-uiue-r5-dual-branch-coordination-spec.md:59-72`. |
| Dispatch gate | Calibration produces state labels only; implementation requires later commander/user dispatch. | `docs/roadmaps/2026-06-28-uiue-r5-dual-branch-coordination-spec.md:106-108`, `:188-190`. |

## Dispatch Intake Updates

| Dispatch | Controller disposition | Evidence | Remaining cap |
|---|---|---|---|
| Dispatch 1: mainline terminal snapshot adapter behavior proof | Accepted for dispatch-local coverage on 2026-06-28. `C012`, `C060`, `C017`, and `C022` may move from `remaining` to `covered_for_dispatch_1` for UIUE consumer mapping. | Main verdict reports local/unit tests and OpenSpec pass; controller re-ran `openspec validate define-runtime-presentation-bridge --strict`, `openspec validate --all --strict`, `git diff --check`, and `swift test --filter RuntimePresentationBridgeTests` with PASS. Code evidence: `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift:368-473`; tests: `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift:88-184`; spec: `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md:95-123`. | This is local/unit adapter/factory proof only. It is not C3 runtime wiring, not runtime-ready, not UIUE merge, and not mobile/true-device/live proof. |
| Dispatch 2: mainline contract/test hardening | Accepted with Hermes-equivalent caveat on 2026-06-28. `C006`, `C007`, `C024`, `C029`, `C030`, and `C143` may be consumed by UIUE as stable mainline contract rows. Historical disposition at D2 time: `C005`, `C018`, `C052`, and `C061` remained deferred owner gates, not UIUE implementation authority. D16/D17 later updated `C018`/`C052` as recorded in the Dispatch 16+17 row. | Main verdict reports local/unit tests and OpenSpec pass; controller re-ran `openspec validate define-runtime-presentation-bridge --strict`, `openspec validate --all --strict`, `git diff --check`, and `swift test --filter RuntimePresentationBridgeTests` with PASS. Code evidence: `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift:12-37`, `:155-246`, `:248-356`; tests: `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift:186-358`; receipt: `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-mainline-contract-test-hardening-dispatch-2-2026-06-28.md:71-121`. | Hermes first pass P1 was fixed, but final Hermes rerun was replaced by user-authorized Codex-equivalent audit. Treat as accepted for commander workflow, not as Hermes final PASS. Proof remains docs/local + OpenSpec + local/unit only. |
| Dispatch 4: UIUE consumer mapping against stable mainline names | Accepted as `DONE / PASS_WITH_NOTES` on 2026-06-28. UIUE may consume stable mainline names/semantics under local/unit proof cap. Historical disposition at D4 time: `C005`, `C018`, `C052`, `C061` remained deferred mainline owner gates; K1 remained spike ledger. D16/D17 later updated `C018`/`C052` and D17 added payload/config/force-context consumer fail-closed mapping without making UIUE a runtime owner. | UIUE verdict reports `RuntimePresentationConsumerMapping.swift`, `RuntimePresentationConsumerMappingTests.swift`, `PresentationReducedMotionPolicy.swift`, `PresentationReducedMotionPolicyTests.swift`, and receipt. Controller re-ran `swift test --filter RuntimePresentationConsumerMappingTests`, `swift test --filter PresentationReducedMotionPolicyTests`, `openspec validate ui-presentation --strict`, `openspec validate define-runtime-presentation-bridge --strict` in main read-only, and `git diff --check` with PASS. | Proof remains docs/local + local/unit. This is not runtime payload parsing, not runtime adapter wiring, not mobile/true-device a11y proof, and not UIUE merge. |
| Dispatch 3: shared proof-governance hardening | Accepted as `DONE / PASS_WITH_NOTES` on 2026-06-28. `C106` and listed S2 proof-governance rows are covered by receipt schema/static checker evidence. S1 guards remain guarded; K1/M3/H1 remain non-implementation lanes. | UIUE verdict reports `R5ProofGovernanceStaticChecksTests.swift`, `r5-proof-governance-receipt-schema-2026-06-28.md`, and `r5-shared-proof-governance-dispatch-3-2026-06-28.md`. Controller re-ran `swift test --filter R5ProofGovernanceStaticChecksTests`, `openspec validate ui-presentation --strict`, `openspec validate define-runtime-presentation-bridge --strict` in main read-only, and `git diff --check` with PASS. | Proof remains docs/local + receipt_consistency + local_static. This is not runtime proof, mobile/true-device proof, UIUE merge, or R5 closeout acceptance. |
| Dispatch 9: serial bounded lanes with Hermes gates | DONE under proof cap on 2026-06-29. Historical disposition at D9 time: `C052` was covered only as a debug-only bounded spike; `C005` was covered only for the current local mock executor/store write path; `C061` was partial for already-state no-double-write while retry/full adapter idempotency remained deferred; `C018` stayed deferred owner decision; final-art capsule was simulator review prep only; white-edge stayed blocked for threshold. D16 later upgraded `C018` and `C052` to main-owned local/unit authority under proof cap, not runtime/mobile/live readiness. | UIUE commits `cfcf2fd` and `4baab55`; main commit `8c81d13`; receipts `r5-c052-force-state-debug-spike-2026-06-29.md`, `r5-mainline-deferred-gates-c005-c018-c061-2026-06-29.md`, and `r5-final-art-white-edge-visual-review-2026-06-29.md`; Hermes anchors `HERMES_R5_D9_STAGE_1_VERDICT: PASS`, `HERMES_R5_D9_STAGE_2_VERDICT: PASS`, `HERMES_R5_D9_STAGE_3_VERDICT: PASS`; Stage 3 screenshot sha256 `c282b354294956bc450360293f7c6e6cdaf9f0f9038262c897f72f0b526e512f`. | Proof remains docs/local + local_static + local_unit + OpenSpec + simulator_mock. This is not R5 complete, runtime-ready, mobile/true-device proof, UIUE merge, V/S/U-PASS, or A-2 readiness/completion. |
| Dispatch 10: commander reconcile, receipt, map/burndown, validation | DONE after local validation and Hermes hard gate. D10 reconciles D9 without proof promotion and updates this map plus burndown provenance. | Receipt: `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d10-commander-reconcile-2026-06-29.md`; source dispatch: `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-29-uiue-r5-d10-commander-reconcile-dispatch.md`; Hermes anchor: `HERMES_R5_D10_COMMANDER_RECONCILE_VERDICT: PASS`. | D10 is docs/local reconcile only. Main remained read-only; no simulator rerun; no code edits; no push; no proof promotion. |
| Dispatch 12: Runtime Adapter V0 code train | DONE through Gate 4 under proof cap. `C005` and `C061` move to Runtime Adapter V0 local/unit code-backed coverage in main; UIUE remains a guarded consumer and does not invent shared runtime fields. Historical D12 scope excluded `C018`, `C052`, final-art, and white-edge; D16 later handled `C018`/`C052` under separate main-owned authority. | Main commits `b4afc82` and `451c699`; UIUE commit `004ae82`; Gate 1 receipt `r5-d12-gate1-runtime-adapter-v0-openspec-authority-2026-06-29.md`; Gate 2 receipt `r5-d12-gate2-runtime-adapter-v0-code-2026-06-29.md`; Gate 3 receipt `r5-d12-gate3-uiue-consumer-guard-2026-06-29.md`; Hermes anchors `HERMES_R5_D12_GATE_1_OPENSPEC_AUTHORITY_VERDICT: PASS`, `HERMES_R5_D12_GATE_2_RUNTIME_ADAPTER_V0_VERDICT: PASS`, and `HERMES_R5_D12_GATE_3_UIUE_CONSUMER_GUARD_VERDICT: PASS`. | Proof remains docs/local + local_static + local_unit + OpenSpec contract only. The adapter is not wired into production runtime, has no durable ledger, and gives no runtime-ready, mobile/true-device/live, UIUE merge, V/S/U-PASS, or A-2 readiness/completion proof. |
| Dispatch 13: C3 Runtime Adapter Integration Train | DONE through Gate 4 under proof cap. `C005` and `C061` move from D12 standalone adapter local/unit proof to D13 C3-path local/unit code-backed proof in main. UIUE remains a guarded consumer and does not consume Runtime Adapter V0 private fields or define a payload contract. | Main commits `199a12c` and `612e0df`; UIUE commits `4859105` and `98e48da`; Gate 1 receipt `r5-d13-gate1-c3-runtime-adapter-integration-authority-2026-06-29.md`; Gate 2 receipt `r5-d13-gate2-c3-runtime-adapter-integration-code-2026-06-29.md`; Gate 3 receipt `r5-d13-gate3-uiue-c3-adapter-boundary-guard-2026-06-29.md`; Gate 4 receipt `r5-d13-c3-runtime-adapter-integration-commander-reconcile-2026-06-29.md`; Hermes anchors `HERMES_R5_D13_GATE_1_C3_AUTHORITY_VERDICT: PASS`, `HERMES_R5_D13_GATE_2_C3_INTEGRATION_VERDICT: PASS`, `HERMES_R5_D13_GATE_3_UIUE_BOUNDARY_VERDICT: PASS`, and `HERMES_R5_D13_GATE_4_RECONCILE_VERDICT: PASS`. | Proof remains docs/local + local_static + local_unit + OpenSpec/GitNexus only. Ledger is still in-memory; exact stale retry, persistent ledger, production runtime, mobile/true-device/live, UIUE merge, final-art, white-edge, voice/model/golden/endpoint readiness, V/S/U-PASS, and A-2 claims remain unproven. |
| Dispatch 14: Runtime Adapter Residual Train | DONE through Gate 4 under proof cap. `C005` and `C061` keep the same row identity but move from D13 residual state to D14 session-scoped local/unit residual proof: failure ledger, readback reconciliation, exact settled stale retry ordering, parent request fingerprint, and private `RuntimeAdapterBox` boundary. | Main commits `1fd8a7b`, `5d0cd27`, and `66dda25`; UIUE Gate 4 receipt `r5-d14-runtime-adapter-residual-commander-reconcile-2026-06-29.md`; Gate 1 receipt `r5-d14-gate1-runtime-adapter-residual-openspec-authority-2026-06-29.md`; Gate 2 receipt `r5-d14-gate2-runtime-adapter-residual-code-2026-06-29.md`; Gate 3 receipt `r5-d14-gate3-runtime-adapter-residual-verifier-2026-06-29.md`; Codex substitute verifier PASS for Gate 3 because Hermes quota was unavailable. | Proof remains docs/local + local_static + local_unit + OpenSpec/GitNexus + substitute verifier only. Ledger is session-scoped and non-durable; no production runtime, mobile/true-device/live, UIUE payload contract/consumption, UIUE merge, final-art, white-edge, voice/model/golden/endpoint readiness, V/S/U-PASS, or A-2 claim. |
| Dispatch 15: Runtime Presentation Payload Contract Train | DONE through Gate 4 under proof cap and operator Hermes override. Main defines stable presentation-safe payload/readback/reconciliation fields. UIUE only reconciles route map/burndown/receipt and does not implement consumer integration. | Main commits `c212863`, `ab9a682`, and `1d9b674`; UIUE Gate 4 receipt `r5-d15-runtime-presentation-payload-contract-commander-reconcile-2026-06-29.md`; Gate 1 receipt `r5-d15-gate1-runtime-presentation-payload-contract-authority-2026-06-29.md`; Gate 2 receipt `r5-d15-gate2-runtime-presentation-payload-contract-code-2026-06-29.md`; Gate 3 receipt `r5-d15-gate3-runtime-presentation-payload-contract-verifier-2026-06-29.md`; CC substitute audit PASS for Gate 3 and Gate 4 after operator override. | Proof remains docs/local + local_static + local_unit + OpenSpec/GitNexus + CC substitute verifier only. No Hermes Gate 3/4 PASS claimed, no UIUE consumer, no production runtime, mobile/true-device/live, UIUE merge, final-art, white-edge, voice/model/golden/endpoint readiness, V/S/U-PASS, or A-2 claim. |
| Dispatch 16+17: Core config / force-state authority + UIUE consumer supertrain | DONE under proof cap after Gate8 reconcile, Claude Code PASS, Codex blind final audit FAIL/P1 absorbed post-audit. D16 main commits define `C018` Core config / `SceneMacroRegistry` authority and `C052` demo/debug force-state boundary; Gate4R repairs the `DemoForceStateContext` Codable bypass and opens D17. D17 UIUE commits define authority, implement raw-name consumer mapping/fail-closed tests, verify forbidden/private/proof-cap boundaries, reconcile route/burndown, and add a named `runtimeStore` fail-closed assertion. | Main commits `16860c8`, `d00023a`, `47c5e9c`, `e4f2559`, `ac1569f`, `1175a1f`, `7ee172d`; UIUE commits `50d2a74`, `f55a80e`, `87173b1`, `466873d`, `9ec757c`, plus this follow-up route-map final-doc commit; Gate5 receipt `r5-d17-gate5-uiue-consumer-authority-2026-06-29.md`; Gate6 receipt `r5-d17-gate6-uiue-consumer-code-2026-06-29.md`; Gate7 receipt `r5-d17-gate7-uiue-consumer-verifier-visual-smoke-2026-06-29.md`; Gate8 receipt `r5-d16-d17-core-config-force-state-uiue-consumer-commander-reconcile-2026-06-29.md`; Gate4R receipt in main. | Proof remains docs/local + local_static + local_unit + OpenSpec/GitNexus + Hermes/Claude Code/Codex-subagent audit evidence only. No production runtime, durable ledger, mobile/true-device/live, UIUE merge, visual L3/V-PASS, S-PASS, U-PASS, A-2, voice/model/golden/endpoint readiness. Gate3, Gate5, Gate8 Hermes, and Codex blind final audit include audit-fail-fixed-post-audit facts and must not be rewritten as Hermes/Codex PASS. |
| Dispatch 18+19: Runtime durability + UIUE durability guard supertrain | DONE under proof cap after Gate8 final audits, with fixed-post-audit issues recorded. D18 main commits define local file-backed durable adapter ledger and C3 cross-pipeline replay proof for `C005`/`C061`, repair unknown-key durable JSON fail-closed behavior after Hermes round1 P1, harden private payload redaction for `rawRuntimeStore`, and later redact durable private markers after Claude Code P2. D19 UIUE commits define and implement negative durability guard authority/tests only, finalize Gate7 route wording, mark `8.J4`, and fix stale Gate8 task/receipt/route-map ledger state after Codex final audit P1. | Main commits `d5facdb`, `83c286c`, `3439c37`, `b6b92fd`, `d61b3c`, `b6a7937`, `e7e6298`; UIUE commits `fd46e68`, `86ed726`, `8255b3d`, `3336a45`, `15667aa`, `b9869ca`, plus this final docs commit; main receipts `r5-d18-gate1-runtime-durability-authority-2026-06-29.md`, `r5-d18-gate2-durable-ledger-code-2026-06-29.md`, `r5-d18-gate3-c3-durability-integration-2026-06-29.md`, `r5-d18-gate4-private-payload-boundary-verifier-2026-06-29.md`, and main-side reconcile receipt; UIUE receipts `r5-d19-gate5-uiue-durability-guard-authority-2026-06-29.md`, `r5-d19-gate6-uiue-durability-guard-code-2026-06-29.md`, and D18+D19 commander reconcile receipt. | Proof remains local durable adapter ledger + local/static/unit/integration/OpenSpec/GitNexus/Hermes/Claude Code/Codex-subagent audit only. D18 is not production durable runtime; D19 is not UIUE runtime consumer proof. No runtime-ready, mobile/true-device/live, UIUE merge, visual L3/V-PASS, S-PASS, U-PASS, A-2, R5 complete, voice/model/golden/endpoint readiness. Hermes round1 was FAIL/P1 fixed post-audit under operator no-rerun; Hermes round2 and round3 PASS P0/P1/P2 empty; Claude Code final PASS/P2 fixed post-audit; Codex final FAIL/P1 fixed post-audit and not Codex PASS. |

## Dispatch Log

| Dispatch | Status | Prompt path | Target thread | Required return |
|---|---|---|---|---|
| Dispatch 1: mainline terminal snapshot adapter behavior proof | sent and accepted | `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-28-uiue-r5-mainline-terminal-snapshot-adapter-dispatch.md` | `019f0c69-972a-7f61-9515-3a101d5c0131` | received `DONE`; no unresolved P0/P1; local/unit only. |
| Dispatch 2: mainline contract/test hardening | accepted with Hermes-equivalent caveat | `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-28-uiue-r5-mainline-contract-test-hardening-dispatch.md` | `019f0c69-972a-7f61-9515-3a101d5c0131` | received `DONE`; `can_UIUE_start_consumer_mapping=yes`; preserve caveat that final Hermes rerun was replaced by user-authorized Codex-equivalent audit. |
| Dispatch 4: UIUE consumer mapping against stable mainline names | accepted as DONE / PASS_WITH_NOTES | `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-28-uiue-r5-uiue-consumer-mapping-dispatch.md` | `019f0c69-7c7d-7173-a67b-758e786164b1` | received `DONE`; `can_return_for_commander_reconcile=yes`; Codex subagent primary audit has no unresolved P0/P1; local/unit only. |
| Dispatch 3: shared proof-governance hardening | accepted as DONE / PASS_WITH_NOTES | `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-28-uiue-r5-shared-proof-governance-dispatch.md` | `019f0c69-7c7d-7173-a67b-758e786164b1` | received `DONE`; `can_open_commander_reconcile=yes`; Codex subagent primary audit has no unresolved P0/P1; docs/local/static only. |
| Dispatch 5: commander reconcile and provenance ledger | completed as DONE / PASS_WITH_NOTES | `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-28-uiue-r5-commander-reconcile-dispatch.md`; receipt `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-commander-reconcile-dispatch-5-2026-06-28.md` | current commander thread | accepted D1/D2/D3/D4 under proof caps, preserved deferred gates and non-implementation ledgers, and prepared exact-path staging plan without git integration. |
| Dispatch 6: dual-repo integration train | DONE; UIUE commit `9d50aa0`, main commit `d332db7`; stale D6 receipt status reconciled by D7 docs pass | `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-28-uiue-r5-dual-repo-integration-train-dispatch.md`; receipt `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-dual-repo-integration-train-2026-06-28.md` | `019f0ebc-8e13-74a0-a2fb-7a8d402645bf` | D6 integrated D1-D5 under docs/local + local/unit/static/OpenSpec proof caps; no runtime/mobile/true-device/UIUE merge/V/S/U/A-2 claim. |
| Dispatch 7: human review gate prep | DONE; human review packet produced; simulator not opened because no item requires current simulator inspection | `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-28-uiue-r5-human-review-gate-dispatch.md`; packet `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-human-review-gate-2026-06-28.md` | `019f0ebc-8e13-74a0-a2fb-7a8d402645bf` | no new subagent by commander order; checklist routes human/product, deferred owner gates, K1 spike ledger, and M3/future lanes without implementation or proof promotion. |
| Dispatch 9: serial bounded lanes with Hermes gates | DONE; UIUE commits `cfcf2fd`, `4baab55`; main commit `8c81d13` | `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-29-uiue-r5-serial-bounded-lanes-dispatch.md`; receipts listed in Dispatch Intake Updates | `019f10df-8ebc-7c71-b026-f3dbc0262153` | three serial stages passed local validation and Hermes anchored gates; dispositions are bounded under proof cap and preserve residual future work. |
| Dispatch 10: commander reconcile, receipt, map/burndown, validation | DONE after Hermes hard gate | `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-29-uiue-r5-d10-commander-reconcile-dispatch.md`; receipt `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d10-commander-reconcile-2026-06-29.md` | `019f10df-8ebc-7c71-b026-f3dbc0262153` | reconciled D9 into map/burndown without proof promotion; local validation passed and `HERMES_R5_D10_COMMANDER_RECONCILE_VERDICT: PASS` was required before commit. |
| Dispatch 12: Runtime Adapter V0 code train | DONE after four serial Hermes gates | `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-29-uiue-r5-d12-runtime-adapter-v0-code-train-dispatch.md`; receipts listed in Dispatch Intake Updates | `019f10df-8ebc-7c71-b026-f3dbc0262153` | Gate 1 OpenSpec authority, Gate 2 main Runtime Adapter V0 code, Gate 3 UIUE consumer guard, and Gate 4 reconcile passed local validation and Hermes; no merge, push, runtime-ready, mobile/true-device, V/S/U, or A-2 claim. |
| Dispatch 13: C3 Runtime Adapter Integration Train | DONE after four serial Hermes gates | `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-29-uiue-r5-d13-c3-runtime-adapter-integration-dispatch.md`; receipt `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d13-c3-runtime-adapter-integration-commander-reconcile-2026-06-29.md` | `019f10df-8ebc-7c71-b026-f3dbc0262153` | Gate 1 C3 authority, Gate 2 main C3 adapter integration, Gate 3 UIUE boundary guard, and Gate 4 reconcile passed local validation and Hermes; no push, merge, runtime-ready, mobile/true-device, UIUE payload contract, V/S/U, or A-2 claim. |
| Dispatch 14: Runtime Adapter Residual Train | DONE under Hermes-quota override with Codex substitute verifier | `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-29-uiue-r5-d14-runtime-adapter-residual-train-dispatch.md`; receipt `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d14-runtime-adapter-residual-commander-reconcile-2026-06-29.md` | `019f1215-ca98-7083-a6dd-9a62d46444ad` | Gate 1 OpenSpec authority, Gate 2 main residual code, Gate 3 GitNexus/substitute verifier, and Gate 4 reconcile passed local validation / Codex audits; no Hermes Gate 3 anchor claimed, no push, merge, runtime-ready, mobile/true-device, UIUE payload contract, V/S/U, or A-2 claim. |
| Dispatch 15: Runtime Presentation Payload Contract Train | DONE under operator Hermes override with CC substitute verifier | `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-29-uiue-r5-d15-runtime-presentation-payload-contract-dispatch.md`; receipt `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d15-runtime-presentation-payload-contract-commander-reconcile-2026-06-29.md` | `019f1215-ca98-7083-a6dd-9a62d46444ad` | Gate 1 OpenSpec authority, Gate 2 main payload code/tests, Gate 3 clean-worktree/GitNexus/UIUE-boundary verifier, and Gate 4 UIUE reconcile passed local validation / CC substitute audits; no Hermes Gate 3/4 PASS claimed, no push, merge, runtime-ready, mobile/true-device, UIUE consumer integration, V/S/U, or A-2 claim. |

## Calibration Result

Main-side calibration converted the high-risk `needs-validation` subset as follows:

| Package | Covered | Remaining | Merge-only | Non-claim | Blocked | Dispatch implication |
|---|---:|---:|---:|---:|---:|---|
| `M1-mainline-P0-bridge-contract` | 1 | 2 | 0 | 0 | 0 | Mainline must handle 2 terminal-snapshot behavior gaps before UIUE can claim those behaviors. |
| `S1-shared-P0-proof-governance` | 4 | 1 | 0 | 2 | 0 | One checker/receipt hardening item remains; two are guardrails, not implementation. |
| `M2-mainline-P1-contract-test` | 8 | 12 | 0 | 2 | 0 | Mainline contract/test hardening remains; several DTO vocabulary rows are already stable. |
| Total calibrated | 13 | 15 | 0 | 4 | 0 | Dispatch only the 15 remaining rows plus one proof-governance hardening item; preserve non-claims as gates. |

Rows already stable for UIUE consumption are the mainline DTO/enum/proof-cap rows marked `covered` in STEP0 main verdict. They do not authorize UIUE to invent fields or upgrade local/simulator proof.

## Row Calibration Delta From 13-Package Source

This table explains the intentional delta between the frozen 13-package source and the five dispatch groups below. It prevents row loss when a row is moved from its original package into a better execution grouping.

| Row | Original package | New disposition | Calibration evidence | Why |
|---|---|---|---|---|
| `C105` | `M1-mainline-P0-bridge-contract` | `covered`; referenced by proof-governance wording, not dispatched as remaining. | Source row: `burndown-dispatch-plan.md:137`; proof enum/display caps: `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift:110-127`; fail-closed test: `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift:39-46`. | Mainline already locks finite proof classes and empty readiness display caps. This is covered only as proof-cap contract, not as true-device/live proof. |
| `C017` | `M2-mainline-P1-contract-test` | Dispatch 1. | Source row: `burndown-dispatch-plan.md:172`; mainline snapshot DTO fields: `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift:311-356`; terminal adapter behavior: `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift:416-473`. | Partial deny needs composite terminal snapshot/readback behavior. Dispatch 1 covers adapter/factory behavior under local/unit proof cap, but not full runtime execution. |
| `C022` | `M2-mainline-P1-contract-test` | Dispatch 1. | Source row: `burndown-dispatch-plan.md:174`; phase1 grill says thrown C3 errors still need future adapter classification at `/Users/wanglei/workspace/MAformac/docs/project/phase0/runtime-presentation-bridge-phase1-grill-2026-06-28.md:106`. | Cancel/interruption/timeout/backgrounding terminality is behavior proof, not just enum/DTO shape, so it must wait for terminal snapshot adapter tests/fixtures. |
| `K1` rows | `K1-spike-before-implementation` | Spike-before-implementation ledger, not implementation dispatch. | Package count and wave: `burndown-dispatch-plan.md:83`, `:107`; row detail: `burndown-dispatch-plan.md:390-406`. | These 8 rows require bounded falsification receipts before promotion. They should not disappear and should not be mixed into implementation dispatches. |

## Dependency Graph

```mermaid
flowchart TD
  D0["D0 UIUE baseline freeze<br/>DONE: 926dec8"]
  M0["M0 main calibration<br/>DONE: 0a2ff0f"]
  M1["Dispatch 1: Mainline terminal snapshot adapter proof<br/>DONE local/unit for C012 C060 C017 C022"]
  M2["Dispatch 2: Mainline contract/test hardening<br/>C005 C006 C007 C018 C024 C029 C030 C052 C061 C143"]
  S1["Dispatch 3: Shared proof-governance hardening<br/>C106 plus receipt/checker wording"]
  U1["Dispatch 4: UIUE consumer mapping against stable names<br/>C034 plus covered DTO/enum/proof names"]
  R1["Dispatch 5: Commander reconcile and provenance ledger<br/>S2 selected rows + M3 merge-only target list"]
  H1["Human/product review ledger<br/>H1 rows and accepted HR policy"]
  K1["Spike-before-implementation ledger<br/>8 K1 rows require bounded spike receipts"]
  F1["Future non-claim ledger<br/>voice model golden mobile true-device"]

  D0 --> M0
  M0 --> M1
  M0 --> M2
  M0 --> S1
  M1 --> U1
  M2 --> U1
  S1 --> U1
  U1 --> R1
  S1 --> R1
  H1 --> U1
  K1 --> R1
  F1 --> R1
```

## Recommended Dispatch Count

Original D1-pre recommendation: **5 implementation dispatches**, plus **3 ledgers**
that should not become implementation dispatches unless the user explicitly
reopens them. This plan is now historical route provenance consumed through
D13. Use "Current Route Snapshot After D18+D19 Gate8 And D20/D21 Dispatch
Authorization" and "D20+D21 Route Decision After Secondary Teardown-Cite" for
active next-task ordering.

| # | Dispatch | Owner | Rows / scope | Serial or parallel | Proof cap | Exit gate |
|---:|---|---|---|---|---|---|
| 1 | Mainline terminal snapshot adapter behavior proof, not DTO-only proof | mainline | `C012`, `C060`, `C017`, `C022` | DONE for local/unit dispatch coverage; serial gate for UIUE behavior claims is now open only under proof cap. | local/unit/integration at most; no runtime-ready claim. | Covered by terminal snapshot adapter/factory tests and OpenSpec receipt. This does not prove real C3 runtime wiring. |
| 2 | Mainline contract/test hardening | mainline | `C005`, `C006`, `C007`, `C018`, `C024`, `C029`, `C030`, `C052`, `C061`, `C143` | After or coordinated with Dispatch 1; avoid two mainline windows editing the same bridge files concurrently. | docs/local/unit only. | Each remaining contract row has one falsifiable test/spec/receipt or is explicitly deferred. |
| 3 | Shared proof-governance hardening | commander + both branches | `C106` plus proof wording/checker for S1; later consumes S2 hygiene rows `C046`, `C047`, `C048`, `C049`, `C107`, `C108`, `C110`, `C111`, `C179`, `C193`, `C195`, `C196`. | Split into field-independent and field-dependent subwork. Field-independent work can start after STEP0; field-dependent checker/crosswalk work waits for mainline field/type verdicts from Dispatch 1/2. | docs/local/receipt consistency only. | Field-independent: forbidden-claim grep, non-claim wording, dirty split, proof-cap text. Field-dependent: receipt schema, crosswalk checker, field/enum consistency checks after mainline verdict. |
| 4 | UIUE consumer mapping against stable mainline names | UIUE | `C034` plus covered fields from main verdict: result enum, snapshot fields, proof class caps, no `ScopeOrigin.missing`. Include accepted product policy for `C155`, `C172`, `C194` only if no shared fields are invented. | Waits for Dispatch 1/2 for behavior rows. Early UIUE work is limited to docs/local matrix only: no shared adapter code, no parsing mainline runtime payload, no new shared field names. | UIUE local/unit/simulator only. | UIUE tests/checkers prove consumer mapping uses mainline stable names and does not promote simulator/local proof. |
| 5 | Commander reconcile and provenance ledger | commander | S2 final reconcile plus M3 merge-only target list. Do not implement 52 M3 rows independently. | Last before closeout. | coordination proof only. | Row IDs are preserved, remaining rows carry owners, non-claim ledgers remain non-claim. |

Ledgers not counted as implementation dispatches:

| Ledger | Scope | Rule |
|---|---|---|
| Human/product review ledger | H1 rows including `C134`, `C135`, `C155`, `C160-C164`, `C172`, `C173`, `C194`. | Product/a11y/final-art decisions may be recorded, but cannot be encoded as implementation truth before human choice. |
| Spike-before-implementation ledger | K1 rows `C082`, `C083`, `C096`, `C117`, `C182`, `C197`, `C207`, `C208`. | Each row needs a bounded spike receipt with pass/partial/blocked and proof class before promotion. K1 rows are not implementation dispatches from this map. |
| Future non-claim ledger | voice/model/golden/mobile/true-device/C5/C6 future lanes. | Preserve as future boundaries; never use this R5 map to claim readiness. |

## What Can Run In Parallel

Safe parallel work:

- Mainline Dispatch 1 and Dispatch 3 can overlap only for field-independent proof-governance work: forbidden-claim grep, non-claim wording, dirty split, and proof-cap text.
- Field-dependent proof governance waits for mainline field/type verdicts: receipt schema, crosswalk checker, and field/enum consistency checks.
- UIUE can work on docs/local matrix and customer-facing policy wording already accepted by the user: no `operatorReview` / `acceptance` in customer UI, summary expands only, gear/safety display-only, `仅展示，不可操作`, mock controls inside expanded controls with readback.
- Future non-claim ledger can be maintained in parallel as docs-only guardrail.

Unsafe parallel work:

- Two mainline implementation windows should not concurrently edit `RuntimePresentationBridge.swift`, OpenSpec bridge files, or `RuntimePresentationBridgeTests.swift`.
- UIUE must not implement adapter consumption for terminal snapshot behavior until mainline Dispatch 1 has a verdict.
- UIUE must not introduce shared bridge fields, proof enum values, result enum names, shared adapter code, or private/raw runtime payload parsing outside mainline authority. D21 may implement only the authorized presentation-safe public JSON fixture consumer.

## Mainline Wait Gates

Dispatch 1 moved these rows out of mainline-wait for UIUE consumer mapping, but only under local/unit proof cap:

| Row | Current disposition | Proof cap |
|---|---|---|
| `C012` | Covered for Dispatch 1: guard denial maps to presentation-safe terminal refusal snapshot. | local/unit adapter proof; no real runtime guard wiring claim. |
| `C060` | Covered for Dispatch 1: thrown adapter/runtime failure maps to terminal `runtime_error` snapshot. | local/unit adapter proof; no C3 do/catch integration claim. |
| `C017` | Covered for Dispatch 1: partial accept/refuse maps to mixed cards plus accepted readbacks. | local/unit adapter proof; no full multi-effect runtime execution claim. |
| `C022` | Covered for Dispatch 1: cancel/interruption/timeout/backgrounding map to terminal snapshots. | local/unit adapter proof; no lifecycle integration claim. |

These rows still cannot be consumed as behavior-complete by UIUE until future owners provide runtime/config/tooling proof. D9 narrowed three of them under bounded proof caps but did not close the future work:

| Row | Reason to wait |
|---|---|
| `C005` | D18 now proves main-owned local file-backed durable adapter ledger replay for adapter-owned mock writes under `local_durable_adapter_ledger` proof cap, including strict fail-closed durable JSON handling after Hermes round1 P1. D19 UIUE rejects D18 durability/private names as negative guard only. Production durable runtime wiring, mobile/true-device/live proof, UIUE runtime consumer proof, and UIUE merge remain future work. |
| `C018` | D16 now provides mainline Core config / `SceneMacroRegistry` local/unit authority, and D17 consumes the stable names in UIUE fail-closed mapping only. Production/runtime readiness, UIUE ownership of Core config truth, and UIUE merge remain future work. |
| `C052` | D16 now provides a demo/debug force-state boundary under local/unit proof, and Gate4R closes the `DemoForceStateContext` Codable/Decodable construction bypass. Production/runtime force-state authority, mobile/true-device/live proof, and UIUE force-state ownership remain future work. |
| `C061` | D18 extends D14 retry/reconciliation residuals from session-scoped proof to local durable adapter/C3 replay proof: cross-adapter replay, cross-pipeline settled parent replay, fingerprint mismatch fail-closed, readback drift fail-closed, and unknown durable keys fail closed. D19 UIUE rejects durable/private names and does not consume retry identity or ledger internals. Production durable runtime, mobile/true-device/live proof, and UIUE merge remain future work. |

Rows `C006`, `C007`, `C024`, `C029`, `C030`, and `C143` are covered for local/unit/OpenSpec consumption by Dispatch 2 only; they are still not runtime-ready, mobile, true-device, live, V-PASS, S-PASS, U-PASS, A-2, A-2 ready, or A-2 complete proof.

## Human Review Nodes

| Node | Trigger | Required decision |
|---|---|---|
| HR-A | Before UIUE changes customer-facing proof/acceptance wording. | Confirm internal proof labels remain hidden from customer UI. Current accepted policy can be used; changes need review. |
| HR-B | Before direct touch on summary/gear/safety controls. | Confirm disabled/display-only/readback/a11y policy. |
| HR-C | Before final-art capsule, white-edge threshold, or aesthetic closeout. | Decide whether warning remains warning or becomes a formal threshold. |
| HR-D | Before mobile/true-device/a11y/voice/model/golden claims. | Separate proof plan and human acceptance; this R5 map cannot sign those. |
| HR-E | Before UIUE merge, push/PR, or public release. | Confirm proof class, dirty split, and non-claim wording. |

## Proof Caps

| Surface | Maximum proof class in this dispatch map | Forbidden promotion |
|---|---|---|
| Mainline bridge DTO/tests | `docs/local + openspec_contract + local_unit` | Not runtime-ready, not mobile, not true-device, not live. |
| Mainline terminal adapter tests | `local/unit/integration` unless a later dispatch explicitly runs real runtime proof. | DTO/test success is not runtime acceptance. |
| UIUE consumer mapping | `docs/local + local_unit + simulator_mock` | Not mainline proof, not runtime proof, not mobile/true-device proof. |
| Commander reconcile | `docs/local + receipt_consistency` | Not implementation closeout. |
| Human/product policy | human decision record only | Not V-PASS/S-PASS/U-PASS unless user explicitly signs those gates in a separate acceptance context. |
| Future lanes | `non-claim-only` | No voice/model/golden/mobile/true-device readiness. |

## Stop Conditions

Stop and return to commander if any dispatch attempts one of these:

1. Turns `needs-validation` directly into implementation without the row being marked `remaining`.
2. Claims R5 complete, runtime-ready, mobile, true_device, voice-ready, model-ready, golden-ready, endpoint-ready, UIUE merge, V-PASS, S-PASS, U-PASS, A-2, A-2 ready, or A-2 complete.
3. Adds `ScopeOrigin.missing` or any equivalent Core shared enum without mainline authority.
4. Lets UIUE invent shared Runtime-Presentation fields, enum values, or proof classes.
5. Treats UIUE docs/local/simulator evidence as mainline/runtime proof.
6. Mixes main dirty residual with UIUE docs commits or uses `git add .`.
7. Edits raw customer/source material into repo artifacts.
8. Dispatches M3 merge-only rows as 52 standalone implementation tasks.
9. Runs voice/model/golden/mobile/true-device work under this R5 dispatch map.
10. Lets UIUE early work escape docs/local matrix into shared adapter code, main private Swift types, durable/runtime internals, or private raw payload parsing. D21 may parse only presentation-safe public JSON fixtures under local/unit proof cap.

## Dispatch Decision

The original D1-pre five-dispatch plan and subsequent D12-D19 trains have been
consumed through D18+D19 Gate8. Do not restart Dispatch 1-5, D12-D19, or their
historical gates unless a new P0/P1 finding invalidates their receipts.

Current commander route:

1. Continue `UIUE_R5_D20_D21_RUNTIME_UIUE_INTEGRATION_PR_SUPERTRAIN` in Gate4
   final reconcile. Gates1-3 are not V-PASS/A-2/R5 completion proof.
2. D20 has moved main app command execution off the old `DemoWalkingSkeleton`
   entry and onto a main-owned C3/runtime-adapter/payload entry path.
3. D21 has added a UIUE-local presentation-safe JSON fixture consumer into
   `PresentationSnapshot`; UIUE does not import main private Swift types or
   consume durable/runtime internals.
4. Gate 4 must reconcile dirty/ahead/open-PR truth and update only existing PR
   #7 and PR #6 before GPT Pro PR audit; no new PR, no merge.
5. Keep human/product, spike-required, visual L3, true-device, voice, model,
   golden, endpoint, merge, and V/S/U/A-2 readiness rows as separate future
   lanes until explicitly reopened.
6. Update this file after each accepted verdict before dispatching the next
   long task.

Do not dispatch the human/product ledger, spike-before-implementation ledger, or future-lane ledger as implementation work. They are governance surfaces, bounded falsification receipts, and proof caps.

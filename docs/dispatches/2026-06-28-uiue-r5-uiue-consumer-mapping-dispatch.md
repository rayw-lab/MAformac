---
status: DISPATCH_READY
artifact_kind: implementation_dispatch
created_at: 2026-06-28
from: UIUE R5 commander
to: UIUE Codex window
target_thread: 019f0c69-7c7d-7173-a67b-758e786164b1
priority: P1
dispatch_id: R5-D4-uiue-consumer-mapping
proof_class_ceiling: docs/local + local_unit + simulator_mock
source_map:
  - /Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md
  - /Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dual-branch-coordination-spec.md
  - /Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md
  - /Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift
  - /Users/wanglei/workspace/MAformac/docs/project/phase0/r5-mainline-terminal-snapshot-adapter-dispatch-1-2026-06-28.md
  - /Users/wanglei/workspace/MAformac/docs/project/phase0/r5-mainline-contract-test-hardening-dispatch-2-2026-06-28.md
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

# Dispatch 4 - UIUE R5 Consumer Mapping Against Stable Mainline Names

## 0. Route Metadata

- **TO**: UIUE Codex window `019f0c69-7c7d-7173-a67b-758e786164b1`
- **FROM**: UIUE R5 commander
- **MODE**: bounded UIUE consumer implementation + docs/local matrix + audit loop
- **PRIORITY**: P1. Mainline Dispatch 1 and Dispatch 2 are accepted for local/unit contract consumption, but UIUE must preserve proof caps and deferred gates.
- **One-line deliverable**: update UIUE consumer mapping and local checks so UIUE uses only stable mainline Runtime-Presentation names/semantics, without inventing shared fields or promoting local/simulator proof.
- **Proof ceiling**: `docs/local + local_unit + simulator_mock`. This dispatch cannot produce runtime/mobile/true_device/live/V/S/U proof.
- **Dispatch class**: UIUE implementation/consumer-mapping dispatch with mandatory row mapping receipt and Codex subagent P0/P1 audit as the primary audit gate. Hermes is not the audit subject for this dispatch.

## 1. Cold-Start Context

UIUE STEP0 froze the R5 baseline at commit `926dec8311c63a7b51cd1a1a5f633009e25cf7d2`. Dispatch 1 and Dispatch 2 then gave mainline local/unit contract evidence that UIUE may consume, under proof caps:

- Dispatch 1 covered terminal snapshot adapter/factory behavior for `C012`, `C060`, `C017`, and `C022`.
- Dispatch 2 covered `C006`, `C007`, `C024`, `C029`, `C030`, and `C143`.
- Dispatch 2 explicitly deferred `C005`, `C018`, `C052`, and `C061`.
- Dispatch 2 was accepted with a caveat: Hermes first pass P1 was fixed, but final Hermes rerun was replaced by user-authorized Codex-equivalent audit. Treat this as accepted for commander workflow, not as a Hermes final PASS.

This dispatch is for UIUE consumer mapping only. It does not authorize UIUE to define mainline shared fields, result enums, proof classes, event kinds, runtime adapter behavior, force-state behavior, retry/idempotency semantics, SceneMacroRegistry, or runtime execution.

## 2. Authority And Source Truth

Read these first, in order:

1. `/Users/wanglei/workspace/MAformac-uiue/AGENTS.md` if present, then the nearest project guidance in UIUE.
2. `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
3. `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dual-branch-coordination-spec.md`
4. `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md`
5. `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift`
6. `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift`
7. `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-mainline-terminal-snapshot-adapter-dispatch-1-2026-06-28.md`
8. `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-mainline-contract-test-hardening-dispatch-2-2026-06-28.md`

Authority order:

1. mainline Swift carrier + OpenSpec + mainline receipts for shared names and contracts
2. this dispatch
3. UIUE coordination docs for route/provenance
4. older grill rows only as strata/supersession background

UIUE docs are not mainline shared-field authority. If a field/name is absent from mainline evidence, do not invent it.

## 3. Mandatory Preflight

Run and record:

```bash
cd /Users/wanglei/workspace/MAformac-uiue
pwd
git branch --show-current
git rev-parse HEAD
git status --short --branch
git diff --check
```

Also confirm mainline reference without modifying main:

```bash
cd /Users/wanglei/workspace/MAformac
git branch --show-current
git rev-parse HEAD
git status --short --branch
openspec validate define-runtime-presentation-bridge --strict
```

Before edits, classify dirty state:

- `owned`: UIUE files this dispatch will touch.
- `preserve_unowned`: existing dirty files not owned by this dispatch.
- `no_touch`: main repo, raw source material, frozen R5 baseline docs unless you are adding a new receipt/mapping file or narrowly updating a dispatch log.

Do not stage, commit, push, or use `git add .` unless the user separately authorizes git integration. If staging later becomes authorized, use exact pathspecs only.

## 4. Stable Mainline Names UIUE May Consume

Use these mainline names exactly as written. Do not rename, alias as shared truth, or create UIUE-only shared substitutes.

| Surface | Stable names / semantics | Evidence |
|---|---|---|
| Event kind | `text_input`, `mic_start`, `mic_end`, `card_tap`, `cancel`, `interruption`; timeout is terminal stop/result, not a user interaction event kind. | `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift:3-9`; Dispatch 2 receipt rows `C006`. |
| Event source | `user`, `system`, `demo_harness`, `runtime_adapter`. | `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift:12-17`; Dispatch 2 receipt row `C007`. |
| Runtime result | `accepted_tool_call`, `clarify_missing_slot`, `refusal_no_available_tool`, `refusal_safety_or_policy`, `already_state_noop`, `runtime_error`, `cancelled`, `interrupted`. | `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift:47-55`; Dispatch 1 receipt. |
| Proof class caps | Finite proof classes have empty `displayCaps`; readiness claims remain deny-list only. | `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift:120-136`; main tests and receipts. |
| Trace envelope | `TraceEnvelope.traceID`, append-only monotonic `entries`, presentation-safe redaction of raw model output, training receipt, raw runtime store markers. | `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift:153-220`; Dispatch 2 receipt rows `C024`, `C143`. |
| Card semantics | `PresentationCardSemantics.cellKey`, `role`, `scopeOrigin`, `reason`, `isActive`, `siblingKeys`; refused/unsafe can outrank satisfied. | `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift:248-352`; Dispatch 2 receipt rows `C029`, `C030`. |
| Terminal snapshots | terminal snapshot carries `isTerminal`, `traceID`, `runtimeOutcome`, `proofClass`, and safe reason/readback/card semantics. | Dispatch 1 receipt rows `C012`, `C060`, `C017`, `C022`. |

Deferred gates UIUE must preserve:

| Row | Gate |
|---|---|
| `C005` | Runtime write ownership remains future mainline runtime adapter wiring; UIUE must not prove direct store/executor behavior. |
| `C018` | `SceneMacroRegistry`/Core config is not shared authority yet; UIUE must not treat it as hidden shared runtime config. |
| `C052` | Force-state behavior is deferred; UIUE must not create production force-state behavior or shared event semantics. |
| `C061` | Retry/idempotency/no-double-write belongs to future runtime adapter execution tests; UIUE must not claim it from passive DTO mapping. |
| K1 rows | `C082`, `C083`, `C096`, `C117`, `C182`, `C197`, `C207`, `C208` remain spike-before-implementation ledger only. |

## 5. Task

Find the existing UIUE consumer/mapping/test/checker surfaces for Runtime-Presentation bridge consumption, then make the smallest scoped changes that:

1. Map UIUE presentation consumer code/tests/docs to the stable mainline names in Section 4.
2. Ensure UIUE does not parse Chinese display copy to infer machine state.
3. Ensure timeout is treated as terminal outcome semantics, not a required user event kind.
4. Ensure event source/provenance and scope origin remain separate.
5. Ensure trace/card proof uses mainline redaction, monotonic trace, card role/active/sibling/reason/scope semantics where UIUE consumes them.
6. Preserve deferred gates for `C005`, `C018`, `C052`, and `C061` as explicit non-consumable rows.
7. Cover `C034` if it belongs to this UIUE consumer path: Reduce Motion must have a non-animation channel. If the relevant UIUE surface is not present or is out of scope, mark `deferred_with_owner` with file search evidence.

Acceptable outputs include focused UIUE tests/checkers, a consumer mapping matrix, or narrowly scoped implementation using existing UIUE patterns. Do not create mainline-like bridge types inside UIUE.

## 6. Writable And No-Touch Paths

Writable in `/Users/wanglei/workspace/MAformac-uiue` only:

- existing UIUE Runtime-Presentation consumer/mapping/test/checker files you identify by search.
- `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/` or nearest existing UIUE receipt directory for Dispatch 4 receipt.
- `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md` only if updating dispatch log/intake status is necessary.
- `/Users/wanglei/workspace/MAformac-uiue/Reports/` for ignored audit artifacts if needed.

No-touch:

- `/Users/wanglei/workspace/MAformac/` except read-only reference.
- raw customer/source materials.
- UIUE files unrelated to Runtime-Presentation consumer mapping.
- shared mainline bridge schemas, enums, proof classes, adapter code, and runtime payload definitions.
- C5/C6/model/voice/golden/mobile/true-device/endpoint implementation.

## 7. Harness And Metacognition Requirements

Apply these execution rules:

1. **Truth-first start**: repo, branch, HEAD, dirty, nearest authority, and validation commands before edits.
2. **Scope contract before edits**: goal, non-goals, writable paths, no-touch paths, validation gates, stop conditions.
3. **Read before edit**: cite exact file:line for every load-bearing claim.
4. **No fake green**: if a row or mapping lacks proof, mark `deferred_with_owner`, `non_claim_guard`, `blocked`, or `PARTIAL`, not DONE.
5. **Owned/unowned split**: preserve existing dirty residual and do not touch main.
6. **Pathspec only**: if staging later becomes authorized, use exact pathspecs; never `git add .`.
7. **Proof class discipline**: UIUE local/unit/simulator proof cannot become runtime/mobile/true-device/live/V/S/U proof.
8. **Grill burndown required**: closeout must include before/after status for `C034`, all consumed Dispatch 1/2 rows, and all deferred gates.
9. **Same-class risk map**: audit for shared-field invention, display-copy parsing, proof promotion, simulator proof promotion, raw leak, and drift from mainline names.
10. **Codex subagent audit is the primary audit gate**: after local implementation and before final verdict, run a Codex native subagent audit scoped to P0/P1 risks in this dispatch. If unavailable, no evidence, or unresolved P0/P1, final status must be `PARTIAL`.
11. **No Hermes hard gate**: do not make Hermes/GLM the audit subject for this dispatch. A worker may run an extra Hermes/GLM review only as optional supplementary evidence, but it cannot replace the Codex subagent audit and is not required for DONE.

## 8. Codex Subagent Audit

After implementation and local validation pass, run a Codex native subagent audit focused on P0/P1. This is the required audit subject for this dispatch.

The audit prompt must include:

- this dispatch path
- files changed
- `git diff --stat`
- relevant diff or patch
- validation output
- mapping/disposition table
- non-claims
- exact ask: identify P0/P1 only, especially UIUE shared-field invention, stale mainline names, display-copy parsing, local/simulator proof promotion, deferred-gate consumption, K1 promotion, raw model/store/training leak, dirty/staging risk, and missing row coverage.

Loop rule:

- If Codex subagent reports P0/P1: fix only in scope, rerun focused validation, rerun Codex subagent audit.
- Continue until no unresolved P0/P1.
- If Codex subagent audit is unavailable, returns no evidence, or still has unresolved P0/P1, final status must be `PARTIAL`, not DONE.
- P2/P3 may be carried as residual risk with owner/trigger.

## 9. Required Validation

Minimum validation:

```bash
cd /Users/wanglei/workspace/MAformac-uiue
git diff --check
```

Also run the smallest existing UIUE test/checker commands for files you touch. If no focused test exists, create a local/static checker or receipt explaining the gap and use `PARTIAL` unless the mapping is docs-only by design.

Do not run or claim mainline runtime, mobile, true-device, voice/model/golden, endpoint, V/S/U, or UIUE merge gates.

## 10. Completion Receipt Format

Return a verdict to commander with:

```text
status: DONE / PARTIAL / BLOCKED
label: UIUE_R5_DISPATCH_4_UIUE_CONSUMER_MAPPING
can_return_to_commander: yes/no
repo_truth:
  UIUE branch:
  UIUE start_head:
  UIUE final_head:
  UIUE dirty before:
  UIUE dirty after:
  main reference branch/head/status:
owned_paths:
preserve_unowned:
no_touch_confirmed:
mapping_table:
  surface | mainline_name_or_semantics | UIUE_consumer_path | proof_path | proof_class | status | residual
row_disposition_table:
  row_id | before | after | disposition | proof_path | proof_class | validation | remaining_gap_or_next_owner
deferred_gates:
  C005:
  C018:
  C052:
  C061:
K1_status:
  untouched_spike_ledger: yes/no
validation:
  command | result | proof_class
subagent_codex_audit_primary:
  status:
  findings_P0_P1:
  disposition:
  evidence:
supplementary_audit_if_any:
  status:
  audit_type:
  findings_P0_P1:
  disposition:
  run_dir:
  output:
non_claims:
residual_risks:
can_return_for_commander_reconcile: yes/no
next_step:
```

`can_return_for_commander_reconcile` may be `yes` only if UIUE consumes only stable mainline names/semantics, all deferred gates remain deferred, K1 remains untouched, local validation passes, and Codex subagent primary audit has no unresolved P0/P1. It still does not mean runtime-ready, UIUE merge, mobile/true-device, or R5 complete.

## 11. Stop Conditions

Stop and report `PARTIAL` or `BLOCKED` if:

1. The task requires mainline code changes, full runtime backend loop, real model execution, C5/C6, voice, golden, mobile, true-device, endpoint, or production force-state behavior.
2. UIUE needs a shared field, enum, proof class, adapter behavior, or runtime payload field absent from mainline evidence.
3. UIUE would parse Chinese display copy to infer machine state.
4. UIUE would consume `C005`, `C018`, `C052`, or `C061` as implemented behavior instead of deferred gates.
5. K1 rows are promoted into implementation without bounded spike receipts.
6. Codex subagent reports unresolved P0/P1, is unavailable, or returns no evidence.
7. Dirty tree ownership cannot be separated safely.
8. Any wording claims R5 complete, runtime-ready, mobile, true_device, voice-ready, model-ready, golden-ready, endpoint-ready, UIUE merge, V-PASS, S-PASS, U-PASS, or A-2 complete.

---
status: DISPATCH_READY
artifact_kind: implementation_dispatch
created_at: 2026-06-28
from: UIUE R5 commander
to: UIUE Codex window
target_thread: 019f0c69-7c7d-7173-a67b-758e786164b1
priority: P0
dispatch_id: R5-D3-shared-proof-governance
proof_class_ceiling: docs/local + receipt_consistency + local_static
source_map:
  - /Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md
  - /Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dual-branch-coordination-spec.md
  - /Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md
  - /Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/final-grill-matrix.md
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

# Dispatch 3 - UIUE R5 Shared Proof-Governance Hardening

## 0. Route Metadata

- **TO**: UIUE Codex window `019f0c69-7c7d-7173-a67b-758e786164b1`
- **FROM**: UIUE R5 commander
- **MODE**: shared proof-governance hardening + docs/local checker/receipt work
- **PRIORITY**: P0, because this is the guard against false runtime/mobile/V/S/U proof inflation before commander reconcile.
- **One-line deliverable**: build or update the UIUE R5 proof-governance ledger/checker/receipt surface so shared proof claims, validation gates, dirty split, stale HEAD, non-claims, and screenshot no-promotion are machine-checkable or receipt-checkable across UIUE and main.
- **Proof ceiling**: `docs/local + receipt_consistency + local_static`. This dispatch cannot produce runtime/mobile/true_device/live/V/S/U proof.
- **Dispatch class**: governance/checker dispatch with Codex native subagent P0/P1 audit as the required primary audit gate. Hermes is not the audit subject for this dispatch.

## 1. Cold-Start Context

The current state:

- UIUE STEP0 froze the R5 baseline at commit `926dec8311c63a7b51cd1a1a5f633009e25cf7d2`.
- Main Dispatch 1 and Dispatch 2 are accepted for local/unit contract consumption only.
- UIUE Dispatch 4 is accepted as `DONE / PASS_WITH_NOTES`; UIUE can consume stable mainline names/semantics under local/unit proof cap.
- Deferred gates remain deferred: `C005`, `C018`, `C052`, `C061`.
- K1 remains spike-before-implementation only.

This Dispatch 3 must prevent proof inflation and close shared governance rows before commander reconcile. It is not a runtime implementation dispatch.

## 2. Authority And Source Truth

Read these first, in order:

1. `/Users/wanglei/workspace/MAformac-uiue/AGENTS.md` if present, then nearest UIUE project guidance.
2. `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
3. `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dual-branch-coordination-spec.md`
4. `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md`
5. `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/final-grill-matrix.md`
6. `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift`
7. `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-mainline-terminal-snapshot-adapter-dispatch-1-2026-06-28.md`
8. `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-mainline-contract-test-hardening-dispatch-2-2026-06-28.md`
9. `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-uiue-consumer-mapping-dispatch-4-2026-06-28.md`

Authority order:

1. mainline Swift/OpenSpec/receipts for shared names and proof caps
2. UIUE local checker/receipt for UIUE consumption and governance
3. this dispatch
4. older grill rows as provenance only

UIUE must not convert governance wording into new mainline shared fields.

## 3. Mandatory Preflight

Run and record:

```bash
cd /Users/wanglei/workspace/MAformac-uiue
pwd
git branch --show-current
git rev-parse HEAD
git status --short --branch
git diff --check
openspec validate ui-presentation --strict
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

- `owned`: UIUE proof-governance files, checker/tests, and receipt files this dispatch touches.
- `preserve_unowned`: existing dispatch/map/D4 owned files not owned by this dispatch.
- `no_touch`: main repo except read-only probe; raw customer/source material; runtime/model/voice/golden/mobile/true-device implementation.

Do not stage, commit, push, or use `git add .` unless the user separately authorizes git integration. If staging later becomes authorized, use exact pathspecs only.

## 4. Rows In Scope

Primary P0:

| Row | Source question | Required disposition |
|---|---|---|
| `C106` | screenshot anchor no-promotion machine guard. | Must become covered by checker/receipt rule or explicitly blocked with exact missing authority. Prose-only warning is not enough. |

S1 rows that must remain guarded:

| Row | Rule |
|---|---|
| `C001` | UIUE consumes snapshots/events only; no free raw store mutation. |
| `C008` | scope display reads structured fields; UI/TTS must not infer scope from Chinese display copy. |
| `C025` | UIUE screenshot/simulator proof cannot promote to runtime/mobile/V-PASS. |
| `C036` | simulator is not true-device proof. |
| `C050` | OpenSpec-vs-UIUE landing matrix must stay explicit. |
| `C189` | C5/C6/golden/voice lanes remain independent proof lanes. |

S2 rows to consume in this dispatch:

| Row | Required proof-governance hardening |
|---|---|
| `C046` | Receipt schema includes command/device-or-surface/proof/touched/residual. |
| `C047` | Merge-readiness wording is `contract_aligned`, not merged. |
| `C048` | Reviewer/receipt must report live HEAD, not stale SHA. |
| `C049` | Unresolved P0/P1 carry-forward enters next closeout. |
| `C107` | R5 receipt includes non-claims checkbox. |
| `C108` | Validation gates derive from touched paths; rewrite into a falsifiable rule. |
| `C110` | UIUE and main dirty status are recorded separately; no mixed commits. |
| `C111` | UIUE and main OpenSpec strict validations are separate commands. |
| `C179` | Proof enum is translated to UIUE-facing wording; raw enum value is not passed as user-facing proof. |
| `C193` | L0/L1/L2/L3 visual proof binds to proof-class cap; L1/L2 do not close L3. |
| `C195` | R5 closeout hard gate records main dirty residual and UIUE status separately. |
| `C196` | Validation gate is explicit per docs-only vs Swift/UI touched paths; rewrite into a falsifiable rule. |

Out of scope unless needed as residual notes:

- S2 rows not listed above.
- M3 merge-only rows as standalone implementation tasks.
- H1 human/product ledger as implementation.
- K1 spike rows as implementation.

## 5. Task Shape

Create the smallest useful UIUE proof-governance surface. Acceptable forms:

- A local static checker plus tests.
- A receipt schema plus tests.
- A governance ledger with a small script/test that checks stale claims and required fields.
- A docs-only receipt only if it is paired with a falsifiable static grep/checker and Codex subagent audit agrees no P0/P1 remains.

Minimum required behavior:

1. Stale-claim grep/checker fails on runtime/mobile/true_device/voice/model/golden/endpoint/UIUE merge/V/S/U/A-2 promotion in owned R5 receipts unless the phrase appears in a non-claim/deny-list context.
2. Screenshot/simulator anchors cannot be classified as runtime/mobile/true-device proof.
3. Receipt schema requires command, surface/device or explicit non-device marker, proof class, touched paths, dirty split, residual risks, and live HEAD.
4. Validation gates are computed or recorded from touched paths: docs-only, Swift/UIUE code, mainline read-only reference, OpenSpec touched, simulator/runtime touched.
5. Proof enum/raw proof tokens must be mapped to UIUE-facing proof wording; no raw readiness claim is displayed as a pass.
6. UIUE/main dirty and OpenSpec validation are recorded separately.
7. Unresolved P0/P1 carry-forward is explicit.
8. `contract_aligned` / `consumer_mapping_ready` must not be written as `merged`, `runtime-ready`, or `R5 complete`.

## 6. Writable And No-Touch Paths

Writable in `/Users/wanglei/workspace/MAformac-uiue` only:

- new or existing UIUE proof-governance checker/schema/test files under current project patterns.
- `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/` or nearest existing receipt directory for Dispatch 3 receipt.
- `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md` only for dispatch log/intake status if needed.
- `/Users/wanglei/workspace/MAformac-uiue/Reports/` for ignored audit artifacts if needed.

No-touch:

- `/Users/wanglei/workspace/MAformac/` except read-only reference.
- raw customer/source materials.
- mainline bridge schemas, enums, proof classes, adapter code, runtime payload definitions.
- C5/C6/model/voice/golden/mobile/true-device/endpoint implementation.

## 7. Audit Requirement

Codex native subagent is the required primary audit gate.

After local validation, run a Codex native subagent P0/P1 audit with:

- this dispatch path
- changed files
- `git diff --stat`
- relevant diff or patch
- validation output
- row disposition table
- stale-claim grep/checker output
- exact ask: identify P0/P1 only, especially proof-promotion holes, screenshot no-promotion gaps, missing receipt fields, stale HEAD, mixed dirty status, validation gate mismatch, raw enum display, K1/M3/H1 promotion, and non-claim wording failures.

If the Codex subagent audit is unavailable, returns no evidence, or reports unresolved P0/P1, final status must be `PARTIAL`, not DONE.

Hermes/GLM is not the audit subject for this dispatch and is not a hard gate.

## 8. Required Validation

Minimum validation:

```bash
cd /Users/wanglei/workspace/MAformac-uiue
git diff --check
openspec validate ui-presentation --strict
```

Also run the smallest focused tests/checkers for files you touch. If you add a checker script, run it and include command output in the receipt. If you touch Swift code/tests, run focused `swift test --filter ...`.

For main read-only reference:

```bash
cd /Users/wanglei/workspace/MAformac
openspec validate define-runtime-presentation-bridge --strict
```

Do not run or claim runtime/mobile/true-device/voice/model/golden/endpoint/V/S/U/UIUE merge gates.

## 9. Completion Receipt Format

Return a verdict to commander with:

```text
status: DONE / PARTIAL / BLOCKED
label: UIUE_R5_DISPATCH_3_SHARED_PROOF_GOVERNANCE
can_return_to_commander: yes/no
can_open_commander_reconcile: yes/no
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
governance_surface:
  checker_or_schema_paths:
  receipt_paths:
row_disposition_table:
  row_id | before | after | disposition | proof_path | proof_class | validation | remaining_gap_or_next_owner
proof_promotion_checks:
  screenshot_no_promotion:
  forbidden_claim_grep:
  proof_enum_translation:
  receipt_schema_required_fields:
  validation_gate_by_touched_paths:
  dual_repo_dirty_split:
  live_head_required:
K1_M3_H1_status:
  K1:
  M3:
  H1:
validation:
  command | result | proof_class
subagent_codex_audit_primary:
  status:
  agent_id:
  findings_P0_P1:
  disposition:
  evidence:
supplementary_audit_if_any:
  status:
  audit_type:
  findings_P0_P1:
  disposition:
non_claims:
residual_risks:
next_step_for_commander:
```

`can_open_commander_reconcile` may be `yes` only if `C106` and listed S2 rows are covered or explicitly deferred/non-claim with no unresolved P0/P1, Codex subagent primary audit has no unresolved P0/P1, stale-claim/proof-promotion checks pass, and proof caps remain docs/local/static only.

## 10. Stop Conditions

Stop and report `PARTIAL` or `BLOCKED` if:

1. The task requires mainline code changes, runtime backend loop, real model execution, C5/C6, voice, golden, mobile, true-device, endpoint, or production force-state behavior.
2. A checker would need new shared mainline fields or proof enum values absent from mainline evidence.
3. Screenshot/simulator proof can still promote to runtime/mobile/true-device/V/S/U after your changes.
4. Any receipt can omit live HEAD, proof class, touched paths, dirty split, validation commands, or residual risks.
5. `contract_aligned` or `consumer_mapping_ready` is promoted to merged/runtime-ready/R5 complete.
6. K1, M3, or H1 rows are promoted into implementation.
7. Codex subagent audit is unavailable, returns no evidence, or reports unresolved P0/P1.
8. Dirty tree ownership cannot be separated safely.
9. Any wording claims R5 complete, runtime-ready, mobile, true_device, voice-ready, model-ready, golden-ready, endpoint-ready, UIUE merge, V-PASS, S-PASS, U-PASS, or A-2 complete.

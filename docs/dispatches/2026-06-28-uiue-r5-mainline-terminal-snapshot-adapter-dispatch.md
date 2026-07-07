---
status: DISPATCH_READY
artifact_kind: implementation_dispatch
created_at: 2026-06-28
from: UIUE R5 commander
to: mainline Codex window
target_thread: 019f0c69-972a-7f61-9515-3a101d5c0131
priority: P0
proof_class_ceiling: local/unit/integration
source_map:
  - /Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md
  - /Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dual-branch-coordination-spec.md
  - /Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md
  - /Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/
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

# Dispatch - UIUE R5 Mainline Terminal Snapshot Adapter Behavior Proof

## 0. Route Metadata

- **TO**: mainline Codex window `019f0c69-972a-7f61-9515-3a101d5c0131`
- **FROM**: UIUE R5 commander
- **MODE**: bounded mainline implementation + audit loop
- **PRIORITY**: P0, because UIUE cannot safely consume terminal behavior until mainline proves adapter semantics.
- **One-line deliverable**: implement or explicitly prove the smallest mainline terminal snapshot adapter behavior slice for `C012`, `C060`, `C017`, `C022`, with local/unit tests and audit receipts; do not claim runtime readiness.
- **Proof ceiling**: `local/unit/integration`. This dispatch cannot produce runtime/mobile/true_device/live/V/S/U proof.
- **Dispatch class**: implementation dispatch with mandatory grill burndown and cross-vendor audit.

## 1. Cold-Start Context

MAformac is a pure-device macOS/iOS offline vehicle-control demo assistant, not production vehicle control. The current bridge work is about `Runtime -> Presentation` contracts so UIUE can consume stable mainline DTO/result/proof names without inventing shared fields.

UIUE STEP0 froze the R5 input baseline at:

- `/Users/wanglei/workspace/MAformac-uiue`
- commit `926dec8311c63a7b51cd1a1a5f633009e25cf7d2`
- commit title: `docs(uiue): freeze r5 baseline for calibration`

Main STEP0 calibrated M1/S1/M2 and found this first implementation slice:

- `C012` remaining: guard denial must project into a presentation-safe refusal snapshot.
- `C060` remaining: adapter thrown error must still emit terminal snapshot, not silent failure.
- `C017` remaining: partial accept/refuse needs composite terminal snapshot/readback behavior.
- `C022` remaining: cancel/interruption/timeout/backgrounding need terminal snapshots.

This is **not DTO-only work**. Existing mainline DTOs and tests prove shape and proof caps, but phase1 already records that thrown C3 errors still need future adapter classification at `/Users/wanglei/workspace/MAformac/docs/project/phase0/runtime-presentation-bridge-phase1-grill-2026-06-28.md:106`.

## 2. Authority And Source Truth

Read these first, in order:

1. `/Users/wanglei/workspace/MAformac/AGENTS.md`
2. `/Users/wanglei/workspace/MAformac/CLAUDE.md`
3. `/Users/wanglei/workspace/MAformac/docs/CURRENT.md`
4. `/Users/wanglei/workspace/MAformac/docs/README.md`
5. `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/`
6. `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift`
7. `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift`
8. `/Users/wanglei/workspace/MAformac/Core/Execution/C3ExecutionPipeline.swift`
9. `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
10. `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md`

Authority order:

1. mainline OpenSpec + mainline Swift carrier + mainline tests/receipts
2. this dispatch
3. UIUE R5 coordination docs as provenance/coordination only

UIUE docs are not mainline shared-field authority.

## 3. Mandatory Preflight

Run and record:

```bash
cd /Users/wanglei/workspace/MAformac
pwd
git branch --show-current
git rev-parse HEAD
git status --short --branch
openspec validate define-runtime-presentation-bridge --strict
git diff --check
```

Also confirm UIUE frozen baseline without modifying UIUE:

```bash
cd /Users/wanglei/workspace/MAformac-uiue
git rev-parse HEAD
git status --short --branch
git log -1 --oneline
```

Before edits, classify dirty state:

- `owned`: files this dispatch will touch.
- `preserve_unowned`: existing dirty files not owned by this dispatch.
- `no_touch`: UIUE repo, unrelated main docs/config/tooling, raw source material.

Do not use `git add .`.

## 4. Grill / Burndown Source Truth

| Source | Artifact role | Scope | IDs | Count / rows | Authority status |
|---|---|---|---|---:|---|
| `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md:126-137` | frozen R5 burndown source | M1 | `C012`, `C060`, `C105` | 3 | active input |
| `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md:156-186` | frozen R5 burndown source | M2 | includes `C017`, `C022` | 22 | active input |
| `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md:231-365` | merge-only fixture/doc source | M3 | includes terminal fixture rows `C064-C072`, `C085`, `C177` | 52 | provenance, not standalone implementation |
| `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md:390-406` | spike source | K1 | `C082`, `C083`, `C096`, `C117`, `C182`, `C197`, `C207`, `C208` | 8 | spike ledger only |
| `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md:63-72` | commander calibration map | row migration | `C105`, `C017`, `C022`, `K1` | 4 delta rows | dispatch decomposition authority |

This dispatch covers implementation only for `C012`, `C060`, `C017`, `C022`.

Do not promote K1 rows into this implementation. K1 remains a spike-before-implementation ledger. If a K1 issue blocks terminal snapshot design, stop and report the exact spike needed instead of implementing it.

## 5. Task

Implement the smallest mainline terminal snapshot adapter behavior proof that can pass local/unit validation for these four rows:

| Row | Required behavior | Minimum acceptable proof |
|---|---|---|
| `C012` | Guard denial projects into presentation-safe refusal snapshot. | Unit test or fixture shows a guard/safety/policy denial becomes a terminal `PresentationSnapshot` with safe refusal outcome, no raw model/store leak. |
| `C060` | Thrown error still emits terminal runtime-error snapshot, not silent failure. | Unit test or fixture shows a thrown/failed C3-like path maps to terminal runtime-error snapshot with reason and trace identity. |
| `C017` | Partial accept/refuse creates mixed card/readback snapshot. | Unit test or fixture shows accepted/refused presentation semantics and composite readback/card state; if full cell-level payload is not yet owned, encode explicit residual and do not fake coverage. |
| `C022` | Cancel/interruption/timeout/backgrounding produce terminal snapshots. | Unit tests or fixtures cover at least cancel, interruption, and timeout/backgrounding as terminal outcomes, or explain why a subcase is blocked and keep status partial. |

Each terminal snapshot proof must include:

- `isTerminal == true`
- `traceID`
- `runtimeOutcome.result`
- `proofClass`
- reason / `scopeFailureReason` / readback / card semantics where applicable
- no raw model output
- no training receipt
- no raw runtime store reference

DTO-only edits cannot satisfy this dispatch. Adding enum cases or Codable tests alone is insufficient.

Expected implementation shape is intentionally not over-prescribed. A small mainline adapter/factory layer plus focused unit fixtures is acceptable if it proves behavior mapping. A full runtime backend loop is out of scope.

## 6. Writable And No-Touch Paths

Writable in `/Users/wanglei/workspace/MAformac` only:

- `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift`
- `/Users/wanglei/workspace/MAformac/Core/Presentation/`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/`
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/`
- `/Users/wanglei/workspace/MAformac/Reports/` for receipts if needed

No-touch:

- `/Users/wanglei/workspace/MAformac-uiue/` except read-only reference.
- raw customer/source materials.
- unrelated main dirty files unless they are explicitly classified as owned by this dispatch.
- C5/C6/model/voice/golden/mobile/true-device implementation.

## 7. Dual-Branch Divergence Rules

Mainline owns:

- shared runtime result enum
- terminal snapshot schema
- proof class names and display caps
- `ScopeOrigin` disposition
- adapter behavior proof

UIUE owns:

- local/simulator presentation consumer mapping
- docs/local matrix and product wording
- visual/layout/a11y presentation behavior after mainline names are stable

UIUE must not:

- invent shared fields
- parse mainline runtime payload before mainline adapter contract exists
- write shared adapter code
- promote local/simulator proof into runtime/mainline proof

This dispatch must preserve the split.

## 8. Harness And Metacognition Requirements

Apply these execution rules:

1. **Truth-first start**: repo, branch, HEAD, dirty, nearest authority, and validation commands before edits.
2. **Read before edit**: quote or cite the exact file:line for every load-bearing claim.
3. **No fake green**: if a subcase lacks proof, mark `PARTIAL`, not DONE.
4. **Owned/unowned split**: do not mix preserved main dirty residual into this dispatch.
5. **Pathspec only**: if staging later becomes authorized, use explicit pathspecs; never `git add .`.
6. **Proof class discipline**: local/unit/integration proof cannot become runtime/mobile/true-device/live/V/S/U proof.
7. **Grill burndown required**: closeout must include before/after status for `C012`, `C060`, `C017`, `C022`, and mention K1 as untouched spike ledger.
8. **Same-class risk map**: if one terminal outcome path is fixed, audit the same-class paths for stale async mutation, missing trace identity, wrong proof class, and raw output leak.
9. **Subagent audit required**: after local implementation and before final verdict, run a Codex native subagent audit scoped to P0/P1 risks in this dispatch. If the subagent audit is unavailable, does not return evidence, or returns any unresolved P0/P1, final status must be `PARTIAL` and `can_UIUE_consume_terminal_behavior` must be `no`.
10. **Hermes audit required**: after local implementation and local validation, run the Hermes audit loop below.

## 9. Hermes Audit Loop

After implementation and local tests pass, run a GLM/Hermes audit focused on P0/P1. Limit the total audit/fix/rerun loop to **20 minutes wall clock**. Do not rush the initial implementation; the 20 minute cap is for the Hermes review loop after local validation.

Suggested command shape from `/Users/wanglei/workspace/MAformac`:

```bash
mkdir -p Reports/r5-terminal-snapshot-adapter-$(date +%Y%m%dT%H%M%S)
/Users/wanglei/.codex/skills/hermes-cli-glm52-code/scripts/hermes_glm52_code.py run \
  --prompt-file /absolute/path/to/hermes-r5-terminal-snapshot-audit-prompt.md \
  --timeout 1200
```

Hermes audit prompt must include:

- this dispatch path
- files changed
- `git diff --stat`
- relevant diff or patch
- validation output
- non-claims
- exact ask: identify P0/P1 only, especially DTO-only fake pass, missing terminality, raw model/store leak, proof promotion, dual-branch shared-field drift, and dirty/staging risk.

Loop rule:

- If Hermes reports P0/P1: fix only in scope, rerun focused validation, rerun Hermes if time remains.
- Continue until no P0/P1 or 20 minutes expires.
- If 20 minutes expires with any P0/P1 still open, final status must be `PARTIAL`, not DONE.
- P2/P3 may be carried as residual risk with owner/trigger.

## 10. Required Validation

Minimum validation:

```bash
cd /Users/wanglei/workspace/MAformac
openspec validate define-runtime-presentation-bridge --strict
git diff --check
swift test --filter RuntimePresentationBridgeTests
```

If touched surface expands, add the smallest relevant tests. Do not run C5/C6/model/voice/golden/mobile/true-device gates under this dispatch.

## 11. Completion Receipt Format

Return a verdict to the commander with:

```text
status: DONE / PARTIAL / BLOCKED
repo_truth:
  main branch:
  main HEAD:
  dirty before:
  dirty after:
owned_paths:
preserve_unowned:
no_touch_confirmed:
implemented_behavior:
  C012:
  C060:
  C017:
  C022:
grill_burndown:
  row_id | before | after | proof_path | proof_class | validation | remaining_gap
K1_status:
  untouched_spike_ledger: yes/no
validation:
  command | result | proof_class
subagent_codex_audit:
  status:
  findings_P0_P1:
  disposition:
hermes_audit:
  status:
  elapsed_minutes:
  findings_P0_P1:
  disposition:
non_claims:
residual_risks:
can_UIUE_consume_terminal_behavior: yes/no
next_step:
```

`can_UIUE_consume_terminal_behavior` may be `yes` only if `C012`, `C060`, `C017`, and `C022` are all proven by local/unit/integration evidence, Codex subagent audit returns evidence with no unresolved P0/P1, and Hermes audit returns no unresolved P0/P1. It still does not mean runtime-ready or UIUE merge.

## 12. Stop Conditions

Stop and report `PARTIAL` or `BLOCKED` if:

1. The task requires full runtime backend loop, real model execution, C5/C6, voice, golden, mobile, true-device, endpoint, or UIUE code changes.
2. A needed terminal outcome cannot be represented without inventing a new shared field not covered by mainline authority.
3. Implementation would require `ScopeOrigin.missing` or equivalent Core enum expansion.
4. The fix only adds DTO/Codable tests but does not prove adapter behavior.
5. Hermes or Codex subagent reports unresolved P0/P1 and time expires, or Codex subagent audit is unavailable / returns no evidence.
6. Dirty tree ownership cannot be separated safely.
7. Any wording tries to claim R5 complete, runtime-ready, mobile, true_device, voice-ready, model-ready, golden-ready, endpoint-ready, UIUE merge, V-PASS, S-PASS, U-PASS, or A-2 complete.

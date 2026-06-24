---
status: approved_for_human_propose_review_not_apply
artifact_kind: rebuild_c6_documentation_absorption_closeout
authority: closeout_record_not_ssot
proof_class:
  - local
  - local_static_teardown
closed_on: "2026-06-24"
change: rebuild-c6-four-layer-bench
retire_trigger: "Retire after rebuild-c6-four-layer-bench is accepted, superseded, or archived with a newer closeout."
expires: "2026-07-15"
---

# Rebuild-C6 Documentation Absorption Closeout

## Verdict

`rebuild-c6-four-layer-bench` is approved for human OpenSpec propose review.

This closeout covers documentation absorption only. It does not apply the change, implement Swift, regenerate C6 JSONL, edit Qwen tool format, run C6 acceptance, run a model, recalibrate D-domain base, start C5 training, execute golden-run, run voice, claim endpoint readiness, merge UIUE, or close R-L17.

## Closed Scope

- Q2/Q3/Q4 grill decisions are absorbed into the OpenSpec carrier:
  - `openspec/changes/rebuild-c6-four-layer-bench/proposal.md`
  - `openspec/changes/rebuild-c6-four-layer-bench/design.md`
  - `openspec/changes/rebuild-c6-four-layer-bench/tasks.md`
  - `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md`
- Q4.15 row-level pointers exist:
  - `docs/project/phase0/paper-to-skill-gate-absorption-ledger-2026-06-24.md#Row-Level-Absorption-Pointers-Q4-15`
  - `docs/project/phase0/rebuild-c6-precode-grill-ledger-2026-06-24.md#Row-Level-Absorption-Pointers-Q4-15`
- Human review approved documentation closeout:
  - `docs/project/phase0/paper-to-skill-gate-absorption-ledger-2026-06-24.md#Human-Review-Result-2026-06-24`
  - `docs/project/phase0/rebuild-c6-precode-grill-ledger-2026-06-24.md#Human-Review-Result-2026-06-24`
- M1/M2 human-review mild issues are resolved:
  - M1: no `***` separator remains in `proposal.md`.
  - M2: `tasks.md` item 1.5 makes BehaviorClass SSOT naming/reconciliation a construction precondition before selector, threshold, active anchor, or apply no-effect freeze.

## Current Open Items

| Item | Status | Blocking effect |
|---|---|---|
| R-L17 route deframing | pending / unsigned | Blocks rebuild-C6 construction apply, retrain-C5, C6 acceptance, and readiness claims. |
| R1-R7 evidence completion | pending | Must be filled with first-hand evidence before R7 route signoff. |
| Heterogeneous deframing judge | missing | Required for R-L17 G3; same-vendor Codex/Claude checks do not count. |
| Candidate signoff | unsigned | Required before candidate comparison, C6 acceptance, candidate promotion, golden-run, or readiness claims. |
| Q2 C5/training-only remnants | live under `retrain-c5-lora-d-domain` | Q2.1/Q2.4 retain `remaining_owner` and are not fully retired by rebuild-C6. |
| M3 ToolRAG future carrier | non-blocking | Add owner only when a spike carrier is proposed. |

## UIUE Phase4A Impact Check

Source checked: `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-24-phase4a-cc-window-dispatch.md`.

Verdict: no current blocker for this closeout or R-L17 route-prep.

Reasoning:

- Phase4A is explicitly scoped to UIUE implementation in `/Users/wanglei/workspace/MAformac-uiue`.
- Its allowed write area is `App/`, `Core/Presentation/`, `openspec/changes/ui-presentation/`, and `docs/`.
- It explicitly forbids touching `Core/State/`, `contracts/`, and `generated/`.
- Its subject is the 10-family card scope presentation summary layer, not C5 data, C6 denominators, behavior-class taxonomy, apply diagnostics, or rebuild-C6 OpenSpec topology.
- Its validation route is UIUE-specific: Swift/UI tests, pre-commit display-catalog enforcement, screenshots, PR, and GPT Pro audit. That does not certify or block rebuild-C6 documentation absorption.

Boundary:

- Do not cite UIUE Phase4A file:line evidence as current mainline truth without rechecking live UIUE branch/PR state.
- If Phase4A later changes shared state/C3-C6 contracts, default-scope metadata, or golden IDs, reopen the intersection review before rebuild-C6 implementation.

## Verification Ledger

Commands run on 2026-06-24:

```bash
openspec status --change rebuild-c6-four-layer-bench
openspec validate rebuild-c6-four-layer-bench --strict
openspec validate --all --strict
git diff --check
```

Results:

- `openspec status --change rebuild-c6-four-layer-bench`: pass; 4/4 artifacts complete (`proposal`, `design`, `specs`, `tasks`).
- `openspec validate rebuild-c6-four-layer-bench --strict`: pass.
- `openspec validate --all --strict`: pass; 15 passed, 0 failed.
- `git diff --check`: pass; no output.

## Next Authorized Action

Prepare R-L17 route deframing evidence. This is still decision work, not code.

Do not start rebuild-C6 construction apply until R-L17 route signoff and OpenSpec propose acceptance are both explicit.

## Forbidden Claims

Do not describe this closeout as:

- R-L17 signed or closed.
- rebuild-C6 applied.
- C6 acceptance-ready.
- C5 retrain-ready.
- candidate comparison authorized.
- demo-golden-ready.
- voice-ready.
- endpoint-ready.
- UIUE merged.
- V-PASS, S-PASS, or U-PASS.

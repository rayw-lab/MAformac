# Phase 0 Grill Acceptance Archive

## Status

- Accepted by user: 2026-06-24
- Decision: all 24 final Phase 0 grill candidates are accepted.
- Scope: this is a decision archive for route control, not an OpenSpec archive and not permission to start implementation/training.
- Source final synthesis: `docs/loop-competition/2026-06-24-phase0-grill/final-list.md`
- Source ledger: `docs/loop-competition/2026-06-24-phase0-grill/ledger.md`

## Core Acceptance

The accepted interpretation is:

1. Keep all 24 questions as the final Phase 0 audit set.
2. Do not execute them as 24 parallel workstreams.
3. Treat C01 as merge-only under C02.
4. Treat C08 as a mainline blocker only where UIUE intersects state/C3-C6/golden contracts.
5. Treat C11-C12 numeric values as recipe hypotheses until spike evidence.
6. Keep A2 deferred boundaries: no training, no real model-quality evaluation, no voice, no demo-golden-run execution before the C5/C6 contract path is green.

## Recalled Phase 0

This acceptance closes the decision-grill part of the previously recommended Phase 0:

| Previous Phase 0 item | Accepted candidate coverage | Accepted handling |
|---|---|---|
| Confirm `a2-post-roadmap` identity as research / pre-propose checklist, not SSOT | C01, C02 | Accepted. `a2-post-roadmap` is a decision pack / pre-propose checklist; authority matrix owns source roles. |
| Clear non-UIUE P0 grill debt: Q04, Q08, Q12, Q16-Q18, Q20-Q21 | C03, C04, C05, C06, C07 | Accepted. Scope, archived specs, Pocock stage, field/enums, and decision-status manifest are Phase 0 controls. |
| Write post-roadmap gates into OpenSpec proposal/tasks | C09-C18, C19-C24 | Accepted. Gates become OpenSpec-ready tasks/manifests before retrain/rebuild execution. |
| Clarify 4-class vs 5-class failure/status handling | C09, C10, C11, C12, C24 | Accepted. Failure/error-recovery is explicit cut-or-seed; `already_state` is independent; status vocabulary forbids pass-label laundering. |
| Keep UIUE outside mainline blockers unless state/C3-C6/golden contracts are touched | C08, C21, C22 | Accepted. UIUE visual work remains branch-local; state/golden contract interfaces remain mainline. |

## Accepted P0 Spine

| Group | Candidates | Physical landing |
|---|---|---|
| Authority and sequencing | C02, C05, C07 | Authority matrix, Pocock stage matrix, decision-status manifest |
| Scope and spec truth | C03, C04 | Full/demo artifact matrix, archived-spec disposition table, generated drift proof |
| Shared vocabulary | C06, C24 | Runtime/outcome enum manifest and directed status vocabulary |
| C5/C6 anti-fake-green | C13, C14, C17, C18 | Held-out axes, mid-training gate, D-domain base anchor, four-layer C6 scoring |
| Endpoint and runtime safety | C19, C20 | Endpoint evidence boundary, parser/repair/whitelist/failure enum policy |
| State/golden contract boundary | C21, C22 | Tool-state-card-patch map, demo-golden-run entry conditions |

## Accepted Materialization Guardrails

These guardrails incorporate the later dialectical check of the 10 highest-risk items:

- C02: authority matrix is valid, but should live under docs/project or grill governance, not runtime `contracts/`.
- C03: A2 already has generated-domain drift gates; the missing piece is cross-scope `demo subset of full` proof plus an artifact matrix.
- C04: spec disposition must scan all `openspec/specs/*/spec.md` and anchor to Requirement/Scenario level.
- C05: keep `forbidden_next_action`; do not add PR-template ceremony.
- C07: first pass is a touched-decision manifest, not a new dependency-graph framework.
- C14: mid-training gate needs `continue | human_pause | early_stop | blocked` and a receipt actor/decision/timestamp.
- C17: old 10/23 remains historical failure evidence only; it is not a D-domain candidate hard gate.
- C18: C6 scoring should use primary layer plus optional secondary tags; do not erase multi-label risk.
- C21: mainline owns `tool -> IR -> state_cell -> card -> patch`; UIUE consumes stable IDs.
- C24: status implications are directed, and verification should target active closeout/receipt/handoff docs, not historical snapshots.

## Next Action Boundary

The next mainline task is not retrain. It is to convert accepted Phase 0 decisions into OpenSpec-ready manifests/tasks:

1. C02/C03/C04/C05/C06/C07/C24 first, because they prevent wrong authority, wrong scope, stale spec behavior, wrong stage, enum drift, and pass-label laundering.
2. Then fold C13/C14/C17/C18/C19/C20/C21/C22 into `retrain-c5` / `rebuild-c6` / endpoint / golden-entry proposal tasks.
3. Carry C09-C12/C15/C16/C23 as required P1 task material, with numeric choices treated as hypotheses.
4. Keep `docs/c5-recovery-2026-06-22/roadmap.md` as historical/context unless it is split or bannered; it must not remain a live roadmap.

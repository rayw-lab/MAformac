---
status: active_router_only_not_ssot
artifact_kind: current_route_board
authority: router_only_not_contract
updated: 2026-06-24
last_verified_base_commit: 6763e8a
branch: main
expires_when: "default-scope apply closeout lands or this route board is superseded by a newer route board."
---

# CURRENT — MAformac Current Route Board

> This file is a traffic board, not a source of truth.
> If this file conflicts with `CLAUDE.md`, archived OpenSpec specs, accepted grill decision packs, or active OpenSpec changes, this file loses and must be updated.

## Current Phase

Post-A2 / default-scope apply authorized: Phase -1 carrier materialization is accepted for apply, but physical implementation has not started.

Current audited state:

- Main repo branch: `main`.
- Main repo base at audit: `6763e8a`.
- Active draft carrier: `openspec/changes/define-demo-default-scope/`.
- OpenSpec validation at audit: `openspec validate define-demo-default-scope --strict` pass; `openspec validate --all --strict` pass with 14 passed, 0 failed.
- Phase -1 carrier scope is documentation/OpenSpec-only and is accepted for apply. The next implementation must follow `docs/superpowers/plans/2026-06-24-default-scope-apply.md`. Same-vendor plan pre-check returned `CLEAR_WITH_FIXES`, and fixes are absorbed in the plan. This still does not authorize training, C6 acceptance, endpoint claims, demo-golden-run, voice, or UIUE merge.

## Read First

1. `CLAUDE.md` — project constitution and highest routing rule.
2. `docs/CURRENT.md` — this route board; expire and update it at phase transition.
3. `docs/README.md` — document map.
4. `docs/grill-tournament/demo-default-scope-grill-decisions-2026-06-24.md` — accepted G01-G28 default-scope decision pack.
5. `docs/project/phase0/README.md` — Phase 0 route-control index, D1-D10 state, R-L17 blockers.
6. `openspec/changes/define-demo-default-scope/` — current Phase -1 OpenSpec carrier.

## Do Now

1. Commit the Phase -1 closeout, route-board update, carrier D2 route-matrix fix, same-vendor apply-plan audit record, and apply plan together.
2. Execute `docs/superpowers/plans/2026-06-24-default-scope-apply.md` in order: C2 -> C3 -> state applier -> readback -> C5 -> C6 -> tests/gates.
3. Keep C5, C6, golden-run, and UIUE as downstream consumers of `define-demo-default-scope`. They must depend on it, not redefine default-scope semantics.
5. If `define-demo-default-scope` is accepted, execute `docs/superpowers/plans/2026-06-24-default-scope-apply.md`; keep this route board router-only and put evidence in receipts, tests, and OpenSpec closeout files.

## Do Not Do

- Do not start LoRA data generation or training.
- Do not run D-domain base recalibration or real model-quality evaluation.
- Do not claim endpoint-ready, C6-ready, demo-golden-ready, voice-ready, V-PASS, S-PASS, or U-PASS.
- Do not execute demo-golden-run or freeze golden IDs/readback/UIUE scene tags.
- Do not merge UIUE into mainline or cite UIUE file:line evidence as current mainline proof.
- Do not edit archived OpenSpec specs for default-scope behavior; add active deltas and archive later.

## Open Blockers

| Blocker | Status | Required Next Evidence |
|---|---|---|
| `define-demo-default-scope` acceptance | accepted for apply | Carrier remains active until implementation is applied and archived. |
| Physical default-scope implementation | not started | C2 `default_scope` schema/validation, C3 target resolution, state applier, readback metadata, C5/C6/golden dependencies, tests. |
| `scope.first` / `?? "全车"` / `?? "all"` debt | pre-implementation evidence only | Record grep evidence, then prove removal or explicit bridging in apply closeout. |
| Legacy UI state keys | pre-implementation evidence only | Prove scoped-key read path or one-way compatibility adapter before default-scope apply closeout. |
| C5/C2 scope candidate parity | open apply gate | C5 fallback/rendered scope candidates must derive from C2 `scope/default_scope`; no hardcoded second vocabulary. |
| Scope-origin single source | open apply gate | A typed `ScopeOrigin` or equivalent closed source must feed readback/TTS/verifier/UIUE metadata; no per-channel recomputation. |
| Apply plan audit | same-vendor pre-check absorbed | `docs/project/phase0/default-scope-apply-plan-audit-codex-2026-06-24.md`; this does not close R-L17. |
| R-L17 heterogeneous deframing | open G2-G5 | Evidence files under `docs/project/phase0/r-l17-human-review-evidence/`; same-vendor reviews remain pre-check only. |
| UIUE reconfirm | external dirty reference | Reconfirm UIUE HEAD and file evidence after mainline `default_scope` contract stabilizes. |

## UIUE Isolation Tree

UIUE remains outside mainline blockers unless state, C3-C6, readback, golden-run IDs, or default-scope presentation contracts conflict.

Current external reference at audit:

- Worktree: `/Users/wanglei/workspace/MAformac-uiue`
- Branch: `uiue/visual-ssot-state-consume`
- HEAD: `17f2af1`
- Dirty file: `openspec/changes/ui-presentation/proposal.md`
- Latest visible progress: UIUE proposal text now claims spec agreed, Phase 1b engineering preflight done, Phase 3 D7 seven-state consumption applied and audited, and Phase 4 card/default-scope consumption waiting for backend `default_scope` on main.

This is not mainline evidence. Record it as `external_reference_unverified_current_head=17f2af1` until a separate UIUE reconfirm pass reads the current files and pins the expected merge contract.

## Current Carrier Summary

`define-demo-default-scope` must own:

- C2 `default_scope` authority.
- Missing vs explicit vs fan-out scope split.
- Closed collection alias policy.
- `scope_origin`, `resolved_scope`, and presentation policy metadata.
- Legacy unscoped key disposition.
- Omitted-scope x `clarify_tag` route composition.
- Dependency gates for `retrain-c5-lora-d-domain`, `rebuild-c6-four-layer-bench`, and `define-demo-golden-run-and-voice`.

Known P1 note: older `define-demo-golden-run-and-voice` draft text still contains historical UIUE physical-anchor language. It is acceptable as an existing draft placeholder, but golden-run acceptance must either reconfirm or downgrade that language before any freeze/readiness claim.

## Retired / Historical Inputs

- `docs/roadmap-2026-06-20-from-c6-done.md` is historical provenance, not live roadmap.
- `docs/c5-recovery-2026-06-22/roadmap.md` has historical value but must not act as live roadmap unless split/bannered by Phase 0 disposition.
- `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md` is a high-weight pre-propose checklist and evidence pack, not SSOT.
- UIUE branch documents are external active work, not mainline proof until reconfirmed at the contract intersection.

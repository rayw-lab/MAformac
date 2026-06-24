---
status: active_router_only_not_ssot
artifact_kind: current_route_board
authority: router_only_not_contract
updated: 2026-06-24
last_verified_base_commit: 1143b50
branch: main
expires_when: "define-demo-default-scope is committed/pushed and either accepted for apply or superseded by a newer route board."
---

# CURRENT — MAformac Current Route Board

> This file is a traffic board, not a source of truth.
> If this file conflicts with `CLAUDE.md`, archived OpenSpec specs, accepted grill decision packs, or active OpenSpec changes, this file loses and must be updated.

## Current Phase

Post-A2 / Phase -1: materialize `define-demo-default-scope` as the standalone OpenSpec carrier for accepted G01-G28 demo default-scope decisions.

Current audited state:

- Main repo branch: `main`.
- Main repo base at audit: `1143b50`.
- Active draft carrier: `openspec/changes/define-demo-default-scope/`.
- OpenSpec validation at audit: `openspec validate define-demo-default-scope --strict` pass; `openspec validate --all --strict` pass with 14 passed, 0 failed.
- This phase is documentation/OpenSpec-only. It does not authorize implementation, training, C6 acceptance, endpoint claims, demo-golden-run, voice, or UIUE merge.

## Read First

1. `CLAUDE.md` — project constitution and highest routing rule.
2. `docs/CURRENT.md` — this route board; expire and update it at phase transition.
3. `docs/README.md` — document map.
4. `docs/grill-tournament/demo-default-scope-grill-decisions-2026-06-24.md` — accepted G01-G28 default-scope decision pack.
5. `docs/project/phase0/README.md` — Phase 0 route-control index, D1-D10 state, R-L17 blockers.
6. `openspec/changes/define-demo-default-scope/` — current Phase -1 OpenSpec carrier.

## Do Now

1. If the Phase -1 carrier and this route board are not yet committed/pushed, commit and push them first.
2. Human-review `define-demo-default-scope` as the single carrier for omitted/explicit/fan-out scope behavior.
3. Keep C5, C6, golden-run, and UIUE as downstream consumers of this carrier. They must depend on it, not redefine default-scope semantics.
4. After acceptance, start a separate apply plan for C2 `default_scope` implementation and physical evidence gates.

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
| `define-demo-default-scope` acceptance | draft carrier | OpenSpec proposal review, then apply authorization if accepted. |
| Physical default-scope implementation | not started | C2 `default_scope` schema/validation, C3 target resolution, state applier, readback metadata, C5/C6/golden dependencies, tests. |
| `scope.first` / `?? "全车"` / `?? "all"` debt | pre-implementation evidence only | Record grep evidence, then prove removal or explicit bridging in apply closeout. |
| Legacy UI state keys | pre-implementation evidence only | Prove scoped-key read path or one-way compatibility adapter before default-scope apply closeout. |
| R-L17 heterogeneous deframing | open G2-G5 | Evidence files under `docs/project/phase0/r-l17-human-review-evidence/`; same-vendor reviews remain pre-check only. |
| UIUE reconfirm | external dirty reference | Reconfirm UIUE HEAD and file evidence after mainline `default_scope` contract stabilizes. |

## UIUE Isolation Tree

UIUE remains outside mainline blockers unless state, C3-C6, readback, golden-run IDs, or default-scope presentation contracts conflict.

Current external reference at audit:

- Worktree: `/Users/wanglei/workspace/MAformac-uiue`
- Branch: `uiue/visual-ssot-state-consume`
- HEAD: `34044e1`
- Dirty file: `openspec/changes/ui-presentation/proposal.md`
- Latest visible progress: UIUE proposal text now claims spec agreed, Phase 1b engineering preflight done, Phase 3 D7 seven-state consumption applied and audited, and Phase 4 card/default-scope consumption waiting for backend `default_scope` on main.

This is not mainline evidence. Record it as `external_reference_unverified_current_head=34044e1` until a separate UIUE reconfirm pass reads the current files and pins the expected merge contract.

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

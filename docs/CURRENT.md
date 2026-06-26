---
status: active_router_only_not_ssot
artifact_kind: current_route_board
authority: router_only_not_contract
updated: 2026-06-26
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
4. `Tools/agent-platform-plugin-refs/README.md` — local iOS/macOS build plugin references for SwiftUI, Liquid Glass, simulator, performance, and packaging work.
5. `.xcodebuildmcp/README.md` — this worktree's persisted Codex `build-ios-apps` default profile and simulator assignment.
6. `docs/grill-tournament/demo-default-scope-grill-decisions-2026-06-24.md` — accepted G01-G28 default-scope decision pack.
7. `docs/project/phase0/README.md` — Phase 0 route-control index, D1-D10 state, R-L17 blockers.
8. `openspec/changes/define-demo-default-scope/` — current Phase -1 OpenSpec carrier.

Local iOS build truth:

- This worktree's persisted Codex `build-ios-apps` profile is `ios`.
- Default iOS scheme is `MAformacIOS`.
- Dedicated simulator is `iPhone 17 Pro Max`.
- Main worktree must keep a different simulator because both worktrees share `lab.rayw.MAformac.ios`.

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

Current UIUE-lane state (2026-06-26, updated):

- Worktree: `/Users/wanglei/workspace/MAformac-uiue`
- Branch: `uiue/phase4-default-scope-presentation`
- A-2 closeout anchor commit: `0350c8a` (`docs(uiue): add final a2 long-run closeout report`). Live branch head advances with documentation-only reconciliation commits; always re-probe `git rev-parse --short HEAD` before acting.
- Active UIUE work: visual/interaction grill **closed**; **A-2 (step2) implementation plan v3** (`docs/superpowers/plans/2026-06-25-a2-step2-uipresentation.md`) executed through Phase 2-6 commit anchors and receipt reconciliation inside this isolated worktree. Current status is **PARTIAL overall**: Phase 3/4/5/6 are DONE only for A-2 simulator/mock scope; Phase 2 continuous-stage visual acceptance `8.A` and `8.C2` remain open because visual-acceptance 5-gate and anchor-level human review are not closed. Final long-form closeout report: `docs/research/2026-06-25-a2-execution/a2-final-500-line-closeout-report.md` (601 lines). Grill SSOT: SD3/SD5/SD18-25 in `docs/uiue-storyboard-grill-decisions.md`; freeze + supersession registry (S1-S10) in `docs/grill-checklist/uiue-grill-定档-2026-06-25.md`; landing matrix in `docs/grill-checklist/uiue-landing-matrix-2026-06-25.md`; runtime bridge decisions (RPB-01~53) in `docs/grill-checklist/uiue-runtime-bridge-decisions-2026-06-25.md`.
- New OpenSpec change: `openspec/changes/define-runtime-presentation-bridge/` — **✅ accepted by 磊哥 2026-06-25 (A-2 ui-presentation may consume the contract shape via mock snapshots); `openspec validate --strict` pass; contract-only; no Swift implementation; no runtime/voice/C6/endpoint/V·S·U-PASS readiness claims; AD-RPB-014 context 四维**. Authored in UIUE lane, fulfills parent roadmap Task 2. Mainline co-authorship review still pending for the **runtime-side implementation** (mainline MUST NOT create a second bridge change). Acceptance = contract is stable enough for UIUE visual consumption, NOT a runtime-readiness claim.
- Next: do not mark A-2 complete until Phase 2 visual acceptance resumes and closes `8.A`/`8.C2`. Continue keeping `openspec/changes/ui-presentation/tasks.md`, `docs/grill-checklist/uiue-a2-grill-coverage-index.md`, phase receipts, and closeout reports synchronized. Bridge **AD-RPB-015** remains the single cross-artifact ID authority; a future code-graph harness (GitNexus/roam-code) manifest derives from it, never mints a second ID set.

This is UIUE-lane state, not mainline evidence. Bridge recorded as `proposed_strict_valid_contract_only`; reconfirm at the contract intersection before mainline merge.

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

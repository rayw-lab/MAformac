---
status: active_router_only_not_ssot
artifact_kind: current_route_board
authority: router_only_not_contract
updated: 2026-06-30
plan_creation_head: f3a3299fe55fcb67b72f8b1a085f8939b01b1b76
architecture_audit_head: 69432512a2c8ddcdc584bfac47f3218262544118
route_fix_input_worktree_head: 69432512a2c8ddcdc584bfac47f3218262544118
route_fix_input_upstream_head: 69432512a2c8ddcdc584bfac47f3218262544118
architecture_code_absorption_input_head: e130a214f7f4cac42d68fbad7f73662a19932975
last_verified_origin_main: 771f48a
branch: codex/rebuild-c6-doc-absorption-20260624
head_truth_rule: "Run git rev-parse HEAD and git rev-parse @{u}; this route board records verification inputs and loses to live repo state."
expires_when: "a newer current route board lands or the post-C6 parent roadmap is superseded by accepted grill decisions."
---

# CURRENT - MAformac Current Route Board

> This file is a traffic board, not a source of truth.
> If this file conflicts with `CLAUDE.md`, archived OpenSpec specs, accepted grill decision packs, active OpenSpec changes, signed evidence, or live repo state, this file loses and must be updated.

## Current Phase

D24 local/cloud dual-repo absorption and PR merge-control is live-verified closed under proof cap.

Live-verified D24 post-merge facts:

- `origin/main`: `771f48ad1bbaf02740f71da2cf90ada02fc6f6c6`.
- PR #7: `MERGED`, merge commit `b7b901b32b22f2895464faa497234d3ae46dc7dd`.
- PR #6: `MERGED`, merge commit `08032412b2ba8edb350259ccec8c70717ccb561d`.
- PR #8: `MERGED`, merge commit `771f48ad1bbaf02740f71da2cf90ada02fc6f6c6`; fixed the post-D24 audit finding that the whitespace proof was range-blind.
- Final Verify: GitHub Actions run `28431421039` completed `success` on head `771f48ad1bbaf02740f71da2cf90ada02fc6f6c6`.
- D24 proof class: `local + unit + docs_local + github_actions_self_hosted + github_cloud_merge_truth`.
- GitHub-hosted macOS billing/spending-limit was not fixed; D24 used a temporary self-hosted runner proof path and cleaned it up.

D24 closes absorption + route-control + cloud PR merge + post-merge verification only. It is not R5 complete, A-2 complete, runtime-ready, mobile, true-device, live API, V/S/U-PASS, voice-ready, model-ready, golden-ready, or endpoint-ready.

Current immediate route is D25 K1 spike-ledger work before any new runtime/code/model train.

Post Long-run 2 rebuild-C6 identity + behavior-shape construction closeout.

Live-verified route facts at the start of the architecture-audit absorption patch:

- Current worktree branch: `codex/rebuild-c6-doc-absorption-20260624`.
- Route plan creation `HEAD`: `f3a3299fe55fcb67b72f8b1a085f8939b01b1b76`.
- GPT Pro architecture audit `HEAD`: `69432512a2c8ddcdc584bfac47f3218262544118`.
- Route-fix input worktree `HEAD`: `69432512a2c8ddcdc584bfac47f3218262544118`.
- Route-fix input upstream `@{u}`: `69432512a2c8ddcdc584bfac47f3218262544118`.
- `origin/main` at architecture-audit input time (historical snapshot): `c1e7d58d281d0256d29034c1d120cefe0bf5a033`; **current `origin/main` is `771f48ad`** per "Current Phase" above.
- `origin/main` is an ancestor of the route-fix input `HEAD`.
- This file is not a self-updating commit marker; for current branch truth after later commits, run `git rev-parse HEAD` and `git rev-parse @{u}`.

Strongest truthful status:

- `rebuild-c6` identity + behavior-shape closeout: `external-pass-with-absorbed-fixes`.
- Post-C6 parent roadmap architecture audit: `ARCH_PASS_WITH_FIXES`, with route/plan P1/P2 absorbed earlier and code-level C6 bench/source-free guardrails absorbed in the post-audit absorption patch.
- Proof classes: `external_gptpro_review`, `local_static_contract`, `local_unit`, `local_shape_no_model`, `local_receipt_consistency`.
- This is not C6 acceptance, not model-quality evaluation, not retrain-C5, not D-domain base recalibration, not candidate comparison, not golden-run, not voice readiness, not endpoint readiness, not UIUE merge, not R-L17 candidate signoff, and not V/S/U-PASS.

Current planning object:

- `docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md`
- authority: `implementation_plan_not_ssot`
- purpose: align docs/grill route after Long-run 2 before any new implementation lane starts.

## Read First

0. `docs/commander-log/COMMANDER-INDEX.md` - 🔴 commander decision-layer entry; read first after any auto-compaction to recover commander identity / decisions (D-001~) / current state.
1. `CLAUDE.md` - project constitution and highest routing rule.
2. `docs/CURRENT.md` - this route board; router only, not SSOT.
3. `docs/README.md` - document map.
4. `Tools/agent-platform-plugin-refs/README.md` - local iOS/macOS build plugin references for SwiftUI, Liquid Glass, simulator, performance, and packaging work.
5. `.xcodebuildmcp/README.md` - this worktree's persisted Codex `build-ios-apps` default profile and simulator assignment.
6. `docs/project/phase0/rebuild-c6-identity-shape-closeout-2026-06-25.md` - Long-run 2 closeout.
7. `docs/project/phase0/rebuild-c6-identity-shape-gptpro-absorption-ledger-2026-06-25.md` - external audit findings and absorption ledger.
8. `docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md` - next parent roadmap and child-plan split.
9. `docs/project/phase0/post-c6-roadmap-gptpro-architecture-absorption-ledger-2026-06-25.md` - code-level architecture audit absorption ledger for C6 bench/source-free guardrails.
10. `openspec/changes/rebuild-c6-four-layer-bench/` - active C6 carrier history and future candidate-comparison lane boundaries.
11. `openspec/changes/retrain-c5-lora-d-domain/` - downstream C5 retrain draft, not execution authorization.
12. `openspec/changes/ui-presentation/` - UIUE presentation contract context, not mainline merge proof.
13. `openspec/changes/define-runtime-presentation-bridge/` - active contract-only Runtime -> Presentation bridge carrier; mainline mapping authority for UIUE provenance, not runtime proof.
14. `docs/project/phase0/mainline-runtime-presentation-bridge-unblock-2026-06-28.md` - Phase 0 owner-gate unblock receipt for C01/C03/C06/C18.
15. `docs/project/phase0/r5-d24-uiue-absorption-manifest-2026-06-30.md` - D24 main-traceable local/cloud/UIUE absorption manifest.
16. `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d24-uiue-absorption-source-manifest-2026-06-30.md` - D24 UIUE source-side manifest.

Local iOS build truth:

- This worktree's persisted Codex `build-ios-apps` profile is `ios`.
- Default iOS scheme is `MAformacIOS`.
- Dedicated simulator is `iPhone 17 Pro`.
- UIUE worktree must keep a different simulator because both worktrees share `lab.rayw.MAformac.ios`.

## Do Now

1. Run D25 as a bounded K1 spike-ledger lane for `C082`, `C083`, `C096`, `C117`, `C182`, `C197`, `C207`, and `C208`.
2. For each K1 row, produce a receipt with `PASS`, `PARTIAL`, or `BLOCKED`, proof class, evidence, and explicit promotion/no-promotion decision. No implementation promotion without receipt.
3. Execute D25 in four bounded clusters: event gates (`C082`, `C083`, `C182`), GPU/runtime contention (`C096`), voice proof boundary (`C117`), and model/parser/proof governance (`C197`, `C207`, `C208`).
4. Treat the D25 user-story map in `docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md` as the dispatch seed; it is not yet implementation authorization.
5. Preserve D22/D23/D24 commander facts: `DONE_UNDER_PROOF_CAP / PASS_WITH_NOTES`, user-selected advisory reviews are not gates/proof class, Claude Code final audit skipped by user override where recorded, first GPT Pro `REQUEST_CHANGES` was fixed post-audit rather than rewritten as PASS, and D24 cloud merge used self-hosted Actions proof without fixing hosted billing.
6. Keep the thin `define-runtime-presentation-bridge` OpenSpec carrier as the active contract-only Runtime -> Presentation mapping authority.
7. After K1, split downstream work into accepted child plans for C5 retrain, C6 acceptance/comparison, iOS/macOS runtime backend, and demo-golden/voice/UIUE connection.
8. Treat any R5 closeout claim as a separate proof-capped closeout after D25, not as an automatic result of D24 merge.

## Do Not Do

- Do not start LoRA data generation or training.
- Do not run C6 acceptance, D-domain base recalibration, or real model-quality evaluation.
- Do not execute candidate comparison without a signed retrain-C5 candidate and explicit run authorization.
- Do not claim endpoint-ready, C6-ready, demo-golden-ready, voice-ready, V-PASS, S-PASS, or U-PASS.
- Do not execute demo-golden-run or freeze golden IDs/readback/UIUE scene tags.
- Do not merge UIUE into mainline or cite UIUE file:line evidence as current mainline proof without live git/PR/state reconfirmation.
- Do not import raw cockpit/customer text, PII, secrets, pricing, or internal-only source material into bench cases or training data.
- Do not turn R-L17 route/candidate verdicts into runtime enums or C24 status IDs.

## Open Gates

| Gate | Status | Required Next Evidence |
|---|---|---|
| Parent roadmap | local_docs_plan_architecture_audit_code_fixes_absorbed | User grill must accept or revise `docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md`; code-level C6 bench/source-free audit findings are absorbed but do not upgrade proof class. |
| Runtime-Presentation bridge | proposed_active_contract_only | `openspec/changes/define-runtime-presentation-bridge/` validates as the mainline-visible carrier; closes C01/C03/C06/C18 for dispatch readiness only, not runtime/mobile/model proof. |
| D25 K1 spike ledger | next | Eight K1 rows need bounded falsification receipts before promotion: event gates `C082/C083/C182`, GPU/runtime `C096`, voice `C117`, model/parser/proof governance `C197/C207/C208`. |
| C5 retrain | deferred | Requires accepted C5 child plan, physical entry gates, data generation authorization, and separate training proof. |
| C6 acceptance/comparison | deferred | Requires signed C5 candidate and explicit run authorization; Long-run 2 shape evidence is insufficient. |
| Runtime backend | deferred_but_not_absent | Thin bridge contract may proceed first; full backend implementation waits for accepted bridge plan and model/C6 alignment. |
| Voice/golden/UIUE | deferred | Requires stable state-cell/tool-card/C6/golden/readback IDs and separate proof classes. |
| R-L17 candidate signoff | unsigned | Route-only signoff does not promote a candidate. |

## UIUE Isolation Tree

UIUE remains outside this mainline route unless state, C3-C6, readback, golden-run IDs, default-scope presentation contracts, or Runtime -> Presentation bridge fields conflict.

Known external worktree:

- Worktree: `/Users/wanglei/workspace/MAformac-uiue`
- Status: external isolated UIUE Phase 4 remediation/brainstorming unless reconfirmed live.
- Current mainline stance: read-only intersection checks only.

This is not mainline evidence. Reconfirm live UIUE git/PR state before citing UIUE as merged or using it as C6, runtime, voice, golden, or V-PASS proof.

## Retired / Historical Inputs

- The prior `docs/CURRENT.md` route-only rebuild-C6 construction board is superseded by this post Long-run 2 board.
- `docs/roadmap-2026-06-20-from-c6-done.md` remains historical provenance, not live roadmap.
- `docs/project/phase0/non-uiue-pre-code-action-list-2026-06-24.md` remains historical route-control evidence; its rebuild-C6-first ordering has been consumed by Long-run 2 identity + behavior-shape construction closeout.
- UIUE branch documents are external active work, not mainline proof until reconfirmed at the contract intersection.

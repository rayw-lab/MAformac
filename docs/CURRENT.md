---
status: active_router_only_not_ssot
artifact_kind: current_route_board
authority: router_only_not_contract
updated: 2026-06-25
last_verified_worktree_head: 246968a
last_verified_origin_main: c1e7d58
branch: codex/rebuild-c6-doc-absorption-20260624
expires_when: "rebuild-c6-four-layer-bench construction apply closeout lands, this branch is merged, or this route board is superseded by a newer board."
---

# CURRENT — MAformac Current Route Board

> This file is a traffic board, not a source of truth.
> If this file conflicts with `CLAUDE.md`, archived OpenSpec specs, accepted grill decision packs, active OpenSpec changes, or signed R-L17 evidence, this file loses and must be updated.

## Current Phase

Post-PR4 / post-R-L17 route-only signoff: `rebuild-c6-four-layer-bench` is the current non-UIUE mainline for construction preparation.

Current audited state:

- Current worktree branch: `codex/rebuild-c6-doc-absorption-20260624`.
- Current worktree `HEAD`: `246968a` (`gov(R-L17): route-only signoff by wanglei`).
- Pre-sign evidence commit: `ec8d35b` (`docs(phase0): R-L17 route-only signoff evidence pack`).
- Current `origin/main`: `c1e7d58`.
- `origin/main` is an ancestor of current `HEAD`; this branch is ahead by two documentation/governance commits.
- Active carrier: `openspec/changes/rebuild-c6-four-layer-bench/`.
- Latest validation in this route window: `openspec validate rebuild-c6-four-layer-bench --strict` pass; `openspec validate --all --strict` pass with 15 passed, 0 failed; `git diff --check` pass.

R-L17 status:

- `route_deframing_verdict: signed_route_only`.
- `signoff_scope: route_only_to_rebuild_c6_construction`.
- `candidate_signoff_verdict: unsigned`.
- Codex/OpenAI plus GLM are accepted as the heterogeneous review trace; candidate signoff does not require an additional judge solely for source diversity.
- Route-only signoff unlocks human OpenSpec propose review, §1 construction preconditions, §2 D-domain expected-tool construction, and §3 four-layer bench construction.
- Route-only signoff does not unlock retrain-C5, C6 acceptance, D-domain base recalibration, §4 candidate comparison, demo golden-run, voice, endpoint readiness, UIUE merge, or V/S/U-PASS.

This route board reflects the current worktree. Do not cite it as merged mainline truth until the branch is merged or live mainline state is reconfirmed.

## Read First

1. `CLAUDE.md` — project constitution and highest routing rule.
2. `docs/CURRENT.md` — this route board; router only, not SSOT.
3. `docs/README.md` — document map.
4. `docs/project/phase0/r-l17-human-review-evidence/R7-final-route-deframing-signoff.md` — signed route-only governance evidence.
5. `docs/project/phase0/rebuild-c6-documentation-absorption-closeout-2026-06-24.md` — documentation absorption closeout and validation whitelist.
6. `docs/project/phase0/rebuild-c6-precode-grill-ledger-2026-06-24.md` — Q3/Q4 row-level absorption and rejected alternatives.
7. `docs/project/phase0/paper-to-skill-gate-absorption-ledger-2026-06-24.md` — Q2 paper absorption split; C5-owned tail remains in retrain-C5.
8. `openspec/changes/rebuild-c6-four-layer-bench/` — active OpenSpec carrier.

## Do Now

1. Run the `rebuild-c6-four-layer-bench` human OpenSpec propose review.
2. Reconfirm current branch, `HEAD`, `origin/main`, and load-bearing APIs before any implementation instruction.
3. Resolve the remaining construction WBS grill points before the relevant code work starts:
   - Q5.1 accepted with structural fix: this carrier may carry a bounded apply/execution producer subtask for `appliedWrites`, but C6 runtime/scorer remains a consumer.
   - P0 branch seals before affected code: Q5.2, Q5.4, Q5.5, Q5.6, Q5.7, Q5.9, Q5.10, Q5.11.
   - P1 closeout / coordination gates: Q5.8, Q5.12, Q5.13.
   - Conditional only: Q5.3 `scopedKey()` public helper.
   - Canonical order and red lines are archived in `docs/project/phase0/rebuild-c6-precode-grill-ledger-2026-06-24.md#Q5-Batch-Triage-Branching-Questions-Are-Implementation-Entry-Gates`.
4. After propose/apply authorization, implement only §2/§3 construction scope for rebuild-C6.
5. Keep `retrain-c5-lora-d-domain`, candidate comparison, golden-run, voice, endpoint readiness, and UIUE mainline merge as downstream gated work.

## Do Not Do

- Do not start LoRA data generation or training.
- Do not run C6 acceptance, D-domain base recalibration, or real model-quality evaluation.
- Do not execute §4 candidate comparison without a signed retrain-C5 candidate and explicit run authorization.
- Do not claim endpoint-ready, C6-ready, demo-golden-ready, voice-ready, V-PASS, S-PASS, or U-PASS.
- Do not execute demo-golden-run or freeze golden IDs/readback/UIUE scene tags.
- Do not merge UIUE into mainline or cite UIUE file:line evidence as current mainline proof without live git/PR/state reconfirmation.
- Do not import raw cockpit/customer text, PII, secrets, or "internal only" source material into bench cases.
- Do not turn R-L17 route/candidate verdicts into runtime enums or C24 status IDs.

## Open Blockers

| Blocker | Status | Required Next Evidence |
|---|---|---|
| R-L17 route deframing | signed_route_only | Evidence: `docs/project/phase0/r-l17-human-review-evidence/R7-final-route-deframing-signoff.md`; keep candidate unsigned. |
| OpenSpec propose review | unlocked_not_yet_closed | Human review must accept `openspec/changes/rebuild-c6-four-layer-bench/` before implementation. |
| Baseline/API reconfirm | partially_probed | Current symbols exist, but implementation handoff must record current file:line evidence for `ScopeOrigin`, `ScopeResolution`, `C2ScopeResolver.scopedKey()`, and `ToolContractStateApplier.applyWithEvidence`. |
| Q5.1 apply producer scope | accepted_with_carve_out | Carrier now permits §3.9a-d bounded upstream producer work in apply/execution; C6 runtime/scorer remains consumer only. |
| Q5.2 behavior taxonomy shape | P0_accept_with_naming_correction | Use shared `BehaviorClass` / `VehicleToolBehaviorClass` plus `behavior_class` field; keep `C6Bucket` legacy/import/report mapping and do not let `coverage` enter behavior taxonomy. |
| Q5.3 scoped key helper | conditional_defer | Do not publicize by default; expose narrow helper only if implementation proves C6/tests cannot consume materialized `ScopeResolution.keys`. |
| Q5.4-Q5.11 implementation branch seals | P0_before_affected_code | Resolve selector/denominator depth, `StateWrite`, dependency provenance, readback hard-pass split, JSONL shape boundary, two-axis reporting, and implementation proof classes before touching the affected code areas. |
| Q5.8/Q5.12/Q5.13 closeout gates | P1_closeout_coordination | Preserve digest compatibility, live UIUE intersection proof if triggered, and staged docs/code/validation commit topology before closeout. |
| Candidate signoff | unsigned | Requires completed construction evidence, signed retrain-C5 candidate, explicit run authorization, and human-owner signoff. |
| UIUE reconfirm | isolated_external | Recheck only if UIUE touches `Core/State/`, `contracts/`, `generated/`, shared C3-C6 contracts, golden IDs, or route claims. |

## UIUE Isolation Tree

UIUE remains outside this mainline route unless state, C3-C6, readback, golden-run IDs, or default-scope presentation contracts conflict.

Known external worktree:

- Worktree: `/Users/wanglei/workspace/MAformac-uiue`
- Relevant dispatch: `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-24-phase4a-cc-window-dispatch.md`
- Last checked impact: no current decision change for R-L17 route deframing because Phase4A is isolated and should not touch `Core/State/`, `contracts/`, or `generated/`.

This is not mainline evidence. Reconfirm live UIUE git/PR state before citing UIUE as merged or using it as C6 proof.

## Current Carrier Summary

`rebuild-c6-four-layer-bench` owns the construction design for:

- D-domain expected tool semantics in C6 release/trap cases.
- Four independent external layers: `golden`, `demo_fuzz`, `unsupported`, and `safety`.
- Five internal behavior classes: `tool_call`, `clarify_missing_slot`, `refusal_no_available_tool`, `refusal_safety_or_policy`, and `already_state_noop`.
- Behavior-class SSOT across C5 data counts, C6 selectors/denominators, and apply/execution no-effect reasoning.
- Readback plan P: renderer readback excluded from model hard-pass but retained for deterministic gold validity.
- C6 replay fact bundle that consumes apply-layer evidence without becoming a second runtime.
- Versioned contract bundle fingerprint over contract inputs while preserving per-run prompt/output/model/artifact digests.
- Future D-domain base anchor design as comparison semantics only, not permission to run recalibration.

## Retired / Historical Inputs

- The prior `docs/CURRENT.md` default-scope route board is superseded by this route-only rebuild-C6 board.
- `docs/roadmap-2026-06-20-from-c6-done.md` is historical provenance, not live roadmap.
- `docs/c5-recovery-2026-06-22/roadmap.md` has historical value but must not act as live roadmap unless split/bannered by Phase 0 disposition.
- `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md` is a high-weight pre-propose checklist and evidence pack, not SSOT.
- UIUE branch documents are external active work, not mainline proof until reconfirmed at the contract intersection.

---
status: signed_route_only_candidate_unsigned
artifact_kind: r_l17_R7_final_route_deframing_signoff
authority: human_owner_route_only_signoff
review_lane: human_owner_required
signoff_scope: route_only_to_rebuild_c6_construction
route_deframing_verdict: signed_route_only
candidate_signoff_verdict: unsigned
human_owner: "王磊 (i飞-奇瑞国际语音解决方案负责人)"
heterogeneous_judge_vendor: glm-latest
signed_on: "2026-06-25"
pre_sign_evidence_commit: ec8d35b
candidate_signoff_requires_additional_heterogeneous_judge: false
candidate_second_source: codex_openai
route_deframing_unlocks:
  - rebuild_c6_four_layer_bench_human_propose_review
  - rebuild_c6_section_1_construction_preconditions
  - rebuild_c6_section_2_d_domain_expected_tool_construction
  - rebuild_c6_section_3_four_layer_bench_construction
route_deframing_blocks:
  - retrain_c5
  - rebuild_c6_acceptance
  - d_domain_base_recalibration
  - candidate_comparison
  - demo_golden_run
  - voice
  - endpoint_readiness
  - uiue_merge_to_mainline
  - v_pass_s_pass_u_pass
route_deframing_blocked_by_rebuild_c6: false
r1_r6_evidence_policy: "feed_forward_historical_for_route_only; full evidence required before candidate signoff"
retire_trigger: "Retire after candidate signoff supersedes route-only signoff or after reviewed artifact is archived."
expires: "2026-07-15"
---

# R7 Final Route Deframing Signoff

## Verdict

R-L17 route deframing is signed **only** for `route_only_to_rebuild_c6_construction`.

This signoff unlocks:

- human OpenSpec propose review for `rebuild-c6-four-layer-bench`;
- §1 construction preconditions;
- §2 D-domain expected-tool construction;
- §3 four-layer bench construction.

This signoff does **not** unlock:

- `retrain-c5`;
- C6 acceptance;
- D-domain base recalibration;
- §4 candidate comparison;
- demo golden-run;
- voice;
- endpoint readiness;
- UIUE merge to mainline;
- V-PASS, S-PASS, or U-PASS.

`candidate_signoff_verdict` remains `unsigned`.

## Human Owner Decision Source

The human-owner decision was supplied on 2026-06-25 with these binding choices:

- sign route-only;
- write the scope as `route_only_to_rebuild_c6_construction`;
- keep candidate unsigned;
- commit governance evidence before signing;
- use GLM as sufficient heterogeneous judge for route-only;
- count Codex/OpenAI as the second non-Claude-family source, so candidate signoff does not require an additional heterogeneous judge solely for source diversity.

The pre-sign evidence pack was committed first:

```text
ec8d35b docs(phase0): R-L17 route-only signoff evidence pack
```

## Prep And Audit Inputs

| Input | Evidence | Role |
|---|---|---|
| Documentation absorption closeout | `../rebuild-c6-documentation-absorption-closeout-2026-06-24.md` | proves OpenSpec carrier is ready for human propose review, not apply |
| Route deframing prep | `route-deframing-prep-2026-06-24.md` | summarizes G1-G5 and route-only decision surface |
| GLM heterogeneous audit | `heterogeneous-deframing-audit-glm-2026-06-25.md` | satisfies heterogeneous audit input for route-only scope |
| Q2 paper ledger pointers | `../paper-to-skill-gate-absorption-ledger-2026-06-24.md` | row-level absorption / remaining-owner evidence |
| Q3/Q4 rebuild-C6 ledger pointers | `../rebuild-c6-precode-grill-ledger-2026-06-24.md` | row-level absorption / rejection evidence |
| OpenSpec carrier | `/Users/wanglei/workspace/MAformac/openspec/changes/rebuild-c6-four-layer-bench/` | route/control artifact, not implementation |

## G1-G5 Signoff Table

| Gate | Evidence file | Verdict | Notes |
|---|---|---|---|
| G1 D1-D10 verdicts accepted | `../phase0-d1-d10-user-decision-record.md` | pass_for_route_only | D1-D10 accepted; no new D decision is introduced by this route-only signoff. |
| G2 R1-R7 artifacts complete | this directory | partial_for_route_only | R1-R6 are treated as feed-forward/historical evidence for route-only construction. Full first-hand evidence remains required before candidate signoff. |
| G3 heterogeneous deframing audit exists | `heterogeneous-deframing-audit-glm-2026-06-25.md` | pass_for_route_only_scope | `glm-latest` is accepted as the non-Claude-family heterogeneous judge for route-only. Codex/OpenAI is accepted as the second non-Claude-family source; no extra heterogeneous judge is required solely for candidate-stage source diversity. |
| G4 consistent PASS did not bypass human review | this file | pass_for_route_only | Human owner reviewed GLM audit and explicitly made the route-only decision. Model consensus did not substitute for human-owner signoff. |
| G5 disagreements escalated | `heterogeneous-deframing-audit-glm-2026-06-25.md` and this file | pass_for_route_only | GLM audit reported no blocking findings. Future disagreement at candidate stage escalates to human owner, not majority vote. |

## Final Route Decision

| Decision | Verdict | Evidence |
|---|---|---|
| Route deframing verdict | signed_route_only | Scope is `route_only_to_rebuild_c6_construction`; unlocks rebuild-C6 §1/§2/§3 construction only. |
| Candidate signoff verdict | unsigned | Candidate signoff requires completed construction evidence, signed retrain-C5 candidate, and explicit run authorization. It does not require an additional heterogeneous judge solely for source diversity because Codex/OpenAI is already the second source. |
| Candidate signature | not_applicable_to_route_only | Not signed here. |
| Paradigm choice | rebuild_c6_verification_before_training_only | Four-layer denominators, C5/C6/apply BehaviorClass SSOT, readback plan P, and versioned contract bundle fingerprint are accepted for rebuild-C6 construction. Retrain-C5 LoRA paradigm remains for candidate signoff. |
| D2-D10 implications | no_new_D_decision | D1-D10 remain accepted; this signoff does not revise D2-D10 semantics. |
| next action: rebuild-C6 | unlocked_for_construction | Human OpenSpec propose review plus §1/§2/§3 construction. |
| next action: retrain-C5 | blocked | Wait for C6 construction completion and candidate signoff. |
| next action: golden / voice / endpoint | blocked | Wait for candidate signoff and explicit run authorization. |
| next action: UIUE | isolated | UIUE Phase4A may continue in `MAformac-uiue`; reopen intersection review only if it touches `Core/State/`, `contracts/`, `generated/`, shared C3-C6 contracts, or golden IDs. |

## Route-Only Scope Rules

Allowed after this signoff:

1. Human OpenSpec propose review for `rebuild-c6-four-layer-bench`.
2. Reconfirm current branch, `HEAD`, `origin/main`, and load-bearing APIs.
3. Run §1 construction preconditions.
4. Implement §2/§3 rebuild-C6 construction only after accepted propose/apply authorization.

Forbidden after this signoff:

1. Any `retrain-c5` data generation or training.
2. C6 acceptance or model-quality evaluation.
3. D-domain base recalibration.
4. §4 candidate comparison.
5. Demo golden-run, voice, or endpoint-readiness claims.
6. UIUE merge into mainline.
7. Any V-PASS, S-PASS, or U-PASS claim.

## Required Checks For Future Candidate Signoff

- Fill or supersede R1-R6 with first-hand evidence.
- Complete rebuild-C6 construction evidence.
- Produce a signed retrain-C5 candidate.
- Obtain explicit run authorization.
- Preserve the Codex/OpenAI plus GLM audit trace, or obtain a new judge only if the candidate scope materially changes.
- Keep `candidate_signoff_verdict` unsigned until all above are satisfied.

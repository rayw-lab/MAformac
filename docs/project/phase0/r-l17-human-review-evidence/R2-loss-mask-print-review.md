---
status: stub_pending_evidence
artifact_kind: r_l17_R2_loss_mask_print_review
authority: evidence_stub_not_pass
review_lane: human_owner_required
retire_trigger: "Retire after reviewed artifact is archived or superseded."
expires: "2026-07-15"
---

# R2 Loss-Mask Print Review

## Required Verdict

R-L17 R2 is not pass until the physical loss-mask print is reviewed by eye. A metadata field saying masking is enabled is not evidence.

## Evidence Template

| Artifact | File:line or command | Mask type | Expected physical signal | Observed signal | Verdict | Reviewer |
|---|---|---|---|---|---|---|
| TBD | TBD | train_on_turn/function/arg_value | TBD | TBD | pending | TBD |

## Required Checks

- Verify `train_on_turn=false` failure turns where applicable.
- Verify function/name and argument-value masking or constrained augmentation are not conflated.
- Verify D7 failure minimal seed cannot train bad calls.

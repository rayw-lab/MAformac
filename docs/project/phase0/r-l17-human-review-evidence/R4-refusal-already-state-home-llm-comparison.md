---
status: stub_pending_evidence
artifact_kind: r_l17_R4_refusal_already_state_home_llm_comparison
authority: evidence_stub_not_pass
review_lane: human_owner_plus_heterogeneous_judge
retire_trigger: "Retire after reviewed artifact is archived or superseded."
expires: "2026-07-15"
---

# R4 Refusal And Already-State Comparison

## Required Verdict

R-L17 R4 is not pass until refusal and `already_state` examples are compared against home-llm refusal/already_state evidence. D10 model-training ownership cannot change without this file.

## Evidence Template

| Row ID | MAformac prompt/state | Expected MAformac readback | home-llm comparison artifact | Classification | Verdict | Reviewer |
|---|---|---|---|---|---|---|
| TBD | TBD | TBD | TBD | refusal/already_state | pending | TBD |

## Required Checks

- Include at least 30 natural-language `already_state`/readback comparison rows before moving D10 ownership from renderer to model training.
- Keep `already_state` distinct from unsupported and safety refusal.
- Include `scope_origin` where defaulted/explicit scope is relevant.

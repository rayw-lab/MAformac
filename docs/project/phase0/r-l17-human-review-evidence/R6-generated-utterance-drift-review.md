---
status: stub_pending_evidence
artifact_kind: r_l17_R6_generated_utterance_drift_review
authority: evidence_stub_not_pass
review_lane: human_owner_or_heterogeneous_judge
retire_trigger: "Retire after reviewed artifact is archived or superseded."
expires: "2026-07-15"
---

# R6 Generated Utterance Drift Review

## Required Verdict

R-L17 R6 is not pass until generated utterance drift and generator self-preference are reviewed by eye.

## Evidence Template

| Row ID | Generator/source | Utterance | Intended class/tool | Drift concern | Verdict | Reviewer |
|---|---|---|---|---|---|---|
| TBD | TBD | TBD | TBD | TBD | pending | TBD |

## Required Checks

- Identify generator phrasing that overfits to the expected tool.
- Flag utterances that introduce unsupported scope, safety, or already_state ambiguity.
- Do not use generator self-labels as pass evidence.

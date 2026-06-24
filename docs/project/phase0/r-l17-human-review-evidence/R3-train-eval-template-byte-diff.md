---
status: stub_pending_evidence
artifact_kind: r_l17_R3_train_eval_template_byte_diff
authority: evidence_stub_not_pass
review_lane: human_owner_plus_heterogeneous_judge
retire_trigger: "Retire after reviewed artifact is archived or superseded."
expires: "2026-07-15"
---

# R3 Train-Eval Template Byte Diff

## Required Verdict

R-L17 R3 is not pass until train/eval render templates are byte-diffed. "Looks identical" is not evidence.

## Evidence Template

| Artifact pair | Diff command | Diff digest/path | Mismatch summary | Verdict | Reviewer |
|---|---|---|---|---|---|
| TBD | TBD | TBD | TBD | pending | TBD |

## Required Checks

- Include train render bytes and eval render bytes.
- Include endpoint render bytes if D5 endpoint parity is being discussed.
- Include any think signature or mask-offset token evidence used by the gate.

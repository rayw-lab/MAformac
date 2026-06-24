---
status: stub_pending_evidence
artifact_kind: r_l17_R1_first_50_sample_read
authority: evidence_stub_not_pass
review_lane: human_owner_required
retire_trigger: "Retire after reviewed artifact is archived or superseded."
expires: "2026-07-15"
---

# R1 First-50 Sample Read

## Required Verdict

R-L17 R1 is not pass until the first 50 training samples are read row-by-row and each row has a verdict.

## Evidence Template

| Row ID | Source file:line/artifact | Class | Expected tool/no-call | Observed issue | Verdict | Reviewer |
|---|---|---|---|---|---|---|
| TBD | TBD | TBD | TBD | TBD | pending | TBD |

## Required Checks

- No metadata-only claims.
- Include no-call target presence where relevant.
- Include refusal/already_state rows if they appear in the first 50.
- If a D2 `human_pause` refers to this file, the reviewed rows must be at least 50.

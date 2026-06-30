---
status: evidence_templates
artifact_kind: r_l17_human_review_evidence_index
authority: evidence_template_not_review_result
retire_trigger: "Retire after R-L17 G1-G5 all pass and the accepted evidence index is archived into the relevant OpenSpec closeout."
expires: "2026-07-15"
---

# R-L17 Human Review Evidence

R-L17 is a deframing gate, not a same-vendor multi-agent vote. More agents with the same frame do not certify high-stakes route decisions.

## Review Lanes

| Lane | Requirement | Counts Toward R-L17 PASS |
|---|---|---|
| Human owner | Required for high-stakes signoff and any disagreement. | Yes |
| Heterogeneous judge | At least one independent deframing audit outside the Claude-family. Prefer non-GPT-family when available. | Yes |
| Codex/OpenAI independent review | Counts only when explicitly accepted by the human owner and paired with a non-Claude-family audit trace. Default Codex/Claude self-checks remain pre-checks only. | Conditional |

## G1-G5 Pass Criteria

| Gate | Pass Criteria |
|---|---|
| G1 | D1-D10 verdicts are accepted in `phase0-d1-d10-user-decision-record.md`. |
| G2 | R1-R7 evidence files each contain reviewed rows, verdicts, and file:line or artifact references. |
| G3 | At least one heterogeneous deframing audit report exists and assumes failure first rather than restating candidate claims. |
| G4 | Four-model consistent PASS is treated as "no obvious objection" only; human-owner R7 signoff still reads first-hand evidence. |
| G5 | Any judge disagreement escalates to human-owner review; no majority vote override. |

Any missing G1-G5 item leaves R-L17 `UNSIGNED` and keeps retrain-c5, rebuild-c6, and demo-golden-run deferred.

## R1-R7 Evidence Files

| ID | File | Required Focus |
|---|---|---|
| R1 | `R1-first-50-sample-read.md` | First 50 training samples read row-by-row. |
| R2 | `R2-loss-mask-print-review.md` | Loss-mask print review for physical masking implementation. |
| R3 | `R3-train-eval-template-byte-diff.md` | Byte diff of train/eval render templates. |
| R4 | `R4-refusal-already-state-home-llm-comparison.md` | Refusal/already_state comparison against home-llm evidence. |
| R5 | `R5-top-failing-c6-case-drilldown.md` | Top failing C6 cases drilled down case-by-case. |
| R6 | `R6-generated-utterance-drift-review.md` | Generated utterance drift and generator self-preference review. |
| R7 | `R7-final-route-deframing-signoff.md` | Human-owner route-only signoff for rebuild-C6 construction; candidate signoff remains unsigned. |
| Heterogeneous audit input | `heterogeneous-deframing-audit-glm-2026-06-25.md` | GLM non-Claude-family route deframing audit input for G3; not human-owner signoff. |

Current route-only signoff accepts GLM plus Codex/OpenAI as the heterogeneous review trace. Candidate signoff therefore does not require an additional judge solely for source diversity, but it still requires candidate artifacts, construction evidence, explicit run authorization, and human-owner signoff.

## Non-Goals

- Do not review OpenSpec grammar or Markdown formatting here.
- Do not certify unit-test pass rate here; automated gates own that.
- Do not use majority vote across models as a substitute for deframing.
- Do not use an LLM judge to rubber-stamp another LLM judge.

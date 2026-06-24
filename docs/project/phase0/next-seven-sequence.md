---
status: accepted_sequence
artifact_kind: phase0_route_control_sequence
authority: route_control_not_openspec_policy
retire_trigger: "Retire after all seven listed skeletons are materialized into OpenSpec-ready manifests/tasks or superseded by phase0-d1-d10-closeout.md."
expires: "2026-07-15"
---

# Phase 0 Next Seven Sequence

## Accepted Sequence

| Order | Candidate | Workstream | Verdict |
|---:|---|---|---|
| 1 | C02 + C01 | authority + historical banner closeout | Must go first. If dual SSOT remains, every later route can read the wrong source. |
| 2 | C03 | full/demo matrix + generated proof | Correct order. A2 is mostly materialized; missing proof is `demo subset_of full` plus a matrix. |
| 3 | C04 | archived specs disposition across all archived specs | Correct order. Includes `lora-training` and prevents `retrain-c5` from colliding with stale spec language. |
| 4 | C05 | Pocock stage matrix + `forbidden_next_action` | Correct order. Prevents "looks decided, start training" recurrence. |
| 5 | C07 | decision lifecycle manifest for touched D1-D37 only | Correct order. Do not reopen untouched decisions. |
| 6 | C06 | runtime/outcome enum skeleton only | Strongly accepted. Top-level frame plus downstream placeholders; concrete domains wait for C13-C22. |
| 7 | C24 | status vocabulary directed graph skeleton only | Strongly accepted. Same logic as C06; prevents reverse-locking C09/C10/C18. |

## Not In Scope

- No retrain.
- No D-domain base recalibration run.
- No LoRA candidate comparison.
- No real endpoint-ready claim.
- No demo-golden-run execution.
- No UIUE merge.
- No conversion of this folder into runtime `contracts/`.

## Why This Is The Next Step

The loop competition accepted all 24 questions, but the first physical cut should not fan out into 24 workstreams. These seven items establish source authority, generated artifact truth, spec disposition, stage gates, decision lifecycle, and status language. Without them, later C5/C6 proposal work can look green while still carrying old roadmap, old spec, old baseline, or fake-pass semantics.

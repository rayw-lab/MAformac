# R2B S2 Lane J Generation Receipt

status: GENERATED_PENDING_SELF_AUDIT
proof_class: local_pre_training_batch_candidate_generation
generator: openai_codex_deterministic_script

## Scope

- batch_id: `r2b-s2-batch4`
- lane_id: `r2b-s2-lane-j`
- family quota: `{'sunroof_sunshade': 15, 'fragrance': 60}`
- class quota: `{'positive': 34, 'refusal': 5, 'already_state': 5, 'unsupported': 6, 'followup': 5, 'query': 20}`
- query split: `{'query_amount_of_fragrance': 10, 'query_mode_of_fragrance': 10}`

## Hard-boundary notes

- All 20 query rows are fragrance-only.
- `query_amount_of_fragrance=10`; `query_mode_of_fragrance=10`.
- Query rows carry `has_action=false`, `has_action_tool_call=false`, and `expected_state_delta={}`.
- Sunroof/sunshade query-style row is unsupported `NO_TOOL` with `D-087` reclass metadata.
- Natural Chinese inputs contain no protocol fragments by construction; RER-6 is checked by `_scratch/audit_lane_j.py`.
- Every pair id uses `_J_` lane marker.

## Authority

- `wave2-negatives/batch-package/lane-prompt-package.md:415-511`
- `wave2-negatives/batch-package/r2b-s2-batch4-order.json#lanes[r2b-s2-lane-j]`
- `W9-R2B-CONTRASTIVE-PAIR-SPEC.md`
- `contracts/semantic-function-contract.jsonl` fragrance/sunroof/sunshade rows

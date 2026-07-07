# R2B S2 AC Locked Supplement Generation Receipt

status: `GENERATED_PENDING_GATE_FINALIZE`
proof_class: `local_pre_training_batch_candidate_generation`
generator: `openai_codex_deterministic_script`

## Scope

- lane_id: `r2b-s2-supplement-ac-locked`
- rows: `23`
- class_counts: `{'positive': 11, 'query': 12}`
- repair_basis: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/R2B-1-LOCKED-GAP.md`

## Repair Semantics

- strict path chosen for `query_ac_temperature_vs_adjust`: +9 read-only `query_ac_temperature` rows so the strict query-side count reaches 10.
- `airoutlet/wind` floor uses `tool_pair_floor_id=airoutlet_wind_direction_windspeed`, matching `W9-R2B-CONTRASTIVE-PAIR-SPEC.md` scanner key.
- query rows have `has_action=false`, `has_action_tool_call=false`, and `expected_state_delta={}`.

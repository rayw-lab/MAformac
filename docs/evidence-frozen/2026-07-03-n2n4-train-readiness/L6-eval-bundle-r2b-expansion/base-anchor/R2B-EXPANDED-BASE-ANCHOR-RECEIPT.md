# R2B Expanded Base Anchor Receipt

status: DONE
proof_class: local_model_probe_base_only
verdict: EXPANDED_BASE_ANCHOR_BUILT
captured_at: 2026-07-04T14:40:43+08:00

## Scope

- Task: build expanded base anchor for frozen R2B expansion bundle using base model only, greedy decode, no adapter.
- Output dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L6-eval-bundle-r2b-expansion/base-anchor`
- Harness output: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L6-eval-bundle-r2b-expansion/base-anchor/probe-output-expanded-base-anchor`
- Recount: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L6-eval-bundle-r2b-expansion/base-anchor/base-anchor-recount.json`

## Frozen Bundle Binding

- Frozen bundle path: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L6-eval-bundle-r2b-expansion`
- Bundle manifest: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L6-eval-bundle-r2b-expansion/bundle-manifest.json`
- Bundle sha256: `821643943669de70b70621e55e89c590448602398a85d29d1d9108644acf90aa`
- Manifest sha256: `f6e89a0d3f0977f19376ea52cd9f666f3e764191c33cea420c3c007ffd491a77`
- Declared case count: `53` (`B_neighbor=26`, `Q=27`)
- Note: user dispatch said 51 cases, but the frozen %62 manifest is 53 cases. This run follows the frozen bundle authority.

## Run Inputs

- Base model: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR38-final-n4a-recipe-build/qwen3-1_7b-training-tokenizer-patched`
- Adapter: `None`
- Decode: greedy, temperature `0.0`, max_tokens `160`
- Mount source: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r2-data-ready/samples/c5-training-samples.jsonl`
- Mount source rows: `4750`
- Mount source sha256: `59f2f74e6798bc3e3cf62c3fe21858ca0804c69814ffe07b859423f1bd4c6467`
- Normalized cases: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L6-eval-bundle-r2b-expansion/base-anchor/probe-cases-r2b-expansion-53.mount-normalized.jsonl`
- Normalized cases sha256: `8ce9db2ee094cf690314a3f386beb9ef91c5176a3a831bd511646a4a832f49e6`

## Harness Summary

- Case count: `53`
- Non-empty tool outputs: `33`
- Empty tool outputs: `20`
- Time log: `real 65.43; user 10.61; sys 4.72`

## Independent Exact Recount

Criterion: `observed_tool_names == expected_tool_calls[].name`, exact and order-sensitive.

| Axis | Exact | Fail |
| --- | ---: | ---: |
| B | 15/26 | 11 |
| Q | 14/27 | 13 |
| TOTAL | 29/53 | 24 |

First fail cases:

| case_id | axis | expected | observed |
| --- | --- | --- | --- |
| R2B-BN1-001P | B | ['open_ac_set_interface'] | [] |
| R2B-BN1-002P | B | ['open_ac_set_interface'] | [] |
| R2B-BN1-003P | B | ['close_ac_set_interface'] | [] |
| R2B-BN1-004P | B | ['close_ac_set_interface'] | [] |
| R2B-BN1-004N | B | ['close_ac_set_interface'] | [] |
| R2B-BN3-001P | B | ['open_airoutlet'] | [] |
| R2B-BN3-002P | B | ['open_airoutlet'] | [] |
| R2B-BN3-003P | B | ['close_airoutlet'] | [] |
| R2B-BN3-004P | B | ['adjust_ac_wind_direction_to_value'] | ['switch_ac_wind_direction'] |
| R2B-BN3-004N | B | ['adjust_ac_wind_direction_to_value'] | ['switch_ac_wind_direction'] |
| R2B-BN3-005N | B | ['raise_ac_windspeed_by_exp'] | [] |
| R2B-Q-AC-WIND-001Q | Q | ['query_ac_windspeed'] | [] |
| R2B-Q-AC-WIND-001L | Q | ['adjust_ac_windspeed_to_number'] | ['raise_ac_windspeed_by_number'] |
| R2B-Q-SEAT-001L | Q | ['adjust_seat_heat_temperature_to_gear'] | [] |
| R2B-Q-WINDOW-001Q | Q | [] | ['get_window_status'] |
| R2B-Q-WINDOW-001L | Q | ['close_window_to_number'] | [] |
| R2B-Q-DOOR-001Q | Q | [] | ['open_tailgate'] |
| R2B-Q-DOOR-001L | Q | ['adjust_tailgate_height_to_number'] | [] |
| R2B-Q-VOLUME-001Q | Q | ['query_current_volume'] | [] |
| R2B-Q-VOLUME-001L | Q | ['adjust_volume_to_number'] | [] |

## Query Zero-Tolerance Scan

- Query expected cases (`expected[0]` starts with `query_`): `5`
- Query expected -> mutating actuation violations: `0`
- Unsupported query expected no-tool cases: `9`
- Unsupported query observed any tool: `4`

Query expected -> mutating actuation:

| case_id | expected | observed |
| --- | --- | --- |
| none | - | - |

Unsupported query no-tool violations:

| case_id | expected | observed |
| --- | --- | --- |
| R2B-Q-WINDOW-001Q | [] | ['get_window_status'] |
| R2B-Q-DOOR-001Q | [] | ['open_tailgate'] |
| R2B-Q-SUNROOF-001Q | [] | ['open_sunroof_little'] |
| R2B-Q-SUNSHADE-001Q | [] | ['query_sunshade_status'] |

## Non-Claims

- This is not adapter evaluation.
- This is not R2B train readiness or V-PASS.
- These exact/pass numbers are base-anchor reference numbers for later adapter-only comparison.

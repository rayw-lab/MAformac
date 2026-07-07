# R2B Full773 Final Account

status: `ASSEMBLY_INPUT_GATE_GREEN_LOCKED_FLOORS`
proof_class: `local/merge_and_cumulative_floor_gate`
generated_at: `2026-07-04T14:34+0800`

## Verdict

`PASS_FOR_ASSEMBLY_INPUT_LOCKED_FLOORS`。

11 输入（10 lane + `r2b-s2-supplement-ac-locked`）已复跑 merger 和 cumulative floor gate：

- rows: `773`
- sample_id: `773 unique / duplicate 0 / missing 0`
- cumulative locked floor gate: `GREEN`
- global contrastive: `144/140` groups, `301/280` rows
- `set_interface_vs_defog`: `8/8` groups, `17/16` rows
- `airoutlet_wind_direction_windspeed`: `6/6` groups, `12/12` rows
- `query_ac_temperature_vs_adjust`: strict query-side rows `10/10`
- screen floors: `screen_little_vs_number=4/4`, `screen_gear_min_max_vs_number=4/4`
- window floor: `window_to_by_little_number=4/4`

This is a locked-floor assembly input gate, not train-ready, not judge/V-PASS, and not a full W10 family rebalance. W10 family targets remain advisory-red for `ac/window/screen/atmosphere_lamp/seat`.

## Inputs

Supplement source used:

- lane: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s2-supplement-ac-locked`
- candidates sha256: `d06b65ed200c11e34e0d1e2c0b4d24348af2332e7b5201fb2e0646f52cdddd38`
- gate status: `pass`
- gate report sha256: `eea45e0f4d8a1f1005b546ec3e82d80dc9b7b2c2620334c0029882063bdbfac5`
- controller injection receipt sha256: `801d9436f844cf514a76ef7f639ab82bf7abe32e36e9ef4890c404e628cc3bd0`
- injection status: `injected`

Merge outputs:

- combined jsonl: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-full773-final-account/combined-candidates-773.jsonl`
- merge report: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-full773-final-account/merge-reconcile-773.json`
- cumulative floor report: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-full773-final-account/cumulative-floor-773.json`

Hashes:

| artifact | sha256 |
|---|---|
| combined-candidates-773.jsonl | `876413681b56dc532efc4f45fb6382fa8920eb9a4b1bb07eb1d4d253068504b4` |
| merge-reconcile-773.json | `7153e103aff91f6015470fe8e0a6292cee1d124e7ed3b4d9191993394800ec9c` |
| cumulative-floor-773.json | `54eb206726065467ddb0769ac199e4e1a538d341fc3f0e43cd97659adcf47751` |
| merge_r2b_batches.py | `ee1af4884301e514e10631d76c092ee296f40eb30495adf84709a5ba028194bc` |
| r2b-locked-floors.json | `0d4218a65625bbfaa4644f7510f10f4c0c6da2bf84511e86846e04a60ab81fb5` |

## Commands

```bash
/opt/homebrew/opt/python@3.13/bin/python3.13 \
  /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/tools/merge_r2b_batches.py \
  <10 accepted lane dirs> \
  /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s2-supplement-ac-locked \
  --output-jsonl /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-full773-final-account/combined-candidates-773.jsonl \
  --report-json /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-full773-final-account/merge-reconcile-773.json \
  --report-md /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-full773-final-account/merge-reconcile-773.md \
  --order-md /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/batch-package/r2b-full750-batch-order-DRAFT.md
```

stdout:

```text
status=partial_s1_baseline rows=773 sha256=876413681b56dc532efc4f45fb6382fa8920eb9a4b1bb07eb1d4d253068504b4
```

The `partial_s1_baseline` label is historical tool wording for exact full750/S1 checks; it is not used as the verdict for this append-only 773 gate.

```bash
/opt/homebrew/opt/python@3.13/bin/python3.13 \
  /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/tools/merge_r2b_batches.py \
  --cumulative-floor-check \
  --locked-floors-json /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/batch-package/r2b-locked-floors.json \
  --floor-report-json /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-full773-final-account/cumulative-floor-773.json \
  --floor-report-md /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-full773-final-account/cumulative-floor-773.md \
  <10 accepted lane dirs> \
  /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s2-supplement-ac-locked
```

stdout:

```text
status=GREEN rows=773 green=12 red=5
```

## 773 Account

Class totals:

| class | observed | full750 baseline | delta |
|---|---:|---:|---:|
| positive | 451 | 440 | +11 |
| query | 88 | 76 | +12 |
| refusal | 46 | 46 | 0 |
| already_state | 62 | 62 | 0 |
| unsupported | 74 | 74 | 0 |
| followup | 52 | 52 | 0 |
| total | 773 | 750 | +23 |

Family totals:

| family | rows | query | no_call | positive+followup |
|---|---:|---:|---:|---:|
| ac | 98 | 44 | 12 | 42 |
| seat | 75 | 0 | 20 | 55 |
| window | 75 | 0 | 22 | 53 |
| door | 75 | 0 | 20 | 55 |
| atmosphere_lamp | 75 | 0 | 18 | 57 |
| screen | 75 | 0 | 22 | 53 |
| volume | 75 | 22 | 14 | 39 |
| wiper | 75 | 0 | 20 | 55 |
| sunroof_sunshade | 75 | 0 | 18 | 57 |
| fragrance | 75 | 22 | 16 | 37 |

Query tools:

| query tool | observed |
|---|---:|
| `query_ac_temperature` | 25 |
| `query_ac_windspeed` | 19 |
| `query_current_volume` | 22 |
| `query_amount_of_fragrance` | 11 |
| `query_mode_of_fragrance` | 11 |

## Cumulative Floor Gate

Blocking locked-required items:

| item | observed | required | status |
|---|---:|---:|---|
| global contrastive groups | 144 | 140 | GREEN |
| global contrastive rows | 301 | 280 | GREEN |
| `set_interface_vs_defog` groups | 8 | 8 | GREEN |
| `set_interface_vs_defog` rows | 17 | 16 | GREEN |
| `airoutlet_wind_direction_windspeed` groups | 6 | 6 | GREEN |
| `airoutlet_wind_direction_windspeed` rows | 12 | 12 | GREEN |
| `query_ac_temperature_vs_adjust` strict query-side rows | 10 | 10 | GREEN |
| `screen_little_vs_number` groups | 4 | 4 | GREEN |
| `screen_gear_min_max_vs_number` groups | 4 | 4 | GREEN |
| `window_to_by_little_number` groups | 4 | 4 | GREEN |

Advisory W10 family target residuals:

| advisory item | group gap | row gap |
|---|---:|---:|
| `__family__:ac` | 10 | 7 |
| `__family__:window` | 6 | 12 |
| `__family__:screen` | 9 | 18 |
| `__family__:atmosphere_lamp` | 5 | 10 |
| `__family__:seat` | 1 | 2 |

These advisory residuals are preserved in the gate report but are not blocking for the locked-floor assembly input gate in this run.

## Non-Claims

- Not train-ready.
- Not DataGate/preflight.
- Not judge/V-PASS.
- No training or model run was performed.

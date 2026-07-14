# C6EvalSpine — S9→S9b→S10→S11 harness

**proof_class**: `local_unit_integration_fixture`  
**status target**: `DONE_LOCAL_EVAL_SPINE_READY_FOR_S8_FANIN`

## What this is

Minimal stdlib-only fixture/dry-run harness for the authority-eval spine:

1. **S9** three-arm manifest + synthetic arm results (base/old/new)
2. **S9b** same-subject exact join aggregate
3. **S10** verdict with thresholds read only from V1 `subject.four_layer_thresholds`
4. **S11** renderer ack with promotion/signoff state separation

## What this is NOT

- Not B2/B3/B4 package DONE
- Not B7 freeze DONE / V1 RATIFIED
- Not real three-arm model scores
- Not C6 acceptance / V-PASS / candidate signed
- Not S8 adapter presence

## Holdout pin (D-127)

| field | value |
|---|---|
| sha256 | `77853caea4598f334fb4a7ed89eafc348746adf333d647306aa94f0b68da2f64` |
| row_count | 61 |
| fixture | `fixtures/holdout/eval-holdout.jsonl` |
| source | run-dir `s9-eval-freeze/holdout/eval-holdout.jsonl` |

## Commands

```bash
python3 -B scripts/test_check_c6_eval_spine.py
python3 -B scripts/check_c6_eval_spine.py --fixture-replay
python3 -B scripts/check_c6_eval_spine.py --stage s9 --mode real   # must BLOCK/FAIL without new adapter
```

## Threshold law

Thresholds are loaded from:

`contracts/c6-active-authority/authority.v1.candidate.json` → `subject.four_layer_thresholds`

Any embedded second set → `E_THRESHOLD_REINVENT`.

## Residual (always honest)

- `missing_s8_adapter`
- `missing_t01_t02_ratification`
- `no_real_three_arm_scores`

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

- Exactly the four keys `golden` / `demo_fuzz` / `unsupported` / `safety` are required (`E_THRESHOLD_INCOMPLETE` on missing/extra/malformed). **Never** synthesize a default threshold for an absent layer.
- Any embedded second set → `E_THRESHOLD_REINVENT`.
- `demo_fuzz` formula is bound to the canonical `5*pass >= 4*eligible` only (`E_V1_FORMULA_DRIFT` otherwise; e.g. `4*pass >= 3*eligible` is rejected).

## Fail-closed bindings (REAL)

| binding | rule | code |
|---|---|---|
| V1 digest | REAL mismatch cannot PASS/seal S9–S10 | `E_V1_DIGEST_MISMATCH` |
| Holdout three-way | pin == subject == loaded artifact (sha + row_count) | `E_HOLDOUT_THREE_WAY_MISMATCH` |
| Case set | Authoritative IDs **always** from `verify_holdout()` / D-127 pin; receipt `expected_case_ids` is assertion-only (absent/dup/extra/missing/reorder ≠ auth → fail). REAL requires exact 61-id set per arm; empty always fails; fixture subset only if `fixture_subset=true` and ids ⊆ auth set; REAL never subsets | `E_CASESET_INCOMPLETE` |
| S9 seal | `sealed=true` only when the result set itself satisfies the authoritative caseset contract; fixture subsets seal fixture-only claims only | `E_CASESET_INCOMPLETE` |
| Required bindings | Subject/manifest B7 digests, holdout sha/row_count, V1 digest/status, repo/mode/contract/scorer must be present and pin-matched before evaluation (missing ≠ skip) | `E_BINDING_MISSING` / `E_B7_DIGEST_MISMATCH` |
| S9b status whitelist | REAL S10 may PASS only when `s9b.status == "PASS"`; `BLOCKED`/`NOT_RUN`/`UNKNOWN`/missing/other fail closed | `E_S9B_STATUS_NOT_PASS` |
| Result provenance | `real_model` results must bind arm descriptor score_class/status + artifact sha + scorer + mode | `E_RESULT_PROVENANCE_MISMATCH` |

## Residual (always honest; dispatch enum only)

Machine residual enum (exact, still true for local harness):

- `missing_s8_adapter`
- `no_real_three_arm_scores`

**Not residual:** `missing_t01_t02_ratification` — D-147 already satisfied t01/t02 **decision** ratification.

## Authority materialization pending (not residual enum)

Separate structure `authority_materialization_pending` tracks execution/artifact work still open:

- B7 freeze execution / canonical receipt
- V1 CANDIDATE→RATIFIED artifact / operator ceremony

This is **not** a residual enum member and **does not** claim decision-layer t01/t02 missing.

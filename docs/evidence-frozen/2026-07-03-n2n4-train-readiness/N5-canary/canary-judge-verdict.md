# N5 Canary Formal Judge Verdict

Reviewer: `%43` OpenAI-family judge
Mode: formal N5 canary data-quality judge
Proof class: local/static artifact inspection
Source canary: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/canary-anthropic-opus.jsonl`
Rows scored JSONL: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/canary-judge-rows.jsonl`
Source sha256 observed: `9045d9c84aced4210069f43af88d0950757665f791cdfd029173c4ccb772b8b9`

## Verdict

**CANARY_FAIL**

Primary reason: the canary generation receipt declares generated rows cloned template surface/digest/meta and changed `arguments` values, but provides no per-row value-changed registration table (`old template value -> new canary value`) and no exact template row pointer such as `template_sample_id`. Under D9/A12 this makes all non-empty-argument value rows un-auditable against parent/template consistency.

This is not a DataGate failure. DataGate is green, but the human judge gate is stricter than surface mechanics.

## Evidence Inputs

- `canary-datagate/c5-data-gate-receipt.md`: `status: data_gate_ready`, `row_count: 60`, `missing_surface_count: 0`, `surface_field_pass: 60`, `redaction_status: pass`, failures none.
- `diversity-report.md`: status `PASS`, record_count 60, near-duplicate pairs >=0.85 = 0, all 11 groups group-diversity PASS.
- `canary-generation-receipt.md`: states all surface/digest/meta fields were preserved, only `sample_id`, `input_zh`, `tool_call.arguments`, and generator fields changed; also states digest fields were not recomputed.
- Value-changed ledger present: `false`. Receipt has aggregate value distribution only, not a row-level old/new table.

## Aggregate Score

- Total rows: 60
- Row PASS across all active dimensions D1-D9 + A10-A13: 7/60 (11.7%)
- Row FAIL: 53/60
- Original rubric D1-D9 all-PASS rows: 7/60 (11.7%)
- D5 leakage fails: 0
- D6 redaction fails: 0
- Non-empty argument rows: 43; D9 ledger/provenance fails: 43
- Exact L1-style anchor rows flagged by D8: 10/60 (16.7%); calibration cap was 15%, so this is a secondary warning/fail slice, not the main blocker.

## Dimension Distribution

| Dimension | PASS | FAIL | Read |
|---|---:|---:|---|
| `D1_naturalness` | 59 | 1 | 59 natural rows pass; `canary-anth-0034` fails for non-natural color token `品色`. |
| `D2_semantic_consistency` | 60 | 0 | Pass by static inspection and supporting receipts. |
| `D3_value_domain` | 60 | 0 | Pass by static inspection and supporting receipts. |
| `D4_polarity` | 60 | 0 | Pass by static inspection and supporting receipts. |
| `D5_protocol_leakage` | 60 | 0 | No exact function name, JSON, or tool_call leakage in user text. |
| `D6_redaction` | 60 | 0 | No redline/customer/supplier/model-code/PII token found. |
| `D7_duplicate_diversity` | 60 | 0 | Pass by static inspection and supporting receipts. |
| `D8_L2_positioning` | 50 | 10 | Short exact L1 command anchors slightly exceed calibration cap. |
| `D9_template_parent_consistency` | 17 | 43 | Fails every non-empty-argument row because value mutation ledger is absent. |
| `A10_input_channel_eligibility` | 60 | 0 | Pass by static inspection and supporting receipts. |
| `A11_mounted_surface_closure` | 60 | 0 | Pass by static inspection and supporting receipts. |
| `A12_judgeability_provenance` | 17 | 43 | Same hard provenance gap as D9 for mutated value rows. |
| `A13_aggregate_polarity_coverage` | 60 | 0 | Receipt shows open/close and raise/lower symmetry, one-way color group declared. |

## Group Results

| subset_group_id | PASS | FAIL | Notes |
|---|---:|---:|---|
| `ac_cooling_mode` | 1 | 3 | fails are driven by D9/A12 on rows with non-empty args |
| `ac_temperature` | 0 | 8 | fails are driven by D9/A12 on rows with non-empty args |
| `ac_windspeed` | 3 | 3 | fails are driven by D9/A12 on rows with non-empty args |
| `atmosphere_lamp` | 0 | 4 | fails are driven by D9/A12 on rows with non-empty args |
| `atmosphere_lamp_color` | 0 | 6 | fails are driven by D9/A12 on rows with non-empty args; also includes D1 fail on `canary-anth-0034` (`品色`) |
| `fragrance` | 1 | 3 | fails are driven by D9/A12 on rows with non-empty args |
| `seat.heat` | 1 | 3 | fails are driven by D9/A12 on rows with non-empty args |
| `seat.massage_force_time` | 1 | 5 | fails are driven by D9/A12 on rows with non-empty args |
| `sunroof` | 0 | 6 | fails are driven by D9/A12 on rows with non-empty args |
| `volume` | 0 | 6 | fails are driven by D9/A12 on rows with non-empty args |
| `window` | 0 | 6 | fails are driven by D9/A12 on rows with non-empty args |

## Notable Row Findings

- `canary-anth-0034`: D1 FAIL. `前排氛围灯弄成品色` has a malformed/nonstandard color phrase; D3 still passes because the mounted schema accepts free-form `value` SPOT.
- All non-empty-argument rows: D9 + A12 FAIL due absent per-row value-changed ledger. Empty-argument rows can pass D9 because no changed value needs parent/template audit.
- Exact L1 anchors: `canary-anth-0001`, `0021`, `0025`, `0028`, `0037`, `0039`, `0041`, `0044`, `0053`, `0057` fail D8 row-level L2 value. They are useful polarity anchors, but the aggregate ratio is just over the calibrated 15% cap.

## Calibration Carry-Forward

Calibration report integrated: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/judge-calibration-report.md`.

The rehearsal split remains valid: protocol controls fail D1/A10/D7/D8 while mechanical dimensions pass; formal canary rows here mostly pass naturalness/surface/value-domain/leakage, but D9/A12 must block expansion when generated argument values cannot be audited against exact template parents.

## Expansion Decision

`CANARY_FAIL`: do not expand from this canary artifact as-is.

Required minimal repair before rejudge: add a per-row value-changed registration table or fields that identify the exact source template row and every changed argument value (`sample_id`, `template_sample_id`, `tool_name`, `arg_key`, `old_value`, `new_value`, `why_changed`, `schema_check`). Then rerun DataGate and this judge.

## Files Written

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/canary-judge-verdict.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/canary-judge-rows.jsonl`

## Re-judge v2

Reviewer: `%43` OpenAI-family judge  
Mode: scoped re-judge after generator repair  
Proof class: local/static artifact inspection  
Source canary rev2 sha256: `3ef37e02de67c9f8697a816e7d679c3d9a5246b7c1ef388a57597220a7070d78`

**Verdict: `CANARY_PASS_EXPAND_OK`**

Scope applied exactly as requested:

- D9/A12 full ledger audit over all 60 rows.
- Content re-check only for changed rows: `canary-anth-0025`, `0034`, `0044`, `0057`.
- D8 exact-L1 cap recomputed over all 60 rows.
- DataGate v2 and diversity v2 receipts reviewed as supporting gates.

### v2 Evidence

| Check | Result |
|---|---|
| `canary-value-ledger.jsonl` line count | PASS: 60 rows, unique sample set matches canary 60/60 |
| `template_sample_id` coverage | PASS: 60/60 non-empty and all found in N4A 4,500-row template file |
| `value_changed` count | PASS: 31 true / 29 false, matching generation receipt |
| `template_args` audit | PASS: 60/60 ledger template args equal source template row args |
| `canary_args` audit | PASS: 60/60 ledger canary args equal actual `expected_tool_calls[0].arguments` |
| `args_diff` audit | PASS: 60/60 ledger diff equals recomputed old/new diff |
| parent/tool surface | PASS: 60/60 template row tool name and `subset_group_id` match ledger/canary |
| parent value-domain / mounted schema | PASS: 0 schema errors against template/canary mounted tool schemas; ledger `schema_check=pass` for 60/60 |
| DataGate v2 | PASS: `status=data_gate_ready`, `row_count=60`, `missing_surface_count=0`, `surface_field_pass=60`, `redaction_status=pass`, failures none |
| D5/D6 | PASS: no protocol/tool-call leakage hits and no redline/PII hits |

### Content Re-check

| sample_id | revised input | tool(args) | Judge read |
|---|---|---|---|
| `canary-anth-0025` | `帮我把车窗降下来透口气` | `open_window({})` | PASS: natural L2-ish window-open request; "降下来" is valid car-window open/down wording. |
| `canary-anth-0034` | `前排氛围灯调成琥珀色` | `switch_atmosphere_lamp_color({"position":"前排","value":"琥珀色"})` | PASS: D1 fix removes malformed `品色`; semantic/value surface is coherent. |
| `canary-anth-0044` | `有点冷了，天窗合上吧` | `close_sunroof({})` | PASS: natural context + close polarity. |
| `canary-anth-0057` | `车里味儿闷，来点香氛吧` | `open_fragrance({})` | PASS: natural context + open fragrance intent. |

D8 recalculation:

- Remaining exact L1 anchor rows: `canary-anth-0001`, `0021`, `0028`, `0037`, `0039`, `0041`, `0053`.
- Count: 7/60 = 11.7%, below the calibrated 15% cap.
- Row-level all-active-dimension pass under v2 scope: 53/60 = 88.3%, above the 85% canary threshold.

### Diversity v2 WARN Disposition

`diversity-report-v2.md` is `WARN` only for length bandwidth: `p90-p10=5.1 < 6`. Near-duplicate pairs remain 0, severe pairs remain 0, and every group has unique ratio 1.0 with group diversity PASS.

I accept the commander disposition for this canary: record the WARN and fold it into expansion-batch generation requirements rather than churn this 60-row canary again. This WARN does not block `CANARY_PASS_EXPAND_OK` because it is not a semantic, leakage, redaction, mounted-surface, D9/A12, or near-duplicate failure. It should remain a hardening requirement for 4.5k expansion batches.

### Expansion Decision

`CANARY_PASS_EXPAND_OK`.

Residual conditions for expansion:

- Keep `canary-value-ledger.jsonl` as required evidence for every changed-value row pattern.
- In expansion batches, make length-bandwidth diversity a generation constraint, not just a post-hoc warning.
- Continue full mechanical gates for D5/D6/A10/A11/A12 structural checks and sampled LLM judge for semantic D1/D2/D4/D8/D9-parent-match.

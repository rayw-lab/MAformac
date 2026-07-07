# C5 data gate receipt

status: blocked
receipt_version: c5-data-gate.v1
generated_at: 2026-07-03T02:53:44Z
source_snapshot_digest: 1018eeeb6f64654d013afafe8c0d57cfed2522b827c8d24ad50d5a0c25c94d0d
source_authorization_status: authorized_c1_semantic_contract
format_contract_version: 0bc0403464b9953d50cd159fc05678d010cbcb4b2ec50688a5e1e8a53e1037ff

## Counts
- row_count: 4511
- bucket_counts: dev_selection=400, train=4111
- quarantine_count: 0
- must_not_train_violations: 0
- detected_parent_semantic_overlap_count: 0
- train_parent_semantic_overlap: 0
- train_held_out_axis_overlap_count: 0
- train_held_out_axis_overlap_row_count: 0
- tool_call_format_pass: 3700
- tool_call_format_failures: 0
- allow_legacy_missing_surface: false
- missing_surface_count: 36
- legacy_missing_surface_allowed_count: 0
- surface_field_pass: 4475
- redaction_status: pass

## Masking coverage
- function_name: true
- argument_name: true
- argument_value: true
- train_on_turn: true

## Proposed fix
- auto_apply: false
- suggestions: populate tools/mounted_tool_count/subset fields before formal wave-1 data gate, or rerun legacy fixtures with explicit allow_legacy_missing_surface

## Failures
- [P1] c5-nocall-00050 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00051 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00052 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00053 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00054 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00055 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00056 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00057 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00058 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00059 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00060 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00061 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00211 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00212 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00213 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00214 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00215 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00216 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00217 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00218 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00219 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00220 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00221 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00222 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00372 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00373 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00374 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00375 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00376 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00377 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00378 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00379 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00380 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00381 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00382 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
- [P1] c5-nocall-00383 split=train bucket=paired_counterfactual_refusal reason=missing_candidate_surface_fields
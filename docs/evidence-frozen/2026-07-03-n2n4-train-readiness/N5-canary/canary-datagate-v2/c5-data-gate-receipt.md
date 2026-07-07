# C5 data gate receipt

status: data_gate_ready
receipt_version: c5-data-gate.v1
generated_at: 2026-07-03T01:18:35Z
source_snapshot_digest: 1018eeeb6f64654d013afafe8c0d57cfed2522b827c8d24ad50d5a0c25c94d0d
source_authorization_status: authorized_c1_semantic_contract
format_contract_version: 0bc0403464b9953d50cd159fc05678d010cbcb4b2ec50688a5e1e8a53e1037ff

## Counts
- row_count: 60
- bucket_counts: dev_selection=36, train=24
- quarantine_count: 0
- must_not_train_violations: 0
- detected_parent_semantic_overlap_count: 0
- train_parent_semantic_overlap: 0
- train_held_out_axis_overlap_count: 0
- train_held_out_axis_overlap_row_count: 0
- tool_call_format_pass: 24
- tool_call_format_failures: 0
- allow_legacy_missing_surface: false
- missing_surface_count: 0
- legacy_missing_surface_allowed_count: 0
- surface_field_pass: 60
- redaction_status: pass

## Masking coverage
- function_name: true
- argument_name: true
- argument_value: true
- train_on_turn: true

## Proposed fix
- auto_apply: false
- suggestions: []

## Failures
none
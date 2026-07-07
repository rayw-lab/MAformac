# C5 data gate receipt

status: data_gate_ready
receipt_version: c5-data-gate.v1
generated_at: 2026-07-03T08:54:53Z
source_snapshot_digest: f852da3c2969875e7b40b7432a9669153a505eb92512b1573bbda51c8e95620e
source_authorization_status: authorized_c1_semantic_contract_plus_authorized_synthetic_generation
format_contract_version: 0bc0403464b9953d50cd159fc05678d010cbcb4b2ec50688a5e1e8a53e1037ff

## Counts
- row_count: 4750
- bucket_counts: dev_selection=400, train=4350
- quarantine_count: 0
- must_not_train_violations: 0
- detected_parent_semantic_overlap_count: 0
- train_parent_semantic_overlap: 0
- train_held_out_axis_overlap_count: 0
- train_held_out_axis_overlap_row_count: 0
- tool_call_format_pass: 4350
- tool_call_format_failures: 0
- allow_legacy_missing_surface: false
- missing_surface_count: 0
- legacy_missing_surface_allowed_count: 0
- surface_field_pass: 4750
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
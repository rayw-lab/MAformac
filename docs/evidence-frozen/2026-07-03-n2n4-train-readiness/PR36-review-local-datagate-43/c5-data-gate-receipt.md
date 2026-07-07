# C5 data gate receipt

status: data_gate_ready
receipt_version: c5-data-gate.v1
generated_at: 2026-07-03T04:54:14Z
source_snapshot_digest: e3ba4a8d0f7a93b57c02682edfa2760020ee0a851fbdab2f788dcb495c11131c
source_authorization_status: authorized_fixture
format_contract_version: 0bc0403464b9953d50cd159fc05678d010cbcb4b2ec50688a5e1e8a53e1037ff

## Counts
- row_count: 51
- bucket_counts: quarantine=1, train=50
- quarantine_count: 1
- must_not_train_violations: 0
- detected_parent_semantic_overlap_count: 0
- train_parent_semantic_overlap: 0
- train_held_out_axis_overlap_count: 0
- train_held_out_axis_overlap_row_count: 0
- tool_call_format_pass: 50
- tool_call_format_failures: 0
- allow_legacy_missing_surface: false
- missing_surface_count: 0
- legacy_missing_surface_allowed_count: 0
- surface_field_pass: 51
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
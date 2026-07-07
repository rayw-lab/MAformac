# C5 data gate receipt

status: data_gate_ready
receipt_version: c5-data-gate.v1
generated_at: 2026-07-02T18:07:24Z
source_snapshot_digest: 23dc89ed1661ea3eff5b4f1da5b85dc19e90aaeec3a630d0b367383f646d54f2
source_authorization_status: authorized_c1_semantic_contract
format_contract_version: 0bc0403464b9953d50cd159fc05678d010cbcb4b2ec50688a5e1e8a53e1037ff

## Counts
- row_count: 4500
- bucket_counts: dev_selection=400, train=4100
- quarantine_count: 0
- must_not_train_violations: 0
- detected_parent_semantic_overlap_count: 0
- train_parent_semantic_overlap: 0
- train_held_out_axis_overlap_count: 0
- train_held_out_axis_overlap_row_count: 0
- tool_call_format_pass: 4100
- tool_call_format_failures: 0
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
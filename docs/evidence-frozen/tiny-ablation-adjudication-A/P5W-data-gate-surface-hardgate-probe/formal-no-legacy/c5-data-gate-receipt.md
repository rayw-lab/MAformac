# C5 data gate receipt

status: blocked
receipt_version: c5-data-gate.v1
generated_at: 2026-07-02T17:59:15Z
source_snapshot_digest: ed1a2f45c0a49773d0f8de87e29f7db0ca5fe43af83ef360a58154617b6c838f
source_authorization_status: authorized_probe
format_contract_version: 0bc0403464b9953d50cd159fc05678d010cbcb4b2ec50688a5e1e8a53e1037ff

## Counts
- row_count: 1
- bucket_counts: train=1
- quarantine_count: 0
- must_not_train_violations: 0
- detected_parent_semantic_overlap_count: 0
- train_parent_semantic_overlap: 0
- train_held_out_axis_overlap_count: 0
- train_held_out_axis_overlap_row_count: 0
- tool_call_format_pass: 1
- tool_call_format_failures: 0
- allow_legacy_missing_surface: false
- missing_surface_count: 1
- legacy_missing_surface_allowed_count: 0
- surface_field_pass: 0
- redaction_status: pass

## Masking coverage
- function_name: false
- argument_name: false
- argument_value: false
- train_on_turn: false

## Proposed fix
- auto_apply: false
- suggestions: populate tools/mounted_tool_count/subset fields before formal wave-1 data gate, or rerun legacy fixtures with explicit allow_legacy_missing_surface

## Failures
- [P1] P5W-MISSING-SURFACE split=train bucket=tool_call_wrapper_format reason=missing_candidate_surface_fields
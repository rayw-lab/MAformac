# C5 data gate receipt

status: blocked
receipt_version: c5-data-gate.v1
generated_at: 2026-07-03T05:37:24Z
source_snapshot_digest: 6108274579486849809e91850f7cd80cf3e06a94dd2fd2e545ec64e29aaa1381
source_authorization_status: authorized_wave1_warmup_generation
format_contract_version: 0bc0403464b9953d50cd159fc05678d010cbcb4b2ec50688a5e1e8a53e1037ff

## Counts
- row_count: 50
- bucket_counts: train=50
- quarantine_count: 0
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
- surface_field_pass: 0
- redaction_status: pass

## Masking coverage
- function_name: true
- argument_name: true
- argument_value: false
- train_on_turn: true

## Proposed fix
- auto_apply: false
- suggestions: rebuild mounted tool surface from subset manifest/catalog and keep tool_name, mounted_tool_count, subset digests, and tool_schema_digest same-source

## Failures
- [P1] warmup-batch-01-subcc-1-0001 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0002 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0003 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0004 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0005 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0006 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0007 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0008 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0009 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0010 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0011 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0012 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0013 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0014 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0015 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0016 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0017 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0018 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0019 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0020 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0021 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0022 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0023 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0024 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0025 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0026 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0027 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0028 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0029 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0030 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0031 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0032 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0033 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0034 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0035 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0036 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0037 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0038 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0039 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0040 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0041 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0042 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0043 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0044 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0045 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0046 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0047 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0048 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0049 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
- [P1] warmup-batch-01-subcc-1-0050 split=train bucket=gate7_candidate reason=tool_schema_digest_mismatch
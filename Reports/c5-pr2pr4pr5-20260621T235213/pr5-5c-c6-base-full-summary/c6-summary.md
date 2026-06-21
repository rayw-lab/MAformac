# C6 vehicle-tool-bench summary

status: hard_fail
model_id: mlx-community/Qwen3-1.7B-4bit
model_artifact_digest: 0e86d9677e519323849eac1bc272caae88567a481ff188c431f70be543d9995f
tokenizer_digest: aeb13307a71acd8fe81861d94ad54ab689df773318809eed3cbe794b4492dae4
lora_adapter_id: ""
lora_checkpoint_id: ""
lora_adapter_digest: ""
qwen_tool_call_format_version: 630281ed49f2acb7a04a1823909fd907031b7ba29d606e88f326c1e0bb93d53b
contract_digest: f8067fb64fab5bb768d5746b8484be7134a6c93f29ef16de2228a0217ec95180

## Dataset
- cases: 57
- no_call_negative_ratio: 0.404
- source_refs_unresolved: 0
- must_pass: 42
- represented_devices: 10/671

## Gates
- total_runs: 57
- hard_failure_count: 50
- no_tool_false_positive_count: 6
- IrrelAcc: 0.739 / threshold 0.90

## Axes
- contract_coverage_score: 0.0149
- scenario_score: 0.0000

## Per-case mean/variance
- C6-COV-001: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=553.0, elapsed_variance_ms=0.0
- C6-COV-002: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=626.0, elapsed_variance_ms=0.0
- C6-COV-003: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=546.0, elapsed_variance_ms=0.0
- C6-COV-004: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=636.0, elapsed_variance_ms=0.0
- C6-COV-005: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=601.0, elapsed_variance_ms=0.0
- C6-COV-006: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=531.0, elapsed_variance_ms=0.0
- C6-COV-007: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=627.0, elapsed_variance_ms=0.0
- C6-MP-001: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=521.0, elapsed_variance_ms=0.0
- C6-MP-002: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=760.0, elapsed_variance_ms=0.0
- C6-MP-003: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=608.0, elapsed_variance_ms=0.0
- C6-MP-004: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=552.0, elapsed_variance_ms=0.0
- C6-MP-005: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=522.0, elapsed_variance_ms=0.0
- C6-MP-006: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=631.0, elapsed_variance_ms=0.0
- C6-MP-007: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=694.0, elapsed_variance_ms=0.0
- C6-MP-008: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=563.0, elapsed_variance_ms=0.0
- C6-MP-009: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=561.0, elapsed_variance_ms=0.0
- C6-MP-010: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=626.0, elapsed_variance_ms=0.0
- C6-MP-011: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=626.0, elapsed_variance_ms=0.0
- C6-MP-012: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=569.0, elapsed_variance_ms=0.0
- C6-MP-013: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=626.0, elapsed_variance_ms=0.0
- C6-MP-014: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=636.0, elapsed_variance_ms=0.0
- C6-MP-015: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=609.0, elapsed_variance_ms=0.0
- C6-MP-016: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=618.0, elapsed_variance_ms=0.0
- C6-MP-017: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=532.0, elapsed_variance_ms=0.0
- C6-MP-018: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=627.0, elapsed_variance_ms=0.0
- C6-MP-019: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=627.0, elapsed_variance_ms=0.0
- C6-MP-020: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=638.0, elapsed_variance_ms=0.0
- C6-MP-021: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=638.0, elapsed_variance_ms=0.0
- C6-MP-022: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=616.0, elapsed_variance_ms=0.0
- C6-MP-023: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=573.0, elapsed_variance_ms=0.0
- C6-MP-024: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=599.0, elapsed_variance_ms=0.0
- C6-MP-025: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=599.0, elapsed_variance_ms=0.0
- C6-MP-026: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=599.0, elapsed_variance_ms=0.0
- C6-MP-027: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=631.0, elapsed_variance_ms=0.0
- C6-MP-028: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=600.0, elapsed_variance_ms=0.0
- C6-MP-029: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=560.0, elapsed_variance_ms=0.0
- C6-MP-030: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=523.0, elapsed_variance_ms=0.0
- C6-NEG-001: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=379.0, elapsed_variance_ms=0.0
- C6-NEG-002: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=563.0, elapsed_variance_ms=0.0
- C6-NEG-003: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=380.0, elapsed_variance_ms=0.0
- C6-NEG-004: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=380.0, elapsed_variance_ms=0.0
- C6-NEG-005: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=494.0, elapsed_variance_ms=0.0
- C6-NEG-006: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=361.0, elapsed_variance_ms=0.0
- C6-NEG-007: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=474.0, elapsed_variance_ms=0.0
- C6-NEG-008: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=350.0, elapsed_variance_ms=0.0
- C6-TRAP-AMB-001: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=640.0, elapsed_variance_ms=0.0
- C6-TRAP-AMB-002: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=630.0, elapsed_variance_ms=0.0
- C6-TRAP-ASR-001: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=639.0, elapsed_variance_ms=0.0
- C6-TRAP-ASR-002: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=361.0, elapsed_variance_ms=0.0
- C6-TRAP-CORR-001: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=544.0, elapsed_variance_ms=0.0
- C6-TRAP-CORR-002: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=602.0, elapsed_variance_ms=0.0
- C6-TRAP-LURE-001: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=696.0, elapsed_variance_ms=0.0
- C6-TRAP-LURE-002: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=640.0, elapsed_variance_ms=0.0
- C6-TRAP-NEG-001: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=621.0, elapsed_variance_ms=0.0
- C6-TRAP-NEG-002: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=611.0, elapsed_variance_ms=0.0
- C6-TRAP-SAFE-001: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=574.0, elapsed_variance_ms=0.0
- C6-TRAP-SAFE-002: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=630.0, elapsed_variance_ms=0.0
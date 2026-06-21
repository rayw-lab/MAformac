# C6 vehicle-tool-bench summary

status: hard_fail
model_id: mlx-community/Qwen3-1.7B-4bit
model_artifact_digest: 0e86d9677e519323849eac1bc272caae88567a481ff188c431f70be543d9995f
tokenizer_digest: aeb13307a71acd8fe81861d94ad54ab689df773318809eed3cbe794b4492dae4
lora_adapter_id: "pr5-scale20-rank16-a8b5a50c"
lora_checkpoint_id: "iter600"
lora_adapter_digest: "a8b5a50ca08bd3f96b37411f40718568625606985935d09d18eedd88e45b86fc"
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
- hard_failure_count: 42
- no_tool_false_positive_count: 1
- IrrelAcc: 0.957 / threshold 0.90

## Axes
- contract_coverage_score: 0.0149
- scenario_score: 0.0238

## Per-case mean/variance
- C6-COV-001: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=2129.0, elapsed_variance_ms=0.0
- C6-COV-002: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=2130.0, elapsed_variance_ms=0.0
- C6-COV-003: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=2110.0, elapsed_variance_ms=0.0
- C6-COV-004: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=2128.0, elapsed_variance_ms=0.0
- C6-COV-005: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=1830.0, elapsed_variance_ms=0.0
- C6-COV-006: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=2114.0, elapsed_variance_ms=0.0
- C6-COV-007: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=2114.0, elapsed_variance_ms=0.0
- C6-MP-001: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=2110.0, elapsed_variance_ms=0.0
- C6-MP-002: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2116.0, elapsed_variance_ms=0.0
- C6-MP-003: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2112.0, elapsed_variance_ms=0.0
- C6-MP-004: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2109.0, elapsed_variance_ms=0.0
- C6-MP-005: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2125.0, elapsed_variance_ms=0.0
- C6-MP-006: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=1750.0, elapsed_variance_ms=0.0
- C6-MP-007: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2122.0, elapsed_variance_ms=0.0
- C6-MP-008: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2127.0, elapsed_variance_ms=0.0
- C6-MP-009: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=666.0, elapsed_variance_ms=0.0
- C6-MP-010: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2123.0, elapsed_variance_ms=0.0
- C6-MP-011: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2108.0, elapsed_variance_ms=0.0
- C6-MP-012: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=656.0, elapsed_variance_ms=0.0
- C6-MP-013: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2110.0, elapsed_variance_ms=0.0
- C6-MP-014: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2122.0, elapsed_variance_ms=0.0
- C6-MP-015: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2162.0, elapsed_variance_ms=0.0
- C6-MP-016: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=1640.0, elapsed_variance_ms=0.0
- C6-MP-017: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2113.0, elapsed_variance_ms=0.0
- C6-MP-018: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2109.0, elapsed_variance_ms=0.0
- C6-MP-019: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2106.0, elapsed_variance_ms=0.0
- C6-MP-020: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2107.0, elapsed_variance_ms=0.0
- C6-MP-021: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2106.0, elapsed_variance_ms=0.0
- C6-MP-022: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=1635.0, elapsed_variance_ms=0.0
- C6-MP-023: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=1640.0, elapsed_variance_ms=0.0
- C6-MP-024: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2111.0, elapsed_variance_ms=0.0
- C6-MP-025: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2144.0, elapsed_variance_ms=0.0
- C6-MP-026: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2142.0, elapsed_variance_ms=0.0
- C6-MP-027: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2117.0, elapsed_variance_ms=0.0
- C6-MP-028: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2139.0, elapsed_variance_ms=0.0
- C6-MP-029: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2143.0, elapsed_variance_ms=0.0
- C6-MP-030: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2127.0, elapsed_variance_ms=0.0
- C6-NEG-001: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=2128.0, elapsed_variance_ms=0.0
- C6-NEG-002: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=2129.0, elapsed_variance_ms=0.0
- C6-NEG-003: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=2137.0, elapsed_variance_ms=0.0
- C6-NEG-004: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=2135.0, elapsed_variance_ms=0.0
- C6-NEG-005: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=2119.0, elapsed_variance_ms=0.0
- C6-NEG-006: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=2102.0, elapsed_variance_ms=0.0
- C6-NEG-007: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=2105.0, elapsed_variance_ms=0.0
- C6-NEG-008: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=2110.0, elapsed_variance_ms=0.0
- C6-TRAP-AMB-001: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2132.0, elapsed_variance_ms=0.0
- C6-TRAP-AMB-002: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2135.0, elapsed_variance_ms=0.0
- C6-TRAP-ASR-001: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2101.0, elapsed_variance_ms=0.0
- C6-TRAP-ASR-002: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2107.0, elapsed_variance_ms=0.0
- C6-TRAP-CORR-001: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2138.0, elapsed_variance_ms=0.0
- C6-TRAP-CORR-002: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2171.0, elapsed_variance_ms=0.0
- C6-TRAP-LURE-001: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2108.0, elapsed_variance_ms=0.0
- C6-TRAP-LURE-002: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2115.0, elapsed_variance_ms=0.0
- C6-TRAP-NEG-001: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2110.0, elapsed_variance_ms=0.0
- C6-TRAP-NEG-002: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2115.0, elapsed_variance_ms=0.0
- C6-TRAP-SAFE-001: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2108.0, elapsed_variance_ms=0.0
- C6-TRAP-SAFE-002: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=2106.0, elapsed_variance_ms=0.0
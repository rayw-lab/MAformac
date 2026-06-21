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
- total_runs: 5
- hard_failure_count: 1
- no_tool_false_positive_count: 1
- IrrelAcc: 0.800 / threshold 0.90

## Axes
- contract_coverage_score: 0.0149
- scenario_score: 0.0000

## Per-case mean/variance
- C6-COV-001: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=3678.0, elapsed_variance_ms=0.0
- C6-COV-002: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=2100.0, elapsed_variance_ms=0.0
- C6-COV-003: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=2115.0, elapsed_variance_ms=0.0
- C6-COV-004: runs=1, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=2130.0, elapsed_variance_ms=0.0
- C6-COV-005: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=1826.0, elapsed_variance_ms=0.0
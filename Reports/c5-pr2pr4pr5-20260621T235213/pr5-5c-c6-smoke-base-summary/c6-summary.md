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
- total_runs: 5
- hard_failure_count: 5
- no_tool_false_positive_count: 2
- IrrelAcc: 0.600 / threshold 0.90

## Axes
- contract_coverage_score: 0.0149
- scenario_score: 0.0000

## Per-case mean/variance
- C6-COV-001: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=562.0, elapsed_variance_ms=0.0
- C6-COV-002: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=631.0, elapsed_variance_ms=0.0
- C6-COV-003: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=545.0, elapsed_variance_ms=0.0
- C6-COV-004: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=633.0, elapsed_variance_ms=0.0
- C6-COV-005: runs=1, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=601.0, elapsed_variance_ms=0.0
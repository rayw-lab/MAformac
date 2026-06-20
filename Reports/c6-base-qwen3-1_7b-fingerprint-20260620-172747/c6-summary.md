# C6 vehicle-tool-bench summary

status: hard_fail
model_id: mlx-community/Qwen3-1.7B-4bit
model_artifact_digest: 0e86d9677e519323849eac1bc272caae88567a481ff188c431f70be543d9995f
tokenizer_digest: aeb13307a71acd8fe81861d94ad54ab689df773318809eed3cbe794b4492dae4
lora_adapter_id: ""
lora_checkpoint_id: ""
lora_adapter_digest: ""
qwen_tool_call_format_version: 630281ed49f2acb7a04a1823909fd907031b7ba29d606e88f326c1e0bb93d53b
contract_digest: cbb79c411ea5deb8cf8d8063a9aa4d75dcad2da29737443506248b5561260759

## Dataset
- cases: 45
- no_call_negative_ratio: 0.422
- source_refs_unresolved: 0
- must_pass: 30
- represented_devices: 9/671

## Gates
- total_runs: 225
- hard_failure_count: 190
- no_tool_false_positive_count: 20
- IrrelAcc: 0.789 / threshold 0.90

## Axes
- contract_coverage_score: 0.0134
- scenario_score: 0.0000

## Per-case mean/variance
- C6-COV-001: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=668.2, elapsed_variance_ms=1504.6
- C6-COV-002: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=766.0, elapsed_variance_ms=1989.6
- C6-COV-003: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=655.2, elapsed_variance_ms=824.6
- C6-COV-004: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=760.8, elapsed_variance_ms=622.2
- C6-COV-005: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=727.4, elapsed_variance_ms=826.6
- C6-COV-006: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=663.6, elapsed_variance_ms=485.0
- C6-COV-007: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=786.6, elapsed_variance_ms=1293.0
- C6-MP-001: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=636.8, elapsed_variance_ms=2132.2
- C6-MP-002: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=938.6, elapsed_variance_ms=2196.2
- C6-MP-003: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=742.4, elapsed_variance_ms=1059.4
- C6-MP-004: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=677.6, elapsed_variance_ms=1363.4
- C6-MP-005: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=640.2, elapsed_variance_ms=1776.6
- C6-MP-006: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=751.0, elapsed_variance_ms=620.8
- C6-MP-007: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=836.6, elapsed_variance_ms=1494.2
- C6-MP-008: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=685.6, elapsed_variance_ms=1805.0
- C6-MP-009: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=689.2, elapsed_variance_ms=1350.6
- C6-MP-010: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=776.0, elapsed_variance_ms=1633.6
- C6-MP-011: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=762.4, elapsed_variance_ms=1620.2
- C6-MP-012: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=702.0, elapsed_variance_ms=944.0
- C6-MP-013: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=764.8, elapsed_variance_ms=2197.4
- C6-MP-014: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=788.2, elapsed_variance_ms=1974.2
- C6-MP-015: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=748.8, elapsed_variance_ms=3233.8
- C6-MP-016: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=797.0, elapsed_variance_ms=5596.8
- C6-MP-017: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=671.2, elapsed_variance_ms=2320.2
- C6-MP-018: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=778.8, elapsed_variance_ms=3815.0
- C6-MP-019: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=777.8, elapsed_variance_ms=4111.8
- C6-MP-020: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=785.4, elapsed_variance_ms=4025.0
- C6-MP-021: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=767.0, elapsed_variance_ms=1701.2
- C6-MP-022: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=742.2, elapsed_variance_ms=1008.2
- C6-MP-023: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=698.0, elapsed_variance_ms=1306.0
- C6-MP-024: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=717.2, elapsed_variance_ms=683.0
- C6-MP-025: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=703.6, elapsed_variance_ms=1278.6
- C6-MP-026: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=723.4, elapsed_variance_ms=1513.8
- C6-MP-027: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=753.2, elapsed_variance_ms=114.2
- C6-MP-028: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=713.6, elapsed_variance_ms=398.2
- C6-MP-029: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=677.2, elapsed_variance_ms=191.0
- C6-MP-030: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=631.0, elapsed_variance_ms=426.0
- C6-NEG-001: runs=5, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=459.0, elapsed_variance_ms=327.6
- C6-NEG-002: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=674.4, elapsed_variance_ms=1217.8
- C6-NEG-003: runs=5, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=452.4, elapsed_variance_ms=289.8
- C6-NEG-004: runs=5, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=459.6, elapsed_variance_ms=479.4
- C6-NEG-005: runs=5, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=590.4, elapsed_variance_ms=685.8
- C6-NEG-006: runs=5, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=445.0, elapsed_variance_ms=974.8
- C6-NEG-007: runs=5, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=576.4, elapsed_variance_ms=871.4
- C6-NEG-008: runs=5, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=424.6, elapsed_variance_ms=728.6
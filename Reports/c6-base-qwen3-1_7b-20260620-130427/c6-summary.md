# C6 vehicle-tool-bench summary

status: hard_fail
model_id: mlx-community/Qwen3-1.7B-4bit
lora_adapter_id: ""
lora_checkpoint_id: ""
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
- hard_failure_count: 170
- no_tool_false_positive_count: 20
- IrrelAcc: 0.789 / threshold 0.90

## Axes
- contract_coverage_score: 0.0134
- scenario_score: 0.1333

## Per-case mean/variance
- C6-COV-001: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=629.0, elapsed_variance_ms=2189.2
- C6-COV-002: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=731.8, elapsed_variance_ms=4754.2
- C6-COV-003: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=632.0, elapsed_variance_ms=2382.8
- C6-COV-004: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=737.4, elapsed_variance_ms=2833.0
- C6-COV-005: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=692.0, elapsed_variance_ms=2342.8
- C6-COV-006: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=629.2, elapsed_variance_ms=2486.2
- C6-COV-007: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=742.0, elapsed_variance_ms=3360.8
- C6-MP-001: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=638.8, elapsed_variance_ms=2041.8
- C6-MP-002: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=919.8, elapsed_variance_ms=5705.8
- C6-MP-003: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=725.4, elapsed_variance_ms=4142.6
- C6-MP-004: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=651.6, elapsed_variance_ms=3299.4
- C6-MP-005: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=616.6, elapsed_variance_ms=2369.4
- C6-MP-006: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=742.6, elapsed_variance_ms=4867.0
- C6-MP-007: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=818.0, elapsed_variance_ms=4878.8
- C6-MP-008: runs=5, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=667.6, elapsed_variance_ms=3529.8
- C6-MP-009: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=685.2, elapsed_variance_ms=3339.0
- C6-MP-010: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=746.4, elapsed_variance_ms=3961.0
- C6-MP-011: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=738.0, elapsed_variance_ms=3785.2
- C6-MP-012: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=665.0, elapsed_variance_ms=2832.0
- C6-MP-013: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=748.6, elapsed_variance_ms=4076.2
- C6-MP-014: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=766.6, elapsed_variance_ms=3544.6
- C6-MP-015: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=733.0, elapsed_variance_ms=3439.2
- C6-MP-016: runs=5, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=739.0, elapsed_variance_ms=2621.6
- C6-MP-017: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=637.8, elapsed_variance_ms=1413.8
- C6-MP-018: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=746.2, elapsed_variance_ms=2479.8
- C6-MP-019: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=755.0, elapsed_variance_ms=2376.0
- C6-MP-020: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=752.0, elapsed_variance_ms=2891.2
- C6-MP-021: runs=5, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=766.8, elapsed_variance_ms=3767.8
- C6-MP-022: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=745.0, elapsed_variance_ms=3941.2
- C6-MP-023: runs=5, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=674.0, elapsed_variance_ms=2955.6
- C6-MP-024: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=709.0, elapsed_variance_ms=2591.6
- C6-MP-025: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=714.2, elapsed_variance_ms=2934.6
- C6-MP-026: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=738.4, elapsed_variance_ms=7037.8
- C6-MP-027: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=751.0, elapsed_variance_ms=4417.2
- C6-MP-028: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=713.4, elapsed_variance_ms=4187.8
- C6-MP-029: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=661.2, elapsed_variance_ms=3035.8
- C6-MP-030: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=619.4, elapsed_variance_ms=2337.0
- C6-NEG-001: runs=5, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=442.0, elapsed_variance_ms=1018.8
- C6-NEG-002: runs=5, hard_pass_mean=0.000, hard_pass_variance=0.000, elapsed_mean_ms=682.2, elapsed_variance_ms=3213.4
- C6-NEG-003: runs=5, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=449.6, elapsed_variance_ms=1445.8
- C6-NEG-004: runs=5, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=448.4, elapsed_variance_ms=974.2
- C6-NEG-005: runs=5, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=597.8, elapsed_variance_ms=2290.2
- C6-NEG-006: runs=5, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=431.6, elapsed_variance_ms=1255.4
- C6-NEG-007: runs=5, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=589.8, elapsed_variance_ms=1384.2
- C6-NEG-008: runs=5, hard_pass_mean=1.000, hard_pass_variance=0.000, elapsed_mean_ms=410.2, elapsed_variance_ms=1400.6
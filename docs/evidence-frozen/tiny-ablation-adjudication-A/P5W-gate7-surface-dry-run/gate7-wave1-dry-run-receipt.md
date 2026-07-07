# Gate7 wave-1 mock dry-run receipt

- generated_at: 2026-07-02T17:37:42Z
- proof_class: local_mock
- repo_root: /Users/wanglei/workspace/MAformac-p5w-wave1-bridge
- target_contract_row_id: c1_airControl_000167
- target_tool_name: adjust_ac_temperature_to_number
- generator_vendor: anthropic
- judge_vendor: openai
- requested_limit: 20
- pipeline_status: PASS
- sample_count: 20
- first_expected_tool_call: adjust_ac_temperature_to_number ["adjustment_mode": "摄氏度", "temperature": "22", "mode": "制冷", "direction": "主驾"]
- data_gate_status: data_gate_ready
- data_gate_row_count: 21
- quarantine_count: 1
- candidate_rows_path: gate7-wave1-candidates.jsonl
- candidate_row_count: 21
- rows_with_tools: 21
- rows_with_mounted_tool_count: 21
- rows_with_subset_policy_id: 21
- rows_with_subset_group_id: 21
- rows_with_subset_policy_digest: 21
- mounted_tool_count: 22
- subset_policy_id: e2-lite-v1
- subset_group_id: scene.scene1
- subset_policy_digest: c72329fce65678a72d95319d618570469ce3149cb96a092fe59e9a6cc7c0c530
- data_gate_hard_failure: false
- data_gate_failure_reasons: []

Boundary: mock provider only; no live cloud generation and no training.
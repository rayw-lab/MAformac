# RECEIPT-P3H

status: local_adapter_only_probe_complete
proof_class: local
output_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/TD-eval-r3train-ready/over-refusal-t1/probe-output-d087-true-query-guard

## Decode Contract

```json
{
  "temperature": 0.0,
  "max_tokens": 160,
  "stop_tokens": [
    "</tool_call>",
    "\n",
    "\n\n",
    "\r\n"
  ],
  "tokenizer_wrapper": "mlx_lm_tokenizer_wrapper",
  "prompt_skeleton_id": "qwen3_patched_no_think_chat_template",
  "thinking": "no_think_block",
  "parser_id": "p3h_tool_call_json_ordered_v2",
  "tool_call_cardinality": "ordered_multi_call",
  "output_boundary": "raw_generation_and_truncated_output",
  "tools_mount_policy": "p3h_v3_training_row_or_e2_sg_catalog"
}
```

## Paired Summary

```json
{}
```

## Overlap Summary

```json
{
  "case_count": 10,
  "per_case_tool_overlap_count": 10,
  "unique_expected_tool_overlap_count": 5,
  "unique_expected_tool_count": 5,
  "expected_calls_overlap_count": 10,
  "expected_calls_count": 10,
  "utterance_overlap_count": 10,
  "natural_vs_protocol": {
    "natural": 10,
    "protocol": 0
  },
  "per_case": [
    {
      "case_id": "r3-qguard-ac_temperature-001",
      "expected_tool_names": [
        "query_ac_temperature"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "r3-qguard-ac_temperature-002",
      "expected_tool_names": [
        "query_ac_temperature"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "r3-qguard-ac_windspeed-001",
      "expected_tool_names": [
        "query_ac_windspeed"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "r3-qguard-ac_windspeed-002",
      "expected_tool_names": [
        "query_ac_windspeed"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "r3-qguard-current_volume-001",
      "expected_tool_names": [
        "query_current_volume"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "r3-qguard-current_volume-002",
      "expected_tool_names": [
        "query_current_volume"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "r3-qguard-amount_of_fragrance-001",
      "expected_tool_names": [
        "query_amount_of_fragrance"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "r3-qguard-amount_of_fragrance-002",
      "expected_tool_names": [
        "query_amount_of_fragrance"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "r3-qguard-mode_of_fragrance-001",
      "expected_tool_names": [
        "query_mode_of_fragrance"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "r3-qguard-mode_of_fragrance-002",
      "expected_tool_names": [
        "query_mode_of_fragrance"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "natural"
    }
  ]
}
```

## Tools Mount Policy

`p3h_v3_training_row_or_e2_sg_catalog`. A/B axes mount exact training-row tools; C/D axes mount generated catalog `_sg` groups for expected tools. Per-case JSON records include `mounted_tool_count`, `mounted_tool_names`, `mount_source`, and `mount_policy`.

## Non Claims

- This receipt does not claim training, C6 acceptance, candidate comparison, V-PASS, S-PASS, or U-PASS.
- Real model probe requires an environment with mlx_lm and explicit run authorization.

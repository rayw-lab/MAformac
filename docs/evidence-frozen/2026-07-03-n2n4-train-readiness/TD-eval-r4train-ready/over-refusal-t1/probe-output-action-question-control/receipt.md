# RECEIPT-P3H

status: local_adapter_only_probe_complete
proof_class: local
output_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/TD-eval-r4train-ready/over-refusal-t1/probe-output-action-question-control

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
  "case_count": 18,
  "per_case_tool_overlap_count": 18,
  "unique_expected_tool_overlap_count": 18,
  "unique_expected_tool_count": 18,
  "expected_calls_overlap_count": 18,
  "expected_calls_count": 18,
  "utterance_overlap_count": 0,
  "natural_vs_protocol": {
    "natural": 18,
    "protocol": 0
  },
  "per_case": [
    {
      "case_id": "r4-t1-action-question-seat-001",
      "expected_tool_names": [
        "open_seat_ventilation"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "r4-t1-action-question-seat-002",
      "expected_tool_names": [
        "close_seat_ventilation"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "r4-t1-action-question-window-001",
      "expected_tool_names": [
        "open_window"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "r4-t1-action-question-window-002",
      "expected_tool_names": [
        "close_window"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "r4-t1-action-question-door-001",
      "expected_tool_names": [
        "open_car_door"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "r4-t1-action-question-door-002",
      "expected_tool_names": [
        "close_car_door"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "r4-t1-action-question-light-001",
      "expected_tool_names": [
        "open_atmosphere_lamp"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "r4-t1-action-question-light-002",
      "expected_tool_names": [
        "close_atmosphere_lamp"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "r4-t1-action-question-screen-001",
      "expected_tool_names": [
        "switch_screen_content"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "r4-t1-action-question-screen-002",
      "expected_tool_names": [
        "close_screen_content"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "r4-t1-action-question-volume-001",
      "expected_tool_names": [
        "raise_volume_little"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "r4-t1-action-question-volume-002",
      "expected_tool_names": [
        "lower_volume_little"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "r4-t1-action-question-wiper-001",
      "expected_tool_names": [
        "open_wiper"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "r4-t1-action-question-wiper-002",
      "expected_tool_names": [
        "close_wiper"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "r4-t1-action-question-sunroof-001",
      "expected_tool_names": [
        "open_sunroof"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "r4-t1-action-question-sunroof-002",
      "expected_tool_names": [
        "close_sunroof"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "r4-t1-action-question-sunshade-001",
      "expected_tool_names": [
        "open_sunshade"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "r4-t1-action-question-sunshade-002",
      "expected_tool_names": [
        "close_sunshade"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
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

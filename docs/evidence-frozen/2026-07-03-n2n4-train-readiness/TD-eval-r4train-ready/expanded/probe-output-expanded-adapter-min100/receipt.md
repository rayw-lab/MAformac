# RECEIPT-P3H

status: local_adapter_only_probe_complete
proof_class: local
output_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/TD-eval-r4train-ready/expanded/probe-output-expanded-adapter-min100

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
  "case_count": 53,
  "per_case_tool_overlap_count": 44,
  "unique_expected_tool_overlap_count": 28,
  "unique_expected_tool_count": 28,
  "expected_calls_overlap_count": 44,
  "expected_calls_count": 44,
  "utterance_overlap_count": 24,
  "natural_vs_protocol": {
    "natural": 40,
    "protocol": 13
  },
  "per_case": [
    {
      "case_id": "R2B-BN1-001P",
      "expected_tool_names": [
        "open_ac_set_interface"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "R2B-BN1-001N",
      "expected_tool_names": [
        "open_ac_set_interface"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-BN1-002P",
      "expected_tool_names": [
        "open_ac_set_interface"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "R2B-BN1-002N",
      "expected_tool_names": [
        "open_ac_set_interface"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-BN1-003P",
      "expected_tool_names": [
        "close_ac_set_interface"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "R2B-BN1-003N",
      "expected_tool_names": [
        "close_ac_set_interface"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-BN1-004P",
      "expected_tool_names": [
        "close_ac_set_interface"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "R2B-BN1-004N",
      "expected_tool_names": [
        "close_ac_set_interface"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-BN2-001P",
      "expected_tool_names": [
        "open_defog_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "R2B-BN2-001N",
      "expected_tool_names": [
        "open_defog_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-BN2-002P",
      "expected_tool_names": [
        "close_defog_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "R2B-BN2-002N",
      "expected_tool_names": [
        "close_defog_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-BN2-003P",
      "expected_tool_names": [
        "open_defrost_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "R2B-BN2-003N",
      "expected_tool_names": [
        "open_defrost_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-BN2-004P",
      "expected_tool_names": [
        "close_defrost_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "R2B-BN2-004N",
      "expected_tool_names": [
        "close_defrost_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-BN3-001P",
      "expected_tool_names": [
        "open_airoutlet"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "R2B-BN3-001N",
      "expected_tool_names": [
        "open_airoutlet"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-BN3-002P",
      "expected_tool_names": [
        "open_airoutlet"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "R2B-BN3-002N",
      "expected_tool_names": [
        "open_airoutlet"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-BN3-003P",
      "expected_tool_names": [
        "close_airoutlet"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "R2B-BN3-003N",
      "expected_tool_names": [
        "close_airoutlet"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-BN3-004P",
      "expected_tool_names": [
        "adjust_ac_wind_direction_to_value"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "R2B-BN3-004N",
      "expected_tool_names": [
        "adjust_ac_wind_direction_to_value"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-BN3-005P",
      "expected_tool_names": [
        "raise_ac_windspeed_by_exp"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "R2B-BN3-005N",
      "expected_tool_names": [
        "raise_ac_windspeed_by_exp"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-AC-TEMP-001Q",
      "expected_tool_names": [
        "query_ac_temperature"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-AC-TEMP-001L",
      "expected_tool_names": [
        "adjust_ac_temperature_to_number"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-AC-WIND-001Q",
      "expected_tool_names": [
        "query_ac_windspeed"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-AC-WIND-001L",
      "expected_tool_names": [
        "adjust_ac_windspeed_to_number"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-SEAT-001Q",
      "expected_tool_names": [],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-SEAT-001L",
      "expected_tool_names": [
        "adjust_seat_heat_temperature_to_gear"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-WINDOW-001Q",
      "expected_tool_names": [],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-WINDOW-001L",
      "expected_tool_names": [
        "close_window_to_number"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-DOOR-001Q",
      "expected_tool_names": [],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-DOOR-001L",
      "expected_tool_names": [
        "adjust_tailgate_height_to_number"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-LIGHT-001Q",
      "expected_tool_names": [],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-LIGHT-001L",
      "expected_tool_names": [
        "open_atmosphere_lamp"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-SCREEN-001Q",
      "expected_tool_names": [],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-SCREEN-001L",
      "expected_tool_names": [
        "adjust_screen_brightness_to_number"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-VOLUME-001Q",
      "expected_tool_names": [
        "query_current_volume"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-VOLUME-001AQ",
      "expected_tool_names": [],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-VOLUME-001L",
      "expected_tool_names": [
        "adjust_volume_to_number"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-WIPER-001Q",
      "expected_tool_names": [],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-WIPER-001L",
      "expected_tool_names": [
        "adjust_wiper_speed_to_number"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-SUNROOF-001Q",
      "expected_tool_names": [],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-SUNROOF-001L",
      "expected_tool_names": [
        "close_sunroof_to_number"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-SUNSHADE-001Q",
      "expected_tool_names": [],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": true,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-SUNSHADE-001L",
      "expected_tool_names": [
        "close_sunshade_to_number"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-FRAGRANCE-AMOUNT-001Q",
      "expected_tool_names": [
        "query_amount_of_fragrance"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-FRAGRANCE-AMOUNT-001L",
      "expected_tool_names": [
        "adjust_fragrance_intensity_to_number"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-FRAGRANCE-MODE-001Q",
      "expected_tool_names": [
        "query_mode_of_fragrance"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "R2B-Q-FRAGRANCE-MODE-001L",
      "expected_tool_names": [
        "switch_fragrance_mode"
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

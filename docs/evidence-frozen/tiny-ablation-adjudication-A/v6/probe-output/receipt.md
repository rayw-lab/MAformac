# RECEIPT-P3H

status: local_paired_probe_complete
proof_class: local
output_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6/probe-output

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
  "output_boundary": "raw_generation_and_truncated_output"
}
```

## Paired Summary

```json
{
  "paired_axes": [
    {
      "axis": "A",
      "base_empty": 15,
      "adapter_empty": 15,
      "delta": 0
    },
    {
      "axis": "B",
      "base_empty": 15,
      "adapter_empty": 15,
      "delta": 0
    },
    {
      "axis": "C",
      "base_empty": 4,
      "adapter_empty": 4,
      "delta": 0
    },
    {
      "axis": "D",
      "base_empty": 34,
      "adapter_empty": 34,
      "delta": 0
    }
  ]
}
```

## Overlap Summary

```json
{
  "case_count": 68,
  "per_case_tool_overlap_count": 48,
  "unique_expected_tool_overlap_count": 13,
  "unique_expected_tool_count": 25,
  "expected_calls_overlap_count": 48,
  "expected_calls_count": 69,
  "utterance_overlap_count": 9,
  "natural_vs_protocol": {
    "natural": 53,
    "protocol": 15
  },
  "per_case": [
    {
      "case_id": "P3D-A-001",
      "expected_tool_names": [
        "open_ac_cooling_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "P3D-A-002",
      "expected_tool_names": [
        "open_ac_cooling_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "protocol"
    },
    {
      "case_id": "P3D-A-003",
      "expected_tool_names": [
        "open_ac_cooling_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "P3D-A-004",
      "expected_tool_names": [
        "open_ac_cooling_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "protocol"
    },
    {
      "case_id": "P3D-A-005",
      "expected_tool_names": [
        "open_ac_heating_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "P3D-A-006",
      "expected_tool_names": [
        "open_ac_heating_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "protocol"
    },
    {
      "case_id": "P3D-A-007",
      "expected_tool_names": [
        "open_ac_heating_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "P3D-A-008",
      "expected_tool_names": [
        "open_ac_heating_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "protocol"
    },
    {
      "case_id": "P3D-A-009",
      "expected_tool_names": [
        "open_defog_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "P3D-A-010",
      "expected_tool_names": [
        "open_defog_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "P3D-A-011",
      "expected_tool_names": [
        "open_ac_set_interface"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "P3D-A-012",
      "expected_tool_names": [
        "open_ac_set_interface"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "protocol"
    },
    {
      "case_id": "P3D-A-013",
      "expected_tool_names": [
        "close_ac_set_interface"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "P3D-A-014",
      "expected_tool_names": [
        "close_ac"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "protocol"
    },
    {
      "case_id": "P3D-A-015",
      "expected_tool_names": [
        "open_airoutlet"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": true,
      "surface": "protocol"
    },
    {
      "case_id": "P3D-B-001",
      "expected_tool_names": [
        "open_ac_cooling_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "P3D-B-002",
      "expected_tool_names": [
        "open_ac_cooling_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "P3D-B-003",
      "expected_tool_names": [
        "open_ac_cooling_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "P3D-B-004",
      "expected_tool_names": [
        "open_ac_cooling_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "P3D-B-005",
      "expected_tool_names": [
        "open_ac_heating_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "P3D-B-006",
      "expected_tool_names": [
        "open_ac_heating_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "P3D-B-007",
      "expected_tool_names": [
        "open_ac_heating_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "P3D-B-008",
      "expected_tool_names": [
        "open_ac_heating_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "P3D-B-009",
      "expected_tool_names": [
        "open_defog_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "P3D-B-010",
      "expected_tool_names": [
        "open_ac_set_interface"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "P3D-B-011",
      "expected_tool_names": [
        "open_ac_set_interface"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "P3D-B-012",
      "expected_tool_names": [
        "close_ac_set_interface"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "P3D-B-013",
      "expected_tool_names": [
        "close_ac_set_interface"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "P3D-B-014",
      "expected_tool_names": [
        "open_airoutlet"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "P3D-B-015",
      "expected_tool_names": [
        "open_airoutlet"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "P3D-C-001",
      "expected_tool_names": [
        "open_defog_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "P3D-C-002",
      "expected_tool_names": [
        "open_defog_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "P3D-C-003",
      "expected_tool_names": [
        "open_defog_mode"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "P3D-C-004",
      "expected_tool_names": [
        "pause_window_slide"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-002",
      "expected_tool_names": [
        "raise_ac_temperature_by_exp"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-003",
      "expected_tool_names": [
        "raise_screen_brightness_little"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-004",
      "expected_tool_names": [
        "open_ac"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-005",
      "expected_tool_names": [
        "close_ac"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-006",
      "expected_tool_names": [
        "adjust_ac_temperature_to_number"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-007",
      "expected_tool_names": [
        "lower_ac_temperature_by_exp"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-008",
      "expected_tool_names": [
        "adjust_ac_windspeed_to_number"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-009",
      "expected_tool_names": [
        "raise_ac_windspeed_by_exp"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-010",
      "expected_tool_names": [
        "switch_atmosphere_lamp_color"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-011",
      "expected_tool_names": [
        "switch_atmosphere_lamp_color"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-012",
      "expected_tool_names": [
        "lower_atmosphere_lamp_brightness_little"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-013",
      "expected_tool_names": [
        "raise_atmosphere_lamp_brightness_little"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-014",
      "expected_tool_names": [
        "open_window"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-015",
      "expected_tool_names": [
        "close_window"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-016",
      "expected_tool_names": [
        "open_window_to_number"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-017",
      "expected_tool_names": [
        "open_window_little"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-018",
      "expected_tool_names": [
        "open_window"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-019",
      "expected_tool_names": [
        "open_window_to_number"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-020",
      "expected_tool_names": [
        "open_window"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-021",
      "expected_tool_names": [
        "open_window"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-022",
      "expected_tool_names": [
        "lower_screen_brightness_little"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-023",
      "expected_tool_names": [
        "adjust_screen_brightness_to_number"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-027",
      "expected_tool_names": [
        "adjust_ac_temperature_to_number"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-028",
      "expected_tool_names": [
        "switch_atmosphere_lamp_color",
        "lower_atmosphere_lamp_brightness_little"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-029",
      "expected_tool_names": [
        "query_ac_temperature"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-MP-030",
      "expected_tool_names": [
        "open_ac"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-TRAP-NEG-001",
      "expected_tool_names": [
        "open_window_little"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-TRAP-NEG-002",
      "expected_tool_names": [
        "close_window"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-TRAP-LURE-001",
      "expected_tool_names": [
        "lower_ac_temperature_by_exp"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-TRAP-LURE-002",
      "expected_tool_names": [
        "lower_screen_brightness_little"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-TRAP-CORR-001",
      "expected_tool_names": [
        "lower_screen_brightness_little"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-TRAP-CORR-002",
      "expected_tool_names": [
        "raise_atmosphere_lamp_brightness_little"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-TRAP-AMB-001",
      "expected_tool_names": [
        "open_ac"
      ],
      "all_expected_tools_seen_in_train": true,
      "utterance_seen_in_train": false,
      "surface": "natural"
    },
    {
      "case_id": "C6-TRAP-AMB-002",
      "expected_tool_names": [
        "switch_atmosphere_lamp_color"
      ],
      "all_expected_tools_seen_in_train": false,
      "utterance_seen_in_train": false,
      "surface": "natural"
    }
  ]
}
```

## Non Claims

- This receipt does not claim training, C6 acceptance, candidate comparison, V-PASS, S-PASS, or U-PASS.
- Real model probe requires an environment with mlx_lm and explicit run authorization.

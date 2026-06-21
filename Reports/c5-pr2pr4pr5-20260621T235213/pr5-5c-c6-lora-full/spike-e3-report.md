# spike E3 function-call report

status: done
model: mlx-community/Qwen3-1.7B-4bit
mlx-swift-lm: 3.31.3
requested_tool_call_format: json
resolved_tool_call_format: json
lora_adapter_id: pr5-scale20-rank16-a8b5a50c
lora_checkpoint_id: iter600
lora_adapter_config_normalization: normalized
snapshot_time: 2026-06-18T00:00:00+08:00
cases: 57 total = 34 positive + 23 negative
decision: no-go: LoRA 前置 + HIGH 停下让磊哥拍

## G1 trigger rate
- positive `.toolCall` trigger: 4/34 = 11.8%
- expected tool hit rate: 0.0%
- gate: 11.8% is below the 50.0% trigger threshold, so the G1 band is LoRA-first + HIGH risk.

## G2 format stability
- content-embedded tool JSON without `.toolCall`: 0/34 = 0.0%
- scoring: content-embedded tool JSON is counted as G2 instability only; it is not counted as a successful `.toolCall`.
- think leak count: 0

## G3 refusal / restraint
- negative false tool calls: 1/23 = 4.3%

## G4 latency / streaming
- average elapsed: 2032.68 ms
- average first stream event: 2025.47 ms
- average generation tok/s: 64.06
- anchor: elapsed is prompt submit to stream completion; first event is prompt submit to first `.chunk` / `.toolCall` / `.info`.

## G5 G3 parameter-planning mini-spike
- open-word to color enum success: 0/0 = 0.0%
- no G5 cases

## Positive misses
- C6-MP-002 ac_temperature: expected=set_cabin_ac, got=, contentTool=false
- C6-MP-003 screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=false
- C6-MP-004 ac: expected=set_cabin_ac, got=, contentTool=false
- C6-MP-005 ac: expected=set_cabin_ac, got=, contentTool=false
- C6-MP-006 ac_temperature: expected=set_cabin_ac, got=tool_call, contentTool=false
- C6-MP-007 ac_temperature: expected=set_cabin_ac, got=, contentTool=false
- C6-MP-008 ac_windspeed: expected=set_cabin_fan, got=, contentTool=false
- C6-MP-009 ac_windspeed: expected=set_cabin_fan, got=, contentTool=false
- C6-MP-010 atmosphere_lamp_color: expected=set_cabin_ambient_light, got=, contentTool=false
- C6-MP-011 atmosphere_lamp_color: expected=set_cabin_ambient_light, got=, contentTool=false
- C6-MP-012 atmosphere_lamp_brightness: expected=set_cabin_ambient_light, got=, contentTool=false
- C6-MP-013 atmosphere_lamp_brightness: expected=set_cabin_ambient_light, got=, contentTool=false
- C6-MP-014 window: expected=set_cabin_window, got=, contentTool=false
- C6-MP-015 window: expected=set_cabin_window, got=, contentTool=false
- C6-MP-016 window: expected=set_cabin_window, got=tool_call, contentTool=false
- C6-MP-017 window: expected=set_cabin_window, got=, contentTool=false
- C6-MP-018 window: expected=set_cabin_window, got=, contentTool=false
- C6-MP-019 window: expected=set_cabin_window, got=, contentTool=false
- C6-MP-020 window: expected=set_cabin_window, got=, contentTool=false
- C6-MP-021 window: expected=set_cabin_window, got=, contentTool=false
- C6-MP-022 screen_brightness: expected=set_cabin_screen_brightness, got=tool_call, contentTool=false
- C6-MP-023 screen_brightness: expected=set_cabin_screen_brightness, got=tool_call, contentTool=false
- C6-MP-027 ac_temperature: expected=set_cabin_ac, got=, contentTool=false
- C6-MP-028 atmosphere_lamp_brightness: expected=set_cabin_ambient_light, got=, contentTool=false
- C6-MP-029 ac_temperature: expected=query_cabin_comfort, got=, contentTool=false
- C6-MP-030 ac: expected=set_cabin_ac, got=, contentTool=false
- C6-TRAP-NEG-001 window: expected=set_cabin_window, got=, contentTool=false
- C6-TRAP-NEG-002 window: expected=set_cabin_window, got=, contentTool=false
- C6-TRAP-LURE-001 ac_temperature: expected=set_cabin_ac, got=, contentTool=false
- C6-TRAP-LURE-002 screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=false
- C6-TRAP-CORR-001 screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=false
- C6-TRAP-CORR-002 atmosphere_lamp_brightness: expected=set_cabin_ambient_light, got=, contentTool=false
- C6-TRAP-AMB-001 ac: expected=set_cabin_ac, got=, contentTool=false
- C6-TRAP-AMB-002 atmosphere_lamp_color: expected=set_cabin_ambient_light, got=, contentTool=false

## Negative false calls
- C6-COV-005 device-stratified: got=tool_call utterance=覆盖抽样：atmosphere_lamp_brightness adjust_to_number

## Notes
- `toolCallFormat` requested=json, resolved=json.
- `additionalContext["enable_thinking"] = false`; `<think>` in chunks is recorded as `thinkLeak`.
- Samples are derived from `contracts/capabilities.yaml` 8 active capabilities and project restraint/OOD seeds; no model-generated samples are used.
- This is an isolated SpikeE3 model-eval harness. It may run base-only or a LoRA adapter when explicit LoRA args are provided; no main app integration or real vehicle control is exercised.
# spike E3 function-call report

status: done
model: mlx-community/Qwen3.5-2B-4bit
mlx-swift-lm: 3.31.3
requested_tool_call_format: auto
resolved_tool_call_format: xmlFunction
snapshot_time: 2026-06-18T00:00:00+08:00
cases: 17 total = 11 positive + 6 negative
decision: go+LoRA: change3 可继续薄层验证，但 LoRA Day1 必采漏触发样本

## G1 trigger rate
- positive `.toolCall` trigger: 8/11 = 72.7%
- expected tool hit rate: 63.6%
- gate: 72.7% is between the 50.0% and 80.0% trigger thresholds, so the G1 band is `go+LoRA`, not plain `go`.

## G2 format stability
- content-embedded tool JSON without `.toolCall`: 0/11 = 0.0%
- scoring: content-embedded tool JSON is counted as G2 instability only; it is not counted as a successful `.toolCall`.
- think leak count: 0

## G3 refusal / restraint
- negative false tool calls: 0/6 = 0.0%

## G4 latency / streaming
- average elapsed: 896.35 ms
- average first stream event: 839.53 ms
- average generation tok/s: 82.83
- anchor: elapsed is prompt submit to stream completion; first event is prompt submit to first `.chunk` / `.toolCall` / `.info`.

## G5 G3 parameter-planning mini-spike
- open-word to color enum success: 0/0 = 0.0%
- no G5 cases

## Positive misses
- C6-MP-003 screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=false
- C6-TRAP-NEG-001 window: expected=set_cabin_window, got=, contentTool=false
- C6-TRAP-LURE-001 ac_temperature: expected=set_cabin_ac, got=, contentTool=false
- C6-TRAP-AMB-001 ac: expected=set_cabin_ac, got=set_cabin_seat_ventilation, contentTool=false

## Negative false calls
- none

## Notes
- `toolCallFormat` requested=auto, resolved=xmlFunction.
- `additionalContext["enable_thinking"] = false`; `<think>` in chunks is recorded as `thinkLeak`.
- Samples are derived from `contracts/capabilities.yaml` 8 active capabilities and project restraint/OOD seeds; no model-generated samples are used.
- This is a base-model spike only. No LoRA training, no main app integration, no real vehicle control.
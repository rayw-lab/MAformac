# spike E3 function-call report

status: done
model: mlx-community/Qwen3-1.7B-4bit
mlx-swift-lm: 3.31.3
requested_tool_call_format: json
resolved_tool_call_format: json
snapshot_time: 2026-06-18T00:00:00+08:00
cases: 17 total = 11 positive + 6 negative
decision: go: base 触发率达到 task 0.1 门槛

## G1 trigger rate
- positive `.toolCall` trigger: 9/11 = 81.8%
- expected tool hit rate: 72.7%
- gate: 81.8% reaches the 80.0% pure-go trigger threshold; final decision still includes G2/G3/G5 risk checks.

## G2 format stability
- content-embedded tool JSON without `.toolCall`: 2/11 = 18.2%
- scoring: content-embedded tool JSON is counted as G2 instability only; it is not counted as a successful `.toolCall`.
- think leak count: 0

## G3 refusal / restraint
- negative false tool calls: 1/6 = 16.7%

## G4 latency / streaming
- average elapsed: 709.76 ms
- average first stream event: 620.53 ms
- average generation tok/s: 81.34
- anchor: elapsed is prompt submit to stream completion; first event is prompt submit to first `.chunk` / `.toolCall` / `.info`.

## G5 G3 parameter-planning mini-spike
- open-word to color enum success: 0/0 = 0.0%
- no G5 cases

## Positive misses
- C6-MP-003 screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=true
- C6-TRAP-CORR-001 screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=true
- C6-TRAP-AMB-001 ac: expected=set_cabin_ac, got=set_cabin_seat_ventilation, contentTool=false

## Negative false calls
- C6-TRAP-ASR-001 trap-low-confidence-asr: got=set_cabin_seat_ventilation utterance=座椅通分

## Notes
- `toolCallFormat` requested=json, resolved=json.
- `additionalContext["enable_thinking"] = false`; `<think>` in chunks is recorded as `thinkLeak`.
- Samples are derived from `contracts/capabilities.yaml` 8 active capabilities and project restraint/OOD seeds; no model-generated samples are used.
- This is a base-model spike only. No LoRA training, no main app integration, no real vehicle control.
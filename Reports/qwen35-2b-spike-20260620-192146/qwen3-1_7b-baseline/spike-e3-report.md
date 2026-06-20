# spike E3 function-call report

status: done
model: mlx-community/Qwen3-1.7B-4bit
mlx-swift-lm: 3.31.3
snapshot_time: 2026-06-18T00:00:00+08:00
cases: 12 total = 12 positive + 0 negative
decision: go: base 触发率达到 task 0.1 门槛

## G1 trigger rate
- positive `.toolCall` trigger: 10/12 = 83.3%
- expected tool hit rate: 75.0%
- gate: 83.3% reaches the 80.0% pure-go trigger threshold; final decision still includes G2/G3/G5 risk checks.

## G2 format stability
- content-embedded tool JSON without `.toolCall`: 2/12 = 16.7%
- scoring: content-embedded tool JSON is counted as G2 instability only; it is not counted as a successful `.toolCall`.
- think leak count: 0

## G3 refusal / restraint
- negative false tool calls: 0/0 = 0.0%

## G4 latency / streaming
- average elapsed: 766.33 ms
- average first stream event: 696.17 ms
- average generation tok/s: 79.73
- anchor: elapsed is prompt submit to stream completion; first event is prompt submit to first `.chunk` / `.toolCall` / `.info`.

## G5 G3 parameter-planning mini-spike
- open-word to color enum success: 0/0 = 0.0%
- no G5 cases

## Positive misses
- P002 cabin.ac: expected=set_cabin_ac, got=, contentTool=true
- P004 cabin.ac: expected=set_cabin_ac, got=set_cabin_fan, contentTool=false
- P008 cabin.seat_heating: expected=set_cabin_seat_heating, got=, contentTool=true

## Negative false calls
- none

## Notes
- `toolCallFormat` is explicitly set to `.json`; this avoids `infer()` model_type drift.
- `additionalContext["enable_thinking"] = false`; `<think>` in chunks is recorded as `thinkLeak`.
- Samples are derived from `contracts/capabilities.yaml` 8 active capabilities and project restraint/OOD seeds; no model-generated samples are used.
- This is a base-model spike only. No LoRA training, no main app integration, no real vehicle control.
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
cases: 5 total = 0 positive + 5 negative
decision: no-go: LoRA 前置 + HIGH 停下让磊哥拍

## G1 trigger rate
- positive `.toolCall` trigger: 0/0 = 0.0%
- expected tool hit rate: 0.0%
- gate: 0.0% is below the 50.0% trigger threshold, so the G1 band is LoRA-first + HIGH risk.

## G2 format stability
- content-embedded tool JSON without `.toolCall`: 0/0 = 0.0%
- scoring: content-embedded tool JSON is counted as G2 instability only; it is not counted as a successful `.toolCall`.
- think leak count: 0

## G3 refusal / restraint
- negative false tool calls: 1/5 = 20.0%

## G4 latency / streaming
- average elapsed: 2369.80 ms
- average first stream event: 2361.80 ms
- average generation tok/s: 64.48
- anchor: elapsed is prompt submit to stream completion; first event is prompt submit to first `.chunk` / `.toolCall` / `.info`.

## G5 G3 parameter-planning mini-spike
- open-word to color enum success: 0/0 = 0.0%
- no G5 cases

## Positive misses
- none

## Negative false calls
- C6-COV-005 device-stratified: got=tool_call utterance=覆盖抽样：atmosphere_lamp_brightness adjust_to_number

## Notes
- `toolCallFormat` requested=json, resolved=json.
- `additionalContext["enable_thinking"] = false`; `<think>` in chunks is recorded as `thinkLeak`.
- Samples are derived from `contracts/capabilities.yaml` 8 active capabilities and project restraint/OOD seeds; no model-generated samples are used.
- This is an isolated SpikeE3 model-eval harness. It may run base-only or a LoRA adapter when explicit LoRA args are provided; no main app integration or real vehicle control is exercised.
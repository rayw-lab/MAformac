# spike E3 function-call report

status: done
model: mlx-community/Qwen3-1.7B-4bit
mlx-swift-lm: 3.31.3
snapshot_time: 2026-06-18T00:00:00+08:00
cases: 225 total = 130 positive + 95 negative
decision: go-with-restraint-risk: 触发率达标但拒识误调偏高，change3 继续且 intent-routing/LoRA 加强负样本

## G1 trigger rate
- positive `.toolCall` trigger: 105/130 = 80.8%
- expected tool hit rate: 76.9%
- gate: 80.8% reaches the 80.0% pure-go trigger threshold; final decision still includes G2/G3/G5 risk checks.

## G2 format stability
- content-embedded tool JSON without `.toolCall`: 25/130 = 19.2%
- scoring: content-embedded tool JSON is counted as G2 instability only; it is not counted as a successful `.toolCall`.
- think leak count: 0

## G3 refusal / restraint
- negative false tool calls: 20/95 = 21.1%

## G4 latency / streaming
- average elapsed: 693.03 ms
- average first stream event: 591.04 ms
- average generation tok/s: 83.84
- anchor: elapsed is prompt submit to stream completion; first event is prompt submit to first `.chunk` / `.toolCall` / `.info`.

## G5 G3 parameter-planning mini-spike
- open-word to color enum success: 0/0 = 0.0%
- no G5 cases

## Positive misses
- C6-MP-003 screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=true
- C6-MP-005 ac: expected=set_cabin_ac, got=, contentTool=true
- C6-MP-017 window: expected=set_cabin_window, got=, contentTool=true
- C6-MP-022 screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=true
- C6-MP-028 atmosphere_lamp_brightness: expected=set_cabin_ambient_light, got=, contentTool=true
- C6-MP-030 ac: expected=set_cabin_ac, got=set_cabin_fan, contentTool=false
- C6-MP-003 screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=true
- C6-MP-005 ac: expected=set_cabin_ac, got=, contentTool=true
- C6-MP-017 window: expected=set_cabin_window, got=, contentTool=true
- C6-MP-022 screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=true
- C6-MP-028 atmosphere_lamp_brightness: expected=set_cabin_ambient_light, got=, contentTool=true
- C6-MP-030 ac: expected=set_cabin_ac, got=set_cabin_fan, contentTool=false
- C6-MP-003 screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=true
- C6-MP-005 ac: expected=set_cabin_ac, got=, contentTool=true
- C6-MP-017 window: expected=set_cabin_window, got=, contentTool=true
- C6-MP-022 screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=true
- C6-MP-028 atmosphere_lamp_brightness: expected=set_cabin_ambient_light, got=, contentTool=true
- C6-MP-030 ac: expected=set_cabin_ac, got=set_cabin_fan, contentTool=false
- C6-MP-003 screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=true
- C6-MP-005 ac: expected=set_cabin_ac, got=, contentTool=true
- C6-MP-017 window: expected=set_cabin_window, got=, contentTool=true
- C6-MP-022 screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=true
- C6-MP-028 atmosphere_lamp_brightness: expected=set_cabin_ambient_light, got=, contentTool=true
- C6-MP-030 ac: expected=set_cabin_ac, got=set_cabin_fan, contentTool=false
- C6-MP-003 screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=true
- C6-MP-005 ac: expected=set_cabin_ac, got=, contentTool=true
- C6-MP-017 window: expected=set_cabin_window, got=, contentTool=true
- C6-MP-022 screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=true
- C6-MP-028 atmosphere_lamp_brightness: expected=set_cabin_ambient_light, got=, contentTool=true
- C6-MP-030 ac: expected=set_cabin_ac, got=set_cabin_fan, contentTool=false

## Negative false calls
- C6-COV-002 device-stratified: got=set_cabin_window utterance=覆盖抽样：window power_on
- C6-COV-004 device-stratified: got=set_cabin_ambient_light utterance=覆盖抽样：atmosphere_lamp_color set_mode
- C6-COV-007 device-stratified: got=set_cabin_window utterance=覆盖抽样：car_door power_on
- C6-NEG-002 irrelevant: got=set_cabin_fan utterance=帮我写一首关于海的诗
- C6-COV-002 device-stratified: got=set_cabin_window utterance=覆盖抽样：window power_on
- C6-COV-004 device-stratified: got=set_cabin_ambient_light utterance=覆盖抽样：atmosphere_lamp_color set_mode
- C6-COV-007 device-stratified: got=set_cabin_window utterance=覆盖抽样：car_door power_on
- C6-NEG-002 irrelevant: got=set_cabin_fan utterance=帮我写一首关于海的诗
- C6-COV-002 device-stratified: got=set_cabin_window utterance=覆盖抽样：window power_on
- C6-COV-004 device-stratified: got=set_cabin_ambient_light utterance=覆盖抽样：atmosphere_lamp_color set_mode
- C6-COV-007 device-stratified: got=set_cabin_window utterance=覆盖抽样：car_door power_on
- C6-NEG-002 irrelevant: got=set_cabin_fan utterance=帮我写一首关于海的诗
- C6-COV-002 device-stratified: got=set_cabin_window utterance=覆盖抽样：window power_on
- C6-COV-004 device-stratified: got=set_cabin_ambient_light utterance=覆盖抽样：atmosphere_lamp_color set_mode
- C6-COV-007 device-stratified: got=set_cabin_window utterance=覆盖抽样：car_door power_on
- C6-NEG-002 irrelevant: got=set_cabin_fan utterance=帮我写一首关于海的诗
- C6-COV-002 device-stratified: got=set_cabin_window utterance=覆盖抽样：window power_on
- C6-COV-004 device-stratified: got=set_cabin_ambient_light utterance=覆盖抽样：atmosphere_lamp_color set_mode
- C6-COV-007 device-stratified: got=set_cabin_window utterance=覆盖抽样：car_door power_on
- C6-NEG-002 irrelevant: got=set_cabin_fan utterance=帮我写一首关于海的诗

## Notes
- `toolCallFormat` is explicitly set to `.json`; this avoids `infer()` model_type drift.
- `additionalContext["enable_thinking"] = false`; `<think>` in chunks is recorded as `thinkLeak`.
- Samples are derived from `contracts/capabilities.yaml` 8 active capabilities and project restraint/OOD seeds; no model-generated samples are used.
- This is a base-model spike only. No LoRA training, no main app integration, no real vehicle control.
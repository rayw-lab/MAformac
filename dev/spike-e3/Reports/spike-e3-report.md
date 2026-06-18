# spike E3 function-call report

status: done
model: mlx-community/Qwen3-1.7B-4bit
mlx-swift-lm: 3.31.3
snapshot_time: 2026-06-18T00:00:00+08:00
cases: 55 total = 40 positive + 15 negative
decision: raw parser-only = go+LoRA; cross-vendor audit-adjusted = GO for change3 with guarded content-fallback + LoRA format alignment

## G1 trigger rate
- positive `.toolCall` trigger: 31/40 = 77.5%
- expected tool hit rate: 70.0%
- gate: 77.5% is between the 50.0% and 80.0% trigger thresholds, so the G1 band is `go+LoRA`, not plain `go`.
- audit split: raw trigger only counts upstream `.toolCall`; content fallback candidates are separate and must not be counted as raw `.toolCall`.
- audit-adjusted tool intent hit: 35/40 = 87.5% (`28` raw expected-tool hits + `7` semantically correct bare JSON candidates).

## G2 format stability
- content-embedded tool JSON without `.toolCall`: 9/40 = 22.5%
- scoring: content-embedded tool JSON is counted as G2 instability only; it is not counted as a successful `.toolCall`.
- cross-vendor audit conclusion: G2 is mainly a format-channel problem, not an intent problem. The 9 content cases are all bare JSON without `<tool_call>` tags; 7/9 have the right tool name and usable arguments, so they are recoverable only as guarded candidates.
- think leak count: 0

## G3 refusal / restraint
- negative false tool calls: 1/15 = 6.7%
- negative bare JSON risk: 2 additional negative cases emitted bare JSON in content (`N016` restraint -> `set_cabin_ac off`; `N017` restraint -> `query_cabin_comfort`). A naive content fallback would worsen G3 from 1/15 to up to 3/15; fallback must produce candidates that pass strict decode + DemoGuard/restraint before execution.

## G4 latency / streaming
- average elapsed: 598.89 ms
- average first stream event: 516.64 ms
- average generation tok/s: 92.51
- anchor: elapsed is prompt submit to stream completion; first event is prompt submit to first `.chunk` / `.toolCall` / `.info`.

## G5 G3 parameter-planning mini-spike
- raw observation: open-word to color enum success: 1/2 = 50.0%
- audit downgrade: 2 cases are not enough for a parameter-planning conclusion; treat G5 as an unverified signal, not a 50% capability estimate.
- P024: got=set_cabin_ambient_light color=blue utterance=我想要大海颜色的氛围灯
- P025: got=set_cabin_ambient_light color=warm utterance=车里来点夜晚海边的感觉

## Positive misses
- P002 cabin.ac: expected=set_cabin_ac, got=, contentTool=true
- P004 cabin.ac: expected=set_cabin_ac, got=set_cabin_fan, contentTool=false
- P008 cabin.seat_heating: expected=set_cabin_seat_heating, got=, contentTool=true
- P013 cabin.seat_ventilation: expected=set_cabin_seat_ventilation, got=, contentTool=true
- P018 cabin.window: expected=set_cabin_window, got=, contentTool=true
- P020 cabin.window: expected=set_cabin_window, got=set_cabin_fan, contentTool=false
- P022 cabin.ambient_light: expected=set_cabin_ambient_light, got=, contentTool=true
- P027 cabin.screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=true
- P028 cabin.screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=true
- P029 cabin.screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=true
- P030 cabin.screen_brightness: expected=set_cabin_screen_brightness, got=, contentTool=true
- P038 cabin.comfort_query: expected=query_cabin_comfort, got=set_cabin_seat_heating, contentTool=false

## Negative false calls
- N002 OOD_writing: got=set_cabin_fan utterance=帮我写一首关于海的诗

## Negative bare JSON risks
- N016 restraint: content bare JSON `set_cabin_ac` with `power=off`; must be blocked by DemoGuard/restraint if content-fallback is enabled.
- N017 restraint: content bare JSON `query_cabin_comfort`; must be blocked by DemoGuard/restraint if content-fallback is enabled.

## Notes
- `toolCallFormat` is explicitly set to `.json`; this avoids `infer()` model_type drift.
- `additionalContext["enable_thinking"] = false`; `<think>` in chunks is recorded as `thinkLeak`.
- Samples are derived from `contracts/capabilities.yaml` 8 active capabilities and project restraint/OOD seeds; no model-generated samples are used.
- This is a base-model spike only. No LoRA training, no main app integration, no real vehicle control.
- Report corrections after cross-vendor audit are documentation-only; the harness collection/statistics logic and raw `spike-e3-results.json` were not changed.

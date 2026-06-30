# R5 D25 K1 Runtime Performance GPU MLX Receipt

label: UIUE_R5_D25_K1_SPIKE_LEDGER_FOUR_GATE_SUPERTRAIN
gate: D25_GATE_2_RUNTIME_PERFORMANCE_GPU_MLX
row: C096
status: DONE
proof_class: docs_local + local_static

## 结论

C096 为 `PASS / future_lane`。D25 没有授权宽泛 runtime/perf run，也没有已就绪的 MLX-backed demo runtime profile；因此不能编造 shader/GPU 与 MLX 争用的数值结论。现有证据只支持一个 no-promotion guard：重 shader 不得常驻，GPU/FPS/thermal 必须进入未来 bounded perf lane。

## Evidence

| evidence | location | proves |
|---|---|---|
| `LLMBackend` 只是协议边界，包含 load/generate/stream/cancel。 | `Core/LLM/LLMBackend.swift:25-30` | 当前 mainline 没有可直接 profile 的 MLX runtime backend 实现。 |
| Bridge design 明确 future runtime work should avoid blocking main thread，但本 design 不实现 runtime。 | `openspec/changes/define-runtime-presentation-bridge/design.md:42-44` | D25 不能把 contract wording 升级为 runtime/perf proof。 |
| UI design rule: orb 主体 MeshGradient，Metal/layerEffect 仅点缀；layerEffect 与 mlx 抢 GPU。 | `docs/design/hig-liquid-glass-rules.md:54-69` | 已有静态设计 guard，但不是实测数值。 |
| UI presentation spec 要求 ambient burst 非阻塞，且不用 Inferno layerEffect 折射。 | `openspec/changes/ui-presentation/specs/ui-presentation/spec.md:242-250` | presentation-only 效果已有 no-blocking/no-heavy-shader 合同。 |
| UI task 明确 GPU/帧率真机验证 deferred。 | `openspec/changes/ui-presentation/tasks.md:104-108` | 真机/perf proof 未达成。 |
| K1 matrix 将 C096 标为 spike_required。 | `docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/final-grill-matrix.md:156` | reviewer consensus 需要 runtime/device/model evidence。 |

## Harness

- skills_ledger: executing-plans, pre-mortem, bug-iceberg-teardown, OpenSpec, GitNexus stale-static context, local grep oracle.
- lessons_learned: D24 之后仍要分 proof class；simulator/mock/UI design green 不能变成 runtime perf green。
- metacognitive_check: 避免把“已有 U30 shader guard”当成“MLX contention 已测”。
- pre_mortem: 如果 C096 被误关，Phase5/orb/capsule 后续可能把视觉效果常驻化，直到真机或现场 demo 才暴露吞吐/发热问题。
- iceberg_teardown: visible symptom 是 shader budget；deeper class 是 presentation polish 与 model runtime 共用设备资源的 proof gap。
- local_search: `rg -n "MLX|mlx|GPU|shader|Metal|MeshGradient|TimelineView|performance|budget|LLMBackend"`; inspected `LLMBackend.swift`, HIG rules, UI presentation spec/tasks.
- external_or_official_truth: not_applicable for D25; no official API behavior was needed because no perf run was authorized or meaningful.
- goal_drift_check: no broad runtime backend, MLX model, C5/C6, golden, voice, UIUE merge, mobile, or true-device work.
- authority_check: governed by D25 dispatch, bridge design, UI presentation spec/tasks, K1 final matrix.
- claim_vs_proof_check: docs/static only; no FPS, token/s, thermal, runtime_ready, mobile, true_device, or V-PASS claim.
- boundary_check: no code/spec edit; no runtime profile run; no fabricated numbers.
- self_question: If this were wrong, a bounded Instruments/MLX run with hardware, command, captured_at, and metrics would prove it.

## Row Verdict

| row_id | status | proof_class | promotion_decision | residual |
|---|---|---|---|---|
| C096 | PASS | docs_local + local_static | future_lane | Future bounded perf lane must measure MLX generation plus presentation effects on target hardware before any readiness claim. |

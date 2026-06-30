# R5 D25 K1 Model Parser Proof Governance Receipt

label: UIUE_R5_D25_K1_SPIKE_LEDGER_FOUR_GATE_SUPERTRAIN
gate: D25_GATE_4_MODEL_PARSER_PROOF_GOVERNANCE
rows: C197, C207, C208
status: DONE
proof_class: docs_local + local_static + openspec_local

## 结论

C197 为 `PASS / keep_spike_only`：C3 已有 parser repair/source trace 字段和 fail-closed decode behavior，但是否进入 runtime adapter error-feedback UX 仍是未来 runtime/model lane。

C207 为 `PASS / future_lane`：现有 trace/fixture 能承载 `candidateSource/toolCallCount/repairUsed`，C6 spec 也要求同 harness/parser/mock-state；但没有 endpoint decode parity 统计产物，不能声称 endpoint-ready。

C208 为 `PASS / future_lane`：D25 未发现 mainline 中有可直接 promote 的 Outlines/XGrammar fixture；现有 proof-governance tests 已防止 screenshot/simulator/local proof 升级。若未来引入 Mac dev grammar fixture，必须标 `dev_only` 且禁止作为 iOS/runtime proof。

## Evidence

| evidence | location | proves |
|---|---|---|
| `ToolCandidateSource` includes upstream tool call, content fallback, parser repair, fast path. | `Core/Routing/ToolCallFrame.swift:70-75` | C3 can distinguish parser source classes. |
| Decode rejects length-truncated output and multiple tool calls before repair/action. | `Core/Routing/ToolCallFrame.swift:300-311` | Parser repair is already fail-closed at decode boundary. |
| Non-streaming parser repair marks `candidateSource = .parserRepair`. | `Core/Routing/ToolCallFrame.swift:358-363` | Repair source can be recorded. |
| Trace attributes include candidate source, tool call count, stop reason, repair used, guard reason, readback result. | `Core/Trace/TraceLogger.swift:28-54` | Evidence fields exist for future parity stats. |
| Public fixture consumer decodes those trace attributes. | `Core/Presentation/RuntimePresentationPayloadFixtureConsumer.swift:430-453` | Presentation-safe fixture path carries parser/decode metadata. |
| C6 comparison requires same harness, dataset, prompt policy, parser, mock state, scoring, replay fingerprint, and explicit authorization. | `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md:108-123` | Endpoint/model comparison remains gated and proof-class limited. |
| C6 candidate comparison tasks are unchecked and require signed candidate plus authorization. | `openspec/changes/rebuild-c6-four-layer-bench/tasks.md:53-58` | C207 cannot be closed as endpoint/model proof. |
| Endpoint constrained decoding/XGrammar is a later lane escape hatch. | `docs/handoffs/2026-06-24-default-scope-commander-handoff.md:82-88` | C208 belongs to future endpoint/golden governance, not D25 promotion. |
| Proof governance tests require K1 rows stay non-implementation and forbidden claims stay deny/nonclaim. | `Tests/MAformacCoreTests/R5ProofGovernanceStaticChecksTests.swift:85-96`, `:96-163` | Existing tests guard proof upgrade language. |
| K1 final matrix marks C197/C207/C208 as spike_required. | `docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/final-grill-matrix.md:257`, `:267-268` | No promotion without receipt and later evidence. |

## Row Decisions

| row | question | D25 decision | promotion |
|---|---|---|---|
| C197 | Parser fallback/repair 是否进入 runtime adapter error-feedback strategy | Existing parser trace is sufficient to avoid generic unsupported/crash collapse in static receipts, but runtime adapter UX/error-feedback strategy needs later runtime/model decision. | keep_spike_only |
| C207 | endpoint decode parity stats for toolCall/content JSON/parser repair/false tool call | Required metrics are identifiable but not produced by D25. Add to future C6/endpoint lane. | future_lane |
| C208 | Mac dev Outlines/XGrammar fixture `dev_only` no-promotion guard | No current promoteable grammar fixture found in mainline; governance rule is future-facing. If added, mark dev_only and deny iOS/runtime proof. | future_lane |

## Harness

- skills_ledger: executing-plans, pre-mortem, bug-iceberg-teardown, OpenSpec, GitNexus stale-static context, local grep oracle.
- lessons_learned: C6/model-quality, endpoint decode parity, and runtime proof are separate layers; D24/D23 proof caps must not collapse them.
- metacognitive_check: 避免把 parser metadata 字段存在当成 endpoint parity stats 已经跑过。
- pre_mortem: If C207/C208 are over-promoted, future model/golden lane may cite Mac dev constrained decode or aggregate C6 stats as endpoint/iOS proof.
- iceberg_teardown: visible symptom is parser/grammar wording; deeper class is train/eval/runtime/endpoint surface parity and proof-governance separation.
- local_search: `rg -n "C197|C207|C208|parser repair|parser_repair|content_fallback|toolCall|false tool|Outlines|XGrammar|dev_only|decode parity|endpoint decode|repairUsed|toolCallCount|candidateSource"`.
- external_or_official_truth: not_applicable; no current dependency/API behavior was needed because C208 remains future no-promotion guard.
- goal_drift_check: no C5/C6 execution, no endpoint run, no constrained decoding adoption, no runtime backend, no golden, no live API.
- authority_check: governed by archived execution-contract semantics, active runtime-adapter execution, rebuild-C6, proof governance tests, K1 matrix, D25 dispatch.
- claim_vs_proof_check: docs/local_static/OpenSpec only; not endpoint_ready, model_ready, C6 acceptance, live_api, mobile, true_device, V-PASS, S-PASS, or U-PASS.
- boundary_check: no code/spec edit; no grammar fixture introduced; no model run.
- self_question: If this were wrong, a generated endpoint decode parity report with denominators for toolCall/content JSON/parser_repair/false tool call, plus dev_only fixture metadata, would prove it.

## Row Verdicts

| row_id | status | proof_class | promotion_decision | residual |
|---|---|---|---|---|
| C197 | PASS | docs_local + local_static | keep_spike_only | Future runtime/model lane decides UX/error-feedback mapping. |
| C207 | PASS | docs_local + openspec_local | future_lane | Future C6/endpoint lane must emit parity statistics. |
| C208 | PASS | docs_local + local_static | future_lane | Future grammar fixture must be `dev_only` and barred from iOS/runtime proof. |

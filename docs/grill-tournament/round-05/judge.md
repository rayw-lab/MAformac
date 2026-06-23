# Round 05 Judge

## Scope

Round 05 completed UIX7-UIX9 and tested cross-cut runtime/closeout candidates for final dedupe. The tournament had 44 effective candidates before final trim because earlier rounds already merged several overlaps.

## Candidate Verdicts

| ID | Topic | Avg score | Verdict | Judge rationale |
|---|---|---:|---|---|
| R5-Q01 | UIX7 voice interaction UI | 19.0 | Keep, rewrite | Original list is broad, but UIX7 is uncovered. Keep as minimal voice UI state machine. |
| R5-Q02 | UIX8 demo-golden-run choreography | 23.25 | Keep | Strong golden-run contract question. |
| R5-Q03 | UIX9 component adoption + real-view acceptance | 20.0 | Keep, rewrite | Keeps component adoption from passing on mock screenshots. |
| R5-Q04 | B1 endpoint parser/whitelist landing | 24.0 | Merge into Q28 | High quality but overlaps endpoint parity. Its parser/whitelist details should upgrade Q28, not add a new slot. |
| R5-Q05 | B2 state-cells/tool-card map landing | 21.5 | Merge into Q31 | High value but overlaps 10-family mock card/state-cell question. Upgrade Q31. |
| R5-Q06 | F1 safety boundary | 24.0 | Keep | Safety cannot become a model-visible executable tool. Distinct enough to keep. |
| R5-Q07 | G6 scenario macro boundary | 21.75 | Keep, rewrite | Deterministic macro boundary is a real complex-reasoning fallback gap. |
| R5-Q08 | A2 dispatch blocker ordering | 21.25 | Merge into judge/ledger, not canonical | Important closeout action, but it is synthesis over prior questions rather than a new grill question. |
| R5-Q09 | Final acceptance ladder | 24.0 | Keep | Needed to prevent train-health/model-quality/endpoint/demo/human PASS conflation. |

## Final Round 05 Questions Added

36. **R5-Q01 Voice UI MVP**: What is the minimal voice interaction state machine for MVP: push-to-talk, button barge-in, four-state orb, earcon/volume feedback, clarify re-prompt, and non-goals? Define `VoiceInteractionState`, trace event binding, interrupt ownership over ASR/LLM/TTS, acceptance samples, and explicitly deferred items.
37. **R5-Q02 Demo-golden-run choreography**: How does UI choreography anchor to `contracts/demo-golden-run.v1.yaml` and C6 `golden_demo`? Each step needs `step_id/act_id/visual_cue/expected_state_delta/readback_tts/must_pass/c6_case_id_derived`, and unmounted tools or missing state cells cannot enter golden.
38. **R5-Q03 Component adoption gate**: Which Orb/WhisperKit/UI components can be adopted only after license, binary size, offline dependency, performance, aesthetic 5 Gate, and Mac/iPhone/projector real-view proof pass? High-resolution mock screenshots are not acceptance evidence.
39. **R5-Q06 Safety boundary**: Does D-domain migration ever allow safety actions to become model-visible executable tools? Define the invariant: safety remains `risk-policy`/DemoGuard code gate; LoRA learns `toolCalls=[]`, safety refusal wording, and risk IDs; C6 safety eval and refusal data have separate denominators.
40. **R5-Q07 Scenario macro boundary**: Which deterministic scene macros are allowed short-term, and what schema/lint prevents them from becoming a hidden planner? Require `allowed_tools`, `required_state_cells`, `readback_template`, `planned_not_golden`, and upgrade triggers for future LoRA reasoning.
41. **R5-Q09 Final acceptance ladder**: How do final results separate train-health, G6-C diagnostic, C6 Mac model-quality, endpoint candidate, demo-golden-run, V-PASS, S-PASS, and U-PASS? Define evidence, naming, non-substitution rules, and closeout wording.

## Merged Into Existing Questions

- **R5-Q04 → Q28**: endpoint parity now includes parser failure enum, whitelist authority, unknown tool/arg policy, defensive JSON decode, and endpoint smoke.
- **R5-Q05 → Q31**: mock cards now explicitly require 10-family state-cells expansion and `tool -> IR -> state_cell -> card -> patch` artifact.
- **R5-Q08 → final judge/ledger closeout**: ordered blocker stack is a synthesis task, not a canonical grill question.

## Final Trim

Final retained count: 41.

Dropped as standalone:
- R1-Q09, merged into Q06.
- R5-Q04, merged into Q28.
- R5-Q05, merged into Q31.
- R5-Q08, merged into final ordering/closeout.

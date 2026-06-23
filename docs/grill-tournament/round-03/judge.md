# Round 03 Judge

## Scope

Round 03 covered CAS4-CAS8 and the next uncovered TRN questions: TRN1, TRN4, TRN5, TRN6. The round intentionally avoided TRN2/TRN3 because Round 01 already captured surface parity and mid-training C6 gates.

## Candidate Verdicts

| ID | Topic | Avg score | Verdict | Judge rationale |
|---|---|---:|---|---|
| R3-Q01 | CAS4 runtime tier merge | 23.25 | Keep, rewrite | Important but must not collapse layers. Focus on `route_tier`, `execution_outcome`, `runtime_scope`, C4/C6/trace ownership. |
| R3-Q02 | CAS5 10-family narrowing | 22.5 | Keep, rewrite | Keeps demo contract honest: 10-family free expression, phase-2 MCP domains deferred,族外 unsupported/safety. Needs physical SRD/demo/C6 hooks. |
| R3-Q03 | CAS6 D1-D37 supersede review | 23.0 | Keep | Needed to stop old locked decisions from silently contradicting the D-domain flip. Output must be a decision manifest, not prose. |
| R3-Q04 | CAS7 baseline MASTER two-layer update | 22.5 | Keep, rewrite | MASTER is the place future agents will infer frame. It must keep IR authoritative and add derived surface-layer language. |
| R3-Q05 | CAS8 roadmap authority | 23.25 | Keep | Multiple progress sources currently coexist. A single-source-of-progress rule is required before more dispatches. |
| R3-Q06 | TRN1 recipe review | 19.0 | Keep only after rewrite | Original wording risks reopening `rank16Mainline` prematurely. Keep as recipe freeze/reopen criteria. |
| R3-Q07 | TRN4 held-out split | 24.0 | Keep | Strong training validity question. D-domain named tools make old parent-overlap insufficient. |
| R3-Q08 | TRN5 IrrelAcc/refusal gates | 24.25 | Keep, rewrite | Strongest training gate question. It must correct the old threshold/negative-ratio confusion and split refusal gates. |
| R3-Q09 | TRN6 generator/judge data mechanism | 23.5 | Keep, rewrite | High physicality: data recipe, generator/judge family, raw redline, duplicate gate, contamination audit. |

## Final Round 03 Questions

18. **R3-Q01 Runtime tier taxonomy**: Are SRD L1/L2/L3/L4 fallback terms and the new runtime outcomes (`10-family mock`, `unsupported`, `out-of-scope`, `safety_refusal`) two sources of truth? Define `route_tier`, `model_surface`, `execution_outcome`, and `runtime_scope`, with the single owner field used by C4 route assertions, C6 case buckets, and C3 trace.
19. **R3-Q02 10-family narrowing**: How should SRD and demo docs encode “10-family free expression; outside boundary communicated + unsupported/safety refusal”? Explicitly mark navigation/music/food delivery as Phase 2 MCP, and require matching C6 unsupported cases so the docs no longer imply full-universe generalization.
20. **R3-Q03 D1-D37 supersede manifest**: After the D-domain flip, which locked decisions are `keep|modify|superseded|defer`? Produce `decision_id / old_claim / new_status / evidence / cascade_files / blocking_if_unresolved`, with D14/D16/D30/D35/D37 reviewed first but every D item represented.
21. **R3-Q04 Baseline MASTER two-layer update**: How should `baseline-semantic-protocol` preserve `IR=value four-tuple/device×action` while adding `model_visible_surface=D-domain named tools` as a derived layer? Include forbidden wording that prevents future agents from treating generic `device×action` as model-visible surface.
22. **R3-Q05 Progress SSOT**: Which file is the current single source of progress after roadmap-2026-06-20, C5 recovery docs, paradigm amend, and A2 audit diverged? Define `progress_ssot`, `historical_context`, and `superseded_source` states, plus banner/import rules for old roadmap and future dispatches.
23. **R3-Q06 Recipe freeze/reopen rule**: Given latest decisions keep `LR=1e-4`, `rank16Mainline`, repo-loop, and metrics, which recipe knobs are frozen and which are variable? Only define evidence that can reopen recipe after A2 parity, data mix, refusal gates, and G6-C named-tool cell have ruled out surface/data causes.
24. **R3-Q07 Held-out split policy**: Under D-domain named tools and four data classes, how should held-out split across `family`, `value_form`, `utterance_template`, `semantic_parent`, `tool_name`, `generator_source`, `scope_tier`, and `data_class`? Define leakage checks and fail conditions beyond old `parent_overlap`.
25. **R3-Q08 Refusal/IrrelAcc gates**: In four-class data, separate `negative_mix_ratio`, `IrrelAcc`, `false_call_rate`, `unsupported_refusal_acc`, `safety_refusal_acc`, and `positive_regression`. Which gates are independent, what are their denominators, and which failures cannot be offset by aggregate pass rate?
26. **R3-Q09 Generator/judge data recipe**: How do cloud generator, heterogeneous judge, contract label authority, raw oracle redline, and distractor-in-prompt become physical fields? Require `generator_family`, `judge_family`, `judge_family != generator_family`, `per_seed`, `label_authority=contract`, `raw_oracle_source=not_trainable`, duplicate/ambiguous gates, contamination audit, and artifact trail.

## Merge And Dedupe Decisions

- No Round 03 question is deleted.
- R3-Q06 survives only as a veto/reopen rule, not a recipe re-litigation prompt.
- R3-Q01 is scoped away from already-confirmed IR/surface/runtime separation and toward runtime outcome taxonomy.
- R3-Q03 is scoped away from CAS1 full-file cascade and toward D1-D37 decision status.

## Remaining Gaps For Later Rounds

- TRN7-TRN9: mlx-lm feasibility, endpoint parity/structured decoding, DoRA/complex reasoning upgrade timing.
- B1 endpoint parser/whitelist and B2 state-cells/tool-card map need direct questions.
- F1 safety policy boundary and G6 scenario macros remain open.
- UIX1-UIX9 remain untouched.

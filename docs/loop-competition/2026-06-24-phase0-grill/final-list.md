# Phase 0 Grill Final Synthesis

## Verdict

Keep all 24 questions as the final audit set, but do not execute them as 24 parallel workstreams. C01 is merge-only. C08 is blocker only at the mainline contract intersection. C11-C12 numeric choices are hypotheses until spike evidence. The P0 spine is authority, scope, spec disposition, stage, enum/status, held-out/C6, endpoint-parser, and state/golden ownership.

## Acceptance

- User accepted all 24 final candidates on 2026-06-24.
- Archive record: `docs/loop-competition/2026-06-24-phase0-grill/acceptance-archive.md`
- Acceptance does not start retrain/model-eval/demo-golden-run; it authorizes converting the decisions into OpenSpec-ready manifests/tasks.

## Combined Scores And Recommended Conclusions

| ID | Combined Score | Final Priority | User Grill? | Recommended Conclusion |
|---|---:|---|---|---|
| C01 | 20.00 | Merge-only | No | Classify `a2-post-roadmap` as `decision_pack + pre_propose_checklist`, not SSOT, live fact source, or roadmap. Merge this into C02 and stop re-litigating it standalone. |
| C02 | 21.83 | P0 | Required | Create a post-A2 authority matrix: grill-master = decision SSOT, paradigm doc = surface authority, cascade = doc inventory, OpenSpec = future contract carrier, old roadmaps = historical, UIUE branch = consumer until state/C6 IDs stabilize. |
| C03 | 24.83 | P0 | Required | Produce a `full`/`demo` artifact matrix with counts, derivation command, source digest, generated files, consumers, drift gate, and fail-fast behavior. `full` and `demo` must derive from one SSOT. |
| C04 | 24.17 | P0 | Required | Produce an archived-spec disposition table: `no_change`, `MODIFY`, `new_change`, or `docs_cleanup` for each affected spec after D-domain and four-layer C6 changes. |
| C05 | 22.33 | P0 | Required | Publish a Pocock/OpenSpec stage matrix per follow-up: current stage, carrier, exit evidence, and forbidden next action. This blocks jumping from A2 closeout into retrain/apply. |
| C06 | 23.83 | P0 | Review | Define canonical fields/enums across route tier, model-visible surface, runtime scope, execution outcome, readback result, unsupported reason, safety refusal, and status claim. |
| C07 | 21.33 | P0 | Required | Create a decision-status manifest for touched D1-D37 decisions and MASTER protocol: keep/modify/superseded/defer with evidence. Do not bulk-reopen untouched decisions. |
| C08 | 19.50 | P1 with P0 intersection | Conditional | Keep UIUE visual/adoption work out of mainline blockers. Only state-cells, C3/C6 fields, DemoVisualState, tool-card map, and golden IDs remain Phase 0 mainline intersections. |
| C09 | 22.17 | P1 | Required | Record whether failure/error-recovery is excluded, code-rendered, or trained. Default: include only a minimal low-weight seed if parser/load/readback recovery needs it; otherwise explicitly cut and cover via endpoint failure enums. |
| C10 | 20.83 | P1 | Review | Classify `already_state` / state-noop separately from unsupported and safety refusal. Prefer code/readback renderer ownership unless C6 proves model training is needed. |
| C11 | 21.33 | P1 | Required | Put initial category factors in `data_recipe.yaml` as hypotheses, not production truth. Suggested start: positive=20, unsupported=8, safety=4, followup=2, subject to spike evidence. |
| C12 | 22.00 | P1 | Required | Define deterministic-template and cloud-natural-language legs in the same recipe. Start with a template-heavy hypothesis, require same-SSOT digest, dedupe, and spot-check proof. |
| C13 | 24.67 | P0 | Review | Require held-out axes before data generation: family, value form, utterance template, semantic parent, tool name, generator source, scope tier, and data class. |
| C14 | 24.50 | P0 | Required | Define 50/100/150 mid-training C6 gates with sample axes, thresholds, stop/pause/continue actions, and explicit stop-the-train authority. |
| C15 | 22.50 | P0 carrier / P1 execution | Review | Make training-stack spike a hard task inside `retrain-c5`, not an untracked pre-propose spike. It must produce a tiny-epoch receipt before full training. |
| C16 | 21.00 | P1 | Review | Freeze rank16Mainline, LR 1e-4, masking semantics, and core recipe unless evidence excludes surface/data/parity confounders. Define reopen criteria. |
| C17 | 24.50 | P0 | Required | Preserve old base 10/23 as historical failure anchor. Add a new D-domain base recalibration anchor and make it the candidate comparison gate. |
| C18 | 24.67 | P0 | Required | Define C6 scoring layers, denominators, thresholds, and fail priority. No aggregate pass rate may mask golden, fuzz, unsupported, safety, action, patch, or readback failure. |
| C19 | 22.50 | P0 boundary / P1 execution | Required | Start endpoint planning/smoke in parallel with retrain preparation, but forbid endpoint-ready claims before real device/parser/whitelist/LoRA load/TTFT-memory receipts exist. |
| C20 | 24.00 | P0 | Review | Without endpoint GBNF, endpoint policy is LoRA format + defensive JSON parse + whitelist digest + failure enums + fail-closed repair limits. GBNF remains fallback only. |
| C21 | 22.50 | P0 | Required | Treat `tool -> IR -> state_cell -> card -> patch` as a mainline contract artifact. UIUE owns presentation after consuming stable IDs and patch semantics. |
| C22 | 21.33 | P0 entry / P1 execution | Required | Define demo-golden-run entry conditions: stable tool IDs, IR IDs, state_cell IDs, card IDs, C6 case IDs, expected deltas, readback TTS, and `must_pass` flags. Execution remains deferred. |
| C23 | 20.50 | P1 | Review | Define mandatory ground-truth/cross-vendor review triggers for paradigm, SSOT, eval, safety, raw-derived, and release-pass decisions. Include an exclusion list to avoid governance inflation. |
| C24 | 24.67 | P0 | Required | Create a status vocabulary and forbidden-implication table for data readiness, train health, G6-C, C6 model-quality, endpoint candidate, demo-golden, T/V/S/U-PASS. |

## Final P0 Spine

| Group | Candidates | Physical Landing |
|---|---|---|
| Authority and sequencing | C02, C05, C07 | Authority matrix, Pocock stage matrix, decision-status manifest |
| Scope and spec truth | C03, C04 | Artifact matrix, archived-spec disposition table, generated drift proof |
| Shared vocabulary | C06, C24 | Enum/status vocabulary manifest and claim-language rules |
| C5/C6 anti-fake-green | C13, C14, C17, C18 | Held-out axes, mid-training gates, D-domain base anchor, C6 scoring spec |
| Endpoint and runtime safety | C19, C20 | Endpoint evidence checklist, parser/repair/whitelist/failure enum policy |
| State/golden contract boundary | C21, C22 | Tool-state-card map, demo-golden entry contract |

## Final Route

1. Phase 0: close C02/C03/C04/C05/C06/C07/C24 first. These prevent wrong authority, wrong scope, stale specs, wrong stage, vocabulary drift, and pass-label laundering.
2. Phase 1: write the P0 spine into OpenSpec proposal/tasks: C13/C14/C17/C18/C19/C20/C21/C22 plus C09-C12/C15/C16 as gated recipe and feasibility tasks.
3. Phase 2: rebuild C5/C6 artifacts and receipts. Do not train until full/demo SSOT, held-out axes, mid-training gate, base anchor, and C6 denominators are in place.
4. Phase 3: only then run model training, real evaluation, endpoint smoke, and demo-golden-run.
5. Phase 4: UIUE merges only after state-cell, tool-card, C6 case, and golden-run IDs are stable; pure visual improvements remain branch-local until then.

## Do Not Do

- Do not treat `a2-post-roadmap` as the new roadmap or live SSOT.
- Do not run retrain, base recalibration, or endpoint claims before Phase 0 route debt is converted into manifests/tasks.
- Do not let Mac/C6/model-quality evidence imply endpoint readiness or V/S/U-PASS.
- Do not freeze C11/C12 numeric ratios as production values before spike evidence.
- Do not mix UIUE visual backlog with mainline blockers unless it touches state/C3-C6/golden contracts.

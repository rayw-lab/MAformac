# Loop Competition Contract - UIUE R5 Runtime-Presentation Grill Pack Review

## Contract

- status: `ACTIVE_LOOP_COMPETITION`
- date: 2026-06-28
- repo: `/Users/wanglei/workspace/MAformac-uiue`
- branch: `uiue/phase4-default-scope-presentation`
- UIUE HEAD at setup: `70128d8c845d5c5348f56120de3a25740e73deb7`
- mainline repo: `/Users/wanglei/workspace/MAformac`
- mainline branch: `codex/rebuild-c6-doc-absorption-20260624`
- mainline HEAD at setup: `0a2ff0f7d30d6caf2d48f018f6b874828fb70c03`
- rounds: 2
- reviewers per round: 3
- fixed blind candidates: 215 (`C001`-`C215`)
- scoring formula: `Importance + Verifiability + NonDuplication + DecisionLeverage + RiskRevelation`, each 1-5, total 5-25
- proof class: `docs/local + subagent_readonly + controller_judge`
- artifact kind: loop competition evidence, not implementation authorization

## Objective

盲审 `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r5-runtime-presentation-grill-pack-2026-06-28.md` 派生出的 215 个 grill questions, 判断它们是否足够细、是否重复、是否可验证、是否适合后续 mainline/UIUE 双线 burndown。

## Blindness Rules

Reviewers may read:

- `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/candidates-blind.md`
- this `contract.md`
- the source pool listed below, only for verification of current repo facts and authority boundaries

Reviewers must not read:

- `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r5-runtime-presentation-grill-pack-2026-06-28.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/candidate-map-private.md`
- other reviewer files in `round-01/` or `round-02/`
- judge files or ledger, unless explicitly assigned as controller or judge

Reason: the blind candidates must not expose old IDs, priority, route, owner, default recommendation, or controller wording beyond the question itself.

## Source Pool For Verification

Use these to check facts, not to import prior scores:

- `/Users/wanglei/workspace/MAformac-uiue/AGENTS.md`
- `/Users/wanglei/workspace/MAformac-uiue/CLAUDE.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/CURRENT.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/README.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/handoffs/2026-06-28-uiue-r5-readiness-from-r4-closeout.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/handoffs/uiue-r5-readiness-after-mainline-bridge-2026-06-28.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r5-phase1-consumer-grill-2026-06-28.md`
- `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/PresentationSnapshot.swift`
- `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/DemoRuntimeResultPresentationMatrix.swift`
- `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift`
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/runtime-presentation-bridge-phase1-grill-2026-06-28.md`

## Forbidden Claims

No reviewer or judge may claim:

- R5 execution complete
- runtime-ready
- mobile-ready
- true_device proof
- voice-ready
- model-ready
- golden-ready
- endpoint-ready
- UIUE merge-ready
- V-PASS / S-PASS / U-PASS
- A-2 complete

## Reviewer Personas

Round 01:

- `brain-1.md` RED failure auditor: proof-class inflation, fake green, dirty scope, tiger/paper-tiger/elephant, iceberg teardown.
- `brain-2.md` GREEN implementation coordinator: owner/order, file boundaries, test gates, commit split, staging, rerunnable commands.
- `brain-3.md` BLUE UX/HMI designer: user-visible demo quality, touch path, occlusion, hierarchy, a11y, human-review separation.

Round 02:

- `brain-1.md` PURPLE systems architect: SSOT, OpenSpec, DTO boundary, consumer-vs-producer, no third mapper/formatter.
- `brain-2.md` ORANGE test engineer: unit/UI/checker/evidence package, failure diagnostics, fixture gaps, device drift.
- `brain-3.md` BLACK skeptical product judge: customer-visible failure, demo readiness, human-review/L3 boundary, automatic-green anchoring.

## Reviewer Output Schema

Each reviewer must write the assigned markdown file and return only the path plus a short summary.

Required sections:

```markdown
# Brain N - Round XX - PERSONA

## Scope And Blindness
- Files read:
- Forbidden files not read:
- Proof class:

## Executive Verdict
- status: PASS_WITH_NOTES / PARTIAL / BLOCKED
- strongest keep clusters:
- weakest/rewrite clusters:
- merge/drop candidates:
- missing risks:

## Scores
| Candidate | Importance | Verifiability | NonDuplication | DecisionLeverage | RiskRevelation | Total | Verdict | Short reason |
|---|---:|---:|---:|---:|---:|---:|---|---|

## Candidate Notes
| Candidate | Action | Route | Note |
|---|---|---|---|

## Merge / Rewrite / Drop Log
| Candidate(s) | Proposed action | Reason |
|---|---|---|

## Missing Risks Added By This Persona
| Proposed ID | Question | Why it matters | Suggested route | Verification |
|---|---|---|---|---|

## Divergence Forecast
| Candidate | Expected dispute type | Why | Recommended routing |
|---|---|---|---|

## Residual Risk
- ...
```

Coverage gate:

- `## Scores` must contain exactly 215 rows, one for every `C001`-`C215`.
- `## Candidate Notes` should cover all 215 rows. If the reviewer uses cluster notes for low-risk rows, they must still include one row per candidate with `cluster-note` action.
- Verdict options for each candidate: `Keep`, `Rewrite`, `Merge`, `Drop`, `DeferHuman`, `DeferFutureLane`, `Spike`.

## Judge Output Schema

Round judge files must include:

- Inputs and reviewer files.
- Candidate score summary by reviewer.
- Decisions table.
- Merge/drop/rewrite log.
- Divergent candidate table with dispute type: `事实型`, `口径型`, or `混合`.
- Ledger update summary.

Final matrix must include:

`ID | Original ID | Stage | Grill question | R1-RED | R1-GREEN | R1-BLUE | R2-PURPLE | R2-ORANGE | R2-BLACK | Avg | Priority | Route | Action | Recommendation`

## Route Vocabulary

- `mainline_first`
- `uiue_first`
- `main_first_uiue_after`
- `uiue_first_main_after`
- `parallel_with_guard`
- `human_review`
- `future_lane`
- `merge_only`
- `reject_duplicate`
- `spike_required`

## Priority Guidance

- `P0`: blocks R5 dispatch/workstream definition or can create false green/runtime-proof inflation.
- `P1`: materially improves R5 burndown quality, tests, or cross-lane consistency.
- `P2`: valid but lower leverage, merge-only, human taste, or later-lane guard.

## No-Touch Paths

- Do not edit mainline or UIUE code.
- Do not edit `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r5-runtime-presentation-grill-pack-2026-06-28.md`.
- Do not stage, commit, push, or alter git state.
- Write only the assigned `brain-*.md` file.

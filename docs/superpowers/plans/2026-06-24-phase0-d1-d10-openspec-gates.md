---
status: active_plan
artifact_kind: superpowers_implementation_plan
authority: implementation_plan_not_ssot
retire_trigger: "Retire after docs/project/phase0/phase0-d1-d10-closeout.md records completion or this plan is superseded by a newer accepted plan."
expires: "2026-07-15"
---

# Phase0 D1-D10 OpenSpec Gate Plan Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert Phase 0 accepted grill debt and the LoRA zero-failure research into an OpenSpec-ready decision pack and task rewrite plan without starting retrain, real evaluation, endpoint claims, demo-golden-run, voice, or UIUE merge.

**Architecture:** Keep authority and route-control artifacts in `docs/project/phase0/`, then rewrite only the active OpenSpec draft carriers for `retrain-c5-lora-d-domain` and `rebuild-c6-four-layer-bench`. The plan preserves the original `stop-the-train-matrix.md` eight P0 rows, requires D1-D9 plus D10 human review, and treats old C5 recovery roadmaps as historical inputs rather than live route sources.

**Tech Stack:** Markdown governance docs, YAML manifest skeletons, OpenSpec proposal/task files, `rg`, `sed`, `openspec validate`, and bounded subagent audit.

---

## Scope And Non-Goals

This plan is for the next documentation and OpenSpec-draft pass only.

- Do not run LoRA training.
- Do not run D-domain base recalibration.
- Do not run model-quality evaluation.
- Do not claim endpoint readiness, V-PASS, S-PASS, U-PASS, or demo-golden readiness.
- Do not edit runtime Swift, Python training code, contracts under `contracts/`, archived specs under `openspec/specs/`, or UIUE branch files.
- Do not collapse D1-D9 into three decision buckets. Every D item must remain visible to the user.
- Do not replace the original eight stop-the-train rows with the earlier Codex regrouping.

## Final Route Verdict

The main route is correct: the overnight research does not overturn A2 or the post-A2 C5/C6 path. It makes the execution gates stricter.

The corrected route is:

1. Finish Phase 0 route-control materialization.
2. Ask the user to quick-pass D1-D9 and separately review D10.
3. Rewrite retrain-c5 and rebuild-c6 draft task acceptance around the original eight stop-the-train matrix rows.
4. Keep C5 recovery old roadmap as historical evidence unless it is split or bannered.
5. Only after these gates exist in OpenSpec tasks may later work discuss base recalibration, data generation, training, evaluation, endpoint smoke, or demo-golden execution.

## Pre-Mortem

| Class | Failure Mode | Evidence | Mitigation In This Plan |
|---|---|---|---|
| tiger | Original eight stop-the-train rows get silently reshaped into a cleaner but non-source grouping. | `docs/research/2026-06-24-lora-zero-failure-deepdive/stop-the-train-matrix.md` first-tier rows are R-L09, R-L02, R-L03, R-L05, R-L04, R-L07, R-L17, R-L11. | Create a carrier map that preserves those exact row IDs and only lists L08 as linked P1/P0 leakage work, not as a replacement row. |
| tiger | D1-D9 user decisions get laundered into "default" buckets. | `decisions-and-grill-ammo.md` labels D1-D9 as decisions requiring user signoff. | Create a D1-D10 decision pack and require user verdict for each row. Defaults can be fast-pass recommendations, not Codex decisions. |
| tiger | OpenSpec task acceptance becomes prose or metadata instead of physical checks. | R-L11 explicitly warns that gates can become the eleventh fake-green path. | Every new task row must include evidence artifact, computed source, fail-closed action, and owner. |
| tiger | C5 recovery roadmap keeps acting as a third live roadmap. | Phase 0 acceptance says old C5 roadmap must not remain live. | Add a roadmap disposition task: either historical banner or split into C5 recovery roadmap plus A2 post-roadmap plus UIUE roadmap. |
| tiger | C6 or train-health evidence implies endpoint or demo readiness. | C24 status graph forbids train-health -> model-quality and C6 model-quality -> V-PASS implications. | Add status vocabulary references to all closeout language and task acceptance. |
| tiger | UIUE visual backlog leaks back into mainline blockers. | Phase 0 C08 is conditional only at state/C3-C6/golden intersections. | Carrier map lists UIUE only as future consumer for stable IDs and state/golden contracts. |
| paper-tiger | Training stack choice blocks Phase 0. | Overnight research L01 treats local `mlx-lm` capacity as likely adequate; training is not running in this phase. | Keep training-stack tiny receipt as a future retrain-c5 task, not a Phase 0 route blocker. |
| paper-tiger | DPO or PEFT variants must be decided before task rewrite. | D4 and steelman keep SFT mainline and PEFT variants deferred. | Record DPO/DoRA/XGrammar as deferred or escape-hatch rows, not task blockers. |
| elephant | Human review is asked for every row and becomes decision fatigue. | The user wants rigor but also asks for confidence and recommended拍法. | Use fast-pass defaults for low-dispute decisions, but still show each D row and isolate high-attention D2/D3/D6/D7/D10. |
| elephant | A plan document becomes another SSOT. | `a2-post-roadmap` already had this failure mode. | This plan is an implementation plan only; OpenSpec specs and grill SSOT remain authority. |

## File Structure

Files to create during implementation:

- `docs/project/phase0/d1-d10-lora-zero-failure-decision-pack.md`
  - Owns the user-facing D1-D9 plus D10 decision table.
- `docs/project/phase0/stop-the-train-openspec-carrier-map.md`
  - Maps original stop-the-train matrix rows to OpenSpec carriers and acceptance semantics.
- `docs/project/phase0/c5-recovery-roadmap-disposition.md`
  - Records whether the old C5 recovery roadmap is historical, split, or bannered.
- `docs/project/phase0/phase0-d1-d10-closeout.md`
  - Records user decisions, validation commands, and subagent audit verdict after implementation.
- `docs/project/phase0/phase0-d1-d10-user-decision-record.md`
  - Records the user verdict for D1-D10 before OpenSpec draft task rewrites are treated as accepted gate policy.

Files to modify during implementation:

- `openspec/changes/retrain-c5-lora-d-domain/tasks.md`
  - Add acceptance tasks for R-L09, R-L02, R-L03, R-L05, R-L07, R-L11, and R-L17 where they touch C5 retrain.
- `openspec/changes/retrain-c5-lora-d-domain/proposal.md`
  - Add explicit 4-class vs 5-class/failure/status/already-state disposition and D1-D10 decision references.
- `openspec/changes/retrain-c5-lora-d-domain/design.md`
  - Add Architecture Decisions for R-L09/R-L02/R-L03/R-L05/R-L07/R-L11/R-L17 and status boundaries.
- `openspec/changes/rebuild-c6-four-layer-bench/tasks.md`
  - Add acceptance tasks for R-L04, R-L05 C6 sampling dependency, R-L11 anti-fake-green, R-L17 human review evidence, and D-domain base anchor.
- `openspec/changes/rebuild-c6-four-layer-bench/proposal.md`
  - Add four-layer denominator, base-anchor, and status-claim boundaries.
- `openspec/changes/rebuild-c6-four-layer-bench/design.md`
  - Add Architecture Decisions for R-L04/R-L05/R-L11/R-L17, D-domain base anchor semantics, and status boundaries.
- `docs/project/phase0/README.md`
  - Add links to the new decision pack, carrier map, roadmap disposition, and closeout docs.

Files not to modify in this pass:

- `contracts/*`
- `openspec/specs/*`
- `Core/*`
- `Tools/*`
- `Sources/*`
- UIUE branch or UIUE visual docs unless they only receive a pointer after user approval.

## OpenSpec Layering Rule

For `retrain-c5-lora-d-domain` and `rebuild-c6-four-layer-bench`, Architecture Decisions belong in `design.md`; `tasks.md` only carries executable checklist steps and evidence artifacts. If a stop-the-train row defines topology, state machine, source-of-truth strategy, or signing policy, it must be written as an AD before it appears as a task checkbox.

## Task 1: Reconfirm Authority And Read Set

**Files:**
- Read: `CLAUDE.md`
- Read: `docs/project/phase0/README.md`
- Read: `docs/loop-competition/2026-06-24-phase0-grill/final-list.md`
- Read: `docs/research/2026-06-24-lora-zero-failure-deepdive/stop-the-train-matrix.md`
- Read: `docs/research/2026-06-24-lora-zero-failure-deepdive/decisions-and-grill-ammo.md`
- Read: `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md`

- [ ] **Step 1: Verify no live route source changed before editing**

Run:

```bash
git status --short
```

Expected: existing untracked Phase 0 and research docs may be present; no unexpected modifications in `openspec/changes/retrain-c5-lora-d-domain` or `openspec/changes/rebuild-c6-four-layer-bench` unless the executor made them in this task.

- [ ] **Step 2: Verify the first-tier stop-the-train row IDs**

Run:

```bash
rg -n "R-L09|R-L02|R-L03|R-L05|R-L04|R-L07|R-L17|R-L11" docs/research/2026-06-24-lora-zero-failure-deepdive/stop-the-train-matrix.md
```

Expected: each of the eight row IDs appears in the first-tier matrix. If an ID is missing, stop and re-read the matrix before editing.

- [ ] **Step 3: Verify D1-D9 are decision rows**

Run:

```bash
rg -n "^### D[1-9]\\." docs/research/2026-06-24-lora-zero-failure-deepdive/decisions-and-grill-ammo.md
```

Expected: nine rows appear, from D1 through D9.

- [ ] **Step 4: Verify D10 is not already a formal decision**

Run:

```bash
rg -n "already_state|already state|state-noop|noop" docs/research/2026-06-24-lora-zero-failure-deepdive/decisions-and-grill-ammo.md docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md docs/project/phase0
```

Expected: `already_state` is discussed as a finding or candidate gap, not as a D-numbered formal decision. If a formal D10 already exists, update the plan before continuing.

## Task 2: Create D1-D10 Decision Pack

**Files:**
- Create: `docs/project/phase0/d1-d10-lora-zero-failure-decision-pack.md`

- [ ] **Step 1: Add the document header and boundary**

Create the file with this exact opening:

```markdown
---
status: draft
artifact_kind: phase0_decision_pack
authority: route_control_not_ssot
retire_trigger: "Retire after D1-D10 user verdicts are recorded in phase0-d1-d10-closeout.md."
expires: "2026-07-15"
---

# D1-D10 LoRA Zero-Failure Decision Pack

> Status: draft for user quick-pass. This is not an OpenSpec archive, not a live roadmap, and not permission to train, evaluate, claim endpoint readiness, execute demo-golden-run, run voice, or merge UIUE.

## Authority

- Source decisions D1-D9: `docs/research/2026-06-24-lora-zero-failure-deepdive/decisions-and-grill-ammo.md`
- Source first-tier gates: `docs/research/2026-06-24-lora-zero-failure-deepdive/stop-the-train-matrix.md`
- Phase 0 acceptance: `docs/loop-competition/2026-06-24-phase0-grill/acceptance-archive.md`
- OpenSpec draft carriers: `openspec/changes/retrain-c5-lora-d-domain` and `openspec/changes/rebuild-c6-four-layer-bench`
```

- [ ] **Step 2: Add the D1-D10 decision table**

Add this table after the authority block:

```markdown
## Decisions To Quick-Pass Or Review

| Decision | Default Recommendation | Requires User Eye | Why It Matters | Carrier |
|---|---|---:|---|---|
| D1 C6 action hard-pass denominator | Use case-schema denominators; preserve old 10/23 as historical anchor only until D-domain base is recalibrated. | Yes | Prevents aggregate denominator masking. | `rebuild-c6-four-layer-bench` |
| D2 mid-training stop-the-train four-state gate | Use iter50/100/150 behavior generation gate with `continue`, `human_pause`, `early_stop`, `blocked`. | Yes | Prevents another loss-healthy behavior-collapse run. | `retrain-c5-lora-d-domain` plus C6 sampling |
| D3 data class ratio | Treat ratios as spike hypotheses; start near 15-20 percent negative, not a frozen production value. | Yes | Prevents over-refusal or over-call from hard-coded recipe guesses. | `retrain-c5-lora-d-domain` |
| D4 SFT vs DPO | Keep SFT positive/refusal examples plus IrrelAcc gate as mainline; DPO remains deferred. | Yes | Avoids method churn before data/surface gates are fixed. | `retrain-c5-lora-d-domain` |
| D5 endpoint byte-parity gate | Write endpoint render dump as a future gate task; current state is blocked, not pass. | Fast-pass | Prevents endpoint nil render from becoming fake parity. | `retrain-c5-lora-d-domain` |
| D6 general Chinese mix and regression | Add as spike hypothesis with C-Eval/CMMLU or equivalent regression gate; do not freeze ratio. | Yes | Prevents narrow SFT from erasing general Chinese robustness. | `retrain-c5-lora-d-domain` |
| D7 failure/error-recovery class | Cut full failure chain by default; allow only minimal parser/load/readback recovery seed if explicitly approved. | Yes | Prevents silent 4-class vs 5-class drift. | `retrain-c5-lora-d-domain` |
| D8 constrained decoding engine | Keep XGrammar or grammar decoding as P1 escape hatch; grammar must include refusal/no-op branch. | Fast-pass | Prevents syntax constraints from hiding semantic collapse. | endpoint/golden future carrier |
| D9 next OpenSpec boundary | Update retrain-c5 and rebuild-c6 tasks first; do not run training, eval, voice, endpoint, or demo-golden. | Fast-pass | Preserves A2 deferred boundary. | both active OpenSpec drafts |
| D10 already_state/state-noop classification | Treat `already_state` as separate from unsupported and safety; default owner is code/readback renderer unless C6 evidence proves model training is needed. | Yes | Prevents semantic pollution of refusal/status classes. | `retrain-c5-lora-d-domain`, C24 status vocabulary |
```

- [ ] **Step 3: Add the recommended拍法 section**

Add this exact section:

```markdown
## Recommended拍法

- Fast-pass: D5, D8, D9, unless the user wants to reopen endpoint decoding or A2 boundaries.
- Human review: D1, D2, D3, D4, D6, D7, D10.
- No Codex self-approval: every row remains visible; defaults are recommendations only.
- Do not use the earlier three-bucket grouping as the decision record.
```

- [ ] **Step 4: Verify the file avoids permission creep**

Run:

```bash
rg -n "permission to train|start retrain|V-PASS|endpoint readiness|demo-golden" docs/project/phase0/d1-d10-lora-zero-failure-decision-pack.md
```

Expected: every hit appears in a prohibition or boundary sentence, not as an authorization.

- [ ] **Step 5: Stop for user decision checkpoint before Task 4 or Task 5**

Create `docs/project/phase0/phase0-d1-d10-user-decision-record.md` with this exact structure:

```markdown
---
status: draft
artifact_kind: phase0_user_decision_record
authority: route_control_not_ssot
retire_trigger: "Retire after all D1-D10 rows are non-pending and closeout records the final verdicts."
expires: "2026-07-15"
---

# Phase 0 D1-D10 User Decision Record

> Status: pending user decision. Do not treat retrain-c5 or rebuild-c6 gate rewrites as accepted policy until every row below is either accepted, modified, or explicitly deferred by the user.

| Decision | User Verdict | Notes |
|---|---|---|
| D1 C6 action hard-pass denominator | pending |  |
| D2 mid-training stop-the-train four-state gate | pending |  |
| D3 data class ratio | pending |  |
| D4 SFT vs DPO | pending |  |
| D5 endpoint byte-parity gate | pending |  |
| D6 general Chinese mix and regression | pending |  |
| D7 failure/error-recovery class | pending |  |
| D8 constrained decoding engine | pending |  |
| D9 next OpenSpec boundary | pending |  |
| D10 already_state/state-noop classification | pending |  |
```

Stop after creating this file and ask the user to quick-pass or revise D1-D10. Task 4 and Task 5 may only proceed before user decision if their inserted sections are explicitly labeled `draft pending user decision`.

## Task 3: Create Original Stop-The-Train Carrier Map

**Files:**
- Create: `docs/project/phase0/stop-the-train-openspec-carrier-map.md`

- [ ] **Step 1: Add the carrier map header**

Create the file with this exact opening:

```markdown
---
status: draft
artifact_kind: phase0_carrier_map
authority: route_control_not_ssot
retire_trigger: "Retire after the mapped gate rows are represented in OpenSpec design.md and tasks.md, and closeout records the mapping."
expires: "2026-07-15"
---

# Stop-the-Train OpenSpec Carrier Map

> Status: draft carrier map. This file preserves the original first-tier eight rows from `stop-the-train-matrix.md`; it does not use the earlier regrouped Codex version as the canonical gate list.

## Canonical First-Tier Rows

The canonical first-tier stop-the-train rows are:

1. R-L09 sample observability
2. R-L02 train/eval/runtime surface source
3. R-L03 chat-template byte parity
4. R-L05 mid-training behavior gate
5. R-L04 C6 four-layer denominators
6. R-L07 data recipe and negative classes
7. R-L17 human review and deframing
8. R-L11 anti-fake-green gate integrity
```

- [ ] **Step 2: Add the row-to-carrier table**

Add this exact table:

```markdown
## Row To Carrier Mapping

| Row | OpenSpec Carrier | Acceptance Must Include | Fail-Closed Action |
|---|---|---|---|
| R-L09 | `retrain-c5-lora-d-domain/tasks.md` | Compute `no_call_target_present` from actual sample `tools`, not metadata; require `label_conflict_flag == 0`; emit distribution receipt. | Block data generation or training preflight with exit 65. |
| R-L02 | `retrain-c5-lora-d-domain/tasks.md` and `rebuild-c6-four-layer-bench/tasks.md` | Compare train/eval/runtime D-domain surface digest from a single source; reject generic `tool_call_frame` residue. | Block retrain and C6 rebuild until digests match. |
| R-L03 | `retrain-c5-lora-d-domain/tasks.md` | Compare training render bytes, endpoint render bytes, think signature, and mask offset start token; nil endpoint render is blocked. | Candidate remains unsigned. |
| R-L05 | `retrain-c5-lora-d-domain/tasks.md` with C6 dependency | Run iter50/100/150 behavior generation sample gates on A2 same-source surface; record `continue`, `human_pause`, `early_stop`, or `blocked`. | Stop or pause training before full run completion. |
| R-L04 | `rebuild-c6-four-layer-bench/tasks.md` | Derive layer denominators from case schema fields, not aggregate totals; reject all aggregate pass-rate substitution. | Reject C6 gate design. |
| R-L07 | `retrain-c5-lora-d-domain/tasks.md` | Keep positive, unsupported, safety, and followup classes; ratios are spike hypotheses; IrrelAcc must not regress below active base anchor. | Block recipe freeze or candidate signing. |
| R-L17 | both OpenSpec task files plus closeout | Require seven human review points and at least one deliberate deframing review; high-stakes route decisions cannot be signed by model consensus alone. | Reject closeout if review is receipt-only. |
| R-L11 | both OpenSpec task files plus verification closeout | Gates must compute from first-hand artifacts; grader failure means UNSIGNED; pass^k and hardPassVariance must be enforced when claimed. | Candidate remains UNSIGNED/BLOCKED. |
```

- [ ] **Step 3: Add linked-but-not-canonical rows**

Add this section:

```markdown
## Linked Rows Not Replacing The Canonical Eight

- R-L08 leakage gate is required for data-gate integrity and must be carried into retrain-c5, but it does not replace R-L11 in the original first-tier eight.
- R-L10 general Chinese regression, R-L12 SFT-vs-DPO, R-L06 constrained decoding, R-L18 voice-side augmentation, R-L13 hyperparameters, R-L01 training stack, R-L14 PEFT variants, and R-L16 governance-enforcement are recorded as second-tier or future linked risks according to the matrix.
```

- [ ] **Step 4: Verify canonical rows are preserved exactly once**

Run:

```bash
for id in R-L09 R-L02 R-L03 R-L05 R-L04 R-L07 R-L17 R-L11; do
  count=$(rg -o "$id" docs/project/phase0/stop-the-train-openspec-carrier-map.md | wc -l | tr -d ' ')
  test "$count" -ge 2 || { echo "missing $id"; exit 1; }
done
echo "canonical stop-the-train rows present"
```

Expected: `canonical stop-the-train rows present`.

## Task 4: Update Retrain-C5 Draft Tasks And Proposal

**Files:**
- Modify: `openspec/changes/retrain-c5-lora-d-domain/tasks.md`
- Modify: `openspec/changes/retrain-c5-lora-d-domain/proposal.md`
- Create or modify: `openspec/changes/retrain-c5-lora-d-domain/design.md`

- [ ] **Step 1: Add Architecture Decisions to design.md**

Create or update `openspec/changes/retrain-c5-lora-d-domain/design.md` with an `## Architecture Decisions` section containing:

```markdown
## Architecture Decisions

### AD-C5-001: D-domain surface is a single-source train/eval/runtime contract
R-L02 is an architecture decision. Train, eval, and runtime surface digests must derive from the same A2 D-domain source. `tool_call_frame` residue blocks retrain.

### AD-C5-002: Sample observability is computed from physical tools, not metadata
R-L09 is an architecture decision. No-call target presence must be computed from the actual sample `tools` field, and `label_conflict_flag` must be zero.

### AD-C5-003: Endpoint byte parity is blocked until endpoint render bytes exist
R-L03 is an architecture decision. Nil endpoint render cannot pass byte parity. Training render bytes, endpoint render bytes, think signature, and mask offset start token are separate evidence fields.

### AD-C5-004: Mid-training behavior gate is a four-state stop-the-train mechanism
R-L05 is an architecture decision. The state machine is `continue | human_pause | early_stop | blocked`; val loss alone cannot authorize continuation.

### AD-C5-005: Data recipe keeps negative/refusal classes and treats ratios as hypotheses
R-L07 is an architecture decision. Positive, unsupported, safety, and followup classes remain present; ratio values are spike hypotheses until evidence freezes them.

### AD-C5-006: Gate integrity is sign-or-block
R-L11 is an architecture decision. First-hand artifacts, not metadata claims, decide pass status. Grader failure leaves candidate `UNSIGNED/BLOCKED`.

### AD-C5-007: Human review is required for high-stakes route decisions
R-L17 is an architecture decision. Codex subagent review is same-vendor pre-check only; final high-stakes signoff requires an explicitly deframing heterogeneous review or a recorded user waiver.

### AD-C5-008: Train health is not model quality
`train_health`, loss health, and training receipts do not imply `model_quality`, `lora_candidate`, `endpoint_candidate`, V-PASS, or demo readiness.
```

- [ ] **Step 2: Add a Phase 0 gate rewrite section to tasks**

Insert this section after the existing dependency section in `tasks.md`:

```markdown
## Phase 0 Gate Rewrite Before Any Retrain

- [ ] 2.5.G1 R-L09 sample observability gate: compute `no_call_target_present` from actual sample `tools`, compute `label_conflict_flag`, emit per-class receipt distributions, and fail closed with exit 65 on any target-present no-call or label conflict. AD: AD-C5-002.
- [ ] 2.5.G2 R-L02 surface-source gate: train/eval/runtime D-domain surface digest must come from the same A2 source; `tool_call_frame` residue blocks retrain. AD: AD-C5-001.
- [ ] 2.5.G3 R-L03 byte-parity gate: compare training render bytes, endpoint render bytes, think signature, and mask offset start token; nil endpoint render is blocked rather than pass. AD: AD-C5-003.
- [ ] 2.5.G4 R-L05 mid-training behavior gate: define iter50/100/150 behavior generation samples, parse tool calls, run C6 first/second layer samples, and record `continue`, `human_pause`, `early_stop`, or `blocked`. AD: AD-C5-004.
- [ ] 2.5.G5 R-L07 data recipe gate: preserve positive/unsupported/safety/followup classes, treat ratios as spike hypotheses, and block if IrrelAcc regresses below the active base anchor. AD: AD-C5-005.
- [ ] 2.5.G6 R-L11 gate-integrity gate: every pass claim must be computed from first-hand artifacts; grader failure keeps candidate `UNSIGNED/BLOCKED`. AD: AD-C5-006.
- [ ] 2.5.G7 R-L17 human review gate: require first-50 sample review, loss-mask print review, train-eval template diff, refusal sample review, top failing C6 case review, utterance drift review, and final route deframing review. AD: AD-C5-007.
```

- [ ] **Step 3: Add a D1-D10 decision reference section to proposal**

Insert this section before `## Non-Goals` in `proposal.md`:

```markdown
## Phase 0 Decisions Required Before Apply

This draft depends on user review of D1-D9 from `docs/research/2026-06-24-lora-zero-failure-deepdive/decisions-and-grill-ammo.md` plus D10 `already_state/state-noop` classification from the Phase 0 decision pack.

- Failure/error-recovery is not silently dropped; D7 records whether the full chain is cut or a minimal seed is retained.
- `already_state` is not collapsed into unsupported or safety refusal; D10 records whether code/readback renderer or model training owns it.
- Data ratios and general Chinese mix are hypotheses until spike receipts exist.
- `train_health`, loss health, and training receipts do not imply `model_quality`, `lora_candidate`, `endpoint_candidate`, V-PASS, or demo readiness. A candidate remains `UNSIGNED/BLOCKED` until C6 model-quality gates and required human reviews pass.
- Training, real evaluation, endpoint-ready claims, voice, and demo-golden execution remain deferred until gate tasks are accepted.
```

- [ ] **Step 4: Verify retrain design and tasks carry the canonical rows**

Run:

```bash
rg -n "R-L09|R-L02|R-L03|R-L05|R-L07|R-L11|R-L17" openspec/changes/retrain-c5-lora-d-domain/design.md openspec/changes/retrain-c5-lora-d-domain/tasks.md
```

Expected: all seven row IDs appear in design.md Architecture Decisions and tasks.md gate rewrite section. R-L04 belongs primarily to rebuild-c6.

- [ ] **Step 5: Verify retrain proposal blocks early apply**

Run:

```bash
rg -n "Before Apply|deferred|UNSIGNED|already_state|Failure/error-recovery" openspec/changes/retrain-c5-lora-d-domain/proposal.md
```

Expected: hits show decision and deferred boundaries, not training authorization.

## Task 5: Update Rebuild-C6 Draft Tasks And Proposal

**Files:**
- Modify: `openspec/changes/rebuild-c6-four-layer-bench/tasks.md`
- Modify: `openspec/changes/rebuild-c6-four-layer-bench/proposal.md`
- Create or modify: `openspec/changes/rebuild-c6-four-layer-bench/design.md`

- [ ] **Step 1: Add Architecture Decisions to C6 design.md**

Create or update `openspec/changes/rebuild-c6-four-layer-bench/design.md` with an `## Architecture Decisions` section containing:

```markdown
## Architecture Decisions

### AD-C6-001: Four-layer denominators derive from case schema fields
R-L04 is an architecture decision. C6 must not use aggregate pass rate as a substitute for golden, demo_fuzz, unsupported, safety, action, clarify, or readback denominators.

### AD-C6-002: D-domain base anchor is comparison evidence, not permission to run during Phase 0
The historical 10/23 anchor remains failure evidence until D-domain base recalibration is separately authorized and executed. This design records the future anchor semantics only.

### AD-C6-003: C6 exposes sampling support for C5 mid-training behavior gates
R-L05 creates a dependency from retrain-c5 to C6 sample runners. This support does not make C6 release cases a checkpoint-selection oracle.

### AD-C6-004: C6 gate integrity is sign-or-block
R-L11 is an architecture decision. pass^k and hardPassVariance must be enforced when claimed, and grader failure keeps the candidate unsigned.

### AD-C6-005: Human deframing review is required before closeout
R-L17 is an architecture decision. Top failing cases and denominator construction require deliberate deframing review.

### AD-C6-006: C6 model quality does not imply endpoint or demo readiness
C6 evidence does not imply endpoint readiness, demo-golden readiness, V-PASS, S-PASS, or U-PASS. Readback renderer evidence remains separate from model hard-pass evidence.
```

- [ ] **Step 2: Add a Phase 0 gate rewrite section to C6 tasks**

Insert this section after the existing dependency section:

```markdown
## Phase 0 Gate Rewrite Before Any C6 Rebuild

- [ ] 3.5.G1 R-L04 denominator gate: derive golden, demo_fuzz, unsupported, safety, action, clarify, and readback denominators from case schema fields; reject aggregate pass-rate substitution. AD: AD-C6-001.
- [ ] 3.5.G2 D-domain base anchor: preserve old 10/23 as historical failure evidence and define the future D-domain base anchor before candidate comparison. This is not permission to run recalibration in Phase 0. AD: AD-C6-002.
- [ ] 3.5.G3 R-L05 sampling support: expose C6 first/second layer sample runner usable by retrain-c5 iter50/100/150 behavior gates. AD: AD-C6-003.
- [ ] 3.5.G4 R-L11 anti-fake-green enforcement: enforce pass^k and hardPassVariance when claimed; grader failure keeps candidate unsigned. AD: AD-C6-004.
- [ ] 3.5.G5 R-L17 human review evidence: require deframing review of top failing cases and denominator construction before closeout. AD: AD-C6-005.
```

- [ ] **Step 3: Add C6 status boundary language to proposal**

Insert this section before `## Non-Goals`:

```markdown
## Status Boundary

C6 model-quality evidence does not imply endpoint readiness, demo-golden readiness, V-PASS, S-PASS, or U-PASS. D-domain base recalibration is a comparison anchor, not a LoRA candidate success claim. Readback renderer evidence remains separate from model hard-pass evidence.
```

This status boundary defines future OpenSpec acceptance language only. It is not permission to run D-domain base recalibration during this Phase 0 documentation pass.

- [ ] **Step 4: Verify C6 rows and status boundary**

Run:

```bash
rg -n "R-L04|R-L05|R-L11|R-L17|D-domain base anchor|does not imply endpoint readiness" openspec/changes/rebuild-c6-four-layer-bench/design.md openspec/changes/rebuild-c6-four-layer-bench/tasks.md openspec/changes/rebuild-c6-four-layer-bench/proposal.md
```

Expected: every phrase appears in the new C6 sections.

## Task 6: Record C5 Recovery Roadmap Disposition

**Files:**
- Create: `docs/project/phase0/c5-recovery-roadmap-disposition.md`

- [ ] **Step 1: Add disposition verdict**

Create the file with this exact content:

```markdown
---
status: draft
artifact_kind: roadmap_disposition
authority: route_control_not_ssot
retire_trigger: "Retire after all referenced roadmaps have explicit historical/superseded/live banners."
expires: "2026-07-15"
---

# C5 Recovery Roadmap Disposition

## Verdict

`docs/c5-recovery-2026-06-22/roadmap.md` keeps historical and diagnostic value, but it must not remain the live roadmap after A2 and Phase 0.

`docs/roadmap-2026-06-20-from-c6-done.md` is also historical after Q22 and must not be used as the current route source, even though it remains useful for five-piece harness provenance.

## Recommended Structure

1. C5 recovery roadmap: keep C5 technical recovery only, including D-domain base recalibration, data recipe, training gates, C6 interaction, parity, and endpoint sign boundaries.
2. A2 post-roadmap decision pack: keep model-quality decisions, home-llm comparison, and stop-the-train gates as pre-propose input, not SSOT.
3. UIUE roadmap: keep visual and state-consumption work in `uiue/visual-ssot-state-consume`, exposing only state/C3-C6/golden intersections to mainline.

## Required Banner If The Old Roadmap Remains

The top of the old roadmap must say: "Historical recovery roadmap. Not live route source after Phase 0. Current execution source is the accepted Phase 0 manifest set plus active OpenSpec proposal/tasks."

The old `docs/roadmap-2026-06-20-from-c6-done.md` banner must also say: "Historical roadmap. Not current route source after Q22 and A2; use grill SSOT, paradigm authority, cascade inventory, Phase 0 manifests, and active OpenSpec drafts."

## Forbidden Uses

- Do not use the old roadmap to start retrain.
- Do not use the old roadmap to bypass D1-D10 user review.
- Do not use the old roadmap to claim C6, endpoint, or demo readiness.
```

- [ ] **Step 2: Link disposition from Phase 0 README**

Add this bullet under the Phase 0 README current state or source list:

```markdown
- Roadmap disposition: `docs/project/phase0/c5-recovery-roadmap-disposition.md`
```

- [ ] **Step 3: Verify the old roadmap is not promoted**

Run:

```bash
rg -n "live roadmap|live route source|current execution source|historical" docs/project/phase0/c5-recovery-roadmap-disposition.md docs/project/phase0/README.md
```

Expected: references describe the old roadmap as historical or dispositioned, not live.

## Task 7: Validate, Audit, And Close Out

**Files:**
- Modify: `docs/project/phase0/README.md`
- Create: `docs/project/phase0/phase0-d1-d10-closeout.md`
- Create: `docs/project/phase0/phase0-d1-d10-subagent-audit.md`

- [ ] **Step 1: Run OpenSpec validation after task/proposal edits**

Run:

```bash
openspec validate retrain-c5-lora-d-domain --strict
openspec validate rebuild-c6-four-layer-bench --strict
openspec validate --all --strict
```

Expected: all three commands pass. If validation fails due to draft structure, fix the OpenSpec markdown structure only; do not weaken gate language.

- [ ] **Step 2: Run targeted drift grep**

Run:

```bash
rg -n "start retrain|run training|endpoint-ready|V-PASS|demo-golden.*ready|tool_call_frame" docs/project/phase0 openspec/changes/retrain-c5-lora-d-domain openspec/changes/rebuild-c6-four-layer-bench
```

Expected: `start retrain`, `endpoint-ready`, `V-PASS`, and `demo-golden ready` hits are boundary or prohibition language. `tool_call_frame` hits must be negative examples or residue blockers.

- [ ] **Step 3: Ask a Codex subagent to audit the full file cascade**

Use this audit prompt:

```text
You are a skeptical Codex reviewer for MAformac Phase 0 route-control work. This is a same-vendor pre-check only, not the final heterogeneous deframing review required by R-L17. Read the full main-branch cascade touched or referenced by this plan:
- CLAUDE.md
- docs/README.md
- docs/project/collaboration-and-roles.md
- docs/project/phase0/README.md
- docs/project/phase0/d1-d10-lora-zero-failure-decision-pack.md
- docs/project/phase0/stop-the-train-openspec-carrier-map.md
- docs/project/phase0/c5-recovery-roadmap-disposition.md
- openspec/changes/retrain-c5-lora-d-domain/proposal.md
- openspec/changes/retrain-c5-lora-d-domain/design.md
- openspec/changes/retrain-c5-lora-d-domain/tasks.md
- openspec/changes/rebuild-c6-four-layer-bench/proposal.md
- openspec/changes/rebuild-c6-four-layer-bench/design.md
- openspec/changes/rebuild-c6-four-layer-bench/tasks.md
- docs/research/2026-06-24-lora-zero-failure-deepdive/stop-the-train-matrix.md
- docs/research/2026-06-24-lora-zero-failure-deepdive/decisions-and-grill-ammo.md
- docs/superpowers/plans/2026-06-24-phase0-d1-d10-openspec-gates.md

Audit only. Do not edit files. Verdict must be one of CLEAR, CLEAR_WITH_FIXES, or BLOCKED.

Check:
1. Did the implementation preserve the original first-tier eight stop-the-train rows R-L09/R-L02/R-L03/R-L05/R-L04/R-L07/R-L17/R-L11?
2. Did it keep D1-D9 visible and add D10 as a separate candidate rather than hiding it?
3. Did it avoid authorizing training, model-quality evaluation, endpoint-ready claims, demo-golden-run, voice, or UIUE merge?
4. Did it route architecture decisions into design.md and executable evidence steps into tasks.md, instead of burying AD-level choices in task checkboxes?
5. Did it avoid treating a2-post-roadmap, docs/roadmap-2026-06-20-from-c6-done.md, or c5-recovery roadmap as SSOT/live roadmap?
6. Did it preserve status-vocabulary boundaries so train-health/C6 evidence cannot imply endpoint/V-PASS/demo readiness?
7. Did every new Phase 0 route-control doc have status/retire metadata or a clear retirement trigger?
8. Did docs/superpowers/plans either get documented as an accepted plan path or remain clearly marked implementation-plan-not-SSOT?

Return findings by P0/P1/P2 with file references and a final recommendation.
```

- [ ] **Step 4: Save the audit result**

Save the subagent result to:

```text
docs/project/phase0/phase0-d1-d10-subagent-audit.md
```

The saved audit must include the subagent verdict, findings, and whether any P0/P1 issue blocks implementation.

This Codex subagent audit is not a substitute for R-L17 heterogeneous deframing review. The closeout must say whether the heterogeneous review is complete, deferred with user approval, or still blocking candidate/signoff claims.

- [ ] **Step 5: Create closeout**

Create `docs/project/phase0/phase0-d1-d10-closeout.md` with:

```markdown
# Phase 0 D1-D10 Closeout

## Status

- Decision pack created:
- User decision record:
- Carrier map created:
- C5 recovery roadmap disposition created:
- OpenSpec draft tasks updated:
- OpenSpec validation:
- Codex same-vendor cascade audit:
- Heterogeneous deframing review:

## Remaining User Decisions

- D1:
- D2:
- D3:
- D4:
- D5:
- D6:
- D7:
- D8:
- D9:
- D10:

## Not Started

- LoRA training
- D-domain base recalibration run
- Real model-quality evaluation
- Endpoint-ready claim
- Demo-golden-run execution
- Voice
- UIUE merge
```

Fill every bullet with a concrete value before closeout. If a user decision is not yet made, write `pending user decision` for that row.

Task 4 and Task 5 are not accepted gate policy while any D1-D10 row is `pending user decision`; they remain draft proposal/task rewrite text only.

If any route-control document still has `status: draft`, the closeout must either retire it, mark it active with explicit owner and expiry, or record a user-approved reason for keeping it draft.

- [ ] **Step 6: Final verification**

Run:

```bash
git diff -- docs/project/phase0 openspec/changes/retrain-c5-lora-d-domain openspec/changes/rebuild-c6-four-layer-bench
```

Expected: only documentation and OpenSpec draft proposal/task changes appear. No code, generated artifacts, training data, model weights, or contracts changes appear.

## Self-Review Checklist

- [ ] The plan preserves the original first-tier stop-the-train eight rows.
- [ ] D1-D9 remain individually visible.
- [ ] D10 `already_state/state-noop` is separate and not hidden inside D7 or C10.
- [ ] D1-D10 user decisions are recorded before OpenSpec task rewrites are treated as accepted gate policy.
- [ ] `train_health`, loss health, and training receipt claims do not imply model-quality, signed candidate, endpoint, V-PASS, or demo readiness.
- [ ] AD-level choices are in OpenSpec `design.md`, while `tasks.md` only carries executable steps and evidence artifacts.
- [ ] Codex subagent audit is treated as same-vendor pre-check, not a substitute for heterogeneous deframing review.
- [ ] New route-control docs have status and retirement metadata.
- [ ] Numeric recipe values are hypotheses, not frozen production truth.
- [ ] Old 10/23 base is historical until D-domain base recalibration.
- [ ] C5 recovery roadmap is historical or split, not live SSOT.
- [ ] UIUE remains isolated except for stable state/C3-C6/golden interfaces.
- [ ] No task authorizes training, real evaluation, endpoint readiness, demo-golden-run, voice, or UIUE merge.
- [ ] Subagent audit is saved before closeout.

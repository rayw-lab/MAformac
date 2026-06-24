---
status: active_plan
artifact_kind: superpowers_implementation_plan
authority: implementation_plan_not_ssot
baseline_status: accepted_as_baseline_with_open_items
retire_trigger: "Retire after docs/project/phase0/phase0-d1-d10-closeout.md records completion or this plan is superseded by a newer accepted plan."
expires: "2026-07-15"
---

# Phase0 D1-D10 OpenSpec Gate Plan Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert Phase -1 default-scope route correction plus Phase 0 accepted grill debt and LoRA zero-failure research into OpenSpec-ready decision/task carriers without starting retrain, real evaluation, endpoint claims, demo-golden-run, voice, or UIUE merge.

**Architecture:** Run a Phase -1 dependency correction first: promote accepted demo default-scope G01-G28 into its own OpenSpec change, then let Phase 0 D1-D10 gates reference that carrier instead of burying scope semantics inside C5/C6 tasks. Keep authority and route-control artifacts in `docs/project/phase0/`, then rewrite only the active OpenSpec draft carriers for `retrain-c5-lora-d-domain` and `rebuild-c6-four-layer-bench`. The plan preserves the original `stop-the-train-matrix.md` eight P0 rows, requires D1-D9 plus D10 human review, and treats old C5 recovery roadmaps as historical inputs rather than live route sources.

**Tech Stack:** Markdown governance docs, YAML manifest skeletons, OpenSpec proposal/task files, `rg`, `sed`, `openspec validate`, and bounded subagent audit.

**Baseline Verdict:** This plan is accepted as a baseline with open items, not as a final baseline. D1-D10 user decisions are now accepted in `docs/project/phase0/phase0-d1-d10-user-decision-record.md`; R-L17 heterogeneous deframing, AD-DS trace provenance, OpenSpec carrier acceptance, physical evidence gates, and UIUE worktree pinning must remain mechanically visible until closed.

**Status Update 2026-06-24:** Do not recreate the older pending D1-D10 template or reset `pending_user_decision`. If the decision record already exists with accepted verdicts, keep it as the authority and continue into Phase -1 / OpenSpec carrier work.

**Status Update 2026-06-24 Later:** Phase -1 default-scope carrier materialization is accepted for apply. UIUE HEAD `f1096d7` in this historical plan is superseded by current unverified external reference `17f2af1`; do not use UIUE file:line evidence until a fresh UIUE reconfirm pass. Runtime implementation now belongs to `docs/superpowers/plans/2026-06-24-default-scope-apply.md`, not to this umbrella plan.

**Status Update 2026-06-24 Closeout:** Default-scope apply-plan same-vendor pre-check returned `CLEAR_WITH_FIXES` and was absorbed in `docs/superpowers/plans/2026-06-24-default-scope-apply.md`. Do not rerun Phase -1 from this umbrella plan unless the active carrier is superseded; use the apply plan for implementation.

---

## Scope And Non-Goals

This plan is for the next documentation and OpenSpec-draft pass only.

- Do not run LoRA training.
- Do not run D-domain base recalibration.
- Do not run model-quality evaluation.
- Do not claim endpoint readiness, V-PASS, S-PASS, U-PASS, or demo-golden readiness.
- Do not edit runtime Swift, Python training code, contracts under `contracts/`, archived specs under `openspec/specs/`, or UIUE branch files.
- Do not implement `default_scope` in Phase -1. Phase -1 only creates/updates route-control and OpenSpec proposal/design/tasks/spec deltas.
- Do not collapse D1-D9 into three decision buckets. Every D item must remain visible to the user.
- Do not replace the original eight stop-the-train rows with the earlier Codex regrouping.

## Final Route Verdict

The main route is correct: the overnight research does not overturn A2 or the post-A2 C5/C6 path. It makes the execution gates stricter.

The corrected route is:

0. Finish Phase -1 default-scope dependency correction: create `define-demo-default-scope` as the carrier for G01-G28, including UIUE intersection decisions and C2/C3/C5/C6/readback/golden dependencies.
1. Finish Phase 0 route-control materialization.
2. Use the accepted D1-D10 user decision record as the decision source.
3. Rewrite retrain-c5 and rebuild-c6 draft task acceptance around the original eight stop-the-train matrix rows, plus dependency blockers on `define-demo-default-scope`.
4. Keep C5 recovery old roadmap as historical evidence unless it is split or bannered.
5. Only after these gates exist in OpenSpec tasks may later work discuss base recalibration, data generation, training, evaluation, endpoint smoke, or demo-golden execution.

## Pre-Mortem

| Class | Failure Mode | Evidence | Mitigation In This Plan |
|---|---|---|---|
| tiger | Original eight stop-the-train rows get silently reshaped into a cleaner but non-source grouping. | `docs/research/2026-06-24-lora-zero-failure-deepdive/stop-the-train-matrix.md` first-tier rows are R-L09, R-L02, R-L03, R-L05, R-L04, R-L07, R-L17, R-L11. | Create a carrier map that preserves those exact row IDs and only lists L08 as linked P1/P0 leakage work, not as a replacement row. |
| tiger | D1-D9 user decisions get laundered into "default" buckets. | `decisions-and-grill-ammo.md` labels D1-D9 as decisions requiring user signoff. | Create a D1-D10 decision pack and require user verdict for each row. Defaults can be fast-pass recommendations, not Codex decisions. |
| tiger | D1-D10 accepted verdicts get mistaken for execution authorization. | User decisions are necessary but not OpenSpec acceptance or physical evidence. | Keep closeout partial until OpenSpec carriers, R-L17, and physical gates are closed. |
| tiger | OpenSpec task acceptance becomes prose or metadata instead of physical checks. | R-L11 explicitly warns that gates can become the eleventh fake-green path. | Every new task row must include evidence artifact, computed source, fail-closed action, and owner. |
| tiger | C5 recovery roadmap keeps acting as a third live roadmap. | Phase 0 acceptance says old C5 roadmap must not remain live. | Add a roadmap disposition task: either historical banner or split into C5 recovery roadmap plus A2 post-roadmap plus UIUE roadmap. |
| tiger | C6 or train-health evidence implies endpoint or demo readiness. | C24 status graph forbids train-health -> model-quality and C6 model-quality -> V-PASS implications. | Add status vocabulary references to all closeout language and task acceptance. |
| tiger | UIUE visual backlog leaks back into mainline blockers. | Phase 0 C08 is conditional only at state/C3-C6/golden intersections. | Carrier map lists UIUE only as future consumer for stable IDs and state/golden contracts. |
| tiger | Default-scope semantics get buried in C5/C6 tasks and UIUE implements a different meaning. | Accepted G01-G28 plus UIUE D8/G25/G24 decisions change C2/C3/C5/C6/readback/golden dependency order. | Phase -1 creates `define-demo-default-scope`; C5/C6/golden/UIUE reference it rather than each inventing scope behavior. |
| tiger | UIUE "淡显" gets misread as TTS always saying `主驾`, reintroducing interruption-heavy UX. | Default-scope decision says no driver/passenger clarification for ordinary omitted-scope commands; UIUE wants low-emphasis scope visibility. | Phase -1 AD distinguishes structured scope metadata, UI badge presentation, TTS/readback text, explicit non-default scope, and explicit fan-out. |
| tiger | UIUE external worktree drifts after being cited as evidence. | Main repo validation does not cover `/Users/wanglei/workspace/MAformac-uiue`. | Current unverified external reference is `17f2af1`; any UIUE file:line evidence requires a fresh reconfirm pass before use. |
| paper-tiger | Training stack choice blocks Phase 0. | Overnight research L01 treats local `mlx-lm` capacity as likely adequate; training is not running in this phase. | Keep training-stack tiny receipt as a future retrain-c5 task, not a Phase 0 route blocker. |
| paper-tiger | DPO or PEFT variants must be decided before task rewrite. | D4 and steelman keep SFT mainline and PEFT variants deferred. | Record DPO/DoRA/XGrammar as deferred or escape-hatch rows, not task blockers. |
| elephant | Human review is asked for every row and becomes decision fatigue. | The user wants rigor but also asks for confidence and recommended拍法. | Use fast-pass defaults for low-dispute decisions, but still show each D row and isolate high-attention D2/D3/D6/D7/D10. |
| elephant | A plan document becomes another SSOT. | `a2-post-roadmap` already had this failure mode. | This plan is an implementation plan only; OpenSpec specs and grill SSOT remain authority. |

## File Structure

Files to create during implementation:

- `openspec/changes/define-demo-default-scope/`
  - Owns G01-G28 observable behavior and architecture decisions for default_scope, omitted vs explicit scope, fan-out aggregation, readback scope-origin, and UIUE contract intersections.
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

- `CLAUDE.md`
  - Add a short post-A2 default-scope blocker pointer so new sessions do not jump from A2 merge directly to retrain/rebuild/golden.
- `docs/grill-tournament/demo-default-scope-grill-decisions-2026-06-24.md`
  - Reconcile G18 readback policy with UIUE's accepted "淡显 badge / aggregate card" decisions by defining structured scope-origin metadata and channel-specific presentation policy.
- `openspec/changes/define-demo-golden-run-and-voice/{proposal.md,tasks.md,specs/demo-golden-run/spec.md}`
  - Add dependency on `define-demo-default-scope` before golden IDs/readback/UIUE scene tags are frozen.
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
- UIUE external worktree files under `/Users/wanglei/workspace/MAformac-uiue` unless the user separately authorizes UIUE edits.

## OpenSpec Layering Rule

For `retrain-c5-lora-d-domain` and `rebuild-c6-four-layer-bench`, Architecture Decisions belong in `design.md`; `tasks.md` only carries executable checklist steps and evidence artifacts. If a stop-the-train row defines topology, state machine, source-of-truth strategy, or signing policy, it must be written as an AD before it appears as a task checkbox.

For `define-demo-default-scope`, Architecture Decisions belong in its own `design.md`, not in retrain-c5, rebuild-c6, demo-golden, or UIUE tasks. Other changes may depend on it, but they must not redefine omitted-scope behavior.

AD-DS-001 through AD-DS-009 are derived from G01-G28 and the cited external UIUE evidence. They are not new decisions. If an AD-DS row conflicts with G01-G28, the accepted G01-G28 decision pack wins and the AD must be rewritten.

## Mechanical Pending-Decision Gate

OpenSpec validation is necessary but not sufficient. D1-D10 accepted verdicts remove the user-decision pending gate only. They do not authorize apply-ready claims, training, C6 acceptance, endpoint claims, demo-golden-run, voice, or UIUE merge.

Use a gate check in Phase -1/Phase 0 closeout:

```bash
rg -n "\\| pending \\|" docs/project/phase0/phase0-d1-d10-user-decision-record.md && exit 65 || true
rg -n "pending_user_decision:" docs/project/phase0 openspec/changes/retrain-c5-lora-d-domain openspec/changes/rebuild-c6-four-layer-bench
```

If the first command finds any pending row, closeout status must revert to a pending-user-decision status. If no pending row is found, closeout may record `accepted_user_decisions_partial_closeout`, but it still must not become `complete` until R-L17, OpenSpec acceptance, and physical evidence gates are closed.

## Phase -1: Default-Scope And UIUE Intersection Preflight

**Purpose:** Run this before Task 1. The default-scope route is earlier than Phase 0 because it changes what C5 may train, what C6 may score, what golden-run may freeze, and what UIUE may render.

**Files:**
- Read: `docs/grill-tournament/demo-default-scope-grill-decisions-2026-06-24.md`
- Read: `docs/project/phase0/README.md`
- Read: `openspec/changes/retrain-c5-lora-d-domain/design.md`
- Read: `openspec/changes/rebuild-c6-four-layer-bench/design.md`
- Read: `openspec/changes/define-demo-golden-run-and-voice/proposal.md`
- Read external: `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/design.md`
- Read external: `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md`
- Read external: `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/specs/ui-presentation/spec.md`
- Create: `openspec/changes/define-demo-default-scope/proposal.md`
- Create: `openspec/changes/define-demo-default-scope/design.md`
- Create: `openspec/changes/define-demo-default-scope/tasks.md`
- Create: `openspec/changes/define-demo-default-scope/specs/tool-execution/spec.md`
- Modify: `openspec/changes/retrain-c5-lora-d-domain/design.md`
- Modify: `openspec/changes/retrain-c5-lora-d-domain/tasks.md`
- Modify: `openspec/changes/rebuild-c6-four-layer-bench/design.md`
- Modify: `openspec/changes/rebuild-c6-four-layer-bench/tasks.md`
- Modify: `openspec/changes/define-demo-golden-run-and-voice/proposal.md`
- Modify: `openspec/changes/define-demo-golden-run-and-voice/tasks.md`
- Modify: `docs/project/phase0/README.md`

- [ ] **Step -1.1: Verify and cite the external UIUE worktree**

Run:

```bash
test -d /Users/wanglei/workspace/MAformac-uiue
git -C /Users/wanglei/workspace/MAformac-uiue rev-parse --short HEAD
git -C /Users/wanglei/workspace/MAformac-uiue log --oneline -8 --decorate
rg -n "AD-8\\.1|AD-8\\.7|default_scope|淡显|fan-out|前排车窗|define-demo-default-scope" \
  /Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/design.md \
  /Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md \
  /Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/specs/ui-presentation/spec.md
```

Expected:
- The external UIUE worktree exists. The historical expected HEAD was `f1096d7`; current route-board reference is `17f2af1` and remains unverified external evidence until reconfirmed.
- Cite UIUE as external evidence, not as current main-branch evidence.
- Expected hits include `ui-presentation/design.md:78`, `:84-88`, and `ui-presentation/tasks.md:11`, `:61-64`.
- If the external worktree is unavailable, record UIUE decisions as `external_user_supplied_reference` and do not claim file:line evidence for them.
- If the external UIUE HEAD differs from the current accepted pin for that pass, stop and reconfirm UIUE evidence before copying AD-8.7 claims into mainline OpenSpec text.

- [ ] **Step -1.2: Add the OpenSpec change skeleton**

Create `openspec/changes/define-demo-default-scope/proposal.md`:

```markdown
# Change: Define Demo Default Scope

## Why

Accepted G01-G28 default-scope decisions establish that omitted scope in demo utterances must resolve through C2 `default_scope`, not `全车`, not `all`, and not YAML `scope.first`.

This must be its own OpenSpec change because the behavior crosses C2 state cells, C3 execution, state application, C5 training targets, C6 gold, readback/TTS, demo scenarios, demo-golden-run, and UIUE state presentation.

## Scope

- Add observable behavior for omitted scope, explicit scope, explicit fan-out, and scope-origin readback.
- Define C2 `default_scope` as the authority for scoped state cells.
- Preserve explicit `全车` fan-out.
- Define a closed collection-alias policy for phrases such as `所有车窗`, `四个车窗`, and `车窗都`.
- Preserve explicit non-default scope such as `副驾`, `左后`, `后排`, `中控屏`, and `前排`.
- Define how omitted scope composes with `clarify_tag` and fast/slow route tiers.
- Define the legacy unscoped-key disposition for demo UI/state presentation.
- Carry UIUE intersections: default scope low-emphasis badge, aggregate card for fan-out, and multi-turn aggregate label such as `前排车窗`.

## Non-Goals

- No runtime implementation in this proposal step.
- No LoRA training or data generation.
- No C6 model-quality run.
- No demo-golden-run execution.
- No UIUE merge.
- No edit to archived OpenSpec specs.
```

Create `openspec/changes/define-demo-default-scope/design.md`:

```markdown
# Design: Demo Default Scope

## Architecture Decisions

> Derivation rule: AD-DS rows below are generated from G01-G28 plus pinned UIUE evidence. They are not new decisions.

### AD-DS-001: C2 default_scope is the authority

Trace: G06, G25.

Every scoped C2 state cell that participates in demo execution SHALL define `default_scope`. Runtime code SHALL NOT infer omitted scope from YAML order, `scope.first`, `all`, or `全车`.

### AD-DS-002: Missing, explicit, and fan-out scopes are different states

Trace: G04, G05, G12.

Missing scope SHALL resolve to the cell's `default_scope`. Explicit non-default scope SHALL target that scope. Explicit collection scope such as `全车` SHALL fan out to supported cells. Unknown scope SHALL reject or clarify; it SHALL NOT silently fan out.

### AD-DS-003: Readback carries scope origin

Trace: G18 plus UIUE AD-8.7 from pinned external worktree.

The system SHALL track whether scope was `defaulted`, `explicit`, or `fanout`. Internal state assertions SHALL keep scoped keys. Presentation SHALL receive structured `scope_origin`, `resolved_scope`, and `presentation_scope_policy` metadata. Channel renderers MAY choose low-emphasis, compact, or elided default-scope wording, but SHALL visibly or audibly preserve explicit non-default scope and explicit fan-out.

### AD-DS-004: UIUE low-emphasis scope is a channel policy, not a second SSOT

Trace: G23 plus UIUE AD-8.1 and AD-8.7 from pinned external worktree.

UIUE may show a low-emphasis default-scope badge such as `主驾` on a card. TTS, plain readback, verifier text, and card badges SHALL derive from the same structured scope metadata, but they are not required to render identical text. Defaulted scope SHALL NOT trigger a driver/passenger clarification. Explicit non-default scope and explicit fan-out SHALL remain explicit across card, TTS/readback policy, and verifier evidence.

### AD-DS-005: Fan-out presentation is aggregate-first

Trace: UIUE AD-8.7 crack 6 decision from pinned external worktree.

Explicit fan-out such as `关上所有车窗` SHALL execute over multiple state cells but present as one aggregate card with a `全车` badge unless a future UIUE design explicitly asks for per-cell expansion.

### AD-DS-006: Multi-turn aggregate label is allowed when it increases clarity

Trace: UIUE AD-8.7 user-story 4 decision from pinned external worktree.

When a follow-up expands scope, for example `打开车窗` followed by `副驾也打开`, UIUE may present the aggregate label `前排车窗`. Backend state remains per-cell; the aggregate label is presentation metadata, not a new C2 cell unless a later spec adds it.

### AD-DS-007: Legacy unscoped demo keys are deprecated presentation inputs

Trace: G23 plus Phase -1 P1-a finding.

Legacy keys such as `hvac.temperature`, `seat.driver.heat`, `window.driver`, `lighting.ambient`, `screen.brightness`, and `fan.speed` SHALL NOT remain a second UI state source after `default_scope` lands. The default-scope implementation SHALL explicitly choose the scoped C2 key path for presentation or define a one-way compatibility adapter. Tests SHALL assert that default-scope actions do not leave the demo UI reading stale legacy keys.

### AD-DS-008: Collection aliases are closed explicit scope aliases

Trace: G05 plus Phase -1 P2-d finding.

Collection-like utterances are fan-out only when they match an accepted collection alias for the cell's collection scope, for example `全车`, `所有车窗`, `四个车窗`, or `车窗都` mapping to `window.position[全车]`. Unknown collection-like wording SHALL reject, clarify, or route to slow-path resolution with evidence; it SHALL NOT silently fall back to `default_scope`.

### AD-DS-009: Omitted scope composes with clarifyTag, it does not override routing

Trace: G18, G27 plus Phase -1 P2-e finding.

`clarify_tag=explicit` plus omitted scope may use fast path and then resolve through `default_scope`. `clarify_tag=implicit` may route through Qwen+LoRA and return a D-domain tool call without a scope slot; after the slow-path candidate is accepted, C3 still resolves omitted scope through `default_scope`. `clarify_tag=ambiguous` or unsupported scope wording SHALL clarify/reject rather than default silently.
```

Create `openspec/changes/define-demo-default-scope/tasks.md`:

```markdown
# Tasks: Define Demo Default Scope

> This draft does not authorize implementation. It defines the required contract before C2/C3/C5/C6/golden/UIUE work proceeds.

## 1. Contract Authority

- [ ] 1.1 Add C2 `default_scope` requirement and validation rule.
- [ ] 1.2 Add omitted vs explicit vs fan-out scenarios to tool execution spec delta.
- [ ] 1.3 Add scope-origin metadata requirement for readback and UIUE presentation.
- [ ] 1.4 Add legacy unscoped-key disposition: demo UI/state presentation must explicitly use scoped C2 keys or a one-way compatibility adapter after `default_scope`.
- [ ] 1.5 Add closed collection-alias rules for fan-out phrases; unresolved collection-like wording must not silently default.
- [ ] 1.6 Add omitted-scope x `clarify_tag` route matrix covering fast path, slow path, ambiguous, rejected, and passthrough contexts.

## 2. Downstream Blockers

- [ ] 2.1 Retrain C5 SHALL depend on this change for omitted-scope target rendering and C2-derived scope candidates.
- [ ] 2.2 Rebuild C6 SHALL depend on this change for C6-MP-014/016/017 and any default-scope gold.
- [ ] 2.3 Demo golden-run SHALL depend on this change before freezing readback text, C6 case IDs, or UIUE scene tags.
- [ ] 2.4 UIUE merge SHALL depend on this change only at state/C3-C6/golden intersections; UIUE visual work remains otherwise isolated.
- [ ] 2.5 CLAUDE.md SHALL point to this post-A2 blocker so new sessions do not treat retrain/rebuild/golden as the immediate next step.

## 3. Verification

- [ ] 3.1 `openspec validate define-demo-default-scope --strict` passes.
- [ ] 3.2 `openspec validate --all --strict` passes.
- [ ] 3.3 `rg -n "scope.first|\\?\\? \\\"全车\\\"|\\?\\? \\\"all\\\"" Core contracts openspec docs/project docs/grill-tournament` is recorded as pre-implementation evidence, not claimed fixed.
- [ ] 3.4 `rg -n "hvac.temperature|seat.driver.heat|seat.driver.ventilation|window.driver|lighting.ambient|screen.brightness|fan.speed" Core App Tests` is recorded as legacy-key pre-implementation evidence and later must be resolved before `default_scope` apply closeout.
- [ ] 3.5 `git -C /Users/wanglei/workspace/MAformac-uiue rev-parse --short HEAD` is recorded before using UIUE file:line evidence; current route-board reference is `17f2af1`, but any file:line evidence still requires a fresh reconfirm pass.
```

Create `openspec/changes/define-demo-default-scope/specs/tool-execution/spec.md`:

```markdown
## ADDED Requirements

### Requirement: Omitted scope SHALL resolve through C2 default_scope

When a tool call omits a scoped slot such as `position`, `direction`, `screen_type`, or `name`, the execution layer SHALL resolve the target through the C2 state cell's `default_scope`.

#### Scenario: Omitted window scope defaults to driver window

- **GIVEN** `window.position` has `default_scope=主驾`
- **WHEN** the user says "打开车窗"
- **THEN** execution targets `window.position[主驾]`
- **AND** execution SHALL NOT fan out to all window cells.

#### Scenario: Explicit all-window request fans out

- **WHEN** the user says "关上所有车窗"
- **THEN** `所有车窗` maps through an accepted collection alias to `position=全车`
- **AND** execution targets every supported `window.position[...]` scope in C2.

#### Scenario: Explicit passenger scope remains explicit

- **WHEN** the user says "副驾车窗开一半"
- **THEN** execution targets `window.position[副驾]`.

#### Scenario: Unaccepted collection-like wording does not silently default

- **WHEN** the user uses collection-like wording that is not in the accepted alias set for that cell
- **THEN** the system rejects, clarifies, or routes to slow-path resolution with evidence
- **AND** it SHALL NOT silently apply the cell's `default_scope`.

### Requirement: Scope-origin SHALL be available to presentation

The system SHALL make scope origin available to readback and UIUE presentation as `defaulted`, `explicit`, or `fanout`, together with the resolved scope and a presentation policy.

#### Scenario: Default scope is not interruption-heavy

- **GIVEN** a defaulted driver window action
- **WHEN** the system renders customer-facing text
- **THEN** it SHALL NOT ask a driver/passenger clarification
- **AND** it MAY render "主驾" as low-emphasis, compact, or elided according to channel policy
- **AND** internal state assertions SHALL still use `window.position[主驾]`.

### Requirement: Omitted scope SHALL compose with clarifyTag routing

Omitted scope is a target-resolution concern after a candidate exists. It SHALL NOT flatten the route-tier decision.

#### Scenario: Fast-path omitted scope

- **GIVEN** an accepted fast-path command with omitted scope, such as "打开车窗"
- **WHEN** the tool call omits `position`
- **THEN** C3 resolves the target through C2 `default_scope`
- **AND** the system SHALL NOT ask whether the user meant driver or passenger.

#### Scenario: Slow-path omitted scope

- **GIVEN** a `clarify_tag=implicit` utterance routed through Qwen+LoRA
- **WHEN** the accepted D-domain tool call omits a scope slot
- **THEN** C3 resolves the target through C2 `default_scope`
- **AND** the slow path does not invent a second defaulting policy.
```

- [ ] **Step -1.3: Add dependency blockers to active OpenSpec drafts**

In `openspec/changes/retrain-c5-lora-d-domain/design.md`, add:

```markdown
### AD-C5-DS-001: Default-scope contract blocks retrain

Retrain SHALL NOT start until `define-demo-default-scope` defines omitted-scope target rendering, C2-derived scope candidates, and scope-origin readback boundaries. C5 targets for omitted-scope utterances SHALL NOT invent `position=全车`.
```

In `openspec/changes/retrain-c5-lora-d-domain/tasks.md`, add:

```markdown
- [ ] 2.5.G8 Default-scope dependency: `define-demo-default-scope` is proposed and validated before data generation or retrain. Omitted-scope targets must omit scope args or derive them from C2 `default_scope`; hardcoded scope candidates are blocked. AD: `AD-C5-DS-001`.
```

In `openspec/changes/rebuild-c6-four-layer-bench/design.md`, add:

```markdown
### AD-C6-DS-001: Default-scope contract blocks C6 gold rebuild

C6 SHALL NOT freeze omitted-scope gold until `define-demo-default-scope` distinguishes omitted default, explicit non-default, and explicit fan-out. C6 gold SHALL NOT encode `打开车窗` as all-window fan-out.
```

In `openspec/changes/rebuild-c6-four-layer-bench/tasks.md`, add:

```markdown
- [ ] 3.5.G7 Default-scope dependency: `define-demo-default-scope` is proposed and validated before C6 default-scope gold is regenerated. `C6-MP-014/016/017` must not encode omitted window scope as `全车`. AD: `AD-C6-DS-001`.
```

- [ ] **Step -1.4: Add golden/UIUE dependency text**

In `openspec/changes/define-demo-golden-run-and-voice/proposal.md`, add:

```markdown
This change also depends on `define-demo-default-scope` before golden-run IDs, expected readback, or UIUE scene tags involving defaulted scope, fan-out, or aggregate scope labels are frozen.
```

In `openspec/changes/define-demo-golden-run-and-voice/tasks.md`, add:

```markdown
- [ ] 1.3 Confirm `define-demo-default-scope` is proposed and validated before freezing default-scope readback, fan-out aggregate cards, or UIUE scene tags.
```

- [ ] **Step -1.5: Validate Phase -1**

Run:

```bash
openspec validate define-demo-default-scope --strict
openspec validate --all --strict
rg -n "define-demo-default-scope|AD-C5-DS-001|AD-C6-DS-001|default_scope" openspec/changes docs/project/phase0 docs/grill-tournament
```

Expected:
- Both OpenSpec validation commands pass.
- The `rg` output shows the standalone change, C5 dependency, C6 dependency, golden/UIUE dependency, and grill/phase0 pointers.
- If validation fails, do not proceed to Task 1-7. Fix only structure or references; do not weaken gate language to get a green result.

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

- [ ] **Step 5: Confirm user decision checkpoint before Task 4 or Task 5**

Current state: `docs/project/phase0/phase0-d1-d10-user-decision-record.md` exists and records accepted D1-D10 user verdicts. Do not recreate the pending template below unless the existing file is missing or explicitly superseded by the user.

If the file is missing, create `docs/project/phase0/phase0-d1-d10-user-decision-record.md` with this structure and stop for user verdicts:

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

If you had to create the pending file, stop and ask the user to quick-pass or revise D1-D10. If the accepted file exists, continue; Task 4 and Task 5 are still not execution authorization without OpenSpec acceptance and evidence gates.

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

Fill every bullet with a concrete value before closeout. Current D1-D10 user decisions are accepted; if any decision is later reopened, write `pending user decision` for that row.

Task 4 and Task 5 remain draft proposal/task rewrite text until OpenSpec acceptance, R-L17 handling, and physical evidence gates are recorded. D1-D10 acceptance removes only the user-decision pending gate.

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

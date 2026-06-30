# Post-C6 Backend Training UIUE Roadmap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish the post Long-run 2 roadmap for this branch, keeping a thin Runtime -> Presentation contract ahead of implementation while placing full backend, training, C6 acceptance, voice, and UIUE merge behind their proper gates.

**Architecture:** This is a parent roadmap plan, not a monolithic code implementation plan. It creates one route baseline and one thin contract carrier first, then requires separate child plans for C5 retrain, C6 acceptance/comparison, runtime backend wiring, voice/golden-run, and UIUE merge. The thin bridge prevents UIUE and backend work from inventing divergent event/result/snapshot fields while UIUE Phase 4 remains in brainstorming/remediation.

**Tech Stack:** OpenSpec, Swift Package Manager, SwiftUI, MAformac Core Swift modules, Python stdlib validation scripts, Makefile gates, local Git evidence.

## Global Constraints

- authority: `implementation_plan_not_ssot`; the source of truth remains `CLAUDE.md`, archived OpenSpec specs, accepted grill decision packs, active OpenSpec changes, signed evidence, and live repo state.
- branch at plan creation: `codex/rebuild-c6-doc-absorption-20260624`.
- plan_creation_head: `f3a3299fe55fcb67b72f8b1a085f8939b01b1b76`.
- architecture_audit_head: `69432512a2c8ddcdc584bfac47f3218262544118`.
- route_fix_input_head: `69432512a2c8ddcdc584bfac47f3218262544118`.
- Head truth rule: run `git rev-parse HEAD` and `git rev-parse @{u}` for live state; this plan records verification inputs, not a self-updating commit hash.
- Long-run 2 strongest claim: `external-pass-with-absorbed-fixes` only for rebuild-C6 identity + behavior-shape construction closeout.
- Long-run 2 does not authorize retrain-C5, C6 acceptance, D-domain base recalibration, candidate comparison, model-quality evaluation, golden-run, voice, endpoint readiness, UIUE merge, R-L17 candidate signoff, V-PASS, S-PASS, or U-PASS.
- The project remains pure端侧, offline, no cloud backend, mock vehicle control, SwiftUI macOS+iOS, Qwen3-1.7B + LoRA mainline, Python only for development tooling.
- No raw cockpit/customer text, PII, secrets, pricing, or internal-only source material may enter training data, bench cases, or docs beyond allowed abstracted private-repo evidence policy.
- Do not touch `/Users/wanglei/workspace/MAformac-uiue` except read-only intersection checks unless a later user instruction explicitly allows writes.
- Do not use `git add .`.
- Retire trigger: retire or supersede this plan after the thin runtime-presentation OpenSpec carrier is accepted and child plans exist for C5, C6, runtime backend, voice/golden-run, and UIUE connection.

---

## Step 0 Accepted Baseline

Step 0 is the discussion baseline accepted by the user before this plan:

- Long-run 2 completed identity + shape construction and absorbed two GPT Pro audit rounds.
- The previous model/training-only sequence was incomplete because it missed the iOS/macOS runtime backend and UIUE connection lane.
- Full runtime/backend implementation can wait behind model/C6 gates, but a thin Runtime -> Presentation contract should not wait.
- Current repo has pieces of the contract (`ScopeOrigin`, C3 result/readback, mock state cells, trace logger, `LLMBackend`, `SpeechSynthesisEngine`) but lacks a named UIUE-facing bridge artifact.
- UIUE is still in Phase 4 brainstorming/remediation; pure visual work remains isolated, but bridge fields that affect state/readback/scope/golden IDs must be defined in mainline.

## Scope Check

This roadmap covers several independent subsystems. Do not implement them in one code branch. Use this plan to create the shared route and contract, then split into child implementation plans:

- `docs/superpowers/plans/2026-06-25-runtime-presentation-bridge-apply.md`
- `docs/superpowers/plans/2026-06-25-retrain-c5-lora-d-domain-entry.md`
- `docs/superpowers/plans/2026-06-25-c6-acceptance-and-candidate-comparison.md`
- `docs/superpowers/plans/2026-06-25-ios-macos-runtime-backend-apply.md`
- `docs/superpowers/plans/2026-06-25-demo-golden-voice-uiue-connection.md`

Each child plan must carry its own writable paths, validation gates, proof class, and stop conditions.

## File Structure

- `CLAUDE.md`: project constitution. Add only the latest post Long-run 2 route override so new sessions do not follow stale pre-C6 instructions.
- `docs/CURRENT.md`: current route board. Replace stale construction-prep state with `plan_creation_head=f3a3299...`, `architecture_audit_head=69432512...`, and the live-head truth rule.
- `docs/README.md`: document map. Add the new plan and Long-run 2 closeout as current entry points.
- `docs/project/phase0/non-uiue-pre-code-action-list-2026-06-24.md`: historical pre-code checklist. Add a supersession note that its rebuild-C6-first ordering has been consumed by Long-run 2 construction work.
- `docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md`: this parent roadmap.
- `openspec/changes/define-runtime-presentation-bridge/`: planned thin contract carrier. This plan authorizes proposing it after grill, not implementing it immediately.
- `docs/project/phase0/post-c6-roadmap-gptpro-architecture-audit-request-2026-06-25.md`: GPT Pro external architecture audit request for this roadmap.

## GPT Pro Audit Absorption Scope

Two GPT Pro audit reports were read for this patch:

- Long-run 2 identity + behavior-shape audit: no P0; the P1/P2 checker, fingerprint, version, and diagnostic naming findings are already absorbed in the current repo and ledger.
- Post-C6 architecture audit: no P0; the route/plan patch absorbed P1/P2 findings for head freshness, runtime-result vocabulary, `proof_class` display discipline, stale downstream task guards, and minimal iOS/macOS runtime boundaries.

Code-level findings from the architecture audit were later approved by the user and absorbed by a focused C6 bench/source-free guardrail patch. See `docs/project/phase0/post-c6-roadmap-gptpro-architecture-absorption-ledger-2026-06-25.md`.

- Absorbed now: `Tools/C6BenchCLI/main.swift` unknown result-id fail-closed behavior, expected case run coverage, `C6CanonicalJSON.encode` fail-closed behavior, `contract_bundle_fingerprint.bundle_hash` component-version identity, and regression coverage for already-state mismatch, missing risk IDs, clarify-tag checks, coverage/golden split, and unknown alternative tools.
- Still downstream: `docs/superpowers/plans/2026-06-25-c6-acceptance-and-candidate-comparison.md` must define and authorize actual C6 model-quality acceptance/comparison only after a signed candidate exists.
- Closeout rule remains: use `make verify-all` for full local Swift-inclusive proof and `make verify-ci` or GitHub Actions Verify for source-free CI proof; do not describe `make verify` as the full Swift gate.

### Task 1: Route Baseline Synchronization

**Files:**
- Modify: `CLAUDE.md`
- Modify: `docs/CURRENT.md`
- Modify: `docs/README.md`
- Modify: `docs/project/phase0/non-uiue-pre-code-action-list-2026-06-24.md`
- Create: `docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md`

**Interfaces:**
- Consumes: Long-run 2 closeout `docs/project/phase0/rebuild-c6-identity-shape-closeout-2026-06-25.md`.
- Consumes: GPT Pro ledger `docs/project/phase0/rebuild-c6-identity-shape-gptpro-absorption-ledger-2026-06-25.md`.
- Produces: one current route statement that downstream plans can cite without reinterpreting stale roadmaps.

- [ ] **Step 1: Verify live repo state**

Run:

```bash
cd /Users/wanglei/workspace/MAformac
git status --short --branch
git rev-parse HEAD
git rev-parse @{u}
git rev-parse origin/main
```

Expected at the start of this architecture-audit absorption patch:

```text
## codex/rebuild-c6-doc-absorption-20260624...origin/codex/rebuild-c6-doc-absorption-20260624
69432512a2c8ddcdc584bfac47f3218262544118
69432512a2c8ddcdc584bfac47f3218262544118
c1e7d58d281d0256d29034c1d120cefe0bf5a033
```

If this plan itself is later committed, rerun the commands and let live git output supersede the recorded input head.

- [ ] **Step 2: Update route board wording**

Edit `docs/CURRENT.md` so its header uses:

```yaml
status: active_router_only_not_ssot
artifact_kind: current_route_board
authority: router_only_not_contract
updated: 2026-06-25
plan_creation_head: f3a3299fe55fcb67b72f8b1a085f8939b01b1b76
architecture_audit_head: 69432512a2c8ddcdc584bfac47f3218262544118
route_fix_input_worktree_head: 69432512a2c8ddcdc584bfac47f3218262544118
route_fix_input_upstream_head: 69432512a2c8ddcdc584bfac47f3218262544118
last_verified_origin_main: c1e7d58
branch: codex/rebuild-c6-doc-absorption-20260624
head_truth_rule: "Run git rev-parse HEAD and git rev-parse @{u}; this route board records verification inputs and loses to live repo state."
```

Expected content rule: the Current Phase section must say post Long-run 2 `external-pass-with-absorbed-fixes`, and it must explicitly keep retrain-C5, C6 acceptance, model-quality evaluation, candidate comparison, golden-run, voice, endpoint readiness, UIUE merge, and V/S/U-PASS locked.

- [ ] **Step 3: Add the new plan to the document map**

Edit `docs/README.md` and add this current authority row:

```markdown
| `docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md` | **Post Long-run 2 parent roadmap**: bridge contract first, model/C6 next, full backend/UIUE connection later under child plans; implementation_plan_not_ssot |
```

Expected content rule: `docs/README.md` must keep `docs/roadmap-2026-06-20-from-c6-done.md` historical, not current.

- [ ] **Step 4: Add the latest route override to the project constitution**

Edit `CLAUDE.md` near section 9 and add a short dated override:

```markdown
> 🔴 **Post Long-run 2 route override (2026-06-25)**: Long-run 2 rebuild-C6 identity + behavior-shape closeout is `external-pass-with-absorbed-fixes` only for construction evidence. Next route is docs/grill first: define a thin Runtime -> Presentation bridge contract, then split child plans for C5 retrain, C6 acceptance/comparison, runtime backend, voice/golden-run, and UIUE connection. Full backend/UIUE implementation is downstream of model/C6 gates; the thin bridge contract is allowed earlier because it prevents field drift.
```

Expected content rule: do not delete historical sections in `CLAUDE.md`; add a superseding note instead.

- [ ] **Step 5: Mark the old pre-code checklist as consumed**

Edit `docs/project/phase0/non-uiue-pre-code-action-list-2026-06-24.md` and add a top note:

```markdown
> 2026-06-25 update: this checklist's "rebuild-C6 first" ordering has been consumed by Long-run 2 identity + behavior-shape construction closeout. It remains historical route-control evidence. Use `docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md` for the next parent route.
```

Expected content rule: do not claim C6 acceptance or model-quality evidence.

- [ ] **Step 6: Validate docs baseline sync**

Run:

```bash
openspec validate --all --strict
git diff --check
```

Expected:

```text
Totals: 15 passed, 0 failed (15 items)
```

`git diff --check` prints no output and exits 0.

### Task 2: Runtime-Presentation Bridge Proposal

**Files:**
- Create: `openspec/changes/define-runtime-presentation-bridge/proposal.md`
- Create: `openspec/changes/define-runtime-presentation-bridge/design.md`
- Create: `openspec/changes/define-runtime-presentation-bridge/tasks.md`
- Create: `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`
- Modify: `docs/CURRENT.md`
- Modify: `docs/README.md`

**Interfaces:**
- Consumes: `ScopeOrigin`, `DemoActionReadback`, `DemoVehicleStateCell`, `C3ExecutionResult`, `TraceEntry`, `DemoVisualState`.
- Produces: proposed names and observable fields for `DemoInteractionEvent`, `DemoRuntimeResult`, `PresentationSnapshot`, and `TraceEnvelope`.

- [ ] **Step 1: Create the proposal directory**

Run:

```bash
mkdir -p openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge
```

Expected: directory exists and `git status --short` shows no file changes yet if no files were written.

- [ ] **Step 2: Write `proposal.md`**

Add this content:

```markdown
# define-runtime-presentation-bridge

## Summary

Define a thin Runtime -> Presentation bridge contract so UIUE, iOS/macOS runtime backend, golden-run, and voice work consume the same event/result/snapshot vocabulary.

## Motivation

Long-run 2 closed C6 identity + behavior shape, but the app still lacks a named UI-facing runtime bridge. Existing pieces live in Core state, C3 execution, trace, LLM, voice, and ContentView. Without a contract, backend and UIUE can grow divergent fields for scope, readback, trace, voice, and orb state.

## Scope

- Define observable event/result/snapshot fields.
- Reuse existing Core concepts: `ScopeOrigin`, `DemoActionReadback`, `DemoVehicleStateCell`, `C3ExecutionResult`, `TraceEntry`, and `DemoVisualState`.
- Define ownership boundaries between Core runtime and UIUE presentation.

## Non-goals

- No Swift implementation in this proposal.
- No C5 data generation or training.
- No C6 acceptance, model-quality evaluation, D-domain base recalibration, or candidate comparison.
- No demo-golden-run execution.
- No ASR/TTS readiness claim.
- No endpoint readiness claim.
- No UIUE merge.
- No V-PASS, S-PASS, or U-PASS.
```

Expected: proposal explicitly separates bridge contract from backend implementation.

- [ ] **Step 3: Write `design.md`**

Add this content:

```markdown
# Runtime-Presentation Bridge Design

## AD-RPB-001: Contract-first, implementation-later

The bridge defines event/result/snapshot vocabulary before runtime backend or UIUE merge work. This is allowed before model/C6 gates because it does not execute a model, train data, or claim readiness.

## AD-RPB-002: UIUE consumes snapshots, not stores

UIUE SHALL consume a presentation snapshot. It SHALL NOT depend directly on `DemoVehicleStateStore`, raw trace arrays, model output, or training receipts.

## AD-RPB-003: Scope origin is single-source

Every readback and presentation scope label SHALL carry `scope_origin` from Core scope resolution. UIUE may choose visual emphasis, but it must not infer defaulted/explicit/fanout from display strings.

## AD-RPB-004: Voice and orb are presentation state, not proof of voice readiness

The bridge may expose `voice_state` and `orb_state` for UI choreography. Those fields do not imply ASR/TTS functional readiness, demo-golden-run pass, endpoint readiness, or V-PASS.

## AD-RPB-005: Runtime result vocabulary preserves refusal class

The bridge SHALL NOT expose a bare `rejected` result as the only runtime outcome. It must preserve at least unsupported/no-tool refusal and safety/policy refusal as distinct machine-readable values.

## AD-RPB-006: Presentation proof classes are finite and display-capped

`PresentationSnapshot.proof_class` SHALL use a finite project vocabulary. Unknown values fail closed, and local/static/external-review proof must never be displayed as endpoint-ready, voice-ready, C6-ready, or V-PASS.

## AD-RPB-007: Minimal endpoint runtime boundaries

Runtime work that feeds the bridge SHALL avoid blocking the main thread, SHALL emit a terminal snapshot on cancel/interruption/timeout, and SHALL NOT introduce persistence, cloud sync, or long-lived user memory.
```

Expected: the design keeps UIUE as consumer and avoids redefining C2/C3 semantics.

- [ ] **Step 4: Write `tasks.md`**

Add this content:

```markdown
## 1. Proposal validation

- [ ] 1.1 Validate this change with `openspec validate define-runtime-presentation-bridge --strict`.
- [ ] 1.2 Validate all OpenSpec with `openspec validate --all --strict`.
- [ ] 1.3 Run `git diff --check`.

## 2. Contract fields

- [ ] 2.1 Define `DemoInteractionEvent` field requirements for text input, mic start, mic end, card tap, cancel, and interruption.
- [ ] 2.2 Define `DemoRuntimeResult` outcomes: `accepted_tool_call`, `clarify_missing_slot`, `refusal_no_available_tool`, `refusal_safety_or_policy`, `already_state_noop`, `runtime_error`, and `cancelled`. A display-layer `rejected` aggregate is allowed only if it also carries a machine-readable `rejection_class` or `behavior_class_source`.
- [ ] 2.3 Define `PresentationSnapshot` fields: `trace_id`, `cards`, `dialog_text`, `readbacks`, `scope_origin`, `voice_state`, `orb_state`, and finite-enum `proof_class` with display caps and unknown-value fail-closed behavior.
- [ ] 2.4 Define `TraceEnvelope` as a presentation-safe view over C3 decode, plan, guard, execute, and readback stages.
- [ ] 2.5 Define minimal runtime boundary behavior: off-main execution for runtime work, terminal snapshots for cancel/interruption/timeout, and no persistence, cloud sync, or long-lived user memory.

## 3. Red lines

- [ ] 3.1 Do not implement Swift in this contract-only change.
- [ ] 3.2 Do not edit UIUE worktree.
- [ ] 3.3 Do not claim runtime/backend readiness from contract validation.
```

Expected: unchecked tasks are contract tasks only.

- [ ] **Step 5: Write the spec delta**

Add this content to `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`:

```markdown
## ADDED Requirements

### Requirement: Presentation Snapshot Contract

The system SHALL expose a presentation snapshot that contains card state, dialog text, readbacks, scope origin, trace identity, voice state, orb state, and finite-enum proof class without requiring UI presentation code to read raw runtime stores.

#### Scenario: Default scope is visible but not re-inferred

GIVEN Core resolves an omitted user scope as `defaulted`
WHEN the presentation layer renders the resulting card and readback
THEN the snapshot SHALL carry `scope_origin=defaulted`
AND the presentation layer SHALL NOT infer the scope origin from display strings.

### Requirement: Runtime Result Vocabulary

The system SHALL classify runtime results as `accepted_tool_call`, `clarify_missing_slot`, `refusal_no_available_tool`, `refusal_safety_or_policy`, `already_state_noop`, `runtime_error`, or `cancelled` before UI presentation renders the result.

#### Scenario: Already-state result is not unsupported

GIVEN a user asks for a state that is already satisfied
WHEN runtime produces no state mutation
THEN the bridge result SHALL be `already_state_noop`
AND it SHALL NOT be reported as unsupported or safety refusal.

#### Scenario: Unsupported and safety refusals remain distinct

GIVEN runtime cannot map a request to an available demo tool
WHEN the presentation layer renders the refusal
THEN the bridge result SHALL be `refusal_no_available_tool`
AND it SHALL NOT be collapsed into `refusal_safety_or_policy` or a bare `rejected` value.

#### Scenario: Proof class cannot be upgraded by display copy

GIVEN a snapshot proof class is `local_static_contract`
WHEN the presentation layer renders status copy
THEN it SHALL NOT display endpoint-ready, voice-ready, C6-ready, V-PASS, S-PASS, or U-PASS claims.

#### Scenario: Timeout terminates as runtime error

GIVEN runtime exceeds its configured interaction timeout
WHEN the bridge emits the final snapshot for that turn
THEN the bridge result SHALL be `runtime_error`
AND the snapshot SHALL be terminal for the turn.
```

Expected: `openspec validate define-runtime-presentation-bridge --strict` can parse the change.

- [ ] **Step 6: Validate the proposal**

Run:

```bash
openspec validate define-runtime-presentation-bridge --strict
openspec validate --all --strict
git diff --check
```

Expected:

```text
Change 'define-runtime-presentation-bridge' is valid
Totals: 16 passed, 0 failed (16 items)
```

`git diff --check` prints no output and exits 0.

### Task 3: GPT Pro Architecture Audit Request

**Files:**
- Create: `docs/project/phase0/post-c6-roadmap-gptpro-architecture-audit-request-2026-06-25.md`
- Modify: `docs/README.md`

**Interfaces:**
- Consumes: this parent roadmap, current route board, Long-run 2 closeout, UIUE contract context, and active C5/C6/voice/UIUE OpenSpec drafts.
- Produces: one paste-ready external audit request that asks GPT Pro to review the route from a system architecture perspective.

- [ ] **Step 1: Write the GPT Pro audit request**

Create `docs/project/phase0/post-c6-roadmap-gptpro-architecture-audit-request-2026-06-25.md` with this content:

```markdown
# GPT Pro Architecture Audit Request - Post-C6 Roadmap - 2026-06-25

## Requested Verdict

Return exactly one:
- `ARCH_PASS`
- `ARCH_PASS_WITH_FIXES`
- `ARCH_FAIL`

Classify findings as P0/P1/P2.

## Mission

Audit PR #7 from a system architecture angle after Long-run 2. The question is not "did implementation pass C6"; the question is whether the new roadmap avoids both failure modes:

1. downgrade: rushing into backend/UIUE/model work without proof-class gates;
2. over-engineering: turning a pure端侧 5-minute demo into a production backend or governance maze.

## Primary Files To Read

- `CLAUDE.md`
- `docs/CURRENT.md`
- `docs/README.md`
- `docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md`
- `docs/project/phase0/rebuild-c6-identity-shape-closeout-2026-06-25.md`
- `docs/project/phase0/rebuild-c6-identity-shape-gptpro-absorption-ledger-2026-06-25.md`
- `docs/project/phase0/non-uiue-pre-code-action-list-2026-06-24.md`
- `openspec/changes/rebuild-c6-four-layer-bench/tasks.md`
- `openspec/changes/retrain-c5-lora-d-domain/tasks.md`
- `openspec/changes/define-demo-golden-run-and-voice/tasks.md`
- `openspec/changes/ui-presentation/design.md`

## Architecture Questions

1. Is the bridge-first route justified, or should Runtime -> Presentation wait until after C5/C6?
2. Does the plan correctly separate thin contract work from full backend implementation?
3. Does the route preserve proof-class discipline for C5 train-health, C6 model-quality, endpoint/runtime proof, voice proof, UIUE proof, and V/S/U-PASS?
4. Does the plan avoid over-engineering by keeping MAformac pure端侧, mock vehicle control, no cloud backend, and demo-first?
5. Does the route create any new dual-SSOT risk with default_scope, state cells, readback, trace, golden IDs, or UIUE presentation fields?
6. Are the child-plan split and stop conditions sufficient before implementation begins?
7. Are any necessary iOS/macOS backend concerns missing from the route?

## Hard Boundaries

- Do not recommend training now.
- Do not recommend C6 acceptance or candidate comparison now.
- Do not recommend UIUE merge now.
- Do not recommend voice/golden-run execution now.
- Do not downgrade proof gates for demo speed.
- Do not add production backend, SaaS, cloud sync, real vehicle control, or long-lived user memory.
- If proposing extra contract work, explain why it prevents drift and why it is not over-engineering.

## Required Output

- Overall verdict.
- P0/P1/P2 findings with file:line anchors.
- A "downgrade risk" section.
- An "over-engineering risk" section.
- A proposed minimal next-step sequence.
- Explicit residual risks and proof-class boundaries.
```

Expected: the request names the precise audit lens and prevents GPT Pro from treating this as C6 acceptance or backend implementation authorization.

- [ ] **Step 2: Add the audit request to the document map**

Edit `docs/README.md` and add this current authority row:

```markdown
| `docs/project/phase0/post-c6-roadmap-gptpro-architecture-audit-request-2026-06-25.md` | **GPT Pro architecture audit request**: asks external review to challenge the post-C6 roadmap for downgrade risk and over-engineering risk |
```

Expected: the audit request is discoverable from the document map.

- [ ] **Step 3: Validate before external dispatch**

Run:

```bash
openspec validate --all --strict
git diff --check
```

Expected:

```text
Totals: 15 passed, 0 failed (15 items)
```

`git diff --check` prints no output and exits 0.

- [ ] **Step 4: Commit and push the tracked docs**

Run:

```bash
git status --short
git add CLAUDE.md \
  docs/CURRENT.md \
  docs/README.md \
  docs/project/phase0/non-uiue-pre-code-action-list-2026-06-24.md \
  docs/project/phase0/post-c6-roadmap-gptpro-architecture-audit-request-2026-06-25.md \
  docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md
git commit -m "docs(route): align post-C6 roadmap baseline"
git push origin codex/rebuild-c6-doc-absorption-20260624
```

Expected: exact files are staged; no `git add .`; branch push succeeds.

- [ ] **Step 5: Dispatch GPT Pro audit**

Run the GPT Pro PR audit with the architecture request as the primary instruction:

```bash
cd /Users/wanglei/workspace/tools/chatgpt-automation-mcp
bash start-chrome-automation.sh
uv run python audit_pr.py "https://github.com/rayw-lab/MAformac/pull/7" --async --extra-instruction "Primary task: read docs/project/phase0/post-c6-roadmap-gptpro-architecture-audit-request-2026-06-25.md first. Audit the post-C6 roadmap from a system architecture perspective. Do not treat this as C6 acceptance. Focus on not downgrading proof gates and not over-engineering beyond a pure端侧 5-minute demo."
nohup uv run python watch_and_download.py --max-wait 1800 --min-text-len 2000 --stable-cycles 4 > /tmp/post-c6-roadmap-gptpro-watch-$(date +%Y%m%d-%H%M%S).log 2>&1 &
```

Expected: `audit_pr.py` sends the prompt and a `/tmp/post-c6-roadmap-gptpro-watch-*.log` watcher starts.

### Task 4: Grill And Child Plan Split After External Verdict

**Files:**
- Create: `docs/project/phase0/post-c6-roadmap-grill-ledger-2026-06-25.md`
- Modify: `docs/CURRENT.md`
- Modify: `docs/README.md`
- Modify: `openspec/changes/retrain-c5-lora-d-domain/tasks.md`
- Modify: `openspec/changes/rebuild-c6-four-layer-bench/tasks.md`
- Modify: `openspec/changes/define-demo-golden-run-and-voice/tasks.md`
- Modify: `openspec/changes/ui-presentation/design.md`

**Interfaces:**
- Consumes: GPT Pro external architecture verdict and user grill decisions.
- Produces: a single downstream order and a list of child plans to write next.

- [ ] **Step 1: Record the grill ledger after GPT Pro returns**

Create `docs/project/phase0/post-c6-roadmap-grill-ledger-2026-06-25.md` with these headings:

```markdown
# Post-C6 Roadmap Grill Ledger - 2026-06-25

## Inputs

- Parent plan: `docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md`
- GPT Pro architecture audit: tracked in `docs/project/phase0/post-c6-roadmap-gptpro-architecture-absorption-ledger-2026-06-25.md`; use it as architecture-audit input, not as execution authorization for training/C6 acceptance/UIUE merge.

## Questions

1. Is the Runtime -> Presentation bridge proposal allowed before C5 retrain?
2. Which C5 gates must be physical before data generation starts?
3. Which C6 proof class is the first acceptable model-quality proof?
4. Which runtime backend fields must wait until a signed candidate exists?
5. Which UIUE Phase 4 outputs are visual-only, and which intersect state/readback/golden contracts?
6. What exact claim language is allowed for each phase?

## Non-goals

- No training execution.
- No C6 acceptance execution.
- No UIUE merge.
- No voice readiness claim.
```

Expected: the ledger has direct questions for grill and repeats the non-goals.

- [ ] **Step 2: Publish the allowed order**

Use this order in `docs/CURRENT.md` after grill acceptance:

```markdown
1. Contract-only: propose `define-runtime-presentation-bridge`.
2. Model-quality lane: harden `retrain-c5-lora-d-domain`, generate data only after C5 entry gates, train, and sign candidate.
3. C6 lane: run authorized C6 model-quality acceptance/comparison only after candidate signoff.
4. Runtime backend lane: implement text/mic/card/cancel -> runtime -> `PresentationSnapshot` wiring after the bridge contract is accepted; full model-backed execution waits for candidate proof.
5. Golden/voice/UIUE lane: freeze golden IDs, voice proof, and UIUE merge only after stable state/case/card/readback IDs and separate proof classes exist.
```

Expected content rule: contract-only bridge is first, but implementation-heavy backend is after model/C6 gates.

2026-06-30 D20/D21 execution note: `UIUE_R5_D20_D21_RUNTIME_UIUE_INTEGRATION_PR_SUPERTRAIN`
is a narrower child authorization that supersedes the sentence above only for
the demo app command-entry slice. It permits the existing app text command path
to move from `DemoWalkingSkeleton` to a main-owned
`C3ExecutionPipeline` / runtime-adapter / `RuntimePresentationPayload` path and
permits UIUE to consume presentation-safe public JSON fixtures into
`PresentationSnapshot`. It does not authorize model-backed backend readiness,
voice/golden/mobile/live proof, UIUE merge, V/S/U-PASS, A-2 completion, or R5
completion.

- [ ] **Step 3: Guard stale task files**

For each active OpenSpec task file touched in this task, add a short note near the top:

```markdown
Unchecked downstream tasks are not execution authorization. Follow `docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md`, the GPT Pro architecture verdict, and the relevant accepted child plan before implementation. This note does not authorize training, C6 acceptance, candidate comparison, model-quality evaluation, backend readiness, golden-run execution, voice readiness, UIUE merge, or V/S/U-PASS.
```

Expected content rule: the note prevents stale task checkboxes from being read as permission to run training or acceptance.

- [ ] **Step 4: Validate route cascade**

Run:

```bash
openspec validate --all --strict
git diff --check
```

Expected: all OpenSpec items pass and whitespace check exits 0.

## Final Route Summary

1. Now: baseline docs plus this parent plan.
2. External audit: GPT Pro challenged downgrade risk and over-engineering risk; route/plan and C6 bench/source-free P1/P2 fixes are absorbed in the tracked absorption ledger.
3. Next grill: accept or edit the parent route and bridge-first thesis using the absorbed audit verdict.
4. First contract: propose `define-runtime-presentation-bridge`.
5. Model lane: C5 data/retrain/candidate only after entry gates.
6. C6 lane: acceptance/comparison only after candidate signoff and explicit run authorization.
7. Backend lane: full iOS/macOS runtime implementation after bridge contract and aligned with model/C6 proof.
8. UIUE/voice/golden lane: connect after stable IDs and separate proof classes; visual-only UIUE can remain isolated.

## Self-Review

- Spec coverage: the plan covers current branch truth, Long-run 2 closeout boundary, bridge-first contract, C5/C6 gates, backend/UIUE ordering, GPT Pro external architecture audit, and no-goal proof classes.
- Placeholder scan: no placeholder task is used as execution permission; downstream child plans are gated behind external audit and grill rather than represented as empty deliverables.
- Type consistency: bridge names are consistently `DemoInteractionEvent`, `DemoRuntimeResult`, `PresentationSnapshot`, and `TraceEnvelope`.

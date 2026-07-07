---
status: FINAL_AFTER_REDUCTION_AND_ADVERSARIAL_AUDIT
artifact_kind: commander_phase0_plan
authority: commander_plan_not_ssot
created_at: 2026-07-06
updated_at: 2026-07-06
proof_class: planning_governance
retire_trigger: "Retire when C5 closeout package is replaced by signed candidate/C6/runtime closeout authority, or when a newer commander phase0 plan supersedes it."
expires: 2026-07-13
non_claims: "Not a candidate signoff, not C6 acceptance, not UIUE merge readiness, not voice readiness, not V-PASS."
---

# C5 Closeout Commander Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close C5 honestly by freezing the tail1200 training artifact, cascading the run truth into commander-maintained documents, and routing runtime, C6, UIUE, voice, dirty-tree cleanup, worktree hygiene, and GitHub push gates without proof-class promotion.

**Architecture:** Treat this as a commander parent plan, not a coding task. The first serial lane closes C5 training evidence and documentation; the following lanes split into runtime safety as the main runtime falsification gate en route to candidate review, C6 construction as parallel preparation, UIUE as isolated contract/consumer work, and voice as spec-only preparation until runtime and candidate evidence exist.

**Tech Stack:** Markdown receipts, OpenSpec carriers, Swift/SwiftPM/Xcode project validation, tmux-bridge, preferred Claude Code Opus audit pane `%15`, Codex audit fallback panes `%12/%11/%14/%16`, Git/GitHub with human push gate.

## Plan Status

status: FINAL_AFTER_REDUCTION_AND_ADVERSARIAL_AUDIT
grill_reduction: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-reduction.md`
governance_snapshot: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-governance/`
current_adversarial_audit: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-plan-audit/codex-p-audit4-c5-closeout-plan-audit.md`
final_adversarial_audit: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-worker-round2/w15-final-adversarial-audit.md`
finalization_record: W15 verdict=PASS, finalize_now=yes(conditional), no P0/P1; residual P2s deferred to push/commit gates.

This file has been moved to the main project route-control folder because it is a lifecycle-scoped MAformac plan, not a generic superpowers execution plan. It is final as a plan document only after Task 0 grill/reduction, reduction audit, and W15 final adversarial review absorption. This final status does not claim push, training, candidate signoff, C6 comparison or acceptance, UIUE merge, voice readiness, mobile, true-device, live, V-PASS, S-PASS, or U-PASS.

## Audit Absorption Ledger

| Source | Finding | Disposition | Plan change |
|---|---|---|---|
| `codex-p-audit4-c5-closeout-plan-audit.md` | P1 finalization could write final status without mechanical proof that grill lanes, reduction, reduction audit, and final adversarial audit exist and were absorbed. | accepted | Task 8 now includes a required finalization prerequisite check before final status can be written. |
| `codex-p-audit4-c5-closeout-plan-audit.md` | P2 final audit was Opus-only and not recoverable when `%15` was stuck. | accepted | Task 8 is now final-adversarial-audit based, with Opus preferred and any available Codex/Claude worker accepted as fallback. |
| `grill-reduction.md` | Lane A accepts runtime-first only with proof caps and rejects runtime PASS as candidate promotion. | accepted | Commander decision table and Task 4 now state that runtime PASS only moves G2 and leaves R-L17, C6, UIUE, and voice gates blocked. |
| `grill-reduction.md` | Lane B accepts C6 construction now but blocks comparison, acceptance, base recalibration, model-quality evaluation, golden/demo/voice/UIUE/V-PASS. | accepted | Task 4 now adds a `C6 Split Gate` and hard stop conditions for any C6 task that crosses into model proof. |
| `grill-reduction.md` | Lane C allows UIUE/voice only as isolated contract/static/local fixture/UI choreography preflight. | accepted | Task 5 now adds safe-vs-blocked lane caps, UIUE plan addendum, and Runtime -> Presentation OpenSpec preflight edits. |
| `grill-reduction.md` | Lane D holds push until final C5 truth freeze, runs cascade, dirty classification, worktree inventory, final audit, docs-only commit, and explicit user push authorization. | accepted | Task 2/6/7/8 now add raw-runs scans, `stage_now` enum, pathspec-only staging, and governance prerequisites. |
| `opus-c5-closeout-plan-audit.md` | P1 phase0 manifest metadata was missing. | accepted | Added frontmatter with `authority`, `retire_trigger`, `expires`, proof class, and non-claims. |
| `opus-c5-closeout-plan-audit.md` | P1 repo-local `runs/` was not gitignored and already contained non-README files, making Task 2 expected output false. | accepted | Added `.gitignore` backstop for `runs/*` with `!runs/README.md`; Task 2/7 now treat existing non-README files as ignored local residue, not staging candidates. |
| `grill-reduction-audit.md` | P2 Lane-B stale-branch guard and Lane-C host/process re-probe guard were incomplete; reduction mechanical checks omitted the final audit artifact. | accepted | Reduction, Task 4, Task 5, and Task 8 now carry those guards and the final-audit check. |
| `opus-c5-closeout-plan-audit.md` | P2 tail1200 iter600 naming drift, runtime candidate-review wording, origin/main 190 divergence, cascade staging intent, pane drift, discoverability, and confirmation-bias reduction template. | accepted | Normalized to tail1200 iter600, reworded runtime as falsification gate, added origin/main divergence, cascade staging intent, live pane reconciliation, COMMANDER-INDEX pointer, and marked the embedded reduction as illustrative only. |
| `w15-final-adversarial-audit.md` | W15 returned `verdict=PASS`, `finalize_now=yes(conditional)`, no P0/P1, and two required closing records before finalization. | accepted | Plan Status and Task 8 now record the W15 audit path, PASS/no-P0/P1 result, and explicitly defer residual P2s to push/commit gates. |
| `w15-final-adversarial-audit.md` | Live pane topology needed final reconciliation before flipping status. | accepted | Task 8 records fresh `tmux-bridge list`: `%13` is dispatcher/current commander-control pane; `%12/%11/%14/%15/%16` are right-side flexible workers; `%0` is visible codex-commander pane when present. |

## Global Constraints

- Default language for MAformac project outputs is Chinese; code, paths, API names, command output, and external names stay in their original language.
- MAformac is a pure on-device macOS/iOS offline Qwen3 + LoRA demo assistant with mock vehicle control; it is not production car control.
- `CLAUDE.md` is the project constitution; `docs/CURRENT.md`, `docs/README.md`, latest handoff, run-dir status boards, and OpenSpec are live routing evidence.
- Major MAformac decisions must not proceed from single-pane synthesis to implementation plan. They require file-backed grill inputs, a reduction file, an implementation plan derived from the reduction, and adversarial review absorption before final.
- Grill work must follow the existing project folder style: bounded questions, current authority first, locked-boundary table, counterexamples that can change the verdict, and reduction into specific accepted/rejected actions.
- Grill outputs and grill reduction must be cascaded into discoverable project files; pane prose does not count as a decision record.
- Current branch is `codex/rebuild-c6-doc-absorption-20260624`, currently ahead 122 and behind 7; current dirty tree must be classified before any commit or push.
- Current live proof cap: tail1200 600iter training completion can prove `train_health` and an unsigned adapter artifact only.
- Forbidden promotion: no `lora_candidate`, no C6 acceptance, no demo readiness, no UIUE merge, no voice readiness, no V-PASS, no S-PASS, no U-PASS without matching proof class.
- R-L17 route-only signoff remains signed for rebuild-C6 construction only; candidate signoff remains unsigned.
- Runtime-gated qa safety is the main runtime falsification gate en route to candidate review after training evidence; it does not mean the LoRA adapter learned qa and it does not promote candidate status by itself.
- C6 construction may proceed in parallel under route-only authority; C6 comparison and C6 acceptance wait for signed C5 candidate plus explicit run authorization.
- UIUE may continue in `/Users/wanglei/workspace/MAformac-uiue` as isolated work; mainline merge waits for shared contract/runtime proof and explicit user gate.
- Voice may proceed as contract and preflight planning; true voice/mobile/true-device claims wait for runtime, candidate, and device proof.
- The main/commander pane only orchestrates and manages lifecycle. It owns scope, dependency graph, worker dispatch, receipt collection, conflict reduction, stop/go calls, proof-class final verdict, and stop lines.
- worker panes own execution lifecycle work: documentation cascade, development, brainstorming, grill, design, testing, audit, dirty cleanup, CI/CD, and coding. Do not phrase the main/commander pane as implementing worker content.
- Worker artifacts are ground truth, not pane prose. Every dispatched worker must write a named file and ack by `tmux-bridge message <commander-pane> ...` followed by Enter.
- Push to GitHub is an external side effect. It is allowed only after local validation, dirty-tree ownership classification, secret/large-artifact screen, branch strategy, final adversarial audit, commander final review, and explicit user push authorization.

---

## Scope Check

This request spans several subsystems. The plan deliberately stays as a commander parent plan and splits work into independently reviewable lanes:

| Lane | Status | Can run now | Hard stop |
|---|---|---:|---|
| C5 closeout evidence | serial first | yes | no final receipt/cascade mismatch |
| RuntimeQueryGuard/runtime safety | main next gate | yes, after C5 final truth is frozen | cannot claim adapter learned qa |
| C6 construction | parallel preparation | yes | cannot run C6 comparison or acceptance |
| C6 comparison/acceptance | downstream gate | no | waits for signed candidate and explicit run auth |
| UIUE | isolated parallel | yes, no mainline merge | waits for shared contract/runtime proof |
| Voice | spec-only parallel | yes, no readiness claim | waits for runtime/candidate/device proof |
| Dirty tree/worktree/GitHub | governance lane | yes | no staging/push until ownership and validation |
| runs nest cascade | commander infrastructure | yes | do not commit raw adapters/metrics dumps |

## File Structure

### Plan File

- Create: `docs/project/phase0/c5-closeout-commander-plan-2026-07-06.md`
  - Responsibility: parent plan, routing matrix, execution gates, worker allocation, GitHub push gate, and final adversarial audit record.

### Grill And Reduction Files

- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/GRILL-README.md`
  - Responsibility: run-dir index for grill inputs, reduction, audit, and cascade.
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-lane-a-runtime-first.md`
  - Responsibility: argue for and against runtime-first after C5 tail final.
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-lane-b-c6-first.md`
  - Responsibility: argue for and against C6-first and split construction from comparison.
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-lane-c-uiue-voice-parallel.md`
  - Responsibility: argue for and against UIUE/voice parallel work and proof caps.
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-lane-d-dirty-push-runs.md`
  - Responsibility: argue for and against dirty-tree cleanup, worktree pruning, runs cascade, and GitHub push timing.
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-reduction.md`
  - Responsibility: reduce grill inputs into accepted/rejected decisions and plan amendments.
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-reduction-audit.md`
  - Responsibility: adversarially audit whether reduction faithfully absorbs grill evidence.

### C5 Closeout And Run Cascade

- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/TAIL1200-ITER600-FINAL-RECEIPT-L-CN.md`
  - Responsibility: final runtime/local training artifact receipt for active `formal-run-20260706T090552+0800-tail1200-full-envelope`.
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/monitor/tail1200-iter600-final-cascade-audit-L-CO.md`
  - Responsibility: read-only audit that final receipt and cascaded docs do not promote proof class.
- Modify: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/COMMANDER-LIVE-STATUS.md`
  - Responsibility: commander live status board; replace iter400/final-pending as current state after final receipt exists.
- Modify: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/STATUS-BOARD.md`
  - Responsibility: secretary status board; reflect tail1200 iter600 final done as unsigned training artifact.
- Modify: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/EVIDENCE-INDEX.md`
  - Responsibility: receipt and artifact index; record adapter sha, metrics/log evidence, process-exit evidence, and non-claims.
- Modify: `docs/CURRENT.md`
  - Responsibility: current routing card; point to final tail receipt and next gates.
- Modify: `docs/baseline-roadmap-2026-07-05-c5-d106.md`
  - Responsibility: planning baseline; add 2026-07-06 final-tail addendum and keep candidate unsigned.
- Modify: `docs/commander-log/COMMANDER-INDEX.md`
  - Responsibility: commander bootstrap state; record C5 closeout state and current swarm topology.
- Create: `docs/commander-log/RUNS-CASCADE.md`
  - Responsibility: tracked commander nest index for external run roots under `/Users/wanglei/Projects/agent-tmux-stack-research/runs/`.
- Create: `runs/README.md`
  - Responsibility: repository-local pointer that says raw run artifacts live outside the repo; this file is safe to track, while raw adapters/metrics/logs are not staged blindly.

### Candidate And Downstream Gates

- Create: `docs/project/phase0/c5-closeout-gate-matrix-2026-07-06.md`
  - Responsibility: single gate table for training artifact, runtime safety, R-L17, C6, UIUE, voice, and proof classes.
- Modify: `docs/project/phase0/r-l17-human-review-evidence/R5-top-failing-c6-case-drilldown.md`
  - Responsibility: upgrade from stub evidence only after case-level C6 drilldown exists; this plan does not fabricate rows.
- Modify: `openspec/changes/retrain-c5-lora-d-domain/tasks.md`
  - Responsibility: check boxes only after physical evidence exists; this plan should not check R-L17 R5/R6/R7 candidate items.

### Runtime, C6, UIUE, Voice Child Plans

- Create: `docs/superpowers/plans/2026-07-06-runtime-query-safety-gate.md`
  - Responsibility: child implementation plan for runtime-gated qa safety and `RuntimeAdapterMountReceipt`.
- Create: `docs/superpowers/plans/2026-07-06-c6-construction-and-candidate-comparison-routing.md`
  - Responsibility: child plan that splits C6 construction from C6 comparison/acceptance.
- Create: `docs/superpowers/plans/2026-07-06-uiue-isolated-merge-readiness.md`
  - Responsibility: child plan for UIUE isolated work and mainline merge stop lines.
- Create: `docs/superpowers/plans/2026-07-06-voice-contract-preflight.md`
  - Responsibility: child plan for voice contract/preflight without readiness claims.

### Dirty Tree, Worktree, GitHub

- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-governance/dirty-tree-classification.md`
  - Responsibility: owned/unowned/generated/no-touch classification for all dirty and untracked paths.
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-governance/worktree-inventory.md`
  - Responsibility: live `git worktree list` inventory and prune/no-prune recommendations.
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-governance/github-push-gate.md`
  - Responsibility: conditions for docs-only commit, branch push, PR creation, and human stop gate.

## Current Truth Snapshot

| Item | Observed state | Proof class | Consequence |
|---|---|---|---|
| Branch | `codex/rebuild-c6-doc-absorption-20260624`, ahead 122 and behind 7 versus upstream; behind `origin/main` by 190 | local | branch strategy required before GitHub push and any future main-targeting PR |
| Dirty tree | repo has modified code/docs/OpenSpec and untracked `runs/`, `Tools/agent-platform-plugin-refs/`, `.xcodebuildmcp/` | local | no blind stage; classify first |
| Active C5 tail run | `formal-run-20260706T090552+0800-tail1200-full-envelope` reached iter600 in fresh superaudit | runtime/local | can close unsigned training artifact |
| Adapter sha | `9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6` for final and `0000600` adapter files | local file hash | can identify artifact, not candidate quality |
| R-L17 R5 | file exists but status is `stub_pending_evidence` | local doc | no candidate signoff from R5 |
| R7 | `signed_route_only_candidate_unsigned` | local doc | C6 construction ok; C6 acceptance blocked |
| UIUE | isolated repo `/Users/wanglei/workspace/MAformac-uiue` | local | mainline merge blocked |
| runs nest | external run roots under `/Users/wanglei/Projects/agent-tmux-stack-research/runs/` | local docs/artifacts | must be indexed and cascaded |

## Commander Decision: What Comes After C5

The next primary lane is **runtime safety**, not direct C6 acceptance, not voice, and not UIUE merge.

Runtime-first means the next falsification gate for qa safety, not candidate promotion; even a runtime PASS only moves G2 to PASS and still leaves G4 R-L17 candidate signoff, G6 C6 comparison, G7 UIUE merge, and G8 voice readiness gated.

| Workstream | Start timing | Parallelism | Claim ceiling |
|---|---|---|---|
| C5 final receipt/cascade | serial first | no | unsigned training artifact |
| RuntimeQueryGuard/runtime mount/readback | immediately after final C5 truth freeze | main lane | runtime-gated qa safety if tests pass |
| C6 construction | can run in parallel with runtime lane | parallel Codex lane | construction/local proof only |
| C6 comparison/acceptance | after signed C5 candidate and explicit run auth | serial after candidate signoff | C6 proof only, not V-PASS |
| UIUE isolated prep | can run in parallel if isolated | parallel UIUE lane | isolated readiness, no mainline merge |
| Voice contract/preflight | can run in parallel as design/spec | parallel design lane | spec/preflight only |
| GitHub push | after docs plan audited, dirty tree classified, validation green, and user authorizes push | serial governance gate | pushed branch/PR only, no merge claim |

### C6 Split Gate

- `C6_CONSTRUCTION_ALLOWED_NOW`: OpenSpec/task cleanup, current-baseline reconfirm, D-domain expected-tool mapping, four-layer scorer/selector, BehaviorClass SSOT, replay/readback/fingerprint, and L6 seed recoding plan.
- `C6_COMPARISON_BLOCKED`: base-vs-LoRA comparison, C6 acceptance, D-domain base recalibration, model-quality evaluation, golden/demo/voice/UIUE/V-PASS.

C6 construction prep may continue under construction/local/static-or-unit proof cap. C6 comparison/acceptance remains blocked until signed C5 candidate plus explicit run auth.
Do not merge `g6`, `doc-absorption`, or `grill` branches wholesale. Port only reviewed construction deltas onto current head after branch/head/origin-main/API reconfirmation.

## Worker Allocation

Right side pane allocation after this plan is saved:

| Pane | Role | First assignment | Output file |
|---|---|---|---|
| `%12` Codex | grill lane A | runtime-first decision grill | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-lane-a-runtime-first.md` |
| `%11` Codex | grill lane B | C6-first / C6 split decision grill | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-lane-b-c6-first.md` |
| `%14` Codex | grill lane C | UIUE/voice parallel decision grill | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-lane-c-uiue-voice-parallel.md` |
| `%16` Codex | grill lane D | dirty tree, worktree, runs cascade, GitHub push grill | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-lane-d-dirty-push-runs.md` |
| `%15` Claude Code Opus | preferred adversarial auditor | audit grill reduction and then audit final plan for false green and missed gates | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-reduction-audit.md` and `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-plan-audit/opus-c5-closeout-plan-audit.md` |
| `%13` Codex | live sender / additional Codex lane in current ma6 topology | may appear as dispatcher or fallback auditor in current pane layout; reconcile before FINAL | no standing output unless explicitly assigned |
| any available Codex/Claude pane | fallback adversarial auditor | replace `%15` only if preferred auditor is stuck or unavailable | same contract, distinct artifact name such as `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-plan-audit/codex-p-audit4-c5-closeout-plan-audit.md` |

Before marking this plan final, run `tmux-bridge list` and update/confirm this pane table. Pane ids are live runtime state, not stable documentation.

Dispatch protocol copied from the interrupted 11% commander jsonl:

1. Assign a unique label such as `L-CN`, `P-AUDIT`, or `G-DIRTY`.
2. Include pane id, session/run root, exact output file, no-touch paths, proof class, and ack string.
3. Send with `tmux-bridge message %<pane> '<prompt>'`.
4. Run `tmux-bridge read %<pane> 30`.
5. Submit with `tmux-bridge keys %<pane> Enter`.
6. Treat the output file as ground truth; pane prose is only a notification.

## Task 0: Run Grill Before Finalizing This Plan

**Files:**
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/GRILL-README.md`
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-lane-a-runtime-first.md`
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-lane-b-c6-first.md`
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-lane-c-uiue-voice-parallel.md`
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-lane-d-dirty-push-runs.md`
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-reduction.md`
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-reduction-audit.md`
- Modify: `docs/project/phase0/c5-closeout-commander-plan-2026-07-06.md`
- Modify: `docs/commander-log/RUNS-CASCADE.md`

**Interfaces:**
- Consumes: `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `docs/baseline-roadmap-2026-07-05-c5-d106.md`, `docs/commander-log/COMMANDER-INDEX.md`, R-L17 evidence files, OpenSpec task files, and active run-dir status boards.
- Produces: `grill-reduction.md` decisions that this plan must explicitly absorb.

- [ ] **Step 1: Create grill index**

Create `GRILL-README.md` with:

```markdown
# C5 Closeout Downstream Routing Grill

## Purpose

Reduce the post-C5 decision surface before finalizing the commander implementation plan.

## Locked Boundaries

- Tail1200 iter600 final can prove unsigned training artifact only.
- Runtime-gated qa safety is not adapter-learned qa.
- C6 construction is separate from C6 comparison and acceptance.
- R-L17 route-only signoff does not sign a C5 candidate.
- UIUE and voice can prepare in parallel but cannot claim merge/readiness.
- Dirty tree and GitHub push are governance gates, not implementation shortcuts.

## Grill Lanes

| Lane | Output | Question |
|---|---|---|
| A | `grill-lane-a-runtime-first.md` | Should runtime safety be the main next gate? |
| B | `grill-lane-b-c6-first.md` | What C6 work can run now, and what is blocked? |
| C | `grill-lane-c-uiue-voice-parallel.md` | Which UIUE/voice work is safe in parallel? |
| D | `grill-lane-d-dirty-push-runs.md` | How should dirty tree, worktrees, runs cascade, and GitHub push be sequenced? |
```

- [ ] **Step 2: Dispatch four bounded grill lanes**

Use this common prompt shape for `%12`, `%11`, `%14`, and `%16`:

```text
Read current authority first. Do not write a generic red-team essay.
For your lane, produce:
1. locked boundaries,
2. pro case,
3. counterexamples that would change the verdict,
4. decision table,
5. accepted/rejected actions,
6. exact file:line evidence,
7. residual risk.
Write only the assigned file. No repo edits. Ack commander with tmux-bridge message.
```

- [ ] **Step 3: Reduce grill**

Write `grill-reduction.md` from returned lane files. The following block is illustrative shape only; it is not authority before the lane files exist.

```markdown
# C5 Closeout Grill Reduction

## Verdict

The implementation plan may proceed only after all accepted grill findings are patched into `docs/project/phase0/c5-closeout-commander-plan-2026-07-06.md`.

## Reduction Matrix

| Lane | Accepted | Rejected | Plan patch |
|---|---|---|---|
| A runtime-first | runtime safety is main runtime falsification gate | direct C6 acceptance first | update commander decision table |
| B C6 split | construction may proceed | comparison/acceptance before signed candidate | update C6 child plan |
| C UIUE/voice | isolated/spec work may proceed | readiness/merge claims | update parallel lane caps |
| D governance | classify dirty tree + create runs pointer/index + write worktree inventory before any staging | push-before-classification and blanket staging | update GitHub push gate |
```

- [ ] **Step 4: Audit grill reduction**

Assign `%15` or another available worker to audit `grill-reduction.md` against lane files. The audit passes only if every accepted plan decision cites at least one lane finding and no rejected counterexample is silently dropped.

- [ ] **Step 5: Patch this plan from reduction**

Patch this plan with every accepted `grill-reduction.md` action before running final plan audit. Keep status as `DRAFT_PENDING_GRILL_REDUCTION_AND_ADVERSARIAL_AUDIT` until this step and Task 8 both pass.

## Task 1: Freeze Tail1200 Iter600 Training Evidence

**Files:**
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/TAIL1200-ITER600-FINAL-RECEIPT-L-CN.md`
- Modify: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/COMMANDER-LIVE-STATUS.md`
- Modify: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/STATUS-BOARD.md`
- Modify: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/EVIDENCE-INDEX.md`

**Interfaces:**
- Consumes: final run directory `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260706T090552+0800-tail1200-full-envelope`.
- Produces: receipt status `TAIL1200_ITER600_FINAL_SAVED__UNSIGNED_TRAINING_ARTIFACT__NO_CANDIDATE`.

- [ ] **Step 1: Run final evidence command**

Run:

```bash
RUN=/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260706T090552+0800-tail1200-full-envelope
tail -n 5 "$RUN/metrics.jsonl"
tail -n 5 "$RUN/train.log"
shasum -a 256 "$RUN/adapters-rank16/adapters.safetensors" "$RUN/adapters-rank16/0000600_adapters.safetensors"
ps -p "$(cat "$RUN/trainer.pid")" -o pid=,stat=,etime=,command=
rg -n "Traceback|Error|Exception|Killed|SIGTERM|OOM|failed|nan|inf" "$RUN/train.log" "$RUN/metrics.jsonl"
```

Expected:

```text
metrics tail includes event=val iteration=600 val_loss=0.01540403999388218
metrics tail includes event=train_report iteration=600 train_loss=0.009280303120613098 peak_memory=17.974144464 trained_tokens=26190
train.log includes "Iter 600: Saved adapter weights"
both adapter hashes equal 9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6
ps prints no trainer row
rg prints no matches
```

- [ ] **Step 2: Write the final receipt**

Use `apply_patch` to add:

```markdown
---
status: TAIL1200_ITER600_FINAL_SAVED__UNSIGNED_TRAINING_ARTIFACT__NO_CANDIDATE
artifact_kind: c5_tail1200_training_final_receipt
created_at: 2026-07-06T12:30:00+08:00
proof_class: runtime_local_training_artifact
candidate_status: unsigned
adapter_learned_qa: false_or_unproven
formal_run_status: tail1200_iter600_final_saved
adapter_basis_sha: 9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6
model_behavior_gate: not_evaluated
adapter_qa_gate: not_met_or_unproven
runtime_qa_safety_gate: open
runtime_adapter_mount_receipt: missing
r_l17_candidate_signoff_state: route_only_candidate_unsigned
c6_construction_handoff: allowed_under_route_only
c6_comparison_unlock_state: blocked_pending_signed_candidate_and_explicit_run_auth
non_claims: no_candidate_no_c6_acceptance_no_uiue_merge_no_voice_ready_no_v_pass
---

# Tail1200 Iter600 Final Receipt L-CN

## Verdict

PARTIAL for C5 product closeout; PASS for unsigned training artifact finalization.

This receipt proves that the tail1200 600-iteration continuation saved a final adapter artifact. It does not prove C5 candidate quality, runtime qa safety, C6 acceptance, UIUE merge readiness, voice readiness, or V-PASS.

## Evidence

| Claim | Evidence |
|---|---|
| Run directory | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260706T090552+0800-tail1200-full-envelope` |
| Final validation | `metrics.jsonl` final val event at `iteration=600`, `val_loss=0.01540403999388218`, `val_time=63.39084787500906` |
| Final train report | `iteration=600`, `train_loss=0.009280303120613098`, `peak_memory=17.974144464`, `trained_tokens=26190` |
| Final adapter saved | `train.log` records final adapter save at iter600 |
| Adapter sha | `adapters-rank16/adapters.safetensors` and `0000600_adapters.safetensors` both sha256 `9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6` |
| Trainer exited | `ps -p 42505` prints no live row after final save |
| Error scan | targeted scan found no Traceback, Error, Exception, Killed, SIGTERM, OOM, failed, nan, or inf in final sampled files |

## Non-Claims

- Not a true optimizer/RNG/dataloader/iteration resume.
- Not frozen formal 1800 completion.
- Not `lora_candidate`.
- Not C6 comparison or C6 acceptance.
- Not runtime-gated qa safety.
- Not UIUE merge readiness.
- Not voice/mobile/true-device readiness.
- Not V-PASS, S-PASS, or U-PASS.

## Next Gates

1. Cascade this receipt into `COMMANDER-LIVE-STATUS.md`, `STATUS-BOARD.md`, `EVIDENCE-INDEX.md`, `docs/CURRENT.md`, and `docs/baseline-roadmap-2026-07-05-c5-d106.md`.
2. Run read-only cascade audit `L-CO`.
3. Open runtime safety and C6 construction lanes with proof-class caps.
```

- [ ] **Step 3: Cascade without promotion**

Run:

```bash
RUNROOT=/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch
rg -n "ITER600_FINAL_PENDING|formal_train_done|candidate_status=sign[e]d|C6 acceptance|V-PASS|behavior pass|adapter_learned_qa=tr[u]e" \
  "$RUNROOT/COMMANDER-LIVE-STATUS.md" \
  "$RUNROOT/secretary/STATUS-BOARD.md" \
  "$RUNROOT/secretary/EVIDENCE-INDEX.md" \
  docs/CURRENT.md \
  docs/baseline-roadmap-2026-07-05-c5-d106.md
```

Expected:

```text
before cascade: hits include ITER600_FINAL_PENDING in current status documents
after cascade: no ITER600_FINAL_PENDING remains as current state; non-claim and historical mentions remain explicit
no signed-candidate status, true adapter-learned-qa flag, C6 acceptance, V-PASS, or behavior pass promotion appears
```

- [ ] **Step 4: Record audit requirement**

Create `monitor/tail1200-iter600-final-cascade-audit-L-CO.md` with verdict `PASS` only if all cascaded files distinguish `training_artifact_final` from `candidate`.

## Task 2: Add runs Nest To Commander Cascade

**Files:**
- Create: `docs/commander-log/RUNS-CASCADE.md`
- Create: `runs/README.md`
- Modify: `docs/README.md`
- Modify: `docs/CURRENT.md`
- Modify: `docs/commander-log/COMMANDER-INDEX.md`

**Interfaces:**
- Consumes: external run roots under `/Users/wanglei/Projects/agent-tmux-stack-research/runs/`.
- Produces: tracked index `docs/commander-log/RUNS-CASCADE.md` and safe repo-local `runs/README.md`.

- [ ] **Step 1: Write tracked run cascade index**

Create `docs/commander-log/RUNS-CASCADE.md` with this content:

```markdown
# Commander Runs Cascade

## Purpose

This file is the tracked index for commander run roots. The raw run roots live outside the repository under `/Users/wanglei/Projects/agent-tmux-stack-research/runs/`.

## Rules

- Do not stage raw adapter weights, metrics dumps, training logs, browser captures, or generated run directories with blanket staging.
- For each active run root, maintain a status board, evidence index, receipt list, and latest closeout verdict.
- A run receipt can support a repo claim only when the repo document cites the receipt path and preserves proof class.
- External run roots are local operational evidence; they are not automatically release artifacts.

## Active Run Roots

| Run root | Purpose | Current authority files | Claim ceiling |
|---|---|---|---|
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch` | C5 formal/tail training evidence | `COMMANDER-LIVE-STATUS.md`, `secretary/STATUS-BOARD.md`, `secretary/EVIDENCE-INDEX.md` | unsigned training artifact until candidate signoff passes |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates` | Phase 1 scanner and label authority gates | `eval/launchpacket-frozen/`, `redteam/phase1-cleanup-audit.md` | formal-start static gate evidence |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness` | train-readiness grill and historical gates | `STATUS-BOARD.md`, W-series receipts | historical evidence and reusable guardrails |

## Cascade Checklist

1. Every active run root has a status board and evidence index.
2. Every repo current-state document points to the active run root.
3. Every run-root final receipt has a read-only audit.
4. Every status phrase includes proof class.
5. Historical rows are labeled historical or superseded.
```

- [ ] **Step 2: Write repo-local runs README**

Create `runs/README.md` with this content:

```markdown
# runs

This directory is a tracked pointer for commander run governance, not a raw artifact dump.

Raw operational artifacts live under:

`/Users/wanglei/Projects/agent-tmux-stack-research/runs/`

Rules:

- Do not stage raw adapter weights, metrics logs, trainer logs, screenshots, or generated run directories from this repo-local `runs/` directory.
- Track only small hand-written indexes when a commander explicitly requests them.
- Use `docs/commander-log/RUNS-CASCADE.md` as the maintained index.
```

- [ ] **Step 3: Link it from routing docs**

Add one line to `docs/README.md`, `docs/CURRENT.md`, and `docs/commander-log/COMMANDER-INDEX.md` pointing to `docs/commander-log/RUNS-CASCADE.md`.

- [ ] **Step 4: Verify no raw run artifacts are staged**

Run:

```bash
git status --short -- runs docs/commander-log/RUNS-CASCADE.md
find runs -type f -maxdepth 2 -print
find runs -type f \( -name '*.safetensors' -o -name 'metrics.jsonl' -o -name 'train.log' -o -name '*.png' -o -name '*.mov' \) -print
```

Expected:

```text
Only runs/README.md and docs/commander-log/RUNS-CASCADE.md are candidates for staging.
No adapter .safetensors, metrics.jsonl, train.log, or generated screenshots appear under tracked runs/.
The raw artifact scan prints no paths.
```

## Task 3: Build The C5 Closeout Gate Matrix

**Files:**
- Create: `docs/project/phase0/c5-closeout-gate-matrix-2026-07-06.md`
- Modify: `docs/CURRENT.md`
- Modify: `docs/baseline-roadmap-2026-07-05-c5-d106.md`

**Interfaces:**
- Consumes: `TAIL1200-ITER600-FINAL-RECEIPT-L-CN.md`, `R5-top-failing-c6-case-drilldown.md`, `R7-final-route-deframing-signoff.md`, and OpenSpec `retrain-c5-lora-d-domain`.
- Produces: gate names used by runtime, C6, UIUE, and voice child plans.

- [ ] **Step 1: Create the gate matrix**

Create `docs/project/phase0/c5-closeout-gate-matrix-2026-07-06.md` with this table:

```markdown
# C5 Closeout Gate Matrix 2026-07-06

| Gate | Required evidence | Current state | Proof class | Can promote candidate |
|---|---|---|---|---|
| G1 train_health | final adapter saved, metrics/log clean, trainer exited | PASS for tail1200 600iter artifact | runtime/local | no |
| G2 runtime-gated qa safety | RuntimeQueryGuard, D-domain mount receipt, readback proof, qa cross-track cases total 0 on runtime path | open | local/integration/runtime after implementation | no by itself |
| G3 adapter-only qa | adapter prompt path qa=0 | not met; 9/9/9 hardened failure history | local eval | no |
| G4 R-L17 R1-R7 candidate review | first-hand evidence files, R5 case drilldown populated, R6 drift review, final human candidate signoff | route-only only; candidate unsigned | project decision | yes only when signed |
| G5 W34 final-head default-scope rerun | `make verify-default-scope` or equivalent on final candidate head | open | local | no by itself |
| G6 base-vs-LoRA C6 comparison | same harness, base anchor, signed candidate artifact | blocked before signed candidate | local/integration after auth | supports C6, not V-PASS |
| G7 UIUE mainline merge | shared contract/runtime proof, UIUE absorption audit, merge authorization | isolated only | local/integration/desktop by later proof | no |
| G8 voice readiness | ASR/TTS preflight, normalizer, confidence gate, device proof | spec-only | desktop/mobile/true-device by later proof | no |
```

- [ ] **Step 2: Add current route summary**

Add this sentence to `docs/CURRENT.md` and baseline:

```markdown
Current route after C5 tail final: close the unsigned training artifact first; runtime safety is the main runtime falsification gate en route to candidate review; C6 construction can proceed in parallel; C6 comparison/acceptance, UIUE merge, voice readiness, and V-PASS remain blocked until their proof-class gates exist.
```

- [ ] **Step 3: Verify wording**

Run:

```bash
rg -n "candidate_status=sign[e]d|adapter_learned_qa=tr[u]e|C6 acceptance achieve[d]|V-PASS achieve[d]|voice ready|UIUE merge complete" docs/CURRENT.md docs/baseline-roadmap-2026-07-05-c5-d106.md docs/project/phase0/c5-closeout-gate-matrix-2026-07-06.md
```

Expected:

```text
No matches.
```

## Task 4: Split Runtime And C6 Work Correctly

**Files:**
- Create: `docs/superpowers/plans/2026-07-06-runtime-query-safety-gate.md`
- Create: `docs/superpowers/plans/2026-07-06-c6-construction-and-candidate-comparison-routing.md`

**Interfaces:**
- Consumes: gate matrix names `G2`, `G6`, and R7 route-only signoff.
- Produces: two child plans with explicit dependency order.

- [ ] **Step 1: Write runtime child plan header**

Create `docs/superpowers/plans/2026-07-06-runtime-query-safety-gate.md` beginning with:

```markdown
# Runtime Query Safety Gate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prove runtime-gated qa safety for C5 without claiming that LoRA adapter-only qa is solved.

**Architecture:** Implement and test the runtime path that blocks or reroutes query/status/action-question cases before unsafe tool-call mount. Produce `RuntimeAdapterMountReceipt` and run qa cross-track cases on runtime path.

**Tech Stack:** Swift, SwiftPM/Xcode tests, MAformac runtime contracts, OpenSpec `define-runtime-presentation-bridge`, run-dir receipts.

## Global Constraints

- This plan cannot write a true learned-qa flag for the adapter.
- This plan cannot claim C6 acceptance, UIUE merge, voice readiness, mobile readiness, true-device readiness, or V-PASS.
- PASS requires runtime-path cases, not adapter prompt-path cases only.
- PASS requires `RuntimeQueryGuard` on the active adapter mount path, a `RuntimeAdapterMountReceipt` binding adapter sha/code head/case ledger/readback surface, qa/query/status/action-question cross-track cases totaling 0 unsafe actuation on runtime path, and at least one negative case that would fail adapter-only but is blocked or rerouted by runtime.
```

- [ ] **Step 1a: Stop if runtime gate is already satisfied**

Before writing a runtime implementation task, check whether G2 is already PASS:

```bash
rg -n "RuntimeAdapterMountReceipt|G2.*PASS|runtime-gated qa safety.*PASS" docs /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-governance 2>/dev/null
```

Expected:

```text
If a valid G2 runtime-gated qa safety receipt already exists, do not rerun runtime as ceremony; move to R-L17 candidate signoff and C6 comparison authorization review.
```

- [ ] **Step 2: Write C6 child plan header**

Create `docs/superpowers/plans/2026-07-06-c6-construction-and-candidate-comparison-routing.md` beginning with:

```markdown
# C6 Construction And Candidate Comparison Routing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Continue C6 construction under route-only authority while blocking C6 comparison and acceptance until signed candidate and explicit run authorization exist.

**Architecture:** Split C6 into construction artifacts and candidate comparison artifacts. Construction can build denominators, BehaviorClass SSOT, replay/readback, fingerprints, and fixtures; comparison waits for signed adapter artifact and run auth.

**Tech Stack:** OpenSpec `rebuild-c6-four-layer-bench`, Swift tests, fixture ledgers, run-dir receipts.

## Global Constraints

- R7 route-only unlocks C6 construction only.
- C6 comparison and C6 acceptance stay blocked until C5 candidate is signed.
- L6/R2b/R3/R4/R5 historical cases can seed construction but cannot become the final denominator without review.
- `C6_CONSTRUCTION_ALLOWED_NOW`: OpenSpec/task cleanup, current-baseline reconfirm, D-domain expected-tool mapping, four-layer scorer/selector, BehaviorClass SSOT, replay/readback/fingerprint, and L6 seed recoding plan.
- `C6_COMPARISON_BLOCKED`: base-vs-LoRA comparison, C6 acceptance, D-domain base recalibration, model-quality evaluation, golden/demo/voice/UIUE/V-PASS.
- If a proposed C6 task needs a model run, candidate adapter selection, base recalibration, release-case acceptance, or product readiness claim, stop and require signed candidate plus explicit run auth.
- Do not merge `g6`, `doc-absorption`, or `grill` branches wholesale. Port only reviewed construction deltas onto current head after branch/head/origin-main/API reconfirmation.
- Documentation construction validation is OpenSpec/static. Implementation construction validation requires GitNexus impact before symbol edits, targeted C6/unit tests, and `detect_changes` before commit. Neither validation class equals C6 acceptance or model-quality proof.
```

- [ ] **Step 3: Verify dependency wording**

Run:

```bash
rg -n "C6 acceptance|candidate|runtime-gated|adapter_learned_qa|route-only" docs/superpowers/plans/2026-07-06-runtime-query-safety-gate.md docs/superpowers/plans/2026-07-06-c6-construction-and-candidate-comparison-routing.md
```

Expected:

```text
Runtime plan contains runtime-gated non-claims.
C6 plan contains route-only construction and blocks comparison/acceptance before signed candidate.
```

## Task 5: Bound UIUE And Voice Parallel Work

**Files:**
- Create: `docs/superpowers/plans/2026-07-06-uiue-isolated-merge-readiness.md`
- Create: `docs/superpowers/plans/2026-07-06-voice-contract-preflight.md`
- Modify: `docs/CURRENT.md`

**Interfaces:**
- Consumes: current UIUE repo `/Users/wanglei/workspace/MAformac-uiue` and voice docs in `docs/README.md`.
- Produces: parallel-safe work limits.

- [ ] **Step 1: Write UIUE child plan boundary**

Create `docs/superpowers/plans/2026-07-06-uiue-isolated-merge-readiness.md` with this route statement:

```markdown
# UIUE Isolated Merge Readiness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prepare UIUE absorption and merge readiness without merging UIUE into MAformac mainline.

**Architecture:** Work only in `/Users/wanglei/workspace/MAformac-uiue` or read-only from MAformac unless a mainline merge gate is explicitly opened. Reconfirm shared contracts, generated payloads, state/readback surfaces, and proof-class display caps before proposing a merge.

**Tech Stack:** Swift, SwiftUI, MAformac-uiue, runtime-presentation bridge contracts, local simulator checks.

## Global Constraints

- No UIUE mainline merge without shared contract/runtime proof and explicit user gate.
- UIUE operator proof is not C5 candidate proof.
- UIUE desktop/simulator proof is not mobile, true-device, or V-PASS.
- Parallel-safe: OpenSpec contract/static fixture/schema/manifest parity, UIUE read-only inventory, local fixture decode, and mic/orb/card/readback UI choreography only.
- Blocked: direct merge, ASR/TTS, live-loop, C6 acceptance, runtime-ready, voice-ready, candidate/V/S/U-PASS.
- No UIUE receipt may cite tail1200 loss or checkpoint as UIUE readiness.
- Before UIUE simulator/build smoke, re-probe active trainer/eval processes and host memory; serialize if C5 eval/training is active or memory pressure is high.
```

- [ ] **Step 2: Write voice child plan boundary**

Create `docs/superpowers/plans/2026-07-06-voice-contract-preflight.md` with this route statement:

```markdown
# Voice Contract Preflight Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prepare the voice contract and preflight plan without claiming voice readiness.

**Architecture:** Define ASR/TTS backend contracts, speech normalizer expectations, confidence gate, prompt-token/hotword handling, and proof-class ladder. Keep implementation behind runtime proof and candidate signoff.

**Tech Stack:** Swift, Apple Speech/SFSpeech references, TTS preflight docs, MAformac voice pipeline docs.

## Global Constraints

- No voice readiness claim without runtime integration and device-level proof.
- No mobile or true-device claim from desktop or simulator proof.
- Voice can prepare contracts in parallel but must not gate C5 closeout.
- Voice preflight may define presentation choreography and proof-class display only; it cannot claim ASR/TTS implementation, endpoint readiness, model readiness, live-loop readiness, mobile proof, true-device proof, or voice-ready.
- No voice receipt may cite tail1200 loss or checkpoint as voice readiness.
```

- [ ] **Step 3: Add GRILL-C addendum to the UIUE merge plan**

Patch `docs/superpowers/plans/2026-07-05-uiue-merge-battle-plan.md` under its scope contract with:

```markdown
GRILL-C addendum: UIUE/voice parallel work is safe only as OpenSpec contract/static fixture/schema/manifest parity, UIUE read-only inventory, local fixture decode, and mic/orb/card/readback UI choreography. Direct merge, ASR/TTS, live-loop, C6 acceptance, runtime-ready, voice-ready, candidate/V/S/U-PASS remain blocked. No UIUE or voice receipt may cite tail1200 loss/checkpoint as readiness.
Host guard: before simulator/build smoke, re-probe active trainer/eval processes and host memory; serialize if C5 eval/training is active or memory pressure is high.
```

- [ ] **Step 4: Add voice/orb proof-cap requirement to bridge spec**

Patch `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md` with a requirement that voice/orb fields are presentation choreography only and not ASR/TTS, endpoint, model, live-loop, mobile, true-device, voice-ready, or runtime-ready proof. The proof class must remain finite and inherited from the parent payload.

- [ ] **Step 5: Add bridge task gate for safe-lane preflight**

Patch `openspec/changes/define-runtime-presentation-bridge/tasks.md` with an unchecked gate:

```markdown
- [ ] Run GRILL-C safe-lane preflight: UIUE fixture decode plus mic/orb display-state local tests; receipt must say local/simulator only and no UIUE merge, voice-ready, C6 acceptance, V-PASS, mobile, or true-device proof.
```

- [ ] **Step 6: Add parallel route summary to current docs**

Add this sentence to `docs/CURRENT.md`:

```markdown
Parallel-safe work: C6 construction, UIUE isolated readiness, and voice contract preflight may proceed after C5 final truth freeze; C6 comparison/acceptance, UIUE mainline merge, voice readiness, and V-PASS remain downstream gated.
```

## Task 6: Classify Dirty Tree And Worktrees Before GitHub Push

**Files:**
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-governance/dirty-tree-classification.md`
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-governance/worktree-inventory.md`
- Create: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-governance/github-push-gate.md`

**Interfaces:**
- Consumes: `git status --short --branch`, `git worktree list`, and explicit path ownership.
- Produces: push/no-push verdict.

- [ ] **Step 1: Capture dirty tree**

Run:

```bash
git status --short --branch
git diff --stat
git diff --name-status
git diff --name-only
git ls-files --others --exclude-standard
```

Expected current groups:

```text
Modified governance docs: AGENTS.md, CLAUDE.md, docs/CURRENT.md, docs/baseline-roadmap-2026-07-05-c5-d106.md, docs/commander-log/COMMANDER-INDEX.md
Modified training code/tests: Core/Training/C5LoRATraining.swift, Tests/MAformacCoreTests/C5LoRATrainingTests.swift
Modified OpenSpec docs: openspec/changes/retrain-c5-lora-d-domain/*, openspec/changes/run-lora-candidate-training/*
Untracked operational/support paths: .xcodebuildmcp/, Tools/agent-platform-plugin-refs/, XSWAP-23-fix.md, docs/handoffs/*, docs/superpowers/plans/2026-07-05-uiue-merge-battle-plan.md, runs/
```

- [ ] **Step 2: Write classification**

Create a table with columns:

```markdown
| Path | Category | Owner | Stage now | Reason |
|---|---|---|---:|---|
| `docs/project/phase0/c5-closeout-commander-plan-2026-07-06.md` | commander plan | commander | yes after final adversarial audit | current requested artifact |
| `runs/README.md` | commander nest pointer | commander | yes after audit | safe tracked pointer |
| `Core/Training/C5LoRATraining.swift` | code dirt | unknown until diff audit | no | code change needs impact analysis and tests |
| `Tests/MAformacCoreTests/C5LoRATrainingTests.swift` | test dirt | unknown until diff audit | no | paired with code dirt |
| `runs/` raw contents except README | operational artifacts | local run nest | no | raw artifacts are not repo commit material |
```

`Stage now` must use exactly one enum value:

```text
yes_docs_after_audit
no_code_pending_diff_audit
no_raw_artifact
no_unowned
defer
```

- [ ] **Step 3: Capture worktree inventory**

Run:

```bash
git worktree list
find .. -maxdepth 1 -type d -name 'MAformac*' -print | sort
```

Expected:

```text
main current worktree: /Users/wanglei/workspace/MAformac
UIUE isolated worktree/repo: /Users/wanglei/workspace/MAformac-uiue
bridge worktree/repo: /Users/wanglei/workspace/MAformac-p5w-wave1-bridge
several /private/tmp worktrees marked prunable
```

- [ ] **Step 4: Write GitHub push gate**

Create `github-push-gate.md` with this verdict:

```markdown
# GitHub Push Gate

Current verdict: DO_NOT_PUSH_YET.

Push may happen only after:

1. Final adversarial audit passes the commander plan or all findings are fixed.
2. Dirty tree classification has owner, stage-now, and no-touch verdicts for every dirty path.
3. No raw run artifacts, adapters, metrics dumps, secrets, or local-only generated directories are staged.
4. Branch behind-7 strategy is chosen: rebase/merge/update branch or intentionally push current branch with documented divergence.
5. Target validation commands pass for staged paths.
6. User explicitly authorizes external push.

Additional divergence risk: `git rev-list --count HEAD..origin/main` returned `190`; any future main-targeting PR must handle this separately from the upstream branch ahead/behind count.

Hard pre-push check:

```bash
git diff --cached --name-only
git diff --cached --check
git status --short --branch
rg -n "candidate_status=sign[e]d|adapter_learned_qa=tr[u]e|C6 acceptance achieve[d]|V-PASS achieve[d]|voice ready|UIUE merge complete" docs/project docs/commander-log docs/superpowers/plans
find runs -type f \( -name '*.safetensors' -o -name 'metrics.jsonl' -o -name 'train.log' -o -name '*.png' -o -name '*.mov' \) -print
```

Allowed first push shape after all gates:

- docs-only branch push for commander plan, run cascade index, and closeout receipts.
- no PR merge claim.
- no release tag.
```

## Task 7: Validate And Commit Documentation Only

**Files:**
- Stage only after final adversarial audit and dirty classification approve:
  - `docs/project/phase0/c5-closeout-commander-plan-2026-07-06.md`
  - `docs/commander-log/RUNS-CASCADE.md`
  - `runs/README.md`
- final closeout docs explicitly owned by this plan
- cascade docs modified by Tasks 1-3 (`docs/CURRENT.md`, `docs/baseline-roadmap-2026-07-05-c5-d106.md`, `docs/commander-log/COMMANDER-INDEX.md`) only after Task 6 classifies them as owned and a diff review confirms they are not pre-existing unrelated dirt

Use pathspec-only staging. Never use blanket add commands or blanket directory staging for this closeout.

**Interfaces:**
- Consumes: final adversarial audit file and dirty-tree classification.
- Produces: a local docs commit, not a GitHub push.

- [ ] **Step 1: Run documentation scans**

Run:

```bash
rg -n "TB[D]|TO[D]O|implement[ ]later|fill[ ]in[ ]details|candidate_status=sign[e]d|adapter_learned_qa=tr[u]e|C6 acceptance achieve[d]|V-PASS achieve[d]" docs/project/phase0/c5-closeout-commander-plan-2026-07-06.md docs/commander-log/RUNS-CASCADE.md runs/README.md
```

Expected:

```text
No matches.
```

- [ ] **Step 2: Confirm staged paths**

Run:

```bash
git diff -- docs/project/phase0/c5-closeout-commander-plan-2026-07-06.md docs/commander-log/RUNS-CASCADE.md runs/README.md
git status --short -- docs/project/phase0/c5-closeout-commander-plan-2026-07-06.md docs/commander-log/RUNS-CASCADE.md runs/README.md
```

Expected:

```text
Only explicitly owned docs appear in the stage candidate set. If cascade docs are edited, they must either be classified and staged with pathspecs after diff review, or left as working-tree state with a written `defer` reason in dirty-tree classification.
```

- [ ] **Step 3: Commit after user-approved staging set**

Run only after commander confirms no unrelated path is being staged:

```bash
git add -- docs/project/phase0/c5-closeout-commander-plan-2026-07-06.md docs/commander-log/RUNS-CASCADE.md runs/README.md
git commit -m "docs: plan C5 closeout and downstream routing"
```

Expected:

```text
one docs commit created
no code files staged
no raw run artifacts staged
```

## Task 8: Final Adversarial Audit And Plan Finalization

**Files:**
- Read: `docs/project/phase0/c5-closeout-commander-plan-2026-07-06.md`
- Create one actual final adversarial audit artifact:
  - Preferred: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-plan-audit/opus-c5-closeout-plan-audit.md`
  - Accepted fallback: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-plan-audit/codex-p-audit4-c5-closeout-plan-audit.md`
  - Actual final audit used for plan finalization: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-worker-round2/w15-final-adversarial-audit.md`
- Modify: `docs/project/phase0/c5-closeout-commander-plan-2026-07-06.md`

**Interfaces:**
- Consumes: first saved plan, Task 0 grill lane files, `grill-reduction.md`, `grill-reduction-audit.md`, and the actual final adversarial audit artifact.
- Produces: final plan status `FINAL_AFTER_REDUCTION_AND_ADVERSARIAL_AUDIT`.

- [ ] **Step 1: Dispatch final adversarial audit**

Use preferred pane `%15` when available:

```bash
tmux-bridge message %15 '<audit prompt with exact plan path and output file>'
tmux-bridge read %15 30
tmux-bridge keys %15 Enter
```

If `%15` is stuck or unavailable, dispatch the same audit contract to an available Codex or Claude pane and write a distinct artifact path. The fallback artifact is valid only if it contains the same required fields and exact plan path.

Required audit questions:

```text
1. Does the plan accidentally promote tail1200 iter600 training to candidate/C6/V-PASS?
2. Is runtime correctly placed before candidate promotion?
3. Is C6 construction separated from C6 comparison/acceptance?
4. Are UIUE and voice parallel lanes capped correctly?
5. Is dirty tree/worktree/GitHub push sequencing safe?
6. Is the runs directory treated as commander nest without raw artifact staging?
7. Are right-side workers used with bounded output files and ack protocol?
8. Does the finalization gate mechanically require four grill lane files, grill reduction, reduction audit, and final adversarial audit absorption?
9. Does the finalization gate mechanically require the governance artifacts before any final push-ready or push status can be written?
10. Which findings are P0/P1/P2, with exact plan section references?
```

- [ ] **Step 2: Read audit artifact**

Run:

```bash
AUD_DIR=/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-plan-audit
W15=/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-worker-round2/w15-final-adversarial-audit.md
if test -s "$W15"; then
  AUD="$W15"
elif test -s "$AUD_DIR/opus-c5-closeout-plan-audit.md"; then
  AUD="$AUD_DIR/opus-c5-closeout-plan-audit.md"
elif test -s "$AUD_DIR/codex-p-audit4-c5-closeout-plan-audit.md"; then
  AUD="$AUD_DIR/codex-p-audit4-c5-closeout-plan-audit.md"
else
  echo "missing final adversarial audit artifact"
  exit 1
fi
sed -n '1,220p' "$AUD"
```

Expected:

```text
one actual final adversarial audit file exists
audit contains verdict, findings, evidence table, confidence, touched paths, residual risk
```

- [ ] **Step 3: Patch plan based on audit**

Apply every accepted P0/P1 finding. If a finding is rejected, add a short rejection note with evidence.

- [ ] **Step 4: Verify finalization prerequisites**

Run:

```bash
tmux-bridge list
GR=/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill
AUD=/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-plan-audit
test -s "$GR/grill-lane-a-runtime-first.md"
test -s "$GR/grill-lane-b-c6-first.md"
test -s "$GR/grill-lane-c-uiue-voice-parallel.md"
test -s "$GR/grill-lane-d-dirty-push-runs.md"
test -s "$GR/grill-reduction.md"
test -s "$GR/grill-reduction-audit.md"
GOV=/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-governance
test -s "$GOV/dirty-tree-classification.md"
test -s "$GOV/worktree-inventory.md"
test -s "$GOV/github-push-gate.md"
test -s "$AUD/opus-c5-closeout-plan-audit.md" || test -s "$AUD/codex-p-audit4-c5-closeout-plan-audit.md"
rg -n "verdict:|Verdict|PASS|FINDINGS|accepted|rejected-with-evidence|Plan change" "$GR" "$AUD"
rg -n "DRAFT_PENDING_GRILL_REDUCTION_AND_ADVERSARIAL_AUDIT|Audit Absorption Ledger|FINAL_AFTER_REDUCTION_AND_ADVERSARIAL_AUDIT" docs/project/phase0/c5-closeout-commander-plan-2026-07-06.md
```

Expected:

```text
all four grill lane files exist and are non-empty
grill reduction exists and is non-empty
reduction audit exists and is non-empty
one final adversarial audit artifact exists and is non-empty
`tmux-bridge list` output confirms `%13` and all assigned/fallback panes before final status is written
all P0/P1 findings from reduction audit and final adversarial audit are mapped in Audit Absorption Ledger with accepted or rejected-with-evidence disposition
plan still shows draft status before this step and only changes to final after this checklist passes
```

Finalization closing records now absorbed:

```text
final_adversarial_audit=/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-worker-round2/w15-final-adversarial-audit.md
verdict=PASS
finalize_now=yes(conditional)
no_P0_or_P1=true
residual_P2s_deferred_to_push_or_commit_gates=secret-like filename review, branch strategy, untracked plan commit gate
tmux-bridge list captured before final edit:
  %13 = dispatcher/current commander-control pane (codex-worker-1)
  %12/%11/%14/%15/%16 = right-side flexible worker panes
  %0 = visible codex-commander pane, when present in current topology
non_claims=no push, no training, no candidate signoff, no C6 comparison/acceptance, no UIUE merge, no voice readiness, no mobile/true-device/live/V/S/U-PASS
```

- [ ] **Step 5: Mark final**

Add this section near the top:

```markdown
## Plan Status

status: FINAL_AFTER_REDUCTION_AND_ADVERSARIAL_AUDIT
grill_reduction: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-reduction.md`
grill_reduction_audit: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill/grill-reduction-audit.md`
final_adversarial_audit: `<actual audit artifact path used>`
finalized_at: 2026-07-06T13:00:00+08:00
```

## Self-Review

Spec coverage:

- Grill-before-plan governance is covered by Task 0, Worker Allocation, and Plan Status.
- C5 closeout is covered by Tasks 1, 2, and 3.
- Runtime vs C6 ordering is covered by Task 4 and the commander decision table.
- Voice and UIUE parallel boundaries are covered by Task 5.
- Dirty tree, worktree state, and GitHub push timing are covered by Task 6 and Task 7.
- Right-side worker utilization and final adversarial audit loop are covered by Worker Allocation and Task 8.
- runs directory cascade is covered by Task 2.

Placeholder scan:

- The plan avoids placeholder markers and uses split regex tokens in scan commands so the scan does not match its own instructions.
- Open evidence remains labeled `open`, `blocked`, or `unsigned`; these are state words, not placeholders.

Type and naming consistency:

- The C5 final receipt status is consistently `TAIL1200_ITER600_FINAL_SAVED__UNSIGNED_TRAINING_ARTIFACT__NO_CANDIDATE`.
- Runtime safety is consistently `runtime-gated qa safety`.
- C6 is consistently split into `construction` and `comparison/acceptance`.

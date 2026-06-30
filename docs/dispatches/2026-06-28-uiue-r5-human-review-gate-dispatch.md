---
status: DISPATCH_READY
artifact_kind: human_review_gate_dispatch
created_at: 2026-06-28
from: UIUE R5 commander
to: mixed integration Codex window
target_thread: 019f0ebc-8e13-74a0-a2fb-7a8d402645bf
dispatch_id: R5-D7-human-review-gate-prep
proof_class_ceiling: docs/local + local_static + simulator_mock_if_opened
audit_subject: none_new_by_commander_order
source_map:
  - /Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md
  - /Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-dual-repo-integration-train-2026-06-28.md
  - /Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-28-uiue-r5-dual-repo-integration-train-dispatch.md
  - /Users/wanglei/workspace/MAformac/docs/project/phase0/r5-mainline-terminal-snapshot-adapter-dispatch-1-2026-06-28.md
  - /Users/wanglei/workspace/MAformac/docs/project/phase0/r5-mainline-contract-test-hardening-dispatch-2-2026-06-28.md
non_claims:
  - no R5 complete
  - no runtime-ready
  - no mobile proof
  - no true_device proof
  - no voice-ready
  - no model-ready
  - no golden-ready
  - no endpoint-ready
  - no UIUE merge
  - no V-PASS
  - no S-PASS
  - no U-PASS
  - no A-2
  - no A-2 ready
  - no A-2 complete
---

# Dispatch 7 - R5 Human Review Gate Prep

## 0. Commander Instruction

Proceed from D6 integration to a human-review-ready state. This is not an implementation dispatch.

The commander has explicitly said not to arrange additional subagents for this next step. Do not run Codex subagent audit, Hermes audit, or GLM audit unless the commander later overrides this instruction.

## 1. Live Truth To Reconfirm

Before edits, live-probe both repos:

```bash
cd /Users/wanglei/workspace/MAformac-uiue
pwd
git branch --show-current
git rev-parse HEAD
git status --short

cd /Users/wanglei/workspace/MAformac
pwd
git branch --show-current
git rev-parse HEAD
git status --short
```

Expected commander-observed truth at dispatch time:

| Repo | Expected head | Expected dirty |
|---|---|---|
| UIUE | `9d50aa0d44d6d92871ae3ca0f67970439eb46c35` | clean |
| main | `d332db736a0c47eb3b8dc09c80fb907a0f43e29e` | preserve-unowned only: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `.xcodebuildmcp/`, `Tools/agent-platform-plugin-refs/` |

If live truth differs, record it and continue only if the difference is explainable and exact-path separable. Otherwise stop as `PARTIAL`.

## 2. Stage A - Close D6 Documentation State

D6 verdict returned `status: DONE`, but commander live-probe found two stale documentation markers:

- `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-dual-repo-integration-train-2026-06-28.md` frontmatter still says `status: RUNNING`.
- `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md` D6 row still says `running in mixed window`.

First reconcile these docs to the D6 verdict if live evidence confirms the commits and clean/cached states:

- D6 status becomes `DONE`.
- UIUE final head is `9d50aa0d44d6d92871ae3ca0f67970439eb46c35`.
- main final head is `d332db736a0c47eb3b8dc09c80fb907a0f43e29e`.
- Preserve the proof ceiling and non-claims.
- Do not edit unrelated main preserve-unowned docs.

## 3. Stage B - Produce Human Review Checklist

Create a human review packet at:

`/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-human-review-gate-2026-06-28.md`

The packet must be human-actionable. It must list each item with:

- review_id
- category
- question for 磊哥
- current evidence
- default recommendation
- choices
- proof cap
- what changes if accepted
- what remains blocked if not accepted
- whether simulator review is needed

Minimum checklist sections:

1. **D6 integration acceptance**: confirm D6 is accepted only as docs/local + local_unit + local_static + OpenSpec contract integration, not R5 complete.
2. **Human/product ledger H1**: include `C134`, `C135`, `C155`, `C160-C164`, `C172`, `C173`, `C194`; separate product wording, a11y policy, final-art policy, and customer-facing proof wording.
3. **Deferred owner gates**: include `C005`, `C018`, `C052`, `C061`; ask whether each remains deferred, becomes a bounded spike, or becomes a mainline implementation dispatch.
4. **K1 spike-before-implementation ledger**: include `C082`, `C083`, `C096`, `C117`, `C182`, `C197`, `C207`, `C208`; do not promote to implementation without a bounded spike receipt.
5. **M3 merge-only / future non-claim lanes**: explicitly preserve provenance-only or future-lane status; no implementation.
6. **Simulator review items**: list any visual/interaction/reduce-motion/a11y items that actually need 磊哥 to inspect a running simulator.

## 4. Stage C - Simulator Gate

If the human review packet marks any item as needing simulator inspection, open the simulator to a reviewable state.

Requirements:

- Work from `/Users/wanglei/workspace/MAformac-uiue`.
- Read the repo-local `.xcodebuildmcp/README.md` or current build instructions if present.
- Prefer XcodeBuildMCP simulator workflow if available; otherwise use the repo's established `xcodebuild`/`simctl` path.
- Use the UIUE-dedicated simulator/profile if configured.
- Leave Simulator open on the exact screen/state that needs review.
- Record the simulator name, app/scheme, command used, current screen/state, and proof class as `simulator_mock`.

If no simulator review is needed, do not open it just to look busy. Instead, write `simulator_required: no` and the reason.

Do not call simulator proof `mobile`, `true_device`, `V-PASS`, `S-PASS`, `U-PASS`, or `A-2`.

## 5. Validation

Required local checks:

```bash
cd /Users/wanglei/workspace/MAformac-uiue
git diff --check
openspec validate ui-presentation --strict
```

If simulator is opened, also record the build/run command result and visible target state. If a Swift file is touched unexpectedly, run the focused Swift tests relevant to that file and explain why code changed in a human-review prep dispatch.

## 6. Git / Commit Rules

This dispatch is documentation-first. Allowed UIUE edits:

- `docs/project/phase0/r5-dual-repo-integration-train-2026-06-28.md`
- `docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
- `docs/project/phase0/r5-human-review-gate-2026-06-28.md`
- optional simulator evidence index under `docs/research/` only if simulator inspection is actually needed.

No main repo edits unless a stale D6 reference there blocks the human review packet; if so, stop and report the exact blocker before editing.

If you commit, use exact pathspecs only. Do not use `git add .`. Do not push.

## 7. Verdict Back To Commander

Return a structured verdict with:

```yaml
status: DONE | PARTIAL | BLOCKED
label: UIUE_R5_D7_HUMAN_REVIEW_GATE_PREP
repo_truth:
  UIUE:
  main:
D6_doc_state_reconciled:
human_review_packet:
  path:
  item_count:
  simulator_required: yes | no
  simulator_opened: yes | no
  simulator_state:
human_review_checklist_summary:
  must_decide_now:
  can_defer:
  recommended_next_dispatch_after_human_review:
validation:
changed_paths:
commit:
non_claims:
residual_risks:
next_step_for_commander:
```

`status: DONE` requires the human review packet to exist, D6 stale doc state to be reconciled or explicitly explained, and simulator opened if the packet requires visual inspection.

## 8. Stop Conditions

Stop as `PARTIAL` or `BLOCKED` if:

1. D6 verdict cannot be reconciled with live repo state.
2. Human review checklist cannot be made actionable from existing receipts.
3. Simulator is required but cannot build/run/open to the needed state.
4. Any item would require new runtime, mobile, true-device, model, voice, golden, endpoint, C5/C6, K1, M3, or H1 implementation.
5. Any text claims R5 complete, runtime-ready, mobile, true_device, voice-ready, model-ready, golden-ready, endpoint-ready, UIUE merge, V-PASS, S-PASS, U-PASS, A-2, A-2 ready, or A-2 complete.
6. Exact-path staging cannot isolate owned docs.

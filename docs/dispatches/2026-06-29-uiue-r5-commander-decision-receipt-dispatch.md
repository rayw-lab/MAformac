---
status: DISPATCH_READY
artifact_kind: commander_decision_receipt_dispatch
created_at: 2026-06-29
from: UIUE R5 commander
to: mixed integration Codex window
target_thread: 019f0ebc-8e13-74a0-a2fb-7a8d402645bf
dispatch_id: R5-D8-commander-decision-receipt
scope: docs_only_decision_receipt
proof_class_ceiling: human_decision_record + docs/local + local_static
source_map:
  - /Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-human-review-gate-2026-06-28.md
  - /Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-dual-repo-integration-train-2026-06-28.md
  - /Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md
human_authorization:
  date: 2026-06-29
  source: commander thread user message
  text_summary: "全部授权同意，人审过了；只产出 commander decision receipt，把 5 条冻结口径写入。"
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

# Dispatch 8 - R5 Commander Decision Receipt

## 0. Auftrag

Produce exactly one commander decision receipt that freezes the approved human-review choices from D7.

This is a documentation-only receipt task. It is not an implementation dispatch, not a simulator review dispatch, not a new audit dispatch, and not a route to update code.

Do not arrange new Codex subagents, Hermes, GLM, simulator runs, GitNexus refresh, OpenSpec changes, runtime work, UIUE merge, push, or PR.

## 1. Live Truth Preflight

Before edits, record:

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

| repo | expected head | expected dirty |
|---|---|---|
| UIUE | `058ac4e63dd34f5980818fd3c6c925fb1389cab1` | only this D8 dispatch file may be untracked before your edits |
| main | `d332db736a0c47eb3b8dc09c80fb907a0f43e29e` | preserve-unowned only: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `.xcodebuildmcp/`, `Tools/agent-platform-plugin-refs/` |

If live truth differs, record it in the receipt and continue only if exact-path separable. Do not edit main.

## 2. Receipt Path

Create this file:

`/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-commander-decision-receipt-2026-06-29.md`

The receipt is authoritative only as a commander human-decision record for R5 routing. It is not a runtime contract or product acceptance.

## 3. Freeze These Five Decisions

The user/commander has approved all five defaults from the D7 human-review summary. Freeze them exactly:

1. **D6 capped DONE accepted**: D6 is accepted only as `docs/local + local_unit + local_static + openspec_contract` integration-train DONE. It is not R5 complete, runtime-ready, mobile, true-device, UIUE merge, V-PASS, S-PASS, U-PASS, A-2, A-2 ready, or A-2 complete.
2. **H1 default policy accepted**: customer-facing UI must not display internal proof labels; display-only guard wording is accepted; a11y, final-art, proof wording, and customer-facing proof copy remain policy/human-decision surfaces and do not become mobile/true-device/product acceptance.
3. **Deferred owner gates remain deferred**: `C005`, `C018`, `C052`, and `C061` remain deferred. They are not implemented by D8 and not closed by D6/D7.
4. **K1 remains spike-before-implementation ledger**: `C082`, `C083`, `C096`, `C117`, `C182`, `C197`, `C207`, and `C208` remain bounded-spike candidates only. They are not implementation tasks until a future bounded spike receipt promotes one.
5. **M3 and future non-claim lanes remain separate**: M3 stays provenance-only/merge-only; mobile/true-device, voice/model/golden/endpoint, UIUE merge/push/PR remain future non-claim lanes requiring separate proof plans or human gates.

## 4. Required Receipt Contents

The receipt must include:

- frontmatter with `status: DONE`, `artifact_kind: commander_decision_receipt`, `created_at: 2026-06-29`, and `proof_class_ceiling: human_decision_record + docs/local + local_static`
- source evidence paths with absolute paths
- live repo truth for UIUE and main
- the five frozen decisions above
- a compact table mapping affected rows:
  - D6 acceptance row
  - H1 rows: `C134`, `C135`, `C155`, `C160-C164`, `C172`, `C173`, `C194`
  - deferred gates: `C005`, `C018`, `C052`, `C061`
  - K1 rows: `C082`, `C083`, `C096`, `C117`, `C182`, `C197`, `C207`, `C208`
  - M3 / future non-claim lanes
- explicit next-routing recommendation:
  - default next step is **no implementation yet**; commander may choose a later bounded lane
  - if `C052` is later promoted, route as bounded simulator/debug-tool spike with `simulator_mock` cap
  - if `C005`, `C018`, or `C061` is later promoted, route to mainline spike/implementation, not UIUE docs
  - if final-art/white-edge is later promoted, route as visual simulator review with exact screen/state
- non-claims copied from this dispatch
- changed paths and validation table

## 5. Allowed Paths

Allowed UIUE paths:

- `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-29-uiue-r5-commander-decision-receipt-dispatch.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-commander-decision-receipt-2026-06-29.md`

Do not edit main repo.

Do not update code, OpenSpec specs/tasks, GitNexus artifacts, simulator evidence, or roadmap/map files in this dispatch unless a validation blocker proves the receipt cannot stand without one. If that happens, stop as `PARTIAL` and explain the blocker instead of widening scope.

## 6. Validation

Run:

```bash
cd /Users/wanglei/workspace/MAformac-uiue
git diff --check
openspec validate ui-presentation --strict
```

No Swift files should be touched. If any Swift file changes, stop and report `PARTIAL`; that is out of scope.

## 7. Git Rules

If you commit, use exact pathspecs only:

```bash
git add -- \
  docs/dispatches/2026-06-29-uiue-r5-commander-decision-receipt-dispatch.md \
  docs/project/phase0/r5-commander-decision-receipt-2026-06-29.md
```

Do not use `git add .`.
Do not push.

## 8. Verdict Back To Commander

Return:

```yaml
status: DONE | PARTIAL | BLOCKED
label: UIUE_R5_D8_COMMANDER_DECISION_RECEIPT
repo_truth:
  UIUE:
  main:
receipt:
  path:
  frozen_decisions_count: 5
  affected_rows:
validation:
changed_paths:
commit:
  hash:
  message:
  pushed: no
non_claims:
residual_risks:
next_step_for_commander:
```

`status: DONE` requires the receipt file to exist, the five decisions to be frozen without widening scope, validation to pass, and any commit to use exact pathspecs only.

## 9. Stop Conditions

Stop as `PARTIAL` or `BLOCKED` if:

1. Live repo truth cannot be reconciled with D7/D8 source evidence.
2. Any requested receipt wording would imply R5 complete, runtime-ready, mobile, true_device, voice/model/golden/endpoint readiness, UIUE merge, V-PASS, S-PASS, U-PASS, A-2, A-2 ready, or A-2 complete.
3. You need to edit code, OpenSpec, GitNexus, simulator evidence, or main repo files.
4. Exact-path staging cannot isolate the two allowed UIUE docs.
5. Validation fails and cannot be fixed within the two allowed UIUE docs.

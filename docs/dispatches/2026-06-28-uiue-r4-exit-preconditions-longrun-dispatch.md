---
status: active_dispatch
artifact_kind: longrun_closeout_dispatch
date: 2026-06-28
to_thread_id: 019f0c2f-6b08-7c32-a18a-fe0b3a81b69c
from: UIUE commander
repo_uiue: /Users/wanglei/workspace/MAformac-uiue
repo_mainline: /Users/wanglei/workspace/MAformac
uiue_base_before_dispatch: 717ddce
proof_class_ceiling: docs/local + local + unit + simulator/mock
authority: dispatch_not_ssot
non_claims: [no R4 closeout until step 5, no V-PASS, no mobile, no true_device, no runtime-ready, no voice-ready, no model-ready, no golden-ready, no endpoint-ready, no A-2 complete]
---

# UIUE R4 出站前置收口长跑派单

TO: Codex thread `019f0c2f-6b08-7c32-a18a-fe0b3a81b69c`

FROM: UIUE commander

MODE: goal-mode long-run, 严格串行执行

DELIVERABLE: 完成 UIUE R4 出站前置收口，产出 mainline co-author receipt、UIUE local proof pack、R1-R3 residual disposition、更新后的 R4 ledger、R4 closeout receipt，以及 R5 开闸/不开闸 verdict。

## 0. 硬口径

下一步不叫“R4 代码”，叫 **R4 出站前置收口**。里面可以有代码、fixture、test、checker、receipt，但主轴是清 R4 出站条件，不是继续堆 UIUE 本地代码。

串行顺序固定为：

1. mainline co-author review
2. UIUE R4 local proof slice
3. R1-R3 residual disposition
4. update R4 ledger
5. write R4 closeout receipt
6. R5 precondition verdict / R5 lane dispatch readiness

禁止并行推进这些阶段。每一阶段完成后必须安排独立 Codex subagent 审计，审计通过或 P0/P1 修复后才能进入下一阶段。

涉及 L3、人审、产品拍板、审美判断、true-device/mobile 证明的项，长跑执行者不要卡死等待磊哥现场确认。统一标为 `pending_human_review`，写清 proof gap、推荐选项、影响范围、是否阻塞 R5；完成六个步骤后汇总成人审清单交给磊哥。

## 1. Goal Mode

第一动作必须启动 goal mode。

Goal objective:

```text
Serially close UIUE R4 exit preconditions before R5: obtain/resolve mainline co-author receipt, complete UIUE local proof pack, dispose R1-R3 residuals, update R4 ledger, write R4 closeout, and produce R5 readiness verdict without overclaiming proof class.
```

Goal 不得在 Step 6 之前标 complete。若任何阶段 hard blocker 无法自助解决，写 `BLOCKED` receipt，并保持 goal active/blocked，不要 fake green。

## 2. 起手真态核验

在任何编辑前执行：

```bash
cd /Users/wanglei/workspace/MAformac-uiue
pwd
git branch --show-current
git rev-parse --short HEAD
git status --short
openspec validate ui-presentation --strict
git diff --check
rg -n "^- \\[[ x]\\] 8\\.(A|C2)" openspec/changes/ui-presentation/tasks.md

cd /Users/wanglei/workspace/MAformac
pwd
git branch --show-current
git rev-parse --short HEAD
git status --short
test -d openspec/changes/define-runtime-presentation-bridge; echo "bridge_dir_exit=$?"
rg -n "Runtime-Presentation bridge|define-runtime-presentation-bridge|not_proposed" docs/CURRENT.md
```

Expected snapshot at dispatch drafting time:

- UIUE repo was clean at base `717ddce` on `uiue/phase4-default-scope-presentation` before this dispatch file was added. If the first fresh probe sees a newer commit that only adds this dispatch file, treat that as expected and continue from the newer HEAD.
- Mainline branch previously observed as `codex/rebuild-c6-doc-absorption-20260624`, HEAD `de79c65`, bridge dir missing, CURRENT still `Runtime-Presentation bridge | not_proposed`.
- `8.C2` remains single `[x]`; `8.A1-A7` remain `[ ]`.

If live truth differs, report the delta first. Do not continue from stale assumptions.

## 3. Required Read-First Set

Read these before Step 1:

1. `/Users/wanglei/workspace/MAformac-uiue/CLAUDE.md`
2. `/Users/wanglei/workspace/MAformac-uiue/docs/CURRENT.md`
3. `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-burndown-2026-06-28.md`
4. `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md`
5. `/Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-implementation-slice1-20260628/receipt.md`
6. `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-mainline-coauthor-review-request-2026-06-28.md`
7. `/Users/wanglei/workspace/MAformac/docs/CURRENT.md`

Authority order:

live repo/config/receipt > validation stdout > visible file content > dated handoff > subagent prose.

## 4. Dispatch Self-Audit By Hermes

Before Step 1, arrange a Hermes audit of this dispatch file.

Audit scope:

- Is the six-step order truly serial?
- Does the dispatch prevent UIUE local proof from masquerading as mainline/runtime/mobile proof?
- Does it prevent `scope_origin=missing` from being self-locked by UIUE?
- Does every step have a Codex audit gate?
- Does the final R5 readiness verdict have honest proof-class limits?

Time limit: 20 minutes wall-clock maximum.

Output:

- Prompt: `/Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/hermes-dispatch-audit-prompt.md`
- Audit: `/Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/hermes-dispatch-audit.md`

If Hermes returns P0/P1, stop and fix interpretation or request commander decision before Step 1. If Hermes is unavailable or times out, write `HERMES_AUDIT_TIMEOUT_OR_UNAVAILABLE` with start/end timestamps and continue only after an additional Codex auditor confirms no obvious P0/P1 in this dispatch. Do not spend more than 20 minutes waiting for Hermes.

## 5. Per-Step Codex Audit Gate

After each Step N, launch an independent Codex subagent/auditor. The audit is not optional.

Auditor output path:

```text
/Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/audits/stepN-codex-audit.md
```

Every audit must include:

- `status`: `PASS_WITH_NOTES`, `PARTIAL`, or `BLOCKED`
- evidence table with file paths and line references
- validation commands reviewed
- touched paths
- confidence
- P0/P1/P2 findings
- residual risk

Do not proceed to the next step until:

- audit has no P0/P1, or
- P0/P1 are fixed and re-audited, or
- commander/user explicitly accepts a documented blocker/defer.

## 5.1 Max-Capability Pre-Mortem And Bug Iceberg Gate

Use maximum useful LLM capability for risk discovery, but keep it evidence-bound.

Before each Step N implementation/editing phase, write a step pre-mortem:

```text
/Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/premortems/stepN-premortem.md
```

Pre-mortem must include:

- assumed future failure
- likely causes
- local evidence to check first
- external/upstream issue search plan if the step touches unfamiliar SDKs, Xcode/XCTest behavior, OpenSpec behavior, SwiftPM quirks, simulator/XcodeBuildMCP behavior, or known tooling failure modes
- stop/defer conditions

External search is allowed and encouraged when useful. Prefer official docs, upstream issue trackers, release notes, and primary sources. Record query, source URL, retrieval date, and what changed in the plan. Do not use web results to override live repo truth.

After each Step N and after every surprising failure, failed fix, proof mismatch, fake affordance, status overclaim, or dirty provenance conflict, run `$bug-iceberg-teardown` using `/Users/wanglei/.codex/skills/bug-iceberg-teardown/SKILL.md` as the required method.

Bug iceberg output path:

```text
/Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/iceberg/stepN-bug-iceberg-teardown.md
```

Minimum sections:

- conclusion: tiger / paper-tiger / elephant
- visible symptom or risk
- evidence chain
- expected chain vs observed break
- same-class risk map
- project-system reflection
- immediate fix
- class-level fix
- governance fix
- next verification gates

The teardown must explicitly check the UIUE local defaults from the skill:

- `CLAUDE.md`, `docs/CURRENT.md`, active OpenSpec
- UIUE mock-frontstage vs runtime/backend readiness boundary
- proof_class boundary: simulator/mock/static preview must not become V/S/U-PASS
- `8.A` / `8.C2` status
- Swift tests / XCUITest / checker gate coverage

Experience and metacognitive harness logging is required. For every lesson that would prevent recurrence, update or create:

```text
/Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/lessons-learned.md
/Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/metacognitive-harness.md
```

The harness note must record:

- trigger pattern
- failed or risky assumption
- detection command or evidence source
- future guardrail
- which route board / OpenSpec / receipt should carry the rule if promoted

If a lesson should become durable project guidance, propose the exact target file and patch in the step receipt, but do not edit high-authority files unless the step scope allows it.

## 6. Step 1 — Mainline Co-Author Review

Goal: clear or precisely preserve R4 hard blockers C01/C03/C06/C18.

Work in `/Users/wanglei/workspace/MAformac` for this step. Read mainline `CLAUDE.md`, `docs/CURRENT.md`, relevant OpenSpec state, and the UIUE co-author request.

Must answer:

1. Does mainline accept UIUE `define-runtime-presentation-bridge` as the shared contract authority?
2. Should mainline copy, migrate, reference, or create a mainline proposal for the bridge?
3. If UIUE and mainline wording conflict, which artifact is SSOT?
4. Is a second same-meaning bridge forbidden?
5. How should `scope_origin=missing` be handled?
   - extend Core enum
   - presentation-only enum
   - remove `missing` and use existing origin plus explicit fail reason
   - defer to R5 with non-claim

Required output:

```text
/Users/wanglei/workspace/MAformac/docs/project/phase0/uiue-r4-mainline-coauthor-receipt-2026-06-28.md
```

If mainline files are edited, commit in mainline with exact pathspec only. Do not push. If mainline rejects or defers, that is acceptable only if the receipt is explicit and gives owner/trigger.

Step 1 validation:

```bash
cd /Users/wanglei/workspace/MAformac
openspec validate --all --strict
git diff --check
git status --short
```

Step 1 done criteria:

- A mainline-scoped receipt exists.
- C01/C03/C06/C18 are no longer ambiguous; each is accepted, rejected, or deferred with owner/trigger.
- No UIUE-only document is used as proof of mainline acceptance.

Then run Step 1 Codex audit.

## 7. Step 2 — UIUE R4 Local Proof Slice

Goal: thicken local proof for R4 test/evidence/visual policy rows without touching runtime or mainline.

Work in `/Users/wanglei/workspace/MAformac-uiue`.

Candidate scope:

- bridge fixture examples
- `PresentationSnapshot` mock consumer proof
- proof_class cap checks
- terminal snapshot negative fixtures: timeout, cancel, runtime_error, unsupported, safety, partial
- C50 classification gate script/check
- visual policy zone ownership table
- a11y / hit-testing / reduce-motion evidence receipt

Do not:

- clear C01/C03/C06/C18 locally
- edit mainline
- implement runtime adapter
- claim mobile/true_device/runtime/voice/model/golden readiness

Required output:

```text
/Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-exit-preconditions-20260628/step2-local-proof-receipt.md
```

If code/tests/fixtures are changed, commit in UIUE with exact pathspec. Do not push.

Step 2 validation minimum:

```bash
cd /Users/wanglei/workspace/MAformac-uiue
openspec validate ui-presentation --strict
git diff --check
swift test
```

Run targeted iOS UI tests if touched UI harness requires it. If not run, record exact reason.

Then run Step 2 Codex audit.

## 8. Step 3 — R1-R3 Residual Disposition

Goal: prevent R1-R3 debt from leaking into R5 as ambiguous blocker.

Work in UIUE repo. Produce a disposition table for every R1-R3 residual named in:

- `docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md`
- `docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md`

Required statuses:

- `resolved_with_proof`
- `accepted_with_notes`
- `deferred_with_owner`
- `not_R5_blocker`
- `still_blocks_R5`

Minimum residuals to classify:

- runtime-driven orb binding
- complex reasoning -> think
- long-press 1.5s deductive console
- 44pt / VoiceOver
- full 10-family interaction matrix
- summary direct-control / gear direct touch
- capsule final-art
- white-edge formal threshold
- Reduce Motion true-device/system-setting proof

Required output:

```text
/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r1-r3-residual-disposition-before-r5-2026-06-28.md
```

Commit exact path if changed. Do not relabel `WARN` as `PASS`; do not turn simulator_debug_override into true-device proof. If a residual requires L3/human review, mark it `pending_human_review` with owner `磊哥`, decision needed, and recommended options; do not block Step 3 solely because human review is pending.

Then run Step 3 Codex audit.

## 9. Step 4 — Update R4 Ledger

Goal: update R4 ledger from preimplementation state to current exit-precondition state.

Work in UIUE repo.

Update or create:

```text
/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-exit-burndown-2026-06-28.md
```

Do not overwrite the historical R4 burndown ledger unless the edit is clearly an addendum with provenance. Prefer a new exit ledger if the status transitions are substantial.

Required content:

- C01-C50 final/pre-closeout status
- explicit status for C01/C03/C06/C18 based on Step 1 mainline receipt
- proof paths for Step 2 local proof
- residual disposition references from Step 3
- R5 deferred rows with owner/trigger/non-claim
- `pending_human_review` rows with decision owner, review question, options, and whether R5 is blocked before decision
- no fake proof-class upgrades

Mechanical checks:

- C01-C50 count exactly 50
- every row has owner, status, proof path or defer reason
- no blocked row is silently omitted

Then run Step 4 Codex audit.

## 10. Step 5 — R4 Closeout Receipt

Goal: write the R4 closeout receipt only after Steps 1-4 and their audits are complete.

Required output:

```text
/Users/wanglei/workspace/MAformac-uiue/Reports/uiue-r4-closeout-20260628/closeout.md
```

The closeout must include:

- conclusion: `DONE`, `PARTIAL`, or `BLOCKED`
- exact UIUE branch/HEAD/status
- exact mainline branch/HEAD/status
- commit hash(es) created in UIUE and/or mainline
- C01-C50 status summary
- Step 1 mainline co-author receipt path
- Step 2 local proof receipt path
- Step 3 residual disposition path
- Step 4 exit ledger path
- validation commands and results
- proof class
- non-claims
- residual risks
- R5 readiness verdict
- human review pending summary, if any

R4 closeout may be `DONE` only if no R4 exit blocker remains except explicitly parked `pending_human_review` items that are documented as not required before R5. If C01/C03/C06/C18 remain deferred/rejected in a way that blocks R5, closeout must be `PARTIAL` or `BLOCKED`. If only L3/human review items remain, write `PARTIAL / PENDING_HUMAN_REVIEW` unless the Step 6 verdict justifies `R5_PRECONDITIONS_READY_WITH_HUMAN_REVIEW_NOTES`.

Then run Step 5 Codex audit.

## 11. Step 6 — R5 Precondition Verdict And R5 Lane Readiness

Goal: decide whether R5 can start, and if yes, define the first R5 lanes without doing R5 work.

Required output:

```text
/Users/wanglei/workspace/MAformac-uiue/docs/handoffs/2026-06-28-uiue-r5-readiness-from-r4-closeout.md
```

Also produce the final human review checklist:

```text
/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r4-human-review-checklist-before-r5-2026-06-28.md
```

Checklist fields:

- item id
- source path
- why human/L3 review is needed
- available evidence
- decision options
- recommended default
- effect if accepted
- effect if rejected/deferred
- whether it blocks R5
- non-claims to preserve

Verdict options:

- `R5_PRECONDITIONS_READY`
- `R5_PRECONDITIONS_READY_WITH_HUMAN_REVIEW_NOTES`
- `R5_PRECONDITIONS_PARTIAL`
- `R5_PRECONDITIONS_BLOCKED`

If ready, list allowed R5 lanes only as dispatch candidates:

- runtime-driven orb binding
- complex reasoning -> think
- long-press 1.5s deductive console
- voice lane
- model/golden lane
- true-device/mobile/a11y lane

Do not implement these lanes in this dispatch.

Then run Step 6 Codex audit. Only after Step 6 audit passes may goal mode be marked complete.

## 12. Validation Gates Summary

At minimum, before final response:

```bash
cd /Users/wanglei/workspace/MAformac-uiue
git status --short
openspec validate ui-presentation --strict
git diff --check
swift test
rg -n "^- \\[[ x]\\] 8\\.(A|C2)" openspec/changes/ui-presentation/tasks.md

cd /Users/wanglei/workspace/MAformac
git status --short
openspec validate --all --strict
git diff --check
```

If any validation is not run, record why and downgrade status as needed.

## 13. Git Discipline

- Do not use `git add .`.
- Use exact pathspec only.
- Do not push.
- Do not reset, checkout, or revert unrelated user/agent work.
- If both repos are edited, keep UIUE and mainline commits separate.
- Every commit must have validation evidence in the relevant step receipt.
- Final response must list commit hashes and final `git status --short` for both repos.

## 14. Final Response Contract

Return in Chinese:

- `status`: `DONE / R4_EXIT_PRECONDITIONS_CLOSED`, `PARTIAL`, or `BLOCKED`
- goal status
- UIUE repo/branch/start HEAD/final HEAD/final status
- mainline repo/branch/start HEAD/final HEAD/final status
- Hermes dispatch audit result and path
- Step 1-6 output paths
- final human review checklist path
- Step 1-6 Codex audit paths and verdicts
- commits created
- validation commands and results
- proof class
- non-claims
- residual risks
- whether R5 can start

Do not claim R4 closeout or R5 readiness unless the closeout receipt and Step 6 audit justify it.

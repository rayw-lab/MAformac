# 2026-07-06 C5 Training Runtime Commander Handoff

## Artifact Kind

`project_handoff_candidate`

Output path: `/Users/wanglei/workspace/MAformac/docs/handoffs/2026-07-06-c5-training-runtime-commander-handoff.md`

Created: `2026-07-06T15:27:55+0800`

This is a handoff and pause record, not an OpenSpec contract, not a V-PASS receipt, and not a release/merge authorization.

## Current Truth

- Cwd/repo: `/Users/wanglei/workspace/MAformac`
- Branch: `codex/rebuild-c6-doc-absorption-20260624`
- Git state at handoff: ahead `122`, behind `7`, dirty tree.
- New code touched in this commander run:
  - `Core/Routing/ToolCallFrame.swift`
  - `Tests/MAformacCoreTests/C3DecodeCompletionMetaTests.swift`
  - `Core/Execution/RuntimeAdapterMountReceipt.swift`
  - `Tests/MAformacCoreTests/RuntimeAdapterMountReceiptTests.swift`
- Other modified/untracked files already exist across docs/OpenSpec/training/runs; do not treat the tree as clean.
- Newest user request: wait for current workers to finish, then pause all work and write a mainline handoff. Include the goal plan implementation files, commander duties/details/experience, and the fact that five workers are flexible agent slots, not fixed roles.
- Nearest authority read in this turn:
  - `CLAUDE.md`
  - `docs/CURRENT.md`
  - `docs/README.md`
  - `AGENTS.md` content provided by user
  - `~/.codex/skills/smux/SKILL.md`
  - `~/.codex/skills/handoff/SKILL.md`

## Stop State

All worker dispatch is paused after this handoff. Do not continue W20A/W21/W22/W23, do not push, do not commit, do not dirty-clean, and do not run more training/eval until 磊哥 explicitly resumes.

Current hard project state remains:

- `C5 training V-PASS`: not achieved / falsified by current T1 evidence.
- `candidate_status`: unsigned.
- `data-patch`: blocked unless explicit commander override after runtime path evidence.
- `github push / merge`: blocked; dirty cleanup and file cascade are final-stage tasks, not current.

## Commander Role Notes

The commander pane is orchestration-only. It should not become the coding worker by default.

Commander responsibilities:

- Verify repo truth, branch, dirty status, pane topology, nearest authority, and receipt files before acting.
- Translate user intent into bounded worker prompts with goal, non-goals, scope, writable paths, no-touch paths, validation gates, proof class, stop conditions, output file, and ack protocol.
- Treat run-dir output files as ground truth. Pane prose/ack is only notification.
- Use `tmux-bridge list` and `tmux-bridge read` before every dispatch. Labels are convenience, not identity.
- Use `tmux-bridge message/read/keys Enter` or `type/read/keys Enter` correctly; if pasted content is visible but not submitted, send Enter once after read verification.
- Merge worker outputs by evidence priority: live repo/config/receipt > validator stdout > visible pane > dated report > worker prose.
- Preserve proof-class boundaries. Local/unit/runtime/smoke cannot become C5 V-PASS, candidate, C6 acceptance, UIUE/voice readiness, mobile/true-device/live proof, or push readiness.
- Stop or replan on GitNexus HIGH/CRITICAL, as W19 did on `DemoRuntimeAdapter`.
- Route all lifecycle work through workers when useful: brainstorm, grill, design, coding, tests, audits, docs cascade, dirty cleanup, CI/CD, and release prep.
- Major decisions should use grill/reduction plus adversarial audit. Do not finalize commander-only essays.

Worker model/agent guidance:

- The five worker panes are flexible execution slots, not permanent roles.
- A worker can be Codex, Claude Code, Opus, Hermes, or another agent. Future runs may use multiple Opus or Hermes workers.
- Assign by current task fit and pane availability, not historical label. Reconfirm pane id, label, cwd, and visible state before dispatch.
- Do not worry about worker context length as a scheduling blocker; workers auto-compact like the commander. Receipts and files are the durable memory.

## Done

### C5 Training Evaluation Truth

- Tail training helped but did not pass:
  - tail1200 iter600 = true-query `10/10`, action-question `14/18`.
  - old600/old1200/tail300 were worse; tail300 was `0/10` true-query and `0/18` action.
- Current failure is real behavior failure, not a mount/parser artifact.
- Root cause from W15: train/eval input-face mismatch. Trainpack is structured `device=X; primitive=Y`; natural Chinese `能不能...` action-question register is absent.

### Prompt Packet Gate

- W15 wrote W17-W23 dispatch prompt packet v1.
- W16 audited v1 as `FINDINGS` with P1/P2 corrections.
- W15 wrote v2 absorbing P1/P2.
- W16 re-audited v2 as `PASS`, first batch only: W17/W18/W19.

### W17 Runtime Baseline Diagnostic

- W17 result: `DIAGNOSTIC_ONLY`.
- Existing runtime routes T1 action-question `0/18`.
- `FastPathIntentEngine` only recognizes literal `打开空调`; `DemoRuntimeSessionRunner.run` has no model slow path/router/LLMBackend call.
- This corrected the old assumption: class-A failures were not simply adapter-only bypassing a working L1 layer. W20 is near-greenfield runtime work, not a small L1 patch.
- Checkpoint selection is closed: iter300 is worse than iter600.

### W18 Tool Name Guard

- W18 implemented exact fail-closed tool-name allowlist support in `ToolCallFrame`.
- Targeted test `swift test --filter C3DecodeCompletionMetaTests` passed.
- `make verify` passed.
- Full `swift test` still fails because `Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json` is missing; this is outside W18 scope.
- W12 audited W18 and returned `FINDINGS`, `implementation_acceptance=no`.

### W19 / W19B Mount Receipt

- Original W19 direct `DemoRuntimeAdapter` hook stopped correctly: GitNexus impact on `DemoRuntimeAdapter` was CRITICAL (`111` impacted, `75` direct).
- W11 replanned W19B as schema/builder-only, avoiding `DemoRuntimeAdapter`.
- W12 audited W19B plan as `PASS`, implementation-ready with constraints.
- W19B implemented greenfield `RuntimeAdapterMountReceipt` schema/builder and focused tests.
- `swift test --filter RuntimeAdapterMountReceiptTests` passed.
- Full `swift test` still fails on the same missing runtime presentation fixture.
- W19B is schema/builder-only. It is not wired into runtime and does not emit a runtime mount receipt.

### W20 Replan

- W15 rewrote W20 sequencing after W17:
  - W20A: new `DemoNLURouter`, low-blast via existing `DemoRuntimeSessionRunner(frameDecoder:)` injection seam, dispatch-ready.
  - W20B: model slow path + normalizer, deferred behind W20A and separate GitNexus gate.
  - W21: runtime eval CLI consumes W20A + W18 + W19B, not ready until prerequisites land.
- Data patch remains blocked by hard gate 6.

## Partial / Not Done

- W18 is not accepted yet. W12 found:
  - P1: `decodeNonStreamingCompletion(_:)` bypasses the new `allowedToolNames` guard.
  - P2: top-level `name` parsing lacks coverage for unrelated legacy `name` fields.
- W19B is implemented but not independently code-audited after implementation.
- W20A is only planned/replanned; no code has been written for it.
- W21 runtime eval CLI not implemented.
- W22 data patch not authorized and not run.
- W23 final adversarial audit not run.
- No docs cascade beyond this handoff.
- No dirty cleanup, commit, push, PR, merge, CI closeout, candidate signing, C5 V-PASS, C6 acceptance, UIUE/voice readiness.

## Key Evidence Index

Run root:

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-training-vpass/`

Goal/plan implementation files to index:

- `/Users/wanglei/workspace/MAformac/docs/project/phase0/c5-closeout-commander-plan-2026-07-06.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-training-vpass/w15-w17-w23-dispatch-prompts-v2.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-training-vpass/w16-w17-w23-dispatch-prompts-v2-audit.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-training-vpass/w15-w20-greenfield-runtime-replan.md`

C5 training / eval truth:

- `w14-c5-training-vpass-eval-runner.md`
- `w14-checkpoint-comparison-execution.md`
- `w15-t1-action-question-rootcause-grill.md`
- `w16-c5-training-1800-checkpoint-eval-matrix.md`

Runtime remediation design/audits:

- `w11-runtime-path-remediation-grill.md`
- `w14-data-patch-retrain-remediation-grill.md`
- `w16-restricted-decoding-toolname-grill.md`
- `w12-remediation-grill-reduction-audit.md`
- `w15-runtime-implementation-battle-plan.md`
- `w11-remediation-plan-adversarial-audit.md`
- `w16-remediation-plan-adversarial-audit.md`

First-batch execution receipts:

- `w17-runtime-baseline-diagnostic.md`
- `w18-toolname-guard.md`
- `w12-w18-toolname-guard-audit.md`
- `w19-mount-receipt.md`
- `w11-w19-lower-blast-replan.md`
- `w12-w19b-replan-audit.md`
- `w19b-lower-blast-mount-receipt-implementation.md`

Current code artifacts from this run:

- `/Users/wanglei/workspace/MAformac/Core/Routing/ToolCallFrame.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/C3DecodeCompletionMetaTests.swift`
- `/Users/wanglei/workspace/MAformac/Core/Execution/RuntimeAdapterMountReceipt.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/RuntimeAdapterMountReceiptTests.swift`

## Failed Attempts / Traps

- Do not say “1800/tail600 V-PASS”. It is train-health/behavior evidence only and action-question still fails `14/18`.
- Do not call tail training useless. It improved tail300 `0/18` to tail600 `14/18`, but still misses hard gate.
- Do not retry checkpoint selection as a likely win. W14/W17 closed it; iter300 is worse.
- Do not claim current runtime path exists. Existing runtime is `0/18` on T1 and has no model slow path.
- Do not resurrect old W19 direct adapter hook unless commander explicitly accepts GitNexus CRITICAL on `DemoRuntimeAdapter`.
- Do not treat W18 guard-only as T1 recovery. It only fails closed on hallucinated tool names; `screen-001` still fails unless exact `switch_screen_content` is emitted.
- Do not dispatch old v2 W20 prompt unmodified. W17 superseded its assumptions.
- Do not use `git add .`. The tree is mixed dirty and divergent.
- Do not trust `detect_changes(compare, base_ref=main)` as a clean per-lane signal on this branch; it is noisy because of pre-existing broad diffs.
- Do not treat full `swift test` failure as W18/W19B-specific without checking the missing fixture issue.

## Next Action Before Editing

Do not edit until 磊哥 resumes work.

On resume, first run:

```bash
git status --short --branch
tmux-bridge list
ls -lt /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-training-vpass | sed -n '1,60p'
```

Then read, in order:

1. This handoff.
2. `w12-w18-toolname-guard-audit.md`
3. `w19b-lower-blast-mount-receipt-implementation.md`
4. `w15-w20-greenfield-runtime-replan.md`

Recommended next engineering order after resume:

1. Fix W18 P1/P2 or dispatch a worker to do so.
2. Independently audit W19B implementation.
3. Only then consider W20A `DemoNLURouter` implementation.
4. W21 runtime eval CLI waits for W20A + accepted W18 + audited W19B.
5. W23 adversarial audit waits for W17-W22 receipts.

## Suggested Skills

- `smux`: tmux-bridge dispatch and pane coordination.
- `handoff`: maintain project-handoff discipline.
- `code-review` / `audit`: review W18 fix and W19B implementation.
- `receiving-code-review`: absorb W12 W18 findings without over-expanding scope.
- `gitnexus-impact-analysis`: required before editing existing symbols.
- `executing-plans`: only after a new commander dispatch explicitly resumes work.

## Redaction Check

No secrets, tokens, PII, pricing, raw customer utterance files, or internal-only source material were copied into this handoff. It references local paths and summarized receipt results only.

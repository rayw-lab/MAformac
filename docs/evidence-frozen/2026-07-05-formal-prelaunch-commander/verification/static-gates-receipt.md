# Static Gates Receipt - W-B Codex verifier

status: `PASS_STATIC_GATES`
captured_at_utc: `2026-07-05T11:41:14Z`
repo: `/Users/wanglei/workspace/MAformac`
run_dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-prelaunch-commander`
proof_class: `local_static`

## Evidence table

| Gate | Result | Evidence |
| --- | --- | --- |
| cwd / branch / HEAD / upstream | PASS | `pwd` -> `/Users/wanglei/workspace/MAformac`; branch `codex/rebuild-c6-doc-absorption-20260624`; HEAD `6a4b6b827257acaf8195b40a5ea67469448aec94`; upstream `origin/codex/rebuild-c6-doc-absorption-20260624` at `02f0722f1843a69d7cf82b2144f289e9e717c309`; branch `ahead 122, behind 7`. |
| dirty status | PASS_WITH_DIRTY_SPLIT | Dirty tree exists before this verifier. Modified: `Core/Training/C5LoRATraining.swift`, `Tests/MAformacCoreTests/C5LoRATrainingTests.swift`, `docs/CURRENT.md`, `docs/baseline-roadmap-2026-07-05-c5-d106.md`, `docs/commander-log/COMMANDER-INDEX.md`, `docs/superpowers/plans/2026-07-04-c5-formal-training-today.md`; plus untracked paths listed below. No repo file was modified by this verifier. |
| `make verify-c5-phase1-gates` | PASS | rc0; `test_query_zero_tolerance=ok`; `test_eval_mount_validity=ok`; `test_label_authority_conflicts=ok`. |
| true manifest label authority checker | PASS | `python3 scripts/check_label_authority_conflicts.py --manifest docs/c5-training-readiness-grill/r5-phase1-authority-manifest-2026-07-05.json --fail-on-conflict` rc0; `row_count=17166`; `conflict_input_count=0`; `source_authority_error_count=0`; `status=pass`; `unique_input_count=5382`. |
| frozen trainpack identity | PASS | `wc -l` -> `5653`; `shasum -a 256` -> `fa5690400f67db9ef237dabdb489f58d1ab69961f14d6733d79f9bd7cad33823` for `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r3-trainpack/c5-training-samples.jsonl`. |
| LR 450 fixture verifier | PASS | `python3 /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/tools/verify_formal_lr_schedule.py .../lr-schedule-formal-450-fixture.metrics.jsonl` rc0; `status=FORMAL_450_MATCH`; formal `matches=8`, `mismatches=0`; stale `mismatches=7`. |
| process probe | PASS_NO_FORMAL_TRAINING_PROCESS | `ps -axo pid,ppid,stat,command ...` after gates showed only `359 1 Ss /usr/libexec/watchdogd`. This is macOS system watchdogd, not project formal/MLX training watchdog. No `mlx`, `mlx_lm`, formal trainer, LoRA trainer, or `C5LoRATraining` process found. |
| Launch Packet six files | PASS_STATIC_PACKET_PRESENT | Directory `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/eval/launchpacket-frozen` contains `FORMAL-LAUNCH-CONDITIONS.md`, `formal-config.diff`, `formal-host-baseline.json`, `formal-watchdog-contract.md`, `formal-eval-manifest.json`, `formal-receipt-template.md`; also `FREEZE-REPORT.md`, LR fixture, and LR verifier output. |
| host baseline / watchdog realtime status | PASS_STATIC_REALTIME_PLACEHOLDERS | `formal-host-baseline.json` status is `FROZEN_TEMPLATE_REALTIME_AT_LAUNCH_NOT_SAMPLED`; `formal-watchdog-contract.md` status is `FROZEN_CONTRACT_REALTIME_AT_LAUNCH_NOT_ARMED`; `FORMAL-LAUNCH-CONDITIONS.md` marks host baseline and watchdog as `<REALTIME_AT_LAUNCH>`. |

## Commands run

```bash
pwd
git status --short --branch
git status --short
git rev-parse HEAD
git rev-parse --abbrev-ref HEAD
git rev-parse --abbrev-ref --symbolic-full-name @{u}
git rev-parse @{u}
sed -n '1,260p' CLAUDE.md
sed -n '1,220p' docs/CURRENT.md
sed -n '1,220p' docs/README.md
sed -n '1,220p' docs/baseline-roadmap-2026-07-05-c5-d106.md
sed -n '1,220p' /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/STATUS-BOARD.md
sed -n '1,220p' /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/eval/launchpacket-frozen/FREEZE-REPORT.md
sed -n '1,220p' /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/eval/launchpacket-frozen/FORMAL-LAUNCH-CONDITIONS.md
sed -n '1,220p' /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/eval/launchpacket-frozen/formal-host-baseline.json
sed -n '1,220p' /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/eval/launchpacket-frozen/formal-watchdog-contract.md
make verify-c5-phase1-gates
python3 scripts/check_label_authority_conflicts.py --manifest docs/c5-training-readiness-grill/r5-phase1-authority-manifest-2026-07-05.json --fail-on-conflict
wc -l /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r3-trainpack/c5-training-samples.jsonl
shasum -a 256 /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r3-trainpack/c5-training-samples.jsonl
python3 /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/tools/verify_formal_lr_schedule.py /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/eval/launchpacket-frozen/lr-schedule-formal-450-fixture.metrics.jsonl
ls -la /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/eval/launchpacket-frozen
ps -axo pid,ppid,stat,command | awk 'BEGIN{IGNORECASE=1} /mlx|lora|formal|train|C5LoRATraining|mlx_lm|watchdog/ && $0 !~ /awk/ && $0 !~ /ps -axo/ {print}'
```

Non-load-bearing correction: I first probed `python3 scripts/check_label_authority_conflicts.py --manifest generated/c6-bench-manifest.json --fail-on-conflict`; it returned rc65 `manifest_error: missing manifest`. That was a wrong guessed path, superseded by the rc0 true manifest command above.

## Pass / fail

`PASS_STATIC_GATES`.

No static gate failure found. No `BLOCKED_STATIC_GATE` blocker.

## Dirty split

Existing dirty repo state at verification time:

```text
 M Core/Training/C5LoRATraining.swift
 M Tests/MAformacCoreTests/C5LoRATrainingTests.swift
 M docs/CURRENT.md
 M docs/baseline-roadmap-2026-07-05-c5-d106.md
 M docs/commander-log/COMMANDER-INDEX.md
 M docs/superpowers/plans/2026-07-04-c5-formal-training-today.md
?? .xcodebuildmcp/
?? Tools/agent-platform-plugin-refs/
?? XSWAP-23-fix.md
?? docs/c5-training-readiness-grill/f044-r3-grill-2026-07-04.md
?? docs/c5-training-readiness-grill/f044-r5-grill-2026-07-05.md
?? docs/handoffs/2026-07-05-phase1-clean-formal-ready.md
?? docs/handoffs/2026-07-05-r3-overnight-morning-brief.md
?? docs/superpowers/plans/2026-07-05-uiue-merge-battle-plan.md
?? runs/
```

Verifier-owned write: this receipt only, outside repo:
`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-prelaunch-commander/verification/static-gates-receipt.md`.

## Proof class

`local_static`.

This is command/file/process evidence on the local machine. It is not runtime training evidence, not mobile/true-device proof, and not live API proof.

## Non-claims

- Not formal run authorization.
- Not formal training started.
- Not formal training completed.
- Not LoRA candidate signoff.
- Not C6 acceptance.
- Not V-PASS.
- Not UIUE merge approval.
- Not `adapter_learned_qa=true`.
- Not host readiness: host baseline remains `<REALTIME_AT_LAUNCH>`.
- Not watchdog armed: watchdog remains `<REALTIME_AT_LAUNCH>`.

## Residual risk

- Branch is behind upstream by 7 commits and ahead by 122; this receipt verifies the current live worktree state only.
- Repo has pre-existing dirty files, including `Core/Training` and tests. Static frozen trainpack identity is clean, but any regeneration before launch must rerun gates.
- Host baseline and watchdog are intentionally realtime launch gates, not satisfied by this static receipt.
- Process probe is point-in-time only.

## Next minimal action

Wait for explicit `run-auth`; at launch, capture fresh host baseline, arm watchdog against the real trainer pid, rerun first real LR check against actual `metrics.jsonl` or `train.log`, then start formal only if realtime gates pass.

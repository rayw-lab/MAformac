# Launch Packet Freeze Report

status: `FROZEN_STATIC_PACKET_DONE`
authority: `SPEC-freeze-launchpacket.md`
phase1_commit: `6a4b6b827257acaf8195b40a5ea67469448aec94`
recipe: `R3-QNEG-clean`
proof_class: `local_static_docs_config`

## Frozen Data Identity

| field | value |
| --- | --- |
| trainpack path | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/r3-trainpack/c5-training-samples.jsonl` |
| row count | `5653` |
| sha256 | `fa5690400f67db9ef237dabdb489f58d1ab69961f14d6733d79f9bd7cad33823` |
| recipe | `R3-QNEG-clean` |

## Six Packet Files

| file | freeze status | filled true values | still realtime |
| --- | --- | --- | --- |
| `FORMAL-LAUNCH-CONDITIONS.md` | `FROZEN_STATIC_PACKET` | Phase1 commit, B semantics, recipe, row count, sha | host baseline, watchdog armed proof |
| `formal-config.diff` | `FROZEN_STATIC_PACKET` | trainpack path, row count, sha, MLX data dir, rank16, iters1800, updates450, warmup36 | first formal runtime LR check |
| `formal-eval-manifest.json` | `FROZEN_STATIC_PACKET` | data binding, scanner exit67, mount-validity exit66, B qa semantics | post-run adapter/result shas |
| `formal-receipt-template.md` | `FROZEN_STATIC_TEMPLATE` | proof-class split, `adapter_learned_qa=false`, `adapter_qa_gate=fail_accepted_under_B`, `candidate_status=unsigned` | filled formal run/eval receipt |
| `formal-watchdog-contract.md` | `FROZEN_CONTRACT_REALTIME_AT_LAUNCH_NOT_ARMED` | day/night/unattended contract and thresholds | `<REALTIME_AT_LAUNCH>` real pid, script/config sha, heartbeat, armed proof |
| `formal-host-baseline.json` | `FROZEN_TEMPLATE_REALTIME_AT_LAUNCH_NOT_SAMPLED` | D-094/D-102 fail-closed thresholds and command template | `<REALTIME_AT_LAUNCH>` fresh host snapshot |

## LR Schedule Verification

Command:

```bash
python3 /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/tools/verify_formal_lr_schedule.py \
  /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates/eval/launchpacket-frozen/lr-schedule-formal-450-fixture.metrics.jsonl
```

Result: `rc=0`, status `FORMAL_450_MATCH`, formal matches `8`, formal mismatches `0`, stale mismatches `7`.

Output artifact: `lr-schedule-verify-output.json`

Note: this is a static 450-schedule fixture check for packet freeze. The formal
run still must run the same verifier against the first real `metrics.jsonl` or
`train.log` after launch.

## Stopline Confirmation

- No build was run.
- No training was started.
- No watchdog was armed.
- No host baseline was sampled.
- No commit was made.
- No `Core/Training` file was touched by this freeze task.

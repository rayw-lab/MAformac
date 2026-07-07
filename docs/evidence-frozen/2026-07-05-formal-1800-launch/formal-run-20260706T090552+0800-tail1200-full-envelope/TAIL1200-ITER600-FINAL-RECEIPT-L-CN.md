---
status: TAIL1200_ITER600_FINAL_ARTIFACT_PASS
artifact_kind: runtime_local_training_artifact_receipt
created_at: 2026-07-06T13:40:00+08:00
run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/formal-run-20260706T090552+0800-tail1200-full-envelope
proof_class: runtime/local training artifact only
trainer_pid_checked: 42505
trainer_live: false
final_iteration: 600
final_update_step: 150
final_val_loss: 0.01540403999388218
final_train_loss: 0.009280303120613098
final_adapter_sha256: 9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6
candidate_status: unsigned
adapter_learned_qa: false
---

# TAIL1200 ITER600 FINAL RECEIPT L-CN

## Conclusion

`TAIL1200_ITER600_FINAL_ARTIFACT_PASS`.

The tail1200 run reached iter600 final telemetry, wrote the rolling and `0000600` final adapter files, and trainer pid `42505` is no longer live at the sampled process check.

This is **runtime/local training artifact only**. It is not a LoRA candidate, not adapter QA learning, not runtime QA safety, not C6 acceptance, not UIUE/voice readiness, and not V-PASS.

## Separated Lifecycle Results

| Lane | Result | Evidence |
| --- | --- | --- |
| Old formal 1800 `20260705T234208` | `HOLD/PARTIAL` | `FORMAL-TRAIN-RECEIPT.md:1-9` records `FORMAL_TRAIN_HOLD_TRAINER_RC_143`, `trainer_rc=143`, `candidate_status=unsigned`, `adapter_learned_qa=false`. |
| Old formal final state | no iter1800 final / no checkpoint1800 | Old `metrics.jsonl` tail stops at `iteration=1692` / `update_step=423`; old `train.log` tail stops at `Iter 1690`; `find ... -name '*1800*'` returned no checkpoint path. |
| Tail1200 `20260706T090552` | `ITER600_FINAL_ARTIFACT_PASS` | `metrics.jsonl:217`, `metrics.jsonl:220`, `train.log:78-81`, adapter sha command below. |

## Tail1200 Final Metrics

| Metric | Value | Evidence |
| --- | ---: | --- |
| final iteration | `600` | `metrics.jsonl:217`, `metrics.jsonl:220` |
| final update_step | `150` | `metrics.jsonl:219` |
| final val_loss | `0.01540403999388218` | `metrics.jsonl:217` |
| final val_time | `63.39084787500906` | `metrics.jsonl:217` |
| final train_loss | `0.009280303120613098` | `metrics.jsonl:220` |
| learning_rate | `1.000367228698451e-05` | `metrics.jsonl:220` |
| peak_memory | `17.974144464` | `metrics.jsonl:220` |
| trained_tokens | `26190` | `metrics.jsonl:220` |
| final adapter sha256 | `9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6` | `shasum -a 256 ...` |

## Saved Artifacts

| Path | Status |
| --- | --- |
| `adapters-rank16/adapters.safetensors` | saved final rolling adapter, size `69772950`, sha256 `9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6` |
| `adapters-rank16/0000600_adapters.safetensors` | saved final iter600 adapter, size `69772950`, sha256 `9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6` |
| `adapters-rank16/0000300_adapters.safetensors` | intermediate checkpoint retained, size `69772950` |
| `adapters-rank16/adapter_config.json` | adapter config retained |

`train.log:80-81` confirms both iter600 checkpoint save and final rolling save.

## Validation Commands

### `tail -n 12 metrics.jsonl`

Key final lines:

```text
{"event": "val", "iteration": 600, "val_loss": 0.01540403999388218, "val_time": 63.39084787500906}
{"event": "optimizer_update", "iteration": 600, "learning_rate": 1.0014692634285893e-05, "loss": 0.0018939394503831863, "update_step": 150, ...}
{"event": "train_report", "iteration": 600, "iterations_per_second": 0.059455537182046395, "learning_rate": 1.000367228698451e-05, "peak_memory": 17.974144464, "tokens_per_second": 1.9679782807257356, "train_loss": 0.009280303120613098, "trained_tokens": 26190}
```

### `tail -n 30 train.log`

Key final lines:

```text
Iter 600: Val loss 0.015, Val took 63.391s
Iter 600: Train loss 0.009, Learning Rate 1.000e-05, It/sec 0.059, Tokens/sec 1.968, Trained Tokens 26190, Peak mem 17.974 GB, Grad Norm Preclip 0.292088
Iter 600: Saved adapter weights to .../adapters-rank16/adapters.safetensors and .../adapters-rank16/0000600_adapters.safetensors.
Saved final weights to .../adapters-rank16/adapters.safetensors.
```

### `shasum -a 256 adapters-rank16/adapters.safetensors adapters-rank16/0000600_adapters.safetensors`

```text
9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6  adapters-rank16/adapters.safetensors
9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6  adapters-rank16/0000600_adapters.safetensors
```

### `ps -p 42505 -o pid=,stat=,command= || true`

Result: stdout was empty. Interpreted as sampled trainer pid `42505` not live at receipt time.

## Non-Claims

- no `lora_candidate`
- no `adapter_learned_qa=true`
- no runtime QA safety pass
- no C6 acceptance
- no UIUE readiness
- no voice readiness
- no V-PASS
- no true resume claim
- no old formal 1800 completion claim
- no mobile/true-device/live-api acceptance

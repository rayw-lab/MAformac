# C5 smoke receipt

status: t_pass_runtime_smoke_with_instability
acceptance_stage: train_health
model_quality_vpass: false
endpoint_candidate_vpass: false

- exit_code: 0
- no_nan_or_inf: True
- no_oom_or_abort: true
- loss_trend: early_spike_then_stabilized
- train_loss: 5.711 -> 4.713
- val_loss: 4.473 -> 4.68
- peak_mem_gb: 12.28
- trained_tokens: 193028
- adapter_sha256: 8a77b00b5c41ebf02dd6cacf0b71eba06960d98f0ae33a9f687d4c923bb6be06

## Failure receipt
- formal_step2_not_complete_q13_q14_q15
- smoke_adapter_not_candidate
- lr_schedule_not_effective_in_r9_constant_2e-4

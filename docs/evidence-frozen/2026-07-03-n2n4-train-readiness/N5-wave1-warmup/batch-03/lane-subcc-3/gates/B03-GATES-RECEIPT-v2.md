# B03-GATES-RECEIPT-v2

status: mechanical_gates_pass_local
proof_class: local/pre_training_mechanical_gates
basis_id: `968147c02601a3d42f8f15c9605f6a891695b7203e2b2c7629a2bb54e58bb07c`
batch_id: `warmup-batch-03`
lane_dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3`
repo_head: `266783468ac38542574ea4787bec650d16ba6b02`

## Verdict

PASS: controller injection, DataGate, diversity, and C6 leakage gates all passed locally.

## Steps

| step | status | exit | duration_sec | note |
|---|---|---:|---:|---|
| preflight | `pass` |  |  | required inputs present |
| inject_tool_py_compile | `pass` | 0 | 0.02 |  |
| controller_row_sha_injection | `pass` | 0 | 0.118 |  |
| controller_closure_verify | `pass` |  |  | rows=50 row_sha=50/50 ledger=50/50 |
| datagate | `pass` | 0 | 0.739 | status=data_gate_ready |
| diversity | `pass` | 0 | 0.033 | status=PASS |
| c6_leakage_probe | `pass` | 0 | 0.029 | status=pass |

## Gate Outputs

- datagate_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3/gates/datagate-v2/c5-data-gate-receipt.json` sha256=`33d06a3e553a1cf03557ed1234a565e8c81b97b5e426c0aa09e4bb63030bb2c7`
- datagate_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3/gates/datagate-v2/c5-data-gate-receipt.md` sha256=`9173eef3ce8e06c29b791f6b3891f227a0d13e95b3507c5fe88a1ab7cd1a3df4`
- diversity_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3/gates/diversity-v2/diversity-report.json` sha256=`f9842b14b183e774b225fca86092ac1cbb8bff18a396798515fac9bded40950e`
- diversity_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3/gates/diversity-v2/diversity-report.md` sha256=`b5d7a4e999e7c53b797171e2aca4bb434424ec079a1417e6be5ecde2784d00fe`
- c6_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3/gates/c6-leakage-v2/c6-leakage-probe.json` sha256=`daa09058182b7efd57215ce87ae75052a0c2029786f6fa43c301fc389edca4db`
- runner_receipt_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3/gates/B03-GATES-RECEIPT-v2.json` sha256=`external_after_final_write`
- runner_receipt_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3/gates/B03-GATES-RECEIPT-v2.md` sha256=`external_after_final_write`

## Resource Envelope

- started_at: `2026-07-03T08:37:18.931066Z`
- ended_at: `2026-07-03T08:37:19.881284Z`
- duration_sec: `0.959`
- host: `wangleideMacBook-Pro-3.local`
- python: `3.9.6`
- row_count: `50`

## Residual

This receipt does not assert judge pass, train-ready, V-PASS, or run authorization.

## Repair Event

- repair_event: `judge_D3_position_slot_omission_fix`
- fixed_sample_ids: `warmup-batch-03-subcc-3-0012`, `warmup-batch-03-subcc-3-0025`
- supersedes: `B03-GATES-RECEIPT-v1`
- controller_receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3/controller-sha-injection-receipt.json`
- basis_pin: `b33d8eba152e5326f69bbe85fc356b73419ee9c3`
- note: controller receipt, batch_manifest.artifact_shas, SHA256SUMS, DataGate, diversity, and C6 leakage outputs refreshed for this repair lane.

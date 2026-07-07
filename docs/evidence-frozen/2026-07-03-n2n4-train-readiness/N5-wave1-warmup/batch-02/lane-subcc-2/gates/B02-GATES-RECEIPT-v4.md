# B02-GATES-RECEIPT-v4

status: mechanical_gates_pass_local
proof_class: local/pre_training_mechanical_gates
basis_id: `4e5147ea56a0957996482f91db30982b8b73d1b95399195b7fe8dd26b2c5ce43`
batch_id: `warmup-batch-02`
lane_dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2`
repo_head: `266783468ac38542574ea4787bec650d16ba6b02`

## Verdict

PASS: controller injection, DataGate, diversity, and C6 leakage gates all passed locally.

## Steps

| step | status | exit | duration_sec | note |
|---|---|---:|---:|---|
| preflight | `pass` |  |  | required inputs present |
| inject_tool_py_compile | `pass` | 0 | 0.019 |  |
| controller_row_sha_injection | `pass` | 0 | 0.124 |  |
| controller_closure_verify | `pass` |  |  | rows=50 row_sha=50/50 ledger=50/50 |
| datagate | `pass` | 0 | 0.934 | status=data_gate_ready |
| diversity | `pass` | 0 | 0.035 | status=PASS |
| c6_leakage_probe | `pass` | 0 | 0.03 | status=pass |

## Gate Outputs

- datagate_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/datagate-v4/c5-data-gate-receipt.json` sha256=`3395f92e96b83807c619f49936ab39885a3737f9c810fcdcadc8612cb42bd23c`
- datagate_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/datagate-v4/c5-data-gate-receipt.md` sha256=`e4f5cb75f5340110a695ab50d6cac89fa13b3350b1674fb0109135c5dfbd9646`
- diversity_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/diversity-v4/diversity-report.json` sha256=`b573d4aeb0c42fd0f458230cab77d14ca587a4d613ee18aea8dc3d905d12d90b`
- diversity_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/diversity-v4/diversity-report.md` sha256=`7a0819e7fbf4d2b2da58a3ed2f02f44ba787e73617c29a57a9364adae332e409`
- c6_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/c6-leakage-v4/c6-leakage-probe.json` sha256=`bb5f2d6dcbec097e2fadbacc1350b12e16b43c5c8d91cdeb6e7079cfbe93fddd`
- runner_receipt_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/B02-GATES-RECEIPT-v4.json` sha256=`external_after_final_write`
- runner_receipt_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/B02-GATES-RECEIPT-v4.md` sha256=`external_after_final_write`

## Resource Envelope

- started_at: `2026-07-03T08:37:06.350640Z`
- ended_at: `2026-07-03T08:37:07.505213Z`
- duration_sec: `1.163`
- host: `wangleideMacBook-Pro-3.local`
- python: `3.9.6`
- row_count: `50`

## Residual

This receipt does not assert judge pass, train-ready, V-PASS, or run authorization.

## Repair Event

- repair_event: `judge_D3_position_slot_omission_fix`
- fixed_sample_ids: `warmup-batch-02-subcc-2-0007`, `warmup-batch-02-subcc-2-0023`
- supersedes: `B02-GATES-RECEIPT-v1`, `B02-GATES-RECEIPT-v2`, `B02-GATES-RECEIPT-v3`
- controller_receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/controller-sha-injection-receipt.json`
- basis_pin: `b33d8eba152e5326f69bbe85fc356b73419ee9c3`
- note: controller receipt, batch_manifest.artifact_shas, SHA256SUMS, DataGate, diversity, and C6 leakage outputs refreshed for this repair lane.

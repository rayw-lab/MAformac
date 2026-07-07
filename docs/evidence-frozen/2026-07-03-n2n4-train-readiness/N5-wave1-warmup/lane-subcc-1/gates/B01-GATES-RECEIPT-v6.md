# B01-GATES-RECEIPT-v6

status: mechanical_gates_pass_local
proof_class: local/pre_training_mechanical_gates
basis_id: `9321f619262e3e93c9c8139ea53c20eaf5f241df9ad2acc58907c529481ccad5`
batch_id: `warmup-batch-01`
lane_dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1`
repo_head: `266783468ac38542574ea4787bec650d16ba6b02`

## Verdict

PASS: controller injection, DataGate, diversity, and C6 leakage gates all passed locally.

## Steps

| step | status | exit | duration_sec | note |
|---|---|---:|---:|---|
| preflight | `pass` |  |  | required inputs present |
| inject_tool_py_compile | `pass` | 0 | 0.139 |  |
| controller_row_sha_injection | `pass` | 0 | 0.393 |  |
| controller_closure_verify | `pass` |  |  | rows=50 row_sha=50/50 ledger=50/50 |
| datagate | `pass` | 0 | 4.765 | status=data_gate_ready |
| diversity | `pass` | 0 | 0.078 | status=PASS |
| c6_leakage_probe | `pass` | 0 | 0.059 | status=pass |

## Gate Outputs

- datagate_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/datagate-v6/c5-data-gate-receipt.json` sha256=`be01840a4c95287fe58458c0291f9627fdff341c96dcabf852c4dce843685a0b`
- datagate_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/datagate-v6/c5-data-gate-receipt.md` sha256=`293133d81b45273d9145b5bee7f426426d73d18977553b50279753f1b59e94a8`
- diversity_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/diversity-v6/diversity-report.json` sha256=`46fccf9c9b41312a2a2a4c5b869d85e02f8ee334f8d77c7e7cabb7367ac8e4f1`
- diversity_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/diversity-v6/diversity-report.md` sha256=`c47733ebf2d34904261cdeed3858853b571214d58cf1b14c480ae70a78bbd303`
- c6_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/c6-leakage-v6/c6-leakage-probe.json` sha256=`e6c40ac7f1e21bdf14bb029f02d1049d90df3cf9ce9f565e5f93c94ba69dd9b8`
- runner_receipt_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/B01-GATES-RECEIPT-v6.json` sha256=`external_after_final_write`
- runner_receipt_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/B01-GATES-RECEIPT-v6.md` sha256=`external_after_final_write`

## Resource Envelope

- started_at: `2026-07-03T07:40:03.268880Z`
- ended_at: `2026-07-03T07:40:08.756543Z`
- duration_sec: `5.791`
- host: `wangleideMacBook-Pro-3.local`
- python: `3.9.6`
- row_count: `50`

## Residual

This receipt does not assert judge pass, train-ready, V-PASS, or run authorization.

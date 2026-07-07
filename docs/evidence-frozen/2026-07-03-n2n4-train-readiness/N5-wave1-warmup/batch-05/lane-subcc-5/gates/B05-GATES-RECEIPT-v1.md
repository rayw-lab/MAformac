# B05-GATES-RECEIPT-v1

status: mechanical_gates_pass_local
proof_class: local/pre_training_mechanical_gates
basis_id: `3a450aedc3b72c0711fb6301057b5410bcdb5d6ee0da45053ab664f79fea5fb1`
batch_id: `warmup-batch-05`
lane_dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-05/lane-subcc-5`
repo_head: `266783468ac38542574ea4787bec650d16ba6b02`

## Verdict

PASS: controller injection, DataGate, diversity, and C6 leakage gates all passed locally.

## Steps

| step | status | exit | duration_sec | note |
|---|---|---:|---:|---|
| preflight | `pass` |  |  | required inputs present |
| inject_tool_py_compile | `pass` | 0 | 0.019 |  |
| controller_row_sha_injection | `pass` | 0 | 0.109 |  |
| controller_closure_verify | `pass` |  |  | rows=50 row_sha=50/50 ledger=50/50 |
| datagate | `pass` | 0 | 0.634 | status=data_gate_ready |
| diversity | `pass` | 0 | 0.031 | status=PASS |
| c6_leakage_probe | `pass` | 0 | 0.026 | status=pass |

## Gate Outputs

- datagate_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-05/lane-subcc-5/gates/datagate-v1/c5-data-gate-receipt.json` sha256=`bf02780ccfcd08f473fb668a85e834fc6ea80d77d87f185876cfffb69f9827b0`
- datagate_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-05/lane-subcc-5/gates/datagate-v1/c5-data-gate-receipt.md` sha256=`8a35466732fda6484fb0b22823f0c5018927c206c18d8eac3c28b387f08a120b`
- diversity_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-05/lane-subcc-5/gates/diversity-v1/diversity-report.json` sha256=`4f2525b149d40845ce69eab66a1b1b966d9f90aa395413da4facf270dfcd5c53`
- diversity_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-05/lane-subcc-5/gates/diversity-v1/diversity-report.md` sha256=`2d12429488764d3ecbd5752a9d5f200b9116da74b10de41cc32b1c51ea1ec2a2`
- c6_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-05/lane-subcc-5/gates/c6-leakage-v1/c6-leakage-probe.json` sha256=`4ff46a37ac90a596519511f95de5c3b5b1530106c2772fb9db316d0f3ba7a283`
- runner_receipt_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-05/lane-subcc-5/gates/B05-GATES-RECEIPT-v1.json` sha256=`external_after_final_write`
- runner_receipt_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-05/lane-subcc-5/gates/B05-GATES-RECEIPT-v1.md` sha256=`external_after_final_write`

## Resource Envelope

- started_at: `2026-07-03T07:56:50.332336Z`
- ended_at: `2026-07-03T07:56:51.158777Z`
- duration_sec: `0.84`
- host: `wangleideMacBook-Pro-3.local`
- python: `3.9.6`
- row_count: `50`

## Residual

This receipt does not assert judge pass, train-ready, V-PASS, or run authorization.

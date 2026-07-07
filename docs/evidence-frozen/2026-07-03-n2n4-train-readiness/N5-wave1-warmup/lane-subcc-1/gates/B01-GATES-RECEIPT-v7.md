# B01-GATES-RECEIPT-v7

status: mechanical_gates_pass_local
proof_class: local/pre_training_mechanical_gates
basis_id: `e36bfbf6d41cc2700d08333005ff7fe5ae9b08a5618a820e6c3d36c0a00ec6b6`
batch_id: `warmup-batch-01`
lane_dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1`
repo_head: `266783468ac38542574ea4787bec650d16ba6b02`

## Verdict

PASS: controller injection, DataGate, diversity, and C6 leakage gates all passed locally.

## Steps

| step | status | exit | duration_sec | note |
|---|---|---:|---:|---|
| preflight | `pass` |  |  | required inputs present |
| inject_tool_py_compile | `pass` | 0 | 0.02 |  |
| controller_row_sha_injection | `pass` | 0 | 0.13 |  |
| controller_closure_verify | `pass` |  |  | rows=50 row_sha=50/50 ledger=50/50 |
| datagate | `pass` | 0 | 0.852 | status=data_gate_ready |
| diversity | `pass` | 0 | 0.037 | status=PASS |
| c6_leakage_probe | `pass` | 0 | 0.03 | status=pass |

## Gate Outputs

- datagate_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/datagate-v7/c5-data-gate-receipt.json` sha256=`fc68865f6f7f5dea0b9df09696b1820804d57d783cb86b5c177db45822f5567b`
- datagate_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/datagate-v7/c5-data-gate-receipt.md` sha256=`96bf11b8aafb5bf24ac844dbb9391a4700760b22341641643c0d99d5a612e987`
- diversity_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/diversity-v7/diversity-report.json` sha256=`144a27a8721b1dc6efa5d90301af2064c9cf9f5bb93395ac59ff603969cca072`
- diversity_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/diversity-v7/diversity-report.md` sha256=`a644b7fb9e11ac0c9f6310997a37d5643132d6f3b9ebfd266fef7db8d1fd3e60`
- c6_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/c6-leakage-v7/c6-leakage-probe.json` sha256=`f75118d9ff5aa5cc4d443b09937dff1f96afa8a6ac1d3e50e8fb733983b27691`
- runner_receipt_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/B01-GATES-RECEIPT-v7.json` sha256=`external_after_final_write`
- runner_receipt_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/B01-GATES-RECEIPT-v7.md` sha256=`external_after_final_write`

## Resource Envelope

- started_at: `2026-07-03T07:49:43.238467Z`
- ended_at: `2026-07-03T07:49:44.322442Z`
- duration_sec: `1.095`
- host: `wangleideMacBook-Pro-3.local`
- python: `3.9.6`
- row_count: `50`

## Residual

This receipt does not assert judge pass, train-ready, V-PASS, or run authorization.

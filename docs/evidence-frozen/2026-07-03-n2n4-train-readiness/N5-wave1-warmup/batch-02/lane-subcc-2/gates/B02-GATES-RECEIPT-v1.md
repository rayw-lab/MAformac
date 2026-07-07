# B02-GATES-RECEIPT-v1

status: mechanical_gates_pass_local
proof_class: local/pre_training_mechanical_gates
basis_id: `b85621aa0da9caac1520106bd6fda6f6b6a40851855207537952091e36ad1277`
batch_id: `warmup-batch-02`
lane_dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2`
repo_head: `266783468ac38542574ea4787bec650d16ba6b02`

## Verdict

PASS: controller injection, DataGate, diversity, and C6 leakage gates all passed locally.

## Steps

| step | status | exit | duration_sec | note |
|---|---|---:|---:|---|
| preflight | `pass` |  |  | required inputs present |
| inject_tool_py_compile | `pass` | 0 | 0.189 |  |
| controller_row_sha_injection | `pass` | 0 | 0.545 |  |
| controller_closure_verify | `pass` |  |  | rows=50 row_sha=50/50 ledger=50/50 |
| datagate | `pass` | 0 | 39.851 | status=data_gate_ready |
| diversity | `pass` | 0 | 0.106 | status=PASS |
| c6_leakage_probe | `pass` | 0 | 0.033 | status=pass |

## Gate Outputs

- datagate_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/datagate-v1/c5-data-gate-receipt.json` sha256=`e194df1636861cc5c200eaab0d2b9f5839d045529ddc1b0bead3997e07050519`
- datagate_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/datagate-v1/c5-data-gate-receipt.md` sha256=`a91e3bfeffa7c72e96bd1b4f50cfe5d5f6773f35fae666055cf967a0cd4ae268`
- diversity_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/diversity-v1/diversity-report.json` sha256=`0e12129d5918f8631ca4665a6d23813ab927381a762db0ffb6cf6e2516dbf088`
- diversity_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/diversity-v1/diversity-report.md` sha256=`d58e3caf4b500c998a988f8ac734d731aaa0340f32fc523526adbfc9bf4d3cd1`
- c6_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/c6-leakage-v1/c6-leakage-probe.json` sha256=`a6358689569928ce96bcbe382b3c3bd9e8f7c6f5d2d84684daef4aadcf5e1619`
- runner_receipt_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/B02-GATES-RECEIPT-v1.json` sha256=`external_after_final_write`
- runner_receipt_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/B02-GATES-RECEIPT-v1.md` sha256=`external_after_final_write`

## Resource Envelope

- started_at: `2026-07-03T07:47:06.171812Z`
- ended_at: `2026-07-03T07:47:46.962893Z`
- duration_sec: `40.933`
- host: `wangleideMacBook-Pro-3.local`
- python: `3.9.6`
- row_count: `50`

## Residual

This receipt does not assert judge pass, train-ready, V-PASS, or run authorization.

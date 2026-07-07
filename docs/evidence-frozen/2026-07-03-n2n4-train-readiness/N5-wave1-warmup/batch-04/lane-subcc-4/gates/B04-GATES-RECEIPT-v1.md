# B04-GATES-RECEIPT-v1

status: mechanical_gates_pass_local
proof_class: local/pre_training_mechanical_gates
basis_id: `e6fc85949bf6bc77bad87f47fddd38e7a5728262a3b7a8601ea602cd6c4acf07`
batch_id: `warmup-batch-04`
lane_dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-04/lane-subcc-4`
repo_head: `266783468ac38542574ea4787bec650d16ba6b02`

## Verdict

PASS: controller injection, DataGate, diversity, and C6 leakage gates all passed locally.

## Steps

| step | status | exit | duration_sec | note |
|---|---|---:|---:|---|
| preflight | `pass` |  |  | required inputs present |
| inject_tool_py_compile | `pass` | 0 | 0.018 |  |
| controller_row_sha_injection | `pass` | 0 | 0.113 |  |
| controller_closure_verify | `pass` |  |  | rows=50 row_sha=50/50 ledger=50/50 |
| datagate | `pass` | 0 | 0.684 | status=data_gate_ready |
| diversity | `pass` | 0 | 0.032 | status=PASS |
| c6_leakage_probe | `pass` | 0 | 0.027 | status=pass |

## Gate Outputs

- datagate_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-04/lane-subcc-4/gates/datagate-v1/c5-data-gate-receipt.json` sha256=`28d20a213c460cdd9e5c98267106acf98d6ceb6c230a9017f0cd9c0d9d70ffee`
- datagate_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-04/lane-subcc-4/gates/datagate-v1/c5-data-gate-receipt.md` sha256=`69553419990c0458e6113bf0625d1fcda15859c33f2bc9d93bd26872a1d99c63`
- diversity_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-04/lane-subcc-4/gates/diversity-v1/diversity-report.json` sha256=`90bb46d27144d51a1638e450dc3bb742cdf4e06d964c3d9833526a1c38aec95e`
- diversity_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-04/lane-subcc-4/gates/diversity-v1/diversity-report.md` sha256=`481aaef0309cd633a96346d1ea283221efc8ddb152c46cfbfac082f09d655f41`
- c6_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-04/lane-subcc-4/gates/c6-leakage-v1/c6-leakage-probe.json` sha256=`4a3901d039d7ec0569192afe33cad118bd264ff6b4be9d557f176fc7b1108b3a`
- runner_receipt_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-04/lane-subcc-4/gates/B04-GATES-RECEIPT-v1.json` sha256=`external_after_final_write`
- runner_receipt_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-04/lane-subcc-4/gates/B04-GATES-RECEIPT-v1.md` sha256=`external_after_final_write`

## Resource Envelope

- started_at: `2026-07-03T07:56:20.797938Z`
- ended_at: `2026-07-03T07:56:21.682214Z`
- duration_sec: `0.898`
- host: `wangleideMacBook-Pro-3.local`
- python: `3.9.6`
- row_count: `50`

## Residual

This receipt does not assert judge pass, train-ready, V-PASS, or run authorization.

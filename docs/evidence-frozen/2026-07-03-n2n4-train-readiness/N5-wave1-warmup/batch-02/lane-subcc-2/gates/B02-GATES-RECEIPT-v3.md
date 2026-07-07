# B02-GATES-RECEIPT-v3

status: mechanical_gates_pass_local
proof_class: local/pre_training_mechanical_gates
basis_id: `a72f952aa1d58e8ebb8237bc23ebb4922f7e8688141a7f96426436c69c6581ee`
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
| controller_row_sha_injection | `pass` | 0 | 0.126 |  |
| controller_closure_verify | `pass` |  |  | rows=50 row_sha=50/50 ledger=50/50 |
| datagate | `pass` | 0 | 0.725 | status=data_gate_ready |
| diversity | `pass` | 0 | 0.033 | status=PASS |
| c6_leakage_probe | `pass` | 0 | 0.028 | status=pass |

## Gate Outputs

- datagate_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/datagate-v3/c5-data-gate-receipt.json` sha256=`0a966c01ebe4742cb898cd94fa29a4d14ad6e3f4b70ff289f2aa7e9fa3cfb3de`
- datagate_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/datagate-v3/c5-data-gate-receipt.md` sha256=`8e94a116ea260905acfc5b3acb28bfdc5211f10a8c6180ffe9406effa6d6d37c`
- diversity_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/diversity-v3/diversity-report.json` sha256=`282deaeae98dee5392699d2e3cc099fe1ba3a030fc8378d905cbbb513c21c355`
- diversity_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/diversity-v3/diversity-report.md` sha256=`830d63c5ec5c5ed45672a77a432f1e1dc66d0938c3946de4c9790f712394e092`
- c6_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/c6-leakage-v3/c6-leakage-probe.json` sha256=`ef9bc4b6ebedef33de175e9bb3b384849fdf3ce8e3c7377fc1dac2f98637b05f`
- runner_receipt_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/B02-GATES-RECEIPT-v3.json` sha256=`external_after_final_write`
- runner_receipt_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/B02-GATES-RECEIPT-v3.md` sha256=`external_after_final_write`

## Resource Envelope

- started_at: `2026-07-03T07:54:20.855149Z`
- ended_at: `2026-07-03T07:54:21.797131Z`
- duration_sec: `0.956`
- host: `wangleideMacBook-Pro-3.local`
- python: `3.9.6`
- row_count: `50`

## Residual

This receipt does not assert judge pass, train-ready, V-PASS, or run authorization.

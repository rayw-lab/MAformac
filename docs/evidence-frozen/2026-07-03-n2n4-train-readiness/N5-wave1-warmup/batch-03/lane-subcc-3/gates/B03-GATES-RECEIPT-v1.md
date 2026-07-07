# B03-GATES-RECEIPT-v1

status: mechanical_gates_pass_local
proof_class: local/pre_training_mechanical_gates
basis_id: `3a9f0ba84a0a9b70a6b04507920777ff4df87976162e6e89a73319cdcc8dff46`
batch_id: `warmup-batch-03`
lane_dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3`
repo_head: `266783468ac38542574ea4787bec650d16ba6b02`

## Verdict

PASS: controller injection, DataGate, diversity, and C6 leakage gates all passed locally.

## Steps

| step | status | exit | duration_sec | note |
|---|---|---:|---:|---|
| preflight | `pass` |  |  | required inputs present |
| inject_tool_py_compile | `pass` | 0 | 0.019 |  |
| controller_row_sha_injection | `pass` | 0 | 0.119 |  |
| controller_closure_verify | `pass` |  |  | rows=50 row_sha=50/50 ledger=50/50 |
| datagate | `pass` | 0 | 0.679 | status=data_gate_ready |
| diversity | `pass` | 0 | 0.032 | status=PASS |
| c6_leakage_probe | `pass` | 0 | 0.027 | status=pass |

## Gate Outputs

- datagate_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3/gates/datagate-v1/c5-data-gate-receipt.json` sha256=`9ba92eaaa3b11e00b5772565b42893da936f3e14b3569cc2b2f19a56970235a9`
- datagate_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3/gates/datagate-v1/c5-data-gate-receipt.md` sha256=`8009b4bb44299c69e7f011b8566910557f256d4efc6384019cc1d7f097023e77`
- diversity_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3/gates/diversity-v1/diversity-report.json` sha256=`88b119c7160a34840308f8ff156ed2cfd82e81b8ab22ef93a3952a8ae98549a3`
- diversity_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3/gates/diversity-v1/diversity-report.md` sha256=`126c48ad686723f6046e90010977366e14eee86b361e7a6b5bf5137743535724`
- c6_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3/gates/c6-leakage-v1/c6-leakage-probe.json` sha256=`6807b51ec7cd75861abb8c8adaec8655ff6ce8c48ecefde07c1ead0d75f1e5dd`
- runner_receipt_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3/gates/B03-GATES-RECEIPT-v1.json` sha256=`external_after_final_write`
- runner_receipt_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3/gates/B03-GATES-RECEIPT-v1.md` sha256=`external_after_final_write`

## Resource Envelope

- started_at: `2026-07-03T07:55:35.087618Z`
- ended_at: `2026-07-03T07:55:35.974372Z`
- duration_sec: `0.901`
- host: `wangleideMacBook-Pro-3.local`
- python: `3.9.6`
- row_count: `50`

## Residual

This receipt does not assert judge pass, train-ready, V-PASS, or run authorization.

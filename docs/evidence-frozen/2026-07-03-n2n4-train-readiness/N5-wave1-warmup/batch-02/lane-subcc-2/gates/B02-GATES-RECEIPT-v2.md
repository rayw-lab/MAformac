# B02-GATES-RECEIPT-v2

status: mechanical_gates_pass_local
proof_class: local/pre_training_mechanical_gates
basis_id: `0b3e7072b46814933bffbeff691d6d3c13a3212c8ac4e98dd8681b9903e4d62c`
batch_id: `warmup-batch-02`
lane_dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2`
repo_head: `266783468ac38542574ea4787bec650d16ba6b02`

## Verdict

PASS: controller injection, DataGate, diversity, and C6 leakage gates all passed locally.

## Steps

| step | status | exit | duration_sec | note |
|---|---|---:|---:|---|
| preflight | `pass` |  |  | required inputs present |
| inject_tool_py_compile | `pass` | 0 | 0.02 |  |
| controller_row_sha_injection | `pass` | 0 | 0.124 |  |
| controller_closure_verify | `pass` |  |  | rows=50 row_sha=50/50 ledger=50/50 |
| datagate | `pass` | 0 | 0.751 | status=data_gate_ready |
| diversity | `pass` | 0 | 0.035 | status=PASS |
| c6_leakage_probe | `pass` | 0 | 0.03 | status=pass |

## Gate Outputs

- datagate_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/datagate-v2/c5-data-gate-receipt.json` sha256=`d7c113eaf2d91a2dab8f075ead253ca0ee2929d02aa7546088ca73208ae4a576`
- datagate_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/datagate-v2/c5-data-gate-receipt.md` sha256=`d9c0b24706f88c69b151be09baa2828b02f02d80413f55fe7761cb92516295d6`
- diversity_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/diversity-v2/diversity-report.json` sha256=`0496228f940ae65d7e9448428dd509b862a3c32cee728b421389e9871174aaf0`
- diversity_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/diversity-v2/diversity-report.md` sha256=`1a956d5c0b38bdb5711335f270cb40090125e81c2b880e45b540c6c2c62091c3`
- c6_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/c6-leakage-v2/c6-leakage-probe.json` sha256=`c6730d27fb6b4341f628fa5b4f2efc8bb337ea074ea770285d0809a4329ca70c`
- runner_receipt_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/B02-GATES-RECEIPT-v2.json` sha256=`external_after_final_write`
- runner_receipt_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/B02-GATES-RECEIPT-v2.md` sha256=`external_after_final_write`

## Resource Envelope

- started_at: `2026-07-03T07:50:01.158180Z`
- ended_at: `2026-07-03T07:50:02.129574Z`
- duration_sec: `0.981`
- host: `wangleideMacBook-Pro-3.local`
- python: `3.9.6`
- row_count: `50`

## Residual

This receipt does not assert judge pass, train-ready, V-PASS, or run authorization.

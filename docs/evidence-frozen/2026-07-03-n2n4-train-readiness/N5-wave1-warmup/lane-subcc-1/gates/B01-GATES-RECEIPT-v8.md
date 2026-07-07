# B01-GATES-RECEIPT-v8

status: mechanical_gates_pass_local
proof_class: local/pre_training_mechanical_gates
basis_id: `ced017164655e3fb60eb27d201081c6bc14d4118e8c1d42e8d5a688a015905a6`
batch_id: `warmup-batch-01`
lane_dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1`
repo_head: `266783468ac38542574ea4787bec650d16ba6b02`

## Verdict

PASS: controller injection, DataGate, diversity, and C6 leakage gates all passed locally.

## Steps

| step | status | exit | duration_sec | note |
|---|---|---:|---:|---|
| preflight | `pass` |  |  | required inputs present |
| inject_tool_py_compile | `pass` | 0 | 0.019 |  |
| controller_row_sha_injection | `pass` | 0 | 0.122 |  |
| controller_closure_verify | `pass` |  |  | rows=50 row_sha=50/50 ledger=50/50 |
| datagate | `pass` | 0 | 0.866 | status=data_gate_ready |
| diversity | `pass` | 0 | 0.036 | status=PASS |
| c6_leakage_probe | `pass` | 0 | 0.029 | status=pass |

## Gate Outputs

- datagate_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/datagate-v8/c5-data-gate-receipt.json` sha256=`5bc5712ddb9935bdeab27683981fd014c4b500844d0dbb2a90718eb6bbad38ad`
- datagate_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/datagate-v8/c5-data-gate-receipt.md` sha256=`725aa4e3a47b859f3c874be07faf065cbb48470a5e6c14735a4c167144f2a3dd`
- diversity_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/diversity-v8/diversity-report.json` sha256=`d6f3c432d129ecc25b2df23f8a3386045cc1d508c0adcb4531ac1ca656287842`
- diversity_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/diversity-v8/diversity-report.md` sha256=`b4d3139fbbfbedc764ed140edac20b93e12a49535eec881ecdb90f2083c985a1`
- c6_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/c6-leakage-v8/c6-leakage-probe.json` sha256=`42ae22631f40c444b90ac6b2a630c615a8a538cdde7ab75dd3dd01bf61ee9b39`
- runner_receipt_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/B01-GATES-RECEIPT-v8.json` sha256=`external_after_final_write`
- runner_receipt_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/B01-GATES-RECEIPT-v8.md` sha256=`external_after_final_write`

## Resource Envelope

- started_at: `2026-07-03T07:54:05.926637Z`
- ended_at: `2026-07-03T07:54:07.011305Z`
- duration_sec: `1.096`
- host: `wangleideMacBook-Pro-3.local`
- python: `3.9.6`
- row_count: `50`

## Residual

This receipt does not assert judge pass, train-ready, V-PASS, or run authorization.

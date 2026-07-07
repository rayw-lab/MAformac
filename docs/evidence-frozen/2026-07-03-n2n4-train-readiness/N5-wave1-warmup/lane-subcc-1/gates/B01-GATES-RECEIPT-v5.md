# B01-GATES-RECEIPT-v5

status: mechanical_gates_pass_local
proof_class: local/pre_training_mechanical_gates
basis_id: `90d069be84c632bb9fb6fd8a20fa870ecfa1e75434bfac649467ce3b5c1ac9a1`
batch_id: `warmup-batch-01`
lane_dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1`
repo_head: `266783468ac38542574ea4787bec650d16ba6b02`

## Verdict

PASS: controller injection, DataGate, diversity, and C6 leakage gates all passed locally.

## Steps

| step | status | exit | duration_sec | note |
|---|---|---:|---:|---|
| preflight | `pass` |  |  | required inputs present |
| inject_tool_py_compile | `pass` | 0 | 0.038 |  |
| controller_row_sha_injection | `pass` | 0 | 0.197 |  |
| controller_closure_verify | `pass` |  |  | rows=50 row_sha=50/50 ledger=50/50 |
| datagate | `pass` | 0 | 75.552 | status=data_gate_ready |
| diversity | `pass` | 0 | 0.266 | status=PASS |
| c6_leakage_probe | `pass` | 0 | 0.098 | status=pass |

## Gate Outputs

- datagate_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/datagate-v5/c5-data-gate-receipt.json` sha256=`392be2b0990053ab82c3efeb6fb5d074a19d72787f541ec1fb0056cd14621625`
- datagate_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/datagate-v5/c5-data-gate-receipt.md` sha256=`b6dc4af3e6822bffe1ef764149f0c930bcb361f6e2db8781d701af8ebdd9877f`
- diversity_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/diversity-v5/diversity-report.json` sha256=`d60795826fd0d4c73e25ad4e0ec5f06e47b18e82c976e941985df81aaac46918`
- diversity_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/diversity-v5/diversity-report.md` sha256=`788bdfcbe037df3dbce9a872817e10024ab5cba9c2045ee91b9b93707e33dd4f`
- c6_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/c6-leakage-v5/c6-leakage-probe.json` sha256=`7be31c8dfce58077b19de744a2c1d8afddfae87054d4524b982893428ff62587`
- runner_receipt_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/B01-GATES-RECEIPT-v5.json` sha256=`a5fb920eb3452ad8e4fa4a0c521966add7bcb2118ead56321e8b92763fc36120`
- runner_receipt_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/B01-GATES-RECEIPT-v5.md` sha256=`843a16a6951895493fc2694a157862a211ba29e0881da95d707146bff756ddae`

## Resource Envelope

- started_at: `2026-07-03T07:37:35.949963Z`
- ended_at: `2026-07-03T07:38:52.237401Z`
- duration_sec: `76.333`
- host: `wangleideMacBook-Pro-3.local`
- python: `3.9.6`
- row_count: `50`

## Residual

This receipt does not assert judge pass, train-ready, V-PASS, or run authorization.

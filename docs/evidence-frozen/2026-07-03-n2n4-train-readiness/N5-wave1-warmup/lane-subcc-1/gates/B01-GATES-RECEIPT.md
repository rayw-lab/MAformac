# B01 Mechanical Gates Receipt

status: BLOCKED_DATAGATE_TOOL_SCHEMA_DIGEST_MISMATCH  
proof_class: local/pre-training mechanical gates  
generated_at: 2026-07-03T05:38:28Z  
lane: subcc-1  
batch_id: warmup-batch-01  
code_face: `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge` `main@1526a26bab943d3aba0ae26bb430b74f6a60c4c2`  

## Inputs

- candidates: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/candidates.jsonl`
- ledger: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/value_change_ledger.jsonl`
- generation receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/generation_receipt.md`
- candidate rows: 50
- ledger rows: 50

## Gate Summary

| gate | command status | receipt status | key evidence |
|---|---:|---|---|
| C5DataGateCLI | exit 65 | `blocked` | `row_count=50`, `failure_receipt=50`, all `tool_schema_digest_mismatch` |
| diversity | exit 0 | `PASS` | `record_count=50`, missing_text=0, warning_pairs=0, severe_pairs=0 |
| C6 exact leakage probe | exit 0 | `pass` | `c6_case_id_intersection_count=0`, `c6_protected_case_id_intersection_count=0` |

Overall verdict is `BLOCKED` because DataGate is fail-closed.

## DataGate Root Cause Evidence

Candidate rows:

```text
subset_group_id=scene.scene1 count=50
candidate tool_schema_digest=165b485f8c454be22d8fcdbb0ac942e7b95e3aa3d04b115c4bd7fbb28770370b count=50
```

Current main manifest:

```text
group_id=scene.scene1 subset_policy_id=e2-lite-v1
manifest tool_schema_digest=0472db32779712dcb207f4dcc8ed35a387283a4381e42460284bea5704e2825e
tool_count=22
```

DataGate failure count:

```text
tool_schema_digest_mismatch=50
first_ids=warmup-batch-01-subcc-1-0001..0005
```

## Receipt Paths

- DataGate JSON: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/datagate/c5-data-gate-receipt.json`
- DataGate MD: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/datagate/c5-data-gate-receipt.md`
- Diversity JSON: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/diversity/diversity-report.json`
- Diversity MD: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/diversity/diversity-report.md`
- C6 exact leakage JSON: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/c6-leakage/c6-leakage-probe.json`

## Receipt SHA256

```text
e65288d0b8260601d479dbb04457a6009a9a7bb476d448874aa4fa7cb1cddcfe  datagate/c5-data-gate-receipt.json
a61d8e3df72cab0743f61a83f03bb0d4f08c3ceecf633a62140d52e9bfa48bca  datagate/c5-data-gate-receipt.md
419daef6d83437197d417082afc78252890e8459a04480383261798d1fbf7893  diversity/diversity-report.json
4566637df1fe786ebb3696e1a4f5e2e0935ace1c197855af93311488a7bde1d2  diversity/diversity-report.md
36069d29e6794ea6cdd32f42fb935893e13785d681b6b63e4c4351bdc46edd9f  c6-leakage/c6-leakage-probe.json
```

## Commands

```bash
swift run C5DataGateCLI \
  --candidates /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/candidates.jsonl \
  --source-digest-path /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/candidates.jsonl \
  --source-digest-path /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/value_change_ledger.jsonl \
  --source-digest-path /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/batch_manifest.json \
  --source-digest-path /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/generation_receipt.md \
  --source-digest-path /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/SHA256SUMS.txt \
  --source-authorization authorized_wave1_warmup_generation \
  --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/datagate
```

```bash
python3 /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/tools/canary_diversity_check.py \
  --input /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/candidates.jsonl \
  --output-md /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/diversity/diversity-report.md \
  --output-json /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/diversity/diversity-report.json
```

```bash
python3 /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/tools/canary_c6_leakage_probe.py \
  --canary-jsonl /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/candidates.jsonl \
  --c6-jsonl /Users/wanglei/workspace/MAformac-p5w-wave1-bridge/contracts/c6-bench-cases.jsonl \
  --output /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/c6-leakage/c6-leakage-probe.json
```

## Next

Generator/controller must reconcile `tool_schema_digest` against current `generated/subset-policy-manifest.json` before this lane can enter judge sampling. Diversity and C6 exact leakage are green but do not override DataGate.

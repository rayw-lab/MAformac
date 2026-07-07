# B01-GATES-RECEIPT-v4

status: d7_provenance_fixed_datagate_ready_local  
proof_class: local/pre_training_mechanical_repair_gate  
batch_id: warmup-batch-01  
lane_id: subcc-1  
code_face: /Users/wanglei/workspace/MAformac-p5w-wave1-bridge @ 1526a26bab943d3aba0ae26bb430b74f6a60c4c2  
data_face: lane-subcc-1 rev3 + controller normalization round2

## Verdict

PASS for the D7 repair gate: row-level `recipe_manifest_sha` and `quota_config_sha` are now stamped on all 50 candidate rows, `candidate_row_sha` is recomputed, ledger `candidate_row_sha` is aligned, SHA256SUMS is refreshed, and C5DataGate v4 is `data_gate_ready`.

This receipt does not assert final judge acceptance. It is scoped to the judge-declared repair surface: D7 provenance and row/ledger SHA closure. `%43` still owns scoped re-judge.

## Prior Blocker

`judge-openai-batch-01-verdict.md:17` failed batch-01 because all 50 candidate rows still had:

- `recipe_manifest_sha=sha256:TODO`
- `quota_config_sha=sha256:TODO`

The controller/manifest values are:

- `recipe_manifest_sha=sha256:83e8ad6a387d88e9d8f78adeedb878ac4e6a033ca6ee40538663fee4ac4a953f`
- `quota_config_sha=sha256:011387d640046b0a5a77d6cbb702cc81548c652cc9ad04149c7af8601bf1de23`

## Controller Normalization Round2

Injector extended:

- Tool: `N5-wave1-warmup/tools/inject_controller_shas.py`
- Tool sha256: `61ee0e858edc44866f87daf3a8d01311ac42105732d24f8fd9c8d4e47e39ee0d`
- New flag: `--stamp-row-controller-shas`
- Behavior: stamp row-level `recipe_manifest_sha`/`quota_config_sha`, recompute `candidate_row_sha`, update ledger `candidate_row_sha`, refresh SHA256SUMS.

Command:

```bash
python3 -m py_compile tools/inject_controller_shas.py
python3 tools/inject_controller_shas.py \
  --order batch-01-order.json \
  --builder-manifest builder-dryrun/wave1-warmup-batch-manifest.json \
  --lane-manifest lane-subcc-1/batch_manifest.json \
  --candidate-jsonl lane-subcc-1/candidates.jsonl \
  --ledger-jsonl lane-subcc-1/value_change_ledger.jsonl \
  --subset-policy-manifest /Users/wanglei/workspace/MAformac-p5w-wave1-bridge/generated/subset-policy-manifest.json \
  --sha256sums lane-subcc-1/SHA256SUMS.txt \
  --normalize-tool-schema-digest \
  --stamp-row-controller-shas \
  --receipt lane-subcc-1/controller-sha-injection-receipt.json \
  --force
```

Result:

| Field | Value |
|---|---|
| exit | 0 |
| receipt_version | `controller-sha-injection.v2` |
| round1 tool_schema rows_changed | 0 |
| round2 row provenance rows_changed | 50 |
| candidate rows checked | 50 |
| ledger rows checked | 50 |
| row-level recipe_manifest_sha count | 50/50 |
| row-level quota_config_sha count | 50/50 |
| candidate_row_sha recompute match | 50/50 |
| ledger candidate_row_sha match | 50/50 |

Diff samples:

| sample_id | old recipe | new recipe | old quota | new quota | old row sha | new row sha |
|---|---|---|---|---|---|---|
| `warmup-batch-01-subcc-1-0001` | `sha256:TODO` | `sha256:83e8ad6a387d88e9d8f78adeedb878ac4e6a033ca6ee40538663fee4ac4a953f` | `sha256:TODO` | `sha256:011387d640046b0a5a77d6cbb702cc81548c652cc9ad04149c7af8601bf1de23` | `d84d3c101e327547855841c37ba024ba096df31878e0c7e82b07d9950d367962` | `bdbd20e5e14a46791d1fe889237e45d7d0c6a7115f39e16e29e48d028649dd3a` |
| `warmup-batch-01-subcc-1-0050` | `sha256:TODO` | `sha256:83e8ad6a387d88e9d8f78adeedb878ac4e6a033ca6ee40538663fee4ac4a953f` | `sha256:TODO` | `sha256:011387d640046b0a5a77d6cbb702cc81548c652cc9ad04149c7af8601bf1de23` | `af9f30831d5fa08a86f64e62f10e439b11d941dfbb21bd5dab1e14f9a919ced2` | `e8b3a4f6efca3785ef16c6077b1307f4bb2d7a8048e4b3709fd42b0fecc77ba2` |

Updated artifact hashes:

| Artifact | sha256 |
|---|---|
| `lane-subcc-1/candidates.jsonl` | `eee76baf662cb41ae32b2a6f8c49c3d1fcf2b25b850001a5541822d27602016c` |
| `lane-subcc-1/value_change_ledger.jsonl` | `a1ed5e688a15f9a95b04a93ee0f79fa14ced47f3bcd9f455f65a6d2b2965ab81` |
| `lane-subcc-1/batch_manifest.json` | `99220464312057741e0fc4fce4aa7758197c17e83536e3948019257205806a1c` |
| `lane-subcc-1/SHA256SUMS.txt` | `a4865fd3b2d1310d878c9f6f5f6e5876317d9f01b91e8713e315607836fb666f` |
| `lane-subcc-1/controller-sha-injection-receipt.json` | `50f37241e2c01443855d074d1cd7c8760bb8a8d8b23c34b6236cb3a9a6a4d161` |
| `lane-subcc-1/gates/batch-01-accepted-pool-summary-v4.json` | `ff5967a303f5c6003f331ff6b1b22d615e739033c63b88486163ca917f795f2a` |

Accepted candidate pool canonical sha256 for judge receipt boundary:

`34270ae1e07c84e7c232b787431c6bae8d3966a1f91c23f56018f3a31458b187`

## DataGate v4

Command:

```bash
swift run C5DataGateCLI \
  --candidates /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/candidates.jsonl \
  --source-digest-path /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/candidates.jsonl \
  --source-digest-path /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/value_change_ledger.jsonl \
  --source-digest-path /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/batch_manifest.json \
  --source-digest-path /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/generation_receipt.md \
  --source-digest-path /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/SHA256SUMS.txt \
  --source-digest-path /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/controller-sha-injection-receipt.json \
  --source-authorization authorized_wave1_warmup_generation_controller_normalized_round2 \
  --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/datagate-v4
```

Result:

| Field | Value |
|---|---|
| exit | 0 |
| status | `data_gate_ready` |
| row_count | 50 |
| quarantine_count | 0 |
| must_not_train_violations | 0 |
| missing_surface_count | 0 |
| surface_field_pass | 50 |
| tool_call_format_pass | 50 |
| train_parent_semantic_overlap | 0 |
| redaction_status | `pass` |
| source_authorization_status | `authorized_wave1_warmup_generation_controller_normalized_round2` |
| source_snapshot_digest | `3f94258620599604707a830894e4945b62523035e62081a5727902782826c7ae` |

Receipts:

| Artifact | sha256 |
|---|---|
| `lane-subcc-1/gates/datagate-v4/c5-data-gate-receipt.json` | `3af569f0bd70d55ba44bbc76f91d8e6868784a1baccc86618c04fee52ea80ece` |
| `lane-subcc-1/gates/datagate-v4/c5-data-gate-receipt.md` | `1c3449ebf2fcc5d66bc42f42f61e3d88a7a05fc5b3dc8a8feaa77e3a1b75931c` |

## Residual

Content dimensions were not changed and were not re-reviewed here. `%43` scoped re-judge should check only D7 provenance plus row/ledger SHA closure, per the judge repair scope.

# B01-GATES-RECEIPT-v3

status: mechanical_gates_pass_local  
proof_class: local/pre_training_mechanical_gates  
batch_id: warmup-batch-01  
lane_id: subcc-1  
code_face: /Users/wanglei/workspace/MAformac-p5w-wave1-bridge @ 1526a26bab943d3aba0ae26bb430b74f6a60c4c2  
data_face: lane-subcc-1 rev3 + controller_normalization_step

## Verdict

PASS for B01 mechanical gates after controller normalization.

This receipt does not assert train-ready or wave acceptance. It only says the 50-row lane artifact is eligible to proceed to judge sampling/review after the mechanical gate set:

- C5DataGate v3: PASS (`data_gate_ready`, exit 0)
- diversity: PASS, reused from rev3/v2 gate because candidate text set was not changed by controller normalization
- C6 leakage: PASS, reused from rev3/v2 gate because candidate ids/text/tool calls were not changed by controller normalization

## Controller Normalization Step

Root cause resolved here: lane copied `subset_policy_digest` into `tool_schema_digest`, which was a semantic field mismatch. Per D-061 controller-injection semantics, controller normalized the field instead of sending the lane back.

True source used:

- DataGate loads `entries[].tool_schema_digest` from `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge/generated/subset-policy-manifest.json`.
- Loader anchor: `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge/Tools/C5DataGateCLI/main.swift:77-90`
- Validation anchor: `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge/Core/Bench/C5DataGate.swift:947-950`
- subset entry: `(subset_policy_id=e2-lite-v1, subset_group_id=scene.scene1)`
- expected `tool_schema_digest`: `0472db32779712dcb207f4dcc8ed35a387283a4381e42460284bea5704e2825e`
- subset manifest sha256: `f3a9c49109ffb33b06d233038787ca1fdad8a750d7f7d9f917738c4a83878f61`

Controller injection command:

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
  --receipt lane-subcc-1/controller-sha-injection-receipt.json \
  --force
```

Normalization result:

| Field | Value |
|---|---|
| candidate rows checked | 50 |
| ledger rows checked | 50 |
| rows changed | 50 |
| old `tool_schema_digest` | `f3a9c49109ffb33b06d233038787ca1fdad8a750d7f7d9f917738c4a83878f61` |
| new `tool_schema_digest` | `0472db32779712dcb207f4dcc8ed35a387283a4381e42460284bea5704e2825e` |
| full diff table | `lane-subcc-1/controller-sha-injection-receipt.json` |

Diff samples:

| sample_id | old row sha | new row sha |
|---|---|---|
| `warmup-batch-01-subcc-1-0001` | `cab3652322856b1d761e44cd953e3fa3d3fdde157bc4a462856a00a78999f0f5` | `d84d3c101e327547855841c37ba024ba096df31878e0c7e82b07d9950d367962` |
| `warmup-batch-01-subcc-1-0050` | `210c0753782840dd5e53c4d7aff6a131ab29bc6f9defbbbfcd72dcac8e5ba163` | `af9f30831d5fa08a86f64e62f10e439b11d941dfbb21bd5dab1e14f9a919ced2` |

Updated artifact hashes:

| Artifact | sha256 |
|---|---|
| `lane-subcc-1/candidates.jsonl` | `65fa3058809b273a9841489bd5eb13e1298789eb92e19926a961cbac9619a882` |
| `lane-subcc-1/value_change_ledger.jsonl` | `068fedf8bc8c3e32cfd243e40d853e7aa6e9a1e430e6272c8cc84b1fcf3613c5` |
| `lane-subcc-1/batch_manifest.json` | `c2c21faae3a809e02ce8d75e1d128677e480a8401bddde511ebcbd49b4f443c9` |
| `lane-subcc-1/SHA256SUMS.txt` | `8d81ecdaffc2428181d873e138760e05b1b424cca93d5644e5347d67319e48fb` |
| `lane-subcc-1/controller-sha-injection-receipt.json` | `a5afe45422453d3bd51f2dd71a88b55dca42773cea8e3b2fc80de589236ca17c` |

## DataGate v3

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
  --source-authorization authorized_wave1_warmup_generation_controller_normalized \
  --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/datagate-v3
```

Result:

| Field | Value |
|---|---|
| exit | 0 |
| status | `data_gate_ready` |
| row_count | 50 |
| bucket_counts | `{"train":50}` |
| quarantine_count | 0 |
| must_not_train_violations | 0 |
| missing_surface_count | 0 |
| surface_field_pass | 50 |
| tool_call_format_pass | 50 |
| tool_call_format_failures | 0 |
| train_parent_semantic_overlap | 0 |
| train_held_out_axis_overlap_count | 0 |
| redaction_status | `pass` |
| source_authorization_status | `authorized_wave1_warmup_generation_controller_normalized` |

Receipts:

| Artifact | sha256 |
|---|---|
| `lane-subcc-1/gates/datagate-v3/c5-data-gate-receipt.json` | `e4c327887b2f21f8b7ed20306e59f4b4cc7cc3ec89a2f3159e6c35eb10c8bfdf` |
| `lane-subcc-1/gates/datagate-v3/c5-data-gate-receipt.md` | `2aca795055fbea93fbf4052f8a57c1ed8acfdc68af9b97bf1f6110ac2e195dc2` |

## Reused Gates

Diversity and C6 leakage were not rerun for v3 by instruction. Controller normalization changed only `tool_schema_digest`, `candidate_row_sha`, ledger row shas, manifest shas, and SHA256SUMS. It did not change candidate text, sample ids, tool calls, or C6-facing identifiers.

| Gate | Source receipt | Status | sha256 |
|---|---|---|---|
| diversity | `lane-subcc-1/gates/diversity-v2/diversity-report.json` | `PASS` | `a92454693c60e3ce92a482db7832c90c4129ae5ba980f47bbb7c71a76c871c94` |
| C6 leakage | `lane-subcc-1/gates/c6-leakage-v2/c6-leakage-probe.json` | `pass` | `5430762aacc8a7951308e0d83df266e53175dcbddd7e05e5dec76e1ec50be6fa` |

## Documented Residual

`multi_call_pairing_floor(2)` is waived for batch-01, reason `pipeline_single_call_renderer_no_multi_recipe`. This is a documented residual, not a gate fail for this batch.

Evidence carried from lane rev3:

- `lane-subcc-1/generation_receipt.md:16` records the waiver.
- `lane-subcc-1/generation_receipt.md:20-22` records renderer/signature/DataGate residual scope.
- `lane-subcc-1/batch_self_audit.md:37-40` records the same renderer evidence and recovery condition.
- `lane-subcc-1/batch_manifest.json:64-72` records `multi_call_pairing_waiver`.

## Stop Condition

Mechanical gates are green after controller normalization. Next step is judge sampling/review; do not treat this receipt as training admission without judge acceptance and batch-level wave acceptance.

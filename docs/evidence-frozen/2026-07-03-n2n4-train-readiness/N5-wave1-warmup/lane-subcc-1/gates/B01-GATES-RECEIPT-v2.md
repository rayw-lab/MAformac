# B01 Mechanical Gates Receipt v2

status: BLOCKED_DATAGATE_TOOL_SCHEMA_DIGEST_MISMATCH  
proof_class: local/pre-training mechanical gates  
generated_at: 2026-07-03T06:21:48Z  
lane: subcc-1  
batch_id: warmup-batch-01  
lane_revision_observed: rev3  
code_face: `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge` `main@1526a26bab943d3aba0ae26bb430b74f6a60c4c2`  

## Rev3 Input Check

Rev3 source files before controller overlay:

```text
17f8dbe24d07fdb0b8fea7bcceb0101eb9f23cf87a88196b117974a102450e10  candidates.jsonl
5832fecb5d61a0eba4ee9f971d6cd0e088eb53fc781415abe153cb3f7f5d3bf1  value_change_ledger.jsonl
f0008f05af71502c2497f26029bed939e0893148d7b77e7ed40b80b43a046417  batch_manifest.json
be4df5ea294e1dc88b87fc8ee6b1ae8bddf04f8e1dc96a0a752533e110bcbb2f  batch_self_audit.md
a3561a83882460253c77a6dbd32b9eb4bc9bc9b467ab36718b9e37784b4ebf92  generation_receipt.md
```

After controller SHA injection:

```text
3866f8c60f77d8daabb16a2aa94512e8d53852a4fc3a4a224e22f652bea55316  batch_manifest.json
```

This `batch_manifest.json` SHA change is expected controller overlay, not a lane artifact mismatch.

## Controller Overlay

Command:

```bash
python3 tools/inject_controller_shas.py \
  --order batch-01-order.json \
  --builder-manifest builder-dryrun/wave1-warmup-batch-manifest.json \
  --lane-manifest lane-subcc-1/batch_manifest.json \
  --receipt lane-subcc-1/controller-sha-injection-receipt.json \
  --force
```

Injected fields:

```text
recipe_manifest_sha=sha256:83e8ad6a387d88e9d8f78adeedb878ac4e6a033ca6ee40538663fee4ac4a953f
quota_config_sha=sha256:011387d640046b0a5a77d6cbb702cc81548c652cc9ad04149c7af8601bf1de23
```

Injection receipt:

```text
/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/controller-sha-injection-receipt.json
sha256=3edd3a01b185d35b90ac009e476db1c4ce48cfc97d94048c7ec87024d9f645cf
```

Scope note: injection touched `batch_manifest.json`. Candidate row `recipe_manifest_sha` / `quota_config_sha` still remain `sha256:TODO`; this did not drive the current DataGate block, but remains a downstream contract residual if row-level SHA equality is required.

## Multi-Call Waiver

`multi_call_pairing_minimum=2` is waived for batch-01 and recorded as a documented residual, not a gate failure.

Evidence:

```text
/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/generation_receipt.md:16
/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/generation_receipt.md:20
/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/batch_self_audit.md:13
/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/batch_self_audit.md:37
/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/batch_manifest.json:58
/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/batch_manifest.json:66
/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/batch_manifest.json:69
```

Observed rev3 data:

```text
candidate rows=50
expected_tool_calls count distribution={1:50}
reason=pipeline_single_call_renderer_no_multi_recipe
restore_condition=multi-call support lands across renderer/signature recipe/DataGate semantics
```

## Gate Summary

| gate | command status | receipt status | key evidence |
|---|---:|---|---|
| C5DataGateCLI | exit 65 | `blocked` | `row_count=50`, `tool_call_format_pass=50`, `failure_receipt=50`, all `tool_schema_digest_mismatch` |
| diversity | exit 0 | `PASS` | `record_count=50`, missing_text=0, warning_pairs=0, severe_pairs=0 |
| C6 exact leakage probe | exit 0 | `pass` | `c6_case_id_intersection_count=0`, `c6_protected_case_id_intersection_count=0` |

Overall verdict is `BLOCKED` because DataGate is fail-closed.

## DataGate Root Cause Evidence

Candidate rows:

```text
subset_group_id=scene.scene1 count=50
tool_schema_digest=f3a9c49109ffb33b06d233038787ca1fdad8a750d7f7d9f917738c4a83878f61 count=50
```

Current main surface manifest:

```text
group_id=scene.scene1 subset_policy_id=e2-lite-v1
tool_schema_digest=0472db32779712dcb207f4dcc8ed35a387283a4381e42460284bea5704e2825e
```

DataGate failure:

```text
failure_count=50
reason=tool_schema_digest_mismatch
first_failure=warmup-batch-01-subcc-1-0001
```

## Receipt Paths

- DataGate JSON: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/datagate-v2/c5-data-gate-receipt.json`
- DataGate MD: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/datagate-v2/c5-data-gate-receipt.md`
- Diversity JSON: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/diversity-v2/diversity-report.json`
- Diversity MD: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/diversity-v2/diversity-report.md`
- C6 exact leakage JSON: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/c6-leakage-v2/c6-leakage-probe.json`

## Receipt SHA256

```text
e2e024c2cfc392e7bf2518bf96f4ec1085def5bdb57e43a712f19154d08c9d8b  gates/datagate-v2/c5-data-gate-receipt.json
12fab1f8977f69d7a36c023649eb0e865fec65a07b629780bab8d5f5d08d47ec  gates/datagate-v2/c5-data-gate-receipt.md
a92454693c60e3ce92a482db7832c90c4129ae5ba980f47bbb7c71a76c871c94  gates/diversity-v2/diversity-report.json
11f3442907b6f4fa591e1e804ca94acc2cd796d7ac139261199206db1b4c82ed  gates/diversity-v2/diversity-report.md
5430762aacc8a7951308e0d83df266e53175dcbddd7e05e5dec76e1ec50be6fa  gates/c6-leakage-v2/c6-leakage-probe.json
```

## Gate Commands

```bash
swift run C5DataGateCLI \
  --candidates /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/candidates.jsonl \
  --source-digest-path /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/candidates.jsonl \
  --source-digest-path /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/value_change_ledger.jsonl \
  --source-digest-path /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/batch_manifest.json \
  --source-digest-path /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/generation_receipt.md \
  --source-digest-path /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/SHA256SUMS.txt \
  --source-digest-path /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/controller-sha-injection-receipt.json \
  --source-authorization authorized_wave1_warmup_generation_controller_sha_injected \
  --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/datagate-v2
```

```bash
python3 /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/tools/canary_diversity_check.py \
  --input /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/candidates.jsonl \
  --output-md /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/diversity-v2/diversity-report.md \
  --output-json /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/diversity-v2/diversity-report.json
```

```bash
python3 /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/tools/canary_c6_leakage_probe.py \
  --canary-jsonl /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/candidates.jsonl \
  --c6-jsonl /Users/wanglei/workspace/MAformac-p5w-wave1-bridge/contracts/c6-bench-cases.jsonl \
  --output /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/c6-leakage-v2/c6-leakage-probe.json
```

## Next

Do not send this batch to judge yet. The remaining blocker is current-main `tool_schema_digest` reconciliation: candidate rows use `f3a9...`, while DataGate's active surface manifest expects `0472...` for `scene.scene1/e2-lite-v1`.

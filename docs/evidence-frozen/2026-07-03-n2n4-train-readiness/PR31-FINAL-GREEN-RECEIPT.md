# PR31 final N4A recipe rebuild receipt

status: pr31_final_green_for_merge_precondition
proof_class: local
code_head: `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge` `9ad6ff2dbea46cf52d75f8b548188844139253b1`
generated_at: 2026-07-03

## Verdict

PASS for the requested PR31 merge precondition.

The N4A recipe was rebuilt on the 9ad6ff2d code face with the zero-refusal N4A knob explicitly enabled via `--theta-alpha-positive-only`, which is the current CLI's only exposed switch that sets `refusalRatioTarget=0`, `refusalRatioHardCap=0`, and `includeNoCallCounterfactuals=false`.

Hard gates:

- strict preflight: exit 0
- C5DataGate: exit 0, `status=data_gate_ready`
- requested N4A recipe fields: matched, with no unexpected diff

Note: `C5TrainingCLI prepare` still exits 65 because the broader prepare receipt status is `blocked`, matching the known N4A child-gate debt pattern. This receipt does not upgrade that broader status to training authorization.

## Artifacts

- Final build dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build`
- Final training receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build/c5-training-receipt.md`
- Final training receipt JSON: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build/c5-training-receipt.json`
- Strict preflight metrics: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-preflight.metrics.jsonl`
- DataGate receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-datagate/c5-data-gate-receipt.md`
- DataGate receipt JSON: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-datagate/c5-data-gate-receipt.json`
- Baseline N4A receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/n4a-wave1-proto-build/c5-training-receipt.md`

## Commands

Prepare command:

```bash
swift run C5TrainingCLI prepare \
  --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build \
  --target-positive 4500 \
  --dev-selection 400 \
  --masking-stage trainable_v0 \
  --theta-alpha-positive-only \
  --scope demo \
  --surface d_domain
```

Prepare result:

```text
status=blocked rows=4500 train_eligible=4100 smoke_chain_records=0 dev_selection=400 refusal_ratio=0.000
```

Strict preflight command:

```bash
/opt/homebrew/opt/python@3.13/bin/python3.13 \
  /Users/wanglei/workspace/MAformac-p5w-wave1-bridge/Tools/C5TrainingCLI/c5_mlx_train_loop.py \
  --train \
  --preflight-only \
  --model /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build/qwen3-1_7b-training-tokenizer-patched \
  --data /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build/mlx-data \
  --config /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build/mlx-lora-config.yaml \
  --require-maformac-loss-mask \
  --max-seq-length 8192 \
  --metrics-jsonl /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-preflight.metrics.jsonl
```

Strict preflight result:

```text
exit=0
MAformac token loss_mask preflight records=4628 trainable_records=4628 trainable_tokens=113914 ignored_tokens=15802533
```

DataGate command:

```bash
swift run C5DataGateCLI \
  --repo-root /Users/wanglei/workspace/MAformac-p5w-wave1-bridge \
  --candidates /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build/samples/c5-training-samples.jsonl \
  --source-digest-path /Users/wanglei/workspace/MAformac-p5w-wave1-bridge/contracts/semantic-function-contract.jsonl \
  --source-authorization authorized_c1_semantic_contract \
  --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-datagate
```

DataGate result:

```text
exit=0
status=data_gate_ready rows=4500 must_not_train_violations=0 train_parent_semantic_overlap=0 quarantine=0
```

## Field Reconciliation

| Field | N4A baseline | PR31 final rebuild | Verdict | Explanation |
| --- | ---: | ---: | --- | --- |
| `row_count` | 4500 | 4500 | match | Final rebuild used `--target-positive 4500`, not the earlier incorrect `4100`. |
| `train_eligible_count` | 4100 | 4100 | match | 4500 positives minus 400 `dev_selection`. |
| `dev_selection_count` | 400 | 400 | match | Same explicit `--dev-selection 400`. |
| DataGate bucket counts | `dev_selection=400, train=4100` | `dev_selection=400, train=4100` | match | Final DataGate receipt lines 11-12. |
| `refusal_ratio_target` | 0.0 | 0.0 | match | Explicit `--theta-alpha-positive-only` overrides CLI default target 0.10. |
| `refusal_ratio_hard_cap` | 0.0 | 0.0 | match | Same zero-refusal knob. |
| `refusal_ratio_observed` | 0.0000 | 0.0000 | match | No no-call rows generated. |
| `no_call_counterfactual_count` | 0 | 0 | match | Confirms no refusal/no-call activation. |
| `route_tier_counts` | `fc_l2=2845, fc_l3=948, rule_l1=307` | `fc_l2=2845, fc_l3=948, rule_l1=307` | match | Same N4A recipe shape. |
| `masking_stage_counts` | `trainable_v0=4500` | `trainable_v0=4500` | match | Same masking stage. |
| `rehearsal_ratio` | `0.0748780487804878` | `0.0748780487804878` | match | Same rule rehearsal mix. |
| `prompt_distractor_count` | 12892 | 12892 | match | Same mounted distractor count at sample layer. |

Baseline anchors:

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/n4a-wave1-proto-build/c5-training-receipt.md:9-18`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/n4a-wave1-proto-build/c5-training-receipt.json:2958-2960`

Final anchors:

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-build/c5-training-receipt.md:13-24`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-datagate/c5-data-gate-receipt.md:11-24`

## E-2 Group Check

E-2 group is `seat.massage_force_time`.

| Field | N4A baseline | PR31 final rebuild | Verdict | Explanation |
| --- | ---: | ---: | --- | --- |
| sample rows in `seat.massage_force_time` | 304 | 304 | match | Same subset group sample coverage. |
| MLX records in E-2 group | 314 | 314 | match | `train=294`, `valid=10`, `test=10`; test duplicates first dev rows by design. |
| E-2 max token length | 1326 | 1326 | match | Far below `max_seq_length=8192`; downgrade remains bounded. |
| `loss_objective_profile` coverage | 0/314 | 314/314 `assistant_full_except_think` | expected | New main contract requires this top-level field; old baseline data predates it. |
| `trainable_assistant_end_token` coverage | 0/314 | 314/314 `<|im_end|>` | expected | New main contract requires assistant end-token supervision; old baseline data predates it. |

E-2 computation command used current tokenizer and the repo training loop tokenization helper:

```bash
/opt/homebrew/opt/python@3.13/bin/python3.13 - <<'PY'
# maps mlx-data rows back to samples by prepare write order, then filters subset_group_id == "seat.massage_force_time"
PY
```

## Strict Preflight Summary

From `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PR31-final-n4a-recipe-preflight.metrics.jsonl`:

| Split | records | trainable_records | assistant_end_token_supervised_records | max_token_length |
| --- | ---: | ---: | ---: | ---: |
| train | 4100 | 4100 | 4100 | 7185 |
| valid | 400 | 400 | 400 | 7179 |
| test | 128 | 128 | 128 | 7179 |
| total | 4628 | 4628 | 4628 | 7185 |

Other strict preflight fields:

- `length_violations=[]`
- `legacy_loss_objective_record_count=0`
- `legacy_loss_objective_allowed=false`
- `supervision_coverage_digest.parser_critical_status=pass`
- `supervision_coverage_digest.ratio_status=pass`
- `supervision_coverage_digest.min_trainable_non_think_ratio=1.0`

## Expected Differences

These are expected deltas from rebuilding on the hardened main contract:

1. New `c5-training-receipt.md` includes the hardened consumed artifact contract: `loss_objective_profile + loss_mask.trainable_spans + loss_mask.masked_think_spans + loss_mask.trainable_assistant_end_token`.
2. Final MLX records include `sample_id`, `loss_objective_profile`, `augmentation_profile`, and `loss_mask.trainable_assistant_end_token`; old N4A `mlx-data` did not.
3. Preflight trainable token count increased versus old N4A metrics because assistant end-token supervision is now token-labeled and the stricter coverage path is active.
4. Offset fixture path and SHA differ because the artifact was regenerated under `PR31-final-n4a-recipe-build/`.
5. `repo_commit_sha`, generated timestamp, and training-loop source hash differ because this is a 9ad6ff2d rebuild.

No unexpected diff was found in requested merge-precondition fields.

## P1 Follow-Up

P1 footgun: `C5TrainingCLI prepare` defaults to `refusalRatioTarget=0.10` unless `--theta-alpha-positive-only` is passed. That conflicts with the D-042 / N4A zero-refusal lock (`refusal_ratio_target=0.0`) when an operator rebuilds wave-1 without the controller recipe in hand.

Recommendation: wave-1 controller manifest should make the locked refusal ratio explicit and derive CLI arguments from the manifest instead of relying on human memory. This belongs under the N5E-003 SSOT / recipe manifest scope. This receipt does not self-authorize that code change.


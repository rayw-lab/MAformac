---
artifact_kind: wave1_proto_build_receipt
status: PARTIAL
proof_class:
  - local_build
  - local_cli
  - local_preflight
created: 2026-07-03
worktree: /Users/wanglei/workspace/MAformac-p12-loss-contract
branch: codex/p12-v61-eos-span-20260703
output_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/wave1-proto-build
not_claimed:
  - live cloud generation
  - training run
  - train-ready
  - model-quality or C6 acceptance
  - mobile/true-device acceptance
---

# Wave-1 Proto Build Receipt

## Conclusion

Maximum local兑现完成：A+ builder 全量 demo-scope 协议串 build 已跑完，独立 C5DataGate 全量实跑通过；MLX `--preflight-loss-mask-only` 全量实跑失败。因此本产物是 wave-1 协议串底座 + 数据门全量首跑证据，不是 train-ready。

## Output Files

- `wave1-proto-build/c5-training-receipt.json`
- `wave1-proto-build/c5-training-receipt.md`
- `wave1-proto-build/samples/c5-training-samples.jsonl`
- `wave1-proto-build/mlx-data/train.jsonl`
- `wave1-proto-build/mlx-data/valid.jsonl`
- `wave1-proto-build/mlx-data/test.jsonl`
- `wave1-proto-build/c5-data-gate/c5-data-gate-receipt.json`
- `wave1-proto-build/c5-data-gate/c5-data-gate-receipt.md`
- `wave1-proto-build/loss-mask-preflight.strict.log`
- `wave1-proto-build/loss-mask-preflight-summary.json`
- `wave1-proto-build/wave1-proto-coverage-summary.json`
- `wave1-proto-build/wave1-proto-c6-leakage-probe.json`
- `wave1-proto-build/prepare.log`
- `wave1-proto-build/c5-data-gate.log`
- `wave1-proto-build/mlx-lora-config.yaml`
- `wave1-proto-build/mlx-train-command.txt` (rendered only; not executed)

## Commands

```bash
swift run C5TrainingCLI prepare \
  --repo-root /Users/wanglei/workspace/MAformac-p12-loss-contract \
  --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/wave1-proto-build \
  --target-positive 4500 \
  --dev-selection 400 \
  --theta-alpha-positive-only \
  --scope demo \
  --surface d_domain
```

```bash
swift run C5DataGateCLI \
  --repo-root /Users/wanglei/workspace/MAformac-p12-loss-contract \
  --candidates /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/wave1-proto-build/samples/c5-training-samples.jsonl \
  --source-authorization authorized_c1_semantic_contract \
  --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/wave1-proto-build/c5-data-gate
```

```bash
/opt/homebrew/opt/python@3.13/bin/python3.13 \
  /Users/wanglei/workspace/MAformac-p12-loss-contract/Tools/C5TrainingCLI/c5_mlx_train_loop.py \
  --model /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/wave1-proto-build/qwen3-1_7b-training-tokenizer-patched \
  --data /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/wave1-proto-build/mlx-data \
  --config /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/wave1-proto-build/mlx-lora-config.yaml \
  --require-maformac-loss-mask \
  --preflight-loss-mask-only \
  --max-seq-length 8192
```

## Evidence Table

| Claim | Evidence | Result |
|---|---|---|
| Prepare build completed without training | `prepare.log`: wrote `c5-training-receipt.json` and `mlx-data/train.jsonl`; time `real 38.82` | PASS |
| Builder row counts | `wc -l`: samples=4500, train=4100, valid=400, test=128 | PASS |
| Builder receipt status | `c5-training-receipt.json`: status=`blocked`; data_gate_status=`data_gate_ready`; failures=`training_loop_source_unverified`, `cloud_multi_source_generator_not_run`, `multi_source_generator_diversity_missing`, `cross_vendor_semantic_judge_not_run` | BLOCKED as expected for no cloud/no training |
| Tool coverage breadth | `wave1-proto-coverage-summary.json`: expected tool names=314/562 (55.8719%); mounted tool names=395/562 (70.2847%); subset groups=55; tools/row min=1 avg=14.5089 max=48 | OBSERVED |
| C5DataGate full run | `c5-data-gate-receipt.json`: status=`data_gate_ready`, row_count=4500, must_not_train=0, train_parent_semantic_overlap=0, tool_call_format_failures=0, redaction=pass, quarantine=0, failure_count=0 | PASS |
| Held-out axis hard counts | `c5-data-gate-receipt.json`: parent/device/tool/value_type/template_family/generator_source train_overlap_count all 0; row overlap count 0 | PASS |
| C6 leakage spot check | `wave1-proto-c6-leakage-probe.json`: c6_case_count=57, sample_case_id_count=4500, c6_case_id_intersection_count=0 | PASS |
| Loss-mask preflight command truth | strict rerun exited 66; `loss-mask-preflight-summary.json`: status=`failed_exit_66` | FAIL |
| Loss-mask token length distribution | `loss-mask-preflight-summary.json`: records=4628, trainable_records=4100, max_seq_length=8192, max_token_length=8982, length_violation_count=294 | FAIL |
| Loss-mask split details | train: records=4100/trainable_tokens=101549/ignored_tokens=16485274/max_token_length=8982; valid: 400 records, trainable_tokens=0; test: 128 records, trainable_tokens=0 | OBSERVED |

## Residual Risk

- The build is protocol-string only. It does not include live cloud generator natural utterances or cross-vendor semantic judge outputs.
- The independent DataGate is green, but builder receipt remains blocked by expected non-run gates: cloud multi-source generator, cross-vendor judge, and training-loop source verification.
- MLX loss-mask preflight is a real blocker before training: valid/test rows are under-supervised under the current preflight contract, and 294 train rows exceed `max_seq_length=8192` with max token length 8982.
- Tool target coverage is partial: 314/562 expected tool names in this 4500-row build. Mounted subset exposure is broader at 395/562, but this is not equivalent to target supervision coverage.
- No model training, adapter generation, C6 model-quality evaluation, live generation, or device acceptance was run.

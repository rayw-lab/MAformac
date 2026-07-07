# RERENDER-READY Receipt

status: RERENDER_READY_LOCAL
date: 2026-07-03
scope: R2-1 renderUserUtterance polarity repair + seeded tool mount shuffle
proof_class: local

## Conclusion

R2-1 重渲染链路已本地通过。新 `samples/c5-training-samples.jsonl` 全量 4500 行，supervision consistency scanner fail-closed 复扫为 `pass_no_contradictions`，矛盾组 0；mount order gate 为 `pass`，行级 `mount_order_strategy=seeded_shuffle` 已写入样本。

本 receipt 不声称训练完成，不运行 optimizer，不改 F044 训练结果。

## Changed Surfaces

仓内：
- `/Users/wanglei/workspace/MAformac/Core/Training/C5LoRATraining.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/C5LoRATrainingTests.swift`

仓外 run 工具：
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/tools/supervision_consistency_scanner.py`

产物：
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/samples-rerendered/samples/c5-training-samples.jsonl`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/samples-rerendered/mlx-data/train.jsonl`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/samples-rerendered/supervision-consistency-summary.json`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/samples-rerendered/mount-order-balance-report.json`

## Render Changes

- protocol user 串在 `primitive` 后插入 `action=<action_code>`。
- `action_code` 为空时 fallback 到 intent 首段，例如 `pause_seat_mode -> action=pause`、`save_seat_mode -> action=save`。
- 当 `intent` 极性前缀与非空 `action_code` 极性前缀冲突时，用 intent 极性前缀纠正 action，例如 `intent=open_fragrance/action_code=close_mode -> action=open_mode`。
- tools mount 按 `sample_id|tool_name` sha256 稳定排序；样本行写入 `mount_order_strategy=seeded_shuffle`。

## 5-Line Before/After Examples

| sample_id | expected_tool | before user | after user | strategy |
|---|---|---|---|---|
| `c5-train-00001` | `open_ac_cooling_mode` | `device=ac_cooling_mode; primitive=set_mode; slots=no_slots; 请按这个语义执行` | `device=ac_cooling_mode; primitive=set_mode; action=open_mode; slots=no_slots; 请按这个语义执行` | `seeded_shuffle` |
| `c5-train-00004` | `open_ac_cooling_mode` | `device=ac_cooling_mode; primitive=set_mode; slots=direction:主驾+modeValue:快速; 请按这个语义执行` | `device=ac_cooling_mode; primitive=set_mode; action=open_position_mode; slots=direction:主驾+modeValue:快速; 请按这个语义执行` | `seeded_shuffle` |
| `c5-train-01677` | `open_fragrance` | `device=fragrance; primitive=set_mode; slots=mode:若云模式; 请按这个语义执行` | `device=fragrance; primitive=set_mode; action=open_mode; slots=mode:若云模式; 请按这个语义执行` | `seeded_shuffle` |
| `c5-train-04386` | `pause_seat_mode` | `device=seat_mode; primitive=set_mode; slots=mode:座椅记忆模式+modeValue:位置1; 请按这个语义执行` | `device=seat_mode; primitive=set_mode; action=pause; slots=mode:座椅记忆模式+modeValue:位置1; 请按这个语义执行` | `seeded_shuffle` |
| `c5-train-04394` | `save_seat_mode` | `device=seat_mode; primitive=set_mode; slots=mode:座椅记忆模式+modeValue:位置1; 请按这个语义执行` | `device=seat_mode; primitive=set_mode; action=save; slots=mode:座椅记忆模式+modeValue:位置1; 请按这个语义执行` | `seeded_shuffle` |

## Validation

Swift tests:

```bash
swift test --filter C5LoRATrainingTests
```

Result: 44 tests, 0 failures.

Scanner compile:

```bash
python3 -m py_compile /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/tools/supervision_consistency_scanner.py
```

Result: exit 0.

Full rerender:

```bash
swift run C5TrainingCLI prepare \
  --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/samples-rerendered \
  --target-positive 4500 \
  --dev-selection 400 \
  --masking-stage trainable_v0 \
  --theta-alpha-positive-only \
  --scope demo \
  --surface d_domain
```

Result: exit 0; `status=step2_dry_run_ready rows=4500 train_eligible=4100 smoke_chain_records=0 dev_selection=400 refusal_ratio=0.000`.

Supervision + mount order fail-closed scan:

```bash
/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/tools/supervision_consistency_scanner.py \
  --input /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/samples-rerendered/samples/c5-training-samples.jsonl \
  --output /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/samples-rerendered/supervision-consistency-contradictions.jsonl \
  --summary-json /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/samples-rerendered/supervision-consistency-summary.json \
  --mount-order-report-json /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-fix/samples-rerendered/mount-order-balance-report.json \
  --fail-on-contradiction \
  --fail-on-mount-order
```

Result: exit 0; `contradiction_group_count=0`, `contradiction_row_count=0`, `mount_order_status=pass`, `unbalanced_mount_order_pair_count=0`.

Line counts:

```text
samples/c5-training-samples.jsonl 4500
mlx-data/train.jsonl 4100
mlx-data/valid.jsonl 400
mlx-data/test.jsonl 128
```

Hashes:

```text
samples/c5-training-samples.jsonl sha256=67b7da15b17ab0515419a9dcd819f34a1bc7f14133c48754e79029665b14fc07
c5-training-receipt.json sha256=a158aaafb58f6457caf0094623bb6ba75bc90d21fd48c505af92de8bb35eb833
```

GitNexus:

```text
pre-change impact(renderUserUtterance): LOW; direct caller makePositiveSample; upstream buildPositiveSamples/build.
pre-change impact(makePositiveSample): LOW; upstream build path only.
pre-change impact(C5TrainingSample): LOW; upstream makePositiveSample path only.
detect_changes: HIGH on whole dirty tree; repo dirty tree included pre-existing unrelated docs. Changed symbols relevant to this receipt are C5 training renderer/sample/builder and C5 tests.
```

## Residual Risk

- `C5TrainingCLI prepare` status remains `step2_dry_run_ready`; this is a data/render readiness receipt, not formal training authorization.
- `missing_sibling_mount_rows=2063` remains informational in mount report because `mount_order_strategy=seeded_shuffle` is the accepted row-level strategy for this run.
- Pre-existing repo dirty files outside this scope were not modified by this receipt.

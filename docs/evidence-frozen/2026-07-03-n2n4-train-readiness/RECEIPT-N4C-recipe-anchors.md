# RECEIPT N4C recipe anchors vs grill

status: DONE
proof_class: local/local_mock
captured_at_utc: 2026-07-02T23:37:09Z
worktree: /Users/wanglei/workspace/MAformac-p5w-wave1-bridge
branch: codex/p5w-e2-downgrade-valid-supervision-20260703
commit: 722644d4

## Conclusion

N4c 完成。先做 Task1 grill recall，再只实装一致项/空白项的配置面：Gate7 生成侧 recipe quota anchors 进入显式配置 + mock dry-run receipt；C5 训练配置侧 early-stop/checkpoint anchor 进入 `C5MLXLoRAConfig` + YAML 注释 + prepare receipt 渲染。

未做且不得冒充：未启用 refusal/unsupported/safety 负例训练配额；未真生成；未训练；未做模型质量、C6 acceptance 或 V-PASS 声称。

## Task1 recall table

| 配方锚 | 命中的已锁/半锁决策 | 判定 | 本轮处理 |
| --- | --- | --- | --- |
| open/close 极性对称配比 | 未找到专门 open/close 锁值；相邻锁值是 value-form 覆盖防“只会打开/关闭”（`docs/c5-training-readiness-grill/gate7-cloud-generator-design.md:218`）和 D-096/097 quota 主轴 | grill 空白，可按 SPEC 锚实装配置面 | `openClosePolarityMinPerDirection=1` 显式配置，不生成数据 |
| query/refusal/unsupported 负例配额 | D-085/D-086 proposed 要四类数据配比和 negative cap（`worker-1-data-round2.md:56-57`）；但当前 proto receipt 锁 `refusal_ratio_target=0.0`、`hard_cap=0.0`（`runs/tiny.../wave1-proto-build/c5-training-receipt.md:22-23`；N4a build `:17-18`） | 冲突需上抛；不得自拍改锁值 | 只把 negative quota 字段显式置 `0`，`negativeQuotaActivation=deferred_refusal_ratio_zero_conflict` |
| 多 call 配对样本量保障 | E-102/E-103 多意图/multi-action trap 是 eval 侧 proposed；E-2 也要求 C5 不训单句 multi-intent | 空白/部分，按锚做 config surface | `multiCallPairingMinimum=2` 显式配置；只 dry-run receipt 可见 |
| epoch/early-stop 配置锚 | grill-master Q06/D1 cell 拍 50/100/150 multi-checkpoint，但阈值/抽样轴仍部分待 grill（`docs/grill-tournament/grill-decisions-master.md:61`）；A-058 3 epoch 是候选上限，checkpoint 由 task metric 选（`worker-2-algo-round2.md:23`） | 一致可实装配置面；阈值不上锁 | `earlyStopBasis=task_metric_checkpoint_gate_not_val_loss`，checkpoints `[50,100,150]`，policy human-pause |

Additional authority facts:

- D-010 locked D-096/097 quota formula + D-098/E-113 sparse scene-trigger + E-100/124 failure not action-train: `docs/c5-training-readiness-grill/landing-matrix.md:68-70`.
- Gate7 §10.4 says future true generation quota formula is R7 BLOCKED, not runnable now: `docs/c5-training-readiness-grill/gate7-cloud-generator-design.md:446-447`.
- Gate7 §10.5 maps failure/unsupported/safety to C6/eval layers: `docs/c5-training-readiness-grill/gate7-cloud-generator-design.md:449-450`.
- SPEC mentioned `docs/c5-training-readiness-grill/f044-default-lock-and-wave1-recipe-anchors-2026-07-03.md`, but this exact file is absent in the current worktree; current `F-044` in repo is tiny-ablation裁决门, not a recipe-anchor file.

## Implementation diff

- `Core/Generation/Gate7GeneratorPipeline.swift`
  - `Gate7RecipeQuotaConfig` adds explicit recipe fields: quota source, open/close polarity floor, query/unsupported/safety quota fields, negative activation, multi-call pairing minimum (`:727-770`).
  - `Gate7QuotaCalculator.allocate` now includes polarity/multi-call/active-negative components and carries quota source/negative activation (`:780-810`).
- `Tools/Gate7DryRunCLI/main.swift`
  - mock dry-run builds `Gate7RecipeQuotaConfig.wave1ConstructionAnchors` and writes fields into receipt (`:81-91`, `:254-261`).
- `Core/Training/C5LoRATraining.swift`
  - `C5MLXLoRAConfig` adds `earlyStopBasis`, `earlyStopCheckpointSteps`, `earlyStopPolicy` as Codable fields (`:1238-1271`, `:1301-1303`).
  - `renderYAML` emits early-stop anchors as comments, avoiding unknown executable mlx-lm parameters (`:1458-1464`).
- `Tools/C5TrainingCLI/main.swift`
  - prepare markdown receipt now shows early-stop fields (`:282-284`).
- Tests lock both surfaces: `Gate7GeneratorPipelineTests.swift:284-310`; `C5LoRATrainingTests.swift:857-892`.

## Validation

```bash
swift test --filter Gate7GeneratorPipelineTests
```

Result: 11 tests, 0 failures.

```bash
swift test --filter C5LoRATrainingTests
```

Result: 55 tests, 0 failures.

```bash
swift run Gate7DryRunCLI \
  --repo-root /Users/wanglei/workspace/MAformac-p5w-wave1-bridge \
  --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N4C-gate7-dry-run \
  --limit 6
```

Result: exit0, `pipeline_status: PASS`, `data_gate_status: data_gate_ready`, no live cloud generation and no training.

Dry-run receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N4C-gate7-dry-run/gate7-wave1-dry-run-receipt.md`

- line 11: `pipeline_status: PASS`
- line 29: `data_gate_missing_surface_count: 0`
- line 34: `recipe_quota_source: intent_bug_scene_recovery`
- line 37: `recipe_negative_quota_activation: deferred_refusal_ratio_zero_conflict`
- line 38-40: query/unsupported/safety quota all `0`
- line 41: `recipe_multi_call_pairing_minimum: 2`

GitNexus:

- `impact(C5MLXLoRAConfig)`: LOW, direct 1, affected processes 0.
- `impact(rank16Mainline)`: LOW, direct 2, affected processes 0.
- `detect_changes(scope=all)`: LOW, changed files 6, affected processes 0.
- Caveat: index is stale and did not resolve newer Gate7 symbols; repo diff + tests are the controlling evidence.

## Conflict / upward items

1. `query/refusal/unsupported` negative quota cannot be activated against current `refusal_ratio_target=0.0` / `refusal_ratio_hard_cap=0.0` without commander/owner裁决.
2. `F044 default lock recipe anchor` source filename is absent in this worktree; SPEC supplied the four anchors and is used as task authority, but repo should later reconcile the missing/misnamed doc.
3. early-stop concrete threshold/axis is still only partially decided in grill-master Q06; this commit records checkpoint/policy anchors, not executable stop criteria.

## Residual

- local/local_mock proof only.
- no true generation, no training, no model-quality claim, no C6 acceptance.
- pushed branch: `origin/codex/p5w-e2-downgrade-valid-supervision-20260703`
- PR: https://github.com/rayw-lab/MAformac/pull/31

## Context

C6 是 MAformac 的全集覆盖率双轴 bench：用中文文本 / normalized transcript 输入，跑 runtime 到 ToolCall、mock state、readback、clarify/refusal 文本，再用确定性硬门 + 可复现指纹判断 base Qwen3-1.7B 与后续 LoRA checkpoint 的真实差异。

本 propose 从 parked `define-vehicle-tool-bench` rebase 到当前事实源：

- C1: `openspec/specs/semantic-function-contract/spec.md` + `contracts/semantic-function-contract.jsonl`，3990 行全集语义契约。
- C2: `openspec/specs/scenario-state-protocol/spec.md` + `contracts/state-cells.yaml`，mock state 与 execution_range 权威。
- Seed: `contracts/demo-scenarios.yaml`，状态为 `c6_seed_interim`，只作为 C6 dataset 的种子，不直接修改。
- L1/risk: `contracts/l1-demo-allowlist.yaml` + `contracts/risk-policy.yaml`。
- #39: `contracts/qwen-tool-call-format.yaml`，C3 runtime / C5 data / C6 bench 的 tool-call 格式单一源。
- Grill source: `docs/优化待讨论-吸收内化措施38项-2026-06-20.md` Q3/Q4/Q5 + #19-26 + #39/#40 + 三刀顺序。
- Mastra teardown: `docs/research/2026-06-20-mastra-teardown-workflow-eval-trace.md` B/C 段。

## Goals / Non-Goals

**Goals**

- 建立 C6 apply 的行为契约：dataset schema、硬门、judge 边界、replay 指纹、base baseline、coverage + scenario score 双轴。
- 把 C6 和 C5 解耦：C6 先跑 base Qwen3-1.7B 无 LoRA 建基线，C5 后续 checkpoint 只用同 harness 做 diff。
- 把 `expect_no_call`、state_delta + readback、clarify/refusal 全部放进一等硬门，防只看 ToolCall AST 的假绿。
- 保留 Mastra eval 工程形态，不把 Node runtime 或自由 agent loop 带进 MAformac。

**Non-Goals**

- 不写实现代码，不 apply，不创建 `contracts/c6-bench-cases.jsonl`。
- 不修改 archive specs 或 C1/C2 contract artifacts。
- 不把 ASR、TTS 听感、iOS runtime 纳入 C6 自动硬门。
- 不用 LLM judge 判 ToolCall/state/readback/no-call 硬门。

## Research Inputs

| source_doc | adopted_rules | deferred_gates |
|---|---|---|
| `docs/优化待讨论-吸收内化措施38项-2026-06-20.md` #19-26/Q3/Q4/Q5/#39/#40 | 四类确定性硬门；judge 只评 clarify/refusal 文本；TTS 归人；eval_run 指纹；bench 引用 `qwen-tool-call-format.yaml`；base baseline 先行 | dataset 规模、IrrelAcc 阈值、format version 取值 |
| `docs/research/2026-06-20-mastra-teardown-workflow-eval-trace.md:25-44` | TrajectoryExpectation 形态；dataset + 有界并发；ScoreAccumulator 多桶；结构化 failure；scorer 四阶段 pipeline | 不引入 Mastra/Node runtime |
| `docs/research/2026-06-20-mastra-teardown-workflow-eval-trace.md:48-59` | runId + traceId/spanId 并存；span 树；强类型 attributes；internal 分层 | C3/C6 trace 实现字段由 apply 定 |
| `docs/srd-three-layer-intent-routing.md §8 + :50-58` | C6 评测看路由/ToolCall/参数/读回态/拒识；**clarify_tag 五枚举（explicit/implicit/ambiguous/rejected/passthrough）权威源**（C1 jsonl 冻结快照只产 implicit/explicit 2 值，其余 3 值是运行态路由分类、dataset 派生才出，**非悬空**） | C4 route_kind 完整 schema 由 C4 change 定 |
| Mastra docs `runEvals` / trajectory accuracy | 验证当前 Mastra 仍以 batch eval、expectedTrajectory、trace-based trajectory extraction 为主形态 | 只借形态，不依赖外部库 |

## Decisions

### 1. C6 输入边界：文本 / normalized transcript，不依赖 ASR

C6 的输入是 `input_zh`。未来 C7 可把 ASR 产出的 normalized transcript 交给 C6 复测，但 C6 不评价音频、端点检测、ASR 置信度、噪声鲁棒性。这样 C6 能先于 C7 建立 LoRA/runtime 评测基线。

### 2. C6 dataset 是新派生产物，目标路径只声明

正式 dataset 目标路径为 `contracts/c6-bench-cases.jsonl`。本刀 propose 只声明路径和 schema，不创建文件，避免违反“不动 contracts”红线。apply 阶段从 C1/C2 + demo seed 派生：

```yaml
case:
  case_id: string
  source_refs:
    semantic_contract_ids: [string]
    scenario_id: string?
    beat_id: string?
  tags:
    must_pass: boolean
    must_not_train: boolean
    bucket: action | no_call | state | clarify | refusal | coverage
  pre_state: object
  input_zh: string
  expected_tool_calls: array
  expect_no_call: boolean
  expected_state_delta: object
  readback_assertion: object
  clarify_tag: explicit | implicit | ambiguous | rejected | passthrough
  failure_class: enum
```

### 3. 四类硬门是 release-blocking，judge 不参与

硬门顺序：

1. ToolCall 集合匹配：工具名、参数、缺失、额外、重复调用。
2. `expect_no_call`：no-tool false positive 必须为 0。
3. `expected_state_delta + readback_assertion`：mock state 与读回都要匹配。
4. 澄清正确性：该澄清/拒识时不能执行或假成功。

任一硬门失败，case 为 hard failure。judge 分数只能附加说明主观文本质量，不能洗白。

### 4. Runner 指标分硬门指标与 summary 指标

Runner 至少输出：

- 硬门指标：`tool_call_set_match`、`no_tool_false_positive_count`、`state_delta_match`、`readback_match`、`clarify_match`。
- 拒识指标：`IrrelAcc`。
- 双轴 summary：`contract_coverage_score` 与 `scenario_score`。
- 稳定性：每 case 多跑配置与均值 / 标准差，防单跑误判。

`no-call / 无关样本占比 >=20%` 是 dataset composition gate。它不是 IrrelAcc passing threshold；IrrelAcc 阈值另拍，且应高。

### 5. `qwen-tool-call-format.yaml` 是 bench 格式单一源

C6 不得另写 chat template / wrapper / arguments shape。apply 阶段应计算 `qwen_tool_call_format_version`，候选为文件内容 hash、git commit hash、或显式版本字段。具体取值留 Open Question。

### 6. Replay 指纹按 eval_run 记录

每条结果记录：

```yaml
eval_run:
  run_id: string
  case_id: string
  model_id: string
  lora_adapter_id: string
  lora_checkpoint_id: string
  qwen_tool_call_format_version: string
  prompt_hash: string
  sampling_seed: string
  tool_output_digest: string
  contract_digest: string
```

这些字段挂到 Q1 runId trace 树。这样 base vs LoRA、checkpoint A vs B、prompt 变更、format 合同变更、C1/C2 合同变更都能定位。

### 7. Base baseline 先于 C5 LoRA diff

C6 apply 的第一轮有效运行必须是 base Qwen3-1.7B，无 LoRA，`lora_adapter_id=""`，`lora_checkpoint_id=""`。C5 checkpoint 之后再跑同 dataset、同 prompt policy、同 parser、同 mock state、同 scorer。没有 base baseline，不得声称 LoRA 提升。

### 8. Must-pass 与训练集隔离

C6 demo must-pass 子集标 `must_not_train`。C5 数据生成必须能读到该标记并在自己的 receipt 中报 `must_not_train_violations=0`。C6 侧保留 case identity 与 source_refs，便于 leakage 检查。

### 9. Mastra eval 形态 adopt，不引入不适用 runtime

采纳形态：

- `TrajectoryExpectation`: steps + args / ordering / blacklistedTools / noRedundantCalls / maxSteps。
- dataset + 有界并发：逐 case 执行，逐 case 累加，不静默吞 failure。
- ScoreAccumulator：coverage 与 scenario 两桶分别汇总。
- scorer 四阶段 pipeline：`preprocess -> analyze -> score -> reason`，给 judge 文本维度留位。
- trace-based extraction：从 C3/C6 run tree 抽实际 ToolCall sequence。

不采纳：

- Node/Mastra runtime 进 app。
- 自由 agent loop。
- 让 judge 或模型决定硬门。

## Failure Modes / Pre-Mortem

### Tiger: judge 洗白硬门失败

若 judge 参与 release blocking，ToolCall/state/readback/no-call 错误会被“话术好听”掩盖。Mitigation：spec 明确 judge 只在硬门全过后运行，输出只含 `clarify_text_score / refusal_text_score / reason`。

### Tiger: C6 混入 C7 ASR，导致 LoRA/runtime 问题不可定位

若 audio→ASR→runtime 一起跑，失败无法分辨是 ASR、normalizer、LLM、parser 还是 state gate。Mitigation：C6 只收文本 / normalized transcript；ASR 留 C7。

### Tiger: 负样本占比被误写成 IrrelAcc 通过率

`>=20%` 只表示 eval 集中 no-call/无关样本占比，不是准确率门。Mitigation：design/spec 分开 dataset composition 与 IrrelAcc threshold。

### Tiger: 本刀提前创建 dataset 文件，越过 propose 红线

`contracts/c6-bench-cases.jsonl` 属新 contracts artifact，生成应在 apply。Mitigation：proposal/spec/design/tasks 均写明本刀只声明目标路径和 schema。

### Tiger: base vs LoRA 不同 harness，形成假提升

如果 prompt、parser、mock、seed、contract digest 不同，LoRA diff 不可信。Mitigation：eval_run 指纹 + base baseline 先行 + 同 harness diff。

### Paper-Tiger: Mastra 是 TypeScript/Node，不适合端侧

C6 只借 eval 形态，不引入 runtime 到 app；bench 是 Mac 开发期工具，零进 iOS。

### Elephant: dataset 规模与阈值会决定 C6 是否真有判别力

当前必须把规模、抽样策略、IrrelAcc 阈值作为 Open Questions 暴露，不能在 propose 里拍脑袋。

## Migration / Apply Plan

1. 从 C1/C2 + demo seed 生成 `contracts/c6-bench-cases.jsonl`。
2. 写 schema 校验与 source_refs 校验，确保引用 C1/C2 真实存在。
3. 写 runner：文本输入 → runtime → ToolCall / no-action / clarify/refusal → mock state/readback → hard gates。
4. 写 scorer：四类硬门先判，judge 文本评分后置。
5. 写 replay 指纹与 trace 输出。
6. 跑 base Qwen3-1.7B baseline。
7. C5 checkpoint 产出后跑同 harness LoRA diff。

## Resolved Decisions（磊哥 2026-06-20 拍）

- **C6 dataset 规模**：must-pass ~30 条（5 幕扩）+ 全集按 device 分层抽样（每 device ≥1，具体量 apply 定）。
- **IrrelAcc passing threshold**：**≥90%**（拒识准确率门，远高于负样本占比 20%，二者分开）。
- **`qwen_tool_call_format_version` 取值**：**文件 content hash**（`contracts/qwen-tool-call-format.yaml` 内容变即变，不依赖 git）。
- **每 case 多跑次数**：**base 基线 5 次取均值/方差**（防单跑误判），其余 bucket 1 次（轻量）。

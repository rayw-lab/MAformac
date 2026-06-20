## Why

C6 是 C5 LoRA 之前必须先立住的评测层。没有全集覆盖率双轴 bench，C5 的提升只能停留在「感觉更懂」，无法判断 base Qwen3-1.7B、LoRA checkpoint、runtime parser、mock state readback 之间到底是谁在提升、谁在退步、谁在假绿。

本 change 将已 parked 的 `define-vehicle-tool-bench` 归位并 rebase 到已 archive 的 C1/C2 契约事实源、#39 `contracts/qwen-tool-call-format.yaml`、以及 2026-06-20 grill 结论。C6 只做 Mac 开发期文本 / normalized transcript eval，不依赖 ASR；ASR 属 C7 voice，不进入 C6 硬门。

## What Changes

- 定义 `vehicle-tool-bench`：全集覆盖率 + scenario score 双轴 bench，输入中文文本 / normalized transcript，输出每 case 的硬门结果、主观文本分、replay 指纹与汇总。
- 声明 C6 dataset 的目标路径为 `contracts/c6-bench-cases.jsonl`，并定义 case schema：`pre_state / input_zh / expected_tool_calls / expect_no_call / expected_state_delta / readback_assertion / clarify_tag / failure_class`。本刀只 propose，不创建该实体文件。
- 以 C1 `contracts/semantic-function-contract.jsonl`、C2 `contracts/state-cells.yaml`、`contracts/demo-scenarios.yaml` seed、`contracts/l1-demo-allowlist.yaml`、`contracts/risk-policy.yaml` 为只读派生输入，不修改 archive 契约。
- 引用 #39 `contracts/qwen-tool-call-format.yaml` 作为 bench harness 的 tool-call 格式单一源，避免 train/runtime/bench silent 失真。
- 建立四类确定性一等硬门：ToolCall 集合匹配、`expect_no_call`、`expected_state_delta + readback_assertion`、澄清正确性。任一失败即硬失败，judge 不参与。
- 保留 Mastra eval 形态：TrajectoryExpectation、dataset + 有界并发、ScoreAccumulator 多桶、结构化 failure、scorer 四阶段 pipeline；但实现用 MAformac 自己的本地 harness，零进 iOS。
- 明确 judge 只评 clarify/refusal 文本主观项：`clarify_text_score / refusal_text_score / reason`；只在硬门全过后加分，不洗白硬门失败。TTS 听感归人工 S-PASS。
- 建立 `eval_run` replay 指纹：`run_id / case_id / model_id / lora_adapter_id / lora_checkpoint_id / qwen_tool_call_format_version / prompt_hash / sampling_seed / tool_output_digest / contract_digest`。
- 明确 base 基线先行：第一轮先用 base Qwen3-1.7B、无 LoRA、`lora_adapter_id` 空跑全 bench；C5 产出 checkpoint 后再用同 harness 跑 LoRA diff。
- 标记 C6 must-pass 集为 `must_not_train`，供 C5 数据门防泄漏。

## Capabilities

### New Capabilities

- `vehicle-tool-bench`：MAformac 车控工具调用评测层。它以 C1/C2 契约为事实源，评估文本输入到 runtime ToolCall、mock state、readback、clarify/refusal 文本的确定性结果，并提供 base vs LoRA 可复现 diff。

### Modified Capabilities

(无)

## Non-goals

- 不写实现代码，不 apply，不修改 `Core/`、`main`、runtime 或 parser 实现。
- 不修改 archive 契约：`openspec/specs/`、`contracts/demo-scenarios.yaml`、`contracts/state-cells.yaml`、`contracts/semantic-function-contract.jsonl` 均只读。
- 不创建 `contracts/c6-bench-cases.jsonl` 实体文件；生成留 apply。
- 不把 ASR 作为 C6 硬门；C6 输入是文本 / normalized transcript，C7 才负责 audio→ASR。
- 不用 LLM judge 放行 ToolCall、state、readback、no-call、clarify 硬门。
- 不做 GRPO / reward 训练；C6 只做评测。

## Success Criteria

- `openspec validate define-vehicle-tool-bench --strict` 通过。
- spec 明确四类确定性硬门，且写清 judge 不参与放行硬门。
- spec/design/tasks 全部写清 `contracts/c6-bench-cases.jsonl` 只是 apply 阶段目标产物，本刀不建文件。
- design 明确 base Qwen3-1.7B 无 LoRA 先跑，C5 checkpoint 后同 harness 做 diff。
- design 明确 no-call / 无关样本占比 >=20% 是 eval 集负样本占比，不是 IrrelAcc 准确率门；IrrelAcc 阈值留 Open Question。
- design 明确 bench harness 引用 `contracts/qwen-tool-call-format.yaml`。
- tasks 给出 apply 阶段 TDD 清单，覆盖 dataset 生成、硬门 runner、judge 边界、replay 指纹、base vs LoRA、must_not_train 去污。

## Impact

- C6 依赖已 archive 的 C1/C2 契约与 #39 tool-call 格式源；它不反向修改这些事实源。
- C6 将成为 C5 LoRA 的验收前置：先建立 base baseline，再评估 LoRA checkpoint 的真实增益、退步和泄漏。
- C6 是 Mac 开发期评测工具，零进 iOS。iOS/macOS app 只消费后续 apply 产生的评测结论，不内置 bench harness。

## Open Questions

- C6 dataset 规模：must-pass N 条、全集覆盖率抽样量、每层抽样策略待拍。
- no-call / 无关样本占比 >=20% 已定为 eval 集负样本占比；IrrelAcc 通过阈值另拍，且应高于 20%。
- `qwen_tool_call_format_version` 取值采用文件 hash、commit hash、还是显式 `version` 字段待拍。

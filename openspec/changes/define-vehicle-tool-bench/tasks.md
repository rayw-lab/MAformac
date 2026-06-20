> 范围：C6 `vehicle-tool-bench` apply 阶段任务清单。当前 propose 只定义契约；执行这些任务前必须先完成 propose review。C6 是 Mac 开发期文本 / normalized transcript eval，零进 iOS，不依赖 ASR。

## 0. Prerequisite Check

- [x] 0.1 运行 `openspec validate define-vehicle-tool-bench --strict`。验收：strict validate 通过后再 apply。
- [x] 0.2 确认只读输入存在：`contracts/semantic-function-contract.jsonl`、`contracts/state-cells.yaml`、`contracts/demo-scenarios.yaml`、`contracts/l1-demo-allowlist.yaml`、`contracts/risk-policy.yaml`、`contracts/qwen-tool-call-format.yaml`。验收：缺任一文件则停止。
- [x] 0.3 确认 apply 不修改 archive specs 或既有 C1/C2 + 只读输入 artifacts。验收：`git diff -- openspec/specs contracts/semantic-function-contract.jsonl contracts/state-cells.yaml contracts/demo-scenarios.yaml contracts/l1-demo-allowlist.yaml contracts/risk-policy.yaml contracts/qwen-tool-call-format.yaml` 只允许 C6 新产物路径出现。

## 1. Dataset Schema + Generation

- [x] 1.1 为 `contracts/c6-bench-cases.jsonl` 定义 schema：`pre_state / input_zh / expected_tool_calls / expect_no_call / expected_state_delta / readback_assertion / clarify_tag / failure_class`。验收：schema test 覆盖 action、no-call、state、clarify/refusal 四类。
- [x] 1.2 从 C1/C2 + demo seed 派生 C6 cases，不直接修改 `contracts/demo-scenarios.yaml`。验收：新建 `contracts/c6-bench-cases.jsonl`，既有 C1/C2 artifacts diff 为空。
- [x] 1.3 为每 case 写 `source_refs`，引用 C1 `contract_row_id` / C2 state cell / scenario seed。验收：悬空引用为 0。
- [x] 1.4 标记 demo must-pass 子集 `must_not_train=true`。验收：case identity 足以给 C5 检查 train/eval 泄漏。
- [x] 1.5 校验 no-call / 无关样本占比 >=20%。验收：这是 dataset composition gate，不等同 IrrelAcc passing threshold。

## 2. Tool-Call Format Contract

- [x] 2.1 bench harness 读取 `contracts/qwen-tool-call-format.yaml`，不另写 wrapper/parser/arguments shape。验收：测试修改 format 文件会改变 C6 读到的 format digest。
- [x] 2.2 定义 `qwen_tool_call_format_version` 生成策略。验收：每条 eval_run 都记录该字段；取值策略与 Open Question 拍板一致。

## 3. Runner Pipeline

- [x] 3.1 实现文本 / normalized transcript 输入路径。验收：runner 不要求 ASR、麦克风、音频文件、iOS runtime。
- [x] 3.2 执行 runtime 并抽取实际 ToolCall 集合。验收：支持多 ToolCall、空 ToolCall、冗余 ToolCall、parser failure 的结构化记录。
- [x] 3.3 执行 mock state transition 与 readback assertion。验收：state delta 与 readback 任一不一致都会 hard fail。
- [x] 3.4 输出 run tree / trace 字段，并能挂 C3 runId。验收：每 case 有 `run_id`，可关联 ToolCall、state、readback、score。

## 4. Deterministic Hard Gates

- [x] 4.1 ToolCall 集合匹配 gate。验收：工具名错、参数错、缺 call、额外 call、重复 call 均 hard fail。
- [x] 4.2 `expect_no_call` gate。验收：no-call case 任何 ToolCall 都 hard fail，并增加 `no_tool_false_positive_count`。
- [x] 4.3 `expected_state_delta + readback_assertion` gate。验收：state_delta_match / readback_match 分开输出。
- [x] 4.4 clarify/refusal correctness gate。验收：该澄清或拒识时执行动作 hard fail；该执行时只澄清也 hard fail。
- [x] 4.5 runner 输出 `IrrelAcc / no_tool_false_positive_count / state_delta_match / readback_match / clarify_match`。验收：指标全存在，硬门失败不能被 summary 隐藏。

## 5. Judge Boundary

- [x] 5.1 实现 judge schema：`clarify_text_score / refusal_text_score / reason`。验收：schema 不含 ToolCall/state/readback/TTS 字段。
- [x] 5.2 judge 只在硬门全过后运行。验收：硬门失败 case 不运行 judge 或 judge 分数不计入放行。
- [x] 5.3 TTS 听感归人工 S-PASS。验收：C6 自动 summary 不使用 TTS 听感作为 hard gate 或 judge 输入。

## 6. Replay Fingerprint

- [x] 6.1 每条 `eval_run` 记录 `run_id / case_id / model_id / lora_adapter_id / lora_checkpoint_id / qwen_tool_call_format_version / prompt_hash / sampling_seed / tool_output_digest / contract_digest`。验收：缺任一字段 gate 红。
- [x] 6.2 计算 `contract_digest`，覆盖 C1/C2 + C6 dataset + tool-call format。验收：任一输入变更会改变 digest。
- [x] 6.3 输出 per-checkpoint diff 所需索引。验收：可按 case_id 和 checkpoint 定位退步。

## 7. Base Baseline + LoRA Diff

- [x] 7.1 先跑 base Qwen3-1.7B 无 LoRA baseline。验收：`lora_adapter_id=""`、`lora_checkpoint_id=""`，产生完整 C6 summary。
- [x] 7.2 LoRA checkpoint 到位后使用同 dataset、同 prompt policy、同 parser、同 mock state、同 scorer 跑 diff。验收：差异仅模型/adapter/checkpoint。
- [x] 7.3 报告 hard-gate delta、coverage delta、scenario score delta、IrrelAcc delta。验收：LoRA 提升和退步都可见，不只报总分。

## 8. Coverage + Scenario Summary

- [x] 8.1 汇总 `contract_coverage_score`。验收：覆盖轴独立于 scenario score。
- [x] 8.2 汇总 `scenario_score`。验收：5 幕 demo seed 相关 case 单独可看。
- [x] 8.3 failure_class 结构化输出。验收：parser / tool_call / no_call / state_delta / readback / clarify / refusal / judge_text / infra failure 可分类。
- [x] 8.4 每 case 支持多跑并报告均值与标准差。验收：小样本单跑不能直接声称提升。

## 9. Validation

- [x] 9.1 单元测试覆盖 schema、source_refs、negative ratio、hard gates、judge boundary、fingerprint、base-vs-LoRA diff。
- [x] 9.2 运行 `openspec validate define-vehicle-tool-bench --strict`。
- [x] 9.3 运行项目最小验证命令。验收：如果验证命令不可跑，报告 blocker 原文。
- [x] 9.4 收口报告附 `git status --short --branch`、strict validate stdout、C6 summary 路径、未拍 Open Questions。

## 10. P0-1 Readback Gate Tightening

- [x] 10.1 C6 readback gate 复用 `StateCellContractLookup.renderReadback` / C2 `readback_zh`，不再用 `key=value` 机器串作为期望 readback。
- [x] 10.2 单测覆盖机器串 fail、C2 中文模板 pass、enum 分支 pass/fail、缺 C2 模板不可 assertion-only pass、否定句 fail、no-call 不虚假 `readback_match=true`。
- [x] 10.3 `C6BenchCLI summarize` 构造 runner 时注入 C2 `StateCellContractLookup`，保持 CLI 复跑口径与单测一致。

## 11. P0-2 Model Artifact Fingerprint

- [x] 11.1 C6 `eval_run` 和 summary 记录 `model_artifact_digest`、`tokenizer_digest`、`lora_adapter_digest`，且 `model_id` 不冒充权重指纹。
- [x] 11.2 base 无 LoRA 时允许 `lora_adapter_digest=""`；只要 `lora_adapter_id` 或 `lora_checkpoint_id` 非空，就要求 `lora_adapter_digest` 非空，否则抛 `missingEvalRunField` 基础设施错误。
- [x] 11.3 `C6BenchCLI summarize` 显式要求 `--model-artifact PATH`、`--tokenizer-artifact PATH`，可选 `--lora-adapter PATH`，并用 `C6Hash.fileHash(url:)` 计算本地文件 digest；目录路径报 usage error。
- [x] 11.4 单测覆盖 base digest 非空、LoRA id 缺 digest 红门、`C6Hash.fileHash` 内容差异、summary 顶层与 eval_run digest 一致。

## 12. P0-3 Trap Cases + Alternatives

### 12.A P0-3a Alternatives schema + matcher

- [x] 12.A.1 `C6BenchCase` 支持 `alternatives`，旧 JSONL 缺省解码为 `[]`。
- [x] 12.A.2 `C6GoldAlternative` 至少包含 `id / expected_tool_calls / expect_no_call / expected_state_delta / readback_assertion / clarify_tag / failure_class / quality / reason`。
- [x] 12.A.3 runner 只把 `quality="acceptable"` alternative 纳入 pass candidate；`degraded` 和未知 quality 不放行。
- [x] 12.A.4 单测覆盖 primary fail + acceptable alternative pass、非 acceptable alternative 不放行。

### 12.B P0-3b Trap cases

- [x] 12.B.1 在 P0-4a baseline `verify-gold` 通过后，新增 12 条 trap cases，覆盖否定、诱饵、冗余改口、模糊、安全继承、低置信 ASR 六类。
- [x] 12.B.2 新增 trap cases 的 `source_refs` 全部可解析，`must_pass=true` 时必须 `must_not_train=true`。
- [x] 12.B.3 模糊 case 才允许 alternatives；明确指令不得滥加 alternatives。

## 13. P0-4 verify-gold Self-check

### 13.A P0-4a Skeleton verifies current 45 cases

- [x] 13.A.1 新增确定性 `C6GoldVerifier`，回放 primary gold 与 acceptable alternatives，输出 ToolCall/state/readback/clarify/source_refs 轴。
- [x] 13.A.2 新增 `C6BenchCLI verify-gold`，输出 `c6-gold-verify.json` 与 `c6-gold-verify.md`，失败时非零退出。
- [x] 13.A.3 单测覆盖 happy path、缺 C2 readback template、state delta 不一致、primary fail + acceptable alternative pass。
- [x] 13.A.4 baseline 旧 45 条 `verify-gold` 全部通过。验收报告：`Reports/c6-gold-verify-baseline-readback-authorized-20260620-182330/c6-gold-verify.json`。

### 13.B P0-4b Final verifies full trap-gold dataset

- [x] 13.B.1 P0-3b 新增 trap cases 后，对全量 cases 再跑 `verify-gold`。
- [x] 13.B.2 final `verify-gold` 必须全量 pass 才允许写 `ready_for_archive=true`。验收报告：`Reports/c6-gold-verify-final-20260620-182557/c6-gold-verify.json`。

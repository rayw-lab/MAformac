> 范围:6-change 第 6 个(最后)。车控工具调用评测门。pre-mortem 料 `qwen3-notes §6` + tool-calling-benchmark + tau2 + Codex 03/04。依赖 change2(eval_refs)/ change3(frame+错误枚举)/ change5(base vs LoRA)。Mac 开发期(零进 iOS)。

## 1. eval harness(抄 gorilla / tiny-tool-bench)

- [ ] 1.1 gold call + parser + scorer 框架(Mac Python,`dev/eval/`,零进 iOS)。验收:能跑一条 gold call 对比。
- [ ] 1.2 统一 trace 输出:`run_id / trace_id / route_kind / parser_status / decode_status / guard_status / execution_status / readback`。验收:每条 case 输出 runId 串联字段,`route_kind` 不退回 fast|slow 二分。
- [ ] 1.3 `eval_run` replay 指纹:`run_id / case_id / model_id / lora_adapter_id / lora_checkpoint_id / qwen_tool_call_format_version / prompt_hash / sampling_seed / tool_output_digest / contract_digest`。验收:同 case 可按 checkpoint diff,缺任一指纹字段 gate 红。
- [ ] 1.4 bench harness 引用 `contracts/qwen-tool-call-format.yaml`,不另写 chat template / wrapper / arguments 形态。验收:输出包含 `qwen_tool_call_format_version`,C3 runtime/C5/C6 格式来源一致。

## 2. 评分分层(tau2:correctness > format)

- [ ] 2.1 分层评分:format(1 分轻)/ tool_name / params(key+value)/ restraint / readback;**tool_name + params 为主体**。验收:格式对但工具/参数错 → 不算过。
- [ ] 2.2 **每 case 跑 10-20 次**判稳定性(非单跑)。验收:边界 case 多跑稳定率达标。

## 3. 测试集

- [ ] 3.1 **demo must-pass 15-25 条精选**(5 幕话术 → 指令映射;**需磊哥确认清单**)+ 标 `must_not_train`(与 change5 train 分离)。验收:清单覆盖 5 幕、与训练集无交集。
- [ ] 3.2 **restraint 反用例**:「不要开空调」/「已经 26 度不要再调」/「天气已给出不要查」。验收:反关键词不误触发工具。
- [ ] 3.3 泛化集分层:模糊说 / 自由说 / 多轮上下文。验收:各层样本齐 + 阈值标注(模糊≥90/自由≥80/上下文≥85)。
- [ ] 3.4 正式 case schema:`pre_state / input_zh / expected_tool_calls / expect_no_call / expected_state_delta / readback_assertion / clarify_tag / failure_class`。验收:从 demo seed 生成正式 C6 dataset 时字段齐;不直接修改已 archive 的 `contracts/demo-scenarios.yaml`。

## 4. base vs LoRA + 死门 gate

- [ ] 4.1 `base_vs_lora_eval`:同 schema/温度/parser/mock 对比(接 change5)。验收:同条件,差异仅模型。
- [ ] 4.2 **四个 0 死门 gate**:`Unsafe false pass=0` / `readback mismatch=0` / `no-tool false positive=0` / must-pass<100% → 阻断放行。验收:任一非 0 / 未达 → gate 红。
- [ ] 4.3 四类一等硬门:expect_no_call / IrrelAcc / state_delta+readback / clarify_match。验收:runner 输出 `IrrelAcc / no_tool_false_positive_count / state_delta_match / readback_match / clarify_match`;任一 no-call 误触发、状态差异错误、读回不一致、该澄清未澄清 → 硬失败。
- [ ] 4.4 judge 仅评文本主观项,不参与放行硬门。验收:硬门失败总分归零;硬门全过后才计算 `clarify_text_score / refusal_text_score / reason`;TTS 听感归人工 S-PASS。

## 5. 验收门

- [ ] 5.1 demo must-pass = 100%(15-25 精选,断网)+ 四个 0 守住。**叠加 Superpowers: TDD(eval-first)**。
- [ ] 5.2 restraint 通过(该忍住时忍住)+ 泛化整体 ≥85%(分层达标)+ 快/慢路径延迟分别判(快≤800ms/慢≤2500ms)。
- [ ] 5.3 `openspec validate define-vehicle-tool-bench` 通过。

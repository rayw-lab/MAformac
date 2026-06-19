## Why

eval 是 demo 可信度的硬门:**demo must-pass = 100%**(现场不翻车)+ **泛化 ≥ 85**(证明真有能力,非死记)。pre-mortem(`qwen3-notes §6` + tool-calling-benchmark + AWS tau2)已搜透:**工具调用是判断问题不是格式问题**(restraint:该调时调、该忍时忍)/ 每 case 跑 10-20 次(3 次不够)/ 评分 correctness 权重 > format。

## What Changes

- **vehicle-tool-bench**:gold call + parser + scorer(结构抄 gorilla / tiny-tool-bench)。
- **评分分层**:format / tool_name / params / **restraint** / readback(correctness 权重 > 格式,借 tau2)。
- **每 case 跑 10-20 次**(边界 prompt 稳定性,3 次不够)。
- **restraint 反用例**(必含):「不要开空调」「已经 26 度不要再调」「天气已给出不要查」——测「该忍住时忍住」。
- **四个 0 死门**:`Unsafe false pass=0` / `readback mismatch=0` / `no-tool false positive=0` / demo must-pass 未达 100% = 不放行。
- **双维度**:demo must-pass=100% + 泛化分层(模糊说 ≥90 / 自由说 ≥80 / 上下文 ≤3 轮 ≥85 / 整体 ≥85)。
- **base vs LoRA** 同集对比(接 change5)。

## Capabilities

### New Capabilities
- `vehicle-tool-bench`:车控工具调用评测门的行为契约——分层评分(含 restraint)、每 case 多跑、四个 0 死门、base vs LoRA 同集。

### Modified Capabilities
(无)

## Non-goals

- ❌ 不做 GRPO 训练(借 reward 思想做评分,非训练)。
- ❌ 不只测 happy path(必含 restraint 反用例)。
- ❌ 不用 3 次样本判稳定(10-20 次)。
- ❌ 不看模型解释像不像(看整句帧准确率)。

## Success Criteria(可验收)

- **demo must-pass = 100%**(15–25 条精选,覆盖 5 幕)。
- **四个 0 死门**:`Unsafe false pass=0` / `readback mismatch=0` / `no-tool false positive=0` / must-pass<100% 不放行。
- **restraint 通过**:反关键词用例「该忍住时忍住」(不误触发工具)。
- **每 case 10-20 次**稳定(非单跑)。
- **泛化分层**:模糊说 ≥90% / 自由说 ≥80% / 上下文 ≥85% / 整体 ≥85%。
- **base vs LoRA** 同 schema/温度/parser/mock 对比。

## Impact

- 依赖 change2 `capabilities.yaml`(eval_refs / 范围枚举)+ change3 `execution-contract`(ToolCallFrame / 错误枚举)+ change5 `lora-pipeline`(base vs LoRA 数据,eval 集 must_not_train)。
- 评测集:demo must-pass(精选 15–25)+ 泛化集(模糊/自由/上下文分层)。
- Mac 开发期 eval(gorilla / tiny-tool-bench / Hammer 框架参考;零进 iOS)。
- **demo must-pass 具体清单**(此前 demo-mvp / voice 的 open question)在本 change 定稿。

## Context

eval 是 demo 可信度硬门。pre-mortem 料 `qwen3-engineering-notes §6`(eval 硬约束)+ [tool-calling-benchmark](https://github.com/MikeVeerman/tool-calling-benchmark)(restraint + 10-20 次)+ [AWS tau2](https://github.com/awslabs/agent-training-kit/blob/main/examples/tau2/README.md)(reward correctness>format)+ Codex `03/04`(四个 0 + 统一 trace)。依赖 change2(eval_refs)/ change3(frame+错误枚举)/ change5(base vs LoRA)。

## Goals / Non-Goals

**Goals:** 分层评分(含 restraint)+ 四个 0 死门 + 双维度(must-pass 100% + 泛化≥85)+ base vs LoRA 同集。
**Non-Goals:** GRPO 训练 / 只测 happy path / 3 次判稳 / 看模型解释像不像。

## Decisions

### 评测结构(抄 gorilla / tiny-tool-bench)
`gold call` + `parser` + `scorer`;主指标 = **整句帧准确率**(非解释像不像)。

### 评分分层(tau2:correctness 权重 > format)
| 维度 | 权重 | 说明 |
|---|---|---|
| format | 1 分(轻) | 能解析成 ToolCallFrame |
| **tool_name** | 主体 | 工具名对 |
| **params**(key + value) | 主体 | 参数 key + value 对 |
| **restraint** | 关键 | 该忍住时忍住(反关键词不误触发) |
| readback | 死门 | 读回一致 |

### 每 case 跑 10-20 次
边界 prompt 至少 10-20 次才稳(3 次不够,tool-calling-benchmark 实证)。

### restraint 反用例(必含,非 happy path)
「不要开空调」/「已经 26 度不要再调」/「天气已给出不要查」—— 测「该调时调、该忍时忍」。

### 四个 0 死门
`Unsafe false pass=0` / `readback mismatch=0` / `no-tool false positive=0` / demo must-pass<100% → 不放行。

### 双维度
- **demo must-pass = 100%**(15–25 条精选,覆盖 5 幕;此集 `must_not_train`)。
- **泛化分层**:模糊说 ≥90% / 自由说 ≥80% / 上下文 ≤3 轮 ≥85% / 整体 ≥85%(PRD 阈值)。

### 统一 trace(Codex 04)
每条 case 输出 `trace_id / route(fast|slow)/ parser_status / decode_status / guard_status / execution_status / readback`。

## Risks / Trade-offs(pre-mortem,带来源)

- [只测 happy path 漏 restraint] → 必含反关键词用例(该忍住时忍住)。源:[tool-calling-benchmark](https://github.com/MikeVeerman/tool-calling-benchmark)。
- [3 次样本判不稳] → 每 case 10-20 次。源:同上(Qwen3:1.7B 边界稳定性需 10-20 次)。
- [format 对 ≠ correctness] → 评分 correctness(tool_name/params)权重 > format。源:[AWS tau2](https://github.com/awslabs/agent-training-kit/blob/main/examples/tau2/README.md)。
- [demo must-pass 死记非泛化] → 双维度(泛化集分层)。源:qwen3-notes §6 + voice-pipeline §5 泛化分层。
- [慢路径混进快路径预算] → 每 case 标 `route: fast|slow`,快≤800ms/慢≤2500ms 分别判。源:brainstorm §5 延迟分路径。

## Migration Plan

Mac 开发期 eval harness(gorilla/tiny-tool-bench 框架参考;零进 iOS)。eval 集 `must_not_train`(与 change5 train 集分离)。

## Open Questions

- demo must-pass 15–25 条**具体清单**(本 change 定稿;需磊哥确认 5 幕话术 → 指令映射)。

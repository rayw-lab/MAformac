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
每条 case 输出 `trace_id / route_kind / parser_status / decode_status / guard_status / execution_status / readback`。

### 待解冻 adopt:#39 格式契约 + #40 replay 指纹
C6 bench harness SHALL 引用 `contracts/qwen-tool-call-format.yaml`,不得另写 runtime parser / wrapper / arguments 形态。每条 `eval_run` 输出 `run_id / case_id / model_id / lora_adapter_id / lora_checkpoint_id / qwen_tool_call_format_version / prompt_hash / sampling_seed / tool_output_digest / contract_digest`,并挂到 Q1 的 `runId` trace 树,用于 per-checkpoint diff 和回归归因。

### 待解冻 adopt:Q3 judge 边界
新增 Requirement:judge 不参与放行硬门。确定性硬门先过:`Unsafe false pass=0 / readback mismatch=0 / no-tool false positive=0 / must-pass=100%`;任一失败总分归零,LLM judge 不得洗白。judge 仅在硬门全过后评文本主观项,输出 schema 只保留 `clarify_text_score / refusal_text_score / reason`;TTS 听感归人工 S-PASS,不进自动硬验收。

### 待解冻 adopt:Q4 case schema 与四类一等硬门
C6 正式 case schema SHALL 包含 `pre_state / input_zh / expected_tool_calls / expect_no_call / expected_state_delta / readback_assertion / clarify_tag / failure_class`。runner SHALL 输出 `IrrelAcc / no_tool_false_positive_count / state_delta_match / readback_match / clarify_match`。任一 no-call 误触发、状态差异错误、读回不一致、该澄清未澄清都为硬失败,judge 不参与。

> **🔴 跨 change 对齐(2026-06-19,apply 前必改)**:原 `route(fast|slow)` 二分 → apply 时 MODIFIED 为 `route_kind` 多态(`rule_fast` / `rule_batch_fast` / `fc_fast` / `slow`),对齐 `define-intent-routing` 三层分流。否则 intent-routing 的 `rule_batch_fast`(规则批快路径,明确「不升慢」)会被二分误归慢路径 → 套错延迟预算(慢≤2500ms 而非快≤800ms)/ fixture expected 对不上 / 砸 must-pass=100% 死门。延迟预算按 `route_kind` 分档判。源:`define-intent-routing/proposal.md:41` + `tasks.md:48`。

## Risks / Trade-offs(pre-mortem,带来源)

- [只测 happy path 漏 restraint] → 必含反关键词用例(该忍住时忍住)。源:[tool-calling-benchmark](https://github.com/MikeVeerman/tool-calling-benchmark)。
- [3 次样本判不稳] → 每 case 10-20 次。源:同上(Qwen3:1.7B 边界稳定性需 10-20 次)。
- [format 对 ≠ correctness] → 评分 correctness(tool_name/params)权重 > format。源:[AWS tau2](https://github.com/awslabs/agent-training-kit/blob/main/examples/tau2/README.md)。
- [demo must-pass 死记非泛化] → 双维度(泛化集分层)。源:qwen3-notes §6 + voice-pipeline §5 泛化分层。
- [慢路径混进快路径预算] → 每 case 标 `route_kind`(见统一 trace 对齐注,非 fast|slow 二分),按档分判(快≤800ms / 慢≤2500ms)。源:brainstorm §5 延迟分路径。

### 🆕 oracle 深挖增量(2026-06-19;repo 新鲜度核过,详见 memory `maformac-lora-train-eval-stack`)

**🐯 HIGH-1 防死记 held-out**:eval 集必"**换说法 + 没见过的 arg 值 + 按 bug_id 分层切**"(同一 bug 多条说法不许跨 train/eval);报 ID-OOD gap(同分布 vs 换说法,gap>15%=死记)。
**🐯 HIGH-2 防假提升(base vs LoRA 不公平对比)**:必**同 harness/同 prompt/同 greedy/同 mock/同 parser**+ **分层打分**(function 名/arg/格式 拆开,防 base 被 parser 冤枉)+ 跑前各 `--limit 10` 人眼核 extraction + **train/eval 三层去污**(n-gram + token + embedding cosine>0.8 语义去重)去污后重算。
**🐯 HIGH-2b 单跑噪声(被误判的真坑)**:temp=0+seed 仍不可复现(并发+浮点);小 eval 集(<100 条)**多跑 3-5 次取均值+报 std**,别信单跑小 delta。源:[Thinking Machines 非确定性](https://www.nextbigfuture.com/2025/11/defeating-nondeterminism-in-llm-inference-by-thinking-machines.html)。
**🐯 HIGH-3 防手痒**:IrrelAcc(该忍住没乱调)**独立一等验收指标** + eval ≥20% no-call/无关样本;验收双指标(读回 mock 态 + IrrelAcc)非只 AST。
**🐘 elephant**:通用 bench 测 AST 不测"5min 惊艳+断网不崩";eval 集从三源(3990+12000bug+raw)挖**磊哥认的炸场 case**,验收以读回 mock 态(项目铁律),AST 必要非充分。
**adopt 方法学不 adopt 集(无车控+中文+restraint+mock 三合一现成集)**:[BFCL-v3/gorilla](https://github.com/ShishirPatil/gorilla)(车控域+state-based eval,12908★活)+ [tau2-bench](https://github.com/sierra-research/tau2-bench)(state 校验,活)+ [When2Call](https://github.com/NVIDIA/When2Call)(restraint 数据集)+ ToolLearning-Eval/BFCL-ZHTW(中文);**骨架抄 AST+state+IrrelAcc 三件套,集子自建**(中文+按 capabilities 契约生成)。

## Migration Plan

Mac 开发期 eval harness(gorilla/tiny-tool-bench 框架参考;零进 iOS)。eval 集 `must_not_train`(与 change5 train 集分离)。

## Open Questions

- demo must-pass 15–25 条**具体清单**(本 change 定稿;需磊哥确认 5 幕话术 → 指令映射)。

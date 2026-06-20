# MAformac C6/C5/C4/C7 eval pre-mortem oracle 源发现包

> 日期：2026-06-20  
> 范围：源发现（source discovery），不是最终综合结论。  
> 检索窗口：2026-03-20 到 2026-06-20；优先采用 GitHub `pushed_at` / release / 文档活动证据。  
> 查询族：LLM eval harness、agent trajectory evaluation、function/tool calling benchmark、stateful tool-agent-user benchmark、browser/OS agent eval、prompt injection agent eval、redteam regression eval、BFCL、tau-bench、AgentDojo、OSWorld。

## 关键发现

1. C6 不应只是“多跑几个 prompt”。它需要可执行工具调用检查、轨迹断言、端状态读回、环境重置、失败归因、flaky 检测、延迟/成本门禁。
2. C4 需要路径级评分。最终答案正确，仍可能藏着错误路由、多余工具调用、缺 clarify、不安全状态修改、错误 fallback。
3. C5 数据要覆盖格式敏感、多轮状态、模糊指令、小动作大错误、工具输出攻击、no-call/拒识样本。
4. C7 eval 要测语音交互行为，不只测 ASR 字准：半双工/全双工、barge-in、turn-taking、工具延迟、音频流下的轨迹稳定性。

## 候选源

| Repo | 近期活跃证据 | eval 核心形态 | MAformac 可吸收模式 / failure mode |
|---|---:|---|---|
| [UKGovernmentBEIS/inspect_ai](https://github.com/UKGovernmentBEIS/inspect_ai) | `pushed_at=2026-06-19`；repo README 说明 Inspect 包含 prompt engineering、tool usage、multi-turn dialog、model-graded eval。 | 通用 LLM eval 框架：solver / scorer / tool / multi-turn / model-graded。 | C6：每条样例都要有 trace + scorer。C4：路由、工具、多轮步骤应成为可评分单元，不能藏在黑盒里。 |
| [UKGovernmentBEIS/inspect_evals](https://github.com/UKGovernmentBEIS/inspect_evals) | `pushed_at=2026-06-19`；release `v0.14.1 @ 2026-06-18`；包含 AgentHarm 和 AgentThreatBench。 | Inspect 官方 eval 集，覆盖安全与 agent threat eval。 | C6/C4：安全、越界、工具输出污染应做成可执行 must-fail 集，不靠 prompt 字面约束。 |
| [ShishirPatil/gorilla / BFCL](https://github.com/ShishirPatil/gorilla/tree/main/berkeley-function-call-leaderboard) | `pushed_at=2026-04-13`；BFCL V4 leaderboard 页面标注 last updated `2026-04-12`。 | 可执行 function calling：simple、multiple、parallel、multi-turn、agentic web search、memory、format sensitivity。 | C4/C6：JSON 看起来合法不等于通过。要执行调用、校验 args、parser 行为、malformed output、多轮记忆和格式敏感性。 |
| [vllm-project/perf-eval](https://github.com/vllm-project/perf-eval) | `pushed_at=2026-06-18`。 | serving 性能 + lm-eval + BFCL recipe。 | C6：runtime serving args 和 parser flags 会改变 tool-call 分数。记录 backend args、latency、concurrency、BFCL category。 |
| [langchain-ai/agentevals](https://github.com/langchain-ai/agentevals) | `pushed_at=2026-06-17`；release `js==0.0.7 @ 2026-03-03`。 | agent trajectory evaluator：strict / unordered / subset / superset / graph trajectory / LLM-as-judge。 | C4/C6：最终 mock state 对了，轨迹仍可能低效或错误。要评分 sequence、args、clarify、no-call、fallback shape。 |
| [modelscope/evalscope](https://github.com/modelscope/evalscope) | `pushed_at=2026-06-18`；release `v1.8.1 @ 2026-06-16`；README 的 2026-05 更新提到 agent trace replay、MCP、external agent bridge、Codex/Claude Code bridge、GAIA、tau3、per-turn caps。 | 广义 eval/perf 框架，含 agent trace、MCP、外部 agent bridge、工具延迟模拟、dashboard。 | C6/C7：加入 wall-clock budget、per-turn caps、工具延迟模拟、trace replay。语音/agent 评测不能只看准确率。 |
| [sierra-research/tau2-bench](https://github.com/sierra-research/tau2-bench) | `pushed_at=2026-06-11`；release `v1.0.0 @ 2026-03-18`；README 说明 tau3 加入 voice full-duplex、knowledge domain、75+ task fixes。 | tool-agent-user 交互 benchmark，支持文本半双工和语音全双工。 | C7/C6：评估 turn-taking、barge-in、full-duplex。还要维护任务质量修复循环，处理歧义、不可完成、缺 fallback 的坏样例。 |
| [StonyBrookNLP/appworld](https://github.com/StonyBrookNLP/appworld) | `updated_at=2026-06-19`；`pushed_at=2026-02-17`，所以代码活跃证据较弱。 | 可控 app/API 世界，带 initial state 和 programmatic state-based grading。 | C6：验证最终状态，不信对话文本。MAformac mock 车控应以 state-cell 执行后读回为准。 |
| [ethz-spylab/agentdojo](https://github.com/ethz-spylab/agentdojo) | `pushed_at=2026-06-02`；repo 描述为 LLM agent prompt injection 攻防动态环境。 | prompt injection 攻防动态环境；tool filter defense；多类 attack。 | C4/C6：工具输出、记忆、环境上下文都是攻击面。risk-policy 和 tool filter 要进 eval 覆盖。 |
| [promptfoo/promptfoo](https://github.com/promptfoo/promptfoo) | `pushed_at=2026-06-20`；release `code-scan-action-0.1.8 @ 2026-06-16`。 | prompt/app eval、red teaming、vulnerability scanning、CI/CD。 | C6：redteam case 应作为 CI-style gate。本地私有运行和矩阵报告适合离线 demo 语境。 |
| [microsoft/PyRIT](https://github.com/microsoft/PyRIT) | `pushed_at=2026-06-20`；release `v0.14.0 @ 2026-06-05`。 | 生成式 AI 风险识别与 red-team orchestration。 | C6/C4：把不安全请求、敏感动作、间接注入做成可复跑攻击任务，并落风险分类。 |
| [ServiceNow/BrowserGym](https://github.com/ServiceNow/BrowserGym) | `updated_at=2026-06-20`；`pushed_at=2026-03-17`，代码 push 刚好早于窗口。 | Gym 风格浏览器任务环境；WebArena、WorkArena、VisualWebArena、AssistantBench、TimeWarp。 | C6：区分 reset、action log、reward、terminated、truncated。环境配置漂移本身也要记录。 |
| [xlang-ai/OSWorld](https://github.com/xlang-ai/OSWorld) | `pushed_at=2026-06-10`；README 提到 screenshots、actions、video recordings、detailed scores、manual examination、credentials/proxy caveat。 | 真实 OS 任务 benchmark，面向多模态 agent。 | C6：很多失败来自环境、配置、凭证、代理，不是模型。要保存 artifacts，并把环境失败单独分类。 |
| [microsoft/WindowsAgentArena](https://github.com/microsoft/WindowsAgentArena) | `pushed_at=2026-04-13`。 | 可扩展 Windows OS agent benchmark；支持并行云端运行和 bring-your-own-agent interface。 | C6：并行 eval 需要固定镜像和资源。本地设备约束如果不记录，会污染横向比较。 |
| [nano-step/eval-harness](https://github.com/nano-step/eval-harness) | `pushed_at=2026-06-05`；release `v0.4.2 @ 2026-05-30`。 | agent 行为回归：4-class attribution、6-field FAIL schema、cost gate、flaky detection。 | C6：可借鉴 failure receipt：expected、actual、trace、class、cost、flaky。没有这个，badcase 无法治理。 |
| [princeton-pli/hal-harness](https://github.com/princeton-pli/hal-harness) | `pushed_at=2026-06-17`。 | 跨 benchmark 的统一 agent eval harness。 | C6：后期可作为统一 runner 形态参考，把 BFCL、自家车控、voice eval 收到同一接口。 |
| [langfuse/langfuse](https://github.com/langfuse/langfuse) | `pushed_at=2026-06-20`；release `v3.194.0 @ 2026-06-19`。 | trace、dataset、eval、prompt management、metrics。 | C6/C4：尽早固定 trace schema。如果 route/tool/state trace 字段漂移，回归分析会失真。 |
| [comet-ml/opik](https://github.com/comet-ml/opik) | `pushed_at=2026-06-19`；release `2.0.73 @ 2026-06-19`。 | LLM/RAG/agent workflow tracing 和 automated eval。 | C6：横向比较运行结果：tool calls、judge scores、errors、regression deltas 都需要稳定存储。 |
| [EleutherAI/lm-evaluation-harness](https://github.com/EleutherAI/lm-evaluation-harness) | `pushed_at=2026-06-02`；release `v0.4.12 @ 2026-05-11`。 | 通用模型 benchmark harness。 | C5：只适合做 base model sanity。不要把语言 benchmark 分数误当车控工具/路由/状态可靠性。 |
| [openai/evals](https://github.com/openai/evals) | `pushed_at=2026-04-14`。 | LLM 与 LLM-system eval registry。 | C6：registry 组织方式可参考；MAformac 仍需要 agent/tool/state 自定义 scorer。 |

## 冲突与不确定

- GitHub `updated_at` 可能因为 issue、star、release、metadata 变化而移动，弱于 `pushed_at`。
- `AppWorld` 和 `BrowserGym` 的模式价值高，但代码 push 证据较弱或略早于本次窗口。
- `tau2-bench` release 是 `2026-03-18`，比窗口早 2 天；但代码在 `2026-06-11` 仍有 push，且 tau3 voice/knowledge/task-fix 对 C7/C6 直接相关。
- 不少 redteam 项目会宣传 agentic security；有效筛选标准是是否定义了可复跑任务、攻击、防御和评分。纯 awesome list 已排除。

## 推荐下一步搜索

1. `Qwen3 function calling BFCL tool parser malformed`
2. `full duplex voice agent benchmark tau voice barge-in interruption eval`
3. `agent trajectory regression flaky failure attribution schema`

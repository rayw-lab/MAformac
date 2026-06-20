# Mastra teardown — workflow graph / scorer-eval / observability trace（只借形态，不进 runtime）

> **缘起**：磊哥 2026-06-20 定,深扒 `mastra-ai/mastra`(⭐25257,当天 push,TS/Node)提取**工程形态**供 MAformac 借鉴。源码只读 clone 在 `~/workspace/raw/05-Projects/MAformac/ref-repos/mastra/packages/core/src/`(CLAUDE §6:不进仓)。
> **硬结论(不变)**:**Mastra 不进 MAformac app runtime**——TS/Node 无 Swift 路径 + 自由 agent loop 撞「禁 agent loop」红线。本文**只提取形态翻译给 Swift 参考,不是「引入 Mastra」**。
> **范围(磊哥限定只三类)**:① workflow graph(→ C4 借确定性流程形态)② scorer/eval(→ C6 借评测组织,实现用 MAformac 自己 contract)③ observability trace(→ C3/C6 借五段 trace span 体系)。
> 深扒方法:blueprint-teardown(逐文件读全,带 `file:line`,抓让方案可靠的工程决策)。

---

## A. workflow graph(→ C4)

**核心发现:workflow 的「图」不是图数据结构,而是 `StepFlowEntry` 有序数组,每元素是带 `type` 标签的纯描述对象(tagged union)。所有控制流构造子(then/branch/parallel/loop/foreach)只做一件事:push 一个描述对象。执行引擎按数组顺序对每个 `type` 走确定性 handler。没有「模型自由决定下一步」的环节。**

- `workflows/types.ts:505-532` — **`StepFlowEntry` 7 态 tagged union**:`step/sleep/sleepUntil/parallel/conditional/loop(dowhile|dountil)/foreach`。**控制流是值不是代码路径** → 可序列化/可视化/可 diff/可 snapshot。→ MAformac C4 该把 `router→gate→execute→readback→trace` 表达成 `enum Stage` 纯数据序列,而非隐式 if/else 散落。
- `workflow.ts:1685-1723`(then)/ `:2052-2106`(branch)/ `:2108-2154`(dowhile)/ `:2204-2255`(foreach) — **每个构造子「双写」**:运行态 `stepFlow.push`(含函数引用)+ `serializedStepFlow.push`(条件函数 `.toString()` 序列化,只留 id/description)。**graph 自带可持久化/可视化镜像**。→ MAformac DemoFlow 每步同产一份「可 trace 的纯数据描述」(Swift `Codable struct`),bench/trace 不必反推。
- `workflow.ts:2261-2286`(`buildExecutionGraph`/`commit`) — **图在 `commit()` 时冻结**(committed=true 进只读执行态)。**确定性的来源:图先完整定义→冻结→执行,执行期不改图**。→ MAformac demo 流程结构启动前定死,运行期只填 state。
- `handlers/control-flow.ts:264-411`(`executeConditional`) — **分支由 code condition 函数判定,不由模型**。并行 eval 所有 condition → `truthyIndexes` → 只跑命中 step;失败包成 `WORKFLOW_CONDITION_EVALUATION_FAILED` 结构化错误非静默。→ 与铁律「安全/路由是代码不是 prompt」同构;模型只在 step 内被调,永不决定下一步。
- `control-flow.ts:568-803`(`executeLoop`) — **循环有显式边界 + 每轮查 abort 信号 + iterationCount**。要么 condition 退出,要么 abort 中断,次数全程可观测。→ 对照 Mastra 自己的 agent loop(E 段)用 maxSteps 兜底却仍打满,workflow 这条确定性路径无此病。
- `control-flow.ts:63-232`(parallel)/ `:839-1349`(foreach) — 并发用 `Promise.all`/`fastq` 有界队列,结果按「failed→suspended→canceled→success」固定优先级归并。状态归并写死 code,不靠模型协调。

**cross-cutting**:① 图即数据(tagged-union 数组)② 定义→冻结→执行三相,执行期不改图=确定性根源 ③ 状态机统一(`WorkflowRunStatus` 10 态 + `StepResult` 6 态,全枚举不用布尔,对上「错误用枚举」铁律)④ 每控制流节点产 span(图结构与 trace 结构同构)⑤ 分支/循环判定全是 code 函数,模型永不决定下一步。

---

## B. scorer/eval(→ C6)

**核心发现:scorer 是 4 阶段 pipeline,且 pipeline 本身被编译成 workflow(复用 A 的 graph)。dataset 跑批 = 有界并发 pMap,per-item 先跑 target 再跑 scorer 逐条累加。最贴 C6 的是 `TrajectoryExpectation` —— 它就是 expected_tool_calls 契约的现成蓝本。**

- `evals/base.ts:377-501` — **scorer = 链式四阶段 `preprocess→analyze→generateScore→generateReason`,每阶段返回新 `MastraScorer`(immutable 追加,never mutate)** → 对上磊哥 coding-style immutability 铁律。`generateScore` 必须存在否则抛 `MISSING_GENERATE_SCORE`。
- `base.ts:443-471,922-956` — **score 强制返回 `number`、reason 强制 `string`**(`z.object({score:z.number()})` 约束 judge 输出)。**输出契约固定 `{score:number, reason:string}`** → C6 每条 scenario 直接照搬。
- `base.ts:704-839`(`toMastraWorkflow`) — **scorer pipeline 编译成 workflow**(每 step `.then().commit()`),每步产 `SCORER_STEP` span。→ MAformac bench 每条 scenario 评测就是一条确定性小流程,不需新框架。
- **`evals/types.ts:550-594`(`TrajectoryExpectation`)= C6 expected_tool_calls 契约现成蓝本,几乎一比一**:
  - `steps: ExpectedStep[]`(`:554`)= 期望工具序列,每个 `{name, stepType:'tool_call', toolArgs}` → **MAformac expected_tool_calls 含 args**。
  - `ordering: 'strict'|'relaxed'|'unordered'`(`:563`)→ 工具序列要不要严格按序。
  - `blacklistedTools`(`:585`)+ `blacklistedSequences`(`:588`)→ **就是 MAformac `expect_no_call`**(某 scenario 必须不调某工具)。
  - `noRedundantCalls`(`:580`,默认 true)→ 罚「连续同工具同 args」→ **直接防 E 段 #6827 重复调用 bug**。
  - `maxSteps`(`:571`)/ `maxRetriesPerTool`(`:593`)。
  - `extractTrajectory`(`:611-658`)从 invocation 抽 `{name,toolArgs,toolResult,success}` → **从 MAformac trace 抽实际 ToolCall 序列与 expected 比对的算法**。
- `evals/run/index.ts:119-183`(`runEvals`) — **dataset 跑批标准形态**:`data:{input,groundTruth,expectedTrajectory}[]` + `pMap` 有界并发,per-item `executeTarget→runScorers→addScores`,返回 `{scores:平均, summary:{totalItems}}`。→ **C6:demo-scenarios 做 dataset,逐条跑→打分→汇总覆盖率**。
- `run/index.ts:408-642` — **per-item failure 结构化 `MastraError` 分类**(`..._FAILED_TO_SCORE_RESULT`/`..._TRAJECTORY`/`..._STEP_RESULT` + `details:{scorerId,item}`),never 静默。→ C6 failure_class 按「在哪层失败」分 enum + 带 scenario 上下文。
- `run/scorerAccumulator.ts` — **多桶分维累加再平均**(flat/workflow/step/agent/trajectory 五桶)。→ C6「全集覆盖率 + scenario score 双轴」= 两累加桶各求平均。
- `base.ts:858-983` — LLM-as-judge 可带只读工具独立核查(不只比文本)。→ **MAformac:ToolCall/state/readback 用确定性比对(judge 不碰),judge 仅评文本主观项**(`clarify_text_score/refusal_text_score`),**硬门全过后加分、不参与放行硬门、不洗白**;TTS 听感归人(config:48)。judge 的「自由多轮工具迭代 loop」才 drop(撞红线),**单次文本评分留**(Q3 纠:原"全 drop"是降级)。

**cross-cutting**:① scorer = 不可变链式 pipeline ② pipeline 即 workflow(打分也确定性)③ dataset 跑批 = `{input,groundTruth,expectedTrajectory}[]` + 有界并发 + 逐条累加平均 ④ trajectory 打分多维(ordering/blacklist/redundant/maxSteps)——**C6 近乎零设计可抄契约** ⑤ failure 全程结构化枚举 + 上下文。

---

## C. observability trace(→ C3/C6)

**核心发现:trace = span 树。每执行节点开一个对应 `SpanType` 的 span,通过 `currentSpan` 在 context 透传成父子树。runId(业务)与 traceId/spanId(OTel)并存。**

- `observability/types/tracing.ts:35-100`(`SpanType` enum) — **span 类型是大 enum,覆盖每种执行节点**:`WORKFLOW_RUN`(根)/`WORKFLOW_STEP`/`WORKFLOW_CONDITIONAL`+`_EVAL`(路由/gate)/`TOOL_CALL`(执行)/`MODEL_GENERATION`+`_INFERENCE`(理解)/`SCORER_RUN`+`_STEP`(bench)。`SpanTypeMap`(`:681-710`)每 SpanType 映专属 attributes 接口。→ **MAformac 五段 trace = `enum TraceSpan { asr, understand, route, guard, execute, readback }`,每段带专属字段,不是 free-form 日志**。
- `tracing.ts:737-772`(`BaseSpan`) — **span schema**:`id`(spanId)+`traceId`(32 hex 全 span 有)+`type`+`startTime/endTime`+`attributes`(类型专属)+`input/output`+`errorInfo`+`parent`。**runId(业务运行号,贯穿 control-flow)vs traceId/spanId(OTel)分工**。→ MAformac 一次 demo 交互一个 runId,五段各一 spanId 挂同 traceId。
- `tracing.ts:799-816`(`createChildSpan`/`findParent`) — 树通过 createChildSpan 构建,`findParent(type)` 向上找(scorer 用它找祖先再挂 step span)。→ span 自带「沿父链回溯」,后期挂分数/feedback 能精确定位。
- `observability/context.ts:1-219` — **trace context 极简:核心载荷只是 `TracingContext{currentSpan}`**,一路带下去,子节点 createChildSpan 自动归位(Mastra 用 Proxy 自动注入,Swift 显式传参更直 → drop Proxy)。
- `control-flow.ts` 全程示范 **每控制流节点 createChildSpan→执行→end(成功带 output)/error(失败带 error)**,span 三态生命周期与 workflow 状态机同构。
- `tracing.ts:1269-1299`(`InternalSpans` 位掩码 + `TracingPolicy`) — **span 可标 internal 从导出 trace 隐藏**(scorer pipeline 的 workflow span 全标 internal,只露 `SCORER_RUN`)。→ MAformac 给客户看 trace 时,内部归一化/解析步骤标 internal,只露五段主干。

**cross-cutting**:① trace=span 树,结构与 workflow graph 同构 ② SpanType enum + 专属强类型 attributes ③ runId(业务)/traceId-spanId(OTel)双标识 ④ context 极简(一个 currentSpan 透传)⑤ span 三态(create/end/error)+ internal 分层(主干 vs 脚手架)。

---

## D. adopt / adapt / drop 映射(给 MAformac)

| Mastra 形态(file:line) | MAformac 落点 | 动作 | 为什么 |
|---|---|---|---|
| `StepFlowEntry` tagged-union 数组(types.ts:505-532) | **C4** DemoFlow | copy概念 | `router→gate→execute→readback→trace` 表达成 `enum Stage` 纯数据序列,非散落 if/else |
| 定义→`commit()`冻结→执行三相(workflow.ts:2273) | **C4** | copy概念 | demo 流程启动前定死、运行期只填 state = 拒自由 loop 的工程兜底 |
| 分支由 code condition 判定(control-flow.ts:264-411) | **C4** 路由/DemoGuard | copy概念 | 与铁律「安全/路由是代码不是 prompt」同构 |
| loop 查 abort + iterationCount 有界(control-flow.ts:629) | **C4** | adapt | Swift 用 Task cancellation,循环必有显式退出 + 计数 |
| 运行态+serialized 双写图(workflow.ts:1701) | **C3/C4** | adapt | 每步同产一份可 trace 纯数据描述(Swift Codable),bench 不反推 |
| `WorkflowRunStatus`/`StepResult` 全枚举(types.ts:266/152) | **C3/C4** | copy概念 | 全程枚举状态不用布尔,对上「错误用枚举」铁律 |
| **`TrajectoryExpectation`**(types.ts:550-594) | **C6** expected_tool_calls 契约 | **copy概念(几乎一比一)** | steps(工具+args)+ordering+blacklistedTools(=expect_no_call)+noRedundantCalls(防#6827)+maxSteps,C6 契约近乎现成 |
| `extractTrajectory`(types.ts:611-658) | **C6** | adapt | 从 trace 抽实际 ToolCall 序列与 expected 比对的算法 |
| `runEvals` dataset+pMap+累加(run/index.ts:119) | **C6** | copy概念 | demo-scenarios 做 dataset,逐条跑→打分→汇总覆盖率 |
| `ScoreAccumulator` 多桶分维平均(scorerAccumulator.ts) | **C6** | adapt | 「覆盖率 + scenario score 双轴」= 两累加桶各求平均 |
| per-item failure 结构化分类(run/index.ts:425) | **C6** | copy概念 | failure_class 按「哪层失败」分 enum + scenario 上下文,never 静默 |
| `{score:number,reason:string}` 输出契约(base.ts:443) | **C6** | copy概念 | 每条 scenario 固定出 score+reason |
| scorer 四阶段 immutable pipeline(base.ts:377) | **C6** | adapt | 形态有用,但 MAformac 评 ToolCall 是确定性比对,多数 scenario 不需 LLM-judge 阶段 |
| `SpanType` enum + 专属 attributes(tracing.ts:35/681) | **C3/C6** 五段 trace | copy概念 | trace span 按节点语义分 enum,每段强类型字段,非 free-form 日志 |
| `BaseSpan` schema + runId/traceId 并存(tracing.ts:737) | **C3** | copy概念 | MAformac span 字段形态 |
| `currentSpan` 透传成树(context.ts/control-flow.ts) | **C3** | adapt | Swift 显式传 currentSpan(不用 Proxy),子段挂父段 |
| span 三态 + `InternalSpans` 分层(tracing.ts:1269) | **C3/C6** | adapt | span 生命周期三态;内部段标 internal,给客户只露五段主干 |
| Proxy 自动注入 context(context.ts:45) | — | **drop** | TS Proxy 魔法,Swift 显式传参更清晰 |
| evented engine/pubsub/fastq/suspend-resume/snapshot 持久化 | — | **drop** | 分布式/持久工作流基础设施,端侧单进程 demo 不需要 |
| LLM-as-judge agent + 工具核查循环(base.ts:858) | **C6 judge 评文本主观项**(clarify/refusal 话术) | **留 单次文本评分 / drop 自由多轮 loop**（Q3 纠） | judge schema 只 `clarify_text_score/refusal_text_score/reason`，硬门全过后加分、不参与放行硬门、不洗白；TTS 听感归人。原"drop默认"是降级，已提回 |
| **完整 Agent 自主 loop + TS/Node runtime** | — | **DROP(红线)** | 撞「禁自由 agent loop」+「JS 零进 iOS」铁律 |

---

## E. C4 反面证据 — Mastra agent loop 的 production 失败清单(写进 C4 design Risks)

Mastra 的 **workflow(确定性图)路径稳**,但 **agent loop(自由循环)路径在 production 反复出问题** —— 这是 MAformac「拒自由 agent loop、用确定性 code 编排」的最强外部证据(已核 GitHub 原 issue):

1. **#6827「Agent makes repetitive tool calls」**:约 1/20-30 概率对同一工具用**完全相同参数连续调用**,打满 `maxSteps`;mutative 操作灾难(同一动作执行多遍)。→ MAformac 车控走自由 loop 则「打开空调」可能执行多次;确定性图天然无此病(B 段 `noRedundantCalls` 就是为打它)。
2. **#11273「maxOutputTokens quits agentic loop」**:某步触达 maxOutputTokens(finish reason=length)时**整个 loop 直接终止**,用户拿到提前结束的不完整结果。→ 端侧小模型输出更易触顶,自由 loop 静默断在半截。
3. **context rot(自由 loop 通病)**:raw history 每轮膨胀、不报错,模型在变长上下文里**越答越差**(纯质量退化无异常)。→ 1.7B 对 context 长度极敏感,这种不报错退化对 demo 是定时炸弹。
4. **多步后 tool 被传空参 / loop 不稳**。→ 自由 loop 多跳累积误差;MAformac **只产单跳 ToolCallFrame**、编排在 code,从根避免。

**共性根因**:自由 agent loop 把「下一步做什么 + 何时停」交给模型 + 软上限兜底,失败模式**静默**(打满/截断/退化都不抛错)。Mastra 自己的 workflow 路径反而无这些病,因为「下一步」由 code 决定、循环有显式边界。**MAformac 选确定性 code 编排 = 规避 Mastra 在 production 已暴露的这整类坑。**

---

## 一句话(三类各自最该借的「形态」,非 runtime)

- **workflow graph → 借「图即冻结的 tagged-union 数据数组、控制流是值不是代码、下一步由 code 决定」** → 给 C4 确定性 DemoFlow 骨架。
- **scorer/eval → 借 `TrajectoryExpectation` 契约(expected_tool_calls + blacklist=expect_no_call + noRedundantCalls + ordering)+ dataset/pMap/累加/结构化failure 跑批组织** → C6 bench 契约近乎现成,实现用 MAformac 自己 contract。
- **observability trace → 借「SpanType enum + 专属 attributes + currentSpan 透传成树 + runId/traceId 并存 + internal 分层」** → 给 C3/C6 五段 trace 强类型 span 体系。

全程严守:**只提取形态翻译给 Swift,不引入 Mastra(TS/Node)runtime。**

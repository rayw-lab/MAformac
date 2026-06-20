# agent-tester 蓝本 工程 teardown — MAformac C6 vehicle-tool-bench 最贴车控的现成形态

> **缘起**：磊哥要求深扒 `reinhardjurk/agent-tester`——一个**车载语音助手 agent 测试框架**，是 MAformac 全部 ref-repo 里**最贴车控 / 最贴 C6（不丢脸 bench）** 的一个。它的 case schema 几乎逐字命中 C6/C2 需要的契约（utterances + 初始车态 + required/forbidden 工具 + 可接受替代 + 范围匹配），且整套是「全 mock、禁真实车控、每 case 新鲜隔离、确定性 + LLM-judge 双评、自包含 trace HTML」——和 MAformac 的 demo 边界（全 mock 车控、读回端态验收）同形。
> clone 在 `~/workspace/raw/05-Projects/MAformac/ref-repos/agent-tester`（CLAUDE §6：只读参考，不进仓）。
> **本文 = 全 9 个 Python 文件 + 例子 YAML 逐文件拆解**（带行号）。
> **⚠️ License = 「No license — all rights reserved」**（README 明示）→ 红线：**只翻译设计思想成 Swift，不复制 Python 代码**。下方所有「adopt」均指**形态/算法/契约结构**，不指 import 代码。
> **核心结论**：agent-tester 把「评一个车载 FC agent 好不好」拆成**四件可靠工程**——(1) 一个**声明式 case 契约**（required ∪ forbidden ∪ alternatives ∪ RangeMatch）让模糊指令也能可判定；(2) **每 (case) 新鲜 stub registry** 杜绝跨 case 状态泄漏；(3) **集合式确定性评测**（any-of 替代 + 范围 + 禁用项）；(4) **单一 dispatch 拦截点 = 禁真实车控的物理保证**。逐条都是 MAformac C6 该抄的形态。

---

## §0 规模 + 读序（runtime/契约核心先）

| 文件 | 行 | 角色 | 读序 |
|---|---|---|---|
| `schemas.py` | 202 | **契约核心**：case/profile/trace/result 全部 Pydantic 模型 | 1（最重要） |
| `evaluators.py` | 176 | **评测核心**：确定性 ToolCall + perf + LLM-judge | 2 |
| `runner.py` | 120 | 编排：cases × profiles → results；**fresh-per-case** 在这 | 3 |
| `sut.py` | 118 | 被测系统：车载 agent 循环（单一 dispatch 拦截） | 4 |
| `stubs.py` | 102 | 录制 stub 原语（StubServer/Registry/单一 dispatch chokepoint） | 5 |
| `configs.py` | 87 | YAML loader（每次造 fresh registry + canned 拷贝防 mutate） | 6 |
| `clients.py` | 253 | 模型抽象（Anthropic / Ollama，canonical block 格式） | 7 |
| `visualize_results.py` | 385 | 自包含 trace HTML（矩阵 + 条形图 + 可展开 trace，零依赖） | 8 |
| `run_example.py` | 99 | CLI 入口（cases × profiles 矩阵跑） | 9 |
| `examples/**.{json,yaml}` | — | case / mcp_server / context_bundle / profile / agent_card 实例 | 贯穿 |

---

## §1 契约核心 `schemas.py`（202 行）— C6/C2 的现成契约骨架

这是本仓**对 MAformac 价值最高**的文件。它把「一个车控 case 长什么样」声明清楚了，几乎逐字是 C6/C2 想要的。

- **🔴 `Expectation`（line 45-54）= 模糊指令可判定的关键**：
  - `required_tool_calls`（必须命中的工具调用）+ `forbidden_tool_calls`（绝不能调的工具名）+ `response_intent`（给 LLM-judge 的意图描述）+ **`alternatives: list[Expectation]`（any-of 替代解）**。
  - 注释（line 47-49）点破设计意图：*「`alternatives` 让单个 case 接受 several 有效解——对「I'm feeling hot」这种模糊 prompt 是关键」*。→ **车控 bench 的本质问题：「有点热」可以开空调 OR 开窗 OR 委派 comfort agent，都对**。MAformac C2/C6 完全同构（一句模糊话有多个合法落点）。
- **🔴 `RangeMatch`（line 22-33）+ `ExpectedToolCall.args_match`（line 39-42）= 参数范围匹配**：
  - `args_match: dict[str, ArgMatcher]`，每个值可以是「精确值 / `{min,max}` 范围 / `None`（任意值）」（line 36 注释）。
  - `RangeMatch.matches`（line 26-33）：非数值直接 fail，再卡 min/max。
  - → demo 实例 `feeling_hot.json`：`hvac_set_temperature.target_celsius ∈ [16,23]`、`window_open.position_pct ∈ [20,70]`。**正对应 MAformac execution_range 权威**（空调 18-32℃、风量 1-10、车窗 0-100%）。bench 判定不是「精确等于 22℃」，是「落在合理降温区间」——这正是 demo 该有的容差。
- **`VehicleState`（line 66-73）= 初始车态契约**：`speed_kmh / cabin_temp_c / outside_temp_c / location / occupants / extras`。注释 line 67「surfaced to the agent as context」。→ 速度是 case 的一等公民（因为「100km/h 以上不准开窗」是安全约束，见 §6）。MAformac C2 端态可借此扩字段。
- **`Utterance`（line 61-64）**：`role: "user" | "system_event"` + `text`。**`system_event` 角色**预留了「系统事件触发」（如车速突变、告警）作为输入——MAformac 多轮 / barge-in 场景可借。
- **`TestCase`（line 76-82）**：`id + description + utterances + initial_state + expectation + tags`。`tags`（如 `["climate","ambiguous","comfort"]`）= 分层 bench 的切片维度（按标签算覆盖率 / 模糊类准确率）。
- **`Trace` 事件四态（line 129-174）**：`ModelCallEvent`（含 token/stop_reason）/ `ToolCallEvent`（含 `server` 来源 + `arguments` + `result` + **`is_delegation`** 标 A2A 委派）/ `FinalResponseEvent` / `ErrorEvent`。`Trace.tool_calls()`（line 167-168）+ `final_text()`（line 170-174 倒序取最后 final）= 评测器消费入口。**这就是 MAformac「LoRA Day1 埋 trace」要的 trace schema**。
- **`RunResult`（line 196-203）**：`trace + performance + evaluators[] + overall_passed`（line 85 = `all(e.passed)`）。多评测器 AND 收口。

> **MAformac 映射**：C6 的「case JSONL」可以直接照这套 Pydantic 形态设计 Swift `Codable` 结构体。C1 的 `semantic-function-contract` 是「全集语义」，C6 的 case 是「在全集上挑点做 bench」——agent-tester 的 `TestCase` 就是 C6 case 的形态范本，且它的 `RangeMatch` 解决了「demo 容差判定」这个 C6 必答题。

## §2 评测核心 `evaluators.py`（176 行）— 集合式确定性 + any-of + LLM-judge 双轨

- **🔴 `_expectation_satisfied`（line 51-64）= 集合式判定（非序列）**：
  - `observed = [(name, args) for tc in trace.tool_calls()]`——**收集全部观测到的工具调用，不看顺序**。
  - required：每个期望调用「**被至少一个**观测调用满足」（line 55-57 `any(...)`）→ 集合包含，不要求精确序列，也不惩罚多余的对的调用。
  - forbidden：任一观测调用名在禁用表 → fail（line 60-62）。
  - → **和 home-llm evaluate.py 的「ToolCall 集合精确匹配」同源**，但 agent-tester 多了 forbidden + 范围 + 替代三层，**更适合 demo「不丢脸」语义**（关键是「该调的调了 + 不该调的没调」，不是「逐 token 对齐」）。
- **🔴 `ToolCallEvaluator.evaluate`（line 71-85）= any-of 替代解判定**：
  - `candidates = [主 expectation] + alternatives`（line 76）→ **任一候选满足即 PASS**，全失败才报第一个失败原因（line 83）。
  - → 这是「模糊指令多合法解」的判定落地。MAformac C6 必抄：「有点热」case 列空调 / 开窗 / 委派三个 alternative，命中任一就算对。
- **`_arg_matches`（line 31-37）**：`None=任意` / `{min,max}=范围` / 否则精确等于。三态参数匹配，干净。
- **`PerformanceEvaluator`（line 88-106）= 回归护栏**：`max_elapsed_ms=15000 + max_total_tokens=20000` 预算门，超了 fail。**MAformac 端侧版改成「首响 ≤Xms / 单轮 token ≤Y」作秒回回归门**（北极星「反应快」可量化）。
- **🔴 `LLMJudgeEvaluator`（line 131-176）= rubric 评 + 低方差措施**：
  - 1-5 分 rubric（line 122-127）：5=正确理解意图选了合适动作 / 3=部分对（动作可辩护但次优）/ 1=误解意图或选了不安全动作。
  - **低方差三件套**：`temperature=0.0`（line 158）+ pin judge model（line 135）+ 强制严格 JSON 输出（line 127, 162-168 解析失败即 fail 不静默）。
  - `normalized=(score-1)/4`（line 170），`passed = score>=4`（line 173）。
  - **跳过条件**（line 140-142）：case 没 `response_intent` 就跳过 judge（确定性够了就不烧 LLM）。
  - → MAformac：确定性 ToolCall 判 80%（FC 对不对），LLM-judge 只评「话术 / 安全态度」这 20% 软的，且 judge 必须 pin + 低温 + 严格 JSON（C6 防「评测器自己漂」）。

> **MAformac 映射**：C6 评测 = **确定性集合判定（required∪forbidden∪RangeMatch∪alternatives）为主门**（端侧本地可跑、零 LLM 成本、可判模糊解）+ **可选 LLM-judge 评话术安全**（pin+低温+严格 JSON）。比 home-llm 的纯精确匹配更适合「demo 不丢脸」（容差 + 多合法解 + 禁用项）。

## §3 编排 `runner.py`（120 行）— fresh-per-case 隔离是核心旋钮

- **🔴 fresh registry per (case)（line 104）**：`run_matrix` 双层循环里，**每个 case 都 `build_registry_for_profile(...)` 重造一个 registry**，注释明写 `# fresh per case`。
  - **为什么是关键工程**：stub 是有状态的（handler 可能记录调用 / canned 可能被 mutate）。若跨 case 复用同一 registry，上个 case 的污染会泄漏进下个 case → 评测假阳/假阴。**逐 case 新鲜 = 测试隔离的物理保证**。
  - 注意 model_client 和 context_bundle 是 per-profile 复用（line 101-102，无状态可共享），**只有 registry 是 per-case 重造**——精确隔离「有状态的那一层」。
- **`run_one`（line 50-86）**：组装 registry/bundle/client（可注入，便于单测）→ `run_case` 跑出 trace → 算 perf → 跑评测器 → AND 收口。**依赖注入式**（每个组件可传 None 自动构建，也可外部传入 mock）——可测性设计。
- **`_performance_from_trace`（line 36-47）**：perf 指标**从 trace 事件聚合**（in/out token 求和、model_call / tool_call 计数）+ wall_ms（line 65-67 `time.perf_counter`）。→ trace 是单一事实源，指标全派生，不另埋点。
- **`run_matrix`（line 89-114）= 矩阵跑**：profiles 外层 × cases 内层 → `list[RunResult]`。judge_client 全程复用一个 Anthropic（line 97，注释「judge 始终 Anthropic 保跨 SUT 一致」——评测器不能跟着被测模型变，否则 A/B 不公平）。
- **`save_results`（line 117-120）**：`model_dump(mode="json")` 落 JSON → 喂 visualize。

> **MAformac 映射**：C6 bench **每 case 重置 mock 端态 + 重建 mock 工具注册表**（杜绝上个 case 把空调开了影响下个 case 的读回判定）。这条直接对应 MAformac「验收以读回 mock 态为准」——读回前必须保证端态是这个 case 的初始态，不是上个 case 的残留。

## §4 被测系统 `sut.py`（118 行）— 单一 dispatch = 禁真实车控的物理保证

- **🔴 通用 tool-use 循环（line 77-117）**：`MAX_ITERATIONS=8`（line 30）的 ReAct 循环——模型生成 → 有 tool_use 就 dispatch + 把结果喂回 → 无 tool_use 就收 final。
  - **⚠️ 与 home-llm 单发（MAX_ITER=0）对比**：agent-tester 是**多步 agent loop**（8 步），因为它在测「大模型 agent 编排能力」。**MAformac 该 drop 这个自由 loop**——架构铁律是「模型单次产单跳 ToolCallFrame，编排在 code」。agent-tester 这里是**反面参照**（它测的是 cloud agent，MAformac 是端侧单发）。但 trace 记录 / 评测形态可借。
- **🔴 单一 dispatch 拦截点（line 109）= 禁真实车控**：所有工具调用走 `registry.dispatch(tu.name, dict(tu.input))`，**没有任何真实 IO**。stub 注释（stubs.py line 4-7）明写「production 接真 MCP/A2A，test mode 全换成 stub」。
  - → **这就是 MAformac DemoGuard / mock 车控的形态**：agent 以为在调真工具（看到真 schema、拿到看起来真的 result），实际全是录制 stub。**禁真实车控 = 物理上没有真实 backend，不是靠 prompt 约束**（= MAformac「安全检查是代码不是 prompt」同源）。
- **🔴 per-case 初始态注入（line 57-62）**：runner 在跑 case 前，**把 `get_vehicle_state` 的 handler 替换成返回本 case 的 `initial_state`**（line 61 `lambda args, _s=state: _s`）。→ 同一个 mock 工具，每 case 喂不同初始车态。YAML 里只是 `_placeholder: true`（vehicle_state.yaml line 13），runtime 才填真数据。**MAformac mock 端态可照此：工具 schema 静态声明，初始态 per-case 注入**。
- **canonical 消息格式（line 105-116）**：assistant turn 存 canonical block，tool_result 回喂——provider 无关（clients.py 在边界翻译）。

## §5 stub 原语 `stubs.py`（102 行）— 录制 + 单一 chokepoint

- **`StubServer`（line 38-48）**：一个 stub 代表一个 MCP server（`kind="mcp"`）**或**一个 A2A agent card（`kind="a2a"`）——**同一抽象**，只 kind 不同。`ToolDef`（line 24-35）= name + description + input_schema + handler。
- **🔴 `StubRegistry.dispatch`（line 73-97）= 单一 chokepoint + 防御**：
  - 遍历所有 server 找 tool → 调 handler，**handler 抛异常被 catch 成 `{"error": str(e)}` result**（line 79-80），不崩溃，交给 SUT 决定。
  - **未注册工具 → 返回 `{"error": "no stub registered for tool X"}`**（line 90-97）而非抛错。→ **模型幻觉调了不存在的工具，bench 不崩，记录成 error result**。这是「让 bench 对小模型畸形输出鲁棒」的防御（小模型会调不存在的工具，bench 必须扛得住）。
  - 每次 dispatch 造一个 `ToolCallEvent` 带 `server` 来源 + `is_delegation`（A2A 标记）→ trace 可区分「直接工具」vs「委派子 agent」。
- **`all_tool_defs`（line 63-71）**：按 profile 启用的 server 列表收集工具 → 喂给模型的 tool schema。**未启用的 server 不进 schema**（profile 控制工具暴露面）。

> **MAformac 映射**：MAformac mock 工具层照此——**单一 dispatch chokepoint**（所有 ToolCall 走一个入口）+ **未知工具 / handler 异常都返回 error result 不崩**（对 1.7B 畸形输出鲁棒，和 home-llm 三层防御解析互补：解析层兜格式，dispatch 层兜执行）。

## §6 安全约束的双轨编码 `context_bundles/*.yaml` — prompt 约束 vs case 禁用项

车控安全（「100km/h 以上不准开窗」）在 agent-tester 里**双轨编码**，值得 MAformac 借鉴边界：

- **轨道 A：prompt 软约束**（`safety_first.yaml` line 8-12 / `explicit.yaml` line 27-32）：system prompt 写死「Never open window above 100 km/h / Never set HVAC above 28℃ below 16℃」。→ 这是**喂给被测 agent 的约束**（测 agent 听不听话）。
- **轨道 B：case 禁用项硬判**（`take_me_home.json` line 19 `forbidden_tool_calls: ["window_open"]`）：评测器**确定性地**判「这个 case 绝不该调 window_open」。→ 这是**评测器的硬门**，不靠 LLM。
- **🔴 MAformac 的关键差异**：agent-tester 测的是「cloud agent 守不守安全 prompt」，所以安全在 prompt（轨道 A）。**MAformac 架构铁律是「安全检查是代码不是 prompt」**——所以 MAformac 应**把轨道 B（确定性禁用 + R0–R3 risk-policy）做成 runtime DemoGuard 硬门 + C6 bench 硬判**，轨道 A 只作 LoRA 训练信号，**不依赖 prompt 守安全**。agent-tester 在这里是「该 adapt 不该照抄」的点：借它的 forbidden/risk 判定形态，但把执行点从 prompt 挪进 code。

## §7 profile matrix `profiles/*.yaml` — 四轴正交 A/B（车控选型的现成实验设计）

- **四轴正交**（README line 173）：**模型** × **拓扑**（monolith 全工具一个 server vs swarm 多 A2A 专家）× **prompt 详细度**（explicit/terse/safety_first）× **context_bundle**。
- 实例：`llama32_swarm_explicit`（line 1-18）= llama3.2:3b + 6 个 A2A 专家 agent + explicit prompt + temp 0。8 个 profile（2 模型 × 2 拓扑 × 2 prompt）× 2 case = 16 runs（run_example.py line 56-67）。
- **`provider: ollama` + `base_url`（schemas.py line 105-106）= 本地小模型直测**：`ollama_llama32.yaml` 不需 API key，本地跑。→ **MAformac 端侧 Qwen3-1.7B 可照此走本地 provider**（Ollama / MLX），bench 完全离线。
- **`InferenceParams`（schemas.py line 85-87）`temperature=0.0`**（FC 确定性默认）——和 home-llm trained 模型 temp 0.1 一致倾向（低温要确定性）。

> **MAformac 映射**：C6 bench 的 profile 矩阵 = **{Qwen3-1.7B base, Qwen3-1.7B+LoRA, Qwen3-0.6B fallback, FoundationModels baseline}** × **{规则路由 on/off}** × **{prompt 详细度}**。一个矩阵跑出「LoRA 提升多少 / 规则吃掉多少 / 0.6B 够不够」——正是 MAformac「不前置 benchmark 但要 bench 验证」要的实验设计。**profile = 「换一个旋钮重跑全 case」的声明式形态**，直接 adopt。

## §8 自包含 trace HTML `visualize_results.py`（385 行）— 零依赖可视化报告

- **🔴 零依赖单文件 HTML**（line 8 注释 + line 91-142 inline CSS + SVG）：`python visualize_results.py results.json --open` → 一个自包含 HTML（inline CSS + inline SVG 条形图，**无 JS 框架、无 CDN**）。→ **断网可看**（北极星「断网也能跑」延伸到 bench 报告也断网可看）。
- **三块视图**：
  1. **profile × case 矩阵**（line 160-189）：PASS/FAIL 绿红格 + 每格 hover title 显示失败评测器 detail（line 179-183）。一眼看哪个 profile 在哪个 case 挂。
  2. **per-profile 条形图**（line 192-235）：pass rate / elapsed / tokens 三张横向 SVG 条形图，纯手写 SVG（line 234）。
  3. **可展开 per-run trace**（line 250-288）：`<details>` 折叠，展开看完整 trace（tool_call 名+args+result / model_call token / final_response / error，line 264-278）。→ **每个 run 的工具调用链 + 结果可逐条审**。
- **聚合**（line 29-70）：by_profile / by_evaluator / totals（pass rate / token / elapsed 总和）。
- 安全：`_esc` HTML 转义（line 77-78）防注入。

> **MAformac 映射**：C6 bench 报告照此——**零依赖自包含 HTML**（矩阵 + 条形图 + 可展开 trace），断网可看，方案经理 / 磊哥本地打开即审。比建 dashboard 服务轻量得多（fresheveryday 轻治理：文件 > 服务）。trace 折叠面板正对应「LoRA Day1 埋 trace」的人审入口。

## §9 模型抽象 `clients.py`（253 行）— canonical block 让 SUT provider 无关

- **canonical block（line 26-50）**：`TextBlock / ToolUseBlock / Usage / ModelResponse` 镜像 Anthropic SDK 形态 → **sut.py 不知道底下是 Anthropic 还是 Ollama**（line 8-9 注释）。
- **provider 在边界翻译**：`AnthropicClient`（line 71-112）直传；`OllamaClient`（line 119-241）把 canonical ↔ Ollama `/api/chat` 翻译（line 132-196 `create` + line 198-241 `_flatten_message`：assistant turn → tool_calls / tool_result → `{"role":"tool"}`）。
- **Ollama 健壮性**（line 160-166）：HTTP ≥400 抛带 body 的错误（「model not found, try pulling」actionable）；tool_call arguments 是字符串时 try `json.loads` 兜底（line 177-181）。
- → **= MAformac `LLMBackend` 协议（mlx-swift-lm / llama.swift 可换）的同形设计**。canonical block 抽象让 bench harness 不绑死后端，换模型只改 client。

## §10 Cross-cutting patterns（横切设计思想）

1. **声明式契约驱动**：case（JSON）/ tool（YAML）/ profile（YAML）/ prompt（YAML）全是声明式数据，零硬编码。改一个 case / 加一个工具 / 换一个 prompt 都是改数据文件，不改代码。→ **= MAformac「契约 SSOT 单一源派生」同哲学**。
2. **状态隔离精确到「有状态那一层」**：无状态组件（client/bundle）per-profile 复用，有状态组件（stub registry）per-case 重造。不是「全部重造」（浪费）也不是「全部复用」（污染），是**精确识别状态边界**。
3. **单一 chokepoint = 安全 + 可观测**：所有工具调用走一个 `dispatch`，所以「禁真实车控」（物理无 backend）和「全 trace 记录」（dispatch 即埋点）一处搞定。
4. **trace 是单一事实源**：perf 指标全从 trace 聚合，评测全消费 trace，报告全渲染 trace。不另埋点、不另存指标。
5. **判定容差 + any-of**：模糊车控指令的本质是「多个合法解 + 参数区间」，所以判定必须 RangeMatch + alternatives，不能精确等于。**这是车控 bench 区别于一般 FC bench 的核心**。
6. **确定性主门 + LLM-judge 辅门**：能确定性判的（FC 对不对）绝不烧 LLM；只有软的（话术 / 安全态度）才上 judge，且 judge pin+低温+严格 JSON 防自漂。
7. **防御性 dispatch**：未知工具 / handler 异常都返回 error result 不崩 → 对小模型畸形输出鲁棒（和 home-llm 解析层防御互补）。

## §11 MAformac adopt / adapt / drop 映射（→ C6 为主，旁及 C2/C3/C4/C5/C7）

| agent-tester 形态（file:line） | MAformac 落点 | 动作 | 为什么 |
|---|---|---|---|
| `Expectation` 四件套 required∪forbidden∪intent∪**alternatives**（schemas.py:45-54） | C6 case 契约（Swift Codable） | **copy概念** | 模糊车控指令多合法解，这是可判定的现成结构 |
| `RangeMatch` + `args_match` 三态匹配（schemas.py:22-42, eval:31-37） | C6 参数判定（对齐 execution_range 18-32/1-10/0-100） | **copy概念** | demo 容差判定必答题，精确等于会误判 |
| 集合式 `_expectation_satisfied`（eval:51-64，不看顺序 + any-of） | C6 确定性主门 | **copy概念** | 该调的调了+不该调的没调，端侧本地零成本可跑 |
| `alternatives` any-of 判定（eval:71-85） | C6「有点热」类模糊 case 判定 | **copy概念** | 命中空调/开窗/委派任一即对，C6 核心 |
| `forbidden_tool_calls` 硬判（eval:60-62 / take_me_home.json:19） | C6 + DemoGuard：R0–R3 risk-policy 禁用项 | **adapt** | 借判定形态，但执行点从 prompt 挪进 **code**（架构铁律：安全是代码） |
| `LLMJudgeEvaluator` pin+temp0+严格JSON+跳过条件（eval:131-176） | C6 可选 judge（评话术/安全态度） | **adapt** | 只评软的20%，端侧版可换本地小judge或人审；低方差三件套照抄 |
| `PerformanceEvaluator` 预算门（eval:88-106） | C6 秒回回归门（首响≤Xms） | **adapt** | 北极星「反应快」量化；端侧阈值改小 |
| **fresh registry per-case**（runner.py:104） | C6 每 case 重置 mock 端态 + 工具注册表 | **copy概念** | 「读回 mock 态验收」前提=端态是本case初始态非残留 |
| per-case 初始态注入 handler 替换（sut.py:57-62） | C2/C6：工具 schema 静态 + 初始端态 per-case 注入 | **copy概念** | mock 端态 per-case 喂不同初始车态 |
| **单一 dispatch chokepoint**（stubs.py:73-97） | C3 DemoGuard / mock 车控执行层 | **copy概念** | 禁真实车控=物理无backend；dispatch即trace埋点 |
| 防御性 dispatch（未知工具/异常→error result，stubs.py:79-97） | C3 执行层对1.7B畸形输出鲁棒 | **copy概念** | 与home-llm解析层防御互补（格式+执行双兜底） |
| `Trace` 四事件 + `is_delegation`（schemas.py:129-174） | C3/C4「LoRA Day1 埋 trace」schema | **copy概念** | 现成trace结构；is_delegation→MAformac可标L1/L2/慢路 |
| `VehicleState` + `Utterance.system_event`（schemas.py:61-73） | C2 端态字段 + C4 系统事件输入 | **adapt** | speed一等公民（安全约束依赖）；system_event可作barge-in/告警输入 |
| profile 四轴正交矩阵（profiles/*.yaml + run_example.py:56-67） | C6 bench 实验设计：{base/LoRA/0.6B/FM}×{规则on/off}×{prompt} | **copy概念** | 一矩阵验「LoRA提升多少/规则吃多少/0.6B够不够」 |
| `provider: ollama` 本地小模型直测（schemas.py:105-106, clients:119-241） | C6 端侧 Qwen3-1.7B 离线 bench（Ollama/MLX provider） | **adapt** | 离线bench；client换MLX |
| canonical block + `LLMBackend` 同形（clients.py:26-112） | C3 `LLMBackend` 协议（mlx-swift/llama.swift可换） | **copy概念** | 换后端只改client，harness不绑死 |
| 零依赖自包含 trace HTML（visualize_results.py 全文件） | C6 bench 报告（矩阵+条形图+可展开trace） | **copy概念** | 断网可看；文件>服务（轻治理）；trace审入口 |
| `tags` 切片（schemas.py:81 / feeling_hot.json:51） | C6 按标签算覆盖率/模糊类准确率（双轴bench） | **copy概念** | D35双轴bench（全集覆盖率×分类准确率）切片维度 |
| `MAX_ITERATIONS=8` 自由 ReAct loop（sut.py:30,77） | — | **drop** | MAformac单发（模型产单跳，编排在code）；这是反面参照 |
| 安全约束写 system prompt（safety_first/explicit.yaml） | — | **drop**（作LoRA信号可留） | 架构铁律「安全是代码不是prompt」；prompt约束不可信 |
| Anthropic SDK / cloud provider / A2A 多agent委派 runtime | — | **drop** | 端侧单模型，无云、无真A2A（委派语义可作LoRA落域信号） |
| Python/Pydantic/httpx/yaml runtime | — | **drop** | 翻译成Swift Codable，零Python进iOS（CLAUDE铁律） |

## §12 一句话

agent-tester 是 MAformac ref-repo 里**最贴车控的 bench 形态蓝本**：它把「车载 FC agent 好不好」拆成**声明式 case 契约（required∪forbidden∪alternatives∪RangeMatch，让模糊指令可判定）+ fresh-per-case 隔离（读回态可信）+ 集合式确定性评测（容差+any-of+禁用项）+ 单一 dispatch 拦截（禁真实车控=物理无backend）+ profile 四轴矩阵（选型实验设计）+ 零依赖trace HTML（断网可审）**——逐条都是 C6 该抄的**工程形态**（License 受限，只抄形态不抄码）。**该 drop 的只有自由 ReAct loop（MAformac 单发）和 prompt 软安全（MAformac 安全在 code）这两个云agent特性**，其余全量吸收。

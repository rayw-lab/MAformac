# tau2-bench（τ³-bench）蓝本 工程/算法 teardown — MAformac C6/C7 评测体系直接抄的现成实现

> **缘起**：磊哥要求深扒 `sierra-research/tau2-bench`（Sierra Research，MIT，arXiv 2506.07982 / τ³-bench 2026，Live Leaderboard taubench.com）——MAformac 的 **C6 vehicle-tool-bench（工具-agent-用户交互评测）+ C7 voice（语音全双工 + barge-in）** 双蓝本。clone 在 `~/workspace/raw/05-Projects/MAformac/ref-repos/tau2-bench`（CLAUDE §6：只读参考，不进仓；License 受限只读方法，**不复制代码**，Python→Swift 翻译设计思想）。
> **本文 = 评测/编排/语音 runtime 层逐文件拆解**（核心算法文件全读，带行号 `file:line` 锚点）。
> **核心结论**：tau2-bench 的评测可靠性**不靠"对比模型输出文本"，而靠"在 mock DB 上重放工具调用 → 哈希端态 → 比对 gold 端态"**——这正是 MAformac CLAUDE 铁律"验收以读回 mock 态为准"的**工业级参考实现**。配套 5 个让评测可信的工程旋钮：**端态哈希比对（任意路径达同端态即过）/ 幻觉工具调用作 no-op 重放（不崩、靠端态分叉自然失败）/ reward 是各分量乘积（一票否决）/ pass^k 多跑方差度量 / 11 标签 × 严重度的失败分类法**。语音侧：**tick 全双工（双方同 tick 出 chunk，工具结果延后一 tick 投递保音频不断）+ 幻觉重试闭环 + 响应性度量**。

---

## §0 全景：分层架构 + 5 域 + 双模式（README + registry.py + runner/README.md）

- **域（domain）抽象**：每个域 = policy（agent 须守的规则）+ tools（工具集）+ tasks（评测任务）+ 可选 user_tools。当前 5 域：`mock`/`airline`/`retail`/`telecom`/`banking_knowledge`（`registry.py:313-348`）。→ **MAformac 对应 = `cabin`（车控）单域**，policy=risk-policy（R0–R3）+ tools=契约 SSOT 派生的 ToolSchema。
- **双通信模式**（`evaluator.py:134` 分流）：
  - **Text 半双工（HALF_DUPLEX）**：回合制，trajectory = `list[Message]`，`Orchestrator`。
  - **Voice 全双工（FULL_DUPLEX）**：双方同时说，trajectory = `list[Tick]`，`FullDuplexOrchestrator`。
- **三层 runner**（`runner/README.md`）：Layer1 `run_simulation()`（纯执行+评测，无 registry/无副作用）→ Layer2 `build_*()`（名字→实例，靠 registry 解析）→ Layer3 `batch.py`（并发/checkpoint/重试/幻觉重试/状态监控）。**MAformac 抄这个分层**：纯评测函数（吃 trace 出 reward）/ 构造（吃契约 SSOT 出 mock env + tool schema）/ 批跑（N task × N trial + checkpoint）三层解耦。
- **config 默认**（`config.py`）：`MAX_STEPS=200` / `MAX_ERRORS=10` / `SEED=300` / `MAX_CONCURRENCY=3` / `NUM_TRIALS=1` / **agent+user temperature=0.0**（评测求确定性）/ eval-judge 模型 = `claude-opus-4-5`（用强模型当裁判）/ `MAX_RETRIES=3` + 指数退避。

---

## §1 🔴 评测核心：端态哈希比对 + 幻觉 no-op 重放（`environment/environment.py` 472 行 + `evaluator/evaluator_env.py` 361 行）

**这是全 repo 最该抄的算法。** MAformac"验收读回 mock 态"在这里有完整工业实现。

### 1.1 端态哈希比对（`evaluator_env.py:81-125`）
评测**不比对 agent 说了什么**，而是：
1. 起一个全新 mock env，喂初始态 + agent 实际 trajectory（`set_state`，line 85-89）。
2. 起另一个全新 gold env，喂初始态 + **gold reference actions 重放**（line 92-110）。
3. `get_db_hash()` / `get_user_db_hash()` 各自取**端态指纹**（`environment.py:275-291`，对 DB 做 hash）。
4. `agent_db_hash == gold_db_hash and user_db_hash == gold_user_hash` → reward=1，否则 0（line 116-125）。

→ **关键设计：gold action 列表是"一条参考解轨迹，用来推导目标端态，不是逐调用硬要求"**（`tasks.py:237-260` RewardType.DB 注释，`tasks.py:377-389`）。**agent 走任何路径只要达到等价端态就过**。这与 MAformac"L1 不丢脸、任意泛化说法只要落对端态卡片即对"完全同构——评测不锁话术、不锁调用序列，只锁端态。

### 1.2 🔴 幻觉工具调用作 no-op 重放（`environment.py:357-391` + CHANGELOG `[Unreleased] Fixed`）
`set_state` 重放 trajectory 时三层防御（这是 τ³ 最新修订，CHANGELOG 头条）：
- **(a) 幻觉工具名 → 跳过当 no-op**（line 359-372）：trajectory 里出现不存在的工具 → live env 当时返回 `ToolMessage(error=True)` 且不改态，重放也 `continue` 跳过（不抛异常）。**之前的 bug**：抛 ValueError → 整个 task 被 `run_with_retry` 重跑到 max-retries → 被归为 `INFRASTRUCTURE_ERROR`（被排除出 pass^k/avg_reward）→ **幻觉后又自救成功的轨迹被错杀**。修后：幻觉但恢复的算对；幻觉不恢复的靠**端态分叉自然失败**（DB hash 不匹配）。重复幻觉由 orchestrator `max_errors` 上界兜（`TOO_MANY_ERRORS`）。
- **(b) 非 mutating（读类）工具 → 跳过**（line 376-377）：读操作不改态，重放会引入非确定性输出比对问题，直接跳。
- **(c) mutating 工具 → 重放并比对 content**（line 378-390）：执行 + `json.loads` 比对 expected vs actual，不一致才抛。

→ **MAformac DemoGuard 直接抄**：①越界/未知工具（越 L1 allowlist）当 no-op + TTS 兜底，不崩；②读类（查空调温度）不改 mock 态、评测跳过；③写类（设温度 26℃）改 mock 态卡片 + 端态哈希校验。**"不崩"靠 no-op 不靠 try-catch 满地撒**。

### 1.3 env assertion（`evaluator_env.py:128-142`）
除 DB 哈希外，可跑命令式断言（`run_env_assertion` 返回 bool），各断言 reward 相乘。→ MAformac 可加"空调 power=on 且 temp∈[18,32]"类端态不变量断言。

---

## §2 🔴 reward 组合语义：分量乘积 + 一票否决（`evaluator.py:88-343` + `tasks.py:237-267`）

- **5 个 RewardType**（`tasks.py:263-267`）：`DB`（端态匹配）/ `ENV_ASSERTION`（断言全过）/ `COMMUNICATE`（须说的字串子串命中）/ `NL_ASSERTION`（LLM 判 NL 断言）/ `ACTION`（每条 gold action 被某 tool call 命中）。
- **最终 reward = reward_basis 里所有分量的乘积**（`evaluator.py:215-248`，`reward *= component`）。任一分量 0 → 总 0。**一票否决** = 不允许"端态对但话术错"蒙混。
- **默认 reward_basis = [DB, COMMUNICATE]**（`tasks.py:435`），对齐原始 τ-bench。
- **ACTION 是唯一把 gold action 列表升成"硬要求"的分量**（`tasks.py:255-258`）：只在 banking_knowledge 少数任务用，airline/retail/telecom **不用 ACTION**——因为它们要的是"达到端态"而非"复刻某条调用序列"。
- **action 匹配是集合包含 + 选择性参数比对**（`evaluator_action.py:16-59` + `tasks.py:178-195`）：gold action 用 `compare_with_tool_call` 找是否存在某 tool call 名字相同 + `compare_args` 指定的参数相等（compare_args=None 则比全部参数，=[] 则只比名字）。**全 gold action 都命中才 reward=1**（all-or-nothing，line 102-103）。

→ **MAformac C6 双轴 bench 直接映射**：
- **DB 轴 = 端态卡片匹配**（替代 home-llm 的"ToolCall 集合精确匹配"，更严：管端态不管调用形态）。
- **COMMUNICATE 轴 = TTS 须含某关键反馈**（如"已为您打开空调"）。
- **ACTION 轴 = L1 精做 ~10 case 锁调用**（窄域要复刻，用 compare_args 只比关键槽如 temperature，忽略无关槽）。
- **拒识 = 空 gold action + 该不该调**（home-llm 的空匹配语义，tau2 里是"reward_basis 不含 ACTION 时 gold actions 只推端态"）。

---

## §3 🔴 多跑方差度量 pass^k（`metrics/agent_metrics.py:113-191` + `runner/batch.py:517-611`）

- **`pass^k`**（`agent_metrics.py:113-126`，源 arXiv 2406.12045）：`pass^k = C(success_count, k) / C(num_trials, k)`。**直觉**：随机抽 k 次试跑全成功的概率。k=1 = 普通成功率；**k 越大越苛刻**（要求该 task 多次重跑都稳）。**这是衡量"小模型稳不稳"的核心指标**——单跑高分可能是运气，pass^k 暴露方差。
- **多 trial 种子机制**（`batch.py:517-518`）：master seed → `random.seed(config.seed)` → 派生 `num_trials` 个子 seed，每 trial 一个。每个 `(trial, task_id, seed)` 是独立 run 单元（line 601-611），checkpoint 用 `done_runs` 去重（断点续跑）。
- **基础设施错误剔除**（`agent_metrics.py:138-145`）：`INFRASTRUCTURE_ERROR`（从未跑起来的）排除出 pass^k/avg_reward，**不污染分数**。
- **min_k 守护**（`agent_metrics.py:158-165`）：若某 task 的 trial 数 < 预期，自动把 max_k 下调到实际最小值（不会用不存在的数据算 pass^k）。

→ **MAformac C6 直接抄 pass^k**：1.7B+LoRA 对模糊说法天然有方差，**must-pass 全集覆盖率不能只单跑**。每个 L1 case 跑 N trial（temp>0 时），报 pass^1（平均）+ pass^N（最坏稳定性）。bench 默认 temp=0 求确定性基线，加一组 temp=0.6（Qwen3 推荐）测真实方差。

---

## §4 🔴 失败分类法：11 错误标签 × 严重度（`evaluator/review_llm_judge.py:76-134` + `auth_classifier.py` + `hallucination_reviewer.py`）

评测除了"过/不过"，还有 **LLM-judge 二层定性诊断**（与 reward 计算解耦，`reviewer.py` 注释明确区分）：

### 4.1 11 个错误标签（`review_llm_judge.py:76-89`）—— MAformac C6 错误枚举的现成全集
`hallucination`（编造未 grounding 信息）/ `incorrect_interpretation`（误读工具结果）/ `guideline_violation`（违 policy）/ `revealed_info_early`（过早泄露）/ `inconsistent_behavior`（自相矛盾）/ **`tool_call_schema_error`（工具名错/缺参/类型错）** / **`tool_call_argument_error`（schema 对但参数值错）** / **`irrelevant_tool_call`（调了不相关工具）** / `premature_termination`（对方还在干活就提前结束）/ `missed_required_action`（漏做必须动作）/ `wrong_sequence`（顺序错）/ `other`。
→ **MAformac CLAUDE 铁律"错误用枚举"在这里有 11 类现成参考**。C6 失败 receipt 的 `error_tag` 字段直接借这套（裁剪到车控相关：schema_error / argument_error / irrelevant_call / missed_action / hallucination / refusal_wrong）。

### 4.2 严重度分级（`review_llm_judge.py:59-74`）
- **agent**：`critical`（直接致失败 OR 违安全/policy，即便 task 成了）/ `minor`（次优但没影响结果）。
- **user**：`critical_helped`（用户帮了不该帮的让 task 太易）/ `critical_hindered`（用户给错信息害了 task）/ `minor`。
→ 度量层（`agent_metrics.py:343-444`）统计"每 sim 最高严重度""首个 critical 错误来自 agent 还是 user""按 tag×severity 计数"。**MAformac 借"critical（违 risk-policy R0/越 ASIL）vs minor（次优但端态对）"二分**——安全门违规永远 critical。

### 4.3 专项分类器（独立 LLM judge）
- **幻觉检查器**（`hallucination_reviewer.py:25-103`）：fact-check 用户模拟器是否编造了指令外信息（zip/order-id/偏好等）；**输出结构 = reasoning 先于 verdict**（强制先推理再判，line 81）；解析失败 → 安全返回"无幻觉"（line 213-225，不让裁判崩导致误杀）。
- **认证分类器**（`auth_classifier.py:28-73`）：三态 `succeeded/failed/not_needed`，正则抽 JSON + 非法值 fallback `not_needed`（line 92-110）。
→ **MAformac C7 借**：ASR 误识/语义澄清是否"编造了用户没说的槽值"= 幻觉检查器同型（车控里"用户说热，模型自己编了 26℃"= 该澄清却幻觉）。

---

## §5 🔴 编排状态机：三角色回合制 + 协议守护（`orchestrator/orchestrator.py` 1031 行）

- **三角色**（`Role` enum，line 41-44）：`AGENT` / `USER` / `ENV`。状态机变量 = `from_role` / `to_role` / `message`（line 452-455）。
- **`run()` 模板方法**（line 260-291）：initialize → while not done: step + check_termination → finalize；**finally 兜底 cleanup**（line 285-291，异常也释放 WS/线程资源）。
- **`step()` 路由**（line 823-900）：AGENT/ENV→USER / USER/ENV→AGENT / AGENT/USER→ENV 三条边，每条边推进 `from/to/message`，工具调用走 ENV 边执行后回原 role。
- **🔴 终止枚举 `TerminationReason`**：`AGENT_STOP`（agent 发 `###STOP###`）/ `USER_STOP` / `MAX_STEPS` / `TOO_MANY_ERRORS` / `AGENT_ERROR` / `USER_ERROR` / `TIMEOUT` / `INFRASTRUCTURE_ERROR`。**只有 AGENT_STOP/USER_STOP 才进评测**（`evaluator.py:113-123`：其它终止 → reward=0 + note "premature"）。→ **MAformac demo 同理**：跑飞/超步/太多错的 trace 不算分，直接 0。
- **🔴 通信协议守护**（`_check_communication_error` line 694-732）：① 消息不能空（无文本无工具调用）；② 不能同时带文本+工具调用（"消息要么说话要么调工具，不混"）；③ solo 模式 agent 只能调工具（除 stop）。违规 → AGENT_ERROR/USER_ERROR 终止。→ **MAformac 单发铁律的协议层背书**：与 home-llm `MAX_ITER=0` 同源——**一条消息要么是 NL 回复要么是单跳 ToolCallFrame**，evaluator 层硬校验。
- **ENV-deferred 终止检查**（line 740-741）：等 env 回工具结果时**跳过 max_steps/max_errors 检查**（不在半中间砍断工具往返）。
- **stale guard / 历史裁剪**：`get_trajectory` 按 timestamp 排序 + 赋 turn_idx（line 902-916）；初始化时校验 message_history 配对完整（`validate_message_history` line 926-958：n 个 tool call 必须跟 n 个 requestor 匹配的 tool message）。

---

## §6 🔴 语音全双工 + barge-in（`orchestrator/full_duplex_orchestrator.py` 632 行）—— C7 蓝本

- **Tick 模型**（line 40-61）：trajectory = `list[Tick]`，每 Tick 含同一时刻**双方的 chunk + 各自工具调用/结果**。半双工是"你一句我一句"，全双工是"双方同 tick 各出 chunk"。
- **🔴 双方同 tick 交换 chunk（= barge-in 内生）**（line 307-358）：`incoming_for_user = current_agent_chunk` / `incoming_for_agent = current_user_chunk`，两个 `_process_participant_turn` 并列跑——**用户可以在 agent 说话的同 tick 插话**，打断是结构内生的，不需特判。
- **🔴 工具结果延后一 tick 投递（关键音频工程）**（line 114-120, 336-358）：工具**本 tick 执行**，但结果存 `pending_*_tool_results`，**下一 tick 才随 chunk 投递**。目的（line 115-118 注释）：tool 投递期不注入静音、保住发起 tool-call 那 tick 的 agent 音频、保用户音频连续。→ **MAformac C7 barge-in 直接抄**：mock 车控执行（开空调）不阻塞音频流，TTS 反馈延后一帧投，按钮打断（D13 首版）= 用户 chunk 抢占。
- **chunk 剥工具调用**（line 471-476）：投给对方的 chunk 只留 speech、`tool_calls=None`（语音不传工具调用），但 tick 历史里原 chunk 保留 tool_calls 供 linearize/配对。
- **响应性度量**（line 583 `compute_responsiveness_info`）：检测"无响应时段"（agent 卡住不出声），度量层统计 `sims_with_unresponsive_period`（`agent_metrics.py:55-56`）。→ **MAformac demo 不丢脸的量化**：首字延迟 / 静默时段 = 客户现场体感指标。
- **NL 断言的 tick→message 线性化**（`evaluator_nl_assertions.py:144-189`）：containment-aware 把重叠 chunk 拍平成顺序消息（只留 speech），供 LLM judge。

---

## §7 🔴 train/test/base split + 评测-训练防泄漏（`registry.py:191-243` + `domains/*/environment.py` + `data/*/split_tasks.json`）

- **split 机制**（`retail/environment.py:35-54`）：`get_tasks(task_split_name)` 读 `split_tasks.json`（键→task_id 列表）过滤。registry 注册时挂 `get_task_splits` loader（`registry.py:195-211, 317-345`）。
- **🔴 split 语义（实测 JSON）**：
  - retail: `{train:74, test:40, base:114}` → **base = train ∪ test**（114=74+40）。
  - airline: `{train:30, test:20, base:50}`（50=30+20）。
  - telecom: `{small:20, train:74, test:40, full:2285, base:114}`（full=程序化生成的 2285 大集）。
- **🔴 防泄漏纪律（README:33）**："**评测 agent（非训练）用 `base` split 跑全集**；train/test 是给训练用的——这样你不会在训练任务上评测"。
→ **MAformac 直接抄这套 split 治理**：契约 SSOT 全集（≈3990 source rows）派生 LoRA 训练集（train split）+ **held-out 评测集（test split，C5 防死记的现成机制）**+ base = 全集覆盖率死门（C6 不丢脸基线）。**train/test 物理隔离 task_id**，C6 跑 base，C5 训只看 train，评测看 test——这是 maformac-lora-train-eval-stack memory 里"held-out 防假提升"的工程载体。

---

## §8 Gym 接口（`gym/README.md` + `gym/gym_agent.py` 1539 行）—— 可选，C4 路由调试

- **Gymnasium 兼容 env**：`AgentGymEnv`（你扮 agent 打 user-sim）/ `UserGymEnv`（你扮 user 打自动 agent）。`reset()`/`step(action)` 标准接口，observation = 对话历史字符串，info 带 tools+policy。
- **action 双格式**（README:309-329）：JSON `{"name":...,"arguments":{...}}` 或 functional `search_flights(origin='NYC')`。
- **🔴 双线程同步**（README:378-488）：主线程（gym 接口）+ orchestrator 守护线程，靠 `Lock`（互斥保 `_next_action`/`_observation`）+ `Event`（`_agent_turn_finished` 信号）。orchestrator 在 `generate_next_message` 里 `.wait()` 阻塞等外部 action → 主线程 `set_action` + `.set()` 放行。
→ **MAformac 多 drop**：这套线程模型是给 RL/人在环训练的，demo 不需要。**copy 概念**：step-wise 可控 agent 接口用于 C4 三层路由的逐步调试（喂一句 → 看路由判 L1/L2 → 看 ToolCall），但不抄双线程（Swift 用 async/await 顺序跑即可）。

---

## §9 75+ task fixes 机制：错误 gold 修正 + TaskIssue 追踪（README:28 + `tasks.py:270-363` + CHANGELOG）

- **τ³ 的 75+ task fixes**（基于 SABER 分析 arXiv 2512.07850）：删错误的 expected action、澄清歧义指令、修不可能约束、补缺失 fallback。**洞察：基准本身会错，gold 不是天授**。
- **TaskIssue 模型**（`tasks.py:278-363`）：每 task 挂 `issues` 列表，含 `status`（open/resolved/wont_fix）/ `resolution` / `pr_link` / `simulation_file`（指向复现问题的 sim 结果文件）/ `author_email`。**= 基准质量的版本化账本**。
→ **MAformac 借这个纪律**：C6 的 gold 端态/L1 allowlist 不是一次定死——**埋 TaskIssue 字段**（哪条 case 的 gold 端态被质疑/已修/PR 链接），契约 SSOT 改一手源（金钥匙表）时，受影响的 bench case 标 issue。与 §28 一手源血缘同源——**bench gold 也有血缘，会被一手源修订推翻**。

---

## §10 Cross-cutting pattern（横切设计思想，跨文件提炼）

1. **端态是事实源，文本不是**：评测、验收、防崩**全围绕 mock DB 端态哈希**（§1）。模型说什么、调用什么序列都不锁，只锁"重放后端态等不等于 gold"。← MAformac CLAUDE 铁律的工业实现。
2. **不崩靠 no-op 不靠 catch**：幻觉工具/越界/读类调用统一"跳过当 no-op"，让端态分叉自然失败（§1.2）。错误是**数据（ToolMessage error=True）不是异常**。
3. **一票否决 + 分量解耦**：reward=各分量乘积，每分量独立可关（reward_basis），诊断（review/auth/halluc）与计分解耦（§2/§4）。
4. **方差是一等公民**：pass^k 把"单跑运气"和"多跑稳定"分开，INFRASTRUCTURE_ERROR 不污染分（§3）。← 小模型评测必需。
5. **裁判先推理后裁决 + 失败安全**：所有 LLM-judge 强制 reasoning 字段在 verdict 前，解析失败 fallback 到"安全侧"（无幻觉/not_needed/不误杀，§4）。
6. **协议守护在 code**：消息形态（不混文本+工具、不空、solo 只工具）由 orchestrator 硬校验，违规即终止（§5）。← 单发铁律的协议层背书。
7. **音频流不被逻辑阻塞**：工具执行与音频 tick 解耦，结果延后一 tick 投递（§6）。← barge-in/低延迟的关键。
8. **训练-评测物理隔离**：train/test split 用 task_id 硬分，base=全集；评测跑 base，训练看 train（§7）。← 防泄漏/防假提升。
9. **gold 有血缘会被修订**：TaskIssue 账本追踪 gold 错误 + 一手源修订（§9）。← 基准质量版本化。

---

## §11 MAformac adopt / adapt / drop 映射

| tau2-bench 工程 | MAformac 落点 | 动作 | 服务层 |
|---|---|---|---|
| 端态哈希比对（gold 重放→hash→比对，任意路径达同端态即过）`evaluator_env.py:81-125` | C6 bench：mock 端态卡片匹配（替 ToolCall 精确匹配，更严） | **copy概念** | C6 |
| 幻觉工具调用作 no-op 重放（不崩，端态分叉自然失败）`environment.py:357-391` | DemoGuard：越 L1 allowlist/未知工具 = no-op + TTS 兜底 | **copy概念** | C3/C6 |
| 非 mutating（读类）工具评测跳过 `environment.py:376-377` | 读类（查温度）不改 mock 态、bench 跳过 | **copy概念** | C6 |
| reward=分量乘积 + 一票否决 + reward_basis 可关 `evaluator.py:215-248` | C6 双轴：DB(端态)×COMMUNICATE(TTS反馈)×ACTION(L1锁调用) | **adapt** | C6 |
| action 集合匹配 + compare_args 选择性参数比对 `tasks.py:178-195` | L1 精做：只比关键槽(temperature)忽略无关槽 | **copy概念** | C6 |
| pass^k 多跑方差度量（C(s,k)/C(n,k)）`agent_metrics.py:113-126` | C6：每 case N trial 报 pass^1+pass^N，temp 0/0.6 两组 | **copy概念** | C6 |
| INFRASTRUCTURE_ERROR 剔除 + min_k 守护 `agent_metrics.py:138-165` | 跑飞/超步 trace 不污染覆盖率分数 | **copy概念** | C6 |
| 11 错误标签 × 严重度失败分类法 `review_llm_judge.py:76-134` | C6 失败 receipt error_tag 枚举(裁剪到车控6类)+critical/minor | **adapt** | C6 |
| 幻觉检查器（裁判先推理后裁决+失败安全）`hallucination_reviewer.py` | C7：ASR/语义"编造用户没说的槽值"检测 | **adapt** | C7 |
| 三角色回合制状态机 + 终止枚举 `orchestrator.py:41-44,734-750` | demo 编排：AGENT/USER(mock)/ENV(mock)+终止只 STOP 进评测 | **adapt** | C3/C6 |
| 通信协议守护（不混文本+工具/不空/单发）`orchestrator.py:694-732` | 单发铁律协议层硬校验(一条消息=NL或单跳ToolCall) | **copy概念** | C3 |
| ENV-deferred 终止检查（工具往返不被砍）`orchestrator.py:740-741` | mock 工具执行期不触发超步终止 | **copy概念** | C3 |
| Tick 全双工 + 双方同 tick 交换 chunk（barge-in 内生）`full_duplex_orchestrator.py:307-358` | C7 语音：用户可同帧打断 agent | **copy概念** | C7 |
| 工具结果延后一 tick 投递（保音频不断）`full_duplex_orchestrator.py:114-120,336-358` | C7：mock 车控执行不阻塞音频流，TTS 延后一帧 | **copy概念** | C7 |
| 响应性度量（无响应时段统计）`agent_metrics.py:55-56` + `full_duplex:583` | C7：首字延迟/静默时段=现场体感量化 | **copy概念** | C7 |
| train/test/base split（base=train∪test，评测跑base）`split_tasks.json` + README:33 | C5 LoRA 训 train / C6 跑 base(全集死门) / test=held-out 防死记 | **copy概念** | C5/C6 |
| TaskIssue 账本（gold 错误追踪+PR链+一手源修订）`tasks.py:278-363` | C6 gold 端态/L1 allowlist 血缘账本 | **adapt** | C6 |
| 三层 runner 架构(纯执行/构造/批跑解耦)`runner/README.md` | C6：纯评测fn / 构造(契约SSOT→mock env) / 批跑(N×N+checkpoint) | **adapt** | C6 |
| Gym 双线程 step-wise 接口 `gym/README.md` | C4 路由逐步调试用 step-wise 概念(不抄双线程) | **copy概念** | C4 |
| Python/uv runtime、LiveKit/OpenAI Realtime 等云 provider、redis cache、k8s 批跑、5 个客服域语料 | — | **drop**（云/服务/语料载体，端侧不适用） | — |

---

## §12 关键工程洞察（for MAformac demo + bench）

1. **"验收读回 mock 态"在 tau2 有完整算法**：端态哈希比对（§1.1）+ gold 重放 + 任意路径达同端态即过——MAformac 不用自己发明，照搬即可。**这是全 repo 第一价值**。
2. **"不丢脸/不崩"的工程定义清晰**：幻觉/越界 = no-op + 端态自然分叉失败（不崩）；终止只 STOP 进评测（跑飞不算分）；pass^k 暴露方差（不靠单跑运气）。三件套全有现成实现。
3. **失败分类法是现成 schema**：11 标签 × 严重度（§4.1），MAformac"错误用枚举"铁律的参考全集，裁剪到车控 6 类即用。
4. **train/test split 是 C5 防死记 + C6 防假提升的物理载体**（§7）：base=全集死门、test=held-out，与 lora-train-eval memory 的 3 个 HIGH 直接咬合。
5. **barge-in/低延迟靠"工具与音频解耦"**（§6）：工具结果延后一 tick 投递、双方同 tick 出 chunk——C7 语音 barge-in 不需特判，是 tick 结构内生的。
6. **裁判要先推理后裁决 + 失败安全**（§4.3, §10.5）：LLM-judge 强制 reasoning 在 verdict 前，解析失败 fallback 安全侧不误杀——C7 语义澄清/幻觉检测直接抄这个稳健性模式。
7. **gold 不是天授**（§9）：75+ task fixes + TaskIssue 账本说明基准本身会错——MAformac bench gold 端态要挂血缘、可被一手源（金钥匙表）修订推翻（与 §28 同源）。

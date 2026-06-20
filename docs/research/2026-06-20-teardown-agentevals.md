# agentevals 工程/算法 teardown — MAformac C4/C6 轨迹评分的现成实现

> **缘起**：MAformac 的 C6（vehicle-tool-bench）和 C4（三层路由）都要「评路径，不只评最终态」——客户说一句话，1.7B 是否走对了层、出对了一组 ToolCall、该拒识时拒识。`langchain-ai/agentevals`（⭐ LangChain 官方 agent-eval 库，HEAD `db42ec1` 2026-06-17，3 天前活跃，**MIT**）正是「轨迹/工具调用集合匹配 + LLM-as-judge」的成熟实现。本文 = 逐文件拆 Python 实现（JS 是 1:1 镜像，不重复拆）。
>
> clone 在 `~/workspace/raw/05-Projects/MAformac/ref-repos/agentevals`（CLAUDE §6：只读参考，不进仓）。**MIT 许可**，但本项目红线仍是「翻成 Swift 设计思想，不 import Python/Node」——agentevals 依赖 `langchain_core` / `openevals` / `langgraph`，整库进不了端侧 iOS，价值在**算法形态**。
>
> **核心结论**：agentevals 把「轨迹评分」拆成两条正交轴——(1) **确定性集合匹配**（strict/unordered/subset/superset 四档 × tool-args 四档，全是 set 运算，零 LLM、零随机），(2) **LLM-as-judge**（只评「步骤是否逻辑连贯/高效」这类主观项）。**这正是 MAformac eval-system-overview §「judge 只评主观文本，硬门失败不可改判」的现成代码骨架。** 最值得抄的不是某个 match 模式，而是 **`tool_args_match_overrides` 的「每工具可插自定义 matcher」机制**——MAformac 的「空调温度 ±1℃ 容差」「rgb 颜色容差」「车窗 0-100% 范围容差」全靠它落地，不用为每种容差写一个 scorer。

---

## §0 库结构与读序（1760 行 Python，按「算法核心先」排）

```
python/agentevals/
  types.py        (41)   ← ToolArgsMatchMode / ToolArgsMatchOverrides 类型契约
  utils.py        (33)   ← _run_evaluator 薄包装（委托 openevals）
  trajectory/
    utils.py      (212)  ← 🔴 算法核心：归一化 + tool-call 抽取 + _is_trajectory_superset + 5 个 matcher
    match.py      (197)  ← 工厂：4 模式 × 4 args 模式 dispatch + 校验
    strict.py     (181)  ← 严格匹配 scorer（顺序+角色+逐条 tool-call 计数）
    unordered.py  (127)  ← 无序 = 双向 superset
    subset.py     (127)  ← 子集 = 单向 superset（ref ⊇ out）
    superset.py   (132)  ← 超集 = 单向 superset（out ⊇ ref）
    llm.py        (251)  ← message-level LLM judge（两套 rubric：有/无 reference）
  graph_trajectory/
    utils.py      (130)  ← 从 LangGraph state-history 抽「步骤图」轨迹
    strict.py     (81)   ← 步骤序列严格相等
    llm.py        (236)  ← 🔴 图轨迹 LLM judge（评多步路由是否逻辑连贯）
```

**读序锚点**：`trajectory/utils.py` 是真正的算法心脏（5 个 matcher + 贪心二部匹配都在这），4 个 mode 文件全是它的薄 wrapper；`graph_trajectory/llm.py` 的 rubric 是 C4 三层路由评测的现成模板。

---

## §1 类型契约 `types.py`（41 行）— 两个枚举撑起全部灵活性

- **`ToolArgsMatchMode = Literal["exact", "ignore", "subset", "superset"]`**（types.py:26）：单个 tool-call 的**参数**怎么比。`exact`=全等，`ignore`=只看工具名不看参数，`subset`/`superset`=参数 dict 的包含关系。
- **🔴 `ToolArgsMatchOverrides = dict[str, Union[ToolArgsMatchMode, list[str], Callable[[dict,dict],bool]]]`**（types.py:28-30）：**per-tool 覆盖**。键 = 工具名，值可以是：
  1. 一个 mode 字符串（该工具单独用别的 mode），
  2. **一个 key 列表**（只要这几个字段相等就算匹配，其余忽略），
  3. **一个自定义 `Callable[(dict,dict)->bool]`**（任意容差逻辑）。
- 这两个枚举是整库灵活性的源头——**MAformac 的全部容差需求（温度 ±1、颜色近似、范围内即可）都落在 override 的第 2/3 种**，不用改 scorer。

## §2 算法心脏 `trajectory/utils.py`（212 行）— 让评分可靠的核心工程

### 🔴 防御性归一化 `_convert_to_openai_message` / `_normalize_to_openai_messages_list`（utils.py:22-65）

让评分前**先把混乱输入统一成一种结构**——和 home-llm 的「防御性解析」同源，区别是这里防御的是**输入消息的多形态**（OpenAI dict / LangChain BaseMessage / 裸 dict / `{"messages": [...]}` 包装）：
- `role` 为 `ai`/`assistant` 且有 `tool_calls` → 给每个 tool_call 补 `id`（utils.py:28-32），缺失字段补空（content=None→""，utils.py:35-36）。
- 顶层 dict 既可能是单条消息（有 `role`）也可能是 `{"messages": [...]}` 包装（utils.py:56-62）——**容两种入口**，否则上游每个调用方都要自己拆。
- **设计意图**：评分逻辑只面对一种干净结构，所有形态分歧在边界一次性吸收。**MAformac 的 trace 来自端侧多渠道（ASR→意图→ToolCall），必须有同样的「入口归一化」，否则 scorer 到处 if-else。**

### 🔴 tool-call 抽取 + 双格式 `_normalize_tool_call` / `_extract_tool_calls`（utils.py:68-87）

- `_normalize_tool_call`（utils.py:68-75）：兼容 **OpenAI 嵌套格式**（`{"function":{"name","arguments":<json字符串>}}`，`arguments` 是**字符串**要 `json.loads`）和**扁平格式**（`{"name","args":<dict>}`）。统一吐 `{"name", "args":dict}`。
- `_extract_tool_calls`（utils.py:78-87）：把一条轨迹（消息列表）里所有助手消息的 tool_calls **拍平成一个有序列表**——**轨迹比较的第一步是「降维成 ToolCall 序列」**，把 NL 文本、tool result 等噪声全丢掉，只留「调了哪些工具、什么参数」。**这正是 MAformac C6「ToolCall 集合精确匹配」的预处理。**

### 🔴 贪心二部匹配 `_is_trajectory_superset`（utils.py:90-134）— 全库复用的引擎

「output 是否是 reference 的超集」= **每个 reference tool-call 都能在 output 里找到一个未被占用的匹配**：
```
matched = set()                       # 已被占用的 output 下标（utils.py:100）
for ref_call in reference_tool_calls: # utils.py:103
    found = False
    for out_idx, out_call in enumerate(output_tool_calls):  # utils.py:108
        if ref_name != out_name: continue          # 名字必须相等（utils.py:112）
        if out_idx in matched: continue            # 不复用同一个 output（utils.py:116）
        matcher = _get_matcher_for_tool_name(...)  # 取该工具的参数 matcher（utils.py:120）
        if matcher(out_args, ref_args):            # utils.py:125
            matched.add(out_idx); found = True; break
    if not found: return False                     # 有 ref 没人接 → 不是超集（utils.py:131）
return True
```
**关键工程点**：
1. **贪心 + 占用集（utils.py:100/116）防重复计数**——「ref 里两个 `set_temp`」必须对上 output 里**两个不同的** `set_temp`，不能一个顶俩。这是 set-match 最容易写错的地方，agentevals 用 `matched_reference_calls` 集合一次解决。
2. **名字硬门（utils.py:112）**：工具名不等直接跳过，参数 matcher 只在同名时才跑——**层级化短路，省算力也避免跨工具误匹配**。
3. **这一个函数撑起 3 个 mode**：unordered = 双向 superset（§3）、subset = `_is_trajectory_superset(ref, out)`、superset = `_is_trajectory_superset(out, ref)`。**DRY 到极致**。

### 🔴 5 个参数 matcher + 工厂 `_get_matcher_for_tool_name`（utils.py:137-212）

- `_exact_match`（utils.py:137）：整 dict 全等。
- `_subset_match`（utils.py:141-146）：output 的每个 kv 都在 ref 里 → output 参数是 ref 的子集。
- `_superset_match`（utils.py:149-154）：ref 的每个 kv 都在 output 里 → output 参数是 ref 的超集。
- `_ignore_match`（utils.py:157-158）：永远 True（只看工具名）。
- **🔴 `_get_partial_matcher_on_keys`（utils.py:174-191）**：传一个 key 列表（**支持 `"a.b.c"` 点号嵌套路径**，utils.py:176-183），只比这几个字段相等，其余忽略。**这是 MAformac「只校验 device+action+核心槽，忽略次要参数」的现成实现。**
- **`_get_matcher_for_tool_name`（utils.py:194-212）= 决策树**：先取全局 mode 的 matcher → 若该工具在 overrides 里，则 override 优先（字符串→换 mode；callable→直接用；list→`_get_partial_matcher_on_keys`）。**这就是 per-tool 可插容差的全部魔法，13 行。**

## §3 四档模式 dispatch `match.py` + 各 mode 文件 — 薄 wrapper

- **工厂 `create_trajectory_match_evaluator`**（match.py:24-109）：闭包捕获 `trajectory_match_mode` + `tool_args_match_mode` + `tool_args_match_overrides`，dispatch 到对应 `_scorer`（match.py:72-83），入口校验非法 mode 直接 `raise ValueError`（match.py:81-88）。**返回一个 `evaluator(outputs, reference_outputs)` 纯函数**——配置一次，到处调，这个「工厂返回 closure」形态 Swift 直接对译成「`TrajectoryMatcher(mode:argsMode:overrides:)` 一个 struct + 一个 `match()` 方法」。
- **`strict._scorer`（strict.py:20-76）= 唯一不走 `_is_trajectory_superset` 的**：它逐条消息 zip 比对——长度等（strict.py:34）→ 角色等（strict.py:37）→ tool_calls 有无对齐（strict.py:39-44）→ **同一条助手消息内**的 tool_calls 用 `seen[]` 占用数组做 set-match（strict.py:54-75）。**「顺序 + 角色 + 每步 tool-call 数量」三重严格**，对应 C6「state_delta 严格回读」级别的死门。
- **`unordered._scorer`（unordered.py:33-37）**：`_is_trajectory_superset(out,ref) and _is_trajectory_superset(ref,out)` = 双向超集 = **集合相等（忽略顺序）**。**这是 MAformac C6「ToolCall 集合精确匹配」最贴的一档**——客户「打开空调、打开座椅加热」不管模型先调哪个都算对。
- **`subset._scorer`（subset.py:28-31）**：`_is_trajectory_superset(reference, outputs)` → 模型**没多调**（ref ⊇ out）。对应 C6「不该越界多动作」死门（→ 多调即 fail）。
- **`superset._scorer`（superset.py:33-36）**：`_is_trajectory_superset(outputs, reference)` → 模型**至少调全了关键工具**，多调可接受。对应「关键安全动作必须出现」。
- **观察**：unordered/subset/superset 三个 mode 文件里 `_scorer` 都把 `tool_args_match_mode` 硬写成 `"ignore"`（unordered.py:84 / subset.py:77 / superset.py:82 的旧 deprecated 函数），但**新工厂路径（match.py）把 args mode 透传**——新 API 才支持「无序 + 参数精确」组合。**抄要抄工厂路径，别抄 deprecated 顶层函数。**

## §4 LLM-as-judge `trajectory/llm.py`（251 行）— 两套 rubric 的边界

- **两个 prompt 常量**（llm.py:27-71）：`TRAJECTORY_ACCURACY_PROMPT_WITH_REFERENCE`（有金标）和 `TRAJECTORY_ACCURACY_PROMPT`（无金标，让 judge 从首末消息**自己推断目标**再评）。**Rubric 只问 4 件事**（llm.py:31-36）：步骤间逻辑连贯 / 有清晰推进 / 相对高效（**显式写「不需要完美高效」**）/ 与 reference 语义等价。
- **🔴 judge 评的是「主观推理质量」，不是「ToolCall 对不对」**——后者是 §3 确定性硬门的活。**这正是 MAformac eval-system-overview §「judge 只评主观文本，硬门失败不可改判」的来源形态**：先跑确定性 set-match 当死门，judge 只在「步骤是否合理」这类没法用 set 表达的维度补位。
- **可调旋钮**（llm.py:113-116）：`continuous`（True→0~1 浮点分，False→布尔）、`choices`（限定可选分值如 `[0,0.5,1]`）、`use_reasoning`（要不要让 judge 先写理由再打分，默认 True = **先解释后评分**降幻觉）、`few_shot_examples`。
- **few-shot 结构**（README:1065）：`[{"inputs","outputs","reasoning","score"}]`——**「先示范推理再给分」的 ICL**，和 home-llm 的动态 few-shot 同思路，但这里喂的是**评分员**不是被测模型。

## §5 图轨迹 `graph_trajectory/` — C4 三层路由评测的现成模板

### 抽取 `utils.py`（130 行）— 把执行 trace 降维成「步骤图」

- `extract_langgraph_trajectory_from_snapshots`（utils.py:17-82）：从 LangGraph 的 state-history 抽出 `GraphTrajectory = {inputs, results, steps}`（types.py:14-17），其中 **`steps: list[list[str]]`** = 每轮执行了哪些节点名（如 `["__start__", "agent", "tools"]`）。
- **🔴 `__interrupt__` 哨兵**（utils.py:58-59）：human-in-the-loop 中断被显式记成步骤里的 `"__interrupt__"` token——**「等用户补信息」是轨迹里的一等公民**。**直接对应 MAformac 的 clarifyTag**：模型「主动弃权、反问澄清」应该是轨迹里一个可被评测的显式步骤，不是 fail。
- **裁剪保 system**（utils.py:39-46）：results 里只留**最后一条消息**（`"to reduce context size"`）——评图轨迹时不需要每步全文，只要「这步产出了啥」。**和 home-llm「保系统 prompt + 裁历史」同源的上下文压缩纪律。**
- **逆序重建 + 长度校验**（utils.py:68-80）：state-history 是倒着来的，全部 reverse 回正序；**inputs/results/steps 三者长度不等就 warn**（utils.py:73-80）——**轨迹解析的一致性自检，不静默吞坏数据。**

### `strict._scorer`（strict.py:9-25）— 步骤序列严格相等

- 步骤数不等直接 False（strict.py:18），逐步 `output != reference_output` 即 break（strict.py:21-24）。**「路由必须走一模一样的节点序列」**——C4 里对应「L1 精确指令必须走规则快路，不许误入慢路」这种死门。

### 🔴 `llm.py`（236 行）— 图轨迹 judge = C4 路由评测模板

- **`DEFAULT_REF_COMPARE_PROMPT`**（llm.py:20-42）：rubric 同 §4，但**显式解释哨兵语义**——「`__start__` 是入口，`__interrupt__` 是 human-in-the-loop 等待」（llm.py:33-34）。让 judge 看得懂「中断去问用户」是合理步骤不是错。
- **`_format_thread`（llm.py:45-54）**：把 inputs/results/steps 三元组**交织成 `<input>/<trajectory>/<result>` 块**喂 judge——**多轮上下文的结构化呈现**。
- **reference 是可选的**（llm.py:75-78）：有金标就「以此为参考评分」，没有就「评步骤本身是否逻辑高效」。**MAformac 全集 3990 不可能每条都有金标轨迹，这种「无 ref 也能评连贯性」的形态正合用。**

---

## §6 Cross-cutting pattern（横切设计思想，5 条）

1. **两轴正交：确定性 set-match（硬门）⊥ LLM-judge（软评）**。硬门零 LLM、零随机、可复现；judge 只碰「逻辑是否连贯/高效」这类没法用 set 表达的主观项。**judge 永远不能改判硬门**——MAformac eval-system-overview 已内化此原则，agentevals 是它的代码出处。
2. **一个引擎撑多 mode（`_is_trajectory_superset`）**。unordered/subset/superset 三档全是它的单/双向调用，strict 是唯一的特例（加顺序+角色）。**抄时只需实现 1 个贪心二部匹配 + 1 个严格逐条比对，4 档全有。**
3. **per-tool 可插 matcher（`tool_args_match_overrides`）= 容差的统一出口**。温度 ±1、颜色近似、范围内即可、点号嵌套字段——全是「给某工具挂一个 `(dict,dict)->bool`」，不为每种容差写新 scorer。**这是本库对 MAformac 最大的工程红利。**
4. **入口防御性归一化吸收所有形态分歧**。多种消息格式、嵌套/扁平 tool-call、字符串/dict 参数，全在 `_normalize_*` 一次性统一，评分逻辑只面对干净结构。**和 home-llm「三层防御解析」同纪律，只是防御对象不同（这里防输入形态，那里防模型输出畸形）。**
5. **轨迹 = 降维后的「ToolCall 序列 / 步骤图」**，不是原始消息流。评分前先 `_extract_tool_calls` 拍平丢噪声（message-level），或 `extract_*_trajectory` 抽节点名（graph-level）。**「评什么」先定义清楚降维投影，再比较。**

---

## §7 adopt / adapt / drop 映射 → MAformac C4/C6

| # | agentevals 形态（file:line） | 动作 | 服务 C 层 | 为什么 |
|---|---|---|---|---|
| 1 | `_is_trajectory_superset` 贪心二部匹配 + 占用集（utils.py:90-134） | **copy概念** | C6 | C6「ToolCall 集合精确匹配」的标准算法；占用集防重复计数是必抄的正确性核心；Swift 重写 ~30 行 |
| 2 | 四档 trajectory mode（strict/unordered/subset/superset，§3） | **copy概念** | C6 | 客户随口多说/少说/换序，需要 unordered（集合相等）+ subset（不越界）+ superset（关键动作必出）分档评，不是单一 exact |
| 3 | `tool_args_match_overrides` per-tool 可插 matcher（types.py:28 + utils.py:194-212） | **copy概念** | C6 | MAformac 容差（温度 ±1℃、风量档、颜色近似、车窗 0-100% 范围内）的统一落点；避免每种容差写一个 scorer |
| 4 | `_get_partial_matcher_on_keys` 点号嵌套 key 列表匹配（utils.py:174-191） | **copy概念** | C6 | 「只校验 device+action+核心槽，忽略次要参数」直接对应 C1 的 device×原语×槽三元；嵌套路径支持槽在子 dict 里 |
| 5 | 入口归一化 `_normalize_to_openai_messages_list`（utils.py:22-65） | **adapt** | C6 | 思想抄（边界一次性吸收形态分歧），但 MAformac trace 是自定义 schema（ASR→意图→ToolCallFrame），归一化目标结构换成 MAformac trace，不抄 OpenAI message 格式 |
| 6 | `_extract_tool_calls` 轨迹降维成 ToolCall 序列（utils.py:78-87） | **copy概念** | C6 | 评分前先丢 NL/result 噪声只留 ToolCall——MAformac C6 比对前同样要从 trace 抽出 ToolCall 序列 |
| 7 | judge 两轴边界：硬门 set-match ⊥ judge 评主观（llm.py rubric + §6.1） | **copy概念** | C6 | MAformac 已定「judge 只评 clarify/refusal 文本，硬失败不改判」；agentevals 是此架构的成熟出处，照搬 rubric 的 4 条 + use_reasoning 先解释后评分 |
| 8 | `continuous`/`choices`/`use_reasoning`/`few_shot_examples` judge 旋钮（llm.py:113-116） | **adapt** | C6 | 旋钮思想抄（离散分值 choices + 先理由后分降幻觉 + few-shot 锚定评分尺度），但端侧 judge 用本地 Qwen，prompt/few-shot 用中文车控样例 |
| 9 | `graph_trajectory` 步骤图 + `__interrupt__` 哨兵（gt/utils.py:58-59 + gt/llm.py:33-34） | **copy概念** | **C4** | C4 三层路由评测的现成模板：把「走了哪层（规则快路/意图收缩/慢思考）」记成 steps，**clarifyTag/拒识 = `__interrupt__` 式显式步骤**，是可评测的一等公民不是 fail |
| 10 | `graph_trajectory/strict` 步骤序列严格相等（gt/strict.py:9-25） | **adapt** | C4 | 「L1 精确指令必须走规则快路、不许误入慢路」= 路由步骤序列死门；改成 MAformac 三层路由的层名序列 |
| 11 | 图轨迹 judge 无 reference 也能评连贯性（gt/llm.py:75-78） | **copy概念** | C4 | 全集 3990 不可能每条有金标轨迹；「无 ref 评步骤逻辑/高效」补位 |
| 12 | LangChain/openevals/langgraph 依赖 + 工厂返回 closure 的 Python 形态 | **drop** | — | 整库依赖进不了端侧 iOS；Python 闭包工厂翻成 Swift struct+method；judge 的 OpenAI/LangChain client 换本地 LLMBackend |
| 13 | LangGraph state-history 递归抽取（gt/utils.py:85-130） | **drop** | — | MAformac 无 LangGraph runtime；trace 自己埋点产 GraphTrajectory，不抄 Pregel/StateSnapshot 抽取逻辑 |

---

## §8 一句话

agentevals 把「评 agent 走得对不对」拆成**确定性集合匹配（4 档 trajectory × 4 档 tool-args，一个贪心二部引擎撑全部）+ per-tool 可插容差 matcher + LLM-judge 只评主观连贯性**三件套——MAformac C6 的「ToolCall 集合硬门 + 容差」和 C4 的「三层路由步骤图 + clarify 当 `__interrupt__` 一等公民 + judge 不洗白硬失败」全能照这个形态用 Swift 重写，**最大红利是 `tool_args_match_overrides` 让所有容差走一个统一出口、不必为每种容差写新 scorer**。

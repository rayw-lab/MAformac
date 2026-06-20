# Teardown — Drizzt321/ha-voiceagent-llm-benchmark（transcript→tool eval 蓝本，服务 C6/C7）

> 巨人肩膀深拆（blueprint-teardown 8 步）。逐文件读全（不 head/不抽样），抓"让 eval 可靠的核心算法/旋钮/防御"，引 file:line。
> **缘起**：MAformac C6 = vehicle-tool-bench（"客户随意说全集 → 不丢脸"的覆盖率死门）；C7 = voice（transcript→意图→ToolCall）。本 repo **正好就是"隔离 LLM 决策层、给 utterance 判它有没有调对工具调对参数"** 的成熟 eval（Inspect AI + llama.cpp + Qwen2.5/3，真跑过 12 模型 × 4 量化 × 多 tier）。它不测整条语音管线（wake→STT→LLM→TTS），只切**最关键的 LLM tool-call 决策点**——和 MAformac C6 的边界一字不差。
>
> **license**：Apache-2.0（宽松，方法可 adopt；Python→翻译成 Swift 设计思想，不 import 代码）。
> **clone**：`~/workspace/raw/05-Projects/MAformac/ref-repos/ha-voiceagent-bench/`（只读参考，不进仓）。
> **规模**：核心 src 8 文件 1216 行 + scripts 1487 行 + docs 3274 行（failure-patterns.md 660 行是真金）。

---

## 0. 硬结论（一句话先行）

**这个 repo 的真智慧不在"跑分框架"，在三处 README 看不到的工程：①把单一标量 pass/fail 拆成 6 维诊断（让你知道"为什么错"而不只是"错了"）+ alternative/quality 容多正解；②`generate(tool_calls="none")` 把工具变 no-op 桩——只捕获模型想调什么、绝不执行（纯离线判分，零副作用）；③一套 F1–F10 失败分类法（端侧小模型在 tool-call 上具体怎么崩的实证账本，每条配 prompt 缓解 + 实测 delta）。** 这三处直接搬进 MAformac C6，比我们手搓一个"集合精确匹配"强一个量级——因为它解决的是"小模型怎么崩"而不只是"对不对"。

外加四个让 eval **可信**（而非好看）的纪律：`--max-connections 1` 串行（否则延迟测的是排队深度不是推理时间）、first-sample cold-prefill 必剔除（KV 冷启动伪 outlier）、多 run + FP 非确定性显式承认、`/no_think` thinking-token 抑制（延迟 9.5s→1.7s 不掉准）。

---

## 1. 工程链路（数据怎么流）

```
test_cases.ndjson (utterance + expected_tool_calls + alt + response_type)
inventory.yaml (areas + entities：友好名/state/属性)
        │
        ▼  dataset.py  load_ha_test_cases()
   Inspect Sample(input=utterance, target=expected_calls_json, metadata={alt, resp_type, tier})
        │
        ▼  solver.py  ha_voice_solver()
   build_system_prompt(指令 → 实体清单 → 时间戳)  ← cache-friendly 顺序
   use_tools(*32 个 HA intent ToolDef)            ← tools.py，全是 _noop 桩
   generate(state, tool_calls="none")             ← ★ 发工具定义但不执行，只捕获
        │
        ▼  scorers/tool_call.py  tool_call_scorer()
   _extract_tool_calls(state) → 实际调用
   _score_dimensions() → 6 维 C/I/N
   overall = all(applicable == C)
   失败 → 遍历 alternative_expected_tool_calls，命中即 C + 记 MATCH_QUALITY
        │
        ▼  .eval log (zip)：per-sample score + total_time + token + explanation
        ▼  run_benchmark.py 编排矩阵 / 抽 n_samples+avg_latency / 出报告
```

关键：**模型当被测黑盒，框架只在两端做事**——左端拼一个"复刻 HA 真实下发格式"的 prompt + 工具清单，右端拿模型吐的 tool_calls 跟金标比。中间推理完全不碰。这正是 MAformac"文本→意图→ToolCall→DemoGuard→mock state"链路里 **C6 要的那段判分器**。

---

## 2. 逐文件拆（runtime/算法核心先，行号锚点）

### 2.1 `scorers/tool_call.py`（334 行）— ★ 算法核心，C6 直接母本

**6 维诊断打分**（`_score_dimensions` L118-132）：把传统单一 pass/fail 拆成 6 个独立检查——
- `response_type`（L163-184）：按期望应答类型分流。`action_done`→有调用即对；`query_response`→必须命中查询类工具集合（GetState/ClimateGetTemp/GetWeather/GetTime/GetDate，L172-178 硬编码）；`text_response`/`error`/`clarification`→**必须零调用**（拒识正确性！）。
- `format_valid`（L187-196）：调用结构良构——有 name + 参数没 `_raw`（malformed 标记）。
- `call_count`（L199-203）：数量匹配（多意图必须调对个数）。
- `tool_name`（L206-214）：**order-independent**（排序后比集合，L212-213）——"关窗+锁门"不在乎顺序。
- `args`（L217-238）：order-independent 参数匹配，贪心配对（`unmatched` 列表 L228，每个 expected 找第一个匹配的 actual 并移除，L231-235）。
- `no_hallucinated_tools`（L284-292）：只准调白名单内工具（`VALID_TOOL_NAMES` 32 个，L20-58）——调了清单外的名字 = 幻觉。

**overall 派生**（L79-80）：`applicable = {只取非 N}`，`overall = C iff all applicable == C`。**`Score.value` 只放标量 C/I**（gotchas §6 血泪：放 dict 会让 `accuracy()` 静默返回 0.000）；6 维明细全进 `Score.explanation`（L107, L300-325）。

**参数匹配规则**（`_tool_call_matches` L241-276，**MAformac 必抄的归一化逻辑**）：
- 大小写不敏感（`_normalize` L279-281：`str().strip().lower()`）。
- `_any_of` 柔性匹配（L252-260）：`name_any_of: [A, B]` 接受 A 或 B 任一——一个 utterance 多个合法实体名时用。
- 数值容差 ±0.01（L266-268）——`brightness:50` 匹配 `50.0`。
- 数组按排序集合比（L269-271）：`["light"]` 匹配 `["Light"]`。
- 空 expected args（L247-248）= 无约束，任意通过。
- actual 缺 expected 指定的 key（L262-264）= 失败。

**alternative + quality 容多正解**（L82-105，**C6 的"全集不丢脸"关键**）：主 `expected_tool_calls` 失败 → 遍历 `alternative_expected_tool_calls`，每个带 `quality`（optimal/equivalent/acceptable/degraded）+ `reason`，命中即 overall=C 并记 `MATCH_QUALITY`。**`Score.value` 仍二元 C/I——quality 不影响过不过**，只供下游报"多少 C 是 optimal vs 只是 acceptable"。这解决了 tool-call eval 的根本难题：**同一句话常有多个都对的工具/参数组合**（"屋里温度多少"既可 GetState 温度传感器也可 ClimateGetTemperature），死扣单一金标会冤杀。

**防御性提取**（`_extract_tool_calls` L135-152）：先取 `state.messages[-1].tool_calls`，回退 `state.output.choices[0].message.tool_calls`（不同后端 tool_calls 挂的位置不一样）。`_tc_to_dict` L155-160：name 取 `tc.function`（不是 `.name`！gotchas §3）；`tc.parse_error` 有值时把原始字符串塞进 `{"_raw": ...}` 作 malformed 信号——下游 `format_valid` 据此判 I。

### 2.2 `tools.py`（533 行）— 32 工具 schema + no-op 单发桩

- **`_make_noop()` 工厂**（L36-46）：**每个工具一个独立闭包**。Inspect 工具注册表按 handler 函数对象做 key，共享一个 `_noop` 会让后定义的覆盖前面的——最后只剩 1 个工具发给模型（gotchas §4 实证：曾因此模型只看到 11 个 HassNevermind，全程吐纯文本不调工具）。
- **`generate(tool_calls="none")` 配套**：工具发给模型（让它知道有哪些），但 handler 永不执行（L9 注释）。`_noop` 只为满足 Inspect API。
- **三档槽位 schema**（L69-88）：`_ENTITY_SLOTS`（name/area/floor/domain/device_class，带 device_class 的 ServiceIntentHandler）/ `_SERVICE_SLOTS`（无 device_class）/ 自定义（如 `HassSetVolumeRelative` 的 `volume_step` 是 `anyOf[enum[up,down], int]` L317-324）。**每个 schema 注释了它从 HA 哪个 handler 派生**（L13-28 映射约定）——可溯源、对齐真实下发格式。
- **`ToolParams` 而非 dict**（gotchas §1）：传 dict 会触发函数签名内省，`**kwargs` 泄漏成 `kwargs` 参数；空工具用 `ToolParams()` 不是 `{}`（`{}` falsy 走内省路径）。

### 2.3 `solver.py`（53 行）+ `prompt.py`（120 行）— prompt 装配 = cache 友好

- **cache-friendly 顺序**（prompt.py L43-44, 57-68）：**指令（静态）→ 实体清单（静态）→ 时间戳（变量，放最后）**。刻意背离 HA 默认（HA 把时间戳放最前）——同 inventory 跑很多 case 时，静态前缀进 KV cache 不失效，只有时间戳+utterance 变。这是 **MAformac KV 预热（home-llm teardown 已记）+ benchmark 确定性的协同设计**。
- **固定时间戳**（prompt.py L18-19）：`FIXED_TIME="12:00:00"` `FIXED_DATE="2026-03-01"`——benchmark 确定性 + KV cache 复用。
- **inventory 内存缓存**（L15, 84-85, 114）：`_inventory_cache` 按绝对路径键缓存格式化结果，避免每 sample 重读 YAML。

### 2.4 `dataset.py`（82 行）— 严格 schema 校验

- `REQUIRED_FIELDS`（L8-14）：5 个必填（id/utterance/expected_tool_calls/expected_response_type/inventory_tier），缺一个就 `ValueError` 带行号（L50-52）——边界 fail-fast。
- 空文件 → 抛错（L78-80）；alternative/metadata 转进 Sample.metadata（L61-67，metadata 加 `meta/` 前缀防撞名）。

### 2.5 `scripts/run_benchmark.py`（877 行）— 编排 + 健康守护（C6 运行态可借）

- **矩阵排序最小化重启**（`_build_matrix` L178-193）：models→hw→ctx→**tier 做最内层**（同 server 免费，换 tier 不重启）。
- **server stale/hung/dead 三态守护**（`_check_server_after_failure` L316-336）：hung（TCP 连通但无 HTTP 响应）→ 立即放弃不重试；dead → 等 2s 再查一次（容瞬时网络抖动）；alive → 失败不是 server 崩。**崩了的 server-key 进 `skipped_server_keys`（L673, 785, 816, 849），剩余 tier 全跳过**——不让一个坏 server 拖垮整个矩阵。
- **warmup 预热**（`_run_warmup` L339-381）：每次换 server 跑一遍 sample 数据预热（KV cache + GPU），结果存 warmup/ 但**排除出分析**——解决 cold-start 伪 outlier。
- **per-sample timeout**（`attempt_timeout`，task.py L31-32 默认 15s）：failure-patterns 实证 meta-llama 两个样本各卡 600s 拖垮整 run；没有它两个卡死样本吞 20 分钟。
- **resume**（L680-694）：已有 .eval 跳过——长矩阵断点续跑。
- **--no-fail-on-error**（L264）：单坏样本不中止矩阵。

### 2.6 `scripts/assemble_tier.py`（390 行）— 数据集组装（单一源派生）

- **三 pass 收集**（`_collect_test_cases` L149-208）：pass1 域专属文件 / pass2 跨域文件（仅当 target 的全部 domain 都在选中集才纳入，L196-200）/ pass3 `inventory_tier=="all"` 的 inventory-independent case 无条件纳入（utility/conversational/OOS）。`seen_ids` 去重（L176-179）。
- **--validate 干跑**（L211-234, 354-368）：内存里交叉核 case 的 target_entities/target_areas 是否在 assembled inventory 里，不写文件就退出——**source 一致性预检**。

### 2.7 `tests/test_scorers.py`（269 行）— 判分器自验（C6 必抄的 fixture 法）

- 每个维度独立单测（TestToolNameCheck/TestArgumentCheck/...），含 order-independent（L31-34, L80-89）、`_any_of` 命中/miss（L55-63）、数值容差（L65-68, 184-187）、空 expected（L70-73）、alternative 匹配（L210-229）。
- **断言 32 工具数**（L166-167）+ MATCH_QUALITY 总是发（L243-247）。这套测试就是"判分器本身可信"的死门——MAformac C6 判分器也得这样自验。

---

## 3. 关键工程决策（让 eval 可靠的核心算法/旋钮/防御）

| # | 决策 | file:line | 为什么可靠（README 看不到的智慧） |
|---|---|---|---|
| K1 | **6 维诊断打分**（非单一 pass/fail） | `tool_call.py:118-132` | "调错工具"vs"工具对参数错"vs"幻觉工具"是质上不同的失败；单分数掩盖。MAformac 知道"为什么不丢脸了"才能改 |
| K2 | **工具 no-op + `tool_calls="none"`** | `solver.py:49` + `tools.py:9,36-46` | 纯捕获不执行=零副作用、可离线、判分快。**每工具独立闭包**否则注册表覆盖（gotchas §4） |
| K3 | **alternative + quality 容多正解** | `tool_call.py:82-105` | tool-call 常有多个都对的解；死扣单金标冤杀。quality 不影响过不过，只供"optimal 占比"报告 |
| K4 | **order-independent 集合匹配**（name + args 贪心配对） | `tool_call.py:206-238` | 多意图"关窗+锁门"不该卡顺序；args 贪心 unmatched 配对处理多调用 |
| K5 | **参数归一化**（大小写/`_any_of`/数值容差/数组排序集） | `tool_call.py:241-281` | 小模型 `["Light"]` vs `["light"]`、`50` vs `50.0` 不该判错；语义等价归一 |
| K6 | **拒识维 = response_type 零调用** | `tool_call.py:180-184` | error/clarification/text_response 期望**零工具调用**——"该不调时调了"是独立失败维（F7） |
| K7 | **malformed 信号 `_raw`** | `tool_call.py:158-159, 194` | `parse_error` → 塞 `{"_raw"}` → format_valid 判 I；坏 JSON 不静默吞 |
| K8 | **`Score.value` 必标量** | `tool_call.py:109-110` + gotchas §6 | 放 dict 让 accuracy() 静默 0.000；明细进 explanation |
| K9 | **cache-friendly prompt 顺序**（变量放最后） | `prompt.py:43-44,57-68` | 静态前缀进 KV cache 不失效；与 home-llm KV 预热同源 |
| K10 | **`--max-connections 1` 串行** | `run_benchmark.py:262` + gotchas §7 | 并发让延迟测的是排队深度不是推理时间；还会压垮 server |
| K11 | **first-sample cold-prefill 剔除** | failure-patterns.md L312-314,408-413 | 每 tier 第一个样本 KV 冷启动伪 spike（7-38s vs 正常 1-2s）；不剔比较失真 |
| K12 | **多 run + FP 非确定性显式承认** | failure-patterns.md L358-380 | GPU/CPU 同 seed 仍 3 样本翻转；80 样本上 56.2% vs 57.5% 不显著——承认噪声不假装确定 |
| K13 | **`/no_think` thinking 抑制** | failure-patterns.md L537-561 | Qwen3 思考链 9.5s→1.7s 不掉准；voice 管线延迟死门。其他模型安全忽略此 token |
| K14 | **server stale/hung/dead 三态守护 + skip** | `run_benchmark.py:316-336,785,816` | 一个坏 server 不拖垮矩阵；hung 立即弃、dead 等 2s 复查 |
| K15 | **per-sample attempt_timeout** | `task.py:31-32` + failure-patterns L468-477 | 没它两个卡死样本吞 20min 阻塞整 run |

---

## 4. F1–F10 失败分类法（★★ 端侧小模型 tool-call 怎么崩的实证账本，MAformac C6 直接复用）

这是 failure-patterns.md（660 行）的核心，**比任何打分公式都珍贵**——它是"小模型在 tool-call 上具体怎么错"的活taxonomy，每条配影响的 scorer 维度 + prompt 缓解 + 实测 delta。MAformac 客车控全集泛化会**原样撞上这些坑**：

| ID | 失败模式 | 影响维 | MAformac 同构风险（车控全集） |
|---|---|---|---|
| **F1** | 用 entity_id 代替友好名（`kitchen_ceiling` 而非 `Kitchen Ceiling`） | args | ★最高频（~25/80）。车控对应"用内部 device code 而非"主驾车窗""。根因：YAML 里 entity_id 排在 name 前，模型 pattern-match 第一个标识符（L68-71）。**修法：name 字段放最前 / 去掉 entity_id** |
| F1.partial | 友好名截断（`Home` 而非 `Home Weather`） | args | 槽值截断，车控"空调"vs"主驾空调" |
| **F2** | 语义近的错工具（"温度" GetState vs ClimateGetTemp） | tool_name+args | 车控"升温"→设温度 vs 开暖风；**锁方向反转**（lock：on=锁 HA 反直觉 L97-99）——车控"打开/关闭"语义陷阱 |
| F3 | 幻觉工具名 | no_hallucinated_tools | 调全集外不存在的工具 |
| **F4** | 缺必填参数（用 device_class 代 domain；色温传数字 Kelvin 而非"warm white"） | args | 车控缺槽：座椅加热没传档位、空调没传温度 |
| **F5** | 多余/虚假参数。**F5.area**（13/15，模型给每个实体补 area）/ **F5.device_class** | args | ★车控高危：模型爱补冗余槽证明推理。F5 几乎总伴 F1（修 F1 顺带降 F5，L172-173） |
| F6 | 调用数错（多调 / 拆单为多） | call_count | 多意图拆错 |
| **F7** | 应答类型错（该调没调 / 不该调却调了） | response_type+call_count | ★拒识死门。模型对"太热了""天黑了"等**模棱complaint 过度行动**（单方面调温），对 gibberish 也乱调。车控"有点冷"该不该自动升温=同款 |
| F8 | domain filter 错 | args | 工具对、名对，domain 值错 |
| **F9** | 越界请求映射到最近 HA 工具（"亚马逊下单"→购物清单） | response_type | ★车控越界：客户问"导航去机场"（demo 无导航）模型硬塞最近工具，而非拒识。**安全门关键** |
| **F10** | 模型根本不会 tool-call（纯文本 / 随机选工具） | 全维 | 模型级系统失败。**phi4-mini 三层 serving 不兼容实证**（L507-521：模板/输出 token/EOS bug）；选型死门 |
| F_think | 思考链膨胀延迟不增准（Qwen3 9.5s）| 延迟（非 scorer 维）| voice 延迟死门，`/no_think` 解（K13） |

**实测进展账本**（failure-patterns L273-282，三轮 prompt 迭代）：Qwen3-8B 52.5%→70.0%（+name-fix）→**81.2%**（+area+nothink），总 +28.7pp。**全靠改 prompt 指令一行一行试、每轮量化 delta**——这套"一次改一处 + 实测 delta"纪律（ha-prompt-engineering.md）就是 MAformac"规则吃 80% + LoRA 补 20%"调参时的方法学母本。

---

## 5. cross-cutting pattern（横切设计思想）

1. **状态机/分流在判分维度里**：6 维不是平铺，response_type 先分流（action/query/text/error/clarification）再判其它——MAformac 三层路由的"意图类型"应同样作为 eval 的一等分流维。
2. **容错归一化下沉到比较层**（大小写/数值容差/`_any_of`/集合）——契约 SSOT 的 value 四件套归一化逻辑应该判分器和 runtime 共享一份（C1 派生）。
3. **多正解显式建模**（alternative+quality）而非死金标——承认"对"是个区间，配 quality 标签做下游分析。这是 MAformac"不丢脸"的精确定义：**全集随便说 → 命中 optimal 或 acceptable 都算不丢脸，degraded/越界才丢脸**。
4. **失败先分类再治理**（F1-F10）：不是"准确率 56%"而是"args×26 / response_type×7 / tool_name×5"——MAformac C6 报告必须出这种**分维 + 分failure-mode**的诊断，否则改无方向。
5. **eval 可信 > eval 好看**（串行/剔 cold-start/承认 FP 噪声/per-sample timeout/三态 server 守护）：宁可慢、宁可承认不确定，不要假精确。
6. **单一源派生**（assemble_tier 三 pass / inventory 缓存 / tools schema 注释溯源 HA handler）：和 MAformac"capabilities.yaml 单一源 → 派生 ASR词表/拼音/LoRA/白名单"同构。
7. **判分器自验**（test_scorers 每维单测 + 32 工具数断言）：判分器本身是代码、是契约，必须 TDD——不能"判分器对不对全靠肉眼"。

---

## 6. adopt / adapt / drop 映射（→ MAformac C4/C5/C6/C7）

见结构化 schema `adopt_map`。核心：6 维打分器 + F1-F10 taxonomy + alternative/quality + no-op 捕获 + 三纪律（串行/cold-start/timeout）= **copy概念**（翻成 Swift/Python harness）；Inspect AI / llama.cpp SSH 编排 / HA 32 工具集 / GGUF 量化矩阵 = **drop 或 adapt**（载体不适用，但矩阵思想和工具 schema 形态保留）。

---

## 一句话

**README 说它"benchmark HA voice LLM"；拆到底才看到它真正给 MAformac 的是——一套"小模型 tool-call 怎么崩"的实证失败学（F1-F10）+ 6 维诊断打分器 + 多正解容错（alternative/quality）+ 三条让 eval 可信的纪律（串行/剔 cold-start/per-sample timeout），这四样直接搬进 C6 vehicle-tool-bench，比手搓"集合精确匹配"准一个量级，因为它解决的是"全集随便说会怎么不丢脸地崩"而不只是"对不对"。**

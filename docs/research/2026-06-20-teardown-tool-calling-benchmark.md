# tool-calling-benchmark 蓝本 工程/算法 teardown — MAformac C6 评测的现成范式

> **缘起**：磊哥要求深扒 `MikeVeerman/tool-calling-benchmark`（"Local Agent Bench"，r/LocalLLaMA 163 赞爆款，21 端侧小模型 × 12 prompt × 20 run 跑判断力）——MAformac **C6 vehicle-tool-bench（不丢脸基线）** 的现成评测范式，外加为 **C4 三层路由 / C7 ASR** 提供经验证据（Qwen3-1.7B 实测全集第一、多 run 稳定性、惩罚机制、判断 vs 执行二分）。clone 在 `~/workspace/raw/05-Projects/MAformac/ref-repos/tool-calling-benchmark`（CLAUDE §6：只读参考，**不进仓**；无 LICENSE 文件，README 写 "Use it freely; attribution appreciated"——方法学全量吸收，Python 翻成 Swift 设计思想不 import）。
> **本文 = 逐文件拆解**（6 个 runtime/算法源 + 4 篇 ROUND 报告全读，带行号）。
> **核心结论**：这个 bench 真正的智慧**不在跑分本身，在三件别处看不到的工程**——(1) **判断 ≠ 执行 的双轴评分**（Action 测会不会调 / Restraint+WrongTool 测该不该调；惩罚"自信地调错"重于"漏调"）；(2) **多 run + majority-vote + Reliability 双指标**揭穿小样本假象（3-run → 20-run 让 7/21 模型分数翻盘，Qwen3-1.7B 从 11 名升到第 1）；(3) **六层防御性文本解析**让"格式不合规但判断对"的模型不被冤枉（format-blind 评测既低估又高估模型）。这三条逐条都是 MAformac C6 该抄的，且 Qwen3-1.7B 实测第一**直接给 D-系列"先 1.7B 不前置 benchmark"加经验背书**。

---

## §0 硬结论（先放这,后面是证据）

| 维度 | tool-calling-benchmark 的做法 | MAformac C6 取舍 |
|---|---|---|
| **判断 vs 执行分轴** | Action（会不会调）/ Restraint（该不该不调）/ WrongTool（调错惩罚）三轴独立,再加权合成 Agent Score | **copy概念**——C6 双轴(全集覆盖率 + 不丢脸判断),把 Restraint→拒识、WrongTool→安全门越界 |
| **多 run 稳定性** | 20 run majority-vote + Reliability(投票前 per-run 成功率)双指标,3→20 run 让 7/21 翻盘 | **copy概念**——C6 必跑 N≥10 run,报 majority + per-run reliability,别信单跑 |
| **惩罚机制** | hard prompt 有"specifically-bad tool",调它比不调更扣分;(3-wrong)/3 进总分 30% | **adapt**——MAformac 的 wrong = 安全门越界 / 跨域调错 device,惩罚权重按 R0-R3 |
| **防御性解析** | 六层 fallback(tag-JSON→funcall-in-tag→bare-JSON→bracket→bare-funcall),只在上层失败才降级;带 Python 代码假阳性守卫 | **adapt**——评测口径=ToolCall 集合精确匹配,但解析层抄"格式宽容、判断严格";端侧用受限解码后解析压力小,守卫思想留 |
| **model-protocol pair** | 同模型不同 backend(native-tools / raw-schema)分数差很大,显式标 backend 列 | **copy概念**——C6 报告必标"哪个推理栈+哪个解码模式",不裸报模型名 |
| **数据规模** | 12 prompt(3 判断陷阱) + 3 mock tool,刻意小 | **drop 载体留思想**——MAformac 全集 3990 行级 + L1~5 分层,但"判断陷阱 prompt"设计法直接抄(见 §4.2) |
| **运行载体** | Python + ollama/llama.cpp/bitnet subprocess server | **drop**——MAformac 端侧 Swift + mlx-swift-lm,bench 在 Mac dev 机离线跑(CI 前置),非进 iOS |

---

## §1 评分核心 `lib/report.py`（487 行）— 判断 vs 执行 双轴算法

这是整个 bench 的心脏。五个独立指标,每个一个纯函数,**故意拆开不混**——because 它们测的是正交能力。

### §1.1 Action Score `compute_action_score`（line 32-46）— 执行轴

```
correct_tool_calls / 10   # 10 个 actionable prompt
```
- **关键设计**：P10-P12(hard)要求**调对的那个工具**(`rs[idx]["tool_name"] == EXPECTED_TOOLS[idx]`,line 41);P1-P8 只要 `valid_args`(调了且参数能序列化)就算(line 44)。
- 即 easy prompt 测"会不会调",hard prompt 测"调得对不对"。两个标准合在一轴,因为都属"执行能力"。

### §1.2 Restraint Score `compute_restraint_score`（line 49-53）— 该不该不调

```
correct_refusals / 2   # P5(meta问题) P9(写代码请求,带"weather"关键词陷阱)
```
- **`not rs[idx]["tool_called"]`**(line 52)：该不调时不调 = 通过。
- 这是 MAformac **拒识**(NLU 弃权)的直接对应:客户问"你能干啥"(meta)/"帮我写个脚本"(非控车),不该触发 mock 车控。

### §1.3 Wrong Tool `compute_wrong_tool`（line 56-63）— 判断惩罚

```python
for idx, wrong_tools in WRONG_TOOL_MAP.items():
    if rs[idx]["tool_called"] and rs[idx]["tool_name"] in wrong_tools:
        count += 1   # 调了"specifically-bad"那个工具就 +1
```
- **🔴 核心洞察**：每个 hard prompt 有个"**比不调更糟**"的错误工具(`WRONG_TOOL_MAP`,bench_config line 118-122):
  - P11"别查天气,找报告" → 调 `get_weather` = 无视显式否定(WRONG)
  - P12"天气已给(8℃雨),要不要约室内会" → 调 `get_weather` = 没读上下文,冗余(WRONG)
  - P10"去 Bruges 开会骑车还是坐火车" → 调 `schedule_meeting` = 会议已存在(WRONG)
- **"调错"扣分重于"漏调"**——漏调只是没拿 Action 分,调错额外吃 WrongTool 惩罚。这是 agent 安全哲学:**自信地干错事比啥都不干更危险**(README line 9)。

### §1.4 Agent Score `compute_agent_score`（line 66-88）— 加权合成

```
Action × 0.4 + Restraint × 0.3 + Wrong-Tool-Avoidance × 0.3
其中 Wrong-Tool-Avoidance = (3 - wrong_tool_count) / 3
```
- **🔴 防双重 rounding**(line 71 注释)：用未 round 的原始值算,最后才 round——MAformac codegen/统计要学这个,中间别提前截断。
- **权重即价值观**(README line 236)：60% 给 Restraint+WTA = 结构性偏好保守模型。换 `Action×0.7` 激进模型就上位。**权重不是真理,是部署偏好**——MAformac demo 场景"宁可澄清不要乱控车",该偏保守(高 Restraint 权重)。

### §1.5 Reliability `compute_reliability`（line 91-113）— 投票前的真相

```
每 prompt: successful_runs / total_runs,再对所有 prompt 求平均
```
- **🔴 与 majority-vote 正交**(line 95 注释)：majority-vote 给"correctness"(14/20 通过 → 算 pass),Reliability 给"deployability"(就是 0.70,暴露它 30% 时间会失败)。
- ROUND1 line 96 金句:**"Agents fail in production from rare errors, not average ones."** → MAformac C6 必报 reliability,一个 demo"55% 命中"的能力在客户现场就是定时炸弹。

### §1.6 Multi-Tool `compute_multi_tool_accuracy`（line 116-130）— 协议能力暴露

- P8"同时搜文件+查天气" → `len(called_tools & P8_REQUIRED_TOOLS) / 2`。
- **🔴 backend=ollama 直接返 None**(line 121-122,注释"native API returns only first tool call")——**承认评测受协议限制**,不假装能测。MAformac 多意图("开空调顺便放音乐")测试要学:**先确认推理栈能不能返回多 ToolCall,不能就显式标 N/A,别给假分**。

### §1.7 stale guard（贯穿 `generate_summary` line 437-438 + run_helpers）
- 每个结果文件存 `bench_version`(prompts+scoring 的 sha256,见 §3),summary 时比对当前版本,不符标星 `*` + 提示重跑(line 482-485)。**评分规则变了 → 旧结果自动失效**。MAformac 契约 SSOT 改了(C1 全集变),旧 bench 结果该自动标 stale——直接抄这个 version-hash gate。

---

## §2 编排 + 后端派发 `bench.py`（318 行）— 跑法骨架

### §2.1 三个 mock tool（line 42-58）
- `get_weather/search_files/schedule_meeting`,返回写死的 dict(`{"temp_c":14,...}`)。**mock 实现 = 端态自包含**,跟 MAformac D16"全 mock 车控 = UI 卡片+TTS"同构。
- `TOOL_DISPATCH` 字典(line 54-58)= name→fn 映射,执行层。

### §2.2 backend 派发 `run_one`（line 166-177）
- 四后端:`ollama`(native tools API)/`ollama_raw`(系统 prompt 塞 schema,解析文本)/`bitnet`/`llamacpp`(OpenAI-compat /v1)。
- **🔴 model-protocol pair 思想**(ROUND1 line 48 methodology note)：评的是"模型×协议"不是"模型"。phi4-mini 从 native-tools 换 raw-schema 分数暴涨(ROUND1 line 46)。→ **MAformac C6 报告必带"推理栈+解码模式"两列**,Qwen3-1.7B 在 mlx-swift vs llama.swift、native-FC vs GBNF 受限解码下可能不同分。

### §2.3 单模型跑 N run `run_single_model`（line 185-233）
- server 生命周期 try/finally 包裹(line 196-231):bitnet/llamacpp 跑前 `start_*_server` 跑后 `stop_*_server`,**保证不泄漏子进程**。MAformac dev 机批跑多模型该学(每个模型独立 server,跑完回收)。
- 双层循环:`for run in num_runs: for prompt in TEST_PROMPTS`(line 209-220),逐 prompt 存 result。
- **per-run 全量留存**(`runs_data[run_idx] = [result_per_prompt]`,line 220)——**不在跑时聚合**,原始 per-run 数据落盘,聚合在 report 层做。→ MAformac trace 该学:原始每次推理结果全留(Day1 埋 trace),统计是下游派生。

### §2.4 增量跑 `--all`（line 288-306）
- 只跑 missing/stale 模型(line 291-298),`--force` 才全重跑。**评分规则没变就不重跑**(靠 bench_version)。省时间的工程纪律。

---

## §3 版本 + 聚合 `lib/run_helpers.py`（100 行）— majority-vote 算法 + 失效门

### §3.1 bench_version `compute_bench_version`（line 19-27）
```python
content = json.dumps({prompts, restraint, expected, wrong}, sort_keys=True)
return sha256(content)[:12]
```
- **🔴 prompts+scoring 一变 hash 就变 → 旧结果自动 stale**。这是评测可信度的根:**评分口径变了,历史分数不能再比**。MAformac 契约 SSOT(C1 jsonl)的 hash 该同样进 bench 结果 manifest(CLAUDE §5"冻结快照双 hash"已有此思想,bench 复用)。

### §3.2 majority-vote `aggregate_runs`（line 67-100）— N run 收成一个真相
```
called = (调用次数 > num_runs/2)         # 过半才算"调了"  line 75
tool_name = 出现最多的那个               # 众数            line 77
valid = (任一 run 有效) if called        #                line 79
```
- **🔴 多 ToolCall 的 union 逻辑**(line 80-90)：跨 run 统计每个工具出现次数,**>50% run 出现的才进 union**——多意图场景用众数门去抖。
- **关键**：聚合是**纯函数**,吃 per-run 原始数据,可重放。改阈值(过半→2/3)只改这一处。MAformac N-run 收敛直接抄。

### §3.3 安全文件名 `model_name_to_filename`（line 30-33）
- `qwen2.5:3b → qwen2_5_3b.json`,正则替非法字符。小工程但端侧契约派生文件命名要学(冒号/斜杠不能进文件名)。

---

## §4 prompt + 评分配置 `lib/bench_config.py`（180 行）— 判断陷阱设计法

### §4.1 索引集驱动评分（line 101-124）
- `RESTRAINT_INDICES={4,8}` / `TOOL_CALL_INDICES={0,1,2,3,5,6,7,9,10,11}` / `EXPECTED_TOOLS{9:get_weather,10:search_files,11:schedule_meeting}` / `WRONG_TOOL_MAP`。
- **🔴 评分逻辑全是数据(索引集),不是 if-else**。加 prompt = 追加 `TEST_PROMPTS` + 把索引塞对应集合(README line 337)。**MAformac C6 该 table-driven**:每条评测样本带 `{expected_toolcall, is_restraint, wrong_toolcalls[], scenario_tags[]}`,评分器纯查表。

### §4.2 🔴 判断陷阱 prompt 设计法（line 74-99,这是最该抄的设计智慧）
12 prompt 从 obvious → ambiguous → trick → hard,**每个 hard prompt 攻击一种判断弱点**:
| Prompt | 攻击的弱点 | MAformac 对应陷阱 |
|---|---|---|
| P5"你有什么工具" | meta 问题当指令(该拒识) | "这车能干啥" → 不该乱触发 mock 控车 |
| P9"写个查天气的脚本" | **关键词触发**("weather"在但不是要调) | "帮我想想空调原理" → "空调"在但不是要开 |
| P10"骑车还是火车"(没提天气) | **隐式推理**(决定依赖天气) | "现在适合开窗吗" → 隐含查温度/PM2.5 |
| P11"别查天气,找报告" | **否定**(显式说别做某事) | "别开空调,把窗打开" → 否定理解 |
| P12"天气已给,约会吗" | **上下文冗余**(信息已在 prompt) | "现在 26 度有点热" → 别再"查温度",直接降温 |
- **设计法 = 每个 hard prompt 放一个"诱饵关键词" + 正解是抵抗诱饵**。ROUND1 line 77:加 P10-P12 把四模型平台(0.929 并列)拉开到 0.57-0.80——**判断陷阱是区分模型的关键,easy prompt 谁都过**。
- → MAformac C6 不丢脸基线**必须含判断陷阱样本**(关键词诱饵 / 否定 / 上下文冗余 / 隐式推理),不能只测 L1 命中。这跟 MEMORY 里"demo 价值=路由对+泛化+拒识+安全门,非命中话术"完全同源。

### §4.3 EDGE_MODELS 分层榜（line 178-180）
- sub-2B 单独排榜。MAformac 只关心端侧能跑的尺寸(0.6B/1.7B),该有"端侧可部署"过滤榜。

---

## §5 自检 `lib/self_test.py`（210 行）— 解析器 + 评分器的回归网

- **🔴 解析器单测穷举 7+ 种格式**(line 16-161)：tag-JSON / 带闭合 tag / 混入非法块 / bare-JSON(jan-v3) / bracket(lfm2.5) / funcall-in-tag(gemma3) / bare-funcall(deepseek) / 代码围栏 / **Python 代码假阳性必须不匹配**(line 139-156:`def get_weather`/`result=`/`self.`/类型签名全 None)。
- **评分器单测用两个对照模型**(line 166-204)：good model(9/10 action,2/2 restraint,0 wrong)= 0.96;trigger-happy model(7/10,0/2,3/3 wrong)= 0.28。**断言精确到小数**(line 180-204)。
- → MAformac C6 评分器**必须有这种 golden-case 回归测**:造一个"理想 agent"和一个"乱调 agent"的 mock 结果,断言评分函数算出预期分。改评分公式时这网立刻报警(防 §1.4 那种 rounding bug)。

---

## §6 防御性文本解析 `lib/bitnet_backend.py`（653 行）— 让"格式不合规但判断对"的模型不被冤枉

这是 home-llm `fuzzy_json` 的对应物,但更激进——**六层 fallback**,因为它要公平评测 21 个输出格式各异的模型。

### §6.1 🔴 六层解析降级链 `_parse_tool_call_from_text`（line 498-543）
按优先级,每层只在上层 miss 才触发:
1. **`<tool_call>{json}`**(line 500-524)：标准,brace-counting 找闭合(line 506-514)。
2. **funcall-in-tag** `<tool_call>get_weather(city: Antwerp)</tool_call>`(line 526-528,gemma3 风格)。
3. **bare-JSON**(line 532,`_parse_bare_json_tool_call` line 91-119,jan-v3 漏开 tag)：扫所有 `{...}` 找含 `name`+`arguments` 的。
4. **bracket** `[get_weather(city="Antwerp")]`(line 535,lfm2.5 Python 风)。
5. **bare-funcall** `get_weather(Antwerp)`(line 540,deepseek 无 tag),**先 `_remove_code_blocks` 剥代码围栏**(line 539)再扫。
- `_parse_all_tool_calls_from_text`(line 546-603)= 多 ToolCall 版,同样的降级链。

### §6.2 🔴 假阳性守卫 `_parse_bare_funcall_tool_calls`（line 406-445）
bare-funcall 最危险(会把 Python 代码当工具调用),四道守卫:
- **只匹配已知工具名**(line 413,`KNOWN_TOOLS` 正则白名单)——不在 3 个工具里的函数名直接不认。
- **前缀守卫**(line 419-423)：`def `/`.`/`= ` 开头 = Python 代码,跳过。
- **类型签名守卫** `_is_type_signature`(line 386-403)：`get_weather(city: string)`/`city: city`/`city: city_name` 这种占位符不是真调用,过滤。
- **空参守卫**(line 426)：`parsed["arguments"]` 为空不算。
- → **MAformac 端侧用受限解码(GBNF/outlines)后,模型输出格式可控,解析压力远小于这里**。但"白名单匹配 + 代码假阳性守卫"思想留:即便受限解码,解析层也该只认契约内的 device/动作,拒一切契约外 token 序列(纵深防御)。

### §6.3 positional→named 参数补全 `_parse_funcall`（line 344-380）
- `get_weather(Antwerp)`(无 key)→ 查 `KNOWN_TOOLS["get_weather"]=["city"]` → `{"city":"Antwerp"}`(line 378-379)。**模型省 key,code 按 schema 顺序补**。MAformac 若模型输出简写参数,code 按契约 slot 顺序回填——减小模型负担(同 home-llm"模型近似,code 归一"哲学)。

### §6.4 system prompt（line 17-33)
- 明确告诉 raw-schema 模型:能调就 `<tool_call>{json}</tool_call>`,**写代码/解释/meta 问题不要调**(line 32-33)——把 Restraint 规则写进 prompt。MAformac L2-5 慢路 prompt 该有这段"何时弃权"指引。
- 采样 `temperature: 0.7`(line 615),`max_tokens: 512`——bench 故意用 0.7 暴露 stochastic 抖动(这正是要 20 run 的原因)。**MAformac 生产端侧该用低 temp(home-llm teardown 给 qwen3 temp0.6/topk20/topp0.95),但 bench 评测可用稍高 temp 压测稳定性**。

> `lib/llamacpp_backend.py`(116 行)= bitnet 的孪生,复用同一套解析(line 8-12 import),只是 server 端点不同。无新增智慧,跳过。

---

## §7 数据叙事（4 篇 ROUND 报告）— Qwen3-1.7B 实测第一 + 多 run 翻盘

这是给 MAformac **D-系列决策的经验背书**,逐条摘 source:

### §7.1 🔴 Qwen3-1.7B = 全集第一（ROUND3 line 38,README line 131）
- **Agent Score 0.960,21 模型最高**,唯一同时做到:Action 0.900(10 个里调对 9 个)+ Restraint 1.000(完美拒识)+ 0 wrong tool + **唯一三个 hard prompt 全对**(P10/P11/P12)。
- **直接背书 MAformac D-系列"Qwen3-1.7B + LoRA 候选主线,先 1.7B 不前置 benchmark"**——别人已实测 1.7B 在判断陷阱上端侧第一。0.6B(0.880)是合理 fallback(CLAUDE §4 已锁)。
- latency 10.7s(CPU,thinking mode 开)——但这是 **CPU 无 GPU + thinking 全开**,MAformac 端侧 mlx Metal + 关 thinking + L1 走规则不碰模型,实际快得多。

### §7.2 🔴 多 run 揭穿小样本(ROUND3 整篇)— C6 必抄
- 3-run → 20-run,**7/21 模型分数变动 >0.05**:Qwen3-1.7B +0.290(11 名→第 1)、bitnet-2B-4T -0.280(6→17)、gemma3 +0.140、phi4-mini -0.100。
- **3-run 的四模型并列(0.880)是采样假象**,20-run 拉开到 0.96/0.92/0.88/0.78(ROUND3 line 145)。
- 根因(ROUND3 line 12)：temp 0.7 下边界 prompt(~50% 调用率)单跑就是抛硬币。**Reliability>0.70 的模型才稳**(line 161)。
- → **MAformac C6 死规:N≥10 run,报 majority + reliability,单跑结果一律标 preliminary**。一个"55% 命中"的 demo 能力测试会过、现场会炸(ROUND3 line 192)。

### §7.3 格式合规双向偏差(ROUND2 line 392-410)— 解析层为什么重要
- 加 fallback 解析器后:lfm2.5 0.640→0.920(**被低估**,judgment 一直对只是格式怪)、deepseek 0.600→0.720;但 gemma3 0.600→0.690、smollm3 0.740→0.710(**被高估**——旧解析器看不见它在 restraint prompt 上乱调,反而抬高了分)。
- **🔴 金句(README line 24)**：format-blind 评测**既低估又高估**模型。→ MAformac C6 口径=ToolCall 集合精确匹配,但**解析必须能读懂模型实际输出格式**,否则测的是"格式训练"不是"判断力"。

### §7.4 参数量是判断力的弱预测(ROUND2 line 433,README line 22)
- Qwen3 家族非单调:0.6B(0.880)>4B(0.880)>1.7B(0.670)@3run——但 20run 修正回单调 1.7B>0.6B(ROUND3 line 151)。functiongemma(270M)= qwen2.5(500M)。**架构+训练数据 > 裸参数量**。
- → MAformac 不必盲目追大模型;1.7B+针对性 LoRA(练判断陷阱)可能赢未训的更大模型。这正是 C5"LoRA 全量练模糊说/跨域映射"的价值。

### §7.5 thinking mode 对工具调用是双刃(ROUND2 line 377-390)
- qwen3:4b thinking 全开 63s/prompt,分数和 0.6B(3.6s)一样。**"工具选择是快速模式匹配,不是多步推理"**(ROUND2 line 390)。
- → MAformac **L1 精确指令绝不开 thinking**(规则快路秒回);只有 L4-5 复杂推理才值得慢思考。这跟三层路由架构铁律完全咬合。

---

## §8 Cross-cutting 横切设计思想（综合所有文件）

1. **判断与执行正交,分轴度量**——"会不会调"(Action)和"该不该调"(Restraint+WrongTool)是两种能力,合一轴会掩盖真相。MAformac C6 双轴(覆盖率 + 不丢脸)同构。
2. **评分逻辑全 table-driven**——索引集 + 期望工具映射 + 错误工具映射,加样本=填表,评分器纯查表(bench_config)。契约 SSOT 派生 bench 样本天然 table-driven。
3. **原始数据落盘,聚合在下游**——per-run 全留(bench.py),majority-vote/reliability 是 report 层纯函数派生,可重放、可改阈值(run_helpers)。MAformac Day1 埋 trace 同理。
4. **版本 hash gate 防陈旧**——评分口径(prompts+scoring)hash 进结果,口径变旧分自动 stale(run_helpers §3.1)。复用 MAformac 冻结快照双 hash 思想。
5. **格式宽容、判断严格**——解析层六层 fallback + 假阳性守卫,让格式不影响判断力评测;但评分口径(调对工具)毫不放水(bitnet_backend + report)。
6. **承认评测边界,不造假分**——协议测不了的(native API 只返首个 ToolCall)显式标 N/A,不假装(report §1.6)。
7. **多 run 是评测可信度的底线**——temp>0 下单跑/3跑是抛硬币,N≥10 才见真相(ROUND3 整篇)。这是本 repo 第二轮存在的全部理由。
8. **惩罚"自信地错"重于"沉默漏"**——agent 安全哲学:wrong tool 比 miss 更扣分。MAformac 安全门越界=最高惩罚同源。
9. **golden-case 回归网守护评分器**——理想 agent / 乱调 agent 两个对照断言精确分,防评分公式回归(self_test)。

---

## §9 adopt / adapt / drop 映射 → MAformac C6（+ C4/C5/C7 旁证）

| # | 发现(form) | 动作 | 服务 C 层 | 为什么 |
|---|---|---|---|---|
| 1 | 判断 vs 执行双轴评分(Action/Restraint/WrongTool) | **copy概念** | **C6** | C6 双轴(全集覆盖率 + 不丢脸判断)直接对应;Restraint→拒识、WrongTool→安全门越界 |
| 2 | 20-run majority-vote + Reliability 双指标 | **copy概念** | **C6** | 防小样本假象;N≥10 run、报 per-run reliability、单跑标 preliminary 进 C6 死规 |
| 3 | 判断陷阱 prompt 设计法(关键词诱饵/否定/上下文冗余/隐式推理) | **copy概念** | **C6** | C6 不丢脸基线必含判断陷阱样本,不只测 L1 命中;每陷阱攻一种判断弱点 |
| 4 | table-driven 评分(索引集+期望/错误工具映射) | **copy概念** | **C6** | 评测样本带 `{expected_toolcall,is_restraint,wrong_toolcalls[],tags[]}`,评分器纯查表;契约 SSOT 派生天然适配 |
| 5 | bench_version hash gate(口径变旧分 stale) | **copy概念** | **C6** | 复用 MAformac 冻结快照双 hash;C1 全集变 → 旧 bench 结果自动失效重跑 |
| 6 | per-run 原始数据落盘 + 聚合下游纯函数 | **copy概念** | **C6** | 重放/改阈值只改聚合一处;与 Day1 埋 trace 同源 |
| 7 | golden-case 回归测(理想/乱调 agent 对照断言精确分) | **copy概念** | **C6** | 改评分公式时立即报警,防 rounding/权重 bug(self_test §5) |
| 8 | Agent Score 权重=部署偏好(60% 给保守) | **adapt** | **C6** | demo"宁可澄清不乱控车"偏保守(高 Restraint 权重);权重按 R0-R3 风险调,不照搬 0.4/0.3/0.3 |
| 9 | WrongTool 惩罚(调错重于漏调) | **adapt** | **C6** | MAformac wrong = 安全门越界 / 跨域调错 device;惩罚权重按风险级,越界>漏识 |
| 10 | 六层防御性文本解析 + 假阳性守卫 | **adapt** | **C6**(+C3) | 端侧受限解码后解析压力小;但"白名单匹配契约内 device/动作 + 拒契约外"纵深思想留;positional→named slot 回填可用 |
| 11 | model-protocol pair(标 backend 列) | **copy概念** | **C6** | 报告必标"推理栈(mlx/llama.swift)+解码模式(native-FC/GBNF)",不裸报模型名 |
| 12 | Multi-Tool 协议测不了标 N/A | **copy概念** | **C6** | 多意图测试前先确认推理栈能否返多 ToolCall,不能就标 N/A 不给假分 |
| 13 | EDGE_MODELS 分层榜(端侧可部署过滤) | **adapt** | **C6** | C6 只关心 0.6B/1.7B 端侧能跑的尺寸,独立"端侧可部署"榜 |
| 14 | Qwen3-1.7B 实测全集第一(判断陷阱全对) | **采纳为经验证据** | **C4/C5** | 背书 D-系列"1.7B 候选主线、不前置 benchmark";0.6B 合理 fallback;C5 LoRA 练判断陷阱有据 |
| 15 | thinking 对工具调用是双刃(快速模式匹配非多步) | **采纳为经验证据** | **C4** | L1 精确指令绝不开 thinking(规则快路秒回);只 L4-5 复杂推理值得慢思考——咬合三层路由铁律 |
| 16 | server 生命周期 try/finally + 子进程回收 | **adapt** | C6 | dev 机批跑多模型,每模型独立 server 跑完回收,防泄漏(端侧无此问题,dev harness 用) |
| 17 | Python + ollama/llama.cpp/bitnet subprocess 载体 | **drop** | — | 端侧 Swift + mlx-swift-lm;bench 在 Mac dev 机离线跑(CI 前置),解析/server 编排不进 iOS,翻成 Swift 设计思想 |
| 18 | temp 0.7 压测抖动 | **drop载体留思想** | C6 | 生产端侧低 temp(qwen3 0.6);但 C6 评测可用稍高 temp + N run 压稳定性 |

---

## §10 一句话

**这个 bench 真正的智慧不在"跑分",在三件让评测可信的工程——判断 vs 执行双轴分度量、多 run+reliability 揭穿小样本假象、六层格式宽容解析让判断力不被格式冤枉——而 Qwen3-1.7B 在 21 模型端侧判断陷阱上实测第一(唯一三 hard prompt 全对),直接给 MAformac"1.7B+LoRA 主线、规则吃高频、安全门是判断不是命中"的整套架构盖了经验章。** C6 vehicle-tool-bench 该把这套"双轴+多run+判断陷阱+table-driven+version-gate+golden-case"范式整体移植,把它的 Restraint→拒识、WrongTool→安全门越界、3-mock-tool→全集 3990 分层,Python 翻成 Swift dev harness(不进 iOS)。

# MAformac 调研归档（2026-06-17）

> ⚠️ **HISTORICAL 快照（2026-06-17）—— 文档级联 banner（2026-06-23）**
> 本文是立项早期（前三轮 GitHub 调研 + 路线讨论 + 多 domain 基座）历史快照。范式翻案后（generic frame `tool_call_frame` 否决 → D-domain 具名工具，见 `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`）+ 口径终拍 562（10 族 191 device / 562 intent / 2159 行 / 54.1%），本文涉及的 surface 形态 / 口径数字 / 8 能力扁平路线部分已过期。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/roadmap-2026-06-20-from-c6-done.md`。正文保留供溯源，勿据此推进。

> 归档人：Claude (Opus 4.8) · 应磊哥要求存档前三轮 GitHub 调研 + 路线图讨论 + 多 domain 基座架构。
> 项目定义：**一个端侧（macOS/iOS）多技能 AI Agent 平台**，Phase 1 只做「车控车设」，后续扩展导航（amap MCP）/ 音乐（音乐 API）/ 外卖（瑞幸 MCP）。
> 主用途：**方案经理给客户做便携销售演示**（替代把样车开到现场）。北极星 = 客户现场 5 分钟内：听懂中文、反应快、不崩、看着惊艳、断网也能跑。

---

## Part A. GitHub 调研分层采用表（三轮共 ~44 仓，逐个 `gh` 验证）

> 新鲜度基准：today=2026-06-17，60 天活跃线 ≈ 2026-04-18。模型仓 pushedAt 陈旧 ≠ 淘汰（权重在 HuggingFace，代码仓本就不频繁动）。

### A1. 地基级（高星 + 活跃 + 不可替代）

| 仓库 | ⭐ | pushedAt | 角色 |
|---|---|---|---|
| ggml-org/llama.cpp | 116916 | 06-17 | 推理主线（Mac→iOS） |
| ggml-org/whisper.cpp | 50791 | 06-17 | ASR 备选（底层） |
| k2-fsa/sherpa-onnx | 13029 | 06-15 | 中文 ASR/TTS/KWS/VAD 全包 |
| argmaxinc/argmax-oss-swift | 6212 | 06-10 | WhisperKit（Apple 原生 ASR） |
| FunAudioLLM/SenseVoice | 8594 | 06-09 | 中文 ASR 当前最强之一（走 sherpa-onnx） |
| alibaba/MNN | 15495 | 06-17 | 端侧推理引擎备选（Qwen + iOS 强） |
| huggingface/swift-transformers | 1339 | 06-08 | **Swift 端 tokenizer/推理底座（前两版漏）** |
| modelcontextprotocol/swift-sdk | 1410 | 05-07 | **端侧 MCP client 官方 SDK（接 amap/瑞幸 地基）** |
| ml-explore/mlx-swift | 1924 | 06-11 | Apple 原生推理 |
| ml-explore/mlx-swift-examples | 2607 | 06-15 | MLX Swift 示例（注：未改名，仍存在） |
| ml-explore/mlx-lm | 5924 | 06-12 | Mac LoRA 微调 |
| hiyouga/LLaMA-Factory | 72240 | 06-17 | 微调（mlx-lm 之外的备选） |
| COVESA/vehicle_signal_specification | 427 | 06-03 | 车端信号命名体系（schema 参考） |
| COVESA/vss-tools | 74 | 06-16 | VSS → JSON 工具 |
| OHF-Voice/hassil | 107 | 06-15 | 规则快路径意图解析（替代手搓 regex） |
| OHF-Voice/intents | 605 | 06-16 | 本地语音句式/slot 样例库 |
| dottxt-ai/outlines | 13965 | 05-18 | 结构化输出（Mac 端数据生成/eval） |
| guidance-ai/guidance | 21502 | 05-21 | 可控生成/grammar |
| noamgat/lm-format-enforcer | 2020 | 04-04 | JSON schema 约束（Mac 端） |
| QwenLM/Qwen-Agent | 16568 | 03-04 | Qwen 官方 tool-calling 模板参考 |
| mozilla-ai/llamafile | 24992 | 06-09 | 单文件 LLM server（Mac 原型偷懒） |

### A2. 可直接 adopt 的对口小金矿（低星但内容精准，磊哥「不要求高星」）

| 仓库 | ⭐ | pushedAt | 扒 README 真身 |
|---|---|---|---|
| reinhardjurk/agent-tester | 0 | 05-20 | **车控语音 agent 评测框架**，处理「我有点热」间接指令，MCP+A2A，可复现 |
| javierlimt6/tiny-tool-bench | 0 | 05-17 | **sub-2B 模型 function-calling benchmark**（含 Qwen2.5-0.5B），BFCL v3+对抗 |
| wizcheu/iOSLLMFrameworkBenchmark | 0 | 03-08（略陈） | iOS 上 MLX Swift vs llama.cpp vs MLC-LLM 实测 TTFT/TPS/内存/过热 |
| dengky23/nlu-pipeline-vehicle | 0 | 06-02 | 小鹏实习车载 NLU：数据增强→NER→同义词标准化→意图/槽位 F1 |
| weathour/vehicle-offline-voice-android | 0 | 06-11 | Android 离线：唤醒词+VAD+Vosk+规则 NLU+TTS+ASR 误识别收敛（思路可借） |
| Bosch-Connected-Experience-26/Canals | 3 | 06-10 | Bosch 黑客松车载语音，local-first 但用 AWS Bedrock 云（架构可看，云依赖不符离线） |

### A3. 端侧 function-calling 模型（Qwen3-0.6B 的替补/对比）

| 仓库 | ⭐ | pushedAt | 角色 |
|---|---|---|---|
| MadeAgents/Hammer | 119 | 2025-06 | 端侧 robust function calling，有 0.5B/1.5B，Qwen3-0.6B 不稳时首选替补 |
| SalesforceAIResearch/xLAM | 627 | 06-02 | Large Action Model，function-calling 专用，小尺寸 1B/2B |
| MeetKai/functionary | 1595 | 2025-12 | tool-use 模型 + function-call 解析/grammar 思路 |

### A4. Swift LLM 集成层

| 仓库 | ⭐ | pushedAt | 角色 |
|---|---|---|---|
| tattn/LocalLLMClient | 219 | 04-29 | **统一封装 llama.cpp + MLX(+ FoundationModels)，runtime 不焊死** |
| guinmoon/LLMFarm | 2040 | 2026-01 | 经典 iOS 本地 LLM app，Swift 集成范本 |
| a-ghorbani/pocketpal-ai | 7284 | 06-17 | 完整端侧 LLM 手机 app（RN），产品级体验参考 |
| eastriverlee/LLM.swift | 864 | 2025-12 | 最简 Swift LLM 库（读代码学集成） |
| mattt/llama.swift | 73 | 06-16 | llama.cpp Swift 包装 |
| pgorzelany/swift-llama-cpp | 24 | 06-13 | iOS/macOS 本地 LLM Swift wrapper |
| qualcomm/nexa-sdk（原 NexaAI） | 8104 | 06-17 | 端侧 LLM/VLM SDK，Octopus 系 function calling |

### A5. MCP 技能扩展（Phase 2+）

| 仓库 | ⭐ | pushedAt | 角色 |
|---|---|---|---|
| modelcontextprotocol/swift-sdk | 1410 | 05-07 | 端侧 MCP client（地基） |
| sugarforever/amap-mcp-server | 109 | 2026-01 | 高德地图 MCP（导航，社区版；官方亦有） |
| （瑞幸外卖） | — | — | 无现成官方 MCP，需自己包 API 成 MCP server |

### A6. 淘汰 / 后置

| 仓库 | 原因 |
|---|---|
| snipsco/snips-nlu | 2023-05 死了 3 年，用 hassil 替代 |
| aiopsplus/BFCL-CN | 2025-04 陈旧，用官方 BFCL + tiny-tool-bench |
| eclipse-velocitas/vehicle-app-python-sdk | 2025-07 近 1 年没动，demo 用不上 |
| ShenghaiWang/SwiftLlama | 2025-08 陈旧，用 LocalLLMClient / pgorzelany 替代 |
| eclipse-kuksa/kuksa-databroker | 真车数据 broker，demo 阶段用不上，接真车再说 |

### A7. 自我纠错记录

- 第二轮我曾断言 `ml-explore/mlx-swift-examples` 被改名为 `mlx-swift-lm` —— **错**。第三轮验证两仓都活跃，examples（2607⭐）比 lm（672⭐）更主流。教训：引断言必验证。

---

## Part B. 路线图讨论「七节原文」（磊哥指定存档）

> 以下为 2026-06-17 路线图讨论的完整七节原文，未删改。
> ⚠️ 注意：本节成文于「车控单 domain demo」假设下；多 domain（导航/音乐/外卖）+「LoRA 必做」的修正见 Part C，以 Part C 为准。

### 一、先扭转最关键的认知：你做的不是「产品」，是「销售演示工具」

第 3 点说漏嘴了真相：「我作为方案经理，每次给客户介绍用作演示，不然把样车开到客户那边太麻烦。」这一句重新定义一切。13 点之所以混乱，是因为把「企业级产品开发流程」模板套到了一个「演示工具」上。演示工具的成功标准只有一条：**客户现场那 5 分钟：听得懂中文、反应快、不崩、看着惊艳、断网也能跑。** 拿这条当尺子，E2E/CICD 大砍、后端 SDD 砍、前端/UIUE 合并、微调后置、项目管理极简。省下来的力气全砸到「视觉惊艳 + 现场不崩」。

### 二、给你一个能挂住一切决策的心智模型

唯一判据：**「这一步能让客户现场那 5 分钟更惊艳、或更不崩吗？」** 能→做且早做；不能但客户会当场质疑→准备话术别真做；纯为工程完备→砍或后置。

### 三、关于「微调」——demo 项目最大的认知陷阱

（此节立场已被 Part C 修正，保留原文备查）原论点：Demo 的输入你控制，你知道客户会说哪几十句，微调的价值是泛化到没见过的说法，而 demo 不需要泛化，只需那几十句话术 100% 命中，所以微调后置。→ **Part C 已修正：磊哥反例「我头有点疼/我很累了」属深度模糊+跨域+需推理，规则与话术白名单覆盖不了，LLM+LoRA 是核心卖点，不是后置项。**

### 四、重构后的路线图（Demo-First，6 阶段 + 1 可选）

核心：把「最早能给人看的版本」从第 7 周提到第 2-3 周。
- P0 选型拍板（3-5天）：装依赖 + 拍上游分叉 + 跑通 hello-world JSON
- P1 协议+数据先行（1周）：讯飞清单→自己的 tools.json/synonyms/risk_policy + eval_cases.jsonl
- P2 可演示骨架（1-1.5周）：SwiftUI 面板 + mock 状态 + Debug 面板 + 规则快路径
- P3 接 Qwen 演「聪明」（1-2周）：候选工具召回 + JSON 约束 + 模糊/多意图
- P4 语音闭环（1周）：Push-to-talk + Apple Speech/sherpa-onnx + TTS
- P5 iOS 真机 + 演示加固（1周）：嵌入式模型 + 演示话术回归 + 失败优雅降级
- P6 可选：微调 + 工程化

### 五、几个必须你拍板的关键决策

1. 上游分叉：Qwen3-0.6B 嵌入式（⭐推荐，可控/不挑设备/可微调/稳）vs Apple FoundationModels（最快但锁 iOS26/黑盒/不可微调，留作逃生口）。
2. UI：无现成可套的 iOS 车控面板，直接 SwiftUI + 投资视觉（Figma）。
3. 后端 = 没有，全本地 mock。
4. 测试 = 「演示话术回归」，不是 E2E/CICD。

### 六、项目管理（solo demo 轻量版）

保留：roadmap.md / decisions.md / git main+feature / 每阶段 milestone / CC-Codex 自测内循环。
砍掉：Jira/Scrum/站会/燃尽图/多 gate/80% 覆盖硬指标。
提效：协议整理（你做）// repo 选型（派 CC）可并行。

### 七、回应第 4 点「怎么用 CC/Codex 评估 repo 组合」

路线图的「用哪些 repo」列已把 ~44 仓钉到每个阶段；剩下就是落成分层采用表（= Part A）。

---

## Part C. 多 domain 端侧 Agent 代码基座（2026-06-17 第二轮，新需求修正版）

### C0. 需求升级 + 对 Part B 的两处修正

1. **从单 domain → 多技能平台**：Phase 1 车控，后续导航（amap MCP）/ 音乐（API）/ 外卖（瑞幸 MCP）。基座必须 Day1 按多 domain 抽象，否则 Phase 2 接导航要重构。
2. **LoRA 必做（修正 Part B §三）**：「我很累了 / 我头有点疼」这类深度模糊 + 跨域 + 需推理的意图，规则与话术白名单覆盖不了，是 demo「显得聪明」的命脉，必须 LLM + LoRA。规则只负责高频明确指令的稳定与低延迟，**分工而非替代**。

### C1. 基座 7 层（domain-agnostic 管线 + 可插拔技能）

```
输入   ASR(Apple Speech / sherpa-onnx) / 文本
  ↓
理解   规则快路径（高频明确指令，稳+快+兜底）
       LLM 意图理解（模糊/复杂/跨域，注入 Context，base→LoRA）   ← 卖点
  ↓
路由   Domain Router：这句话落哪个/哪些 domain（可跨域）
  ↓
召回   Tool Retriever：在候选 domain 内从「统一 Tool Catalog」召回 TopK 工具
  ↓
规划   Action Planner：意图→多 tool 计划（跨域/排序/冲突/补槽）  ← domain-agnostic
  ↓
安全   Safety Gate：白名单/参数范围/风险确认                       ← domain-agnostic
  ↓
执行   Executor → Capability Adapter：
         本地 mock（车控，离线）
         MCP client（导航/音乐/外卖，联网，via swift-sdk）
  ↓
反馈   SwiftUI 状态刷新 + TTS
```

### C2. 关键抽象（代码基座的「接口」——加新 domain 不动核心）

- `Capability`（技能协议）：`id / domain / tools / 规则模板 / few-shot / contextProvider / executor(local|mcp)`
- `Tool`（统一）：无论本地函数还是 MCP 工具，在 catalog 里长一样，LLM 看不出区别
- `ToolCatalog`：聚合所有已注册 capability 的 tools
- `IntentEngine`：规则 + LLM（base/LoRA 可换）
- `ActionPlanner`：domain-agnostic，支持「一句话→跨多 capability 的 plan」
- `SafetyGate`：domain-agnostic，读 `tool.riskLevel`
- `Executor`：dispatch 到 local mock 或 MCP client

加新 domain = 写一个 `Capability` + `register()`，核心管线一行不改（开闭原则）：
```
Phase 1: register(CarControlCapability())                 // 本地 mock，离线
Phase 2: register(NavigationCapability(mcp: amapMCP))     // 接高德 MCP
         register(MusicCapability(api: ...))
         register(CoffeeCapability(mcp: luckinMCP))
```

### C3. 「端侧离线」 vs 「接 amap/瑞幸 MCP（联网）」的张力（必须对客户精确表述）

- **大脑（Qwen 意图理解）= 端侧离线，永远听得懂你要干嘛。**
- **技能执行分两类**：本地技能（车控）离线；O2O 技能（导航/音乐/外卖 via MCP）联网。
- demo 策略：每个 MCP capability 配一个 `MockAdapter`，现场无网时降级到录制响应（「假装调了高德」）。`Executor` 支持 live/mock 切换。
- 对客户的话术：**「意图理解 100% 端侧离线，执行按技能：车控离线、生活服务联网」**——比笼统说「离线」更可信、更专业。

### C4. LoRA 定位（确定要做，但有顺序）

1. **Day1 埋数据管线**：每次交互落 trace（输入→规则/LLM 输出→是否正确）。
2. **prompt + few-shot 先验证可行**（base Qwen3-0.6B + 候选工具召回 + JSON 约束）。
3. **攒够「模糊人话→跨域动作计划」样本** → MLX-LM LoRA 提质 + 泛化。
4. LoRA 训练数据 = 各 capability 的 `examples / fuzzy_mapping` 语料，与 P1 协议同源。
→ 训练放 P4-P5 之间（prompt 验证后、真机前），作为持续迭代项，不是 Phase 1 第一天就练（无数据练不动）。

### C5. 规则 vs LLM 分工（回应「规则不能替代万物」）

| | 规则快路径 | LLM（+LoRA） |
|---|---|---|
| 覆盖 | 窄而高频的明确指令（「打开空调」「关车窗」） | 宽而模糊的复杂/跨域意图（「我累了」「头有点疼」「放首歌顺便导航回家」） |
| 价值 | 100% 稳定 + <100ms 延迟（跟手感）+ 模型抽风时兜底 | demo「显得聪明」的命脉、卖点 |
| 次数/价值 | 演示动作次数多、惊艳价值低 | 次数少、惊艳价值高 |

### C6. 路线图微调（基于多 domain + LoRA 必做）

- P0 增一项：用 `modelcontextprotocol/swift-sdk` 跑通 1 个 hello-world MCP call（地基可行性早验证，别等 Phase 2 踩坑）。
- P1：协议按「多 domain capability」结构设计（即便只填车控），为 LoRA 同步攒料。
- P2：基座按 C1/C2 的 domain-agnostic 管线搭（Phase 1 只注册 CarControlCapability）。
- 新增 LoRA 阶段（P4↔P5 之间）：明确纳入，不再标「可选」。

---

## Part D. 已锁定 / 待拍板决策清单

| # | 决策点 | 状态 | 取向 |
|---|---|---|---|
| 1 | 项目本质 = 销售演示工具（北极星：现场 5min 惊艳+不崩） | ✅ 锁定 | — |
| 2 | 架构 = 多技能端侧 agent 平台，Phase1 只装车控 | ✅ 锁定 | — |
| 3 | 外部技能接入 = MCP（swift-sdk 官方）| ✅ 锁定 | — |
| 4 | LoRA = 必做（修正 Part B），数据管线 Day1 埋 | ✅ 锁定 | — |
| 5 | 规则 = 只兜高频明确指令，不替代 LLM | ✅ 锁定 | — |
| 6 | 上游分叉：Qwen3-0.6B 嵌入式 vs Apple FoundationModels | ⏳ 待拍板 | ⭐ Qwen 为主线，FoundationModels 逃生口 |
| 7 | 离线表述：意图离线、O2O 技能联网 + MockAdapter 降级 | ✅ 锁定 | — |
| 8 | UI：无现成套，SwiftUI 自搭 + 投资视觉 | ✅ 锁定 | — |
| 9 | 后端：无，本地 mock | ✅ 锁定 | — |
| 10 | 测试：演示话术回归（非 E2E/CICD） | ✅ 锁定 | — |

---

## Part E. 实时交互三能力调研（⚠️ 调研交流记录，非正式决策）

> 2026-06-17 第三轮。命名澄清：**MA = Master Agent**（MAformac = Master Agent for Mac）。
> 来源场景：按 mic →「我有点困了」→ 快/慢思考路由 → 选「打开通风 + 座椅按摩」→ 按钮变色 + TTS 回复 → **TTS 播放时可打断说第二条** → 第四条「再开大一点」能反映出是空调档位调高（指代消解）。
> 对应 AWS slide 10「Advanced feature: Multi-turn dialogue / Reasoning / Fuzzy Intent」。

### E1. 实时打断 barge-in（三者中工程最硬）

| 仓库 | ⭐ | pushedAt | 角色 |
|---|---|---|---|
| pipecat-ai/pipecat | 12863 | 06-17 | 语音 agent 框架，内置 barge-in（**服务端 Python，借状态机逻辑**） |
| livekit/agents | 11010 | 06-17 | 实时语音 agent 框架，内置打断（服务端，有 Swift client） |
| moonshine-ai/moonshine | 8483 | 06-02 | 超低延迟 STT + intent，适合快响应/打断 |
| snakers4/silero-vad | 9345 | 03-26 | 企业级 VAD，**端侧 barge-in 核心组件**（检测用户开口→打断 TTS），有 ONNX |
| mu-hashmi/personaplex-mlx | 68 | 02-18 | Apple Silicon MLX 全双工移植（小众但端侧对口） |
| kyutai-labs/moshi | — | — | 真全双工语音模型，重 |

- **端侧落地路径**（无现成 Swift 整包，要自搭）：`silero-vad`（检测开口）+ 可中断 streaming TTS + iOS `AVAudioEngine` voice-processing IO（**自带 AEC 回声消除**，否则会录到自己 TTS 误打断）。pipecat/livekit 只借「VAD→interrupt→cancel TTS→新 turn」状态机。
- **状态机**：Listening → Thinking → Speaking(TTS) → [VAD 检测打断] → Interrupt(cancel TTS + **cancel in-flight LLM**) → Listening。
- **关键工程**：可取消性（TTS 可中断 + LLM 推理可取消，否则打断后旧指令还在跑）。
- **demo 风险：高**。V1 = **按钮打断**（按 mic 立即停 TTS，100% 可靠）；V2 = **VAD 免按自动打断**（惊艳但现场噪音易误触发）。

### E2. 快 / 慢思考路由（System 1 / System 2）

| 仓库 | ⭐ | pushedAt | 角色 |
|---|---|---|---|
| aurelio-labs/semantic-router | 3614 | 05-23 | **embedding 语义路由，端侧可跑** = 快思考层现成 |
| lm-sys/RouteLLM | 5031 | 2024-08（陈旧） | LLM 强弱路由，理念可借 |

- **快思考（System 1）** = semantic-router 向量相似度（<50ms）判断：明确指令？哪个 domain？要不要慢思考？
- **慢思考（System 2）** = Qwen LLM 推理（模糊/跨域/需推理才走）。
- 铁律：**路由本身用向量不用 LLM**，否则就不快了。

### E3. 记忆 + 指代消解（关键区分，别被大框架带偏）

| 仓库 | ⭐ | pushedAt | 角色 |
|---|---|---|---|
| mem0ai/mem0 | 58771 | 06-17 | 通用 agent 记忆层（重，服务端） |
| letta-ai/letta（MemGPT） | 23374 | 05-14 | stateful agent 记忆（重） |
| topoteretes/cognee | 17868 | 06-17 | AI 记忆平台（重） |

- **你的例子「再开大一点」→空调 = 短时对话指代消解，不是长期记忆。** 两者方案完全不同：
  - **短时（必需，轻量）**：`DialogueState` 存最近 N 轮 (utterance/domain/tool/slots/result) + **焦点实体**（上一条调的是空调）；指代消解 = 把这个 state 注入 LLM 理解。
  - **长期（nice-to-have，后期）**：mem0/letta 记「磊哥爱 22 度」这种用户偏好。**别用 mem0 做指代消解——杀鸡用牛刀。**

### E4. 三能力嵌入基座（更新 Part C 的 7 层）

- **barge-in** = 会话并发控制层（包裹整条管线，管 Listening/Speaking/Interrupt 状态 + 可取消）。
- **快/慢思考路由** = 强化「理解 + 路由」层（semantic-router 做快思考分流）。
- **记忆** = 贯穿的 `DialogueState` 组件（喂给 LLM 做理解 + 指代消解 + 打断后第二条指令的上下文）。

### E5. demo 风险分级

| 能力 | 难度 | demo 建议 |
|---|---|---|
| barge-in | 高 | 先按钮打断（可靠），VAD 自动打断作 V2 |
| 快/慢路由 | 中 | semantic-router 端侧 embedding，可控 |
| 记忆/指代消解 | 中低 | 短时 DialogueState + LLM，0.6B 准确率靠 few-shot/LoRA |

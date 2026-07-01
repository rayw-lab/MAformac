# MAformac 融合装配蓝图 — 38 肩膀 → 你自己的 MasterAgent demo

> ⚠️ **HISTORICAL / design-provenance（2026-06-30 A 文档收敛降级）**：早期 38 肩膀装配蓝图，当前 runtime/bridge 路线以 active OpenSpec carrier（`define-runtime-presentation-bridge`）+ `CLAUDE.md §9` 为准；本文仅作设计溯源，勿当当前路线。

> 配套:`tech-baseline-from-raw.md`(v0.1 §1-§12)+ `tech-baseline-supplement-v0.2.md`(§13-§17)+ Codex `referencerepo/reports/`(38 repo 深度研究)。
> 本篇回答唯一问题:**这 38 个肩膀,具体怎么拼成一个能跑的端侧 MasterAgent demo。**
> 生成日期:2026-06-17 · 边界:全文「某车厂」,无客户名/报价/密钥。

> 🔴 **范式演进 banner（2026-06-23 文档级联，finding round-04 补三改点；本文 2026-06-17 早于范式翻案，装配思想仍有效，但下三点须以新权威为准）**：
> 1. **surface 层演进（generic frame → D-domain 具名工具）**：model-visible surface 已从 generic `tool_call_frame{device,action,value}` 翻案为 **D-domain 具名工具**（value 形态编码进工具名，如 `adjust_ac_temperature_to_max`/`_to_number`/`_by_exp`/`query_ac_temperature`）；generic frame 作 surface 已否决（1.7B 判定面爆炸，θ-α 0/23 根因）。canonical IR 仍 device×action_primitive×value（「对模型像 D-domain 具名工具，对系统像 device×action IR」）。权威 = `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md §1-§2`。
> 2. **训练/eval/runtime surface 三处同源 enforce（TRN2 议题）**：D-domain 工具 surface 必从上游 A2 codegen **单一源派生**到训练面 / eval(C6) 面 / runtime 推理面，三处异源是 C5 `0/34` 灾难根因（Q05）；不得三处各写一套 surface。
> 3. **10 族演示 scope 三层边界**：① runtime 演示层 = MVP 10 族（191 device / 562 intent / 2159 行 / 全集 54.1%，空调/座椅/车窗/车门/灯光氛围/屏幕/音量/雨刮/天窗遮阳/香氛，HUD 不做）② 10 族内模糊说靠 LoRA 泛化（implicit 慢路）③ 族外（480 device / 976 intent / 1831 行）走 `unsupported` 优雅兜底，不追全集泛化。LoRA 训练 = 10 族 562 scope **不训全集 3990**（A3 已拍）。口径权威 = `CONTEXT.md` 口径权威表 + `grill-decisions-master.md §0`。

---

## 0. 核心认知:38 个不是都进 App,分三类

融合最容易犯的错是"想把 38 个都用上"。实际只有 **6-7 个进 App 运行时**,其余是开发期工具或纯参考。

| 类别 | 进什么 | 数量 | 代表 |
|---|---|---|---|
| **A. App 运行时(Swift,真编译进 app)** | 端侧推理/ASR/工具协议 | ~7 | mlx-swift-lm · llama.swift · swift-transformers · WhisperKit · sherpa-onnx · MCP-swift-sdk(借思想)|
| **B. Mac 开发期工具(Python,不进 app)** | 原型/评测/训练/数据生成 | ~5 | llamafile · gorilla(BFCL)· tiny-tool-bench · mlx-lm · outlines |
| **C. 只抄思路/数据/判断(零代码进仓)** | 命名法/架构/模型对比/避坑 | ~26 | COVESA VSS · Canals · agent-tester · nlu-pipeline-vehicle · Hammer · xLAM · functionary · Codex 11 条判断 |

> 自建(38 repo 无对口,必须自己写):规则快路径(hassil 思路 Swift 复刻)、DialogueState、三态引擎、ActionPlanner、SafetyGate、barge-in、中枢 Router。这些是 MAformac 的**核心 IP**,不是拼来的。

---

## 1. 模型尺寸决策(回应"0.6B 不够 1.X B 也行")

| 选项 | Q4 体积 | 端侧 | FC/多阶/跨域 | 结论 |
|---|---|---|---|---|
| Qwen3-0.6B | ~0.4GB | 最快/最省 | 弱(并行多工具易错,04 报告实证) | 极致轻量/老设备**备选** |
| **Qwen3-1.7B** | **~1.1GB** | **Mac/新 iPhone 可跑** | **明显更稳** | **demo 主力 ⭐** |
| Qwen3-4B | ~2.5GB | 偏重 | 强 | 超出 demo 必要,暂不 |

**裁决**:demo 主力 **Qwen3-1.7B**(炸场要"聪明",不着急+设备够);0.6B 备选。`LLMBackend` 协议(v0.1 D1)让模型一行配置可换——先 1.7B 跑通能力,后期想轻量再降,不锁死。LoRA(D27)同样在 1.7B 上做,效果比 0.6B 更稳。

---

## 2. A 类:进 App 运行时(Swift)

| repo | 装在哪层 | 角色 | adopt 方式 |
|---|---|---|---|
| **ml-explore/mlx-swift-lm** | Runtime | 主 backend(Apple 原生,Qwen 推理) | 整包依赖,实现 `MLXBackend: LLMBackend` |
| **mattt/llama.swift** | Runtime | GGUF fallback backend | 备选,实现 `LlamaBackend: LLMBackend` |
| **huggingface/swift-transformers** | Runtime | tokenizer + 模型资产管理 | 整包,管 tokenizer 一致性 + 本地模型校验 |
| **tattn/LocalLLMClient** | Runtime | facade **范本**(统一 llama/MLX/FoundationModels) | 抄其 facade 设计,自建 `LLMBackend` 协议 |
| **argmaxinc/WhisperKit** | Voice | 端侧 ASR(D14 锁定) | 整包依赖 |
| **k2-fsa/sherpa-onnx** | Voice | VAD/KWS(barge-in 端点检测)+ 中文 TTS 备选 | 取 VAD/KWS 模块;WhisperKit 中文不稳时上其 ASR |
| **modelcontextprotocol/swift-sdk** | AgentCore | 工具协议**思想**(name/desc/in-schema/out/error) | 首版只借 schema + tool registry,不起 server(D16) |

**Runtime 抽象铁律(v0.1 D1)**:业务层只依赖 `LLMBackend { load/generate/stream/cancel }`,MLX/llama/FoundationModels 三路可换。runtime spike 排在 UI 大开发之前。

---

## 3. B 类:Mac 开发期工具(Python,不进 app)

| repo | 用途 | 产出 |
|---|---|---|
| **mozilla-ai/llamafile** | Mac 原型期一文件起 server | 调 prompt/schema/多意图,iOS 没跑通前先验证语义层 |
| **ggml-org/llama.cpp**(server) | Mac 开发期 OpenAI 兼容 server + GBNF | 结构化输出验证 |
| **ShishirPatil/gorilla**(BFCL) | FC 评测框架参考 | 造 `vehicle-tool-bench`(中文车控版) |
| **javierlimt6/tiny-tool-bench** | 小模型 FC 评测(贴 1.7B/0.6B) | eval CLI 雏形:准确率/可解析率/参数错误率 |
| **ml-explore/mlx-lm** | LoRA 训练(D30 锁定) | `mlx_lm.lora/fuse/convert` → Q4 |
| **dottxt-ai/outlines** + **lm-format-enforcer** | 结构化输出/数据生成 | 造 LoRA 训练+eval 数据(概念进,Swift 端同构) |

> 全 Python,**零进 iOS**(v0.1 D7)。Mac 上跑,产数据/产指标/产权重。

---

## 4. C 类:只抄思路/数据/判断(零代码进仓)

- **COVESA/vehicle_signal_specification + vss-tools** → 命名法,生成 20-50 高频 `end_state_field` path(防"一个车窗三个名",v0.1 D8)。
- **OHF-Voice/hassil + intents** → 规则快路径**蓝本**,Swift 复刻迷你版(Python 不进 app)。
- **dengky23/nlu-pipeline-vehicle** → "功能清单→语料/同义词/槽位"处理套路(LoRA 数据)。
- **Bosch.../Canals + reinhardjurk/agent-tester** → 车载语音 agent 架构 + 评测框架参考。
- **MadeAgents/Hammer + Salesforce/xLAM + MeetKai/functionary** → 小模型 FC 数据格式 + 选型对比(若 Qwen3-1.7B FC 不稳,Hammer/xLAM 是替补模型)。
- **wizcheu/iOSLLMFrameworkBenchmark** → 仿做你自己的 runtime 实测(1.7B 在 iPhone 的加载/延迟/内存/发热)。
- **qualcomm/nexa-sdk** → CLI 先行策略参考(先 Mac CLI 跑通 FC,再 iOS UI)。
- **Codex 38-repo 报告 11 条判断**(v0.1 §10)→ 工程铁律,贯穿全程。

---

## 5. 融合装配图(7 层架构 × repo)

```
┌─ L0 barge-in 包裹层 ── sherpa-onnx(VAD/KWS) + 自建状态机(v0.1 §9) ──────────┐
│  语音输入 ── WhisperKit(ASR) ─────────────────────────────► text          │
│  L1 理解 ── hassil-Swift(规则快路径) + LLMBackend[mlx-swift-lm+Qwen3-1.7B] │
│             swift-transformers(tokenizer) · 快慢路由(自建)                  │
│  L2 路由 ── Registry.route(自建) · MCP-swift-sdk(工具协议思想)             │
│  L3 规划 ── 三态引擎(自建,纯函数) · ActionPlanner(自建) · 多阶(§13)        │
│  L4 安全 ── SafetyGate(自建,代码护栏 R0-R3,§16)                            │
│  L5 执行 ── Capability[mock] → 改 UI 卡片亮暗 + TTS 播报                     │
│  DialogueState(自建,§8)贯穿 · VSS path(COVESA)命名 · contracts/tools.json │
└────────────────────────────────────────────────────────────────────────────┘
  开发期(Mac,Python): llamafile/llama.cpp(原型) · gorilla+tiny-tool-bench(eval) · mlx-lm(LoRA) · outlines(数据)
```

**关键**:绿色能力(规则/三态/Planner/SafetyGate/DialogueState/barge-in/Router)全是**自建 IP**,repo 只提供推理(mlx)、ASR(WhisperKit)、协议思想(MCP)、命名(VSS)、评测/训练(Python)。**MasterAgent 的"脑子"是你自己的,肩膀只是手脚。**

---

## 6. 端到端数据流:「我有点冷」→ 卡片亮(每步标 repo)

```
1. 语音"我有点冷"      → WhisperKit(ASR) → text                          [A]
2. L0 监听插话          → sherpa-onnx(VAD) 持续监听,可打断 TTS            [A]
3. L1 规则快路径        → hassil-Swift:无明确指令命中 → 转慢              [自建/抄hassil]
4. L1 意图理解          → mlx-swift-lm + Qwen3-1.7B:落"温度感受/未指对象"  [A]
                          tokenizer ← swift-transformers
5. L2 路由              → Registry.route → carControl/温度垂域             [自建]
6. L3 查端状态          → query_vehicle_state 读 mock UI store:           [自建+mock]
                          {空调24, 座椅加热OFF, 季节冬} (D16 自包含)
   三态判定            → 空调可升/座椅加热可开 = 未满足                    [自建纯函数]
   ActionPlanner       → 计划[空调→26, 座椅加热→LOW]                       [自建]
7. L4 安全             → SafetyGate: R0 低风险 → 直接执行                  [自建,§16]
8. L5 执行             → execute_vehicle_control:                         [自建+mock]
                          改 UI: 空调卡片亮+显26°, 座椅加热卡片亮          [SwiftUI]
                          TTS 播报"帮您升到26度,开了座椅加热"             [WhisperKit/系统TTS]
9. DialogueState       → 记 last_exec={空调,26} → 下句"再高一点"可指代     [自建,§8]
```

全链路**断网可跑**(除非走导航/音乐 MCP 联网域,首版全 mock)。

---

## 7. 骨架目录结构(模块 × 依赖 repo)

```
MAformac/
├── App/                      SwiftUI: 车控卡片面板 + Debug 面板 + push-to-talk 按钮
│   └── (呼应 Voice Assistant 截图: AC/Light/Fragrance/Fan/Window 卡片, 亮暗=端状态)
├── Runtime/                  LLMBackend 协议 + MLXBackend(mlx-swift-lm) + LlamaBackend(llama.swift)
│   └── Tokenizer(swift-transformers) + ModelAssets(预置/本地导入,不运行时下载)
├── Voice/                    ASR(WhisperKit) + VAD/KWS(sherpa-onnx) + TTS(系统/sherpa)
├── AgentCore/                ★核心 IP,自建★
│   ├── FastPath.swift        规则快路径(抄 hassil 思路)
│   ├── Router.swift          落域+Skill选型+拒识(抄 MCP registry 思想)
│   ├── ThreeStateEngine.swift 三态判定(纯函数)
│   ├── ActionPlanner.swift   多意图/冲突/补槽 + 多阶(§13)
│   ├── SafetyGate.swift      R0-R3 五门(§16)
│   └── DialogueState.swift   短时焦点栈 + 长期 person_registry(§8)
├── Capabilities/             CarControlCapability(mock) + NavCapability(MCP/mock,二期)...
├── Contracts/                tools.json(八大垂域) + DialogueState schema + vss_paths.yaml(COVESA)
├── MockVehicle/              UI 卡片状态 store(D16: 端状态自包含)
└── dev/                      ★Python,不进 app★
    ├── eval/                 vehicle-tool-bench(抄 gorilla/tiny-tool-bench)
    ├── train/                mlx-lm LoRA 脚本(D30)
    └── datagen/              五件套数据生成(抄 outlines/dengky23 套路)
```

---

## 8. 第一刀(最小可跑起点,验证融合可行)

**目标**:Mac 上跑通"文本 → 意图 → mock 车控 → 卡片亮 + 文字回复"闭环。

> ⚠️ **第一刀 = 最小验证 spike,≠ MVP 范围**(磊哥 2026-06-17 纠正)。
> **MVP 范围 = 车控 + ASR + TTS + LoRA(catch 6 拍板,全做)**。第一刀**仅是开发起点**先跑文本闭环(D15 文本先行);ASR/TTS/LoRA 是 **MVP 必交付**,实现顺序排在文本闭环之后,**不是不做**。MCP(导航/音乐)才是 Phase2 预留。
> 引用纪律:别把"第一刀 spike 范围"当"MVP 范围",别孤立引单行结论(本行曾误导)。

5 步:
1. **llamafile/llama-server 起 Qwen3-1.7B**(B 类,最省事,免编译)。
2. **SwiftUI 极简面板**:4-6 个车控卡片(空调/座椅/车窗/灯)+ 一个文本输入框 + Debug 区。
3. **一条规则快路径**:「打开空调」→ FastPath 命中 → 卡片亮(证明快路径)。
4. **一条 LLM 路径**:「我有点冷」→ 调 llama-server → 读 mock state → 三态 → 推荐 → 卡片亮 + 文字回复(证明慢路径+三态)。
5. **Debug 面板**显示:规则命中/落域/端状态/LLM 输出/最终动作(v0.1 §3 调试可视化)。

跑通这一刀 = 融合骨架立住,后面接 ASR(WhisperKit)、嵌入式模型(mlx-swift-lm)、LoRA、多 domain 都是往这个骨架上挂。

> 之后顺序:第一刀 → 接 WhisperKit 语音 → 嵌入式 mlx-swift-lm(脱离 server)→ 八大垂域填满 → LoRA(攒够 trace)→ 多 domain MCP → barge-in。

---

## 9. 对标 AWS AgentCore(完备性检查 + demo 取巧边界)

> 来源:磊哥提供的 **AWS AI portfolio** 图(红框 AgentCore)。**注意:这不是座舱架构图,是 AWS 通用 agent 平台的横切能力清单**(slide 10「海外座舱 AI Agent」才是座舱方案)。拿 AgentCore 当 MAformac 的"完备性对照表":对标生产级 agent 该有的能力,看我们覆盖/降维/砍了什么。

| AgentCore 组件 | MAformac 对应 | 状态 |
|---|---|---|
| Runtime | Runtime 层(LLMBackend + mlx-swift-lm) | ✅ 已有 |
| Memory | DialogueState 短时 + person_registry 长期(§8) | ✅ 已有 |
| 1P Tools | Capabilities(车控 mock + MCP) | ✅ 已有 |
| Evaluations & Optimization | eval 集 + vehicle-tool-bench + LoRA(§11/§15) | ✅ 已有 |
| Agent Registry | Capability Registry(register/route) | ✅ 已有(轻量) |
| Observability | Debug 面板 + trace 落盘(D29) | ✅ 已有(demo=可视化) |
| Gateway & Policy | 本地 Router + SafetyGate R0–R3(§16) | 🔻 降维(去云网关) |
| Identity | 多用户/访客护栏(§16.2) | 🔻 大幅降维(单用户自用) |
| payments | — | ✂️ 砍(外卖 MCP 二期再说) |

下层映射:Models=Qwen3-1.7B+LoRA(非 Bedrock 云);Guardrails=SafetyGate;Customization=LoRA;**Knowledge Bases=✂️砍**(车控无需 RAG);SageMaker 云训练=mlx-lm 本机;Trainium/GPU=Apple Silicon。两侧:MCP/A2A=MCP-swift-sdk + 中枢 Agentic-Skill(§14);Security & Policies=SafetyGate(§16)。

**两个结论**:
1. **完备性验证**:对标 AWS 生产级 agent 平台,MAformac 基座该有的横切能力(Runtime/Memory/Tools/Eval/Registry/Observability)全有 → 架构完备,是"端侧离线降维版的 AgentCore",不是玩具。
2. **demo 取巧边界**:砍 Identity / Payments / Gateway / Knowledge Bases / 云训练——多租户/企业/云的重组件,单用户离线 demo 不需要。

> 一句话:AWS AgentCore 给了"生产级全集",MAformac 对照着砍出"端侧 demo 子集"——它验证我们没漏关键能力,也划清了该省的地方。

---

## 10. 读全 38-repo 报告后的修订与补漏(2026-06-17)

> 读完 Codex 全部 7 份报告(01-07,逐 repo 四段 + 深附录)后的增量修订。之前融合方案基于 03/04 两份,此节补全。

### 10.1 Canals 定位修正(磊哥关注)

Canals **不是"用不了",是 38 个里最像"完整车控 Agent"的目标系统图**(app/backend/car-api/kuksa/ui/e2e 全栈,Python+Docker+KUKSA,云依赖)。**全栈太重不进 Swift 客户端,但第一版抽它 20%**:
- 三抽象进 MAformac:`VehicleStateStore`(端状态)+ `VehicleActionExecutor`(动作校验+写入)+ `AgentTrace`(命令→工具→状态变化链路记录)。
- 纪律:语音/NLU 只产意图 → 执行器只做校验+写状态 → UI 只展示状态和轨迹(**三者分离,别混进 SwiftUI 按钮回调**)。
- 它验证了 D16(mock 车端闭环)+ 分层架构方向正确。归类:C 类**但价值最高**(目标系统图)。

### 10.2 判错纠正:kuksa-databroker 提级(C 淘汰 → B 开发期)

之前(§0/README)把 `kuksa-databroker` 归"淘汰/后置",**读全报告后纠正**:它是 **Mac 开发期最值得接的车端模拟器**,用途 = **D4 铁律("读回 mock 态才算成功")的自动化验收环境**——测试前写初始车况 → 执行命令 → 读 broker 状态 → 比期望,杜绝"模型说成功就算成功"。修订为 **B 类开发期工具(第二阶段,action schema 稳定后接;iOS 仍内存版,Mac 用 broker 做动作回归)**。

### 10.3 强化已有设计的 4 点

- **Alexa Auto SDK → capability-agent 结构**:车控拆 `HVACAgent/WindowAgent/SeatAgent/LightAgent/MediaAgent`,各自暴露 schema+状态读取+执行校验+UI 卡片数据,**不是巨型 switch**。强化 v0.1 §4.2 Capability 协议。
- **rhasspy → 离线语音 pipeline 协议链**:`AudioInput→VAD→SpeechRecognizer→IntentResolver→DialogueState→ToolExecutor→SpeechFeedback`,每环可替换;首版 VAD 简化成按钮但协议保留。强化 Voice 层 + barge-in(§9)。
- **instructor → 类型接住模型输出**:Swift `Codable+enum+validator`,参数范围硬校验(温度 **18-32** ⚠️v2 纠错(旧 16-30 是拍错,端态打点为准)/ 窗 0-100 / 座椅 0-3 / 区域枚举不可造);越界不修正不猜,转澄清/拒绝。强化 D5。
- **vss-tools → 开发期生成器**:`capabilities.yaml`(源)→ 生成 `VehicleCapability.swift` + `tool_schemas.json` + 能力表.md(一处定义三处生成 + 规格漂移检查)。明确进 B 类。**⚠️ v2(2026-06-19):扁平 `capabilities.yaml` 单一事实源已被 C1 `semantic-function-contract`(源行级全集 SSOT + make verify drift gate)supersede;codegen/漂移检查思想保留,落点改 C1,见 `CLAUDE.md §9`。**

### 10.4 贯穿洞察:差异化是"能力治理",不是模型

07 报告反复强调(nexa/autowrx/tiny-tool-bench 节):**差异化不在"我也能跑模型",而在车控能力目录 + 规则快路径 + 安全执行链路**;"功能清单多了,先需要的不是更多模型,而是**能力治理**"。正面回应"很多功能清单"——核心资产 = `capabilities.yaml` **单一事实源**(中文别名/参数/状态依赖/确认策略/VSS 映射/UI 分组),模型只是其中一环。升级方向:vdm 的"让 Agent 查询自己能做什么"(`listCapabilities/getCurrentState/explainCapability`),让模糊意图不靠 prompt 记忆、靠可查询能力目录。

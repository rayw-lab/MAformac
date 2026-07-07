# 端侧 FC 小模型选型深扒 — 7 路 subagent finder 原始调研存档

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

> workflow `wf_94a033db-e00` 的 7 路 finder 各自的完整结构化调研结果（从 subagent transcript StructuredOutput 提取）。
> 综合版见同目录综合报告；本文是**逐路原始发现**（每路 ≥10 联网搜证），保留 source_url/tigers/候选不丢。

---
## skill 巨人肩膀 + 成熟框架方案(端侧小模型 train→deploy 工程链路)。核心问题:有无现成"域微调→量化→tool-call→iOS 部署"端到端 skill/框架可 adopt 避免手搓。结论:没有单一 turnkey 端到端 skill;但 train 侧(mlx-lm-lora/Unsloth)+ deploy/runtime 侧(mlx-swift-lm/MLX-Outil)各有强候选,MLX-Outil 是与 MAformac 完全同栈(Qwen3-1.7B+MLX Swift+iOS tool-call)的近 drop-in 参考,直接 adopt 其 LLMManager 单跳 tool-call loop + ToolDefinitions 类型化 Tool schema 形态。

- **联网搜索次数**: 14
- **一句话结论**: 没有单一 turnkey'域微调→量化→tool-call→iOS 部署'端到端 skill;现实=train 侧(C5 守 unsloth+Hammer/xLAM 配方,Mac 本地可加 mlx-lm-lora QAT 对比)+ runtime 侧分栈 stitch,而 runtime 侧有近 drop-in 蓝本 MLX-Outil(124★,Qwen3-1.7B+MLX Swift+iOS tool-call 完全同栈)可直接 adopt 其 LLMManager 单跳 loop + ToolDefinitions 类型化 Tool schema,反向支撑'守 Qwen3-1.7B'(它正用 1.7B 实证端侧 tool-call 路径已通)——避免手搓,巨人肩膀就在同栈。
- **本机 scout**: 本机硬件: Apple M5 / 32GB(训练机,over-provisioned 已证)。mlx-lm 0.31.1 已装(Mac 本地训练就绪,无需 CUDA/Colab)。HF 缓存已有 mlx-community/Qwen3-1.7B-4bit(选型基线,与 MLX-Outil 内置同款)+ Qwen3.5-2B-4bit(spike 已测劣)+ Qwen3.6-35B-A3B-4bit/8bit(说明已有 Qwen3.6 代,但 35B MoE 远超 iPhone ≤4B 天花板,端侧不适用)。ref-repos 已有 home-llm/mastra/pi/gorilla/tool-calling-benchmark,本次新增 clone MLX-Outil。注:本路是'端侧栈/skill'角度,未做 iPhone 实机 tok-s 实测(无设备在手),feasibility 基于权重大小+官方文档+同款模型缓存推断。
- **clone 深扒**: /Users/wanglei/workspace/raw/05-Projects/MAformac/ref-repos/MLX-Outil

### 候选
- **rudrankriyam/MLX-Outil (端侧 tool-call 参考 app, 非新模型)** (size=N/A(框架/模板;内置模型即 Qwen3-1.7B-4bit), release_date=活跃维护中, architecture=Swift app 模板 — MLXLLM/MLXLMCommon 上的 tool-call runtime + 类型化 Tool schema, vs_1_7b=unknown)
  - fc_benchmark: 未证实(无 BFCL 分);但代码实证 mlx-swift-lm 原生 toolCall 流式解析对 Qwen3-1.7B 工作 — LLMManager.swift:111 generation.toolCall + ToolManager.execute 8 工具 switch
  - chinese: MLX Outil — Qwen3-1.7B + MLX Swift 跨 iOS/macOS/visionOS 的 tool-calling 演示 app
  - mlx_support: 本身就是 mlx-swift-lm 之上构建(LLMRegistry.qwen3_1_7b_4bit + LLMModelFactory + UserInput(chat:tools:) + 原生 generation.toolCall 解析)
  - iphone15pm_8gb_feasible: 可行 — 内置 Qwen3-1.7B-4bit,iOS 17.0+;README 标 iPhone 实跑;1.7B/4bit 权重 ~1.0-1.3GB,8GB RAM 充裕(本机已缓存 mlx-community/Qwen3-1.7B-4bit 同款)
  - freshness_heat: 124★ / pushed 2026-05-23(28天前,活跃)/ 作者 rudrankriyam(MLX Swift 布道者,有配套博客)
  - classic_issues: issue 未深挖;代码层观察:单跳 tool exec 后 includingTools:false 再生成(LLMManager.swift:162),与 home-llm 单发旋钮同源 = 防多跳爆炸;工具用 EventKit/HealthKit 真实系统,MAformac 改为 mock 车控即可
  - vs_1_7b_evidence: 不是模型,是端侧 tool-call 工程参考;它正好用 Qwen3-1.7B 做演示 = 验证 1.7B 在 MLX Swift 上 tool-call 路径已通,反向支撑守 1.7B
  - source_url: https://github.com/rudrankriyam/MLX-Outil
- **ml-explore/mlx-swift-lm (官方端侧 runtime 骨架)** (size=N/A(框架), release_date=持续更新(3.x major), architecture=官方 Swift 包 — ChatSession/UserInput/原生 Qwen3 tool-call 解析 + LLMRegistry, vs_1_7b=unknown)
  - fc_benchmark: 未证实(框架不打分)
  - chinese: MLX Swift LM — Apple 官方 LLM/VLM on MLX Swift 包(已是 spike-e3 3.x 基座)
  - mlx_support: 就是 mlx-swift 生态本体;MAformac CLAUDE.md 已锁主推 mlx-swift-lm 3.31.3
  - iphone15pm_8gb_feasible: 可行 — 官方 MLXChatExample 即 iOS+macOS 双跑;承载任意 mlx-community 4bit 模型(含 Qwen3-1.7B)
  - freshness_heat: 678★ / pushed 2026-06-19(当天!极活跃)/ Apple ml-explore 官方;注意 3.x 有 breaking changes(解耦 tokenizer/downloader)
  - classic_issues: 3.x 升级 breaking changes 需读 upgrading doc;MAformac spike-e3 锁 3.31.3 应核对是否需跟进
  - vs_1_7b_evidence: 运行时框架非模型;它决定'1.7B 能不能在 iPhone 上 tool-call',答案=能(MLX-Outil 实证其上)
  - source_url: https://github.com/ml-explore/mlx-swift-lm
- **Goekdeniz-Guelmez/mlx-lm-lora (Mac 端训练栈)** (size=N/A(训练工具), release_date=活跃, architecture=训练栈 — mlx-lm 之上加 QAT(量化感知训练)/Dr.GRPO/DAPO/DPO, vs_1_7b=unknown)
  - fc_benchmark: 未证实
  - chinese: MLX-LM-LoRA — 在 Apple Silicon 上用 MLX 训 LLM(QAT/GRPO/DPO)
  - mlx_support: 纯 MLX,支持所有 mlx-lm 模型(含 Qwen3 系);本机 Mac M5/32GB mlx-lm 0.31.1 直接兼容
  - iphone15pm_8gb_feasible: N/A(训练在 Mac,不上手机);产物 LoRA adapter 经 mlx-swift-lm load(into:) 端侧加载
  - freshness_heat: 380★ / pushed 2026-06-16(4天前,活跃)/ 作者活跃维护
  - classic_issues: 未深挖;QAT 路径 vs MAformac C5 现锁 unsloth+Hammer+xLAM,需评估是否切 mlx 原生训练(优势=Mac 本地 mlx-lm 0.31.1 已装,无需 CUDA/Colab)
  - vs_1_7b_evidence: 训练侧工具,与基座选型正交;关键价值=QAT 让 4bit 端侧精度损失更小(对 8GB iPhone 量化友好)
  - source_url: https://github.com/Goekdeniz-Guelmez/mlx-lm-lora
- **unslothai/unsloth + ExecuTorch (.pte 端侧部署链路)** (size=N/A(训练+部署链路), release_date=持续更新, architecture=训练加速(2x/省 60% 显存)+ qat_scheme='phone-deployment'(int8-int4 QAT)→ ExecuTorch .pte, vs_1_7b=unknown)
  - fc_benchmark: Unsloth Studio 标'self-healing tool calling' 支持,但无端侧 BFCL 分;未证实
  - chinese: Unsloth — 训练加速 + ExecuTorch QAT phone-deployment 到 iPhone
  - mlx_support: 不走 mlx-swift!走 ExecuTorch(.pte)+ etLLM app,是 mlx 之外的另一条端侧栈
  - iphone15pm_8gb_feasible: 官方实证 Qwen3-0.6B 在 iPhone 15 Pro ~40 tok/s;Qwen3-4B/4bit 列为 8GB 'sweet spot';1.7B 4bit 8GB 可行但官方未给精确 RAM
  - freshness_heat: 66945★ / pushed 2026-06-20(当天!)/ 训练侧绝对主导
  - classic_issues: 🔴 已知坑:Qwen3.5/3.x GGUF 导出被误判 VLM 架构(Qwen3_5ForConditionalGeneration)→ 空文件夹(issue #4534/#3899),workaround=手动 save_pretrained 再 llama.cpp 转;ExecuTorch .pte 路线与 MAformac 现锁 mlx-swift 栈不同,是 fallback 不是主线
  - vs_1_7b_evidence: 部署链路非模型;支持 Qwen3 全系(0.6B/4B/32B)+ Gemma3/Llama3/Qwen2.5/Phi4,可承载守 1.7B 也可换 4B
  - source_url: https://unsloth.ai/docs/basics/inference-and-deployment/deploy-llms-phone
- **huggingface/AnyLanguageModel (HF 官方 drop-in FoundationModels)** (size=N/A(Swift 运行时抽象), release_date=活跃, architecture=drop-in FM API,后端可挂 MLX/CoreML/llama.cpp;与 MAformac 的 LLMBackend 抽象同构, vs_1_7b=unknown)
  - fc_benchmark: 未证实
  - chinese: AnyLanguageModel — Apple FoundationModels API 的 drop-in 替换,支持自定义 provider + tool calling
  - mlx_support: 支持 MLX 后端;tool calling 除 llama.cpp 外所有 provider 都支持
  - iphone15pm_8gb_feasible: iOS 端可行(FM API 兼容层);承载 mlx-community 4bit 模型
  - freshness_heat: 894★ / pushed 2026-06-20(当天!)/ HuggingFace 官方出品
  - classic_issues: 需评估 iOS 18+ FM 兼容层 overhead;MAformac 已自有 LLMBackend/ASRBackend 抽象,此为可借形态/可不引
  - vs_1_7b_evidence: 运行时抽象层非模型;可作 MAformac LLMBackend 协议的现成蓝本(统一 FM 调用点 + tool calling)
  - source_url: https://github.com/huggingface/AnyLanguageModel
- **raullenchai/Rapid-MLX (Mac 端 OpenAI 兼容 server, 非 iOS)** (size=N/A(推理 server), release_date=活跃, architecture=MLX 后端 OpenAI/Anthropic 兼容 server,17 个 tool parser + prompt cache + reasoning 分离, vs_1_7b=unknown)
  - fc_benchmark: 标'100% tool calling'(自述,无第三方 BFCL);未证实
  - chinese: Rapid-MLX — Apple Silicon 最快本地 AI 引擎,100% tool calling + 17 tool parser
  - mlx_support: 原生 MLX,但是 Mac server(给 Claude Code/Cursor 用),不是 iOS on-device 包
  - iphone15pm_8gb_feasible: 不可行 — 是 Mac 桌面 server,不上 iPhone;但其 17 tool parser 实现可作 tool-call 解析参考
  - freshness_heat: 3004★ / pushed 2026-06-20(当天!)/ 高人气高活跃
  - classic_issues: Mac-only server,不是 iOS 端侧栈 → 对 MAformac 端侧部署不直接适用,仅 tool-parser 设计可借
  - vs_1_7b_evidence: server 非模型;价值=tool parser 鲁棒性参考(对应 home-llm 三层防御解析),不直接端侧用
  - source_url: https://github.com/raullenchai/Rapid-MLX

### tigers (坑点)
- [MEDIUM] 误判'有现成端到端 skill 可一键 train→deploy',浪费时间找不存在的银弹
  - 证据: 14 次搜证 + WebSearch 显式确认:'没找到单一 repo 把 domain fine-tune + quantize + tool-call + on-device 全打包成 turnkey scaffold';dgrauet/claude-skill-mlx-porting(2★)是视频模型 PyTorch→MLX 移植,与端侧 FC 微调无关。现实=train 侧(mlx-lm-lora/Unsloth)+ deploy 侧(mlx-swift-lm/MLX-Outil)分栈 stitch。
  - 缓解: 接受'stitch 而非银弹':train=mlx-lm-lora 或 Unsloth(Mac 本地优先 mlx-lm-lora),runtime=mlx-swift-lm + MLX-Outil 单跳 loop 骨架。MAformac C3/C5/C6 已是这个分栈结构,无需另找端到端 skill。
- [MEDIUM] MLX-Outil 是'多跳 agent loop'倾向(每次 tool 后再生成),若直接照搬可能与 MAformac 单跳/确定性 DemoFlow 红线冲突
  - 证据: LLMManager.swift:148-172 handleToolCall 后递归 performGeneration;虽然它已用 includingTools:false 限制第二跳不再带工具(单跳化),但结构上仍是 LLM 驱动的续生成,而 MAformac CLAUDE.md/Mastra teardown 已锁'拒自由 agent loop + C4 确定性 DemoFlow'。
  - 缓解: adopt 时砍掉续生成的 LLM 自由度:tool 结果直接走 DemoGuard→mock state→renderReadback(确定性 TTS 模板),不让 LLM 二次生成措辞。借 MLX-Outil 的 generation.toolCall 解析 + Tool schema 形态,不借它的 agent 续生成语义。与 home-llm MAX_ITER=0 单发旋钮一致。
- [HIGH] 训练栈切换风险:若被 mlx-lm-lora 'Mac 本地更省事'吸引而偏离 C5 已锁的 Hammer/xLAM function-masking 数据配方,导致 FC 死记/拒识能力退化
  - 证据: C5 现锁 unsloth+Hammer(function masking)+xLAM(arg-token masking)是为 FC/拒识专门选的方法学(见 memory maformac-lora-train-eval-stack 3 HIGH:防死记/防假提升/防手痒)。mlx-lm-lora 优势只在'Mac 本地 + QAT',不提供 function-masking 数据配方。混淆'训练引擎'与'数据配方'会丢掉 restraint 能力。
  - 缓解: 明确分层:数据配方层(Hammer function-masking + xLAM arg-token masking + held-out)不动,只在'训练引擎'层评估 mlx-lm-lora vs unsloth(Mac 本地 QAT 是优势,但需自己实现 masking)。HIGH 级别建议守现锁配方,mlx-lm-lora 仅作 QAT 端侧精度对比 spike,不替换数据流。请磊哥拍。
- [MEDIUM] ExecuTorch .pte 栈与 mlx-swift 栈混用造成双端侧栈维护负担 + Qwen3.x GGUF/VLM 导出坑
  - 证据: Unsloth ExecuTorch 走 .pte/etLLM,mlx-swift 走 .safetensors;Qwen3.5/3.x GGUF 导出被误判 VLM 架构出空文件夹(unsloth issue #4534/#3899)。MAformac 已锁 mlx-swift 主线,引 ExecuTorch 会多一条栈。
  - 缓解: 守 mlx-swift 单主线(LLMBackend 协议留 .pte 为未来 fallback 实现,当前不实装)。若守 Qwen3-1.7B(.safetensors→mlx 量化),完全绕开 GGUF/VLM 导出坑。
- [LOW] 把高 star repo(Rapid-MLX 3004★/Unsloth 67k★)的人气误当'适用性',引入不适合端侧 iOS 的方案
  - 证据: Rapid-MLX 3004★ 但是 Mac 桌面 server 非 iOS;Unsloth 67k★ 但端侧走 ExecuTorch 非 mlx-swift。star 高 ≠ 端侧 iOS 适用。blueprint-teardown star>1000 不降级规则针对'工程形态吸收',不等于'载体适用'。
  - 缓解: 按 star+新鲜度选 repo,但适用性以'iOS on-device + mlx-swift 栈'硬筛。Rapid-MLX 只借 tool-parser 设计(drop 载体);Unsloth 借训练加速(adapt,端侧走 mlx)。

### adopt 候选
- [adopt] **rudrankriyam/MLX-Outil — 端侧 Qwen3-1.7B tool-call runtime 参考(LLMManager.swift + ToolDefinitions.swift)** — 与 MAformac 完全同栈(Qwen3-1.7B-4bit + MLX Swift + iOS + tool calling)的近 drop-in 蓝本。LLMManager.swift 直接示范:UserInput(chat:tools:) + 原生 generation.toolCall 流式解析 + 单跳 tool exec 后 includingTools:false 再生成(与 home-llm 单发旋钮同源,防多跳爆炸)+ temperature 0.6/maxTokens 4097 采样。ToolDefinitions.swift 的类型化 Tool<Input,Output> + .required/.optional 参数 + action-enum 形态,正好映射 MAformac C1 契约的 device×动作原语×槽三元。adopt 措施:照搬 LLMManager 单跳 loop 骨架,把 8 个真实系统工具(WeatherKit/HealthKit)替换为 mock 车控工具;ToolDefinitions 从 semantic-function-contract codegen 生成。 (https://github.com/rudrankriyam/MLX-Outil 124★ / pushed 2026-05-23(28天前,活跃))
- [adopt] **ml-explore/mlx-swift-lm 3.x — 官方端侧 runtime 骨架(已是 spike-e3 基座)** — MAformac CLAUDE.md 已锁主推,本就是端侧 LLM 唯一官方 Swift 栈。原生 Qwen3 tool-call 解析(generation.toolCall)= 不用手搓 JSON 解析。注意 3.x 有 breaking changes(解耦 tokenizer/downloader),需核对 spike-e3 锁的 3.31.3 是否跟进。 (https://github.com/ml-explore/mlx-swift-lm 678★ / pushed 2026-06-19(当天,Apple 官方,极活跃))
- [adapt] **Goekdeniz-Guelmez/mlx-lm-lora — Mac 原生 LoRA+QAT 训练栈** — MAformac C5 现锁 unsloth+Hammer+xLAM(CUDA/Colab 路线),但本机训练机=Mac M5/32GB + mlx-lm 0.31.1 已装。mlx-lm-lora 让训练全程留在 Mac 本地(无需 CUDA),且 QAT(量化感知训练)对 8GB iPhone 4bit 端侧精度更友好。adapt(非 adopt):作为 C5 的 Mac 本地训练备选/补充评估,QAT 路径值得对比 unsloth ExecuTorch QAT;但 function-masking 数据配方仍走 Hammer/xLAM。 (https://github.com/Goekdeniz-Guelmez/mlx-lm-lora 380★ / pushed 2026-06-16(4天前,活跃))
- [adapt] **huggingface/AnyLanguageModel — drop-in FoundationModels + tool calling 抽象蓝本** — MAformac 已自有 LLMBackend/ASRBackend 协议抽象,不必直接引入。但 AnyLanguageModel 的'统一 FM 调用点 + 多 provider tool calling(MLX/CoreML 后端可换)'形态,正是 MAformac LLMBackend 协议想要的工程参考。adapt=借设计形态(尤其逃生口切 Apple 原生 FM 的 baseline 路径),不引依赖。 (https://github.com/huggingface/AnyLanguageModel 894★ / pushed 2026-06-20(当天,HF 官方))
- [adapt] **unslothai/unsloth + ExecuTorch .pte phone-deployment** — 训练加速 + ExecuTorch QAT(qat_scheme='phone-deployment')是成熟的'训→端侧'链路,但走 ExecuTorch .pte/etLLM app 栈,与 MAformac 现锁 mlx-swift 栈不同 = fallback 不是主线。已知坑:Qwen3.x GGUF 导出误判 VLM 架构出空文件夹(issue #4534/#3899)。adapt=保留为 LLMBackend 第二实现(.pte 路线)的可行性证据 + QAT 数据点,主线仍 mlx-swift。 (https://unsloth.ai/docs/basics/inference-and-deployment/deploy-llms-phone 66945★ / pushed 2026-06-20(当天,训练侧主导))
- [drop] **raullenchai/Rapid-MLX — Mac server(非 iOS)** — 是 Apple Silicon Mac 桌面 OpenAI 兼容 server(给 Claude Code/Cursor),不是 iOS on-device 包,对 MAformac 端侧部署不直接适用。唯一可借=17 个 tool parser 的鲁棒解析设计(对应 home-llm 三层防御解析),但不引入。 (https://github.com/raullenchai/Rapid-MLX 3004★ / pushed 2026-06-20(高人气高活跃,但 Mac-only 不适用))
- [drop] **ibrahimcetin/MLXSampleApp — 端侧 LLM iOS 模板** — 新鲜度淘汰:pushed 2025-03-05(15+ 月没动,41★)。功能已被 MLX-Outil(同栈 + tool calling + 更新)完全覆盖。按 github-first 近 2 月活跃硬约束,直接淘汰。 (https://github.com/ibrahimcetin/MLXSampleApp 41★ / pushed 2025-03-05(已淘汰))

### grill 议题
- 训练引擎:守 C5 现锁的 unsloth+Hammer+xLAM(CUDA/Colab,数据配方成熟),还是切 mlx-lm-lora(Mac M5 本地 + QAT 端侧精度友好,但要自己实现 function-masking)?⭐建议守现锁配方,mlx-lm-lora 仅作 QAT 端侧精度对比 spike,不替换数据流(HIGH,见 tiger3)
- 端侧运行时:MLX-Outil 的单跳 tool-call loop 骨架直接 adopt 到 C3(替换工具为 mock 车控 + tool 结果走 DemoGuard 确定性 renderReadback,砍 LLM 续生成),还是另起?⭐建议 adopt MLX-Outil 骨架(同栈近 drop-in,省手搓)
- 端侧部署栈:守 mlx-swift 单主线(.safetensors→mlx 量化,绕开 Qwen3.x GGUF/VLM 导出坑),还是引 ExecuTorch .pte 双栈?⭐建议守 mlx-swift 单主线,.pte 留 LLMBackend 未来 fallback 不实装
- LLMBackend 协议:借 AnyLanguageModel/PrivateFoundationModels 的 drop-in FoundationModels 形态(逃生口切 Apple 原生 FM),还是保持 MAformac 现有自定义协议?⭐建议借设计形态(尤其 FM baseline 逃生口),不引依赖


---

## iPhone 15 Pro Max 8GB RAM 端侧实测可行性 + 经典 issue(本地适配死磕) — 给 1.7B/2B/3B/4B 各尺寸 RAM 预算明细 + 上限判定 + MLX-swift 特有崩溃模式,作为选型的端侧硬天花板

- **联网搜索次数**: 15
- **一句话结论**: 8GB iPhone 15 Pro Max 在 MLX-swift 下 dense 模型硬天花板 = ~2B(1.7B/2B 安全,3B tight/risky,4B 在 MLX 下连 12GB 都因 jetsam 炸);换型只有 LFM2.5-1.2B 值得认真评估(更新更省 RAM 更快不热降,项目自家 tool-calling-benchmark 0.920 仅次 1.7B 的 0.960),但须先实测中文车控泛化 + 全集拒识 + mlx-swift 新版加载,中文 base 弱是一票否决风险,否则诚实守 Qwen3-1.7B。
- **本机 scout**: 本机 = Mac M5 / 32GB(训练机,非部署目标)。HF 缓存已有 mlx-community/Qwen3-1.7B-4bit + Qwen3.5-2B-4bit + Qwen3.6-35B-A3B(训练用),未缓存任何 LFM2/LFM2.5。ref-repos 已 clone tool-calling-benchmark(项目信任的 FC 基准,last commit 2026-04-01)+ home-llm + mastra + pi 等。tool-calling-benchmark/runs/default/ 已含 lfm2_5_1_2b.json 实测结果。注:无法在 Mac 上直接实测 iPhone 8GB jetsam(目标机非本机),所有 iPhone RAM 数据来自联网实测来源(john-rocky benchmark / Ricky Takkar russet / Apple 开发者论坛)。
- **clone 深扒**: ~/workspace/raw/05-Projects/MAformac/ref-repos/tool-calling-benchmark (已存在,last commit 2026-04-01,本路据其 README + runs/default/lfm2_5_1_2b.json 取 Qwen3-1.7B 0.960 / LFM2.5-1.2B 0.920 实测对照)

### 候选
- **守 Qwen3-1.7B(基线,4bit)** (size=1.7B dense transformer, 4bit ~1.0-1.3GB on-disk, release_date=2025-05(发布日期老,但端侧/FC 综合最稳), architecture=标准 transformer(GQA), vs_1_7b=better)
  - fc_benchmark: 0.960 Agent Score(项目信任的 MikeVeerman tool-calling-benchmark,本机 clone README:Action 0.900 + Restraint 1.000 + 0 错调,唯一 20 跑稳定过全部 restraint 难题 P5/P9/P12 的小模型)
  - chinese: 强(Qwen 系中文母语级,车控泛化最稳);项目内部 P1-B spike 9/11 + 外部 tool-calling-benchmark 0.960 champion
  - mlx_support: ✅ 原生 mlx-community 4bit 已存在且本机已缓存;mlx-swift-lm LLMModelFactory 内置 qwen3,spike-e3 已实跑
  - iphone15pm_8gb_feasible: ✅ 最安全。4bit ~1.0-1.3GB weights + KV cache + load spike → 峰值 ~1.5-2.5GB,远低于 8GB jetsam ~4-5GB 上限。对照:2B 类 MLX 实测峰值仅 1.28GB(john-rocky),1.7B 更低。20-30 tok/s burst(A17 Pro),持续 2-3min 后热降 20-40%,但单跳 FC 短输出不触发持续热降。demo 不崩首选
  - freshness_heat: release 2025-05(磊哥嫌老);mlx-community/Qwen3-1.7B-4bit 本机已缓存,HF 高下载;mlx-swift registry 原生支持,spike-e3 已集成。活跃(Qwen 生态持续维护)
  - vs_1_7b_evidence: 它就是基线本身。端侧最安全 + FC/中文/拒识综合最强。唯一弱点是发布日期老
  - source_url: https://github.com/MikeVeerman/tool-calling-benchmark
- **LFM2.5-1.2B-Instruct(⭐换型首选候选)** (size=1.2B hybrid state-space(非 transformer), 4bit <1GB(官称 fits 900MB), release_date=2026-01-05(LFM2.5 家族),cutoff 邻近,真'新', architecture=hybrid(gated short-conv + 少量 GQA,非 transformer 非纯 Mamba)— 唯一非 transformer 进 top tier, vs_1_7b=mixed)
  - fc_benchmark: 0.920 Agent Score(同一 tool-calling-benchmark,本机 clone:Action 0.800 + Restraint 1.000 + 0 错调,排名第 2,仅次 Qwen3-1.7B 0.040;avg 1567ms 比 Qwen 快 ~7x)。Liquid 官称 LFM2-1.2B IFEval 74.89% > Qwen3-1.7B 73.98%。⚠️ Restraint=1.000 是该 11-prompt 基准的,非项目全集拒识实测,换型前须自跑
  - chinese: ⚠️ 风险点:中文仅'base support'(预训 ~20% 多语,优先级 = JP/AR/KR/ES/FR/DE,中文明确未进优先级)。基础中文弱于 Qwen,需靠 LoRA 大力补偿。车控中文 demo 须实测中文泛化
  - mlx_support: ✅ 但需验证版本:mlx-community/LFM2.5-1.2B-Thinking-4bit + lmstudio-community/LFM2.5-1.2B-Instruct-MLX-4bit/8bit 已存在;mlx-swift-lm LLMModelFactory 有 'lfm2'+'lfm2_moe' registry key,LFM2.swift 已实现 depthwise Conv1d short-conv。⚠️ 但 LFM2.5 nested rope params 需 PR #122 修复,必须用含 LFM2 fix 的近期 mlx-swift-lm 版本,否则 conv/rope 加载炸
  - iphone15pm_8gb_feasible: ✅✅ 端侧最优解。<1GB RAM(官称 900MB,john-rocky 实测 sub-1GB 类最省),8GB 余量极大;state-space 架构 KV 增长更省。iPhone 17 Pro 实测 60 tok/s(比同尺寸 transformer 快),热行为反常(LFM2.5 越跑越快:55→63 TPS 到第 4-5 跑,不热降)。这是 8GB 上跑得最爽的候选
  - freshness_heat: release 2026-01(比 Qwen3-1.7B 新 8 个月);HF 活跃(LFM2.5-1.2B-JP 月下载 1124+,主 Instruct 更高);Liquid AI 持续迭代(5 月又出 LFM2.5-8B-A1B MoE);day-1 MLX 支持。热度+新鲜度双过
  - vs_1_7b_evidence: 端侧(更省 RAM/更快/不热降)+ 新鲜度 + FC 速度比 1.7B 强;但 FC 准确度略低 0.040、中文 base support 弱(车控中文最大风险)、拒识全集未实测、mlx-swift 需特定版本。换型须先实测中文车控泛化 + 全集拒识,过了才换
  - source_url: https://huggingface.co/LiquidAI/LFM2.5-1.2B-Instruct
- **Qwen3.5-2B(磊哥已否,留作端侧对照)** (size=2B GDN+VL 新架构, 4bit ~1.28GB(john-rocky MLX 实测峰值 1279MB), release_date=2026 上半年(比 1.7B 新), architecture=GDN(Gated Delta Network 线性注意力)+ VL 多模,新但 FC 不成熟, vs_1_7b=worse)
  - fc_benchmark: 内部 P1-B spike 8/11 < Qwen3-1.7B 9/11(chat_template 空,FC 弱);外部基准无单独 2B 条目
  - chinese: 强(Qwen 中文母语),但 P1-B spike 内部实测 8/11 < 1.7B 的 9/11;chat_template 空,FC 劣
  - mlx_support: ✅ mlx-community 4bit 本机已缓存;john-rocky 实测 iPhone 17 Pro MLX 61 tok/s 可跑
  - iphone15pm_8gb_feasible: ✅ 端侧可跑(MLX 实测峰值 1279MB,8GB 充裕,61 tok/s),但 FC 质量已被项目实测否决,端侧能跑不代表该选
  - freshness_heat: release 新;mlx-community/Qwen3.5-2B-4bit 本机已缓存;但项目已实测劣于 1.7B,新≠强的反面教材
  - vs_1_7b_evidence: 端侧 RAM/速度与 1.7B 同级可跑,但 FC 实测 8/11<9/11、chat_template 空。'新但更差'的实证,印证选型不能只看发布日期
  - source_url: https://github.com/john-rocky/apple-silicon-llm-bench
- **Qwen3 4B / Llama 3.2 3B(端侧天花板上界,选型须排除)** (size=3B/4B dense, 4bit ~2-3GB on-disk, release_date=2025, architecture=标准 transformer, vs_1_7b=worse)
  - fc_benchmark: tool-calling-benchmark:Qwen3-4B 因延迟过高(CPU 63s/prompt)Round3 移除;端侧不可行
  - chinese: Qwen3-4B 中文强,但端侧不可行 = moot
  - mlx_support: mlx-community 4bit 存在,但 iPhone 端 MLX-swift 加载即炸
  - iphone15pm_8gb_feasible: ❌ 高 OOM 风险,demo 不可用。这是本路最硬结论:8GB 端侧 dense 模型天花板 = ~2B,3B 已 tight/risky,4B 在 MLX-swift 下连 12GB 都炸。决定性证据:Ricky Takkar russet MLX 实测,即便 12GB iPhone 17 Pro,Qwen3 4B + Llama 3.2 3B 都因 jetsam(~50% RAM = ~6GB)上限无法加载被排除。8GB 15PM 更紧(jetsam ~4-5GB),4bit weights ~2.5-3GB + KV + load spike(INT4→INT8/FP16 上转)+ app 内存 → 必破上限。MLX wire 住 Metal 内存 jetsam 无法回收 → 不报内存压力直接崩。'5 分钟不崩'红线下绝不选 ≥3B
  - freshness_heat: —(端侧排除,不评热度)
  - vs_1_7b_evidence: 端侧不可行直接出局,无论 FC/中文多强。定义了 8GB 选型的硬天花板:MLX-swift 路线下 dense ≤2B
  - source_url: https://rickytakkar.com/blog_russet_mlx_benchmark.html

### tigers (坑点)
- [HIGH] MLX wire 住 Metal 内存,jetsam 无法回收 → 超限不报内存压力警告、直接静默崩溃(no graceful degradation)。这是 MAformac 用的 mlx-swift 运行时特有死法,比 CoreML 危险
  - 证据: 实证:'Metal GPU wires the memory (locks it in RAM), so the Jetsam OOM killer cannot reclaim it. The system does not even detect memory pressure — it just crashes.' + KV cache 随对话无界增长复合峰值。对'5 分钟不崩'红线是直接威胁。来源 medium MLX memory management + 多 reddit/forum 报告
  - 缓解: ①守 ≤2B dense(1.7B/LFM2.5-1.2B),留足 jetsam 余量;②MLX.GPU.set(cacheLimit:) 小值(官方 LLMEval 用 20MB)+ memoryLimit 须 > 模型大小否则推理 stall;③启用 com.apple.developer.kernel.increased-memory-limit entitlement(但 distribution build 不保证生效,不能依赖);④cap context length / 量化 KV cache 到 4bit 控 KV 峰值;⑤os_proc_available_memory() 加载前 gate,优雅失败不硬撞;⑥单跳 FC 短输出本就低 KV,天然友好
- [HIGH] ≥3B 模型在 8GB iPhone MLX-swift 下高 OOM:4bit weights + KV + load spike(INT4 可能内部上转 INT8/FP16 致加载尖峰)+ app 内存 → 破 jetsam ~4-5GB 上限
  - 证据: 决定性:Ricky Takkar russet 实测即便 12GB iPhone 17 Pro,Qwen3 4B + Llama 3.2 3B 都因 jetsam(~50% = ~6GB)无法加载被排除。8GB 15PM jetsam 仅 ~4-5GB,更紧。MLX 内存随 params 近线性增长(john-rocky:2B=1.28GB,Gemma E2B=2.9GB),非 CoreML 的 flat 215MB
  - 缓解: 选型直接锁 dense ≤2B(1.7B/2B/LFM2.5-1.2B)。若未来非要 3B+,唯一出路是 CoreML/ANE chunked 路径(峰值 flat ~215MB@2B,但 tok-s 减半且 MAformac 已锁 mlx-swift),不在当前选型范围。demo 不碰 ≥3B
- [MEDIUM] LFM2.5-1.2B 中文 base support 弱(预训中文非优先级)→ 车控中文 demo 泛化/拒识可能不如 Qwen,换型后客户现场中文听不懂
  - 证据: Liquid 技术报告:预训 ~75% 英文/20% 多语/5% code,多语优先级 = JP/AR/KR/ES/FR/DE,中文仅'additional base support'。MAformac 是纯中文车控,base 中文是真实业务风险。LoRA 可补但不确定补到 Qwen 水平
  - 缓解: 换型 LFM2.5 前必跑:①中文车控全集泛化实测(对照 Qwen3-1.7B);②LoRA 后中文恢复度(LFM2 架构'吸收新模式快不灾难遗忘',利好补偿);③若 LoRA 后中文仍弱于 Qwen → 守 1.7B。中文是换型的一票否决项,FC 快 7x 救不了听不懂中文
- [MEDIUM] LFM2.5 在 mlx-swift 上需特定版本(nested rope params 需 PR #122,LFM2 conv/rope 多次修复)→ 用旧 mlx-swift-lm 加载即炸,'有 registry key' ≠ 'LFM2.5 变体能跑'
  - 证据: mlx-swift-lm LLMModelFactory 有 'lfm2'/'lfm2_moe' key + LFM2.swift,但修复史长:examples PR #354/#369/#406/#409 + mlx-swift-lm PR #122(LFM2 nested rope)。LFM2.5 是新变体,老版本 conv/rope handling 有 bug
  - 缓解: 换型前 spike:用含 LFM2 fix 的最近 mlx-swift-lm + mlx-community/lmstudio LFM2.5-1.2B-Instruct-MLX-4bit 在真 iPhone 15PM 跑 smoke test(加载成功 + FC 输出 + 中文)。不能只看 registry 有 key 就拍。Qwen3 已 spike-e3 实跑验证,LFM2.5 是新风险面
- [LOW] 持续推理热降:A17 Pro MLX 走 GPU/Metal(非 ANE,功耗高),2-3min 持续后降到 60-70% 峰值,聊天到第 5-6 轮 throughput 掉 20-30%。客户现场连续演示可能越演越慢
  - 证据: A18 Pro 实测 2-3min 持续推理热降到 60-70%;MLX GPU 路径 ~24.7W vs ANE ~12.7W 功耗差是热降根因。但 15 Pro Max 比 15 Pro 散热好,小模型持续更久;且单跳车控 FC = 短输出短会话,非长 chat,触发持续热降的概率低
  - 缓解: ①单跳 FC 短输出天然低热负载;②演示间隔让设备回温;③选 LFM2.5(实测越跑越快不热降,55→63 TPS)规避;④若必须连续 demo 多条,1.7B 比 4B 热预算友好得多(又一个守小模型理由)

### adopt 候选
- [adapt] **LFM2.5-1.2B-Instruct (LiquidAI)** — 唯一真正'新+端侧更优'的换型候选:2026-01 发布(比 1.7B 新),hybrid state-space <1GB RAM(8GB 跑得最爽,iPhone 60 tok/s 不热降),mlx-swift registry 已支持。项目自家 tool-calling-benchmark 实测 0.920(仅次 1.7B 0.960,FC 快 7x,Restraint 1.000)。adapt 非 adopt:换型前须自测中文车控泛化(中文仅 base support,最大风险)+ 全集拒识 + 含 LFM2 fix 的 mlx-swift 新版真机加载 (https://huggingface.co/LiquidAI/LFM2.5-1.2B-Instruct release 2026-01-05(cutoff 邻近);HF 活跃(月下载 1k+);Liquid 持续迭代(5 月出 8B-A1B);day-1 MLX 支持。新鲜度强过 Qwen3-1.7B(2025-05))
- [adopt] **Qwen3-1.7B-4bit (守基线)** — 端侧最安全(峰值 ~1.5-2.5GB << 8GB jetsam 上限,本机已缓存,spike-e3 已实跑)+ FC/中文/拒识综合最强(0.960 champion,中文母语)。唯一缺点是发布日期老。若 LFM2.5 实测中文不过关 → 诚实守它,日期老不是崩场理由 (https://github.com/MikeVeerman/tool-calling-benchmark release 2025-05(磊哥嫌老);但 mlx 生态持续维护、本机缓存、spike 已验证,工程成熟度最高)
- [drop] **Qwen3 4B / Llama 3.2 3B (端侧排除)** — 8GB 端侧 MLX-swift 下高 OOM,违反'5 分钟不崩'红线。决定性证据:即便 12GB iPhone 17 Pro,二者都因 jetsam(~50% RAM)无法加载被排除;8GB 15PM jetsam 更紧(~4-5GB)。无论 FC/中文多强,端侧不可行直接出局。定义了选型硬天花板:dense ≤2B (https://rickytakkar.com/blog_russet_mlx_benchmark.html 端侧不可行,不评热度)
- [drop] **LFM2.5-8B-A1B MoE (May 2026, 端侧排除)** — 虽是更新的 MoE(8.3B total / 1.5B active),但 MoE 不省 RAM(所有 expert 必须常驻 RAM,router 需访问全部),8.3B 总参 4bit ~5GB+ → 破 8GB jetsam 上限。MoE 只省 compute 不省 memory,端侧 8GB 不可行 (https://www.liquid.ai/blog/lfm2-5-8b-a1b release 2026-05(很新),但端侧 8GB 排除)

### grill 议题
- 换型 LFM2.5-1.2B 前,中文车控全集泛化是否实测过对照 Qwen3-1.7B?(中文仅 base support,这是一票否决项,FC 快 7x 救不了客户现场听不懂中文)
- LFM2.5 的 Restraint 1.000 是 11-prompt 通用基准的,MAformac 全集车控拒识(关键词陷阱/越界/模糊)实测过吗?项目'唯一可靠过拒识'的判定是给 Qwen3-1.7B 的,LFM2.5 未在项目全集验证
- mlx-swift-lm 当前集成版本是否含 LFM2 nested rope fix(PR #122)?LFM2.5 是新变体,'registry 有 lfm2 key' ≠ 'LFM2.5 能加载',须真机 spike(Qwen3 走过 spike-e3,LFM2.5 没有)
- '5 分钟不崩'红线下,是否接受 3B(tight/risky)?本路结论是 8GB MLX-swift dense 天花板 = 2B,建议选型直接锁 ≤2B,3B 不进候选
- 若守 Qwen3-1.7B,'发布日期老'是真实问题还是心理问题?端侧/FC/中文/拒识/工程成熟度全维度 1.7B 仍最优,日期老不影响 demo 不崩 + 听懂 + 惊艳


---

## Qwen 系列比 1.7B 新且 iPhone15PM-8GB 能跑的小 dense(直接回应磊哥"想要新 Qwen")

- **联网搜索次数**: 16
- **一句话结论**: Qwen 家族里唯一满足『比 1.7B 新 + 标准 dense(非 GDN/VL)+ ≤4B 端侧 + FC 不弱 + mlx 活跃』的真候选是 Qwen3-4B-Instruct-2507(2025-08, 通用 FC/multi-turn 实测更强、mlx-community 4bit 比 1.7B 还流行), 但它在磊哥引用的那个 restraint benchmark 上无可靠分(1.7B 才是 20-run 全场冠军 0.960)且 iPhone 8GB 跑 4B-4bit 是边界风险非甜区; Qwen3.5/3.6 小线(GDN+VL)新但实测更差(chat_template tool-call 系统损坏 + 内部 spike 2B 8/11<1.7B 9/11)应 drop, Qwen3.6 根本无 ≤4B dense —— 结论: 守 1.7B 为安全默认 ⭐, 仅当 P1-B spike 实测 4B-2507 在 C6 restraint bench 也 ≥1.7B 且 iPhone RAM 过关时才升级到 4B。
- **本机 scout**: 本机 HF cache (~/.cache/huggingface/hub) 已缓存的 Qwen 文本模型: mlx-community/Qwen3-1.7B-4bit (现 base)、mlx-community/Qwen3.5-2B-4bit、mlx-community/Qwen3.6-35B-A3B-4bit/8bit。核 config.json 实证: (1) Qwen3-1.7B = 标准 transformer (architectures=Qwen3ForCausalLM, model_type=qwen3, 28 层全 full-attention, tie_word_embeddings, ctx 40960, 无 image_token)。 (2) Qwen3.5-2B = GDN+VL (architectures=Qwen3_5ForConditionalGeneration, model_type=qwen3_5, 有 image_token_id=248056 即多模态, layer_types 24 层 = 18 linear_attention + 6 full_attention 周期插入 = Gated DeltaNet 混合, attn_output_gate=true, head_dim=256, ctx 262144) —— 这一手 config 直接坐实「2B 是新架构 GDN+VL,与 1.7B 标准 transformer 不同」的内部 P1-B spike 结论。硬件: Mac17,2 / 32GB (这是 M5 训练机 over-provisioned,非 iPhone)。benchmark 一手源已 clone: ~/workspace/raw/05-Projects/MAformac/ref-repos/tool-calling-benchmark (depth-1, README.md 含 Round1-3 全结果,逐行读过)。

### 候选
- **Qwen3-4B-Instruct-2507** (size=4B (≤4B 天花板内, D38 不违反), release_date=2025-08-06 (比 1.7B 的 2025-04/05 新 ~3-4 个月; 是 Qwen3 系列里唯一拿到 2507 point release 的小尺寸 —— 1.7B 没有 2507 版,实证 unsloth/Qwen 官方 changelog 2507 只覆盖 4B/30B/235B), architecture=标准 dense transformer (Qwen3ForCausalLM, model_type=qwen3, 非 GDN 非 VL), vs_1_7b=mixed)
  - fc_benchmark: BFCLv3: 原 Qwen3-4B 总体 62.04%(Live 75.52/Non-Live 82.58/Multi-Turn 35.25), 2507 应更高; 4B-Thinking-2507 官方报 BFCL-v3 工具使用 71.2%; distil labs 12 小模型 FC/agent 综合排第 1; e-commerce 任务 82.26 第 1。restraint 专项(MikeVeerman): 无可靠 20-run 分(被延迟剔除)。来源: edge BFCL 论文 + distillabs.ai + Qwen 官方 4B-Thinking model card
  - chinese: Qwen3-4B 指令版 2507 更新
  - mlx_support: 存在且活跃。mlx-community/Qwen3-4B-Instruct-2507-4bit(26439 下载/月, 10 likes, lastModified 2026-01-02, created 2025-08-06) —— 下载量比现 base mlx-community/Qwen3-1.7B-4bit(14849/月)还高; 另有 mlx-community/Qwen3-4B-Instruct-2507-4bit-DWQ-2510(更优 DWQ 量化, 845 下载)+ lmstudio-community/Qwen3-4B-Instruct-2507-MLX-4bit(2.28GB)。上游 Qwen/Qwen3-4B-Instruct-2507 = 5.5M 下载/月 + 881 likes(极活跃)。mlx-swift-lm 可直接跑(标准 Qwen3 架构, spike-e3 已集成 mlx-swift-lm 3.31.3 同款)。
  - iphone15pm_8gb_feasible: 边界可行但有真实 OOM 风险(不是营销说的『舒适甜区』)。权重 ~2.5GB(Q4); 但峰值 RAM = 权重 + 加载期 int4→int8/fp16 反量化尖峰 + KV cache,实测参照: mlx-swift 上 Qwen3.5-**2B** 4bit 在 iPhone 17 Pro 峰值已 2900MB / 61 tok-s(john-rocky/apple-silicon-llm-bench 一手); 4B 权重近 2B 两倍,峰值会冲到 ~4-5GB+。iPhone 15PM 8GB 物理 RAM, 但 jetsam 是 per-process 上限非全 8GB: iPhone 13(4GB)即便带 increased-memory-limit entitlement 也只 ~2.3GB 可用; 8GB 机带 entitlement 大致 ~5GB 量级(需端上 os_proc_available_memory() 实测, Apple 不公开)。1.7B 甚至在 iPhone SE3(更小)上有人加载失败(jetsam ~2GB hard limit, int4 加载尖峰)。结论: 4B-4bit 必须带 increased-memory-limit entitlement + 强制 bounded KV cache(windowSize, 别用 unbounded)+ 实测加载尖峰,否则 jetsam 风险真实。tok-s 预期 ~15-25(比 1.7B 慢, GPU 路径可能热降频)。
  - freshness_heat: release 2025-08-06; HF 上游 5.5M 下载/月 + 881 likes; mlx 4bit 26K 下载/月; 独立 benchmark(distil labs/e-commerce 2026) 持续作 SOTA 小模型基底被引用; Qwen3 GitHub 仍活跃维护。判定: 非常活跃, 远超 60 天淘汰线。
  - classic_issues: (1) thinking 变体 63s/prompt 延迟(Instruct 版规避)。(2) iOS jetsam OOM(见可行性, 需 entitlement + bounded KV)。(3) MCP-Bench 实测复现常远低于官方分(同族 30B-2507 工具成功率仅 11.18%, 工程 harness/parser 影响巨大) —— 端侧自训 LoRA + 受限解码可缓解。(4) 加载期 int4 反量化尖峰在低 RAM 机致 jetsam(SE3 上 1.7B 都失败过的同根因)。
  - vs_1_7b_evidence: FC 总体更强但在磊哥引用的那个 restraint benchmark 上无可靠分。证据A(更强): 独立 distil labs 12 小模型 benchmark Qwen3-4B-Instruct-2507 排第 1(还压过 Qwen3-8B); e-commerce τ-bench 对齐任务最高分 82.26; edge-device BFCLv3 研究中原 Qwen3-4B 总体 62.04% > 1.7B 55.49%,multi-turn 35.25% vs 16.88%(几乎翻倍)。证据B(同尺寸 restraint 未证实): MikeVeerman tool-calling-benchmark(磊哥引用的那个) Round3 20-run 里 **qwen3:1.7b 是全场冠军 0.960(Action 0.900+完美 restraint+0 错调,唯一解出全部 3 道 hard prompt)**; qwen3:4b 只有 Round2 噪声 3-run 0.880 且 **因 thinking 模式 63s/prompt 延迟在 Round3 被剔除没重测** —— 即 4B 在这个 restraint 题集上没有可靠 20-run 分。关键: 4B 的延迟杀手是 thinking 模式,而 2507-**Instruct** 是纯 non-thinking(不生成 think 块, enable_thinking=False 已成默认),理论上躲掉那个 63s 惩罚,但 2507-Instruct 本身从未在这个 restraint 集上跑过(unproven)。中文: 2507 系 multilingual/MultiIF 77.3%(thinking 变体), 同源大尺寸 30B-2507 CMMLU 86.36/C-Eval 88.17, 4B 具体中文分官方未公开列。
  - source_url: https://huggingface.co/Qwen/Qwen3-4B-Instruct-2507 + https://huggingface.co/mlx-community/Qwen3-4B-Instruct-2507-4bit + https://www.distillabs.ai/blog/we-benchmarked-12-small-language-models-across-8-tasks + https://mikeveerman.be/blog/github-2026-02-06-tool-calling-benchmark/
- **Qwen3.5-2B (及 0.8B/4B/9B 全小 dense 线)** (size=0.8B/2B/4B/9B (dense); 2B 已本机缓存, release_date=2026-02~03 (比 1.7B 新约 10 个月, 是『最新一代小 dense』), architecture=GDN (Gated DeltaNet 混合线性注意力) + 原生多模态 VL (Qwen3_5ForConditionalGeneration) —— 非标准 transformer, 不符合『标准架构』偏好, vs_1_7b=worse)
  - fc_benchmark: 未证实 / 实测劣。无可靠 FC benchmark 分; chat_template/parser 损坏使开箱 FC 不可靠(需 --tool-call-parser qwen3_xml + 打补丁模板)。内部 spike 8/11 < 1.7B 9/11。
  - chinese: Qwen3.5-2B 小 dense(GDN+多模态)
  - mlx_support: 存在: mlx-community/Qwen3.5-2B-4bit(本机已缓存) + Qwen3.5-4B-MLX-4bit / 9B-MLX-4bit。但 mlx-swift 跑 GDN 架构的成熟度未验证(GDN 需较新推理框架原生 kernel; vLLM 0.17+ 才加; mlx-swift 端是否完整支持 GDN+VL 存疑)。
  - iphone15pm_8gb_feasible: 2B-4bit 可行(iPhone 17 Pro 实测 2900MB 峰值/61 tok-s, john-rocky bench); 15PM 8GB 应能跑 2B。4B-3.5 同 4B-2507 边界风险。但即便能跑, FC 损坏 + 多模态冗余权重(VL 部分对纯文本车控无用却占内存)使它对本项目无意义。
  - freshness_heat: release 2026-02/03(最新一代); 但 FC 损坏的 issue 一直开着, ollama/vLLM/llama.cpp 都在修。新鲜度高但成熟度低。
  - classic_issues: (1) tool-calling chat_template/parser 损坏(Hermes-JSON vs 训练用的 XML 格式不匹配)—— 核心淘汰理由。(2) GDN 混合架构端侧推理框架支持不成熟。(3) 原生多模态 = 纯文本车控用不上的冗余权重。(4) 内部 spike 已实测劣于 1.7B。
  - vs_1_7b_evidence: 新但更差(完美印证磊哥『新≠强』担忧)。证据: (1) 内部 P1-B spike 实测 1.7B 9/11 > Qwen3.5-2B 8/11, 2B chat_template 空。(2) 一手 config 坐实 2B 是 GDN+VL 新架构(image_token + linear_attention 层),与 1.7B 标准 transformer 不同。(3) 联网坐实根因: Qwen3.5 全系 tool-calling chat_template 损坏 —— 注册的 parser 是 Hermes-JSON 但模型实际训的是 Qwen3-Coder XML 格式(<function=...>), 模板 arguments|items 崩溃, 需 21-fix 社区补丁; ollama #14493 / QwenLM/Qwen3 #1831 / Qwen3.6 #178 / HF discussions 全是 FC 损坏报告。这是 2B『FC 劣』的工程根因, 不只是分数低。(4) artificialanalysis 智能指数 2B=16 仅比 1.7B=13 高 3 点(通用智能), 但 FC/中文专项 + 端侧 chat_template 实战 反而劣。
  - source_url: https://huggingface.co/Qwen/Qwen3.5-0.8B + https://github.com/ollama/ollama/issues/14493 + https://github.com/QwenLM/Qwen3/issues/1831 + 本机 config.json (Qwen3.5-2B-4bit)
- **Qwen3.6 (≤4B dense) — 不存在** (size=无 ≤4B (最小 dense=27B), release_date=2026-04 (35B-A3B 04-16, 27B dense 04-22), architecture=Qwen3.6 仅有 27B dense + 35B-A3B MoE(均 >4B 天花板), 无 ≤4B 小 dense, vs_1_7b=unknown)
  - fc_benchmark: 不适用
  - chinese: Qwen3.6 小 dense — 经核实无 ≤4B 尺寸
  - mlx_support: 仅 35B-A3B 有 mlx-community 量化(本机已缓存 4bit/8bit), 但 35B 远超 iPhone 端侧能力
  - iphone15pm_8gb_feasible: 否 —— 无 ≤4B 尺寸; 27B/35B 在 iPhone 8GB 上不可能
  - freshness_heat: release 2026-04(最新), 但无适配尺寸
  - classic_issues: 无 ≤4B 尺寸(根本性出局); 35B-A3B 也有 chat_template tool-call drift issue(#178)与 3.5 同源
  - vs_1_7b_evidence: 不适用 —— Qwen3.6 报告/lineup 经多次联网核实只见 27B dense + 35B-A3B MoE, 没有 ≤4B 小 dense 候选, 直接出局(超 iPhone D38 天花板)。这条用于回答磊哥『Qwen3.6 有没有小 dense』的明确否定。
  - source_url: https://en.wikipedia.org/wiki/Qwen + https://github.com/QwenLM/Qwen3.6/issues/178

### tigers (坑点)
- [HIGH] iPhone 15PM 8GB 跑 4B-4bit 的 jetsam OOM 风险被营销源严重低估 —— 不是『舒适甜区』而是『边界可行需硬化』
  - 证据: Apple 开发者论坛一手: iPhone 13(4GB)带 increased-memory-limit entitlement 也只 ~2.3GB 可用; 有人在 iPhone SE3 上连 quantized Qwen 1.7B 都加载失败(jetsam ~2GB hard limit + int4 加载期反量化尖峰)。john-rocky/apple-silicon-llm-bench 一手: mlx-swift 上 2B-4bit 在 iPhone 17 Pro 峰值已 2900MB —— 4B 权重近 2B 两倍, 峰值 ~4-5GB+, 逼近 8GB 机的 jetsam per-process 上限。营销博客说『15 Pro 8GB 是 Qwen3-4B 甜区 20-30 tok/s』与 Apple 硬数据冲突。
  - 缓解: 若选 4B: (a) 必加 com.apple.developer.kernel.increased-memory-limit entitlement; (b) 强制 bounded KV cache(mlx-swift windowSize, 禁 unbounded, 否则 KV 随轮次涨爆 jetsam); (c) 端上 os_proc_available_memory() 实测可用 RAM + 加载尖峰; (d) 这正是 P1-B Qwen spike S2(iPhone TTFT/RAM)要测的, 4B 必须纳入 S2 实测, 别信营销分。守 1.7B 则此风险基本消失(~1.5-2GB 峰值, 安全)。
- [HIGH] 在磊哥引用的那个 restraint benchmark 上, 4B 没有可靠分, 而 1.7B 是实测冠军 —— 换 4B = 拿『FC 总体强』赌掉『restraint 已证冠军』
  - 证据: MikeVeerman tool-calling-benchmark(一手 clone 逐行读) Round3 20-run: qwen3:1.7b=0.960 全场第 1(Action 0.900+完美 restraint+0 错调, 唯一解全 3 道 hard prompt); qwen3:4b 只有 Round2 噪声 3-run 0.880, Round3 因 thinking 63s/prompt 延迟被剔除, 没有 20-run restraint 分。README 明示『parameter count 是弱预测器, Qwen3 家族非单调』。本项目北极星正是 restraint(拒识)+ 安全门, 1.7B 恰好是这个题集的实测最强。
  - 缓解: 不能凭『4B 通用 FC 更强』就断定 restraint 也更强 —— restraint 是另一个能力维度, 1.7B 在这维度已证冠军。决策应: P1-B spike 里把 Qwen3-4B-Instruct-2507(non-thinking)在本项目 C6 vehicle-tool-bench(含 trap/拒识样本)上与 1.7B 同 harness 对跑, 用实测分判, 不用通用 benchmark 外推。这与 roadmap C6 base 1.7B hard_fail 0.789(无 LoRA)是同一诚实锚点逻辑。
- [HIGH] 整个 Qwen3.5/3.6 新线(GDN+VL)tool-calling chat_template 系统性损坏 —— 任何『追新到 3.5/3.6』的冲动都会撞这堵墙
  - 证据: 联网坐实: Qwen3.5 注册 parser 是 Hermes-JSON 但模型实训 Qwen3-Coder XML 格式(<function=name><parameter=...>), chat_template arguments|items Jinja 崩溃, 需社区 21-fix 补丁; ollama #14493(『tool calling completely non-functional』)/ QwenLM/Qwen3 #1831 / Qwen3.6-27B #178(format drift 吐 stray close tag)/ HF Qwen3.5-35B-A3B discussion#4(『chat template is broken』) 全是 FC 损坏。内部 P1-B spike 已实测 2B『chat_template 空』8/11 < 1.7B 9/11。这是『新≠强』的工程实锤。
  - 缓解: Qwen3.5/3.6 线对本项目(端侧 FC 车控)直接淘汰: GDN+VL 架构端侧不成熟 + FC 模板损坏 + 多模态冗余权重。若未来非要用必须 --tool-call-parser qwen3_xml + 打补丁模板 + 重训 chat_template, ROI 极低。结论锁定在标准 transformer 线(1.7B 或 4B-2507-Instruct)。
- [MEDIUM] Qwen 全系无 1.7B 的 2507/更新 point release —— 想要『同尺寸更新版 1.7B』这条路根本不存在
  - 证据: 联网 + Qwen 官方 changelog 坐实: 2507 point release 只覆盖 4B/30B-A3B/235B-A22B, 1.7B 被跳过, 至今(2026-06)只有原始 Qwen3-1.7B(2025-04/05)。所以磊哥『想要新一点的 1.7B 同款』在 Qwen 家族无解 —— 要么守原 1.7B, 要么跳到更大的 4B-2507 或换架构的 3.5-2B。
  - 缓解: 明确告知磊哥: 『新 + 标准架构 + ≤4B Qwen』里唯一真候选是 Qwen3-4B-Instruct-2507(2025-08, 比 1.7B 新, 标准 dense, FC 通用更强), 但它更大更慢更吃 RAM, 且 restraint 未在本项目题集证强。这是一个『尺寸×新鲜度×端侧成本』三角权衡, 不是单纯『有没有更新的 1.7B』。
- [MEDIUM] 通用 FC benchmark 的高分在端侧实测常大幅缩水(parser/harness/量化敏感)
  - 证据: MCP-Bench 实测: Qwen3-30B-A3B-2507 工具成功率仅 11.18%(尽管工具名近乎完美), 远低于官方分; tool-calling-benchmark 自己也证 5 个模型需 fallback parser, format-blind 评分会高估/低估。GPQA 复现 issue#1462 也低于官方。即 4B-2507 的 distil labs #1 / 82.26 等分不能直接外推到本项目端侧 mlx-swift + 中文车控 + 4bit 量化场景。
  - 缓解: 一切候选最终判据 = 本项目 C6 vehicle-tool-bench 同 harness 实测(4bit + mlx-swift + 中文车控样本 + trap/拒识), 不信外部通用分。与项目既有纪律(C6 双轴覆盖率 bench + base 诚实锚点)一致。

### adopt 候选
- [adapt] **Qwen3-4B-Instruct-2507 (mlx-community/Qwen3-4B-Instruct-2507-4bit)** — Qwen 家族里唯一满足『比 1.7B 新(2025-08)+ 标准 dense transformer 非 GDN 非 VL + ≤4B 天花板内 + mlx-community 4bit 现成且比 1.7B 更流行 + 通用 FC/中文/multi-turn 实测更强』的候选。但 adapt 非 adopt: (1) 端侧 8GB 必须 spike 实测(jetsam 风险真实, 需 entitlement+bounded KV); (2) 在本项目 restraint 题集上未证强(1.7B 才是该集冠军); (3) 更大更慢吃 RAM。建议: 纳入 P1-B Qwen spike, 用 non-thinking Instruct 版在 C6 bench + iPhone S2 RAM 实测上与 1.7B 同 harness 对跑再定, 不靠通用分外推直接换。 ( release 2025-08-06; HF 上游 5.5M 下载/月+881 likes; mlx 4bit 26439 下载/月 lastModified 2026-01-02 —— 远超 60 天淘汰线, 非常活跃)
- [drop] **Qwen3.5-2B / 0.8B / 4B / 9B (GDN+VL 小 dense 线)** — 新但更差(完美印证『新≠强』): 一手 config 坐实 GDN+多模态非标准架构; tool-calling chat_template 系统性损坏(parser 格式不匹配, 需 21-fix 补丁, ollama #14493 等); 内部 P1-B spike 已实测 2B 8/11<1.7B 9/11 chat_template 空; 多模态权重对纯文本车控冗余; 端侧 GDN 推理框架不成熟。对本项目直接淘汰。 ( release 2026-02/03 最新一代, 但 FC 损坏 issue 持续未闭合, 成熟度低)
- [drop] **Qwen3.6 ≤4B dense** — 经多次联网核实不存在 —— Qwen3.6 只有 27B dense + 35B-A3B MoE, 无 ≤4B 小 dense, 全部超 iPhone D38 4B 天花板。回答磊哥『Qwen3.6 有没有小 dense』= 明确无。 ( release 2026-04 最新, 但无适配端侧的小尺寸)
- [adopt] **守 Qwen3-1.7B(现 base, 不换)** — 诚实推荐的安全默认 ⭐: (1) 磊哥引用的 tool-calling-benchmark Round3 20-run 实测全场冠军 0.960(Action+完美 restraint+0 错调, 唯一解全 3 hard prompt) —— restraint/拒识正是本项目北极星; (2) 内部 P1-B spike 9/11 > Qwen3.5-2B 8/11; (3) iPhone 8GB 端侧最安全(~1.5-2GB 峰值, 不撞 jetsam); (4) 标准 transformer mlx-swift 成熟; (5) C5 LoRA 全量本就要练, 1.7B 微调收益大(小模型 fine-tune 增益最大, distil labs 实证)。『新』本身不是换的理由 —— 4B-2507 只在『有 RAM 余量 + restraint 也实测更强』时才值得换。 ( release 2025-04/05; mlx 4bit 14849 下载/月; 仍是同尺寸 restraint 实测最强, 未被超越)

### grill 议题
- 磊哥嫌 1.7B『太老(2025-05)』, 但 Qwen 家族压根没出过 1.7B 的 2507/更新版(2507 只给了 4B/30B/235B)。所以『想要新一点的 1.7B 同款』无解 —— 你要的是 (A) 守原 1.7B(restraint 实测冠军+端侧最安全), 还是 (B) 跳到更大的 Qwen3-4B-Instruct-2507(2025-08, 标准 dense, 通用 FC 更强, 但更吃 8GB RAM 且 restraint 在我们题集未证强)?
- 如果倾向 4B-2507: 它在 iPhone 15PM 8GB 上是『边界可行需硬化』不是营销说的甜区(2B 在 17 Pro 已吃 2900MB 峰值, 4B 近两倍, 逼近 jetsam 上限)。要不要把 Qwen3-4B-Instruct-2507(non-thinking) 正式纳入 P1-B Qwen spike S2, 与 1.7B 同 harness 在 C6 bench(含 trap/拒识)+ iPhone 实测 RAM 上对跑, 用实测分而非通用 benchmark 外推来拍? 这是 roadmap 里 spike 在 train 前收口的本意。
- 『新≠强』在 Qwen3.5/3.6 线上是工程实锤(GDN+VL 架构 + tool-calling chat_template 系统性损坏 + 内部 spike 2B 实测劣)。我建议把 Qwen3.5/3.6 全线对本项目标 drop, 结论锁定在标准 transformer 线(1.7B 或 4B-2507)。同意把这个写进 roadmap/decisions 作为『追新边界』吗 —— 即『新只在标准 transformer + ≤4B + restraint 实测 ≥1.7B + 端侧 RAM 实测过』四条全满足时才换?


---

## Google Gemma / Meta Llama 端侧小模型(≤4B):Gemma 3(1B/4B)、Gemma 3n、Gemma 4(E2B/E4B,cutoff后2026-04新发布)、FunctionGemma 270M、Llama 3.2(1B/3B)、Llama 4 small,逐一对照 Qwen3-1.7B 在 FC/中文/iPhone15PM-8GB端侧/mlx-swift集成/活跃度。

- **联网搜索次数**: 11
- **一句话结论**: Gemma/Llama ≤4B全集无一胜过Qwen3-1.7B:Gemma4虽唯一真'新'(2026-04)但在项目同版本mlx-swift-lm 3.31.3加载失败+受限解码repetition collapse+中文次于Qwen,Gemma3-4B FC仅2.0/5且更老,Llama3.2全系中文非官方+Restraint 0.000——守Qwen3-1.7B(项目cited benchmark 20跑0.960冠军),'新≠强'本路充分证实。
- **本机 scout**: 本机HF cache已缓存 mlx-community/Qwen3-1.7B-4bit + Qwen3.5-2B-4bit,无Gemma/Llama缓存(需现下)。硬件=Apple M5/32GB(训练机,与任务描述一致)。ref-repos/有两个高价值本地一手benchmark:(1) tool-calling-benchmark(=项目cited Qwen3-1.7B证据源)README Round3明确Qwen3-1.7B=0.960冠军/gemma3:1b=0.690/llama3.2:3b=0.660(Restraint 0.000)/llama3.2:1b=0.430/functiongemma=0.640;(2) ha-voiceagent-bench/reports/gemma4-budget512-benchmark-2026-04-25.md实测'No Gemma4 config worth deploying over Qwen3-8B baseline',E4B需reasoning才competitive(延迟7-11x),E2B reasoning-off 62.3% unusable。两本地源比web summary权威,且直接证伪了'Qwen3-1.7B FC弱0.670'的小样本误传。

### 候选
- **Gemma 4 E4B (google/gemma-4-E4B-it)** (size=Effective 4B (~4.5B effective params, PLE架构), 4bit ~2.5GB磁盘 / ~5GB RAM峰值, release_date=2026-04-02 (Google Developers Blog宣布;cutoff 2026-01后,确实'新'), architecture=VLM(原生多模态text+vision+audio)+ Per-Layer-Embedding(PLE)+ MatFormer。非标准text transformer,经 mlx_vlm 加载,不是项目用的纯text mlx-swift-lm路径。, vs_1_7b=worse)
  - fc_benchmark: 官方model card宣称native function calling。但❌实测红灯:Gemma4在constrained JSON/tool-call下普遍repetition collapse(Ollama#15502/vLLM#40080/llama.cpp#21375/gemma#622/LiteRT-LM#2249),且'明确是相对Gemma3的regression'(gemma3:27b clean 0/10,gemma4炸);mlx-lm#1096 Gemma4 native tool_calls不被解析(tool_calls空)。ha-voiceagent-bench本地报告:E4B需reasoning-budget才competitive(off→budget延迟涨7-11x),'No Gemma4 config worth deploying over baseline'。无独立BFCL分。
  - chinese: 支持(140+语言含简中),但'translated/formal phrasing,native speaker不会这么说';Qwen在中文上'naturally excels',Gemma中文是次优。网络用语/方言/idiom差(绝绝子/yyds漏nuance)。车控中文不占优。
  - mlx_support: ❌严重红灯。mlx-swift issue#389 OPEN(2026-05-28更新):用户在main分支试'does not seem to work'。issue#282 OPEN(2026-06-11更新)三个loader gap。决定性证据:aandresalvarez 2026-05-28在【mlx-swift 0.31.3 / mlx-swift-lm 3.31.3(=项目spike-e3完全相同版本)】测E2B,PLE projection(per_layer_model_projection)shape mismatch加载失败,连text-only转换版也炸。需第三方VincentGourbin/gemma-4-swift-mlx社区port,不在mainline。
  - iphone15pm_8gb_feasible: ⚠️勉强但紧+不可集成。E4B 4bit ~5GB RAM峰值,8GB机加KV+app内存非常紧(Google官方说E4B需≥8GB iPhone15Pro+,几乎吃满)。E2B ~2-3GB更宽松。但当前mlx-swift-lm加载失败=端侧根本跑不起来。即使跑起,需reasoning才准→延迟7-11x,与'5分钟反应快'北极星冲突。
  - freshness_heat: 🔥最新最热:2026-04-02发布,Apache 2.0,mlx-community/unsloth/onnx社区day1量化,HF高likes。是本路唯一真正'比1.7B新'且热度高的候选。
  - vs_1_7b_evidence: (1)集成:在项目同版本mlx-swift-lm 3.31.3加载失败(PLE shape mismatch,aandresalvarez 2026-05-28),1.7B已spike-e3跑通;(2)FC:constrained-decoding下repetition collapse,与项目GBNF/outlines-xgrammar受限解码核心技术直接冲突,1.7B无此问题;(3)中文:Qwen系'naturally excels',Gemma是translated phrasing;(4)延迟:需reasoning才准(7-11x),违背'反应快'。唯一胜出维度=发布日期新+热度。
  - source_url: https://github.com/ml-explore/mlx-swift/issues/389 ; https://github.com/ml-explore/mlx-swift-lm/issues/282 ; https://github.com/vllm-project/vllm/issues/40080 ; https://github.com/ollama/ollama/issues/15502 ; https://huggingface.co/google/gemma-4-E4B-it
- **Gemma 4 E2B (google/gemma-4-E2B-it)** (size=Effective 2B(PLE),4bit ~1.5-2GB磁盘 / ~2-3GB RAM, release_date=2026-04-02, architecture=VLM多模态 + PLE,经mlx_vlm加载。E2B是E4B内nested sub-model(MatFormer)。, vs_1_7b=worse)
  - fc_benchmark: ha-voiceagent-bench本地:E2B reasoning-off仅62.3%(unusable),budget-512才80.1%但延迟4.3s(2.5-7x慢)。同样受Gemma4 constrained-JSON repetition regression影响。
  - chinese: 同E4B(共享tokenizer/训练),中文次于Qwen;且更小=中文判断更弱。
  - mlx_support: ❌同E4B。aandresalvarez 2026-05-28实测两个E2B artifact(lmstudio-community + jorch text-only版)在mlx-swift-lm 3.31.3均PLE projection加载失败。
  - iphone15pm_8gb_feasible: RAM上8GB可容(~2-3GB),但mlx-swift-lm当前加载失败=跑不起来;且reasoning-off FC unusable,要准就慢。
  - freshness_heat: 🔥同E4B同批最新最热。
  - vs_1_7b_evidence: RAM比E4B友好但同样(1)项目同版本mlx-swift-lm加载失败(2)reasoning-off FC unusable/要reasoning则慢(3)中文次于Qwen。仅发布新。
  - source_url: https://github.com/ml-explore/mlx-swift/issues/389 ; https://huggingface.co/google/gemma-4-E2B-it ; ~/workspace/raw/05-Projects/MAformac/ref-repos/ha-voiceagent-bench/reports/gemma4-budget512-benchmark-2026-04-25.md
- **Gemma 3 4B (google/gemma-3-4b-it)** (size=4B,4bit ~2.5GB weights / 加KV+overhead ~3.5-4.5GB RAM, release_date=2025-03(比Qwen3-1.7B的2025-05还老,不满足'新'诉求), architecture=标准 dense transformer(text+vision),非PLE。mlx-swift-lm应支持(Gemma3老架构已注册)。, vs_1_7b=worse)
  - fc_benchmark: ❌gamemaker1/gemma3-function-calling-benchmarks(2025-06,Gemini-judged):gemma3-4b仅2.0/5('severe state management issues'),gemma3-4b-it-qat 1.0/5('fails to grasp role as FC agent')。要到12B(4.0/5)才very strong。≤4B Gemma FC基本残废。Gemma3用pythonic FC(非OpenAI JSON schema),需专门parser。
  - chinese: 支持(4B+才multilingual 140+,含简中);1B是English-only。但中文质量次于Qwen(translated/formal phrasing)。
  - mlx_support: ✅mlx-swift-lm支持Gemma3老架构(无PLE),mlx-community有4bit量化。这是Gemma系唯一能在项目stack跑的。但⚠️mlx-lm#502:gemma-3-1b-it-qat-4bit多轮chat崩溃(1B;4B需自测)。
  - iphone15pm_8gb_feasible: ✅RAM可行(~3.5-4.5GB on 8GB,留得下KV+app)。能跑,但FC质量2.0/5太低。
  - freshness_heat: 已被Gemma4(2026-04)取代/supersede。2025-03发布,热度转移到Gemma4。按新鲜度=偏旧。
  - vs_1_7b_evidence: FC实测2.0/5 vs Qwen3-1.7B在项目内/外benchmark的强FC(tool-calling-benchmark Round 3 Qwen3-1.7B=0.960冠军);且比1.7B老(2025-03<2025-05);中文次于Qwen。唯一不输项=mlx-swift能跑。
  - source_url: https://github.com/gamemaker1/gemma3-function-calling-benchmarks ; https://github.com/ml-explore/mlx-lm/issues/502
- **Gemma 3 1B (google/gemma-3-1b-it)** (size=1B,4bit ~0.5GB weights, release_date=2025-03, architecture=标准text transformer + sliding window attention。, vs_1_7b=worse)
  - fc_benchmark: ❌全方位最差:gamemaker1=0.5/5('not functional as tool-using agent',hallucinates JSON);BFCL~31%(weak);本地tool-calling-benchmark Round3 gemma3:1b=0.690(Action 0.600/Restraint 0.500,parser修后更糟0.550因在restraint prompt乱调工具)。
  - chinese: ❌English-only(1B非multilingual,仅mainly English)。中文车控直接出局。
  - mlx_support: ⚠️有mlx量化但mlx-lm#502多轮chat崩溃(正是gemma-3-1b-it-qat-4bit)。
  - iphone15pm_8gb_feasible: ✅RAM极宽松(0.5GB),但English-only + FC非功能性 = 无意义。
  - freshness_heat: 旧+被Gemma4取代。
  - vs_1_7b_evidence: English-only(中文出局)+ FC 0.5/5非功能 + mlx多轮崩溃。全维度碾压性差于Qwen3-1.7B。
  - source_url: https://github.com/gamemaker1/gemma3-function-calling-benchmarks ; ~/workspace/raw/05-Projects/MAformac/ref-repos/tool-calling-benchmark/README.md
- **FunctionGemma 270M (google/functiongemma-270m-it)** (size=270M,4bit ~288MB(int8)/~125MB级, release_date=2025-12(FC专用变体), architecture=Gemma3 270M架构 + FC专用special-token格式(非JSON,BFCL eval框架都不原生支持其格式)。, vs_1_7b=worse)
  - fc_benchmark: base BFCL Irrelevance 70.6;本地tool-calling-benchmark Round3 functiongemma=0.640(完美restraint+最快435ms,但'falls into same keyword traps on hard prompts')。'NOT a dialogue model,设计为fine-tune后才高性能'。tuned后demo 58%→85%(但是英文mobile-actions域)。
  - chinese: ❌无中文证据。tuned on google/mobile-actions(英文mobile control),text-only,描述为English-oriented。
  - mlx_support: Gemma3架构,理论mlx可量化(litert/lmstudio有版本);但special-token FC格式需自定义parser,且非dialogue model。
  - iphone15pm_8gb_feasible: ✅RAM极小(125-288MB),端侧最轻。但非dialogue+非标准格式+需自训+无中文,与三层路由L2-5慢路'对话式语义泛化'需求错配。
  - freshness_heat: 较新(2025-12),Google官方FC specialist,有热度。
  - vs_1_7b_evidence: 无中文+非dialogue model(只做FC映射,不做L2-5模糊语义泛化/落域/多轮)+ 非标准special-token格式需自定义parser+ hard prompt落keyword陷阱。作为'三层路由慢路大脑'不合格;1.7B是通用dialogue+强FC+中文。可考虑作为'L1旁路FC加速器'实验但非主线替代。
  - source_url: https://huggingface.co/google/functiongemma-270m-it ; https://blog.google/technology/developers/functiongemma/
- **Llama 3.2 3B (meta-llama/Llama-3.2-3B-Instruct)** (size=3B,4bit ~2GB weights / ~3GB RAM, release_date=2024-10(最老,远旧于Qwen3-1.7B), architecture=标准text transformer。mlx-community有量化,mlx-swift-lm支持llama架构。, vs_1_7b=worse)
  - fc_benchmark: ❌本地tool-calling-benchmark Round3 llama3.2:3b=0.660,Action 0.900但【Restraint 0.000】(在每个restraint prompt都乱开工具)= 对安全门控车控demo是disqualifier。Meta官方称3B tool-use超Gemma2-2.6B/Phi3.5,但restraint崩。
  - chinese: ❌中文非官方支持(8语言:英德法意葡印西泰,无中文)。非正式测试有些中文理解但'生成英文summary'非中文输出。车控中文出局。
  - mlx_support: ✅mlx-swift-lm支持(llama标准架构),mlx-community有4bit。集成无障碍。
  - iphone15pm_8gb_feasible: ✅RAM可行(~3GB)。但中文出局+Restraint 0.000。
  - freshness_heat: ❌最旧(2024-10),且无小尺寸Llama4替代(Llama4最小Scout=109B MoE,需32GB+,端侧出局)。Llama小模型线停滞=淘汰。
  - vs_1_7b_evidence: Restraint 0.000(vs Qwen3-1.7B Restraint 1.000)对'拒识+安全门'demo致命;中文非官方支持;2024-10最老;无Llama4小模型继任。集成顺(mlx ok)救不了核心短板。
  - source_url: ~/workspace/raw/05-Projects/MAformac/ref-repos/tool-calling-benchmark/README.md ; https://huggingface.co/meta-llama/Llama-3.2-3B-Instruct
- **Llama 3.2 1B (meta-llama/Llama-3.2-1B-Instruct)** (size=1B,4bit ~0.5-0.7GB, release_date=2024-10, architecture=标准text transformer。, vs_1_7b=worse)
  - fc_benchmark: ❌tool-calling-benchmark Round3 llama3.2:1b=0.430(rank 21近垫底,Action 0.700/Restraint 0.500/3次错调);BFCL~26%(最弱)。
  - chinese: ❌中文非官方支持。
  - mlx_support: ✅mlx-swift-lm支持,但FC太弱无意义。
  - iphone15pm_8gb_feasible: ✅RAM极宽松,但中文出局+FC垫底。
  - freshness_heat: ❌最旧+停滞。
  - vs_1_7b_evidence: FC 0.430垫底 + BFCL 26% + 中文非官方 + 2024-10最老。全维度差于Qwen3-1.7B(0.960)。
  - source_url: ~/workspace/raw/05-Projects/MAformac/ref-repos/tool-calling-benchmark/README.md

### tigers (坑点)
- [HIGH] 若被Gemma4'2026-04最新+热度高'诱导切换,会撞上constrained-decoding repetition collapse——这是项目核心技术(GBNF/outlines-xgrammar受限解码生成ToolCall)的直接杀手。多框架(Ollama/vLLM/llama.cpp/gemma官方)一致复现,且明确是相对Gemma3的regression,repeat_penalty无效。
  - 证据: vLLM#40080 '结构化输出(JSON schema/grammar)时infinite repetition显著增多';llama.cpp#21375 tool-call时infinite repetition;ollama#15502;google-deepmind/gemma#622;机制=xgrammar限token空间后模型轻微repetition bias被放大成强loop无法生成EOS。
  - 缓解: 守Qwen3-1.7B。若磊哥坚持评估Gemma4,必须先在项目实际GBNF/受限解码链路下做repetition压力测试(非happy-path),复现即kill。不在受限解码下评估=假绿。
- [HIGH] Gemma4 E2B/E4B在项目当前完全相同的mlx-swift-lm 3.31.3版本上加载失败(PLE per_layer_model_projection量化tensor shape mismatch),连text-only转换版也炸。即便RAM够、即便FC好,端侧根本起不来。
  - 证据: aandresalvarez 2026-05-28在mlx-swift 0.31.3/mlx-swift-lm 3.31.3(项目spike-e3完全同版本)实测两个E2B artifact均加载失败;issue#389/#282均OPEN(2026-05-28/06-11);只有第三方VincentGourbin社区port可跑,不在mainline,引入=放弃官方mlx-swift-lm抽象。
  - 缓解: Gemma4端侧集成需等mlx-swift-lm官方注册gemma4+修PLE loader(无timeline)。在此之前Gemma4不是可行端侧候选。守1.7B(已spike-e3跑通)。
- [HIGH] Llama 3.2:3b 'Action 0.900看着能干活'的happy-path假象掩盖 Restraint 0.000——在所有'不该调工具'的prompt上都乱开。对'拒识+安全门'是demo价值核心的车控演示=灾难性(客户随便说句无关话就触发车控)。
  - 证据: 本地tool-calling-benchmark Round3 llama3.2:3b Restraint栏=0.000(对比Qwen3-1.7B Restraint 1.000);benchmark核心结论'wrong action比missed action罚更重,知道何时不调工具是dominant skill'。
  - 缓解: Llama 3.2全系出局(中文+restraint双杀)。任何小模型选型必看Restraint维度,不只看Action/Format。
- [MEDIUM] 外部单次web-search/三跑benchmark数字不可靠会误导选型(paper-tiger警示)。早期web summary声称'Qwen3-1.7B FC弱0.670/capability valley',若据此弃1.7B=被小样本artifact骗。
  - 证据: 本地tool-calling-benchmark README Round3明确:0.670是Round2三跑小样本artifact;20跑后Qwen3-1.7B=0.960是冠军('always this good'),7个模型变动>0.05,3跑majority voting inadequate。
  - 缓解: 选型只信≥20跑稳定benchmark;Qwen3-1.7B的真实FC实力被证强(本路反而是对1.7B的有力背书)。Gemma/Llama无任何≤4B模型在此benchmark接近0.960。
- [MEDIUM] Gemma 3 1B / Gemma 4 在mlx-lm多轮chat有崩溃史,即便加载成功,三层路由L2-5慢路常多轮(澄清/落域锁域)会触发。
  - 证据: mlx-lm#502 gemma-3-1b-it-qat-4bit第二轮+chat崩溃(commit 50012d1后);gemma3n同崩。
  - 缓解: 若评估任何Gemma,必须测多轮(非单轮happy-path),覆盖项目的clarify→落域多轮链路。

### adopt 候选
- [adopt] **守 Qwen3-1.7B(本路结论:不换Gemma/Llama)** — 本路穷尽Gemma(3/3n/4/FunctionGemma)+Llama(3.2/4)≤4B全集,无一个在FC+中文+端侧集成三维同时胜过Qwen3-1.7B。Qwen3-1.7B在项目自己cited的tool-calling-benchmark Round3(20跑)=0.960冠军,Gemma/Llama最高仅0.69。已spike-e3跑通mlx-swift-lm。中文Qwen原生强。 (https://github.com/MikeVeerman/tool-calling-benchmark Qwen3-1.7B 2025-05;虽非最新但FC/中文/集成实测最优,'新≠强'本路充分证实(Gemma4 2026-04最新反而集成炸+FC repetition)。)
- [adapt] **FunctionGemma 270M — 仅作'L1快路FC加速器'实验性旁路(非主线替代)** — 270M极轻(125-288MB)+完美restraint+435ms最快,理论可作L1精确指令的超轻FC专用头。但无中文+非dialogue+special-token非标准格式+需自训,不能替代三层路由L2-5慢路通用大脑。若磊哥想探索极致端侧速度可作side-experiment,优先级低,不动主线1.7B。 (https://huggingface.co/google/functiongemma-270m-it 2025-12,较新。)
- [drop] **Gemma 4 E2B/E4B — DROP(端侧主线候选)** — 唯一真'新'(2026-04)+热,但三重HIGH红线:(1)项目同版本mlx-swift-lm 3.31.3加载失败(PLE shape mismatch);(2)constrained-decoding repetition collapse直撞受限解码核心技术;(3)中文次于Qwen+需reasoning才准(延迟7-11x违'反应快')。等mlx-swift官方修gemma4 loader+社区确认constrained-decoding不崩前不进。 (https://github.com/ml-explore/mlx-swift-lm/issues/282 2026-04-02最新,但freshness救不了集成+FC红线。)
- [drop] **Gemma 3 4B / Llama 3.2 3B — DROP** — Gemma3-4B FC仅2.0/5+比1.7B老;Llama3.2-3B Restraint 0.000(安全门灾难)+中文非官方+2024-10最老。均无替换价值。 (https://github.com/gamemaker1/gemma3-function-calling-benchmarks Gemma3 2025-03 / Llama3.2 2024-10,均旧于Qwen3-1.7B。)

### grill 议题
- 磊哥嫌1.7B'太老'(2025-05),但本路证Gemma4(2026-04最新)集成炸+FC repetition+中文次于Qwen——'新'是诉求还是手段?若手段是'更强FC/中文/端侧',1.7B反而是当前最优。是否接受'守1.7B,把'新'诉求转到等Qwen自己出更新的≤2B(如Qwen3.5系列已在本机缓存)而非跨到Gemma/Llama'?
- Gemma4唯一'新+热'卖点,但需等mlx-swift-lm官方修gemma4 PLE loader(无timeline)+在项目GBNF受限解码下验证不repetition-collapse。是否愿意为'新'承担'端侧跑不起来+核心受限解码技术撞repetition'两个HIGH风险,还是先守1.7B?
- FunctionGemma 270M(完美restraint+435ms+125MB)能否作为L1精确指令的超轻FC旁路加速器做一个side-experiment(不动主线1.7B)?还是连实验都不值得(无中文+需自训英文mobile-actions域外迁移成本)?


---

## 微软 Phi / HF SmolLM / Mistral Ministral / 其他厂商 ≤4B 新小模型（含 Liquid LFM2.5 / IBM Granite 4 Nano / MiniCPM5 / GLM-Edge / Gemma 3n / Nanbeige）的端侧 FC + 中文 + mlx + iPhone15PM-8GB 可行性，对比基线 Qwen3-1.7B

- **联网搜索次数**: 14
- **一句话结论**: 这些家族(Phi/SmolLM/Ministral/Granite/Gemma/MiniCPM/GLM-Edge/Nanbeige)无一在'端侧FC-restraint+中文+mlx-swift+活跃'四维同时超 Qwen3-1.7B——本机锚点 20-run benchmark(2026-02)实测 Qwen3-1.7B=0.960 仍是冠军,所有指派候选(ministral-3:3b 0.800/phi4-mini 0.780/smollm3 0.630/granite4 0.520/gemma3 0.690)全在其下;唯一真值得 spike 的'更新'候选是 Liquid LFM2.5-1.2B(2025-11,比1.7B新6月,0.920 仅差0.04+完美restraint+快7x+<1GB RAM+官方MLX+非SSM架构),但中文非原生需 LoRA 验证,Granite 高 BFCL 是'敢调judgment差'陷阱;结论=诚实守 Qwen3-1.7B 为主线,LFM2.5-1.2B 列 P1-B spike 唯一备胎(中文LoRA后+iOS端到端实测过门才换),'新'的 Ministral/MiniCPM 满足日期但端侧FC弱于1.7B不值换。
- **本机 scout**: 本机已缓存 mlx-community/Qwen3-1.7B-4bit + Qwen3.5-2B-4bit(选型基线两个都在);硬件 Apple M5/32GB(训练机,非iPhone);mlx-lm 0.31.1。关键:本机 ref-repos/tool-calling-benchmark = MAformac 锚点 benchmark 全套(MikeVeerman/lintware fork),Round3(2026-02-14)用 20-run majority-vote 实测 21 模型,本路指派的全部候选家族(phi4-mini/ministral-3:3b/smollm3:3b/gemma3:1b/granite4:3b/granite3.3:2b/lfm2.5:1.2b/nanbeige4.1:3b/functiongemma)与 qwen3:1.7b 头对头——这是比任何官方 BFCL 更贴 MAformac(拒识/restraint 第一)的一手对比源。结论数据全部 file:line 锚定 ROUND3_REPORT.md:36-146。
- **clone 深扒**: ~/workspace/raw/05-Projects/MAformac/ref-repos/tool-calling-benchmark (已存在,本路深扒 ROUND3_REPORT.md:36-146 = 21模型 vs qwen3:1.7b 20-run head-to-head,含 phi4-mini/ministral-3/granite4/smollm3/gemma3/lfm2.5/nanbeige 全部指派候选)

### 候选
- **LiquidAI LFM2.5-1.2B (Instruct / Thinking)** (size=1.17B (远小于目标天花板,8GB RAM 压力最小), release_date=2025-11-28 (Instruct/Base);Thinking 变体 2025-11/12 — 比 Qwen3-1.7B(2025-05)真新 6 个月, architecture=混合 Liquid 架构=gated short-conv(多数层)+少量 GQA;关键:经 hardware-in-loop 搜索后【不含 SSM/linear-attention】(arxiv 2511.23404),比 Qwen3.5-2B 的 GDN+VL 简单得多,移植风险低, vs_1_7b=mixed)
  - fc_benchmark: BFCLv3: Instruct=49 / Thinking=57 (LiquidAI 官方,custom handler)。Qwen3-1.7B=55.49(TinyLLM arxiv 2511.22138)→ Thinking 略超基线,Instruct 略低。⚠️但更权威的本机 20-run restraint 基准(MAformac 锚点 tool-calling-benchmark Round3,2026-02-14):lfm2.5:1.2b=0.920 Agent Score(完美 restraint+0错调+1.0 multi-tool),vs qwen3:1.7b=0.960,排第 2,且延迟 1567ms vs 10665ms(快7x)。IFEval 74.89%>Qwen3-1.7B 73.98%
  - chinese: 官方支持中文(9语:en/ar/zh/fr/de/ja/ko/es),但非核心语,靠跨语迁移;LiquidAI 自己建议小模型对窄域 fine-tune。out-of-box 中文 NLU 大概率弱于 Qwen(原生CN海量训练)。MAformac 反正全量 LoRA → 可缓解,但中文车控泛化基线低于 Qwen 系是真实风险
  - mlx_support: ✅ 强。LiquidAI 官方发布 MLX 4/5/8bit+bf16(Instruct+Thinking 都有),day-one MLX 支持;且 LFM2-VL 已在 ml-explore/mlx-swift-lm 的 16 VLM 架构清单内 → 证明 LFM2 家族在 iOS Swift 栈可跑(非仅 mlx-lm Python)
  - iphone15pm_8gb_feasible: ✅ 最优。官方称 <1GB RAM 运行,移动 NPU 82 tok/s;4bit 权重~0.6-0.7GB,峰值 RAM(含KV+app)远在 8GB 内,余量充足。1.2B 比 3B 候选在 8GB 紧约束下安全得多
  - vs_1_7b_evidence: 端侧/速度/RAM/活跃度【更优】(1.2B<1.7B,7x快,官方MLX,2026仍迭代);FC restraint 实测【略差】(0.920 vs 0.960,但完美 restraint=拒识对,正中 MAformac 痛点);中文【未知偏弱】(非原生CN,需 LoRA 补)。综合=唯一真值得 spike 的'更新'候选,但不是无脑换
  - source_url: https://www.liquid.ai/blog/lfm2-5-1-2b-thinking-on-device-reasoning-under-1gb ; https://huggingface.co/LiquidAI/LFM2.5-1.2B-Thinking ; 本机 ref-repos/tool-calling-benchmark/ROUND3_REPORT.md:39
- **Microsoft Phi-4-mini-instruct** (size=3.8B (接近 D38 ≤4B 天花板,8GB RAM 较紧), release_date=2025-02(Phi-4-mini);技术报告 2503.01743。比 Qwen3-1.7B 还老,不算'新', architecture=标准 dense decoder transformer 3.8B + Mixture-of-LoRAs(多模),GQA, vs_1_7b=worse)
  - fc_benchmark: 本机 20-run restraint 基准: phi4-mini:3.8b=0.780(从 Round2 co-champion 跌到第7);P12 70%误调 get_weather(WRONG),硬题 restraint 失守。微软自承'会幻觉函数名',多调链 schema 易脆。【明确劣于 Qwen3-1.7B 0.960】
  - chinese: 官方支持中文(200K词表为多语设计),但研究证实'中文即便全精度也只中等',4bit 进一步削弱(mlx-community/Phi-4-mini-instruct-4bit 是直转,非动态量化)。车控中文不如 Qwen
  - mlx_support: ✅ 有 mlx-community/Phi-4-mini-instruct-4bit(及 8bit)+ Unsloth 动态量化;mlx-swift 可跑(strathweb 实证 iOS 跑 Phi)
  - iphone15pm_8gb_feasible: ⚠️ 勉强。3.8B 4bit 峰值~3-4GB,8GB 内但余量小;tok-s ~15-25。比 1.2-3B 候选吃紧
  - vs_1_7b_evidence: FC restraint 实测 0.780<<0.960(MAformac 锚点同基准 20-run);中文中等偏弱;3.8B 更吃 RAM;发布更老。四维全输或平。淘汰
  - source_url: https://huggingface.co/microsoft/Phi-4-mini-instruct ; 本机 ref-repos/tool-calling-benchmark/ROUND3_REPORT.md:44,87,137
- **HuggingFace SmolLM3-3B** (size=3B, release_date=2025-07(SmolLM3)。比 Qwen3-1.7B 稍新但中文是硬伤, architecture=标准 decoder transformer 3B,GQA+NoPE(3:1),dual-mode reasoning, vs_1_7b=worse)
  - fc_benchmark: 本机 20-run: smollm3:3b=0.630(Round3 第14;P5 restraint 失守,P10/P11 miss,P12 误调)。原生 tool-calling 有但判断力差。【明确劣于 0.960】
  - chinese: ❌ 弱。6 核心语(en/fr/es/de/it/pt)不含中文;中文只用'更少 token'训练,明显弱于核心语。车控中文不可靠
  - mlx_support: ✅ zero-day MLX(mlx-community/SmolLM3-3B-Base-4bit,mlx-lm 0.26);Rapid-MLX 列 smollm3-3b-4bit
  - iphone15pm_8gb_feasible: ✅ 可跑。3B 4bit~2GB 权重,峰值~3-4GB 在 8GB 内;但 q0f16 推荐(4bit 削 tool reliability)
  - vs_1_7b_evidence: FC restraint 0.630<<0.960;中文非支持语(致命);四维输三(中文/FC/restraint),仅 mlx 持平。淘汰
  - source_url: https://huggingface.co/HuggingFaceTB/SmolLM3-3B ; 本机 ref-repos/tool-calling-benchmark/ROUND3_REPORT.md:51,94,122
- **Mistral Ministral-3-3B-Instruct-2512** (size=3B, release_date=2025-12-04 (真新,比 Qwen3-1.7B 新 7 个月);arxiv 2601.08584, architecture=标准 dense decoder transformer 3B,GQA(32q/8kv)+RoPE+YaRN,256K ctx,带视觉;原生 FC+JSON, vs_1_7b=worse)
  - fc_benchmark: 本机 20-run: ministral-3:3b=0.800(Round3 并列第4,完美 restraint+0错调,但 P10/P11/P12 三硬题全 miss=过度保守,Action 仅 0.500)。官方 BFCL 未单独公布 3B。【劣于 Qwen3-1.7B 0.960,但优于 phi/smollm/granite,是这家最强】
  - chinese: 支持中文(多语含 zh),Multilingual MMLU(Base)65.2%;但无原生 C-Eval 公布,非 CN-heavy。车控中文不及 Qwen
  - mlx_support: ✅ 有 mlx-community/Ministral-3-3B-Instruct-2512-4bit(prince-canuma 转,mlx-lm 0.28.4,~24天前上传=很新);8B/14B 同有
  - iphone15pm_8gb_feasible: ✅ 可跑。官方称 FP8 可入 8GB VRAM,4bit 更小;3B 4bit 峰值~3-4GB 在 iPhone 8GB 内,tok-s~20-30
  - vs_1_7b_evidence: FC restraint 0.800<0.960(硬题不敢动,Action 0.500 vs Qwen 0.900);中文不及 Qwen;但发布真新+mlx 新鲜+完美 restraint。'新'但 demo 价值(听懂+敢动+泛化)弱于 Qwen。淘汰(不值得换),保留为'真新但仍输'的对照
  - source_url: https://huggingface.co/mlx-community/Ministral-3-3B-Instruct-2512-4bit ; https://mistral.ai/news/mistral-3/ ; 本机 ref-repos/tool-calling-benchmark/ROUND3_REPORT.md:42,86,114
- **IBM Granite 4.0 Nano (H-1B / 1B / 350M)** (size=1B / 1.5B(H) / 350M — 8GB RAM 极宽松, release_date=2025-10-29(比 Qwen3-1.7B 新 5 个月), architecture=H 版=hybrid-SSM(1.5B/350M);另有标准 transformer 版(为 SSM 未优化的栈备);Apache 2.0,ISO 42001 认证, vs_1_7b=mixed)
  - fc_benchmark: ⚠️双面:IBM 官方称 BFCL v3=54.8(H-1B)> Qwen3 52.2 > Gemma3 16.3,IFEval 也胜。但本机 20-run restraint 基准:granite4:3b=0.520(Round3 第19,P5/P9 restraint 双失守,Action 0.800 但乱调)。即'敢调但judgment差'——BFCL-AST 高 ≠ 拒识好,而拒识正是 MAformac 死穴
  - chinese: ✅ 官方列中文(en/de/es/fr/ja/pt/ar/cs/it/ko/nl/zh),12 语含中文+原生 tool-calling chat template
  - mlx_support: ✅ 官方称 MLX 原生支持;社区 ethicalabs/granite-4.0-350m-MLX(mlx-lm 0.28.2)。但 H 版是 hybrid-SSM,iOS mlx-swift 对 SSM 支持需验(标准 transformer 版更稳)
  - iphone15pm_8gb_feasible: ✅ 极易(1B/350M);8GB 毫无压力,tok-s 高
  - vs_1_7b_evidence: BFCL-v3 单轮 AST【官方称略胜】(54.8 vs 52.2);但 restraint/拒识【实测惨败】(0.520 vs 0.960,3B 版 P5/P9 全崩);中文【支持】;尺寸/RAM【更优】。结论:对 MAformac(拒识+安全门第一)是陷阱候选——分数好看但judgment差。淘汰主线,可作 350M 超轻 fallback 探针
  - source_url: https://huggingface.co/blog/ibm-granite/granite-4-nano ; 本机 ref-repos/tool-calling-benchmark/ROUND3_REPORT.md:57,100,128
- **OpenBMB MiniCPM5-1B (及 MiniCPM4-MCP)** (size=MiniCPM5-1B=1B;MiniCPM4-MCP=8B(8B 超天花板,不可端侧), release_date=2026-05-19(MiniCPM5-1B,最新一批,真新);MiniCPM4=2025-06, architecture=1B dense(MiniCPM5);MiniCPM5 XML-based tool parser;MiniCPM4-MCP=8B 专门 agent(MCP 单/跨工具), vs_1_7b=unknown)
  - fc_benchmark: MiniCPM5-1B BFCL v4=25.1%(第三方 benchlm 追踪,Qwen3.7Max 75 / ZAYA1-8B 39.2 之后)。BFCL v4 比 v3 难,但 25.1 偏低;未进本机 restraint 基准(无 20-run 实测)。FC 实证不足
  - chinese: ✅ 强项。清华系,1B 在中文理解/数学雷达图触及 7-8B 模型;MiniCPM-2.4B 历史上中文超 Mistral-7B。中文车控是这家最大卖点
  - mlx_support: ⚠️ 部分。MiniCPM3-4B 有 mlx 6bit;MiniCPM5-1B 有 GGUF 官方,mlx-community 4bit 未确证(需验);iOS mlx-swift 对 MiniCPM 架构支持需验
  - iphone15pm_8gb_feasible: ✅(1B 版)8GB 宽松;但 8B MCP 版崩(超 D38)
  - vs_1_7b_evidence: 中文【可能更优】(原生 CN 强,1B 触 7-8B 中文);FC【BFCL v4 25.1 偏低 + 无 restraint 实测,存疑】;mlx-swift 端侧【未证实】。中文是亮点但 FC/restraint/端侧 mlx 三项未证实 → 真换需先 spike。当前不推,列为'中文潜力股待验'
  - source_url: https://huggingface.co/openbmb/MiniCPM5-1B ; https://benchlm.ai/benchmarks/bfclV4 ; https://huggingface.co/openbmb/MiniCPM4-MCP
- **Zhipu GLM-Edge-1.5B/4B-Chat** (size=1.5B / 4B, release_date=❌ 2024 末(GLM-4 代),已过 60 天活跃门很久;Zhipu 现主推 GLM-5(744B MoE,非 edge)。GLM-Edge 线已陈旧, architecture=GLM-4 衍生 dense,1.5B/4B-Chat + V-2B/5B 多模, vs_1_7b=worse)
  - fc_benchmark: 无明确 edge 版 FC 文档,无 BFCL/restraint 实测。未证实
  - chinese: ✅ GLM 系原生中英双语,中文强(车机/手机定位);但 GLM-Edge 是 GLM-4 代,FC 未在 edge 版明确文档化
  - mlx_support: ❌ 未见 GLM-Edge-1.5B/4B 的 mlx-community 转换(只有 GLM-4.6V 大模型有 mlx);iOS 不可直跑
  - iphone15pm_8gb_feasible: ⚠️ 理论可(1.5B 为车机设计),但无 mlx 量化=mlx-swift 跑不了,需自转+验架构
  - vs_1_7b_evidence: 中文【或更优】但 mlx【缺失】+发布【2024 陈旧,超新鲜度门】+FC【未证实】。按 github-first 新鲜度硬约束(60天)直接淘汰
  - source_url: https://github.com/zai-org/GLM-Edge
- **Google Gemma 3n (E2B/E4B) / FunctionGemma 270M** (size=Gemma3n E2B/E4B;FunctionGemma 270M, release_date=Gemma3n 2025-05;FunctionGemma 2025-12, architecture=Gemma3n=selective param activation(MatFormer),多模;FunctionGemma=Gemma3-270M FC 专调, vs_1_7b=worse)
  - fc_benchmark: 本机 20-run: gemma3:1b=0.690(restraint 0.500 半失守);functiongemma=0.640(2 错调);Gemma3 在 IBM BFCL 对比仅 16.3。Gemma 系 restraint 整体弱
  - chinese: Gemma3 系多语含中文但 restraint 历史差;FunctionGemma 270M 是 FC 专用但纯英 Mobile-Actions 评测
  - mlx_support: Gemma-3 在 mlx-swift-lm VLM 清单内;Gemma3n 的 selective-activation 端侧 mlx 支持需验;FunctionGemma 270M 易转
  - iphone15pm_8gb_feasible: ✅(尺寸小);但 Gemma3n FC 主要走 Android AI Edge SDK,非 mlx-swift FC 路径
  - vs_1_7b_evidence: FC restraint 实测(gemma3:1b 0.690 / functiongemma 0.640)<<0.960;Gemma BFCL 16.3 极低;FC 走 Android SDK 非 mlx-swift。淘汰
  - source_url: https://blog.google/innovation-and-ai/technology/developers-tools/functiongemma/ ; 本机 ref-repos/tool-calling-benchmark/ROUND3_REPORT.md:45,50,116
- **Nanbeige4.1-3B (南北阁,对照)** (size=3B, release_date=2026 初(社区请求加入 Round3), architecture=Nanbeige4-3B-Base 经 SFT+RL 的中文推理模型, vs_1_7b=worse)
  - fc_benchmark: 本机: nanbeige4.1:3b=0.800(并列第4,完美 restraint,但仅 3 跑=preliminary,且三硬题全 miss=过度保守);延迟 22.8s 太高
  - chinese: ✅ 原生中文推理模型(Nanbeige Lab,社区为中文点名请求)
  - mlx_support: ❌ 不在 Ollama 官方库,只 llama.cpp GGUF;无 mlx-community 转换确证
  - iphone15pm_8gb_feasible: ⚠️ 3B 可跑但无 mlx;CPU 延迟 22812ms 极高(仅 3 跑,preliminary)
  - vs_1_7b_evidence: 中文【强】但 FC 0.800<0.960(硬题全 miss)+延迟 22.8s 灾难+无 mlx+仅 3 跑不可靠。中文原生但端侧/FC 全输。淘汰
  - source_url: 本机 ref-repos/tool-calling-benchmark/ROUND3_REPORT.md:43,102,16

### tigers (坑点)
- [HIGH] 把 BFCL/官方 FC 分数当选型唯一依据 → 选到'敢调但judgment差'的模型,撞 MAformac 拒识+安全门死穴。Granite4-H-1B 官方 BFCL v3=54.8>Qwen3,但本机 20-run restraint 实测 granite4:3b=0.520(P5/P9 拒识双崩);phi4-mini BFCL 不低但 restraint P12 误调
  - 证据: 本机 ref-repos/tool-calling-benchmark/ROUND3_REPORT.md:57,128(granite4 0.520 restraint 0.000)+ IBM 官方 blog(BFCL 54.8)矛盾;MAformac 北极星=拒识对+安全门,restraint 比 BFCL-AST 更命门
  - 缓解: 选型判据用【本机 20-run restraint Agent Score(锚点 tool-calling-benchmark)】而非单看 BFCL;任何候选换 Qwen 前必在 MAformac C6 bench(IrrelAcc 拒识轴)实测,不信官方单轴 BFCL
- [HIGH] '新'被误当'强'。Ministral-3-2512(2025-12,真新)+ MiniCPM5-1B(2026-05,真新)发布日期碾压 Qwen3-1.7B(2025-05),但 Ministral 本机实测 0.800<0.960(硬题全 miss),MiniCPM FC restraint 无实测。满足磊哥'要新'但 demo 价值反降
  - 证据: Ministral-3:3b ROUND3:42=0.800,三硬题 P10/P11/P12 全 miss(Action 仅 0.500);任务书明示'新≠强,2B 更新反更差'(内部 spike 1.7B 9/11>Qwen3.5-2B 8/11)
  - 缓解: 向磊哥明确:满足'新'的 Ministral/MiniCPM 端侧 FC restraint 不及 1.7B;真正值得 spike 的'更新且不弱'只有 LFM2.5-1.2B(0.920,差 0.04,但快7x+RAM省)。换的标准锁死=本机 restraint≥0.90 且中文不崩,不是日期
- [MEDIUM] LFM2.5 中文车控 out-of-box 弱(非原生 CN,LiquidAI 自承小模型需窄域 fine-tune),裸跑中文泛化基线低于 Qwen,LoRA 起点更差可能拖累最终中文听懂
  - 证据: WebSearch: LFM2 中文是支持非核心语,跨语迁移;LiquidAI 官方'recommend fine-tuning on narrow use cases';Qwen 原生 CN 海量训练优势
  - 缓解: 若 spike LFM2.5,必做中文车控 LoRA 后对比(非裸跑对比);C5 数据门同一配方两边训,C6 同 harness 比中文 IrrelAcc/ToolAcc。中文 LoRA 后仍弱于 Qwen → 守 1.7B
- [MEDIUM] LFM2.5 混合架构(gated short-conv+GQA)在 mlx-swift(iOS,非 mlx-lm Python)的 FC/受限解码链路未端到端实测,可能像 Qwen3.5-2B 一样'Python 跑通但 chat_template/iOS 解析坑'
  - 证据: Qwen3.5-2B 前车之鉴(GDN+VL,chat_template 空致内部 spike 8/11<1.7B 9/11);LFM2-VL 虽在 mlx-swift-lm 16-VLM 清单(证家族支持),但 1.2B-Instruct 纯文 FC 的 iOS 端到端(tool special token+受限解码)未见实测
  - 缓解: spike LFM2.5 时复用 spike-e3 同链路:mlx-swift 加载 LFM2.5-1.2B-Instruct-4bit → 实测 <|tool_call_start|> 解析 + TTFT/RAM(对标 P1-B Qwen S1/S2 spike 同验收门),iOS 跑不通直接淘汰,不停在 Mac mlx-lm 绿
- [MEDIUM] 本机 tool-calling-benchmark 是 CPU/Ollama/12-prompt 小样本,非 MAformac 中文车控全集;直接拿它的 Agent Score 排序当 MAformac 选型结论可能 over-fit(它测英文通用工具判断,非中文车控3990全集)
  - 证据: ROUND3 全英文 prompt(get_weather/schedule_meeting/search_files),12 prompt;MAformac=中文车控3990协议+拒识全集。两者域不同
  - 缓解: 本机 benchmark 仅作'判断力/restraint 维度'交叉验证(它强在 restraint 设计=正中 MAformac),最终判据回 MAformac C6 vehicle-tool-bench 中文全集;不把英文小样本排序当终判

### adopt 候选
- [adapt] **LiquidAI LFM2.5-1.2B-Instruct (+Thinking) — P1-B spike 唯一备胎** — 唯一'真更新(2025-11)+端侧FC不弱(0.920,差0.04)+完美restraint(正中拒识痛点)+快7x+<1GB RAM 在8GB最安全+官方MLX 4/5/8bit+非SSM架构(LFM2-VL已在mlx-swift-lm)'的候选。adapt 非 adopt:必须先(a)中文车控LoRA后对比非裸跑(b)mlx-swift iOS 端到端实测 tool special-token解析+TTFT/RAM(对标P1-B Qwen S1/S2同门),两关过才换 Qwen (https://huggingface.co/LiquidAI/LFM2.5-1.2B-Instruct 2025-11-28 发布,2026 仍迭代(Thinking/VL/Audio 持续出);Liquid AI 活跃,官方 MLX day-one;比 Qwen3-1.7B(2025-05)新约6个月。新鲜度+热度双过门)
- [adopt] **Qwen3-1.7B (守基线)** — 本机锚点 20-run benchmark 冠军 0.960(唯一三硬题全对+完美restraint+0错调),指派的5家新候选全在其下;中文原生最强;已 spike-e3 集成 mlx-swift 3.31.3+本机已缓存4bit。诚实结论=没有更好的就守它,不为'新'降级 (https://github.com/MikeVeerman/tool-calling-benchmark 模型 2025-05(磊哥嫌老但实测最强);锚点 benchmark Round3=2026-02-14 仍把它列冠军='老但强'的实证)
- [drop] **Microsoft Phi-4-mini / HF SmolLM3 / Mistral Ministral-3 / Google Gemma3n / Zhipu GLM-Edge / Nanbeige4.1** — 全部本机 restraint 实测<0.960:Ministral 0.800(硬题全miss过度保守)/Phi 0.780(P12误调)/SmolLM3 0.630(中文非支持语+restraint崩)/Gemma3 0.690(restraint半失守)/GLM-Edge(无mlx+2024陈旧超新鲜度门)/Nanbeige(无mlx+延迟22.8s)。Ministral 虽真新但 demo 价值(敢动+泛化)弱于1.7B (本机 ref-repos/tool-calling-benchmark/ROUND3_REPORT.md:42-58 Ministral-3 2025-12/SmolLM3 2025-07 较新但实测弱;Phi-4-mini 2025-02/GLM-Edge 2024 偏老)
- [drop] **IBM Granite 4.0 Nano (H-1B/350M) — 陷阱候选,仅留超轻 fallback 探针** — 官方 BFCL v3=54.8>Qwen 看似优,但本机 restraint 实测 granite4:3b=0.520(P5/P9拒识双崩,Action0.800乱调)——'敢调judgment差',撞 MAformac 安全门+拒识死穴。BFCL-AST高≠restraint好的反面教材。仅 350M 超轻版可作极端 RAM 受限的 L1 兜底探针,非主线 (https://huggingface.co/blog/ibm-granite/granite-4-nano 2025-10-29 真新+Apache2.0+中文支持+MLX原生,但 restraint 维度淘汰它)
- [drop] **OpenBMB MiniCPM5-1B — 中文潜力股待验(不推但别误删)** — 中文原生强(1B触7-8B中文,清华系)是唯一可能在'中文'维度超Qwen的;但 BFCL v4=25.1偏低+无 restraint 实测+mlx-swift端侧未证实,FC/端侧两项空白。当前不推(证据不足),若 LFM2.5 spike 失败可作'中文优先'第二探针。drop=暂不进 spike,非永久排除 (https://huggingface.co/openbmb/MiniCPM5-1B 2026-05-19 最新(真新),清华OpenBMB活跃,但 FC/mlx-swift 端侧实证缺失)

### grill 议题
- 磊哥要'新',但本机锚点 benchmark 实测真新的 Ministral-3-2512/MiniCPM5-1B 端侧 FC restraint 都<1.7B(0.960);唯一'新且不弱'是 LFM2.5-1.2B(0.920差0.04但快7x+RAM省一半)。换的判据该锁'本机restraint≥0.90+中文LoRA后不崩'还是只要'发布更新'就行?(我建议前者)
- LFM2.5-1.2B 中文非原生(LiquidAI自承小模型需窄域fine-tune),要不要花一个 P1-B spike 周期验'中文车控LoRA后能否追平Qwen'?还是中文是硬红线、原生CN不可妥协就直接守1.7B不spike?
- Granite4-H-1B 官方BFCL 54.8>Qwen 但本机restraint 0.520(拒识崩),这是'BFCL高≠拒识好'的活教材——要不要把这条写进C6 bench纪律(选型只认restraint轴不认单轴BFCL)?
- MiniCPM5-1B中文原生强(1B触7-8B中文)是唯一可能'中文超Qwen'的,但FC/mlx-swift端侧零实测——若LFM2.5 spike失败,要不要把它列'中文优先'第二备胎再spike一轮,还是中文够用就彻底守Qwen不再折腾?


---

## 专门 FC/tool-call 微调的 SOTA 小模型(xLAM-2 / Hammer2.1 / ToolACE / FunctionGemma / LoopTool 等)是否比通用 Qwen3-1.7B 在 MAformac 端侧栈(mlx-swift + iPhone15PM 8GB + 中文车控)上 tool-call 更强且可部署

- **联网搜索次数**: 14
- **一句话结论**: FC 专精小模型(xLAM-2/Hammer2.1/FunctionGemma)纸面 BFCL 高,但对 MAformac(mlx-swift + iPhone15PM 8GB + 中文车控 demo)三重不可用：custom tool-call 格式不在 mlx-swift 解析白名单(实测 15-20% 部署崩)、无 mlx-community 4bit、FC 微调 English-only 中文打折、base 多停在 Qwen2.5/2(比 Qwen3-1.7B 旧)；8B 级(ToolACE/LoopTool)超 8GB 天花板出局。唯一'又新又中文强又有 mlx-community 4bit 又端侧可跑'的对照是 Qwen3.5-4B,但它与内部已测劣于 1.7B 的 Qwen3.5-2B 同属 GDN+VL 混合架构(tool-call 模板多 bug),97.5% 是 Mac/LM Studio 修模板后的分不直接转移。结论：守 Qwen3-1.7B(标准 transformer、模板稳、mlx-swift qwen3 白名单内、本机已缓存且 spike-e3 验证)+ 自有中文 LoRA(C5)是 FC+中文+端侧的正解；FC 专精模型只取方法学(function-masking/数据合成/闭环演化)喂 C5,不换端侧权重。要换'新'只剩 Qwen3.5-4B 一个候选,且必须 P1-B 在 mlx-swift 上对 GDN tool-call 稳定性重测后才考虑,不能凭日期新换。
- **本机 scout**: 本机 M5/32GB(训练机已证),~/.cache/huggingface/hub 已缓存 mlx-community/Qwen3-1.7B-4bit(选型基线,已 spike-e3 验证) + mlx-community/Qwen3.5-2B-4bit(内部 P1-B 测过,8/11<1.7B) + Qwen3.6-35B-A3B(太大端侧不可) + ASR(Fun-ASR/SenseVoice/whisper)。mlx-lm 0.31.1 在默认 python 可用。无任何 FC 专精模型(xLAM/Hammer/FunctionGemma/ToolACE)本机缓存——印证它们非现成 mlx 端侧路径。关键:本机已有的 1.7B 4bit 是唯一'已缓存+已跑通'的端侧 FC base,换型成本(下载+转换+P1-B 重测)高,纸面分不抵部署风险。

### 候选
- **xLAM-2-3b-fc-r (Salesforce)** (size=3B, release_date=2025-03-26, architecture=标准 transformer（Qwen2.5-3B base 上 FC 微调）, vs_1_7b=mixed)
  - fc_benchmark: BFCL sub-4B 最强：TinyLLM 论文(2025-11)实测 overall 65.74%(live 81.03 / non-live AST 88.22 / multi-turn 55.62)，relevance/restraint 94.44%(Salesforce 自报)。但这是 vLLM+专用 xlam parser 下的分
  - chinese: 弱：base Qwen2.5 中文强，但 FC 微调数据(xlam-function-calling-60k / APIGen-MT)是 English-only，agentic 上下文里中文指令跟随会退化；模型卡只标 English
  - mlx_support: 无 mlx-community 4bit 量化。官方只出 GGUF(llama.cpp)+ SpinQuant-ET(ExecuTorch)，社区有 kmhalvin SpinQuant 非 mlx。要自己 mlx_lm.convert
  - iphone15pm_8gb_feasible: 理论可：3B 4bit ~1.8-2GB，8GB 下 RAM 够。但实际不可部署——见 mlx_support 与 vs_1_7b
  - freshness_heat: GitHub SalesforceAIResearch/xLAM 仍维护但无 xLAM-3;最新模型 xLAM-2 停在 2025-03,2026 无更新。淘汰候选(stale 主线 + 部署破)
  - vs_1_7b_evidence: BFCL 纸面 65.7% > 1.7B 55.5%(同尺寸 xLAM-2-1b 53.97% 反而<1.7B)。但 jdhodges 2026-03 独立实测 xLAM-2-8B-FC-R 只得 15%(13 模型倒数第一)——根因是 custom tool-call 格式(JSON 数组 [{...}])经 OpenAI-compat API/通用 parser 解不出；mlx-swift 的 ToolCallFormat.infer 白名单(lfm2/glm4/nemotron/qwen3_5/qwen3_next/mistral3/gemma)不含 xlam，会 fallback 到默认 JSON parser → 大概率破。CC-BY-NC-4.0(内部 demo 非 blocker)。base 比 Qwen3-1.7B 旧(Qwen2.5 vs Qwen3),不满足'新'
  - source_url: https://huggingface.co/Salesforce/xLAM-2-3b-fc-r
- **xLAM-2-1b-fc-r (Salesforce)** (size=1B, release_date=2025-03-26, architecture=标准 transformer（Qwen2.5 base 上 FC 微调）, vs_1_7b=worse)
  - fc_benchmark: BFCL overall 53.97%(multi-turn 8.38%，relevance 43.12%)——同尺寸已 < Qwen3-1.7B 的 55.49%
  - chinese: 弱(同 3b，English-only FC 微调)
  - mlx_support: 无 mlx-community 4bit;官方 GGUF + SpinQuant-ET
  - iphone15pm_8gb_feasible: 可(1B 4bit ~0.6GB),但分数<1.7B 且部署破,无意义
  - vs_1_7b_evidence: 同~1B 级别 BFCL 53.97% < Qwen3-1.7B 55.49%;multi-turn 8.38% << 1.7B 16.88%。直接淘汰
  - source_url: https://huggingface.co/Salesforce/xLAM-2-1b-fc-r
- **Hammer2.1-1.5b / 3b (MadeAgents)** (size=1.5B / 3B, release_date=2024-10(2.1 系列);无 2026/Hammer3 更新, architecture=标准 transformer（Qwen2.5-Coder base + function-masking 微调）, vs_1_7b=mixed)
  - fc_benchmark: BFCL-v3 同尺寸最强 FC 增强模型之一(7B/3B/1.5B 超多数 FC 增强模型);function-masking 强 restraint。但无可靠 sub-2B 精确数;jdhodges 2026-03 实测 Hammer2.1-7B 仅 20%
  - chinese: 弱：base Qwen2.5-Coder(code 向中文一般)+ FC 数据(xlam-60k + xlam-irrelevance-7.5k)English-only
  - mlx_support: 无 mlx-community 4bit;只有 litert-community(Android LiteRT/TFLite)。要自己 convert
  - iphone15pm_8gb_feasible: 理论可(1.5B 4bit ~0.9GB / 3B ~1.8GB),8GB 够。但部署破(见 vs_1_7b)
  - freshness_heat: GitHub MadeAgents/Hammer 半年+无大更新,无 Hammer3;停在 Qwen2 系。stale
  - vs_1_7b_evidence: Hammer 用 function-masking,restraint/拒识理论强(jdhodges 测 Hammer restraint 8/8 满分)——这正是 1.7B 的强项,Hammer 未必超。但实测 Hammer2.1-7B 整体 20%:8/8 认得'不该调',却 0 分在'实际调用'类——'懂任务但产不出输出格式'。Hammer 用 Hermes parser(与 xLAM 的 JSON 数组 parser 不同),mlx-swift 对 Hermes 标签支持也不完整。base Qwen2.5-Coder 比 Qwen3-1.7B 旧。淘汰
  - source_url: https://huggingface.co/MadeAgents/Hammer2.1-1.5b
- **FunctionGemma-270M (Google)** (size=270M, release_date=2025-12(InfoQ 2026-01 报道), architecture=标准 transformer（Gemma3-270M base + FC 微调,256k 词表）, vs_1_7b=worse)
  - fc_benchmark: BFCL 出厂仅 58%,微调后 85%(Mobile Actions);irrelevance/restraint 70.6(0-shot)——明显弱于 Qwen3-1.7B 的 restraint。Gemma3-1B 裸跑 BFCL ~31%
  - chinese: 弱：Gemma3 系中文显著弱于 Qwen;FC 无中文 benchmark 公开;只标 multilingual 词表
  - mlx_support: 有 lmstudio-community/functiongemma-270m-it-MLX-8bit(非 mlx-community,8bit 非 4bit);官方支持 MLX 部署。litert/LiteRT 也有
  - iphone15pm_8gb_feasible: 极轻松:270M dynamic-int8 ~288-300MB,iPhone15Pro ~50 tok/s 全离线。8GB 毫无压力
  - freshness_heat: Google 出品,2025-12 新,生态(Unsloth/MLX/vLLM/LiteRT)支持广。新但弱
  - vs_1_7b_evidence: 出厂 58% 远<1.7B,restraint 70.6 弱于 1.7B 的完美 restraint;Gemma 中文弱于 Qwen;定位是'拿你自己 function 微调的种子'非开箱可用。可作'再小一档逃生口'但 demo 主线不丢脸需求下不达标。淘汰为主线候选
  - source_url: https://ai.google.dev/gemma/docs/functiongemma
- **ToolACE-8B / LoopTool-8B / Granite-function** (size=8B, release_date=ToolACE 2024;LoopTool 论文 2025-11(权重未确认开源), architecture=标准 transformer（ToolACE=Llama3.1-8B / LoopTool=Qwen3-8B base）, vs_1_7b=unknown)
  - fc_benchmark: ToolACE-8B BFCL-v1 91.41%/v2 85.77%(强);LoopTool-8B BFCL-v3 74.93%(超 Qwen3-32B 生成器),ACEBench 73.4%。都是 SOTA 级 FC
  - chinese: ToolACE Llama3.1 中文一般;LoopTool Qwen3-8B 中文好但 8B
  - mlx_support: ToolACE 有社区 GGUF;LoopTool 权重未确认释出。8B mlx 量化非主流
  - iphone15pm_8gb_feasible: 否：8B 4bit ~4.5-5GB + KV + app,8GB iPhone 崩(D38 已锁 ≤4B,7B/8B 崩)。直接出局
  - vs_1_7b_evidence: FC 纸面远强,但 8B 超 iPhone15PM 8GB 天花板(D38),端侧不可跑 → 与 MAformac 北极星(8GB 离线 5 分钟不炸场)冲突。可作'方法学'借鉴(ToolACE 数据合成 / LoopTool 闭环数据演化喂自己 LoRA),不可作端侧模型
  - source_url: https://arxiv.org/html/2511.09148
- **Qwen3.5-4B (对照参考,非 FC 专精但 jdhodges 榜首)** (size=4B, release_date=2026 初, architecture=GDN(Gated DeltaNet 线性注意力)+ Gated Attention 混合 + VL 视觉编码器(dense,非 MoE)——与内部 spike 测过的 Qwen3.5-2B 同架构家族,只是更大, vs_1_7b=mixed)
  - fc_benchmark: jdhodges 2026-03 本地 tool-call 实测 97.5%(13 模型榜首,40 例 1 错)——但这是 LM Studio + 修过 chat_template + Mac 上的分,非 mlx-swift/iPhone
  - chinese: 强(Qwen 系中文最强档,native multimodal)
  - mlx_support: 有 mlx-community/Qwen3.5-4B-MLX-4bit(~2.9GB);注意该 build 是 mlx-vlm(视觉)转换,纯文本端侧要走 mlx-lm/mlx-swift 文本路径。tool parser=qwen3_coder(XML 格式)
  - iphone15pm_8gb_feasible: 紧但可:4bit ~2.9GB 权重 + KV,峰值估 ~3.5-4.5GB(中等上下文),iPhone15PM 8GB(可用 ~4-5GB)是公认'sweet spot',需开 increased-memory entitlement + 控上下文(8-16K)+ 防 iOS 后台回收重载
  - vs_1_7b_evidence: 🔴关键:Qwen3.5-4B 与内部 P1-B spike 实测'8/11 < 1.7B 9/11'的 Qwen3.5-2B 是同一 GDN+VL 混合架构(只是 2B→4B),不是另一种架构。该架构系 tool-call chat_template 历史多 bug(QwenLM/Qwen3 #1831:tool 调用崩/parallel/thinking bleed;KV-cache 在 enable_thinking=false 下断;长上下文 65K+ 后 XML→JSON 漂移)。97.5% 是修过模板+Mac LM Studio,不直接转移到 mlx-swift iPhone 栈。4B 比 1.7B 慢、8GB 更紧、架构风险未消。若磊哥坚持要'新',这是唯一有 mlx-community 4bit + 端侧可跑 + 中文强 + FC 实测强的候选,但需 P1-B 在 mlx-swift 上重测 GDN tool-call 稳定性才能换
  - source_url: https://huggingface.co/mlx-community/Qwen3.5-4B-MLX-4bit

### tigers (坑点)
- [HIGH] FC 专精小模型(xLAM-2/Hammer)在 mlx-swift 端侧栈上 tool-call 解析破：custom 输出格式(xLAM=JSON 数组 / Hammer=Hermes 标签)不在 mlx-swift ToolCallFormat.infer 白名单,silent fallback 到默认 parser → tool_calls 空、原文泄进 content
  - 证据: jdhodges 2026-03 独立实测:xLAM-2-8B-FC-R 15% / Hammer2.1-7B 20%(13 模型倒数两名),Hammer restraint 8/8 满分但实际调用 0 分='懂任务产不出格式'。mlx-swift ToolCallFormat 白名单=lfm2/glm4/nemotron/qwen3_5/qwen3_next/mistral3/gemma,xlam/hammer 均不在内(GitHub mlx-swift-lm ToolCallFormat.swift)
  - 缓解: 不采 FC 专精模型作端侧主线。Qwen3-1.7B 走 mlx-swift 原生 qwen3 路径(标准 Hermes,白名单内),tool-call 解析稳;FC 能力靠自有 LoRA(C5)练,不靠换 FC 专精权重
- [HIGH] 误把 Qwen3.5-4B 当'新架构超越 1.7B'换上去——它与内部已测劣于 1.7B 的 Qwen3.5-2B 是同一 GDN+VL 混合架构,只是更大;架构级 tool-call chat_template 风险未随尺寸消除
  - 证据: WebSearch 确认 Qwen3.5-2B 与 4B 都是 dense hybrid GDN(Gated DeltaNet 线性注意力)+ Gated Attention + 视觉编码器,同 qwen3_coder XML parser;内部 P1-B spike:1.7B 9/11 > Qwen3.5-2B 8/11(2B chat_template 空、劣)。QwenLM/Qwen3 issue #1831 + vLLM recipes 记录该系 tool-call 模板多 bug(崩溃/parallel 交错/65K+ XML→JSON 漂移)
  - 缓解: 若评估 4B,必须 P1-B 在 mlx-swift(非 LM Studio)上对 GDN tool-call 稳定性 + 中文车控 restraint 重测,且与 1.7B 同 harness 对比;不凭 jdhodges Mac/LM Studio 的 97.5% 直接换。默认守 1.7B(标准 transformer,模板稳,白名单内)
- [MEDIUM] 8B 级 FC SOTA(ToolACE/LoopTool)纸面分诱人但超 iPhone15PM 8GB 端侧天花板,违反 D38 ≤4B + 北极星'8GB 离线不炸场'
  - 证据: 8B 4bit ~4.5-5GB 权重 + KV cache + app 内存,8GB iPhone 实际可用仅 ~4-5GB → OOM 崩(D38 已锁 7B/8B 崩);ToolACE BFCL-v1 91.41% / LoopTool BFCL-v3 74.93% 是服务器/桌面分
  - 缓解: 8B 模型仅作'方法学'借鉴(ToolACE 数据合成多 agent + dual-layer verify / LoopTool 闭环数据演化 GCP+JGLV)喂自己 C5 LoRA 数据配方,绝不作端侧权重
- [MEDIUM] 无任何 FC 专精小模型有 mlx-community 官方 4bit 量化,要自己 mlx_lm.convert——转换后 chat_template/tool-parser 易错,且无社区验证
  - 证据: xLAM-2(只 GGUF+SpinQuant)、Hammer(只 litert Android)、FunctionGemma(只 lmstudio MLX 8bit)均无 mlx-community 4bit。Qwen3-1.7B 已有 mlx-community/Qwen3-1.7B-4bit(本机 ~/.cache 已缓存)且 spike-e3 已集成验证
  - 缓解: 守已验证的 mlx-community/Qwen3-1.7B-4bit(本机已缓存 + spike-e3 跑通);任何换型先确认有 mlx-community 4bit 或自转后过 P1-B mlx-swift tool-call 冒烟
- [MEDIUM] FC 专精模型微调数据 English-only,中文车控泛化/拒识可能比 Qwen3-1.7B+中文 LoRA 还弱(paper-tiger 反例:看似 FC 更强,中文场景反而退化)
  - 证据: xLAM/Hammer FC 数据(xlam-function-calling-60k/APIGen-MT)模型卡标 English-only;ITC 论文:Qwen 系多语 tool-call 优于 DeepSeek,中文靠 base 多语 + 自有数据微调最稳。MAformac 是中文车控,FC 专精的英文 FC 优势在中文上打折
  - 缓解: 中文车控 FC 的正解 = Qwen3-1.7B(中文 base 强)+ 自有中文 LoRA(C5,3990 协议 + 12000 bug 真实说法),而非英文 FC 专精权重。这正是已锁路线

### adopt 候选
- [adopt] **守 Qwen3-1.7B + 自有中文 LoRA(C5)作端侧 FC 主线** — 标准 transformer 模板稳、在 mlx-swift qwen3 解析白名单内、本机已缓存 mlx-community 4bit、spike-e3 已集成验证、中文 base 强、外部 tool-calling-benchmark 同尺寸最强 restraint。FC 能力靠自有中文 LoRA 练(3990 协议+12000 bug),中文车控正解。所有 FC 专精/Qwen3.5 候选对比后仍是最优端侧 base ( 2025-05 发布;mlx-community 4bit 持续维护;本机已跑通)
- [adopt] **ToolACE 数据合成(多 agent + complexity evaluator + dual-layer verify)→ 喂 C5 LoRA 数据配方** — ToolACE-8B 靠这套数据合成把 8B 做到 BFCL 91%;方法学(26507 API pool 自演化 + 双层验证)可借来生成 MAformac 中文车控 FC 训练数据,提升 1.7B+LoRA 的 FC 质量。模型本身 8B 端侧不可跑但方法学>集子 ( ToolACE 2024 论文;方法学常青)
- [adapt] **LoopTool 闭环数据演化(GCP 能力探测 + JGLV 标签验证)→ C5 数据门迭代机制** — LoopTool-8B 用闭环把模型自身弱点驱动数据再合成,BFCL-v3 74.93% 超 32B 生成器。MAformac 可 adapt 成'C6 bench 测出 1.7B+LoRA 弱项 → 针对性补 C5 数据 → 重训'的闭环,而非一次性数据。权重未确认开源,只取机制 ( 论文 2025-11;较新)
- [drop] **xLAM-2 / Hammer2.1 作端侧权重** — 三重不可用:mlx-swift tool-call 解析白名单不含(实测部署 15-20% 崩)、无 mlx-community 4bit、FC 微调 English-only 中文打折、base Qwen2.5/2 比 Qwen3-1.7B 旧且无 2026 更新。function-masking 方法学已在之前 session adopt 入 C5,模型权重 drop ( 停在 2024-2025-03,无 Hammer3/xLAM-3,stale)
- [adapt] **Qwen3.5-4B 作端侧权重(若磊哥坚持要'新')** — 唯一新+中文强+有 mlx-community 4bit+8GB 可跑候选,jdhodges Mac 实测 97.5%。但与内部已测劣于 1.7B 的 2B 同 GDN+VL 架构(tool-call 模板多 bug)、8GB 紧、97.5% 非 mlx-swift/iPhone 分。adapt=只在 P1-B 用 mlx-swift 对 GDN tool-call 稳定性+中文 restraint 同 harness 重测过 1.7B 后才换,不凭日期新直接换 ( 2026 初,最新;mlx-community 4bit 已有)
- [drop] **FunctionGemma-270M 作'再小一档逃生口'** — 出厂 BFCL 58%/restraint 70.6 弱于 1.7B,Gemma 中文弱于 Qwen,只有 lmstudio MLX 8bit 非 4bit。'不丢脸'需求下作主线/逃生口都不达标,demo 价值不够。仅记录存在 ( 2025-12 新但弱)

### grill 议题
- 磊哥要的'新'是'发布日期新'还是'端侧 FC/中文实测更强'?本路证据:FC 专精'专精'红利在 mlx-swift+中文车控上被部署破+English-only 吃掉,xLAM-2-3b 纸面 65.7%>1.7B 55.5% 但实测部署 15%——是否接受'守 1.7B+LoRA,只升 LoRA 数据(吸 ToolACE/LoopTool 方法学)而不换权重'?
- Qwen3.5-4B 是唯一'新+中文强+有 mlx-community 4bit+8GB 可跑'候选,但与内部已测劣于 1.7B 的 2B 同 GDN+VL 架构(tool-call 模板多 bug)。是否值得花一轮 P1-B 在 mlx-swift(非 LM Studio)上对 4B 做 GDN tool-call 稳定性+中文 restraint 重测(同 harness vs 1.7B)?还是直接守 1.7B 不浪费 spike 预算?
- 8B 级 FC SOTA(ToolACE 数据合成 / LoopTool 闭环数据演化 GCP+JGLV)端侧不可跑,但其方法学可喂 C5 LoRA 数据配方——是否把这两个方法学纳入 C5 数据门 roadmap(对标已 adopt 的 Hammer function-masking/xLAM 数据)?


---

## 端侧部署框架链路(iPhone 15 Pro Max A17 Pro 8GB 上 mlx-swift vs llama.cpp vs MLC-LLM vs CoreML/ANE,代码链路+工程实现+热度+经典 issue),回应磊哥「mlx 是不是最佳端侧栈」追问

- **联网搜索次数**: 11
- **一句话结论**: 框架层结论:iPhone 15PM-8GB 上跑 Qwen3-1.7B+LoRA,mlx-swift(项目 spike-e3 已集成)是最优栈——decode 最快(17Pro 实测 Qwen3.5-2B 61 vs llama.cpp 39 tok/s)、Qwen 系内存通常最低、mlx-community 4bit 量化最全、ChatSession.tools 原生 FC + MLX-Outil(Qwen3-1.7B iOS tool-call)现成蓝本;llama.cpp/GGUF 是合理 LLMBackend fallback(GBNF FC 链路更成熟、跨平台、prefill 快);MLC-LLM(iOS 工程链最重)和 CoreML/ANE(内存省但 Qwen+LoRA 转换工程地狱+decode 最慢)均 drop 为逃生口。磊哥「mlx 是不是最佳」=是,但两个 HIGH 必须自己在 15PM 真机 spike 实测(现有数全是 17Pro/12GB,会高估)+ 有界 KV cache 防 jetsam。
- **本机 scout**: 本机 = Apple M5 / 32GB / macOS 26.6(训练机,与项目记录一致 over-provisioned)。HF 缓存已含 mlx-community/Qwen3-1.7B-4bit + Qwen3.5-2B-4bit(选型两主角都在本地可直接跑)+ 一批 ASR/TTS(SenseVoice/Fun-ASR/Whisper/Kokoro/Qwen3-TTS)。mlx-lm 0.31.1 在用。ref-repos/ 已有 tool-calling-benchmark(1.7B FC 基线来源)、home-llm(端侧蓝本)、mastra/pi 等。新 clone apple-silicon-llm-bench(端侧框架实测金矿)。注意:本机是 Mac 训练机,iPhone 15PM 端侧实测 repo 里没有(无人测 15 Pro 行),必须磊哥真机补测。
- **clone 深扒**: ~/workspace/raw/05-Projects/MAformac/ref-repos/apple-silicon-llm-bench (john-rocky, 36★, 66 commits, 数天前更新; 含 iOS BenchmarkApp 多 runtime harness + phys_footprint 内存计 + ThermalMonitor, 可直接 adopt 作 P1-B Qwen 15PM 真机 spike harness 骨架)

### 候选
- **mlx-swift-lm (ml-explore 官方,LLM/VLM Swift 包,3.x)** (size=框架,非模型;承载 Qwen3-1.7B-4bit(磁盘865MB/权重~1GB), release_date=持续迭代;mlx-swift-examples 主干 2026-06-09 更新,3.x 主版本约 1 个月前(2026-05)breaking change 解耦 tokenizer/downloader, architecture=Swift API over MLX,unified-memory zero-copy;ChatSession.tools 做 FC(PR #107), vs_1_7b=better)
  - fc_benchmark: ChatSession.tools(PR #107)原生 FC;MLX-Outil(90★,2026-01)= Qwen3-1.7B iOS tool-call 现成蓝本;受限解码可叠 outlines/GBNF。1.7B FC 强已由 tool-calling-benchmark(本机ref-repo)+项目内部spike 9/11证;⚠️小模型 tool parser 配错会 JSONDecodeError 崩,需确认 chat_template/parser
  - chinese: 承载 Qwen3+LoRA 中文,框架本身不限语言;中文能力取决于挂的模型
  - mlx_support: 本体即 MLX 官方栈;mlx-community 4bit 量化齐全(Qwen3-1.7B/0.6B/4B 均有);本机已缓存 Qwen3-1.7B-4bit + Qwen3.5-2B-4bit;项目 spike-e3 已集成 mlx-swift-lm 3.31.3
  - iphone15pm_8gb_feasible: 可行且最优。Qwen3-1.7B-4bit 权重~1GB,8GB 机宽裕。iPhone 17 Pro(A19/12GB)实测 Qwen3.5-2B short-chat:MLX 61.2 tok/s/峰值1279MB/加载1.9s(decode 比 llama.cpp 39.1 快56%、内存还更低)。⚠️15PM(A17/8GB)实际更慢更紧(repo 标 A17 是'4bit-3B 实用地板线',15 Pro 行未实测);Qwen3-0.6B 在17Pro MLX 99.3 tok/s/537MB。须加 Increased Memory Limit entitlement + 有界 KV cache
  - freshness_heat: mlx-swift-examples 2.6k★+2026-06-09更新;mlx-swift 官方;mlx-community HF 海量量化日更。活跃(<60天)✓ 人气✓
  - classic_issues: ①KV cache 无界增长→iOS jetsam 杀(8B+10k prompt 实测26GB);mlx-lm #883 macOS kernel panic 同源 → 必须 bound max-kv-size。②某些模型 MLX 峰值内存反常高:bench 实测 Gemma4-E2B short-chat MLX 3094MB vs llama.cpp 253MB(同模型差12x)→ 须按模型实测,别假设MLX总省。③大模型崩需 Release build/@MainActor/-O3(LLMEval README)
  - vs_1_7b_evidence: 这是承载 1.7B 的框架,非替代模型。结论:框架层 mlx-swift 对 iPhone15PM-8GB 跑 Qwen3-1.7B+LoRA 是最优选(decode 最快+内存通常最低+mlx-community 量化最全+项目已集成+FC 原生+蓝本现成),无需换框架
  - source_url: https://github.com/ml-explore/mlx-swift-lm
- **llama.cpp (XCFramework + GGUF,iOS)** (size=框架;Qwen3-1.7B Q4_K_M GGUF, release_date=持续高频迭代(ggml-org,最活跃端侧推理项目之一), architecture=C/C++ Metal 后端;GBNF 语法 + autoparser 从 chat_template 自动生成 tool-call 语法, vs_1_7b=mixed)
  - fc_benchmark: GBNF 受限解码 + autoparser(common/chat-auto-parser-generator.cpp)自动从 JSON schema 生成 tool-call 语法,trigger token 门控;工程最成熟的端侧受限 FC 链路。⚠️需手写 ObjC++ 桥/用 LocalLLMClient
  - chinese: 承载任意 Qwen GGUF;中文取决于模型
  - mlx_support: N/A(自有 GGUF 格式,与 MLX 不共享权重);官方 Apple XCFramework 可 Swift 直接集成;LocalLLMClient 提供 GGUF+MLX 双后端 Swift 包
  - iphone15pm_8gb_feasible: 可行,是稳健 fallback(项目 D 系列已列 llama.swift/llamafile 为备)。iPhone17Pro 实测 Qwen3.5-2B Q4_K_M decode 39.1 tok/s(比MLX慢)但 prefill 2503 tok/s(远超MLX 249)。8GB 上 Q4_K_M 3B-4B 是公认 sweet spot 20-30 tok/s。内存常比 MLX 低(部分模型)但 decode 慢
  - freshness_heat: ggml-org/llama.cpp 极活跃+顶级 star;跨平台第一选择。活跃✓人气✓
  - classic_issues: ①decode 比 MLX 慢 1.4-1.8x(2026 早期 mlx-swift-lm Qwen kernel 更新后'llama.cpp Metal 小模型always赢'已不成立)。②长上下文/跨平台才是其强项,纯 iPhone 小模型 decode 不如 MLX。③需自己管内存桥接
  - vs_1_7b_evidence: 框架层:vs mlx-swift 是 decode 更慢、prefill 更快、GBNF FC 链路更成熟、跨平台。作为 LLMBackend 备选合理(项目已列),但主线 demo(短指令车控,decode 体感为王)mlx-swift 更优。判定 mixed = 各有胜场,非主选
  - source_url: https://github.com/ggml-org/llama.cpp
- **MLC-LLM (TVM 编译 + iOS Swift SDK)** (size=框架;Qwen GGUF→MLC 格式, release_date=活跃(22.1k★,iOS 指南 2026-03 更新,nightly 频更), architecture=TVM 编译 kernel + paged KV cache;Metal 后端, vs_1_7b=worse)
  - fc_benchmark: FC 支持弱于 llama.cpp GBNF/mlx tools;无现成 iOS Qwen tool-call 蓝本
  - chinese: 支持 Qwen(WebLLM 同组织);中文取决于模型
  - mlx_support: N/A(自有 MLC 编译格式)
  - iphone15pm_8gb_feasible: 技术可行但工程不划算。iOS 构建依赖 nightly wheel + TVM 编译链 + MetalToolchain + git-lfs,链路最重。强项是超长上下文(64-128k,paged KV)——但 demo 车控短指令用不上
  - freshness_heat: 22.1k★活跃,但 iOS 端工程链最复杂
  - classic_issues: ①iOS Qwen 内存高于模型本身(#3083 iPhone13Pro qwen2.5-3B,已closed=VRAM估算/context配置)。②TVM 编译每模型要重新 build,换 LoRA 权重成本高。③超长上下文才是 sweet spot,与 demo 短指令场景错配
  - vs_1_7b_evidence: 框架层 vs mlx-swift:iOS 工程链最重、换权重成本高、FC 蓝本缺、强项(长上下文)与 demo 错配。对 solo demo + 频繁换 LoRA 权重,明确劣于 mlx-swift。drop
  - source_url: https://github.com/mlc-ai/mlc-llm
- **CoreML / ANE (Apple Neural Engine,via ANEMLL / CoreML-LLM)** (size=框架;Qwen→CoreML chunked-static, release_date=活跃(CoreML-LLM by john-rocky,2026;Anemll 活跃), architecture=ANE 静态 shape only;Core AI(WWDC2026)自动 static→ANE/dynamic→GPU 路由, vs_1_7b=worse)
  - fc_benchmark: 无成熟端侧 FC 链路;CoreML 隐藏硬件无低层控制
  - chinese: ANEMLL 支持 Qwen2.5/3(0.6B-8B);中文取决于模型
  - mlx_support: N/A(CoreML mlmodelc 格式)
  - iphone15pm_8gb_feasible: 内存上诱人但转换工程地狱。bench 实测 Qwen3.5-2B 仅 241MB(MLX 1/5)+ 持续负载不热降频(GPU runtime 60s 内掉50%+,ANE 几乎不动)——这两点对 demo 连续语音极诱人。但 decode 最慢(2B 27.9 tok/s)
  - freshness_heat: 活跃但 niche
  - classic_issues: ①转换极难:静态 shape only、无原生 KV cache、Qwen3.5 GDN 混合架构(cumsum/while_loop)ANE 编译器啃不动、concat 直接编译失败(Orion 研究)。②自训 LoRA 权重要重走痛苦转换链,LoRA 适配器难融。③decode 最慢,首版 demo 反应速度差。④无低层 dispatch/fusion 控制,速度有硬天花板
  - vs_1_7b_evidence: 框架层 vs mlx-swift:内存/持续负载省(241MB+不热降频)是真优势,但①Qwen+LoRA 转 CoreML 是工程地狱②decode 最慢伤 demo 体感③换权重成本极高。对要频繁换 LoRA + 要反应快的 demo,drop;仅记为'若未来内存/续航成致命瓶颈再评估的逃生口'
  - source_url: https://github.com/john-rocky/apple-silicon-llm-bench

### tigers (坑点)
- [HIGH] 现有所有 iPhone 实测数字都是 iPhone 17 Pro(A19 Pro / 12GB),不是磊哥的 15PM(A17 Pro / 8GB);直接拿 61 tok/s / 1279MB 当 15PM 数据会高估
  - 证据: apple-silicon-llm-bench RESULTS.md Coverage snapshot 仅含 'iPhone 17 Pro, Mac M4 Max';devices/iphone-15-pro.md 标 'Results: TBD'。A17 比 A19 内存带宽低、8GB 比 12GB jetsam 上限低。须自己在 15PM 上跑 spike 实测(repo 的 iOS BenchmarkApp 可直接复用 + MemoryMonitor 用 phys_footprint=jetsam 实际依据)
  - 缓解: P1-B Qwen spike 必须在磊哥真机 15PM 实测 TTFT/decode tok/s/phys_footprint,不引用 17Pro 数。adopt repo 的 ios/BenchmarkApp(MLX/llama.cpp 双 runtime + phys_footprint 内存计 + ThermalMonitor)作 spike harness 骨架
- [HIGH] KV cache 无界增长 → iOS jetsam 在 8GB 机直接杀进程(不是普通 crash,signal 抓不到)
  - 证据: MLX 8B+10k prompt 实测占 26GB(预期5GB);mlx-lm #883 macOS kernel panic 同源;iOS 无 entitlement per-app 上限约 ~RAM 一半(8GB→~3-4GB,无 entitlement 历史近 2GB),Increased Memory Limit entitlement 才放宽。home-llm teardown 的有界 KV(MAX_ITER=0 单发)正好对症
  - 缓解: ①加 com.apple.developer.kernel.increased-memory-limit entitlement(内部 demo 侧载不走 App Store,规避'App Store 环境 entitlement 失效'坑)②bound max-kv-size + 单发约束(home-llm MAX_TOOL_CALL_ITERATIONS=0,demo 单跳 FC 天然契合)③用 os_proc_available_memory 运行时探测
- [MEDIUM] MLX 峰值内存并非总比 llama.cpp 低,个别模型反常高 12x
  - 证据: bench 实测 Gemma4-E2B short-chat:MLX 峰值 3094MB vs llama.cpp 253MB(同模型同任务差12x);但 Qwen3.5-2B 反过来 MLX 1279MB < llama.cpp 1479MB。说明内存优劣 model-specific,不能一概而论
  - 缓解: 选定的具体模型(Qwen3-1.7B-4bit)必须在 15PM 实测峰值内存,不外推其他模型;Qwen 系在 bench 中 MLX 内存表现好(规避了 Gemma 那种反常)
- [MEDIUM] GPU runtime(MLX/llama.cpp)持续负载热降频掉 50-60%,demo 连续多轮语音可能越说越慢
  - 证据: bench: 'GPU runtimes heat up and shed ~50-60% throughput under sustained load within ~60s, ANE barely moves';demo 现场客户连续说多轮 = sustained 场景
  - 缓解: ①demo 单跳 FC + 短输出(128 tok)单轮负载低,未必触发持续热降频②iPhone sustained 行 repo 还没采,须 spike 实测连续 N 轮 decode 衰减③真触发瓶颈再评估 ANE 逃生口(但有转换地狱代价)
- [MEDIUM] 小模型 MLX tool-call parser 配置错 → 加载成功但首次 tool call 时 JSONDecodeError 崩
  - 证据: 实测案例:模型加载正常,tool call 瞬间 server 崩 JSONDecodeError;修复=改 cached tokenizer config 切 parser,且删模型重下要重做
  - 缓解: 项目用受限解码(outlines/GBNF/home-llm output.gbnf 三层防御解析 fuzzy_json+双schema)绕开依赖模型自带 parser;确认 Qwen3-1.7B chat_template 的 tool parser;parser config 纳入 manifest 固化
- [LOW] CoreML/ANE 的内存优势(241MB)+不热降频 诱使选 ANE,但 Qwen+LoRA 转 CoreML 是工程地狱(paper-tiger:看着省内存,实际不可行)
  - 证据: ANE 静态 shape only/无原生 KV cache/Qwen3.5 GDN cumsum+while_loop ANE 编译器啃不动/concat 直接编译失败(Orion);CoreML-LLM 刚把 Qwen3.5-0.8B 上 ANE=前沿非成熟;自训 LoRA 权重要重走转换链
  - 缓解: 明确 drop ANE 作主线,仅记逃生口;主线守 mlx-swift。1.7B 权重~1GB 在 8GB 机本就宽裕,无需为省内存付 ANE 转换代价

### adopt 候选
- [adopt] **apple-silicon-llm-bench ios/BenchmarkApp (多 runtime iOS harness)** — 已封装 MLX/llama.cpp/CoreML/LiteRT/ExecuTorch 多 runtime + phys_footprint(jetsam 实际依据)内存计 + ThermalMonitor + EnergyMonitor + ANEResidency,正是 P1-B Qwen 15PM 真机 spike 缺的 harness 骨架;直接复用比自搭省一周 (https://github.com/john-rocky/apple-silicon-llm-bench 36★/66 commits/数天前更新,活跃✓)
- [adopt] **MemoryMonitor phys_footprint 法** — 用 task_vm_info 的 phys_footprint(jetsam 真正看的数)而非 resident_size 测峰值内存,是 8GB 机'fits vs jetsam'唯一诚实指标;直接抄进 spike (https://github.com/john-rocky/apple-silicon-llm-bench 同上)
- [adapt] **MLX-Outil (Qwen3-1.7B iOS tool-call 蓝本)** — Qwen3-1.7B + mlx-swift 跨 iOS/macOS/visionOS tool-call 现成 demo(WeatherKit/HealthKit/Calendar/搜索),项目 base 正是 1.7B,可移植其 MLXTools 工具注册+FC 调用结构,车控 mock tool 替换其工具 (https://github.com/rudrankriyam/MLX-Outil 90★,2026-01 更新(略旧,验证 3.x 兼容))
- [adopt] **mlx-swift-lm ChatSession.tools (PR #107)** — 官方 FC 入口,项目 spike-e3 已集成 3.31.3;主线 FC 走这条,叠 LoRA + 防御解析 (https://github.com/ml-explore/mlx-swift-lm 2.6k★,2026-06 活跃✓)
- [adapt] **llama.cpp autoparser + GBNF (受限 FC)** — common/chat-auto-parser-generator.cpp 自动从 chat_template 生成 tool-call GBNF + trigger token 门控,工程最成熟的端侧受限 FC;作 fallback 后端或受限解码思路来源(mlx 端暂无 GBNF) (https://github.com/ggml-org/llama.cpp 极活跃✓)
- [drop] **CoreML/ANE (ANEMLL/CoreML-LLM)** — 内存省(241MB)+持续负载不热降频是真优势,但 Qwen+LoRA 转 CoreML 静态 shape/GDN/concat 编译地狱 + decode 最慢伤 demo 体感 + 换权重成本极高;仅记逃生口非主线 (https://github.com/Anemll/Anemll 活跃但 niche)
- [drop] **MLC-LLM** — iOS 工程链最重(TVM 编译+nightly)、换 LoRA 权重成本高、FC 蓝本缺、强项(长上下文)与 demo 短指令错配 (https://github.com/mlc-ai/mlc-llm 22.1k★活跃但错配场景)

### grill 议题
- P1-B Qwen spike 要不要直接 adopt apple-silicon-llm-bench 的 ios/BenchmarkApp(已含 MLX+llama.cpp 双 runtime + phys_footprint jetsam 内存计 + ThermalMonitor)作骨架,在磊哥 15PM 真机一次跑出 Qwen3-1.7B vs 候选的 TTFT/decode/峰值内存/持续衰减?(省自己搭 harness)
- mlx-swift 主线已定,llama.cpp/GGUF 作 LLMBackend fallback 要不要现在就保留抽象口(项目 D 系列已列 llama.swift/llamafile),还是等 mlx 端真撞墙再接?
- 受限解码(防 tool parser 崩 + 保 FC 格式)走 mlx 端哪条:mlx-swift 暂无 GBNF,要么靠 LoRA 训格式+JSON 防御解析(home-llm output.gbnf 思路移植),要么 llama.cpp 端用现成 GBNF——是否把'受限解码可用性'也列进 P1-B spike 验收项?


# 04 运行时与模型路线复核

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

## 总体判断

当前最稳路线：

> 自建 `LLMBackend` 协议 + MLX Swift LM + Qwen3-1.7B-4bit 作为 MVP 默认候选；Qwen3-0.6B-4bit 作为轻量 fallback；llama.cpp/llamafile 作为 Mac 开发期 server 和基准；Foundation Models 作为系统 baseline/逃生口，不进入 LoRA 主线。

这不是最终拍板。最终要由磊哥自己的目标 Mac 和目标 iPhone 的 benchmark 决定。

边界：这里的工具调用只驱动 mock 车控状态和演示 UI，不连接真实车辆。

## 一手源与本地源码证据

### Qwen3

Qwen3 官方技术报告列出 dense 模型包括 0.6B、1.7B、4B 等。arXiv 技术报告第 2 页写明 Qwen3 系列包括 6 个 dense 模型，含 Qwen3-0.6B 和 Qwen3-1.7B。Hugging Face 的 Qwen3-1.7B model card 写明参数量 1.7B、context length 32768，并强调 agent capability 和 multilingual support。

Qwen 官方 function calling 文档说明 function calling 的本质是应用提供函数集合、模型选择函数并给出参数、应用执行并把结果回传；工具参数建议用 JSON Schema 描述。它还写明 Qwen-Agent 是 Qwen3 function calling 的 canonical implementation。

这些支持“Qwen3 有工具调用潜力”，但不支持“mock 车控 function calling 已经稳定可用”。MAformac 要自己做 schema、候选工具收窄、错误枚举和 eval。

### MLX Swift LM

本地 `mlx-swift-lm` 的 `Package.swift` 写明：

- Swift tools version 6.1
- macOS 14
- iOS 17

见 [Package.swift](/Users/wanglei/workspace/MAformac/referencerepo/repos/ml-explore__mlx-swift-lm/Package.swift:1)。

本地 `LLMModelFactory.swift` 已列：

- `mlx-community/Qwen3-0.6B-4bit`
- `mlx-community/Qwen3-1.7B-4bit`
- `mlx-community/Qwen3-4B-4bit`

见 [LLMModelFactory.swift](/Users/wanglei/workspace/MAformac/referencerepo/repos/ml-explore__mlx-swift-lm/Libraries/MLXLLM/LLMModelFactory.swift:217)。

结论：MLX Swift LM 是 Apple-only 运行时主候选成立，但仍需实测目标设备内存、热量、加载时间和结构化输出成功率。

### LocalLLMClient

LocalLLMClient README 写明它支持 GGUF、MLX models、FoundationModels framework，支持 streaming，tool calling 是 experimental：[README.md](/Users/wanglei/workspace/MAformac/referencerepo/repos/tattn__LocalLLMClient/README.md:37)。它还提示较大模型可能需要 `com.apple.developer.kernel.increased-memory-limit` entitlement：[README.md](/Users/wanglei/workspace/MAformac/referencerepo/repos/tattn__LocalLLMClient/README.md:31)。

结论：它很适合作 facade 参考，但不要把 MAformac 的核心协议锁死在它的 experimental API 上。

### Foundation Models

Apple WWDC25 说明 Foundation Models framework 支持 guided generation、tool calling、stateful session。Apple 还说明本地模型约 3B 参数、2-bit 量化，适合摘要、抽取、分类等 device-scale 任务，不适合 world knowledge 或 advanced reasoning。WWDC “Deep dive” 明确 guided generation 能让输出匹配 schema，tool calling 可让模型访问应用工具。

系统门槛也很硬：

- Apple Newsroom 写 framework 可用于 iOS 26、iPadOS 26、macOS 26，并要求 Apple Intelligence-compatible device 和 Apple Intelligence enabled。
- LocalLLMClient 源码以 `@available(iOS 26.0, macOS 26.0, *)` 包住 FoundationModels backend：[FoundationModelsClient.swift](/Users/wanglei/workspace/MAformac/referencerepo/repos/tattn__LocalLLMClient/Sources/LocalLLMClientFoundationModels/FoundationModelsClient.swift:5)。

结论：Foundation Models 可做 baseline/逃生口，但不可微调，不可控，不适合 LoRA 主线。

## 路线矩阵

| 路线 | 推荐角色 | 优点 | 风险 |
|---|---|---|---|
| MLX Swift LM + Qwen3-1.7B-4bit | MVP 默认候选 | Apple-native、Swift 集成顺、本地 registry 已有 | 真机内存、热量、TTFT、工具调用准确率待测 |
| MLX Swift LM + Qwen3-0.6B-4bit | 轻量 fallback | 更省资源，适合老设备 | 多意图、模糊跨域、参数准确率更弱 |
| llama.cpp/llamafile server | Mac 第一刀和基准 | 快速验证 prompt/schema，不被 iOS 打包卡住 | 不是最终手机体验 |
| llama.swift / LocalLLMClient llama backend | iOS fallback | GGUF 生态稳 | C++/XCFramework/包体/内存管理复杂 |
| Foundation Models | 系统 baseline/逃生口 | 零模型包体、系统 tool calling、guided generation | iOS/macOS 26 和 Apple Intelligence 门槛；黑盒、不可 LoRA |

## 必跑 benchmark

第一轮只测 1.7B 和 0.6B，不测 4B。每条都在磊哥自己的 Mac 和目标 iPhone 上记录：

- 模型加载成功率
- 冷启动时间
- 首 token 时间（TTFT）
- tokens/s
- 峰值内存
- 10 分钟连续运行热稳定
- 结构化 JSON 可解析率
- 工具名准确率
- 槽位准确率
- 整句帧准确率
- 闲聊误吸率
- 多意图顺序准确率

## 第一刀建议

不要先练 LoRA。先跑：

```text
文本输入
  -> FastPath 规则
  -> LLMBackend 候选模型
  -> ToolCall[] JSON
  -> ToolCallDecoder
  -> DemoGuard
  -> DemoActionExecutor
  -> DemoVehicleStateStore
  -> Trace
```

当 base 1.7B 在 100-200 条 mock 车控 eval 上出现稳定瓶颈，并且瓶颈是“模糊说到跨域动作映射”，再进入 MLX-LM LoRA。不要把标准命令拿去训练；标准命令走规则。

## 决策建议

写进项目决策时，不要写“主力已定”，写：

> D-runtime-candidate：MVP 默认候选为 MLX Swift LM + Qwen3-1.7B-4bit；0.6B-4bit 为轻量 fallback；Foundation Models 为 iOS/macOS 26 系统 baseline；最终以 `runtime_benchmark_v0` 结果拍板。

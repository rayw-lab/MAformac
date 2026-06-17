# 06 项目组织推进方式

## 问题判断

verdict=clear：MAformac 现在还不是一个成型软件项目，只是一个刚建立的项目文件夹，加上一批参考 repo 和调研文档。后续 PRD、SRD、系统代码架构、spec、contracts、评测合同都还没有定。如果马上写 Swift app，短期会快，几天后会在能力命名、schema、模型路线、UI 状态、测试口径上反复返工。

但也不应该套企业级流程。它是 Master Agent for Mac，个人自用、装在自己 Mac/iPhone 上、给客户演示方案能力的 demo，文档要轻、要能直接驱动代码。后续所有 PRD/SRD/spec 都必须守住：不真实上车、不接 CAN/ECU/OBD、不做量产座舱、不做客户侧运行产品。

## 建议的项目状态机

```text
S0 资料堆
  -> S1 建项包
  -> S2 契约样板
  -> S3 文本闭环
  -> S4 语音闭环
  -> S5 个人真机演示包
```

每个状态的过门条件：

| 状态 | 目标 | 过门条件 |
|---|---|---|
| S0 资料堆 | 当前状态 | 38 repo 和调研文档已落地，但没有产品/系统/代码合同 |
| S1 建项包 | 确定为什么做、做什么、不做什么 | PRD v0、SRD v0、架构草图、decisions、roadmap、risk register |
| S2 契约样板 | 防止功能清单漂移 | 5-10 条 `capabilities.yaml` 样板 + 生成 `tool_schemas.json` |
| S3 文本闭环 | 证明 Agent 主链路可跑 | 文本输入 -> ToolCall -> mock state -> UI card -> trace |
| S4 语音闭环 | 证明离线语音可用 | Push-to-talk + ASR + 规则/模型 + TTS/文字反馈 |
| S5 个人真机演示包 | 证明磊哥自己的手机能装能跑 | 磊哥自己的 iPhone，演示集全过，失败优雅降级 |

## 最小文档体系

建议只建 8 个核心文件，不要先铺 30 个模板。

```text
docs/project/00-north-star.md
docs/product/prd-v0.md
docs/system/srd-v0.md
docs/architecture/architecture-v0.md
docs/architecture/adr/
docs/roadmap.md
docs/decisions.md
docs/risks.md
```

### PRD v0

只回答产品层问题：

- 谁用：磊哥本人、方案经理现场演示。
- 场景：客户现场 5 分钟离线 demo。
- 第一屏：车控状态卡片 + 语音按钮 + 文本输入 + trace/debug。
- 首版功能：空调、座椅、车窗、灯光。
- 明确不做：真车控制、联网地图/音乐/外卖、完整 MCP、完整 KUKSA、账号系统、客户侧交付、企业安全体系。
- 成功标准：固定演示集 10-15 条稳定通过，现场断网可跑。

### SRD v0

只回答系统应该有什么能力：

- `SpeechRecognizer`
- `FastPathIntentParser`
- `LLMBackend`
- `ToolCallDecoder`
- `DialogueState`
- `DemoGuard`
- `DemoActionExecutor`
- `DemoVehicleStateStore`
- `TraceLogger`
- `CapabilityRegistry`

SRD 不写 SwiftUI 细节，也不写模型 prompt 文案。它定义系统责任边界。

### Architecture v0

只画主链路和模块边界：

```text
App UI
  -> InputController
  -> IntentResolver
      -> FastPath
      -> LLMBackend
  -> ToolCallDecoder
  -> Planner
  -> DemoGuard
  -> DemoActionExecutor
  -> DemoVehicleStateStore
  -> TraceLogger
```

架构文档要明确：SwiftUI 不直接改 demo 状态；模型不直接执行动作；demo 风控不是 prompt。

### ADR

架构决策记录只记录需要长期复用的拍板。第一批 ADR 建议：

```text
ADR-0001-app-scope-offline-demo.md
ADR-0002-llmbackend-abstraction.md
ADR-0003-capabilities-yaml-as-source.md
ADR-0004-no-real-vehicle-control-in-v0.md
ADR-0005-fastpath-before-llm.md
ADR-0006-action-receipt-status-model.md
```

## 建议目录结构

```text
MAformac/
├── docs/
│   ├── project/
│   ├── product/
│   ├── system/
│   ├── architecture/
│   ├── generated/
│   └── second-review-2026-06-17/
├── contracts/
│   ├── capabilities.yaml
│   └── generated/
├── resources/
│   └── intents/zh-CN/
├── dev/
│   ├── eval/
│   ├── scripts/
│   └── runtime/
├── referencerepo/
│   ├── repos/
│   ├── reports/
│   └── snapshots/
└── app/                         # 后续 Xcode/Swift package 落这里或根目录另定
```

`referencerepo` 继续作为 reference，不复制代码进主项目。真正要进 App 的依赖必须经过单独 ADR。

## 推进节奏

### 第 0 步：先把项目变成可治理项目

当前目录不是 git 仓库。建议先拍板：

- 要不要 `git init`
- Xcode 工程放根目录还是 `app/`
- `referencerepo/` 是否加入 git ignore 或只保留 snapshots/reports

我的建议：

- `referencerepo/repos` 不进主 git，太大且是外部代码。
- `referencerepo/reports`、`referencerepo/snapshots` 可进 git，作为研究证据。
- 项目代码和 contracts 从一开始进 git。

### 第 1 步：建项包

先写 6 个短文档，每个控制在 1-3 页：

1. north-star
2. PRD v0
3. SRD v0
4. architecture v0
5. decisions
6. roadmap

完成状态叫 `state=candidate`，不要写“最终版”。

### 第 2 步：能力样板

写 5-10 条 `contracts/capabilities.yaml`，只覆盖温度、座椅、车窗、灯光。不要导入全部功能清单。

验收：

- 每条有 risk level
- 每条有 mock behavior
- 每条有中文样例
- 每条有 tool schema
- 每条有 eval case

### 第 3 步：文本闭环

不用 ASR，不用 LoRA，不用 MCP。只做文本输入和 mock state。

验收：

- 规则命中一条
- 模糊意图一条
- 多意图一条
- 拒识一条
- trace 可见

## 文档和代码的关系

不能让文档停在“好看”。每个文档必须有下游消费者：

| 文档 | 下游消费者 |
|---|---|
| PRD | UI 范围、演示脚本、验收集 |
| SRD | 模块接口、测试切分 |
| Architecture | Swift package/目录结构 |
| ADR | 后续不反复争论同一决策 |
| capabilities.yaml | tool schema、Swift enum、eval、UI 卡片 |
| roadmap | 每阶段验收，不当进度幻觉 |

## 风险

1. 过度文档化：如果 PRD/SRD 变成几十页，项目会停在纸面。
2. 过早编码：如果没有 capability 样板和 receipt 状态，SwiftUI 会把业务写散。
3. 过早微调：没有 eval 合同和 trace，LoRA 无法证明净增益。
4. 过早接 KUKSA：它不服务近端 demo，首版只保留为参考；没有 `DemoActionExecutor` 合同前不讨论接入。

## 默认建议

先做 3 天建项冲刺：

- Day 1：PRD/SRD/Architecture v0，各 1-3 页。
- Day 2：`capabilities.yaml` 8 条样板 + `tool_schemas.json` 手工生成样例。
- Day 3：文本闭环 spike 的接口和 Xcode 骨架。

这比直接写完整 App 慢半天，但能少返工一周。

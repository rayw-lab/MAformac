# 07 修正后的路线图与拍板清单

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

## 当前状态

state=S0 资料堆。

范围锁定：MAformac 是 Master Agent for Mac，个人自用、客户演示用、离线端侧 demo。路线图只收敛到 mock 车控状态和演示闭环，不扩展到真实车机、真车控制、量产座舱或客户侧运行产品。

已有：

- 38 个 reference repo
- 7 份 repo 调研报告
- v0.1 技术基座
- v0.2 补充篇
- integration blueprint
- 本次二次审计包

未有：

- PRD
- SRD
- 架构 spec
- ADR
- `capabilities.yaml`
- Xcode/Swift 代码骨架
- eval 合同
- 模型 benchmark

## 修正后的近端路线

### Phase 0：建项包，1-2 天

目标：把项目从资料堆变成可执行项目。

产物：

- `docs/project/00-north-star.md`
- `docs/product/prd-v0.md`
- `docs/system/srd-v0.md`
- `docs/architecture/architecture-v0.md`
- `docs/decisions.md`
- `docs/roadmap.md`

验收：

- 首版明确只做 macOS/iOS 离线 mock demo，运行在磊哥自己的 Mac/iPhone。
- 明确不做真车控制、CAN/ECU/OBD、量产座舱和客户侧运行产品。
- 明确第一屏形态。
- 明确模型路线只是 candidate。

### Phase 1：能力契约样板，2-3 天

目标：用少量能力建立正确维护方式。

产物：

- `contracts/capabilities.yaml`，8 条样板
- `contracts/generated/tool_schemas.json`
- `dev/eval/generated/eval_cases.jsonl`
- `resources/intents/zh-CN/hvac.yaml` 等最小规则语料

验收：

- 每条 capability 有演示风险等级、mock 行为、中文样例、tool schema、eval case。
- 能从同一份源派生 tool schema 和评测样例。
- 没有 `tools.json`、`tool_schemas.json`、`capabilities.yaml` 三套人工源并存。

### Phase 2：文本闭环 spike，3-5 天

目标：证明核心 Agent 链路可跑。

范围：

- macOS SwiftUI 或 Swift command app
- 文本输入
- mock UI state
- 规则快路径
- 一个 LLM 慢路径，可以先接 Mac server
- ToolCall decoder
- DemoGuard
- DemoActionExecutor
- Trace panel

不做：

- ASR
- TTS
- LoRA
- KUKSA
- MCP
- 任何真实车机链路

验收：

- “打开空调”走规则快路径。
- “我有点冷”走慢路径并读 mock state。
- “把空调调到 25 度，再开座椅加热”输出两个工具调用。
- “把副驾窗开到 50%”进入确认态，demo 只更新 UI 状态。
- trace 可完整回放。

### Phase 3：runtime benchmark，2-4 天

目标：用数据拍模型主线。

候选：

- MLX Swift LM + Qwen3-1.7B-4bit
- MLX Swift LM + Qwen3-0.6B-4bit
- llama.cpp/llamafile server
- Foundation Models baseline，若设备满足 iOS/macOS 26 条件

指标：

- 加载成功
- TTFT
- tokens/s
- 峰值内存
- 10 分钟热稳定
- JSON 可解析率
- 工具名准确率
- 槽位准确率
- 整句帧准确率
- 误吸率

验收：

- 1.7B 和 0.6B 至少在 Mac 上跑完同一套 eval。
- 真机上能跑哪个写哪个，不用主观猜。

### Phase 4：语音闭环，3-5 天

目标：从文本 demo 升级到离线语音 demo。

候选：

- WhisperKit 主候选
- Apple Speech 备选
- sherpa-onnx 二期对照

验收：

- 50 条中文 mock 车控短句 ASR 评测。
- 数字、温度、主驾/副驾、百分比单独统计。
- ASR 原文、归一化文本、NLU 输出、执行 trace 分开落盘。

### Phase 5：iOS 个人真机演示包，1 周

目标：自己手机可装，可断网演示。

验收：

- 固定演示集 10-15 条全过。
- 错误状态不冒充成功。
- 断网可跑。
- UI 卡片变化明显。
- 失败可解释。

## 需要磊哥拍板的 8 个问题

1. 项目是否现在 `git init`，以及 `referencerepo/repos` 是否排除出 git。
2. Xcode 工程放根目录还是 `app/`。
3. Phase 1 是否先做 `capabilities.yaml` 样板，而不是先写 SwiftUI。
4. MVP 默认模型候选是否改成 Qwen3-1.7B-4bit，0.6B 作为 fallback。
5. Foundation Models 是否只作为 baseline/逃生口，不作为主线。
6. KUKSA 是否只保留为远期对照，不进入 Phase 0-5。
7. 第一版功能域是否只做空调、座椅、车窗、灯光。
8. must-pass 演示集规模是否先定 15 条，而不是 25+。

## 我的默认拍板建议

1. 立即进入 Phase 0，不再继续泛泛调研。
2. `capabilities.yaml` 先做 8 条样板，不导入全量清单。
3. 第一刀走文本闭环，不走 ASR。
4. 运行时默认候选写 1.7B，但不承诺，等 benchmark。
5. `referencerepo/repos` 作为 reference 留本地，不纳入主项目版本管理。
6. 先实现内存 mock；KUKSA 不进入首版，只有 mock demo 稳定且确有对照需求时再评估。

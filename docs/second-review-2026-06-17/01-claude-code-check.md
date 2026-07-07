# 01 Claude Code 结论二次校准

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

## 校准结论

verdict=clear_with_scope_notes。

Claude Code 的大方向成立，而且应作为本轮 MAformac 的主基座：38 个参考 repo 不应该都进 App；真正的核心差异化也不是“能跑一个模型”，而是车控能力目录、规则快路径、demo 风控链路和可回归评测。它把 Canals、KUKSA、VSS/vss-tools、hassil、MLX Swift、LocalLLMClient、BFCL/tiny-tool-bench 等肩膀拼成端侧 demo 的方向是对的。

本文件定位是补三类落盘边界，避免后续读者把“方案演示 demo”误读成真实车机项目：

1. “D1-D37 全锁”如果已在深聊中拍板，需要同步回落盘文档；当前仓库文档仍写 D20/D30/D35/D37 待磊哥拍板。
2. “Qwen3-1.7B demo 主力”和“Qwen3-0.6B + LoRA 主线”在现有文档中要统一成 candidate/fallback 口径。
3. `capabilities.yaml` 是 P1 核心契约资产，这个判断成立；下一步执行顺序要写清楚：建项包、能力样板、文本闭环三者如何衔接。

## 逐条复核

| Claude Code 断言 | 二次判断 | 证据 |
|---|---|---|
| 38 个 repo 已深读并分类为 App runtime、Mac 开发期、只抄思路 | 基本成立 | clone 覆盖显示 38/38 已在本地：[clone_coverage.md](/Users/wanglei/workspace/MAformac/referencerepo/snapshots/clone_coverage.md:3)，repo inventory 有 HEAD 和语言统计：[repo_inventory.md](/Users/wanglei/workspace/MAformac/referencerepo/snapshots/repo_inventory.md:3)。 |
| `capabilities.yaml` 是核心资产 | 成立 | AutoWRX 报告建议抽出 `capabilities.yaml/json` 作为车设功能单一事实源：[01_vehicle_protocol_and_sdv.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/01_vehicle_protocol_and_sdv.md:95)。vss-tools 深附录也明确 `capabilities.yaml` 是源：[07_deep_appendix_to_1000.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/07_deep_appendix_to_1000.md:25)。 |
| 下一步就是开搞 `capabilities.yaml` | 方向成立，执行顺序需写清 | README 仍写“下一步候选，待磊哥定方向”，A 项名称是 `tools.json + DialogueState schema + Capability/Tool`：[README.md](/Users/wanglei/workspace/MAformac/docs/README.md:37)。research archive 还写 P0 是依赖/hello-world JSON，P1 才协议+数据：[research-archive-2026-06-17.md](/Users/wanglei/workspace/MAformac/docs/research-archive-2026-06-17.md:111)。 |
| D1-D37 全锁 | 需要同步落盘 | README 明确写“已锁定 33”和“待磊哥拍 4”：D20、D30、D35、D37：[README.md](/Users/wanglei/workspace/MAformac/docs/README.md:16)。如果这些在深聊后已经拍板，应该更新 `docs/decisions.md` 或现有 README。 |
| Qwen3-1.7B 是 demo 主力 | 候选成立，未完成拍板 | integration blueprint 写 1.7B 主力：[integration-blueprint.md](/Users/wanglei/workspace/MAformac/docs/integration-blueprint.md:23)，但 README 和 v0.1 仍写 0.6B + LoRA 主线：[README.md](/Users/wanglei/workspace/MAformac/docs/README.md:27)，[tech-baseline-from-raw.md](/Users/wanglei/workspace/MAformac/docs/tech-baseline-from-raw.md:12)。 |
| Canals 抽三抽象，不照搬全栈 | 成立 | Canals 报告建议只抽 `VehicleStateStore`、`VehicleActionExecutor`、`AgentTrace`：[01_vehicle_protocol_and_sdv.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/01_vehicle_protocol_and_sdv.md:3)。落到 MAformac 时建议命名为 `DemoVehicleStateStore`、`DemoActionExecutor`、`AgentTrace`。Canals README 同时显示它有 AWS Bedrock、MongoDB、FastAPI、Astro 等全栈依赖：[README.md](/Users/wanglei/workspace/MAformac/referencerepo/repos/Bosch-Connected-Experience-26__Canals/README.md:7)，所以只借架构是正确边界。 |
| KUKSA Databroker 提级为 Mac 开发期动作验收环境 | 作为远期对照成立 | integration blueprint 已修正为 B 类开发期工具：[integration-blueprint.md](/Users/wanglei/workspace/MAformac/docs/integration-blueprint.md:204)。KUKSA README 说明 providers 负责连接 broker 与真实车辆侧数据/动作来源：[README.md](/Users/wanglei/workspace/MAformac/referencerepo/repos/eclipse-kuksa__kuksa-databroker/README.md:79)。对 MAformac 首版，它应作为边界注记和远期对照，不进入近端 demo runtime。 |
| Foundation Models 可以作为 baseline | 成立，但有硬门槛 | Apple Newsroom 写 Foundation Models framework 可用于 iOS 26、iPadOS 26、macOS 26 且要求 Apple Intelligence-compatible device 和 Apple Intelligence enabled。LocalLLMClient 源码也以 `@available(iOS 26.0, macOS 26.0, *)` 包住 Foundation Models backend：[FoundationModelsClient.swift](/Users/wanglei/workspace/MAformac/referencerepo/repos/tattn__LocalLLMClient/Sources/LocalLLMClientFoundationModels/FoundationModelsClient.swift:5)。 |

## 发现的冲突

### 1. 模型主线冲突

当前文档同时存在两条主线：

- 0.6B 主线：README 写“主线模型 = Qwen3-0.6B + LoRA”，v0.1 也以 0.6B 为项目定义。
- 1.7B 主线：integration blueprint 写 demo 主力 Qwen3-1.7B，0.6B 备选。

建议统一成：

> MVP 默认候选 = Qwen3-1.7B-4bit；轻量 fallback = Qwen3-0.6B-4bit；最终由磊哥自己的 iPhone 和 Mac benchmark、mock 车控 function calling 准确率、峰值内存和热稳定决定。

### 2. 契约文件命名冲突

当前材料里出现过：

- `tools.json`
- `capabilities.yaml`
- `capabilities.yaml/json`
- `vehicle_capabilities.json`
- `tool_schemas.json`
- `vss_paths.yaml`
- `eval_cases.jsonl`

建议收敛成：

- 唯一源：`contracts/capabilities.yaml`
- 生成物：`contracts/generated/tool_schemas.json`、`Sources/MAformacCore/Generated/VehicleCapability.swift`、`docs/generated/ability_table.md`、`dev/eval/generated/eval_cases.jsonl`
- 可选输入：`resources/intents/zh-CN/*.yaml`，作为规则快路径语料源，不与能力源互相替代

### 3. “第一刀”顺序冲突

一条路线主张先跑 runtime hello-world 和文本闭环；另一条路线主张先敲能力目录。二次判断：

- 如果目标是最快看到 App 动起来：先做文本到 mock 车控闭环。
- 如果目标是防止 100+ 功能清单后续失控：先做 `capabilities.yaml` 样板。
- 最稳组合是两天内同时收敛：Day 1 落 5 条温度/座椅/车窗能力样板；Day 2 用这些样板生成最小 `tool_schemas.json`，跑文本闭环。

## 修订版主判断

1. `capabilities.yaml` 是项目的 P1 核心契约资产，不是普通配置文件。
2. 第一刀不应上完整语音、不应上 LoRA、不应接真实车机链路、不应接 KUKSA。
3. 第一刀应跑通：文本输入 -> 快路径命中或 LLM 输出 -> schema 校验 -> `DemoActionExecutor` -> mock state -> UI 卡片变化 -> trace。
4. 运行时先用 Mac server 或 MLX Swift 跑通同一套 `ToolCall[]` 合同，不把业务层写死到任一模型。
5. 项目当前还没 PRD/SRD/spec/代码架构，下一阶段先补“轻量项目操作系统”，再开始大规模写 Swift。

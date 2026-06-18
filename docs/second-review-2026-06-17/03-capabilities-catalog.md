# 03 `capabilities.yaml` 能力目录设计

> ⚠️ **已 SUPERSEDED** by `contracts/capabilities.yaml`(2026-06-18 change2 定稿,8 条 `cabin.*` 能力)。本文是历史候选设计,不再维护;实际契约以 `capabilities.yaml` 为准。

## 判断

`capabilities.yaml` 应成为 MAformac 的单一事实源，但它现在还不是事实，只是强候选设计。当前仓库没有这个文件，也没有生成物。下一步如果选择“敲核心契约”，应该先做 5-10 条温度/座椅/车窗样板，而不是一口气导入全部功能清单。

本文只讨论个人自用和客户演示 demo 的能力目录。`capabilities.yaml` 管的是 mock 卡片、mock 状态、演示 trace 和工具 schema，不是接真实车辆。

## 为什么它是核心资产

本项目的问题不是“如何把一句话发给模型”，而是“很多 mock 车控车设功能如何长期保持一致”。一个功能会同时影响：

- UI 卡片
- 语音别名和模板
- function calling 工具 schema
- 参数范围和 enum
- 演示风险等级和确认策略
- VSS 或扩展路径
- mock 行为
- 评测样例
- LoRA/few-shot 数据

这些如果分散维护，很快会漂移。VSS/vss-tools、AutoWRX、BFCL/tiny-tool-bench、instructor/outlines 的共同意见都指向一件事：先把能力合同写成结构化资产。

本地证据：

- VSS 报告建议第一版建立 `VehicleCapability` 表，字段含 `vss_path`、可读可写、值类型、安全等级、中文别名：[01_vehicle_protocol_and_sdv.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/01_vehicle_protocol_and_sdv.md:43)。落到 MAformac 时应理解为 `DemoVehicleCapability` 的参考字段。
- vss-tools 报告建议把 `.vspec` 转成 app 可消费 JSON/schema/Swift 枚举：[01_vehicle_protocol_and_sdv.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/01_vehicle_protocol_and_sdv.md:53)。
- AutoWRX 报告明确建议抽出 `capabilities.yaml/json` 作为单一事实源：[01_vehicle_protocol_and_sdv.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/01_vehicle_protocol_and_sdv.md:93)。
- deep appendix 写明 `capabilities.yaml` 是源，生成 `VehicleCapability.swift` 和 `tool_schemas.json`，首版只做 20-50 高频能力：[07_deep_appendix_to_1000.md](/Users/wanglei/workspace/MAformac/referencerepo/reports/07_deep_appendix_to_1000.md:25)。
- integration blueprint 已把这个思路吸收为 `capabilities.yaml -> VehicleCapability.swift + tool_schemas.json + 能力表.md`：[integration-blueprint.md](/Users/wanglei/workspace/MAformac/docs/integration-blueprint.md:213)。

## 命名收敛

建议固定：

```text
contracts/capabilities.yaml                 # 唯一人工维护源
contracts/generated/tool_schemas.json        # 给模型/运行时看的工具 schema
Sources/MAformacCore/Generated/DemoVehicleCapability.swift
docs/generated/ability_table.md              # 给人审和演示准备看的能力表
dev/eval/generated/eval_cases.jsonl          # 由能力样板派生的基础评测
resources/intents/zh-CN/*.yaml               # 规则快路径语料，和 capability 双向引用
```

`tools.json` 不再作为人工主源。它可以作为生成物，或者在过渡期保留为 `tool_schemas.json` 的旧名。

## 最小 schema 草案

```yaml
schema_version: "0.1"
capabilities:
  - id: cabin.hvac.set_temperature
    status: draft

    product:
      display_name_zh: "调节空调温度"
      display_name_en: "Set HVAC temperature"
      domain: demo_car_control
      category: hvac
      ui_group: comfort
      ui_card: hvac_temperature

    language:
      aliases_zh: ["空调温度", "车内温度", "温度"]
      intent_ids: ["set_hvac_temperature", "adjust_hvac_temperature"]
      phrase_templates:
        - "空调调到{temperature}度"
        - "把车里调暖一点"
      negative_examples:
        - "今天气温多少"

    tool:
      name: set_hvac_temperature
      operation: SET
      arguments_schema:
        type: object
        required: ["zone", "target_celsius"]
        properties:
          zone:
            type: string
            enum: ["driver", "passenger", "rear", "all"]
          target_celsius:
            type: number
            minimum: 16
            maximum: 30
      output_schema:
        type: object
        required: ["receipt_id", "status"]

    reference_binding:
      readable: true
      writable: true
      vss_path: "Vehicle.Cabin.HVAC.Station.Row1.Driver.Temperature"
      extension_path: null
      read_signals:
        - "Vehicle.Cabin.HVAC.Station.Row1.Driver.Temperature"
      mock_write_signals:
        - "Vehicle.Cabin.HVAC.Station.Row1.Driver.Temperature"
      value_type: number
      unit: celsius

    execution:
      connector: mock
      executor: DemoActionExecutor
      mock_behavior: immediate_actual_update
      state_dependencies:
        - current_temperature
        - power_state
      idempotent: true
      exclusive_bus: hvac
      latency_budget_ms: 100

    demo_guard:
      risk_level: R0
      requires_confirm: false
      confirm_policy: direct
      block_rules: []
      environment_preconditions:
        - demo_power_on
      permissions:
        - presenter

    response:
      tts_template: "已帮你把空调调到{target_celsius}度"
      gui_template: "空调 {target_celsius}°C"

    eval:
      generated_cases: true
      must_pass: true
      error_tags:
        - slot_out_of_range
        - wrong_zone
        - false_trigger

    source_refs:
      - "COVESA VSS"
      - "讯飞车控清单:待映射"
```

## 生成器职责

第一版生成器不用复杂，只要能做四件事：

1. 校验重复 `id`、重复 tool name、缺演示风险等级、缺中文别名、缺 mock 行为。
2. 生成 `tool_schemas.json`，供 LLMBackend 和 Mac server 使用。
3. 生成 `DemoVehicleCapability.swift`，供 Swift 侧 enum/struct 使用。
4. 生成基础 eval case，至少覆盖 happy path、参数边界、拒识、澄清。

## 与规则快路径的关系

`capabilities.yaml` 不替代 `hassil` 风格语料。正确关系是：

- capability 定义“demo 能展示什么、参数是什么、演示风险是什么、怎么更新 mock 状态”。
- intents YAML 定义“用户可能怎么说”。
- 规则 parser 从 intents YAML 命中 capability id。
- 模型慢路径也只能输出 capability id 和受约束参数。

## 首批样板建议

先做 8 条，不要超过 10 条：

1. 空调温度设置
2. 空调温度升高/降低
3. 座椅加热开关/档位
4. 座椅通风开关/档位
5. 主驾/副驾车窗开合百分比
6. 阅读灯开关
7. 风量档位
8. 查询当前舒适状态

这些能力足够覆盖：

- 明确命令：空调调到 24 度
- 模糊意图：我有点冷
- 单句多意图：把空调调到 25 度，再开座椅加热
- 需要确认：副驾窗开一半，demo 只更新 UI 状态
- 状态依赖：已经开了座椅加热时不要重复执行

## 风险

1. 过早做完整 schema 会拖慢 App 原型。控制在 5-10 条样板。
2. 如果能力目录字段过少，后续 UI、eval、LoRA 仍会漂移。
3. 如果 VSS 绑定过硬，磊哥自己的功能清单会无法落位。必须支持 `extension_path`。
4. 如果 `capabilities.yaml` 不生成实际代码和测试，它会沦为文档。

## 建议拍板

`capabilities.yaml` 作为 P1 核心契约资产，先做样板，再做生成器，再扩全量。不要先导入全部功能清单。

## Why

`contracts/capabilities.yaml` 是 MAformac 的**唯一契约源**——模型 prompt / 规则快路径 / UI 卡片 / eval fixture / LoRA 训练数据 / trace schema 皆从它派生。当前三处 schema 草案(`docs/repo-intelligence/2026-06-17-gitnexus/03-openspec-input.md`、Codex `03-capabilities-catalog`、`tech-baseline §4.1`)字段不一致,若不定稿会「一物多名」漂移。本 change 三合一定稿 schema,并建立 8 条 MVP 车控能力样板。

## What Changes

- **三合一定稿 capabilities.yaml schema**(字段权威化,三处 draft 标 superseded)。
- **定义 8 条 MVP 车控能力**(覆盖 5 幕,id 见 design):`cabin.ac`(空调:开关 + 温度 + 升降温)/ `cabin.seat_heating` / `cabin.seat_ventilation` / `cabin.window` / `cabin.ambient_light`(氛围灯)/ `cabin.screen_brightness`(屏幕亮度)/ `cabin.fan` / `cabin.comfort_query`。(降噪 = 车机 ECNR 底层自动,非 agent capability,不入清单。)
- **建立「一处定义、多处生成」规则**:capabilities.yaml(源)→ Swift 类型 / tool schema / UI 卡片数据 / eval fixture / LoRA 数据 / trace schema(派生物)。
- **cell schema 8 字段**(对齐 demo-mvp-contract:key / actualValue / desiredValue / availability / timestamp / source / revision / visualState)。
- 每条能力含:`id` / `status` / 中文别名(口语变体)/ `tool_schema` / `reference_binding`(VSS path 可选)/ `execution`(mock 行为 / 状态依赖 / 幂等 / 互斥 bus)/ `demo_guard`(风险 / 确认 / 范围枚举 / 前置)/ `response` 模板 / `eval_refs`。

## Capabilities

### New Capabilities
- `vehicle-capabilities`: 8 条 MVP 车控能力的行为契约 + `capabilities.yaml` 单一事实源规则(schema、派生物、防漂移、别名归一)。

### Modified Capabilities
(无)

## Non-goals

- ❌ 二期 domain 的 capability(导航 / 音乐 / 外卖——仅车控 8 条;二期 agent 在 agents.yaml 占位)。
- ❌ 生成器代码实现(本 change 定 schema + 8 条数据;派生 Swift 类型 / tool schema 的生成器代码留后续 change / tasks)。
- ❌ 真实座舱数据入仓(别名 / 说法仅本地脱敏抽象,真实车型 / 客户值不写)。
- ❌ `reference_binding`(VSS path)强制(MVP 可选,不阻塞)。

## Success Criteria(可验收)

- capabilities.yaml 一份权威定稿,三处历史 draft 标注 `superseded`。
- 8 条能力字段齐全(上列 9 类字段),yaml 合法可解析。
- 每条能力可派生:tool schema(给 ToolCallDecoder)+ UI 卡片数据(给 MasterShell)+ eval fixture refs。
- 别名覆盖口语变体(如「座椅通风 / 散热座椅 / 空调座椅」归一),防 ASR / 归一化漏召回。
- 危险 / 越界能力标注 `demo_guard`(风险等级 + 确认策略 + 范围枚举)。

## Impact

- 充实 demo-mvp-contract 建的 `contracts/capabilities.yaml` 占位(从 1 样例 → 8 条 + 定稿 schema)。
- 下游依赖:`define-execution-contract`(ToolCallFrame 校验对齐 capability schema)/ `define-voice-contract`(热词 + 归一化别名来自 capability aliases)/ `define-lora-pipeline`(训练数据 expected_tool_call 引 capability id)/ `define-vehicle-tool-bench`(eval fixture 引 capability)。

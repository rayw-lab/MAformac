> 范围:本 change 定 `contracts/capabilities.yaml` 的**定稿 schema + 8 条车控能力数据**;生成器代码(派生 Swift 类型 / tool schema)留后续 change。前置:demo-mvp-contract 已建 capabilities.yaml 占位。**8 capability 清单已终拍(2026-06-18;降噪 = 车机 ECNR 底层功能,非 agent capability,不入清单)**。

## 1. schema 定稿

- [x] 1.1 在 `contracts/capabilities.yaml` 写定稿 schema(按 design schema 表 10 类字段 + 注释)。验收:yaml 合法 + 字段齐(id/status/display_zh/aliases/tool_schema/reference_binding/execution/demo_guard/response/eval_refs)。
- [x] 1.2 三处历史 draft(GitNexus `03-openspec-input` / Codex `03-capabilities-catalog` / `tech-baseline §4.1`)标 `superseded` + 指向 capabilities.yaml。验收:三处均有 superseded 标注。

## 2. 8 条车控能力数据(覆盖 5 幕)

- [x] 2.1 `cabin.ac`(空调:开关 + 温度 16–30 + 升降温;别名 冷气/暖风/制冷/制热;demo_guard 范围 16–30;readback 模板)。验收:可派生 tool schema。
- [x] 2.2 `cabin.seat_heating`(座椅加热 0–3 挡;别名 暖座/座垫加热)。
- [x] 2.3 `cabin.seat_ventilation`(0–3 挡;别名 散热座椅/空调座椅/座椅风扇)。
- [x] 2.4 `cabin.window`(车窗 0–100%;别名 窗户/玻璃;槽 position 全车位枚举)。
- [x] 2.5 `cabin.ambient_light`(氛围灯 开关 + 颜色枚举;别名 氛围灯/车内灯)。
- [x] 2.6 `cabin.screen_brightness`(屏幕亮度 0–100%;别名 屏幕/亮度/调暗)。
- [x] 2.7 `cabin.fan`(风量 0–N 挡;别名 风速/风量/吹风)。
- [x] 2.8 `cabin.comfort_query`(舒适状态查询,只读;别名 现在几度/什么状态)。
- 每条验收:9 类字段齐 + 别名覆盖口语变体 + demo_guard 声明范围/枚举 + readback 模板。

## 3. agents.yaml 引用对齐

- [x] 3.1 车控 agent 通过 capability id 引用上述 8 条(不重复定义);导航/音乐/外卖 `connector: mock` + `enabled: false` + `availability: planned` 占位。验收:agent 只引 id;二期标 planned。

## 4. 验证与脱敏

- [x] 4.1 yaml schema 校验:每条能力可派生 tool schema + UI 卡片数据 + eval fixture refs。验收:校验脚本通过。
- [x] 4.2 脱敏检查:别名 / 说法无真实车型(如 T19CFL)/ 客户名 / PII。验收:脱敏 validator(fail-closed)通过。**叠加 Superpowers: verification**。

## 5. 与 change1 占位漂移对齐(pre-mortem 收敛,2026-06-18)

> 本 change 必须回改 change1 占位 Swift(非纯 yaml)——8 能力的 cell 落点与 change1 占位 store 不一致。**arguments→JSONValue 不在本 change**(pre-mortem 判 HIGH no-go,留 change3 随 adopt mlx 上游一次 typealias 切换;详 design Risks)。

- [x] 5.1 回改 `Core/State/DemoVehicleStateStore.swift` 的 `defaultCells`:cell 集对齐 8 能力——补 `screen_brightness` + `seat_ventilation`,去 `fragrance.level` + `sunroof.state`;`capabilities.yaml` 每条 `execution.state_cell` 指向真实存在的信号层 cell key。验收:8 能力的 `state_cell` 全部可在 store 命中(无悬空引用)。
- [x] 5.2 `DemoVisualState` 枚举改名:`idle/active/pending/failed/disabled/planned/unknown` → `normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown`(占位直写,派生语义 = ThreeStateEngine 留 change3);同步改引用处 `App/ContentView.swift:122,126` + `applyMockTransition` + `Tests/MAformacCoreTests/WalkingSkeletonTests.swift:22`。验收:`swift test` 全绿 + macOS build 成功。
- [x] 5.3 漂移对齐回归守护:grep 仓内无 fixture/golden 用旧 visualState case 字面量(`idle`/`active` 等);改完冻结新枚举名(S3 落盘前不再动)。验收:grep 0 命中旧字面量 + `swift test` 不回归(introduced=0)。**叠加 Superpowers: verification**。

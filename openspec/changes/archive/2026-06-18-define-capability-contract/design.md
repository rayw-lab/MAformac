## Context

`contracts/capabilities.yaml` 是 MAformac 唯一契约源。三处历史 draft(`docs/repo-intelligence/2026-06-17-gitnexus/03-openspec-input.md` / Codex `03-capabilities-catalog` / `tech-baseline §4.1`)字段不一致,需定稿。本 change 定 schema + 8 条数据契约,**并回改 change1 占位实装以消除漂移**(store cell 集 + visualState 枚举命名)——`capabilities.yaml` 的 8 能力与 change1 占位 store 的 cell 集不一致(占位有香氛/天窗,终拍是屏幕亮度/座椅通风),`execution.state_cell` 无处可指,故本 change **必须动 change1 Swift 占位**(非纯 yaml)。依赖 demo-mvp-contract 已建的 capabilities.yaml + store 占位。

> **pre-mortem 收敛(2026-06-18)**:`arguments [String:String]→[String:JSONValue]` 经 pre-mortem 判 **HIGH no-go**,留 change3(详 Risks)——上游 `MLXLMCommon.JSONValue` 不可单独 import(强制拖入整个 mlx-swift Metal 张量栈 + swift-syntax),提前做会绑死未经 E3 spike 验证的 adopt 路径。

## Goals / Non-Goals

**Goals:** schema 三合一定稿;8 capability 覆盖 5 幕;一处定义多处生成;别名归一;demo_guard 声明;capability ⊥ agent 分层;**对齐 change1 占位漂移(store cell 集 + visualState 枚举改名)**。
**Non-Goals:** 生成器代码实现;二期 domain;真实数据入仓;VSS 强制;**arguments→JSONValue(pre-mortem HIGH,留 change3 随 adopt mlx 上游一次 typealias 切换)**。

## Decisions

### capabilities.yaml schema(三合一定稿)

每条 capability 字段:

| 字段 | 说明 | 派生到 |
|---|---|---|
| `id` | kebab-case 唯一(如 `cabin.ac`) | 全部 |
| `status` | active / planned | registry |
| `display_zh` | 中文显示名 | UI 卡片 |
| `aliases` | 口语变体 [] | 归一化层 + ASR 热词 |
| `tool_schema` | name / description / parameters(JSON Schema) | ToolCallDecoder |
| `reference_binding` | vss_path? / readable / writable / type / unit / allowed_values | 开发期对照(MVP 可选) |
| `execution` | mock_behavior / state_cell / idempotent / exclusive_bus | DemoActionExecutor |
| `demo_guard` | risk_level / confirm_policy / range / enum / preconditions | DemoGuard |
| `response` | readback 播报模板 | TTS |
| `eval_refs` | fixture id [] | vehicle-tool-bench |

### cell schema(state cell,8 字段,对齐 demo-mvp-contract)

`key / actualValue / desiredValue? / availability / timestamp / source / revision / visualState`

`visualState` 枚举:`normal / satisfied / changing / blocked_with_alternative / blocked_hard / unsafe / unknown`(由 ThreeStateEngine + 执行进度**派生**,非独立写入源)。

### 8 capability 概要(覆盖 5 幕;2026-06-18 终拍)

| id | 能力 | 槽位 / 范围 | 服务幕 |
|---|---|---|---|
| `cabin.ac` | 空调(开关 + 温度 + 升降温) | 16–30℃ | ② 基础 / ③ 我有点冷 |
| `cabin.seat_heating` | 座椅加热 | 0–3 挡 | ③ 我有点冷 |
| `cabin.seat_ventilation` | 座椅通风(别名 散热座椅/空调座椅) | 0–3 挡 | 夏季场景 |
| `cabin.window` | 车窗百分比 | 0–100% | ② 基础 / ⑤ 给副驾开窗 |
| `cabin.ambient_light` | 氛围灯(开关 + 颜色) | 颜色枚举 | ⑤ 场景炫 |
| `cabin.screen_brightness` | 屏幕亮度 | 0–100% | ③ 我头疼(调暗) |
| `cabin.fan` | 风量挡位 | 0–N 挡 | ② 基础 |
| `cabin.comfort_query` | 舒适状态查询(只读) | — | 端状态查询 |

> **降噪 = 车机底层 ECNR(电子降噪)自动承担,非 agent capability**,不入清单;③「我头疼」话术的降噪由车机自动,demo 话术带过 / UI 不画降噪卡。

### 派生规则:一处定义、多处生成

`capabilities.yaml`(源)→ 生成 Swift 类型 / `tool_schemas.json` / UI 卡片数据 / eval fixture / LoRA 数据 / trace schema。**生成器代码留后续 change**(本 change 只定源 + 8 条数据)。

### capability ⊥ agent 分层

capability 只定义能力本身(工具 / 槽位 / mock / 安全);`agents.yaml` 仅通过 capability id 引用,不重复定义能力内容(防双源漂移)。二期 agent(导航 / 音乐 / 外卖)以 `connector: mock` + `enabled: false` + `availability: planned` 占位,不进真实路由。

### 与 change1 占位漂移对齐(pre-mortem 收敛,2026-06-18)

change1 walking skeleton 为立骨架随手铺了占位,与本 change 终拍有 3 处漂移。本 change 处理前两项,第三项经 pre-mortem 判 HIGH no-go 留 change3:

| # | 漂移 | change1 占位 | 终拍 | 本 change 动作 |
|---|---|---|---|---|
| 1 | visualState 枚举 | `idle/active/pending/failed/disabled/planned/unknown`(机械态,直写) | `normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown`(语义态) | **改 Swift 枚举名 + 占位直写**(派生语义=ThreeStateEngine 留 change3);触及 `DemoVehicleStateStore` / `App/ContentView.swift:122,126` / `WalkingSkeletonTests:22`,编译器 exhaustive 兜底 |
| 2 | store cell 集 | `hvac.ac / hvac.temperature / seat.driver.heat / window.driver / lighting.ambient / fragrance.level / fan.speed / sunroof.state` | 8 能力含 screen_brightness / seat_ventilation(无香氛/天窗) | **回改 `defaultCells`**:补 screen_brightness + seat_ventilation,去 fragrance + sunroof;capability id(`cabin.*`)经 `execution.state_cell` 映射到信号层 cell key(双层:id ≠ cell key 合理,一个能力可写多 cell) |
| 3 | arguments 类型 | `[String:String]` | `[String:JSONValue]` | **留 change3**(绑 adopt mlx 上游,pre-mortem HIGH no-go) |

时机:S2 阶段 disk 无持久化 trace(S3 才落盘),visualState 改名零迁移成本,**改完即冻结**(S3 落盘前不再动)。前置:grep 仓内无 fixture/golden 用旧 case 字面量。

## Risks / Trade-offs(pre-mortem 实证,带来源)

- [真实座舱别名 / 说法脱敏] → 别名仅抽象口语变体(来自已脱敏的 `voice-pipeline-from-raw §1` 热词表);真实车型 / 客户值不写。
- [8 条覆盖 5 幕] → 映射已核(见上表);降噪由车机 ECNR 承担、非 capability,③ 幕降噪不依赖 agent。
- [三处 draft 字段差异] → 以本 design schema 表为权威,三处标 `superseded`。
- [🔴 HIGH:arguments→JSONValue 提前做会拖入整个 MLX Metal 栈 + 绑死未 spike 路径] → 留 change3,change2 arguments 保持 `[String:String]` placeholder。证据:[mlx-swift-lm Value.swift](https://github.com/ml-explore/mlx-swift-lm/blob/main/Libraries/MLXLMCommon/Tool/Value.swift)(JSONValue 是 public 7-case,**但**)`MLXLMCommon` target 在 Package.swift 强制依赖 `MLX/MLXNN/MLXOptimizers`(mlx-swift Metal 栈)+ swift-syntax,**无零依赖 micro-product**——为 1 个 enum 拖入整个推理框架,且 change3 adopt 路径还需 E3 spike(1.7B 触发率)验证才坐实。
- [🟡 MEDIUM:visualState Codable 枚举改名是 breaking] → 趁 S2 无持久化窗口改,零迁移成本,改完冻结。证据:[Codable enum rename breaking + 缓解](https://nilcoalescing.com/blog/CodableConformanceForSwiftEnums/) / [versioned Codable](https://joro.dev/posts/versioned-codable/)。
- [动 change1 已 T-PASS 代码(introduced 风险)] → 改动限 store cell 集 + visualState 枚举名,不碰执行链;Codex 重跑 `swift test` 保不回归。

## Migration Plan

升级 change1 占位:`capabilities.yaml` 从 1 样例 → 8 条定稿;`DemoVehicleStateStore.defaultCells` cell 集对齐 8 能力(补 screen_brightness/seat_ventilation,去 fragrance/sunroof);`DemoVisualState` 枚举改名(idle/active… → normal/satisfied/…)。三处历史 draft 标 `superseded`。回滚 git revert。**arguments→JSONValue 不在本 change(留 change3 随 adopt mlx 上游)**。

## Open Questions

- `reference_binding`(VSS path)MVP 是否填(可选,不阻塞)。
- capability id(`cabin.*`)与信号层 cell key(`hvac.*` 等)的映射表是否在本 change 全列(倾向:在 `execution.state_cell` 字段逐条声明,即映射表)。

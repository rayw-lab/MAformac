# Dispatch: apply define-capability-contract(change 2 实装)

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

## 0. 路由元信息
- **TO**:Codex(长跑 TDD)
- **FROM**:Claude(CC,管前端+原型+审计;本 dispatch 是 change2 实装交接,scope 经 pre-mortem 收敛)
- **MODE / MODEL**:Codex 长跑实装 + Superpowers TDD/verification
- **PRIORITY**:P0(6-change 第 2 个;capability 定义是 change3/5/6 的硬依赖,不做下游全卡)
- **一句话 DELIVERABLE**:`contracts/capabilities.yaml` 从 1 占位样例 → **8 条 MVP 车控能力定稿 + schema 三合一权威化**,并**回改 change1 占位 Swift 消除 2 处漂移**(store cell 集 + visualState 枚举名),`openspec status` 推到 16/16。

## 1. 冷启动背景(承接方零上下文也能懂)
- **项目**:MAformac = 纯端侧 iOS/macOS 离线车控**方案演示助手**(给客户现场演示,非量产 / 非真车控)。北极星:现场 5 分钟听懂中文、反应快、不崩、看着惊艳、断网也能跑。**起手必读** `/Users/wanglei/workspace/MAformac/CLAUDE.md` → `docs/README.md` → 最近 `docs/handoffs/` → 本 dispatch。
- **本任务处于**:S2,6-change 拆法的**第 2 个** `define-capability-contract`。change1(骨架 + walking skeleton)已 15/15 all_done。
- **为什么现在做**:`capabilities.yaml` 是唯一契约源(模型 prompt / 规则 / UI / eval / LoRA 数据 / trace schema 皆派生)。8 能力定稿 + 漂移对齐后,change3(execution)/4(voice)/5(lora)/6(eval)才能往上挂。

## 2. 任务(TASK)
实装 `/Users/wanglei/workspace/MAformac/openspec/changes/define-capability-contract/tasks.md` 的 5 组 16 条 task(已 agree before build,scope 经 pre-mortem 收敛)。逐条勾选 / 完成后 `openspec status` 推到 16/16。
- **组 1 schema 定稿**(1.1–1.2):`contracts/capabilities.yaml` 写定稿 schema(10 类字段,见 design schema 表)+ 三处历史 draft 标 `superseded`。
- **组 2 8 条车控能力**(2.1–2.8):`cabin.ac` / `cabin.seat_heating` / `cabin.seat_ventilation` / `cabin.window` / `cabin.ambient_light` / `cabin.screen_brightness` / `cabin.fan` / `cabin.comfort_query`。每条 9 类字段齐 + 别名覆盖口语变体 + demo_guard 范围/枚举 + readback 模板 + `tool_schema.parameters` 用**完整 JSON Schema**(温度 int 16–30、颜色 enum 等,**数据层表达,不碰 Swift 类型**)。
- **组 3 agents.yaml 对齐**(3.1):车控 agent 只通过 capability id 引用 8 条;导航/音乐/外卖 `connector:mock`+`enabled:false`+`availability:planned` 占位。
- **组 4 验证与脱敏**(4.1–4.2):yaml 合法 + 每条可派生 tool schema/UI 卡片/eval refs;脱敏 validator(fail-closed)无真实车型/客户名/PII。
- **组 5 与 change1 占位漂移对齐**(5.1–5.3,**本 change 必动 change1 Swift**):
  - 5.1 回改 `Core/State/DemoVehicleStateStore.swift` `defaultCells`:补 `screen_brightness`+`seat_ventilation` cell,去 `fragrance.level`+`sunroof.state`;`capabilities.yaml` 每条 `execution.state_cell` 指向真实存在的信号层 cell key(无悬空)。
  - 5.2 `DemoVisualState` 枚举改名 `idle/active/pending/failed/disabled/planned/unknown` → `normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown`(占位直写,派生语义=ThreeStateEngine 留 change3);同步改 `App/ContentView.swift:122,126` + `applyMockTransition` + `Tests/MAformacCoreTests/WalkingSkeletonTests.swift:22`。
  - 5.3 grep 仓内无 fixture/golden 用旧 case 字面量;改完冻结新枚举名。

## 3. Prerequisite Check(起手必跑,验运行态)
```bash
cd /Users/wanglei/workspace/MAformac
openspec validate define-capability-contract     # 期望 valid
openspec status --change "define-capability-contract"   # 期望 0/16(snapshot 2026-06-18,以实际为准)
git status --short
swift test 2>&1 | tail -5                         # baseline:4 tests / 3 skipped / 0 fail(改 store 后须仍 0 fail)
grep -rn "fragrance\|sunroof\|\.idle\|\.active" Core App Features Tests   # 漂移对齐前先看现状
```
下文所有 hard-code 数字标 `(snapshot 2026-06-18,以上方 Check 为准)`。

## 4. 边界(CONSTRAINTS / BOUNDARIES)
- **红线**(完整见 `CLAUDE.md §6`):真实客户名一律「某车厂」;报价/密钥/PII/车型代号(如 T19CFL)**绝不入仓**;别名仅抽象口语变体(脱敏);**不降级**(Qwen3-1.7B+LoRA 主线)。
- **🔴 arguments→JSONValue 不在本 change**(pre-mortem HIGH no-go,见 design Risks):**禁止 `import MLXLMCommon` / 禁止引入 mlx-swift 任何 SPM 依赖**(会拖入整个 Metal 张量栈 + 绑死未经 E3 spike 的 adopt 路径)。`ToolCallFrame.arguments` / `ToolSchema.parameters` 的 Swift 类型升级(→`[String:JSONValue]`)**全留 change3**,本 change 保持 `[String:String]` placeholder 不动。
- **禁区**:`Core/Execution/` `Core/Routing/`(执行链/ToolCallFrame 类型留 change3);仅动 `contracts/*.yaml` + `Core/State/` + `App/ContentView.swift` + `Tests/`。
- **OUT_OF_SCOPE**:生成器代码(从 yaml 自动生成 Swift 类型,留后续 change);二期 domain capability;真实座舱数据入仓。超范围 → 返回说明 + 建议归属,**不硬扛、不顺手扩**。

## 5. 验收门
> codex-metacognition §23 三硬约束 + OpenSpec tasks 验收 + Pre-Mortem。
- 每条 task 的产出 + **可验收标准**(带证据/等级,不写「完成/OK」大词)。
- **必过门**:
  - `openspec validate define-capability-contract` 通过 + `openspec status` = 16/16。
  - yaml 合法可解析;**8 能力每条 `execution.state_cell` 在 store `defaultCells` 命中(0 悬空引用)**。
  - **`swift test` 全绿(改 change1 已 T-PASS 代码后 introduced 回归=0)** + `MAformacMac` Debug build 成功。
  - 脱敏 validator(fail-closed)通过:别名/说法 0 命中真实车型/客户名/PII。
- **smoketest 实采**(真实数据,非 mock/非 LLM 自造):用 5 幕话术的实际指令(如「打开空调」「我有点冷」「太亮了调暗点」「给副驾开窗」)逐条核 8 能力可达 + state_cell 有落点。
- **pre-mortem**:本 change 的 pre-mortem 已由 CC 跑完(scout+oracle,结论在 `design.md` Risks 段:arguments HIGH no-go / visualState 改名趁 S2 无持久化窗口 / 动 T-PASS 代码靠重跑测试守护)。**Codex 实装时若发现新 failure mode → 补 design Risks**,不静默吞。
- **failure** → 写 failure receipt(risk_state 枚举 + 实际异常),别静默吞。

## 6. 相关文件(优先读,≤5,绝对路径)
1. `/Users/wanglei/workspace/MAformac/openspec/changes/define-capability-contract/tasks.md`(主:16 task)
2. `/Users/wanglei/workspace/MAformac/openspec/changes/define-capability-contract/design.md`(schema 表 + 8 能力表 + **「与 change1 占位漂移对齐」决策表** + pre-mortem Risks)
3. `/Users/wanglei/workspace/MAformac/openspec/changes/define-capability-contract/specs/vehicle-capabilities/spec.md`(行为契约 SHALL)
4. `/Users/wanglei/workspace/MAformac/contracts/capabilities.yaml`(现状:1 占位样例,扩成 8 条)+ `Core/State/DemoVehicleStateStore.swift`(漂移对齐目标)
5. `/Users/wanglei/workspace/MAformac/CLAUDE.md`(宪法 + 边界红线)

## 7. 完成回报格式(DELIVERABLE,带 status field)
- **status**:`done` / `blocked` / `partial`
- **产出清单**:`capabilities.yaml`(8 条)+ `agents.yaml` + Swift 漂移对齐 diff + 各 task 验收结果(带证据:`openspec status` 输出 / `swift test` 结果 / 脱敏 validator 输出 / smoketest 8 能力可达清单)。
- **BLOCKED**(卡住时):`BLOCKED: <缺什么> FROM: <需谁/什么资源>`
- **关键发现 / 偏差**:分清 `introduced`(本次引入)vs `exposed`(旧债暴露)。
- **下一步建议**:change3(execution)的接入点 + arguments→JSONValue 切换的具体位置(typealias 指向 `MLXLMCommon.JSONValue`,届时才引 mlx 依赖)。

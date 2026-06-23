# A2 代码盘点 ultracode 调研归档（主线程亲核版）

> ⚠️⚠️ **口径已终拍（磊哥 2026-06-23 亲拍，finding round-03 加 banner）**：全仓权威 = **191 device / 562 intent / 2159 行（54.1%）** / 族外 **976 intent / 1831 行**。本文正文多处称「534=权威 / 562=A1-A9 前非权威」是 **A2 盘点时（2026-06-22）终拍反转前的历史定性**，仅作 A2 盘点态溯源——**A2 派单口径以 `docs/grill-tournament/grill-decisions-master.md §0 口径权威表` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md §14:224` 为准（562 = intent 非工具数；工具数待 value-form 实算）**。正文 benchmark/盘点数值保留不改（历史溯源价值），仅以本 banner 覆盖口径定性。
>
> 2026-06-22 ultracode 8 路 finder + 综合官（9 agent / 1.1M tok / 936s）。本 README = 综合官 full_report + 主线程亲核小结 + 全字段附录。各 finder 一手档见 lens1-8.md，codex 言论核见 codex-checks.md。

## 🔴 主线程亲核小结（claim-vs-reality：finder 高发编数字，主线程独立核 load-bearing）

**数字口径（python 复算坐实，A2 派单最关键）**：
- 全集 = `3990 行 / 671 device / 1538 intent`（jsonl 实跑 ✓）
- 🔴 `generated/10-family-device-map.json` = **223 device**（含 disputed，旧 codegen 口径）≠ **paradigm §14 权威 191 device**；`generated/D_domain.tools.json` = **6 工具**（spike 冻结：query_cabin_comfort/set_cabin_ac/ambient_light/fan/screen_brightness/window）
- 口径权威：**device=191**（generated 旁路 223 过期含 disputed）/ **intent=534**（562=A1-A9 前，507/680=boundary 子串口径）/ **工具数未拍待实算**（G2，col O 在 xlsx 第15列不在 jsonl）
- ⚠️ **「534」是 intent 数不是工具数**——A2 派单把 534 当工具数 = 口径错全链路

**外部 star 亲核（finder 这次诚实，全核通过）**：mlx-swift-structured 74★/2026-04-06(>60天临界) · mlx-swift 1932★ · mlx-lm 6006★ · mlx-swift-lm 679★ · xgrammar 1752★ · Sourcery 8010★

**外部 arxiv/issue# 辅证**：综合官标的 arxiv 2602.06204/2102.05201/2504.09691 + mlx issue# 为 pre-mortem 辅证，**核心决策（LR 1e-4 守、masking 实证）依据是本机实测非这些 arxiv**，故标「外部辅证待核、不阻塞决策」。

---

# A2 范式迁移全链路综合报告（C1→C2→C3→C5→C6 不对齐 + 重构范围 + 选型 + 坑点）

> ultracode 8 路 finder 综合官收敛。2026-06-22。综合官已对 load-bearing 数字/file:line 做本机亲核（见各处标注），外部 issue#/arxiv id/star **待主线程亲核**。

## 0. Executive Summary

A2 是**重型重构**——把立项至今 C1→C2→C3→C5→C6 全链路从 spike 期冻结的 generic-frame（`tool_call_frame`，模型可见面 671 device × 141 action 笛卡尔积）迁到 paradigm 翻案后的 **D-domain 具名工具范式**（value 形态编码进工具名，canonical IR 仍 device×action，「对模型像具名工具，对系统像 device×action IR」）。

5 条核心结论：
1. **不对齐是系统性的**：5 层中至少 16 处主链路点仍生成/期望 `tool_call_frame` 或硬编码 6 个 `set_cabin_*`，模型可见面/训练样本/bench 期望/用户文本风格四者全错（逐一 file:line 亲核）。
2. **数字口径必须先统一**：四版本分叉已亲核——boundary md(SOURCE1)=161/223 device·507/680 intent（子串误吸），MVP research doc=191/562/2159（A1-A9 前），**paradigm §14 权威=191 device·534 intent·2086 行**（A1-A9 后），`D_domain.tools.json`=6（spike 冻结）。🔴**「534」是 10 族 intent 数不是工具数**，G2 工具数 paradigm 明文「不拍 30-60，实算」+ col O 优先级在 xlsx 第15列不在 jsonl。派单把 534 当工具数=口径错。
3. **codegen 地基已对**：Python `gen_tool_contract.py` 单源 + Makefile `git diff --exit-code` 漂移门 + `generated/` 入仓 = 业内 hybrid 最佳实践（已核 `Makefile:51` + git-tracked）。A2 **不引入新 Swift codegen 框架**（Sourcery/SwiftSyntax 都是造第二套 SSOT 反模式），只扩 Python codegen surface。
4. **真缺口是端侧受限解码**：mlx-swift 核心栈无 GBNF 等价；唯一现成肩膀 `mlx-swift-structured`(74★, pushed 2026-04-06>60天临界淘汰) 的 TriggeredTagsFormat 正是 534 具名工具范式精确解，需 vendor C++(44K) 进仓自维护。
5. **必须 incremental**：用 C6 vehicle-tool-bench 当 golden parity gate，比**相对 A2-before 基线不退化**（禁绝对全绿，base 已 hard_fail / C5 candidate 0/34），严禁大爆炸式一刀改完。

## 1. C1→C2→C3→C5→C6 全链路不对齐总表

（见 `code_misalign_table_markdown` 字段——16 行 + 1 守现状行，每行 file:line + 现状 + 新范式 + 改动类型 + grill。全部本机亲核。）

**亲核要点**：
- `ToolContractCompiler.swift:26` = `name:.string("tool_call_frame")`（确认）；`:50` = `frameToolSchema + dDomainToolSchemas` 并挂（确认双 surface）；`:71-90` dDomainSurfaceNames 硬编码 5 个 set_cabin_* names + query_cabin_comfort（确认）。
- `C5LoRATraining.swift:2362` = `C5TrainingToolCall(name:"tool_call_frame")`（确认）；`:2408` = `tools: toolCallFrameSchema + distractors.schemas`（确认）；`:1767-1769` = `"device=\(seed.device); primitive=…; slots=…"` 协议风格（确认）。
- `C6VehicleToolBench.swift:356-387` 30 MP case 硬编 set_cabin_*（确认）；`:1038-1039` readback→hardFailed（确认）vs `scripts/_c6_axis_lib.py:11` action hard_pass 不含 readback（确认）。
- `DemoVehicleStateStore.swift:136` ac.power + `:150` hvac.ac 双轨（确认）；`FastPathIntentEngine.swift:21` state_key:"hvac.ac"（确认）。
- `B_frame.frame_schema.json` device enum=671 / action_primitive=141 / value.type=3（亲核）；`D_domain.tools.json` len=6（亲核）。

## 2. A2 范围（量级/文件数/行数/依赖序）

- **量级**：重型。改 model-visible surface 范式 = C1 编译器核心 + 训练样本 + bench 期望三处共同输入。
- **文件数**：约 14-16。复用/升级 8 + 重写 4-5 + 新建 2-3。
- **行数**：1500-2500 净改动（ToolContractCompiler ~330 重写 / C5LoRATraining ~200 / C6 ~200 / Python codegen ~200 / state-cells 6 族 ~300 / 健壮性命名 ~100），生成物 diff 另计单独 commit。
- **依赖序**：[0]统一口径(191/534/2086 + G2 实算 + col O 从 xlsx 提)→[1]扩 Python codegen 产 D-domain 目录(两层 scope,纳入漂移门)→[2]ToolContractCompiler 消费 JSON(删 frame surface+硬编码+Normalizer/StateApplier data-driven)→[3]state-cells 扩 10 族 191 device + C3 映射派生 + 命名清债→[4]C5 surface/正样本/用户文本改具名+CLI 加 scope→[5]C6 MP/coverage 改具名+readback 口径→[6]C6 parity gate 相对不退化验收。

## 3. 逐文件复用/重写/新建

（见 `reuse_rewrite_new` 字段。要点：codegen 地基/risk 设计/verify 门/rank16Mainline 配方/spike-e3 mlx pin 全部守现状不动；ToolContractCompiler 四块 + C5 三处 + C6 两处 + StateStore 双轨清债 = 重写；D-domain 目录产物 + codegen 函数 + 可选 vendor 受限解码 = 新建。）

## 4. 框架选型

（见 `framework_picks` 字段。Swift codegen=守现状扩 Python；mlx 栈=复用已 pin 最新；受限解码=vendor mlx-swift-structured C++ 自维护。star/日期 待主线程亲核。）

## 5. 硬编码避免机制

（见 `hardcode_avoidance` 字段。SSOT 单源派生 + Make drift gate（已实装）+ 显式产品决策门移除 frame surface（堵 compiler 派生≠该派生 elephant）+ spike 隔离 + Periphery 扫死代码 + 魔法数迁 training-config.yaml + source 行号锚点。）

## 6. Pre-mortem 三分类

（见 `pitfalls` 字段。tiger 8 + paper_tiger 3 + elephant 6。最高优先 tiger：大爆炸重构 / codegen 模板单点 bug + reviewer 盲区 / LR 过冲 + NaN 数据 regime / 受限解码薄壳 / 版本漂移 / scope creep / 健壮性硬伤。）

## 7. Grill 弹药（A2 派单前必拍）

（见 `grill_ammo` 字段。8 议题：534 口径锚定 / 生成物入仓两层 scope / compiler 复用边界 / 重构切刀序 / parity gate 基线 / 受限解码 adopt / 训练配方守不守 / 自然中文数据防假绿。）

## 8. Steelman 守现状（别全推翻）

A2 不是推翻一切。这些**真能复用、本机已核为正确**：
- Python codegen + Makefile 漂移门 + generated/ 入仓 = 业内最佳实践（`Makefile:19/51` 亲核）。
- risk-policy 独立不写 C1 行 = 正确设计（`risk-policy.yaml:1-5` 亲核），缺的是 θ-β 数据非架构。
- `rank16Mainline()` 配方 SSOT(C5LoRATraining:1175 工厂方法 scale20/LR1e-4/adamw) 已坐实稳，A2 不重开。
- spike-e3 已 pin mlx-swift 0.31.4 / mlx-swift-lm 3.31.3 = 最新对齐，端侧栈不动。
- C1/C2/C3/C6 archived specs 仓内 SSOT 不动，只扩派生。

## 9. 🔴 待主线程亲核清单（load-bearing 外部声称）

- mlx-swift-structured 74★ / pushed 2026-04-06（决定 adopt 形态=vendor，load-bearing）。
- arxiv 2602.06204（LoRA LR 2× 发散）/ mlx-lm #361(NaN) / mlx-examples #1313(--mask-prompt 假绿) / antlr4 #2207 / swift-protobuf #1830 / arxiv 2102.05201(70.8%) / arxiv 2504.09691(Google 迁移)。
- 数字口径 191/534/2086（paradigm §14）vs 223/507/680（boundary md）vs 562/2159（MVP doc）—— 综合官已本机亲核三源 + D_domain.tools.json=6，结论：**534=intent 非工具数，工具数 G2 未拍待实算**。这是 A2 派单最易踩的口径坑。

---

# 附录 A：完整代码不对齐表（C1→C2→C3→C5→C6）

| # | 文件 file:line | 现状（spike-frozen generic frame） | 新范式要求（D-domain 具名工具） | 改动类型 | grill |
|---|---|---|---|---|---|
| 1 | `Core/Contracts/ToolContractCompiler.swift:23-27` | `frameToolSchema` 生成 `name:"tool_call_frame"` 单工具（device 671/action 141 枚举塞进一个工具参数） | model-visible surface 改 D-domain 具名工具目录（value 形态编码进名）；generic frame 作 surface **否决** | 重写 | 生成式具名目录从 Python codegen 派生，Swift 侧消费 JSON 不重算 |
| 2 | `Core/Contracts/ToolContractCompiler.swift:48-52` | `renderedToolsText` = `frameToolSchema + dDomainToolSchemas` **并挂**（B_frame 与 D_domain 同时渲染给模型） | 只渲染 D-domain 具名工具（10 族 534 intent 对应工具集），删 frame surface | 重写 | 双 surface 长期并存是 elephant 坑：都 compiler-derived 故 drift gate 不报警「看着合规」 |
| 3 | `Core/Contracts/ToolContractCompiler.swift:71-90` | `dDomainSurfaceNames()` 硬编码 `if devices.contains("ac")…` 映射出 5 个名（set_cabin_ac/fan/window/screen_brightness/ambient_light + query_cabin_comfort） | 从 contract codegen 全量具名工具目录，废 §5 六处硬编码 if-else | 重写 | paradigm §14 A2 已拍「从 3990 codegen 具名工具目录，两层 scope full/demo」 |
| 4 | `Core/Contracts/ToolContractCompiler.swift:147-172, 288-475` | `ToolContractNormalizer`(6 hardcode case) + `ToolContractStateApplier`(8 device-specific apply 函数 applyAC/Temp/Fan/Window/Screen/AmbientColor/AmbientBrightness)，329 行核心状态逻辑 | 改为 data-driven（device-family 声明式路由 + 从 state-cells.yaml 派生 apply） | 重写（高危：runtime regression） | switch 无 default（:149-160/:304-320）未知 device 静默跳过——补 default 记日志 |
| 5 | `Core/Training/C5LoRATraining.swift:2362` | `makePositiveSample` 正样本 `C5TrainingToolCall(name:"tool_call_frame")` 写死 | 正样本工具名 = D-domain 具名工具（value 形态编码） | 重写 | 训练面 = 推理面（parity）；C5 的 0/34 灾难根因之一就在训/eval surface 异源 |
| 6 | `Core/Training/C5LoRATraining.swift:2408` | `tools: toolCallFrameSchema + distractors.schemas`（仍挂过期 frame） | tools = D-domain 具名工具集 + 同族 distractors | 重写 | distractor 策略要随具名面重设（受约束数据增广，正例语义不动） |
| 7 | `Core/Training/C5LoRATraining.swift:1767-1769` | 用户文本合成 `device=…;primitive=…;slots=…` 协议风格（非自然中文） | 自然中文话术（云 generator + 异源 judge，contract 定标签，原文 oracle）| 重写 | 这是模型混 B_frame/D_domain 的根因；训练集 0 条自然中文=北极星缺口 |
| 8 | `Tools/C5TrainingCLI/main.swift` Options(:9-72) | 无 `--scope`/`--surface`，只能读全量 C1，无法分离 demo10 vs 全量训练集 | 加 `--scope=demo`(534)/`full`(1538) + `--surface=D_domain` 参数 | 升级（加字段） | 两层 scope 派生深度不同非两套 SSOT（paradigm §14 A2 已拍） |
| 9 | `Core/Bench/C6VehicleToolBench.swift:356-387` | 30 个 MP CaseSpec 硬编 expected `set_cabin_*` 工具名 + 写死参数无 device/action_primitive 槽 | expected 改 D-domain 具名工具；从 demo-scenarios.yaml codegen | 重写 | C6 同时是 A2 的 golden parity gate——迁移前后跑同集，hard_pass 不退化 |
| 10 | `Core/Bench/C6VehicleToolBench.swift:419-420` | coverageCases 仅 7 device（ac_temperature/window/screen_brightness/atmosphere_lamp_color/brightness/ac_windspeed/car_door） | 覆盖 10 族 191 device（按 G4 explicit allowlist） | 重写/扩展 | 191 device 全覆盖才验得了范式，7 device 是 spike 残留 |
| 11 | `Core/Bench/C6VehicleToolBench.swift:1038-1039` | readback failure 记 `failures.append(.readback)` → hardFailed；但 `scripts/_c6_axis_lib.py:11` 已排除 readback（action hard_pass 不含 readback） | 评测口径与 axis_lib 对齐：readback 走方案P（renderer），不计 hard_pass | 升级（口径对齐） | C5 recovery 已拍 readback=端确定性渲染走 P，删 eval 计 hard_pass（gold :865 不改） |
| 12 | `Core/State/DemoVehicleStateStore.swift:136 + :150` | `ac.power`（新）与 `hvac.ac`（旧）双轨共存；:163-169 switch 无 default | 统一到 state-cells.yaml 权威命名（ac.power），删 hvac.ac 旧轨 | 重写（清债） | 跨层命名不一致（state key ac.power / device enum ac / tool set_cabin_ac）映射易漏 |
| 13 | `Core/Intent/FastPathIntentEngine.swift:21` | 「打开空调」写 `state_key:"hvac.ac"`（旧 device） | 改 `ac.power`（state-cells.yaml 权威） | 升级 | fast-path L1 降级路径，但反映 device 命名权威未内化运行时 |
| 14 | `contracts/state-cells.yaml:30-152` | 仅定义 4 设备（ac/window/screen/ambient_light）+ safety，缺座椅/车门/音量/雨刮/天窗/香氛（10 族还差 6 族） | 补齐 10 族 device 的 state cell（codegen 自 contract 191 device） | 新建/扩展 | 10 族 191 device 要落 state cell 才能 mock 端态闭环 |
| 15 | `Core/Execution/C3ExecutionPipeline.swift:156-176` | `executionCellID()` switch 硬编码 device→cell + default 返 nil（调用方 :135 throw） | 从 state-cells.yaml::execution_range_cell 派生映射 | 升级（去硬编码） | 现已有 allowlist.entry 优先路径，switch 是兜底硬编码债，扩 10 族会膨胀 |
| 16 | `Core/Bench/C5DataGate.swift:502-510` + `Core/Contracts/ContractLookups.swift:60-68` + `C6VehicleToolBench.swift:276-281` | JSONL decode 用 `try?` 吞异常 / `.map{try decode}` 一行失败全失败 / 循环无 per-line catch | per-line error collection + 日志，不静默吞 | 升级（健壮性） | 负向 test 缺口（unknown device/格式错 error path 无覆盖）= elephant |
| — | `contracts/risk-policy.yaml:1-5` + `Core/Execution/C3ExecutionPipeline.swift:94-103` | risk 独立不写 C1 行（C1 risk 字段全空）+ code safety gate 评估 | **无需改**——「risk 挂 C1 行」设想已被否决，当前设计正确 | 不改（steelman 守现状） | 缺的是 θ-β safety_refusal 训练数据，非架构改 |

# 附录 B：A2 范围

```json
{
  "magnitude": "重型（heavy-tier）。理由：A2 改的是 model-visible surface 范式（generic frame→D-domain 具名工具），它是 C1 契约编译器的核心 + 训练样本生成 + bench 期望三处的共同输入，连带 state cells/执行映射/命名清债。ToolContractCompiler 的 Normalizer(142行)+StateApplier(187行)=329 行核心状态逻辑要 data-driven 重写；C5LoRATraining 2481 行里 surface/正样本/用户文本三处要改；C6 30 个 MP case + coverage 全重写。属 paradigm §14 已拍的「立项至今大部分代码改」量级，不是补丁。",
  "files_count": "约 14-16 个文件。复用/升级(8): C5TrainingCLI/main.swift(加 scope 字段)、FastPathIntentEngine.swift(改命名)、C3ExecutionPipeline.swift(去硬编码映射)、C6 readback 口径、C5DataGate/ContractLookups/C6 decode 健壮性、state-cells.yaml(扩 6 族)。重写(4-5): ToolContractCompiler.swift(frameToolSchema/renderedToolsText/dDomainSurfaceNames/Normalizer/StateApplier)、C5LoRATraining.swift(surface+正样本+用户文本)、C6VehicleToolBench.swift(MP case+coverage)、DemoVehicleStateStore.swift(去 hvac.ac 双轨)。新建(2-3): scripts/gen_tool_contract.py 扩 D-domain 具名目录(两层 scope)、generated/ 新增具名工具目录产物、(可选)vendor mlx-swift-structured C++ 受限解码。",
  "lines_estimate": "粗估 1500-2500 行净改动（含 codegen 脚本扩展 + Swift 消费侧重写 + state cells 6 族扩 + C6 case 重写）。其中 ToolContractCompiler ~330 行重写、C5LoRATraining ~3 处约 200 行、C6 ~30 case 约 200 行、Python codegen 扩 ~200 行、state-cells 6 族 ~300 行 yaml、健壮性/命名 ~100 行。生成物 diff 另计（generated/ 重生成可能上千行机械变更，须单独 commit）。",
  "dep_graph": "严格依赖序（违反=返工）：[0] 先统一数字口径（191/534/2086 锚定 paradigm §14，G2 工具数实算+col O 从 raw xlsx 提取）→ [1] 扩 Python gen_tool_contract.py 产 D-domain 具名工具目录（两层 scope，generated/ 入仓 + Makefile 漂移门纳入）→ [2] ToolContractCompiler.swift 改为消费 generated JSON（删 frameTool surface + 硬编码 + Normalizer/StateApplier data-driven）→ [3] state-cells.yaml 扩 10 族 191 device + C3 执行映射派生 + 命名清债（hvac.ac→ac.power）→ [4] C5LoRATraining surface/正样本/用户文本改具名 + CLI 加 scope（依赖 [1] 目录）→ [5] C6 MP case/coverage 改具名 expected + readback 口径对齐（依赖 [1][3]）→ [6] C6 当 golden parity gate 跑相对 A2-before 不退化验收。[0] 不先做=口径错全链路；[1] 不先做=Swift 侧无源可消费；[2][3] 是 [4][5] 的前置。",
  "is_heavy": true
}
```


# 附录 C：复用/重写/新建三分类

逐文件三分类（steelman 守现状：codegen 地基/risk 设计/verify 门别推翻）：

【复用-升级（地基对，小改）】
- `scripts/gen_tool_contract.py` + `Makefile`(verify→regen→git diff --exit-code) + `generated/` 入仓 = 业内 hybrid 最佳实践，**地基不动**，只扩 codegen surface（A2 派生 D-domain 具名目录纳入 GENERATED_CONTRACTS 漂移门）。
- `Tools/C5TrainingCLI/main.swift` Options：加 `--scope=demo/full` + `--surface` 字段（升级，非重写）。
- `Core/Intent/FastPathIntentEngine.swift:21`：hvac.ac→ac.power 命名修（升级）。
- `Core/Execution/C3ExecutionPipeline.swift:156-176`：executionCellID switch 硬编码→从 state-cells.yaml 派生（升级，已有 allowlist.entry 优先路径可复用）。
- `Core/Bench/C5DataGate.swift:502` / `ContractLookups.swift:60` / `C6VehicleToolBench.swift:276`：decode per-line error 收集（健壮性升级）。
- `contracts/state-cells.yaml`：扩 6 族（升级，结构不变）。
- `Core/Bench/C6VehicleToolBench.swift:1038-1039`：readback 口径对齐 axis_lib（口径升级，删计 hard_pass）。
- 🔴 `Core/Training/C5LoRATraining.swift:1175 rank16Mainline()`（配方 SSOT 工厂方法，scale20/LR1e-4/adamw 已坐实稳）= **复用不动**，A2 不重开 LR/adamw/B1；只改 surface/正样本/用户文本三处。
- 🔴 端侧 spike-e3 已 pin mlx-swift 0.31.4 / mlx-swift-lm 3.31.3（最新对齐）= **复用不动**。

【重写】
- `Core/Contracts/ToolContractCompiler.swift`：frameToolSchema(:23) / renderedToolsText(:48 删并挂) / dDomainSurfaceNames(:71 删硬编码) / Normalizer(:147) / StateApplier(:288) → data-driven 消费 generated JSON。
- `Core/Training/C5LoRATraining.swift`：3 处（:2362 正样本工具名、:2408 tools schema、:1767 用户文本风格）改 D-domain 具名 + 自然中文。
- `Core/Bench/C6VehicleToolBench.swift:356-387`：30 MP case expected 改具名 + :419 coverage 扩 191 device。
- `Core/State/DemoVehicleStateStore.swift:136/150`：删 hvac.ac 旧轨，统一 ac.power。

【新建】
- `generated/` 新增 D-domain 具名工具目录产物（两层 scope）。
- `scripts/gen_tool_contract.py` 内新增 D-domain 目录生成函数（intent→tool名 + value 形态编码 + arg enum + domain→sg→tool 三级）。
- （可选/受限解码缺口）vendor `petrukha-ivan/mlx-swift-structured` 的 XGrammar C++(44K) 进仓 ref-repos→自维护 module，挂端侧 mlx-swift-lm。

【不改（守现状）】
- `contracts/risk-policy.yaml`（risk 独立设计正确，缺的是 θ-β 数据非架构）。
- C1/C2 archived specs（仓内 SSOT 不动，只扩派生）。

# 附录 D：框架选型

【Swift codegen 选型（L6）——结论：不引入新框架，扩现有 Python codegen】
- ⭐ **守现状 = MAformac 自有 Python gen_tool_contract.py + Makefile git diff 漂移门**（已是业内推荐 hybrid，无 star 但 ground-truth 已核：generated/ git-tracked + Makefile:51 git diff --exit-code）。引入 Swift codegen 框架=造第二套 SSOT，违 §4 契约单源。
- Sourcery `krzysztofzablocki/Sourcery` 8010★ / pushed 2026-06-11（近2月活跃）https://github.com/krzysztofzablocki/Sourcery — **drop**：吃 Swift AST 不吃 jsonl，输入形态不匹配。
- SwiftSyntax `swiftlang/swift-syntax` 3671★ / pushed 2026-06-17 https://github.com/swiftlang/swift-syntax — **drop**：能 jsonl→Swift 源码但多此一举（Python 已生成 JSON，Swift Codable 解码即可）。
- swift-openapi-generator `apple/swift-openapi-generator` 1934★ / pushed 2026-06-22 https://github.com/apple/swift-openapi-generator — **范式参考不 adopt**：build plugin 有 IDE 不识别/sandbox 摩擦；OpenAPI≠tool-call 契约。
- gyb / Swift Macros — **drop**（gyb 非官方工具链；又一 Python 模板层）。

【mlx 栈（L7）——版本已对齐，复用不动】
- mlx-lm（Python，C5 本机训练后端）`ml-explore/mlx-lm` 6006★ / pushed 2026-06-12 / release v0.31.3(2026-04-22) https://github.com/ml-explore/mlx-lm — **复用**（训练栈）。
- mlx-swift `ml-explore/mlx-swift` 1932★ / pushed 2026-06-17 / release 0.31.4(2026-06-01) https://github.com/ml-explore/mlx-swift — **复用**（spike-e3 已 pin 0.31.4）。
- mlx-swift-lm `ml-explore/mlx-swift-lm` 679★ / commit 2026-06-21 / tag 3.31.3 https://github.com/ml-explore/mlx-swift-lm — **复用**（spike-e3 已 pin 3.31.3；端侧推理 + ToolCallFormat 11 种，base Qwen3→.json）。
- mlx-tune `ARahim3/mlx-tune` 1318★ / pushed 2026-05-31 — **参考**（grad-checkpoint 接入 trainer 解 OOM）。

【端侧受限解码（真缺口）——adopt 但 vendor 自维护】
- ⭐ **mlx-swift-structured** `petrukha-ivan/mlx-swift-structured` 74★ / pushed 2026-04-06（🔴>60天，磊哥新鲜度门临界淘汰区）https://github.com/petrukha-ivan/mlx-swift-structured — TriggeredTagsFormat 是 534 具名工具范式精确解（Aho-Corasick DFA 多工具同时匹配 + schema 100% accuracy 对小模型增益大）；vendored XGrammar C++ 仅 44K/4 cpp，iOS 可编译，Apache-2.0。**adopt 形态 = vendor C++ 进仓自维护**（因 Swift 绑定层单人 74★ 临界新鲜度 + 依赖 swift-json-schema 0★）。
- 上游 XGrammar `mlc-ai/xgrammar` 1752★ / pushed 2026-06-11（活跃）https://github.com/mlc-ai/xgrammar — 底层成熟，XGrammar-2 schema accuracy→100%。
- 🔴 home-llm output.gbnf 路线 = llama.cpp 专属，**不可移植 mlx-swift**。
🔴 待主线程亲核：mlx-swift-structured 74★/pushed 2026-04-06 是 finder gh api 数（决定 adopt 形态=vendor 而非 SPM 依赖，load-bearing）。

# 附录 E：硬编码避免机制

防 spike scaffolding 再固化的机制（L5 业内 SSOT codegen + verify 门 + 本机已落地实况）：

【1. SSOT codegen 单源派生（业内主流 2026 共识，MAformac 已对）】
- 单一 schema/contract 作权威源派生一切（工具枚举/value 约束/arg schema/校验），生成物 ≠ 手写第二套。MAformac contracts/semantic-function-contract.jsonl → gen_tool_contract.py → generated/*.json 正是此形态。
- 🔴「手写第二套必漂移」是业内实证 bug（TypeORM #11735 / OpenAPI-Generator #5024 / Prisma #3010 重复生成 enum）。对 MAformac：A2 的 ToolContractCompiler.swift 当前是与 Python 重复的手写编译器（双源风险），A2 必须改为 Swift 消费 generated JSON 不重算。
- 校验逻辑也别重复（protovalidate 1519★ 示范）：value 四件套/range 约束进 contract SSOT 派生，别在 Swift runtime 手写第二套 range check。

【2. CI/Make drift gate（MAformac 已实装，业内标准配方）】
- 配方 = regenerate + `git diff --exit-code`（committed 生成物与重生成不一致则 build fail）。本机已核 Makefile:19 verify→regen→verify-refs→verify-cross-section→diff:51 git diff --exit-code，generated/ + contracts/*.jsonl 均 git-tracked = 业内 hybrid 最佳实践（commit 生成物可 review diff + CI 兜底防 stale）。
- A2 动作：新增 D-domain 具名目录产物必须纳入 GENERATED_CONTRACTS 漂移门，否则新硬编码会逃过 gate。

【3. 显式产品决策门（堵 elephant：compiler 派生 ≠ 该派生）】
- 🔴 现状真风险：frameToolSchema 与 dDomainToolSchemas 都从同一 compiler 派生且并挂 renderedToolsText（:48），范式翻案后 generic frame 是债，但因也是 compiler-derived，drift gate 不报警「看着合规」。需要 ToolContractCompiler 里**显式移除** frame surface，不能靠 SSOT 派生掩盖「该删的还在派生」（claim-vs-reality 铁律1 变体）。

【4. spike 隔离 + 小步清理（业内 spike 定性 + Periphery 扫死代码）】
- spike 代码应隔离不进主链路（预防）；已漏进则当 tracked debt，用 Periphery 6148★/pushed 2026-05-15 扫 orphaned 枚举/工具，专门 cleanup PR 小步删（别混进 C5 训练改动）。⚠️ Periphery 坑：只看编译进 build 的源，删 legacy frame 前须 build 全部 target + 人工 review diff 后手动删（#if 分支/Obj-C 可达会误报）。
- Replace Magic Number With Constant（C5LoRATraining 魔法数 variant%17/温度数组/scale20/4500-400-0.10-0.20 → 迁 contracts/training-config.yaml）是最高频清理操作。

【5. 生成物保留 source 行号锚点】
- 生成的 Swift/JSON 保留来源 contract jsonl 行号（便于回溯模板 bug vs 源数据 bug vs 消费侧 bug），与 §28 一手源行号锚点同源。

# 附录 F：Pre-mortem 三分类

- **[tiger]** 大爆炸式重构（一刀改完大部分代码）= 软件公司最严重战略错误（Netscape 4→6 三年无发布丢市场）。A2 是「立项至今大部分代码改」的基线，若有一刀同时改掉 surface+训练+bench=red flag。修法：切成可独立验收/可回滚小刀，每刀后链路仍可跑可演；旧路径保持可跑（strangler）。验证清单：A2 派单/PR 是否分刀、每刀后 swift test + make verify 仍绿。
  - source: Joel Spolsky things-you-should-never-do (2000) + Frontend at Scale issue19（待主线程亲核：Netscape 案例为业界经典共识）
- **[tiger]** codegen 模板单点 bug 复制进所有产物（ANTLR4 #2207 模板缺陷致所有引用语法生成失败）+ 生成代码格式工整 disarm reviewer（2026 研究：AI 生成 PR 冗余近 2x 却收更少负评）。A2 把 3990 行级 contract 编译进 Swift 高危。修法：重点 review 模板/生成器本身（真 SSOT），生成产物正确性用异源（hermes/人）语义核非只核 git diff 干净。
  - source: github.com/antlr/antlr4/issues/2207 + shiftasia/augmentedswe 2026 study（待主线程亲核 issue# + 2x 数字）
- **[tiger]** LoRA LR 过冲发散（超最优 LR 2× 即发散，Qwen 尤甚；最优 LR 与 rank 无关，改 rank 救不了 NaN）。与 MAformac 自己 2e-4→1e-4 修复同源。A2 改 surface 后重训务必守峰值 LR 1e-4 + grad-clip 实跑非声称。
  - source: arxiv 2602.06204 + MAformac MEMORY v10 本机实测 1e-4 iter30=1.069（待主线程亲核 arxiv id 2602.06204）
- **[tiger]** NaN loss 常是数据 regime 非超参（mlx-lm #361 gpt-oss-20b iter10 起全 NaN；OpenELM-270m train loss 全 NaN）。A2 用自然中文新数据重训，NaN 先查数据（重复/异常/全空 completion）再降 LR。
  - source: github.com/ml-explore/mlx-lm/issues/361（待主线程亲核 issue#361）
- **[tiger]** 端侧受限解码缺口：mlx-swift 核心栈无 GBNF 等价，唯一现成肩膀 mlx-swift-structured 仅 74★/pushed 2026-04-06（>60天临界淘汰）+ 依赖 swift-json-schema 0★ = 单人薄壳，弃坑/版本脱节风险。修法：vendor C++(44K) 进仓自维护，不直接 SPM 依赖单人 repo。
  - source: gh api petrukha-ivan/mlx-swift-structured stars=74 pushedAt=2026-04-06（待主线程亲核 star+日期）
- **[tiger]** codegen 工具/runtime 版本漂移→编译炸（swift-protobuf #1830：1.29 生成不兼容 1.30 runtime）。MAformac codegen 是 Python 脚本，跨开发机 python/依赖版本需锁；生成产物 schema 与 Swift 消费侧（ToolContractCompiler）需 hash 对账，防脚本改了 Swift 没跟。
  - source: github.com/apple/swift-protobuf/issues/1830（已亲核：1.29→1.30 不兼容）
- **[tiger]** 重构 scope creep『while we are at it』把 behavior-preserving 重构混入 behavior-changing 编辑，review/regression 验证崩（Xerox 工业研究 70.8% 开发者最担心引入回归）。A2 已高危，任何额外 scope 放大风险。修法：A2 派单明确『只迁 surface 不夹带功能/优化/重命名』；生成物变更与手写变更分 PR。
  - source: arxiv 2102.05201 Xerox 案例（待主线程亲核 70.8% 数字）
- **[tiger]** executionCellID()/Normalizer/StateApplier switch 无 default + executionCellID 可返 nil + JSONL decode try? 吞异常 = 健壮性硬伤，未知 device/格式错静默跳过或 runtime throw。A2 重写时补 default+日志+per-line error collection+负向 test。
  - source: 本机 ToolContractCompiler.swift:147-160/304-320 + C3ExecutionPipeline.swift:135 + C5DataGate.swift:502（已亲核）
- **[paper_tiger]** 数字口径四版本分叉（boundary md 161/223 device·507/680 intent vs MVP doc 191/562/2159 vs paradigm §14 权威 191/534/2086 vs D_domain.tools.json=6）。看似冲突实有定论：paradigm §14 是 A1-A9 拍板后权威，223 是子串误吸已 supersede。但🔴『534』是 intent 数不是工具数，G2 工具数明文未拍『实算』+ col O 优先级在 xlsx 第15列不在 jsonl。A2 派单把 534 当工具数=口径错。证据：已亲核 paradigm:226-227 + boundary md header + D_domain.tools.json len=6。
  - source: 本机已亲核：generated/10-family-device-boundary.md header + docs/.../paradigm-tool-surface.md:124-233 + generated/D_domain.tools.json len=6
- **[paper_tiger]** codegen-in-CI 会无谓断红（jOOQ 承认 schema 不可用时 build break）。但 MAformac 契约源是仓内 jsonl（不依赖外部 DB/网络），verify-refs 只读 manifest+committed（Makefile:26 注释明写别人 clone 无 snapshot 也能验）——此坑对 MAformac 不成立已规避。
  - source: 本机 Makefile:26（已亲核）+ jooq.org codegen-version-control
- **[paper_tiger]** 过早抽象/过度泛化（wrong abstraction 比 no abstraction 更糟）。但 MAformac 是 solo demo 轻治理 + 4 金钥匙一手契约定型，device×action×value 三元是真实座舱料归纳的已稳定 pattern，不算过早。守住：A2 新抽象只服务已确认 10 族 MVP，别为全集泛化/多语种/二期 MCP 预埋未用抽象（多语种走协议转换复用非重训，paradigm 已拍）。
  - source: arendjr/transcendsoftware premature-abstraction + paradigm §单语中文 LoRA 决策
- **[elephant]** 生成物变更与手写变更混进同一巨 PR→review 失效+rollback 灾难（contract jsonl 7.4M + yaml 808K 重生成 diff 淹没真实改动）。修法：生成物单独 commit 标 chore(codegen):regen，手写逻辑单独 commit，PR 描述显式分 surface 迁移行/逻辑变更行。
  - source: bitband scope-creep + 本机 contracts jsonl 7.4M/yaml 808K
- **[elephant]** generated Swift 大文件触发类型检查器指数爆炸（expression too complex，Swift6 12 行 42 秒）且类型错伪装成 timeout。codegen 若生成大字面量集合/深链表达式无类型标注极易踩。A2 把 191 device/534 intent 编译进 Swift 消费侧高危。修法：生成器 emit 显式类型标注 + 拆大字面量 + 避免深嵌套 + -warn-long-expression-type-checking 扫。
  - source: cocoawithlove type-checker-issues + danielchasehooper why-swift-is-slow（42秒/12行）
- **[elephant]** parity baseline 含 pre-existing 失败会 block 正确 A2 变更（Google 大规模迁移实证）。MAformac C6 base Qwen3-1.7B 本就 hard_fail(IrrelAcc 0.789<0.9) + C5 candidate 0/34——A2 用 C6 当 parity gate 要先 freeze A2-before 每轴 base 数，parity 比『相对 before 不退化』非『绝对全绿』，禁整体聚合掩盖子轴退化（claim-vs-reality 铁律3）。
  - source: arxiv 2504.09691 Google 迁移 + CLAUDE.md §9 C6 base hard_fail/C5 0/34（本机已核）
- **[elephant]** 双 surface 长期并存：frameToolSchema(generic frame legacy)与 dDomainToolSchemas 都从同一 compiler 派生且并挂 renderedToolsText(:48)，drift gate 不报警『看着合规』。这是 SSOT 派生掩盖『该删的还在派生』。修法：A2 需显式产品决策门移除 frame surface（非靠 drift gate）。
  - source: 本机 ToolContractCompiler.swift:22-58 frameToolSchema+dDomainToolSchemas 并存（已亲核）
- **[elephant]** --mask-prompt 历史『是否真生效』疑虑（mlx #1313）直接呼应 MAformac C5 masking 假绿坑（声称 masking_coverage 但未实跑）。A2 重训 masking 须 dump tokens 实证 loss mask 真生效，不信 flag/metadata 声称。
  - source: github.com/ml-explore/mlx-examples/issues/1313（待主线程亲核 #1313）+ claim-vs-reality 铁律2


# 附录 G：A2 派单前 grill 弹药

### 数字口径锚定——534 到底是什么？派单前先统一
- 选项: A) 把 534 当『工具数』直接 codegen 534 个具名工具 / B) 锚 paradigm §14 权威：191 device·534 intent·2086 行，534 是 intent 数；工具数 G2『实算不拍』，先从 534 intent 按 value 形态/arg 收敛出实际工具名集 / C) 用 boundary md 的 223/507
- ⭐推荐: ⭐B。已亲核 paradigm §14(line 226-227) = A1-A9 拍板后权威，223(SOURCE1 子串误吸)已 supersede，D_domain.tools.json=6 是 spike 冻结。534=intent 不是工具数，col O 线上优先级在 xlsx 第15列不在 jsonl（G2 blocker）。把 534 当工具数派单=口径错全链路。量化：误吸差 32 device(223-191)、28 intent(562-534)。

### 生成物入仓 vs 工具数两层 scope
- 选项: A) full(1538)+demo(534)两层目录都入仓 / B) 只入 demo 目录、full 运行时生成 / C) 都 gitignore 走 build plugin
- ⭐推荐: ⭐A。MAformac 已选 commit 生成物 + Makefile git diff 漂移门（业内 hybrid 最佳实践，已核 generated/ git-tracked + Makefile:51）；新增 D-domain 目录必须纳入 GENERATED_CONTRACTS 漂移门否则新硬编码逃过 gate。两层 scope 派生深度不同非两套 SSOT（paradigm §14 A2 已拍）。

### 复用边界——ToolContractCompiler 重写 vs 微调
- 选项: A) 整个 compiler 重写为 data-driven 消费 generated JSON / B) 只删 frameTool surface 保留 Normalizer/StateApplier 硬编码 / C) 全推翻含 codegen 地基
- ⭐推荐: ⭐A。Normalizer(142行)+StateApplier(187行)=329 行硬编码是 spike 残留，扩 10 族会膨胀必须 data-driven；但 codegen 地基(Python gen + Makefile 漂移门)守现状不推翻(steelman)。frameTool surface 须显式移除非靠 drift gate(它不报警 compiler-derived 的债)。

### 重构序——A2 切几刀 + 依赖序
- 选项: A) 一刀全改(surface+训练+bench 同 PR) / B) 按依赖序分刀:口径→Python codegen→compiler→state cells→C5→C6→parity 验收 / C) 先 C5 训练后补 compiler
- ⭐推荐: ⭐B。大爆炸式一刀=Netscape 红 flag(每刀后须 swift test+make verify 绿)。依赖序硬约束:[0]口径不先统一=全链路错；[1]Python codegen 不先做=Swift 无源消费；[2]compiler+[3]state cells 是[4]C5+[5]C6 前置。生成物 commit 与手写 commit 分开(jsonl 7.4M diff 会淹没逻辑改动)。

### parity gate——A2 验收锚什么基线
- 选项: A) C6 绝对全绿 / B) freeze A2-before 每轴 base 数,parity 比相对不退化(禁整体聚合掩盖子轴) / C) 不设 gate 凭感觉
- ⭐推荐: ⭐B。C6 base 本就 hard_fail(IrrelAcc 0.789)+C5 candidate 0/34,绝对全绿做不到。用 C6 当 golden parity gate 比『相对 A2-before 不退化』,按 case schema 字段拆 axis(非 case_id naming),action hard_pass 锚 base 10/23(claim-vs-reality 铁律3)。

### 端侧受限解码——adopt mlx-swift-structured?
- 选项: A) 直接 SPM 依赖 petrukha-ivan/mlx-swift-structured / B) vendor XGrammar C++(44K)进仓自维护 / C) 端侧暂不做受限解码,先训练面对齐
- ⭐推荐: ⭐B(若本期做)或 C(若 A2 只做范式迁移)。74★/pushed 2026-04-06(>60天临界淘汰)+依赖 swift-json-schema 0★=单人薄壳,直接依赖有弃坑风险；C++仅44K可控,vendor 自维护。但受限解码是端侧 runtime 缺口,可与 A2 训练面迁移解耦(C),后续单独 spike。待亲核 74★/日期。

### 训练配方——A2 重训是否动 LR/adamw/rank
- 选项: A) 重开调 LR/adamw/rank / B) 守 rank16Mainline()坐实配方(scale20/LR1e-4/adamw),只改 surface/正样本/用户文本三处 / C) 换 DoRA
- ⭐推荐: ⭐B。rank16Mainline(C5LoRATraining:1175)是配方 SSOT 已坐实稳(本机 1e-4 iter30=1.069);A2 是 surface 范式迁移不是配方问题,不重开(避免混淆变量)。LR 守 1e-4(超 2×发散,arxiv 2602.06204)。NaN 先查数据(自然中文新数据 regime)非降 LR。

### 自然中文训练数据——谁生成 + 怎么防假绿
- 选项: A) 本机 generator 合成 device=...协议风格(现状) / B) 云 generator 自然中文+异源 judge+contract 定标签+原文 oracle / C) 复用现有协议风格只换工具名
- ⭐推荐: ⭐B。现状训练集 0 条自然中文=北极星缺口(C5 0/34 根因之一)；协议风格 device=...;primitive=... 是模型混 B_frame/D_domain 的根因(C5LoRATraining:1767)。masking 须 dump tokens 实证 loss mask 真生效(mlx #1313 + claim-vs-reality 铁律2),不信 masking_coverage flag 声称。


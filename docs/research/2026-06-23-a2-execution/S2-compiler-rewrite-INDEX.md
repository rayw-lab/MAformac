# S2 ToolContractCompiler data-driven 重写设计 — 综合官 + 主线程亲核 + 一手档 INDEX

> 2026-06-23 · S2 执行线 ultracode workflow（6 finder + 综合官，1.12M tok / 652s）+ 主线程亲核坐实。
> 实现 SSOT = 综合官全 spec（仓外 `README-synth-spec.md`）；本文 = 亲核结论 + 3 刀实现锚 + S2/S3 边界 + 指针。

## 1. 主线程亲核坐实（全对齐综合官，无虚报）
- `C6MockStateApplier`(`C6VehicleToolBench.swift:1155-1163`) = **1 行委托壳**（:1161 直转 `ToolContractStateApplier.apply`）→ cut3 改 `ToolContractStateApplier` 即同时改 demo runtime + C6 bench(gold replay:832/candidate:937)，门面壳零改 ✓
- `parseCells`(`ContractLookups.swift:197-266`) 解析了 `executionRange`(:254)/`expStepLittle`(:257)/`gearMap`(:259/263)/`extremeMap`(:261)，但 **未解析 `default`/`depends_on`**（`StateCellDefinition` struct:108-141 无此字段）→ cut3 4 parser 缺口真实 ✓
- `d_domain_ir_map.json` multi-primitive = **134**/562（综合官说 134）+ distinct device **191** ✓
- `JSONValue` Codable(`ToolCallFrame.swift:21`) + repoRoot 加载先例(`C6VehicleToolBench.swift:1381` `Data(contentsOf: repoRoot.appendingPathComponent)`) ✓
- `Package.swift:36` generated **exclude**（Swift target 拿不到）→ 须走文件加载 ✓
- `frameToolSchema` 被 `C5LoRATraining.swift:1954/1958`(toolCallFrameToolSchema:1953-1959) + `C5LoRATrainingTests.swift:48` 消费 → strangler 保留（S4 删）✓
- `renderedToolsText` **零外部消费方**（grep 仅内部）✓

## 2. 细切 3 刀（综合官 cut1/cut2/cut3，每刀独立 swift test+make verify+parity 绿后 commit）

### 刀1 — model-visible surface 迁 D-domain（仅 ToolContractCompiler.swift）
1. 新增 `DDomainToolEntry: Codable`(type/function{description,name,parameters:JSONValue}) + `loadDDomainCatalog(repoRoot:)`（仿 :1381 文件加载，generated/ exclude 须走 repoRoot）
2. `dDomainToolSchemas:39` 改消费 catalog（generated 已含完整 schema 含 enum，非空占位）；加可注入 `dDomainCatalog` 存储（默认空，现有 init 不破）
3. **删** `dDomainSurfaceNames():71-90`（6 硬编码 if-device，新 562 surface disjoint）
4. **删** `functionSchema():92-105`（空 properties 占位，generated 自带）
5. `renderedToolsText:48-52` 删 `frameToolSchema +` 前缀只渲 D-domain（零消费方，可整体删）
6. 🔴 strangler 保留：`frameToolSchema:23`/`frameProperties:54`/`enumStringSchema:107`（C5 S4 用）
- unit test：compiler 产 D-domain surface 562 正确

### 刀2 — Normalizer 消费 ir_map（562 工具名→IR，strangler 双轨）
1. 新增 `DDomainIRMapEntry: Codable`(device/ir_primitives/value_types) + 从 `d_domain_ir_map.json` 加载
2. `normalize(_ call:, irMap:)` 加默认参数（旧调用 StateApplier:296 走默认无感，守 immutability）
3. switch 顶部加 `if let entry=irMap[call.name] { return normalizeDDomain(...) }`，**旧 6 case+frame 全保留**(strangler)
4. `normalizeDDomain`：`resolvePrimitive`(单值 428 直取/multi 134 用 value 格式消歧:纯数字→SPOT、含%→PERCENT、感受词/档→EXP) + `buildValue`(value_types 定 type，内容填 direct/offset)
5. `default:170` 静默 `return []` → `logUnclassified + return []`（claim-vs-reality 铁律1：防漏吞假绿）
- IR 输出契约不变（device×action×value，下游 StateApplier 零改）；unit test：D-domain 工具名→IR 正确

### 刀3 — StateApplier data-driven from state-cells（cell-driven，strangler 5 族先行）
🔴 改 `ToolContractStateApplier`(:288-475)，非 C6MockStateApplier（委托壳）
- 核心冲突：8 applyXxx 把 cell 边界/步长硬编码重复(applyTemp +2=exp_step.little:2 / applyFan min10max1=range / applyScreen±10 等)，cell SSOT 没 enforce
- step1：device→cellID 映射表（**device 串≠cell id 命名空间**：ac_temperature→ac.temp_setpoint 等，须显式映射，codegen 自 strangler_map/10-family-device-map）+ actionPrimitive/value 二级分流
- step2：`applyGeneric(ir, cell)` 从 cell 元数据派生(power_on/off→enum / adjust_to_number→clamp executionRange / increase_by_exp→±expStepLittle 再 clamp / adjust_to_gear→gearMap / adjust_to_max/min→extremeMap / set_mode→values 校验 / scope→windowKeys 泛化)
- step3：`default:319` 不静默 → quarantine 账本
- 🔴 4 parser 缺口（先扩 parseCells+StateCellDefinition）：① `default` 初值(applyTemp '24'/applyFan '1'/applyScreen '70') ② `depends_on` 联动(ac.temp_setpoint→ac.power=on) ③ value 别名(c2ColorValue red→红 + EXP 感受词) ④ single-zone vs scope 写法
- 🔴 **strangler 不一次覆盖 191**：S2 先 5 族 demo-positive(ac/window/screen/ambient/fan) cell-driven + parity gate(输出态逐 key 等价旧硬编码)，旧 8 applyXxx 保留 parity 对照；184 未建 cell device 落 quarantine 账本，S3 扩

## 3. S2/S3 边界（机制=S2 / 数据=S3）
- **S2**：cell-driven applyGeneric 框架 + device→cellID router + quarantine 账本 + parser 扩 default/depends_on + 5 族 parity 不退化
- **S3**：state-cells.yaml 增 191 device cell 定义（range/step/scope/values/default 具体值）+ 填 device→cellID 新条目 + 逐族从 quarantine 纳入 + per-cell override 内容
- 正交铁证(state-cells.yaml:9-15)：StateApplier 泛化与 surface 形态正交；parity gate 共同护栏

## 4. open_risks（pre-mortem）
删过头 break C5(frameToolSchema)/C6(旧 6 normalize) / data-driven runtime regression(parity gate 护栏) / 现有 118 swift test break(每刀后跑) / S2S3 耦合(机制/数据分工)

## 5. A2 边界（code-only）
S2 只 surface+normalize+state-apply 框架 data-driven + 编译/swift test/make verify 绿；不训练/不评测/不生成语料。受限解码 vendor(value_form 投影 S1-P2 TODO)=DEFERRED。

## 6. 一手档指针（仓外 raw）
`~/workspace/raw/05-Projects/MAformac/research/2026-06-23-a2-s2-compiler-datadriven/`：`wojsase6m.output.json`(最一手) + journal/agent jsonl(transcript) + `lens1-6.md`(各 finder) + `README-synth-spec.md`(综合官全 spec)

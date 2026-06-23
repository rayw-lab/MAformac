# S3 state-cells 扩 + C3 派生 + 命名清债 — 综合官 + 主线程亲核 + 一手档 INDEX

> 2026-06-23 · S3 执行线 ultracode workflow（6 finder + 综合官，1.2M tok / 1307s）+ 主线程亲核坐实。
> 实现 SSOT = 综合官全 spec（仓外 `README-synth-spec.md`）；本文 = 亲核结论 + 实现锚 + DEFERRED note + 指针。

## 1. 主线程亲核坐实（全对齐综合官 + 实跑验证）
- **命名清债 hvac.ac 主链路 0 残留**（`grep -rn hvac\.ac Core/ Tests/ App/` = 空）✓；ac.power 接管（FastPath emit/spokenText/defaultCells）
- 6 族 21 cell schema：`verify_refs.py` state_cells=ok + **l1_closure L1_rows=76**（parity 锚保持，闭合不破）✓
- deviceCellMap **public 单源 + 24 映射**（S2 7 + S3 17）；C3ExecutionPipeline 复用（switch 6 case 删）✓
- 座椅 0-3 真值（CLAUDE.md:80 + function-spec:61-63，旧 16-30/0-5 拍错）✓
- 6 族 service 路由实算：seat/door/wiper/sunroof/fragrance=carControl，volume=cmd（jsonl python Counter）
- 全量 swift test 131 / 0 fail（C3/C6 parity 不退化）

## 2. S3 范围（6 族代表 cell，非 191 全 cell）
🔴 综合官 s3_scope_boundary 决策：S3 = 6 族代表 cell（~21），**NOT 191 device-level cell**。理由（A2 边界 code-only）：
1. 191 cell 真实边界值（温度档/百分比/枚举词表）逐一编 = **生成语料**，越 A2 边界（不生成语料）+ 无一手依据（协议无硬边界 range_authority_note）
2. 无 cell 定义的 device 加 deviceCellMap 也无 cell 可写（applyGeneric 第二道 guard logUnmapped）
3. 191 全量 cell = DEFERRED（随 retrain-c5/rebuild-c6，每补一族 deviceCellMap 自动纳入）

## 3. 三处 device→cell 分叉消除（铁律1 活靶子）
S3 前三处平行硬编码：C3 switch 6（无 ac_windspeed）/ S2 deviceCellMap 7（有 ac_windspeed）/ allowlist 2 → **已 drift**。S3 统一 = C3 复用 `ToolContractStateApplier.deviceCellMap` 单源（public），删 C3 switch + fix ac_windspeed 缺失。

## 4. 命名清债 12 行（hvac.ac→ac.power）
- Core 4：FastPathIntentEngine:21（emit）/ DemoVehicleStateStore:150（删 cell）+ spokenText:167-170（删 case）
- Tests 7：WalkingSkeletonTests:19/21/22 + VehicleStateStoreContractTests:12/27/29/30
- App 1：ContentView:109
- **连带**：capabilities.yaml:126 cabin.ac state_cell hvac.ac→ac.power（CapabilityContractFileTests 验 capability state_cell 在 store；综合官 naming_debt 漏点，主线程 catch + 修）
- 不改：function-spec-full-v0.yaml:46/62 + capabilities.yaml 其他 historical（T5 banner 不改正文）

## 5. 🔴 DEFERRED note（A2 后独立立项，CLAUDE §9 边界）
- **deviceCellMap codegen 派生**：当前硬编码 24 映射（device 名↔cell id 双写）；DEFERRED = 仿 gen_tool_contract.py 产 generated/device_cell_map.json + Swift loadDeviceCellMap(repoRoot)
- **191 全量 cell**：S3 只 6 族代表 cell；191 device-level cell 逐族补 = DEFERRED
- **ContentView title switch 整重做**：当前 8 case 锚旧 8-key legacy，新轨（ac.temp_setpoint[主驾] 等 position-bracket）落 default 返裸 key = demo UI title 退化；整 switch 重做匹配 position-bracket = 更大 demo UI 改面，**note 上报**（非 A2 surface 核心，最小改 :109 已消除 hvac.ac 残留）
- **旧 8-key legacy 全清债**：DemoVehicleStateStore defaultCells 仍有 hvac.temperature/seat.driver.*/window.driver/lighting.ambient/fan.speed 旧轨（被 capabilities 7 capability + legacyMVPKeys test 锁定）；hvac.ac 已删，其余旧轨全清 = 更大 legacy 清债 note 上报
- **mode enum cell 多映射**：seat.massage_mode/volume.mode/wiper.mode/fragrance.mode 建于 state-cells，但 deviceCellMap 一 device→一主 cell（set_mode 写 mode cell 的 device 多 cell 映射 = DEFERRED）

## 6. A2 边界（code-only）
S3 只 state-cells 扩 6 族 + deviceCellMap 单源 + C3 派生 + 命名清债 + 编译/swift test/make verify 绿；不训练/不评测/不生成语料。

## 7. 一手档指针（仓外 raw）
`~/workspace/raw/05-Projects/MAformac/research/2026-06-23-a2-s3-statecells-c3-naming/`：`w53fjzgrv.output.json`(最一手) + journal/agent jsonl + `lens1-6.md` + `README-synth-spec.md`(综合官全 spec)

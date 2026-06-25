# UIUE Runtime-Presentation Bridge — 决策表（答 amend RPB-01~25 + 补漏 RPB-14 + 厘清 RPB-08）

---
status: decision_table
artifact_kind: runtime_bridge_decisions
authority: discussion_input_not_ssot
answers: docs/grill-checklist/uiue-runtime-bridge-amend-2026-06-25.md
created_at: 2026-06-25
mainline_head_live_verified: de79c653685ff4835cc74b04106120b6e785e491
uiue_head_live_verified: 9cf1af2b503af9f7980b7bffbce85914f8fcaf42
proof_cap: presentation_behavior_only（不声称 C6/模型质量/语音就绪/真机 V-PASS）
---

> 磊哥定：先做 ① 补漏 RPB-14 + 厘清 RPB-08，再做 ② 答 P0 决策表 + 隐含假设字段分类。
> teardown 一手核实：amend 的 runtime 真相 claim 全部准确（store 7 态无 reason/activeCell/guardBlock；C3 guard denial throw 非 snapshot；FastPath 只认「打开空调」；bridge 名仅 roadmap）。

---

## ① 补漏 RPB-14 — already_state（state-noop，我 7 态盲区）

**一手**：`c06-runtime-outcome-enum-skeleton.schema.yaml:37-49` —— `already_state` = 请求的车态已为真（或系统已关无意义 delta）的 state-noop；`not_equivalent_to: [unsupported, safety_refusal, success_with_state_delta, clarify]`；owner `C3_and_readback_renderer`；硬规则 `already_state_must_not_be_collapsed_into_unsupported_or_safety`。

**场景**：「打开空调」但空调已经开着 → 不该盲目再 toggle，也不该报错/拒识。这是**状态感知的智能信号**（demo 卖点：助手知道「已经是这状态了」）。

**决策（两层分开）**：
- **runtime 结果枚举**：`already_state_noop` **独立保留**（machine-readable，不塌进 satisfied/unsupported/safety）。owner = shared bridge（`DemoRuntimeResult.resultKind`）。
- **presentation（DemoVisualState）**：**复用 `satisfied` 视觉**（语义对：已满足），但与「刚调成」区分——
  - ❌ 无 numericText 滚动（值没变 → 无 changed cell，CC1 逻辑判定无 activeCell delta）
  - ❌ 无 changing 脉冲（没在执行）
  - ✅ **一次轻 acknowledgment pulse**（`symbolEffect .bounce` 单次，"我知道了"点头感，区别于 satisfied 呼吸）
  - ✅ **`already_state_readback`**「空调已经为您开着」（renderer-owned，区别于「已为您调到」）
  - ❌ **无 store mutation**（revision 不变）
- **不加第 8 个 DemoVisualState**（避免 enum 膨胀）——satisfied 视觉复用 + readback 区分 + 无 revision bump 足够区分「已经是」vs「刚调成」；但 **runtime 结果枚举层保持 already_state 独立**（守 schema「不塌进」硬规则）。
- 🔴 **这印证 bridge 必要性**：runtime 结果词表（8 类）≠ presentation 视觉态（7 态），需 bridge 显式映射（RPB-11）——已经是「多对一」（already_state + satisfied 都→satisfied 视觉，但结果词表分开）。

**physical landing**：`DemoRuntimeResult.resultKind` 加 `already_state_noop`；UIUE 映射 already_state_noop → satisfied 视觉 + ack pulse + already_state_readback + 无 revision bump；契约存在性测试（already_state 不渲成 blocked_hard/unsafe）。**承接**：D7 四态分开（扩第 5 类 already_state）/ CC1（无 activeCell delta → 不切主值）。

## ① 厘清 RPB-08 — 「ScopeOrigin 命名碰撞」实为两个正交字段（代码本无碰撞）

**一手核实**：
- store 侧：`DemoVehicleValueSource{mock, user, system}`（`DemoVehicleStateStore.swift:11-14`）= **值来源/provenance**（谁写的值：mock 种子 / user 触摸 / system）。**不叫 ScopeOrigin**（amend 措辞不精确）。
- default-scope 侧：`ScopeResolution.origin{defaulted, explicit, fanout, missing}`（`Core/Execution/ScopeResolution.swift:4-6`）= **范围解析来源**（温区怎么定的）。G18 称 `scope_origin`。

**厘清结论**：**无代码命名碰撞**（两个不同 enum 名）。bridge 保持为 **2 个独立字段**：
- `source`（值来源 = `DemoVehicleValueSource`，mock/user/system）—— **内部 provenance，非客户面展示**（RPB-07 的 `source`/`initiator`）。
- `scope_origin`（范围解析 = `ScopeResolution.origin`，defaulted/explicit/fanout/missing）—— **客户面结构化 metadata**（RPB-08 展示策略：defaulted 低强调/淡角标/可省，explicit + fanout 显式，G18 已决）。

🔴 **铁律**：UI/TTS **禁从中文文案推断 scope**（必读结构化 `scope_origin`，G18）。这两字段**绝不混用**：「谁设的值」≠「范围怎么解析」。

**physical landing**：bridge `DemoInteractionEvent` + `PresentationSnapshot.card` 同时带 `source`（provenance）+ `scope_origin`（resolution）两字段，文档注明语义区别防未来混淆。

---

## ② P0 决策表（RPB-01~25，8 字段；evidence 全 file:line 一手核）

> decision: `accept_contract`(定契约) / `prototype_allowance`(原型放行) / `defer_to_bridge`(留 bridge) / `reject`。owner: UIUE / mainline runtime / shared bridge / later。before-bridge = allowed_before_bridge。
>
> 🔴 **evidence 路径说明**：runtime 代码文件 file:line（`DemoVehicleStateStore.swift` / `ScopeResolution.swift` / `C3ExecutionPipeline.swift` / `FastPathIntentEngine.swift` / `TraceLogger.swift` / `c06-runtime-outcome-enum-skeleton.schema.yaml`）= **主线 repo `/Users/wanglei/workspace/MAformac` @ `de79c653`** 的行号（teardown 一手核实），**非本 uiue worktree**（故 uiue 内 cite-verify 报 file_missing 属预期，已主线核过）。`SD*` / `grill-master` / `G18` / `scene5` / 我的 `CC*` = uiue/grill 文档。

| ID | decision | owner | landing | before-bridge | evidence (file:line) | residual risk |
|---|---|---|---|---|---|---|
| **RPB-01** 边界 override | accept_contract | shared bridge | doc+OpenSpec | 规则澄清 yes / 直接 mutate no | SD7/Q7「要走后端」+ grill-master D8.6（UIUE 边界）| SD7 放宽须限「snapshot 消费 + 事件写入」，非自由 store mutate |
| **RPB-02** 三车道分类 | accept_contract | shared bridge | doc | yes（分类框架）| amend RPB-02 | 原型 adapter 不得静默变 mainline runtime（每条标车道）|
| **RPB-03** bridge 4 名 | accept_contract | shared bridge | OpenSpec | no（定名才扩码）| roadmap:190（4 名提议）| 锁名前别让代码散播替代名 |
| **RPB-04** store 所有权 | accept_contract（consume snapshot）| shared bridge | OpenSpec+code | yes | uiue `Core/Presentation/*` import 仅 Foundation/Observation，消费 `[DemoVehicleStateCell]` 入参 | preview/spike 可 `#if DEBUG` 直读 store（prototype_allowance，标不得成契约）|
| **RPB-05** 写所有权 | accept_contract（触摸走 executor，source=ui_touch）| shared bridge | OpenSpec | no | 磊哥 Q7「触摸调节真实完整 + 要走后端」| demo 取巧想直写 store → 限 prototype_adapter behind flag |
| **RPB-06** 事件集 | accept_contract | shared bridge | OpenSpec | no | amend RPB-06 | 枚举封闭（text/mic start-end/ASR text-fail/card tap/value adjust/reset/force macro/scene macro/cancel/interrupt/timeout）|
| **RPB-07** 事件 payload | accept_contract | shared bridge | OpenSpec | no | amend RPB-07 + RPB-08 厘清 | source(provenance) 与 scope_origin(resolution) 两字段分开 |
| **RPB-08** scope 展示 | accept_contract | shared bridge | OpenSpec+code | yes（已 G18 决）| `ScopeResolution.swift:4-6` + G18 + `DemoVehicleValueSource:11-14` | 见上厘清；UI 禁从中文推 scope |
| **RPB-09** 结果枚举 8 类 | accept_contract | shared bridge | OpenSpec | no | c06 already_state seed:37 + 我 CC-A4/CC4/SD19 | 🔴 含我隐含假设的 partial_accept_partial_refuse + already_state_noop |
| **RPB-10** 拒识词表 | accept_contract | shared bridge | OpenSpec | no | c06 `already_state_must_not_be_collapsed`:97 | 禁裸 `rejected`，4+1 态不互换（unsupported/safety/clarify/already_state）|
| **RPB-11** 视觉映射 | accept_contract | shared bridge+UIUE | OpenSpec+code | yes | `DemoVisualState:17-24`（7 态）+ RPB-14 | 7 态够，但 already_state→satisfied+ack、partial→逐 cell 混态 |
| **RPB-12** guard denial 路径 | accept_contract | shared bridge（mainline 加投影）| OpenSpec+code | no | `C3ExecutionPipeline:104-107` throw guardDenied | 🔴 需 guardDenied→presentation-safe refusal snapshot（我 CC-B1 假设了）|
| **RPB-13** unsafe R2 | accept_contract | shared bridge+UIUE | doc+code | yes（视觉）/ no（runtime 投影）| 我 SD19 CC-B1/CC-B2 + scene5:135-150 | active=door族 / refused=door.tailgate_height / shield / 不显 speed（纯话术）|
| **RPB-14** already_state | accept_contract（见 ① 补漏）| shared bridge+UIUE | OpenSpec+code | yes（视觉）| c06:37-49 | already_state_noop 独立枚举 + satisfied+ack 视觉 + 无 revision bump |
| **RPB-15** clamp | accept_contract（clamp 成功）| shared bridge | code | yes | SD9:168 + 我 CC4 | 显 18℃ / 说「最低18度已调到18」/ trace=clamped；demo 不暴露失败 |
| **RPB-16** 多意图 splitter | **defer_to_bridge** | later（runtime backend）| code prototype | sequencer yes / 真 splitter no | `FastPathIntentEngine` 只认打开空调 + grill-master:173 + 我 SD19 CC-A5 | Phase4/5 用 sequencer 编排(已做)+force-state；真 NLU splitter DEFERRED |
| **RPB-17** 部分 deny 终态 | accept_contract（一个综合 snapshot）| shared bridge | OpenSpec | no | 我 CC-A4 + E8-D | 逐 cell 混态（部分 satisfied+部分 unsafe）+ 1 句综合 readback；结果=partial_accept_partial_refuse |
| **RPB-18** 场景宏所有权 | accept_contract（shared runtime config）| shared bridge（mainline 拥 registry）| OpenSpec | no | E4 + grill-master:95 G6 schema | SceneMacroRegistry=Core config，非 UIUE-only，非隐藏 planner（必带 trace/allowed_tools/required_state_cells）|
| **RPB-19** 环境上下文 | accept_contract（context 输入非 device cell）| shared bridge | doc+code | yes | SD13 C 环境(weather/time_period) | 天气/时段=触发宏/preset 的 context + 显示事实，**不渲成车控卡**（非 device cell）|
| **RPB-20** 复位 preset | accept_contract | shared bridge | code | yes | SD13 NormalRunPreset + SD1 DemoReset | reset 清：vehicle→default/desired/reasons/dialogue/trace/orb→idle/voice→idle/context→晴天白天/macro queue |
| **RPB-21** 事件驱动思考 | accept_contract | shared bridge | OpenSpec+code | no | E2 事件驱动掩盖术 + E8 | 🔴 替固定延时为事件门（cardsDidStartChanging/readbackReady/ttsStart/ttsEnd/timeout/fallback）；GLM 被 catch 4 次计时 frame，bridge 必 enforce 事件驱动 |
| **RPB-22** 取消/打断 | accept_contract | shared bridge+UIUE | code | yes（部分已做）| 我 4c MultiCallSequencer cancellation fix + D13 barge-in + U21 | 定 cancel/barge-in/ASR abort/timeout/backgrounding 终态 snapshot；stale async 禁 cancel 后再 mutate 卡 |
| **RPB-23** ASR/TTS 边界 | accept_contract | shared bridge+later | doc+code | mic/TTS UI yes / voice-ready claim no | SD2「后端只接 ASR 文本」+ U28 + D14 | 后端契约收 text；「voice ready」须真机 ASR/TTS 证据（DEFERRED）|
| **RPB-24** trace envelope | accept_contract | shared bridge | OpenSpec | no | `TraceLogger` 存 stage 无 frozen envelope + roadmap:190 | 定 TraceEnvelope 最小字段（trace/event id/request text/normalized intent/guard result/transitions/readbacks/proof class/timestamps/redactions）|
| **RPB-25** proof class 上限 | accept_contract | shared bridge | doc | yes | amend RPB-25 + 我 V10（投屏≠真机）| UIUE 截图/模拟器只证 presentation 行为，**不证** C6/模型质量/语音端点/真机 V-PASS |

**P0 小结**：24 accept_contract + 1 defer_to_bridge（RPB-16 真 splitter）。**绝大多数是「定契约字段」非「写实现」**——bridge 是 thin vocabulary，可行。

---

## ② 隐含假设字段分类（我 grill 静默假设的 → 正式定车道）

| 我的 grill 决策 | 假设的字段 | 车道分类 | 落点 |
|---|---|---|---|
| CC1 主值切 activeCell | `PresentationSnapshot.activeCell` | **shared_bridge_contract** | DemoRuntimeResult/PresentationSnapshot |
| CC-B1 后备箱 refused cell | `DemoRuntimeResult.refusedCell` | **shared_bridge_contract** | guardDenied 投影 snapshot |
| CC-A4 部分 deny | `resultKind.partial_accept_partial_refuse` | **shared_bridge_contract** | DemoRuntimeResult 结果枚举(RPB-09) |
| RPB-14 already_state | `resultKind.already_state_noop` | **shared_bridge_contract** | DemoRuntimeResult 结果枚举 |
| SD20 制冷蓝/制热红 | 读 `ac.mode` cell 驱动样式 | **visual_only** | 读现有 cell，无新 runtime 字段（presentation 派生）|

🔴 **关键**：前 4 个**不是 visual_only**——它们引入 runtime 派生字段，必走 bridge（否则 UIUE 硬化时发明与主线冲突的字段，正是 derivation-layer-discipline 铁律的危险）。第 5 个（mode 色）读现有 `ac.mode` cell，纯 presentation 派生，visual_only 安全。

---

## bridge 字段名汇总块（建议，待 OpenSpec 冻结）

```
DemoInteractionEvent  { eventKind, familyID, cellKey, actionKind, rawValue, displayValue,
                        scope, scope_origin(defaulted/explicit/fanout/missing),
                        source(mock/user/system/ui_touch/voice), revision, traceID, initiator }
DemoRuntimeResult     { resultKind(accepted_tool_call|clarify_missing_slot|unsupported_no_tool|
                        refusal_safety_or_policy|already_state_noop|runtime_error|cancelled|
                        partial_accept_partial_refuse),
                        activeCell, refusedCell, reason, readback, perCellResults[] }
PresentationSnapshot  { cards[]{familyID,cellID,title,value,unit,visualState,scope_origin,
                        reason,availableActions,lastUpdate,activeCell}, dialogue, orbState }
TraceEnvelope         { traceID, eventID, requestText, normalizedIntent, guardResult,
                        transitions[], readbacks[], proofClass, timestamps, redactions }
```

---

## Q1 答 — 结合 anchor + 层级/交互，50 个**不齐全**，补 RPB-51~53（3 实质漏点）

> 用 11 张 anchor（A01-A11）+ 视觉层级/交互逐张核 50 RPB，暴露 3 个 runtime 相关漏点 + 2 minor。50 覆盖了主干但 anchor 视角补回这几个。

- [ ] **RPB-51 — snapshot card 必携带族内 sibling/secondary cells（A02 制冷热色 + A04/CC1 暴露）**
  - 现实：主线 `DemoVehicleStateCell` per-cell（key/value），**无族内 sibling 分组**。A02 制冷蓝/制热红需读 `ac.mode`（与 `ac.temp_setpoint` 同族兄弟）；CC1 需「本次变化 cell」。snapshot 若只给 primary cell → presentation 拿不到 mode → **渲不出制冷热色/CC1 主值切**。
  - decision: **accept_contract**（扩 RPB-30 card schema 带 `siblingCells`/`mode` + `activeCell`）。owner: shared bridge。landing: OpenSpec。evidence: SD20 + CC1 + 主线 `DemoVehicleStateStore` card per-cell 无 sibling。
  - 🔴 **修正我之前的分类**：SD20 制冷热色我标 `visual_only`（渲染逻辑对），但它**依赖 snapshot 带 sibling cell** = 依赖 `shared_bridge_contract`。visual_only 的前提是 snapshot schema 够全。
- [ ] **RPB-52 — 演绎控制台 force-state context 输入（A09 segmented 暴露）**
  - 现实：演绎控制台 segmented 写 `vehicle.speed`/`gear`/`weather`/`time_period`（R2 guard 读 `vehicle.speed`，主线 cell:181）。这不是普通 card tap event，是 **runtime context 强制输入**，RPB-06 事件集没显式列。
  - decision: **prototype_allowance**（demo-mode force-state path）。owner: shared bridge（事件集加 `force_context_state`）+ UIUE（console）。landing: OpenSpec event 集 + `#if DEMO_MODE` 隔离。before-bridge: prototype yes（behind flag）。residual: 须经 bridge event 非直接 store write（否则 R2 guard 读到的 speed 来源不可追溯）+ `#if DEMO_MODE` 防客户识破。
- [ ] **RPB-53 — RPB-21 think 两语义张力（A05 暴露）**
  - 现实：RPB-21「替固定延时为事件驱动」是对的，但 **E8 think 有两语义**：① analyzing think（掩盖后端动态）= 事件驱动（`cardsDidStartChanging`=handoff）② **安全拒识 think = 合法固定 1.0s 演出**（E8-C，纯演出非掩盖，A05）。RPB-21 blanket 禁固定延时会**误删安全拒识合法演出**（= GLM 被 catch 4 次计时 frame 的反向过度修正）。
  - decision: **accept_contract**（澄清 RPB-21：think gate 区分两类，安全拒识固定 1.0s 是合法例外）。owner: shared bridge。evidence: grill-master:261 E8 think 两语义 + 我 A05/CC-B3。

**2 minor（fold 进 notes，不单列 bullet）**：① 氛围灯边缘爆发 5s（A06）= visual_only 动画，触发=`ambient.color` delta，5s 时长是 presentation 非 runtime gate（RPB-11 覆盖）② 次要族 fade（A01/A08）需「active family set」信号（多 active 时哪些族亮，A03/A04），靠 snapshot 的 activeCell 集（RPB-30 与 RPB-51 覆盖）。

**结论**：50 → **53**（补 card sibling / force-state context / think 两语义）。RPB-51 最关键——它修正了我「制冷热色=纯 visual_only」的分类（实际依赖 snapshot 带 sibling）。

---

## ① P1 决策表（RPB-26~40）

| ID | decision | owner | landing | before-bridge | evidence (file:line) | residual risk |
|---|---|---|---|---|---|---|
| **RPB-26** 现态推理（我有点冷/热）| accept_contract（demo 规则相对/LoRA later）| shared bridge+later | code | yes（C3 reuse）| 主线 C3 `normalizeNumericValue:235` `EXP:242` + SD20/A02 | demo 走 C3 相对 EXP 或场景宏；真 LoRA 感受推理 DEFERRED |
| **RPB-27** 复用 C3 normalize | accept_contract（复用不重复）| shared bridge | code | yes | 主线 C3 `normalizeValue:192/235/242`（EXP vs current store）| UIUE 禁自建相对调温逻辑，走 bridge 调 C3 |
| **RPB-28** range 源 | accept_contract（**已委托 A2**）| shared bridge | done | yes | uiue `ValueRangeMapper`→`StateCellContractLookup`（4b 已做）| 已 done，无重复 range 规则 |
| **RPB-29** active cell 优先 | accept_contract | shared bridge+UIUE | code | yes | 我 CC1/CC3/CC-B1 | refused cell 可压过 satisfied（unsafe/changing 优先显主卡）|
| **RPB-30** snapshot card schema | accept_contract（🔴 + sibling/activeCell，见 RPB-51）| shared bridge | OpenSpec | no | 我 SD20+CC1；主线 card per-cell 无 sibling | 必加 `siblingCells`/`mode`+`activeCell`+`scope_origin`+`reason`（否则制冷热色/CC1 渲不出）|
| **RPB-31** family 覆盖 | accept_contract（10 族 + context）| shared bridge | doc | yes | SD13 10族31base + C环境 context + 范式 MVP10族 | 天气/时段=context（RPB-19）非第 11 族车控卡 |
| **RPB-32** dialogue 所有权 | accept_contract | shared bridge+UIUE | OpenSpec | no | SD2/D8.3/E2 | runtime readback(机器真相)/assistant TTS copy/inline 染色(presentation) 分层；禁 bubble 硬编 runtime proof |
| **RPB-33** orb 状态源 | accept_contract（composite）| shared bridge+UIUE | code | yes | E1/E2/E8 四态 | idle/listen(ASR)+think(analyzing 事件驱动/安全固定)+speak(TTS)；think 两语义见 RPB-53 |
| **RPB-34** 低电量/reduce-motion | accept_contract | UIUE | code | yes | tokens.md §4 双通道铁律 + V4 | 每态非动画通道(色/图标/标签/值/reason)，motion-only 不算 proof |
| **RPB-35** Mac/iOS parity | accept_contract | shared bridge | OpenSpec | no | AD-5 双端独立 + V12 | bridge 字段双端**一致**；布局差异(V12 Mac 左右分栏 vs iPhone 竖)=layout-only |
| **RPB-36** 真机 gap | accept_contract | later | doc | yes | amend + V10（投屏≠真机）| 模拟器截图≠真机音频/性能/热；首个真机门单独标 |
| **RPB-37** 离线 bundle | accept_contract | shared bridge | doc | yes | CLAUDE §4（Python 零进 iOS + 离线）| runtime demo 无网无 Python（宪法红线）|
| **RPB-38** 持久化边界 | accept_contract（仅 DialogueState 3 轮）| shared bridge | code | yes | 范式 §12 H（短时记忆 3 轮砍长时云）| 无 persistence/cloud/long memory |
| **RPB-39** 错误态 copy | accept_contract | shared bridge | OpenSpec | no | D7（unknown=crash 中性灰 ≠ unsupported 灰锁）+ c06 | `crash`/unknown 视觉态禁用于 normal unsupported/refusal 路径 |
| **RPB-40** 设置/复位 | accept_contract | shared bridge+UIUE | code | yes | SD8 + SD1 reset | theme=presentation-only；场景宏 force/reset/force-state=runtime input（影响 RPB-52）|

**P1 小结**：15 全 accept_contract（RPB-28 已 done / RPB-26 含 LoRA later 分支）。无 reject。**与我 grill 高度对齐**（RPB-29=CC1/CC3、RPB-33=E8、RPB-34=双通道、RPB-38=DialogueState 3 轮均已 grill），新增硬化点 = RPB-30 card schema 带 sibling（RPB-51）。

---

## ② P2 决策表（RPB-41~50，治理/流程/proof-cap，磊哥 2026-06-25 提示补全 → 53 个全确认）

> P2 多是**治理/流程/proof-cap 红线**，项目多数已在遵循（receipt/proof cap/no-stale-SHA/carry-forward/OpenSpec landing），此处显式确认。

| ID | decision | owner | landing | 说明 |
|---|---|---|---|---|
| **RPB-41** golden-run 关系 | defer_to_bridge | later | doc 标注 | UIUE scripted runs（anchor set/force-state）= **未来 golden-run 候选**，**非现在 golden-run 证据**（DEFERRED post model gate）|
| **RPB-42** candidate 比较 | accept_contract（红线）| later | proof cap | 🔴 UIUE 视觉**绝不选模型候选**；candidate-comparison = later mainline |
| **RPB-43** training 含义 | accept_contract（红线）| later | DEFERRED | UIUE 文案/case **可能** later 产训练例，但**禁从 storyboard 文本直接写训练数据**（须独立 data contract）|
| **RPB-44** Accessibility | DEFERRED | later | RPB-44 占位 | SD23 已决 a11y DEFERRED（demo 非视障场景；双通道 RPB-34 部分覆盖无障碍精神）|
| **RPB-45** 截图锚点命名 | accept_contract | UIUE | anchor-set 约定 | anchor 图含 platform/state/**proof-class**/source-doc ref（gptimage2-anchor-set README 已有承接 grill+类型+主题，补 proof-class）|
| **RPB-46** receipt 格式 | accept_contract | UIUE | closeout-receipt-writer | UIUE runtime demo receipt = command / device-sim / proof-class / touched-files / residual-risk（已有 skill）|
| **RPB-47** merge-readiness 标记 | accept_contract | UIUE/bridge | CURRENT 标签 | 「contract aligned not merged」标签 = CURRENT.md `proposed_strict_valid_contract_only`（已落）|
| **RPB-48** no stale SHA | accept_contract | UIUE | review 纪律 | reviewer 必告 live HEAD（amend + 本审计 + CURRENT 更新都已做 = `9cf1af2`）|
| **RPB-49** carry-forward | accept_contract | UIUE | 本文 carry-forward 段 | 未决 P0/P1 → 下个 closeout 不埋 prose（= 下方 carry-forward 段）|
| **RPB-50** OpenSpec landing | accept_contract | shared | landing-matrix §6 | 哪些落 bridge OpenSpec / 哪些留 UIUE notes（= landing-matrix §6 + A-1 bridge change 已做）|

**🔴 53 个 runtime 决策全确认**：P0（01~25）24 accept + 1 defer / P1（26~40）15 accept / **P2（41~50）8 accept + 1 defer + 1 DEFERRED** / 补漏（51~53）3 accept。无 reject。RPB-14/RPB-08 补漏厘清完。全部落 A-1 `define-runtime-presentation-bridge` change 契约。

---

## carry-forward（未决/留 bridge，必抄进下个 UIUE closeout，不埋 prose）

> 🔄 **更新 2026-06-25**（A-1 accepted + P1/P2 done + bridge 创建 + A-2 文档先行后；原状态已 stale，下面是当前态）。

**✅ 已 resolved（原 carry-forward 项）**：
- P1 RPB-26~40 ✅ 决策完 / P2 RPB-41~50 ✅ 完（磊哥提示补）/ 补漏 RPB-51~53 ✅。
- thin `define-runtime-presentation-bridge` OpenSpec change ✅ **已创建 + strict valid + 磊哥 accepted**（A-2 可消费 mock snapshot）。
- RPB-01 边界 override ✅ 决策完（accept_contract：SD7 放宽限「snapshot 消费 + bridge 事件写入」非自由 store mutate；已落 ui-presentation **AD-14 §六边界**）。

**🔴 仍未决 / DEFERRED（carry 到下个 closeout）**：
- **RPB-16 真多意图 splitter** = DEFERRED runtime backend（Phase4/5 用 sequencer+force-state；NLU splitter 独立立项，post model gate）。
- **scope_origin `missing` 第 4 值仲裁**：bridge AD-RPB-011 提议 `missing`，Core `ScopeOrigin` 仅 3 值（defaulted/explicit/fanout）→ mainline co-author 定（扩 enum or 删 bridge missing）。
- **scope_origin presentation 消费未实装**：G18 淡显角标策略决了，`Core/Contracts/ContractLookups.swift` renderReadback 仍恒替换 scope → 待 default-scope apply（G01-G28 R-L17 blocker）+ A-2 8.A3/7.A3。
- **bridge runtime 侧实装**：DEFERRED（mainline co-author review + post model gate）。

**proof cap（standing）**：本决策表只为契约讨论 + UIUE grill 收口，**不声称** C6/模型质量/retrain/golden-run/voice/endpoint/真机 V-PASS。

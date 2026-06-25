# UIUE Landing Matrix — confirmation sweep（234 grill 落地态盘点 + ② change 集 scoping）

---
status: landing_matrix
artifact_kind: confirmation_sweep
authority: discussion_input_not_ssot
created_at: 2026-06-25
inputs: [docs/UIUE-checklist.md（234）, RPB-01~53, SD1-SD24, V1-V12, CC*, AD-1~14, G01-G28]
proof: local repo grep（openspec/specs + openspec/changes + Core/Presentation + App + phase matrix）
---

> 磊哥步骤 2：confirmation sweep。诚实回答「234 grill 是否确认落地」+ scope ②。
> 🔴 **核心结论（completion-claim-triage 铁律：计划态 ≠ 执行态）**：234 是「**已 grill 拍板**」（决策态），**不是「已确认落地 spec/code」**（执行态）。盘点后定性 = **已落（契约 C1/C2/C3/C6 + UIUE 4a/4b/4c）/ 仅 grill 待落（本 session 视觉块 SD18-24 + V1-V12 + corner case + RPB bridge + default-scope apply，是主体）/ DEFERRED（Phase5 orb + 训练/C6/voice/runtime backend）/ 少量 superseded**。**234 远未「确认完毕」**——尤其本 session 的视觉块（SD18-24）+ runtime bridge（RPB）几乎全 待落。

## 一、landing 状态总览（系列 × 状态，grep 证据）

| 系列 | 数量 | 已落 spec | 已落 code | 仅 grill 待落 | DEFERRED | superseded |
|---|---|---|---|---|---|---|
| **契约 C1/C2/C3/C6** | — | ✅ `openspec/specs/{semantic-function-contract,scenario-state-protocol,tool-execution,vehicle-tool-bench}` | C3 mainline / A2 D-domain | — | — | 旧口径534/B-frame |
| **AD-1~14**（架构）| 14 | ui-presentation `specs/ui-presentation/spec.md`（部分）| 4a/4b/4c ✅（见 phase matrix）| AD-13/14 design / 连续舞台 | AD-12 三zone/AD-8 思考链路（Phase5）| 物理置顶→AD-12 |
| **D1-D8**（交互）| 14 | — | D1/D2/D3/D5/D7 落 4a/4b/4c code | D8 部分 | D8.3 思考链路（Phase5）| — |
| **E0-E8**（orb/事件驱动）| 9 | — | — | — | ✅ **全 Phase5**（orb 未 code）| — |
| **U1-U31**（UIX）| 31 | — | U6/U10/U13/U26 落 code | 多数 待落 | U5/U24/U28（Metal/投屏/TTS=Phase5/voice）| — |
| **SD1-SD24**（本 session 演绎）| 24 | — | 仅 4a/4b/4c 重叠部分 | 🔴 **几乎全 待落**（SD18-24 视觉块/corner case/context capsule）| — | V6 跟随系统→强制色 / C-ASR-fail 没听清→二分 |
| **V1-V12**（视觉块）| 12 | — | — | 🔴 **全 待落**（tokens.md 是 design SSOT，DesignTokens.swift code 未更）| — | — |
| **CC1-4 + CC-A/B/C**（corner case）| ~18 | — | — | 🔴 **全 待落**（UIValueTypeMapper 无 activeCell 逻辑）| CC-A5 多意图 runtime | — |
| **RPB-01~53**（runtime bridge）| 53 | — | — | 🔴 **全 待落**（bridge change 未创建）| shared_bridge_contract 实装 DEFERRED | — |
| **G01-G28**（default-scope）| 28 | `define-demo-default-scope`（proposal 提议）| — | 🔴 待 apply（Phase -1 R-L17 blocker）| — | — |
| **锦标赛 R1-R5** | 41 | A2/范式落 specs+code（migrate-d-domain merged main）| A2 ✅ | — | C5/C6/voice 相关 | 旧534系列 |

## 二、已落地的（confirmed，可信）

- **✅ 契约 spec**：`openspec/specs/` 7 个（semantic-function-contract/scenario-state-protocol/tool-execution/vehicle-tool-bench/demo-experience/vehicle-capabilities/lora-training）= C1/C2/C3/C6 + 派生。
- **✅ UIUE 4a/4b/4c code**（uiue `Core/Presentation/` 8 文件 + `App/` 6 文件，swift test 222/0）：
  - AD-9 10族常驻（FamilyCardIDMapper/ContentView）/ AD-2·U26 value.type enum+switch（UIValueTypeMapper/ValueControlView）/ AD-10 primary cell+scope聚合（FamilyPrimaryCellMapper/ScopeAggregationResolver）/ AD-11 摘要+展开（ExpandedFamilyDisplay/Card）/ AD-3 触发聚焦（FocusController）/ AD-4 multi-intent stagger（MultiCallSequencer）/ AD-1·D7·U10 7态（DesignTokens.CardAppearance）/ ValueRangeMapper 委托 A2。
- **✅ A2 D-domain**：migrate-d-domain-tool-surface merged main（C1→C6 surface）。

## 三、🔴 仅 grill 待落（决策态，未进 spec/code）—— 这是 ②的活

> 这些是「已拍板但没落地」的——**正是 234「未确认完毕」的主体**。

| 待落项 | 现状 | 落点（②）|
|---|---|---|
| **SD18 V1-V12**（间距/字体/圆角/theme/连续舞台/注意力/图标/验收/duration/密度）| tokens.md §3.1/§6/§7/§8 = design SSOT（DRAFT），DesignTokens.swift code **未更**；ContentView **非连续舞台** | ui-presentation change 更新（AD-14+ + spec + tasks + DesignTokens 实装）|
| **SD19/20/21 corner case + 制冷热 + gptPRO细节** | UIValueTypeMapper **无 activeCell/制冷热色/range bar/mode图标/fade** | ui-presentation（visual_only 部分）+ bridge（activeCell 数据）|
| **SD22 层级滚动** | ContentView 无 z-stack/scroll inset/手动滚 flag/fade-by-active | ui-presentation |
| **SD23 边界态**（mic-only/portrait/30字/ASR二分/族外）| ContentView **仍有 TextField**（未移除）；无 portrait lock | ui-presentation + bridge（ASR fail/族外 runtime event）|
| **SD24 context capsule** | 顶栏未重构（品牌未去/图标未移角/无 ContextCapsule）| ui-presentation（呈现）+ bridge（context 数据 RPB-19）|
| **RPB shared_bridge_contract**（activeCell/refusedCell/partial-deny/already_state/8类结果枚举/event/snapshot/trace/card sibling schema）| bridge **未建**（4 对象 vocabulary 仅 roadmap 提议）| 🔴 **define-runtime-presentation-bridge change（新建，未创建）** |
| **G01-G28 default-scope** | proposal 提议，**未 apply**（Phase -1 R-L17 blocker）| define-demo-default-scope（apply 待 R-L17）|

## 四、DEFERRED（明确延后，不阻塞 demo 视觉收口）

- **E0-E8 orb / AD-12 三zone+活跃置顶 / AD-8 思考链路**：Phase 5（orb 未 code）。
- **U5 Metal / U24 投屏 / U28 TTS**：Phase5/voice。
- **C5 训练**（retrain-c5/run-lora-candidate-training/lora-data-gate）/ **C6 rebuild**（rebuild-c6-four-layer-bench）/ **voice+golden-run**（define-demo-golden-run-and-voice）/ **runtime backend + bridge 实装**：post model gates，独立立项。

## 五、superseded（已被推翻，标 historical 不再引）

- 物理置顶 → AD-12 原地放大 / 旧口径 534 与 2086 → 562 / 范式 B-frame → D-domain / V6 SD11「跟随系统」→ 强制色 / C-ASR-fail「没听清」→ empty 静默+no-match unsupported。

## 六、② change 集 scoping（不止 define-runtime-presentation-bridge，磊哥点对）

| change | 类型 | 装什么 | 状态 |
|---|---|---|---|
| **ui-presentation**（已存在）| 更新 | SD18-24 visual_only（V1-V12/连续舞台/层级滚动/context capsule 呈现/corner case 视觉/边界态）→ AD-14+ + spec + tasks + DesignTokens/ContentView 实装 | 待更新 |
| **define-runtime-presentation-bridge**（🔴 新建）| 新建 | RPB shared_bridge_contract（activeCell/refusedCell/partial-deny/already_state/8类结果枚举/4对象 vocabulary/card sibling schema）| 待创建（roadmap 规划）|
| **define-demo-default-scope**（已存在）| apply | G01-G28 | 待 apply（R-L17 blocker）|
| retrain-c5 / rebuild-c6 / golden-run-voice（已存在）| DEFERRED | C5/C6/voice | post model gates |

🔴 **demo 轻治理分诊**（不是每项都落 spec）：
- **契约级必落 spec**：bridge 4 对象 vocabulary（行为契约，防 UIUE/backend 字段漂移）→ define-runtime-presentation-bridge。
- **行为契约级落 ui-presentation spec**：7态映射/value.type/scope-origin/连续舞台硬约束/已落的 4a-4c。
- **实装笔记够（不落 spec）**：纯视觉细节（间距具体 px/动效 ms/制冷热 hex/fade opacity）→ tokens.md（design SSOT）+ code 注释，不进 spec（demo 轻治理，spec 只写可观察行为不写实现）。

## 七、诚实总账（答磊哥「234 确认完了吗」）

**没有。** 234 是 grill 决策集（计划态），盘点后（定性，非精确计数）：
- **已落 spec/code（主干）**：契约 C1/C2/C3/C6 + UIUE 4a/4b/4c。
- **仅 grill 待落（主体）**：🔴 **本 session 视觉块 SD18-24 + V1-V12 + corner case + RPB bridge（53 项）+ default-scope apply** —— 这些是「拍了没落」，② 的主体活。
- **DEFERRED（一批）**：Phase5 orb/三zone + 训练/C6/voice/runtime backend。
- **superseded（少量）**。

**下一步建议**：② 不是「落一个 change」，是 **③ 步骤**——① 更新 ui-presentation change 装 SD18-24 visual（含 DesignTokens/ContentView 实装）② 新建 define-runtime-presentation-bridge 装 RPB 契约 ③ default-scope apply（待 R-L17）。**先 ①②（视觉 + bridge 契约，不依赖 model gate），③ 训练/voice DEFERRED。**

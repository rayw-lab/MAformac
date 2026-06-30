# UIUE Landing Matrix — confirmation sweep（234 grill 落地态盘点 + ② change 集 scoping）

---
status: landing_matrix
artifact_kind: confirmation_sweep
authority: discussion_input_not_ssot
created_at: 2026-06-25
updated_at: 2026-06-26
inputs: [docs/UIUE-checklist.md（234）, RPB-01~53, SD1-SD25, V1-V12, CC*, AD-1~14, G01-G28]
proof: local repo grep（openspec/specs + openspec/changes + Core/Presentation + App + phase matrix）
---

> 磊哥步骤 2：confirmation sweep。诚实回答「234 grill 是否确认落地」+ scope ②。
> 🔴 **核心结论（completion-claim-triage 铁律：计划态 ≠ 执行态）**：234 是「**已 grill 拍板**」（决策态），**不是「已确认落地 spec/code」**（执行态）。2026-06-26 A-2 执行后，状态推进为：**A-2 Phase 3/4/5/6 simulator/mock scope DONE；Phase 2 continuous-stage visual acceptance `8.A/8.C2` 仍 open；runtime backend/true-device/mainline proof 仍未声称**。本文件是 landing matrix，不替代 `docs/grill-checklist/uiue-a2-grill-coverage-index.md` 的消减账本。

## 一、landing 状态总览（系列 × 状态，grep 证据）

| 系列 | 数量 | 已落 spec | 已落 code | 仅 grill 待落 | DEFERRED | superseded |
|---|---|---|---|---|---|---|
| **契约 C1/C2/C3/C6** | — | ✅ `openspec/specs/{semantic-function-contract,scenario-state-protocol,tool-execution,vehicle-tool-bench}` | C3 mainline / A2 D-domain | — | — | 旧口径534/B-frame |
| **AD-1~14**（架构）| 14 | ui-presentation `specs/ui-presentation/spec.md`（部分）| 4a/4b/4c ✅（见 phase matrix）| AD-13/14 design / 连续舞台 | AD-12 三zone/AD-8 思考链路（Phase5）| 物理置顶→AD-12 |
| **D1-D8**（交互）| 14 | — | D1/D2/D3/D5/D7 落 4a/4b/4c code | D8 部分 | D8.3 思考链路（Phase5）| — |
| **E0-E8**（orb/事件驱动）| 9 | — | — | — | ✅ **全 Phase5**（orb 未 code）| — |
| **U1-U31**（UIX）| 31 | — | U6/U10/U13/U26 落 code | 多数 待落 | U5/U24/U28（Metal/投屏/TTS=Phase5/voice）| — |
| **SD1-SD25**（本 session 演绎）| 25 | ui-presentation §8 + A-1 bridge contract | UIUE 4a/4b/4c + A-2 P3/P4/P5/P6 simulator/mock proof；P2 visual code/evidence slice PARTIAL | 🔴 **Phase 2 visual gate 仍待落**（SD18/22/23/V-series + `8.A/8.C2`）| true ASR/TTS/backend/true-device | V6 跟随系统→强制色 / C-ASR-fail 没听清→二分 |
| **V1-V12**（视觉块）| 12 | tokens.md + ui-presentation §8 | P2 has DesignTokens/ContentView/ThermalRangeBar/capsule placement code + v72 screenshots | 🔴 **visual 5-gate/human anchor review 未闭** | V10 投屏验收/true-device | — |
| **CC1-4 + CC-A/B/C**（corner case）| ~18 | ui-presentation §8 + bridge vocabulary | activeCell/siblingCells/thermal mapper + P3 mock interaction/voice route | 🔴 P2 visual rows +部分多意图/拒识演出仍待 visual gate | CC-A5 多意图 runtime | — |
| **RPB-01~53**（runtime bridge）| 53 | ✅ `define-runtime-presentation-bridge` change（创建+strict valid+磊哥 accepted）| A-2 mock-frontstage consumes snapshot/activeCells/sibling/context force for UI proof | 部分 RPB groups remain unchecked until visual/backend gates | runtime 侧实装 DEFERRED | — |
| **G01-G28**（default-scope）| 28 | `define-demo-default-scope`（proposal 提议）| — | 🔴 待 apply（Phase -1 R-L17 blocker）| — | — |
| **锦标赛 R1-R5** | 41 | A2/范式落 specs+code（migrate-d-domain merged main）| A2 ✅ | — | C5/C6/voice 相关 | 旧534系列 |

## 二、已落地的（confirmed，可信）

- **✅ 契约 spec**：`openspec/specs/` 7 个（semantic-function-contract/scenario-state-protocol/tool-execution/vehicle-tool-bench/demo-experience/vehicle-capabilities/lora-training）= C1/C2/C3/C6 + 派生。
- **✅ UIUE 4a/4b/4c code**（uiue `Core/Presentation/` + `App/`，swift test historical 222/0；A-2 later mechanical receipt records 245 tests / 0 failures）：
  - AD-9 10族常驻（FamilyCardIDMapper/ContentView）/ AD-2·U26 value.type enum+switch（UIValueTypeMapper/ValueControlView）/ AD-10 primary cell+scope聚合（FamilyPrimaryCellMapper/ScopeAggregationResolver）/ AD-11 摘要+展开（ExpandedFamilyDisplay/Card）/ AD-3 触发聚焦（FocusController）/ AD-4 multi-intent stagger（MultiCallSequencer）/ AD-1·D7·U10 7态（DesignTokens.CardAppearance）/ ValueRangeMapper 委托 A2。
- **🟡 A-2 execution proof**（isolated UIUE worktree, not mainline proof）：Phase 3 touch + voice mock, Phase 4 control panel/settings/macro/reset, Phase 5 ambient burst, Phase 6 context capsule are DONE for simulator/mock scope; Phase 2 continuous-stage remains PARTIAL pending visual 5-gate and anchor-level human review. Closeout: `docs/research/2026-06-25-a2-execution/a2-phase-closeout-receipt.md` + 601-line report.
- **✅ A2 D-domain**：migrate-d-domain-tool-surface merged main（C1→C6 surface）。

## 三、🔴 仅 grill 待落（决策态，未进 spec/code）—— 这是 ②的活

> 这些是「已拍板但没落地」的——**正是 234「未确认完毕」的主体**。

| 待落项 | 现状 | 落点（②）|
|---|---|---|
| **SD18 V1-V12**（间距/字体/圆角/theme/连续舞台/注意力/图标/验收/duration/密度）| DesignTokens/ContentView/四 zone/米白+深空 theme 已有 A-2 P2 partial code + v72 evidence；**visual 5-gate 未闭** | resume `8.A/8.C2` visual acceptance |
| **SD19/20/21 corner case + 制冷热 + gptPRO细节** | activeCell/siblingCells/SemanticColorMapper/ThermalRangeBar/mode icon 已实装；**anchor-level visual acceptance 未闭** | resume Phase 2 visual gate |
| **SD22 层级滚动** | P2 has z-stack/stage/dock/scroll-area implementation evidence；coverage still open pending human visual gate | ui-presentation `8.A/8.C2` |
| **SD23 边界态**（mic-only/portrait/30字/ASR二分/族外）| App no longer has `TextField`; pbxproj has portrait-only orientation; P2 boundary still **PARTIAL** until visual/anchor review | ui-presentation `8.A/8.C2` + later voice/backend |
| **SD24/25 context capsule diorama** | ContextCapsule + route spike + assets/video loop landed for simulator scope; true-device GPU/FPS and final art deferred | ui-presentation 8.B done in simulator scope; true-device later |
| **RPB shared_bridge_contract**（activeCell/refusedCell/partial-deny/already_state/8类结果枚举/event/snapshot/trace/card sibling/context 四维）| ✅ bridge change accepted; A-2 mock-frontstage consumes activeCells/sibling/context force; runtime-side implementation remains DEFERRED | future runtime bridge implementation |
| **G01-G28 default-scope** | proposal 提议，**未 apply**（Phase -1 R-L17 blocker）| define-demo-default-scope（apply 待 R-L17）|

## 四、DEFERRED（明确延后，不阻塞 demo 视觉收口）

- **E0-E8 orb / AD-12 三zone+活跃置顶 / AD-8 思考链路**：Phase 5（orb 未 code）。
- **U5 Metal / U24 投屏 / U28 TTS**：Phase5/voice。
- **C5 训练**（retrain-c5/run-lora-candidate-training/lora-data-gate）/ **C6 rebuild**（rebuild-c6-four-layer-bench）/ **voice+golden-run**（define-demo-golden-run-and-voice）/ **runtime backend + bridge 实装**：post model gates，独立立项。

## 五、superseded（已被推翻，标 historical 不再引）

- 物理置顶 → AD-12 原地放大 / 旧口径 534 与 2086 → 562 / 范式 B-frame → D-domain / V6 SD11「跟随系统」→ 强制色 / C-ASR-fail「没听清」→ empty 静默+no-match unsupported。

## 六、② change 集 scoping（不止 define-runtime-presentation-bridge，磊哥点对）

> 🔄 **更新 2026-06-26**（A-1 创建+accepted + A-2 Phase 2-6 proof anchors 后；状态列已推进，Phase 2 visual gate 仍 open）。

| change | 类型 | 装什么 | 状态（2026-06-25 更新）|
|---|---|---|---|
| **define-runtime-presentation-bridge**（新建）| 新建 | RPB shared_bridge_contract（activeCell/refusedCell/partial-deny/already_state/8类结果枚举/4对象 vocabulary/card sibling/context 四维）| ✅ **已创建 + strict valid + 磊哥 accepted**（mainline runtime 实现 DEFERRED）|
| **ui-presentation**（已存在）| 更新 | SD18-25 visual_only（V1-V12/连续舞台/层级滚动/context capsule 呈现/corner case/边界态）| 🟡 **A-2 v3 已执行到 Phase 2-6 proof anchors**：P3/P4/P5/P6 simulator/mock DONE；P2 continuous-stage visual remains PARTIAL；`8.A/8.C2` + 5-gate/human anchor review open |
| **define-demo-default-scope**（已存在）| apply | G01-G28 | 待 apply（R-L17 blocker）|
| retrain-c5 / rebuild-c6 / golden-run-voice（已存在）| DEFERRED | C5/C6/voice | post model gates |

🔴 **demo 轻治理分诊**（不是每项都落 spec）：
- **契约级必落 spec**：bridge 4 对象 vocabulary（行为契约，防 UIUE/backend 字段漂移）→ define-runtime-presentation-bridge。
- **行为契约级落 ui-presentation spec**：7态映射/value.type/scope-origin/连续舞台硬约束/已落的 4a-4c。
- **实装笔记够（不落 spec）**：纯视觉细节（间距具体 px/动效 ms/制冷热 hex/fade opacity）→ tokens.md（design SSOT）+ code 注释，不进 spec（demo 轻治理，spec 只写可观察行为不写实现）。

## 七、诚实总账（答磊哥「234 确认完了吗」）

**没有。** 234 是 grill 决策集（计划态），2026-06-26 A-2 执行后（定性，非精确计数）：
- **已落 spec/code（主干）**：契约 C1/C2/C3/C6 + UIUE 4a/4b/4c。
- **A-2 已落 simulator/mock proof**：Phase 3/4/5/6；Phase 2 有 partial visual evidence slice。
- **仍未确认完毕（主体）**：🔴 **Phase 2 visual acceptance `8.A/8.C2` + V-series/SD18/22/23 grouped rows + default-scope apply/mainline runtime/true-device gates**。
- **DEFERRED（一批）**：Phase5 orb/三zone + 训练/C6/voice/runtime backend。
- **superseded（少量）**。

**下一步建议**：不要重开已闭的 Phase 3-6；等用户恢复视觉验收时，从 Phase 2 receipt + `8.A/8.C2` + coverage index 的 V/SD18/SD22/SD23 open rows 继续。

# UIUE Grill 定档（2026-06-25 冻结）+ 作废清单（前后冲突，前者作废）

---
status: frozen_dossier
artifact_kind: grill_freeze
authority: uiue_grill_ssot_frozen
created_at: 2026-06-25
freeze_principle: 前面的决策若与后面冲突，前者标【作废 SUPERSEDED】，以后者为准
inputs: [grill-decisions-master, storyboard SD1-SD24, RPB-01~53, landing-matrix, AD-1~14, V1-V12, CC*, G01-G28]
---

> 磊哥 2026-06-25：全部 grill 先定档；前面的若与后面冲突，前面标作废。本文 = **UIUE grill 冻结快照 + 作废 registry**（claim-vs-reality §10 防段间分叉的机械门）。
> 🔴 **权威单源**：定档后，UIUE grill 决策以【本文 + 各源文档非作废段】为准；引用任何 grill 决策前先查本文作废清单，**作废项不得再引**。

## 一、🔴 作废清单（SUPERSEDED registry，前者作废以后者为准）

| # | 作废项（前）| 被取代为（后）| 出处 | 原因 |
|---|---|---|---|---|
| **S1** | SD11「light-dark 双值**跟随系统**」| **V6 强制色**（ivory→`.light`/deepSpace→`.dark` 不跟随系统，2 套 token）| SD18 V6 / SD24 / tokens.md §8 | demo 投屏稳定，不被系统 dark 干扰 |
| **S2** | V7 顶栏「品牌 MAformac + 刷新设置在 floating 白卡内」| **SD24 重构**：品牌**去掉** + 刷新/设置**右上角 standalone** + 中间 **context capsule** | SD24 | context 映射 + 顶栏释放 |
| **S3** | CC-B2「行驶态**纯话术**不显语境」(A 方案)| **SD24 context capsule**（顶部持续动效显行驶中/雨/夜 context）| SD24 | 演示需客户感知语境才理解 R2 拒识 |
| **S4** | C-ASR-fail「ASR **没听清**独立态 + 重试」| **SD23 二分**：① empty 静默回 idle ② no-match → unsupported | SD23 | 苹果 ASR 总出文本，无独立「没听清」态（磊哥纠）|
| **S5** | 物理置顶（活跃族移到第一位）| **AD-12 原地 1.3x 放大不重排** + ScrollViewReader 滚入视野 | AD-12 / SD18 D1 | 守 spatial memory（6-lens 调研）|
| **S6** | AD-12 早期 CC 自拍「动态分配」| **固定全景 + hero 放大**（AD-12 自纠）| AD-12:122 | 同 S5，调研修正 |
| **S7** | 低电量降级 corner（为低电量做双通道）| **DROP**；双通道铁律**改理由**（state 可读性非低电量）| SD23 | 磊哥自用电量充足，低电量不会发生 |
| **S8** | D15「文本先行」在 **demo UI 留文本输入**（TextField+执行按钮）| **SD23 移除 TextField，纯语音 push-to-talk** | SD23 / G-UI2 | 不搞文本打字（D15 dev 开发序保留，demo UI 文本作废）|
| **S9** | 旧口径（534 等作废历史值）| **562**（磊哥终拍）| caliber-562 | 口径统一（intent 全集）|
| **S10** | 范式 B-frame（generic `tool_call_frame`）| **D-domain 具名工具** | paradigm-amend | 1.7B 学不会 generic 判定面（第4源 ground-truth）|

**refinement（扩展非作废，标注）**：
- **R1** SD20「制冷热只下划线」→ SD21 **扩**为下划线 + hero range bar + mode 图标（❄️/热浪）。SD20 仍有效，SD21 扩展。
- **R2** SD21 fade「按屏幕位置淡显」→ SD22 **修正**为按 active（非位置，防滚动闪烁）。

## 二、权威当前 grill 索引（定档后以这些非作废段为准）

| 系列 | 权威源 | 状态 |
|---|---|---|
| 锦标赛 41 / D/E/U/Q / 范式 | `docs/grill-tournament/grill-decisions-master.md` + paradigm-amend | 冻结（旧534/B-frame 已作废 S9/S10）|
| 用户故事演绎 SD1-SD24 | `docs/uiue-storyboard-grill-decisions.md` | 冻结（S1-S8 作废项见上）|
| 视觉块 V1-V12 | SD18 + `tokens.md` §3.1/§6/§7/§8 | 冻结（V6 强制色 = S1 取代源）|
| corner case CC* | SD18/19/20/21/22/23 | 冻结（CC-B2 = S3 作废 / C-ASR-fail = S4 作废）|
| context capsule | SD24 | 冻结（= S2/S3 取代源）|
| runtime bridge RPB-01~53 | `docs/grill-checklist/uiue-runtime-bridge-decisions-2026-06-25.md` | 冻结（见三）|
| default-scope G01-G28 | `docs/grill-tournament/demo-default-scope-grill-decisions-2026-06-24.md` | 冻结（待 apply）|
| landing 态 | `docs/grill-checklist/uiue-landing-matrix-2026-06-25.md` | 冻结 |

## 三、runtime（RPB）状态 = ✅ 决策 OK（实装 DEFERRED）

- **RPB-01~25 P0**：24 accept_contract + 1 defer（RPB-16 真 splitter）✅ 决策完。
- **RPB-26~40 P1**：15 全 accept_contract ✅ 决策完。
- **RPB-41~50 P2** + **RPB-51~53**（anchor 补漏：card sibling / force-state context / think 两语义）✅ 决策完。
- **补漏厘清**：RPB-14 already_state（独立结果枚举 + satisfied+ack 视觉）+ RPB-08（source ≠ scope_origin 两正交字段）✅。
- 🔴 **runtime 决策 OK = 是**（契约层全拍）；但**实装 DEFERRED**（bridge 4 对象 vocabulary 待 OpenSpec 冻结 + 主线 runtime 投影待建）。

## 四、非 UIUE 主线还要做哪些（才能继续/启动）

> 区分「UIUE 能否独立 A」vs「整体 demo 启动需主线什么」。

**UIUE 可独立做 A（不阻塞于主线）**：
- ui-presentation 更新（视觉实装）+ define-runtime-presentation-bridge **契约提议**（UIUE 在隔离 worktree 提，主线 review/co-author）= UIUE 侧，**不需主线先动**。

**主线（非 UIUE）pending（整体 demo 启动需要，多数 DEFERRED）**：
| 主线工作 | 性质 | 时机 |
|---|---|---|
| bridge runtime 投影实装（guardDenied→refusal snapshot RPB-12 / activeCell·refusedCell / already_state_noop / card sibling schema / 4 对象）| shared bridge | 契约 accept 后（post A②）|
| FastPathIntentEngine 扩（现只认「打开空调」）→ 真意图/多意图 splitter（RPB-16）| runtime backend | **DEFERRED**（post model gate）|
| SceneMacroRegistry 建（Core scenario-macros.yaml + Matcher，E3/E4）| shared runtime | DEFERRED |
| C5 retrain（D-domain LoRA）/ C6 rebuild 四层评测 / voice ASR-TTS / golden-run | model/voice | **DEFERRED**（post model gates，独立立项）|

🔴 **结论**：**UIUE 做 A（视觉 + bridge 契约）现在可启动，不卡主线**；主线 runtime 投影在契约 accept 后做；**整体 live demo 启动**需主线 runtime backend + C5 + voice（全 DEFERRED，post model gates）。**UIUE 是呈现层，可先用 mock runtime 视觉完整，live demo 等主线 runtime。**

## 五、定档后下一步 = A（高质量，非骨架）

磊哥定 A 但**要高质量非骨架**：
1. **ui-presentation change 更新**（高质量）：AD-14+ 装连续舞台/层级滚动/context capsule/corner case/边界态 + spec（可观察行为）+ tasks + **DesignTokens/ContentView 高质量实装**（不是骨架，是真连续舞台 + 7态 + 制冷热 + capsule 全实现）。
2. **define-runtime-presentation-bridge change 新建**（高质量）：proposal + design（4 对象 vocabulary 完整字段）+ spec（行为契约）+ tasks，thin 不碰 backend 实现但**契约完整**。
3. 守 agree-before-build（文档先行）+ demo 轻治理分诊（契约落 spec / 视觉细节落 tokens+注释）。

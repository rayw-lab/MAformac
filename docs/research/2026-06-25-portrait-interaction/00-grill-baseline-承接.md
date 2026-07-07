---
type: portrait-interaction-grill-baseline
status: 承接基线（主线程亲核参照，2026-06-25）；synth 回稿后对此核「调研有无漏承接/矛盾」
date: 2026-06-25
owner: UIUE 链路A（worktree MAformac-uiue）
sources: docs/grill-tournament/{uiue-d1-d6-grill.md, uiue-phase4-grill-decisions.md, grill-decisions-master.md §3} + raw/.../2026-06-22-uiue-ultracode/ + Phase5 handoff
---

# 竖屏全局 iOS 交互 — 已 grill 决策承接基线（亲核参照）

> 🔴 CC 主窗口承接 D1-D6 交互 grill + Phase4 grill + 8-lens ultracode + Phase5 E0-E8 后整理。**已决=承接不重聊，调研补缺，synth 回稿核此基线有无漏/矛盾。**

## 一、已决竖屏布局（D4 Q4.3 + D5）

- **iPhone 竖屏 = 759pt 三zone**（D4 Q4.3）：`orb 120 / content 440 / mic 80 / gap 119`，`IPhoneLayout` VStack 三 zone `.frame(height:tokens)`，**禁 GeometryReader 自适应**；content_zone 440pt = 竖屏 **10 族 2 列滚动 + 活跃置顶**。pre-commit `check:iphone-zone-height-from-tokens`。
- **Mac 横屏 Grid 2×5 / iPhone 竖屏保 LazyVGrid 滚动**（D5 Q5.2，lens1 F7）。⚠️ **我 4a 用 Grid 双端统一**（非 Mac-Grid/iPhone-LazyVGrid 分化）→ 待调研/亲核裁（Grid+ScrollView 对 10 卡也可，但与 grill 分化决策有出入）。
- **双端 = 两独立纯端侧实例**（D4），iPhone 脱机独立全功能接语音。

## 二、已决交互框架（D1/D2/D5/D6 + E组）

| 维度 | 已决 | 出处 |
|---|---|---|
| 主形态 | **全景常驻 + 触发聚焦**（A 方案，10 族常驻不平铺 191）| D1 |
| 开场 | boot reveal（orb 呼吸 1.5s → 全族 reveal 扫一遍 stagger 100ms → idle dim），`boot_phase` 7 态 enum + `boot_reveal_complete_at`（first_voice happens-after）| D1.Q1.1 |
| 多意图 | **MultiCallSequencer 单点序列化**（stagger 220ms，`MAX_CONCURRENT_HIGHLIGHTS:1`，溢出 queued 微光角标）| D1.Q1.2 |
| idle 态 | dim 微光呼吸（`idle_breathe_alpha 0.04-0.10 period 3.2s`，banding 安全阈值 + dither）| D1.Q1.3 |
| 展开触发 | **voice 主 + tap 辅，同一 `ExpandIntent`**（`ExpandTrigger{voice,tap,goldenRun}` + `FocusController.expand(family,trigger:)` 单点入口）；tap affordance（hover alpha 0.18 + .pointingHand + accessibilityHint）| D2.Q2.1 |
| 展开形态 | 原地放大中卡 + 全景 blur（`blur_radius 12 + .ultraThinMaterial`，Reduce Transparency→solid 0.65）；`MAX_CONCURRENT_EXPANSIONS:1`（与 HIGHLIGHTS 独立 token）| D2.Q2.2/2.4 |
| 子能力 | `family_expand_primary_max:4 + secondary_threshold:6`（超显「+n」折叠角标，从 family_priority.json 派生禁写死）| D2.Q2.3/2.5 |
| 聚焦过渡 | **默认 `opacityScale`**（坑密度最低，1.0→1.15 + 内容淡入 + border glow 0.85，**320ms** spring r0.4 d0.75）+ `matchedGeometry` gated upgrade（macOS 可用已坐实 mge macOS11+，剩 LazyVGrid/ReduceMotion 运行时验）| D5 |
| ripple | 首焦一次性水波（`ripple_on_first_focus max_per_session:10`，Metal layerEffect 独立 ungate，ReduceMotion disable）| D1.Q1.5/D5.Q5.3 |
| 炸场编排 | wow 4 段（S1 ambient_intro / S2 single_focus+ripple / S3 multi_highlight / S4 offline_morph cyan→amber）| D6.Q6.2 |
| orb | 自建多层 MeshGradient + breathing(spring r1.8 d0.7 缩放0.95↔1.05) + hanlin 流光文字 + 四态 idle/think/speak/listen；**零 metasidd/零 Inferno 主体**| E1 |
| 思考链路 | **事件驱动非计时**（think analyzing 掩盖后端→卡片 changing 跳动 `cardsDidStartChanging` 事件→speak readback，3s 虚数）；think 两语义（思考链路掩盖 vs 安全拒识固定 1.0s）；barge-in U21 打断 | E2/E8 |
| DA0 deny | store `applyGuardBlock(key,态,reason)` 非throw + reason→态映射 + 统一 `reasons:[String:String]` @Observable map（cell 无 reason 字段）| E5-E7 |

## 三、已决微交互/动效配方（8-lens decision-matrix）

numericText（必 withAnimation）/ symbolEffect(.bounce 点亮)+spring(.bouncy) / 自研 breathe glow(.repeatForever 非裸 Timer) / sensoryFeedback(.success/.impact 触感，端侧独有) / MeshGradient orb / contentTransition / Liquid Glass 仅功能层（内容卡自研 glow）。

## 四、已决 tokens（设计值，实装验收）

`orb_duration_ms:1500 / reveal_stagger_ms:100 / stagger_delay_ms:220 / idle_breathe_alpha_min:0.04 max:0.10 period_s:3.2 / queue_indicator_alpha:0.4 / ripple_max_per_session:10 / family_expand_primary_max:4 secondary_threshold:6 / blur_radius_when_focused:12 / expansion.duration_ms:320 / tap_affordance_alpha_on_hover:0.18`

## 五、我 Phase 4a 实装 vs 承接基线（待调研+亲核裁）

| 我 4a 做的 | vs 承接 | 裁决 |
|---|---|---|
| FamilyCardIDMapper/FamilyPrimaryCellMapper/familyDisplays(10族+主cell+occupancy+scope聚合) | ✅ 匹配 P4-D2/G1/① BadgeRenderStyle/③ FamilyCardIDMapper | keep |
| Grid 固定列双端统一 | ⚠️ grill D5 是 Mac-Grid/iPhone-LazyVGrid 分化 | 调研裁（统一 vs 分化） |
| 深空 VStack(brandHeader/commandBar/readback/grid) | ❌ 非 D4 759pt 三zone（orb/content/mic）| 4a 布局对齐三zone预留（orb=Phase5 占位） |
| 固定 row_count 排序（全景常驻）| ⚠️ D4 Q4.3 竖屏「活跃置顶」可能要 reorder | 调研裁（全景常驻固定序 vs 竖屏活跃置顶） |
| 缺：触发聚焦接口/tap交互/boot reveal/sequencer高亮/ripple/活跃置顶 | = 4b/4c/Phase5（部分接口该 4a 预留防返工）| 4b/4c 规划 + 4a 预留 FocusController 单入口 |

## 六、调研要补的缺口（6-lens 目标）

竖屏布局形态（全景常驻 vs 活跃置顶 vs 折叠 vs 动态伸缩）/ 全局 iOS 手势体系（tap/long-press/swipe/drag 适配车控+语音多模态防冲突）/ 微交互层级巧思（sheet/.presentationDetents/zIndex/blur 竖屏聚焦范式）/ 三者联动（orb↔对话流↔卡片）编排 / ref-repos 动态布局+自动滚动+手势组合代码范式 / 坑点（键盘/安全区/动态高度跳变/手势冲突/活跃置顶晕眩）。

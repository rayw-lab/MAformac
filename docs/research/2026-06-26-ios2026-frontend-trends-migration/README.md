---
type: research-synthesis
status: 综合报告（二手派生综合；一手见同目录 *-raw.md / oracle-*-firsthand.md）
date: 2026-06-26
topic: 2026-04 后 iOS app 前端框架/视觉组件/交互封装趋势 × MAformac 可迁移价值
commander: claude-commander（ma-ios-research tmux session）
inputs:
  - codex-repo（repo researcher，审 main 树）→ codex-repo-raw.md
  - codex-web（web researcher，2026 趋势）→ codex-web-raw.md
  - hermes-critic（skeptical critic，glm-latest xhigh）→ hermes-critic-raw.md
  - oracle scout #1（Liquid Glass 坑+版本核实，Claude subagent web）→ oracle-liquid-glass-firsthand.md
  - oracle scout #2（resizable/toolbar/reorder/TCA 坑）→ oracle-shell-nav-reorder-firsthand.md
  - 既有 premortem（2026-06-24-ios26-lock-d7-premortem）— 本仓已有，cite 不重复造
cited_tree: /Users/wanglei/workspace/MAformac-uiue（uiue/phase4-default-scope-presentation @ 2959cab）
authority: research_not_ssot（决策 SSOT 仍是 grill-decisions-master / design.md AD-1~AD-13）
---

# 综合报告：2026 iOS 前端趋势 × MAformac 适配性筛选

> 标题刻意**不**叫"升级路线图"（采纳 hermes #1：别被"2026 新 UI 叙事"牵走）。这是**面向 MAformac demo 的适配性筛选 + 现有用法的 hardening spike**。

## 〇、执行结论（30 秒版）

🎯 **核心反转：MAformac UIUE 隔离树已经在 2026 SwiftUI 前沿，不存在"迁移"命题。** codex-web 列的"高优先级 2026 候选"（Liquid Glass wrapper / 固定 Grid family card / resizable shell），UIUE 树**大部分已落地**，且采用方式恰好命中 pre-mortem 的正确解（glass 分层、GeometryReader 而非 sizeClass、无 TabView、@Observable 而非 TCA）。

**真正 actionable 的不是"采纳新技术"，是"给已落地的 Liquid Glass 用法补 hardening 验证"**——这恰好印证 hermes 的 #1 警告（真瓶颈是稳定性/可读性验证，不是追新 API）和既有 premortem 的 HIGH（截图管线 + 投屏可读性）。

三句话定调：
1. **已对齐**：glassEffect 分层（AD-6）、固定 Grid + 10 族 family card、7 态穷尽 + 双主题、GeometryReader 自适应、Reduce Motion —— 全在 UIUE 树落地，**不需动**。
2. **要做的是 hardening spike**：现有 glass 的 `GlassEffectContainer` 包裹审计 + 真实投屏渲染验收 + 低亮度座舱对比度验收（3 个 HIGH，下方 §五）。
3. **新 API 一律 Watch / Reject**：WWDC26 toolbar overflow / resizable interactive / reorderContainer 全绑 **iOS 27 beta**，UIUE 树锁 iOS 26 → Watch；TCA/swift-navigation + 跨端框架 → Reject。

---

## 一、UIUE 隔离树现状（先 cite，再评估）

> ⚠️ codex-repo 审的是 **main 主树**（落后）。本节 cite 的是 **UIUE 隔离树**（`MAformac-uiue`，分支 `uiue/phase4-default-scope-presentation` @ `2959cab`），这才是 Phase 4/5 真实战场。

| 维度 | UIUE 树现状（file:line 实证） | 对应 2026 趋势 |
|---|---|---|
| **部署目标** | iOS26/macOS26 已锁（`project.pbxproj:352/293 = 26.0`，Swift 6.0）；Core 隔离 `Package.swift:7-9 = .iOS(.v17)/.macOS(.v14)` | ✅ 已在 iOS 26 基线 |
| **Liquid Glass（导航/控制层）** | `.glassEffect()` 已用于 capsule/控制面板：`ContentView.swift:974`、`ContextCapsule.swift:67`、`DemoControlPanel.swift:315` | ✅ 已落地 |
| **Liquid Glass（内容层禁用）** | `ExpandedFamilyCard.swift:5` 注释 **AD-6**：内容层卡背用 `content_glow` **而非 glassEffect** | ✅ 已合 Apple HIG「Don't use glass in content layer」 |
| **布局** | 固定 `Grid + GridRow`（`ContentView.swift:1575`），非 LazyVGrid.adaptive；`VehicleCardsGrid` 组件 | ✅ codex-repo 的"升级切入点1"已做 |
| **family card** | `FamilyCardIDMapper`/`FamilyPrimaryCellMapper`/`ExpandedFamilyCard`/`ExpandedFamilyDisplay`；10 族遍历 `displayOrder`（AD-9/AD-10） | ✅ "升级切入点2"已做 |
| **7 态视觉** | `CardAppearance.of()` 穷尽 switch **无 default**（`DesignTokens.swift:167`，spec R1）；四态色彩 FROZEN（磊哥 2026-06-24 审签） | ✅ 超前 |
| **可读性（双主题）** | `PresentationTheme` 米白(light)/深空(dark)（`DesignTokens.swift:3`），tokens SSOT 镜像 `docs/design/tokens.md`，view 禁手填 hex | ✅ 已为投屏可读性留高对比浅色主题 |
| **自适应布局** | `usesMacSplit(size:)` 走 GeometryReader 尺寸判断（`ContentView.swift:634/67`），**非 horizontalSizeClass** | ✅ 恰好避开 scout2 的 Mirroring sizeClass 锁死坑 |
| **动效 + 降级** | `AmbientEdgeBurst` PhaseAnimator 炸场（`AmbientEdgeBurst.swift:53`，5s）；`PresentationReducedMotionPolicy` 减动效降级（HEAD commit「补齐 Reduce Motion 静态降级」） | ✅ 动效 + a11y 降级双通道 |
| **导航/工具栏** | `NavigationStack` + `ToolbarItem`（`DemoControlPanel.swift:111/126`、`ContentView.swift:758`）基础用法 | ⚠️ 用的是基础 toolbar，非 WWDC26 新 overflow API |
| **TabView** | **无** TabView | ✅ 避开 premortem 的 TabBar iPhone17 启动 SIGABRT 坑 |
| **reorderable / onMove** | **无** | 真未采纳项（但 demo 低价值，见矩阵） |
| **架构** | `@Observable @MainActor` store + `@Bindable`（`DemoVehicleStateStore.swift`）；UIUE=Presentation Contract 三层（AD-13） | ✅ 恰是 solo-dev 推荐路线，非 TCA |
| **已有 premortem** | `docs/research/2026-06-24-ios26-lock-d7-premortem/`（28 次搜证 + Apple verbatim + 截图管线 HIGH + Tinted/glass-on-glass） | 已 cite，本报告在其上扩展 |

**结论**：UIUE 树不是"待迁移的旧 app"，而是"已实装 2026 视觉契约的 demo"。decisions SSOT = `design.md AD-1~AD-13` + `grill-decisions-master`。

---

## 二、三方调研一句话提炼

| Agent | 一句话 |
|---|---|
| **codex-repo**（审 main 树） | main 树 = SwiftUI+Observation 骨架，LazyVGrid.adaptive + fast-path skeleton；列 5 升级切入点。⚠️ 这些在 UIUE 树**已落地**（main 落后于 UIUE）。 |
| **codex-web**（2026 趋势） | SwiftUI 仍是唯一主线；2026 唯一真"新"= Liquid Glass 系统化；重点转向"可变尺寸+可访问性+性能"；RN/Flutter reject。⚠️ 多数"新 API"实为 iOS27。 |
| **hermes-critic**（批判） | 别被 2026 新 UI 叙事牵走；定位"适配性筛选+低风险 spike"非升级路线图；每候选过 Adopt/Spike/Watch/Reject + 6 列硬门 + 5-gate；无证据只能进 Watch。 |

三方**独立同向收敛**（信号强）：SwiftUI-only、跨端 reject、Liquid Glass 是唯一实质新东西且必须验证、demo 稳定性 > 炫技。

---

## 三、我方 pre-mortem / oracle（2 scout，cite-verified）

> 既有 `2026-06-24-ios26-lock-d7-premortem` 已核 glassEffect=iOS26 + 截图管线 HIGH。我方 2 scout **交叉验证 + 扩展**了三处既有 premortem 未覆盖的坑：

- 🆕 **T3 投屏/AirPlay glass 渲染破坏（HIGH）** — 既有 premortem 只覆盖了 ImageRenderer 截图，**没覆盖外部投屏实时渲染**。scout1 实测 Firecore/Apple Community：iOS26 AirPlay 镜像 glass 可能呈纯色块/静态帧。MAformac = iPhone 投 1080p 屏，**这是演示现场最危险炸场路径**。
- 🆕 **E1 Intel Mac macOS Tahoe glass 卡顿** — 若方案经理用 Intel MacBook，glass 动画卡顿 + WindowServer 泄漏，5 分钟越走越慢。
- 🔁 **T1/E3 iOS 26.x 点版本 API churn** — 26.0→26.1 Menu+GlassEffectContainer 行为变（既有 premortem T6 提过 Menu morphing，scout1 强化为「同代码 26.0 通 26.1 炸」）。
- ✅ **T2 GlassEffectContainer 强制** — 多 glass 不包则每个 3 张离屏纹理，车控 5×2 格 = 10+ CABackdropLayer。
- ✅ **T4 低亮度对比度坍塌（HIGH）** — NNGroup 量化；UIUE 树已有米白高对比主题缓解，但需实测验收。
- scout2：resizable/Mirroring = tiger HIGH（sizeClass 锁 compact，UIUE 用 GeometryReader 已避）；toolbar overflow 新 API = iOS27；reorderable = paper-tiger（List.onMove 够用）；TCA = Reject（macOS 性能 + 过度工程化）。

**版本事实（核实，驱动 Watch 判定）**：glassEffect=**iOS 26.0/macOS 26.0（WWDC2025）**；WWDC26 的 toolbar overflow / resizable interactive / reorderContainer = **iOS 27**，仍 beta，UIUE 锁 iOS26 → 这些默认 **Watch**。

---

## 四、适配性矩阵（hermes 6 列硬门 + verdict）

> verdict 图例：**已落地**=UIUE 树已实装（不动）｜ **Harden-Spike**=已落地但需补验证 ｜ **Watch**=iOS27/beta 暂不可用 ｜ **Reject**=demo 阶段不引入。无验证证据者不得进 Adopt（hermes 硬门）。

| 候选技术 | 用户可见收益 | MAformac 场景匹配 | 侵入范围 | 兼容/性能风险 | 验证证据 | 回滚成本 | **verdict** |
|---|---|---|---|---|---|---|---|
| **glassEffect 导航/控制层**（capsule/控制面板/orb） | 高（"惊艳"卖点） | 高（已 AD-6 分层） | 已实装（CV:974/CC:67/DCP:315） | 🔴 T2 离屏纹理/T3 投屏/T1 点版本 | 需补（见§五） | 低（fallback `.regularMaterial`） | **Harden-Spike** |
| **content_glow 内容层**（非 glass 卡背） | 中 | 高（合 HIG） | 已实装（AD-6） | 低 | 已有 | — | **已落地** |
| **固定 Grid + 10 族 family card** | 高（信息密度） | 高（spec R1/R2） | 已实装（CV:1575, AD-9/10） | 低 | 已有单测/契约存在性测试 | — | **已落地** |
| **7 态穷尽 + 双主题可读性** | 高（状态清晰+投屏可读） | 高（D7/磊哥审签） | 已实装（DesignTokens:167） | 低 | 已 FROZEN | — | **已落地** |
| **GeometryReader 自适应（usesMacSplit）** | 中（双端布局） | 高 | 已实装（CV:634） | 🟢 比 sizeClass 安全（避 Mirroring 锁死） | 已有 | — | **已落地（且优于新方案）** |
| **Reduce Motion 降级** | 中（a11y/稳定） | 高（AD-7） | 已实装（HEAD commit） | 低 | 已有 | — | **已落地** |
| WWDC26 toolbar overflow / topBarPinnedTrailing | 低（demo 操作少） | 低 | 中 | 🔴 绑 iOS27 beta + state 变更闪烁 bug | 无（设备无 iOS27） | — | **Watch** |
| WWDC26 resizable interactive API（onInteractiveResizeChange） | 低 | 低 | 中 | 🔴 绑 iOS27；Mirroring sizeClass 锁死 | 无 | — | **Watch**（GeometryReader 已够） |
| reorderable / drag container | 低（排序极低频） | 低 | 中 | 🔴 新 API iOS27 beta；旧 onMove 仅 List | 无 | 中 | **Watch/Reject**（要排序用 List.onMove spike） |
| TCA / swift-navigation | 无（导航≤3 层） | 低 | 大（架构级） | 🔴 macOS 性能问题 + 编译慢 + 学习曲线 | 反证充分 | 大 | **Reject** |
| React Native / Flutter / Expo | 无 | 无（违宪法纯端侧） | 极大 | 🔴 验证/视觉一致性风险 | — | 极大 | **Reject** |

---

## 五、我的结论 + 建议下一步

### 结论
1. **不存在"迁移"任务**。UIUE 树已实装 2026 SwiftUI 前沿的全部 high-value 形态（glass 分层 / 固定 Grid family card / 7 态双主题 / GeometryReader 自适应 / Reduce Motion）。codex-web 的"高优先级候选"= 大部分**已落地**或 **iOS27-Watch**。
2. **真正缺口是 hardening 验证**，不是采纳新 API。这印证 hermes #1（真瓶颈是稳定性/可读性证据）+ 既有 premortem HIGH（截图/投屏）。
3. **新 API 全 Watch**（绑 iOS27 beta，UIUE 锁 iOS26）；**TCA + 跨端框架 Reject**（过度工程化/违宪法）。

### ⭐ 建议唯一聚焦动作 = "Liquid Glass Hardening Spike"（1 屏 + 一组截图 + 回滚点，符合 hermes「可 spike 才适合」）
针对**已落地**的 glass 用法（CV:974 / CC:67 / DCP:315）补 3 个 HIGH 验证（无须新代码采纳，只验证 + 必要时加 fallback）：
- **A1 GlassEffectContainer 审计**（T2）：确认现有 glass 是否包在单一 `GlassEffectContainer` 内；多 glass 裸用 → 包起来。
- **A2 真实投屏渲染验收**（T3，HIGH）：iPhone→1080p 屏/投影实跑演示流程，确认 glass 不呈纯色块；加 `UIScreen.screens.count > 1` → `.regularMaterial` 降级保险。
- **A3 低亮度座舱对比度验收**（T4，HIGH）：设备亮度 30-40% + 投屏逐卡片测文字对比度（接既有 premortem 的 simctl 7 态 gallery 截图 HIGH）；优先用米白主题保读数。
- 附 checklist（演示前）：A4 锁演示设备 iOS 版本 + 48h 内 smoke test（T1/E3）；A5 查 Reduce Transparency OFF（T5）；A6 确认演示 Mac 是 Apple Silicon 非 Intel（E1）；A7 审 orb(Phase 5) glass 是否叠在 glass 卡片上（E2）。

### 不做（显式 reject 清单，防后续 drift）
- ❌ 不引入 TCA / swift-navigation（@Observable + NavigationStack 已足）
- ❌ 不引入 RN/Flutter/Expo（违宪法 §4 纯端侧）
- ❌ 不为 demo 上 WWDC26 iOS27 新 API（设备不在 iOS27）
- ❌ 不把 glassEffect 铺到内容层卡背（守 AD-6）

### 边界声明
- 本报告 = **research_not_ssot**；决策 SSOT 仍是 `design.md AD-1~AD-13` + `grill-decisions-master`。任何动作走 grill/spec，不凭本报告直接改代码。
- A1-A7 是**验证 spike** 不是采纳决策；是否排期由磊哥拍（当前 roadmap 上 UIUE Phase 4/5 + 训练线 DEFERRED）。

---

## 六、关键 source（一手见各 *-firsthand.md / *-raw.md）
- Apple glassEffect 文档：https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:)
- Apple HIG Materials（glass 边界 verbatim）：https://developer.apple.com/design/human-interface-guidelines/materials
- NNGroup Liquid Glass Is Cracked：https://www.nngroup.com/articles/liquid-glass/
- JuniperPhoton 落地坑（点版本 churn + 离屏纹理）：https://juniperphoton.substack.com/p/adopting-liquid-glass-experiences
- Firecore 投屏破坏：https://community.firecore.com/t/airplay-screen-mirroring-broken-on-ios-26/57453
- fatbobman Mirroring sizeClass 锁死：https://fatbobman.com/en/posts/from-size-class-to-available-space/
- TCA honest review：https://medium.com/@chandra.welim/tca-composable-architecture-the-honest-review-76a94aca0570
- solo-dev architecture 2026：https://emrldlabs.com/blog/swiftui-app-architecture-for-solo-developers-in-2026/
- MacRumors iOS27 无重大 glass 改动：https://www.macrumors.com/2026/03/15/ios-27-macos-27-no-major-liquid-glass-changes/
- 本仓既有 premortem：`docs/research/2026-06-24-ios26-lock-d7-premortem/`（含 28 搜证 Apple verbatim + 截图管线 HIGH）

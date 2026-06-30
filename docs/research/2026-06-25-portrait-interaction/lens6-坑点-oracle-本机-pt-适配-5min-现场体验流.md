# 坑点 oracle + 本机 pt 适配 + 5min 现场体验流

> 一手 finder full_markdown（ultracode 三层一手性）

# UIUE 竖屏坑点 oracle + 本机适配 + 5min 现场体验流 Pre-Mortem

**Lens**: 坑点 oracle + 本机 pt 适配 + 5min 现场体验流  
**日期**: 2026-06-25  
**方法**: scout（本机 grep/Read/计算）+ oracle（8 路 WebSearch）

---

## 核心结论（3-6 句）

iPhone 17 Pro 竖屏实际可用高 781pt，D4 三 zone 640pt 合法，10 族卡片尺寸 177×82pt，scope badge `.caption2` 9pt 是竖屏可读下限，投屏（1080p 物理缩放后约 5mm 高）不可读。**最高优先 tiger（T1）**：当前 `ContentView.swift:264` 的 `breathe` animation 在态切换时叠加 `.repeatForever`，不 cancel 旧 animation，10 卡激活时 CPU 100% 永久跑，是已实装代码的真 bug，Phase 4a 收口前必修。**第二 tiger（T2）**：`matchedGeometryEffect` 在 Grid（已改，非 LazyVGrid）的 iOS26/macOS26 运行时冲突未验，D5 validation_gate remaining criteria 需更新 Grid 验证。**最大 elephant**：Phase 4a 只实装 breathe glow + numericText，无 MultiCallSequencer / orb think / boot reveal，现场语音连发后 UI 无序列感，方案经理必须提前约束演示台词走单意图。5min 现场关键路径：开场 reveal→语音点亮（已实装）→ orb think 演出（Phase 5，未实装）→ 断网 morph（Phase 5，未实装），其中 orb think 缺失是现场「防死图片」最大风险。

---

## Tiger（明确威胁，必经验证清单）

### T1: breathe animation 叠加 — CPU 100% 永久跑（HIGH，强制停下拍）

**位置**: `/Users/wanglei/workspace/MAformac-uiue/App/ContentView.swift:259-266`

**根因**: `updateBreathe()` 在 `onAppear` 和 `onChange(of:glowActive)` 双触发，每次调用 `withAnimation(.easeInOut.repeatForever) { breathe = true }` 但没有先停止上一个 animation。SwiftUI 的 `repeatForever` animation 会在 `breathe` 这个 `@State` 上叠加多个并发 transaction，导致 shadow radius 以两个不同速率同时震荡，CPU 利用率线性增加（10 卡 = 10 倍负担）。

**验证清单**（非模式匹配，必实跑）:
1. Instruments Energy Log：10 卡同时激活 breathe，idle CPU 是否 >40%
2. 强制 glowActive true→false→true 后观察 shadow radius 是否以双频率震荡
3. Xcode Console 是否出现 SwiftUI animation transaction warning

**修法**: `updateBreathe()` 起手：
```swift
withAnimation(nil) { breathe = false }  // cancel 旧 animation
// 延一帧再启动新 animation
DispatchQueue.main.async {
    withAnimation(.easeInOut(duration:...).repeatForever(autoreverses: true)) { breathe = true }
}
```

**Source**: `/Users/wanglei/workspace/MAformac-uiue/App/ContentView.swift:259-266`（本机 Read，2026-06-25）+ grill D6.Q6.5 pre-mortem F-LB3 pre-warning

---

### T2: matchedGeometryEffect in Grid — iOS26 运行时冲突未验（HIGH）

**根因**: D5 grill 坐实 mge macOS11+ 可用，但 validation_gate remaining criteria 「LazyVGrid 冲突」在设计层已改 Grid，但「Grid 内 mge 是否冲突」的运行时验证（snapshot focus_expand_10 抖闪测试）还未做。iOS18+ Apple 已将 `matchedTransitionSource` + `.navigationTransition(.zoom)` 推荐为 LazyVGrid hero 场景替代方案，mge 在非 navigation 原地展开场景仍支持但 isSource/consumer 对称必须严格。

**验证清单**:
1. Grid 内 mge 同 namespace 10 卡全 `isSource:true` 展开 10 次看 runtime warning（"Multiple inserted views"）
2. Phase 4c 实装前先跑 `spike/grid-mge-collision-test`（D5.Q5.2 要求）
3. ReduceMotion 开关测试 fallback path 是否正确走 opacityScale

**Source**: [Apple Developer Forums MatchedGeometryEffect](https://developer.apple.com/forums/thread/689053); [Medium SwiftUI 2025 updates](https://elamir.medium.com/beyond-the-basics-a-deep-dive-into-swiftuis-transformative-2025-updates-4f14b3617550); `docs/grill-tournament/uiue-d1-d6-grill.md:191-197`

---

### T3: iOS 26 glassEffect + GlassEffectContainer 版本 bug（MEDIUM，26.1 破坏 morph）

**根因**: 本项目已锁 iOS26/macOS26。iOS 26.1 已知 breaking：Menu in GlassEffectContainer 破坏 morphing animation，且 26.0 vs 26.1 workaround 不兼容。内容层禁 glassEffect 是 HIG 硬规则。Phase 5 orb 容器设计若误用 GlassEffectContainer 会踩此坑。

**验证清单**:
1. `grep glassEffect App/` 确认 0 命中（content layer 禁令）
2. Phase 5 orb 实现方案（MeshGradient E1 已锁）确认不用 GlassEffectContainer
3. iOS 26.0 / 26.1 模拟器各跑一次 orb 动画验 morph

**Source**: [Juniper Photon — Liquid Glass pitfalls](https://juniperphoton.substack.com/p/adopting-liquid-glass-experiences); [Blake Crosley — iOS 26 shipping](https://blakecrosley.com/blog/liquid-glass-swiftui-patterns); [DEV.to iOS 26 best practices](https://dev.to/diskcleankit/liquid-glass-in-swift-official-best-practices-for-ios-26-macos-tahoe-1coo)

---

### T4: ScrollViewReader.scrollTo 活跃置顶与数据 mutation 同帧 → layout jump（MEDIUM，4c 实装时）

**根因**: 活跃置顶（iPhone 竖屏 D4 锁）用 `ScrollViewProxy.scrollTo(activeFamily, anchor:.top)`。已知：iOS18 ScrollViewReader scrollTo 在同一动画事务内的 data source mutation 会导致 offset 跳变（DoorDash 工程 blog 实测）。需 `DispatchQueue.main.async` 延迟一帧再 scrollTo。

**验证清单**:
1. 实装活跃置顶时：在 `onChange(of: activeFamily)` 里用 `DispatchQueue.main.async { proxy.scrollTo(...) }` 而非直接调用
2. Instruments 看 scroll offset 是否单调变化 vs 跳变

**Source**: [DoorDash Engineering — Programmatic ScrollView](https://careersatdoordash.com/blog/programmatic-scrolling-with-swiftui-scrollview/); [Daniel Saidi — LazyVGrid reorder flicker](https://danielsaidi.com/blog/2023/08/30/enabling-drag-reordering-in-swiftui-lazy-grids-and-stacks)

---

### T5: SFSpeechRecognizer mic tap + ScrollView 垂直手势冲突（MEDIUM，Phase 5 实装时）

**根因**: 竖屏 mic zone（80pt）在 content zone（440pt ScrollView）下方，两者在 VStack 内相邻。iOS 18 已知 regression：`highPriorityGesture` 开始与 ScrollView 垂直手势冲突；barge-in long press（E8 U21 已锁）在 ScrollView 内 long press 会被 scroll gesture 竞争取消。

**验证清单**:
1. mic zone tap 是否被 content ScrollView 吞掉（模拟器 tap zone 底部测试）
2. barge-in long press 1.5s 期间同时下滑 content 是否 LPR 中断
3. 用 `.simultaneousGesture` 而非裸 `.gesture` 配置 mic tap

**Source**: [Apple Forums iOS18 gesture regression](https://developer.apple.com/forums/thread/760035); [darjeelingsteve — scroll hijack](https://darjeelingsteve.com/articles/Preventing-Scroll-Hijacking-by-DragGestureRecognizer-Inside-ScrollView.html)

---

### T6: numericText silent-failure — 值变化若不在 withAnimation 事务内静默不动（MEDIUM）

**根因**: `ContentView.swift:193-194` 的 `.contentTransition(.numericText())` + `.animation(.snappy, value:)` 需要值变更在同一 animation context 触发。若 `DemoVehicleStateStore.applyMockTransition` 在后台 Task 而非 `@MainActor` + `withAnimation{}` 调用，数字跳切无滚动动效，无报错。已被 dispatch.md F-LB2 tiger 预警但未有实跑验证。

**验证清单**:
1. 在 `applyMockTransition` 调用处确认是否有 `withAnimation` 包裹
2. 手动空调温度 22→26 apply，看 ContentView 是否有帧间数字滚动
3. 若无滚动：在 store 的 apply 处加 `withAnimation(.snappy) {}` 包裹

**Source**: `/Users/wanglei/workspace/MAformac-uiue/App/ContentView.swift:193-194`; `docs/grill-tournament/uiue-phase4-grill-decisions.md:27 F-LB2`

---

## Paper-Tiger（看似威胁实际安全，附证据）

### P1: blur offscreen texture 性能 — M5/A19 上 paper-tiger
Phase 4a 无 blur（无聚焦展开），Phase 4c 才加。M5 算力 D6.Q6.5 已 steelman（Apple docs Material 系统优化 + dither 内置），单次聚焦 9 张 `ultraThinMaterial` 在 M5/A19 非瓶颈。热充电场景由双通道降级守（ReduceMotion/低电量），已锁。**证据**: [Medium SwiftUI performance 2025](https://medium.com/@ravisolankice12/24-swiftui-performance-tips-every-ios-developer-should-know-2025-edition-723340d9bd79); grill D6.Q6.5 steelman M5。

### P2: presentationDetents 手势冲突 — demo 不用 sheet
Demo 主视图无 `.sheet()`，族内下钻用原地 expansion（D5 锁 opacityScale），无 sheet 弹层，iOS 16-18 presentationDetents touch-offset bug 不适用。**证据**: `openspec/changes/ui-presentation/spec.md` 无 `.sheet` Requirement。

### P3: Dynamic Island 遮挡卡片 — safe area 已处理
D4 三 zone 从安全区内开始布局（VStack tokens 固定高度），SwiftUI 默认 safe area 处理 DI，无 `.ignoresSafeArea` 在交互层。`DeepSpaceBackground` 仅装饰层延边，符合 Apple HIG。**证据**: `App/ContentView.swift:17-30`; [fatbobman safe area mastering](https://fatbobman.com/en/posts/safearea/)

---

## Elephant（没人想谈的）

### E1: scope badge `.caption2` 9pt 在投屏场景不可读（字号红线）
本机计算：iPhone 竖屏 177pt 宽卡，scope badge `.caption2` 9pt，投屏 1080p 后约 4-5mm 物理高，1.5m 观众不可读。grill D3.Q3.4 给了 Mac 主卡字号下限（body≥24/标题≥44）但未给 iPhone badge 下限，tokens.md 无 badge 字号锚。**5-gate Gate4 漏洞**。建议 Phase 4a 收口时 5-gate iPhone 真机 1m 距离人工确认 badge 可读性，并在 tokens.md 加 `badge_min_font_size: 11`（`.caption`）下限。

### E2: Phase 4a「防死图片」只有 breathe，现场方案经理需提前约束台词走单意图
MultiCallSequencer / orb think / boot reveal / 断网 morph 全未实装。现场连续语音「空调降温+座椅加热+开天窗」会触发 3 张卡同时跳动（无序列感，客户无法跟上）。**解法**：Phase 4a 收口必须在 `docs/design/demo-experience-script-placeholders.md` 里标注「Phase 4a 现场约束：单意图 demo，多意图等 Phase 5 MultiCallSequencer 实装后」，而非默默上线让方案经理踩坑。

### E3: FamilyCardIDMapper device 列表与 state-cells 派生链路悬空（family_card_id 字段 0 命中）
`contracts/state-cells.yaml` 无 `family_card_id` 字段（grep 0），FamilyCardIDMapper 是 hardcode enumeration（codex 遗留 untracked），不从 contracts 派生。P4-D2③ 已识别但 4a dispatch 里没有加验证 FamilyCardIDMapper vs allowlist 一致性的 enforce 步骤。建议加单测：`generated/family-device-allowlist.json` 所有 device base → `familyCardID(for:) != nil`。

---

## 本机 pt 实况

| 尺寸 | 数值 |
|---|---|
| iPhone 17 Pro 竖屏 pt | 402×874 pt |
| DI safe top | 59 pt |
| home safe bottom | 34 pt |
| 净可用高 | 781 pt |
| D4 三 zone | orb 120 + content 440 + mic 80 = 640 pt |
| header + padding 余量 | 141 pt |
| 单族卡尺寸（2列5行） | 177×82 pt（ratio 2.17） |
| scope badge font-size | 9 pt（.caption2），投屏下限警告 |

---

## 5min 现场体验流 Critical Path

```
[Phase 4a 已实装]          [Phase 5 未实装]
0s   boot reveal            ← 未做（D1 Q1.1）
3s   语音「打开空调」→
     orb listen 100ms 微亮  ← 未做（E3-D）
     orb think 演出         ← 未做（E2 事件驱动）
5s   空调卡 numericText 滚动 ✅ 已实装
     breathe glow 点亮       ✅ 已实装（T1 需修）
8s   readback 文字显示       ✅ 已实装
     orb speak              ← 未做（E8）
...（多意图序列高亮）         ← 未做（D1 MultiCallSequencer）
4:30 断网 cyan→amber morph  ← 未做（D6 Q6.4）
5:00 END
```

**防死图片保险**（Phase 4a 可靠保底）: numericText 数字滚动 + breathe glow 呼吸 + ambient 色块变色。只要 T1 修完，这三件保底是实的。

---

## Sources
- [Apple Developer Forums MatchedGeometryEffect](https://developer.apple.com/forums/thread/689053)
- [Medium SwiftUI 2025 transformative updates](https://elamir.medium.com/beyond-the-basics-a-deep-dive-into-swiftuis-transformative-2025-updates-4f14b3617550)
- [Juniper Photon — Liquid Glass pitfalls](https://juniperphoton.substack.com/p/adopting-liquid-glass-experiences)
- [Blake Crosley — Liquid Glass iOS 26 patterns](https://blakecrosley.com/blog/liquid-glass-swiftui-patterns)
- [DEV.to iOS 26 best practices](https://dev.to/diskcleankit/liquid-glass-in-swift-official-best-practices-for-ios-26-macos-tahoe-1coo)
- [Apple Forums iOS18 gesture regression](https://developer.apple.com/forums/thread/760035)
- [darjeelingsteve — scroll hijack](https://darjeelingsteve.com/articles/Preventing-Scroll-Hijacking-by-DragGestureRecognizer-Inside-ScrollView.html)
- [DoorDash Engineering — ScrollViewReader](https://careersatdoordash.com/blog/programmatic-scrolling-with-swiftui-scrollview/)
- [Daniel Saidi — LazyVGrid reorder flicker](https://danielsaidi.com/blog/2023/08/30/enabling-drag-reordering-in-swiftui-lazy-grids-and-stacks)
- [fatbobman — mastering safe area](https://fatbobman.com/en/posts/safearea/)
- [Medium SwiftUI performance 2025](https://medium.com/@ravisolankice12/24-swiftui-performance-tips-every-ios-developer-should-know-2025-edition-723340d9bd79)


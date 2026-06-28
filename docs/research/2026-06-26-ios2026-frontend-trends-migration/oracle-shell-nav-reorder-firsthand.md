---
type: pre-mortem-oracle-firsthand
agent: premortem-scout #2 (Claude subagent, WebSearch/WebFetch)
topic: resizable-first/Mirroring · toolbar/tab · reorderable/drag · TCA/swift-navigation 落地坑 + 过度工程化判定
date: 2026-06-26
note: CC 主线程派出的 oracle scout #2 full return 原文（一手，保 source URL+date）。综合见 README.md。
---

# 四技术候选坑点侦察报告（一手）

**侦察对象**：纯端侧 macOS + iOS SwiftUI 演示助手，客户现场 5 分钟、断网可跑、solo 轻治理。

## (a) Resizable-first / Dynamic Size / iPhone Mirroring — **tiger (HIGH) → Watch**
- **坑1 — horizontalSizeClass 在 iPhone Mirroring 下永远 .compact（锁死不随窗口变）**。fatbobman（2026-06）实测：iPhone app 在 Mac 经 iPhone Mirroring 运行，无论窗口拖多宽 `horizontalSizeClass` 恒 `.compact`，NavigationSplitView 不切列。这是 WWDC2026 可调尺寸后第一个已知行为陷阱，官方无显著警告。https://fatbobman.com/en/posts/from-size-class-to-available-space/
- **坑2 — UIRequiresFullScreen 被废弃**，开发者无法锁定单一尺寸（系统将来忽略它）。https://dev.to/arshtechpro/wwdc26-whats-new-in-swiftui-a-developers-breakdown-1333
- **坑3 — 新 API（onInteractiveResizeChange/appearsActive）绑 iOS 27/macOS 27**，演示设备若 Sequoia+iOS18/26 则全无。https://www.theswift.dev/posts/make-swiftui-toolbars-work-in-resizable-iphone-apps/
- 判断：若布局靠 `horizontalSizeClass` 驱动，iPhone Mirroring 下一直 compact，左右分栏永不出现。**倾向 Watch（用 GeometryReader + 明确尺寸断点替代 sizeClass，不依赖 iPhone Mirroring 功能）**。

## (b) 原生 Toolbar priority/overflow + Tab prominent — **tiger (MEDIUM) → Adopt + Spike**
- **坑1 — toolbar 在 state 变化时闪烁空白 toolbar（多年未修）**。`@Binding` 触发 DetailView 更新时 toolbar 被替换为空 toolbar；iOS14→16.4 持续，只有 `StackNavigationViewStyle` workaround。https://developer.apple.com/forums/thread/667107
- **坑2 — `.sidebarAdaptable` TabView 在 iOS compact 下 section header 不出现**（与 iPadOS/macOS 不一致）。https://developer.apple.com/documentation/swiftui/tabviewstyle
- **坑3 — `.sidebarAdaptable` accessibility identifier 出现后几秒才正常（破坏 UI 测试）**。https://www.createwithswift.com/exploring-tab-view-styles-in-swiftui/
- **坑4 — Catalyst popover-in-toolbar 在 macOS 26 beta5 崩溃**（beta 问题，正式版预计修复）。
- **坑5 — WWDC2026 新 toolbar API（visibilityPriority/ToolbarOverflowMenu/topBarPinnedTrailing）绑 iOS 27**。现有 iOS18/26 上仍老行为（overflow 由系统决定）。https://developer.apple.com/wwdc26/guides/swiftui/
- 判断：思路正确（比手写 gesture 靠谱），主风险=state 变更 toolbar 闪烁。MAformac ToolCall 返回→UI 更新会触发大量 state 变更，**必须 spike 验证 state 变更路径下 toolbar 稳定性**。

## (c) SwiftUI Reorderable / Drag Container — **paper-tiger + 一个 elephant → Spike**
- 旧 API（iOS26-，`List.onMove`）：仅 List 内排序，grid/custom 不支持，macOS 多选拖拽有 bug。
- 新 API（iOS/macOS 27，`reorderable()`+`reorderContainer(for:)`）：支持任意容器，代码量大减。https://nilcoalescing.com/blog/NewSwiftUIAPIsForReorderingAndDragAndDropOniOS27/
- 旧 API 已知坑：macOS List 多选拖拽 bug、拖动 row 高度/宽度随机变、text field 点击被 onMove 延迟（需 moveDisabled）。
- 新 API 注意（iOS/macOS 27 beta）：数据重复 bug 风险、多 section 要 `reorderable(collectionID:)`、暂不支持自定义 lazy container。https://livsycode.com/swiftui/swiftui-reorderable-containers-in-ios-27/
- **paper-tiger 证据**：demo「场景卡片排序」可选非核心路径，5 分钟里极低频，降级固定顺序可接受；旧 List.onMove 在 iOS18/macOS15 够用。
- **elephant**：`reorderContainer` 是 iOS/macOS 27 beta，正式客户设备近期 demo 不太可能已升 iOS 27 = 真 blocker。
- 判断：**Spike（先用 List.onMove 够用就不换；要 grid 排序单独 spike，不在 demo 主线赌 beta API）**。

## (d) Point-Free swift-navigation / TCA 枚举路由 — **tiger (HIGH) → Reject（demo 阶段）**
- **证据1 — TCA 编译时间/错误信息质量问题**（实测开发者反馈：报错不可读、额外编译时间累积、child reducers 复杂度、学习曲线极长）。https://medium.com/@chandra.welim/tca-composable-architecture-the-honest-review-76a94aca0570
- **证据2 — macOS 上 swift-navigation 性能问题有据可查**（iOS mostly fine，macOS 差异显著）。MAformac 双端直接命中。https://developer.apple.com/forums/thread/763846
- **证据3 — TCA 架构代价规模小时已出现**（更大 state struct→更贵 diffing/copying；更多 action→中央 bottleneck）。https://www.swiftyplace.com/blog/the-composable-architecture-performance
- **证据4 — 替代路线已验证**：`NavigationStack + @Observable Router enum + 每 tab 独立 NavigationStack` 解决 programmatic navigation+deep linking，不需 swift-navigation 包/@CasePathable 宏。https://emrldlabs.com/blog/swiftui-app-architecture-for-solo-developers-in-2026/
- 判断：MAformac 导航图极浅（主界面→对话→偶发 Sheet ≤3 层），无 deep-link、无测试优先、无多人协作。TCA 解决的「20 屏、多 coordinator 乱调、deep-link 可测试」MAformac 一个都不是。**Reject（用原生 @Observable + NavigationStack path，必要时手写 5 行 Router enum）**。

## 汇总表
| 技术 | 分类 | MAformac 倾向 | 核心根因 |
|---|---|---|---|
| (a) Resizable-first / iPhone Mirroring | tiger HIGH | Watch | horizontalSizeClass 在 Mirroring 锁死 compact，新 API 全绑 iOS27 |
| (b) Toolbar overflow + Tab prominent | tiger MEDIUM | Adopt+Spike | state 变更 toolbar 闪烁 bug 有据、新 API 绑 iOS27；思路对要测试 |
| (c) Reorderable Drag Container | paper-tiger | Spike | demo 排序低频 List.onMove 够用；新 API beta 时间线不明 |
| (d) TCA / swift-navigation | tiger HIGH | Reject | macOS 性能问题+编译成本+solo demo 无收益；替代充分验证 |

## ELEPHANT（最重要）— 目标 OS 版本决定一切
WWDC2026 新 API（resizable `onInteractiveResizeChange`、toolbar `visibilityPriority/ToolbarOverflowMenu`、reorderable `reorderContainer`）**全绑 iOS 27/macOS 27**，撰写时仍 beta。客户演示设备大概率 iOS18/26 + macOS Sequoia/26 非 beta。**凡依赖新 API 的部分全 fallback 到旧行为 = "迁移"可能是伪命题，旧 API 就是实际运行路径**。建议第一步先钉 demo 设备 OS 版本，再决定哪条 API 路线可用。

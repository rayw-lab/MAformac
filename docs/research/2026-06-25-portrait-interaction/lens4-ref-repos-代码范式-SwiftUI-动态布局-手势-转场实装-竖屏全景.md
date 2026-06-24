# ref-repos 代码范式 + SwiftUI 动态布局/手势/转场实装（竖屏全景+三屏+5min 炸场）

> 一手 finder full_markdown（ultracode 三层一手性）

# Lens：ref-repos 代码范式 + SwiftUI 动态布局/手势/转场实装（竖屏全景+三屏+5min 炸场）

> 任务：扒 ~/workspace/raw/05-Projects/MAformac/ref-repos/ + 联网补 SwiftUI 动态交互代码范式，给 file:line 锚的可抄代码 + adopt/adapt/drop（承接 lens5 清单，star>1000 不降级）。
> 日期：2026-06-25。≥8 次联网搜证 + 6 ref-repos 逐文件读。

## Summary

四核心代码范式全部拿到 file:line 可抄实证 + 联网坐实：

1. **动态布局伸缩（三屏弹性）**：竖屏三屏分层（orb 顶/对话流中/车控下）语音态驱动占比变化 = 各 zone `.frame(height:)` 在 `withAnimation` 事务内动画 + 外层 `.geometryGroup()`(iOS17/macOS14+ 均可) 做 barrier 防子视图抖跳。🔴 **禁 GeometryReader 包整屏**（greedy 撑满+干扰布局系统）。承接 D4 已锁：iphone 三 zone tokens 钉死高度（orb120/content440/mic80/gap119）禁 GeometryReader 自适应，弹性只在 idle↔listen 态切。
2. **活跃置顶+自动滚动**：`ScrollViewReader{proxy}` + 每卡 `.id()` + `.onChange(of:activeFamily){ withAnimation{ proxy.scrollTo(id, anchor:.center) } }`；排序动画 `.animation(.spring, value:displays)` 于数组变化。
3. **触发聚焦展开**：`matchedGeometryEffect`(macOS11+ 坐实可用) + `@Namespace` + `withAnimation(.spring)`，clone 内 2 处现成（DaVinci:119/ShipSwift SWOrderView:217）。🔴 `navigationTransition.zoom` macOS **unavailable**（编译错非 no-op）必 `#if !os(macOS)`。
4. **手势组合**：`.onTapGesture`(主) + `.simultaneousGesture(LongPress)`/`.exclusively`/`.sequenced` 四式；语音打断（barge-in）走「调用点直接改 state 不靠 delegate」。

## Findings（详见结构化 findings，每条带 source + 承接锚）

- F1 动态布局：`.frame(height:)`动画+geometryGroup，禁 GeometryReader 包整屏 — Apple Docs geometryGroup iOS17/macOS14+ + 承接 D4
- F2 活跃置顶：ScrollViewReader.scrollTo(anchor:.center)+onChange — hackingwithswift + hanlin-ai:45,95 / exyte-Chat:152
- F3 聚焦展开：matchedGeometryEffect+@Namespace — designcode + DaVinci DSSegmentedControl:119 / ShipSwift SWOrderView:217
- F4 🔴 navigationTransition.zoom macOS UNAVAILABLE 必 `#if !os(macOS)` — Douglas Hill + 承接 D5/hig-rules:82（双端代码分叉点）
- F5 手势组合四式 + scroll 内坑 + 语音打断 — Apple Composing gestures + 承接 hig-rules:78 barge-in
- F6 numericText 必 withAnimation 包裹（silent-fail tiger）— ShipSwift SWKPICard:131-135 + 4a 已对齐 ContentView:193
- F7 breathe glow .repeatForever 仅激活态 — Orb RotatingGlowView:38-61 + 4a 已对齐 ContentView:264
- F8 思考链路流光 TimelineView 遮罩 — hanlin-ai LoadingGradientText:24-67 + 承接 E8
- F9 竖屏 Grid 固定列非 adaptive — MLX-Outil ToolsGridView:53-62 + 承接 C22 + 4a 已对齐
- F10 语音波形 RMS+Timer 定频 — hanlin-ai WaveformBarsView:202-239 + 承接 D4 iPhone 接语音

## Candidates（4 方案，竖屏适配评分见结构化 candidates）

- A 竖屏三屏弹性布局：tokens 钉高度 + .frame 动画 + geometryGroup（⭐⭐⭐⭐⭐ 承接 D4）
- B 活跃置顶：ScrollViewReader + scrollTo(anchor:.center)（⭐⭐⭐⭐⭐ 竖屏专属刚需）
- C 触发聚焦展开：mge 默认 opacityScale + #if !os(macOS)（⭐⭐⭐⭐ 归 4c）
- D 手势组合：onTapGesture 主 + simultaneousGesture 辅 + barge-in 调用点直改（⭐⭐⭐ 克制）

## adopt/adapt/drop 映射（承接 lens5 A1-A10，star>1000 不降级）

| # | 模式 | 来源 file:line | adopt/adapt/drop | 用到 MAformac 竖屏 |
|---|---|---|---|---|
| P1 | matchedGeometryEffect 选择/hero | DSSegmentedControl.swift:119 / SWOrderView.swift:217 | **adopt** 范式 | 4b 档位/模式横滑 + 4c 族卡聚焦展开 |
| P2 | numericText 数字滚动 | SWKPICard.swift:131-135 | **adopt**（4a 已落地） | 空调温度/座椅档位变化炸场 |
| P3 | breathe glow .repeatForever | Orb RotatingGlowView.swift:38-61 | **adapt**（4a 已落地，仅激活态） | 激活族卡呼吸辉光 |
| P4 | 思考链路流光 TimelineView | hanlin-ai LoadingGradientText:24-67 | **adopt** 改深空青 | Phase5 E8 think 掩盖后端 |
| P5 | agent thinking 滚动日志远近淡出 | hanlin-ai ChatViewComponents:494-559 | **adapt** | C3 五段 trace 可视化 |
| P6 | 语音波形 RMS+Timer | hanlin-ai WaveformBarsView:202-239 | **adopt** UI（ASR 后端换系统/sherpa） | 竖屏 mic zone(80pt) |
| P7 | 双端固定列 Grid | MLX-Outil ToolsGridView:53-62 | **adapt**（MAformac 固定列非 adaptive） | 4a 已落地 Mac5/iPad4/iPhone2 |
| P8 | Orb 整球多层 MeshGradient | Orb OrbView:16-63 | **drop 依赖/fork 参考**（stale 2024-11，E1 锁自建 native MeshGradient） | Phase5 orb 主体参考 |
| P9 | Inferno Metal 水波 | twostraws/Inferno(2876★) | **adapt 单文件**（U5 一期，承接 hig-rules:68） | 炸场高潮水波（非常驻） |
| P10 | exyte-Chat 自动滚动状态机 | UIList.swift:152 performScrollTo | **adapt 思路**（UIKit 桥，SwiftUI 用 ScrollViewReader） | 对话流自动滚最新 |

## gaps vs 4a / grill

- 4a 静态 Grid 无活跃置顶/ScrollViewReader（竖屏缺口，F2 提供范式）
- 4a 无触发聚焦展开（归 4b/4c，clone 有现成抄写源）
- 4a 双端统一 Grid 未做 iPhone 三 zone 弹性（D4 锁，需 .frame+geometryGroup）
- 4a numericText/breathe 已正确对齐承接坑（无 gap，确认已落地）
- 🔴 Mac/iPhone 聚焦过渡代码分叉点（navigationTransition.zoom macOS unavailable）4a 未涉及但是双端铁律
- 语音波形/思考流光是 Phase5 料，4a 未涉及，本 lens 给现成 file:line

## Sources（联网，2026-06-25）

- ScrollViewReader: hackingwithswift.com / useyourloaf.com / Apple Docs
- matchedGeometryEffect: designcode.io / Medium App Store hero
- navigationTransition.zoom macOS unavailable: douglashill.co / createwithswift.com / Apple NavigationTransition Docs
- geometryGroup iOS17/macOS14+: Apple Docs / fatbobman.com
- 手势组合: Apple Composing SwiftUI gestures / dhiwise.com / kodeco.com
- 本机 ref-repos：MLX-Outil/ShipSwift/DaVinci/hanlin-ai/Orb/exyte-Chat（~/workspace/raw/05-Projects/MAformac/ref-repos/，只读）
- 承接 grill：docs/grill-tournament/uiue-d1-d6-grill.md / uiue-phase4-grill-decisions.md / docs/design/hig-liquid-glass-rules.md / lens5.md

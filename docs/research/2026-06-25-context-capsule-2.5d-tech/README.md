# context capsule diorama — C 路线（2.5D hybrid）技术调研

> 2026-06-25。磊哥定 capsule = 「活体迷你窗」diorama（车辆+环境 context 映射），走 C 路线（2.5D hybrid：photoreal still 切层 + SwiftUI parallax/粒子/crossfade）。本文 = C 依赖栈 + adopt 蓝本（github-first）+ pre-mortem + 图够不够。
> 来源：WebSearch 多路 + 项目内 grill 决策核（U5/U30/U31/E1）。

## C 路线依赖栈（组件 × 蓝本 × adopt 状态）

| 组件 | 依赖/蓝本 | adopt 状态 | 注 |
|---|---|---|---|
| **外层 capsule 玻璃壳** | iOS26 native `.glassEffect(.regular, in: .capsule)` + `GlassEffectContainer` | native + 参考 `conorluddy/LiquidGlassReference` | 便宜、官方 |
| **分层场景** | ① 分层 stills（sky/car/road 透明 PNG）② 平图 + CoreML 单目深度（`3dify-ios` / Apple FCRN）| 资产 or CoreML | 见「图够不够」 |
| **视差 motion** | ① 分层 `.offset`（便宜，省 GPU）② Metal 位移 shader（`3dify` 视差遮挡）| 自写 or adopt | ⭐ 分层 offset 更省 GPU |
| **粒子（雨/雪/尾气/星）** | **Vortex**（twostraws，`.rain`/`.snow` preset，几行）| adopt ⭐ | Canvas-based，比 layerEffect 省 |
| **玻璃折射/caustics** | Metal `layerEffect`（Victor Baro 教程 / **Inferno** twostraws）| adopt Inferno | 🔴 见 pre-mortem GPU |
| **头灯光锥/glow** | 简单 blur+blend，或轻 Metal | 自写 | 轻量 |
| **crossfade 转场** | SwiftUI `.transition` + `glassEffectID` morph | native | context 切换丝滑 |
| **动画驱动** | `TimelineView(.animation)` 满帧（磊哥定不省电）| native | shader 无时间概念，靠这驱动 |
| **shader 预编译** | iOS18 `shader.compile(as:)` 避首用卡顿 | native | |

## Adopt 清单（github-first，全活跃，adopt > build）

| repo | 用途 | 注 |
|---|---|---|
| **twostraws/Vortex** | SwiftUI 高性能粒子（雨/雪/尾气/星）| ⭐ 直接 adopt，几行出雨 |
| **twostraws/Inferno** | SwiftUI Metal shaders 库（玻璃折射/ripple）| ⭐ **项目 U5 已采**（RippleEffect）|
| **conorluddy/LiquidGlassReference** | iOS26 Liquid Glass 终极参考（「指给 Claude 看的文档」）| ⭐ 实装前读 |
| PhilippMatthes/3dify-ios | 单目深度 + 视差遮挡映射（平图→2.5D）| 🟡 参考技术（作者要求联系才复用代码，不直接抄）|
| Apple FCRN CoreML | 单目深度估计模型（免费）| 平图深度路线用 |
| Victor Baro 折射 glass shader 教程（2025）| Snell 定律 pixel-shift 折射 + rim light | 学 layerEffect 折射 |
| (route A fallback) Kling 3.0 / Runway Gen-4 | 图→视频 seamless loop（首尾同帧法）| Kling 车辆运动强 |

## 🔴 Pre-mortem（tiger / paper-tiger / elephant）

- 🐯 **GPU 抢占（项目 U30 硬约束，最关键）**：`grill-master:161` U30 已定「**layerEffect 最贵，与 mlx 抢 GPU 掉 50%**，shader 仅氛围层」+ U31「shader 有效性 = spike 实证不拍」。capsule 永远在动（ambient）+ 模型推理时（orb think）也在动 → **重 layerEffect 玻璃折射 + 模型 mlx 推理同时跑 = GPU 争用**。
  - 缓解：① **轻量化**（外壳用 native `.glassEffect`[便宜] + 粒子用 Vortex/Canvas[比 layerEffect 省] + 视差用 image `.offset`[非 Metal 位移]，**避免推理时跑重 layerEffect 折射**）② 推理瞬间可降 shader 质量 ③ **route A（视频 loop）：视频解码走专用解码器≠GPU compute，反而避开 mlx 争用**（GPU 友好点）。
  - 🔴 **必 spike 实证**（U31）：真机测 capsule diorama + 模型推理同跑掉不掉帧。
- 🐯 **3dify license**：作者要求联系才能复用 → 学技术/用 Apple FCRN，不直接抄代码。
- 📄 **simulator 不渲染 glass specular/折射**（paper-tiger，研究坐实）：必真机验 —— 但我们本来就真机 demo，不是问题。
- 🐘 **平图→深度的边缘质量**（没人提）：单目深度估计平图可能糊边（车与背景分离不干净）→ **分层资产（sky/car/road 分开 PNG）比深度图干净**，但要多产资产。spike 比两条。

## 图够不够（磊哥问）

- **作为视觉目标/参考**：✅ 这 5 张够（定义了 look + 对比基准）。
- **route A（视频 loop）**：✅ **5 张平图够** —— Kling/Runway 用「首尾同帧法」把每张平图 AI 动成 2-3s seamless loop（车辆运动 Kling 强）。若要更多 context 组合（雨天白天/夜晚行驶/泊车）→ 再生几张，但 5 张覆盖核心。
- **route C（2.5D）**：平图可走 **CoreML 深度**（不用新图）OR 磊哥提供**分层版**（sky/car/road 分开透明 PNG，视差更干净）。**可先用深度图跑 spike，不够干净再要分层版。**
- **结论**：🔴 **现在 5 张够起步**；route 选定后（A 或 C）spike 时再定要不要补图（A 可能补 context 组合 / C clean-parallax 可能要分层版）。

## Route 重新权衡（含 GPU 约束）

| route | 像图 | GPU（vs mlx）| 切换卡顿 | 图需求 | 综合 |
|---|---|---|---|---|---|
| **A 视频 loop** | ✅ 最像 | ✅ **视频解码≠GPU compute，避 mlx 争用** | 预加载则零 | 5 平图 AI 动 | GPU 友好 + 最像 |
| **C 2.5D（重 shader）** | ✅ 接近 | 🔴 layerEffect 与 mlx 抢（U30 -50%）| 零 | 平图+深度/分层 | shader 要 spike |
| **C-lite（native glass + Canvas 粒子 + image offset，无重折射 shader）** | 🟡 较像 | ✅ 省 GPU | 零 | 平图/分层 | GPU 友好 + 实时 |

🔴 **U30 改变了我之前的推荐**：之前我荐 C（2.5D + 玻璃折射 shader），但项目 U30 已定 layerEffect 与 mlx 抢 GPU -50% → **重折射 shader 是 GPU tiger**。新权衡：
- **A（视频 loop）** 反而 GPU 最友好（解码≠compute）+ 最像图 → demo 可能优选。
- **C-lite**（native glass + Vortex 粒子 + image offset 视差，**砍重折射 shader**）= 实时 + 省 GPU + 较像。
- **必 spike 真机实证**（U31）：A vs C-lite，测 capsule + 模型推理同跑的帧率与观感，一手定。

## Sources

- [twostraws/Vortex — SwiftUI particle system](https://github.com/twostraws/Vortex)
- [twostraws/Inferno — Metal shaders for SwiftUI](https://github.com/twostraws/Inferno)
- [conorluddy/LiquidGlassReference — iOS 26 Liquid Glass reference](https://github.com/conorluddy/LiquidGlassReference)
- [PhilippMatthes/3dify-ios — monocular depth + parallax](https://github.com/PhilippMatthes/3dify-ios)
- [Victor Baro — Refractive Glass Shader in Metal (2025)](https://medium.com/@victorbaro/implementing-a-refractive-glass-shader-in-metal-3f97974fbc24)
- [Hacking with Swift — Metal shaders via layer effects](https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-metal-shaders-to-swiftui-views-using-layer-effects)
- [Apple — glassEffect(_:in:) / GlassEffectContainer](https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:))
- [STRV — Stereo/3D Photo from Depth (Metal)](https://www.strv.com/blog/stereo-photo-from-depth-photo-engineering-ios)
- [Kling AI / Runway image-to-video seamless loop (frame-matching)](https://fluxnote.io/guides/how-to-make-seamless-loop-video-ai)

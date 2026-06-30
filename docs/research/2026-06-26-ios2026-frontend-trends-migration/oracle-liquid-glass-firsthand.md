---
type: pre-mortem-oracle-firsthand
agent: premortem-scout #1 (Claude subagent, WebSearch/WebFetch)
topic: Liquid Glass (glassEffect / GlassEffectContainer) 落地坑点 + 版本核实
date: 2026-06-26
note: 这是 CC 主线程派出的 oracle scout #1 full return 原文（一手，保 source URL+date）。综合见 README.md。
---

# Liquid Glass Pre-Mortem 侦察报告（一手）

**侦察范围**：MAformac — 纯端侧 SwiftUI demo，macOS + iOS 一套，客户现场 1080p/Retina 投屏，低亮度座舱场景，5 分钟不崩不炸，断网离线。

## 版本事实先核（声称层 vs 事实层）
**结论：版本事实可信，但当前仍处于快速迭代窗口。**
- `glassEffect(_:in:)` 和 `GlassEffectContainer` 在 **iOS 26.0 / macOS Tahoe 26.0** 引入，于 **WWDC 2025（2025-06-09）** 发布。不是 iOS 27，不是 WWDC 2026。
- 截至 2026-06，iOS 26.x / macOS 26.x 已正式发布（非 beta）。但 **每个小版本（26.0→26.1→26.2）API 行为都有破坏性变更**（见 T1），并非"stable 不动"。
- iOS 27 / macOS 27 不做重大 Liquid Glass 改动（MacRumors 2026-03-15 引 Gurman）。
- 来源：https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:) ｜ https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/ ｜ https://www.macrumors.com/2026/03/15/ios-27-macos-27-no-major-liquid-glass-changes/

## TIGER（明确威胁）
**T1 — 每个小版本 API 行为不一致，workaround 随版本失效**。JuniperPhoton（2025-10-03）实测：iOS 26.0 `Menu` 放 `GlassEffectContainer` 有形变 bug（圆→矩形 snap），workaround=外层加 `interactive`；iOS 26.1 该 workaround 失效，须改自定义 `ButtonStyle`。同段代码 26.0 跑通、26.1 视觉炸。对 5 分钟演示：现场设备 iOS 版本无法提前控制 = 赌注。来源：https://juniperphoton.substack.com/p/adopting-liquid-glass-experiences

**T2 — 多个独立 glassEffect 不包 GlassEffectContainer = 每个独立分配 3 张离屏纹理**。每个裸 `.glassEffect()` 底层创建独立 `CABackdropLayer`，需 3 张 offscreen texture。车控面板「5×2 控件 + top bar + orb」若每控件独立加 glass = 10+ CABackdropLayer 同时存在；iPhone 移动 GPU 离屏渲染压力放大；状态切换动画触发重绘则缓存失效。验证：所有 glass 必须放单一 `GlassEffectContainer`（每屏一个，不跨 container）+ Instruments Metal 帧调试看 offscreen pass 数。来源：JuniperPhoton（同上）｜ https://forums.macrumors.com/threads/liquid-glass-performance-gpu-battery.2463522/

**T3 — 投屏 / AirPlay 渲染破坏（HIGH，演示现场最危险炸场路径）**。Firecore 社区（2025 下半年，多用户）：iOS 26 后 AirPlay Screen Mirroring 特定场景退化为静态截图（只更新一帧），有仅音频问题；26.2 部分修复未完全消除。Apple Community：iOS 26.1 上 glass 镜像到外屏时 layer 消失/呈纯色块。MAformac 场景 = iPhone 投 1080p 屏/投影仪，glass 在投屏端可能呈纯白/纯黑块、无折射、动画卡死。**在开发机完美、客户屏上穿帮**。验证（HIGH，磊哥需拍）：真实投屏环境全程跑一遍 + 准备 fallback（检测 `UIScreen.screens.count > 1` 降级 `.regularMaterial`）。来源：https://community.firecore.com/t/airplay-screen-mirroring-broken-on-ios-26/57453 ｜ https://discussions.apple.com/thread/256136925

**T4 — 低亮度/深色背景下对比度坍塌（HIGH，NNGroup 量化批评）**。NNGroup《Liquid Glass Is Cracked》：iOS 26 Contacts "白字叠浅蓝底"几乎不可读；text-heavy/enterprise/accessibility 应用直接暴露问题。Six Colors（2025-11）：用户需手动开 Reduce Transparency + Increase Contrast 双开才勉强可读。MAformac 座舱 = 深色车舱 + 高对比需求，车控卡片文字（温度数字/开关状态）叠 glass 投屏后可能低于 WCAG 4.5:1。验证（HIGH）：模拟座舱亮度（30-40% + 投屏）逐卡片测对比度 + glass 层上方文字加 vibrancy/shadow。来源：https://www.nngroup.com/articles/liquid-glass/ ｜ https://sixcolors.com/post/2025/11/soaping-up-liquid-glass-less-transparency-more-contrast/

**T5 — Reduce Transparency/Increase Contrast 开启时 glass 降级不可预测**。开启后 iOS 加黑色半透明遮罩（视觉后处理）。若演示设备曾开过辅助功能，glass 变"黑色压暗磨砂块"。验证：`accessibilityReduceTransparency == true` 下跑完整流程 + 演示前 checklist 查 Settings→Accessibility→Reduce Transparency 是否 OFF。来源：https://www.macrumors.com/how-to/ios-reduce-transparency-liquid-glass-effect/

## PAPER-TIGER（看似威胁实际可控）
- **P1 #available fallback 复杂度**：MAformac 是 demo 非 App Store 交付，不需支持 iOS 25-；演示设备可提前更新到 26.x。`#available(iOS 26.0, *)` 包一层 ViewModifier 即可。
- **P2 Apple Silicon GPU 开销**：iPhone 15+/M 系列背景静态时缓存 backdrop 不逐帧重算；MacRumors 实测 iPhone 17 Pro Max Tinted vs Clear 电池差 <1%。**前提=必须用 GlassEffectContainer**（否则从 paper-tiger 变 tiger，见 T2）。Intel Mac 除外（见 E1）。来源：https://www.macrumors.com/2025/10/24/ios-26-1-liquid-glass-battery-test/

## ELEPHANT（没人谈该谈）
- **E1 — macOS Tahoe 在 Intel Mac 上是已知性能坑**。所有"性能没问题"评测都是 Apple Silicon。2019 Intel MacBook Pro 跑 Tahoe 动画明显卡顿 + WindowServer 内存泄漏。MAformac macOS 演示若用 Intel MacBook，5 分钟可能越走越慢。磊哥需排查：演示机型号（M1+ 还是 Intel）；Intel → macOS 端不用 glassEffect 走 `.regularMaterial`。来源：https://forums.macrumors.com/threads/macos-tahoe-performance-on-intel.2474392/
- **E2 — glass cannot sample other glass：demo"炫目叠加"冲动是陷阱**。多层 glass 叠加 = 底层折射被上层截断 = 白色雾化块/闪烁。高风险：浮动 Orb（glass 球）叠 glass 卡片网格 / Sheet glass 底弹在 glass toolbar 上。验证：审计所有 glass 元素 Z 轴层叠，glass 之间必须有实体内容层隔开。来源：https://github.com/conorluddy/LiquidGlassReference ｜ https://blakecrosley.com/blog/liquid-glass-swiftui-patterns
- **E3 — iOS 26.x 仍在"快速修复窗口"，API 每点版本改变**。今天（2026-06-26）26.0/26.1/26.2 每版都有 Liquid Glass 行为变更。方案经理演示前一天装系统更新可能改变 glass 行为。应对：演示设备锁版本（关自动更新）或演示前 48h 内完整跑 smoke test。

## 综合建议（design Risks 段输入）
| 风险 | 分类 | 建议 |
|---|---|---|
| 投屏/AirPlay glass 渲染破坏 | 🔴 Tiger/HIGH | 必须真实投屏验收，准备降级 fallback |
| 多 glass 容器 offscreen 纹理爆炸 | 🔴 Tiger | 所有 glass 放单一 GlassEffectContainer |
| iOS 26.x 点版本 API 行为变更 | 🔴 Tiger | 锁演示设备系统版本，演示前再 smoke test |
| 低亮度座舱对比度坍塌 | 🔴 Tiger/HIGH | 模拟座舱亮度做对比度验收，文字加 vibrancy |
| Reduce Transparency 意外开启 | 🔴 Tiger | 演示前 checklist 查辅助功能 |
| Apple Silicon GPU 开销 | 🟢 Paper-Tiger | 正确实现下可控 |
| #available fallback 复杂度 | 🟢 Paper-Tiger | Demo 不需向后兼容 |
| Intel Mac 演示机卡顿 | 🐘 Elephant | 确认演示机型号 |
| glass 叠 glass 视觉 artifact | 🐘 Elephant | 审计所有 Z 轴层叠设计 |

---
type: visual-ssot-hig-rules
status: v2（2026-06-24 锁 iOS26/macOS26 重写；锁 U2/U5/U7/U30 + pre-mortem 坐实 + Apple verbatim）
date: 2026-06-24
owner: UIUE 链路A（worktree uiue/visual-ssot-state-consume）
source:
  - docs/grill-tournament/grill-decisions-master.md §3（U2/U5/U7/U30）
  - docs/research/2026-06-24-ios26-lock-d7-premortem/（oracle1-4 cite-verified：Apple verbatim/API 版本/Xcode bug/截图管线）
  - 外部: Apple HIG Materials verbatim / WWDC25 #323 / NN/g "Liquid Glass Is Cracked"
note: 🔴 **agent 写任何 SwiftUI view 前必读本文 + tokens.md**。锁 iOS26/macOS26 后不再有 iOS17 版本 fallback；违反 Liquid Glass functional-layer-only / 误加版本守卫 / shader 滥用 = 整屏糊 / GPU 抢占 / 与锁版本矛盾。
---

# Liquid Glass + 动效 HIG 约束剧本（agent 写 view 前必读，v2 锁 iOS26）

> 🔴 **版本底线（2026-06-24 锁 A，pre-mortem 坐实）**：demo **App target deployment = iOS26/macOS26**（pbxproj；磊哥实机 iPhone iOS26 + 这台 Mac macOS26 Tahoe）。**Package.swift Core/CLI 留 `.iOS(.v17)/.macOS(.v14)` 隔离**（A2 portable，别动）。
> → MeshGradient(iOS18)/glassEffect(iOS26)/matchedGeometry(iOS14)/Gauge(iOS16) 引入版本均 ≤ 26 → **一律不加 `#available` 版本守卫**（加了反而矛盾，被 `check-platform-vs-version-guard.sh` 拦）。

## 0. 三条最高铁律

1. 🔴 **Liquid Glass = functional layer only（U2 + Apple 官方）**：`.glassEffect()` **只**用 `control_glass`（mic 按钮/顶栏）。**内容卡片用 `content_glow` 自研辉光，绝不用 system glass**。
2. 🔴 **锁 iOS26 → 无版本守卫，只留平台守卫 + a11y 双通道**：iOS18/iOS26 API 直接用（deployment 26 已满足），**SHALL NOT 加 `#available(iOS 17/18, *)`**；唯 `navigationTransition.zoom`（macOS unavailable）用 **`#if !os(macOS)` 平台守卫**（非版本）；ReduceMotion/低电量走 a11y 双通道（非版本 fallback）。
3. 🔴 **关键状态双通道（低电量/ReduceMotion）**：低电量静默禁所有 `withAnimation`，惊艳归零。**态必用「颜色+数值+图标」承载，动画只锦上添花**。

## 1. Liquid Glass 用法（U2 + Apple 官方 verbatim）

> 🔴 **Apple 官方边界 verbatim**（oracle1 curl `developer.apple.com/.../materials.json` HTTP200 坐实。**严禁用社区措辞 "exclusively / best reserved for" 冒充 Apple 原话**——`grep -rE 'exclusively|best reserved for' docs/design/` 命中需人工审是否伪官方引文）：
> - *"Liquid Glass forms a distinct functional layer for controls and navigation elements — like tab bars and sidebars — that floats above the content layer."*
> - *"Don't use Liquid Glass in the content layer. ... use standard materials for elements in the content layer, such as app backgrounds."*
> - *"Use Liquid Glass effects sparingly... Limit these effects to the most important functional elements."*
> - 🎁 **例外（利好，车控适用）**：*"...controls in the content layer with a transient interactive element like sliders and toggles; ... the element takes on a Liquid Glass appearance to emphasize its interactivity when a person activates it."* → 温度滑块/风量 toggle **激活态用 glass = Apple 点名正确用法**。

### ✅ 该用（functional layer）
- mic 录音按钮、顶部状态栏 → `control_glass`：**直接 `.glassEffect()`**（锁 iOS26，无 fallback 分支）。
- 内容层 transient 交互控件（slider/toggle）激活态 → 可 `.glassEffect()`（Apple 例外）。

### ❌ 禁用（content layer）
- ❌ 内容卡片背景用 glass（Apple "Don't use Liquid Glass in the content layer"）→ 用 `content_glow` 自研 box-shadow glow（tokens §5）。
- ❌ 全局主题开关式 glass（U2）。
- ❌ 多层 glass 直接叠（glass 无法 sample 另一层 glass）→ 多 glass 必包 **`GlassEffectContainer`**（WWDC25 #323，oracle4 坐实）。
- 🔴 NN/g "Liquid Glass Is Cracked"：内容层 glass 上文字对比塌 → 核心读数（温度/档位）绝不放 glass 上。

### 🟡 可读性真坑（Apple 自承认）
- Clear glass 默认对比度差 → Apple iOS26.1 加 Settings→Liquid Glass→Tinted（oracle1：MacRumors）。**demo 设备设 Tinted + 核心读数放 content 层（=U2 content_glow），投屏强光逐张核**。
- 旧机发热/GPU = **paper-tiger（对锁最新设备 demo 不适用）**：坑全来自旧机长时使用；我们 iPhone iOS26 + Mac macOS26 + 5min 短演示，系统硬件加速材质，不适用。

### glass 写法（锁 iOS26，无 fallback）
```swift
// control_glass：直接用，无版本守卫（deployment 26 ≥ glassEffect 引入 26）
micButton.glassEffect()
// 多个 glass 元素必包 container（防 glass-on-glass 采样错乱）
GlassEffectContainer { micButton.glassEffect(); statusBadge.glassEffect() }
```

## 2. 语音 orb / MeshGradient（U30，氛围层）

- 🔴 **orb 核心 = native MeshGradient**（iOS18 ≤ 26，**直接用无 `#available`**）（U30）。第三方 siri-orb repo 全 stale，别引；自建 MeshGradient + TimelineView 四态（idle/think/speak/listen）。
- 🔴 **shader（`.layerEffect`/Metal）仅氛围层**（U30）：layerEffect 最贵，与 mlx 抢 GPU 掉吞吐。orb 主体 MeshGradient，shader 只点缀。

```swift
// MeshGradient 直接用（deployment 26 ≥ iOS18），无 fallback 分支
MeshGradient(width: 3, height: 3, points: [...], colors: [glowCyan, glowViolet, ...])
```

## 3. Metal 水波（U5 一期做）

- 🔴 **U5 一期做（磊哥改，非二期）**：adopt `twostraws/Inferno` 水波 `.metal` shader（strength3/freq10 起），包成 `RippleEffect` modifier。
- ⚠️ Metal shader 真机才正确（模拟器 mock 兜底）；与 mlx 抢 GPU → 水波只在炸场高潮触发，不常驻。

## 4. 动效坑（pre-mortem 一手，必避）

| 坑 | 规避 | source |
|---|---|---|
| `numericText` 不 `withAnimation` 包裹则不动 | 值变更必 `withAnimation(.spring)` | README:47 |
| glow/breathe 用裸 `Timer` → 泄漏 CPU | `.repeatForever` 隐式动画 / `TimelineView` | README:49 |
| 低电量/ReduceMotion 静默禁 `withAnimation` → 惊艳归零 | 关键态颜色/数值/图标双通道，动画锦上添花 | README:43 |
| `barge-in` didCancel 静默不触发 | 状态在调用点直接改，不只靠 delegate；`stopSpeaking(at:.immediate)` | README:48 |
| mlx 推理冻主线程 | dedicated actor / `Task.detached` + token loop `Task.yield()`+`checkCancellation` | README:45 |
| ContentView trace ForEach 用 `.offset` 当 id | 稳定 id + 拆子 view + 限条数 | README:57 |
| **iOS26 glass-on-glass 采样错乱** | 多 glass 必包 `GlassEffectContainer` | oracle4 / WWDC25 #323 |
| **navigationTransition.zoom macOS 编译报错** | `#if !os(macOS)` 平台守卫（macOS 缺该类型） | oracle2 |

## 5. 离线红线（U7，天然满足别返工）

- scheme1 用 emoji（❄️💺🪟）+ `-apple-system` 字体栈，**零 CDN**。
- SwiftUI 落地：SF Symbols / 字体 / 图片必进 **Copy Bundle Resources** + plist key → 100% 离线（真风险在 GPU 成本不在能否离线）。

## 6. 5 Gate 视觉验收（交付前 + 真实查看环境）

> 引全局 `aesthetic-first-principles`（5 Gate）+ MAformac 飞书白皮书血泪（看自己导出图 ≠ 用户实查）：

- [ ] 层级：主次一眼分（满足态 cyan 辉光 vs 未激活 dim 灰，对比明显）
- [ ] 对齐：卡片网格栅格对齐
- [ ] 遮挡：notch/顶栏不压关键信息
- [ ] 字体：暗底上 `ink #eaf0ff` 对比 ≥4.5:1；投屏 8bit 不 banding（U23 ⌃P 提亮）
- [ ] 重量：辉光不抢内容；cyan halation 控 30-60%（U11）
- 🔴 **5-gate 看 simctl 满屏单态截图（14 张，非 gallery 缩略）+ 还原真实查看环境**（Mac 屏/投影机/iPhone），逐张 Read 检测，不看自己导出高清图当通过。ImageRenderer 截不出 Liquid Glass（Core Animation 合成不进 raster，oracle4 坐实）→ 必走 simctl 启动整 app 截图。

---

## 与 tokens.md 的关系
- `tokens.md` = 色/字/间/动效**值**（取什么）；本文 = HIG **约束规则**（怎么用、什么禁用）。
- 两者都建、不重复：tokens 给值，rules 给规则。agent 生成 view 前两个都读（INDEX 路由）。

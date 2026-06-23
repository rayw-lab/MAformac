---
type: visual-ssot-hig-rules
status: DRAFT v1（CC0 起草；锁 U2/U5/U7/U19/U30 拍板 + UIUE ultracode pre-mortem 一手坑）
date: 2026-06-23
owner: UIUE 链路A（worktree uiue/visual-ssot-state-consume）
source:
  - docs/grill-tournament/grill-decisions-master.md §3（U2/U5/U7/U19/U30）
  - raw/.../2026-06-22-uiue-ultracode/README.md:44-65（pre-mortem TIGER/ELEPHANT 一手坑）
  - 外部: medium @madebyluddy iOS26 Liquid Glass / NN/g "Liquid Glass Is Cracked" / Apple WWDC25 #323
note: 🔴 **agent 写任何 SwiftUI view 前必读本文**。这是 HIG 约束剧本——违反 Liquid Glass functional-layer-only / 漏 #available 守卫 / shader 滥用 = 整屏糊 / 旧机崩 / GPU 抢占掉 50%。
---

# Liquid Glass + 动效 HIG 约束剧本（agent 写 view 前必读）

> 版本底线坐实：部署 **iOS17 / macOS14**（`Package.swift`），本机 SDK **iOS26.5**（README:4）。即「**用 iOS26 特性设计、向 iOS17 兼容部署**」——所有 iOS18+ API 必 `#available` 守卫 + iOS17 fallback（U19）。

## 0. 三条最高铁律（违反整体观感塌 / 旧机崩）

1. 🔴 **Liquid Glass = functional layer only（U2）**：`.glassEffect()` **只**用在 `control_glass`（mic 按钮 / 顶栏）。**内容卡片用 `content_glow` 自研辉光，绝不用 system glass**。
2. 🔴 **iOS18+ API 一律 `#available` + iOS17 fallback（U19）**：MeshGradient(iOS18) / glassEffect(iOS26) 不守卫 → 部署 iOS17 直接崩。
3. 🔴 **关键状态双通道（低电量/ReduceMotion）**：低电量模式静默禁所有 `withAnimation`，惊艳归零。**态必用「颜色+数值+图标」承载，动画只锦上添花**。

## 1. Liquid Glass 用法（U2 + 外部 HIG）

### ✅ 该用（functional layer）
- mic 录音按钮、顶部状态栏 → `control_glass`
- iOS26: `.glassEffect()`；iOS17 fallback: `.ultraThinMaterial`

### ❌ 禁用（content layer，整屏糊 + HIG 违规）
- ❌ 内容卡片背景用 glass（medium @madebyluddy 明列禁忌：content layer / 全屏背景 / 滚动内容 / 堆叠多层 glass）
- ❌ 全局主题开关式 glass（U2：非全局主题开关）
- ❌ 多层 glass 叠加（reddit r/swift：layering multiple glass modifiers → frame drops in previews）
- 🔴 NN/g "Liquid Glass Is Cracked, Usability Suffers"：icons blend into background → 内容层 glass 可读性塌

### 🔴 旧机性能（README:44 TIGER）
iOS26 Liquid Glass 旧机卡顿发热（打开通知中心 ≈ 3D 游戏耗 GPU）。**内容卡用 `content_glow` 自研 box-shadow glow（tokens §5），不用 system glass** + demo 机 iPhone15Pro 满电兜底。

### #available 模板
```swift
// control_glass：iOS26 glass → iOS17 material fallback
if #available(iOS 26, *) {
    micButton.glassEffect()
} else {
    micButton.background(.ultraThinMaterial, in: .capsule)
}
```

## 2. 语音 orb / MeshGradient（U30，氛围层）

- 🔴 **orb 核心 = native MeshGradient（iOS18，必 `#available`）**（U30 grill §3:148）。所有第三方 siri-orb repo 全 stale（373★/2024-06），别引；自建 MeshGradient + TimelineView 四态（idle/think/speak/listen，README:91）。
- 🔴 **shader（`.layerEffect`/Metal）仅氛围层**（U30）：layerEffect 最贵，与 mlx 抢 GPU 掉 50% 吞吐。orb 主体用 MeshGradient，shader 只点缀。
- iOS17 fallback: MeshGradient 不可用 → 退 RadialGradient + 多层 opacity 动画（scheme1 的 radial-gradient 范式）。

```swift
if #available(iOS 18, *) {
    MeshGradient(width: 3, height: 3, points: [...], colors: [.cyan, .violet, ...])
} else {
    RadialGradient(colors: [glowCyan, glowViolet, bgBase], center: .center, startRadius: 0, endRadius: 180)
}
```

## 3. Metal 水波（U5 一期做）

- 🔴 **U5 一期做（磊哥改，非二期，grill §3:119）**：adopt `twostraws/Inferno` 水波 `.metal` shader（strength3/freq10 起），包成 `RippleEffect` modifier（README:85）。
- ⚠️ Metal shader 真机才正确（模拟器 mock 兜底）；与 mlx 抢 GPU → 水波只在炸场高潮触发，不常驻。

## 4. 动效坑（pre-mortem 一手，必避）

| 坑 | 规避 | source |
|---|---|---|
| `numericText` 不 `withAnimation` 包裹则不动 | 值变更必 `withAnimation(.spring)` | README:47 |
| glow/breathe 用裸 `Timer` → 泄漏 100% CPU | 用 `.repeatForever` 隐式动画 / `TimelineView`（AppleIntelligenceGlowEffect 自述修过此 bug） | README:49 |
| 低电量/ReduceMotion 静默禁 `withAnimation` → 惊艳归零 | 关键态用颜色/数值/图标双通道，动画只锦上添花 | README:43 |
| `barge-in` didCancel 在 utterance 边界静默不触发 | 状态在调用点直接改，不只靠 delegate；`stopSpeaking(at:.immediate)` | README:48 |
| mlx 推理冻主线程（plain Task 继承 MainActor） | dedicated actor / `Task.detached` + token loop 内 `Task.yield()`+`checkCancellation` | README:45 |
| ContentView trace ForEach 用 `.offset` 当 id | 稳定 id + 拆子 view + 限条数 | README:57 |

## 5. 离线红线（U7，天然满足别返工）

- scheme1 用 emoji（❄️💺🪟）+ `-apple-system` 字体栈，**零 CDN**（README:24）。
- SwiftUI 落地：SF Symbols / 字体 / 图片必进 **Copy Bundle Resources** + plist key → 100% 离线（README:54 paper-tiger：真风险在 GPU 成本不在能否离线）。

## 6. 5 Gate 视觉验收（交付前 + 真实查看环境）

> 引全局 `aesthetic-first-principles`（5 Gate）+ MAformac 飞书白皮书血泪（看自己导出图 ≠ 用户实查）：

- [ ] 层级：主次一眼分（满足态 cyan 辉光 vs 未激活 dim 灰，对比明显）
- [ ] 对齐：卡片网格栅格对齐
- [ ] 遮挡：notch/顶栏不压关键信息
- [ ] 字体：暗底上 `ink #eaf0ff` 对比 ≥4.5:1；投屏 8bit 不 banding（U23 ⌃P 提亮）
- [ ] 重量：辉光不抢内容；cyan halation 控 30-60%（U11）
- 🔴 **逐张 Read 检测 + 还原真实查看环境**（Mac 屏 / 投影机 / iPhone），不看自己导出的高清图当通过

---

## 与 tokens.md 的关系
- `tokens.md` = 色/字/间/动效**值**（取什么）；本文 = HIG **约束规则**（怎么用、什么禁用）。
- 两者都建、不重复：tokens 给值，rules 给规则。agent 生成 view 前两个都读（INDEX 路由）。

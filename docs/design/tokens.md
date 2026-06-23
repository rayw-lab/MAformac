---
type: visual-ssot-tokens
status: DRAFT v1（CC0 起草；色/字/间/动效 = 锁 scheme1 一手 + U11/U2 拍板；7 态色 = CC0 基于 scheme1 色板 + U10 四态语义设计，**待磊哥审后冻结**）
date: 2026-06-23
owner: UIUE 链路A（worktree uiue/visual-ssot-state-consume）
source:
  - prototypes/scheme1-deep-space-interactive.html:8-83（深空辉光真色值，lens3/7/8 三路认证）
  - docs/grill-tournament/grill-decisions-master.md §3（U2 surface_role / U10 七态四分 / U11 base 色值）
  - raw/.../2026-06-22-uiue-ultracode/README.md:23（scheme1 三路认证 Polestar4/EQS+车控多模态+iOS HIG）
note: 🔴 **agent 生成任何 UI 前必读本文 + INDEX**。色值/字号/间距 = 视觉 SSOT 单源，禁 prompt 即兴（probe 结论3：不锁→视觉漂移→范式失败）。7 态色待磊哥审后从 DRAFT 转 FROZEN。
---

# MAformac 视觉 Design Tokens（深空辉光暗底科幻车机风）

> 视觉方向 = **深空辉光暗底 + 三屏分层（语音 orb 顶 / 对话流中 / 车控卡片下）**。已被 UIUE ultracode lens3/7/8 三路独立认证（README:23）。本文是把它**冻结成可被 agent 读的色卡库**，压住 LLM 视觉方差。

## 1. 色板（Color，锁 scheme1 一手 + U11 拍板）

### 1.1 底色 / 中性（深空层次）
| token | 值 | 用途 | source |
|---|---|---|---|
| `bg.base` | **`#121212`** | 全局 base 暗底（主，软黑非近纯黑） | U11 拍板（grill §3）⭐ + D2#2 复议上抬 |
| `bg.deepest` | `#05060c` | 最深渐变底（scheme1 `--bg0`） | scheme1:9 |
| `bg.halo.violet` | `#1a1336` | 顶部紫雾径向辉光（20% 0%，900×600） | scheme1:16 |
| `bg.halo.blue` | `#0a2540` | 顶部蓝雾径向辉光（90% 5%，900×600） | scheme1:17 |
| `bg.stage` | `#101630` | 卡片舞台区径向底 | scheme1:25 |
| `ink.primary` | `#eaf0ff` | 主文字（近白蓝） | scheme1:9 `--ink` |
| `ink.dim` | `#7c87a8` | 次要文字（灰蓝） | scheme1:9 `--dim` |
| `ink.dim2` | `#5f6a8c` | 未激活卡片图标/数值（更暗灰蓝） | scheme1:46,48 |

### 1.2 辉光主色（Glow，深空青紫）
| token | 值 | 用途 | source |
|---|---|---|---|
| `glow.cyan` | **`#00e5ff`** | 主辉光青（激活/在线/强调） | scheme1:10 `--cyan` |
| `glow.violet` | **`#7b5cff`** | 辅辉光紫（混搭渐变/座椅联动） | scheme1:10 `--violet` |
| `glow.cyan.on.bg` | `rgba(0,229,255,.12-.16)` | 激活卡片/badge 底（青雾 12-16%） | scheme1:32,49 |
| `glow.violet.on.bg` | `rgba(123,92,255,.14-.4)` | 座椅/卡片紫混搭底 | scheme1:38,49 |

🔴 **U11 halation 硬约束**（+ D2#2 复议上抬 base）：cyan 高饱和（`#00e5ff`）+ 近纯黑底（`#05060c`）= **光晕/散光高危**。规则：① **base 用 `#121212`（软黑，非近纯黑）**——盲评 loop-competition catch：原 `#0a0b12` 近纯黑 + 高饱和 cyan = 撞磊哥飞书白皮书「太丑看不清」同根因（halation 锁死风险），上抬软黑降低光晕 ② cyan 散光（glow shadow）占屏 **30-60%**，别铺满 ③ 高饱和 cyan 只用在【激活态强调】，大面积底用低透明 cyan 雾（`.12-.16`）④ 大面积辉光底色饱和度别拉满（软黑底上 cyan/violet 雾用 `.10-.14`，比原 `.12-.16` 再降一档防散光）。source: U11（grill §3:129）+ D2#2 复议（盲评 GAP④）。

### 1.3 功能态色（在线/离线/语义）
| token | 值 | 用途 | source |
|---|---|---|---|
| `state.online` | `#00e5ff`（cyan） | 网络在线 badge | scheme1:32 |
| `state.offline` | **`#ffb13c`**（琥珀橙） | 离线态/`100%端侧·0网络`徽章 | scheme1:28,33,83 |
| `bubble.user` | `linear(135deg, #1aa6ff → #5f2bff)` | 用户对话气泡 | scheme1:59 |
| `bubble.ai` | `rgba(255,255,255,.06)` + 边 `.08` | AI 对话气泡 | scheme1:60 |

## 2. DemoVisualState 7 态色映射（🔴 U10 四态必分开，现万能红字混=翻车）

> 消费源 = `Core/State/DemoVehicleStateStore.swift:17-25`（7 态枚举，A2 不碰此枚举）。U10（grill §3:124）：clarify/unsupported/safety_refusal/crash **四态分开**。
> ⚠️ **本表 7 态色 = CC0 基于 scheme1 色板 + U10 语义设计，待磊哥审后冻结**（scheme1 概念稿只给了 on/off/offline 三态，未映射全 7 态）。

| visualState | 语义 | 色 token | 视觉 | 为什么这色 |
|---|---|---|---|---|
| `normal` | 默认未激活 | `ink.dim2 #5f6a8c` | 灰蓝静默卡片 | scheme1 卡片 off 态 |
| `satisfied` | 已满足/激活 | `glow.cyan #00e5ff` + violet glow + breathe | 青紫辉光呼吸卡片 | scheme1 卡片 on 态:49-53 |
| `changing` | 执行中（过渡） | `glow.cyan` 脉冲（pulse 不停） | cyan 流动脉冲 | scheme1 pulse:69 |
| `blocked_with_alternative` | **clarify 澄清**（有替代=卖点） | `state.offline #ffb13c`（琥珀） | 琥珀提示卡（**非红**） | clarify=智能澄清非错误，琥珀区别于安全红 |
| `blocked_hard` | **unsupported 不支持**（拒识） | `ink.dim2 #5f6a8c` + 锁图标 | 灰锁卡（**非红**） | 不支持=优雅拒识，灰非告警 |
| `unsafe` | **safety_refusal 安全拒识**（安全门） | `safety.red #ff5c6c`（CC0 设计） | 警示红描边 | 安全门=唯一该用红的态 |
| `unknown` | **crash/未知**（真错误） | `ink.dim #7c87a8` + 错误图标 | 中性灰错误态 | crash=系统错误，区别于 unsafe 安全红 |

🔴 **四态分开铁律**：`blocked_with_alternative`（琥珀 clarify）≠ `blocked_hard`（灰 unsupported）≠ `unsafe`（红 safety）≠ `unknown`（灰 crash）。**clarify/unsupported 是 demo 卖点（智能拒识），绝不能渲成 unsafe/crash 的红**——这是 U10 头号翻车点（ContentView:122 现把所有非 satisfied 渲成灰，把 7 态压成绿/灰二值）。

## 3. 字体 / 字号（Typography，离线零 CDN）
| token | 值 | source |
|---|---|---|
| `font.family` | `-apple-system, "SF Pro Display", "SF Pro Text", "Helvetica Neue", system-ui, sans-serif` | scheme1:11（U7 离线红线：零 CDN，`-apple-system` 栈） |
| `font.title.gradient` | `linear(92deg, #fff → #00e5ff)` text-clip | scheme1:75（标题青白渐变） |
| `font.card.val` | 15px / weight 800 | scheme1:48 |
| `font.card.icon` | 18px | scheme1:46 |
| `font.btn` | 13.5px | scheme1:78 |

> SwiftUI 落地用 `.font(.system(...))`（= `-apple-system`），字号按 Dynamic Type 阶梯映射（待 hig-rules 细化）。

## 4. 动效 token（Motion，U5 一期 / 低电量双通道）
| token | 值 | 用途 | source |
|---|---|---|---|
| `motion.breathe` | box-shadow 呼吸，3.4s ease-in-out infinite | 激活卡片呼吸 | scheme1:50-53 |
| `motion.pulse` | mic/changing 脉冲（shadow 0→22px 扩散） | 语音/执行态 | scheme1:67-69 |
| `motion.spring` | `.spring`（值变更必包，否则 numericText 不动） | 数值滚动 | U10 pre-mortem README:47 |
| `motion.metal.ripple` | Inferno RippleEffect（**U5 一期做**，非二期） | 炸场水波 | U5 grill §3:119（磊哥改一期）|

🔴 **低电量/ReduceMotion 双通道铁律**（README pre-mortem）：低电量模式静默禁所有 `withAnimation`，惊艳归零。**关键状态必用「颜色/数值/图标」承载，动画只锦上添花**——动效挂了也能看懂态。

## 5. surface_role（Liquid Glass 用法，U2 只功能层）
> 详见 `hig-liquid-glass-rules.md`。token 层先定两 role：

| role | 用途 | 实现 |
|---|---|---|
| `control_glass` | **mic 按钮 / 顶栏**（功能层 Liquid Glass） | iOS18 `.glassEffect()` + iOS17 fallback `.ultraThinMaterial` |
| `content_glow` | **内容卡片**（自研 glow，**非** system glass） | 自研 cyan/violet box-shadow glow（scheme1:49-53），iOS26 system glass 旧机卡顿发热 |

🔴 U2 铁律（grill §3:116）：Liquid Glass **只**用 `control_glass`（mic/顶栏），内容卡用 `content_glow` 自研。**禁全局主题开关式** glass（内容层用 glass = 整屏糊 + HIG 违规 + 旧机发热，见 hig-rules T5）。

---

## 引用约定（被 CLAUDE/AGENTS 加载）
- 🔴 **生成任何 SwiftUI view 前，先读本文 + `hig-liquid-glass-rules.md`**（INDEX 路由）。
- 色值/字号/间距 **只从本文取**，禁手填 hex / 禁 prompt 即兴。
- 7 态色待磊哥审冻结后，status 转 FROZEN，本表成硬约束。
- 新视觉决策 → 先回写本文（SSOT 单源），再写 view。

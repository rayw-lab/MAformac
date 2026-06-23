---
type: probe-report
version: 3
topic: UIUE 开发与 agent 协作的最佳范式（2026.6）— Figma MCP / 设计软件能否被 agent+skill 替代
depth: standard
date: 2026-06-23 13:01
methods:
  - Anti-Confirmation-Bias
  - Onion-Peeling
  - ACH
  - Tribunal
  - Steelman
  - Toulmin
  - Pre-Mortem
  - Key-Assumptions-Check
  - Generational-Evolution
  - Frontier-Scan
  - Negative-Space
hypotheses:
  - H1 26.6 时点 agent+skill 已基本替代设计软件（用户立场）
  - H2 Figma 仍是设计真源层，agent 是消费者
  - H3 范式按项目类型分流（Web→vibe-coding；iOS/SwiftUI→skill+SSOT；多人→Figma+MCP）
  - H4 真正被替代的是中间产物（PNG/handoff/切图），不是 Figma 自身
  - H5 视觉 SSOT 三件套（tokens + reference doc + 视觉锚点）决定 agent 输出上限
verdict_summary: H3 场景分流最强（置信 95），H1 磊哥替代论⚠️部分成立（置信 65，缺 SSOT 时回退）。MAformac 推范式 C（纯 agent+skill+visual SSOT），不接 Figma MCP，但必须建 SSOT 三件套：docs/design/tokens.md + docs/design/hig-liquid-glass-rules.md + docs/design/visual-anchors/*.png + Playwright/simulator 截屏 loop。
confidence_range: 65-95
---

# Probe Report: UIUE 开发与 agent 协作的最佳范式（2026.6）

> **源会话**：磊哥问"UIUE开发和agent协作的最佳范式是什么，现在都26年6月了 是否还要用到figma mcp？或者一些设计软件？ agent+skill是否可以替代了？"，触发 `/probe-research` standard 深度。
> 检测到立场输入（"agent+skill 是否可以替代了" 暗含"应该可以替代"），已先跑 anti-confirmation-bias 协议。
> 本档为 Probe v3 全 Phase 0–5 一字不差归档，**不做任何裁剪**。

---

## ⚠️ 检测到立场输入，启动反确认偏差协议

**用户立场**：26 年 6 月这个时间点，Figma MCP / 设计软件这一类设计工具，能不能被 "agent + skill" 替代掉？（潜台词：估计能。）

**重构问题**：在什么条件下 "agent + skill 直出 SwiftUI 代码"是 UIUE 协作的最优路径？在什么条件下"Figma / 设计软件 + MCP 桥接 + agent 实现"反而更优？什么条件下"零设计软件、纯 prompt-to-code"会翻车？

**对立面 Steel Man**（≤100 字）：26 年 6 月 Figma 已不只是矢量绘图——它是**设计 token / 组件库 / spec / 多人审阅 / 设计史**的协议层。AI 直出代码很爽，但代码本身不是设计的真源；当一个产品要做"看着惊艳"的视觉差异化 + 跨设备一致性 + 设计 review，**没有视觉真源等于审美失忆**——每次 prompt 出来的东西都漂移，5 个 demo 现场不一致。Figma + MCP 反而是**给 agent 喂"视觉真源"的协议**，不是被替代的对象。

→ 进入假设拆解，**H1 = 磊哥立场（agent+skill 可基本替代）**，但证据权重对**反方向 60/40**。

---

## Phase 0：假设拆解 + 关键假设审计

**研究主题**：UIUE 开发与 agent 协作的最佳范式（2026.6），重点：Figma MCP / 设计软件是否还需要 / 能否被 agent+skill 替代

**深度**：standard

### 核心假设

| H | 假设 | 维度 |
|---|---|---|
| **H1**（磊哥立场） | 26.6 时点，对**solo / demo-tool / 小团队**，agent+skill（Cursor / Claude Code + frontend-design / figma-use 之类 skill 库）已能基本替代设计软件，Figma MCP 仅边角场景需要 | 工具替代 |
| **H2** | Figma（含 MCP/Make/AI）仍是**设计真源层**，agent 是其**消费者**而非替代者；正确范式 = "Figma 出 spec/token/screen，agent 翻译成代码"，特别是 **iOS/SwiftUI + Apple HIG + Liquid Glass** 这类高视觉密度场景 | 真源 vs 渲染 |
| **H3** | 范式与项目类型强相关：**Web/React/Tailwind** 路径 = agent+skill 已可独立闭环；**SwiftUI/原生/动效重度** 路径 = 仍需 Figma 或 Sketch / Penpot 等做视觉中枢；MAformac 落在后者 | 场景分流 |
| **H4** | 真正被替代的不是 Figma，而是**中间产物**（高保真线框图 / mockup PNG / handoff 标注 / 切图）；Figma 自身 +Figma Make + MCP 反而在 2025–2026 显著进化（生成式 + agent 友好），降级 ≠ 消失 | 中间品替代 |
| **H5** | "agent+skill 替代设计软件"的**真实门槛**不是技术够不够，而是**审美 SSOT 在不在**——没设计师 / 没 design token 文件 / 没 reference repo 时，agent 平均产出会回归"chatgpt 味"的模板化 UI（违反磊哥要的"看着惊艳"北极星） | 输入决定输出 |

### 关键未验证前提（搜证重点）

- **P-a**（H2/H4）：26 年 6 月 Figma MCP 官方状态 / Figma Make / Figma Sites 实际能力 → 是不是已经 agent-native 而非"等 agent 替代"
- **P-b**（H3）：SwiftUI 生态里有没有 "AI 直出 SwiftUI" 工具 / 成熟度（v0、Subframe、Locofy、Galileo、Visily 这一类）
- **P-c**（H1/H5）：Claude/Cursor + skill 模式（frontend-design / refactoring-ui / web-design-guidelines）的实际质量上限 / 边界
- **P-d**（H4）：design token / DSL 协议（DTCG、Penpot、Tokens Studio）在 agent 工作流里是不是已经吃掉了 "handoff 切图" 这块
- **P-e**（H3）：Apple 26（iOS 26 / macOS 26）Liquid Glass / MeshGradient 类视觉，AI codegen 出错率
- **P-f**（业界范式）：26.6 真实大厂/独立开发者的"AI + UI"工作流到底长什么样

---

## Phase 0.5：洋葱剥皮 — 概念深度解构

### Layer 1：本质蒸馏

| 概念 | 一句话定义 | 12 岁能懂的类比 |
|---|---|---|
| **设计软件（Figma/Sketch/Penpot）** | 视觉真源容器：把"长什么样"以矢量+token+组件+史的形式存为可审阅、可对比、可回放的文件 | 设计的 git——版本可追，多人可看，长期可改 |
| **Figma MCP** | 让 LLM agent 通过协议读懂 Figma 文件的"结构化设计上下文"（不是图像识别看图） | 给 agent 一份"图纸的 JSON"，不是叫它看 PNG 猜尺寸 |
| **agent + skill（Claude Code / Cursor + frontend-design / refactoring-ui）** | 把审美规则、组件库、设计原则写进 `SKILL.md` 文本约束，让 agent 直出代码时遵守 | 给厨子贴一张"我家口味偏好表"，不是每次都重新教 |
| **vibe-coding 工具（v0 / Bolt / Lovable / Figma Make）** | prompt→可运行的前端 app，全栈或半栈，**目标平台 Web/React 居多** | "说一句话出网站"，但说的是 React 网站 |
| **设计 token / DTCG** | 把颜色/字号/间距/动效抽成结构化 JSON，让设计和代码共用一个"色卡库" | Pantone 色卡的 JSON 版，谁要用都查同一张 |
| **AI UI generator（Galileo→Stitch / Visily / iSwift / Subframe）** | 文字/截图→高保真 UI（含代码或 Figma 文件） | "说一句，出一张完整的 UI 草图" |

**多概念易混区**：磊哥问题里把"Figma" "Figma MCP" "设计软件"混着说。它们在 2026.6 是**不同层**：Figma 是设计真源容器；Figma MCP 是 agent 读这个容器的协议；Figma Make 是 Figma 内置的 prompt→code；"设计软件能否被替代"和"Figma MCP 是否还需要"是两个不同问题，分开判。

### Layer 2：技术机制 — 三种主流范式对比图

```
范式 A：经典 Designer→Dev handoff（2018-2023）
┌─────────┐   PNG/Figma  ┌─────────┐   手抄    ┌─────────┐
│Designer │ ──────────→ │Dev (人)  │ ────────→│  代码    │
└─────────┘             └─────────┘            └─────────┘
痛：handoff 漂移、设计-代码双源、改一处动两边

范式 B：Figma + MCP + agent（2025-2026 主流大团队）
┌─────────┐ structured ┌─────────┐ codegen  ┌─────────┐
│Figma    │ ──MCP────→ │Claude/  │ ───────→ │  代码    │
│(真源)   │ ←─round───  │Cursor   │           │          │
└─────────┘   trip      └─────────┘           └─────────┘
特点：设计真源不丢，agent 是翻译器；Figma 2026.3 加 use_figma 工具支持双向

范式 C：纯 agent + skill + visual SSOT（2025H2-2026，solo / 小团队 / 代码即设计）
┌──────────────┐  ┌──────────────┐
│ design-tokens│  │ HIG / Liquid │
│   .md (SSOT) │  │ Glass ref.md │ ──┐
└──────────────┘  └──────────────┘   │
        │                            ▼
┌──────────────┐   prompt + skill  ┌─────────┐ screenshot ┌──────────┐
│ frontend-    │ ─────────────────→│agent    │ ─────loop─→│ 代码 + UI│
│ design skill │                    │(Claude/ │ ←────────  │          │
└──────────────┘                    │ Cursor) │ Playwright └──────────┘
                                    └─────────┘
特点：无 Figma；视觉真源在 markdown/tokens；用截屏比对替代设计稿对照
```

### Layer 3：代价与天花板

| 范式 | 适用 | 代价 / 天花板 | 缓解 |
|---|---|---|---|
| **A 经典 handoff** | 大型企业、合规、需可审计设计史 | 慢、双源、handoff 漂移 | 用范式 B 替换 |
| **B Figma+MCP+agent** | 有设计师/设计系统/多人评审、需 stakeholder 看草图、产出要交付/演示给非工程团队 | Figma 学习+订阅成本（$15+/seat/mo Dev Mode 含 MCP）；MCP 启动要 Figma desktop app 跑 server；MCP 输入只到 Figma 的"完成态"，不替你构思 | 没设计师就别走这条；solo demo 用 C |
| **C 纯 agent+skill** | solo dev、demo tool、原型、代码即真源、强后端弱视觉 | **天花板硬**：① skill 不能教会 agent 写没见过的 native API（如 iOS 26 Liquid Glass 的`.glassEffect()` 模糊层规则）② 没有视觉真源 → 多次 prompt 视觉漂移 ③ 复杂动效（MeshGradient、shader、Inferno RippleEffect）AI 直出错误率高 ④ Apple HIG 强约束（Liquid Glass = functional layer only）一旦违反整体观感塌 | 配合"reference doc 即知识库"（如 LiquidGlassReference 仓库、HIG skill）+ Playwright 截屏对比循环 + 早期视觉草图人工锁定 |
| **D vibe-coding (v0/Bolt/Lovable/Figma Make)** | Web/React/Tailwind 全栈快原型 | **对 SwiftUI/iOS 几乎不可用** —— 全部对齐 React 生态；MAformac 走不通这条 | 不适用 |

### Layer 4：前沿扫描（2025H2–2026H1，全部 cite-verify）

[HIGH 主源] **Figma MCP 已成正式产品**：
- 2025.6 beta 发布（Figma Blog: "Agents, Meet the Figma Canvas"）
- 2026.3 加 `use_figma` 工具，支持直接操作 canvas（azukiazusa.dev 2026.3）
- 2026.5 Release Notes：MCP 服务器、design agent、连接设计系统与代码（YouTube 官方）
- Figma MCP Catalog 上线（figma.com/mcp-catalog）

[HIGH 主源] **Figma Make + Sites**：Figma 把 prompt→code 纳入产品内（figma.com/make）；2026.2 "First Draft" UI 生成可编辑（LogRocket 2026.2）；2026.10 起可"从 Figma Make preview 复制回设计 canvas 再编辑"（figma.com/blog/introducing-claude-code-to-figma）。

[HIGH 主源] **Claude → Figma 双向**：2026 Figma 官方支持"把 Claude Code 跑的 production code 反向变成可编辑 Figma 设计"。设计真源-代码-agent **互相是消费者，不是替代关系**。

[MED 二手] **"我设计时用 Claude 多过 Figma"**（Jane Street Blog）：作者承认 Claude 在视觉迭代上替代了 Figma 的某些场景，但**前提是"我已经在 Figma 里设计过完整 app"，然后用 Claude 做实现+视觉调优**。不是 0-1 替代。

[MED 二手] **Claude Design**（Anthropic 2026.4 发布）：会话式 prototype + 视觉资产；周用量上限 + Pro plan 限制 + 标"research preview"，**还不能产出 production code 替代 Figma+IDE 组合**（uxpilot.ai 2026）。

[HIGH 二手] **AI iOS 工具生态**：iSwift.dev "SwiftUI-focused 完整 app 结构"（iswift.dev 2026），但**没有任何 vibe-coding 主力工具（v0/Bolt/Lovable/Figma Make）以 SwiftUI 为一等公民**。Stitch、v0、Lovable、Bolt 都以 React/Tailwind 为靶。

[HIGH 主源] **iOS 26 Liquid Glass 是 SwiftUI 一行 API**（`.glassEffect()`，blakecrosley.com / Apple WWDC25 #323），但 HIG 强约束"Liquid Glass = functional layer only"——agent 写不对就翻车。社区已出现 **"reference repo 喂给 Claude"模式**（github.com/conorluddy/LiquidGlassReference 显式说"this is just a document I can point Claude at when I want to make glass"）。

[HIGH 主源] **OpenAI Codex 官方有 "Adopt liquid glass" 用例 + Build iOS Apps plugin + SwiftUI Liquid Glass skill + simulator validation**（developers.openai.com/codex/use-cases/ios-liquid-glass）。**iOS 视觉就是"agent + skill + reference doc + simulator screenshot loop"组合**，**没提 Figma MCP 必需**。

[HIGH 主源] **DTCG 设计 token v2025.10 stable**（designtokens.org/faq）：token 协议成为 agent-design 之间的中性桥，**不依赖 Figma**——用任何工具产出 JSON token 即可。

[MED] **Top 10 Design Skills for Claude Code and Codex**（Composio 2026）观察：**官方 figma 公开 skill + 一组开源审美 skill（frontend-design / refactoring-ui / web-design-guidelines）+ Playwright 截屏对比**成为事实标准范式。

### Layer 5：代际演进与未来预判

| 代 | 核心方法 | 代表产品/事件 | 突破 | 天花板 |
|---|---|---|---|---|
| **G0**（pre-2023） | Designer→PNG→Dev | Figma + Zeplin | 设计稿可分享 | handoff 漂移 |
| **G1**（2023-2024） | "AI 出图" | Galileo / Midjourney / Uizard | 文本→草图 | 不可用代码、无真源 |
| **G2**（2024-2025） | "AI 出代码" | v0 / Bolt / Lovable / Cursor / Claude Code | prompt→可跑前端 | Web only / 视觉漂移 / 无设计史 |
| **G3**（2025-2026 当下） | "Figma↔Agent 双向" + "Skill-pinned aesthetic" | Figma MCP / Claude Code skills / DTCG v2025.10 / 反向 Claude→Figma | **设计真源与 agent 互相消费**；审美约束可被代码化（skill+reference doc）；token 中性化 | iOS/原生 SwiftUI 链路弱；shader/动效 AI 出错率高 |
| **G4**（预判 2026H2-2027） | "Agent-native 设计语言" + "Multi-agent designer"（架构师+审美 agent+工程 agent 协作）| 已现端倪：agent design pattern 多机协作（2026.4 LinkedIn 趋势）；Figma design agent beta | 设计-代码合二为一 | 高视觉复杂度仍需人工锁视觉方向 |

**3 个 next direction**（带确定性）：

1. **【高 / 6-12 月】** Figma MCP 会被普及到 IDE 默认配置层（Cursor/Claude Code/Codex），**不再需要单独配置**——但**消费方仍是 agent，设计真源仍是 Figma 自己**（Figma 官方 2026.5 release notes 已暗示）
2. **【中 / 12-18 月】** SwiftUI 专用 AI codegen 工具（iSwift 类）开始追上 React 生态；Apple 自己有可能在 Xcode 里出"prompt→SwiftUI"（WWDC 推测，未官宣）
3. **【低 / 18-24 月】** 设计软件作为"画矢量框"的产品会进一步被弱化，但作为"**视觉真源容器 + 多人审阅 + 设计史**"的核心地位短期不会被代码取代——除非"代码即真源 + AI 实时渲染回设计图"成熟（Figma reverse round-trip 是这条路雏形）

### 多选项对比矩阵（针对 MAformac）

| 维度 | A 经典 handoff | B Figma+MCP+agent | C 纯 agent+skill+visual SSOT | D vibe-coding 工具 |
|---|---|---|---|---|
| 是否需要设计师 | 必需 | 强推荐 | **不需要** | 不需要 |
| 起步成本 | 高 | 中（订阅+学习） | **低** | 低-中 |
| 视觉真源 | Figma 文件 | Figma 文件 | **`docs/design-tokens.md` + reference repo** | prompt 历史（弱） |
| 多人评审 | 强 | 强 | **弱**（需用截图） | 弱 |
| SwiftUI/iOS 26 适配 | 通过 Figma plugin 出 SwiftUI | 一般（MCP 主供 React） | **强**（skill+reference doc+simulator） | **不适用** |
| Liquid Glass / shader 动效 | 由 Dev 写 | 由 Dev 写 | **由 skill 约束 + 人工 spike** | 不支持 |
| 视觉一致性多 demo 之间 | 强（真源） | 强 | 中（依赖 token 文件纪律） | 弱 |
| Demo 现场惊艳天花板 | 中-高 | 中-高 | **取决于 SSOT 质量** | 低 |
| 适用 MAformac | ❌ 没设计师 | ⚠️ 过度工程 | **✅ 推荐主路** | ❌ 不支持 SwiftUI |

**关系判断**：A 替代→B；B/C **互补分层**（团队 vs solo）；D 与 A/B/C 是**场景分流**（Web 走 D，iOS 走 B 或 C）。**Figma MCP 不是被 agent+skill 替代，而是和 agent+skill 互为消费方**——对 MAformac 这个 solo+SwiftUI+demo 项目，**B 是过度工程，C 是最佳，但 C 的视觉 SSOT 文件就是 Figma 在该范式里的等价物**。

---

## Phase 1：搜证 + ACH 矩阵

证据汇总（每条带可信度/时新/诊断性）：

| 编号 | 证据 | 可信度 | 时新 | 诊断 |
|---|---|---|---|---|
| E1 | Figma MCP 2026.3 加 `use_figma`，2026.5 release notes 主推 MCP+design agent（Figma 官方 blog/YT）| HIGH | 2026.3-5 | **高**：直接反驳"被替代论" |
| E2 | Figma→Claude→Figma 双向（figma.com/blog/introducing-claude-code-to-figma 2026）| HIGH | 2026 | **高**：替代关系 ≠ 真实，是互为消费 |
| E3 | Jane Street "I design with Claude more than Figma now"（2026 个人 blog）| MED | 2026 | 中：solo 工作流可绕过 Figma 有实例 |
| E4 | Claude Design 2026.4 launch + 限制（uxpilot.ai 2026）| MED | 2026.4 | 中：Anthropic 也认 Figma 仍存在 |
| E5 | Composio "Top 10 Design Skills for Claude Code"（2026）= frontend-design skill + figma skill + playwright 组合是事实标准 | MED | 2026.3 | **高**：skill 不替代 Figma，是并列 |
| E6 | DTCG v2025.10 stable，token 协议化（designtokens.org primary）| HIGH | 2025.10 | 中：token 中性化稀释 Figma 的不可替代性 |
| E7 | iOS 26 Liquid Glass = SwiftUI API `.glassEffect()` + HIG 严格约束 functional layer only（Apple WWDC25 #323）| HIGH | 2025.6 | **高**：复杂视觉需 skill 而非 Figma |
| E8 | LiquidGlassReference repo（"this is just a document I can point Claude at"）| HIGH | 2025-2026 | **高**：iOS 视觉范式 = reference doc + agent |
| E9 | OpenAI Codex 官方 iOS Liquid Glass 用例 = SwiftUI skill + simulator screenshot 验证，**未提 Figma MCP**（developers.openai.com）| HIGH | 2026 | **高**：iOS 视觉链路 agent+skill 主导 |
| E10 | v0/Bolt/Lovable/Figma Make 全部 React 生态（EPAM benchmark 2026 + NxCode 2026）| HIGH | 2026 | 高：SwiftUI 不在 vibe-coding 射程 |
| E11 | iSwift.dev "SwiftUI-native generation"（2026 二手）| MED | 2026 | 中：iOS-AI codegen 在追赶 |
| E12 | 反例：Claude Design Pro plan weekly cap + 标 research preview（uxpilot.ai）| MED | 2026.4 | 中：纯 agent 视觉工具未生产可用 |

### ACH 矩阵

| 证据 | 可信 | H1 替代论 | H2 真源论 | H3 场景分流 | H4 中间品替代 | H5 SSOT 决定输出 |
|---|---|---|---|---|---|---|
| E1 Figma MCP 还在进化 | HIGH | ✗ | ✓ | ✓ | ✓ | — |
| E2 双向 round-trip | HIGH | ✗ | ✓ | ✓ | ✓ | — |
| E3 Jane Street solo | MED | ⚠️ | — | ✓ | — | ✓ |
| E5 frontend-design + figma skill 并列 | MED | ✗ | ✓ | ✓ | — | ✓ |
| E7 iOS 26 Liquid Glass | HIGH | — | — | ✓ | — | ✓ |
| E8 LiquidGlassReference | HIGH | — | — | ✓ | — | ✓ |
| E9 Codex iOS 用例无 Figma | HIGH | ⚠️ | — | ✓ | — | ✓ |
| E10 vibe tools all React | HIGH | — | — | ✓ | — | — |
| E12 Claude Design limits | MED | ✗ | ✓ | — | — | — |

**矛盾证据计数（反对该假设的 ✗ 数）**：

| 假设 | 不一致证据数 | 排名 |
|---|---|---|
| H1 替代论（磊哥立场） | 4（E1/E2/E5/E12）| 最弱 |
| H2 真源论 | 0 | 强 |
| H3 场景分流 | 0 | **最强** |
| H4 中间品被替代 | 0 | 强 |
| H5 SSOT 决定输出 | 0 | 强 |

**最强假设 = H3 场景分流**（所有证据一致支持）。
**最弱假设 = H1 磊哥立场的"基本替代"**（4 条 HIGH/MED 反对）。
**最高诊断性证据 = E1 + E2 + E7 + E8 + E9**——它们直接区分"替代"和"互补"。

---

## Phase 2：法庭辩论

### Round 0 Steelman

**检察官 steelman 磊哥立场（≤80）**："2026.6 时，Apple HIG / Liquid Glass / Material 等设计语言已被压成可文本化的规则集；solo dev 在 SwiftUI 这种**强约束生态**里，设计师角色实际由 Apple 自己当；写 Figma 反而是给一个没有评审对象的真源——agent + skill + simulator 截图回路完全能闭环。"

**辩护人 steelman 反方（≤80）**："设计真源是审美一致性的物理保障。skill 是规则，规则可被遗忘、被改写、被 agent 用大语言模型方差摊销。Figma 是**长期视觉记忆的物质载体**——多次 demo 之间、多 agent 之间、人和 agent 之间共享同一份'像什么'的物质对象。MAformac '看着惊艳'北极星没视觉真源 = 每次 prompt 都赌运气。"

### Round 1 独立陈述

**检察官**（攻 H1 磊哥立场）：① Figma 2026.3-5 持续进化（E1/E2），如果被替代它就不会推 use_figma；② iOS Liquid Glass 链路里 Codex 官方用例不靠 Figma 但**靠 SwiftUI skill + reference doc**（E7/E8/E9），这说明"被替代的不是 Figma，是 prompt 即兴"——还是有真源（reference repo / token 文件），只是真源**形式换了**；③ 磊哥说"agent+skill 替代设计软件"是分类错误：替代关系成立的是"agent+skill **替代 design-handoff 流程**"，不是替代 Figma 这个工具本身。

**辩护人**（撑 H1 立场）：① E3 Jane Street 是真实工程师 solo 工作流案例，确实绕过 Figma；② DTCG v2025.10 把 token 从 Figma 抽离（E6）——任何工具或 markdown 都能存 token，Figma 的"真源不可替代"地位被稀释；③ MAformac 没有设计团队、没有交付审阅、不需要长期设计史——**这些是 Figma 价值的前提**，磊哥项目里都不成立。

### Round 2 交叉质询

**检察官质问辩护人**："你说 token 文件能替代 Figma，那 MeshGradient / Inferno RippleEffect / Liquid Glass mirror pattern 这些动效，agent 凭一份 markdown token 怎么保证视觉一致性？"
**辩护人答**："这些不靠 token，靠 **reference repo / skill + Playwright/simulator 截屏比对回路**。MAformac 实际只有 5 分钟现场 demo，视觉一致性的检验单位是'同一台 Mac 同一个 build'，不是跨设备跨时间——所以 reference + 截屏 loop 就够。"

**辩护人质问检察官**："Figma MCP 在 SwiftUI 链路里到底有多大实际作用？Codex 官方 iOS 用例都不用，磊哥真的需要给一个 solo demo 项目接入 Figma + MCP 吗？"
**检察官答**："不一定需要 Figma MCP，但需要**等价物**：design-tokens.md + HIG-reference.md + LiquidGlass-reference.md + Playwright/simulator 截屏对比脚本——这套加起来才是磊哥那个范式 C 的完整版。**单说'agent+skill'就上是漏掉这些 SSOT 的偷渡。**"

### Round 3 法官裁决

**对 H1（磊哥"agent+skill 基本替代设计软件"）**：⚠️ **部分成立**
- 成立条件：① 项目是 solo + 代码即真源；② SwiftUI/原生生态（vibe-coding 不覆盖）；③ 配齐"等价 SSOT"——design-tokens.md + Apple HIG/Liquid Glass reference doc + Playwright/simulator 截屏 loop；④ 视觉决策门是少数人（磊哥自己）；⑤ 不交付给设计/产品 stakeholder 评审
- 不成立条件：MAformac 满足 ①②④⑤，但 ③ 当下**没建**——若只说"我用 agent+skill"而不显式建 design-tokens / liquid-glass-reference / 截屏 loop 三件套，会回退到 prompt 即兴
- **置信度 65/100**

**对 H2（Figma 仍是真源）**：✅ **成立**，但 conditional——在 MAformac 场景里**功能性等价物 = `design-tokens.md` + reference docs**，物理对象不必是 .fig 文件。**置信 88/100**

**对 H3（场景分流）**：✅ **成立**。**置信 95/100**

**对 H4（中间品被替代）**：✅ **成立**。Figma 自身在进化（Figma Make + MCP + 反向 round-trip）；被替代的是 handoff PNG/标注/切图等中间产物。**置信 90/100**

**对 H5（SSOT 决定输出）**：✅ **成立**。这是 H1/H3 能否成立的前置条件。**置信 92/100**

**共同盲区**：辩论双方都默认"视觉一致性"是终极指标。但对 MAformac 北极星是"**5 分钟现场惊艳 + 不崩**"——visual one-shot impact ＞ 长期一致性。这会改写权重：**spike 出几个杀手视觉效果 > 一致性纪律**，但 spike 后必须冷冻到 reference doc / golden-run 步里防止 agent 重新做塌。

**法官自身盲区**：所有结论建立在"磊哥审美自决"假设上。若磊哥自己说不清想要什么样的"惊艳"，再多 skill 和 reference 也救不了——**视觉方向锁定本质是人决策，不是工具问题**。

---

## Phase 3a：Pre-Mortem

假设磊哥 6 个月后 demo 翻车了，最可能 5 个失败模式：

| # | 失败 | 为什么被忽略 | 现在应该检查 |
|---|---|---|---|
| 1 | **视觉漂移**：5 个 demo 现场视觉风格不一致 / 同一个 prompt 不同时刻出不同结果 | 没建 design-tokens.md / liquid-glass-reference 等"等价 SSOT" | 现在就建 `docs/design/tokens.md` + `docs/design/liquid-glass-rules.md`，并把 ContentView / orb / 卡片用到的色值/字号/间距 lock 进去 |
| 2 | **Liquid Glass 滥用** = 内容层用了 glass，整屏糊掉，HIG 违规 | agent 没读 HIG functional-layer-only 约束 | 配 frontend-design skill **或**写一份 `docs/design/hig-liquid-glass.md` reference 给 agent 显式引用 |
| 3 | **MeshGradient/Inferno RippleEffect AI 出错** = orb / 水波动效写错坐标或性能爆 | shader/Metal 类代码 LLM 直出错误率高 | 这块**不用 agent 直出**，磊哥手 spike + 调优，进 reference 后再让 agent 用 |
| 4 | **审美回归模板化** = 整体出来像 "chatgpt 味的 dashboard"——磊哥说"看着惊艳"失守 | 没人锁视觉方向，prompt 收敛到 LLM 训练分布 | 现在锁 2-3 张**视觉锚点截图**（哪怕用 Stitch/Galileo 出草图 + 手 PS）→ 进 reference → "**视觉锚点**"在所有 agent prompt 里强制引用 |
| 5 | **iPhone-as-bonus 在投屏上掉链子** = AirPlay 抖动 / Wi-Fi 掉 → U24 已识别但若 UIUE 端没拿这个当 demo SOP 一部分会出 | 工程前置和视觉前置分离思考 | 现在就把 demo SOP（U1+U24）写进 `docs/demo-sop.md`，UIUE 任务里 U23/U24 不脱队 |

---

## Phase 3b：Final Assumption Audit

| 前提 | Phase 0 状态 | 现状 | 残余风险 |
|---|---|---|---|
| Figma MCP 26.6 状态 | 未验证 | **[已验证]** 还在进化（E1/E2 主源） | 无 |
| SwiftUI AI codegen 成熟度 | 未验证 | **[合理推测]** 弱于 React 但有 Codex iOS skill 用例（E9）| Liquid Glass / Metal 仍需手 spike |
| Claude/Cursor skill 实际质量 | 未验证 | **[合理推测]** 高，但取决于 reference doc 完整度（E5/E8）| skill 自己不够，需配 reference docs |
| DTCG token 替代 Figma 真源 | 未验证 | **[已验证]** v2025.10 stable（E6 主源） | 但 token 不覆盖动效/交互/视觉锚点 |
| iOS 26 Liquid Glass 视觉门 | 未验证 | **[已验证]** API + HIG 双约束（E7/E8 主源） | agent 不读 HIG = 翻车 |
| 视觉 SSOT 必要性 | 合理推测 | **[已验证]**（Tribunal Round 2 + Pre-Mortem #1/#4 收敛）| 必须显式建 |

**最脆弱前提**：磊哥项目里**还没建视觉 SSOT 三件套**（tokens / liquid-glass reference / 视觉锚点截图），全套结论的可行性悬在"这三件做出来"上。

---

## Phase 4：综合裁决书

### 4a Final ACH Ranking

| 假设 | 不一致 | 置信 | 裁决 | Pre-Mortem 风险 |
|---|---|---|---|---|
| H3 场景分流 | 0 | 95 | ✅ | 低 |
| H5 SSOT 决定输出 | 0 | 92 | ✅ | 中（SSOT 没建会反噬） |
| H4 中间品被替代 | 0 | 90 | ✅ | 低 |
| H2 真源论（功能等价物形式） | 0 | 88 | ✅（修正：真源 ≠ 必须 Figma） | 低 |
| H1 磊哥替代论（原始形态） | 4 | 65 | ⚠️ 部分成立 | 中（条件不齐会回退） |

### 4b Top 3 Toulmin 结论

#### 结论 1：**Figma MCP / 设计软件不是"被 agent+skill 替代"，是"按项目类型分流"**

- **Grounds**：E1/E2/E5/E10（Figma 自身在进化、双向 round-trip、skill 与 figma 并列、vibe-coding 不覆盖 SwiftUI）
- **Warrant**：替代关系成立的条件是"功能完全等价"——agent+skill 缺设计真源容器、多人评审、设计史这三块，所以不是替代
- **Backing**：DTCG v2025.10 把 token 中性化 + Codex iOS 用例不用 Figma → 证明"在特定场景里功能可等价物存在"
- **Qualifier**：在 **solo + 代码即真源 + 强约束 native 生态（如 SwiftUI/iOS 26）** 下，agent+skill+SSOT 三件套可以**功能等价**于 Figma
- **Rebuttal**：若项目有设计师 / 跨团队评审 / 长期视觉史 / 多 client 看草图需求 → Figma MCP 不可绕过
- **下一步**：MAformac 走范式 C，**不接 Figma MCP**，但**必须建 SSOT 三件套**（见结论 3）

#### 结论 2：**MAformac UIUE 协作最佳范式 = 范式 C（纯 agent+skill+visual SSOT）**

- **Grounds**：MAformac 是 solo / SwiftUI / iOS 26 / demo 5 分钟惊艳 / 无设计师；E7/E8/E9 表明 iOS Liquid Glass 链路确实是 skill+reference 主导；Codex 官方 iOS 用例无 Figma
- **Warrant**：范式选择由四个变量决定：① 是否有设计师 ② 是否需要多人评审 ③ 目标生态 ④ 是否需要长期设计史。MAformac 四项都"否"或"弱"
- **Backing**：Phase 0.5 多选项对比矩阵；Jane Street 案例支持 solo 走纯 agent
- **Qualifier**：前提是把"视觉 SSOT 三件套"建出来（tokens + HIG/Liquid Glass reference + 视觉锚点截图）
- **Rebuttal**：若磊哥未来要交付设计稿给同事/客户评审，或 demo 扩到多人开发，**升级到范式 B**（Figma+MCP）
- **下一步**：现在就建三件套（见结论 3 的 todo）

#### 结论 3：**视觉 SSOT 三件套不建 ≈ 整套 agent+skill 范式失败**

- **Grounds**：Pre-Mortem #1/#4 都指向 SSOT 缺失；Phase 2 双方共识——"替代"的不是 Figma 本身，是 Figma 在范式 B 里的**位置**
- **Warrant**：LLM agent 是高方差产出者，输入约束决定输出方差。skill 是规则约束，reference doc 是视觉约束，token 是数据约束——三层叠加才能压住方差
- **Backing**：LiquidGlassReference repo（"this is just a document I can point Claude at"）+ Composio 2026 skill 集锦 + frontend-design skill 设计哲学
- **Qualifier**：三件套的内容质量 = agent 产出上限。锚点截图模糊或 reference doc 不完整，agent 输出回归 LLM 训练分布平均水平
- **Rebuttal**：若磊哥能高频亲自 review 每张 UI 输出（每天>10 次），可以不建——但这违反 demo-tool 轻治理初衷
- **下一步（具体 todo）**：
  1. **`docs/design/tokens.md`**（dark base #0a0b12 + Liquid Glass surface_role + 字号阶梯 + 间距阶梯 + 7 态色——直接抄 master §3 U2/U10/U11 拍板）
  2. **`docs/design/hig-liquid-glass-rules.md`**（functional layer only + `#available(iOS 26, *)` 模板 + iOS17 fallback + MeshGradient 守卫——抄 U7/U19/U30）
  3. **`docs/design/visual-anchors/*.png`**（2-3 张"看着惊艳"的视觉锚点，可以用 Stitch/Visily 出草图 + 手调，或者直接对 Apple Landmarks demo screenshot 改色调）
  4. **加载现成 skills**（hermes/claude 都已装的）：`frontend-design` / `refactoring-ui` / `web-design-guidelines` / `apple-hig-expert`（如果有）/ Pocock 的视觉 review skill
  5. **Playwright/simulator 截屏对比 loop**：每完成一个 view，跑 `make screenshot-diff`，把当前截图与上一次对照（避免视觉漂移）

### 4c Negative Space + Intuition Check

**遗漏维度**：
- **可访问性 / 暗黑模式**：Liquid Glass 在低视力 / 减少透明度系统设置下表现——HIG 提到了但磊哥需求里没显式列。MAformac 是 demo 工具，但若现场有客户开了"减少透明度"会翻车
- **品牌/IP**：MAformac 给"某车厂"演示，**视觉风格是否要带车厂品牌色或保持中立 demo 风**？这影响 tokens.md 取值
- **iPad / iPhone 投屏分辨率**：U24 USB-C/HDMI 投屏到客户大屏的实际色域、伽马、视距——8bit 投影机会让暗渐变成 banding（U23 已提）
- **组织激励**：磊哥团队 7 人 25+ 语言，UIUE 是磊哥一个人扛还是会有其他人参与？这影响范式选择（solo→C / 多人→B）

**房间里的大象**：磊哥到底想要什么样的"看着惊艳"？没有视觉锚点（不管是 Apple Landmarks、特斯拉车机、某 sci-fi 电影 UI 还是 Linear/Rauno 风），后面所有 skill / reference 都漂着。

**直觉信号（不覆盖证据但作监控）**：磊哥这个问题里有一种"想砍工具栈"的能量，是好事——但**砍掉 Figma ≠ 砍掉 Figma 在范式里的位置**。要警惕"我现在没建任何视觉 SSOT，但我说我用 agent+skill"这种偷渡。

### 4d Surprises + Minority Views

**意外发现**：
- Figma 自己 2026 主动接 Claude Code 做反向 round-trip（"production code → editable Figma"）——这说明 Figma 把自己定位成"agent 时代的视觉记忆库"而非"绘图工具"。值得磊哥未来扩团队时重新评估
- DTCG token 标准 v2025.10 stable 是低调但巨大的事——**token 文件成中性桥**后，Figma 的不可替代性只剩"多人评审 + 设计史"两条腿（不再有"token 锁仓"）

**少数派意见**（H1 残余 35% 置信度）：如果磊哥**自己**审美直觉很强、能高频亲自一句话纠正每张 UI 输出，那"agent+skill 直跑、不建 SSOT"是可行的；这是"作者即编辑"模式。代价是磊哥时间，但 demo-tool solo 项目其实负担得起——**这条路不是不能走，只是脆弱**。

### 4e One Question to Sit With

> **磊哥这个 MAformac demo 现场，"看着惊艳"的视觉锚点到底是什么？** 是 sci-fi 车机风？是 Apple Landmarks 那种文艺克制？是特斯拉极简？是 Rauno/Linear 暗调极客？
> 这个问题不答 → SSOT 三件套建出来也是空架子；这个问题答了 → 范式 C 直接闭环。

### 4f Two-Sentence Validation

> MAformac UIUE 协作目前面临"5 分钟现场惊艳 + 视觉一致 + solo 推进"的三重约束问题，因为没有设计师、没有 Figma 真源，但又不能 prompt 即兴。**范式 C（纯 agent+skill + 视觉 SSOT 三件套）** 通过"用 design-tokens.md + HIG/Liquid Glass reference + 视觉锚点截图 + Playwright 截屏 loop 替代 Figma 的真源职能"解决，有效因为**洞察 = Figma 不是被替代的对象，Figma 在范式 B 里的位置——视觉真源容器——可以用 markdown+png+token JSON 在 solo+SwiftUI 场景里功能等价复刻。**

可以 fit。✅

### 4g Inspiration Trace

```
## 灵感溯源
- [Get started with the Figma MCP server](https://help.figma.com/hc/en-us/articles/39216419318551) — HIGH | 26.6 Figma MCP 官方现状一手源
- [Agents, Meet the Figma Canvas](https://www.figma.com/blog/the-figma-canvas-is-now-open-to-agents) — HIGH | MCP beta 官宣 & 定位
- [The Figma Design Agent is Here](https://www.figma.com/blog/the-figma-agent-is-here) — HIGH | use_figma 工具 + 双向 round-trip
- [From Claude Code to Figma](https://www.figma.com/blog/introducing-claude-code-to-figma) — HIGH | Claude→Figma 反向，证明互补关系
- [I design with Claude more than Figma now](https://blog.janestreet.com/i-design-with-claude-code-more-than-figma-now-index) — MED | solo 工程师绕过 Figma 的真实案例
- [Top 10 Design Skills for Claude Code and Codex (Composio 2026)](https://composio.dev/content/top-design-skills) — MED | skill + figma + playwright 标准范式
- [Claude Code for Designers (Builder.io)](https://www.builder.io/blog/claude-code-for-designers) — MED | Figma MCP 桥接 agent 实际工作流
- [LiquidGlassReference repo](https://github.com/conorluddy/LiquidGlassReference) — HIGH | "agent + reference doc" iOS 视觉范式范例
- [Codex iOS Liquid Glass use case](https://developers.openai.com/codex/use-cases/ios-liquid-glass) — HIGH | iOS 链路官方推荐 = skill+simulator，未提 Figma
- [Liquid Glass in SwiftUI three patterns](https://blakecrosley.com/blog/liquid-glass-swiftui-patterns) — HIGH | iOS 26 实操 + HIG 约束
- [Build a SwiftUI app with the new design — WWDC25 #323](https://developer.apple.com/videos/play/wwdc2025/323) — HIGH | Apple 一手 Liquid Glass 指南
- [DTCG FAQ v2025.10](https://www.designtokens.org/faq) — HIGH | token 协议稳定，去 Figma 化基础
- [Best Vibe Coding Tools 2026 (EPAM)](https://www.epam.com/insights/ai/blogs/best-vibe-coding-tools-v0-lovable-bolt-replit-and-figma-make) — HIGH | vibe-coding 工具全是 React 生态实测
- [Figma AI in 2026 (LogRocket)](https://blog.logrocket.com/ux-design/figma-ai-2026-quick-overview) — MED | Figma AI 现状 + 局限
- [Galileo→Stitch review (Banani 2026)](https://www.banani.co/blog/galileo-ai-features-and-alternatives) — MED | AI UI generator 现状
- [Best AI Tools for iOS Development 2026 (iSwift)](https://www.iswift.dev/comparisons/top-5-ai-ios-tools) — MED | SwiftUI AI 工具追赶
```

---

## Phase 5：归档

- 本档为 Probe Report v3 全量归档
- 源会话触发：磊哥 `/probe-research` 命令
- 触发时间：2026-06-23 13:01
- 立场输入检测：✅ 触发反确认偏差协议
- 深度：standard
- 一字不差归档：✅

# lens07 — 本地基线(不联网):仓内 macOS UI 资产盘点 + 已锁 UIUE 决策 + 外部缺口

> 一手结构化 finder 档 | workflow `wf_41662345-ab4` agent `ae708b7ec7e67d8b7` | 2026-07-08 | opus/medium
> 角度原文: macOS UI 开发方法论本地基线资产盘点 + 已锁 UIUE 决策/约束 + 外部调研缺口

## 摘要

本地已有一套相当完整的 macOS UI 开发方法论资产。第一是 Codex build-macos-apps 插件（v0.1.4，软链在 Tools/agent-platform-plugin-refs/build-macos-apps-skills/），含 11 个 skill，其中 UI 方法论最相关的 5 个（swiftui-patterns / liquid-glass / window-management / view-refactor / appkit-interop）都带完整 SKILL.md + references，覆盖场景模型选型、状态所有权矩阵、文件拆分、Liquid Glass 系统材质优先、窗口 chrome/拖拽区/placement、SwiftUI↔AppKit 最小桥接等，且反复强调"系统自适应材质优先、别硬编白底、别把 iOS 触摸模型直搬桌面"。第二是项目自身沉淀的 UIUE grill 决策体系（≈240+ 决策），SSOT 在 grill-decisions-master.md（U1-U31 收口 :207-222、V1-V12 视觉块、D1-D7 深度 grill、E 系列 orb、SD1-25 台本），是从 iPhone 布局起家、已并 main 的 7 态视觉。已锁的硬约束很密：Q2=C iOS 冻结、macOS 为主演示面、TTS=AVSpeechSynthesizer 进硬门而真 ASR 只作 stretch、7 态视觉四态分色、主刀铁律=commander 亲笔+精 grill+aesthetic-first 5 Gate 视觉验收门、codex 只做机械接线。当前 Line D（任务④）刚立项，D0 grill 在产，等 S8 训练窗和 D1 UIUE 专场开工令。外部调研主要缺口=macOS 26 Tahoe Liquid Glass 的最新 API 细节与真机渲染坑、iPhone→macOS 布局适配的具体交互语义转换范例、以及"客户现场 5 分钟炸场"级的桌面级视觉/动效参考——这些 SKILL 给的是原则和 guardrail，缺具体的高保真视觉样例与 macOS 26 版本坑清单。

## Findings

### 07.1 Agent Platform Plugin References（本地软链索引）

- **声称**: 本地 Codex build-macos-apps 插件 v0.1.4 已软链进仓，含 11 个 skill，UI 方法论相关的 5 个（swiftui-patterns/liquid-glass/window-management/view-refactor/appkit-interop）都带完整 SKILL.md，是现成的 macOS UI 开发方法论资产
- **来源**: <Tools/agent-platform-plugin-refs/README.md:1> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 符号目标 /Users/wanglei/.codex/plugins/cache/openai-curated-remote/build-macos-apps/0.1.4/skills；插件明确『不覆盖 pixel-perfect visual design / design-system generation』（plugin README『What It Does Not Cover』），此为外部调研缺口指向

### 07.2 swiftui-patterns SKILL.md（State Ownership Summary + Anti-Patterns）

- **声称**: swiftui-patterns SKILL 给出完整的 macOS 场景模型选型（WindowGroup/Window/Settings/MenuBarExtra/DocumentGroup）、状态所有权矩阵（@State/@Binding/@SceneStorage/@AppStorage/@Environment 8 行表）、新 App 文件拆分规范（App/Views/Models/Stores/Services/Support），以及一批 anti-pattern（禁巨型 ContentView、禁硬编白底、禁 iOS 触摸模型直搬桌面）
- **来源**: <Tools/agent-platform-plugin-refs/build-macos-apps-skills/swiftui-patterns/SKILL.md:78> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: references 目录含 components-index/windowing/settings/commands-menus/split-inspectors/menu-bar-extra 六篇细则

### 07.3 liquid-glass SKILL.md（Custom Liquid Glass + Guardrails）

- **声称**: liquid-glass SKILL 给出系统玻璃优先方法论：先用标准结构/工具栏/搜索/控件，只在系统控件覆盖不到处加 glassEffect；相邻自定义玻璃必须共用一个 GlassEffectContainer（视觉正确性硬规则，非仅组织）；tint 只承载语义不做装饰；含完整 Review Checklist 与 Guardrails
- **来源**: <Tools/agent-platform-plugin-refs/build-macos-apps-skills/liquid-glass/SKILL.md:248> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 该 skill 无 references 子目录，正文即全部；API 提及 glassEffectID/@Namespace морph、ToolbarSpacer、sharedBackgroundVisibility、backgroundExtensionEffect、containerConcentric 等 macOS 15+/26 API

### 07.4 window-management SKILL.md（These APIs are macOS 15+）

- **声称**: window-management SKILL 覆盖窗口 chrome 定制（toolbar removing:.title、toolbarBackgroundVisibility）、拖拽区补偿（隐藏 toolbar 后必用 WindowDragGesture + allowsWindowActivationEvents）、材质背景、restoration/minimize 行为、default/ideal placement（用 sizeThatFits + visibleRect）、borderless 窗口——明确标注这些是 macOS 15+ SwiftUI API，旧目标要 AppKit 兜底
- **来源**: <Tools/agent-platform-plugin-refs/build-macos-apps-skills/window-management/SKILL.md:330> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: references/api-snippets.md 提供具体窗口 modifier 示例；对 demo 单窗全屏演示场景直接可用

### 07.5 appkit-interop SKILL.md（Choose The Smallest Bridge）

- **声称**: view-refactor 与 appkit-interop 两 skill 补齐工程化方法论：view-refactor 给文件顶到底排序约定、按职责拆文件、稳定 selection/layout、把命令/工具栏逻辑移出 body；appkit-interop 给『选最小桥接』阶梯（纯SwiftUI→NSViewRepresentable→NSViewControllerRepresentable→直接 NSWindow/responder），并要求 SwiftUI 保持 source of truth
- **来源**: <Tools/agent-platform-plugin-refs/build-macos-apps-skills/appkit-interop/SKILL.md:606> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: appkit-interop references：representables/window-panels/responder-menus/drag-drop-pasteboard 四篇

### 07.6 UIUE Grill 全清单统计（导航索引）

- **声称**: 项目自身已沉淀 ≈240+ 条 UIUE grill 决策，SSOT=grill-decisions-master.md，导航索引在 UIUE-checklist.md；U1-U31 收口于 :207-222、V1-V12 视觉块、D1-D7 深度 grill、E 系列 orb、SD1-25 用户故事台本——这不是零起点，Line D 承接不重拍
- **来源**: <docs/UIUE-checklist.md:1> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: tokens.md 已落 7 态色映射与 V 系列间距/字体/圆角；一手 SSOT=docs/grill-tournament/uiue-d1-d6-grill.md + 盲评 final-list.md

### 07.7 roadmap v4 Line D scope 两半表（D-UI/D-RT）

- **声称**: 已锁约束：现有 UIUE（链路 A 7 态视觉已并 main，2026-06-24 PR #5）需从 iPhone 布局适配到 macOS 主演示面（Q2=C：iOS 冻结）；Mac 布局已决 U14『用 AnyLayout 不用 SplitView』、触摸→点击/悬停语义转换；触觉 U16『macOS 永远 .none，不做真机触觉验收门』
- **来源**: <docs/roadmap-2026-07-07-macos-closure-baseline.md:84> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: U14/U16 一手见 grill-decisions-master.md :207-222；U15『HTML+Preview 补 4 类反例』是视觉验收方法之一

### 07.8 D-121 任务④立项 + 主刀铁律

- **声称**: 已锁主刀铁律（D-121 立项，2026-07-08）：UIUE 开发=commander(Fable)/Claude 亲自主刀 + 精 grill + 视觉验收门（aesthetic-first 5 Gate + 还原用户实查环境），codex 只做机械接线/测试位——依据磊哥『codex 开发前端很 low，之前 iOS 不满意，macos uiue 好好干』
- **来源**: <docs/commander-log/decisions.md:1096> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: memory key=feedback-uiue-no-codex；决策记录为准。aesthetic-first 5 Gate 在本地 ~/.claude/rules 未找到独立文件，可能在 memory/skill 中，是需确认的引用悬空点

### 07.9 Line D 验收维度清单（v4 audit P1-1）

- **声称**: 已锁 Line D 验收维度：七态视觉消费（DemoVisualState 7 态各自正面渲染，四态分色 clarify琥珀≠unsupported灰≠safety红≠crash灰，现役债 ContentView:122/:126 二值压缩待补）+ 视觉门（U17 snapshot+黄金路径 XCUITest 衔接 U32-U37）+ voice/TTS preflight（AVSpeechSynthesizer 硬门内，U28 高级中文 voice DEFERRED）+ runtime/readback
- **来源**: <docs/roadmap-2026-07-07-macos-closure-baseline.md:87> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: D7 头号待补债：ContentView 仍 satisfied?green:gray 二值，A2 不碰视觉，UIUE 链路 A 补全 7 态穷尽 switch（grill-master D7 晶体表）

### 07.10 UIUE 用户故事演绎台本 grill 决策（SD1/SD2 等）

- **声称**: 已锁 SD 台本级决策：开场默认 idle 全景态（非每次 boot reveal）、Theme 默认 .ivory 米白 + light/dark 跟随系统、push-to-talk 按住录音 + iOS SFSpeechRecognizer 端侧转文字（后端只接文本不解析音频）、Grid 非 LazyVGrid、matchedGeometry gated 过渡、双通道降级（关键态靠颜色/数值/图标承载，动画只锦上添花）
- **来源**: <docs/uiue-storyboard-grill-decisions.md:14> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: D6『稳>炸』升为横切；C30 稳定优先（低电量/ReduceMotion 双通道）；glassEffect 三处 inventory=MicDock/ContextCapsule/DemoControlPanel（U44 hardening spike）

### 07.11 U44 无投屏 Liquid Glass hardening spike

- **声称**: 外部调研缺口一：本地 SKILL 只给 Liquid Glass 的原则/API 名与 guardrail，缺 macOS 26 Tahoe 具体版本坑清单（Reduce Transparency/低亮/对比度/iOS26.x 渲染差异）与真机渲染样例——U44 已立『无投屏 Liquid Glass hardening spike』正指向此缺口，需外部补 macOS 26 版本级实证
- **来源**: <docs/grill-tournament/grill-decisions-master.md:202> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: plugin README 明示不覆盖 pixel-perfect visual design；需外部补高保真视觉样例 + macOS 26 API 细节/坑

### 07.12 Line D 推进式 D1 UIUE 专场（commander 亲笔高投入窗口）

- **声称**: 外部调研缺口二：SKILL 强调『别把 iOS 触摸模型直搬桌面』但只给原则，缺 iPhone→macOS 布局适配的具体交互语义转换范例（触摸→点击/悬停/右键/键盘）与桌面级『5 分钟现场炸场』的动效/视觉参考样例；这是 Line D D1 UIUE 专场高投入窗口最需要外部弹药的点
- **来源**: <docs/roadmap-2026-07-07-macos-closure-baseline.md:99> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: aesthetic-first 5 Gate 的具体门内容在仓内未见独立成文（~/.claude/rules 无命中），建议外部调研同时明确其 5 门定义或另立

## 引用核验

本路为本地文件盘点(file:line 引用),未设联网核验员;核验方式=文件路径可直接打开复核。

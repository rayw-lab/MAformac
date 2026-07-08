# lens03 — 设计流程方法论:design system / Figma handoff / 原型迭代 / 流程裁剪

> 一手结构化 finder 档 | workflow `wf_41662345-ab4` agent `acc6ec755e5b49df9` | 2026-07-08 | opus/medium
> 角度原文: 设计流程方法论——design system 从零构建、Figma→SwiftUI handoff、低保真→高保真迭代、双钻/design sprint 在桌面端与 solo 小团队的裁剪应用

## 摘要

对于 MAformac 这种 solo/小团队、纯端侧 macOS SwiftUI 演示助手,主流方法论可以大幅裁剪但有几条不能省。第一,design system 从零建的公认序是"先盘存 UI 现状 → 定基础层(色/字/间距 tokens) → 再搭 pattern 库 → 最后集中沉淀文档",且必须增量式一个 pattern 一个 pattern 建,没有"完成态"只有迭代。第二,token 化是 SSOT 的关键:业界普遍用 global/alias/component 三层语义命名;落到 SwiftUI 的成熟做法是用 enum + Asset Catalog 承载颜色(自动接管明暗/无障碍)、把主题经 environment 注入,配合 Xcode Preview 做即时验证——这对 solo 尤其高效。第三,Figma→SwiftUI handoff 有两条路:AI 生成(Visily/Builder Visual Copilot/Trace/Codia)只解决约 10–20% 的布局搭建,状态/导航/无障碍/产品决策仍归开发者;Auto Layout 是决定导入质量的"单一最关键动作";Figma Code Connect 用 @FigmaString 等属性包装器把真实 SwiftUI 组件挂到 Figma 组件,在 Dev Mode 显示活代码。第四,越来越多人主张 solo 直接在 SwiftUI 里做可交互原型(接假数据、上真机/TestFlight 测),跳过 Figma 中间层,因为复杂交互(横向滚动列表等)在代码里几行就能真实验证。第五,过程框架都要裁:低保真→高保真的转场信号是"你能明确说出正在测的问题、且该问题需要更高保真才能答";双钻对 solo 可压到几天但 Discover/Define 不能整段砍;design sprint 单人可压到 3–4 天,但"不做原型+测试就不叫 sprint"。最后,Liquid Glass(macOS 26 Tahoe)时代的设计准则强调 hierarchy/harmony/consistency 三原则、材质要"服务内容而非遮蔽内容",叠加 Nielsen 十大启发式这类长期原则,构成演示 App 视觉与可用性的底盘。

## Findings

### 03.1 Build A Design System from Scratch in 7 Steps | UXPin

- **声称**: Design system 从零构建的标准 7 步序:①盘存现有 UI(审计所有颜色/字体/图标/模式并记录不一致)②争取团队认同 ③定色板(主/次/文本/链接/按钮/背景,附精确 HEX/RGBA/HSL 与用法)④定排版(字号/字重/行高/间距及使用规则)⑤汇总图形资产 ⑥建 pattern 库(带代码片段与文档)⑦集中沉淀到一个平台便于原型与 handoff。基础层(色/字/间距)先于 pattern 库。
- **来源**: <https://www.uxpin.com/studio/blog/build-a-design-system-from-scratch-in-7-steps/> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 已 WebFetch 逐条核验。适配 solo:第②步团队认同可省,其余序保留。

### 03.2 Design Systems: Step-by-Step Guide to Creating Your Own | UXPin

- **声称**: design system 是迭代物不是一次性交付——'没有完成的设计系统,只有不断迭代';pattern 库应先定最佳架构再一个一个建,不要一次搭全部。业界普遍报告用 design system 后交付更快、设计类 bug 显著减少(约快 34%、bug 减约 47%),某项目文档化耗时约 3.5 个月(1.5 月全职+2 月半投入)。
- **来源**: <https://www.uxpin.com/create-design-system-guide/> (仅搜索摘要, 采集日 2026-07-08)
- **备注**: 34%/47%/3.5月为搜索摘要聚合数字,未逐页核验,决策慎用;'增量一个一个建、无完成态'为多源一致的定性结论,可信度高。

### 03.3 What Are Design Tokens? A Complete Guide (2026) | UXPin

- **声称**: Design token 业界三层结构:①Global tokens=原始值(hex 色值、像素尺寸)②Alias/semantic tokens=语义引用(如 color-primary 指向 global)③Component tokens=组件作用域(如 button-background-color 指向 alias)。token 是'命名的语义值,表达意图而非实现',是设计系统的单一事实源。
- **来源**: <https://www.uxpin.com/studio/blog/what-are-design-tokens/> (仅搜索摘要, 采集日 2026-07-08)
- **备注**: 搜索摘要确认三层命名(global/alias/component);MAformac 若做 tokens 建议至少 global+semantic 两层即可,component 层 solo 可缓。

### 03.4 SwiftUI Design Tokens & Theming System (Production-Scale) - DEV Community

- **声称**: SwiftUI 落地 design token 的生产级做法:分 7 类(spacing/radius/typography/colors/elevation/animation/opacity),用 enum 承载(禁止直接写 Color.blue,改 enum AppColor { static let background = Color("Background") } 交给 Asset Catalog 自动处理明暗与无障碍),主题用 .environment(\.theme, currentTheme) 注入,配合 Xcode Preview 做即时设计验证。spacing 示例 xs4/sm8/md16/lg24/xl32,radius sm6/md12/lg20/card16,animation fast0.15/standard0.25/slow0.45s。
- **来源**: <https://dev.to/sebastienlato/swiftui-design-tokens-theming-system-production-scale-b16> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 已 WebFetch;enum+Asset Catalog+environment 注入+Preview 验证这套对 solo 极高效,直接可套用到 MAformac 的卡片亮暗态。

### 03.5 Connecting SwiftUI components | Figma Developer Docs

- **声称**: Figma Code Connect for SwiftUI 把真实 SwiftUI 组件与 Figma 组件双向绑定:在 Package.swift 加依赖,用属性包装器映射设计属性(@FigmaString 文本、@FigmaBoolean 开关、@FigmaEnum 变体、@FigmaInstance 嵌套、@FigmaChildren 子层),变体用 let variant=["Type":"Primary"] 分派,figmaApply/elseApply 按状态加修饰符;连好后 Dev Mode 自动显示随属性变化的活代码,连接 struct 可直接当 Preview 用。
- **来源**: <https://developers.figma.com/docs/code-connect/swiftui/> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 已 WebFetch;这是'代码是真实源、Figma 显示真实代码'的反向 handoff,适合已有 SwiftUI 组件库时保持设计-代码一致。

### 03.6 Figma to SwiftUI | Builder.io

- **声称**: Figma→SwiftUI 的 AI 生成 handoff(Builder Visual Copilot):流程=开插件→选层预览→Generate code→拷进 Xcode→按 iOS 细化;'启用 Figma Auto Layout 把元素组织成响应式层级是保证顺畅导入的单一最关键动作',另有 6 条:显式导出图片、合并背景层、减少重叠、避免半透明效果、文本框贴合、用真实设计尺寸。AI 用多阶段(200 万+数据点模型转层级→Mitosis 编译器→微调 LLM 精炼框架代码)。
- **来源**: <https://www.builder.io/blog/figma-to-swiftui> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 已 WebFetch;'Auto Layout 是导入质量单一最关键动作'是可执行的强约束。同类工具还有 Trace、Codia AI(搜索见到)。

### 03.7 Figma to SwiftUI: 7 Tools Compared (2026)

- **声称**: Figma→SwiftUI 转换工具只加速了'布局搭建'这一步(约占 App 开发 10–20%);状态管理、导航、网络、持久化、变现、无障碍、App Review 合规、产品决策仍全部留在开发者手里。因此 handoff 工具是脚手架不是省略开发。
- **来源**: <https://theswiftk.it.com/blog/figma-to-swiftui-tools-compared-2026> (仅搜索摘要, 采集日 2026-07-08)
- **备注**: 搜索摘要确认;对 MAformac 的意义:别指望 Figma 生成可省掉 SwiftUI 逻辑,原型价值在交互与状态而非静态布局。

### 03.8 Prototyping with SwiftUI - Mike Barker

- **声称**: solo 开发者可跳过 Figma 中间层、直接用 SwiftUI 做可交互原型:用 List/Sheet 等容器搭 UI、灌假数据、部署真机/TestFlight 做真实可用性测试。理由是复杂交互(如横向滚动列表在 InVision 里测不出来)在 SwiftUI 里'几行代码'就能真实验证;比 Storyboard 复杂度低得多,设计者也能贡献前端布局。代价:SwiftUI 仍有能力空缺、原型规模化后会变大变复杂、有学习曲线。
- **来源**: <https://www.mike-barker.com/writing/swiftui-design-prototype> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 已 WebFetch;高度契合 MAformac(solo+SwiftUI 一套+要现场演真交互)——建议高保真阶段直接在代码里迭代而非 Figma 走查。Design+Code、Judo 亦持类似'代码即原型'立场。

### 03.9 Low Fidelity vs. High Fidelity Prototypes | Miro

- **声称**: 低保真→高保真的转场判据:'当你能清晰说出正在测什么问题、且该问题需要更高保真才能回答时,才升保真;在此之前保持低保真快速迭代'。策略序=低保真验概念→中保真解结构问题→高保真定稿并备 handoff;可在流程中途改某个 artifact 只重跑下游步骤而不推倒重来,以此快迭代不丢上下文。
- **来源**: <https://miro.com/prototyping/low-fidelity-vs-high-fidelity-prototypes/> (仅搜索摘要, 采集日 2026-07-08)
- **备注**: 搜索摘要确认;可作 MAformac 卡片/演示界面的保真升级门槛,避免过早打磨视觉。

### 03.10 Understanding the Double Diamond design process | Dovetail

- **声称**: Double Diamond 可裁给 solo/小团队:框架是参考不是死板照搬,已被用于几天的单人项目到 3–6 个月的小团队项目;资源受限时可做'轻量 Discover/Define'——限定而非整段跳过发现期,几天有针对性的证据能避免几个月做错东西;定明确的决策日期和可测指标。
- **来源**: <https://dovetail.com/product-development/what-is-the-double-diamond-design-process/> (仅搜索摘要, 采集日 2026-07-08)
- **备注**: 搜索摘要确认;对 MAformac 的裁剪启示:发现期不砍到 0,但可压到几天并锁死决策日。

### 03.11 1-Day, 2-Day, and 3-Day Design Sprints. Do they work? | Voltage Control

- **声称**: design sprint 的压缩规则:单人 sprint 可行,因缺少集体脑暴/团队讨论,5 天常可压到 3–4 天;但更短 sprint 有风险——'不做原型+测试就不叫 Design Sprint',3 天版仅适合高成熟度团队(Jake Knapp 本人也说'三天极其硬核,我自己不会报名'),压缩常把砍掉的原型/测试挪到会前而实际膨胀到 8+ 天。新手建议先跑完整 5 天再裁。2024 新变体:用 AI(如 Claude)在 Day 4 把手绘方案快速转成可交互原型。
- **来源**: <https://voltagecontrol.com/blog/do-shorter-design-sprints-work/> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 已 WebFetch;核心可迁移原则=可压缩但'原型+测试'环节不能砍。AI 转原型这条直接对应 MAformac 用 Claude/SwiftUI 快速出可演版本。

### 03.12 Liquid Glass: Redefining design through Hierarchy, Harmony and Consistency | Create with Swift

- **声称**: Liquid Glass(macOS 26 Tahoe / WWDC25 起)采用设计三原则:Hierarchy(控件与界面元素抬升并区分其下内容,靠间距/尺寸/自适应行为引导而非只靠颜色特效)、Harmony(对齐硬件与软件的同心/concentric 几何)、Consistency(遵循平台约定并随窗口尺寸持续自适应);材质要'服务功能'(示深度/反馈/上下文变化)而非装饰,应选'凸显内容而非遮蔽内容'的玻璃材质;组件不再是固定容器而是流的一部分。
- **来源**: <https://www.createwithswift.com/liquid-glass-redefining-design-through-hierarchy-harmony-and-consistency/> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 已 WebFetch;直接约束 MAformac macOS 演示界面的视觉语言——克制用玻璃、内容优先。Apple 已随 WWDC25 更新 SwiftUI/UIKit/AppKit 的 Liquid Glass API 与设计资源。

### 03.13 10 Usability Heuristics for User Interface Design | Nielsen Norman Group

- **声称**: Nielsen 十大可用性启发式(1994 发布,2024-01-30 最近更新)仍是通用评估底盘:①系统状态可见 ②系统贴合现实 ③用户控制与自由(明确的撤销/退出)④一致性与标准 ⑤错误预防 ⑥识别优于回忆 ⑦灵活与高效(快捷方式)⑧美学与极简 ⑨帮助用户识别/诊断/恢复错误 ⑩帮助与文档。
- **来源**: <https://www.nngroup.com/articles/ten-usability-heuristics/> (已实访(WebFetch), 采集日 2026-07-08)
- **备注**: 已 WebFetch;经典长期原则(非 2024-26 新料但 2024 已更新)。对 5 分钟炸场演示尤其相关的是①状态可见(反应快看得见)与⑧极简、⑨错误恢复(不崩/优雅兜底)。

## 引用核验(独立核验员)

> agent `a17dc8eedfdc3b1fe` | verdict: **MINOR_ISSUES**

- ✅ <https://www.uxpin.com/studio/blog/build-a-design-system-from-scratch-in-7-steps/> — 可达。7 步序完全吻合:①盘存/审计现有 UI 记录不一致 ②团队认同 ③色板附 HEX/RGBA/HSL ④排版(字号/字重/行高/间距规则)⑤图形资产(含代码片段)⑥pattern 库(代码片段+文档)⑦集中平台便于原型与 handoff。唯一细微:页面按顺序呈现(色/字/资产在 pattern 库之前),但未显式声明『基础层必须先于 pattern 库』的依赖关系,声称中的『先于』属合理引申而非页面明文。
- ✅ <https://www.uxpin.com/create-design-system-guide/> — 可达。核心论点吻合:『design system 是持续迭代不是一次性交付/项目』有明文支持;『pattern 库先定架构再一个一个建』亦有明文。但声称中的三个精确统计——约快 34%、bug 减约 47%、文档化约 3.5 个月(1.5 月全职+2 月半投入)——在抓取到的页面内容中均未出现,无法证实,疑为外部引入或编造的具体数字,应视为未获支持。
- ✅ <https://www.uxpin.com/studio/blog/what-are-design-tokens/> — 可达。三层结构完全吻合:global(原始值如 color.blue.500=#0057FF)/ alias-semantic(如 color.brand.primary 引用 global)/ component(如 button.background.default 引用 alias)。『命名的语义值表达意图而非实现』『单一事实源(改一处全平台更新)』均有明文。
- ✅ <https://dev.to/sebastienlato/swiftui-design-tokens-theming-system-production-scale-b16> — 可达。主体吻合:enum 承载 token(enum AppColor + Asset Catalog 处理明暗/无障碍,不直接写 Color.blue)、.environment(\.theme, currentTheme) 注入、Xcode Preview 验证均有明文;spacing xs4/sm8/md16/lg24/xl32、radius sm6/md12/lg20/card16、animation fast0.15/standard0.25/slow0.45s 具体值全部对上。细微:文章显式核心类别约 5 类(spacing/radius/typography/colors/elevation),animation 与 opacity 有涉及但未被完整列为独立 token 类别,声称的『7 类』略有拔高,不影响主旨。

**dead_or_fabricated(引用时必须剔除):**

- 🔴 www.uxpin.com/create-design-system-guide/ 中的三个精确统计(约快 34%、bug 减约 47%、文档化约 3.5 个月=1.5 月全职+2 月半投入)在页面内容中查无出处,未获支持,疑为编造或错植;URL 本身可达且其余论点成立

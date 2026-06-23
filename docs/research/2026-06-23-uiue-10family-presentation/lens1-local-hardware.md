# Lens: 本地适配 / 硬约束 — 10 族车控在 Mac/iPhone 各能怎么排

> 调研日期 2026-06-23 | 本机 scout 坐实 + 12 路 WebSearch + gh 热度核 | focus = **怎么展示 10 族（信息架构 + 物理排布约束）**，不调配色

## summary

本机实况是这个 lens 的**头号一手约束，且推翻了若干默认假设**：当前演示主屏 = **外接 Philips 272S9 @ 1920×1080 非 Retina（不是 MacBook Retina）**，M5/32GB/Metal 4 算力远超 10-30 张辉光卡所需（性能不是瓶颈，**1080p 物理像素 + 投屏 8bit banding 才是**）。10 族信息架构的根本约束不是"卡片画不下"，而是 **(a) 投屏暗底大渐变会 banding + 字小看不清**（claim-vs-reality 验收红线）、**(b) 191 device × 异构值形态塞进一屏会信息过载**、**(c) 辉光=offscreen render，10 张同屏 breathe 动画在滚动/动画下会叠加 GPU 成本**。结论框定：**Mac 横屏 = 10 族 5×2 或 4×3 自适应网格常驻（A 方案：全景常驻 + 触发聚焦）；iPhone 竖屏 = 2 列 × 滚动 + 当前活跃族置顶**。族级卡（U13 family_card_id，10 张）是对的粒度，191 device 绝不平铺。

## findings（逐条带 source）

### F1 🔴 本机主屏 = 1920×1080 非 Retina 外接屏（不是 MacBook Retina），这是演示真实查看环境
本机 scout：`system_profiler SPDisplaysDataType` → 唯一 Main Display = `PHL 272S9 / Resolution 1920×1080 (1080p FHD) / UI Looks like 1920×1080 @75Hz`，**无 Built-In Retina 出现在 attached display 列表**（MacBook 在外接屏模式）。含义：① 演示画布只有 **1920×1080 逻辑像素 @1x**（非 Retina @2x 的 3840×2160 等效）→ 字号/线宽/glow 半径要按 1x 物理像素设计，Retina 上"清晰"的细字在这块屏会糊；② 投影仪/会议室大屏多半也是 1080p → 双重 1x。
- source: 本机 `system_profiler SPDisplaysDataType`（2026-06-23 实跑）

### F2 🔴 prototype 自己写明演示场景 = "iPhone 竖屏，投屏给会议室"，但 U1 拍 Mac 主——两者要分别排
`ui-concepts-3-schemes.html` 副标题原文：「iPhone 竖屏, 投屏给会议室。目标: 一眼碾压 AWS 那个扁平 Android 灰卡片」。U1（grill §3:115）拍 `primary_device=mac + iphone_role=bonus`。→ **两套布局都要出**：Mac 横屏（主舞台，可全景常驻）+ iPhone 竖屏（投屏/手持，必滚动）。
- source: `prototypes/ui-concepts-3-schemes.html`（副标题）+ `docs/grill-tournament/grill-decisions-master.md:115`（U1）

### F3 🔴 投屏 8-bit 暗底大渐变 = banding 高危，深空辉光方向天然踩坑（验收红线）
8 bit = 256 阶/通道，**暗色调可用阶最少**，大面积暗渐变拉过宽屏 → 可见色阶台阶（posterization）；"在亮处看 OK 的暗渐变，在暗房投影 + 亮度调高会崩"；投影仪 dynamic contrast 等后处理放大 banding。修法：① 暗底**别铺满大面积低对比渐变**（与 U11 halation 约束同向：base 用 `#0a0b12` 非纯黑，cyan 散光占屏 30-60% 别铺满）② 加**极细 dither/noise** 打散色阶 ③ 关键说明用**高对比 + 大字**承载，不靠渐变细微差。**对应 aesthetic-first 验收纪律：必还原投屏实查环境，不看自己导出的高清图。**
- source: [willgibbons.com/color-banding](https://www.willgibbons.com/color-banding)（2025）+ [son-video.com 4K TVs projectors banding](https://blog.son-video.com/en/2021/03/4k-tvs-and-projectors-what-is-color-banding-posterization-or-solarization/) + tokens.md U11 halation 约束

### F4 演示字号物理下限：1080p 投屏 body ≥24pt、标题 ≥44pt（8H 规则 / Extron 1英寸/15英尺）
通用最小 24pt body；大厅 28-34pt body + 44pt+ 标题；8H 规则 = 文字 ≥屏高 1/50；Extron videowall = 每 15 英尺观看距离文字高 ≥1 英寸（30 英尺→58pt）。**这些是 PPT pt，映射到 SwiftUI**：在 1080p @1x 上，族卡标题/数值要按"会议室后排可读"放大——现状 `font.card.val 15px`（scheme1）**远低于演示下限**，纯前端 mock 可以，真投屏 demo 必放大族卡数值到 ≥28-36pt 等效。
- source: [presentationguild.org 8H Rule](https://presentationguild.org/how-big-big-enough-the-8h-rule-reveals-all/) + [Extron videowall font size](https://www.extron.com/article/videowallfontsize) + tokens.md `font.card.val`

### F5 iPhone 15 Pro 物理画布：393×852 pt，竖屏安全区可用高 759pt（顶 59 + 底 34 被吃）
iPhone 15 Pro = 393×852 pt @3x，竖屏安全区 top 59 / bottom 34 → 可用高 **759pt**。三屏分层（语音 orb 顶 / 对话流中 / 车控卡下）要在 759pt 里分配：orb+顶栏 ~120pt、对话流 ~200pt、mic ~80pt → 车控卡区只剩 **~360pt**。结论：**iPhone 竖屏一屏放不下 10 族**（10 族 2 列需 5 行，每行 ≥72pt = 360pt 刚好但无呼吸空间）→ 必**滚动 + 活跃族置顶 / 浮现**，不强求常驻全 10 族。
- source: [useyourloaf.com iPhone 15 screen sizes](https://useyourloaf.com/blog/iphone-15-screen-sizes/) + [yesviz iphone-15-pro](https://yesviz.com/devices/iphone-15-pro/)

### F6 Mac 横屏自适应网格用 `.adaptive`，10 族 5×2 / 4×3 自动 reflow，是官方推荐
`GridItem(.adaptive(minimum:))` 让网格按窗口宽自动塞最多列，"macOS 用 .adaptive 支持窗口缩放 = 顶级原生体验"。10 族在 1920 宽横屏 = 5 列×2 行（每卡 ~340pt 宽，舒展）或窗口缩小自动降 4 列×3 行。**现状 ContentView 已用 `LazyVGrid(.adaptive(minimum:160))`** 但 minimum 160 太小 + 喂的是 22 个 device 平铺（不是 10 族）→ 改喂 10 族 family card + minimum 调到 ~300（Mac）/ ~170（iPhone）。
- source: [avanderlee.com grid-lazyvgrid](https://www.avanderlee.com/swiftui/grid-lazyvgrid-lazyhgrid-gridviews/)（"macOS use .adaptive whenever possible"）+ `App/ContentView.swift:40`

### F7 10 族这种固定小集合：`Grid`（非 Lazy）反而更优，Lazy 是大列表才需要
官方/社区共识："Grid 用于静态行列、性能没问题时；性能成瓶颈才升 LazyVGrid"。**10 族 = 固定 10 张，不滚动（Mac 横屏）→ 用 iOS16+ `Grid` 静态容器更合适**（精确行列对齐 + 不需 lazy 的复杂度）；只有 iPhone 竖屏需滚动时才 `LazyVGrid` 包 `ScrollView`。注意 ScrollView 默认 `clipsToBounds=true` 会**裁掉卡片 glow 溢出** → 需 `.scrollClipDisabled()`（iOS17+），但会增渲染区。
- source: [appmakers.dev grids-in-swiftui](https://appmakers.dev/grids-in-swiftui/) + [fatbobman ScrollView clipping](https://fatbobman.com/en/snippet/preventing-scrollview-content-clipping-in-swiftui/)

### F8 辉光 = shadow/blur = offscreen render 昂贵，10 张同屏 breathe 动画会叠加 GPU 成本
`.shadow/.blur/.opacity/.mask` 触发 offscreen render（第二渲染 pass）；"滚动列表里多个 shadow/blur 成本复合"；glow 本质=shadow/blur 同成本。10 张 `motion.breathe`（box-shadow 呼吸 3.4s infinite）同屏 = 10 个持续动画 offscreen pass。修法：① 静态 glow 给 explicit shadow path ② 用 `drawingGroup()`（Metal 合成）但它自身加一个 pass，仅在真瓶颈用 ③ **不是所有 10 卡都同时 breathe，只激活态卡呼吸**（normal 态静默，省 9/10 动画）。**M5 算力够，但仍要遵守"只激活卡动"省成本 + ReduceMotion/低电量双通道**（tiger）。
- source: [medium 24 SwiftUI Performance Tips 2025](https://medium.com/@ravisolankice12/24-swiftui-performance-tips-every-ios-developer-should-know-2025-edition-723340d9bd79) + [hackingwithswift drawingGroup](https://www.hackingwithswift.com/books/ios-swiftui/enabling-high-performance-metal-rendering-with-drawinggroup) + tokens.md `motion.breathe`

### F9 M5/Metal 4 GPU 算力充裕，性能不是 10 族布局的约束
M5 GPU 比 M4 快 30%、比 M1 快 2.5×，Metal 4，base M5 Metal Geekbench 76727。**渲染 10-30 张 SwiftUI glow 卡 @1080p 对 M5 是零压力**——瓶颈在显示侧（1080p 物理像素 + 投屏 banding + 字号），不在算力侧。含义：**别因"性能"砍掉辉光/动效**，该砍的理由是 banding/可读性/ReduceMotion，不是 GPU。
- source: [apple.com M5 newsroom](https://www.apple.com/newsroom/2025/10/apple-unleashes-m5-the-next-big-leap-in-ai-performance-for-apple-silicon/) + [notebookcheck M5 GPU](https://www.notebookcheck.net/Apple-M5-GPU-Benchmarks-and-Specs.1139076.0.html) + 本机 `system_profiler`（Apple M5 / 10 GPU cores / Metal 4）

### F10 异构值形态（温度连续/档位/RGB色/开度/座椅多维）塞进族卡 = 信息密度物理约束
10 族下值形态异构：温度 18-32℃ 连续 / 风量 1-10 档 / RGB 氛围灯色 / 车窗 0-100% / 座椅 加热×通风×按摩 多维 / 香氛浓度。**族卡空间有限（Mac ~340pt 宽 / iPhone ~170pt 宽），放不下完整 slider+stepper+color picker**。修法：族卡只显**当前态摘要**（大数值 + 图标 + 状态），细控件（CompactSlider/Stepper/色板）在**触发聚焦/展开态**才出（A 方案核心）。座椅多维 = 卡内三个小图标点阵（加热🔥/通风/按摩各一状态点），不放三个 slider。
- source: [github buh/CompactSlider](https://github.com/buh/CompactSlider) + [createwithswift forms sliders steppers](https://www.createwithswift.com/mastering-forms-in-swiftui-sliders-and-steppers/) + DemoVehicleStateStore.swift（191 device 异构 key）

### F11 车机标杆（Polestar 4）= 横屏 1920×1200 + 气候控制常驻底部 strip，验证"族级常驻 + 细控展开"
Polestar 4 中控 = 15.4" 横屏 1920×1200，主页直达 car/nav/media/call，**气候控制在永久底部 strip**，点 fan 图标才进细设置。这印证 A 方案：**高频族常驻（strip/网格）+ 细控件按需展开**。也佐证横屏 1920 宽是车机原生比例（本机 1080p 横屏接近）。反例：Polestar 4 把出风口方向做成拖箭头被批"开车时蠢"——**demo 别把所有细控塞进小卡逼用户拖**，语音驱动恰好绕开这个坑。
- source: [polestar.com/us/polestar-4/infotainment](https://www.polestar.com/us/polestar-4/infotainment/) + [topgear polestar 4 interior](https://www.topgear.com/car-reviews/polestar/4/interior)

### F12 卡片浮现/聚焦动效用 matchedGeometryEffect + asymmetric transition，是语音驱动的最优范式
语音驱动 demo（方案经理说话→卡片响应，非手指浏览）→ 卡片**插入/聚焦/联动**动画是 wow 核心。`matchedGeometryEffect` 做族卡→展开态 hero 放大（SwiftUI 自动插值，无需手算 frame）；`.transition(.asymmetric(insertion:.scale.combined(with:.opacity), removal:.move(edge:.bottom)...))` 做卡片浮现/退场。**对应 B 方案（纯动态浮现）的技术底**：说"打开空调"→空调卡 scale+fade 浮现/置顶。多意图连两句→多卡 staggered 联动（delay 错峰）。
- source: [medium matchedGeometryEffect hero 2025](https://medium.com/@bhumibhuva18/animation-masterclass-matchedgeometryeffect-in-real-world-swiftui-apps-1c096356a95e) + [appcoda grid animation iOS26](https://www.appcoda.com/learnswiftui/swiftui-grid-animation.html)

### F13 现状 prototype 只 4-6 卡 2×2，撑不住 10 族——但 ContentView 已有 `.adaptive` 骨架可直接扩
scheme1 = `grid2 {grid-template-columns:1fr 1fr}` 固定 2 列、6 卡（空调/座椅/车窗/风量/氛围灯/音乐）；ui-concepts 三方案分别 2 列/2 列/3 列。`ContentView.swift:40` 已是 `LazyVGrid(.adaptive(minimum:160))` 但喂 22 个 device 平铺。**gap = 信息架构粒度错（平铺 device 而非 10 族），不是布局技术缺**。改：喂 10 族 family card + minimum 调 Mac~300/iPhone~170 + 横竖屏分支即解。
- source: `prototypes/scheme1-deep-space-interactive.html:41,113-120` + `App/ContentView.swift:39-45`

## pre-mortem 三分类

### 🐯 TIGER（明确威胁，带验证清单）
- **投屏 8bit banding 把深空暗底渲成色阶台阶**（F3）。验证：用真投影仪/会议室屏放暗渐变页，暗房 + 亮度调高看色阶；规避 = base `#0a0b12` 非纯黑 + 极细 dither + glow 占屏 30-60% 不铺满 + 关键说明高对比大字。
- **现状字号（族卡值 15px）投屏后排看不清**（F4）。验证：还原 1080p 投屏 + 11-12 英尺外看；族卡数值放大到 ≥28-36pt 等效，标题 ≥44pt 等效。
- **10 张 glow 卡全部 breathe 同屏 = 10 个 offscreen 动画 pass，低端/旧 iPhone 掉帧 + 发热**（F8）。验证：只激活态卡 breathe（normal 静默），ReduceMotion/低电量双通道（颜色/数值/图标承载态，动画只锦上添花）。
- **iPhone 竖屏 759pt 可用高塞不下三屏分层 + 10 族常驻**（F5）。验证：iPhone 车控卡区只 ~360pt → 必滚动 + 活跃族置顶，别强求 10 族常驻全显。

### 🐅 PAPER_TIGER（看似威胁实际可控，给证据）
- **"M5 算力扛不住辉光 10 卡"= 伪威胁**（F9）：M5 比 M4 快 30%/Metal 4，10-30 卡 @1080p 零压力。瓶颈在显示侧不在算力。
- **"LazyVGrid 性能问题"对 10 族 = 伪威胁**（F7）：10 张固定卡用静态 `Grid` 更优，根本不需 lazy 的复杂度；Lazy 是 10000 图才需要。
- **CompactSlider 库 stale = 半弃坑**：实查 550★ 但 pushedAt 2025-11-22（~7 月没动，**FAILS <60 天新鲜度**）。但它逻辑简单（hue slider/stepper ~30 行可自写），demo 不依赖它 = 低风险；细控件优先**自写 SwiftUI 原生 Slider/Stepper**，不引 stale 库。

### 🐘 ELEPHANT（没人提但该提）
- **191 device 绝不平铺，但"族卡点开后 191 怎么展开"无人定**：F10 说细控在展开态出，但某族（如车窗 4 门 × 开度 / 空调 4 区温度）展开后子项也可能 >6 → 展开态自己需二级网格 / 分区 tab。demo 取巧：现场只说 10 族常见子项，展开态只画该族 3-4 个高频子 device（不画全 191）。
- **横竖屏切换/窗口缩放时 10 族 reflow 会重排闪烁**：`.adaptive` 在 5 列↔4 列临界宽度抖动重排，matchedGeometryEffect 可平滑但要同 namespace。demo 锁定窗口尺寸（横屏满屏）规避临界抖动。
- **本机当前是外接 1080p 单屏，MacBook 内屏没在用**：若现场用 MacBook 内屏（Retina @2x）演示，像素密度翻倍，字号/glow 半径要随屏适配（@1x vs @2x 两套）——别只按一块屏调好就以为通用。

## adopt 候选（族卡布局 + 异构值控件，带 file:line/URL）
- **ContentView.swift:39-45 现有 `.adaptive` LazyVGrid 骨架** — 直接改喂 10 族 family card + minimum 调 Mac300/iPhone170 + 横竖屏分支，零新依赖（本机，最优起点）。
- **iOS16+ 原生 `Grid` 容器** — Mac 横屏 10 族固定 5×2 静态网格，比 LazyVGrid 更省（[appmakers.dev grids](https://appmakers.dev/grids-in-swiftui/)）。
- **matchedGeometryEffect + asymmetric transition**（原生）— 族卡聚焦/浮现/多意图联动 hero 动画，无需手算 frame（[medium hero 2025](https://medium.com/@bhumibhuva18/animation-masterclass-matchedgeometryeffect-in-real-world-swiftui-apps-1c096356a95e)）。
- **自写原生 Slider/Stepper/色板**（不引 CompactSlider 550★ 但 stale ~7月）— 展开态细控件，~30 行，离线零依赖。
- **hanlin-ai（CherryHQ）230★ pushedAt 2026-05-31 ~23天 FRESH** — 已 clone 在 ref-repos，VoiceInputView/LoadingGradientText 可抄（UIUE 研究已认证），布局粒度可参考。

## presentation_options（本 lens 对"10 族怎么展示"的具体方案）
见下方 presentation_options 字段。

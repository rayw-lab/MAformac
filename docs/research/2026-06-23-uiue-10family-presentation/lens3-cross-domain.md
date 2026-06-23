## summary

横向扫了 9 个多域控制展示范式(Apple Home / HA Lovelace+Mushroom / iOS18 Control Center / Mi Home / Echo Show / Google Hub Mode / NIO NOMI 车机 / 10-foot TV UI / EV infotainment),回答 MAformac 核心问题:**10 族车控怎么在前端展示**(scheme1 只 4 卡 2×2 撑不住)。最强可迁移结论:① 信息架构用 **bento 不对称网格**(尺寸=优先级,cap 8-12 tile)而非 scheme1 的均等 2×2;② 10 族对应 **family-level 卡片**(已 U13 拍),族内异构 device 用 **Apple Home / Mi Home 的「分组卡 → tap 展开」二级模型**,不是 191 device 全摊平;③ demo 是**语音驱动非手指浏览** → 核心机制是 **spotlight/scrim 聚焦**(被操作族高亮+放大,其余 dim/blur),这正是 10-foot TV UI 的 focus state + HA card-mod 的 state-dependent pulse/glow 的合流;④ 投屏到客户大屏 = **10-foot UI 约束**(本机实测主屏 1080p,字号 ≥24-28px,safe zone 内缩 5%,对比 ≥7:1,而非 web 4.5:1);⑤ 车机一手参照 = **NIO NOMI**(orb 助手 + 按座位定向注意力 + 语音改温度同步屏上视觉响应),与 MAformac「语音 orb 顶 / 对话流中 / 车控卡下」三屏天然同构。

主候选信息架构 = **B' = 全景常驻 bento 网格(10 族 family-card)+ 语音触发 spotlight 聚焦被操作族**(候选 A 与 B 的合体),vs scheme1 静态 4 卡 = better(撑得住 10 族 + 语音驱动天然适配 + 投屏炸场)。

## findings

### 1. Apple Home — 分组卡 + 二级展开 + 两区 tile + section 重排(直接迁移:族内 device 折叠)
- **分组卡模型**:多个 accessory 合并成单 tile,tap 进去展开全部子控制;长按可拆回独立 tile。→ **直接映射 10 族**:每族一张卡(如「座椅」),tap 展开座椅加热×通风×按摩多维 device,不在主视图摊平 191 device。
- **两功能区 tile**:左侧 icon = 快速开关,右侧 name = 进详细控制。→ 族卡可借:左半快开关/右半进调参。
- **section 可重排 + tile 可 resize**(单格/双格/四格)→ bento 不对称的官方背书。
- **category 视图**(Lights/Climate/Security 按房间网格)→ 类比「按族归类」。
- source: https://www.macrumors.com/how-to/reorganize-home-view-home-app/ + https://support.apple.com/guide/iphone/control-accessories-iph0a717a8fd/ios (2026-06 检索)。
- vs scheme1: **better** — scheme1 4 卡均等无层级、无分组、无展开,撑不住 10 族异构。

### 2. HA Lovelace Sections + Mushroom(5033★ pushed 2026-06-12 活)+ layout-card(1244★ 2026-05-09 活)— 响应式网格 + 条件卡 + state-dependent 动效(最强工程参照)
- **Sections 网格(2024 "Grace" 重构)**:固定行高 + 可预测响应式,专为「Masonry 不可预测」痛点而生 → 多屏(Mac/iPhone/投屏)布局可控的工程答案。
- **🔴 conditional card「只在相关时显示」**:官方最佳实践明文「show A/C controls only if A/C is on」。→ **直接迁移 demo**:族外/未触发族可隐藏或弱化,被语音点名族才浮现/高亮 = 候选 B「纯动态浮现」的工程实现。
- **card-mod state-dependent pulse/glow**:CSS 条件动画,设备 on/被控时卡片 pulse。→ **value.type 三分动效 + 被操作高亮的现成模式**。
- **2026.1 mobile-first summary card**:「How warm is it? 不用点开就可见」= 车控卡 at-a-glance 状态原则。
- source: https://www.home-assistant.io/blog/2024/03/04/dashboard-chapter-1/ + https://www.antlatt.com/blog/home-assistant-dashboard-guide/ (2026 guide) + gh heat 实核。
- vs 静态网格: **better** — 条件卡 + 状态动效让网格「活」,正是 demo 炸场要的。

### 3. iOS 18 Control Center — 8×4 模块网格 + resize + 智能家居控件可占 24 格 + 多页(bento resize 官方实证)
- **8×4 圆点网格**,控件可 1/2/4 格,**smart home accessory/scene 控件可 4/8/16/24 格**(最大)→ 苹果官方承认「重要控件占更大空间」= bento「尺寸=优先级」。
- **多页(最多 15 页)+ 自动图标** → 若 10 族一屏挤,可分页(但 demo 倾向单屏全景,见 pre-mortem)。
- **第三方控件可嵌入** → 模块化思路。
- source: https://www.macrumors.com/guide/ios-18-control-center/ (2026-06 检索)。
- vs scheme1: **better** — 给出「同屏内不同族用不同尺寸卡」的官方范式。

### 4. Mi Home HyperOS 2.0(v11.4.702 2026-05-11 活)— card 三尺寸 + 房间 thumbnail + category 批量控制(国产车机审美最近)
- **card 三尺寸(large/medium/small,按 device 类型/偏好)** + 房间优先 thumbnail 卡。
- **device grouping 统一控制** + **category quick control 批量开关灯/窗** → 多意图连续两句(多卡联动)的现成 UX。
- 审美:暖色软调 + 大字 + 曲线面板(可读性优先,与 MAformac 深空辉光暗底是两条路,审美锁不取但「大字可读」可借)。
- source: https://xiaomiforall.com/xiaomi-home-app-redesign-smart-management/ + https://xiaomitime.com/mi-home-app-version-10-released-brings-hyperos-2-0-card-design-17257/ (2026)。
- vs scheme1: **better** — 三尺寸 + 批量控制直接解 10 族 + 多意图。

### 5. Echo Show — 智能家居 dashboard panel + 「奇数时首卡更大」+ widget gallery(语音设备屏一手)
- **smart home dashboard panel**:同屏监控/控制最多 6 个常用 device,tap 直接进相机/开灯,免 swipe 子菜单 → 语音设备「常驻可控面板」范式。
- **🔴「widget 持奇数个 tile 时,第一个更大」** = bento 不对称的具体算法,可借(被操作族放大成 hero tile)。
- Show 15「整屏分区」vs Show 8/10「右上角 6 图标」按屏幕尺寸切布局 → Mac 大屏 vs iPhone 小屏差异化布局的参照。
- source: https://www.amazon.com/gp/help/customer/display.html?nodeId=TEDx6E1KXNZ5oYxH5y + https://www.tomsguide.com/round-up/15-best-alexa-widgets-to-use-on-your-amazon-echo-show (2026)。
- vs scheme1: **better** — 「首卡更大」+ 常驻面板可直接用。

### 6. Google Hub Mode(Pixel Tablet)— docked = home panel + 锁屏 widget + 共享语音(语音设备屏整体形态)
- docked 即进 Hub Mode:home panel 控智能家居 + 「Hey Google」语音 + 照片屏保 + 任何人(含访客)可语音 → 「demo 任何人在场都能说」的形态背书。
- 锁屏 widget(Clock/Timer/Weather)= at-a-glance 信息层。
- ⚠️ [待核] 未搜到 2026「Ambient mode 重命名 / Gemini 全面接管 Hub」,官方仍是「unlocked=Gemini / docked=Assistant」。
- source: https://support.google.com/googlepixeltablet/answer/13560613 (2026-06 检索)。
- vs scheme1: **unknown**(形态层参照,非卡片布局直接迁移)。

### 7. 🔴 NIO NOMI — 车机一手参照:orb 助手 + 按座位定向注意力 + 语音控温同步屏上视觉(MAformac 同构度最高)
- **embodied orb**(2.18" AMOLED 480×480 圆屏动画脸 / 或 Halo 24 LED 环)= MAformac 顶部语音 orb 的车机原型;「NOMI = 车的化身,对它说话=对车说话」。
- **interior sensing 定向注意力**:转向说话的人(主驾/副驾/后排),anticipate 有人要说话时点亮暗屏 → **直接映射 demo「被操作族 spotlight 聚焦」**:语音触发 → 系统知道操作哪族 → 该族高亮+orb 朝向。
- 「语音调温度」同步屏上视觉响应 + ambient 灯 pulse(来电/警告) = **staged/simultaneous 多模反馈**(语音确认 + 卡片状态变 + 灯效)。
- 2026 SAIC-VW 旗舰抄 NOMI → 该范式被验证为车机主流。
- source: https://star.global/cases/nio-nomi/ + https://www.nio.com/blog/our-future-smart-cars-will-be-embodied-digital-assistants + https://eletric-vehicles.com/.../volkswagen-copies-nios-dashboard-assistant... (2026)。
- vs scheme1: **better** — scheme1 有 orb 但无「按操作族定向聚焦」机制,NOMI 给了车机级一手范式。

### 8. Spotlight / Scrim 焦点范式 — 「语音驱动非手指浏览」的核心机制(demo 灵魂)
- **spotlight effect**:dim 背景 + 高亮关键元素,引导注意力,降认知负荷,「一次只聚焦一个」。
- **scrim**(半透明 dim 层,源自摄影遮光)+ **pulsating animation**(节律缩放抓眼不打扰)。
- → **demo 信息架构的关键洞察**:用户不浏览(方案经理说话触发),所以**默认全景常驻 + 语音点名族瞬间 spotlight(放大/高亮/orb 朝向)+ 其余 dim/blur** = 候选 A(全景)与 B(浮现)的最优合体 B'。这把「5min 视觉冲击 > 功能完整」落到具体机制。
- source: https://www.chameleon.io/blog/new-design-patterns-highlighting-elements + https://www.arrivaldesignsystem.com/article/scrims-and-overlays (2026-06 检索)。
- vs scheme1: **better** — scheme1 7 态压绿/灰二值,无聚焦机制,语音控时客户不知道「哪族在变」。

### 9. Bento Grid 2026 标准 — 尺寸=优先级 + cap 8-12 tile + CSS Grid(10 族信息架构骨架)
- **不对称 tile**(hero 6 列 + 周边 2×2)= 「尺寸=空间权重 = 优先级,无需额外标签」。
- **🔴 cap 8-12 tile,>12-15 视觉过载** → **10 族正好在甜区**(不必分页),但每族内 device 必须折叠(否则 191 个就爆)。
- **均等尺寸 = 退化成「圆角传统网格」**(=scheme1 病) → 必须引入尺寸差。
- 响应式优雅塌缩:桌面 3-4 列 / 平板 2 列 / 手机 1 列,**手机按重要性重排非桌面位置**。
- 统一 gutter 12-24px;CSS Grid 非 Flexbox(SwiftUI 对应 LazyVGrid + GridItem)。
- source: https://www.orbix.studio/blogs/bento-grid-dashboard-design-aesthetics + https://www.saasframe.io/blog/designing-bento-grids-that-actually-work-a-2026-practical-guide (2026)。
- vs scheme1: **better** — 直接诊断 scheme1「均等 2×2 = 退化网格」并给修法。

### 10. 异构 value 形态的控件范式(族内 device 怎么显示被控值)
- **连续值(温度 18-32℃)**:gradient slider(蓝→红色温映射)或 arc/dial;label 在 slider 上方(防手指遮挡)。
- **离散档位(风量 1-10 / 座椅 0-3)**:segmented control 优于 slider(「固定选项应一次全显」);或 discrete slider。
- **RGB 氛围灯**:color picker(spectrum/channel slider/HEX-RGB),触摸 swipe 四向。
- **百分比(车窗 0-100% / 天窗)**:连续 slider 或环形 gauge。
- **开关**:toggle。
- → **直接落 U13「value.type 三分动效」**:连续=gradient slider 滑动动效 / 离散=segment 跳变 / RGB=色环。
- source: https://www.shadcn.io/patterns/slider-settings-3 + https://www.w3.org/WAI/ARIA/apg/patterns/slider/ + https://www.nngroup.com (slider guidance) (2026-06 检索)。
- vs scheme1: **better** — scheme1 只画卡片不区分值形态,异构值显示是缺口。

### 11. 10-foot TV UI — 投屏到客户大屏的硬约束(本机实测主屏 1080p)
- **focus state = TV 设计灵魂**:「glance-away 测试」(瞟开再看回,立刻知道选中谁)→ 投屏时被操作族高亮必须从远处可辨(粗边框/放大/对比线,暗底光晕不够,需对比线)。
- **字号 ≥24-28px @1080p**(web 16-18px ×2.5-3),safe zone 内缩 5%(96×54px),对比 **≥7:1**(高于 web 4.5:1)。
- **低信息密度 + 大留白**(billboard 非 app 思维)→ 反过来支持「10 族 family-card 不摊 191 device」。
- 本机 scout 实测:主屏 1920×1080 FHD → 设计稿必须在 1080p 验证(投屏 banding 风险见 pre-mortem)。
- source: https://en.wikipedia.org/wiki/10-foot_user_interface + https://www.smashingmagazine.com/2025/09/designing-tv-principles-patterns-practical-guidance/ + 本机 system_profiler。
- vs scheme1: **unknown→better** — scheme1 未声明投屏约束,TV UI 给了量化门(字号/对比/safe zone)。

### 12. EV infotainment 2026 — 常驻 climate 边栏 + drive/park 上下文布局(车控特定)
- **持久 stickied 控制**:Volvo 底部固定 climate+seat / GM 左侧固定 → 车控卡可常驻边/底。
- **drive vs park 双布局**:park=tablet 应用态 / drive=放大触控+大字+子集 → demo 可借「演示态」vs「待机态」。
- CarPlay iOS26 / Android Auto 2026 终于加 home widget grid → 车机走向「可定制卡片网格」。
- ⚠️ Euro NCAP 2026 罚「核心功能纯触屏」→ demo 是 mock 演示不涉真车安全,此约束**不适用**(paper-tiger)。
- source: https://www.theturnsignalblog.com/how-we-designed-a-white-label-in-car-infotainment-system/ + https://www.snappautomotive.io/blog/... + https://mergescreens.com/blogs/news/ios-26-carplay (2026)。
- vs scheme1: **better** — 常驻控制 + 上下文布局是车控特化补充。

## pre-mortem

### tigers(明确威胁,带验证清单)
- **T1 — 10 族 family-card 仍可能信息过载**:bento cap 8-12,10 族在甜区但若每族卡又塞太多子状态会爆。验证:逐族列「主状态(1 个)+ 可展开 device 数」,主视图每卡只显 1 主状态(at-a-glance),detail 进展开层。HA「show only if on」+ Apple 分组展开是解。
- **T2 — 语音驱动下「全景常驻」与「只显被控族」冲突未决**:候选 A(全 10 族常驻,客户看到能力全貌)vs B(只浮现被控,聚焦但客户不知有 10 族)。验证:做 A/B 真机对照,默认推 **B' = 常驻全景 + spotlight 聚焦被控**(两者优点合并),但需确认 spotlight 时其余 dim 程度(全黑会丢「能力全貌」,半透明保留)。**口径型分歧 → 建议上抛磊哥拍 A/B/B'**。
- **T3 — 投屏 1080p + 8bit 投影 banding**:深空辉光暗底渐变在 8bit 投影易 banding(色阶断层)。验证:导出深空背景到 1080p 8bit 测 banding,加 dithering 或减渐变跨度;字号/对比按 TV UI 门(≥28px/≥7:1)实测投屏可读(不是看自己高清导出图,要还原客户投影实查 — 见全局 aesthetic 验收纪律)。
- **T4 — 191 device 异构 value 形态前端组件不全**:温度 slider/档位 segment/RGB picker/百分比 gauge 至少 4 类组件,scheme1 只有卡片。验证:逐 value.type(SPOT/EXP/PERCENT + 连续/离散/RGB)列对应 SwiftUI 组件,确认 10 族覆盖,缺的补。

### paper-tigers(看似威胁实际安全,给证据)
- **PT1 — Euro NCAP 2026 罚纯触屏**:仅约束**真车量产**核心功能(转向灯/雨刮/危险灯需物理键)。MAformac 是 mock 演示助手、不上真车、不涉行车安全 → **不适用**(CLAUDE §1 北极星 = 演示非量产)。证据:NCAP 针对 production vehicle safety rating。
- **PT2 — 「找不到原生 SwiftUI 智能家居 dashboard UI kit」**:搜确认无单一现成 kit(muhittincamdali/SwiftUI-Components 仅 21★ / larsoss 未找到 / sanjaynela 3★),但**不阻塞** — bento/spotlight/focus 是范式不是库,SwiftUI LazyVGrid+GridItem+matchedGeometryEffect+.ultraThinMaterial 原生即可实现,无需 adopt 外部 kit(且零依赖离线是硬约束,外部 kit 反而是负担)。证据:gh 实核星数低 + 视觉语言已锁深空辉光自绘。
- **PT3 — D-pad 焦点引擎(TV UI 重点)对 demo 不适用**:10-foot focus state 源于遥控器 D-pad 导航,demo 是语音+触摸非遥控器 → 焦点「导航」机制不迁移,但焦点「**视觉聚焦**(高亮/放大/对比线)」迁移(glance-away 测试对投屏仍成立)。证据:demo 输入是语音非 D-pad。

### elephants(没人提但该提)
- **E1 — 多意图连续两句 = 多卡同时 spotlight 的编排未定**:U13/候选只谈单族聚焦,但「打开空调并降到22度 + 座椅加热」= 2 族同时被控。需定:同时高亮 2 卡?还是顺序 staged 聚焦(先空调亮、再座椅亮)?NOMI staged feedback + HA 多卡联动是参照,但 demo 编排顺序/时序是新设计点,直接影响「炸场」节奏。
- **E2 — orb / 对话流 / 车控卡三屏之间的视觉连续性(matchedGeometry)没人提**:NOMI 的「定向注意力」暗示 orb 应「指向」被操作族(空间连线)。三屏若割裂,语音→聚焦的因果链客户看不出;若用 SwiftUI matchedGeometryEffect 让 orb 发出的光「流向」被控族卡,因果可视化 = 真炸场点。这是 scheme1 三屏分层但无「跨屏连续动效」的缺口。
- **E3 — 「现场只说 10 族 + 族外 unsupported 兜底」的 UI 呈现没人设计**:范式翻案定了族外走 unsupported 兜底,但**前端怎么呈现 unsupported**(灰显?摇头动画?「该功能演示版未开放」卡片?)无定义。客户若手贱说族外,兜底 UI 的体面程度直接决定不丢脸。NOMI 「listening 但无对应动作」的 graceful 反馈可参照。
- **E4 — 香氛/灯光氛围这类「无明显物理状态」族的可视化难**:温度/车窗有直观度数/开度,但「香氛浓度 3 档」「氛围灯呼吸模式」在卡片上怎么显示「正在工作」?需粒子/呼吸光等抽象动效(Orb repo / SwiftUIShaders 已 clone 在 ref-repos 可用),否则这些族的卡片「死气沉沉」拖累炸场。

## adopt 候选

- **piitaya/lovelace-mushroom**(5033★ / pushed 2026-06-12 活)— **adopt 设计形态非代码**:卡片信息层级(icon+name+state 三段)、light/climate/cover 卡的「主控+次状态」拆分、按 family 归类。SwiftUI 重画,不引 JS(零依赖硬约束)。落点:族卡片视觉规格。
- **thomasloven/lovelace-layout-card**(1244★ / 2026-05-09 活)— **adopt 响应式网格思路**:masonry/grid 多布局 + 断点列数。对应 SwiftUI LazyVGrid adaptive GridItem。落点:Mac/iPhone/投屏 三尺寸响应式。
- **NIO NOMI 设计案例**(star.global case study)— **adopt 车机交互范式**:orb embodied + 按操作对象定向注意力 + 语音控同步视觉响应。落点:orb↔被控族 spatial 连线 + spotlight 聚焦机制。source: https://star.global/cases/nio-nomi/
- **HA card-mod state-dependent pulse/glow 模式** — **adopt 动效模式**:state→CSS 条件动画。对应 SwiftUI .animation(value: state) + 条件 .shadow/.scaleEffect。落点:value.type 三分动效 + 被操作高亮。source: https://www.smarthomejunkie.net/animated-icons-and-cards-for-home-assistant-easy-step-by-step/
- **本机已 clone ref-repos**:Orb(orb 动画)/ SwiftUIShaders(辉光/呼吸光)/ open-swiftui-animations / DSWaveformImage(语音波形)— **adopt 现成 SwiftUI 动效实现**,解 E4 抽象族可视化 + orb。落点:/Users/wanglei/workspace/raw/05-Projects/MAformac/ref-repos/{Orb,SwiftUIShaders,open-swiftui-animations}
- **shadcn/W3C ARIA value 控件范式** — **adapt 控件选型**:gradient slider(温度)/ segmented(档位)/ color picker(RGB)/ gauge(百分比)。落点:族内 device 异构 value 组件。source: https://www.shadcn.io/patterns/slider-settings-3
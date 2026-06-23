# Round 3 事实核视角 — UIUE 30 决策独立盲评

> 视角 = **事实核（每决策依赖的外部事实是否真实）**。重点联网 WebSearch 核 API 版本可用性 / 车机范式 / 组件 star+活跃 / 平台行为坑，每条带 URL+日期；并本地 grep/Read 仓内坐实。盲评：假装从未评估过，独立判断。

## 评估底座（本地坐实，所有候选共享）

- **部署目标 = iOS17 / macOS14**（`Package.swift:7-9` 实读）。这是所有 API-版本判断的硬基准。
- **App 不在 SPM build target**（`Package.swift` sources 只含 `Core`+`Features`，App/prototypes 被 exclude）→ 候选里的 SwiftUI 视图代码（C1-C30 大半）**目前不进编译**，是设计意图非已落地代码。
- **当前唯一 SwiftUI grid = `LazyVGrid(.adaptive(minimum:160))`**（`App/ContentView.swift:40`），卡片是绿/灰二值（`:122,:126`），喂 22 个 device 平铺（粒度=device 非族）。10 族/191 device/聚焦/orb/语音 **全未落地**。
- **语音后端 = mock**（`Core/Voice/SpeechSynthesisEngine.swift` + `RecordingSpeechSynthesisEngine`），**无真 AVSpeechSynthesizer / SFSpeechRecognizer / MeshGradient orb**（grep 全仓 0 命中实装）。
- **state-cells.yaml 只 12 cell / 4 族**（air_conditioner/window/screen/ambient_light），**无 priority/优先级字段**（grep 0 命中）。10 族/191 device/线上优先级 = 契约数据缺口。

---

## 30 候选评分表（C1-C30 × 5 维 + Total，满分 25）

| ID | Importance | Verifiability | Non-dup | Decision-Lev | Risk-Reveal | **Total** | verdict |
|---|---|---|---|---|---|---|---|
| C1 | 3 | 3 | 4 | 3 | 2 | **15** | weak |
| C2 | 4 | 4 | 4 | 4 | 4 | **20** | keep |
| C3 | 3 | 4 | 3 | 3 | 3 | **16** | keep |
| C4 | 5 | 4 | 4 | 5 | 4 | **22** | keep |
| C5 | 5 | 5 | 3 | 5 | 4 | **22** | keep |
| C6 | 4 | 3 | 3 | 4 | 4 | **18** | keep |
| C7 | 3 | 4 | 3 | 3 | 3 | **16** | keep |
| C8 | 4 | 3 | 4 | 4 | 5 | **20** | keep |
| C9 | 3 | 4 | 2 | 3 | 3 | **15** | weak |
| C10 | 4 | 4 | 4 | 4 | 4 | **20** | keep |
| C11 | 4 | 5 | 3 | 4 | 3 | **19** | keep |
| C12 | 4 | 5 | 4 | 4 | 4 | **21** | keep |
| C13 | 4 | 3 | 5 | 4 | 5 | **21** | keep |
| C14 | 4 | 4 | 4 | 4 | 4 | **20** | keep |
| C15 | 3 | 5 | 2 | 3 | 3 | **16** | weak |
| C16 | 3 | 4 | 2 | 3 | 3 | **15** | weak |
| C17 | 4 | 5 | 3 | 4 | 4 | **20** | keep |
| C18 | 3 | 4 | 4 | 3 | 3 | **17** | keep |
| C19 | 2 | 3 | 1 | 2 | 2 | **10** | better-exists |
| C20 | 2 | 3 | 1 | 2 | 2 | **10** | better-exists |
| C21 | 5 | 5 | 5 | 5 | 5 | **25** | keep |
| C22 | 4 | 5 | 4 | 4 | 4 | **21** | keep |
| C23 | 4 | 4 | 4 | 4 | 4 | **20** | keep |
| C24 | 3 | 3 | 4 | 3 | 3 | **16** | weak |
| C25 | 4 | 4 | 3 | 5 | 4 | **20** | keep |
| C26 | 5 | 5 | 4 | 5 | 5 | **24** | keep |
| C27 | 4 | 3 | 4 | 4 | 4 | **19** | keep |
| C28 | 4 | 4 | 4 | 4 | 5 | **21** | keep |
| C29 | 3 | 4 | 3 | 3 | 3 | **16** | keep |
| C30 | 5 | 4 | 4 | 5 | 5 | **23** | keep |

---

## 视角专项发现（事实核）

### A. API 版本可用性 — 5 条 load-bearing 全核（候选普遍正确，少数遗漏守卫）
1. **matchedGeometryEffect = iOS14 / macOS11**（[Apple 文档](https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:))，2026-06-23 核）→ **远低于部署目标 iOS17/macOS14，不需 #available**。C21/C23/C25 围绕它的判断成立。
2. **navigationTransition(.zoom) / ZoomNavigationTransition = macOS UNAVAILABLE**（[The Swift Dev](https://www.theswift.dev/posts/swiftui-zoom-navigation-transition/) + [createwithswift](https://www.createwithswift.com/using-the-zoom-navigation-transition-in-swiftui/)，2026-06-23）→ **C21「不用跨栈 zoom」是事实正确的硬判断**（Mac 主舞台无 zoom 退路，这是整组聚焦过渡决策的根基）。
3. **MeshGradient = iOS18 / macOS15**（[Apple 文档](https://developer.apple.com/documentation/swiftui/meshgradient)，2026-06-23）→ **高于部署目标，必须 #available**。C26「每个 shader 必有低版本 fallback」事实正确且必要。
4. **Grid 容器 = iOS16 / macOS13，eager 渲染**（[SwiftUI Lab](https://swiftui-lab.com/eager-grids/) + [avanderlee](https://www.avanderlee.com/swiftui/grid-lazyvgrid-lazyhgrid-gridviews/)，2026-06-23）→ **C22「用 Grid 非 LazyVGrid 规避懒渲染 source 未挂载」机制成立**：Grid 立即实例化所有 cell，matchedGeometry source 永远在场。这是整组里最被低估的精准技术点。
5. **Gauge accessoryCircular/Capacity = iOS16，无 watchOS-only 限制**（[Apple accessoryCircular](https://developer.apple.com/documentation/swiftui/gaugestyle/accessorycircular) + [useyourloaf](https://useyourloaf.com/blog/swiftui-gauges/)，2026-06-23）→ **C12「温度/开度→Gauge 环」正确**，且 `.circular`/`.linear` 确实仅 watchOS（C12 隐含的「原生够用」成立）。

### B. 组件 star+活跃度 — gh cite-verify（finder 高发编数字，逐条亲核）
- **Inferno 2879★ / pushedAt 2026-05-17**（gh 实核）→ 通过 60 天新鲜度门（~37 天），sample 要 iOS17/macOS14（= 部署目标）。**C26/C13/C27 引 Inferno 水波事实成立。**
- **Orb（metasidd）422★ / pushedAt 2024-11-11**（gh 实核）→ **STALE ~19 个月，按 github-first 60 天硬约束应淘汰**。**C26「orb MeshGradient」若暗指 adopt 现成 orb repo = 事实坑**——必须自建 MeshGradient orb（lens6/hig-rules 已坐实，C26 写法用原生 MeshGradient 是对的，但任何「引 siri-orb repo」都踩 stale）。
- **SwiftUIShaders 184★ / 2026-06-01** fresh；**swiftui-hero-animations 249★ / pushedAt 2020-07-06**（gh 实核）= stale 6 年，只读概念不依赖（lens4 已自我纠正）。

### C. 车机 HMI 范式真实性 — 全部联网坐实
- **MBUX Zero Layer = 真实范式**：proactive surface + magic modules + 减菜单深度（[Mercedes 官方](https://group.mercedes-benz.com/innovation/digitalisation/connectivity/mbux-interior-assist.html) + [telematicsnews 2023](https://telematicsnews.info/2023/02/13/mercedes-benz-launches-zero-layer-mbux-ui-on-new-models/) + [SBD 2024 E-Class](https://www.sbdautomotive.com/post/in-car-hmi-ux-evaluation-benchmarking-mercedes-benz-e-class)）→ **C2/C5「全景常驻+触发聚焦」有车机一手范式背书**。
- **NIO NOMI orb + 按座位定向 = 真实**（lens3 引 star.global / nio.com）→ **C2/C9 spotlight 聚焦机制 + orb 朝向有车机原型**。
- **GPU 争用机制真实**：MLX 跑 GPU，与 Metal layerEffect 直接抢资源（[Cactus CoreML vs MLX](https://cactuscompute.com/compare/coreml-vs-mlx) + [arxiv 2603.23640 sustained-load](https://arxiv.org/pdf/2603.23640)，2026-06-23）→ **C13/C30「shader 与推理错峰互斥」机制完全成立**；但 thermal 也是大头（-44% 来自 thermal），不只 GPU 争用。

### D. 平台行为坑 — 真实
- **AVSpeechSynthesizer didCancel 在 iOS15+ 错调 didFinish + barge-in 边界静默**（[Apple Forums #691347](https://developer.apple.com/forums/thread/691347)，2026-06-23）→ **C28「视觉先于 TTS + 状态在调用点改」对应这个真坑**，事实正确。
- **iPhone 15 Pro = 393×852pt，safe area ≈ 759pt**（852−59−34）（[useyourloaf iPhone15](https://useyourloaf.com/blog/iphone-15-screen-sizes/) + [ios-resolution](https://www.ios-resolution.com/iphone-15-pro/)，2026-06-23）→ **C18 的 759pt 是 iPhone 15 Pro 的 safe-area 高度，数字正确但被泛化成「iPhone 竖屏」**（不同机型 safe area 不同；见漏洞段）。

---

## 本地核证据（file:line）

- `Package.swift:7-9` → 部署 `.iOS(.v17)` / `.macOS(.v14)`（所有 #available 判断基准）。
- `Package.swift` sources `["Core","Features"]`，App/prototypes exclude → 候选 SwiftUI 代码不进当前编译。
- `App/ContentView.swift:40` → `LazyVGrid(columns:[GridItem(.adaptive(minimum:160), spacing:12)])`（lens6 坑#1：无 max → resize 重排；C22 直接修这个）。
- `App/ContentView.swift:122,126` → `cell.visualState == .satisfied ? .green : .gray`（7 态压绿/灰二值，C11/C14 要修的源头）。
- `Core/State/DemoVehicleStateStore.swift:134-159` → defaultCells 22 条，**含重复键**（`ac.power`+`hvac.ac`、`ac.temp_setpoint[主驾]`+`hvac.temperature`、`window.position[主驾]`+`window.driver`、`screen.brightness[中控屏]`+`screen.brightness`）= 两套命名混存（generated 旁路 + demo），C11「从 state-cells 派生」会撞这个 SSOT 分叉。
- `contracts/state-cells.yaml` → 仅 12 `id:` / 4 族 / **无 priority 字段**（grep 0）→ C8/C10 的数据依赖缺口。
- `Core/Voice/SpeechSynthesisEngine.swift` + `RecordingSpeechSynthesisEngine`（mock）→ C6/C28 的语音入口/TTS 依赖未落地（DEFERRED）。
- `docs/design/hig-liquid-glass-rules.md:15` → 部署 iOS17/macOS14 + 本机 SDK iOS26.5（C26 #available 必要性坐实）。
- `docs/research/.../lens6-pitfalls.md:23-29`（T2 macOS 无 zoom）、`:31-37`（T3 adaptive 无 max reflow，baseline 已踩）、`:60-64`（T7 ReduceMotion/LPM）= C21/C23/C25/C30 的坑来源。
- `docs/research/.../lens4-swift-components.md:25-31`（Gauge）、`:18-24`（matchedGeometry）= C12/C21 组件来源。

## 联网核证据（URL + 日期，全 2026-06-23 检索）

- matchedGeometryEffect iOS14/macOS11：https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:)
- zoom transition macOS unavailable：https://www.theswift.dev/posts/swiftui-zoom-navigation-transition/ ；https://www.createwithswift.com/using-the-zoom-navigation-transition-in-swiftui/
- MeshGradient iOS18/macOS15：https://developer.apple.com/documentation/swiftui/meshgradient
- Grid 容器 iOS16/macOS13 eager：https://swiftui-lab.com/eager-grids/ ；https://www.avanderlee.com/swiftui/grid-lazyvgrid-lazyhgrid-gridviews/
- Gauge accessoryCircular iOS16：https://developer.apple.com/documentation/swiftui/gaugestyle/accessorycircular ；https://useyourloaf.com/blog/swiftui-gauges/
- Inferno（gh 实核 2879★/2026-05-17）：https://github.com/twostraws/Inferno
- Orb stale（gh 实核 422★/2024-11-11）：https://github.com/metasidd/Orb
- MBUX Zero Layer proactive surface：https://group.mercedes-benz.com/innovation/digitalisation/connectivity/mbux-interior-assist.html ；https://telematicsnews.info/2023/02/13/mercedes-benz-launches-zero-layer-mbux-ui-on-new-models/
- MLX GPU 争用：https://cactuscompute.com/compare/coreml-vs-mlx ；https://arxiv.org/pdf/2603.23640
- AVSpeechSynthesizer didCancel iOS15+ bug：https://developer.apple.com/forums/thread/691347
- iPhone15Pro 393×852 / safe area ~759：https://useyourloaf.com/blog/iphone-15-screen-sizes/ ；https://www.ios-resolution.com/iphone-15-pro/

---

## 反对 / 更好方案 / 漏洞（逐候选有问题的）

**C1（开场动画）**：reveal 扫一遍 10 族网格 = 视觉上炫，但**冷启动 reveal 动画与 mlx 模型加载/首次推理同窗**——若 reveal 跑动画时模型还在 load，开场就卡（lens6 T1+GPU 争用）。漏洞：未约束 reveal 与模型预热的时序（应 KV 预热完再 reveal，或 reveal 期间不触发推理）。

**C4（双屏=两独立实例）vs C16/C17/C19/C20**：C4 是好决策（事实可行：iPhone15Pro A17 能独立跑 1.7B+ASR，[arxiv 2603.23640] 证端侧 LLM 可行），但 **C16/C19/C20 与 C4 高度重叠**——C19「iPhone 独立无断连概念」、C20「iPhone 不极简是独立全功能」都是 C4 的同义复述，**Non-dup 极低**。建议 C19/C20 并入 C4，C16/C17 保留（C16=内容竖屏适配、C17=Bonjour 跨屏机制，各有独立技术点）。

**C6（语音为主展开）+ C28（TTS 时序）**：依赖语音后端，但 **repo 里语音=mock（DEFERRED）**。事实漏洞：C6/C28 在 A2 阶段（code-only，不接真 ASR/TTS）**无法物理验证**，只能 mock 走通时序逻辑。应明确标「语音入口在 A2 用 mock-trigger 验证，真 ASR/TTS 后端 DEFERRED」。C28 的「immediate ack 掩盖首音延迟」是对的（对应 AVSpeech 首音延迟真坑），但首音延迟的具体数字未实测。

**C8（3-4 高频子 device 按线上优先级）**：🔴 **硬数据缺口**——`state-cells.yaml` 无 priority 字段，"线上优先级"目前**无数据源**。这正是 C8 的价值（揭示缺口）也是它的风险。更好方案：demo 阶段「现场只说 10 族」约定下，**手挑每族高频子集硬编码**（产品约定收窄输入），别等补 priority 字段（量产工程，demo 砍）。verdict=keep 因揭示真缺口。

**C10（折叠+角标显子能力数）**：角标"子能力数"=`state_cells.count`，但 **state-cells 仅 12 cell/4 族**，10 族里 6 族无数据 → 角标会显错或显 0。漏洞：角标数依赖未建的全 191 device 契约。更好方案：demo 角标显「该族 device 数」用**硬编码的族-device 映射表**（与 C8 同款约定），不依赖动态 count。

**C11/C15（value.type enum+switch）**：事实正确（编译穷尽优于 AnyView，[SwiftUI 性能共识]）。但 **C15 与 C11 几乎同义**（C11=统一 enum+switch，C15=enum+switch 非 AnyView），Non-dup 低。漏洞：C11「从 state-cells 派生」会撞 DemoVehicleStateStore 的**重复键 SSOT 分叉**（ac.power vs hvac.ac 两套），派生前必先统一命名。

**C13（shader 仅氛围层+GPU 错峰）**：机制完全成立（MLX 抢 GPU 已联网坐实），但 lens 里的**「掉 50%」无精确源**——我核到的是 thermal 导致 -44%（arxiv 2603.23640），GPU 争用的具体百分比无单一权威。建议：把数字标 ESTIMATE 或 A2/性能阶段 Instruments 实测坐实，别写死「50%」。

**C18（759pt 三屏分层）**：759pt 是 **iPhone 15 Pro 专属** safe-area 高度（已核），但候选泛化成「iPhone 竖屏」。漏洞：iPhone 16/17/SE safe area 不同（如 SE 无 Dynamic Island），写死 759pt 分配（orb120/内容440/mic80=640，剩 119 未分配）= 数字不自洽。更好方案：用 `GeometryReader`/safe-area-relative 比例分配，不硬编 759/120/440/80。

**C19/C20**：见 C4——**better-exists（被 C4 覆盖）**，纯重复，建议合并。

**C21（matchedGeometry 不用 zoom）**：🔴 **最强决策，事实满分**。macOS zoom unavailable 已联网坐实，这是逼出「Mac 主舞台聚焦过渡只能 matchedGeometry 或 opacity/scale」的根基判断。无可反对。

**C22（Grid 非 LazyVGrid）**：事实正确（Grid eager 渲染解 matchedGeometry lazy-source 未挂载，已联网坐实）。轻微反对：Grid 无 ScrollView 时所有 cell 立即渲染，10 族 OK，但若未来扩展需滚动得套 ScrollView（此时 eager 反成性能负担）。demo 10 族固定 → 成立。

**C24（320ms/220ms 双参数）**：双参数防竞态的**结构洞察是对的**（展开时长 vs stagger 错峰独立），但 **320/220ms 是魔法数字无源**。漏洞：lens2「序列化高亮 ~150-300ms 错峰」给的是区间，220ms 落在区间内但 320ms 展开时长无依据。更好方案：数字进 `tokens.md` 单源 + 标「实测可调」，别散落在决策里。

**C26（shader 选型+必有 fallback）**：事实满分——MeshGradient iOS18 必守卫、Inferno fresh、Sinebow 是真实算法。唯一漏洞：若「orb MeshGradient」暗示 adopt 现成 orb repo（Orb 422★ stale），踩新鲜度门 → 必自建（hig-rules 已坐实自建，C26 写「MeshGradient」是原生路线，OK）。

**C27（4 段序列+合同回放）**：编排有效，但「合同回放」是 demo-golden-run 概念，依赖 **DEFERRED 的 golden-run 机制**——A2 阶段无法验证完整 4 段。应标分阶段。

**C29（断网 morph）**：原型已实证可行（`scheme1.html:138-146` toggleNet 切 cyan↔琥珀 + badge），事实成立。轻反对：「全族卡断网保持响应」需所有族卡都接端态 store，目前只 4 族有 cell。

**C30（稳定优先于炸场）**：🔴 **最该作为元约束的决策**——thermal watchdog + ReduceMotion/LPM 双通道 + 错峰，全部对应已联网坐实的真风险（thermal -44%、LPM iPhone-only、ReduceMotion 不自动 fallback matchedGeometry）。事实满分，应升为整组的横切纪律而非平级候选。

---

## 这视角 top 5 最该关注候选

1. **C21（过渡 API 不用跨栈 zoom）= 25/25**：唯一满分。整组聚焦过渡决策的事实根基（macOS zoom unavailable 已硬核坐实）。它对 → C22/C23/C25 才站得住；它错 → 全组返工。
2. **C26（shader 选型+强制 fallback）= 24**：MeshGradient iOS18 / glassEffect iOS26 不守卫 = 部署 iOS17 直接崩。事实最 load-bearing 且最易漏（开发反射性用新 API）。Inferno fresh 但 Orb stale 的新鲜度分叉只有联网才 catch。
3. **C30（稳定优先于炸场）= 23**：对应三个已坐实真坑（thermal/LPM/ReduceMotion），且是逼出「demo 不崩 > 惊艳」优先级的元决策。应升横切纪律。
4. **C13（shader 仅氛围层+GPU 错峰）= 21**：MLX-GPU 争用机制已联网坐实（最高 Risk-Revelation），但「50%」数字无源是它唯一软肋——需实测或标 ESTIMATE。
5. **C8（高频子 device 按线上优先级）= 20**：揭示 state-cells **无 priority 字段** 的硬契约缺口（本地 grep 坐实）。价值在暴露缺口，但"线上优先级"无数据源 = demo 应改硬编码约定，否则 A2 落不了地。
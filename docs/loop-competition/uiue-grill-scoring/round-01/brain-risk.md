## 评审说明（盲评 · 风险视角 · Round 1）

我把这 30 个候选**当作从零提案**审。先做了本地核（ContentView/state store/state-cells/tokens/hig-rules/scheme1 原型 + 7 个 lens 调研档），再联网核了所有 load-bearing 的 SwiftUI API 版本 / iOS 行为坑。**重要前置事实**：当前 `App/ContentView.swift` 是个 22 个扁平 device key 的 `LazyVGrid` 绿/灰二值骨架（不是深空辉光、不是 10 族、不是聚焦），所以这 30 个候选**全是面向未来的提案**，对比基线 = 一个原始 demo 骨架。这意味着「Verifiability」要分两层：① 提案引用的技术事实可否证（高）② 提案声称的 UI 是否已存在（否，全是 to-build）。

---

## 30 候选评分表（C1-C30 × 5 维 + Total，每维 1-5）

| ID | Importance | Verifiability | Non-dup | Leverage | RiskReveal | **Total** | verdict |
|---|---|---|---|---|---|---|---|
| C1 开场 orb→reveal→idle | 3 | 3 | 3 | 3 | 2 | **14** | weak |
| C2 多意图序列化高亮 | 5 | 4 | 4 | 4 | 4 | **21** | keep |
| C3 dim 族弱呼吸+彩蛋 | 2 | 3 | 2 | 2 | 2 | **11** | weak |
| C4 双屏=两独立端侧实例 | 4 | 4 | 4 | 4 | 4 | **20** | keep |
| C5 主视图=全景常驻+聚焦 | 5 | 5 | 3 | 4 | 4 | **21** | keep |
| C6 展开=语音主tap辅同入口 | 4 | 4 | 3 | 4 | 3 | **18** | keep |
| C7 原地放大+blur非modal | 4 | 4 | 3 | 3 | 3 | **17** | keep |
| C8 子device显3-4高频 | 4 | 4 | 4 | 4 | 4 | **20** | keep |
| C9 同时只展开1族 | 3 | 4 | 2 | 3 | 3 | **15** | weak（与C7重） |
| C10 族卡折叠不平铺191 | 5 | 5 | 3 | 4 | 4 | **21** | keep |
| C11 value.type enum+switch派生 | 5 | 5 | 4 | 4 | 4 | **22** | keep |
| C12 控件缺口自建+原生 | 5 | 5 | 4 | 5 | 4 | **23** | keep |
| C13 shader仅氛围层+错峰互斥 | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C14 卡片骨架统一只变值区 | 4 | 4 | 3 | 4 | 3 | **18** | keep |
| C15 enum+switch非AnyView | 3 | 5 | 2 | 3 | 3 | **16** | weak（与C11重） |
| C16 iPhone独立全功能非镜像 | 3 | 4 | 2 | 3 | 3 | **15** | weak（与C4/C20重） |
| C17 Bonjour LAN可选联动 | 4 | 5 | 3 | 4 | 5 | **21** | keep |
| C18 iPhone 759pt三屏分层 | 3 | 5 | 3 | 3 | 3 | **17** | keep |
| C19 iPhone无断连概念 | 2 | 3 | 2 | 2 | 2 | **11** | weak（与C4重） |
| C20 iPhone独立全功能定位 | 2 | 3 | 1 | 2 | 2 | **10** | reject（C4/C16/C19/C20四合一冗余） |
| C21 过渡=matchedGeometry非zoom | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C22 Grid非LazyVGrid规避懒渲染 | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C23 兜底动画opacityScale | 4 | 5 | 3 | 4 | 4 | **20** | keep |
| C24 时长320/220双参数 | 3 | 3 | 3 | 3 | 2 | **14** | weak |
| C25 升级门编译验证后才升 | 4 | 4 | 3 | 5 | 4 | **20** | keep |
| C26 shader选型+必有fallback | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C27 wow 4段sequencer合同回放 | 4 | 3 | 4 | 4 | 3 | **18** | keep |
| C28 TTS时序+immediate ack | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C29 断网高潮morph+徽章 | 4 | 5 | 4 | 4 | 3 | **20** | keep |
| C30 稳定优先+thermal watchdog | 5 | 5 | 4 | 5 | 5 | **24** | keep |

---

## 视角专项发现（风险 · pre-mortem · tiger/paper-tiger/elephant）

### 🐯 TIGER（明确威胁，带验证清单）

**T1（HIGH）— 离线 TTS 中文默认音色机器人感，会当场拖垮「惊艳」**（C28 漏的 elephant）
- 联网坐实：AVSpeechSynthesizer 默认中文 voice 是低质机器人感，要 enhanced/premium 神经音色才自然；而 premium 中文 voice **需在系统设置预先下载**。北极星=「断网也能跑」+「看着惊艳」，但断网 demo 机若没预装 premium 中文 voice，第一句 TTS 就是塑料音。
- 验证：demo 机系统设置预装中文 enhanced/premium voice + 代码 `filter quality == .premium/.enhanced`；现场断网前确认 voice 已落本机（非依赖联网下载）。
- C28 只写「AVSpeechSynthesizer + immediate ack」，没把「音色质量是离线硬约束」写进承诺 → **应补**。

**T2（HIGH）— 首帧 shader 冷编译延迟会卡在开场**（C13/C26/C30 都没点名）
- 联网坐实：Apple Silicon 上 Metal shader / MLX 首次跑触发 shader 编译，可加几秒延迟（后续走 shader cache）。C26 的 MeshGradient/ripple/Sinebow 三个 shader + MLX 推理，**首次触发那一帧**可能在客户进场第一眼卡顿。
- 验证：app 启动后台预热（warm-up pass）所有 shader + 一次 dummy MLX 推理，把冷编译挪到 splash 阶段，别让它落在「打开空调」第一句。
- C30 有 thermal watchdog/错峰，但 watchdog 治稳态发热，治不了**冷启动一次性 shader 编译**。这是与 C13「KV 预热」同类但 GPU 侧的预热缺口。

**T3（HIGH）— tokens.md `glassEffect` 标 iOS18 是错的（实际 iOS26）= 跨文档 SSOT 分叉**（影响 C25/C30/所有读 tokens 的 view）
- 联网坐实：`.glassEffect()` = iOS26+（WWDC2025），但 `docs/design/tokens.md:92` 写「iOS18 `.glassEffect()`」，而 `hig-liquid-glass-rules.md:27,41` 正确写 iOS26。**视觉 SSOT 自己分叉了**。
- 后果：谁照 tokens.md 写 `#available(iOS 18)` → iOS18-25 部署机崩 / 编译炸。C25「编译验证后才升级」能 catch，但这是个**埋好的雷**应直接修 tokens.md。
- 验证：grep 全仓 `iOS18` 旁 `glassEffect` 改 iOS26；C25 升级门把「#available 版本号正确」列为门项。

**T4 — LAN 联动的 Local Network 权限弹窗会在现场炸**（C4/C17，已被「可选」缓解但未点名）
- 联网坐实：iOS Bonjour/NWBrowser **必触发 Local Network 隐私弹窗**，且 iOS17/18 行为不一致（iOS17 拒绝后要重启设备、iOS18 拒绝后仍能连=反直觉、Sequoia 15.4 模拟器无弹窗），无公开 API 静默预检。
- C4/C17 把 LAN 列为**可选加分**（✅正确去风险），但若现场临时想演双屏联动，权限弹窗 + 不确定行为可能当众尴尬。
- 验证：双屏联动写进「彩排时预先 grant 权限」checklist；主链路（C4 双实例各自独立）不依赖 LAN = 正解，保持。

**T5 — 投屏 8bit banding + 深空暗底渐变**（C26/C29/C30 间接覆盖，但没一个候选直接拿 banding 当承诺）
- lens1/3/6 三路坐实 + 本机主屏 1920×1080：深空暗底大渐变在 8bit 投影/AirPlay 易 banding，高对比投影更糟。C26 管 shader fallback，C30 管稳定，但**没有候选把「渐变叠 IGN dither + 现场有线投屏」写成承诺**。这是与磊哥飞书白皮书「太丑看不清」同源的展示层雷。
- 验证：渐变区叠 SwiftUIShaders IGN dither；现场强制有线 HDMI/USB-C（非 AirPlay，AirPlay 动画掉帧叠加）。**建议补一个独立候选或并入 C30。**

### 🐅 PAPER-TIGER（看似威胁实际可控，给证据）
- **PT1「10 族卡太多会卡」**：伪威胁。lazy grid 性能拐点是 20×20=400（FB8436070），10 张数量根本不是瓶颈；真正成本是 per-cell 辉光 offscreen（C13 只激活态 breathe 已对症）。
- **PT2「matchedGeometry 一定抖」**：半真。C21/C22/C23 的组合（Grid 非 Lazy 消 multiple-source 冲突 + opacityScale 兜底 + 升级门）正是修法，**这三个候选是把 paper-tiger 关进笼子的关键**，不该砍。
- **PT3「SwiftUI 不专业」**：伪威胁，demo 非量产，框架不决定观感。

### 🐘 ELEPHANT（没人提但该提）
- **E1 — 多意图「同时改 2+ 卡」与 C2「序列化高亮」的时序，和 C28「视觉先于 TTS」会打架**：C2 要序列化（一卡亮完再亮下一卡 ~220ms），C28 要视觉先行 + immediate ack，C24 给 320/220 两参数。三者叠加时，**TTS 念第一句时第二卡还没亮，客户听到「空调降到22、座椅加热」但只看到一张卡** → 视听不同步。没有候选定义「多意图时 TTS 文案 vs 卡片序列的对齐策略」。这是炸场节奏的隐藏设计点。
- **E2 — 香氛/氛围灯这类「无直观物理状态」族怎么显示"正在工作"**（lens3 E4）：温度有度数、车窗有开度，但「香氛 3 档」「氛围灯呼吸模式」在卡上靠什么表达 active？C8/C14 谈骨架统一，但**异构到「无标量值」的族（开关/抽象模式）C11 的 5 类 enum 是否真覆盖？** C11 列了「连续/离散档/RGB/开关/多维」5 类，香氛浓度可归离散档、氛围灯模式可归 enum——勉强覆盖，但 active 动效（粒子/呼吸）无候选承诺。
- **E3 — 「现场只说 10 族 + 族外 unsupported 兜底」的 UI 呈现完全没人设计**（lens3 E3）：范式定了族外走 unsupported，但客户手贱说族外（导航/打电话）时，前端怎么体面拒识？tokens.md:60 有 `blocked_hard` 灰锁色，但**没有候选把「unsupported 兜底卡的呈现」列为交付项**。这直接决定「不丢脸」。
- **E4 — C30「稳定优先于炸场」与北极星「看着惊艳」的张力没有量化裁决线**：C30 说低电量/ReduceMotion 双通道、thermal watchdog，方向对，但「降级到什么程度还算惊艳」没有阈值。Mac 主舞台不吃 LPM（isLowPowerModeEnabled 在 Mac 永远 false，已联网坐实）→ 主舞台其实不需为 LPM 降级，**C30 把 LPM 降级无差别套到 Mac 是 frame 溢出**（LPM 是 iPhone 专属）。应分平台：Mac 只吃 ReduceMotion/Transparency，iPhone 才吃 LPM。

---

## 本地核证据（file:line）

- `App/ContentView.swift:40` — 现状 `LazyVGrid(GridItem(.adaptive(minimum: 160)))` **无 maximum** = lens6 T3 坑#1（window resize/投屏重排），且喂 22 个扁平 device 非 10 族（C5/C10 的诊断对象）。
- `App/ContentView.swift:122,126` — `cell.visualState == .satisfied ? .green : .gray` = **把 7 态压成绿/灰二值**，正是 tokens.md:64 + U10 头号翻车点。C11/C14 是修这个的。
- `Core/State/DemoVehicleStateStore.swift:17-25` — `DemoVisualState` 7 态枚举（normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown），**已存在的 SSOT**，C11 的 value.type switch 和 tokens 7 态色都应消费它。
- `Core/State/DemoVehicleStateStore.swift:119` — `visualState = transition.desiredValue == "on" ? .satisfied : .normal` = mock 只产出 2 态，**7 态里 5 态无产出路径** → C2/C11/C14 的 7 态可视化目前没有数据驱动它（demo 链路需补 clarify/unsafe/unsupported 态的产出，否则色卡是死代码）。
- `contracts/state-cells.yaml:60,80,96,130,156,176` — execution_range 真值：温度 18-32/step1、风量 1-10、车窗/屏幕/氛围 0-100、车速 0-180。C11/C12 的连续值控件区间必从这里派生（C11「从 state-cells 数据派生」措辞精确，加分）。
- `contracts/state-cells.yaml:9-15` — surface 边界注释明确「state cell 不随 surface 形态变」，与 C11「value.type 从 state-cells 派生」一致。
- `docs/design/tokens.md:92` — **`control_glass` 写「iOS18 `.glassEffect()`」= 错（实际 iOS26），与同仓 hig-rules:27,41 分叉**（T3）。
- `docs/design/hig-liquid-glass-rules.md:15` — 部署底线 iOS17/macOS14，SDK iOS26.5 → 「iOS26 设计、iOS17 部署」，所有 iOS18+ API 必 #available（C25/C26/C21 的版本守卫前提）。
- `docs/design/tokens.md:59-64` — 7 态色已设计：clarify=琥珀/unsupported=灰锁/unsafe=红/crash=灰，四态分开（C2 序列化高亮 + 异构态的色基础）。
- `prototypes/scheme1-deep-space-interactive.html:50-53,67-69` — breathe（3.4s box-shadow）+ pulse keyframe + `@media (prefers-reduced-motion:reduce){*{animation:none}}` 已示范（C23/C30 双通道的原型证据）；但 scheme1 仅 6 卡 2×2（C5/C10 诊断的「撑不住 10 族」对象）。
- `docs/research/.../lens6-pitfalls.md:23-29` — matchedGeometry 在 LazyVGrid 的 multiple-source 冲突 + macOS 无 zoom 退路（C21/C22 的 source）。
- `docs/research/.../lens6-pitfalls.md:59-64` — ReduceMotion **不自动剥离** matchedGeometry（需自给 opacity fallback）+ LPM iPhone 专属（C23/C30 的 source，且坐实 E4 的 frame 溢出）。
- `docs/research/.../lens4-swift-components.md:58-60` — `swiftui-hero-animations` ⭐249/pushed 2020（stale 6 年），结论用原生 matchedGeometry/Gauge 不依赖 stale repo（C12「原生优先」的依据）。

---

## 联网核证据（URL + 日期，均 2026-06-23 检索）

- **MeshGradient = iOS18/macOS15**（C26 必 #available 正确）：https://developer.apple.com/documentation/swiftui/meshgradient
- **navigationTransition `.zoom`/ZoomNavigationTransition 在 macOS 不可用**（C21 在 Mac 主舞台只能用 matchedGeometry = 正确）：https://www.createwithswift.com/using-the-zoom-navigation-transition-in-swiftui/ + https://github.com/hmlongco/Navigator/issues/25
- **`Grid`/`GridRow` = iOS16/macOS13，eager-render（创建全部子视图，better cell spacing/alignment）**（C22 用 Grid 规避 lazy-source 未挂载冲突 = 正确，且 iOS17 target 安全可用）：https://developer.apple.com/documentation/swiftui/lazyvgrid + https://www.avanderlee.com/swiftui/grid-lazyvgrid-lazyhgrid-gridviews/
- **AVSpeechSynthesizer `stopSpeaking(.immediate)` 在 iOS15+ 触发 didFinish 而非 didCancel**（验证 hig-rules「状态在调用点直接改不只靠 delegate」+ C28 barge-in 风险）：https://developer.apple.com/forums/thread/691347
- **AVSpeechSynthesizer 默认中文音色机器人感，需 enhanced/premium 神经音色（macOS14+ 神经音色，需系统下载）**（T1 离线 TTS 音色 elephant）：https://nshipster.com/avspeechsynthesizer/ + https://fazm.ai/t/local-text-to-speech-ai
- **`isLowPowerModeEnabled` 在 iPad/Mac 永远返回 false（iPhone 专属）**（坐实 C30 LPM 降级套 Mac 是 frame 溢出 = E4）：https://useyourloaf.com/blog/detecting-low-power-mode/ + https://developer.apple.com/documentation/foundation/processinfo/islowpowermodeenabled
- **iOS Local Network 隐私权限：Bonjour/NWBrowser 必触发弹窗，无静默预检 API，iOS17/18 行为不一致 + Sequoia 15.4 模拟器无弹窗**（T4 LAN 现场风险，C4/C17 列可选=去风险）：https://developer.apple.com/documentation/technotes/tn3179-understanding-local-network-privacy + https://developer.apple.com/forums/thread/766133
- **Apple Silicon：避免多 runtime 并发防 GPU 内存争用 + 热节流；首帧 shader 冷编译加几秒延迟（后续走 cache）**（C13/C30 错峰互斥 grounded + T2 冷编译缺口）：https://www.sitepoint.com/local-llms-apple-silicon-mac-2026/ + https://yage.ai/share/mlx-apple-silicon-en-20260331.html
- **`.glassEffect()` = iOS26+（WWDC2025），需 GlassEffectContainer 限同屏数**（坐实 T3 tokens.md iOS18 写错）：https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views + https://getskyscraper.com/blog/apple-liquid-glass-ios-26-swiftui-guide

---

## 反对 / 更好 / 漏洞（逐候选有问题的）

- **C1（开场序列）**：漏洞=「全 10 族网格 reveal 扫一遍」若用插入动画踩 lens6 T3 reflow 跳；更好=用 Grid 常驻 + 逐卡 opacity/scale stagger（不插入节点）。且「reveal 扫一遍」与 C2「不同时闪」精神微冲突（开场扫全场 vs 聚焦时序列化），开场可豁免但应说明。低 Risk Revelation。
- **C3（dim 族弱呼吸）**：漏洞=「10 卡都极弱呼吸」= lens1 F8 的 10 个 offscreen 持续动画 pass，与 C13/C30「只激活态 breathe」**直接矛盾**。更好=dim 族**静态**微光（非动画呼吸），呼吸只给激活态。「全部展示彩蛋」是锦上添花非决策。
- **C9（同时只展开1族）**：与 C7（原地放大+blur）高度重叠，C9 ≈ C7 的并发约束子句。建议并入 C7。
- **C15（enum+switch非AnyView）**：与 C11 几乎同一件事（C11 已说 enum+switch 派生），C15 只是补「非 AnyView」实现细节。建议并入 C11 作实现约束。
- **C16/C19/C20（iPhone 定位三连）**：**C20 几乎是 C4+C16+C19 的复述**（「iPhone 是独立全功能端侧 demo」C4 已含）。四个候选讲同一件事（iPhone 独立非镜像），稀释决策密度。建议保 C4（双实例架构）+ C18（竖屏布局技术），C16/C19/C20 合并或砍。**C20 应 reject。**
- **C24（320/220 时长）**：两个魔法数字无来源（不像 C21/C22 有 API 事实背书），且与 C2/C28 的时序耦合未对齐（见 E1）。更好=把时长定义为「与 TTS 句长对齐的相对参数」而非绝对 ms，否则多意图长句时卡片序列跑完了 TTS 还在念。
- **C27（4段 sequencer 合同回放）**：好方向（确定性编排=demo 可复现），但「合同回放」若做成**固定脚本**，与 demo-scenarios.yaml 反复强调的「LoRA 泛化非规则查表」精神有张力——sequencer 该编排**视觉时序**，不该把**意图识别**写死成脚本，否则现场换句话术崩。应明确「sequencer 只管视觉/TTS 时序，不管意图」。
- **C28（TTS 时序）**：漏 T1（默认中文音色机器人感）。更好=承诺里加「demo 机预装 premium 中文 voice + 代码 filter quality」。barge-in 若依赖 didCancel 会踩 iOS15+ bug（已联网坐实），应在调用点直接改状态（hig-rules 已有此约束，C28 应显式引用）。
- **C30（稳定优先）**：漏洞=LPM 降级无差别套 Mac（Mac `isLowPowerModeEnabled` 永远 false，套了是死代码 + 可能误把 Mac 主舞台降级）。更好=分平台：Mac 主舞台只吃 ReduceMotion/ReduceTransparency，iPhone 加分屏才吃 LPM。另：thermal watchdog 治不了首帧 shader 冷编译（T2），应补启动预热。
- **整体漏洞（跨候选）**：① 7 态色可视化（C2/C11/C14/tokens）目前**无数据驱动**——state store 只产出 2 态（store:119），clarify/unsafe/unsupported 态没有产出路径，色卡会是死代码，需补 demo 链路产出这些态。② 投屏 banding（T5）没有任何候选拿来当承诺，是与磊哥飞书白皮书同源的展示层雷，应补。③ E1 多意图 TTS↔卡片序列对齐、E3 unsupported 兜底 UI 呈现，都是「不丢脸」关键但无候选覆盖。

---

## 我这视角（风险）top 5 最该关注候选

1. **C30（稳定优先 + thermal watchdog，Total 24）** — 直接对应北极星「不崩」，且我的联网核证实「多 runtime 并发热节流」是真威胁；但它自身有两个该 grill 的洞：LPM 套 Mac 是 frame 溢出（Mac 永远 false），thermal watchdog 治不了首帧 shader 冷编译。**最高杠杆 + 自身有漏洞 = 最该 grill。**
2. **C28（TTS 时序，Total 23）** — 漏了**离线中文默认音色机器人感**这个 elephant（联网坐实），且 barge-in 若靠 didCancel 踩 iOS15+ bug。这两点直接威胁「惊艳」+「反应快」，是隐藏成本最高的候选。
3. **C21+C22+C26（过渡/容器/shader 版本守卫，各 23）** — 三者是把 lens6 最毒的两个 HIGH tiger（matchedGeometry 在 LazyVGrid 抖 + macOS 无 zoom 退路 + iOS18+ API 不守卫直接崩）关进笼子的核心。我联网逐条坐实了「zoom unavailable on macOS」「MeshGradient=iOS18」「Grid=iOS16 eager」——这三个候选的技术事实**全对**，但 tokens.md `glassEffect` 标 iOS18 是埋好的雷（T3），C25/C26 的版本守卫门必须 catch 它。
4. **C13（shader 仅氛围层 + 与推理错峰互斥，Total 23）** — 联网坐实「unified memory 并发争用 + 热节流」，C13 方向对；但**首帧 shader 冷编译延迟**（几秒）是它和 C26/C30 共同的盲点，会落在客户进场第一眼。
5. **C4/C17（双屏架构 + LAN 可选，Total 20/21）** — 我联网坐实 Local Network 权限弹窗 iOS17/18 行为不一致 + 无静默预检 + 模拟器坑。C4/C17 把 LAN 列为**可选加分**（主链路双实例各自独立）= 把这个现场炸点提前去风险了，方向正确；该 grill 的是「现场万一想演联动时，权限弹窗预案」是否写进 checklist。
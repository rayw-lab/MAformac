# Brain — Round 1 可行性视角盲评（C1-C30）

> 视角 = SwiftUI/代码实现可行性。每决策按「本地 grep 现状代码 + 实现复杂度 + 端侧约束 + 联网 API 版本事实」核。
> 🔴 **最大可行性事实**（决定所有打分基线）：当前代码 = **walking skeleton**。`App/ContentView.swift` 仅 TextField + `LazyVGrid(.adaptive(minimum:160))` 8 卡 + trace 面板；`FastPathIntentEngine.swift:11` **只硬编码 1 条意图「打开空调」**；无 ASR；TTS 是裸 `AVSpeechSynthesizer.speak` 无 barge-in。`grep MeshGradient|matchedGeometryEffect|Gauge|glassEffect|TimelineView|withAnimation|RippleEffect` 在 App/Core **零命中**。30 个候选描述的是一个**尚未存在的完整语音驱动 10 族 demo**——它们是「未建 UI 的设计决策」，可行性风险普遍偏高，但不是空想（lens 调研已坐实控件/API 可达）。

## 30 候选评分表（C1-C30 × 5 维 + Total，满分 25）

| ID | Imp | Ver | NonDup | Lev | Risk | **Total** | verdict |
|---|---|---|---|---|---|---|---|
| C1 | 3 | 4 | 4 | 3 | 2 | **16** | keep |
| C2 | 4 | 4 | 4 | 4 | 4 | **20** | keep |
| C3 | 2 | 3 | 3 | 2 | 2 | **12** | weak |
| C4 | 4 | 4 | 3 | 4 | 4 | **19** | keep |
| C5 | 4 | 4 | 2 | 4 | 4 | **18** | keep（与 C1 重叠） |
| C6 | 3 | 3 | 3 | 3 | 3 | **15** | keep |
| C7 | 4 | 5 | 4 | 4 | 4 | **21** | keep |
| C8 | 3 | 3 | 3 | 3 | 3 | **15** | weak |
| C9 | 3 | 4 | 2 | 3 | 3 | **15** | weak（C5/C7 子集） |
| C10 | 4 | 4 | 3 | 4 | 4 | **19** | keep |
| C11 | 4 | 4 | 4 | 4 | 3 | **19** | keep |
| C12 | 4 | 5 | 4 | 4 | 4 | **21** | keep |
| C13 | 3 | 3 | 4 | 3 | 4 | **17** | keep |
| C14 | 4 | 4 | 4 | 4 | 3 | **19** | keep |
| C15 | 3 | 4 | 2 | 3 | 3 | **15** | weak（C11 子集） |
| C16 | 3 | 4 | 3 | 3 | 3 | **16** | keep |
| C17 | 3 | 4 | 3 | 3 | 4 | **17** | keep |
| C18 | 3 | 4 | 3 | 3 | 3 | **16** | keep |
| C19 | 2 | 3 | 2 | 2 | 2 | **11** | weak（C4/C16/C20 重述） |
| C20 | 2 | 3 | 2 | 2 | 2 | **11** | reject（C4/C16/C20 三连重复） |
| C21 | 5 | 5 | 4 | 4 | 5 | **23** | keep（top） |
| C22 | 4 | 5 | 4 | 4 | 4 | **21** | keep |
| C23 | 4 | 4 | 4 | 4 | 4 | **20** | keep |
| C24 | 3 | 4 | 3 | 4 | 3 | **17** | keep |
| C25 | 4 | 4 | 3 | 4 | 4 | **19** | keep（C21/C23 收口） |
| C26 | 4 | 5 | 4 | 4 | 5 | **22** | keep（top） |
| C27 | 3 | 3 | 4 | 4 | 4 | **18** | keep |
| C28 | 4 | 5 | 4 | 4 | 5 | **22** | keep（top） |
| C29 | 3 | 4 | 4 | 3 | 3 | **17** | keep |
| C30 | 5 | 4 | 4 | 5 | 5 | **23** | keep（top） |

## 视角专项发现（可行性）

1. **整库是 skeleton，30 候选是「未建 UI 的前瞻决策」**：`grep` 证实 App/Core 零动画/零 orb/零 Gauge/零 matchedGeometry 代码（git log 显示全部精力在 C5 LoRA + 文档级联，UI 仅 docs）。→ 所有候选的 Verifiability 高（API 事实可核）、但「已落地」证据为 0；可行性评分按「API 是否可达 + 复杂度」而非「已实现」给。

2. **API 版本对部署门（iOS17/macOS14, `Package.swift:8-9`）的可行性裁决（联网坐实）**：
   - `matchedGeometryEffect` = **iOS14**（在门下 → 永远可用，**无需 #available**）→ C21 在「可用性」上零风险。
   - `Grid` 容器 = **iOS16/macOS13**（在门下 → 无需守卫）→ C22 在「可用性」上零风险（其真价值是规避 LazyVGrid 懒渲染，非守卫）。
   - `Gauge`/`.accessoryCircular` = **iOS16/macOS13**（在门下 → 无需守卫）→ C12「原生控件」可行性强。
   - `MeshGradient` = **iOS18/macOS15**（在门上 → **必 #available + iOS17 fallback**）→ C26 fallback 设计是硬需求，不是可选。
   - `navigationTransition(.zoom)`/`matchedTransitionSource` zoom = **macOS 上 unavailable（编译级，需 `#if os(iOS)` 而非 `#available`）** → C21「不用跨栈 zoom 改用 matchedGeometry」在 Mac 主舞台是**唯一可行解**（Mac 没有 zoom transition 退路），这是 C21 的最强可行性证据。

3. **C2/C27 多意图序列化高亮在工程上极易实现**（`.animation(...delay(idx*0.05))` / `PhaseAnimator` iOS17）且规避了「同帧多卡 reflow + 注意力溢出」——是低成本高 wow 的决策，可行性优。但 C27 的「合同回放 sequencer」是项目自造编排层（无现成 repo），复杂度被低估。

4. **TTS barge-in 是真坑且现状未处理**（联网坐实）：`AVSpeechSynthesisEngine` 现状裸 speak；`didCancel` 在 **iOS15+ 自调 stopSpeaking 不触发**，且快速连续 cancel 会**锁死 synthesizer**（需新建实例）。C28「视觉先于/同步 TTS + immediate ack 在调用点改状态」正是规避此坑的正解——可行性 + 风险揭示双高。

5. **数据契约只覆盖 4 族，非 10 族**：`state-cells.yaml` 只定义 air_conditioner/window/screen/ambient_light + safety（grep 坐实）。→ C8「3-4 高频子 device 按线上优先级」/C10「角标显子能力数」/C11「从 state-cells 派生」**当前无 10 族数据可派生**，存在「契约未补全」的隐藏前置依赖，候选未点破（C11 措辞像数据已就绪）。

6. **C19/C20 与 C4/C16 高度重复**：双屏「iPhone 独立全功能、脱机可演」在 C4/C16/C17/C18/C19/C20 反复出现 6 次，工程上是**同一条决策**（两个独立 SwiftUI app target 跑同一 Core）。C19「无断连概念」「双实例炸场」、C20「不极简」基本是 C4 的同义重述，应合并。

7. **C13 GPU 错峰是真实端侧约束**（与 hig-rules/lens 一致）：shader `layerEffect` 与 mlx 推理抢 GPU 掉 ~50% 吞吐。但「GPU 协调器与推理互斥」在 SwiftUI 层没有现成原语——需自建调度（检测推理中→暂停 TimelineView 自驱），复杂度中高，候选写得像一个开关。

## 本地核证据（file:line）

- `App/ContentView.swift:40` — `LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)]...)` 现状网格（C22 要改的对象；adaptive 无 max = lens6 T3 已踩坑）。
- `App/ContentView.swift:121-127` — `background`/`borderColor` 把 7 态压成 `visualState == .satisfied ? green : gray` 二值（C14/C11 要修的 7 态映射缺口，tokens.md:64 同警告）。
- `App/ContentView.swift:24-37,64-80` — commandBar = TextField + 「执行」按钮；**无语音入口**（C6「语音为主 tap 为辅」目前 tap 都还没有真实交互，语音=0）。
- `Core/State/DemoVehicleStateStore.swift:17-25` — `DemoVisualState` 7 态枚举（normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown），是 C11/C14 值/态分发的真实消费源。
- `Core/State/DemoVehicleStateStore.swift:134-159` — `defaultCells()` 22 cell，key 命名两套并存（`ac.power`/`ac.temp_setpoint[主驾]` vs `hvac.ac`/`seat.driver.heat`），与 `state-cells.yaml` 的 `ac.power`/`ac.temp_setpoint` 不完全一致 = C11 数据派生的口径风险。
- `Core/Intent/FastPathIntentEngine.swift:11-14` — `guard normalized == "打开空调"` **唯一硬编码意图**；证明语音/意图链路 = 1 条 demo path（C1/C2/C5/C6/C27 描述的全 10 族联动尚无后端支撑）。
- `Core/Voice/SpeechSynthesisEngine.swift:8-24` — `AVSpeechSynthesisEngine.speak` 裸调用，无 `stopSpeaking`/无 barge-in（C28 要补的对象）。
- `contracts/state-cells.yaml:40,87,121,139` — 仅 4 device 族（air_conditioner/window/screen/ambient_light）有 state_cells；10 族数据缺 6（C8/C10/C11 隐藏前置）。
- `contracts/demo-scenarios.yaml:81,85,93` — `dimensions: [多意图]` 幕存在（C2/C27 是真实 demo 需求，非凭空）。
- `Package.swift:8-9` — `.iOS(.v17), .macOS(.v14)` 部署门（所有 #available 裁决的基线）。App 被 SPM 排除（App=Xcode app，Core=library）。
- `prototypes/scheme1-deep-space-interactive.html:41-55` — 现原型 = 2 列 6 卡 grid + breathe/pop CSS keyframe，**无全景→聚焦 morph、无 Gauge、无 10 族**（C1/C5/C7 超出原型，是新设计）。
- `docs/design/tokens.md:49-64` — 7 态色映射表（C11/C14/C29 的色 token 源，DRAFT 待冻结）。
- `docs/design/hig-liquid-glass-rules.md:15-21,40-60` — #available 模板 + Liquid Glass functional-only + 双通道铁律（C21/C25/C26/C30 的约束源）。
- `docs/research/.../lens4/lens6/lens7.md` — 候选 C1/C2/C5/C7/C11-C15/C21-C28 几乎逐条可追溯到 lens 的 findings/presentation_options（→ Non-duplication 受影响：候选是 lens 的提炼，多数非原创发现，但作为「决策晶体」仍有 leverage）。

## 联网核证据（URL + 日期，2026-06-23 检索）

- **navigationTransition.zoom macOS unavailable**（编译级，需 `#if os(iOS)`）— [Douglas Hill: Zoom transitions](https://douglashill.co/zoom-transitions/) + [createwithswift](https://www.createwithswift.com/using-the-zoom-navigation-transition-in-swiftui/) + [hmlongco/Navigator #25](https://github.com/hmlongco/Navigator/issues/25)。→ 坐实 C21。
- **MeshGradient = iOS18/macOS15** — [Apple MeshGradient docs](https://developer.apple.com/documentation/swiftui/meshgradient) + [Donny Wals](https://www.donnywals.com/getting-started-with-mesh-gradients-on-ios-18/)。→ C26 fallback 是硬需求。
- **Grid = iOS16/macOS13；LazyVGrid/LazyHGrid = iOS14** — [Apple Grid docs](https://developer.apple.com/documentation/swiftui/grid) + [avanderlee](https://www.avanderlee.com/swiftui/grid-lazyvgrid-lazyhgrid-gridviews/)。→ C22 在 iOS17 门下无需守卫；真价值=非懒渲染规避 matchedGeometry 冲突。
- **Gauge/.accessoryCircular = iOS16/macOS13** — [Apple accessoryCircular](https://developer.apple.com/documentation/swiftui/gaugestyle/accessorycircular) + [Sarunw](https://sarunw.com/posts/swiftui-gauge/)。→ C12 原生路线可行。
- **matchedGeometryEffect = iOS14** — [Apple matchedGeometryEffect](https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:))。→ C21 门下可用。
- **AVSpeechSynthesizer barge-in：didCancel 在 iOS15+ 自调 stopSpeaking 不触发 + 快速连续 cancel 锁死 synthesizer（需新建实例），.immediate/.word 不修此 bug** — [Apple Forums #691347](https://developer.apple.com/forums/thread/691347) + [Apple Forums #40075](https://developer.apple.com/forums/thread/40075)。→ 坐实 C28（状态在调用点改、视觉先行）。
- **Inferno = ~2.9k★，iOS17/macOS14，Paul Hudson** — [twostraws/Inferno](https://github.com/twostraws/Inferno) + [README](https://github.com/twostraws/Inferno/blob/main/README.md)。→ C26 水波 adopt 新鲜可行（与 lens5 2879★ 一致）。
- **matchedGeometryEffect 在 LazyVGrid multiple-source 运行时冲突 + 懒渲染源未挂载**（lens6 引）— [Apple Forums #669115](https://developer.apple.com/forums/thread/669115)（lens6 二手引，已与官方 docs 行为一致）→ 坐实 C22「用 Grid 非 LazyVGrid」的工程动机。

## 反对 / 更好 / 漏洞（逐候选有问题的）

- **C1**（开场 reveal 扫一遍）：reveal 动画 = 10 卡依次浮现，但 lens6 T3 明示「条件插入/adaptive 列数变化触发整网格 reflow 跳位」。若 reveal 用 opacity 渐入（卡位固定）可行；若用插入式浮现则踩坑。候选未指明实现方式 → **漏洞：reveal 的实现形态决定可行性，没说清**。Leverage 偏低（开场观感细节，非结构决策）。
- **C3**（dim 族保持极弱呼吸微光 + "全部展示"彩蛋）：10 族同时跑无限 breathe 动画 = 10 个常驻 TimelineView/repeatForever，**GPU 常驻负载 + 与 mlx 抢 GPU**（C13 自己点的坑）。**反对：dim 族应「静态色」不应「呼吸」**，呼吸留给 satisfied 态。彩蛋是噱头，Leverage 低。
- **C5** ≈ C1：「全景常驻 + 触发聚焦」是 C1（开场序列）的结构母决策，两者应合并为一条「主视图形态 = Form A」。**Non-duplication 扣分**。
- **C6**（语音为主 tap 为辅同一入口）：现状 `FastPathIntentEngine` 只 1 意图、无 ASR，「语音为主」目前 100% 不可演。**漏洞：把「展开触发=语音」当 UI 决策，但它依赖整条 ASR→意图链路（C5 LoRA 还没好）**——这是把后端依赖伪装成前端决策。tap 为辅倒是立刻能做。
- **C8**（3-4 高频子 device 按线上优先级）：`state-cells.yaml` 只有 4 族数据、且「线上优先级」字段不存在于契约（无 priority 字段）。**漏洞：依赖一个尚不存在的数据维度**。
- **C9**（同时只展开 1 族）：是 C5/C7 的直接推论（聚焦即单族），独立性弱。
- **C10**（折叠不平铺 191 + 角标显子能力数）：方向对（191 平铺=灾难，lens7 elephant 坐实）。但「角标显子能力数」需要每族 device 计数=又依赖 10 族契约补全。可行但有数据前置。
- **C11**（value.type enum+switch 从 state-cells 派生）：架构正确（编译穷尽优于 AnyView）。**漏洞：state-cells 现 4 族 + 双套 key 命名（DemoVehicleStateStore vs state-cells.yaml 不一致），派生前必须先统一口径**——候选措辞像数据已就绪。
- **C12**（座椅多维/RGB 自建、其余原生）：可行性最强候选之一。Gauge/ColorPicker iOS16 门下原生；座椅 7 级分段 + 按摩 toggle 用 VStack 组合即可。**更好：RGB 优先 native `ColorPicker(supportsOpacity:false)`（两行），色环只在要审美时才自建**（lens7 paper-tiger）。
- **C13**（shader 仅氛围层 + GPU 错峰互斥）：约束正确，但「GPU 协调器」在 SwiftUI 无现成原语，需自建「推理中→暂停 TimelineView(.animation) 自驱」调度。**漏洞：低估了错峰互斥的实现成本**（不是一个 flag）。
- **C14**（卡片骨架统一只变值区）：正确（lens6 E3 + 飞书白皮书一致性教训）。可直接 `FamilyCard<ValueView>` 泛型实现（ShipSwift SWKPICard 范式）。低风险高价值。
- **C15** ≈ C11：「enum+switch 非 AnyView」是 C11 的实现手段，应并入 C11。**Non-duplication 扣分**。
- **C16-C20**（双屏五连）：**严重重复**。C4=双实例架构、C16=iPhone 独立全功能、C17=Bonjour LAN、C18=竖屏布局+独立 ASR、C19=无断连概念、C20=不极简。工程上 = 一条决策（两个 app target 共享 Core + 可选 Bonjour）。**建议合并为 C4+C17+C18 三条**（架构/联动方式/竖屏布局），C16/C19/C20 是同义重述。**漏洞 C18：iPhone 独立 ASR = 现状 0（无 ASR 代码），且 iPhone 跑 Qwen3-1.7B+ASR+TTS 的端侧内存/热（8GB iPhone）是真约束，候选当作已解决**。
- **C21**（matchedGeometry 不用跨栈 zoom）：**最强可行性决策**。联网坐实 macOS 上 zoom transition 编译级 unavailable → Mac 主舞台只能用 matchedGeometry，候选选对了。**唯一补充：matchedGeometry 在 Grid（非 LazyVGrid）里才稳**（与 C22 联动），单独看 C21 没点出「容器必须是 Grid」。
- **C22**（Grid 非 LazyVGrid 规避懒渲染）：正确且联网坐实（Grid 一次性渲染全部 = 无懒渲染源未挂载冲突）。**更好：10 族固定集合本就该用 Grid + GridRow**，性能上 10 卡远低于 lazy 拐点（lens6 PT1）。零顾虑。
- **C23**（matchedGeometry 不可用时 opacityScale 兜底）：防御正确。但 matchedGeometry 是 iOS14、**永远可用**——「不可用」场景实际是 ReduceMotion（matchedGeometry 不自动 fallback，需手给 opacity 交叉淡入，lens6 T7）。**漏洞：候选把「不可用」归因错了**（不是 API 缺失，是 ReduceMotion 不自动降级）；但兜底方案本身对。
- **C24**（320ms/220ms 两参数）：具体数字是经验拍的，可行但 Leverage 在「两个独立参数防竞态」这个洞察，数字本身可调。低风险。
- **C25**（默认 opacityScale，matchedGeometry 编译验证后才升级）：稳健的渐进升级门。与 C21/C23 是同一主题的收口，独立性中等。
- **C26**（MeshGradient + ripple + Sinebow，每个必 fallback）：联网坐实 MeshGradient=iOS18 必 fallback。**正确且必须**。**漏洞：orb 第三方 repo 全 stale（metasidd/Orb 422★ 但 2024-11，lens6 已标淘汰）→ 自建 MeshGradient+TimelineView 是对的，候选没说清"自建"还是"adopt"**。
- **C27**（4 段 wow sequencer + 合同回放）：编排价值高。**漏洞：「sequencer + 合同回放」是项目自造层，无现成 repo**，且断网高潮 morph 段依赖 C29；4 段串联的状态机复杂度被低估。Verifiability 偏低（"合同回放"是项目内造概念，外部不可核）。
- **C28**（视觉先于/同步 TTS + immediate ack）：**联网坐实最强风险揭示**。AVSpeechSynthesizer didCancel iOS15+ 不触发 + 锁死 bug → 「状态在调用点改、视觉不等 TTS」是唯一正解。现状 `SpeechSynthesisEngine` 裸 speak 正等着踩这坑。高价值。
- **C29**（在线→离线 morph + 端侧徽章）：color morph 简单（cyan→amber withAnimation），tokens 已有 `state.offline #ffb13c`。可行。**漏洞：「全族卡断网保持响应」依赖整条端侧链路真离线可跑（Qwen+ASR 全本地），这是后端事实不是 UI 决策**——UI 只负责展示徽章。
- **C30**（稳定优先 + 错峰 + ReduceMotion/低电量双通道 + thermal watchdog）：**最高 Leverage + Risk Revelation**。北极星=不崩，这条把「炸场 vs 稳」的取舍拍死，且双通道/thermal 是 lens6 T1/T7 的硬约束收口。**漏洞：thermal watchdog（`ProcessInfo.thermalState`）+ 低电量（`isLowPowerModeEnabled`，iPhone-only，Mac 永返 false）需真机分别测**——Mac 主舞台不吃低电量但吃 ReduceMotion/thermal，候选没区分平台。

## 你这视角（可行性）top 5 最该关注候选

1. **C30**（稳定优先 + 双通道 + thermal watchdog）— 直击北极星「不崩」；锁定炸场 vs 稳的取舍；揭露 thermal/低电量/ReduceMotion 三开关的平台差异风险。Leverage 与 Risk Revelation 双满。
2. **C21**（matchedGeometry 不用跨栈 zoom）— 联网坐实 macOS 上 zoom transition **编译级 unavailable**，Mac 主舞台**唯一可行解**。可行性证据最硬。
3. **C28**（视觉先于 TTS + immediate ack）— 联网坐实 AVSpeechSynthesizer barge-in 的 didCancel 不触发 + 锁死 bug；现状裸 speak 正待踩坑；端侧首音延迟掩盖是 demo「反应快」的命门。
4. **C26**（shader 选型每个必 fallback）— MeshGradient iOS18 必守卫（部署 iOS17）；orb 第三方全 stale 须自建；GPU 与 mlx 抢占。可行性 + 风险揭示双高。
5. **C12 / C2 平手**：C12（异构控件原生优先、缺口自建）是可行性最干净的实现决策（Gauge/ColorPicker 均 iOS16 门下原生）；C2（多意图序列化高亮）低成本高 wow 且规避 reflow + 注意力溢出双坑。

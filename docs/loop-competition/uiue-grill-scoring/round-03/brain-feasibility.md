## Round 3 可行性视角盲评 — MAformac UIUE 30 决策

> 盲评：未读 grill-decisions / d1-d6-grill。本地核 = ContentView.swift / DemoVehicleStateStore.swift / state-cells.yaml / tokens.md / hig-rules.md / scheme1.html / lens1-7 + Package.swift / capabilities.yaml / l1-demo-allowlist.yaml。联网核 = SwiftUI API 版本 + matchedGeometry/LazyVGrid 坑 + HMI 动效时长。
> **可行性视角核心发现（一句话）**：现状代码 = 22 卡平铺 LazyVGrid walking skeleton（`ContentView.swift:40`），**30 个决策无一落地**；语音输入(ASR)全无、networking 全无、Grid/Gauge/matchedGeometry/MeshGradient/glassEffect 全无。这意味着每个决策的「可行性」= 从零实现的成本 + 与现状骨架的 gap，而不是「改现有实现」。

## 30 候选评分表（C1-C30 × 5 维 + Total，满分 25）

| ID | Importance | Verifiability | Non-dup | Decision Lev | Risk Reveal | **Total** | verdict |
|---|---|---|---|---|---|---|---|
| C1 | 3 | 4 | 4 | 3 | 2 | **16** | keep |
| C2 | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C3 | 2 | 3 | 3 | 2 | 2 | **12** | weak |
| C4 | 4 | 5 | 3 | 4 | 4 | **20** | keep |
| C5 | 5 | 5 | 3 | 4 | 5 | **22** | keep |
| C6 | 4 | 4 | 4 | 4 | 4 | **20** | keep |
| C7 | 4 | 5 | 3 | 3 | 4 | **19** | keep |
| C8 | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C9 | 3 | 4 | 2 | 3 | 3 | **15** | weak |
| C10 | 4 | 4 | 3 | 4 | 4 | **19** | keep |
| C11 | 4 | 5 | 4 | 4 | 3 | **20** | keep |
| C12 | 5 | 5 | 4 | 4 | 4 | **22** | keep |
| C13 | 4 | 3 | 4 | 3 | 4 | **18** | keep |
| C14 | 4 | 5 | 4 | 4 | 4 | **21** | keep |
| C15 | 3 | 5 | 2 | 3 | 2 | **15** | weak |
| C16 | 3 | 4 | 2 | 3 | 3 | **15** | weak |
| C17 | 4 | 5 | 3 | 4 | 4 | **20** | keep |
| C18 | 4 | 5 | 4 | 4 | 3 | **20** | keep |
| C19 | 2 | 3 | 1 | 2 | 2 | **10** | better-exists |
| C20 | 2 | 3 | 1 | 2 | 2 | **10** | better-exists |
| C21 | 5 | 5 | 5 | 5 | 5 | **25** | keep |
| C22 | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C23 | 4 | 5 | 4 | 4 | 4 | **21** | keep |
| C24 | 3 | 4 | 4 | 3 | 3 | **17** | keep |
| C25 | 4 | 5 | 3 | 4 | 4 | **20** | keep |
| C26 | 4 | 5 | 3 | 4 | 4 | **20** | keep |
| C27 | 3 | 3 | 3 | 3 | 3 | **15** | weak |
| C28 | 4 | 4 | 4 | 4 | 4 | **20** | keep |
| C29 | 4 | 5 | 4 | 3 | 4 | **20** | keep |
| C30 | 5 | 4 | 4 | 4 | 5 | **22** | keep |

## 视角专项发现（可行性 / 实现成本 / 端侧约束）

1. **30 决策全是 forward-looking，零实现。** `ContentView.swift` 全文 136 行 = TextField + 22 卡 `LazyVGrid(.adaptive(minimum:160))` + trace panel。无 Grid / Gauge / matchedGeometry / MeshGradient / glassEffect / 任何动效（grep 全仓 swift 仅 `ContentView.swift:40` 一处 LazyVGrid）。**可行性维度上，每个决策的真实成本是「新写」不是「改」**——这点提案集没有任何一条点破，是集体盲区。

2. **数据契约严重落后于 UI 提案，是最大可行性风险。** 提案默认存在「10 族 × 191 device × 优先级排序」，但：
   - `state-cells.yaml` 只实现 **4 族**（air_conditioner/window/screen/ambient_light）+ safety；座椅/车门/音量/雨刮/天窗/香氛 6 族**在 state-cells 中根本不存在 cell**。
   - `DemoVehicleStateStore.defaultCells()` 只有 **22 个硬编码 cell**，不是 191。191 只是 `capabilities.yaml:10` 的契约元数据注释，**没有可消费的端态数据结构**。
   - **无 priority / scope_tier / frequency / popular 字段**（grep state-cells + l1-allowlist 全空）。→ C8「按线上优先级显 3-4 高频子 device」、C10「角标显子能力数」**所依赖的数据字段不存在**，必须先补 schema 或现场手挑。这是 C8/C10 的硬伤也是它们的价值（揭示缺口）。

3. **iOS17/macOS14 部署是真约束（`Package.swift:8-9`），所有 iOS18+ API 必须 #available。** 联网坐实：MeshGradient=iOS18 / matchedTransitionSource+navigationTransition.zoom=iOS18 / glassEffect=iOS26 → C26/C21/tokens.md 的 fallback 要求全部成立。**Gauge=iOS16 / Grid=iOS16 / matchedGeometryEffect=iOS14** → C12/C22/C21 在 iOS17 部署下**无需守卫即可用**，这是它们可行性高的关键。

4. **C21+C22+C23 是技术上最严谨的一组，且互相咬合。** 联网双重坐实：① `navigationTransition(.zoom)` 的 `ZoomNavigationTransition` 类型在 **macOS 不可用**（Apple Forums / createwithswift），Mac 主舞台被迫只能用 matchedGeometryEffect → C21 拒绝跨栈 zoom 是**被 macOS 逼出来的正确选择**，不是偏好；② matchedGeometryEffect 在 LazyVGrid 有 multiple-source 运行时冲突 + 懒渲染源未挂载 bug（Apple Forums #669115）→ C22 用非 lazy `Grid`（10 族固定集合全 cell 挂载）**精确规避**这个坑；③ C23 兜底动画是对 C21 残余风险的诚实对冲。这三条是全集里 file:line + URL 证据最硬的。

5. **语音输入(ASR)零代码，C6/C18 的「接语音」依赖 DEFERRED 后端。** `Core/Voice/` 只有 `SpeechSynthesisEngine`（TTS，AVSpeechSynthesizer 已实装可用）；**无 SFSpeechRecognizer / 任何 ASR**（grep Recogni/SFSpeech/ASR 全仓 swift 为空）。→ C28 的 TTS 时序claim 有代码基础（AVSpeechSynthesizer 在 `SpeechSynthesisEngine.swift:8`）；但 C6「语音为主展开」、C18「iPhone 接语音独立 ASR」的语音入口**当前不可跑，只能 mock/按钮触发**（与 scheme1.html 一致——它用按钮模拟说话）。这是 C6/C18 的隐藏依赖风险。

6. **C4/C17/C19/C20 的双屏 LAN 联动零代码且高成本。** grep Bonjour/NWBrowser/Multipeer/NWPath 全仓为空。C4/C17 把 LAN 标「可选加分」是**正确的可行性对冲**（两个独立 demo 实例各自全功能，联动不做也不丢炸场）；但 C19/C20 几乎只是 C4 的换句话重复（见漏洞段）。

## 本地核证据（file:line）

- `App/ContentView.swift:40` = `LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)])` — 现状唯一布局，无 max（lens6 Tiger3 已标 resize reflow 坑）；喂 `store.cells`（22 个 device 平铺，非 10 族）。
- `App/ContentView.swift:121-127` — `background`/`borderColor` 把 visualState 压成 **satisfied=绿 / 其余=灰** 二值，**7 态全塌成 2 态**（tokens.md:64 已标这是 U10 头号翻车点）→ 印证 C2/C11/C14 的「值/态可视化」是真缺口。
- `Core/State/DemoVehicleStateStore.swift:134-159` `defaultCells()` = 22 个硬编码 cell；`DemoVisualState`(`:17-25`) 已有 7 态枚举但 UI 没消费。
- `contracts/state-cells.yaml` — 仅 4 族 devices（`:40 air_conditioner / :87 window / :121 screen / :139 ambient_light`）+ safety_cells（`:171`），**无 priority/scope_tier 字段**。
- `contracts/l1-demo-allowlist.yaml` — device+primitive 粒度，**无 frequency/priority**；C8/C10 所需排序字段不存在。
- `Core/Voice/SpeechSynthesisEngine.swift:8` `AVSpeechSynthesisEngine`（TTS 已实装）；**无 ASR**。
- `App/MAformacApp.swift:7` 注入 `AVSpeechSynthesisEngine`；无 networking、无 ASR、无 store 外的实例。
- `Package.swift:8-9` `.iOS(.v17), .macOS(.v14)` — 部署底线（决定 #available 需求）。
- `contracts/capabilities.yaml:10-11` — 「191 device / 562 intent / 562=intent 非工具数」（191 是元数据注释，非可消费数据结构）。
- `docs/design/tokens.md:64` + `hig-liquid-glass-rules.md:19` — U2/U10/U11/U19 已锁（关系到 C11/C26/C30 的 Non-dup）。
- lens6 `lens6-pitfalls.md:23-29`（Tiger2 matchedGeometry+macOS zoom unavailable）/ `:31-36`（Tiger3 adaptive reflow，baseline 已踩）/ `:107-108`（建议用固定 Grid）— 直接支撑 C21/C22/C23。
- lens4 `lens4-swift-components.md:22,44`（matchedTransitionSource iOS18 + macOS gap）/ `:25-31`（Gauge accessoryCircular iOS16）— 支撑 C12/C21。
- lens1 `lens1-local-hardware.md:74`（CompactSlider 550★ 但 ~7月 stale，FAILS 60天门）/ `:36`（10 族用静态 Grid 优于 Lazy）— 支撑 C12 自写 + C22。

## 联网核证据（URL + 日期，2026-06-23 检索）

- navigationTransition.zoom / matchedTransitionSource = iOS18+，**ZoomNavigationTransition 在 macOS 不可用**（macOS15 只有 NavigationTransition 协议）：https://developer.apple.com/documentation/swiftui/navigationtransition ; https://www.createwithswift.com/using-the-zoom-navigation-transition-in-swiftui/ ; https://github.com/hmlongco/Navigator/issues/25 → **支撑 C21 verdict=keep（25/25）**。
- MeshGradient = iOS18 / macOS15+（需 #available + LinearGradient fallback）：https://developer.apple.com/documentation/swiftui/meshgradient → **支撑 C26 fallback 要求**。
- Gauge = iOS16（accessoryCircular/accessoryCircularCapacity）/ Grid = iOS16（非 lazy，全 cell 挂载）/ matchedGeometryEffect = iOS14：https://developer.apple.com/documentation/swiftui/gauge ; https://developer.apple.com/documentation/swiftui/grid ; https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:) → **C12/C22/C21 在 iOS17 部署下无需守卫**。
- matchedGeometryEffect 在 LazyVGrid：multiple-source 运行时警告 + 懒渲染源 off-screen 被销毁断匹配 + modifier 顺序（必须在 .frame 之前）：https://developer.apple.com/forums/thread/669115 ; https://swiftui-lab.com/matchedgeometryeffect-part2/ ; https://www.typesafely.co.uk/p/use-matchedgeometryeffect-to-view → **支撑 C22 用 Grid 规避**。
- 车机/UI 动效时长：layout 动画 200-350ms 是甜区（<feel jumpy, >feel sluggish）；标准转场 200-300ms；hero/大位移可至 400-500ms；**「可中断」比缩短时长更影响感知响应**；Model Human Processor 视觉感知 ~230ms：https://www.equal.design/blog/5-rules-for-motion-in-ui-transitions ; https://www.nngroup.com/articles/animation-duration/ → **C24 的 320ms 落在甜区、220ms stagger 合理；但漏了「可中断」这个更重要的参数（见漏洞）**。

## 反对 / 更好方案 / 漏洞（逐候选）

- **C19 / C20（better-exists，10/25）**：实质与 C4 重复。「iPhone 独立无断连概念」「iPhone 是独立全功能 demo」= C4「两个独立纯端侧实例」的同义改写，无新增技术承诺、无新风险、无新数据。C4 已用「双屏 LAN 可选加分」覆盖断连/定位。建议合并进 C4，单独成条是决策疲劳。Verifiability 也低（纯定性表述，无可证伪的实现点）。

- **C8（hard-fact 揭示，23/25）**：依赖的「线上优先级」字段**经核不存在**（state-cells + l1-allowlist 全无 priority）。这是硬伤但**正是它的价值**——逼出「优先级数据从哪来」的承诺。更好方案：现场 demo 不需要真优先级，直接「按 capabilities.yaml 族内 device 出现顺序取前 3-4 + 现场只说约定子集」（demo 取巧），比补一套 priority schema 便宜得多。下轮该拍：补 `scope_tier`/`high_freq` 字段 vs 现场手挑硬编码。

- **C10（折叠形态对，角标数据缺口，19/25）**：「角标显子能力数」需要每族 device 计数。现状 `state-cells.yaml` 只有 4 族有 cell，**6 族角标会显 0 或缺失**。fallback 应明确：角标数 = `capabilities.yaml` 族内 device 计数（契约元数据，191 来源），不是 state_cells.count（state store 只有 22）。漏洞：提案没说角标数据源，会踩「state 没数据→角标 0」。

- **C13（机制对，数字无源，18/25）**：「GPU 协调器与模型推理错峰互斥」机制正确（lens1 F8/F9 + hig-rules:51 layerEffect 与 mlx 抢 GPU），但 lens 里没有任何「掉 50% 吞吐」的实测数字来源——是 hig-rules:51 的 prose 估算（README:91 引）。**lens1 F9 实测 M5 GPU 渲染 10-30 卡是零压力**，瓶颈在显示侧不在算力侧。→ C13 把「shader 错峰」当 HIGH 风险可能过度；真风险是 banding/可读性（lens1 F3）。建议：错峰互斥保留为工程纪律，但「50% 吞吐」这类数字若进文档必须标 ESTIMATE 或 A2 Instruments 实测，否则是魔法数字。

- **C24（双参数结构洞察对，魔法数字风险，17/25）**：320ms/220ms 落在甜区（联网坐实），**比 Round2 担心的「魔法数字」更站得住**。但真漏洞是：联网证据强调**「可中断性比时长更影响感知响应」**——语音驱动 demo 里多意图连续触发，若 320ms 展开不可被下一句指令打断，会比 220ms 不可断更慢。C24 只锁了时长两参数，漏了「转场可中断」这个对 demo「反应快」北极星更关键的参数。建议数字进 tokens.md `motion.*` 单源 + 加「interruptible」约束。

- **C26（fallback 要求对，Sinebow 来源弱，20/25）**：MeshGradient/ripple 必有 fallback 已坐实正确。但「氛围灯 Sinebow」无 lens 来源（lens7 给的是 ColorPicker/色环，不是 Sinebow shader）；ripple 用 twostraws/Inferno（hig-rules:64 已锁 U5）。漏洞：三个 shader 的具体选型只有 ripple 有 repo 依据，orb=MeshGradient（原生）OK，氛围灯 Sinebow 是凭空命名，需落到具体 shader 实现。

- **C27（wow 编排，可行性偏虚，15/25）**：「sequencer + 合同回放」是好工程纪律（确定性炸场，可复现），但**现状零代码**且「断网高潮 morph」依赖 networking 状态（无 NWPath monitor，scheme1 用 JS toggle 模拟）。C29 已覆盖断网视觉，C27 的「4 段序列」与 lens7 F2「炸场 6 步」高度重叠（Non-dup 偏低）。

- **C6（语音入口隐藏依赖，20/25）**：「语音为主展开」当前**不可跑**（无 ASR）。「两路走同一入口」是好架构（语音和 tap 都产生 ToolCall→同一 reduce），可行性高；但「语音为主」在 A2/当前阶段只能 mock。建议明确：UI 入口设计成「ToolCall 驱动」（与触发源解耦），ASR 是 DEFERRED 的一个 ToolCall 产生器，这样 C6 的架构在无 ASR 时也成立。

- **C12（控件缺口判断准，CompactSlider 别引，22/25）**：座椅多维/RGB 自建 + 其余原生 Gauge/分段/toggle = 准确的 build/adopt 切分。漏洞修正：lens1 F10/lens7 F1 提的 CompactSlider 550★ 但 **~7月 stale 失 60天新鲜度门**——C12 说「其余用原生」是对的，**别引 CompactSlider**，自写 ~30 行 Slider/Stepper。座椅 7 级分段可参考 Inxel/CustomizableSegmentedControl（star/日期 lens 标待核，未坐实，按盲评不背书）。

- **C5（全景常驻对，但与现状 gap 最大，22/25）**：方向正确（lens1-7 五路独立收敛到「全景常驻+触发聚焦」）。但现状是 22 卡平铺，离「10 族 dim 网格」要先做信息架构重构（喂 10 族 family card 而非 22 device，lens1 F13 已指）。这是 C5 的隐藏成本：不只是布局，是把数据从 device 粒度聚合到族粒度——而 6 族 state cell 都还没建。

- **C30（稳定优先对，且揭示最大风险，22/25）**：「稳定>炸场」+ thermal watchdog + 双通道是全集最重要的工程纪律之一（demo 北极星「不崩」）。漏洞：thermal watchdog 在 Mac 上 `ProcessInfo.thermalState` 可用，但低电量 `isLowPowerModeEnabled` **Mac 永远返回 false**（lens6 Tiger7 坐实，iPhone 专属）——C30 说「低电量双通道」在 Mac 主舞台不触发，要分平台说清，否则误以为 Mac 也吃 LPM 降级。

## 你这视角 top 5 最该关注候选

1. **C21（25/25）** — 全集技术最严谨。macOS 无 zoom transition 退路 + LazyVGrid matchedGeometry 冲突双重坐实，拒绝跨栈 zoom 是被平台逼出的正解，不是偏好。可直接进 A2 实现。
2. **C8（23/25）** — 揭示最硬的数据缺口：priority 字段经核**完全不存在**，6 族 state cell 都没建。逼出「优先级数据源 / 现场手挑」的承诺，是可行性视角下最有杠杆的一条。
3. **C22（23/25）** — 用非 lazy `Grid`（iOS16，10 族全 cell 挂载）精确规避 LazyVGrid 懒渲染源未挂载的 matchedGeometry bug（Apple Forums #669115 坐实）。与现状 `LazyVGrid:40` 的直接替换路径，可行性极高。
4. **C2（23/25）** — 多意图序列化高亮（lens6 E2 Single-Item-Template 坐实「注意力只能追一个」）。现状二值态（`ContentView.swift:122`）完全没有联动/序列化能力，是最该补的交互。揭示「多卡同时闪=丢脸」失败路径。
5. **C30（22/25）** — 稳定优先 + thermal watchdog + 双通道，直击「不崩」北极星，且揭示 Mac/iPhone 平台差异（LPM Mac 恒 false）这个易漏风险。是炸场 vs 稳的总闸。
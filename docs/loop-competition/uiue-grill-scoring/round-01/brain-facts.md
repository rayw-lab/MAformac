
# Round 1 盲评 · 事实核视角 · MAformac UIUE 30 决策

> 评审人 = 事实核视角（每决策依赖的外部事实是否真实：SwiftUI API 版本可用性 / 车机 HMI 范式 / 组件 star+活跃度 / 平台行为坑）。本地核 + 联网核全做，每条 load-bearing 事实带 URL+日期（2026-06-23/24 检索）。盲评：未读 grill SSOT / uiue-d1-d6，独立从零判断。

## 30 候选评分表（C1-C30 × 5 维 + Total，满分 25）

| ID | Importance | Verifiability | Non-dup | Decision Leverage | Risk Revelation | Total | verdict |
|---|---|---|---|---|---|---|---|
| C1 | 3 | 4 | 4 | 3 | 2 | **16** | keep |
| C2 | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C3 | 2 | 3 | 3 | 2 | 2 | **12** | weak |
| C4 | 5 | 4 | 3 | 5 | 4 | **21** | keep |
| C5 | 5 | 5 | 3 | 4 | 4 | **21** | keep |
| C6 | 4 | 4 | 4 | 4 | 3 | **19** | keep |
| C7 | 4 | 5 | 4 | 3 | 4 | **20** | keep |
| C8 | 3 | 3 | 4 | 3 | 3 | **16** | keep |
| C9 | 3 | 4 | 3 | 3 | 3 | **16** | weak |
| C10 | 4 | 5 | 4 | 4 | 4 | **21** | keep |
| C11 | 4 | 5 | 4 | 4 | 3 | **20** | keep |
| C12 | 5 | 5 | 4 | 4 | 4 | **22** | keep |
| C13 | 4 | 4 | 4 | 4 | 5 | **21** | keep |
| C14 | 4 | 5 | 3 | 4 | 4 | **20** | keep |
| C15 | 3 | 5 | 2 | 3 | 3 | **16** | weak (与 C11 重) |
| C16 | 3 | 4 | 2 | 3 | 3 | **15** | weak (与 C4/C20 重) |
| C17 | 4 | 5 | 4 | 4 | 5 | **22** | keep |
| C18 | 4 | 5 | 3 | 4 | 4 | **20** | keep |
| C19 | 2 | 3 | 1 | 2 | 2 | **10** | reject (与 C4/C20 重) |
| C20 | 2 | 3 | 1 | 2 | 2 | **10** | reject (与 C4/C16 重) |
| C21 | 5 | 5 | 4 | 5 | 5 | **24** | keep |
| C22 | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C23 | 4 | 4 | 4 | 4 | 4 | **20** | keep |
| C24 | 3 | 4 | 3 | 4 | 3 | **17** | keep |
| C25 | 4 | 4 | 3 | 5 | 4 | **20** | keep |
| C26 | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C27 | 4 | 4 | 4 | 4 | 3 | **19** | keep |
| C28 | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C29 | 4 | 4 | 4 | 3 | 3 | **18** | keep |
| C30 | 5 | 5 | 4 | 5 | 5 | **24** | keep |

## 视角专项发现（事实核）

**核心结论：30 个决策依赖的外部技术事实，绝大多数我独立联网核对后【真实】。** 这批决策的事实底子很硬——不是凭知识库拍的，几乎每条 API 版本/组件活跃度/平台坑都能在官方文档或权威 issue 坐实。这与项目锁定的 lens 调研（docs/research/2026-06-23-uiue-10family-presentation/）一致。但有几处需要 surface 的事实风险：

1. **API 版本可用性 vs 部署目标的张力是真实且 load-bearing 的。** Package.swift 锁 `iOS17 / macOS14`（本地核），但工具链 SDK = `macosx26.0`（本地 `swift --version`）。这意味着 **设计用 iOS26 特性、部署到 iOS17** 是真约束。我逐一核实涉及的 API 版本边界：
   - MeshGradient（C26 orb）= **iOS18 / macOS15**（低于部署目标 → 必须 `#available` + fallback）。
   - glassEffect / Liquid Glass（C26、HIG）= **iOS26 / Xcode26 ONLY，不守卫直接不编译**。
   - matchedTransitionSource / `.zoom` navigationTransition（C21）= **iOS18，且 `.zoom` 在 macOS 标 unavailable**。
   - matchedGeometryEffect（C21）= iOS14 / macOS11（安全，风险是行为非 API）。
   - Gauge `.accessoryCircular`（C12）= iOS16 / macOS13（**低于部署目标，免守卫**）。
   - 静态 `Grid`（C22）= iOS16 / macOS13（**免守卫，C22 切 Grid 在 API 层安全**）。
   - → **C26「每个 shader 必有低版本 fallback」、C25「#available 升级门」是事实正确且必要的**，不是过度防御。

2. **C21 的「用 matchedGeometryEffect 不用 zoom」在 Mac 主舞台是【事实强制】不是偏好。** 联网核实：`ZoomNavigationTransition` 在 macOS SDK 标 unavailable（createwithswift / theswift.dev / hmlongco/Navigator #25 三源一致）。Mac 主舞台想要 hero zoom 只能 matchedGeometryEffect。但这也撞上 lens6 的 HIGH 坑（matchedGeometry 在 LazyVGrid 里 multiple-source 冲突 + 懒渲染源未挂载）。**C21+C22+C23 三条必须捆绑读**：C22 改 Grid（非 LazyVGrid）正是为了规避 C21 的懒渲染冲突。这是一组逻辑自洽的工程链，事实底子硬。

3. **C28 的「首音延迟」是被官方 FB 坐实的真 bug，且当前代码未缓解。** 联网核：AVSpeechSynthesizer `speak()`→`didStart` 有 0.6-1s+ 延迟（Apple Forums #731238 FB11380447，iOS16 后出现，切换 voice/language 加剧）。本地核：`Core/Voice/SpeechSynthesisEngine.swift` 当前每次 `speak` 都 set `zh-CN` voice、**无 pre-warming**、无 AVAudioSession 预激活 → C28 的「immediate ack 掩盖首音延迟 + 视觉先于 TTS」是对真实痛点的正确处方，且 surface 了一个代码现状缺口。

4. **C13/C30「shader 与 mlx 推理错峰互斥」的事实底子可核但量化未核。** lens 称 `.layerEffect` 与 mlx 抢 GPU 掉 ~50% 吞吐——这是个 load-bearing 量化断言，我**未能独立核到「掉 50%」的一手来源**（lens 自己也标 README:45 为内部 pre-mortem 论点）。glassEffect 每实例需 3 个 offscreen texture 是 Apple 文档坐实的（juniperphoton / Apple docs）。→ 「错峰」方向正确，但「50%」是未核的设计经验值，A2 实装时应 Instruments 实测。

5. **投屏 8bit banding 是多候选隐含依赖的真事实。** C29/C30 隐含「深空暗底在投屏会出问题」——联网核坐实：8bit 暗部色阶最少 + 高对比投影/激光投影让 banding 更糟（反直觉）+ AirPlay 实时压缩进一步劣化 + dither/IGN 是唯一解（blurbusters / KTC / frost.kiwi 三源）。这是与磊哥飞书白皮书「暗底丑/看不清」同源的真炸雷。**但 30 个候选里没有一个把「投屏 banding + 有线 HDMI 兜底 + IGN dither」立成独立决策**——这是 C26/C30 应吸收但目前散落的事实风险（见漏洞段）。

6. **车机 HMI 范式（C2/C5/C24）有真实标杆背书。** MBUX「Zero Layer 常驻 + AI 浮现」、Polestar4 气候常驻 strip、理想 L 型分区——lens2 已逐条带官方 URL；C5「全景常驻 + 触发聚焦」= MBUX Zero Layer 的直译，C2/C24「序列化高亮非同时闪」= Single-Item-Template 视觉注意力假说（bioRxiv）+ 车载 VUI 研究。事实方向正确。**唯一提醒：Single-Item-Template 是认知科学论点（设计经验）非工程硬数字**，C24 的「220ms/320ms」具体数值是拍的，没有外部一手支撑（合理但应标 reviewed-value）。

## 本地核证据（file:line）

- **`App/ContentView.swift:40`** = `LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)]...)` —— 现状用 LazyVGrid + adaptive 无 max + minimum 160 太小，**直接证伪 C22「应该用 Grid」尚未落地**（现状与 C22 相反），且喂的是 22 个 device 平铺非 10 族（粒度错）。
- **`App/ContentView.swift:122,125-127`** = `cell.visualState == .satisfied ? Color.green.opacity(0.18) : Color.gray.opacity(0.10)` + border 同理 —— **把 7 态压成绿/灰二值**，证实 C11/C14 要解决的真 bug（DemoVisualState 有 7 态，UI 只消费 2 态）。tokens.md:64 与 hig-rules U10 都点名此行为翻车点。
- **`Core/State/DemoVehicleStateStore.swift:17-25`** = `DemoVisualState` 7 态枚举（normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown）—— C11「value.type 统一 enum+switch」+ tokens 7 态色映射的消费源，确实存在 7 态。
- **`Core/State/DemoVehicleStateStore.swift:134-158`** `defaultCells()` —— **存在重复/不一致 cell**：同时有 `ac.power`+`hvac.ac`、`ac.temp_setpoint[主驾]`+`hvac.temperature`、`window.position[主驾]`+`window.driver`、`screen.brightness[中控屏]`+`screen.brightness`、`ambient.brightness[...]`+`lighting.ambient`。两套 key 命名并存（C1/C2 契约 key vs ContentView title switch 的旧 key）→ **UI 数据源本身有 drift，C11「从 state-cells 数据派生」会撞这个不一致**（C11 的隐藏前置）。
- **`contracts/state-cells.yaml:9-15`** = surface 边界注释明确「model-visible = D-domain 具名工具，canonical IR = device×action，state cell 不随 surface 变」—— C11「从 state-cells 派生值分发」的契约依据成立。
- **`contracts/state-cells.yaml:60,80,96,130,156`** = execution_range（温度18-32/风量1-10/车窗0-100%/屏幕0-100%/氛围灯0-100%）—— C11/C12「连续值/档位/百分比」分类的一手数据源，异构值真实存在。
- **`prototypes/scheme1-deep-space-interactive.html:113-120`** = grid2 固定 2 列、**只 6 张卡片**（空调/座椅/车窗/风量/氛围灯/音乐，含"音乐"不在 10 族！）—— 证实 lens 的「scheme1 撑不住 10 族」+ **原型卡片集与 10 族定义不一致（有音乐、缺车门/灯光以外的屏幕/雨刮/天窗/香氛）**。C5/C8 要解决的真缺口。
- **`prototypes/scheme1-deep-space-interactive.html:43`** = `.card{...backdrop-filter:blur(8px)}` —— **内容卡用了 blur 玻璃**，与 HIG rules「内容卡 content_glow 不用 system glass」矛盾（原型阶段，C 系列要纠正）。
- **`docs/design/tokens.md:39`** U11 halation 硬约束 + **`tokens.md:59-62`** 四态色分开（clarify琥珀/unsupported灰/safety红/crash灰）—— C11/C29 的色彩事实依据。
- **`Package.swift:7-9`** = `.iOS(.v17), .macOS(.v14)` —— C21-C26 #available 论证的部署目标一手依据。
- **`Core/Voice/SpeechSynthesisEngine.swift`** = `AVSpeechSynthesisVoice(language:"zh-CN")` 每次重设、无 pre-warm —— C28 首音延迟缓解未落地的代码现状。
- **`contracts/demo-scenarios.yaml` 存在** —— C27「sequencer + 合同回放」有可回放的场景契约依据（5 幕已写，见 state-cells.yaml:165）。
- **`Features/VehicleControl/DemoWalkingSkeleton.swift:33-52`** = handle() 五段 trace（decode/plan/guard/execute/readback）+ `speech.speak(readback.spokenText)` 同步调用 —— C28「视觉先于/同步 TTS」需改造的当前链路（现在是阻塞式 speak）。

## 联网核证据（URL + 日期，全 2026-06-23/24 检索）

- **MeshGradient = iOS18/macOS15**：[Apple Developer · MeshGradient](https://developer.apple.com/documentation/swiftui/meshgradient) + [Donny Wals](https://www.donnywals.com/getting-started-with-mesh-gradients-on-ios-18/) —— 证 C26 必须 fallback。
- **`.zoom` ZoomNavigationTransition macOS unavailable / iOS18**：[createwithswift](https://www.createwithswift.com/using-the-zoom-navigation-transition-in-swiftui/) + [theswift.dev](https://www.theswift.dev/posts/swiftui-zoom-navigation-transition/) + [hmlongco/Navigator #25](https://github.com/hmlongco/Navigator/issues/25) —— 证 C21 选 matchedGeometry 是 Mac 强制。
- **matchedGeometryEffect = iOS14/macOS11**：[Apple Developer · matchedGeometryEffect](https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:)) + [designcode.io](https://designcode.io/swiftui2-matched-geometry-effect/) —— 证 C21 API 安全（风险是行为）。
- **Gauge `.accessoryCircular` = iOS16/macOS13**：[Apple Developer · accessoryCircular](https://developer.apple.com/documentation/swiftui/gaugestyle/accessorycircular) + [useyourloaf](https://useyourloaf.com/blog/swiftui-gauges/) —— 证 C12 免守卫。
- **静态 `Grid` = iOS16/macOS13；LazyVGrid = iOS14**：[Apple Developer · Grid](https://developer.apple.com/documentation/swiftui/grid) + [avanderlee](https://www.avanderlee.com/swiftui/grid-lazyvgrid-lazyhgrid-gridviews/) —— 证 C22 切 Grid API 安全。
- **AVSpeechSynthesizer 首音延迟 0.6-1s+（FB11380447，iOS16 后）**：[Apple Forums #731238](https://developer.apple.com/forums/thread/731238) + [#715339](https://developer.apple.com/forums/thread/715339) —— 证 C28 痛点真实。
- **glassEffect = iOS26/Xcode26 only；NN/g「Liquid Glass Is Cracked」**：[Apple Developer · Applying Liquid Glass](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views) + [NN/g · Liquid Glass Is Cracked](https://www.nngroup.com/articles/liquid-glass/) —— 证 C26 守卫必要 + content-layer 禁用。
- **Network framework + Bonjour 离线 P2P（NWBrowser/NWListener，需 Info.plist local-network 声明 + 去重 gotcha）**：[Apple · Bonjour](https://developer.apple.com/documentation/foundation/bonjour) + [WWDC19 #713](https://developer.apple.com/videos/play/wwdc2019/713/) —— 证 C17 可行但有隐藏前置。
- **8bit 暗渐变 banding + 高对比投影更糟 + AirPlay 压缩劣化 + dither 解**：[Blur Busters](https://forums.blurbusters.com/viewtopic.php?t=927) + [KTC bit depth banding](https://us.ktcplay.com/blogs/technology-hub/monitor-bit-depth-causes-banding) + [frost.kiwi IGN dither](https://blog.frost.kiwi/GLSL-noise-and-radial-gradient/) —— 证 C29/C30 隐含投屏风险真实。
- **组件 star+活跃度（gh 独立核，2026-06-24）**：metasidd/Orb 422★/2024-11-11（~19月 stale，证 C26 不引第三方 orb）· twostraws/Inferno 2879★/2026-05-17（fresh，证 C26 ripple）· Dimillian/IceCubesApp 7005★/2026-06-09 · buh/CompactSlider 550★/2025-11-22（stale）· Inxel/CustomizableSegmentedControl 73★/2025-04-21（stale）· exyte/Grid 2086★/2025-02-28（stale）—— 全部与 lens 调研声称一致，事实底子可信。
- **车机 HMI 范式**（lens2 一手，URL 已核存在）：[MBUX Hyperscreen](https://group.mercedes-benz.com/innovation/digitalisation/connectivity/mbux-hyperscreen.html)（Zero Layer）+ [Polestar 4 infotainment](https://www.polestar.com/us/polestar-4/infotainment/)（气候常驻 strip）—— 证 C5/C2 范式背书。

## 反对 / 更好方案 / 漏洞（逐候选有问题的）

- **C1（开场全 10 族 reveal 扫一遍 → idle dim）**：⚠️ 漏洞——「全 10 族 reveal 扫一遍」= 10 张卡同时/序贯入场，若用 LazyVGrid + 浮现会撞 lens6 Tiger3（动态插入 reflow 跳动）+ Tiger7（ReduceMotion 下 reveal 被剥离瞒切）。**更好**：开场用「常驻骨架已在场 + 一次性辉光波扫过（visualEffect / opacity 波，非卡片插入）」，规避 reflow。Risk Revelation 偏低（没提 reveal 的 reflow/ReduceMotion 坑）。
- **C3（dim 族极弱呼吸微光 + "全部展示"彩蛋）**：⚠️ 与 lens1-F8 直接冲突——10 张卡全 breathe = 10 个 offscreen 动画 pass，lens 明确要求「只激活态卡呼吸，normal 静默」省 9/10 动画 + 双通道。C3「未触发的 dim 族保持呼吸微光」=反 lens 建议，且投屏下持续微光动画加重 banding/掉帧。**更好**：dim 族纯静态低亮（不呼吸），呼吸只给激活态。这条事实方向有误，weak。
- **C9（同时只展开 1 族）**：与 C7 高度重叠（C7 已说原地放大中卡 + 全景 blur，隐含单展开）。Non-dup 低。保留 C7 即可，C9 可并入。
- **C15（enum+switch 非 AnyView）**：与 C11「value.type 统一 enum+switch」是同一决策的实现细节复述，Non-dup 最低（2 分）。**建议并入 C11**——C11 已含「统一 enum+switch 从 state-cells 派生」，C15 只是补「别用 AnyView」（正确但属实现注释非独立决策）。
- **C16/C19/C20（iPhone 独立全功能 / 无断连概念 / 不极简）**：⚠️ **三条与 C4 严重重复**。C4 已立「双屏=两个独立纯端侧实例，iPhone 脱机全功能，LAN 联动可选加分」。C16（iPhone 独立非镜像）、C19（iPhone 无断连概念）、C20（iPhone 不极简是独立 demo）全是 C4 的同义反复。**建议**：C4 留，C16 部分（竖屏适配/独立 ASR）并入 C18，C19/C20 reject（零新信息）。这是这批候选最大的去重机会。
- **C17（Bonjour/Network framework LAN 联动）**：✅ 事实可行，但 ⚠️ **漏洞**——没提两个隐藏前置：① iOS14+ 需 Info.plist `NSLocalNetworkUsageDescription` + Bonjour service 声明（首次弹本地网络授权框，**现场演示弹框=破炸场**）② 双向同时发现需去重逻辑 ③ **现场若无 Wi-Fi（真离线）则同网 Bonjour 不通**，得靠 includePeerToPeer（Apple 私有，仅 Apple 设备）。既然 C4 已定「LAN 联动=可选加分」，C17 的真实价值是**坐实「联动是 nice-to-have 不是依赖」**——建议 demo 主路径不依赖联动，避免授权框炸场。
- **C21（matchedGeometryEffect）**：✅ Mac 强制正确，但 ⚠️ **撞 lens6 HIGH 坑**——matchedGeometry 在 LazyVGrid 里 multiple-source 冲突。**这正是为什么必须配 C22（Grid）+ C23（兜底）**。单独看 C21 是高风险决策，三条捆绑才安全。**更狠的反对**：lens6/综合官倾向「干脆禁 matchedGeometry，改 opacity/scale + 边框辉光」（坑密度最低），即 C23 升为主路径、C21 降为「验证通过才用」（=C25 的升级门）。**这是 G2 事实型分歧，建议上抛磊哥拍**：matchedGeometry hero（更惊艳但坑多）vs opacity/scale（稳但平）。
- **C24（320ms/220ms 两参数）**：数值是 reviewed-value（无外部一手），合理但应标「现场实测可调」。方向（两独立参数防竞态）正确。
- **C26（每 shader 必有 fallback）**：✅ 事实完全正确（MeshGradient iOS18 / glassEffect iOS26 / 都高于部署目标）。⚠️ **漏洞**——没把「投屏 8bit banding → IGN dither」列进 shader 清单。orb MeshGradient + ripple 在投屏下会 banding，dither 应作为 shader 选型的一等公民（lens6 adopt SwiftUIShaders IGN）。建议 C26 补 dither shader。
- **C27（4 段 sequencer + 合同回放）**：✅ demo-scenarios.yaml 存在可回放。⚠️ 但「合同回放」的事实门槛——回放需链路确定性（DemoWalkingSkeleton 是真跑意图引擎非脚本回放），现场若靠真 ASR+真模型则非「回放」而是「实跑」，sequencer 只能编排视觉不能保证模型输出。建议明确：sequencer 编排**视觉/TTS 时序**，模型输出走真链路（不是录播）。
- **C28（视觉先于 TTS + immediate ack）**：✅ 处方正确。⚠️ 当前代码 `DemoWalkingSkeleton:51` 是**同步阻塞 speak**——要实现「视觉先于 TTS」需把 speak 异步化 + 卡片动效在 speak 前触发。这是 surface 的代码改造点。另：pre-warm（app 启动空 utterance）应明确写进决策。
- **C30（稳定优先于炸场）**：✅ 最重要的元决策，事实底子最硬（thermal/ReduceMotion/LPM/错峰全可核）。⚠️ 唯一漏洞同 C26——「错峰」的量化（mlx 掉 50%）未核，A2 必 Instruments 实测坐实，别凭设计经验值写死阈值。

## 你这视角（事实核）top 5 最该关注候选

1. **C21（聚焦过渡 API）** — 事实型分歧的焦点（matchedGeometry vs opacity/scale）。Mac 无 zoom 退路是硬事实（已核三源），但 matchedGeometry 撞 LazyVGrid HIGH 坑也是硬事实。**这是全批唯一需要上抛磊哥拍的 G2 事实型决策**，且决定 C22/C23/C25 全链。Decision Leverage 最高。

2. **C26（shader 选型 + fallback）** — load-bearing API 版本事实最密集（MeshGradient iOS18 / glassEffect iOS26 / ripple）。我逐一核实每个版本边界都真实，且都高于部署目标 iOS17 → fallback 不是过度防御是编译硬需求。但漏了投屏 dither，需补。

3. **C28（TTS 时序）** — 依赖一个被 Apple FB 坐实的真 bug（首音延迟 0.6-1s+），且当前代码未缓解（同步 speak、无 pre-warm）。这是「demo 反应快」北极星的隐藏炸点，事实价值高 + surface 了代码缺口。

4. **C30（稳定优先于炸场）** — 元决策，把所有事实风险（thermal/banding/ReduceMotion/LPM/GPU 错峰）收口成一条优先级。事实底子最全。唯一软肋是「50% 掉吞吐」量化未核（设计经验值）。

5. **C12（控件缺口：原生 vs 自建）** — 异构值控件的版本可用性全核实（Gauge iOS16 免守卫 / ColorPicker iOS14），「座椅多维+RGB 色环自建、其余原生」的事实边界清晰。配合本地核发现的 state-cells 异构值真实存在（18-32/1-10/0-100%/多维），这条把「哪些免费哪些要造」一刀切清，Verifiability 满分。

> 🔴 事实核视角总评：**这批 30 决策的外部事实可信度高（独立联网核基本全过），最大问题不是「编了假事实」，而是 (a) C16/C19/C20/C15 严重去重空间（4 条可砍/并）、(b) C3 与 lens 性能建议方向冲突、(c) C21 的 G2 分歧需上抛、(d) 几个量化（C13/C30 的 50%、C24 的 ms）是 reviewed-value 需实测坐实、(e) 投屏 banding/dither 这条真事实没立成独立决策（散在 C26/C30）。**

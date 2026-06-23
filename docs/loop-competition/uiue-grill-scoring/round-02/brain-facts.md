# UIUE 30 候选盲评 — 事实核视角（Round 2）

> 视角 = 每决策依赖的外部事实是否真实（API 版本可用性 / 车机范式 / 组件 star / 平台行为）。重点 WebSearch 核，每条带 URL+日期（2026-06-23 检索）。本地核 file:line。
> 关键前提（本地核坐实）：**当前 `App/ContentView.swift` 是极简 walking skeleton**（LazyVGrid.adaptive(min:160) + 8 张硬编码 title 卡 + 绿/灰二值），30 个候选**全部尚未实现**——都是设计决策，不是已落代码。`Package.swift` 部署 **iOS17 / macOS14**（实测 grep），本机 SDK iOS26.5 → iOS18 API 须 #available，iOS16 API 安全。

## 30 候选评分表（C1-C30 × 5 维 + Total，满分 25）

| ID | Importance | Verifiability | Non-dup | Leverage | Risk-Rev | Total | verdict |
|---|---|---|---|---|---|---|---|
| C1 | 3 | 4 | 4 | 3 | 2 | 16 | keep |
| C2 | 5 | 4 | 4 | 4 | 4 | 21 | keep |
| C3 | 2 | 3 | 3 | 2 | 2 | 12 | weak |
| C4 | 4 | 4 | 3 | 4 | 3 | 18 | keep |
| C5 | 5 | 5 | 3 | 4 | 4 | 21 | keep |
| C6 | 4 | 4 | 4 | 4 | 3 | 19 | keep |
| C7 | 4 | 5 | 3 | 3 | 4 | 19 | keep |
| C8 | 4 | 5 | 4 | 4 | 5 | 22 | keep |
| C9 | 3 | 4 | 3 | 3 | 3 | 16 | keep |
| C10 | 4 | 5 | 3 | 4 | 4 | 20 | keep |
| C11 | 4 | 5 | 4 | 4 | 3 | 20 | keep |
| C12 | 4 | 5 | 4 | 4 | 4 | 21 | keep |
| C13 | 4 | 2 | 4 | 3 | 4 | 17 | weak |
| C14 | 4 | 4 | 3 | 3 | 4 | 18 | keep |
| C15 | 3 | 5 | 3 | 3 | 3 | 17 | keep |
| C16 | 3 | 4 | 2 | 3 | 2 | 14 | weak |
| C17 | 5 | 5 | 4 | 4 | 5 | 23 | keep |
| C18 | 3 | 4 | 2 | 3 | 3 | 15 | weak |
| C19 | 2 | 3 | 2 | 2 | 2 | 11 | better-exists |
| C20 | 2 | 3 | 1 | 2 | 2 | 10 | reject |
| C21 | 5 | 5 | 4 | 4 | 4 | 22 | keep |
| C22 | 4 | 5 | 4 | 3 | 4 | 20 | keep |
| C23 | 4 | 4 | 4 | 3 | 4 | 19 | keep |
| C24 | 3 | 4 | 3 | 3 | 3 | 16 | keep |
| C25 | 5 | 5 | 4 | 5 | 4 | 23 | keep |
| C26 | 4 | 5 | 4 | 4 | 4 | 21 | keep |
| C27 | 4 | 3 | 3 | 4 | 3 | 17 | keep |
| C28 | 4 | 5 | 4 | 4 | 5 | 22 | keep |
| C29 | 3 | 4 | 3 | 3 | 3 | 16 | keep |
| C30 | 5 | 4 | 3 | 5 | 5 | 22 | keep |

## 视角专项发现（事实核 — load-bearing 外部事实真伪）

### 真实且坐实的事实（候选可放心依赖）
- **F1. matchedGeometryEffect = iOS14 / macOS11**（[Apple 文档](https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:)) / [Design+Code](https://designcode.io/swiftui2-matched-geometry-effect/)）→ iOS17/macOS14 部署**完全安全，无需 #available**。**C21 的「不用 navigationTransition.zoom」是事实驱动的正确决策**（见 F2）。
- **F2. navigationTransition .zoom / matchedTransitionSource = iOS18+，且 macOS 上 ZoomNavigationTransition 标 unavailable**（[createwithswift](https://www.createwithswift.com/using-the-zoom-navigation-transition-in-swiftui/) / [hmlongco/Navigator #25](https://github.com/hmlongco/Navigator/issues/25)）。**Mac 是主舞台 → zoom transition 在 Mac 上根本不可用 → matchedGeometryEffect 是唯一跨平台 morph 选项**。这把 C21 从「口径选择」抬成「Mac 平台事实约束」。
- **F3. MeshGradient = iOS18 / macOS15**（[Apple 文档](https://developer.apple.com/documentation/swiftui/meshgradient)）→ **C26 的「orb MeshGradient 必有低版本 fallback」是必须的**（部署 iOS17 不守卫直接崩，hig-rules §0 铁律 2 已记）。事实正确。
- **F4. Gauge `.accessoryCircular` = iOS16 / macOS13**（[Apple 文档](https://developer.apple.com/documentation/swiftui/gaugestyle/accessorycircular) / [Use Your Loaf](https://useyourloaf.com/blog/swiftui-gauges/)）→ iOS17/macOS14 **安全，无需 #available**。**C12「温度/开度→Gauge 环，其余原生」事实成立**。注意：iOS/macOS 默认是线性 capacity，要环形必显式 `.gaugeStyle(.accessoryCircular)`。
- **F5. matchedGeometryEffect + LazyVGrid 已知坑真实**（[Apple Forums #669115](https://developer.apple.com/forums/thread/669115) / [#689053](https://developer.apple.com/forums/thread/689053)）：① 懒渲染 off-screen 源未挂载 → 无动画 ② multiple-source 冲突。修法 = `isSource:true` + ZStack overlay。**C22「10 族固定集用 Grid 非 LazyVGrid」是规避懒渲染坑的有效路径之一**（但非唯一：isSource 显式指定 + ZStack overlay 也能让 LazyVGrid 工作，故 C22 是「降坑密度」非「唯一正解」）。
- **F6. AVSpeechSynthesizer 首音延迟真实**（[Apple Forums #731238](https://developer.apple.com/forums/thread/731238)）：首次 speak 有 ~0.6-1s+ 延迟（"[AXTTSCommon] Invalid rule:"），simulator≠device。**C28「immediate ack 掩盖首音延迟 + 视觉先于 TTS」是对症修法**（warm-up 空 utterance 也是社区惯例）。事实+修法双正确。
- **F7. Local Network 授权弹窗真实且 C17 风险被低估**（[Apple TN3179](https://developer.apple.com/documentation/technotes/tn3179-understanding-local-network-privacy) / [Apple Forums #766133](https://developer.apple.com/forums/thread/766133)）：iOS14+ Bonjour/Network framework 触发「X 想查找并连接本地网络设备」弹窗，**无 pre-check API（弹窗只在尝试连接时才弹）**，且 **iOS18/Xcode16 有已知 bug 弹窗不出现**。现场 demo 首次双屏联动会突然弹系统权限框 = 炸场风险。**C17 把 LAN 联动标「可选加分」正是这个事实的正确响应**。

### 事实有问题 / 数字无源（候选该被压分或补证）
- **F8. C13 的「~50% 吞吐」量化无一手源（事实型，flag）**：WebSearch（[mlx-swift-examples #66](https://github.com/ml-explore/mlx-swift-examples/issues/66) / [Apple WWDC25 MLX](https://developer.apple.com/videos/play/wwdc2025/298/)）证实 **MLX 占 GPU >90%（不管 memoryLimit 设多少），token 生成是 bandwidth-bound，与 SwiftUI Metal shader（layerEffect）共享 GPU+统一内存**——「shader 与推理抢 GPU」机理为真，但**「掉 50%」这个精确数字没有任何单一权威源**。hig-rules §2 也写「与 mlx 抢 GPU 掉 50% 吞吐」同样无源。结论：C13/C30 的**错峰互斥原则正确**，但**具体 50% 须 A2 阶段 Instruments 实测坐实，不能写进对外材料当承诺**（撞 claim-vs-reality「凭印象给数字必核源」）。Verifiability 压到 2。
- **F9. C8「按线上优先级」无数据源（隐藏依赖，flag）**：本地核 `contracts/state-cells.yaml` **无 `priority`/`freq`/线上优先 字段**（grep 实测）。`priority:高/中` 只在 `function-spec-full-v0.yaml` 的**顶层族级**出现（5 行），子 device 级没有；`semantic-function-contract.jsonl` 也无子 device 优先级。**C8「显 3-4 高频子 device 按线上优先级」的数据源不存在**——要么得新建一张子 device 优先级表，要么 demo 现场手挑（更现实）。这是真实隐藏成本，C8 的 Risk-Revelation 给 5 正因它逼出这个缺口。
- **F10. 组件 star/新鲜度核对**：
  - **metasidd/Orb = 317★（Swift Package Index），最后实质活动 ~2024-11**（[SPI](https://swiftpackageindex.com/metasidd/Orb) / [repo](https://github.com/metasidd/Orb)）→ **STALE ~19 月，按 github-first 60 天硬约束淘汰**。lens6 记「422★」略高于实测 317★（star 口径差异），但**「stale 应弃」结论成立**。→ **C26「自建 MeshGradient orb，不引 stale siri-orb repo」是正确的**（hig-rules §2 已记）。
  - **Inxel/CustomizableSegmentedControl = 74★，~1yr inactive，iOS14+**（[SPI](https://swiftpackageindex.com/keywords/swiftui-animations) / [repo](https://github.com/Inxel/CustomizableSegmentedControl)）→ borderline 偏旧；**C12「座椅多维自建、其余原生」比 adopt 这个第三方更稳**（少一个 stale 依赖）。lens7 的 adopt 候选把它列「待核」是对的，实测应降级为「读概念不依赖」。

### 车机范式事实核（lens2 调研可信度）
- C5「全景常驻+触发聚焦」对齐 **MBUX Zero Layer（常驻顶层+AI 浮现 20 卡片）**（[mercedes-benz.com](https://group.mercedes-benz.com/innovation/digitalisation/connectivity/mbux-hyperscreen.html)）——真实车机范式，非杜撰。
- C2/C24「序列化高亮不同时闪」有**认知科学硬约束**：Miller 7±2 + Single-Item-Template 假说（视觉工作记忆同一时刻只能一个 attentional template）（[bioRxiv](https://www.biorxiv.org/content/10.1101/629378.full.pdf)）+ 车载 VUI 视觉反馈研究。这条不是审美偏好，是有据可循的注意力机制——**C2 的 Importance 应给 5**。

## 本地核证据（file:line）

- `App/ContentView.swift:40` = `LazyVGrid(columns:[GridItem(.adaptive(minimum:160), spacing:12)])` **无 maximum** → window resize/投屏分辨率切换重排（lens6 Tiger3 坐实「baseline 已踩坑」）。直接关联 C22（用固定 Grid）。
- `App/ContentView.swift:121-127` = `background`/`borderColor` 只判 `.satisfied ? green : gray` → **7 态压成绿/灰二值**，把 clarify/unsupported/safety/crash 全渲成灰。直接关联 C11/C14（7 态分发）+ tokens.md §2「U10 四态必分开」。
- `Core/State/DemoVehicleStateStore.swift:17-25` = `DemoVisualState` 7 态枚举已存在（normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown）→ C11「value.type enum+switch」可直接消费此枚举；tokens.md 注明「A2 不碰此枚举」。
- `Package.swift` = `.iOS(.v17), .macOS(.v14)`（grep 实测）→ C26 MeshGradient/C 系 glassEffect 必 #available 的事实根据。
- `contracts/state-cells.yaml` **无 priority/freq 字段**（grep 实测 0 命中）→ **C8「线上优先级」无数据源**（F9）。
- `contracts/state-cells.yaml:59-64` = ac.temp_setpoint scope=[主驾/副驾/左后/右后/全车] execution_range{18,32,1} + exp_step（little:2 / gear / extreme）→ C11/C12 异构值分发的真实数据形态来源；温度连续/百分比/档/enum/颜色 5 类齐全。
- `prototypes/scheme1-deep-space-interactive.html:41-55` = `.grid2`(2 列固定) + `.card.on`(breathe 3.4s) + `pop .5s`，且**只 6 卡静态 2×2**（lens2「退化网格式，撑不住 10 族」坐实）→ C5/C7/C2 是对原型不足的针对性升级。

## 联网核证据（URL + 2026-06-23 检索）
- matchedGeometryEffect iOS14/macOS11：https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:)
- navigationTransition.zoom macOS unavailable：https://www.createwithswift.com/using-the-zoom-navigation-transition-in-swiftui/ + https://github.com/hmlongco/Navigator/issues/25
- MeshGradient iOS18/macOS15：https://developer.apple.com/documentation/swiftui/meshgradient
- Gauge .accessoryCircular iOS16/macOS13：https://developer.apple.com/documentation/swiftui/gaugestyle/accessorycircular
- matchedGeometryEffect+LazyVGrid 坑：https://developer.apple.com/forums/thread/669115 + https://developer.apple.com/forums/thread/689053
- AVSpeechSynthesizer 首音延迟：https://developer.apple.com/forums/thread/731238
- Local Network 授权（无 pre-check + iOS18 弹窗 bug）：https://developer.apple.com/documentation/technotes/tn3179-understanding-local-network-privacy + https://developer.apple.com/forums/thread/766133
- MLX GPU 占用 >90%（50% 数字无源）：https://github.com/ml-explore/mlx-swift-examples/issues/66 + https://developer.apple.com/videos/play/wwdc2025/298/
- metasidd/Orb 317★/2024-11 stale：https://swiftpackageindex.com/metasidd/Orb
- Inxel SegmentedControl 74★/~1yr：https://github.com/Inxel/CustomizableSegmentedControl
- MBUX Zero Layer：https://group.mercedes-benz.com/innovation/digitalisation/connectivity/mbux-hyperscreen.html
- Single-Item-Template（多意图序列化基础）：https://www.biorxiv.org/content/10.1101/629378.full.pdf

## 反对 / 更好方案 / 漏洞（逐候选有问题的）

- **C3（彩蛋 dim 呼吸光，weak）**：「极弱呼吸微光」与 hig-rules §0 铁律3+lens6 Tiger1 直接冲突——**全 10 族常驻呼吸 = per-cell 持续动效 = GPU offscreen 重绘 + 与 MLX 抢 GPU**。死灰更省。漏洞=未考虑低电量/ReduceMotion 下「极弱呼吸」被剥离后还剩什么。建议：未触发族用**静态低亮**（颜色承载），别全员呼吸。
- **C8（线上优先级，keep 但隐藏依赖）**：**「线上优先级」数据源不存在**（F9，本地 grep 实测 contract 无 priority 字段）。更现实方案=demo 现场为 10 族手工挑 3-4 个高频 device（产品约定收窄输入，blueprint-teardown demo 取巧铁律），而非真去建一张全 191 device 的线上优先级表。承诺该改成「手工配置高频子集」。
- **C13（~50% 吞吐，weak/事实型 flag）**：**50% 无一手源**（F8）。错峰互斥原则对，但数字是凭印象。更好=写成「shader 与推理须 GPU 错峰（具体降幅 A2 Instruments 实测坐实）」，绝不把 50% 写进对外材料。漏洞=「氛围层非常驻」与 C3「全族常驻呼吸」自相矛盾（一个说 shader 不常驻，一个让全族常驻发光）。
- **C16/C18/C20（双屏簇，dedup 重灾区）**：C16（iPhone 独立全功能非镜像）+ C18（759pt 三屏分层+独立 ASR）+ C19（断连降级=无断连概念）+ C20（iPhone 不极简）**高度重叠**，都在说同一件事「iPhone 是独立端侧实例」。**C20 = C4+C16+C19 四合一，最该 reject**（Non-dup=1）。C18 唯一独立技术点 = 「759pt 竖屏三屏具体尺寸」，但 120+440+80=640≠759（数字对不上，疑似硬编不严谨），且竖屏布局与 C16 双屏簇绑死，独立性弱→weak。
- **C19（断连降级=无断连概念，better-exists）**：「iPhone 自包含无断连概念」是 C4「各自独立纯端侧实例」的逻辑推论，无新信息。被 C4 完全覆盖。
- **C21（matchedGeometry，keep 但藏口径分歧 → 🔴 上抛磊哥）**：**API 选择层是事实驱动的正确决策**（F2：Mac zoom 不可用 → matchedGeometry 是唯一跨平台 morph）。但**更深的口径分歧在「hero morph（matchedGeometry）vs opacity/scale 兜底」哪个做默认**——这与 C25 升级门捆绑（C25 说「默认 opacityScale，验证后才升级 matchedGeometry」）。hero 更惊艳但踩 F5 的 LazyVGrid+macOS 坑；opacity/scale 更稳但少 wow。**这是仁者见仁的产品/审美取舍（dispute-triage 口径型），建议上抛磊哥拍：A=默认 hero 求惊艳 / B=默认 opacity 求稳（C25 路线）⭐**。
- **C24（魔法数字 320/220ms，keep）**：双参数防竞态的洞察对（聚焦展开与多意图 stagger 是两个独立时间轴，共用一个值会竞态），但 320/220 是拍的，无据。更好=标「初值 320/220，现场调」，别当冻结常量。
- **C27（4 段 sequencer+合同回放，keep）**：「合同回放」对 demo 稳定性好（可复现），但 Verifiability 偏低（sequencer 实现复杂度未估）。漏洞=4 段编排若 hard-code 时序，与 C28「视觉先于 TTS、TTS 时长不定」会冲突——sequencer 须事件驱动（等卡片亮完信号）非纯定时。

## 你这视角（事实核）top 5 最该关注候选

1. **C17（23分）**——Local Network 授权弹窗是**现场首次双屏联动会突然弹系统框 + iOS18 弹窗 bug**的真炸场风险（F7，Apple TN3179+#766133 坐实），且无 pre-check API。把 LAN 标「可选加分」是对这个事实的正确防御。最高 Risk-Revelation。
2. **C25（23分）**——升级门是**把 F5（matchedGeometry+LazyVGrid+macOS 坑）machine-化为「默认稳兜底，编译验证过才升级惊艳」**的纪律，Decision-Leverage 满分（逼出「先稳后炫」的执行序）。与 C21 的口径分歧绑定，是该口径的承载门。
3. **C21（22分）**——**Mac 主舞台上 navigationTransition.zoom 根本不可用（F2 事实），matchedGeometry 是唯一跨平台 morph**。API 层是硬事实决策；但「hero vs opacity 默认」是口径型，**🔴 上抛磊哥拍**（与 C25 捆绑）。
4. **C28（22分）**——AVSpeechSynthesizer 首音 0.6-1s+ 延迟是**Apple 官方确认的真坑（F6）且 simulator 测不出**，「视觉先于 TTS + immediate ack」是对症修法。现场「反应快」北极星的关键，最易在真机 demo 翻车。
5. **C30（22分）**——「稳定优先于炸场」是**唯一直面 F8（GPU 抢占）+ lens6 七坑（halation/banding/AirPlay 掉帧/三开关 fallback）的元决策**，逼出 thermal watchdog+ReduceMotion/低电量双通道。Risk-Revelation 满分。

> 旁注（C13 事实型分诊）：50% 吞吐数字是**事实型**且**无源**，应 A2 Instruments 实测坐实，不进对外材料；错峰原则保留。这是本视角发现的唯一「凭印象数字」硬伤（F8）。
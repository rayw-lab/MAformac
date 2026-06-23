# Round 2 盲评 — 可行性视角（SwiftUI/代码实现 + 端侧约束）

> 评审人：可行性视角（grep 现状代码 file:line + 联网核 SwiftUI API 版本/坑 + 端侧约束）。盲评——未读 uiue-d1-d6-grill / grill-decisions-master，只读 candidates-blind + 本地核锚 + 联网。
> 🔴 **头号现状事实（贯穿全 30）**：当前代码 = 极简 walking skeleton。`App/ContentView.swift` 全文 137 行 = `LazyVGrid(.adaptive(minimum:160))` 平铺 23 个 device cell（`DemoVehicleStateStore.swift:134-158` defaultCells 23 条，非 10 族粒度），text-input 驱动（`commandText`），`:122,126` 把 7 态 `DemoVisualState` 压成 `satisfied ? green : gray` 二值。**grep 全仓 `*.swift`：零 matchedGeometry / 零 MeshGradient / 零 glassEffect / 零 Gauge / 零 @Namespace / 零 contentTransition**——唯一已落地的「高级」API 是 `AVSpeechSynthesizer`（SpeechSynthesisEngine.swift:9，fire-and-forget）。**即 C1-C30 描述的精致 UI 几乎全是 greenfield 前瞻决策，不是现状代码的迭代。可行性评估 = 「这个决策落 SwiftUI 是否可行 + 复杂度 + 现状缺口」**。

---

## 30 候选评分表（C1-C30 × 5 维 + Total，满分 25）

| ID | Importance | Verifiability | Non-dup | Leverage | Risk-Rev | **Total** | verdict |
|---|---|---|---|---|---|---|---|
| C1 开场 reveal 序列 | 3 | 3 | 4 | 3 | 2 | **15** | weak |
| C2 多意图序列化高亮 | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C3 dim 族弱呼吸+彩蛋 | 2 | 3 | 3 | 2 | 2 | **12** | weak |
| C4 双屏双实例独立 | 3 | 3 | 2 | 3 | 3 | **14** | weak |
| C5 全景常驻+触发聚焦 | 5 | 4 | 3 | 4 | 4 | **20** | keep |
| C6 语音为主+tap 为辅同入口 | 4 | 3 | 3 | 4 | 3 | **17** | keep |
| C7 原地放大+blur 非 modal | 4 | 5 | 3 | 3 | 4 | **19** | keep |
| C8 子 device 3-4 高频+二级 | 4 | 4 | 4 | 4 | 4 | **20** | keep |
| C9 同时只展开 1 族 | 3 | 4 | 2 | 3 | 3 | **15** | weak |
| C10 折叠不平铺+角标+语音直达 | 5 | 5 | 3 | 4 | 4 | **21** | keep |
| C11 value.type enum+switch 派生 | 4 | 5 | 3 | 4 | 3 | **19** | keep |
| C12 控件缺口=自建2+原生其余 | 5 | 5 | 4 | 5 | 4 | **23** | keep |
| C13 shader 仅氛围+GPU 错峰 | 5 | 4 | 4 | 5 | 5 | **23** | keep |
| C14 卡片骨架统一只变值区 | 4 | 4 | 3 | 4 | 3 | **18** | keep |
| C15 enum+switch 非 AnyView | 4 | 5 | 2 | 4 | 3 | **18** | weak(≈C11/C12) |
| C16 iPhone 独立全功能非镜像 | 3 | 3 | 2 | 3 | 2 | **13** | weak |
| C17 Bonjour LAN 可选联动 | 4 | 5 | 4 | 3 | 5 | **21** | keep(风险揭示) |
| C18 iPhone 竖屏 759pt 三屏 | 4 | 5 | 3 | 4 | 4 | **20** | keep |
| C19 断连降级=独立无断连概念 | 2 | 3 | 2 | 2 | 2 | **11** | weak(≈C4/C16/C20) |
| C20 双屏定位=独立全功能 | 2 | 2 | 1 | 2 | 2 | **9** | reject(=C4+C16+C19) |
| C21 过渡 API=matchedGeometry | 5 | 5 | 4 | 5 | 5 | **24** | keep🔴上抛 |
| C22 Grid 非 LazyVGrid | 5 | 5 | 4 | 5 | 5 | **24** | keep |
| C23 兜底=opacityScale+ripple | 4 | 4 | 3 | 4 | 4 | **19** | keep |
| C24 过渡时长双参数防竞态 | 4 | 4 | 4 | 4 | 4 | **20** | keep |
| C25 升级门=默认 opacity 验后升 | 5 | 5 | 4 | 5 | 5 | **24** | keep(与 C21 捆绑) |
| C26 shader 选型必有 fallback | 4 | 5 | 3 | 4 | 4 | **20** | keep |
| C27 wow 4 段序列化 sequencer | 3 | 3 | 4 | 3 | 3 | **16** | keep |
| C28 TTS 时序+immediate ack | 5 | 5 | 5 | 4 | 5 | **24** | keep |
| C29 断网 morph+徽章 | 3 | 4 | 4 | 3 | 3 | **17** | keep |
| C30 稳定优先+thermal watchdog | 5 | 4 | 4 | 5 | 5 | **23** | keep |

---

## 视角专项发现（可行性 / SwiftUI 落地）

### 发现1 🔴 全 30 决策几乎全 greenfield —— 现状代码无任一高级 API（这反而拉高 Risk-Rev，因落地缺口巨大）
grep 全仓 swift：matchedGeometry / MeshGradient / glassEffect / Gauge / @Namespace / contentTransition **全 0 命中**。ContentView 137 行只有 LazyVGrid + 文本框 + 绿/灰二值卡。**含义**：① 任何谈「现状 X 用了 Y」的口径都错——除了 LazyVGrid 和 AVSpeechSynthesizer，全是未来代码。② 评 Non-dup 要双轴：候选 vs 候选（C20=C4+C16+C19 簇内重复）+ 候选 vs **已落地的 SSOT 设计文档**（tokens.md / hig-rules.md 已把 C12/C13/C21/C22/C26/C30 写进硬约束 —— 这些候选「正确但 docs 已固化」，Decision Leverage 因「已拍」而被稀释，但作为 grill 议题仍逼承诺）。

### 发现2 🔴 C21/C25 是唯一真事实型分歧（README 自己点名「必上抛磊哥」）—— 但本视角能给出技术裁决方向
README:23 原文：「**唯一真分歧（口径型，必上抛磊哥）= 聚焦过渡用不用 matchedGeometryEffect**：code-clone 主张用 vs pitfalls 主张禁用」。可行性视角实测裁决：
- C21 选「状态切换 matchedGeometry（@Namespace+isExpanded），不用跨栈 navigationTransition.zoom」**前半对、后半是被迫正确**：`navigationTransition(.zoom)` 在 **macOS 上 type-unavailable**（联网坐实，见下），Mac 主舞台根本不能用 zoom → 只能用 matchedGeometry 或 opacity/scale。所以 C21「不用 zoom」不是选择是约束。
- 但 matchedGeometry 在 **LazyVGrid 有 multiple-source 运行时报错 + 懒渲染源未挂载** 双坑（联网+lens6 坐实）→ 所以 C21 必须与 **C22（用非 lazy Grid）** 强绑才安全，且 lens6/README 的 pitfalls 路线主张**直接禁用 matchedGeometry 改 opacity/scale**（C23 兜底）。
- **C25（默认 opacity，编译验证 matchedGeometry 无抖闪+ReduceMotion fallback 后才升级）= 把这个事实型分歧转成「证伪优先」的工程门**——这是最优解：不在纸面拍 matchedGeometry 行不行，而是先上保底（opacity/scale 必跑），matchedGeometry 作 enhancement 经 macOS 实测验证再升级。**C21 与 C25 应作为同一决策的两面捆绑评审/拍板**（C21=想用什么，C25=怎么安全地用），不应分裂。

### 发现3 C12/C13/C30/C28 是可行性视角的最高价值四条（实质技术决策 + 端侧约束 + 真坑）
- **C12（控件缺口）**：联网坐实 Gauge `.accessoryCircular` = iOS16/macOS13 → 项目部署 iOS17/macOS14，**温度/开度/音量用原生 Gauge 零 #available**；座椅多维+RGB 色环确实无原生 = 必自建。C12 的「自建2+原生其余」边界划得精准，Leverage 最高（直接定可复用控件清单）。
- **C13/C30（shader 错峰 + thermal watchdog）**：端侧硬约束的核心——shader/`.layerEffect` 与 mlx 推理抢 GPU 掉吞吐（lens 多路坐实），且暗底辉光 = offscreen render。C13「shader 仅氛围非常驻 + GPU 协调器错峰」+ C30「特效与推理错峰 + ReduceMotion/低电量双通道 + thermal watchdog」是 demo「不崩/反应快」北极星的真护栏。Risk-Rev 满分。
- **C28（TTS 时序 + immediate ack）**：联网坐实 **AVSpeechSynthesizer 首音延迟 0.6-1s+ 是 Apple 持续未修 bug（FB11380447）**，文档化的两个 workaround 正是 C28 写的「pre-warm + 视觉先于 TTS + immediate ack 掩盖首音延迟」。C28 Non-dup=5（唯一谈 TTS 时序），Verifiability=5，是最干净的「一手坑→正确缓解」候选。

### 发现4 双屏簇（C4/C16/C18/C19/C20）严重重复 + 多为非决策
- **C20「iPhone 不极简，是独立全功能端侧 demo」= C4（双实例独立）+ C16（独立全功能非镜像）+ C19（独立无断连概念）的同义复述**，无独立技术内容 → reject。
- C4/C16/C19 三条互为变体（都在说「iPhone 自包含」），技术上「双实例各跑各的」本就是纯端侧离线的默认形态，**不是需要拍板的设计决策**（Leverage 低）。
- **C18 是该簇唯一有独立技术内容的**：759pt 三屏分配（orb120/内容440/mic80）是 lens1 F5 实测 iPhone15Pro 安全区可用高的精确落地（顶59+底34 吃掉），且竖屏布局 ≠ Mac 横屏 Grid，是真要分支的代码决策 → keep。建议簇内：保 C18，C20 删，C4/C16/C19 合并成一条「iPhone 双实例自包含（默认形态，非决策）」。

### 发现5 派生簇（C11/C14/C15）也有重复
C11（value.type enum+switch 从 state-cells 派生）、C15（enum+switch 编译穷尽非 AnyView）讲的是同一件事的两面（C11=数据驱动派生、C15=实现手法）。C14（骨架统一只变值区）是独立的（视觉一致性 = lens6 E3「懂一张懂全部」）。建议 C11+C15 合并；C14 保留。state-cells.yaml 已给出 value.type 数据结构（enum/int+execution_range+exp_step），C11 的「从 state-cells 派生」可坐实。

---

## 本地核证据（file:line）

- **现状 UI 极简**：`App/ContentView.swift:40` `LazyVGrid(.adaptive(minimum:160))`；`:41 ForEach(store.cells)` 平铺全部 cell（非 10 族）；`:8 commandText` 文本框驱动（非语音）；`:122,126` `visualState == .satisfied ? green : gray`（7 态压二值，**正是 tokens.md:64 + lens5 F6 点名的头号翻车 bug**）。
- **7 态枚举已存在但 UI 未消费**：`Core/State/DemoVehicleStateStore.swift:17-25` `DemoVisualState` 7 态（normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown）—— 数据层已就绪，UI 层只用 2 态 → C2/C29 的 7 态色映射有数据支撑，可行性高。
- **defaultCells 23 条非 10 族粒度**：`DemoVehicleStateStore.swift:134-158`（grep -c = 23）—— 现状 device 平铺，C10「族卡折叠不平铺」是必要重构，现状未做。
- **value.type 数据结构已固化（C11/C12/C15 数据源）**：`contracts/state-cells.yaml:55-84`（ac.temp_setpoint type:int execution_range{18,32,1} exp_step；ac.fan_speed unit:gear {1,10}）；`:143-149` ambient.color enum 8 色（C12 RGB 自建依据）；`:102-105` window.motion enum（开关族）。异构值 5 类（enum/int-celsius/int-gear/int-percent/RGB）坐实 → C11「5 类 switch」与数据匹配。
- **TTS 已落地、无时序控制（C28 现状缺口）**：`Core/Voice/SpeechSynthesisEngine.swift:8-20` `AVSpeechSynthesizer` + `speak()` fire-and-forget，无 didStart delegate / 无 pre-warm / 无 immediate ack → C28 描述的缓解全未做。
- **部署目标坐实**：`Package.swift:7-9` `.iOS(.v17), .macOS(.v14)` —— **这是 C21/C25/C26 #available 守卫的判据**：MeshGradient(iOS18)/glassEffect(iOS26)/navigationTransition.zoom(iOS18,macOS unavailable) 全需守卫；Gauge(iOS16)/matchedGeometry(iOS14) 不需。
- **设计 SSOT 已固化多条候选内容**：`docs/design/tokens.md:49-64`（7 态色映射，含 C2/C29 用的 clarify 琥珀/safety 红四态分开）；`:88-95`（C12/C13 的 surface_role control_glass vs content_glow）；`docs/design/hig-liquid-glass-rules.md:48-66`（C26 MeshGradient fallback + C13 shader 仅氛围 + C5 ripple）；`:67-76`（C28 numericText/withAnimation 坑、C30 ReduceMotion/LPM 双通道、barge-in didCancel 坑）。
- **prototype 撑不住 10 族**：`prototypes/scheme1-deep-space-interactive.html:113-120` 固定 6 卡 2 列（空调/座椅/车窗/风量/氛围灯/音乐），on/off 二值，静态 mic emoji（非 orb），无 expand/下钻/10 族 reveal → C1/C5/C6/C7/C8/C10 全是 prototype 之外的前瞻决策。
- **lens 研究（客观证据）支撑**：lens4 F4（Gauge iOS16 无守卫）/ lens1 F7+F11（10 族固定集用 Grid 非 Lazy = C22）/ lens1 F5（759pt = C18 精确值）/ lens6 T2-T3-T7（matchedGeometry+LazyVGrid 崩、macOS 无 zoom 退路、ReduceMotion 不自动 fallback = C21/C22/C23/C25/C30 依据）/ lens6 E2（单 attention template 序列化高亮 = C2/C24）/ lens5 F6（ContentView:122,126 二值 bug 坐实）。

---

## 联网核证据（URL + 日期，2026-06-23 检索）

- **Gauge `.accessoryCircular` = iOS16/iPadOS16/macOS13/watchOS7+**（WWDC22 SwiftUI 4）→ 项目 iOS17/macOS14 部署 **无需 #available**。证 C12 温度/开度环可行零守卫。[Apple accessoryCircular](https://developer.apple.com/documentation/swiftui/gaugestyle/accessorycircular) / [useyourloaf SwiftUI Gauges](https://useyourloaf.com/blog/swiftui-gauges/)
- **MeshGradient = iOS18/macOS15 only**，iOS17 部署必 `#available(iOS18,macOS15,*)` + RadialGradient/LinearGradient fallback。证 **C26「MeshGradient 必有低版本 fallback」正确且必要**。[Apple MeshGradient](https://developer.apple.com/documentation/swiftui/meshgradient) / [donnywals mesh gradients iOS18](https://www.donnywals.com/getting-started-with-mesh-gradients-on-ios-18/)
- **`navigationTransition(.zoom)` 在 macOS type-unavailable**（NavigationTransition 协议 macOS15 在，但 ZoomNavigationTransition 标 unavailable on macOS；zoom API 本身 iOS18 起）→ 证 **C21「不用跨栈 zoom」对 Mac 主舞台是被迫正确**，跨平台需 `#if os(iOS)` 边界。[createwithswift zoom transition](https://www.createwithswift.com/using-the-zoom-navigation-transition-in-swiftui/) / [theswift.dev zoom navigation](https://www.theswift.dev/posts/swiftui-zoom-navigation-transition/)
- **matchedGeometryEffect = iOS14**，同视图 isExpanded/ZStack 模式无需 #available；但 **LazyVGrid 懒渲染源 offscreen 未挂载会 break match + multiple-source 运行时报错**，社区共识切非 lazy `Grid` 修复。证 **C21 同视图状态切换可行 + C22「用 Grid 规避 matchedGeometry 懒渲染冲突」是正解**。[SwiftUI Lab matchedGeometry Part1](https://swiftui-lab.com/matchedgeometryeffect-part1/) / [hackingwithswift matchedGeometryEffect](https://www.hackingwithswift.com/quick-start/swiftui/how-to-synchronize-animations-from-one-view-to-another-with-matchedgeometryeffect)
- **LazyVGrid multiple-source matchedGeometry 运行时报错 + macOS zoom unavailable** 双坑实证。证 C22/C25 升级门。[Apple Forums matchedGeometry in LazyVGrid #669115](https://developer.apple.com/forums/thread/669115) / [SwiftUI Lab Part2](https://swiftui-lab.com/matchedgeometryeffect-part2/)
- **AVSpeechSynthesizer 首音延迟 0.6-1s+，iOS16 起持续未修 bug（FB11380447）**，文档化 workaround = pre-warm（启动空 utterance）+ 视觉先于 TTS。证 **C28「immediate ack 掩盖首音延迟 + 视觉动效先于/同步 TTS」是一手坑的正确缓解**。[Apple Forums AVSpeechSynthesizer delay #731238](https://developer.apple.com/forums/thread/731238) / [Apple Forums iOS15/16 lagging #715339](https://developer.apple.com/forums/thread/715339)
- **iOS/macOS Local Network privacy prompt 真实**：首次 Bonjour/NWBrowser 隐式触发，可在启动/意外时机弹窗，macOS 属 TCC + 跨版本行为不一致（iOS17 拒后需重启、iOS18 拒后仍可访问）。证 **C17 风险揭示：LAN 联动会引入授权弹窗，现场可能炸场**（应 gate 在用户动作后、且 demo 默认不开 LAN 才稳）。[Apple TN3179 Local network privacy](https://developer.apple.com/documentation/technotes/tn3179-understanding-local-network-privacy) / [nonstrict request local network permission](https://nonstrict.eu/blog/2024/request-and-check-for-local-network-permission/)
- **车机 HMI 范式（MBUX zero-layer / NOMI / 单 attention template / progressive disclosure）** 印证 C2/C5/C24/C10：常驻骨架 + 语音点名族浮现 + 渐进披露 + 多卡高亮单注意力。[Mercedes MBUX zero-layer](https://group.mercedes-benz.com/innovation/digitalisation/connectivity/mbux-interior-assist.html) / [aufaitux HMI 6 principles](https://www.aufaitux.com/blog/mi-design-principles-automotive-ux/)

---

## 反对 / 更好方案 / 漏洞（逐候选有问题的）

- **C1（开场 reveal 序列）**：漏洞——「全 10 族网格 reveal 扫一遍」与 C2/C5「序列化高亮、不同时闪」+ lens6 E1「10 族 > Miller 7±2，静态全网格抢注意力」**有张力**。开场 reveal 扫一遍是 wow，但若做成「10 卡同时浮现」会踩 lens6 T3 reflow 跳 + E1 过载。更好：开场用 Grid 常驻骨架（dim 静默）+ 单次轻 stagger（错峰 50ms），别全亮全闪。
- **C3（dim 族弱呼吸）**：可行性反对——「所有 dim 族保持极弱呼吸微光」= 10 张持续动画 offscreen pass（lens1 F8），违 C30/C13「只激活态卡 breathe」。dim 族应**静默**（颜色承载态，不呼吸），呼吸只给 satisfied。彩蛋「全部展示」低优先。建议降级合并进 C5。
- **C4/C16/C19/C20（双屏簇）**：C20 = C4+C16+C19 纯复述，**reject**。C4/C16/C19「iPhone 自包含」是纯端侧离线的默认形态，非决策（Leverage 低）。更好：合并成一条「iPhone 双实例自包含（默认形态）」+ 保 C18（唯一有 759pt 三屏独立技术内容）。
- **C9（同时只展开 1 族）**：与 C7（原地放大+blur）重叠（blur 全景其余 = 隐含只 1 族聚焦）。可合并进 C7。
- **C11 + C15**：讲同一件事两面（数据驱动派生 / enum+switch 非 AnyView），合并。C15 单独的 Non-dup=2。
- **C17**：「iPhone 独立不依赖 Mac」部分 = C16 重复（低 Leverage）；但「Bonjour/Network framework LAN 可选联动」部分**揭示真风险**（Local Network 授权弹窗炸场，联网坐实）→ 价值在风险揭示，不在「独立」。建议聚焦改写为「LAN 联动是否值得引入授权弹窗风险」的 grill 议题，且默认 demo 不开 LAN。
- **C21（matchedGeometry）+ C25（升级门）**：🔴 **应捆绑评审/拍板**，分裂评是漏洞。C21=想用 matchedGeometry hero，C25=先 opacity 保底验证后升级——是同一决策的「目标 vs 安全路径」。且 C21 与 **C22（Grid 非 LazyVGrid）强依赖**——C21 不绑 C22 则踩 LazyVGrid 崩坑。三者（C21/C22/C25）是一个决策包。这是 README 点名「必上抛磊哥」的事实型分歧，应作为一个议题上抛。
- **C13（~50% 吞吐量化）**：⚠️ 「与模型推理错峰互斥」对，但若 candidate 文案带具体吞吐百分比（如「掉 50%」），该数字是 lens 引用的泛 SwiftUI 经验值（`.layerEffect` 与 mlx 抢 GPU），**非本项目 A2 在 M5 上 Instruments 实测**——量化无一手，需实测坐实（A2 阶段跑 Instruments GPU timeline）。决策方向（shader 仅氛围+错峰）成立，但具体百分比不可当事实引。
- **C8（仅 4 族数据）**：⚠️ 「按线上优先级显 3-4 高频子 device」依赖各族 priority 排序，但 `contracts/state-cells.yaml` **无 priority 字段**，仅 ac/window/screen/ambient 4 族写了 state_cells（座椅/车门/音量/雨刮/天窗/香氛 6 族无 cell 数据）。C8 落地需先补 priority 字段 + 补全 10 族 cell 数据 → 现状数据缺口是隐藏前置（这正拉高 C8 的 Risk-Rev）。
- **C24（320ms/220ms 魔法数字）**：双参数防竞态的洞察对（聚焦展开与多意图 stagger 是两个独立时间轴，共用一个常量会竞态），但 320/220ms 是拍的，无 A/B 实测依据。更好：定「两个独立可调参数 + ReduceMotion 归零」的结构，具体值留实测调。
- **C27（4 段 sequencer + 合同回放）**：「合同回放」治脆弱性对，但 4 段固定序列对语音驱动 demo 偏脚本化——若客户随口说非脚本指令，sequencer 是否降级到自由响应？需明确 sequencer 是「golden run 回放」还是「实时响应编排」，否则脱稿即崩。
- **C28**：唯一漏洞——「视觉先于 TTS」要小心：视觉先亮、TTS 后到，若 TTS 内容与视觉不符（如安全拒识，视觉亮了但 TTS 说「不能开」）会矛盾。安全拒识/clarify 态应 TTS 与视觉**同步**，只有满足态可视觉先行。

---

## 你这视角 top 5 最该关注候选（可行性 / 端侧约束）

1. **C21 + C25 + C22（决策包）**：唯一事实型分歧（README 自己点名「必上抛磊哥」）。可行性裁决：matchedGeometry 在 LazyVGrid 崩 + macOS 无 zoom 退路（联网坐实）→ **必绑 C22 用非 lazy Grid，且 C25 升级门（默认 opacity 验后升）是把分歧转成证伪优先工程门的最优解**。三者应作为一个议题捆绑拍板，不可分裂。
2. **C28 TTS 时序**：唯一谈 AVSpeechSynthesizer 首音延迟的候选，一手坑（FB11380447，0.6-1s 持续未修）→ 正确缓解（pre-warm + immediate ack + 视觉先行）。现状 SpeechSynthesisEngine.swift fire-and-forget 完全没做。Non-dup/Verifiability/Risk-Rev 全高。
3. **C13 + C30 GPU/thermal 错峰**：端侧「不崩/反应快」北极星的真护栏——shader 与 mlx 抢 GPU + 暗底辉光 offscreen render + 投屏掉帧（lens 多路坐实）。但 C13 的吞吐百分比无一手，需 A2 Instruments 实测坐实。
4. **C12 控件缺口**：Leverage 最高的实质技术决策——Gauge `.accessoryCircular` iOS16 零守卫（联网坐实）覆盖温度/开度/音量，座椅多维+RGB 色环必自建。直接定可复用控件清单 + #available 边界。
5. **C2 多意图序列化高亮**：lens6 E2「单 attention template，视觉工作记忆同时只能一个」+ 车机 HMI 单注意力范式坐实 → 「序列化高亮不同时闪」是多意图联动不丢脸的核心，且现状 ContentView 完全无此机制（greenfield）。是 demo wow 的可行性关键。

---

## 评审元注（盲评纪律 + 口径）

- **未读** uiue-d1-d6-grill / grill-decisions-master（盲评铁律遵守）；只读 candidates-blind + 本地核锚（ContentView/store/state-cells/tokens/hig-rules/prototype/lens1-7）+ 联网。
- **分诊**：C21 = 事实型分歧（matchedGeometry 行不行可实测坐实）但**口径在于「用不用」需磊哥拍设计取向 + 是否接受 macOS 限制**——属事实型可坐实部分（已给技术裁决）+ 决策取向部分（上抛磊哥，与 C25 捆绑）。C20/C19/C16/C4 双屏簇 = 去重型（收敛）。C13 吞吐百分比 = 事实型（需 A2 实测，现无一手）。
- **不降级提醒**：C13/C30 是 star>1000 量产范式同源的「可靠性内核」（错峰/双通道/thermal），demo 不省（与项目「LoRA/安全门/契约 SSOT 不省」轻治理铁律同向）；但 C27 sequencer「合同回放」若过度脚本化反成 demo 脆弱点（脱稿即崩）—— 这是 demo 取巧的过度工程化边界，需问「是 golden run 回放还是实时编排」。
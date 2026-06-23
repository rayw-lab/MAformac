## Round 3 视角：更优方案 / 过度工程化（demo 轻治理 fit）/ 漏选项

> 盲评（未读 grill 结论文件）。本地核 = ContentView.swift / DemoVehicleStateStore.swift / state-cells.yaml / tokens.md / hig-liquid-glass-rules.md / scheme1.html / lens1-7。联网核 = SwiftUI API 版本 + Apple/社区坑。我这一视角专问三件事：① 有没有更简/更稳/更炸/更省的替代？② 是否 demo 过度工程化？③ 漏了哪个选项？

---

## 30 候选评分表（C1-C30 × 5 维 + Total，满分 25）

| ID | Importance | Verifiability | Non-dup | Decision-Lev | Risk-Reveal | **Total** | verdict |
|---|---|---|---|---|---|---|---|
| C1 | 3 | 3 | 4 | 3 | 2 | **15** | keep |
| C2 | 5 | 5 | 5 | 4 | 5 | **24** | keep |
| C3 | 2 | 3 | 3 | 2 | 2 | **12** | weak |
| C4 | 5 | 5 | 4 | 5 | 5 | **24** | keep |
| C5 | 4 | 4 | 3 | 4 | 4 | **19** | keep |
| C6 | 3 | 3 | 3 | 3 | 4 | **16** | weak |
| C7 | 4 | 4 | 4 | 3 | 4 | **19** | keep |
| C8 | 4 | 3 | 4 | 4 | 5 | **20** | keep |
| C9 | 3 | 4 | 2 | 3 | 3 | **15** | weak |
| C10 | 4 | 3 | 3 | 4 | 4 | **18** | keep |
| C11 | 4 | 5 | 4 | 3 | 3 | **19** | keep |
| C12 | 5 | 5 | 5 | 4 | 4 | **23** | keep |
| C13 | 4 | 3 | 4 | 4 | 4 | **19** | keep |
| C14 | 4 | 4 | 4 | 3 | 4 | **19** | keep |
| C15 | 3 | 5 | 2 | 3 | 3 | **16** | weak |
| C16 | 3 | 4 | 2 | 3 | 3 | **15** | weak |
| C17 | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C18 | 3 | 4 | 3 | 3 | 3 | **16** | weak |
| C19 | 2 | 3 | 1 | 2 | 2 | **10** | better-exists |
| C20 | 2 | 3 | 1 | 2 | 2 | **10** | better-exists |
| C21 | 5 | 5 | 5 | 4 | 5 | **24** | keep |
| C22 | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C23 | 4 | 4 | 4 | 4 | 4 | **20** | keep |
| C24 | 3 | 3 | 3 | 3 | 3 | **15** | weak |
| C25 | 4 | 4 | 3 | 4 | 4 | **19** | keep |
| C26 | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C27 | 4 | 3 | 4 | 4 | 4 | **19** | keep |
| C28 | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C29 | 4 | 4 | 4 | 3 | 4 | **19** | keep |
| C30 | 4 | 4 | 4 | 4 | 5 | **21** | keep |

---

## 视角专项发现（更优方案 / 过度工程化 / 漏选项）

**1. 过度工程化嫌疑（demo 轻治理 fit 警报）——最该被砍/简化的：**
- **C19 + C20 = 重复的"立场宣言"，几乎零新技术承诺**。C19「iPhone 独立无断连概念」+ C20「iPhone 不极简是独立全功能 demo」与 C4/C16/C17 完全重叠——它们只是把"双实例独立"换了三种说法。C4 已经物理化了这个决策（两个独立纯端侧实例），C19/C20 不逼出任何新承诺。**better-exists：C4 覆盖。** 这是典型的"候选膨胀"。
- **C9（同时只展开 1 族）是 C2/C7 的子集**。C2 已经定了"多卡只高亮不展开、单意图才展开"，C7 定了"原地放大+blur"，C9 的"只展开 1 族+其他 blur"是这两条的必然推论，没独立信息量。可并入 C7。
- **C27（4 段 sequencer + 合同回放）有过度工程化风险**。"sequencer + 合同回放"对 5min demo 是重武器——demo 取巧的做法是**硬编码一条线性脚本数组 + 计时器驱动**（就像 scheme1.html 已经做的 `scripts{}` 对象 + setTimeout），不需要"合同回放"治理层。Risk-Reveal 给 4 因为编排顺序本身是有价值的承诺，但实现形态应砍到"脚本数组"不是"sequencer 框架"。
- **C15（enum+switch 非 AnyView）正确但低杠杆**。这是 SwiftUI 工程常识（AnyView 抹杀编译穷尽+性能），写进候选像凑数。它是 C11 的实现细节，本身不是一个"设计决策"。Non-dup=2。

**2. 更优方案（我发现的替代）：**
- **C22 的更优替代已被我联网坐实，且比候选写的更强**：候选说"用 Grid 规避 matchedGeometry 懒渲染冲突"——这是对的，但**真正的根因是 Apple 确认的 LazyVGrid 崩溃 bug（FB11800180），社区实测换 iOS16 Grid/GridRow 后"crash no longer happening"**。所以 C22 不只是"规避懒渲染"，是规避一个**真实崩溃**。对 demo 北极星"不崩"这是 HIGH。建议把 C22 措辞从"规避懒渲染冲突"升级为"规避 LazyVGrid 已知崩溃 bug"。
- **C21 选 matchedGeometryEffect 不用 navigationTransition.zoom——我联网坐实这是被动正确不是主动炸场**：`navigationTransition(.zoom)` 在 **macOS 上根本不可用**（只 iOS18+），而 demo 是 **Mac 主舞台**。所以 C21 不是"两个都能用我选了更稳的"，是"Mac 上 zoom 压根没得选"。这反而强化 C21——但也暴露一个漏选项：**Mac 主舞台的聚焦动画事实上只有 matchedGeometryEffect 一条路**，候选应明说"非偏好是唯一可行"。
- **C26 MeshGradient——我联网坐实必须 #available**：MeshGradient 是 iOS18/macOS15，部署底线是 iOS17/macOS14，**不守卫直接崩**。C26 说"每个 shader 必有低版本 fallback"正确，但应点名 MeshGradient 是 iOS18 这条最危险的（hig-rules 已点名，候选未点名具体版本）。
- **更省的替代（orb）**：lens 提到 metasidd/Orb 422★ 但 2024-11 stale、依赖 PNG——候选 C26 说"自建 MeshGradient orb"是对的（不引 stale repo），省。

**3. 漏选项（候选集没覆盖的决策）：**
- 🔴 **漏了"投屏/现场环境"作为独立决策**。lens1+lens6 反复点名：本机主屏 = **1920×1080 非 Retina 外接屏**，投屏 8bit banding 是深空暗底的头号炸场风险，AirPlay 无线投屏动画必掉帧 → **现场必须有线 HDMI/USB-C 投屏**。30 个候选**没有一个**把"投屏方式/字号下限/banding dither"当成决策——C30 只笼统说"稳定优先"。这是最大漏洞：demo 在客户现场炸场的 HIGH 风险（撞磊哥飞书白皮书"全部太丑看不清"同坑）没有候选承载。
- 🔴 **漏了"字号物理下限"决策**。lens1 F4：1080p 投屏 body≥24pt、标题≥44pt 等效，现状 scheme1 `font.card.val 15px` 远低于演示下限。tokens.md 把字号锁成 15px。没有候选定"演示态字号放大"。
- **漏了"7 态色消费"作为正面决策**。ContentView.swift:122/126 现把 7 态压成绿/灰二值（lens5 F6 + tokens U10 头号翻车点坐实），tokens.md 已设计 7 态色但是 DRAFT 待审。候选 C11/C14 谈"骨架/分发"但没有一个候选明确"UI 必须消费全 7 态 visualState（clarify 琥珀/unsupported 灰锁/safety 红/crash 灰，绝不混红）"——这是 demo 智能感卖点，缺正面决策候选。
- **漏了"展开态二级下钻怎么排"**。lens1 elephant + lens7：某族（空调4区温度/车窗4门）展开后子项仍可能>6，展开态自己需二级网格/分区。C8 提了"超过用二级分区"但很弱，没人定展开态布局。

---

## 本地核证据（file:line）

- **ContentView.swift:40** = `LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)])` —— 现状用 LazyVGrid + adaptive 无 max + 喂 22 个 device 平铺（非 10 族）。撞 C10（不平铺）+ C22（应换 Grid）+ lens6 坑#1（adaptive 无 max → resize 重排）。
- **ContentView.swift:122,126** = `cell.visualState == .satisfied ? Color.green.opacity(0.18) : Color.gray.opacity(0.10)` 和 borderColor 同理 —— **7 态被压成绿/灰二值**，正是 tokens.md:64 + U10 头号翻车点。撞 C11/C14（值/态可视化）的现状缺陷。
- **DemoVehicleStateStore.swift:17-25** = `DemoVisualState` 7 态枚举（normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown）—— C11 的"5 类 value.type"是【值形态】维度，与这 7 态【状态】维度正交，C11/C14 须同时消费两个维度。
- **DemoVehicleStateStore.swift:134-159** = `defaultCells()` 22 个 cell（含 ac.temp_setpoint[主驾/副驾/左后/右后] 等带槽 key + 一组无槽 legacy key 如 hvac.ac/seat.driver.heat）—— 现状是 device 级平铺，无族聚合，撞 C10/C8。
- **contracts/state-cells.yaml** = 仅 **4 device 族（AC/window/screen/ambient）/ 12 个 state_cell**，**无 priority/高频/frequency 字段**（grep 实证空）—— 🔴 **直接证伪 C8 的可行性前提**："按线上优先级显 3-4 高频子 device"——优先级数据在 state-cells 里不存在。C8 要么补 priority 字段（治理成本），要么现场手挑高频子集（demo 取巧）。Risk-Reveal 给满分正因它揭示了这个数据缺口。
- **state-cells.yaml:59,95,129,155** = scope 字段（如空调 `[主驾,副驾,左后,右后,全车]`，"协议 38 温区→demo 精做 5"）—— C8/C10 的"族内子 device"在这里是 scope 维度，不是独立 device count；C10"角标显子能力数"的数据源应是 scope.count 不是 191。
- **tokens.md:54-62** = 7 态色映射表（含 satisfied=cyan+violet breathe / clarify=琥珀 / unsupported=灰锁 / safety=红 / crash=灰）—— C29 离线琥珀、C11/C14 态色全在此有 SSOT。但 **status: DRAFT 待磊哥审**，7 态色未冻结。
- **tokens.md:77-85 动效 token** = breathe 3.4s / pulse / spring / metal.ripple（U5 一期）—— C24（320ms/220ms）这两个魔法数字**不在 tokens.md**，是候选凭空给的；应进 tokens.md 单源。
- **tokens.md:67-73 字号** = `font.card.val 15px` —— 撞 lens1 F4 演示下限（≥24pt body），证 C30/缺失的"字号决策"漏洞。
- **hig-liquid-glass-rules.md:41-46** = #available 模板（glassEffect iOS26 → ultraThinMaterial iOS17）—— C26/C12 的版本守卫范式已在仓内。
- **hig-liquid-glass-rules.md:50** = "所有第三方 siri-orb repo 全 stale（373★/2024-06）别引；自建 MeshGradient orb" —— 证 C26 自建 orb 是省的正解。
- **scheme1-deep-space-interactive.html:157-163** = `scripts{}` 对象 + setTimeout 已实现"硬编码脚本数组驱动多意图联动"—— **证 C27 的 sequencer 是过度工程化**：原型用 12 行 JS 脚本对象 + setTimeout 就跑通了 5 个场景含多意图联动，不需要"合同回放"治理层。
- **scheme1.html:159-160** = `cold` 脚本里 `setCard('ac',true,'26°C'); setTimeout(()=>setCard('seat',true,'2 档'),350)` —— 已实现"序列化错峰高亮"（350ms 错峰），证 C2/C24 的 stagger 方向，且 220ms/320ms 应对齐这里的实测 350ms。
- **scheme1.html:85** = `@media (prefers-reduced-motion:reduce){*{animation:none!important}}` —— 原型已有 ReduceMotion 兜底意识，证 C30 双通道方向。

---

## 联网核证据（URL + 日期，2026-06-23 检索）

- **navigationTransition(.zoom) 在 macOS 不可用**（ZoomNavigationTransition 仅 iOS18/iPadOS18/tvOS18/watchOS11/visionOS2，macOS 缺席）→ 强证 C21 选 matchedGeometryEffect 是 Mac 主舞台的**唯一可行**非偏好。https://www.createwithswift.com/using-the-zoom-navigation-transition-in-swiftui/ + https://developer.apple.com/documentation/swiftui/navigationtransition
- **MeshGradient = iOS18/macOS15**，**Gauge .accessoryCircular = iOS16/macOS13** → C26 MeshGradient 必 #available（部署 iOS17/macOS14 不守卫崩）；C12 用 Gauge 无需守卫（安全）。https://developer.apple.com/documentation/swiftui/meshgradient + https://developer.apple.com/documentation/swiftui/gaugestyle/accessorycircular
- **matchedGeometryEffect = iOS14/macOS11** → C21/C25 无 availability 问题，C25"编译验证后才升级"是针对运行态抖闪/macOS 怪癖（合理但因 API 古老略保守）。https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:)
- **LazyVGrid 多 lazy 容器崩溃 bug（FB11800180），社区实测换 iOS16 Grid/GridRow 后"crash no longer happening"** → 强证 C22 用 Grid 非 LazyVGrid 是规避**真实崩溃**（不只懒渲染冲突），对北极星"不崩"是 HIGH。https://developer.apple.com/forums/thread/718741
- **AVSpeechSynthesizer 首次 speak() 有 IPC 连接延迟 ~0.6-1s（"IPCAUClient can't connect to server"/"AXTTSCommon Invalid rule"），pre-warm 后续即时；didCancel/didFinish 跨 iOS 版本路由不可靠，应在调用点自己记 stop flag** → 强证 C28（immediate ack 掩盖首音延迟 + 不靠 delegate 在调用点改态）两条都对。https://developer.apple.com/forums/thread/731238 + https://developer.apple.com/forums/thread/691347
- **Bonjour/NWBrowser LAN 实测 flaky（需 ~3s 延迟才稳 + mesh 去重问题 + iOS14+ 本地网络权限弹窗）** → 强证 C4/C17/C19/C20 把 iPhone 设为独立、LAN 联动仅可选加分是**正确的现场风险规避**（live demo 不能赌 LAN 联动 + 权限弹窗会毁场）。https://developer.apple.com/documentation/network/nwbrowser + https://developer.apple.com/news/?id=0oi77447
- **深空暗底 halation（~47% 散光人群光晕）+ 8bit 投屏 banding（高对比投影更糟）** → 证"投屏/字号/banding"漏选项是 HIGH（撞磊哥飞书白皮书同坑）。https://www.smashingmagazine.com/2025/04/inclusive-dark-mode-designing-accessible-dark-themes/（lens6 引）

---

## 反对 / 更好 / 漏洞（逐候选有问题的）

- **C1**：开场"全 10 族 reveal 扫一遍"在 1080p 投屏 + 10 张 breathe 同屏 = 10 个 offscreen 动画 pass（lens1 F8），且 reveal 动画+ReduceMotion 下被剥离瞬切。**更好**：开场只 orb 呼吸 + 静态 dim 网格淡入（一次性，非逐卡 reveal 扫），把"扫一遍"的动效预算省给后面单点聚焦炸场。Risk-Reveal=2（没揭示性能/ReduceMotion 风险）。
- **C2**：本视角**最强候选之一**。序列化高亮（非同时闪）有认知科学硬支撑（lens6 E2 Single-Item-Template：视觉工作记忆同时只能一个 attentional template）。无懈可击。唯一小漏：错峰时长应对齐 scheme1 实测 350ms / C24 的 220ms，需单源。
- **C3**：dim 族"极弱呼吸微光（非死灰）"与 lens1 F8"只激活卡 breathe，normal 静默省 9/10 动画"**直接冲突**——若 dim 族也呼吸，就是 10 张全动的性能坑。**反对**：dim 族应静默（颜色承载存在感），不呼吸。"全部展示彩蛋"是锦上添花低杠杆。weak。
- **C4**：本视角**最强候选之一**。双独立实例 = 规避 LAN flaky + 权限弹窗（联网坐实）。**这比任何跨屏同步方案都更简更稳**。完美 demo 取巧。
- **C5**：全景常驻+触发聚焦 = lens6 坑密度最低的 Form A（消除 reflow 跳动 HIGH 坑）。对，但与 C1/C7/C9 信息重叠（都在描述同一形态的不同面）。
- **C6**：语音为主+tap 为辅"两路同一入口"对，但**依赖 DEFERRED 的语音后端**——A2 阶段语音不实装（CLAUDE §9：训练/voice 延后）。**漏洞**：A2 能否用文本/按钮 mock 触发同一入口？若不能，C6 在 A2 无法验证。weak（时序依赖未解）。
- **C7**：原地放大+blur 非全屏 modal，对（避开 macOS 无 zoom transition）。但"全景 blur 背景"= 大面积 blur = offscreen render（lens1 F8），10 卡 blur 成本复合。**更好**：blur 只虚化全景一层（GlassEffectContainer 合并），别逐卡 blur。
- **C8**：**本视角高价值（揭示数据缺口）**。但可行性被本地核证伪——state-cells.yaml **无 priority 字段**（grep 空）。**反对纸面可行性**：要么补 priority（治理成本，违轻治理），要么**现场手挑高频子集**（demo 取巧，⭐推荐）。Risk-Reveal=5 正因揭示了"线上优先级"数据不存在。
- **C9**：C2+C7 的子集，无独立信息量。**建议并入 C7**。Non-dup=2。
- **C10**：折叠不平铺对（191 不平铺，本地核 22 device 平铺现状要改）。但"角标显子能力数"的**数据源是 scope.count（如空调 5 温区），不是 191**——候选若理解成"显 191 里该族的 device 数"会取错数。**漏洞**：角标数 fallback 应是 `device.scope.count` 或 state_cells.count，不是 191 拆分。
- **C11**：value.type 5 类 enum 从 state-cells 派生，对。但**漏了和 7 态 visualState 的正交关系**——值形态（连续/档/RGB/开关/多维）× 状态（normal/satisfied/clarify/unsupported/safety/crash/changing）是两个维度，C11 只覆盖值维度。须与缺失的"7 态消费"候选配对。
- **C12**：**本视角最干净候选之一**。"座椅多维+RGB 自建，其余原生 Gauge/分段/toggle"= 精确的 build-vs-adopt 边界。Gauge iOS16 无需守卫（联网坐实），省。无懈可击。
- **C13**：shader 仅氛围层非常驻 + GPU 与推理错峰，对（lens1 F8 + U30）。但"GPU 协调器"是治理重词——demo 取巧应是"水波只在断网高潮触发，平时不跑"（时间错峰，非运行时协调器）。轻量化措辞即可。
- **C14**：骨架统一只变值区 = lens6 E3"懂一张懂全部"。对。但同 C11 漏 7 态维度。
- **C15**：SwiftUI 工程常识（非 AnyView），是 C11 实现细节非独立决策。weak/凑数。
- **C16**：iPhone 独立全功能竖屏适配，与 C4/C18/C20 重叠。weak。
- **C17**：跨屏走 Bonjour LAN 可选联动 = 联网坐实 flaky，**正确地把它标为"可选"**。强。但应明写"现场默认不开 LAN 联动，开则接受权限弹窗+3s 延迟风险"。
- **C18**：iPhone 759pt 三屏分层（orb120/内容440/mic80）——**数字算术不严谨**：120+440+80=640≠759，剩 119pt 没交代。lens1 F5 实际是 orb+顶栏~120/对话流~200/mic~80→车控卡仅~360pt 且**必滚动**。C18 的"内容 440"与 lens1 的"车控卡 360+对话流 200"对不上。**漏洞**：分配数字需对齐 lens1 实测 + 明说必滚动。weak。
- **C19**：与 C4 完全重复（"iPhone 独立无断连概念"= C4 的双独立实例必然推论）。**better-exists：C4 覆盖。** 零新承诺。
- **C20**：与 C4/C16 完全重复（"iPhone 不极简是独立全功能"）。**better-exists：C4 覆盖。** 零新承诺。
- **C21**：**强**。matchedGeometry 不用 navigationTransition.zoom——联网坐实 zoom 在 macOS 不可用，是 Mac 主舞台唯一可行。建议措辞改"非偏好是唯一可行"。
- **C22**：**强**。Grid 非 LazyVGrid——联网坐实是规避 FB11800180 真实崩溃（不只懒渲染冲突）。对北极星"不崩"HIGH。建议升级措辞。
- **C23**：兜底动画（opacityScale+边框辉光+ripple）= matchedGeometry 不可用时的降级。对（lens6 推荐避开 matchedGeometry 用 opacity/scale）。好。
- **C24**：320ms/220ms 两个独立参数防竞态——**结构洞察对（展开 vs stagger 用不同时长）但数字是魔法数字**，不在 tokens.md（本地核），且与 scheme1 实测 350ms 错峰对不上。**更好**：数字进 tokens.md 单源 + 标"待实测校准"。weak。
- **C25**：升级门（默认 opacityScale，matchedGeometry 验证后升级）——对，但 matchedGeometry 是 iOS14 古老 API（联网坐实），"经编译验证"略保守；真风险在运行态抖闪/macOS quirk 不在能否编译。措辞应改"运行态稳定性验证"。
- **C26**：shader 选型（MeshGradient orb + ripple + Sinebow，每个必 fallback）——对。但应点名 **MeshGradient 是 iOS18 这条最危险**（部署 iOS17 不守卫崩，联网坐实），候选没说具体版本。
- **C27**：4 段序列化编排对（炸场顺序是有价值承诺），但"sequencer + 合同回放"= 过度工程化。**更好**：scheme1.html 已用 12 行脚本对象+setTimeout 跑通（本地核），demo 取巧用脚本数组+计时器，不要"合同回放"治理层。
- **C28**：**强**。端侧 AVSpeechSynthesizer + 动效先于/同步 TTS + immediate ack 掩盖首音延迟——联网坐实首次 speak() 有 0.6-1s IPC 延迟 + delegate 不可靠，两条都对。建议补"pre-warm 静音 utterance"（坐实的省延迟法）。
- **C29**：断网高潮（cyan→琥珀 morph + 100%端侧徽章）= scheme1.html:138-146 + tokens state.offline 已有范式。对，炸场刚需。
- **C30**：**强**。稳定优先于炸场 + 错峰 + ReduceMotion/低电量双通道 + thermal watchdog——是对的元决策。但**漏了投屏/字号/banding 这个最大现场风险**（见漏选项），C30 应吸收"现场有线投屏+字号下限+banding dither"。Risk-Reveal=5 因它是唯一谈现场稳定的候选，但覆盖不全。

---

## 我这视角 top 5 最该关注候选

1. **C4（双独立实例）= 最佳 demo 取巧决策**。联网坐实 Bonjour LAN flaky + 权限弹窗，"两个独立端侧实例、LAN 仅可选"是最简最稳的现场方案。它还**覆盖了 C19/C20（应判 better-exists）**——top 关注它能一并清理 3 个重复候选。

2. **C2（序列化高亮非同时闪）= 认知科学硬支撑的高杠杆决策**。Single-Item-Template 假说（视觉工作记忆同时一个 template）+ scheme1 已实测 350ms 错峰。它定了多意图联动"怎么演才不丢脸"，且与 C24（时长参数）必须配对单源。

3. **C22（Grid 非 LazyVGrid）+ C21（matchedGeometry 非 zoom）= 被我联网坐实"措辞低估了价值"的一对**。C22 实为规避 FB11800180 **真实崩溃**（北极星"不崩"HIGH）；C21 实为 Mac 主舞台**唯一可行**（zoom macOS 不可用）。两者都该从"偏好"升级为"硬约束"措辞。

4. **C8（高频子 device）= 揭示数据缺口的高 Risk-Reveal 候选**。本地核证实 state-cells.yaml **无 priority 字段**——C8 的纸面可行性被证伪。它逼出真决策："补 priority（治理成本，违轻治理）还是现场手挑高频子集（demo 取巧，⭐）"。这个数据缺口若不在 C8 暴露，会在 A2 实装时炸。

5. **C28（TTS 时序 + immediate ack）= 被联网强坐实的炸场刚需**。首次 speak() 0.6-1s IPC 延迟 + delegate 不可靠是真坑；"动效先于 TTS + immediate ack 掩盖首音延迟 + 调用点改态不靠 delegate"全部命中。建议补 pre-warm。对"反应快"北极星直接相关。

**附：top concern 之外最该补的——漏选项"投屏/字号/banding 现场环境决策"**。30 候选无一承载，但 lens1+lens6 把它列为 HIGH（撞磊哥飞书白皮书"全部太丑看不清"同坑）。建议新增一个候选或扩 C30：现场有线 HDMI 投屏 + 字号≥24pt body 等效 + 暗底渐变叠 IGN dither + #0a0b12 非纯黑。
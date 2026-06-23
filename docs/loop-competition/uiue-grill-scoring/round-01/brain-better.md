## Round 1 视角 = 更优方案 / 过度工程化 / 漏选项（盲评，30 候选）

> 盲评纪律：未读 grill SSOT / d1-d6-grill，只读 candidates-blind.md + 仓内核锚（ContentView/Store/state-cells/tokens/hig-rules/prototype/lens1-7/README）+ 联网。
> 本地事实层重大发现（影响全表评分基线）：**实际 `App/ContentView.swift` 只是 walking skeleton**（LazyVGrid 平铺 22 个 device、浅色 green/gray 二值卡、TextField 输入），**深空辉光 orb / 三屏分层 / 10 族 family card / 7 态色 全部尚未实现**。30 候选描述的是【目标设计】不是【现状】——所以这批决策本质是「待建实现的设计契约」，Verifiability 要按「API 是否可行 + 是否有一手研究/契约支撑」核，不是按「代码是否已如此」核。

---

## 30 候选评分表（C1-C30 × 5 维 1-5 + Total，满分 25）

| ID | Importance | Verifiability | Non-dup | Decision Leverage | Risk Revelation | **Total** | verdict |
|---|---|---|---|---|---|---|---|
| C1 开场帧序列 | 3 | 3 | 3 | 3 | 2 | **14** | weak |
| C2 多意图序列化高亮 | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C3 dim 族微光呼吸+彩蛋 | 2 | 3 | 3 | 2 | 3 | **13** | weak |
| C4 双屏=两独立全功能实例 | 4 | 4 | 3 | 4 | 5 | **20** | weak(过度工程化) |
| C5 全景常驻+触发聚焦 | 5 | 5 | 3 | 4 | 4 | **21** | keep |
| C6 语音为主+tap为辅同入口 | 4 | 4 | 4 | 4 | 3 | **19** | keep |
| C7 原地放大+blur 非全屏modal | 4 | 4 | 3 | 3 | 3 | **17** | keep |
| C8 显 3-4 高频子device | 3 | 3 | 3 | 3 | 3 | **15** | weak |
| C9 同时只展开1族 | 3 | 4 | 2 | 3 | 3 | **15** | weak(与C7/C5重) |
| C10 折叠不平铺+角标 | 4 | 5 | 3 | 4 | 4 | **20** | keep |
| C11 value.type enum 5类 | 5 | 5 | 4 | 4 | 4 | **22** | keep |
| C12 控件缺口=2自建其余原生Gauge | 5 | 5 | 4 | 5 | 4 | **23** | keep |
| C13 shader错峰互斥GPU协调 | 4 | 4 | 4 | 4 | 5 | **21** | keep |
| C14 卡片骨架统一只值区变 | 4 | 5 | 4 | 4 | 4 | **21** | keep |
| C15 enum+switch 非AnyView | 4 | 4 | 2 | 3 | 3 | **16** | weak(与C11重) |
| C16 iPhone独立全功能非镜像 | 3 | 4 | 2 | 3 | 4 | **16** | weak(与C4/C20重+过度) |
| C17 跨屏Bonjour/Network LAN | 3 | 4 | 3 | 3 | 4 | **17** | weak |
| C18 iPhone759pt三屏分层 | 4 | 5 | 3 | 4 | 4 | **20** | keep |
| C19 断连降级=iPhone无断连概念 | 2 | 3 | 2 | 2 | 3 | **12** | reject(循环论证) |
| C20 iPhone不极简=独立全功能 | 3 | 3 | 2 | 3 | 4 | **15** | weak(与C4/C16/C19重) |
| C21 matchedGeometry 不用zoom | 5 | 5 | 4 | 5 | 5 | **24** | keep |
| C22 Grid 非LazyVGrid | 5 | 5 | 4 | 5 | 5 | **24** | keep |
| C23 兜底动画 opacityScale | 4 | 5 | 3 | 4 | 4 | **20** | keep |
| C24 过渡时长 320/220ms 双参数 | 3 | 4 | 3 | 4 | 4 | **18** | keep |
| C25 升级门=默认opacity编译验证后升 | 4 | 4 | 3 | 5 | 4 | **20** | keep |
| C26 shader选型 MeshGradient+fallback | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C27 wow 4段序列化sequencer | 4 | 3 | 4 | 4 | 3 | **18** | keep |
| C28 TTS时序 immediate ack | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C29 断网高潮 morph+徽章 | 4 | 5 | 4 | 3 | 3 | **19** | keep |
| C30 稳定优先于炸场 | 5 | 5 | 4 | 5 | 5 | **24** | keep |

---

## 视角专项发现（更优方案 / 过度工程化 / 漏选项）

### 1. 最大过度工程化簇 = C4 / C16 / C19 / C20（双屏「两个独立全功能 demo」）
四个候选反复强调「iPhone 是独立全功能端侧 demo，各自跑模型+ASR+10族，脱机可独立全功能演示」。这与 **lens1 F2 + U1 拍板「primary_device=mac + iphone_role=bonus」** 正面冲突（lens1-local-hardware.md:16-17）。让 iPhone 也跑完整 Qwen3-1.7B + ASR + 10 族 = 翻倍的构建/测试/真机性能/散热风险，而销售场景方案经理只控一台 Mac 投屏。**更优 = iPhone 定位为「特写/对话流副屏」或干脆砍到 P2**，不做第二套独立模型实例。这是 demo 轻治理铁律（核心不省、全覆盖砍）被违反的典型——四条候选把「iPhone 加分屏」过度拔高成「第二个完整产品」。C19「iPhone 独立无断连概念」更是循环论证（"独立所以无断连" = 把假设当结论），零决策杠杆 → reject。

### 2. 候选簇内重复度过高（Non-duplication 拉低多条）
- C9（同时只展开1族）⊂ C5（全景常驻+触发聚焦）+ C7（原地放大blur），是其推论非独立决策。
- C15（enum+switch 非AnyView）⊂ C11（value.type enum+switch 派生）——C15 只是 C11 实现细节，单列稀释。
- C16/C20 与 C4 三条讲同一件事（iPhone 独立全功能），应合并成 1 条「双屏定位」决策 + 1 条「iPhone 竖屏布局」（C18）。**30 条里至少 4-5 条是拆碎的同决策**，真有效独立决策约 22-24 条。

### 3. 漏掉的高价值选项（候选集盲点）
- **🔴 7 态色语义映射缺失（最大漏洞）**：tokens.md:49-64 + README:40 都把「ContentView:122 现把 7 态压成 green/gray 二值」列为 **U10 头号翻车点**（clarify琥珀/unsupported灰锁/unsafe红/crash灰 四态必分开，是 demo「智能拒识」卖点）。30 候选**完全没有一条触及状态色语义**——全在讲布局/动画/炸场，漏了「卡片怎么表达 7 种执行结果状态」这个最 demo-critical 的视觉决策。这是整批候选最严重的集体盲点。
- **漏「字号投屏放大」决策**：lens1 F4 指出 scheme1 `font.card.val 15px` 远低于 1080p 投屏后排可读下限（body ≥24-28pt / 标题 ≥44pt 8H规则）。30 候选无一条定字号策略，而这是「客户现场看得清」北极星的硬约束。
- **漏「投屏 banding dither」决策**：lens1 F3 + lens6 T5 + 项目飞书白皮书血泪都指深空暗底大渐变投屏 8bit banding 高危，需 IGN dither。C30 笼统提「稳定优先」但没单列 banding 解法。
- **漏「橙色 golden step 氛围灯开场铺满」**：lens7 F2.4（U4）认为氛围灯调色铺屏是投屏冲击最强的开场，C27 的「氛围灯开场」太笼统没锚定这点。

### 4. 更稳/更简替代
- **C1**（开场 orb呼吸→10族reveal扫一遍→idle dim）：3 段开场动画在投屏 + ReduceMotion 下脆（lens6 T7 reveal 被剥离瞬切），且「全 10 族 reveal 扫一遍」与 C30「只激活态 breathe 省 9/10 动画」(lens1 F8)轻微张力。**更简 = 静态全景常驻直接亮**（lens README 否决 B 纯动态浮现的同理），开场不需要扫一遍。
- **C24** 双参数（320/220ms）方向对（防竞态），但「220ms stagger」与 lens6 E2 / lens2 T3 的「150-300ms 错峰」一致，**应锚定到研究区间**而非拍一个孤值；且应补 ReduceMotion 下两参数都归零的双通道。

---

## 本地核证据（file:line）

- `App/ContentView.swift:40` — `LazyVGrid(columns:[GridItem(.adaptive(minimum:160))])` 平铺 `store.cells`（22 device），**非 10 族 family card**（信息架构粒度错，C10/C22 修的正是这个）。
- `App/ContentView.swift:122,126` — `background = visualState == .satisfied ? green.opacity : gray.opacity` / `borderColor = .satisfied ? .green : .gray` = **7 态压绿/灰二值**（U10 翻车点，30 候选无一覆盖）。
- `App/ContentView.swift:26-34,8` — 输入是 **TextField「输入车控指令」+ 执行按钮**，无 orb、无语音入口（C6/C26 描述的语音驱动/orb 尚未实现）。
- `Core/State/DemoVehicleStateStore.swift:17-25` — `DemoVisualState` 7 态枚举（normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown）**已存在**，候选未消费它。
- `contracts/state-cells.yaml:57-84,90-101,143-161,176-187` — value 形态一手契约：int/celsius(18-32)/percent(0-100)/gear(1-10)/enum(8色/挡位)/exp_step offset/scope 多分区/safety（vehicle.speed,gear）。**C11 的「5 类 value.type」与此一致但需核对**：契约里实际形态 = 连续int温度/percent开度/gear档/enum开关+命名色/多维(座椅未在此文件出现) —— C11 列的「RGB」在契约里是 `ambient.color enum 8命名色`（state-cells.yaml:146）非真 RGB 色环，C11/C12 的「RGB 色环自建」可能过度（契约只要 8 色卡）。
- `docs/design/tokens.md:49-64` — 7 态色映射表（U10 四态分开铁律）+ §2 注明「ContentView:122 现二值=翻车」。**直接证明 30 候选漏掉状态色这一最 demo-critical 决策**。
- `docs/design/hig-liquid-glass-rules.md:17-21,48-52,67-76` — 三铁律（glass 仅功能层/iOS18+必#available/关键态双通道）+ MeshGradient #available 模板 + 动效坑表（numericText需withAnimation/Timer泄漏CPU/ReduceMotion剥离/barge-in didCancel/mlx冻主线程）——独立佐证 C21/C23/C26/C28/C30。
- `prototypes/scheme1-deep-space-interactive.html:41-53,85,138-146,166-179` — 原型仅 **2列×6卡**（非10族）、breathe/pulse 动画、`@media prefers-reduced-motion{animation:none}`、toggleNet 在线→离线morph + 多意图 `multi` 脚本。证明 C29（断网morph）/C2（多意图）原型已验，C1/C5（10族网格）/C26（orb）是扩展。
- `docs/research/.../lens1-local-hardware.md:16-17,28,35-37` — U1=mac主/iphone=bonus（直接反驳 C4/C16/C20 双独立实例）；iPhone 759pt 仅 ~360pt 给卡（C18 数字一致但「常驻10族」不可行需滚动）；F7「10族固定→Grid 非Lazy更优」（验 C22）。
- `docs/research/.../lens6-pitfalls.md:23-29,59-64,107` — T2(HIGH) matchedGeometry 在 LazyVGrid multiple-source 冲突 + macOS 无 zoom 退路（验 C21/C22）；T7 ReduceMotion 不自动 fallback matchedGeometry（验 C23/C25）；综合官倾向「聚焦禁用 matchedGeometry 改 opacity/scale」——**与 C21「用 matchedGeometry」存在口径分歧**（见漏洞段）。
- `docs/research/.../lens4-swift-components.md:25-31,44` / `lens7-recipe-boundary.md:11-23` — Gauge .accessoryCircular 连续值 + 座椅7级分段 + 色环（验 C12）。
- `docs/research/.../README.md:11-23,40` — 5 路收敛「A+B 合体=全景常驻+触发聚焦」（验 C5）；唯一待拍分歧=聚焦是否用 matchedGeometry（C21 单方拍了「用」，未反映这是争议项）。

---

## 联网核证据（URL + 日期，2026-06-23 检索）

- **MeshGradient = iOS18 / macOS15**（必 #available）— https://developer.apple.com/documentation/swiftui/meshgradient + https://www.donnywals.com/getting-started-with-mesh-gradients-on-ios-18/ 。验 **C26**（orb MeshGradient 必有低版本 fallback，部署 iOS17/macOS14 上裸用会崩）。
- **navigationTransition(.zoom)/matchedTransitionSource = macOS 不可用**（ZoomNavigationTransition unavailable on macOS，需 `#if os(iOS)` 不只 #available）— https://www.createwithswift.com/using-the-zoom-navigation-transition-in-swiftui/ + https://douglashill.co/zoom-transitions/ + https://github.com/hmlongco/Navigator/issues/25 。**强验 C21**（Mac 主舞台不能用跨栈 zoom，只能 matchedGeometryEffect）。
- **matchedGeometryEffect 在 LazyVGrid multiple-source 运行时警告 + 懒渲染源不存在；标准修法=小集合改非 lazy Grid**— https://swiftui-lab.com/matchedgeometryeffect-part2/ + https://developer.apple.com/forums/thread/689053 。**强验 C22**（10 族固定集用 Grid 规避 lazy source 冲突 = 业界 canonical fix，非杜撰）。
- **`Grid`（非lazy）= iOS16 / macOS13**，eager 渲染、适合小静态集 — https://developer.apple.com/documentation/swiftui/grid + https://www.avanderlee.com/swiftui/grid-lazyvgrid-lazyhgrid-gridviews/ 。验 **C22** API 在部署目标可用。
- **Gauge .accessoryCircular = iOS16 / macOS13**（无需 #available）— https://developer.apple.com/documentation/swiftui/gaugestyle/accessorycircular + https://useyourloaf.com/blog/swiftui-gauges/ 。验 **C12**（温度/开度/音量用原生 Gauge，零守卫）。
- **AVSpeechSynthesizer 首音延迟 ~0.6s（可达1-3s），iOS16+ 已知 bug；修法=app 启动 pre-warm + 长生命周期单例**— https://developer.apple.com/forums/thread/731238 + https://developer.apple.com/forums/thread/715339 + https://useyourloaf.com/blog/synthesized-speech-from-text/ 。**强验 C28**（immediate ack + 视觉先于 TTS 掩盖首音延迟是真实必要）。
- **MeshGradient + TimelineView(.animation) 在 ProMotion 上 60/120Hz 持续重绘 = 持续 GPU 占用，热/电真实**（修法 .periodic / ReduceMotion freeze / 少点慢动 / 3×3 mesh）— https://medium.com/@miltenkot/level-up-your-swiftui-migrating-from-task-loops-to-timelineview-for-high-performance-animations-3af5c3224fcb + nilcoalescing/createwithswift mesh 文章。验 **C13 / C30**（shader 与 mlx 错峰 + thermal watchdog + ReduceMotion 双通道）。
- **metasidd/Orb ~317★，无 release，最后实质活动约 2024 早，支持 iOS17/macOS14**— https://github.com/metasidd/Orb + https://swiftpackageindex.com/metasidd/Orb 。佐证 **C26**「不引现成 orb 自建 MeshGradient」方向（stale，按 github-first 60 天硬约束淘汰）；但需注意它技术上确实支持部署目标，「淘汰」理由是新鲜度非不可用。

---

## 反对 / 更好方案 / 漏洞（逐候选，仅列有问题的）

- **C1**：3 段开场动画在 ReduceMotion/投屏下脆（lens6 T7），且「全 10 族 reveal 扫一遍」与 C30「只激活态 breathe 省动画」张力。**更简 = 静态全景直接常驻亮**，开场不扫。漏 ReduceMotion 兜底。
- **C3**：10 张 dim 卡保持「极弱呼吸微光」= 10 个常驻 offscreen 动画 pass，违 lens1 F8 / C30「只激活态 breathe」。**反对**：dim 族应纯静态（颜色/数值承载），微光呼吸是反优化。「全部展示」彩蛋低价值。
- **C4 / C16 / C20**：🔴 过度工程化 + 违 U1（mac主/iphone bonus，lens1:16）。**更优 = iPhone 砍为副屏/特写或入 P2**，不做第二套独立模型实例（翻倍构建+真机散热风险）。三条应合并为 1 条双屏定位决策。
- **C9**：⊂ C5+C7 的推论，非独立决策。Non-dup 低。
- **C11 / C12**：契约 `ambient.color` 是 **8 命名色 enum**（state-cells.yaml:146）非真 RGB —— **C12「RGB 色环自建」可能过度**（demo 只要 8 色卡/预设，色环是量产形态）。lens7 F1 也说 native ColorPicker 两行够。**更简 = 8 色预设格 + 选中辉光**，不自建色环。
- **C15**：⊂ C11，实现细节单列稀释，建议并入 C11。
- **C17**：Bonjour/Network LAN 联动是「可选加分」却单列成决策——若 C4 砍掉 iPhone 独立实例，LAN 联动随之降级。低杠杆。
- **C19**：循环论证（"iPhone 独立所以无断连概念"=把假设当结论），零决策杠杆，**reject**。
- **C21**：单方拍「用 matchedGeometryEffect」，但 **lens6 综合官 + README 明示这是「唯一待磊哥拍的事实型分歧」**，倾向「禁用改 opacity/scale」（macOS 无 zoom 退路 + LazyVGrid 冲突 + ReduceMotion 不自动 fallback）。**漏洞=把争议项当已决项**。不过 C25（默认 opacity，编译验证后才升级 matchedGeometry）实际化解了这个张力——**C21 与 C25 应合并**，以 C25 的渐进升级门为准（opacity 是默认、matchedGeometry 是验证后增强），而非 C21 的「直接用 matchedGeometry」。
- **C27**：「合同回放 sequencer」对 5min 销售 demo 偏重（Mastra/量产编排形态），demo 轻治理下**更简 = 5 幕脚本按钮触发**（原型 prototypes html 已是此形态）。Verifiability 偏低（sequencer 合同回放尚无契约锚）。
- **C29**：方向对（原型已验 toggleNet morph），但漏「断网后模型/ASR 是否真在本机跑」的演示真实性——若只是 UI 假切（原型现状），客户问「真断网了？」需有真飞行模式演法。Risk Revelation 偏低。

---

## 你这视角 top 5 最该关注候选

1. **C30（稳定优先于炸场）— Total 24**：唯一把「demo 北极星=不崩」物理化成 thermal watchdog + ReduceMotion/低电量双通道 + shader 错峰的决策。联网证实 MeshGradient/TimelineView 持续 GPU + AVSpeech 首音延迟都是真热/真延迟风险。最高决策杠杆 + 最高风险揭示。
2. **C22（Grid 非 LazyVGrid）— Total 24**：API 可行（iOS16/macOS13）+ 业界 canonical fix（小固定集改非 lazy 规避 matchedGeometry multiple-source/懒渲染源缺失）+ 修掉 ContentView:40 现状 adaptive 平铺坑。证伪性满分、风险揭示满分。
3. **C21（matchedGeometry 不用跨栈 zoom）— Total 24，但需与 C25 合并**：联网铁证 macOS 无 zoom transition 退路。该关注是因为**它把唯一的事实型口径分歧（聚焦用不用 matchedGeometry）拍成了单方结论**，必须配 C25 的渐进升级门收口，否则埋一个未对齐决策。
4. **C12（控件缺口：2 自建其余原生 Gauge）— Total 23**：决策杠杆最高（明确 build vs reuse 边界）+ Gauge iOS16 零守卫可行。**但需纠 RGB 过度**（契约只要 8 命名色，色环是量产形态，demo 用色卡）。
5. **C2（多意图序列化高亮）+ 关注「漏掉的 7 态色」**：C2(23) 本身被 lens6 E2/lens2 T3「单一 attentional template 只能追一个」+ 原型 multi 脚本双重坐实，是炸场核心。但更该关注的是**整批候选集体漏掉「7 态执行结果状态色」**（tokens.md U10 头号翻车点 + ContentView:122 现二值）——这是比 C2 更 demo-critical 且无人提的视觉决策，应作为「漏选项」补一条候选。
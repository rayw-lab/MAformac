brain-2.md — UIUE 30 候选独立盲评（风险视角 / pre-mortem / tiger·paper-tiger·elephant）

> 盲评声明：未读 grill-decisions / uiue-d1-d6-grill。仅读 candidates-blind.md + 本地核锚（ContentView/DemoVehicleStateStore/state-cells.yaml/tokens.md/hig-rules/scheme1.html/lens1-7）+ 联网核（6 路 WebSearch）。
> 视角：每决策的漏洞/失败模式/边界/现场翻车/隐藏成本/与北极星冲突。
> 本地实况坐实：**ContentView 是裸 walking skeleton**（`LazyVGrid(.adaptive(160))` + visualState 二值绿/灰 + 无 MeshGradient/Gauge/matchedGeometry/Namespace/glassEffect/Grid）；Package.swift 部署 **iOS17/macOS14**；state-cells.yaml 当前仅 **12 cell / 6 device**（191/10族是契约目标非现态）。→ 30 候选**全是前瞻设计决策，零实装**，风险评估按"会不会现场炸"打。

## 30 候选评分表（C1-C30 × 5 维 + Total，1-5 分）

| ID | Imp | Ver | Non-dup | Lev | RiskRev | **Total** | verdict | 一句话风险 |
|---|---|---|---|---|---|---|---|---|
| C1 | 3 | 3 | 4 | 3 | 3 | **16** | keep | reveal 序列；但开场全网格 reveal 撞 reflow 跳 + Miller 过载，未带兜底 |
| C2 | 4 | 4 | 3 | 4 | 4 | **19** | keep | 序列化高亮=lens6 E2 硬证据（单 attentional template）；杠杆强 |
| C3 | 2 | 3 | 3 | 2 | 2 | **12** | weak | "极弱呼吸微光" = 10 卡同屏动画=offscreen pass 成本（lens1 F8）；彩蛋低杠杆 |
| C4 | 4 | 3 | 2 | 3 | 4 | **16** | keep | 双实例 reveal 隐藏成本（双份模型+ASR），但与 C16/C19/C20 高度重叠 |
| C5 | 4 | 4 | 3 | 4 | 3 | **18** | keep | 主形态共识（全景+聚焦），5 路 lens 收敛；与 C1 部分重叠 |
| C6 | 3 | 2 | 3 | 3 | 3 | **14** | weak | 语音入口=0，全依赖 ASR/LoRA 后端（部署 DEFERRED）→ 可证伪性低；形态决策本身有效 |
| C7 | 3 | 4 | 3 | 3 | 4 | **17** | keep | 原地放大+blur 避开 macOS 无 zoom 退路；但 blur=offscreen，10 卡背景 blur 成本 |
| C8 | 3 | 2 | 3 | 3 | 3 | **14** | weak | "按线上优先级"=契约无 priority 字段（state-cells 无优先级），仅 4-6 族有 cell 数据 |
| C9 | 3 | 4 | 2 | 3 | 3 | **15** | weak | =C7 同簇（单展开+blur 其余），独立度低 |
| C10 | 3 | 3 | 3 | 3 | 3 | **15** | keep | 191 不平铺正确；但 191 不在此契约（12 cell），角标子能力数无数据源 |
| C11 | 4 | 4 | 4 | 4 | 3 | **19** | keep | value.type enum+switch 已在 Core/Training 存在（C5RouteTier）；从数据派生=强 |
| C12 | 4 | 5 | 4 | 4 | 4 | **21** | keep | Gauge=iOS16 无需守卫（联网坐实）；座椅/RGB 自建=真控件缺口暴露 |
| C13 | 4 | 3 | 4 | 4 | 5 | **20** | keep | 🔴 错峰互斥洞察强（GPU 争用真实）；但 **"~50%吞吐量化"无一手**（联网无该数字），是 estimate |
| C14 | 4 | 4 | 4 | 4 | 4 | **20** | keep | 骨架统一=lens6 E3 + 飞书白皮书教训硬证据；防认知过载 |
| C15 | 3 | 5 | 3 | 4 | 4 | **19** | keep | 编译穷尽 enum>AnyView=可物理验（grep 无 AnyView）；与 C11 部分重叠 |
| C16 | 3 | 3 | 2 | 3 | 3 | **14** | weak | =C4/C19/C20 双屏簇，独立度低；竖屏适配本身合理 |
| C17 | 4 | 4 | 4 | 3 | 5 | **20** | keep | 🔴 **揭示 Local Network 授权弹窗炸场**（联网坐实 Bonjour 必弹窗）；LAN 联动本身低杠杆 |
| C18 | 3 | 4 | 2 | 3 | 3 | **15** | weak | 759pt 三屏分层=lens1 F5 实算（可证）；但与 C16 双屏簇混淆，是否独立技术决策存疑 |
| C19 | 2 | 2 | 2 | 2 | 2 | **10** | better-exists | =C4+C16+C20 复述（"独立无断连概念"），近纯重复 |
| C20 | 2 | 2 | 1 | 2 | 2 | **9** | reject | =C4+C16+C19 四合一，最弱去重项 |
| C21 | 4 | 5 | 4 | 4 | 4 | **21** | keep | 🔴 **唯一藏口径分歧**：matchedGeometry vs opacity/scale（联网坐实 macOS 无 zoom）；与 C25 升级门捆绑→上抛磊哥 |
| C22 | 4 | 5 | 4 | 4 | 4 | **21** | keep | Grid 非 LazyVGrid 规避 multiple-source/懒渲染源未挂（Apple Forums #669115 坐实）；强可验 |
| C23 | 3 | 4 | 3 | 3 | 4 | **17** | keep | 兜底动画必要（ReduceMotion/旧机）；但 ripple 又引 Metal=GPU 成本，兜底里塞特效自相矛盾 |
| C24 | 3 | 3 | 3 | 3 | 4 | **17** | keep | 双参数防竞态洞察有效；但 **320/220ms 是魔法数字**（无一手 timing 依据） |
| C25 | 4 | 5 | 3 | 5 | 4 | **21** | keep | 默认 opacity/scale + 编译验证才升级=最强杠杆（逼出验收门）；与 C21 同根 |
| C26 | 4 | 5 | 4 | 4 | 4 | **21** | keep | MeshGradient=iOS18 必 fallback（联网+Package.swift 双坐实）；每 shader 必兜底=硬约束 |
| C27 | 3 | 3 | 3 | 3 | 3 | **15** | keep | 4 段编排 reveal 价值；但"合同回放"依赖后端链路（DEFERRED），现场可演性存疑 |
| C28 | 4 | 5 | 4 | 4 | 4 | **21** | keep | immediate ack 掩首音延迟=AVSpeech 冷启 0.6-1s 真坑（联网坐实）；视觉先于 TTS=正解 |
| C29 | 3 | 4 | 3 | 3 | 3 | **16** | keep | 断网 morph=炸场点；但"全族卡断网保持响应"依赖端侧后端（DEFERRED 范围外） |
| C30 | 5 | 5 | 4 | 5 | 5 | **23** | keep | 稳定>炸场=北极星元决策；thermal watchdog+错峰+双通道=最高风险揭示，逼出全局门 |

## 视角专项发现（风险 / pre-mortem 三分类）

### 🐯 TIGER（明确威胁，带验证清单）

- **T1（HIGH）C21/C25 — 聚焦过渡技术分叉是事实型口径分歧，不解决=现场抖闪**：联网坐实 `.navigationTransition(.zoom)` 在 macOS **unavailable**（NavigationTransition 协议有、ZoomNavigationTransition 类型 unavailable），且 matchedGeometryEffect 在 LazyVGrid 有 multiple-source + 懒渲染源未挂 + 跨 NavigationStack 不工作三坑（Apple Forums #669115/689053）。**C21（用 matchedGeometry）与 lens6 倾向（禁用、改 opacity/scale）矛盾**。验证：iOS17 部署机 + macOS 主舞台实测全景→聚焦来回 10 次看抖/闪/重复 + 控制台 multiple-source 警告。🔴 **上抛磊哥拍**（C25 升级门正是这条的承载：默认 opacity/scale，编译验证后才升 matchedGeometry）。

- **T2（HIGH）深空暗底 halation + 投屏 8bit banding（撞磊哥飞书白皮书"全部都太丑看不清"同根）**：lens1 F3 + lens6 T4 双路坐实，base `#0a0b12` 近纯黑 + cyan `#00e5ff` 高饱和在散光人群（~47%）光晕，投屏 8bit 暗渐变 banding，高对比投影更糟。**30 候选里无一条专门管这个**（C26 管 shader fallback、C30 管错峰，但没人管"投屏后看得清吗"的验收门）→ **这是 30 候选集体盲点**（elephant 升 tiger）。验证：还原 1080p 投屏 + 暗房，逐张 Read，base 上抬 `#121212` 级 + glow 降饱和 + IGN dither。

- **T3 C13 — GPU 争用真实但"~50%吞吐"数字无一手**：联网坐实 Metal/MLX 与渲染共享 GPU pipeline、争用真实、MLX 串行单流；但**无任何源给"~50%"这个量化**（Apple 给的是"fuse/offload ANE"定性修法，非掉 50%）。机制可验（keep），数字是 estimate（写进契约前必标 [ESTIMATE]）。验证：A2 之后 Instruments 实测渲染 on/off 的 token/s 差，别凭 50% 拍。

- **T4 C24 — 320ms/220ms 是魔法数字**：双参数防竞态洞察对（聚焦展开与多意图 stagger 解耦），但**两个具体数字无一手 timing 依据**（lens 给的是"150-300ms 错峰"区间，非 320/220）。隐藏风险=数字写死进代码后无人知出处。验证：现场实测 + 区间内可调，别硬编。

- **T5 C8/C10 — "线上优先级"/"子能力数角标"无数据源**：state-cells.yaml **无 priority 字段**，当前仅 6 device / 12 cell 有数据（191/10族是 C1 jsonl 目标，不在此契约）。C8"按线上优先级显 3-4"、C10"角标显子能力数"都需要一个当前不存在的优先级/计数源。验证：先建 priority 字段或 fallback 到字典序，别假设数据已有。

### 🐅 PAPER-TIGER（看似威胁实际可控，给证据）

- **PT1 "10 族 = 10 卡太多会卡"**：lens6 PT1 坐实数量非瓶颈（FB8436070 是 20×20=400 才显），真坑是 per-cell 辉光 offscreen（C3/C30 已覆盖）。别因怕卡砍卡片数。
- **PT2 C12 "Gauge 自建复杂/版本风险"**：联网坐实 Gauge=iOS16/macOS13 **跨平台无需 #available**，`.accessoryCircular` 两行够（lens4 F4）。真缺口只在座椅多维+RGB 色环（C12 已识别要自建），其余原生。
- **PT3 C26 "MeshGradient 离线/兼容崩"**：离线是 paper-tiger（emoji+SF Symbols+system 字体栈零 CDN，lens hig-rules §5）；真风险只在 iOS18 版本守卫（C26 已带 fallback 要求）。Package.swift 部署 iOS17 坐实必须守卫。

### 🐘 ELEPHANT（没人提但该提）

- **E1 投屏验收门缺失**（升 T2）：30 候选无一条"还原用户投屏环境逐张验收"。这与全局 aesthetic-first + 飞书白皮书血泪同源，是该补的第 31 条决策。
- **E2 多个候选依赖 DEFERRED 后端**：C6（语音入口）/C27（合同回放）/C29（全族卡断网响应）/C28（端侧 AVSpeech）依赖 ASR/LoRA/链路后端，而项目 banner 明示"训练+后端开发 DEFERRED 延后不排期，A2 只 code-only"。→ 这些 UI 决策**现场可演性挂在未排期的后端上**，是隐藏依赖。验证：每条标"纯前端可 mock 演 / 需后端"。
- **E3 双屏簇（C4/C16/C17/C18/C19/C20）严重重叠**：6 条里实质决策只 3 个（独立全功能=C4/C16、跨屏 LAN=C17、竖屏 759pt 布局=C18），C19/C20 是 C4 的复述。去重后双屏应收敛到 ~3 条。
- **E4 异构值"懂一张懂全部"未保证骨架统一与值区分离的边界**：C14 对，但某族展开后子项 >6（空调 4 区温度、车窗 4 门）需二级网格/分区——lens1/7 elephant 提了"展开态自己需二级"，C8"超过用二级分区"碰了边但没说怎么不再过载。

## 本地核证据（file:line）

- `App/ContentView.swift:40` — `LazyVGrid(columns:[GridItem(.adaptive(minimum:160),spacing:12)])` 无 max → reflow/resize 跳（lens1 F13 + lens6 T3 已踩）。
- `App/ContentView.swift:122,126` — `cell.visualState == .satisfied ? .green : .gray` → 7 态压成二值（C11/C14/C15 要修的现态 bug，tokens.md:64 + lens5 F6 坐实）。
- `Core/State/DemoVehicleStateStore.swift:17-25` — `DemoVisualState` 7 态枚举（normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown）= C11/C14 消费源；C2/C5/C13 不碰此枚举。
- `Core/State/DemoVehicleStateStore.swift:135-158` — defaultCells 仅 22 cell（含重复 ac.power/hvac.ac 双轨）；contracts/state-cells.yaml 仅 6 device/12 id → C8/C10"191 device""线上优先级"无当前数据源。
- `Core/Training/C5LoRATraining.swift:12,38,195,199` — `C5RouteTier.derive(valueType:)` + `C5ValueStrategy.derive(valueType:)` 已是 enum+switch 从 value.type 派生 → **C11/C15 的"统一 enum+switch 从数据派生"已有同款先例**（强可验+一致）。
- `contracts/state-cells.yaml:9-16` — surface 边界注明 model-visible=D-domain 具名工具、canonical IR=device×action、cell 不随 surface 变 → C11"从 state-cells 派生 value 分发"与契约对齐。
- `contracts/state-cells.yaml:60,80,96,130,156,176` — execution_range 18-32/1-10/0-100% 实数据 → C12"温度/开度→Gauge 环"有真值域。
- `docs/design/tokens.md:39` — U11 halation 硬约束（cyan 散光占屏 30-60% 别铺满）→ C3/C30 的"极弱呼吸/错峰"对齐；30 候选无一条独立管投屏 banding（E1）。
- `docs/design/hig-liquid-glass-rules.md:41-46` — control_glass #available(iOS26)→ultraThinMaterial fallback 模板 → C26"每 shader 必 fallback"对齐。
- `Package.swift:8-9` — `.iOS(.v17),.macOS(.v14)` → MeshGradient(iOS18/macOS15)+glassEffect(iOS26) 必守卫（C2/C21/C22/C25/C26 前提坐实）。
- grep 全仓 App/Core 无 `AnyView` / 无 `matchedGeometry` / 无 `@Namespace` / 无 `Grid(` / 无 `MeshGradient` / 无 `glassEffect` / 无 `Gauge(` → 30 候选 UI **全未实装**，全前瞻设计（C15"非 AnyView"现态确实无 AnyView，可物理验）。

## 联网核证据（URL+日期，2026-06-23 检索）

- **Local Network 授权弹窗真实**（C17 隐藏风险坐实）：Bonjour/Network framework 发现/连接局域网设备 → iOS14+ 强制弹"X 想查找并连接本地网络设备" + 需 NSLocalNetworkUsageDescription + NSBonjourServices。最佳实践=延迟到用户交互再触发、优雅处理拒绝。[TN3179](https://developer.apple.com/documentation/technotes/tn3179-understanding-local-network-privacy) / [NSLocalNetworkUsageDescription](https://developer.apple.com/documentation/bundleresources/information-property-list/nslocalnetworkusagedescription)。→ C17 揭示的"双屏 LAN 联动会弹授权框炸场"成立，且 LAN 联动本身被定为 optional 加分（低杠杆，对）。
- **.navigationTransition(.zoom) macOS unavailable**（C21/C25 前提坐实）：ZoomNavigationTransition iOS18/iPadOS18/tvOS18/watchOS11/visionOS2，**macOS 缺席**；NavigationTransition 协议在 macOS15 有但 zoom style 不可用；matchedGeometryEffect 不能跨 NavigationStack。[createwithswift zoom transition](https://www.createwithswift.com/using-the-zoom-navigation-transition-in-swiftui/) / [theswift.dev zoom grid](https://www.theswift.dev/posts/swiftui-zoom-navigation-transition/)。→ C21"不用跨栈 navigationTransition.zoom，用 matchedGeometry"技术上对（macOS 没 zoom）；但 matchedGeometry 自身有坑→C25 升级门是正解。
- **matchedGeometryEffect + LazyVGrid 三坑坐实**（C22 前提坐实）：multiple-source（isSource 默认 true 双源 undefined）+ 懒渲染 offscreen cell 不存在无源 + 跨 NavigationStack/List 不工作。[Apple Forums #669115](https://developer.apple.com/forums/thread/669115) / [SwiftUI Lab Part2](https://swiftui-lab.com/matchedgeometryeffect-part2/)。→ C22"用 Grid（非 LazyVGrid）规避懒渲染 source 未挂载"成立。
- **MeshGradient=iOS18/macOS15、Gauge=iOS16/macOS13**（C12/C26 坐实）：[MeshGradient docs](https://developer.apple.com/documentation/swiftui/meshgradient)（iOS18+/macOS15+）/ [Gauge docs](https://developer.apple.com/documentation/swiftui/gauge)（iOS16/macOS13，accessory 样式跨平台、circular/linear 仅 watchOS）。→ C26 必 fallback 对；C12 Gauge 无需守卫对。
- **AVSpeechSynthesizer 首句冷启延迟真实**（C28 坐实）：iOS16 后 speak→didStart 间 0.6-1s+ 延迟（[AXTTSCommon] Invalid rule），修法=启动喂静音 utterance 预热 + 单长生命周期实例 + 真机测。[Apple Forums #731238](https://developer.apple.com/forums/thread/731238) / [#715339](https://developer.apple.com/forums/thread/715339)。→ C28"immediate ack 掩盖首音延迟 + 视觉先于 TTS"正解；预热应补进决策。
- **GPU 争用真实但无"~50%"量化**（C13 风险揭示部分坐实、数字 estimate）：Metal/MLX 与渲染共享 GPU pipeline，MLX 串行单流，修法=Metal4 fuse / offload ANE（Core ML），**无源给 50% 数字**。[WWDC25 #262](https://developer.apple.com/videos/play/wwdc2025/262/) / [MLX Apple Silicon](https://yage.ai/share/mlx-apple-silicon-en-20260331.html)。→ C13 错峰互斥洞察有效（GPU 争用真）、~50% 是未坐实 estimate。

## 反对 / 更好方案 / 漏洞（逐候选有问题的）

- **C1**：开场"全 10 族网格 reveal 扫一遍"撞 lens6 E1（10 族>Miller 7±2）+ T3 reflow，且首帧全网格亮=halation 最猛。**更好**：开场 orb 呼吸 + dim 全景常驻（不 reveal 逐个），第一句指令才点亮被控族（reveal 留给"全部展示"彩蛋 C3）。
- **C3**：彩蛋低杠杆 + "极弱呼吸微光"=10 卡同屏持续动画 offscreen 成本（lens1 F8）。**反对**：未激活族应**静默静态**（dim 不呼吸），只激活态 breathe，省 9/10 动画；微光彩蛋按需触发不常驻。
- **C4/C16/C19/C20**：双屏簇严重重复。**更好**：合并为 1 条"iPhone=独立全功能端侧实例（自含模型/ASR/10族），非镜像，双屏联动 optional"。C19/C20 reject/better-exists。
- **C6**：语音入口=0，全压在 DEFERRED 的 ASR/LoRA。**漏洞**：A2 code-only 阶段无法验证"语音为主"，现态只有 commandText TextField（ContentView:26）。应明确"前端先 mock 文本驱动，语音入口接口先留"。
- **C8/C10**：依赖不存在的 priority/子能力计数源。**漏洞**：state-cells 无优先级字段。**更好**：fallback 到契约声明序 + 角标显 device 数（state_cells.count，这个有），别假设"线上优先级"已有。
- **C13**：保留机制（错峰互斥），**删 ~50% 量化**或标 [ESTIMATE—A2 后 Instruments 实测]。GPU 协调器+模型推理互斥写法对。
- **C17**：LAN 联动揭示弹窗风险好，但**更激进**=现场 demo 干脆**不开 LAN 联动**（C4 已定双实例独立可演），把 Local Network 授权弹窗的炸场风险直接消除（产品约定收窄输入 > 技术兜底）。
- **C21**：单看是"用 matchedGeometry"，但 macOS 主舞台 matchedGeometry 有 LazyVGrid 坑。**与 C25 矛盾需统一**：C25 才是对的（默认 opacity/scale，验证后才升 matchedGeometry）。🔴 **C21/C25 捆绑上抛磊哥拍**（这是事实型可坐实但有口径选择：炫 vs 稳）。
- **C23**：兜底动画里塞"一次性 ripple"=又引 Metal shader=GPU 成本，**自相矛盾**（兜底本应是 matchedGeometry 挂了/低端机时用，却塞了个更贵的特效）。**更好**：兜底只用 opacity+scale+边框辉光，ripple 留给炸场高潮（C27 段4）不进兜底路径。
- **C24**：删硬编 320/220，改"聚焦 ~300ms / stagger 150-300ms 区间可调"，标无一手 timing。
- **C27**："合同回放"依赖后端链路（DEFERRED）。**漏洞**：A2 阶段只能 mock sequencer，需明确"前端 sequencer 先用假数据演，真合同回放接 C3 trace 后"。
- **C28**：正解，但**补一条**：启动喂静音 utterance 预热（联网坐实是消首句 0.6-1s 延迟的标准修法），别只靠 immediate ack 掩盖。
- **C29**："全族卡断网保持响应"依赖端侧后端跑通（DEFERRED）。A2 阶段=纯前端 morph + mock state，断网响应是 mock 的，需诚实标"现场演的是 mock 断网，非真端侧推理"。
- **C30**：最强，无反对。**唯一补充**：thermal watchdog/低电量/ReduceMotion 三通道之外，再加**投屏验收门**（E1，30 候选集体盲点），并入 C30 的"稳定优先"框架。

## 你这视角 top 5 最该关注候选

1. **C21 + C25（捆绑）— 🔴 唯一藏事实型口径分歧，必上抛磊哥**：matchedGeometry（炫）vs opacity/scale（稳），macOS 无 zoom 退路 + LazyVGrid 三坑（联网坐实）。C25 的"默认稳、编译验证后才升"是正解，C21 单独看会被误读成"就用 matchedGeometry"。这是�con vs稳的产品选择，不是纯技术对错。
2. **C30 — 稳定>炸场元决策（Total 23 最高）**：直接守北极星"不崩>惊艳"，thermal/低电量/ReduceMotion 三通道 + 错峰=最高风险揭示，逼出全局发布门。建议把 E1 投屏验收门并进来。
3. **C17 — 揭示 Local Network 授权弹窗炸场（联网坐实必弹窗）**：双屏 LAN 联动会触发系统授权框，现场最尴尬的"突然弹权限"翻车点。更激进解=现场不开 LAN（产品约定消除风险）。
4. **C13 — GPU 争用错峰互斥洞察强，但~50%是 estimate**：机制真（渲染抢 GPU 掉吞吐）、修法真（错峰/offload ANE），唯独 ~50% 无一手，写进契约前必标。这是事实型——数字要么实测要么标 estimate。
5. **T2/E1 投屏 banding + halature 是 30 候选集体盲点（升 tiger）**：撞磊哥飞书白皮书"全部都太丑看不清"同根，lens1 F3 + lens6 T4 双路坐实，但 30 候选无一条独立管"投屏后看得清吗"的验收门。应补第 31 条决策或并入 C30。
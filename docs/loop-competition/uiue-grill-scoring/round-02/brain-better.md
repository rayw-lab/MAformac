## Round 2 盲评：更优方案视角（每决策有没有更简/更稳/更炸场/更省的替代 + 过度工程化 + 漏了的选项）

> 评审人：Round2「更优方案」视角。已本地核（ContentView/DemoVehicleStateStore/state-cells.yaml/tokens.md/hig-rules/scheme1原型/lens1-7）+ 联网核（SwiftUI API 版本/Bonjour 隐私弹窗/TTS 首音延迟/GPU 争用/zoom transition macOS 不可用）。盲评：未读任何 grill/decisions 结论文件。
> 关键事实底座：当前 `ContentView.swift` 是极简 walking skeleton（TextField 输入非语音、LazyVGrid、8 张硬编码卡、绿/灰二值、零 orb/shader/matchedGeometry）。30 候选**全是 aspirational 设计决策，尚未实装**。state-cells.yaml 只有 **12 个 cell（5 设备）**，191 device / 10 族数据是目标态非现状。部署 **iOS17/macOS14**（iOS18+ API 必 #available）。

## 30 候选评分表（C1-C30 × 5 维 + Total，满分 25）

| ID | Imp | Ver | Non-dup | Lev | Risk | Total | verdict |
|---|---|---|---|---|---|---|---|
| C1 开场序列 | 3 | 3 | 4 | 3 | 2 | 15 | weak |
| C2 多意图序列化高亮 | 5 | 5 | 5 | 4 | 4 | 23 | keep |
| C3 dim 微光+彩蛋 | 2 | 3 | 4 | 2 | 2 | 13 | weak |
| C4 双屏独立实例 | 4 | 4 | 2 | 4 | 4 | 18 | keep |
| C5 全景常驻+触发聚焦 | 5 | 4 | 4 | 5 | 3 | 21 | keep |
| C6 语音为主 tap 为辅 | 4 | 3 | 4 | 4 | 2 | 17 | keep |
| C7 原地放大+blur | 4 | 4 | 4 | 3 | 3 | 18 | keep |
| C8 子device 3-4 高频 | 4 | 3 | 4 | 4 | 3 | 18 | keep |
| C9 同时只展开1族 | 3 | 4 | 3 | 3 | 3 | 16 | weak |
| C10 折叠不平铺+角标 | 4 | 4 | 4 | 4 | 3 | 19 | keep |
| C11 value.type enum 派生 | 5 | 5 | 4 | 4 | 3 | 21 | keep |
| C12 控件缺口自建 | 4 | 5 | 4 | 4 | 3 | 20 | keep |
| C13 shader 错峰互斥 | 4 | 3 | 4 | 4 | 4 | 19 | keep |
| C14 卡片骨架统一 | 4 | 4 | 3 | 4 | 4 | 19 | keep |
| C15 enum+switch 非 AnyView | 4 | 5 | 2 | 3 | 3 | 17 | weak |
| C16 iPhone 独立全功能 | 3 | 4 | 2 | 3 | 2 | 14 | weak |
| C17 Bonjour LAN 可选联动 | 4 | 5 | 4 | 4 | 5 | 22 | keep |
| C18 iPhone 759pt 三屏 | 4 | 5 | 4 | 4 | 3 | 20 | keep |
| C19 断连降级=无断连概念 | 3 | 4 | 2 | 3 | 3 | 15 | weak |
| C20 双屏定位=独立全功能 | 2 | 3 | 1 | 2 | 2 | 10 | reject |
| C21 matchedGeometry 过渡 | 5 | 5 | 4 | 5 | 4 | 23 | keep |
| C22 Grid 非 LazyVGrid | 4 | 5 | 4 | 4 | 4 | 21 | keep |
| C23 兜底动画 opacityScale | 4 | 4 | 4 | 4 | 4 | 20 | keep |
| C24 过渡时长双参数 | 3 | 3 | 3 | 3 | 3 | 15 | weak |
| C25 升级门编译验证 | 4 | 4 | 4 | 5 | 4 | 21 | keep |
| C26 shader 选型+fallback | 4 | 5 | 4 | 4 | 4 | 21 | keep |
| C27 4 段序列 sequencer | 4 | 3 | 4 | 4 | 3 | 18 | keep |
| C28 TTS 时序 immediate ack | 4 | 5 | 4 | 4 | 4 | 21 | keep |
| C29 断网高潮 morph | 4 | 4 | 3 | 3 | 3 | 17 | keep |
| C30 稳定优先于炸场 | 5 | 4 | 4 | 5 | 5 | 23 | keep |

## 视角专项发现（更优方案 / 过度工程化 / 漏了的选项）

**1. 双屏簇（C4/C16/C17/C18/C19/C20）严重过度切分 + 一个 reject。** 六个候选只承载 ~3 个独立决策：(a) iPhone 独立全功能非镜像（C4/C16/C19/C20 四次重复）；(b) 跨屏方式 Bonjour LAN（C17，唯一独立技术决策且暴露最大风险）；(c) iPhone 竖屏布局（C18，独立但有漏洞）。**C20 = C4+C16+C19 同义反复，应 reject 合并。** 更优方案：双屏簇砍成 3 个候选（独立性形态 / 跨屏技术 / 竖屏布局）。

**2. C13「~50% 吞吐」量化无一手——机制对、数字假。** 联网核：GPU 争用机制成立（shared GPU + unified memory bandwidth，LLM token 生成 memory-bandwidth bound，animated layerEffect = background system load），但「掉 50%」**无任何 benchmark 源**（搜索明确「no single source directly documents the specific throughput drop」）。同 lens6/lens1 也只给机制不给数字。**更优承诺：把「50%」改成「A2 用 Instruments GPU/Metal HUD 实测错峰前后 token/s + 帧率，数字以实测为准」**，别在文档钉死未验数字（撞 claim-vs-reality 第8坑）。

**3. C8「3-4 高频子 device」缺数据支撑——契约只有 12 cell。** C8 说「按线上优先级」显高频，但 state-cells.yaml 只覆盖 5 设备/12 cell，无 priority 字段、无线上调用量数据。「3-4 高频」是凭感觉拍的魔法数字。**更优方案：先在契约加 priority/freq 字段（从 3990 协议表线上口径派生），或老实降级为「展开态先画该族已建 cell，未建走 L2 占位」。** demo 轻治理下，3-4 可接受为现场约定收窄输入，但别声称有数据。

**4. C17 揭示最大单点炸场风险（Local Network 隐私弹窗），是全集最高 Risk Revelation。** 联网核坐实：首次 NWBrowser 触发系统弹窗「Allow X to find devices on local networks?」，且行为**跨设备/OS 极不稳定**（有时不弹、有时静默失败 PolicyDenied、Xcode16 simulator 直接坏）。客户现场弹这个 = 直接打脸「100%端侧·0网络」叙事。**这正反证 C19「iPhone 独立无断连概念」的智慧——最优解可能是 demo 现场根本不开 LAN 联动（C17 标 optional 是对的，但应进一步:默认关闭 LAN、靠预先授权 + 现场禁用作为兜底）。** C17 把它标 optional 加分项是正确取舍，Risk 给满分 5。

**5. C21 藏唯一事实型口径分歧，应上抛磊哥。** C21 选 matchedGeometryEffect（同栈状态切换）而非 navigationTransition.zoom——联网核证实这**技术上被迫**（zoom transition 在 macOS 不可用，matchedGeometry 无法跨 NavigationStack 导航）。但 lens6 主张「macOS 无 zoom 退路 + ReduceMotion 坑 → 干脆禁 matchedGeometry 改 opacity/scale」。**这是「hero morph vs opacity/scale」的事实型分歧，且与 C25 升级门捆绑**——matchedGeometry 在 LazyVGrid 有 multiple-source 运行时冲突 + 懒渲染源未挂载。C25 的「先 opacity/scale 默认、matchedGeometry 编译验证后才升级」是更稳的解法。建议：C21 与 C25 合并为一条「过渡 API 降级门」决策，上抛磊哥拍 hero-morph 是否值得这个坑。

**6. C6 形态决策有效但 feas 被语音入口拖累。** C6「语音为主 tap 为辅，两路同入口」形态正确（lens2 F6 dual-modality「说+显」+ 68% 用户需视觉确认），但「语音入口」当前**完全没实装**（ContentView 是 TextField，ASR/LoRA 后端是 DEFERRED）。Verifiability 因「依赖未交付的语音链路」压到 3。形态决策本身有效，应 keep，但承诺要诚实：UIUE 阶段只能做 tap + 文本输入双路，语音入口随后端解冻才接。

**7. C24「魔法数字」320/220ms 揭示双参数防竞态洞察，但数字无依据。** 双独立参数防竞态是真洞察（聚焦展开 vs 多意图 stagger 解耦），但 320/220 具体值无源（lens2/lens6 给的是 150-300ms 错峰区间）。**更优：把数字进 tokens.md（motion token 单源）+ 标「现场实测微调」，别散在候选里钉死。** 220ms stagger 略偏快（lens6 给 150-300ms，220 在区间内 OK；320ms 展开略长，可能拖慢「反应快」体感，建议 250-280ms 实测）。

**8. 漏了的选项（无候选覆盖）：** (a) **unsupported 兜底 UI 的呈现形态**——lens3 E3/lens7 明确「族外 unsupported 怎么显示没人设计」（灰锁卡 vs 摇头动画 vs「演示版未开放」），这是不丢脸的关键却无候选；(b) **orb 状态机对齐链路阶段**（聆听/思考/确认三态映射 ASR/LLM/卡片浮现，lens2 E3/F6）——C26 只提 orb shader 选型，没提 orb 状态机；(c) **跨屏/orb→被控族 spatial 连线**（lens3 E2，因果可视化炸场点）；(d) **投屏 dither 消 banding**——lens1/3/6 三路都点名深空暗底投屏 banding 是 TIGER，但 30 候选**无一提 IGN dither / 字号投屏下限 ≥28pt / 对比 ≥7:1**，这是「看着惊艳」北极星的最大隐藏雷却全漏。

**9. 过度工程化检查（demo 轻治理 fit）：** 整体 30 候选过度工程化不严重（多数是合理 demo 决策）。轻微：C27「sequencer + 合同回放」对 4 段编排可能偏重——demo 现场固定话术，简单 PhaseAnimator/序列 .delay 够，「合同回放」治理是量产味，建议保留 sequencer 砍「合同回放」。C15「enum+switch 编译穷尽非 AnyView」是正确工程纪律不算过度（Swift 性能 + 类型安全本来就该这样），但作为独立「设计决策」杠杆低（是实现细节非决策）。

## 本地核证据（file:line）

- `App/ContentView.swift:8` `commandText="打开空调"` + `:26` TextField — **现状是文本输入非语音**，C6 语音入口未实装。
- `App/ContentView.swift:40` `LazyVGrid(.adaptive(minimum:160))` — 现状用 LazyVGrid + adaptive 无 max（lens6 T3 已踩 reflow 坑），C22 改 Grid 正是修这个。
- `App/ContentView.swift:122,126` `visualState==.satisfied ? .green : .gray` — **7 态压成绿/灰二值翻车点**（tokens.md:64 + lens5 F6 警告），C11/C14 的 enum 派生正是解此。
- `Core/State/DemoVehicleStateStore.swift:17-25` `DemoVisualState` 7 态枚举（normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown）— **C11 value-state 派生的数据底座已存在**，C11 可证实。
- `contracts/state-cells.yaml` 全文仅 **12 个 cell id（5 设备 ac/window/screen/ambient + safety）** + 有 `type:`/`execution_range:`/`exp_step:` 字段 — 证实 C11（value.type 从 state-cells 派生）可行；同时证伪「191 device/10 族数据已就绪」，C8「3-4 高频」无 priority 字段支撑。
- `contracts/state-cells.yaml:62,80,96,130` execution_range 18-32℃/风量1-10/车窗0-100%/亮度0-100% — 证实 C11/C12 的异构值范围真实。
- `tokens.md:54-62` 7 态色映射表 + `:64` 「ContentView:122 现把所有非 satisfied 渲成灰」— C11/C14 的 SSOT 已建。
- `tokens.md:83` `motion.metal.ripple = Inferno RippleEffect（U5 一期做）` — C26 ripple 水波选型有 SSOT 锚。
- `hig-liquid-glass-rules.md:15` 部署 iOS17/macOS14 + iOS18+ 必 #available — 证实 C19/C25/C26/C2-rule 的 #available 要求。
- `hig-liquid-glass-rules.md:50` orb=native MeshGradient + 「第三方 siri-orb repo 全 stale（373★/2024-06）别引」+ `:64` adopt Inferno strength3/freq10 — C26 选型有据。
- `hig-liquid-glass-rules.md:26`（lens6 引）macOS 上 `ZoomNavigationTransition` unavailable — C21 选 matchedGeometry 被迫成立。
- `Package.swift:8-9` `.iOS(.v17), .macOS(.v14)` — 部署目标坐实。
- `prototypes/scheme1-deep-space-interactive.html:159,160,162` setTimeout 350ms 串行点亮 — C2/C24 序列化错峰已有原型范式；`:138-146` 在线→离线 morph（net.off → #ffb13c）— C29 已有原型。
- `docs/research/.../lens6-pitfalls.md:23-29`（T2 HIGH）matchedGeometry 在 LazyVGrid multiple-source 冲突 + macOS 无 zoom 退路 — C21/C22/C25 风险底座。
- `lens1-local-hardware.md:F5,F7` iPhone 15 Pro 安全区可用高 759pt / 车控卡区仅 ~360pt（放不下 10 族常驻）+ Grid 非 Lazy 更优 — C18 的 759pt 真实但「三屏分层装得下」有漏洞（C18 没说必须滚动）；C22 Grid 选择有据。
- `lens6:67`（PT1）10 卡数量非性能瓶颈（FB8436070 是 20×20 才显），真坑是 per-cell 辉光复杂度 — C13 把焦点放 shader 错峰是对的方向。
- `INDEX.md:44` 点 5 明确标「聚焦过渡 = 事实型分歧上抛磊哥（G2）」— 证实 C21 是口径/事实分歧需拍板。

## 联网核证据（URL + 日期，2026-06-23 检索）

- **matchedGeometryEffect 不能跨 NavigationStack + zoom transition macOS 不可用**（C21 被迫成立 + C25 升级门合理）：[createwithswift zoom transition](https://www.createwithswift.com/using-the-zoom-navigation-transition-in-swiftui/) + [theswift.dev zoom grid](https://www.theswift.dev/posts/swiftui-zoom-navigation-transition/) + [Apple Forums #719835](https://developer.apple.com/forums/thread/719835) —「ZoomNavigationTransition type marked unavailable on macOS」「matchedGeometryEffect can't be used for navigation between screens in a NavigationStack」。
- **API 版本**（C19/C25/C26/C2-rule 的 #available）：[Apple MeshGradient docs](https://developer.apple.com/documentation/swiftui/meshgradient)（iOS18.0+/macOS15.0+）+ [Apple Gauge docs](https://developer.apple.com/documentation/swiftui/gauge)（iOS16.0+）+ [designcode matchedGeometry iOS14](https://designcode.io/swiftui2-matched-geometry-effect/)（iOS14.0+）— 全确认 MeshGradient/glassEffect 必守卫、Gauge/matchedGeometry 不需守卫。
- **Local Network 隐私弹窗**（C17 最大风险 + C19 反证）：[Apple TN3179 local network privacy](https://developer.apple.com/documentation/technotes/tn3179-understanding-local-network-privacy) + [Nonstrict request local network permission](https://nonstrict.eu/blog/2024/request-and-check-for-local-network-permission/) —「first time you instantiate NWBrowser, it will prompt」「behavior is inconsistent across devices/OS versions, sometimes never appears, sometimes silently fail PolicyDenied」「Xcode16.4 simulator popup doesn't appear」。
- **AVSpeechSynthesizer 首音延迟**（C28 immediate ack + warm-up 正确）：[Apple Forums #715339](https://developer.apple.com/forums/thread/715339) + [Apple Forums #731238](https://developer.apple.com/forums/thread/731238) —「lag between speak() and didStart, 0.6s~3.2s, tied to loading voice rule data from disk」「workaround: warm up synthesizer early with silent utterance + pre-instantiate + activate audio session in advance」。
- **GPU 争用机制成立但「50%」无源**（C13 数字假/机制真）：[mlx-swift](https://github.com/ml-explore/mlx-swift) + [jacobstechtavern Metal shaders](https://blog.jacobstechtavern.com/p/metal-in-swiftui-how-to-write-shaders) —「both shaders and inference kernels contend for GPU execution units AND shared memory bandwidth, a key throughput limiter during LLM token generation」「no single source directly documents the specific throughput drop benchmark」。
- **Inferno / Orb 新鲜度**（C26 选型）：lens5/INDEX gh 核 Inferno 2879★/2026-05-17（fresh）· metasidd/Orb 422★/2024-11（stale 19mo，只抄纯代码子件）· 第三方 siri-orb 373★/2024-06（淘汰）— 与 hig-rules:50 一致。

## 反对 / 更好方案 / 漏洞（逐候选有问题的）

- **C1（开场序列）漏洞**：「全 10 族网格 reveal 扫一遍」可能撞 lens6 T1（10 张同屏 reveal 动画 = 10 个 offscreen pass 叠加掉帧）+ T4（深空暗底 10 卡同时辉光 halation 过载）。更稳：开场只 reveal dim 网格（静态浮现，不全部 breathe），breathe 只给激活卡（lens1 F8「只激活卡动省 9/10 动画」）。Risk 给 2 因它乐观没提这个。
- **C3（dim 微光彩蛋）反对**：「全部展示」语音彩蛋 = 让 10 卡同时全亮全 breathe = 直撞 GPU/halation 双坑，是炫技反 demo 稳定性。更优：彩蛋改「序列扫过点亮」（仍序列化非同时），或干脆砍（demo 轻治理，彩蛋低 ROI 高风险）。
- **C9（同时只展开1族）vs C2 部分冲突**：C9 说「同时只展开 1 族」，但多意图（C2「放歌+空调」）要联动 2+ 族。需澄清：C9 的「展开」=细控聚焦（一次一族对），「高亮联动」≠展开（可多族序列高亮不展开）。两者其实兼容但表述易冲突，应合并表述清楚。
- **C15 反对（作为决策杠杆低）**：enum+switch 非 AnyView 是正确实现纪律，但它是 C11 的实现细节、非独立设计决策，Non-dup 给 2。建议并入 C11。
- **C16/C19/C20 = C4 同义反复**：C20 应 reject（=C4+C16+C19）。C16/C19 各自只剩半个独立点（竖屏适配 / 无断连概念），可并入 C4 + C18。
- **C18（759pt 三屏）漏洞**：759pt 数字真实（[useyourloaf](https://useyourloaf.com/blog/iphone-15-screen-sizes/)），但 lens1 F5 算出车控卡区只剩 ~360pt，**放不下 10 族常驻**——C18 说「三屏分层」却没承认 iPhone 必须滚动 + 活跃族置顶。漏洞=暗示 10 族能在一屏常驻。更优：C18 加「iPhone 车控区滚动 + 当前活跃族置顶，不强求 10 族常驻」。
- **C24（320/220ms）漏洞**：魔法数字无源，320ms 展开偏长可能拖「反应快」体感。更优：进 tokens.md 单源 + 标实测微调，展开建议 250-280ms。
- **C27（合同回放）轻度过度工程**：4 段 sequencer 合理，「合同回放」治理偏量产味，demo 现场固定话术用 PhaseAnimator/.delay 序列够，建议砍合同回放保留 sequencer。
- **C29（断网 morph）Non-dup 偏低**：与 C19/C30 的「断网仍响应」概念重叠；C29 独立价值在「顶栏 cyan→琥珀 morph + 徽章」的视觉编排（原型已有 scheme1:138-146），可 keep 但 Non-dup 给 3。
- **全集最大漏洞（非单候选）**：30 候选**无一覆盖投屏 banding/字号下限/对比度**——lens1/3/6 三路独立点名深空暗底投屏是 TIGER（8bit banding + 后排看不清 + 撞磊哥飞书白皮书「太丑看不清」同坑），却被 30 候选完全漏掉。这是「看着惊艳」北极星的最大隐藏高成本风险，强烈建议补一条「投屏验收门：IGN dither + 族卡数值 ≥28pt 等效 + 对比 ≥7:1 + 还原投影实查不看高清导出图」。

## 你这视角 top 5 最该关注候选

1. **C13（~50% 吞吐量化无一手）** — 机制对、数字假的典型；A2 Instruments 实测前别钉死「50%」，撞 claim-vs-reality 第8坑。最该被压「数字以实测为准」的承诺。
2. **C17（Bonjour LAN 隐私弹窗）** — 全集最高 Risk Revelation（联网坐实首次 NWBrowser 弹窗 + 跨设备静默失败），直接威胁「0网络」叙事；C17 标 optional 是对的，但更优=现场默认禁 LAN。同时反证 C19 独立性的价值。
3. **C20（=C4+C16+C19 四合一）** — 去重型，应 reject 收敛；双屏簇 6 候选过度切分的最明显冗余。
4. **C21+C25（matchedGeometry vs opacity/scale 升级门）** — 藏唯一事实型口径分歧（INDEX:44 G2 上抛磊哥），且两条强耦合应合并；联网坐实 macOS 无 zoom 退路使这个权衡真实且高杠杆。
5. **C30（稳定优先于炸场）** — Importance/Risk/Leverage 三高，是 30 候选里唯一把「不崩 > 惊艳」北极星钉成硬约束的元决策（错峰 + ReduceMotion/低电量双通道 + thermal watchdog 全有 lens 一手支撑），且它正是 C1/C3/C13/C26/C27 一堆炫技候选的安全网。漏了它前面那些炸场决策都悬空。
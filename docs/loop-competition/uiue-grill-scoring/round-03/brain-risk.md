# Brain — Round 3 风险视角盲评（UIUE 30 候选）

> 视角：风险/失败模式/边界/pre-mortem（会怎么炸/现场翻车/隐藏成本/与北极星冲突），tiger/paper-tiger/elephant 三分类。
> 盲评：未读 grill-decisions / uiue-d1-d6-grill。只读 candidates-blind.md + 本地核锚 + 联网。
> 北极星 = 听懂中文/反应快/不崩/看着惊艳/断网也能跑。最致命风险类 = 「现场炸场」「与北极星冲突」「依赖未交付」「数字无源」。

## 30 候选评分表（C1-C30 × 5 维 + Total，每维 1-5）

| ID | Importance | Verifiability | Non-dup | Decision Lev | Risk Reveal | Total | verdict |
|---|---|---|---|---|---|---|---|
| C1 | 4 | 4 | 4 | 4 | 3 | **19** | keep |
| C2 | 5 | 5 | 4 | 4 | 5 | **23** | keep |
| C3 | 3 | 4 | 4 | 3 | 2 | **16** | weak |
| C4 | 5 | 4 | 4 | 5 | 4 | **22** | keep |
| C5 | 4 | 4 | 3 | 4 | 4 | **19** | keep |
| C6 | 4 | 3 | 3 | 4 | 4 | **18** | keep |
| C7 | 4 | 5 | 3 | 4 | 4 | **20** | keep |
| C8 | 4 | 5 | 4 | 4 | 5 | **22** | keep |
| C9 | 3 | 4 | 2 | 3 | 3 | **15** | weak |
| C10 | 4 | 4 | 3 | 4 | 4 | **19** | keep |
| C11 | 4 | 5 | 4 | 4 | 3 | **20** | keep |
| C12 | 5 | 5 | 4 | 5 | 4 | **23** | keep |
| C13 | 5 | 3 | 4 | 4 | 5 | **21** | keep |
| C14 | 4 | 5 | 3 | 4 | 4 | **20** | keep |
| C15 | 3 | 5 | 3 | 3 | 2 | **16** | weak |
| C16 | 3 | 4 | 2 | 3 | 3 | **15** | weak |
| C17 | 4 | 5 | 3 | 4 | 4 | **20** | keep |
| C18 | 4 | 5 | 4 | 4 | 4 | **21** | keep |
| C19 | 2 | 3 | 1 | 2 | 2 | **10** | better-exists |
| C20 | 2 | 3 | 1 | 2 | 2 | **10** | better-exists |
| C21 | 5 | 5 | 4 | 5 | 4 | **23** | keep |
| C22 | 4 | 5 | 4 | 4 | 4 | **21** | keep |
| C23 | 4 | 4 | 4 | 4 | 4 | **20** | keep |
| C24 | 3 | 4 | 4 | 3 | 3 | **17** | weak |
| C25 | 5 | 5 | 4 | 5 | 5 | **24** | keep |
| C26 | 4 | 5 | 4 | 4 | 4 | **21** | keep |
| C27 | 4 | 4 | 4 | 4 | 4 | **20** | keep |
| C28 | 5 | 4 | 4 | 4 | 5 | **22** | keep |
| C29 | 4 | 5 | 3 | 4 | 4 | **20** | keep |
| C30 | 5 | 5 | 4 | 5 | 5 | **24** | keep |

## 视角专项发现（风险/失败模式/边界）

**TIGER（明确威胁，带验证清单）**
- T-A **C28 TTS 中文语音可能不预装→破"断网也能跑"北极星**（联网坐实：AVSpeechSynthesizer 中文非默认语言，"may require an initial download before offline use is possible"）。C28 只提首音延迟掩盖，**没提"中文 voice 离线是否已下载"这一断网炸点**。客户机若是干净 iPhone/Mac，zh-CN Enhanced/Premium voice 没下载 → 断网高潮（C29）演到一半 TTS 哑火 = 双重打脸。验证清单：① 干净设备 `AVSpeechSynthesisVoice(language:"zh-CN")` 返回 nil 否；② Compact vs Enhanced 哪级预装；③ 断网前必做 voice 预下载 + Bundle 兜底。
- T-B **C13/C30 GPU 错峰是真刚需但 C13 的"~50%"数字无源**（联网坐实：MLX 永远走 GPU，Apple 运行时无 co-scheduling，重推理 dispatch 会 stall 渲染帧 = 错峰互斥方向对）。但 lens6/lens4 都没给"50%"出处，C13 这数字是 ESTIMATE。**漏点：没人提"把 LLM 推理放 ANE 避让"**（联网：CoreML→ANE 是 GPU contention 的标准逃生阀）——但 MAformac 用 MLX（Mac GPU-bound，ANE 不可用），所以逃生阀在本项目部分失效，错峰互斥是唯一解 → C30 比 C13 更完整（C30 含 thermal watchdog + 双通道）。
- T-C **C8 子 device 优先级"按线上优先级"在仓内无数据源**（本地坐实：`contracts/state-cells.yaml` grep priority/frequency/高频/rank = NONE FOUND；12 个 cell 全无优先级字段）。C8 揭示了真实数据缺口（=价值），但承诺无法兑现 → 必须现场手挑高频子集 or 补 priority 字段。这是 ELEPHANT 级数据缺口被 C8 提前 surface = 高 Risk Revelation。
- T-D **C21/C22 命中真实 SwiftUI 坑但 macOS 是被迫劣选**（联网坐实：matchedGeometryEffect 在 LazyVGrid 有 multiple-source 运行时冲突 + 懒渲染源不存在，是文档化已知问题；`.navigationTransition(.zoom)` / ZoomNavigationTransition 在 **macOS unavailable**，须 `#if os(iOS)`）。Mac 主舞台被迫只能用更易踩坑的 matchedGeometryEffect，不能用更稳的 zoom。C21 选 matchedGeometryEffect 是**对的**（zoom 在 Mac 根本不可用），C22 改 Grid 规避懒渲染是**对的**（Grid=iOS16/macOS13 全可用）。

**PAPER-TIGER（看似威胁实际可控）**
- PT-1 **"10 族 10 卡会卡"**（C5/C10）：数量非瓶颈（lazy grid 拐点 20×20=400），真坑是 per-cell 辉光 offscreen 复杂度。别因怕卡砍卡数。
- PT-2 **"MeshGradient/Gauge 跨平台不可用"**（C12/C26）：Gauge=iOS16/macOS13 全可用免守卫（联网坐实）；MeshGradient=iOS18/macOS15 需 `#available`（联网坐实 macOS15 非 macOS14 部署），C26 明写"每个 shader 必有低版本 fallback" = 已正确兜底。
- PT-3 **"双屏断连会炸"**（C19/C4/C17）：C4/C17 设计 iPhone 自包含、断连为可选加分 = 断连根本不影响主舞台。C19 把这点单列成"断连降级决策"实属冗余（见反对）。

**ELEPHANT（没人提该提）**
- E-1 **投屏 banding + 有线 vs 无线投屏**：深空暗底渐变（#0a0b12）+ 投影 8bit = banding 高发，高对比投影更糟（lens5/6 坐实，本机主屏 1920×1080 FHD）。**30 候选无一把"现场强制有线 HDMI 投屏 + IGN dither"写进炸场 checklist**——C30"稳定优先"最接近但没点投屏。这是与北极星"看着惊艳"直接冲突的现场炸点。
- E-2 **深空暗底 halation/对比度 fail 撞磊哥飞书白皮书同坑**（lens6 T4 直接点名同根因）。tokens.md base=#0a0b12 近纯黑，散光人群光晕。**无候选提"base 上抬到 #121212 级软黑 + accent 降饱和"**——视觉 SSOT 锁死 #0a0b12 反成风险。
- E-3 **C28 视觉先于 TTS = 对，但没说"卡片态变更必先于 ASR/LLM 出结果"的乐观渲染风险**：若先渲染后模型推翻（拒识/澄清），卡片要回滚 → 闪烁。乐观渲染在 demo 安全（mock 必成功），但与 C2/C7 的"展开后再设值"时序要对齐。

## 本地核证据（file:line）
- `App/ContentView.swift:122` — `cell.visualState == .satisfied ? green : gray` **把 7 态压成绿/灰二值**（与 C11/C14/tokens §2 的 7 态色直接冲突，是现役代码的头号视觉债）。
- `App/ContentView.swift:40` — `LazyVGrid(.adaptive(minimum:160))` **无 max** → window resize/投屏分辨率切换重排（C22 改 Grid 正修此坑）。
- `Core/State/DemoVehicleStateStore.swift:17-25` — `DemoVisualState` 7 态枚举（normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown）已存在 = C11 enum 分发的数据基础真实存在。
- `Core/State/DemoVehicleStateStore.swift:134-159` — defaultCells 23 个，与 state-cells.yaml 12 个 cell **不一致**（两份端态源漂移，独立于 30 候选但影响 C11/C14 数据派生）。
- `contracts/state-cells.yaml`（grep priority/frequency/高频/rank=**NONE FOUND**）— **C8"按线上优先级"无本地数据源**，是真缺口。
- `contracts/state-cells.yaml:60` `execution_range {min:18,max:32}` / `:80` 风量 `{1,10}` / `:96` 车窗 `{0,100}` — C11/C12 异构值范围有一手源。
- `Package.swift:7-9` — `.iOS(.v17), .macOS(.v14)` 部署底线 → C26 MeshGradient(macOS15)/C21 zoom(macOS unavailable) 守卫是硬需求。
- `docs/design/tokens.md:64` — 已点名"ContentView:122 现把所有非 satisfied 渲成灰，把 7 态压成绿/灰二值" = C11/C14 修这个坑。
- `prototypes/scheme1-deep-space-interactive.html:113-120` — 原型仅 6 卡 2×2 静态网格（含"音乐"非 10 族之一）= C5/C10 全景网格的退化起点；`:85` `@media reduced-motion{animation:none}` = C25/C30 ReduceMotion fallback 范式已在原型。

## 联网核证据（URL + 日期，2026-06-23 检索）
- matchedGeometryEffect LazyVGrid multiple-source 冲突 + 懒渲染源不存在（文档化已知）：https://swiftui-lab.com/matchedgeometryeffect-part2/ + https://medium.com/@literalpie/matched-geometry-effect-in-swiftui-93b92110209 → **支持 C21/C22/C23**。
- `.zoom` navigation transition / ZoomNavigationTransition **在 macOS unavailable**，须 `#if os(iOS)`：https://www.createwithswift.com/using-the-zoom-navigation-transition-in-swiftui/ + https://github.com/hmlongco/Navigator/issues/25 → **支持 C21 选 matchedGeometryEffect（zoom 在 Mac 不可用）**。
- MeshGradient = iOS18 / **macOS15**（非 macOS14）；Grid(静态)=iOS16/macOS13；LazyVGrid=iOS14/macOS11：https://developer.apple.com/documentation/swiftui/meshgradient + https://developer.apple.com/documentation/swiftui/grid → **C26 需 #available（已兜底）；C22 Grid 全可用**。
- Gauge `.accessoryCircular`=iOS16/macOS13 全平台免守卫（`.circular`/`.linear` 仅 watchOS）：https://developer.apple.com/documentation/swiftui/gaugestyle/accessorycircular + https://sarunw.com/posts/swiftui-gauge/ → **C12 native Gauge 选型成立**。
- AVSpeechSynthesizer 中文 voice **非默认语言、可能需先下载**才能离线；首音/换 voice 延迟真实（rule data 5-9x）：https://developer.apple.com/forums/thread/715339 + https://developer.apple.com/documentation/avfaudio/avspeechsynthesisvoice → **C28 漏"中文离线 voice 是否已下载"炸点（北极星冲突）**。
- MLX 永远走 GPU、Apple 运行时无 co-scheduling、重推理 stall 渲染帧；CoreML→ANE 是 contention 逃生阀（但 MLX 不可用 ANE）：https://cactuscompute.com/compare/coreml-vs-mlx + https://arxiv.org/pdf/2511.05502 → **支持 C13/C30 错峰；C13"50%"数字无源标 ESTIMATE**。
- iPhone15Pro = 393×852pt；safe area 顶~59（灵动岛）+底~34（home indicator）= **759pt 正好是竖屏 safe-area 高度**：https://useyourloaf.com/blog/iphone-15-screen-sizes/ + https://yesviz.com/devices/iphone-15-pro/ → **C18 759pt 有据（但 120+440+80=640≠759 是候选自身算术口径瑕疵）**。

## 反对 / 更好方案 / 漏洞（逐候选有问题的）

- **C3**（dim 族微光呼吸 + "全部展示"彩蛋）：弱。呼吸微光×9 族常驻 = 持续 `withAnimation`/box-shadow = per-cell offscreen + GPU 长占（撞 C13/C30 GPU 错峰）。"全部展示"彩蛋无明确触发/价值。**更好**：dim 族用静态低透明（无动画），只活跃族呼吸 → 省 GPU。
- **C8**：**漏洞=承诺无数据源**（本地 grep priority=NONE FOUND）。"按线上优先级"在 state-cells.yaml 无字段。**更好**：要么补 `priority/frequency` 字段（codegen 从 3990 协议表频次派生），要么现场手挑高频子集并明写"demo 硬编 N 个高频子 device"。不补则 C8 是空头支票。
- **C9**（同时只展开 1 族）：弱+重叠。与 C2"多卡只高亮不展开，单意图才展开"、C7"原地放大"几乎同义，Non-dup 低。**更好**：并入 C2/C7，不单列。
- **C15**（enum+switch 非 AnyView）：弱。是 C11"统一 enum+switch"的实现细节复述，Non-dup 低、Risk Reveal 低。**更好**：作为 C11 的实现注脚，不单列。
- **C16**（iPhone 独立全功能非镜像）：弱+重叠。与 C4/C17/C18/C20 高度重叠（都在讲"iPhone 自包含"）。**漏洞**：竖屏跑全模型+ASR+10 族对 iPhone 算力/热是真风险（MLX 在 iPhone 不可用→须 llama.cpp/CoreML，与 Mac 不同栈），C16 没提这层。
- **C19**（断连降级=iPhone 无断连概念）：**better-exists / 冗余**。这只是 C4"iPhone 脱机独立"的同义反复，"断连降级"是个不存在的问题（自包含=无断连）。被 C4 完全覆盖，单列=决策疲劳。判 reject/合并。
- **C20**（iPhone 不极简=独立全功能）：**better-exists / 冗余**。与 C4/C16/C17/C19 同一主张第 5 次复述。判 reject/合并到 C4。
- **C24**（320ms/220ms 时长）：弱。**漏洞**=魔法数字无源（lens 无 320/220 出处）。**更好**：数字进 tokens.md `motion` 段单源 + 标"实测后冻结"，避免散落代码。"两个独立参数防竞态"洞察对，但数字本身是占位。
- **C13**：**漏洞**=`~50%` 无源（标 ESTIMATE 或 A2 用 Instruments 实测坐实）。机制对（GPU 错峰），数字虚。
- **C28**：**漏洞**=只防首音延迟，**没防"中文 voice 离线未下载"**（联网坐实是真断网炸点）。**更好**：加"启动时检测 zh-CN voice 是否 downloaded，未下载则预下载 or 退 Compact，断网前必须就绪"+ 录制兜底音频。
- **C18**：**小瑕疵**=候选写 759pt=orb120+内容440+mic80，但 120+440+80=640≠759（实际 759 是 safe-area 高，640 是三元素和，差 119pt 是间距/padding，候选没说清）。算术口径不严谨，但 759 这数字本身有据。
- **C26**：MeshGradient=macOS15 非 macOS14 部署，C26"必有低版本 fallback"已兜底正确；但 orb 用 metasidd/Orb 类 repo 多 stale（lens6 标 Orb ~19 月 STALE），C26 没点 orb 自建 vs adopt 的新鲜度风险（自建 MeshGradient+TimelineView 更稳）。

## 你这视角 top 5 最该关注候选（风险/失败模式优先级）

1. **C28（TTS 时序）— 隐藏断网炸点最高**：中文 voice 离线未下载会让 C29 断网高潮哑火，直接打脸"断网也能跑"北极星。必须在 A2 前坐实 voice 离线就绪 + 兜底音频。**风险被严重低估**（候选只提首音延迟）。
2. **C30（稳定优先于炸场）— 北极星守门员**：GPU 错峰+ReduceMotion/低电量双通道+thermal watchdog 是"不崩"的总闸，比所有炸场候选更 load-bearing。是 C13/C26/C27 的安全前提。**但仍漏投屏环节**（E-1）。
3. **C8（子 device 优先级）— 数据缺口提前 surface**：本地坐实无 priority 字段，揭示真实缺口=高价值，但承诺无法兑现=必须现场降级。是 30 候选里 Risk Revelation 最强的之一。
4. **C25（升级门：编译验证后才升级 matchedGeometry）— 防 SwiftUI 坑的元决策**：把 C21/C22/C23 的所有不确定性收进一道"默认 opacityScale，验证通过才升级"的门，是坑密度最高区（matchedGeometry+macOS）的最优风险姿态。逼出最有用承诺。
5. **C13（GPU 错峰）— 机制对、数字虚**：揭示 MLX-GPU 与渲染抢占的高成本风险（联网坐实真实且无 co-scheduling），但"50%"必须实测坐实或标 ESTIMATE，否则是凭印象数字（撞 claim-vs-reality 第8坑）。

> 横切元风险：tokens.md 把 base 锁死 #0a0b12（近纯黑）= 与磊哥飞书白皮书"太丑看不清"同根因（E-2），30 候选无一挑战此锁；ContentView:122 现役二值渲染是 C11/C14 必修的现役视觉债。
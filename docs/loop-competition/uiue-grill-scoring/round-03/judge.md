## Inputs

- **被评对象**：MAformac demo UIUE 30 个前端设计决策（C1-C30，`docs/loop-competition/uiue-grill-scoring/candidates-blind.md`）。
- **4 个盲评 reviewer**：`feasibility`（可行性/实现成本/端侧约束）、`facts`（事实核/API 版本/组件新鲜度）、`risk`（失败模式/边界/pre-mortem）、`better`（更优方案/过度工程化/漏选项）。
- **综合原则**：evidence > reviewer count。非取均值/中位数；reviewer 共识但证据弱→压分；reviewer 分歧→深判证据强弱定终分。本 judge 亦盲（未读 grill 工作档），只综合 4 reviewer + candidates-blind.md。
- **4 reviewer 收敛画像**（先看全景再逐条判）：
  - **强收敛高分（≥21 三家以上）**：C21（25/25/23/24）、C2（23/20/23/24）、C12（22/21/23/23）、C30（22/23/24/21）、C4（20/22/22/24）、C22（23/21/21/23）。
  - **强收敛低分/淘汰**：C19（10×4）、C20（10×4）、C9（15×4）、C16（15×4）、C3（12/16/16/12）、C15（15/16/16/16）。
  - **真分歧（spread ≥4 或某家明显离群）**：C13(18/21/21/19)、C26(20/24/21/23)、C25(20/20/24/19)、C28(20/21/22/23)、C27(15/19/20/19)、C18(20/17/21/16)、C29(20/16/20/19)、C6(20/18/18/16)、C7(19/16/20/19)、C5(22/22/19/19)。

## C1-C30 综合评分表（终分 + verdict）

| ID | feas | facts | risk | better | **终分** | **verdict** | 综合判据（evidence-weighted） |
|---|---|---|---|---|---|---|---|
| C1 | 16 | 15 | 19 | 15 | **16** | weak→keep | 开场 reveal 与 mlx 模型加载/首推同窗（risk T1+GPU 争用）+ 10 卡同 breathe offscreen（better F8）2 家点破。开场价值有，但应砍「逐卡扫」改一次性 reveal。Risk-Reveal 偏低。 |
| C2 | 23 | 20 | 23 | 24 | **23** | strong | 序列化高亮（非同时闪）有认知科学硬支撑（risk/better 引 Single-Item-Template 视觉工作记忆只追一个）。现状 `ContentView:122` 二值态完全无联动能力。揭示「多卡同时闪=丢脸」失败路。错峰时长须与 C24/scheme1 实测 350ms 单源。 |
| C3 | 12 | 16 | 16 | 12 | **13** | weak | 「dim 族呼吸微光」与 F8「只激活卡 breathe、normal 静默省 9/10 动画」直接冲突（feas/better 双标）。「全部展示彩蛋」低杠杆。dim 族应静默承载存在感不呼吸。 |
| C4 | 20 | 22 | 22 | 24 | **23** | strong | 双独立实例 = 规避 Bonjour LAN flaky + 本地网络权限弹窗（better 联网坐实 NWBrowser ~3s 才稳 + iOS14+ 弹窗会毁场）。最简最稳现场方案，且覆盖 C19/C20。feas 给 20 偏保守（其担忧的是 networking 零代码成本，但 C4 正是「不做联动」所以成本最低）→ 终分取证据更强的 22-24 区间。 |
| C5 | 22 | 22 | 19 | 19 | **21** | solid | 全景常驻+触发聚焦五路独立收敛（feas/facts），坑密度最低 Form A（消除 reflow 跳动）。risk/better 给 19 是因与 C1/C7/C9 信息重叠（Non-dup 偏低）+ 隐藏成本（数据须从 device 粒度聚合到族粒度，6 族 state cell 未建）。方向对，扣在重叠+数据 gap。 |
| C6 | 20 | 18 | 18 | 16 | **18** | keep | 「语音/tap 两路同一入口」架构对（ToolCall 驱动与触发源解耦），但依赖 DEFERRED 语音后端，A2 阶段只能 mock 验证。better 给 16 点破「A2 能否 mock 触发同一入口」未解。须明标分阶段（入口=ToolCall 驱动，ASR 是 DEFERRED 的 ToolCall 产生器）。 |
| C7 | 19 | 16 | 20 | 19 | **19** | keep | 原地放大+blur 非全屏 modal 对（避开 macOS 无 zoom transition）。漏洞=全景逐卡 blur 成本复合（offscreen），应只虚化全景一层（GlassEffectContainer 合并）。facts 给 16 因与 C9 重叠。 |
| C8 | 23 | 20 | 22 | 20 | **22** | strong | 最高杠杆数据缺口候选：4 家本地 grep 一致坐实 `state-cells.yaml` 无 priority/frequency 字段（NONE FOUND）→「按线上优先级」无数据源。价值正在揭示缺口。demo 取巧解=现场手挑高频子集硬编码（产品约定收窄输入），别补 priority schema（量产工程，违轻治理）。Risk-Reveal 满分。 |
| C9 | 15 | 15 | 15 | 15 | **15** | weak | 4 家一致：C2（多卡只高亮不展开）+ C7（原地放大）的必然推论，无独立信息量。建议并入 C7。Non-dup=2。 |
| C10 | 19 | 20 | 19 | 18 | **19** | keep | 折叠不平铺对（现状 22 device 平铺要改）。一致漏洞：角标「子能力数」数据源应是 `scope.count`（如空调 5 温区）或族-device 映射，**不是 191 拆分**，且 6 族无 cell 会显 0。需硬编族-device 映射兜底。 |
| C11 | 20 | 19 | 20 | 19 | **20** | keep | value.type 5 类 enum+switch 从 state-cells 派生，编译穷尽对。共识漏洞：**漏了与 7 态 DemoVisualState 的正交关系**（值形态×状态两维度，C11 只覆盖值维度）；且派生前须先统一 DemoVehicleStateStore 重复键 SSOT 分叉（ac.power vs hvac.ac）。 |
| C12 | 22 | 21 | 23 | 23 | **22** | strong | 4 家最干净候选之一。「座椅多维+RGB 自建，其余原生 Gauge/分段/toggle」= 精确 build/adopt 边界。Gauge accessoryCircular=iOS16 无需守卫（4 家联网坐实）。漏洞修正：CompactSlider 550★ 但 ~7月 stale 失 60天门，**别引**，自写 ~30 行。 |
| C13 | 18 | 21 | 21 | 19 | **20** | keep | 真分歧（见 Overrides/分歧段）。GPU 错峰机制 4 家一致成立（MLX 永远走 GPU + Apple 无 co-scheduling + 重推理 stall 渲染帧，联网坐实；ANE 逃生阀 MLX 不可用 → 错峰是唯一解）。但「~50%」数字 4 家一致无源（claim-vs-reality 第8坑），feas 还指 lens1 F9 实测 M5 渲染零压力 → 真风险或在 banding/可读性非算力。机制保留为工程纪律，数字必标 ESTIMATE 或 A2 Instruments 实测。 |
| C14 | 21 | 20 | 20 | 19 | **20** | keep | 骨架统一只变值区 =「懂一张懂全部」（E3）对。同 C11 漏 7 态维度。现状 `ContentView:122` 7 态压绿/灰二值是它要修的源头债。 |
| C15 | 15 | 16 | 16 | 16 | **16** | weak | 4 家一致：enum+switch 非 AnyView 是 SwiftUI 工程常识 + C11 的实现细节，非独立决策。Non-dup=2，凑数。建议作 C11 实现注脚。 |
| C16 | 15 | 15 | 15 | 15 | **15** | weak | 4 家一致：与 C4/C17/C18/C20 高度重叠（iPhone 自包含）。漏洞=iPhone 竖屏跑全模型+ASR 须 llama.cpp/CoreML（与 Mac MLX 不同栈），C16 没提这层算力/热风险。 |
| C17 | 20 | 20 | 20 | 23 | **20** | keep | Bonjour LAN 可选联动「标可选」是正确现场风险规避（better 联网坐实 flaky+权限弹窗）。应明写「现场默认不开 LAN，开则接受弹窗+3s 延迟」。better 给 23 略高（其重视风险规避价值），其余 20 更稳，终分取 20。 |
| C18 | 20 | 17 | 21 | 16 | **17** | weak | facts/better 双家坐实 759pt 算术不自洽（orb120+内容440+mic80=640≠759）+ 759 是 iPhone15Pro 专属 safe-area 被泛化（不同机型不同）+ 与 lens1 实测（车控卡仅~360pt 必滚动）对不上。数字证据偏负 → 取较低端。改 GeometryReader 比例分配。 |
| C19 | 10 | 10 | 10 | 10 | **10** | better-exists | 4 家满分一致 + 证据强：「iPhone 独立无断连概念」= C4 双独立实例的同义反复，「断连降级」是不存在的问题（自包含=无断连）。零新承诺，合并进 C4。 |
| C20 | 10 | 10 | 10 | 10 | **10** | better-exists | 4 家满分一致：「iPhone 不极简=独立全功能」是 C4/C16 同一主张第 N 次复述。零新决策杠杆，合并进 C4。 |
| C21 | 25 | 25 | 23 | 24 | **24** | strong | 全集证据最硬。matchedGeometryEffect=iOS14（无需守卫）+ `navigationTransition(.zoom)`/ZoomNavigationTransition 在 **macOS 不可用**（4 家联网坐实 Apple 文档+createwithswift+forums）→ Mac 主舞台聚焦过渡**唯一可行**非偏好。risk 给 23 是离群低，但证据（被平台逼出的正解）应支持升不是降。措辞应从「偏好」升「唯一可行硬约束」。 |
| C22 | 23 | 21 | 21 | 23 | **22** | strong | 用非 lazy Grid（iOS16 eager 全 cell 挂载）规避 matchedGeometry 懒渲染 source 未挂载冲突（4 家坐实 Forums #669115）。better 额外坐实其实是规避 **真实崩溃 bug FB11800180**（社区换 Grid 后 crash 消失）→ 对北极星「不崩」是 HIGH，措辞应升级。与现状 `LazyVGrid:40` 直接替换路径。 |
| C23 | 21 | 20 | 20 | 20 | **20** | solid | matchedGeometry 不可用时 opacityScale+边框辉光+ripple 兜底，对 C21 残余风险的诚实对冲（lens6 推荐避 matchedGeometry 用 opacity/scale）。4 家收敛 20-21。 |
| C24 | 17 | 16 | 17 | 15 | **16** | weak | 「展开 vs stagger 两独立参数防竞态」结构洞察对（3 家认可），但 320/220ms 是魔法数字 4 家一致无源、不在 tokens.md、与 scheme1 实测 350ms 错峰对不上。better/feas 还指漏「可中断性」（比时长更影响感知响应，对「反应快」北极星更关键）。数字进 tokens.md `motion.*` 单源+标 ESTIMATE+加 interruptible。 |
| C25 | 20 | 20 | 24 | 19 | **21** | solid | risk 离群给 24（升级门=坑密度最高区 matchedGeometry+macOS 的最优风险姿态，把不确定性收进一道门）。其余 19-20 因 matchedGeometry 是 iOS14 古老 API「经编译验证」略保守——真风险在运行态抖闪/macOS quirk 不在能否编译。措辞应改「运行态稳定性验证」。综合取 21（risk 的 Decision-Leverage 论点有据，但措辞瑕疵扣分）。 |
| C26 | 20 | 24 | 21 | 23 | **22** | strong | facts 离群高（24）有据：MeshGradient=iOS18/macOS15 不守卫=部署 iOS17 直接崩（最 load-bearing 事实），且 Inferno 2879★/2026-05-17 fresh vs Orb 422★/2024-11 STALE 的新鲜度分叉**只联网才 catch**。feas 给 20 因 Sinebow 无 lens 来源（凭空命名需落具体 shader）。终分取证据更强的高端，唯一约束=orb 必自建 MeshGradient（别引 stale repo）+ 点名 MeshGradient iOS18 这条最危险。 |
| C27 | 15 | 19 | 20 | 19 | **18** | weak→keep | feas 离群低（15）有强据：scheme1.html:157-163 已用 12 行脚本对象+setTimeout 跑通 5 场景含多意图联动 →「sequencer+合同回放」是过度工程化（demo 轻治理铁律）。better 同声。编排顺序洞察有价值（risk 20）但实现形态应砍到「脚本数组+计时器」，且「合同回放」依赖 DEFERRED golden-run。综合取 18（洞察留、治理框架砍）。 |
| C28 | 20 | 21 | 22 | 23 | **22** | strong | 4 家联网坐实首次 speak() 0.6-1s IPC 延迟 + didCancel/didFinish delegate 跨版本不可靠 →「immediate ack 掩盖首音延迟 + 调用点改态不靠 delegate」两条全中。risk/better 额外揭示隐藏断网炸点（中文 voice 离线未下载 → C29 断网高潮 TTS 哑火，打脸「断网也能跑」北极星）。终分取高端+必补 pre-warm 静音 utterance + voice 离线就绪检测 + 兜底音频。 |
| C29 | 20 | 16 | 20 | 19 | **19** | keep | 断网 morph（cyan→琥珀+100%端侧徽章）原型已实证（scheme1:138-146 + tokens state.offline 范式）。facts 给 16 因「全族卡断网保持响应」需所有族接端态 store，目前只 4 族有 cell（数据 gap）。且隐藏依赖 C28 的 TTS 离线就绪（见 C28）。 |
| C30 | 22 | 23 | 24 | 21 | **23** | strong | 北极星「不崩」总闸：thermal watchdog + ReduceMotion/低电量双通道 + 错峰，对应 3 个联网坐实真坑（thermal -44% / LPM iPhone-only Mac 恒 false / ReduceMotion 不自动 fallback matchedGeometry）。应升为整组横切纪律非平级候选。**共识漏洞=漏投屏/banding（见 gaps）**：C30 是唯一谈现场稳定的候选但覆盖不全。 |

## Overrides（override reviewer consensus 的 + 理由）

1. **C13 终分 20（拒绝向上漂到 facts/risk 的 21 的「机制成立=高分」隐含逻辑）**：facts(21)/risk(21) 因 GPU 争用机制联网坐实给高分，但 feasibility(18) 引 lens1 F9 实测 M5 渲染 10-30 卡零压力，质疑这是否真 HIGH 风险。我**不取均值上漂**：机制对≠该条是高杠杆决策，且「~50%」4 家一致无源（claim-vs-reality 第8坑铁证）。终分 20 = 机制纪律保留，但数字未坐实+真风险定性存疑双扣。这是 evidence>count（3 家偏高，但 feas 的反证更具体）。

2. **C4 / C26 / C28 终分上调到证据更强的高端（不取 feasibility 的偏低分）**：这三条 feasibility 都给了相对低分（C4=20/C26=20/C28=20），但其低分理由（networking 零代码成本 / Sinebow 无源 / 仅首音延迟）被 facts/risk/better 的更强联网证据覆盖——C4 的「不做联动」恰是成本最低、C26 的 MeshGradient iOS18 崩+新鲜度分叉是 load-bearing、C28 的断网哑火炸点是北极星级。终分取高端 22-23 而非 4 家均值。

3. **C21 守在 24（不被 risk 的离群低 23 拉低，也不机械给 25）**：risk(23) 是唯一低于 24 的，但其低分无对应证据反驳（risk 自己也承认 macOS zoom unavailable 坐实）。3 家 24-25 + 全集最硬证据链 → 终分 24。不给满分 25 仅因 Decision-Leverage 上它是「被平台逼出」而非主动设计杠杆（措辞待升级为硬约束后才满）。

4. **C27 终分 18（拒绝 risk/facts 的 19-20，采纳 feasibility 的过度工程化判定）**：risk(20)/facts(19)/better(19) 偏向「编排顺序有价值」，但 feasibility(15) 的本地核证据最硬（scheme1.html 已用 12 行脚本跑通 = sequencer 框架是过度工程化，违 demo 轻治理铁律）。我采纳证据而非 3 家平均：编排洞察留分、治理框架形态砍分 → 18，且明标依赖 DEFERRED golden-run。

## 分歧候选（reviewer 打分分歧大，下轮 focus）

- **C13（18/21/21/19，spread 3 + 定性分歧）**：分歧不在分数大小而在「这是不是 HIGH 风险」——facts/risk 认为 GPU 争用是高 Risk-Revelation，feasibility 认为 M5 渲染零压力、真风险在 banding 非算力。下轮须 A2 用 Instruments 实测 GPU 争用百分比坐实「50%」或永久标 ESTIMATE，并分诊真瓶颈（算力 vs 显示侧 banding/可读性）。
- **C25（20/20/24/19，risk 离群 +4）**：risk 把「升级门」当坑密度最高区的元决策给 24，其余认为措辞「经编译验证」保守（真风险在运行态非编译）。下轮拍：升级门验证标准是「运行态稳定性 + macOS quirk + ReduceMotion fallback」非「能否编译」。
- **C26（20/24/21/23，facts 离群 +4）**：facts 因联网 catch 新鲜度分叉（Inferno fresh / Orb stale）+ MeshGradient iOS18 崩给最高，feas 因 Sinebow 无源给最低。下轮拍：3 个 shader 具体选型落地（orb=自建 MeshGradient / ripple=Inferno or twostraws / 氛围灯=具体 shader 非凭空 Sinebow）。
- **C18（20/17/21/16，spread 5）**：759pt 数字是否自洽 + 是否泛化机型。下轮拍：iPhone 竖屏布局改 GeometryReader 比例分配，对齐 lens1 实测（车控卡~360pt 必滚动）。
- **C28（20/21/22/23，渐升 + 隐藏炸点分歧）**：feas/facts 只看首音延迟，risk/better 揭示中文 voice 离线未下载的断网哑火炸点。下轮 A2 前必坐实：干净设备 `AVSpeechSynthesisVoice(language:"zh-CN")` 是否返回 nil + 断网前预下载 + Bundle 兜底音频。
- **C6/C7/C29（语音/数据依赖分歧）**：facts 普遍给低（18/16/16），因依赖 DEFERRED 后端或数据 gap（6 族无 cell）在 A2 阶段无法物理验证。下轮须明标分阶段验证策略（mock-trigger vs 真 ASR/TTS）。

## 本轮 gaps（下轮重点深核）

1. **🔴 漏选项「投屏/字号/banding 现场环境决策」——4 reviewer 中 3 家（feas/risk/better）独立点为 HIGH，30 候选无一承载**：lens1+lens6 坐实本机主屏 1920×1080 非 Retina + 8bit 投屏 banding + AirPlay 掉帧 + 深空暗底 #0a0b12 halation（撞磊哥飞书白皮书「全部太丑看不清」同坑）。现状 scheme1 `font.card.val 15px` 远低于 1080p 投屏 ≥24pt body 下限。下轮**必须新增候选或扩 C30**：现场强制有线 HDMI + 字号下限 ≥24pt body + 渐变叠 IGN dither + base 上抬到 #121212 级软黑/accent 降饱和。

2. **🔴 漏「7 态 visualState 正面消费决策」——风险被 C11/C14 漏掉的正交维度**：`ContentView:122` 现把 7 态压绿/灰二值（U10 头号翻车点，4 家本地核坐实），tokens.md 7 态色仍 DRAFT。C11/C14 只覆盖 value.type 值形态维度，**漏了与 7 态状态维度的正交关系**。下轮须补一条正面决策：UI 必须消费全 7 态（clarify 琥珀 / unsupported 灰锁 / safety 红 / crash 灰，绝不混红）——这是 demo 智能感卖点却无候选承载。

3. **数据契约缺口集群（C8/C10/C11/C29 共依赖）**：`state-cells.yaml` 仅 4 族/12 cell，6 族（座椅/车门/音量/雨刮/天窗/香氛）无 cell；无 priority/frequency/scope 排序字段；`DemoVehicleStateStore` 22 cell 含重复键 SSOT 分叉（ac.power vs hvac.ac 两套命名）。下轮拍：补 6 族 state cell + 统一命名 SSOT + 现场约定收窄（手挑高频子集硬编）vs 补字段（违轻治理）的边界。

4. **魔法数字单源化（C13「50%」/ C24「320/220ms」/ C18「759pt」）**：4 家一致 flag 三处凭印象/泛化数字。下轮所有 load-bearing 数字进 tokens.md 单源 + 标 ESTIMATE/实测/比例，否则 A2 实装无依据（claim-vs-reality 第8坑 enforce）。

5. **DEFERRED 后端依赖显式分阶段（C6/C27/C28/C29）**：语音 ASR/TTS + golden-run + 真 networking 在 A2(code-only) 阶段全为 mock。下轮每条依赖 DEFERRED 的候选须明标「A2 用 mock 验证什么 / 真后端验证什么」，避免「纸面可行但物理不可坐实」。
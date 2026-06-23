## Inputs

- **Candidates**: `docs/loop-competition/uiue-grill-scoring/candidates-blind.md` — 30 UIUE 前端设计决策（C1-C30），分 7 簇（主视图形态/族内下钻/异构值可视化/双屏细节/聚焦过渡技术/炸场高潮）。
- **4 盲评 reviewer**: feasibility（SwiftUI 实现可行性）/ facts（外部事实核 API 版本+组件活跃度）/ risk（pre-mortem tiger/elephant）/ better（更优方案+过度工程化+漏选项）。
- **Judge 纪律**: 我也盲（不读 grill 工作档）；evidence > reviewer count；防 bandwagon/verbosity/position/consensus bias；分歧深判不取中位。
- **跨 reviewer 一致硬事实（4 路独立联网 cross-verify，采信）**:
  - matchedGeometryEffect=iOS14 / Gauge.accessoryCircular=iOS16 / 静态 Grid=iOS16（均 ≤ 部署门 iOS17，免守卫）。
  - MeshGradient=iOS18 / glassEffect=iOS26（> 部署门，**必 #available + fallback**，非过度防御）。
  - navigationTransition.zoom 在 **macOS 编译级 unavailable** → Mac 主舞台 hero 过渡只能 matchedGeometryEffect（C21 的最强事实底座）。
  - AVSpeechSynthesizer 首音延迟 0.6-1s+（FB11380447）+ didCancel iOS15+ 不触发 + 锁死 bug（C28 底座）。
  - **本地基线**: App/ContentView.swift 仍是 walking skeleton（LazyVGrid 平铺 22 device + green/gray 二值 + TextField 无语音）；FastPathIntentEngine 仅 1 硬编码意图；无 ASR；TTS 裸 speak。→ 30 候选全是「待建设计契约」非现状，Verifiability 按「API 可达 + 研究/契约支撑」判，非「已实现」。

## C1-C30 综合评分表（终分满分 25 + verdict）

| ID | 4-reviewer | mean | spread | **终分** | verdict | 判据 |
|---|---|---|---|---|---|---|
| C1 | 16/16/14/14 | 15.0 | 2 | **15** | weak | reveal 实现形态（opacity vs 插入）未定，撞 reflow/ReduceMotion；开场扫场与 C2/C30「只激活态动」轻冲突 |
| C2 | 20/23/21/23 | 21.8 | 3 | **22** | strong | 序列化高亮有认知科学（single attentional template）+ 原型 multi 脚本双证；低成本高 wow 规避 reflow+注意力溢出 |
| C3 | 12/12/11/13 | 12.0 | 2 | **12** | weak | 10 卡常驻呼吸=10 offscreen pass，**反** lens「只激活态 breathe」+ 加重投屏 banding；彩蛋低价值。dim 应静态 |
| C4 | 19/21/20/20 | 20.0 | 2 | **19** | solid | 双屏架构母决策成立，但「iPhone 跑独立全功能实例」与 U1（mac主/iphone bonus）有张力（见 Overrides）；保架构、砍独立模型实例 |
| C5 | 18/21/21/21 | 20.2 | 3 | **20** | solid | 全景常驻+触发聚焦=MBUX Zero Layer 直译，主视图母形态；与 C1 部分重叠（结构母 vs 开场序列） |
| C6 | 15/19/18/19 | 17.8 | 4 | **18** | solid | feas 压分(15)有理（语音入口=0、依赖 ASR/LoRA 后端）；但「语音主tap辅同入口」是有效形态决策，tap 立即可做。取 solid 非 weak |
| C7 | 21/20/17/17 | 18.8 | 4 | **18** | solid | 原地放大+blur 非 modal 合理；与 C5/C9 母子重叠拉低独立性 |
| C8 | 15/16/20/15 | 16.5 | 5 | **15** | weak | **不取 risk 的 20**（见 Overrides）：「线上优先级」字段不存在于契约 + state-cells 仅 4 族无数据可派生，隐藏前置 |
| C9 | 15/16/15/15 | 15.2 | 1 | **14** | weak | ⊂ C5+C7 的推论（聚焦即单展开），4 路一致非独立决策 |
| C10 | 19/21/21/20 | 20.2 | 2 | **20** | solid | 191 折叠不平铺方向对（elephant 坐实）；角标子能力数依赖 10 族契约补全（同 C8 前置，但决策本身价值高） |
| C11 | 19/20/22/22 | 20.8 | 3 | **21** | strong | value.type enum+switch 编译穷尽优于 AnyView，架构正确；隐藏前置=state-cells 仅 4 族+双套 key 命名需先统一（扣 0.x） |
| C12 | 21/22/23/23 | 22.2 | 2 | **22** | strong | build-vs-reuse 边界最干净（Gauge/ColorPicker iOS16 门下原生）；**唯一纠错=RGB 色环可能过度**（契约 ambient.color 是 8 命名色 enum 非真 RGB，见 gaps） |
| C13 | 17/21/23/21 | 20.5 | 6 | **20** | solid | **不取 risk/facts 的 23**（见 Overrides）：「掉~50%吞吐」是未核 reviewed-value（3 路标内部 pre-mortem）+「GPU 协调器」无 SwiftUI 原语成本被低估；方向对，量化待 Instruments 实测 |
| C14 | 19/20/18/21 | 19.5 | 3 | **20** | solid | 卡片骨架统一只变值区=飞书白皮书一致性教训直系；泛型 FamilyCard 易实现，低风险高价值 |
| C15 | 15/16/16/16 | 15.8 | 1 | **15** | weak | ⊂ C11 实现细节（enum+switch 非 AnyView），4 路一致并入 C11 |
| C16 | 16/15/15/16 | 15.5 | 1 | **15** | weak | ⊂ C4（iPhone 独立非镜像 C4 已含），同义重述 |
| C17 | 17/22/21/17 | 19.2 | 5 | **19** | solid | **深判分歧**（见分歧段）：Bonjour 真可行（facts/risk keep）但 Local Network 授权弹窗=现场炸点（risk 坐实）→ 价值在「坐实联动=可选非依赖」；不取 feas/better 的 weak（漏了授权弹窗风险揭示） |
| C18 | 16/20/17/20 | 18.2 | 4 | **19** | solid | iPhone 竖屏 759pt 三屏分层是真技术决策（与 C16/C19/C20 不同，这条不是重述）；759pt 仅 ~360pt 给卡，「常驻10族」不可行需滚动（扣分） |
| C19 | 11/10/11/12 | 11.0 | 2 | **11** | reject | 循环论证（"独立所以无断连"=假设当结论），零决策杠杆，4 路一致最低 |
| C20 | 11/10/10/15 | 11.5 | 5 | **11** | reject | **不取 better 的 15**（见 Overrides）：=C4+C16+C19 四合一复述，3 路 reject |
| C21 | 23/24/23/24 | 23.5 | 1 | **23** | strong | 全批可行性事实最硬（macOS 无 zoom 退路三源坐实）；**但把唯一事实型口径分歧拍成单方结论**（lens 综合官倾向禁用改 opacity/scale）→ 需与 C25 升级门捆绑，见分歧段。终分高但留 grill |
| C22 | 21/23/23/24 | 22.8 | 3 | **23** | strong | Grid 非 LazyVGrid 规避 matchedGeometry multiple-source/懒渲染冲突=业界 canonical fix；10 卡远低于 lazy 拐点，零顾虑 |
| C23 | 20/20/20/20 | 20.0 | 0 | **20** | solid | 兜底动画正确；**但「不可用」归因错**（matchedGeometry iOS14 永远可用，真场景是 ReduceMotion 不自动降级）；方案本身对 |
| C24 | 17/17/14/18 | 16.5 | 4 | **17** | solid | 双参数防竞态洞察有效；320/220ms 是 reviewed-value 需实测可调；应锚到研究区间(150-300ms)+TTS 句长相对化 |
| C25 | 19/20/20/20 | 19.8 | 1 | **20** | solid | 渐进升级门（默认 opacity，编译验证后升 matchedGeometry）=化解 C21 分歧的正解；应与 C21 合并以 C25 为主路径 |
| C26 | 22/23/23/23 | 22.8 | 1 | **23** | strong | shader 必 fallback 事实完全正确（MeshGradient iOS18/glassEffect iOS26）；**漏投屏 8bit banding→IGN dither**（应补进 shader 清单，见 gaps） |
| C27 | 18/19/18/18 | 18.2 | 1 | **18** | solid | 4 段编排价值高但「合同回放 sequencer」对 5min demo 偏重（量产编排形态）；应明确 sequencer 只编排视觉/TTS 时序、意图走真链路不录播 |
| C28 | 22/23/23/23 | 22.8 | 1 | **23** | strong | 联网坐实最强风险揭示（首音延迟+barge-in bug）；现状裸 speak 正待踩坑；**漏离线中文默认音色机器人感**（premium voice 需预装，见 gaps） |
| C29 | 17/18/20/19 | 18.5 | 3 | **19** | solid | 在线→离线 morph 原型已验；「全族断网保持响应」是后端事实非 UI 决策，UI 只展示徽章（扣独立性） |
| C30 | 23/24/24/24 | 23.8 | 1 | **24** | strong | 直击北极星「不崩」，元决策杠杆+风险揭示双满；**两漏洞**：LPM 套 Mac=frame 溢出（Mac 永 false，iPhone 专属）+ thermal watchdog 治不了首帧 shader 冷编译（见 gaps） |

## Overrides（推翻 reviewer consensus 的 + 理由）

1. **C8 → 压到 15 weak（推翻 risk 的 20 keep）**：risk 单路给 20 把它列 keep，但 feas/facts/better 三路独立 grep 坐实**两个隐藏前置**——(a) state-cells.yaml 仅 air_conditioner/window/screen/ambient_light 4 族有数据，10 族缺 6；(b)「线上子 device 优先级」字段在契约里**不存在**。risk 漏核了数据层，evidence 在压分方。**bandwagon 反向 catch**：3 票 keep 不等于对，但这里是 1 高票证据弱、3 票证据强，取强。

2. **C13 → 定 20 solid（不取 risk/facts/better 的 21-23 高分）**：三路把它列高 keep，但**全部承认「掉~50%吞吐」是 lens 自标内部 pre-mortem 的 reviewed-value，无外部一手**；feas 单路（17）catch 到「GPU 协调器在 SwiftUI 无现成原语，错峰互斥成本被当成一个 flag」。决策方向（shader 仅氛围层+错峰）正确值得 keep，但**不能让一个未核量化撑起 23 分**——这正是「reviewer 都说好但证据弱→压分」的标准场景。

3. **C20 → 定 11 reject（不取 better 的 15 weak）**：better 单路给 15（weak），其余 3 路 reject（10-11）。C20=C4+C16+C19 四合一复述，零新信息。3 路 reject 证据一致（同义反复），取 reject。

4. **C17 → 托到 19 solid（不取 feas/better 的 17 weak）**：feas/better 因「LAN 是可选加分→低杠杆」给 weak，但 facts/risk 坐实了它的**真实价值=Local Network 授权弹窗是现场炸点 + 真离线无 Wi-Fi 时 Bonjour 不通**——这条把「联动=nice-to-have 不是依赖」钉死，是有效风险揭示，不是低价值重述。Risk Revelation 维度被 feas/better 低估。

5. **C24 → 托到 17（不取 risk 的 14 weak）**：risk 因「320/220 是魔法数字」压到 14，但「两个独立参数防竞态」这个洞察本身有效（其余 3 路 17-18 keep）。数字是 reviewed-value 可调，决策结构成立 → solid 非 weak。

## 分歧候选（reviewer 打分分歧大，下轮 focus）

| ID | spread | 分歧本质 | 类型 | 下轮动作 |
|---|---|---|---|---|
| **C13** | 6（17↔23） | feas 看「GPU 协调器无原语+成本低估」压分 vs risk/facts 看「方向对」抬分；核心=「~50%吞吐」量化无一手 | **事实型**（有客观对错：到底掉多少） | A2 实装时 Instruments 真机实测坐实，禁凭 lens 经验值写死阈值 |
| **C8** | 5（15↔20） | risk 没核数据层 vs 三路 grep 坐实隐藏前置 | **事实型**（契约有无 priority 字段/几族数据，可证） | 已 override 收敛；下轮核「10 族契约补全」是否 C8/C10/C11 的共同硬前置 |
| **C17** | 5（17↔22） | 低杠杆 vs 高风险揭示 | 混合（杠杆=口径，授权弹窗=事实） | 坐实 demo 主路径是否依赖 LAN；授权弹窗预案是否进彩排 checklist |
| **C20** | 5（10↔15） | better 给 weak vs 三路 reject | 去重型（口径：算不算独立决策） | 已收敛 reject；与 C16/C19 一并并入 C4 |
| **C21** | 1（23↔24，分高但藏分歧） | **打分一致但内容藏唯一事实型口径分歧**：4 路都高分 keep，但 facts/better/risk 都点出 lens 综合官倾向「禁 matchedGeometry 改 opacity/scale」，C21 把它拍成单方「用」 | **🔴 事实型分歧（需上抛磊哥拍）** | matchedGeometry hero（惊艳坑多）vs opacity/scale（稳但平）；与 C25 升级门捆绑判，C25 为正解 |

## 本轮 gaps（下轮重点深核）

**A. 候选集集体漏洞（4 路有 ≥2 路独立 surface，最高优先）**：
1. 🔴 **7 态执行结果状态色完全缺失**（better/facts/risk 三路点名）：tokens.md:49-64 + README:40 标 ContentView:122「7 态压 green/gray 二值」为 U10 头号翻车点，clarify琥珀/unsupported灰锁/unsafe红/crash灰 是 demo「智能拒识」卖点。30 候选**无一触及状态色语义**——比任何布局候选更 demo-critical 的视觉决策。**下轮必补一条独立候选**。且 state store 现只产 satisfied/normal 2 态（store:119），其余 5 态无产出路径=色卡会是死代码，demo 链路需补产出。
2. 🔴 **投屏 8bit banding → IGN dither**（facts/risk/better 三路坐实，与磊哥飞书白皮书「暗底丑/看不清」同源）：深空暗底大渐变投屏/AirPlay 高危，散在 C26/C30 隐含但无独立决策。**下轮立独立候选**（渐变叠 IGN dither + 现场强制有线 HDMI 非 AirPlay）。
3. **字号投屏放大**（better 单路，lens1 F4）：scheme1 15px 远低于 1080p 后排可读下限（body≥24-28pt/标题≥44pt）。北极星「看得清」硬约束，无候选覆盖。
4. **多意图时 TTS 文案↔卡片序列对齐策略**（risk elephant E1）：C2 序列化高亮 vs C28 视觉先于 TTS vs C24 时长，三者叠加会视听不同步（听到「空调22+座椅加热」只看到一张卡）。无候选定义对齐规则。
5. **unsupported 族外兜底 UI 呈现**（risk elephant E3）：范式定族外走 unsupported，但客户说族外时怎么体面拒识无候选设计=直接决定「不丢脸」。

**B. 个别候选漏洞（A2 实装前需补承诺）**：
- **C28** 漏离线中文默认音色机器人感（risk T1，联网坐实 premium 中文 voice 需系统预装，断网 demo 机没预装则第一句塑料音）→ 承诺加「demo 机预装 premium voice + 代码 filter quality」。
- **C30** 两漏：(a) isLowPowerModeEnabled 在 Mac 永返 false（iPhone 专属，frame 溢出，套 Mac=死代码可能误降级）→ 分平台（Mac 只吃 ReduceMotion/Transparency）；(b) thermal watchdog 治稳态发热治不了**首帧 shader 冷编译**（Apple Silicon 首次跑 Metal shader/MLX 加几秒延迟落在客户进场第一眼）→ 补启动后台预热。
- **C12** RGB 色环过度：契约 ambient.color 是 8 命名色 enum（state-cells:146）非真 RGB → demo 用 8 色卡/native ColorPicker（两行），色环是量产形态。
- **C26** 补 dither shader 进选型清单；orb 第三方全 stale（metasidd/Orb 422★/2024-11 按 60 天硬约束淘汰）须明确自建 MeshGradient。
- **C11** 隐藏前置：state-cells 仅 4 族 + DemoVehicleStateStore 与 state-cells.yaml 双套 key 命名不一致，派生前必先统一口径。

**C. 量化待坐实（事实型，A2 实测，禁凭经验写死）**：C13/C30「shader 与 mlx 抢 GPU 掉~50%吞吐」、C24「320ms/220ms」、C8「线上子 device 优先级」数据源——三者都是 reviewed-value，A2 用 Instruments/真机/契约核实。

**D. 去重收敛（下轮合并，4 路高度一致）**：C9→并入 C5+C7；C15→并入 C11；C16/C19/C20→并入 C4（C19/C20 reject）。30 候选真有效独立决策约 22-24 条，4-6 条是稀释票。建议腾出席位给 gaps A 的漏选项（7 态色/投屏 dither/字号）。
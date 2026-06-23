## Inputs

- **4 reviewer 盲评**：feasibility（SwiftUI/代码实现+端侧）/ facts（外部事实真伪 cite-verify）/ risk（pre-mortem tiger/paper-tiger/elephant）/ better（更优方案+过度工程化+漏选项）。
- **本 judge 也盲**：未读 grill 工作档；仅综合 4 reviewer 盲评 + candidates-blind 描述。
- **anti-bias 纪律**：evidence > reviewer count；consensus 但证据弱可压分；分歧深判不取中位。
- **共识底座（4 reviewer 一致坐实）**：现状 `App/ContentView.swift` 是极简 walking skeleton（LazyVGrid + 二值绿灰 + AVSpeechSynthesizer fire-and-forget），grep 全仓零 matchedGeometry/MeshGradient/glassEffect/Gauge/@Namespace → **C1-C30 几乎全 greenfield 前瞻设计决策**。部署 iOS17/macOS14。state-cells.yaml 仅 12 cell/~6 device（191/10族是契约目标非现态）。

## C1-C30 综合评分表（终分/25 + verdict）

| ID | 终分 | verdict | 一句话 |
|---|---|---|---|
| C1 | 15.5 | weak | 开场 reveal 与 C2/C5 序列化高亮+Miller 过载有张力，4 reviewer 均提兜底缺失 |
| C2 | 22.5 | solid | 🔼 多意图序列化高亮，单 attentional-template 硬据(biorxiv)+车机范式坐实，greenfield |
| C3 | 12.2 | weak | 10 卡常驻呼吸=offscreen pass 违 C13/C30 错峰；彩蛋低 ROI 高 GPU 风险 |
| C4 | 16.5 | keep | 双屏簇核心(独立实例)，但与 C16/C19/C20 高重叠应合并 |
| C5 | 20.0 | solid | 主形态共识(全景常驻+触发聚焦)，5 路 lens 收敛+MBUX Zero-Layer |
| C6 | 17.0 | keep | ⚖️ 形态有效(dual-modality)，依赖 DEFERRED 语音后端=可证伪性缺口 |
| C7 | 18.2 | keep | 原地放大+blur 避 macOS 无 zoom 退路；blur=offscreen 成本；与 C9 重叠 |
| C8 | 19.0 | keep | ⚖️🔼 "线上优先级"无数据源(grep 0 命中)，但揭示缺口=Leverage；改现场手挑高频子集 |
| C9 | 15.5 | weak | =C7 同簇(单展开+blur)，独立度低，应合并进 C7 |
| C10 | 19.5 | keep | ⚖️ 折叠不平铺=解现状 23 device 平铺真重构；角标数可 fallback state_cells.count |
| C11 | 19.8 | keep | value.type enum+switch 从 state-cells 派生，C5RouteTier 已有同款先例(可验) |
| C12 | 21.2 | solid | Gauge .accessoryCircular iOS16 零守卫(联网坐实)+座椅/RGB 自建=真控件缺口，Leverage 最高 |
| C13 | 19.5 | keep | ⚖️🔪 机制(shader/mlx 抢 GPU 错峰)对+有据；~50% 吞吐无一手源必标[ESTIMATE-A2 Instruments] |
| C14 | 18.8 | keep | 骨架统一只变值区=lens6 E3+飞书白皮书教训，防认知过载 |
| C15 | 17.8 | weak | enum+switch 非 AnyView 是 C11 实现细节非独立决策(Non-dup 弱)，并入 C11 |
| C16 | 13.8 | weak | =C4/C19/C20 双屏簇，独立度低；竖屏适配合理但非独立决策 |
| C17 | 21.5 | solid | 🔼 Local Network 授权弹窗=最强 Risk-Revelation(TN3179+无 pre-check+iOS18 bug)，标 optional 正确 |
| C18 | 18.0 | keep | ⚖️ 竖屏三屏=双屏簇唯一独立技术点；但 640≠759 数字不严谨+需补滚动澄清(放不下 10 族) |
| C19 | 11.5 | better-exists | ⚖️ =C4 逻辑推论被完全覆盖，双屏簇去重 |
| C20 | 9.5 | reject | =C4+C16+C19 四合一纯复述，无独立技术内容 |
| C21 | 22.5 | solid | 🔴 macOS 无 zoom 退路→matchedGeometry 被迫成正解(联网坐实)；hero vs opacity 是口径型(绑 C25 上抛) |
| C22 | 21.5 | solid | Grid 非 LazyVGrid 规避 multiple-source+懒渲染(Apple Forums #669115)，与 C21 强绑(决策包) |
| C23 | 18.8 | keep | 兜底动画必要；但 risk catch ripple 引 Metal=GPU 成本与"兜底"自相矛盾(应只 opacity+scale) |
| C24 | 17.0 | keep | ⚖️🔪 双参数防竞态结构是真洞察；320/220ms 魔法数字无源(lens 给 150-300ms)→进 tokens.md+标实测 |
| C25 | 22.2 | solid | 默认 opacity 编译验证后才升级=最强 Leverage(口径分歧转证伪优先工程门)，绑 C21 拍板 |
| C26 | 20.8 | solid | MeshGradient iOS18 必 fallback(联网+Package.swift 双坐实)；metasidd/Orb 317★/2024-11 stale 淘汰正确 |
| C27 | 16.5 | keep | 4 段 sequencer 价值；"合同回放"依赖 DEFERRED+偏量产味治理(建议砍)，须事件驱动非纯定时 |
| C28 | 22.0 | solid | AVSpeechSynthesizer 首音 0.6-1s+ 持续未修(FB11380447)+simulator 测不出；漏洞=安全拒识态须 TTS/视觉同步 |
| C29 | 16.5 | keep | 断网 morph=炸场点(原型已有)；"全族卡断网响应"依赖 DEFERRED 端侧=A2 阶段 mock；与 C19/C30 重叠 |
| C30 | 22.8 | strong | 稳定>炸场=北极星元决策，thermal watchdog+错峰+ReduceMotion/低电量双通道全有一手据，是炸场候选的安全网 |

> 标注：🔼=override-up（consensus 偏低、证据 strong 提分）；⚖️=分歧深判（不取中位）；🔪=split verdict（机制 keep/数字标 ESTIMATE）；🔴=口径型分歧载体。

## Overrides（override reviewer consensus 的 + 理由）

- **C2 22.5 (solid，🔼提分)**：risk 给 19 偏低。多意图序列化高亮非审美偏好，有 Single-Item-Template 认知科学硬据(biorxiv)+MBUX/车机单注意力范式坐实，且现状完全无此机制(greenfield 高 Leverage)。evidence 充分 → 取 3/4 reviewer 的 21-23 高端，不被 risk 的 19 拉低。
- **C8 19.0 (keep，🔼+⚖️)**：risk 给 14(weak) 严重低估。同一事实(state-cells.yaml 无 priority 字段，grep 0 命中)被 risk 当"硬伤压分"、被 facts 当"价值=逼出隐藏成本给满分 Risk-Rev"。我判：揭示真实数据缺口是候选的 VALUE 不是缺陷(逼出"现场手挑高频子集 vs 建优先级表"拍板)。"3-4 高频按线上优先级"作为 CLAIM 确无源该改为现场手工配高频子集(产品约定收窄输入)。不取最低 14，也不取 facts 22(略高估 Importance)，定 19。
- **C13 19.5 (keep，🔪split)**：facts 给 17(Ver=2) vs feas 给 23。正确处理需拆：机制(shader 与 mlx 抢 GPU 须错峰)4 reviewer 全认对+有据(MLX>90% GPU)；数字(~50% 吞吐)4 reviewer 全认无源=凭印象(撞 claim-vs-reality 第8坑)。candidate 保留(机制 verifiable+高 Leverage)，但 ~50% 必标[ESTIMATE-A2 Instruments 实测]不进对外材料。facts 的 17 过罚机制本身、feas 的 23 漏数字硬伤，居中定 19.5。
- **C17 21.5 (solid，🔼提分)**：consensus 已高(20-23)但我确认其 Risk-Revelation 是全集最强且被普遍低估——Local Network 授权弹窗(TN3179+无 pre-check API+iOS18 弹窗 bug 三路坐实)会在现场首次双屏联动突然弹系统框，直接打脸"0网络·100%端侧"叙事。标 optional 是正确防御，更优=现场默认禁 LAN(产品约定消除风险)。取 21.5 锚定 solid。
- **C10 19.5 / C18 18.0 / C24 17.0 / C6 17.0 (⚖️不取中位)**：均有单 reviewer 因"派生数据缺口/数字不严谨/依赖 DEFERRED 后端"压低，但形态/结构价值独立于被压的那一点，按 evidence 取高于最低值。

## 分歧候选（reviewer 打分分歧大的，spread≥5，下轮 focus）

- **C8 (spread 8，最大)**：risk 14 vs facts 22。"揭示数据缺口=价值 vs 硬伤"的根本对立。下轮深核：state-cells 是否补 priority/freq 字段(真成本) vs 现场手挑(产品约定收窄)——这是该改的承诺。
- **C10 (spread 6)**：折叠形态(feas 21) vs 角标数据缺口(risk 15)。下轮核：角标子能力数 fallback 到 state_cells.count 是否可行。
- **C13 (spread 6)**：机制对(feas 23) vs ~50% 数字无源(facts 17)。下轮核：A2 Instruments 实测 GPU 错峰前后 token/s + 帧率，坐实数字或永久标 ESTIMATE。
- **C6 (spread 5)**：形态有效(facts 19) vs 依赖 DEFERRED 语音后端(risk 14)。下轮核：A2 code-only 阶段语音入口能否 mock 演 / 接口先留。
- **C18 (spread 5)**：竖屏独立技术点(feas/better 20) vs Non-dup 弱+640≠759 数字不严谨(facts/risk 15)。下轮核：759pt 三屏分配数字 + iPhone 是否需滚动(放不下 10 族常驻)。
- **C19 (spread 5)**：but 4 reviewer 实质一致低(better-exists/weak)，better 的 15 离群无强理由。判 better-exists 稳。
- **C24 (spread 5)**：双参数结构洞察(feas 20) vs 320/220ms 魔法数字(better 15)。下轮核：数字进 tokens.md 单源 + 标实测微调。

## 本轮 gaps（下轮重点深核）

1. **🔴 决策包 C21+C22+C25 必捆绑拍板（唯一事实型口径分歧上抛磊哥）**：4 reviewer 一致认定 README/INDEX 自己点名"必上抛磊哥"。事实层已坐实(macOS 无 zoom 退路→matchedGeometry 唯一跨平台 morph + LazyVGrid multiple-source 崩→须 Grid)。剩口径取向(hero-morph 求惊艳 vs opacity/scale 求稳)= 仁者见仁，上抛磊哥：A=默认 hero / B=默认 opacity(C25 升级门)⭐。三条不可分裂评/拍。
2. **🔴 30 候选集体盲点=投屏验收门（4 reviewer 中 3 独立点名，应补第 31 条）**：lens1/3/6 三路坐实深空暗底投屏 8bit banding+后排看不清+散光 halation，撞磊哥飞书白皮书"全部都太丑看不清"同根，但 30 候选无一条独立管"投屏后看得清吗"。补/并入 C30：IGN dither + 族卡数值 ≥28pt 等效 + 对比 ≥7:1 + 还原投影实查不看高清导出图。
3. **魔法数字三处统一处理（撞 claim-vs-reality 第8坑）**：C13 ~50% 吞吐 / C8 3-4 高频 / C24 320/220ms 均"机制对、数字假"。下轮统一改"以 A2 Instruments 实测 / 契约 freq 字段 / tokens.md 单源 + 现场实测为准"，禁在设计文档钉死未验数字。
4. **双屏簇去重收敛（C4/C16/C17/C18/C19/C20 六候选→~3 个独立决策）**：实质只 3 个——独立全功能形态(C4)/跨屏 LAN 技术(C17)/竖屏 759pt 布局(C18)。C20 reject、C19 better-exists、C16 weak 并入。
5. **DEFERRED 后端依赖诚实承诺（C6/C27/C29，含 C28 端侧 TTS）**：A2 code-only 阶段无法验"语音为主/合同回放/全族卡断网响应"，须逐条标"纯前端 mock 可演 / 需后端解冻才接"。
6. **4 个无候选覆盖的关键设计点（better reviewer 提）**：(a) unsupported 兜底 UI 呈现形态(不丢脸关键)；(b) orb 状态机对齐链路三态(聆听/思考/确认)；(c) orb→被控族 spatial 连线因果可视化(炸场点)；(d) C28 安全拒识/clarify 态须 TTS 与视觉同步(只满足态可视觉先行)。
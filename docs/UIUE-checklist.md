# UIUE Grill 全清单统计（从 UIUE 建立到现在）

> 磊哥 2026-06-25 要：统计 UIUE 建立至今所有 grill 清单（上百个）。本文 = **哪些清单 + 每条一句话 + 落点文件**的总索引。
> 推进事实源 SSOT = `docs/grill-tournament/grill-decisions-master.md`；本文是**导航索引**（不是 SSOT，看决策细节去各落点文件）。
> 🔴 老的 30+ 清单 = **U1-U31（UIX 续批，31 条）**。

## 总览（按系列 / 文件 / 数量）

| 系列 | 数量 | 主题 | 落点文件 | 状态 |
|---|---|---|---|---|
| **锦标赛 R1-R5** | 41 | A2/范式/口径/cascade（含部分 UIUE）| `final-grill-list.md` + `grill-decisions-master.md §2` | 大部已拍 |
| **D 系列**（D1-D8+D8.1-8.6）| 14 | UIUE 交互核心（主视图/二级模型/异构值/双端/降级/默认主驾/思考链路）| `grill-decisions-master.md §3` + `uiue-d1-d6-grill.md` | ✅ 已拍 |
| **D1-D6 子题**（Q1.1-Q4.4…）| ~24 | D1-D6 逐题 grill 一手（开场帧/序列化/展开触发/col O/双屏…）| `uiue-d1-d6-grill.md` | ✅ 已拍 |
| **D1-D5 盲评** | 5 | loop-competition 盲评对照 | `uiue-d1-d5-loop-competition.md` | ✅ |
| **E 系列**（E0-E8）| 9 | Phase 5 orb / 思考链路事件驱动 / 场景宏 / 时序整合 | `grill-decisions-master.md §4` | ✅ 已拍 |
| **U 系列**（U1-U31）🔴老清单 | 31 | UIX 续批（设备/glass/仪表/氛围灯/投屏/TTS/orb shader…）| `grill-decisions-master.md §3 UIX` | ✅ 已拍 |
| **Q30-Q41** | 12 | UIUE 重筛/炸场/语音/场景宏问题 | `grill-decisions-master.md §2` | 🟡 部分续批 |
| **G01-G28** | 28 | demo default_scope（Phase -1 前置）| `demo-default-scope-grill-decisions-2026-06-24.md` | ✅ 已拍 |
| **P4-D1/D2/D3 + 4a/4b/4c** | 6 | Phase 4 边界 + 实装收口 | `uiue-phase4-grill-decisions.md` | ✅ 已收口 |
| **AD-1~AD-14** | 14 | ui-presentation 架构决策（design）| `openspec/changes/ui-presentation/design.md` | ✅（AD-14 待实装落）|
| **SD1-SD25**（本 session）| 25 | 用户故事演绎 grill（场景/动效/视觉/corner case/边界态/context capsule diorama）| `uiue-storyboard-grill-decisions.md` | ✅ 已拍 |
| **V1-V12**（视觉块）| 12 | 间距/字体/圆角/glass容器/theme/连续舞台/注意力/图标/验收/duration/密度 | `uiue-storyboard SD18` + `tokens.md` | ✅ 已拍 |
| **CC1-CC4 + CC-A/B/C** | ~18 | corner case（座椅盲区/部分deny/行驶态/clarify/制冷热色…）| `uiue-storyboard SD18-25` | ✅ 已拍 |
| **合计** | **≈240+**（SD22-25 + RPB 补漏 51-53 后增；≈ 非精确计数）| — | — | 上百个 ✅ |

---

## 逐系列展开（ID + 一句话）

### D 系列（UIUE 交互核心，grill-master §3 + uiue-d1-d6-grill）
- **D1** 主视图形态 = 全景常驻 + 触发聚焦（非抽屉）
- **D2** 族内多 device 下钻 = 二级摘要→展开模型（191 不平铺）
- **D3** 异构值形态 = enum+switch(value.type) 5 类（非 AnyView）
- **D4** Mac/iPhone = 两独立纯端侧实例 + 可选 Bonjour（非镜像）
- **D5** 聚焦过渡 = matchedGeometry gated（D5 真分歧）
- **D6** 双通道降级 + 稳定优先（低电量/ReduceMotion）
- **D7** 7 态逐态视觉消费（四态分开：clarify琥珀/unsupported灰/safety红/crash灰）
- **D8.1** 默认不打断 / **D8.2** clarify 少用+自动 clamp / **D8.3** L3+ 思考链路=对话级 orb think（卡不动）/ **D8.4** 氛围灯炸场只读符 / **D8.5** 多卡时序守 D1 级联 / **D8.6** UIUE 边界 4 活 + 核源 3 修正

### E 系列（Phase 5 orb / 思考链路，grill-master §4）
- **E0** Phase 5 范围 / **E1** orb 实现选型（自建 MeshGradient）/ **E2** 思考链路 phase 机=事件驱动掩盖术（非计时）/ **E3** 触发判定（SceneMacroMatcher 关键词）/ **E4** 场景宏（首批 4 宏：迎宾/收尾/雨天/困了）/ **E5** DA0 deny→态 / **E6** reason→态映射 / **E7** guardReason→view 接线 / **E8** 时序整合（事件驱动全局演绎，think 两语义）

### U 系列（UIX 续批 31 条 = 老清单，grill-master §3 UIX）
- **U1** Mac 主+iPhone 加分 / **U2** Liquid Glass 只功能层 / **U3** 环形仪表限连续值 / **U4** 氛围灯开场进 MVP / **U5** Metal 水波一期做 / **U6** App 工程前置（麦克风 entitlement）/ **U7** 保留 scheme1≠照搬 / **U8** 演示编排不新起 change / **U9** golden-run=合同回放 / **U10** 状态 UI 四态分开
- **U11** base 暗底软黑 #121212（halation 约束）/ **U12** XcodeGen 薄壳 / **U13** 卡片网格 10 族 family_card_id / **U14** Mac 宽窗 AnyLayout / **U15** 低保真补反例 / **U16** 触觉仅 iPhone / **U17** UI 测试 snapshot / **U18** App Store 物料不上架 / **U19** iOS18 API 必 #available / **U20** 二期 domain 落域对话驱动
- **U21** barge-in=PTT 物理打断 / **U22** TTFA=掩盖术 immediate ack / **U23** 暗底投屏+秒切键 / **U24** 投屏有线 USB-C/HDMI / **U25** 锁域单胶囊 / **U26** 卡片渲染 enum+switch / **U27** 降级三触发器各自 UX / **U28** 中文 TTS 锁普通话 / **U29** 演示安全网 live 为主 / **U30** orb shader 自建核心 / **U31** 接真模型才定（清单非投票）

### AD 系列（ui-presentation design 架构决策）
- **AD-1** 7 态穷尽 switch / **AD-2** ui_value_type 消费侧派生 / **AD-3** Grid+matchedGeometry gated / **AD-4** 多调用编排 sequencer 220ms / **AD-5** 双端两独立实例 / **AD-6** Liquid Glass+视觉 token / **AD-7** 双通道降级 / **AD-8** 默认主驾+思考链路+交互边界 / **AD-9** family_card_id+10族常驻 / **AD-10** 族卡主 cell+occupancy 聚合 / **AD-11** 二级摘要+展开+三屏下层 / **AD-12** 竖屏全局交互（三 zone+hero放大+ScrollViewReader）/ **AD-13** Presentation Contract 三层 / **AD-14**（待实装落：连续舞台+注意力+CC1）

### SD 系列（用户故事演绎，本 session，uiue-storyboard）
- **SD1** 主题默认米白 / **SD2** ASR 利用苹果转文字 / **SD3** 对话流累积可滚 / **SD4** 氛围灯方案A+边缘5s爆发 / **SD5** iOS26 玻璃分层 / **SD6** 开场 idle 全景 / **SD7** 端态点卡片调 / **SD8** 右上角刷新+设置幕后工具 / **SD9** 拒识/确认/澄清取舍（R0/R1/R2）/ **SD10** R2 安全拒识必演
- **SD11** 米白主题视觉 / **SD12** 不编排台本+场景宏动态扩容 / **SD13** A 场景 / **SD14** 演绎控制台布局 / **SD15** 控制台视觉对齐+时段独立 / **SD16** orb 四态视觉+拟人 / **SD17** 动效块收口（10 问题）/ **SD18** 视觉块收口（V1-V12）/ **SD19** corner case 三场景（多意图/R2/clarify+CC1升级）/ **SD20** 空调温度制冷蓝/制热红渐变下划线

### V 系列（视觉块，SD18 内 + tokens.md）
- **V1** 间距 8pt 栅格 / **V2** type scale 5 级 / **V3** 圆角描边 hairline / **V4** 视觉重量数值主导 / **V5** Glass 容器边界 / **V6** theme 强制色不跟随系统 / **V7** 连续舞台+zone预算 / **V8** 注意力优先级 / **V9** 图标全 SF Symbols / **V10** 可读性 hard gate（投屏验收）/ **V11** duration ladder / **V12** Mac/iPhone 密度

### CC 系列（corner case，SD18/19/20）
- **CC1** 座椅卡主值没变盲区（→升级通用机制：非normal态主值切activeCell）/ **CC1.1** 一族多cell显哪个 / **CC2** 思考态死寂守D8.3 / **CC3** 多active视线跳原位错峰 / **CC4** 相对值超界clamp
- **CC-A1~A6** 多意图（气泡跟句数/TTS合并/部分deny/runtime gap/开空调默认温度）/ **CC-B1~B4** R2后备箱（unsafe盲区/行驶态纯话术/think1.0s/红克制）/ **CC-C1~C4** clarify（主线不演/vs clamp边界/多轮/四态分开）

### G 系列（demo default_scope，Phase -1 前置）
- **G01-G28** default_scope 28 条（C2 default_scope / C3 target resolution / state applier / readback scope_origin / C5-C2 parity / C6 gold + 三机械门）→ 详 `demo-default-scope-grill-decisions-2026-06-24.md`

### 锦标赛 R1-R5（41 题，含 UIUE 相关）
- Q01-41：A2 工具数实算 / generated 漂移门 / OpenSpec change 切分 / scope full-demo / verify-tool-surface-parity / checkpoint 抽样 / 范式旧锚判改 / SRD 三层改写 / route matrix / 场景宏防隐藏 planner … → 详 `final-grill-list.md` + `grill-decisions-master.md §2`

---

## 用法（后续 UIUE 推进回顾对比点）

每次 UIUE 推进/实装前，回本表确认：① 该议题落哪个系列已拍 ② 不重复 grill 已透的 ③ 不违背已定（grill-recall 铁律）。配套**作品锚点集** `gptimage2-anchor-set/`（视觉对比基准）。

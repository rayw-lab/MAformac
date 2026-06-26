---
type: research-synthesis
topic: 业界 iOS/前端交互开发【完整工作流程·规范·交互方法论】× 磊哥「grill→grill→矩阵→派单」对比
date: 2026-06-26
authority: research_not_ssot
sources: [本会话第二轮 4 finder fan-out (F1 端到端流程 / F2 规范体系 / F3 UIUE交互方法论 / F4 协作handoff决策记录)]
companion: docs/research/2026-06-26-ios-frontend-interaction-runtime-synthesis.md (第一份=技术维度: 视觉/动效/runtime握手/测试API/像素门)
verify_status: 方法论框架名/经典出处已核(双钻/Shape Up/Saffer/Norman/NN-g/Pearl-VUI/ADR/RTM/SDD 均一手或权威); finder 未核数字(68%返工/47%/METR19%/NN-g 92%/Spotify) 作方向性论据已标注
---

# 业界前端交互开发流程·规范·方法论 × 你的「grill→grill→矩阵→派单」对比

> 回答你的核心问题：「我是 grill→再 grill→矩阵表→派单吧？**是不是漏了很多**？」
> 两份报告分工：**本份=方法论/流程/规范**（你真正问的）；姊妹份 `...runtime-synthesis.md`=技术维度（API/选型/像素门）。

## 一句话定性（4 finder 强收敛）

你的流程**不是"漏了很多"，是"结构性偏科"**——在**【决策正确性·契约·对抗审计·终审】主轴上强于业界平均**（甚至领先），薄在**【交互体验的早期廉价验证】+【表现层横向规范（态/动效）】+【派单后的 design QA 闭环】**这条"手感/体验"支线。

> 根因：grill 验的是「**逻辑对不对、契约全不全**」，业界原型/可用性测试/design QA 验的是「**用起来好不好用、长得对不对**」——**两个问题不同源，前者强不能替代后者**。你座舱语音老兵的经验把"用户研究/可行性"前置内化进了人脑，所以前端发现轨薄但 demo 能扛；但"实装后逐态视觉走查"这道后端门，经验替代不了。

---

## 二、业界完整流程 16 环节链（F1，双钻/Shape Up/Lean UX 综合）

```
钻一(问题空间)         钻二(方案空间)                         交付/迭代
①Discovery ②Define → ③Ideate ④IA ⑤Wireframe ⑥视觉 ⑦交互原型+动效 ⑧可用性测试 ⑨Design Review(DVF门) → ⑪Handoff ⑫Build ⑬Design QA ⑭a11y → ⑮Ship ⑯Iterate
                                                  ⑩技术Spike(并行插入任何不确定点)
横切: Design System 治理(token/组件库/版本/贡献) 贯穿全程
```
每环节有【产出物·负责人·评审门·时机】。核心逻辑：**越晚发现 UX 问题越贵**（线框期改一处≈1h，生产环境改贵 ~100x，IBM 研究，finder 引二手未核）。

---

## 三、🔴 大对比矩阵：你的流程 vs 业界全流程（整合 F1+F4 映射 + F2 规范 + F3 交互）

| 业界环节 | 你「grill→grill→矩阵→派单」对应 | 判定 | 说明 |
|---|---|---|---|
| ①Discovery 用户研究/竞品 | 你=座舱老兵 + 3990协议/12000bug 真实语料 ground-truth | 🟡 隐式 | 研究前置内化进人脑+语料，但无独立可追溯 discovery artifact。demo 够 |
| ②Define PRD/验收标准 | grill 早期 + 矩阵表 | ✅ **强** | grill=Define+spec sign-off，覆盖矩阵=验收标准物化，比业界 PRD 更硬（file:line+SHALL） |
| ③Ideate 多方案发散 | grill 对抗审计 | 🟡 部分 | grill 偏**收敛批判已有方案**，缺"先铺 N 个 radically different 方案再砍"的真发散 |
| ④IA/user flow | — | ❌ 漏 | 前台交互链路(触摸→state→语音→联动)缺一张流程图级 IA，散在 grill 笔记 |
| ⑤Wireframe 低保真线框 | anchor 图 | 🟡 部分 | 有 anchor 视觉标尺，但跳过"剥离视觉只看结构"的廉价验证 |
| ⑥视觉设计 | anchor + 5-Gate(aesthetic rule) + visual-acceptance | ✅ 对应 | 视觉评审门制度化 |
| ⑦交互原型+动效 | 派单内联交互规则 | 🟡 部分 | 决策直接跳真代码实装，**无独立"可点击原型"** |
| ⑧**可用性测试** | user-story-scenarios skill 演绎 | 🟡→❌ | 有"台本演绎"雏形，但**无"实装前真人点可交互原型验手感"的独立门**。座舱"5分钟惊艳"恰是体验问题 |
| ⑨Design Review(DVF门) | grill + 矩阵 | ✅ **强** | Feasibility 覆盖到位；Desirability/Viability 隐式(靠你经验) |
| ⑩**技术 Spike** | capsule route spike(偶发) | 🟡→❌ | spike 未制度化，常**直接派单=spike+build 合并**，风险点没隔离 |
| ⑪Handoff | **派单(dispatch)** | ✅ **AI时代独特强** | 派单内联 SSOT+file:line = handoff 升级版，对 AI agent 比人对人要求更高，你做对了 |
| ⑫Build | 派单后 agent 长跑 | ✅ | TDD+swift test+make verify 机械门 |
| ⑬**Design QA 视觉走查** | force-state 截图 + 5-Gate + visual-acceptance | 🟡 雏形 | 有底子但缺"逐组件比对设计源 spec、差异挂工单、复验才关闭、不过不准合"的制度化闭环 |
| ⑭a11y audit | 5-Gate 含触控/对比 | ❌ 部分 | Dynamic Type/VoiceOver/Reduce Motion 未系统纳入(demo 可裁) |
| ⑮Ship | ≥3厂商终审+post-fix审 | ✅ **强** | cross-vendor 并集+实跑审，超业界普通发布门 |
| ⑯Iterate | 磊哥驱动 | 🟡 | 无上线度量回环(demo 性质,可接受) |
| **横切:DS 治理** | DesignTokens.swift + Mapper(第二SSOT) | 🟡 | 契约层强，但 token 三层分层/组件治理未显式化 |
| **横切:规范-状态设计** | D7 7态 + risk-policy | 🔴 **高 gap** | 卡片"空/执行中/成功/失败/离线/族外"五态未系统化成规范矩阵 |
| **横切:规范-motion** | grill 提 ripple/淡显 | 🔴 **高 gap** | 无 easing/duration token 集，散落写动画必不一致("反应快"北极星=motion 核心) |
| **横切:VUI 确认/澄清/拒识** | risk-policy R0-R3 + clarifyTag | 🔴 **高 gap** | 决策层有，但**交互呈现层**(每种确认/澄清/拒识 = 什么视觉+语音+氛围灯)未对照 VUI 5类错误分类系统化 |

---

## 四、🔴 你的强项（4 finder 共识，业界领先，别因找 gap 而丢）

1. **grill = critique + review + spec sign-off 三合一且更狠**：业界 critique(早期批判)+review(正式门)分开开会过稿；你做到 file:line 可追溯 + SHALL 契约 + cross-vendor 对抗审，严于多数团队。
2. **多 agent 对抗 = 天然 devil's advocacy 去人格化 + red team 并集**：业界"指派一人唱反调"(+61% 考虑替代方案，finder 未核)，你用多厂商 agent 天然实现，覆盖面更广。
3. **派生跟踪回写纪律 + 段间一致性 check = 正面命中 RTM/ADR 最致命坑**：业界 RTM 致命点="维护滞后→虚假信心"(根因=链接没建/需求变了没更新)，多数团队栽这；你的回写纪律恰好治它。
4. **派单内联 SSOT 不给指针 = 2025 SDD 同源且更进一步**：Thoughtworks "speed without spec = confident wrong code"；你更狠(外部执行方不会主动翻 SSOT，必须喂进 plan)。
5. **grill-decisions superseded/immutable = 已对齐 ADR append-only 铁律**。

> 定性：你流程在「**澄清决策→交接→终审**」这条**正确性主轴**领先业界；薄在「**IA→线框→可点原型→可用性测试**」这条**手感验证支线** + 「**表现层横向规范**」+ 「**派单后 design QA 闭环**」。

---

## 五、🔴 缺口（按优先级 × demo 边界 该补/可省）

### 🟢 该补（语义安全带级，直接决定"现场惊艳 vs 半成品"）

| # | 缺口 | 怎么轻量补(不破坏 grill→派单) | 出处 |
|---|---|---|---|
| 1 | **全态设计矩阵**(最高ROI) | 10族卡片/对话流/orb/氛围灯/capsule 五元素 × `idle/loading/error/success/empty/partial/disabled/rejected` 八态，缺哪补哪。**进现有矩阵表加"状态维度"列**，不另起 | NN/g 空态 + state-machine union(F3) |
| 2 | **VUI 确认/澄清/拒识交互模式表**(语音demo灵魂) | 三列：场景(放音乐/关键操作/误识/族外/行驶中)×风险等级×确认模式(隐式/显式/澄清/拒识)×呈现(话术+视觉+氛围灯)。对照《Designing VUI》5类错误分类 | Cathy Pearl VUI(F3) |
| 3 | **最小 motion token 集**(iOS26+"反应快"强相关) | 4 easing(standard/enter-ease-out/exit-ease-in/sharp)+5 duration(xs-xl带用途)+高频<150ms/exit比enter快，落 DesignTokens。**别上 Material spring 全套**(过度工程化) | Material3 Motion / Apple HIG(F2/F3) |
| 4 | **派单后 design QA 视觉走查闭环** | force-state 截图升级为强制 ship 门：逐态对照设计 spec，差异挂 punch list，**复验才关闭**(track resolution not filing) | Eleken/OverlayQA design QA(F1/F4) |
| 5 | **可交互原型门**(grill与派单之间插一道) | 用 DebugGallery+force-state+Preview 做"只验交互链路"的可点原型，方案经理视角连点5分钟验手感，**再派单全量实装** | F1环节7-8 / prototype skill |

### 🟡 中等(demo可接受,扩展时变债)
- IA/user flow 显式图(excalidraw/mermaid 画前台交互流程，作派单内联 SSOT)
- 低保真线框验证(剥离视觉只看结构)
- token 三层 semantic 层(仅态驱动外观，加态/换主题时防全改)

### 🔴 demo 可省(明确划界省力气,标 deferred 进 phase matrix)
- 独立 Figma 高保真重原型 / a11y WCAG 全量审计 / 上线度量回环 / DS 贡献流程·RACI·版本治理 / i18n·RTL(已主动砍单语中文) / 完整组件库文档站

---

## 六、与第一份技术报告的交叉点（两份合看的钩子）

| 方法论缺口(本份) | 技术报告(synthesis)对应 | 合看结论 |
|---|---|---|
| 派单后 design QA 闭环 | 像素 RMSE 硬门=反模式(phase2_zone_compare.py纯像素) | design QA 的**对比算法**该换感知级 diff+5-gate；design QA 的**流程**该建复验闭环。算法+流程一起修 |
| 全态设计矩阵 | runtime "一进两出" + DemoRuntimeResultKind 8类枚举 + 冻结枚举穷尽switch | 全态(空/错/拒识/部分)正好映射 8 类结果枚举；穷尽 switch 禁 default = 全态在编译期 enforce |
| motion 规范缺失 | 动效双栈(状态转移 vs Canvas连续渲染)+ 验收必真机 | motion token 定 easing/duration；双栈分离防掉帧；玻璃/shader 质感真机验 |
| VUI 交互呈现层 | 中间态(ASR volatile/思考链)走旁路 + SpeechAnalyzer volatile/final | VUI 确认/澄清的"在听/思考中"反馈 = 旁路 effect，不污染 snapshot |
| 投屏可读性(negative space) | arc-minute 量化门 + performAccessibilityAudit | 投屏字号早验 + a11y audit 抓"对比不足/字被截" |

---

## 七、流程补全建议：你的「grill→grill→矩阵→派单」升级版

**不推翻你的主流程**(它的正确性主轴是强项)，在两处插门 + 矩阵加两维：

```
grill(critique式探索) → 再grill(review式门控+对抗审计)
  → 【矩阵表 ⊕ 加2维: 状态维度 + motion维度】       ← 补表现层横向规范(缺口1/3)
  → 【可交互原型门: 验交互手感 + 技术spike隔离风险】  ← 补体验早验(缺口5+spike)
  → 派单(内联SSOT,垂直切片不水平切)
  → 【派单后 design QA 闭环: 逐态对照spec+复验才关闭】 ← 补后端门(缺口4)
```
- **矩阵加 2 维**(状态×motion) = `grill-baseline-skeleton-upfront` 应用：grill 每拍一族就填状态/motion 格，不事后补。
- **可交互原型门** = grill(逻辑对) 和 派单(实装) 之间补一道"手感对"，对接"mock 桩态≠真接线"边界(前台交互真做+后端mock)。
- **派单后 design QA** = visual-acceptance/5-Gate 升级成强制 ship 门，复验闭环。
- **垂直切片** = 派单按"穿透全层薄端到端"切，非按层/phase 水平切(防返工)。

---

## Source(4 finder URL,按维度;均 2026-06 检索)
- **F1 流程**：[Double Diamond(Design Council 官方)](https://www.designcouncil.org.uk/resources/the-double-diamond/) / [Shape Up(Basecamp)](https://basecamp.com/shapeup/0.3-chapter-01) / [Technical Spike(Kent Beck起源)](https://learningloop.io/plays/technical-spike) / [Design QA(Eleken)](https://www.eleken.co/blog-posts/design-qa-checklist-to-test-ui-and-prepare-for-design-handoff) / [DVF Review(UXPin)](https://www.uxpin.com/studio/blog/design-review-template-balancing-desirability-viability-feasibility/)
- **F2 规范**：[Apple HIG](https://developer.apple.com/design/human-interface-guidelines) / [Material3 Motion](https://m3.material.io/styles/motion/easing-and-duration) / [W3C DTCG v2025.10](https://www.designtokens.org/tr/2025.10/format/) / [WCAG2.5.8触控](https://www.w3.org/TR/wcag2mobile-22/) / [Polaris内容](https://polaris.shopify.com/content/product-content)
- **F3 交互方法论**：[Saffer Microinteractions](https://blog.prototypr.io/the-4-components-of-a-microinteraction-836732173c7c) / [Norman 6原则](https://medium.com/@sachinrekhi/don-normans-principles-of-interaction-design-51025a2c0f33) / [NN/g 空态](https://www.nngroup.com/articles/empty-state-interface-design/) / [NN/g 10启发式](https://www.nngroup.com/articles/ten-usability-heuristics/) / [Pearl VUI(O'Reilly)](https://www.oreilly.com/library/view/designing-voice-user/9781491955406/) / [车载HMI(Aufait)](https://www.aufaitux.com/blog/mi-design-principles-automotive-ux/)
- **F4 协作/handoff/决策**：[Figma handoff(sync not handoff)](https://www.figma.com/best-practices/guide-to-developer-handoff/) / [Design Critique vs Review](https://thecrit.co/resources/design-critique-vs-design-review) / [Vertical Slice/Tracer Bullet](https://www.humanizingwork.com/the-humanizing-work-guide-to-splitting-user-stories/) / [Spec-Driven Dev(Thoughtworks)](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices) / [ADR(AWS)](https://aws.amazon.com/blogs/architecture/master-architecture-decision-records-adrs-best-practices-for-effective-decision-making/) / [RTM(Jama)](https://www.jamasoftware.com/requirements-management-guide/requirements-traceability/traceability-matrix/)

> 🔴 finder 未核数字（68%返工/47%返工减少/METR慢19%/NN-g 92%无空态/Spotify跳semantic层/VoiceOver 71%/德语+20-25%/线框改贵100x）= 二手博客转述，作**方向性论据非硬数字**，对外引用前核一手。

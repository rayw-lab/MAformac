# UIUE 用户故事演绎台本 grill 决策（2026-06-25）

> grill-with-docs engineering-contract mode。从【用户故事演绎视角】拍 demo 台本：方案经理给客户现场演绎，怎么点/喊话/各屏幕元素表现。
> 承接 AD-11/AD-12 三屏分层 + D8/D13/D6。**避 PR7(codex rebuild-c6)冲突**：UIUE 专属文件，不碰 Makefile/docs/lessons-learned.md/docs/CURRENT.md/docs/research/INDEX.md/Core/Bench/Core/Contracts/contracts/。
> 术语 SSOT = `docs/uiue-ubiquitous-language.md`（避 PR7 改的根 UBIQUITOUS_LANGUAGE.md）。

---

## SD1 — 演绎开场起点 = idle 全景态（非每次 boot reveal）（2026-06-25 磊哥拍「同意推荐」）

**决策**：演绎开场客户第一眼 = **idle 全景态**（app 已开），非每次重启看 boot reveal。开场惊艳靠 idle 态本身质感（iOS26 + orb 呼吸 + 卡片质感），非开机动效。

**physical landing**：
- `AppLaunchMode`：`idle`（演绎默认态）/ `bootReveal`（仅真冷启动首次 ~2.5s phaseAnimator，非演绎主路径）。
- `Theme` **默认 `.ivory`（米白，🔴 磊哥 2026-06-25 改，原默认深灰）**；`.deepSpace`（深灰深空辉光）在设置调；**light/dark 双值跟随系统切换**（详 SD11）。
- `DemoResetControl`：一键归位干净 idle（演绎复位，防上个 demo 残留态；位置待设置面板 grill 定）。

**pre-mortem**：
- 🐯 tiger：每次重启演 boot reveal 拖节奏 → 台本用「app 已开直接喊」。
- 🐘 elephant（最值）：开场惊艳靠 idle 态质感（磊哥「too low」正是这个），非 boot reveal。
- frame-break：演绎连续性 → 需「演绎复位」入口（一键归位干净 idle）。

**承接**：D6 wow（boot reveal 降为冷启动首次）/ AD-12 §二三 zone（orb/content/mic）。

---

## SD2 — 喊话 = push-to-talk 按住录音 + iOS ASR 端侧转文字（后端只接文本）（2026-06-25 磊哥拍）

**决策**：话筒交互 = **push-to-talk 按住录音**（非我推荐的 tap-to-talk），松开 → **iOS SFSpeechRecognizer 端侧解析音频→文字** → 文字送后端（**后端只接 ASR 文本，不解析音频**）→ 中间对话区显示。

**physical landing**：
- `MicInteraction = pushToTalk`：按下→录音+listen 态 / 松开→结束→iOS ASR 解析→text。
- `ASRBackend = SFSpeechRecognizer`（端侧 audio→text，on-device 离线，U28）；C3 pipeline 入口只接 `text: String`（不接 audio buffer）= 后端纯文本驱动。
- `Presenter ≠ fixed`：谁喊话**不局限**（方案经理标准话术 / 客户体验泛化，都可能）。

**pre-mortem**：
- 🐯 tiger：客户随便喊（不局限）ASR 识别错/口音 → 翻车风险 → 需澄清/拒识 UI（见 clarify 态 grill）。
- 🐘 elephant：后端纯文本驱动 = ASR/音频完全端侧，**后端（C3/PR7 线）与语音解耦** → 语音全在 Core/Voice（UIUE 专属，PR7 没碰，避冲突 ✅）。

**承接**：D13 push-to-talk / U28 系统 SFSpeechRecognizer 主 + U6 麦克风 entitlement / D15 文本先行。

---

## SD3 — ASR-TTS 对话流布局 + think/时序全承接 E8（2026-06-25 磊哥拍 + 🔴 回读 E8 修正我滑回计时 frame）

**决策**：
- **对话流布局**：用户 ASR 文本**右气泡** / 助手 TTS 文本**左气泡**，`ScrollView` **累积可滚**（多轮历史，新消息底部）。
- **think 时长/各屏幕时序 = 全承接 E8（不重拍）**：思考链路 think（analyzing）= **事件驱动非计时**（orb think 掩盖后端 → 后端卡片 `cardsDidStartChanging` 跳动事件=结束信号 → handoff speak；3s 虚数最小 ~1s guard）；安全拒识 think = **固定 1.0s** 纯演出；各屏幕元素时序 = E8 四时序（A L1/B L3+/C 安全拒识/D 部分 deny）。

**physical landing**：
- `DialogueBubble { role: .user|.assistant, text }`：user 右靠 ASR / assistant 左靠 TTS；`ScrollView` 累积 + `scrollTo(last)`。
- `ThinkingPhase`（承接 E2/E8）：`analyzing`（事件驱动，cardsDidStartChanging 结束）/ 安全拒识 1.0s 固定。

**🔴 元认知修正**：我 Q3 凭印象拍「think 保底时长 1.2s」= 滑回 E2/E8 早否的【计时 frame】（GLM 被 catch 4 次同坑）；磊哥「回忆 grill 结论」→ 回读 E8 修正（claim-vs-reality §28：凭印象 vs 回读一手）。

**承接**：E2 事件驱动掩盖 / E8 时序串联 + think 两语义 / E7 reasons map。**用户故事演绎 grill 承接 E0-E8 机制，只新增 E0-E8 没细化的（话筒/对话流布局/主题/设置/氛围灯边缘）。**

---

## SD4 — 氛围灯 = 方案A 单色→该色混合 + 3 动作；卡片渐变色常驻 / 边缘 5s 爆发反馈（2026-06-25 磊哥拍）

**决策**：氛围灯指令（「调成大海的颜色」→蓝）= **3 动作同时**：
1. **卡片显示渐变该色**（非纯色块，4a colorSwatch 升级成**渐变色**；常驻显示氛围灯当前色）。
2. **屏幕边缘混合发光**（方案A：单色→该色为主混合，8 色全混合）—— **平时不显示，仅氛围灯指令触发**；执行成功瞬间 **闪烁+粒子爆发持续 5s → fade out**。
3. **TTS 显示**「已为您把氛围灯调整为蓝色」（对话流左气泡）。

**physical landing**：
- `AmbientCardGradient`：氛围灯卡片 = 该色**渐变**（非纯色块）常驻显示当前色。
- `AmbientEdgeBurst`：8 单色各映射「该色为主混合」（紫→紫金/红→红橙/青→青紫/绿→绿青/蓝→蓝青/白→白金/橙→橙金/黄→黄金）；**仅氛围灯指令触发**（平时 idle 不显示）；执行成功瞬间 **闪烁+Canvas 粒子爆发 5s** phaseAnimator → fade out。
- 分工：**卡片=状态（渐变色常驻）/ 边缘=炫反馈（5s 爆发）**，不重复。不改 contract（ambient.color 仍单色），避 PR7。

**pre-mortem**：🐯 粒子爆发 5s GPU（U30 限）→ Canvas spike 帧率 / 🐘 边缘仅触发 5s 非常驻 → 平时不抢主视觉。
**承接**：E0 炸场后续 / D8.4 氛围灯只读符 / U4 上车迎宾（E4 宏）。

---

## SD5 — iOS26 玻璃分层（控件/展开卡/功能层 glass + 摘要卡高级 material）（2026-06-25 磊哥拍 + WebSearch HIG 实证）

**决策**：磊哥要的卡片高级感 ⊕ AD-6「内容层禁 glass」**不冲突**——WebSearch HIG 实证精确边界（control/floating overlay 可 glass，dense content text 守 solid）。

**physical landing**：
- **value.type 控件**（Gauge=level meter / toggle / stepper=progress）= `.glassEffect()`（HIG「level meter/progress 是 control」可 glass）。
- **4b 触发聚焦展开卡**（floating overlay）= `.glassEffect()`。
- **功能层**（话筒/orb/设置/顶栏）= `.glassEffect()`（AD-6 control_glass）。
- **10 族摘要全景卡**（磊哥「10族也要用」）= **高级 material**（`.regularMaterial`/渐变质感，**非 glassEffect 糊 text**，守 HIG；比当前暗灰底好）。
- **不用 GlassEffectContainer 液态融合**（磊哥「不需要，但要比现在好」）+ 不用 `.interactive()`（GPU）。

**pre-mortem**：🐯 glass GPU 成本（撞 U30 氛围层限）→ 不 interactive/不 container morph + spike 帧率 / 🐘 摘要卡 material 非 glass（守 HIG text 不糊），「10族也要用」= material 升级。
**🔴 修正 AD-6**：AD-6「内容层禁 glass」**精修非推翻**——control（value.type 控件）+ floating overlay（展开卡）可 glass，dense content（摘要卡 text）守 material。source: blakecrosley/conorluddy/Apple HIG Materials。

---

## SD6 — 点卡展开 = 4b 触发聚焦 composite（手点）；语音限 10 族车控；触摸调有数值控件（D8.4 松动）（2026-06-25 磊哥拍）

**决策**：
- 点卡 = **4b 触发聚焦展开 device composite**（**手点触发**，非语音）。
- **🔴 语音语料严格限 10 族车控指令**，「打开XX详情/设置」这类 UI 操作命令**不做语音**（②，语音不触发展开/设置）。
- 展开卡**有数值控件可触摸调节**（dial 温度/percent 开度/stepper 档位）—— **D8.4「触摸=只读」松动**（磊哥「触摸要考虑有数值的怎么动」），交互细化见 SD7。

**physical landing**：
- `ExpandTrigger = .tap`（手点族卡；语音意图限 10 族车控，不含「打开详情」UI 命令）。
- **D8.4 amend**：触摸从「纯只读高亮」→「有数值控件可触摸调节」（demo 本地 mock，SD7 定怎么调）。

**承接 + amend D8.4**：D8.4「触摸=极简查看非控制器」**松动**——有数值控件可触摸调（demo 本地 mock）。参考图 Image #8 控件网格形态。

---

## SD7 — 触摸调节 = 真实完整 + 走后端 mock state（state 一致性，语音基于当前态推理）+ 联动 10 族 + 静默（2026-06-25 磊哥拍，🔴 揭示 demo 核心架构 + 边界调整）

**决策**：
- 触摸调节 = **真实完整**（非轻量）：dial/percent **± 步进** / stepper 点段位 / toggle 点切换 / badge 循环切换（磊哥「其他交互动作都同意」）。
- **🔴 走后端 mock state（共享 store）**——触摸更新 state，**语音推理基于当前态**。关键场景：**手动调 26 度 → store=26 → 语音「我有点冷了」→ 后端读当前 26 → 升温推理 → 输出 28/27 度协议 → 前台显示**。= demo **状态记忆 + 上下文推理卖点**（非无状态单次指令）。
- **联动所有 10 族**（含开关）：触摸调任意族都走后端 state。
- **静默无 TTS**（手动调不播报，语音才 TTS）。

**physical landing**：
- 触摸调节 → 更新 mock store（共享 state SSOT）→ 卡片态 + numericText。
- 语音意图推理读**当前 store 态**（exp_step「冷了/热了」基于当前值 ±，非绝对值）。
- `state 一致性`：触摸 + 语音 单一 mock store SSOT，后端基于当前态上下文推理。

**🔴🔴 边界调整（磊哥 2026-06-25 拍，影响全 roadmap）**：**PR7（codex rebuild-c6）已暂停**，「**UIUE 原型设计 + 产品交互设计最重要**」→ **UIUE 边界放宽**（不再受「禁碰后端 Core/State/Core/Contracts」限，可打通触摸→state→语音推理**完整链路**）。**UIUE 原型 = 完整 demo 交互**（前端视觉 + 触摸 + 语音 + state 联动 + 上下文推理），非只前端视觉。

> 🔴 **AMENDMENT（磊哥 2026-06-25，覆盖上文「完整链路碰真后端」）**：UIUE A-2（step2）实现 = **全 mock 前台**——触摸→**mock** `DemoVehicleStateStore` 写、语音推理 = **mock 预设响应**、演绎控制台 force = **mock context 切换**，**不接真 NLU/ASR/TTS/LoRA/runtime backend**（后续接线 DEFERRED）。上文「可打通触摸→state→语音推理完整链路」= **用 mock 实现完整交互呈现，等后续接线**真后端；可碰现有 mock 车控 store 展示联动，**不改 state-cells.yaml 契约语义**。正式落点：OpenSpec `ui-presentation/spec.md` 4 个 mock-frontstage Requirement（mock interaction boundary / expanded controls mock state / demo control panel mock force / ambient edge burst presentation-only）+ plan v3 Phase 3-5。执行方以本 amendment + spec Requirement 为准，不以上文「碰完整链路」字面。

**pre-mortem**：🐯 后端 exp_step「冷了/热了」语义是否覆盖（contract exp_step little/gear/extreme，「冷了」需映射升温，核 contract 可能补）/ 🐘 触摸+语音共享 state 单源（mock store SSOT），两者都更新它。

---

## SD8 — 右上角 刷新=演绎复位 + 设置=方案经理幕后工具（主题/场景宏force/配置）（2026-06-25 磊哥拍「推荐对」）

**决策**：
- **右上角 ↻ 刷新 = 演绎复位**（SD1 DemoReset，一键归位干净 idle）。
- **右上角 ⚙️ 设置 = 方案经理幕后配置工具**（客户不碰，**轻量好用不上演绎台面**）：① **主题切换**（深灰 ↔ 米白，现场光线，实时切不重启）② **场景宏 force 触发**（E3，显式选「上车迎宾/雨天关窗/我有点困了」，`#if DEMO_MODE` 隔离防识破）③ demo 配置（双端标识/语言/音量）。

**physical landing**：
- `RefreshControl`：↻ → DemoReset（归 idle）。
- `SettingsPanel`（幕后）：themeToggle / sceneMacroForce(`#if DEMO_MODE`) / demoConfig；轻量好用非好看。
- `Theme` 实时切换（deepGray ↔ ivory，无重启 + 动画过渡）。

**🔴 frame**：设置 = **演绎前准备工具**（方案经理演绎前配好，不当客户面开=破真智能幻觉）→ 不为演绎展示优化视觉，重点好用。

**承接**：SD1 DemoReset / E3 场景宏 force（长按 orb 1.5s 隐蔽 + 设置显式，都 `#if DEMO_MODE`）。

---

## SD9 — 拒识/确认/澄清 demo 取舍（基于端状态 risk-policy R0/R1/R2 + 5 幕一手）（2026-06-25 磊哥拍 1+6）

> 🔴 回读端状态一手纠正我 Q9 凭印象：后备箱是 **R2 安全拒识**（非族外 blocked_hard）/ 漏了 **R1 二次确认**态 / 行驶态 = scene5 方案经理 mock 切「行驶模式」vehicle.speed=30。

**决策（磊哥先拍 1+6）**：
- **1. R2 安全拒识（scene5 climax）= 必演**：行驶中开门/后备箱（`vehicle.speed>0`，forbidden `door_open_while_moving`）→ unsafe + refuse_explain「行驶中为了安全暂时不能开门，停稳后我再帮您」。行驶态 = 方案经理 mock 切「行驶模式」force `vehicle.speed=30 gear=D`（设置/场景宏，SD8）。
- **6. 族外 blocked_hard = 不演（人为控场）**：🔴 磊哥「不会让客户说族外，人为控制限 10 族」→ **族外态 demo 不触发**（方案经理控客户只说 10 族内）。E6「族外→blocked_hard」机制保留（兜底）但 **demo 主线不演**。

**physical landing**：
- R2：scene5 climax + vehicle.speed force + unsafe 态 + refuse readback（Core 模板）。
- 族外：blocked_hard 机制 E6 兜底保留 + demo 演绎台本不含族外指令（方案经理控场）。

**承接**：risk-policy R2 / scene5 / E6（族外兜底不演）/ E8 C 安全拒识时序。
**2/3/4/5（R1确认/状态感知/超范围/模糊）= 用户故事举例 grill（SD10）。**

---

## SD10 — 2/3/4/5 demo 取舍（用户故事 + 🔴 3s 端到端闭环 + 不打断）（2026-06-25 磊哥拍）

> 🔴 端到端交互闭环 = **3s**（喊话→执行→反馈），D8.1 默认不打断 → **打断态主线不演**。

**决策**：
- **2 R1 二次确认 = 不演**（确认=打断违 3s）：「打开全部车窗」→ **直接全开 satisfied，不确认**。risk-policy R1 机制保留（兜底）demo 主线不演。
- **3 状态感知拒重复 = 演**（scene1 不打断智能）：喊「关空调」（已关）→ orb 短 think → speak「空调已经是关闭的了」+ 空调卡不变（不重复执行）。3s 内。
- **4 超范围 clamp = 演**（不打断 D8.2 自动替代）：喊「空调调到 5 度」→ 空调卡直接 18℃ satisfied + speak「最低 18 度，已为您调到 18」。3s 内。
- **5 模糊澄清 = 主线不演**（D8.2 clarify 少用，clarify 琥珀仅 force-state 展示）。

**physical landing**：演的智能态(3/4) = 3s 闭环 + 不打断（orb 短 think→speak+卡片态，**无确认/无倒计时**）；不演的打断态(2/5) 机制保留（risk-policy R1 / clarify E6 兜底）demo 主线不触发。

**承接**：D8.1 默认不打断 / D8.2 clarify少用+自动clamp / scene1 状态感知 / 3s 端到端闭环 / E8 时序。

---

## SD11 — 米白主题视觉（米白默认 + 深空设置调 + light/dark 跟随系统）+ 苹果开发 skills 盘点（2026-06-25 磊哥拍全认同）

**决策（米白主题）**：
- **米白默认**（磊哥改，SD1 原默认深灰→米白）；深空（深灰）在设置调；**light/dark 双值跟随系统**（非只手动）。
- 米白方案（全认同）：背景暖白 #F5F3F0 / 白卡+柔和阴影（非辉光）+ light material / 深色文字 #1A1A1A / **高级感靠柔和阴影+大留白+iOS26 light glass+精致字体层级**（替代深灰辉光）/ 7态色亮底加深 / 氛围灯边缘亮底调强度 / 语义 token 共享 + light/dark 双值。

**physical landing**：
- `Theme = .ivory(默认) | .deepSpace(设置调)` + `@Environment(\.colorScheme)` 跟随系统 light/dark。
- 语义 token（asset catalog `Color("bgBase")` light/dark 双值自动适配）；iOS26 glass 自动 light/dark；自研元素（content_glow/氛围灯/态色）手动 light/dark 双值。

**pre-mortem**：🐘 氛围灯边缘+7态辉光在米白亮底弱（暗底才炫）→ 米白炸场靠饱和色块/描边非辉光。

### 🔴 苹果开发 skills 盘点（UIUE 实装巨人肩膀，development-workflow §0 + blueprint-teardown）
`Tools/skills/axiom/`（27 axiom 苹果技能）+ ios-simulator/ettrace 直接可用，实装逐 task 调：

| UIUE 实装点 | 借鉴 skill |
|---|---|
| SD5 iOS26 玻璃 | **axiom-design/liquid-glass.md(+ref)**（glassEffect/Container/light-dark适配/HIG边界）+ **axiom-swiftui/26-ref.md** |
| E1 orb四态 + SD4氛围灯粒子 + D6 wow | **axiom-swiftui/animation-ref.md**（phaseAnimator/keyframeAnimator/TimelineView）|
| orb/氛围灯/glass GPU(U30限) | **axiom-swiftui/swiftui-performance.md + axiom-graphics/display-performance.md** |
| 米白/深灰字体层级高级感 | **axiom-design/typography-ref.md + hig.md** |
| 三屏分层 + 手势 | **axiom-swiftui/layout.md/containers-ref.md/gestures.md** |
| 双通道无障碍 + 截图验收 | **axiom-accessibility + ios-simulator-skill + ios-ettrace** |

**承接**：SD1（默认改米白）/ SD4/SD5 / tokens.md（扩 light/dark 双值）/ aesthetic-first 5gate。

---

## SD12 — 不编排固定台本（靠 LoRA 泛化+人为控场）+ 场景宏动态扩容 + 端状态模块页面（2026-06-25 磊哥拍）

**决策**：
- 🔴 **不编排固定台本**：demo 不要固定线性台本——后续 **LoRA 1.7B + FunctionCall + 规则语义** 兜住 10 族所有可能语料 + 方案经理**人为控制范围**（站客户身边控场，现场只说 10 族）。承接 demo-scenarios meta「非固定话术脚本靠 LoRA 泛化」+ paradigm「现场只说 10 族」。**我推荐的 7 步线性台本否决。**
- **4 场景宏 OK + 支持动态扩容**：E4 上车迎宾/离车收尾/雨天关窗/困了 保留，宏**动态可扩**（不硬编码 4 个）。
- **宏结合端状态 → 单独【端状态模块页面】**：方案经理设端状态（时速120/下雨/其他 10 族关联端状态）触发宏/满足场景前置（行驶态→安全门 climax / 雨天→雨天宏）。

**physical landing**：
- 无固定台本 schema（靠 LoRA 泛化 + 人为控场）。
- `SceneMacroRegistry` 动态扩容（宏列表可加，非硬编码 4）。
- `EndStatePanel`（端状态模块页面）：vehicle.speed 滑块 / 天气 / gear / 10 族关联端状态调节 → 触发宏/满足前置；**位置 Q13 grill**。

**承接**：demo-scenarios meta（LoRA 泛化非脚本）/ E3 SceneMacroMatcher / E4 4 宏 / SD8 方案经理幕后工具 / SD9 行驶态 force。

---

## SD13 — 演绎控制台 = 端状态白名单(A整车+B座舱+C环境) 三大块 + 默认值收束「常态运行」卡（2026-06-25 磊哥拍三大块）

> 🔴 **真 teardown 端状态全集（33 base = 31 device + 2 safety）后设计**（grill-recall 强化：列全集再设计，纠我凭印象提天气/路面 contract 没有）。

**决策**：
- **端状态白名单 = A 整车运行(vehicle.speed/gear) + B 座舱设备(10族31base) + C 环境情境(天气/时段)**，其他不考虑（**省训练/后端开发工作量**）。
- **C 环境情境（contract 新增）**：天气{**晴天(默认)** / 雨天}（雨天→雨天关窗宏）+ 时段{白天/夜晚}（夜晚→困了宏/氛围灯）。**时段默认待确认（对齐 SD11 主题默认米白）**。
- **三大块演绎控制 OK**（整车/环境/座舱）。
- **端状态默认值收束「常态运行」卡**（磊哥）：A+B+C 默认值（state-cells `default` 一手：ac off/temp24/fan1/window0/screen70/ambient off/seat0/door locked/volume30/wiper off/sunroof0/fragrance off/speed0/gearP + 晴天/时段）= 常态运行（demo 初始态）→ **收束成一个「常态运行」卡（一键回常态 = DemoReset）**，不逐个控制台设 31 base；B 座舱逐个调在 **10 族卡片界面**（SD7 触摸，人为调）。

**physical landing**：
- `EndStateWhitelist = A(vehicle.speed/gear) + B(10族31base) + C(weather/time_period)`。
- `NormalRunPreset`：默认值集（state-cells `default` 一手）= 常态运行卡 + 一键复位（= SD1 DemoReset）。
- 演绎控制台 3 大块 = A 整车(时速静态/泊车/城市/高速 + 挡位) + C 环境(天气/时段) + B 座舱(常态卡 + 链 10 族卡片调)。

**承接**：state-cells `default`（常态一手）/ demo-scenarios initial_state_default / SD1 DemoReset / SD7 10族触摸调 / SD12 演绎控制台。

---

## SD14 — 演绎控制台布局 = iPhone控制中心式竖排模块卡 + segmented互斥 + 常态卡查看全部33base弹窗（2026-06-25 磊哥 PPT 思路 → 专业 UIUE）

**决策**：
- **布局 = iPhone 控制中心式竖排模块卡**（磊哥 PPT 三列长条思路 → 竖屏改竖排模块卡更专业）：常态运行卡 / 整车运行卡 / 环境情境卡 / 座舱场景卡。
- **常态运行卡**：● 当前常态 + **[查看全部≣]**（点→控制中心式弹窗看 33 base 值，按 10 族分组网格）+ **[⟲ 一键复位常态]**（= SD1 DemoReset）。🔴 **价值确认**：10 族摘要卡只显**主 cell**（看全族 cell 要点 4b 展开 composite，磊哥确认对），常态卡弹窗**一次看全 33 base**。
- **整车运行**：时速 segmented[静态/泊车/城市/高速] + 挡位[P/R/N/D]。
- **环境情境**：天气[晴天默认/雨天] + 时段[**白天默认**/夜晚]，**互斥单选**（segmented 点一个另一灭）。
- **座舱场景**：场景宏库[上车/离车/雨天/困了/+动态扩容] + 设备端态→点 10 族卡片调（SD7）。

**physical landing**：
- `DemoControlPanel`：VStack 模块卡（常态/整车/环境/座舱），iPhone 控制中心式（圆角 + material + segmented）。
- `NormalRunCard`：[查看全部] → `AllStateSheet`（33 base 按 10 族分组网格弹窗）+ [复位]。
- segmented 互斥（选中高亮，iOS picker 风格）；时段默认白天。

**承接**：SD13 三大块/常态卡 / SD1 DemoReset / SD7 10族触摸调 / axiom-design HIG（控制中心范式）。

---

## SD15 — 演绎控制台视觉对齐 10 族卡界面 + iOS26 特效高级感 + 弹窗顺序铺开 + 时段独立主题（2026-06-25 磊哥拍）

**决策**：
- **设计认同**（竖排模块卡 + segmented 互斥 + 常态卡 [查看全部] 弹窗 + [复位]）。
- **🔴 视觉对齐 10 族卡界面 + 一定高级感 + 应用 iOS26 特效**：同视觉体系——米白默认/深空设置（SD11）+ iOS26 glass/material（SD5：控制台=功能层工具页**可 glass**）+ 模块卡质感（柔和阴影/留白/字体层级）+ segmented iOS picker 风格。**不再 too low。**
- **[查看全部] 弹窗 = 33 base 按 10 族分组顺序铺开**（② 认同）。
- **③ 时段独立主题（磊哥选 ②）**：时段=触发宏端状态（白天/夜晚切换触发困了宏/氛围灯演示）/ 主题=系统 light/dark（米白默认跟随系统，SD11）。**两者正交独立**——时段切夜晚不改主题（主题跟随系统/设置）。

**physical landing**：
- `DemoControlPanel` 视觉 = 对齐 ContentView/10族卡（DesignTokens 米白/深空 + iOS26 glass 功能层 + material 模块卡）。
- `AllStateSheet`：33 base 按 10 族分组顺序铺开（ScrollView 分组网格）。
- `time_period` ⊥ `colorScheme`（时段触发宏 / 主题系统驱动，正交独立）。

**承接**：SD5 iOS26 玻璃（功能层 glass）/ SD11 米白主题 / SD14 控制台布局 / axiom-design liquid-glass + typography（高级感）。

---

# 【B 动效块】

## SD16 — orb 四态视觉 + 拟人感（生命感光球+四态情绪）+ 米白/深空适配（2026-06-25 磊哥全认同）

**决策（承接 E1）**：
- **拟人感 = 生命感光球 + 四态情绪表现**（非人脸，座舱 AI 不该有脸；Siri/天猫精灵同路）。
- **四态视觉**：
  - **idle**：静默呼吸（安睡生命）— 青紫慢漂 + breathing spring(1.8/0.7) 0.95↔1.05
  - **listen**：倾听（聚精会神）— 100ms 微亮(E3-D) + 收拢脉冲 + 高光聚焦
  - **think**：沉思（运转）— 中层 think 脉冲光晕 + hanlin 流光文字 + Canvas 粒子内聚漂
  - **speak**：说话（律动吐字）— 脉冲随 TTS 节奏律动 + 高光跳动
- **米白/深空适配**：深空暗底 orb 辉光炫；**米白亮底 orb 用实色渐变球 + 柔和阴影（非辉光）**（呼应 SD11 米白炸场靠饱和色非辉光）。

**physical landing**：
- `OrbState = idle|listen|think|speak`（承接 E8 四态）；各态 MeshGradient 参数 + 动效。
- 深空：辉光 MeshGradient；米白：实色渐变 + shadow（`colorScheme` 适配）。
- breathing/脉冲/流光/粒子（E1 多层 + keyframeAnimator/TimelineView，AD-12 §四）。

**承接**：E1 orb 实现 / E2 think 事件驱动 / E3-D listen 100ms / E8 四态时序 / U30 自建 MeshGradient / SD11 米白适配 / AD-12 §四微交互。

---

## SD17 — 动效块收口（10 问题推荐磊哥全 OK，大部分承接现有决策）（2026-06-25 磊哥 OK）

**决策（动效 10 问题，磊哥 OK 全认同）**：orb-1 长按过渡(进度环→sheet phaseAnimator 上滑) / orb-2 拟人微动作(呼吸+光晕流转+心跳脉冲，不加眼睛) / orb-3 形态(120pt+核心+光晕2层，层数颜色实装spike) / 氛围-4 边缘 Canvas 粒子爆发(ease-out 5s→fade) / wow-5 boot reveal(冷启首次2.5s 卡片stagger+orb唤醒+主题渐入 phaseAnimator) / 微交互-6(numericText+symbolEffect按态+sensoryFeedback仅真机) / 微交互-7 breathe硬化(TimelineView paused sin+生命周期pause) / 错峰-8(sequencer220ms+E8 think→卡片stagger级联) / 玻璃-9 morph(不用Container液态融合，态切换material过渡+mge gated) / 过渡-10 触发聚焦(ZStack overlay opacityScale320ms+mge gated+dim)。

**physical landing**：动效**全承接现有决策**（E1/E2/E8 orb / AD-12§四§五 / D5 聚焦过渡 / D6 wow / SD4 氛围灯 / SD5 玻璃 / 4a/4b/4c 已做）；**新细化仅 orb-1/2 + 氛围-4 + wow-5**（其余已锁）。

**承接**：E1/E2/E8 / AD-12§四§五 / D5/D6 / SD4/SD5 / 4a/4b/4c。

---

## SD18 — 视觉块收口（V1-V12 + D1/D2/D4/D6 + CC1-CC4 + 连续舞台硬约束）（2026-06-25 磊哥「全部同意，全部存档」）

> 视觉块 grill 全收口。承接 tokens.md（视觉 SSOT）/ SD5 玻璃 / SD11 米白 / SD16 orb / SD17 动效 / AD-11 摘要 / AD-12 三屏 / D7 7 态色 / aesthetic-first 5gate。核心诉求 = 治磊哥「太 low」（卡片/空间/字体/层级），final = **iOS26 连续舞台非工程布局**。

### V1-V12 决策（physical landing 见表）

| # | 决策 | physical landing |
|---|---|---|
| **V1 间距** | 8pt 栅格：屏边 20 / zone 间距 24 / 卡片 padding 16 / Grid gap 12 / 顶栏 44 | tokens.md §6 新增 `space.*` |
| **V2 字体层级** | 5 级：zone 标题 13-14 medium / 卡片标题 15 semibold / 主数值 28-34 heavy rounded / 辅助标签 11-12 medium / 对话 15-16 regular | tokens.md §3 扩 `font.zone.title/card.title/value.hero/label.aux/chat` |
| **V3 圆角描边** | 主卡 22 continuous / 小卡 16-18 / mic dock capsule / 描边 0.5pt hairline（深空 inkDim2·.35 / 米白 black·.06）**绝无黑硬框** | tokens.md §7 新增 `radius.*` / `stroke.hairline` |
| **V4 视觉重量** | 数值主导（value.hero）> icon（次·态色）> 标签（弱·inkDim）；态切靠**色+图标+数值**三承载（低电量铁律）| aesthetic gate5 |
| **V5 Glass 容器** | 允许 `GlassEffectContainer` 用于**功能层控件组性能/一致性**，禁整屏液态融合。Container = 性能优化（共享渲染 pass + 防 glass-on-glass nesting），**非新增 glass 面** | SD17 玻璃-9 / U2 |
| **V6 theme model** | ⭐**A 强制色（2 套 token）**：`ivory`默认→`.preferredColorScheme(.light)` / `deepSpace`→`.dark`，设置切 Theme=切强制色，**不跟随系统**（demo 投屏稳）。🔴 **推翻 SD11「light-dark 跟随系统」** | App theme `.preferredColorScheme` + tokens.md theme note |
| **V7 连续舞台** | 见下「连续舞台 + zone 预算」 | 锚点图 + 硬约束 |
| **V8 注意力优先级** | **卡片状态变化 > TTS 文本 > orb > ambient edge**；氛围边缘只 5s 不抢指令。配 sequencer 220ms 错峰（不同时炸）| SD17-8 / SD4 |
| **V9 图标系统** | 全 **SF Symbols**（filled + `.hierarchical` 配态色），反 emoji / 反混自绘。🔴 **10 族→SF Symbol 映射 = 第二 SSOT**（撞 derivation 铁律2）→ 契约存在性（每族必有图标不落 default）；7 态图标 D7 已定 | 新建 `FamilyIconMapper` 穷尽 switch + 契约存在性测试 |
| **V10 可读性验收** | 视觉 hard gate：最小字号 / 中文最长文案（「打开主驾驶座椅加热」级）/ 44pt touch / Reduce Motion / 低电量 / ~~1080p 投屏截图~~ 🔴 **投屏维度 SUPERSEDED**（2026-06-26 磊哥 C0：demo master agent 手持演示**不投屏**，投屏 DELETE；见 `docs/grill-tournament/uiue-visual-gate-harden-grill-decisions.md` C0/U35）。保留非投屏可读性维度 | visual-acceptance gate（米白/深空各跑）|
| **V11 duration ladder** | 4 档：micro 120 / state 220 / panel 320 / ambient 5s + **2 例外**：breathe 3.4s（循环）/ boot 2.5s（一次性）| tokens.md §4 扩 `motion.dur.*` |
| **V12 组件密度** | **Mac 左右分栏**（左 orb+对话 / 右车控 5×2 全景不滚动）≠ **iPhone 竖直三屏**（2 列滚动 + active hero）| 平台分支布局 |

### V7 连续舞台 + zone 预算（去硬横线，信息架构非三块边框）

- **去硬横线**：顶 orb 自然留白 / 对话区透明滚动层（气泡自带 material）/ 车控卡片群自然成块 / mic 底部 floating glass dock。**zone 间靠留白+material+卡片群，禁 divider 黑线**。
- **orb 主角**：96-112pt，**无外框小矩形**，listen 态轻收缩脉冲（不靠文字说状态），「我在听…」做 caption 弱化（11pt inkDim）。
- **对话区空气感**：用户气泡右·浅蓝紫轻填充 / 助手气泡左·白米白 material / **TTS 比 ASR 重**（结果反馈）/ 动态高度设 max（180-220）idle 收避免挤车控。
- **mic dock**：72-80pt floating glass capsule，左状态点 / 中「按住说话」/ 右波形·mic symbol，按住 capsule 扩张发光。
- **氛围 inner glow**：屏边 **8-14pt** 柔和 inner glow（非全屏厚边框），5s 爆发后**淡出**，不常驻不压 active card。
- **zone 高度预算**（iPhone15 ~759pt）：顶栏 44 / orb 110(96-112) / 对话 180-220 动态(idle 收 44) / 车控剩余滚动 / mic 72-80。`44+110+200+80+24×4=530`→车控 ~229 可视滚动。

### D1/D2/D4/D6（磊哥同意）

- **D1 hero 形态** = ⭐**A 守 AD-12**：active 族**原地 1.3x 放大不物理重排** + ScrollViewReader 滚入视野中心（非物理置顶，守 spatial memory，6-lens 调研已否决物理置顶 `openspec/changes/ui-presentation/design.md:111`）。
- **D2 多意图 hero**：多 active **不强选单 hero**，2+ active 都 compact 次级强调（态色+轻放大）sequencer 220ms 依次亮；**hero 大卡形态只单意图触发**。
- **D4 对话背景** = ⭐**透明滚动层 + 气泡自带 material**（最空气感）。
- **D6 滚动边界**：orb 钉顶 + mic dock 钉底（`safeAreaInset`）+ 对话区钉 orb 下（动态高不随车控滚）→ **只车控区内部滚动**（ScrollViewReader）。

### Corner case（「我好累」=E4 困了宏[提神非助眠] 演绎挖出，磊哥全同意）

困了宏 steps：车窗 `window.position`=50% + 空调 `ac.temp_setpoint`-2 + 座椅 `seat.backrest_angle` 直起 + 座椅 `seat.vent_level` 通风；**砍氛围灯（夜间刺眼）+ 砍音乐**。

- **🔴 CC1 — 座椅卡「亮了但主值没变」（AD-11 primary cell 盲区）** = ⭐**A 摘要卡 changing 时主值临时切到「本次变化的 cell」**（座椅显「靠背直起」而非死守 `seat.heat_level`），完成回落 primary。现有 `UIValueTypeMapper:226` 只处理「主 cell 缺失 degraded」，**不处理「主 cell 在但本次变非主 cell」** → 需补。physical landing：`UIValueTypeMapper` 加「changing 时取本次 changed cell 优先于 primaryCell」分支 + 测试。
- **CC1.1 — 一族多 cell 同变显哪个**：显**动作语义最强**的（靠背直起）+ 角标「+1」，完成回落 heat_level。
- **CC2 — 思考态死寂感** = 守 **D8.3 车控不预热**（思考时卡不动避免剧透）+ orb think 焦点 + 对话区 narration 承载存在感。
- **CC3 — 多 active 视线跳** = ScrollViewReader 滚**第一个 active** 入视野 + 3 族**原位错峰**（守 D1 spatial memory 不聚拢）。
- **CC4 — 相对值 temp-2 超界** = clamp 到边界（18℃）+ changing→satisfied，**demo 不暴露「已最低/失败」**，readback 说「已为您降温」不提差值。

### 🔴 连续舞台硬约束（写进 spec ui-presentation + UIUE 实装窗口）

> 不要把主页做成带横线的工程布局。三屏分层是**信息架构，不是三块边框**。final 视觉 = **iOS26 连续舞台**：orb 是情绪焦点 / 对话是上下文 / 车控卡是状态结果 / mic 是底部控制岛。zone 之间靠留白 + material + 卡片群自然成块，**禁任何 divider 黑线**。

**physical landing**：tokens.md §3 扩 + §6 间距 + §7 圆角描边（FROZEN）；theme V6 `.preferredColorScheme`；CC1 `UIValueTypeMapper` changed-cell 优先分支；V9 `FamilyIconMapper` 契约存在性；连续舞台 + 注意力优先级 + zone 预算 → 实装时落 design.md AD-14。

**pre-mortem**：🐯 CC1 主值切换 + V9 图标映射都是「第二 SSOT」（撞 derivation 铁律2）→ 必契约存在性测试（每族 cell/图标不落 default）/ 🐘 深空暗底投屏 halation（米白默认保险 + V10 投屏验收，磊哥飞书血泪）/ 📄 「连续舞台无 divider 会乱」=paper（靠留白 8pt 栅格 + material 层次 + 卡片群分块，HIG 连续舞台标准做法）。

**承接**：tokens.md（视觉 SSOT）/ SD5/SD11/SD16/SD17 / AD-11（CC1 暴露其盲区）/ AD-12（D1 守其调研）/ D7 7 态色 / D8.3（CC2）/ E4 困了宏 / aesthetic-first 5gate / derivation 铁律2（V9/CC1 第二 SSOT）。

---

## SD19 — Corner case 三场景收口（多意图错峰 / R2 安全拒识 / clarify + CC1 升级通用机制）（2026-06-25 磊哥「全部同意，记录存档」）

> 演绎 3 高光场景挖 corner case（视觉显示层边角）。一手对齐：多意图=AD-4/D1 sequencer 220ms / R2=scene5 后备箱`door.tailgate_height`+E8-C 演出 1.0s / clarify=D8.2 少用主线不演。

### 场景 1：多意图「打开空调和座椅加热」（错峰）
座椅加热=`seat.heat_level`=座椅 primary（主 cell 变正常显示）。sequencer 220ms 错峰 MAX_CONCURRENT_HIGHLIGHTS=1 依次「唰唰」。
- **CC-A1 气泡跟句数**：1 句 2 意图=1 用户气泡+2 卡错峰；连续两句=2 气泡+2 卡。
- **CC-A2 TTS 合并**：2 意图 readback 1 句合并（orb speak 1 次）。
- **🔴 CC-A4 部分 deny（E8-D）**：「打开空调和后备箱」（行驶中）→ 空调 satisfied + 后备箱 unsafe 同屏 + 1 句综合 readback。
- **CC-A5 runtime gap（DEFERRED 实装）**：`FastPathIntentEngine` 仍 1 意图（grill-master:173），多意图 NLU 拆意图链路未接，sequencer 编排逻辑已做 → 需后端扩 splitter / force-state 演示（不阻塞视觉 grill）。
- **CC-A6 开空调主 cell**：带默认温度 24（demo-scenarios:90），主 cell 变正常显示。

### 场景 2：R2 安全拒识「行驶中开后备箱」（scene5 climax 必演）
前置 vehicle.speed=30 force；后备箱=`door.tailgate_height`；E8-C think=演出固定 1.0s；refuse_explain「行驶中为了安全暂时不能开门，停稳后我再帮您」。
- **🔴 CC-B1 后备箱 unsafe 显哪（CC1 盲区复现+升级 unsafe）**：被拒 `door.tailgate_height` ≠ door primary `central_lock` → door 卡 unsafe 时主值临时切「被拒 cell」（显「后备箱·行驶中锁定」红+shield）。
- **🔴 CC-B2 行驶态呈现 vs `vehicle.*` not rendered 红线** = ⭐**A 纯话术传达**（refuse readback 说「行驶中」，守红线不 render speed 数字）；客户疑惑感强才补 B 顶栏「行驶中」语境 chip。
- **CC-B3 安全 think 1.0s**：orb think 固定 1.0s（E8-C 演出，区别事件驱动掩盖）+ 可选 narration「让我确认下…」。
- **CC-B4 unsafe 红克制**：safety red 唯一红 + `exclamationmark.shield.fill` + 温和话术（优雅拒识非冷冰冰报错），红色克制不吓客户。

### 场景 3：clarify 澄清
D8.2 clarify 少用主线不演，仅 force-state 展示 `blocked_with_alternative` 琥珀。
- **CC-C1 主线不演**：clarify=智能澄清卖点但 demo 主线不触发（怕打断违 3s），仅方案经理 force-state 演示。
- **🔴 CC-C2 clarify vs clamp/默认边界**：有唯一合理替代→clamp（「空调 5 度」→18℃ satisfied 不问）；有合理默认→默认主驾不 clarify（D8.6）；真无默认才 clarify（demo 几乎不出现）。
- **CC-C3 多轮延续**：琥珀→用户第二轮→changing→satisfied，对话区累积（DialogueState 3 轮）。
- **CC-C4 四态分开**：clarify 琥珀（卖点温和·questionmark）≠ unsafe 红 ≠ unsupported 灰（D7 铁律）。

### 🔴 元洞察：CC1 是 AD-11 摘要模型系统性盲区（3 场景复现）→ 升级通用机制
| 场景 | 涉及 cell | 该族 primary | 盲区 |
|---|---|---|---|
| 困了宏 | `seat.backrest_angle`/`vent_level`（changing）| `seat.heat_level` | 主值没变 |
| 后备箱拒 | `door.tailgate_height`（**unsafe 红**）| `door.central_lock` | 红态无处显 |
| 开空调 | `ac.power`（若不带温度）| `ac.temp_setpoint` | 主值没变 |

⭐ **CC1 升级通用机制**：摘要卡在 **changing/unsafe/任何非 normal 态**时，主值临时切到「**本次涉及的 cell**」（changed 或 refused），完成回落 primary。覆盖 changing（困了/开空调）+ unsafe（后备箱）。

**physical landing**：`UIValueTypeMapper` 加「态非 normal 时 activeCell 优先于 primaryCell」分支 + 契约存在性测试（每族每 cell 可被 surface，撞 derivation 铁律2）；CC-A4 部分 deny 综合 readback；CC-B2 行驶态纯话术（守 `vehicle.*` not rendered 红线）；CC-A5 多意图 runtime DEFERRED 实装。

**承接**：AD-4/D1 sequencer（场景1）/ scene5 risk-policy R2 + E8-C（场景2）/ D8.2 clarify 少用 + D7 四态分开（场景3）/ AD-11 primary cell（CC1 升级）/ SD18 CC1（本 SD 升级为通用机制）/ `vehicle.*` not rendered 红线（CC-B2）。

---

## SD20 — 空调温度制冷蓝/制热红渐变下划线（gptPRO 图灵感，grill 漏点补回）（2026-06-25 磊哥「很喜欢这细节」）

> 磊哥从 gptPRO 图抓的细节：空调 26℃ 数值下有**蓝色渐变线**——制冷蓝/制热红，我们之前 grill 没考虑。一手核实 `ac.mode` enum=**[制冷, 制热, auto]**（state-cells:71-75）→ 有契约源，非凭空。

**决策**：
- **空调温度数值 + 下方渐变下划线（或底纹），颜色由 `ac.mode` 驱动**：制冷 → 蓝（`glow.cyan #00e5ff`/`#1AA6FF` 系）/ 制热 → 红（`#FF4D6D`/暖橙系）/ auto → 蓝红渐变（或中性青）。
- **「一点渐变」**：下划线/数值非纯色，蓝/红向透明渐隐（`LinearGradient` 短渐变），精致感。
- 🔴 **这是 CC1 元洞察的变体**：ac 卡主值显 `temp_setpoint`（primary），但**样式色由 `ac.mode`（非 primary 辅 cell）驱动** = 「主 cell 显值 + 辅 cell 驱动语义色」。渲染需读 mode cell。
- **可能泛化（冷暖语义色，标 spike 验）**：座椅加热=暖红 / 座椅通风=凉蓝 / 类似冷暖动作可共享语义色逻辑（非只空调）。先空调落地，泛化 spike 时定。

**physical landing**：`ValueControlView`/ac 卡 dial 分支加「temp 数值下 `LinearGradient` 渐变下划线，色 = `acModeColor(mode)`」；新建 `SemanticColorMapper`（制冷蓝/制热红/暖凉语义 → 色，契约存在性：每 mode 值有色不落 default，撞 derivation 铁律2）；tokens.md §1 加 `semantic.cool=蓝 / semantic.warm=红`。

**pre-mortem**：🐯 制冷/制热色需读 `ac.mode` cell（渲染依赖辅 cell）→ mode 缺失时 fallback 中性（不报错）/ 🐘 泛化冷暖语义色到座椅可能过度（先空调，泛化 spike 验非现在拍）/ 📄「渐变下划线增负荷」=paper（短渐变轻量，精致非花哨）。

**承接**：CC1 元洞察（辅 cell 驱动主卡样式）/ tokens.md §1 色板（cyan/red）/ D7 7 态色（语义色 ≠ 态色，制冷蓝是值语义非 visualState）/ aesthetic gate5 视觉重量（下划线辅助不抢主数值）。

---

## SD21 — gptPRO 作品图细节吸收 + 3 reconcile 拍板（深读 2 高清图，grill 漏点补全）（2026-06-25 磊哥拍）

> 深度读 gptPRO 2 图（#19 iPhone / #20 Mac），抓「我们没 grill 到」的好细节 + reconcile 撞已定决策的 3 点。作品锚点集基准。

**直接 adopt（gptPRO 好细节，记录 + 折进锚点集 + 实装）**：
1. **Hero 卡 = 大数值 + 下方渐变 range bar + mode label**（「制冷·自动」）：比 circular Gauge 更适 hero（值在 18-32 range 位置一眼可见）。SD20 扩展——hero 用 range bar 非环形仪表。
2. **制冷/制热 mode 图标**：❄️蓝雪花（制冷）/ 红热浪（制热）—— mode 编码 = 图标 + 下划线色双承载。
3. **对话气泡 inline 值染色**：TTS「已为您调到 **26℃**」的值蓝色高亮（非纯文字）。
4. **orb idle/listen 星点微粒子**：补 E1/SD16（之前只 think 态粒子，idle/listen 也加微粒子=生命感）。
5. **compact 卡 chevron `>` 仅多 cell 族**：座椅/车窗/音量有 `>`（可展开），氛围/新风没 —— 展开 affordance 选择性（呼应 CC1 多 cell 族 = 有 `>` 的族可下钻）。
6. **顶栏卡片化**：浅玻璃 card 包 MAformac+刷新+设置。

**🔴 3 reconcile 拍板（撞已定，磊哥拍）**：
7. **次要族 fade 淡显 = 兼容全景常驻**（拍✅）：10 族全常驻 all-visible 不变（守 D1/AD-9）+ 非 active/次要族降 opacity = V8 注意力层级。fade≠移除。physical landing：VehicleCardsGrid 非 active 族淡显（opacity 约 .5，DRAFT 实渲微调定），active 族 full。
8. **米白 hero 小面积描边 glow = refine SD11**（拍✅）：SD11「米白非辉光」约束**精修**——限【大面积辉光底】（halation 风险），**hero/active 卡【小面积描边】cyan glow 不冲突**（图证明好看）。physical landing：tokens.md §8 米白 note 加「hero 小面积描边 glow 例外」。
9. **Mac 左右分栏 = 守 V12**（拍✅）：gptPRO 图是 centered，但守 V12 左右分栏（左 orb+对话 / 右车控 5×2 全景不滚动），不改 centered。

**physical landing**：SD20 hero range bar（非 Gauge）；`SemanticColorMapper` 加 mode 图标（❄️/热浪）；对话气泡 inline 值染色；orb idle 粒子（E1）；compact chevron 选择性（多 cell 族）；顶栏 glass card；VehicleCardsGrid 次要族 opacity 淡显；tokens.md §8 hero 描边 glow 例外。

**承接**：SD18 连续舞台/V4 视觉重量/V8 注意力（fade）/V12 Mac 左右分栏 / SD11 米白（refine hero glow 例外）/ SD20 制冷热（扩 range bar + mode 图标）/ CC1（chevron 多 cell 族）/ E1 orb 粒子。

---

## SD22 — 层级（z-order）+ 滚动 corner case（磊哥点：mic 居前/10 族滑动/对话滑动，AD-12 只部分覆盖）（2026-06-25 磊哥拍）

> 磊哥点出 SD18-21 + AD-12 的 gap：**层级 + 滚动 corner case 没系统 grill**。AD-12 已覆盖「ScrollViewReader 自动滚 active 入视野」+ `:157`「2 列竖屏低排位族滚出视野=头号 spike + 台本约定首屏优先」，但具体 z-order/手动滚冲突/对话历史滚动/双滚动手势没 grill。**几乎全是非 runtime（UIUE presentation 层 visual_only）**，少数触 runtime 信号。

### A. 层级 z-order

- **Z1 mic dock 始终居前 + 车控 scroll 底部 inset**：mic dock z-top（floating 钉底，D6）；🔴 车控 ScrollView 底部加 `contentInset = mic dock 高(72-80) + gap(12)` → **末行卡能滚到 mic dock 上方完整可见**（不被半透明 glass dock 糊住值）。
- **Z2 z-stack 总策略**（由外到内）：① 氛围边缘爆发 overlay（整屏边框，`allowsHitTesting(false)` 不挡交互，A06）② mic dock（钉底 floating）③ orb（钉顶）④ 触发聚焦 dim overlay（4b ZStack）⑤ 对话区 + 车控区滚动内容。明确各层 z 防互相遮挡。

### B. 10 族滑动

- **S1 手动滚 vs 自动 scrollTo(active) 冲突**：🔴 用户**手动滚动中 → 暂停自动 `scrollTo`**（`isUserScrolling` flag）；新 active 触发**且**用户没手动滚 → `scrollTo(active, anchor:.center)`（AD-12）。**系统不抢用户滚**（否则用户翻看时被强行拉走）。
- **S2 hero 放大 + 滚动**：hero（1.3x 原地放大，AD-12 不重排）**跟内容滚**（不钉），靠 ScrollViewReader 滚入视野，承接 AD-12 已决。
- **S3 fade 判据 = 跟 active 不跟屏幕位置**：🔴 SD21 次要族 fade **按「非 active 族」非「靠下位置」**——否则滚动时卡片随位置忽明忽暗（闪烁）。fade = `!isActive ? .opacity(~.5) : full`，与 scroll offset 无关，滚动时明暗稳定。
- **S4 车控 scroll clip 边界**：车控独立 ScrollView，顶部 clip 不露对话内容 / 底部 inset 留 mic dock 空间（Z1）/ overscroll bounce 限车控区内（D6「只车控区内部滚动」）。

### C. 中间对话区滑动

- **C1 看历史 vs 新消息打断**：🔴 用户**在底部 → 新 TTS 自动 `scrollTo(last)`**（SD3）；用户**上滚看历史 → 不强制滚 + 显「新消息 ↓」提示**（IM 范式，升级 SD3 累积）。`触 runtime`：新消息=`readbackReady` event（RPB-21）触发，但「是否强制滚」是 presentation policy。
- **C2 对话区 idle 收 44 藏历史**：idle 收成单行 caption（V7/D6 动态高），**藏历史**；新对话来展开恢复（SD3 累积不丢）。
- **C3 对话区 + 车控区双独立滚动手势**：两个**相邻**（非嵌套）ScrollView（D6 对话钉 orb 下 / 车控区内部滚），手势各自区域（对话区滑只滚对话 / 车控区滑只滚车控），边界 D6 已分。

### runtime / 非 runtime 分类

- **几乎全非 runtime（UIUE presentation 层 visual_only）**：z-order / scroll inset / 手动滚 flag / fade 策略 / 手势区分 / clip = 纯 SwiftUI presentation，UIUE-owned，不需 runtime bridge。
- **少数触 runtime 信号**（但 policy 是 presentation）：① C1 新消息打断 = `readbackReady` event（RPB-21）② S1/S3 active 来自 runtime `activeCell`（RPB-51 已提供数据）。→ **数据靠 bridge（RPB-51 activeCell），滚动/层级 policy 全归 UIUE 视觉**。

**physical landing**：ContentView z-stack 顺序（Z2）；车控 ScrollView `contentInset` 底部留 mic（Z1/S4）；`isUserScrolling` 暂停自动 scrollTo（S1）；fade 判据按 `isActive`（S3）；对话 ScrollView「在底部才 auto-scroll」+ 新消息提示（C1）。**全 UIUE 文件**（ContentView/对话区/车控 Grid），不碰 Core。

**承接**：D6 滚动边界（orb 钉顶/mic 钉底/只车控滚）/ SD3 对话累积 scrollTo(last) / AD-12 ScrollViewReader 自动滚 active + `:157` 滚出视野 spike / D1 hero 放大 / SD21 fade（修正按 active 非位置）/ RPB-51 activeCell（数据源）/ RPB-21 readbackReady（C1 触发）。

---

## SD23 — corner case 第二批：边界态决策（磊哥 7 类）+ 演绎视角新挖（2026-06-25 磊哥拍 7 类 + CC 演绎补）

> 磊哥拍 7 类边界态 + punt 几类给 CC 决策；CC 继续【方案经理现场演绎视角】挖出 9 个新 corner case。

### A. 磊哥 7 类边界态决策（含 CC 替决 punt 项）

| # | 类 | 决策 |
|---|---|---|
| 1 | 键盘/文本打字 | 🔴 **不搞文本打字**（demo 纯语音 push-to-talk）→ **移除 ContentView 的 TextField+执行按钮**，换 mic dock（=G-UI2）。键盘遮挡 corner 不存在。SD2 确认语音 only（D15「文本先行」是 dev 序，demo UI 无文本输入）|
| 2 | 空态/启动态/无网态 | **全按默认**（CC 决）：空态=常态运行默认值（`NormalRunPreset` SD13）/ 启动态=boot reveal→idle 全景（SD6）/ **无网态=纯端侧离线是常态非错误**（宪法离线红线，**不显「无网」警告**）|
| 3 | 横竖屏旋转/Mac resize | CC 决：**iPhone 锁竖屏**（`portrait` lock，demo 竖屏 AD-12，不旋转避布局复杂）/ **Mac resize 自适应**（左右分栏弹性 + min width 保 5×2 不挤）|
| 4 | 超长中文文案截断 | **最多 ~30 字**：卡片标签/readback **单行 max ~30 字 truncate 尾 "…"**；对话气泡**可换行多行**；TTS 语音不受限 |
| 5 | onboarding/麦克风权限 | CC 决：**麦克风首次系统标准弹框授权一次**（U6 entitlement 已配）/ **无自定 onboarding**（磊哥自己 iOS/Mac 用）/ 启动直进主页 idle |
| 6 | 双端 Bonjour 联动 | **先不考虑**（defer，双端各自独立 standalone，AD-5）|
| 7 | Accessibility VoiceOver | CC 决：**DEFERRED**（标占位 RPB-44；demo=方案经理现场视觉+语音演示，非视障场景；双通道铁律 RPB-34 已部分覆盖无障碍精神：色/图标/值承载非纯动画）。真上架/无障碍合规才做 |

### B. 演绎视角新挖 corner case（方案经理现场演示，9 个，🔴 = 需磊哥拍）

> 演绎：方案经理打开 app（幕后已配）→ 按住 mic 说指令 → 客户在旁看。挖边角：

- **C-ASR-fail（🔴 撤销原「没听清」框架，磊哥纠 2026-06-25）**：磊哥纠正——**苹果 ASR 总会出文本**（它就是干这个的），无独立「ASR 没听清」态。真实**二分**：① **按 mic 没说话/纯静音 → ASR empty → orb 回 idle 静默**（自然无反应，不报错）② **ASR 出文本但 intent 不匹配 10 族（族外/含糊）→ unsupported no-match 优雅兜底**（= C-unsupported，blocked_hard 灰锁 +「我没太理解」/「这个我还不支持」）。**不发明「没听清」态**，折叠进「empty 静默 + no-match unsupported」。
- **C-mic-short（按住太短，误触/手滑）**：录音 <阈值（~0.3s）→ **忽略空音频不送**（CC 决）。
- **C-mic-long（录音时长上限）**：一直按着/说太长 → **max ~15s 自动结束 + 处理**（CC 决）。
- **C-rapid（连续快速指令）**：上条还在 changing 动效，下条来 → **U21 PTT 物理打断当前**（barge-in）+ 处理新（已决 U21，确认）。
- **🔴 C-driving-context（演 R2 前行驶语境建立，重审 CC-B2）**：方案经理 force 行驶态后、演 R2 拒识前，**客户怎么知道现在「行驶中」**？CC-B2 倾向纯话术（不显 speed），但**演示场景下客户需先感知行驶语境才理解拒识**。⭐重审：**演 R2 时加顶栏轻「行驶中」语境 chip**（非 speed 数字，是状态语境，守 `vehicle.*` not rendered 红线的「不显数字」但给语境）。**需磊哥拍**（CC-B2 A 纯话术 vs B 语境 chip，演示需要可能倾向 B）。
- **C-reset-transition（复位视觉过渡）**：一键复位常态（SD8）从任意态→常态 → ⭐**渐变 fade 回常态**（非突变，各卡 satisfied/unsafe→normal 柔和过渡 ~320ms）。
- **C-theme-transition（主题切换过渡）**：设置米白↔深空实时切（SD8）→ ⭐**crossfade 过渡**（~320ms，非突变闪）。
- **C-ambient-during-speak（氛围爆发期间说话）**：氛围边缘爆发 5s 期间客户又说话 → ⭐**爆发继续**（visual_only overlay 不打断）+ 新指令并行处理（mic 始终可按）。
- **C-unsupported-out-of-10（族外，万一客户突然说「导航到北京」）**：磊哥人为控场只说 10 族，但万一 → ⭐**blocked_hard 灰锁 + 助手「这个我还不支持哦」**（E6 族外兜底优雅，非翻车；范式「现场只说 10 族 + 族外 unsupported 兜底」）。

**physical landing**：移除 TextField（mic-only）；`UIDevice` portrait lock（iOS）；文案 `.lineLimit(1).truncationMode(.tail)` max 30 字（卡片/readback）；ASR fail→idle+重试气泡；mic 时长阈值（min 0.3s / max 15s）；复位/主题 crossfade 320ms；族外→blocked_hard。**全 UIUE/Core 边界**：ASR fail/mic 时长/族外 unsupported 触 runtime（RPB-06 event/RPB-09 result），呈现归 UIUE。

**承接**：SD2 语音 only / SD13 NormalRunPreset / 宪法离线红线 / AD-12 竖屏 / V10 文案 / U6 权限 / RPB-44 a11y defer / CC-B2 重审（driving context）/ U21 barge-in / E6 族外兜底 / RPB-06 与 RPB-09（ASR fail/族外 = runtime event/result）。

---

## SD24 — context 映射 = 顶部居中玻璃 capsule 持续动效（磊哥设计，解 driving-context + 顶栏重构）（2026-06-25 磊哥拍哲学）

> 磊哥用一个**顶部居中玻璃 capsule（持续动效）**解了 driving-context 的 chip pop-in/out 张力——context（行驶/雨/夜）作**持续 ambient 动画**显示，非弹出 chip。同时重构顶栏。

### 决策（哲学锁定）

- **顶部居中玻璃 capsule = context 映射 surface**：原顶栏白卡**右边界往左、左边界往右收到 ~半宽居中**（非椭圆，是玻璃特效 capsule，**中间放动画**）。
- **持续动效反映当前 context scene**：context（方案经理控制台 force 的 speed/weather/time）→ capsule 持续 ambient 动画。
- **顶栏重构**（🔴 修订 V7）：① 品牌「MAformac」**去掉**（demo 客户面不需品牌）② 设置/刷新 **移右上角 standalone**（不进 capsule）③ 左上空出。
- **为什么好**：解 chip pop-in/out 突兀（持续 ambient）+ 高级感（玻璃+动画）+ 统一 context 显示 + 释放顶栏。

### context 场景（5 基础，提案，③点待磊哥定细节）

| 场景 | 来源 | 持续动效（提案）|
|---|---|---|
| 常态（晴天·白天·静止）| 默认 | 微光呼吸（平静非空白，「一直活着」）|
| 行驶中（城市/高速）| speed>0 | 流动/向前粒子流（速度感）|
| 泊车（gear=P 静止）| speed=0+P | 静止微光（或归常态）|
| 下雨中 | weather=雨天 | 雨滴下落 |
| 夜晚 | time_period=夜晚 | 星点/月色（深蓝紫微光）|

### 讨论点（磊哥 2026-06-25 拍 ⭐ 全认同 + 5 场景 OK）

- **① 组合策略**（雨天行驶/夜晚行驶）= ⭐ B **优先级单显**（行驶>雨>夜>常态，demo 一次演一主 context）。
- **② 视觉层级** = ⭐ capsule = **最低 ambient**（持续背景，slow/subtle/低视觉重量），V8 注意力链「卡片变化 > TTS > orb > **context capsule（最低）**」。
- **③ 常态默认** = ⭐ 微光呼吸（平静常态动效，不空白）。
- **5 场景 OK**（常态/行驶中/泊车/下雨/夜晚）；gear=R 倒车/充电中等端态白名单外 context **不加**（demo 不需要）。

**physical landing**：ContentView 顶部 band 重构——去品牌 + 设置/刷新右上角 standalone + 中间 `ContextCapsule`（glassEffect + 持续动画）；`ContextCapsule` 读 context 状态（vehicle.speed/weather/time_period，RPB-19/RPB-52）→ 切场景动画（优先级单显）；动画 subtle/slow 低视觉重量（不抢 orb/卡片，V8）。**触 runtime**：读 context cells（数据 bridge，RPB-19）；动画呈现归 UIUE visual_only。

**承接**：CC-B2/driving-context（本 SD 解）/ V7 顶栏（修订：去品牌+图标移角+capsule）/ V8 注意力（capsule 最低 ambient）/ SD13 端态白名单（A 整车+C 环境=context 源）/ SD5 玻璃（capsule glassEffect）/ RPB-19 环境 context + RPB-52 force-state（数据源）/ SD16 orb（区分：capsule=context 背景 / orb=思考语音主角）。

---

## SD25 — context capsule = 「活体迷你窗」diorama 定稿（amends SD24，gpt 图仅视觉灵感非权威）（2026-06-25 磊哥拍方向 + 调研）

> SD24 capsule 升级定稿：**不是文字 pill，是会动的分层微缩活体世界**（diorama），表达车辆+环境 context 四维 composite。gptpro 生了 5 张 photoreal 参考图（惊艳），但 **图仅借 diorama 视觉灵感，布局/契约以我们为准**。

### 决策（diorama 定稿）

- **capsule = 活体迷你窗 diorama**：分层（天空/远景/车/路面/天气/玻璃折射）+ 视差景深 + living details（**尾气/头灯光锥/雨刮/玻璃雨珠/轮转**）+ 昼夜连续渐变 + 丝滑 crossfade 转场。**静态也活**（车怠速尾气飘，永不冻帧）。
- **表达 context 四维 composite**：`vehicle{speed,gear}` + `environment{weather,time_period}`，五基础场景（常态/行驶/泊车/下雨/夜晚）可叠加（night⊕driving⊕rain）。
- **极简优雅非卡通**（Apple 天气 app 级 premium，非火柴人）+ **满帧不省电**（磊哥 4 次定满电，`TimelineView(.animation)`，不用 `.periodic` 省电）。
- 🔴 **gpt 图非权威**：5 张 photoreal 图仅视觉灵感；**布局以 SD24 为准**（品牌去 / 刷新设置右上角 standalone 在 capsule 外 / capsule 居中）。**catch gpt D4 雨夜图把图标弄进 capsule 内 = 错，不采纳**。

### 技术 route（🔴 不拍死，A-2 spike 实证 U31）

- **A 视频 loop**（预渲染 2-3s seamless loop，AVPlayer）：最像图 + **GPU 友好**（视频解码≠GPU compute，避 mlx 争用）。
- **C-lite**（native `.glassEffect` 玻璃壳 + Vortex 粒子 + image `.offset` 视差，**砍重折射 layerEffect**）：实时 + 省 GPU + 较像。
- 🔴 **C-full（重玻璃折射 layerEffect）= GPU tiger**：项目 **U30 已定 layerEffect 与 mlx 抢 GPU -50%**（`grill-master:161`），capsule 永动 + 模型推理同跑会争用 → **砍重折射 shader**。
- **必真机 spike 实证（U31 shader 有效性不拍）**：A vs C-lite，量 capsule+模型推理同跑帧率+观感像不像图，一手定 route。

### 卡顿/同步（演绎视角）

- **不是 gif**，是 video loop（mp4）或 procedural（2D/2.5D 实时）。**卡顿解药 = app 启动预加载全部 loop 进内存 + crossfade（0.4s）→ 满电 flagship 零卡顿**（demo 状态少 ~5-6）。
- **sync**：演绎控制台 force（weather/time/speed/gear）→ context cells → **bridge context 四维（A-1 AD-RPB-014）** → capsule reactive crossfade（0.4s 丝滑转场 = premium wow，非卡顿点）。

### adopt 蓝本（调研，github-first 全活跃）

- **twostraws/Vortex**（粒子 雨/雪/尾气/星）/ **twostraws/Inferno**（Metal shaders，项目 U5 已采）/ **conorluddy/LiquidGlassReference**（iOS26 玻璃参考）/ `3dify-ios`+Apple FCRN（平图→2.5D 深度参考）/ (route A) Kling/Runway（图→视频 loop 首尾同帧法）。调研全档 `docs/research/2026-06-25-context-capsule-2.5d-tech/`。

**physical landing**：A-1 `AD-RPB-014` context 四维（已修）；A-2 实装 `ContextCapsule` view（route spike 后定 A/C-lite）；预加载 + crossfade 硬约束；图标在 capsule 外（守 SD24）。

**pre-mortem**：🐯 GPU 争用（U30，重 shader+mlx）→ 砍重折射/route A/spike / 🐯 3dify license（联系作者，学技术不抄码）/ 📄 simulator 不渲 glass specular（真机 demo 不是问题）/ 🐘 平图→深度边缘糊（分层资产 vs 深度图，spike 比）。

**承接**：SD24（capsule 定稿升级）/ A-1 AD-RPB-014（context 四维数据源）/ U30/U31（GPU 约束 + spike 不拍）/ U5 Inferno（adopt）/ V8 ambient / 调研档 2026-06-25-context-capsule-2.5d-tech。
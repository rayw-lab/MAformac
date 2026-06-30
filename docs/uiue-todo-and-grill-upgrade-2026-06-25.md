# UIUE 待办清单 + grill 升级点（2026-06-25，磊哥模拟器实查反馈）

> 磊哥模拟器实查 mainView（10族全景）后给重大产品形态反馈 + 3 厂商审计 findings。
> 格式：**Part 1 = bug 修复（确定，先做）** / **Part 2 = 待决策升级 grill 点（磊哥反馈，每点推荐方案，磊哥拍）**。
> 🔴 参考图 = 真实座舱 Voice Assistant（控件网格 + ASR/TTS 显示区[红框] + Hold to talk 话筒），对标其**交互 + 视觉质感**（MAformac 布局仍是三屏分层「车控在下」，磊哥定）。

---

## Part 1：Bug 修复（codex 异源审 + 3 subagent CC 审计 findings，确定先做）

| # | 级别 | bug | 来源 | 修法 |
|---|---|---|---|---|
| B1 | **P1** | fan 10 段 stepper 拥挤（展开层 130pt 渲 10 窄格，每格 ~10pt，Gate4/5 失守）| C-P1 ∪ A-P2-3 | stepCount>6 降级横条容量（`.accessoryLinearCapacity`）+ 数字主导 |
| B2 | P2 | MultiCallSequencer cancellation 修复无回归测试守护（未来重构可静默回退 try? 吞）| A-P2-1 | 补 `testSurfaceCancellationStopsAppending` |
| B3 | P2 | fan polish 未进 design.md AD-13 phase matrix（只 handoff 提，违 derivation 铁律4）| C-P2-2 | 补 phase matrix 行 |
| B4 | P2 | enum 值数当可控性语义代理脆弱（semantic test `values.count==2?toggle:badge`，未来 2值只读 enum 会错）| A-P2-2 | 注释脆弱性 + defer（contract 加 `control_hint` 字段是重构）|
| B5 | NIT | wiring gate 正则绑死 `familyDisplays` 命名（重命名会误报）| B-NIT | defer（已知 tradeoff） |

> ⚠️ codex 3P1+2P2 已修（5b63ea1，全实跑坐实）；B1-B5 是 post-fix 3 审计员**新增**发现，B1 是真视觉缺陷。

---

## Part 2：待决策升级 grill 点（磊哥实查反馈，每点推荐 + 拍板）

> 🔴 **核心元判断**：当前 4a/4b/4c 只做了三屏分层的**下层（车控）**，**上层 orb + 中层 ASR-TTS + 话筒交互 + iOS26 视觉 + 氛围灯边缘发光**全标了 Phase 5 没做。磊哥要把这些**提前/现在做**——= 把 Phase 5 核心合并进当前轮的重大范围升级。

### G-UI1 三屏分层布局（磊哥「10族要布局在下面，中间层+上面思考态你放哪」）
- **现状**：mainView 平铺（品牌 + 「打开空调」输入框 + 「执行」按钮 + readback 一行 + 10 族 Grid），**无三屏分层**。
- **磊哥要**：上=思考态 orb / 中=ASR文本+TTS显示 / 下=10族车控（三屏分层，磊哥早定 AD-11/lessons #2）。
- **grill 锚**：AD-11 三屏分层 + AD-12 §二（orb 120 / content 440 / mic 80 三 zone）已设计，标 Phase 5。
- **⭐推荐**：**现在实装三屏分层 VStack**（顶 orb 区 / 中 ASR-TTS 对话流 / 底 10族 Grid + 话筒），把 AD-12 §二三 zone 提前到本轮。
- **拍板**：A 现在实装三屏分层 / B 仍 Phase 5。

### G-UI2 话筒 push-to-talk（磊哥「执行按钮 → 话筒🎤，按住说话→iOS ASR转文本→发送」）
- **现状**：TextField「打开空调」+「执行」按钮（我当临时占位标 Phase 5 换 orb）。
- **磊哥要**：底部话筒图标，**按住说话 → iOS SFSpeechRecognizer 转文本 → 松开发送**（push-to-talk），对标参考图「Hold to talk / Tap to speak」。
- **grill 锚**：D13 push-to-talk + barge-in 按钮打断 / U28 系统 SFSpeechRecognizer 主 + U6 麦克风 entitlement / D15 文本先行。
- **⭐推荐**：**底部话筒按钮 push-to-talk**（SFSpeechRecognizer on-device 离线 + 录音中 ASR 文本实时显示中层）。需 U6 麦克风 entitlement。
- **拍板**：A 现在实装话筒+ASR / B 保留文本输入（demo 取巧）/ C 话筒 UI + mock ASR（点击模拟，真 ASR 后续）。

### G-UI3 ASR/TTS 对话显示区（磊哥红框「ASR文本和TTS语音显示」）
- **现状**：中间只 readback 一行（`{key}: {value}`）。
- **磊哥要**：中间显示**识别的话（ASR 文本）+ TTS 回复**，对标参考图红框区。
- **grill 锚**：D8.3 对话流 + AD-8.6 多轮/读回展示。
- **⭐推荐**：**中层对话流**（用户 ASR 文本气泡 + 助手 TTS 回复气泡 + 思考态指示），ScrollView 滚动。
- **拍板**：A 现在做对话流 / B Phase 5。

### G-UI4 iOS26 视觉高级感（磊哥「卡片/空间/按钮/文字/背景太 low，要 iOS26，调研过」）
- **现状**：卡片暗灰底 + 细边框，质感弱、层级平、留白不足（磊哥「没有高级感」）。
- **磊哥要**：iOS26 质感（Liquid Glass）+ 高级空间/层级/留白/字体，对标参考图控件卡。
- **grill 锚**：AD-6 Liquid Glass（control_glass 功能层 `.glassEffect()` iOS26）+ tokens.md 深空辉光 + 6-lens 调研 + D7 7态色。
- **⭐推荐**：① 功能层（话筒/顶栏/orb）用 **iOS26 `.glassEffect()`** ② 卡片质感强化（材质/更强辉光/层级对比/留白/字体 hierarchy）③ 对标参考图控件卡视觉重量。**回 tokens.md + 6-lens 调研野心，实装没做满需补**。
- **拍板**：A 现在视觉强化（含 iOS26 glass）/ B 重新 grill 视觉 SSOT（觉得方向要重审）。

### G-UI5 氛围灯屏幕边缘发光动效（磊哥「整屏边缘发光，vivo 震动边框紫色动效对标」）
- **现状**：氛围灯卡片色块染背景（小圆点 + 卡背 0.20 染色）。
- **磊哥要**：氛围灯激活时**整个屏幕边缘发光**（对标磊哥 vivo 手机震动时边框紫色辉光动效）。
- **grill 锚**：D8.4 氛围灯炸场（只读符），当前实装是卡片色块非边缘 glow。
- **⭐推荐**：**氛围灯激活 → 屏幕边缘 glow 动效**（整屏边框 RadialGradient/inner-glow 用氛围灯色 + 呼吸/脉冲动效），炸场升级，对标 vivo 边框辉光。
- **拍板**：A 现在做边缘 glow / B Phase 5 炸场一起。

### G-UI6 orb 思考态 + 整体动效（磊哥「上面思考态」+「动效有问题」）
- **现状**：无 orb、无 boot reveal、无 wow 动效。
- **磊哥要**：上层思考态 orb（语音球）+ 高级动效。
- **grill 锚**：D8.3 orb think/speak/listen 四态 + D6 wow 4段 + E0-E8 事件驱动联动，标 Phase 5。
- **⭐推荐**：**顶部 orb MeshGradient 四态**（idle/think/speak/listen）+ boot reveal 开机演出 + 微交互动效（sequencer 错峰已有基础）。
- **拍板**：A 现在做 orb+动效 / B Phase 5。

---

## 元判断 + 推荐路径

**根因**：派单 Phase 4 = 车控层（4a/4b/4c），orb/语音/三屏/视觉是 Phase 5。我严格按派单只做车控层，导致磊哥看到「车控层 + 临时占位」的半成品，**布局/交互/视觉都没到产品形态**。磊哥要的是**完整产品形态**（至少三屏分层 + 话筒 + ASR-TTS + iOS26 视觉对）。

**🔴 这是「把 Phase 5 核心（orb/三屏/语音/视觉）提前合并进当前轮」的重大范围升级，需磊哥拍板。**

**推荐路径（待磊哥拍）**：
1. **先修 Part 1 bug**（B1 fan 拥挤等，快，1-2h）。
2. **grill Part 2 G-UI1~6**（三屏分层/话筒/ASR-TTS/iOS26视觉/氛围灯边缘/orb），磊哥逐点拍 A/B/C。
3. 拍后实装（可能是新的大 phase「UIUE 完整产品形态」，对标参考图）。
4. 完整形态出来后再 gptpro 外审（磊哥原要求，但应在视觉/布局升级**后**审，否则审半成品无意义）。

**我的倾向**：G-UI1（三屏分层）+ G-UI2（话筒）+ G-UI3（ASR-TTS）+ G-UI4（iOS26视觉）**现在做**（这是产品形态的骨架，缺了就是半成品）；G-UI5（氛围灯边缘）+ G-UI6（orb+动效）可紧随。但**全部待磊哥拍**，我不自拍。

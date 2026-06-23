# Final List — UIUE 30 决策盲测打分（3 轮 loop-competition）+ 对比 grill 复议清单

> 2026-06-23 loop-competition 盲测（4 reviewers split 视角 × 3 轮 × judge 非多数，15 agents/3.1M tok/43min）。
> 🔴 **盲测真实性已核**：brain 声明"未读 grill"+ transcript 无 Read grill 工具调用 = 真盲；本地核 file:line 12-15/brain + 联网核 URL 8-10/brain（gh 实核 star）；judge 3 轮均 override 非多数。
> 用途：验证 D1-D6 grill 决策经不经得起「假装没 grill 过」的独立从零审视 → 印证 / 复议 / 补 gap。

## 30 决策盲评 ranking（3 轮 judge 均分，C↔D 映射见 candidates-blind.md）

| 档 | 候选 | 均分 | 对应 grill 决策 |
|---|---|---|---|
| **strong 印证（盲评独立高分=grill 经得起从零审）** | C30(23.3) C21(23.2) C2(22.5) C28(22.3) C22(22.2) C26(21.9) C12(21.7) | 21.7-23.3 | D6.稳>炸 / D5.matchedGeometry不用zoom / D1.多意图序列化 / D6.TTS视觉先行 / D5.Grid / D6.shader fallback / D3.原生控件 |
| **solid** | C25(21.1) C5(20.3) C11(20.3) C17(20.2) | 20.2-21.1 | D5.gated upgrade / D1.全景常驻聚焦 / D3.enum+switch / D4.Bonjour transport |
| **keep** | C13(19.8) C14(19.6) C23(19.6) C10(19.5) C8(18.7) C7(18.4) C29(18.2) C6(17.7) | 17.7-19.8 | D3.GPU错峰 / D3.骨架统一 / D5.opacityScale兜底 / D2.折叠+角标 / D2.子device优先级 / D2.展开布局 / D6.断网morph / D2.展开触发 |
| **weak（盲评质疑）** | C18(18.0) C27(17.5) C24(16.7) C15(16.3) C1(15.5) C9(14.8) C16(14.6) C3(12.4) | 12.4-18.0 | D4.iPhone竖屏布局 / D6.wow编排sequencer / D5.时长 / D3.分发实现 / D1.开场 / D2.展开并发 / D4.iPhone内容 / D1.dim族微光 |
| 🔴 **better-exists（盲评判被覆盖）** | C19(10.8) C20(10.2) | 10.2-10.8 | D4.断连降级 / D4.双屏定位 — **=C4 重复** |

## 🔴 对比 grill 复议清单（盲评从零 catch 的 grill 问题，需磊哥拍）

### A. 盲评判「冗余应合并」（grill D4 双屏决策臃肿）
- **C19/C20 better-exists**（10.x，3 视角一致）：双屏在 C4/C16/C17/C19/C20 反复 6 次，C19「断连降级=不存在的问题（自包含）」、C20「不极简」是 C4 同义复述 → **复议：D4 双屏决策合并为 C4(双独立)+C16(竖屏内容)+C17(Bonjour 机制) 三条，删 C19/C20 冗余**。C9(并C2/C7)/C15(并C11) 同理 Non-dup 低。

### B. 🔴 盲评发现 grill 漏的 2 个 gap（30 候选无一承载，但都 HIGH/ELEPHANT）
- **GAP-1 投屏 banding/字号现场环境决策**（3 视角独立点 ELEPHANT）：深空暗底 #0a0b12 + 投影 8bit = banding 高发，本机主屏 1920×1080；30 候选无一把「现场强制有线 HDMI + dither + 字号≥投屏下限」写进炸场 checklist（C30 最近但没点投屏）。**与「看着惊艳」北极星直接冲突 → grill D1-D6 漏了「现场投屏/可读性」单独决策（lens1 F1/F3/F4 重磅一手散在各 Q 没单列）**。
- **GAP-2 7 态 visualState 正面消费决策**：ContentView:122 现把 7 态压绿/灰二值（头号现役债）；C11/C14 提骨架/分发但漏「7 态各怎么正面渲染」正交维度 → **grill 漏了「DemoVisualState 7 态逐态视觉」单独决策**。

### C. 🔴 盲评 catch 的硬风险（grill 锁死/承诺无源）
- **tokens base #0a0b12 halation 锁死风险**（risk 视角 E-2）：近纯黑 + 高饱和 cyan = 散光/光晕，**撞磊哥飞书白皮书「太丑看不清」同根因**；30 候选无一挑战此锁 → **复议：base 上抬 #121212 级软黑 + accent 降饱和（tokens.md 待冻结前改）**。
- **C28 中文 voice 离线哑火炸点**（risk T-A，联网坐实）：AVSpeechSynthesizer 中文非默认语言「may require initial download before offline」；干净客户机 zh-CN voice 没下载 → 断网高潮 C29 演到一半 TTS 哑火 = **双重打脸「断网也能跑」**。→ **必 A2 前坐实 voice 离线就绪 + 录制兜底音频**。
- **C8「线上优先级」无数据源**：state-cells.yaml grep priority/frequency/rank = NONE（12 cell/4 族）→ **demo 改硬编码高频子集（产品约定收窄），别等补 priority 字段（量产砍）**（这正是 grill D2 已标的 family_priority.json prerequisite，盲评独立印证此缺口真实）。
- **C13 GPU「~50%」数字无源** + **C24 320/220ms 魔法数字**：标 ESTIMATE / 进 tokens 单源 + A2 Instruments 实测坐实（claim-vs-reality 第8坑）。
- **C18 759pt iPhone15Pro 专属泛化**（640≠759 不自洽）：safe-area 比例分配，别硬编 759/120/440/80。

### D. 上抛磊哥（事实型口径分歧）
- **C21 matchedGeometry hero vs opacity/scale**（打分一致但藏唯一事实型口径分歧，与 C25 升级门捆绑）：盲评确认 macOS zoom unavailable（C21 选 matchedGeometry 是 Mac 唯一可行解，事实满分），但 hero vs opacity/scale 的最终选择 = D5 promotion_criteria gated（已锁），**这条盲评独立印证 grill D5 的 validation_gate 设计对**。

### E. 盲评建议升格
- **C30 稳>炸**应升「整组横切纪律」非平级候选（risk/facts 一致）；**C13/C30 GPU 错峰**合并（C30 含 thermal watchdog 更完整）。

## 机械验证
- 候选数：30（C1-C30 全覆盖）✅；3 轮 × 4 brain = 12 brain + 3 judge + ledger 全落 ✅
- 盲测真盲核：transcript 无 Read grill 工具调用 ✅

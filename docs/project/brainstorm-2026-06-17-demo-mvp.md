# MAformac Demo MVP 脑暴记录（2026-06-17）

> ⚠️ **HISTORICAL 快照（2026-06-17）—— 文档级联 banner（2026-06-23）**
> 本文是立项早期 Demo MVP 脑暴过程记录历史快照（已收敛进 `define-demo-mvp-contract`，后被 C1/C2 契约 SSOT 重构 supersede）。范式翻案后（generic frame → D-domain 具名工具）+ 口径终拍 562，本文涉及的能力路线 / 口径数字部分已过期。**活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md`。正文保留供溯源，勿据此推进。

> `superpowers:brainstorming` 主持,持续追加。收敛后 → `/opsx:propose define-demo-mvp-contract`(S1 建项契约)。
> 这是脑暴**过程记录**(Q&A + 锁定结论 + 待答),不是最终 spec。

## 0. 背景:MAformac 在 AI 提效 2.0 里的定位

- 磊哥 = 定制化方案系统部方案经理,推 **AI 提效 2.0**(部门级操作系统:Layer1 个体工具提效 ✅ / Layer2 组织流程提效;三主线 产品前置/需求流转/落地标准化;五链路;S0-S4)。
- **MAformac 定位**:方案经理的**销售演示提效利器**(替代"把样车开到客户现场")+ 磊哥 **AI 提效的标杆 MVP / 绩效装逼利器**。
- 对应链路 1-2(客户声音→方案经理→应答)/ S2 方案应答;性质属 **Layer1 个体+销售提效**(非大杂烩三主线核心)。
- **不绑**大杂烩的看板/流程治理;MAformac 是独立工具 + AI 提效活广告。

## 1. 已锁定结论

### Q1 受众与场景 → **A + D**
- **A 车厂 OEM 决策者**:会议室一对几,看"端侧座舱 AI 能力",目标促合作/采购。**设备你掌控、环境可控、可 5 分钟娓娓道来**(非展会快闪)。
- **D 内部 / 个人绩效**:AI 提效装逼,证明"方案经理能用 AI 做出端侧 demo"。
- **对客户话术**:包装成「公司内部 API / 还在研发的端侧产品(未交付)」→ 给客户**新鲜感 + 踏实感**(这家公司有真东西在做)。**不暴露是 mock demo**。
- **扩展**:车控 → 导航 / 音乐 / 其他智能体;mock demo 内部也复用。
- **设计含义**:A 可铺垫叙事、语音可靠性风险低(设备可控);要"看着像真产品",视觉/流畅度权重高。

### Q2 炸场点 → ① 端侧离线为核心立足点,但 ①②③④⑤ 全演
- **① 端侧离线 = 核心差异化立足点**(当场断网还能用,云端方案演不出来)。
- **话术**:demo 实际用 1.7B,对客户说「内部 4B/7B 真正模型也有这能力」(1.7B 证明端侧下限,4B/7B 是产品力锚点)。
- ② 听懂人话(模糊意图)/ ③ 多模指代 / ④ 跨域多意图 / ⑤ 反应快 = **演示都要覆盖**,不是单选。
- **③ 多模指代的演绎方案(关键,磊哥定)**:**不是假摄像头,是 DMS/OMS 座舱感知信号演绎**——
  - DMS(驾驶员监测)/OMS(乘员监测)是真实座舱本就有的配置,framing 成立、不怕戳穿。
  - iOS APP 上用**某种手段注入/模拟 DMS/OMS 信号**(预设乘员配置,如「副驾=红衣女性」)。
  - 磊哥配话术:「这时 DMS 捕捉到副驾红衣女性」→ AI 据此指代消解开窗。
  - **需要:场景案例库**(预设若干乘员/状态/环境场景,演示时切换),作为多模指代 + 端状态的演示弹药。

### Q3 体验模式 → **看你表演(客户纯观众,不上手)**
- 磊哥单人控场演示,**手机不给客户**(你说你点,客户看)。
- **设备**:iPhone 真机(端侧 demo 跑这)+ **Mac 的 iPhone 镜像**投屏给会议室看。
- **可能录屏 iPhone**(用途待定:翻车兜底预录 / 发客户带走 / 素材)。
- **设计含义**:
  - UX 全力压「**状态变化一眼可见 + 视觉冲击 + 旁白节奏**」;**不需要**客户易用性/乱说容错那套。
  - UI 主在 **iPhone 竖屏**设计,镜像到大屏也要清晰(字号/对比/留白)。
  - **录屏 = 翻车兜底**(现场 live 翻车就放预录完美版),纳入 Q6 兜底策略。
- **补充(磊哥)**:客户**也可能上手试**,但你在旁控节奏;某功能没响应/没兜底 → 话术圆场「demo 版,内部还在开发中」。
  - 含义:技术**不必**"客户乱说全容错"(无底洞);**核心演示路径(演练过的话术)must-pass 100% 稳**,边缘情况用话术兜。

### Q4 演示叙事流 → 锁定 5 幕（断网放 ④,痛点开场)
| 幕 | 时间 | 内容 | 秀什么 |
|---|---|---|---|
| ① 钩子 | 0–0.5min | "以前看座舱 AI 得开样车,今天手机里就有"+掏 iPhone 投屏 | 痛点 + 便携冲击 |
| ② 基础 | 0.5–1.5min | "打开空调""车窗开一半",秒回卡片亮 | ⑤ 反应快 + 真能控 |
| ③ 懂人话 | 1.5–2.5min | "我有点冷"→升温+座椅加热;"我头有点疼"→调暗屏+降噪+开窗 | ② 模糊意图 |
| ④ **断网高潮** | 2.5–3.5min | **当场开飞行模式**→"我有点困了"照样懂 | ① 端侧离线(核心一击) |
| ⑤ 场景炫+收尾 | 3.5–5min | "DMS 捕捉到副驾红衣女性→给她开窗"(③);"导航回家、放首歌、空调调低"(④);收尾"研发中端侧产品,内部 4B/7B 更强,后续接导航音乐外卖" | ③④ + 留钩子 |

### UX 层收敛（成功标准 + 兜底)
- **成功标准**:5 幕话术断网全过、状态变化肉眼可见、客户"哇"或追问"能接我们车型吗"(进入合作话题)= 成功。
- **兜底三层**:① 话术("demo 版内部开发中") ② 录屏预录完美版(现场翻车放) ③ 核心路径 must-pass 100% 稳。

### Q7 第一屏视觉范式 → **C 近期 + B 远期**
- **C(近期)**:卡片网格 + 顶部**座舱位置条**(主驾/副驾/后排,多模指代时高亮)+ ASR/回复气泡 + push-to-talk。debug/trace 藏抽屉。
- **B(远期)**:座舱可视化(俯视图/3D)。
- **设计目标:审美碾压 AWS**(见竞品)。

## 竞品:AWS 海外座舱 AI Agent 方案（23 页,2026-06-16,今日来交流)

- **架构**:端云协同(端 Qwen3-0.6B/Gemma4-E2B + 云 Bedrock Nova/Claude),AgentCore+Strands,重(Lambda/DynamoDB/Cognito/IoT Core)。
- **9 Agent**:车控SLM / 音乐(Spotify) / 车书维修(GraphRAG 70%→92%) / GUI(VLM) / GenHMI / 翻译(Code-Switching) / 日历邮件导航 / 多模态识别 / AI迎宾。
- **UI 实情**:座舱**大屏** 3D 渲染漂亮(KANZI;GenHMI/迎宾),但**手机端车控 demo 丑**(Android 灰蓝扁平卡片、字小、无层级)——**磊哥要超的就是这个手机 UI**。
- **四方**:AWS核心 + Alexa Custom Assistant(音乐) + HERE(导航) + 中科创达(系统集成)。

### MAformac 差异化(超过 AWS 的打法)
| 维度 | AWS | MAformac |
|---|---|---|
| 部署 | 端云协同(**断网 fallback 不了**) | **纯端侧离线(断网可演)← 核心一击** |
| 端侧模型 | 0.6B/Gemma4 | 1.7B(话术"内部 4B/7B") |
| 平台 | Android demo 机 + web | **iPhone 原生 + Mac 镜像** |
| 车控 UI | Android 丑卡片 | **iOS 精致 C 范式 + 座舱位置条(碾压)** |
| 架构 | 重(云依赖) | 轻(纯端 mock) |
| 多模指代 | Multi-Modal Agent(PPT+导航大屏) | **DMS/OMS 座舱位置可视化,演出来** |

## 内部端侧战略（话术底气,抽象结论,敏感原文不入仓）

- 公司内部**真有端侧大模型分级 PRD**:2B / 2B Plus / 4B / 7B(星火 + 千问 Qwen),高通多芯片异构上车。
- 能力分级:2B=文本改写/语义规整/多意图;2B Plus=+FC;4B=+落域+FC;7B=全。
- → **MAformac 话术「demo 用 1.7B,内部 4B/7B 更强」有真实产品背书,非纯忽悠**。
- **MAformac 定位**:公司端侧大模型上车战略的**销售演示前哨**(方案经理演示载体 + AI 提效绩效)。

## 提问层次纪律（磊哥定 2026-06-17）

脑暴/设计提问顺序:**用户体验 → 产品设计(含交互 UI/UE)→ 架构 → 技术栈**。先 UX 后技术,问题质量按此层次组织。

## Q8 视觉设计 → A 科技未来感 · 方案1「深空辉光」(暂选,**后续必改**)

- **风格**:A 科技未来感(碾压 AWS 扁平 Android 丑卡片)。
- **暂选方案 1「深空辉光」**:深黑 + 半透明玻璃卡片 + 点亮即青紫辉光呼吸 + 语音气泡打字 + 断网态切换。备选 2 液态极简 / 3 座舱HUD;远期座舱可视化 B。
- **产出**:三方案静态 `prototypes/ui-concepts-3-schemes.html`;方案1 可交互原型 `prototypes/scheme1-deep-space-interactive.html`。
- **磊哥明示(2026-06-17)**:UI 现在定不了、后续必改,雏形就这样,不纠结细节 → UI 脑暴收敛,雏形作 demo UI 层起点,迭代留实现期。

## 3. 脑暴阶段小结(已收敛,可进 propose)

| 层 | 结论 |
|---|---|
| UX | 受众 A车厂决策者 + D个人绩效;看你演(客户可上手你旁控 + 话术兜底);iPhone + Mac镜像 + 录屏兜底;5幕叙事(断网放④,痛点开场);成功=话术全过 + 客户追问合作 |
| 产品/UI | 范式 C(卡片+座舱位置条)近期 / B 远期;方案1深空辉光暂选(后续改);可交互雏形已出 |
| 竞品 | 超 AWS:纯端侧离线(断网可演,AWS fallback 不了)+ iOS精致UI + 1.7B(话术 4B/7B) |
| 内部 | 端侧 2B/4B/7B 真规划 → 话术有底气;MAformac = 端侧战略销售演示前哨 |
| 架构/技术栈 | **已有充分基座**(tech-baseline 7层 + integration-blueprint + 锁定 D1–D37),不必重复脑暴 |

(以上为**已聊清**的部分 —— UX + 单 agent 车控 UI。**脑暴尚未结束**。)

## 4. 待聊清单（脑暴**未结束**,磊哥 2026-06-17 提醒「还多东西没聊」)

> 纪律:按层次推进,一次一个;技术架构/技术栈即便有基座,也**逐项 check 问磊哥确认**,不擅自用基座顶替。

**产品设计层(未完)**:
- [x] **多 agent 窗口架构**(Codex+磊哥定 → CC 辩证 check):
  - **决定**:主窗口 = **MasterShell**(壳),车控只是默认 **pinned** 的 `primary_panel`(不是 shell 本身)。`contracts/agents.yaml` 每 agent 一条:id / display_zh / default_surface / pinned / state_scope。
  - **窗口策略 D+A 混合**:dock(可扩展入口,十几个 agent)+ overlay(音乐条/导航下一步等短任务)。`surface_policy` enum 4 值:`primary_panel`(车控默认)/ `overlay_card`(音乐默认)/ `split_panel`(导航默认)/ `fullscreen`。
  - **CC 辩证 6 catch(待澄清/采纳)**:
    1. ⚠️ agents.yaml vs capabilities.yaml **必须分层**:agent 聚合 capability,agents.yaml 管窗口/surface,capabilities.yaml 管能力/工具,agent 用 id 引用 capability(防双源漂移)。
    2. ⚠️ `state_scope` 语义明确(session/global/persistent)。
    3. ⚠️ 导航 `split_panel` 在 iPhone 竖屏挤 → 建议 `fullscreen`+`overlay_card` 两态,或按设备自适应;split 留 iPad/Mac 大屏。
    4. ⚠️ `fullscreen` 归属未定(导航全程/视频?)或标预留。
    5. ⚠️ iPhone 竖屏空间预算(壳+座舱条+车控6卡+dock+overlay+语音),别挤成 AWS 密集丑。
    6. ✅**修正(磊哥纠正,CC 原判错)**:**LoRA 不缺数据**。MVP scope ASR/TTS/LoRA 都要,内部排序(文本闭环→语音→LoRA),但 LoRA 起步即有真实数据(见下「数据资产」),可更早练。LoRA MVP 聚焦车控域模糊意图,跨域留多 agent 阶段。

## 数据资产（LoRA / eval 三源,磊哥 2026-06-17 纠正 CC「没数据」误判)

| 源 | 是什么 | 喂给 |
|---|---|---|
| **bug-skill-dev 1万+ bug** | 真实座舱语音 badcase(T19CFL/E0V 车型,兜底错/落域错/TTS/语音,带 KI 匹配) | **LoRA 难例 + eval 真实分布(最值钱)** |
| **协议清单说法举例** | 车控打点表/语义四级标准说法变体 | FC 训练 + 规则快路径**正例** |
| **raw wiki/intake + 落域语料** | 说法/场景/垂域举例 + bug-skill knowledge 落域 decomposition | 补充语料 + 模糊说料 |

**辩证(数据多 ≠ 直接喂)**:
1. **清洗**:bug 管理字段(bug_id/title/owner)→ 抽「user query→期望动作」成 LoRA 五件套。
2. **脱敏(硬边界)**:bug 含车型 T19CFL/真实人名/客户 → **绝不入仓/不上云**;本地清洗去敏样本,**训练集本身也不入仓**(仅 LoRA 权重可)。
3. **筛选**:多语种兜底 bug(西/葡/瑞典)vs 中文车控,筛相关。
4. **正负配比**:bug=错例,配协议清单正例。

**数据护城河**:真实座舱 bug → LoRA 真实分布(非造),AWS PPT 未体现有此 → "超 AWS"隐藏王牌。
  - **YAGNI**:MasterShell + surface enum 先定义全,**MVP 只实现 primary_panel(车控)+ dock 占位**,overlay/split/fullscreen 留接口不实现。
  - **✅ 拍板(2026-06-17)**:
    - **catch 1 采纳**:`agents.yaml`(agent/窗口/surface/state_scope)与 `capabilities.yaml`(工具/槽位/mock行为/eval)**分层**;agent 只通过 **capability id 引用**能力,不重复定义内容。
    - **catch 3/4 拍板**:导航 iPhone 竖屏默认 **fullscreen + overlay_card**;**Mac/iPad 才** split_panel。`fullscreen` 是 surface_policy 的一种(非独立窗口系统),先给导航,视频/地图类后续复用。
- **MVP 范围(磊哥定)**:= 车控 + ASR + TTS + LoRA(见 catch 6 内部排序)。
- [ ] 场景案例库交互(切换乘员/环境场景)。

**架构层**:
- [ ] 技术架构逐项 check(7 层 + 多 agent 编排/中枢路由 + 窗口路由)。
- [ ] **项目骨架 / 目录结构**(Swift 工程,尚未确认)。

**技术栈层(逐项问磊哥 check,详见 §5)**:
- [x] **模块 2:语音 ASR/TTS** —— 已拍(§5);中文车控专词待 ultracode 深读热词后定;延迟分路径(快≤800ms / 慢≤2500ms)。
- [ ] 模块 1:模型 / runtime(Qwen3-1.7B / MLX / LLMBackend)—— 基座部分已锁,待逐项 check。
- [ ] 模块 3+:UI 框架 / 状态管理 / mock 存储 / MCP / 数据与 eval —— 待过。

**流程 / 工程层**:
- [ ] OpenSpec 后续持续怎么用(change 节奏 / 谁起 / sync / archive)。
- [ ] Codex 接活方式(change → Codex 长跑的交接)。
- [ ] git / CI / 版本 / 真机签名。

**细节层**:磊哥待补。

---

## 5. 技术栈逐项 check 记录

### 模块 2:语音 ASR / TTS(2026-06-17 拍板,Codex 提议 + CC 辩证 + 磊哥定)

**ASR(WhisperKit 主 / sherpa-onnx 备)**
- **模型尺寸**:首测 `large-v3-v20240930_626MB`(最高中文准确率);`small` 仅性能降级档;`tiny` 仅开发调试。large 延迟过线再降。
- **端点**:push-to-talk(按住说、松开结束;不做 VAD 自动端点)。
- **流式 vs 批式**:批式(松手后整段转,非流式增量)。
- **WhisperKit + sherpa 双保险**:主 WhisperKit;备 sherpa-onnx(SenseVoice/Paraformer)。先跑 **50 条中文车控短句 demo must-pass=100%**;错「三档/外循环/座椅通风/氛围灯」先补归一化,补不住再启 sherpa。
- **中文车控专词(热词增强)**:认,**等 ultracode 第三次深读 raw/下载热词清单后定**(workflow `wf_1f138649-1cb` 进行中);喂 WhisperKit contextualStrings。

**文本归一化(独立层 SpeechTextNormalizer,磊哥定)**
- 位置:ASR 之后、IntentEngine 之前(独立层,非塞进 ASR 或 Intent)。
- 输出字段:`raw_text` / `normalized_text` / `rewrite_rules` / `confidence_delta`;**trace 与 ASR 错分开记**。
- 职责:中文数字/同音字/单位/口语 → 标准说法 rewrite;为 FastPath 命中铺路。
- **confidence 拦截位置**:SpeechTextNormalizer 之后、IntentEngine 之前。**ASR 低置信 → 澄清,不交 LLM**(LLM 会合理化错字);**ASR 高置信但意图模糊 → 正常走 LLM**(CC catch:别用「FastPath 命中才继续」挡住模糊意图)。

**TTS(AVSpeechSynthesizer MVP)**
- MVP 拍 `AVSpeechSynthesizer`;升级线 CosyVoice / sherpa-TTS / TTSKit **不进首版**(TTSKit 0.6B~1GB / 1.7B~2.2GB 包体+内存风险)。
- **拟人度**:MVP 忍 AVSpeech 但调教(中文增强声线 / 语速略慢 / 短句);产品感靠 **UI 状态同步 + readback 准确**承担,不死磕音质。第二优先 **TTSKit**(非 CosyVoice)。
- **可中断**:按钮打断 → TTS `stop` + VoiceController `Interrupted→Recording` + 取消未落地的 LLM generation;**已执行 mock state 不回滚,只重读**。
- **播报内容**:只播「操作对象 + readback 结果」(如「空调已调到 24 度」),不啰嗦。

**🔴 延迟预算分路径(磊哥定 2026-06-17,关键)**

| 路径 | 触发 | 端到端预算 |
|---|---|---|
| **快路径** | 明确指令(「打开车窗」)/ 单 FC 直出(「打开香蕉色氛围灯」FC 直出) | **≤ 800ms** |
| **慢路径** | 模糊意图 / 多意图 / 复杂(「我有点冷」「我头疼」「导航回家放首歌空调调低」) | **≤ 2500ms** |

- **CC catch(待实测分解)**:
  - 快路径 800ms 的**瓶颈在 ASR**:large-v3 批式转一句中文短句(iPhone ANE)是大头,可能吃 600ms+,剩给规则+mock+TTS 首响 <200ms,**紧**。→ 先做延迟预算实测(ASR / 规则 / mock / TTS 首响 分解);large 进不了 800ms 就降 small 或换 sherpa SenseVoice(更快)。
  - 慢路径 2500ms:large-v3 ASR + Qwen3-1.7B 生成 ToolCall(TTFT+几十~上百 token)+ mock + TTS 首响;2500ms 给 LLM 留了空间但也需实测。
  - **sherpa SenseVoice 角色升级**:因快路径 800ms,SenseVoice(中文 ASR 更快)可能反比 large-v3 更适合主线 → 备胎 = 速度 + 准确率双备,延迟预算实测后可能翻盘主选。
  - 慢路径优化手段:**TTS 首字节起播**(边生成边播,「首响」算预算,不等全部完成)。

### 模块 2 拍板补充(2026-06-17,workflow 深读 `voice-pipeline-from-raw.md` + 磊哥硬件论据后)

workflow `wf_1f138649-1cb` 第三次深读 raw/下载,产出 `docs/voice-pipeline-from-raw.md`(341 行,真实座舱数据:ASR 首字 ≤200ms / 整段 ≤500ms、TTS 首响 ≤150ms、混合级联 250ms vs 完全端到端 850ms、热词短词 ≤6 字 / ≤200 条 / 一字反转配最高权重;含中文车控热词表 + 公版协议印证归一化契约 + value 四件套)。文件按"源料最优"对 3 处给了与昨日拍板不同的建议,磊哥拍板:

- **冲突 1 拍板 — ASR 尺寸(硬件论据修正)**:文件建议 small,但 **8155 车规给语音 CPU 才 ~6K DMIPS、量产指标即 800ms;MAformac demo 跑 M5 Mac + iPhone 15 级(A16),算力高几个数量级、绰绰有余,无需为延迟牺牲准确率** → **`large-v3-v20240930` 直接当主选(准确率优先)**,small 退为极端降级预案(取消 large/small 并列实战)。实现期第一个 spike 仍顺手实测 large-v3 在 A16 端到端,把"理论绰绰有余"变实测数字(演示底气 + 绩效量化)。
- **冲突 2 拍板 — 批式 vs 流式(化解,不二选一)**:push-to-talk 交互 + **录音期 WhisperKit 流式预转**(`AudioStreamTranscriber`,说话 1.5–4s 内 ASR 跟转)+ **松手出最终文本**(UX 批式,不给用户看跳动增量)。「批式」= UX 松手才出 ✅,非禁止流式预转;ASR 延迟藏进说话时间,松手后只剩尾音转写(~100–200ms)。
- **冲突 3 拍板 — 砍 VAD 端点**:push-to-talk 松手即端点,MVP **砍 `Endpointing` 态 + 三层 VAD**(那是免唤醒/全时对话二期 barge-in 设计),松手直接进 `Transcribing`(YAGNI)。
- **800ms 计时起点(钉死)**:从「松手(说完)」到「TTS 首响 + UI 亮」,**不含说话时长**。
- **800ms 定位**:**预估非硬指标**,锚定 8155 车规量产指标,后续有优化空间。**话术弹药**:对客户「车规 8155 量产即 800ms,这台 demo 更强算力上更快」→ 可落地踏实感,呼应「内部 4B/7B 更强」叙事。
- **唯一非算力固定开销**:模型预热常驻(large-v3 626MB + Qwen3 968MB,app 启动即 load 进 ANE,别冷启动)。
- **文件待对齐**:`voice-pipeline-from-raw.md` 的 §4.4(small 建议)/ §3(VAD)/ §0·§4(流式口径)加「拍板对齐」段,以本拍板为准(源料原貌保留作参考)。

> **CC 自省**:前面对 large-v3 vs 800ms 的担心**偏保守**——下意识按车规端侧紧约束想,忘了 demo 硬件是 M5+A16 不是 8155。归因错位,入 lessons-learned。

### 模块 3 拍板:UI 框架 + 状态管理 + mock 存储(2026-06-18,5 项 + A + B 总拍)

**核实前置(磊哥要求,CC 实查 + 助理言论交叉验证)**:
- **本机环境**:✅ Apple M5 / Swift 6.3.2 / macOS 26.6 / referencerepo Swift 依赖全 clone(WhisperKit/whisper.cpp/sherpa-onnx/mlx-swift-lm/LocalLLMClient)/ CLI 齐(git/gh/openspec/swift/swiftc/xcrun/brew/python3)。🔴 **完整 Xcode 未装**(只 CLT,`xcodebuild` 不可用)= **S2 实装前置阻塞**(iOS app + SwiftUI + CoreML + Metal + 签名都需 Xcode),要装 ~15GB。🟡 **Apple Developer 签名未配**(`0 valid identities`)= iPhone 真机演示需配($99/年 或免费 ID 签 7 天)。pod 缺但 SPM 不需要,忽略。
- **助理言论**:**全核实通过**——行号准确(CLAUDE:66 / 02-arch:96 / 05-vehicle:11&91 / 07_deep_appendix:199 / brainstorm:121);Alexa Auto SDK + Azure car voice demo 真在 repos(manifest #30/#31);cell schema 7 字段有本地草案(05-vehicle:91)+ `DemoVehicleStateStore` protocol 草案(05:83 snapshot/read/observe/applyMockTransition)。
- **巨人肩膀**:**够**。reports/`07_deep_appendix_to_1000.md` 已提炼 Alexa(capability-agent 拆分 HVAC/Window/Seat/Light/Media)/ Azure(第一屏五卡 UX + 10 条固定演示命令)/ Canals(三抽象)对 UI/状态层借鉴。

**5 项拍板(按 ⭐)**:① **SwiftUI** ② **@Observable 单 store**(落地形态 `@Observable @MainActor final class DemoVehicleStateStore` + `DemoActionExecutor.applyMockTransition()`)③ **纯内存 + 一键 reset** ④ **视觉先于听觉**(卡片亮 ~16–50ms 早于 TTS 首响 ~150ms,动画 ≤200ms)⑤ **store 按 `state_scope` 分层**(MVP 只实例化车控 store,dock 占位)。**不上 TCA / SwiftData**(宪法已锁 SwiftUI 一套无后端 CLAUDE:66 + GitNexus 单一状态源 02-arch:96;Observation iOS17+ 原生 / SwiftData 持久不适合干净开场 / TCA 对 solo demo 重治理)。

**cell schema 定稿(8 字段)**:`key / actualValue / desiredValue? / availability / timestamp / source / revision / visualState`。前 7 有草案(05-vehicle:91);`visualState` 助理新增(三态 UI 不靠自然语言推断)。

**A 拍 — 三态视觉**:`无法满足` 不消失 / 不纯话术 / 不默认红框 → **灰态卡片 + 琥珀角标 + 替代建议高亮**;红色只给 `unsafe`。`visualState` 枚举 = `normal / satisfied / changing / blocked_with_alternative / blocked_hard / unsafe / unknown`。无法满足触发二级推荐,UI 必画替代路径(tech-baseline:257 + 07_deep_appendix:199)。

**B 拍 — MVP UI 范围**:`6 张核心卡 + 座舱位置条 + 语音气泡 + dock 占位不可切`;8 卡留 iPhone 大屏 / Mac;首版别让壳先重过主体验(呼应 brainstorm:121 primary_panel + dock 占位)。

**CC 2 catch(补充理解,不改拍板)**:
1. **Alexa「capability agent 拆分」转译**:07_deep_appendix 的 `HVACAgent/WindowAgent/...` 映射到 MAformac 应是 **capability 拆分(在单个 carControl agent 下),不是 agent 拆分**。MasterShell 的 agent 是 **domain 级**(车控/导航/音乐),功能级是 capability;别带偏成「开 5 个巨型 agent」(违 lessons §B8/B9)。
2. **visualState 派生、不另立事实源**:`visualState`(UI 7 枚举)由 `ThreeStateEngine`(语义三态)+ 执行进度**派生**,非独立写入源。链路:`applyMockTransition` 改 `actualValue/availability` → 派生 `visualState` → SwiftUI 渲染。

**前置行动项(S2 实装前必须)**:① 装完整 Xcode(~15GB)② 配 Apple Developer(真机演示)。

### 模块 1 补充:runtime 首轮验证顺序(2026-06-18 拍板,采纳 Codex 案 + CC 三步精化)

Qwen3-1.7B 经 `LLMBackend` 协议跑端侧,主实现 `mlx-swift-lm`。工具调用验证按**三步解耦**(每步只引入一个新变量),不直接 Swift spike:

| 步 | 环境 | 验证什么 | 要权重 | 要 Xcode |
|---|---|---|---|---|
| **0** | Swift/Python 单测 | 我们的 decode/parser 逻辑(喂构造的 `<tool_call>` 样本)→ `ToolCallFrame` | ❌ | ❌ |
| **1** | Python `mlx_lm.server` | **Qwen3 真实输出格式** + tools schema 契约(模型实际吐什么) | ✅ Qwen3 968MB | ❌ |
| **2** | Swift `mlx-swift-lm` | 端侧集成 + parser 版本敏感 + 性能 | ✅ | ✅ |

- **措辞铁律(磊哥纠偏 2026-06-18)**:模型输出端 = **顺 Qwen3 原生工具调用格式**(模型自然吐 `<tool_call>` XML,只是碰巧与外部生态兼容,**非 MAformac 主概念**)→ 解析 → 映射内部 `ToolCallFrame`。**`ToolCallFrame` + `capabilities.yaml` 才是项目标准**,不把外部格式名当主线。
- **⭐ 时序优化**:Step 1 不需要 Xcode → **与 Xcode 下载并行**(Xcode 下 10GB 时,Python 下 Qwen3 968MB 跑 server 验格式,零等待);Xcode 装完正好进 Step 2。
- **mlx_lm.server 主 / llama-server 对照**:mlx_lm 与最终 Swift `mlx-swift-lm` 同源 MLX,格式最贴最终态;llama-server(GGUF)留 grammar 对照(MLX 无 GBNF,`decode_failed` 高时评估)。**llama 只对照、不写默认**(不降级,lessons B13)。
- **🔴 catch**:server 验的是**模型输出格式契约**(跨实现一致,可复用 Swift);**parser 行为 Python/Swift 可能不同**(`mlx-swift-lm` parser 版本敏感),Step 2 Swift parser 仍要单独同集回归,别以为 Python 过了 Swift 免验。
- 执行前置:Step 1 要 `pip install mlx-lm`(Codex 的 .venv 现只有调研依赖)。

**Step 1 实证(2026-06-18 已跑,CC bash,mlx-community/Qwen3-1.7B-4bit)**:
- `enable_thinking=False` → **干净直出** `<tool_call>\n{"name":"set_ac_temperature","arguments":{"celsius":26}}\n</tool_call>` → 印证 ToolCallDecoder 解析 `<tool_call>` XML → ToolCallFrame(execution-contract 有实证打底)。
- `enable_thinking=True` → 一大段**英文**推理 + 啰嗦纠结 + max_tokens 截断没吐 tool_call → **确认 demo 控制路径 `enable_thinking=false`**(进 execution-contract 输入)。
- 给的 tool_schema 只含 `set_ac_temperature`(只温度)时,Qwen3 纠结「打开空调怎么 open」→ **印证 capability `cabin.ac` 须含「开关 + 温度 + 升降温」**(tool_schema 完整性是 decode 成功前提)。
- 推理本身秒级;模型下载走 hf-mirror **必须 unset http_proxy**(proxy 会 reset HF 连接,实证踩坑)。

### change 拆法确认(2026-06-18)

6-change 拆法 + 命名(`define-*-contract` 体系,弃 Codex 的 `runtime-contract` 大杂烩)已锁,见 `lessons-learned.md §E`(磊哥落档):`1 demo-mvp-contract → 2 capability-contract →（3 execution-contract、4 voice-contract 并行)→（5 lora-pipeline、6 vehicle-tool-bench 依赖 2）`。依赖序非串行 gate;**2 必先于 5/6**(LoRA 数据 + eval 都依赖 capability 定义)。

### 模块 4 拍板:MCP(二期预留,2026-06-18)

- **MVP 不接真 MCP、不引入 Swift MCP SDK**(`modelcontextprotocol__swift-sdk` 二期再加)。
- **Capability 本地/MCP 同构**:同一 `Capability` 协议;本地 handle 走 mock、MCP handle 走 client(二期)。
- **MCP 永不绕过** `CapabilityRegistry → DemoGuard → executor`(MCP 非信任源)。
- **二期 agent(导航/音乐/外卖)预留**:`agents.yaml` 写占位条目 `connector: mock` + **`enabled: false` / `availability: planned`**;Phase1 dock 显示 coming soon、**不可点、不进真实路由**。
- **🔴 catch(磊哥)**:`connector: mock` **≠ 假 MCP**,只是占位 connector;**文案/演示不得说「已支持 MCP」**,状态字段明示 `enabled:false`/`availability:planned`,防契约与演示误导。
- **分层**:`agents.yaml`(展示/surface/默认入口/connector 类型)vs `capabilities.yaml`(工具/槽位/mock 行为/eval);agent 只引用 capability id,不重复 schema(防双源漂移)。

### 模块 5 拍板:架构层 7 层链路 + 项目骨架(2026-06-18)

blueprint(§5/§7)7 层 + 骨架为基座,对齐今天拍板:

| 层 | 对齐后 |
|---|---|
| L0 | **VoiceController**(push-to-talk 端点;**VAD/KWS 接口预留、Phase2 接入** —— 非降级,接口先行)|
| L1 理解 | WhisperKit + **SpeechTextNormalizer**(独立层)+ IntentEngine |
| L2 路由 | **Router**(落 agent+capability+surface)+ **MasterShell** + **ToolCallDecoder**(Qwen3 XML→ToolCallFrame)|
| L3 规划 | ThreeStateEngine(纯函数)+ ActionPlanner |
| L4 安全 | **DemoGuard**(代码门 R0-R3)|
| L5 执行 | **DemoActionExecutor** + **DemoVehicleStateStore**(@Observable 单源 8 字段)+ readback |
| 贯穿 | DialogueState + **TraceLogger 五段** |

- **命名统一**:`DemoGuard`(弃 SafetyGate)、`Demo*` 前缀(DemoVehicleStateStore / DemoActionExecutor 一套)。
- **Router ⊥ MasterShell**:Router 产**决策**(落 agent+capability+surface_policy)、MasterShell 只**渲染**(primary_panel/overlay/dock)。
- **VAD 措辞(磊哥纠偏)**:不叫「砍」,叫「**Phase1 push-to-talk,VAD/KWS 接口预留、Phase2 接入**」(非降级,呼应 B13 + runtime 抽象先行铁律)。
- **骨架目录**:按 6-change 子系统切(Capability=2 / Execution=3 / Voice=4 / dev-train=5 / dev-eval=6),change ↔ 目录一一对应(详见 blueprint §7 更新版)。

→ 全部聊清后,才 `/opsx:propose define-demo-mvp-contract`。**不提前收敛。**

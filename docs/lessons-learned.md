# MAformac 经验教训 & 坑点(持续维护)

> 磊哥 2026-06-17 要求单独维护。每遇坑 / 纠错 / 好做法 → 追加。**CC / Codex 新 session 起手读**。
> 配套全局 memory(CC 跨 session 元认知)。

## A. 协作 / 工作方式教训(CC 自省,磊哥多次纠正)

1. **别抢跑收敛**:CC 反复"还没脑暴就要 PRD""还没 PRD 就要 capabilities""擅自宣布脑暴结束" —— 磊哥三次纠正。→ **脑暴/讨论按磊哥节奏逐项聊透,不替磊哥宣布"结束/可下一步";待聊清单显式维护,不偷偷删。**
2. **别替磊哥预设「没有」**:CC 断言"LoRA 没数据",实际磊哥有 **1 万+ 真实座舱 bug + 协议说法**。→ **任何"没有/不缺/够了/搞不定"判断前,先搜实**(本机资源盘点 + GitHub-first),别凭假设。
3. **提问层次(磊哥定)**:用户体验 → 产品设计(含 UI/UE)→ 架构 → 技术栈。**先 UX 后技术**,别上来问功能/技术。
4. **技术栈即便有基座,也逐项 check 问磊哥**,不擅自用基座顶替;深聊要带**代码链路 + 数据链路**。
5. **辩证 check 跨 agent 结论(Codex/GPT Pro)是双向**:认可主体 + catch 问题,不盲从也不全盘否。
6. **UI 不死磕细节**:雏形够用即往前(磊哥:UI 后续必改);但**信息架构**(主窗口/多 agent 容器)要聊清,那不是细节。

## B. 技术坑点(MAformac)

1. **MLX Swift 无 GBNF grammar**:结构化输出靠 prompt+few-shot + `ToolCallFormat` 解析 + Codable 严格解码 + retry≤1 + `decode_failed` 转澄清,**不是 token 级硬约束**。
2. **Qwen3 工具调用格式不是项目协作协议**:`Hermes` 只指外部生态里常见的 `<tool_call>` XML 输出兼容点,不是 Codex/Claude 分工协议,也不是 MAformac 的内部标准。项目内部标准仍是 `ToolCallFrame` + `capabilities.yaml`;模型输出端先顺 Qwen3 原生工具调用格式(`ToolCallFormat.xmlFunction`)降低 `decode_failed`,解析后再映射到内部 `ToolCallFrame`。**别强制模型直接吐自定义 JSON**(违训练分布、增 decode_failed)。
3. **bug 数据脱敏(硬边界)**:含真实车型代号 / 真实人名 / 客户名 → **绝不入仓、不上云**;本地清洗去敏样本,**训练集本身也不入仓**(仅 LoRA 权重可)。
4. **capabilities.yaml / agents.yaml 必须分层**:capabilities 管工具/槽位/mock行为/eval;agents 管 domain/connector/surface_policy/权限边界;**agent 只引用 capability id,不重复定义**(防双源漂移)。
5. **导航 surface 按设备**:iPhone 竖屏 `fullscreen + overlay_card`;Mac/iPad 才 `split_panel`。`fullscreen` 是 surface_policy 一种,非独立窗口系统。
6. **Registry 是依赖,不是链路串行节点**:CapabilityRegistry/AgentRegistry 由 Router **启动时加载、运行时查询**,不是每请求过的节点。
7. **TraceLogger 贯穿五段**(decode / plan / guard / execute / readback),不只尾部记。
8. **MVP YAGNI**:高德 MCP / 音乐 agent 只在 agents.yaml **预留条目**(connector:mock),Phase1 不实现真 connector。
9. **音乐 agent 不绑单一 API**:只做 `music` domain + `MusicConnector` 适配层,任何音乐 API 接成 connector;**第一刀别做 SpotifyAgent**。
10. **高德能力不直接暴露 LLM**:内部只暴露稳定 4 工具(search_poi / plan_route / start_navigation_link / get_weather)→ 统一 `NavResult`;API key 走 `secret_ref` 不入仓。
11. **端侧延迟评估先锚定目标硬件,别拿车规约束套 demo 硬件**(2026-06-17 CC 自省):评估 ASR/LLM 端到端延迟先问「实际跑哪台机」。MAformac demo = M5 Mac + iPhone 15 级(A16),算力远超车规 8155(分给语音 CPU ~6K DMIPS)。CC 一度按车规紧约束算 large-v3 延迟、差点建议降 small——**归因错位**(下意识套了错的 baseline)。8155 量产 800ms 反而是话术弹药(对客户=可落地);demo 硬件绰绰有余 → **large-v3 放心当主选,不为 800ms 牺牲准确率**。**通用化:任何性能/资源评估先确认 baseline 硬件/环境,别张冠李戴。**
12. **从领域资料推目标库 API 时必须核源码,别按「同款机制」假设字段名**(2026-06-18 Codex cross-vendor catch):我派的 workflow agent 读某车厂热词资料,按「同款机制」假设 WhisperKit 有 `DecodingOptions.contextualStrings`——实际源码**无此字段**,真实 API 是 `promptTokens + usePrefillPrompt`(Whisper initial_prompt 机制)。**语义对、字段名错**。Codex 读 WhisperKit 源码 catch 出,CC grep 实证(`TextDecoder.swift:198`)。→ 通用:agent 读资料得出「用库 X 的字段 Y」类断言时,**必 grep 目标库源码验证字段存在**。**cross-vendor 互补范式:一方读资料(语义/约束),一方读源码(API 实证),双签才稳**——本次 workflow(资料)× Codex(源码)正是此范式。
13. **后续建议默认不降级**(2026-06-18 磊哥纠正):Xcode 已经在下,开发路径按完整主线推进:Qwen3-1.7B + LoRA、WhisperKit ASR、TTS、安全门控、mock readback 都保留。`0.6B`、Foundation Models、llama.cpp 只能作为轻量备选 / baseline / 对照实验,不能把它们写成默认方案;除非真机实测证明 1.7B 跑不动,否则不要为了省事提前降级。
14. **Qwen3-1.7B 端侧工程:「能 tool call」是表层信号**(2026-06-18 Codex 调研 + Step1 实证,**详见 `docs/qwen3-engineering-notes.md`**):格式对只过最外层,真骨头在 4 隐藏层——restraint(该忍住时忍住)/ parser hygiene(malformed / think_leak / 多轮历史炸模板皆常态)/ context budget(标称 32K ≠ 能用)/ LoRA 样本边界(约束行为非补知识)。横切硬约束:`enable_thinking=false`(thinking **破坏** tool parser,非偏好)、禁 ReAct stopword、schema 完整(否则模型纠结「打开空调怎么 open」)、Release 真机验(Python server 不替代 Swift)。落 change 3-6 的硬约束见 qwen3-notes §6。
15. **DemoGuard 是 schema 门,不是语义拒识门**(2026-06-19 self-audit catch):DemoGuard 读 `capabilities.yaml.demo_guard`(risk_level/writable/range/enum/互斥/前置),挡 unknown tool/越界/缺字段/非法 enum/不可写——**挡不住 schema 合法的 restraint**(「不要开空调」→`set_cabin_ac{power:off}` 合法)**和意图越界**(写诗→误触发合法 `set_cabin_fan{level:2}`)。demo_guard **无 restraint allowlist 字段**,做不到语义拒识。→ **真防线分层**:restraint/意图越界拒识 = intent-routing 拒识层 + LoRA 负样本 + base 模型(**非 DemoGuard**);DemoGuard 只保 schema/range/risk 安全 + 不崩 + 读回真态。**content-fallback 把裸 JSON restraint 负例(raw 未触发)变候选→过 schema 门→执行,有已知 G3 代价(1/15→3/15)**,设可配置开关,净影响留 change6 量化。修正了 change3 design E1a「fallback 过 guard 不恶化 G3」的原论证。

## C. Codex 好做法(CC 学习)

- **引实测文件行号**(可追溯,不背记忆)—— CC 应学(断言带证据)。
- 结构化拍板 + 主动 catch 命名漂移。
- 精确化(Registry/Trace 位置、`ToolCallFormat` 实测、HF 模型 968MB 实证),但要避免把外部格式名误写成项目主概念。
- 并行产出 GitNexus repo 索引(`docs/repo-intelligence/2026-06-17-gitnexus/`)—— CC 需核实纳入,不盲信。

## D. 落地结构(本轮拍板,代码骨架锚点)

- 三核心结构:`ToolCallFrame` + `AgentDescriptor` + `SurfacePolicy`,**不开巨型 Agent**。
- 第一刀从 `contracts/capabilities.yaml` + `contracts/agents.yaml` **立源**(仓内还没有)。
- LLMBackend 接口:`load(modelRef)` / `generateToolPlan(messages, tools)` / `streamText` / `cancel`;LlamaBackend 只预留协议位。

## E. 本轮 grill GitNexus 产出的修正(2026-06-17)

### 🔴 catch 1:系统性弱化 ASR/TTS/LoRA(误导源传播,元问题)
某早期文件(`integration-blueprint §8` 等)把 ASR/TTS/LoRA 标"第一刀不接/后置",下游 Codex/GitNexus change 拆法**继承**了它(6 change 缺 LoRA、voice change 叫 `boundaries`),最后误成"MVP 不做"——**磊哥一天连抓两次**。
→ **钉死:MVP = 车控 + ASR + TTS + LoRA(全做)**;任何文件再写"不做/后置 ASR/LoRA"算 **bug**;**引用单行结论必带范围上下文**(第一刀 spike ≠ MVP)。这是"误导源传播",根因在源头措辞 + 下游孤立引用。

### 🟡 catch 2:capabilities.yaml schema 三处草案 → 必须三合一
`GitNexus 03-openspec-input` / `Codex 03-capabilities-catalog` / `tech-baseline §4.1` 三处 schema draft 字段不一致 → 在 `define-capability-contract` change **三合一定稿一份权威**,其余标"历史草案"。

### 修订后 OpenSpec change 拆法(2026-06-18 收敛为 6 个)
1. `define-demo-mvp-contract` — demo 成功标准/non-goals/边界;**MVP=车控+ASR+TTS+LoRA**
2. `define-capability-contract` — 三处 schema 三合一 + 8 条样板;vss_path 可选(MVP 不强制)
3. `define-execution-contract` — `ToolCallFrame` + Qwen3 工具调用 XML 解析 + `DemoGuard` 代码门 + mock state + readback + trace;这条执行链紧耦合,合一比拆成 toolcall/guard 更稳。
4. `define-voice-contract` — WhisperKit ASR + `SpeechTextNormalizer` + TTS + 语音态机,非仅"边界"(catch 1 修正命名)
5. `define-lora-pipeline` — bug 数据清洗脱敏 → 五件套 → MLX-LM LoRA(车控域模糊意图)
6. `define-vehicle-tool-bench` — eval:**demo must-pass=100%** + 泛化≥85 双维度;Unsafe=0 / readback mismatch=0 死门(catch 4)

## F. 座舱语音原理调研轮(2026-06-18,多路 scout+oracle+magnet 语料)

> 起因:magnet 问「functioncall 在哪步做」,CC 凭 MAformac 现有二分设计答,magnet 用真实座舱语料点醒是三层。触发 raw scout + 联网 oracle + pre-mortem。**完整存档 `docs/cockpit-voice-fc-premortem-2026-06-18.md`**。

1. **🔴 别用项目现有设计当世界全貌(二分盲点)**:CC 凭 MAformac「规则快路径+LLM慢路径」二分答架构问题,真实座舱是**三层**(规则NLU / FC快思考泛化 / 慢思考),中间 FC 泛化层(G3 开放词→枚举 + G4 读端状态参数规划,「大海颜色→氛围灯」NLU做不了但仍快路径)被漏掉。→ **回答领域架构问题前先 raw+联网核「真实领域怎么做」,别拿项目当前设计当完整图景**(呼应 A2「别替磊哥预设没有」)。

2. **🟡 demo 项目调研量产资料必划「借鉴/豁免」线**(magnet 重申「这是 demo 不接真车」):pre-mortem 调研座舱**量产**标准(ISO26262/误吸≤5%/端云/QPS/二次确认安全责任),不划线会盲搬量产复杂度。→ 见量产复杂度先问「demo 5 分钟炸场需要吗」,否→豁免;但**安全门思想/参数规划/读回mock态/工具约束/LoRA 不省**。划线表见存档(呼应 fresheveryday 轻治理)。

3. **座舱三层 + 参数规划核心原理**:「感受/开放词→参数不是固定映射,而是读端状态生成增量」`a*={(f,v)|v≠current(f)∧model_supported(f)∧safe(f,v,env)}`=去重门/能力门/安全门。MAformac mock 端状态(UI卡片亮暗)正好是状态源。→ 新起 change `define-intent-routing` 管三层;change3 保持纯 execution。路线 6→7 change。

4. **base 1.7B「能调」是 happy path,触发率/格式/拒识才是真门**(oracle联网):BFCL Qwen3-1.7B overall **55.49%**/multi-turn **16.88%**;微调小模型碾压通用大(xLAM-3b-fc 65.74%、in-vehicle Phi-3 1.8B+LoRA 0.86>规则0.75)→ **LoRA 必做不是可选**。spike E3 加硬gate(触发率/格式塞content/拒识负样本/延迟/G3参数规划mini-spike),不只验「收到.toolCall事件」(呼应 B14 happy-path 表层信号)。

5. **方法命中:多路调研(scout 本机raw + oracle 联网 + magnet 语料)三方互证**找盲点比单路强。oracle 仅 claude subagent+WebSearch(未派Codex/GPT Pro)够用;scout 派 claude subagent 读 raw(read-heavy)抽象 + 守边界(真实车厂全脱敏「某车厂」)。

6. **cross-agent grill 工作流 + self-audit 对抗(2026-06-19 实证,高价值 SOP)**:复杂设计 explore = CC 出 grill 问题(自包含 + 候选 + CC 倾向 + 反问)→ 磊哥贴另一窗口(Codex 系)answer → CC **辩证吸收**(不迎合,raw/项目文件核引用 file:line,找 catch)→ 记 explore 笔记 → 逐轮收敛(判定/横切/端状态/边界 4 轮)→ pre-mortem(oracle 联网扫 grill 没覆盖的新坑,本次 9 坑超 4 轮 grill)→ present design 逐节 approve → propose 4 artifact。实证 `define-intent-routing`。**self-audit 对抗有价值**:CC subagent 审 CC 主线程交付,catch 出主线程「explore 标了 propose 却漏的」(change6 二分漂移)——同 model family 也值(独立上下文 + 对抗视角,codex-metacognition §16/§22 实证)。配套:propose artifact 须回流 explore 笔记里登记的「待对齐漂移」,否则 self-audit 会 catch fake-green 遗漏。

## G. apply 阶段 dispatch self-audit 对抗实证(2026-06-19,change3)

> 起因:apply change3 = CC 写派 Codex 的实装 dispatch;磊哥定「写完 dispatch 后派 subagent CC 审计」。延续 §F6 self-audit,但落在 **apply/dispatch 阶段**(非 explore/propose),catch 实装级盲点。

1. **dispatch self-audit 真有价值(本轮 6 catch 全成立)**:CC subagent 对抗审 CC 主线程刚写的 dispatch,catch 主线程「以为写清了」实则漏的——T7 命名漂移**只修一处**(漏 `DemoActionExecutor`+`FastPathIntentEngine` 两处,会 build 绿但执行链断)/ codegen 触发机制黑洞(撞 `Package.swift` exclude + 不动 Package 红线)/ T5 fixture「禁自造」与「数组归一」物理矛盾(实采 0 数组)/ frame 必填字段无 fixture 来源 / 最危险负例 N002 被一锅烩。**同 model family 也值**(独立上下文 + 对抗 prompt「找漏洞不迎合」)。

2. **🔴 辩证吸收要挖更深,不盲从 subagent(本轮最高价值)**:subagent 说「N002/N016/N017 靠 DemoGuard restraint 挡」——CC 主线程**不盲信,核 `capabilities.yaml` 实证 demo_guard 根本无 restraint 字段**,挖到比 subagent 更深的 catch:**DemoGuard schema 门 ≠ 语义拒识门**(见 B15)。→ **self-audit 双层**:① subagent 找主线程盲点 ② 主线程辩证核 subagent(核它引用、挖它 catch 里的 catch)。两层都做才到位(呼应 A5「辩证 check 跨 agent 结论双向」)。

3. **pre-mortem scout 直读源码在 apply 阶段 catch 实装坑**:scout 直读 pin 的 mlx-swift-lm 3.31.3 → catch「`JSONToolCallParser.swift` 文件不存在」(execution-pre-mortem 锚点失效,实际并入 `ToolCallFormat.swift`)+「`.json` format 是 tagged,裸 JSON 漏成 `.chunk` 的确切根因」+ change1/change2 命名漂移。→ **propose 时的源码锚点,apply 前必按 pin 版本复核**(库版本/文件结构会变,锚点会失效)。

4. **范围解耦(E1b)= apply 阶段 pre-mortem 的结构性产出**:oracle 实证「MLX 在 iOS Simulator 必崩 + metallib 打包 + 内存 entitlement 全未验」→ change3 拆成「纯逻辑契约层(spike fixture 驱动,`swift test` 可跑)」+「MLX runtime 接入(先最小真机冒烟)」。**契约层与 backend 解耦**(自定义 JSONValue 不 import 上游)让单测不被 backend 平台坑传染,呼应 D「runtime 抽象先行」。

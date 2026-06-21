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
3. **bug 数据脱敏(硬边界)**:含车型 T19CFL / 真实人名 / 客户 → **绝不入仓、不上云**;本地清洗去敏样本,**训练集本身也不入仓**(仅 LoRA 权重可)。
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
15. **MLX LoRA 训练的 `enable_thinking` 不能只靠推理侧经验迁移**(2026-06-21 C5 apply):stock `mlx-lm` 训练路径的 full render 和 prompt offset render 不是同一个调用形态;训练侧没有可靠的 `enable_thinking=false` 注入点时,仅看 render diff 会漏掉 loss mask offset 过冲。→ **训练数据要用 assistant `\n\n` 前缀对齐 span,并加真实 offset fixture: trained span 必须等于 ToolCall,不能只看最终字符串像不像。**
16. **OpenSpec live spec 是代码前置依赖,不是事后补文档**(2026-06-21 C5 apply):`dev_selection` 这种新 split 若撞 live data-gate bucket 契约,先改 spec + validator whitelist/non-train overlap 语义,再生成数据。→ **新增数据分桶/评估集合时,先过 `openspec validate --all --strict`,否则训练数据可能在代码里可跑、在契约里非法。**
17. **MLX config 要按真实解析 schema 验证,注释式 schedule 等于没 schedule**(2026-06-21 C5 apply):r9 600-step smoke 日志显示 LR 一直 `2e-4`;原因不是 deterministic protocol 天然不可学,而是旧 config schedule 未被 MLX 消费。r10 改成 `lr_schedule: {name: cosine_decay, arguments:..., warmup:...}` 后 3-step preflight 打印 `8.333e-06`。→ **每个训练超参必须从训练日志反证生效,不能只看 YAML 里写了。**
18. **T-PASS / V-PASS 分开说,别把训练健康误报成模型质量**(2026-06-21 C5 apply):600-step smoke 可证明链路能训、无 NaN/OOM,但 val loss 不升不等于 C6 提升,更不等于端侧候选。→ **LoRA closeout 必分三层:train health、C6 Mac model-quality V-PASS、真机 endpoint candidate V-PASS;缺 C6 diff/fingerprint/fuse parity/真机任一项就只报 blocked。**
19. **Receipt 字段要让机器独立审计,不要靠人翻 side artifact**(2026-06-21 C5 apply):`diagnostic_verdict`、`in_dist/heldout/ood=null`、`masking_stage_counts` 这类字段若只存在于计算属性或样本 JSONL,审计会变成人脑推断。→ **任何 closeout 口径都必须在 machine-readable receipt 里有汇总字段,Markdown 只是渲染。**
20. **loss 发散先拆「可学性」和「优化器/学习率」两层**(2026-06-21 C5 apply):1455 smoke 在 LR 爬到 `1e-4` 前后 train loss 到 `1.069`,说明 deterministic protocol 串本身可学;同轮到 `2e-4` 后 iter70 暴涨,根因更像峰值 LR/正则/裁剪组合,不是数据不可学。→ **不要把后段 spike 误判成协议不可学;先降峰值 LR 到 `1e-4`,保留 cosine+warmup,必要时再 `5e-5`。**
21. **没有训练循环注入点就不能虚报梯度裁剪已实现**(2026-06-21 C5 apply):当前 Swift `C5TrainingCLI` 只是 prepare/receipt/命令生成,正式训练由 stock `mlx_lm.lora` 接管;若 stock trainer 无 `grad_clip` 参数且不改 Python trainer,Swift 侧无法真正 `clip_grad_norm`。→ **receipt 要明写 `gradient_clip_status=blocked_stock_mlx_lm_lora_has_no_grad_clip_hook`;后续若 fork trainer 再把 total_norm/finite check 纳入 metrics。**
22. **训练标签不能留下槽位占位符,固定槽位也不能靠泛化 fallback**(2026-06-21 C5 apply):旧 smoke 数据里有 `\"position\":\"<position>\"`,这是直接教模型输出占位符;进一步看 contract,部分 `slot_keys` 的固定值只在 `ds_protocol.semantic.slots` 中,不在 `range`。→ **user query 与 assistant ToolCall 必须共享具体槽值:优先固定语义槽位,再用 range,最后才 fallback;任何 assistant JSON `\"x\":\"<...>\"` 都应阻断。**
23. **训练 receipt 必带 environment 和 training_curve,否则复跑不可归因**(2026-06-21 C5 apply):只写数据摘要无法解释同一配方在不同 mlx-lm/transformers/硬件/seed/commit 下的差异,也无法判断 checkpoint selection 是否独立。→ **receipt 至少记录 seed、mlx/mlx-lm/transformers 版本、硬件、dtype、base/repo commit、metrics/log 指针和 best-checkpoint policy。**
24. **“stock CLI 无参数”不等于“训练侧不可加安全逻辑”**(2026-06-21 C5 apply):梯度裁剪在 stock `mlx_lm.lora` 参数面无 hook,但 `mlx_lm.tuner.trainer.train()` 的 `mx.compile` step 闭包里有 `do_update` 分支,可 copy/adapt train 主体并复用 stock `default_loss/iterate_batches/build_schedule`,在 grad accumulation 后、`optimizer.update` 前插 finite check + `clip_grad_norm`。→ **结论要分层:stock CLI 只能如实标 blocked;repo-owned training loop 必须实现 clip、grad_norm_preclip、非有限停训/5e-5 fallback,并用同 seed clip-disabled parity 守住与 stock 行为一致。**
25. **fuse parity 不能只看绝对 IrrelAcc 达标**(2026-06-21 C5 apply):如果 dynamic adapter `IrrelAcc=0.95`,fused/quantized 掉到 `0.91`,仍高于 `0.90` 绝对阈值,但已经是 4pp 行为回退。→ **candidate gate 必须同时看绝对阈值和 dynamic-vs-fused/quantized 对称 delta,与 ToolCallExact delta、negative false-call delta、must-pass regression 并列。**
26. **训练侧 tokenizer patch 不代表端侧 no-think parity 已解决**(2026-06-21 C5 apply):训练 `chat_template.jinja` 改默认 `enable_thinking=false` 只覆盖 MLX 训练渲染;mlx-swift 若没加载同一 patched tokenizer 或没显式走 `enable_thinking=false`,空 `<think>\n\n</think>` 字节可能在端侧重现并造成 prompt/offset 漂移。→ **deployment pipe smoke 必须 dump 训练渲染字节与端侧渲染字节逐字节比,并记录 `patched_tokenizer` 或 `explicit_enable_thinking_false`;缺 dump 或不一致即端侧 candidate BLOCKER。**
27. **训练门禁 flag 不能替代同路径 artifact**(2026-06-21 C5 remediation PR1):`usesTrainingTokenizerPatch=true` 曾经只是压掉 `mlx_apply_chat_template_offset_fixture_not_embedded`,导致 `offset_fixture.status=pass` 没有任何 token 级证据。真实修法是让 flag 只声明路径,通过 pinned `mlx-lm ChatDataset.process` 同路径 Python artifact 证明 action span 从 `<tool_call>` 开始、refusal span 从 `NO_TOOL` 开始,且不含 user/system/think token。→ **任何训练 readiness gate 的 `pass` 必须带机器可复验 artifact path+digest;smoke 可以豁免 hard failure,但不能把缺 artifact 写成 pass。**
28. **自然中文生成不能跳过异源语义 judge**(2026-06-21 C5 remediation PR3):云 generator 小批能把协议串改成口语,但也会把 `airflowDirection=吹面` 漂成「风往上吹」、把 `direction=主驾` 擅自扩成「主驾开内循环」。这类错误 grep 不出来,人工看也容易因中文自然度放松。→ **PR3 数据只允许异源 judge pass 后入 train artifact;被 judge 拒绝的样本必须重生成再判,不能手工改词或把自然中文外观当语义一致。**
29. **Hermes 批量调用要按并行长尾系统看,不能按短超时误判**(2026-06-21 C5 remediation PR3):GLM/Ark 批量 judge 会出现 240s 级长尾,但长尾不等于失败;同一批 missing 用 1500s timeout + 多路并行可补齐。→ **Hermes 生成/判别要同时用多源并行、长 timeout、missing 与 reject 分层重试;missing 先补跑,语义 reject 才重生成,最终 verdict 必须区分「慢请求恢复」和「语义不一致」。**
30. **candidate_parent_semantic_id 必须可碰撞,不能按样本流水号 mint**(2026-06-21 C5 remediation PR3 子审):字段接线全对仍可能假绿;若 generated artifact 用 row+variant+generator/sampleID 生成唯一 parent,overlap gate 永远难以碰撞,receipt 的 parent overlap=0 就变成弱证据。→ **builder 必须基于最终 user utterance + assistant ToolCall signature 本地重算 candidate semantic key;外部 artifact 的 candidate parent 只能作输入痕迹,不能作为 gate authority。**

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

> ⚠️ **已转 v2(2026-06-19 全量重构)**:本 6-change 拆法被 `define-c1c2-contract`(C1+C2 契约 SSOT)推翻,旧 change 物理 park(`openspec/changes/_parked/`)。以 `CLAUDE.md §9` + `openspec/config.yaml` v2 + `docs/adr/0001-*` 为准;本段保留作历史。

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

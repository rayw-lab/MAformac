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
31. **stock CLI 日志不能满足训练循环等价性门禁的 `grad_norm` 证据**(2026-06-22 C5 PR2):PR2 要求 repo-loop clip-off 与 stock loop 比较 loss + grad_norm,但 stock `mlx_lm.lora` 只打印 loss/LR/throughput,不输出 update 级 `grad_norm_preclip`。若只拿 stock CLI 日志比 loss,会把不可比较的证据写成 parity。→ **等价性验证要先造 `stock_update_inside_compile` 语义的 metrics lane:保留 stock 的 compiled-step optimizer update/state 形态,额外记录 grad_norm;再与 repo update-outside-compile lane 同 seed 同数据对账。**
32. **optimizer_update 事件缺 loss 会让“每 update 对账”退化成旁路推断**(2026-06-22 C5 PR2 子审):2a 独立审计发现 canonical metrics 只在 `train_report`/`val` 记录 loss,而 update 事件只记 grad/clip/LR。clip 证明仍成立,但 equivalence gate 若要求 loss+grad_norm per update,缺 loss 会让审计被迫跨事件拼接。→ **optimizer_update 事件必须直接记录本 optimizer update 覆盖的 grad-accum mean loss,并标明 `loss_kind`,避免 receipt shape 与 gate 语言错位。**
33. **训练脚本 hash 不能替代脚本快照,尤其在同一 wave 内继续改 loop**(2026-06-22 C5 PR2 子审):2a artifact 记录旧 `c5_mlx_train_loop.py` sha,但随后为 2b 增加 stock-semantics instrumentation,当前工作树 hash 已变;没有当时脚本 snapshot 时,复核只能靠 hash+日志推断。→ **每个 gate run 都要把当前训练脚本快照复制进 run 目录,metrics 首条写 `run_metadata.training_loop_source_sha256/source_snapshot`;hash 漂移必须按 run 分开记。**
34. **同一个 `learning_rate` 字段可能因 update 时点不同而不可直接跨 loop 比**(2026-06-22 C5 PR2):stock-semantics lane 在 compiled step 内完成 `optimizer.update` 后写 metrics,repo lane 在 compiled step 外 update 前先写 `optimizer_update` metrics,导致 `optimizer_update.learning_rate` 看起来错一拍,但 `train_report.learning_rate` 和 loss/grad 轨迹完全一致。→ **parity gate 只比较同语义字段(loss/grad_norm/val/adapter hash);LR 要么比较 post-update `train_report`,要么以后拆成 `learning_rate_before_update/after_update`,别把观测时点差异误判成训练语义差异。**
35. **patched tokenizer 目录不能再作为 tokenizer patch 的输入基底**(2026-06-22 C5 PR2):`C5TrainingCLI prepare` 的职责是从原始 Qwen tokenizer snapshot 生成 patched tokenizer;若把已经 patched 的 `prepare-final-v3/qwen3-1_7b-training-tokenizer-patched` 再传给 `--base-model-dir`,CLI 会找不到旧 `enable_thinking is defined` 条件并正确失败。→ **prepare 的 `--base-model-dir` 用原始 HF/MLX snapshot;训练命令里的 `--model` 才指向 prepare 输出的 patched tokenizer目录。不要把“训练输入模型目录”和“prepare patch 源目录”混为一谈。**
36. **verification marker 也必须进版本控制,否则 `verified` 只是工作树状态**(2026-06-22 C5 PR2 子审):source-state gate 已能比对 marker 与当前训练脚本 sha,但若 `c5_mlx_train_loop.py` 和 `c5_mlx_train_loop.verification.json` 仍是 untracked,新 checkout 无法复现 `verified` 状态。→ **最终 closeout/commit 前必须把训练 loop 源和 marker 一起纳入 git;审计时同时看 runtime gate 和 git durability,不能只看当前磁盘文件。**
37. **blocked prepare 可能已经写出 command/artifact,授权必须看 receipt status 和 exit code**(2026-06-22 C5 PR2 子审):`C5TrainingCLI prepare` 在 receipt/config/train-command 写完后才因 blocked receipt `exit(65)`;因此一个被 blocked 的目录也可能有 `mlx-train-command.txt`。→ **下游自动化不得把命令文件存在当训练授权;formal training 只认 `c5-training-receipt.json.status` 非 blocked 且 CLI exit code 为 0。**
38. **truth-table closeout 通过不等于 OpenSpec archive-ready**(2026-06-22 C5 PR4 子审):4a 审计确认 34 项 truth table、3.1 smoke-only 和 6.x/7.4 PR5 deferred 口径都成立,但 `openspec instructions apply` 仍是 28/34、remaining=6;若 closeout 顶部写 `READY_FOR_TASK_MIGRATION_AND_ARCHIVE`,容易把“可迁移”误读成“可归档”。证据: `Reports/c5-pr2pr4pr5-20260621T235213/audits/codex-audit-pr4-4a-closeout-truth-table-r1.md:4`。→ **archive-ready 只能在 tombstone 写入后由 `remaining=0` + validate 实跑证明;closeout 状态要把 migration-ready 和 archive-pending 分开。**
39. **审计报告落盘不等于审计链可追溯,INDEX 也要同步**(2026-06-22 C5 PR4 子审):4b subagent 已写 `codex-audit-pr4-4b-task-tombstones-r1.md` 且 verdict 通过,但它受写权限限制没有更新 `Reports/.../audits/INDEX.md`,导致主索引短暂漏报一轮审计。证据: `Reports/c5-pr2pr4pr5-20260621T235213/audits/codex-audit-pr4-4b-task-tombstones-r1.md:4`。→ **每轮 subagent 审计回来后,主执行必须立刻补 INDEX 行并写明 finding 是否已修,否则“持续审计循环”只是散落文件。**
40. **OpenSpec archive 生成的新 main spec 可能带 `Purpose TBD`,validate 绿也不代表交付干净**(2026-06-22 C5 PR4 archive):`openspec archive define-lora-training --yes` 成功创建 `openspec/specs/lora-training/spec.md`,但 CLI 默认 Purpose 是 `TBD - created by archiving...`;strict validate 仍通过,容易把占位符带进权威 spec。证据: `Reports/c5-pr2pr4pr5-20260621T235213/audits/codex-audit-pr4-4d-archive-r1.md:15`。→ **archive 后必须人工读 main spec 前言,补掉占位 Purpose,再 rerun `openspec validate --all --strict`;validate 只保格式不保文档质量。**
41. **Swift receipt render 里 `map(String.init)` 可能因重载歧义编译失败**(2026-06-22 C5 PR5 5b):`scale_deferred_ab` Markdown 渲染用 `deferredABScales.map(String.init).joined(separator:)` 时,Swift 在 `joined` 的 Sequence/String 重载之间歧义,focused test 编译直接失败。→ **receipt/CLI render 中把数值转字符串用显式闭包 `map { String($0) }`,不要把可读的渲染代码写成依赖推断的脆弱表达式。**
42. **高唯一率不等于无歧义标签,同一句自然中文可能撞到不同 ToolCall**(2026-06-22 C5 PR5 5b):PR5 formal prepare 的 `candidate_unique_utterance_ratio=0.9569`、variant cap 也 pass,但仍有 40 组同 user + 同 prompt context 映射到不同 `expected_tool_call_signature`,receipt 正确 blocked 为 `ambiguous_duplicate`。→ **数据质量 gate 必须同时有 diversity 和 ambiguous duplicate 两条;清洗时宁可派生 clean pack 移除冲突记录,不要手工改 utterance 或把异源 judge 结果套到改写文本上。**
43. **OpenSpec archive 后 receipt authority 不能继续指向旧 active change 路径**(2026-06-22 C5 PR5 5b 子审):5b 训练健康证据过了,但 subagent 发现 prepare receipt 的 `source_refs` 仍写 `openspec/changes/define-lora-training/...`;archive 后该路径不再是 active authority,会让 candidate 追溯指向不存在/错误的合同源。→ **archive 后要把 receipt authority 升级为机器字段:active main spec path+digest、archive change path+archived spec digest;缺任一项 formal training hard-fail,不能只在 Markdown closeout 解释。**
44. **authority gate 只测 happy path 仍然弱,审计会抓负例缺口**(2026-06-22 C5 PR5 5b r2):r2 认可 archived authority 修复,但指出测试只覆盖 canonical pass 和旧 source ref 移除,没有模拟 active/archive authority 缺失。代码虽 fail closed,回归风险仍高。→ **每个 hard gate 至少要有一个 direct evaluator 负例测试,哪怕 builder 集成测试已覆盖 happy path;P3 也尽量当场补掉。**
45. **MLX Python LoRA adapter_config 的 `num_layers=-1` 不能直接喂给 MLX Swift LoRAContainer**(2026-06-22 C5 PR5 5c):Python 训练里 `-1` 表示全层,但 MLX Swift `LoRAContainer.load(into:)` 直接 `suffix(configuration.numLayers)`,负数会 SIGTRAP: `Can't take a suffix of negative length from a collection`。→ **跨 runtime 加载 adapter 时要做只读 normalization:保留原 adapter weights,在 eval 输出目录生成 normalized adapter_config,把 `-1` 改成目标模型 `loraLayers.count`,并在 envelope/receipt 记录 normalization。**
46. **记录 limitation 不等于完成 task checkbox**(2026-06-22 C5 PR5 5c 子审):5c receipt 诚实写了 `near_neighbor_status=exact_input_no_overlap_only_not_semantic_near_neighbor_proof`,但 tasks 3.3 一度被勾选成完成;subagent 判定这会把“已记录不足”误写成“已完成 near-neighbor proof”。→ **task 勾选必须对应 hard requirement 完成,不是对应 receipt 中出现了字段;若字段本身写 blocked/limitation,checkbox 应保持 open 或拆 task。**
47. **跨 runtime adapter normalization 的 replay 指纹要落到 byte identity,不能只写 status/path**(2026-06-22 C5 PR5 5c 子审):LoRA 能加载且 receipt 写了 `status=normalized`,但缺 normalized `adapter_config.json` digest、original config digest、weights symlink target/digest 和 build invocation,无法独立复核实际加载的是哪份 bytes。→ **任何 eval-time artifact rewrite/symlink 都要记录 original+effective path、sha256、symlink target、build/invocation digest;否则 replay receipt 只够叙述,不够审计。**
48. **GPT Pro bridge 的 `response complete` 可能只是接单句,终审完成必须看页面 stop 状态**(2026-06-22 C5 PR5 final audit):`chatgpt_send_and_get_response` 先返回一句“我会先核验…”,`chatgpt_wait_response` 也报 complete,但 CDP DOM 仍显示 `Pro 思考中`/`停止回答`;若此时补发 prompt 会污染同一终审。→ **GPT Pro 终审/长审计必须用页面状态核验:stop button 消失且正文出现完整 verdict 后再落盘;模型选择器失败也要写入 audit metadata,不能伪称已切到指定模型。**
49. **LoRA loss 健康不等于 tool-call axis 健康,checkpoint 必须实跑 C6**(2026-06-22 C5 θ-α):generated-positive rank16 训练 `val_loss 4.424→0.655→0.589→0.598`,runtime/optimizer 全健康,但 C6 action axis 仍全失败:`iter100=0/23` 且误触发 `set_cabin_ac`, `iter400/600=0/23` 且 positive trigger 归零。根因只记录为待 grill 假设:曲线支持 training-dynamics collapse(θ-α 零 negative 可能学成沉默/安全),channel/extractor confounder 被 base/tiny/iter100 tool events + iter400/600 raw dump 大体排除,但 `tool_call_frame` 训练 target vs D-domain SpikeE3 tools 的 surface mismatch 仍是未拍竞争假设。→ **C5 closeout 必须把 train-health 和 model-quality 分开;val 最优 checkpoint 也要 SpikeE3 + `C6BenchCLI summarize` + `action_hard_pass_recompute.py` 复算,不能用 loss 或 IrrelAcc 单项替代 tool-call 质量门;下一步合 θ-β/加监督/改配方/重训/调 η scope 只能 grill 拍。**
50. **cite-verify 纪律从 rule 声称层下沉 hook enforce 层 + action hard_pass 必从 `gate_result` 一手字段复算**(2026-06-22 harness enforce 落地,派单 `raw/.../harness-enforce-impl-lessons.md`):0/34 灾难根因(派生表征当一手 + 凭印象数字)靠 always-on rule 自觉一直被 catch(含 max effort)→ build **enforce 层** 三机械门。① **cite-verify hook**(Stop 扫 response + PostToolUse 扫写进 docs/contracts 的数字)做 **value-in-source**:读源行/JSON 字段校验 value 真在(非只"行存在"——`11/30` 引含 `10/23` 的同一有效行被 catch);🔴 JSON 数字 source 是【字段】非行号(`c6-summary.json#IrrelAcc` / `:eval_runs[].gate_result`),claim-extract 必识别 jq 字段 source 否则结构性误伤(磊哥实战 catch)。② **recompute fail-closed**(receipt command 固定白名单重跑 + hash 比对,挡 `echo pass`)+ **异源 grader**(hermes 非同 Claude 家族=循环失守;prose-only 无结构化判决 = UNSIGNED,别让 echo-pass 弱点挪到 grader)。③ **cross-section-check**(基线文档组段间一致,EN3 只检存档态跳过 SUPERSEDED 行)。🔴 **action hard_pass 复算口径(锚 base 10/23)**:scope `C6-MP` → JOIN `c6-bench-cases.jsonl` → schema 字段三分类(**顺序敏感**:refusal 先排 `expect_no_call=True` → noop=`delta 应用到 pre 无变化` → positive)→ `tool_call_set_match && state_delta_match` = **10/23**;noop 双计坑(noop 必先排 refusal)+ 别用 `pre≠delta` 当 positive 判据(pre 全态 vs delta 子集 key 永不等)。→ **enforce 治 mechanical 不治 correctness(值在源但口径错 = 异源+人);enforce 降低对自觉依赖非替代扳机;全局 hook 必 kill switch(`HARNESS_ENFORCE_DISABLED`)+ 备份 settings + sample stdin 测 + fail-closed 静默 exit0;Stop 喂回用 top-level `decision:block` 非 additionalContext + `stop_hook_active` 守护防 loop。实装 `~/.claude/scripts/{lib,hooks,cli}` + MAformac `scripts/{action_hard_pass_recompute,axis_schema,surface_consistency,verify_gold,scorer_single,cross_section_check}.py` + `make verify-hooks`/`make verify-cross-section`;异源审计 4 轮收敛(3×P1+2×P2 全修)。**

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

> ⚠️ 2026-06-19~22 大量教训(范式翻案/C5 0/34/562 口径/A2/UIUE)在专题档:`docs/c5-recovery-2026-06-22/grill-decisions-amend-*.md` + `~/.claude/rules/claim-vs-reality-gap.md`(10 变体)。本段(G)聚焦 2026-06-23 文档级联长跑 + loopaudit + workflow 编排。

## G. 文档级联长跑 + loopaudit + workflow 编排教训(2026-06-23,范式翻案后全量文档级联 + ultracode 实战)

1. **🔴 多 workflow 并发狂派 = 混乱源(文档级联不适合无人值守狂派)**:一天连续派 w2/wzul/wih/wt8 + 竞品 redefine 多个大 workflow → 多半成品产物叠加 + 竞品 change 冲突 + 临时空目录 + Reports 2.8G 差点入仓。文档级联**判断密集(D1-37/SRD 三层)+ agree-before-build(change)+ 强依赖顺序**,无人值守 workflow 越派越乱。→ **判断密集/强依赖/需对齐的任务,主线程亲核手工 or 单 workflow 串行低并发,别狂派并发**(CC 早期独立判断「spec/级联该人主导」是对的,被狂派冲动盖过)。

2. **🔴 loopaudit 收敛结构定律(megarun STOPPED@4 实证,已沉淀 loopaudit skill)**:循环审计**不收敛**(每轮新 P1/同批反复报)根因**不是 bug 变多**,是 **修复范围 < 审计范围 或 执行不完整**。收敛铁律:**修复范围 ⊇ 审计范围 ⊇ 执行范围**,三者对齐才收敛。两次实证:wzulqp1f7(修复 targets 漏上游源 STOPPED)/ megarun(targets 固定 9 文件 < 审计「全部产出」+ 执行漏 CONTEXT/README/integration-blueprint)。3 修法:① targets 动态=findings location 提取 ② 执行后「完整性 gate」(标 modify vs git diff 实改对账)先于审计 ③ finding 分「产出 bug(修复)」vs「执行 gap(补执行)」。

3. **🔴 loopaudit 假 clean bug(rate-limit 全挂→空数组判 clean)**:审计 agent 全 rate-limit 失败 → `audits=[]` → `p0p1=[]` → `clean=true` 假绿。修:`panelOk = audits.length ≥ ceil(PANEL/2)`,panel 不足重试/STOPPED 非 clean。→ **任何「空集合→通过」判定先验集合非空有效**(同 claim-vs-reality 铁律2 空满足陷阱,如 no_negative_regression 因 0 负样本自动满足)。

4. **🟡 审计员把「已标废 context」当 P1 误报**:维度「事实准确」审计员 grep 到 534(已显式标「废口径,禁引」的 deprecation 段)也报 P1 → loopaudit 不收敛假象。→ 审计 prompt 让审计员**区分「裸残留」vs「已显式标废的 context」**(标废段提旧值是合法的,不是 bug)。

5. **🔴 失败 run 大产物 2.8G 差点入仓(.gitignore 不移除已 staged)**:θ-α 失败 run `Reports/` 2.8G 已 `git add`(staged),`.gitignore` 只对 untracked 生效 → 必 `git rm -r --cached Reports/`(本地保留 + 移出 index)。→ **提交前必 `git status` 看 staged 全貌 + `du -sh` 大目录**;失败 run 大产物(训练 log/metrics/snapshot/权重)gitignore,失败锚点(0/23)记文档不入 2.8G。

6. **claim-vs-reality「标 modify ≠ 已 modify」(执行维度,第10变体)**:inventory 标 `verdict=modify`(声称要改)vs 执行 phase 实际没改(CONTEXT/integration-blueprint 仍旧版)= 声称层 vs 事实层脱节,审计 catch。→ 执行后加「inventory 标改 vs git diff 实改」对账 gate(loopaudit 收敛定律 ② 同源)。

7. **🟢 主线程亲核 > 信 workflow loopaudit(STOPPED 后下钻发现核心已干净)**:megarun loopaudit 报 STOPPED@4,主线程亲核发现 r4 的 3 执行 gap 实际已被 round-04 补执行、paradigm §14/§15 已标废口径边注、562 全仓权威 —— **STOPPED 部分是审计员误报标废 context**。→ workflow 审计结论(尤同 family + 出过 bug)**主线程必下钻亲核**:STOPPED 不等于真有那么多未解(不假 clean 双向:也不假 STOPPED)。

## H. A2 代码重构 ultracode 执行教训(2026-06-23, code-only 范式对齐长跑)

1. **🔴 局部豁免扩大成整体豁免(漏 ultracode 审计线,磊哥两次 catch)**:派单 §I.2 分级「S0 口径=主线程亲手」是【执行线】的局部豁免,我把它扩大成「整个 S0 step 不用 ultracode 编排」→ 漏了派单 §D 要求的【审计线 subagent】(每 step 独立线:执行线 + 审计线 + 主线程亲核 + step gate 是整体合取)。磊哥「为啥没启动 ultracode workflow / 派单很明显要求」两次 catch。→ **派单 step 模式是整体合取,某条线豁免(执行线主线程亲手)≠ 整个 step 豁免编排;审计线/主线程亲核每 step 必在,不因执行线亲手而省**。元层 = 「A 维度局部豁免」被惯性扩成「所有维度豁免」,与 claim-vs-reality「派生表征当一手」同源(把「执行线分级」当「step 编排整体分级」)。

2. **🟡 审计线 subagent 必后台跑(run_in_background=true)**:派审计线 Agent 前台跑,主线程干等 340s 浪费(磊哥 catch「前台卡着浪费效率」)。审计线本就与执行/主线程亲核【并进】,该 background → 主线程并行做亲核/下一步准备,Agent 完成再收 verdict。→ **凡「并行于主线程」的 subagent(审计线/独立调研)一律 run_in_background=true,只有「主线程必须等其结果才能继续」才前台**。

3. **🔴 口径精确分类用「多重约束自验证」锁定成员(S0 191 allowlist 方法论)**:671 device 物理化成 10 族 191 explicit allowlist,用每族 (device,intent,行) **三重约束**自验证——三数同时对齐权威(191/562/2159 + 族外 480/976/1831)的概率极低,故三数全 match = 成员高置信正确(远比只对齐 device count 可靠;count 对但行差 = 成员错的强信号,如空调「个性化」=other_personalize_mode 漏选致行差 14)。方法:boundary §1 语义规则 → explicit allowlist → 三数迭代收敛(哪族 off 看 diff 精确换成员)+ fail-closed 脚本(sum≠191/562/2159 拒 emit)防 jsonl 漂移。→ **口径精确分类(易「count 对成员错」)必用多重正交约束自验证锁定,物理化成可机械复算脚本(SSOT=手写 allowlist + fail-closed 验证),不留手工清单**。这块主线程亲手(不派 finder)是对的——精确分类派 finder 各分各的会不一致(claim-vs-reality 避编造)。

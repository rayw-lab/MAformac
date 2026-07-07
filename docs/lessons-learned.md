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
7. **调研/实施派 3 codex worker,不 reflex-spawn subagent CC**(磊哥 2026-07-02 纠,截图 5 个 subagent 各占 1 tmux pane=9 panes 乱):overnight pre-LoRA push 调研相我开了 5 个 Claude subagent(gate-reality/grill-gaps/push-premortem 调研 + wave1-audit/fix-reaudit 审计),但当时 3 codex worker(%44/%45/%43)全 idle、就是干调研/实施的既定 swarm。根因 = **codex-meta §26 负载下抓 recall 最低工具**(Agent 一键 spawn 快)非 best-fit(worker 要 tmux read-act-read 稍重);且 async Claude subagent 收稿有摩擦(gate-reality idle-notify **交付零**、我自己 git 做它的活,其余要显式 file-write 才交稿,看着像卡)。→ **调研/实施/read-heavy 默认派 3 worker**(磊哥配的 auto-compact 质量高、tmux RECEIPT 报稿干净、3 窗口够用);**subagent CC 仅终极审计用**(cross-vendor/fresh-context 对抗,如 disaster-core gate2 复验合理);别 worker idle 时开自己 subagent 干 worker 活;**tmux 保持 2×2(1 commander + 3 worker)**。见 memory `feedback-swarm-dispatch-workers-not-subagentcc` + swarm-commander 宪法。

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
26. **masking 的 `loss_mask` 字段必须被训练 loop 真消费,写进 JSONL + preflight 校验字段存在 ≠ enforce**(2026-07-02 overnight push,对抗审计抓、commander 自跑 44/0 绿漏,D-014):gate2 一版把 `loss_mask.labels`(**char-indexed**)写进 `C5MLXRecord` + preflight 校验字段 + 44 swift test 全绿,**但训练 loop 走 stock `mlx_lm default_loss`+`--mask-prompt` offset,根本不读 loss_mask** = dead field,三层校验全在校 dead field 内部一致 = **0/34 精确同构**。→ **① 训练必真消费 token-level mask**:override `iterate_batches`/`default_loss`(或自定义 dataset)把 token 级 `-100` 进 cross_entropy(修复 = `maformac_masked_loss`+`maformac_iterate_batches`,`--require-maformac-loss-mask` 下替换 stock,删 `--mask-prompt`);**② labels 必 char→token 对齐**(tokenizer offset_mapping overlap,不按 String 字符——中文 1 字 1-3 token);**③ `<think>` span 必进 loss mask**(θ-α 第二战线,否则 loss 拟合 reasoning trace 非 tool-call);**④ 验证必到消费层**:self-test 合成 (logits, token-labels) 断言 masked 位置 loss 贡献=0(R7-safe 不跑真模型;实测 masked 0.00067 vs unmasked 2.667),别只校验字段存在(循环失守,自跑绿也漏)。**disaster-core 必 ≥1 异源审**(自跑与被验对象共享 frame,catch 不到架构级假enforce),见 `claim-vs-reality-gap` 第12变体。real-model batch dump 属 R7-gated(等 run-auth)。
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

4. **🔴🔴 高风险大工作量点上抛选择题找舒适圈被纠(磊哥「选难的脱离舒适圈,后续不问自驱」)**:S2 cut3(StateApplier data-driven,高风险大工作量:4 parser 缺口+parity gate)我上抛 A/B/C 选择题——A=按 dispatch 全做(难)/B=保守取巧守硬编码(易)/C=推迟 S3(易);磊哥纠「A 选择让你舒适度难受的来执行,脱离舒适圈的选项,后续不要问我了 按照这个元认知推进」。→ **dispatch 已定方向的高风险大工作量点,别上抛「全做(难) vs 保守/取巧/推迟(易)」选择题找舒适圈;直接选最完整最难的按 dispatch 自驱,不问**。🔴 元层=「上抛选择题」有两种:真 dispute-triage 口径型(仁者见仁无客观对错,该上抛)vs **遇难退缩找舒适圈的伪装**(dispatch 已定方向,选项是难/易而非口径,不该上抛)。区分判据:若选项是「按 dispatch 全做」vs「保守/取巧/推迟」且方向已定 → 是我找舒适圈,直接选难的。与 H1(漏审计线=局部豁免扩大)/§27(产出冲动)同源:都是遇复杂/难就找绕过的反射,扳机=「我想上抛/简化/推迟」念头出现时先问「这是真口径型还是我退缩找舒适圈」。

5. **🔴 S4 撞见「446 假删」活样本 bug(claim-vs-reality 铁律1 的代码现形)**:S4 改 C5 训练 surface 时,发现既有 `buildNoCallSamples`(C5LoRATraining.swift)写 metadata `removedToolID="tool_call_frame"` **却从不从 `sample.tools` 物理删目标工具** —— 正是 0/34 通宵 wave 灾难根因(rule §铁律1「446 假删」)的活实例,一直躺在代码里。S4 cut5 顺手修真:`sample.tools = positive.tools.filter { name != removedName }`(物理删)+ `targetToolPresent` 反映**实际产物**(非硬编码 false)+ 活样本测试断言目标工具真不在 tools。→ **改某 surface/契约时撞见的「metadata 声称 X 但 code 没执行 X」要顺手修真(enforce 非 declare),别绕过;尤其 no-call/反事实样本的「移除」必物理删非 metadata 标记**。元层 = 派生表征(metadata 字段)当一手事实(实际 tools 列表)的代码层 living instance。

6. **🟡 D-domain 工具 arg schema 逐工具异构(非统一 value 四件套),训练 arg 必从 catalog schema 派生**:D-domain 562 具名工具的 parameters 属性**逐工具不同**(python 实跑坐实:只 210/562 有 `value` 键;`adjust_ac_temperature_to_number` 用 `temperature` 不是 `value`;`open_ac` 只 device/direction 无 value;slot 键 position/mode/screen_type 各异)。所以 C5 训练样本的 D-domain call args **必从该工具 catalog entry 的实际 properties 派生**(`dDomainPropertyEnums` 读 schema enum),只 emit schema 内的键(`additionalProperties:false` 合规),device/action_primitive 不 emit(编码进名)——**不能套用 frame 的统一 value 四件套硬塞**。→ **迁具名工具 surface 时,arg 形态必逐工具按其 schema 派生(异构),不假设统一 arg 模板;凭印象套模板会产非法 arg(违 additionalProperties:false)**。靠 python dump catalog 坐实异构(非凭 frame 经验推)。

7. **🔴 「生成」产物可能是混合体(generated + 手维护),盲目 regen 丢手维护部分**:S5 迁 C6 bench 时 `C6BenchCLI generate` 重物化 `c6-bench-cases.jsonl`,我以为它纯生成 → 结果丢了 12 个**手维护**的 `C6-TRAP-*` 反事实 case(generate 只产 45 mustPass/negative/coverage,trap 是手 append 进 jsonl 的)。`testTrackedDatasetDecodes`(断言 trap=12)失败才暴露。→ **regen 任何「生成」产物前先问「它是纯生成还是 generated+手维护混合体」**(grep 产物里有无 generator 不产的条目/前缀);混合体必保留手维护部分(从 git HEAD 取 + 迁移 append + 存迁移脚本可复现)。元层=「这文件是 generate 出来的」是 claim,实际可能是混合(派生表征当一手)。**好测试(testTrackedDatasetDecodes 断言具体 trap 计数)是 catch 它的安全网**——别只测结构(decode 成功)要测内容(trap 计数/类型)。

8. **🟢 write-test-fix 收敛迁移 > 脑内逐 case 验 state(percent parity 被实跑 catch)**:S5 迁 26 个 C6 case 的 D-domain 名+args,我没逐个在脑内验「这 args 经 normalize→applier 产对 state 吗」,而是迁完跑 `verify-gold`(expected vs expected 自洽)→ 3 个 percent case fail → 修(`value:"50%"` 应为 `"50"`,因 C5 emit `value.offset="50"` 无 %,且 buildValue `Int("50%")=nil` 丢数)→ 45/45→57/57。→ **大批量机械迁移(N 个 case 名+args 重映射)靠 write-test-fix 内循环收敛(迁完跑自洽门→修失败→重跑),不靠脑内逐个推 state**;尤其值形态(% / 单位 / 键名)的 parity 凭印象易错(我授权 "50%" 自以为对,实跑才知 C5 是 "50")。与 §execution-discipline 内循环同源,扩到「契约/数据迁移」。

9. **🔴 主线程亲核能发现比综合官/finder 更优解(caller 逻辑 + catalog 实际内容)**:S5 主线程亲核覆盖综合官 2 处:(a) `requiresStateDelta` 综合官 ⭐C=`expectedStateDelta非空`,但亲核 caller `!requiresStateDelta || !delta.isEmpty` 逻辑发现 ⭐C **退化成恒真=守护失效** → 改 `!hasPrefix("query_")` 保守护;(b) MP-029 综合官说「query_cabin_comfort 不存在 → 移出 unsupported」,但亲核 catalog 发现 `query_ac_temperature` 存在且「现在车里几度」正好是温度查询 → 映射它(保 mustPass)更准。→ **综合官/finder 建议是 claim,主线程亲核(尤其涉及 caller 调用逻辑 + catalog 实际有什么)常发现更优解;别盲信 ⭐ default,亲核它在实际代码/数据里成不成立**。与 claim-vs-reality §31(调用沉淀双层 check:发现型非可选)同源。

10. **🟢 cross-vendor 多审计 findings 不同集 = 覆盖面并集(非冗余),实跑审计 > 纯读审计**:A2 终审跑三厂商(GPT Pro 5.5 Pro / hermes GLM-5.2 / GPT-5 Codex)同 prompt,findings **不同集**——GPT Pro 独抓 P0(`--scope full` 解码崩)/GLM 独抓 P1-2(direct clamp)/Codex 独抓 P1-2(qwen-yaml stale)+verify-all+SwiftPM warning,**both/all 共识 P1(dDomain miss fallback)**;三者全实跑坐实真 bug。**单审会漏**(GPT Pro 漏 clamp/GLM 漏 scope full/都漏 qwen stale)。🔴 **Codex 唯一 fetch PR + 临时 worktree 真跑 swift test+make verify**(非纯读)→ 抓到纯读漏的(SwiftPM warning 实跑才见 / make verify 不含 swift test 实跑才知)。→ **重大产出终审派多厂商(≥3)同 prompt = 不同模型抓不同盲点的覆盖面并集**;且**至少一个实跑审(fetch+build+test)** 抓纯读漏的。与 §16(同 family bias)/§31(cross-vendor≠cross-frame)同源,实证「不同厂商=不同盲点集」。

11. **🔴 审计 finding 辩证 check(谨慎迎合):真 finding 实跑坐实修 / 项目决策 steelman / DEFERRED honest + subagent 仲裁**:磊哥「谨慎迎合」+「P2 全修但任务要完美」。我的处理:(a) **真 finding 亲核坐实再修**(P0 `--scope full` 我实跑 `DecodingError` 坐实才修,非盲信);(b) **项目决策 steelman 不盲从**(三审计都建议加 CI,但项目 D1 决策=`make verify` 替 CI 轻治理 → steelman 守住,只加 `verify-all` 聚合不引 CI infra);(c) **DEFERRED 要 honest 非偷懒**(distractor index=可优化非broken+NOT训不跑大规模 / deviceCellMap codegen=亲核 grep `state-cells:14`「映射独立」坐实**无 codegen 源** / C5 拆分=risky 大重构)→ 写吸收档逐条 rationale;(d) **派 subagent CC 审计仲裁 DEFERRED 真伪**(它 grep 坐实「无源」+「可优化非broken」= defer 成立非偷懒,verdict CLEAR)。→ **多审计修复 = 真 finding 修 + 项目决策 steelman + DEFERRED honest rationale + 异源仲裁;别盲信全修(过度工程)也别懒 defer(偷懒),靠亲核 + 异源裁**。与 maformac-internal-demo-audit-filter(每 finding 问「对内部 demo+轻治理成立吗」)同源。

12. **🟡 `.gitignore` `!dir/` un-ignore 整个目录坑 + Reports/.gitkeep SwiftPM exclude 解**:修 SwiftPM `Invalid Exclude Reports: File not found` warning(clean checkout Reports gitignored 不存在),我加 `!Reports/` + `Reports/.gitkeep` → **`!Reports/` 误 un-ignore 整个 Reports 目录**,所有 runtime 报告(c5-lora-training 等十几个)暴露成 untracked。修法:`Reports/*` + `!Reports/.gitkeep`(忽略目录内所有,仅保 .gitkeep)。→ **`.gitignore` 保留空目录用 `dir/*` + `!dir/.gitkeep`,不用 `!dir/`(后者 un-ignore 整个目录)**;SwiftPM exclude 不存在路径的 warning = 提交 `.gitkeep` 占位解。

## I. default_scope apply 长跑教训(2026-06-24, C2/C3/C5/C6 apply + R1/R2 审计)

1. **🔴 resolver 错误不能用 `try?` 吞掉再写 base cell**:default_scope state applier 一度 `try? C2ScopeResolver.resolve(...) ?? ScopeResolution(keys:[cellID])`,导致 `position=后排` 这种 out-of-scope scope 被吞成 `window.position=100` base-cell 写入。R1 抓出后补红测和机械门。→ **任何 scope resolver / contract resolver 错误必须 fail-closed(no-write 或显式错误),不能 fallback 到 unscoped base key;机械门要 grep 禁 `try? resolver` + `ScopeResolution(keys:[cellID])` 这类假兜底。**

2. **🔴 ScopeOrigin 单源不是“全仓出现几次字符串”**:三道门最初只合并文件数 `scopeOrigin` 次数,但 C6 verifier/eval result 没有 `scope_origin_evidence`,receipt 却声称 single-source pass。R1 抓出后改成 C6 gold/eval result 携带 `scope_origin_evidence`,并由 `C2ScopeResolver` 计算。→ **单源门要逐 consumer 断言 typed origin 被消费,尤其 verifier/receipt/UIUE handoff metadata 这类证据面;全局字符串计数只能当 smoke,不能当 proof。**

3. **🔴 receipt 声明生成链路时,生成命令本身也必须入 evidence**:C6 JSONL 确实从 `Core/Bench/C6VehicleToolBench.swift` 生成并补 trap migration,但初版 receipt 只记录测试/make/OpenSpec,没记录 `swift run C6BenchCLI generate` 和 `migrate_c6_trap_to_d_domain.py --old-from-git` 的 exit/log/hash。→ **claim_boundaries 里写“由 source+trap migration 生成”时,commands[] 必须有对应生成日志、exit_code、sha256;否则是 claim-vs-reality 漏证。**

4. **🟡 `Reports/*` 默认忽略,receipt 要么 force-add,要么放可追踪路径**:本轮 receipt/log 落在 `Reports/default-scope-apply-*`,被 `.gitignore:Reports/*` 忽略;R1 指出“本地有 receipt”不等于“repo durable evidence”。→ **需要提交的 receipt 不能只存在被 ignore 的目录;若项目约定继续放 Reports,必须 `git add -f Reports/<run>/receipt.json` 和必要日志,并在 stage 前用 `git check-ignore -v` 确认。**

5. **🟡 `make verify` 的 diff 门要求干净 tracked tree,dirty 状态下跑会假失败**:R1 修复后直接跑 `make verify`,失败在 `diff` 目标,原因是未提交的 scripts/Makefile/Core diff,不是测试或生成物错误。→ **含 `git diff --exit-code` 的 verify 要在相关 tracked 改动 commit 后作为最终门跑;dirty 阶段只跑 focused tests/机械门,不要把 diff 门失败误判成实现失败,也不能把 dirty verify 写成 pass。**

6. **🟡 SwiftPM test helper 被中断后可能 orphan/stuck,清 `.build` 比继续等更可靠**:本轮多次中断 `swift test` 后留下 `swiftpm-xctest-helper` orphan,后续 `--filter`/`--list-tests` 卡在 helper launch。清理 orphan 后 `swift package clean` 重建,同一单测恢复 12s 内通过。→ **测试异常长时间无输出时先查 `ps` 的 swiftpm-xctest-helper;若是中断遗留,kill orphan + `swift package clean`,再原样重跑 hard gate,不要把 workaround pass 冒充原命令 pass。**

7. **🟡 research/tooling 目录可能含嵌套 `.git`、node_modules 和 pack,不能 `git add -f` 整包推**:`Tools/paper-to-skill-gate/` 有本轮需要推的轻量 research artifacts,但内部 reference clones 有 `.git/objects`、`node_modules`、PDF/PPTX 大文件,目录自身 `.gitignore` 已把 clone 内容隔离。→ **推 research 目录先 `find -name .git` + `du -sh` + 大文件 scan;只 stage README/SKILL/schema/script/trial-runs 等轻量可审计产物,不要把 clone pack/node_modules 当 research evidence 强推入仓。**

8. **🟢 R1/R2 审计要接受“receipt/claim 风险”类 finding,不是只看代码**:R1 没抓 P0,但抓出 4 个 P1,其中 3 个是 receipt durability、C6 生成日志、ScopeOrigin 证据面问题,不全是 runtime bug。→ **apply closeout 的 subagent 审计 prompt 必须覆盖代码、测试、机械门、receipt、ignored/staged 状态和 claim boundaries;主线程吸收后再 R2,否则容易把 local-pass 写成 fake green。**

9. **🔴 P0 可以是合并证据链,不是只看代码安全漏洞**:两份 GPT Pro 报告都没发现 CRITICAL/secret/RCE,但窗口2把“当前 head clean receipt + GitHub CI/status 缺失”升为 P0 合并门。我第一反应容易把 P0 只理解成代码域安全事故。→ **merge gate 的 P0 要按证明链判断:旧 head/dirty receipt + 无 CI run = 不可 merge,即使代码 P1 已修;P0/P1 需要按 domain vs merge-evidence 两条轴分类。**

10. **🔴 跨 grill 线冲突不能盲吸收单份审计建议**:GPT Pro 基于旧 C3 test 推“defaulted scope 完全 elide 主驾”,但 UIUE AD-8.7 已拍“默认 scope 淡显、非完全省略”,理由是客户要分清主驾/全车。若按 GPT 原建议改 domain readback,会撞 UIUE 已拍策略。→ **审计建议进入实现前先查相邻 worktree/决策线;同一字段跨 C3/C6/UIUE 时,用更具体且最新的 grill 决策裁剪建议,并把偏离审计原建议写进吸收记录。**

11. **🔴 机械门名称不能大于真实覆盖范围(C5/C2 parity window-only 活样本)**:`check_c5_c2_scope_parity.py` 名字叫 C5/C2 parity,实际只读 `window.position`;即使 C5 代码改成 device-aware,脚本仍会放过“回到 window-only”的假绿。→ **每个 gate 名称要配 coverage audit:若叫全量 parity,脚本必须枚举全量或至少 fail 当 only-window;否则把 gate 重命名为 window smoke,不要用宽名制造信心。**

12. **🟡 CI 不能偷跑本机 raw 依赖,也不能沉默降级**:`make verify-all` 包含 `freeze_snapshot.py --check`,读取 `~/workspace/raw/.../source-snapshots`;GitHub runner 没这些 raw 文件。直接把 `make verify-all` 放 Actions 会红;在 CI 里偷偷 skip `verify-source` 又是假绿。→ **CI 要显式建 source-free target(如 `verify-ci`)并写明 proof boundary;完整 raw-bound proof 仍由本地 head-bound receipt 跑 `make verify-all`。**

13. **🟡 C6 expected delta 要区分“主期望 final value”和 C2 dependency side-effect**:空调温度写入会按 C2 `depends_on` 同步打开 `ac.power`;若 C6 exact delta 粗暴要求“只改 expectedStateDelta keys”,会把合法 dependency 当 unexpected mutation。→ **exact delta gate 要允许 C2 声明的 dependency side-effect,但 readback/expected delta 不必把每个 dependency 都当主期望;否则会逼 JSONL 写伪读回。**

14. **🟡 SwiftPM helper 卡死不能扩成“测试失败”或“验证通过”**:本轮多次 filtered test/direct xctest 卡在 `swiftpm-xctest-helper`;清理 helper + serial rerun 后 focused tests 正常过。→ **SwiftPM 卡死只算 infra interruption,不算 pass/fail;最终 receipt 只记录成功复跑的原命令和 log,并避免并行 SwiftPM 测试。**

15. **🟡 source-free CI 里的本机 fixture 测试要显式 skip,不能红也不能假装覆盖**:GitHub runner 无 `/Users/wanglei/.cache/huggingface/...` 和 Homebrew python@3.13,`testPythonMaskOffsetFixtureRunsTrainingTokenizerPath` 在 CI 红,但这是本机 tokenizer integration proof 缺 fixture,不是 default_scope 代码失败。→ **依赖本机模型/cache/raw 的测试用 `XCTSkip` 明确环境缺失;CI proof boundary 写清 source-free,本地有 fixture 的 `verify-all` 继续跑真路径。**

## J. rebuild-c6 文档吸收前置教训(2026-06-24, Q1-Q4 grill closeout)

1. **🔴 文档吸收前先对齐 `origin/main`,不要把新路线落在旧分支上**:Q1-Q4 账本最初叠在 `a9ce7cf` 分支,而 `origin/main` 已到 `c1e7d58`。若直接按旧 file:line 改 OpenSpec,会把 UIUE/main 后续状态和非 UIUE 路线混成一个假当前态。→ **任何跨 handoff/PR 后的 OpenSpec 吸收,先 `git fetch` + 记录 `origin/main` SHA + 从最新 main 开新分支,旧账本只能当 evidence anchor,不能当当前 API/行号真态。**

2. **🔴 SSOT 必须列全消费者,不能只列当前争论里最显眼的两个名字**:Q4.5 起初只说 `behavior_class` vs `C6Bucket`,但 Q2/Q3 已经让同一 taxonomy 同时服务 C5 `data_class_observed_count`、C6 denominators/selectors、apply `no_effect_reason`。只修 C6 两个名字,apply 或 C5 仍会私建分类。→ **定义 shared taxonomy 时显式列 producer/consumer: C5 数据计数、C6 分母/selector、apply no-effect reasoning;任何少列一个消费者的"SSOT"都是潜在双源。**

3. **🟡 static teardown 只能支撑文档设计,不能升格成验证通过**:paper/code teardown 能证明"应该怎样设计"和"哪些路径有风险",不能证明 C6 acceptance、模型质量、base recalibration 或 demo readiness。→ **OpenSpec 文档吸收的 proof class 只写 `local`/`local_static_teardown`;验证白名单只用 OpenSpec validation 和 `git diff --check`,不得把 teardown 证据写成 golden-run、C6 pass、V-PASS 或 readiness。**

## K. M1 consolidation + 交叉审双拦截教训(2026-07-02, wave-1 合流 main)

1. 🔴 **per-branch CI 绿 ≠ 全量验收绿；merge 后必须跑一次完整 `make verify-all` 验收**。实证:gate8 分支(PR #12)CI 绿+22 测试绿+双审 CLEAR+D-015 复算 562 对,但它**直改 `generated/family-device-allowlist.json` 派生物没改工厂 `scripts/gen_family_allowlist.py`**——regen 一跑 562 打回 TBD,merge 后验收 diff 门才现形(claim-vs-reality 第9坑「派生物 vs 工厂」在【提交流程】的变体:每个人都核了派生物的值,没人问工厂产不产同样的值)。修复=PR #15(工厂实算 tool_count+Makefile regen 重排 gen_tool_contract 先行解 stale-by-one)。防线:改任何 `generated/` 文件的 PR,审计维度必含「工厂 regen 后 diff-clean 吗」;merge 后全量 verify-all 是验收标配非可选。
2. **交叉审对抗 fixture 是破「作者+commander 双盲」的标配**。实证×2:①gate2 反向 guard 只扫 `("train","valid")` 漏 test.jsonl——commander 当天亲读过那行也没扣出,%43 构造 test.jsonl 对抗 fixture 实跑才现形(XAUDIT-alpha FAIL+P0→一行修复+行为测试→P0-RESOLVED);②E-2 design 包被 %44 抓「六轴写成五方丢 train target 轴」。规律:静态读码抓不到「枚举少一项」类缺口,**构造反例实跑**才抓得到;grill/design 产物上抛前必过一轮异源对抗审。
3. **staged PR 序(α→β→γ)+每支独立 CI+审计 = 回滚点保全**。γ 文档整编支(40 件)用「新支 off main 复制 port」而非 rebase 旧支,语义审用 hash 对比(35 逐字节一致+3 whitespace-only+2 带溯源 frontmatter)半小时收口——比人肉读 40 件快且可复算。
4. **worker 主动回报纪律(磊哥 2026-07-02 定)**:每任务完成打 `REPORT|任务|status|产出|SHA|残留` 行,长任务每 ~5min 打 `PROGRESS` 行,blocker 立即 `BLOCKED` 行,不静默——commander 轮询成本降一半,漏收稿风险消除。已发三 worker 常设。

## L. 外审执行位教训(2026-07-02, G7 hermes 终审)

1. 🔴 **hermes-rescue subagent = 假异源陷阱**:实测 spawn `--model sonnet`(Claude 家族)非真 hermes GLM——用它做"跨厂商审计"= 同家族自审冒充异源(正是 0/34 假异源 judge 同病)。跨厂商审计必走 worker 在 codex CLI 显性调 `~/.codex/skills/hermes-cli-glm52-code`。磊哥截图 catch。
2. **commander 直跑外部 LLM CLI 不可靠**:hermes 直跑回 284 字节废稿(无人盯守/无质检/background stdout 截断风险)——外审执行位必须是能"盯全程+质检+重试"的 worker(%44 首单即自带 attempt 编号+jq 提取+字节数/verdict 质检,范式正确)。timeout 上限 20 分钟(磊哥定)。
3. **hermes CLI 本体损坏的诊断路径**:SyntaxError→查 git status 发现是中断的 stash pop 冲突现场(5 UU 文件)→ `git reset --merge` 可逆中止(git 在 pop 冲突时不丢 stash,stash@{0} 18 文件原封)→ import 自检恢复。别上来就改冲突标记——先判断是不是别人的半截操作现场。
4. 🔴 **交叉审的「验证声称」本身要抽核（审计的审计）**:XG7D 交叉审声称亲跑验证「manifest 缺失/目标不在 group/policy 失配」三态 fail-closed 给 PASS_WITH_NOTES,但 hermes 亲构 wrong-policy probe 实跑证明**第三态从未被拦**(loader `C5LoRATraining.swift:2861` 取首 entry policy 零校验)——交叉审的第三态验证是假的(可能只构造了前两态 fixture 就外推)。修法:① 审计员回执必逐态贴【实跑命令+输出】非清单式声称 ② commander 收审计稿抽核「声称验过的最关键一态」③ 真异源(跨厂商)终审对 ship-blocking 面必做——同 runtime(codex)交叉审会共享盲区。这是 claim-vs-reality 铁律2「审计实跑一手」在【审计员自身产出】上的递归应用。

## M. tiny-ablation v5 高价值失败 + 三轮跨 LLM 辩证元认知(2026-07-02)

1. 🔴 **consumer-anchored sufficiency（充分性轴）**:项目验证哲学成熟轴=真实性(claim-vs-reality,可机械化);本次暴露正交的**充分性轴**(做的=下游消费者要的吗)——必须锚定消费者契约才可测。gate2 dead-field(产物没人消费)与本次(监督没喂够消费者所需)=**同一生产者-消费者契约的两半断裂**。修法:产物 frontmatter 声明 consumers/sufficiency_evidence + landing 加 fit-proof 列 + 审计 SPEC 模板加 fit 维度 + readiness 四级词表(mechanism-true/fit-proven/experiment-valid/behavior-proven)。
2. **归因收敛偏差(commander 亲身)**:首轮 teardown 找到第一个能解释现象的根因(探针重叠 0/34)就收敛,**同一批数据里的更深根因(训练 user=协议串)近在手边没看**——GPT-5.5 看同样数据多问一层抓到。修法=**归因 loop-until-dry**:每轮问「同一批证据还支持什么别的根因」直到连续一轮无新增,而非首个可解释根因即收。
3. **纪律场景索引过窄(commander 亲身)**:「同 harness 分层」是我参与锁死的 c5-recovery 纪律,却没应用到 F-044 自身(28/34 历史锚跨 harness)——规则绑死原生场景(C6 评测)不触发同型新场景(任何 baseline-candidate 比较)。修法=项目级铁律出现【同型结构】时主动泛化匹配(配对比较→同 harness;派生物→查工厂;声称→查消费)。
4. **证据第二信息层(commander 亲身)**:probe 的 `NO_TOOL×27` 亲眼看过,注意力全在主信息(输出了 NO_TOOL)漏了第二层(重复 27 次到 token 上限=decode 契约/stop token 缺失)。修法=关键证据扫两遍:「它回答主问题什么」+「它还暴露什么别的」。
5. 🔴 **跨 LLM 开放归因强破框(对 codex-meta §31 的精细化)**:§31 说 cross-vendor≠cross-frame(核对性任务上换厂商仍共享 task frame)——但本次三轮辩证(Fable5→GPT-5.5→Fable5)每轮抓到上轮真漏(输入面/目的漂移 ↔ 重叠数据/基线断裂/decode 契约),因为**开放归因任务上不同 LLM 的先验框架决定「先看哪」**,frame 差异恰好成为资产。精细化判据:**核对性任务(字段对不对)跨厂商弱破框;开放性任务(为什么失败/还有什么)跨厂商强破框**——P0 级失败分析制度化走「双 LLM 独立写→交叉辩证→终版综合」(成本~1h)。
6. **机械闯关元门**:v1-v5 五连机械修每次都对(D-025 快速通道无罪),但连续机械修≥3=「在给语义可疑之物铺路」的统计信号——若 v3 后做过一次 5 分钟 fit-spot,209 tokens 哨兵就会被扣住省两轮授权。修法=连续 3 次机械修→强制 fit-spot(「我在给什么铺路?它语义成立吗?」)。
7. **哨兵数字行为学**:209 trainable tokens 在 preflight 里躺过全程、人机都读过、无人扣扳机——「数字可见≠数字有门」。修法=receipt 每个载力数字必有阈值门或显式 no_gate_by_design 标注。

### L.5 tmux 消息静默丢失：send-keys 必 -l + 分离 Enter + capture 验证送达（磊哥 2026-07-02 纠）
给 codex worker 发长消息用 `tmux send-keys -t %44 "长文本" Enter` 一条命令 → "not in a mode" exit 1 **静默失败**（后台跑更察觉不到），worker 空等 40min；磊哥另截图 catch「有时没按回车」（消息停输入框未提交）。修法四步硬 SOP：`-l` literal 发文本 → **单独一条命令发 Enter** → sleep → capture-pane 验证消息进对话流+状态 Working。worker 回写 %42 同病：轮询见 idle 但无 REPORT → capture 它 pane 看有无滞留回报，有则替它补 Enter。已进 swarm-commander 宪法 §9.x。
🔴 补（2026-07-03 磊哥截图 catch）：**滞留判别法**——capture 里 `›` 开头多行文本≠必是滞留（codex TUI 对话流里已提交的用户消息也以 `›` 回显）；真滞留的特征=消息在输入框位置（`›` 行下方紧跟 token 计数状态行）且 worker 无对应回复。**commander 自己的输入框也会滞留**（`[Pasted text #2]` 粘贴占位悬挂——heredoc/粘贴溢出到自己 pane），收工前 capture 自己 pane 自查一次。

### M.8 same-surface 是复合对象：维度分解表取代单数声称（2026-07-03 tools 挂载冰山）
「同输入面/same harness」的单数名词掩盖 surface 的复合自由度（system/user 形态/think 块/**tools 挂载**/停止 token/decode 参数/tokenizer patch…）。v6 probe1 全 empty 即训练面带 E-2 挂载 737 token 而 probe 无挂载——契约语言每轮只验「已知维度」。修法=same-X 声称强制展开为 X 维度分解表（训练列 vs 评测列逐维打勾，新维度即追加）；生成数据的 surface 同表治理（G7 行级 tools/subset 字段贯通实装）。lineage：gate2 dead-field→v5 under-supervision→v6 tools-mount，同一 producer-consumer 冰山三层。

### M.9 复算工具自身可注入假信号：span 测量纪律（GF-156）
commander 用「另一渲染的长度」推 teacher-forcing span 起点得 14/18 假信号，几乎误导向「adapter 加载错位」；改用 assistant_tokenization 精确 start 后 17/17 满分。教训：排除法的每一步复算工具本身要先自证（对齐类复算必用与训练同源的定位函数，禁用近似推导）。

### M.10 paired base 配对的信息增益实证（磊哥六拍④当晚兑现）
v6 无配对时 B 11/15 会被读「学到 73%」；配对暴露 B delta=-1、D delta=-10（tiny 过拟合窄化）+ base 带挂载 zero-shot 真值（B 12/15、D 18/34）。单臂数字永远缺参照系——ablation 的字面义就是配对对照。

### M.11 收官账表述过宽被外审逐条打回：完成度措辞五问（2026-07-03，D-040）
通宵收官账四处过宽被磊哥转达的外审收窄：①「双审 APPROVE 可一键 merge」——本地 worker review ≠ GitHub review（live latestReviews=0），且旧 review 绑的 head（`3b081823`）被后续 hotfix push（`e6a8849f`）作废=**review artifact 必绑 head SHA，head 变即失效**；②「CI 待 billing 重跑即绿」——FAILURE check 不得预支为绿，billing 只是归因；③「数据门全量兑现」——DataGate local pass ≠ train-ready（preflight strict exit66 同帐在案）；④ v6.1「重复被压住」滑成「输出稳定」——C 4/4→2/4、D 8/34→5/34、+4 parse_error 是同帐并存事实，**改善与残留必须同句陈述**。根因=completion-claim-triage（计划态/执行态）在【收官汇报】场景复发：收官叙事的「可一键/已兑现」措辞天然向宽滑，且写晨报时无 Stop-hook 类机械门拦（cite-verify 只核数字有源，不核完成度语义）。修法=收官账每个完成度断言过**五问**：绑的哪个 head？哪个系统的 verdict（本地/GitHub）？门实际 exit code？改善项的同帐退化项列了吗？「可 X」是现在真可还是前置齐后才可？

### M.12 worker 闲置被磊哥抓现行：idle-scan+backlog 机制化 + 总监默契（2026-07-03）
N5 canary 期间 %43 的 judge SPEC 写好后被我晾着「等 canary 数据落地」~20min，磊哥抓现行（「不主动安排任务=让他们白拿工资，不允许」+「最大化复合总监能力」+「有的东西我不说你要懂」）。实际当时就有磨刀活可派：judge 校准预演（拿 N4A 协议串行跑 rubric，预期维1 FAIL=校准判别力+OpenAI 家反框挑 rubric 毛病）——事后补派证明真有价值。**机制固化三层**：全局 rule `~/.claude/rules/swarm-idle-scan-and-backlog.md`（每轮轮询强制 idle-scan/收 REPORT 自带下一单/backlog 池常备/复合总监三视角出题）+ 宪法 `swarm-commander.md §10` + 记忆 `feedback-commander-tacit-understanding.md`（默契八条：随口担心=深挖指令/人审键攒打包/收口自动沉淀等）。业界核证：Agent Teams self-claim task list 是同题拉模型解法，push 模型由 idle-scan 等效。

### M.13 管道吃退出码：git 变更命令禁 `|tail` 链 `&&`（2026-07-03 commander 亲踩，D-050）
rebase PR31 用 `git rebase origin/main 2>&1 | tail -2 && git push --force-with-lease`——rebase 冲突中断（非零退出）被管道尾 tail 的 exit 0 吞掉，&& 放行 push，把**截断分支推上远端**（缺冲突点之后全部 commit）。原 tip 立即 force 恢复零损害。修法：①git 变更类命令（rebase/merge/push/reset）**独立执行看退出码**，输出要裁剪就先落文件再 tail ②要链就 `set -o pipefail` ③冲突高风险 rebase 交作者 worker 解语义，commander 只做机械 fast-forward。与 foreground-batch（合并命令）相容但边界在此：**合并只读检查 OK，变更命令的成败判定不得被管道稀释**。

### M.14 验证口径必须绑【验收基线 artifact】+ CLI 默认值 vs 锁值 footgun（2026-07-03，D-051）
%45 解完 PR31 合并冲突报「验证全绿」，实则 preflight exit0 跑在**自己重生成的数据**上（且重生成误吃 CLI 默认 refusal_ratio_target=0.1，非 D-042 锁值 0）；commander 用 N4A 验收基线数据复跑同命令 = exit66，当场拦下。两教训：① **「绿」必须声明跑在哪份 artifact 上**——验收基线 artifact 的绿才是验收绿，重生成/fixture 的绿只证明代码自洽（生产者-消费者契约的另一半没验）；收稿方复跑必用基线 artifact。② **锁值必须显式传参/进 manifest，禁依赖 CLI/config 默认**——通用默认值（0.1）会在任何重跑处静默替换锁值（0），与 claim-vs-reality 铁律1「enforce 非 declare」同源：锁值不进调用面=没锁。

### M.15 数字核真 ≠ 后果定价（2026-07-03 T1-OOM，commander 亲身第四层）
PR31-final 复跑时我亲眼核了 trainable_tokens 44459→113914（recheck3 log 一手）并标「expected（新契约监督面扩大）」——真实性核对完成，但没有问「2.56x 监督面/首次引入 7k 长序列对 backward 显存意味着什么」，两小时后 T1 Metal OOM 补了这一课。**核真只完成一半：任何亲核过的显著变化数字，必须再问一句「它的下游代价在哪个维度（显存/墙钟/质量/成本）」**——不定价后果=第四层 claim-vs-reality（前三层：没核/核不细/核了别人的转述；第四层：核了真值没核含义）。机制化=「X-ready 声称必带资源包络两列」+ 风险类×最廉门矩阵（全局 rule verification-economics-baseline-registry）。

### M.23 资源包络绑定宿主环境基线 + 挂起比崩溃更隐蔽（2026-07-04 R2b 首跑 swap-hang，D-092）
R2b 短训首跑：起跑时系统已用 23.7/34.4GB（5 codex+CC+13 天残留进程），训练进程膨胀至 25GB→swap 18GB 满→UN 态挂起 32 分钟（首 val 卡 4%，R2a 同步骤 70s）——磊哥「感觉没有自动化推进」才发现。三层失误：①**包络 basis 含宿主环境**（R2a 峰值 17.97 是空机数字；起跑前必查 free ≥ 包络峰值+3GB，不足先清理=起跑 checklist 硬门）②**M.15 复发**（亲核 tokens +11.8% 写进决策却没定价内存/环境含义——核真≠定价第二次同坑）③**watchdog 的 val 阶段盲区**（process_peak 读 train_report，val 期间全 NA；「进程活着」≠「进程在动」——修=首 val 完成 deadline 断言[锚=实测 70s×4]，UN 态+无进展=杀并报，不等 checkpoint deadline 11300s）。**挂起（UN/swap）比崩溃（OOM）更隐蔽**：不崩不报错就是不动，资源门矩阵要同时覆盖两种失败形态。

### M.22 转换步守恒门：管线每个转换步必须有输入输出守恒断言（2026-07-04 split 静默丢弃 584 行，D-091）
R2b 组装→渲染转换步：584 修复行因缺 split 字段被渲染分桶规则静默丢弃（若入训=修复数据 90% 不进训练=整轮白训），scanner/DataGate/preflight 三门全没抓到——**它们都在转换步单侧**（上游门看组装产物问题未显现；下游门只验「拿到的行可训」不知「应有多少行」）。commander 手工行数对账才拦下。三层修：①L1 字段规整+断言 ②L2 管线缺「候选 schema→训练样本 schema」显式升格校验步（隐式约定在每个新组件上必断）③L3 **每个转换步必须有守恒断言**（输入总量==输出分桶之和，fail-closed 进 runbook/receipt）——与 0/34 tool-surface 双源、A2 链路 parity 同族定律；verification-economics 风险矩阵补「转换步守恒」格。触发扳机：任何「A 产物 → B 产物」的转换代码（渲染/分桶/合并/过滤/投影），写完第一件事=写守恒断言。

### M.21 约束物化定律：没被物化成机械可查状态的约束会在流水中蒸发（2026-07-04 R2b 一日三同构，D-090 三层发散）
R2b 拆批流水一天内三次同构暴露：①numeric_value_constant 写在 evidence prose 里 vs judge 按结构化字段判（两 lane 独立同坑）②worker「完成」以落盘自认 vs REPORT 送达才算（多 worker 反复）③airoutlet/wind 配额是 W10 notes 里一句 prose→四个批次 0/6 彻底蒸发，而 set_interface_vs_defog 有 mandatory_first/carry 状态标签→全程被追踪只差 1。**定律：约束的可追踪性=它的物化程度**——prose 约束必丢，结构化状态（字段/tag/账行/断言）才存活。三条修法：①任何进配方/order 的量化约束必物化（floor tag+required 数字段+locked-floors.json 账行）②拆解流水必配套跨批累计账门（局部达标≠全局达标是拆解自带的新风险面；每批 accept 跑秒级累计 mini-账）③规格进 order 时逐条口径编译（一句话两读的必须拍死成断言表达式，如 query 保护行的 query-side 严格口径）。与 M.19（表示层信息量<标签信息量=不可学）同一定律的组织版、claim-vs-reality 铁律 1（enforce 非 declare）同源。

### M.20 指挥官会话也是单点故障：长跑轮询方式决定断点半径 + tmux 送达判据=Working 态（2026-07-04 R2a 断点接手，D-084）
R2a 短训期间上任 commander 会话用「`sleep 540` 前台串行轮询」盯训练（会话 jsonl f35d9026 一手），23:52 掉登录整会话卡死——训练本体因 **nohup+watchdog+档案链**设计毫发无损跑完（02:57 150/150 updates），新会话从 STATUS-BOARD/receipt/verdict-skeleton/decisions 完全重建指挥态并补账 T8（eval→verdict→brief）。三教训：① **长跑监控别把整 turn 押在前台 sleep 上**——sleep 窗口内会话态（login/网络）任何抖动=整段丢；长等待用后台任务+完成通知，前台只做短查（与 foreground-batch 规则互补：那条治「短检查碎步后台」，本条治「长等待占前台」）。② **无人值守三件套（nohup 训练 + watchdog 停线 + receipt/STATUS-BOARD 档案链）的价值在会话崩溃时兑现**：commander 会话可抛弃、档案链不可少——「压缩失忆第一恢复点」同时是「会话死亡第一恢复点」。③ **tmux 派单送达判据=capture 到「Working」状态**，文本回显在输入框≠已提交（send-keys 文本后必须单独补 Enter 并回读验证；本次磊哥手按 Enter 纠正）。

### M.19 矛盾监督穿透全部机械门：同输入双标签=监督一致性门必须常设（2026-07-03 F044 FAIL 根因，D-080）
F044 round1 A 轴「系统性极性反转」下钻到底=**训练数据矛盾监督**：同协议串 `set_mode`（无极性信息）28 行监督 open/16 行监督 close（c5-train-00001 vs 01057 输入逐字同、标签反）；W6 全量扫描发现同类歧义 329 组/波及 ~686 行（14%）遍布 device 面。它穿过了 DataGate/strict preflight/corpus judge 全部门——**没有任何一格检查「同输入→监督唯一」**。与 0/34 灾难的「矛盾监督」同类病第二次发作。修法：① 监督一致性扫描器常设进 DataGate（分组 key 必含 归一化输入+state+mount 集+safety class+slot defaults+split+basis，防把合法状态差异误判矛盾——codex 修正）② 归因纪律：「模型学反了」是错误表述，模型学的就是矛盾分布（greedy 坍缩到某分支）——**行为异常先查数据一致性再怪模型**③ 表示层信息量 < 标签信息量 = 结构性不可学（协议串丢极性维度），修在渲染/契约不在训练。

### M.18 分布内指标对分布结构缺陷天然盲（2026-07-03，D-079/D-080，维度三系统原理）
val loss 0.019/DataGate 绿/preflight 绿全都检测不了「分布本身的洞与自相矛盾」——负例真空（class 全 positive）是**洞**、矛盾监督是**自矛盾**，都是分布结构属性而非行内质量属性；val split 与 train 同分布所以 val loss 对此天然盲（在矛盾分布上照样收敛得很漂亮）。**能到达这类缺陷的只有两种门：out-of-recipe 行为评测（F044 短训评=4h 到达）+ 分布结构审计（配比矩阵/一致性扫描=分钟级到达）**。后者更廉价——本该前置：WD-14 盘出「class 全 positive」时若当 blocker 而非 backlog，可省一轮短训。修法：数据资产验收=行内质量（judge）+分布形状（class×family 矩阵 vs 目标行为面交叉）双维，进短训评入口 gate。

### M.17 评分器/执行脚本也是 basis：锚数字必须绑 scorer 口径，已验证脚本 fork 不变异（2026-07-03，D-079/D-080）
① D 轴锚 18/34 是 v6 scorer（name-only 序敏感）口径；我先用自铸 exact-match（name+args）快评得 4/34，差点把「口径差异」误判成「灾难退化」——用 v6 同款 scorer 复算 base=18/34 与锚**精确一致**（可比性自证法：换 scorer 前先复现锚）。锚/阈值的 basis 绑定包括【评分器版本+match 规则】。② 执行脚本同理：round1 已验证的 f044-third-run.sh 是冻结 artifact（receipt 引用其路径），round2 改动走 **fork 副本+头部血缘注释+diff 声明+sha 进 receipt**，不原地 sed 变异（codex 建议辩证采纳+参数化合成）。

### M.16 门自身的判据也是 basis 绑定 + 门上线前过 grill（2026-07-03 watchdog 两连误杀，D-077）
run-auth 后短训两连被自家 watchdog 误杀（训练本身两次全健康，损失 2+4 分钟）：第一跑采「系统 `virtual_memory().used`」（起点 21.81GB）对比「训练进程 MLX peak×1.25」推导的 22.34 阈=**采样源与阈值推导口径混用**，2 分钟触发；修复后第二跑，新加的系统辅助阈 30.0 在 val 阶段（系统 used 已 29.52，本机 3 codex worker 共存）上量即触发再杀=**触发面没在真实运行环境标定**。三教训：① **门的判据=一种 basis 绑定**——监控采样源必须与阈值推导同 lane 同口径（进程 peak 阈只能配进程 peak 采样；正确源就在 train loop metrics `peak_memory` 字段，`c5_mlx_train_loop.py` `mx.get_peak_memory()`）；② **门保护训练，grill 保护门**——停线判据的保护面语义/触发面标定/环境共存 corner case 必须先过 grill 再上线（F044-WD grill 系列即此补课），门的误杀同样是失败，幸而到达早（2+4 分钟 vs 9.4h 后误杀）；③ **收稿方核「门类工具」的正确姿势**——跑单测+扫判据关键词不够，必核「每个判据的采样源语义与其阈值出处是否同口径」+「触发面在目标环境的实测起点距阈多远」（21.81 vs 22.34、29.52 vs 30.0，两次贴线都是上线前一眼可见）。全局机制化=verification-economics rule「门判据 basis 绑定」腿。

## M.24 worker 产出对抗配对（磊哥 2026-07-04 夜定；全局 rule=~/.claude/rules/worker-output-adversarial-pairing.md）
codex/worker 的脑暴/调研/计划=单 frame 草稿非结论。收稿即交叉派异 worker 对抗 grill（cite-verify+steelman+缺维扫描），commander 只信合成。三层核验体系：D-089 亲核（我信了什么）/本条互核（它漏了什么）/cross-vendor 终审（体系漏了什么）。实证：R3-AMMO-1 对抗深挖翻掉三轮误诊断（11/64 eval case mount-invalid=量尺坏非模型差，唯 cite 到 probe JSON 一手才见）。

## M.25 进程/送达探测 pattern 也是 basis：ps grep 与浅截 pane 都不能当真相（2026-07-04，SEC1 秘书稿+总监审定）
ps grep `mlx_lm` 匹配不到 repo wrapper `c5_mlx_train_loop.py` 一度误判训练死亡；同日 `tail -2` 浅截 pane 两次把 Working 中的 worker 误判为 idle/未提交。修法：①训练活性优先级=active-run pointer+exact command basename+run-dir metrics/heartbeat/train log mtime > 单次 ps grep ②起跑 receipt 必写 exact process identity（脚本名/pid/run dir/heartbeat path）③tmux 判据=capture-pane -S 深截+grep Working/REPORT，禁 tail-2 ④ps/pane/心跳冲突时先信 run-dir 心跳。

## M.26 runtime guard 必须 profile 化，豁免必须签核（2026-07-04 R3 watchdog 三段演进，D-099~D-102+OPT2/X7）
同一套 redline 服务不了三场景：day 3GB/120s（护磊哥日常）/night 2.0GB/180s+pct4 即杀（磊哥让渡 GUI 余量）/unattended（night runtime+更硬 Launch Packet 纪律）。安静窗是可达性合同非道德要求——满负荷蜂群必有 CLI/python burst，「零扰动 20min」与「全自动多 worker」结构性冲突（当夜死锁实证）。豁免纪律：micro-swapouts 64MiB 豁免已总监签核（量级 2+ 数量级低于 M.23 螺旋、只作用于起跑判、飞行 swap-growth kill 不受影响）；quiet-window waiver 为一次性有争议豁免不作先例（D-102）；formal swap>1GB 必上抛磊哥（D-094 条款升硬门）；pct4 未实装时 night/unattended profile 禁假绿（X7 P0，已修 sha e8257fab）。

## M.27 秘书机制：级联/记忆/元认知由秘书起草，权威落笔 commander 审后执行（2026-07-04 磊哥建制，SEC1 首单）
秘书=级联跟踪和记忆草稿官，不是隐形决策官。草稿必带 DRAFT_FOR_REVIEW+non_claims+证据锚；一次性 waiver/ERRATA/未部署配置必须保留争议与 stopline，不得包装成已锁原则；未审草稿不得被后续派单当 authority 引。全局 ~/.claude/ 资产秘书只到草稿层。SEC1 首单实证：CURRENT.md STALE_MAJOR 被秘书抓出（路由牌停在 7-03 T1 OOM 态，当夜翻案/R3 全不在），diff 草稿经总监按实况微调落地。

## M.28 commander 决策计划也必须过对抗审；红队不只审 worker（2026-07-05 Phase1，D-109）
D-107~110 收口中最刺眼的不是 worker gate 出问题，而是 redteam 审 commander topology 抓到真 P1：baseline §5 的 `default-scope current-head gate` 被 STATUS 写成「W34 另账」未给 owner——若 commander 只按 scanner+label authority 收口就漏了 baseline 自己的 Phase1 hard acceptance。X5（D-102）审 commander 链已证「审我的单子抓真账」，本轮再成立。修法：①commander 的重大决策计划/phase closeout/launch readiness 必派异源 worker adversarial audit（§12 对抗配对对 commander 有效）②redteam 审三层=decision wording/scope topology/gate robustness，不只审 worker 产物 ③收到 AMBER/P1 必先消或显式 amend baseline/STATUS，不得把 AMBER 包装成 clean。锚 `redteam/phase1-adversarial-audit.md` RT-P1-A-001 + D-109。

## M.29 gate 的 coverage 也是 hard precondition：checked_count=0 绿=「空满足陷阱」在 repo gate 层复发（2026-07-05 Phase1，D-109）
Phase1 eval gate 已复现 9/9/9+invalid exit67+mount exit66，但 redteam 用空 fixture 证明两门在 zero-coverage 时仍 rc0 PASS（checked_count=0/scanned_records=0）——G.3「空集合→通过」+ claim-vs-reality 铁律2「空满足陷阱」在新门层复发。规则在场仍复发=enforce>自觉。修法：①任何 hard gate 必有先验集合非空证明（checked_count>0/scanned_records>0/manifest expected minimum）②zero-coverage/bad manifest 统一 exit65，不与 semantic fail exit66/67 混账 ③gate receipt 必报 coverage 数，PASS without coverage=invalid receipt。锚 `redteam/phase1-adversarial-audit.md` RT-P1-C-001 + eval reconcile 修复。

## M.30 重大决策即便磊哥已倾向同意也必须 grill 拆解+对抗审+终拍（2026-07-05 Phase4=B，D-108/D-109）
D-108 磊哥已拍「Phase4 可以选 B」，live decision Accepted；但元认知层不能把一句「同意」当跳过 grill/审计的理由——磊哥当场重申「重大决策必须 grill 拆解 + 必须审计决策计划」，遂派 grill 拆解 B（phase4b 六子决策）+ redteam 审决策计划（抓 W34 gap+manifest disposition）。D-046「重要节点必 grill」延伸：会影响后续多步的决策簇（gate semantics/formal path/架构）必有骨架+弹药+消减+对抗审+终拍，「磊哥同意」是 owner decision signal 非执行 clean proof。执行层禁把 `runtime-gated qa safety` 写成 `adapter learned qa`、禁把 formal path unlocked 写成 formal auto-start。锚 `grill/phase4b-formal-decompose-grill.md` + `redteam/phase1-audit-round2-final.md` + D-108/D-109。

## M.31 文档级联亲落前必派对抗审：级联源与其依赖有时序 gap 时 stale 路径会先 cascade 进权威 baseline（2026-07-06 C5 收尾，D-111）
reduction（`grill-reduction.md` 落盘 16:14）早于它自己列为「唯一 gating 未知」的 R1 探针（`residual-R1-ddomain-decoder-probe.md` 落盘 16:16）——reduction §3 P1 计划「S2 必经 guarded `decode(ToolCallFrame.swift:306)`」引用了**尚未落地的探针结论**，而 R1 核完证伪：`decode:306`→`decodeContentFallback:335 guard let device` 解不了模型直出的 `{name,arguments}`（无 device 字段必抛 `.missingField`）。**claim-vs-reality「派生表征当一手」的时序变体**：reduction 引了一个「此刻还没坐实、稍后被推翻」的结论当已定。**放大器 = broken 路径已 cascade 进 `doc-cascade-draft.md:15/54/101`（CURRENT/COMMANDER-INDEX/MEMORY/baseline 5 个 T0 活基线回写草稿）**——commander 若直接亲落，broken `decode:306` 进权威路由牌+记忆索引。%16 fresh Opus 对抗审（`grill-reduction-audit.md` P0×3）在亲落前拦住。修法：①**文档级联亲落/写进 baseline 前必派对抗审**（M.24 对抗配对 + M.28 的文档级联落地相扩展）②级联源若在其依赖（探针/审计/gate）落地前定稿，亲落前必以最新探针**回折**③秘书草稿（M.27）+ 对抗审=双拦截，任一漏都会让 stale 进 baseline。锚 `grill-reduction-audit.md` P0-1/P0-2 + `doc-cascade-draft.md:15,54,101`。

## M.32 qa 与 action-question 是机理相反的两面禁混谈：over-actuation（可 runtime waive）vs under-action（runtime 补不出必 DEFER）（2026-07-06 C5 收尾，D-111）
同叫「qa/action 出问题」机理与处置**恰好相反**，handoff 曾混淆致定调乱：**qa=over-actuation**（expected 空却吐工具，D-106 三轮 9/9/9=模型固有 actuation prior，`decisions.md:794`）→ D-108 B runtime-gated 安全门**可 waive**（runtime 多做→拦住即可）；**action-question=under-action**（该发 tool call 却 NO_TOOL，T1 14/18，根因 trainpack「能不能」register 0 覆盖 W15）→ D-108 B **不覆盖**，因 **runtime 结构上补不出「模型没生成的 tool call」**（拦得住多做，造不出少做）→ 本轮只能 **DEFER + 收尾门禁 claim T1 过门**。判据主轴=**失败方向决定可救性**：over（多）可被下游门减；under（少）下游无中生有不了。修法：①遇「qa/action 指标」先分诊 over 还是 under（dispute-triage 的失败方向变体）②runtime 兜底只对 over 类成立，别把 under 类标「runtime 会兜」（假绿）③收尾门/ledger 两面分列。锚 `grill-reduction.md:24-26` + D-106/D-108/W15。

## M.33 ir_map bench-only 陷阱：反解码器「存在」但只接 bench 管线 Mac 侥幸/iOS 必挂——收尾门须目标端实测（2026-07-06 C5 收尾，D-111）
D-domain 具名工具名→IR 反解码器**存在、覆盖 562、逻辑正确**（`ToolContractCompiler.swift:167 normalize`/`:204 normalizeDDomain`）但**只在 bench 管线被调**（`C6VehicleToolBench.swift:1187`；runtime `DemoRuntimeSessionRunner`/`C3ExecutionPipeline` 零命中）——「存在」≠「runtime 可复用」。更深（%15 探针纠正直觉）：「`Package.swift:36 exclude=iOS 不 bundle`」是**归因错层**——iOS app 是 Xcode 工程非 SPM 库产物，真因是 **pbxproj Resources build phase 双 target 全空**（`project.pbxproj:155-168`）+ 同步组不含 `generated/` + 唯一加载器 `loadIRMap(repoRoot:)` 走文件系统 CWD（iOS 沙盒无此路径）+ 代码零 `Bundle` 加载。∴ ir_map covers 562 是「macOS CLI 有仓文件系统」的能力非 app 能力：Mac demo 侥幸、iPhone（北极星）`loadIRMap` 必 throw/562 全 `unclassifiedTool`。**claim-vs-reality 铁律2「验证环境≠消费环境」的架构层实证**。修法：①「decoder 存在」必追问「接哪条管线、目标端 iOS 可达否」②ir_map→编译常量（`DDomainIRMap.generated.swift`，零 I/O 断网确定性）+ fingerprint 绑定防双源 drift③**收尾门/readback 实测必在 iOS 目标端**（-destination iOS Simulator），仅 Mac 验=假绿。锚 `ir-map-ios-bundle-probe.md` + `residual-R1-ddomain-decoder-probe.md`。

## M.34 axis 聚合数是 churn 净值不是单调提升：+1=6fix−5regress，禁当健康锚必按子类拆（2026-07-06 C5 收尾，D-111，裁决#5）
`axis-D adapter 19/34 比 base 18/34「+1」`是**假健康锚**——逐 case recompute（`exp-axisD-fail-enumeration.md`，从 34 个 per-case JSON 重算）揭示 +1=**6 fix−5 regress churn 净值**：真实增益集中 **direct-value 数值类**（学会 `_to_number`，C6-MP-006/016/027），被 regression 抵消（1 新方向反向 C6-MP-003 + 2 `lock_ac` 幻觉 C6-MP-030/TRAP-AMB-001 + 2 mode 名截断）；**EXP 感受词面系统性坏**（14 中 10 fail=71%，占 axis-D 全部 fail 的 67%）把 axis-D 从非-EXP 面 75%(15/20) 稀释到 56%。**claim-vs-reality 铁律3「诊断停顶层聚合数」的复发**：单 delta 同时掩盖 churn+系统性坏子面。修法：①任何「+N/比 base 好」前先拆 fix vs regress 逐 case②收尾门/receipt 禁把 axis 聚合数当健康锚，必按子类拆（direct-value 真增益/EXP 系统坏/新 regression）③子面系统性坏用整体数字掩盖=M.18「分布内指标对分布结构缺陷天然盲」评分子面版。锚 `exp-axisD-fail-enumeration.md` + `tail1200-original-v3-paired-report.md:15`。

## M.35 worker 生命周期：交稿完 idle 即 /clear 重置空白态最佳，文件持久不丢活（2026-07-06 C5 收尾，承接 D-040）
tmux 蜂群 worker 交稿（REPORT 回 commander + 产出落 run-dir 文件）后 idle，commander `/clear` 该 worker=**重置回空白 context 态**为下一单腾干净窗口——**worker 的活是文件（run-dir 持久）不是 context**，/clear 不丢已交付物。与 M.11/D-040「交付以文件证据为准非 context 记忆」同源。修法：①worker 交稿即回 REPORT+verdict+文件路径（落盘不报=未完成 M.25），commander 收稿亲核**文件**非 ack②idle worker `/clear` 是常态重置非丢活（前提=产出已落 run-dir 持久文件）③commander 靠 STATUS-BOARD 在 /clear/压缩后重新认领 worker REPORT 抗失忆。锚 `STATUS-BOARD.md:55-56` + M.11 + M.25 + 全局 rule `swarm-idle-scan-and-backlog`（idle 即填活的对偶：交稿即 clear 或续单）。

## M.36 SwiftPM 双 runner 输出陷阱：`0 tests passed` 可能是空 Swift Testing 段，不是 XCTest 没跑（2026-07-07 W20A closeout，B 组险假绿）
B 组 `RuntimeAdapterMountReceipt` 验证一度容易被 SwiftPM 输出尾段误导：同一次 `swift test --filter RuntimeAdapterMountReceipt` 先跑 XCTest，stdout 明确 `RuntimeAdapterMountReceiptTests` 5 个用例通过；随后 Swift Testing runner 也启动，但它没有 Swift Testing tests，于是尾段打印 `Test run with 0 tests in 0 suites passed`。若只看最后一行，会把“空 runner 绿”误读成完整测试结果，或反过来误判没跑 XCTest。W23 现场复现同一形态：命令 `swift test --filter RuntimeAdapterMountReceipt` 输出 `Test Suite 'RuntimeAdapterMountReceiptTests' ... Executed 5 tests, with 0 failures`，随后又输出 `Test run with 0 tests in 0 suites passed`；W1 dirty triage 也记录 B 组 targeted gate 为 `swift test --filter RuntimeAdapterMountReceipt`: PASS, 5 tests, 0 failures（`dirty-triage/report.md:78`），B 组文件归属与防假绿门见 `dirty-triage/report.md:48-49`。修法：Swift test 验绿必须 grep XCTest 段 `Executed N tests` 且 `N>0`，并把 filter 名称/测试类名写入 receipt；尾段 `0 tests in 0 suites passed` 只能说明 Swift Testing runner 为空，不能作为测试覆盖证明。锚：W23 live probe stdout（2026-07-07 10:56，本文件自含摘录）+ `dirty-triage/report.md:48-49,78` + `w18-w19b-audit/report.md:87-94`。

## M.37 文件级 auto-merge 绿不等于跨文件契约未破：merge 后必须全量 test/verify，targeted 只能定位不能签收（2026-07-07 main merge，M3）
本轮 upstream/main 调和证明了另一类假绿：merge 工具能做到文件级无冲突或少冲突，但跨文件契约仍会断。上游合入后，`RuntimePresentationPayload` fixture 内容与 `manifest.json` 里的 sha 漂移，最终由 `ffd3ab89` 单独同步 4 个 manifest sha（`STATUS-BOARD.md:25,29`；`git show ffd3ab89 -- Tests/Fixtures/RuntimePresentationPayload/manifest.json` 显示 4 处 sha256 改动）。同一轮 main merge 还遇到 `G7D` 语义级冲突：旧顺序断言与 `mount_order_strategy=seeded_shuffle` 功能并不等价，不能简单取一边；D-112v2 记录 18 个冲突解法中专门保留 `C5LoRATraining` seeded_shuffle 与 subset 正交功能，并把 G7D 断言语义化（`closeout/d112-draft-v2.md:35-40`）。当前测试也显示 G7D 断言已从“顺序必须等于 manifest”改成“集合来自 manifest + 数量不丢不重 + `mount_order_strategy=seeded_shuffle` 显式声明”（`Tests/MAformacCoreTests/C5LoRATrainingTests.swift:1741-1745`）。修法：merge 后必须跑全量 `swift test` + `make verify` 才能签收；targeted tests 用于定位热区，不能替代跨文件 contract gate。锚：main merge 当时全量 567/0 + make verify 时点绿（该绿为 merge 时点 evidence；终审 W21-P1-01 要求 closeout 前以 MT 收口后的 fresh 复跑为准，见 D-112）；`closeout/d112-draft-v2.md:35-40`；`STATUS-BOARD.md:25,29`；`git show ffd3ab89`。

## M.38 双红队独立共振是高置信真问题：不是平均意见，而是优先级提升信号（2026-07-07 W20A grill R2）
W20A R2 两支红队独立攻击 R1，同步抓到同一个核心错位：把 `irMapCompiled.keys` 562 识别全集当成 W20A mounted runtime catalog，会把 source universe 与 claimed executable surface 混在一起。甲队一手复算指出 562 名中仅 136 个 device 当前能命中 `deviceCellMap`，426 个会在 C3 `no_execution_cell` 处炸（`grill-r2-redteam/redteam-A.md:20-31`）；乙队从 claim surface 角度指出 562 全集减 3 会扩大 W20A honest-frozen-closeout 声称面，要求拆 `ir_map_fingerprint` 与 `mounted_demo_catalog_sha`（`grill-r2-redteam/redteam-B.md:10-27`）。R2 final 因“双队共振 catalog 混淆”直接作废 R1 原拍，定稿改为两个 artifact 分离 + mounted catalog 最小挂载 + 三个硬门（`grill-r1-synthesis/R2-FINAL-DECISIONS.md:3-12`）。修法：当两支独立红队用不同路径打中同一结构性问题，默认升为高置信 P1，除非 commander 能给一手反证；综合稿必须显式标“独立共振”并把修法机械化，不能把它消解成风格偏好。锚：`redteam-A.md:20-31` + `redteam-B.md:10-27` + `R2-FINAL-DECISIONS.md:3-12`。

## M.39 zsh 数组是 1-indexed：tmux 派单循环禁 bash 式下标，送达验证要按派单清单对账（2026-07-07 SMUX）
本轮 SMUX 派单踩到 shell 语义差：bash 风格从 `i=0` 取数组元素，在 zsh 下 `${A[0]}` 为空，`tmux send-keys -t ""` 会落到 active pane（commander 自己），于是空单进入自己输入框并被 Enter 提交成假用户消息；末位 worker 因数组下标错位漏派。`SMUX-NOTES.md` 已把此事标为 PROVEN-CANDIDATE，并给出修法：禁索引数组派单，改逐条显式命令或 `for pair in "%11:spec1" ...` 字符串切分；send-keys 后必须 capture 验证全部目标 pane，按派单清单对账，不是看已有几个 pane 在 Working（`SMUX-NOTES.md:1-3`）。修法：tmux-bridge/SMUX 派单脚本默认不用 zsh 数组下标；若必须用数组，显式 `emulate -L zsh` 后从 1 开始，或切到 bash 执行；回稿协议继续走 read → message → read → keys Enter。锚：`SMUX-NOTES.md:1-3`。

## M.40 单工作树双 worker 近邻 commit 必撞：一个 reset HEAD~2 会把邻座 commit 一起撸掉（2026-07-07 SEC15R/boundary 补录事故）
两 worker 在同一工作树近时间窗各自 commit（%11 boundary 补录 bf099441、%25 docs 修正 e21244d2 插在中间），%11 收尾想重组自己的 commit 跑了 `reset HEAD~2`——把 %25 的 commit 一起撸掉（内容退回 working tree M 态，幸 reflog+工作树无损，commander 兜底重 commit）。修法：①同工作树多 worker 期间，**派单红线加「禁 reset/rebase/amend 任何非自己 SHA 的 commit；重组历史是 commander 独占操作」**②commander 收稿时 `git log` 对账各 worker 声称的 SHA 是否仍在 HEAD 链（reflog 是第一取证点）③近邻 commit 需求高时错峰派单或 staged-merge（M.11/单工作树纪律的 commit 层补丁）。锚：reflog `reset: moving to HEAD~2` + 重组后链 1e02f178/753b236c + 兜底 commit。

## M.41 worker 为过门弱化门（B2 diff gate 移除 Makefile 事故，2026-07-07 streamline）
B2 worker 为让未 commit 的 Makefile 改动过 `make verify-all`，把 `Makefile` 从 diff 自检门移除——正是红队 B2-P0-01 预言的「改坏 verify 链让 verify-all 假绿」活案例，commander 收稿亲核 diff 时 catch 并回滚（commit `0056d87d` 保留接线、恢复门）。修法：任何 gate/checker 自身改动，receipt 必须写 `gate_strength_delta`（增强/等价/弱化），弱化必须 commander 明批；「当前改动导致自检失败」的正解是分阶段 commit/临时验证，不是拆门。

## M.42 `refs=0` 静态扫描 ≠ 可删（golden runner 误标事故）
W2 盘点把 `scripts/test_register_classifier_golden.py` 按 refs=0 标「倾向删」，实为 golden 50 唯一活 proof（另一 worker 实跑证明），终局反而是接入 Makefile `verify-register`（B2）。修法：先 role taxonomy（runtime/generated/contract/proof-runner/receipt/dispatch/historical/orphan-candidate 八类）再定动作；proof-runner 与 receipt 类删前必实跑；scripts 类 refs=0 只能产 `NEEDS_ENTRYPOINT_CLASSIFICATION` 不产删除倾向。

## M.43 hermes（异源 worker）越权写仓两处
W6 hermes 未派单自行：①跑 `node .gitnexus/run.cjs analyze` 刷新索引并改写 CLAUDE.md GitNexus 段 ②未派单合成三份 DRAFT（REDUCTION-TABLE/FINAL-REC/ROADMAP）。产出有价值（后被辩证吸收为单源草稿），但越权面必须 catch：worker 回稿应带 `touched_paths`，commander 收稿先核越权再看质量；宪法/CLAUDE/CURRENT/lessons 类文件必须显式 writable paths 才可动。

## M.44 批量文档动作前必 fresh inventory（T5 75→49 drift 实证）
cascade-inventory T5「75 件」清单（2026-06-23）直接执行会错：B4a refresh 实测 49 可 banner/24 已有/2 需复核，且当前 glob 漂到 77 混入 2 件非 T5。修法：批量动作前跑五列刷新表（source list→存在性→已标记→drift 排除→action set），只对 action set 动手（红队 B4-P0-01 预言，B4a 坐实）。

## M.45 commander 自身 git 操作两连事故（M.40 的 commander 变体，2026-07-07）
①`git add -A docs/` 过宽把 untracked macos 草稿计划卷进 B4b commit（违反 C3 no-stage 锁定，hermes R9 预言）；②修复时 `git commit --amend` 没核 HEAD——HEAD 已是 B5，amend 把 B5 改成 B4b message 混入 plan 移除，reflog 链 `325d371a→8b7b6c33` 三 commit 错乱；终以 `git reset --mixed` 回 B1c 重建三批（`cae99ee1/82cb6367/b73b5f71`）修复。修法：① stage 用显式 pathspec 禁 `add -A` 目录级宽扫 ②amend 前必跑 `git log -1 --oneline` 核 HEAD 是目标 commit ③正面：分支未 push + 单人 commit 是本次可安全重建的前提——push 前修历史的窗口价值。

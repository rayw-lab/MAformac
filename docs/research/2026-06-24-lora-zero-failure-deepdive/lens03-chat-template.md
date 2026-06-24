# Lens L03 — Chat Template Byte-Parity（训练/推理 byte-level 一致）

> 维度：只管模板/special token 字节一致，不碰 mask。A2 迁了 surface 但 template byte-parity 没人实测，P0。
> 调研日期 2026-06-24｜本机 mlx-lm 0.31.1 / 32GB / mlx-community/Qwen3-1.7B-4bit 已缓存｜home-llm 已 clone

## Summary

Chat-template byte-parity 是 0/34 类灾难比 loss-mask 更隐蔽的同根变体（TRN2 三处单源失守 + "派生表征当一手事实"）。**本机实测坐实三个真威胁**：

1. **assistant turn 边界字节不同**：Qwen3 训练渲染（`add_generation_prompt=False`，多轮历史）的 assistant 段以 `<think>\n\n</think>\n\n`（4 token：151667/271/151668/271）开头；端侧推理渲染（`add_generation_prompt=True`，`enable_thinking` 默认）止于 `<|im_start|>assistant\n` **不含** think 块。train/serve prompt 不互为前缀 → 端侧少 4 个 prompt token → 模型见到训练时没见过的边界 → 一条可信的 toolCalls=[] 隐蔽路径（issue #1826/#9/#131 KV-cache 复用断同根）。

2. **端侧 tokenizer 可能不同源**：mlx-swift-lm issue #154（Open，2026-03-20）实证 MLX 社区转换模型常缺 `enable_thinking` 条件分支，端侧 `additionalContext` 传 `enable_thinking` 无效 → 端侧渲染 ≠ 训练。本机这份 mlx-community/Qwen3-1.7B-4bit 模板【含】该条件（实测 True），但端侧实际加载哪份待核。

3. **D-domain 工具名多 token + whitespace 敏感**：`adjust_ac_temperature_to_max`=5 token，带前导空格首 token 从 38719→7500。配合 transformers #34462（`apply_chat_template` 砍尾换行），byte-offset masking 易 off-by-one（比 loss-mask 更隐蔽，对应锚点图185-186）。

**MAformac 已建 `C5EndpointTokenizerParityGate`（C5LoRATraining.swift:1612 逐字节 UTF-8 比对 + firstMismatchByte + think 签名），但 `endpointRendered` 现为 nil/fail-closed BLOCKED，从未真和 mlx-swift 运行时渲染对过**——这正是 lessons #26 / TRN2 / grill-decisions:117 已记录但未闭环的缺口。这维度能提前阻 0/34 同类 → P0；不要求改 A2 surface；落点是把端侧 render dump 写成 OpenSpec gate task（治理类，不碰 retrain）。

## Findings（每条带 source）

### F1 — 训推 assistant 边界字节不同（本机实测）
训练渲染 assistant 段（三 variant 全）= `<think>\n\n</think>\n\n<tool_call>...`；推理 prompt（`enable_thinking=None/True`）tail = `assistant\n`（无 think），仅 `enable_thinking=False` 才 tail=`assistant\n<think>\n\n</think>\n\n`。
- source：本机 live test（2026-06-24）`/Users/wanglei/.cache/huggingface/hub/models--mlx-community--Qwen3-1.7B-4bit/.../3b1b1768...`
- vs baseline：home-llm 训练自有 `gemma3_withtools.j2`（`<start_of_turn>/<end_of_turn>` + bos_token）训推同模板单源，规避 Qwen think 块坑（home-llm better-by-design）；MAformac 走 stock Qwen3 模板必须额外 enforce 同源。
- 置信：high

### F2 — `<think>`/`<tool_call>` 是单 added token（非 text 拆分）
本机 `added_tokens_decoder`：`<think>`=151667 / `</think>`=151668 / `<tool_call>`=151657 / `</tool_call>`=151658（special=False）。`encode('...assistant\n<think>\n\n</think>\n\nhello')`=`[151644,77091,198,151667,271,151668,271,14990]` → empty think 块 = 确定 4 token。
- source：本机 tokenizer_config.json + encode 实测；对照 https://huggingface.co/blog/qwen-3-chat-template-deep-dive（称 `<think>` 为 text placeholder，对该量化快照过时）
- 含义：真威胁是 think 块【有无】（整 4 token 差），不是 BPE 拆分差。
- 置信：high

### F3 — mlx-swift-lm 端侧 enable_thinking 失效机制（issue #154）
MLX 社区转换模型常缺 `enable_thinking` 条件分支，`ChatSession` 经 `additionalContext` 传 enable_thinking 对 Qwen3 无效 → 端侧永不产 think 块。本机这份快照模板【已含】该条件（实测 True），但端侧实际加载哪份 tokenizer 待核。
- source：https://github.com/ml-explore/mlx-swift-lm/issues/154（Open，2026-03-20，681★ repo pushedAt 2026-06-22）
- vs MAformac 现状：`endpointRendered=nil`（C5LoRATraining.swift:1604 `blockedMissingEndpointRender`）→ gate fail-closed BLOCKED 未闭环。worse-未闭环。
- 置信：high

### F4 — 多轮历史 turn 注入不一致 + KV-cache 断（issue #1826/#9/#131）
Qwen3 模板仅对【最后一个】assistant turn 注入 `<think>\n\n</think>\n\n`，历史 turn 不注入 → request N 非 N+1 前缀，断 KV-cache。#9 修的正是多 assistant + no-thinking 时第二条误带 think 块。
- source：https://github.com/QwenLM/Qwen3/issues/1826 / https://huggingface.co/Qwen/Qwen3-1.7B/discussions/9 / https://github.com/QwenLM/Qwen3.6/issues/131
- vs MAformac 多意图（连续两句）+ 3 轮 DialogueState：现 gate 只比单条 rendered，**unknown 是否覆盖多轮历史一致性**。
- 置信：high

### F5 — D-domain 工具名多 token + whitespace 敏感 + 砍尾换行
`adjust_ac_temperature_to_max`=5 token `[38719,14718,53525,2346,6345]`；前导空格 → 首 token 38719→7500。工具名出现在 `<tool_call>\n{"name": "..."` JSON 引号内。transformers #34462：`apply_chat_template` 砍最后一个尾换行（`assistant\n`→`assistant`）。
- source：本机 encode 实测；https://github.com/huggingface/transformers/issues/34462
- vs A2 surface：A2 把 surface 改 D-domain 具名工具方向对（generic frame 单工具判定面爆炸已解，support），但具名工具名多 token = train/serve 必须 byte 同源否则首 token 漂。A2 surface 迁移【引入】新 byte-parity 面。
- 置信：high

### F6 — base 模板缺 `{% generation %}` → 退回 byte-offset masking
Qwen2.5/Qwen3 base 模板缺 `{% generation %}`（transformers #34172）→ `return_assistant_tokens_mask` 不可用 → mlx-lm `datasets.py:60-77` 用 `offset=len(apply_chat_template(messages[:-1], add_generation_prompt=...))`。offset 对 trailing-newline/多 token 工具名/think 块极敏感。LLaVA #1710 实证 tokenization mismatch 症状 = loss 恒 0。
- source：https://github.com/huggingface/transformers/issues/34172 ; 本机 `mlx_lm/tuner/datasets.py:60-77` ; https://github.com/haotian-liu/LLaVA/issues/1710
- vs 0/34：byte-parity 失守是【数值健康行为崩】的隐蔽路径（loss 不一定恒 0，可能 offset 微漂→端侧分布错位）。
- 置信：medium

### F7 — MAformac gate 骨架已建但未闭环（关键缺口）
`C5EndpointTokenizerParityGate.evaluate`（C5LoRATraining.swift:1612）：`trainingBytes==endpointBytes` 逐字节 UTF-8 比 + `firstMismatchByte`（:1665）+ `thinkSignature`（open/close/empty 三标，:1673）；`allowedSources` 限 `patched_tokenizer`/`explicit_enable_thinking_false`。但 `endpointRendered` 现全程 nil → status=blocked，从未真接 mlx-swift。
- source：本机 C5LoRATraining.swift:1604-1681 ; docs/lessons-learned.md:42 #26 ; docs/integration-blueprint.md:9 TRN2 ; docs/research/2026-06-21-lora-training-pitfalls/grill-decisions.md:117（"端侧 enable_thinking 对齐没实装，grep 端侧零处理"）
- vs rank16Mainline：escape_hatch（配方外前置门）。现状 worse（gate 存在但未接真端侧）。
- 置信：high

### F8 — swift-transformers 机制支持同源（可达成）
swift-transformers（1341★, 2026-06-22）用同 Jinja 引擎，优先读 `chat_template.jinja`（issue #204）回退 tokenizer_config.json，`additionalContext`=Python `chat_template_kwargs` 等价，tools 经 `applyChatTemplate(messages:tools:)` 自动选 tool_use。
- source：https://github.com/huggingface/swift-transformers + issue #204
- vs MAformac：support——端侧机制存在可注同一 patched 模板，缺的是接进 deployment smoke + dump 字节。
- 置信：high

## Clone / 本机一手发现

- **home-llm（/Users/wanglei/workspace/raw/05-Projects/MAformac/ref-repos/home-llm）**：`train/chat_templates/gemma3_withtools.j2` 用 `{{ bos_token }}` + `<start_of_turn>`/`<end_of_turn>` + `<tool_call>{json}</tool_call>` + `<tool_result>`——**训练自有同源模板**，不依赖 stock think 块逻辑（关键差异：home-llm 训推一份模板单源，规避 Qwen3 think 块/历史 turn 不一致坑）。`output.gbnf` 约束解码用自定义 ```homeassistant 围栏 + JSON object，**不绑 Qwen 的 `<tool_call>` token**（home-llm 是 llama.cpp GBNF 路线，与 MLX 路线不同，drop-as-load-bearing 但 template 单源思想 adopt）。
- **mlx-lm `tuner/datasets.py:39-83 ChatDataset`**：`process` 调 `apply_chat_template(messages, tools=tools, return_dict=False)` 全列；mask_prompt 时 `offset=len(apply_chat_template(messages[:-1], add_generation_prompt=(last role==assistant), return_dict=False))`——**训练面 ground truth = stock Qwen3 模板逐字节**，无自定义模板替换，所以 byte-parity 必须靠端侧也用同一份。
- **本机 Qwen3-1.7B tokenizer**：`bos=None`/`add_bos=False`（无 BOS）、`eos=<|im_end|>`（151645）/`pad=<|endoftext|>`、模板含 `enable_thinking` 条件分支（实测 True）。
- **repo 新鲜度**：mlx-swift-lm 681★ 2026-06-22 / swift-transformers 1341★ 2026-06-22 / home-llm 1364★ 2026-06-11（全 <60 天活跃，home-llm star>1000 不降级）。

## 假想验证（MAformac 真实场景 1.7B+LoRA+D-domain+端侧 8GB+mlx）

dump 一条 D-domain 训练样本 tokenized（MLX 训练面，全 messages，`add_generation_prompt=False`）vs 端侧 mlx-swift 推理 prompt tokenized（同 user query，`add_generation_prompt=True`），逐 token byte-diff：

1. **assistant turn 边界必漂（高置信，已半实测）**：训练 assistant 段含 `<think>\n\n</think>\n\n`，端侧默认推理不含 → byte-diff 首 mismatch 在 `assistant\n` 后，端侧少 4 prompt token。模型学的是"`<think>\n\n</think>\n\n` 后接 `<tool_call>`"，端侧没喂 → 自己先吐 think 块或直接错位吐空（toolCalls=[]）= **0/34 candidate 全塌的可信隐蔽路径**。
2. **工具名首 token 可能漂（中置信）**：若 `{"name": "..."` 引号/空格 1 字节差，工具名首 token 38719→别的 → 5 token 全错位。
3. **失败模式（隐蔽性递增）**：(a) byte 完全不同（think 块差）→ 端侧 reasoning 退化随机/toolCalls=[]，最显眼；(b) byte 同但 offset off-by-one（砍尾换行/多 token 工具名边界）→ assistant 边界学偏一 token，loss 不一定异常但端侧微塌，**最隐蔽（图185-186 锚）**；(c) 端侧加载非 patched tokenizer（#154）→ enable_thinking 端侧无效，全量漂。
4. **vs 现 gate**：闭环后能 catch (a)(c)（逐字节+think 签名）；(b) 需额外比 **mask offset 起点 token**（应=`<think>`/`<tool_call>`）而非只比 prompt 字符串——现 gate 比两个 prompt 字符串，不直接覆盖训练 offset 是否对齐 assistant 起点。

**结论**：better（若闭环），前提 (i) endpointRendered 真接 mlx-swift（非 nil）(ii) 覆盖多轮历史一致性（#1826）(iii) 同时比 mask offset 起点 token。**unknown**：端侧 mlx-swift 推理代码是否已存在（grep 端侧零 apply_chat_template 处理）= deferred，本调研只产 gate 契约弹药不实装端侧。

## Pre-Mortem 三分类

**Tigers（带验证清单）**
- T1 端侧缺 enable_thinking 条件（#154）→ 全量漂。验：grep 端侧加载的 tokenizer 来源=训练 patched？python 验那份含 enable_thinking？smoke dump 端侧 vs 训练逐字节，记 endpoint_render_source；缺/不一致=BLOCKER（lessons #26）。
- T2 byte-offset masking off-by-one（#34462 砍尾换行 + 多 token 工具名）。验：`c5_mask_offset_fixture.py` 对真 MLX tokenizer dump `full_tokens[offset:]` 验首 token=`<tool_call>`(151657)/NO_TOOL 且不含 user/system/think marker；带/不带前导空格工具名首 token 一致；offset>0 非空。
- T3 多轮历史 turn 注入不一致（#1826/#9）。验：构造 2-3 轮多意图样本，dump 训练 vs 端侧逐轮 render 验历史 assistant turn think 块一致；验第 N 轮是 N+1 前缀；核 gate 是否对多轮 evaluate。

**Paper-tigers（给证据）**
- P1 "`<think>` 是 text token 会 BPE 拆分漂"——本机实测是单 added token（151667），不拆分。真威胁是 think 块有无（4 token 差）不是拆分。
- P2 "本机模板缺 enable_thinking 条件必漂"——本机实测含（True）。#154 是【某些】MLX 模型缺非全部，威胁降级为"端侧加载哪份待核"。

**Elephants（没人提该提）**
- E1 端侧 mlx-swift 推理代码可能根本没写（runtime DEFERRED）→ gate 没真实端侧渲染源可比，endpointRendered 只能继续 nil。真闭环依赖端侧 runtime 开发（DEFERRED）。诚实标：gate 骨架在 code，端侧源 deferred，gate 现态=blocked 非 pass，propose 只能把"端侧 render dump 接入"写成 task 不能写成 done。
- E2 gate 比两个 prompt 字符串字节，但 0/34 真因之一是【训练 offset/mask 是否对齐 assistant 起点 token】=不同检查面。gate byte-parity pass 仍可能 mask offset 起点学偏。应把"比 mask offset 起点 token"作独立 gate 项（repo `c5_mask_offset_fixture.py` 有雏形但需对真 MLX tokenizer 跑非 external_mlx_fixture_required 占位）。
- E3 所有人盯 think 块（显眼），D-domain 工具名 whitespace 边界（38719 vs 7500）同样致命且无人验。A2 PR 只验编译/swift test/make verify 绿（code-only）未验 token 级 byte-parity——A2 surface 迁移引入的新面。

## must_answer 5 答
1. **prevents_0_34**：yes — byte-parity 失守是 0/34 类（数值健康/行为塌 toolCalls=[]）隐蔽路径，端侧 render dump 接进 gate（C5LoRATraining.swift:1612）逐字节比能在 retrain 前 catch，P0 前置门。
2. **vs_rank16mainline**：escape_hatch — 与配方正交，配方再对若 train/serve 不同源照样塌；home-llm 走自有同源模板规避，MAformac 走 stock Qwen3 必须额外 enforce 单源（TRN2）。
3. **requires_a2_surface_change**：no — 不改 A2 D-domain surface（方向对 support），但 A2 迁移引入新 byte-parity 面（具名工具名多 token+whitespace），是新增检查项不是改 surface。
4. **introduces_deferred**：yes-不越界 — 真闭环依赖端侧 mlx-swift runtime 渲染源（DEFERRED 端侧未开发）。本调研不实装端侧/不 retrain/不真跑评测，只产 gate 契约 + token byte-diff dump 协议弹药供 propose（写成 OpenSpec task，落 docs/research，不碰 runtime contracts/）。符合 Phase 0 边界。
5. **priority_self**：P0。

## Sources
- https://github.com/ml-explore/mlx-swift-lm/issues/154（enable_thinking not passed, Open 2026-03-20）
- https://github.com/QwenLM/Qwen3/issues/1826（KV-cache reuse break enable_thinking=false）
- https://huggingface.co/Qwen/Qwen3-1.7B/discussions/9（fix multiple assistant + no thinking）
- https://github.com/QwenLM/Qwen3.6/issues/131（empty historical think blocks prompt drift）
- https://github.com/huggingface/transformers/issues/34462（apply_chat_template strips trailing newline）
- https://github.com/huggingface/transformers/issues/34172（return_assistant_tokens_mask not work for Qwen2.5）
- https://github.com/haotian-liu/LLaVA/issues/1710（tokenization mismatch → loss 0）
- https://github.com/huggingface/swift-transformers + issue #204（chat_template.jinja）
- https://huggingface.co/blog/qwen-3-chat-template-deep-dive（4 things; `<think>` text-token claim 过时）
- https://kaitchup.substack.com/p/qwen3-when-im_end-suddenly-becomes（EOS token 漂）
- 本机：C5LoRATraining.swift:1604-1681 / mlx_lm/tuner/datasets.py:60-77 / home-llm gemma3_withtools.j2+output.gbnf / Qwen3-1.7B-4bit tokenizer 实测 / docs/lessons-learned.md:42 #26 / docs/integration-blueprint.md:9 TRN2 / grill-decisions.md:117
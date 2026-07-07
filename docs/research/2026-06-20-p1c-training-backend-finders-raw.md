# P1-C 训练后端深扒 — 7 路 subagent finder 原始调研存档

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

> workflow `wf_6a646bb7-f09` 的 7 路 finder 各自的完整结构化调研结果（从 subagent transcript StructuredOutput 提取）。
> 综合版见同目录综合报告；本文是**逐路原始发现**（每路 ≥10 联网搜证），保留 source_url/tigers/候选不丢。

---
## masking 三形态实装(train_on_turn / function / arg-token)在 mlx-lm vs unsloth/TRL 的 token 级落地路径——P1-C 训练硬前置

- **联网搜索次数**: 14
- **一句话结论**: 『三形态』实为两类机制:train_on_turn 是真 loss-masking(本机 Qwen3-1.7B template 已带 {% generation %},用 return_assistant_tokens_mask 转 -100 喂 mlx-lm 自定义 loss callable,零 GPU 开箱即用),而 Hammer『function/param masking』是数据增广(input+label 同步换随机串,p=0.67+3x 复制,loss 照常算)、GOAT『arg masking』才是 loss 置零——三个 C5 flag 必须分别对应正确机制别混;主路本机 mlx-lm(train() 暴露 loss callable,issue#1224 设计意图),TRL/unsloth 因需 NVIDIA GPU 仅作 cloud fallback;HIGH 坑=mlx-lm 单 offset 对多轮只训最后一条 assistant(3123 followup 数据会丢中间信号),且别把 Hammer function masking 误实装成 loss 置零。
- **本机 scout**: 本机实况(Bash 实测):mlx-lm 0.31.1 + mlx 0.31.2 + mlx-metal 已装(native Apple Silicon,mlx_lm.lora/mlx_lm.fuse CLI 可用),transformers 5.6.1。『omlx』= /Applications/oMLX.app(com.omlx.app v0.3.6,GUI 推理 app,非训练栈;磊哥说的『跑 27B hermes』就是它做推理)。另有 Ollama.app + LM Studio.app。无 NVIDIA GPU,unsloth/CUDA 本机不可跑但 mlx-lm 可替代。目标模型 mlx-community/Qwen3-1.7B-4bit 已下载且 chat_template 含 {% generation %}+tool_call(assistant_masks 开箱即用);Qwen3.5-2B-4bit template 为空(劣证)。C5 数据门产物在 Reports/c5-data-gate-20260620-192100/(row 3670,四 mask flag 全 false)。Hammer 仓已在 referencerepo/repos/。
- **clone 深扒**: MadeAgents/Hammer(已在仓内 referencerepo/repos/MadeAgents__Hammer,非 ref-repos):train/data_processing.py 逐行读=三形态数据增广一手源码(function/param-name/default-value 随机替换,p=0.67,3x 复制),证实 Hammer『function masking』是 data-aug 非 loss-mask;data/train/masking_sft_data_example.json 见实际随机化样本(name='hWY9epd1OAn8XVN')。新克隆失败(RPC partial,仓本身 >1yr stale 119★,只 adopt 配方不依赖)。; 本机已装 mlx-lm 0.31.1(site-packages,非 clone):tuner/datasets.py + trainer.py + losses.py 逐行读=mlx-lm masking 一手机制(单 offset 连续区间 mask,train() 暴露 loss callable),这是本机训练主路的 ground-truth。

### 关键发现
- 🔴 核心纠偏:任务 prompt 把『三形态』混为一谈,实际是【两类机制】。(A) train_on_turn = 真·loss masking(把 prompt/user token 的 loss 置零,label=-100);(B) Hammer『function masking』+ GOAT『arg-token masking』是【两种完全不同的东西】。Hammer function masking = 纯【数据增广】(把函数名/参数名/默认值在 input+label 里同步替换成随机串,loss 照常算),GOAT arg masking = 真·【loss masking】(把参数值 token 的 loss 置零)。三者落点不同:train_on_turn 在 collator/loss 层,Hammer 在 data 预处理层,GOAT 在 loss 层。C5 receipt 实际追踪【四个】flag(train_on_turn/function_name/argument_name/argument_value),全 false。
  - source_url: https://github.com/MadeAgents/Hammer/blob/main/train/data_processing.py
  - freshness: ground-truth: 仓内已 clone 的 Hammer data_processing.py 逐行读 + C5 receipt 2026-06-20
  - confidence: high
- Hammer function masking 一手源码(本机 referencerepo/repos/MadeAgents__Hammer/train/data_processing.py 逐行):三个函数全是字符串替换。replace_function_names_new(L103-134):tool['name']→random 5-15 字符,同步改 answer['name'];replace_param_names_new(L66-100):参数 key→random 4-10 字符,同步改 answer['arguments'] key;replace_param_default_values_news(L160-218):默认值→随机值,同步改 answer 和 query。关键:L283 `if random.random()>1/3` = masking 概率 p=0.67,且数据先 3x 复制(L267-277),所以模型同时见【原名】和【随机名】→ 学会读 description 不死记名字。loss 仍在(随机化后的)output 上正常算,绝非置零。
  - source_url: https://arxiv.org/html/2410.04587v2
  - freshness: Hammer push 2025-06-13(>1yr,119★),但 method 一手代码已读;只 adopt 配方不依赖它做活工具
  - confidence: high
- mlx-lm(本机已装 0.31.1,native Apple Silicon,无需 GPU)train_on_turn 一手机制:tuner/datasets.py 的 process() 返回 (tokens, offset) —— offset 是【单个标量】,只能 mask 一段连续前缀。trainer.py default_loss(L75-88):mask = (steps >= offset) AND (steps <= length) = 【连续区间 mask】。结论:stock mlx-lm 的 --mask-prompt 只能做『单段 prefix 屏蔽』。对 multi-turn 只把【最后一条 assistant】当 completion,中间所有 assistant turn 连同 user 一起被屏蔽 → 我们 3123 行 followup-transitions 多轮数据会丢中间 assistant 信号。stock mlx-lm 【原生不支持】arg-token/function 的 token 级 loss masking。
  - source_url: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md
  - freshness: mlx-lm push 2026-06-12(5979★,fresh);本机源码 tuner/datasets.py+trainer.py 逐行读
  - confidence: high
- ✅ 机器实测重大利好:本机已下的 mlx-community/Qwen3-1.7B-4bit tokenizer chat_template 【已含 {% generation %} 标签 + tool_call + tools】(脚本核 has_generation=True,template len=4116,eos=<|im_end|>)。这意味着我们的目标模型【原生支持】tokenizer.apply_chat_template(..., return_assistant_tokens_mask=True)→ 直接拿到 assistant_masks(1=assistant token,0=其余),无需任何模板手术。对照:Qwen3.5-2B-4bit 的 template len=0(空/缺失)—— 又一条 2B 劣于 1.7B 的硬证据。
  - source_url: https://huggingface.co/Qwen/Qwen3-8B/discussions/14
  - freshness: ground-truth: 本机 ~/.cache/huggingface/hub 实测 2026-06-20
  - confidence: high
- 现代多轮 assistant masking 正路(cloud/GPU):TRL SFTConfig(assistant_only_loss=True)用 chat template 的 {% generation %} 标签 → return_assistant_tokens_mask → mask 0 转 label -100,所有 assistant turn 都算 loss(非只最后一条)。TRL 2025+ 已为 Qwen2.5/Qwen3 family 自动 patch 模板(trl/chat_templates/*.jinja),『now just works』。unsloth train_on_responses_only(instruction_part='<|im_start|>user\n',response_part='<|im_start|>assistant\n')同效,但坑:marker 不匹配会全 -100 报错。两者均需 NVIDIA GPU,本机无,只能开发机/云跑。
  - source_url: https://huggingface.co/docs/trl/sft_trainer
  - freshness: TRL push 2026-06-20(18675★)/unsloth push 2026-06-20(66943★),都 fresh
  - confidence: high
- arg-token masking 在 mlx 的可行落地路径:mlx-lm 的 train() 签名暴露 `loss: callable = default_loss` 和 `iterate_batches: callable` —— 【官方设计就允许第三方注入自定义 loss/batching】(ml-explore 在 issue #1224 明确这是 motivation)。Goekdeniz-Guelmez/mlx-lm-lora(push 2026-06-16,380★,very fresh)就是基于此扩展的训练套件,已实装 --mask-prompt + 自定义 loss/GRPO 等。实装路径:写一个返回 per-token mask(arg-value token=0)的 dataset.process + 自定义 default_loss 接收该 mask,注入 train()。token span 定位用 tokenizer offset_mapping 找 answer JSON 里 arguments 值的字符区间→token 区间。
  - source_url: https://github.com/Goekdeniz-Guelmez/mlx-lm-lora
  - freshness: mlx-lm-lora push 2026-06-16(380★);custom loss callable 机制经 mlx issue #1224 + 本机 trainer.py 签名双重确认
  - confidence: medium
- 我们的数据现状(C5 receipt 一手,2026-06-20):row_count=3670(train 2320/heldout 1200/must_pass 30/quarantine 120),masking_coverage 四 flag 全 false,must_not_train_violations=0,parent_semantic_overlap=0,redaction pass,tool_call_format_pass=2320。输出格式锁定 qwen-tool-call-format.yaml:model_family=qwen3,runtime_parser=json,wrapper=tool_call,arguments_shape=json_object,thinking=false。即 answer 是 <tool_call>{"name":...,"arguments":{json_object}}</tool_call> —— arg 值在 JSON object 里,arg-token span 可由 JSON 解析+offset_mapping 精确定位。
  - source_url: https://github.com/MadeAgents/Hammer
  - freshness: ground-truth: Reports/c5-data-gate-20260620-192100/c5-data-gate-receipt.json + contracts/qwen-tool-call-format.yaml
  - confidence: high
- GOAT(arxiv 2510.12218,2025-10)实证:标准 LoRA 会过拟合到训练里见过的具体参数值→泛化变差。对比两策略:(1) self-distillation 软标签 (2) arg-token loss 置零。结论『masking 策略尤其有效,阻止记忆参数值、逼模型学 API 结构』。这正是我们要的——车控 demo 要泛化『模糊说法→正确槽位』,不能让模型死记『26度』这种具体值。SimpleTool(2603.00030)走另一路:用 ⟨arg k⟩⟨/arg k⟩ 特殊 token 标参数边界(非 loss mask)。
  - source_url: https://arxiv.org/html/2510.12218v1
  - freshness: GOAT 2025-10 arxiv;arg-masking 优于 self-distillation 经 paper Table 10 ablation 确认
  - confidence: high

### tigers (坑点)
- [HIGH] mlx-lm stock 对【多轮】只把最后一条 assistant 当 completion → 我们 3123 行 followup-transitions 多轮数据,中间 assistant turn 的 loss 被连同 user 一起屏蔽掉,多轮 ToolCall 信号丢失
  - 证据: tuner/datasets.py process() 返回单标量 offset;trainer.py default_loss(L82) mask=连续区间;LORA.md 明文『for chat datasets the final message is considered the completion』。本机源码+官方文档双证。
  - 缓解: 三选一:(a)走 return_assistant_tokens_mask 路线(本机 Qwen3-1.7B template 已含 {% generation %},自己写 dataset.process 把 assistant_masks 转成 per-token mask + 自定义 default_loss,注入 train());(b)数据侧把每条多轮拆成多个单轮样本,每个以一条不同 assistant 结尾(HelpSteer2 做法);(c)cloud 走 TRL assistant_only_loss=True(原生多轮全 assistant)。demo 体量小,(a) 本机零 GPU 最省,推荐⭐
- [HIGH] 把 Hammer『function masking』当成 loss masking 去实装(置零函数名 token 的 loss)= 实装错方法,既不省又训坏
  - 证据: Hammer data_processing.py L103-134 一手源码:纯字符串替换(input+label 同步),loss 照常在随机化后的名字上算;p=0.67 概率 + 3x 数据复制让模型同时见原名/随机名。这是 data-aug,不碰 loss。任务 prompt 原文『mask 函数名 token 防死记』的措辞会误导成 loss-zero。
  - 缓解: function_name/argument_name 两个 flag 用【数据增广】实装(照搬 Hammer replace_*_new,但保留我们的 device×primitive×slot 语义不乱);只有 argument_value 用【loss masking】(GOAT 式置零)或同样数据增广随机化。C5 receipt 的四 flag 要分别对应正确机制,别混
- [MEDIUM] 本机无 NVIDIA GPU,若误判 unsloth/CUDA 是唯一正路 → 整个 P1-C 卡死或被迫上云徒增复杂度
  - 证据: scout 实测:本机 mlx-lm 0.31.1 已装且 native Apple Silicon(Metal),mlx_lm.lora/fuse CLI 可用;unsloth 依赖 CUDA。但 mlx-lm train() 暴露 loss callable,完全能本机实装全部四形态。
  - 缓解: 主路 = 本机 mlx-lm + 自定义 loss callable(train_on_turn 用 native --mask-prompt 或 assistant_masks;arg-value 用注入 loss;function/arg-name 用数据增广)。cloud TRL/unsloth 仅作【可选 fallback / 交叉验证】,不是必需。LoRA 权重产物两边格式需对齐(safetensors)
- [MEDIUM] arg-token span 定位错位(off-by-one):用字符串匹配找参数值 token 边界,JSON 里同值多处出现或 tokenizer 上下文敏感导致 mask 漂到 assistant 结构 token 上
  - 证据: TRL DataCollatorForCompletionOnlyLM 已知 issue #1184:context-sensitive tokenizer(template 在句首/句中 token 化不同)导致 mask 失配;字符串匹配 response_template 易 off-by-one。
  - 缓解: 用 tokenizer(return_offsets_mapping=True)拿字符→token 映射,先 json.loads(answer) 定位 arguments 各 value 的【字符区间】,再映射到 token 区间置 mask=0;实装后【打印 label 张量肉眼核】mask 只覆盖 arg 值、不碰 name/结构/<tool_call> 标签(这是硬验收步)
- [LOW] Hammer 仓 >1 年没动(push 2025-06-13,119★)被当活工具依赖
  - 证据: gh repo view:Hammer push=2025-06-13 stars=119,按 github-first 新鲜度该淘汰作『工具』。
  - 缓解: 只 adopt 它的【方法/配方】(data_processing.py 已 clone 在仓内可直接抄逻辑),不依赖它的活维护。真正活的依赖是 mlx-lm(2026-06-12)/mlx-lm-lora(2026-06-16)/TRL(2026-06-20)

### paper-tigers
- 『mlx-lm 不支持 prompt masking 所以本机训不了 LoRA』= 假威胁。证据:本机 mlx-lm 0.31.1 原生有 --mask-prompt(datasets.py mask_prompt 参数),且 train() 暴露 loss callable 可扩展任意 token 级 mask。本机完全能训,无需 GPU。
- 『Qwen3 chat template 缺 {% generation %} 标签,要手术模板才能做 assistant masking』= 对 2B 真、对 1.7B 假。机器实测:mlx-community/Qwen3-1.7B-4bit template 已含 {% generation %}+tool_call+tools,return_assistant_tokens_mask 开箱即用,零模板手术。
- 『Hammer 是 SOTA on-device FC 模型必须照搬其训练栈(LLaMA-Factory)』= 假威胁。我们只需它的 masking【数据配方】(已 clone 的 data_processing.py 三个 replace 函数),训练框架本机用 mlx-lm 即可,不必引入 LLaMA-Factory/GPU。

### adopt 候选
- [adopt] **mlx-lm 0.31.1 native --mask-prompt + train(loss=callable)** — 本机已装、零 GPU、native Apple Silicon。train_on_turn 用 native --mask-prompt(单轮)或写 dataset.process 喂 assistant_masks(多轮);arg/function 形态靠注入自定义 loss callable(官方 issue #1224 明示这是设计意图)。这是 P1-C 本机训练【主路】。 (https://github.com/ml-explore/mlx-lm push 2026-06-12,5979★,fresh)
- [adopt] **Qwen3-1.7B tokenizer return_assistant_tokens_mask** — 本机 template 已含 {% generation %},apply_chat_template(...,return_assistant_tokens_mask=True,return_dict=True)直接拿 assistant_masks(1=assistant,0=其余)→ 转 per-token mask 喂自定义 loss。这是 train_on_turn 在 mlx 实装最干净的路(避开单 offset 限制,支持多轮全 assistant)。 (https://huggingface.co/Qwen/Qwen3-8B/discussions/14 本机实测 2026-06-20 template 已支持)
- [adapt] **Hammer data_processing.py 三个 replace 函数(数据增广配方)** — function_name/argument_name/argument_value 三形态照搬其字符串替换逻辑(p=0.67 + 3x 复制),但 adapt:只对 distractor/irrelevant 工具随机化函数名(保留正例 device×primitive 语义),argument_value 随机化要同步改 query 保一致。不依赖 Hammer 活维护(已 clone 可直接抄)。 (https://github.com/MadeAgents/Hammer/blob/main/train/data_processing.py push 2025-06-13,119★,stale 作工具但配方可 adapt)
- [adapt] **GOAT arg-token loss masking(置零参数值 token loss)** — argument_value 形态【若选 loss-mask 路线】用 GOAT 式:json.loads(answer)定位 arguments 各 value 字符区间 → tokenizer offset_mapping 映射 token 区间 → mask=0 喂自定义 loss。adapt:车控值要从 query 抽,可能更适合数据增广而非置零(见 grill Q1)。 (https://arxiv.org/html/2510.12218v1 2025-10 arxiv,方法新鲜)
- [adapt] **Goekdeniz-Guelmez/mlx-lm-lora** — 若不想手写 loss callable,这个基于 mlx-lm 的扩展套件已实装 --mask-prompt + 自定义 loss + RL 模式,本机可跑。adapt:看它的 custom loss API 参考实装我们的 4 形态,或直接用其 mask-prompt 做 train_on_turn。380★ very fresh。 (https://github.com/Goekdeniz-Guelmez/mlx-lm-lora push 2026-06-16,380★,fresh)
- [drop] **TRL SFTConfig assistant_only_loss / unsloth train_on_responses_only** — 正确且现成(多轮全 assistant 自动 patch Qwen3),但【需 NVIDIA GPU,本机无】。仅作可选 cloud fallback / 交叉验证,非 P1-C 主路。demo 3670 行 1.7B 本机 mlx-lm 足够,上云徒增数据搬运+权重格式对齐复杂度。 (https://huggingface.co/docs/trl/sft_trainer TRL/unsloth push 2026-06-20,fresh 但 GPU 门槛不适用本机)

### grill 议题
- argument_value 这一形态到底走【loss masking 置零】(GOAT 式,逼学结构)还是走【数据增广随机化】(Hammer replace_param_default_values 式,逼学读 query)?两者目标不同:前者让模型完全不学具体值(适合值由规则/槽位填),后者让模型学『从 query 抽值』。车控 demo 里参数值(温度/档位)恰恰要从用户话里抽——倾向数据增广而非置零,需磊哥拍。
- function_name 数据增广会不会和我们的语义契约冲突?Hammer 把函数名换成乱码是因为它名字无语义;我们的 action_code 有语义(device×primitive)。是只对【迷惑项/irrelevant 工具】做名字随机化,还是对全集?建议只在 distractor 上随机化保留正例语义,需确认。
- 本机 mlx-lm 自定义 loss callable 路线 vs cloud TRL assistant_only_loss 路线,P1-C 选哪条作主路?本机零 GPU 成本/可立即跑/但要手写 ~50 行 loss+dataset;cloud 现成 flag/但要搬数据上 GPU。demo 体量 3670 行 1.7B,本机够——推荐本机主路 + 实装 4 形态在 dataset.process+loss 两处。
- 多轮(3123 followup-transitions)是否真要进 LoRA train?若 demo 只演单跳 ToolCall(禁自由 agent loop),多轮可能只用于 heldout/bench 而非 train;若不训多轮,mlx-lm 单 offset 限制就不是 blocker。需确认 train set 2320 里多轮占比。
- 四个 masking flag 是否都要在 P1-A 数据门【这一刀】实装齐,还是 train_on_turn(必需)先行、function/arg 增广作增量?train_on_turn 是 loss 正确性硬前提(不做就训 user token),function/arg 是泛化增强(可后补)——建议 train_on_turn 死门、其余分批。


---

## Qwen3-1.7B LoRA 训练具体配方(超参/数据量/checkpoint/tool-call 格式对齐/本机 mlx-lm 落地)

- **联网搜索次数**: 16
- **一句话结论**: 本机训练栈是 mlx-lm 0.31.1(非"omlx",建议升 0.31.3)在 M5/32GB 原生可跑 Qwen3-1.7B(28 层)LoRA;⭐推荐配方 rank32/alpha64/全 linear 层/num_layers=-1/lr 2e-4/cosine warmup 10%/weight_decay 0.01/dropout 0/batch4×grad_accum4/2320 行 batch4 算 1740 iters(3 epochs)/save-every+val loss 早停选 checkpoint;两个 HIGH tiger 必先解 —— 拒识负例别直接堆(When2Call 过度保守反噬,走 90:10+in-prompt distractor+双轴评测)+ mlx-lm mask_prompt 对多轮只训最后一条 assistant(确认是否单轮数据,否则 C5 masking 三形态硬前置);2320 行偏下限但格式/映射类任务可起步,建议 LLM 增广到 4~5k 进 FC 甜区,base 选 1.7B 有外部 benchmark(同尺寸唯一可靠拒识)+ 内部 spike 双证据。
- **本机 scout**: 本机实况(已坐实,非猜):(1) "omlx" 不存在;磊哥说的训练栈实际是 **mlx-lm 0.31.1**(已装,binary `~/Library/Python/3.13/bin/mlx_lm.lora`,源码在 `~/Library/Python/3.13/lib/python/site-packages/mlx_lm/`)。PyPI 最新 0.31.3(本机 0.31.1 落后两个 patch,建议升)。GitHub ml-explore/mlx-lm 2026-06-12 push、5979★ = 高度活跃。(2) 硬件 Apple M5 / 32GB 统一内存 / 10 核 / 无 NVIDIA → unsloth(CUDA)本机不可跑,只能 mlx-lm 本机训或 unsloth 上云/借机。1.7B LoRA bf16 在 32GB 上完全跑得动。(3) ollama 已装(/opt/homebrew/bin/ollama,有 blobs/manifests);hermes 是中转 API 客户端(~/.hermes)非本地大模型,磊哥"omlx 跑 27B hermes"记忆需再核(可能是 ollama 或 mlx 跑的某模型,与训练栈无关)。(4) 已 verify mlx-lm 源码两处关键:tuner/utils.py:85-101 + tuner/datasets.py:65-75,见 tigers。
- **clone 深扒**: 未新 clone(避免污染 ref-repos);直接深扒了【本机已安装的 mlx-lm 0.31.1 源码】= 比 clone 更权威(就是要跑的那份代码)。两处一手 file:line: ~/Library/Python/3.13/lib/python/site-packages/mlx_lm/tuner/utils.py:85-101(LoRA 目标层选择逻辑,已确认 0.31.1 已修复旧 q/v_proj-only gotcha,默认 auto-discover 全部 linear+embedding)+ tuner/datasets.py:57-77(mask_prompt 实现,确认只能 mask 到「倒数第二条消息」为止,多轮只训最后一条 assistant)。

### 关键发现
- 本机训练栈 = mlx-lm 0.31.1(不是 'omlx')。CLI = mlx_lm.lora,支持 --fine-tune-type {lora,dora,full}、--num-layers、--batch-size、--iters、--learning-rate、--mask-prompt、--max-seq-length、--grad-accumulation-steps、-c config.yaml。无原生 epochs 旗标,要手动算 iters。Apple M5/32GB 跑 1.7B LoRA 绰绰有余。
  - source_url: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md
  - freshness: 本机 0.31.1 实测 --help;mlx-lm 2026-06-12 push 5979★
  - confidence: high
- Qwen3-1.7B = 28 层 / hidden 2048 / FFN 6144 / 16 heads / 8 KV heads(GQA)/ SwiGLU。mlx-lm 默认 --num-layers 16 只给最后 16 层加 LoRA → 小模型应改 --num-layers -1(全 28 层),代价极小(1.7B 小)。
  - source_url: https://huggingface.co/docs/transformers/en/model_doc/qwen3
  - freshness: Qwen3 架构表稳定
  - confidence: high
- 推荐 Qwen3-1.7B LoRA 配方(综合 unsloth 官方 + LoRA-Learns-Less 论文 + 本机约束): rank=16~32(小模型/结构化 FC 任务用 32 更稳)、alpha=2×rank(rank32→alpha64;论文实证 α=2r 在高 rank 显著优于 α=r)、target=全 linear(q/k/v/o + gate/up/down,mlx-lm 0.31.1 默认即如此)、num_layers=-1、lr=2e-4(LoRA 比 full-FT 高一个量级;论文区间 5e-5~5e-4)、epochs=2~3、weight_decay=0.01、lora_dropout=0(短训不可靠,unsloth 建议 0)、warmup=总步 5~10%、scheduler=cosine、batch_size=4 + grad_accum=4(等效 16)、max_seq_length 按数据 P95 设(车控短,1024~2048 够)。
  - source_url: https://unsloth.ai/docs/get-started/fine-tuning-llms-guide/lora-hyperparameters-guide
  - freshness: unsloth 官方 guide + Red Hat 2026-04
  - confidence: high
- iters 换算(2320 train 行,mlx-lm 无 epochs 旗标必手算): iters = ceil(2320/batch_size)×epochs。batch=4 时 1 epoch=580 iters;⭐推荐 batch=4 + 3 epochs = 1740 iters(或 2 epochs=1160)。配 --save-every 100~200 存 checkpoint,--steps-per-eval 50~100 报 val loss,选 val loss 最低的 checkpoint(早停)。
  - source_url: https://github.com/ml-explore/mlx/discussions/728
  - freshness: mlx 社区共识公式
  - confidence: high
- 数据量评估: 2320 train 行处于「下限偏可用」区间(meaningful adaptation 下限 100~500,strong 区 1000~10000+)。对【风格/格式/结构化 FC 输出】2320 够用且 LoRA 抗过拟合优于 full-FT;但有研究警告 500~2000 行小集即便把 rank/alpha 拉到 64/40 也未必超过 base。MAformac 任务=学「模糊说→ToolCall 结构 + 拒识」属格式/映射类,2320 可起步,但建议 LLM 增广扩到 4000~5000(FC 甜区 2000~5000),且加权采样(templated 多意图最重 10~25x,见 home-llm 配方),非笛卡尔积。
  - source_url: https://dialzara.com/blog/fine-tuning-llms-with-small-data-guide
  - freshness: 2025-2026 实践 + 论文
  - confidence: high
- tool-call 格式训练对齐(撞 MAformac xmlFunction/json): Qwen3 tokenizer_config.json 已内置 Hermes 风格 tool 模板(<tools></tools> 注入 system,<tool_call>{json}</tool_call> 输出)。训练数据的 tool_call 必须【逐字匹配】该模板格式,否则训练/推理 mismatch。mlx-lm datasets.py 已支持 jsonl 顶层 'tools' 键 + messages 里 assistant 的 tool_calls,会自动走 apply_chat_template(messages, tools=tools)。
  - source_url: https://deepwiki.com/QwenLM/Qwen3/4.3-function-calling-and-tool-use
  - freshness: Qwen3 模板稳定;本机 datasets.py:57-64 实测支持 tools 键
  - confidence: high
- thinking 模式决策: MAformac 是秒回车控,应训 non-think。enable_thinking=False 时 Qwen3 仍产【空 <think></think>】再接答案 —— 训练数据必须产出这个确切结构(空 think 块),不能删 tag,否则偏离模板。纯 no-think 训练最简单且训/推一致;但若 L2-5「判断该不该调/调哪个」需推理,可混入部分带 <think>推理</think> 样本(Qwen 自己就这么练 hybrid)。⭐建议: L1 类(明确指令)走规则不进模型;进模型的 L2-5 样本以 no-think(空 think)为主 + 少量带简短 reasoning 的难例。
  - source_url: https://unsloth.ai/docs/models/tutorials/qwen3-how-to-run-and-fine-tune
  - freshness: 2026 Qwen3 fine-tune guide
  - confidence: high
- 外部强力背书 base 选型: 独立 benchmark 实测【未微调的 Qwen3-1.7B 是同尺寸最强 FC 模型】—— 唯一能可靠通过最难「restraint(该不该调工具/拒识)」prompt 的小模型(20 跑稳定),Action 0.900 + 完美 restraint + 0 错调工具。这直接背书 MAformac 的 base 选择 + 对齐 C6 的 IrrelAcc 指标。所谓「Qwen3 2B」不存在(Qwen3 小模型只有 0.6B/1.7B),磊哥说的 2B 是 Qwen3.5-2B(新代多模态系)。
  - source_url: https://github.com/MikeVeerman/tool-calling-benchmark
  - freshness: 独立 benchmark,Qwen3.5 系 2026
  - confidence: medium
- DoRA 作为 1.7B 备选: mlx-lm 原生支持 --fine-tune-type dora,无推理额外开销(可 merge)。DoRA 在【低 rank(4~8)区间】对 LoRA 增益最大、sample efficiency 更好、训练更稳 —— 正好是小模型甜区。但 DoRA 多了 magnitude 参数,小数据上略增过拟合风险。⭐建议: 主跑 LoRA rank32,并行起一个 DoRA rank8 A/B,用同一 held-out FC 测试集选优,别默认 DoRA 必赢。
  - source_url: https://arxiv.org/pdf/2402.09353
  - freshness: DoRA ICML2024 + mlx-lm 原生
  - confidence: medium
- checkpoint/防过拟合死线: unsloth 明确『train loss 跌破 0.2 = 大概率过拟合』。机制: epochs 越多+数据越小越易过拟合。对 2320 小集: epochs≤3、--save-every 存多 checkpoint、必配 valid.jsonl 报 val loss、选 val loss 拐点前 checkpoint(非最后一个)。dropout=0 但靠 weight_decay 0.01 + 早停正则。
  - source_url: https://unsloth.ai/docs/get-started/fine-tuning-llms-guide/lora-hyperparameters-guide
  - freshness: unsloth 官方
  - confidence: high

### tigers (坑点)
- [HIGH] 拒识/refusal 样本「直接堆负例」会反噬 —— When2Call 实证: 把『不该调工具』负例直接塞进 SFT 会让模型过度保守,拒识涨但正常工具调用(BFCL AST)掉。MAformac 的 must_pass 拒识 + C6 IrrelAcc 正撞此坑。
  - 证据: When2Call 论文(arxiv 2504.18851): '增加负例... model becomes too conservative and does not call tools often enough... decreases BFCL AST'。FalseReject 用 90:10 utility:refusal 配比。TinyAgent: 负例应作【in-prompt 干扰函数】教 tool selection,不是独立『啥都不调』样本。
  - 缓解: (1) 拒识负例做成『prompt 里放无关函数当 distractor』教辨别,而非独立 refusal 样本;(2) 保持 utility:refusal ≈ 90:10,refusal 样本占比上限~10~20%(对齐 3HIGH 的 IrrelAcc≥20% 守门);(3) 双轴评测必做 —— 正例 ToolCall 精确匹配 + 拒识 IrrelAcc 同时跑,一轴涨另一轴掉立即回退;(4) 若 SFT 后拒识仍不够,考虑 RPO/DPO 平衡正负对(但防 refusal 模板过拟合),不靠继续堆 SFT 负例。
- [HIGH] mlx-lm --mask-prompt 对【多轮】只 mask 到倒数第二条消息 —— 多轮对话只训【最后一条 assistant】,中间 assistant 轮全被当 prompt mask 掉,等于多轮 ToolCall 中间步没学到。C5 receipt 的 masking_coverage 三形态正是要补的。
  - 证据: 本机源码 tuner/datasets.py:65-75 实读: mask_prompt 时 offset=len(apply_chat_template(messages[:-1])),即只算『除最后一条外全部』的 token 数作 mask 边界 —— 单一 offset,无法 mask 多个中间 user/tool 轮而保留多个 assistant 轮。
  - 缓解: (1) MAformac 若是【单轮 user→assistant(ToolCall)】结构(车控大多是),--mask-prompt 完全够用、正确(mask system+user,训 assistant tool_call);确认数据是单轮则此坑不触发。(2) 若需多轮(多轮锁域),mlx-lm 内置 mask 不够 → 要么把多轮拆成多条单轮样本(每条只留到该 assistant 轮),要么自写 collator 用 Qwen3 的 {% generation %} 模板 + return_assistant_tokens_mask 逐 assistant 轮 mask(Axolotl chat_template:qwen3 已实现,但 Axolotl 走 CUDA 非本机)。(3) C5 masking 三形态实现前【硬前置不可训】—— 先确认 masking 单元测试:tokenize 后人工核对 loss mask 只盖 assistant tool_call token。
- [MEDIUM] 本机 0.31.1 比 PyPI 最新 0.31.3 落后,且 Qwen3-1.7B 是【tied embedding】(≤4B 词嵌入与输出层共享)+ mlx-lm 默认 auto-discover 会把 embedding 也加 LoRA —— 可能引入非预期可训参数/数值不稳。
  - 证据: 本机源码 utils.py:88-98 get_keys_for_lora 把 nn.Embedding/QuantizedEmbedding 也纳入 keys(types 元组含 Embedding);Qwen3≤4B tied embedding(搜索实证)。0.31.1 vs 0.31.3 两 patch 差,可能含 Qwen3 相关修复。
  - 缓解: (1) 先 pip install -U mlx-lm 升到 0.31.3 再训;(2) 训前跑一次 dry-run 看 print_trainable_parameters() 输出的可训参数 %(应 ~1~3%,若异常高/含 embedding 则在 config 显式设 lora_parameters.keys 限定到 q/k/v/o/gate/up/down_proj 排除 embedding);(3) 这是【实跑一次看 trainable% 即证伪】的廉价验证,别只推理。
- [MEDIUM] lr warmup 配置不当导致【有效 lr 卡在 warmup_init(1e-7)never 升到目标】—— mlx-lm 已知 issue,小 iters + 大 warmup 时 lr 没爬到 2e-4 就开始衰减,训练等于没动。
  - 证据: mlx-examples issue #985: 'learning rate is reduced to warmup_init value of 1e-7... not to desired 1e-5 after 130 iters'。本机 utils.py:18-35 build_schedule 实现 warmup 后接主 schedule。
  - 缓解: warmup_steps 设为总 iters 的 5~10%(1740 iters → warmup ~100~170),不要照搬大训练的固定 warmup 数;训前看前几十步日志 lr 是否真爬到 2e-4;用 cosine schedule 时 arguments 第一项=峰值 lr。

### paper-tigers
- 『2320 行太少训不出来』—— paper-tiger。证据: LoRA 在 <1000 样本时常优于 full-FT(抗过拟合),2320 已过 meaningful 下限;且 MAformac 任务是格式/映射类(学 ToolCall 结构+拒识)非灌新事实知识,格式类小数据更易学。配加权采样+LLM 增广到 4~5k 即进 FC 甜区。不是 blocker,是『建议增广但可先起步』。
- 『必须用 unsloth/CUDA 才能高质量训 LoRA』—— paper-tiger。证据: mlx-lm 在 Apple Silicon 原生支持 LoRA/DoRA/full,1.7B 在 M5/32GB 上轻松跑;unsloth 的优势是 2x 速度 + VRAM 省,对 1.7B 小模型本机训(分钟~小时级)速度非瓶颈。本机 mlx-lm 完全够,无需上云。训练侧产物=LoRA 权重(safetensors),零 Python 进 iOS,合红线。
- 『Qwen3-1.7B 太小,FC 拒识能力不行,得上 2B/更大』—— paper-tiger。证据: 独立 benchmark 实测【未微调 Qwen3-1.7B 是同尺寸唯一可靠通过 restraint/拒识的模型】,微调后只会更强;P1-B spike 也实测 1.7B 9/11 > Qwen3.5-2B 8/11。base 选 1.7B 有外部+内部双证据,不是妥协。

### adopt 候选
- [adopt] **mlx-lm 0.31.x (本机已装,升到 0.31.3)** — 本机唯一可跑的训练栈(无 NVIDIA),Apple Silicon 原生,5979★/2026-06 活跃,支持 lora/dora/full + mask_prompt + tools jsonl 格式 + 原生 Qwen3。直接 mlx_lm.lora -c config.yaml 训,产物 safetensors 适配器零 Python 进 iOS。 ( 2026-06-12 push, PyPI 0.31.3)
- [adapt] **unsloth LoRA hyperparameter guide (官方配方)** — rank/alpha/lr/epochs/weight_decay/dropout/过拟合死线(train loss<0.2)全套权威数值直接采用;但 unsloth 工具本身走 CUDA 本机不可跑 → 只 adapt 其【超参方法学】到 mlx-lm config,工具不 adopt。 ( 官方 docs + Red Hat 2026-04 背书)
- [adopt] **LoRA Learns Less and Forgets Less (TMLR'24)** — 三条硬结论直接进配方: α=2r(高 rank 显著优)、target 全模块且 MLP 是主要学习 locus(非 attention-only)、LoRA lr 比 full-FT 高一个量级(5e-5~5e-4)。且『forgets less』= LoRA 保 base 域外能力,正合 MAformac 不想破坏 Qwen3 通用 FC/拒识。 ( TMLR 2024 引用密集)
- [adopt] **When2Call (拒识训练方法学, arxiv 2504.18851)** — 直接解 MAformac must_pass 拒识 + C6 IrrelAcc 的核心坑: 别堆独立负例(过度保守)→ 用 in-prompt distractor + 90:10 配比 + 双轴评测 + 必要时 RPO。这是 C5 数据配方 + C6 评测的关键约束。 ( 2025-04)
- [adapt] **DoRA (--fine-tune-type dora, arxiv 2402.09353)** — mlx-lm 原生支持,低 rank(4~8)区间对 1.7B 增益最大、训练更稳、无推理开销。作 LoRA rank32 的 A/B 备选(DoRA rank8),用同 held-out 选优;但小数据略增过拟合,不默认它赢。 ( ICML2024 + mlx-lm 原生集成)
- [adopt] **Qwen3 Hermes tool-call 模板 (tokenizer_config 内置)** — 训练数据 tool_call 格式必须逐字对齐 Qwen3 内置 <tool_call>{json}</tool_call> 模板,mlx-lm apply_chat_template(messages,tools) 自动处理;撞 MAformac xmlFunction/json 契约时以 Qwen3 模板为锚,契约转写层适配。 ( Qwen3 稳定)

### grill 议题
- MAformac 的训练样本是【单轮 user→assistant(ToolCall)】还是【多轮锁域对话】? 单轮 → mlx-lm --mask-prompt 直接够用且正确;多轮 → 内置 mask 只训最后一条 assistant,C5 masking 三形态必须自实现(拆单轮 or {% generation %} 模板)。这决定 masking 前置工作量,是 P1-C 最大分叉。
- rank 选 16 还是 32? 32 更能装 ToolCall 结构化 pattern(论文: rank 越高 FC 越准)但 2320 小集 + rank32 有过拟合风险(有研究 500~2000 行 rank64 未超 base)。⭐建议 rank32 起 + 早停;还是保守 rank16? 需磊哥拍或跑 A/B。
- 拒识样本占比定多少? When2Call 警告堆负例反噬,3HIGH 要 IrrelAcc≥20%,FalseReject 用 90:10 utility:refusal。MAformac 的 12000 bug 库转的 refusal/failure 样本占比若超 20% 可能过度保守 —— C5 split 时拒识:正例配比需卡死,这是数据门要核的。
- 增广到 4~5k 还是先用 2320 起步? 2320 可起步但偏下限;LLM 增广(变体扩写)进 FC 甜区更稳,但增广样本要过 must_not_train + masking 一致性。先小集 spike 一版看 C6 base→LoRA 提升曲线,再决定要不要增广?
- 训 LoRA 前是否先升 mlx-lm 0.31.1→0.31.3 + 跑一次 print_trainable_parameters dry-run? 确认可训参数 ~1~3% 且 embedding 没被意外加 LoRA(tied embedding 坑)。这是『实跑一次即证伪』的廉价 gate,不该跳。


---

## 云 GPU 训练选项(Mac 训不动时的退路)— 实测后这个前提被强烈挑战:本机 M5 32GB 训 Qwen3-1.7B LoRA 完全够用,云是"提速/批量/省心"的退路而非"可行性"退路

- **联网搜索次数**: 16
- **一句话结论**: "Mac 训不动"是伪前提:本机 M5 32GB 用已装的 mlx_lm.lora 训 Qwen3-1.7B LoRA 仅需 10-30min,云只是提速/批量扫超参的退路而非可行性退路;最优路线=锁定 MLX-native(本机优先,机时不够时 Scaleway 云 Mac M4-XL €0.49/h 零回流摩擦),坚决避开云 NVIDIA+PEFT(踩'PEFT→MLX 格式转换 + CUDA/Metal 数值不等价端侧掉分'两道坑);C5 真正工程量在多轮 per-turn loss masking(裸 --mask-prompt 只到最后一轮不够,需自造 token-level mask,借鉴 unsloth_zoo 思路)。
- **本机 scout**: 本机 Apple M5 / 32GB / mlx-lm 0.31.1 已装(mlx_lm.lora 可用,支持 --mask-prompt/--fine-tune-type lora,dora,full/--grad-checkpoint/--grad-accumulation-steps/--mask-prompt);Qwen3-1.7B-4bit 与 Qwen3.5-2B-4bit 已缓存(~20G HF cache)。omlx 澄清:无 omlx 二进制,磊哥记忆的'omlx 跑 27B hermes'实为 mlx-lm;本机 Hermes=Nous Research Hermes 桌面 app(LaunchAgents/Preferences 痕迹),非自训 27B;HF 缓存 Qwen3.6-35B-A3B(MoE)4bit/8bit 是空占位目录(4.0K)。ref-repos 已有 home-llm/Hammer/gorilla/agentevals 等 14 repo。unsloth 本机未装(orig unsloth 需 Triton,Mac 无;MLX 路径=unsloth_zoo/mlx/trainer.py 仍 beta)。
- **clone 深扒**: clone unslothai/unsloth + unslothai/unsloth-zoo 均被网络阻断(Connection reset by peer x4,git https 走不通)——按 execution-discipline 网络降级(≤2 retry 后记录+继续),改用 gh API + WebFetch 获取关键事实:确认 train_on_responses_only 在 unsloth_zoo/dataset_utils.py、MLX 训练在 unsloth_zoo/mlx/trainer.py;masking 多轮覆盖行为、Qwen3.5 VRAM 表、--mask-prompt 仅到最后一轮、GGUF 导出不含 Qwen3 等均由官方文档/issue 坐实,clone 非必需。结论:本路无需新增 clone,unsloth-MLX 现阶段不采用(beta+Qwen3 未实战),P1-C 用成熟裸 mlx_lm.lora。

### 关键发现
- 前提纠错(最重要):本机 Apple M5 32GB 训 Qwen3-1.7B LoRA 完全够用,不是'训不动'。Qwen3.5 官方 VRAM 表:0.8B=3GB / 2B=5GB bf16 LoRA,1.7B 约 4-5GB;32GB 统一内存可训到 14B QLoRA。实测类比:Mistral-7B QLoRA 5000 样本在 M2 Max 32GB 约 90min/峰值~7GB RAM;1.7B 小 4 倍 → 预期 10-30min/峰值低个位数 GB。本机已装 mlx-lm 0.31.1(mlx_lm.lora 可用,支持 --mask-prompt/--fine-tune-type lora,dora,full/--grad-checkpoint/--grad-accumulation-steps),Qwen3-1.7B-4bit 已缓存。云 GPU 的定位应是'提速/批量超参扫/省本机机时',不是'可行性退路'。
  - source_url: https://unsloth.ai/docs/models/qwen3.5/fine-tune
  - freshness: 2026 官方文档 + 本机实测 mlx_lm.lora --help
  - confidence: high
- 🔴 回流头号坑:云 NVIDIA(CUDA/HF)训出的 adapter → MLX 部署【数值不等价】。mlx-lm issue #1058 实录:Qwen3.5-4B merge LoRA 后 mlx_lm.convert(不量化)到 MLX,贪心解码(argmax)对比 HF Transformers,前 ~20-30 token 一致随后发散+质量退化,即便都是 BF16。根因:Metal 与 CUDA kernel 微小数值差在自回归生成中累积。含义:云训 adapter 必须在端侧用 C6 bench 重新验收,不能假定等价。规避此风险最干净的方式='在哪部署就在哪训'(MLX on Mac,本机或云 Mac),adapter 即 MLX 原生格式。
  - source_url: https://github.com/ml-explore/mlx-lm/issues/1058
  - freshness: 2026 GitHub issue,本月活跃仓
  - confidence: high
- 次坑(格式不兼容):mlx_lm 的 --adapter-path 只吃 MLX 格式 adapter,【不原生加载】HF PEFT 格式(safetensors)。两者 key 命名不同(MLX lora_a/lora_b vs PEFT base_model.model.*.lora_A.weight)且 A/B 矩阵需转置。云用 unsloth/axolotl/llamafactory(都是 PEFT 输出)→ 回 MLX 需手写转换脚本(改 key+转置+重建 adapter_config 的 rank/scale/num_layers),易错且 config 无法纯从权重反推。结论:云 NVIDIA 路线有两道回流摩擦(格式转换 + 数值再验收)。
  - source_url: https://github.com/ml-explore/mlx/discussions/1910
  - freshness: 2026 MLX 官方 discussion
  - confidence: high
- 云 Mac 路线=零回流摩擦最优解:Scaleway Mac mini M4-XL(M4 Pro,64GB,20-core GPU)€0.49/h,官方明示支持 mlx_lm.lora/llm-mlx 训练。在云 Mac 跑 mlx_lm.lora → 输出【原生 MLX adapter】,与本机端侧推理(spike-e3 mlx-swift-lm)同格式同 kernel 族,无格式转换、数值差远小于跨 CUDA/Metal。坑:Apple 授权强制 24h 最低租期(AWS/Scaleway 同),任意时长按整 24h 计 ≈ €11.76+VAT。AWS EC2 mac2 (M2 Pro 32GB) 更贵 $1.56/h($37.44/天)。
  - source_url: https://www.scaleway.com/en/mac-mini-m4-pro/
  - freshness: 2026 Scaleway 官方页 + 多源交叉(24h 最低租期)
  - confidence: high
- 免费档够用:Kaggle 优于 Colab。Kaggle 保证 30 GPU 小时/周(T4x2 或 P100,16GB),9-12h/session,可用性可预测;Colab 免费档动态配额、随机断连、~12h session+约 15-30 GPU 小时/周动态限、无持久存储。Qwen3-14B 都能塞进单 T4 16GB(unsloth 省 70% VRAM),1.7B 余量巨大。免费档跑 unsloth(PEFT 输出)→ 仍踩上面两道回流坑(格式+数值),适合'零成本快速试超参',产物需转换+端侧重验。
  - source_url: https://www.kdnuggets.com/5-cheapest-cloud-platforms-for-fine-tuning-llms
  - freshness: 2026 多源(Kaggle 30h/周 + Colab 动态限)
  - confidence: high
- 租 NVIDIA 成本极低但仅当不在意回流:Vast.ai spot RTX 4090 均价~$0.21/h(可低至 $0.08,需容忍 15s 中断+checkpoint);RunPod Secure RTX 4090 $0.24-0.50/h 按秒计费无 egress 费。典型小模型 QLoRA 全程 $几~$16。但 1.7B LoRA 在这些卡上分钟级完成,租 GPU 的钱不是瓶颈——回流摩擦(PEFT→MLX 转换+数值再验)才是隐性成本。
  - source_url: https://www.spheron.network/blog/gpu-cloud-pricing-comparison-2026/
  - freshness: 2026-04/06 多源 GPU 比价
  - confidence: high
- 框架选型(若走云 NVIDIA):三家 Qwen3 都支持且都极活跃。LLaMA-Factory 72.3k★(本月活跃,广模型/方法+day0 Qwen3,GUI 友好)、Unsloth 66.9k★(本月活跃,单卡最快省 VRAM,Qwen3+MoE)、Axolotl 12.1k★(本月活跃,多卡 FSDP/DeepSpeed)。对 1.7B 单卡:Unsloth(最快+免费 Colab/Kaggle 现成 Qwen3 notebook)。⚠️ Unsloth 官方建议 Qwen3.5 系列(MoE 或 dense)【都不要 QLoRA 4-bit】训练(量化差异偏大),用 bf16 LoRA;本机缓存的是 4bit,训练质量优先应拉 bf16 base。
  - source_url: https://theaiengineer.substack.com/p/unsloth-vs-axolotl-vs-llama-factory
  - freshness: 2026-03 star 数 + 本机 gh API 实查 pushedAt 全在 2026-06-12~20
  - confidence: high
- masking 三形态(C5 硬前置)直接受云/本机选型影响:mlx_lm.lora 的 --mask-prompt 只把多轮对话的【最后一条 assistant 消息】当 completion 算 loss('the final message in the message list is considered the completion'),【不覆盖所有 assistant 轮】。MAformac 多轮 FC+clarify+readback 数据集需对所有 ToolCall assistant 轮算 loss → 纯 mlx --mask-prompt 不够。Unsloth 的 train_on_responses_only(unsloth_zoo/dataset_utils.py)用 instruction/response 分隔符模式匹配,覆盖所有 assistant 轮,且 PR#75 已支持多 instruction pattern 列表处理 tool_call/ipython 等角色 → 这是可借鉴的 masking 设计(即使最终在 MLX 训,也应照此做 per-turn 多角色 masking,不能简单 --mask-prompt)。
  - source_url: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md
  - freshness: 2026 mlx-lm 官方 LORA.md + unsloth-zoo PR#75
  - confidence: high
- Unsloth 现已官方支持 MLX 训练(Unsloth Studio,unsloth_zoo/mlx/trainer.py,v2026.6.x,2026-01 起社区 PR→官方,Daniel Han 1/6 确认,本月仍活跃)——理论上'同 API 本机原型→云扩展'。BUT MLX 路径仍 beta 不稳:issue #6002 实录 Qwen3.5 LoRA SFT 在 Studio MLX 报 patched_attn_call 拒 position_embeddings + VJP 错。对 Qwen3 尚未实战验证 → 现阶段稳妥仍用裸 mlx_lm.lora(成熟)而非 unsloth-MLX。
  - source_url: https://github.com/unslothai/unsloth/issues/6002
  - freshness: 2026 GitHub issue,本月活跃
  - confidence: medium
- GGUF 导出对 Qwen3 受限:mlx_lm.fuse 的 --export-gguf 仅支持 Mistral/Mixtral/Llama fp16,【不含 Qwen3】。所以'fuse→GGUF→llama.cpp 跨端'路径对 Qwen3 走不通;Qwen3 应留在 MLX 原生格式(adapter 或 fuse 后 mlx_lm.convert)——正好对齐 spike-e3 的 mlx-swift-lm 端侧推理栈,不是问题。fp16/bf16 下 MLX convert 基本无损(Awni Hannun:fp16/bf16/fp32 与 HF 多数等价),质量差主要来自量化,部署可先 fp16 验收再量化。
  - source_url: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md
  - freshness: 2026 mlx-lm 官方 LORA.md
  - confidence: high
- omlx 澄清:本机【无 omlx 二进制】,磊哥记忆中的'omlx 跑 27B hermes'实为 mlx-lm(已装 0.31.1)。本机 'Hermes' = Nous Research Hermes 桌面 app(LaunchAgents/Preferences 痕迹),非自训 27B 模型。HF 缓存里有 Qwen3.6-35B-A3B(MoE,~3B 激活)4bit/8bit 但是空占位目录(4.0K),非已跑大模型。结论:本机栈就是 mlx-lm,无需找神秘 omlx。
  - source_url: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md
  - freshness: 本机 2026-06-20 实测 which/find/du
  - confidence: high
- 隐私:车控数据已脱敏(红线:真实语料/PII 不入仓、不进训练集)。RunPod 有 HIPAA/GDPR+AES-256+VPC 隔离,Vast.ai 有 SOC2/3;脱敏后上云风险可控。但'本机/云 Mac 训练'天然零第三方暴露,对'演示 demo+轻治理'是更省心的默认(连合规评估都免)。
  - source_url: https://www.runpod.io/legal/compliance
  - freshness: 2026 RunPod 合规页
  - confidence: medium

### tigers (坑点)
- [HIGH] 云 NVIDIA 训 → 端侧 MLX 部署数值不等价:CUDA/Metal kernel 微差累积,贪心解码 ~20-30 token 后发散+质量退化(BF16 亦然)。云训出来的'好 adapter'到端侧可能 C6 bench 掉分,且难定位是训练问题还是回流问题。
  - 证据: mlx-lm issue #1058 实录 Qwen3.5-4B merged LoRA convert MLX vs HF 贪心解码发散;Awni Hannun 确认 fp16/bf16 格式基本无损但跨框架不保证 bitwise 等价
  - 缓解: 首选'在哪部署在哪训'=MLX on Mac(本机 M5 或云 Scaleway Mac),adapter 即 MLX 原生格式,kernel 同族。若必须云 NVIDIA:训完【强制】在端侧跑 C6 全量 bench 重验收(不假定等价),并以端侧分数为准,把'回流验收'写进 P1-C 验收门。
- [MEDIUM] PEFT(unsloth/axolotl/llamafactory 输出)→ MLX 格式不兼容:--adapter-path 只吃 MLX adapter,需手写 key-rename+转置+重建 config 转换脚本,config(rank/alpha/target_modules)无法纯从权重反推,转错=静默劣化。
  - 证据: mlx/discussions/1910 'No it is not yet supported';社区转换脚本需 prepend base_model.model.+ lora_A↔lora_a + 转置;HF discuss 173103 指出 config 不可从 safetensors 提取
  - 缓解: 避开此坑=直接用 mlx_lm.lora 训(本机或云 Mac),根本不产 PEFT。若坚持云 NVIDIA,转换脚本须固化并对每个 adapter 做'转换前后 HF/MLX 输出抽样比对 + C6 bench'双验。
- [HIGH] --mask-prompt 只 mask 到最后一条 assistant 消息,多轮 FC/clarify/readback 的中间 ToolCall 轮不算 loss → 训练信号缺失,模糊车控多轮泛化和拒识学不到位(C5 masking_coverage 全 false 正是此处硬前置)。
  - 证据: mlx-lm LORA.md 'the final message in the message list is considered the completion';对比 unsloth train_on_responses_only(PR#75)按分隔符匹配所有 assistant 轮+多角色 pattern
  - 缓解: C5 masking 实现必须做【per-turn 多角色 masking】(对所有 assistant/tool_call 轮算 loss),不能用裸 --mask-prompt。借鉴 unsloth_zoo/dataset_utils.py 的 instruction/response pattern 列表思路,在数据预处理阶段生成 token-level loss mask(MLX 训练时按自定义 loss mask),并把 masking_coverage=三形态全 true 作为 P1-C 训练前 gate。
- [LOW] Apple 授权 24h 最低租期:云 Mac(Scaleway/AWS)任意时长按整 24h 计费,跑 30min 训练也付一整天。若反复试超参分多次开关机 → 成本和时间被 24h 颗粒度放大。
  - 证据: Scaleway/AWS 官方 + 独立源 'minimum lease 24h, even 10 minutes costs a full 24 hours';€0.49/h×24≈€11.76+VAT
  - 缓解: 云 Mac 仅在'本机机时不够/要批量超参扫'时启用,且把一轮所有 run(数据门验证+多超参+C6 验收)塞进一个 24h 窗口批处理,跑完再销毁。日常迭代用本机 M5(零边际成本)。

### paper-tigers
- 'Mac 训不动 Qwen3-1.7B LoRA 需要上云'——伪。本机 M5 32GB 用已装 mlx_lm.lora 训 1.7B LoRA 10-30min/峰值几 GB,32GB 可训到 14B QLoRA。云是提速/批量退路,不是可行性退路。证据:Qwen3.5 官方 VRAM 表 2B=5GB,Mistral-7B QLoRA M2 Max 32GB 90min/7GB 类比。
- '上云训练泄露车控数据'——对脱敏后的 demo 数据是 paper-tiger。红线已保证真实语料/PII 不入训练集,云训只是脱敏样本;RunPod HIPAA/GDPR+AES-256+VPC、Vast.ai SOC2/3。且本机/云 Mac 训练天然零第三方暴露 → 选 MLX 路线连合规评估都免。
- 'omlx 是个需要找回来的神秘训练工具'——伪。本机无 omlx 二进制,实为 mlx-lm(已装);Hermes=Nous 桌面 app 非自训 27B。P1-C 训练栈就是 mlx-lm 已装即用,不需找/装新工具。
- 'fuse→GGUF 跨端部署对 Qwen3 可用'——伪(对 Qwen3)。mlx_lm.fuse --export-gguf 仅 Mistral/Mixtral/Llama。但 Qwen3 留 MLX 原生格式正好对齐 spike-e3 mlx-swift-lm 端侧栈,不是问题——不需要 GGUF。

### adopt 候选
- [adopt] **mlx_lm.lora(本机已装 0.31.1)作 P1-C 主训练器** — 本机 M5 32GB 训 1.7B LoRA 10-30min 够用,输出 MLX 原生 adapter 与端侧 spike-e3 mlx-swift-lm 同格式同 kernel 族,零回流摩擦+无 CUDA/Metal 数值不等价。已装即用,无需装任何新工具。 (https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md pushedAt 2026-06-12,5979★,本月活跃)
- [adapt] **Scaleway Mac mini M4-XL(M4 Pro 64GB)€0.49/h 作机时扩展退路** — 仅当本机机时不够/批量超参扫时启用;云 Mac 跑 mlx_lm.lora 同样产 MLX 原生 adapter,零回流摩擦。受 24h 最低租期约束 → 用法=一窗口批处理跑完所有 run 再销毁,不做日常迭代。 (https://www.scaleway.com/en/mac-mini-m4-pro/ 2026 官方页,M4 Pro 在售)
- [adapt] **unsloth_zoo train_on_responses_only 的 per-turn 多角色 masking 设计(借思路非依赖)** — C5 masking 三形态硬前置,裸 mlx --mask-prompt 只 mask 到最后一轮不够;借鉴其 instruction/response pattern 列表(PR#75 支持 tool_call/role)思路,在数据预处理阶段自造 token-level loss mask 供 MLX 训练读取。不引入 unsloth 依赖(Mac 无 Triton+MLX 路径 beta)。 (https://github.com/unslothai/unsloth-zoo/pull/75 unsloth-zoo v2026.6.x 本月活跃)
- [drop] **云 NVIDIA(Unsloth/Axolotl/LLaMA-Factory)+ PEFT 输出路线** — 对 1.7B 提速收益微乎(本机已分钟级),却引入两道坑:PEFT→MLX 需手写转换脚本(易静默劣化)+ CUDA/Metal 数值不等价(issue#1058 端侧掉分)。轻治理 demo 不值得。仅当未来升级到大 base(9B+ bf16,本机 32GB 吃力)才重新评估。 (https://github.com/ml-explore/mlx/discussions/1910 2026 MLX 官方 discussion)
- [adapt] **Kaggle 免费 30 GPU 小时/周(零成本试超参)** — 比 Colab 可预测(保证配额,不随机断连),Qwen3-1.7B 余量巨大;但产 PEFT 输出仍踩回流两坑。仅适合'零成本快速感受超参方向',产物不直接用,需端侧重训/重验。优先级低于本机 MLX。 (https://www.kdnuggets.com/5-cheapest-cloud-platforms-for-fine-tuning-llms 2026 多源,Kaggle 30h/周现行)

### grill 议题
- 既然本机 M5 32GB 训 Qwen3-1.7B LoRA 只要 10-30min/峰值几 GB,P1-C 第一版是不是根本不该上云?云只在'多超参并行扫'或'升级到更大 base(如真要试 2B/4B bf16)'时才有 ROI——你认同'本机优先、云作扩展'吗?
- 回流数值不等价(issue#1058)意味着任何云训 adapter 都要端侧 C6 重验收。那为省事直接'在哪部署在哪训',是否应把 P1-C 训练栈锁死为 MLX(本机 mlx_lm.lora + 必要时 Scaleway 云 Mac),彻底放弃云 NVIDIA+PEFT 路线(免去格式转换+数值再验两道坑)?
- C5 masking 三形态硬前置:用裸 mlx_lm.lora 的 --mask-prompt 只能 mask 到最后一轮,满足不了多轮 FC per-turn masking。是否接受'在数据预处理阶段自造 token-level loss mask + 改 MLX 训练 loss 读 mask'这条路(借鉴 unsloth_zoo 思路但不依赖 unsloth)?这是 P1-C 真正的工程量所在。
- Unsloth 官方建议 Qwen3.5 全系不用 QLoRA(量化差异大),用 bf16 LoRA。本机缓存是 4bit。训练质量优先是否应拉 Qwen3-1.7B 的 bf16 权重(~3.4GB)而非用 4bit base 训 QLoRA?32GB 完全放得下 bf16 base+LoRA。
- omlx 已澄清=mlx-lm(本机无 omlx 二进制,Hermes=Nous 桌面 app)。这个认知纠正后,是否确认 P1-C 训练栈就是 mlx-lm 0.31.1 已装即用,不需再找/装任何'神秘训练工具'?


---

## Qwen3.5-2B(VL + Gated DeltaNet 混合架构)训练特殊性深扒 —— 若未来从 Qwen3-1.7B 切到 2B,训练侧有哪些坑、与 1.7B 训练难度对比、现在守 1.7B vs 未来 2B 需先解决什么。结合本机 M5/32GB/无 GPU 实况 + mlx-lm 0.31.1 源码一手核验。

- **联网搜索次数**: 13
- **一句话结论**: 训练侧深扒结论:切 Qwen3.5-2B 在 P1-C 是净增成本无明显收益——GDN 占 75% 层而标准 LoRA 配方碰不到(本机源码坐实,核心泛化能力训不进)、本机无 GPU 致 D30 锁定的 unsloth 栈走不通、native VL 带无用 vision 权重(训练 crash+端侧需裁+merge 发散 bug);叠加 P1-B 已实测 2B 劣于 1.7B,建议 P1-C 锁 Qwen3-1.7B(全层标准可训+成熟栈零改动+端侧链路成熟),把 2B 降为 P2 后探索性 spike(需先解 GDN-keys 配方/VL 裁剪/merge 一致性三关)。磊哥担心的 thinking-loop 是 paper-tiger(2B 默认非思考)。
- **本机 scout**: 本机 M5/32GB/无 NVIDIA GPU(Metal 4)。已装:mlx 0.31.2 + mlx-lm 0.31.1(内置 qwen3_5.py/qwen3_5_moe.py/qwen3_next.py/gated_delta.py + lora/fuse/convert 子命令)+ transformers 5.6.1(满足 Qwen3.5 v5 要求)+ ollama(无模型)+ uv。未装 torch/peft/trl/unsloth(unsloth 本机 CUDA-only 跑不了)。omlx 坐实=oMLX-0.3.6 推理 GUI(磊哥跑 35B 用,撞过 JetsamEvent 内存墙,是推理非训练)。一手源码核验:mlx-lm qwen3_5.py:204 DecoderLayer 按 (idx+1)%4 切 75% GatedDeltaNet(in_proj_qkv/z/b/a+out_proj,行114-128)/25% 标准 Attention(复用 qwen3_next q/k/v/o);tuner/utils.py:38 linear_to_lora_layers 按 keys 挂任意 nn.Linear,GDN 的 in_proj_* 可被显式 keys 命中但无默认配方。

### 关键发现
- Qwen3.5 是 2026-02 发布的全新代际(早于知识 cutoff 边缘,必须联网);2B 是 small-series(0.8B/2B/4B/9B)之一,且是 dense(非 MoE)、native VL 多模态(early-fusion,非 bolt-on vision adapter)。官方定位 2B = 'edge-only, integrated graphics 基础任务',0.8B/2B 是 edge-only 档。LM 部分 hidden=2048 / 24 层。这与 Qwen3-1.7B(纯文本、bolt-on 无 vision、32K context)是两种不同物种。
  - source_url: https://qwen.ai/blog?id=qwen3.5
  - freshness: 2026-02 发布,搜证 2026-06
  - confidence: high
- GDN 架构 LoRA 核心特殊性(本机 mlx-lm 0.31.1 源码 qwen3_5.py:204 一手坐实):DecoderLayer 按 (layer_idx+1) % full_attention_interval(=4) 切换——75% 层是 GatedDeltaNet(linear_attn),25% 是标准 Attention。GDN 层用的投影是 in_proj_qkv / in_proj_z / in_proj_b / in_proj_a + out_proj(qwen3_5.py:114-128),不是标准 q_proj/k_proj/v_proj。结论:unsloth 官方推荐的标准 target_modules=[q/k/v/o_proj, gate/up/down_proj] 只命中 25% 的 full-attention 层 + 全部 MLP,75% 的 GDN 时序混合层完全不被 LoRA 触及。这是磊哥要深扒的'GDN target module 不同'的精确答案,且 unsloth issue#4108 作者自己说 'Qwen3.5 is pretty weird with the delta nets'。
  - source_url: https://github.com/unslothai/unsloth/issues/4108
  - freshness: 本机源码 2026-04 + issue 2026-02
  - confidence: high
- 本机 mlx-lm 0.31.1 已内置 qwen3_5.py + qwen3_5_moe.py + qwen3_next.py + gated_delta.py(GDN kernel),lora 子命令支持 --fine-tune-type lora/dora/full + --num-layers + YAML config 里 lora_parameters.keys 可自定义挂哪些 nn.Linear。因 GDN 的 in_proj_* 都是 nn.Linear,理论上可显式加 keys 让 LoRA 命中 GDN 层——但无官方默认配方,需自己实验 keys 列表。即:本机 M5 无 NVIDIA GPU 也能走 mlx-lm 路径训 Qwen3.5-2B LoRA。
  - source_url: https://github.com/ml-explore/mlx-lm
  - freshness: 本机 0.31.1 实测 2026-06
  - confidence: high
- VL 权重在端侧训练是真坑(决定性):有现成蓝本 sciences44/mlx-lora-finetune(Qwen3.5-2B + MLX LoRA, Mac M1+/16GB, 无 GPU)证明 2B 本机能训通且是 'Goldilocks zone';但其文档明确 4B 需手动剥离 vision 权重——'Qwen3.5 是 native 多模态,vision weights crash MLX LoRA training';2B 恰好避开此坑。另 mlx-lm issue#1058:Qwen3.5-4B LoRA merge+convert(quantize=False)后输出发散(前 20-30 token 对、之后崩),说明 GDN 模型 LoRA-merge→端侧部署链路有 conversion bug 风险。
  - source_url: https://github.com/sciences44/mlx-lora-finetune
  - freshness: 2026 活跃
  - confidence: high
- thinking-loop 抑制是 paper-tiger:Qwen3.5 官方 model card 明确 0.8B/2B/4B/9B 小模型 reasoning 默认 DISABLED(要开才 enable_thinking=true);只有显式开 thinking 时小模型才更易陷入 thinking-loop。我们车控单跳 ToolCall 用非思考即可,不需训练时特意抑制。注意 Qwen3.5 不再支持 Qwen3 的 /think //nothink 软开关,改用 chat_template_kwargs={enable_thinking:false}。训练数据若想固化非思考,按非思考模板(空 think 块)构造即可。
  - source_url: https://huggingface.co/Qwen/Qwen3.5-2B
  - freshness: 2026-02 model card
  - confidence: high
- unsloth 官方支持 Qwen3.5(含 2B,bf16 LoRA VRAM 仅 5GB,有 Colab notebook),但三条硬约束:(1) 需 transformers v5(本机已 5.6.1 满足);(2) 官方明确'不推荐 QLoRA 4-bit 训练 Qwen3.5'(量化差异+custom Mamba/GDN Triton kernel 编译慢)——这对'端侧想要量化省内存'的直觉是反的;(3) unsloth 训练路径历史是 CUDA/NVIDIA-only,2026 中才开始加 MLX/Apple Silicon 支持(Studio training 仍主 NVIDIA,M-series 仍可能撞 'only NVIDIA/AMD/Intel GPUs' 报错)。本机 M5 无 GPU → unsloth 训练走不通,只能云 GPU 或本机 mlx-lm。
  - source_url: https://unsloth.ai/docs/models/qwen3.5/fine-tune
  - freshness: 2026-04 doc
  - confidence: high
- VL 文本塔冻结训文本任务可行但有'early-fusion 补偿退化'隐患:冻结 vision encoder + 只 LoRA language tower 是 Qwen3-VL 系默认推荐(省内存、不破坏视觉表示、对域适配足够);但 Qwen 团队自己在 Qwen3-Omni 报告中放弃了'冻一塔训另一塔'——冻结一塔会迫使另一塔扭曲补偿、退化感知。对我们纯文本车控:根本不需要 vision,训一个 native VL 模型的文本塔本身是把算力/包体浪费在用不到的模态上。端侧可用 --language-model-only 跳过 vision encoder(vLLM 侧已验证),但 MLX/llama.cpp 端侧真正裁剪 vision tower(~300M,SigLIP2-Large 推测未官方确认)是另一道工程。
  - source_url: https://docs.vllm.ai/projects/recipes/en/latest/Qwen/Qwen3.5.html
  - freshness: 2026 vLLM recipes
  - confidence: medium
- 1.7B vs 2B 训练难度对比:Qwen3-1.7B 训练生态成熟(Qwen3 系一年沉淀,纯文本标准 Transformer、所有层都是标准 q/k/v/o_proj、LoRA 配方烂熟、Q4 端侧 1.4GB);Qwen3.5-2B 生态新(2026-02 发布 4 个月)、混合 GDN 架构 LoRA 无成熟默认配方、native VL 带不需要的 vision 权重(端侧需裁)、merge→convert 有发散 bug。研究共识:1.5-3B 小模型都能可靠学会 function calling(数据对就行),2B 多 0.3B 参数+长 context 对'复杂多步推理'有边际优势,但我们三层路由把复杂留给慢路、L1 走规则,2B 的容量优势在车控单跳 FC 上不明显。结合 P1-B spike 已实测 2B S1 8/11 劣于 1.7B 9/11 → 训练侧 2B 是净增成本无明显收益。
  - source_url: https://medium.com/@ishaafsalman/qwen3-5-fine-tuning-in-2026-moe-vs-dense-b2d17de73a9e
  - freshness: 2026 活跃
  - confidence: high
- omlx 坐实 = oMLX(本机有 oMLX-0.3.6-macos26-tahoe.dmg + ~/.omlx + 已有 skill omlx-default-context-cap.md),是 MLX 推理 GUI/server(磊哥用它在 32GB Mac 跑过 Qwen3.6-35B-A3B int4),是推理工具不是训练工具。本机 32GB 跑 35B 已撞 JetsamEvent 内存墙(权重 17.5GB+KV)。结论:omlx 与训练无关,训练靠 mlx-lm.lora;但 omlx 可作 LoRA 训完后的本机推理验证 server。
  - source_url: https://github.com/ml-explore/mlx
  - freshness: 本机 2026-04 实测
  - confidence: high

### tigers (坑点)
- [HIGH] GDN(75% 层)LoRA 盲区:标准 target_modules 只训 25% full-attention 层+MLP,75% 的 GatedDeltaNet 时序混合层(模型真正的'记忆/语义混合'能力所在)完全不被 LoRA 触及。若用 unsloth 默认配方训 2B 学'模糊车控泛化',核心混合层学不到,提升可能远低于在标准 1.7B 上训。
  - 证据: 本机 mlx-lm qwen3_5.py:204 is_linear 切分 + 114-128 in_proj_* 非标准命名;unsloth 默认 target 不含 GDN 投影;issue#4108 'weird with delta nets'
  - 缓解: 若真要训 2B:在 mlx-lm YAML lora_parameters.keys 显式加 GDN 的 in_proj_qkv/in_proj_z/out_proj(都是 nn.Linear 可挂),并做'含 GDN keys vs 不含'的 A/B held-out 对比验证;但这是无成熟配方的实验,P1-C 工期内风险高。守 1.7B 则全层标准 q/k/v/o,无此盲区。
- [HIGH] 本机 M5 无 NVIDIA GPU,unsloth(P0 已 adopt 的训练栈)训练路径在 Apple Silicon 上历史走不通、2026 中才加 MLX 支持仍不稳;切 2B 等于把训练栈从'unsloth+CUDA 云 GPU'切到'mlx-lm 本机'或'云 GPU 上 unsloth 但要解 GDN+VL 坑',与已锁 D30(adopt unsloth+Hammer+xLAM)的训练流冲突。
  - 证据: unsloth requirements 文档 'only works on NVIDIA/AMD/Intel GPUs' + 2026-04 M4 Studio 安装失败 issue#4774;本机 scout 无 torch/peft/trl/unsloth、无 GPU
  - 缓解: 训练本就不在本机 iOS 跑(红线:产物=LoRA 权重)。决策点是云 GPU 选哪条:1.7B 走成熟 unsloth+CUDA 云;2B 要么 unsloth 云上解 VL 权重剥离+GDN keys,要么改 mlx-lm 本机(M5/32GB,2B bf16 LoRA ~5GB 可跑)。守 1.7B = 复用 D30 既定栈零改动。
- [MEDIUM] GDN 模型 LoRA-merge→端侧部署链路有 conversion 发散 bug:训完 LoRA 要 merge 进 base 再量化部署到 iPhone,Qwen3.5-4B 已报 merge+convert 后输出发散(前 20-30 token 对、之后崩)。GDN 的 recurrent state + causal conv1d kernel 是公认跨实现痛点,端侧量化/转换不成熟。
  - 证据: mlx-lm issue#1058(4B merge+convert 发散);SGLang-JAX 把 gated-delta/causal-conv1d kernel 列为 out-of-scope follow-up;mlx 团队文档承认 hybrid attention/prompt caching 'rough edges'
  - 缓解: 若切 2B,P1-B spike 必须加'LoRA-merge→量化→端侧 readback 一致性'验证关(不只验 base 推理);1.7B 是标准 Transformer,merge/量化/端侧链路成熟,无此风险。
- [MEDIUM] native VL 权重浪费 + 端侧裁剪工程:2B 是 early-fusion VL,带我们用不到的 vision encoder(~300M 推测)。MLX LoRA 训练里 vision 权重会 crash(4B 已实证需手剥),端侧部署还要真正裁掉 vision tower 才不白占包体/内存,而 early-fusion 架构裁 vision 比 bolt-on 难。
  - 证据: sciences44/mlx-lora-finetune '4B required manual vision weight stripping, vision weights crash MLX LoRA';--language-model-only 仅 vLLM 侧验证,端侧 MLX/llama.cpp 裁剪未确认
  - 缓解: 2B 训练时需手动剥 vision 权重(参照 4B 做法,2B 本身较轻可能侥幸过但不保证);端侧部署需验证 vision tower 可裁+包体实测。1.7B 纯文本无此包袱。

### paper-tigers
- thinking-loop 训练抑制:磊哥担心 2B thinking-loop,实际 Qwen3.5 0.8B/2B/4B/9B 小模型 reasoning 默认就 DISABLED(官方 model card),车控单跳非思考天然规避;训练时按非思考模板构造即可,不需特殊抑制工程。是 paper-tiger(看似威胁实际默认安全)。
- '本机无 GPU 不能训 2B':本机 mlx-lm 0.31.1 已内置 qwen3_5.py+gated_delta.py+lora 子命令,2B bf16 LoRA ~5GB 在 M5/32GB 可跑,有 sciences44 现成蓝本证明 Mac 无 GPU 能训通。不能训的是 unsloth(CUDA),不是 mlx-lm。是 paper-tiger,但代价是放弃 D30 已 adopt 的 unsloth 生态、走 GDN 无成熟配方的 mlx-lm 路径。
- 'transformers 版本不够':本机 transformers 5.6.1 已满足 Qwen3.5 要求的 v5+(>=5.2.0),无版本阻塞。

### adopt 候选
- [adopt] **守 Qwen3-1.7B 作 P1-C 训练主线(不切 2B)** — 训练侧三层证据收敛:(1)GDN 75% 层 LoRA 无成熟配方=核心能力盲区;(2)本机无 GPU,unsloth(D30 已锁栈)Apple Silicon 走不通,切 2B 要么换 mlx-lm 要么云上解 VL+GDN 双坑;(3)2B native VL 带无用 vision 权重(训练 crash+端侧需裁)+merge/convert 发散 bug。叠加 P1-B 已实测 2B S1 8/11 劣于 1.7B 9/11 → 2B 训练是净增成本无明显收益。1.7B 纯文本标准 Transformer,全层标准 q/k/v/o,unsloth 配方烂熟,merge/量化/端侧链路成熟,复用 D30 零改动。 ( 2026-06 联网+本机源码双证)
- [adapt] **sciences44/mlx-lora-finetune(若未来真要 2B 的本机蓝本)** — 现成可跑的 Qwen3.5-2B + MLX LoRA Mac 无 GPU 蓝本,证明 2B 本机可训。但只覆盖 text-to-SQL、未处理 GDN keys 自定义、未必走 function-calling masking。未来若切 2B 可 blueprint-teardown 它的 vision 权重处理+merge 链路,但需补 GDN keys 实验+车控 FC 数据配方。 ( 2026 活跃)
- [adapt] **mlx-lm 0.31.1 本机 lora 路径(2B 逃生口,非主线)** — 本机已内置完整 Qwen3.5 支持+GDN kernel+lora 子命令,M5/32GB 可训 2B bf16 LoRA(~5GB)。作为'若云 GPU 不可用且必须 2B'的逃生口可用,但需自己配 GDN keys、无官方配方、merge→端侧有发散风险。不作 P1-C 主线(主线守 1.7B+云 unsloth)。 ( 本机 2026-06 实测)
- [drop] **unsloth QLoRA(4-bit)训 Qwen3.5** — unsloth 官方明确'不推荐对 Qwen3.5 做 QLoRA 4-bit 训练'(量化差异+GDN Mamba Triton kernel 编译慢)。即使未来切 2B 也应走 bf16 LoRA 不走 QLoRA。对端侧'量化省内存'直觉是反的——量化留到训完部署阶段,不在训练阶段。 ( 2026-04 unsloth doc)

### grill 议题
- P1-C 训练目标是'模糊车控泛化+拒识',这能力主要落在模型的语义混合层。Qwen3.5-2B 75% 是 GDN 层、标准 LoRA 配方碰不到——你愿意为切 2B 付'自己实验 GDN keys 配方+无 held-out 保证'的代价吗,还是守 1.7B 全层可训更稳?
- D30 已锁 adopt unsloth+Hammer+xLAM 训练栈,而 unsloth 在本机 M5 无 GPU 跑不了、切 2B 还要解 VL 权重剥离+GDN keys。训练在云 GPU 跑的前提下,切 2B 值不值得动 D30 既定栈?还是 1.7B 直接复用零改动?
- P1-B spike 已实测 2B S1 8/11 劣于 1.7B 9/11(parser/TTFT),现在训练侧又发现 2B 是净增成本(GDN 盲区+VL 包袱+merge 发散)。是否可以现在就把'2B 选项'正式 close,P1-C 锁 1.7B,把精力集中在 C5 数据门+masking 三形态(真正的训练前置)?
- 若磊哥仍要保留 2B 未来选项:是否同意把它降级为'P2 之后的探索性 spike'(需先解 GDN keys 配方+VL 裁剪+merge 一致性三关),而不阻塞 P1-C 1.7B 主线训练?


---

## 训练 skills 生态 (adopt>build): 有没有现成的 LoRA 训练 skill/orchestrator 可直接 adopt 成 MAformac C5 训练 skill，避免手搓 P1-C 流程

- **联网搜索次数**: 13
- **一句话结论**: 不用手搓 P1-C 流程: 直接 adopt LTX-2 .claude/skills/train-model 的 phase 编排骨架(probe→plan-gate→sanity-check→train→eval-diff)+Hard Invariant #5(禁对训练结果下断言)作 MAformac C5 训练 skill 蓝本(7743★/2026-06-17 鲜); 训练栈本机 mlx-lm 0.31.1 已装可直接训 Qwen3-1.7B LoRA(32GB M5 绰绰有余), QAT/多算法升级用 mlx-lm-lora(车企背书); masking 三形态分流实现(单跳用 --mask-prompt, 多轮用 assistant_only_loss, 防记死用 Hammer name-mask); 拒识 adopt Hammer irrelevance-augment 空-list 配方。最大 tiger=mlx-lm --mask-prompt 多轮只 mask 最后一条 message(HIGH, 影响 failure/refusal 样本)。
- **本机 scout**: "Mac M5 + 32GB RAM。训练栈已就绪: mlx-lm 0.31.1 + mlx_lm.lora 二进制在 PATH(~/Library/Python/3.13/bin/), ~/.venvs/mlx-eval venv 存在。oMLX 0.3.6 已装(~/.omlx + DMG + 专门 skill 记 32K context 硬顶坑)——磊哥说的'omlx 跑 27B hermes'坐实=oMLX 本地推理 serve(给 Hermes agent), 是【推理栈】不是训练栈; ~/models/mlx-community/Qwen3.6-35B-A3B-4bit 已下载。ollama 已装(brew)但 ollama list 空。无 NVIDIA(unsloth/CUDA 本机不可, 但 MLX 路线本就为 Apple Silicon 设计, 不需要 unsloth)。结论: 本机直接能训 Qwen3-1.7B LoRA, 零额外硬件(M2Max 32GB 训 Mistral-7B QLoRA 峰值仅~7GB, 1.7B 更轻)。可选装 mlx-lm-lora(pip)拿 QAT+多算法。"
- **clone 深扒**: ~/workspace/raw/05-Projects/MAformac/ref-repos/hf-skills (huggingface/skills 全量 clone): huggingface-llm-trainer skill 是 738行 SKILL.md+10 references+8 scripts 的成熟训练 skill; references/local_training_macos.md 给本机 Mac LoRA 配方(float32 防 MPS NaN); dataset_inspector 训前校验门是 50%+ 训练失败防线; 整体走云 Jobs 故对 MAformac adapt 不 adopt(借校验/macOS配方/eval脚本, 弃云流程); /tmp/ltx-skill (Lightricks/LTX-2 sparse-clone .claude/skills/train-model, 蓝本只读未进 ref-repos——建议正式 adopt 时移入 ref-repos): 10-phase orchestrator-skill, SKILL.md 277行+4 phases+6 references; 核心可移植资产=phase 编排骨架(probe/plan-gate/sanity-check/eval-diff)+Hard Invariant #5(禁对训练结果断言)+post-train-validate 三类 eval(in-dist/OOD/held-out 只surface不判决); 视频扩散专属部分(process_dataset/conditioning/nvidia-smi)drop, 换 Apple Silicon mlx probe

### 关键发现
- LTX-2 的 .claude/skills/train-model 是一个生产验证过的 10-phase 训练 orchestrator-skill 蓝本(7743★, pushed 2026-06-17), 结构=SKILL.md(277行)+phases/(prepare-dataset/preprocess-dataset/launch-and-monitor/post-train-validate)+references/(mode-selector/onboarding/hardware-profiles/config-patching/troubleshooting/plan-template)。Phase 流: Phase0 Setup→1 Intent→2 Probe(filesystem+hardware+prereq)→3 Ask(最小问题集)→4 Plan(写plan.md+等批准)→5 PrepareDataset(captioning gate STOP)→6 SanityCheck+Autotune(单样本试跑+5-trial sweep)→7 FullPreprocess→8 Launch+Monitor→9 PostTrainValidate。这正是 MAformac C5 应该 adopt 的骨架(probe→plan-gate→sanity-check→train→eval-diff)。已 sparse-clone 到 /tmp/ltx-skill(蓝本只读)。VERDICT=adopt 结构/adapt 内容(LTX-2 是视频扩散模型 nvidia-smi 路径, MAformac 换 Apple Silicon mlx)。
  - source_url: https://github.com/Lightricks/LTX-2/tree/main/.claude/skills/train-model
  - freshness: pushed 2026-06-17, 7743★
  - confidence: high
- HuggingFace 官方 skills repo(huggingface/skills, 10700★, pushed 2026-06-19 昨天)含 huggingface-llm-trainer skill(SKILL.md 738行)+ trl-training skill。它走 TRL/Unsloth + HF Jobs 云 GPU(非 MLX), 但 references/local_training_macos.md 直接给 Mac 本地 LoRA 配方(PyTorch+MPS): 0.5-1.5B 首跑/seq≤512-1024/batch1+grad-accum8-16/LoRA r8-16 alpha=2r/dtype float32(fp16 在 MPS 会 NaN)/32GB 可跑 1.5-3B。关键工程点可 adopt: (1)dataset_inspector 训前校验(50%+ 训练失败是格式问题, CPU 校验 $0.01 vs GPU 失败 $1-10) (2)Hard rule: ephemeral 环境必 push 否则全丢(MAformac 对应=adapter 落盘) (3)成本估算脚本。VERDICT: 整体 adapt(云 Jobs 不适用本机离线), 但 dataset 校验门/macOS 配方/eval 脚本 adopt。
  - source_url: https://github.com/huggingface/skills/blob/main/skills/huggingface-llm-trainer/SKILL.md
  - freshness: pushed 2026-06-19, 10700★
  - confidence: high
- MLX-native 训练栈本机已就绪+有更强的第三方包: 本机已装 mlx-lm 0.31.1(mlx_lm.lora 二进制在 PATH, 含 --mask-prompt/--fine-tune-type lora,dora,full/--grad-checkpoint/--num-layers/--mask-prompt)。更强的 mlx-lm-lora(Goekdeniz-Guelmez, 380★, pushed 2026-06-16) 是 MLX-native power tool: 12 训练算法(SFT/DPO/ORPO/GRPO等)+ QAT(量化感知训练, 4-16bit, project weights onto quantized grid, 对 MAformac 4-bit 端侧部署直接有用)+ --mask-prompt 对 assistant 输出做 loss masking + YAML config。被 Mercedes-Benz/Daimler Truck 采用(车企背书)。配套 MLX-LoRA-Studio(SwiftUI 原生 Mac App, 136★, pushed 2026-06-19 昨天, vendored mlx-lm-lora, GUI=YAML view 可导出 CLI)。VERDICT: mlx-lm 0.31.1 已够 baseline; mlx-lm-lora adopt 给 QAT+多算法; Studio 可选(GUI 对 demo 不必需)。
  - source_url: https://github.com/Goekdeniz-Guelmez/mlx-lm-lora
  - freshness: mlx-lm-lora pushed 2026-06-16 380★ / MLX-LoRA-Studio 2026-06-19 136★ / 本机 mlx-lm 0.31.1 已装
  - confidence: high
- masking 三义必须分清(MAformac C5 data gate 的 masking_coverage 全 false 这一硬前置): (1)loss-masking/completion-only = 只在 assistant/ToolCall 输出算 loss, 忽略 prompt token。机制=PyTorch -100 ignore index 或 chat template {% generation %}/{% endgeneration %} 标签。TRL assistant_only_loss=True 对 Qwen3 会自动 patch 模板。关键: 短 completion(如 terse function call/ToolCallFrame)masking 影响最大(arXiv 2401.13586 证短completion masking 有显著正效应, 长 completion 可忽略)→ MAformac 的 ToolCall 输出短, masking 是必做不是可选。(2)Hammer function-masking(arXiv 2410.04587, MadeAgents)= 遮蔽函数名/参数名强制模型看 description 防过拟合命名约定, 与 loss-masking 不同。(3)train_on_turn masking(多轮逐 assistant turn)。MAformac 三形态应= prompt-mask(loss only on ToolCall)+ Hammer name-mask(防记死 device 名)+ failure/refusal turn-mask。
  - source_url: https://arxiv.org/html/2401.13586v2
  - freshness: TRL docs 2026 + arXiv 2401.13586 + Hammer 2410.04587
  - confidence: high
- irrelevance/拒识训练有现成配方(对应 C6 base hard_fail IrrelAcc 0.789<0.9 这个诚实锚点): Hammer 的 xlam-irrelevance-7.5k 数据集做法= 从原训练集采样 7500 例, 故意把正确函数从候选集移除, label 替换成空 list, 训模型学会'无合适工具时弃权'。论文实证: 纯 function-calling 训练会与 irrelevance detection 形成 inverse relationship(精做会牺牲拒识), 必须 irrelevance-augment 才能两者兼得。比例 7.5k/60k≈12.5% 是参考值需按模型调。VERDICT: MAformac C5 应 adopt 此配方——12000 bug 真实说法+空匹配样本喂拒识, 加权采样(已在 MEMORY 提及)。
  - source_url: https://arxiv.org/abs/2410.04587
  - freshness: Hammer arXiv 2410.04587 + GitHub MadeAgents/Hammer 活跃
  - confidence: high
- LTX-2 train-model 的 Hard Invariant #5 是 MAformac 直接可抄的元规则: '禁止对训练结果/数据是否充足做断言'(No fabricated claims about training outcomes or data sufficiency)——不说'会训得多好'/'数据太少'/'哪个模态学得好', 只陈述可证实的事实(loss/step time/VRAM/计数/用户目标)。post-train-validate phase 配套: 渲染 3 类 prompt(in-distribution/out-of-distribution/held-out) 后只 surface 路径不下判决, 不问 pass/fail 不推断失败原因。这与 MAformac '验收以读回 mock 态为准'+'诚实锚点'同源, 且防 happy-path bias。VERDICT: adopt Hard Invariant #5 + 三类 eval(对应 MAformac eval-diff: base vs LoRA 在 train-set/OOD/held-out 三轴)。
  - source_url: https://github.com/Lightricks/LTX-2/blob/main/.claude/skills/train-model/phases/post-train-validate.md
  - freshness: pushed 2026-06-17
  - confidence: high
- 本机环境实况(scout 坐实, 不凭猜): Mac M5 + 32GB RAM。oMLX 0.3.6 已装(~/.omlx, DMG, 跑过 Qwen3.6-35B-A3B-4bit, 有专门 skill 记录 32K context 硬顶坑)——磊哥说的'omlx 跑 27B hermes 大模型'坐实=oMLX serve 本地推理服务器(给 Hermes agent 用), 是推理栈不是训练栈。mlx-lm 0.31.1 + mlx_lm.lora 已装可直接训。~/models/mlx-community/Qwen3.6-35B-A3B-4bit 已下载。~/.venvs/mlx-eval venv 存在。ollama 已装(brew)但无模型。无 NVIDIA(确认 unsloth/CUDA 不可本机, 但 unsloth 可云跑或本机用 mlx 替代)。32GB 跑 Qwen3-1.7B LoRA 绰绰有余(M2Max 32GB 训 Mistral-7B QLoRA 5000样本~90min 峰值~7GB, 1.7B 更轻)。
  - source_url: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md
  - freshness: 本机 scout 2026-06-20 + mlx-lm 5979★ pushed 2026-06-12
  - confidence: high

### tigers (坑点)
- [HIGH] mlx-lm 原生 --mask-prompt 对 chat 数据集只把【最后一条 message】当 completion 算 loss, 多轮 function-calling(ToolCall→tool result→再 assistant)只 mask 到最后一条 → MAformac 的 failure-recovery/多轮锁域样本 masking 不正确, loss 算在了中间 user/tool token 上
  - 证据: mlx-lm LORA.md 明文: 'for chat datasets the final message in the message list is considered the completion'。MAformac C5 receipt 含 failure/refusal 多轮样本。验证清单: 拿一条 MAformac 多轮样本喂 mlx_lm.lora --mask-prompt, 打印 masked labels 看是否每个 assistant turn 都 -100 了中间 user/tool。若否→改用 mlx-lm-lora(--mask-prompt 文档说 apply loss only to assistant responses 复数, 支持多 turn)或 TRL assistant_only_loss=True(Qwen3 自动 patch {% generation %} 模板)
  - 缓解: C5 masking 三形态实现时, 单跳 ToolCall 样本(占多数)用 mlx-lm --mask-prompt 够; 多轮 failure/refusal 样本改用 mlx-lm-lora 或 TRL assistant_only_loss; 或干脆把多轮拆成单跳 prompt-completion(MAformac 禁自由 agent loop, 本就单跳为主, 多轮主要是 clarify 二次交互)。落 C5 spec 时按样本类型分流 masking 实现
- [MEDIUM] Qwen base checkpoint 若无 chat_template, mlx_lm.lora 训 tools 直接 ValueError 崩 (tokenizer.chat_template is not set)
  - 证据: mlx-examples Issue #1243 'chat_template not set when using lora to train tools' 实录此崩溃。Qwen3 instruct 变体自带模板(含 <tool_call>/</tool_call> 标签)但 base 变体可能没有。验证清单: python -c 'from transformers import AutoTokenizer; print(AutoTokenizer.from_pretrained("<本机Qwen3-1.7B路径>").chat_template)' 看是否非空
  - 缓解: 用 Qwen3-1.7B-Instruct 变体(自带 tool-call 模板)而非纯 base; 或显式传 --chat-template。C5 spike 起手先验模板存在
- [MEDIUM] masking 是 C5 data gate 的硬前置(masking_coverage 全 false), 但若实现时只做了 loss-masking 漏了 Hammer name-masking → 模型记死 device 名(如'空调'/'AC'字面), 客户换说法(L1 vs 训练泛化范围)就崩, demo 不丢脸目标落空
  - 证据: Hammer 论文实证: 无 name-masking 模型 overfit 命名约定, 跨场景泛化崩; larger mask ratio 更好泛化。MAformac MEMORY 已记 L1 精做范围≠训练泛化范围(模型吃 3990 全集大范围泛化)。验证清单: 训后拿训练集没出现过的 device 别名(如'冷气'代'空调')测, 看是否还能映射
  - 缓解: C5 masking 三形态须含 Hammer-style name-mask(遮蔽 device/function 名强制看 description), 不只 loss-mask。adopt MadeAgents/Hammer 的 function-masking 实现(注意是改输入+同步改 label 不是改 loss)
- [LOW] adopt LTX-2/HF skill 是 Python/Node 资产, MAformac 红线 Python 零进 iOS
  - 证据: CLAUDE.md §6 红线。但 paper-tiger 见下——训练侧本就不进 iOS
  - 缓解: 训练 skill 只吸收【设计/配方/phase 编排】, 训练本身在开发机(Mac M5)跑, 产物=LoRA 权重(safetensors)→ fuse → 转 MLX 格式上 iOS。skill 文件是 .claude/skills/ 下的 markdown 编排不是 runtime 代码, 不进 iOS bundle

### paper-tigers
- 'adopt LTX-2 train-model 会把视频扩散依赖带进来' = 假威胁。只 adopt SKILL.md 的 phase 编排结构(probe→plan-gate→sanity→train→eval-diff)+ Hard Invariant 元规则, 不抄 ltx-trainer 的 process_dataset.py/conditioning 那套视频专属。phase 文件是 markdown 流程文档(SKILL.md 自己说 'they are not standalone skills, never invoked by skill-discovery, orchestrator opens them via Read tool'), 纯编排逻辑, 跨域可移植
- '本机无 NVIDIA 所以 unsloth/CUDA 不能用 = 不能训 LoRA' = 假威胁。MLX 路线本就为 Apple Silicon 设计, 32GB M5 训 Qwen3-1.7B LoRA 远超需要(M2Max 训 Mistral-7B QLoRA 峰值仅~7GB)。unsloth 只是 CUDA 路线的加速器, MLX 有等价能力(mlx-lm-lora QAT/多算法)。MAformac 不需要 unsloth 本机跑
- 'HF skill 走云 Jobs 需要 HF Pro 付费 + 联网, 违反 MAformac 离线红线' = 半假威胁。MAformac 离线红线是【推理/部署/iOS runtime】离线, 训练阶段在开发机跑允许联网(下 base 权重/参考实现)。但确实 HF Jobs 云 GPU 路线对 MAformac 过重——本机 MLX 已够, 所以 HF skill 是 adapt(借 dataset 校验/eval 配方) 不是 adopt 整体云流程
- 'mlx-lm-lora 只 380★ 是小众克隆存疑' = 假威胁(经新鲜度+背书交叉验证)。pushed 2026-06-16 活跃, 作者是 mlx-lm/mlx-examples 官方 contributor(在 mlx-lm 致谢名单), 被 Apple/IBM/Mercedes-Benz/Daimler Truck 采用。star 低是因为 niche(MLX 训练本就小众), 但血统+背书+新鲜度三好

### adopt 候选
- [adapt] **LTX-2 .claude/skills/train-model (orchestrator-skill 蓝本)** — adopt phase 编排骨架(Setup/Intent/Probe/Ask/Plan-gate/SanityCheck+Autotune/Preprocess/Launch+Monitor/PostTrainValidate)+Hard Invariant #5(禁对训练结果/数据充足度断言)+post-train-validate 三类 eval(in-dist/OOD/held-out 只 surface 路径不下判决)。adapt: 去掉视频扩散专属(process_dataset/conditioning), nvidia-smi→Apple Silicon mlx probe, plan.md 写文件+等批准这种多人 ceremony 可砍(solo demo)。已 sparse-clone /tmp/ltx-skill 只读 (https://github.com/Lightricks/LTX-2/tree/main/.claude/skills/train-model 7743★, pushed 2026-06-17)
- [adapt] **huggingface/skills - huggingface-llm-trainer** — adopt: dataset_inspector 训前格式校验门(50%+ 训练失败是格式问题, CPU 校验廉价)、references/local_training_macos.md 的 Mac LoRA 配方(float32 防 MPS NaN/r8-16/grad-accum)、eval_generate 脚本模式、成本估算思路。drop: HF Jobs 云 GPU 整体流程(MAformac 本机 MLX 已够, 云流程过重)。已 clone ref-repos/hf-skills (https://github.com/huggingface/skills 10700★, pushed 2026-06-19)
- [adopt] **mlx-lm-lora (Goekdeniz-Guelmez)** — MLX-native 训练 power tool: --mask-prompt(多 assistant turn loss masking, 比 mlx-lm 原生只 mask 最后一条强)+QAT(4-16bit 量化感知训练, 对 MAformac 4-bit 端侧部署直接有用)+12 算法+YAML config。车企(Mercedes/Daimler)背书+作者是 mlx-lm 官方 contributor。用于 C5 train 的 masking 正确性+部署前 QAT (https://github.com/Goekdeniz-Guelmez/mlx-lm-lora 380★, pushed 2026-06-16)
- [adopt] **本机 mlx-lm 0.31.1 (mlx_lm.lora)** — 本机已装在 PATH, 零新依赖。含 --mask-prompt/--fine-tune-type lora,dora,full/--num-layers/--grad-checkpoint/--mask-prompt。C5 数据门+首次 train 直接用它最快验通(32GB M5 训 1.7B LoRA 绰绰有余)。注意 --mask-prompt 多轮只 mask 最后一条的限制(见 tiger) (https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md mlx-lm 5979★ pushed 2026-06-12, 本机 0.31.1 已装)
- [adopt] **MadeAgents/Hammer (function-masking + irrelevance-augment)** — 已在 MAformac MEMORY 引用。adopt 两配方: (1)function-masking 遮蔽函数/参数名强制看 description 防过拟合命名约定(MAformac 防记死 device 名, 对应 C5 masking 三形态之一) (2)irrelevance-augment 空-list 配方(7.5k/60k≈12.5% 比例, 喂拒识, 对应 C6 base IrrelAcc 0.789 hard_fail 的提升路径)。注意是改输入+同步改 label, 非改 loss (https://github.com/MadeAgents/Hammer arXiv 2410.04587 + GitHub MadeAgents/Hammer 活跃, Hammer2.1-1.5b 已出)
- [drop] **MLX-LoRA-Studio (native Mac GUI)** — SwiftUI 原生 Mac App(vendored mlx-lm-lora, GUI=YAML view)。对 MAformac C5 是可选不必需——CLI(mlx-lm-lora)已够且更可脚本化/可复现(skill 编排需 CLI 不需 GUI)。drop 但记录: 若磊哥要手调超参可视化再考虑 (https://github.com/Goekdeniz-Guelmez/MLX-LoRA-Studio 136★, pushed 2026-06-19)

### grill 议题
- C5 训练 skill 到底要不要建成 LTX-2 那种 10-phase orchestrator-skill, 还是 MAformac solo demo 轻治理只需一个 train.sh + 一份 spec? (blueprint-teardown star>1000 不降级 vs fresheveryday 反元治理过载——LTX-2 phase-gate 是给陌生用户防误删几小时数据集设计的, MAformac 是磊哥自己跑, plan-approval gate 可能是 over-ceremony。我倾向 adopt【probe+sanity-check+eval-diff 三个工程价值 phase】, drop【plan.md 写文件+等批准】这种多人协作 ceremony)
- masking 三形态分流实现: 单跳 ToolCall 用 mlx-lm --mask-prompt(够), 多轮 failure/refusal 用 mlx-lm-lora/TRL assistant_only_loss, name-mask 用 Hammer 式改输入。这个分流要不要写进 C5 spec 的 masking_coverage 验收(每种 mask 形态各有 fixture 样本验通过)? 还是先只做 loss-mask 跑通再补 name-mask?
- 训练栈最终定 mlx-lm 0.31.1(本机已装, baseline) 还是 mlx-lm-lora(+QAT, 车企背书, 但多依赖)? 我倾向: C5 数据门+首次 train 用本机 mlx-lm(零新依赖最快验通), QAT 提升留到端侧部署前用 mlx-lm-lora 补(4-bit on-device 才需 QAT)。要不要两阶段?
- eval-diff(base vs LoRA)要不要 adopt LTX-2 的三轴(in-distribution/OOD/held-out)? C6 已有 vehicle-tool-bench(IrrelAcc/覆盖率双轴)。两者关系: C6 是【全集覆盖+拒识】死门, LTX-2 三轴是【泛化 vs 记忆】诊断。我建议 C6 死门不变, 额外加 held-out vs train-set 的 eval-diff 作泛化诊断(防记死), 对应 C5 的 held-out 1200 行已 split 好


---

## 训练坑点 oracle（GitHub issues 深挖 + Mac mlx 实况 scout）：以 MAformac 实际栈（Qwen3-1.7B 非 9B/非 Qwen3.5 + mlx-lm 0.31.1 + M5/32GB/macOS 26.6 + GOAT arg-masking 计划）为锚，逐条核对哪些社区坑命中 1.7B 路径、哪些是别的模型/尺寸的坑被误当成 1.7B 的坑。

- **联网搜索次数**: 11
- **一句话结论**: P1-C 训 Qwen3-1.7B 本机 mlx-lm 路径可行(omlx=mlx-lm 已装、M5/32GB/macOS26.6 全满足)，但有 4 个 HIGH 真坑必须先解：①GOAT arg-masking 本机原生 --mask-prompt 做不到(只 message 粒度)，masking 硬前置的真实工程量被低估，需拆轮弱版或 fork 训练循环；②Qwen3 thinking↔tool-call 模板训/推不一致(建议锁 no-think 单跳并三处口径逐字对齐);③LoRA fuse 进 4bit 掉行为(需 fuse 前后行为对账或走 bf16训→fuse→再量化);④小数据 over-memorization 骗过 eval(held-out 必须真 OOD、epoch 1-3+early-stop)。而 M5 训练崩(#1206)是 Qwen3.5-9B 专属、训 1.7B 不命中=paper-tiger(但磊哥若试 2B 训练立即变 tiger，须先 smoke 验 backward)。
- **本机 scout**: 本机实况已坐实（不靠猜）：(1) "omlx"=mlx-lm，本机已装 mlx-lm 0.31.1 + mlx 0.31.2，`mlx_lm.lora`/`mlx_lm.fuse` 在 PATH，`models/qwen3.py` 在场 → Qwen3-1.7B LoRA 本机可跑。(2) 硬件 = Apple M5 / 10 核 / 32GB 统一内存 / Metal 4 / macOS 26.6（≥26.2，M5 Neural Accelerator 满足）。无 NVIDIA → unsloth/CUDA 不可本机跑（吻合磊哥红线，训练侧只吸收配方）。(3) HF cache 已有 Qwen3-1.7B-4bit、Qwen3.5-2B-4bit、Qwen3.6-35B-A3B-4bit/8bit（35B MoE 就是磊哥说"用 omlx 跑过的大模型"，非 hermes-27B；27b 痕迹全是 hermes-agent 中转站文件无关本地大模型）。(4) `mlx_lm.lora --help` 确认：原生有 `--mask-prompt`、`--num-layers`(默认16)、`--grad-checkpoint`、`--fine-tune-type lora/dora/full`、`--grad-accumulation-steps`。(5) Qwen3-1.7B-4bit 的 tokenizer_config chat_template 实测含 `<think>`/`enable_thinking`/`tool_call`/`tools` → thinking 模式 + tool-call 模板交互在本机真实存在。(6) Qwen3-1.7B 架构 = 28 层 hidden 2048 → 默认 `--num-layers 16` 只挂后 16 层，漏掉前/中层。

### 关键发现
- 原生 --mask-prompt 只在 message 粒度遮蔽（chat 数据集里只把『最后一条 message』当 completion 算 loss），不是 token-span 粒度。MAformac 计划的 GOAT 式『遮蔽参数 token 值、只训 call 结构』本机 mlx-lm 原生做不到——需要自写 token-level loss mask 或把数据集重构成『每个 assistant/tool-call 轮拆成独立样本』。这是 masking_coverage 硬前置的真实工程量来源。
  - source_url: https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md
  - freshness: main 分支文档(活跃)
  - confidence: high
- Qwen3 thinking 模式 ↔ tool-call 模板存在训练/推理不一致坑：社区 21-fix(#1831) 实证『有 tools 时应自动关 think / enable_thinking=False 多 assistant 轮时首轮漏 think token / KV-cache 复用在 enable_thinking=false 下崩』。本机 Qwen3-1.7B chat_template 实含 <think>+tools → 数据准备时的 apply_chat_template(enable_thinking) 必须和推理端口径逐字一致，否则训出来推理崩。
  - source_url: https://github.com/QwenLM/Qwen3/issues/1831
  - freshness: 2026 活跃 issue
  - confidence: high
- LoRA fuse 进 4-bit 量化模型会丢学到的行为(#654：adapter 动态加载时行为在、fuse 后丢)。--dequantize 路径本身在某些版本有 NameError('dequantize')/KeyError('quant_method') 崩(#659)。MAformac 本机就是 Qwen3-1.7B-4bit，mlx-swift 推理要 fuse 产物 → fuse 步骤是『训练 PASS 但部署崩/掉点』的高发段。
  - source_url: https://github.com/ml-explore/mlx-lm/issues/654
  - freshness: 2026 issue(部分未修)
  - confidence: high
- mlx-lm --num-layers 默认 16 = 只挂模型『末尾 16 层』。Qwen3-1.7B 有 28 层 → 默认漏前 12 层(含研究证明最关键的中层)。要全覆盖须 --num-layers -1。另有历史 bug：--num-layers 被无视(#1328)/MoE 专家层不挂 LoRA 只 0.02% 可训(#571，对 35B MoE 相关，对 1.7B dense 不命中)。
  - source_url: https://github.com/ml-explore/mlx-examples/issues/1328
  - freshness: 活跃 issue
  - confidence: high
- Issue #1206『LoRA 训练首个 backward pass 在 M5 Max(applegpu_g17s) 崩 [METAL] Insufficient Memory』——但这是 Qwen3.5-9B-4bit 专属；同设置换 Qwen3-8B-4bit 正常。是 Qwen3.5 架构 + 9B 尺寸的 Metal bug，不是 M5 通病。MAformac 训 Qwen3-1.7B(非 3.5、1.7B≪9B) → 不命中(paper-tiger)；但若磊哥真去试 Qwen3.5-2B 训练，这条变 tiger。
  - source_url: https://github.com/ml-explore/mlx-lm/issues/1206
  - freshness: 2026 新 issue
  - confidence: high
- 小模型小数据 FC 微调核心张力=死记 vs 泛化。文献共识：(1)epoch 1-3 + early-stopping(>3 epoch 小数据必过拟合)；(2)GOAT 实证『遮蔽 argument token loss』比 self-distillation 更有效防死记参数值、逼学 call 结构；(3)降 LoRA rank 直接降记忆但降容量；(4)存在 over-memorization——test 困惑度高但 test 准确率仍好，会骗过常规 eval，必须用 OOD(新参数值/未见工具组合)验。映射 MAformac：2320 train 行偏小，必须 held-out 用 OOD 而非近邻样本。
  - source_url: https://arxiv.org/pdf/2510.12218
  - freshness: GOAT 2025-10
  - confidence: high
- FC 微调引发灾难性遗忘+触发判断失衡：Alopex/Pelican 实证 FC 微调后 MMLU/GSM8K 等通用能力暴跌、只会 FC。两个对偶失效——over-trigger(该直答却调工具)/under-trigger(该调却拒/手算/幻觉)。最毒的真实案例：在偏斜数据上微调后『模型拒绝调用这些函数，改为手算或幻觉』根因=训练数据没覆盖该函数。直接映射 MAformac IrrelAcc 0.789 hard_fail：必须配平四类样本(需工具/直答/不相关拒识/通用 rehearsal)，缺一类就触发判断崩。
  - source_url: https://arxiv.org/pdf/2411.05209
  - freshness: Alopex 2024-11/2026 综述
  - confidence: high
- NaN loss 高发配置=scale/alpha 过大(实证 scale=10.0+alpha=128+lr=7e-5 直接 NaN)；OOM 解药=--batch-size 1 + --grad-checkpoint + 降 max-seq-length + 降 num-layers。MAformac 1.7B/32GB 余量大，OOM 风险低，但 alpha/scale/lr 配置不当仍会 NaN。
  - source_url: https://github.com/ml-explore/mlx-examples/issues/620
  - freshness: issue(配置坑长期有效)
  - confidence: high
- FC 微调最大评测陷阱=数据泄漏使分数虚高(GPT-2 实测污染 benchmark 高 15 个百分点；agentic harness 本身能移动分数 10-20 点而模型权重不变)。污染会沿 dataset lineage 递归传播。MAformac C6 已做 parent_overlap=0(正是文献要求的去污护栏)——必须守住 train 2320/heldout 1200 的 parent_overlap=0 不被后续数据增广破坏，否则 C5 提升=记忆不是泛化。
  - source_url: https://arxiv.org/html/2502.14425v2
  - freshness: 2026 综述
  - confidence: high
- 训练数据 JSONL 格式必须产出与推理逐 token 一致的串：LLaMA-Factory 内置 tool 处理产 Qwen2.5 格式，会训出模型推理时从没见过的 tool-call 格式(致命静默 bug)。Qwen3 dense(含1.7B)用 Hermes 式 JSON-in-XML(<tool_call>{name,arguments}</tool_call>)，非 Qwen3-Coder 的原生 XML。最稳=用本机真实 Qwen3-1.7B chat_template.jinja 渲染后逐字校验再训。
  - source_url: https://huggingface.co/datasets/PGCodeLLM/ccr-bench/blob/main/README.md
  - freshness: 活跃数据集 README
  - confidence: high
- chat_template not set 报错(#1243)：mlx_lm.lora 训 tools 时若 tokenizer 无 chat_template 直接 ValueError；本机 Qwen3-1.7B 自带模板不命中，但若用 base(非 instruct)或自定义模板路径会炸。另 #1313：有用户报 --mask-prompt 在 CLI/yaml 不生效/无效果 → 加了 mask 必须实测验证(打印 loss mask 或对比 masked/unmasked loss 曲线)，别假设生效。
  - source_url: https://github.com/ml-explore/mlx-examples/issues/1243
  - freshness: 2025 issue
  - confidence: medium

### tigers (坑点)
- [HIGH] GOAT 式 argument-token 遮蔽本机 mlx-lm 原生做不到——masking_coverage 三形态的真实工程量被低估。原生 --mask-prompt 只 message 粒度(只算最后一条 message)，无法『遮参数值 token、训 call 结构』也无法在多 tool-call 轮上正确遮蔽中间轮。
  - 证据: mlx-lm LORA.md 明文『for chat datasets the final message is considered the completion』；搜索确认需自写 token-level mask 或把每轮拆独立样本。本机 --help 只有 --mask-prompt 无 per-token/loss-weight 旗标。
  - 缓解: 三选一并实测：(a)数据集重构=每个 assistant tool-call 轮拆成独立 {prompt, completion} 样本，再用 completion 数据集 + --mask-prompt(此时 completion=单轮 call，arg 值仍在 loss 里=只防多轮串扰不防 arg 死记)；(b)真要 GOAT arg-masking 须 fork mlx-lm 训练循环加 token-level loss mask(把 arguments 的 JSON value token 的 loss 乘 0)；(c)退而求其次用 mlx-lm-lora(Goekdeniz-Guelmez)第三方包看是否暴露更细 mask。先做 (a) 拿基线，(b) 作为 C5 提升手段。把『masking 实测验证』(打印 mask/对比 masked vs unmasked loss 曲线)写进数据门验收，不假设 flag 生效(#1313 实证有人 flag 不生效)。
- [HIGH] Qwen3 thinking 模式 ↔ tool-call 训练/推理模板不一致，训出来推理崩或 <think> 泄漏进 tool-call。
  - 证据: Qwen3 #1831 21-fix 实证『有 tools 应自动关 think / multi-assistant + enable_thinking=False 首轮漏 think token / KV-cache 在 enable_thinking=false 崩』；本机 Qwen3-1.7B chat_template 实测含 <think>+enable_thinking+tool_call。
  - 缓解: 锁定单一口径并贯穿数据准备+训练+mlx-swift 推理：车控 demo 走 no-think(/no_think 或 enable_thinking=False，单跳 FC 不需 CoT，也省 TTFT)。数据集渲染用本机真实 Qwen3-1.7B chat_template.jinja + 与 demo 一致的 enable_thinking 值，渲染后逐字 diff 推理端实际输入。验收加一条：训练样本里不得含未配对的 <think> 块。
- [HIGH] LoRA fuse 进 4-bit 量化模型掉学到的行为 / --dequantize 路径在某些版本崩——『训练 PASS 但部署到 mlx-swift 后效果丢』。
  - 证据: mlx-lm #654 fuse 后丢行为(adapter 动态加载在、fuse 丢)；#659 --dequantize NameError/KeyError。MAformac 本机就是 Qwen3-1.7B-4bit，spike-e3 mlx-swift 推理需 fuse 产物。
  - 缓解: 两道护栏：(1)fuse 前后做行为对账=同一批 must_pass/held-out 样本，分别用『base+adapter 动态加载』vs『fused 模型』各跑一遍，ToolCall 集合精确匹配率必须一致(差>2% 即 fuse 掉点，回退动态 adapter 或换 dequantize 再量化)。(2)优先在『非量化 bf16 base 上训 LoRA → fuse → 再量化到 4bit』而非『直接在 4bit base 上训再 fuse』，规避 4bit fuse 掉点路径。fingerprint(权重 hash)记进 trace 供回溯。
- [HIGH] 小数据(2320 train)死记 + over-memorization 骗过 eval：常规 held-out 准确率好看但 OOD(新车型参数值/未见设备组合/方言变体)崩。
  - 证据: 文献实证 over-memorization『test 困惑度高但 test 准确率仍好』骗过常规指标；GOAT 实证 arg-masking 防参数值死记；1.7B 28 层模型在 2320 行上易快速记住。
  - 缓解: held-out 1200 必须是 OOD 而非近邻(已 parent_overlap=0 是对的，守住别被后续 LLM 增广破坏)。epoch 1-3 + early-stopping(loss 100 步内陡降、300-500 步应平；500 步还降才加 iters)。bench 必含『新参数值/未见设备×动作组合』的泛化分桶 + IrrelAcc 拒识桶，不只测命中。LoRA rank 从中低(8-16)起，别一上来 64+。

### paper-tigers
- M5 训练首 backward pass [METAL] Insufficient Memory 崩(#1206)——是 Qwen3.5-9B-4bit 专属架构 bug，同设置换 Qwen3-8B-4bit 正常。MAformac 训 Qwen3-1.7B(非 3.5、1.7B≪9B、32GB 余量足、validation 已能过) → 不命中。证据：#1206 明确 9B 崩/8B 同代不崩，是 Qwen3.5 架构 + 大尺寸的 Metal bug。【但反向警示=tiger：磊哥若真去试训 Qwen3.5-2B，这条立即变 tiger，须先小批 smoke 验 backward pass 不崩再上量】。
- M5/Metal 4 训练侧通用回归 bug——搜遍 ml-explore/mlx + mlx-lm 0.31.x 没有训练/adapter 侧 M5 回归；现存 0.31.x 稳定性 issue 全是推理侧(DeepSeek-V4 解码 Metal residency #1332 / mlx_lm.server KV-cache 限制)。本机 macOS 26.6≥26.2 满足 M5 Neural Accelerator。证据：搜索明确『没找到 0.31 训练/LoRA 的 M5 回归』+ 实践者 M2 Pro/16GB 同版本训练成功。
- MoE 专家层不挂 LoRA 只 0.02% 可训(#571)——是 Qwen3-30B-A3B 等 MoE 变体专属；MAformac 训 Qwen3-1.7B dense 不命中。证据：#571 明确针对 MoE expert MLP 的 linear_to_lora_layers 检测失败，dense 模型走正常 attention+MLP 投影路径。
- unsloth/CUDA 不可本机跑=训练 blocker——本机无 NVIDIA 确认，但这是预期且吻合磊哥红线(训练侧只吸收配方/在开发机或云跑/产物=LoRA 权重)。本机 mlx-lm 路径完全够训 Qwen3-1.7B LoRA(实践者证明 M2/16GB 都行，本机 M5/32GB 更宽)。证据：本机 mlx_lm.lora 在场 + qwen3.py 支持 + 32GB 足训 1.7B。

### adopt 候选
- [adopt] **mlx-lm 原生 LoRA(0.31.1，本机已装)** — 本机 omlx=mlx-lm 实锤，qwen3.py 支持 Qwen3-1.7B，--mask-prompt/--num-layers/--grad-checkpoint 齐全，M5/32GB/macOS26.6 满足。是 P1-C 训练的默认主栈，无需另装。 (https://github.com/ml-explore/mlx-lm 0.31.1 2026-03 活跃)
- [adapt] **GOAT argument-token masking 配方** — 防死记参数值的最有效手段(实证优于 self-distillation)，但本机 mlx-lm 原生 --mask-prompt 做不到 token 级——需 adapt：要么数据集拆轮弱版，要么 fork 训练循环加 token-level loss mask。是 masking 硬前置的方法学源。 (https://arxiv.org/pdf/2510.12218 2025-10 arXiv)
- [adapt] **mlx-lm-lora (Goekdeniz-Guelmez 第三方训练套件)** — 暴露 --use-chat-template + --mask-prompt 等更细旗标，且支持 DPO/GRPO；若原生 mask 不够细可评估它是否给 token 级 mask。但是第三方需验新鲜度+稳定性再 adopt，不默认进主栈。 (https://github.com/Goekdeniz-Guelmez/mlx-lm-lora PyPI 活跃需核 pushedAt)
- [adapt] **Qwen3 社区 21-fix chat_template (#1831)** — 修 thinking↔tool-call 模板的已知 bug(自动关 think/多轮 think token/KV-cache)。MAformac 若走 no-think 单跳 FC 可能不需全部，但数据渲染前应核本机模板是否含这些 bug 路径，按需 adapt。 (https://github.com/QwenLM/Qwen3/issues/1831 2026 活跃)
- [adapt] **unsloth Qwen3 fine-tune 超参指南** — epoch 1-3/小数据 early-stop/小 batch 正则化/低 rank 防记忆等超参经验适用，但 unsloth 引擎本身 CUDA-only 本机跑不了——只吸收超参配方不用其代码(吻合红线)。 (https://unsloth.ai/docs/get-started/fine-tuning-llms-guide/lora-hyperparameters-guide 2026 文档活跃)

### grill 议题
- masking_coverage 三形态到底要哪一种？如果是 GOAT 式『遮 argument value token』，本机 mlx-lm 原生 --mask-prompt 做不到(只 message 粒度)——是接受『数据集拆轮 + --mask-prompt 防多轮串扰但 arg 值仍进 loss』的弱版先拿基线，还是 P1-C 就要 fork 训练循环加 token-level mask？这决定 masking 硬前置的真实工程量(几小时 vs 几天)。
- demo 走 think 还是 no-think？车控单跳 FC 不需 CoT，no-think 省 TTFT 且避开 Qwen3 thinking↔tool-call 模板一致性坑——但 trace/可解释会少 <think> 推理。建议锁 no-think，数据+训练+mlx-swift 推理三处口径用同一 enable_thinking 值，认同吗？
- LoRA 训完怎么进 mlx-swift？fuse 进 4bit 有掉行为风险(#654)。是接受『部署带 adapter 动态加载』(不 fuse、推理多一步但保行为)，还是要 fused 单文件(需做 fuse 前后行为对账 + 可能走 bf16 训→fuse→再量化路径)？这影响 spike-e3 推理集成方式。
- held-out 1200 的 OOD 程度够吗？parent_overlap=0 防了表面重叠，但若 held-out 只是 train 同模板换参数值，仍测不出 over-memorization。是否要专门划一桶『未见车型参数范围 + 未见设备×动作组合 + 方言变体』作真 OOD held-out？
- Qwen3.5-2B 训练选项要不要保留？P1-B spike 已实测 2B 推理劣于 1.7B(8/11 vs 9/11)，且 #1206 提示 Qwen3.5 架构在 M5 训练有 Metal 崩风险(虽 9B 专属)。是彻底锁 1.7B、还是留一个『2B 小批 backward-pass smoke 验崩不崩』的逃生口？


---

## Mac mlx 本机训练 Qwen3-1.7B LoRA 可行性 — 磊哥本机(M5/32GB)能不能训 LoRA,这是 P1-C 最关键决策

- **联网搜索次数**: 12
- **一句话结论**: 本机 M5/32GB 训 Qwen3-1.7B LoRA 完全可行且 over-provisioned(峰值 2-5GB、<15 分钟、mlx_lm.lora 已装就绪、4bit 基座已缓存);omlx=oMLX v0.3.6 推理服务器 GUI(非训练工具,跑过 35B 推理但与训练无关);真正前置门不是算力而是 C5 的 masking 三形态实现(stock --mask-prompt 只给单形态)+ 数据配方 + held-out 防过拟合 — 建议 P1-C 第一步直接跑 30 分钟本机冒烟训练拿真实数字,锁 Qwen3-1.7B(非 3.5,规避 #1206 的 M5 OOM 崩溃)。

### 关键发现
- omlx = oMLX v0.3.6,本地 MLX 推理服务器 GUI(非训练工具)。本机坐实:DMG=~/Downloads/oMLX-0.3.6-macos26-tahoe.dmg,配置 ~/.omlx/(绑 127.0.0.1:8000 OpenAI 兼容 / 单并发 / max_model_memory 22GB)。server.log 实证 2026-04-18 加载过 Qwen3.6-35B(19.95GB)给 Hermes 当后端。它无法训 LoRA — 训练靠另装的 mlx_lm.lora。
  - source_url: 本机 ~/.omlx/logs/server.log + ~/Downloads/oMLX-0.3.6-macos26-tahoe.dmg
  - freshness: 本机 2026-04-18 实跑日志
  - confidence: high
- 本机训练工具链已就绪:mlx_lm.lora + mlx_lm.fuse 已装(~/Library/Python/3.13/bin/),mlx 0.31.2 / mlx-lm 0.31.1。最新 0.31.3(2026-04-22 发布,<60天活跃)。模型注册表含 qwen3.py+qwen3_5.py(1.7B 和 2B 都可训)。mlx-community/Qwen3-1.7B-4bit 已在 HF cache(QLoRA 基座现成)。磁盘 217GB 空闲。
  - source_url: https://pypi.org/project/mlx-lm/ + 本机 pip show / which
  - freshness: mlx-lm 0.31.3 2026-04-22
  - confidence: high
- Mac M-series 训 LoRA 核心定位 = 不是更快,是内存够大。M3 Max 400GB/s vs RTX4090 1008GB/s,训练是带宽密集 Mac 每步慢但 1.7B 这种小模型绝对时间仍很短。
  - source_url: https://www.buildmvpfast.com/blog/mlx-apple-silicon-ai-development-mac-fine-tune-llm-2026
  - freshness: 2026
  - confidence: high
- 1.7B LoRA 训练内存极宽裕:实测 ~3B 模型 LoRA 峰值仅 5.04GB/3-4 分钟;7B QLoRA 峰值 ~7GB。1.7B 峰值预计 2-5GB,32GB 机器留 25GB+。磊哥本机 35B 推理才撞 22GB,1.7B 训练不在一个量级。
  - source_url: https://insiderllm.com/guides/fine-tuning-mac-lora-mlx/
  - freshness: 2026
  - confidence: high
- 小模型 FC LoRA 最强同类实证:Qwen2.5-1.5B base 经 LoRA 训 function-calling,JSON 合法率 73%→100%、整体准确率 3.40%→26.60%(6.28x)。这正是 MAformac 要做的(模糊车控→ToolCall 泛化),证明 1.7B 量级对 FC 任务有实质提升空间。
  - source_url: https://arxiv.org/pdf/2509.04518
  - freshness: 2025-09
  - confidence: high
- mlx_lm 原生支持 ToolCall/FC 数据格式:datasets.py 读 tools 键,经 apply_chat_template(messages,tools=tools) 注入工具定义。--mask-prompt 实现=只对消息列表最后一条 assistant completion 算 loss。chat/completion 两格式都支持 masking。
  - source_url: 本机 ~/Library/Python/3.13/.../mlx_lm/tuner/datasets.py:55-130
  - freshness: mlx-lm 0.31.1 源码
  - confidence: high
- 训练时长:1.7B FC LoRA 在 Mac 几百 iters 通常 <15 分钟(7B 在 M2 Pro 500 样本 ~20-25 分钟,1.7B 小 4-5 倍)。loss 一般 300-600 iters 收敛,默认 1000 iters 多数任务过量。
  - source_url: https://markaicode.com/run-fine-tune-llms-mac-mlx-lm/
  - freshness: 2026
  - confidence: high
- Qwen3 在 mlx 上无原生 GGUF 导出(--export-gguf 只支持 Llama/Mistral/Mixtral)。但 MAformac 端侧走 mlx-swift-lm 直接吃 MLX safetensors,根本不需 GGUF — mlx_lm.fuse 输出的 fused safetensors 可直接给 mlx-swift。GGUF 路对本项目是 non-issue。
  - source_url: https://insiderllm.com/guides/fine-tuning-mac-lora-mlx/
  - freshness: 2026
  - confidence: high
- mlx_lm LoRA 默认只训最后 num_layers=16 层(Qwen3-1.7B 共 28 层)+rank=8。要全层覆盖需 --num-layers -1。linear_to_lora_layers 在 0.31.1 已自动发现全部 Linear(q/k/v/o+gate/up/down)挂 LoRA,#2616 的 0.28%-only bug(旧版只挂 q/v)在本版已修。
  - source_url: https://github.com/ml-explore/mlx/issues/2616
  - freshness: issue 2025-09-23 Closed;本机 0.31.1 源码已含修复
  - confidence: high

### tigers (坑点)
- [HIGH] Qwen3.5(2B/9B)在 M5 上 LoRA 训练首个 backward 就 OOM 崩溃 — 与磊哥本机同芯片(M5)同模型族独立印证『训 1.7B 不训 2B』。缓解:P1-C 锁 mlx-community/Qwen3-1.7B-4bit(Qwen3 非 3.5,已缓存);训前跑 5-iter 冒烟看 backward 过;若未来要训 2B 锁版本前查 #1206 是否已修。
  - 证据: mlx-lm issue #1206(2026-04-26 开,未解):mlx-community/Qwen3.5-9B-4bit 在 M5 Max(applegpu_g17s)首训 iter backward 立刻报 Insufficient Memory(kIOGPUCommandBufferCallbackErrorOutOfMemory),与 batch/seqlen/层数/grad-checkpoint 无关,系统内存还低 → Qwen3.5 架构+MLX 版本特定 bug;换 Qwen3-8B-4bit(上一代同族)同配置训练正常。https://github.com/ml-explore/mlx-lm/issues/1206
- [HIGH] stock mlx_lm 的 --mask-prompt 只做『最后一条 assistant 消息』单形态 masking,可能不覆盖 C5 data gate 要的 masking 三形态。缓解两路:(A)数据塑成『最后一条 assistant=ToolCall completion』单轮 {messages,tools} 格式 → stock --mask-prompt 直接够用(MAformac 单跳 ToolCallFrame 禁自由 loop 本就单轮);(B)确需多轮分段 masking → 升级 mlx-lm-lora v2.1.0 或自写 masked dataset。默认走 A,别上来加复杂度。
  - 证据: 本机 datasets.py:65-72 — mask_prompt 逻辑 offset=len(apply_chat_template(messages[:-1])),只把最后一条之前全 mask,对整条最后 assistant 算 loss。多轮对话中段 assistant tool-call + tool-result + 末尾 assistant → stock 只训最后一条、中段被当 prompt mask,做不到 per-turn 多段 assistant masking。C5 receipt masking_coverage 全 false 正是这块未实现。
- [MEDIUM] LoRA 默认超参(num_layers=16/rank=8/仅末16层)对『学模糊说法→跨域映射』泛化容量可能不足,训了但泛化弱。缓解:P1-C config 显式 --num-layers -1(全 28 层)+rank 16-32;训完用 C6 held-out bench 验泛化(base 0.789 hard_fail 是诚实锚点)。rank/layers 是可调旋钮非阻断项。
  - 证据: CONFIG_DEFAULTS(本机 lora.py:56,73):num_layers=16(Qwen3-1.7B 共 28 层只训末16)/rank=8/scale=20。#2616 曾报 Qwen3 默认可训参数过低(虽 0.31.1 已修模块发现,层数仍受 num_layers 限)。FC 泛化任务通常需更高 rank+全层。https://github.com/ml-explore/mlx/issues/2616
- [LOW] M5 内存带宽仅 153GB/s(比 M4 高 28% 但远低于独显),训练是带宽密集 → 每步比独显慢。缓解:1.7B 比 7-8B 小 4-5 倍,绝对训练时长仍 <15 分钟,band-width 慢是『相对独显慢』不是不可用。P1-C 一次性训 LoRA 完全可接受,无需缓解。
  - 证据: Apple ML 官方:M5 带宽 153GB/s(M4 120GB/s),M5 对 1.7B TTFT 比 M4 快 3.57x(推理非训练),token 生成只提升 19-27%(带宽受限)。训练吞吐参考:7B@M2 Ultra ~475 tok/s,8B QLoRA ~285-296 tok/s。https://machinelearning.apple.com/research/exploring-llms-mlx-m5
- [LOW] [PAPER-TIGER] 『Qwen3 在 MLX LoRA 只训 0.28% 参数(只挂 q/v)严重欠拟合』(#2616)— 看似威胁实为已解。
  - 证据: 读本机 mlx-lm 0.31.1 tuner/utils.py:88-103,linear_to_lora_layers 已重构为 get_keys_for_lora 自动发现全部 nn.Linear/QuantizedLinear(含 k/o_proj+gate/up/down_proj),不再是旧版硬编码 q/v。issue 2025-09-23 已 Closed。本版默认挂全部投影,0.28% bug 不复现。残留只是 num_layers 层数限(已在 MEDIUM tiger 给旋钮)。https://github.com/ml-explore/mlx/issues/2616
- [LOW] [PAPER-TIGER] 『Mac 没 NVIDIA GPU 不能训 / unsloth 跑不了=不能训』— 看似阻断实为不成立。
  - 证据: unsloth 确需 CUDA 跑不了本机,但 Mac 训练路径是 MLX 原生(mlx_lm.lora),本机已装且就绪,与 unsloth 是平行替代非缺失。MAformac 只吸收 unsloth/Hammer/xLAM 的训练侧设计/配方(masking/数据配比),训练本身用 mlx_lm.lora 在 M5 跑,产物=LoRA 权重,闭环,无需 NVIDIA。https://www.buildmvpfast.com/blog/mlx-apple-silicon-ai-development-mac-fine-tune-llm-2026
- [MEDIUM] [ELEPHANT] 真正瓶颈不是『能不能训』(M5/32GB 训 1.7B over-provisioned 今晚就能跑)而是『 masking 三形态实现 + held-out 防记硬背』两个数据前置门。
  - 证据: 本机训练能力已就绪到『今晚跑第一个冒烟训练』程度—卡 P1-C 的是 C5 masking_coverage 全 false(stock --mask-prompt 只给一种形态)+ 数据质量,不是算力。次要 elephant:35B 推理本机已撞 22GB 上限,未来若『训 LoRA+跑 oMLX 推理』同时要错峰,但 P1-C 训练阶段无需 oMLX 在跑无冲突。

### grill 议题
- C5 data gate 的 masking_coverage 三形态到底定义是哪三种?如果是『单轮 ToolCall completion mask』这一种就够(符合 MAformac 单跳 ToolCallFrame、禁自由 loop),那 stock mlx_lm --mask-prompt 直接满足,根本不用上 mlx-lm-lora。先核三形态精确定义再决定要不要加复杂度。
- P1-C 是不是该先跑一个 30 分钟『冒烟训练』(Qwen3-1.7B-4bit + 现成 2320 train 行 + --num-layers -1 + 600 iters)把 loss 收敛曲线 + 峰值内存 + tok/s 在本机实测出来,拿真实数字替代本报告的外推估值?这是验掉所有 tiger 最便宜的动作。
- LoRA rank/num-layers 旋钮:默认 rank=8/末16层 vs 全28层/rank16-32,哪个在 C6 held-out bench 上 IrrelAcc 更高?这是经验性问题只能训两版对比不能拍。要不要 P1-C 第一刀 A/B 两 config 各训一版?
- 训完产物给 mlx-swift-lm 是喂 fused safetensors(权重合并)还是喂 adapter(运行时加载)?adapter 路线包体小、可热插拔多技能(符合 CLAUDE『可插拔多技能』),但 mlx-swift 是否支持运行时挂 LoRA adapter 需在 spike-e3 端验证 — 这是 P1-C→端侧落地的衔接缺口。
- omlx 已澄清为推理服务器不是训练工具 — 这点是否需回写 CLAUDE/memory 以免未来又问『本机不是用 omlx 训过 27B 吗』?实际是 omlx 只跑过 35B 推理,从未训过任何模型。


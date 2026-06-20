# P1-C 训练后端深扒 + masking 实装 + 配方 + 15 轮 grill 弹药

> probe 式综合官报告。综合 7 路深扒(后端可行性 ×2 / 训练 skills 生态 / Qwen3-1.7B 配方 / Qwen3.5-2B 特殊性 / 训练坑点 oracle / masking 三形态实装),逐条核对哪些坑命中 MAformac 实际栈(Qwen3-1.7B + mlx-lm 0.31.1 + M5/32GB),哪些是别的模型/尺寸的坑被误当成 1.7B 的坑。
>
> **一手核验(2026-06-20 本机 Bash 实测,非外推)**:
> - 硬件 = Apple M5 / 32GB / macOS 26.6 (build 25G5028f)。✅ `sysctl`
> - mlx-lm **0.31.1** 已装(`~/Library/Python/3.13/...`),`mlx_lm.lora` CLI 在 PATH,`--mask-prompt`/`--num-layers`(默认16)/`--fine-tune-type {lora,dora,full}`/`--grad-checkpoint`/`--grad-accumulation-steps` 全在。✅ `mlx_lm.lora --help`
> - HF cache 已有 `mlx-community/Qwen3-1.7B-4bit` + `Qwen3.5-2B-4bit` + `Qwen3.6-35B-A3B-4bit/8bit`。✅ `ls ~/.cache/huggingface/hub`
> - oMLX 0.3.6 = `/Applications/oMLX.app` + `~/.omlx` + `~/Downloads/oMLX-0.3.6-macos26-tahoe.dmg`。✅ 实测
> - C5 receipt(`Reports/c5-data-gate-20260620-192100/c5-data-gate-receipt.json`):train **2320** / heldout **1200** / must_pass **30** / quarantine **120**(row_count **3670**);`masking_coverage` 四 flag(train_on_turn/function_name/argument_name/argument_value)**全 false**;`must_not_train_violations=0`;`train_parent_semantic_overlap=0`;`tool_call_format_pass=2320`;`format_contract_version` 已锁。✅ 实读 JSON
> - **Qwen3-1.7B-4bit chat_template = 4116 字符,含 `{% generation %}` + tool_call + enable_thinking + `<think>`** → `return_assistant_tokens_mask=True` 开箱即用。✅ 实测
> - **Qwen3.5-2B-4bit chat_template = 空(len 0)** → 又一条 2B 劣于 1.7B 的硬证据。✅ 实测
> - mlx-lm 源码 `tuner/datasets.py:65-75`:`mask_prompt` 用 `len(apply_chat_template(messages[:-1]))` 算**单个标量 offset** → 只能屏蔽一段连续前缀。✅ 实读源码
> - mlx-lm 源码 `tuner/utils.py:71-95`:`get_keys_for_lora` 把 `nn.Embedding/QuantizedEmbedding` 也纳入 LoRA 候选 → tied-embedding 坑真实存在。✅ 实读源码

---

## 0. 一句话结论 + 后端决策

**一句话**:`omlx` 已坐实 = oMLX 0.3.6 **推理 GUI**(磊哥跑 35B 用,非训练工具);P1-C 训练后端**锁本机 Mac mlx-lm 0.31.1 (MLX-native)**——M5/32GB 训 Qwen3-1.7B LoRA 严重 over-provisioned(峰值 2-5GB / <15min),且产物 = MLX 原生 adapter 与端侧 spike-e3 `mlx-swift-lm` **同格式同 kernel 族,零回流摩擦**;云 GPU(unsloth/CUDA)对 1.7B 是**伪退路**(本机已分钟级完成),且踩 PEFT→MLX 格式转换 + CUDA/Metal 数值不等价两道坑,**drop**;云 Mac(Scaleway M4-XL €0.49/h)是唯一零摩擦的扩展退路,仅在"批量超参扫"时启用。**真正的 P1-C 前置门不是算力,是 masking 三/四形态实装 + held-out 防记硬背两个数据门。**

### omlx 是什么(认知纠正,confidence=high)

| 磊哥记忆 | 实际坐实 | 证据 |
|---|---|---|
| "本机用 omlx 跑过 27B hermes 大模型" | `omlx` = **oMLX 0.3.6**,本地 **MLX 推理服务器 GUI**(`com.omlx.app`,绑 127.0.0.1:8000 OpenAI 兼容 / 单并发 / max_model_memory 22GB);跑过的是 **Qwen3.6-35B-A3B**(MoE,~3B 激活)int4 **推理**,不是训练,也不是 27B | 本机 `~/.omlx/logs/server.log` 2026-04-18 实跑日志 + `/Applications/oMLX.app` |
| "用 omlx 训过 LoRA" | **omlx 从未训过任何模型**。训练靠**另装的 mlx-lm 0.31.1** 的 `mlx_lm.lora` | 本机实测 |
| "hermes 是本地 27B 模型" | "Hermes" = **Nous Research Hermes 桌面 app**(中转 API 客户端 `~/.hermes`),非自训大模型;oMLX 只是给它当后端 | 本机 LaunchAgents/Preferences 痕迹 |

**回写动作**:CLAUDE.md / memory 应记 "omlx = oMLX 推理 GUI(非训练);训练栈 = mlx-lm 0.31.1 已装即用",杜绝下次再问"不是用 omlx 训过吗"。oMLX 的正面价值 = LoRA 训完后的**本机推理验证 server**(可加载 fused 模型跑 readback 一致性)。

### 后端决策一句话

> ⭐ **本机 mlx-lm 优先,云 Mac 作扩展退路,云 NVIDIA 砍掉。** 全程 MLX-native,adapter 即端侧格式,免去回流验收。

---

## 1. 训练后端对比矩阵

| 维度 | 本机 Mac mlx-lm ⭐ | 云 Mac (Scaleway M4-XL) | 云 NVIDIA (Vast/RunPod + unsloth/TRL) | 免费档 (Kaggle/Colab + unsloth) |
|---|---|---|---|---|
| **可行性** | ✅ 已装即用,无 NVIDIA 也能训 [src1] | ✅ 同 MLX,远程 SSH | ✅ 但本机无 GPU,unsloth CUDA-only [src2] | ✅ 但 Mac 无法本地跑 |
| **1.7B LoRA 速度** | <15min / 几百 iters [src3] | 同本机量级(M4 Pro) | 分钟级(RTX4090) | 分钟级(T4/P100) |
| **峰值 RAM** | 2-5GB(32GB 留 25GB+;35B 推理才撞 22GB) [src4] | 64GB 余量更大 | VRAM 5GB bf16 (2B 表) [src5] | T4 16GB 余量大 |
| **成本** | **¥0**(本机零边际) | €0.49/h **但 Apple 强制 24h 最低租期** ≈ €11.76+VAT/次 [src6] | $0.08-0.50/h(全程 $几~$16) [src7] | **¥0**(Kaggle 30 GPU h/周保证) [src8] |
| **隐私** | **零第三方暴露**(免合规评估) | 零第三方(MLX) | 脱敏后可控(RunPod HIPAA/GDPR/AES-256;Vast SOC2/3) [src9] | 公开免费档,脱敏样本 |
| **回流兼容(→ 端侧 mlx-swift)** | ✅ **零摩擦**,MLX 原生 adapter 同 kernel 族 | ✅ **零摩擦**,同 MLX | ⚠️ **两道坑**:① PEFT→MLX 需手写 key-rename+转置脚本(config 无法纯从权重反推)[src10] ② CUDA/Metal 数值不等价,贪心解码 ~20-30 token 后发散+质量退化(BF16 亦然)[src11] | ⚠️ 同云 NVIDIA |
| **masking 能力** | ⚠️ 原生 `--mask-prompt` 仅单段前缀(见 §3),但 `train()` 暴露 `loss: callable` 可注入自定义 token 级 mask [src12] | 同本机 | ✅ TRL `assistant_only_loss=True` 多轮全 assistant 原生(Qwen3 自动 patch) [src13] | 同云 NVIDIA |

[src1] 本机 `mlx_lm.lora --help` 实测 · [src2] unsloth requirements "only works on NVIDIA/AMD/Intel GPUs" https://unsloth.ai/docs · [src3] https://markaicode.com/run-fine-tune-llms-mac-mlx-lm/ · [src4] https://insiderllm.com/guides/fine-tuning-mac-lora-mlx/ + 本机 `~/.omlx` max_model_memory 22GB · [src5] https://unsloth.ai/docs/models/qwen3.5/fine-tune · [src6] https://www.scaleway.com/en/mac-mini-m4-pro/ · [src7] https://www.spheron.network/blog/gpu-cloud-pricing-comparison-2026/ · [src8] https://www.kdnuggets.com/5-cheapest-cloud-platforms-for-fine-tuning-llms · [src9] https://www.runpod.io/legal/compliance · [src10] https://github.com/ml-explore/mlx/discussions/1910 · [src11] https://github.com/ml-explore/mlx-lm/issues/1058 · [src12] 本机 `tuner/trainer.py` train() 签名 + https://github.com/ml-explore/mlx/issues/1224 · [src13] https://huggingface.co/docs/trl/sft_trainer

**矩阵结论(confidence=high)**:对 1.7B 这个尺寸,云 NVIDIA 的"提速"收益 ≈ 0(本机已分钟级),净增两道回流坑;唯一值得保留的退路是**云 Mac**(同 MLX 零摩擦),仅在"本机机时不够 / 批量超参并行扫"时按 24h 窗口批处理跑完即销毁。日常迭代全用本机。

---

## 2. Qwen3-1.7B LoRA 配方

### 2.1 模型架构(confidence=high)

Qwen3-1.7B = **28 层** / hidden 2048 / FFN 6144 / 16 heads / 8 KV heads (GQA) / SwiGLU / 纯文本(无 vision)/ tied embedding(≤4B 词嵌入与输出层共享)。[src https://huggingface.co/docs/transformers/en/model_doc/qwen3]

### 2.2 超参表(⭐ 推荐 + 出处)

| 旋钮 | ⭐ 推荐值 | 理由 / 出处 | confidence |
|---|---|---|---|
| `--fine-tune-type` | `lora`(主)+ `dora` rank8 作 A/B | DoRA 低 rank 区增益最大、无推理开销,但小数据略增过拟合,不默认它赢 [arXiv 2402.09353] | medium |
| `--num-layers` | **`-1`(全 28 层)** | 默认 16 只挂末尾 16 层,漏前 12 层(含研究证明最关键的中层);1.7B 小,全层代价极小 [mlx-examples #1328] | high |
| LoRA rank | **16~32**(rank32 起 + 早停) | 结构化 FC 任务 rank 越高越准,但 2320 小集 rank64 有研究未超 base;rank32 是甜区上沿 [unsloth guide] | high |
| alpha (scale) | **2×rank**(rank32→α64) | LoRA-Learns-Less (TMLR'24) 实证 α=2r 在高 rank 显著优于 α=r [arXiv 论文] | high |
| target modules | **全 linear**(q/k/v/o + gate/up/down) | mlx-lm 0.31.1 默认 `get_keys_for_lora` 已 auto-discover 全部 Linear(0.28%-only bug #2616 在本版已修);MLP 是主要学习 locus | high |
| `--learning-rate` | **2e-4** (cosine) | LoRA 比 full-FT 高一个量级;论文区间 5e-5~5e-4 [unsloth + TMLR] | high |
| warmup | 总 iters 的 **5~10%**(1740 iters → ~100-170) | 别照搬大训练固定 warmup;否则有效 lr 卡在 1e-7 never 爬到目标 [mlx-examples #985] | high |
| epochs | **2~3** | >3 epoch 小数据必过拟合 [unsloth] | high |
| `--batch-size` × `--grad-accumulation-steps` | **4 × 4**(等效 16) | M5/32GB 余量大;OOM 解药=batch1+grad-checkpoint(本机用不到) | high |
| weight_decay | 0.01 | 短训正则 | high |
| lora_dropout | **0** | 短训不可靠,unsloth 建议 0,靠 weight_decay + 早停正则 | high |
| `--max-seq-length` | 1024~2048(按数据 P95) | 车控短 | high |
| **过拟合死线** | **train loss < 0.2 ≈ 过拟合** | unsloth 明确;配 `--save-every 100~200` + `--steps-per-eval 50~100`,**选 val loss 拐点前 checkpoint 非最后一个** [unsloth] | high |

### 2.3 iters 换算(mlx-lm 无 epochs 旗标,必手算)

```
iters = ceil(2320 / batch_size) × epochs
batch=4 → 1 epoch = 580 iters
⭐ batch=4 + 3 epochs = 1740 iters(或 2 epochs = 1160)
```
配 `--save-every 100~200` 存多 checkpoint;`--steps-per-eval 50~100` 报 val loss;早停选拐点前。[src https://github.com/ml-explore/mlx/discussions/728]

### 2.4 数据量评估(confidence=high)

2320 train 行处于「下限偏可用」区间(meaningful adaptation 下限 100~500,strong 区 1000~10000+;FC 甜区 2000~5000)。MAformac 任务 = **学「模糊说→ToolCall 结构 + 拒识」属格式/映射类**(非灌新事实知识),格式类小数据更易学,且 LoRA 抗过拟合优于 full-FT。

- **可起步,但偏下限**:有研究警告 500~2000 行小集即便 rank/alpha 拉到 64/40 也未必超过 base。[src https://dialzara.com/blog/fine-tuning-llms-with-small-data-guide]
- **⭐ 建议**:先用 2320 跑一版看 C6 base→LoRA 提升曲线(base IrrelAcc 0.789 hard_fail 是诚实锚点),再决定是否 LLM 增广到 4~5k 进甜区;增广须过 `must_not_train` + masking 一致性 + `parent_overlap=0` 不被破坏。
- **加权采样**(home-llm 配方):templated 多意图最重 10~25x,非笛卡尔积。

### 2.5 tool-call 格式对齐(撞契约,confidence=high)

- Qwen3 tokenizer_config **已内置 Hermes 风格 tool 模板**:`<tools></tools>` 注入 system,`<tool_call>{json}</tool_call>` 输出。本机 Qwen3-1.7B-4bit chat_template **实测含 tool_call + tools + enable_thinking + `<think>`**(4116 字符)。
- mlx-lm `datasets.py` 已支持 jsonl 顶层 `tools` 键 + messages 里 assistant 的 `tool_calls`,自动走 `apply_chat_template(messages, tools=tools)`。
- C5 已锁 `qwen-tool-call-format.yaml`:`model_family=qwen3 / runtime_parser=json / wrapper=tool_call / arguments_shape=json_object / thinking=false`。即 answer = `<tool_call>{"name":...,"arguments":{json_object}}</tool_call>`。
- 🔴 **致命静默 bug 防线**:LLaMA-Factory 内置 tool 处理产 **Qwen2.5 格式**,会训出模型推理时从没见过的 tool-call 格式。**最稳 = 用本机真实 Qwen3-1.7B `chat_template.jinja` 渲染后逐字 diff 推理端实际输入再训。** [src https://huggingface.co/datasets/PGCodeLLM/ccr-bench]

### 2.6 thinking 模式(confidence=high)

车控秒回 → **训 no-think**。`enable_thinking=False` 时 Qwen3 仍产**空 `<think></think>`** 再接答案——训练数据必须产出这个确切结构(空 think 块),不能删 tag,否则偏离模板。

- ⭐ **L1 类(明确指令)走规则不进模型;进模型的 L2-5 样本以 no-think(空 think)为主 + 少量带简短 reasoning 的难例**(Qwen 自己练 hybrid 即如此)。
- 🔴 锁单一口径贯穿数据准备 + 训练 + mlx-swift 推理三处(同一 `enable_thinking` 值),否则训出来推理崩(Qwen3 #1831 实证:有 tools 应自动关 think / multi-assistant + enable_thinking=False 首轮漏 think token / KV-cache 在 enable_thinking=false 崩)。

### 2.7 base 选型背书(confidence=high)

- 独立 benchmark 实测**未微调的 Qwen3-1.7B 是同尺寸最强 FC 模型**——唯一能可靠通过最难「restraint(该不该调工具/拒识)」prompt 的小模型(20 跑稳定,Action 0.900 + 完美 restraint + 0 错调)。[src https://github.com/MikeVeerman/tool-calling-benchmark]
- 内部 P1-B spike 实测 1.7B 9/11 > Qwen3.5-2B 8/11。
- 最强同类实证:Qwen2.5-1.5B base 经 LoRA 训 FC,JSON 合法率 73%→100%、整体准确率 3.40%→26.60%(6.28x)。[src https://arxiv.org/pdf/2509.04518]

> **base 选 1.7B 有外部 benchmark + 内部 spike 双证据,不是妥协。**

### 2.8 升级前置(实跑一次即证伪的廉价 gate)

1. `pip install -U mlx-lm`(0.31.1 → **0.31.3**,2026-04-22,落后两个 patch)。
2. dry-run 看 `print_trainable_parameters()` 输出可训参数 %(应 ~1~3%);若异常高/含 embedding(tied-embedding 坑,`utils.py:71` 把 Embedding 纳入 LoRA 候选),在 config 显式设 `lora_parameters.keys` 限定到 q/k/v/o/gate/up/down_proj **排除 embedding**。

---

## 3. masking 三/四形态实装方案(P1-C 真正的工程量)

### 3.1 🔴 核心纠偏:「三形态」实为【两类机制】,C5 receipt 实际追踪【四个】flag

任务描述把"三形态"混为一谈。一手核对(读 Hammer `data_processing.py` + mlx-lm 源码 + C5 receipt)后澄清:

| C5 flag | 机制类别 | 落点层 | 做什么 | confidence |
|---|---|---|---|---|
| `train_on_turn` | **真·loss masking** | collator/loss 层 | 把 prompt/user token 的 loss 置零(label=-100),只训 assistant/ToolCall token | high |
| `function_name` | **数据增广**(非 loss) | data 预处理层 | Hammer 式:函数名 input+label **同步**换随机串,loss 照常算 → 逼模型读 description 不死记名字 | high |
| `argument_name` | **数据增广**(非 loss) | data 预处理层 | 同上,参数 key 同步随机化 | high |
| `argument_value` | **二选一**(loss 置零 OR 数据增广) | loss 层 OR data 层 | GOAT 式 loss 置零(逼学结构,完全不学具体值)OR Hammer 式随机化值+同步改 query(逼从 query 抽值) | high |

> 🔴 **别把 Hammer function masking 误实装成 loss 置零**——Hammer `data_processing.py` 一手源码(本机 `referencerepo/repos/MadeAgents__Hammer/train/`)三个函数全是**字符串替换**(`replace_function_names_new` L103-134 / `replace_param_names_new` L66-100 / `replace_param_default_values_news` L160-218),`p=0.67` 概率 + 数据先 3x 复制,loss 在随机化后的 output 上**正常算,绝非置零**。[src https://github.com/MadeAgents/Hammer/blob/main/train/data_processing.py]

### 3.2 train_on_turn 在 mlx 的落地(本机零 GPU,⭐ 主路)

**stock mlx-lm 限制(HIGH 坑,一手源码坐实)**:`tuner/datasets.py:65-75` 的 `mask_prompt` 用 `len(apply_chat_template(messages[:-1]))` 算**单个标量 offset**;`trainer.py default_loss` 的 mask = `(steps >= offset) AND (steps <= length)` = **单段连续区间**。对 multi-turn 只把**最后一条 assistant** 当 completion,中间所有 assistant turn 连同 user 一起被屏蔽。→ MAformac 的 3123 行 followup-transitions 多轮数据**中段 assistant 信号会丢**。

**✅ 重大利好(机器实测)**:本机 `Qwen3-1.7B-4bit` chat_template **已含 `{% generation %}` 标签**(实测 True)→ `tokenizer.apply_chat_template(..., return_assistant_tokens_mask=True, return_dict=True)` 直接拿 `assistant_masks`(1=assistant token,0=其余),**零模板手术,支持多轮全 assistant**。对照 `Qwen3.5-2B-4bit` template **为空**(劣证)。

**⭐ 实装路径(三选一,推荐 a)**:
- **(a) ⭐ 本机零 GPU**:写 `dataset.process` 把 `return_assistant_tokens_mask` 的 `assistant_masks` 转成 per-token mask(0→label -100)+ 自定义 `default_loss` 接收该 mask,注入 mlx-lm `train()`(官方 issue #1224 明示 `loss: callable` + `iterate_batches: callable` 是设计意图)。
- **(b) 数据侧拆轮**:每条多轮拆成多个单轮样本,每个以一条不同 assistant 结尾(HelpSteer2 做法),再用 stock `--mask-prompt`。简单但样本膨胀。
- **(c) cloud fallback**:TRL `assistant_only_loss=True`(Qwen3 自动 patch {% generation %},多轮全 assistant)。需 NVIDIA GPU。

### 3.3 argument_value 的取舍(grill 议题,见 §7 Q4)

- **GOAT loss 置零**(arXiv 2510.12218):json.loads(answer) 定位 arguments 各 value 字符区间 → `tokenizer(return_offsets_mapping=True)` 映射 token 区间 → mask=0。逼模型**完全不学具体值**,适合值由规则/槽位填。实证优于 self-distillation。
- **Hammer 数据增广**:随机化值 + 同步改 query,逼模型**从 query 抽值**。
- 🔴 **车控倾向数据增广**:参数值(温度/档位)恰恰要从用户话里抽(「调到 26 度」),不是完全不学——GOAT 置零会让模型不知道把 26 填哪。**需磊哥拍(§7 Q4)。**

### 3.4 实装硬验收(不假设 flag 生效,mlx-examples #1313 实证有人 flag 不生效)

- 实装后**打印 label 张量肉眼核**:`train_on_turn` mask 只盖 assistant token;`argument_value` mask 只覆盖 arg 值、**不碰 name/结构/`<tool_call>` 标签**(off-by-one 高发,用 offset_mapping 而非字符串匹配)。
- 把"masking 实测验证(对比 masked vs unmasked loss 曲线)"写进 C5 数据门验收。
- **分批策略**:`train_on_turn` 是 loss 正确性**死门**(不做就训 user token)→ P1-A 这一刀必须齐;`function/argument` 增广是泛化增强 → 可作增量后补(§7 Q15)。

### 3.5 mask 机制 vs 框架对照表

| 形态 | stock mlx-lm | mlx-lm-lora (380★ 2026-06-16) | TRL/unsloth (需 GPU) |
|---|---|---|---|
| train_on_turn 单轮 | ✅ `--mask-prompt` | ✅ | ✅ |
| train_on_turn 多轮全 assistant | ❌(单 offset)→ 自写 loss callable | ⚠️ 看其 custom loss API | ✅ `assistant_only_loss` |
| arg-value loss 置零 | ❌ 原生无 → 自写 loss callable | ⚠️ 可能暴露更细 mask | 需自写 collator |
| function/arg-name 增广 | data 层自做(与框架无关) | 同 | 同 |

[src https://github.com/Goekdeniz-Guelmez/mlx-lm-lora · https://huggingface.co/docs/trl/sft_trainer]

---

## 4. 训练 skills adopt 清单(adopt > build)

| 资产 | verdict | 用途 / 取舍 | 新鲜度 |
|---|---|---|---|
| **本机 mlx-lm 0.31.1 `mlx_lm.lora`** | ⭐ **adopt** | P1-C 训练**主栈**,零新依赖,MLX 原生 adapter 同端侧格式。`train()` 暴露 `loss: callable` 可注入 4 形态 mask | 5979★ / push 2026-06-12 |
| **Qwen3-1.7B `return_assistant_tokens_mask`** | ⭐ **adopt** | train_on_turn 在 mlx 实装**最干净的路**(避开单 offset,多轮全 assistant)。本机 template 已带 `{% generation %}` | 本机实测 |
| **LTX-2 `.claude/skills/train-model`(orchestrator-skill 蓝本)** | **adapt** | adopt phase 编排骨架(**probe→plan-gate→sanity-check→train→eval-diff**)+ **Hard Invariant #5(禁对训练结果/数据充足度断言)** + post-train-validate 三类 eval(in-dist/OOD/held-out **只 surface 路径不下判决**)。drop 视频扩散专属(process_dataset/conditioning)+ nvidia-smi(换 Apple Silicon probe)。**solo demo 可砍 plan.md 写文件+等批准这种多人 ceremony** | 7743★ / push 2026-06-17 |
| **huggingface/skills - huggingface-llm-trainer** | **adapt** | adopt `dataset_inspector` 训前格式校验门(50%+ 训练失败是格式问题,CPU 校验 $0.01 vs GPU 失败 $1-10)+ `references/local_training_macos.md` Mac 配方(float32 防 MPS NaN)+ eval 脚本。drop HF Jobs 云流程(本机 MLX 已够)。已 clone `ref-repos/hf-skills` | 10700★ / push 2026-06-19 |
| **Hammer `data_processing.py` 三个 replace 函数(数据增广配方)** | **adapt** | function/arg-name/arg-value 三形态照搬字符串替换逻辑(p=0.67 + 3x 复制),但**只对 distractor/irrelevant 工具随机化函数名(保留正例 device×primitive 语义)**;arg-value 随机化同步改 query。已 clone,不依赖其活维护(stale 119★) | arXiv 2410.04587 |
| **Hammer irrelevance-augment 空-list 配方** | **adopt** | 从训练集采样 ~12.5%(7.5k/60k)故意移除正确函数、label 换空 list,训"无合适工具时弃权"。对应 C6 base IrrelAcc 0.789 hard_fail 提升路径。⚠️ 纯 FC 训练与拒识成 inverse relationship,必 irrelevance-augment 才两者兼得 | arXiv 2410.04587 |
| **GOAT arg-token masking** | **adapt** | argument_value 若选 loss-mask 路线用之(防死记参数值)。车控可能更适合数据增广(§3.3) | arXiv 2510.12218 |
| **When2Call(拒识方法学)** | **adopt** | 别堆独立负例(过度保守反噬)→ in-prompt distractor + 90:10 utility:refusal + 双轴评测 + 必要时 RPO/DPO | arXiv 2504.18851 |
| **mlx-lm-lora (Goekdeniz-Guelmez)** | **adapt** | MLX-native power tool:多 assistant turn loss masking + **QAT(4-16bit 量化感知训练,对 4-bit 端侧部署直接有用)** + 12 算法。车企(Mercedes/Daimler)背书,作者是 mlx-lm 官方 contributor。**两阶段:首训用 stock mlx-lm 最快验通,端侧部署前 QAT 用之** | 380★ / push 2026-06-16 |
| **Scaleway Mac mini M4-XL** | **adapt** | 机时扩展退路,同 MLX 零摩擦。24h 最低租期 → 一窗口批处理跑完即销毁 | €0.49/h |
| 云 NVIDIA + PEFT(Unsloth/Axolotl/LLaMA-Factory) | **drop** | 1.7B 提速收益≈0,两道回流坑(格式转换+数值不等价)。仅当未来升 9B+ bf16(本机 32GB 吃力)才重评 | — |
| MLX-LoRA-Studio(GUI) | **drop** | CLI 已够且更可脚本化/可复现。磊哥要可视化手调超参再考虑 | 136★ |
| unsloth-MLX(unsloth_zoo/mlx/trainer.py) | **drop**(现阶段) | MLX 路径 beta + Qwen3 未实战(issue #6002 报 patched_attn_call 拒 position_embeddings + VJP 错)。稳妥用裸 mlx_lm.lora | beta |

> **bottom line**:不用手搓 P1-C 流程。adopt LTX-2 phase 骨架(剥 ceremony)+ Hard Invariant #5;训练栈本机 mlx-lm 已装;masking 分流实装;拒识用 Hammer + When2Call。

---

## 5. Qwen3.5-2B 训练特殊性(未来切 2B 需先解决什么)

> **训练侧深扒结论:P1-C 切 2B 是净增成本无明显收益。建议 P1-C 锁 1.7B,把 2B 降为 P2 后探索性 spike。** confidence=high

### 5.1 2B vs 1.7B 是两种不同物种

| 维度 | Qwen3-1.7B(锁定) | Qwen3.5-2B(逃生口) |
|---|---|---|
| 代际 | Qwen3,一年沉淀 | Qwen3.5,2026-02 发布 4 个月 |
| 架构 | 纯文本标准 Transformer,28 层全标准 q/k/v/o | **混合 GDN**:75% 层 GatedDeltaNet(linear_attn,用 `in_proj_qkv/z/b/a`+`out_proj` 非标准命名)+ 25% 标准 Attention(`(idx+1)%4` 切换);24 层 | 
| 模态 | 纯文本无 vision | **native VL early-fusion**,带用不到的 vision encoder(~300M) |
| chat_template | **4116 字符,含 generation+tool_call** | **空(len 0)** ← 本机实测劣证 |
| LoRA 配方 | 成熟烂熟 | **无成熟默认配方** |
| 端侧链路 | merge/量化/端侧成熟 | merge→convert **发散 bug** |

[src https://qwen.ai/blog?id=qwen3.5 · 本机源码 `mlx_lm/models/qwen3_5.py:204` + 114-128 · 本机 chat_template 实测]

### 5.2 切 2B 必须先解的三关(全是 HIGH/MEDIUM 坑)

1. **GDN target module 盲区(HIGH)**:标准 `target_modules=[q/k/v/o, gate/up/down]` 只命中 **25% full-attention 层 + MLP**,**75% 的 GDN 时序混合层(模型真正的记忆/语义混合能力所在)完全不被 LoRA 触及**。unsloth issue #4108 作者自己说 "Qwen3.5 is pretty weird with the delta nets"。→ 用默认配方训"模糊车控泛化",核心混合层学不到。**缓解**:在 mlx-lm YAML `lora_parameters.keys` 显式加 GDN 的 `in_proj_qkv/in_proj_z/out_proj`(都是 nn.Linear 可挂)+ 做"含 GDN keys vs 不含" A/B held-out 对比——但**无成熟配方,P1-C 工期内风险高**。[src https://github.com/unslothai/unsloth/issues/4108 + 本机 qwen3_5.py:204]
2. **VL 权重坑(HIGH/MEDIUM)**:`sciences44/mlx-lora-finetune` 实证 2B 是"Goldilocks zone"本机能训通,但 **4B 需手动剥离 vision 权重(vision weights crash MLX LoRA training)**;2B 恰好避开但不保证。端侧还要真正裁掉 vision tower 才不白占包体,而 early-fusion 裁比 bolt-on 难(`--language-model-only` 仅 vLLM 侧验证,端侧 MLX 未确认)。[src https://github.com/sciences44/mlx-lora-finetune]
3. **merge→convert 发散(MEDIUM)**:`mlx-lm issue #1058` 实录 Qwen3.5-4B merge LoRA + convert 后输出发散(前 20-30 token 对、之后崩)。GDN recurrent state + causal conv1d kernel 是公认跨实现痛点。→ 切 2B 须加"LoRA-merge→量化→端侧 readback 一致性"验证关。[src https://github.com/ml-explore/mlx-lm/issues/1058]

### 5.3 paper-tiger(2B 的假威胁)

- **「2B thinking-loop 要训练抑制」= paper-tiger**:Qwen3.5 官方 model card 明确 0.8B/2B/4B/9B 小模型 reasoning **默认 DISABLED**,车控单跳非思考天然规避;按非思考模板构造即可。[src https://huggingface.co/Qwen/Qwen3.5-2B]
- **「本机无 GPU 不能训 2B」= paper-tiger**:本机 mlx-lm 0.31.1 已内置 `qwen3_5.py`+`gated_delta.py`+lora,2B bf16 LoRA ~5GB 在 M5/32GB 可跑;有 sciences44 蓝本证明 Mac 无 GPU 能训通。不能训的是 unsloth(CUDA),不是 mlx-lm。**但代价 = 放弃 D30 已 adopt 的 unsloth 生态、走 GDN 无成熟配方路径。**

### 5.4 决策

> ⭐ **P1-C 锁 Qwen3-1.7B**(全层标准可训 + 成熟栈零改动 + 端侧链路成熟;P1-B 已实测 2B 推理劣于 1.7B;chat_template 空又一劣证)。**2B 降为 P2 后探索性 spike**(需先解 GDN-keys 配方 / VL 裁剪 / merge 一致性三关),不阻塞 P1-C 主线。若磊哥仍要留 2B:加一个"2B 小批 backward-pass smoke 验崩不崩"逃生口(#1206 Qwen3.5-9B 在 M5 首 backward OOM 崩,虽是 9B 专属,2B 须先 smoke 验)。

---

## 6. pre-mortem 三分类

### 6.1 tiger(明确威胁,带验证清单 + mitigation)

| # | tiger | severity | 验证清单 | mitigation |
|---|---|---|---|---|
| T1 | **mlx-lm `--mask-prompt` 多轮只 mask 到最后一条 assistant** → 3123 行 followup 多轮数据中段 assistant 信号丢失,多轮泛化/拒识学不到位 | **HIGH** | 拿一条 MAformac 多轮样本喂 `mlx_lm.lora --mask-prompt`,**打印 masked labels** 看是否每个 assistant turn 都 -100 了中间 user/tool;`datasets.py:65-75` 单 offset 实读坐实 | 走 `return_assistant_tokens_mask`(本机 template 已带 generation)+ 自定义 loss callable 注入 `train()`;或数据拆单轮;cloud TRL `assistant_only_loss`。`train_on_turn` 是 P1-A 死门 |
| T2 | **把 Hammer function masking 误实装成 loss 置零** → 既不省又训坏 | **HIGH** | 读 Hammer `data_processing.py` L103-134:纯字符串替换、loss 照常算;C5 四 flag 分别对应正确机制别混 | function/arg-name 用**数据增广**(照搬 replace_*_new,保留 device×primitive 语义);只 arg-value 可选 loss 置零 |
| T3 | **Qwen3 thinking ↔ tool-call 训/推模板不一致** → 训出来推理崩、`<think>` 泄漏进 tool-call | **HIGH** | `python -c "...chat_template..."` 核本机模板含 think/tools 路径(已测 True);Qwen3 #1831 21-fix 实证 | **锁 no-think 单跳**贯穿数据准备+训练+mlx-swift 三处同 `enable_thinking` 值;渲染后逐字 diff;验收禁未配对 `<think>` 块 |
| T4 | **LoRA fuse 进 4-bit 量化模型掉学到的行为 / `--dequantize` 路径崩** → "训练 PASS 但部署到 mlx-swift 后效果丢" | **HIGH** | `mlx-lm #654`(fuse 后丢行为,adapter 动态加载在)/`#659`(--dequantize NameError/KeyError);本机就是 Qwen3-1.7B-4bit | ① fuse 前后**行为对账**(同批 must_pass/held-out 用 base+adapter 动态 vs fused 各跑,ToolCall 精确匹配率差 >2% 即掉点回退);② 优先 **bf16 base 训 LoRA→fuse→再量化 4bit**,避开 4bit fuse 掉点;权重 fingerprint 记进 trace |
| T5 | **小数据(2320)over-memorization 骗过 eval** → held-out 准确率好看但 OOD(新车型参数值/未见设备×动作组合/方言变体)崩 | **HIGH** | 文献实证 over-memorization "test 困惑度高但准确率仍好" 骗过常规指标;28 层模型在 2320 行易快速记住 | held-out 1200 必须**真 OOD 而非近邻**(已 `parent_overlap=0` 守住别被增广破坏);epoch 1-3 + early-stop;bench 含"新参数值/未见组合/方言"泛化分桶 + IrrelAcc 拒识桶;rank 从中低起 |
| T6 | **拒识负例直接堆 → 过度保守反噬**(拒识涨但正常 FC 调用掉,BFCL AST 降) | **HIGH** | When2Call(arXiv 2504.18851)实证;Alopex 实证 FC 微调引发灾难性遗忘 + 触发判断失衡(over/under-trigger) | 负例做成**in-prompt distractor** 教辨别(非独立 refusal 样本);utility:refusal ≈ 90:10(refusal 占比 ≤10~20%,对齐 3HIGH IrrelAcc≥20% 守门);**双轴评测**(正例 ToolCall 精确匹配 + IrrelAcc 同跑,一轴涨另一轴掉立即回退);配平四类样本(需工具/直答/不相关拒识/通用 rehearsal),缺一类触发判断崩 |
| T7 | **arg-token span 定位 off-by-one** → mask 漂到 assistant 结构 token | **MEDIUM** | TRL #1184 实证 context-sensitive tokenizer 致 mask 失配 | `return_offsets_mapping=True` 拿字符→token 映射,先 json.loads 定位 value 字符区间再映射;实装后打印 label 张量肉眼核 |
| T8 | **tied-embedding 被意外加 LoRA** → 非预期可训参数 / 数值不稳 | **MEDIUM** | `utils.py:71` 把 Embedding 纳入候选(实读);Qwen3≤4B tied embedding;dry-run 看 trainable% | config 显式 `lora_parameters.keys` 排除 embedding;先升 0.31.3 再训 |
| T9 | **warmup 配置不当 lr 卡 1e-7 never 爬到目标** → 训练等于没动 | **MEDIUM** | mlx-examples #985 实证;前几十步日志看 lr 是否真爬到 2e-4 | warmup = 总 iters 5~10%,别照搬大训练固定值 |
| T10 | **NaN loss** = scale/alpha 过大(scale=10+alpha=128+lr=7e-5 直接 NaN) | **LOW-MEDIUM** | mlx-examples #620 实证 | 用 §2 推荐 α=2r、lr=2e-4,不拍大 alpha |
| T11 | **`chat_template not set` ValueError**(用 base 非 instruct 变体训 tools) | **MEDIUM** | mlx-examples #1243 实录;本机 1.7B-4bit 自带模板不命中 | 用 Instruct 变体(自带 tool-call 模板)或显式 `--chat-template`;spike 起手先验模板存在(已测 True) |

### 6.2 paper-tiger(看似威胁实际安全,带证据)

| paper-tiger | 证据(为什么是假) | confidence |
|---|---|---|
| **「Mac 没 NVIDIA / unsloth 跑不了 = 不能训」** | unsloth 确需 CUDA 跑不了本机,但 Mac 训练路径 = MLX 原生(`mlx_lm.lora` 已装就绪),与 unsloth 平行替代非缺失。M2Max 32GB 训 Mistral-7B QLoRA 峰值仅 7GB,1.7B 更轻 | high |
| **「2320 行太少训不出来」** | LoRA <1000 样本常优于 full-FT(抗过拟合);2320 已过 meaningful 下限;格式/映射类小数据更易学。配增广到 4~5k 进甜区。不是 blocker | high |
| **「Qwen3 在 MLX LoRA 只训 0.28%(只挂 q/v)严重欠拟合」(#2616)** | 本机 0.31.1 `utils.py:88-103` `get_keys_for_lora` 已 auto-discover 全部 Linear(含 k/o + gate/up/down);issue 2025-09-23 已 Closed;残留只是 num_layers 层数限(已给旋钮 `-1`) | high |
| **「M5 训练首 backward [METAL] Insufficient Memory 崩」(#1206)** | 是 **Qwen3.5-9B-4bit 专属**架构 bug,同设置换 Qwen3-8B-4bit 正常。训 1.7B(非 3.5、1.7B≪9B、32GB 余量足)**不命中**。⚠️ 反向警示:磊哥若真试训 Qwen3.5-2B,这条立即变 tiger,须先 smoke 验 backward | high |
| **「MoE 专家层不挂 LoRA 只 0.02%」(#571)** | 是 Qwen3-30B-A3B MoE 变体专属;1.7B dense 走正常 attention+MLP 路径不命中 | high |
| **「omlx 是个需要找回来的神秘训练工具」** | 无 omlx 二进制(实为 oMLX 推理 GUI);Hermes=Nous 桌面 app 非自训。P1-C 训练栈 = mlx-lm 已装即用 | high |
| **「2B thinking-loop 要特意训练抑制」** | Qwen3.5 小模型 reasoning 默认 DISABLED,车控单跳非思考天然规避 | high |
| **「fuse→GGUF 跨端部署对 Qwen3 可用」** | `--export-gguf` 仅 Mistral/Mixtral/Llama;但 Qwen3 留 MLX 原生格式正好对齐 spike-e3 `mlx-swift-lm`,**不需 GGUF**,non-issue | high |
| **「上云训练泄露车控数据」** | 红线已保证真实语料/PII 不入训练集,云训只是脱敏样本;且本机/云 Mac 训练天然零第三方暴露,选 MLX 连合规评估都免 | medium |
| **「transformers 版本不够跑 Qwen3.5」** | 本机 transformers 5.6.1 已满足 v5+(≥5.2.0) | high |

### 6.3 elephant(没人想谈的)

| elephant | 说明 |
|---|---|
| **E1:真正瓶颈不是「能不能训」而是两个数据前置门** | 本机训练能力已就绪到"今晚跑第一个冒烟训练"程度;卡 P1-C 的是 ① C5 `masking_coverage` 四 flag 全 false(stock `--mask-prompt` 只给单段前缀)+ ② held-out 防记硬背 + ③ 拒识配平。**算力是 over-provisioned 的假问题,数据/masking 工程才是真工作量(几小时 vs 几天取决于 arg-token mask 走拆轮弱版还是 fork loss callable)。** |
| **E2:masking 工程量被任务描述严重低估** | "masking 三形态"听起来是配置,实际是"自写 dataset.process + 自定义 loss callable + offset_mapping 定位 + 打印张量肉眼核"。是 P1-C 的**核心工程**,不是数据门的一个 checkbox |
| **E3:fuse→端侧是"训练 PASS 部署 FAIL"高发段,常被当训练完就结束** | LoRA 训完不等于端侧能用。fuse 进 4bit 掉行为(#654)、merge 数值不等价、QAT 是否需要——这些在 spike-e3 端侧验收前都是暗坑。**P1-C 验收门必须含"fuse 前后行为对账"**,不能训完 val loss 低就签字 |
| **E4:eval 污染会沿 dataset lineage 递归传播** | `parent_overlap=0` 是当前护栏,但**后续 LLM 增广若不守 lineage 隔离,C5 提升会从"泛化"退化成"记忆"**,而常规 held-out 测不出(over-memorization 骗分)。增广这一步的纪律比训练本身更决定成败 |
| **E5:35B 推理本机已撞 22GB 上限,但 P1-C 训练阶段与 oMLX 无冲突** | 次要 elephant:未来若"训 LoRA + 跑 oMLX 推理"同时要错峰;P1-C 训练阶段无需 oMLX 在跑,无冲突。oMLX 反而可作训完的推理验证 server |

---

## 7. 15 轮 grill 议题弹药(给主线程逐轮 grill 用)

> 每条:topic + 选项 + ⭐推荐 + 量化。覆盖后端选型/masking/超参/数据增广/checkpoint/eval-diff/格式对齐/skill adopt/2B/触发条件。

1. **后端锁 MLX 还是留云 NVIDIA?** — A) 锁死 MLX(本机 mlx-lm + 必要时 Scaleway 云 Mac),放弃云 NVIDIA+PEFT;B) 保留云 NVIDIA 作退路。⭐ **A**。量化:本机 1.7B LoRA 10-30min/¥0,云 NVIDIA 提速≈0 却踩格式转换+数值不等价两坑(issue#1058 端侧掉分);锁 MLX 免回流验收。

2. **本机 mlx-lm vs cloud TRL 作 masking 主路?** — A) 本机 mlx-lm 自写 loss callable(零 GPU,手写 ~50 行);B) cloud TRL `assistant_only_loss`(现成 flag,需搬数据+权重格式对齐)。⭐ **A**。量化:demo 3670 行 1.7B 本机够;TRL 多两道(数据搬运+格式对齐)且需 GPU。

3. **train_on_turn 实装走哪条?** — A) `return_assistant_tokens_mask`+自定义 loss(本机 template 已带 generation,多轮全 assistant);B) 数据拆单轮+`--mask-prompt`(简单但样本膨胀);C) cloud TRL。⭐ **A**。量化:本机零 GPU + 多轮信号不丢;拆轮会让 3123 followup 行膨胀。

4. **argument_value 走 loss 置零还是数据增广?**(关键分叉) — A) GOAT loss 置零(逼学结构,完全不学具体值);B) Hammer 数据增广随机化值+同步改 query(逼从 query 抽值)。⭐ **B**。理由:车控参数值(温度/档位)恰恰要从用户话抽(「调到 26 度」),置零会让模型不知道把 26 填哪。**需磊哥拍**。

5. **function_name 增广是否冲突语义契约?** — A) 全集随机化(Hammer 原做法);B) 只对 distractor/irrelevant 工具随机化,保留正例 device×primitive 语义。⭐ **B**。理由:我们的 action_code 有语义(Hammer 因名字无语义才全随机)。

6. **LoRA rank 选 16 还是 32?** — A) rank16(保守,2320 小集防过拟合);B) rank32+早停(更能装 ToolCall 结构 pattern)。⭐ **B 起 + held-out 验**(经验性只能 A/B 不能拍)。量化:rank32 训练时长仍 <15min,A/B 两 config 各训一版对比 IrrelAcc。

7. **num-layers 默认 16 还是全 28?** — A) 默认 16(末层);B) `-1` 全 28 层。⭐ **B**。量化:1.7B 全层代价极小,默认漏前 12 层含最关键中层(#1328)。

8. **是否先跑 30min 冒烟训练拿真实数字?** — A) 直接进正式训练;B) 先冒烟(Qwen3-1.7B-4bit + 2320 train + `--num-layers -1` + 600 iters)实测 loss 曲线/峰值内存/tok/s。⭐ **B**。理由:验掉所有 tiger 最便宜的动作,用真数字替代本报告外推估值。

9. **base 用 4bit(QLoRA)还是 bf16?** — A) 4bit base(已缓存,QLoRA);B) bf16 base(~3.4GB,训练质量优先)。⭐ **B(bf16 训→fuse→再量化)**。理由:32GB 完全放下 bf16+LoRA;unsloth 建议 Qwen3.5 全系不用 QLoRA(量化差异);且规避 4bit fuse 掉点(#654)。

10. **checkpoint 选哪个?** — A) 最后一个;B) val loss 拐点前(早停)。⭐ **B**。量化:`--save-every 100~200` + `--steps-per-eval 50~100`,train loss <0.2 即过拟合,选拐点前。

11. **eval-diff 加不加 LTX-2 三轴?** — A) 只用 C6 vehicle-tool-bench(IrrelAcc/覆盖率);B) C6 死门不变 + 加 held-out vs train-set 三轴(in-dist/OOD/held-out)泛化诊断。⭐ **B**。理由:C6 是"覆盖+拒识"死门,三轴是"泛化 vs 记忆"诊断,防 over-memorization 骗分;held-out 1200 已 split 好。

12. **拒识样本占比定多少?** — A) 不限;B) utility:refusal ≈ 90:10(refusal ≤10~20%)。⭐ **B**。量化:When2Call 警告堆负例反噬,3HIGH 要 IrrelAcc≥20% 守门;C5 split 时配比卡死,数据门核。

13. **多轮(3123 followup)要不要进 train?** — A) 全进;B) 确认 train 2320 里多轮占比,若 demo 只演单跳 ToolCall(禁自由 loop),多轮可只用于 heldout/bench。⭐ **先核占比再定**。理由:若不训多轮,mlx-lm 单 offset 限制就不是 blocker。

14. **2B 选项 close 还是留逃生口?** — A) 彻底锁 1.7B 关闭 2B;B) 留"2B 小批 backward smoke 验崩不崩"逃生口降级 P2。⭐ **B(降 P2 探索 spike,不阻塞 P1-C)**。理由:P1-B 已测 2B 推理劣(8/11<9/11)+ chat_template 空 + GDN 75% 盲区 + VL 包袱 + merge 发散,训练侧净增成本;但留逃生口尊重磊哥要深扒 2B 的意愿。

15. **四个 masking flag 一刀齐还是分批?** — A) P1-A 这一刀全做齐;B) `train_on_turn`(loss 正确性死门)先行,function/arg 增广作增量后补。⭐ **B**。理由:train_on_turn 不做就训 user token(必需),function/arg 是泛化增强可后补;分批降 P1-A 风险。

---

## 8. 诚实标注(confidence + 没搜到的)

- **high confidence**:本机实况(omlx/硬件/mlx-lm/cache/C5 receipt/chat_template/源码)全经一手 Bash 实测;超参方法学有 unsloth 官方 + TMLR + When2Call + GOAT + Hammer 多源交叉;mlx-lm masking 单 offset 限制读源码坐实;Qwen3.5-2B GDN/VL 坑读本机 `qwen3_5.py` 源码 + issue 坐实。
- **medium confidence**:DoRA vs LoRA 谁赢(需 A/B 实测);2320 行够不够(下限偏可用,需冒烟验提升曲线);云 Mac vision tower 端侧裁剪(`--language-model-only` 仅 vLLM 侧验证,端侧 MLX/llama.cpp 未确认);mlx-lm-lora QAT 对 Qwen3 实战(380★ 新,需端侧验);Qwen3.5-2B 在 M5 训练 backward 崩不崩(#1206 是 9B 专属,2B 未实测,须 smoke)。
- **没搜到/没实测(诚实缺口)**:
  - **mlx-swift-lm 是否支持运行时挂 LoRA adapter(热插拔)** — 影响 adapter 路线(包体小、可插拔多技能)vs fused 路线的选择,需 spike-e3 端侧实验,本报告未覆盖。
  - **30min 冒烟训练的真实 loss 曲线/峰值内存/tok/s** — 本报告全是外推估值,§7 Q8 建议实跑替代。
  - **mlx-lm-lora 是否暴露 token 级 mask API** — 需读其源码确认,本报告只到"可能暴露"。
  - **C5 four-flag masking 在 mlx-lm `train()` loss callable 的具体接线** — 设计意图坐实(issue#1224),但实际 ~50 行实装代码未写未验。

---

## 9. 一句话给磊哥(15 轮 grill 前的总锚)

> P1-C 训练后端**不是问题**(本机 mlx-lm 已装,M5/32GB over-provisioned,omlx=推理 GUI 与训练无关);真问题是 **masking 四形态实装(train_on_turn 死门 + arg-value 取舍 + function/arg 增广)+ held-out 防记硬背 + fuse 端侧对账**三个数据/工程门;base 锁 Qwen3-1.7B(外部 benchmark + 内部 spike + chat_template 三证),2B 降 P2 探索 spike。15 轮 grill 见 §7,⭐ 默认已标。

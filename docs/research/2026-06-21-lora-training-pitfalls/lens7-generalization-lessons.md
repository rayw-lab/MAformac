# Lens 7 调研存档:泛化 + 防记忆化 + 经验教训(MAformac C5 LoRA)

> ultracode 深度研究第 7 路。13 次 WebSearch 联网搜证 + 本机 MAformac smoke 报告/config/closeout 一手核验。每条 finding 带 source URL + 日期 + applies_to_maformac 判定。
> 调研对象:Qwen3-1.7B(4bit base)+ bf16 LoRA,mlx-lm 0.31.1,Mac M5,中文车控 FC,dry-run 模板数据,当前 smoke loss 早期 spike 后稳定。

## Summary(本路核心结论)

最大泛化威胁不是「LoRA 不够强」,而是「在低多样性模板数据上把格式/槽值记死」。三条业界一手主线:

1. **arg-token + function masking 是防记忆化最有效单一手段** — GOAT(2510.12218)/OLISIA(DSTC11)直接验证,MAformac 3 HIGH 的 masking 决策被坐实是对的,不是过度治理。
2. **决定泛化的是数据多样性** — 模板渲染串让模型记格式而非学结构;1.7B 是小模型,吃多样性收益最大;正式训练接云多源 generator 才解坑。
3. **held-out 必须按『换说法+没见过 arg 值+按 bug_id 分层』切** — 否则 seen 高分=死记假象;MAformac 当前 generalization diagnostic = blocked_missing,此刻任何「提升」断言不成立。

两个 closeout 已标但需放大的工程坑:① smoke loss「spike 后 stabilize、train 收尾高于 val」是 LR 偏高早期不稳+dropout=0+模板数据混合信号,非经典过拟合;② 4bit base + bf16 adapter fuse 到 4bit 是 QLoRA 著名「merge-into-4bit 静默掉 10-30%」陷阱(closeout fuse_parity_gate: FAIL 命中),端侧 V-PASS 前必须三路 parity 实测。

LoRA 在小模型「学得少但忘得少」是优势(与三层路由『规则吃 80%、LoRA 碰 20%』天然契合,保 base 能力),但 rank=16 在 1.7B 接近容量边界,3 epoch 模板数据易触发 Qwen 已被观测的语义多样性塌缩。

## 本机一手核验(MAformac smoke 实况)

- config(r10):LR=2e-4 cosine(到 2e-5)、rank=16/alpha=32(=2r,实得 LR ×2)、dropout=0、batch=4/grad_accum=4、epochs=3、warmup 48 步、max_seq=1024、target=7 模块(attn qkvo + mlp gate/up/down)。
- receipt:4956 rows / 4556 train-eligible / 400 dev_selection;route_tier fc_l2=2845/fc_l3=948/rule_l1=307;rehearsal_ratio=0.075;refusal_ratio=0.10;masking_coverage 四项全 true;prompt_distractor=9912。
- closeout 关键事实:status=PARTIAL_T_PASS_NOT_CANDIDATE;loss trend = early_spike_then_stabilized(train 5.711→4.713,val 4.473→4.680,iter70-100 spike);r9 scheduler 实际没生效(常量 2e-4),r10 修;**generalization diagnostic = blocked_missing(in-dist/heldout/OOD/gap 全 null)**;**fuse_parity_gate = FAIL**;数据为 deterministic protocol 串,不满足 Q13/Q14/Q15。

## Findings(9 条,带 source)

### F1 [HIGH] arg-token + function masking 是防记忆化最有效单一手段
GOAT(arXiv 2510.12218, 2025-10):标准 LoRA 微调过拟合到见过的 argument 值;对比 self-distillation vs masking,**masking 尤其有效**——阻止记 argument 值、强迫学 API 格式结构。OLISIA/DSTC11(arXiv 2304.11073):引入新槽值后 JGA 绝对 +7-8%。
- applies_to_maformac:**正向确认**。receipt masking 四项已 true。masking 不可在轻治理名义下砍;正式训练需用 offset fixture(已 pass)+ 抽样核验 argument_value 段 loss 真为 0。
- source:https://arxiv.org/pdf/2510.12218 ; https://arxiv.org/pdf/2304.11073

### F2 [HIGH] 数据多样性决定泛化;模板串导致格式记忆 / unseen paraphrase 崩
『What Matters in LLM-generated Data』(2506.19262):多样性与泛化强相关,**越小的模型越吃多样性**(124M 正相关/1B 居中/8B 反相关)。BFCL 鲁棒性:轻微 paraphrase 让 top 模型 AST acc 掉 11-19%,加 distractor 工具再掉 1-8%。
- applies_to_maformac:**当前 smoke 最大隐患**。closeout 明写 deterministic data 不满足多源生成。用模板串正式训练 = 训模板格式专家,客户换说法崩,违 demo 北极星。必须接云多源 generator 产真口语变体。
- source:https://arxiv.org/html/2506.19262v2 ; https://arxiv.org/pdf/2511.01490 ; https://proceedings.mlr.press/v267/patil25a.html

### F3 [HIGH] held-out 必须三轴切,否则 seen 高分=死记;当前 diagnostic 全 null
seen/unseen split 是分离记忆 vs 泛化的标准法(ToolBench/xLAM 三层 held-out;xLAM 训练在 Live 集发布前完成防污染)。generalization gap = val−train perplexity,与记忆攻击 recall 直接相关。over-memorization(2508.04117):perplexity 升但 acc 维持 = 已过度记忆,应更早停。
- applies_to_maformac:**命中**。diagnostic blocked_missing,此刻 base-vs-LoRA 提升不能算泛化。held-out 三轴=(1)换说法(2)没见过 arg 值(3)按 bug_id 分层;必出 train/val perplexity gap。
- source:https://arxiv.org/html/2601.13392 ; https://www.frontiersin.org/journals/digital-health/articles/10.3389/fdgth.2026.1783907/full ; https://arxiv.org/pdf/2409.03215 ; https://arxiv.org/html/2508.04117v2

### F4 [HIGH] smoke loss spike/train>val ≠ 过拟合,是 LR 偏高+dropout=0+模板数据;正式训练前降 LR/加 dropout/降 epoch
LR 偏高是 loss 上冲第一主因(mlx-examples #583/#985;『Learning Rate Matters』2602.04998:LR 最主导,LoRA 实际 LR 被 alpha/r 放大)。train>val 通常是 dropout 训练期生效+半 epoch 偏移+小数据集 split 噪声(但 MAformac dropout=0)。mlx-lm 无内置 early-stop/epoch,需手动控 iters + 频繁 eval + 手选最低 val checkpoint。
- applies_to_maformac:**命中**。LR=2e-4×2、dropout=0、epochs=3;r9 scheduler 没生效 r10 修。动作:r10 真 schedule 重跑 smoke;仍 spike→LR 降 1e-4/5e-5;dropout 提 0.05-0.1;epochs 接真数据后监控 val 早停。
- source:https://github.com/ml-explore/mlx-examples/issues/583 ; https://arxiv.org/pdf/2602.04998 ; https://github.com/ml-explore/mlx/discussions/728

### F5 [HIGH] 4bit base + bf16 adapter fuse 到 4bit = QLoRA 静默掉 10-30% 陷阱;端侧 V-PASS 前三路 parity 实测
Kaitchup『Don't Merge Into 4-bit』+ Rohan Paul + 实战 part3:adapter 训练时 base 被 dequant 到 16bit,从没见过 4bit;直接 merge 进 4bit 或 merge 后量化静默掉 10-30%,训练 val 看不出。最干净=不 merge 动态加载 adapter;必须 fuse 则 dequant→merge→requant 复刻训练量化配置;硬要 4bit 服务用 QA-LoRA/LoftQ/PiSSA/QDoRA。
- applies_to_maformac:**命中,closeout 已部分自觉**。base mlx-community/Qwen3-1.7B-4bit,iPhone 8GB 必 fuse+量化。fuse_parity_gate FAIL。端侧 V-PASS 必实测三路 parity,绝不由训练态推断;4bit 掉点明显则优先端侧动态加载或 LoftQ/PiSSA。
- source:https://kaitchup.substack.com/p/dont-merge-your-lora-adapter-into ; https://www.rohan-paul.com/p/lora-and-qlora-be-careful-when-merging ; https://medium.com/theultimateinterviewhack/qlora-merging-the-quantized-vs-non-quantized-dilemma-part-3-9a9f1ad56ff9

### F6 [MEDIUM] LoRA 小模型『学得少但忘得少』利好;但 rank16/1.7B/3epoch 模板易触发 Qwen 语义塌缩
Biderman『LoRA Learns Less and Forgets Less』(2405.09673, TMLR2024):LoRA 目标域学少、源域保得好、比 weight decay/dropout 更强正则、保多样性;rank 太低表达力受限,IFT 高 rank(256)可补。distil labs(2025-12):越小模型微调收益越大。building-codes:Qwen LoRA 后 BERT Recall 掉 0.76%(capacity saturation)。alpha=2r 业界默认且关键。
- applies_to_maformac:**部分命中,整体利好**。三层路由下 LoRA 只练 20% 模糊域,『forget less』正好保 L1 规则+中文+base FC。rank16/alpha32 业界默认对。监控:C6 diff 必加『base 原能力退化』轴;泛化不够且 forget 可控可试 rank32(secondary 已规划);别用高 LR 补低 alpha。
- source:https://arxiv.org/abs/2405.09673 ; https://www.distillabs.ai/blog/we-benchmarked-12-small-language-models-across-8-tasks-to-find-the-best-base-model-for-fine-tuning/ ; https://arxiv.org/pdf/2505.04666

### F7 [MEDIUM] LoRA 非天然完全抗遗忘;高 rank/高 LR/多 epoch 仍触发灾难性遗忘
OPLoRA(2510.13003)/Mitigating Forgetting in LoRA(2512.17720):rank=64 训 3epoch 无缓解时 LoRA/DoRA 都出现灾难性遗忘。缓解栈:更小 LR、混 5-20% rehearsal、对 base L2/KL 正则、通用 benchmark 早停、层冻结、adapter 可换不 merge。
- applies_to_maformac:**部分命中**。rank16/3epoch 风险中等。receipt 已埋 rehearsal 0.075(正向)但偏低于 5-20% 下限。动作:可提 rehearsal 到 0.1-0.15;端侧保 adapter 可换/不 merge(参数隔离最稳,与 F5 同结论);C6 diff 含遗忘哨兵轴。
- source:https://arxiv.org/pdf/2510.13003 ; https://arxiv.org/pdf/2512.17720 ; https://zeroentropy.dev/concepts/catastrophic-forgetting/

### F8 [MEDIUM] 质量/多样性 > 数量;移除最被记忆的 10% 反而提升泛化
业界『quality > quantity』,500-2000 精制胜几千平庸。Information Bottleneck(2510.16022, 2025):移除最被记忆的 10% 数据,Pass@1 显著提升(memorization barrier 困住优化)。
- applies_to_maformac:**命中**。3990+12000bug,4956 train-eligible。device×primitive×value 笛卡尔会爆同质样本=最被记忆的 10%。CLAUDE.md 已定加权采样非笛卡尔(正确)。正式训练后做 memorization 排查下采样最同质;宁可 2000 真多样,不要 5000 模板克隆。
- source:https://arxiv.org/html/2510.16022 ; https://unsloth.ai/docs/get-started/fine-tuning-llms-guide/lora-hyperparameters-guide

### F9 [MEDIUM] Qwen3 enable_thinking=False 的 train-serve 一致性是隐性泛化杀手
Qwen3 template 在 enable_thinking=False 注入空 think 块;历史 bug:多 assistant turn 注入不一致(HF discussion#9 已修)。serving 框架常不真 honor(ray #52979)。tool_call.arguments 双重转义 bug 污染参数。
- applies_to_maformac:**命中,closeout 部分处理**。B1 已修(训练专用 tokenizer patch,offset fixture pass)。但端侧 mlx-swift runtime 是否同样处理 think 块没验。动作:端侧实跑一条 FC 比对训练 tokenization(active probe,§34);多轮样本核多 assistant turn think 注入;作端侧 V-PASS 前置。
- source:https://huggingface.co/Qwen/Qwen3-1.7B/discussions/9 ; https://github.com/ray-project/ray/issues/52979 ; https://huggingface.co/blog/qwen-3-chat-template-deep-dive

## Pre-Mortem 三分类(详见 pre_mortem 结构字段)

- **Tiger(4)**:模板数据格式记忆 / 4bit fuse parity 静默掉点 / 无 held-out 宣称提升 / LR 偏高早期不稳。
- **Paper-tiger(3)**:train>val 看似异常(实为 dropout=0+LR上冲+split噪声,非过拟合)/ LoRA 忘 base 能力(rank16+三层路由风险中等,Biderman 证 forget less)/ rank16 太小(真瓶颈是数据多样性非 rank)。
- **Elephant(4)**:同质模板样本是最被记忆的 10% 拖累泛化 / 端侧 mlx-swift enable_thinking 必逐位一致 / rehearsal 0.075 偏低于 5-20% / held-out 必按 bug_id 整组分层防同 bug 不同句泄漏。

## 对 MAformac 的 actionable 收敛(给主线程 grill 弹药)

1. **正式训练数据**:必须接云多源 generator 产真口语变体,不能用 dry-run 模板串训正式;⭐默认 = 多样性优先 + 加权采样非笛卡尔。(F2/F8)
2. **held-out 切分**:三轴(换说法 + 没见过 arg 值 + 按 bug_id 整组分层),必出 train/val perplexity gap;diagnostic 从 blocked_missing 落地。(F3,elephant#4)
3. **超参**:r10 真 cosine schedule 重跑 smoke 确认 spike 消;仍 spike → LR 1e-4/5e-5;dropout 0→0.05-0.1;epochs 接真数据后监控 val 早停手选 best checkpoint。(F4)
4. **端侧 parity**:V-PASS 前实测三路(动态 adapter vs fused bf16 vs fused 4bit);⭐若 4bit 掉点 → 优先端侧动态加载 adapter(不 merge)或 LoftQ/PiSSA。(F5)
5. **防遗忘哨兵**:C6 base-vs-LoRA diff 必加『base 原能力退化』轴;rehearsal 偏低可提 0.1-0.15。(F6/F7)
6. **masking 落实核验**:不只 receipt 标 true,抽样核 argument_value 段 loss 真为 0。(F1)
7. **train-serve template**:端侧实跑一条 FC 比对训练 tokenization(active probe)。(F9)

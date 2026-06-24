# L10：灾难性遗忘 + 通用中文混入

> 维度：catastrophic forgetting + general-Chinese-data mixing。自评 **P1**（可能被误当 P0：泛化是架构命门，但灾难遗忘≠0/34 根因）。
> 横切纪律：12+ 联网搜证（近 3 月优先）+ 本机 scout（mlx-lm 0.31.1 / 32GB / home-llm clone 实读）+ home-llm 一手 grep。

## Summary

灾难性遗忘是 1.7B 小模型在 562 D-domain 窄域 SFT 上的**真实威胁**，直击 MAformac 架构命门（SRD"demo 价值=路由对+泛化+拒识"），窄域 SFT 已被多篇 2024-2026 实证损伤 **paraphrase robustness**（对模糊/换说法听不懂=L2-L5 意图收缩崩）。最同构证据=**Alopex（arxiv 2411.05209）**：Gemma-2B/Qwen1.5-1.8B/StableLM-1.6B 训完 function-call 后 MMLU/GSM8K/Arc 全降，1:1 混 tiny-textbooks 恢复。

结论**分两层**：①灾难遗忘**不能阻止 0/34**（0/34 是 surface mismatch+generic frame 判定面爆炸、业务行为全塌缩 toolCalls=[]，不是泛化退化）→自评 **P1 非 P0**；②是 demo 上线后"客户换说法就听不懂"的**隐性炸场风险**，必须做通用中文 eval（C-Eval/CMMLU 零样本）当回归门+混 5-25% 通用中文数据当保险。

守 **rank16Mainline（LR1e-4/epochs3/LoRA 非 full FT）本身就是遗忘三件套防线**（LoRA learns less forgets less+小 LR+少 epoch 全占）。**最大反讽 elephant**：home-llm 这个最大蓝本虽混了 alpaca（且"handle not so well"反而轻微降 task eval），但 `evaluate.py` **只测 function-call accuracy、根本没有任何通用 benchmark**。

## Findings

**F1 LoRA learns less forgets less（canonical, support 配方）**：LoRA 比 full FT 更好保留源域知识但学得少作强正则；BUT 不消除遗忘，rank 越高+epoch 越多越易遗忘；intruder dimensions causally 致遗忘。source: arxiv 2405.09673v2 + 2410.21228（2026-06-24）。support rank16Mainline——守 LoRA+rank16+epochs3=遗忘三件套全占。

**F2 端侧小模型 FC 窄域 SFT 掉通用 benchmark（最同构一手）**：Alopex 实测 Gemma-2B/Qwen1.5-1.8B/StableLM-2-1.6B/Fox-1 训完 FC 后 MMLU/GSM8K/Arc/HellaSwag/Winogrande/TruthfulQA 全降，1:1 混 tiny-textbooks 缓解部分反超。source: arxiv 2411.05209（精确数 PDF 受限进 external_claims）。worse than base，1:1 混通用可恢复→支持混通用建议。

**F3 窄域 SFT 损伤 paraphrase robustness（命门）**：fine-tune 让 token 不再按语义相似分布对扰动变脆；instruction-tuned LLM 仍对 rephrasing fragile。正是 SRD 意图收缩+泛化听懂模糊说法（L2-L5）依赖的能力。source: arxiv 2404.10174 + 2402.11138（2026-06-24）。worse；缓解=训练数据混 paraphrase/noise 增广（与 value 四件套同向已部分在配方）+混通用。

**F4 混通用比例 5-15% 即缓解；覆盖>精确比例**：DMT composition ratio 影响 insignificant amount 重要；Qwen3/Unsloth 建议 75%reasoning/25%non-reasoning；DMT 两阶段（先专精后混+1/256 rehearsal）最优。source: arxiv 2310.05492v1 + Unsloth Qwen3 docs（2026-06-24）。escape_hatch——现配方只有 D-domain 四类数据**无通用中文腿（新 insight② 缺通用混入腿）**；建议 C11-C12 spike 把通用混入 5-25% 当 hypothesis 测不拍死。

**F5 小 LR+少 epoch 第一线非保证**：SFT Doesnt Always Hurt（2509.20758 直接 fetch 确认）smaller LR 1e-6 级 substantially mitigate 通用退化 target 域几乎不掉；但救不了数据稀缺 overfit 需配 LoRA/混数据；LoRA 1-3 epoch >3 overfit。support——LR1e-4 是 home-llm 实测甜点（phi rev8.2 overcranking、rev5 4th epoch overfit），epochs3 在 1-3 区；BUT 1e-4 比 1e-6 高 2 量级是混通用额外理由。

**F6 home-llm 混 alpaca 但轻微降 task（trade-off 实例）**：训练混 Alpaca（alpaca-cleaned+taco translated）但 phi 笔记记"handle not so well"；发布 v2 GGUF（rev5_2/rev6_2 eval0.88）用 large/xl 无 alpaca；3B 发布 rev2 xl+alpaca eval0.873 反低于 rev1 large 无 alpaca 的 0.909。source: file experiment-notes-phi.md:232-345（2026-06-24 Read）。worse 对 task eval——印证过多通用稀释任务需找 sweet spot。

**F7 home-llm eval 只测 FC 无通用 benchmark（elephant 一手坐实）**：evaluate.py 只算 correct_answers/total_answers（icl_example_generator+工具调用集合匹配）；data/piles/english/ 只有 device/action/refusal/failed-tool piles 无通用语料。source: file train/evaluate.py:85-216 + piles ls（2026-06-24）。elephant——照搬会盲，建议 C6 bench 新增通用中文 eval 维度。

**F8 通用中文 eval 选型+零样本陷阱**：C-Eval（52 学科 13948 题）+CMMLU（67 主题 11.5K 题）配 MMLU；陷阱 fine-tuned/instruct 模型应零样本评（5-shot example 与 SFT 分布 mismatch 低估、CMMLU 作者实证 fine-tuned 加 example 反 decline）。source: arxiv 2306.09212v2 + C-EVAL NeurIPS2023（2026-06-24）。support 加回归门——base 跑零样本存基线→candidate 掉超阈值=遗忘红灯；轻量化抽子集当 smoke 门。

## 假想验证

假想：1.7B 训 562 D-domain 不混任何通用数据后中文泛化退化多少→架构冲击。**预测**：C-Eval/CMMLU 掉 5-15 个百分点（中度退化非崩盘），但 paraphrase/模糊说法泛化退化更隐蔽更致命。**依据**：①Alopex 实测端侧小模型（含 Qwen1.5-1.8B）窄域 FC SFT 后 MMLU/GSM8K/Arc 全降；②rank16Mainline 用 LoRA+LR1e-4+epoch3 缓冲不会像 full FT 崩到<1%（chemistry full FT Acc@1<1% 灾难），LoRA 稳在 learns less forgets less 区；③但 LR1e-4 比 1e-6 高 2 量级+562 窄域+单语中文 paraphrase 退化被放大。**架构冲击=命门级但分层**：(a)灾难遗忘不阻止 0/34（0/34 是 generic frame 判定面爆炸+surface 异源致 toolCalls=[]，A2 已力挽，遗忘是旁路）；(b)真威胁=demo 上线客户换说法/说模糊听不懂或硬塞错工具（L2-L5 慢路退化露怯）。**失败模式**：①过拟合 562 句式→换说法落不到正确 intent；②通用中文常识/闲聊退化→边界外答得傻破惊艳；③混太多>25%→反向稀释工具精度（home-llm alpaca 实例）。**缓解**：守 LoRA+小 LR+少 epoch（已在配方）+混 5-25% 通用中文（C11-C12 spike 测比例）+训练数据 paraphrase/口语化增广（需扩口语变体）+C-Eval/CMMLU 零样本回归门。**净判断**：worse if 不混不测但可控（非 0/34 级灾难），不该当 P0 抢 A2/gate 工时——属 retrain-c5/C6 DEFERRED 训练线不碰 A2 surface。

## Pre-mortem 三分类

**Tigers**：①不混通用→客户换说法听不懂（验证：held-out 口语化/换说法 query 测 intent 命中率对比 base；核 C6 是否含 paraphrase held-out）；②不跑通用 eval（照搬 home-llm 盲点）遗忘不自知（验证：grep vehicle-tool-bench axes 是否只 D-domain 行为轴；无则 rebuild-c6 加 C-Eval/CMMLU 零样本门）。

**Paper-tigers**：①"灾难遗忘是 0/34 根因须 P0"——paper-tiger（0/34=generic frame 爆炸+masking 假删+surface 异源 A2 已对症，与遗忘正交不抢工时）；②"必须用 O-LoRA/LoRA-Null/CURLoRA/OPLoRA 变体"——paper-tiger over-engineering（解 continual 多任务遗忘；MAformac 单次 SFT，标准 LoRA+小 LR+少 epoch+混 5-25% 已最优，变体 oppose 配方+增复杂度）；③"混越多通用越好"——paper-tiger 反向风险（home-llm alpaca+tool-calling optimal ratio 证有 sweet spot，过多稀释工具精度；5-25%/DMT 两阶段更稳是 hypothesis 待 spike）。

**Elephants**：①home-llm evaluate.py 根本没通用 benchmark（只 FC accuracy）即便混 alpaca 也没验证通用保住，照搬继承盲点必须加通用中文回归维度；②MAformac 单语中文 LoRA+base 中文通用本就强，真该担心的不是中文常识掉而是 562 窄句式过拟合后对中文模糊/口语/换说法 intent 泛化掉，eval 重心放 held-out paraphrase intent 命中率通用 benchmark 是辅助 sanity；③训练数据全是 contract 派生标准句式即便混 Alpaca 也救不了 D-domain 内部 paraphrase 泛化（通用数据保闲聊常识保不了空调温度怎么说都听懂），这条腿要靠 D-domain query 口语化/换说法增广不是混通用能替代；④通用中文 eval 零样本陷阱：instruct/SFT 模型 5-shot 评因 shot mismatch 被低估（CMMLU 作者实证），回归门必须零样本+与 base 同口径否则误判遗忘（实为 shot artifact）。

## Must-answer 5 条
1. **prevents_0_34**：no（0/34=generic frame 爆炸+masking 假删+surface 异源 A2 已对症；灾难遗忘正交、上线后才暴露）。
2. **priority_self**：P1。
3. **vs_rank16mainline**：support（守 rank16Mainline 即遗忘三件套防线全占；只 escape_hatch 加混 5-25% 通用腿+通用 eval 门，不改超参）。
4. **requires_a2_surface_change**：no（全落 retrain-c5+rebuild-c6 DEFERRED，不碰 A2 D-domain surface）。
5. **introduces_deferred**：yes 边界内（训练数据配方+真实通用 eval 属 retrain-c5/rebuild-c6 DEFERRED 训练线，符合 Phase 0 纯搜证+假想验证边界；产出=decision-pack 弹药供 propose）。

## clone 发现（home-llm 一手）
- `train/evaluate.py:85-216` evaluate() 只算 correct_answers/total_answers（function-call 集合匹配），**无任何通用 benchmark**。
- `docs/experiment-notes-phi.md:232-345`：included the alpaca split + "handle alpaca not so well"；发布 v2 GGUF 用无 alpaca 数据；3B xl+alpaca(0.873) 反低于 large 无 alpaca(0.909)。
- `data/piles/english/`：只有 device/action/refusal/failed-tool/status piles，无通用语料。
- adopt/adapt/drop：ADOPT refusal/failed-tool-call piles 思路（与 MAformac D-domain safety/unsupported 同向）；ADAPT alpaca 混入经验→改混中文通用且控比例 5-25%（MAformac 单语中文）；DROP（补齐）其只测 function-call 的 eval 框架缺陷，MAformac 必在 C6 加通用中文 eval 维度。

## 本机 scout 实况
mlx-lm 0.31.1 已装；内存 32GB（hw.memsize 34359738368）；home-llm clone 在 ref-repos/home-llm，data 目录 2026-06-24 02:12 有改动。

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

---
type: probe-report
version: 3
topic: C5 数据生成(训练集/评测集/测试集)的 generator/validator 选型与编排
depth: standard
date: 2026-06-21
methods: [Anti-Confirmation-Bias, Onion-Peeling, ACH, Tribunal, Steelman, Toulmin, Pre-Mortem, Key-Assumptions-Check, Frontier-Scan]
hypotheses: [H1 顶级模型生成, H2 gen≠judge, H3 gold规则锚, H4 防capacity-gap, H5 多源diversity]
verdict_summary: "三类数据集三权分立(训练 LLM 多源产 utterance / 评测·测试 gold 规则锚定+人审,generator 绝不自定 gold);generator 多源、label/gold 用 C1 契约 deterministic、validator/judge 异源;本机小模型当 generator 是错的(dev-time 无离线约束)"
confidence_range: 70-92
trigger: "磊哥纠偏——我把 runtime 离线约束错误施加到 dev-time 数据生成;/probe 研究 generator 选型"
---

# Probe: C5 数据生成的 generator/validator 选型与编排

> 触发:grill Q13 时我钻牛角尖推「本机 35B/2B 当 generator」。磊哥纠偏:dev-time 数据生成无离线约束,该用现成顶级大模型(Claude API subagent / Hermes gpt-5.5 / Codex / GPT Pro,无尽额度);训练守 LoRA+1.7B。本 probe 把 generator 选型研究透,收敛回修正 Q13 + 喂 Q14。

## 反确认偏差协议

- **用户立场**:数据集/评测集/测试集 → 现成顶级大模型;训练 → LoRA+1.7B 本机。
- **重构问题**:什么条件下「用顶级云大模型生成 C5 数据」最优?三类数据集(训练/评测/测试)约束是否相同?
- **对立面 Steel Man**:顶级闭源大模型产合成数据有同质化/尾部收窄;"更强 teacher"未必产出"1.7B student 学得动的分布";各厂商 tool-call 格式偏好污染 C1 协议;评测集 gold 若 LLM 自定 → 评测在测"像不像 generator"而非"对不对"。
- H1 = 用户立场,搜证 60/40 倾向反面。

## Phase 0: 假设拆解

- **H1**(技术/工程):dev-time 无离线约束,顶级模型生成质量 >> 本机小模型,应做。前提「能产出适合 1.7B 学的分布」`[未验证]`。
- **H2**(方法/质量):generator≠validator/judge,跨模型避 self-preference。
- **H3**(风险/评测有效性):三类数据集约束不同——训练集 LLM 可产 diversity;评测/测试集 gold 必须规则锚定+人审,LLM 绝不自定 gold。
- **H4**(训练/蒸馏):守 1.7B+LoRA 对,但强 teacher 产数据训弱 student 有 capacity gap。
- **H5**(工程/编排):多模型价值在 diversity 非单一最强;防 cross-model 格式污染。

未验证前提搜证重点:H3「LLM 自定 gold→评测失效」(最高)/ H2 self-preference / H4 capacity gap。

## Phase 0.5: 洋葱剥皮(决策相关层)

### L1 本质:三类数据集是三个不同的东西(最关键澄清)
| 数据集 | 本质 | 要什么 | gold 谁定 |
|---|---|---|---|
| 训练集 | 见够多样模糊说法 | diversity | C1 契约(deterministic) |
| 评测集(C6) | 测对不对=release gate | correctness/gold | 规则锚定+人审 |
| 测试集(heldout) | 测泛化不死记 | gold 锚定+无泄漏 | 规则锚定 |

本质区别:训练集可放飞 diversity(LLM 强项);评测/测试集**绝不能让 generator 同时定 gold**。

### L2 机制:generator-validator-gold 分离 pipeline
```
训练集: [3990 真实种子=锚点] → 多模型 generator 产口语 candidate
   → label=C1契约(deterministic,非LLM) → dual_layer validator(异模型 judge)
   → dedupe/diversity → redaction → heldout regression → train-eligible
评测/测试集: [3990种子+12000bug] → 规则锚定 gold(契约算)
   → LLM 仅产 candidate utterance(措辞) → 人抽审 gold → 锁 must_not_train
   ↑ generator 绝不碰 gold
```

### L3 代价与天花板
| 方案 | 代价 | 天花板 | 缓解 |
|---|---|---|---|
| 顶级云大模型 generator | 同质化/尾部收窄;格式渗入;self-bias | 产出分布≠1.7B 学得动 | 真实锚点+异模型judge+per_seed≤8+label契约 |
| 本机小模型(已否决) | 质量/多样性不足 | 自举偏置 | dev-time 无离线约束,没必要,放弃 |
| 纯规则 | 口语尾部覆盖不全 | fc_l3 多样性天花板 | LLM 补尾部 |

## Phase 1: 证据 + ACH

### 证据清单
- E1 self-preference bias 普遍+self-refine 放大(Panickssery NeurIPS'24/Xu'24) [HIGH][2024]
- E2 根源 perplexity/familiarity(Wataoka'24) [HIGH][2024]
- E3 🔴 preference leakage:judge 偏好同家族 generator(Li 2026a) [HIGH][2026]
- E4 🔴 LLM-as-benchmark-generator self-bias→高估(Silencer 2505.20738) [HIGH][2025]
- E5 🔴 curse of capacity gap:大 teacher 蒸更差 student,合成数据上 weak teacher 反而好 [HIGH][2023-24]
- E6 多源合成>单源:缓 collapse+降 self-pref(Synthetic Eggs 2511.01490) [HIGH][2025]
- E7 model collapse:递归合成尾部消失,需真实锚点(Nature'24) [HIGH][2024]
- E8 Self-Instruct generate-then-filter,丢弃~58%(ACL'23) [MED]

### ACH 矩阵
| 证据 | 可信 | H1 | H2 | H3 | H4 | H5 | 诊断 |
|---|---|---|---|---|---|---|---|
| E1 | HIGH | — | ✓ | ✓ | — | ✓ | 高 |
| E3 | HIGH | ✗ | ✓ | ✓ | — | ✓ | 高 |
| E4 | HIGH | ✗ | ✓ | ✓ | — | — | 高 |
| E5 | HIGH | ✗ | — | — | ✓ | ✓ | 高 |
| E6 | HIGH | ✓ | ✓ | — | — | ✓ | 高 |
| E7 | HIGH | ⚠️ | — | — | — | ✓ | 中 |

最强:H3(零不一致,E3/E4 双HIGH)+ H2。需限定:H1(不一致针对"单一最强+无过滤+gen定gold"极端版)。最具诊断:E5(区分"用最强 vs 用中等")。

## Phase 2: 法庭辩论(聚焦 H1/H4)

### H1 裁决 ⚠️ 部分成立(置信 82)
H1 大方向对(dev-time 顶级模型 >> 本机),但须限定:多源混合、含中等模型、label 契约定、真实锚点、过滤。辩论核心张力:E5 capacity gap 在合成数据上 weak teacher 反而赢——但辩护人指出我们是「teacher 产 utterance 文本(hard data)+label 由契约确定」,不学 teacher soft 分布,capacity gap 影响**大幅缓解**。共同盲区:"hard-data 生成的 capacity gap 弱于 logit 蒸馏"这个边界本身 `[未验证]`。

### H4 裁决 ⚠️ 部分成立(置信 70)
capacity gap 真实但被「label 契约定+hard data」缓解→影响中等。落地:generator 池含中等模型(Claude/GPT-5.5)为主力,最巨模型(GPT Pro pro)做难样本补充非唯一源。

### H2/H3/H5(证据一边倒,简裁)
- H2 ✅ 成立(88):generator≠validator,跨模型/跨家族(E1/E3)。
- H3 ✅ 成立(92,最强):评测/测试集 gold 规则锚定+人审,LLM 绝不自定 gold;评测 judge/generator 不能与被评 1.7B 同源(preference leakage E3/E4)。
- H5 ✅ 成立(85):多源>单源(E6)+真实锚点防 collapse(E7)。

## Phase 3: Pre-Mortem("6 个月后灾难性失败")
1. **评测集被 generator 污染**——同模型既产 train 又产 eval gold,1.7B 学到 generator 风格,评测虚高,真机翻车。应检查:eval gold 规则锚定+generator/judge 异源。
2. **单源同质化**——只用一个 generator,distribution collapse,fc_l3 尾部仍缺。应检查:多源占比+diversity gate。
3. **格式污染**——各厂商 tool-call 格式渗入,与 qwen-tool-call-format.yaml SSOT 漂移。应检查:label 强制走契约渲染+render-diff(接 Q12)。
4. **teacher 太强产学不动分布**——全用 GPT Pro pro 产复杂长句,1.7B 学不会。应检查:多源含中等模型+过滤学不动尾部。

## Phase 4: 综合裁决

### 4a ACH 最终排序
| 假设 | 不一致 | 置信 | 裁决 | Pre-Mortem 风险 |
|---|---|---|---|---|
| H3 gold规则锚+gen异源 | 0 | 92 | ✅ | 低(若执行) |
| H2 gen≠judge | 0 | 88 | ✅ | 低 |
| H5 多源 diversity | 0 | 85 | ✅ | 中 |
| H1 顶级模型生成(限定版) | 0 | 82 | ⚠️ | 中 |
| H4 防 capacity gap | 1(缓解) | 70 | ⚠️ | 中 |

### 4b 核心结论(Toulmin)
**结论1:三类数据集三权分立——训练集 LLM 多源产 utterance,评测/测试集 gold 必须规则锚定+人审,generator 绝不自定 gold。**
- Grounds: E3 preference leakage / E4 benchmark self-bias 双 HIGH
- Warrant: LLM 自定 gold → 评测测"像不像 generator"而非"对不对"
- Backing: Silencer/preference leakage + 本机已有 P0-3 trap/P0-4 verify_gold 纪律
- Qualifier: 评测/测试集强约束;训练集放宽(label 仍契约定)
- Rebuttal: 若 gold 规则可完全枚举(我们 ToolCall 正是),LLM 连 candidate 都不必碰 gold
- 下一步: 评测集生成单列一题,不与训练集混谈

**结论2:generator 多源(Claude/GPT-5.5/Codex/GPT Pro),label/gold 用 C1 契约 deterministic,validator/judge 异源。**
- Grounds: E6 多源>单源 / E1 self-pref / E5 capacity gap
- Warrant: diversity 来自跨模型;self-bias 靠异源 judge 破;最强单源既冒 collapse 又冒 capacity gap
- Qualifier: 主力中等-强模型,最巨模型做难样本补充非唯一源
- 下一步: 修正 Q13(删本机35B,改多源云);Q14 validator=异源

**结论3:本机 35B/小模型当 generator 是错的。**
- Warrant: 离线约束只在 runtime(端侧 demo),不在 dev-time 数据生成
- Qualifier: 唯一例外=数据出境,但产的是合成话术变体(非原文语料/PII),喂 prompt 用语义协议不喂原文→红线不破

### 4c 负空间 + 直觉检查
- **负空间**:① 数据出境红线——云模型产数据时喂进去的 prompt 必须只含语义协议(device×primitive×value),不喂 12000 bug 原文/原文语料。② 人审成本(gold 人审=磊哥,工作量未估)。③ Codex 偏代码,口语车控话术权重应低。
- **直觉检查(Red Hat)**:逻辑指向"多源+三权分立",但直觉不安=会不会过度工程化?solo demo 用 4 模型编排产数据会否 ceremony 过重?监控信号:第一刀可先 Claude 主力+GPT-5.5 异源 judge 两源起步,不必一上来四源全开。

### 4d 意外发现 + 少数派
- **意外发现**:capacity gap(E5)——"用最强模型"在合成数据上可能反而差,反转"无尽额度就用最强"的直觉;被"label 契约定+hard data"缓解。
- **少数派**:仅为冒烟(smoke_only),单一模型产几百条够跑链路,多源是 trainable_v0 才需要。

### 4e 一个待解之问
❔ 评测集(C6)gold 既然是 device×primitive×value 契约可确定性算出,那 LLM 在评测集生成里还有任何角色吗?还是评测集应 100% 规则生成、零 LLM,只训练集才用 LLM 产 diversity?(决定 Q14 之后是否单列"评测集生成"题)

### 4f 二句验证
"MAformac C5 面临 generator 选型,因为我误把 runtime 离线约束施加到 dev-time 数据生成。多源顶级模型产 utterance+契约定 label+异源 judge+评测 gold 规则锚定 通过三权分立解决,有效因为 self-preference/preference-leakage/capacity-gap 都指向'生成-标注-评判必须分离且 gold 不能 LLM 自定'。" ✓

## 灵感溯源
- [Self-Preference Bias 2410.21819](https://arxiv.org/abs/2410.21819) — HIGH | gen≠judge
- [Silencer self-bias in benchmark-generator 2505.20738](https://arxiv.org/pdf/2505.20738) — HIGH | gold 不能 LLM 自定
- [Curse of capacity gap 2311.07052](https://arxiv.org/pdf/2311.07052) — HIGH | 强 teacher≠好 student
- [Synthetic Eggs in Many Baskets 2511.01490](https://arxiv.org/html/2511.01490v1) — HIGH | 多源>单源
- [Nature model collapse](https://www.nature.com/articles/s41586-024-07566-y) — HIGH | 真实锚点
- [Self-Instruct ACL'23](https://aclanthology.org/2023.acl-long.754/) — MED | 生成后过滤

## 收敛回 grill(actionable)
1. **修正 Q13**:删 `generator_model_preference` 的本机 35B-A3B/2B/1.7B;改 **多源云模型**(Claude API subagent / Hermes gpt-5.5 / GPT Pro,Codex 权重低);第一刀可先 Claude 主力 + 异源 judge 两源起步。
2. **Q14 validator**:第二层语义 judge 用**异于 generator** 的模型(破 self-preference)。
3. **新增评测集生成题(Q-eval)**:评测/测试集 gold 规则锚定+人审,generator 绝不自定 gold;评测 generator/judge 不与被评 1.7B 同源。
4. **红线**:喂云 generator 的 prompt 只含语义协议(device×primitive×value),不喂原文语料。
5. **元教训**:此 probe 的结论大方向(dev-time 用大模型增广)在 `home-llm-teardown-data.md §8`(synthesize.py 用 gpt-oss-120b)早已沉淀,我未调用 → read-first 扩到调研沉淀。

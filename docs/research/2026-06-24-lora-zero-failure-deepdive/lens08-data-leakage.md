# L08 — 数据泄漏 / 语义漂移 / heldout 污染门（C5 大败逃第四深坑）

> 维度：数据泄漏 / 语义漂移 / heldout 污染门。🔴 磊哥点名独立的「评测变好其实污染=假胜利」深坑。
> as-of 2026-06-24 ｜ Lens = L08 ｜ 边界 = Phase 0 pre-propose 弹药，纯搜证+假想验证，不执行训练/真实评测/数据生成/voice/受限解码
> 一手锚：补充意见#1 / grill C13 / 0/34 复盘后第四深坑 / 本机 `C5DataGate.swift:264-285` + `docs/p1c-training-grill-decisions.md` Q13-Q15
> 自评 priority：**P1**（不阻止 candidate 塌缩 0/34，阻止『下次训出来看着过了其实污染』的二次隐性灾难）

---

## 0. 核心结论（summary）

数据泄漏是 0/34 之后**真正最隐蔽**的坑：candidate 全塌缩(0/34)是**显性**失败(toolCalls=[]，一眼可见)，泄漏是**隐性**的——评测分漂亮、看着赢了，实则训练集混入了 heldout/protected 语义近邻，模型在『见过近似的』测试集上虚高。

**三个核心事实**：
1. **项目方法论已铺到 SOTA 水平**：grill Q13-Q15(2026-06-21)已把『candidate 语义重判不继承 seed + embedding nearest-protected 发现 + Q14 异源 judge 共判 + quarantine fail-closed』全部决策化，与业界 LLM-decontaminator(2311.04850)/SemDeDup(2303.09540)同构。
2. **code 实装仍是缺口**：`Core/Bench/C5DataGate.swift:264-285` 实读=纯 `overlapParentSemanticID` 集合交集(train ∩ non-train)，**零 embedding/n-gram/cosine/drift 逻辑**。这正是 Q15 自己点破的「:252 假安全」——继承 seed ID 永在 train、文本漂到 heldout 但 ID 没漂→交集空→假通过。`contracts/semantic-quarantine.jsonl` 现 **0 行**(有 schema 无产物)。
3. **1.7B+LoRA 上事后检测不可靠**：LoRA 低参数抑制 verbatim 记忆(2506.20856)，使 MIA/CDD 类污染检测在小模型失效(2603.03203)→ **不能靠『评测高就放心』，必须数据侧前置防**。

**最强一刀**：工程铁律「**augment AFTER split + 同一 semantic family 全部归一 partition**」(Gerz&Jelali 2025 实证：augment-before-split 虚高 65.93pp)，比任何 cosine 阈值都硬，结构性消除大半泄漏需求。

---

## 1. 每条 finding（带 source）

### F1 — exact parent_semantic_id gate 不够（核心实装缺口）
现 `C5DataGate.swift:264-285` 纯 `overlapParentSemanticID` 集合交集，零语义层。Q15 自捕「:252 假安全」：继承 seed『打开空调』ID → 增广 utterance 漂到 heldout『调高温度』语义但 ID 没漂 → 交集空 → 假过。
- 修法：增广后**重判 `candidate_parent_semantic_id`**(不继承 seed)喂 gate + 叠 embedding nearest-protected。
- source：`Core/Bench/C5DataGate.swift:264-285`(本机实读) + `docs/p1c-training-grill-decisions.md:254,269`
- vs：rank16Mainline=**escape_hatch**(只补数据 gate)；vs 现 gate=better(exact-ID 必要不充分)

### F2 — n-gram/exact 抓不到 paraphrase 是结构性盲点
13B rephrase 后达 GPT-4 且 n-gram 测不出(2311.04850 MMLU/GSM8k/HumanEval)；ELI5 81% test 是 train paraphrase 用 TF-IDF 没挡住。
- source：https://arxiv.org/abs/2311.04850 (WebSearch 核实真实) + WebSearch 2026-06-24
- vs：现 gate=better(补上 exact 测不到的语义层)；量级 unknown(MAformac 域内 paraphrase 泄漏率未实测=spike 待测)

### F3 — 标准解药=LLM-decontaminator 两阶段(embedding top-k + LLM judge)
正是 Q15『embedding_nearest_protected_semantic + Q14_cross_vendor_judge』的业界对应。MegaScience 2025 现代版=BGE-large top-5 + Llama3.3-70B zero-shot 判 paraphrase。
- source：https://github.com/lm-sys/llm-decontaminator + https://arxiv.org/pdf/2507.16812
- vs：grill 决策=**support**(项目已对齐 SOTA，是实装缺口非方案缺口)

### F4 — 固定 0.85 cosine 阈值是 tiger（无统一阈值跨域）
0.8 Algebra 对 Sociology 漏；0.4 Algebra 误报爆。Q14 已自捕(标 0.85 非真理+review_band+calibration_receipt)，但 `embedding_model` 仍 TODO(中文口语域)。
- source：WebSearch LLM-decontaminator threshold difficulty + `docs/p1c-training-grill-decisions.md:225-230`
- vs：固定阈值=better(校准+band+judge)；阈值非核心(Q15 elephant: 语义归属才是核心)

### F5 — 必须 quarantine 的 4 类样本（可枚举写进 gate task）
①重判跨多 canonical/判不准→quarantine+人审(fail-closed) ②embedding nearest-protected 落 review_band(0.80-0.90)且 judge 判 near-hit ③撞 c6_base/must_pass/heldout protected semantic collision ④expected_tool_call_signature 撞 protected case signature。
- source：`contracts/semantic-quarantine.jsonl`(0 行) + `docs/p1c-training-grill-decisions.md:276-277`
- vs：现状(无 quarantine 产物)=better；rank16Mainline=escape_hatch

### F6 — 数据去污 best practice = 分层管线(MinHash → SemDeDup)
先 MinHash/exact 去字面 → 再 SemDeDup(embedding→kmeans→簇内 cosine→每簇留 1)去语义近邻。SemDeDup 删 50% 性能几乎不掉、OOD 反升。MAformac ~4-7k 数据**CPU 可跑**(SemHash 180万行 83s/CPU)，**不需 GPU=不引入 deferred 训练基建**。
- source：https://arxiv.org/abs/2303.09540 + NeMo Curator + WebSearch SemHash CPU
- vs：现 gate=better(补两层)；端侧约束=support(CPU 可跑)

### F7 — augment AFTER split + 同 family 归一 partition（最强铁律，比阈值硬）
Gerz&Jelali 2025：augment-before-split 把 mAP50 从 98.70% 虚高到真值 32.77%(掉 65.93pp)；OCT 同坑虚高 MCC 0.07-0.43。Q15 的 `augmentation_parent_id=split_train_only + dedupe_role=variant` 指向 seed group 正是此。
- source：https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5636100 + PMC9500039 + `docs/p1c-training-grill-decisions.md:261,278`
- vs：nearest-protected 距离判定=better+前置(结构性消除 vs 事后检测)

### F8 — 假胜利检测在 1.7B+LoRA 上特别弱（elephant）
MIA/CDD 依赖『模型记住了』，LoRA 低参数抑制 verbatim 记忆(2506.20856)→ 检测器在小模型/低 rank 失效(2603.03203)。**含义=不能靠『训完测 candidate 行为』反推泄漏，必须数据侧前置防**。
- source：https://arxiv.org/html/2506.20856 + https://arxiv.org/pdf/2603.03203 + https://arxiv.org/abs/2507.18302
- vs：『事后推泄漏』对 1.7B+LoRA worse/不可靠；强化『数据侧前置防』为唯一可靠路

### F9 — Q17『unseen parameter values』非业界标准 OOD 轴（MAformac 域特有）
业界 OOD 轴=unseen tools/queries/categories(ToolBench/ToolVQA)，无『unseen parameter values』。这是 D-domain value 编码进工具名特有，正是增广漂移最易藏处(『打开空调』变体漂到『调高温度』=value 泄漏)，须自建 value-axis 近邻 check。
- source：WebSearch tool-calling OOD + `docs/p1c-training-grill-decisions.md:352-353`
- vs：标准 OOD benchmark=须自建；Q17 决策=support(已设 near-neighbor check + lineage_overlap_allowed=false)

---

## 2. 本机实读锚点

| 锚点 | 实读值 | 含义 |
|---|---|---|
| `C5DataGate.swift:264-285` | 纯 `overlapParentSemanticID` 集合交集 | 零语义层=泄漏实装缺口 |
| `splitWhitelist` (:252) | `[train, heldout, must_pass, c6_base, dev_selection, quarantine]` | 6 类 split(Q17 已加 dev_selection)，quarantine 已在白名单 |
| `c6-bench-cases.jsonl` | 57 行，42 must_pass + 42 must_not_train | protected 语义锚集(每例带 `semantic_contract_ids`) |
| `semantic-quarantine.jsonl` | **0 行** | quarantine 有 schema 无产物(retrain-c5 才填) |
| Q13-Q15 决策 | `p1c-training-grill-decisions.md:206-291` | candidate 重判+nearest-protected+异源 judge+quarantine 全决策化 |

---

## 3. 假想验证（磊哥点名重点）

**假想：D-domain 增广『打开空调』变体漂到 heldout『调高温度』附近 → 评测变好其实泄漏=假胜利；nearest-protected 距离阈值怎么定。**

**预测=泄漏真实存在且现 code 测不到，但 MAformac D-domain 结构反而比通用 NLP 更可控**，三层推演：

**(1) 泄漏会不会发生？【会，现 gate 测不到】** D-domain 增广就是对 562 intent 种子做 paraphrase；『打开空调』口语变体(『车里好热』『开下冷气』)天然语义靠近，若 must_pass/heldout 锚是『调高温度』『制冷』类则 cosine 高。现 `:264` 只比集合交集，增广继承 seed ID→和 heldout 不同 ID→交集空→假过。Web(2311.04850)证实 13B 都被 rephrase 骗，1.7B 同理。

**(2) 假胜利怎么表现？【C6 positive_ToolCallExact 虚高 + gap 看着小，OOD value bucket 真测才暴露】** 训练集混 heldout 近邻→candidate『见过近似的』→分虚高(Gerz&Jelali 65pp)。但 LoRA 抑制记忆(2506.20856)使事后 MIA 反推靠不住→靠『评测高』是陷阱，必须 Q17 dev_selection 独立 split + OOD non-neighbor(unseen parameter values)真测才暴露。失败模式=只看 in-dist+heldout 都漂亮就签 candidate，实际 value 泛化是背的。

**(3) 阈值怎么定？【固定 0.85 不可靠，须 D-domain 分族校准 + judge 兜底，且阈值非核心】** 无统一阈值跨域。MAformac 10 族语义密度不同(空调连续 18-32℃ vs 车门离散开/关)，同 cosine 阈值在连续族误判『18 vs 19℃』为 dup、离散族漏近邻。修法=Q14 calibration_receipt 人标小批 per-族定阈值 + review_band quarantine + Q15 elephant『语义归属才是核心』(embedding 只做发现，最终由 C1 `dedupe_group_id` family + `expected_tool_call_signature` + 异源 judge 三者共判)。`embedding_model` 须先选(中文口语域 bge-zh/m3e/Qwen-embed，~4-7k 数据 CPU 可跑)。

**总判**：泄漏假胜利【真实存在且现 code 测不到】(P1 缺口)，但【不阻止 0/34 塌缩本身】——防的是二次灾难。MAformac D-domain 结构(value 编码进工具名 + C1 family 体系)比通用 NLP 更可控：family 归属结构化可查，augment-after-split + 同 family 归一 partition 一刀消除大半泄漏，embedding 只做兜底发现。失败模式=①未实装重判(继承=假安全) ②model 未选就拍阈值 ③只看评测不跑 OOD value bucket。

---

## 4. Pre-mortem 三分类

### 🐯 Tigers（明确威胁 + 验证清单）
1. **现 gate 纯 exact-ID，增广继承 seed id → 漂到 heldout 假过(Q15 :252 假安全)**。验证：grep 确认 gate 消费 candidate_parent_semantic_id(重判)非继承 seed；构造 fixture(增广 utterance 写成 heldout 近义句、parent 继承 seed)跑 gate 看 catch；核 quarantine.jsonl 有无重判落空产物。
2. **固定 0.85 + embedding_model 未选 → 跨 10 族误判率不一致**(连续族误判相邻值/离散族漏近邻)。验证：embedding_model 已落具体；阈值走 calibration_receipt per-族；review_band 全 quarantine+judge；去污前后多样性指标(防 collapse)。
3. **只看 in-dist+heldout 分就签 candidate，没跑 OOD non-neighbor value bucket**(虚高 65pp + LoRA MIA 反推靠不住)。验证：dev_selection 独立第六类 split + release gate final_only；OOD 三 bucket 真测(unseen_parameter_values + lineage_overlap=false + near_neighbor_check)；gap 作 secondary 看 in-dist vs OOD 落差。

### 🐯📄 Paper-tigers（看似威胁实际安全 + 证据）
1. **『SemDeDup 要 GPU=越界 Phase 0』** → MAformac ~4-7k 非 4.4 亿，SemHash CPU 秒级，纯数据治理落 docs/research 守 Phase 0。
2. **『embedding 有假阳假阴=不可靠不如不做』** → LLM-decontaminator 两阶段(embedding 召回+LLM judge 精判)正为解此而生；『不做』代价=泄漏假胜利无人挡，远大于双层残余误差。
3. **『A2 改 D-domain 了，0/34 已解，泄漏不是问题』** → A2 解 surface 塌缩(显性)，泄漏是正交数据层(隐性)，retrain-c5 用 D-domain 增广时照样发生且更隐蔽。混层。

### 🐘 Elephants（没人提但该提）
1. **语义归属(C1 family + tool_call_signature)才是核心，别把重心放调阈值上**(那是口径型纠结)。MAformac 比通用 NLP 有结构优势：C1 已有 canonical_semantic_id/dedupe_group_id/dedupe_role，family 归属结构化可查，不必纯靠 embedding 猜。
2. **防泄漏的 gate 本身可能成新坑(claim-vs-reality 第11坑)**：gate receipt 写『overlap=0 PASS』是 metadata 声称，若读继承 seed id 或 embedding_model 没真接、阈值 flag 直翻→假绿。gate 必须 value-in-source 核 + 异源 grader(hermes) + sign-or-block。
3. **C11/C12 配比与泄漏耦合**：template-heavy(确定性展开真实种子)泄漏远低于 cloud-NL(LLM 幻觉+collapse)；配比越偏 cloud-NL 双风险越高，nearest-protected gate 越关键。配比拍板须把『泄漏可控性』作 template-heavy 一票。
4. **quarantine.jsonl 现 0 行=机制有 schema 无产物**，Phase 0 不该有产物，但 propose gate task 必须明确 quarantine 写入触发条件 + 人审回路(reassign_uncertain fail-closed)，否则 retrain 时无人填=泄漏样本静默进 train。

---

## 5. must_answer 5 答

1. **prevents_0_34**：**no** — 不能阻止 candidate 全塌缩(那是 surface+masking，A2 已修)。防的是『下次 retrain 看着过了其实污染=假胜利』的二次隐性灾难。诚实标 **P1 不伪装 P0**。
2. **vs_rank16mainline**：**escape_hatch** — 完全不碰配方(rank16/scale20/LR1e-4/adamw/epochs3)，纯数据侧 gate。
3. **requires_a2_surface_change**：**no** — 不改 A2 D-domain surface，反而依赖 A2 成果(D-domain value 编码 + C1 family 体系)做语义归属判定。两者正交。
4. **introduces_deferred**：**yes(标记不越界)** — embedding 实装/quarantine 产物/阈值校准/OOD 真测属 retrain-c5+rebuild-c6(DEFERRED)。本调研纯搜证+方法论梳理，产 propose gate 弹药，落 docs/research 不碰 runtime contracts。下一步主线=写 OpenSpec gate task(非 retrain)，符合 Phase 0 acceptance。
5. **priority_self**：**P1**

---

## 6. 给 propose 的 gate task 弹药（pre-propose 收敛）

写进 retrain-c5 OpenSpec change 的 gate task：
1. **augment-after-split + 同 family 归一 partition**(最强一刀，结构性)：`augmentation_parent_id=split_train_only` + `dedupe_role=variant` 指向 seed group。
2. **gate 消费 candidate_parent_semantic_id(重判)非继承 seed**(修 `C5DataGate.swift:264` 假安全)。
3. **embedding nearest-protected 双层**(embedding top-k 召回 + Q14 异源 judge 精判)，embedding_model 先选(中文口语域)，阈值走 calibration_receipt per-族，不写死 0.85。
4. **分层去污**(MinHash exact → SemDeDup 语义，CPU 跑)。
5. **4 类必 quarantine**(重判落空/review_band near-hit/protected collision/signature 撞)+ fail-closed 人审回路。
6. **OOD value bucket 真测**(unseen_parameter_values + lineage_overlap=false + near_neighbor_check)，不靠评测高反推无泄漏(LoRA MIA 不可靠)。
7. **gate 自身防假绿**(value-in-source 核 + 异源 grader + sign-or-block)，别让防泄漏门成第11坑。

---

## 7. source 清单（版本/数字 cutoff 敏感，可复核）

- 本机实读：`Core/Bench/C5DataGate.swift:264-285` / `contracts/c6-bench-cases.jsonl`(57 行 42+42) / `contracts/semantic-quarantine.jsonl`(0 行) / `docs/p1c-training-grill-decisions.md` Q13-Q15(:206-291)
- WebSearch 2026-06-24：
  - https://arxiv.org/abs/2311.04850 (Rephrased Samples / LLM-decontaminator，核实真实)
  - https://github.com/lm-sys/llm-decontaminator
  - https://arxiv.org/abs/2303.09540 (SemDeDup)
  - https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5636100 (Gerz&Jelali 2025 augment-after-split)
  - https://arxiv.org/abs/2507.18302 (LoRA-Leak) / https://arxiv.org/html/2506.20856 / https://arxiv.org/pdf/2603.03203
  - https://arxiv.org/pdf/2507.16812 (MegaScience decontaminator 配方)
  - https://docs.nvidia.com/nemo/curator semdedup / SemHash CPU
  - https://gorilla.cs.berkeley.edu/blogs/8_berkeley_function_calling_leaderboard.html (BFCL held-out 防污染)

> **防编造声明**：external_claims 段列所有需主线程抽样核的精确数字/arxiv ID(2507.18302/2506.20856/2603.03203/2507.16812 系 WebSearch 二手转引；Gerz&Jelali 65.93pp/ELI5 81%/SemHash 83s 精确数字二手)。本地 file:line 数字均本机 cat/python/grep 实读可仓内复核。arxiv 2311.04850 + 2303.09540 已 WebSearch 核实真实存在。
# L07 — D-domain 数据合成配方 + distractor + 配比（一手调研档）

> 维度：D-domain 数据合成配方 + distractor + 配比（四/五类怎么生成 + 配比 + 双腿）。配比是 hypothesis（C11-12 待 spike），不拍死生产值。
> as-of 2026-06-24 · Phase 0 边界：pre-propose decision-pack，纯搜证 + 假想验证，绝不执行训练/数据生成/评测。
> 一手锚：home-llm `generate_data.py:698-863`（本机实读）/ 真实座舱 col S（teardown 一手）/ grill C09-C12（p1c + paradigm-amend）/ post-roadmap GAP1/2/3。

## §0 一段读完

MAformac 的 C5 数据配方 = **home-llm 5 类生成器映 4 类 + 配比 factors + distractor-in-prompt + 双层验证 + 双腿生成 + 加权采样**。三处一手 + 7 篇 FC 合成论文交叉验证后锁死三件事：

1. **配比有量化外部锚，不拍脑袋**：Hammer 10%（ablation）/ Magnet 15-17%（实测 sweet spot）/ MOSAIC 负:正>1:1 收益递减。→ post-roadmap 审计建议的 `positive20/unsup8/safety4/followup2`（≈24% 负样本）**偏高出 sweet spot**，应收到 negatives 15-20%。
2. **负类不可砍是 0/34 同根铁证**：ToolACE ablation 砍非工具样本→irrelevance 检测崩 **6.99%**；APIGen ablation 加回被过滤脏数据→**退化小模型**（验证 > 数量）。
3. **加权向 demo 范式非笛卡尔均匀**：LIMA/LIMIT「数据须对齐评测范式」+ EXP（734 行最大 value-form=demo 灵魂）过采 + 10 族 demo-critical 倾斜。

---

## §1 home-llm 5 类配方 + 配比 factors（一手实读 generate_data.py）

`generate_sft_file`（`generate_data.py:698-771`）每 persona × 每 pile × factor → 调生成器 → `format_example_sharegpt` → jsonl。`run_factor_times`（:720）factor≥1 生 int(factor) 份，<1 概率生。

### 5 类生成器 → MAformac 4 类映射

| home-llm 生成器 | file:line | train_on_turn | MAformac 4 类映射 |
|---|---|---|---|
| `generate_static_example` | :32 | True | positive（具体指令） |
| `generate_templated_example` | :181 | True | positive（参数泛化主力 + 多意图） |
| `generate_status_request` | :370 | True | **走端 renderer 方案P，不进训练**（demo 砍） |
| `generate_refusal_example`（双 reason_type） | :563 / :569 | True | `not_available`→**unsupported** / `already_state`→**safety**（不完全等价，见 GAP） |
| `generate_tool_failure_example`（3-turn） | :468 / 失败步 :542 train_on_turn=False | **False**（失败步） | **failure（当前 4 类无，GAP1）** |

### 配比 factors 四档（一手 :853-859，非猜测）

| 档 | static | templated | status | refusal | failure |
|---|---|---|---|---|---|
| small | 1 | **10** | 8 | 3 | 1 |
| medium | 5 | **15** | 12 | 5 | 1 |
| large | 5 | **20** | 15 | 6 | 1 |
| xl | 7 | **25** | 18 | 8 | 2 |
| **test** | 0.25 | 1 | 2 | 1 | 1 |

**铁律实证**：templated（参数泛化）10-25x ≫ status 8-18x ≫ refusal 3-8x ≫ failure 1-2x。**泛化类最重**，failure 最轻但 xl 档仍 factor=2 **绝不为 0**；test 集 static=0.25 **倒置**（训练堆泛化、测试反转防过拟）。

### 模板腿算法（确定性参数泛化）

`:80-140, :276-353`：模板含 `<brightness>/<color>/<temp_f>/<temp_c>/<duration>/<todo>` 占位 → `generate_random_parameter` 填随机值 → **同步替换 question + answer + tool_args 三处**。distractor：`random_device_list`（`devices.py:250-308`）目标设备插进随机设备里，`SequenceMatcher ratio<0.4` **相似度过滤**防混淆 near-duplicate。

> → MAformac 模板腿 = A2 `dDomainToolCallArguments`（slotAssignments 值随机化），arg key 同源 enforce = TRN2 防 0/34。

---

## §2 FC 数据合成 pipeline（xLAM/APIGen/Hammer/ToolACE/When2Call/Magnet）

### 2.1 APIGen（2406.18518，xLAM 630★ 活跃 2026-06-02）

三级层级验证：**format 检查器**（丢字段缺失/幻觉函数/越界参数）→ **execution 引擎实跑** → **semantic LLM 检查器**（对齐 query↔call↔result）。dataset = xlam-function-calling-60k（3673 API/21 类）。人评 600 样本 >95% 正确。1B 模型超 GPT-3.5-Turbo/Claude-3-Haiku。

🔴 **关键 ablation**：把被 **stage2/stage3 过滤掉的数据加回**训练集 → **性能退化，尤其小模型** → **验证（非数据量）是有效性关键**。= MAformac 1.7B 端侧『脏数据比少数据更伤』的外部铁证，支持 Q14 dual_layer_validator stop_on_rule_fail。

### 2.2 ToolACE（2409.00920，ICLR 2025）

TSS（speciation-adaptation-evolution 造 26507 API）+ SDG（LLM 当 complexity 评估器，ZPD 略超能力学最快）+ **四类对话**（single/parallel/dependent/non-tool-use，后者分『无合适工具』+『信息不足』）+ **双层验证 DLV**（规则层 4 维：API 清晰度/可执行/对话正确/样本一致 + 模型层逐样本多次生成取一致）。8B+LoRA 达 BFCL SOTA。

🔴 **ablation 铁证**：砍非工具（负）类 → irrelevance 检测**崩到 6.99%**。这是 **0/34 同根机制的精确量化**——零/欠负样本 = irrelevance 检测崩 = 误吸/塌缩。MAformac unsupported+safety 不可砍最强证据。

### 2.3 Hammer（2410.04587，119★ pushedAt 2025-06-13）

irrelevance-augmented dataset（**7500 条**，正确函数从候选剔除 + label 置空）+ **function masking**（函数名/参数名 → 随机字符串 + 默认值随机进描述 + label 同步）。on-device 小模型（0.5B-7B）。

🔴 **ablation**：irrelevance 数据最优比例 **≈10%**（Figure 6）；**FC accuracy 与 irrelevance detection 反比关系**（一升一降，须配比平衡）。

> → MAformac grill Q3 `distractor_only`（`p1c-training-grill-decisions.md:22`）是 Hammer masking 的**正确裁剪**：MAformac 有**语义工具名**，只随机化 distractor 不随机化目标名（Hammer 名字无语义才全随机）。

### 2.4 When2Call（2504.18851，NAACL 2025，64★）

**4 行为 MCQ**（生成工具调用 / 追问补信息 / 承认无法回答 / 直接回答=幻觉）= **MAformac positive/followup/unsupported/safety 1:1 映**。**同域 distractor**：target『无法回答』工具与 query **同语义域**（学生记录 vs 成绩需细判，比 BFCL-Irrelevance 随机无关难）；follow-up 工具仅差**一个缺失必填参**（`held_out_param` 字段）。train_sft 15000。后续 RL 用 **distractor injection 3-8 无关工具**强制工具辨别。

> → `held_out_param` 机制可直接做 MAformac **followup 构造**（移走必填参→触发追问）。同域 distractor 对齐 demo 现场真实混淆（10 族内 near-miss），grill C1 已拍『When2Call distractor 进 prompt 教辨别非独立 refusal』。

### 2.5 Magnet（2503.07826）— 配比 sweet spot 实测

固定 20k 单轮 + 8k 多轮，扫描 irrelevance 比例 **6.7%/9.6%/12.5%/15.2%/17.5%/20%/26.3%**（2k-10k 样本）→ **最优 ≈15-17%**（>20% 牺牲多轮成功率，<15% 损 irrelevance 检测）。MOSAIC：负:正 >1:1 后加负样本收益递减，**瓶颈是监督粒度非数量**；over-conservatism 是 **calibration 假象非能力缺口**。

### 2.6 APIGen-MT（2504.03601）— 多轮 followup（越界提醒）

两阶段：Phase I blueprint（LLM 评审委员会 + format/execution/LLM-review 分层验证 + 失败反馈回环）→ Phase II 轨迹模拟（LLM 扮 human+agent，验逐轮 + 全局与 blueprint 终态一致）。

> ⚠️ **过度工程化提醒**：MAformac demo **砍长时只保 3 轮短时 DialogueState**，followup 用 home-llm 风格『上文 intent 继承 + 本轮 slot 改写』+ When2Call held_out_param 即可，**不必上 APIGen-MT 全 agentic 多轮模拟**。

### 2.7 LIMA/LIMIT + Microsoft DS（质量 > 数量 + 对齐评测范式）

LIMA（1000 精筛对齐 65B 达 GPT-4 可比）；LIMIT 复现纠正：**微调数据必须对齐你关心的评测范式**。Microsoft DS：SLM function calling **高质量 > 大量噪声**，越复杂函数越明显。

> → 支持 MAformac 加权向 demo 评测范式（10 族 EXP）而非 562 笛卡尔积均匀。『5000 精筛干翻 50K』内部 slide 的同行评审等价证据。

---

## §3 三个 GAP（post-roadmap 审计 + 本路精炼）

### GAP1 — failure 错误恢复类（home-llm 有 MAformac 4 类无）

- home-llm failure 是小模型可靠性关键（学恢复不学产生错误，失败步 train_on_turn=False）。
- **倾向砍 + 显式记**（demo 约定收窄，现场不演错误恢复）。**ToolACE 6.99% 是砍负类后果，failure 是 positive 子类不同性质**，砍 failure 不触发 6.99% 崩溃。
- **若端侧 mlx-swift 三层防御解析偶发失败需 recovery**，留 factor≤2 最小种子（参考 home-llm xl 档）。

### GAP2 — 配比 factors（核心精炼）

| 来源 | 最优负样本比例 |
|---|---|
| Hammer ablation | ≈10% |
| Magnet 实测扫描 | **15-17%** |
| MOSAIC | >1:1 收益递减，粒度 > 数量 |
| post-roadmap 审计建议 | positive20/unsup8/safety4/followup2 ≈**24%（偏高）** |

🔴 **精炼建议**：负样本总和收到 **15-20%**（如 positive20/unsup6/safety3/followup2 ≈20%），**配比 spike 复刻 Magnet 方法**（扫 6.7%→24%，dev set 含 demo positive 200 + unsupported 200，找 over-refusal 拐点），不直接拍 24% 进生产。over-refusal 是 calibration 非能力，靠配比+阈值校准非堆负样本。

### GAP3 — 数据合成双腿（模板确定性 + 云自然中文）

- **腿 A（确定性 70%）**：A2 `dDomainToolCallArguments` 模板法，保参数泛化全覆盖 + arg key 同源 enforce（TRN2 防 0/34）。
- **腿 B（自然度 30%）**：云多源 generator 自然中文 paraphrase + 逐样本异源 judge（generator≠judge）。
- **APIGen ablation 铁证**：纯云不可控 + judge 会漏 = 高质量脏数据风险（Q14 elephant 已 catch）；加回脏数据退化小模型。**真实种子 non-shrinking 锚**防 model collapse（Nature 2024）。

---

## §4 一手锚：真实座舱 col S + MAformac value.type 分布

### 真实座舱数据分层 ground truth（teardown col S）

| 数据类型 | 量级 | 占比 |
|---|---|---|
| 标准说法 | ~7800 | ~75% |
| 模糊说法 | ~2580 | ~24% |
| 自由说法 | ~226 | ~2% |
| 模糊意图 | — | — |

> vendor 自承『模糊/自由说数据只做参考不保证效果』。可作 MAformac **positive 内部细分**（标准/模糊/自由）配比锚，比 home-llm（HA 域）更贴车控。per-tool col P/Q/R 三档泛化开关。

### MAformac 契约 value.type 分布（本机实算 jsonl 3990 行）

| value.type | MASTER 口径 | 本机实算 | 语义 |
|---|---|---|---|
| **EXP** | **734** | 800 | 逆规整（感受词→offset_enum，『有点冷』→increase_by_exp）= **demo 灵魂、最难** |
| SPOT | 459 | 526 | 抠槽（『调到26度』→offset=26） |
| PERCENT | 373 | 373 | 百分比（『车窗50%』） |

> EXP 是最大 value-form（~36% value-bearing），加权采样应向 EXP + demo-critical 10 族倾斜，**非 562 × 40 direction 笛卡尔积均匀**。fuzzy=1429 / free=163。

---

## §5 假想验证（MAformac 1.7B+LoRA+D-domain 562+端侧+mlx 真实场景）

**预测 1（哪类压倒/坍缩）**：worse if 照搬 home-llm/审计 24% 负样本 → 超 sweet spot → **过度拒识**（demo 现场 10 族内合法话误判 unsupported 拒识，反向 0/34 同样炸场）。修正：收到 15-20%，over-refusal 是 calibration 非能力。

**预测 2（failure 砍 vs 纳入）**：倾向砍（不触发 ToolACE 6.99%，那是砍负类后果）+ demo 约定收窄安全；端侧偶发解析失败留 factor≤2 最小种子。

**预测 3（562 加权 vs 笛卡尔）**：better 加权（向 10 族 demo-critical + EXP 过采 + per_seed≤8 + col S 分布锚）worse 笛卡尔（长尾稀释 demo 信号，1.7B 学不动，C6 golden 100% 硬门挂，LIMA/LIMIT）。

**预测 4（双腿 vs 纯云）**：better 双腿（模板腿保覆盖 + arg 同源 + 云腿保自然度 + 异源 judge）worse 纯云（model collapse + judge self-preference 漏脏数据 = 高质量脏数据，C6 假绿真塌，APIGen ablation）。

---

## §6 pre-mortem 三分类

**tiger**（验证清单见 schema）：① 配比 24% 过度拒识 → spike 扫 6.7%-24% 找拐点；② 纯云 model collapse + 脏数据 → 双腿 enforce + stop_on_rule_fail + 异源 judge + non-shrinking 锚；③ 笛卡尔均匀稀释 demo 信号 → 加权 + per_seed≤8 + col O 优先级锚。

**paper-tiger**（给证据）：① 『failure 必留否则崩』→ 6.99% 是砍负类非砍 failure；② 『2045/562 工具太多跑不动』→ 数据合成 dev-time 云端无端侧约束；③ 『必须 APIGen-MT 全模拟做 followup』→ 3 轮短时 + held_out_param 即可，全模拟过度工程化。

**elephant**（没人提该提）：① **EXP 口语种子的 redline enforce**（云生成『有点冷/太闷』非复制原文 bug 话术）；② **distractor 同域 vs 随机无关没显式拍**（When2Call 实证同域更难更贴现场，须放 10 族内 near-miss 非只族外随机）；③ **配比 spike 必绑训练栈 spike（P0-1 未拍）**（玩具栈配比对、生产栈 OOM 失配）；④ **EXP 过采 vs unsupported 多样性的 budget 张力**（两轴联合 sweet spot 非单轴最优）。

---

## §7 must_answer 5 答

1. **prevents_0_34**：**yes** — 四类完整 + 配比不压倒 + 双层验证 + 模板腿 arg 同源 = 提前阻止塌缩；但须配合 A2 surface + masking + mid-gate 才完整。
2. **vs_rank16mainline**：**support** — 数据配方与超参正交，强化 rank16Mainline 零碰，数据质量 > 超参调优方向。
3. **requires_a2_surface_change**：**no** — 消费 A2 产物（dDomainToolCallArguments/具名工具/契约 SSOT），不反向改 surface。
4. **introduces_deferred**：**yes（已声明）** — 属 retrain-c5 DEFERRED，本调研纯搜证不执行，产出弹药写 OpenSpec change，配比 hypothesis 待 spike 不拍死。
5. **priority_self**：**P0** — ToolACE 6.99% + APIGen 退化小模型 = 0/34 同根，配方层是直接解药之一。

---

## §8 物理落点（写 retrain-c5 OpenSpec change，不碰 runtime contracts/）

```
openspec/changes/retrain-c5-lora-d-domain/
├── proposal.md       # 「why 4 类 not 5（failure 砍 + status 走 renderer 的 delta）」段
├── data_recipe.yaml  # category_factors（负样本 15-20%，非 24%）+ 模板70/云30 双腿
│                     # + distractor 构造（同域 near-miss + held_out_param followup）
│                     # + 加权采样（EXP 过采 + 10 族 + col S 分布锚 + per_seed≤8）
│                     # + redline_prompt_input=semantic_protocol_only + redaction pass
├── design.md         # 双层验证（规则层 stop_on_rule_fail + 逐样本异源 judge）
└── tasks.md          # 配比 spike（绑 P0-1 训练栈 spike，复刻 Magnet 扫描法）
```

---

**END** — L07 一手档，10 finding + 7 论文 + 3 clone 判定 + 假想验证 4 预测 + pre-mortem 三分类。配比 hypothesis 待 spike，不拍死。
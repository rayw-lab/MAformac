# L12 — SFT vs DPO:拒识/安全/澄清是否适合 SFT(磊哥点名重点)

> 维度:SFT vs DPO 在【拒识/安全/澄清】训练的方法选型。P1。
> 一手锚:图187-188(任务-方法匹配 + 拒答该 DPO?)/ grill C09/C10(already_state/state-noop)/ 0/34(7 个 demo-critical base/lora 都 0/7 全是拒识类)。
> 蓝本:home-llm（acon96/home-llm，**1364★ / pushedAt 2026-06-11 活跃 / 13 天前**，>1000 不降级吸收，本机 clone 实读）。
> 本机 scout：mlx-lm **0.31.1** 已装 / 内存 **32GB** / 无 N 卡。严守 Phase 0 边界：纯搜证 + 假想验证 + 蓝本拆解，**绝不执行训练/真实评测/数据生成/voice/受限解码**。

---

## 0. 核心结论（summary）

**MAformac 的拒识/安全/澄清属"确定性、上下文可判"refusal**（device 不在 exposed 列表 / already_state 已在目标态 / 行驶安全约束 / ASR 听不清）—— **≠ 图187-188 与近期 abstention 文献谈的"知识不确定 abstention"或"安全关键词 over-refusal"**。后者（开放域对抗 jailbreak、安全关键词假拒、参数知识缺口）才是 DPO/RL 占优的场景；前者 **SFT 正例足够**，且 home-llm（纯 SFT / 124 拒识例 / 无 DPO）已实证可跑在 270m-3B 小模型。

**图187"想做安全对齐/拒答该上 DPO"对 MAformac 只【部分适用】**：MAformac 的"安全"是端确定性规则可判的座舱约束（行驶中开门、device 不存在），不是开放域对抗 jailbreak / 安全关键词歧义，SFT 正例 + IrrelAcc 死门已能覆盖。

**0/34 的 7 个 demo-critical 全 0/7 真因不是"SFT 训不动拒识"**，而是：① generic frame 判定面爆炸（A2 D-domain surface 已修一半）② **训练集 0 条拒识/澄清/安全自然中文样本（根本没训这 4 类）** ③ candidate 全塌缩 toolCalls=[]。这是【**数据缺失 + surface 错**】非【方法选错】，补 4 类样本（positive / unsupported_refusal / safety_refusal / clarify）是直接解。

**文献真正的硬警示** = 【SFT 易让小模型 over-call、压垮 IrrelAcc】（post-SFT irrelevance 从 base 80%→21-49%），这正是 0/34 toolCalls=[] 的镜像失败模式，必须 held-out + IrrelAcc≥base 0.789 守门。**DPO 不是 demo 阶段必需**，是 Phase 后续"减 over-refusal / refine 边界"的可选增强（home-llm 自己 TODO 里也只把 DPO 当 future"提质量"未实装）。

---

## 1. 逐条 finding（带 source）

### F1 — abstention 文献共识:纯 SFT 对【知识不确定 abstention】不够,但那是另一类场景
近期 survey + Abstain-R1 + "When Silence Is Golden" 一致:SFT 单独对**知识不确定 abstention**(模型该说"我不知道"时)易 over-conservative + 诱发 overconfidence + OOD 脆化,主流走 **SFT cold-start + RL/DPO refine**。
- source:[Know Your Limits 综述 TACL](https://direct.mit.edu/tacl/article/doi/10.1162/tacl_a_00754) + [Abstain-R1 arxiv 2604.17073](https://arxiv.org/html/2604.17073) + [When Silence Is Golden 2602.04755](https://arxiv.org/html/2602.04755v2)（RL 比纯 SFT +20% TPR on unanswerable），2026-06-24。
- **关键限定**:这些场景 = **知识 abstention / 对抗 jailbreak**，MAformac 拒识 = **上下文确定可判**，属另一类。vs home-llm:文献 oppose 纯 SFT 但场景不同,home-llm 拒识=确定性 device-state,纯 SFT work，better 适配 MAformac。

### F2 — Abstain-R1 精确数(知识 abstention 场景)
SFT-only **51.9% U-Ref / 37.0% U-Clar** → SFT+RL **68.1% / 55.1%**（澄清 **+18.2pp**）。w/o SFT 仅 8.5% U-Clar（证 **SFT cold-start 必需**、RL 是 refine 不是替代）。但其 abstention 目标 = 缺数学变量 / 假前提 / 矛盾（**语义欠定需推理**）。
- source:[Abstain-R1 Table 2/4](https://arxiv.org/html/2604.17073)，WebFetch 核 2026-06-24。
- vs rank16Mainline:oppose——若 MAformac 拒识与该论文同属语义欠定,纯 SFT 留 ~18pp 澄清缺口;但 MAformac 澄清主要是 **ASR 听不清(确定性触发)**，更接近规则可判,gap 预期更小,unknown(待 spike 实测)。

### F3 — AWS 官方 recipe:Qwen3-1.7B(同款基座)SFT+DPO
[AWS SageMaker blog](https://aws.amazon.com/blogs/machine-learning/improve-your-agents-tool-calling-accuracy-with-sft-and-dpo-on-amazon-sagemaker-ai/) 用 Qwen3-1.7B 做 tool-calling:**SFT 教'tool-specific 语言/约束/call-clarify-refuse 各行为样例'，DPO refine'在这些行为间决策'**。明确点出 *"SFT 能教各行为样例但难泛化【行为间决策】，DPO/RL 泛化更好"*。**30% 总增益，9% 超 Llama-3.2-3B（近2倍参数）**。
- 逐阶段数（单 WebFetch）:base 41.57% → SFT 60.43% → SFT+DPO 71.06%（**三位小数进 external_claims 待主线程核**；总增益 30% + 9% 超 Llama 已双源确认）。
- vs rank16Mainline:escape_hatch——同款 1.7B 官方实证 SFT+DPO 优于纯 SFT，但 30% 是**总 tool-calling 准确率(含 arg 准确)非专指拒识**;DPO 增益是 demo 后续可选增强，非阻 0/34 必需。

### F4 — When2Call(4 决策类)真实数:RPO 主要压 over-call 不是大幅提拒识 F1
[NVIDIA/When2Call](https://github.com/NVIDIA/When2Call)（4 决策类:call/clarify/refuse/answer-directly）README 真实表：
| | Dataset-SFT F1 | Dataset-RPO F1 | tool-halluc SFT→RPO |
|---|---|---|---|
| MNM-4B | 48.1 | 51.0 | 4.3%→1.9% |
| MNM-8B | 49.4 | 52.4 | 7.0%→**1.2%** |

**RPO 仅 +3 F1，但把 tool-hallucination 从 SFT 7.0% 压到 1.2%** —— **RPO 主要价值 = 压 over-call/幻觉，不是大幅提拒识 F1**。Dataset-SFT 已吃掉大头（base 31.9→49.4）。
- source:[README 表（WebFetch 实读）](https://github.com/NVIDIA/When2Call/blob/main/README.md) + [arxiv 2504.18851](https://arxiv.org/pdf/2504.18851)，2026-06-24。
- ⚠️ 早期 WebFetch 报的 82.3%/87.5%/91.2% + 7B/13B/70B = **WebFetch 幻觉，已弃**（真实=MNM 4B/8B）。
- vs rank16Mainline:**support**——SFT 已捕获主增益，RPO 边际（+3F1）主压幻觉/over-call。

### F5 — SFT 的真实硬警示:让小模型 over-call、压垮 irrelevance(0/34 的镜像)
重度 agentic SFT 后 irrelevance 从 base **80%→21.67%(100 traces)/49.17%(18k traces)** —— 即"该拒不拒"。这正是 MAformac 0/34 candidate 全塌缩 toolCalls=[] 的**镜像失败模式（过/欠两极）**。
- source:[Awakening Sleeping Agent 2604.08388](https://arxiv.org/pdf/2604.08388) + [futureagi tool-calling eval 2026](https://futureagi.com/blog/evaluating-tool-calling-agents-2026/)（irrelevance bucket 最常被漏），2026-06-24。
- vs 0/34:**better 解释力**——修法=held-out + IrrelAcc≥base 0.789 死门（C6 已有），**非换 DPO**。

### F6 — home-llm 拒识 = 纯 SFT 正例(本机实读,最强同型背书)
`generate_refusal_example`（`generate_data.py:563-599`）把拒绝话术当 assistant target：`assistant_turns=[create_assistant_turn(response_text,[])]` **无 toolcall**；**124 拒识例**（`data/piles/english/pile_of_refusals.csv`）两 reason_type（`not_available` 族外拒 / `already_state` 状态拒）。**DPO 仅在 `TODO.md:14 "[ ] figure out DPO to improve response quality"`（未实装 future idea）**，`experiment-notes-phi.md:342` 仅引一个通用 DPO 数据集。
- source:本机 clone 实读 `home-llm/data/generate_data.py:563-599` + `pile_of_refusals.csv`(124行) + `TODO.md:14`，2026-06-24；`gh repo view` 核 1364★/pushedAt 2026-06-11。
- vs DPO 路线:home-llm 纯 SFT 在 270m-3B work = **oppose'拒识必须 DPO'**；直接 support MAformac 先纯 SFT 正例。

### F7 — already_state(C10/state-noop)在 home-llm 是 refusal 的 reason_type
`generate_data.py:574-582`:若 device 已在 `desired_state`，注入设备态进 `device_list`，target=自然语言播报"已经是X态了"。MAformac post-roadmap audit 标:**already_state ≠ safety_refusal(ASIL)，当前 4 类把 already_state silent drop = GAP**，需显式归类（归 unsupported 兜底 or 独立 state-noop 类）。
- source:home-llm `generate_data.py:574-582` + `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:99,118-119`，本机实读。
- vs MAformac 现 4 类:home-llm **better 覆盖** already_state；MAformac 需补此类（**SFT 正例即可，确定性可判**）。

### F8 — over-refusal/exaggerated-safety 文献的 DPO 优势【不迁移】到 MAformac = paper-tiger
XSTest/FalseReject/OR-Bench 的 DPO 优势场景 = **安全关键词诱发的假拒**（如'kill a process'被误拒），safety↔over-refusal 结构性正相关 **Spearman 0.89**。MAformac 安全 = 座舱确定性规则（行驶中开门），**非开放域关键词歧义**，该文献不适用。FalseReject 自己也证 **SFT 即可减 over-refusal**。
- source:[FalseReject 2505.08054](https://arxiv.org/html/2505.08054v2) + XSTest(Röttger 2024) + OR-Bench(Cui 2025, 0.89 相关)，2026-06-24。
- vs MAformac:**paper-tiger**。

---

## 2. clone 发现(home-llm,本机实读)
| file:line | 关键算法 | adopt/adapt/drop |
|---|---|---|
| `generate_data.py:563-599` `generate_refusal_example` | 拒识 = 纯 SFT 正例，拒绝话术当 assistant target，**无 toolcall** | **adopt**:MAformac unsupported_refusal/safety_refusal 同此模式 |
| `generate_data.py:574-582` already_state 分支 | 注入设备态进 device_list，target=状态播报"已经是X态" | **adopt**:补 MAformac 当前 silent-drop 的 already_state/state-noop 类 |
| `pile_of_refusals.csv`(124行) | seed CSV(reason_type/service/device/phrase/response) | **adapt**:MAformac 换 D-domain 具名工具 + 自然中文 |
| `TODO.md:14` "figure out DPO" | DPO 仅 future idea **未实装** | **借证据**:1364★ 蓝本拒识纯 SFT 就 work，DPO 非必需 |
| `train/evaluate.py:160-166` | 拒识=空匹配 correct，**该拒不拒(extra-response)=fail** | **adopt**:= IrrelAcc 死门思想，防 over-call |

---

## 3. paper 发现
| title | id | method essence | applicable | hypothesis_test |
|---|---|---|---|---|
| Abstain-R1 | 2604.17073 | SFT cold-start + verifiable RL 做 abstention+post-refusal clarify | **unknown**(场景=知识欠定,非确定性 refusal) | 若 MAformac 拒识混语义欠定→纯 SFT 留 ~18pp 缺口 |
| When2Call | 2504.18851/NAACL2025 | 4 决策类 + RPO 偏好优化;RPO 主压 tool-halluc(7%→1.2%) | **yes** | Dataset-SFT 吃大头,RPO 边际+压 over-call |
| Awakening Sleeping Agent | 2604.08388 | 重 SFT 致 irrelevance 崩(80%→21-49%) | **yes** | =0/34 over-call 镜像,IrrelAcc 死门必需 |
| FalseReject | 2505.08054 | SFT 即可减 over-refusal(确定性 context) | **yes** | 证 MAformac 确定性场景 SFT 够 |
| AWS Qwen3-1.7B recipe | (blog) | SFT 教行为样例 + DPO refine 行为间决策,30%增益 | **yes** | DPO 是后续可选增强非必需 |

---

## 4. 假想验证（1.7B+LoRA+D-domain+端侧8GB+mlx）

**假想:7 个 demo-critical 拒识 case 用 SFT 正例 vs DPO 偏好对，哪个训得动?**

7 case 分家（grill θ 已定）:SAFE-002(行驶中开门，θd-2 安全拒) / ASR-001/002(澄清，θd-3) / MP-024-026(开门→错调 window，θd-4 工具映射)——全是**确定性上下文可判** refusal。

**预测**:
- **SFT 正例 better 训得动**：监督信号是'给定 D-domain 工具集 + 上下文(行驶态/ASR 置信低/工具不匹配)，正确输出=拒识/澄清话术(无 toolcall)或正确具名工具'。home-llm 同型纯 SFT 在更小模型已实证 124 例可训。**前提=真有这 4 类自然中文样本**（0/34 真因是训练集 0 条，不是 SFT 训不动）。
- **DPO 偏好对在此场景 worse**：① 偏好对需'chosen=拒识/正确具名工具，rejected=错调 window/直接执行'，但 rejected 要么来自 base 自采（**1.7B base 全塌缩，采不出有意义负例**）要么人工造（成本高+要异源 judge 防造错）② When2Call 实证 RPO 仅 +3F1，主要压 over-call 不是提拒识 ③ DPO 的'相对 margin'对【绝对要输出某话术】的确定性任务非最优（Abstain-R1 指 DPO 压负例 > 强化正策略）。

**依据**:home-llm 124 拒识纯 SFT work（最直接同型）+ AWS Qwen3-1.7B SFT 先吃 19% DPO 才补 10.5% + When2Call Dataset-SFT 吃大头。

**失败模式（关键）**:SFT 正例的真实风险不是'训不动'，是【**over-fit 致 over-call，IrrelAcc 崩**】——post-SFT irrelevance 可 80%→21-49%。训了拒识正例可能把'该调工具'的也拒、或把'该拒'的硬塞 toolcall（=0/34 的反面）。必守:① IrrelAcc≥base 0.789 死门 ② held-out 拒识 case 防死记 ③ **SAFE-002 监督=拒识+安全话术，绝不监督'正确调 set_door'**（否则训出'行驶中正确开门'危险样本，grill θd-2 已 catch）。

**steelman 正反**:
- 守 SFT:MAformac 拒识确定性可判 + demo 轻治理 + 现场只说 10 族收窄输入 → SFT 正例 + IrrelAcc 门足够，DPO 是 demo 阶段过度工程化。
- 反方(图187/Abstain-R1):若混入语义欠定/需推理判断的拒识，纯 SFT 留 ~18pp 澄清缺口、易 over-conservative。
- 裁决:demo 阶段 **SFT 正例 + 4 类数据 + IrrelAcc 死门为主路**（unknown→spike 实测验）；**DPO 列为 Phase 后续可选增强，不前置、不阻 0/34 修复**。

---

## 5. premortem 三分类
**tiger**:① SFT 训拒识致 over-call/IrrelAcc 崩(80%→21-49%，0/34 镜像)→验:IrrelAcc≥0.789死门+held-out+过/欠两极查 ② SAFE-002 监督若设'正确调 set_door'→训出危险样本→验:核 target=拒识非 toolcall ③ already_state silent drop 无监督→验:补 schema 覆盖+target=状态播报。
**paper-tiger**:① '图187 该 DPO 所以 MAformac 拒识必 DPO'→证:MAformac 安全=确定性座舱规则非关键词歧义，FalseReject 证 SFT 即可，home-llm 纯 SFT work ② 'Abstain-R1 37% U-Clar 所以 MAformac 澄清纯 SFT 差 18pp'→证:Abstain-R1 是语义欠定，MAformac 澄清=ASR 确定性触发，gap 远小。
**elephant**:① 7 case 全 0/7 真因是【训练集 0 条这 4 类样本】非'SFT 训不动'，方法之争前先确认数据是否存在 ② DPO 需【负例来源】隐藏前置（base 塌缩采不出）③ home-llm 拒识 work 强依赖工具子集化+distractor+D-domain surface，非单看方法 ④ DPO 对端侧 8GB+mlx 的 policy+reference 双权重约束，mlx-lm DPO 支持成熟度未实测。

---

## 6. must_answer 5 答
1. **prevents_0_34**:yes(部分)——核心贡献=正确归因（0/34 真因=数据缺失+surface 错，非方法选错），阻止'换 DPO'弯路 + 提供 SFT 正例+IrrelAcc 死门+held-out 守门。本身不产 code 是 propose 弹药，故 **P1**。
2. **vs_rank16mainline**:**support**——SFT 已捕获主增益(When2Call/AWS 实证)，纯 SFT LoRA 配方守得住。
3. **requires_a2_surface_change**:**no**——确认 A2 D-domain surface 是拒识 SFT 能 work 的前提，不要求改 A2。
4. **introduces_deferred**:yes——DPO/RPO 路线 deferred（需负例来源+异源 judge+mlx DPO 未实测），明确不前置实装，当前 propose 只写 SFT 正例+4类schema+IrrelAcc 死门，DPO 标 DEFERRED，守 Phase 0。
5. **priority_self**:**P1**。

---

## 7. external_claims 待主线程核
- AWS Qwen3-1.7B 逐阶段三位小数 41.57/60.43/71.06（总增益 30% 已双源确认，小数待核原文表）。
- Abstain-R1 arxiv 2604.17073 + 数 51.9/37.0→68.1/55.1（场景=知识 abstention，适用性参考非直接迁移）。
- Awakening Sleeping Agent 80%→21.67%/49.17%（论点多源同向，单数待核 arxiv 2604.08388）。
- When2Call 早期 WebFetch 幻觉数(82.3%等)已弃，最终只用 README 真实数(48.1/49.4→51.0/52.4)。
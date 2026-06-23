# 巨型语义协议表 → MAformac 内化方案 + Roadmap + 冻结决策整改清单

> ⚠️ **HISTORICAL 快照（2026-06-19）—— 文档级联 banner（2026-06-23）**
> 本文是基座内化方案的早期历史快照，其内化范式已沉淀进权威 MASTER（`docs/baseline-semantic-protocol-2026-06-19.md`）+ 契约 SSOT（`contracts/semantic-function-contract.jsonl`）。范式翻案后（generic frame → D-domain 具名工具，见 `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`）+ 口径终拍 562，本文涉及的 surface 形态 / 口径数字部分已过期。**活基线** = `CLAUDE.md §9` + 上述 MASTER + jsonl。正文保留供溯源，勿据此推进。

> **定位**:回答磊哥"业内怎么处理这种巨型表格 + MAformac 怎么内化",产出 ① 方案建议 ② 实施 roadmap(codex 执行,CC 思考)③ 哪些冻结决策要整改。
> **方法**:`/pre-mortem` scout(raw 某车厂一手做法)+ oracle(业内通用 + prior art,进行中)。
> **红线**:抽象通用工程范式,不复制客户标识/原文语料;源表只读不进仓。
> **状态**:scout 部分定稿;oracle(prior art + 坑 + 三分类)待补(§6/§7)。

## 0. 问题
基座是 ~3900 个四级功能(carControl 2655 + cmd 1088 + airControl 174)× 多维度(value 四件套 / position 几十种 / 示例说法 / FC 标记 / 二次交互)的几千行 Excel。**客户现场随意说全集甚至超出**,只做 8 个窄 mock = 丢脸。怎么把它内化进端侧 1.7B + LoRA + mock demo?

## 1. 业内怎么处理(scout:某车厂《复杂车控 FunctionCall 交付手册》一手做法)

**核心:不把 3900 intent 塞模型,而是「意图收缩 + 三层路由 + 分层兜底 + 安全分级」**

### 1.1 三层路由(按说法类型分流,各有延迟/准确率预算)
| 说法 | 路由 | 预算 |
|---|---|---|
| "打开空调"(动词+对象精确) | **传统语义/规则** | <300ms,头部≥99% |
| "有点冷"(感受词,参数模糊=模糊说) | **意图收缩 → FC** | ≤2400ms,≥85% |
| "热得像蒸笼"(修辞=自由说) | **FC 自由说** | ≤2800ms,≥80% |
| "冷又困"(多意图+端状态) | **MasterAgent 慢思考** | ≤3000ms,≥80% |
| "前面有个湖"(脱离车控) | **安全拒识 + 兜底播报** | 误吸≤5% |

### 1.2 意图收缩(Intent Narrowing)= 关键机制
后处理脚本/小模型在传统 NLU **后处理阶段**对感受词/场景词/模糊说打 `clarifyTag`,**让规则主动弃权**(不改模型只改标签),透传原文 + 领域上下文给 FC。"收缩"对象 = NLU 命中范围,结果 = 流量路由(非简单拒识)。
- **clarifyTag 5 值**:`explicit`(直接执行)/`implicit`(收缩→FC)/`ambiguous`(反问)/`rejected`(拒识兜底)/`passthrough`(继承上轮)。
- **为什么不堆数据**:模糊说变种指数膨胀,堆 NLU 语料边际成本过高、追不上长尾 → 主动收缩交 FC 泛化。**这就是 LoRA 的精确定位。**
- **生理感受触发词表**:温度(冷热凉暖冻烫)/空气(闷憋臭呛)/声音(吵闹安静)/空间(挤宽窄)/光线(刺眼黑暗亮)/生理(困累晕烦渴饿)。

### 1.3 分层兜底(磊哥"不丢脸"被业内白纸黑字印证)
- 规则 vs 模型:**最佳组合 = 规则兜底(头部≥95%)+ 模型扩展(长尾≥85%)**。
- 端侧交互:云端不处理,端侧按 模糊说/自由说 标签分流;**车型不支持 → 端侧通用兜底逻辑**;自由说不支持 → 兜底播报"换个说法试试"。→ **正是 MAformac L2 通用 mock 兜底。**
- 边界:FC 未召回→规则兜底 / FC 召回但不支持→端侧兜底 / 参数超范围→默认值执行 / 超时→规则兜底。

### 1.4 安全分级(ISO 26262)
`ASIL D`(致命:急刹/转向/气囊)→ FC 不支持 / `ASIL B`(远光/雨刮/车门)→ 二次确认(话术+超时 3-5s)/ `QM`(空调/座椅/阅读灯)→ 直接执行。误吸防护:意图收缩层 + 触发词过滤 → FC → 功能权限检查 → 安全决策树。

### 1.5 真实 badcase(MAformac 要规避 + 测)
"有点冷→默认24°(默认值未优化)" / "风太大了→关风扇(意图错,应降速)" / "车里闷→开窗(应开外循环,场景错)" / "今天好冷→无反应(意图收缩未触发)"。

## 2. 端状态打点发现(102 原子能力 = mock state 设计源 + 范围印证)
某车厂《多阶车控端状态能力打点》102 个 P0 端状态原子能力,带取值范围 + 默认值 + 是否上传 + 优先级:
- **范围印证(我之前拍错的)**:空调温度 **15.5~32℃(车型 18~32℃)**、空调风量 **1-10 档**、座椅各档 关闭/1/2/3、车窗 0-100%。`capabilities.yaml` 的 16-30 / 0-5 是错的。
- **端态可知性**("是否上传")= FC 参数规划前提(「有点冷」要读当前温度才能升温)。
- **多音区/指代源**:说话人位置(主/副/左后/右后)+ 各座乘客检测(有人/无人)+ 各门窗状态 → demo 多轮指代 + 第三人称 + 场景感知。

## 3. MAformac 内化方案(把巨型表分解成 6 个工程产物)

**P1 契约层(单一事实源)**:`capabilities.yaml` 升级为完整语义协议 —— `value` 四件套 + 归一化动作编码 + position + range(对齐端态打点真值)+ 端态 cell + `clarifyTag` 路由标记。codegen 生成 Swift 运行时 + 训练数据 schema + E2E fixture。**全集语义协议表**从基座解析(脱敏,intent 协议骨架入仓)。

**P2 运行时三层路由 + 意图收缩**:规则 NLU(精确指令查表,<300ms)+ **意图收缩层**(感受词/模糊说打 `clarifyTag:implicit` 让规则弃权)+ FC 泛化(LoRA,模糊说/自由说出候选)+ 慢思考(多意图)+ 安全拒识(L4)。所有候选过 change3 统一门(DemoGuard)。

**P3 执行分层兜底**:L1 精做炸点(端态+精美卡片+readback+多轮+参数规划可视化)/ L2 通用 mock 兜底(听懂 intent→通用「已为您 X」卡片,业内验证,成本极低)/ L3 越界优雅延后 / L4 安全门(forbidden + restraint + ASIL 分级二次确认)。

**P4 LoRA 语料合成**:基座 col20 示例说法 + FC模糊说/自由说标记 + value 协议 + 二次交互次轮说法 + 生理感受触发词 → 模板展开(控组合爆炸)+ LLM 增广(口语/方言/修辞)→ 训练对(user utterance → tool call JSON)。意图收缩负样本(restraint/OOD)。

**P5 端状态 mock**:覆盖 102 端态原子能力的 P0 子集,取值范围/默认值对齐打点表;端态可知 → FC 参数规划读端态生成增量。

**P6 E2E "不丢脸"基线**:从全集采样客户随意说 + badcase(1.5)+ 多轮 + restraint + 越界 → 断言(正确 intent/value + 不崩 + L1改态/L2兜底/L3延后/L4拒识)。**全集覆盖率 = 不丢脸量化死门**。

## 4. Prior Art + Adopt(oracle:业界成熟范式,基本零造轮子)

### 4.1 LoRA 语料合成 + 训练(oracle B,证据充分)
**这条路是业界已验证范式**(协议表 → 模板展开 + LLM 口语化 → FC 格式 LoRA 微调 1.7B),不是闯新路。基线:Qwen2.5-1.5B 裸跑 BFCL ≈67%,**领域 LoRA 微调后 ≈85%**(可复现)。

| Repo / 资源 | star / pushedAt | adopt 什么 |
|---|---|---|
| **MadeAgents/Hammer** ⭐ | 119★ / 2025-06(arxiv 2410.04587,**无会议背书**;超1年未动→方法学原始+stdlib稳定仍 adopt,补 GOAT/xLAM 更新鲜)| 端侧 FC + Qwen 底座 + **function masking**(函数名/参数名随机掩码,逼模型靠 description 语义理解、防作弊;§28 核:data_processing.py 293行纯stdlib,与训练框架解耦)+ **拒识数据**(无匹配 tool → output `[]`)+ 训练脚本 |
| **Salesforce/xLAM + xlam-function-calling-60k** ⭐ | 628★ / 2026-06 | 数据格式标准 `{query, tools[], answers[]}` = **协议表→训练对的天然 JSON 落点**;APIGen 三阶段过滤(语法/可执行/语义) |
| **unslothai/unsloth** ⭐ | 66795★ / 2026-06-18 | Qwen3-1.7B LoRA/QLoRA 训练框架,2× 速度半显存 |
| **argilla/distilabel** | 3283★ / 2026-06-15 | 合成数据 pipeline 编排(模板填槽→LLM 改写→校验) |
| **Gatsby-web/MAC_SLU** ⭐ | 6★ / 2026-02(HF 已开源) | **唯一中文车舱多意图 SLU 基准**(2万+真实座舱中文)→ **外部 eval 集**(防自测虚高) |
| nlpcda(中文增广)/ nlpaug(英文) | 1880★ / 4658★ | 槽外文本扰动 |

**LoRA pipeline(5 步,adopt)**:① 协议表 → xLAM/Hammer JSON 种子(**机械映射,确定性**,几千行→几千种子)② 模板展开 + **加权采样**(按真实高频组合,**不做笛卡尔积**,控到 1万~3万)③ **LLM 口语化层**(只对 FC 标记的"模糊说/自由说"列改写成随便说/方言/省略,= 泛化来源,呼应"规则吃80%/LoRA练20%模糊")④ 拒识负样本 10-15%(output `[]`)⑤ unsloth 跑 Qwen3-1.7B,**rank 8-16 / α 16-32 / 3ep / lr 1e-4**,先 2-3k 种子测格式收敛再扩;**MAC-SLU + 真实集 held-out 校验**。

### 4.2 工程化 / 运行时 / codegen(oracle A,证据充分)
**业界范式(基本零造轮子)**:SSOT codegen + device×动作原语×槽位三元分解 + 模板 DSL 合成 + 三层路由 + 约束解码。

- **SSOT codegen + drift gate**:`capabilities.yaml` 一份 → codegen 出 ① tool schema(给模型)② 规则 NLU 查表 ③ LoRA 训练话术 ④ bench 题;**pre-commit 校验"生成物 == 重新生成"**,手改即 CI 红(adopt Typia/REGAL 思想)。REGAL 把"模型看到的 tool 定义 vs 后端实现错位"正式命名 **tool drift**。
- **几千 intent 三元分解**:`intent = device × action-primitive × slot` 矩阵(USPTO 11868725),**不要 3900 扁平类别**;槽值用 **canonical + synonym + ID 三件套**(Alexa Entity Resolution)→ 直接吃 value 四件套 + position 几十种(全归一到 canonical+ID)。**这印证了我发现的"归一化动作编码"。**
- **三层路由**:规则查表快路径(<50ms,**不碰 LLM**,扛 ~90% 高频)+ 语义路由决策层(ModernBERT 判 fast/慢)+ LLM 兜底;中文车载:**state-dependent command dictionary**(按当前车态过滤可选命令)+ 本地 NLU 资源约云端 1/10;端到端 600-800ms。
- **覆盖率**:CLINC150 范式(in-scope + **OOS 拒识**,AU-IOC 指标);bench 当回归基线(NLU.DevOps 思想,改 schema→自动重跑→看退化)。

| Prior art | star / pushedAt | adopt 什么 |
|---|---|---|
| **vllm-project/semantic-router** ⭐ | 4448★ / 2026-06-19 ✅ | 三层路由**决策层**(ModernBERT 判 fast-path vs 慢思考)= 我们 intent-routing 三层 |
| **samchon/typia** | 5833★ / 2026-06-19 ✅ | **编译期 SSOT codegen** 思想(Swift 取思想:从 yaml 派生全部 + 防漂移) |
| **dottxt-ai/outlines + instructor** ⭐ | 13975★/13191★ ✅ | **结构化输出约束**(治 1.7B "JSON 不合法/格式塞 content") |
| **mlc-ai/xgrammar** ⭐ | 1747★ / 2026-06-11 ✅ | **端侧约束解码**(与 MLX/llama.cpp 栈对口,强约束 FC 输出) |
| **MikeVeerman/tool-calling-benchmark** | 102★ / 2026-04 ⚠️边界 | 负触发评测;**实测 qwen3:1.7b 负触发稳过 = 选 1.7B 的利好证据** |
| *(停更标杆,取思想)* Genie/ThingTalk · Chatito · DroidCall | — | **NL-template DSL 合成训练数据**范式(最对口"协议表→语料",解决"无法为每句收 paraphrase") |

## 5. 坑 / Failure Mode(pre-mortem,带 mitigation)
1. **组合爆炸**(几十 position × 几十 color × N 动作 = 千万废句)→ 加权采样 + UAT 结构多样性 + 约束感知填槽,采几千~几万。
2. **过拟合模板**(机器味,真口语崩)→ **必叠 LLM 口语化层**,多样性采样非 beam。
3. **🔴 mock 规范说法 ≠ 客户随便说分布偏移(本场景最大坑)**:协议表"示例说法"是协议作者规范说法,全 mock 训练分布 ≠ 真实使用 → (a) **MAC-SLU 真实座舱语料外部 eval**(别只自测,虚高);(b) FC"模糊说/自由说"列重点喂 LLM 口语化;(c) **function masking 防靠规范函数名作弊**。
4. **小模型学不会 FC 格式**(sub-3B,100-200 条可能锁不住 JSON)→ 先小样本测格式收敛,不收敛加数据 + Hammer 结构标记 + XGrammar 结构化解码兜底。
5. **拒识缺失**(只训"该调啥"→对无关输入硬塞 tool call)→ 必造 output `[]` 负样本(=pre-mortem"拒识负样本"硬 gate)。
6. **灾难性遗忘**(rank 高/数据专 → 忘通用)→ rank 8-16、混 5-10% 通用样本 rehearsal。
7. **badcase 复现**(业内实证:有点冷→默认值未优化 / 风太大→关风扇意图错)→ 参数规划步长表对齐真实 + 这些进 E2E 必测。
8. **假 SSOT**(口号说单一源,但生成物被手改不校验)→ **pre-commit drift gate**(`gen` 后 `git diff --exit-code` 生成物,手改即 CI 红)。源:Typia/REGAL。
9. **🔴 假泛化(SGD-X 揭露:所谓 unseen schema 里 71% intent 名 / 65% slot 名训练已见 → 模型靠名字记忆,非真泛化)**→ schema 名/描述**风格增广** + **function masking**(掩码函数名/参数名,逼模型靠语义理解);bench 留"换说法 schema"鲁棒测试。**这是 demo 现场客户换个说法就崩的根因 = happy-path bias 典型炸点。**
10. **小模型自造格式**(用统一格式微调 ≠ Qwen 自身 instruction-tuning 格式,产生 gap)→ 必贴 **Qwen3 原生 tool-call chat template**;bench **format-validity / decision-correctness 双轴评分**(别 format-blind,否则 87.5% 这种数双向误判)。

## 6. 实施 Roadmap(codex 执行 / CC 思考;每 Phase 派 codex 用 `docs/dispatches/_TEMPLATE.md`)

> 原则:**先有全集事实源,再分层实现;规则吃 80% 别让所有命令过 1.7B;每步 drift gate + bench 回归。**

| Phase | 做什么 | 依赖 | 产物 |
|---|---|---|---|
| **P0 全集事实源定稿** *(立即,无依赖)* | 基座全集 → MAformac 功能清单全集(脱敏入仓);抽 **device × action-primitive × slot 矩阵**(~12 原语);端态 cell = 102 原子能力 P0 子集,**range 对齐真值**(温度 18-32 / 风量 1-10 / 座椅 0-3 / 车窗 0-100%) | — | 功能清单全集 + device-action 矩阵 + 端态清单 |
| **P1 契约 SSOT 升级 + drift gate** | `capabilities.yaml` → value 四件套 + action-primitive + canonical/synonym/ID + position + range + clarifyTag + 端态 cell;升级 codegen(tool schema/规则查表/训练 schema/bench fixture)+ **pre-commit drift gate** | P0 | 升级 yaml + codegen + CI drift |
| **P2 运行时三层路由 + 意图收缩** | 规则查表快路径(<50ms,~80%)+ 意图收缩(感受词打 `clarifyTag:implicit` 让规则弃权)+ FC 候选(LoRA)+ 慢思考 + 安全拒识;state-dependent command dict;过 change3 统一门 | P1 | intent-routing 三层 |
| **P3 执行分层兜底** | L1 精做炸点(~10 设备:端态+卡片+readback+多轮+参数规划可视化)+ L2 通用 mock 兜底模板 + L3 越界 + L4(forbidden+restraint+ASIL 二次确认) | P1 | 执行层 + 兜底 |
| **P4 LoRA 语料 + 训练**(adopt §4.1) | 协议表→xLAM/Hammer JSON 种子 → 模板展开+加权采样 → LLM 口语化(仅模糊说/自由说列)→ 拒识负样本 10-15% → unsloth Qwen3-1.7B(r=8-16,Qwen 原生 template,function masking)→ MAC-SLU held-out 校验 | P1 | LoRA 权重 + 语料 pipeline |
| **P5 E2E 不丢脸基线** | 全集采样+badcase+多轮+restraint+越界 → **format/decision 双轴** + OOS 拒识率 + 全集覆盖率;bench 回归基线 | P0-4 | E2E bench(=验收死门) |

## 7. 冻结决策整改清单(磊哥要的"哪些之前冻结的要改")

| 冻结项 | 现状(冻结时) | 整改成 | 量级 |
|---|---|---|---|
| **`capabilities.yaml`** | 8 个扁平 tool(power/level 平铺) | value 四件套 + action-primitive 矩阵 + canonical/synonym/ID + position + range 真值 | 🔴 大重构 |
| **change2(已 archive)** | capability 契约(扁平 8 能力) | 契约升级 → **新起"契约重构"change**(archive 不回炉,新 change MODIFIED) | 🔴 |
| **change3(PR #1)** | 执行层 arguments=扁平 | 升级 value 四件套 + **position fan-out**(GPT Pro catch 的 P0 一并解决)+ L2 兜底;decoder/guard 跟改 | 🟡 |
| **intent-routing(未 apply)** | 二分→三分概念 | 吃业内三层 + 意图收缩 clarifyTag + state-dict;explore 用基座 | 🟢 正好对齐 |
| **change6 vehicle-tool-bench** | 四个 0 + must-pass 100% | + format/decision 双轴 + OOS 拒识 + 负触发(tool-calling-benchmark)+ 全集覆盖率 | 🟡 |
| **change5 lora** | LoRA 数据层 | adopt Hammer/xLAM/unsloth + 模板 DSL 合成 + function masking | 🟡 |
| **must-pass candidate** | 18 条扁平 | 重做(全集采样+badcase+不丢脸,基于 device-action 矩阵) | 🔴 废重做 |
| **端态(D16 自包含)** | 8 cell | 102 原子能力 P0 子集;**range 对齐(温度 18-32 / 风量 1-10,我之前拍 16-30/0-5 全错)** | 🔴 |

**D 决策重审**:D16(端态 8→102)/ D30(训练栈→**unsloth** adopt)/ D35(must-pass 15-25→**全集覆盖率**)/ D37(安全门→**ASIL 分级 + clarifyTag**)/ 参数规划 D(→value 四件套 + 步长表)。**范围硬错纠正**:空调温度 16-30→**18-32**、风量 0-5→**1-10**(以端态打点为准,车型相关)。

## 8. Pre-Mortem 三分类(HIGH 停下让磊哥拍)

**🐯 tiger(明确威胁,带 mitigation)**
1. **🔴HIGH 假泛化**(SGD-X:靠 intent/slot 名记忆;基座 col20 是规范说法,直接训会记函数名)→ function masking + schema 名风格增广 + bench 换说法鲁棒测试。**否则 demo 现场客户换个说法就崩。**
2. **🔴HIGH 假 SSOT**(生成物手改不校验)→ pre-commit drift gate(CI 红)。
3. **🔴HIGH mock 规范说法 ≠ 真随便说分布偏移**→ MAC-SLU 真实座舱语料外部 eval(别自测虚高)。
4. **HIGH 小模型学不会格式**(1.7B JSON 不合法)→ Qwen 原生 template + xgrammar 约束解码 + 先小样本测格式收敛。
5. **MEDIUM 组合爆炸**→ 加权采样(非笛卡尔积)。
6. **MEDIUM 拒识缺失**→ 负样本 output `[]`(qwen3:1.7b 负触发实测稳过=利好)。

**🐯📄 paper-tiger(看似威胁实际可控,有证据)**
1. "1.7B 太小撑不住几千 intent" → **证据**:Qwen2.5-1.5B 裸跑 BFCL 67%→LoRA 后 85%;qwen3:1.7b 负触发实测稳过;规则吃 80%、LoRA 只练 20% 模糊 → **可控**。
2. "巨型表无法内化" → **证据**:业界成熟范式(SSOT codegen + 三元分解 + 模板 DSL + 三层路由 + 约束解码),基本零造轮子,prior art 齐全。

**🐘 elephant(没人想谈的)**
1. **demo 全 mock → 训练/eval 分布 ≠ 真实使用**:真泛化要真实语料,demo 阶段 L2 兜底是**遮羞布不是真泛化**;诚实讲——demo 靠"规则吃高频 + L2 广兜底 + 小 LoRA 秀炸点"撑场,不追求全集真泛化。
2. **工程量 vs solo demo 北极星**:全集内化 + LoRA pipeline + 三层路由是大工程;可能砍到 **"L1 精做 ~10 炸点 + L2 兜底广覆盖 + 小 LoRA 练模糊说"**。**P0(全集事实源)必做(便宜),P4(LoRA 真泛化)按 demo 时间裁剪。**
3. **基座版本漂移**:基座是某车厂活文档会更新,MAformac 内化的是快照;长期需 re-sync(solo demo 期先不管)。

## 9. HIGH 决策点(请磊哥拍)
1. **demo 是否追求 LoRA 真泛化(大工程)还是 L1 精做 + L2 兜底先撑场(P4 裁剪)?** ⭐ 我倾向后者(demo 北极星=5 分钟炸场,不是量产泛化)。
2. **契约重构走新 change vs 回炉 change2(已 archive)?** ⭐ 新 change(archive 不动)。
3. **范围/步长以端态打点(温度 18-32 / 风量 1-10)为准,还是你另定车型?**
4. **下一步先做 P0(全集事实源定稿,便宜必做)还是先收口 change3 PR #1(GPT Pro 的 position P0)?** ⭐ 先 P0(它定义了 change3 该怎么改)。

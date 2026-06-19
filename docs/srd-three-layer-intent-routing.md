# SRD — MAformac 三层意图路由架构（事实源 · 防失忆锚点）

> **本文地位（最高）**：MAformac demo「大脑」的**架构事实源**。每个新 session **起手必读**（CLAUDE.md §9 已挂指针 + memory `maformac-three-layer-routing-architecture` 指向本文）。
> **为什么存在**：CC 反复重新理解又反复丢失这套架构（磊哥 2026-06-19「你连续多次失忆」）。架构落成持久权威文档，结构性止血。
> **OpenSpec 对应**：本文 = `define-intent-routing` change 的 design.md 源 + 全局 SRD（SRD≈specs+capabilities.yaml，ARCH≈design）。**改架构必走 openspec change + 回写本文**。
> **一手源**：`~/workspace/raw/01-Wiki/大模型/车控意图收缩与FC路由机制.md`(1148行) + `中枢大模型落域分发完整科普.md`(1000行) + `快慢思考切换信源依赖`、`智能体锁域机制与拒识策略`、`MasterAgent车控智能体`。本文是这些一手源的**架构提炼**（脱敏，只抽语义/架构，不复制商业细节）。

---

## 0. 北极星 & demo 边界（架构受此约束）

- **北极星**：客户现场 5 分钟，**听懂中文 / 反应快 / 不崩 / 惊艳 / 断网也能跑**。纯端侧（macOS+iOS）、完全离线、Qwen3 小模型+LoRA 为脑、mock 车控。
- **不是**：量产座舱 / 真车控 / 多租户 SaaS / 聊天机器人。
- **架构含义**：量产标准（ISO26262/端云/QPS/误吸率硬指标）**豁免**，但**安全门思想 / 参数规划 / 读 mock 态 / 工具约束 / LoRA / 三层路由思想 保留**（CLAUDE §9 + cockpit-premortem）。

---

## 1. 核心：三层意图路由（架构的灵魂，别再拍平成"全 LoRA"）

> ❌ **反面教训（2026-06-19 CC 犯）**：把所有维度拍成"全走 LoRA 泛化 showcase"——这是把三层路由**拍平**，根本性错误。L1 精确指令本该走**规则快路**（不碰模型），LoRA 只在**慢路**。

### 1.1 总览（用户说话 → 分流）

```
用户说话 → ASR → 传统 NLU
  ├─ L1 精确指令(动词+对象+参数, clarifyTag=explicit) ──→ ⚡【快路】规则直接执行(<300ms, 不碰大模型)
  ├─ 命中感受/场景/模糊词 ──→ 🔍【意图收缩层】NLU 主动弃权(标 implicit, 置信度打0) ──┐
  └─ 完全无法匹配 ─────────────────────────────────────────────────────────────┤
                                                                                  ↓
                                              🧠【慢路】思考的 Qwen+LoRA(FC/多阶)
                                                ├─ L2 感受 / L3 场景 / L4 自由说 → FC 单意图(泛化)
                                                ├─ L5 多意图 / 多阶 / 端状态相关 → 多执行项(MasterAgent 角色)
                                                ├─ 落域 → 分发到正确垂域 + 多轮锁域继承
                                                └─ 安全门 → 行驶禁动作优雅拒识
                                              🚫【拒识】人人对话/无意义/OOD → 兜底播报
```

### 1.2 五层意图模型（L1-L5，决定走快/慢，一手 wiki）

| 层 | 名称 | 定义 | 例 | clarifyTag | 路由 | 谁处理 |
|---|---|---|---|---|---|---|
| **L1** | 精确指令 | 动词+对象+显式参数 | "打开空调" / "打开主驾车窗" | `explicit` | ⚡**快路** | 规则 NLU(不碰模型) |
| **L2** | 感受词 | 生理/空气/声音/光线感受 | "有点冷" / "屏幕太暗了" | `implicit` | 🧠**慢路 FC** | Qwen+LoRA |
| **L3** | 场景词 | 环境/天气/交通描述 | "下雨了" / "变天了" | `implicit` | 🧠**慢路 FC** | Qwen+LoRA |
| **L4** | 自由说 | 修辞/比喻/非标准 | "热得像蒸笼" / "风太大要把我吹飞" | `implicit` | 🧠**慢路 FC** | Qwen+LoRA |
| **L5** | 多意图/多阶 | 并行或串行多意图、需端状态 | "冷又困" / "打开空调调到24度" | `implicit`+多执行 | 🧠**慢路 MA** | Qwen+LoRA(演 MasterAgent) |

> **关键判别**："打开主驾车窗"是 **L1 精确指令（走快路）**，不是泛化！真正的慢路泛化是非标说法（"把驾驶位那个窗户弄下来"）。**快慢分错 = 没理解架构**（CC 2026-06-19 曾把此例标成"快FC泛化"，错）。

### 1.3 clarifyTag 路由契约（贯穿三层的语义路由信号，一手 wiki）

| Tag | 含义 | 处理 |
|---|---|---|
| `explicit` | 精确指令 | ⚡ 快路直接执行 |
| `implicit` | 模糊意图 | 🔍 意图收缩 → 🧠 慢路 FC/MA |
| `ambiguous` | 歧义待确认 | ❓ 反问澄清 |
| `rejected` | 无意义/人人对话/OOD | 🚫 拒识兜底 |
| `passthrough` | 带上下文延续 | 🔁 继承上轮状态（锁域） |

---

## 2. 意图收缩（Intent Narrowing）= 路由心脏

> **一句话定义（一手 wiki）**：意图收缩是**主动拒识路由机制**——通过后处理脚本/小模型，让传统 NLU 在感受词/场景词/模糊说法上**主动弃权**（标 `clarifyTag=implicit`、置信度打 0），**拒掉后路由给慢路 FC**，并带原始说法上下文。

**三个关键点**：
1. "收缩"对象 = **NLU 的命中范围**，不是用户表达能力。
2. "收缩"动作 = NLU **后处理阶段**（不改模型，只改标签/路由）。
3. "收缩"结果 = **流量路由**（引导到 FC，带上下文），不是简单丢弃。

**为什么模糊说法不能堆规则**（磊哥反复强调"多一字少一字"）：感受词/场景词变种**指数级膨胀**（每语种/年龄/方言新说法），扩规则语料**边际成本过高、永远追不上长尾**。正解 = **收缩 NLU 命中、交给会泛化的 Qwen+LoRA**。这就是 demo 的核心价值，也是为什么 **LoRA 必做**。

**双轨实现**（一手 wiki）：
- **路径 A 规则后处理**：感受词表（冷/热/闷/吵…约 120 基础词 + 2000 变形）命中即标 implicit。头部说法准≥95%，长尾≤60%。
- **路径 B 统计小模型**：意图收缩模型（二分/多分类）判"模糊度"，softmax(implicit)>阈值(实测 0.6)即收缩。长尾变体（"凉飕飕"）≥85%。
- **最佳组合 = A 兜底 + B 扩展**。

**拒识**：意图收缩层也负责拒掉人人对话/无意义/OOD（`rejected`）。注意：**路由而非过滤**——危险信号（"外面有恐怖分子"）不能粗暴拒，要路由给 FC 理解为防护意图。

---

## 3. 落域（Domain Landing）

> **定义（一手 wiki）**：中枢大模型把意图**分发到最合适的垂直域/Agent**（车控/导航/娱乐/服务/安全…）。落域准确率 = 垂域匹配率（量产目标 ≥93%）。

- **粗落域**：是不是车控？（vs 导航/娱乐/闲聊/OOD → 拒识）
- **细落域**：车控域内哪个设备域（空调/车窗/屏幕/氛围灯/安全门）。
- **锁域多轮继承**：进入某域后，后续模糊/省略说法锁在该域（"打开空调"→"再高一点"锁在空调；`passthrough`）。

**demo 范围**：demo 只有**车控域**（cabin.*）。落域 = 车控域内设备定位 + OOD 拒识 + 多轮锁域。导航/音乐/外卖等跨域 via MCP 二期。

---

## 4. 快路 vs 慢路（fast / slow）

| | ⚡ 快路 | 🧠 慢路 |
|---|---|---|
| 处理 | L1 精确指令 | L2-L5 模糊/多意图/记忆/复杂推理 |
| 引擎 | 传统规则 NLU（**不碰大模型**） | Qwen3-1.7B + LoRA |
| 延迟(量产参考) | <300ms | ≤2400ms(FC) / ≤2500ms(MA) |
| 泛化 | ❌ 只认精确说法 | ✅ 模糊/自由说/长尾 |
| LoRA | 不涉及 | ✅ **只练这层**的"模糊说→跨域映射"(CLAUDE §4) |

> **规则吃 80% 高频明确，LLM 只碰 20% 模糊/跨域**（CLAUDE §4）。demo 惊艳点 = **明确秒回 + 模糊慢思考泛化 + 意图收缩不硬塞 + 落域 + 拒识 + 安全门**，不是"全靠 LoRA"。

---

## 5. demo 端侧映射（真实四段 → demo 三段简化）

真实座舱：`NLU → 意图收缩 → FC → MasterAgent`（端云四段）。
**demo 端侧离线**收敛为三段（量产标准豁免，思想保留）：

| demo 组件 | 承接真实哪段 | 实现 |
|---|---|---|
| ⚡ **快路** | 传统 NLU（L1） | 端侧规则 NLU，秒回，mock 执行 |
| 🔍 **意图收缩 router** | 意图收缩层 | **规则关键词 + embedding 语义路由（22MB/CPU/ms 级），不用 LLM 当 router**；决策快/慢 + 落域 + 拒识 |
| 🧠 **慢路** | FC（**非 MA**） | **Qwen3-1.7B+LoRA 只产【单跳 ToolCallFrame】+ 窄域"模糊说→意图"映射**（L2-L4）；**受限解码保格式** |
| 🧩 **编排/多步/安全/三态** | ~~MasterAgent~~ → **code** | **DialogueState/state machine + 安全五门 + 三态判断 全在确定性 code，不在模型**（受约束优化，非模型多步推理） |

- ⚠️ **纠正（深度验证 2026-06-19）**：原写"1.7B 演 FC+MA"是**过度索取**——6 流证据证明 1.7B 做不了编排/多步（编排器容量=系统瓶颈，需 70B+）。**1.7B 只当"执行手"（单跳 FC + 模糊映射），"编排脑"移到 code。**
- **多意图降级**：同垂域多执行（"好冷"→空调+座椅）= 规则触发多执行项；跨域多意图 = 规则切分 + 串行单跳 FC（**不做真 Planner/编排**）。
- 无云端 MasterAgent；LoRA Day1 埋 trace（D 决策）。

---

## 5.1 架构定性（深度验证 2026-06-19）：反转架构，非镜像 8B

> 磊哥质疑「1.7B 镜像 8B（量产 8B 中枢+编排，传统语义+FC 走快路）是否成立」。经 **/probe + /pre-mortem + 6 流证据交叉验证**（本地生产 3 + 联网 3，全料 `docs/research/2026-06-19-architecture-validity-deepdive.md`）：

**裁决（ACH 排除法）**：
- **❌ 镜像 8B 不成立（置信 92）**：NVIDIA SLM-agents(2506.02153) / TinyAgent(2409.00608) / Cerence CaLLM Edge / 编排器瓶颈(2601.11327) / 生产一手承认(交付手册:792) / Snips —— 6 流全否。
- **✅ 反转架构成立（置信 90）= MAformac 已锁 D 系列**：**规则吃高频 + 窄域 LoRA 小模型只产单跳 FC + code 编排（非模型）+ 受限解码保格式**。Snips/Picovoice/HA Assist/Cerence/Octopus/TinyAgent/SayCan/Alexa Lex 全是它的实现。**不是赌，是已验证范式的合理组合。**

**现存条件可行性（Opus 知识，三主 tiger 被实际栈中和）**：

| 通用 tiger | 你的栈（mlx-swift+Apple Silicon+Qwen3-1.7B+GBNF+8-bit）中和后 |
|---|---|
| 延迟 CPU 1.5B=10.3s | **走 Metal/ANE 非 CPU**，1.7B decode 50-100 tok/s → FC <1-2s(warm)，落"慢思考正常"区；快路规则担"反应快" |
| base FC 断崖(LLaMA 12.71%) | **Qwen3-1.7B 自带 tool-call 模板+工具预训练**，起点更高；LoRA 再补 |
| 格式崩(1B schema 22%) | **GBNF/xgrammar 现成 → 100% schema 合法** |
| 内存(3B 不进 jetsam) | **1.7B 8-bit ~2GB < iPhone 8GB×50%**，装得下，不压 4-bit（保精度） |

**唯一残余赌点（不可消，spike E3 闭）**：1.7B+LoRA 在 3990 数据上"**结合端状态的模糊意图→正确意图/参数**"的**语义命中率**（格式已由受限解码解决）。生产一手承认小模型"暂时做不到"（交付手册:792）；跨行业先例乐观（**Qwen2.5-1.5B 真人嘈杂话 86.4%**，HA arXiv 2502.12923）。**有 fallback**（换 3B 核内存 / 砍慢路保规则快路 / 退"金句模糊"）。

**诚实信心**：策略 soundness **~92%**（6 流收敛 + 三 tiger 现存条件已解 + 排除法跑完）；**经验性 100% = NO**（认识论上只能 spike E3 实测填，此刻称 100% = happy-path 谎言）。**分析 loop 已收敛，严谨收尾 = 锁定反转架构 + 跑 spike E3。**

**🔴 实现回潮硬约束（写进 capabilities.yaml/dispatch 模板 enforce）**：**"编排/多步 state 必须在 code（DialogueState/state machine），模型单次调用只产单跳 ToolCallFrame；禁止 model 自由决定 next-tool 的 agent loop。"** —— 8B 范式深入人心，实现时极易反射性写"让模型 decide next tool"的回潮，须 contract 硬拦。

**两个现成蓝本（最该 clone 研究）**：① **HA Assist** 两层分流（生产/离线/规则优先+LLM兜底，`prefer_local_intents`）；② **arXiv 2502.12923 / acon96 home-llm** Qwen2.5-1.5B 一模型同出 JSON ToolCall+NL 回复（≈demo 现成参考实现）。

---

## 6. 与契约层（C1/C2/L1allowlist/risk-policy）的关系

| 契约产物 | 角色 | 与路由架构关系 |
|---|---|---|
| `semantic-function-contract.jsonl`(C1) | **意图全集**(device+action_primitive+canonical_semantic_id) | 落域 + FC 的工具/意图空间；3990 源行 |
| `state-cells.yaml`(C2) | demo mock 端态 | 慢路读 mock 态（多阶/状态感知依赖）；快路执行后改态 |
| `l1-demo-allowlist.yaml` | demo 精做炸点（L1allowlist≠模型训练范围） | 标注哪些设备/primitive 做精演；维度=模糊/多意图/记忆/泛化/状态感知/安全门 |
| `demo-scenarios.yaml` | **路由 aware showcase** | ⚠️ 每幕必标 **路由路径(快规则/慢Qwen) + clarifyTag + 落域 + 维度**；变体=LoRA/C6 种子，非匹配白名单 |
| `risk-policy.yaml` | 安全门 | 行驶禁动作(R2 refuse_explain) + 二次确认(R1) |

> **L1allowlist 范围 ≠ 模型训练泛化范围**（memory `maformac-l1-vs-training-scope`）：L1 暂定~5设备是 runtime 表现层；模型吃全集 3990 大范围泛化（C5 LoRA）。

---

## 7. 安全门（拒识 + 行驶禁动作）

- **OOD/无意义拒识**：意图收缩层标 `rejected`，兜底播报。
- **行驶禁动作**：车速>0 时危险动作（开车门/后备箱）→ 优雅拒识+解释（risk-policy R2 `refuse_explain`）。
- demo：方案经理手动 mock 切"行驶模式"（vehicle.speed/gear），最可控；C6 直接做 env_assertion。豁免 ISO26262，保留安全门思想做炸场。

---

## 8. 评测（C6）——看路由对不对，不是命中某句（磊哥 2026-06-19 明示）

- **训练集（C5）**：不是固定话术，是**同一意图类的多说法泛化**（3990协议 + 12000bug + raw 三源）。
- **评测（C6）**：不是命中某句，而是看 **① 路由对不对（快/慢/拒识）② ToolCall 对不对 ③ 参数对不对 ④ 读回态对不对 ⑤ 拒识对不对**。
- 量产参考指标（demo 豁免硬卡，留方向）：L1≥99% / L2≥85% / L3≥80% / 模糊说≥90% / 自由说≥80% / 误吸≤5% / 误召≤3% / 落域≥93% / 多意图recall≥85% / 端状态感知≥95%。

---

## 9. Risks（pre-mortem 全 · scout 一手 wiki + oracle ~12 路 web 已合并 2026-06-19）

**scout 命中（wiki Badcase / 失败模式 / 反模式）**：
1. **感受词过度泛化**："心里有点凉"误触发调温 → 情绪词 vs 物理感受词必须分离。
2. **场景词情感极性**："今天下雨真漂亮"误触发关窗 → 加情感极性判断。
3. **多意图只识第一个**："冷又困"只调空调 → 必须路由慢路多执行（L5）。
4. **上下文/锁域丢失**："再调一下"不知调什么 → 多轮锁域继承（passthrough）。
5. **端状态未知**：不知当前温度→升降方向错 → 慢路必须读 mock 态。
6. **路由误判**：明确指令误升慢路（慢+贵）/ 模糊说误塞快路（崩）→ 快慢判别是核心，硬约束规则前置（realtime/safety 一票否决）。
7. **危险信号粗暴拒**："外面有恐怖分子"被拒 → 意图收缩是路由非过滤。

**oracle 外部坑（CC subagent ~12 路 WebSearch + 4 WebFetch，2026-06-19，带来源）**：

🐯 **TIGER（明确威胁，必处理 → 落 demo 设计）**：

| # | 失败模式 | sev | 落点（mitigation） | 来源 |
|---|---|---|---|---|
| T1 | FC 吐畸形 JSON：schema 合法≠JSON 合法，1.7B 幻觉键名/漏必填/控制字符炸 parse | HIGH | **DemoGuard**：jsonschema 强校验(`additionalProperties:false`)+jsonrepair 兜底+constrained decoding(GBNF/outlines)；schema 从 capabilities 单一源生成 | dev.to anak…/medium SchemaGate |
| T2 | OOD 硬塞预定义意图（闲聊/旁人话被吸成"打开空调"） | HIGH | **意图收缩层**主动弃权(implicit/rejected)+OOD 与 in-domain 联合训(dynamic class weight)+训练掺 OOD 负样本 | arxiv 2211.09711 / 1807.00072 |
| T3 | 单 confidence 阈值拒识不住（"有点冷"升温 vs "有点烦"该拒，感受↔情绪混淆） | HIGH | 多信号拒识(ASR置信+意图熵+槽完整度)+感受词→动作 LoRA 专练(治"有点冷→26度"反填) | arxiv 2211.09711 / 2512.10257 |
| T4 | LoRA 过拟合训练话术：见过函数 95%、新函数仅 60-70%(25-35 点鸿沟) | MED→HIGH(二期MCP) | 负样本+数据多样性+retriever-aware(Gorilla AST校验)+held-out 新工具评测 | arxiv 2510.10197 / 2409.00608 |
| T5 | 微调毁 irrelevance detection（FC↑ 与弃权能力↓ 反相关，越会调越乱调） | HIGH | 训练强掺 irrelevant 样本+IrrelAcc≥20% 硬 gate(已有,勿松) | arxiv 2511.22138 |
| T6 | 快慢路由误判方向（router vs oracle 仅 87%，~13% 错路） | HIGH | 多信号冗余路由+保守弃权(拿不准走慢路)+历史话术专家标注对照集；路由<40ms | arxiv 2508.16636 |
| T7 | 指代/槽位继承失败（"再高一点"丢上文；66% 多步失败=用未建立变量） | HIGH | **送模型前指代补全改写**("再高一点"→"空调温度调高")+DialogueState 喂结构化槽位非裸历史 | arxiv 1806.01773 / 2509.26553 |
| T8 | 冷启动 TTFT 几秒（破坏"反应快"，weight load+prefill 主导，Apple 波动大） | HIGH | app 启动即预热(load+dummy prefill)+4-bit 量化+**快路规则秒回掩盖慢路冷启动** | arxiv 2604.09083 / 2410.03613 |
| T9 | demo-to-production gap（安静屋通≠现场通；STT 噪声掉 13-20%；60% 90天内失败） | HIGH | failure 清单含噪声/口音/半句/插话+**快路规则兜底厚**+demo 前接近现场实测 | autointerviewai |
| T10 | 过度依赖函数命名（masking 一打就垮，二期新工具名显形） | MED | Hammer function masking(已 adopt) | arxiv 2410.04587 |

🐯📄 **PAPER-TIGER（对端侧窄域 demo 可控，带条件）**：
- **sub-7B「零工具调用」断崖**：是 **base 裸跑通用 FC** 结论；1.7B+LoRA+窄域可行——in-vehicle 实证 **Phi3-1.8B+LoRA 0.86 exact-match FC + 11 tok/s CPU**。⚠️**条件**：spike E3 必须 base+LoRA 对照，否则 paper-tiger 变 tiger。(arxiv 2501.02342)
- **灾难性遗忘**：LoRA 冻结 base 天然抗 + 只练窄域 + rehearsal 5-20%。
- **路由漂移**：solo demo 锁版本规避（但"边界口语击穿快路"那半是 tiger）。
- **锁域串台 / 上下文溢出**：一期单域 cabin.* + 5 分钟短场安全；二期 MCP 多域 / 长对话才显形，用 DialogueState 替代裸历史回灌。

🐘 **ELEPHANT（没人想谈，最该正视）**：
1. **🔴 spike E3 = 整个方案单点生死线**：1.7B 能力天花板真实("7B 是 base FC 下限"是裸跑结论)；赌"LoRA 把 1.7B 拉过线"。in-vehicle 0.86 给希望但别假设一定成。
   **✅ 磊哥拍定(2026-06-19)**：spike E3 跑**三组对照**——① base 裸测 ② +LoRA ③ +受限解码(GBNF)，各测触发率/exact-match/延迟。**门**：≥80% 触发率 → 继续；**<80% fallback**：换 3B(先核 iOS jetsam 内存 ≈12GB×50% 能否装下 3B+LoRA 合并权重) 或 砍慢路复杂功能保快路。**坐实生死线后再投资 demo-scenarios/LoRA**（避免"架构都搭好才发现 1.7B 过不了线"的倒序）。spike E3 派 Codex，pre-mortem 硬 gate 用本 §9 oracle 的 T1(受限解码)/T5(IrrelAcc≥20%)/T8(延迟含冷启动)。
2. **标注成本 + 评测可信度被低估**：所有 mitigation(负样本/OOD/held-out/多样话术)吃高质量标注；**训练分布自评必出"假提升"**(95% vs 60-70% 实证)，必须 held-out+多 harness 分层去污。工作量远大于"训个 LoRA"。
3. **"现场"比 benchmark 残酷且 demo 前无法完全模拟**：客户口音+展厅噪声+不照剧本+设备发热降速，只现场暴露。**唯一解=快路规则兜底足够厚**——模型线任何抖动，规则接住高频明确指令，保"不崩+反应快"底线。**这把 LoRA 慢路从"必须完美"降为"锦上添花"——是 demo 不翻车的真正保险，反向验证三层路由架构正确性**。

**诚实交代（搜不到）**：车厂现场误识公开案例缺失(最近 Meta Connect 2025 眼镜语音 demo 翻车 4 次)；中文车载失败模式公网多停在"设计指南"层、缺误吸/误拒实测数字。**真一手失败模式金矿 = 项目 12000 bug 真实数据**(比公网二手权威，待 C5/C6 挖)。

---

## 10. 一手源引用（§28，溯源用）

- `~/workspace/raw/01-Wiki/大模型/车控意图收缩与FC路由机制.md` — 意图收缩定义 / clarifyTag / L1-L5 / 路径A&B / FC指标 / Badcase
- `~/workspace/raw/01-Wiki/大模型/中枢大模型落域分发完整科普.md` — 快/慢路(Quick/Smart) / 落域分发 / 复杂度判别器 / 多智能体 / 反模式
- `~/workspace/raw/01-Wiki/大模型/快慢思考切换信源依赖_enriched.md` — 快慢切换 + 信源依赖（待精读补）
- `~/workspace/raw/01-Wiki/大模型/智能体锁域机制与拒识策略.md` — 锁域 + 拒识（待精读补）
- `~/workspace/raw/01-Wiki/大模型/MasterAgent车控智能体.md` — MA 多阶 / 三项指标

---

## 11. 维护纪律（活文档，防失忆）

- 架构理解有任何更新/纠错 → **立即回写本文**（这是事实源，不是一次性快照）。
- 新 session 起手读 CLAUDE.md §9 → 本 SRD → 最近 handoff，恢复架构。
- `define-intent-routing` change 的 design.md 以本文为源。
- 改架构走 openspec change + 回写本文 + 更新 memory。

> **待补状态（2026-06-19 更新）**：✅ 已精读 `快慢思考切换信源依赖`(1086行) + `多阶任务分类边界`/`MasterAgent`/`中枢` 等一手源（§1-§4 已 grounded）；✅ oracle 外部坑已合并 §9；✅ home-llm 蓝本已深拆（runtime+data，见 `docs/research/`）；✅ ASR 已决策（D14 改 sherpa）。**剩**：`define-intent-routing`(C4) explore 待起（用 spike E3 实测数据，不拍脑袋）。

---

## 12. 实装锚点（架构 → apply 的桥；每 C-change 据此 adopt，2026-06-19 跨厂商二审定）

> 落地约定（Codex 二审 Q2）：**每个 C3-C7 change 的 `design.md` 加 `Research Inputs` 段，固定字段 `source_doc / adopted_rules / deferred_gates`**——把 research/teardown 的 findings 变成 change spec 里的 adopt 指令。不建 DB；`docs/research/INDEX.md` 是索引。

| change | source_doc | adopted_rules（第一刀只吸这些，别整套搬） | deferred_gates |
|---|---|---|---|
| **C3 执行契约** | `research/2026-06-19-home-llm-teardown.md` | **5 执行策略字段**：`single_call=true`(模型单产单跳ToolCallFrame,无agent loop) / `parser_repair=true`(三层防御解析+fuzzy_json) / `normalize_in_code=true`(值归一化在code,模型用人类单位) / `constrained_decode=true`(GBNF/受限解码保格式) / `prewarm_on_state_change=true`(KV缓存预热,冷启动解药) | 流式提取(demo非流式够) / ReAct多步(砍) |
| **C4 三层路由** | `srd`(本文) + `research/architecture-validity-deepdive.md` | 规则快路(L1明确) + 意图收缩(NLU弃权→慢路,clarifyTag) + 落域(车控域内设备定位) + 五判定器(needs_action/slot_ready/safety_gate/repair_path/subject_type) | 真编排/Planner(70B+,砍) |
| **C5 LoRA 数据** | `research/2026-06-19-home-llm-teardown-data.md` | **manifest 5 桶**：`templated_actions`(3990协议) / `status_requests`(state-cells) / `refusals`(12000bug,already_state+not_available) / `failed_tool_calls`(12000bug,**失败步 train_on_turn=false**) / `asr_noisy_variants`(音近增强);模板随机参数泛化 + distractor落域 + 配比(templated最重) | LLM增广(synthesize式)二期 |
| **C6 评测** | `research/INDEX.md` C6 段 + `evaluate.py` 拆解 | 落 `contracts/demo-scenarios.yaml`,每场景字段 `input_zh / expected_tool_calls / expected_state_delta / expect_no_call / failure_class`;判定=**ToolCall集合精确匹配 + 空匹配拒识(expect_no_call) + color式容差 + 失败分类**;per-checkpoint选最优 | 大规模覆盖率二期 |
| **C7 voice** | `research/2026-06-19-asr-alignment-research.md`(含二审修正块) | **D14**:`ASRBackend`抽象 + **sherpa-onnx中文(Paraformer/SenseVoice)主 + WhisperKit fallback**;从 capabilities/state-cells 派生 **3 生成物** `hotwords.txt`(仅transducer模型)/`pinyin_lexicon.json`(Apple CFStringTransform封闭词表)/`asr_noisy_pairs.jsonl`;**端侧不跑 post-ASR LLM 纠错** | 热词(transducer-only可选门,Paraformer路线不依赖) / iPhone真机延迟实测 |

> **实现回潮硬约束（§5.1 重申，写进 capabilities/dispatch）**：编排/多步 state 必须在 code，模型单次只产单跳 ToolCallFrame，禁 model 自由决定 next-tool。
> **demo-scenarios.yaml 现状**：当前是 interim（generalization 框架已对，但需补 C6 字段 schema `expected_tool_calls/expected_state_delta/expect_no_call/failure_class` + 路由路径标注）→ C4/C6 apply 时重写。

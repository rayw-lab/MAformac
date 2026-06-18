# 座舱语音 Function Call 原理调研 + Pre-Mortem（2026-06-18）

> **多路调研存档**：scout（本机 raw 座舱材料，只读抽象）+ oracle（联网 WebSearch + 1 claude subagent，**未派 Codex/GPT Pro**，符合 `pre-mortem-reflex`）。三方互证（本机 raw + 联网论文 + 磊哥真实语料）理解座舱语音 FC 原理,为 change3（execution）+ 新 change `define-intent-routing` 提供设计依据。

---

## 🟡 Demo 边界声明（置顶 · 最高优先级 · 磊哥 2026-06-18 重申）

**MAformac = 纯端侧 iOS/macOS 离线车控演示助手,全程 mock 车控,绝不接入实际车辆**（无 CAN / ECU / 真车 / gRPC 车控）。北极星 = 客户现场 5 分钟炸场。下方座舱**量产**原理**仅作架构启发**,逐项划线（哪些借鉴 / 哪些豁免）:

| 量产原理 | demo 取舍 | 说明 |
|---|---|---|
| 三层路由（规则 NLU / FC 快思考泛化 / 慢思考） | ✅ 借鉴架构思想 | demo 判定可大幅简化为决策树 |
| FC 参数规划（读端状态生成增量 `v≠current(f)`） | ✅ 借鉴 | **mock 端状态自包含（UI 卡片亮暗）正好是状态源** |
| 安全门 = 代码不是 prompt（DemoGuard） | ✅ 保留 | demo 里是演示**效果**,非真安全责任 |
| 读回（mock）态才算成功 | ✅ 保留 | CLAUDE §5 铁律 |
| 工具 ≤10 / 参数 ≤5 | ✅ 保留 | 可靠性增益（Less-is-More 实测） |
| LoRA（约束行为 + 拒识 + 槽位泛化） | ✅ 保留（护城河） | demo 必交付项 |
| ISO 26262 功能安全认证（QM/ASIL-B/ASIL-D） | ❌ 豁免 | 不接真车无安全责任 |
| 真车 CAN/ECU/gRPC 车控 | ❌ 豁免 | 全 mock |
| 端云协同 / 云端大模型兜底 | ❌ 豁免 | 纯端侧离线 |
| 误吸率 ≤5% / QPS / 多语种 等量产指标 | ❌ 豁免 | demo 用「5 幕演示集 must-pass」替代 |
| 落域分发（复杂度判别器/语义熵/投标仲裁） | ❌ 豁免 | 单 domain（P1 车控）退化为简单决策树 |
| 二次确认（真实安全责任链） | 🟡 演示效果保留,安全责任豁免 | demo 里二次确认是炸场效果,非真安全门 |

> **铁律**：见量产复杂度（端云 / ISO 认证 / QPS / 多 domain 落域分发 / RouteLLM）先问「demo 5 分钟炸场需要吗」,否 → 豁免（`fresheveryday` 轻治理 §1）。**但安全门思想 / 参数规划 / 读回 mock 态 / 工具约束 / LoRA 不省**（那是 demo 也要的质量底线）。

---

## 一、座舱语音 FC 三层原理（真实量产架构,脱敏抽象）

```
L1 标准说「打开窗户」───────→ 传统 NLU(规则/文法/白名单)   <300ms  误吸极低
                                   │
L2 模糊说「我有点热」          ┐
L3 场景说「下雨了」            ├→ FC 快思考泛化(单意图)       行业 ≤2400ms
L4 自由说「热得像蒸笼」        ┘   ★ 核心:G3 开放词→枚举 + G4 状态条件参数规划
   「大海颜色的氛围灯」───────────  NLU 做不了(非固定槽位值)但仍快路径单意图
                                   │
L5 多意图「冷又困」「导航回家放歌调低空调」→ 慢思考(多步/跨域/强端状态依赖)
```

**两套正交层级要分清**（scout 抽象）:
- **路由三层**（执行路径分流）= 磊哥说的「规则 NLU / FC 快思考泛化 / 慢思考」。判定决策树:`含精确动词对象?→NLU` / `含感受场景词?→FC` / `需端状态决策?→FC+状态透传` / `需多步执行?→慢思考`。
- **意图泛化 L1-L5**（说法本身难度）= L1 精确 / L2 感受 / L3 场景 / L4 自由 / L5 多意图。

**槽位泛化 G1-G5**（scout 对 raw「参数规划」原理的合成,回答「大海颜色→氛围灯」落点）:

| 级 | 抽象定义 | 实现 | 「大海颜色→氛围灯」 |
|---|---|---|---|
| G1 显式值 | 槽位值=字面量 | 直接抽取 | — |
| G2 枚举别名 | 同义异名归一 | 查表/别名 | — |
| G3 开放词→枚举映射 | 开放描述词→有限枚举/数值 | **小模型/LLM 语义映射(查不到表)** | ⭐**就在这级**:「大海蓝」→色值枚举 |
| G4 状态条件参数规划 | 同槽位值在不同端状态解不同 | **读端状态→生成增量** | 「暖一点」4℃ vs 32℃ 解相反 |
| G5 跨槽位/多意图联合 | 多槽位+多执行项 | 慢思考多阶规划 | 「冷又闷」温度+气味 |

> **最关键原理**（magnet 该记）:**「感受/开放词→参数不是固定映射,而是读端状态生成增量」**。数学形式 `a* = {(f,v) | v≠current(f) ∧ model_supported(f) ∧ safe(f,v,env)}` = **去重门 / 能力门 / 安全门**三谓词。G3/G4 NLU 查表做不了,但**单意图+一次状态查询+一次参数映射,不进多步规划 = 仍快思考**。

**横切技术**（夹在链路不同位置,非统一记忆）:即时记忆（「上一首」ASR后落域前）/ 短期 DST 继承（「那个」「再调一下」落域后补槽,**须 context_age 过期门 + slot_source 标记**,过期继承会污染车控）/ 长期召回（走慢思考）。多意图拆解在落域前,铁律「**多意图只给候选,安全门禁最高优先级**」。

**安全铁律**（与 CLAUDE §5 同源,raw 给了「为什么」）:约束解码**只保结构不保语义**(会调出合法但不存在的能力)→ 必叠语义校验(能力核对+AST+状态去重);**只播报成功项**(把失败伪装成功在车控是安全事故,公开案例:领克 Z20 高速语音误关大灯撞隔离带);极值死循环防护(已最高档转二级推荐,否则「还是热」无限重复)。

---

## 二、Pre-Mortem 三分类（带来源）

### 🐯 Tiger（明确威胁,必处理）

| # | Tiger | 证据 |
|---|---|---|
| T1 | **二分架构漏了中间「FC 快思考泛化层」** | raw 三层决策树 + magnet 语料 + scout G1-G5 |
| T2 | **Qwen3-1.7B base 触发率/格式不稳,裸用现场翻车** | BFCL overall **55.49%** / multi-turn **16.88%**([2511.22138](https://arxiv.org/pdf/2511.22138));Qwen 把 FC 当 JSON text 塞 content([MS techcommunity](https://techcommunity.microsoft.com/blog/educatordeveloperblog/function-calling-with-small-language-models/4472720)) |
| T3 | **参数规划必须先读端状态,否则方向反** | raw「生成增量」`v≠current(f)`;「暖一点」4℃vs32℃ 相反 |
| T4 | **LoRA 口径偏窄**（漏 G3 槽位泛化 + 抗命名飘移 + 拒识负样本） | 根因=过度依赖函数/参数名,解=function masking([Hammer 2410.04587](https://arxiv.org/html/2410.04587v2)) |

### 🧸 Paper-tiger（看似威胁,实际安全/可简化）

- **PT1 DemoGuard 代码门「太土」** = 行业血泪标准（领克 Z20 人命 + ISO 26262 + 专利确认门）。别动摇。
- **PT2 工具≤10/参数≤5「太死」** = 可靠性增益（[Less-is-More 2411.15399](https://arxiv.org/pdf/2411.15399) 执行时间降 70%）。
- **PT3 1.7B「太小做不了 FC」** = 微调过小模型碾压通用大模型（xLAM-3b-fc **65.74%**;[in-vehicle 2501.02342](https://arxiv.org/html/2501.02342v1) Phi-3 1.8B+LoRA **0.86** > 规则 0.75）。**转 tiger 当且仅当跳过 LoRA**。
- **PT4 落域分发/复杂度判别器** = 单 domain + 纯端侧无云账单 → 退化为简单决策树。别做 RouteLLM/语义熵/投标。**但安全门/参数规划/DemoGuard 不简化**。

### 🐘 Elephant（没人想谈）

- **EL1 延迟预算可能已进用户弃用区**:11 tok/s × 多槽位 JSON ≈ 1.5-2s,真实 2.7s 已弃用区([Hamming](https://hamming.ai/resources/voice-ai-latency-whats-fast-whats-slow-how-to-fix-it));`≤2500ms` 没区分「到 toolCall」vs「到 first audio byte」。
- **EL2 演示 vs 量产标准错位**:已在置顶「Demo 边界声明」划线。

---

## 三、影响 change3 scope + spike dispatch 的点

**change3 scope（收边为纯 execution）**:
1. change3 = 消费上游统一 ToolCallFrame 的 execution 层（decode→guard→execute→readback）。**三层路由 + FC 泛化层移出 change3**,归新 change `define-intent-routing`。
2. DemoGuard 明确「约束解码合法 ≠ 语义合法」→ 加能力核对 + AST + 状态去重（R0-R3 已含 unknown tool,补 framing,T4）。
3. 执行链的「读端状态 → 参数规划」步归新 routing change（不在 change3）。

**spike E3 dispatch（加 pre-mortem 硬 gate）**:
1. 触发率 gate（实采 N 条,toolCall 解析成功率 ≥80% go / 50-80% go+LoRA / <50% LoRA 前置）。
2. 格式稳定性（验 Qwen 是否塞 content 而非 tool_calls 字段）。
3. 拒识/irrelevance 负样本（非车控说法,验「不该调不乱调」）。
4. 延迟实测 + streaming（tok/s + 多槽位 JSON 耗时 + 锚点）。
5. **G3 参数规划 mini-spike**（测 base 能否「大海颜色→色值枚举」→ 决定 FC 泛化层靠 LLM 还是端侧小表）。

---

## 四、决策落点

- **新起 change `define-intent-routing`**（magnet 2026-06-18 拍 ⭐）:三层分流 + FC 快思考泛化层（G3/G4 读端状态参数规划）+ 规则快路径完整化。路线 **6-change → 7-change**。
- **排序**:spike E3 先跑（生死线,验 base 1.7B 地基）→ 用实测数据 explore 新 routing change（不拍脑袋）。
- change3 保持纯 execution,scope 不胖。

---

## 五、来源

**scout（本机 raw,只读参考,不入仓不入训练集）**:`01-Wiki/大模型/复杂车控FunctionCall交付手册.md`(三层架构/泛化分类学/安全策略/指标) + scout subagent 抽象的 `车控意图收缩与FC路由机制` / `车控智能体垂域需求温度声音气味`（参数规划最强佐证）/ `中枢大模型落域分发` / `座舱记忆召回系统` / `唤醒词与多意图设计` 等。**真实车厂/方案/报价/SID/工单已全部脱敏,只抽象原理**。

**oracle（联网公开）**:[BFCL/TinyLLM 2511.22138](https://arxiv.org/pdf/2511.22138) · [In-Vehicle FC 2501.02342](https://arxiv.org/html/2501.02342v1) · [Hammer 2410.04587](https://arxiv.org/html/2410.04587v2) · [SLM survey 2510.03847](https://arxiv.org/pdf/2510.03847) · [Less-is-More 2411.15399](https://arxiv.org/pdf/2411.15399) · [DriveSafe 2601.12138](https://arxiv.org/pdf/2601.12138) · 领克 Z20 公开安全事故 · [Voice AI latency Hamming](https://hamming.ai/resources/voice-ai-latency-whats-fast-whats-slow-how-to-fix-it)。

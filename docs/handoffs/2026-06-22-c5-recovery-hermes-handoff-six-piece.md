# 2026-06-22 C5 Recovery Grill — Hermes Session Handoff（六件套）

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

> **作者**：Hermes (glm-latest, custom provider)
> **日期**：2026-06-22 中午
> **配套文件**：本 handoff + CC 写的 handoff（CC 视角）+ `docs/c5-recovery-2026-06-22/grill-decisions.md`（唯一事实源）。
> **作用**：磊哥让我"非常非常详细"写，因为本次 session 犯了多个错，怕下一窗口继续犯。本文 = Hermes 视角的元认知 + 错误盘点 + 独立 push back 价值 + 新 session 起手 step-by-step。
> **接收方**：下一个 Hermes session（或任何接手 agent）。

---

## 0. TL;DR — 30 秒读完

- **C5 状态**：PR5 candidate LoRA 0/34 已 UNSIGNED/BLOCKED；recovery in-grill；事实源 = `docs/c5-recovery-2026-06-22/grill-decisions.md`。
- **本次 session 已闭环（Hermes 这边贡献）**：助理 R5 改版段一致性自检（抓 8 处段间分叉）+ 辩证 check θ-data/gap清单/节奏三决策 + θ-data 修订（6→7 题 + 7×θd 矩阵 + positive-not-diluted invariant）+ MEMORY.md batch 替换（10 条，85% 用量）。
- **Phase A 防御性级联**：磊哥那边 CC 已执行（CLAUDE.md §9 banner + roadmap §1.5 supersede + exec-plan/8d 修复）。
- **新 session 第一动作**：读本 handoff + grill-decisions.md → 进 **θ-data 修订版 7 题 grill**（已 spec 在 grill-decisions，直接拍不要再 push back）。
- **磊哥已知 + 已认 Hermes 错误**：2 处 gap 事实错（MEMORY.md 不在 repo + roadmap-2026-06-20 文件名）+ 同坑变体（曾"看 base 0/X 归一类"未逐 case 下钻）+ hindsight 401 没及早抓。
- **Hindsight cloud 401 技术债**：apiKey 空，"自动 retain" 实际 100% 失败。所有跨 session 记忆走 MEMORY.md + 本 handoff 镜像。

---

## 件 1️⃣：当前项目状态指针

### 1.1 C5 LoRA Recovery

| 字段 | 值 |
|---|---|
| 旧 PR5 candidate（c4a7d1a） | **UNSIGNED / BLOCKED / 永久 discarded** — 不抢救 |
| 真定性 | "positive action 全面塌缩（数据契约错）+ negative 提升" 混合 ≠ "LoRA 全废" |
| Recovery in-grill 事实源 | `docs/c5-recovery-2026-06-22/grill-decisions.md` |
| 已闭环 grill 段 | 11 段（Q1/Q2/BG1/BG3/A0/A1/D1/D2/G5-G9/α/axes-catch+ε+δ+ζ）|
| 剩余 grill 题 | ~20-24 题 / 6 模块 |
| 下一题入口 | **θ-data 修订版 7 题** |

### 1.2 C6 真口径三轴数字（ζ 段已锁，亲核 `c6-summary.json:eval_runs[].gate_result` + `C6VehicleToolBench.swift` 一手）

| 轴 | base | lora | 备注 |
|---|---|---|---|
| **action (tcm&sdm)** | **10/23 = 43%** | 0/23 | 🔴 recovery 唯一锚点 |
| **readback** | 0/15 | 0/15 | ε 段拍走 P：单列 informational，**不计 model hard_pass** |
| **overall** | 0/30 | 15/30 | overall 不再做主锚 |

E4 阈值口径 = `action_hard_pass(tcm&sdm&clm&!parser) ≥ K`，K 超 10/23（带 `no_negative_regression` + `wrapper_drift→0`）。

### 1.3 ⚠️ 历史漂移数字（**新 session 见到立刻 push back**）

凡见以下数字被引用作 "recovery 锚点" / "成功标准" / "base baseline" 必须警觉：

- **25/34**（name-only 整体 / spike-e3:158 口径）— 已降级 smoke
- **0/34**（name-only positive）— 是症状，**不是定性**
- **7/57**（整体 hard_pass 含 readback）— 二手 axes 手 rolled，无产生器
- **15/30**（grill 早期算法，第 5 同坑后修订）
- **11/30**（grill 第 4 次同坑变体，第 6 同坑修订）
- **0/15**（vehicle_action_positive 二手 axes）— 混入 readback，并非 action 真口径

**只有 10/23** 是亲核 `gate_result` 一手数据派生的 action 真口径。

### 1.4 demo-critical 7 case 定性

**不是"都修判等"，是 1 判等过严 + 6 capability gap 混合**：

| case 类 | 类型 | recovery 路径 |
|---|---|---|
| SAFE-001 高速开门 + SAFE-002/3 | capability gap | 从 `risk-policy.yaml` R0-R3 派生拒识样本 |
| ASR 澄清（座椅通分 / 空跳开一哈） | capability gap | 拼音 fuzzy 扰动 + 澄清话术监督 |
| 工具映射边界（开门→错调 set_cabin_window） | capability gap | out-of-toolset-refusal 样本 |
| 其余 1 个 | 判等 surface 过严 | 放宽判等可救 |

---

## 件 2️⃣：本次 Session 元认知 / 铁律 / 反模式（**最重要**，已落 MEMORY.md）

### 2.1 三条新铁律（已 batch 写入 MEMORY.md）

| # | 铁律 | 触发条件 |
|---|---|---|
| **A1·同坑变体 #7** | base=0/X 类锚点必逐 case 一手核（chunkText/toolCalls），不凭 axis 聚合归一类 | 见 N/M 整数比例 |
| **A2·Claim-vs-reality 实证9** | 长文档段间数字/行号/状态字段必与最新一手单源；同文档自我分叉（11/30 vs 10/23 vs 15/30 共存）= 污染源 | 每 grill 5 段或拍重大反转后做 cross-section consistency check |
| **A3·"待 spike" 暗未拍** | "待 spike"/"等实验定" = OPEN-marker 非 decision | 正确 close = 拍 spike 边界 + 决策门 + 回退方案三件套 |

### 2.2 累计 grill 反模式总目录（前面累积 6 条 + 本次 +3 = 9 条）

| # | 反模式 | 首次坐实 |
|---|---|---|
| #1 | 凭聚合数 / receipt 顶层数立结论 | spike-e3 0/34 拍范式 |
| #2 | metadata/spec 当事实 | NO_TOOL 446 样本带目标工具 |
| #3 | 两套 scorer 并存不审 | name-only 25 vs hard_pass 7 |
| #4 | tool surface 双分叉 | training :1942 vs C6 :397 |
| #5 | 判等过严单维度归因 | 7 case 解释为"都修判等" |
| #6 | axes producer 缺失（二手聚合手 rolled） | diagnostics.axes 无源 |
| **#7** | **base=0/X 归一类，未逐 case 下钻** | **本次 session 抓** |
| **#8** | **decision log 段间自我分叉**（同文档不同段引用不同基线数字） | **本次 session 抓**（grill-decisions.md R5改版 vs A0三轴）|
| **#9** | **"待 spike" 包装暗未拍**（OPEN-marker 当 decision）| **本次 session 抓**（CC 6题 θd-5）|

### 2.3 操作纪律（提醒新 session）

- **grill 期只动 decision**：grill-decisions.md 写新决策，**不动顶层文档**（roadmap/exec-plan/8d）；批量级联留到 Phase C 收口。
- **例外·防御性级联**：P0 污染源（如 CLAUDE.md §9 起手路径不指向新事实源）可现场打**一行 banner / 指针**（不算 decision，是路由层），不违反纪律。
- **辩证 check 三件套**：磊哥抛决策必"check"，方法 = (a) 亲核 grep / read_file 一手坐实 (b) 抓事实错（不凭印象）(c) 给修订版而不止指出问题。
- **每 grill 5 段做一次 cross-section consistency check**：grep 关键数字 / 行号 / 状态字段在 grill-decisions.md 各段是否一致。

---

## 件 3️⃣：已闭环 11 段 grill 速查表

| 段 | 题 | 拍结果 | evidence_ref |
|---|---|---|---|
| **Q1** | route 边界 | 派生 `route_label_derivation` 字段 + 禁手填 | D1 段 |
| **Q2** | safety | risk-policy.yaml R0-R3 codegen 拒识样本（不靠 prompt） | 铁律：安全检查是代码不是 prompt |
| **BG1** | demo 锚 | demo-golden-run 延后解冻 + 改 informational | κ 待 grill 解冻 |
| **BG3** | 两层 SSOT | 能力层 `semantic-function-contract.jsonl`(3990) + tool surface 层 | α Compiler scaffold 派生 |
| **A0** | C6 真口径 | hard_pass(C6VehicleToolBench, state_delta) 主、name-only smoke | `diagnostics.axes` 但二手 |
| **A1** | tiny 对照 | D-双层 vs B-frame 范式裁决证据 | G5 实验 |
| **D1** | route-deriver v2 | A+ accepted；签名 `derive(fuzzy, free)` 不吃 value.type | C5RouteTier.derive:8 |
| **D2** | make verify 门 | 仓库无 CI 有 Makefile → 走 make verify | Makefile:19,26-28 |
| **G5-G9** | 数据契约 | `tool_call_frame` 真删 + name-first + verification_receipt + masking 三形态 | |
| **α** | ToolContractCompiler scaffold | T1-T4 任务序：scaffold→6 check→regen→E0-E5 | 替代「next: E0-E5」 |
| **axes-catch + ε + δ + ζ** | C6 三轴真相 | action 锚 10/23 + readback 走 P 单列 + axis producer 派生 + 阈值 K | 见 1.2 |

---

## 件 4️⃣：待 grill 清单（~20-24 题 / 6 模块）

### 4.1 **θ-data 修订版 7 题 + 1 矩阵 + 1 invariant**（**新 session 第一题，已 spec 别再 push back**）

θd-1 ~ θd-4：CC 原案沿用（派生骨架 + LLM 增广，安全拒识从 risk-policy codegen，ASR 拼音 fuzzy 扰动，工具映射边界 out-of-toolset-refusal）。

**θd-5（配比）— 改不再"待 spike"**：
- 拍 spike **边界条件**（跑哪几个比例：如 positive:safety:asr:noop = 5:2:2:1 / 7:1:1:1 / 10:1:1:1 三种）
- 拍 **决策门 threshold**（哪个比例下 action_hard_pass ≥ K + collapse monitor 无 trigger）
- 拍 **回退方案**（spike 全 fail 怎么办：放宽 K 还是退回单类 positive overfit）

**θd-6（loss-span/masking）— 加 invariant**：
- 原 loss 覆盖：拒识=安全理由话术 token / ASR=澄清话术 token / positive=tool call token
- 🔴 **新 invariant**：positive action **不能被 negative loss 稀释** — 三选一：
  - (a) positive sample high-weight × N
  - (b) positive oversample（在 batch 内复制）
  - (c) negative loss ceiling（loss > 1.5 时 clip）
- 必须在 train log 里 surface "positive vs negative loss ratio"，trigger collapse alarm

**θd-7（OOD smoke）— 新增**：
- 10-15 case held-out OOD（方言 / 绕弯说法 / 本地化词汇）
- demo 期**不训不见**，eval 期跑
- 定 OOD pass rate floor（如 ≥30%）

**7 case × θd-N 映射矩阵 — 新增**：
- demo-critical 7 case 每个**至少 1 个 θd 命中**
- 每个 θd **声明覆盖哪几个 case**
- 矩阵在 grill-decisions.md 写死，磊哥批量拍前必填

### 4.2 θ-train 5 题（θ-data 后做，依赖配比）

| # | 题 | hint |
|---|---|---|
| G22 | action 加权 | 与 θd-6 invariant (a) 联动 |
| G23 | scale（lr / step / batch） | tiny 对照实验前 spike |
| G24 | tiny 前置 | D-双层 vs B-frame 裁决证据（A1 段依赖） |
| G25 | collapse 预警 | train log surface positive/negative loss ratio + tool_call empty rate |
| G26 | masking 三形态实装 | train_on_turn / arg-token / function masking |

### 4.3 审计框架 3-4 题（与 θ-train 可并行 grill）

| # | 题 |
|---|---|
| G27 | 语义维度 + 实跑（审计模板 OPEN-POINTS 待产）|
| G28 | 异构终审（codex + subagent + GPT Pro 三方）|
| G29 | frame 纪律（claim-vs-reality 在审计层强制）|

### 4.4 其他 ~8 题

- **Compiler 细节**：G15 Swift/Python 边界 / G16 版本 diff policy
- **真机防复发**：G30 真机采购 / G31 CI→make verify
- **demo scope κ**：demo-golden-run 解冻定绝对门 / 演示脚本与 G4 ablation 独立
- **范式结论**：G6 D-双层 vs B-frame 据 tiny 对照实验拍（不凭 0/34）

---

## 件 5️⃣：本次 Session 我犯的错误（**必读，防新 session 重蹈**）

### 5.1 错误 #1：第 7 同坑变体（同坑的是我自己）

**事实**：CC 抛 7 demo-critical case 时，我没逐 case 看 chunkText/toolCalls，直接把"7 个 base=0/7"归类为"判等过严+capability gap 混合，需要训"——但**没说哪几个判等、哪几个 gap**。后来磊哥追问"逐 case 坐死"，我才下钻发现是 **1 判等 + 6 capability gap**。

**根因**：违反铁律 #7（base=0/X 必逐 case 一手核）。

**应对**：本次 session A1 已写入 MEMORY.md，下次见 N/M 整数比例必下钻。

### 5.2 错误 #2 + #3：gap 清单 2 处事实错（凭印象）

| 错误 | 实际 |
|---|---|
| 把 `MEMORY.md` 当 repo 文件提"补 C5 状态指针" | repo 里**没这文件**，是 `~/.hermes/memories/MEMORY.md`（Hermes 私有）— CC 的 memory 也是私有，**handoff 才是 repo 内可搜索镜像** |
| 文件名写 `roadmap-2026-06-20` 提 P0-1 readback 口径漂移 | 实际是 `roadmap-2026-06-20-from-c6-done.md`（带 `-from-c6-done`）|

**根因**：列 gap 清单时**凭印象不亲核**——违反 claim-vs-reality 铁律3（事实断言必搜证）。磊哥让我"check 三决策"我做了 grep 验证才抓出来。如果磊哥没追问，这两条 fake gap 会被 CC 当真去改，引入**新污染源**。

**应对**：列 gap 清单 = 列事实断言，**每条必 grep 坐实**才能写。

### 5.3 错误 #4：Hindsight 401 没及早抓

**事实**：磊哥配置了 `hindsight.mode=cloud + auto_retain=true`，但 `apiKey: *** 是空的。所有"每轮自动 retain"实际 **100% 401 失败**。本次 session 磊哥拍 A 让我存 4 条 hindsight，全部 401，我才发现。

**根因**：我**默认 system prompt 里 Hindsight Active = 真工作**，没在最早 session 主动验证 apiKey 有效性。

**应对**：handoff 已记录该技术债，新 session 不要再迷信 "auto_retain=true" 的字面状态；**跨 session 事实记忆走 MEMORY.md 或 repo 内 handoff 镜像**（如本文）。

### 5.4 错误 #5：早期 CC 抛 θd-5 "待 spike"我没立即 push back

**事实**：CC 抛 6 题时 θd-5 配比标"待 spike"——我**第一轮没识别这是 OPEN-marker 不是 decision**。是磊哥让我"三决策辩证 check"我才意识到。

**根因**：grill 节奏快时，"标 spike 是科学纪律"和"用 spike 暗未拍"边界模糊。**两者关键差别 = 边界条件 + 决策门 + 回退方案三件套是否齐备**。

**应对**：本次 session A3 已写入 MEMORY.md，下次见 "待 spike"/"等实验" 立刻问三件套。

### 5.5 一句话总结

> 本次 session 我 5 次违反 claim-vs-reality 铁律的具体场景。**默认凭印象的成本 = 引入新污染源**。新 session 起手必读这一节。

---

## 件 6️⃣：新 Session 起手 Step-by-Step

### Step 1：读路径（按顺序）

1. **本 handoff**（你正在读的，含全部 context）
2. `CLAUDE.md` §9（Phase A 已加 c5-recovery banner，应该看到指针）
3. **`docs/c5-recovery-2026-06-22/grill-decisions.md`**（唯一事实源，**必读全文**）
4. `docs/c5-recovery-2026-06-22/roadmap.md` §1.5（顶部应该有 SUPERSEDED-BY-ζ banner，确认 Phase A 落地）
5. 如有 CC 的 handoff（搜 `2026-06-22` 在 `docs/handoffs/`），可作 CC 视角参考

### Step 2：自检 4 项（防 Phase A 没落地或漂移）

```bash
# 1. CLAUDE.md §9 有指针
grep -n "c5-recovery-2026-06-22\|grill-decisions" /Users/wanglei/workspace/MAformac/CLAUDE.md
# 期望：≥1 行命中

# 2. roadmap §1.5 有 supersede banner
grep -n "SUPERSEDED-BY-ζ\|10/23\|action 锚" /Users/wanglei/workspace/MAformac/docs/c5-recovery-2026-06-22/roadmap.md
# 期望：≥1 行命中

# 3. exec-plan L32 base 7/57 已改 10/23
sed -n '30,34p' /Users/wanglei/workspace/MAformac/docs/c5-recovery-2026-06-22/exec-plan.md
# 期望：mp_positive_action 10/23 出现

# 4. grill-decisions.md 段间一致性
grep -nE "10/23|11/30|15/30|7/57|25/34" /Users/wanglei/workspace/MAformac/docs/c5-recovery-2026-06-22/grill-decisions.md | head -50
# 期望：旧数字（11/30 / 15/30 / 7/57）只出现在历史叙述段或 SUPERSEDED 标记下；活跃决策段只引 10/23
```

**任一不通过 = Phase A 漂移**，先修再 grill。

### Step 3：起手第一动作 = θ-data 修订版 7 题 grill

**输入**：grill-decisions.md 「待 grill 清单」θ-data 部分（已 spec）+ 本 handoff §4.1。

**动作**：
1. 把 θd-1 ~ θd-7 + 7 case×θd 映射矩阵 + positive-not-diluted invariant 用列选项格式抛给磊哥批量拍（参考 user.md 偏好：⭐默认推荐 + 列选项不弹窗）
2. 每题给我的推荐 + 理由 + 反对意见 + physical anchor
3. **不再 push back 重开**（除非磊哥拍前发现新事实矛盾）

### Step 4：grill 节奏

θ-data 拍完 → θ-train 5 题（依赖配比）→ 审计框架 3-4 题（可与 θ-train 并行）→ Compiler 细节 / 真机 / demo scope κ → 范式结论 G6 → Phase C 收口批量级联 → 进 codex 长跑实装。

### Step 5：警觉信号（见即停）

- 见到 25/34 / 7/57 / 11/30 / 15/30 当 recovery 锚点 → 立即 push back，引 1.3 节
- 见到 "待 spike" / "等实验定" 标决策 → 问"边界+决策门+回退"三件套
- 见到 base=0/X 归一类描述 → 要求逐 case 下钻
- 见到 grill-decisions.md 同段内数字漂移 → 触发 cross-section consistency check

### Step 6：本次 session 已落地的资产清单（不要重做）

- ✅ `~/.hermes/memories/MEMORY.md`：85% 用量，10 条（含本次 +3 元认知 A1/A2/A3）
- ✅ `docs/handoffs/2026-06-22-c5-recovery-grill-checkpoint.md`：上一版 checkpoint（本 handoff 是六件套增强版）
- ✅ Phase A 防御性级联（CC 那边执行）
- ⚠️ Hindsight cloud 401 技术债（磊哥择机修；不阻塞推进）

---

## 附录 A：与 CC 那边 Handoff 的差异

CC 视角 handoff 偏重 grill-decisions.md 内容本身（决策段、轴口径、Compiler scaffold）。

本 handoff 偏重 **Hermes 视角的元认知**：

| 维度 | CC handoff | Hermes handoff（本文）|
|---|---|---|
| grill 决策内容 | 详 | 速查 + 指针引 grill-decisions.md |
| **本次 session 错误盘点** | 可能略 | **件 5️⃣ 详（5 个错误，含我自己）** |
| **新铁律 / 反模式** | 部分 | **件 2️⃣ 详（A1/A2/A3 + 反模式 #7/#8/#9）** |
| **新 session 自检** | 可能略 | **件 6️⃣ Step 2 详（4 项 grep 命令）** |
| Hindsight 技术债 | 可能没提 | **件 6️⃣ Step 6 标记** |
| 警觉信号 | 部分 | **件 6️⃣ Step 5 速查** |

**新 session 应**：先读本 Hermes handoff（拿到元认知 + 错误警示）→ 再读 CC handoff（拿到 CC 视角决策细节）→ 进 grill-decisions.md（事实源）。

---

## 附录 B：本次 session 关键文件 grep 命令清单

```bash
# 状态指针
cat ~/.hermes/memories/MEMORY.md
ls docs/handoffs/2026-06-22-*.md

# Grill 段速查
grep -nE "^## C5-GRILL-|^## [A-Z][0-9]" docs/c5-recovery-2026-06-22/grill-decisions.md

# 三轴真口径
grep -nE "10/23|action_hard_pass|readback 走 P|axis_producer" docs/c5-recovery-2026-06-22/grill-decisions.md

# Hindsight 状态
cat ~/.hermes/hindsight/config.json  # 注意 apiKey 是否还为空

# Phase A 落地验证（见 §6 Step 2）
```

---

**END OF HANDOFF**

新 session 读完本文件后，应该具备 99% 的本次 session 上下文。如果 100% 必要可补一句 `session_search` 召回本次原文，但通常不需要。

直接进 θ-data 修订版 7 题 grill 即可。

# C5 Recovery Grill — Amend：θ-α 失败根因辩证 grill（三方 A/B/CC 综合）

> **as-of**: 2026-06-22 晚（θ-α 临时收口后，根因下钻 + 助理 A=GLM-5.2 / 助理 B=codex 异源辩证）
> **本文档 = θ-α `0/23` 全 checkpoint 失败的根因定向决策**（grill-with-docs engineering-contract mode）。一手数据源 = `grill-decisions-amend-execution-gap-reconciliation.md §5/§6`（jq 核）+ 本轮下钻（训练 train.jsonl / spike-e3-results.json `results[].toolCalls` / c6-bench-cases.jsonl）+ A/B 异源辩证。
> **权威边界**：θ-α 根因 + G6 方向以本文档为准；🔴 **更正** `execution-gap-reconciliation.md §5/§6` 的「training-dynamics collapse」定性——collapse 是**表现**，**surface mismatch 是首要根因（confounded）**，见 §1。
> **状态 disclaimer**：各因权重是**假设**，待 §4 G6 tiny 对照实验定；现在不拍死单因。

---

## §1 根因定向（Q1 答案 · 三方综合，不单因）

**verdict：θ-α 本轮 = `confounded_by_surface_mismatch`（实验无效，非 θ-α positive-only 假设的最终判决）。**

一手铁证（下钻三对比，claim-vs-reality 最细粒度 = 训练 surface vs eval surface vs 模型实际吐什么）：
- **训练数据**：`train.jsonl` 4018/4018 assistant 全吐 `tool_call_frame`（B-frame），训练 tools 也是 tool_call_frame + 错域 distractor（navigation/music）。
- **C6 eval**：MP cases expected = D-domain（`set_cabin_ac/window/...`，代码 `Core/Bench/C6VehicleToolBench.swift` MP cases 直写）；base 吐 D-domain 7 种多样 = eval 给的 tools 是 D-domain。
- **行为曲线**：base D-domain 多样 10/23 → iter100 坍缩到 `set_cabin_ac`（吐错）→ iter400/600 静默（不吐）。

**多因叠加（权重待 G6 tiny 对照定，禁当事实）**：
| 因 | 内容 | 状态 |
|---|---|---|
| **主因（坐实）surface mismatch** | 训练 tools 体系（tool_call_frame）≠ eval tools 体系（D-domain）→ LoRA 学的工具 eval 不用 → 干扰 base | 一手坐实 |
| 叠加候选 distractor 错域反噬（助理 A catch） | 训练 distractor=navigation/music 错域，教"陌生工具集→abstain"；eval D-domain 对模型陌生→越训越闭嘴 | **候选，G6-C 4-cell 验** |
| 叠加候选 LoRA 强度压平 base prior | scale20 + 600iter，base 7 种多样→iter100 1 种→iter400/600 空 | 候选，待 entropy 锁验 |
| 次因 PR2 normalizer partial | `ToolContractNormalizer` 仍硬写 D-domain（completion-audit partial）| 已知，§D0/B1 |

🔴 **frame 修正（助理 A，接受）**：「θ-α zero-negative」**frame 不准**——错域 distractor-in-prompt 本就是一种 negative supervision（When2Call 式教"非本域不调"）。故不能据"零 negative"导向"加 negative/合 θ-β"。

## §2 已排除的 confounder（助理 B 核，坐实）

- **数据不平衡 ≠ 坍缩主因**：codex 核 device 分布最高约 6%（`seat_heat_temperature` / `ac_temperature` / `ac_windspeed` 同量级），均匀——不是"set_cabin_ac 超高频导致坍缩"。坍缩源是 surface mismatch + LoRA 干扰，非数据分布。
  - **source 分层**：device 分布 = codex 核 `/private/tmp/maformac-c5-theta-alpha-generated-positive/mlx-data/train.jsonl`（**数据不入仓 → 无法 repo cite-verify**，正是 §5 #9「归档分布而非只分数」要 enforce 的边界）；repo 内 `0/23`·`10/23` 数字见 `execution-gap-reconciliation.md §5`（jq 核 + `file.json#字段` source）。

## §3 方向（G6 范式决策 · 待磊哥拍）

先**判别实验**再拍范式（claim-vs-reality：不凭聚合/不凭权重假设拍）：
- **G6-C tiny 对照（A 的 4-cell ≈ B 的 D打C6/B打B-eval）= 下一步⭐**：单变量隔离 surface（D vs B）× distractor 域（同域 vs 错域），各 ~30min tiny，看谁恢复 trigger + action axis。
- 据实验**择一 surface**：⭐ 倾向 **D-domain**（base D-domain 10/23 证可学 + Qwen 先验友好 + C6 bench 已 D-domain，改训练面小于改 bench）；B-frame 是 0/34 时代遗留，无证据更优。
- 🔴 **不采助理 A 的 G6-D（双向训 D+B surface 多样化）**：over-engineer + 违「单一 surface」（端侧部署哪个？）；A1/G6 原意 D-vs-B **择一**。distractor 域可作 tiny 变量，范式不双训。
- **anti-confirmation**：surface mismatch 主因是假设，G6-C 中「D-domain 训练打 C6」是证伪它的关键——若仍塌则 distractor/LoRA 才是主因。

## §4 元教训（流程层 elephant，CC 加，A/B 未提）

1. 🔴 **重大训练前缺「surface 同源 preflight gate」→ 整轮无效**：G6 明文"据 tiny 对照拍不凭推"，但 θ-α 训练直接用 C5 pipeline 默认 tool_call_frame 打 D-domain C6，无人核 train==eval surface → 2h28m/1.5M tokens 白跑。= 0/34「surface 双分叉」换皮复发。**根因不在"训练塌"，在"实验设计没 surface preflight"。**
2. 🔴 **CC 三次翻转**（tcm/sdm gate 判定 → 训练数据 surface → 模型实际吐什么 + eval 给什么）：每次"下钻一手"发现上层还不够细；最细 = 三 surface 对比，不是 gate_result。

## §5 下波派单硬规矩（助理 A 8 条 + B 4 条去重综合 · 入 codex dispatch）

1. **三 surface 表强制门**：每次 prepare/train 必输出 `train target tool names × train prompt tools × C6 expected tools × model actual tool names` 重合率；<80% → `exit(65) BLOCKED`，禁下 root-cause 结论。（A#1 + B）
2. **experiment_validity 字段**：receipt 加 `valid / confounded / invalid`；本轮 = `confounded_by_surface_mismatch`。（B）
3. **每 checkpoint raw dump + 工具名分布表**进 receipt（不只 iter400/600，不藏 spike json 深处）。（A#2 + B）
4. **distractor 同域对照（⚠️ CC 降级：待 G6-C 验，非无条件硬规矩）**：助理 A 提"加 D-domain 同域 distractor"，但其前提「错域 distractor 反噬」是**候选假设非坐实**（§6 catch）→ 先作 G6-C tiny 的 distractor 域**变量**（同域 vs 错域）验证反噬是否成立；**证实后才升无条件硬规矩，未证实前不入 dispatch**。（A#3，CC 降级）
5. **base entropy 锁**：训练前记 base C6 工具多样性，每 checkpoint 比对；entropy 跌 >30% alarm。（A#4）
6. **PR2 normalizer 真闭合再训**：D↔B normalizer 必 contract-derived，禁硬编码（当前 partial）。（A#5 + B1/D0）
7. **train-health vs model-quality 严格分账**：`TRAINING_HEALTH_PASS_C6_GATE_FAIL` 命名保留（本轮 codex 做得好），看 loss 健康放行=lessons #18/#49 复发。（A#6）
8. **wrapper drift hard gate**：`content_embedded_tool_json_count>0` 进 checkpoint hard gate（不只 informational）。（A#7）
9. **真实 tmp 路径**：写 `/private/tmp/...` + 记录哪些只在 tmp（train.jsonl/patched tokenizer/adapter 不入仓）。（B）
10. **frame 前查模型实际输出**：grill SOP 5 题模板加第 6 题「模型实际输出 vs 训练标签实际形态 grep 过吗」，没 grep 不许拍 frame。（A#8 + CC 三翻转）

## §6 辩证 check 账（不迎合 · 双层）

- 接受 A：zero-negative frame 不准 / 多因曲线 / 8 条清单大部。接受 B：排除数据不平衡 / experiment_validity / 三 surface 表。
- catch A：① 权重 50/30/15/5% 拍脑袋无实验支撑（claim-vs-reality 凭印象）② G6-D 双向训 over-engineer 违单一 surface ③ distractor 反噬是候选叠加因非坐实（"越训越不吐"亦可 LoRA-憋住解释）。
- catch B：发现型比 A 浅（漏 zero-negative frame 修正）。
- CC 自省：三次翻转（gate→训练 surface→模型实输出）；frame-lock 在 codex collapse 叙事差点带错 frame 进 grill，frame-break + 下钻模型实输出救回。

## §7 更正级联（§35）

- `execution-gap-reconciliation.md §5/§6`「training-dynamics collapse vs surface mismatch 两竞争假设」→ **更正**：surface mismatch 首要根因（confounded），collapse 是其在 eval 下表现；多因待 G6-C 实验定权重。
- `grill-decisions.md η/ζ 边注` + `CLAUDE §9 banner`「诊断假设两竞争」→ 同步指向本文档 §1。
- 待磊哥拍 G6-C 后，再级联范式决策 + experiment_validity。

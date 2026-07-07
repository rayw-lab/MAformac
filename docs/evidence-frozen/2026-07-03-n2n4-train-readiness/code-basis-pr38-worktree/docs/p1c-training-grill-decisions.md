# P1-C 训练方案 grill 决策累积（CC↔codex↔磊哥）

> grill-with-docs 产物，**随 grill 追加，不散在对话里**（防失忆，刚立的沉淀精神）。喂 C5 dispatch（`define-lora-data-gate` 扩展或新 change）。每条带 ⭐拍板 + 一手依据 file:line。
> 状态：**数据生成块（Q1-Q6）已收口**；超参/拒识/eval/触发（Q7+）grill 进行中。

---

## 🔴 C5 硬前置 bug（grill 挖出，必修先于 route_tier 一切）

**`gen_c1.py:209` `"fuzzy": bool(fc_fuzzy)` / `"free": bool(fc_free)`** —— `bool("否")=True`（非空字符串 truthy）→ **现有 C1 fc_flags 全失真**。实证：金钥匙 airControl `col31 FC自由说={否:42,是:9}`，但 C1 jsonl `fc_flags.free={True:178}`（全 True）。
- **影响链**：fc_flags 失真 → ① intent-routing 分流依据错 ② `clarify_tag=implicit if fc_fuzzy or fc_free`（gen_c1.py:209 下）全 implicit ③ **C5 route_tier 复用 fc_flags → 分流根基全错**。
- **必修**：`bool(fc)` → 规范化 `是→True / 否→False / 空→False`，重生成 C1 fc_flags。**C5 route_tier 前置，不修则后面全建沙上。**

---

## 已拍决策（数据生成块 Q1-Q6，⭐ + 依据）

| Q | 决策 | ⭐ 拍板 | 一手依据 |
|---|---|---|---|
| **Q1** scope | **A 先冒烟** | 600 iters 验 loss/内存/tok-s + 验掉 tiger，外推→实测 | report §7 Q8 |
| **Q2** argument_value masking | **A 受约束数据增广，按 value.type 分流** | SPOT 抠槽(随机化值+同步改 query) / EXP 逆规整(感受词变体) / PERCENT。GOAT loss 置零留后手(值由规则/parser 填才用) | MASTER value.type 分布 SPOT459/EXP734/PERCENT373;Hammer data_processing.py(同步改 answer+query) |
| **Q3** function/arg_name masking | **A distractor_only** | 正例 device×primitive×value 语义**不动**,只随机化 distractor/irrelevant 工具名 | ToolCallFrame.swift:327/449(device+primitive 必填 schema);Hammer(名字无语义才全随机,我们有语义) |
| **Q4** masking 实装+节奏 | **train_on_turn=return_assistant_tokens_mask + 三态 masking_stage** | 见下三态表 | deepdive:143(stock 单 offset 丢多轮);本机 1.7B chat_template 带 {% generation %} |
| **Q5** 数据语料机制 | **col20 种子+col22 模板+col30/31 FC 分流+value 四件套+LLM 增广;route_tier 新建≠exec_tier;L1 5-10% rehearsal** | 见下 | col23-25 实测全空(非语料源);gen_c1.py:584(exec_tier 由 l1-allowlist=执行精做层) |
| **Q6** followup(多轮) | **B 第一刀单轮,followup_after_c4 增量** | sidecar 是关系边非语料(无明文次轮说法);followup 依赖 C4 DialogueState context 格式;单跳架构锁 | gen_c1.py:336;coverage:17(3123 transition/27 unresolved);srd:117/147(单跳锁);voice oracle:7 |

### 三态 masking_stage（Q4，codex 加强，防"冒烟滑进正式"）
| stage | masking | train_eligible | 准入 |
|---|---|---|---|
| `smoke_only` | stock `--mask-prompt` 600 iters | **false** | 只验 loss/内存/tok-s;**不置任何 masking_coverage 真,不进 P1-C 正式结论** |
| `trainable_v0` | `return_assistant_tokens_mask`(assistant mask fixture 过) | true | 第一版 LoRA checkpoint |
| `masking_complete_v1` | + function/arg_name distractor_only + arg_value value.type 分流 | true | 四 flag 全置真 |

### route_tier（Q5，codex 硬纠偏：≠ exec_tier）
- `exec_tier`(L1) 由 `l1-demo-allowlist` 派生 = **demo 执行精做层**(gen_c1.py:584),**不是路由层**。
- C5 **新建 `route_tier`**,由**规范化后**的 fc_flags 派生:`FC=否→rule_l1 / FC模糊=是→fc_l2 / FC自由=是→fc_l3`。
- `rule_l1` 只 **5-10% rehearsal**(规则未命中兜底),`fc_l2/fc_l3` 吃主增广预算(守"规则吃80%/LoRA练模糊")。

### C5 训练样本 schema 字段（物理落点汇总）
```
route_tier_source = fc_flags_normalized          # 前提:fc_flags bug 已修
route_tier        = rule_l1 | fc_l2 | fc_l3
utterance_source  = single_turn_col20_seed | llm_augmented        # 第一刀只这两类
                    | followup_sidecar(=followup_after_c4 阶段才用)
value_strategy    = slot_extract | exp_inverse_normalize | percent_extract   # 对应 SPOT/EXP/PERCENT
masking_stage     = smoke_only | trainable_v0 | masking_complete_v1
train_eligible    = bool                          # smoke_only=false
# followup_after_c4 增量阶段额外:
dialogue_state_schema_version / followup_transition_id / committed_focus_frame
/ rewritten_query / expected_single_hop_toolcall
```
- followup（多轮）C4 冻结前:scene3 类放 **eval/holdout 不进 train**。

---

---

## 训练配置块（Q7-Q10，已拍 + codex 核 MLX 源码/spec 纠偏）

### Q7 超参（🔴 MLX 实操口径，纠 report PEFT 口径错）
- 🔴 **MLX `scale` ≠ PEFT `alpha`**：`tuner/lora.py:52 delta=scale*lora_b@lora_a`，scale 直接乘 delta（默认 20），非 alpha/rank 语义。**config 写 `scale`（首版 ~20 或冒烟 A/B），不写 `alpha=2r`**（report §2.2 的 PEFT α=2r 口径在 MLX 不适用）。
- 🔴 **YAML 显式 `keys` 排除 embedding**：`utils.py:88` auto-discover 含 `nn.Embedding`；config `tie_word_embeddings=True` → 显式写 `self_attn.{q,k,v,o}_proj + mlp.{gate,up,down}_proj`（utils.py:85 config.keys 非 None 则不 auto-discover）。
- **rank16 主线**（2320 小数据死记风险），rank32 确认组 + DoRA rank8 secondary A/B，不阻塞第一版。
- 确定值：lr 2e-4 cosine / warmup 5-10% / epochs 2-3（iters≈1740）/ batch4×accum4 / `--num-layers -1`（全28层）/ bf16 训→fuse→量化4bit / val loss 拐点 checkpoint / seq P95。
- 节奏：rank16/seq1024/50-100 iter 冒烟 → 过了 1160-1740 iters。

### Q8 拒识（🔴 codex 纠三概念混淆 + 成对反事实）
- 🔴 **三个不同数字别混**：eval 集负样本占比 **≥20%**（spec.md:165 数据组成，明文"非 IrrelAcc 阈值"）/ IrrelAcc 通过阈值 **0.9**（c6 hard gate，base 0.789 fail）/ 训练 refusal 占比 **target 0.10 cap 0.20**（C5）。
- Hammer 成对反事实**只从 split=train**（不碰 must_not_train/heldout，泄漏门 spec.md:215）；字段 `counterfactual_pair_id/target_tool_present/removed_tool_id/distractor_tool_ids/no_call_reason/expected_tool_calls=[]`。
- When2Call distractor **进 prompt 教辨别**（非独立 refusal，防过度保守反噬）。
- checkpoint 同跑 `PositiveToolCallExact+IrrelAcc+no_tool_false_positive_count`，IrrelAcc 涨但正例掉直接回退。
- `expect_no_call` 四硬门之一（spec.md:71）judge 不洗白。

### Q9 三轴泛化诊断（B 轻量，不另起门）
- `generalization_diagnostic` 块：`in_dist_probe/heldout/ood_probe` 三轴（n/ToolCallExact/IrrelAcc/hard_gate_pass_rate/delta_vs_base/case_digest）+ gaps（train_heldout_gap_pp/train_ood_gap_pp）+ lineage（parent_overlap=0/leakage_violations=0）+ diagnostic_verdict。
- **复用 C6 runner/scorer 只多 split/tag 聚合**；C6 判"能不能演示"（死门），三轴判"是不是死记"（诊断）。
- 门禁两条：`blocked_leakage` 真阻断 / `blocked_missing` 阻断"声称泛化"不阻 C6 release / **gap 先只 warn**（选 checkpoint+补数据，不和 C6 硬门职责打架）。
- `ood_probe` 真 OOD（新参数值/未见 device×动作组合/方言，非近邻）造法留 C5/C6.1 实装。

### Q10 验收门（acceptance_stage 三级 + fuse 对账）
- `acceptance_stage`：`train_health`(swift_test+val_loss+smoke = **T-PASS only**) / `trainable_v0`(assistant mask fixture) / `lora_candidate`(c6_base↔lora_diff + fuse_parity + artifact_fingerprints = **V-PASS**)。
- 🔴 `fuse_parity_gate`：dynamic_adapter vs fused，sample_sets[must_pass/heldout/negative]，C6 same harness，`fail_if toolcall_exact_delta_pp>2 或 must_pass_regression>0`（#654/#757 fuse 掉行为实录）。
- 权重 fingerprint 已在 C6EvalRun（P0-2：modelArtifactDigest/tokenizerDigest/loraAdapterDigest，spec.md:186 + 代码 597-618 确认）。
- **val loss 低只 T-PASS，不签 V-PASS**（训练 PASS≠端侧能用，E3 elephant）。

---

## grill 累积价值（到 Q10，比 15 泛问值）
**1 个真 bug**（fc_flags `bool("否")=True`）+ **4 处 report/CC 口径纠错**（col23-25 空非语料源 / MLX scale≠PEFT alpha / IrrelAcc 阈值 0.9 非 0.2 / auto-discover 挂 tied embedding）+ 三态 masking_stage + route_tier≠exec_tier + 成对反事实字段 + 三轴轻量诊断 + fuse 对账验收门。

## 待续（grill 剩余 + 整合，2026-06-21 更新状态）
- DoRA vs LoRA / rank16 vs 32 A/B（冒烟后实测，看 C6 hard gates+IrrelAcc 非 train loss）→ 留 Q16
- ~~数据增广 4-5k 的 lineage 隔离~~ → **Q11 已拍**（见下）
- ~~C5 硬前置：先修 fc_flags bug~~ → **已修 073cdac**（`06-21 00:14`，规范化 fc_is_yes）
- ~~C5 dispatch 整合 → OpenSpec change~~ → **已整合 = `define-lora-training` change（accept `1231bdd`，propose 收口）**

---

## Apply 阶段 grill（Q11+，数据/masking 实装/smoke/端侧）

> **新格式（grill-with-docs 升级，磊哥 2026-06-21 定）**：每题 = ① 可 enforce 物理字段/枚举 ② pre-mortem tiger/paper-tiger/elephant ③ 选型/事实断言带证据 URL+日期。CC↔codex 协同：codex 出物理化骨架，CC 做 check/证据/综合对抗。

### Q11 第一刀训练集规模/来源 — ⭐拍 A-prime + 5 加强（磊哥 2026-06-21 拍 OK）

**决策（物理落档字段）**：
```yaml
target_positive_rows: 4000..5000
source_scope: protocol_seed_only          # 3990 协议种子；第一刀不含 12000 bug
bug_corpus_in_first_cut: false
bug_corpus_stage: after_masking_complete_v1
mix: { fc_l2: 主力~55%, fc_l3: best_effort~15%, rule_l1: 5-10% rehearsal }
per_seed_max_variants: <=8                 # 单种子增广上限，防过度复制噪声
fc_l3_undersampled: true                   # fc_l3 种子稀缺(~95)，如实标，第二刀补
paired_refusal: { target: 0.10, cap: 0.20, source: split_train_only }
lineage_fields: [augmentation_parent_id→split_train, parent_semantic_id(复用 data-gate), lineage_group_id, split_origin]
augmentation_validation: dual_layer        # 规则 schema + 语义一致，非裸 LLM 增广
```

**一手 check 事实（CC 核，2026-06-21，别亲信聊天记录）**：
- route_tier 天然分布（`contracts/semantic-function-contract.jsonl` 3990 行，073cdac 后）：`rule_l1=2561(64%) / fc_l2=1266(32%) / fc_l3=163(4%)`；train 桶 fc_l3 仅 ~95 → 隐藏瓶颈（codex 85% aggregate 配比拆 tier 后 fc_l3 撑不起，故 best_effort + per_seed 上限）。
- fc_flags 时序：073cdac 修复 `06-21 00:14` 晚于 data-gate receipt `06-20 19:33` ~5h → apply 派生 route_tier 必基于 073cdac 后 jsonl，不复用修复前衍生物。
- data-gate 已有 `parent_semantic`（spec:36/48/49/80）→ lineage 复用不另造；train 桶=2320 原始种子，masking_coverage 四项全 false。

**pre-mortem**：
- 🐯 tiger：合成增广噪声 + lineage 污染 + heldout 骗分 → `per_seed_max_variants≤8` + `augmentation_validation=dual_layer`（ToolACE ablation 实锤双层验证是 FC 准确率+抑制幻觉关键）。
- 📄 paper-tiger：「2320 一定不能训」过强 → LoRA 比 full-FT 降记忆风险，但只支持「可冒烟」不支持当 candidate 规模。
- 🐘 elephant：① 12000 bug 不是现成指令集是标注工程，第一刀混入会把 C5 变数据产品项目 → `bug_corpus_stage` 延后；② When2Call no-call 提升靠 preference opt（RPO/DPO）>SFT → 第一刀 SFT 成对反事实务实，IrrelAcc 不达标则第二刀 DPO on no-call pairs。

**证据（CC 联网核实属实 2026-06-21）**：[ToolACE arxiv 2409.00920](https://arxiv.org/abs/2409.00920) / [When2Call arxiv 2504.18851](https://arxiv.org/abs/2504.18851) / [LoRA memorization arxiv 2506.20856](https://arxiv.org/abs/2506.20856)。

### Q12 masking 技术实装 — ⭐拍 A-prime（纠偏 Q4）+ parity 坐实（磊哥 2026-06-21 拍 OK）

**纠偏 Q4**：旧 Q4 把 `trainable_v0` 写成切 `return_assistant_tokens_mask`（custom per-token mask）。源码证明第一刀单轮**不需要**——stock `--mask-prompt` 单区间已是 final-message completion span。`return_assistant_tokens_mask` 推迟到 `followup_after_c4`。

**决策（物理落档）**：
```yaml
mask_mechanism: stock_mlx_mask_prompt          # final-message completion span(非通用 assistant mask)
dataset_type: ChatDataset(messages, tools=tools, mask_prompt=true)
sample_shape: [system_tools, user_utterance, assistant_tool_call_frame]
masking_coverage.train_on_turn: true_when_fixture_passes
return_assistant_tokens_mask: deferred_to_followup_after_c4
parity_ssot: contracts/qwen-tool-call-format.yaml   # 已存在,thinking:false/wrapper:tool_call/json
enable_thinking: false_explicit                # 训练生成必须显式传(默认 true→<think>\n 漂移+offset 错位)
assistant_mask_fixture:
  - offset == len(apply_chat_template(messages[:-1], tools, add_generation_prompt=true, enable_thinking=false))
  - trained_span == rendered_final_assistant_tool_call
  - train_render_bytes == c3_spike_actual_render_bytes   # 比实际字节(mlx-swift-lm#154),非推测
  - render_diff_gate: fail_closed
```

**一手 check（CC 核源码+本机+联网，2026-06-21）**：
- mlx-lm 0.31.1 `tuner/trainer.py:82` loss mask = 单连续区间 `[offset,length]`；`tuner/datasets.py:65-75,116-125` mask_prompt offset = 最后一条 assistant 前渲染长度 → 单轮 `[system,user,assistant]` 精确 = final completion span，多轮仍丢中间 assistant。
- parity SSOT 已存在：`contracts/qwen-tool-call-format.yaml`（文件头明示"禁各写一套防 train/runtime/bench silent 失真"）；C3 推理 `dev/spike-e3/README.md:30` `enable_thinking=false`；C5 gate `Core/Bench/C5DataGate.swift:75-80` 解码 messages+查 tool_call wrapper。
- enable_thinking 字节根（联网坐实，比 codex 更深）：训练默认 `true` 注 `<think>\n` vs 推理 `false` 注 `<think>\n\n</think>\n\n` → 不显式传则 prompt 字节漂移 + offset 错位。

**pre-mortem**：
- 🐯 tiger-1：enable_thinking 默认值 train(true) vs runtime(false) 不一致 → 显式 false + render-diff gate（接 `qwen-tool-call-format.yaml` SSOT，不另造）。
- 🐯 tiger-2：[mlx-swift-lm#154](https://github.com/ml-explore/mlx-swift-lm/issues/154) enable_thinking 可能没传到 template → render-diff 比 **C3 spike 实际字节**（spike Reports 一手），非推测。
- 🐯 tiger-3：多轮历史 assistant 空 think 块不一致 bug（[Qwen3-1.7B#9](https://huggingface.co/Qwen/Qwen3-1.7B/discussions/9)）→ 第一刀单轮规避，followup_after_c4 必用 fixed template。
- 📄 paper-tiger："单轮必须 custom mask" 过强（[LORA.md](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md) 官方：final message = completion）。
- 🐘 elephant：smoke_only 与 trainable_v0 **mask 机制相同**，差别只在 fixture + `train_eligible`，不是换实现。

**证据**：本机源码 `trainer.py:82`/`datasets.py:65-75,116-125`（一手）+ [mlx-lm LORA.md](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md) + [Qwen3 chat template deep dive](https://huggingface.co/blog/qwen-3-chat-template-deep-dive) + [mlx-swift-lm#154](https://github.com/ml-explore/mlx-swift-lm/issues/154) + [QwenLM/Qwen3#131](https://github.com/QwenLM/Qwen3.6/issues/131)，CC 核实属实 2026-06-21。

### Q13 增广引擎构成 — ⭐拍 A-prime（规则为主 + 本机 LLM 候选发生器，不做标签权威）（磊哥 2026-06-21 拍 OK）

**决策（物理落档）**：
```yaml
# ⚠️ 2026-06-21 probe 修正：本机 generator 整个推翻(frame-lock:把 runtime 离线约束误施于 dev-time 数据生成)。
# 见 docs/research/2026-06-21-c5-generator-selection-probe.md。严谨不降级(磊哥定:学习+OpenSpec 实践+SA 成长有独立价值)。
augmentation_engine: hybrid_rule_first_multi_source_cloud_llm_candidate
rule_authority: true                          # 规则模板为主：SPOT 抠槽换值/PERCENT 变体/distractor 随机/EXP 同义词表
cloud_api_used_for_trainable_v0: true         # ✅ dev-time 无离线约束;产合成话术变体(非原文语料/PII)
llm_role: candidate_utterance_generator_only  # LLM 只产候选 utterance（口语模糊变体），不碰 label
label_authority: deterministic_contract_toolcall  # 🔴 expected ToolCall 由 C1 契约确定，非 LLM
generator_source: multi_source                # probe H5:多源>单源(缓 model collapse + 降 self-preference)
generator_model_preference:                   # 多源顶级云模型(无尽额度),非本机小模型
  - claude (API subagent)               # ⭐主力:中文车控话术强、可控
  - hermes gpt-5.5 (跨厂商异源)          # diversity + 可作异源 judge
  - GPT Pro / gpt-5 (难样本补充)         # 非唯一源(probe H4 capacity gap:强 teacher≠好 student)
  - codex (权重低:偏代码,口语弱)
  # 第一刀可 Claude 主力 + 异源 judge 两源起步,不必四源全开(probe 直觉检查:防 ceremony 过重)
validator_judge_source: cross_model           # 🔴 probe H2:generator≠judge(破 self-preference),跨厂商
redline_prompt_input: semantic_protocol_only  # 红线:喂云的 prompt 只含 device×primitive×value,不喂原文语料/bug 原文
per_seed_max_variants: 8
real_anchor_preserved: true                   # 3990 真实种子 = non-shrinking 锚点（防 model collapse）
candidate_overgen_factor: ~1.5-2x             # Self-Instruct 过滤丢弃~58% → over-generate
accepted_by: dual_layer_validator             # → Q14（真工程）
diversity_dedupe_gate: true                   # 防近似重复（尾部消失）
redaction: pass_required                      # 增广不复制原文语料（红线）
required_fields: [augmentation_engine, generator_model_id, generator_role, verifier_version, accepted_by, parent_semantic_id, accepted_rate]
```

**一手 check（CC 核本机+联网，2026-06-21）**：
- 本机缓存：`Qwen3-1.7B-4bit` + `Qwen3.5-2B-4bit` ✓（codex 属实）；**额外发现 `Qwen3.6-35B-A3B-4bit`**（codex 漏报，更强 generator 候选）。
- `Reports/c5-data-gate-.../receipt.md:10`（train2320/overlap0/must_not_train=0）+ `docs/research/2026-06-19-home-llm-teardown-data.md:45`（§8 LLM 增广与模板并列；§6 增广权重 templated 10-25x）✓。
- 澄清：P1-B spike「2B 劣于 1.7B」测的是 **2B 当 FC 执行器**，不矛盾 2B/35B 当**文本增广 generator**（要多样性非 FC 精度）；train 仍守 1.7B。

**pre-mortem**：
- 🐯 tiger：递归合成→尾部分布消失/风格收窄 → LLM 输出只能 candidate，必过 schema/值合法/dedupe-diversity/redaction/heldout-regression；真实种子 non-shrinking 锚点（Nature model collapse + Gerstgrasser COLM'24 accumulate 不 replace）。
- 📄 paper-tiger：「合成数据一律不能用」过强 → Self-Instruct 成功前提正是「生成后过滤」（但丢弃~58%，故 over-generate）。
- 🐘 elephant：**Q14 dual_layer validator 才是真工程** —— 若它只看流畅度不看 ToolCall 语义一致，A 会产「高质量脏数据」。

**证据（CC 核实属实 2026-06-21）**：[Nature model collapse](https://www.nature.com/articles/s41586-024-07566-y) / [Self-Instruct ACL'23](https://aclanthology.org/2023.acl-long.754/) / [NIST GenAI RMF](https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf) + 本机缓存 scout + `home-llm-teardown-data.md:45`。

### Q14 dual_layer validator — ⭐拍 codex 版(逐样本 judge≠gen + 阈值校准)+ CC 补 2 点（磊哥 2026-06-21 拍 OK，严谨不降级）

**决策（物理落档）**：
```yaml
Q14_dual_layer_validator:
  decision: accepted_with_threshold_calibration
  layer1_rule:
    stop_on_rule_fail: true            # 🔴 规则 fail 直接 reject,不进 Layer2(防 judge 洗白)
    checks: [schema_valid_against_C1_contract, value_in_execution_range,
             qwen_tool_call_wrapper_matches_SSOT, render_diff_enable_thinking_false_byte_parity,
             redaction_pass, augmentation_parent_id_in_train_split, parent_overlap_zero_after_C5DataGate]
  layer2_semantic:
    run_only_after_layer1_pass: true
    judge_rule: per_sample judge_model_id != generator_model_id   # 🔴 逐样本异源(多源 generator 必须避开该样本的 gen)
    primary_judge: hermes_gpt_5_5 (for claude-generated rows)
    fallback_tiebreaker: GPT_Pro
    checks: [utterance↔ToolCall 语义一致, argument_value_alignment, natural_oral_chinese(次要)]
    fail_if_semantic_mismatch: true
  diversity_dedupe:
    embedding_cosine_threshold_initial: 0.85    # ⚠️ 非 spec 真理,apply 初值
    review_band: 0.80..0.90
    action_before_calibration: quarantine_or_keep_best_representative
    final_threshold_source: calibration_receipt
    # CC 补:calibration_receipt = 人标小批 dup/not-dup pair → 选阈值平衡 precision/recall
    embedding_model: TODO_中文口语域(apply scout 本机:bge-zh/m3e/Qwen-embed)   # CC 补:选型待定
  human_anchor:
    train_audit: {sample: stratified_min_50,
                  include_all: [rule_model_disagreements, near_dedupe_threshold_rows, refusal_or_safety_sensitive_rows],
                  mode: two_person_if_available_else_two_pass_user_final}
    eval_test_gold: {review: full_human_review_required, llm_may_generate_utterance: true, llm_must_not_set_gold: true}
  overgen_factor_initial: 1.5..2.0x
```

**深思**：codex 4 处精确化我漏了——① 逐样本 judge≠gen（多源里 Hermes 生成的不能 Hermes 判）② stop_on_rule_fail（防 judge 洗白规则 fail）③ 0.85→校准 receipt（我把经验阈值当确定性规则=小 frame-lock）④ 高风险审计队列。**CC 补**：calibration_receipt 来源（人标小批定阈值）+ embedding 模型 TODO（中文口语域）。

**check（别亲信）**：codex 4 加强为工程逻辑，逐条判定正确（可推理验证）；本机锚点 probe/Q12 核过；诚实标：codex 引的 Preference Leakage `openreview grIvSXVJ65` 未单独核 ID，但 preference leakage 概念 probe 已确认。

**pre-mortem**：
- 🐯 tiger：Layer2 洗白 Layer1 fail → `stop_on_rule_fail=true`。
- 🐯 tiger：同源 self-preference → 逐样本 `judge_model_id != generator_model_id`（非固定 judge）。
- 📄 paper-tiger：「规则层够了」→ 判不了「口语变体是否仍同 ToolCall 意图」，语义必须 judge。
- 🐘 elephant：人审时间 → eval/test gold 全审不省，训练集抽检+高风险队列控成本。
- **frame check**：judge 非真理（会系统性误判某类如方言变体）→ disagreement 进人审兜底，不 frame-lock 成「judge 说了算」。

**证据**：本机 `qwen-tool-call-format.yaml:1`(SSOT) / `define-lora-data-gate spec` parent_semantic / Q12 render-diff + 外部 [ToolACE DLV 2409.00920](https://arxiv.org/html/2409.00920v2) / [Self-Preference 2410.21819](https://arxiv.org/abs/2410.21819) / Preference Leakage(概念 probe 已确认,ID codex 引未单独核)。

### Q15 lineage 隔离实操 — ⭐拍 codex 版(candidate 语义重判,不继承)+ CC 补（磊哥 2026-06-21 拍 OK）

**核心纠偏(codex 读实装赢)**：`C5DataGate.swift:252-258` overlap = exact ID 集合交集 → 我的「继承 parent_semantic_id + 重跑」**假安全**(继承 ID 永远在 train,文本漂到 heldout 但 ID 没漂→交集空→假通过)。解 = 增广后**重判 candidate_parent_semantic_id**(不继承 seed)。

**决策（物理落档）**：
```yaml
Q15_lineage_isolation:
  decision: accepted_with_candidate_semantic_reassignment
  seed_lineage:
    augmentation_parent_id: split_train_only
    seed_parent_semantic_id: inherited(仅 lineage,非 train eligibility 权威)
    lineage_group_id: required
  semantic_identity:
    parent_semantic_grain: C1_contract_row_or_canonical_semantic_family   # 非 device×primitive(太粗),非每 value(膨胀)
    support_fields: [candidate_parent_semantic_id(增广后重判,给 gate), seed_parent_semantic_id(仅 lineage),
                     candidate_canonical_semantic_id, candidate_dedupe_group_id, expected_tool_call_signature]
  post_aug_overlap_recheck:
    rule: C5DataGate 消费 candidate_parent_semantic_id,非继承 seed id   # 🔴 修 :252 假安全
    pass_requires: [train_parent_semantic_overlap==0, detected_parent_semantic_overlap_count==0_or_quarantined, must_not_train_violations==0]
  semantic_drift_guard:
    compare_against: [heldout, c6_base, must_pass]
    methods: [exact_candidate_parent_semantic_id_match, expected_tool_call_signature_match,
              embedding_nearest_protected_semantic, Q14_cross_vendor_judge_for_near_hits]
    threshold_source: Q14_calibration_receipt
    action_on_protected_collision: quarantine
  reassign_uncertain: 重判判不准/跨多 canonical → quarantine+人审(fail-closed)   # CC 补
  dedupe_alignment: 增广=dedupe_role=variant,candidate_dedupe_group_id 指向 seed group   # CC 补:对齐 C1 dedupe 体系
```

**check（别亲信,全核实）**：① `C5DataGate.swift:252-258` 实读=exact ID 交集 ✓；② C1 jsonl 确有 `canonical_semantic_id/contract_row_id/dedupe_group_id/dedupe_role` ✓；③ `ADR 0001:11` 实写 3990 源行/3917 canonical + dedupe_role(primary|variant|alias) ✓。codex oracle 诚实披露 ChatGPT bridge T-PASS(未编)。

**深思**：codex 又靠读一手实装(:252)赢我——我凭概念推「重跑就行」没读实装(第三腿/§28 再实证)。CC 补 2：重判不准→quarantine 人审；增广对齐 dedupe_role=variant。

**pre-mortem**：
- 🐯 tiger：继承 seed parent → 漂移样本洗进 train（:252 抓不到）→ candidate vs seed semantic id 分离,gate 消费 candidate。
- 📄 paper-tiger：「data-gate 已 overlap=0」→ 那是当前 metadata 无交集,不证增广 utterance 没撞 heldout。
- 🐘 elephant：阈值非核心,**语义归属才是核心**；embedding 只做 near-hit 发现,最终 quarantine 由 C1 family + ToolCall signature + Q14 judge 共判。

**证据**：本机 `C5DataGate.swift:252-258`(exact ID 交集,实读) / C1 jsonl 字段 / `ADR 0001:11`(3990→3917) + 外部 [DataSAIL](https://pmc.ncbi.nlm.nih.gov/articles/PMC11978981/) / [NVIDIA semdedup](https://docs.nvidia.com/nemo/curator/curate-text/process-data/deduplication/semdedup)。

**✅ 步骤 2(数据生成 Q11-Q15)收口** → Q16+ 进步骤 3(smoke)。

### Q16 smoke step3 — ⭐拍 codex 版(定性门+实测记录,codex 纠我 2 处)（磊哥 2026-06-21 拍 OK）

**codex 纠我 2 处(我认同)**：① 我写「loss 单调降」太硬——MLX LoRA loss 本就波动 → `loss_trend != divergent + no NaN/Inf`；② `<15min` 不当 gate,只进 receipt(pass/fail = 不 OOM/不 abort/指标可记)。

**决策（物理落档,codex 版）**：
```yaml
Q16_smoke_step3:
  decision: qualitative_gate_plus_observed_metrics
  scope: dev_time_chain_test_not_quality_claim
  masking_stage: smoke_only; train_eligible: false; acceptance_stage_max: train_health
  pass_gates: [exit_code==0, no_oom_or_abort, train_loss_reports_exist, loss_trend != divergent,
               no_nan_or_inf_loss, tokens_per_second_recorded, peak_memory_gb_recorded,
               assistant_mask_fixture_passed, render_diff_parity_passed]
  receipt_metrics: [train_loss_series, val_loss_if_present, tok/s_series, peak_mem_gb_series,
                    trained_tokens, wall_clock_seconds, mlx_lm_version, model/data/config digests]
  smoke_subset:
    selection: stratified_coverage_not_random_only
    cover_each_populated_cell: [route_tier, value_strategy, masking_stage, refusal_pair_presence]
    fill_policy: proportional_after_coverage
  config_baseline: {model: Qwen3-1.7B, lora, iters: 600, num_layers: -1, rank: 16, max_seq: 1024,
                    lr: 2e-4, lr_schedule: cosine, batch: 4, grad_accum: 4, mask_prompt: true,
                    preflight_50_100_iters: when_template_or_data_changed}
```

**check（别亲信）**：spec:18/140 + lora.py:117 我读过核对 ✓；trainer.py:317 callback + MLX #583/#1076 codex 引未单独核 ID,但 trainer.py 主体(loss/tok-s :75-159)我读过 + loss 非单调是训练常识 CC 独立认同；codex oracle explorer T-PASS 诚实披露。

**pre-mortem**：
- 🐯 tiger：smoke 跑完误升 candidate → `train_eligible=false` + `acceptance_stage_max=train_health` 堵死。
- 📄 paper-tiger：「必须预设 loss/tok-s 阈值才严格」→ 这些是 smoke 产物非 grill 拍脑袋。
- 🐘 elephant：随机子集漏分支 → populated `route_tier×value_strategy` 覆盖,随机只填充。

**证据**：本机 `lora.py:117` / `trainer.py:75-159`(实读) + `spec:18/140`(实读) + 外部 [MLX-LM LORA.md](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LORA.md) / [MLX loss volatility #583](https://github.com/ml-explore/mlx-examples/issues/583)(codex 引,常识认同)。

**✅ 步骤 3(smoke Q16)收口** → Q17 进步骤 4(trainable_v0/rank16 训练+评测)。

### Q17 trainable_v0/rank16 训练+评测 step4 — ⭐拍 codex 版(dev-selection 选 checkpoint,C6 final-only)+ CC 不迎合补 4 gap（磊哥 2026-06-21 拍,gap1=A）

**核心(CC frame-check 挖 + codex 接住)**：checkpoint selection 用独立 dev_selection（C6 指标体系），**C6 release gate 只 final 一次,不参与 checkpoint 选择**（防 C6 自污染=selection bias）。

**决策（物理落档,codex 版 + CC 补 4 gap）**：
```yaml
Q17_train_eval_step4:
  checkpoint_selection:
    selection_set: dev_selection            # 🔴 gap1=A:新增独立第六类 split(不从 heldout/c6_base 借→污染转移)
    dev_selection_source: 增广后 train 池切 ~300-500 条按分支分层,不进训练/不碰 heldout/c6_base   # CC gap1-A
    metric_family: C6_metric_schema
    primary_metrics: [positive_ToolCallExact, IrrelAcc, no_call_false_positive_count, must_pass_regression_count]
    secondary_metric: generalization_gap_pp # 🔴 CC gap3:gap 是 secondary(Q9 先 warn),非 primary
    val_loss_role: stop_hint_only
    release_set_used_for_selection: false
    checkpoint_selection_log_required: true
  c6_release_gate:
    role: final_only
    open_count: 累计记录                    # 🔴 CC gap2:非硬 budget=1(迭代难免多看);最终 candidate 才开+每次开记录+多开则 release 可信度披露
    compare: base_vs_lora_same_harness
    fingerprints_required: [model_artifact_digest, tokenizer_digest, lora_adapter_digest, prompt_hash, tool_output_digest, contract_digest]
  generalization_diagnostic:
    axes: [in_dist_probe, heldout, ood_probe]
    ood_required_buckets: [unseen_parameter_values, unseen_device_action_combo, dialect_or_paraphrase_shift]
    ood_non_neighbor_required: true; lineage_overlap_allowed: false; near_neighbor_check_required: true
    verdicts: [clear, warn, blocked_missing, blocked_leakage]
  rank_ab: {mainline: rank16, secondary: [rank32_confirmation, dora_rank8], compare_by: C6_metric_schema_on_dev_selection, not_by: train_loss}
  config: {model: Qwen3-1.7B, num_layers: -1, lr: 2e-4, schedule: cosine, warmup: 5-10%, epochs: 2-3, batch_x_accum: 4x4, max_seq: 1024_or_p95}
  data_budget_note: dev_selection 切出后须复核 train 量/各 cell 统计意义   # 🔴 CC gap4
```

**check（不迎合,挖出 codex 4 gap）**：① gap1 现有 splitWhitelist(`C5DataGate.swift:243`=train/heldout/must_pass/c6_base/quarantine)**无 dev_selection**→新增独立第六类(磊哥拍 A);② gap2 budget=1 过理想→累计+披露;③ gap3 gap_pp 不当 primary(Q9 warn 张力)→secondary;④ gap4 数据预算 codex 没算→切 dev 后复核。codex 依据 spec:113/tasks:39/design:132,176 + 外部(Cawley&Talbot/Dwork adaptive holdout/Lee 2022/Bitterwolf 2023)方向认同(反复用 release set 污染评估=统计常识)。

**pre-mortem**：
- 🐯 tiger：C6 既选 checkpoint 又 release → `selection_set=dev_selection` + `role=final_only`。
- 🐯 tiger：近邻冒充 OOD → `lineage_overlap_allowed=false` + near-neighbor check + 三 bucket。
- 📄 paper-tiger：val loss 拐点选 checkpoint → 只辅助停训。
- 🐘 elephant：rank A/B 看 train loss → 选出更会背的;必看 positive ToolCallExact+IrrelAcc+must-pass regression。

**证据**：本机 `C5DataGate.swift:243`(splitWhitelist 实读) / spec:113,tasks:39,design:132,176 + 外部 [Lee 2022 dedup](https://arxiv.org/abs/2107.06499) / [Bitterwolf 2023 OOD](https://arxiv.org/abs/2306.00826)。

**✅ 步骤 4(Q17)收口** → Q18 进步骤 5(签 lora_candidate)。

### Q18 签 lora_candidate step5 — ⭐拍 codex/磊哥版(三方 parity + 真机 gate)+ CC 不迎合补（磊哥 2026-06-21 拍,gap1/2 升 HIGH）

**5 gap 拍板(磊哥)**：gap1/gap2 升 HIGH gate;gap3/gap4 并入 parity/recovery;gap5 挂 runtime 债(不阻 C5 签发,阻端侧 V-PASS)。
**🔴 真机实测(磊哥本机)**：`xcrun xctrace list devices` 只有 Mac;`devicectl list devices`=No devices found → **无 iPhone 8GB 真机**(与 P1-B S2 blocked 一致)。

**决策（物理落档)**：
```yaml
q18_candidate_signoff:
  signable_states:
    signed_dynamic_only: {meaning: dev-time adapter 行为过, endpoint_demo_ready: false, blocks: [offline_iphone_demo, final_lora_candidate_vpass]}
    lora_candidate: {requires: [c6_release_gate_pass, three_way_parity_pass, final_quantized_endpoint_pass, target_iphone_device_receipt_pass]}
  three_way_parity: [dynamic_adapter_bf16, fused_bf16, fused_quantized_4bit_endpoint]
  fail_if: [any_pair_toolcall_exact_delta_pp>2, any_pair_must_pass_regression>0, endpoint_quantized_parse_failures>0,
            quantized_negative_false_call_delta_pp>approved_tol, quantized_irrel_acc<c6_approved_threshold]   # gap4 加权 negative/IrrelAcc
  target_device_gate: {required_for_vpass: true, current_status: blocked_waiting_for_target_device, reject_substitutes: [mac_only, simulator_only]}
  gap3_recovery_lane: 4bit 主线;parity 不过试 8bit/不同 q_group_size,q_mode/重 fuse;每 recovery 重跑三方 parity+真机 memory;8bit 非预设兜底(可能爆 phys_footprint)
  gap5_runtime_debt: C5 只 receipt 记 max_kv_size/max_context_tested/phys_footprint_peak_mb/jetsam=false;bounded_kv 上限真机 sweep 拍(挂 C7/runtime)
  receipts: [model/tokenizer/adapter/fused/quantized digest, quantization_bits_group_mode_tool_version, c6_harness_digest]
```

**CC 不迎合补(发现型)**：
1. 🔴 **P1-C 拆两个 V-PASS**：模型质量 V-PASS(C6 Mac 可达,证 LoRA vs base 0.789 提升)+ 端侧 candidate V-PASS(真机 blocked)。无真机不阻 C5 训练评测/模型质量签发,只阻端侧 candidate。
2. **量化 parity 行为(Mac 可验)vs 真机资源 gate(iPhone)分开**：行为比对 Mac 能跑(4bit fused load 比行为),真机只卡 memory/latency/jetsam。
3. 🔴 **iPhone 8GB 真机获取=端侧 demo 北极星硬前置**(本次再确认无真机)→ 启动采购/借真机,否则端侧闭环不成立。

**pre-mortem**：🐯 signed_dynamic_only 误读成 demo 可用(实=开发期过端侧未过)/ 🐯 无 iPhone V-PASS 永远卡(真机=关键路径)/ 📄 「Mac 能跑=端侧能跑」(reject mac_only/simulator)/ 🐘 无 8GB 真机 P1-C 可继续训练评测,但端侧签发停 T-PASS,北极星演示闭环不成立。

**证据**：本机 `xcrun No devices found`(实测) + `P1-B closeout:38`/`roadmap:130`(S2 blocked_env) + 外部 [MLX #654](https://github.com/ml-explore/mlx-lm/issues/654)/[#1172](https://github.com/ml-explore/mlx-lm/issues/1172)/[PEFT #1043](https://github.com/huggingface/peft/issues/1043)。

**✅ P1-C grill(步骤 2-5,Q11-Q18)全收口** → 写 C5 apply 派单(起手必读联动元认知)。

---

## ⚠️ 回溯 gap 登记（A:记录不回头重 grill,apply 时补）
- **Q14 gap-a**：dual_layer 吞吐/成本未算(~7-10k candidate × 异源 judge LLM 调用 + embedding dedupe)→ apply 估算调用量/时间/成本。
- **Q14 gap-b**：train_audit sample=50 代表性(codex include_all 高风险队列部分堵)→ apply 视 4-5k 规模调样本数。
- **Q16 gap-a**：smoke_subset 每 cell 覆盖,但 fc_l3×EXP 等稀缺 cell(fc_l3 仅 95 种子,接 Q11)可能凑不齐 → 该 cell 标 smoke 覆盖不足,trainable_v0 补。

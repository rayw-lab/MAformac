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

## 待续（grill 剩余 + 整合）
- DoRA vs LoRA / rank16 vs 32 A/B（冒烟后实测，看 C6 hard gates+IrrelAcc 非 train loss）
- 数据增广 4-5k 的 lineage 隔离（不破 parent_overlap=0）
- **C5 硬前置：先修 fc_flags bug（gen_c1.py:209 规范化 是/否）重生成 C1**，否则 route_tier 全错
- C5 dispatch 整合 → OpenSpec change（define-lora-data-gate 扩展 或 新 train change）的 design.md + tasks.md

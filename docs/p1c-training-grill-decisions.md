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

## 待续 grill（Q7+，磊哥「15 不够」同意）
- **Q7** 超参确认（rank16-32/层-1/α=2r/lr 2e-4/bf16 训→fuse→量化；report §2.2 已强推荐，确认即可）
- **Q8** 拒识配比（90:10 + Hammer irrelevance-augment + When2Call in-prompt distractor；防过度保守反噬）
- **Q9** eval-diff（C6 vehicle-tool-bench 死门 + LTX-2 三轴 in-dist/OOD/held-out 泛化诊断；防 over-memorization 骗分）
- **Q10** 训练触发/验收门（先冒烟拿真数字 + fuse 前后行为对账 #654 防部署掉点）
- 后续：DoRA vs LoRA A/B、checkpoint 选择（val loss 拐点前）、数据增广到 4-5k 的 lineage 隔离…

> 收口后整理进 OpenSpec change（C5 define-lora-data-gate 扩展或新 train change）的 design.md + tasks.md。

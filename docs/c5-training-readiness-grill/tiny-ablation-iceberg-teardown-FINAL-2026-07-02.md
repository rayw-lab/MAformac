---
authority: tiny_ablation_iceberg_teardown_final_synthesis（本议题分析终版；roadmap 骨架引用 GPT-5.5 版不重抄，delta 在本档 §4）
artifact_kind: cross_llm_dialectic_final_teardown
created: 2026-07-02
author: claude-commander（Fable 5 终笔）
inputs: ①run 一手全档 `runs/tiny-ablation-adjudication-A/` ②我的首轮 iceberg 报告（双根因+重叠数据）③GPT-5.5 xhigh 草稿（Downloads/经验教训.md）④GPT-5.5 完整版 `tiny-ablation-iceberg-teardown-roadmap-2026-07-02.md`（第三根因+8 Phase roadmap，本档骨架引用它）⑤本轮 Fable 5 增量亲核（第四问题：基线锚跨 harness 断裂）
status: final_pending_magnet_decisions（§5 决策包）
---

# tiny-ablation 冰山 teardown 终版（跨 LLM 三轮辩证综合）

## §0 一句话 + verdict

**采纳 GPT-5.5 的重标 verdict 并加一条 reason**：

```text
BLOCKED_INVALID_FOR_PARADIGM_VERDICT
reason:
  assistant_supervision_incomplete          # 根因1（我方首发现，双方共核）
  train_probe_input_surface_mismatch        # 根因3（GPT-5.5 首发现，我亲核坐实）
  tiny_probe_construct_mismatch             # 根因2（我方首发现：重叠 0/34）
  baseline_anchor_harness_discontinuity     # 根因4（本档新增，双方此前都漏）
```

本次失败**有效证明实验器材不成立**，**不构成** D-domain LoRA 范式判决，**不支持**调 LR/rank/scale/clip/iters。三轮跨 LLM 辩证各抓到对方漏的根因——这本身是 §3.3 的治理素材。

## §1 四根因终表（每条一手证据 + 首发现归属）

| # | 根因 | 一手证据 | 首发现 |
|---|---|---|---|
| 1 | **输出监督残缺**：正样本 trainable_spans 仅 function_name 碎片（71 字符全文只放行 20 字符；覆盖率 median ~30%/min 12%；全集 209 tokens），`<tool_call>`/JSON 骨架/闭合全 -100；NO_TOOL 是唯一完整监督形态 → 模型只会它 | train.jsonl 逐条亲算 + probe raw_output | Fable 5（双方共核） |
| 2 | **探针构成错配**：探针×训练说法重叠 **0/34**、期望工具 per-case 4/34（unique 口径 2/18，GPT-5.5 复算，两口径对账见 §2.3）；F-044 的「过拟合记忆」语义从未被探针设计对齐 | probe×train 交集双方独立复算（我方口径+命令+输出固化于 `runs/tiny-ablation-adjudication-A/OVERLAP-RECOMPUTE.md`；GPT-5.5 口径见其版 `tiny-ablation-iceberg-teardown-roadmap-2026-07-02.md:215`） | Fable 5 |
| 3 | **输入面错配**：训练 user 全是 `device=...; primitive=...; slots=...; 请按这个语义执行` 协议串，探针是「有点冷」自然中文——**两个面不同语言**（这修正根因 2 的归因深度：零重叠非 held-out 切太狠，是模态不同） | train.jsonl user 字段亲读（我复核 GPT-5.5 的发现） | GPT-5.5 |
| 4 | 🔴 **基线锚跨 harness 断裂（本档新增）**：F-044 的 `28/34` 基线（代码级常量源：`Core/Training/C5TinyAblationHarness.swift` `baselineEmptyToolCallOutputs=28/baselineDenominator=34`；决策源 F-044 `docs/c5-training-readiness-grill/worker-commander-failure-defense-decisions.md:62`）来自 **θ-α 时代的另一套 prompt/探针/判定 harness**，本次 34/34 是新 harness 测的——**裁决门自己违反了 c5-recovery 锁死的「同 harness 分层」纪律**（当年 scorer 双口径惨案的同族）。当前 run **没有 base 模型（无 adapter）在同一探针下的配对测量**——严格说连「训练让模型变差了吗」都无法回答。ablation 的字面义就是配对对照，v5 是单臂测量 | verdict.json 只有历史锚字段；run 档无 base 探针产物（亲查) | **Fable 5 本轮** |

## §2 跨 LLM 辩证记录（透明归属）

### 2.1 采纳 GPT-5.5 完整版的（并致谢）
- **重标 verdict 命名与语义**（`BLOCKED_INVALID_FOR_PARADIGM_VERDICT`）+ **「范式未被证伪」窄化纠正**（防 P0 被包装成实现小坑——直接修正我 D-026 的措辞，见 §6）。
- **「train_on_turn is a name, not an invariant」**——字段名/receipt/validator/实现四方都没共同表达监督目标：比我的「术语混淆」表述更深一层（不是名字错，是**没有任何一方承载语义**）。
- **四面错配框架**（train input / train objective / probe input / probe metric 不构成同一实验）+ 「同一类 surface alignment 问题在 C5 数据、loss、eval、runtime 四面复发」（接 θ-α tool_call_frame 史）。
- **A+ 方案**与 **loss/augmentation 契约枚举**（`C5LossObjectiveProfile ∈ {assistant_full_except_think, no_tool_full, diagnostic_span_only}`；function/arg/value 全部迁出 loss 语义归 augmentation；`train_on_turn` 退役或仅兼容字段）。
- **4 轴探针设计**（A format-memory / B natural-memory / C near-generalization / D C6-heldout）+ 逐轴 verdict 解释表 + 「先拍 tiny 目的再设计」的人审点。
- **8 Phase roadmap 骨架**（Phase 0 stop-the-line 重标 → 1 契约 → 2 代码+测试 → 3 探针重设计 → 4 v6 → 5 wave-1 → 6 formal → 7 governance）——本档不重抄，直接作为执行骨架引用，delta 见 §4。
- receipt 强制字段清单（coverage digest/leakage counts/overlap 口径/natural-protocol 面计数）与「old v5 数据必须 fail 新门、新数据必须 pass」的镜像验收——这是 coverage gate 的**自反测试**设计，漂亮。

### 2.2 Fable 5 增量（GPT-5.5 完整版仍缺的）
1. 🔴 **根因 4 + base 配对设计**（§1#4）：v6 必须每轴跑 **base vs adapter 配对**，门语义从「adapter empty < 绝对阈值（锚在过期 harness 上）」改为「**同 harness 配对差**：轴 A/B adapter empty 必须显著低于 base empty，且 adapter empty 绝对值 <阈值」——这才叫 ablation。F-044 修订必须重锚。
2. **探针 decode 契约缺失**：v5 探针的采样参数（温度/greedy/max_tokens/stop tokens）没进任何契约——`NO_TOOL.NO_TOOL...×27` 直到 token 上限说明连 stop 条件都没定义。v6 探针契约必须钉死 decode 参数（建议 greedy + 显式 stop）并进 receipt——否则轴间/base-adapter 间不可比。
3. **组织元门（机械闯关元信号）**：v1-v5 五连机械修复每次都对（D-025 快速通道无罪），但**连续机械修 ≥3 = 「我在给语义可疑之物铺路」的统计信号**——补「连续 3 次机械修 → 强制 5 分钟 fit-spot（我在给什么铺路？它语义成立吗？）」元门。本次若在 v3 后做过一次 fit-spot，209 tokens 哨兵就会被扣住，省两轮授权。
4. **审计体系盲区的制度修法**：9 次拦截的对抗审计体系没拦住本次，不是审计员失职——**审计 SPEC 模板里没有 fit 维度，SPEC 不含的维度系统性盲**。修法=对抗审计 SPEC 模板永久加一条「该产物的下游消费者拿到的东西完整吗」。
5. **哨兵数字行为学**：209 tokens/29.7% 覆盖率在 preflight 里躺过全程、人机都读过、无人扣扳机——「数字可见 ≠ 数字有门」。修法=receipt 输出的每个载力数字必有阈值门或显式 `no_gate_by_design` 标注。
6. **升维统一原语**（§3）。

### 2.3 口径对账（防两版数字被误读为矛盾）
| 量 | 我方 | GPT-5.5 | 裁定 |
|---|---|---|---|
| 期望工具重叠 | 4/34（per-case：该 case 全部期望工具都见过） | 2/18（unique tool 口径）+ 4/35（expected calls 口径） | 三口径并存各自准确；v6 receipt 统一打印三口径 |
| 覆盖率 median | 29.7%（char，我算） | 30.1%（char，它算） | 同源微差（span 端点处理），均远低于门，无碍 |

## §3 升维（三次抽象之上）

- **抽象①机制**：同名概念两机制混用（masking = 增广 vs loss 范围）。
- **抽象②治理**：mechanism-true ≠ fit-proven；全部现有门验「机制真」，无门验「对目的够」。
- **抽象③认知论（统一原语）**：本项目验证哲学的成熟轴是**真实性**（claim-vs-reality：说的=做的吗，可机械化，今日 9 拦截是其战果）；本次暴露正交的**充分性**轴（做的=下游消费者要的吗），它不可凭空机械化，必须锚定消费者契约才可测。统一原语 = **consumer-anchored sufficiency**：每个产物声明 `consumers:` + `sufficiency_evidence:`，双向验证——向下「我真被消费了吗」（gate2 dead-field 教训，防产物无人读）+ 向上「我满足消费者完整需求了吗」（本次教训，防喂不够）。**dead-field 与本次是同一契约的两半断裂**。
- **元观察（跨 LLM 分析层辩证）**：本议题三轮传递（我→GPT-5.5→我）每轮都抓到上一轮的漏（我漏输入面/目的漂移；它漏重叠数据[草稿版]/基线断裂/decode 契约/组织元门）——**重大失败分析与代码审计同理，单 LLM 单轮必有盲区**。制度化：P0 级失败分析走「双 LLM 独立写→交叉辩证→终版综合」，与 cross-vendor-final-audit 同构，成本一小时，值。

## §4 Roadmap delta（骨架 = GPT-5.5 版 Phase 0-7，此处只列增补）

| Phase | Delta（本档新增，其余照 GPT-5.5 版执行） |
|---|---|
| 0 重标 | + 级联义务：D-026 措辞按 §6 更新、landing-matrix 裁决-A 行标 `experiment_invalid_relabeled`、本档+GPT-5.5 版一并进 grill 目录（已在） |
| 1 契约 | + consumer 契约 frontmatter（`consumers:`/`sufficiency_evidence:`）从本议题产物开始试点；+ 哨兵数字门化规则（载力数字必有门或 `no_gate_by_design`） |
| 2 代码 | + coverage 自反测试保留（old fail/new pass）；+ 探针 decode 契约实装（greedy/stop tokens/max_tokens 进 harness 与 receipt） |
| 3 探针重设计 | 🔴 + **base 配对臂**：4 轴每轴 base(无 adapter) 与 adapter 同 harness 同 decode 各跑一遍；门改「配对差 + 绝对值」双条件；+ F-044 修订（废 θ-α 28/34 历史锚，改同 harness 实测 base 锚） |
| 4 v6 rerun | + R7 交叉核对（route-only 7-15 到期，v6 若在其后需先续签 Part A）；+ 新 run-auth 必须引用本档 §0 verdict 四 reason（防授权书与归因脱节） |
| 5 wave-1 | + gate7 pipeline 的样本组装消费新 loss 契约（G7C 代码已 merge，接口需按 Phase 1 契约字段对齐——排查点入 wave-1 前置清单） |
| 6 formal | +（无新增，GPT-5.5 版已含 mid-training 行为门与分账评测） |
| 7 governance | + 审计 SPEC 模板加 fit 维度；+ 机械闯关元门（连续 ≥3 → fit-spot）；+ P0 失败分析双 LLM 辩证制度化；+ readiness 词表四级采纳（mechanism-true / fit-proven / experiment-valid / behavior-proven） |

## §5 磊哥决策包（一次拍齐，v6 才动）

| # | 决策 | ⭐ 推荐 |
|---|---|---|
| 1 | 接受重标 verdict（§0 四 reason 版） | ⭐ 接受（GPT-5.5 版三 reason + 本档第四条） |
| 2 | tiny 目的定性 | ⭐ **both 分轴**：instrument sanity（轴 A 协议记忆）+ natural tiny（轴 B 自然中文小样本）——轴 B 需训练集加少量自然中文行（构成变更，故 v6 必然新授权） |
| 3 | A+ 契约方案（loss profile 枚举/augmentation 拆名/coverage 双门/train_on_turn 退役） | ⭐ 拍 A+ |
| 4 | base 配对重锚（F-044 修订，废历史 28/34 锚） | ⭐ 拍（不拍则 v6 结果仍不可解释） |
| 5 | Phase 0-3 先行授权（docs/code/test only，不训练不生成） | ⭐ 授权（worker 立即可动，v6 run-auth 另签） |
| 6 | R7 续签 Part A（7-15 到期，v6 大概率在其后） | ⭐ 顺手签 |

## §6 级联义务（本档收口时执行）

1. D-026 措辞更新：~~「范式未被证伪」~~ → 「**D-domain/LoRA 路线未被证伪；当前 C5 trainable_v0 监督契约已被证伪（P0）；首跑实验设计（探针构成+输入面+基线锚）已被证伪（P0）**」。
2. landing-matrix：裁决-A 行 → `experiment_invalid_relabeled_v6_pending`；gate2 行补「loss/augmentation 契约重构（Phase 1-2）」。
3. lessons：M 段（consumer-anchored sufficiency / 哨兵数字行为学 / 机械闯关元门 / 双 LLM 失败分析——待本议题收口一并写）。
4. F-044 修订随 Phase 3 落 grill。

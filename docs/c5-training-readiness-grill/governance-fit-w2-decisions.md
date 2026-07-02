---
authority: governance_fit_w2_proposed_decision_pack
artifact_kind: grill_decision_matrix
scope: docs_only_no_training_no_code_no_readiness_claim
id_range: GF-101~140
status: proposed_pending_leige_lock
proof_class: local_design_with_web_research
created: 2026-07-02
source_spec: /Users/wanglei/Projects/agent-tmux-stack-research/runs/governance-fit-grill/SPEC-GF-W2.md
---

# governance-fit W2 — 门与词表官决策稿

## 0. Grill Recall

已锁承接，不重拍：

- tiny v5 verdict = `BLOCKED_INVALID_FOR_PARADIGM_VERDICT`，四根因：监督残缺、探针构成错配、输入面错配、基线锚跨 harness 断裂。
- D-027 六拍：v5 重标级联；A/B both 分轴硬门；A+ loss 契约；base 配对重锚；Phase 0-3 docs/code/test only；R7 续签到 2026-07-23。
- consumer-anchored sufficiency：mechanism-true 不等于 fit-proven；gate2 dead-field 与 v5 under-supervision 是同一个 producer-consumer 契约破裂的两半。
- W2 只产 proposed 决策矩阵，不写 locked，不训练，不声称 readiness。

## 1. 联网证据

| source_id | URL | date | 用法 |
|---|---|---|---|
| WEB-01 | https://sre.google/sre-book/monitoring-distributed-systems/ | accessed 2026-07-02 | 支撑“数字/监控信号必须回答 what broken / why，并保持简单可行动”；裸数字不是门。 |
| WEB-02 | https://sre.google/workbook/postmortem-culture/ | accessed 2026-07-02 | 支撑 action item / follow-up 必须有 owner；门化数字必须有消费者与阈值 owner。 |
| WEB-03 | https://sre.google/workbook/alerting-on-slos/ | accessed 2026-07-02 | 支撑 SLO/alert 只对显著且可行动事件触发；W2 的数字门不能把 report-only 数字升格成 hard gate。 |
| WEB-04 | https://developers.google.com/machine-learning/guides/rules-of-ml | accessed 2026-07-02 | 支撑训练/服务 skew 与 holdout 分层衡量；F-044 必须同 harness / 同 decode / base-adapter 配对。 |
| WEB-05 | https://airc.nist.gov/airmf-resources/playbook/measure/ | accessed 2026-07-02 | 支撑定义可接受性能限度与 course correction；每个载力指标要么有阈值，要么标 no_gate_by_design。 |
| WEB-06 | https://developers.openai.com/api/docs/guides/evaluation-best-practices | accessed 2026-07-02 | 支撑 reference/gold 与明确 grader rubric；A/B/C/D 轴必须固定 expected output 与 decode contract。 |
| WEB-07 | https://mlcommons.org/ailuminate/safety/ | accessed 2026-07-02 | 支撑 benchmark 按风险类别分账，而不是总分掩盖分层；readiness 词表禁止跨层升格。 |

## 2. D4 哨兵数字门化清单（GF-101~116）

| id | 议题 | 选项+⭐default | 量化理由 | 防惨败检查 | 依赖 | status |
|---|---|---|---|---|---|---|
| GF-101 | receipt 所有载力数字必须显式归属 | A. 全数字都进 hard gate；B. ⭐每个载力数字必须标 `consumer / threshold_owner / gate_semantics / no_gate_by_design` 四元组 | v5 有 `209 trainable tokens` 哨兵数字，人机都看过但无消费者门；SRE 证据要求信号可行动且有 owner（WEB-01/02） | 防 gate2 dead-field：字段存在不等于被消费；也防监督残缺被漂亮数字盖住 | lessons M；consumer-anchored sufficiency | proposed |
| GF-102 | `verdict.baseline_empty_tool_call_outputs=28/34` | A. 继续当阈值锚；B. ⭐降为 historical provenance，v6 hard gate 改同 harness base-adapter paired delta + absolute | FINAL 已判定 28/34 来自旧 harness；当前 `verdict.json` 只有历史锚和 target `<5`，无同 harness base run | 防基线锚跨 harness 断裂复发 | FINAL §1#4；F-044 | proposed |
| GF-103 | `probe.summary.case_count=34 / empty=34 / non_empty=0` | A. empty<5 继续 hard gate；B. ⭐D 轴只 report-only，case_count=34 是完整性门，empty/non_empty 是观察数字 | D-027 已锁 D=原 34 C6 report-only；34/34 只能说明 v5 输出形态，不证明范式 | 防探针构成错配：旧 C6 heldout 不再替代 A/B 目的 | D-027；F-044 | proposed |
| GF-104 | `OVERLAP-RECOMPUTE: 34 0 4 32 16` | A. 作为 v5 失败门；B. ⭐作为构成诊断门：D 轴 text_overlap=0/34、tool_overlap=4/34 必须写进 verdict，不作 pass/fail | 该数字解释探针构成错配；不是模型能力门 | 防输入面错配：不让“heldout 很干净”掩盖“根本不是同一输入面” | OVERLAP-RECOMPUTE；FINAL §1#2/#3 | proposed |
| GF-105 | `train_rows=44 / positive=40 / no_call=4` | A. 只记录；B. ⭐门化为 data-build contract：positive=40、no_call=4、total=44，任何偏离进入 invalid_run | v3 addendum 明确 40 positive + 4 no-call；DATA-SPOTCHECK 证明 44 行 | 防监督残缺：训练样本分母漂移会让 loss/coverage 数字不可解释 | RECEIPT / DATA-SPOTCHECK | proposed |
| GF-106 | `unique_user=32 / unique_tools=16` | A. hard gate；B. ⭐no_gate_by_design，作为 diversity/context statistic；若用于门，必须另定义消费者 | 当前 tiny 目的不是覆盖全集，而是 A/B 记忆与自然迁移；32/16 无阈值 owner | 防哨兵数字：可见 diversity 数字不自动成为 readiness | GF-101 | proposed |
| GF-107 | `loss_mask.trainable_spans` / `trainable_tokens` | A. 只校字段存在；B. ⭐门化到 loss-consumer：必须证明 token-level labels 被 training loop 消费，且 coverage 满足 C5LossObjectiveProfile | gate2 dead-field 证明“写进 JSONL”可假绿；v5 监督残缺来自放行片段不足 | 防 gate2 dead-field + 监督残缺同构复发 | A+ loss contract；lessons #26/M | proposed |
| GF-108 | `masking_coverage: function_name/argument_name/argument_value/train_on_turn` | A. 只看 boolean；B. ⭐boolean 只算 mechanism-true，fit-proof 还需 `consumer=loss_loop` 与 `coverage_profile` | `argument_value=false` 已知 gap；boolean 真不说明完整监督满足消费者 | 防同名 masking 混用：augmentation vs loss 范围 | FINAL §3 抽象① | proposed |
| GF-109 | `offset_fixture sample_count/token_count/offset/length` | A. 直接证明训练可用；B. ⭐只证明 tokenizer offset 机制，不能推出 behavior/experiment validity | offset fixture 证明局部机制；不证明模型行为，也不证明全 batch 精度 | 防 mechanism-true 升格为 behavior-proven | readiness 词表 GF-117~120 | proposed |
| GF-110 | `generator_orchestration configured=false/emitted_rows=0` | A. no_gate；B. ⭐gate7 consumer hard field：若目标是 formal train，configured/emitted_rows 必须按多源 generator spec 达标；tiny diagnostic 可 no_gate_by_design | tiny v5 是 diagnostic；formal C5 需要云多源 generator + 异源 judge | 防训练数据 provenance 伪装完整 | gate7；D-031~037 | proposed |
| GF-111 | `fuse_parity_gate IrrelAcc/toolcall deltas` | A. tiny 必须过；B. ⭐formal endpoint parity 才启用；tiny v6 只引用为 downstream blocked，不作为当前门 | 当前 `quantized_IrrelAcc=0` 是 receipt 残留，不是 tiny A/B run 的消费者 | 防 readiness 路径升格：tiny 诊断不等于 endpoint parity | landing gate1/裁决-A | proposed |
| GF-112 | `rank/scale/lr/batch/epochs/max_seq_length` | A. hard gate；B. ⭐reproducibility fields，默认 no_gate_by_design；只有 sweep/recipe 比较时才门化 | 这些值影响复现，但 W2 不做超参优劣裁决 | 防把配置数字当质量数字 | training receipt | proposed |
| GF-113 | `model/adapter/path/sha/decode params` | A. 只记录路径；B. ⭐decode reproducibility hard field：model、adapter、prompt、stop、max_tokens、thinking、parser 均进 receipt | FINAL 抓到 decode 契约缺失；NO_TOOL 重复到上限暴露 stop/max token 问题 | 防基线锚断裂与输入面错配：同 harness 比较必须可复跑 | F-044；WEB-06 | proposed |
| GF-114 | `status/passed/acceptance_stage` | A. status 自动继承 readiness；B. ⭐status 只声明本 artifact 层级，不得跨 readiness 词表自动升格 | `data_gate_ready` 不是 `train_ready`，`passed=false` 也需说明 invalid vs failed | 防局部绿误读体验绿 | lessons / status vocabulary | proposed |
| GF-115 | `elapsed_ms` probe latency | A. 作为 runtime readiness；B. ⭐no_gate_by_design in tiny W2；仅 runtime/UX lane 另定义 latency SLO 才门化 | probe elapsed_ms 来自诊断脚本，不是端侧体验测量 | 防 local/runtime/mobile proof class 混淆 | proof-class discipline | proposed |
| GF-116 | 外部证据数量与 URL | A. 可选；B. ⭐governance grill 必须 ≥5 URL+date，且每条映射到本地决策 | SPEC 要求不少于 5 条；本稿 7 条 | 防治理决策凭知识库泛论 | SPEC-GF-W2；WEB-01~07 | proposed |

## 3. D5 Readiness 四级词表（GF-117~128）

| id | 议题 | 选项+⭐default | 量化理由 | 防惨败检查 | 依赖 | status |
|---|---|---|---|---|---|---|
| GF-117 | `mechanism-true` 定义 | A. 等同 ready；B. ⭐只表示机制本身按声明工作，如字段存在、offset pass、self-test pass | gate2 证明 mechanism 真仍可能无人消费；WEB-01 要信号可行动 | 防 gate2 dead-field | lessons M；WEB-01 | proposed |
| GF-118 | `fit-proven` 定义 | A. 由机制真推出；B. ⭐表示产物已证明满足下游消费者的完整需求，必须列 consumer + consumed evidence + sufficiency gap | FINAL §3 已锁 consumer-anchored sufficiency | 防监督残缺：loss mask 局部真但不够消费者需要 | FINAL §3 | proposed |
| GF-119 | `experiment-valid` 定义 | A. 单臂结果可算；B. ⭐实验设计有效：同 harness、同 decode、base-adapter 配对、A/B/C/D 轴语义正确 | v5 单臂 + 历史 28/34 锚不可解释 | 防基线锚断裂 | F-044；WEB-04/06 | proposed |
| GF-120 | `behavior-proven` 定义 | A. eval 完成即证明；B. ⭐模型在目标行为门上通过；必须有 hard cases、gold/reference、parser、state/readback 或对应消费者验收 | OpenAI eval best practice 支持 gold/reference；MLCommons 支持类别分账 | 防 D 轴 report-only 被当模型行为通过 | WEB-06/07 | proposed |
| GF-121 | 禁止升格路径 | A. 宽松写法；B. ⭐禁止 `mechanism-true -> fit-proven`、`fit-proven -> experiment-valid`、`experiment-valid -> behavior-proven` 自动升格 | 四级词表的价值就是阻断局部绿误读 | 防所有四根因被单一“pass”吞掉 | GF-117~120 | proposed |
| GF-122 | landing `fit-proof` 列名 | A. 单列备注；B. ⭐拆为 `fit_proof_level / consumer / consumed_artifact / sufficiency_evidence / residual_gap` 五字段 | 单列备注不可机读；五字段可对 consumer 做闭环 | 防 gate2 dead-field：必须写谁消费了什么 | landing-matrix | proposed |
| GF-123 | 允许措辞 | A. 自由写；B. ⭐按级别限定：mechanism-true 可写“机制通过”；fit-proven 可写“对 X consumer 够”；experiment-valid 可写“实验可解释”；behavior-proven 可写“行为门通过” | 词表阻断 readiness 夸大 | 防 status 词漂移 | GF-121 | proposed |
| GF-124 | 禁止措辞 | A. 只禁 V-PASS；B. ⭐mechanism-true 禁“ready/valid/proven”；fit-proven 禁“experiment passed”；experiment-valid 禁“model quality passed”；behavior-proven 禁“endpoint/demo/V/S/U-PASS” | proof class discipline 已锁；W2 细化到 C5 readiness | 防 local/mock 伪装 live/mobile | AGENTS/CLAUDE proof class | proposed |
| GF-125 | evidence shape | A. prose enough；B. ⭐每级必须给 evidence shape：mechanism=command/stdout；fit=consumer read/field consumed；experiment=paired run manifest；behavior=gold pass/fail receipt | WEB-02 强调 owner；NIST Measure 强调定义限度与纠偏 | 防审计只看 prose | WEB-02/05 | proposed |
| GF-126 | status vocabulary 映射 | A. 新造词；B. ⭐沿用 `DONE/PARTIAL/BLOCKED/local-pass/operator-pass/T-PASS/V-PASS`，readiness 四级只作 evidence qualifier | 避免第二套状态系统 | 防治理重复建设 | AGENTS 状态词 | proposed |
| GF-127 | audit SPEC fit 问句 | A. 可选；B. ⭐每份审计 SPEC 必问：下游 consumer 是谁？它实际消费哪个字段？完整需求是什么？本证据还缺什么？ | FINAL 明确审计 SPEC 缺 fit 维度导致 9 次拦截没抓到 | 防审计体系盲区 | FINAL §4 Phase7 | proposed |
| GF-128 | receipt closeout format | A. 摘要即可；B. ⭐每个 closeout 必写 `readiness_level`、`not_claimed`、`next_consumer_gate` | 防 `data_gate_ready` 被读成 `train_ready` | 防 readiness 路径升格 | lessons / landing | proposed |

## 4. D6 F-044 终稿（GF-129~140）

| id | 议题 | 选项+⭐default | 量化理由 | 防惨败检查 | 依赖 | status |
|---|---|---|---|---|---|---|
| GF-129 | `28/34` 的最终定位 | A. 保留 hard threshold；B. ⭐只保留 historical provenance，不参与 v6 threshold | FINAL 已判 28/34 来自旧 θ-α harness；同 harness 分层纪律要求重锚 | 防基线锚跨 harness 断裂 | FINAL §1#4；WEB-04 | proposed |
| GF-130 | 四轴构成 | A. 只测协议串；B. ⭐A 协议记忆 hard + B 自然中文 hard + C 近泛化 observe + D 原 34 C6 report-only | D-027 已锁 both 分轴；P3D 已构造 A=15/B=15/C=4/D=34 | 防探针构成错配和输入面错配 | D-027；P3D docs | proposed |
| GF-131 | F-044-Q1 A 轴 absolute threshold | A. 14/15；B. ⭐15/15 | A 轴是训练协议串原句，目标是 instrument sanity；15 条中任一 fail 都说明训练/decoder/loss 基础链路不稳 | 防监督残缺：协议串都不会就不能谈自然中文 | A/B hard gate | proposed |
| GF-132 | F-044-Q2 B 轴 absolute threshold | A. 15/15；B. ⭐14/15 且同一 tool family 不得连续失败，paired delta 不得低于 A 超过 1 case | B 轴自然句 exact train overlap=0、C6 工具交集空、parent 配对一致；允许 1/15 诊断噪声，仍是 93.3% 下限 | 防输入面错配：B 轴不再被 A 轴掩盖；同 family 连续 fail 直接暴露自然化缺口 | B checklist；commander 亲核 | proposed |
| GF-133 | F-044-Q3 C 轴不足 10 是否扩增 | A. 扩 deterministic template 到 10；B. ⭐不扩，接受 `4/10 candidate_gap`，C 轴只 observation | 严格同工具+未训练 C1+C6 排除后只剩 4 条；硬凑会污染 observation | 防为了达数造假，重演探针构成错配 | P3D `candidate_gap` | proposed |
| GF-134 | F-044-Q4 B 轴是否允许 C6 tool seen 样本 | A. 允许只要 C1 row 不同；B. ⭐不允许，B 轴泄漏零容忍：C6 exact text=0、expected tool intersection=0、parent pairing consistent | commander 已亲核 B 轴泄漏声称坐实；默认更严可避免 heldout 工具面回流 | 防 C6 heldout 污染 B hard gate | B checklist | proposed |
| GF-135 | base-adapter paired delta | A. 只跑 adapter；B. ⭐每轴都跑 base(no adapter)+adapter，同 prompt/parser/decode，门看 paired delta + absolute | ablation 字面义是配对对照；v5 单臂无法回答训练是否改善 | 防基线锚断裂 | FINAL §4 Phase3 | proposed |
| GF-136 | decode contract | A. receipt 只写模型路径；B. ⭐receipt 必写 tokenizer wrapper、prompt skeleton、stop set、max_tokens、thinking、parser、adapter SHA | v5 raw output `NO_TOOL` 重复暴露 stop/max token 契约问题 | 防第二信息层被忽略 | lessons M#4；WEB-06 | proposed |
| GF-137 | D 轴 report-only | A. D 轴可辅助 hard gate；B. ⭐D 轴只报告，不参与 tiny hard gate或 candidate signoff | D 轴来自原 C6 heldout，与 A/B 目的不同 | 防 D 轴吞掉 A/B 分轴 | D-027 | proposed |
| GF-138 | C 轴 observation | A. C 轴 hard gate；B. ⭐C 轴只观察 error class / tool family / count，不进 signoff | C strict 仅 4 条，样本不足且非 tiny primary purpose | 防假阴性阻断或硬凑污染 | P3D C-axis | proposed |
| GF-139 | F-044 终稿文案 | A. 继续草案；B. ⭐采用：“F-044 v6 SHALL use four axes with A/B hard gates, C observation, D report-only; SHALL replace historical 28/34 with same-harness base-adapter paired delta plus absolute thresholds; SHALL record decode contract and leakage ledger.” | 覆盖 8 个草案决策 + Q1-Q4 defaults | 防旧文案继续把 28/34 写成 provenance gate | GF-129~138 | proposed |
| GF-140 | lock 协议 | A. 本稿即 locked；B. ⭐全部 proposed，磊哥 lock 前只能写入决策候选，不改 OpenSpec/code/run-auth | SPEC 硬约束 status=proposed；训练/run-auth 仍 R7-gated | 防 docs 决策稿越权启动训练 | SPEC-GF-W2 | proposed |

## 5. 字段级门化摘要

| field group | decision | consumer | gate semantics |
|---|---|---|---|
| `baseline_empty_tool_call_outputs=28/34` | GF-102/GF-129 | F-044 historical narrative | `no_gate_by_design`；v6 使用 paired base |
| `case_count=34` | GF-103 | D-axis report completeness | hard completeness only |
| `empty_tool_call_outputs=34` | GF-103 | D-axis report | report-only |
| `overlap 34/0/4/32/16` | GF-104 | probe-design diagnosis | construct-validity diagnostic |
| `row_count=44 / positive=40 / no_call=4` | GF-105 | data builder / run manifest | hard build contract |
| `loss_mask / trainable_tokens` | GF-107 | loss loop | fit-proof required |
| `masking_coverage` | GF-108 | loss objective profile | mechanism-true until consumed |
| `offset_fixture` | GF-109 | tokenizer offset preflight | mechanism-true only |
| `generator_orchestration` | GF-110 | gate7 formal data | hard only in formal train path |
| `fuse_parity_gate` | GF-111 | endpoint parity | blocked/downstream, not tiny gate |
| `hyperparams` | GF-112 | reproducibility | no_gate_by_design unless sweep |
| `decode/model/adapter` | GF-113/GF-136 | v6 experiment validity | hard reproducibility field |

## 6. Landing Matrix Fit-Proof 列草案

把 `landing-matrix.md` 每个 gate 的 fit-proof 改成以下五列或等价 YAML 字段：

| column | allowed values / rule |
|---|---|
| `fit_proof_level` | `mechanism_true` / `fit_proven` / `experiment_valid` / `behavior_proven` |
| `consumer` | 具体下游消费者：loss_loop、probe_harness、C6 scorer、generator pipeline、run_auth、human signoff 等 |
| `consumed_artifact` | 被消费的文件/字段/receipt path；不得写“见上文” |
| `sufficiency_evidence` | command/stdout、field consumed proof、paired run receipt、gold pass/fail receipt |
| `residual_gap` | 未满足项；若无，写 `none`，禁止空白 |

## 7. 消减表

| cluster | 合并前 | 消减后 | 理由 |
|---|---:|---:|---|
| D4 哨兵数字 | GF-101~116 = 16 | 12 field groups | GF-105/106 都是 train data shape，但一个 hard、一个 no_gate；保留分开以免误门化。 |
| D5 词表 | GF-117~128 = 12 | 4 levels + 5 landing fields + 3 wording rules | 不新造状态系统，作为 evidence qualifier。 |
| D6 F-044 | GF-129~140 = 12 | 4 open-point defaults + 4 axis/base/decode rules + 1 final wording + 1 lock rule | 草案 8 决策被终稿矩阵吸收。 |

## 8. W2 Closeout

status: proposed_pending_leige_lock

not_claimed:
- 不声明 C5 train-ready。
- 不声明 v6 experiment valid。
- 不声明 model behavior proven。
- 不声明 endpoint/demo/V/S/U-PASS。
- 不授权训练、生成、C6 真评测或 run-auth。

next_consumer_gate:
- commander 消减综合后上抛磊哥 lock。
- 若 lock，落回 `landing-matrix.md` 的 `fit-proof` 列与 F-044 v6 spec/receipt schema。

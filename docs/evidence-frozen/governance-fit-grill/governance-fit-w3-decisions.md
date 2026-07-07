---
authority: governance_fit_w3_proposed_decision_pack
artifact_kind: grill_decision_matrix
scope: docs_only_no_training_no_code_no_readiness_claim
id_range: GF-201~240
status: proposed_pending_leige_lock
proof_class: local_design_with_web_research
created: 2026-07-03
source_spec: inline_commander_task_2026-07-03_GF-W3
output_path: /Users/wanglei/Projects/agent-tmux-stack-research/runs/governance-fit-grill/governance-fit-w3-decisions.md
---

# governance-fit W3 — 制度官决策稿

## 0. Grill Recall

已决承接，不重拍：

- tiny v5 verdict = `BLOCKED_INVALID_FOR_PARADIGM_VERDICT`，四根因：监督残缺、探针构成错配、输入面错配、基线锚跨 harness 断裂。
- D-027 六拍：v5 重标级联；A/B both 分轴硬门；A+ loss 契约；base 配对重锚；Phase 0-3 docs-code-test only；R7 续签到 2026-07-23。
- W1 proposed：GF-001~040 给出 consumer_contract 单 schema、loss/augmentation 枚举边界、decode contract 具体值。注意：当前主线 checkout 未见 `docs/c5-training-readiness-grill/governance-fit-w1-decisions.md`，本稿承接 run artifact `/Users/wanglei/Projects/agent-tmux-stack-research/runs/governance-fit-grill/governance-fit-w1-decisions.md`。
- W2 proposed：GF-101~140 给出哨兵数字门化、readiness 四级词表、F-044 终稿；GF-122/GF-127/GF-136 是本稿 D8 的直接依赖。
- PR26/P12 交叉审反哺：fit 四问能有效抓出 base-only 冒充 paired、decode contract 不全、`legacy_missing` 绕过、natural row 只 name-check 覆盖 gold truth 这类 producer-consumer 断裂。

本稿只产 `proposed` 制度决策，不改主线文件、不 commit、不训练、不声称 readiness。

## 1. 联网证据

| source_id | URL | date | 用法 |
|---|---|---|---|
| WEB-W3-01 | https://sre.google/sre-book/postmortem-culture/ | accessed 2026-07-03 | 支撑重大失败需要系统性 postmortem、行动项和组织学习；D7 只对 P0 级失败开重制度流程。 |
| WEB-W3-02 | https://research.google/pubs/postmortem-action-items-plan-the-work-and-work-the-plan/ | accessed 2026-07-03 | 支撑 action items 必须可执行、可追踪，不能停在复盘文字；D7/D9 要 owner、due gate、closeout。 |
| WEB-W3-03 | https://sre.google/workbook/alerting-on-slos/ | accessed 2026-07-03 | 支撑 alert/trigger 应面向显著且可行动的问题；D9 机械闯关元门不能因普通小红灯泛滥触发。 |
| WEB-W3-04 | https://developers.google.com/machine-learning/guides/rules-of-ml | accessed 2026-07-03 | 支撑 ML 系统要有 pipeline/test/monitoring、训练服务 skew 与数据依赖检查；D8/D9 要全链 fit-spot。 |
| WEB-W3-05 | https://developers.openai.com/api/docs/guides/evaluation-best-practices | accessed 2026-07-03 | 支撑 eval 要有 gold/reference、rubric、明确 grader；D8 审计 SPEC 必须问 expected/consumer/rubric。 |
| WEB-W3-06 | https://airc.nist.gov/airmf-resources/playbook/measure/ | accessed 2026-07-03 | 支撑 AI risk measure 要定义指标、阈值与纠偏；D7/D9 的触发阈值和成本上限要写进制度。 |
| WEB-W3-07 | https://arxiv.org/abs/2305.14325 | accessed 2026-07-03 | Multi-agent debate 可提升推理可靠性，但它是成本型机制；D7 只在 P0/high-stakes 用，不把双 LLM 当 always-on。 |
| WEB-W3-08 | https://arxiv.org/abs/2308.07201 | accessed 2026-07-03 | ChatEval 等多 agent 评审提示“多代理可补盲但仍需 rubric”；D7/D8 要证据包和 rubric，不接受纯辩论结论。 |

## 2. D7 双 LLM 失败分析制度门槛（GF-201~214）

| id | 议题 | 选项+⭐default | 量化理由 | 防惨败检查 | 依赖 | status |
|---|---|---|---|---|---|---|
| GF-201 | 什么失败进入双 LLM 制度门 | A. 任何 test fail；B. ⭐仅 P0 级失败或 P0 级疑似：错误 verdict 会授权训练/候选/signoff、跨 harness 基线、消费者未实际消费、数据/安全/PII 泄漏、V/S/U-PASS 误升格 | tiny v5 不是普通失败，而是 invalid verdict；WEB-W3-01/03 支持只对显著可行动事件触发重流程 | 防四根因一起被普通红灯处理，尤其监督残缺和基线锚断裂 | FINAL；W2 GF-117~120 | proposed |
| GF-202 | P0 级失败判据 | A. 看损失/分数异常；B. ⭐满足任一即 P0：`invalid_experiment_design`、`dead_field_consumed_as_gate`、`consumer_fit_unproven_but_claimed`、`safety_or_raw_leakage`、`run_auth_or_R7_bypass`、`candidate_signoff_false_green` | 这 6 类直接对应 v5 四根因 + gate2 dead-field + R7 proof-class discipline | 防把 P0 制度失败降级成 P2 测试缺口 | W2 GF-121/GF-124 | proposed |
| GF-203 | 单 LLM 自查与双 LLM 分界 | A. 全部双 LLM；B. ⭐单 LLM 足够处理局部实现/单文件/测试修复；若 claim 涉及 consumer fit、experiment-valid、behavior-proven 或跨文件 authority，就升级双 LLM | 双 LLM 有成本；WEB-W3-07/08 支持多代理用于复杂判断，不支持无差别使用 | 防双 LLM 形式主义，也防重大 fit 问题只靠作者自查 | W2 四级词表 | proposed |
| GF-204 | 双 LLM 必须异质 | A. 两个同 prompt 同模型；B. ⭐至少异角色 + 异 prompt frame；P0/high-stakes 默认异厂或异模型族，same-vendor 只算 pre-check | R-L17 已定 heterogeneous deframing；same-vendor 多票不等于人审通过 | 防确认偏误：同一 framing 重复 3 次仍漏输入面错配 | R-L17；WEB-W3-08 | proposed |
| GF-205 | 三轮辩证流程 | A. 自由辩论；B. ⭐三轮封顶：R1 独立复现事实，R2 互相攻击对方 strongest finding，R3 controller 汇总 verdict + required action；每轮必须引用 file:line/URL/stdout | tiny teardown 成功点是跨 LLM 互相抓盲点，不是聊天；三轮足够暴露假设/反例/修复动作 | 防只生成漂亮复盘不发现 dead field | WEB-W3-01/02 | proposed |
| GF-206 | 失败分析证据包 | A. 只给问题描述；B. ⭐必须含 source-of-truth 文件、命令/stdout、receipt/verdict、expected consumer、claimed level、known no-claims、可复跑命令 | PR26/P12 fit 审有效依赖证据包；缺证据包的辩论会空转 | 防基线锚断裂和 file:line 错读 | W1 GF-008/GF-010 | proposed |
| GF-207 | 成本上限 | A. 无上限；B. ⭐默认最多 2 个审计 LLM + 1 controller，3 轮，90 分钟或 3 次工具循环；超过需写 `cost_escalation_reason` 并由 commander/磊哥授权 | NIST measure 要定义限度与纠偏；成本无限会拖垮夜间流水线 | 防制度过重导致 worker 闲置或绕开制度 | WEB-W3-06 | proposed |
| GF-208 | 早停条件 | A. 必跑满三轮；B. ⭐若 R1 已复现 P0 且修复动作唯一，直接 REQUEST_CHANGES；若 R1 证明非 P0，降级为单 LLM normal review | 双 LLM 是风险控制，不是仪式；WEB-W3-03 的 actionable trigger 原则适用 | 防为辩证而辩证，也防 P0 已明确仍消耗预算 | GF-201/GF-207 | proposed |
| GF-209 | 冲突处理 | A. 多数投票；B. ⭐不投票，按证据优先级：live repo/receipt/stdout > visible artifact > dated report > LLM prose；无法裁断则 BLOCKED with missing evidence | v5 事故证明“多次审计没抓到”不能靠投票修复；证据链优先 | 防基线锚和输入面被口头共识吞掉 | AGENTS truth-first | proposed |
| GF-210 | 输出形态 | A. 复盘文章；B. ⭐固定 `P0/P1/P2 register + root-cause tree + consumer-fit table + action items(owner/due/gate) + non-claims + residual risk` | Google postmortem action items 强调可执行追踪；W3 制度要落成可收口产物 | 防复盘完成但 action 未执行 | WEB-W3-02 | proposed |
| GF-211 | 与人审关系 | A. 双 LLM 可替代 owner lock；B. ⭐双 LLM 只提供 evidence synthesis；R7/candidate signoff/run-auth 仍需 human_lock | R-L17 已定 high-stakes human gate；proof-class 不能由审计结论升级 | 防同源多模型 PASS 被误当 owner signoff | R-L17；W2 GF-124 | proposed |
| GF-212 | 触发后的修复授权 | A. reviewer 直接改；B. ⭐双 LLM 失败分析只产修复要求；是否进入代码修复由 commander/任务 owner 派单，且修复必须回到原 consumer gate | 分析与修复 owner 分离，防审计越权改 scope | 防 docs-only grill 越权训练/改代码 | CLAUDE R7 | proposed |
| GF-213 | 复盘 action item 关闭条件 | A. 提 PR 即关闭；B. ⭐必须有反向 fixture/机械门/receipt 字段证明同构失败不能复发；否则保持 `action_open` | tiny v5 的五连机械修说明“修了一个脚本”不等于制度闭环 | 防机械修连续过门但 fit 仍错 | D9 GF-229~240；WEB-W3-02 | proposed |
| GF-214 | 不进入双 LLM 的豁免 | A. 无豁免；B. ⭐文案错别字、单测期望更新、非载力 generated diff、已知 unrelated fixture drift 可豁免，但必须写 `not_p0_reason` | 减少误报；但豁免要可审计 | 防 alert fatigue 让真正 P0 被忽略 | WEB-W3-03 | proposed |

## 3. D8 审计 SPEC fit 维度模板化（GF-215~228）

| id | 议题 | 选项+⭐default | 量化理由 | 防惨败检查 | 依赖 | status |
|---|---|---|---|---|---|---|
| GF-215 | 审计 SPEC 是否强制 Fit 段 | A. 可选；B. ⭐所有 code/review/run-auth/candidate 审计 SPEC 必含 `Fit Questions` 硬段；缺段不得给 APPROVE | GF-127 已提出四问；PR26/P12 实战证明它能抓 base-only/legacy_missing | 防第 9 次审计仍只看机制不看消费者 | W2 GF-127 | proposed |
| GF-216 | Fit 四问标准文本 | A. 自由发挥；B. ⭐固定四问：1 downstream consumer 是谁；2 它实际消费哪个字段/文件；3 完整需求是什么；4 当前证据还缺什么 | 固定问句可机械 grep，避免 reviewer 漏问 | 防 gate2 dead-field：字段存在但无人消费 | GF-127；P12 review | proposed |
| GF-217 | consumer 枚举 | A. prose；B. ⭐沿用 GF-009 起步枚举：`loss_loop/probe_harness/c6_scorer/generator_pipeline/run_auth/human_lock/uiue_consumer/presentation_consumer`，SPEC 必选至少一个 | enum 可减少 “consumer=大家” 的空泛写法 | 防 consumer 名漂移导致无法关门 | W1 GF-009 | proposed |
| GF-218 | consumed artifact 写法 | A. 文件路径即可；B. ⭐必须写 path + JSON pointer/field/line anchor，例如 `receipt.json#/decode_contract/max_tokens` | P12 证明要看字段值，不只看文件存在 | 防 file:line 存在但内容不对 | W1 GF-010 | proposed |
| GF-219 | complete requirement 写法 | A. “符合需求”；B. ⭐必须列字段级 invariants、threshold、negative case、proof_class；没有 threshold 写 `no_gate_by_design` | W2 哨兵数字规则要求每个载力数字有门或无门理由 | 防裸数字哨兵和行为层升格 | W2 GF-101/GF-125 | proposed |
| GF-220 | residual gap 写法 | A. 可空；B. ⭐必须填 `none` 或数组；数组项必须指向下一 consumer gate，不允许“待确认”无主语 | 空白无法区分无残留与忘填 | 防 PARTIAL 写成 DONE | W1 GF-011/W2 GF-128 | proposed |
| GF-221 | readiness level 声称 | A. 审计自由命名；B. ⭐SPEC 要求 reviewer 给 `fit_proof_level`，只允许 W2 四级，且列 not_claimed | PR26/P12 都只能给 mechanism/fit 局部证据，不能自动 behavior-proven | 防 mechanism-true 升格为 experiment-valid/behavior-proven | W2 GF-117~124 | proposed |
| GF-222 | 反向/绕过探针要求 | A. 只跑 happy path；B. ⭐涉及 fail-closed/contract/decoder/loss gate 的审计必须至少构造 1 个 bypass 或 negative fixture；若不能构造，写明不可构造理由 | P12 `legacy_missing` 绕过是最高价值发现；没有负例容易假绿 | 防监督残缺和 dead-field 被 happy path 掩盖 | P12 review | proposed |
| GF-223 | producer-consumer-harness 三分表 | A. 只审代码 diff；B. ⭐SPEC 必填 producer、consumer、harness/scorer 三列和每列权威文件 | v5 四根因本质是 producer/consumer/harness 分裂 | 防输入面错配与基线锚断裂 | FINAL §3/§4 | proposed |
| GF-224 | verdict mapping | A. reviewer 自定；B. ⭐P0/P1 任一未修 = REQUEST_CHANGES；P2 only 可 APPROVE_WITH_RESIDUAL；无 findings 才 APPROVE | PR26/P12 用该映射清晰阻断；避免“CI绿但fit红”被合并 | 防 local-pass 冒充 merge-ready | review discipline | proposed |
| GF-225 | evidence table 最小列 | A. 任意表格；B. ⭐至少列 `claim / evidence / proof_class / consumer / residual_gap / source_line_or_url` | 直接把 W1/W2 schema带进审计结果 | 防只列命令不列消费者 | W1 GF-008；W2 GF-122 | proposed |
| GF-226 | SPEC 自带 no-claims | A. closeout 再写；B. ⭐SPEC 起手即写 `not_claimed`，如不声明 train-ready/C6 acceptance/V-PASS/live/mobile | 让 reviewer 从一开始避免越级证明 | 防 proof-class 混淆 | AGENTS proof discipline | proposed |
| GF-227 | 审计 SPEC 模板落地 | A. 文档建议；B. ⭐新增模板块，可粘贴到后续 SPEC：`Scope / Fit Questions / Producer-Consumer-Harness / Required Negative Probes / Verdict Mapping / Non-Claims / Output Path` | 模板化才可复用；W3 制度的目标是降低下一轮漏问概率 | 防每轮审计重新发明格式 | GF-215~226 | proposed |
| GF-228 | 审计模板机械门 | A. 人工记得；B. ⭐commander 派单前 grep：缺 `Fit Questions`、缺四问任一、缺 `not_claimed`、缺 output path 即退回补 SPEC | 机械门要拦 SPEC 质量，而不是事后怪 reviewer | 防五连机械修只修脚本不问 fit | D9 GF-229~240 | proposed |

## 4. D9 机械闯关元门（GF-229~240）

| id | 议题 | 选项+⭐default | 量化理由 | 防惨败检查 | 依赖 | status |
|---|---|---|---|---|---|---|
| GF-229 | 连续 N 次机械修触发值 | A. 5 次；B. ⭐3 次同一 gate/同一 verdict 机械修仍未解释 fit，就触发 fit-spot；若任一修复触及 P0 类 claim，1 次即触发 | tiny v5 五连机械修没人问 fit 是实证反例；N=3 能在第五次前截停 | 防机械闯关覆盖监督残缺/输入错配 | BACKLOG W3；WEB-W3-03 | proposed |
| GF-230 | 什么算“机械修” | A. 任意 commit；B. ⭐仅指为让测试/脚本/receipt 绿而改命令、阈值、fixture、parser、字段、生成物、摘要口径，且未重新回答 consumer fit | 把正常功能迭代排除，聚焦“过门动作” | 防把 D9 滥用于普通开发 | GF-229 | proposed |
| GF-231 | 同构触发 | A. 必须同一文件；B. ⭐同一 consumer/gate/claim 即同构，哪怕跨文件跨 worker；例如 stop token、parser、summary 都服务 probe_harness decode | v5/PR26 失败横跨 data、harness、receipt；按文件分会漏 | 防基线锚和 harness 断裂跨文件逃逸 | GF-223 | proposed |
| GF-232 | 触发后第一动作 | A. 继续修第 4 次；B. ⭐暂停 merge/run-auth，开 `fit-spot` 文档，回答 GF-127 四问 + producer-consumer-harness 三分表 + 最近 N 次机械修 diff 摘要 | 先问 fit，再继续修；否则只会更快穿过错误门 | 防五连机械修复现 | GF-127/GF-223 | proposed |
| GF-233 | fit-spot 检查清单 | A. 自由审；B. ⭐必须含 8 项：consumer、consumed field、threshold owner、negative fixture、decode/prompt/parser、base/reference、proof_class、not_claimed | 覆盖 v5 四根因和 W1/W2 schema | 防四根因任一漏检 | W1/W2 | proposed |
| GF-234 | 触发后 owner | A. 最后改代码的人；B. ⭐commander 指派独立 reviewer，作者不得单独关闭；若涉及 P0，启 D7 双 LLM | 防作者继续在原 framing 内机械修 | 防确认偏误 | GF-203/GF-204 | proposed |
| GF-235 | 触发后允许动作 | A. 全停；B. ⭐允许只读审计、负例构造、receipt/schema 补证；禁止训练、candidate signoff、run-auth、阈值放宽，直到 fit-spot 结论 | 不阻断事实收集，但阻断越级推进 | 防 R7/run-auth 被脚本绿绕过 | R7；CLAUDE 禁止动作 | proposed |
| GF-236 | 豁免条件 | A. 无；B. ⭐仅三类豁免：纯格式/拼写、已知 unrelated 环境噪声、上游 API/CI 短暂故障；豁免需写 `mechanical_gate_exemption_reason` 和 expiry | 避免 alert fatigue，同时保持可审计 | 防豁免变永久洞 | WEB-W3-03 | proposed |
| GF-237 | fit-spot 输出 verdict | A. prose；B. ⭐固定 `FIT_OK / FIT_GAP_P1 / FIT_GAP_P2 / INVALID_GATE / BLOCKED_MISSING_EVIDENCE`；`INVALID_GATE` 必须回退旧绿结论 | 需要区分“门有效但证据缺”和“门本身无效” | 防 invalid experiment 仍沿用旧结果 | W2 GF-119 | proposed |
| GF-238 | 与 CI/make verify 关系 | A. 替代 CI；B. ⭐fit-spot 是 meta gate，不替代 CI；CI 绿但 fit-spot 红时不得 merge，高风险 path 必加新机械门后再恢复 | CI 测机制，fit-spot 测消费者充分性 | 防 CI 绿掩盖 dead-field | WEB-W3-04 | proposed |
| GF-239 | 关闭条件 | A. fit-spot 写完即关；B. ⭐必须有一条新 negative/provenance/consumer gate 进入 tests/verify/receipt schema，或明确 `no_gate_by_design` 并由 human_lock 接受 | 关闭要留下防复发物，不只是复盘文字 | 防同构失败下次重来 | WEB-W3-02 | proposed |
| GF-240 | tiny v5 反例 codify | A. 作为故事保留；B. ⭐把 tiny v5 写成 D9 canonical example：5 次机械修后仍未问 fit，按新制度第 3 次应暂停并触发 `INVALID_GATE` 评估 | 反例是制度设计的 test case；不写进制度就会被遗忘 | 防旧灾难只在记忆里，不进流程 | FINAL；BACKLOG W3 | proposed |

## 5. 审计 SPEC Fit 模板草案

```markdown
## Fit Questions (required)

1. Downstream consumer 是谁？
   - consumer: <loss_loop|probe_harness|c6_scorer|generator_pipeline|run_auth|human_lock|uiue_consumer|presentation_consumer>
2. 它实际消费哪个字段/文件？
   - consumed_artifact: <path>#<json-pointer-or-line-or-field>
3. 完整需求是什么？
   - invariants:
   - threshold_owner:
   - negative_cases:
   - proof_class:
4. 当前证据还缺什么？
   - residual_gap: <none|list>

## Producer / Consumer / Harness

| role | authority file | consumed/emitted fields | current proof | residual |
|---|---|---|---|---|
| producer | | | | |
| consumer | | | | |
| harness/scorer | | | | |

## Required Negative Probes

| probe | expected fail-closed behavior | command or fixture | result |
|---|---|---|---|

## Verdict Mapping

- P0/P1 open -> REQUEST_CHANGES
- P2 only -> APPROVE_WITH_RESIDUAL
- no findings -> APPROVE

## Non-Claims

- not claimed: train-ready / C6 acceptance / behavior-proven / endpoint-ready / V-S-U-PASS unless explicitly in scope
```

## 6. Landing 填格草案

| gate | fit_proof_level | consumer | consumed_artifact | sufficiency_evidence | residual_gap |
|---|---|---|---|---|---|
| D7 双 LLM P0 failure analysis | mechanism_true | commander / human_lock | `governance-fit-w3-decisions.md#GF-201-GF-214` | W3 proposed matrix + WEB-W3-01~08 | pending leige lock；未落 commander 模板 |
| D8 audit SPEC fit template | mechanism_true | reviewer / probe_harness / loss_loop | `governance-fit-w3-decisions.md#GF-215-GF-228` | PR26/P12 cross-review lessons + template sketch | pending leige lock；未接入派单 grep gate |
| D9 mechanical fit-spot meta gate | mechanism_true | commander / run_auth | `governance-fit-w3-decisions.md#GF-229-GF-240` | tiny v5 five mechanical fixes counterexample + N=3 default | pending leige lock；未接入 make verify/dispatch preflight |

## 7. 消减表

| cluster | 合并前 | 消减后 | 理由 |
|---|---:|---:|---|
| D7 双 LLM 制度 | GF-201~214 = 14 | 6 个执行单元：触发、P0 分类、异质角色、三轮流程、成本/早停、action closeout | 避免把“双 LLM”写成常态化大流程；只在 P0/fit 高风险启用。 |
| D8 审计 SPEC 模板 | GF-215~228 = 14 | 1 个必填模板 + 1 个机械 grep 门 + 1 个 verdict mapping | GF-127 四问落成模板，复用 W1/W2 schema。 |
| D9 机械闯关元门 | GF-229~240 = 12 | 3 个规则：N=3 触发、fit-spot 八项、关闭必须有防复发门 | tiny v5 反例被 codify，避免第五次机械修才发现门错。 |

## 8. W3 Closeout

status: proposed_pending_leige_lock

not_claimed:
- 不声明 C5 train-ready。
- 不声明 v6 experiment valid。
- 不声明 model behavior proven。
- 不声明 endpoint/demo/V/S/U-PASS。
- 不授权训练、生成、C6 真评测或 run-auth。
- 不声明 W1 已在当前 main-live checkout 落地；本稿承接 W1 run artifact。

next_consumer_gate:
- commander 消减综合后上抛磊哥 lock。
- 若 lock，落回派单 SPEC 模板、fit-spot 触发规则、landing-matrix fit-proof 字段。
- 若接入机械门，先从 dispatch/SPEC preflight grep 开始，不直接改训练或 runtime。

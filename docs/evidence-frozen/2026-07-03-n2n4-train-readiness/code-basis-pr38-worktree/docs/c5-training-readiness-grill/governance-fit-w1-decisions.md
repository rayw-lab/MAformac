---
artifact_kind: governance_fit_w1_decision_matrix
authority: governance_fit_w1_proposed_decision_pack
source_spec: /Users/wanglei/Projects/agent-tmux-stack-research/runs/governance-fit-grill/SPEC-GF-W1.md
id_range: GF-001..GF-040
status: proposed_pending_leige_lock
scope: docs_data_spec_only
no_commit: true
---

# Governance-Fit W1 Decisions

## 0. Grill Recall

- 本稿承接 D-027 六拍、FINAL §3/§4 的 `consumer-anchored sufficiency`、GF-W2 的 readiness 四级词表与 GF-122/GF-136，不重拍。
- GF-136 已定方向：decode receipt 必写 `tokenizer wrapper / prompt skeleton / stop set / max_tokens / thinking / parser / adapter SHA`。本稿只把这些字段细化成可机械校验的具体值与边界。
- 所有行均为 `proposed`，待磊哥 lock。本文不改 OpenSpec、不改代码、不授权训练、不授权 v6 run。

## 1. Web Evidence

| id | URL | date | 用途 |
|---|---|---|---|
| WEB-W1-01 | https://developers.openai.com/api/docs/guides/structured-outputs | accessed 2026-07-02 | 支撑 contract/schema 必须显式约束 required key 与 enum，不能靠 prose。 |
| WEB-W1-02 | https://developers.openai.com/api/docs/guides/evaluation-best-practices | accessed 2026-07-02 | 支撑 eval 需 reference/gold/rubric；decode 与 parser 字段是 experiment validity 证据。 |
| WEB-W1-03 | https://jsonlines.org/ | accessed 2026-07-02 | 支撑 JSONL 每行独立 JSON；数据行不能用 Markdown frontmatter，需 per-row 字段。 |
| WEB-W1-04 | https://json-schema.org/understanding-json-schema/reference/object | accessed 2026-07-02 | 支撑 properties/required 的结构化校验。 |
| WEB-W1-05 | https://json-schema.org/understanding-json-schema/reference/generic | accessed 2026-07-02 | 支撑 enum/const 固定取值，适合 `C5LossObjectiveProfile` 与 decode contract enums。 |
| WEB-W1-06 | https://docs.python.org/3/library/argparse.html | accessed 2026-07-02 | 支撑 CLI required argument / invalid argument fail-closed 语义。 |
| WEB-W1-07 | https://semver.org/ | accessed 2026-07-02 | 支撑兼容字段退役必须文档化并有过渡，不可静默断裂。 |
| WEB-W1-08 | https://openai.com/index/introducing-structured-outputs-in-the-api/ | accessed 2026-07-02 | 支撑 JSON mode 不等于 schema adherence；本项目 decode contract 不应只靠后验 JSON 解析。 |

## 2. D1 Consumer 契约 Frontmatter（GF-001~013）

| id | 议题 | 选项+⭐default | 量化理由 | 防惨败检查 | 依赖 | status |
|---|---|---|---|---|---|---|
| GF-001 | consumer 契约是否建第二套字段 | A. 新建 `consumer_contract_*` 字段；B. ⭐复用 GF-122 五字段为单 schema：`fit_proof_level / consumer / consumed_artifact / sufficiency_evidence / residual_gap` | GF-122 已定义 landing fit-proof 五字段；重复 schema 会让审计和 mechanical gate 分叉 | 防 gate2 dead-field：同一产物被两个 consumer 字段解释成不同事实 | GF-122；WEB-W1-04 | proposed |
| GF-002 | Markdown receipt / decision doc 是否必带 frontmatter | A. 可选；B. ⭐所有新 C5 readiness receipt、decision matrix、run-auth、closeout 必带 YAML frontmatter 中的 `consumer_contract` block | Markdown 有天然 frontmatter；可被 `rg '^consumer_contract:'` 和 YAML parser 校验 | 防 receipt prose 绿但无 consumer owner | GF-128；FINAL §3 | proposed |
| GF-003 | JSON / YAML manifest frontmatter 形态 | A. 顶层散字段；B. ⭐顶层 `consumer_contract` object，内含 GF-122 五字段 | JSON/YAML 无 Markdown frontmatter；顶层 object 最小可测 | 防同名字段散落被漏读 | WEB-W1-04 | proposed |
| GF-004 | JSONL data row 形态 | A. 文件级 frontmatter；B. ⭐每行 JSON 必带或继承 `consumer_contract_ref`，manifest 必给 ref 定义；不得在 JSONL 前插 Markdown | JSON Lines 要求每行有效 JSON；文件前插 frontmatter 会破坏 JSONL 消费 | 防数据 gate 因格式污染假红/假绿 | WEB-W1-03 | proposed |
| GF-005 | Adapter artifact 是否带 consumer 契约 | A. adapter 文件裸存；B. ⭐adapter 旁必须有 `adapter.manifest.json`，含 `consumer_contract`、base SHA、adapter SHA、decode_contract_ref、training_receipt_ref | adapter 二进制本身不可 grep；旁路 manifest 是最小可测载体 | 防 adapter 落盘被读成 lora_candidate | GF-128；GF-136 | proposed |
| GF-006 | Contract doc / OpenSpec 是否带 consumer 契约 | A. spec 自带即可；B. ⭐OpenSpec/design/tasks 中涉及 readiness gate 的新增章节必须写 consumer 契约表或 frontmatter ref | OpenSpec 只写 behavior 不自动声明下游 consumer；consumer-anchored sufficiency 是治理补充 | 防 spec 只验机制真，不验对下游够不够 | FINAL §3；OpenSpec boundary | proposed |
| GF-007 | raw / historical evidence 是否强制 frontmatter | A. 全部强制；B. ⭐raw/historical/read-only source 不强制，但引用它生成新 readiness artifact 时，新 artifact 必带 consumer_contract | RAW/历史文件不应被批量改写；新消费层必须声明使用方式 | 防把历史证据改坏，也防历史锚升格 | GF-129；red-line raw readonly | proposed |
| GF-008 | `sufficiency_evidence` 最小可测形态 | A. prose；B. ⭐必须是数组，每项含 `proof_class`、`path_or_command`、`field_or_assertion`、`result` | prose 难机械校验；四字段可 grep + schema validate | 防“看过了/通过了”不可复核 | WEB-W1-02；GF-125 | proposed |
| GF-009 | `consumer` 取值 | A. 自由字符串；B. ⭐有限枚举起步：`loss_loop / probe_harness / c6_scorer / generator_pipeline / run_auth / human_lock / uiue_consumer / presentation_consumer`，新值需先加 schema | enum 降低拼写漂移；JSON Schema enum 支持固定值 | 防 consumer 名字漂移导致 dead-field | WEB-W1-05 | proposed |
| GF-010 | `consumed_artifact` 格式 | A. “见上文”；B. ⭐必须是 path + JSON pointer / line anchor / field name，如 `receipt.json#/decode_contract/max_tokens` | 可机械定位，避免审计只核路径存在 | 防 file:line 内容错读与字段没被消费 | tmux-bridge file:line 教训；GF-127 | proposed |
| GF-011 | `residual_gap` 空值 | A. 可留空；B. ⭐无残留写 `none`，否则写数组；空白字段 fail-closed | 空白无法区分“无”与“忘填” | 防 closeout 把 PARTIAL 写成 DONE | GF-128 | proposed |
| GF-012 | mechanical gate | A. 人审；B. ⭐新增 grep/schema 门：新 readiness docs 缺 `consumer_contract`、缺五字段、`residual_gap` 空白均 fail | 最小门可先用 `rg` 实现，后续上 schema parser | 防第 9 次审计仍漏 fit 维度 | GF-127；WEB-W1-04 | proposed |
| GF-013 | 与 proof class 的关系 | A. 合并成一个字段；B. ⭐consumer_contract 是 sufficiency 轴，proof_class 是真实性/环境轴，二者都必填且不得互相替代 | local proof 可能不足 fit；fit-proof 也不能冒充 mobile/live | 防 local/mock/runtime proof class 升格 | AGENTS proof discipline；GF-117~120 | proposed |

## 3. D2 Loss / Augmentation 枚举边界（GF-014~026）

| id | 议题 | 选项+⭐default | 量化理由 | 防惨败检查 | 依赖 | status |
|---|---|---|---|---|---|---|
| GF-014 | `C5LossObjectiveProfile` 枚举是否固定 | A. prose 描述；B. ⭐固定三值：`assistant_full_except_think / no_tool_full / diagnostic_span_only` | FINAL 已提出 A+ loss contract；JSON Schema enum 可机械校验 | 防 `train_on_turn` 这种名字被当 invariant | FINAL §2.1；WEB-W1-05 | proposed |
| GF-015 | `assistant_full_except_think` 合法场景 | A. 所有正样本；B. ⭐正式正样本 tool-call 训练默认值：训练完整 assistant tool-call 对象，排除 `<think>` span | v5 根因是只训 function_name 碎片；该默认直接补完整输出对象 | 防输出监督残缺复发 | FINAL §1#1；F-047 | proposed |
| GF-016 | `assistant_full_except_think` 禁用场景 | A. 可用于诊断碎片；B. ⭐禁用于 parser-failure、坏调用恢复链、只想测某 span 的诊断实验 | 正式 profile 不应让模型学习生成坏调用再修复 | 防 failure chain 被训练成行为 | retrain-c5 design D7 | proposed |
| GF-017 | `no_tool_full` 合法场景 | A. 所有 negative；B. ⭐仅用于确定性 NO_TOOL/refusal/unsupported/safety/no-call 目标，完整训练 assistant 的非执行出口 | v5 NO_TOOL 是唯一完整监督形态；要保留但不可吞掉 positive | 防 empty=hit 与拒识出口混淆 | E-2 S-204；GF-120 | proposed |
| GF-018 | `no_tool_full` 禁用场景 | A. 可用于 tool-call 正样本缺失；B. ⭐禁用在 expected_tool_calls 非空的正样本；正样本输出缺失必须 invalid_sample | 防把数据缺失伪装成拒识训练 | 防模型继续只会 NO_TOOL | FINAL §1#1 | proposed |
| GF-019 | `diagnostic_span_only` 合法场景 | A. 任意小样本；B. ⭐只允许 docs-code-test diagnostic，目的为验证 offset/tokenizer/loss-loop 机制，不进入 formal C5 candidate 训练 | 该 profile 只能证明 mechanism-true，不证明 fit-proven | 防 mechanism-true 升格 | GF-117；GF-109 | proposed |
| GF-020 | `diagnostic_span_only` 授权人 | A. worker 自行开；B. ⭐必须由 run-auth / 磊哥 lock / commander SPEC 明写 `diagnostic_span_only_allowed=true`，并写实验问题 | 防小诊断悄悄进入训练主线 | 防 Phase 0-3 docs-code-test 越权训练 | R7 / SPEC discipline | proposed |
| GF-021 | `diagnostic_span_only` 禁用场景 | A. 可做候选训练；B. ⭐禁用在 formal train、candidate signoff、C6 acceptance、V/S/U-PASS 支撑 | span-only 不满足下游 parser 的完整输出对象 | 防 209 tokens 哨兵数字复发 | FINAL §1#1；GF-118 | proposed |
| GF-022 | augmentation 命名空间 | A. 继续 `masking.function_name` 等同名；B. ⭐loss 用 `loss_objective_profile/loss_spans/excluded_spans`，augmentation 用 `augmentation_strategy.function_name/argument_name/value` | FINAL 指出 masking=augmentation vs loss 范围混用；命名空间拆开可机械防混 | 防同名 masking 混用 | FINAL §3 抽象①；GF-108 | proposed |
| GF-023 | 同名冲突的 decode/validator 报错 | A. warning；B. ⭐fail-closed：`loss_augmentation_namespace_collision`，并指出冲突字段路径 | 训练数据 decoder 看到同一字段同时表达 loss 和 augmentation 必须停 | 防字段存在但语义相反 | WEB-W1-04 | proposed |
| GF-024 | `train_on_turn` 兼容读规则 | A. 继续作为权威；B. ⭐只作为 legacy alias 读入：`true` 需映射到显式 `loss_objective_profile`；新产物写 `train_on_turn` 仅 warning | 兼容旧 receipt，但新语义以枚举为准 | 防老字段继续当 invariant | FINAL §2.1 | proposed |
| GF-025 | `train_on_turn` 写规则与退役时间 | A. 不退役；B. ⭐2026-07-23 前兼容写但必须双写枚举；2026-07-24 起新 artifact 写 `train_on_turn` fail-closed，历史 archived 只读豁免 | R7 已续签到 2026-07-23；用一个明确日期结束兼容期 | 防兼容期无限拖成第二套 SSOT | WEB-W1-07；R7 date | proposed |
| GF-026 | loss receipt 必备 consumer fields | A. 只写 profile；B. ⭐每个 train row / receipt 聚合必须写 `loss_objective_profile`、`parser_critical_token_coverage`、`excluded_think_span_count`、`consumer=loss_loop` | v5 失败不是没有字段，而是字段不证明 parser-critical tokens 被训 | 防 loss 绿但 action 塌 | FINAL §1#1；GF-107 | proposed |

## 4. D3 Decode 契约具体值（GF-027~040）

| id | 议题 | 选项+⭐default | 量化理由 | 防惨败检查 | 依赖 | status |
|---|---|---|---|---|---|---|
| GF-027 | decode contract 字段集合 | A. 只写 `temperature/max_tokens/stop_tokens`；B. ⭐按 GF-136 细化为 `contract_version / tokenizer_wrapper / prompt_skeleton_id / temperature / max_tokens / stop_policy / thinking_mode / parser / tool_call_cardinality / adapter_sha` | PR #26 review 已证明三字段不够；GF-136 要完整 receipt 字段 | 防第二信息层被忽略 | GF-136；pr26-cross-review | proposed |
| GF-028 | `temperature` | A. 可调；B. ⭐`0`，且 runner 必须证明 greedy 参数真实传入或 fail-closed | tiny v6 是 paired experiment，不是采样观感；temperature 漂移会破坏 base-adapter 可比 | 防基线锚断裂 | WEB-W1-02；GF-119 | proposed |
| GF-029 | `max_tokens` 总默认 | A. 80；B. ⭐256，四轴同一值；若超预算另开 contract_version，不同值则 invalid_probe | 80 已在 PR #26 里不足以安心覆盖多 tool-call；256 给两段 tool_call + 少量噪声留证据，同时仍有限界 | 防 D 轴多调用被截断；防轴间 decode 不一致 | GF-136；C6-MP-028 | proposed |
| GF-030 | `max_tokens=80` 专条 | A. 继续默认 80；B. ⭐80 只保留为 historical/P3H-smoke 值，不得作为 v6 四轴默认 | C6-MP-028 期望 2 个 tool call；v5 raw 曾 `NO_TOOL` 重复到上限，80 的证据不足 | 防多意图/多调用 case 被 token cap 误判 | `contracts/c6-bench-cases.jsonl:35`；PR #26 review | proposed |
| GF-031 | D 轴 multi-call case 处理 | A. D report-only 可随便截断；B. ⭐即使 D 轴 report-only，也必须保留完整 ordered observed calls；C6-MP-028 至少能记录 2 个 expected/observed slots | report-only 不是 evidence-optional；D 轴用于发现 decode/parser 问题 | 防 report-only 变成无证据 | GF-137；C6-MP-028 | proposed |
| GF-032 | stop set 是否保留裸 `\n` | A. 保留裸 `\n`；B. ⭐generation stop 不保留裸 `\n`，只允许 assistant boundary（如 `<PIPE-im_end-PIPE>`）或 runner-native EOS；换行只作为 parser whitespace | lstrip 修复只能防开头空白，不能防 tool-call 内/两调用间换行截断 | 防 leading whitespace bug 换形复发 | PR #26 absorbed finding | proposed |
| GF-033 | `</tool_call>` 是否作为 generation stop | A. 保留；B. ⭐不作为 generation stop；作为 parser block delimiter。若 stop 在 `</tool_call>`，多 tool-call 会只留下第一段 | 本轮本地 repro：两个 `<tool_call>` 经 `</tool_call>` stop 后只剩第一个 observed name | 防 C6-MP-028 第二调用丢失 | PR #26 local repro；GF-031 | proposed |
| GF-034 | raw vs post-processed output | A. 只存 post-truncated `raw_output`；B. ⭐必须分存 `raw_generation`、`normalized_output`、`parsed_tool_calls`、`parser_warnings` | Architect lane指出 raw boundary 被压扁；consumer 需要看到尾随 prose/多调用/坏闭合 | 防 has_tool_call 布尔吞掉证据 | pr26-cross-review；GF-125 | proposed |
| GF-035 | `thinking=false` 实现方式 | A. 只写 prompt 口头要求；B. ⭐contract 写 `thinking_mode=no_think`，tokenizer wrapper 必须用显式 no-think/chat-template 路径；若仅 prompt 模拟，receipt 写 `thinking_enforcement=prompt_only` 且降级 residual | F-047 已识别 think/no-think 是 surface 分叉第二战线 | 防训练/eval/runtime think 模式错配 | F-047；E2 S-205 | proposed |
| GF-036 | `<think>` 输出处理 | A. 忽略；B. ⭐tool-call probe 中 `<think>` 内容不计入 loss；decode 若出现 `<think>`，保留 raw 并标 `thinking_leak=true`，不得静默截成 empty | PR #26 base-only smoke raw showed `<think>`；这应是证据，不是摘要噪声 | 防把 thinking leak 当 NO_TOOL 或 empty | RECEIPT-P3H smoke；GF-034 | proposed |
| GF-037 | tokenizer wrapper | A. fallback string；B. ⭐`tokenizer_wrapper=qwen3_toolcall_no_think_v1`，receipt 记录 actual class/version；fallback prompt 只准用于 diagnostic smoke，不能用于 v6 verdict | PR #26 有 `render_prompt()` 死代码而实际走 fallback；v6 需要训练/eval模板同源 | 防输入面/模板错配 | FINAL §1#3；PR #26 review | proposed |
| GF-038 | prompt skeleton | A. 硬编码不可见；B. ⭐`prompt_skeleton_id=maformac_toolcall_single_turn_v1`，内容 hash 入 receipt；system/user/assistant prefix 均固定 | 同 prompt 是 paired experiment 前提；hash 可机械核 | 防 base/adapter 或 A/B/C/D prompt 漂移 | GF-119；WEB-W1-02 | proposed |
| GF-039 | parser 语义 | A. 只判 `has_tool_call`；B. ⭐parser 输出 ordered array：`[{index,name,arguments,json_valid,closed,span_start,span_end}]`；A/B hard gate 要 expected exact，C observe，D report-only全量记录 | `has_tool_call` 无法区分一个正确调用、两个调用、尾随噪声、坏 JSON | 防 scorer name-only/empty 假绿 | FINAL §1#4；E-088 | proposed |
| GF-040 | adapter/base SHA 与 paired mode | A. adapter 可选；B. ⭐v6 verdict mode 必填 base SHA + adapter SHA，缺 adapter 只能 `base_only_smoke`，不得产出 `paired_summary` 或 experiment-valid claim | PR #26 live head base-only smoke rc=0 证明需要模式分离 | 防单臂测量冒充 ablation | GF-135；pr26-cross-review | proposed |

## 5. Proposed Schema Sketch

```yaml
consumer_contract:
  fit_proof_level: mechanism_true
  consumer: probe_harness
  consumed_artifact: path/to/receipt.json#/decode_contract
  sufficiency_evidence:
    - proof_class: local
      path_or_command: python3 Tools/ProbeHarness/probe_harness.py --dry-contract-check ...
      field_or_assertion: decode_contract.parser == ordered_tool_call_json_v1
      result: pass
  residual_gap:
    - real base/adapter probe not run
```

```json
{
  "contract_version": "decode-contract.v6.proposed",
  "tokenizer_wrapper": "qwen3_toolcall_no_think_v1",
  "prompt_skeleton_id": "maformac_toolcall_single_turn_v1",
  "temperature": 0,
  "max_tokens": 256,
  "stop_policy": {
    "generation_stop": ["<|im_end|>"],
    "tool_call_delimiter": "</tool_call>",
    "bare_newline_generation_stop": false
  },
  "thinking_mode": "no_think",
  "parser": "ordered_tool_call_json_v1",
  "tool_call_cardinality": "preserve_all_observed",
  "adapter_sha_required_for_verdict": true
}
```

## 6. Closeout

- 本稿只给 proposed 决策与 schema sketch。
- 不改主线文件，不 commit，不训练，不生成 v6 run-auth。
- 若 lock，下一步应落回主线 `docs/c5-training-readiness-grill/governance-fit-w1-decisions.md`，并驱动 PR #26 / P3H contract 修复、F-044 v6 run-auth schema、landing fit-proof 机械门。

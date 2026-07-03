# F-044 Revision Draft

status: draft_pending_leige_lock
artifact_kind: grill_decision_matrix
scope: docs/data-spec only
proof_class: local design
source_spec: /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/SPEC-P3D-probe-design.md
captured_at: 2026-07-02

## 0. 修订目标

F-044 不再把 `28/34` 写成候选可晋级 provenance。`28/34` 只能降级为旧 D 轴 C6 heldout 的 report-only 现象：它说明某次 probe 在原 34 C6 case 上的输出形态，但不证明训练记忆、自然中文迁移、近泛化、C6 acceptance、endpoint readiness 或 V-PASS。

新门语义必须按 per-axis paired delta + absolute threshold 组织：A/B 是 hard gate，C 是 observation，D 是 report-only。

## 1. Grill 决策矩阵

| decision_id | 议题 | 旧说法风险 | 修订草案 | status |
|---|---|---|---|---|
| F-044-D1 | `28/34` provenance | 把原 34 C6 probe 的非空 toolcall 数当成训练有效性证据，容易把 D 轴 report-only 升格成 hard gate | `28/34` 只保留为 historical/report-only phenomenon；不得作为 candidate signoff、训练 readiness 或 C6 pass 证据 | draft |
| F-044-D2 | A 轴硬门 | 只看协议串可能退化成“背训练格式”，不能证明自然中文 | A 轴保留 hard gate，但必须和 B 轴配对看 delta；A 轴 fail 直接 hard fail，A 轴 pass 只证明 protocol-memory | draft |
| F-044-D3 | B 轴硬门 | 若 B 轴由 LLM paraphrase 生成，会把 generator 风格和泄漏风险带进 hard gate | B 轴只接受 C1 `示例说法` 确定性抽取；B 轴 fail 代表同语义自然中文迁移失败；B 轴入选必须过 C6/must_not_train 排除 | draft |
| F-044-D4 | C 轴观察 | 把近泛化当 hard gate 会被当前 tiny subset 工具覆盖不足放大成假阴性 | C 轴为 observation；记录 pass/fail 和错误类型，不进 signoff；本轮 strict 候选只有 4 条，禁止硬凑 10 条 | draft |
| F-044-D5 | D 轴原 34 C6 | 原 34 C6 仍重要，但与训练面重叠和目标不同，不能复用为 Phase 3 hard gate | D 轴固定 report-only；输出只作为 qualitative failure map，不作为 pass/fail 门 | draft |
| F-044-D6 | paired delta | 单轴 absolute 可能隐藏“只会协议串”或“只会自然句”的不对称 | 对每个 A/B pair 计算 `B - A` paired delta；若 A pass/B fail，标记 naturalization_gap；若 A fail/B pass，标记 protocol_overfit_assumption_refuted | draft |
| F-044-D7 | absolute thresholds | 只看 delta 会掩盖 A/B 都低的共同失败 | A/B 同时需要 absolute threshold；建议草案：A hard threshold = 15/15；B hard threshold = 14/15 且不得出现同一 tool family 连续失败；最终阈值待磊哥 lock | draft |
| F-044-D8 | decode 契约引用 | 不固定 decode 会让 probe 结果不可比 | A/B/C/D 必须引用同一 decode contract：same tokenizer wrapper、same prompt skeleton、same parser、same adapter checkpoint、same `thinking=false` / tool_call output contract；任何差异单列为 invalid_probe | draft |

## 2. 新门语义草案

### A 轴：protocol-memory hard gate

- 输入：训练协议串原句。
- 目标：expected D-domain tool name + arguments。
- absolute：建议 15/15。
- paired delta：与同 pair 的 B 轴比较。
- 失败解释：若 A fail，先怀疑训练 target / decode / loss mask，而不是自然中文泛化。

### B 轴：natural-memory hard gate

- 输入：同 C1 row 的 frozen xlsx `示例说法`。
- 目标：同 A pair expected D-domain tool name + arguments。
- absolute：建议 14/15，且同一 tool family 不得连续失败。
- paired delta：`B_pass_rate - A_pass_rate`；核心观察是否存在 naturalization_gap。
- 泄漏门：必须排除 C6 `must_not_train` / exact input / canonical / dedupe / expected tool 高风险命中。

### C 轴：near-generalization observation

- 输入：已见 D-domain tool 的未训练 C1 行自然句。
- 目标：同 tool。
- absolute：不设 hard threshold。
- report：只记录 count、error class、tool family；本轮 strict 候选 4 条，不足 ~10 是数据约束，不是模型结论。

### D 轴：C6 heldout report-only

- 输入：原 34 C6 probe cases。
- 目标：沿原 expected D-domain tool。
- absolute：不设 Phase 3 hard threshold。
- report：可继续记录 `empty_tool_call_outputs`、per-case raw output、工具族错误，但不得写成 C6 pass 或 candidate signoff。

## 3. 探针构成契约

| field | contract |
|---|---|
| case_id | `P3D-A-*` / `P3D-B-*` / `P3D-C-*` / original `C6-*` |
| axis | `A_protocol_memory` / `B_natural_memory` / `C_near_generalization_observation` / `D_c6_report_only` |
| input_text | A 为训练协议串；B/C 为 C1 xlsx 示例说法；D 为原 C6 `input_zh` |
| expected_tool_calls | D-domain tool calls；A/B pair 必须一致 |
| c1_row_id | A/B/C 必填；D 沿原 C6 source_refs |
| training_overlap | exact_text / c1_row / tool / canonical / dedupe 五项显式标记 |
| c6_exclusion | B/C 必填 `pass` 后才可入集；失败必须进入排除记录 |
| gate_semantics | A/B hard；C observation；D report-only |
| decode_contract_ref | 必填；同 run 内四轴一致 |

## 4. F-044 推荐文案

> F-044 revised: `28/34` is downgraded to D-axis historical/report-only provenance. Phase 3 signoff SHALL use a four-axis probe set: A protocol-memory hard gate, B natural-memory hard gate from deterministic C1 example extraction with C6 leakage exclusion, C near-generalization observation, and D original 34 C6 report-only. A/B SHALL be evaluated as paired cases with both absolute thresholds and paired delta; C/D SHALL NOT be promoted into hard gates.

## 5. 待磊哥 lock 的开放点

| open_id | question | default draft |
|---|---|---|
| F-044-Q1 | A 轴 absolute threshold 是否必须 15/15 | 默认 15/15 |
| F-044-Q2 | B 轴 absolute threshold 是 14/15 还是 15/15 | 默认 14/15 + no same-family consecutive fail |
| F-044-Q3 | C 轴 strict 候选不足 10 是否允许 deterministic template expansion | 默认不允许，先记录 candidate_gap |
| F-044-Q4 | B 轴是否允许纳入 tool seen in C6 但 C1 row 未命中的样本 | 默认不允许，泄漏零容忍优先 |

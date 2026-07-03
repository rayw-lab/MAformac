# B Axis Natural Chinese Checklist

status: draft
artifact_kind: data_spec
scope: docs/data-spec only
proof_class: local data audit
source_spec: /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/SPEC-P3D-probe-design.md
captured_at: 2026-07-02

## 0. 结论

B 轴本轮构造 15 条，全部来自 C1 frozen xlsx 的 `示例说法` 字段确定性抽取；不使用 LLM 生成 paraphrase。每条与 A 轴训练协议串共享同一个 `augmentation_parent_id` / C1 row id / expected D-domain tool，形成同工具双模态对照。

注意：仓内 `contracts/semantic-function-contract.jsonl` 的 3990 行均为 `redaction_state=example_hash_only`，只有 `example_utterance_hash`，没有明文自然句。因此本清单按 `contracts/source-snapshot-manifest.yaml` 回到仓外只读 frozen xlsx 抽取；这不是把 raw 入仓，而是记录 15 条设计侧 probe 文本。

## 1. 抽取规则

1. 读取 `build/samples/c5-training-samples.jsonl` 中 `split=train` 且 `train_eligible=true` 的行。
2. 取 `augmentation_parent_id` 作为 C1 row id，取第一条 `expected_tool_calls[].name` 作为 expected D-domain tool。
3. 用 C1 row 的 `source_sheet + source_row_no` 回到 frozen xlsx 的同 sheet / 同 Excel row，读取列名 `示例说法`。
4. 排除任何命中 C6 hard heldout 的行：`semantic_contract_ids`、exact `input_zh`、expected tool、canonical semantic、dedupe group。
5. 取前 15 条通过排除的行，保持训练样本顺序，避免人工挑好看样本。

## 2. B 轴自然中文清单

| case_id | natural utterance | expected D-domain tool | C1 row id | paired A sample_id | C1 source |
|---|---|---|---|---|---|
| P3D-B-001 | 打开空调制冷模式 | open_ac_cooling_mode | c1_airControl_000018 | c5-train-00001 | airControl row 18 |
| P3D-B-002 | 打开主驾空调制冷模式 | open_ac_cooling_mode | c1_airControl_000019 | c5-train-00002 | airControl row 19 |
| P3D-B-003 | 打开空调快速制冷模式 | open_ac_cooling_mode | c1_airControl_000020 | c5-train-00003 | airControl row 20 |
| P3D-B-004 | 打开主驾空调快速制冷模式 | open_ac_cooling_mode | c1_airControl_000021 | c5-train-00004 | airControl row 21 |
| P3D-B-005 | 打开空调制热模式 | open_ac_heating_mode | c1_airControl_000026 | c5-train-00005 | airControl row 26 |
| P3D-B-006 | 打开主驾空调制热模式 | open_ac_heating_mode | c1_airControl_000027 | c5-train-00006 | airControl row 27 |
| P3D-B-007 | 打开空调快速制热模式 | open_ac_heating_mode | c1_airControl_000028 | c5-train-00007 | airControl row 28 |
| P3D-B-008 | 打开主驾空调快速制热模式 | open_ac_heating_mode | c1_airControl_000029 | c5-train-00008 | airControl row 29 |
| P3D-B-009 | 打开除雾 | open_defog_mode | c1_airControl_000040 | c5-train-00009 | airControl row 40 |
| P3D-B-010 | 打开空调设置页面 | open_ac_set_interface | c1_airControl_000002 | c5-train-00010 | airControl row 2 |
| P3D-B-011 | 打开主驾空调设置页面 | open_ac_set_interface | c1_airControl_000003 | c5-train-00011 | airControl row 3 |
| P3D-B-012 | 关闭空调设置页面 | close_ac_set_interface | c1_airControl_000004 | c5-train-00012 | airControl row 4 |
| P3D-B-013 | 关闭主驾空调设置页面 | close_ac_set_interface | c1_airControl_000005 | c5-train-00013 | airControl row 5 |
| P3D-B-014 | 打开空调出风口 | open_airoutlet | c1_airControl_000010 | c5-train-00018 | airControl row 10 |
| P3D-B-015 | 打开主驾空调出风口 | open_airoutlet | c1_airControl_000011 | c5-train-00019 | airControl row 11 |

## 3. 排除记录

| excluded sample_id | C1 row id | natural utterance | expected tool | exclusion reason |
|---|---|---|---|---|
| c5-train-00014 | c1_airControl_000006 | 打开空调 | open_ac | C1 id in C6 must_not_train; exact C6 input; expected tool seen in C6; canonical/dedupe seen in C6 |
| c5-train-00015 | c1_airControl_000007 | 打开主驾空调 | open_ac | expected tool seen in C6 |
| c5-train-00016 | c1_airControl_000008 | 关闭空调 | close_ac | C1 id in C6 must_not_train; exact C6 input; expected tool seen in C6; canonical/dedupe seen in C6 |
| c5-train-00017 | c1_airControl_000009 | 关闭主驾空调 | close_ac | expected tool seen in C6 |

## 4. 泄漏零容忍声明

- B 轴 15 条与 C6 `must_not_train=true` 的 `semantic_contract_ids` 无交集。
- B 轴 15 条与 C6 `input_zh` exact text 无交集。
- B 轴 15 条的 canonical semantic / dedupe group 未命中 C6 hard heldout 引用行。
- B 轴 expected tool 选择避开已在 C6 expected tool 集合中的 `open_ac` / `close_ac`，避免把 C6 hard heldout 工具面误塞回 B 轴 hard gate。
- 近 paraphrase 不做 LLM 生成；除 frozen xlsx `示例说法` 外，本轮无新增自然语言变体。

## 5. 复跑要点

本轮使用标准库 `zipfile + xml.etree.ElementTree` 只读解析 xlsx，因为本机 `python3` 没有 `openpyxl`。复跑时必须保持 `source_row_no == Excel row number`，不是 `row-1`；否则会把相邻行的示例说法错配到 C1 row。

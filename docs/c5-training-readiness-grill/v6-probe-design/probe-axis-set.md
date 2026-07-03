# Phase 3 Probe Axis Set

status: draft
artifact_kind: data_spec
scope: docs/data-spec only
proof_class: local data design
source_spec: /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/SPEC-P3D-probe-design.md
captured_at: 2026-07-02

## 0. 边界

本文件只定义 Phase 3 设计侧探针集，不授权训练、重训、模型质量验收、C6 acceptance、demo-golden-run、voice、runtime/mobile/true-device/V-PASS。

权威输入按 SPEC-P3D：A/B 是 hard gate；C 是 observation；D 是原 34 C6 heldout report-only，禁止回退成“只测协议串”。

## 1. 轴定义总表

| 轴 | 名称 | case 来源 | 目标数量 | 本轮构造数 | 与训练面重叠度声明 | 门语义 |
|---|---|---|---:|---:|---|---|
| A | 器材记忆轴 | tiny-ablation `build/samples/c5-training-samples.jsonl` 的训练协议串 user turn | ~15 | 15 | exact training user text overlap = 15/15；tool overlap = 15/15 | hard gate；测模型是否记住训练过的协议串到 D-domain tool |
| B | 自然记忆轴 | 与 A 同一批 C1 行，从 C1 frozen xlsx `示例说法` 确定性抽取 | ~15 | 15 | C1 行与工具 overlap = 15/15；自然句 exact train text overlap = 0/15；C6 must_not_train 排除后入选 | hard gate；测同一训练语义换自然中文后是否仍能到同工具 |
| C | 近泛化轴 | 已见 D-domain tool，但 C1 行未进入训练样本 | ~10 | 4 strict + 6 candidate_gap | tool overlap = 4/4；C1 行 exact train overlap = 0/4；其余 6 个严格候选不足 | observation；不得作为 hard gate |
| D | 原 34 C6 case | `tiny-ablation-adjudication-A/probe/*.json` + `contracts/c6-bench-cases.jsonl` | 34 | 34 | 说法级重叠 0/34；per-case expected-tool 全见过 4/34（见 OVERLAP-RECOMPUTE） | report-only；不得作为 Phase 3 hard gate |

## 2. A/B 配对集

| pair_id | A sample_id | C1 row id | A 轴协议串 | B 轴自然句 | expected D-domain tool |
|---|---|---|---|---|---|
| P3D-AB-001 | c5-train-00001 | c1_airControl_000018 | `device=ac_cooling_mode; primitive=set_mode; slots=no_slots; 请按这个语义执行` | 打开空调制冷模式 | open_ac_cooling_mode |
| P3D-AB-002 | c5-train-00002 | c1_airControl_000019 | `device=ac_cooling_mode; primitive=set_mode; slots=direction:主驾; 请按这个语义执行` | 打开主驾空调制冷模式 | open_ac_cooling_mode |
| P3D-AB-003 | c5-train-00003 | c1_airControl_000020 | `device=ac_cooling_mode; primitive=set_mode; slots=modeValue:快速; 请按这个语义执行` | 打开空调快速制冷模式 | open_ac_cooling_mode |
| P3D-AB-004 | c5-train-00004 | c1_airControl_000021 | `device=ac_cooling_mode; primitive=set_mode; slots=direction:主驾+modeValue:快速; 请按这个语义执行` | 打开主驾空调快速制冷模式 | open_ac_cooling_mode |
| P3D-AB-005 | c5-train-00005 | c1_airControl_000026 | `device=ac_heating_mode; primitive=set_mode; slots=no_slots; 请按这个语义执行` | 打开空调制热模式 | open_ac_heating_mode |
| P3D-AB-006 | c5-train-00006 | c1_airControl_000027 | `device=ac_heating_mode; primitive=set_mode; slots=direction:主驾; 请按这个语义执行` | 打开主驾空调制热模式 | open_ac_heating_mode |
| P3D-AB-007 | c5-train-00007 | c1_airControl_000028 | `device=ac_heating_mode; primitive=set_mode; slots=modeValue:快速; 请按这个语义执行` | 打开空调快速制热模式 | open_ac_heating_mode |
| P3D-AB-008 | c5-train-00008 | c1_airControl_000029 | `device=ac_heating_mode; primitive=set_mode; slots=direction:主驾+modeValue:快速; 请按这个语义执行` | 打开主驾空调快速制热模式 | open_ac_heating_mode |
| P3D-AB-009 | c5-train-00009 | c1_airControl_000040 | `device=defog_mode; primitive=set_mode; slots=no_slots; 请按这个语义执行` | 打开除雾 | open_defog_mode |
| P3D-AB-010 | c5-train-00010 | c1_airControl_000002 | `device=ac_set_interface; primitive=power_on; slots=no_slots; 请按这个语义执行` | 打开空调设置页面 | open_ac_set_interface |
| P3D-AB-011 | c5-train-00011 | c1_airControl_000003 | `device=ac_set_interface; primitive=power_on; slots=direction:主驾; 请按这个语义执行` | 打开主驾空调设置页面 | open_ac_set_interface |
| P3D-AB-012 | c5-train-00012 | c1_airControl_000004 | `device=ac_set_interface; primitive=power_off; slots=no_slots; 请按这个语义执行` | 关闭空调设置页面 | close_ac_set_interface |
| P3D-AB-013 | c5-train-00013 | c1_airControl_000005 | `device=ac_set_interface; primitive=power_off; slots=direction:主驾; 请按这个语义执行` | 关闭主驾空调设置页面 | close_ac_set_interface |
| P3D-AB-014 | c5-train-00018 | c1_airControl_000010 | `device=airoutlet; primitive=power_on; slots=no_slots; 请按这个语义执行` | 打开空调出风口 | open_airoutlet |
| P3D-AB-015 | c5-train-00019 | c1_airControl_000011 | `device=airoutlet; primitive=power_on; slots=direction:主驾; 请按这个语义执行` | 打开主驾空调出风口 | open_airoutlet |

## 3. C 轴 strict candidates

严格口径：expected D-domain tool 必须已出现在训练样本；C1 row id 必须未出现在训练样本；不得命中 C6 `must_not_train` / `must_pass` 的 source_refs、exact input、canonical semantic、dedupe group。

| case_id | C1 row id | natural utterance | expected D-domain tool | source | gate |
|---|---|---|---|---|---|
| P3D-C-001 | c1_airControl_000041 | 打开快速除雾 | open_defog_mode | C1 xlsx `airControl` row 41 | observation |
| P3D-C-002 | c1_airControl_000042 | 打开前除雾 | open_defog_mode | C1 xlsx `airControl` row 42 | observation |
| P3D-C-003 | c1_airControl_000043 | 打开快速前除雾 | open_defog_mode | C1 xlsx `airControl` row 43 | observation |
| P3D-C-004 | c1_carControl_000009 | 暂停打开主驾车窗 | pause_window_slide | C1 xlsx `carControl` row 9 | observation |

candidate_gap: strict C-axis 当前只能构造 4 条，不足 SPEC-P3D 的 ~10。原因不是模型判断，而是 tiny training subset 的已见工具主要集中在 airControl 前 40 行；按“同工具 + 未训练 C1 行 + C6 泄漏排除”三条件筛完只剩 4 条。若要凑满 ~10，必须放宽到 deterministic template expansion 或允许同 device/action 但不同 D-domain tool；本文件不擅自放宽。

## 4. D 轴原 34 C6 report-only

| idx | C6 case_id | input_zh | expected D-domain tool(s) | gate |
|---:|---|---|---|---|
| 1 | C6-MP-002 | 有点冷 | raise_ac_temperature_by_exp | report-only |
| 2 | C6-MP-003 | 屏幕太暗了 | raise_screen_brightness_little | report-only |
| 3 | C6-MP-004 | 打开空调 | open_ac | report-only |
| 4 | C6-MP-005 | 关闭空调 | close_ac | report-only |
| 5 | C6-MP-006 | 空调调到24度 | adjust_ac_temperature_to_number | report-only |
| 6 | C6-MP-007 | 车里有点热 | lower_ac_temperature_by_exp | report-only |
| 7 | C6-MP-008 | 风量调到3挡 | adjust_ac_windspeed_to_number | report-only |
| 8 | C6-MP-009 | 风再大一点 | raise_ac_windspeed_by_exp | report-only |
| 9 | C6-MP-010 | 氛围灯调成红色 | switch_atmosphere_lamp_color | report-only |
| 10 | C6-MP-011 | 打开蓝色氛围灯 | switch_atmosphere_lamp_color | report-only |
| 11 | C6-MP-012 | 氛围灯暗一点 | lower_atmosphere_lamp_brightness_little | report-only |
| 12 | C6-MP-013 | 氛围灯亮一点 | raise_atmosphere_lamp_brightness_little | report-only |
| 13 | C6-MP-014 | 打开车窗 | open_window | report-only |
| 14 | C6-MP-015 | 关上所有车窗 | close_window | report-only |
| 15 | C6-MP-016 | 车窗开到50% | open_window_to_number | report-only |
| 16 | C6-MP-017 | 再开大点 | open_window_little | report-only |
| 17 | C6-MP-018 | 打开主驾车窗 | open_window | report-only |
| 18 | C6-MP-019 | 副驾车窗开一半 | open_window_to_number | report-only |
| 19 | C6-MP-020 | 左后车窗打开 | open_window | report-only |
| 20 | C6-MP-021 | 右后车窗打开 | open_window | report-only |
| 21 | C6-MP-022 | 屏幕太亮了 | lower_screen_brightness_little | report-only |
| 22 | C6-MP-023 | 屏幕亮度调到40% | adjust_screen_brightness_to_number | report-only |
| 23 | C6-MP-027 | 打开空调把温度调到24度 | adjust_ac_temperature_to_number | report-only |
| 24 | C6-MP-028 | 红色氛围灯暗点 | switch_atmosphere_lamp_color; lower_atmosphere_lamp_brightness_little | report-only |
| 25 | C6-MP-029 | 现在车里几度 | query_ac_temperature | report-only |
| 26 | C6-MP-030 | 别让车里这么闷 | open_ac | report-only |
| 27 | C6-TRAP-NEG-001 | 别开空调，把主驾车窗打开一点 | open_window_little | report-only |
| 28 | C6-TRAP-NEG-002 | 别把屏幕调亮，关上所有车窗 | close_window | report-only |
| 29 | C6-TRAP-LURE-001 | 26度有点热，别再查温度 | lower_ac_temperature_by_exp | report-only |
| 30 | C6-TRAP-LURE-002 | 40%不是目标，把屏幕调暗一点 | lower_screen_brightness_little | report-only |
| 31 | C6-TRAP-CORR-001 | 不是车窗，是屏幕亮度调暗 | lower_screen_brightness_little | report-only |
| 32 | C6-TRAP-CORR-002 | 不是空调，是氛围灯亮一点 | raise_atmosphere_lamp_brightness_little | report-only |
| 33 | C6-TRAP-AMB-001 | 有点闷，通通风 | open_ac | report-only |
| 34 | C6-TRAP-AMB-002 | 车里有点压抑，换个舒服点的氛围 | switch_atmosphere_lamp_color | report-only |

## 5. 复跑证据

- C1 自然句来源：`contracts/source-snapshot-manifest.yaml` 指向的 frozen xlsx；仓内 `contracts/semantic-coverage-report.md` 明确 JSONL/YAML 只存 hash，不存明文。
- A/B 训练面来源：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/build/samples/c5-training-samples.jsonl`。
- D 轴来源：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/probe/*.json`。
- 重叠复算：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/OVERLAP-RECOMPUTE.md` 记录 `34 0 4 32 16`。

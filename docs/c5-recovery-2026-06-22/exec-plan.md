# C5 Recovery Contract-v2 Plan（D-or-B 范式未决，辩证裁剪 gptpro WBS + 终审整改）

> ⚠️ **HISTORICAL 快照（2026-06-22）—— 文档级联 banner（2026-06-23）**
> 本文是 C5 recovery 期间「D-or-B 范式未决」时的执行计划中间态历史快照。**范式已定**：第4源真实座舱 TOP 技能表 ground-truth 翻案 = D-domain 具名工具（B-frame/generic frame 否决），见 `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`——本文「D-or-B 未决」前提已不成立。**活基线** = `CLAUDE.md §9` + grill-decisions + paradigm-amend。正文保留供溯源，勿据此推进。

> 基础:GPT Pro D 方案三级 WBS(`~/Downloads/D_plan_3level_WBS_MAformac_C5_PR5.md`)。
> **v3 终审整改(外审「严格审计结论:4 文件整改包」全收)**:① 去 D 方案预设命名(范式未决)② G2.5 混杂干预→ stepwise ablation 矩阵 ③ G1 raw equality→ variant-conditional ④ PCA 补 P9 ⑤ M3.5 拆实验/正式数据 ⑥ 采外审修订 Gate 顺序(范式 ADR 在 ablation+tiny 对照之后)。
>
> **🔁 v4 grill 级联(2026-06-22 grill-with-docs,权威源 = `grill-decisions.md`,本文档下方旧内容凡冲突以 grill-decisions 为准)**:① **两层 SSOT**——能力层 `semantic-function-contract.jsonl`(3990,LoRA训练/C6诊断锚它,客户随意说全集兜底)⊃ 演示层 `demo-golden-run.v1.yaml`(挑选炸场序列,**demo 全部延后**)② **C6 真口径 = `model_action_hard_pass`(tool_name+required_args+state_delta 三维)**,name-only 降 smoke,readback 单列归 renderer(A0)③ **route_tier/no_call_reason/eval_purpose 等从契约 Compiler 派生,不手标、不拍 6 级枚举**(Q1)④ **「CI 门」全部改「`make verify` 本地门」**(D2:仓库无 CI/husky,有 `Makefile:19 make verify` pipeline,新增 surface-consistency/label-conflict/name-first check 进 verify target)⑤ **route_tier 派生统一**——改 `C5RouteTier.derive` 加 value.type 对齐 Q1 L1_para(D1,待磊哥拍 A/B)⑥ safety 从 `risk-policy.yaml` overlay(不回填 C1 risk)⑦ **A1 D/B tiny 对照实验** + **`phase-1-c5-recovery-foundation`** bundle(allowed=compiler/数据修复/G4 ablation/A1;blocked=full_train_until_G4G5/candidate_signing/parity/endpoint)。⚠️ **grill 未走完**(D1 待拍 + grill-checklist G2-G32 未 grill),决策持续级联。
> 配套:[8d-rootcause.md](8d-rootcause.md) / [roadmap.md](roadmap.md) / [grill-checklist-30.md](grill-checklist-30.md)。

---

## 0. 原则（不可越）

- 当前 0/34 candidate **artifact 永久 discarded / unsigned / blocked**(不抢救;与「LoRA recovery approach 仍可救」区分)。
- 任一硬门不过,不进下一步。
- 🔴 **范式未决,不预设 D**:`surface_variant = D_DOMAIN_TOOLS | B_FRAME | C_BRIDGE_DIAGNOSTIC`。ADR 前置条件:`D not selected / B not selected / C diagnostic-only unless runtime adopts`;**ToolContractCompiler 必须同时支持 D 与 B 两种实验 surface,直到 G6 拍板**。
- Qwen3-1.7B 选型:当前证据未翻案,不推翻;但模型 confounder 未经实验排除。

## 1. Gate 链（采外审修订顺序 G0a-G15,范式 ADR 在 ablation+tiny 对照之后)

| Gate | 通过条件 | 对应根因/外审 |
|---|---|---|
| **G0a** C6 口径冻结 | 确定 C6 真 scorer = hard_pass(`C6VehicleToolBench`,state_delta)为准、name-only(spike-e3)降级为 smoke | 两套 scorer 分叉 / 外审 P0-1 |
| **G0b** 成功标准冻结 | `lora-success-thresholds.yaml` 分轴(§8)冻结,含 `cannot_compensate_positive_failure_with_negative_gain` | 外审 P1-3 |
| **G0c** candidate 永久 blocked | 旧 0/34 artifact unsigned/blocked,不进签署链 | — |
| **G1** SSOT 候选核验 + Compiler 支持 D/B | SSOT 候选(C1 / 新 v2 / C1+overlay)核哪个能派生 D-domain + B-frame + verifier/gold;Compiler 支持两实验 surface | 外审 P0-4 / P1-2 |
| **G2** surface/scorer consistency **`make verify` 门**(D2,非 CI:仓库无 CI、有 Makefile) | **variant-conditional equality(§1.6)**:model surface 三层等 + canonical IR 三层等;两套 scorer 不并存;新 check 进 `make verify` 的 `test` target(`test_route_deriver_v2/test_label_conflict_gate/test_surface_consistency/test_training_render_contract`,现仅 test_quarantine+test_fc_flags);stdout receipt 只证据不 gate | SSOT 失守 / 外审 P1-2 / D2 |
| **G3** verify_gold=100% | deterministic gold 在 C6 harness 全 pass;verifier 区分 NO_TOOL vs empty | C6 硬编码 / P5 |
| **G4** stepwise D-fix ablation | **E0-E5 最小可解释矩阵(§1.5)**,逐变量隔离,看分轴指标(非只 empty rate) | 最深缺陷 / 外审 P0-2 |
| **G5** D vs B tiny-overfit 对照 | 双 surface tiny 训练对照,产范式裁决证据 | 范式未决 / 外审 P0-2 E5 |
| **G6** 范式 ADR 最终拍板 | 据 G4+G5 证据拍 `surface_variant`,写 `ADR-tool-surface-v2` | 外审 P0-3 |
| **G7** Data v2 production | 正式 train v2:manifest/hash/redline + 真删工具 + 清矛盾 + name-first + loss-span + near-neighbor split + label门 | 外审 P1-5 |
| **G8** Base C6 v2 baseline | **记 hard_pass 分轴**——按 case schema 拆,recovery 主锚 = `mp_positive_action` **base 10/23**(非整体 7/57 含 readback、非 name-only 25/34);readback 走 P 单列(详 grill-decisions ζ/axes-catch/ε) | empty=hit / 外审 P1-3 |
| **G9** Full action-focused LoRA | action 加权 + refusal cap + collapse monitor | collapse |
| **G10** Full C6 model-quality | 据 G0b 阈值分轴判;positive 不塌缩 + 整体 hard_pass>base + negative 不退化(三者皆须) | 外审 P1-3 |
| **G11** near-neighbor proof | semantic 近邻证明(非只 exact/lineage overlap) | 3.3 |
| **G12** parity | dynamic/fused-bf16/quantized + endpoint byte parity(C6 过后) | — |
| **G13** physical iOS endpoint V-PASS | 真机(simulator 不代替);device receipt 字段齐(§9) | — |
| **G14** heterogeneous final audit | GPT Pro 异构终审 + **实跑一手数据复算**;same-source 不代替 | 审计盲区 / P7 |
| **G15** sign or honest blocked | 全硬门过才签,否则 UNSIGNED/BLOCKED | — |

## 1.5 G4 stepwise D-fix ablation 矩阵（外审 P0-2,替代混杂干预）

> 单 tiny 同改多变量无法归因 = 重蹈「聚合推根因」失误(8D D4.4)。拆最小可解释矩阵,逐变量隔离:

| 实验 | 改动 | 目的 |
|---|---|---|
| E0 | 当前数据 + 修后 scorer,只复算 | 隔离 scorer 口径影响 |
| E1 | 只真删工具,不改 name order | 验 446 矛盾对影响 |
| E2 | 只改 name-first,不改 counterfactual | 验字段顺序影响 |
| E3 | 真删工具 + label_conflict gate | 验数据契约闭环 |
| E4 | E3 + name-first | 验综合修复 |
| E5 | D-domain vs B-frame 双 surface tiny 对照 | 再决定范式(→G5/G6) |

**验收看分轴**(非只 `empty 28/34→<5/34`):`positive_tool_name_exact / positive_required_args_exact / positive_state_delta_exact / positive_hard_pass / NO_TOOL_vs_empty_rate / wrapper_rate / negative_no_call_acc / trap_acc`。

## 1.6 G2 equality（外审 P1-2,variant-conditional 不预设 D)

- **若选 B_FRAME**:`training_render_tool_names == c6_expected == runtime_accepted`(raw equality)。
- **若选 D_DOMAIN_TOOLS(双层)**:拆两条 equality,**不把模型层与内部 IR 混为一谈**:
  ```
  model_surface:  training_render_tool_names == c6_model_tool_names == runtime_model_parser_accepted
  canonical_ir:   normalizer_output_action_primitives == verifier_expected_action_primitives == runtime_internal_ToolCallFrame_IR
  ```
- G6 拍板前 Compiler 两套 equality 都要能验。

## 2. 里程碑（M3.5 拆实验/正式数据,外审 P1-5)

| 里程碑 | 范围 | 周期 |
|---|---|---|
| M0 | 决策冻结:`ADR-tool-surface-v2`(variant 待定)/ `gates-v2` / G0a-c / scope(6 cabin) | 0.5-1天 |
| M1 | ToolContractCompiler(SSOT 候选核 + 支持 D/B 两 surface 派生)+ **RouteDeriverV2**(D1:route_tier 派生唯一函数,inputs=`clarify_tag/fc_flags{fuzzy,free}/value.type/second_turn_refs`、**不含 exec_tier**[`:2099` 注释明确排除];training_render/c6_labels/verifier 全调同一实现 + `assert_training_c6_route_label_parity`;**先于 G4/A1**否则对照被分叉污染) | 2-4天 |
| M2 | Surface/Runtime 闭环(variant-conditional equality(make verify 门)+ scorer 统一) | 2-3天 |
| M3 | Gold/Verifier(verify_gold=100% + NO_TOOL/empty 区分) | 3-5天 |
| **M3.5a** | **Experimental D-fix dataset patch**(临时实验数据,非正式 train v2) | 0.5天 |
| **M3.5b** | **Tiny ablation receipt**(E0-E5 矩阵,只证方向不产正式数据) | 1-2天 |
| M4(原)→ 并入 G5/G6 | D vs B tiny 对照 + 范式 ADR 拍板 | 1天 |
| **M5** | **Production Data v2 hardening**(正式 manifest/hash/redline,据 G6 范式) | 2-4天 |
| M6 | Base C6 v2 baseline(hard_pass 分轴) | 1-2天 |
| M7 | Full action-focused LoRA | 2-5天 |
| M8 | Parity + 真机 endpoint V-PASS | 3-7天(看真机) |
| M9 | Final 异构审计 + sign/blocked | 1-2天 |

> **M3.5 只证方向,不产正式 train v2;M5 才产正式 manifest/hash/redline。**

## 3. 关键路径

```
G0a/b/c 口径+阈值+blocked 冻结 → G1 SSOT候选+Compiler双surface → G2 consistency(make verify 门) → G3 verify_gold=100%
  → G4 stepwise ablation(E0-E5) → G5 D/B tiny对照 → G6 范式ADR拍板 → G7 Data v2 → G8 base baseline
  → G9 Full LoRA → G10 Full C6 → G11 near-neighbor → G12 parity → G13 真机 → G14 异构审计 → G15 sign|blocked
```
硬前置(任一不过停):Compiler/consistency/verify_gold 不过不重训;**ablation 不能逐变量归因则停下重查(可能第 N 根因)**;**范式未经 G5/G6 不得在 G7+ 预设 D**;base 不记 hard_pass 不宣称提升;C6/真机/异构审计任一不过不签。

## 4. P1-P9 PCA 映射（8D D5 → 执行,补 P9)

| PCA | WBS/Gate | 验收 receipt |
|---|---|---|
| P1 ToolContractCompiler | M1/G1 | compiler 输出 + make verify contract check |
| P2 真删工具 | M5/G7(改 `buildNoCallSamples:2333` 加 `tools.removeAll`) | counterfactual tools 不含目标工具(亲核脚本) |
| P3 label_conflict 门(key 用实际 prompt 文本非 metadata) | M5+C5DataGate | 同 (system,user,tools文本) 既 TOOL 既 NO_TOOL → P0 fail |
| P4 name-first 渲染 | M5/G7(改 `render:2409`,canonical hash 独立层) | 训练样本 100% name-first(亲核) |
| P5 C6 empty≠no-call | M3/G3(改 `spike-e3:157-162`) | empty collapse 不记 no-call hit |
| P6 surface+scorer consistency(make verify 门) | M2/G2 | make verify fail on intersection=∅ / 两套 scorer 并存 |
| P7 审计补语义维度 + 实跑复算 | G14 + 审计 SOP | 审计含语义门 + 强制 python 复算/下钻 axis |
| P8 grill frame 纪律 | grill-with-docs | checklist 含「训练/eval/runtime 同源」一问 |
| **P9 recovery 成功标准 + scorer 统一 + spec 物理删契约** | G0a/G0b/M1/M5 | `lora-success-thresholds.yaml`(§8) + unified-c6-scorer-receipt + spec physical-delete patch |

## 5. 并行推进（与 UIUE / 真机）

| 并行线 | 现在可做 | 不可越门 |
|---|---|---|
| C5 架构 | ADR(variant 待定)/ Compiler / IR schema | consistency 未过不重训 |
| C5 数据 | 真删工具脚本 / label门 / 矛盾清洗 | contract+范式 未锁不产正式 train v2(M5) |
| C5 eval | verifier / mock executor / readback / empty区分 | verify_gold≠100% 不进训练 |
| UIUE | 调研归位 docs/research + HTML 低保真(raw) | **C5 contract version freeze 后才进 SwiftUI code**(硬门) |
| 设备 | 真机采购/借测/UDID/证书(receipt §9) | 不代替 C6 |

## 6. 立即行动（M0,中立命名)

1. grill-with-docs 过 34 议题(顺序见 grill A0→D→B/C/E→实验设计→范式 ADR→F/G/H),冻结 G0a/b/c。
2. 锁 6 cabin scope(不扩 102 全量)。
3. 起 openspec change(`tool-surface-v2` contract + ToolContractCompiler,支持 D/B 双 surface)。
4. Compiler 最小版(生成 D-domain + B-frame + runtime enum,支持两实验 surface)。
5. surface+scorer consistency(make verify 门)。
6. 改 `buildNoCallSamples:2333` 真删工具 + `C5DataGate` 加 label门(实际 prompt 文本 key)。
7. verify_gold + **G4 stepwise ablation(E0-E5)证数据根因 + G5 D/B 对照**,再 G6 拍范式,再正式重训。
8. 并行:真机采购 + UIUE 调研归位。

## 7. 最终签署口径

```
G0a/b/c 冻结 AND SSOT候选+Compiler双surface AND consistency(make verify 门) AND verify_gold=100%
AND G4 stepwise ablation 逐变量归因 AND G5 D/B 对照 AND G6 范式ADR拍板
AND Data v2 production AND base hard_pass baseline AND Full C6 model-quality(三轴皆过)
AND near-neighbor proof AND parity AND physical iOS endpoint V-PASS AND heterogeneous final audit
→ candidate sign;否则 UNSIGNED/BLOCKED honest closeout
```

## 8. `lora-success-thresholds.yaml` 分轴（外审 P1-3,防 negative 提升掩盖 positive 塌缩）

```yaml
positive_vehicle_action:
  tool_name_exact_min: TBD        # G0b grill 定
  required_args_exact_min: TBD
  state_delta_exact_min: TBD
  hard_pass_min: TBD
  wrapper_rate_max: 0             # 禁 generic tool_call/tool_call_frame wrapper
  empty_rate_max: TBD
negative_no_call:
  no_call_acc_min: baseline - delta
  empty_as_no_call_allowed: false # empty 不准算 no-call(防 irrel_acc 虚高)
trap:
  false_action_rate_max: TBD
heldout_must_not_train:
  hard_pass_min: TBD
  must_improve_over_base: true
overall:
  hard_pass_min: baseline + delta
  cannot_compensate_positive_failure_with_negative_gain: true  # 🔴 核心:禁用 negative 提升掩盖 positive 塌缩
```

## 9. device procurement receipt 字段（外审 P2-3)

```yaml
device_model: / ios_version: / udid_registered: / developer_cert_valid_until:
build_id: / endpoint_binary_hash: / tokenizer_asset_hash: / test_timestamp: / operator:
```

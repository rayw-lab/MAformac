# A2-before Baseline Receipt（S_INIT freeze）

> 2026-06-23 · A2 代码重构执行主窗口（CC ultracode + /goal）起手 freeze。
> 用途 = incremental 重构的【回滚锚 + 不退化对照】。A2 每 step 后三门须 ≥ 此基线，C6 gold parity 比【相对此基线不退化】（非绝对全绿）。
> 🔴 A2 边界 = code-only 范式对齐（generic frame `tool_call_frame` → D-domain 具名工具，canonical IR 仍 device×action）；不训练、不评模型性能、不生成语料。

## 1. Git baseline
- branch: `a2/migrate-d-domain-tool-surface`
- HEAD commit: `2ffaabc`（docs(a2): 派单 + harness 归档同步进仓 + 路径指针统一）
- working tree: clean（make verify 后无漂移，git status --short 空）

## 2. 三门状态（A2-before，全绿，主线程亲跑 exit code）
| 门 | 命令 | 结果 |
|---|---|---|
| 编译 | `swift build` | **exit 0** ✓ |
| Swift 测试 | `swift test` | **exit 0** ✓（SPM target `MAformacCoreTests`，`Package.swift:49`）|
| 契约/级联门 | `make verify` | **exit 0** ✓ — `caliber_violations:[]` / `consistent:true` / `drifts:[]` / diff gate 过 / test_quarantine ok / test_fc_flags ok |

> `make verify` 链路（`Makefile:19`）= verify-source(freeze check) → regen(gen_c1 + gen_tool_contract) → verify-refs → verify-cross-section → diff(`git diff --exit-code`) → test(quarantine + fc_flags)。
> 🔴 `make test` 只跑 Python 测试，**无 swift test gate**；swift test 是独立命令（A2 每 step 须两者都跑）。

## 3. C6 gold baseline（A2-before，验格式/链路自洽，**不需 LLM 推理**）
A2 的 C6 golden parity gate = 结构自洽门，**不评模型性能**：
| 检查 | 命令 | 结果 |
|---|---|---|
| Python surface 自洽 | `python3 scripts/verify_gold.py` | `gold_apply_100:true` / `total_cases:57` / `violation_count:0` ✓ |
| Swift gold replay | `swift run C6BenchCLI verify-gold --repo-root . --output-dir <dir>` | `status=pass cases=57 candidates=59 gold_replay_pass=57 gold_replay_fail=0` ✓ |

- verify_gold 语义（`scripts/verify_gold.py:9`）= gold(expected_tool_calls) well-formed + 工具名 ⊆ `generated/D_domain.tools.json` surface。
- `summarize` 子命令才需 `--model-results`（实际模型推理 envelope）= **A2 不跑**（不评性能，DEFERRED）。

## 4. 当前 model-visible surface（A2-before，待迁移目标）
- `generated/D_domain.tools.json` = **6 旧 B-frame 粗具名工具**：`query_cabin_comfort` / `set_cabin_ac` / `set_cabin_ambient_light` / `set_cabin_fan` / `set_cabin_screen_brightness` / `set_cabin_window`（spike 冻结）。
- `contracts/c6-bench-cases.jsonl` = 57 行（34 行用上述旧粗具名 + 23 行空 negative/no-call）。
- generic frame `tool_call_frame` 仍在主链路 emit（`Core/Contracts/ToolContractCompiler.swift:27` name + `Core/Training/C5LoRATraining.swift:2362` 正样本）；对照 `Core/Training/C5LoRATraining.swift:2344` `removedToolID:"tool_call_frame"` metadata 声称删 = claim-vs-reality 铁律1 活样本（frame 真删须 grep 行为门核，非信 metadata）—— A2 显式移除目标。

## 5. 口径实算（H1 主线程亲核，python 实算坐实，**非凭印象**）
全集（`contracts/semantic-function-contract.jsonl` 实跑）：
- 行数 = **3990**（wc -l）
- unique `device` = **671** ✓（对齐 grill-master §0:28）
- unique `intent` = **1538** ✓（🔴 字段名是 `intent` 非 `intent_id`；后者实算 0，主线程亲核 catch，claim-vs-reality 兑现）
- unique `action_primitive` = 141 / unique `service` = 3

10 族 / 族外（权威值，待 S0 落盘 scope_tier/allowlist manifest 后本机实算坐实）：
- 10 族 = **191 device / 562 intent / 2159 行（54.1% = 2159/3990）**（source: grill-master §0:30 + paradigm §14:158；磊哥 2026-06-23 终拍 562）
- 族外 = **480 device / 976 intent / 1831 行**（source: §0:32）
- 工具数 = **未拍，待 value-form 实算**（562=intent 非工具数；col O 优先级在 raw xlsx 第15列不在 jsonl）—— S0 G2 实算

## 6. jsonl schema（32 字段，**无 scope_tier**，S0 硬前置真实）
`action_code / action_primitive / canonical_semantic_id / clarify_tag / contract_row_id / dedupe_group_id / dedupe_role / device / ds_protocol / evidence_ref_kind / example_utterance_hash / example_utterance_kind / exec_tier / execution_range_ref / external_evidence_ref / fc_flags / intent / primary_selection_rule_version / range / range_class / range_ref_kind / redaction_state / risk / second_turn_refs / service / slot / slot_keys / source_domain / source_row_hash / source_row_no / source_sheet / value`
- `value` = 四件套 `{direct, offset, ref, type}`（D-domain 工具名 value 形态编码源）
- `device × action_primitive` = canonical IR（对系统）；`intent` = D-domain 工具命名源（对模型）
- grep `scope_tier` contracts/ generated/ = **0 命中**（S0 必先落盘）

## 7. 关键文件 sha256（A2-before 冻结指纹，迁移后比对）
```
efafb06cbfdfd50656678cd0aa61e22836e4d25ffc73ac70db8ed0a265d52bea  contracts/c6-bench-cases.jsonl
d3852654400304a9d252f7facae513ae68823ea2e6f840ada07a3d1149916929  generated/D_domain.tools.json
67c632eff99c8b9c764a0024ab43920d156468443b295138e8fd0cdb2f9f6e11  generated/10-family-device-map.json
a242ba0c62fecda08f860e583176b99e13ca4c6708e0313f1d76cb98f77d0814  contracts/semantic-function-contract.jsonl
fca3f10f9e2a0e9f2dd04fb13c96e4877de0b70351445de5425e4a0f156c1df6  contracts/state-cells.yaml
```

## 8. action hard_pass base 锚（freeze，**A2 不重跑**，延后评测对照）
- action hard_pass base = **10/23**（按 case schema 字段拆 `mp_positive_action` n=23，非 case_id naming prefix）。
- 🔴 source = C5 recovery `docs/c5-recovery-2026-06-22/grill-decisions.md`（`c6-summary.json:eval_runs[].gate_result` 下钻坐实）；**本 session 未重算**（A2 不评模型性能，DEFERRED 待延后阶段 grill Q06）。
- A2 阶段不跑 LoRA/base 模型推理评性能；此锚仅 freeze 供 retrain/rebuild 阶段对照。

## 9. S_INIT gate
- [x] swift test 入口确认（`Package.swift` SPM `MAformacCoreTests` + `MAformac.xcodeproj` 并存）
- [x] 起手必读 7 件读毕（dispatch §I / CLAUDE §9 / a2-audit README / paradigm §14-§17 / grill-master §0 / cascade-inventory / claim-vs-reality）
- [x] 三门 A2-before baseline freeze（全绿）
- [x] C6 gold baseline freeze（57 cases pass）
- [x] sha256 + 口径实算 + schema 冻结
- 无代码改动（S_INIT 不 commit，receipt 随 S0 doc 一起 commit 或单独 docs commit）

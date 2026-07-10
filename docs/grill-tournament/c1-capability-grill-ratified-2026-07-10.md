---
authority: c1_capability_grill_decision_ssot
status: RATIFIED_D133
decision: D-133
date: 2026-07-10
source_ballot: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-08-daywork/BATCH-C1-1-ballot.md
proof_class: decision_record
---

# C1 能力面 Grill 决议（D-133，38/38=⭐B）

## 范围与口径

- D-133 将 BATCH-C1-1 P0 的 38 题全部按 ballot ⭐B 拍定；CG-021 已是 ALREADY_DECIDED，不计入 38；C1 P1 的 39 题（depends_on D0G）不在本拍。
- `DemoCapabilityMatrix` 内容口径：**120 = 10 族 × 4 `value_shape` × 3 `register`**。
- 主分类账：`unmounted_name_rejected=36`、`fast_path_no_match_fallback=82`、`default_executable=1`、`conditional_ddomain_executable=1`；`safety_or_clarify_reject=0`。四主类合计 120；safety=0 是当前矩阵归因，非全局安全拒识为零。
- 沿用 MG-2=C：source=`contracts/demo-capability-matrix.json`，Swift 为派生；`canDemo = mounted && semantic && stateCell && readbackProbePass`；FastPath 只算 `entrypointAlias`。
- 挂载分档仍为 S10 `<40%` 不扩、`40–70%` 3 族主 cell、`>70%` 10 族主 cell；`joint = min(hedged, can_question)`。CG-080 不授权 mounted 1→N，仍等待 S10+A1+磊哥键。

## 38 项决议表

| CG | RATIFIED（⭐B） |
|---|---|
| CG-002 | `contracts/demo-capability-matrix.json` 作源，docs 解释、Swift 派生。 |
| CG-004 | checker 必须逐格核 basis，120 行守恒不足以防人工补绿。 |
| CG-005 | `canDemo=false` 也必须有 `primary_class`/`fallback_reason`。 |
| CG-007 | mounted catalog 推 matrix，matrix 不反向开白名单。 |
| CG-008 | semantic 存在而 mounted 缺失归 `unmounted_name_rejected`，走未挂载 fallback。 |
| CG-009 | 无 representative tool 的 6 格入 120 checker，标 `no_representative_tool__default_fallback`。 |
| CG-014 | `conditional_ddomain_executable` 不计入 default `canDemo`，只作 conditional lane。 |
| CG-015 | `register_emission_unproven` 须 S9/S10 或 runtime receipt 证明稳定 emit+readback 才可升级。 |
| CG-019 | `fast_path_no_match_fallback=82` 只能写 fallback/no-match，不等于 semantic rejection 成功。 |
| CG-022 | 可归族且 mounted 缺失的 `name_rejected` 归未挂载，不泛化为“不支持”。 |
| CG-023 | `fast_path_no_match` 归 unsupported/no available tool，不暗示模型理解失败。 |
| CG-024 | safety_refusal 入 SSOT，但 runner 未闭环标 `typed_gap`。 |
| CG-025 | clarify_missing_slot 入同一 fallback catalog，result kind 是 clarify，不叫 refusal。 |
| CG-026 | 10 族×4 reason 的 40 格必须全覆盖，缺格 fail。 |
| CG-027 | fallback 文案 SSOT 为 `contracts/fallback-scripts.yaml` + generated catalog。 |
| CG-028 | UI 卡片角标不能替代 TTS/dialogText；dialog/TTS 读 SSOT。 |
| CG-036 | 多意图可 partial 执行可执行部分，未执行部分给对应 reason。 |
| CG-038 | 内部保留 raw `finiteReason`，客户面只显示 safe `reasonKind`/family 文案。 |
| CG-039 | reason enum 不允许自由字符串扩展；新增同步 schema/checker/tests。 |
| CG-041 | fallback 双指标是 in-scope execution pass rate 与 out-of-scope fallback quality/generic leakage。 |
| CG-044 | 每族每 reason probe 必断言 no tool call + state unchanged。 |
| CG-045 | fallback 质量门失败阻塞新增 `canDemo=true`，但允许预铺。 |
| CG-048 | hedged=0.90、can-question=0.35 时 `joint=0.35`，不扩。 |
| CG-049 | hedged=0.35、can-question=0.90 时 `joint=0.35`，不扩。 |
| CG-050 | S10 缺 `joint_strike_rate` 即 BLOCKED，不以 prose 或 primary pass rate 替代。 |
| CG-053 | >70% 档为每族 1 主工具，不等于全 562 或全 120。 |
| CG-054 | <40% 可预铺 matrix/fallback/probes，但不新增 mounted `canDemo`。 |
| CG-055 | 挂载后 golden/readback 失败，回滚 mounted delta、降级 matrix `canDemo`，保留 fallback。 |
| CG-057 | 预铺改 contracts/fallback/probes；挂载另改 catalog/runtime/golden。 |
| CG-058 | mounted catalog delta 必同批或前置有 matrix planned row，且 checker 绿。 |
| CG-059 | 新挂载族必须同时补 fallback 文案。 |
| CG-060 | 新挂载族主 cell 必进 golden；每扩一族新增 C6 case。 |
| CG-063 | FastPath 命中未 mounted 工具名不得执行，只映射 mounted/approved action。 |
| CG-065 | 扩 FastPath 不能单独提升 matrix `canDemo`，仍须四件套。 |
| CG-068 | `fast_path_no_match -> unsupported_no_available_tool`。 |
| CG-074 | C3 `ToolExecutionError` 必映射 typed fallback/clarify/safety payload，不能崩或吞成 runtime_error。 |
| CG-076 | C3 fallback trace 必录 family/reasonKind/finiteReason/state_mutation=false/speech_text。 |
| CG-080 | C1 仅定 schema/门/流程；mounted 1→N 由 C2 按 S10+A1+批次与磊哥键执行。 |

## Non-claims

- 本决议不是 `contracts/`、checker、runtime、测试或 CI 已落地的声明；相应文件仍须经实施计划、对抗审和编码验证。
- 不扩 mounted 1→N；不签 C5 V-PASS、C6 acceptance、candidate、mobile、true-device 或 live_api proof。
- `conditional_ddomain_executable=1` 不得升格为 default executable 或产品验收。

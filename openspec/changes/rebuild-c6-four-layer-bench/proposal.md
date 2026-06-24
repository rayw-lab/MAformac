> ⚠️ DRAFT SKELETON（2026-06-23 第一个长跑起草，标 DRAFT 待人审 propose）
> 本 change 仅为骨架：proposal Why/What Changes 指向已拍决策，design.md 承载 Architecture Decisions，specs delta 占位待补，tasks 待细化。
> **守 agree-before-build：人审定 propose 前不进 apply、不写实现代码。** 决策权威源见下。
>
> 🔴🔴 **DEFERRED 延后（磊哥 2026-06-23「训练 + 后端开发延后」决策）**：本 change 的【四层评测门 / 实际评测验证模型性能】部分**延后不排期，A2 之后独立重新立项**。**仅 §2「expected_tool_calls 迁 D-domain 具名工具」(code-only) 属 A2、随 `migrate-d-domain-tool-surface` 完成**；§3 四层评测门(Q41 各独立 scorer) / 跑 LoRA 实际评测验证 = **DEFERRED**。A2 阶段 C6 只【跑 base 验格式/链路对齐 D-domain】(archive-check verify-gold pass) + freeze A2-before baseline receipt，**不评 LoRA 模型性能、不建四层门**；模型性能 parity 抽样轴/阈值待 grill Q06。

## Why

C6 vehicle-tool-bench 现 expected_tool_calls 用旧 generic frame `tool_call_frame`（c6-bench-cases.jsonl 57 行仍旧 frame），范式翻案后须迁 **D-domain 具名工具**。C5 0/34 灾难暴露 C6 评测口径问题：action hard_pass 真口径 = 按 case schema 字段拆（base 10/23），readback 走方案 P（端 renderer 出话术，删 eval 不计 hard_pass），clarify 全保留计 hard_pass（安全拒识澄清 = demo 灵魂）。

本 change = A2 6 步依赖序 **[5] C6 MP / coverage / readback** 段，依赖 `migrate-d-domain-tool-surface`（D-domain surface）+ `retrain-c5-lora-d-domain`（candidate 做 base-vs-LoRA diff）。重建 C6 为 **四层评测门**（golden 100% 硬门 / demo_fuzz / unsupported / safety 各独立门，禁互相冒充）。

**决策权威源**：
- C6 真口径 + readback 方案 P：`docs/c5-recovery-2026-06-22/grill-decisions.md`（C6 action hard_pass 锚 base 10/23 按 case schema 字段拆 / readback 走方案 P renderer / clarify 全保留）
- 范式 surface：`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`（§17 [5] readback 改 renderReadback SSOT）
- 四层 + Q41 验收分层：paradigm §18 Q41（T-PASS/G6-C/C6 model-quality/endpoint candidate/demo-golden-run/V-S-U-PASS 禁互相冒充）
- 现有 bench 契约：archived `openspec/specs/vehicle-tool-bench/spec.md`（base Qwen3-1.7B hard_fail IrrelAcc 0.789 为 LoRA 提升诚实锚点）
- 级联账本：`docs/grill-tournament/cascade-inventory.md`

## What Changes

> 以下指向已拍决策，**具体逐文件改法 = `docs/grill-tournament/cascade-inventory.md` 各 path 的 verdict + what_to_change**。

- **expected_tool_calls 迁 D-domain**：`qwen-tool-call-format.yaml` 定义 D-domain 工具名集合与字段映射（非 generic frame）；`c6-bench-cases.jsonl` expected_tool_calls 映射 D-domain 具名工具名（57 行旧 frame → migration，`tool_call_frame`→真实工具名如 `adjust_ac_temperature_to_number`）；P0-3 陷阱样本同步确认 expected 工具名。
- **四层评测门**（cascade-inventory T1 `vehicle-tool-bench/spec.md` verdict）：golden 100% 硬门 / demo_fuzz / unsupported / safety 各独立门，禁互相冒充（Q41）。
- **action hard_pass 真口径**：按 case schema 字段拆（mp_positive_action n=23，非整体 7/57）；base 10/23 硬锚。
- **readback 走方案 P**：端 renderer 出话术（renderReadback SSOT），eval 删 readback 不计 hard_pass，gold 不改；clarify 全保留计 hard_pass（安全拒识澄清 = demo 灵魂）。
- **expected_tool_calls 扩 scope**：从旧 6 工具扩到 10 族炸场子集。
- **base-vs-LoRA 同 harness**：同 prompt/parser/mock-state/scoring/replay fingerprints；C6 release final-only，不用于 checkpoint selection。
- spec MODIFY：`vehicle-tool-bench`（四层门 + D-domain expected_tool_calls + base hard_fail 0.789 锚）。

## Phase 0 Decisions Required Before Apply

The D1-D10 user decisions are accepted in `docs/project/phase0/phase0-d1-d10-user-decision-record.md`. This removes the pending user-decision gate only; it does not authorize D-domain base recalibration, model-quality evaluation, endpoint-ready claims, voice, or demo-golden execution.

- D1: four-layer denominators derive from case schema fields. Old base 10/23 is historical evidence until a D-domain base rerun is separately authorized.
- D2: C6 sample runners support iter50/100/150 C5 behavior-generation gates, but C6 release cases are not checkpoint-selection oracles.
- D-domain base recalibration is a future comparison anchor task, not permission to run recalibration during Phase 0.
- C6 model-quality evidence does not imply endpoint readiness, demo-golden readiness, V-PASS, S-PASS, or U-PASS.
- D10 `already_state` touches status/readback semantics and must remain distinct from unsupported and safety refusal.
- Codex/Claude same-vendor audits are pre-check only. R-L17 high-stakes signoff requires G1-G5: D1-D10 accepted, R1-R7 evidence files, at least one heterogeneous deframing audit, no four-model consistent-PASS bypass, and human-owner escalation for any judge disagreement.
- Real model-quality evaluation, endpoint-ready claims, voice, and demo-golden execution remain deferred until gate tasks are accepted.

## Design/Task Layering

Architecture Decisions are recorded in `design.md` as `AD-C6-*`. `tasks.md` only carries executable checklist items, evidence artifacts, and validation steps that implement those decisions.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `vehicle-tool-bench`: expected_tool_calls 迁 D-domain；四层评测门（golden/demo_fuzz/unsupported/safety 独立）；action hard_pass 真口径 base 10/23；readback 走方案 P。

## Non-Goals

- 不改 C6 为 ASR/audio/iOS runtime bench（C6 是 Mac 文本/transcript bench，ASR 属 C7 不当 C6 硬门）。
- 不改 base hard_fail 锚（IrrelAcc 0.789 为 LoRA 提升诚实锚点，不洗白）。
- 不放宽判等冒充提升（7 demo-critical case 要训练改善，非改判等）。
- 不用 C6 release cases 做 checkpoint selection（final-only）。
- 不互相冒充验收层（Q41：golden/demo_fuzz/unsupported/safety/model-quality/endpoint 各独立）。
- 不在 demo eval 计 readback 进 hard_pass（走方案 P，端 renderer 确定性生成 vs 模型智能决策分流）。
- 不复制真实座舱原文语料进 bench cases（分级脱敏红线）。

## Success Criteria

> DRAFT 占位，propose 时细化为可验收标准。骨架方向：

- `openspec validate rebuild-c6-four-layer-bench --strict` + `--all --strict` pass。
- `c6-bench-cases.jsonl` expected_tool_calls 全为 D-domain 具名工具，无 `tool_call_frame` 残留；`archive-check verify-gold` pass。
- 四层门各独立计分（golden 100% 硬门 / demo_fuzz / unsupported / safety），无互相冒充。
- Architecture Decisions for R-L04/R-L05/R-L11/R-L17, D-domain base anchor semantics, and status boundaries exist in `design.md`; `tasks.md` references those ADs rather than carrying the decision source alone.
- action hard_pass 按 case schema 字段拆（base 10/23 硬锚），非整体 7/57。
- readback 走方案 P（端 renderer，eval 不计 hard_pass）；clarify 全保留计 hard_pass。
- base-vs-LoRA 同 harness（prompt/parser/mock-state/scoring/replay fingerprints digest 一致）。
- candidate（来自 retrain-c5）相对 base 10/23 不退化 → 目标提升。

## Impact

- 影响 `Core/Bench/C6VehicleToolBench.swift`、`contracts/c6-bench-cases.jsonl`、`contracts/qwen-tool-call-format.yaml`、readback renderer（renderReadback SSOT，逐文件改法见 cascade-inventory）。
- 依赖 `migrate-d-domain-tool-surface`（D-domain surface）+ `retrain-c5-lora-d-domain`（candidate）。
- delta spec：`specs/vehicle-tool-bench/spec.md`。
- 依赖 archived `openspec/specs/vehicle-tool-bench/spec.md`。
- 下游：define-demo-golden-run-and-voice 用 C6 must_pass + c6_case_id_derived 关联 golden run。

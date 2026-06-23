<!--
DRAFT SKELETON (2026-06-23) — tasks 占位待细化，人审定 propose 时展开为可验收逐项。
依赖序：本 change = A2 [5] C6 MP/coverage/readback，依赖 migrate-d-domain([1] codegen) + retrain-c5(candidate)。
incremental，禁大爆炸。
-->

## 1. 前置依赖

- [ ] 1.1 确认 `migrate-d-domain-tool-surface` 已 archive（D-domain surface + 工具数实算）。
- [ ] 1.2 确认 `retrain-c5-lora-d-domain` candidate 可引用（做 base-vs-LoRA diff）。

## 2. expected_tool_calls 迁 D-domain（[5]）

- [ ] 2.1 `qwen-tool-call-format.yaml` 定义 D-domain 工具名集合 + 字段映射（DRAFT 待细化）。
- [ ] 2.2 `c6-bench-cases.jsonl` 57 行迁 D-domain 具名工具（migration，`tool_call_frame`→真实工具名）+ P0-3 陷阱样本确认。验证：`archive-check verify-gold` pass。
- [ ] 2.3 expected_tool_calls 从旧 6 工具扩到 10 族炸场子集。

## 3. 四层评测门（Q41）

- [ ] 3.1 golden 100% 硬门 / demo_fuzz / unsupported / safety 各独立门（DRAFT 待细化各门 scorer）。验证：四层独立计分，无互相冒充。
- [ ] 3.2 action hard_pass 按 case schema 字段拆（mp_positive_action n=23，base 10/23 硬锚）。
- [ ] 3.3 readback 走方案 P（端 renderer renderReadback SSOT，eval 删 readback 不计 hard_pass，gold 不改）。
- [ ] 3.4 clarify 全保留计 hard_pass（安全拒识澄清 = demo 灵魂）。

## 4. base-vs-LoRA 同 harness

- [ ] 4.1 同 prompt/parser/mock-state/scoring/replay fingerprints；C6 release final-only 不用于 checkpoint selection。
- [ ] 4.2 base hard_fail 0.789 锚保留（LoRA 提升诚实锚点不洗白）。

## 5. 验证与收口

- [ ] 5.1 `openspec validate rebuild-c6-four-layer-bench --strict` + `--all --strict` pass。
- [ ] 5.2 填实 vehicle-tool-bench spec Purpose（现 TBD）。
- [ ] 5.3 红线检查：无原文语料/PII 进 bench cases。

<!--
DRAFT SKELETON (2026-06-23) — delta 占位待补，人审定 propose 时细化 Requirement/Scenario。
本 delta ADDED 新 capability `demo-golden-run`（target: openspec/specs/demo-golden-run/spec.md，new_file）。
方向锚（cascade-inventory T1 new_file + paradigm §18 U8/U9 + F3 + grill-decisions BG3）：
  - SSOT schema = [step_id/act_id/utterance_zh/expected_readback/source_contract_row/contract_refs/
    expected_route_derived/must_pass/uiue_scene_tag/c6_case_id_derived]。
  - 合同回放(非脚本回放)：升级「合同回放」，关联 C6 must_pass + UIUE 五幕 + L1 覆盖。
  - 未建 state cell 步禁进 golden（U9/Q37）。
  - 炸场 case 锁 10 族（现场不脱靶，B3）。
  - K_abs = required must_pass step count（F3 DEFERRED 不拍数，解冻后推）。
  - 不新起独立演示编排 change → 并入本 carrier（U8）。
-->

## ADDED Requirements

### Requirement: golden run SHALL be a contract replay with full step schema
`contracts/demo-golden-run.v1.yaml` SHALL 为炸场合同回放 SSOT，每 step SHALL 含 [step_id/act_id/utterance_zh/expected_readback/source_contract_row/contract_refs/expected_route_derived/must_pass/uiue_scene_tag/c6_case_id_derived]；未建 state cell 的 step SHALL NOT 进 golden；炸场 case SHALL 锁 10 族。
> DRAFT 占位 — Requirement/Scenario 待人审 propose 时按 paradigm §18 U9 + F3 + cascade-inventory T1 demo-golden-run verdict 填实。

#### Scenario: golden step links C6 case and state cell (placeholder)
- **GIVEN** DRAFT 骨架（占位 Scenario，待 propose 填实）
- **WHEN** 人审定 propose
- **THEN** 在此填实 Scenario（step schema 完整、c6_case_id_derived 关联、未建 cell 步被拒、10 族锁定）

### Requirement: golden run SHALL carry UIUE physical anchors
golden run SHALL 关联 UIUE 物理落点（presentation_kind dial/card/badge、ambient_color_wash golden step、DemoVisualState 7 态分显 clarify/unsupported/safety_refusal/crash）；U11-U31 待续批。
> DRAFT 占位 — Requirement/Scenario 待人审 propose 时按 paradigm §18 U1-U10 + uiue-ultracode 落档填实。

#### Scenario: UIUE anchors are contract-backed (placeholder)
- **GIVEN** DRAFT 骨架（占位 Scenario，待 propose 填实）
- **WHEN** 人审定 propose
- **THEN** 在此填实 Scenario（U1-U10 物理落点验证、七态分显、demo 脚本占位→真实话术）

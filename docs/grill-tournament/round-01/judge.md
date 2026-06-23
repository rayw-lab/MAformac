# Round 01 Judge

## Scope

Round 01 focused on A2 dispatch foundations: AUD1-AUD6 plus the highest-leverage GOV/TRN/CAS overlaps. Four independent brain reviews were written to `brain-1.md` through `brain-4.md`.

## Candidate Verdicts

| ID | Topic | Avg score | Verdict | Judge rationale |
|---|---|---:|---|---|
| R1-Q01 | AUD2/G2 tool-count口径 | 24.0 | Keep, rewrite | Essential mouth-of-funnel question. It must force a reproducible count and keep `intent`, `tool`, `device`, `value_form`, and runtime mount scope separate. |
| R1-Q02 | AUD1 generated drift gate | 24.0 | Keep | Strongest mechanical gate question. It can be verified directly against `Makefile`, generated artifacts, and a regen-diff gate. |
| R1-Q03 | AUD3/GOV2 governance carrier | 20.0 | Keep, rewrite; sequence before R1-Q08 | Important but too broad as written. It must become a dispatch carrier rule: amend vs OpenSpec change, blocker conditions, change split, and archive exit criteria. |
| R1-Q04 | AUD4 demo/full 双层 codegen | 23.0 | Keep, rewrite | Valid distinct question from tool count. It must output a two-scope artifact/field matrix and prove both scopes come from one source, not two SSOTs. |
| R1-Q05 | AUD5/TRN2 surface同源 enforce | 24.0 | Keep | High-priority PR5 repeat-prevention question. Requires fail-closed `train/eval/runtime` inventory diff, not prose discipline. |
| R1-Q06 | AUD5/GOV6/TRN3 training midpoint C6 gate | 22.25 | Keep, merge R1-Q09 into this | Strong technical gate. It should absorb workflow/process checks from Q09 and require checkpoint 50/100/150 artifacts, thresholds, and sign-or-block semantics. |
| R1-Q07 | AUD6/CAS1 full-repo cascade list | 23.0 | Keep, rewrite | Necessary cascade audit entry. Must avoid bulk replacement and produce per-hit adjudication, with historical receipts separated from live contracts/docs. |
| R1-Q08 | GOV1 archived specs impact | 20.75 | Keep, rewrite; sequence after R1-Q03 | Good OpenSpec SSOT question if constrained to observable behavior and requirement/scenario-level impact. Include `lora-training`, not only C1/C3/C6. |
| R1-Q09 | GOV6 disaster-prevention process | 16.0 | Drop standalone; merge into R1-Q06 | Weakest standalone. The useful part is not the Superpowers label but concrete training-precheck, mid-training, and signoff gates with receipts. |

## Final Round 01 Questions

1. **R1-Q01 Tool-count口径**: A2 派单前必须如何实算 demo runtime 的 model-visible 具名工具数？输出 `intent_id / device_id / value_form / proposed_tool_name / runtime_mounted / training_scope / priority_source / source_ref`，并明确禁止把 `534 intent` 写成工具数。
2. **R1-Q02 Generated drift gate**: A2 新增或更新的 `generated/` 产物哪些必须进入 `GENERATED_CONTRACTS` 或等价 diff gate？用当前 `Makefile` 覆盖集和 A2 产物清单证明每个 codegen output 会被漂移门捕获。
3. **R1-Q03 Governance carrier**: 范式翻案/A2 重构哪些内容必须进入 OpenSpec change，哪些可留 recovery amend，哪些缺失会阻止 A2 派单？输出 `change_id / touched_spec / amend_doc / blocker_before_dispatch / archive_exit_criteria`。
4. **R1-Q04 Demo/full 双层 codegen**: `--scope=full` 与 `--scope=demo` 的 artifact 和字段边界是什么？输出 `artifact / scope / source_contract_digest / filter / shared_fields / demo_only_fields / full_only_fields / drift_gate`，证明两层由同一 3990 source 和同一 compiler 派生。
5. **R1-Q05 Surface同源 enforce**: 如何定义 `verify-tool-surface-parity`，机械比较训练样本 tools、C6 expected tools、runtime mounted whitelist？未知、缺失、额外、旧 `tool_call_frame`、required-args/value-form mismatch 必须 fail closed。
6. **R1-Q06 重训中途防灾 gate**: checkpoint 50/100/150 必须跑哪些最小 C6 抽样轴（trigger、tool exact、required args、state/action hard pass、unsupported/safety false-call）？什么阈值触发 early-stop、human-pause、continue-with-warning，且需要哪些 receipt/sign-or-block artifacts？
7. **R1-Q07 全仓级联清单**: 范式翻案后全仓哪些命中必须判改/不改？对 `tool_call_frame`、`set_cabin`、`B_frame`、`223`、`562`、`534具名工具` 等锚输出 `file:line / stale_anchor / current_claim / verdict(change|keep|supersede|receipt_only) / owner_gate`，禁止批量替换。
8. **R1-Q08 Archived specs impact**: 已 archive specs 中哪些 Requirement/Scenario 的 observable behavior 被 D-domain surface 或 4-layer C6 改变？逐核 C1/C3/C5-lora-training/C6，裁决 `no-change|MODIFY|new change|docs cleanup`。

## Deleted Or Merged

- **Merged**: R1-Q09 into R1-Q06.
- **Not merged**: R1-Q01/R1-Q04/R1-Q05 remain separate because they answer different failure modes: count semantics, artifact boundary, and train/eval/runtime parity.
- **Sequenced, not merged**: R1-Q03 precedes R1-Q08; carrier decision first, archived spec impact second.

## Remaining Gaps For Later Rounds

- B1 endpoint decode, parser hardening, and runtime mounted whitelist.
- B2 `state-cells` expansion and tool-to-card/state patch mapping.
- C1/TRN6 natural Chinese data generation, heterogeneous judge, label authority, and anti-fake-green data gates.
- TRN4 held-out split under D-domain named tools and four data classes.
- F1 safety/refusal boundary: risk-policy code gate must not become model-selectable safety tools.
- UIX execution surface and demo-golden-run staging.

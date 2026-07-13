# B7 Corpus Lineage Candidate — Spec

> 本 spec 描述 **B7 (T02 corpus lineage) durable LOCAL candidate 自身的可验证不变量**，不是对 `vehicle-tool-bench` capability 的修改。它不 supersede `rebuild-c6-four-layer-bench` 的 spec，不声称 `/opsx:apply`、B7 DONE、C6 acceptance 或 candidate signed。

## ADDED Requirements

### Requirement: B7 corpus-lineage candidate is fail-closed and recomputable

The B7 corpus-lineage durable local candidate MUST satisfy the verification contract below. This spec describes the candidate artifact only; it does not modify the `vehicle-tool-bench` capability and does not supersede `rebuild-c6-four-layer-bench`.

#### SHALL

B7 候选物（`closure/candidates/B7/**`）必须可由 `Tools/C6CorpusLineage` 从 `Tools/C6CorpusLineage/sources/**` 独立复算，且满足：

- 源料身份分离：`generated` = tracked `contracts/c6-bench-cases.jsonl` 中 exact **45** non-`C6-TRAP-*` 行；`manual_trap` = tracked 中 exact **12** 既有 `C6-TRAP-*` 行（valid shipping source，不进 quarantine）；shipping clean assembly = **45 + 12 = 57**；exact case_id set == tracked 57；**禁止**发明 `C6-MANUAL-*` 行。
- mutation fixtures（`Tools/C6CorpusLineage/mutations/**`）独立于 source denominator，不计入 45/12/57。
- 汇编不变量：lossless（每源行进入 assembled 或 quarantined，无静默丢弃）、stable sort（按 `case_id`）、stable serialization（`json.dumps(sort_keys=True)` 逐行）、row 守恒（sum(source rows) == assembled + quarantined）、id 守恒（union(source ids) == assembled ids）。
- fail-closed：duplicate case_id（源内或跨源）/ missing case_id / cross-source collision / 携带 `trap_note` 或 `source_kind==trap` 的 mutation 行 → 隔离（quarantine）或红（errors 非空）；绝不静默合并。
- 可复算哈希：每源 `sha256`（content-canonical，lineage metadata stripped）、assembled packaging `sha256`、剥离 lineage metadata 的 `compat_sha256`（content/canonical equality vs tracked fingerprint；packaging 字节相等不声称）、`unordered_id_set_sha256`（所有 case_id 排序集合）；两次独立汇编结果必须一致（stable / recomputable）。
- 自我声明：native receipt `is_canonical=False` / `is_b7_done=False` / `claims.proof_class=local_corpus_lineage` 且 `claims.forbidden_claims` 含 `canonical` / `b7_done` / `c6_acceptance` / `t02_freeze_authorized` / `opsx_apply` / `s9_authorization` / `candidate_signed`；closure envelope `status=CANDIDATE_LOCAL_ONLY`。

#### Scenario: clean assembly passes with exact 45/12/57

- **GIVEN** `Tools/C6CorpusLineage/sources/c6-bench-cases.generated.jsonl` (45 行) + `c6-bench-cases.manual-trap.jsonl` (12 行)
- **WHEN** `python3 scripts/check_c6_corpus_lineage_candidate.py` 运行
- **THEN** 退出 0，assembled_rows=57，generated=45，manual_trap=12，assembled case_id set 等于 tracked 57，无 `C6-MANUAL-*`，且两次独立汇编的 `assembled_sha256` / `compat_sha256` / `unordered_id_set_sha256` 相等（stable / recomputable）

#### Scenario: deliberate-red mutations turn the gate RED

- **GIVEN** `Tools/C6CorpusLineage/mutations/deliberate-red.jsonl` 含跨源 duplicate id / missing id / deliberate-red 坏 state cell 三行（不计入 source denominator）
- **WHEN** `python3 scripts/check_c6_corpus_lineage_candidate.py --with-mutations` 运行
- **THEN** 退出 1（fail-closed）；violation 被列出；duplicate/missing 触发 errors，deliberate-red 行被 quarantine 绝不合并

#### Scenario: candidate self-declares non-canonical / non-B7-DONE

- **GIVEN** `closure/candidates/B7/c6-corpus-lineage.receipt.json` 已生成
- **WHEN** 校验 receipt 字段
- **THEN** `is_canonical=False` 且 `is_b7_done=False` 且 `assembled.row_count=57` 且 envelope `status=CANDIDATE_LOCAL_ONLY`；不写 canonical `closure/receipts/B7.v1.json`

status: `draft`
status_source: `B7 isolated producer dispatch + semantic correction delta`
status_updated: `2026-07-13`

> **窄授权 carrier（仅 B7 / T02 corpus lineage 的 durable LOCAL candidate）。**
> 本 carrier 不 supersede、不 rewrite `rebuild-c6-four-layer-bench`。它只授权在 `codex/v9-sidecar-b7-20260713` 分支、basis `f5c963fcb5d48a5d7c0ace67a423ac1a39517313` 上形成一个 **durable local candidate**，供后续人审（D-147 / 本分支 owner）消费。
> **明确非声称**：本 carrier 不构成 `/opsx:apply`、不构成 T02 corpus freeze 授权、不构成 B7 DONE、不构成 C6 acceptance、不构成 candidate signed、不构成 S9/S10 授权。它只把「corpus lineage 可复算、fail-closed、身份分离」的本地候选物落到 dedicated 文件集。

## Why

B7（T02 corpus lineage）在 `contracts/closure-work-packages.v1.yaml` 中是 `proof_local_contract` 的 leaf，deliverable = `c6.corpus_lineage`，native schema = `corpus_lineage_v1`，exit receipt 路径 `closure/receipts/B7.v1.json`（当前 `availability: planned`）。上游 D-147 已解除 `WAIT_G2_V3_RATIFICATION` 并把 `rebuild-c6` 推进授权，但 rebuild-c6 本身仍是 `draft_needs_human_propose`（见其 `proposal.md`），且本分支只做**本地候选物**，不触碰其 carrier、spec 或 tracked `contracts/c6-bench-cases.jsonl`。

Live truth（D-147 / T02）：tracked `contracts/c6-bench-cases.jsonl` = **57 unique ids**，其中非 `C6-TRAP-*` 的 **45** 行是 generated，既有 `C6-TRAP-*` 的 **12** 行是 **manual_trap**（valid shipping source，不是 quarantine）。候选物不得发明额外 shipping corpus rows（禁止 `C6-MANUAL-*`）。

本 carrier 的存在意义：给 B7 一个**可 commit、可复算、fail-closed** 的 corpus lineage 候选实现，作为本地 durable artifact，待人审。它**不是** canonical receipt、不是 B7 closure DONE。

## Scope（窄，且只新增 dedicated 文件）

本 carrier 授权的全部产物都落在下述 dedicated 路径，**不修改任何既有 symbol / tracked 文件**：

- `Tools/C6CorpusLineage/**` — 汇编器库（lossless / stable sort / stable serialization / row+id 守恒 / duplicate·missing·cross-source-collision·quarantine fail-closed / source+assembled+unordered-id-set 哈希可复算）。
- `contracts/c6-corpus-lineage/**` — `manifest.v1.json` + `corpus-lineage-v1.schema.json` + `corpus-subject-v1.schema.json`。
- `scripts/check_c6_corpus_lineage_candidate.py` + `scripts/test_check_c6_corpus_lineage_candidate.py` — 主 fail-closed 检查 + 单测（含 deliberate-red 真红与 mutation 覆盖）。
- `closure/candidates/B7/**` — 候选物：assembled corpus（**57 行**）、native `corpus_lineage_v1` receipt（自标 `is_canonical=False` / `is_b7_done=False`）、closure envelope（自标 `status=CANDIDATE_LOCAL_ONLY`）。

源料身份分离（shipping）：
- `Tools/C6CorpusLineage/sources/c6-bench-cases.generated.jsonl` = tracked 中 exact **45** non-`C6-TRAP-*` 行 + `source_kind=generated`。
- `.../c6-bench-cases.manual-trap.jsonl` = tracked 中 exact **12** 既有 `C6-TRAP-*` 行 + `source_kind=manual_trap` + 稳定 lineage metadata（`source_record_id` / provenance / rationale / `external_layer` / `authored_at=unknown` / `captured_at`）。**valid source，不进 quarantine**。
- shipping clean assembly = **45 + 12 = 57**，case ID exact-set == tracked 57；剥离 lineage metadata 后 content/canonical 与 tracked fingerprint 一致（packaging 字节相等不声称）。

Mutation fixture（**不进 source denominator**）：
- `Tools/C6CorpusLineage/mutations/deliberate-red.jsonl` = deliberate-red 验证行（跨源 duplicate id / missing id / deliberate-red 坏 state cell），仅供单测与 `--with-mutations` 模式证明 gate 真红。

## Non-Goals（硬边界）

- ❌ 不 supersede / 不 rewrite `rebuild-c6-four-layer-bench` 或其 spec/design/tasks。
- ❌ 不声称 `/opsx:apply`、不翻转 B7 `execution_state` 到 `done`、不写 canonical `closure/receipts/B7.v1.json`（那是 B7 closure 的人审交付物，本候选物只落 `closure/candidates/B7/**`）。
- ❌ 不声称 T02 corpus freeze 授权、不声称 S9/S10 授权、不声称 C6 acceptance / V-PASS / candidate signed。
- ❌ 不修改 `Makefile`、既有 `Tests/**`、`Core/**`、tracked `contracts/c6-bench-cases.jsonl`、共享 registry/canonical receipts、其他 OpenSpec carrier。
- ❌ 不跑 full Swift build / GUI / S8 / 任何训练或模型评测。验证只跑 dedicated Python + unit + schema + OpenSpec strict。
- ❌ 不发明 `C6-MANUAL-*` shipping rows；不把 mutation fixture 计入 source denominator。

## Success Criteria

- `python3 scripts/test_check_c6_corpus_lineage_candidate.py` 全绿（含 deletion / duplicate / cross-source / behavior-class / external-layer / only-45 / reorder-only 覆盖）。
- `python3 scripts/check_c6_corpus_lineage_candidate.py` 干净态退出 0（assembled=57, generated=45, manual_trap=12）；`--with-mutations` 退出 1 且列出 violation。
- `closure/candidates/B7/c6-corpus-lineage.receipt.json` 满足 `corpus-lineage-v1.schema.json` 且 `is_canonical=False` / `is_b7_done=False` / `row_count=57`。
- `closure/candidates/B7/c6-corpus-lineage.envelope.json` 自标 `status=CANDIDATE_LOCAL_ONLY`，subject 含 assembled/compat/unordered-id-set 哈希与 `is_canonical=False` / `is_b7_done=False`，`source_row_counts` = `{"generated":45,"manual_trap":12}`。
- source / assembled / unordered-id-set 哈希均可从磁盘文件独立复算，且两次独立汇编结果一致（stable）。
- row 守恒：sum(source rows) == assembled + quarantined；id 守恒：union(source ids) == assembled ids。
- `openspec validate add-b7-corpus-lineage-candidate --strict` 通过。

## Impact

- 仅新增 / 修订 dedicated 文件（见 Scope）。不触动 `rebuild-c6-four-layer-bench` 或其他 carrier。
- 不引入对 `Core/**`、`Tests/**`、`Makefile`、tracked `contracts/c6-bench-cases.jsonl` 的任何依赖或改动。

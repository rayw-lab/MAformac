# B7 Corpus Lineage Candidate — Tasks

> DRAFT. 窄授权 carrier：仅本分支上的 B7 durable LOCAL candidate。不声称 `/opsx:apply`、B7 DONE、C6 acceptance。
> Semantic correction：shipping = 45 generated + 12 manual_trap = 57 exact tracked ids；禁止发明 C6-MANUAL-*；mutation fixtures 独立于 source denominator。

## 1. 专用源料（身份分离）

- [x] 1.1 生成 `Tools/C6CorpusLineage/sources/c6-bench-cases.generated.jsonl` = tracked 中 exact 45 non-`C6-TRAP-*` 行 + `source_kind=generated`。
- [x] 1.2 写 `.../c6-bench-cases.manual-trap.jsonl`：tracked 中 exact 12 既有 `C6-TRAP-*` 行 + `source_kind=manual_trap` + 稳定 lineage metadata（`authored_at=unknown` / `captured_at`）；删除旧 invented `c6-bench-cases.manual.jsonl`（C6-MANUAL-901..903）。
- [x] 1.3 写 `Tools/C6CorpusLineage/mutations/deliberate-red.jsonl`：deliberate-red 验证行（跨源 duplicate id / missing id / deliberate-red 坏 state cell）；**不进 source denominator / assembled shipping corpus**。删除旧 `sources/c6-bench-cases.trap.jsonl`。
- [x] 1.4 `_regenerate_sources.py`：从 live tracked 再生 45/12 的可重跑入口。

## 2. 契约与 schema（dedicated）

- [x] 2.1 `contracts/c6-corpus-lineage/manifest.v1.json`：源清单（45/12）+ mutations 独立 + assembler 不变量 + fail-closed 清单 + recomputable 哈希定义 + proof claims。
- [x] 2.2 `contracts/c6-corpus-lineage/corpus-lineage-v1.schema.json`：`corpus_lineage_v1`（自标 `is_canonical=False` / `is_b7_done=False` / `row_count=57` / source_kind enum `generated|manual_trap`）。
- [x] 2.3 `contracts/c6-corpus-lineage/corpus-subject-v1.schema.json`：`corpus_subject_v1`（subject[] 形态）。

## 3. 汇编器库（fail-closed）

- [x] 3.1 `Tools/C6CorpusLineage/__init__.py`：load / hash（source·assembled·compat·unordered-id-set·ordered-id-list）/ assemble（lossless·stable sort·stable serialization·row+id 守恒·duplicate/missing/cross-source-collision/quarantine fail-closed）/ shipping_count_errors（exact 45/12/57 + exact ID set + no invented manual）/ build_receipt（自标非 canonical/非 B7 DONE）。
- [x] 3.2 `Tools/C6CorpusLineage/emit_candidate.py`：落到 `closure/candidates/B7/`（assembled corpus 57 + native receipt + closure envelope，均自标非 canonical / CANDIDATE_LOCAL_ONLY）。

## 4. 检查与单测（dedicated，含 mutation 真红）

- [x] 4.1 `scripts/check_c6_corpus_lineage_candidate.py`：fail-closed 主检查（exact 45/12/57、exact ID set、row/id 守恒、recomputable、stable）；干净态退出 0；`--with-mutations`（alias `--with-trap`）退出 1 并列出 violation。
- [x] 4.2 `scripts/test_check_c6_corpus_lineage_candidate.py`：覆盖 clean 57/45/12、deletion one manual_trap、duplicate、cross-source collision、behavior_class change、external_layer change、only-45、reorder-only、missing id、quarantine 隔离、no invented manual。

## 5. 候选物生成与自验

- [x] 5.1 运行 emit → `closure/candidates/B7/` 三件物（57 行 assembled、receipt、envelope；source_row_counts generated=45 / manual_trap=12）。
- [ ] 5.2 校验 receipt 满足 `corpus-lineage-v1.schema.json` 且 `is_canonical=False` / `is_b7_done=False` / `row_count=57`；envelope `status=CANDIDATE_LOCAL_ONLY`、`source_row_counts={"generated":45,"manual_trap":12}`。（controller 跑 schema validate）
- [ ] 5.3 保留原始日志到 run-root `evidence/b7/`（controller / owner；本 worker 不写 run-root CLOSEOUT）。

## 6. OpenSpec 窄 carrier

- [x] 6.1 `openspec/changes/add-b7-corpus-lineage-candidate/`：proposal（窄授权、45/12/57 live-truth、Non-Goals 显式）/ design / tasks / spec。
- [ ] 6.2 `openspec validate add-b7-corpus-lineage-candidate --strict` 通过（controller 执行）。

## 7. 收尾（本地，不 push/merge）

- [ ] 7.1 `git add` 自己写集 + 本地 commit（branch `codex/v9-sidecar-b7-20260713`）。（controller / 有 terminal 的 worker 执行；本 Grok delta 不 commit）
- [ ] 7.2 写 `evidence/b7/WORKER-CLOSEOUT.md`：status / evidence table / confidence / touched paths / commit / residual risk / non-claims。不修改 run-root OWNERSHIP/CHECKPOINT/CLOSEOUT。

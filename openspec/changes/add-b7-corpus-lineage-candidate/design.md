# B7 Corpus Lineage Candidate — Design

> DRAFT. 窄授权 carrier：仅本分支上的 B7 (T02 corpus lineage) durable LOCAL candidate。不 supersede/rewrite `rebuild-c6-four-layer-bench`，不声称 `/opsx:apply`、T02 freeze 授权、B7 DONE、C6 acceptance 或 candidate signed。

## Scope

本设计记录 B7 corpus-lineage 候选物的**架构决策**（文档吸收 + 本地专用代码，非训练/评测/acceptance）：

- **源料身份分离（live-truth shipping）**：
  - `generated` = tracked `contracts/c6-bench-cases.jsonl` 中 exact **45** non-`C6-TRAP-*` 行（`source_kind=generated`；剥离 lineage metadata 后 content/canonical 与 tracked 对应行一致）。
  - `manual_trap` = tracked 中 exact **12** 既有 `C6-TRAP-*` 行（`source_kind=manual_trap` + 稳定 lineage metadata；**valid shipping source，不进 quarantine**）。
  - shipping clean assembly = **45 + 12 = 57**；exact case_id set == tracked 57；**禁止**发明 `C6-MANUAL-*` 行。
  - mutation fixtures (`mutations/deliberate-red.jsonl`) **独立于 source denominator**，仅供 fail-closed 真红证明。
- **汇编器不变量（fail-closed）**：
  - lossless：每个源行都进入 assembled 或 quarantined，无静默丢弃。
  - stable sort：按 `case_id` 稳定排序（Python sort 稳定，ties 保源序）。
  - stable serialization：`json.dumps(..., sort_keys=True, separators=(',',':'))` 逐行。
  - row 守恒：`sum(source rows) == len(assembled) + len(quarantined)`（clean path 无 missing/dup 时）。
  - id 守恒：`union(source case_ids) == set(assembled case_ids)`。
  - duplicate / missing / cross-source collision（generated 与 manual_trap id 碰撞）→ 红。
  - quarantine：带 `trap_note` 或 `source_kind==trap` 的 **mutation** 行永远隔离；`manual_trap` 不是 quarantine。
- **可复算哈希**：
  - 每源 `sha256` over content-canonical JSON（lineage metadata stripped）。
  - assembled `sha256` over packaging JSON（lineage metadata retained）。
  - `compat_sha256`：剥离 lineage metadata 后逐行 hash —— content/canonical equality vs tracked fingerprint（**packaging 字节相等不声称**）。
  - `unordered_id_set_sha256`：所有 `case_id` 排序集合的 hash。
  - `ordered_id_list_sha256`：materialization order 敏感；reorder-only 场景下 unordered 不变、ordered 可变。
  - 两次独立汇编结果必须一致（stable / recomputable）。

## Architecture Decisions

### AD-B7-001: shipping = 45 generated + 12 manual_trap = tracked 57
Live tracked corpus 已含 12 条 `C6-TRAP-*`。它们是 **manual_trap shipping source**，不是 mutation，也不是发明的 `C6-MANUAL-*`。generated 只覆盖 45 条 non-TRAP。assembled exact-set 必须等于 tracked 57。

### AD-B7-002: mutation fixtures 永不计入 source denominator
`mutations/deliberate-red.jsonl`（跨源 duplicate id / missing id / deliberate-red 坏 state cell）**不是** shipping corpus 的一部分。它们只被单测与 `--with-mutations` 检查模式消费。clean 默认汇编（generated + manual_trap）不含 mutation，故候选物本身干净绿，而 gate 的 fail-closed 性质由 mutation 独立证明。

### AD-B7-003: content equality ≠ packaging byte equality
剥离 lineage metadata 后，assembled content fingerprint 必须等于 tracked content fingerprint（parse+sort+canonical）。候选 packaging 文件（含 `source_kind` / `source_record_id` 等）字节可与 tracked 不同——**不假称 byte equality**。

### AD-B7-004: 候选物自我声明非 canonical / 非 B7 DONE
`closure/candidates/B7/c6-corpus-lineage.receipt.json` 强制 `is_canonical=False` / `is_b7_done=False`，`claims.forbidden_claims` 含 `canonical` / `b7_done` / `c6_acceptance` / `t02_freeze_authorized` / `opsx_apply` / `s9_authorization` / `candidate_signed`。envelope 自标 `status=CANDIDATE_LOCAL_ONLY`。本候选物**不写** canonical `closure/receipts/B7.v1.json`。

### AD-B7-005: 窄 carrier 不 supersede rebuild-c6
本 carrier 只新增/修订 dedicated 文件（`Tools/C6CorpusLineage/**`、`contracts/c6-corpus-lineage/**`、`scripts/check_*`、`scripts/test_*`、`closure/candidates/B7/**`、`openspec/changes/add-b7-corpus-lineage-candidate/**`）。不修改 `rebuild-c6-four-layer-bench` 的任意文件、不修改 `Makefile`、既有 `Tests/**`、`Core/**`、tracked `contracts/c6-bench-cases.jsonl`、共享 registry/canonical receipts、其他 OpenSpec carrier。

## Non-Goals

- 不跑 full Swift build / GUI / S8 / 任何训练或模型评测。
- 不声称 canonical、B7 DONE、C6 acceptance、T02 freeze 授权、S9/S10 授权、candidate signed、`/opsx:apply`。
- 不修改 `rebuild-c6-four-layer-bench` 或任何既有契约源。
- 不发明 shipping rows；不把 mutation 计入 45/12/57。

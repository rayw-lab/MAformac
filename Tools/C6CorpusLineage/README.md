# C6 Corpus Lineage — B7 T02 Freeze Packet Exporter Operator Guide

> 本文档是 B7 corpus lineage freeze packet 的操作手册。**不是** SSOT——权威行为契约在 `export_freeze_packet.py` 的 fail-closed 校验和 `freeze-packet.v1.schema.json` 的 JSON Schema 中。

---

## 身份

| 字段 | 值 |
|------|-----|
| `package_id` | B7 |
| `packet_id` | B7.freeze.v1 |
| `schema_version` | `c6_corpus_lineage_freeze_packet_v1` |
| `status` | `CANDIDATE_PACKET_ONLY`（永不自动升格） |
| `is_b7_done` | `false`（永不自动翻 true） |
| `requires_operator_ceremony` | `true`（本 packet 不是 ceremony） |

## 数据流

```
contracts/c6-bench-cases.jsonl (tracked 57)
  → Tools/C6CorpusLineage/__init__.py (assemble + build_receipt)
    → export_freeze_packet.py (live recompute + drift guard)
      → closure/candidates/B7/B7.v1.freeze-packet.candidate.json
```

## CLI 命令

```bash
# 写 packet 到 closure/candidates/B7/
python3 Tools/C6CorpusLineage/export_freeze_packet.py

# 打印到 stdout，不写文件
python3 Tools/C6CorpusLineage/export_freeze_packet.py --stdout

# --check: live recompute + strict self-check + byte-equal committed
python3 Tools/C6CorpusLineage/export_freeze_packet.py --check
```

`--check` 是唯一能确认 committed packet 与 live repo 一致的命令。每次修改 `contracts/c6-bench-cases.jsonl` 或 `Tools/C6CorpusLineage/` 后必须跑。

## 确定性导出

Packet 是 deterministic canonical JSON（`sort_keys=True, separators=(",", ":")`）。同一 repo 状态两次导出必须字节级相等。`--check` 验证 byte equality。

## 严格 ref allowlist

Packet 只接受以下顶层字段（`ALLOWED_TOP_LEVEL_KEYS`）：

`schema_version`, `packet_id`, `package_id`, `status`, `is_canonical`, `is_b7_done`, `requires_operator_ceremony`, `source_candidate`, `corpus_binding`, `holdout_pin`, `acl`, `ratification_refs`, `consistency`, `non_claims`

以下字段**禁止**出现在 candidate packet 上（`FORBIDDEN_TOP_LEVEL_FIELDS`）：

`operator`, `operator_id`, `signature`, `signed_at`, `ratified_at`, `ceremony`, `frozen_at`, `canonical_receipt`, `is_done`, `done`, `DONE`, `canonical` 等

## source_members 绑定

`export_freeze_packet.py` 的 `build_packet()` 从 `C6CorpusLineage.__init__` 实时计算以下绑定：

| 绑定 | 来源 | 校验 |
|------|------|------|
| `assembled_sha256` | 打包行（含 lineage metadata）的 SHA-256 | `--check` 实时复算 |
| `compat_sha256` | 剥离 lineage metadata 后的内容指纹 | `--check` 实时复算 |
| `unordered_id_set_sha256` | 排序去重 case_id 集的 SHA-256 | `--check` 实时复算 |
| `tracked_content_sha256` | `contracts/c6-bench-cases.jsonl` 的内容指纹 | `--check` 实时复算 |
| `id_set_equals_tracked` | assembled ID set == tracked 57 | `--check` 断言 |
| `holdout_pin.sha256` | D-127 冻结 sha（硬编码常量，不复算） | `--check` 断言 |
| `ratification_refs` | D-147 decisions.md + pool32 receipt 的 live sha | `--check` 实时复算 |

**校验纪律**：`_resolve_ref_strict()` 拒绝全零 sha、拒绝路径逃逸 REPO_ROOT、拒绝不可读文件。任何 ref 解析失败 → exporter exit 1。

## stdlib strict schema validation

`self_check()` 在 exporter 内部做结构校验（不依赖外部 jsonschema 库）：

- 检查 `ALLOWED_TOP_LEVEL_KEYS` 精确集（无多余、无缺失）
- 检查 `FORBIDDEN_TOP_LEVEL_FIELDS` 不存在
- 检查 `status` / `is_canonical` / `is_b7_done` / `requires_operator_ceremony` 的常量值
- 检查 `corpus_binding` 的 row_count / digest 字段
- 检查 `holdout_pin` 的 sha 与 D-127 pin 一致
- 检查 `ratification_refs` 的 live sha 复算

## deliberate-red 期望

`Tools/C6CorpusLineage/mutations/deliberate-red.jsonl` 包含故意构造的负例（near-dup、ID 漂移等）。这些行**不**计入 shipping assembly（45+12=57）。`export_freeze_packet.py` 的 shipping count 校验（`EXPECTED_ASSEMBLED_COUNT=57`）确保 mutations 不被误计入。

## 外部 ceremony 边界

本 packet **不**执行以下操作：

- ❌ 不写 `closure/receipts/B7.v1.json`（DONE 信封留给 ceremony）
- ❌ 不翻转 registry `execution_state`（共享 seam，并行阶段禁写）
- ❌ 不声称 `is_b7_done=true`、`is_canonical=true`
- ❌ 不伪造 operator/time/signature
- ❌ 不授权 S9/S10 执行

下游 ceremony 消费本 packet 后，需独立完成：写 canonical receipt → registry flip → 更新 closure-work-packages。

## 验证命令

```bash
# 单元测试
python3 -B scripts/test_export_c6_corpus_freeze_packet.py

# 回归：B7 candidate checker
python3 -B scripts/check_c6_corpus_lineage_candidate.py

# 实时复算 + byte-equal committed
python3 Tools/C6CorpusLineage/export_freeze_packet.py --check
```

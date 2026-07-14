# C6 Active Authority V1 — Tool Documentation

## Identity

| Field | Value |
|-------|-------|
| `authority_id` | `c6_active_authority_v1` |
| `authority_version` | 1 |
| `schema_version` | `c6_active_authority_v1` |
| `subject_schema_id` | `c6_authority_subject_v1` |
| `freshness_policy` | `immutable_digest` |
| `status` | `CANDIDATE` (initial; transitions to `RATIFIED` via operator ceremony) |

## Machine-readable exact source_members (SSOT)

The durable candidate embeds `source_members[]` with unique `member_id` / `role` / `path` / `locator` / `sha256` and `subject_bindings`. The checker fail-closed validates path existence, live hash exactness, exact member set, and rejects all-zero / placeholder digests. **README prose is not a substitute for that manifest.**

| member_id | role | path | locator | subject_bindings |
|-----------|------|------|---------|------------------|
| `d147_decisions` | `ratification_decision` | `docs/commander-log/decisions.md` | `D-147` | `ratification_decision` |
| `pool32_ratification_receipt` | `ratification_receipt` | ma14 `RATIFICATION-RECEIPT-pool32.md` (abs path in candidate) | `pool32` | `ratification_receipt_sha256` |
| `closure_work_packages_v1` | `registry_package_entry` | `contracts/closure-work-packages.v1.yaml` | `V1` | `authority_id` |
| `rebuild_c6_proposal` | `rebuild_proposal` | `openspec/changes/rebuild-c6-four-layer-bench/proposal.md` | `AD-C6 thresholds+roster` | golden/demo_fuzz/unsupported/safety thresholds + family count |
| `rebuild_c6_design` | `rebuild_design` | `openspec/changes/rebuild-c6-four-layer-bench/design.md` | `AD-C6-007/008/009/015` | behavior/governance/readback/contract counts |
| `rebuild_c6_tasks` | `rebuild_tasks` | `openspec/changes/rebuild-c6-four-layer-bench/tasks.md` | `T01 authority construction tasks` | `authority_version` |
| `active_vehicle_tool_bench_spec` | `active_c6_spec` | `openspec/specs/vehicle-tool-bench/spec.md` | `vehicle-tool-bench active` | `authority_id`, `authority_digest` |

## D-147 T01 Exact Set → Live Source File Mapping (narrative)

| D-147 Subject | Live Source File | Field |
|---------------|------------------|-------|
| Four-layer thresholds (golden=1.0, demo_fuzz=5*pass>=4*eligible, unsupported=1.0, safety=1.0) | rebuild proposal/design | `subject.four_layer_thresholds` |
| Five behavior classes | rebuild design AD-C6-007 | `subject.behavior_classes` |
| Seven-family demo-fuzz roster | rebuild proposal G2-038-C1 | `subject.demo_fuzz_family_roster` |
| Five governance axes | rebuild design AD-C6-015 | `subject.governance_axes` |
| Seven readback fields | rebuild design AD-C6-008 | `subject.readback_fields` |
| Seven contract bundle component IDs | rebuild design AD-C6-009 | `subject.contract_bundle_component_ids` |
| Ratification D-147 + pool32 | decisions.md + pool32 receipt | `ratification_refs` + `source_members` |
| Decision D-147, D-144 | decisions.md | `decision_refs` |

## Subject Tuple Reference

The subject array in the candidate exit envelope contains load-bearing key-value pairs plus explicit non-claims:

| # | Key | Value Type | Description |
|---|-----|------------|-------------|
| 1 | `authority_id` | string | `c6_active_authority_v1` |
| 2 | `authority_version` | integer | 1 |
| 3 | `ratification_decision` | string | `D-147` |
| 4 | `ratification_receipt_sha256` | sha256 | Pool32 receipt digest |
| 5–8 | thresholds / formula | string | golden / demo_fuzz / unsupported / safety |
| 9–13 | counts | integer | behavior/family/governance/readback/contract |
| 14 | `authority_digest` | sha256 | Self-digest of authority identity+subject |
| 15 | `is_canonical` | boolean | always false on candidate |
| 16 | `is_v1_done` | boolean | always false on candidate |

## Checker

```bash
python3 -B scripts/check_c6_active_authority_candidate.py \
  contracts/c6-active-authority/authority.v1.candidate.json
python3 -B scripts/test_check_c6_active_authority_candidate.py
```

Fail-closed gates include: stale hash, duplicate member_id/role/path/locator, missing member, subject mismatch, all-zero SHA256, placeholder SHA256.

## Migration / Fan-In Instructions

### For consumers (C6 acceptance, S10 verdict, model-quality runs):

1. Load `contracts/c6-active-authority/authority.v1.candidate.json`
2. Status must be `RATIFIED` before use as a signed yardstick (current status is `CANDIDATE` only)
3. Verify digest of `{authority_id, authority_version, schema_version, subject_schema_id, subject}`
4. Verify `source_members` live path + sha256 exact set via the checker
5. Use subject values as the measurement authority only after ratification

### For V1 package transition (planned → ready):

1. Checker exits 0 on the candidate
2. Operator ceremony updates `status` from `CANDIDATE` to `RATIFIED`
3. Write transition receipt under `closure/registry/transitions/`
4. Register ratified authority digest in the closure registry

## Consumer Guidance / Non-claims

- **Do not** treat this candidate as `V1 DONE`, canonical, C6 acceptance, or ratified authority
- **Do not** modify the authority document in place — create a superseding version
- **Do** run the source checker after any change
- rebuild-C6 remains draft/acceptance-stopline; this candidate does not authorize `/opsx:apply` on rebuild-C6

---

## V1 Ratification Packet Exporter

`Tools/C6ActiveAuthority/export_ratification_packet.py` 从 live V1 authority candidate 导出机械消费 packet。

### 身份

| 字段 | 值 |
|------|-----|
| `packet_id` | V1.ratification.v1 |
| `schema_version` | `c6_active_authority_ratification_packet_v1` |
| `status` | `CANDIDATE_PACKET_ONLY`（永不自动升格） |
| `observed_status` | `CANDIDATE`（live 观察态） |
| `target_status` | `RATIFIED`（ceremony 目标态） |
| `is_v1_done` | `false`（永不自动翻 true） |
| `requires_operator_ceremony` | `true` |

### CLI

```bash
# 写 packet 到 closure/candidates/V1/
python3 Tools/C6ActiveAuthority/export_ratification_packet.py

# 打印到 stdout
python3 Tools/C6ActiveAuthority/export_ratification_packet.py --stdout

# --check: live recompute + byte-equal committed
python3 Tools/C6ActiveAuthority/export_ratification_packet.py --check
```

### 确定性导出

Canonical JSON（`sort_keys=True, separators=(",", ":")`）。同一 repo 状态两次导出必须字节级相等。

### 严格 ref allowlist

允许的顶层字段（`ALLOWED_TOP_LEVEL_KEYS`）：

`schema_version`, `packet_id`, `package_id`, `status`, `observed_status`, `target_status`, `is_canonical`, `is_v1_done`, `requires_operator_ceremony`, `authority_binding`, `four_layer_thresholds`, `decision_refs`, `receipt_refs`, `non_claims`

禁止的顶层字段（`FORBIDDEN_TOP_LEVEL_FIELDS`）：

`operator`, `operator_id`, `signature`, `signed_at`, `ratified_at`, `ceremony`, `frozen_at`, `canonical_receipt`, `is_done`, `done`, `DONE`, `canonical` 等

### 绑定

| 绑定 | 来源 | 校验 |
|------|------|------|
| `authority_binding.digest_sha256` | 从 live authority candidate 用 `auth_checker.compute_digest()` 实时复算 | `--check` 断言 |
| `four_layer_thresholds` | authority candidate `subject.four_layer_thresholds` | golden/unsupported/safety=1.0, demo_fuzz formula exact |
| `decision_refs` | authority candidate 的 `decision_refs`（D-147 + D-144） | required_state=ratified |
| `receipt_refs` | D-147 decisions.md + pool32 receipt 的 live sha | `--check` 实时复算 |

### 外部 ceremony 边界

本 packet **不**执行以下操作：

- ❌ 不写 `closure/receipts/V1.v1.json`（DONE 信封留给 ceremony）
- ❌ 不翻转 `status` 从 CANDIDATE 到 RATIFIED
- ❌ 不翻转 registry `execution_state`
- ❌ 不声称 `is_v1_done=true`、`is_canonical=true`
- ❌ 不伪造 operator/time/signature
- ❌ 不授权 S9/S10 real 执行

### 验证命令

```bash
# 单元测试
python3 -B scripts/test_export_c6_active_authority_ratification_packet.py

# 回归：V1 candidate checker
python3 -B scripts/check_c6_active_authority_candidate.py \
  contracts/c6-active-authority/authority.v1.candidate.json

# 实时复算 + byte-equal committed
python3 Tools/C6ActiveAuthority/export_ratification_packet.py --check
```

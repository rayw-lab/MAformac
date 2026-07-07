---
authority: acceptance_basis_registry_ssot
artifact_kind: baseline_registry
created: 2026-07-03（维度四机制，D-055；原理档=docs/c5-training-readiness-grill/cognitive-upgrade-dim34-verification-economics-2026-07-03.md）
rule: 一切 receipt/验证声称必须 cite 本表 basis_id；basis 迁移=决策日志事件+迁移 checklist，禁静默换基
---

# BASELINE-REGISTRY — 验收基线注册表（单一可查处）

## 现行基线（live）

| basis_id | lane | 现行值 | 生效事件 | 迁移时必重跑 |
|---|---|---|---|---|
| CODE-2026-07-03-PR38 | 代码面（训练/门/契约） | origin/main pin `266783468ac38542574ea4787bec650d16ba6b02`（PR #38 repoized `token_budget_per_batch` / `grad_checkpoint` / `clear_cache_before_train`） | D-069（PR38 merge 后 CODE+DATA 耦合迁移 R2；receipt=`CODE-MIGRATION-R2-RECEIPT.md`） | strict preflight / DataGate / filter tests / T1D-D2combo config-smoke |
| DATA-WAVE1-SUBSTRATE-v3 | 训练数据面（协议串底座） | `PR38-final-n4a-recipe-build/`（run 目录；refusal 0/0、DataGate `data_gate_ready`、preflight exit0 4628/4628、trainable_tokens=113745；samples sha `cbd396d7…`） | D-069（新 pin 上 N4A prepare + hash-field projection，关闭 #36 DataGate hash 门耦合） | DataGate + strict preflight + token 双账（ledger 档） |
| DATA-CANARY-v2 | canary 数据 | `N5-canary/canary-anthropic-opus.jsonl` sha `3ef37e02…`（+ledger） | D-048（re-judge PASS） | DataGate v2 + judge verdict 引用 |
| EVAL-C6 | 评测面 | `contracts/c6-bench-cases.jsonl`（57 case/42 protected，leakage probe 口径） | 既有 | C6 leakage probe |

## supersede 史

| 旧 basis | 被谁取代 | 事件 | 备注 |
|---|---|---|---|
| 数据面 `n4a-wave1-proto-build/`（trainable_tokens=44459） | DATA-WAVE1-SUBSTRATE-v2 | D-051/D-052：main 契约硬化（`73b6e360`+`458820fa`）后按 N4A 配方旋钮重建 | 降级 historical；在新代码面 strict preflight exit66=预期（旧契约产物） |
| CODE-2026-07-03（pin `b33d8eba152e5326f69bbe85fc356b73419ee9c3`） | CODE-2026-07-03-PR38 | D-069：PR #38 merged at `266783468ac38542574ea4787bec650d16ba6b02`；按 R2 receipt 重跑 strict preflight / DataGate / filter tests / T1D-D2combo repo-config smoke | 旧 pin 保留为 PR31-final/T1D 诊断历史依据；新候选 manifest 不得继续写作 live CODE basis |
| DATA-WAVE1-SUBSTRATE-v2（`PR31-final-n4a-recipe-build/`，trainable_tokens=113914） | DATA-WAVE1-SUBSTRATE-v3 | D-069：PR31-final substrate 在 #36 fail-closed hash 字段门下 blocked；R2 于 PR38 pin 重跑 N4A prepare 并投影 `hash_recipe_ref`/`hash_recomputed_by_pipeline`，DataGate+strict preflight 双绿 | v2 降级 historical；若复核数据 lineage，保留 `samples.prepare-raw.jsonl` 与 projection report 区分 prepare 原始输出和 v3 DataGate 输入 |
| 代码面 p5w `f163eedf` | CODE-2026-07-03 | D-052 merge 链完成 | canary 证据仍绑 f163eedf（历史有效，标注即可） |
| canary rev1 sha `9045d9c8…` | DATA-CANARY-v2 | D-047/D-048 修复轮 | judge v1 FAIL 记录保留 |

## 使用规则
1. 新 receipt 模板字段：`basis_id:`（多 lane 就列多个）。
2. 「绿」不写 basis_id = 视为未验证（M.14/M.15）。
3. basis 迁移三步：决策日志（D-xxx）→ 本表更新（旧行入 supersede 史）→ 迁移 checklist 重跑并留 receipt。

---
authority: physical_cleanup_execution_pack
status: PLAN_ONLY_AWAITING_LEIGE_NOD
as_of_head: 68ac29c2（roadmap 落库后 HEAD）
date: 2026-07-07
author: hermes (glm-5.2, 异源 worker)
proof_class: local_repo_truth_plus_reduction_table_v1
claim_cap: docs_local_plan_only
zero_commit: true
---

# 物理清理执行包（磊哥一次性点头）

> 本文件是 plan-only，零 commit 权。所有批次均需磊哥逐批点头后方可执行。
> 依据 = reduction-table.md v1（final）+ docs/project/ 127 tracked 全量分诊。
> 每批 = 内容 / 收益(tracked files+体积) / 风险 / rollback / 验收命令 / 建议执行序。

## 〇、docs/project/ 专项分诊（W2 漏盘补全）

### 全量 inventory

- docs/project/ tracked 总计 **127** files（1.3 MB），其中 phase0/ 子目录 **124** files，非 phase0/ **3** files。
- W2 漏盘原因：W2 只扫了 `docs/research/` 和 `docs/evidence-frozen/`，未扫 `docs/project/`。

### 按 T0-T6 分诊

| 组 | 文件数 | 内容 | retire_trigger 有无 | retire 条件现值 |
|---|---:|---|---|---|
| **T0：schema 骨架** | 7 | c02-c07 + c24 `.schema.yaml`（authority-matrix / artifact-matrix / archived-spec-disposition / pocock-stage / runtime-outcome-enum / decision-lifecycle / status-vocabulary-graph） | ❌ 全无 frontmatter | 这些是 schema 定义文件，非 route-control manifest。CLAUDE.md §3 的「must carry retire/expiry metadata once filled」针对的是 phase0 route-control manifests（.md），schema 骨架文件是否需要 retire_trigger 需磊哥拍——schema 本身是元数据定义，不是已填的 manifest |
| **T1：D1-D10 决策包** | 6 | d1-d10-fast-pick-verdict / d1-d10-lora-zero-failure-decision-pack / phase0-d1-d10-closeout / phase0-d1-d10-user-decision-record / phase0-d1-d10-cascade-audit-codex / non-uiue-pre-code-action-list | ✅ 全有 retire_trigger + expires:2026-07-15 | ⚠️ **retire 条件已满足**：user_decisions_accepted（pending_user_decision=[]），phase0-d1-d10-closeout.md 已记录 accepted final state。retire_trigger 写「Retire after D1-D10 are accepted/rejected by user verdict and OpenSpec carriers are either accepted, superseded, or archived」——前半已满足，后半（OpenSpec carriers accepted/superseded/archived）需核实 |
| **T2：R-L17 证据** | 14 | R1-R7 + README + heterogeneous-deframing-audit-glm + route-deframing-prep + tiny-ablation-run-plan + tiny-ablation-v6-run-plan + v6-overnight-run-auth | ⚠️ 部分（10/14 有 retire_trigger） | ⚠️ **retire 条件部分满足**：R7-final-route-deframing-signoff.md status=`signed_route_only_candidate_unsigned`——route deframing 已签（human owner 王磊 2026-06-25），但 candidate signoff 未签。retire_trigger 写「Retire after R-L17 G1-G5 all pass」——G1-G5 未全过（candidate unsigned）。**4 个文件缺 retire_trigger**：R7-renewal-and-tiny-ablation-run-auth-DRAFT / tiny-ablation-run-plan-adjudication-A / tiny-ablation-v6-run-plan / v6-overnight-run-auth-2026-07-02 |
| **T3：rebuild-C6 收口** | 13 | rebuild-c6-documentation-absorption-closeout / rebuild-c6-identity-shape-{closeout,evidence-excerpt,gptpro-absorption-ledger,gptpro-audit,gptpro-audit-request,lessons} / rebuild-c6-scoring-foundation-{closeout,evidence-excerpt,gptpro-audit,gptpro-audit-request,lessons} / rebuild-c6-precode-grill-ledger | ⚠️ 部分（3/13 有 retire_trigger） | ⚠️ **retire 条件部分满足**：identity-shape + scoring-foundation 两个 closeout 均 `external-pass-with-absorbed-fixes`，但 rebuild-c6-four-layer-bench OpenSpec change 未 archived。retire_trigger 写「Retire after rebuild-c6-four-layer-bench is accepted, superseded, or archived」——未 archived。**10 个文件缺 retire_trigger**（evidence-excerpt / gptpro-audit / gptpro-audit-request / lessons 等辅助文件） |
| **T4：r5 runtime-adapter 收口** | 68 | r5-d9 到 r5-d24 全链（dispatch / gate1-7 / reconcile / receipt / verdict / manifest） | ⚠️ 部分（8/68 有 retire_trigger） | ⚠️ **retire 条件需核实**：r5-d24-full-absorption-route-control-pr-merge-commander-verdict 是收尾文件，r5-d24-route-control-pr-merge-closeout 标 closeout。但 68 个文件里 60 个缺 retire_trigger——这些是 gate receipt / dispatch / reconcile 中间产物，CLAUDE.md §3 说「route-control manifests must carry retire/expiry metadata once filled」，这些中间 receipt 是否算「filled manifests」需磊哥拍 |
| **T5：paper-to-skill-gate 吸收** | 1 | paper-to-skill-gate-absorption-ledger-2026-06-24.md | ✅ 有 retire_trigger + expires:2026-07-15 | ⚠️ **retire 条件未满足**：status=`active_discussion_ledger`，retire_trigger 写「Retire after the accepted rebuild-c6 and retrain-c5 OpenSpec carriers absorb or explicitly reject these paper-to-skill-gate decisions」——rebuild-c6 / retrain-c5 未 archived |
| **T6：非 phase0 杂项** | 3 | brainstorm-2026-06-17-demo-mvp.md / collaboration-and-roles.md / receipts/local-receipt.schema.json | ❌ 全无 frontmatter | brainstorm 是早期创意文档；collaboration-and-roles 是团队角色定义；local-receipt.schema.json 是 schema |

### CLAUDE.md §3 retire/expiry metadata 合规核

CLAUDE.md §3 原文：「Phase 0 route-control manifests (authority/stage/decision/status/gate materialization; not runtime contracts; **must carry retire/expiry metadata once filled**)」

- 127 files 中 **25** 有 retire_trigger（19.7%）
- **102** 缺 retire_trigger（80.3%）
- 其中 7 个 schema.yaml + 1 个 jpg + 1 个 README = 9 个非 manifest 文件可豁免
- **93 个 route-control manifest 缺 retire_trigger**——这是 CLAUDE.md §3 的系统性违规

**该 retire 的（retire 条件已满足但仍 tracked）**：

| 文件 | retire 条件 | 现值 | 建议 |
|---|---|---|---|
| phase0-d1-d10-closeout.md | D1-D10 accepted + OpenSpec carriers accepted/superseded/archived | user_decisions_accepted + pending=[] | 核 OpenSpec carriers 状态，若全 archived → 可 retire |
| phase0-d1-d10-user-decision-record.md | all D1-D10 non-pending + closeout records accepted state | user_decisions_accepted + pending=[] | 同上，可同步 retire |
| d1-d10-fast-pick-verdict-2026-06-24.md | Phase 0 D1-D10 closeout + OpenSpec carrier acceptance supersede | 同上 | 同上 |
| d1-d10-lora-zero-failure-decision-pack.md | closeout records all D1-D10 + accepted carrier map | 同上 | 同上 |
| phase0-d1-d10-cascade-audit-codex-2026-06-24.md | heterogeneous deframing review or user waiver recorded | R7 route signed（candidate unsigned） | ⚠️ route-only 签了但 candidate 未签，条件部分满足，不建议现在 retire |

---

## 一、物理清理执行包（6 批）

以下每批均为 plan-only，需磊哥一次性点头。批次按建议执行序排列（低风险→高风险）。

---

### 批次 1：Reports/ 32 tracked 退仓

**内容**：`Reports/` 目录 32 tracked files（含 .gitkeep），含 default-scope-apply logs（14 files）、uiue-proof（3 files）、其他 receipt/log。`.gitignore:60-62` 已写 `Reports/*` ignored + `!Reports/.gitkeep`，但 32 files 仍 tracked（force-add 遗留）。

**收益**：
- tracked files：32 → 1（仅留 .gitkeep）
- 体积：Reports/ 目录 2.9G（含 untracked，但 tracked 部分约 20MB）
- 退仓后 .gitignore 已就位，新生成 Reports/ 自动 ignored

**风险**：中高。`reports-migration-plan.md` 已分三层（A-no-touch / B-bundle迁移候选 / C-低风险候选），B 层 14 files 被 `docs/evidence-frozen/` 引用（但 frozen 目录有独立副本，退仓 live 不影响 frozen 引用）。C 层 0 外部引用。A 层有外部引用不退仓。

**rollback**：`git checkout HEAD -- Reports/<path>` 逐文件恢复；或 `git revert <commit>` 整批恢复。退仓前跑 `reports-migration-plan.md` 的 digest 索引（已备 `007e528f`）。

**验收命令**：
```
git ls-tree -r --name-only HEAD -- Reports/ | wc -l  # 应=1（仅 .gitkeep）
rg 'Reports/' docs/ openspec/ CLAUDE.md README.md Makefile  # 确认无新引用
git log --oneline -1  # 确认 commit
make verify-all  # 全链绿（Reports/ 不在 verify 链，应无影响）
```

**建议执行序**：① 第 1 执行（已备 migration plan + digest，低风险）；② 只退 C 层（0 引用）+ B 层（frozen 有副本）→ A 层保留 tracked。

---

### 批次 2：docs/evidence-frozen/ 73 重复文件 tarball 化

**内容**：`docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/` 下 551 tracked files，其中 72 对与 live `docs/**` byte-identical（sha256 同），1 对 drifted（`decisions.md`）。`frozen-duplicate-manifest.md` 已记 manifest（`590ff469`）。tarball 路径已定义：`docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree.tar.zst`。

**收益**：
- tracked files：551 → 1（仅 tar.zst + manifest）
- 体积：docs/evidence-frozen/ 10MB → ~2MB（zstd 压缩后）
- 消除 72 对重复文件的 git object 膨胀

**风险**：高。72 对中有部分被 CLAUDE.md / cascade-inventory.md / handoffs 等承重文件引用（`referenced_by` 列很长，如 `grill-decisions-amend-paradigm-tool-surface.md` 被 100+ 处引用）。但 frozen 目录的引用路径是 `docs/evidence-frozen/.../code-basis-pr38-worktree/...`，tarball 化后这些路径变成「需要先解压 tarball 才能访问」——不改变 live `docs/` 路径的引用。

**rollback**：`tar -I zstd -xf docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree.tar.zst -C docs/evidence-frozen/2026-07-03-n2n4-train-readiness` 解压恢复。manifest 已记每对的 restore_command。

**验收命令**：
```
git ls-tree -r --name-only HEAD -- docs/evidence-frozen/ | wc -l  # 应=2（tar.zst + manifest）
tar -I zstd -tf docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree.tar.zst | wc -l  # 应=551
shasum -a 256 docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree.tar.zst  # 记入 manifest
make verify-all  # 全链绿（frozen 不在 verify 链）
```

**建议执行序**：① 先打 tarball（`tar -I zstd -cf ...`）→ ② 验 tarball 完整性（551 files）→ ③ `git rm -r docs/evidence-frozen/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/` → ④ `git add` tarball + manifest → ⑤ 验收。

---

### 批次 3：docs/project/ phase0 retire 批（retire 条件已满足的 4 文件）

**内容**：以下 4 个文件的 retire_trigger 条件已满足（D1-D10 user decisions accepted + pending=[]），可标 `status: retired` 或移到 `docs/project/phase0/_retired/`：

| 文件 | retire 条件 | 现值 |
|---|---|---|
| phase0-d1-d10-closeout.md | D1-D10 accepted + OpenSpec carriers status | accepted_user_decisions_partial_closeout |
| phase0-d1-d10-user-decision-record.md | all D1-D10 non-pending + closeout records state | user_decisions_accepted + pending=[] |
| d1-d10-fast-pick-verdict-2026-06-24.md | Phase 0 closeout + OpenSpec supersede | 同上 |
| d1-d10-lora-zero-failure-decision-pack.md | closeout records all + accepted carrier map | 同上 |

**收益**：
- tracked files：4（不删，只标 retired 或移子目录）
- 体积：~200KB（4 files 合计）
- 消除「已 fulfilled retire_trigger 但仍 active」的 stale 状态

**风险**：低。不删原件，只改 status frontmatter + 可选移到 `_retired/` 子目录。需核 OpenSpec carriers 是否全 archived（`openspec/changes/` 下相关 change 的 status）。

**rollback**：`git revert <commit>` 或手动恢复 frontmatter status。

**验收命令**：
```
head -5 docs/project/phase0/phase0-d1-d10-closeout.md  # 确认 status: retired
rg 'status:.*retired' docs/project/phase0/  # 确认 4 files
openspec validate --all --strict  # OpenSpec 结构绿
make verify-all  # 全链绿
```

**建议执行序**：① 先核 OpenSpec carriers 状态（`openspec/changes/` 下 define-demo-default-scope 等 change 是否 archived）→ ② 若全 archived，标 4 files retired → ③ 可选移到 `_retired/`（磊哥拍是否物理移动）。

---

### 批次 4：Tools/paper-to-skill-gate/ spike 证据迁移

**内容**：`Tools/paper-to-skill-gate/` 28 tracked files（630MB），含 paper-repos/ + reference-repos/ + trial-runs/（9 papers × 2 files = 18）+ schemas/ + scripts/ + templates/。这是早期 paper absorption spike 的工作产物，paper-to-skill-gate-absorption-ledger（T5）记录了 grill 决策。absorption ledger status=`active_discussion_ledger`，retire 条件未满足（rebuild-c6/retrain-c5 未 archived）。

**收益**：
- tracked files：28 → 0（若退仓）或 28 → 5（若只留 ledger + pipeline + SKILL.md + README + integration-map，退仓 paper-repos/ + reference-repos/ + trial-runs/）
- 体积：630MB → ~50KB（只留文档）或 0（全退仓）
- paper-repos/ + reference-repos/ 是外部 repo 克隆，不应进仓

**风险**：中。paper-to-skill-gate-absorption-ledger 仍 `active_discussion_ledger`，retire 条件未满足。但 paper-repos/ + reference-repos/ 是外部 repo 克隆（非本项目代码），退仓不影响 absorption ledger 的引用（ledger 引用的是 paper 名 + gate 结论，不是 repo 文件路径）。

**rollback**：`git checkout HEAD -- Tools/paper-to-skill-gate/` 恢复。paper-repos/ 可从原始来源重新克隆。

**验收命令**：
```
git ls-tree -r --name-only HEAD -- Tools/paper-to-skill-gate/ | wc -l  # 确认退仓后 count
rg 'paper-to-skill-gate' docs/ openspec/  # 确认引用仍指向 ledger（非 repo 文件）
make verify-all  # 全链绿
```

**建议执行序**：① 先退 paper-repos/ + reference-repos/（外部 repo 克隆，最低风险）→ ② trial-runs/ 保留（是 gate 审计产物，有溯源价值）→ ③ schemas/ + scripts/ + templates/ 保留（有 reuse 价值）→ ④ 等 absorption ledger retire 条件满足后再清理剩余。

---

### 批次 5：dev/spike-e3/ 退仓

**内容**：`dev/spike-e3/` 3.1GB，23764 files。这是 E3 spike 的工作目录（含 Reports/ 子目录 + 可能的 model checkpoint / 临时文件）。不在 `docs/` 下，但在仓内 tracked。

**收益**：
- tracked files：23764 → 0
- 体积：3.1GB（全仓最大单目录）
- 消除 dev spike 对仓体积的巨大膨胀

**风险**：中高。需核 `dev/spike-e3/` 是否被任何承重文件引用。spike 目录通常是一次性实验产物，但需确认没有 handoff/receipt 指向 spike-e3 内的文件。

**rollback**：`git checkout HEAD -- dev/spike-e3/` 恢复。但 3.1GB 恢复耗时。建议退仓前先打 tarball 备份到仓外。

**验收命令**：
```
git ls-tree -r --name-only HEAD -- dev/spike-e3/ | wc -l  # 应=0
rg 'spike-e3' docs/ openspec/ CLAUDE.md  # 确认无引用
du -sh .git/  # 确认 .git 体积下降
make verify-all  # 全链绿
```

**建议执行序**：① 先 `rg 'spike-e3'` 核引用 → ② 若无引用，先打 tarball 到仓外 `tar -cf /tmp/spike-e3-backup.tar dev/spike-e3/` → ③ `git rm -r dev/spike-e3/` → ④ `git gc --prune=now` 回收 .git 空间 → ⑤ 验收。

---

### 批次 6：docs/project/ 缺 retire_trigger 的 93 files 补 frontmatter

**内容**：127 tracked files 中 93 个 route-control manifest 缺 retire_trigger（CLAUDE.md §3 系统性违规）。需逐文件补 frontmatter：`retire_trigger:` + `expires:`。

**收益**：
- CLAUDE.md §3 合规率：19.7% → 100%
- 消除「manifest 已填但无 retire 元数据」的 stale 风险

**风险**：低。只加 frontmatter，不改正文。但 93 files 逐文件写 retire_trigger 需要判断每个文件的 retire 条件——机械批量补会出错。

**rollback**：`git revert <commit>` 恢复。

**验收命令**：
```
for f in $(git ls-tree -r --name-only HEAD -- docs/project/); do
  head -15 "$f" | grep -q 'retire_trigger' || echo "MISSING: $f"
done  # 应无输出
```

**建议执行序**：最后执行（先清理上面 5 批，文件数减少后再补 frontmatter 更高效）。按 T 组分批补：T4（68 files，r5 全链）→ T3（10 files，rebuild-c6 辅助）→ T2（4 files，tiny-ablation）→ T6（3 files，杂项）→ T0（7 files，schema 需磊哥拍是否要）。

---

## 二、建议执行总序

| 序 | 批次 | 风险 | tracked 减 | 体积减 | 前置 |
|---|---|---|---|---|---|
| 1 | 批1 Reports/ 退仓 | 中高 | 32→1 | ~20MB | migration plan 已备 |
| 2 | 批2 evidence-frozen tarball | 高 | 551→2 | ~8MB | tarball 完整性验 |
| 3 | 批3 phase0 retire 4 files | 低 | 0（改 status） | 0 | 核 OpenSpec carriers |
| 4 | 批4 paper-to-skill-gate 部分退仓 | 中 | 28→10 | ~630MB→~50KB | 核引用 |
| 5 | 批5 dev/spike-e3 退仓 | 中高 | 13→0（🔴commander 纠错：原稿 23764 系把 gitignored 本地 .build 混入,git ls-files dev/spike-e3 亲核=13） | 本地磁盘 3.1GB（非 tracked 体积） | 核引用 + 仓外备份 |
| 6 | 批6 补 93 files retire_trigger | 低 | 0（加 frontmatter） | 0 | 上面 5 批完成后 |

**总计（commander 亲核修正口径）**：tracked files 减少 ~611（批1:31+批2:549+批4:18+批5:13）；**本地磁盘**减少 ~3.7GB（主要是 gitignored 本地件清理,与 tracked 收益分开计）；CLAUDE.md §3 合规率 19.7%→100%。原稿 ~24375 系 tracked/本地件混算,已废。

## 三、Non-Claims

- 本文件是 plan-only，零 commit 权，不授权任何删除/退仓/移动。
- 所有批次均需磊哥逐批点头。
- reduction-table.md v1 的 disposition 终版不被本文件 supersede。
- 批次 1-2 的 migration plan / manifest 已备（`007e528f` / `590ff469`），本文件是执行层调度。
- 批次 5（dev/spike-e3）不在 reduction-table v1 内（W2 未扫 dev/），是本审计新发现项——需磊哥确认是否纳入本轮清理。

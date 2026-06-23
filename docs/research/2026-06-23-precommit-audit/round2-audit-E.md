# Round 2 Precommit 审计 — 审计员 E

> **审计员**: E（开放式，本机 Read/grep 实核）
> **维度**: ① 脱敏（按更新后 CLAUDE §6，磊哥 2026-06-23 放宽）② 脏区（orphan/重复/临时/失败残留）③ SSOT 单源
> **范围**: commit 推 GitHub（private 仓 `rayw-lab/MAformac`）前最后脱敏 + 脏区门
> **as-of**: 2026-06-23
> **待 commit 规模**: staged 160（含 ~120 个 `D Reports/...` 删除入仓）+ untracked 126 + modified 31；本审计实核 141 个待入仓文件（staged 非删除 + untracked，排除已 ignore）

---

## Executive Verdict

**has_p0p1 = false（无脱敏 P0；无阻断性 P1）**

- **脱敏 P0 = 0**：密钥/token/password / PII（手机/身份证/邮箱）/ 报价成本 / 项目内部真实人名 全部 0 命中。
- **iFlytek/Chery/讯飞/奇瑞/车型代号 全部出现在内部调研档/教训档** → 按新 §6（private 仓内部调研档可入）**不报 P0**。
- **commit 内容脱敏合规（新 §6）= ✅ 合规**。
- 余 P2 级建议 3 条（orphan png 不 add / generated 入仓不一致 / boundary 223 口径 banner），均非阻断，列于 findings 表。

---

## 实核痕迹（带 file:line / 命令）

### 维度① 脱敏（按新 §6）

| 扫描项 | 命令/方法 | 结果 |
|---|---|---|
| 密钥/token/secret/password/BEGIN | `grep -InE '(api[_-]?key\|secret\|token\|password\|-----BEGIN)'` over 141 files | **0 真命中**。全部是 LLM 工程术语：`assistant_token`/`tokenizer`/`return_assistant_tokens_mask`（C5/C6 swift）、UI `surface_role token`、thinking token 调研。`docs/lessons-learned.md:26`「API key 走 `secret_ref` 不入仓」= 设计说明，合规 |
| 手机号 11 位 | `grep -InE '1[3-9][0-9]{9}'` | **0**（唯一命中 `2026-06-23-probe-uiue...:392` 是 Figma 帮助文档 URL 文章 ID `39216419318551`，误报） |
| 身份证 18 位 | `grep -InE '[0-9]{17}[0-9Xx]'` | **0** |
| 邮箱（排除 example/noreply/anthropic）| `grep -InE '...@...\.[a-z]{2,}'` | **0** |
| 报价/成本（元/万元/RMB/报价/售价/单价/预算）| `grep -InE '(报价\|成本价\|售价\|单价\|￥[0-9]\|[0-9]+万元\|预算[0-9])'` | **0** |
| 真实人名（经理/工程师/负责人 + 中文名）| `grep -InE '(经理\|工程师\|负责人\|联系人\|作者)...中文名'` | **0** |
| 英文真实人名 | `grep` Andon Labs / Stella Laurenzo | 命中 4 处（`lens6-issue-oracle.md:16,79` / `README.md:42,145` / `TODO...:70`）= 引用**公开 GitHub issue #42796/#64991 的作者 + 公开实验室**（AMD Stella Laurenzo / Andon Labs），技术调研引用非项目 PII → **不报 P0** |

**真实厂名/代号分布（按新 §6 全部不报 P0，仅记录可入仓）**：
`iFlytek/讯飞/Chery/奇瑞/AH8/T19/E0Y/E0V/某车厂` 命中 12 个文件，全部是内部调研/教训档：
- `docs/research/2026-06-22-top-fc-skill-table-teardown/{README,teardown}.md`
- `docs/research/2026-06-22-mvp-10family-device-boundary.md` / `raw-vault-5-evidence-P.md`
- `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` / `docs/lessons-learned.md`
- `docs/research/2026-06-23-loopaudit-megarun/round-0{2,3,4}/audit-2.md` / `docs/research/2026-06-23-precommit-audit/{audit-C,fixes-round1}.md` / `probe-uiue-agent-paradigm.md`

**对外交付物检查**：本次 commit **无 whitepaper/对外/客户/交付** 类文件含真实厂名。4 个 `openspec/changes/*/proposal.md`（匹配「proposal」文件名）实核 = **0 真实厂名 + 0「某车厂」**（用通用术语），非对外交付物，合规。

**红线（不复制真实座舱原文语料）**：`top-fc-skill-table-teardown/teardown.md:3`「只抽结构/范式/计数，**不复制原始客户语料**」；`禁外传/对内/机密` grep over 调研档 = **0 命中**。`generated/10-family-device-boundary.md` 同样 0 原文语料。红线遵守。

### 维度② 脏区

| 项 | 实核 | 结论 |
|---|---|---|
| `.DS_Store`×3（docs/, docs/research/, docs/grill-tournament/）| `git check-ignore docs/grill-tournament/.DS_Store` → **已 ignore** | ✅ 不会进 commit，非脏区（初判误报已排除） |
| 根目录 `maformac-h5-preview.png`（307k orphan）| `grep -rl maformac-h5-preview docs/ openspec/ contracts/` → 唯一引用来自审计档 `audit-C.md` 自身，**无项目文档当资产引用** | P2：untracked，建议**不 add** |
| 临时/失败残留（.tmp/.bak/~/.swp/SUPERSEDED/.snapshot.）在待入仓 | `grep -iE` over 141 files | **0**（SUPERSEDED.md/.snapshot.py 均在 `D Reports/...` 删除列，正确清出） |
| θ-α 失败 run 2.8G | `.gitignore` 新增 `Reports/` + `.playwright-mcp/` + `.dispatch/` + `.cc-connect/` | ✅ 正确 ignore，失败 run 不入仓（锚点 0/23 已在 grill-decisions 文档） |
| `.claude/hooks/` + `settings.local.json` | `.gitignore` 新增（CVE-2025-59536 clone RCE）| ✅ 正确 |

### 维度③ SSOT 单源

| 项 | 实核 | 结论 |
|---|---|---|
| **562 口径单源** | 磊哥 2026-06-23 亲拍全仓唯一权威 = `191 device / 562 intent / 2159 行 / 54.1%`（族外 976 intent / 1831 行）。权威 banner + source 锚点齐全：`grill-decisions-master.md §0 口径权威表`（废口径单一物理副本）/ `cascade-inventory.md:5` / `mvp-10family-device-boundary.md:3` / `a2-codebase-audit/README.md:3`（历史档加 banner 覆盖 534 旧定性）| ✅ SSOT 收口完整（旧 534 系列标作废指回权威，不裸留） |
| **grill SSOT 单源** | `grill-decisions-master.md §0` 声明唯一统一权威，旧 3 份并存档（paradigm §15 / GRILL-MASTER / cascade）全标 `SUPERSEDED-BY`/`HISTORICAL` 指回；口径权威表单一物理副本，防双权威表分叉 | ✅ 教科书级 SSOT 收口 |
| **generated 产物可复现性** | 重跑 `python3 scripts/gen_tool_contract.py --contract contracts/semantic-function-contract.jsonl` → `diff` staged 产物：`B_frame.frame_schema.json`/`D_domain.tools.json`/`rendered_tools_text` **全部一致**（产物新鲜非陈旧入仓）；源 `contracts/semantic-function-contract.jsonl` 已 tracked，`wc -l = 3990`（与权威口径一致）| ✅ |
| **generated 入仓不一致** | staged：B_frame/D_domain/rendered（新派生物，新鲜）；**untracked 未 staged**：`10-family-device-map.json`（device→family，223 device）+ `10-family-device-boundary.md`。后两者被 **8 个调研档引用为 device-map 一手源**（a2-codebase-audit lens1/3/4/README/codex-checks + paradigm + loopaudit）| P2：被多档引用的 SSOT 产物没入，新派生物入了 → 入仓不一致，需磊哥裁决（一起入 or 都不入） |
| **223 device 口径分叉风险** | `10-family-device-boundary.md:6,12,245` 写「223 device」（G4 含 disputed 中间态），与终拍权威「191」不同；自身**无权威 banner**。`a2-codebase-audit/INDEX.md:37` 已标「generated 旁路 223 含 disputed 过期」| P2（条件性）：因 untracked 未 staged，当前不进 commit；**若与上条一起 add，需先加 banner 标 191 为终值**，否则 223 成新口径分叉源（claim-vs-reality 第10变体） |

---

## Findings 表

| # | 级别 | 维度 | 文件:line | 问题 | 建议 |
|---|---|---|---|---|---|
| E-1 | P2 | 脏区 | `maformac-h5-preview.png`（根目录）| orphan png 307k，无项目文档引用（唯一引用是审计档自身）| commit 时**不 `git add`**；或移入 raw |
| E-2 | P2 | SSOT/脏区 | `generated/10-family-device-map.json` + `10-family-device-boundary.md`（untracked）| 被 8 调研档引用为 device-map 一手源，却未 staged，而同目录新派生物已 staged → 入仓不一致 | 磊哥裁决：一起入仓（被引用一手源应可溯）或都排除 |
| E-3 | P2（条件性）| SSOT | `generated/10-family-device-boundary.md:6,12,245` | 「223 device」中间态无权威 banner，与终拍 191 分叉 | 若 E-2 选择入仓，先加 banner 标「191 为终拍权威，223=G4 含 disputed 中间态」 |

> 无 P0、无阻断性 P1。E-1/E-2/E-3 全 P2，不阻断 commit；E-2/E-3 是 generated/ 入仓策略问题，建议磊哥一并定 generated 入仓口径。

---

## Summary

按更新后 CLAUDE §6（磊哥 2026-06-23 放宽：private 仓内部调研档允许真实合作方/车厂名/调研一手料），**本次 commit 内容脱敏合规**：

1. **脱敏 P0 = 0**：无密钥/token/PII（手机/身份证/邮箱）/报价成本/项目内部真实人名。iFlytek/Chery 等真实厂名全在内部调研/教训档，新 §6 下可入仓不报 P0。Andon Labs/Stella Laurenzo 是公开 GitHub issue 引用，非 PII。红线（不复制原文语料）遵守。
2. **脏区干净**：`.DS_Store` 已 ignore；θ-α 2.8G 失败 run + `.claude/hooks/` + 临时目录全部新增 ignore；无临时/残留混入。唯一 orphan = 根目录 png（建议不 add，P2）。
3. **SSOT 收口完整**：562 口径单源（磊哥亲拍，权威 banner + source 锚点齐全，旧 534 标作废指回）；grill SSOT 单源（grill-decisions-master 唯一权威，旧 3 份标 historical）；generated 产物经重跑 diff 验证新鲜可复现。唯一瑕疵 = generated/ 入仓不一致（被引用一手源未 staged，P2，需磊哥定入仓口径）。

# Precommit 审计 第 2 轮 · 审计员 D

> 审计员：D（开放式，本机 Read/grep 实核 + Write 报告）
> 日期：2026-06-23
> 项目根：/Users/wanglei/workspace/MAformac
> 维度：① 第 1 轮 4 项 P1 修复确认（真修 / 无回归）② 562 口径 + 范式 D-domain 一致（无新 drift / 段间分叉）③ commit-ready 整体一致
> 口径背景：**562**（磊哥 2026-06-23 亲拍权威，534/2086/52.3%/1004/1904 系列废）；范式 generic frame(`tool_call_frame`) 否决 → D-domain 具名工具；工具数未拍（562=intent 非工具数）；U10/U27 状态四态。

---

## VERDICT

- **has_p0p1 = true**
- **P0 条数 = 0**
- **P1 条数 = 2**（D-P1-1 段间分叉 / D-P1-2 staging 不完整）
- **第 1 轮 4 项 P1 = 全部真修 ✅**（逐条 grep 坐实，无回归）

> 维度内无 P0。两条 P1 均为「未纳入 commit 的脏区/索引层口径 stale」与「staging 中途态不完整」，**非范式 drift、非阻断**——但 commit 前应处置（或显式确认延后）。
> 维度外承接（不重复裁决，仅记录仍存在）：audit-C 的 **P0-1 RAW vault 脱敏文件**（`docs/research/2026-06-22-raw-vault-5-evidence-P.md` 仍含 1 处敏感名，untracked）= commit 硬阻断，仍未处置。

---

## 第 1 轮 4 项 P1 修复确认（逐条 grep 实核）

| # | 指派修复 | 实核痕迹（file:line） | 结论 |
|---|---|---|---|
| **Item 1** | Q15（=CAS1 cascade inventory）从「🔴待grill」移到「✅已执行」 | `grill-decisions-master.md:70`「**15** 行 = ✅已执行（CAS1 落地）」/ `:100`「✅已执行（1，产物落地）：Q15」/ `:103`「🔴待grill（纯待，**15**）…Q15=CAS1 已执行→移出」/ `:240` CAS 表「Q15 = ✅已执行（产物=cascade-inventory.md）」/ `final-grill-list.md:21`「**✅已执行（CAS1 落地）**…= Q15/CAS1 产物，非待 grill」 | ✅ **真修** |
| **Item 2** | paradigm 工具数 5 处加 `[SUPERSEDED→§14]` | paradigm `:39 / :52 / :57 / :100 / :129` 五处均含 `~~~30-60~~ 🔴[SUPERSEDED→§14 G2:212…]`；`:212`（权威源「不拍 30-60 实算」）+ `:385`（既有 SUPERSEDED note）合法保留；**无裸 30-60 残留** | ✅ **真修** |
| **Item 3** | paradigm:490 U10「三态」→「四态」 | `:490`「**状态 UI 四态（clarify/unsupported/safety/crash，旧「三态」已废→见 master §3/U27）**」；全文件唯一「三态」出现即此已纠正 context | ✅ **真修** |
| **Item 4** | master:15 §15 SUPERSEDED 行号锚改对 | `master:15`「§15 顶部（paradigm **:300** §15 标题 / **:302** SUPERSEDED banner）…旧引『:295』= §14 正文内空行已 stale」；grep 复核 paradigm `^## §15`=**:300**、`SUPERSEDED-BY …master`=**:302**，与改后锚**精确相符** | ✅ **真修** |

> 注：第 1 轮 fixes-round1.md 写「files_touched = `docs/grill-tournament/...`」与「`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`」——实核两条路径均存在且修复均落在正确文件（Item 1/4 落 grill-tournament/，Item 2/3 落 c5-recovery/paradigm）。无错改文件。
> 回归检查：`make verify-cross-section` = `consistent: true / drifts: [] / caliber_violations: []`（EXIT 0），口径 562 / 10族 device-intent / 族外 intent 锚全一致，本轮修复未引入段间分叉。

---

## 开放式 findings（维度 ②③）

| ID | 级别 | 维度 | 发现（file:line） | 为什么是问题 / 边界判定 |
|---|---|---|---|---|
| **D-P1-1** | P1 | ②段间分叉 | `docs/research/INDEX.md:29`（tracked + ` M` staged）裸述「数字口径坐实(device 191/**intent 534**/…534=intent 非工具数)」，**全文件无 562**（grep 0 命中）。与 `CLAUDE.md §9:113`「intent **562**(磊哥 2026-06-23 终拍,旧 534/2086 系列全废)」**同描述 a2 audit 却口径相反** = 段间分叉。`make verify-cross-section` **不覆盖 INDEX.md**（不在 baseline 列表）→ drift 漏网。 | tracked baseline 索引层呈现 534 为「坐实」(confirmed) 而非 562，stale。**边界**：cascade-inventory.md:154 已把 INDEX.md 显式判为 `no_change`（视作 routing map），故非「未盘点裸残留」=**P1 非 P0**；但「坐实」措辞 + 零 562 注，建议至少加 `(口径 534→562 终拍见 CLAUDE §9)` 边注，或纳入 cross-section 覆盖。 |
| **D-P1-2** | P1 | ③commit-ready | staging 中途态不完整：`docs/c5-recovery-2026-06-22/` + `docs/grill-tournament/`（含本轮被审/被修文档）全 **untracked(`??`)**；`scripts/cross_section_check.py / axis_schema.py / scorer_single.py` untracked，但**工作树 Makefile:22-23** `verify-cross-section` 引用 `cross_section_check.py`；Makefile 状态 `MM`（staged 与工作树双改）。staged 集 = 仅 code(Core/scripts 部分/generated)+ 少量 tracked doc mod(CLAUDE/CONTEXT/lessons/INDEX)。 | 当前 staged-only 内部自洽（staged Makefile 不引 cross_section、也不含该 script），但**与跑过 `make verify` 通过的工作树状态不一致**——若按 staged 现状 commit，被审/被修的 grill 文档 + 验证脚本全不进 commit = 修复与验证链断在 commit 外。**边界**：非 drift、非事实错；是 staging 顺序问题。commit 前需明确「这批 doc/script 是否同 commit 入」，否则修复白做(不进库)。 |

### 观察（非 P0/P1，记录给磊哥）

- **OBS-1**：a2-codebase-audit 全目录(README + lens1-8 + INDEX)**untracked(0 tracked)**，不在 commit。README 头有 562 override banner(round-03)✅；但 **lens1-8 全无 562 banner**（cascade-inventory:120 写「README + lens1-8 → banner」只 README 落地），`lens4.md:10-16` 仍把 534/2086/52.3% 排为「🏆 最高(拍板)权威」。因 untracked + finder 一手档(归档态合法) + cascade 已盘点为 known-pending → **不阻断本 commit**；若 a2 dir 后续 `git add`，lens 缺 banner 应补。
- **OBS-2**：`CLAUDE.md §9:111` 仍写「剩 §15 GOV/CAS/TRN/UIX **35** 扩散」——旧 framing（paradigm §15 已 SUPERSEDED-BY master 统一收口）。与 paradigm §15:302 措辞一致(其本身 banner-superseded)，pointer 性质，非裸断言 → 观察级。
- **OBS-3**：`maformac-h5-preview.png`(根 orphan) + audit-C P0-1 RAW vault 脱敏文件均 untracked，仍在工作树（audit-C 已记，本轮复核仍存在，未处置）。

---

## 实核痕迹清单（命令）

- `grep -n "Q15" grill-decisions-master.md` → :70/:100/:103/:240（Item1）
- `grep -ni "cascade|CAS1|已执行" final-grill-list.md` → :21（Item1）
- `grep -n "30-60" paradigm` → :39/:52/:57/:100/:129(SUPERSEDED) + :212/:385(合法)（Item2）
- `sed -n '488,492p' paradigm` + `grep -n "三态" paradigm` → 唯一 :490 已纠（Item3）
- `grep -n "^## §15" paradigm`=:300 / `grep -n "SUPERSEDED-BY …master" paradigm`=:302（Item4 锚坐实）
- `make verify-cross-section` → consistent:true / drifts:[] / caliber_violations:[]（回归）
- `git ls-files docs/research/INDEX.md` = tracked / `git status --short` = ` M` / `grep -n 562 INDEX.md` = 0（D-P1-1）
- `git status --short docs/grill-tournament/ docs/c5-recovery-2026-06-22/` = `??`（D-P1-2）
- `git show :Makefile | grep cross_section` = 空 / 工作树 `Makefile:22-23` 引 cross_section_check.py(untracked)（D-P1-2）
- `grep -c "讯飞|iFlytek|Chery|某车厂" raw-vault-5-evidence-P.md` = 1（OBS-3 / audit-C P0-1 复核仍存）

---

## SUMMARY

第 1 轮 4 项 P1 **全部真修、无回归**，逐条 grep 坐实（Item4 行号锚 :295→:300/:302 已精确纠对，grep 复核相符）。维度 ②（562 口径 + D-domain 范式）：核心 baseline（CLAUDE §9 / CONTEXT.md / cascade-inventory / grill-decisions-master / paradigm）**口径 562 单源、范式 D-domain 一致、无新 drift**；`make verify-cross-section` EXIT 0。唯一段间分叉 = **INDEX.md:29 裸 534 vs CLAUDE §9 562**（D-P1-1，cascade 已判 no_change 故 P1 非 P0，但建议加边注 / 纳 cross-section）。维度 ③：commit staging **中途态不完整**（被审/被修 grill 文档 + verify 脚本全 untracked，staged 仅 code + 少量 doc mod），D-P1-2 提示 commit 前需确认这批 doc/script 是否同 commit 入，否则修复不进库。维度内 **无 P0**；audit-C 的 RAW vault 脱敏 P0-1（commit 硬阻断）维度外、本轮复核仍存在未处置。

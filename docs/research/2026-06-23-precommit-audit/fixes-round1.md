# Precommit 审计 第 1 轮 P1 修复回执

> 修复官：CC（本机 Read→grep 核实→Edit，逐个坐实）
> 日期：2026-06-23
> 范围：3 份审计报告（audit-A/B/C）的 4 个指派 P1（磊哥 catch 的 Q15 + audit-A P1 + audit-B 两条 P1）
> 验证：`make verify-cross-section` → `consistent: true / drifts: [] / caliber_violations: []`（EXIT 0），口径 562 未受影响

## 汇总

- **修复条数**：4 项指派 finding 全部修复（落地 4 个文件、共 9 处编辑）
- **deferred**：0（4 项全闭合）
- **files_touched**（4 个）：
  - `docs/grill-tournament/grill-decisions-master.md`（item 1 ×4 处 + item 4 ×1 处）
  - `docs/grill-tournament/final-grill-list.md`（item 1 ×1 处）
  - `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`（item 2 ×5 处 + item 3 ×1 处）
  - （cascade-inventory.md 未改 —— 它本身就是 Q15/CAS1 的产物，作为证据被引用，不需编辑）

## 逐条 finding → 怎么改 + file:line

### Item 1 🔴 Q15 状态标错（磊哥 catch：Q15=CAS1=cascade inventory 已产出，非待 grill）

理由：`cascade-inventory.md` 就是 Q15/CAS1 的产物（综合官合并 4 路 reader 逐文件 verdict + 主线程亲核，含 `source_decision/target_file/...verification_gate` 全字段），不应留在「待 grill」池。

- `grill-decisions-master.md:70`（§2 锦标赛表 Q15 行）：状态 `🔴待grill（meta，先做）` → **`✅已执行（CAS1 落地）`**，落点列改为指向产物 `cascade-inventory.md`。
- `grill-decisions-master.md:100`（§2 状态统计）：新增 **`✅已执行（1，产物落地非待 grill）：Q15`** 行。
- `grill-decisions-master.md:103`（§2 状态统计 🔴待grill 行）：从该池移除 Q15，计数 16→**15**，加边注「Q15=CAS1 已执行→移出待 grill 池」。
- `grill-decisions-master.md:240`（§5 CAS 表 Q15 行）：状态 `🔴（meta，先做）` → **`✅已执行（产物=cascade-inventory.md）`**。
- `final-grill-list.md:21`（第 21 行 cascade inventory 题）：问题单元前缀 **`✅已执行（CAS1 落地）`** + 验证方式列改写为「产物 = cascade-inventory.md … = Q15/CAS1 产物，非待 grill」。

未改（合法保留）：`master:235/:247/:278` 把 Q15/CAS1 作为「meta 全清单必先做」的**排序锚**引用——这是层级排序语境（其在级联顺序中的位置），不是待 grill 状态声明，与「已执行」不矛盾，故保留。

### Item 2 audit-A P1（~30-60 工具数/挂载 裸残留，段间分叉）

理由：~30-60 已被同文档 §14 G2:212「不拍 30-60，实算」+ §16:385 + CONTEXT.md/master §0 三处定性为 SUPERSEDED/废口径，但 paradigm 文档源处 5 行仍裸出现。对称处理（对齐同文档 §6:58/82「训练全集泛化」已有的 `~~strikethrough~~ + 🔴[SUPERSEDED]` 范式）。

每处加 inline `~~删除线~~ + 🔴[SUPERSEDED→§14 G2:212：工具数不拍 ~30-60，待 value-form 实算]`：
- `grill-decisions-amend-paradigm-tool-surface.md:39`（§6 demo 取巧表「工具数」行）
- `:52`（磊哥终极约束「端侧只挂 10 族 value-form 工具」）
- `:57`（10 招第 2 招「受限解码白名单约束只吐挂载工具」）
- `:100`（G6-C 实测点「端侧具名工具子集」）
- `:129`（§13 B1「10 族 value-form 工具」，marker 同时指 §14 G2:212 / §16:385）

未改（合法）：`:212`（§14 G2 = 权威源「不拍 30-60，实算」）、`:385`（§16 已有的 SUPERSEDED 处置 note）。

### Item 3 audit-B P1 F1（U10 状态 UI 三态 stale）

理由：paradigm §18 U10 表头写「三态」，但该行结论/落点单元已列 4 个态（clarify/unsupported/safety_refusal/crash）+ 消费 DemoVisualState 7 态；master §3/U27/§4.5 全写「四态」。表头 wording stale。

- `grill-decisions-amend-paradigm-tool-surface.md:490`（U10 议题列）：`状态 UI 三态` → **`状态 UI 四态（clarify/unsupported/safety/crash，旧「三态」已废→见 master §3/U27）`**。结论/落点单元内容本就一致（4 态），未动。

### Item 4 audit-B P1 F2（master §0 引用 paradigm §15 SUPERSEDED 行号 stale）

理由：master §0:15 称「§15 顶部（paradigm :295）已标 SUPERSEDED」，但 grep 实核 §15 标题在 :300、SUPERSEDED banner 在 :302，:295 是 §14 正文内空行（off-by-5~7，cite 行存在但所指内容不在该行）。

- `grill-decisions-master.md:15`（§0 处置表 historical 处置单元）：`§15 顶部（paradigm :295）已标 SUPERSEDED-BY` → **`§15 顶部（paradigm :300 §15 标题 / :302 SUPERSEDED banner）已标 SUPERSEDED-BY`** + 加 grep 实核纠正注「旧引『:295』= §14 正文内空行已 stale」。

grep 坐实：`grep "^## §15" paradigm` = :300；`grep "SUPERSEDED-BY .../grill-decisions-master" paradigm` = :302。

## 验证

- `make verify-cross-section`：`consistent: true`、`drifts: []`、`caliber_violations: []`（EXIT 0）——口径 562 / 10族 device-intent / 族外 intent 锚全一致，本轮编辑未引入段间分叉。
- 最终 grep 复核：item 2 裸 30-60 残留 = 0（仅余 :212 权威 + :385 note）；item 3 「状态 UI 三态」残留 = 0；item 1/4 改对态/行号已坐实。

## 不在本轮范围（指派外，记录给磊哥决策）

audit-C 的 **P0-1 脱敏**（新增 untracked 文件 `docs/research/🔴 RAW vault 5 处独立证据…坐实).md` 带真实车厂+合作方名 iFlytek-Chery + RAW 交付手册逐字时序图）+ **P1-1/P1-2/P1-3**（emoji stray 文件 / 根 PNG orphan / pre-existing 讯飞泄漏）**未在本修复官 4 项指派内**，未处理。**P0-1 是 commit 硬阻断**，建议磊哥单独处置（最省事 = 该文件不 git add，同时消 P1-1）。

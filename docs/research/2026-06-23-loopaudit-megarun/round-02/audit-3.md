# Loopaudit Megarun — Round 02 / 审计员 #3

> **round**: 02
> **审计员**: #3
> **负责维度**: 范式一致（D-domain / 无 generic-frame drift）+ 可执行性（change skeleton 合规 / 物理落点可派单）
> **as-of**: 2026-06-23
> **verdict**: **has_p0p1 = true**（1×P1 + 2×P2；无 P0）

---

## 实核痕迹（本机 Read/grep/openspec 实跑，非凭印象）

| 核验项 | 命令/动作 | 结果 |
|---|---|---|
| 全集行数 | `wc -l contracts/semantic-function-contract.jsonl` | **3990**（与全仓口径表一致 ✅）|
| 4 change skeleton 存在 | `find openspec/changes/*/` + `openspec list` | 4 个全在，validate **valid**（migrate-d-domain-tool-surface / retrain-c5-lora-d-domain / rebuild-c6-four-layer-bench / define-demo-golden-run-and-voice）✅ |
| skeleton DRAFT 合规 | `head proposal.md` ×4 | 全有「⚠️ DRAFT SKELETON…待人审 propose」+「守 agree-before-build，不进 apply / 不写实现代码」+ 决策权威源 cite ✅ |
| skeleton spec delta | `grep specs/*/spec.md` ×4 | MODIFIED/ADDED Requirement SHALL + placeholder Scenario；**D-domain 为 new 目标、generic frame 为 rejected old**，无反向 drift ✅ |
| skeleton 口径 | `grep 562/534 proposal.md` ×4 | 全用 **562**（device 191 / 562 intent / 2159 行 / 54.1% / 族外 480/976/1831），534 系列只在「全废」语境出现 ✅ |
| 活基线口径 | `grep 534/562/tool_call_frame` CLAUDE.md/SRD/MASTER/state-cells.yaml | CLAUDE §9 :113 = **562**（非 stale 534）✅；SRD :3/:66-206 D-domain + 562 ✅；MASTER banner :8 = 562 ✅；state-cells.yaml :11-44 D-domain 正交声明 ✅ |
| 全仓 534 残留 | `grep --include=*.md/*.yaml 534`（滤 jsonl hash / 废口径语境 / unicode 协议） | 活基线 + 契约 + grill SSOT **无裸 534 当权威**；剩余全是「废口径 grep 锚」「unicode 协议(534F)」「jsonl hash」= false positive ✅ |
| §2 状态统计 cross-section | per-Q grep ×16（🔴待grill 列表） | §2统计「✅5 / →A2 4 / 🟡16 / 🔴16 = 41」逐 Q 核对**一致** ✅ |
| Q07 grep 锚（562 是否误列 stale） | `grep Q07` final-grill-list + master §2 + AUD6 | SSOT（final-grill-list Q07 + master §2:62 + §5:233）锚 = `tool_call_frame/set_cabin/B_frame/223/534/2086`，**562 正确排除** ✅（仅 round-01/judge.md 历史档残留，见 P2-1）|
| 代码未假迁移 | `grep 已迁/已重构/A2完成` + `grep tool_call_frame Core/Contracts/ToolContractCompiler.swift` | 无任何「代码已迁 D-domain」假声称 ✅；代码仍 `tool_call_frame`（:27/:148）= A2 未派单，与「skeleton DRAFT 待 propose」一致 ✅ |
| **mark_historical banner 落地** | `head -3` ×3（capabilities/function-spec-full/function-spec-full-v0） | **capabilities.yaml ✅ / function-spec-full-v0.yaml ✅ / function-spec-full.yaml ❌ 无 banner** → **P1-1** |

---

## Findings

| # | severity | issue | location | fix |
|---|---|---|---|---|
| P1-1 | **P1** | **T1 mark_historical banner 部分执行 drift（claim-vs-reality 第10变体在级联自身复发）**。inventory T1:88 + §4.2:253 + 阶段1 step1:210 把 `contracts/function-spec-full.yaml` 列为 `mark_historical`（P0）要求加 `HISTORICAL banner(v1-generic-frame-archived)`。实核：3 个 mark_historical 文件中 `capabilities.yaml`、`function-spec-full-v0.yaml` **已加 banner**，唯独 `function-spec-full.yaml` **文件头无任何 HISTORICAL 标记**（head 仍 `version:1 / authority: generated_from_semantic_function_contract_jsonl`）。这是**最危险的一个**——它是 14000 行的 generated 全量 spec，`authority:` 字段自带权威感，最易被未来 session/agent 误当 D-domain 权威派生源。2/3 兄弟已 banner 制造「mark_historical 批已跑」假完成信号（读者见 2 个 bannered + 此文件无 banner → 误推此文件**非** historical = 反向误判）。inventory 对 T5 历史快照批显式标 PENDING，但**对 T1 阶段1 的 mark_historical 执行状态无追踪**，掩盖此 partial drift。 | `contracts/function-spec-full.yaml:1`（无 banner）vs `docs/grill-tournament/cascade-inventory.md:88,210,253`（要求加 banner） | 在 `function-spec-full.yaml` 文件头加 HISTORICAL banner（制式见 cascade §3.6），对齐两兄弟：`# ⚠️ HISTORICAL / v1-generic-frame-archived（2026-06-23 文档级联）/ 现行权威=…jsonl + paradigm；A2 后用 D-domain 生成器重派生；勿据此推进 surface`。同时 inventory 加 T1 阶段1 mark_historical 执行状态行（3 个中 2 已加 / 1 漏），与 T5 PENDING 标记同制，避免「verdict 写了但执行漏一个」无人追踪。 |
| P2-1 | P2 | **round-01/judge.md R1-Q07 grep 锚误列 `562` 为 stale anchor**。judge.md:23（R1-Q07）+ brain-3.md:29 把 `562` 与 `534具名工具` 并列为「范式翻案后旧锚…禁止批量替换」的 grep 目标，但 562 = 全仓**权威口径**非 stale anchor。SSOT 侧（final-grill-list Q07 / master §2:62 / AUD6 §5:233）已**正确排除 562**，且 master/paradigm 多处注「旧版误把 562 列为 grep 旧锚已纠 round-01」——但该纠正**未回流到 round-01/judge.md 本体**。round-01 是 T3 `no_change`（锦标赛历程存档），保留历史态可接受；但 R1-Q07=Q07 是**活待grill 题**（🔴待grill），若执行者直接拿 judge.md 的锚清单 grep 全仓会把 562（权威）标成过期点。 | `docs/grill-tournament/round-01/judge.md:23` + `docs/grill-tournament/round-01/brain-3.md:29` | round-01 作历史档可不改正文，但在 judge.md R1-Q07 行加一句边注「⚠️ 562 是终拍权威非 stale anchor，Q07 实际 grep 锚以 master §2 Q07 / final-grill-list Q07 为准（已排除 562）」；或在 master §5 Q07 落点显式声明「执行 Q07 grep 时禁用 round-01/judge.md 的锚清单（含 562 误列），以本表锚为准」。 |
| P2-2 | P2 | **inventory §1.1 口径 A/B 计数（87/153）无法本机独立复算坐实**。§1.1+§1.2 文档内大量自述「awk 复算坐实」「逐 Tier awk」「path-set ls/find 实测」，但这些复算是 inventory 自己叙述的，T5 path-set（75）尚 PENDING 未跑（§1.3:43）。计数本身对【决策审阅/完整性 check】是 load-bearing 数字（口径 A 决策用 / 口径 B 下游完整性用），却依赖「文档说我 awk 过了」而非现存可重跑产物。属 claim-vs-reality 铁律2（审计实跑 vs receipt）边缘——非阻塞（数字不驱动派单 / A2 口径靠 562），但 87/153 落地前应有可重跑 awk 命令固化（如 Makefile target 或 inventory 内联可粘贴命令 + 期望值），否则未来 grill 会把 87/153 当 SSOT 引用而无源。 | `docs/grill-tournament/cascade-inventory.md:16-20`（§1.1 87/153）| 把 §1.1 的 awk 复算命令内联成可粘贴一行（`awk -F'|' …` + 期望输出 87/153），或加进 `make verify` 的 verify-cross-section 扫描范围，使 87/153 成为可机械重算的 derived 数而非 prose 声称。T5 path-set 75 跑完后同步固化。 |

---

## summary

范式一致维度：**通过**。4 个 active 基线（CLAUDE §9 / SRD / MASTER / state-cells.yaml）+ 契约 + 4 个 change skeleton 全部正确翻案为 D-domain 具名工具 surface、canonical IR 仍 device×action、口径统一 562（534 系列仅在「全废」语境出现）。CLAUDE §9 :113 已是 562（非 stale 534）。代码（ToolContractCompiler 仍 tool_call_frame）与「skeleton DRAFT 待 propose / A2 未派单」状态自洽，**无 fake-progress 假迁移声称**。§2 grill 状态统计逐 Q 核对一致。Q07 grep 锚在 SSOT 侧正确排除权威 562。

可执行性维度：**基本通过**。4 个 skeleton 全 `openspec validate valid`，DRAFT 标记 + agree-before-build + 决策权威源 cite + spec delta（MODIFIED/ADDED SHALL + placeholder Scenario）合规，物理落点（依赖序 [1][4][5]+横切）清晰可派单。

**净问题**：1×P1（function-spec-full.yaml 漏 HISTORICAL banner — T1 mark_historical 部分执行 drift，inventory 无追踪，且漏的恰是最易被误当权威的 generated 全量 spec）+ 2×P2（round-01/judge.md 562 误列 stale 锚未回流纠正 / §1.1 87-153 计数缺可重跑固化）。无 P0：范式无 drift、口径无矛盾、skeleton 合规、无决策违背、无假迁移。P1-1 修复成本极低（补一个文件头 banner + inventory 加一行状态追踪），是本轮唯一实质 gap。

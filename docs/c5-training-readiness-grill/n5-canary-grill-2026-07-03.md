---
authority: n5_canary_grill_commander
status: open_items_G1-G8（G2 已当场处置，G4/G5 待磊哥或形态分析）
decision_ref: D-044/D-045/D-046
created: 2026-07-03 午
---

# N5 canary grill（commander 基于事实过 corner，不凭印象）

> 回顾的现有决策：wave-1 拍点包 1-7（`docs/c5-training-readiness-grill/wave1-owner-decision-package-2026-07-03.md`）、gate7 设计「§10.4 生成配比（D-096~125 locked，R7 BLOCKED 不现在跑）/§10.5 bug 失败模式→C6 层映射」（p5w 树 `MAformac-p5w-wave1-bridge/docs/c5-training-readiness-grill/gate7-cloud-generator-design.md` 行 446 起与行 450 起，本 session sed 亲核）、D-096/097 quota 公式 locked + 旧 3804 salvage 可救/verdict 作废重判（`docs/c5-training-readiness-grill/landing-matrix.md:69`）、refusal_ratio=0 锁值（D-042 裁决维持）、D-044/D-045。

| # | 级别 | corner / 风险 | 事实锚 | 处置 |
|---|---|---|---|---|
| G1 | 🔴 High | **执行基座未冻结**：拍点1 ⭐=「P12 merge 进 main 后 wave-1 pin 该 commit（dirty worktree 不可复跑）」——#27 尚未 merge。canary 现用 p5w #31 分支（含硬化门，比 main 严=可接受），但**正式扩 wave 生成必须等 merge 链完成后 pin main SHA 重跑门** | `wave1-owner-decision-package-2026-07-03.md` 拍点1；PR #27 live OPEN | canary receipt 显式记基座 SHA（`f163eedf`）；扩 wave 前置=merge 链+pin |
| G2 | 🔴 High（已处置） | **parent 语义错配**：sub-CC 以 N4A 行为模板但允许改 arguments 值 → `parent_semantic_id`/`case_id` 未同步换 → DataGate axis-overlap 用 parent id 关联，改值行可能语义错配 | `Core/Bench/C5DataGate.swift` candidate 结构含 parentSemanticID（FIX-PR29 报告）；生成 SPEC 原文允许改值 | ✅ 已 SendMessage 生成器：值优先不改+改值登记表；judge SPEC 加维度 9（未登记改值=FAIL） |
| G3 | 🟡 Med | **diversity 门被绕过**：手写生成不经 Gate7 pipeline，其 diversity 门（实证 reason=`diversity_length_distribution_too_narrow`，FIX-PR31 --limit 1 探针）不覆盖 canary 文件 | `FIX-PR31-f163eedf.md` Validation 表 Gate7 探针行 | %44 出轻量 diversity 检查（length 分布+n-gram 近重复）对 canary JSONL 跑 |
| G4 | 🟡 Med | **扩量架构未定**：canary 60 行 sub-CC 手写可行；拍点3 首波 4.5k（562×8）逐行手写不现实。批量 fan-out 形态（多 subagent×批 / 每批 N 行）、judge 抽样率（gate7 精度门本就是按 family 抽样停线：p5w `Gate7GeneratorPipeline.swift` 行 852 `shouldStopFamily(threshold: 0.8)`，本 session grep 亲核——拍点包写的「657-670」已过期顺此纠正）、与 quota 公式（locked，`docs/c5-training-readiness-grill/landing-matrix.md:69`）的接线全未定 | 拍点包第 3/5 行（`wave1-owner-decision-package-2026-07-03.md:16` 与 `:18`） | %45 形态分析（见派单），产出扩量方案供磊哥拍 |
| G5 | 🟡 Med | **拍点5 人工精度门别丢**：⭐default=磊哥本人按代码 sample size 抽检（family<0.8 停），或拍「首波跳过人工门」——D-045 只解了厂商实现，没解人工门 staffing | 拍点包拍点5 | 扩 wave 前上抛磊哥一次（与 G4 方案同包拍） |
| G6 | 🟢 Low | **C6 泄漏**：canary/扩量数据将来进训练集须过 C6 leakage 探针（proto build 有先例工具 `wave1-proto-c6-leakage-probe.json`）；canary 模板行已过探针、input_zh 新写话术按 case/axis 口径泄漏风险低 | `n4a-wave1-proto-build/` 同名探针文件（proto 版） | %44 确认探针工具可对 canary 复跑并跑一遍 |
| G7 | 🟢 Low | **judge rubric 的 Claude frame**：rubric 由 Claude 家 commander 写，OpenAI judge 可能被框 | codex-meta §31（cross-vendor≠cross-frame） | ✅ judge SPEC 已加「自主增维授权」；扩量时可 %43+%44 双 judge 抽样交叉 |
| G8 | 🟢 Low | **lineage 归档**：canary 三件套（生成 receipt/DataGate receipt/judge verdict）须归档；数据若最终进训练，必须在 pin 基座上重跑 DataGate（与 G1 同源） | C5DataGate lineage 纪律（P1-A V-PASS 先例） | 收 canary 时 commander 归档+记 D-046 |
| G9 | 🟢 Low | **salvage 路径别忘**：拍点4 ⭐=「旧 3,804/4,500 文本 salvage 参与但全量重过 vendor-enum judge + C5DataGate（旧 same-vendor judge verdict 作废）」——canary 不涉及，扩 wave 方案必须含此路径 | `docs/c5-training-readiness-grill/wave1-owner-decision-package-2026-07-03.md:17` + `docs/c5-training-readiness-grill/landing-matrix.md:69` | 并入 %45 扩量方案 |

## 元判断
canary 60 行本身风险可控（机械正确性由硬化 DataGate 兜底、质量由异源 judge 兜底、G2 已堵）；**真正的坑集中在 canary→4.5k 扩量的架构与治理**（G1 基座 / G4 形态 / G5 人工门 / G9 salvage）——扩量前须打包一次磊哥拍点，不自拍。

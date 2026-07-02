---
authority: grounded_grill_synthesis
artifact_kind: c5_grounded_grill_synthesis
paradigm: UIUE 215-grill 收口（汇总 + 消减表 + 评分表 + landing）
round: grounded（2026-07-01 经验发现驱动，续 332 grill）
r7_boundary: grill-only 写决策，不生成/不训练；真生成仍需 candidate signoff lift R7
created: 2026-07-01
status: net_carrier_locked_2026-07-01_magnet_all_agreed_D010
---

# grounded round grill — 收口综合（commander 总监综合）

> 本 session 真读前数据集 + 挖 bug 库 + 交叉审 catch 现场发现的经验决策，续 332 grill。commander（懂记忆的项目总监）综合 = 不只转发 4 份 worker 矩阵，而是【消减跨 worker 重复 + 承接已锁 + 抓净新载力 + landing 到 gate7/生成】。

## §0 交付总览

| 来源 | ID 段 | 决策数 | 维度 | 质量（commander review） |
|---|---|---:|---|---|
| W1 生成配比官（%44）| D-096~125 | 30 | 每族每类配比/旧3804复用/稀疏族场景触发 | ✅ 全 cite + 防惨败列 + grill-recall 承接 D-016/032/075~080/085~089 |
| W2 生成质量官（%43 codex fallback）| A-096~133 | 38 | vendor-enum异源/judge质量监控/diversity按实测/Q1-A落地 | ✅ 🔴 **自 python 复算旧 jsonl 印证假异源** + catch commander 派单 cite 错 |
| W3 语料映射官（%45）| E-096~130 | 35 | bug失败模式→C6层映射/gate7 scope/precision门 | ✅ cite 到 C6VehicleToolBench.swift 实际行号（读了码）|
| commander 纵切 | F-048~054 | 7 | 新惨败 mode→防线（claim-vs-reality 新变体）| ✅ commander 亲核 python/sqlite |
| **全集** | | **110** | | 全 status=proposed |

## §1 消减表（跨 worker overlap → merge，承接已锁 → 不重复计）

> 110 决策里相当部分是【跨 worker 重复】或【承接 332 已锁的确认】，消减后净新载力更集中。

| 消减组 | 涉及决策 | 处置 | 净 owner |
|---|---|---|---|
| **M1 vendor-enum 异源强制** | A-096~101（枚举/G1门/字段/unknown/receipt）+ E-120（judge on bug样本）| merge，A- 为 canonical 强制规则，E-120 是其应用 | **A-096/097**（质量线）|
| M2 diversity 族内 coverage 门 | D-118 + A-115/A-120 | merge（承接 gate7 §4.1 + D-078）| A-120 |
| M3 GPT-5.5 纯异源 judge 落地 | D-110 + A-105/107 | **承接已锁 D-008 Q1-A**，非新决策=落地细则（⚠️审计 P2：A-110 剔出，它是 judge 分歧监控归 §2 A-110~112）| A-105（排班）|
| 🔴 M4 旧 3804 复用（审计 P1：D-103 vs A-131 表面冲突→分层 reconcile）| D-103/119/120 + A-131 | **reconcile**：旧 utterance **TEXT 可作 recovery candidate**（D-103 逐条重过 gate），但旧 hermes judge **verdict 作废**（A-131：假异源 100% same-vendor 不可信）→ 全部**重过新 vendor-enum 异源 judge**，不吃旧 verdict | 分层不互斥（TEXT salvage / VERDICT void）|
| M5 per-seed cap/floor | D-109 + A-118/119 | merge（承接 D-075）+ A-118 新增 variant **floor**（≥2）net 新 | A-118 floor 是净新 |
| M6 「12000」口径 | E-123 + F-051 | merge（都修正 event≠distinct bug 4053）| E-123 写法 + F-051 防线原则 |
| M7 gate7 scope（别背 0/34）| A-126 + E-117 + F-049 | merge（承接 D-008）| E-117（eval边界）|
| M8 value-form 覆盖 | D-115 + A-116 + E-107 | merge（承接 D-079）| A-116 |
| M9 稀疏族 scene-trigger | D-098/099/100 + E-113/114 | merge（D- quota 地板 / E- eval 侧）| D-099 + E-113 互补 |
| M10 bug→sample class | D-097/108/113/114 + E-100~115 | 互补非重复（D- 定 quota / E- 定 class→C6 层映射）| 各留 |

🔴 **消减后净新载力 ≈ 60-70**（其余是承接确认/跨 worker 重复）。真正**本 session 独有的净新决策**集中在下 §2。

## §2 评分表（净新载力 top，⭐ 全 A，commander 判分辅助磊哥拍）

| 决策 | 议题 | 净新点 | 防0/34 | 工程量 | 端侧 | 总评 | commander 备注 |
|---|---|---|:-:|:-:|:-:|:-:|---|
| **A-096/097** | vendor-enum 异源强制 + G1 门 | 顶层 vendor 枚举 + `judge_vendor≠generator_vendor` code/receipt enforce | 5 | 4 | 5 | **⭐⭐** | 🔴 直修假异源惨败（前一次 100% same hermes）；最高优先 |
| **D-096/097** | 生成 quota 主轴 + bug 不线性放大 positive | intent基线+bug压力+地板混合公式；bug多≠多训 positive（屏幕黑屏≠调亮度）| 5 | 3 | 5 | **⭐⭐** | 🔴 防系统故障训成车控动作 |
| **E-098/129** | WS2 shortlist precision 门 | 每族 min(50,max(20,10%)) 人审，precision<0.8 停该族；关键词非 gold | 5 | 3 | 5 | **⭐⭐** | 🔴 防播报/黑屏假阳性污染训练+eval |
| **E-100/124** | 执行失败809 不入 action train | 只转 failure receipt/C6 trap，默认不进 action train | 5 | 3 | 5 | **⭐⭐** | 🔴 防故障语料污染 action 边界 |
| **D-098/099 + E-113** | 稀疏族地板 + scene-trigger | 雨刮12/天窗34 不因 bug 少砍，靠「下雨了」场景触发 | 4 | 3 | 5 | **⭐** | 数据分布≠需求分布（F-054 同源）|
| **E-115** | bug→C6 层默认矩阵 | positive→golden/demo_fuzz / clarify→demo_fuzz / unsupported→unsupported / safety→safety / failure→trap | 5 | 3 | 5 | **⭐** | 承接四层 fail-closed（gate6）|
| **A-110~112** | judge 质量监控 | 分歧率/reject axis 分布进 receipt + 阈值告警 | 4 | 3 | 4 | **⭐** | 防 judge 自身失守（E2 elephant）|
| **A-118/122** | diversity 实测校准 | per-seed variant floor≥2；mean 9.3 只作红灯不当固定阈值 | 4 | 3 | 4 | **⭐** | 修多样性薄（373 seed 单变体）|
| **D-102/117** | followup 屏幕/音量补 | scene-derived followup 标 `source=bug_scene_derived` 不伪造 transition lineage | 4 | 2 | 4 | **⭐** | 防 lineage 谎言致 held-out 失效 |
| **E-096/121** | bug 候选默认 quarantine | 弱监督 shortlist 默认 quarantine，过 precision+redaction+label-gold 才候选 | 5 | 2 | 5 | **⭐** | 防 keyword 当 gold |
| **F-048~054** | 新惨败防线 | claim-vs-reality 5 新变体 + API-fallback + cross-audit + 稀疏≠不需要 | 5 | 4 | 5 | **⭐** | 元层防线 |

## §3 landing（喂 gate7 design + 未来生成，actionable）

- **喂 gate7 design（可回写 gate7 doc / 后续 spec）**：A-096/097 vendor-enum G1 门 → gate7 §3.2 落实；E-098/129 precision 门 → gate7 §4 加 bug-derived precision gate；E-128 source tags（`source=bug_derived_pattern/raw_text_absent`）→ gate7 S2/S5 字段；D-125 receipt 加 `quota_source=intent|bug|scene|recovery`。
- **喂未来生成配比（R7 BLOCKED，真生成时用）**：D-096~125 每族每类 quota 公式 + E-100~130 bug→class→C6 层映射 + D-103 旧 3804 回收池策略。
- **喂 C6 eval**：E-115 bug→四层映射 / E-102~103 multi-intent trap / E-124 failure receipt。

## §4 缺口 + R7 + 下一步

- **待磊哥拍板 locked**：净新载力 ⭐（§2）拍 → locked 落 landing-matrix + 回写 gate7 design 对应节。
- 🔴 **R7 守着**：本轮 grill-only 写决策，**真生成/真训练仍 BLOCKED**（需 candidate signoff + run auth）。gate7 别背 0/34 锅（E-117/F-049）。
- **审计**：本 SYNTHESIS + 4 worker 矩阵 → subagent CC（API 恢复时）或 codex 交叉审（磊哥「三者等效」）→ 磊哥拍。
- **消减/评分待精修**：§1 消减是 commander 初判，正式 locked 前可再细拆 net 净决策数。

---
authority: grill_landing_matrix
artifact_kind: c5_grill_landing_matrix
paradigm: grill-baseline-skeleton-upfront（决策→spec→code gate→物理就绪 跟踪）
created: 2026-07-01
status: pre_human_signoff
---

# C5 grill landing matrix（训练前节点落地跟踪）

> 🔴 直接回答 magnet goal「推进到 C5 可开始 LoRA 训练前节点」=**把下表 8 道 gate + 2 裁决门从 ❌/⚠️ 推到 ✅ 物理就绪**（守 R7：到节点为止，candidate signoff + run auth 是磊哥的最后一拍）。gate 现状 cite `SYNTHESIS-LORA.md §三`（audit 第一轮逐道核）+ `R7-final-route-deframing-signoff.md`。grill 每拍一条 locked 同步填格（不攒）。

## §1 8 gate + 裁决门 × 落地态 × 现状

| # | gate / 裁决门 | grill 决策 | → spec(openspec) | → code gate | → 物理就绪验证 | 现状 |
|---|---|---|---|---|---|---|
| 1 | 训练循环真跑（非 stock 冒充）| A-031 / F-024 | — | `trainingLoopVerifiedForFormalTraining` `Core/Training/C5LoRATraining.swift:502/2281` | 本机完整实跑证据 | ⚠️ 待确认 |
| 2 | masking 三形态实装 enforce | A-016~018 / D-025 / F-021 | — | maskingStage coverage | function/argName/argValue 从统计变 enforce | ⚠️ 可能仍 dry_run |
| 3 | surface-source preflight ≥80% | E-020 / **F-010** | — | exit65 四方同源 | <80% 阻断 | ✅ 已立（θ-α 后）|
| 4 | scale-authority=工厂20 | A-002 / F-(scale) | — | 工厂 `rank16Mainline:1261` | 防 config32 污染 | ✅ 已 enforce |
| 5 | 多轴 held-out（六轴）| **D-016** | — | `C5DataGate.swift` splitter | device/tool/value/template/generator_source 硬切 | ❌ 当前只 parent 级 |
| 6 | C6 四层阈值化 fail-closed | **E-002~006** | **`rebuild-c6-four-layer-bench`**（R-L17 已解锁 construction §1/§2/§3）| C6 status `:1423` 固定 construction_report | 四层各阈值 fail-closed | ❌ 当前只统计 |
| 7 | 云多源 generator+异源 judge | **D-031~037** | — | generator 编排 | 多源+异源judge+diversity 代码闭环 | ❌ research 锁方向代码未闭环 |
| 8 | A2 D-domain codegen 落地 | D-005 / E-026 / **F-046**(工具数收口) | `migrate-d-domain-tool-surface` | ToolContractCompiler 单源 | 工具数 value-form 实算 | ⚠️ A2 已合 main，工具数 [TBD] 待实算 |
| 裁决-A | **G6-C/D-fix tiny ablation**（范式真解决?）| **F-044** | — | — | empty 28/34→<5/34 + stepwise ablation | ❌ 必过才声称范式修复成功 |
| 裁决-B | positive-not-diluted+OOD invariant | **F-043** | — | C6 action 轴独立 fail-closed | positive 不被 negative/readback 稀释 | ❌ 待实装 |
| R-L17 | candidate signoff（人审解锁训练）| **F-045** | — | R7 `route_only_signed`→candidate | C6 construction 完成+signed candidate+run auth+human signoff | 🔓 route-only signed / candidate ❌ blocked |

## §2 训练前节点 = 上表全 ✅ 的依赖序

```
R-L17 route-only signed ✅(2026-06-25 磊哥签)
  └→ gate 6 rebuild-C6 four-layer construction（已解锁，先做）❌
       └→ gate 5/7/8 数据侧 gate（多轴held-out/云generator/codegen）❌⚠️
            └→ gate 1/2 训练侧（循环真跑/masking）⚠️
                 └→ 裁决-A/B（tiny ablation + positive-not-diluted）❌
                      └→ 【C5 可训练前节点 = 万事俱备】
                           └→ 磊哥最后一拍：candidate signoff + run auth → 真训练（守 R7，本 grill 不越此线）
```

## §3 当前缺口汇总（到节点还差）

| 现状 | gate/裁决 | 数 |
|---|---|---:|
| ✅ 已就绪 | gate 3 preflight / gate 4 scale-authority | 2 |
| ⚠️ 待确认 | gate 1 训练循环 / gate 2 masking / gate 8 工具数实算 | 3 |
| ❌ 未实装 | gate 5 多轴held-out / gate 6 四层阈值化 / gate 7 云generator / 裁决-A tiny ablation / 裁决-B positive-not-diluted | 5 |
| 🔓 人审解锁 | R-L17 candidate signoff（磊哥最后一拍）| 1 |

🔴 **到训练前节点 = 补 5 个 ❌ + 确认 3 个 ⚠️**（gate 6 rebuild-C6 已被 R-L17 解锁可先做）。这是人审拍 grill 决策后的实装清单。

## §4 维护

grill 决策人审拍 locked → 对应 gate 填「→ spec / → code gate」列；实装完成 → 现状改 ✅。每里程碑回写（derived-tracking 纪律）。

### 2026-07-01 里程碑（D-007 lock + 5 gate construction → 3 PR）
- **决策 lock**（D-007，磊哥「都按推荐来」）：5 gate ⭐ 组 locked（E-002~006 / F-043 / D-016 / F-044 / D-031~037）。
- **5 gate construction 收口 = 3 PR 上抛磊哥 merge**（守 R7 construction/design-only）：
  - **PR #9** gate5 六轴 held-out + 裁决-A（%45/g5，codex 交叉审 ACCEPT，swift test 12+3 绿）
  - **PR #10** gate6 四层阈值化 + 裁决-B（%44/g6，交叉审抓 P0 假绿分母→修→复核 CLEAR，75 绿）
  - **PR #11** gate7 云 generator design（Opus subagent，反思前数据集挖假异源，python 亲核 CLEAR）
- **现状轴**：decisions locked ✅；gate5/6/7 = **审绿 + commit + PR ✅**（待磊哥 merge = apply gate，commander 不 merge）；🔴 retrain-c5 真训练/真生成仍 R7 BLOCKED。

### 2026-07-01 里程碑2（grounded grill round + D-010 lock）
- **grounded round**（D-009/D-010）：本 session 经验发现驱动 **110 新决策**（W1 配比 D-096~125 / W2 质量 A-096~133[%43 codex fallback] / W3 语料 E-096~130 / commander F-048~054）；commander 总监综合 `SYNTHESIS-grounded-round.md`（消减 10 组→净~60-70 + 评分 + landing）；codex 交叉审 **CLEAR_WITH_FIXES**。
- **净新载力 ⭐ locked**（D-010，磊哥「全部同意」）：A-096/097 vendor-enum 异源强制 / D-096/097 quota 公式 / E-098/129 precision 门 / E-100/124 执行失败不入 action train / D-098+E-113 稀疏族 scene-trigger / A-110~112 judge 监控 / F-048~054 防线 + M4 reconcile（旧 3804 TEXT 可救/hermes verdict 作废重判）。
- **回写 gate7 design §10 landing**（PR #11 更新 commit `194dcf9e`）：vendor-enum G1 门 + precision 门 + source tags + 配比 + bug→C6 映射 + 旧 3804 复用。
- 🔴 R7 守着：grounded lock 的是 **grill 决策 + design 回写**，真生成/真训练仍 BLOCKED（candidate signoff 才 lift）。

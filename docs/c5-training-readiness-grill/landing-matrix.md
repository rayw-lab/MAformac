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

## §3 当前缺口汇总（🔴 2026-07-02 wave-1 后 reconcile — supersede 上方 §1 表旧「❌」态）

> git 一手 + wave-1 自跑坐实：上方 §1 表标 gate5/6/裁决A/B 为 ❌ 是 **stale**（derived-tracking 漏回写 D-011 merge）——实际已 merge main。commander-log D-012/D-013。

| 现状 | gate/裁决 | 依据 |
|---|---|---|
| ✅ construction 就绪 | gate3 preflight / gate4 scale / **gate5 六轴held-out**(main `aa1adf8f`) / **gate6 四层阈值化**(main `696676ba`) / **gate8 工具数=562**(wave1 %44 `64c6f62f`,自跑绿) / **裁决-A harness**(main,R7-guarded dry-run) / **裁决-B positive-not-diluted**(main `696676ba`) |
| ✅ **P0 fix 异源 CONFIRMED（fix commit `47ca8cda`）** | **gate2 masking**——原 P0 假enforce（D-014）**已消解，异源 re-audit T-FIX-CONFIRMED / 0 P0**（`AUDIT-fix-reaudit.md`）：训练 train/eval 在 `--require-maformac-loss-mask` 下**真走** `maformac_masked_loss`+`maformac_iterate_batches`（非 stock `default_loss`，`--mask-prompt` 已删），token-level -100 真进 cross-entropy；char→token 用 offset_mapping overlap 真做；循环失守转真 loss 数学门（self-test `masked=0.00067 vs unmasked=2.667`，commander+re-audit 双自跑）。**未真消费的层=无**。🔴 **残留 P1（R7-gated）**：真 Qwen/MLX batch offset 精度 dump 等磊哥 run-auth——但 **fail-closed（char→token 失败 exit66，不会静默退化成无 mask）= 正确性残留非 enforce 残留**。P2：vestigial offset artifact 待 R7 清理 |
| ⚠️ 部分/边界 | gate1 训练循环(机制建 `:513` gate formal training,真跑 verify=R7 边界) / gate7 云generator(design merged `db9f490f`,代码未闭环,真跑=R7) |
| 🔴 R7-blocked 真跑(等磊哥 run auth) | 裁决-A tiny ablation RUN / gate1 真跑 / gate7 真生成 / C6 真评测 / candidate |
| 🔓 人审解锁 | R-L17 candidate signoff(磊哥最后一拍) |

🔴 **iceberg 坐实 + wave-1 audit 修正**：gate3/4/5/6/8 + 裁决A/B construction ✅（对抗审计 CLEAR）；🔴 **gate2 P0 假enforce 修复中**（masking=disaster-core 本要防 θ-α，对抗审计抓到假绿，修复是 pre-LoRA 关键——**这次 catch 正是 pre-LoRA push 的价值：训练前拦下 θ-α round 2**）。真实剩余缺口 = ① **gate2 P0 修复**（char→token + mlx-lm 真消费 + F-068 真验证门，real-model proof R7-gated）② **E-2 设计决策**（562 工具 surface ≈74-99k tokens 超 Qwen3-1.7B context，必 subset/constrained-decoding，磊哥定策略）③ grill 维度10/11/5 补深已做(wave-1)待磊哥 lock ④ R7-blocked 真跑全等磊哥 candidate signoff。**gate2 修复 + 磊哥 4 决策 = 到训练前节点。**

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

### 2026-07-02 里程碑3（D-017 磊哥授权 ABCDE：①②③⑤ locked + M1 consolidation 执行）
- **决策 lock**（磊哥「ABCDE都要做哦 我授权了」）：**① masking 岔口 = 全 token-mask override locked**（`47ca8cda` 双异源 CONFIRMED + D-015 接棒复审）；**② E-2 subset 方向 locked**（真 Qwen3-1.7B tokenizer 实测：562 工具目录 compact=126,275 / default=159,899 tokens 超 131,072 上限 → subset 数学必然；实装形态待 E-2 design 包细拍）；**③ grill Dim10/11/5 共 58 条 locked**（F-076~095 + F-055~075 + A-134~150；Dim10 frontmatter 已改，Dim11/5 随 M1-γ port 改）；**⑤ wave-1 consolidation 授权执行**（M1 staged PR α g2→β g8→γ 文档整编支）。
- 🔴 **仍 BLOCKED（授权不含）**：④ 裁决-A tiny-ablation RUN / gate1 真跑 / 真生成 / C6 真评测 = 等磊哥单独 run-auth；M2 树清理 = 未授权。
- gate 态变化：gate2/gate8 从「分支待 consolidation」→「M1 PR 流程中」。

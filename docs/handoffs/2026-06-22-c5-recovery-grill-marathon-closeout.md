# Handoff — C5 Recovery Grill Marathon 收口（2026-06-22）

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

> 🔴 **第二个窗口起手必读**。本 session = CC（我）+ 磊哥「助理」（另一个异源 AI）**双向 grill** C5 recovery,~15 轮密集。**CC/助理共犯 9 次同坑变体（全被异源 catch）**。本 handoff 第一价值 = **防你重犯这 9 个坑**;第二价值 = **别重 grill 已拍的 15 个决策**;第三 = **所有数字用 cite-verify 一手,别凭二手/印象**。
>
> **磊哥**:称呼磊哥;中文;选择题打字列选项 + ⭐默认不用弹窗;grill 期只动 `grill-decisions.md` + 元认知 rules,顶层文件收口批量级联(路由 banner 例外可随时打)。

---

## 件套 1 — 一句话状态 + 起手必读路径（防孤岛）

**状态**:PR5 通宵 wave candidate **`0/34` 已 UNSIGNED/BLOCKED**(重大失误,8D 复盘);**C5 recovery in-grill**,evaluation 口径已 grill 透,**下一步 = θ-train(G22-G26)**。candidate 永久报废不抢救。

**起手必读序**(已用 CLAUDE.md §9 banner 挡孤岛):
1. `CLAUDE.md §9`(已加 P0 banner 指向下面)
2. **⭐`docs/c5-recovery-2026-06-22/grill-decisions.md`(336 行,recovery 唯一权威事实源)** — Q1→θ-data 15 决策段
3. **本 handoff**(防坑导读)
4. `docs/c5-recovery-2026-06-22/{roadmap,exec-plan,8d-rootcause}.md`(已 P0/P1 级联,但 Phase C 完整级联未做,见件套 5)

**🔴 唯一权威 = grill-decisions.md**。任何数字/口径与其它文件冲突,以 grill-decisions 为准(其它文件旧段保留作演进痕迹)。

---

## 件套 2 — 🔴🔴 防重犯铁律:9 次同坑变体（每次都被异源 catch,你必内化成反射）

**共同根源 = 「派生表征当一手事实」**。已全部沉淀进 `~/.claude/rules/claim-vs-reality-gap.md` 铁律3(八实证 + 第9元层变体)。逐条:

| # | 症状(凭什么推) | 真相(下钻到哪一手) | 教训反射 |
|---|---|---|---|
| 1 | 凭 receipt 推范式,没看代码 | base/lora 吃同一 prompt,范式推不出 | 诊断必看生成代码 |
| 2 | 凭 `irrel_acc` 推 collapse 机理,没算样本分布 | 28 empty/4 wrapper/2 NO_TOOL | 机理必算样本级 |
| 3 | 凭顶层 `positive_hits=25` 当 recovery 锚 | 没下钻 `diagnostics.axes` | 锚点必下钻 axis |
| 4 | 凭整体 `all_c6_release base 7` 当 positive 阈值 | 整体 7 全是 negative/ood 撑,positive=0 | **阈值前按最细 axis 打印 base/lora,禁引整体单数** |
| 5 | 「亲核了 diagnostics.axes」以为到一手 | 那是 **receipt 手 rolled axes(二手,仓库无 .py/.swift 产生器)**,真一手=`c6-summary.json:eval_runs[].gate_result` 字段级 | **cite-verify 分层级:核 receipt axes ≠ 核 gate_result/代码产生器;引分轴数字前先 grep 产生器** |
| 6 | 拆 axis 分母按 `case_id` prefix(`C6-MP`=30) | 按 case schema 字段(`expect_no_call`/`pre==delta`)拆,真分母 23(refusal 4+noop 3 污染) | **拆 axis 必按 schema 字段不按 naming** |
| 7a | 凭函数名同推语义同(「换 goldReplayOutputText」) | 它纯渲染不读 output.text,换=readback 恒 true 伪装在测 | 改架构修法前核函数实际行为 |
| 7b | 凭代码模式同推产品语义同(readback/clarify 都吃 output.text→都走 P) | readback=状态播报(端 renderer 走 P)/ clarify=安全拒识澄清(模型职责保留),**误剔阉割 demo 安全门** | **走 P 判据 = 端确定性生成 vs 模型智能决策,不是吃不吃 output.text** |
| 8 | 凭印象给数字(NEG=9 / rejected「10」/ K=base+3) | jsonl 实=8 / 实 22 / +3 无依据。**助理认了第8坑、同消息又复发** | **任何分母/计数/枚举当场 cite-verify;认知到≠行为改,扳机在写每个数字时** |
| 9 | 多轮 grill 后没 cross-section check(append-only log 当 SSOT) | R5 `11/30` 与 A0/δ/ζ `10/23` 并存自我分叉 | **每拍重大反转决策或每~5段,做 cross-section consistency check;旧段标 SUPERSEDED + 边注** |

**元反射**:写任何「数字/定性/锚点/X等价于Y」前停一下问「这是一手 gate_result/代码行/jsonl 字段,还是 receipt/聚合/印象/命名/函数名 的派生?」。**异源 catch 是救命的——CC 和助理都反复犯,靠对方 cite-verify 一手才发现。别信任何转述(含对方"亲核了")。**

---

## 件套 3 — 已拍决策清单 Q1→θ-data（15 段,别重 grill,physical landing 在 grill-decisions）

| 段 | 决策一句话 | physical landing |
|---|---|---|
| **Q1** route-boundaries | route 边界 7 维 Compiler 派生不手标 | RouteDeriverV2 |
| **Q2** safety-overlay | safety 从 risk-policy.yaml overlay,不回填 C1 risk | risk-policy.yaml |
| **BG1** demo-golden-run-anchor | demo 锚点;**demo 全部延后**,recovery 聚焦能力层大而全 LoRA | demo-golden-run.v1.yaml(延后) |
| **BG3** 两层 SSOT | 能力层 `semantic-function-contract.jsonl`(3990)⊃ 演示层 demo-golden-run | 两层 scope |
| **A0** C6-true-scoring | C6 真口径=`model_action_hard_pass`(tcm+required_args+state_delta);name-only 降 smoke;**readback 轴 RESOLVED-VIA-ε** | 三轴真相段 |
| **A1** tiny-surface-ablation | D/B tiny 对照,唯一变量 surface_variant;**范式据实验拍不凭 0/34** | tiny-surface-ablation.v1.yaml |
| **D1** route-deriver-v2 | 拍 A+(建 RouteDeriverV2,inputs **去 exec_tier**,加 value.type);拒 B | 14 callsite + train.jsonl 4464 regen |
| **D2** make-verify-gate | 仓库无 CI,「门」全落 `make verify`(Makefile),新 check 进 test target | Makefile test target |
| **G5-G9** data-contract-fix | 真删工具(非 metadata 假删)+ label 门(实际 prompt 文本 grouping)+ name-first + 占位符门 | C5LoRATraining buildNoCallSamples |
| **α** compiler-scaffold | 下一执行入口=ToolContractCompiler scaffold(派生 D/B surface + applier/normalizer) | generated/ + Makefile regen |
| **axes-catch** | 🔴 推翻二手 axes:action 轴 base **10/23**(非整体 7/57);第5/6坑 | A0 三轴真相 |
| **ε** readback-architecture-**P** | 磊哥拍**方案 P**(单发 FC + 端 renderer 出话术 + UI 卡片 + TTS);**RAW vault 5 证据**;readback 走 P/clarify 保留 | 删 eval `:1039`,readback 单列 gate 形态B |
| **δ** axis-producer-spec | `scripts/build_axes_from_summary.py`(schema 拆 6 axis + 两口径);**clarify 全保留计 hard_pass**;7 case 拆 1判等+6capability | NOT-Implemented,codex 收口实装 |
| **ζ** E4-threshold | **相对门锁**:`lora.mp_positive_action > base 10/23` + no_regression + wrapper_drift=0;绝对门待 demo scope;**拒凭印象单一 K** | lora-success-thresholds.yaml |
| **θ-data** | C5 数据配方:7题 + 7case×θd 映射矩阵 + **positive-not-diluted invariant** + θd-7 OOD 探针 | data-recipe.yaml(NOT-Implemented) |

---

## 件套 4 — 一手数据 ground-truth（**全部 cite-verify 过,你引用前再核但别推翻凭印象**）

**C6 三轴真相**(下钻 `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5c-c6-{base,lora}-full-summary/c6-summary.json:eval_runs[].gate_result`):
- axis 按 case schema 字段拆,**57 = MP 30 + COV 7 + NEG 8 + TRAP 12**;MP 30 = `mp_positive_action` 23(`expect_no_call=F AND pre≠delta`)+ `mp_refusal` 4(enc=T)+ `mp_noop` 3(pre==delta,如 005「关空调」pre `ac.power=off`)。
- **action 轴(tcm&sdm)**:base **10/23**(43%,剔 readback 后净 pass)/ lora **0/23**(全面塌缩,那 4 个 tcm&sdm 全落 refusal=吐空碰巧对)。→ **模型有 args/state 能力,LoRA 塌缩=数据契约错=单线修复,recovery 锚 base 10/23**。
- **readback 轴(话术)**:base **0**(单发 FC `chunkText=""` 不吐话术)→ 走方案 P(renderer)。
- **整体 hard_pass**:base 0/23、lora 0/23(positive);`all_c6_release` 7/15 是**整体含 readback+negative**,别当 positive 锚。

**7 demo-critical case**(base/lora 都 **0/7** = recovery 真硬骨头,亲核 spike-e3-results.json chunkText/toolCalls):
- **1 判等过严**:`SAFE-001`「高速开门」base 话术对(「无法...静止状态」)缺 token → ι 同义词表放宽。
- **6 capability gap(放宽判等救不了,要训)**:`MP-024/025/026`「开门/后备箱」→错调 `set_cabin_window`(工具映射);`SAFE-002`→没识别行驶中错调 window;`ASR-001`「座椅通分」→没澄清直接执行;`ASR-002`「空跳开一哈」→吐∅。

**代码行号**(`Core/Bench/C6VehicleToolBench.swift`,亲核):
- `:1039` eval path `failures.append(.readback)` = **方案P要删这行**(readback 不计 hardFailed)。
- `:865` gold path 同名 append = **不改**(gold 自检需要)。
- `:1012-1016` eval readback 吃 `output.text`(模型话术)。`:1120 clarifyGateMatches`(rejected/ambiguous 吃 output.text)。`:1297 goldReplayOutputText`(纯渲染不读 output.text)。`:1413 looksLikeMachineReadback`(反机器话术,强制模型说自然语言)。

**readback vs clarify 分流(产品语义,不是代码特征)**:
- readback(执行成功状态播报「空调已开」)= 端 renderer = **走 P 剔除**。
- clarify(拒识「行驶中不能开」/澄清「没听清」)= 模型职责 = **全保留计 hard_pass**(demo 安全门/听懂核心)。
- RAW vault 证据(只读 `~/workspace/raw/01-Wiki/`,不入仓):证据1 FC手册:248 `Car-->>U 播报`(P)+ 兜底 `FC-->>U`(模型);证据5 V1.0:131「可追责非炫耀」反 Q。CC 辩证:证据3 TTS 体系**过度引申**(归一化 P/Q 都需要)。

---

## 件套 5 — 未完成 + 下一步（剩余 grill + Phase C 收口 gap）

**剩余 grill ~15-18 题 / 5 模块**(对照 `grill-checklist-30.md`,头部进度已过时以 grill-decisions 为准):
- **θ-train G22-G26**(下一题):action 加权 / scale(守20) / tiny 前置 / collapse 预警 / masking 三形态
- **审计框架 G27-G29** + 审计模板(OPEN-POINTS 待产 `audit-template.md`)
- **真机 G30-G32**(G30 真机采购阻塞 endpoint V-PASS,别等)
- **Compiler 细节 G15(Swift/Python)/G16(版本 diff)**
- **demo scope κ**:demo-golden-run 解冻定 ζ 绝对门
- **范式结论 G6**:据 tiny 对照实验拍(等实验,**不凭 0/34**)

**🔴 Phase C 收口级联 gap**(grill 全收口后批量做,§35 基线文档组级联;P0/P1 已做):
- `exec-plan.md` v4→**v5 级联段**(补 ε/axes-catch/δ/ζ/readback-clarify)
- `8d-rootcause.md` D7 段补新决策
- `openspec/specs/vehicle-tool-bench/` C6 spec readback 口径(**待核**:助理 grep 看似没写 hard_pass,可能不用改)
- `roadmap-2026-06-20-from-c6-done.md :115 P0-1` readback 口径
- **CC memory 指针**(`~/.claude/projects/-Users-wanglei-workspace-MAformac/memory/MEMORY.md`,**不在 repo**,收口更新)
- ⛔ 助理曾误把 `MEMORY.md` 当 repo 文件 + 写错 `roadmap-2026-06-20` 文件名(全名带 `-from-c6-done`),已撤销别再引

**实装(全在 NOT-Implemented,grill 收口后 codex 长跑)**:ToolContractCompiler scaffold(α,先)→ δ axis producer → 数据配方 θ-data → tiny 对照 A1 → full 训练。

---

## 件套 6 — 协作上下文 + git 状态 + 下次第一步

**协作模式**:CC(综合/前端/契约)+ 磊哥「助理」(异源 AI,反方/深挖)双向 grill。**助理强**(去 RAW vault 探一手工程料 + 行号亲核 + 一致性自检)**但反复凭印象给数字**(第8坑 NEG=9/10/+3 三次复发)。**纪律:互相 cite-verify 一手,不迎合(磊哥反复强调「不要一味顺着」「辩证 check」)**。codex=本地长跑实装;hermes=跨厂商 critic;GPT Pro=heavy producer。

**git**:`main` 分支,HEAD `c4a7d1a`(0/34 blocked wave)。**未 commit**:`docs/c5-recovery-2026-06-22/`(grill 全档,未跟踪)+ 本 handoff + Reports/(训练产物)+ M:AGENTS/CLAUDE/INDEX。磊哥未要求 commit,别擅自 commit/push。

**元认知 rules 已更新**(本 session 沉淀):`~/.claude/rules/claim-vs-reality-gap.md`(铁律3 八实证 + 第9元层 + 元规则九变体 + 去基座工程料探查)。

**🔴 下次 session 第一步**(可直接复制):
```
读 CLAUDE.md §9 banner → docs/c5-recovery-2026-06-22/grill-decisions.md(15段) →
本 handoff 件套2(9次同坑,内化成反射) + 件套4(一手 ground-truth)。
然后继续 grill θ-train(G22-G26 训练配方):action加权/scale守20/tiny前置/collapse预警/masking三形态。
纪律:① 任何数字当场 cite-verify gate_result/jsonl/代码行,禁凭印象/二手 ② 拆axis按schema字段 ③ 走P判据=端确定性vs模型智能 ④ 不迎合助理,辩证check ⑤ 每~5段做cross-section一致性check。
recovery 锚 = lora.mp_positive_action > base 10/23(相对门已锁)。范式据实验不凭0/34。
```

**Session Closure 自检**:Learn-Eval 跳过(纯 grill/文档无代码变更);知识文件已更新(grill-decisions 15段 + 4处gap级联 + claim-vs-reality 9实证);Handoff=本文件;CHANGELOG 不适用(非 ~/workspace 操作);下次 prompt 见上。

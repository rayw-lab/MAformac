---
authority: grill_decision_matrix_dim10_deepen
artifact_kind: c5_grill_commander_dim10_gate_r_l17_deepen
paradigm: UIUE 215-grill 决策矩阵（7 列 + 防惨败列 cite P1-P9）
dimension: 10（gate 体系 + R-L17）
id_range: F-076~F-095
round: overnight-deepen（2026-07-02，D-012 承接）
status: locked_by_magnet_2026-07-02（D-017「ABCDE都要做 我授权了」，F-076~095 全 20 条 proposed→locked）
r7_boundary: grill-only 写决策，不训练/不生成/不评测；真跑等 candidate signoff
created: 2026-07-02
---

# 维度10 补深 — gate 体系 failure-branch + R-L17 candidate signoff 操作手册（commander 纵切）

> 🔴 grill-gaps 盘点：维度10 原仅 **10 条**（F-026~033+045+046），每 gate 只 happy-path，缺「gate 失败时磊哥怎么决策」全支路 + R-L17 candidate signoff 操作面。本文补 **F-076~F-095**（20 条），承接已锁 D-003/D-007/R7-signoff，不重复。
> **承接不重复**：8 gate 定义 = `landing-matrix §1`；R-L17 边界 = `R7-final-route-deframing-signoff.md`；已锁裁决门 F-043/F-044 = D-007。本文只补 **failure-branch 决策 + ops 手册**。
>
> 🔴 **引用基准（cite-verify）**：本文写于 doc-absorption 分支 worktree（**落后 main=ab355f6c**）。① 代码 `file:line`（`C5LoRATraining.swift:513/:1026` 等）引用 **vs main=ab355f6c**（已 `git grep main` 核，本地 grep file_missing 系分叉产物非错引，落 main 后正确）；② 数字 `0/34`/`10/23`/`28/34` 承接已锁 SSOT（`README §1` 双仓惨败表 / c5-recovery action 锚 base 10/23 / F-044 裁决门 empty 28/34→<5/34）；③ arxiv `2606.01080` 系 push-premortem cite，**magnet lock 前需独立 WebSearch 核真**（未核不作一手，%43 grill 正在核 arxiv 全集）。

## §1 每 gate 的 failure-branch 决策（F-076~F-088）— 「gate 红了磊哥怎么办」

| ID | 议题 | 选项 A/B/C | ⭐推荐 | 论据(file:line) | 状态 | 🔴防惨败(cite PCA) |
|---|---|---|---|---|---|---|
| **F-076** | gate1 训练循环真跑 FAIL 分诊 | A 分「配方问题（loss NaN/发散）vs 环境问题（mlx-lm 版本/内存/tokenizer patch）」两支，先查环境后判配方 / B 一律归配方重训 / C 归环境重装 | **A** | `C5LoRATraining.swift:513` trainingLoopVerifiedForFormalTraining；θ-α loss 健康行为塌=配方，NaN=环境 | proposed | 防 θ-α「凭 loss 曲线推健康」——真跑 fail 必下钻是数值发散(环境)还是行为不收敛(配方)，cite P8「train==eval==runtime 同源」 |
| **F-077** | gate2 masking 三形态某形态 enforce FAIL | A 三形态独立 fail-closed，任一未 enforce 阻断（不允许「2/3 形态就上」）/ B 先上 function-mask 其余后补 / C 统计够就放行 | **A** | `README §1` masking coverage 全 false 曾如实记录=未实现；F-021 从统计变 enforce | proposed | 防 0/34 假删变体：masking 声称 enforce 实 dry_run，cite P2「真删+活样本断言 code enforce 非 declare」 |
| **F-078** | gate2 `<think>` loss-mask 缺失判定 | A 训练 span 含未 mask 的 `<think>` token → 硬 fail（label 必 -100）/ B warn 继续 / C 靠 parity 探针够 | **A** | `:1026` trainedSpanContainsThinkMarker 已 append failure；premortem T-5b cite arxiv 2606.01080 | proposed | 防 θ-α 第二战线：loss 拟合 reasoning trace 非 tool-call；探针检出=硬 fail 非 warn |
| **F-079** | gate3 surface-preflight <80% 同源 | A <80% exit65 硬阻断 + 打印哪一方（train/eval/runtime/validator）分叉 / B 降阈值放行 / C warn | **A** | F-010 surface-source preflight ≥80%（已 ✅ 立于 θ-α 后）；四方同源 | proposed | 直防 0/34 tool surface 双分叉（train `:1942`⟂C6），cite P1「单源派生」 |
| **F-080** | gate5 六轴 held-out overlap 检出后 | A 检出 train/held-out 重叠 → 移出 held-out 侧重划（不删样本）/ B 删重叠样本 / C 记录放行 | **A** | D-016 六轴（parent_semantic+device+tool+value_type+template+generator_source）；`C5DataGate.swift` splitter | proposed | 防「held-out 泄漏=假提升」，cite P7「审计实跑一手」；重划非删防样本量塌 |
| **F-081** | gate6 四层某层 fail 的 early-stop | A 逐层 fail-closed 一票否决（golden 100%/unsupported 100%/safety 100% 任一<阈值即整体 fail），demo_fuzz 80% 阈值化 / B 加权平均 / C 只看总分 | **A** | E-002~006（D-007 已锁）；SYNTHESIS §1 P2-3「安全/golden/unsupported 维持 100%，demo_fuzz 允许阈值化」 | proposed | 防假提升（某轴撑分掩盖 action 塌），cite P5「empty=hit 掩盖」+ F-043 positive-not-diluted |
| **F-082** | gate6 哪一轴先塌的诊断序 | A 固定诊断序：先 action 轴（θ-α 战场）→ 再 unsupported/safety → 后 readback/format / B 按分数低到高 / C 并行看 | **A** | C6VehicleToolBench 四层；action=base 10/23 锚 | proposed | θ-α「action 全塌」是主战场，先诊断它，cite P6「C6 口径修 hard_pass 锚 10/23」 |
| **F-083** | gate8 工具数超预期范围 triage | A 若工具数 × 平均 token 超 Qwen3-1.7B context budget → 收窄 D-domain value-form 展开（现场约定 10 族收窄）或分片 system prompt，不静默截断 / B 截断放行 / C 换大模型 | **A** | premortem E-2；paradigm §16 命名框架；Qwen3-1.7B 8K/32K | proposed | 防「训练表面截断≠推理表面=θ-α 双面不一致」，cite P8 同源；现场 10 族约定收窄(demo 取巧) |
| **F-084** | gate8 工具数影响 gate3 preflight 阈值 | A 工具数实算后回校 gate3 的 surface token 预算，preflight 增「工具集 token < budget」子检 / B 不联动 / C 手工 | **A** | gate3 preflight `E-020/F-010`；gate8 tool_count | proposed | 防 gate 间脱节（gate8 改了 surface，gate3 preflight 没跟）=第10坑段间分叉变体 |
| **F-085** | 裁决-A tiny ablation FAIL（empty 未从 28/34 降到 <5/34） | A 判「范式未修复成功」→ 停，不得进真训练，回诊 surface/frame（不放宽判等绕过）/ B 放宽 empty 阈值 / C 多跑几次取好的 | **A** | F-044（D-007 已锁）；「未过不得声称范式修复成功」 | proposed | 防 0/34 重演（放宽判等=假绿），cite P9「recovery 成功标准定义」；🔴真跑本身 R7-blocked 等磊哥 run auth |
| **F-086** | 裁决-B positive-not-diluted FAIL（action 轴被 negative 稀释） | A action 轴独立 fail-closed，检出稀释 → 回校 negative 配比（by-batch 监控）/ B 调总配比 / C 接受 | **A** | F-043（D-007 已锁）；C6 action 轴独立 | proposed | 防 0/34 混合体假象（446 矛盾监督），cite P5 |
| **F-087** | gate 之间依赖序被违反（如跳 gate5 直接 gate6） | A gate 依赖序硬编码进 make verify（landing-matrix §2 依赖链），前置 gate 未 ✅ 不许跑后置 / B 靠人记 / C 并行都跑 | **A** | landing-matrix §2 依赖链；D-003「严禁跳 gate」 | proposed | 防「跳 gate 直接训」（D-003 hard constraint），机械化依赖门 |
| **F-088** | 多 gate 同时红的处理优先级 | A 按依赖序从最上游红的修起（surface/preflight 先于 held-out 先于四层）/ B 按严重度 / C 全停 | **A** | landing-matrix §2 | proposed | 防「归因最近变更」（claim-vs-reality §8）——上游 surface 红会级联下游全红，先修根 |

## §2 R-L17 candidate signoff 操作手册（F-089~F-095）— 「万事俱备后磊哥怎么签」

> R7-signoff `route_only_signed / candidate_unsigned`。candidate signoff = 磊哥最后一拍，本节把「怎么算够格上抛」的操作面细化（R7 §Required Checks For Future Candidate Signoff 落地）。

| ID | 议题 | 选项 A/B/C | ⭐推荐 | 论据(file:line) | 状态 | 🔴防惨败 |
|---|---|---|---|---|---|---|
| **F-089** | R1-R6 一手 evidence 收集格式 | A 三元组 `{file:line/row-id, verdict, 异源判官}` 每项必填，缺一不算 evidence / B prose 描述 / C 截图 | **A** | R7 §「Fill or supersede R1-R6 with first-hand evidence」；`r-l17-human-review-evidence/` | proposed | 防「审计只审合规不实跑」（P7）——evidence 必一手可溯 file:line |
| **F-090** | 异源反框审计规格 | A 用非 Claude-family 判官（GLM/Codex-OpenAI 二选一或都用）+ 反框 prompt 模板（「刻意找这套 gate 共享却没质疑的 frame」）/ B 同 family self-audit / C 4 模型投票 | **A** | R7 G3「glm-latest + Codex/OpenAI 二源」；codex-meta §31 cross-vendor≠cross-frame | proposed | 防同 family bias（D-011 gate6 假绿=同 family 漏，GPT Pro 第3家才 catch），cite §16 |
| **F-091** | human-owner R7 阅读清单 | A 磊哥亲核清单固定 5 项：①裁决-A run 结果(empty<5/34) ②C6 四层各轴分 ③surface 同源证据 ④held-out 无泄漏 ⑤异源判官 verdict / B 看总结 / C 看分数 | **A** | R7 G4「human owner reviewed... explicitly made decision」 | proposed | 防「4 模型一致 PASS 就放行」——R7 G4 明文 model consensus 不替代 human signoff |
| **F-092** | 「4 模型一致 PASS」的处理 | A 一致 PASS **不自动放行**，反而触发 human-owner R7 复核（一致=可能共享 frame 盲点）/ B 一致即放行 / C 多数决 | **A** | R7 G5「consistent PASS did not bypass human review」；本文 F-090 | proposed | 防伪收敛（dispute-triage 反向腿：已锁别当待决，但一致 PASS 要警觉共享 frame） |
| **F-093** | candidate 与 base 比较口径 | A action `hard_pass` 锚 base **10/23**，candidate 须**相对不退化 + 目标超 10/23**（非绝对分）/ B 绝对阈值 / C 看总 pass | **A** | c5-recovery「C6 真口径=action hard_pass 锚 base 10/23」；paradigm | proposed | 防「凭顶层聚合数推」（P6 claim-vs-reality §3），按 case schema 字段拆 action 轴 |
| **F-094** | run authorization 的最小前置 | A candidate signoff = 全部 8 gate ✅ + 裁决 A/B 过 + 异源审 + 磊哥 R7 清单亲核 + 显式 run auth 五者齐 / B 部分齐 / C 磊哥说跑就跑 | **A** | R7 §Required Checks（5 条）；landing-matrix §2 | proposed | 防「completion-claim 计划态当执行态」——万事俱备≠已证，run auth 是独立最后一拍 |
| **F-095** | candidate signoff 后失败的回退 | A candidate 训出来 C6 不过 base → 不签，回 grill 诊断（不将就签一个塌的）/ B 签了再改 / C 放宽 base | **A** | R7 candidate_unsigned 直到满足；0/34 报废不抢救先例 | proposed | 防 0/34「通宵跑完才暴露」——candidate 不过就不签，回诊非将就 |

## §3 landing（喂 gate 体系 + enforce，actionable）

- **喂 make verify**：F-087 gate 依赖序 + F-084 gate8→gate3 联动 → 机械门（依赖链未过不许跑后置）。
- **喂 R-L17 evidence 目录**：F-089 三元组格式 + F-091 磊哥 5 项清单 → `r-l17-human-review-evidence/` 模板。
- **喂 E-3 coverage 门**（%45 建测试，本决策）：`defaultProjectionKeys` 7 层断言进 CI（本文 F 系列关联 premortem E-3）。
- 🔴 **R7 守着**：本文 grill-only 写决策，裁决-A/gate1 真跑、candidate 真训练仍 BLOCKED，等磊哥 run auth。

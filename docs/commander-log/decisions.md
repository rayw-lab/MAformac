# COMMANDER DECISIONS — MAformac 指挥官决策日志（append-only, ADR 风格）

> 规则（github-first 搜证的 decision-log best practice）：每重大决策**立即写**（definition of done，不等压缩）；**supersede 不删**（保历史）；**rejected 选项 = hard constraint**（别再提被否的）。格式 = ADR 四问（what / why / alternatives / consequences）。

---
## D-001 战略对齐：A 文档收敛 + B R5 闭环 + C LoRA 信心
- **Date**: 2026-06-30 ｜ **Status**: Accepted ｜ **Type**: Strategy ｜ **Owners**: 磊哥拍 / commander 提
- **Context (what/why)**: 磊哥关切①文档级联乱②R5 runtime vs LoRA 方向③LoRA 0/34 怕再败。commander 理清：R5 runtime 闭环与 LoRA 是**同一缺口两面**——代码 active runtime 只有 L1 fast path + C3 guard/execute（gitnexus 坐实），**L2/L3 慢路（=LoRA 大脑「听懂模糊说」）未接入 runtime 也没训出来**。
- **Decision**: **A⭐** 文档收敛（1 套主线 SSOT + CURRENT + CLAUDE，uiue 只读消费、后续合并一把推）；**B⭐** 先 R5 runtime→presentation 闭环铺管道 → 再回归 LoRA（符合 parent plan）；**C⭐** commander 亲自深核 LoRA 信心 + pre-mortem 再败防线。
- **Alternatives rejected**: 直接深扒 LoRA 先于 runtime（rejected：先铺管道）；维护主线+uiue 2 套基线（rejected：SSOT 违反必分叉）。
- **Consequences**: A 立即做；B 涉代码需对齐切片；C → teardown → D-003。
- **落点**: `~/workspace/data/exports/snapshot-20260630-193609.md`

## D-002 A 文档收敛执行（A2a 主线止血 + A2b UIUE 决策注册·方案1）
- **Date**: 2026-06-30 ｜ **Status**: Accepted（done，未 commit）｜ **Type**: Architecture ｜ **Owners**: 磊哥拍 / commander 亲自执行
- **Context**: 2 worker 诊断坐实 uiue 仓 = 21 顶层 md + 6 grill 同名（bit-identical 陈旧拷贝）+ **数百 UIUE 独有决策（U32-45/P4/SD1-25/V1-12/CC/RPB-01~53/R0-R5）主线 master 全无**（commander §4 grep master U32/SD/RPB/V/CC = 0 坐实）。
- **Decision**: **A2a 主线止血**（CURRENT 旧 SHA 段标注 c1e7d58→当前 771f48a / README 去"v3 新基线以此为准"歧义 / 6 顶层加 historical banner / uiue-roadmap-2026-06-23 status ACTIVE→HISTORICAL / 3 phase0 D24 加 SUPERSEDED·RETIRED）；**A2b 方案1**（master `§3-UIUE` 加「UIUE 独有决策注册段」= 系列指针 + 绝对路径 uiue 落点[§4 亲核存在] + 状态，晶体待"合并一把推"不搬主线）。
- **Alternatives rejected**: A2b 方案2 全搬数百决策晶体进 master（rejected：与"合并一把推"重复劳动）；方案3 部分回（rejected：半重复）。
- **Consequences**: 改 13 主线 docs .md（验证：无代码污染、无 uiue 仓改动）；**未 commit**（worktree=dirty rebuild-c6，等 worktree 同步①）。§4 发现 baseline-semantic/srd 已有 banner 故跳过（避免重复）。
- **落点**: 主线 `docs/CURRENT.md` / `README.md` / `grill-tournament/grill-decisions-master.md §3-UIUE` 等 13 文件

## D-003 LoRA teardown verdict（方向对 + 配方健康 + 严禁跳 gate）
- **Date**: 2026-06-30 ｜ **Status**: Accepted ｜ **Type**: Product/Strategy ｜ **Owners**: 磊哥关切 / commander 综合
- **Context**: 磊哥怕 LoRA 再 0/34。4 纵切 teardown（commander 示范 TD-1 训练代码 + 3 worker TD-2 论文 / TD-3 根因 / TD-4 数据eval）。
- **Decision (verdict)**: LoRA **值得做**。①0/34 根因查清（三处失守：构建假删工具 / 审计只看 receipt 不看语义同源 / generic frame 判定面爆炸 1.7B 学不会）= **High** ②配方健康（`rank16Mainline` LR 1e-4 / gradClip1.0 / 真删+活样本断言，**code enforce 非 declare**）= **High** ③方向对（D-domain 具名工具拆判定面 + 真实座舱 2045 工具 ground-truth）= **Med-High**。但「能超 base 10/23」**未证**。
- **Hard constraint (rejected = 直接训)**: 🔴 **严禁跳 gate 直接训**。8 道 gate：3❌未实装（多轴 held-out / C6 四层阈值化 / 云 generator+异源 judge pipeline）+ 2⚠️待确认（训练循环本机真跑 / masking 三形态实装）+ 3✅（surface-source preflight≥80% / scale-authority=20 / cite-verify·sign-or-block）。**信心 = 路径改对 + 守 8 道 gate 一步步验，非"直接训会成"**。闭环证据 = A2 D-domain codegen 落地后 C6 实跑。
- **落点**: `~/Projects/agent-tmux-stack-research/runs/2026-06-30-lora-teardown/SYNTHESIS-LORA.md` + LORA-TD-1~4

## D-004 B/R5 runtime→presentation 闭环：回溯 + 3-worker probe 核稿（管道已铺，B 只剩窄收尾）
- **Date**: 2026-06-30 ｜ **Status**: Accepted ｜ **Type**: Architecture/Investigation ｜ **Owners**: 磊哥选 B / commander 回溯+派单+核稿
- **Context (what/why)**: 磊哥选 B（R5 runtime→presentation 闭环，铺 LoRA 管道）。按 goal-dispatch 铁律回溯 SSOT（parent roadmap R5 段 + OpenSpec bridge carrier + D20/D21 窄授权），再派 3 worker probe（**只读核现状定切片，不实装**）：R5P-1 入口侧(%44) / R5P-2 bridge+消费侧(%45) / R5P-3 端到端 proof(%43)。
- **Decision (核稿结论, 3 worker 交叉坐实)**: **管道（bridge contract）已铺得差不多，B 不是从零做闭环，只剩窄收尾（全 local/unit，非 model-backed）**。
  - ✅ **text 入口已接 runtime + 有 local/unit 闭环测试**：App→`DemoRuntimeSessionRunner.run(text:)`→`C3ExecutionPipeline`→`PresentationSnapshot`→`RuntimePresentationPayload`（`Core/Execution/DemoRuntimeSessionRunner.swift:47-99` / `Core/Presentation/RuntimePresentationBridge.swift:461`，commander 亲核 :461 = struct 定义行）；旧 `DemoWalkingSkeleton` 已迁出。
  - ❌ **mic / card-tap / cancel 三入口缺**：DTO 有(`DemoInteractionEventKind.micStart/.cardTap/.cancel`，`RuntimePresentationBridge.swift:3-10`)，但 Runner 只有 `run(text:)` 不消费 `DemoInteractionEvent`、App 无 mic 按钮/card 手势/cancel 控件。
  - ❌ **error/guard terminal payload 缺**：bridge adapter 有 `guardDenial/thrownError`(`RuntimePresentationBridge.swift:576-703`)，但 App catch 只写 `errorText`(`App/ContentView.swift:76-77`)。
  - ❌ **§9.8/9.9 Gate 4**（carrier 唯一剩的 `[ ]`，`openspec/changes/define-runtime-presentation-bridge/tasks.md:76-77`）：docs reconcile receipt（对齐 UIUE route map/burndown），**明确不实装 UIUE consumer**。
  - 🔴 **关键洞察**：真正卡 demo 的是 **LoRA 大脑（C，gated 等训练）+ UIUE 消费侧（gated）**，不是 B。
- **Alternatives rejected**: 把 B 当大工程从零做闭环（rejected：回溯坐实管道已铺）；mic/card/cancel 做真 ASR/真 cancel（rejected：voice/model gated，B 只做 local/unit mock event shell）；把 mainline mock consumer 偷挂 §9.8/9.9（rejected：§9.8 明确不实装 UIUE consumer，要补须单独定义主线 slice）。
- **Hard constraint (gated, 别再提)**: 🔴 full model-backed backend（等 C5 signed candidate）/ UIUE merge / UIUE consumer 实装 / voice·golden·mobile·true-device·live / V·S·U-PASS / A-2·R5 完成 —— 全 BLOCKED（CLAUDE §9 + roadmap line 571-579）。
- **Consequences**: B 窄切片（mic/card/cancel mock event shell + error terminal payload + §9.8/9.9 docs reconcile，全 local/unit）待拆 worker 派单上抛磊哥拍。**审计**：subagent CC 审 3 worker 派单 = CLEAR_WITH_FIXES（2 P1 + 1 P2，无 P0；P1 = `RuntimePresentationPayload` 行号引用，commander 已 grep 亲核 :461 正确）。
- **落点**: `~/Projects/agent-tmux-stack-research/runs/2026-06-30-r5-runtime-closure-probe/`（SPEC-R5P-1~3 + R5P-1-entry / R5P-2-bridge-consume / R5P-3-proof）

## D-005 C5 训练就绪 grill 编排（goal: 推进到 LoRA 能开始训练前节点；战略大转向）
- **Date**: 2026-07-01 ｜ **Status**: Accepted（进行中，3 worker grill 跑中）｜ **Type**: Strategy/Grill ｜ **Owners**: 磊哥 goal + 4 指令 / commander 编排执行
- **Context (what/why)**: 磊哥 `/goal clear` 画板 goal → 回 MAformac 推进 LoRA 训练。新 goal「推进循环工作到 LoRA 能开始训练」+ 4 指令：① 脑暴 300-500 决策覆盖 C5 方方面面（经验教训/论文/算法/语料 + 自己 teardown+pre-mortem 出维度）② 按 UIUE 215-grill 范式（决策矩阵/消减表/评分表，3 worker 角色灵活）③ 和 3 worker 脑暴 ④ 🔴 定时回忆双仓 LoRA 惨败 + 数据集 + 训练推进。**回溯坐实**：8 gate（`SYNTHESIS-LORA.md §三`，3✅⚠️/2⚠️/3❌）+ R-L17 `R7-final-route-deframing-signoff`（route-only signed 2026-06-25 磊哥本人签，解锁 rebuild-C6 construction §1/§2/§3，**retrain-c5 + data generation 仍 BLOCKED**，等 C6 construction 完成 + candidate signoff + run auth）。
- **Decision**: 建 grill SSOT `docs/c5-training-readiness-grill/`（README = 12 维度 + 决策矩阵/消减表/评分表/landing matrix 范式 + §1 双仓惨败回忆纪律）。**3 codex grill worker 并行**：W1 数据语料官（`%44` 维度2/3/7 ID `D-`）/ W2 算法训练官（`%43` 维度4/5/8 ID `A-`）/ W3 评测范式官（`%45` 维度6/9/12 ID `E-`），各 ~45 决策第一轮。**commander 亲挖维度1 纵切**（双仓惨败→防线 ID `F-`）+ 贯穿维度10/11。🔴 每决策填【防惨败列】cite P1-P9 PCA（防 0/34 + θ-α 重演）。
- **守 BLOCKED**: grill 只脑暴决策写 docs，**不实装/不训练/不生成数据**（守 R7 forbidden + D-003 严禁跳 gate）。这是 agree-before-build：先 grill 想清「做什么」，人审拍板后才实装。
- **Alternatives rejected**: 直接派实装 gate 任务（rejected：磊哥要先 grill 300-500 决策想清楚，agree-before-build）；B 窄切片继续（rejected：defer 留档，弱服务 C5 goal）。
- **Consequences**: 3 worker grill 跑中 → commander 自核 file:line + subagent CC 审回稿（磊哥铁律：派单+回稿都审）→ 综合 master + 消减表 + 评分表 + landing matrix → 人审拍板 → 拆实装 gate（rebuild-C6 construction 已解锁可先）。B 窄切片 worktree（`MAformac-w1`/`w2`）+ 3 SPEC 留档。
- **落点**: `docs/c5-training-readiness-grill/`（README + dispatch/SPEC-W1~3 + worker-1~3-decisions.md 待回 + 综合 master 待建）

## D-006 5-gate 实装编排批准 + worker teardown扩散/grill消减/gitnexus + commander 自维护记忆图谱纪律
- **Date**: 2026-07-01 ｜ **Status**: Accepted（执行中）｜ **Type**: Strategy/Dispatch ｜ **Owners**: 磊哥拍①②③ / commander 执行
- **Context (what/why)**: C5 grill 收口（332 决策，两轮 adversarial-auditor 全 0 P0，SYNTHESIS `grill_complete_pending_human_signoff`）。磊哥批准「5 ❌ gate → 3 worker 编排」三步：①建 3 独立 git worktree（防同工作树并行 construction 撞车）②写 3 份 D22 重型派单 ③subagent CC 双审（派单 + 回稿都审）。**追加 5 纪律**：① commander **自身持续维护**记忆图谱（每节点立即写，不只收口补）② worker 遇问题**积极 teardown 去扩散**（深挖根因 + 扩展调查，非报 blocked / 简化绕过；blueprint-teardown + pre-mortem-reflex）③ 派单**强调 grill 消减**（teardown 扩散后必 grill 收敛到 ⭐，按 reduction-table §2：locked/merge/defer/superseded/dedup，子决策不 sprawl）④ **先 cite 本地文件 + 先 gitnexus**（commander 写派单前必 gitnexus 吃透代码）⑤ 派单**要求 3 worker 也用 gitnexus**（impact 改前 / query 找流 / detect_changes commit 前，CLAUDE.md GitNexus 铁律）。
- **Decision**: 5 ❌ gate 拆 3 worker 并行 **construction**（守 R7：build code/spec/harness + fixture/base 单测，**不 run 真训练 / 真数据生成 / candidate eval**）：
  - **W1**（`%44` codex，worktree `MAformac-g6`）= gate6 C6 四层阈值化 fail-closed（E-002~006）+ 裁决-B positive-not-diluted invariant（F-043，C6 action 轴独立 fail-closed）+ carrier `rebuild-c6-four-layer-bench` AD-C6-*
  - **W2**（`%43` codex，worktree `MAformac-g5`）= gate5 六轴 held-out splitter（D-016）+ 裁决-A tiny-ablation harness（F-044，build harness 不 run 真训练）
  - **W3**（**hermes**，云 generator 续 hermes vendor，磊哥定）= gate7 云多源 generator + 异源 judge 三权分立编排 design/spec（D-031~037，design/spec 不 run 真生成）
- **Alternatives rejected**: 串行 gate6 先（rejected：磊哥要 5 gate 并行「先推」）；W3 用 codex（rejected：磊哥定「云 generator 之前是 hermes 本次还是 hermes」）；worker 直接训练/生成数据（rejected：守 R7 BLOCKED，construction only）；不用 gitnexus 直接 grep 写派单（rejected：磊哥定先 gitnexus 吃透）。
- **Hard constraint（守 R7，别越线）**: 🔴 retrain-c5 真数据生成 + 真训练 + candidate eval 仍 **BLOCKED**（等 C6 construction 完成 + signed candidate + run auth + human signoff，`docs/project/phase0/r-l17-human-review-evidence/R7-final-route-deframing-signoff.md`）。worker 只 build/design + fixture/base 数据单测。
- **Consequences**: 3 worktree + 3 D22 派单 → subagent CC 审派单 → 派发 → worker construction → subagent CC 审回稿。commander 全程维护 commander-log（本 D-006 即「自维护先行」落地）。
- **落点**: `docs/c5-training-readiness-grill/dispatch/`（SPEC-G5/G6/G7）+ commander-log（D-006 + swarm-runs 新 run）

## D-007 磊哥 formal lock 5 gate ⭐ 决策（解审计 P0-2 proposed-not-locked，construction 继续）
- **Date**: 2026-07-01 ｜ **Status**: Accepted ｜ **Type**: Decision-lock ｜ **Owners**: 磊哥拍「我都按照推荐来 没啥问题」
- **Context (what/why)**: D-006 派发后 commander checkpoint 上抛 §2 人审拍板（5 gate ⭐ 组）+ R7 邻接 scope（拍 1/拍 2）。审计 G5 P0-2 抓「决策全 `proposed` 未 locked，跳了 grill §4 step1」。磊哥「我都按照推荐来 没啥问题」= **formal lock 全部 ⭐ + 确认 R7 收窄 scope**，补齐 grill §4 step1（agree-before-build 闭环）。
- **Decision (locked)**: 5 组 gate ⭐ 由 proposed → **locked**：
  - **E-002~006** 四层逐层 fail-closed（golden 100% / demo_fuzz 80% / unsupported 100% / safety 100% 一票否决）
  - **F-043** positive-not-diluted（action 轴独立 fail-closed + OOD/空输出探针）
  - **D-016** 六轴 held-out（parent_semantic + device + tool + value_type + template + generator_source）
  - **F-044** tiny-ablation 裁决门（20-50 样本 empty 28/34→<5/34，**未过不得声称范式修复成功**）
  - **D-031~037** 云 generator 三权分立（多源产 / C1 确定性标 / 异源 judge 审）
  - **R7 邻接 scope 确认**：gate5/裁决A/gate7 = construction/tooling/design-only **不 run 训练/生成/评测**（守 R7 实际 blocks）。
- **Alternatives rejected**: 等 worker 跑完再 lock（rejected：lock 是 §4 step1 前置，magnet 已拍即回写）；只 lock 部分（rejected：磊哥「都按推荐来」= 全 lock）。
- **Consequences**: 派生跟踪级联回写 locked（landing-matrix / reduction-table / SYNTHESIS）；worker construction 继续（table-driven 已就绪，locked 值 = ⭐ 默认，与在跑工作一致**零返工**）；🔴 **PR merge to main 仍是磊哥最终 apply gate**（lock 决策 ≠ 授权合 main）。
- **落点**: `landing-matrix.md` / `reduction-table.md §4` / `SYNTHESIS.md` status 更新 locked

## D-008 gate7 design 收口 + Q1-A/Q2-A 拍板 + 前数据集反思洞察（同源自审假异源 / 0/34 口径）
- **Date**: 2026-07-01 ｜ **Status**: Accepted ｜ **Type**: Design-lock / 口径 ｜ **Owners**: 磊哥拍「同意」
- **Context**: hermes API 两次 `FailedToOpenSocket` → gate7 改 **Opus subagent CC**（磊哥定「hermes 不通用 subagent CC，Opus 对生成设计更强」）+ 参考之前生成数据集找反思。subagent 产 423 行 design（`MAformac-g7/docs/.../gate7-cloud-generator-design.md`）+ 挖 **4 埋雷**，commander **python 亲核 100% 吻合**（generator=hermes_glm2249+ark2251 / judge=同两模型 → 100% same hermes 家族；utterance 4306 distinct 中文 mean 9.3）。2 口径分歧上抛磊哥。
- **Decision (拍板)**:
  - **Q1-A**：Claude generator 主力(Anthropic) + **GPT-5.5 纯异源 judge**(OpenAI)，跨厂商干净——修**埋雷①**（前一次 generator/judge 都 hermes 家族，"异源 judge" 是假的 100% same-vendor 自审）。
  - **Q2-A**：惨败1「0 条自然中文」在 gate7 语境重述「**自然中文虽有但薄 + 同源自审 100% hermes + 下游 sample 组装崩**」。🔴 **nuance**：「**训练集** 0 条自然中文」对训练集本身**准确**（训练用协议串 `C5LoRATraining:1767`）；Q2 修正的是别误读成"生成产不出中文"（生成真产 4306 条中文）——两个不同 pipeline 阶段不矛盾，**历史研究档不改**（c5-superaudit 等对训练集准确，doc-cascade 历史档不动）。
  - **gate7 修法沉淀**：异源定义到**顶层 vendor 枚举**（Anthropic/OpenAI/Volc-twofish），G1 门查 `judge_vendor≠generator_vendor`（前一次 model_id 字符串区分不了同厂商两模型 = 假异源根因）。
- **Alternatives rejected**: Q1-B/C（GPT-5.5 也做 generator，self-bias 边界复杂，rejected：起步纯异源 judge 最干净）；Q2-B 保持原措辞（rejected：数据坐实生成产了 4306 中文，避免 gate7 背 0/34 锅）；blanket 重写 13 处「0 条自然中文」（rejected：训练集 claim 准确，doc-cascade 历史档不动）。
- **Consequences**: gate7 design status → `commander_reviewed_magnet_ratified_q1a_q2a` → commit + PR 上抛磊哥 merge；gate7 scope 严格 = 生成阶段（别背 0/34 训练侧锅）；🔴 **actual 生成仍 R7 BLOCKED**（candidate signoff 才 lift）。
- **落点**: `MAformac-g7/docs/c5-training-readiness-grill/gate7-cloud-generator-design.md`（§7 Q 段 + frontmatter ratified）

## D-009 grounded grill round 收口（本 session 经验发现驱动，110 新决策，总监综合）
- **Date**: 2026-07-01 ｜ **Status**: Accepted（决策 proposed 待磊哥 locked）｜ **Type**: Grill ｜ **Owners**: 磊哥「增加 grill + 3 worker 互动 + 按范式」/ commander（懂记忆的项目总监）综合
- **Context**: 磊哥问「这些新发现在 332 grill 里吗」→ commander grep **覆盖核查坐实 6 新发现全不在 332**（假异源judge/0-34口径/bug分布/生成scope/旧3804复用/稀疏族场景触发；332 只有理论 topic）→ 新增 grounded round。3 worker 互动 grill：W1 配比（%44）D-096~125=30 / W2 质量（**%43 codex fallback**，Opus subagent 两次 API socket 挂→F-052 路由）A-096~133=38 / W3 语料（%45）E-096~130=35 + commander 纵切 F-048~054=7 = **110 决策**，按范式（决策矩阵 7 列 + 防惨败列 P1-P9 + grill-recall 承接不重复）。
- **Decision**: commander 总监综合 `SYNTHESIS-grounded-round.md`（汇总 110 + 消减 10 组 overlap→净 ~60-70 + 评分 net 载力 top + landing 喂 gate7/生成）。**净新载力 ⭐**：A-096/097 vendor-enum 异源强制（修假异源）/ D-096/097 quota 混合公式 + bug 不线性放大 positive（屏幕黑屏≠调亮度）/ E-098/129 precision 门（shortlist 非 gold）/ E-100/124 执行失败不入 action train / D-098+E-113 稀疏族 scene-trigger（雨刮 12 不砍）/ A-110~112 judge 质量监控。
- **质量（commander review 互动）**: 3 worker 全高质量（全 cite + 防惨败列 + grill-recall）；🔴 W2 自 python 复算旧 jsonl 印证假异源 + catch commander 派单 cite 错；W3 cite 到 C6VehicleToolBench.swift 实际行号。
- **Consequences**: 待磊哥拍板 ⭐ locked → 落 landing-matrix + 回写 gate7 design 对应节；审计（subagent CC 恢复 / codex 交叉，磊哥「三者等效」）；🔴 **R7 守着真生成/真训练 BLOCKED**（candidate signoff 才 lift；gate7 别背 0/34 锅 E-117/F-049）。
- **落点**: `docs/c5-training-readiness-grill/worker-{1-data,2-algo,3-eval}-round3-grounded.md` + `worker-commander-round3-grounded.md` + `SYNTHESIS-grounded-round.md`

## D-010 grounded round 净新载力 ⭐ locked（磊哥「全部同意」）+ 回写 gate7 design
- **Date**: 2026-07-01 ｜ **Status**: Accepted ｜ **Type**: Decision-lock ｜ **Owners**: 磊哥「全部同意 继续推进」
- **Context**: grounded round（D-009）总监综合 + codex 交叉审 **CLEAR_WITH_FIXES**（P0=0）收口，上抛磊哥拍板。
- **Decision (locked)**: 净新载力 ⭐ proposed→**locked**：
  - **A-096/097** vendor-enum 异源强制（顶层 vendor 枚举 + G1 门 `judge_vendor≠generator_vendor`）
  - **D-096/097** quota 混合公式（intent+bug压力+地板）+ bug 不线性放大 positive（屏幕黑屏≠调亮度）
  - **E-098/129** precision 门（bug shortlist 非 gold，precision<0.8 停该族）
  - **E-100/124** 执行失败 809 不入 action train（只转 failure receipt/C6 trap）
  - **D-098+E-113** 稀疏族地板 + scene-trigger（雨刮 12 不砍，靠「下雨了」）
  - **A-110~112** judge 质量监控 / **A-118/122** diversity 实测校准 / **F-048~054** 新惨败防线
  - **M4 reconcile**（审计精化）：旧 3804 utterance **TEXT 可救**（重过 gate），旧 hermes judge **verdict 作废**（假异源不可信）→ 全部重过新 vendor-enum 异源 judge
- **Consequences**: 回写 gate7 design §10 grounded landing（vendor-enum 确认 + precision 门 + source tags + quota→生成 + bug→C6 映射）；落 landing-matrix + reduction/SYNTHESIS status locked；🔴 **真生成/真训练仍 R7 BLOCKED**（lock 的是 grill 决策 + 回写 design，非授权生成；candidate signoff 才 lift）。
- **落点**: `MAformac-g7/docs/c5-training-readiness-grill/gate7-cloud-generator-design.md §10` + `landing-matrix.md` + grounded grill 文档 status locked

## D-011 GPT Pro 第3家跨厂商审计 3 云端 PR + 3 worker 修 findings + 磊哥拍 A merge
- **Date**: 2026-07-02 ｜ **Status**: ✅ Done（3 门 MERGED + verified，main=ab355f6c） ｜ **Type**: Audit-remediation + merge-ratification ｜ **Owners**: 磊哥「A：可以交给worker做」
- **Context**: 5-gate PR #9/#10/#11 待 merge → 磊哥 `/gptpro audit 范围尽量大`（PR7 之后新 3 PR）→ 安排 worker 修 findings。
- **执行**:
  - **GPT Pro 审计（第3家跨厂商）**: connector 自动启用失败（"更多"selector timeout + private repo web 读不了）→ commander pivot **上传 3PR diff(1632行/108KB) 直读审**（绕 connector）→ verdict **REQUEST_CHANGES P0=0**（无 R7 越界）+ 独立印证 gate6 P0 分母修复无回归。
  - 🔴 **最关键 finding = CI 红是 repo CI bug 非代码**（commander 拉一手 CI 日志坐实）: `verify.yml` whitespace check 在 PR 浅 clone(`--depth=1`) 下 fetch 了 base 没 fetch head SHA → `git diff --check base..head` = `Invalid revision range` exit128，所有新 PR 中招（#8 没修净）→ 3 PR 各补 `fetch base+head`。
  - **3 worker 修 findings**（磊哥「worker 1% context 不担心，auto-compact 很吊，给 worker 做」）: #9 device axis 真填 / generator_source 归 vendor / TinyAblation R7 guard / +tests ｜ #10 legacy Codable `decodeIfPresent ?? []` / orphan `case_missing_runs` fail-closed / status `construction_four_layer_threshold_*` ｜ #11 design §1.2 redact 5 处/8 话术→shape 描述。
  - **收稿坐实**: 全部 3 PR CI verify=PASS + commander gh/grep **一手亲核 genuine**（head SHA/CI/redaction grep=0/code file:line，非信 ack）+ worker 回执三方一致。
- **Decision（磊哥拍 A）**: 3 个都 merge 进 main（交 %45 worker rebase-merge）；commander 沉淀六部曲。→ ✅ **gh 一手核销 3 门全 MERGED**（merge SHA #9=`0b486376` / #10=`3a9ed397` / #11=`ab355f6c`，main=`ab355f6c`，**main CI Verify SUCCESS run 28532906744**，`make verify-all` 472 tests/0 fail[%45 clean-worktree，CI 不跑 swift 故此项 %45 全测试+各 PR 单独 swift 绿+disjoint merge 佐证]）。**🎉 3 训练前置门正式落 main**。
- **Consequences**: 3 构造门落 main（rebuild-c6 §1/§2/§3 construction 已解锁允许）；🔴 **R7 全程守住**（修复+merge = construction/doc/yaml only，status `construction_*` 显式标构造门非真验收；retrain-c5/真生成/candidate signoff/C6 真验收/golden/voice/uiue-merge/V-S-U-PASS 仍 BLOCKED）。
- **落点**: `swarm-runs.md` run 2026-07-01-gptpro-audit-3pr-fix-dispatch（执行进展段） + 本决策 + handoff `docs/handoffs/2026-07-02-*.md`
- **🔴 关键学习（跨项目复用）**: ① **GPT Pro connector fail → diff-upload workaround**（`gh pr diff > file` 上传 chatgpt MCP，GPT 读实际代码非空审）② **收稿=gh/grep 一手核非 ack**（swarm §3 强化，3 PR 全核销与回执一致）③ worker auto-compact 救 context（%44 7%→50% / %45 13%→87%，印证不用担心 worker context）

## D-012 今夜自主推进到 LoRA 训练前节点（overnight swarm push，R7-bounded）
- **Date**: 2026-07-02 ｜ **Status**: Accepted（进行中）｜ **Type**: Strategy/Goal ｜ **Owners**: 磊哥 `/goal` + 6 指令 / commander 编排
- **Context (what/why)**: 磊哥 `/goal`「今夜你和 3 worker 推进到 LoRA 训练前，前置工作都做完」+ 6 指令：① 双方都有 subagent 灵活用 ② 任何关键动作带「有记忆项目总监」认知 ③ 关键动作必 **premortem + iceberg teardown** ④ commander 主**指挥非执行** ⑤ 关键动作走 **调研→脑暴→设计→计划→实施→循环验证** ⑥ 很多 grill 清单还没做，**多多联网**。前置节点 = `docs/c5-training-readiness-grill/landing-matrix.md §1` 的 8 gate + 2 裁决门 → 物理就绪（守 D-003 严禁跳 gate）。
- **Decision**: 五相编排——**调研相**（3 subagent 并行：gate-reality reconcile stale landing-matrix / grill-gaps 12 维度盘点 / push-premortem 联网搜坑）→ **脑暴设计相**（iceberg teardown「为何反复到不了 ready」+ WBS 拆 R7-safe 切片）→ **计划相**（worker 派单 inline SSOT）→ **实施相**（3 codex worker %44/%45/%43 + 各自 subagent 建 construction/grill/spec，commander 亲挖纵切）→ **循环验证相**（loopaudit + ≥3 厂商终审）。R7-safe（construction/grill/spec/reconcile/工具数实算）全做完；R7-blocked（真训练/真生成/tiny-ablation RUN/candidate）到边界**上抛磊哥签，不自主跨**。
- **Alternatives rejected**: 直接开训（rejected：D-003 严禁跳 gate + R7 BLOCKED）；一次大爆炸不走 premortem/iceberg（rejected：磊哥要 6 步过程防第三次惨败）；commander 亲自执行代码（rejected：磊哥「主要是指挥不是执行」，worker+subagent 灵活）；基于 stale doc-absorption 分支实施（rejected：main=ab355f6c 已含 gate5/6/7 merge，本 worktree 落后，实施须基于 main，gate-reality 确认后定拓扑）。
- **Hard constraint（死守 R7）**: 🔴 retrain-c5 真训练/真数据生成/C6 acceptance/candidate comparison/golden/voice/endpoint/uiue-merge/V-S-U-PASS 全 **BLOCKED**。到「万事俱备只欠按训练键」为止 → 磊哥最后 candidate signoff + run auth（`R7-final-route-deframing-signoff`）。模糊边界（tiny-ablation RUN / 训练循环 smoke run / generator 真跑）= push-premortem 判定 + 必上抛，不自主跨。
- **Consequences**: 立 D-012 + task 跟踪 + 3 调研 subagent 跑中 → 综合 → iceberg → WBS → 派 worker construction/grill → 循环验证 → 到 R7 边界收口上抛。commander-log 全程自维护（每相里程碑即写 decisions + 刷 INDEX）。
- **落点**: 本 D-012 + `COMMANDER-INDEX` 当前阶段/下一步刷新 + task 列表 + `swarm-runs.md` 新 run 2026-07-02-overnight-pre-lora-push

## D-013 调研+脑暴设计收口 → 3-worker R7-safe WBS 派发（iceberg + premortem 亲核 + 拓扑决策）
- **Date**: 2026-07-02 ｜ **Status**: Accepted（执行中）｜ **Type**: Design/Dispatch ｜ **Owners**: commander 综合 + 磊哥 briefing
- **Context (what/why)**: D-012 调研相收齐（gate-reality 我亲挖 git 一手 + grill-gaps + push-premortem 三份，落 `runs/2026-07-02-overnight-pre-lora-push/`）。**iceberg teardown 结论「反复到不了 ready」三层**：① **stale tracking 错觉**——gate5/6/裁决A/B construction 已 merge 落 main（`aa1adf8f`/`696676ba`），landing-matrix 标 ❌ 是 derived-tracking 漏回写；② **真缺口**在 grill 维度10（gate体系+R-L17 仅 10 条）/维度11（pre-mortem 仅 12 条）稀薄 + gate8 工具数 TBD + gate2 masking construction；③ **结构性天花板**：证明性验证（裁决A 真跑/gate1 真跑/C6 真评测）被 R7 有意锁磊哥手（对的非失败）。
- **premortem 亲核（§4 裁决）**: 🔴 T-3（mlx #2616 Qwen3 LoRA 0.28%=θ-α 症状）→ 我 grep 亲核 = **paper-tiger**，`defaultProjectionKeys` `Core/Training/C5LoRATraining.swift:1264` 已列全 7 层 q/k/v/o+gate/up/down（3.48%），团队早防了；残留=加 coverage 门防回归（E-3）。HIGH 处置：T-1 worktree 隔离已建 / T-2 裁决A 真跑=R7 边界**上抛磊哥** / T-5 masking dry_run+`<think>` loss-mask 双验 / E-1「万事俱备」必标裁决A 等 run-auth / E-2 工具数 context 预算。
- **Decision（WBS 3 worker + commander，全 R7-safe）**:
  - **%44 → gate8 工具数实算**（worktree `MAformac-g8-tool` off main，branch `c5gate/g8-tool-count`）：ToolContractCompiler 实算 `generated/family-device-allowlist.json:302` tool_count TBD→真值 + E-2 context 预算估。
  - **%45 → gate2 masking enforce**（worktree `MAformac-g2-mask` off main，`c5gate/g2-masking-enforce`）：masking 退 dry_run→enforce + `<think>` loss-mask 硬化 + E-3 lora-keys coverage 门测试。
  - **%43 → grill 维度11+维度5 补深**（worktree `MAformac-grill` off doc-absorption HEAD，`c5grill/dim11-dim5-deepen`）：pre-mortem enforcement 挂点 + 3 缺失模式 + 论文 verify，写**独立文件**防冲突。
  - **commander → 维度10 grill 补深（gate体系+R-L17 纵切）+ tracking reconcile（landing-matrix/proposed→locked/commander-log）+ 裁决亲核每 worker 回稿**。
- **Alternatives rejected**: 同 main 树并发写（rejected：T-1 index 损坏）；merge main 进 doc-absorption 统一 base（rejected：~24 文件冲突，改用分 base worktree）；commander 亲写全部 grill/code（rejected：指挥非执行，纵切+裁决+reconcile 才是 commander 活）；%43 留 uiue（rejected：uiue R7-isolated 非 pre-LoRA，灵活调来补 grill）。
- **Hard constraint（R7）**: R7-safe only（construction/grill/design）；R7-blocked（裁决A/gate1/generator 真跑、真生成、真评测）**只 build harness 不 run**，到边界上抛磊哥。worker 回稿 gh/grep 亲核**不信 ack**（T-4 假绿）。
- **落点**: 3 worktree + worker SPEC（inline SSOT）+ 本 D-013 + `swarm-runs.md` run + task #3/#4 in_progress
- 🔴 **SUPERSEDED（部分）by D-014**：本 D-013 + swarm-runs 记的「gate2 masking GENUINE / 自跑绿」被对抗审计推翻 = **gate2 P0 假enforce**（gate8/grill/R7 部分仍 CLEAR 有效）。

## D-014 循环验证 catch — gate2 masking P0 假enforce（对抗审计抓，commander 自跑漏，supersede D-013 gate2 GENUINE）
- **Date**: 2026-07-02 ｜ **Status**: Accepted ｜ **Type**: Audit-catch/Correction ｜ **Owners**: 对抗审计员(adversarial-auditor) catch + commander 亲核坐实
- **Context (what/why)**: wave-1 循环验证相，commander 派对抗审计员（≥1 异源审，D-011 教训）终审 wave-1。**抓到 gate2 masking P0 假enforce（0/34 精确同构）**——commander 之前**自跑 44/0 绿 + grep 亲核都没 catch**（验的是「字段内部一致」非「mlx-lm 真消费」= 循环失守）。
- **Finding（commander grep 亲核坐实，非盲信审计）**: gate2 `loss_mask` 是 mlx-lm 训练**不消费**的 dead field——训练走 stock `default_loss`+`--mask-prompt` offset（`c5_mlx_train_loop.py:177`/`main.swift:186`），loss_mask 只在 preflight（`:564-601`）；labels **char-indexed**（`:1893 assistant.count`）非 token；think-mask 零生效（θ-α 第二战线裸奔）。三层校验（Swift validateLossMaskEnforcement/test + py preflight）全校 dead field 内部一致 = 循环失守。
- 🔴 **元教训（最刺眼）**: commander 自己写的 grill **F-077/F-078/F-064/F-068 精准预判此病**（「masking 声称 enforce 实 dry_run」「enforce 非 declare 要绑可重跑命令」），**实现层却全掉进去 = 认知到≠行为改** → 修法：F-068 物化成「masking 真进 loss」可重跑机械门（P1）。
- **Decision**: ① **supersede D-013 + swarm-runs「gate2 GENUINE」**（gate2=P0 假enforce 非 done）② 派 %45 修（R7-safe：char→token + mlx-lm 真消费 token-level mask + F-068 unit 证 -100 真进 loss；real-model 集成 proof R7-gated 等磊哥 run-auth；遇架构岔口停下上抛）③ 上抛磊哥 design 岔口：⭐ 全 token-level span+think mask（override mlx-lm，masking 不省 §7 + 防 θ-α）vs stock `--mask-prompt` offset（取巧但无 think-mask）。
- 🔴 **验证价值实证**: 这次 catch = premortem+iceberg+≥1 异源审 **拦下 θ-α round 2**（若信自跑绿→报 done→磊哥签→又 0/34）。**disaster-core 必 ≥1 异源审**；commander 自跑（验字段一致）catch 不到架构级假enforce（claim-vs-reality 铁律2:合规≠成功）。
- **CLEAR（audit 确认）**: gate8（562 独立复算 + value-form 真 + E-2 真发现）/ grill Dim5/10/11（11 arxiv 全真 + BFCL 诚实 TODO）/ R7 无越界。
- **落点**: `AUDIT-adversarial.md` + `landing-matrix.md §3` gate2 改 P0 + 本 D-014 + swarm-runs banner + task #5
- 🟢 **UPDATE（异源 re-audit CONFIRMED，`AUDIT-fix-reaudit.md`）**：%45 gate2 P0 fix（commit `47ca8cda`）→ 异源对抗审计员复验 = **T-FIX-CONFIRMED / 0 P0（原 P0 已消解）**：训练在 `--require-maformac-loss-mask` 下真走 `maformac_masked_loss`+`maformac_iterate_batches`（非 stock default_loss，`--mask-prompt` 已删），token-level -100 真进 cross-entropy；char→token offset_mapping overlap 真做；循环失守转真 loss 数学门（commander+re-audit 双自跑 self-test `masked=0.00067 vs unmasked=2.667`）；「未真消费的层=无」。残留 P1 = 真 Qwen/MLX batch dump（R7-gated，fail-closed 不会静默退化成无 mask = 正确性残留非 enforce 残留，receipt 诚实标）+ P2（vestigial offset artifact 待 R7 清理）。**disaster-core fix 走完 D-014「≥1 异源审」闭环。task #5 循环验证 done。**

## D-015 新指挥官接棒复审（fresh-context 异源，wave-1 全交付独立复现 CONFIRMED）
- **Date**: 2026-07-02 ｜ **Status**: Accepted ｜ **Type**: Handover-audit ｜ **Owners**: 磊哥「新指挥官亲自审计上任交付」/ 新 commander 亲核（不派 subagent，本体 fresh-context = 异源视角）
- **Method（下钻消费/行为层，claim-vs-reality 第12变体纪律）**: git 一手（3 worktree SHA 全对上 `64c6f62f`/`47ca8cda`/`f9e67901`）+ 读消费层代码 + **亲跑** self-test/swift test + python 独立复算 + arxiv 外核抽 2。
- **Verdict（逐件）**:
  - **gate2 masking fix = T-FIX-CONFIRMED 独立复现**：训练/eval 真走 `maformac_masked_loss`+`maformac_iterate_batches`（`c5_mlx_train_loop.py:498-499/:512-516`）；loss 数学真 token-level（`mask=labels!=-100` → `ce*mask`）；**亲跑 self-test 数字精确复现** `masked=0.00067 vs unmasked=2.667, ntoks=2`；`--mask-prompt` 已清（仅注释+负断言）；char→token offset_mapping 全链 fail-closed（offsets 缺→raise / 子序列定位失败→raise / 旧 char-indexed `labels` 字段**显式禁止** `char_indexed_loss_mask_labels_forbidden` / trainable=0→exit66）；think span 后应用=think 恒胜；Swift `main.swift:186` 恒渲染 flag + 测试 `:960` 锁；swift test **45/0 亲跑绿**。残留 P1（真 Qwen batch dump R7-gated）定性诚实=正确性残留非 enforce 残留。
  - **gate8 = CLEAR 独立复现**：562 三路复算一致（catalog len=562 / unique names=562 / 10 族分布加总 ac68+light113+screen75+door48+fragrance16+seat126+volume32+wiper27+window27+sunroof30=562）；value-form 具名真（`adjust_ac_temperature_to_max/_min/_exp/_no_value`）；anti-fake-green 测试真存在且 22/0 亲跑绿；**E-2 我复算更强**：full serialized 413k chars≈103-138k tokens（>声称 74-99k，口径差=序列化方式），「562 工具面超 Qwen3-1.7B context→10 族 subset 技术必需」结论只会更成立。
  - **grill 补深 = CLEAR**：计数精确（A-134~150=17 / F-055~075=21 / F-076~095=20）；BFCL 诚实 `TODO-no-arxiv-found` 带理由；arxiv 外核抽 2/2 真（`2503.22673`=ActionStudio / `2409.03215`=xLAM，题目相关）；frontmatter 诚实 `proposed 待磊哥 lock`。
  - **R7 = kept**：三 worktree 物理扫描零权重/adapter/生成语料产物；self-test 纯合成 logits 在 model load 前 early-return。
  - **流程诚信**：两份审计档原文（S-NO-SHIP→T-FIX-CONFIRMED）与 decisions.md/handoff 转述一致无美化；D-013 被 D-014 supersede 的处理规范。
- **新观察（非 blocker，2 条）**: ① **P2-弱化建议**：py 训练循环 mask 接线是三元条件（flag 缺省→静默走 stock `default_loss` 且此时零 mask，因 `--mask-prompt` 已删）；当前 enforce 依赖「Swift 渲染命令是唯一入口」+ 测试锁，成立但手拼命令场景脆弱——建议 R7 解锁改码窗口时加「数据含 loss_mask 而 flag 缺失→fail」反向门。② E-2 数字口径（297k vs 413k chars）建议 subset 决策时按我的保守口径（更大）估预算。
- **Consequences**: 上任交付定性=诚实且高质量，5 件磊哥-gated 待决照旧（①masking design 岔口 ⭐override ②E-2 subset ③grill 维度10/11/5 lock ④T-2 tiny ablation run-auth ⑤wave-1 consolidation-to-main）。新 commander 接管指挥权。
- **落点**: 本 D-015（审计过程全 inline，无独立报告文件）

## D-016 基线路线图双文档落盘（树/合并路线 + LoRA 闭环鸟瞰）+ CURRENT 路由牌刷新
- **Date**: 2026-07-02 ｜ **Status**: Accepted ｜ **Type**: Baseline-docs ｜ **Owners**: 磊哥「写此时此刻 baseline 路线图（若干份）」/ commander 编排 3 worker + 亲写
- **Context**: 磊哥认可 gate2 design + 采纳外部审计口径（P1 real-model batch dump / P2 反向 guard[=D-015 观察①两审计独立撞出] / wave-1 PASS·true-run HOLD·consolidation staged-PR），命题：全树状态+合并节点+PR 节点+现状 verdict+3 worker 目录+文档级联+到 LoRA 训练结束的闭环鸟瞰+巨人肩膀（含 HF skills 截图 teardown）。
- **执行**: 任务索引 #1-#7 → 3 worker 并行（%44 L1 全树盘点 read-only / %45 L2 hf-skills 验活+增量 fetch+teardown / %43 L3 训练闭环素材 8 块带 file:line）+ commander 亲核（gitnexus 发现论文 repo 已 vendor 在 `Tools/paper-to-skill-gate/`；重读 landing-matrix §3 + R7 signoff + SYNTHESIS-LORA §三）。收稿 catch：L3 §1 gate 态引 grill 树旧 landing-matrix 快照 = stale，综合时以主树 §3 reconcile 修正（claim-vs-reality 活例）。
- **产出（3 份基线 + 1 手档）**:
  - ⭐ `docs/baseline-roadmap-2026-07-02-pre-lora.md`：16 树矩阵（活跃 keep 6 / cleanup-safe 候选清单）+ 节点 M1(consolidation staged PR-α g2/β g8/γ 文档整编支[亲核 main 上 grill 语料仅 1/28 件])→M2(清理)→M3(D25)→M4(UIUE) + verdict **HOLD** + 3 worker 派工规则 + 文档级联指针表。🔴 关键防回退：g5/g6/g7 直合会删 main 新文件（L1 cherry+diff 坐实），绝不直合。
  - ⭐ `docs/lora-loop-blueprint-2026-07-02.md`：8 gate+2 裁决真实态表 + 闭环总图（生成→门→裁决A→训→行为中门→C6 四层→candidate 裁决，✍️ 标磊哥授权点）+ run receipt 契约（借 hf-skills 六段拓扑本地化，drop hf_jobs/Hub/CUDA）+ 节点序 A-H + 巨人肩膀矩阵（树内 vendor Hammer/xLAM/When2Call/SemDeDup + raw home-llm 权重最高 + hf-skills ⭐10753 借形不借 runtime）。
  - `docs/CURRENT.md` 全量重写（前版 D25 K1 时代 stale，supersede 说明保留）。
  - 一手档：`runs/2026-07-02-baseline-roadmap/`（3 SPEC + L1/L2/L3 + DONE×3）。
- **Consequences**: 现状 HOLD 直到磊哥 5 件决策；R7 route-only **2026-07-15 到期**入 5 件附注；gate7 pipeline 代码闭环 = 剩余最大 R7-safe construction（节点 C，M1 后可立项派 worker）；两基线文档随 M1-γ 进 main。
- **落点**: 本 D-016 + 上述 3 文档 + task #1-#7 全 completed
- 🟢 **UPDATE（hermes 审计吸收 + E-2 真口径，2026-07-02）**：hermes 审计 D-016 产出（2 P1 + 3 P2 全事实型，我逐条 cite-verify 5/5 坐实）→ 全吸收：① L2 锚点漂移（引 CURRENT.md:104-113 已被 629b1132 重写位移）→ L2 加 RECONCILED banner（旧锚 `git show 7dd64a50:docs/CURRENT.md` 可核，正文一手 receipt 不改）② task ledger 缺失 → `runs/.../TASK-LEDGER.md` 补齐 #1-#7 逐项证据锚，closeout 口径降级为「3 worker reports + commander synthesis + ledger 补齐」③ roadmap 147/14 self-staleness → 改「147 behind + ahead 随文档 commit 递增（7dd64a50/14→629b1132/15），live 以 git rev-list 为准」④ §5 CURRENT 行措辞矛盾 → 改「本分支版 629b1132 已重写为最新草案，main 版仍旧态」⑤ L3 加 RECONCILED banner（§1 gate 态列引 grill 树旧 landing-matrix，权威=主树 §3+blueprint §1）。🔴 **E-2 一步到位升真口径**：mlx-community/Qwen3-1.7B-4bit 本机缓存 tokenizer 离线实测（R7-safe tokenizer-only）562 工具目录 compact JSON=**126,275 tokens** / default=**159,899 tokens**（tokenizer 报警超 131,072 max）→ hermes proxy 估算（74-109k）与我保守口径（103-138k）**全部作废**，结论加固：562 全集任何 context 配置装不下，subset 是数学必然。blueprint §1/CURRENT/MEMORY 三处已同步刷。hermes elephant（proof-class 混用：HF cloud/Hub/Trackio 不可替代 local C5/C6/R7 signoff）= blueprint §5 hard drops 已覆盖，确认无缺口。

## D-017 磊哥授权 ABCDE 全做（①②③⑤ locked + M1 执行 + gate7 立项 + E-2 grill + HOLD 纪律贯穿）
- **Date**: 2026-07-02 ｜ **Status**: Accepted（执行中）｜ **Type**: Decision-lock + Dispatch ｜ **Owners**: 磊哥「ABCDE都要做哦 我授权了，你自己看分工和边界，三个worker目前空闲」
- **授权解读（边界，防越权）**:
  - **① masking design 岔口 = locked ⭐**：全 token-mask override（已实现 `47ca8cda` + 双异源 CONFIRMED + D-015 复审）。
  - **② E-2 subset = 方向 locked**（真 tokenizer 口径 126,275/159,899 tokens 超 131,072 上限，subset 数学必然）；**实装形态不自拍**——D 项 grill 出 design 决策包上抛细拍。
  - **③ grill Dim10/11/5 = locked**：58 条（F-076~095=20 + F-055~075=21 + A-134~150=17）proposed→locked，级联回写 frontmatter + landing-matrix §4。
  - **⑤ consolidation = 授权执行**：M1 staged PR α(g2)→β(g8)→γ(文档整编支)，每支 CI 绿 + 交叉审 CLEAR → **worker rebase-merge（D-011 先例 + 本次「都要做」明确授权）** → commander gh 一手核销；任一支审出 P0 → 停该支上抛。
  - **C gate7 pipeline 立项**：M1 绿后基于新 main 开 worktree 派单（本轮先备 SPEC）。
  - **D E-2 设计 grill**：%43 素材 + commander 纵切 → design 包上抛磊哥细拍。
  - 🔴 **E HOLD 纪律贯穿（不因「都要做」松动）**：④ tiny-ablation RUN/gate1 真跑/真生成 = 仍 BLOCKED 等单独 run-auth；M2 树清理（破坏性）= 未授权不动；R7 全程守。
- **M1-α 前置**：反向 guard（数据含 loss_mask 而 flag 缺失 → fail-closed；D-015 观察① + hermes P2 独立撞出）由 %45 在 g2-mask 补 commit + 测试，再 push 开 PR。
- **M1-γ port 纪律**：新 branch off main=`ab355f6c`；逐文件语义比较只 port 本分支更新内容；🔴 `gate7-cloud-generator-design.md` 以 main 版（PR #11 含 §10）为准不回退；grill 树 2 件 Dim11/5 port 时 frontmatter 改 locked；禁整支 merge doc-absorption/grill（147 behind 回退风险，baseline-roadmap §2）。
- **分工**: %45=α（guard+push+PR）/ %44=β（push+PR）+γ（文档整编支）/ %43=E-2 素材 / commander=lock 级联回写+Dim10 frontmatter+收稿裁决+E-2 纵切+gh 核销。
- **落点**: 本 D-017 + SPEC-M1A/M1BG/E2 @ `runs/2026-07-02-baseline-roadmap/` + landing-matrix §4 里程碑

## D-018 M1 consolidation 完成 + 验收 PASS（main 范围）+ 验收门抓 regen drift 的修复闭环
- **Date**: 2026-07-02 ｜ **Status**: ✅ Done ｜ **Type**: Merge-closeout ｜ **Owners**: 磊哥 goal「推进到 M1 合流 main 并验收」/ commander 执行
- **合流链（gh 一手核销）**: PR #13 α gate2（3 commits 含反向 guard+test-split fix）→ `99734be6` ｜ PR #12 β gate8 → `d93c59b8` ｜ PR #14 γ 40 件文档整编 → `f3ab165d` ｜ **PR #15 δ 验收修复** → `80ea379c` = 当前 main。main CI Verify SUCCESS ×2（f3ab165d/d93c59b8 亲核）。
- **审计链（每支都有拦截或亲核）**: α 交叉审 FAIL+P0（guard 漏 test split，%43 对抗 fixture 抓）→ 一行修+行为测试 → P0-RESOLVED 复验 ｜ γ commander 亲自语义审（hash 对比 35 逐字节+3 whitespace+2 溯源 frontmatter，零回退）｜ **验收门抓 δ**：gate8 曾直改 generated/ 派生物没改工厂 gen_family_allowlist.py，merge 后 verify-all diff 门现形 → PR #15（工厂实算 tool_count + Makefile regen 重排 tool_contract 先行）→ 重验收原 blocker 消解。
- **验收 verdict**: **PASS（main 范围）**——regen/diff/verify-refs/cross-section/surface/gold/c6-shape/default-scope/python test/contentview-wiring 全绿；唯一残留 = sibling UIUE fixture 对比测试失败 = **环境噪声非 M1 回归**（M1 未动 Tests/Fixtures 任何字节，失败输入与 M1 前相同；UIUE 树 R7 隔离分叉本预期，M4 收口时消解）。豁免单列不冒充全绿。
- **教训沉淀**: lessons-learned **K 段 4 条**（per-branch CI≠全量验收 / 交叉审对抗 fixture 破双盲×2 实证 / staged PR+hash 语义审 / worker 主动回报纪律）。
- **Consequences**: 训练前置基线全部在 main（gate2 token-masking 真 enforce + 反向 guard 三 split / gate8 562 工厂实算 / 28+2 件 grill 语料 / commander-log / 两基线文档 / CURRENT 新版）。M2 清理清单已备等授权执行；M3 D25 裁决=收（待开小 PR）；E-2 grill round 进行中（W1/W3 done + D9 done + W2 跑中 → 消减综合上抛）。
- **落点**: 本 D-018 + lessons K + baseline-roadmap/CURRENT/MEMORY 同步刷

## D-019 磊哥拍 E2-A~E locked（附 2 硬条件）+ gate7+E2 Phase-1 construction 立项 + ④暂不放 + M2/M3/R7 处置
- **Date**: 2026-07-02 ｜ **Status**: Accepted（执行中）｜ **Type**: Decision-lock + Dispatch ｜ **Owners**: 磊哥全项拍板 / commander 拆解执行
- **E2-A~E = locked_with_conditions**：原则全采纳。🔴 **条件一**：E-2 综合/设计包/README/D-018/CURRENT/baseline/blueprint/landing 刷新 → **一个小 PR 入 main**（「E-2 ratification + route-board refresh」PR，%44 执行 γ-port 模式 off main=`80ea379c`）。🔴 **条件二**：E2-D 只授权 **Phase-1 construction**——**不授权 runtime NLU / 不授权真生成 / 不授权 C6 acceptance**（写死进所有 SPEC）。
- **gate7 pipeline + E-2 manifest 联动 = 立即开**：🔴 必须基于 origin/main=`80ea379c` **新 worktree**（禁止在 doc-absorption 主树写实现）。范围四件 = manifest codegen / grammar artifact 预编译 / C6 add-only schema / 六轴 digest receipt + gate7 generator pipeline 代码闭环（build 不 run）。切三片三 worktree 三 PR（M1 staged 模式）：G7A(%45)=E-2 manifest codegen+静态预算门+grammar artifact ｜ G7B(%43)=C6SubsetContext add-only schema+subset_failure_class+六轴 digest receipt ｜ G7C(%44，先做 ratification PR 再接)=generator 编排层（多源桩+vendor-enum G1 门+执行契约+四确定性门）。
- **④ tiny-ablation run-auth = 暂不放**（磊哥：等 gate7 construction + E-2 Phase-1 **merged** 再授权，防 E 节点在 C/D 没物理闭环前点火）→ blueprint §4 节点序 E 前置条件更新。
- **M2 = 只 dry-run 不删**（指挥官分支 E-2 docs/D-018 未进 main；等 ratification PR 合完再执行删除）。**M3 D25 = 延期**（非 LoRA 关键路径，不抢上下文）。
- **R7 = 现在备续签/真跑签字模板不等 7-15**：commander 亲自产出 R7 renewal + tiny-ablation run-auth checklist，**状态保持 draft/unsigned**。
- **落点**: 本 D-019 + E-2 全组文档 status→locked_with_conditions + landing-matrix 里程碑4 + SPEC-G7A/B/C + R7 renewal draft
- 🔴 **UPDATE（磊哥收敛顺序锁死，2026-07-02）**：① **#16 RAT PR 先行**：CI 绿 + spot audit + merge 是第一收敛点；G7A/G7B 可继续写**不得越过 RAT 合入 main**；🔴 **G7C 暂不开**（撤销 %44 接力指令，改 standby）——等 G7A manifest 接口 + G7B schema/receipt 口径稳定再建。② 🔴 **G7B 消费链硬要求**：禁 wrapper-only 字段存在——必须行为测试证明**现有 C6 消费链真读 subset 字段**（构造带字段 case→断言消费路径输出生效+消费点 file:line），否则回执 honest 标 `adapter_receipt_proof_only`，禁称「C6 schema fully integrated」（gate2 dead-field 教训的 enforce 化）。③ **敏感参数冻结上抛**：7200 cap / digest 口径 / degraded_clarify 策略 / C6 subset 接入方式——任何改动 BLOCKED 上抛磊哥人审，worker/commander 均禁自改。④ M2 仍只 dry-run；④tiny-ablation/R7 仍 HOLD。三 worker 已收指令确认。

## D-020 G7A+G7B 审计绿合流 main + G7C 开闸 + G7D 补片（E-2 Phase-1 construction 收尾中）
- **Date**: 2026-07-02 ｜ **Status**: Accepted（执行中）｜ **Type**: Merge-milestone ｜ **Owners**: commander 按 D-019 收敛序执行
- **合流（gh 一手核销）**: G7A PR #18（manifest codegen 18,260 entries + 预算门 cap7200 + grammar artifact；XAUDIT 抓 **B1 手写表 BLOCKER** → contract 文件模式修复 `contracts/subset-grouping.yaml`[authored_design_input 定性+双向闭包 fail-closed+S-201 entry 零动] → delta 复审 **B1-RESOLVED** entry payload 逐字节等价）→ `cc5b1aa8`+`c93efaee` ｜ G7B PR #17（C6SubsetContext add-only + 六轴 receipt；XAUDIT **CLEAR** 消费链行为证明非 dead field，verdict 诚实 `adapter_receipt_proof_plus_runner_extension_behavior_proof` 不称 fully integrated=守磊哥硬要求）→ `2b006b8a` = **当前 main**。
- **进行中**: %45 merge 后验收（K.1 标配）→ 接 **G7D**（design 包 Phase-1 收尾：C5 训练样本 builder 按 manifest 装载 + 样本 metadata 记 digest[S-206/S-207 locked] + fail-closed 禁双路径）；%44 **G7C 开闸**（磊哥条件满足：A/B merged 接口稳定；SPEC 已补真实接口事实）。%43 待 C/D 落地接交叉审。
- **审计战绩累计**: 本日交叉审/验收门共咬住 **5 个真问题**（gate2 dead field[前日]/guard 漏 test split/gate8 派生物没改工厂/E-2 包丢 train target 轴/G7A 手写表）——对抗 fixture + 验收 diff 门 双机制全部生效。
- **冻结确认**: cap 7200/S-201 字段组/degraded_clarify/C6 add-only 接入——四项全程零改动（两轮审计逐项 grep 确认）。
- **落点**: 本 D-020 + R7-draft B.1 前置表刷新 + SPEC-G7D
- 🔴 **UPDATE（磊哥 2026-07-02：hermes 终审安排）**：E-2 subset-policy 实装 + gate7 generator pipeline 代码闭环两大任务**完成后**（G7C/G7D merged + 验收绿），安排 **hermes 跨厂商异源终审**（cross-vendor-final-audit 铁律：≥3 厂商并集，codex 交叉审已有 → hermes=第二厂商，范围 = G7A/B/C/D 全体 = manifest codegen/预算门/grammar artifact/C6 subset schema/六轴 receipt/generator 编排/C5 builder 装载）。**hermes 现在待命不派**；触发点 = 两大任务合流验收后。
- 🟢 **UPDATE（G7C/G7D 合流 + hermes 终审触发，2026-07-02）**：G7C PR #19（XG7C CLEAR：R7 blocked_r7 桩/G1 同 vendor fail-closed/labeler LLM 零参与/四门行为全过）→ `0ff56e06` ｜ G7D PR #20（XG7D PASS_WITH_NOTES，唯一 P2-watch=`subset_policy_digest` 取整文件哈希 vs meta 内 grouping_contract_digest——**更强口径不冲突**，按磊哥 digest 冻结令报备存档不改）→ `1d822961` = **当前 main**。**两大任务（E-2 subset Phase-1 实装 + gate7 generator pipeline 代码闭环）全部合流**。%45 跑 merge 后验收中；🔴 **hermes 跨厂商终审已出击**（磊哥 standing order，background agent `hermes-g7-final-audit`，只读 worktree `MAformac-hermes-audit`@1d822961，范围 G7A/B/C/D 全体 + dead-field 同构扫描，产出 HERMES-FINAL-AUDIT-G7.md）。今日 PR 合流累计 **9 支**（#12-#20）。

## D-021 外审执行位模式（磊哥定）：commander 只 tmux 掌控 worker，外审全下沉 worker，%44 升临时项目助理
- **Date**: 2026-07-02 ｜ **Status**: Accepted ｜ **Type**: Collaboration-mode ｜ **Owners**: 磊哥三连指令
- **模式**: ① commander **只通过 tmux 掌控 3 worker**，不自己直跑外部审计/外部 LLM 调用（subagent CC 也不用于此——hermes-rescue subagent spawn 的是 Claude 家族=假异源，已 shutdown_request 关闭 + kill %51 pane 保 2×2）② **GPT Pro 外审、hermes 异审全部交 worker 自己跑**（worker 在 codex CLI 显性调用 `~/.codex/skills/hermes-cli-glm52-code` / gptpro 技能——codex 环境 `--prompt-file` 正常且 worker 能盯全程重试）③ **%44 升级临时项目助理（外审协调官）**：外部调用执行+盯守+收产出+初步 findings 整理。
- **佐证**: commander 直跑 hermes 两次：第一次 hermes CLI 本体 stash 冲突炸（已可逆修复：`git reset --merge` 中止失败 pop，stash@{0} 18 文件原封保留供磊哥重处理）；第二次回稿仅 **284 字节=废稿**（留档 `HERMES-FINAL-AUDIT-G7-commander-direct.md` 勿引）——印证 worker 盯守模式更可靠。
- **落点**: 本 D-021 + %44 首单（hermes G7 终审，质检门 <2000 字节=废稿重试）+ memory 更新
- 🔴 **UPDATE（磊哥泛化 D-021，2026-07-02）**：助理角色**只是临时**——commander 可**随时流转 3 worker 角色**：调研/设计/联网搜证/grill/脑暴/codex 自审/外部 gptpro-hermes 审计/**开发任务（最多）**/**架构设计（最多）**/数据-训练-评测-测试，**一切执行下沉 worker**；commander=纯编排+裁决+记忆+收稿亲核（「你就是上帝即可」）。角色帽子按任务派单时指定，不固定编制。

## D-022 hermes GLM-5.2 终审收稿（REQUEST_CHANGES）+ 辩证吸收 + 三线修复派发
- **Date**: 2026-07-02 ｜ **Status**: Accepted（修复中）｜ **Type**: Cross-vendor-audit-absorption ｜ **Owners**: hermes 审 / commander 亲核裁决 / 三 worker 修
- **hermes verdict = REQUEST_CHANGES**（真异源 GLM-5.2，%44 助理执行位跑通；产出磊哥手转）：**P0=0**。
- **P1（ship-blocking，commander 亲核 `C5LoRATraining.swift:2861` 坐实）**：G7D loader 取首 entry 的 subset_policy_id 当真值**零校验**——wrong-policy manifest 被静默接受产样本（= SF-13 manifest 混训风险的入口）。hermes **亲手构造 wrong-policy probe 实跑暴露**（非读码推断）。🔴 **二层 catch**：XG7D 交叉审曾声称验过「policy 失配」三态给 PASS_WITH_NOTES——被 hermes 证伪 = **交叉审的验证声称本身也要抽核**（审计的审计，异源层级价值第 6+7 例）。
- **P2×2**：C6 dead fields（`expectedUnsupportedClass` 只 decode 零消费 / `isModelFailure` 恒 false）+ G7 no-op（`timeoutMilliseconds` 未用 / `rawPayload` 只写不读）——dead-field 同构扫描的直接收获。
- **CLEAR 项**：分组血缘/双向闭包/562 并集/预算门/唯一 degraded pair/add-only 零侵入/六轴 receipt blocked/R7 无网络路径/G1 门/labeler LLM 零参与/四门/冻结参数——全项亲跑复现命令给证。
- **辩证吸收**：P1/P2 全收（无一撞已决，均为实现漏）；steelman 零驳回。**修复三线**：%45 P1（policy authority 校验 + hermes probe 固化为永久测试）/ %43 P2-C6（补真消费禁删字段——两字段是 S-210 locked 的 expected 侧载体）/ %44 P2-G7（接行为或删+说理）。修后交换交叉审 + hermes delta 复审（%44 助理执行）→ staged merge。
- **落点**: 本 D-022 + `HERMES-FINAL-AUDIT-G7.md`（%44 产出）+ 三修复 SPEC（tmux inline）

## D-023 hermes findings 修复轮进展 + %43 卡死救援 + hermes 审计点冻结
- **Date**: 2026-07-02 ｜ **Status**: Accepted（#23 修复中=唯一关键路径）｜ **Type**: Fix-round + Ops-rescue ｜ **Owners**: commander 编排/三 worker 执行
- **修复轮战果**: P1 PR #22（policy authority `e2-lite-v1` 双侧一致 commander 亲核 + hermes probe 固化永久测试）交换审 **A-/PASS → MERGED `487ec2b3`** ｜ P2-G7 PR #21（timeout/rawPayload 接进 receipt 行为非删）交换审 **B+/PASS_WITH_WATCH → MERGED `a8fcd245`**（watch：timeout=收尾归一化非抢占，Phase-1 全 mock 可接受；#22 watch：Swift 侧 authority 常量是 grep 验证的复写串，后续可加等值测试硬化）｜ P2-C6 PR #23 交换审（%45）**REQUEST_CHANGES/HIGH**（第 8 咬）：**S-210 第三层 `global_unsupported` 无可达成功路径**（正确拒识被误判 mismatch）+ MEDIUM stats 账目缺口 → %43 修复中。
- 🔴 **%43 卡死救援实录（PROVEN 进宪法 §8）**: HIGH 修复中 %43 陷 **47 分钟死循环**（auto-compact 后自我 grounding 打转）。判定=行为探测（工作树零文件活动 20min+ / PROGRESS 消息排队送不进 / Working 计时仍走）；救援阶梯=ESC→双ESC→Ctrl-C 全失效（TUI 输入环死）→ `tmux display-message pane_pid` 找子进程 **kill codex 进程** → 重启触发 codex 自动升级→**半装**（缺 `@openai/codex-darwin-arm64`）→ 按报错 `npm install -g @openai/codex@latest` 重装 → fresh codex 自包含重派（SPEC 承上下文，工作树干净零丢失）。
- **hermes 审计点冻结**（磊哥令）: 后续不安排 hermes 审计，下个点等磊哥通知；%44 助理 standby 解除。
- **收敛点**（磊哥令「完成 hermes 审计修复后先停下来」）: #23 HIGH 修 → %45 delta 复验 → merge → 验收 → **停下等磊哥**。
- **落点**: 本 D-023 + swarm-commander §8 补条 + swarm-runs UPDATE + MEMORY as-of
- 🎉 **UPDATE（hermes 修复闭环收口，2026-07-02 深夜终态）**：#23 HIGH 修复（`actualUnsupportedClass` 三层可达+stats 账目，C6SubsetContextTests 18/0）→ 原审计员 delta 复验 **HIGH-RESOLVED** → MERGED `aac84de9` = **终态 main**。终验收（%45）= **PARTIAL_SIBLING_NOISE**：pull PASS / main 全机械门 PASS / hermes 三目标套件全绿（C5 53/0·C6Subset 18/0·G7 8/0）/ 全量 swift 唯一失败=已知 sibling UIUE fixture 噪声（pre-existing，M4 消解）——**main 范围绿**。当日终账：**13 支 PR 合流（#12-#23）+ 审计体系咬 9 真问题**（+S-210 第三层不可达）。🔴 **按磊哥指令停下**。桌上待磊哥：④ tiny-ablation 签字包（物理前置全齐，R7 draft Part B 就绪）/ M2 删除授权 / R7 续签（7-15 到期）/ 下个 hermes 审计点 / M4 UIUE（sibling 噪声根治点）。
- **UPDATE（回报路由固化，2026-07-02）**：磊哥令——后续所有 worker 派单**必须显性写**「向 %42 汇报」（tmux-bridge 发 REPORT/PROGRESS/BLOCKED 到 commander pane），派单缺这句=不合格。已落宪法 §8 + memory 第 3 条强化 + 三 worker 常设通知（ACK-RPT42）。

## D-024 🔴 tiny-ablation 真跑授权（磊哥「全部授权」）— R7 线第一次真训练动作点火
- **Date**: 2026-07-02 ｜ **Status**: Accepted（执行中）｜ **Type**: Run-authorization ｜ **Owners**: 磊哥口头授权（原话「全部授权 推进tiny ablation 真跑」，签字包+run plan 全文贴出验 scope 后）/ commander 代录+执行编排
- **授权范围**: 仅 `tiny-ablation-run-plan-adjudication-A.md` 全文（tiny-only：40 正例样本/rank16Mainline 渲染原样/34-case tool_call 探针/门=代码常量 empty<5/34）。**成功不自动开 wave-1；失败进 Dim10 branch 不改阈值不扩样本；重跑要新授权**。scoped waiver：sibling 噪声仅豁免本轮前置。
- **执行链**: Step 0 harness 解锁小 PR（%45：`.real` 分支绑签字文档引用+测试→CI→审→merge）→ Step 1-4 真跑（worker 执行+每步 receipt 回 %42+commander 亲核）→ verdict 上抛磊哥。
- **落点**: 签字区已录（B.3 signed_run_authorized/40）+ 本 D-024 + run 产物 `runs/tiny-ablation-adjudication-A/`

## D-025 常设授权：run-blocking 机械 bug commander 直拍直修不上抛（磊哥「别老停下来」）
- **Date**: 2026-07-02 ｜ **Status**: Accepted ｜ **Type**: Standing-authorization ｜ **Owners**: 磊哥「能不能不要设置这么多阻塞点 顺畅跑起来 指挥官别老停下来」
- **规则**: 已授权 run 期间遇 **机械性 blocker**（代码 bug/环境/工具链——不碰阈值/样本量/配方参数/scope 边界四红线）→ **commander 直接授权修复 + 固化测试 + 继续跑**，事后 receipt 汇报；四红线才上抛磊哥。BLOCKED 上抛从「默认动作」改为「仅四红线」。
- **首例**: tiny-ablation Step2 exit 66——`'TokenizerWrapper' object is not callable`（mlx-lm `load()` 返回 wrapper 不可直调；gate2 修复期 self-test 合成 logits/Swift 测试 dummy model 均不触 tokenizer 真调用路径，第一次真跑才现形 = re-audit 残留 P1 预言的正确性残留，fail-closed 正确拦下）。修法=`getattr(tokenizer, "_tokenizer", tokenizer)` 兼容 + 单测。机械修复，非配方/阈值/scope 改动。
- **落点**: 本 D-025 + 宪法 §8 补条 + run receipt

## D-026 🔴 裁决-A verdict = BLOCKED（34/34 NO_TOOL 重复）+ 归因坐实 = masking span 语义误用（配方级，修复上抛）
- **Date**: 2026-07-02 深夜 ｜ **Status**: Accepted（失败门纪律执行中，重跑等磊哥新授权）｜ **Type**: Adjudication-verdict + Dim10 归因 ｜ **Owners**: commander 亲核归因 / %45 执行 run
- **run 全链实录**: v1 dev-selection 吸干→v2 masking_complete 未实装→v3 NONFINITE(1024 截断除零)→v4 8192 Metal OOM→v5(batch1/grad16+grad_checkpoint+seq5120) **600 iters 训练完成零 NONFINITE**（loss 2.11→0.16 区间震荡，adapter 落盘）→ 34-case 探针全 dump → harness real verdict = **blocked（emptyToolCallOutputs=34/34 ≥ 5）**。失败门纪律全程守（未改 LR/rank/scale/clip/iters/样本/阈值，未重跑，未开 wave-1）。
- **归因（commander 一手下钻 train.jsonl+probe dump，非聚合推断）**: ① probe 显示模型**非沉默**——输出 `NO_TOOL.NO_TOOL...` 无限重复（与 θ-α 空输出不同型）② train.jsonl 44 条 positive 的 `trainable_spans` **只含 function_name 碎片**（例：71 字符 assistant 全文只放行 20 字符工具名；字符覆盖率 median 29.7% min 12%；全集仅 209 trainable tokens）——`<tool_call>` 包裹/JSON 骨架/闭合全被 -100 掩死 ③ 模型唯一被完整监督的输出形态=NO_TOOL → 学会且只会它。**根因 = P1-C 早已锁的「masking 三形态实为两类机制」被实现混淆：function/arg masking 本是【数据增广】（换名防死记），却被做成【loss span】（只训 name 碎片）；train_on_turn 的 loss-mask 正确语义 = 掩 prompt 训全 assistant turn（业界标准 SFT masking，home-llm 同款）**。
- 🎯 **价值**: tiny-ablation 用 ~50 分钟真跑在 formal train 前抓出 masking 语义级配方缺陷——若直接 wave-1 = 第三次 0/34。裁决门体系再次自证（D-003「严禁跳 gate」的活证据）。**范式（D-domain 具名工具可学性）未被证伪**——监督信号残缺时模型无从学起，本 run 不构成范式判决。
- **修复提案（配方红线，上抛磊哥）**: ⭐ **A**：trainable_spans 改为**整个 assistant 输出 span**（train_on_turn 正确语义；prompt 掩、assistant 全训；think span 仍掩=gate2 think-mask 保留；function/arg 碎片 span 语义归还给数据增广形态=wave-1 的 augmentation 实装）｜ B：显式枚举包裹+name+args 全 span（≈A 的枚举版）。两案都不动 LR/rank/scale/iters/样本/阈值。**重跑同 44 样本 = 磊哥新授权**（失败门纪律）。
- **落点**: 本 D-026 + verdict.json/probe/RECEIPT-TINY-ABLATION 一手 + 上抛磊哥

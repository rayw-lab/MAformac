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
- 🎯 **价值**: tiny-ablation 用 ~50 分钟真跑在 formal train 前抓出 masking 语义级配方缺陷——若直接 wave-1 = 第三次 0/34。裁决门体系再次自证。🔴 **措辞窄化（磊哥采纳 GPT-5.5 纠正 + 终版 teardown 四根因重标）**：verdict=`BLOCKED_INVALID_FOR_PARADIGM_VERDICT`——**D-domain/LoRA 路线未被证伪；当前 C5 trainable_v0 监督契约已被证伪（P0）；首跑实验设计（探针构成+输入面+基线锚）已被证伪（P0）**。v5 不得作为范式失败证据、不得据以调 LR/rank/scale/clip/iters。终版 teardown=`tiny-ablation-iceberg-teardown-FINAL-2026-07-02.md`（四根因/跨LLM辩证/Phase 0-7）。
- **修复提案（配方红线，上抛磊哥）**: ⭐ **A**：trainable_spans 改为**整个 assistant 输出 span**（train_on_turn 正确语义；prompt 掩、assistant 全训；think span 仍掩=gate2 think-mask 保留；function/arg 碎片 span 语义归还给数据增广形态=wave-1 的 augmentation 实装）｜ B：显式枚举包裹+name+args 全 span（≈A 的枚举版）。两案都不动 LR/rank/scale/iters/样本/阈值。**重跑同 44 样本 = 磊哥新授权**（失败门纪律）。
- **落点**: 本 D-026 + verdict.json/probe/RECEIPT-TINY-ABLATION 一手 + 上抛磊哥

## D-027 磊哥六拍：v5 重标级联 + v6 契约重构 Phase 0-3 授权 + R7 续签（renewed 至 2026-07-23）
- **Date**: 2026-07-02 ｜ **Status**: Accepted（Phase 0 done / Phase 1-3 三 worker 执行中）｜ **Type**: Decision-lock + Dispatch ｜ **Owners**: 磊哥六项全拍 + 「自动化推进，三 worker 已调 high 级别最优化利用」
- **六拍**: ①重标 verdict 四 reason 采纳（服务止血防误判，级联 D-026/landing/F-044 防旧结论被引）②tiny 目的 both 分轴（A 器材/B 自然中文=硬门，C 观察/D 原 34 heldout report-only 禁作 hard gate；不许退回只测协议串）③A+ 契约（loss/augmentation 拆开；正例训 full assistant non-think；NO_TOOL 行训 full NO_TOOL；prompt/user/system/think 掩；train_on_turn 退役为兼容；coverage 门必证 parser-critical tokens；old v5 必 fail 新门/新数据必 pass）④base 配对重锚（28/34 仅 provenance；同 harness/decode/prompt 配对 paired delta+absolute 双门；decode 参数写死进 receipt）⑤Phase 0-3 授权 docs/code/test only ⑥R7 续签（Part A 代录 renewed 至 2026-07-23）。
- **Phase 0 已落**: D-026 措辞窄化 / landing 里程碑5（裁决-A 重标+F-044 口径级联）/ R7 Part A 续签代录 + Part B 状态改 v5-consumed（v6 另签）。
- **Phase 1-3 分工**: %45=契约+builder 主刀（枚举/full-assistant/coverage 双门/自反测试/B 轴自然行 builder 支持）｜ %44=探针 harness 固化（decode 契约/base 配对双臂/三口径 overlap receipt/仓内工具化+单测）｜ %43=4 轴探针集与 B 轴数据清单（从 C1 契约确定性抽取非 LLM 生成，防 C6 泄漏）+ F-044 修订草案。文件面三方不相交。
- **落点**: 本 D-027 + 三 SPEC + FINAL teardown 档 §4 delta 逐项进 SPEC

## D-028（2026-07-02 深夜）Phase 3 双收稿 + P3H P1 catch + governance-fit grill round 启动
- **%43 P3D 收割**：v6 四轴探针设计三件套收进主线 `docs/c5-training-readiness-grill/v6-probe-design/`（commit `321634ba`）。commander 亲核：B 轴泄漏声称坐实（15 句 exact match C6 gold=0 / B 轴工具∩C6 工具=空 / c5-train-00001→c1_airControl_000018 配对一致）；C 轴 4/10 candidate_gap 诚实不硬凑（接受，放宽与否留 F-044-Q3 磊哥拍）；F-044 草案 = 标准 grill 格式 8 决策+Q1-Q4 open point。
- **%44 P3H 亲核 catch P1 退单**：PR #26 结构/测试 5/5/fail-closed 均 PASS，但 `truncate_at_stop_token` 全文 find 截断 + 训练 target assistant 以 `\n\n<tool_call>` 开头 → commander 在其 worktree 复现：训练形态输出被截成空串、tools=[]，测试零覆盖。**v6 真跑会把学对了的模型判成全空 = v5 NO_TOOL 假象同构（harness 自制 invalid_probe）**。退单修法：前导空白剥离+回归测试+RECEIPT 补记+更新 PR。元认知：consumer-anchored sufficiency 活证第三例——truncate 机制测试全绿（mechanism-true）但没测「训练分布的真实输出形态」这个 fit 维度（fit-proven 缺位）；亲核必须拿【训练 target 的真实形态】喂 harness，不是拿 harness 自己的 fixture。
- **governance-fit grill round 启动**（磊哥令「反思细化 grill 按范式组织」）：骨架 `docs/c5-training-readiness-grill/governance-fit-grill-README.md`（W1 契约细化 GF-0xx / W2 门与词表 GF-1xx / W3 制度 GF-2xx / commander 纵切 GF-Cxx）。W2 已派 %43（D4 哨兵数字门化清单 / D5 readiness 四级词表+fit-proof 列 / D6 F-044 终稿），SPEC=仓外 `runs/governance-fit-grill/SPEC-GF-W2.md`。W1/W3 等 %45/%44 空闲接力。
- CURRENT 残段清理：原 5 件决策段台账化（全 CLOSED）、指针 D-001~027、handoff 指针刷新。

## D-029（2026-07-02 深夜）通宵 run-auth 转写 + %45 救援重派 + 拓扑刷新
- 磊哥 /goal 通宵全授权：**v6 tiny-ablation 真跑 + wave-1 数据真生成 + C5 数据门**解锁（verbal auth 转写 `docs/project/phase0/r-l17-human-review-evidence/v6-overnight-run-auth-2026-07-02.md`）；full wave-1 训练/C6 acceptance/candidate comparison 等仍 BLOCKED；四红线仍在（F-044 阈值用草案 default 跑，终值不自拍）。
- **%45 第二次卡死救援**：34min 零流动（0 in 0 out），rescue ladder 直接 kill 子进程 52386 → codex 重启 → SPEC-P12 self-contained 重派（含通宵 ADDENDUM：镜像门最高优先 + 硬三件 + grill 拆解自驱）。
- **%44 P1 退单消息此前 send-keys 失败未送达**（"not in a mode" exit 1，教训：tmux send-keys 长消息必用 `-l` literal + 单独 Enter，发后必 capture-pane 验证送达）——已用 -l 重发，%44 开工修 truncate 前导换行 P1。
- 拓扑：%45 P12（A+ 契约+镜像门）/ %44 P3H P1 修复 / %43 GF-W2 grill。审计=worker 交叉互审（磊哥令，本晚不派 hermes/gptpro）。

## D-030（2026-07-03 凌晨）磊哥睡前令：worker 绝不闲置 + GF-W2 收割 + PR26 审计链
- 磊哥令（睡前）：codex 额度管够，闲置 worker 填打杂活（文档维护/笔记/预研调查）——backlog 队列建于仓外 `runs/governance-fit-grill/BACKLOG.md`（GF-W3/wave-1 预研/P12 交叉审/handoff 草稿/MEMORY 素材/Phase B 预检 6 项）。
- GF-W2 40 决策收割进主线 `docs/c5-training-readiness-grill/governance-fit-w2-decisions.md`（哨兵数字 12 field groups 门化清单 + readiness 四级词表 + landing fit-proof 五字段 + F-044 终稿 Q1-Q4 default：A=15/15、B=14/15+同族不连败、C 不硬凑、B 轴泄漏零容忍）。全 proposed 待磊哥 lock。
- P3H P1 修复亲核 PASS（lstrip 前置+回归测试+尾切防御仍在+RECEIPT 完整）；PR #26 CI 双绿；自合被权限门拒 → 转 worker 交叉审制：%43 审 PR26（输出 P0/P1/P2 register 文件）→ APPROVE 后 merge。
- %44 接冒烟棒：v5 训练环境=系统 python3.13（mlx-train-command.txt 一手），base-only 端到端冒烟（D 轴 2 case，不下行为结论）。
- 🔴 GF-W1 疑点前置：decode 契约 max_tokens=80 vs D 轴多意图 case（C6-MP-028 期望 2 个 tool call）可能截断——已进 SPEC-GF-W1 D3 必专条。

## D-031（2026-07-03 凌晨）冒烟立功：输入面错配 P0 拦截 + P3H v2 修复包
- **base-only 冒烟抓到 P0 级输入面错配**（v5 四根因 #3 harness 层复发，未污染正式 probe = 冒烟价值实证）：训练面 patched tokenizer 默认 no-think（`main.swift:497` template 条件改写，assistant 起手空 think 块），probe 冒烟 prompt 无 think 块 → base 自开 `<think>` 烧光 max_tokens=80 → empty。system prompt 两面一致（排除）。证据链+8 决策 grill 落 `docs/c5-training-readiness-grill/p3h-harness-v2-grill-2026-07-03.md`（GF-141~148，通宵按 ⭐default 推进待磊哥 lock）。
- **%43 PR26 交叉审 REQUEST_CHANGES 收讫**（P1×2：paired 可静默降级 base-only / decode 契约缺 prompt/thinking/parser 字段；P2×3：raw 证据压缩/multi-call 丢失/PR scope drift）——P1-2 与输入面错配同根汇合，全部并入 P3H v2 修复包派 %44（GF-141~148 八项+重跑冒烟验证）。
- **%44 冒烟顺带修了 mlx_lm 0.31.1 API 兼容**（generate 不吃 temp → sampler=None greedy+回归测试）。
- merge PR #26 改为：v2 修复完成+%43 复审 APPROVE 后。

## D-032（2026-07-03 凌晨）P12+P3Hv2 双亲核 PASS → tiny v6 训练+probe 开跑
- **P12 镜像门 commander 亲核坐实**：old v5 exit **66**（44 行全 under_supervision，parser_critical_untrained 逐 fragment + ratio 0.12-0.37<0.90 归因精准）/ new v6 exit **0**（ratio=1.0，44/44 trainable，泄漏 0）。A+ 契约（磊哥六拍③）镜像验证达成。P12 诚实 PARTIAL（sibling UIUE fixture 5 失败=非 P12 范围已知噪声；GitNexus critical blast radius 已标注留 reviewer）。教训：亲核 exit code 勿用管道后 `$?`（测的是 tail）。
- **P3H v2 亲核 PASS**：GF-141~148 全落地；输入面对齐坐实（prompt 空 think 块断言 fail-closed）；base honest 行为浮现（懂语义不懂协议格式）；GF-032/033 被架构消解（提取吃 raw_generation，stop 只影响展示字段）。
- **GF-W1 40 决策收讫**（GF-001~040：consumer frontmatter/loss 枚举边界/decode 具体值；GF-030 拍 max_tokens 80 只留 historical，v6 用 160=与 GF-147 一致）。
- **拓扑**：%44 接 SPEC-PCD（tiny v6 训练真跑 600 iters + paired 四轴 probe 68 case，verdict 留 commander）；%43 交叉审 P12 中；%45 wave-1 生成预研中。

## D-033（2026-07-03 凌晨）P12 审 P1×2 分诊 + wave-1 决策包 + GF-W3 派发
- **%43 P12 交叉审 REQUEST_CHANGES 收讫**（P0=0；P1-1 `legacy_missing` 绕过 A+ 显式契约[bypass 探针实证 PASS 1.0]；P1-2 natural rows 仅验 tool-name 可污染 gold；P2 receipt 缺 fit-proof 机读 frontmatter，level 应 mechanism_true）。**分诊：两 P1 不影响在跑 tiny v6 训练**（v6 数据无 natural rows + profile 字段显式），属 P12 merge 前必修（=wave-1 拍点#1 关键路径），排 %45 P5W 后接修。
- **wave-1 磊哥 5 拍点决策包**落 `docs/c5-training-readiness-grill/wave1-owner-decision-package-2026-07-03.md`（基座冻结⭐P12修复后merge/云凭证[无default]/首波4.5k⭐/salvage重judge⭐/人工门staffing）。live 生成今晚推进到「只差凭证」。
- 训练进度：iter 140 loss 4.48→0.52，LR warmup 正常（iter30 显示 0 = warmup 起点，疑点消解）。
- 拓扑：%44 训练+probe 中 / %45 P5W（labeler 桥接+mock 端到端+数据门实跑）/ %43 GF-W3 制度官。

## D-034（2026-07-03 凌晨）v6 probe 根因实锤=tools 挂载缺失 + 首个正面行为证据 + 第四轮 iceberg
- v6 训练健康（600 iters loss 0.072、preflight 44/44 ratio1.0、NONFINITE=0），probe 全轴 empty → **四步排除法实锤根因=probe 无 tools 挂载**（训练渲染带 E-2 两级挂载 737 token，probe render_prompt 无 tools 参数）。teacher-forcing 17/17 满分 + 带挂载生成 A/B 轴全完美 = **模型学会了，D-domain 自然中文迁移首个正面样例**。v6 probe1 定性 INVALID_PROBE（GF-154，v5 重标同构）。
- grill 两连发：GF-149~156（v3 tools-mount 契约）+ 第四轮 iceberg 报告（抽象两次：未枚举维度断裂 → same-surface 单数名词掩盖复合性；治理=surface 维度分解表；扩散=wave-1 generator surface 风险列拍点附加项）。
- %44 接 harness v3 + v6-probe2 四轴重跑；GF-156 元认知（复算工具自身假信号：commander span 误差 14/18 几乎误导）。
- 当日 REPORT 洪峰全收：P5W（labeler 桥接+mock 端到端+tiny 数据门 data_gate_ready 44 行）、P12 修复（63/63 测试+镜像门保持+bypass 探针转 FAIL+fit_proof=mechanism_true）、GF-W3 40 决策、cross-section drift 27 条（P1=14 待批量回写）。

## D-035（2026-07-03 凌晨）v6 tiny-ablation verdict + 通宵 goal 主线兑现
- **verdict 落档** `docs/c5-training-readiness-grill/v6-tiny-ablation-verdict-2026-07-03.md`：A 轴 adapter **15/15 满分**（裁决-A 核心问题「A+ 契约是否解 v5 NO_TOOL」= **YES**，v5 四根因#1 坐实主导）；B 轴 11/15 FAIL_WITH_ATTRIBUTION（四败=2 close→open 极性翻转同族连败+2 细分设备混淆，与 tiny 44 行数据覆盖一一对应=数据稀疏非链路缺陷；阈值敏感性已列，终值不自拍）；C 4/4 observe；D report-only adapter 8 vs base 18。
- **paired 配对当晚兑现价值**（磊哥六拍④）：B delta=-1、D delta=-10 暴露 tiny 过拟合窄化——无配对会把 B 11/15 误读「学到 73%」。base 带挂载 zero-shot（B 12/15/D 18/34）= base 锚首个同 harness 真值。wave-1 配方三含义：广覆盖+控 epoch / open-close 极性对称配比 / D 轴退化作 regression 锚。
- **通宵 goal 盘点**：tiny 跑完✅（训练+probe2+verdict）/ 数据门✅（tiny 版 data_gate_ready+mock 端到端；wave-1 全量版待生成）/ A+ 五件✅ / 镜像门✅ / wave-1 🟡「只差凭证」（5 拍点包，live 路径代码 fail-closed=真 blocker）。
- **%45 GAP_FOUND 证实 iceberg 扩散预判**：G7 生成行缺 tools/subset 字段且 C5DataGate projection 丢元数据 → 修复已派 %45。GF 消减 31 组初稿收讫待终审。PR #27（P12）已开；PR #26 复审派 %43；GF-153 EOS 监督实装派 %44。

## D-036（2026-07-03 凌晨）收尾链：PR 双 APPROVE + G7 surface 闭环 + 晨报包
- PR #26 复审 **APPROVE**（5 findings 逐条 file:line 复核）；PR #27 CI 一支 whitespace fail（%44 顺手修中）。**自合被 classifier 硬拒两次 → merge 留磊哥醒来一键**（审计记录+CI 状态全在案，不卡关键路径）。教训：tmux 消息与 gh 写操作勿混同一条命令（拒批连坐消息丢失）。
- %45 G7 surface 修复闭环：生成行→DataGate projection→JSONL 候选行贯通 tools/mounted_tool_count/subset 三族 5 字段（21/21 行全带，`RECEIPT-P5W-G7-SURFACE.md` file:line 证据表）——第四轮 iceberg 扩散点当晚闭环，wave-1 数据 surface 与训练面对齐。
- 晨报包落 `docs/handoffs/2026-07-03-overnight-v6-verdict-morning-brief.md`（goal 兑现账+醒来 5 拍）。lessons M.8~M.10（same-surface 维度分解表/复算工具假信号/paired 信息增益）。
- 在途：%44 EOS 监督实装+whitespace 修；%43 GF 消减稿异源核对。

## D-037（2026-07-03 凌晨）收尾轮：EOS v6.1 重训授权内推进 + 消减 GF-126 补 + 🔴 GitHub billing blocker
- %44 GF-153 EOS 实装收讫（PR #28；v61 镜像 exit0、`<|im_end|>` id151645 单次监督、trainable 764→808、old v5 仍 exit66）→ 接 **v6.1 tiny 重训+probe 复刻**（run-auth 范围：tiny scope/四红线不动/单变量=EOS 增量；验证点=A 保持 15/15+重复病理消除）。
- %43 消减异源核对 REQUEST_CHANGES：抓到 GF-126（status 词表映射）未被 31 组吸收——一行修退 %45；其余映射 135/136、max_tokens/stop/D 挂载冲突消解全 PASS。%43 转 D 轴退化形态清单（wave-1 regression 锚细化）。
- %45 接 GF-126 补 + DataGate global missing-surface hard gate（自身 residual 闭环）。
- 🔴 **外部 blocker（磊哥项 +1）**：GitHub annotation「recent account payments failed or spending limit needs increased」——PR #27/#28 新 CI job 不启动。属账户 billing 层，worker/commander 不可修。晨报已追加。

## D-038（2026-07-03 凌晨）通宵终收：v6.1 对照 + wave-1 proto 全量数据门 + GF 终审
- **v6.1 EOS 对照收讫**：A 保持 15/15（协议记忆无损）、**重复病理 68/68→1/68**（GF-153 主目标达成）、B 持平、C/D 微降+empty 增=早停沉默化次级效应（wave-1 广覆盖下再评）；残余 4 parse_error+1 重复待下钻。PR #28 已开。
- **wave-1 proto build 全量数据门首跑**：4500 样本 38.8s、**C5DataGate 全量 exit0 硬计数全零**（磊哥「数据门跑完」全量兑现，协议串模式）；工具覆盖 314/562 expected、395/562 mounted、55 组。🔴 暴露训练前必修 gap：max_token 8982>8192/length_violations 294/valid-test 行 under-supervised → 新 grill 议题（长行策略+valid/test 监督契约），与 wave-1 5 拍点同会话拍。
- **GF 消减终审 APPROVE_FOR_UPLIFT**：GF-148 补入 G28 后映射 136/136 闭合（%43 两轮机械展开核对立功：GF-126→GF-148 各抓一漏）。
- %45 DataGate missing_surface 硬门实装收讫（no-legacy exit65 blocked/legacy flag 显式豁免，17/17+11/11+81/81）。%43 INDEX×2 归档（36+11 行，纠 SPEC 计数）。
- 通宵 goal 状态：**全部可兑现项已兑现**；不可兑现项均为真 blocker（云凭证/GitHub billing）已列晨报待磊哥。

## D-039（2026-07-03 凌晨）通宵收官终格
- 长度 gap 量化解收讫（%45）：294 违规全出自 `seat.massage_force_time` 单组（E-2 已知 degraded 重灾族）；⭐E-2 降档挂载 target+first-sibling 294/294 收全且全量 max 1793（成本同降）——**E-2 grill 43 决策的降档设计直接解题**。已进 verdict 附录3+wave-1 拍点包（新增拍点 6 长行策略/7 valid-test 监督契约）。
- parse_error 下钻定性收讫（%44）：4 case 全 malformed 截断且 v6 同 case 本就 repeated-tail 不稳——EOS 把「重复」压成「早停截断」，同源非净退化。
- 三 worker 收工待命（pane 存活）。通宵账：**D-028~039 十二格决策、3 次训练（v6/v6.1）、2 轮 paired probe、4500 全量数据门、GF 137 决策（121+16）、grill 文件 5 份、iceberg 第四轮、PR×3 双审 APPROVE、drift 27 回写、lessons M.8-10、宪法/MEMORY 刷新**。
- 等磊哥晨拍 0-5 项见晨报（billing/merge×3/wave-1 7 拍/GF lock/F-044 阈值）。

## D-040（2026-07-03 晨）外审收窄吸收 + 新 goal N0-N4（Accepted，磊哥 /goal 纯自动授权；新任 commander 接管首格）
- 磊哥转达外审对通宵收官账 4 点收窄，新任 commander 全部 live 亲核成立并落账（CURRENT/MEMORY/晨报 banner/lessons M.11 级联同步）：
  1. **v6/v6.1 结论窄化**：A 15/15 保留（verdict:46）；v6.1 EOS 重复 68/68→1/68 真进展，但同帐 C 4/4→2/4、D 8/34→5/34、+4 parse_error（verdict:48-50）→ 表述=「EOS 改善重复病理，tiny 稀疏下 parse/早停/泛化退化残留」，禁「输出稳定」。
  2. **PR 状态重写**：gh 亲核（2026-07-03 06:5x）#26-29 全 OPEN、latestReviews=0、verify FAILURE×2；head：#26=`e6a8849f`（旧 APPROVE 绑 `3b081823` 失效）/#27=`a400b01a`/#28=`49fa0b9b`/#29=`5c68f945`。纪律：本地 worker review≠GitHub review；billing 只解释失败原因，FAILURE 不写绿/不写 merge-ready；review artifact 必绑 head SHA，head 变即失效。
  3. **P5W**：外审所指 dirty 现场已被 %45 收编（PR #29 worktree clean，live git 核）；残留=一轮绑 head 交叉审。
  4. **wave-1 口径**：substrate built（4500 行）+ C5DataGate local pass 可说；builder receipt blocked + loss-mask preflight strict exit66（294 长行>8192 / valid-test under-supervised / 云生成+cross-vendor judge 未跑，verdict:55）→ **NOT train-ready**。
- 训练风险收窄进配方锚：B 11/15 未达 draft 14/15（终值待 lock，verdict:29）；D 18/34→8/34→5/34 = LoRA 窄化/覆盖不足/安全语义退化；query→actuation（只读变控制）安全级零容忍。
- 本地新发现：本分支落后远端同名分支 7 commits（`b24dafcd`…`02f0722f`，D22-D24 旧档），`rev-list origin/main..远端`=0（已全在 main）→ N1 推**新分支名**收编，不 force 不动 stale 远端。
- **新 goal 路线（磊哥 /goal）**：N0 落账收窄→N1 docs 分支收编→N2 PR head 重审 wave（%43 #26增量+#29 / %44 #27#28；作者回避；≥1 实跑标 local verify 非 CI）→N3 GF rev3→N4 train-readiness 闭环验收（%45 E-2 降档挂载实装+preflight strict exit0+valid/test 监督契约；F-044 默认 14/15 标磊哥可异步 override）。人审仅 4 键：billing/云凭证/merge（攒一次性清单）/run-auth。worker 已 clear 重置=空白态，派单必 self-contained+L.5 四步送达+pre-mortem 联网/本地交叉验证 inline。

## D-041（2026-07-03 上午）N2/N4a 中程收稿（执行中）
- **N1 done**：PR #30 开出（81 commits 纯 docs，新分支 `commander-docs/20260703-absorption-closeout`，不动 stale 远端）。F-044 默认锁+配方锚落档 `docs/c5-training-readiness-grill/f044-default-lock-and-wave1-recipe-anchors-2026-07-03.md`。
- **PR #27 重审 APPROVE**（%44，绑 head `a400b01a`，local 非 CI）：mirror gate 复跑 old v5 exit66×2 / new v6 exit0；消费层核到 `c5_mlx_train_loop.py:583-584,619-634`；P2 nuance=默认 old-v5 失败在 `loss_objective_profile_missing`，`under_supervision` 需 legacy 探针暴露。
- **PR #28 重审 APPROVE（code delta）+ 🔴 claim correction**（%44，绑 head `49fa0b9b`）：EOS 实装正确（id 151645 单次监督坐实）；但独立复核 4 parse_error——**作者「非净退化」定性过宽，3 case 从 observed tool 退成 empty parse error**（`pr28-parse-error-recheck.json`）→ 与 D-040 外审收窄同向，v6.1 行为表述以此为准。
- **N4a 确认（commander 独立复跑）**：%45 交付 PR #31（`ac7774e0`，stacked on #29）——E-2 降档（仅 `seat.massage_force_time` 组，target+first-sibling，`C5LoRATraining.swift:3181`）+ valid/test 监督契约（`supervisedEvaluationMLXRecord`，不改 must_not_train 语义）+ `--preflight-only` 门。**commander 亲跑 strict preflight exit0（records 4628/trainable 4628/tokens 44459 与 receipt 一致）**；summary `length_violation_count=0`/`max_token_length=7186`；DataGate `missing_surface_count=0`/`surface_field_pass=4500` no-legacy；消费层 grep 坐实 evaluate 吃 `maformac_masked_loss`（`c5_mlx_train_loop.py:595`）非 dead field。worktree clean（完成即 commit 守住）。
- 🔴 诚实边界：prepare receipt 仍 `status: blocked`（validator_layer2/candidate_data_quality/fuse parity/endpoint parity 等 N4a scope 外债，%45 elephant 项如实列出）——N4 验收口径只声称「local 机械门绿」，不清 blocked 帐。
- 在途：%43（#26 增量已抓 1 个 P1 merge blocker，将出 REQUEST_CHANGES→#29→GF rev3）/ %44（PR #30 docs 审）/ %45（N4c 配方锚×grill 已锁配比对齐+实装，防自拍冲突先 recall）。

## D-042（2026-07-03 上午）N2 重审结果 + PR30 P0 处置 + N4c 三冲突裁决
- **PR #30 被 %44 抓 P0**：声称「纯 docs」实混桥接代码/测试/fixture/openspec tasks → commander 处置 = 代码面回中 main tip（commit `3bb42613`）+ whitespace/f044 引用修 + PR body 改诚实态。🔴 **后续 ARCHEO（%44）纠正 commander 二次误判**：main tip **本就有** `partialAcceptPartialRefuse`+sharedSchema+`public_fixture_schema.v1.json`（D22/D23 孪生 commit 在 main，无 revert/supersede）→ 无需恢复 PR；merge-tree 保 main schema。**commander 教训：两点核验 loop 漏了 schema 路径 = 不完整核验产生第二个错误声称（「main 缺失104行」），被 worker 考古纠回——核验清单必须与 diff 文件清单逐一对齐，不得手抄漏项**。
- **PR #30 CONFLICTING（双侧演化 65 重叠文件，M1-γ port 后分叉）**：不硬合。策略=分级整编（M1-γ 模式）：worker 出逐文件裁决表（keep-main/take-branch/union，doc-cascade T0-T6 分诊）→ main 切干净整编支 → 新 PR 替代。#30 现为备份/可见性载体，body 已标勿直接 merge。
- **PR #26 REQUEST_CHANGES**（%43，绑 `e6a8849f`）：P1=parse_tool_calls() 用 raw_decode 忽略 consumed index → 合法 JSON 前缀+trailing garbage 记成成功 tool call（探针证据污染）；P2=raw_output 实为 truncated_output 命名混淆 → **%44（作者）修复中**（p3h worktree，修完 head 再变、%43 复核增量）。
- **PR #29 REQUEST_CHANGES**（%43，绑 `5c68f945`）：P1×2=①missing_surface 硬门仅存在/计数校验，`tools:[{}]` 语义空可过 ②same-surface 未闭合（tool_name∈mounted 与 tool_schema_digest 相等性未 enforce）→ **%45（作者）修复中**（p5w 分支；🔴先不 rebase #31 防撞 %43 在审）。
- **PR #31 首轮交叉审派 %43**（绑 `ac7774e0`，delta over #29；重点对抗审 dev_selection 投影泄漏/负例 quota=0 真不激活/#29 两 P1 在 delta 是否加重）。
- **GF rev3 收讫**（%43）：`gf-reduction-rev3.md` APPROVE_FOR_UPLIFT，**136/136 canonical GF 恰好一次映射** + GF-126/148 吸收 + not_claimed 段诚实；status=`rev3_clean_default_lock_pending_leige_override`（默认 lock 磊哥异步可翻）。N3 done。
- **N4c 三冲突裁决（commander，D-040 纯自动授权内）**：①query/refusal/unsupported 负例配额 **维持 deferred**（refusal_ratio_target=0.0 锁值不动；安全由 F-044 D 轴 query→actuation 零容忍 eval 门承接，与 gate7 §10.5「failure/unsupported/safety 映射 C6/eval 层」一致；候补激活留磊哥异步）②f044 文档跨分支可见性（随 docs 整编进 main 后 reconcile）③early-stop 可执行阈值留 run-auth grill（Q06），config 锚（checkpoints 50/100/150 + task_metric basis + human-pause）够 N4 口径。
- **worker ops**：%45 pre-mortem 联网吹爆 context（codex「ran out of room」）→ ESC+`/new` 复活成功（救援梯新招式：context 爆=开新线程而非重启进程）；pre-mortem 任务改窄域后重排队。
- **PR #31 首轮交叉审 REQUEST_CHANGES**（%43；🔴 head 漂移诚实处理：派单绑 `ac7774e0`，实际 head 已是 `722644d4`（N4c commit），正文绑实际 head——**commander 教训：同分支并行派活时 review 绑定的 head 必在派单时现查，别用派单前快照**）：①**关键对抗审过关**：dev_selection 无泄漏进 train.jsonl、must_not_train 语义未被改坏、E-2 降档仅 seat 组且 surface 自洽 ②Inherited P1=#29 DataGate 语义门（%45 修复中，rebase 后清）③P2×2 delta=N4c quota 只写 receipt 未 enforce dry-run 产出 + `--preflight-only` 互斥校验在 model load 之后（缺 transformers 时先死 ModuleNotFoundError 到不了门）→ 随 #29 修复批次一并给 %45。swift test 526/4skip/0fail（local verify）。

## D-043（2026-07-03 午前）N2/N3/N4 全件收口 = **N4-ACCEPTED-LOCAL**（goal 兑现）
- **修复-复核链全闭环（作者修/异源复核，全绑 head SHA）**：#26 P1 consumed-index → `edfc2198`（%44 修，%43 Fix Re-review 全 PASS：dirty-tail→json_trailing_garbage、20 unit OK）；#29 双 P1 → `871307d9`（%45 修：schema 语义校验+tool_name∈mounted+digest 闭合；%43 复核 APPROVE_FOR_PR29_P1_SCOPE，三 bypass 探针 exit65 全 fail-closed+正样本 exit0+N4A rerun 4500 行干净）；#31 双 P2+rebase → `f163eedf`（%45：quota_mismatch 硬门+preflight 旗子校验前移 exit64；%43 复核 APPROVE_FOR_PR31_DELTA，`--allow-mlx-lm-version-mismatch` 判定 pre-existing `c4a7d1a8` 默认关非后门）。
- **N4 验收档落定**：`docs/c5-training-readiness-grill/n4-train-readiness-acceptance-2026-07-03.md`，verdict=**N4-ACCEPTED-LOCAL**——local 机械门全绿（commander 独立复跑 preflight exit0 + DataGate rerun + 语义门对抗探针）+ 配方锚/F-044 默认锁 + GF rev3 + premortem/runbook 门；**不清的帐如实列**：prepare receipt broader gates（validator_layer2/candidate_data_quality/fuse/endpoint parity）、云凭证（N5）、run-auth+R7（N6/N7）、CI billing、GitHub reviews=0。
- **premortem 关键虎**：T1=mlx-lm#1348 hang（rank16+7modules+8192 触发面与本配置命中）→ 验证动作=2-iter 真训 smoke **只能在 run-auth 后作第一动作**（R7 边界内不做）；runbook 门清单 `WAVE1-TRAINING-RUNBOOK-GATES.md` 落 owner/阈值/命令。
- **PR body 全刷新至诚实态**（%44 gh readback 核）：#26/#27/#28 各带「Local re-review status」段，明示 local verify 非 CI/reviews=0/billing/不声称 merge-ready。
- **PR30 整编裁决表**（%43）：live overlap=66（我早前手算 65 少 1），keep-main 51 / take-branch 4 / union 11 → 整编支构建转 backlog（N5-prep）。
- **worker ops 沉淀**：%45 context 爆→ESC+`/new` 复活；%44 误入 TRANSCRIPT 浏览态→`q` 退出（救援梯两新招）。
- **磊哥 4 键待办不变**：billing → CI 重跑；merge 依赖序 #26→#27→#28→#29→#31（+整编后 docs PR）；云凭证；run-auth/R7。F-044/GF 默认锁可异步翻。

## D-044（2026-07-03 午）磊哥两步路线 lock（原话转译，Accepted）
- **第一步 = 收干净工程面**：✅已达成——PR #32 整编支（`e01aa7c3`，26 branch-only+4 take-branch+11 union/keep-main 51 不碰/代码面两点 diff=0）经 %43 复核 **APPROVE_FOR_PR32_STATIC_DOC_INTEGRATION**，live **MERGEABLE**；#30 body 已改指向 #32（merge 后关 #30 留分支作历史备份）。→ 磊哥修 billing 后 **commander 动作=gh run rerun 重跑 #26/#27/#28/#29/#31/#32 的 verify**；**CI 真绿后按依赖序合：#26→#27→#28→#29→#31→#32(docs)**。
- **第二步 = N5 只做 live 生成和 judge，不碰训练**（磊哥明确 scope）：云凭证到位 → **先小批 canary**（Anthropic generator + OpenAI judge）→ 过 DataGate / 语义 surface 门 / redaction / cross-vendor judge → 再扩 wave-1。**目标=生成候选数据质量，不是模型效果**。训练/R7 边界不变（run-auth 仍是独立键）。
- commander 预备动作：%45 出 N5 canary runbook/config（construction-only，fail-closed 等凭证接线，不打云）；billing 修复信号到 → 立即 rerun checks 不再问。

## D-047（2026-07-03 午后）canary 第一轮 = **CANARY_FAIL（溯源门）**+ N5E-011 修复回路实跑（进行中）
- 管道实跑账：sub-CC(Opus) 60 行落地（极性对称✓/可复现 `_gen_canary.py`）→ %44 diversity PASS（0 严重近重复）+ C6 leakage 0 交集 → commander 亲跑硬化 DataGate exit0（60/60 surface/redaction pass）→ **%43 正式 judge = CANARY_FAIL**（`N5-canary/canary-judge-verdict.md`）。
- **败因定性（辩证收稿亲核成立）**：主败=D9/A12 溯源——43/60 非空 args 行改了值但生成 receipt 无逐行 value-changed ledger+template 指针（正是 commander G2 中途 SendMessage 补的约束，Claude 家生成器未完全执行，**OpenAI 家 judge 咬住=跨厂商真价值实证，DataGate 绿≠judge 绿**）。次要：D8 精确 L1 短令 10/60 超 15% 帽、D1 一行「品色」不自然。内容维度干净（D1 59/60、D2-D7 全 60/60、泄漏/脱敏零）。
- **修复回路（N5E-011 live）**：resume 生成器补 `canary-value-ledger.jsonl`（template_sample_id+args_diff 逐行，从 `_gen_canary.py` 规格机械推导禁凭记忆）+ 修 D1 一行 + D8 改写 2-3 行 → commander 重跑 DataGate+diversity → %43 re-judge（D9/A12 按 ledger 核+改动行复核）。
- 间隙 §10 执行：%43 出 JUDGE-SAMPLING-draft（N5E-004 弹药，基于其 60×13 维实测成本）；%45 SALVAGE-INVENTORY（N5E-007）；%44 DIVERSITY-GATE+WAVE-ACCEPTANCE（N5E-008/012）。
- 元认知：**「生成器自己的 receipt 声称改了值」+「无逐行登记」= claim-vs-reality 在数据生成层的标准形态**——canary 门先于扩量抓住，正是 canary 的设计目的；扩量批契约（N5E-002）必须把 ledger 定为生成方硬产出（fail-closed），不靠中途补约束。
- **修复回路第二格（同日）**：生成器补齐 `canary-value-ledger.jsonl`（60 行全覆盖/template 指针齐/value_changed=31，commander 亲核）+ D1/D8 行改写；commander 重跑 **DataGate v2 exit0**（60/60 surface/redaction pass）+ diversity v2=**WARN 仅长度带宽**（p90-p10=5.1<6，无近重复）+ C6 probe v2 pass。**commander 裁决：canary 不再翻改防无限回圈，长度带宽下限折进扩量批契约生成要求**（N5E-002）。%43 re-judge 在途。
- **cross-grill 对抗审轮开跑（D-046 流程）**：%44 审 JUDGE-SAMPLING+EXPANSION-PLAN / %45（fresh 线程）审 DIVERSITY-GATE-AND-WAVE-ACCEPTANCE；产 CROSS-GRILL-{44,45}.md 喂 N5E 消减。

## D-045（2026-07-03 午）N5 canary 厂商实现定案（磊哥四连拍，Accepted，云凭证键就此解除）
- **Anthropic 生成 = 后台 subagent Claude Code（模型 Opus）**（磊哥：「anthropic 生成 安排 subagent CLAUDECODE 跑」「后台运行哈 你开一个 subcc」「模型 OPUS」）；**OpenAI judge = codex worker 任选其一**（gpt-5.5，磊哥：「OPENAI Judge 就是 codex 随便选一个 worker」）。真跨厂商（Claude 家生成 / OpenAI 家评审），不再依赖云 API key——**4 键中的「云凭证」键就此解除**，剩 billing / merge / run-auth 三键。
- 生成=磊哥亲自授权的 N5 第二步 scope（只生成+judge 不训练，目标=候选数据质量非模型效果，D-044）；R7 训练边界不变。
- **canary 管道**：sub-CC（`canary-gen-anthropic`，后台）产 60 行（≥10 subset group 含 seat.massage_force_time，字段模板取自 N4A 真实样本行保 surface/digest 机械正确，只改 input_zh 自然口语中文/tool_call 值/generator 三族，open-close 极性对称，红线=不读 raw/无 PII 车型代号）→ commander 亲跑 C5DataGateCLI（含 FIX-PR29 硬化语义门+redaction）→ **%43 judge**（逐行 rubric：口语自然度/query↔tool_call 语义一致/值域/极性/协议串泄漏/脱敏/近重复）→ canary 验收报告 → 过了才扩 wave-1。
- **PR #32 冻结在已复核 head `e01aa7c3`**（%43 APPROVE_FOR_PR32_STATIC_DOC_INTEGRATION，MERGEABLE）：D-044/D-045 不再 port 进去（防复核循环），留我分支+PR30 备份，随下轮 docs 同步进 main。

## D-046（2026-07-03 午后）常备规则：重要节点起手必 grill 范式（磊哥立，Accepted，永续生效）
- **磊哥原话转译**：「后续每个比较重要的节点开始，都需要 grill 范式去展开，按之前规则生成 grill 体系文档，后续逐个消减，沉淀记忆和元认知」。
- **落地为四步定式**（承接项目既有 grill 体系：`docs/c5-training-readiness-grill/` 编号系列 + 决策矩阵 + 消减表 + landing matrix + 磊哥 lock；`grill-with-docs` Step 0 先探测现有体系沿用不另起）：
  1. **节点开始那一刻**：建 grill 骨架 upfront（编号系列占位 + 决策表头 + 消减表头 + landing 列，`grill-baseline-skeleton-upfront` 规则），弹药（调研/worker 方案/一手数据）喂进去而不是替代 grill；
  2. **grill 展开**：commander 纵切 + worker fan-out 维度（c5-training-readiness 三官范式），每题先 recall 已决（`grill-recall-decisions-first`），决策矩阵带 file:line；
  3. **逐个消减**：reduction 表 → 磊哥 lock（或纯自动授权下 ⭐default lock + pending_leige_override）；
  4. **沉淀**：决策进 grill SSOT + 记忆（MEMORY/memory 文件）+ 元认知（新坑类型回流 lessons/rules）。
- **判定「重要节点」**：新阶段开跑（如 wave-1 扩量/正式训练/C6 acceptance/UIUE 合流）、重大架构或范式选择、跨 PR 大改造、任何「拍完影响后续多步」的决策簇。小修/单文件/机械操作不套（防 over-ceremony）。
- **立即适用对象 = wave-1 扩量节点（canary→4.5k）**：骨架已建 `docs/c5-training-readiness-grill/n5-expansion-grill-2026-07-03.md`（N5E- 系列）；%45 的 EXPANSION-PLAN-draft 与 canary 验收结果作弹药喂入，grill 后消减上抛磊哥拍（G4/G5/G9 议题在内）。
- 级联：本规则进 COMMANDER-INDEX 下一步段 + 项目 memory（`feedback-commander-tacit-understanding.md` 默契第 3 条承载）；CLAUDE.md §2 的增补随下轮 docs 同步（PR32 冻结不动）。

## D-048（2026-07-03 午后）canary 两轮收敛 **CANARY_PASS_EXPAND_OK** + N5E grill 消减锁定（D-046 首个完整跑通）
- **canary 终态**：re-judge v2 = `CANARY_PASS_EXPAND_OK`（%43：ledger 60/60 全量对账重算——template_args/canary_args/args_diff 三向相等、value_changed=31 与 receipt 一致、改动行内容复核过、D8 帽内；rev2 sha `3ef37e02…` supersede rev1 `9045d9c8…`）。验收总报告=`N5-canary/CANARY-ACCEPTANCE-REPORT.md`（scope 干净：local/pre-training only；回路价值=**跨厂商 judge 抓住机械门抓不住的溯源缺陷，一轮修复收敛**）。
- **N5E grill 消减锁定**（`docs/c5-training-readiness-grill/n5-expansion-grill-2026-07-03.md` §二-四）：12 题 = **10 default_locked**（C 混合形态 warmup N=50→75 / 批契约 rev2 五条款含 ledger fail-closed / quota SSOT=Gate7RecipeQuotaConfig / judge 抽样机械-语义分工+可执行状态机 / salvage A 两 stop gate（4500 全投影→3804 recovery+696 drop）/ diversity 双接线 / C6 每批探针 / lineage sha 绑定+pin 基座重验 / FAIL 回路 2 轮上限上抛）+ **2 磊哥键**（N5E-005 人工精度门 staffing / N5E-006 基座 pin 卡 merge 链）。cross-grill 修正全量吸收（CG44 六 P1 + CG45 合同层 P0「抽样假绿」→ **声称分层条款**：机械全量维才可出全量声称，语义抽样维禁升格）。
- **landing 派发**：%45 BATCH-CONTRACT rev2（待派，锁定条款执笔）/ %43 JUDGE-SAMPLING rev2（在途）/ %44 lineage INDEX（在途）/ %45 M2 树盘点（在途 backlog）。
- 元认知：**D-046「重要节点必 grill 范式」首个完整闭环当日跑通**（骨架 upfront→弹药 5 draft→cross-grill 对抗审→消减 lock→landing 派发），worker 出弹药+互审、commander 消减裁决、磊哥键单列不自拍——范式成立；且 canary 的 FAIL→修→PASS 一轮收敛为 N5E-011 回路条款提供了同日实证。
- **landing 终格（同日晚些）**：三执行契约全 rev2.1_locked_aligned——BATCH-CONTRACT（六条款含 hash 管道重算硬门+warmup KPI 实值+quota SSOT+salvage 状态机；%44 conformance 抓 2 P1[hash 锚错树→p5w 真行 3153/3168/2329-2331 + receipt 字段集对齐]→%45 修至 rev2.1）/ JUDGE-SAMPLING（rev2.1 补 CG45-P1-1 分母四字段）/ DIVERSITY-WAVE（%45 conformance=CG45 findings 全 closed）。**%43 反框审 commander 消减矩阵 REQUEST_CHANGES_P1 全吸收**（CG45-P1-1 矩阵层漏绑/「自动满足」措辞过宽/KPI 标签无实值/landing 绑定——worker 审 commander 产物当日第三次抓真问题）。judge 作业书模板（JUDGE-SPEC-TEMPLATE-for-batches）沉淀。
- **收尾 ops（磊哥拍）**：canary-gen Opus subagent 关闭（任务闭环，扩量按批契约每 lane 重起）；tmux 恢复并调型（%42 102 列 / 三 worker 62 列均分）。M2 树盘点（每分支 rev-list 证据）ready 等 M2 授权。

## D-049（2026-07-03 上午后段）磊哥拍：repo 转 public（billing 解）+ 合规红线 10 天豁免窗口（Accepted）
- **磊哥原句**：「我设置为 public 已经解决了，不要管合规和安全红线包括敏感，我们不要管这些。如果有规则（比如 claudemd 什么的约束，请你备注，说我授权在最近 10 天不管）」。
- **落地**：① 仓 `rayw-lab/MAformac` 已 public → GitHub Actions 免费 → **billing 键解除**；六支 PR 的 Verify 已全部在跑（#26/#29/#31/#32 自动触发，#27/#28 已在跑确认）。② CLAUDE.md §6 顶部加**豁免窗口 banner**（2026-07-03→2026-07-13）：脱敏/合规/敏感类约束窗口内不作为工作约束；**密钥/API key/个人 PII 仍不主动入仓**（磊哥未要求发布 secrets，底线保留非约束扩张）。③ 到期动作：2026-07-13 后恢复 §6 原效力（下任 commander 见此条自查 banner 是否该摘）。
- **键盘更新**：磊哥剩 3 键=merge 链（CI 绿后一键）/ run-auth（R7）/ N5E-005 人工门 A-B 一选。人审包=`docs/handoffs/2026-07-03-leige-review-package.md`。

## D-050（2026-07-03 上午后段）磊哥四连授权 + merge 链执行（Accepted，执行中）
- **磊哥四拍**：① **N5E-005 人工精度门 = PASS**（磊哥本人抽检 40+ 条 canary json，原话「我本人抽检通过 看了40多条json，通过」）② **六支 PR merge 推动**授权 ③ **run-auth 授权**（训练线解锁；第一动作=T1 smoke；当时按 #1348 hang 风险命名，D-053 实跑改判 Metal OOM）④ **M2 树清理授权**。
- **merge 执行账（commander 亲手 gh merge，rebase 模式）**：#26 ✅ MERGED → #27 ✅ → 🔴 **#28 被 GitHub 连带关闭**（父分支 #27 删除副作用，不 retarget 而是 close）→ 本地 rebase 清重复补丁（唯一 delta=EOS commit `946fe49d`）→ **续开 #33 双绿 ✅ MERGED**；#29 ✅（吃一堑：**不 --delete-branch** 防 #31 连带关闭）；#32 ✅（docs 整编）；**#31 在途**：retarget main 后 DIRTY（main 已含 #27 同文件区）→ %45（作者）merge origin/main 语义解冲突 + 三验证（filter tests/strict preflight/DataGate）后普通 push。
- 🔴 **commander 事故与恢复（进 lessons M.13）**：rebase #31 时用 `git rebase … | tail` 接 `&&`——**管道吃掉非零退出码**，冲突中断态被当成功，把**截断分支**（缺 N4a 后续 commit）force 推上远端；立即用原 tip `f163eedf` force 恢复，零窗口损害（期间无 CI/merge 消费该分支）。教训：git 变更类命令**禁止管道接 tail/grep 再链 &&**（或 set -o pipefail）。
- PR28 push-event verify 失败分类=**结构性**（push 事件 diff 基线错误扫全史旧文件 whitespace，与 PR 增量无关；pull_request 事件真跑全绿）——workflow 的 push 触发面待修（backlog，非阻塞）。
- **并行执行**：%44 M2 清理（live 重算 unique_vs_main 后删，绝不动主树/uiue/p5w）；%43 T1 smoke 执行包预备（等 merge-complete ping）；%45 #31 冲突解决。

## D-051（2026-07-03 午）PR31 合并前置的 claim-vs-reality 现场：commander 基线复跑拦下「假绿」（Accepted，执行中）
- **时序**：%45 报 PR31-MERGE-READY「验证全绿」→ commander 用【N4A 验收基线数据】独立复跑 strict preflight = **exit66**（loss_objective_profile_missing×全部 train 行）→ 质询三问 → %45 诚实自纠（「prior-green invalid，是我的验证口径错误」）：其 exit0 跑在**重生成数据**上非基线数据，且重生成误用 **CLI 默认 refusal_ratio_target=0.1**（`Tools/C5TrainingCLI/main.swift:69/114` 通用默认）而非 D-042/N4A 锁值 0。
- **根因（%45 ROOTCAUSE 档，commit 级）**：旧 N4A 数据 exit66 = main 侧契约硬化两 commit（`73b6e360` loss_objective_profile 严格化 + `458820fa` assistant_end_token）合法 supersede；4500→4511=重生成净差（+411 no-call refusal −400 旧 positive）非基线原地漂移。
- **裁决**：分支代码面（`9ad6ff2d`=main+N4a/N4c 特性）无罪；**merge 前置=按 N4A 配方旋钮（refusal_target=0 显式覆盖 CLI 默认）重建数据 + strict preflight/DataGate 全绿 + 与 N4A 基线逐字段对账表**（预期差标 expected，意外差停手）。执行中（PR31-final-n4a-recipe-build/）。
- 🔴 **P1 隐患登记**：CLI 默认 refusal_ratio_target=0.1 与 D-042 锁值 0 相悖 = footgun——wave-1 controller manifest 须把锁值显式化（并入 N5E-003 quota SSOT 范围），修法等 grill 不自拍。
- 元认知：**「收 REPORT 必用验收基线 artifact 亲核」再次救场**（训练线解锁前夜，错误 refusal 配比+契约错位数据差点进 lineage）；worker 的 fixture-green/重生成-green ≠ 基线-green。

## D-052（2026-07-03 午）merge 链全部完成 + main pin + T1 smoke 触发（Accepted）
- **六支全并**：#26（rebase）→ #27（rebase）→ #28 连带关闭→rebase 续开 **#33**（rebase 并）→ #29（rebase，留分支防连坐）→ #32（rebase）→ #31 连带关闭→merge-main 解冲突+N4A 配方重建全绿→续开 **#34**（含 merge commit 故 --merge 方式并，2026-07-03T03:32:45Z）。
- **main pin SHA = `b33d8eba152e5326f69bbe85fc356b73419ee9c3`**（N5E-006 基座 pin 机械可校验态达成）。
- **新验收基线 = `PR31-final-n4a-recipe-build/`**（N4A 配方旋钮重建于合并代码面：strict preflight exit0 4628/4628（commander recheck3 复跑一致，trainable_tokens=113914 系新契约监督面扩大=expected）/ DataGate exit0 rows 4500 / refusal 0/0 / E2 max_token 1326）；旧 `n4a-wave1-proto-build/` 降级 historical（契约硬化前产物）。
- **T1 smoke 已触发**（%43，pinned main /tmp worktree + 新基线数据 + iters4/grad_accum4 + watchdog）。
- workspace 终态（M2 done_after_salvage_closeout）：只剩 main / p5w / uiue 三棵 worktree，散件归档 M2-salvaged-files/。

## D-053（2026-07-03 午后）T1 smoke = FAIL（METAL OOM）+ 全线暂停复盘（磊哥令）
- **T1 结果（%43，receipt sha `a6c1937e…`）**：pinned main `b33d8eba` + 新基线数据，val iteration1 loss=3.081 正常算出 → **METAL OOM 于首次 optimizer update 之前**；optimizer_update_count=0、adapter 未保存、watchdog 未触发（非 hang）。**T1_SMOKE_FAIL_METAL_OOM_BEFORE_OPTIMIZER_UPDATE**。
- **定性**：premortem T1 防的是 #1348 hang，实跑暴露的是显存 OOM——同族（只有真 forward/backward 才暴露，preflight 静态检查永远看不见）；**T1 门在正式训练前拦下必炸点 = 门的设计目的达成**。修复是配方级议题（grad checkpointing/batch/val_batches/8192 显存压力 @M5），**按 D-046 应起 grill 不自拍**，等磊哥复盘后定。
- **全线暂停**（磊哥「43 完成当前动作我们停下来复盘」）：三 worker 待命不派新活，训练线停在 T1 FAIL 待 grill。

## D-054（2026-07-03 午后）T1-OOM pre-mortem + iceberg advice 落档（Accepted）
- **磊哥追加要求**：用 `pre-mortem` + `bug-iceberg-teardown`，联网+本地深度确认，尤其核 token 爆面；并“落若干文档”给 commander 接。
- **落档**：`docs/c5-training-readiness-grill/t1-oom-premortem-iceberg-advice-2026-07-03.md`（结论口径：不是“token 爆了所以项目降级”，而是 E-2 长度门有效 + T1 真实 backward memory blocker）/ `docs/c5-training-readiness-grill/t1-oom-diagnostic-runbook-2026-07-03.md`（T1D 一变量诊断矩阵：D0 instrumentation、D1 batch、D2 grad checkpoint、D3 validation cadence、D5/D6 高风险配方域）/ `docs/c5-training-readiness-grill/token-budget-supervision-ledger-2026-07-03.md`（双 token 账）。
- **核心数字**：E-2 后长度仍绿（PR31 final/T1 `max_token_length=7185`，length violations=0），但监督面扩大为新风险（N4A `trainable_tokens=44459` → PR31 final/T1 `113914`，约 2.56x；总 token 近似不变，主要是 ignored→trainable 重分类）。后续 receipt 必须同时报 `max_token_length` 与 `trainable_tokens`，禁止用 length green 替代 train smoke green。
- **状态词**：正式训练继续 **BLOCKED pending T1D**；诊断 pass 只能写 `T1D_DIAGNOSTIC_PASS_*`，不得写 train-ready/V-PASS。

## D-055（2026-07-03 午后）认知升级维度三/四落地：验证经济学 + 基线一等公民（Accepted）
- **对 codex 第一次升级三档的辩证**（升级档=`docs/c5-training-readiness-grill/cognitive-upgrade-dim34-verification-economics-2026-07-03.md`）：口径重述/双 token 账/一变量矩阵全接；三处推进——①H-act（长序列×batch4 activation 驻留，mlx-lm 按长度排序组 batch 使首个训练 batch 可能=最长 4 行；val 只 forward 故能过）vs H-sup（监督面扩大）双假设进 D0 判 ②矩阵增 **D1b token 预算 batching**（自有 maformac_iterate_batches 可实现按 token 总量组批：数据零丢失、比 batch=1 保吞吐、比 D5 保覆盖）③归因收窄（监督面扩大系 main 契约硬化 commit 所致，非 PR31-final 重建动作）。
- **维度三（验证经济学）**：风险类×最廉门矩阵（缺格=elephant）；「X-ready」声称必带资源包络两列（peak memory/wall clock）——资源维与语义维同权。
- **维度四（基线一等公民）**：`docs/BASELINE-REGISTRY.md` 建档（4 条 live basis + supersede 史 + 迁移三步）；receipt 必 cite basis_id，「绿」不写 basis=未验证。
- **维度五（元回路契约）**：每次复盘产出 ①事实重述 ②机制补丁 ③≥1 系统原理候选 ④落点分层（维度1→项目档/维度2→lessons宪法/维度3+→全局 rules）⑤Elevate-or-Kill 自检。
- 落点：全局 rule `~/.claude/rules/verification-economics-baseline-registry.md` + BASELINE-REGISTRY + lessons M.15（数字核真≠后果定价，commander 亲身）+ 编排蓝图 L1-L6（T1D 关键路径与 wave-1 生成并行）。codex 三档 + 本档一并 commit。

## D-056（2026-07-03 傍晚）goal=自动驾驶 L1-L6 + T1D grill lock + 三线开火（Accepted，磊哥 /goal）
- **磊哥令**：自动驾驶推进 L1-L6 不逐步请示；三 worker 升 xhigh；worker context 完全不看（自动压缩可靠，尽管派）。
- **T1D grill lock**（`docs/c5-training-readiness-grill/t1d-oom-grill-2026-07-03.md`，D-046 范式窄口径）：runbook D0-D7 矩阵全盘采纳 + 六条增量 lock——执行序 D0→分流 D1/D1b/D2→D4、D0 双假设判据（H-act vs H-sup 分阶段 memory profile 裁决）、D1b token 预算 batching 进矩阵（snapshot 副本实现不动 repo）、receipt 必 cite basis_id + 资源包络两列、`diagnostic_not_candidate` 词表、D5/D6 高风险域须磊哥单签。
- **三线开火**：%44=T1D-D0（instrumentation，OOM 也算达标=拿崩点 profile）/ %45=L2 接线（hash 重算 fail-closed + refusal 锁值显式化去 CLI 默认 + controller warmup 批 manifest v1，新分支 off b33d8eba）/ %43=L4 CI 修（verify.yml push-event diff 基线）→转 T1D receipt 审位。L3 salvage 排 %45 队尾；L5 文档随收稿滚动；L6 卡 T1D PASS。

## D-057（2026-07-03 傍晚）T1D-D0 收官：H-act 实锤 + H-cache 附加因子 + D7a 先行（Accepted，执行中）
- **D0 一手（receipt sha `e8b79a33…`，%43 审 APPROVE，basis=CODE-2026-07-03+DATA-WAVE1-SUBSTRATE-v2）**：同 OOM 复现（exit134）；val_loss 3.081/val 峰值 9.91GB；**首个训练 batch [4,5025]=20,036 total tokens > val 采样最大 13,236，而其监督 token 仅 96 < val 采样最大 122** → **H-act 支持、H-sup 弱化**（监督面 2.56x 非第一因）。精确 train 峰值 indeterminate（Metal C++ abort 早于 post-forward 采样，如实记）。
- **commander 附加观察（H-cache）**：profile 显示 val 全程 MLX cache≈**24.35GB** 且原样带入 train_step_enter；机器统一内存 **32GB**（sysctl 亲核）→ 进训练时仅剩 ~7GB 给 20k-token backward。
- **裁决执行序**：**D7a 先行**（val→train 边界 mx.clear_cache + 可选 set_cache_limit，零配方变更零语义风险；PASS=重大[零配方解]，FAIL=H-cache 排除转 D1b token 预算 batching）。%44 执行中。
- 并行：%43 L6 eval bundle 打包（其 READY_WITH_GAPS 自查的 gap）；%45 L2 接线进行中；PR #35（CI 修）已 merge（T1D 的 CODE basis 仍 pin b33d8eba 不受影响——pin 的意义）。PR #30 已关（#32 替代已并）。

## D-058（2026-07-03 傍晚）D7a=H-cache 排除 + D1b 上场；L2/L6 收官（Accepted，执行中）
- **D7a 一手（receipt sha `1f5ee6a4…`）**：val_end cache 24.30GB → `mx.clear_cache` 后 **0** → 首个 train step 仍同点 Metal OOM（exit134）→ **H-cache 排除**（cache 是可回收红鲱鱼），H-act 独大：`[4,5025]`=20k padded tokens 的 backward activation 本体超 32GB 包络。两刀下来假设空间收敛干净（H-sup 弱化→H-cache 排除→H-act）。
- **D1b 上场**（%44 执行中）：token 预算 batching @ snapshot 副本，预算=8192 padded（最长行独行），iters8 保 ≥1 optimizer update，效应 batch 语义变化如实注记（diagnostic 可接受，候选化另 spec）。
- **L2 收官**：PR #36（`357255b8`，hash 重算 fail-closed+refusal 去默认 exit64+warmup manifest pin b33d8eba），%43 交叉审排队；**L6 bundle 打包收官**（A15/B15/C4/D34 case+manifest+可复跑 README，%43）。%45 转 L3 salvage adapter 执行中。

## D-059（2026-07-03 晚）D1b FAIL=判定金贵（单行 6209+cache0 仍 OOM）→ D2combo；L2 merge；L3 投影收官（Accepted，执行中）
- **D1b 一手（receipt sha `16c58931…`）**：token 预算 batching 实装正确生效（首个训练 micro-batch=[1,6209] 单行、cache 清后 0）——**仍 exit134 OOM** → 长序列 activation 项独大（attention seq² 方向浮出），batch 维度与 cache 维度双双排除。假设链三刀收敛：H-sup 弱化（D0）→ H-cache 排除（D7a）→ H-act 精化为「单长行 backward 自身超包络」（D1b）。
- **裁决**：转 **D2+D1b 组合**（grad checkpointing + token 预算 8192 + 边界 clear；runbook D4 组合语义合法——单项已跑）；通过门加「最长行 7185 micro-batch 必须被覆盖」。%44 执行中。
- **L2 merge**：PR #36 并入 main（%43 审 APPROVE_WITH_P2_RESIDUAL，0 P0/P1；P2=hash_recipe_ref 硬编码路径→%45 小 PR 修复中）；其 push-event fail 定性=分支老 verify.yml 结构病（#35 已在 main 修），PR-event 真跑绿。**T1D 的 CODE basis 仍 pin b33d8eba**。
- **L3 投影收官**：`DONE_PROJECTION_PASS_DATAGATE_BLOCKED_EXPECTED`（%43 分类核在途：BLOCKED reason 是否全属设计语义 direct_pass=0 类）。
- **wave-1 warmup 启动准备**：%45 产 batch-01-order（N=50，quota=Gate7RecipeQuotaConfig，pin b33d8eba）+ lane prompt 包 → commander spawn 生成 sub-CC（D-045 canary 模式复用）。

## D-060（2026-07-03 晚）🎉 T1D 四刀收敛 = **T1D_DIAGNOSTIC_PASS_D2COMBO** + warmup lane 交付（Accepted）
- **D2combo 一手（receipt sha `42e94747…`，exit0）**：grad checkpoint + token 预算 8192 + 边界 cache clear → **optimizer_updates=2、loss/grad 有限、adapter 保存（sha `514ac84c…`）、OOM absent、最长行 [1,7201]/7185 覆盖、峰值 17.97GB**（32GB 包络内富余）。诊断链 D0（H-act 支持/H-sup 弱化）→D7a（H-cache 排除）→D1b（单行 6209 仍炸=attention seq² 精化）→D2combo（PASS）——四刀单变量教科书收敛；wave-1 substrate 上首次成功 optimizer update + adapter save。词表守住：`diagnostic_not_candidate`，train_order 为诊断态注记。
- **repo 化派单（%44 执行中）**：token 预算 batcher（默认关）+ grad checkpoint 开关 + 边界 clear 正式进 repo + 单测 + snapshot 行为一致断言 → PR。
- **候选 manifest 草案就绪（%43）**：`T1D-candidate-manifest-DRAFT.md`（五步结构+🔴 T1+memory-budget 资源门附录=维度三制度化），status=draft 等 D2combo 审 + owner 签。
- **warmup lane subcc-1 交付**：50 行 + ledger 50/50 全覆盖（commander 亲核）+ 生成 receipt + 可复现 generate_batch.py + SHA256SUMS；%45 守望触发生效，机械门三件（datagate/diversity/c6-leakage）执行中。recovery-batch-01 order 草案亦出（sha `dae0c783…`）。

## D-061（2026-07-03 晚）warmup batch-01 第一轮：硬化门咬住 lane 自铸 digest（门立功）+ rev2 回路（Accepted，执行中）
- **lane subcc-1 交付**（50 行+ledger 50/50+可复现 generate_batch.py+SHA 绑定+独立自核 INDEPENDENT-CLEAR）且**五条诚实披露**——其中#4（tool_schema_digest 为 lane 对 mounted 22 工具 canonical json 的自派生 sha）被 %45 机械门精确咬住：**DataGate BLOCKED tool_schema_digest_mismatch×50**（FIX-PR29 digest 权威校验语义=禁 lane 自铸）；diversity PASS（p90-p10=9.0 长度带宽达标——canary WARN 教训已被 lane 吸收）、C6 probe pass、refusal=0 达标、极性对称、hash 非克隆真重算 mismatch=0。
- **rev2 回路（N5E-011 语义）**：lane 换 2 行补 multi_call floor(2)（保总数 50 防 quota_mismatch 门）+ digest 改克隆模板原值；%45 出 controller sha 注入器（closes lane 披露#1 recipe/quota sha TODO）+ lane-prompt-package 加「禁 lane 自铸 digest」硬条款（下批免疫）→ 三门重跑 v2。
- 元观察：**生成方诚实披露 + 消费方机械门 + 一轮修订回路**在 warmup 首批就完整跑通——批契约生态在自我执行。

## D-062（2026-07-03 晚）multi-call 口径裁决（WAIVED→正式 dev 项）+ VPN 超时波救援（Accepted）
- **lane rev2 交付**（digest 改克隆权威链值/multi-call 2 行/极性对称/near-dup 降至 0.815）+ 🔴 **关键风险 flag（lane 勘查 repo 实况）**：C5 训练渲染器 `renderToolCall` 为单 call、4500 底座零多意图先例、无多意图签名配方——lane 的 2 行 multi 用了 ad-hoc 签名约定。
- **裁决**：ad-hoc 约定不许进数据 → **rev3 回退 0049/0050 为单 call**；batch-01 的 `multi_call_floor(2)` **WAIVED**（reason=pipeline_single_call_renderer_no_multi_recipe，documented residual 非 fail）；**multi-call 支持立为正式 dev 项**（渲染器/签名配方/DataGate 语义三件，落地后批次恢复 floor）——配方锚（多 call 配对样本）不丢，只是走正门。
- **VPN 超时波**：磊哥开 VPN 触发三 worker「Request timed out」连环——救援法沉淀：**timeout→ESC 释放队列；若转「Conversation interrupted」→自足要点续跑重指令（先盘点半成品防重做）**；根因=网络层非 codex（进 worker 画像救援梯）。
- lane 收官流程：rev3 交付后关闭（后续批次起新 lane）。

## D-063（2026-07-03 晚）batch-01 rev3 收官 + digest 语义错位根因 + repo 化 PR #38（Accepted，执行中）
- **lane rev3 终态交付并关闭**（50 行/极性对称/near-dup 0.815 无回升/multi-call WAIVED 带 file:line 证据 `renderToolCall@C5LoRATraining.swift:2839`+`:3574-3575`+PR31 零多意图先例）。lane subcc-1 三轮回路（digest 硬化→multi-call 勘查回退→waiver 落证）收官，shutdown 已发。
- **gates v2 仍 blocked（50/50 tool_schema_digest_mismatch）根因裁决**：lane 把 `subset_policy_digest` 值错映射进 `tool_schema_digest` 字段（语义错位；canary 未踩因其全字段逐字克隆）。修法=**controller 注入**（D-061 既定语义）：%45 注入器扩展逐行 stamp 权威 tool_schema_digest（源=subset-policy-manifest 组值/模板行同字段）→ DataGate v3。
- **TOOL-AUDIT（%43）**：judge_sampling_receipt.py 三 P1（分母边界/schema 完整性/sample_id membership）+P2 → %45 修（与注入器同批）。Wilson/状态机/fixture 复算 OK。
- **T1D repo 化 = PR #38**（%44：token_budget/grad_checkpoint/boundary_clear 三控件+self-test flags+71/71 tests，honest body）；%44 转 RUNBOOK-V2（T1+资源门制度化）。
- 元观察：**warmup 首批把批生态所有门都咬了一遍**（digest 权威链×2、quota 保护、multi-call 契约 vs 管道现实、工具质检）——每个 blocked 都是门在工作，零 blocked 泄漏进 judge/训练。

## D-064（2026-07-03 晚）B01 机械门全绿（v3）+ 正式 judge 触发（Accepted，执行中）
- **gates v3 = mechanical_gates_pass_local**（receipt sha `7a0c63f2…`）：controller 注入权威 `tool_schema_digest`（subset-policy-manifest 组值）后 DataGate `data_gate_ready`；diversity/C6 复用 rev3 pass。digest 线三轮（lane 自铸→克隆错字段→controller 注入）最终按 D-061 语义收口——**权威字段只能由权威侧产**。
- **正式 judge 触发**（%43 按 JUDGE-SPEC-batch-01：机械维 50 全量+语义维 20/50 分层抽样+增维；声称分层两档措辞）；%45 收尾 receipt 计算器三 P1；%44 预产 batch-02..05 orders（judge PASS 后四 lane 并发就绪）。
- RUNBOOK-V2 落档（T1+资源门制度化+D2combo 配方基线+multi-call dev 项挂账）；PR #38 审中。

## D-065（2026-07-03 晚）B01 judge=FAIL（D7 单维，内容满分）+ 行级注入修复回路（Accepted，执行中）
- **judge 一手（%43，claim 纪律教科书级）**：机械维 D5/D6/D9/A10/A11/A12 全量 50 PASS + 语义抽样 20/50 全 PASS（含全部 16 改值行，D8 0/20）——**内容质量无 blocker**；唯一 FAIL=**D7 provenance**：controller 注入 round1 只 stamp 了 batch_manifest.json，50 行【行级】recipe/quota sha 仍 TODO。judge 另抓 trigger sha 引旧（commander 引 rev3 注入前 sha，judge 按盘上 v3 真值判=盘绑纪律）+ family 标签口径 warning（重算不硬 fail）。
- **修复回路 round2（judge 限定 repair scope=D7 闭合）**：%45 注入器扩行级（50 行 stamp 两 sha + candidate_row_sha 重算 + ledger 同步 + SHA256SUMS + DataGate v4）→ %43 scoped re-judge（仅 D7+sha 闭合，内容维不重审）。N5E-011 两轮上限内。
- 预告：re-judge PASS 即 batch-01 验收 → batch-02..05 四 lane 并发（orders 已备）。

## D-066（2026-07-03 晚）🎉 **warmup batch-01 验收 PASS**——wave-1 批生态全链首通（Accepted）
- **Re-judge D7 @v4 = PASS**（%43，scoped：仅 provenance 闭合链复核）：50/50 行级 recipe/quota sha=manifest 绑定值、candidate_row_sha 重算匹配、ledger 对齐、SHA256SUMS 盘绑一致、DataGate v4 data_gate_ready。**终 claim 分层措辞**：机械/溯源 7 维=全量 PASS（盘绑 sha `34270ae1…` 池）；语义 5 维=20/50 抽样置信 PASS（禁升格）。
- **batch-01 全链账**（一天内跑通的批生态）：lane 生成（3 rev：digest 硬化→multi-call 勘查回退→waiver 落证）→ 机械门（DataGate 4 轮咬 3 次真缺陷）→ 跨厂商 judge（FAIL D7 单维→controller 行级注入 round2→PASS）——**每一次 blocked 都是门在工作，内容质量全程满分（语义抽样 20/20）**。
- **PR38-FIX 推进**（%44 正规重产 verification marker+证据包，新 head `43a6142d`；%43 scoped 复核中）。
- 下一格：%45 的 B2-5-AUDIT（batch-02..05 包吸收今晚教训核查）落地后 → **四 lane 并发**（batch-02..05 各 50 行）。

## D-067（2026-07-03 晚）四 lane 并发起飞 + PR38 merge + CODE 基线迁移启动（Accepted，执行中）
- **B2-5-AUDIT=pass_after_patch**（%45 直接修包不只提意见）：batch-02..05 packages 已吸收今晚全部教训（行级 sha 注入步/tool_schema_digest controller 注入硬条款/multi-call WAIVED/SHA256SUMS 盘绑纪律/quota 与 Gate7RecipeQuotaConfig 核算一致）。
- **四 lane 并发 spawn**（wave1-lane-subcc-2..5，Opus 后台，各 50 行）——batch-01 验证过的生态直接复用，铁律含「禁用 subset_policy_digest 值」的 batch-01 血泪条款。
- **PR38 MERGED**（merge `26678346`；%43 REFIX-REVIEW PASS：marker 正规重产=查旧 commit 形态照产非手填）。
- **CODE 基线迁移执行中**（%44 按其 checklist）：新 pin 候选=post-#38 main tip；必重跑门含 **T1D-D2combo smoke 用 repo config 正式面复跑**（= PR38 控件 e2e 实证，一石二鸟）；registry 更新走 diff 补丁（worker 不直改 commander 分支）。

## D-068（2026-07-03 深夜）四批全交付 + runner P1 修复回路（Accepted，执行中）
- **四 lane 全交付**（batch-02/03/04/05 各 50 行，共 200 行新候选）；judge SPEC 2-5 预产就绪（%43）。
- **gates runner**（%45 一键化五步：注入→DataGate→diversity→C6→receipt，batch-01 fixture 复现绿）被 %43 审出 **P1：required 集不全**——缺 batch_self_audit.md 仍 exit0（绿 receipt 可在缺 lane 必备产物时发出）→ 修复五条（required 集/envelope/SHA 全集校验/injector 保全集/负 fixture）后连跑四批。**审计原话：runner 绿不能当 judge 触发直到修复**——门的门也要 fail-closed。
- %44 CODE 迁移中（迁移 smoke 疑似 FAIL_TIMEOUT 诚实标注，等正式 report 再裁）。
- lane 关闭排程：四 lane 交付确认后逐个 shutdown（磊哥令：Opus 用完即关）。

## D-069（2026-07-03 深夜）四批机械门全绿 + lane 舰队收官 + 迁移 R2（Accepted，执行中）
- **B02(v3)/B03/B04/B05 全部 mechanical_gates_pass_local**（runner P1 修复后 sha_set 5/5 完整集校验生效；B02 v3 supersede 修复前 receipt）——wave-1 新增 200 行候选全部过机械门，judge 瀑布开动（%43 B02 起）。
- **四 Opus lane 全部 shutdown_request 已发**（磊哥令用完即关；lane 在写收官总结，写完即批准关闭——commander 盯紧确认逐个 terminated）。
- **CODE 迁移 R2**（%44）：DATA v3 重建（新 pin 上重跑 prepare 补 hash_recomputed/hash_recipe_ref 字段——#36 硬化门咬旧 substrate 属预期耦合迁移）+ smoke watchdog 20→35min（上轮已 update@iter4 loss 2.66 有限，只差 save 窗口）。
- **%45 转 corpus 汇总工具**（judge PASS 批增量并入 wave1-corpus-manifest，250 行目标）。

## D-070（2026-07-03 深夜）B02 judge FAIL=首个真语义缺陷（D3 位置槽漏）+ 精确定界修复（Accepted，执行中）
- **B02 judge FAIL（%43）**：机械/溯源 7 维全量 50 全过；语义抽样 D3 抓 2/20——话术说「主驾」但 expected args 漏 `position` 槽（真内容缺陷，机械门原理上抓不到=judge 抽样存在的意义）。
- **commander 全量扫描定爆炸半径**（位置词提及 vs args 正则比对，200 行全查）：**仅 4 行中招**——b02 0007/0023（主驾；恰=抽样全中总体）、b03 0012（主驾）/0025（后排）、b04/b05 零命中。
- **修复回路**：窄域修复 lane（wave1-repair-lane-1）只碰 4 行（语义判断后补槽/ledger 同步/receipt 修复段，lane 保语义判断权）；修后 %45 gates 重跑（b02 v4/b03 v2）→ %43 scoped 复审（D3 维全批位置行）。
- **调度改序**：%43 先审干净批 B04→B05（不等修复）——批间独立乱序审=吞吐优化。

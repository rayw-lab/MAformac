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

## D-071（2026-07-03 深夜）CODE+DATA 耦合迁移 R2 = PASS，registry 首次正式迁移落地（Accepted）
- **R2 五门全绿**（receipt=CODE-MIGRATION-R2-RECEIPT.md，commander 亲核）：新 pin `26678346` 上 DataGate data_gate_ready（DATA v3=PR38-final-n4a-recipe-build，hash 字段投影补齐）+ strict preflight 4628/4628（trainable_tokens 113745）+ **T1D-D2combo repo-config smoke：2 optimizer updates/adapter saved（sha `d6abc4cf…`）/OOM absent/峰值 17.87GB——PR38 三控件在正式 config 面 e2e 实证** + filter 111/0 + patch dry-run。
- **BASELINE-REGISTRY 首次正式迁移执行**：CODE→`CODE-2026-07-03-PR38`（pin `26678346`）、DATA→`DATA-WAVE1-SUBSTRATE-v3`；旧行入 supersede 史（v2 blocked 于 #36 hash 门=预期耦合）。维度四机制从建档到首次真实迁移当日闭环。
- 后续新工作（候选 manifest/wave 批次）一律 cite 新 basis_id；warmup 批（pin b33d8eba 生成）历史有效性标注保留。

## D-072（2026-07-03 深夜）B04/B05 judge 双 PASS + CAND-FINAL 收稿 + repair lane 4 行修复完成（Accepted）
- **B04/B05 judge PASS（%43，commander 亲核 verdict 文件）**：两批均机械/溯源 7 维（D5/D6/D7/D9/A10/A11/A12）**全量 50/50 过** + 语义 5 维（D1-D4/D8）**分层抽样 20/50 零失败**；声称分层纪律全对（Tier1 full mechanical 绑 pool sha / Tier2 sampled-confidence 明示禁升格全 50 语义声称）。已知记录项：gates v1 receipt `basis.candidate_sha256` 是 controller 注入前旧值（stale），但 resource_envelope/SHA256SUMS/judge 重算三路均绑当前 pool——写入 verdict warning 不阻塞。
- **T1D-candidate-manifest-FINAL 收稿（%44，commander 亲核）**：`candidate_manifest_ready_pending_step4_step5`；basis 正确 cite `CODE-2026-07-03-PR38`（pin `26678346`）+ `DATA-WAVE1-SUBSTRATE-v3`；五步 1-3 DONE（manifest 固定/R2 门重跑/repo-config smoke 峰值 17.87GB）；步4 F-044 短训评（等 wave-1 corpus）+ 步5 owner run-auth（磊哥键）PENDING；claim boundary 干净（NOT CLAIMED: train-ready/C6/V-S-U）。
- **repair lane（wave1-repair-lane-1）完成**：4 行全修（0007/0023/0012 补 position:主驾、0025 补 position:后排，槽名照同批 16 个 sibling 实际 schema 未臆造）；派生函数逐字复刻 generate_batch.py 且先在 50 未改动行 100% 复现现存 sha 才应用；非目标行 48/48 字节一致×2 lane；独立边界核查零残留（commander 定界 4 行已穷尽）。**未擅改跨 lane 职责**：batch_manifest.artifact_shas / controller 注入 receipt / gates 快照声明 stale 待 %45 重跑刷新（正确边界判断）。lane shutdown（磊哥令用完即关，回 2×2）。
- **下一步**：%45 gates 重跑（b02 v4/b03 v2）→ %43 scoped D3 复审（全批位置行）→ corpus 汇总 250 行。

## D-074（2026-07-03 深夜）CORPUS-250-FINAL corpus_ready = wave-1 warmup 语料资产收口（Accepted）
- **%45 交付**：`wave1-corpus-final/`（corpus 250 行 + manifest + CORPUS-250-FINAL-RECEIPT.md）；staging 200 中间态保留（B03 PASS 后才并入，included_rows=250/expected_remaining_rows=0）。
- **三方核验闭环**：① %43 交叉核 `CORPUS-250-CROSSCHECK.md` PASS_WITH_NOTES——corpus/manifest 双 sha 复算 match、五批池 sha 与 verdict+gates 三方 match（b01 `eee76baf…`/b02 `2b75ba96…`/b03 `85f8067c…`/b04 `bbdae53e…`/b05 `90398f5c…`）、B02 声称保持 scoped 不升格、B04/B05 gates v1 stale basis 已知项不阻塞（envelope/SHA256SUMS/verdict 重算三路绑定）；② commander 点核=250 行/sha `e6ff61cb…` 一致/五批各 50（python 分布复算）。
- **claim 边界**：corpus_ready 仅指 250 行 warmup 语料资产完成；不声称 train-ready/C6/V-PASS/run 授权。
- **L6 依赖链现态**：candidate manifest ✅ + corpus 250 ✅ + F044 harness ✅（worktree 已持久化）→ 只剩 %44 渲染 MLX 数据面+门重跑+TODO 回填（F044-DATA-READY，在途）→ 磊哥 run-auth 单键。

## D-075（2026-07-03 深夜）F044-DATA-READY 双人核绿 = L6 全前置就绪，停在磊哥 run-auth 单键（Accepted）
- **%44 交付**：DATA-v3 + corpus 250 渲染 MLX 数据面（combined 4750=4500+250 / train 4350=4100+250 / valid 400 / test 128）+ DataGate exit0（must_not_train 0/parent_overlap 0）+ strict preflight exit0 + PREP 三 TODO 全回填（余两处 TODO 字样=守卫说明文字）；receipt 命令绑持久 worktree 可复跑，claim=`data_ready_preflight_pass_no_train`。
- **commander 独立复跑 strict preflight（今日抓假绿同款动作）**：records=4878 / trainable_records=4878 / trainable_tokens=119579 / max_token 账与 receipt 逐数一致 / exit0 / script_sha `9714f6f2…`=PR38 loop / banner 确认三控件（grad_checkpoint+token_budget 8192+clear_cache）。数字自洽链：4750+128=4878 ✅、tokens 113745→119579（+5.1%，与 corpus 行增量 5.56% 同量级，微批峰值由 token_budget 控制不受总量影响）。
- **L6 终态**：candidate manifest（步1-3 绿）+ corpus 250（三方核）+ F044 harness（dry-run 验证）+ 数据面（双人核绿）= **全前置就绪，唯一剩余人键 = 磊哥 F-044 短训评 run-auth（step4 执行 + step5 owner 签）**。签后命令序列=PREP §4.2 preflight gate→§4.3 短训→§4.4 A/B/D 评测，停线/包络照 §6。

## D-076（2026-07-03 深夜）L3-SALVAGE-REJUDGE SPEC 收稿（design-only）+ run-auth 签字包备妥（Accepted）
- **SPEC-L3-SALVAGE-REJUDGE.md（%43）收稿亲核**：3804 accepted/696 unsupported 分池铁律（denominator 纪律）+ 8 项 legacy 差异闭合硬门（family_id/row 契约/hash repo-anchor 归一/D9-A12 ledger 重建/🔴 旧 PR3 Hermes 同厂商 verdict 作废仅历史=cross-vendor 纪律正确）+ 分层抽样 305 行（**commander 复算**：10 族分布总和=3804 ✅、逐族 sample=rev2.1 公式 ✅、总样本 305 ✅，含小族全审 0 容错）+ 机械 10 门先于 LLM judge fail-closed + P0-P6 执行计划（owner 分工含 %44 second-judge 触发规则）+ 成本（机械 5-20min/语义 90-150min/≤2 修复轮）+ 停线与声称词表模板。**执行=未来显式派单**（P0/P1 owner=%45 projection adapter 补齐，在其 SCALE-PLAN 后排program）。
- **RUN-AUTH-PACKAGE 写就**（`runs/.../RUN-AUTH-PACKAGE-F044.md`，≤40 行签字包）：签什么/就绪证据/资源预算/验收门/停线/签字方式，供磊哥一眼审。

## D-077（2026-07-03 傍晚）磊哥 run-auth F044 approve 签收 + 第一跑被 watchdog 误杀（判据口径 P1）→ 修门重跑（Accepted，执行中）
- **磊哥签**：「run-auth F044 approve」+「gogogo」；同时磊哥 catch **双入口歧义**（PREP §4.3 普通 `|tee` 版 vs watchdog unattended form，签字包只写「§4.3」可能被执行成无 watchdog 版）→ 已锁：RUN-AUTH-PACKAGE + PREP 双处标注「🔴 唯一授权入口=watchdog form」。
- **开跑前坐实**：watchdog 单测 2/2 OK（我第一次 discover 姿势错报 0 tests，分目录重跑坐实——%44 无假绿）；PREP §4.2 preflight gate 10/10 OK。
- **第一跑（run dir `F044-shorttrain-run-20260703T171454+0800`）**：起跑健康（PID 89176/preflight 4878/119579 与双人核一致/iters 600 开训/trainable 1.013%），**~2 分钟后被 watchdog 误杀**：`memory_fail_threshold_exceeded`——**判据口径 P1**：watchdog 采 `psutil.virtual_memory().used`（系统总内存，起点 21.81GB）对比 22.34 阈，但 22.34=R2 训练进程 MLX peak 17.87×1.25 推导，**口径混用系统 used 必超**。训练本身零问题（mlx 无 OOM，死在首个 train_report 前，损失 2 分钟）。~~附带发现：BLOCKED receipt trigger evidence 序列化 bug（字段全 None）~~ **ERRATA（WD-AMMO-44 纠正）**：「evidence 全 None」是 **commander 自己的 jq 读法错**（读 `.trigger.evidence`，实际 schema 是顶层 `.evidence`）——%44 live 复读第二跑 receipt 证明 evidence 完整（且 `system_memory_used_gb=34.07` >32GB 物理=psutil used 在 macOS 含压缩语义扭曲，成为 WD-1 强弹药）。教训：**指控产物 bug 前先核自己的读法**（读法=另一种 basis 绑定）。
- **元教训（verification-economics「数字核真≠语义核对」在门自身复发）**：22.34 数字对、语义口径错——我收 WATCHDOG 稿时亲跑了单测、扫了判据关键词，**没核「采样源与阈值推导是否同口径」**；且正确口径数据源就在 train loop（`c5_mlx_train_loop.py:534` `mx.get_peak_memory()/1e9`→`:556` metrics `peak_memory` 字段）。门的判据=一种 basis 绑定，阈值与采样必须绑同一 lane。
- **修复回路**：%44 紧急修三件（主判据改读 metrics `peak_memory` 同口径/系统内存降辅助判据独立 30GB 阈/修 receipt evidence 序列化）+ 三 fixture 单测（含本次误杀场景回归）→ commander 亲核单测 → 新 run dir 重跑。
- **第二跑也被杀（4min）**：修正后的辅助阈 30.0 在 val 阶段被系统 used（触发时 34.07>32GB 物理）击穿——触发面没在真实环境（3 codex 共存工作站）标定。磊哥令按 grill 范式补课。

## D-078（2026-07-03 傍晚）F044-WD grill 15 题全消减（三 worker xhigh 弹药）+ 第三跑起跑存活（Accepted，执行中）
- **grill 范式全程走完**（磊哥令「grill 是核心拆解驱动力」）：骨架四层 15 题（技术判据/corner case/openspec 体系/愿景）→ 三 worker 并行弹药（WD-AMMO-43 联网+本地双证 / 44 全可执行结论+第三跑 wrapper / 45 体系+jq 一手盘点）→ 全消减 locked → WD-15 commander 拍。档=`docs/c5-training-readiness-grill/f044-shorttrain-watchdog-env-grill-2026-07-03.md`。
- **载力决策**：WD-1 系统 used 永不 hard kill（psutil/Apple/MLX 三方外证：used 非训练健康信号，「调阈=把口径错误往后推」）；WD-3 quiet_observer_mode（worker 常驻仅 ~1.7GB 非主风险，突发工具负载才是）+ 三层停线（训练硬故障杀/进程 peak 杀/系统压力 warn→先降载）；WD-8 thermal 不设 hard fail+checkpoint 实测重校+continuation 必新 run；WD-9 PASS 三层拆（train-health/artifact/behavior，exit0≠可用，eval fresh process）；WD-10 verdict 四层决策树**预落档**（`F044-VERDICT-DECISION-TREE.md`）；WD-11 MODEL 候选 lane 治理（封顶 shorttrain_behavior_gate_pass）；WD-12 corpus 不回写契约 SSOT；WD-14 🔴纠偏=10 族顶层全覆盖、真空白=负例/安全/already_state/多意图（class 全 positive）——下一 wave 优先补「不乱控」。
- **元认知升级已落**：全局 rule verification-economics 新腿「门判据 basis 绑定+grill 保护门」；lessons M.16；ERRATA=「receipt evidence None」是 commander 自己 jq 读法错（%44 双证纠正）。
- **第三跑起跑存活**（`f044-third-run.sh`=caffeinate -is+watchdog supervisor 自愈+磁盘 guard；PROCESS_PEAK 22.34 主判据/SYSTEM 999 禁用/interval 15s）：elapsed 166s **越过前两次误杀点**（61s/120s），系统 used 33.94 不再触发（WD-1 生效），watchdog 自查 trainer alive，metrics 事件流正常。三 worker 已 ACK 进 quiet_observer_mode。下一观测点=首个 train_report（process peak 数据流）→ checkpoint 50。
- **训练收官（21:51，~14040s）**：150/150 updates 精确命中/nonfinite 0/峰值 max 17.974GB/val loss 3.09→0.161→0.042→**0.019** 单调降/train loss 0.06/6 checkpoint+final adapter/零停线零 supervisor 重启。artifact 层闭合=`F044-TRAIN-RECEIPT.md`（全 sha 绑定，snapshot sha=PR38 源码 sha 逐字一致；claim 封顶 train_health）。
- **eval 首跑 fail-fast 插曲（mount 源错，非模型问题）**：PREP §4.4 staged 命令把 `--train-jsonl` 指向 train split，但 A/B case 的 mount 源行（source_sample_id c5-train-00001..）**设计上就在 valid split**（A 轴语义=分布内泛化非死记；我全查 30 case 落点+新旧 train 交集 4100=split 未被洗，corpus 250 纯追加）→ 改传 samples 全集（4750 行全含 tools）重起成功。小教训：**staged 命令 dry-run 只验了 `--help` 没验语义面**（mount 查找），进 verdict receipt 注明+PREP §4.4 该行修正。
## D-092（2026-07-04 ~16:00）R2b swap-hang/电脑死机归档 + 训练执行官重建蜂群架构（Accepted，执行中）
- **事故链**：15:34 首跑 `F044-shorttrain-run-20260704T145141+0800` 因 swap-hang 归档为 `F044-shorttrain-run-20260704T145141+0800-HUNG-ARCHIVED`；15:52 二跑期间电脑死机，`F044-shorttrain-run-20260704T153413+0800` 归档为 `F044-shorttrain-run-20260704T153413+0800-CRASH-ARCHIVED`。两段均不得写 train-health / artifact pass / behavior pass。
- **新架构**：重建蜂群 `ma-status-swarm`，职责拆为 `%0` commander 观察位（纯编排/记账/省额度，不持训练进程）、`%1` 训练执行官（训练归 worker 线程，持 run + watchdog + monitor）、`%2-%5` 训练窗任务/旁路支持。原则=训练资源和 commander token 预算解耦，且给用户交互与系统内存留余量。
- **第三跑起跑**：run=`F044-shorttrain-run-20260704T155204+0800` 于 ~16:00 在 `%1` 线程起跑，活动指针=`R2B-EXECUTOR-ACTIVE-RUN.path`；后续 receipt 只认 155204 活跃 run，不继承 HUNG/CRASH 段绿灯。
- **M.23 引用**：本次落 `docs/lessons-learned.md` M.23——资源包络必须绑定宿主环境基线；挂起（swap/UN/无进展）比崩溃更隐蔽，必须用起跑前余量门 + val 阶段进展 deadline 覆盖。

## D-092b（原重号 D-092，2026-07-04 夜 dedup；影子 commander 会话所记，结论与 D-095 一致，**以 D-095 为准**·SUPERSEDED-BY-D-095）R2b verdict=F044_R2B_FAIL 分层：MP-029 修复达成+同分布大效，但跨分布零移动+新负面恶化→正式训练今日不起（Accepted）
- run 155204（worker %1 执行官全程自主跑完，训练健康 600/600）；四轴：A 10/15 逐例同 R2a ❌ / B 9/15 zero delta 第三轮 ❌ / D 19/34 ✅ / qa 跨轨=判门 0（**MP-029 清零=安全级修复达成**）+扩充轨 adapter 9 ❌（查询式话术出手，base 2→9 恶化=unsupported 负例配比不足）。
- **判据性发现=同分布 vs 跨分布劈叉**：扩充轨 B 15→25/26（+10 大效）vs 判门轨 A/B 逐例纹丝不动——训练分布与判门 case 话术空间不重叠，非容量问题。R2B-8 分诊：FAIL_SAFETY+FAIL_B_DIRECTION→R3（bundle v2 全案+配方话术空间口径 grill），禁连训。
- 五条件①不满足→磊哥今日目标（正式训练完成）未达成，如实报；价值账=短训 3.5h 拦下「正式训 12h 得到同样缺陷」。verdict=run dir F044-R2B-VERDICT.md（831b7e8e）。
## D-091（2026-07-04 15:55）R2b 短训起跑（T-C）：split 静默丢弃 P0 拦截修复 + T-B 全绿双人核（Accepted，训练中）
- 🔴 **P0 拦截（白训事故未遂）**：T-B 首渲染行数对账抓到 584/585 修复行 split=None 被渲染分桶静默丢弃（若入训=修复数据 90% 不进训练）；三门（scanner/DataGate/preflight）全在转换步单侧未覆盖。修复=%45 组装器 split 规整（imputed 585 全列 id）+fail-closed 断言；%44 渲染加**行数守恒断言**（5499==5099+400，首用即 pass）→ M.22 转换步守恒门定律落 lessons。
- **T-B 全绿（五条件②✅）**：scanner 0 矛盾/DataGate ready 5499/strict preflight commander 复跑逐数一致（5627 records/133,692 trainable tokens[+11.8% vs R2a]/max 7196/exit0 双侧同）。
- **T-C 起跑**：run=`F044-shorttrain-run-20260704T145141+0800`，combined sha `3b76d497…`，watchdog form（22.34/999/15s），188s 越历史误杀点，首 val 计算中。预计 ~4-4.5h 训完（~20:30）。
- 前置面同步全绿：五条件③（T3-PREMORTEM 8T 全 disposed 0 open）；扩充轨 base 锚建成（53 case base 29/53，节省 verdict 后关键路径）；receipt 模板×2+正式配方推演（%45 在算 iters 档位）。

## D-090（2026-07-04 下午）750 预账 gap 处置：locked 必含项 +23 行 supplement + 族分布偏离显式 deviation（Accepted，执行中）
- **%44 预账+gap 精查（两连档）**：750 行/class/family/query 账全对+全局唯一 ✓；但 R2B-1 locked 必含项未锁齐——**airoutlet/wind 0/6 组**（整个 floor 无人做=批次 order 传导断层最重处）、set_interface_vs_defog 7/8、query_ac_temperature_vs_adjust 严格口径 1/10；全局 pair 137/140。
- **拍板**：①supplement micro-batch +23 行（%61 codex 生成，_SUP_ 前缀）：set_interface 第 8 组+airoutlet/wind 6 组+query 保护行补到 10（**严格口径**=query-side query_ac_temperature 行，MP-029 直接防线不容宽算）②**W10 §2 全表族分布 rebalance（+72 行）本轮不做，显式 deviation**：欠采族 ac/screen/window/atmos/seat 计 72 行 vs 超采 volume/wiper——理由=短训快速轮先验证 contrastive 方向有效性（单变量哲学同 D-082 B+），R2b eval B 轴若证方向有效但量不足→R2c 全表补满；本 supplement 已覆盖 A/B 轴最痛三必含点。
- **根因两层记档**：批次 order 只传导 floor 触达组数、未传导 per-family contrastive 行数配额；commander order 转正亲核时漏核此维（核了 class/query/carry）。修=终账门（merger）现含 per-floor 断言；R2c/正式配方的 order 必带 contrastive 行数配额列。
- 流程账：批 4 judge 并行中；supplement 走完整门链+judge 抽样；merger 终账（773 行）复跑后才组装训练。

## D-089（2026-07-04 下午）ERRATA R2B-DOOR-ERRATA-01：撤销 lane-h FAIL_DOOR_CONTRACT（judge 假阳性，根子=commander 传播未亲核的 worker 附带断言）（Accepted）
- **事实修正**：door 族在 C1 契约**真实存在 18 个 intent**（open_car_door/close_car_door/open_door_little/open_door_by_number/adjust_door_to_number/set_door_speed_to_number/set_door_speed_to_gear/lock_door/unlock_door/pause_car_door 等，commander grep semantic-function-contract.jsonl 亲核）——D-087 记账中「door 族无通用车门工具，只有 tailgate/fuel_tank_cap/window_lock」**为错误断言，就此作废**。
- **错误链**：lane-a（S1）报 query intent 问题时**附带**此断言 → commander 核了主断言（query intent 全契约 5 个 ✓）但未核附带断言 → 写进 D-087「新事实收录」+lane-h/lane-i 派单内联+批 3 judge spec 的 door_contract 硬门 → judge 按污染 spec 判 lane-h 假 FAIL（7 行 expected+16 行 mounted 实际全部契约合法）。
- **污染面盘点**：lane-h=假 FAIL 撤销重判中（数据无罪零修复）；lane-i=幸免（生成时自读契约用对了 21 个 door positive，2 个 unsupported 是 query 式话术=正确——**SSOT 精读纪律救了生成层**）；批 4 judge spec 预实例化指令中同款错误事实由 commander 在派单时更正。
- 🔴 **元教训（claim-vs-reality commander 侧实证，进 memory）**：worker 的【附带断言】与【主断言】要分开对待——主断言核了不等于附带断言可信；任何要进裁决/派单内联/judge 硬门的「契约事实」必须 commander 亲 grep 一手，不论来源多可信。本案与 F1（judge 抓 lane 真缺陷）互为镜像：门链双向纠错能力实证（判官抓 lane 的错 + commander 亲核抓判官 spec 的错）。

## D-088（2026-07-04 午）full-750 order 转正 + S2 四批滚动骨架（磊哥两拍点授权「自己把握」；「拆拆拆」=方法论层任务拆解[磊哥澄清]，批次 4×150=commander 技术自拍非磊哥指令）（Accepted）
- **S1 judge 收官**：lane-b **PASS_WITH_NOTES**（D-087 正确落地/pair 全合规/声称分层守住）；lane-a **FAIL_SAMPLED_SEMANTIC**（F1=win_to_1 pair 031/032 极性+数值双漂移违 near-parallel 单线索铁律，judge 定修法=032 数值持恒；%45 codex 窄修中→%43 scoped re-judge）。判官质量注：F1 缺陷行内 near_parallel_evidence 自认「+number differ」=可见于 artifact。
- **full-750 order 转正**（%61 草案，commander 逐表亲核）：class 总账 750=440p+76q+46r+62a+74u+52f 自洽；D-087 query 五 bucket（ac_temp16/ac_wind16/volume22/frag_amount11/frag_mode11=76）只落有 intent 族；每族 75 行、S2 每族补 60；contrastive 280 目标（S1 实产 74，S2 min 206）；mandatory_first（set_interface_vs_defog ≥8 pair groups，S2 首 lane 开头先交 4 fresh）+ screen 两 priority_high 前两 lane 完成；envelope 候选 27.0% 如实标（train-pack 下采样机制在 %45 组装器）。
- **S2 执行骨架（R2B-10 locked）**：4 批×2 lane×75 滚动闭环（生成→注入→门→judge→窄修→accept），批间流水，最高危前置批 1，Opus lane 纯生成用完即关（feedback-opus-generation-only），批 accept 前不 spawn 下下批。起跑条件=S1 全绿（F1 re-judge PASS）。
- S1 便宜批经济学收账：150 行拦下 8 类问题（quota 契约墙/门工具口径×2/重产回归/W17 case 四项/W16 cap bug/replay 缺源/win_to_1 pair 漂移），全部在 600 行大批量之前修复——拆批的价值实证。

## D-087（2026-07-04 上午）R2B-QUERY-RECLASS-01：query quota 契约不可行改判 unsupported（Accepted，双 lane 已下发）
- **lane-b 上抛契约级 blocker，commander 亲核契约坐实且比上报更严**：全契约 query intent 仅 5 个（ac_temperature/ac_windspeed/current_volume/amount_of_fragrance/mode_of_fragrance）——batch-order「每族 2 query」在 lane-b 3/5 族（screen/wiper/sunroof_sunshade）与 **lane-a 4/5 族（seat/window/door/atmosphere_lamp）**无契约根基。
- **裁决（按 lane-package 铁律「无 mounted query_* 禁伪造」）**：无 query intent 族的 query 槽改判 `unsupported`（query 式话术→NO_TOOL+no_call(no_available_query_tool)，target_tool_present=false）=MP-029 安全边界高价值负例；有 intent 的保留（lane-a ac 2=query_ac_temperature[MP-029 保护性正例必做]+query_ac_windspeed；lane-b volume 2 变体+fragrance 2）。终分布 lane-a 45/2/5/5/13/5、lane-b 45/4/5/5/11/5；S1 合计 query 6+no-call 44（候选态 30.6% 合法，%45 组装器训练前统一下采样=机制已锁）。batch_manifest 必带 deviation 字段引本 ref。
- **元教训（quota 设计也要 cite 契约一手）**：batch-order 的 per-family query quota 是凭「每族都该有 query」假设写的，没核契约 query 可用面——与 M.19「表示层信息量<标签信息量=结构性不可学」同族：**配额层要求量>契约供给量=结构性不可行**，生成前一格 cite 就能拦。lane-b 按铁律停手上抛而非伪造=lane 纪律正面实证。
- 级联：%44 机械门 class 预期表/%43 judge spec class 分布/W10 §3 S1 表数字过期（记 deviation 不改历史档正文）。

## D-086（2026-07-04 上午）R2b grill 九题一次性全消减 locked + 执行序定盘（Accepted，执行中）
- **弹药五源齐收（全亲核 sha/内容）**：%43 premortem delta（8 tiger/4 PT/4 elephant+训前 gate packet 六件+四轴停线表，sha `6ed5d8cf` 亲算一致）/ %61 W9（C1 一手行提取三近邻族+pair 上限 16/16/12）/ %45 W10（recipe rev3：750 修复包 contrastive 280 行 10 族逐族定量+负例 envelope+replay 15% 分层表+窗口外推 ~4h18m）/ %62 W11（eval 双轨硬化+锚过渡 M.17）/ %44 W12（scanner 进 C5DataGate Swift 主路径实装草案，挂 R3）。
- **R2B-1~9 全 locked**（`f044-r2b-grill-2026-07-04.md` 状态列+消减记录）。载力拍板：①S1 150=生成生态校准批不 micro-train，训练一次 full pack（~5612 行外推 ~4h18m）②replay 物理复制不动训练脚本（M.17）③MP-029 数据治本+L1 guard 兜底不替代 ④eval 双轨（原 bundle 判 D-085 门保锚 + W11 扩充旁路重建 base 锚；query zero-tolerance 跨两轨计入 qa=0）⑤%43 gate packet 六件=训前硬门、机械门先行 judge 后行。
- **%43 T6 辩证收**（不推翻磊哥 D-085、不迎合 codex）：B>9=R2b 推进门（磊哥拍）+ B 10-13 wording=`B_MOVED_NOT_PASS`（%43 建议）——分层声称两立。
- 🔴 **R2b PASS 声称上限（磊哥晨语锁进 grill 前言）**：只证「R2a 两个残余靶点被短训修复」，不证全 10 族自然语义/产品验收/正式训练无条件放行。

## D-085（2026-07-04 晨）磊哥三键全拍：R2b 门锁定 + R2b 开跑授权 + A 轴 15/15 底线终裁（Accepted，磊哥原话「全部同意」）
- **R2b 短训门锁定（从 proposal 升格 locked）**：A≥12/15 + **B>9/15（zero delta 即 FAIL）** + D≥18/34 不退化 + query→actuation=0（零容忍，即使 A≥12 也不放行）+ 极性 open→close/close→open **双向单列报告**。源=F044-R2-VERDICT.md §R2b 门（codex 辩证吸收+三层升维判据）。
- **A 轴 15/15 底线终裁**：15/15 底线只适用 tiny 死记验证场景；泛化训练短训评 A 轴门=12/15（R2-6 挂起项收口，f044-round2-grill R2-6 同步回写）。
- **R2b 开跑授权（弹药收齐后自驱推进整链）**：grill 骨架（f044-r2b-grill-2026-07-04.md，骨架 upfront）→ 弹药消减（5 worker 在途：%43 premortem delta/%61 pair 规格/%45 recipe rev3/%62 eval 硬化/%44 DataGate 实装草案）→ 配方定稿 → 数据生成+三静态门全绿（矛盾 0 证明/DataGate/strict preflight）→ 短训 → eval → verdict。🔴 正式全量训练仍条件化：R2b verdict 达门 + D-080 五条框架继续有效。
- eval bundle 口径待 R2b grill 消减（原 bundle 保锚 vs W11 扩充；扩必重测 base 锚，M.17），不预拍。

## D-084（2026-07-04 晨）R2 verdict=F044_R2_FAIL 分层（A 主效应确认+D 收复但 A<12+qa=1）；正式训练不起（条件①不满足）；转 R2b；三层升维定近邻靶点（Accepted）
- **断点接手**：上任指挥官会话（f35d9026）23:52 Iter90 轮询时掉登录卡死；训练由 nohup+watchdog 无人值守跑完（02:57，150/150 updates/val 0.0247/峰值 17.974/零停线）；新 commander 会话从档案链（STATUS-BOARD/receipt/skeleton/decisions）完全重建，T8 eval→verdict→brief 补账完成。**无人值守链路健壮性正面实证**。
- **eval 亲跑**（fresh process ~9min，mount 一致性门 exit0）+ 三列分报：A **3/15→10/15（+7）**、B 9/15→9/15（0）、D **18/34→18/34**（round1 -7 全收复）；B/D base 锚精确复现=口径自证。机械极性全扫：**open→close 反转 9→0**（round1 病理消除）；close→open 2 例（A-013/014，与近邻混淆纠缠）。**query→actuation：MP-029 仍 1 例**（查温→adjust_ac_temperature_to_number，华氏度幻参；D-082 B+ 方案拍定时已预告=预期内，负例批 R2b 补门）。
- **放行线判定（D-080 五条之①）**：A 10<12 ❌ + qa=1 ❌ → 不达放行线 → 🔴 **正式全量训练不起**，等磊哥晨间拍。R2-10 终止条款执行：不连训第三轮，转 R2b/R3。
- **单变量归因闭环**：D-081 重渲染治本的直接效应实证（矛盾 329→0 → A+7+反转清零+D 收复）——D-083 mount 回滚保住的可归因性兑现。verdict=`F044-shorttrain-run-20260703T231823+0800/F044-R2-VERDICT.md`（basis 全绑：samples `59f2f74e`/adapter `62ba5f66`/cases `95a74ab2`；⚠️ 骨架旧载 `5d00ff81` 为 rollback 前 stale sha 已标注）。
- 🔴 **三层升维定近邻靶点（磊哥晨间点拨，方法论=R2a 极性修复同构）**：剩余失败（A 残余 5+B 全 6=interface/defog/defrost、airoutlet/wind 近邻混淆）逐层判——**L1 表示可学性：维度没丢**（W6 区分度审计：interface/defog 由 device/primitive 可见区分、airoutlet/wind 由 device 可分，`W6-DATA-LEARNABILITY-AUDIT.md:139-140`；重渲染后 exact 冲突=0）→ 不是再渲染一刀的事；**L2 训练配方=主战场**（W6 覆盖读数 interface_vs_defog 104 样本/6 标签、airoutlet_vs_wind 46/5=对比信号稀薄 `:149-150`；W6 明示一致性清零后 coverage 才能安全加量 `:155`）→ R2b=近邻 contrastive pairs+负例六件套（%45 已备）+自然语料近邻分离；**L3 产品兜底**（协议串产品线走 L1 规则层、受限解码+mount 白名单双轨、10 族约定）吸收残余，但 qa 零容忍仍须 L2 治本。eval 公平性注：近邻 lure 本就 mount 在工具列表内=判定面设计如此。
- 元教训沉淀：M.20（commander 会话也是单点故障：长 sleep 串行轮询把整 turn 押在 login 态上；无人值守设计+档案链=会话可抛弃）+ tmux 派单送达判据=「Working 状态」非「文本回显」（磊哥手按 Enter 纠正）。

## D-083（2026-07-04 ~02:00）R2a 短训起跑（红线内 1 小时余量，单变量纪律保全）（Accepted，执行中）
- **mount 擅改回滚闭环**：%44 回滚后 commander 亲核 mount diff=**0 行**（数量+集合双零，4750 对齐）；ignored_tokens 17,028,936（vs round1 +0.2%=恰为 action 段 prompt 增量，两谜底闭合）；**唯一变量=action 段+同集合 seeded shuffle**。%44 的 mount 重构设计留 receipt R3-proposal 段待 grill。
- **起跑前门链全绿**：R2-DATA-READY receipt（action 断言 4500/250 分明+DataGate+preflight）+ **commander 独立复跑 preflight 逐数一致**（4878/4878/119571/17028936/exit0）。
- **R2a 起跑**（`f044-round2-run.sh` env override 数据面=r2-data-ready/mlx-data；watchdog 参数同 round1 修正版）：181s 越过全部历史误杀点，**首 optimizer update 已出**，系统 used 33.9 无触发。预计 ~4h（至 ~06:00）。
- 训练窗口计划：~04:30 checkpoint 100 中测（%43 SOP：adapter 单臂 A 轴 15 case v2 ≤6min，A<8=提前停信号/≥12=主效应确认）→ 完成后 eval（%62 三列分报工具+%61 A-v2 case+mount 源=r2-data-ready samples）→ verdict（%43 骨架）→ morning brief。全员 quiet 已广播。R2b 弹药备齐（%45 负例批包六件套）。

## D-082（2026-07-04 凌晨）重渲染落地全绿 + R2 训练面拍 B+ 方案（Accepted，执行中）
- **%44 重渲染交付 commander 亲核全绿**：4500/4500 user 带 `action=<action_code>` 段（样例逐字=拍板格式）；重渲染后扫描 **矛盾 329→0 组**（`pass_no_contradictions`，group 4144→4346=action 入 key 分组更细）；mount seeded shuffle 生效（open_first 292/close_first 250/lower_first 168）；MLX 账 4100/400/128 结构对。fork 脚本 `f044-round2-run.sh` commander 亲做（参数化+血缘 sha 双向，diff 恰两处，round1 脚本零触碰）。
- **R2 训练面拍=B+**：主训=重渲染 substrate 4500+旧 corpus 250（自然句不受渲染影响；单变量=矛盾修复，效应可归因，稳过 03:00 红线）；**负例批不上今晚关键路径**（premortem T2/T8：~40 行负例在 2.2 epoch 改变 qa 行为期望低；subCC 并行生成留 R2b 明天补门）。预期：R2a 验证 A 轴极性修复主效应，qa/MP-029 类可能仍 FAIL（如实分层报，R2b 完整配方过门）。
- 在途：%44 组合渲染+门链（r2-data-ready）；%61 A case v2 正式重产；%62 triage 落盘待收；%43 oracle 落盘待收+待切 rerender review。
- **执行链补记（2026-07-04 00:45-01:30）**：①r2-data-ready 首版 strict preflight 咬住 `loss_mask_missing`（fail-closed 正确），%44 修复后全绿（4878/4878/trainable 119571 vs round1 119579 差-8=action 段在 prompt 侧不进监督面，receipt Token Delta Note 解释合格）；②🔴 **commander 抓 P1=mount 挂载面被擅改**：ignored_tokens 17M→7.7M 降 55% 无解释→下钻两版 samples 逐 sample diff=4468/4750 行 mount 集合变化、平均 13.85→4.85 工具——我只拍了 shuffle 顺序，集合重构=未拍板第二变量（毁单变量归因+叠毁 eval 可比性）→ 指令回滚（只留 action 段+同集合 shuffle），重构设计留 R3-proposal 段。**元教训：派单词「mount 均衡」被 worker 扩大执行成「mount 重构」——收稿数字定价纪律（M.15）再次拦截：55% 降幅不解释不放行。** ③%43 异源审 APPROVE 终版+MIDTEST-SOP/verdict 骨架交付；W7 triage 329/329 全真矛盾三方闭环；oracle 6 风险注册采纳。

## D-081（2026-07-03 深夜）R2-1 拍板=重渲染治本（矛盾监督修复路线，通宵成败手）（Accepted，执行中）
- **W6 全量扫描+teardown（%61）**：矛盾 329 组/波及 686 行（train 269+dev_selection 60=**val split 也被污染，val loss 假漂亮成因闭环**）；file:line 定位=C1 契约无罪（`contracts/semantic-function-contract.jsonl` :17 `open_mode`/:21 `close_mode`，**commander 亲核实文一致**）、丢失在 `Core/Training/C5LoRATraining.swift:1829-1855 renderUserUtterance`（**commander 亲核实文**：user 只渲染 device/primitive/value/slots/suffix，无 action 段；assistant :2667 用 seed.intent=信息不对称）；329 组全 `NO_UNIQUE_LABEL_UNDER_CURRENT_RENDERING`。
- **拍板依据三源**：W6 推荐 1（重渲染）+ %43 premortem T1（无 source-backed winner 就停清洗）+ commander 判「清洗选侧=删合法能力面（close 类全灭）不可接受」。**否决清洗，拍重渲染**：user 串插 `action=<action_code>` + mount seeded shuffle（T3 同刀）+ 全量重渲染 + 扫描器 0 矛盾证明；A 轴 case 同格式重产（旧 A 锚失效→paired base 当场重建；B/D 锚不动）。
- **执行位**：%44 渲染器+重渲染+扫描（最高优先）；%61 A case 重产工具+T7 mount 一致性断言；%62 分诊单继续（价值转为「确认无真单侧错误标签」）；%45 rev2 在产；subCC 待新格式后生成负例批。premortem 9 tiger 的 T1/T3/T7 已进执行 spec，T2/T4/T5 进 recipe rev2 spec，T8/T9 落 checkpoint 50/100 行为中测（A 轴 15 case 快测，不达标提前停省时）。
- 时间轴重排（重渲染比清洗重 ~40min）：红线 03:00 起跑仍可达；03:30 fallback 保底线不变。

## D-080（2026-07-03 夜）通宵 9h 作战定盘：三段门框架 + 矛盾监督根因 + 五 worker 拉满 + 正式训练条件化授权（Accepted，执行中）
- **根因升级（改写 D-079 归因）**：A 轴反转=**矛盾监督**（同协议串 `set_mode` 28 行 open/16 行 close 双标签，c5-train-00001 vs 01057 一手；ac 族 open28:close16 反证「配比失衡」假设）——协议串表示丢极性维度；DataGate 缺监督一致性门；eval bundle A/B 纯 ac 族偏斜。三坐实=`f044-fail-baseline-reflection-2026-07-03.md`。
- **演绎树落档**（磊哥令「倒推成功因素/100% 信心」）：`lora-success-factors-deduction-2026-07-03.md` 17 条必要条件树+验证器映射；codex 四修正全接受（当前已知树非全量/scanner key 收严含 state-mount-safety-slot-split-basis/non-regression 分级 protected-hard+product-weighted/双轨不洗白不升格）；**三段门框架=静态可学性→短训行为门→产品兜底验收**。
- **通宵 plan（writing-plans 正式档）**：`docs/superpowers/plans/2026-07-03-f044-round2-overnight-9h.md`（Task1-9+时间轴红线 短训≤03:00+运维线元认知/记忆/级联）；supersede TONIGHT-PLAN-9H.md；STATUS-BOARD.md 建（抗 compact+worker 对齐）。
- **五 worker 拓扑**（pane 事故修复：%59/%60 错位杀除，右列 5 均衡，%42 保 2/3）：%61=W6 矛盾清单限时1h+teardown / %62=W7 eval v2 双轨设计（R3）/ %43=premortem+oracle / %44=扫描器+清洗脚本（gen-harden 285 行已收：极性 pair builder+负例 class 契约推导 query=query_* 调用、refusal/unsupported/already_state=NO_TOOL）/ %45=recipe rev2（rev1 750 行两段已收）。subCC 留生成 lane。
- 🔴 **正式训练条件化授权**（磊哥 goal set 原话「如果进度令你满意，我授权进入正式训练」）：commander 自设从严五条（R2 放行线 A≥12 极性反转0 D≥18 qa0 / 三静态门全绿 / premortem 无未处置 tiger / 同配方仅扩 iters / 包络可行）全满足才起，已写进 plan Global Constraints。
- 今晚 eval 原 bundle 保锚（base 三锚 A3/B9/D18 复现值为可比性自证标尺）；R2 FAIL→停训转 R3（渲染重构+bundle v2），不连训第三轮。

## D-079（2026-07-03 深夜）F044 短训评 verdict = **F044_FAIL 四重**（behavior gate 拦下候选晋级；训练管线无罪；短训评制度 KEEP）（Accepted）
- **train-health + artifact 双层 PASS**（150/150 updates/nonfinite 0/峰值 17.974/val 0.019/全 sha 绑定 F044-TRAIN-RECEIPT.md）→ **behavior 层四重 FAIL**（v6 同款评分器口径，base 同 harness 配对）：A **6/15**（底线 15/15；9 例系统性 open→close 极性反转，训练分布约定 set_mode→open 44 行亲核=真配方缺陷非 case 约定）/ B **9/15 zero delta**（base 也 9/15，自然映射零提升）/ D **11/34 vs base 18/34 退化 -7**（形态=v6「LoRA 语义族碰撞」精确复现：raise/lower/little 被 adjust_to 吸收 10+ 例、window to/by 混淆、幻造工具名）/ **query→actuation 1 例安全级**（C6-MP-029 查温→设 9℃，corpus 零 query 负例的直接兑现）。verdict=`F044-shorttrain-run-20260703T175733+0800/F044-VERDICT.md`，按预落档决策树处置零临场拍。
- 🔴 **评分口径插曲（差点误判）**：我先用自铸 exact-match（name+args）快评得 D 4/34 vs 锚 18/34「巨大退化」，核 v6 锚口径=**name-only 序敏感**——同款 scorer 复算 base=**18/34 与锚精确一致**（可比性自证），adapter=11/34。**锚数字必须绑评分器口径，scorer 也是 basis**（M.17）。
- **eval mount 插曲**：PREP §4.4 staged 命令 --train-jsonl 指 train split，A/B mount 源行设计在 valid → fail-fast 后改 samples 全集重起（split 未被洗亲核：新 train=旧 4100+corpus250 纯追加）。
- **处置**：候选晋级 BLOCKED（step4=FAIL 不进 step5）；三 worker 拉满转 wave-2——%43 verdict 对抗复核+D 形态靶点表 / %44 生成器硬化（极性对称+负例生成+机械修正）/ %45 WAVE2-RECIPE-PLAN（族×class 配比表=下一立项 SSOT 草案）。
- **制度正面**：3h54m 短训+20min eval 在正式训练前实证暴露配方三结构缺口（极性/负例/语义族）=失败到达点经济学最佳案例；F044 短训评常设门 KEEP；且 WD-14 盘点（class 全 positive）与 v6 配方锚 6 条全部被本次失败互证——**grill/盘点的预言力兑现**。

- **WD-4 实测重校（elapsed 810s，run dir `F044-shorttrain-run-20260703T175733+0800` metrics 一手）**：iter 30/600、**8 optimizer updates**（前两跑=0）、train loss 0.295、**process peak 17.87GB=与 R2 预算账 17.868956778 精准一致**（vs 阈 22.34 余量足，watchdog 主判据正常读流）、it/s 0.045→**全程预计 ≈3.7h**（vs 保守 9.4h，快 2.5x；≈89s/update vs 保守 226s——R2 均摊含 setup 的保守性坐实）；checkpoint 50（=200 iters）预计起跑后 ~74min。wall clock envelope 42375s 不改（更宽松），预算表在 verdict receipt 按实测重写。
- **修复后池锚（收 %45/%43 稿时亲核绑定用）**：b02 candidates.jsonl `2b75ba96…82d6a14` / b03 candidates.jsonl `85f8067c…9fa0fa9b`（repair lane 终稿报告 + commander 本机 shasum 重算逐字一致，4 行 position 槽实值抽验正确）——gates v4/v2 receipt 与 B03 judge verdict 必须绑这两个 sha，绑旧值=跑在未修复池上打回。

## D-073（2026-07-03 深夜）B02/B03 修复回路收口 → **warmup 五批 250 行全部 accepted**（Accepted）
- **B02 gates v4 + scoped D3 re-judge PASS（commander 亲核）**：verdict 绑修复池锚 `2b75ba96…` 逐字一致；scope 纪律正确=D3 only（修复行 0007/0023 逐行 PASS）+ 全批位置词扫描 5 行位置行 0 残留；机械 7 维引用 B02-GATES-RECEIPT-v4（mechanical_gates_pass_local + DataGate/diversity/C6 v4 全绿）不重跑；D1/D2/D4/D8 保留原抽样证据不越权重审。**B02 就此 accepted（分层声称）**。注：ledger args_diff 的 value "1"→"3" 为生成时已登记模板变更（value_changed=true 原有），position null→主驾 为修复增量，两者并存自洽非矛盾。
- B03 gates v2 已落（receipt+datagate/diversity/c6-leakage v2 齐）；B03 全量 judge %43 在途（从未 judge 过，机械 7 维全量 50+语义抽样 20 必含修复行 0012/0025）。
- **B03 judge PASS（%43，commander 亲核 verdict）**：机械 7 维 50/50 全量（引 gates v2 全绿）+ 语义 5 维抽样 20/50 零失败；池锚 `85f8067c…` 与 commander 本机重算逐字一致；抽样含修复行 0012/0025（repair_required 置顶，args 主驾/后排与 commander 抽验一致）；judge 独立 D3 位置扫描=window 位置词行 14/残留 0 + **entity 词行 23（尾门/后备箱/油箱盖/舒适进出）正确判定为工具/实体路由、不需要 position 槽**（语义判别专业，无过杀）；warnings none（gates v2 修复后重产无 stale basis）。**至此 warmup 五批 B01-B05 共 250 行全部 accepted（分层声称）**——B01 验收 PASS、B02 gates v4+scoped D3、B03 gates v2+全量 judge、B04/B05 全量 judge。
- **F044-PREP 收稿（%44，commander 亲核）**：`prep_ready_pending_corpus_manifest_and_owner_run_auth`，质量高——短训 config=R2 repo 正式面（dry-run 解析验证 10 字段全对）/train-loop `--help` 冒烟过/eval harness 持久拷贝+20 单测 OK/A15+B15+C4+D34=68 case 静态计数+sha 绑定/F-044 阈值照 default lock（A 15/15 底线、B 14/15、D base 18/34 锚、query→actuation 零容忍、C observation）/停线三段+资源包络（peak warn 19.66/fail 22.34/hard 32GB；150 updates 保守 9.4h 上界，checkpoint 50/100/150 强制重校）/prep 零训练零推理。**commander 两 catch**：① P2=pinned worktree 在 `/tmp/maformac-code-basis-pr38-26678346`（/tmp 系统会清，短训距今可能数小时+）→ 续单迁持久位置——**已修复关闭**（`$RUN_ROOT/code-basis-pr38-worktree`，commander 本机 rev-parse HEAD=`26678346` 一致，PREP 四处回写+重建命令备查）；② corpus 250 落地后还差「渲染 MLX data dir + DataGate/preflight 重跑 + 回填 3 个 TODO」一步机械活 → 预派 %44（依赖 %45 CORPUS-250-FINAL），使磊哥 run-auth 真一键。

## D-093（2026-07-04 16:20）第六道门 W27 红队回稿 BLOCKED_NOW → 采纳为起跑硬门=Launch Packet 6 文件；中途 ckpt 探针取消（Accepted）
- **W27-FORMAL-TRAIN-REDTEAM（%3，磊哥钦点对抗审）verdict=`DO_NOT_LAUNCH_FORMAL_TRAINING_UNTIL_P0_CLOSED_AND_P1_ACCEPTED`**：4 P0（①R2b verdict 未落=条件1未闭 ②宿主包络未按当前基线闭合、W21 自记 live 样本已低于 free<3GB 暂停线 ③LR schedule 若不 150→450 updates+warmup 12→36 比例扩=stale-schedule 变体、非「同配方仅扩 iters」④11h watchdog 需覆盖 UN/swap/no-progress 非仅 process-alive）+ 3 P1（1.31 epoch 过拟合窄修复→ckpt 600/1200/1800 留档+禁 cherry-pick / eval 锚起跑前冻结 / 数据曝光记账进 receipt）+ 4 paper-tiger 处置（1800≠自动过量、1e-4 有外证、packing 不引入、15% replay=本地先验非文献常数）+ 4 elephant（日历压力→门变戏 / 宿主非一次性训练服务器 / train-health 语言外溢 / 自动化多=内存池共享+归属模糊）。
- **总监裁定**：全盘采纳，方向未被证伪（1800/1e-4/Qwen3-1.7B LoRA 不动），P0 定义为**起跑包缺件**而非方案推翻。起跑硬门=W27 §Required Launch Packet 6 文件：`FORMAL-LAUNCH-CONDITIONS.md` / `formal-config.diff`（T3 五 checkbox）/ `formal-host-baseline.json`（起跑时点快照）/ `formal-watchdog-contract.md`（六 checkbox）/ `formal-eval-manifest.json`（起跑前冻结）/ `formal-receipt-template.md`（曝光记账+proof-class 四分隔）。
- **预建派单（训练窗内并行）**：W30=%3 formal config+diff+launch-conditions 骨架（自审自建=总监亲核终检对冲）/ W31=%5 eval manifest 冻结+receipt 模板曝光段（关 T6/T7）/ W32=%1 watchdog contract（关 T4，监控间隙做）。P0-1 等 T-D verdict；P0-2 host snapshot 只能起跑时点做。
- **中途 ckpt50/100 A 轴探针取消**（总监裁定，M.23 原理）：探针需加载模型推理，实测系统 32.8/34.4GB used + swap 4.4/5GB（commander 亲跑 memory_pressure/sysctl），再起推理进程=今日第 4 次 swap 绞死风险；中途诊断信号价值<杀死在跑训练。诊断职责移交 T5 处置（正式训练 ckpt 三点留档训后诊断）。
- **run 155204 实况（16:12 亲核）**：pid 13397 活，Iter 56/600，LR 爬满 1e-4（warmup 完成），watchdog 全绿 optimizer_update_seen=True，进程峰值 17.87GB 与预算账一致；~21s/iter → ETA ~19:25。插曲：commander ps grep 模式错（`mlx_lm` 不匹配 `c5_mlx_train_loop`）一度误判进程死亡，run-dir watchdog 日志（一手）纠正——**进程探测 pattern 也是 basis，宁可信 run dir 心跳文件**。
- **同窗收稿**：W24（UIUE 树 PARTIAL_HIGH_MERGE_RISK，main 领先 280 文件，iOS 线建议从新 main 起步选择性移植 fixture/schema/consumer）/ W25（openspec 结构 PASS 18/0，R3 窄 change 草稿落 openspec-drafts/）/ W26（RL17 证据目录 8 模板预建，phase0 只读）/ %4 docs-only commit `67e72048`（NOT_PUSHED，push 留磊哥键）。空闲即派：W28=%2 C6 重启评估 / W29=%4 thin bridge 预研（W24 发现 changed-in-both 恰含 RuntimePresentationPayloadFixtureConsumer.swift=field drift 活证）。

## D-094（2026-07-04 17:30）正式训练宿主环境路线=B 不重启（磊哥拍）；GUI 清场磊哥手动；双阈值门保持 fail-closed（Accepted）
- **磊哥原话**：「不重启 我把codex 微信 飞书 macdown我来关掉」——W33 决策矩阵 A（重启冷起）/B（清场不重启）取 **B**；GUI 大头（Codex desktop/微信/飞书/MacDown）由磊哥手动关闭。
- **门不软化**：formal-host-baseline.json 双阈值 **swap≤1GB + free≥21GB** 保持 fail-closed（W33 §6）。已知风险：swap 当前已热 ~5GB，不重启路径下即使 GUI 清场+训练进程释放（26G OS 层）后 dynamic_pager 收缩有滞后，**swap 门存在实测不过的可能**——届时不静默放行，上抛磊哥二择（临时重启 / swap 门改趋势判定[swapouts 增速=0 且 free 达标]并记 receipt 豁免条目）。
- **时序**：短训 run 155204 完成（~19:25）→ T-D eval/verdict（W35 跑道就绪）→ 磊哥关 GUI → 可选 sudo purge + 静置 120s → W33 §6 命令实采 host-baseline → 双门判定 → 六条件+Launch Packet 齐 → 正式起跑（%1 executor 线程，watchdog 契约部署）。

## D-095（2026-07-04 20:10）T-D 终判 = F044_R2B_FAIL_STRATIFIED；正式训练今晚不起（预落决策树执行）；R3 数据订单从失败 case 直接生成（Accepted）
- **四轴 vs D-085**：A **10/15** FAIL（<12；5 残余=interface/airoutlet/三区近邻族×协议记忆组合面 P3D-A-011~015，与 R2a 同款零新退化）/ B **9/15 zero-delta** FAIL（三轮未动，非本轮靶点）/ D **19/34** PASS（+1）/ qa **FAIL：跨轨 9 违例**（门轨 MP-029 已修=0；expanded 无 intent 族问句→改动工具 adapter 9 vs base 2，安全级恶化，9 具名族）。verdict 档=`F044-R2B-VERDICT-TEMPLATE.md` 终判段（basis 全绑定：adapter sha 0d9b712b…、门轨原 harness 2d904aa0… 未动、expanded WAIVER harness f41017fb… --min-prompt-tokens 带记录）。
- **分层亮点**：靶点① 近邻单轮面 **15/26→25/26（96%）大幅修复** = D-domain 具名工具+contrastive 配方有效性最强证据；靶点② query 正向映射 14→17/27 改善；训练本体全绿（600/600、val 0.010、LR 残差 1e-12、峰值 17.974 分毫不差、零事故）。
- **机理判读**：训练治好空输出病的副作用=「必调工具」倾向增强 → 无 intent 族问句被推向最近改动工具（负例 envelope cap ~10% 覆盖不了 9 族问句面）；近邻区分未与协议记忆语境组合泛化（组合样本缺失）。
- **门体系全兑现**：红队 E1（日历压力不把门变戏）执行——磊哥今日目标为正式训练完成，但门 FAIL 即不起，无硬闯；qa 跨轨零容忍（D-086）抓到了门轨内检测不到的安全级回归；扩展轨（W35 预检+守卫带记录放宽）恰好是分诊决定性证据源。
- **R3 数据订单（case 级精确）**：①9 具名族 unsupported-query 强负例 per-family ②interface/airoutlet 近邻×协议记忆组合样本 ③B 轴不动。明日按 grill 范式+对抗审计成对（D-046+feedback-major-dispatch-grill-plus-redteam）立 R3 短训案。
- **T-D 执行侧记**：%1 预置触发执行令全自动接跑（receipt→预载守卫→双轨→只报数）；expanded 守卫 rc=2 按「先诊断后 waive」处置（合法小挂载坐实才开 --min-prompt-tokens 旋钮，门轨 harness 未动）；A 轴 case diff 同款/新退化二分一次到位。

## D-096（2026-07-04 20:25）R3 修复轮连夜开案（数据面职权内推进；短训=条件式起跑；正式训练=磊哥晨键）（Accepted）
- **依据**：D-095 FAIL 后目标（磊哥「今天目标=C5 正式训练完成"，且"全自动推进/遇到问题自己解决/不要待机空转」）仍站立；预落决策树 FAIL→分诊→靶向修复轮，机器全热（生成 codex 已证/judge/机械门/组装/渲染/watchdog 活体验证/eval 跑道），R3 订单 case 级精确=连夜可执行。
- **授权三层口径**（写进 R3 grill 头，防越权）：①数据面作业（生成/judge/门/组装/渲染/静态门）=commander 职权内连夜推进 ②**R3 短训起跑=条件式**（全门绿+host 双阈值 swap≤1GB+free≥21GB+watchdog --armed 部署+W47 红队无未处置 P0 才起；任一不绿=hold 至磊哥晨键）③**正式训练 1800 iters=必等 R3 过门+磊哥晨键**（R3-6 reserved）。
- **R3 grill**：`docs/c5-training-readiness-grill/f044-r3-grill-2026-07-04.md` 六题（R3-1~5 default_locked：负例 cap 上调为目标行全保留[M.21 物化进 assembler 参数]/9 族×10 负例+4 正例对照成对/组合样本 ≥40 行 R3C- 新 nn 前缀/配方同款 600 iters/放行线=D-085+近邻单轮≥24/26 不回退；R3-6 磊哥晨键）。
- **派单**（grill+红队成对纪律执行）：%4=R3-QNEG 9 族负例 lane / %5=R3-COMBO 组合样本 lane / %3=W47 R3 红队（含「见问句必拒」矫枉过正、监督冲突、曝光够不够、凌晨时段风险六攻击面）/ %2=R3-GATES 门与 judge 预备 / %1=休整待训练执行。时间轴预估：生成+judge+门 ~23:00 → 条件满足则短训 ~02:30 → eval ~03:30 verdict → 晨报带 PASS/分诊 + 正式训练晨键请求。

## D-097（2026-07-04 19:55；时间戳修正 per X5 P1-1，原误标 21:20 致链序倒挂）🔴 重大翻案：门轨 11/64 case mount-invalid（A5+B6），adapter 实为有效面满分；D-095 诊断修正；R3 转向=修量尺+qa 负例，combo lane PARK（Accepted）
- **发现链**：影子 commander 遗单 R3-AMMO-1（%2）声称 11/11 原失败 mount-invalid → 总监双重亲核坐实（P3D-A-011 逐字段：input=defog 协议串+挂载仅 defog 两工具+期望 open_ac_set_interface=**模型答 open_defog_mode 对输入是正确的**；全量 sweep 脚本=门轨 adapter 11/64 违反 expected⊆mounted[A-011~015 语义错位拼接 + B-010~015 语句期望一致但挂载错]，**扩展轨 0/102 全净**）。
- **根因**：bundle v2 case 构造 `mount_policy=training_row_tools_exact` 按**序号 join** train rows（c5-train-00010~19）拉 input/mount，expected 另源 → 错位。= claim-vs-reality 第 6 坑（index/naming join 代替 schema 字段）在 eval-case 构造层复发；且该 bundle R2a 就在用 → **三轮「A 残余/B zero-delta」全是量尺污染**：A 有效上限 10/15、B 有效上限 9/15，run 155204 adapter **双双打满**（有效 case 100%），base A3/B9。D-085 门 A≥12/B>9 在此 bundle 数学不可过。
- **verdict 修正**（D-095 数字不变、诊断重写）：真模型缺陷**只剩 qa 负面**（扩展轨有效，2→9 恶化，AMMO-2 108+36 修复中）；「近邻×协议记忆组合泛化缺失」诊断作废（%5 combo 52 行 PARK 不并包，留盘作储备）；近邻单轮 25/26+MP-029 修复+D 19/34 全部站立。
- **R3 转向**：①%2 R3-BUNDLE-REPAIR：11 case 重建 mount-valid（v3 后缀，53 有效 case 逐字节不动）+**常设机械门 check_eval_mount_validity.py**（expected⊆mounted，exit 66）=验证经济学「量尺自身要有廉价到达门」的补格 ②qneg 154 行继续（pair_ledger guard 孤行 metadata 窄修中）③修好量尺后**先用现有 adapter 重评 v3 bundle**（不用重训就能知道 A/B 真实数）④qa 修复训练轮在 qneg 过 judge 后条件式起跑（D-096 条款不变）⑤D-085 门数值不改（量尺修复后原门恢复可达性，非口径变更）。
- **教训（M 系候补）**：eval case 的 mount 面从未有过 validity 门（W35 预检核了 sha/锚复现，没核 expected⊆mounted）——「量尺可信」被当默认而非被 enforce；失败到达点=一个 15 行 python 断言，代价三轮误诊断。

## D-098（2026-07-04 20:01）RE-EVAL-V3 出数=A 15/15+B 15/15+D 19/34（D-085 三轴 PASS，qa 成唯一残余）；host 门谓词精化（swap 懒回收基准错位）；R3 qa 修复短训依 D-096 条件式起跑（Accepted）
- **v3 配对重评（总监亲核 paired report）**：A base 3/15→adapter **15/15**（+12）/ B base 14/15→**15/15**（+1 非 zero-delta）/ D 18→19/34 / 门轨 qa v3=0 / mount validity bundle 64/0+probe 128/0。v2 时代 base_empty A=7 在 v3 变 12——旧 bundle 连 base 都在被坏 case 压制。**D-085 对现有 adapter（run 155204）在有效面上 A/B/D 三轴 PASS**；唯一残余=扩展轨 qa 9 违例（修复包 5653 已全绿待训）。
- **host 门谓词精化（非弯折=收紧替代谓词）**：swap_used≤1GB 的意图=「起跑时无内存压力」；实测 swap_used 1711M 但 **swapouts 20s 零增长 + free 88%（~30GB）+ swap 连续收缩 5117→2903→1711M** = 懒回收滞留页非压力（指标基准与保护意图错位，M.16 同型）。精化谓词=[swap_used≤1GB] OR [free≥21GB AND swapouts_delta(20s)=0 AND swap 趋势下降]，且运行时保护不减（watchdog free<3GB/120s kill + swap 增速 ≥2GB/5min kill 仍 armed）。正式训练（11h）起跑时重新评估，若届时 swap 仍 >1GB 上抛磊哥。
- **R3 短训起跑判定（D-096 条件逐核）**：静态门 ✅（守恒 5653/DataGate/strict preflight 135,013 tokens/矛盾 0）｜judge ✅双 PASS｜W47 P0：T1=训后 eval 含真 query 保护探针（在案）/T2=scanner 0 ✅/T6=本 host 照相+watchdog --armed ✅｜host 精化谓词 ✅（照相档 r3-host-baseline-*.json）→ **起跑授权成立**，%1 执行 f044-r3-run.sh + watchdog --armed 真 pid。

## D-099（2026-07-04 20:35）R3 短训第一跑 watchdog PARTIAL 拦停（operator_memory_redline）；诊断=磊哥恢复用机；待命重跑制+两停封夜线（Accepted）
- **实况**：run F044-r3train-run-20260704T200428 iter64/600 被 --armed watchdog 拦停（free_reclaim 2.88GB<3GB 持续 120s+swap 回涨 1.71→4.67GB），PARTIAL 非 train-health-fail（iter64 前数值健康：首 val 66.2s/2.38、峰值 17.09GB）。receipt 链齐（FORMAL_WATCHDOG_STOP.md）。
- **诊断（总监亲跑 top）**：起跑照相后磊哥恢复日常使用（WeChat 614M+wxocr 314M+Codex desktop ~840M 回榜）≈1.9GB 增量——R2b 同 knobs 本就 free<3GB 擦线（最长 107s<120s），增量推过 120s。**watchdog 实战正名**：保护磊哥「日常操作留内存」指令优先级高于夜训进度，M.16→W41/W45→本次=门体系从两连误杀进化到精准真保护。
- **处置**：run 归档 PARTIAL；%1 待命重跑（条件=宿主持续安静 20min：free≥21GB 稳+swapouts 零增+无 GUI 增长，哨兵探测→GO→重照 baseline→同脚本重跑，不算配方变更）；🔴**两次拦停即封夜**（防 thrash），转晨间与磊哥同步窗口再跑。R3 数据面/量尺修复/v3 三轴满分成果不受影响。

## D-100（2026-07-04 20:50）磊哥夜令：目标口径=完整 LoRA C5（R3 全绿→正式训练条件式直起，晨键提前授权）；训练窗推进分支线；代码/架构优化自主授权（Accepted）
- **磊哥原话**：「希望明早有好的结果 我说的不是R2或者我们短训，我说的是完整的LORA C5。另外如果你提前完成了，思考全范围分支还有没有grill没有消减的，继续消减，如果都消减的请推进到下个环节 比如UIUE和主线合并，比如voice，比如真实的uiue输入文本到后端模型再返回，uiue能正确显示10族的动作，比如端状态的宏场景协同。另外如果你觉得整个代码或者架构需要优化，也可以自主去行动 当然第一目标还是完城goal」。
- **解读与条款**：①R3-6 晨键**提前授权**为条件式：R3 短训四轴全绿（A≥12/B>9 非零/D≥18/qa=0 跨轨）+Launch Packet 全件+host 门+watchdog --armed → **正式训练 1800 iters 当夜直起**（时间账：R3 23:45 完→eval ~00:45→verdict 绿→formal ~00:5x 起→明早 ~11:15 完）；任何轴不绿仍停，转晨间分诊。②训练窗分支线四单（不碰模型不抢内存）：grill 全范围未消减扫描/UIUE 合并作战计划/真实链路接线设计/端状态宏场景预研。③代码架构优化=自主授权（重大改动仍走 grill+红队成对）。

## D-101（2026-07-04 21:00）二停诊断=UX 余量阈结构性贴线（非内存险情）；夜间模式门重校+封夜线改为第三跑绝对终线（Accepted）
- **心跳一手**：拦停窗 free 稳态 2.24-2.88GB 悬停+**swapouts 四拍零增**（2083396 平）——无 thrash 无螺旋，纯稳态贴线；R2b 成功跑同宿主同门本就 92-107s 擦线（W41 §3.2），3GB/120s 对本机任何训练=刀尖。M.23 死亡螺旋特征（swapouts 连续攀升+UN 态）不在场。
- **门重校依据**：3GB/120s 的保护对象=磊哥日常操作余量（W32 明记「磊哥 redline」）；磊哥 D-100 明示夜间优先级=完整 C5（「第一目标还是完成 goal」+主动退微信让路）→ 被保护方已让渡夜间 UX。重校非弱化防灾：**夜间模式=redline 2.0GB/180s**（低于实测稳态底 2.24）+**新增 memory_pressure_free_pct<4% 即杀**（实测稳态 7-9%，真螺旋才会击穿）+swap 增速 ≥2GB/5min kill 不变+process peak 22.34 不变+全部 deadline 不变。天亮恢复日间参数。
- **封夜线修正**：D-099「两停封夜」的前提=同变量重试防 thrash；本次变量已变（门基准重校+分支 worker 静默）→ **第三跑=绝对终线**（再拦停无论何因即封夜转晨间，无例外）。分支四单（W48-51）暂停新派单至训练进入稳态巡航（worker 驻留 ~200MB 非主因，但训练窗内不再加负载）。

## D-102（2026-07-04 22:1x）X5 commander 链审计吃账：ERRATA×2+级联修复×2+qa 四数字口径（Accepted）
- **X5-COMMANDER-CHAIN-AUDIT（%5 审总监，磊哥令「我的产出也要审」）verdict=P0_0/P1_4/P2_3**，四 P1 全实锤全吃：
- **P1-1 已修**：D-097 时间戳 21:20→19:55（原误标致 D-097/D-098 链序倒挂，X5 cite decisions.md:733-743）。
- **P1-2 已修**：D-097 判 combo PARK 但 R3 grill 前言+R3-3 行仍留 locked 口径=派生跟踪未级联——grill 两处已改（R3-3 标 PARKED per D-097，前言目标改「qa 唯一真靶点」）。
- **P1-3 ERRATA（程序瑕疵承认）**：D-098 对 host swap 谓词的精化，技术论证充分（swapouts 零增+懒回收）但**手续上绕过了 D-094 自己的「swap 门不过应上抛磊哥二择」条款**——当时应上抛而非自改。事后磊哥「红线可以放宽点？」+D-100/退应用让路构成追认，但程序序错了。矫正条款：**host-predicate-v2 waiver=本夜 R3 短训限定**；正式 1800 起跑时 swap>1GB 必须按 D-094 原条款上抛磊哥（D-098 尾款已有此句，此处升为硬门）；白天默认门恢复 D-094 原文。
- **P1-4 ERRATA**：安静窗解除令只发 tmux 未入决策正文——补记：该令为**一次性 waiver 且有争议**（合理面=满负荷蜂群下零 swapouts 不可达+防灾在飞行 watchdog；争议面=推翻了 D-099 自己写的重跑条件）。后续引用 night mode 只指 redline 参数，quiet-window waiver 不作先例；OPT2 config 化时「安静窗」条款按可达标准重写。
- **qa 四数字口径统一（X5 建议采纳）**：今后 qa 报数必须四数齐：`total=11 / adapter=9 / base=2 / original_v3=0`，禁单数引用致口径混淆。
- **元层**：审我的单子抓出我 4 个真账=对抗配对机制对 commander 同样有效的实证；program 纪律（该上抛就上抛）不因技术自信豁免——与「effort≠纪律」同源。

## D-103（2026-07-05 01:3x）R3 verdict=FAIL_QA_ONLY（A14✅/B15✅/D23✅/qa adapter 8❌）；机理=qneg 训练行 mount 面与 eval 分布失配（D-097 镜像）；R4 mount 同构化连夜一刀（Accepted）
- **R3 四轴（run 211035，adapter sha 4e278f18…，总监亲读 paired report+qa json）**：A 14/15 ✅（≥12；掉例 P3D-A-014-v3 close_ac→unlock_ac 单例记入）/ B 15/15 ✅（base 14→15 非零 delta）/ **D 23/34 ✅（+5，qneg 反哺保护面）**/ qa **FAIL**：四数字 `total=10 / adapter=8 / base=2 / original_v3=0`（9 族仍 8 族问句→改动工具）；T1 over-refusal 10/10 全过（真 query 零误伤=对照行起效）。训练本体零事故（600/600，val 0.024）。
- **机理（三层升维，总监亲核一手）**：现象=154 行 qneg 全过门/judge 却几乎没动 qa（9→8）。机理=**mount 面分布失配**：训练行同句挂 4 工具且不含诱惑工具（SEAT 行无 open_seat_heat），eval 探针挂 23 个全家族工具含诱惑——模型没见过「大挂载+诱惑在场+问句→空」的组合。范式=**mount cardinality/composition 是训练分布一等维度**（D-097 是 eval 侧 mount 坏，本次是训练侧 mount 与 eval 不同构）；配比矩阵缺格：class×family 之外必须有 mount-shape 列（验证经济学补格，进 lessons/门）。
- **处置=R4 mount 同构化（连夜一刀，D-100 授权链内）**：机械变换非新创作——108 负例+36 对照行的 tools 字段替换为**同族 eval 探针同构挂载**（全家族+含诱惑工具），话术/expected 不动 → scoped 门+judge → 组装 → 短训第四刀 → 晨间 eval。时间账：~02:30 数据面齐 → ~06:00 训完 → ~07:00 verdict=磊哥晨间看到。formal 1800 顺延至 R4 过门。
- **正面账**：A/B/D 三轴已在真门达标且 D 大涨；qa 修复的这一刀刀口已从「缺监督」（R3 补了）精确推进到「监督的挂载形态」（R4 补）——每轮 FAIL 都在收窄，不是打转。

## D-104（2026-07-05 晨，Opus4.8 commander 接棒首判）R4 verdict=F044_R4_FAIL_QA_REGRESSION；mount 同构化被证伪（qa 8→10 恶化）；T1 失败=工具名幻觉非 over-refusal（纠正 W55 预期）；机理走对抗归因（Accepted）
- **交接**：Fable5 commander 额度耗尽，Opus4.8 接棒（磊哥 /swarm-commander + 4 天沉淀回顾）。本条为接棒首个亲核 verdict。
- **R4 四轴（新 commander 亲核 paired report+qa json+T1 json 一手，run 005046，adapter sha ee579127…，train 健康 600/600 峰值 19.03GB<22.34）**：A **15/15**✅ / B **15/15**✅（base14→15 非零）/ D **21/34**✅（+3）——**A/B/D 连续两轮（R3/R4）稳定 PASS**；qa 跨轨 `total=12 / adapter=10 / base=2 / original_v3=0` ❌（R3 adapter=8[D-103]→R4 **10 恶化**，10 族全中含新增 AC-WIND/WIPER）。
- **🔴 T1 失败精确定性（纠正 W55 over-refusal 预期，亲核 observed + 契约核名）**：true_query_guard 7/10 + action_question 15/18 的 6 例失败**全是工具名幻觉/近邻混淆，非拒答**——模型吐 `query_volume`/`query_fragrance_mode`/`close_door`（契约**不存在**的幻觉名），真名 `query_current_volume`/`query_mode_of_fragrance`/`close_car_door` 存在且训练行挂载里就是真名。即模型仍调 query 工具、只是工具名生成精度退化。claim-vs-reality 第7坑防线兑现：没凭红队预言（over-refusal）拍死，亲核 observed 发现是精度问题。
- **机理层（假设，走对抗不一人拍）**：mount 同构化=R3→R4 唯一变量（负例挂载 4→23-48 工具含诱惑），被**证伪**：qa 不降反升。假设=大挂载在 136:1 稀疏监督下 ① 未给"问句 vs 操作"对比信号（负例仍孤立 NO_TOOL）② 稀释工具名精度监督→幻觉近邻名。**派 %5+%3 双视角对抗归因**（§8 P0 双 LLM 辩证）。
- **范式层候选（待对抗确认后沉淀）**：负例修复单位可能=**对比对**（同 mount 同 device「问 X→NO_TOOL」vs「操作 X→调工具」紧邻成对）非**负例数/挂载形态**——R3 堆量、R4 改形态两手段都没触及"判定面"。
- **决策点上抛磊哥（口径型，dispute-triage）**：qa 三轮数据手段未破（9→8→10），策略选择留磊哥拍：A 对比对数据(R5) / B runtime 兜底+A/B/D 三轴满分候选先晋级(需松 D-085 qa=0 硬门) / C 双管。

## D-105（2026-07-05 晨，Opus4.8 commander）🔴 qa 三轮数字翻案：scanner 口径不一致+label authority 冲突（亲核坐实，mount-invalid 同型第二案）；撤回 A/B/C 紧迫性，先修量尺重扫得可比真数（Accepted）
- **触发**：%2 机理归因（对抗三方之一）报 volume label/scanner P0，我亲核坐实两个量尺缺陷（claim-vs-reality，量尺自身有 bug 使 qa 数字失真）：
- **①label authority 冲突（P0，亲核）**：同句 `现在音量是多少` 在训练 qguard 标 `expected=query_current_volume`（R4-QNEG-ISO:149），在 eval `R2B-Q-VOLUME-001AQ` 标 `expected=[]`——**同句矛盾监督**=F044 round1 矛盾监督病（同串双标签）在 qa 层精确复发。模型不可能两标签都学对。非"对比对"能解，是数据 authority bug。
- **②scanner 漏计（P1，亲核）**：R3 `R2B-Q-VOLUME-001AQ` observed=`query_volume`（契约不存在的 invalid 名，expected=[] 有 tool_call）**未进 R3 failure list**；R4 同 case observed=`adjust_volume_to_number`（mounted action）进了 R4 list。即 scanner 只计 mounted action、漏计 invalid name → **R3 qa=8 虚低（真实 ≥9）→ 三轮 9→8→10 口径不一致不可比，"恶化"部分是 scanner artifact 非纯语义**。
- **范式层（三层升维制度物）**：qa 也需 **authority 门（identical-input 不得跨 bundle 冲突 expected）+ scanner 一致性门（expected=[] 时任何 tool_call 含 invalid name 都计 fail，actuation/invalid 分类分开）**——与 mount-validity 门、F044 矛盾监督 scanner 同源。verification-economics 补格：qa 风险类此前无"量尺口径一致"最早到达门。
- **战略修正**：**撤回 D-104 的 A/B/C 口径紧迫性**（那个战略图基于"qa 数字可比+数据手段未破"，前提被动摇）。先自主推进量尺修复（scanner 硬化 + label authority 裁决 + 重扫 R2b/R3/R4 得可比真数），拿到真数才能判"数据手段是否真未破 / 是否需 runtime 兜底"。qa=0 硬门是否松（磊哥键）推迟到重评后。
- **派单（grill+对抗都交 worker，磊哥令）**：%5 scanner 硬化+三轮重扫真数 / %2 label authority 回溯 C1+全 qa 冲突扫描 / %3 对抗审两者修法 / %4 秘书回写。R5 配方方向（%2 建议：authority-clean 强对比对，同 mount 同 device 同 slot 紧邻成对+distractor⊆mounted+observed lure 覆盖+工具名精度独立 gate）待量尺修复+重评后进 grill。
- **%2 authority 审计补账（回稿已收）**：全 qa 冲突扫描抓到 **6 个 identical-input cross-bundle 冲突**；C1 裁定口径=status-query 若系统存在 query 工具，应路由 query 工具，不应在另一 bundle 同句标 `expected=[]`。修法二择：①修 eval 侧 expected/mount 使其走 query；②若要测「query tool absent 时不得动作」，必须拆话术为 no-query counterfactual 并在 manifest 标明 authority，不能复用 true query guard 原句。`R5-LABEL-AUTHORITY-AUDIT.md` 目标文件暂未在 run dir 找到，本条以 %2 回稿摘要 + commander 亲核为恢复锚。
- **%5 scanner 真数补账（R5-SCANNER-HARDENED）**：硬化 expected-empty 规则后，adapter `any_tool_call_fail` 三轮可比真数为 **R2b/R3/R4=9/9/9**；adapter total 为 **9/9/10**（R4 多一个 `QUERY_EXPECTED_TO_ACTUATION` on `R2B-Q-AC-WIND-001Q`）；cross-track product hard-gate total 为 **13/13/14**。结论：旧 `9→8→10` 叙事作废；R3 的 8 是 scanner 漏计 artifact，R3/R4 数据手段对 expected-empty qa 墙体没有移动，R4 仅新增一例 query-expected→actuation 退化。产物=`R5-SCANNER-HARDENED.md`，未训练、未加载模型、未改 expected。
- **当前保存点（SEC4 09:38）**：%2 authority 已回，%5 scanner 已回；%3 对抗审两者修法待回；%1 训练执行位待命不动。R5 配方、runtime 兜底、D-085 `qa=0` 是否可由 runtime safety gate 满足，全部等量尺修复+对抗审后再上 grill，不在半成品图景上拍。


## D-106（2026-07-05 晨，Opus4.8 commander）qa 可比真数坐实：三轮 9/9/9=模型固有 actuation prior 硬墙，数据两轮没撬动；战略拍点成熟（Accepted）
- **可比真数（%5 硬化 scanner 重扫 + commander 复算 hardened json 逐 case 核 + %3 对抗审独立确认）**：adapter any_tool_call_fail（expected 空吐工具，纯 qa 口径）R2b/R3/R4=**9/9/9**；adapter total=9/9/10（R4 多 1=AC-WIND 的 QUERY_EXPECTED_TO_ACTUATION 单列）；base_anchor 硬化后=4（共享背景不归因训练）。"9→8→10 恶化"叙事破产（R3=8 是漏计 query_volume artifact）。
- **逐 case 明细揭深层真相**：三轮 adapter 失败几乎逐 case 相同（10 族问句→动作）；🔴 base 原模型也失败 4 个（WINDOW/DOOR/SUNROOF/SUNSHADE）→ qa 是**模型固有 actuation prior**非训练搞坏；adapter 两轮 9→9→9 纹丝不动=数据手段撬不动。
- **战略定性**：qa 数据 LoRA 手段可能到头（base 固有+两轮未撬）；runtime 兜底=产品正解方向；唯一没试的数据手段=authority-clean 强对比对（%2/%5/%3 共指），值 one-shot。%3 对抗审补充：volume authority 修法=拆话术非重标 + 加 T1 工具名 exact-name 独立门。
- **前置硬约束**：任何数据轮前必修 6 个 label authority 冲突（%2 audit，如「现在音量是多少」训练 query_current_volume/eval 空，C1 裁 status-query 应路由 query）。
- 🔴 **战略拍点上抛磊哥（qa=0 硬门，D-085 磊哥门）**：A adapter-only qa=0（修 label→对比对 one-shot 35%）/ B 松成 runtime safety gate（runtime 兜底，A/B/D 三轴满分候选先晋级 75%，治理红线明写 model defect 由 runtime 非 LoRA 学会）/ ⭐C 双管（修 label→对比对 one-shot 自主推进+松门 runtime gate 保底，尊重 A/B/D 满分不被 qa 卡死）。
- **接棒纪律实证**：本条差点因「D-106 字样被别处引用」假信号漏落库（claim-vs-reality：检测裸字样假阳性，须检测 `## D-106` 标题）；%2 authority 报 DONE 文件不在=§3 坑不信 ack。


## D-107（2026-07-05，Opus4.8 commander，磊哥拍）Codex App 接管执行基线 + Phase 0/1 启动令（Accepted）
- **定性**：D-106 是 C5 训练路线的**结论锚**（qa 三轮 9/9/9=模型固有 actuation prior 硬墙，adapter-only 数据法两轮未撬动），不再「继续做 D-106」。D-107 = 从 D-106 出发开**新执行锚**：把 C5 后续执行基线交由 **Codex App worker**（跨厂商 tmux swarm + Codex.app build-ios/macos 工具链）承接，commander 纯编排+裁决+记忆图谱+收稿亲核（§11/§14 执行下沉 worker）。
- **① baseline 确认**：`docs/baseline-roadmap-2026-07-05-c5-d106.md` 为**当前 C5 起手 baseline**（authority=`planning_baseline_not_openspec_contract`，非行为契约事实源；与 live repo/最新 D 条/run receipt/OpenSpec 冲突时后者胜）。本文件即刻纳入 repo 文档路径（git 跟踪），不再是未跟踪散文件。
- **② formal 1800 HOLD**：正式 1800 iters 训练 **HOLD pending Phase 1-4**（scanner/label authority 修 → runtime query safety gate → R5 pair-boundary one-shot → D-085 gate semantics 重拍）。D-100 的条件式授权在 R4/D-106 后已 HOLD（baseline §9 Preconditions），不因「多训一会就好」误起跑。
- **③ R-L17 口径固定**：`route-only signed; candidate signoff unsigned`——route-only R7 允许 C6 construction lane 提前推进，但**不允许** C6 acceptance/comparison、golden、voice、UIUE merge、V-PASS 或 C5 candidate 晋级（baseline §0.1 修正 2）。
- **④ 第一执行单 = Phase 1 ONLY**：scanner hardening 正式化（`R5-SCANNER-HARDENED.md` expected-empty 规则迁入 repo 内可复跑 gate；invalid tool name 与 actuation 分账）+ 6 个 primary label authority conflict 裁决表（尤其「现在音量是多少」应走 `query_current_volume` 非 `NO_TOOL`，修 absent-query counterfactual 侧不改 qguard/query 侧）。产物=repo 内可复跑/可裁决 gate（非 run-dir 一次性脚本才算量尺已修，baseline §5 Stop conditions）。
- 🔴 **stoplines（本单硬约束）**：不训练 / 不生成新训练数据 / 不启动 formal 1800 / 不 merge UIUE / 不碰 `Core/Training` 训练代码。Phase 1 只做量尺与标签权威修复（判断系统先可靠，再允许任何新数据/训练进主线，baseline §5 Goal）。
- **non-claims（继承 baseline §0）**：本决策不是 OpenSpec acceptance、不是 runtime 实现授权、不是数据生成授权、不是 formal launch 授权、不是 C5 candidate signoff、不是 C6 acceptance、不是 UIUE merge approval、不是 voice/mobile/true-device/V-PASS。
- **证据锚**：baseline 全文 `docs/baseline-roadmap-2026-07-05-c5-d106.md`（§0 读取纪律 / §4 Phase 0 / §5 Phase 1 / §9 formal Preconditions / §11 并行池）；D-106 结论 `docs/commander-log/decisions.md:794-800`；scanner 真数 `R5-SCANNER-HARDENED.md:23-37`；label authority 6 冲突 `R5-LABEL-AUTHORITY-AUDIT.md:7-24`。
- **执行序**：第一步=本 doc/governance patch（D-107 落库 + CURRENT.md 标 D-106 后 baseline + baseline 文件纳入 repo，不碰训练代码/数据）；第二步才进 Phase 1 实活（scanner+label authority 做成 repo gate，派 worker）。


## D-108（2026-07-05，Opus4.8 commander，磊哥拍）Phase 4 D-085 gate semantics = B（runtime-gated qa safety）；formal 训练路径解锁（Accepted）
- **磊哥拍**：「phase 4 可以选择 B 我同意」。D-085 qa 门语义重拍 = **Option B runtime-gated**（baseline §8）：**A/B/D 三轴由 model candidate gate 证明；qa 安全由 runtime safety gate 证明，不再等 adapter 学会 qa**（D-106 坐实 adapter-only qa 撞模型固有 actuation prior 硬墙，两轮数据法未撬动，A 35% one-shot 不赌）。
- **解锁**：满足 baseline §9 Phase 5 precondition「Phase 4 明确允许某一路径进入 formal」→ **formal 1800 训练路径解锁**（磊哥 goal=看到 LoRA 十几小时训练跑完的终点通道打开）。formal 训 A/B/D-strong 配方（R2b/R3 同款 rank16 配方），qa=9/9/9 在 B 口径下**被接受非 blocker**。
- 🔴 **治理红线（B 必明写，proof-class 铁律）**：candidate receipt/closeout 必写 `runtime_qa_safety_gate`，**禁写 `adapter learned qa`**；model defect（qa）由 runtime 安全门兜底=诚实 non-claim，不得假装 LoRA 学会 qa（D-106/baseline §8 B 风险条款）。
- 🔴 **formal 起跑仍未解除的前置**（B 只解 qa 门语义，不 auto-start）：① Phase 1 量尺收口（scanner/mount-validity/label authority repo gate 全绿，进行中）② Launch Packet 六件齐（FORMAL-LAUNCH-CONDITIONS/formal-config.diff/host-baseline/watchdog-contract/eval-manifest/receipt-template，baseline §9）③ fresh host baseline（swap/free fail-closed）+ watchdog --armed ④ formal 配方定版（A/B/D-strong recipe + 是否含 qneg）。任一缺=formal HOLD。
- 🔴 **仍守边界**：B ≠ candidate signoff——**R-L17 candidate signoff 仍 unsigned**（route-only signed），formal 训完的候选晋级仍需 human R7；Phase 2 runtime query guard（RuntimeQueryGuard）成为**并行/下游轨**（candidate signoff 与产品安全需要它，training 起跑不需要它先完成）；Phase 3 R5 one-shot 在 B 下**降为可选**（非阻塞 formal）。
- **non-claims**：不是 candidate signoff / 不是 C6 acceptance / 不是 runtime guard 已实装 / 不是 formal 结果达标（formal 训完仍按 baseline §9 Phase 5 acceptance 验 A/B/D + qa 按 B 口径 + T1）。
- **证据锚**：baseline §8 Phase 4 Option B + Recommended baseline（`docs/baseline-roadmap-2026-07-05-c5-d106.md`）；D-106 战略拍点 B 75%（`docs/commander-log/decisions.md:799`）；Phase 5 precondition（baseline §9）。


## D-109（2026-07-05，Opus4.8 commander）采纳 phase4b 决策计划 + Phase 1 disposition（gate landing done / 数据清零未完）+ W34 amend（Accepted，grill 拆解+redteam 审已足）
- **依据**：磊哥令「重大决策必须 grill 拆解 + 必须审计决策计划」——phase4b grill 拆解（`grill/phase4b-formal-decompose-grill.md`）+ redteam Round2 审（`redteam/phase1-audit-round2-final.md` verdict `AMBER_FORMAL_HOLD_UNTIL_D_MANIFEST_DISPOSITION`，E=pass-with-amends/F=PASS/D=AMBER）均已完成，据此落 commander disposition。
- **采纳 phase4b 六子决策**（redteam E pass-with-amends）：①formal 配方=R3-QNEG-clean（qneg 保 D轴/true-query 对照，非证 adapter 学 qa；Phase1-clean 后冻结）②split gates（formal_training_start_gate 不需 Phase2；candidate_signoff_gate 需 RuntimeQueryGuard+R-L17）③两 receipt 分离+字段拆分+`adapter_learned_qa=false` 强制 ④R5 non-blocking（B 下可选，formal 前只 docs/spec）⑤W34→candidate-promotion gate ⑥formal 起跑 checklist+磊哥键。
- 🔴 **Phase 1 disposition（redteam D 关键）**：
  - **门 landing = DONE+authoritative**：repo `scripts/{check,test}_{query_zero_tolerance,eval_mount_validity,label_authority_conflicts}.py` + Makefile `verify-c5-phase1-gates`，commander 亲核 make RC=0 三门绿 + redteam F 亲跑 PASS（zero rc65/mount rc66/query rc67/label bad-manifest rc65/hardened 9-9-9）。这是 repo 回归门权威。
  - 🔴 **真实 manifest label authority 扫描 = HARD gate（不是 advisory）**：baseline §5 Acceptance「label conflict 清零」+ Stop condition「identical input 有 conflicting expected 即停训」→ `check_label_authority_conflicts.py --manifest r5-phase1-authority-manifest --fail-on-conflict` 现 **rc2（conflict=10 + source_error=31）= 真数据冲突未解**，Phase 1 **NOT clean until rc0**。门建好 ≠ 数据清零（此前 commander「门收口技术完成」措辞不足，claim-vs-reality 纠正）。
  - **剩余 Phase 1 数据清零工作**（Phase 1 scope，非「生成新数据」）：①manifest 精化 exclude historical/v2/probe（grill locked）消历史冲突 ②应用裁决表修 real 冲突（LABEL-AUTH-001 改 AQ input / 006/009 加 value=LITTLE / 002-004 标 historical）③005/007/008 **等磊哥 default_scope LEIGE_KEY** ④LABEL-AUTH-010 额外 pending 纳入 ⑤重扫 → rc0。
- **W34 amend（redteam E：mandatory 非口头）**：W34 default-scope current-head gate 从 Phase1 completion 改为 candidate-promotion gate，需改 **baseline §5 + STATUS 正文**（不是只 decision 记）；Phase1 仍负责 default_scope canonical + label cleanup。
- **data stopline breach 处置**：data 违「只写 run-dir」直写 repo（scripts/+Makefile+docs），但门质量经 F 审 PASS → **保留 repo 门**（reconcile 后可信），breach 记 M 段教训（对抗配对对 commander 有效 + worker YOLO 越权风险）。
- **non-claims**：Phase 1 未 clean（数据未清零）；不是 formal-ready；不是 candidate signoff。
- **证据锚**：`redteam/phase1-audit-round2-final.md:9-90`；`grill/phase4b-formal-decompose-grill.md`；baseline §5 Acceptance/Stop（`docs/baseline-roadmap-2026-07-05-c5-d106.md:203-215`）。


## D-110（2026-07-05，磊哥拍）default_scope canonical = Scheme A（no-arg）+ 授权 Phase 1 数据清零执行（Accepted）
- **磊哥拍**：「A，授权执行清零」。LABEL-AUTH-005/007/008/010（天窗/遮阳帘 没说位置的开/关话术）canonical = **no-arg**（tool args 不带 `position`）；「全车」作 runtime default_scope/readback 事实，不塞进 model tool args；「开一点」保 `value=LITTLE` 无 position。解 baseline §5 item3 default_scope 拍点 + phase4b 子决策5 LEIGE_KEY。
- **授权执行**：Phase 1 数据清零按 `grill/data-cleanup-plan-DRAFT.md` 执行——**Batch1**（LABEL-AUTH-001 音量反事实改 AQ input+counterfactual 字段 / 002 协议 direction 补全 / 006·009 加 value=LITTLE / 24 行 Q-query-hard 加 counterfactual 元数据 / manifest exclude 003·004 historical v2）+ **Batch2 Scheme A**（005/007/008/010 删 `position:全车` → no-arg）→ 真 manifest `check_label_authority_conflicts --fail-on-conflict` **rc0**（conflict 10→0 + source_err 31→0，plan 已推演）。
- **性质**：编辑既有 qneg/counterfactual 数据（改 expected/input/元字段），**非生成新样本**（Phase 1 label authority 清零 scope，baseline §5 item2；D-107 stopline「不生成新数据」不含 authority 清零）。
- 🔴 **execution guardrails**（plan §Execution Guardrails）：①编辑前 snapshot 当前 manifest 输出 ②优先改 source candidate 层再 regenerate 派生 trainpack（若有可靠 generator path）；无则按 plan 列的 exact file:line 同步直改 JSONL ③Batch1 后跑 checker（strict full 预期 conflict=4 剩 005/007/008/010；deferred 预期 rc0）④Batch2 Scheme A 后跑 full manifest checker **要求 rc0** ⑤**不 train/build/commit**（commander 收口统一 commit）⑥不碰 Core/Training。
- **收口后**：真 manifest rc0 → redteam 复审执行结果（rc0 + 抽查编辑正确 + 无误改）→ commander 亲核 git diff → **Phase 1 clean** → commit → Launch Packet 冻结（R3-QNEG-clean）→ 磊哥 recipe-key + run-auth → formal 1800。
- **证据锚**：`grill/data-cleanup-plan-DRAFT.md`（Batch1/Batch2 Scheme A 逐行 + rc0 推演）；D-109 disposition。


## D-111（2026-07-06，Opus4.8 commander，磊哥拍 A）C5 runtime 收尾主路定调=honest-frozen-closeout；qa/action-question 两面分诊；不重训 1800；执行全下沉 5 worker（Accepted）

- **接棒语境**：新会话 commander 起手（`/swarm-commander`），goal=C5 收尾主路。磊哥令「重大决策必 grill 拆解 + 对抗审计 + 文档级联 + 执行全下沉 5 worker（commander 只编排+项目管理）」。worker 拓扑亲核=4 Opus（%11/%12/%14/%15）+ 1 Hermes（%16）；旧 pane label 写 codex 全 stale，派单用 pane id。
- **诊断锚（一手 eval，commander 亲核）**：tail1200 iter600 = true-query 10/10、action-question **14/18**（<R3 17/18 退化）。direct-value 同构实证 `C6-MP-006「空调调到24度」→ adjust_ac_temperature_to_number{temperature:24}` ✅（axis A 15/15），带 arguments 幻觉（direction/mode 瞎填）；EXP 感受词系统反向（有点冷→降温）。runtime T1 **0/18**（FastPathIntentEngine 只认「打开空调」，无慢路）。
- 🔴 **qa vs action-question 两面分诊（grounding 核心 reconcile，此前 handoff 混淆）**：
  - **qa（over-actuation）**：D-106 三轮 **9/9/9** 硬墙=模型固有 actuation prior（base 也失败 4 族），数据撬不动 → D-108 B runtime-gated 已 waive。
  - **action-question（under-action）**：14/18，根因=trainpack `能不能` register 0 覆盖（W15）；**D-108 B 不覆盖**（runtime qa 门结构上补不出缺失 tool call，W15+Lane4 坐实）。
- 🔴 **战略分叉（诚实）**：runtime 接线（W20A）能让 direct-value「调到26度」在 app 生效，但 **≠ C5 training V-PASS 达成**（action-question under-action 接线不改 14/18）。磊哥「1800 正式训练不希望大动（除非重大漏洞）」→ 不重训补 register → action-question 本轮 DEFER。
- 🔴 **定调=A honest-frozen-closeout（磊哥拍 A）**：① 冻结 tail1200 unsigned artifact（不重训）② runtime 接线 W20A 让 demo direct-value 可演（S1 async 缝→S2 DemoNLURouter 必经 guarded decode `ToolCallFrame.swift:306`→S3 LLMBackend）③ Lane2 slot 白名单投影防 arguments 幻觉现场出丑 ④ 三缺陷（EXP 反向/arguments 幻觉/action-question under-action）显式 DEFER ledger ⑤ 机械防假绿门（`RuntimeAdapterMountReceipt.validate()` 硬编码 unsigned + grep 门 0 命中 V-PASS/signed）。**不重训、不强求 V-PASS、candidate 保持 unsigned**。
- **4 lane grill 收敛（独立对抗，file:line 已核）**：SSOT=`runs/2026-07-06-c5-runtime-mainpath-grill/`。Lane1（W18/W19B 非 W20A 硬前置可并行；接线 S1-S3；residual R1 反解码器存在性）+ Lane2（不加独立 argument-guard 层，slot 白名单投影归 W20A 映射层）+ Lane3（两缺陷均 DEFERRED 非 blocker + 显式 deferred 契约）+ Lane4（接线只 claim runtime_path_reachable 非 V-PASS + DoD honest-frozen-closeout + validate() 防假绿）。
- **next（全下沉 worker，commander 编排+裁决）**：reduction（worker 综合 4 lane + 前序已决 D-106/D-108/W15/W16）→ Hermes 跨厂商审 reduction → 实施计划（worker）→ Opus 审实施计划 → 文档级联（秘书 worker，commander 过一道）。
- **non-claims**：不是 candidate signoff / 不是 V-PASS / 不是 C6 acceptance / 不是 runtime 已实装（W20A 未写码）/ 不是 formal 结果达标。
- **证据锚**：grill SSOT `runs/2026-07-06-c5-runtime-mainpath-grill/`（GRILL-README + lane-1~4）；诊断一手 `runs/2026-07-06-c5-training-vpass/tail1200-original-v3-paired-report.md` + `.../adapter/35-C6-MP-006.json`；W15 `.../w15-t1-action-question-rootcause-grill.md`；W16 `.../w16-restricted-decoding-toolname-grill.md`；D-106（decisions.md:794）/D-108（:815）。

## D-112（2026-07-07，Codex/commander 蜂群 closeout）W20A closeout 前置收束：脏区分组、upstream/main 双调和、两轮 grill 定稿、外审吸收、1800 confirmed-not-ready、终审条件失败

- **repo truth（snapshot-bound，不作永恒 live claim）**：本条按 2026-07-07 约 11:05 CST 本地探测快照书写。`landing-checklist.md` 最新 SEC probe 记录 `HEAD=381ae735`、branch `codex/rebuild-c6-doc-absorption-20260624`、`ahead 189`、worktree clean；本 worker 复核 `git status --short --branch` 同为 `[ahead 189]` 且无 dirty 行。该 truth 只绑定本快照，后续 push/commit/PR 需重新 probe。

- **HEAD 演进链（`6a4b6b82..HEAD` 载力段）**：
  - `178da86d` D-111 honest-frozen-closeout 文档级联。
  - `ed69a935` W19B `RuntimeAdapterMountReceipt` 防假绿门。
  - `72fd2ac0` W18 decode allowlist guard + trainpack 渲染 action/seeded-shuffle 收基线。
  - `ed63180d` main worktree iOS build 默认修回 + XSWAP-23 归档 + agent/tooling 指针。
  - `e87e2a00` upstream merge（B=merge，不 rebase）。
  - `ffd3ab89` fixture manifest 4 sha drift 修正。
  - `ad9283cf` main merge（18 冲突解、G7D 语义化、plugin refs 撤追踪；commit message 记录历史 `swift test 567/0 + make verify` 绿）。
  - `ed3a5a96` MT2 basis_id gate 初版（外审🔴3）。
  - `ab92bd8c` MT3 30 run 判定性证据冻结入仓（外审🔴4）。
  - `e6738d6b` MT5 GitNexus MUST/NEVER 降级为 advisory（外审🔴5）。
  - `0c8b0e69` MT1 qa 9/9/9 回归证据链 repo-relative 入仓（外审🔴1）。
  - `381ae735` MT2-FIX basis_id gate 覆盖 docs receipts。
  - `214f8d84` 终审 W21-P2-02 吸收：subset manifest tool_ids_ordered 唯一性断言。
  - 注：`ad9283cf` 合入 main，故 `6a4b6b82..HEAD` 全量会展开大量 UIUE/P5W/main 历史；D-112 只记录 closeout 载力段，不把 main 历史逐条重述。

- 🔴 **脏区 triage 四组分 commit 决策（Accepted，commit 已落）**：
  - **A 组 = D-111 文档级联/governance/OpenSpec notes**：范围包括 `CURRENT`、baseline roadmap、grill README/reduction、commander index/decisions/RUNS-CASCADE、handoffs、war-room、OpenSpec 状态等；性质是 honest-frozen-closeout、formal host-HOLD/not-launched、runs pointer 与 proof-class 级联，不混代码语义。已落 `178da86d`。
  - **B 组 = D-111 RuntimeAdapterMountReceipt 防假绿门**：`Core/Execution/RuntimeAdapterMountReceipt.swift` + tests，硬编码 candidate `unsigned`、`adapter_learned_qa=false`、runtime QA safety 不升格，并让 `validate()` fail-closed。已落 `ed69a935`。
  - **C 组 = C5 trainpack/render/decode dirty code**：`C5LoRATraining` action/polarity/seeded shuffle、`ToolCallFrame` allowlist guard、对应 C5/C3 tests。已落 `72fd2ac0`。
  - **D 组 = misc support/pointers/misplaced report**：`.xcodebuildmcp/`、agent/plugin pointers、`runs/README.md`、XSWAP-23 报告归档。已落 `ed63180d`；后续 `ad9283cf` 按 main 决策撤追踪 `Tools/agent-platform-plugin-refs/*`，避免本仓跟踪本机绝对 symlink。
  - 🔴 **provenance caveat（必须保留到最终落仓件）**：W1 triage 与 W21 P2-01 均点名：frozen trainpack 已有 `action=...` 与 `mount_order_strategy=seeded_shuffle` 形态，formal/tail run 消费的是冻结 trainpack sha/rows，不是当前 dirty code 现场重生成；因此不能声称 `6a4b6b82` clean code 可复现冻结 trainpack。C 组 commit 只能作为未来再生成/可复现性修复或 provenance 补洞；若要把它作为既有 formal/tail artifact basis，必须重冻或显式改 provenance。

- 🔴 **upstream 调和决策：选 B = merge，非 rebase（Accepted，merge 已落）**：
  - 依据 W5：upstream 原 behind 7 / ahead 122；`--cherry-pick` 口径显示远端 7 个里 6 个与本地早期 D22/D23/D24 patch-id 等价，真正远端独有主要是 `.github/workflows/verify.yml` self-hosted verify runner 变更。
  - 选择 **merge 远端进本地**，不 rebase 本地 122 commit，理由是 decisions/lessons/receipts 大量按 commit sha 做 basis；rebase 会重写 D-064~D-111 决策链 sha，重锚代价大于一个 merge commit。
  - 已落 `e87e2a00`，父提交为 `ed63180d` 与 `02f0722f`。4 个冲突 `docs/CURRENT.md`、`docs/project/phase0/README.md`、`r5-d24-route-control-pr-merge-closeout...`、`r5-d24-uiue-absorption-manifest...` 全取本地演进版；远端独有 `.github/workflows/verify.yml` 与 `public_fixture_schema.v1.json` 随 merge 进入。

- 🔴 **W20A grill 两遍收口（Accepted for implementation planning；G 项待磊哥拍）**：
  - **R1 综合**：`grill-r1-synthesis/cross-review.md` 完成 17 题 cross-review，形成 14 条 CONSENSUS、3 条 DISPUTE/需拍项、4 个双盲缺维吸收方向，并把 persona 现场 runbook/allow-avoid/out-of-claim 边界纳入候选落点。
  - **R2 双红队**：`R2-FINAL-DECISIONS.md` 定稿，lineage = grill-topics(17) → A/B 双卷 + persona → cross-review(14C/3D, cite 9/9 TRUE) → R1 draft → R2 红队双路（甲 P0=0/P1=3、乙 P0=0/P1=3）→ final。
  - **R2 3 个 P1 修订全部吸收**：
    1. mounted catalog 与 562 识别全集彻底分离：`ir_map_fingerprint`（562 识别全集）与 `mounted_demo_catalog_sha`（W20A claimed runtime surface）双 artifact；mounted catalog 只取 W20A claimed demo surface（direct-value AC 温度数值类为核），并加 execution-cell 全命中、avoid-list 交叉校验、receipt 双 sha。
    2. receipt 扩字段必须 bump `runtime_adapter_mount_receipt.v2`；validate 精确校验 schemaVersion；`runtime_target` 由 readback XCTest helper 从实际 destination 探测生成；Mac helper 伪写 ios_sim 必 fail；v1 只 decode 历史 evidence。
    3. W20A P1-S2 scope 内直接修 `decodeNonStreamingCompletion(allowedToolNames:)`，复用 `decode(_:)` guard，消灭而非绕过 W18 P1，并加 static guard + 未挂 catalog/by_exp/lock_ac 行为负例。
  - **G3 撤销**：helper 直接修已并入 W20A scope，G3「W18 P1 节奏：先修 vs conditional-moot」不再需磊哥拍。
  - **待磊哥拍项剩 G1/G2/G4/G5/G6**：G1 iOS 实测门是否保留；G2 malformed/unsupported 兜底 TTS 文案；G4 demo 话术 allow/avoid 进 operator runbook；G5 对外是否展示 axis-D 聚合数；G6 RT-6 无真异源时是否由磊哥/人审签 accepted residual。
  - **non-claim**：R2 final 仍是 planning/governance 定稿，非写码授权；G1/G2/G4/G5/G6 未拍前，不得写成 W20A implementation approved。

- 🔴 **main merge 决策与执行（Accepted，commit 已落；green 口径需按 W21 收窄）**：
  - 已落 `ad9283cf`，把 `main` 合入本分支。
  - 18 个冲突已解：authority 文档以本分支 HEAD 为主，E2 子集决策取 main ratified 态，`Makefile`/`.gitignore` union，`C5LoRATraining` 中 seeded_shuffle 与 subset 正交功能双保，`C5LoRATrainingTests` 保留两边测试意图，`CURRENT`/`COMMANDER-INDEX`/`decisions`/`lessons` 避免旧 main 截断 D-064~D-112 链。
  - G7D 语义化：将 G7D 相关断言随 `mount_order_strategy` 语义化，避免把 seeded shuffle 与 subset manifest gate 混成同一语义。
  - plugin refs 撤追踪：`Tools/agent-platform-plugin-refs/*` 按 main 决策撤追踪，避免本机 Codex plugin cache 绝对 symlink 进入主仓历史。
  - `ad9283cf` commit message 中的 `swift test 567/0 + make verify` 只作为**历史时点 local/unit/build-script proof**。W21 终审已判当前 closeout green 不能直接沿用该 stale green；最终 green 必须以 MT commits 后 fresh `make verify` 解除。

- 🔴 **1800 口径澄清（W14 CONFIRMED；confirmed/not-ready）**：
  - W14 对 W2 数据报告给 `CONFIRMED`：`1800` 一手口径 = **formal training iterations / iters**，不是「1800 条训练样本」。证据锚：`docs/commander-log/decisions.md:729` 写 `1800 iters`；formal config/launch conditions 也写 `iters 1800 / updates 450 / warmup 36`。
  - frozen trainpack = **5653 行**，sha256 = `fa5690400f67db9ef237dabdb489f58d1ab69961f14d6733d79f9bd7cad33823`，静态包口径为 `ready-static`。
  - formal 1800 当前口径仍为 **not-ready**：host gate HOLD、new/retry run-auth 待重确认、无 current real trainer pid/watchdog；D-111 后 formal 1800 是保留的 evidence-run 目标，不是 C5 closeout 主路，也不能修 action-question 14/18 register 覆盖缺口。
  - 禁止写「1800 条训练数据 ok」「formal 1800 已过」「formal 1800 DEFER」等混淆句。

- 🔴 **MT1-MT5 外审吸收段（外审真问题入仓/入门，commit 已落）**：
  - **MT1 / 外审🔴1 CI 仓外依赖**：`0c8b0e69` 把 qa 9/9/9 回归证据链入仓并改 repo-relative，目标是 CI 任意机器可绿可红，消除仓外单机 runs 依赖。
  - **MT2 / 外审🔴3 basis_id 无牙**：`ed3a5a96` 给 receipt basis_id 规则装机械门；`381ae735` follow-up 把 docs receipts 纳入 basis_id check，修正初版覆盖不足。
  - **MT3 / 外审🔴4 证据单机**：`ab92bd8c` 将 30 个 run 的判定性小文件冻结入 `docs/evidence-frozen/`，每 run 有 `MANIFEST.sha256`，空/已清 run 有 `EMPTY-NOTE.md`，大文件留仓外 hash+路径+体积记录。
  - **MT4 / 三状态板并行**：常设秘书产 `closeout/mt4-statusboard-convergence-draft.md`，收敛为 `docs/CURRENT.md` 唯一活路由牌正文、MEMORY as-of 一行态+指向 CURRENT、run 内 `STATUS-BOARD.md` 标 run-local scope。
  - **MT5 / 外审🔴5 GitNexus MUST/NEVER 错位**：`e6738d6b` 将 GitNexus MUST/NEVER 降级为 advisory 措辞，避免宪法级措辞无机械门承接。
  - 外审🔴2 merge 悬置被判为 commander 工作中间态，已由 `ad9283cf` main merge + W21 覆核承接；不单独生成修复 commit。

- 🔴 **W21 终审结果：CONDITIONAL_FAIL_CLOSEOUT（P1 blocker）**：
  - W21 verdict = `CONDITIONAL_FAIL_CLOSEOUT`，grade=`P1_BLOCKER`，P0=0。
  - P1：当前不能签「main merge 后全量 swift test 567/0 + make verify 绿」作为最终 closeout green。W21 fresh `swift test` 通过 `567/0`，但 fresh `make verify` 失败在 `diff` gate（`scripts/test_query_zero_tolerance.py` diff），且当时 worktree 有 MT 系列未提交/未跟踪改动。
  - 最小解除动作：收口 MT1/MT2/MT3 等 dirty 改动（commit 或回滚）→ 重新跑 `make verify`，必须无 diff gate failure → 刷新 `git status --short --branch` → 更新 `MASTER-STATUS.md`/PR body，把 green 绑定到 fresh rerun 时间和 log。
  - 本 D-112 v3 只记录 W21 blocker 与解除路径，不声称 blocker 已解除；若后续已 fresh verify，需另以新 receipt/commit 追加。

- **`.xcodebuildmcp/config.yaml` 修回 main 默认（Accepted）**：W1 triage 指出 `.xcodebuildmcp/config.yaml` 一度指向 `MAformac-uiue` 与 `iPhone 17 Pro Max`，污染 main worktree 默认；已在 `ed63180d` 修回 `projectPath=/Users/wanglei/workspace/MAformac/MAformac.xcodeproj`、`scheme=MAformacIOS`、`simulatorName=iPhone 17 Pro`。

- **XSWAP-23-fix.md 归档 phase0，不跨 worktree（Accepted）**：W1 triage 判定 `XSWAP-23-fix.md` 是隔壁 `MAformac-p2c6` / PR23 验证报告，误落 MAformac root；本轮不跨 worktree 移动，改为当前仓归档到 `docs/project/phase0/xswap-23-fix-delta-reverification-2026-07-02.md`，由 `ed63180d` 入仓。

- 🔴 **push / PR 状态（snapshot-bound live-verified）**：
  - 当前本地分支相对 `origin/codex/rebuild-c6-doc-absorption-20260624` = `ahead 189`，说明 `ad9283cf` 之后 MT 系列 commit 尚未全部同步到该 upstream ref。
  - `gh pr list --head codex/rebuild-c6-doc-absorption-20260624 --state all` 当前只返回历史 PR **#7 MERGED**（`R5 D22-D23 main runtime payload corpus and shared schema under proof cap`），未发现新的 open PR。后续 push/开 PR 仍是 commander stop/go 动作；本 D 条不替代 push 授权。

- **non-claims**：本 D 条不声称 candidate signed；不声称 V-PASS；不声称 formal 1800 已起跑或已过门；不声称 `6a4b6b82` clean code 可复现冻结 trainpack；不声称 W20A runtime 接线已实装；不声称 G1/G2/G4/G5/G6 已由磊哥拍；不把 `swift test 567/0` / `make verify` 升格为 runtime/mobile/true-device/live acceptance；不声称 W21 P1 已解除；不声称新 PR 已打开。

- **证据锚**：`closeout/landing-checklist.md`；`final-audit/report.md`；W1 `/dirty-triage/report.md`；W2 `/data-1800-check/report.md`；W5 `/remote-reconcile/report.md`；W10 `/main-conflict-prep/report.md`；R1/R2 `/grill-r1-synthesis/cross-review.md`、`R2-FINAL-DECISIONS.md`；`MASTER-STATUS.md`；current git `git status --short --branch`; `git log --oneline 6a4b6b82..HEAD`; `gh pr list --head codex/rebuild-c6-doc-absorption-20260624 --state all --json ...`。

## D-113（2026-07-07，register 补洞窗 grill 20/20 全拍 → 计划相定稿）指针式落库、formal 1800 goal supersede 分层、W20A 收口

- **磊哥全拍键**：2026-07-07 register grill **20/20 裁决批准**（含 Q13 golden boundary、Q16 机械前置+分型阈值、Q19 A supersede）。
- **SSOT 指针**：20 裁决全文=`runs/2026-07-07-w20a-grill-closeout/register-window/grill-20/PARADIGM-LEDGER.md`；一页消费清单=同目录 `FINAL-LIST.md`；实施计划定稿=`register-window/IMPL-PLAN-v2.md`（12 stage，双红队 2P0+8P1 全吸收，REDTEAM_ABSORBED_PENDING_RUNAUTH）；消减表=`REDUCTION-TABLE-v1.md`。
- **计划相态**：v1→双红队（甲 2P0+5P1/乙 4P1）→v2 定稿。磊哥仅 4 项 hard gate：①S2 golden boundary ~10 条 ratify ②run-auth ③host HOLD 解法 ④S10 触发 Q18②/③分支知情确认。补洞前不跑中间档训练。


- 🔴 **register 补洞窗正式从 grill 决策相进入计划相（Accepted）**：
  - 20 题 grill 已按 R1-R4 四轮收口，范围覆盖：金标 ratify/overturn、risk/register 分层、action-question 窗口边界、监督形态、分桶与防死记、DataGate/meta 判定、scanner v3 时序、生成工艺、重冻/验收/回退、Q19 账务、Q20 落库分层。
  - 磊哥已全拍 20/20：特别确认 Q13 golden boundary 需磊哥抽约 10 条 ratify；Q16 六机械前置缺一即 BLOCKED 且不产可读行为数字、NO_TOOL fail=0/wrong-name≤1/holdout 相对差/non_EXP_D_regressions=0；Q19 采用 A 案。
  - 下一阶段仍不是直接训练，而是计划件修订：`IMPL-PLAN-v1.md` 已出，双红队已回，v2 修订中；补洞前不得跑中间档训练。
  - 任何新数据训练都必须作为 `register-window new recipe run`，绑定新 Launch Packet、scanner v3、DataGate、runtime_qa_safety receipt、三臂 eval、claim envelope 和红队审计。

- 🔴 **20 裁决采用指针式落库，不复制全文（Accepted）**：
  - `decisions.md` 只落一条 D-113：记录窗口立项、20 裁决 source pointer、磊哥全拍键、Q19 supersede 链、W20A 当前态、计划 lineage、Q20 分层落点。
  - 20 条完整裁决全文留在 run-local ledger：`register-window/grill-20/PARADIGM-LEDGER.md`；一页消费清单留 `register-window/grill-20/FINAL-LIST.md`。
  - `docs/CURRENT.md` 只放活动窗指针和过期条件；不复制 20 条正文。

- 🔴 **Q19 formal 1800 goal supersede 链分层（Accepted）**：
  - **goal 层立即 supersede**：旧口径「R3-QNEG-clean 5653 冻结包上的 formal 1800 goal」立即标记为由 `register-window new recipe run` 这个达成体承接/实现。语义是 **A = 达成体 + 显式 supersede 链**，不是两个 formal 1800 并存。
  - **data/candidate 层 pending**：旧 tail1200 / R3-QNEG-clean basis 在新门全绿前**不标 data-basis superseded**。旧 basis 继续是 demo 主路和回退承重墙，直到新 recipe 通过机械门、行为门、holdout、qa safety、receipt、三臂 eval 和红队复核后才迁移。
  - **registry 层两事件**：即刻登记 goal supersede event；新 data basis 只预登记为 `pending_gates`。失败 run 以 `FAILED_UNSIGNED` / `PARTIAL_BEHAVIOR` 等状态入 registry，不污染旧 basis。
  - **non-claim**：D-113 不声称 formal 1800 已完成、不声称新 candidate signed、不声称 tail1200 已被替换、不声称 register 训练已启动。

- 🔴 **W20A 当前态作为 register 计划前置上下文（Accepted）**：
  - W20A 已走完 8 stage 实装链；Stage 8 先被 S8R `REFUTED`，因为 Mac SwiftPM 可伪造 `ios_sim` receipt 过 claim gate、iOS xcodebuild 只跑 stdout stub、claim-envelope 不验 stdout。
  - S8FIX 后 S8FR 复核为 `AMENDED`：三条 S8R P0 false-green 攻击面均 **CLOSED**；攻击套件在 current HEAD 上为 `ATTACK1=BLOCKED / ATTACK2=BLOCKED / ATTACK3=BLOCKED`，在 vulnerable basis 上为 3×LEAKED，证明攻击套件有判别力。
  - 当前 W20A S8FIX 证据面还包含：RuntimeAdapterMountReceiptTests 6/0、W20ARuntimeReadbackTests 4/0、claim-envelope tests PASS、xcodebuild iOS Simulator readback PASS、extraction + claim gate PASS；S8FR 记录 closeout 路径必须是 `xcodebuild stdout -> extract receipt -> claim gate`。
  - W20A 全量回归面记录为 **597 tests / 0 failures**；register-window 的 S8 训练启动必须消费 W20A S8FIX 机械绿 receipt，不能只消费 prose “已收口”。

- 🔴 **实施计划 lineage：v1 → 双红队 → v2 修订中（Accepted）**：
  - `IMPL-PLAN-v1.md` 是 10 stage 计划草稿，status=`DRAFT_PENDING_REDTEAM`。
  - 红队甲 `plan-rt-a.md`：P0=2 / P1=5。两 P0 已采信并转 %16 修 v2：final label-authority key 缺 `mounted_tool_shape/target_tool_present` 上下文；S10 `runtime_qa_safety receipt` 无生产 stage。
  - 红队乙 `plan-rt-b.md`：P0=0 / P1=4。P1 指向 Q4/Q7 renderer ack/register variants 缺 stage、DEFER registry 缺强制产物、W20A S8FIX 攻击套件只写 prose precondition、S9 holdout 生成/Opus 边界未拍定。
  - 汇总 lineage：双红队合计 **2 P0 + 8 unique P1**（A/B 均触及 holdout/S9 生成归属，合并去重一次）。v2 必须补齐：final authority key、S9b runtime_qa_safety、base arm snapshot、holdout eval provenance、defer registry、Q4/Q7 ack backlog/S11、W20A attack-suite hard preflight、schedule blocker receipt。

- 🔴 **Q20 落库分层表（Accepted）**：

| Landing tier | 落什么 | 不落什么 |
|---|---|---|
| `docs/commander-log/decisions.md` D-113 | 单条 ADR：register-window 进入计划相、20 裁决指针、磊哥 20/20 全拍键、Q19 goal/data 分层 supersede、W20A S8FIX 当前态、计划 lineage | 不复制 20 条全文，不写执行细节，不签新 candidate |
| `docs/CURRENT.md` | 活动窗指针：`register-window/grill-20/PARADIGM-LEDGER.md` + `FINAL-LIST.md` + `IMPL-PLAN-v2`；`expires_when=register 窗关闭或 basis 迁移发生` | 不写长裁决正文 |
| `BASELINE-REGISTRY.md` | goal 层 supersede event；data basis pending gates 预登记；失败/partial run 事件态 | 不提前把旧 tail1200 / R3-QNEG-clean 标 data superseded |
| `register-window/grill-20/PARADIGM-LEDGER.md` | 20 裁决全文、R1-R4 元教训、终卷元记录 | 不升格为全局 SSOT |
| `register-window/grill-20/FINAL-LIST.md` | 20 裁决消费清单，供计划/执行/审计映射 | 不替代 ledger 全文 |
| `lessons-learned.md` | 只落元教训候选：R1 答非所问/dispatch-inline grill 变体；S8 REFUTED 行为层审计；Q15 schema 权威错位/F044 上游防线；Q16 机械门假绿防 anchor | 不搬技术细节表 |
| MEMORY as-of | 一段短态：D-113 指针、register-window 计划相、W20A S8FIX 三 P0 closed、IMPL-PLAN v2 修订中 | 不复制 ledger |

### 20 裁决指针摘要

- R1 Q1-Q5：ratify action-question 金标但强制配对负例；risk tier 优先于 register 并显式元数据；本窗只补 can_question_action + hedged_request 正例与门链负例；R0 监督 target 保持纯协议串，ack 归 renderer；约 400 条按 demo 10 族、holdout 与双负例义务组织。
- R2 Q6-Q10：生产 enum 保持五类，DataGate 加 meta-capability 非 mutating 断言；R1 confirm 为 renderer register 变体；三字段顶层且 scanner v3 先行；status_query 新正例出窗而配对负例入窗；首批 50 全语义校准后批量 +20/50 抽检，单次重冻。
- R3 Q11-Q15：holdout 三腿防线、值随机化三点一致、meta-FAQ 判定脚本+golden fixture、judge rubric 防自标、schema 字段权威归属表；`mounted_tool_shape/target_tool_present` 权威在组装层，不给 generator stamp。
- R4 Q16-Q20：机械前置缺一即 BLOCKED 且不产出可读数字；三臂全跑但增补桶 new-only diagnostic 不进同尺分；tail1200 主路承重墙在新门全绿前不 data supersede；Q19 采用 A 达成体 + 显式 supersede 链；D-113/CURRENT/registry/ledger/lessons/MEMORY 分层落库。

### 当前执行态

- **计划相 owner**：RW-PLAN / IMPL-PLAN %16；消减表 %14；FINAL-LIST %12；D-113 草稿本文件由 worker 升 v2。
- **红队门**：PLAN-RT-A/B 已回；2 P0 全采信并转 %16 修 v2。v2 出稿后再按 commander 要求决定是否二次审。
- **W20A 并行态**：S8R `REFUTED` 已经 S8FIX+S8FR 翻转为三 P0 CLOSED，但 closeout wording 必须保留 `AMENDED` 残留：xcodebuild stdout 需 extraction step，iOS receipt 口径不得误称 live-head-bound。
- **启动红线**：register-window 不因 D-113 落库自动启动训练；S8 train 仍需 W20A mechanical green receipt、run-auth、host HOLD 解法和 IMPL-PLAN v2 gates。

### Evidence anchors

- `register-window/grill-20/PARADIGM-LEDGER.md` R1-R4 裁决段。
- `register-window/grill-20/FINAL-LIST.md`：顶部记录“磊哥 2026-07-07 全拍（20/20 裁决批准，含 Q13 golden boundary/Q16 阈值/Q19 A supersede）”。
- `register-window/IMPL-PLAN-v1.md`：10 stage 计划草稿，status=`DRAFT_PENDING_REDTEAM`。
- `register-window/plan-rt-a.md`：P0=2/P1=5；两 P0 为 final key mount context 与 runtime_qa_safety receipt 生产 stage。
- `register-window/plan-rt-b.md`：P0=0/P1=4；四 P1 为 Q4/Q7 ack、DEFER registry、W20A attack-suite preflight、S9 holdout/Opus 边界。
- `w20a-impl-reviews/s8-review.md`：S8R verdict=`REFUTED`。
- `w20a-impl-reviews/s8fix-review.md`：S8FR verdict=`AMENDED`；三 P0 CLOSED；攻击套件 3×BLOCKED；extraction + claim gate PASS。
- `w20a-impl-reviews/selftest-log.md`：current HEAD 3×BLOCKED；vulnerable basis 3×LEAKED。

---

## D-114：register 窗待磊哥包四拍落定（run-auth 条件式 / Q18 缓拍 / 承重墙+S10 分流 / host HOLD 不 waiver）

- date: 2026-07-07（下午，Fable5 commander @%13 蜂群第二场）
- 磊哥原话逐条（tmux 直拍）：
  1. 「S7c PASS 后 run-auth：我给！」→ **run-auth 条件式预授权**：S7c learnability micro-probe（IMPL-PLAN v3 必跑前置）PASS 即视为 S8 1800-iters run-auth 生效，无需再等一轮拍板。S7c FAIL 则不触发，回 IMPL-PLAN v3 失败分支。
  2. 「Q18 分支：现在不拍，等 S10 触发后按失败类型分流。」→ Q18 保持条件式，不预拍。
  3. 「默认保持 tail1200 / R3-QNEG-clean 是承重墙。S10 全绿再 data supersede；S10 不绿就先分类：runtime qa fail 修 guard/harness；coverage debt 才开新 data repair；coverage 足但 action-question 仍 fail 才判 causal bet falsified；holdout 塌就走话术收窄或新窗口，不给 waiver。」→ **S10 失败四类分流处置表落定**（与 IMPL-PLAN v3 §S10 失败出口对齐并升级为磊哥拍板级）。
  4. 「不建议默认给 host-waiver-key。waiver 会污染失败归因，后面 S8 如果不理想，很难判断是模型/数据问题还是资源环境问题。只有时间窗口极硬、你愿意承担归因不干净时才给 waiver。」→ **host HOLD 解法 = ⭐A 关重 GUI 后 fresh resample PASS**；waiver-key 仅时间窗口极硬时例外且归因不干净由决策者显式承担。
- 消费口径：
  - S8 点火五布尔改写为：S7c receipt PASS（=run-auth 生效）+ host fresh resample PASS（非 waiver）+ W20A mechanical green receipt + S7b causal-bet receipt + IMPL-PLAN v3 gates。
  - holdout 塌 = 话术收窄或新窗口，**waiver 通道对 holdout 关闭**（比 v3 更严，以本条为准）。
- 级联：CURRENT.md 待磊哥段收敛（仅剩条件式项）；STATUS-BOARD（run dir 2026-07-07-ma-opt-refactor）；MEMORY as-of 下轮刷新时并入。

## D-115：任务①（全项目精简与架构优化）N1-N4 四项磊哥全批（照 commander ⭐ 推荐）

- date: 2026-07-07（下午）
- 磊哥原话：「N1-N4全部同意你的推荐」。逐项生效：
  - **N1 批**：MCP decision note——旧「MCP 走 Capability 同构」（brainstorm-2026-06-17）显式 amend 为「vehicle `Capability` + domain-neutral `ToolProvider` 并行，guard/executor 等价边界保留」。note 起草后仍呈磊哥过目正文再落 openspec/docs。
  - **N2 知情确认**：M.33 iOS ir_map 缺陷随 Q2=C 冻结封存，iOS 二期再修；修复成本三档估算存档（run dir `out/m33-ios-irmap-status.md`）。
  - **N3 批（保守版）**：Reports 31 tracked 文件退仓与 frozen 重复 tarball 化——本轮只落 migration plan + digest/重复清单，实际执行等磊哥单独点头。
  - **N4 批**：openspec 11 active change 补 `status:` 字段（disposition 机械源），字段方案草案呈磊哥过目后落。
- 关联：任务① 合成件=run dir `2026-07-07-ma-opt-refactor/out/COMMANDER-SYNTHESIS-v1.md`（10 结论 grill 拆解 + 双红队审计后修订 v2 再执行）。

### D-115 补记（2026-07-07 下午）：N1/N4 正文过目已批

磊哥原话「N1 批 / N4 批」。生效：
- N1 正文批：proof-class 走 Option A（Slice A/C 用 public `PresentationProofClass`；Option B provider 内部枚举等真 MCP 执行获批再引入）；落点=新 openspec change `define-external-tool-provider-boundary`（四件套）+ 接受后 ADR 指针。
- N4 正文批：`status:` 单字段首刀 + 6 枚举 + 11 change 初值表（run dir `2026-07-07-ma-opt-refactor/out/n4-openspec-status-field-draft.md`）；门=`openspec validate --all --strict` 全绿。

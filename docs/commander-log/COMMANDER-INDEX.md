# COMMANDER-INDEX — MAformac 指挥官记忆图谱（单一入口 / 冷启动锚点）

> 🔴 **起手必读 + 每次自动压缩后必读**。我（Claude）是 MAformac 这条线的【指挥官】（claude-commander，pane `%42` @ ma-status-swarm），指挥 3 个 codex worker（自动压缩不丢工作）。本图谱补 MAformac 缺失的【**指挥官决策层**】，**指向（不复制）**现有 grill SSOT / CURRENT / handoff / MEMORY。
> **抗失忆机制**（2026 best practice，github-first 搜证）：① 每重大决策**立即写** `decisions.md`（definition of done，不等压缩抢救）② 本 INDEX = bootstrap manifest（事实层「做过啥/在哪」）+ `SOUL.md` = 心法层（「我是谁/怎么做事」）③ markdown + git（grep 可达，无锁定）。压缩后：读 INDEX 恢复事实，读 SOUL 恢复心智。

## 我是谁（身份 scope）
- **角色**：MAformac 线指挥官（commander），**非 worker**。只协调 / 综合 / 裁决 / 终审，不写 worker 内容。
- **协作**：磊哥拍板；我指挥 3 codex worker（tmux-bridge swarm）；worker 自动压缩不丢工作（不关注 worker context 高低）。
- **协议**：`/swarm-commander` 宪法 + 本图谱 + `SOUL.md`。🔴 **复杂步骤先纯文本讲计划 → 磊哥说"继续" → 纯工具执行**（防我自己 malformed：工具调用前不堆长文本）。

## 当前阶段（as-of 2026-07-02，🎉 3 训练前置门已 merge 落 main + verified（main=ab355f6c CI SUCCESS）D-011）

> 🔴 **grill 已收口**（332 决策，两轮 audit 0 P0，SYNTHESIS `grill_complete_pending_human_signoff`）→ 磊哥批准「5 ❌ gate → 3 worker 编排」（**D-006**）：①建 3 worktree（`MAformac-g6/g5/g7`）②写 3 份 D22 派单（inline grill 决策 + **gitnexus 要求** + **grill 消减** + **teardown 扩散**纪律）③subagent CC 双审（派单 + 回稿）。**5 gate**：W1(`%44`/g6)=gate6 四层阈值化 E-002~006 + 裁决-B F-043 ／ W2(`%45`/g5)=gate5 六轴 held-out D-016 + 裁决-A F-044（%45 codex@MAformac，grill 后空闲；%43 留 UIUE 不动） ／ W3(**hermes**/g7)=gate7 云 generator D-031~037。**守 R7**：全 construction（build code/spec/harness + fixture 单测），retrain-c5 真训练/真数据生成/candidate eval 仍 BLOCKED。SSOT `docs/c5-training-readiness-grill/`，详 `decisions.md` D-006/D-007。
> 🔴 **最新（2026-07-01 收口）**：**5 gate construction → PR #9(gate5 六轴+裁决A)/#10(gate6 四层+裁决B)/#11(gate7 云generator design) 待磊哥 merge**（D-007 lock；codex 交叉审抓 gate6 P0 假绿分母 runs.count→修 case 覆盖 CLEAR 75 绿；gate7 Opus subagent 反思前数据集挖【假异源 judge 前一次 gen+judge 都 hermes 100% same-vendor】+ 修【0/34 口径:生成产了 4306 中文, 根因训练侧】= **D-008**）。**grounded grill round**（**D-009/D-010**）：本 session 经验发现驱动 110 新决策（W1 配比 D-096~125/W2 质量 A-096~133/W3 语料 E-096~130/commander F-048~054）magnet 全 lock，回写 gate7 §10。**数据 scoping 齐**（WS1 562 生成 scope 5994 / WS2 bug 语料 1730/4053）。🔴 **retrain-c5 真训练/真生成仍 R7 BLOCKED**（candidate signoff 才 lift；gate7 别背 0/34 锅）。🔴 **API 故障应对**：subagent CC/hermes proxy 层 socket 挂 → codex tmux 活 pane 交叉审/顶替（**F-052**，磊哥「三者等效」）。详 `decisions.md` D-006~010 + `swarm-runs`。
> 🔴 **最新（2026-07-02，D-011）**：磊哥 `/gptpro audit 范围大` → GPT Pro（第3家跨厂商）审 3 云端 PR（connector 挂 → commander pivot **上传 diff 直读审**）verdict REQUEST_CHANGES **P0=0 无 R7 越界** + 独立印证 gate6 分母修复。🔴 **最关键 = CI 红是 repo bug 非代码**（verify.yml 浅 clone 没 fetch head SHA → `git diff --check base..head` exit128）。3 worker 修 findings（#9 device axis/vendor/R7 guard/tests · #10 legacy Codable/orphan fail-closed/`construction_*` status · #11 design redact 8 话术→shape）+ 各补 verify.yml fetch base+head → **全部 3 PR CI 绿 + commander gh/grep 一手亲核 genuine + worker 回执三方一致**。磊哥拍 **A（3 都 merge）** 交 %45 rebase-merge → **gh 一手核销 3 门全 MERGED（main=ab355f6c + CI Verify SUCCESS run 28532906744 + make verify-all 472 tests/0 fail）**，commander 沉淀六部曲。🔴 **R7 全程守住**（construction/doc only，`construction_*` 显式标非真验收；gate 落地=R7 解锁后训练的验收脚手架就位，**非解锁训练**；retrain/真生成/candidate signoff 仍 BLOCKED）。详 `decisions.md` D-011 + handoff `2026-07-02-gptpro-audit-3pr-fix-merge.md`。
> 🔴 **双仓惨败回忆纪律**：每决策必防 0/34（C5 PR5 `8d-rootcause` 9 失守）+ θ-α（generated-positive 全 checkpoint 塌）重演，cite P1-P9 PCA。
> 🔴 **R-L17 现状**（`R7-final-route-deframing-signoff` 2026-06-25 磊哥签）：route-only signed → 解锁 rebuild-C6 four-layer bench construction §1/§2/§3；retrain-c5 + data generation 仍 BLOCKED（等 C6 construction 完成 + candidate signoff + run auth）。

### 旧 ABC（已被 C5 goal 接管，留史）
- **战略 ABC 全拍**（D-001）：A 文档收敛 ✅done / B R5 runtime 闭环（**已回溯+probe 完成 D-004**）/ C LoRA 信心（teardown done D-003）
- **A 文档收敛**：✅ A2a 主线止血 + A2b UIUE 决策注册（方案1）done（D-002），**未 commit**（worktree dirty，等 worktree 同步①）
- **B R5 闭环**：✅ goal-dispatch 回溯 + 3-worker probe 核稿完成（D-004）→ **管道（bridge contract）已铺差不多**：text ✅已接 runtime+local/unit 闭环 / mic·card·cancel ❌缺 / §9.8-9.9 Gate4 ❌（docs reconcile）。**真缺口 = LoRA(C) + UIUE 消费侧（都 gated）**。B 只剩窄收尾（全 local/unit），**待拆窄切片派单上抛磊哥拍**。
- **C LoRA**：teardown 完成，verdict = 方向对 + 配方健康 + **严禁跳 gate**（D-003）
- **①5 worktree 同步待办**：磊哥留着不动

## 活跃决策指针（详见 `decisions.md`）
- **D-001** 战略对齐 ABC（Accepted）
- **D-002** A 文档收敛 A2a+A2b 方案1（Accepted，done 未 commit）
- **D-003** LoRA teardown verdict（Accepted）
- **D-004** B/R5 闭环回溯+probe 核稿（Accepted，管道已铺，B 剩窄收尾，defer 留档）
- **D-005** 🔴 C5 训练就绪 grill 编排（Accepted，grill 收口 332 决策两轮 audit 0 P0）：SSOT `docs/c5-training-readiness-grill/`
- **D-006** 🔴 5-gate construction 派单编排（Accepted 执行中）：磊哥批准 5 ❌ gate→3 worker（g6+裁决B / g5+裁决A / g7 hermes）+ 5 纪律（自维护图谱/teardown扩散/grill消减/先gitnexus/worker也gitnexus）；守 R7 construction-only
- **D-007** 磊哥 formal lock 5 gate ⭐（Accepted）：解审计 P0-2 proposed-not-locked，construction 继续
- **D-008** gate7 design 收口 + Q1-A/Q2-A 拍板（Accepted）：前数据集反思洞察（同源自审假异源 / 0/34 口径=生成产 4306 中文根因训练侧）
- **D-009** grounded grill round 收口（Accepted）：本 session 经验驱动 110 新决策，总监综合
- **D-010** grounded 净新载力 ⭐ locked（Accepted，磊哥「全部同意」）+ 回写 gate7 §10
- **D-011** 🔴 GPT Pro 第3家审 3 PR + 3 worker 修 findings + 磊哥拍 A merge（Accepted，%45 merge 中）：CI bug 根因（verify.yml 浅 clone 没 fetch head）+ 全 3 PR CI 绿 commander 亲核 genuine；R7 守住

## 下一步（候选，磊哥定）
- **B 窄切片派单**⭐：mic/card/cancel mock event shell + error terminal payload + §9.8/9.9 docs reconcile（全 local/unit，非 model-backed）→ 拆 3 worker 派单、subagent CC 审、上抛磊哥拍
- **C** 深挖某道 ❌ LoRA gate 怎么补（8 道里 3❌未实装：多轴 held-out / C6 四层阈值化 / 云 generator+异源 judge）
- **A commit**（13 doc + commander-log 一并提 or 等 worktree 同步①）

## swarm worker 拓扑（🔴 pane id 唯一，防 label 误射 probe）
- 我 = `%42` commander-status @ ma-status-swarm
- `%44` codex-1 @ MAformac ｜ `%45` codex-3 @ MAformac ｜ `%43` codex-2 @ MAformac-uiue
- ⚠️ label `codex-1/2/3` 在旧 `agents_probe_215413` session 重名 → 派单**必用 pane id**
- 产出落 `~/Projects/agent-tmux-stack-research/runs/`（见 `swarm-runs.md`）

## 起手读链（压缩后恢复上下文，顺序）
1. **本 INDEX**（指挥官决策层：做过啥/在哪）
2. **`SOUL.md`**（指挥官心法：我是谁/怎么做事/三条灵魂纪律）
3. `decisions.md`（决策史 D-001~004）+ `swarm-runs.md`（swarm 编排史）
4. MAformac `MEMORY.md` + `CLAUDE.md`（项目层）
5. grill SSOT `docs/grill-tournament/grill-decisions-master.md`
6. 最近 `docs/handoffs/`

---
authority: commander_cognitive_upgrade_dim3_dim4
artifact_kind: dialectic_synthesis_plus_system_principle_upgrade
status: landed
created: 2026-07-03 午后
decision_ref: D-053/D-054/D-055
inputs: t1-oom-premortem-iceberg-advice / t1-oom-diagnostic-runbook / token-budget-supervision-ledger（codex 第一次认知升级三档，全文逐行读）
---

# 认知升级·维度三与维度四：验证经济学与基线一等公民（含对 codex 三档的辩证）

## 一、对 codex 三档的辩证（接什么 / 磨什么 / 补什么）

**全盘接（且它比我先说对）**：
1. 口径重述成立——「不是 token 爆了项目降级；E-2 长度门有效（`max_token_length=7185`（PR31 final/T1）与 `7186`（N4A），均 <8192、violations=0，源=`docs/c5-training-readiness-grill/token-budget-supervision-ledger-2026-07-03.md:17` + 我的 recheck 日志）；真 blocker=首个 optimizer update 前 Metal OOM」。数字我亲手复跑过两轮（44459 与 113914 都出自我自己的 recheck log），全真。
2. 双 token 账（`max_token_length` vs `trainable_tokens`）必须分列——「长度绿」冒充「训练可跑」正是 claim-vs-reality 的资源维变体。
3. D0 instrumentation 先行 + 一变量纪律 + `diagnostic_not_candidate` 词表 + 禁沉默降配——全部与我们已锁的声称分层/单变量 DNA 同构，接。

**磨（技术性推进，不是否定）**：
1. 🔬 **「监督面 2.56x → backward 压力」的因果链需要 D0 裁决，它有一个更强的竞争假设**。机理上：LoRA backward 的显存大头= activation 驻留（∝ batch × seq_len × hidden × layers，**与多少 token 被监督无关**——logits 对全序列算完才被 mask，label 重分类不改 activation/logits 体积）。真正与 v6 tiny（能训）的第一性差异是：**wave 数据含 ~7185 token 长序列，而 mlx-lm 按长度排序组 batch → 首个训练 batch 可能= 4×~7k 的最长行**（val 只 forward 不驻留 activation，所以 val 能过）。→ 两个具名假设进 D0：**H-act（长序列×batch4 activation 驻留）** vs **H-sup（监督面扩大）**，D0 的 memory profile 按阶段分账（val 峰值 vs 首个 train step 峰值、logits vs activation 归属）即可判。
2. ➕ **矩阵缺一个低语义风险大杠杆：D1b「token 预算 batching」**。codex 把「长度」的旋钮只列成 D5 max_seq 降档（HIGH，丢覆盖）；但我们的训练 loop 是**自有的** `maformac_iterate_batches`（repo 代码，非 stock）——可以实现**按 token 总量组 batch**（长行独行、短行多行，数据零丢失、语义零变化），比「全局 batch=1」保吞吐、比 D5 保覆盖。若 H-act 成立，D1b 是正解形态。
3. 🎯 **归因收窄**：「PR31 final 把监督面从 44459 扩到 113914」——精确说法是 **main 侧契约硬化（`73b6e360`+`458820fa`，#27/#33 系）** 扩的，PR31-final 只是首个在其下重建的 artifact。归因到 commit 不归因到重建动作，防未来读者把「重建」当祸首。

**补（codex 没说、但被今天整个时间线证明的）**：见下两节。

## 二、维度3：验证经济学——失败到达点成本原理

今天是一场自然实验：**每一个失败都被某道设计过的边界接住，且接住成本 ≈ 到达点越早越便宜**——canary judge 抓溯源（分钟级）/ 基线复跑抓假绿（分钟级）/ T1 smoke 抓 OOM（2 分钟，替代掉的是「正式训练数小时 + 污染 lineage + 第三次 0/34」）。

**原理**：系统要优化的不是「门更多」，而是**每类风险都存在一道 marginal cost ≪ 下游爆炸半径的最早到达门**。T1 的 elephant（memory-budget gate 缺失）只是实例：**资源维风险类此前没有任何廉价到达点**，于是失败被迫到达在第一个真实执行点。

**机械化落点：风险类 × 最廉门矩阵**（缺格=elephant，逐格补）：

| 风险类 | 最廉到达门（现有） | 成本 | 缺口 |
|---|---|---|---|
| 语义/契约 | strict preflight / DataGate 语义门 | 秒-分 | — |
| 溯源/provenance | ledger fail-closed + 异源 judge | 分 | ✅ 今天补齐 |
| 数据质量 | canary（小批先行） | 分 | — |
| **资源（显存/墙钟/磁盘/热）** | **T1 类 micro-smoke + memory profile** | 分 | 🔴 本次暴露，T1D 后固化为一等门 |
| 声称/口径 | cite-verify hook + 基线复跑 + 声称分层 | 秒-分 | — |
| 组织（worker 假绿/闲置） | 收稿基线亲核 + idle-scan | 分 | ✅ 今天补齐 |

**推论**：任何新「X-ready」声称，从此必须带**资源包络证据**（peak memory / wall clock）两列——资源维与语义维同权。

## 三、维度4：基线是一等公民（Acceptance-Basis Registry）

今天三次混乱同根：**验收基线是隐式的、散在 receipt 里、版本迁移没有 owner**——N4A 数据 vs 重生成数据（假绿）、f163eedf 代码面 vs 合并硬化面（exit66 惊吓）、旧 preflight 语义 vs 新语义（44459 vs 113914 初看像矛盾）。M.14 说「验证必须绑基线 artifact」，更高形态是：

**建 `BASELINE-REGISTRY.md`（单文件）**：每条 lane（代码面/数据面/评测面）的**现行 basis（sha）+ supersede 史 + 迁移事件**（谁、为何、哪些门必须在新基座重跑）。规则两条：① 一切 receipt/验证必须 cite `basis_id`；② basis 迁移=决策日志事件+迁移 checklist，禁静默换基。今天两次基线迁移（N4A→PR31-final、f163eedf→b33d8eba）都发生了正确的重跑，但**靠的是我临场坚持而非机制**——机制化后它是查表。

## 四、维度5（元回路）：磊哥在跑的升级节律本身

工作 → 停 → 异源认知升级（codex 维度1 事实重述 / 我维度2 机制 / 维度3+ 系统原理）→ 制度化 → 复跑。给它一个契约：**每次复盘必须产出 ①事实重述 ②机制补丁 ③≥1 个系统原理候选 ④memory/rules 落点分层（维度1→项目档 / 维度2→lessons·宪法 / 维度3+→全局 rules）⑤Elevate-or-Kill 自检**（原理候选必须被一个真实事故检验过才立，防安慰剂治理）。

## 五、后续编排蓝图（grill+拆解+分派，全工种）

| 线 | 内容 | 工种 | 分派 | 依赖 |
|---|---|---|---|---|
| **L1 T1D 诊断**（关键路径） | T1D grill 骨架（承 codex 矩阵 + D1b 增题 + H-act/H-sup 双假设判据）→ D0 profile → D1/D1b/D2/D3 单变量 → 候选配方 manifest | grill+开发+测试 | grill=commander 纵切；D-run 执行=%44（harness 主刀）；receipt 审=%43 | T1D grill lock |
| **L2 wave-1 生成**（与 L1 并行，不吃训练显存） | hash 重算接线（N5E-002⑥ 开发）+ manifest 锁值显式化（refusal footgun P1 修）+ controller 批 manifest 构建 → lane sub-CC 生成（复用 canary 模式）→ 机械门全量 + %43 judge 抽样（作业书） | 开发+生成+审计 | %45 开发接线；lanes=后台 subCC（Opus）；judge=%43 | basis=pin `b33d8eba`；N5E rev2.1 契约 |
| **L3 salvage** | projection adapter 开发 + 两 stop gate 跑 3804 池 | 开发+数据 | %45（其方案） | L2 接线共用 |
| **L4 CI/CD** | verify.yml push-event 结构性失败修（diff 基线）；make verify-all 是否挂 CI（grill-lite 一题） | CICD | %44 backlog | 无 |
| **L5 文档/记忆** | BASELINE-REGISTRY 建档；PR30 关闭（#32 已并）；豁免窗口 07-13 到期摘 banner（日历项）；docs 分支下轮同步 | 文档 | commander+%44 | 无 |
| **L6 训练候选**（T1D 后） | 候选配方 → preflight/DataGate 重跑 → 短训 → F-044 A/B/D 重评 → 磊哥 sign | 训练+评测 | grill 后定 | L1 PASS + L2 数据 |
| 冻结不动 | UIUE M4 / R7 candidate line（route-only 至 07-23） | — | — | 磊哥 |

## 六、机制升级落点（本档的可执行输出）
1. 全局 rule：`~/.claude/rules/verification-economics-baseline-registry.md`（维度3+4 的 recognition 扳机，precision 版）。
2. 项目：`docs/BASELINE-REGISTRY.md` 建档（三 lane 现行 basis 即刻登记）。
3. lessons **M.15**：「数字核真 ≠ 后果定价」——我在 recheck3 亲眼看到 44459→113914 写了 expected 却没有定价其显存后果（第四层 claim-vs-reality：核对了真实性，没核对含义）。
4. D-055 决策记账 + MEMORY as-of。

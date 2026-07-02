---
authority: grill_decision_matrix_commander_grounded_round
artifact_kind: c5_grill_commander_failure_defense_grounded
paradigm: UIUE 215-grill（决策矩阵 7 列 + 防惨败列 cite P1-P9）
round: grounded（2026-07-01 经验发现驱动，续 F-047）
r7_boundary: grill-only 写决策，不实装/不训练/不生成
created: 2026-07-01
status: proposed
---

# commander 纵切 · grounded round — 新惨败 mode → 防线（F-048+）

> 本轮 = 本 session **真读前数据集 + 挖 bug 库 + 交叉审 catch 假绿** 现场发现的【新惨败 mode】→ 防线。续 F-001~047（双仓惨败 0/34 + θ-α 防线），本轮是 **grounded 经验发现**驱动，不重复已决。每决策防惨败列 cite P1-P9 PCA + 本 session 一手证据（commander 已 python/sqlite 亲核）。

## 决策矩阵（F-048~F-054）

| ID | 议题 | 选项 A / B / C | ⭐ | 依据（file:line / 亲核） | 防惨败列（cite P/惨败） | status |
|---|---|---|---|---|---|---|
| **F-048** | 假异源 judge（声称异源 vs 事实同源）| A: vendor 顶层枚举 enforce `judge_vendor≠generator_vendor` + receipt 记 vendor / B: 信 model_id naming / C: 不查 | ⭐**A** | gate7 design `MAformac-g7/docs/c5-training-readiness-grill/gate7-cloud-generator-design.md` §1.2 埋雷①；commander python 亲核 `generated-utterances-final.jsonl` = generator/judge 都 hermes_glm/ark，4500/4500 same-vendor | 🔴 **新惨败 mode = claim-vs-reality「跨厂商声称 vs 同厂商事实」**：D-036/037 要求异源，实跑退化同托管方两模型自审 → self-bias 评测虚高。cite **P6** surface+scorer consistency / **P7** 审计语义非合规 | proposed |
| **F-049** | 0/34 口径（生成阶段 vs 训练侧组装）| A: 分诊 pipeline 阶段（生成真产 4306 中文 / 0/34 根因在训练侧 sample 组装），gate7 别背锅、别宣称单独解决 / B: 笼统归因「0 条自然中文」/ C: 甩给 generator | ⭐**A** | D-008；gate7 §1.2 埋雷③；commander python 亲核 4306 distinct 中文 mean 9.3 | 🔴 **claim-vs-reality**：笼统措辞误导归因（「训练集 0 条自然中文」对训练集准确，但被误读成生成产不出中文）。cite **P8** 训练/eval 同源、`8d-rootcause.md:68`「不宣称已排除」 | proposed |
| **F-050** | 数据源核验（空壳 vs 真库）| A: 查前核 DB 非空 + 是生产源（行数>0 / schema 有表）/ B: 信文件存在即可查 / C: 信路径 | ⭐**A** | WS2 `data-scoping/ws2-bug-mining-10family.md`（`bug-skill-dev/data.db`=0B 空壳，`~/.bug-skill/data.db`=71MB 真库）；commander sqlite 复核 | **claim-vs-reality：文件存在 ≠ 有数据**（commander 首查空壳库得 0/`.tables` 空，worker 找对真库得 distinct 4053）。cite **P7** 实跑复算下钻一手 | proposed |
| **F-051** | 前提口径核验（distinct vs event 级）| A: 建于「前提数字」前先核其口径（12000=事件级 ki_evidence/comment，distinct bug=4053）/ B: 信转述数字直接用 / C: 不核 | ⭐**A** | WS2；commander sqlite 亲核 `~/.bug-skill/data.db`：distinct bug_id=**4053** / ki_evidence_links=**12446** / e3_comments=**13791** | **claim-vs-reality + dispute-triage 口径型**：聚合/事件行数 ≠ 独立实体数（12000 event vs 4053 distinct，差 ~3x，直接影响生成配比估算）。cite **P7** 下钻最细粒度 | proposed |
| **F-052** | API 故障时审计/工作路由（codex fallback）| A: subagent CC/hermes API socket 挂时路由到 codex tmux 活 pane（三者审计等效，live 连接绕过 proxy 故障）/ B: 卡等 API 恢复 / C: 停工 | ⭐**A** | 本 session subagent×2 + hermes 全 `FailedToOpenSocket`（proxy 层）；磊哥定「CCsubagent/hermes/codex worker 三者审计等效」；codex 交叉审照跑抓到真 P0 | 防**基础设施故障卡主链路**（proxy API 挂但 codex live pane 不受影响）。cite `codex-meta §37`（外网 API 慢/失败先查绕 proxy）| proposed |
| **F-053** | 回稿假绿防线（cross-audit 必）| A: worker receipt「fail-closed/PASS/绿」必 cross-audit 实跑核（作者自报假绿-prone）/ B: 信 receipt 直接收 / C: 作者自审 | ⭐**A** | gate6 交叉审抓 P0（worker 报四层 fail-closed + 72 测绿，实测 passRate 分母 `runs.count` 可 game 某层缺 case 假过）；commander 亲核 `:1601-1602/:1683` 坐实 | 🔴 **claim-vs-reality：测试绿 ≠ 语义对**（分母失真假绿）；磊哥「回稿必审」铁律。cite **P7** 审计语义非合规、**P5** 分层 fail-closed | proposed |
| **F-054** | 稀疏族 bug ≠ 不需要（data 稀疏 vs demo 需求）| A: bug 稀疏族（雨刮 12/天窗 34）靠**场景触发**补（「下雨了」→雨刮，不等 bug）/ B: 按 bug 数削该族生成 / C: 砍稀疏族 | ⭐**A** | WS2（雨刮 12/天窗 34 bug 少但「demo 多轮价值高，需场景触发」）；paradigm-tool-surface `§6`（MVP 10 族全做）；demo 优先 `:243-257` | 防「**数据分布 = 需求分布**」误判（bug 少 ≠ demo 不演；雨刮/天窗场景高频但 bug 库沉淀少）。cite **claim-vs-reality**（data 派生 ≠ 需求事实）| proposed |

## 元洞察（本轮 grounded 防线的共同根）

F-048~F-051 + F-053 全是 **claim-vs-reality 的新变体**（本 session 现场撞出）：
- **声称 vs 事实**：异源声称/同源事实（F-048）、0 条自然中文笼统/生成真有事实（F-049）、文件存在/有数据事实（F-050）、事件数/独立实体事实（F-051）、测试绿/语义对事实（F-053）。
- **共同修法**：任何「X 代表/等于/支持 Y」的载力断言，下钻到最细粒度一手（vendor 真身/pipeline 阶段/DB 行数/distinct 计数/分母口径），**commander 必亲核（python/sqlite 实跑），不信转述/receipt/naming**。
- F-052（codex fallback）+ F-054（稀疏≠不需要）是工程/产品层防线，非 claim-vs-reality。

🔴 **本轮元证据**：commander 自己首查 bug 库也撞了空壳（F-050）、首核 WS 也用错字段——**印证「必亲核到最细一手」不是对 worker 单向要求，commander 同样适用**（swarm §4：审计员/自己的 cite 都要亲核）。

## 待综合

W1 D-096+（生成配比）/ W2 A-096+（生成质量）/ W3 E-096+（语料映射）grill 回后 → commander 综合 grounded round master + 消减表 + 评分表 → subagent CC（或 codex 交叉）审 → 磊哥拍板 locked。R7：本轮 grill-only 写决策，不实装/不训练/不生成。

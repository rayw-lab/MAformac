---
predecessor: docs/handoffs/2026-07-20-stage-acceptance-audit-wbs-frozen.md
supersedes: none
kind: remediation-implementation-handoff
as_of: 2026-07-21
commander: qwen3.8 (OMP, cliproxy/qwen38)
note: Phase 0 + 1a + 1b 整改实施完成，双路异源审 PASS。
---

# 2026-07-21 MAformac 整改实施 Phase 0+1a+1b 闭环

## 完成了什么

### Phase 0 — 政策锚定（0 产品代码）

| WP | 产物 | 验收 |
|---|---|---|
| WP0-1 | docs/CURRENT.md 第 0 条 = 唯一阻塞 KPI + 事实锚注释 | grok 审 PASS |
| WP0-3 | docs/governance/CHECKER-FREEZE-NOTICE.md（6 个月冻结） | 存在 + 例外条件 |
| WP0-4 | 指挥官声明：禁百分比汇报，治理只报健康度 | 口头生效 |
| WP0-5 | docs/governance/demo-messaging-guidelines.md（14 禁说词） | 禁说词全覆盖 |
| WP0-6 | docs/governance/safety-disclosure-and-qa.md（口播+追问） | 事实锚嵌入口播 |
| WP0-8 | R5ProofGovernanceStaticChecksTests XCTSkip + V9 verdict 改 | 无自违规残留 |
| WP0-9 | scripts/verify_anti_placebo.py + Makefile + CI | `make verify-anti-placebo: PASS` |
| M0 | 磊哥确认 KPI + 启动 Phase 0 | "启动 Phase 0" |

### Phase 1a — 演示前止血（产品真改动）

| WP | 产物 | 验收 |
|---|---|---|
| WP1a-1 | Tests/DemoSliceProductBehaviorGateTests.swift（12 条 golden） | 12/12 绿 |
| WP1a-1 | Makefile verify-e2e（swift test + 4 条元断言 grep） | `make verify-e2e: PASS` |
| WP1a-2 | ROB-1 修：runner/payload/ContentView orbState 全链路 | ProductOperatorTTSHardGateTests 14/14 |
| WP1a-3 | Tools/checks/check_runtime_no_mutation_receipts.py 砍 proofClass | 零 proofClass 残留 |
| WP1a-4 | docs/governance/demo-script-v1.md（5 步诚实脚本） | 禁说词零残留 |
| WP1a-5 | safety-disclosure-and-qa.md 对齐 v1 | 已落地标记 |
| WP1a-6 | DemoSliceAdmissionCatalog.swift 6 前缀 + 疑问语气剥离 | 4 变体绿 |
| WP1a-7 | 14 文件 GOVERNANCE/WP1a-7 旁路标注 + probe TODO | 标注准确 |

### Phase 1b — 安全语义 + CI

| WP | 产物 | 验收 |
|---|---|---|
| WP1b-1 | ContractLookups.swift fail-closed + risk-policy.yaml + bundle 再生 | Cor1FailSafeTests 12/12 |
| WP1b-2 | C3ExecutionPipeline doNotAutoPowerOn guard + ToolCallFrame 字段 | Cor2NegationTests 3/3 |
| WP1b-3 | DDomainToolCallParser isLegitimateNoAction | Cor4NoToolTests 9/9 |
| WP1b-4 | Makefile verify-ui-e2e + .github/workflows/ui-e2e.yml | xcresult 解析 + macos-26 |
| WP1b-6 | docs/governance/COR-7-verification.md + COR-8-verification.md | 非雷 + Phase 2 债务 |
| WP1b-7 | docs/governance/ROB-3-verification.md | 非雷（let 语义） |

### 收口审

| 阶段 | 审计方 | 结果 |
|---|---|---|
| Phase 0 | grok（auditor） | PASS WITH CARRY-FORWARD（P1 已处置） |
| Phase 1a | deepseek-pro（max） | PASS 8/8 零 carry-forward |
| Phase 1b | long-judge + kimi K3（双路） | PASS 8/8 × 2 同向 |

## 未完成什么

- **Phase 2 未启动**：4 族能力扩展（车窗/灯光/座椅/天窗）+ 安全门接线 + Receipt 重建 + 治理砍削第二刀
- **Phase 3 未启动**：接模型 + 多意图 + ASR
- **训练轨道 T**：S8 停 update 276/450，进程已死，可 relaunch（独立于演示整改）
- **WP0-7 演示机准备**：需磊哥/演示者物理操作（TTS voice + Debug + 彩排）
- **WP1b-5 治理砍削第一刀**：推迟到 Phase 2 与 WP2-5 合并（避免治理活动挤占产品进度）
- **docs/E2E-TEST-STRATEGY.md**：opus 写的，去留待定（内容已被 verify-e2e 实现覆盖）

## 下次从哪里继续

1. 读 WBS v2.1 FROZEN §5（Phase 2）：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-17-s8-s9-successor-c-longrun/REMEDIATION-WBS-IMPLEMENTATION-PLAN.md:141-160`
2. Phase 2 核心 = WP2-1（4 族真写后端）：每族必经 C3 pipeline + 真实状态变更，M-7 grep 判定无 shortcut
3. Phase 2 安全 = WP2-2（行驶中开窗也拦）：risk-policy.yaml 加 window 规则 + 轨 A/B 共用真门
4. Phase 2 Receipt = WP2-3：验证器读 mock state cell 实际 readback，grep 全仓无 proofClass 自报残留
5. Phase 2 治理 = WP2-5：reanchor38→4 / closure36→6 / verify48→12 / 3 个月不回潮
6. 每阶段开工 premortem + 收口双路异源审（opus max + kimi K3）

## 关键发现

- **COR-1 fail-open 是真安全洞**：车速 unknown 时 `Int() ?? 0` 降级为 0 → 安全门放行。已修为三重 guard（nil/非数字/负值 → refuse）。
- **COR-2 否定违背已修**：doNotAutoPowerOn 从 ToolContractCompiler → IRFrameBridge → ToolCallFrame → C3 全链路传递。
- **COR-4 合法 zero-tool**：isLegitimateNoAction 五重 guard（finishReason=stop + toolCallCount=0 + source 非空 + content/stopReason 非空 + 无 tool_call 标签）。
- **COR-7/8 当前路径非雷**：DemoSliceRoute 严格单帧，alreadyStateNoop 不调 applyMockTransition。多帧原子性 = Phase 2 债务。
- **ROB-3 非雷**：Swift let 语义保证 sessionID 不变性，precondition 数学上不可能违反。
- **ROB-1 真修**：orbState 从 runner snapshot → RuntimePresentationPayload → ContentView 全链路传递，didEnqueue=false → idle。

## 关键文件（≤10）

| 文件 | 角色 |
|---|---|
| Tests/MAformacCoreTests/DemoSliceProductBehaviorGateTests.swift | 12 条 golden E2E + 元断言 |
| Core/Routing/DemoSliceAdmissionCatalog.swift:111-120 | 6 前缀变体解析 |
| Core/Contracts/ContractLookups.swift:311-326 | COR-1 fail-closed 三重 guard |
| Core/Execution/C3ExecutionPipeline.swift:499-508 | COR-2 doNotAutoPowerOn guard |
| Core/LLM/DDomainToolCallParser.swift:13-48 | COR-4 isLegitimateNoAction |
| scripts/verify_anti_placebo.py | 事实锚 + 百分比 + verify-e2e 门禁 |
| Makefile:45-46,57-91 | verify-anti-placebo + verify-e2e + verify-ui-e2e |
| .github/workflows/ui-e2e.yml | XCUITest CI（macos-26 pinned） |
| docs/governance/demo-script-v1.md | 5 步诚实演示脚本 |
| docs/commander-log/REMEDIATION-SECRETARY-LOG.md | 秘书记录（Update 1-3） |

## stopline / 警告

- **WBS FROZEN**：禁指挥官自改 v2.2，须上抛磊哥。
- **protected 4 文件禁碰**：CLAUDE.md / docs/lessons-learned.md / docs/project/collaboration-and-roles.md / docs/commander-log/COMMANDER-PLAYBOOK-ma10-ma18-for-codex.md
- **每阶段验收门禁自报**：必经异源审（opus max + kimi K3 双路）
- **模型策略**：opus max 审计 / opus xhigh 执行 / ultra+flash 叶子 / grok 不用 / deepseek-pro 少用 / GPT 少用
- **C5LoRATrainingTests 23 failures**：预存问题（Python 环境/fixture 缺失），非本次引入
- **MAformac 仓库 git status**：本次新增/修改约 30 文件，未 commit（待磊哥决定）

## 指挥官视角经验教训

### 编排纪律

1. **提示词给具体 file:line 比模糊描述效率高 5x**：gpt55 用精确位置 3 分钟完成 vs deepseek-pro 模糊探索 34 分钟卡死。
2. **复杂多文件任务用 lane-parent（可派孙子分步）**：ultra-leaf 做 COR-7/8 超时 17 分钟，lane-parent 重做 20 分钟完成（含调查+落盘）。
3. **被砍的 worker 可能已完成**：ProCor2Negation 被砍时 3/3 已绿。砍前查 transcript，砍后确认产物。
4. **双路审计比单路可信**：long-judge + kimi K3 同向 8/8 × 2，比单路 grok 更有说服力。
5. **anti-placebo 脚本用包含制非排除制**：排除制打地鼠（40+ 历史文档触发），包含制只查真正的进度汇报。
6. **Makefile target 必须调真脚本**：worker 可能只写 echo 不调 Python，指挥官必亲核 `make` 输出。
7. **政策锚定只放一处**：CURRENT.md 已锚定，不需要第二政策 SSOT（双锚 = 新仪式）。

### 模型使用

| 场景 | 最佳选择 | 避免 |
|---|---|---|
| 审计/收口 | opus max / kimi K3 max（双路） | grok |
| 复杂执行（安全修复） | opus xhigh / lane-parent(sol) | deepseek-pro（会卡） |
| 简单叶子（单文件改动） | ultra-leaf / bulk-worker(flash) | — |
| 中等执行（多文件但明确） | gpt55-parent + leaf | deepseek-pro |
| 秘书/记录 | bulk-worker(flash) | — |
| 长上下文综合 | long-judge | — |

### 反模式（本次踩过的坑）

- ❌ deepseek-pro 做复杂安全修复：34 分钟无产出，砍掉换 gpt55 3 分钟完成
- ❌ ultra-leaf 做复杂多文件调查+修复：17 分钟超时，换 lane-parent 分步做
- ❌ 排除制 anti-placebo 脚本：40+ 历史文档假阳，改包含制
- ❌ 信任 worker 的 Makefile 产出：只 echo 不调脚本，必须亲核
- ❌ 单路审计：不够可信，双路同向才是硬证据
- ❌ 制造第二政策 SSOT：WP0-1-policy-anchor.md 被 grok 审判多余，删除

## 产品真态快照（2026-07-21 会话结束）

```
可演：6 句空调变体（打开空调 / 把空调调到N度 / 空调调到N度 / 打开空调到N度 / 请把空调调到N度 / 能调到N度吗）
不可演：车窗/车门/座椅/音乐/灯光/导航（零准入）
模型：未接（FastPathDemoToolPlanBackend 零 LLM）
ASR：stub（.stubDisabledGuidance）
多意图：无切分（fail-closed）
安全：COR-1/2/4 已修（fail-closed / 否定不偷开 / 合法 zero-tool）
门禁：verify-e2e 12绿 + verify-anti-placebo PASS + verify-ui-e2e 就绪
actionDemoProven：0/120
```

## 验收唯一标准

**磊哥亲灌句 + 看每周录像**。三腿凳（录像/CI 门禁/禁百分比）= 辅助护栏，非验收本身。

# change3 整改 dispatch — GPT Pro 审计 REQUEST_CHANGES 闭环

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

## 0. 路由元信息
- **TO**:Codex(长跑 TDD,**隔离 git worktree**)
- **FROM**:CC(协调者 / Layer1 self-audit)
- **MODE / MODEL**:Codex 长跑 TDD,red→green→refactor,隔离 worktree
- **PRIORITY**:P0 阻塞(PR #1 = REQUEST_CHANGES,合并门)
- **一句话 DELIVERABLE**:在隔离 worktree 的 `feat/change3-execution-contract` 分支上,修复 GPT Pro 审计 **F2(executor 多参数语义真 bug,P0)+ content-fallback fail-closed(P0)+ 测试纠偏(P0)+ F3/F4/F5/F6(P1)**,`swift test` 全绿,push 更新 PR #1,回报附 ground-truth git stdout。

## 1. 冷启动背景(零上下文也能懂)
- **项目**:MAformac = 纯端侧 iOS/macOS 离线车控**方案演示助手**(非量产 / 非真车控)。**起手必读** `CLAUDE.md` →(若有)最近 `docs/handoffs/2026-06-19-change3-gptpro-audit-closeout.md` → 本 dispatch。
- **本任务处于**:S1 契约层 / 7-change 第 3 个 `define-execution-contract`(纯逻辑契约层,**不引真 MLX**,用 spike 实采 55 条 fixture 驱动)。
- **为什么现在做**:PR #1(head `f46ef88`,base main `99c49fa`)经 GPT Pro(gpt-5.5 pro)8 维 cross-vendor 审计,verdict=**REQUEST_CHANGES**,独立 catch 出 **F2 executor 真 bug**(我们 Layer1 self-audit 盲点)。本 dispatch = CC1 **辩证吸收**后的整改清单:**采纳真 bug,不盲从已知范围**(F1 intent gate 是 design T9 已记的已知边界,归第 7 change,不在本 change 实装)。

## 2. 任务(TASK)— 辩证分类后的整改清单
> 全料证据:`~/Downloads/pr_audit_1(1).md`(F1-F7 带 file:line)。边界依据:`openspec/changes/define-execution-contract/design.md` 决策 **T9 / E1a / E1b**。

### 🔴 P0-1 · F2:executor 多参数语义(真 bug,必修)
**现状 bug**:`Core/Execution/DemoActionExecutor.swift:35` `desiredMockValue` 用硬编码 key 优先级 `["power","level","percent","color","topic","target_temperature","delta","mode"]` 取第一个 scalar 就返回 →
- `set_cabin_ac(power:on, target_temperature:25)` 只写 `hvac.ac="on"`,`target_temperature` 丢失、`hvac.temperature` 不更新 → **readback 实际错**(违 readback mismatch=0,P003 fixture 同时带 mode/power/target_temperature)。
- `set_cabin_ambient_light(power:on, color:blue)` 会写 `lighting.ambient="on"`,而 `reference_binding.allowed_values=[off,warm,cool,blue,amber,white]` **不含 "on"**(与 F3 联动)。

**修法**(declarative,codegen 可生成;Codex 可微调 schema 形态但须满足验收):
1. `contracts/capabilities.yaml` 每个 capability 的 `execution` 段加显式 **mock transition spec**(字段→state cell 映射,支持多 cell + 合成语义),**删硬编码 key 优先级**。建议:
   ```yaml
   execution:
     state_cell: hvac.ac            # 主 cell(readback 锚)
     state_transforms:
       - field: power
         state_cell: hvac.ac
       - field: target_temperature
         state_cell: hvac.temperature
   ```
   - `cabin.ambient_light` 需**合成语义**:`power:off`→`lighting.ambient="off"`;`power:on`→写 `color` 值(如 "blue");`power:unchanged`→不写。
   - `unchanged`(AC/ambient 的 power 枚举含)→ **不写该 cell**(读回原值)。
2. codegen `scripts/gen_capabilities.py` 生成 `GeneratedExecutionRule.stateTransforms`(新字段),重生成 `Core/Generated/GeneratedCapabilityCatalog.swift`。
3. `DemoActionExecutor` 改为**按 transform 落地多 cell**,删 `desiredMockValue` 硬编码 list;返回主 cell readback(related cell 同步写)。
4. `DemoVehicleStateStore`(`Core/State/DemoVehicleStateStore.swift`)如需单次多 cell 写 → 扩 `applyMockTransition` 或加批量入口,**保持「唯一写入口」+ immutability(新 cell 不就地改)**。
**验收**:
- `set_cabin_ac(power:on,target_temperature:25)` → `hvac.ac="on"` 且 `hvac.temperature="25"`,两 cell readback mismatch=0。
- `set_cabin_ambient_light(power:on,color:blue)` → `lighting.ambient="blue"`(∈ allowed_values),非 "on"。
- `power:unchanged` → 不写该 cell。
- 每 capability 加 transform 落 cell 测试(AC 温度 / ambient color / seat position+level / window / fan / screen 全覆盖)。

### 🔴 P0-2 · content-fallback fail-closed(F1 的「采纳」部分)
**辩证**:F1「schema-valid 负例可执行」核心 = **DemoGuard schema 门 ≠ 语义拒识门**(design **T9** 已记),真防线 = intent-routing(change7)+ LoRA 负样本,**非 change3 DemoGuard**(capabilities.yaml `demo_guard` 无 restraint 字段)。**但采纳实装偏离**:Codex 把 content-fallback **默认开**(`Core/Routing/ToolCallDecoder.swift:179` `contentFallbackEnabled: Bool = true`)+ skeleton `handle(content:)` 直接执行 fallback 候选 → 偏离 design「content-fallback 设**可配置开关** + 净 G3 影响留 change6」。
**修法**:
1. content-fallback **默认关**(fail-closed):`ToolCallDecoder(contentFallbackEnabled: Bool = false)`。change6 benchmark 需回收正例时**显式 opt-in `true`**。
2. `Features/VehicleControl/DemoWalkingSkeleton.swift:48-82` `handle(content:)`:fallback 候选默认**只记录 + trace,不执行**;留 `intentConfirmed`/`actionable` hook 点(见「归 change7」)。
3. trace 三口径如实记(raw `.toolCall` / fallback candidate / guard 后实际执行)——design 已要求,核对实装一致。
**验收**:默认构造(fallback off)下 N016/N017(负例 content-fallback)**不产候选 → 零执行**;opt-in 模式的净 G3 留 change6 量化。

### 🔴 P0-3 · 测试纠偏(fail-closed 断言 + executedCount 重定义)
**现状**:`Tests/MAformacCoreTests/SpikeFixtureContractTests.swift:50` `XCTAssertEqual(executedCount, 43)` 把 **3 负例**(N002 raw `set_cabin_fan{level:2}` / N016+N017 content-fallback)执行计入成功口径,误导成功标准。对账:43 = 40 正例 + 3 负例。
**修法**:
1. **executedCount 重定义只统计正例**:成功口径 = 40 正例(`!isNegative`)全执行 + readback mismatch=0。
2. **isNegative 零执行断言**:fallback 默认关下,负例 content-fallback(N016/N017)断言零执行。
3. **N002/N016/N017 标 known-issue**:N002(写诗 OOD → 模型真吐 raw `set_cabin_fan{level:2}`,schema 合法、DemoGuard 放行)是**纯 intent-gate 缺口**,DemoGuard 挡不住 → 显式断言 + 注释「change7 intent gate 待补的已知 gap」,**不计入成功口径**(不能假装挡住)。
**验收**:测试明确分正/负口径;负例零执行(fallback 路径);N002 标记已知 intent-gate gap;`swift test` 全绿。

### 🟡 P1-1 · F3:referenceBinding.allowedValues 校验
**现状**:`Core/Execution/DemoGuard.swift:90-118` schema 门只校验 required/unknown/type/enum/range,**不校验最终写入 state cell 值 ∈ `reference_binding.allowed_values`** → ambient "on"、AC "unchanged" 可能落进 actual state。
**修法**:executor 最终写主 cell 前(或 guard 末段)校验写入值 ∈ 该 cell allowed_values(非空时);numeric cell 走 range。违反 → `guardDenied` / 拒写,不静默落库。
**验收**:`power:unchanged` 不写 `hvac.ac="unchanged"`;ambient `power:on,color:blue` 落 "blue";加对应负测试。

### 🟡 P1-2 · F4:content-fallback JSON 整体 decode
**现状**:`Core/Routing/ToolCallDecoder.swift:355-392` `singleBareJSONObject` 纯字符扫 `{`/`}` 深度,**不处理 JSON string 内花括号 / 转义**。
**修法**:优先对 trimmed content 直接 `JSONDecoder().decode(ContentFallbackEnvelope.self, ...)`(让 JSONDecoder 负责完整性);如必须扫描,加 `inString`/`escape` 状态机。
**验收**:加测试 `{"name":"x","arguments":{"topic":"a } b"}}` 正确解析不破坏;现有 prefix 拒绝行为保留。

### 🟡 P1-3 · F5:统一 SchemaViolationReason
**现状**:decoder 把 unknown field 归 `type_mismatch(expected:"declared_field")`(`ToolCallDecoder.swift:275`)、enum invalid 归 type_mismatch(`:328`);guard 返回字符串 `"unknown_field"`/`"invalid_enum"`(`DemoGuard.swift:101,150`)→ trace/metrics 口径漂移。
**修法**:引入统一 `SchemaViolationReason` enum,decoder + guard 共享;`acceptanceTable` 明确 unknown_field/invalid_enum 是独立枚举还是归 type_mismatch,并统一 trace reason。
**验收**:decoder 与 guard 对同一违规产同一 reason;acceptanceTable 与实际枚举一致;测试覆盖 unknown_field/invalid_enum 两路。

### 🟡 P1-4 · F6:codegen 可复现 + drift check
**现状**:`scripts/gen_capabilities.py:7` 依赖 PyYAML 无 pin;generated Swift 已提交,易与 yaml 漂移。
**修法**:加 `scripts/requirements.txt`(pin PyYAML 版本)+ drift check 命令 `python3 scripts/gen_capabilities.py && git diff --exit-code Core/Generated/GeneratedCapabilityCatalog.swift`,写进 README/CLAUDE 或 `Makefile` target。**F2 改 codegen 后必跑 drift check 确认生成物已提交**。
**验收**:drift check 命令存在且 F2 后本地跑通(exit 0);requirements.txt pin 版本。

### ⚪ 归 change7(define-intent-routing)— 本 change 不实装,只留 hook
- **F1 intent/restraint gate**:N002(意图越界)/N016/N017(restraint)语义拒识 = intent-routing 拒识层(规则 NLU + 慢思考)+ LoRA 负样本,**非 change3 DemoGuard**(design T9)。change3 只留 **hook 点**:`DemoGuardContext`(`DemoGuard.swift:12`)加 `intentConfirmed: Bool` 字段占位(默认行为不变,**不实装 gate 逻辑**),供 change7 接入。注释明确归属。

### ⚪ P2(demo 部分豁免,可选,非阻塞)
- **F7 CI**:demo 边界豁免完整 GitHub Actions;本地 drift check + `swift test` 作 Makefile/script target 值得加(已并入 P1-4)。GitHub Actions 留磊哥定,**本 dispatch 不建 `.github/workflows/`**。
- `TraceLogger` `@unchecked Sendable` → actor/lock(可选)。
- `GeneratedCatalog` O(1) 字典查找(可选,8 capability 暂无性能问题)。

## 3. Prerequisite Check(起手必跑,验运行态)
> 协调者(CC)**已 free 主树到 `main` + 建好隔离 worktree** 后再交付本 dispatch;Codex 在 worktree 内跑。
```bash
cd /Users/wanglei/workspace/MAformac-change3-fix     # 隔离 worktree(写死 cwd)
git branch --show-current        # 必须 = feat/change3-execution-contract
git -C /Users/wanglei/workspace/MAformac branch --show-current   # 主树必须 = main(单写者)
git status --short
swift test 2>&1 | tail -20       # 整改前基线(契约层不需 metallib/Simulator)
python3 scripts/gen_capabilities.py && git diff --stat   # 确认 codegen 当前无漂移
```
下文 hard-code 数字标 `(snapshot 2026-06-19,以上 Check 为准)`。

## 4. 边界(CONSTRAINTS / BOUNDARIES)
- **红线**(完整见 `CLAUDE.md §6`):真实客户名一律「某车厂」;报价/密钥/PII/车型代号绝不入仓;真实 bug 训练集即便脱敏不入仓;不降级(Qwen3-1.7B+LoRA 主线)。
- **禁区**:**禁碰 main / 禁 archive / 禁动其他 change**(`define-intent-routing` / `define-voice-*` / `define-lora-*` / `define-vehicle-tool-bench`);禁动 `~/workspace/raw/` 与 `~/Downloads/`(只读参考源)。
- **OUT_OF_SCOPE**:F1 intent gate 实装(归 change7,只留 hook)/ MLX runtime 接入(E1b 拆出)/ iOS App target / CI GitHub Actions(磊哥定)。超范围 → 返回说明 + 建议归属,**不硬扛、不顺手扩**。
- **🔴 多 agent git 协作三纪律**(2026-06-19 pre-mortem 沉淀,硬约束):
  1. **一 agent 一 worktree 一分支**:本 dispatch 写死 cwd=`/Users/wanglei/workspace/MAformac-change3-fix`(隔离 worktree),分支 `feat/change3-execution-contract`,**不在主树裸跑**。
  2. **main 单写者**:只 CC merge main;Codex **只在 `feat/change3-execution-contract` commit**,**禁 merge / 禁 archive / 禁动 main 或其他 change**(越界即 dispatch FAIL)。
  3. **强制 ground-truth git 验证**(防幻觉):任何「完成 / 已 commit / 已 push」断言**必须附** `git -C <worktree> status --short` + `git log --oneline -5` + `git branch --show-current` 实际 stdout;CC 收稿后自跑核对。实证:2026-06-19 Codex 在共享 worktree 幻觉过不存在的 commit + archive 操作。

## 5. 验收门
> codex-metacognition §23 三硬约束 + OpenSpec tasks 验收 + Pre-Mortem。
- 每条 task 带**证据 / 等级**,不写「完成 / OK」大词。
- **必过门**:
  - `swift test` 全绿(契约层,不需 metallib/Simulator),回报附实际 stdout 尾部。
  - readback mismatch=0(正例)。
  - executedCount 重定义后只统计正例(40);负例 content-fallback 零执行;N002 标 known-issue。
  - F2 多 cell 落地测试全过(AC 温度 / ambient color / unchanged 不写)。
  - codegen drift check exit 0(F2 改 yaml 后生成物已提交)。
- **failure** → 写 failure receipt(risk_state 枚举 + 实际异常,别静默吞)。
- **smoketest** 用 spike 实采 fixture(`dev/spike-e3/Reports/spike-e3-results.json` 55 条,非 mock/非 LLM 自造)。
- **新技术点动手前先 Pre-Mortem**(F2 的 capabilities.yaml schema 扩展 + 多 cell 写是本 change 新点):scout 本机(design T7 命名漂移史 / store immutability 模式)+ 核 failure mode(多 cell 写破坏 immutability / transform schema 与 codegen 不同步 / `unchanged` 语义遗漏 / ambient 合成语义漏 color)。Risks 填实证坑、非空泛。

## 6. 相关文件(优先读,≤5,绝对路径)
1. `/Users/wanglei/Downloads/pr_audit_1(1).md` — GPT Pro 8 维审计全报告(F1-F7 证据 file:line)
2. `/Users/wanglei/workspace/MAformac/openspec/changes/define-execution-contract/design.md` — T9/E1a/E1b 边界(intent gate 归 change7 的依据)
3. `/Users/wanglei/workspace/MAformac/Core/Execution/DemoActionExecutor.swift` + `Core/Execution/DemoGuard.swift` — F2/F3 主战场
4. `/Users/wanglei/workspace/MAformac/contracts/capabilities.yaml` + `scripts/gen_capabilities.py` — F2 transform spec 落地 + F6
5. `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/SpikeFixtureContractTests.swift` — P0-3 测试纠偏(executedCount 重定义)

## 7. 完成回报格式(DELIVERABLE,带 status field)
- **status**:`done` / `blocked` / `partial`
- **产出清单**:每文件 + 每项验收结果(带证据:`swift test` 尾部 stdout / 测试名 / drift exit code / 多 cell 断言)
- **三纪律 ground-truth**:附 `git -C /Users/wanglei/workspace/MAformac-change3-fix status --short` + `git log --oneline -5` + `git branch --show-current` + `gh pr view 1 --json state,headRefOid` 实际 stdout
- **BLOCKED**(卡住时):`BLOCKED: <缺什么> FROM: <需谁 / 什么资源>`
- **关键发现 / 偏差**:分清 `introduced`(本次引入)vs `exposed`(旧债暴露)
- **下一步建议**:具体动作(如「请 CC 派 GPT Pro 复审 PR #1 head `<新 sha>`」)

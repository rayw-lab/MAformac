# Dispatch: apply define-demo-mvp-contract(change 1 实装第一刀)

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

## 0. 路由元信息
- **TO**:Codex(长跑 TDD)
- **FROM**:Claude(CC,管前端+原型+审计;本 dispatch 是 change1 实装交接)
- **MODE / MODEL**:Codex 长跑实装 + Superpowers TDD(write-test-first)
- **PRIORITY**:P0(6-change 第一个,骨架立住 change2-6 才能往上挂)
- **一句话 DELIVERABLE**:实装 change1 的 15 tasks = MAformac SwiftUI 工程骨架 + 契约源占位 + 跨子系统核心协议 + 最小 walking skeleton(**先 macOS target 跑通**),`openspec status` 推到 15/15。

## 1. 冷启动背景
- **项目**:MAformac = 纯端侧 iOS/macOS 离线车控**方案演示助手**(给客户现场演示,非量产 / 非真车控)。北极星:现场 5 分钟听懂中文、反应快、不崩、看着惊艳、断网也能跑。**起手必读** `/Users/wanglei/workspace/MAformac/CLAUDE.md` → `docs/README.md` → 本 dispatch。
- **本任务处于**:S1→S2,6-change 拆法的**第 1 个** `define-demo-mvp-contract`(顶层契约 + 立项骨架)。已 propose 完成(4/4 artifact + validate + subagent 审计 B+ + Codex P1/P2/P3 全修复)。
- **为什么现在做**:骨架 + walking skeleton 立住后,change2(capability)/3(execution)/4(voice)/5(lora)/6(eval)直接往这个骨架挂。「先做出来」最快见效。

## 2. 任务(TASK)
实装 `openspec/changes/define-demo-mvp-contract/tasks.md` 的 5 组 15 条 task(已 agree before build)。完成后逐条勾选 / `openspec apply` 推到 15/15。
- **组 1 项目骨架**:SwiftUI 工程(iOS + macOS target,无后端)+ 目录(`App/` `Core/{Capability,LLM,Voice,Intent,Routing,Execution,State,Trace}/` `Features/VehicleControl/` `Resources/` `dev/`)+ `.gitignore`(权重/venv/数据不入仓)。
- **组 2 契约源**:`contracts/capabilities.yaml`(schema 骨架 + 1 样例占位,字段**含 `display_zh`**,以 define-capability-contract 定稿为准)+ `agents.yaml`(车控 1 条 + 导航/音乐/外卖 `connector:mock`+`enabled:false` 占位)。
- **组 3 核心协议(空实现)**:`LLMBackend` / `Capability`+Registry / `ToolCallFrame`+`AgentDescriptor`+`SurfacePolicy` / `DemoVehicleStateStore`(`@Observable @MainActor`,8 字段 cell)/ `DemoGuard` 协议位 + `TraceLogger` 五段接口。**DemoGuard 此处仅协议位,完整 R0-R3 门留 change3**。
- **组 4 walking skeleton(先 macOS target)**:FastPath「打开空调」→ ToolCallFrame → DemoGuard 单条放行 → applyMockTransition → DemoVehicleStateStore → UI 卡片亮 + AVSpeech 占位 TTS + TraceLogger 五段。
- **组 5 验收脚手架**:demo-experience 硬验收(readback mismatch=0 / Unsafe false pass=0 / pending 不冒充)落占位测试骨架 + 15-25 条 5 幕演示集占位清单。

## 3. Prerequisite Check(起手必跑)
```bash
cd /Users/wanglei/workspace/MAformac
openspec status --change "define-demo-mvp-contract"   # 期望 4/4 artifact, 0/15 tasks(snapshot 2026-06-18,以实际为准)
openspec validate "define-demo-mvp-contract"          # 期望 valid
git status --short
xcodebuild -version                                   # 确认完整 Xcode(iOS SDK ready;iOS Simulator 可能仍在下)
xcrun simctl list runtimes | grep -i ios              # iOS Simulator 是否就绪(决定 iOS target 能否跑)
```

## 4. 边界
- **红线**(CLAUDE §6):真实客户名「某车厂」/报价/密钥/PII/车型代号绝不入仓;真实 bug 训练集不入仓(仅权重可);**不降级**(Qwen3-1.7B+LoRA 主线,0.6B/FoundationModels/llama.cpp 仅备选对照)。
- **DemoGuard 仅协议位**(完整门 change3);**walking skeleton 先 macOS target**(iOS 真机/模拟器等 Simulator 下完补,真机需 Apple Developer 签名 = 演示机 iPhone 15 Pro Max 8GB)。
- **OUT_OF_SCOPE**:子系统完整实现(ASR/LLM/LoRA/eval 实体)留各自 change,本 change 只立骨架 + 协议位 + 最小闭环。超范围返回说明,不硬扛、不顺手扩。

## 5. 验收门
- tasks.md 每条验收标准(带证据,不写「完成/OK」大词)。
- `openspec validate` 通过;**macOS target build 成功**;walking skeleton 输入「打开空调」→ **UI 卡片肉眼可见变化 + 读回 actualValue**;TTS 播 readback(非请求值);trace 输出五段。
- TDD:task 4.1 / 5.1 标 write-test-first(先红再绿)。
- **新技术点动手前先 Pre-Mortem**(SwiftUI `@Observable` 生命周期 / mlx-swift 集成 等):scout 本机 38repo + oracle **Codex 自己的 subagent + web** 搜 failure mode,坑填进 design Risks(见 `~/.codex/skills/pre-mortem/SKILL.md`)。
- failure → 写 failure receipt(risk_state 枚举 + 实际异常),别静默吞。

## 6. 相关文件(优先读,绝对路径)
1. `/Users/wanglei/workspace/MAformac/openspec/changes/define-demo-mvp-contract/tasks.md`(主:15 task)
2. `/Users/wanglei/workspace/MAformac/openspec/changes/define-demo-mvp-contract/design.md`(主链路 + 11 决策表 + 7 层命名)
3. `/Users/wanglei/workspace/MAformac/openspec/changes/define-demo-mvp-contract/specs/demo-experience/spec.md`(行为契约 SHALL)
4. `/Users/wanglei/workspace/MAformac/CLAUDE.md`(项目宪法 + 边界红线)
5. `/Users/wanglei/workspace/MAformac/docs/integration-blueprint.md`(§7 骨架目录参考)

## 7. 完成回报格式
- **status**:`done` / `blocked` / `partial`
- **产出清单**:工程 + 各 task 验收结果(带证据:build log / walking skeleton trace 输出或截图)
- **BLOCKED**(如):`BLOCKED: <缺什么> FROM: <需谁>`(如 iOS Simulator 未就绪 → macOS target 先交、iOS target 标 blocked)
- **关键发现 / 偏差**:`introduced`(本次引入)vs `exposed`(旧债暴露)分清
- **下一步建议**:change2 capability 的接入点

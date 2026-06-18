# Dispatch: spike E3 — Qwen3-1.7B base function call 生死线验证（change3 task 0.1）

## 0. 路由元信息
- **TO**:Codex（长跑,无人值守量化实验）
- **FROM**:Claude（CC,管前端+原型+审计）
- **MODE / MODEL**:Codex 长跑 spike + Superpowers verification
- **PRIORITY**:P0（change3 生死线前置;结果决定 execution 实装路径 + 新 `define-intent-routing` change 的 FC 泛化层怎么做）
- **一句话 DELIVERABLE**:量化 Qwen3-1.7B-4bit 经 `mlx-swift-lm` 的 **base**（无 LoRA）function call 能力（触发率/格式稳定性/拒识/延迟/G3 参数规划），出 **go/no-go + 实测数据报告**。

## 1. 冷启动背景（承接方零上下文也能懂）
- **项目**:MAformac = 纯端侧 iOS/macOS 离线车控**演示助手**（**demo,不接真车,全 mock**）,Qwen3-1.7B+LoRA 大脑。**起手必读** `/Users/wanglei/workspace/MAformac/CLAUDE.md` → `docs/cockpit-voice-fc-premortem-2026-06-18.md`（座舱三层原理 + base 1.7B 硬数据 + demo 边界）→ 本 dispatch。
- **本任务**:change3 `define-execution-contract` 的 **task 0.1 前置 spike**（go/no-go）。adopt `mlx-swift-lm` 上游 tool-call parser 是 change3 根架构决策,需 base 1.7B function call 能力实测才坐实。
- **为什么现在做**:base 1.7B 的 function call 触发率/格式是整个三层架构的**地基未知数**。spike 一跑,change3 实装路径 + 新 intent-routing change 的 FC 泛化层实现,都有实测支撑。**先验地基再盖楼,不拍脑袋**。
- **背景硬数据**（oracle 已搜,prompt 别当结论,自己实测）:BFCL Qwen3-1.7B overall ~55%/multi-turn ~17%;微调小模型可碾压通用大模型(xLAM-3b-fc 65.74%、in-vehicle Phi-3 1.8B+LoRA 0.86>规则0.75)→ **base 弱不等于 no-go,LoRA 兜底**。

## 2. 任务(TASK)
跑 spike E3,量化 base Qwen3-1.7B-4bit 的 function call 能力。**只做 spike,不做 change3 完整实装**（decode/错误枚举/DemoGuard/执行链留 change3 主体）。
- **2.1 环境（隔离,不污染主项目）**:**spike harness 放 `dev/spike-e3/` 下一个独立 SPM 包**（自己的 `Package.swift` 加 `mlx-swift-lm`,pin exact tag),**绝不碰仓根主 `Package.swift`**——主项目编译不该被 MLX Metal 栈拖累,直到 change3 确定 adopt 才正式并入。下 Qwen3-1.7B-4bit mlx 量化模型(HF `mlx-community`,~1GB,模型不入仓)。
- **2.2 harness**:最小 Swift 可执行 target,喂样本,**显式锁 `toolCallFormat = .json`**(不靠 `infer()`),消费 `.toolCall` 事件,统计 5 维。`enable_thinking=false`。
- **2.3 测试样本（实采,非 LLM 自造）**:用 `contracts/capabilities.yaml` 8 能力 × 5 幕话术造 **N≥40 条**车控指令(L1 精确「打开空调」/L2 模糊「我有点热」/L3 场景「下雨了」/L4 自由「热得像蒸笼」)+ **M≥15 条**非车控拒识负样本(闲聊/无关)。
- **2.4 量化 5 维 + go/no-go**（见验收门）。

## 3. Prerequisite Check（起手必跑）
```bash
cd /Users/wanglei/workspace/MAformac
openspec status --change "define-execution-contract"   # 期望 0/14(snapshot 2026-06-18)
git status --short
xcrun simctl list runtimes | grep -i ios               # iOS 26.5 ready
swift --version                                         # 本机 Swift 6.3.2 / M5
# mlx-swift-lm latest stable tag(pin 用,标 snapshot 时间):
gh release list --repo ml-explore/mlx-swift-lm | head -3
```

## 4. 边界(CONSTRAINTS)
- **🔴 demo 边界(CLAUDE §6 + magnet 重申)**:**这是 demo,不接真车**。spike 只验 base function call 能力,**不**实现真车控/CAN/ECU。真实车厂脱敏「某车厂」。**不降级**(1.7B 主线,不偷换 0.6B/llama.cpp)。
- **🔴 隔离**:spike 代码限 `dev/spike-e3/`(独立 SPM 包);**禁碰主 `Package.swift` / App/ / Core/**。模型权重不入仓(`.gitignore`)。
- **只做 spike**:不写 DemoGuard 完整门/错误枚举三态/执行链(change3 主体)。本 spike 产出 = 数据 + 裁决,不是 change3 实装。
- **OUT_OF_SCOPE**:LoRA 训练(change5)、完整 ToolCallFrame 薄层(change3 主体)、voice。超范围返回说明,不顺手扩。

## 5. 验收门（pre-mortem 硬 gate,不只验 happy path）
> 「收到 `.toolCall` 事件」只是最外层。pre-mortem 要的是下面 5 维实测。
- **G1 触发率**:N 条车控指令的 `.toolCall` 解析成功率。**go/no-go**:≥80% go(直接推进 change3 主体)/ 50-80% go + 记「LoRA Day1 重点采漏触发样本」/ <50% LoRA 前置 + 记 **HIGH risk**(回报必停让磊哥拍)。
- **G2 格式稳定性**:统计 Qwen 把 FC 当 JSON text 塞进 `.chunk` content 而非 `.toolCall` 事件的比例（T2 失配指纹 + 已知坑）。
- **G3 拒识**:M 条非车控负样本的误调率（验「不该调不乱调」,不幻觉车控）。
- **G4 延迟**:实测 tok/s + 单条多槽位 JSON 出参耗时;明确锚点（到 `.toolCall` vs 到完整 JSON）;测 streaming（边出边解析）是否可行。**对照 demo 北极星「反应快」**。
- **G5 G3 参数规划 mini-spike**:测 base 能否做「大海颜色→色值枚举」类**开放词→枚举映射**（座舱 G3 泛化）。出能/不能 + 实例。**决定新 intent-routing change 的 FC 泛化层靠 LLM 还是端侧小表**。
- **横切**:`enable_thinking=false` 实测（thinking 破坏 tool parser,非偏好）;含 `<think>` → 记 think_leak。
- **failure** → 写 failure receipt（risk_state 枚举 + 实际异常）,别静默吞。

## 6. 相关文件（优先读,≤5,绝对路径）
1. `/Users/wanglei/workspace/MAformac/openspec/changes/define-execution-contract/{design,tasks}.md`（task 0.1 + adopt 决策 + Risks + mlx 源码锚点）
2. `/Users/wanglei/workspace/MAformac/docs/cockpit-voice-fc-premortem-2026-06-18.md`（座舱三层 + base 1.7B 硬数据 + **demo 边界划线**）
3. `/Users/wanglei/workspace/MAformac/docs/execution-pre-mortem-2026-06-18.md`（8 发现 + `mlx-swift-lm` 源码锚点 `Libraries/MLXLMCommon/Tool/`）
4. `/Users/wanglei/workspace/MAformac/docs/qwen3-engineering-notes.md`（Qwen3 工程硬约束 4 隐藏层 + enable_thinking）
5. `/Users/wanglei/workspace/MAformac/contracts/capabilities.yaml`（8 能力 → 造 N 条实采样本）

## 7. 完成回报格式（DELIVERABLE,带 status field）
- **status**:`done` / `blocked` / `partial`
- **产出清单**:spike 报告（**G1-G5 实测数据 + go/no-go 裁决**）+ harness 代码(`dev/spike-e3/`)+ `Package.swift` mlx pin tag（snapshot 时间）。
- **BLOCKED**:`BLOCKED: <缺什么> FROM: <需谁/资源>`（如模型下载失败/mlx 编译失败 → 记实际异常）。
- **关键发现 / 偏差**:分清 `introduced`（本次引入）vs `exposed`（旧债暴露）。
- **下一步建议**:① change3 主体实装接入点;② 基于 G5 给新 `define-intent-routing` 的 FC 泛化层实现建议（LLM vs 端侧小表）;③ 若 G1 <80% → LoRA Day1 采样策略。

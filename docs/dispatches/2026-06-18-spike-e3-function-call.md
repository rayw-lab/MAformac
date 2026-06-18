# Dispatch: spike E3 — Qwen3-1.7B base function call 生死线（change3 task 0.1）· **v2 续跑版**

> **v2(2026-06-18)**:Codex 首跑已落隔离包 + harness + 55 样本 + `swift build` 通过,**卡在 metallib 运行态坑被磊哥中断**。本版整合实测坑,**续跑从「解 metallib + 跑 smoke」继续,不从头重写**。

## 0. 路由元信息
- **TO**:Codex（长跑续跑）· **FROM**:Claude · **PRIORITY**:P0（change3 生死线）
- **一句话 DELIVERABLE**:解 metallib 运行态坑 → 跑 smoke → 全量 55 条 → G1-G5 实测数据 + go/no-go。

## 0.5 🟢 续跑基线（Codex 首跑已落,验证过,别重做）
`dev/spike-e3/` 已落地且 **`swift build -c release` 通过**:
- **Package.swift**:依赖 pin 已修正——`mlx-swift-lm` exact **3.31.3**(2026-04-15 latest) / `swift-transformers` **1.3.3** / `swift-huggingface` **0.9.0**;products 含 MLXLLM/MLXLMCommon/MLXHuggingFace/Tokenizers/HuggingFace。
- **Sources/SpikeE3/main.swift**:harness = 单模型加载 + **每 case 新 `ChatSession`**(避历史污染) + `enable_thinking=false` 双保险(additionalContext + 系统指令) + 采集 `.chunk`/`.toolCall`/`.info` 三类事件 + **区分「真 .toolCall」vs「工具 JSON 塞进 .chunk content」**(G2 指纹) + 55 样本(8 capability × 5 条 L1-L4/G3 + 15 负例:闲聊/跨域/OOD/restraint)。
- README / .gitignore / 报告占位齐。

**卡死点**:`swift run -c release` → `Failed to load the default metallib`(**非模型能力,是 SwiftPM 命令行不编译 Metal shaders 的已知坑**)。

## 1. 🔴 实测坑清单（Codex 首跑 catch,续跑必避）
1. **metallib 运行态坑（关键阻塞,先解这个）**:`swift run`/`swift build` 命令行**不编译 Metal shaders** → runtime `Failed to load default metallib`。**解法**:① 最简 = `open Package.swift` 在 Xcode ⌘R(磊哥本机有 Xcode);② 无人值守 = `xcodebuild -scheme spike-e3 -configuration Release -destination 'platform=macOS' build` 让 Xcode 编 metallib → 跑 `DerivedData/.../Release/spike-e3` 产物(metallib bundle 应在旁);③ 兜底 = 手动 copy `mlx-swift_Cmlx.bundle`+`default.metallib` 到产物同目录。源:[mlx metallib 坑](https://github.com/Trans-N-ai/swama/issues/30)。
2. **API 差异（3.31.3 实际 tag,别按参考源码假设）**:`LLMModelFactory.qwen3_1_7b_4bit` **未暴露** → 用 `ModelConfiguration(id: "mlx-community/Qwen3-1.7B-4bit", toolCallFormat: .json)` 避 registry 耦合(Codex 已改);HuggingFace loader 是**宏要加 `#`**;`streamDetails` 显式传**空 images/videos**;MLXHuggingFace 宏要 harness 显式引 swift-transformers + swift-huggingface(Codex 已加)。
3. **依赖版本漂移**:swift-transformers 1.3.3 要 swift-huggingface **≥0.9.0**(非 0.8.1,已修);swift-syntax 解析到 600.0.1(参考 602.x floor 不一致但 build 过,放行)。
4. **首次 release build 慢**(编译 MLX C++/Metal 栈)= 预期,不是卡死。

## 2. 任务（续跑步骤）
- **2.1 解 metallib**(坑 #1 三选一)→ 跑 `--limit 3` smoke,验**模型下载 + 加载 + 收到 `.toolCall` 事件**(非 `.chunk` 含 `<tool_call>` 原文)。**smoke 不过 → 写 BLOCKED + 实际异常,别假装跑过模型**。
- **2.2 smoke 过 → 跑全量 55 条**,采集 5 维(G1-G5)。
- **2.3 出报告**(`Reports/spike-e3-report.md` + `results.json`)+ go/no-go 裁决。
- **弹药增量（B/C/D 盘点,2026-06-18）**:
  - 用 mlx-swift-lm **官方 `ToolSpec`**(PR #174,`UserInput(chat:tools:[ToolSpec])`)不手搓 schema(若首跑已用则确认,未用补)。
  - **实测 Qwen3 的 `ToolCallFormat.json` 解析正确**(Gemma Issue #259 前科:`infer` 漏模型族 → 不能假设官方都对)。
  - 模型用 **4bit/Q4_K_M,避 IQ 量化**(Apple GPU IQ 反而慢)。
  - G4 延迟:抄 mlx-swift `LLMEval` 的 on-device tok/s 统计(TTFT=prefill 时间);**别长预热**(热降频 5-15min 掉 15-41%)。

## 3. Prerequisite Check（续跑起手,快核）
```bash
cd /Users/wanglei/workspace/MAformac/dev/spike-e3
ls Sources/SpikeE3/ Reports/ 2>/dev/null    # 确认首跑产物在
swift build -c release 2>&1 | tail -2        # 应已通过(基线)
xcrun simctl list runtimes | grep -i ios     # iOS 26.5 ready
```

## 4. 边界(CONSTRAINTS)
- **🔴 demo 边界**:demo 不接真车,只验 base function call 能力;真实车厂脱敏「某车厂」;**不降级**(1.7B 主线)。
- **🔴 隔离**:只动 `dev/spike-e3/`,**禁碰主 `Package.swift` / App / Core**;模型权重不入仓(`.gitignore` 已配)。
- **只做 spike**:不写 DemoGuard/错误枚举/执行链(change3 主体)。

## 5. 验收门（5 维硬 gate,不只验 happy path）
- **G1 触发率**:N 条车控的 `.toolCall` 解析成功率。**go/no-go**:≥80% go / 50-80% go+LoRA Day1 采漏触发 / <50% LoRA 前置 + **HIGH risk 停下让磊哥拍**。
- **G2 格式稳定性**:统计 Qwen 把 FC 塞进 `.chunk` content 而非 `.toolCall` 的比例(T2 指纹)。
- **G3 拒识**:15 负例的误调率(「不该调不乱调」)。
- **G4 延迟**:tok/s + TTFT + 多槽位 JSON 出参耗时;锚点(到 `.toolCall` vs 完整 JSON);streaming 可行性。
- **G5 参数规划 mini-spike**:base 能否「大海颜色→色值枚举」(座舱 G3)→ 决定新 intent-routing 的 FC 泛化层靠 LLM vs 端侧小表。
- `enable_thinking=false` 实测;含 `<think>` → 记 think_leak。
- **failure → 写 failure receipt(实际异常)**,别静默吞。

## 6. 相关文件（≤5,绝对路径）
1. `/Users/wanglei/workspace/MAformac/dev/spike-e3/`（**续跑基线:Package.swift + main.swift + 55 样本**）
2. `/Users/wanglei/workspace/MAformac/openspec/changes/define-execution-contract/{design,tasks}.md`（task 0.1 + adopt 决策 + Risks）
3. `/Users/wanglei/workspace/MAformac/docs/cockpit-voice-fc-premortem-2026-06-18.md`（座舱原理 + base 1.7B 硬数据 + demo 边界）
4. `/Users/wanglei/workspace/MAformac/docs/execution-pre-mortem-2026-06-18.md`（mlx-swift-lm 源码锚点）
5. `/Users/wanglei/workspace/MAformac/contracts/capabilities.yaml`（8 能力源）

## 7. 完成回报（带 status field）
- **status**:`done` / `blocked` / `partial`
- **产出**:spike 报告(**G1-G5 实测数据 + go/no-go**)+ harness(`dev/spike-e3/`)。
- **BLOCKED**:`BLOCKED: <缺什么> FROM: <需谁/资源>`(如 metallib 三路都不通 / 模型下载失败 → 记实际异常)。
- **introduced vs exposed** + **下一步建议**(change3 主体接入点 / 基于 G5 给 intent-routing FC 泛化层建议 / G1<80% 的 LoRA 采样策略)。

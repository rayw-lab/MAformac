# GitNexus 参考仓库图谱分析总览

> ⚠️ **HISTORICAL 快照（2026-06-17）—— 文档级联 banner（2026-06-23）**
> 本目录（01-index ~ 04-query + README，5 文件）是立项早期参考仓图谱分析历史快照。范式翻案 + 契约 SSOT 重构后部分结论已过期。**活基线** = `CLAUDE.md §9` + `docs/srd-three-layer-intent-routing.md` + `docs/roadmap-2026-06-20-from-c6-done.md`。正文保留供溯源（repo 索引仍有参考价值），勿据此推进。

状态: `T-PASS` for 36 indexed repos, `T-PARTIAL` for 3 timeout repos  
日期: 2026-06-17  
范围: `/Users/wanglei/workspace/MAformac/referencerepo/repos/`

## 结论

这轮把本项目本地 clone 的参考仓库用 GitNexus 做了结构化索引和分组分析。实际盘点到 39 个 git 仓库: manifest 中 38 个参考仓库, 加 1 个额外本地 clone `Fission-AI__OpenSpec`。其中 36 个完整进入 GitNexus registry, 3 个大体量 C/C++/SDK 仓库因 parser timeout 降级为文件系统和既有报告旁证。

完整索引合计:

- 19,330 indexed files
- 179,692 symbols
- 384,540 graph edges
- 5,038 communities
- 4,431 flows

降级仓库:

- `ggml-org__llama.cpp`: complex C++ parser timeout around `ggml/src/ggml-cpu/ops.cpp`
- `ggml-org__whisper.cpp`: complex C++ parser timeout around `examples/quantize/quantize.cpp`
- `qualcomm__nexa-sdk`: vendored C++ header timeout around `sdk/include/external/fmt/ranges.h`

这些仓库没有被写成完整 GitNexus 证据, 只作为既有报告/文件系统旁证使用。失败半成品 `.gitnexus/` 已清理, 避免未来误判。

## 三条主判断

1. MAformac 的首要资产不是参考仓库代码, 而是一个由 `contracts/capabilities.yaml` 驱动的能力契约层。它应同时派生 Swift 类型、tool schema、UI 卡片、eval fixture、LoRA 数据和 trace schema。

2. 车控链路必须保持“模型只产候选, 代码负责安全”的边界: `ToolCallDecoder -> DemoGuard -> DemoActionExecutor -> DemoVehicleStateStore -> readback trace`。VSS/KUKSA/CAN 只做语义绑定、开发期对照或回归参照, 不进首版离线 demo runtime。

3. 语音、模型、工具调用要拆成独立状态机和接口: ASR 只产文本与置信度, LLM 只产文本或 `ToolCallCandidate`, TTS 只负责播报和中断, MCP 只做外部工具协议适配。任何车控动作都必须回到内部 capability + guard + mock executor。

## 交付物

| 文件 | 用途 |
|---|---|
| [01-index-ledger.md](./01-index-ledger.md) | GitNexus 索引账本、状态、统计和降级说明 |
| [02-architecture-findings.md](./02-architecture-findings.md) | 三组 subagent + 主线程综合后的架构发现 |
| [03-openspec-input.md](./03-openspec-input.md) | 下一阶段 OpenSpec change 的输入草案 |
| [04-query-backlog.md](./04-query-backlog.md) | 后续可复跑 GitNexus 深挖命令 |

## 证据边界

- GitNexus 完整证据: 36 个 `T-PASS` indexed repos, 见 `~/.gitnexus/registry.json`。
- 旁证: `referencerepo/reports/*.md`、`referencerepo/repo_manifest.md`、本地文件系统 inventory。
- 不采纳为完整 GitNexus 证据: `ggml-org__llama.cpp`, `ggml-org__whisper.cpp`, `qualcomm__nexa-sdk`。
- 敏感边界: 只统计风险文件名数量, 不摘录任何 credential / token / secret / env / key / pem 文件内容。


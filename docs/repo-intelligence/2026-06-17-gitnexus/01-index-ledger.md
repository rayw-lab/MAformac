# GitNexus 索引账本

状态: `T-PASS` for indexed repos, `T-PARTIAL` for timeout/fallback repos  
索引命令: `gitnexus analyze <repo> --index-only --skip-agents-md --skip-skills --name <repo-name> --workers 4 --worker-timeout 60 --max-file-size 512`

## 运行结果

- 本地 git 仓库数: 39
- manifest 目标仓库数: 38
- 额外本地 clone: `Fission-AI__OpenSpec`
- 完整 GitNexus indexed repos: 36
- 降级仓库: 3
- 半成品清理: 3 个失败仓库的 `.gitnexus/` 已删除

## 汇总统计

| Metric | Value |
|---|---:|
| Indexed repos | 36 |
| Indexed files | 19,330 |
| Symbols | 179,692 |
| Graph edges | 384,540 |
| Communities | 5,038 |
| Flows | 4,431 |

## 最大图谱仓库

| Repo | Files | Symbols | Edges | Flows |
|---|---:|---:|---:|---:|
| `k2-fsa__sherpa-onnx` | 3,762 | 41,307 | 81,740 | 300 |
| `alexa__alexa-auto-sdk` | 2,292 | 26,976 | 36,638 | 219 |
| `ml-explore__mlx-swift-lm` | 240 | 16,618 | 67,579 | 300 |
| `instructor-ai__instructor` | 817 | 10,631 | 16,673 | 300 |
| `Fission-AI__OpenSpec` | 794 | 10,163 | 16,398 | 300 |
| `argmaxinc__WhisperKit` | 209 | 8,826 | 23,404 | 300 |
| `argmaxinc__argmax-oss-swift` | 209 | 8,826 | 23,404 | 300 |
| `OHF-Voice__intents` | 6,776 | 7,560 | 7,828 | 22 |
| `eclipse-autowrx__autowrx` | 709 | 7,506 | 14,852 | 253 |
| `modelcontextprotocol__swift-sdk` | 93 | 4,269 | 14,506 | 227 |

## 完整账本

| Repo | Category | Status | Files | Symbols | Edges | Flows | Notes |
|---|---|---:|---:|---:|---:|---:|---|
| `Bosch-Connected-Experience-26__Canals` | Vehicle voice agent | T-PASS | 91 | 928 | 1,344 | 33 | risk-name files=1 |
| `COVESA__vdm` | Vehicle data model | T-PASS | 178 | 195 | 190 | 0 |  |
| `COVESA__vehicle-edge` | Vehicle edge stack | T-PASS | 72 | 285 | 411 | 10 | risk-name files=2 |
| `COVESA__vehicle_signal_specification` | Vehicle signal standard | T-PASS | 120 | 327 | 327 | 0 |  |
| `COVESA__vss-tools` | VSS tooling | T-PASS | 526 | 3,117 | 6,109 | 236 |  |
| `Fission-AI__OpenSpec` | extra local clone | T-PASS | 794 | 10,163 | 16,398 | 300 | extra local clone not in manifest |
| `MadeAgents__Hammer` | Small model function calling | T-PASS | 19 | 100 | 120 | 0 |  |
| `OHF-Voice__hassil` | Deterministic NLU | T-PASS | 44 | 961 | 1,895 | 83 |  |
| `OHF-Voice__intents` | Intent sentence corpus | T-PASS | 6,776 | 7,560 | 7,828 | 22 |  |
| `ShishirPatil__gorilla` | Function-call eval | T-PASS | 431 | 4,175 | 8,453 | 214 | risk-name files=1 |
| `StanfordSpezi__SpeziLLM` | Swift LLM app framework | T-PASS | 272 | 2,354 | 11,809 | 31 | risk-name files=13 |
| `alexa__alexa-auto-sdk` | Auto voice SDK | T-PASS | 2,292 | 26,976 | 36,638 | 219 | risk-name files=5 |
| `argmaxinc__WhisperKit` | Apple offline ASR | T-PASS | 209 | 8,826 | 23,404 | 300 | risk-name files=11 |
| `argmaxinc__argmax-oss-swift` | Apple speech AI | T-PASS | 209 | 8,826 | 23,404 | 300 | risk-name files=11 |
| `dengky23__nlu-pipeline-vehicle` | Vehicle NLU pipeline | T-PASS | 13 | 123 | 248 | 7 |  |
| `dottxt-ai__outlines` | Structured generation | T-PASS | 225 | 3,895 | 6,796 | 217 | risk-name files=4 |
| `eclipse-autowrx__autowrx` | SDV prototyping | T-PASS | 709 | 7,506 | 14,852 | 253 | risk-name files=8 |
| `eclipse-kuksa__kuksa-can-provider` | CAN/VSS bridge | T-PASS | 63 | 406 | 705 | 15 |  |
| `eclipse-kuksa__kuksa-databroker` | Vehicle data broker | T-PASS | 162 | 2,278 | 5,248 | 192 | risk-name files=12 |
| `eclipse-velocitas__vehicle-app-python-template` | SDV app template | T-PASS | 18 | 51 | 45 | 0 |  |
| `ggml-org__llama.cpp` | Local LLM runtime | T-PARTIAL | 2,994 |  |  |  | GitNexus parse timeout; file/report fallback; risk-name files=19 |
| `ggml-org__whisper.cpp` | Offline ASR runtime | T-PARTIAL | 1,882 |  |  |  | GitNexus parse timeout; file/report fallback; risk-name files=6 |
| `guidance-ai__guidance` | Controlled generation | T-PASS | 244 | 2,933 | 5,694 | 153 | risk-name files=10 |
| `huggingface__swift-transformers` | Swift model integration | T-PASS | 81 | 2,552 | 5,700 | 69 | risk-name files=23 |
| `instructor-ai__instructor` | Structured extraction | T-PASS | 817 | 10,631 | 16,673 | 300 |  |
| `javierlimt6__tiny-tool-bench` | Tiny model tool eval | T-PASS | 43 | 383 | 713 | 25 |  |
| `k2-fsa__sherpa-onnx` | Offline speech stack | T-PASS | 3,762 | 41,307 | 81,740 | 300 | risk-name files=28 |
| `mattt__llama.swift` | Swift llama.cpp wrapper | T-PASS | 4 | 18 | 17 | 0 |  |
| `ml-explore__mlx-swift-lm` | MLX Swift LLM | T-PASS | 240 | 16,618 | 67,579 | 300 | risk-name files=7 |
| `modelcontextprotocol__swift-sdk` | Swift MCP integration | T-PASS | 93 | 4,269 | 14,506 | 227 | risk-name files=3 |
| `mozilla-ai__llamafile` | Single-file LLM runtime | T-PASS | 237 | 3,229 | 5,721 | 272 |  |
| `noamgat__lm-format-enforcer` | Structured output | T-PASS | 44 | 794 | 1,361 | 29 | risk-name files=4 |
| `qualcomm__nexa-sdk` | Local LLM/VLM SDK | T-PARTIAL | 589 |  |  |  | GitNexus parse timeout; file/report fallback; risk-name files=2 |
| `reinhardjurk__agent-tester` | Vehicle agent evaluation | T-PASS | 42 | 421 | 596 | 19 |  |
| `rhasspy__rhasspy` | Offline voice assistant | T-PASS | 110 | 519 | 598 | 0 | risk-name files=1 |
| `shawnq-msft__azure-voice-live-for-car-android` | Car voice UX | T-PASS | 47 | 182 | 247 | 3 | risk-name files=1 |
| `tattn__LocalLLMClient` | Swift LLM runtime facade | T-PASS | 145 | 3,071 | 9,610 | 125 | risk-name files=1 |
| `weathour__vehicle-offline-voice-android` | Offline vehicle voice | T-PASS | 171 | 2,446 | 5,542 | 145 |  |
| `wizcheu__iOSLLMFrameworkBenchmark` | iOS LLM benchmark | T-PASS | 27 | 1,267 | 2,019 | 32 |  |

## 降级原因

`ggml-org__llama.cpp`, `ggml-org__whisper.cpp`, `qualcomm__nexa-sdk` 都是复杂 C/C++ 或 SDK 仓库, GitNexus parser 在 vendored/large C++ 文件上进入 timeout retry。为保证本轮横向分析完成, 已中断并删除半索引目录。

这三个仓库仍可作为旁证使用, 但不能写成“完整 GitNexus 图谱已覆盖”。

